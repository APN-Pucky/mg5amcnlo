      program reweight_xsec_events
c Given a LH file that contains an <rwgt> part, computes the scale 
c and/or PDF dependence through reweighting. A new file is created,
c which does not contain the <rwgt> part, but retains only the 
c information on the maximum and minimum weights due to scale
c and PDF variations
c Compile with makefile_rwgt
      implicit none
      include "genps.inc"
      include "reweight.inc"
      integer maxevt,ifile,ofile,i,isave,imu,ipdf
      double precision saved_weight
      logical unweighted
      integer IDBMUP(2),PDFGUP(2),PDFSUP(2),IDWTUP,NPRUP,LPRUP
      double precision EBMUP(2),XSECUP,XERRUP,XMAXUP
      INTEGER MAXNUP
      PARAMETER (MAXNUP=500)
      INTEGER NUP,IDPRUP,IDUP(MAXNUP),ISTUP(MAXNUP),
     # MOTHUP(2,MAXNUP),ICOLUP(2,MAXNUP)
      DOUBLE PRECISION XWGTUP,SCALUP,AQEDUP,AQCDUP,
     # PUP(5,MAXNUP),VTIMUP(MAXNUP),SPINUP(MAXNUP)
      integer isorh_lhe,ifks_lhe,jfks_lhe,fksfather_lhe,ipartner_lhe
      double precision scale1_lhe,scale2_lhe,percentage
      integer kwgtinfo,kexternal,jwgtnumpartn
      double precision wgtcentral,wgtmumin,wgtmumax,wgtpdfmin,wgtpdfmax
      double precision xmuR_over_ref,xmuF1_over_ref,xmuF2_over_ref,
     # xQES_over_ref,pr_muR_over_ref,pr_muF1_over_ref,pr_muF2_over_ref,
     # tmp,yfactR(maxscales),yfactF(maxscales),xsecPDFr(0:maxPDFs)
      double precision compute_rwgt_wgt_Sev,compute_rwgt_wgt_Hev
      integer kr,kf,n,nng,nps,npairs,nsets,izero,itmp,idpdf(0:maxPDFs)
      parameter (izero=0)
      integer lef
      character*80 event_file,fname1
      character*140 buff
      character*10 MonteCarlo
      character*1 ch1
      character*20 parm(20)
      double precision value(20)
      logical AddInfoLHE
      external compute_rwgt_wgt_Sev,compute_rwgt_wgt_Hev
c
      call setrun                !Sets up run parameters

      write(*,*) 'Enter event file name'
      read(*,*) event_file

      write(*,*)'Enter 1 to save all cross sections on tape'
      write(*,*)'      0 otherwise'
      read(*,*)isave
      if(isave.eq.1)then
        isave=8
      else
        isave=0
      endif

      write(*,*)'Enter 1 to compute scale uncertainty'
      write(*,*)'      0 otherwise'
      read(*,*)imu

      write(*,*)'Enter 1 to compute PDF uncertainty'
      write(*,*)'      0 otherwise'
      read(*,*)ipdf

      write(6,*)'Enter QES_over_ref used in the reference computation'
      read(5,*)xQES_over_ref

      write(6,*)'Enter muR_over_ref, muF1_over_ref(=muF2_over_ref)'
      write(6,*)'  used in the reference computation'
      read(5,*)xmuR_over_ref,xmuF1_over_ref
      xmuF2_over_ref=xmuF1_over_ref

      if(imu.ne.0)then
        write(6,*)'Enter renormalization scale variation range'
        write(6,*)'  (e.g., 0.5 2.0)'
        read(5,*)yfactR(2),yfactR(3)
        yfactR(1)=1.d0
        write(6,*)'Enter factorization scale variation range'
        write(6,*)'  (e.g., 0.5 2.0)'
        read(5,*)yfactF(2),yfactF(3)
        yfactF(1)=1.d0
        numscales=3
        if(numscales.gt.maxscales)then
          write(*,*)
     #      'Too many scales: increase maxscales in reweight0.inc'
          stop
        endif
      else
        numscales=0
      endif

c Note: when ipdf#0, the central PDF set will be used also as a reference
c for the scale uncertainty
      if(ipdf.ne.0)then
        write(6,*)'Enter id number of central set'
        read(5,*)idpdf(0)
        write(6,*)'Enter id numbers of first and last error set'
        read(5,*)idpdf(1),itmp
c
        nsets=itmp-idpdf(1)+1
        if(mod(nsets,2).ne.0)then
          write(*,*)'The number of error sets must be even',nsets
          stop
        else
          npairs=nsets/2
        endif
        do i=2,nsets
          idpdf(i)=idpdf(1)+i-1
        enddo
        if(nsets.gt.maxPDFs)then
          write(*,*)'Too many PDFs: increase maxPDFs in reweight0.inc'
          stop
        endif
c
        value(1)=idpdf(0)
        parm(1)='DEFAULT'
        call pdfset(parm,value)
c
        numPDFpairs=npairs
      else
        numPDFpairs=0
      endif

c$$$      call fk88strcat(event_file,'.rwgt',fname1)
      lef=index(event_file,' ')-1
      fname1=event_file(1:lef)//'.rwgt'

      ifile=34
      open (unit=ifile,file=event_file,status='old')
      AddInfoLHE=.true.
      unweighted=.true.
      call read_lhef_header(ifile,maxevt,MonteCarlo)
      call read_lhef_init(ifile,
     &     IDBMUP,EBMUP,PDFGUP,PDFSUP,IDWTUP,NPRUP,
     &     XSECUP,XERRUP,XMAXUP,LPRUP)

      do i=1,min(10,maxevt)
        call read_lhef_event(ifile,
     &       NUP,IDPRUP,XWGTUP,SCALUP,AQEDUP,AQCDUP,
     &       IDUP,ISTUP,MOTHUP,ICOLUP,PUP,VTIMUP,SPINUP,buff)

        if(buff(1:1).ne.'#')then
          write(*,*)'This event file cannot be reweighted [1]',i
          stop
        endif
        read(buff,200)ch1,iSorH_lhe,ifks_lhe,jfks_lhe,
     #                    fksfather_lhe,ipartner_lhe,
     #                    scale1_lhe,scale2_lhe,
     #                    kwgtinfo,kexternal,jwgtnumpartn,
     #         wgtcentral,wgtmumin,wgtmumax,wgtpdfmin,wgtpdfmax
        if(kwgtinfo.lt.1.or.kwgtinfo.gt.4)then
          write(*,*)'This event file cannot be reweighted [2]',i
          write(*,*)kwgtinfo
          stop
        endif
        if(i.eq.1)then
          saved_weight=abs(XWGTUP)
        else
          unweighted=unweighted.and.
     #               abs(1.d0-abs(XWGTUP)/saved_weight).lt.1.d-5
        endif
      enddo
      close(34)

      write(*,*)'  '
      if(unweighted)then
        write(*,*)'The events appear to be unweighted'
        write(*,*)' Will store the ratios of recomputed weights'
        write(*,*)' over reference weights'
      else
        write(*,*)'The events appear to be weighted'
        write(*,*)' Will store recomputed weights'
      endif

      open (unit=ifile,file=event_file,status='old')
      ofile=35
      open(unit=ofile,file=fname1,status='unknown')

      call read_lhef_header(ifile,maxevt,MonteCarlo)
      call write_lhef_header(ofile,maxevt,MonteCarlo)
      call read_lhef_init(ifile,
     &     IDBMUP,EBMUP,PDFGUP,PDFSUP,IDWTUP,NPRUP,
     &     XSECUP,XERRUP,XMAXUP,LPRUP)
      call write_lhef_init(ofile,
     &     IDBMUP,EBMUP,PDFGUP,PDFSUP,IDWTUP,NPRUP,
     &     XSECUP,XERRUP,XMAXUP,LPRUP)


      do i=1,maxevt

        call read_lhef_event(ifile,
     &       NUP,IDPRUP,XWGTUP,SCALUP,AQEDUP,AQCDUP,
     &       IDUP,ISTUP,MOTHUP,ICOLUP,PUP,VTIMUP,SPINUP,buff)
        call reweight_fill_extra_inverse()

        if(buff(1:1).ne.'#')then
          write(*,*)'This event file cannot be reweighted [3]',i
          stop
        endif
        read(buff,200)ch1,iSorH_lhe,ifks_lhe,jfks_lhe,
     #                    fksfather_lhe,ipartner_lhe,
     #                    scale1_lhe,scale2_lhe,
     #                    kwgtinfo,kexternal,jwgtnumpartn,
     #         wgtcentral,wgtmumin,wgtmumax,wgtpdfmin,wgtpdfmax
        if(kwgtinfo.lt.1.or.kwgtinfo.gt.4)then
          write(*,*)'This event file cannot be reweighted [4]',i
          write(*,*)kwgtinfo
          stop
        endif
        if(wgtcentral.ne.0.d0.or.wgtmumin.ne.0.d0.or.
     #     wgtmumax.ne.0.d0.or.wgtpdfmin.ne.0.d0.or.
     #     wgtpdfmax.ne.0.d0)then
          write(*,*)'This event file was already reweighted',i
          write(*,*)wgtcentral,wgtmumin,wgtmumax,wgtpdfmin,wgtpdfmax
          stop
        endif

        if(imu.ne.0)then

          wgtmumin=1.d40
          wgtmumax=-1.d40

          do kr=1,3
            do kf=1,3
              pr_muR_over_ref=xmuR_over_ref*yfactR(kr)
              pr_muF1_over_ref=xmuF1_over_ref*yfactF(kf)
              pr_muF2_over_ref=pr_muF1_over_ref
              if(iSorH_lhe.eq.1)then
                wgtxsecmu(kr,kf)=
     #   compute_rwgt_wgt_Sev(pr_muR_over_ref,pr_muF1_over_ref,
     #                        pr_muF2_over_ref,xQES_over_ref,
     #                        kwgtinfo)
              elseif(iSorH_lhe.eq.2)then
                wgtxsecmu(kr,kf)=
     #   compute_rwgt_wgt_Hev(pr_muR_over_ref,pr_muF1_over_ref,
     #                        pr_muF2_over_ref,xQES_over_ref,
     #                        kwgtinfo)
              else
                write(*,*)'Invalid value of iSorH_lhe',iSorH_lhe
                stop
              endif
c
              tmp=wgtxsecmu(kr,kf)
              if(tmp.lt.wgtmumin)wgtmumin=tmp
              if(tmp.gt.wgtmumax)wgtmumax=tmp
            enddo
          enddo

          if(unweighted)then
            wgtcentral=wgtxsecmu(1,1)/wgtref
            wgtmumin=wgtmumin/wgtref
            wgtmumax=wgtmumax/wgtref
          else
            wgtcentral=wgtxsecmu(1,1)
          endif

        endif

        if(ipdf.ne.0)then

          do n=0,nsets
            call InitPDF(n)

            if(iSorH_lhe.eq.1)then
              wgtxsecPDF(n)=
     #   compute_rwgt_wgt_Sev(xmuR_over_ref,xmuF1_over_ref,
     #                        xmuF2_over_ref,xQES_over_ref,
     #                        kwgtinfo)
            elseif(iSorH_lhe.eq.2)then
              wgtxsecPDF(n)=
     #   compute_rwgt_wgt_Hev(xmuR_over_ref,xmuF1_over_ref,
     #                        xmuF2_over_ref,xQES_over_ref,
     #                        kwgtinfo)
            else
              write(*,*)'Invalid value of iSorH_lhe',iSorH_lhe
              stop
            endif
c
            if(unweighted)then
              xsecPDFr(n)=wgtxsecPDF(n)/wgtref
            else
              xsecPDFr(n)=wgtxsecPDF(n)
            endif
          enddo

          if(imu.ne.0)then
            if(abs(xsecPDFr(0)/wgtcentral-1.d0).gt.1.d-6)then
              write(*,*)'Central valued computed with mu and PDF differ'
              write(*,*)xsecPDFr(0),wgtcentral
              stop
            endif
          else
            wgtcentral=xsecPDFr(0)
c The following serves to write on tape the reference cross section
c computed with the new parameters
            wgtxsecmu(1,1)=wgtxsecPDF(0)
          endif

          wgtpdfmin=0.d0
          wgtpdfmax=0.d0

          do n=1,npairs
            nps=2*n-1
            nng=2*n

            wgtpdfmin=wgtpdfmin+
     #                ( max(0.d0,
     #                      xsecPDFr(0)-xsecPDFr(nps),
     #                      xsecPDFr(0)-xsecPDFr(nng)) )**2
            wgtpdfmax=wgtpdfmax+
     #                ( max(0.d0,
     #                      xsecPDFr(nps)-xsecPDFr(0),
     #                      xsecPDFr(nng)-xsecPDFr(0)) )**2
          enddo
          wgtpdfmin=wgtcentral-sqrt(wgtpdfmin)
          wgtpdfmax=wgtcentral+sqrt(wgtpdfmax)

c Restore default PDFs
          call InitPDF(izero)

        endif

        write(buff,200)'#',iSorH_lhe,ifks_lhe,jfks_lhe,
     #                     fksfather_lhe,ipartner_lhe,
     #                     scale1_lhe,scale2_lhe,
     #                     isave,izero,izero,
     #          wgtcentral,wgtmumin,wgtmumax,wgtpdfmin,wgtpdfmax

        call write_lhef_event(ofile,
     &       NUP,IDPRUP,XWGTUP,SCALUP,AQEDUP,AQCDUP,
     &       IDUP,ISTUP,MOTHUP,ICOLUP,PUP,VTIMUP,SPINUP,buff)


      enddo

      write(ofile,'(a)')'</LesHouchesEvents>'
      close(34)
      close(35)

 200  format(1a,1x,i1,4(1x,i2),2(1x,d14.8),1x,i1,2(1x,i2),5(1x,d14.8))


      end



      subroutine set_cms_stuff(icountevts)
      implicit none
      include "run.inc"

      integer icountevts

      double precision ybst_til_tolab,ybst_til_tocm,sqrtshat,shat
      common/parton_cms_stuff/ybst_til_tolab,ybst_til_tocm,
     #                        sqrtshat,shat

      double precision sqrtshat_ev,shat_ev
      common/parton_cms_ev/sqrtshat_ev,shat_ev

      double precision sqrtshat_cnt(-2:2),shat_cnt(-2:2)
      common/parton_cms_cnt/sqrtshat_cnt,shat_cnt

      double precision tau_ev,ycm_ev
      common/cbjrk12_ev/tau_ev,ycm_ev

      double precision tau_cnt(-2:2),ycm_cnt(-2:2)
      common/cbjrk12_cnt/tau_cnt,ycm_cnt

      double precision xbjrk_ev(2),xbjrk_cnt(2,-2:2)
      common/cbjorkenx/xbjrk_ev,xbjrk_cnt

c rapidity of boost from \tilde{k}_1+\tilde{k}_2 c.m. frame to lab frame --
c same for event and counterevents
c This is the rapidity that enters in the arguments of the sinh() and
c cosh() of the boost, in such a way that
c       y(k)_lab = y(k)_tilde - ybst_til_tolab
c where y(k)_lab and y(k)_tilde are the rapidities computed with a generic
c four-momentum k, in the lab frame and in the \tilde{k}_1+\tilde{k}_2 
c c.m. frame respectively
      ybst_til_tolab=-ycm_cnt(0)
      if(icountevts.eq.-100)then
c set Bjorken x's in run.inc for the computation of PDFs in auto_dsig
        xbk(1)=xbjrk_ev(1)
        xbk(2)=xbjrk_ev(2)
c shat=2*k1.k2 -- consistency of this assignment with momenta checked
c in phspncheck_nocms
        shat=shat_ev
        sqrtshat=sqrtshat_ev
c rapidity of boost from \tilde{k}_1+\tilde{k}_2 c.m. frame to 
c k_1+k_2 c.m. frame
        ybst_til_tocm=ycm_ev-ycm_cnt(0)
      else
c do the same as above for the counterevents
        xbk(1)=xbjrk_cnt(1,icountevts)
        xbk(2)=xbjrk_cnt(2,icountevts)
        shat=shat_cnt(icountevts)
        sqrtshat=sqrtshat_cnt(icountevts)
        ybst_til_tocm=ycm_cnt(icountevts)-ycm_cnt(0)
      endif
      return
      end

