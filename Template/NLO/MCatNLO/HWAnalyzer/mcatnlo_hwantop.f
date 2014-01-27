C----------------------------------------------------------------------
      SUBROUTINE RCLOS()
C     DUMMY IF HBOOK IS USED
C----------------------------------------------------------------------
      END


C----------------------------------------------------------------------
      SUBROUTINE HWABEG
C     USER'S ROUTINE FOR INITIALIZATION
C----------------------------------------------------------------------
      REAL*8 pi
      integer j,k
      PARAMETER (PI=3.14159265358979312D0)
      character*5 cc(2)
      data cc/'     ',' cuts'/
c
      call inihist
      do j=1,2
        k=(j-1)*50
        call mbook(k+ 1,'tt pt'//cc(j),2.d0,0.d0,100.d0)
        call mbook(k+ 2,'tt log[pt]'//cc(j),0.05d0,0.1d0,5.d0)
        call mbook(k+ 3,'tt inv m'//cc(j),10.d0,300.d0,1000.d0)
        call mbook(k+ 4,'tt azimt'//cc(j),pi/20.d0,0.d0,pi)
        call mbook(k+ 5,'tt del R'//cc(j),pi/20.d0,0.d0,3*pi)
        call mbook(k+ 6,'tb pt'//cc(j),5.d0,0.d0,500.d0)
        call mbook(k+ 7,'tb log[pt]'//cc(j),0.05d0,0.1d0,5.d0)
        call mbook(k+ 8,'t pt'//cc(j),5.d0,0.d0,500.d0)
        call mbook(k+ 9,'t log[pt]'//cc(j),0.05d0,0.1d0,5.d0)
        call mbook(k+10,'tt delta eta'//cc(j),0.2d0,-4.d0,4.d0)
        call mbook(k+11,'y_tt'//cc(j),0.1d0,-4.d0,4.d0)
        call mbook(k+12,'delta y'//cc(j),0.2d0,-4.d0,4.d0)
        call mbook(k+13,'tt azimt'//cc(j),pi/60.d0,2*pi/3,pi)
        call mbook(k+14,'tt del R'//cc(j),pi/60.d0,2*pi/3,4*pi/3)
        call mbook(k+15,'y_tb'//cc(j),0.1d0,-4.d0,4.d0)
        call mbook(k+16,'y_t'//cc(j),0.1d0,-4.d0,4.d0)
        call mbook(k+17,'tt log[pi-azimt]'//cc(j),0.05d0,-4.d0,0.1d0)
      enddo
      do j=1,2
        k=(j-1)*50
        call mbook(k+18,'tt pt'//cc(j),20.d0,80.d0,2000.d0)
        call mbook(k+19,'tb pt'//cc(j),20.d0,400.d0,2400.d0)
        call mbook(k+20,'t pt'//cc(j),20.d0,400.d0,2400.d0)
      enddo
      END


C----------------------------------------------------------------------
      SUBROUTINE HWAEND
C     USER'S ROUTINE FOR TERMINAL CALCULATIONS, HISTOGRAM OUTPUT, ETC
C----------------------------------------------------------------------
      INCLUDE 'HERWIG65.INC'
      REAL*8 XNORM
      INTEGER I,J,K
      OPEN(UNIT=99,FILE='HERQQ.TOP',STATUS='UNKNOWN')
C XNORM IS SUCH THAT THE CROSS SECTION PER BIN IS IN PB, SINCE THE HERWIG 
C WEIGHT IS IN NB, AND CORRESPONDS TO THE AVERAGE CROSS SECTION
      XNORM=1.D3/DFLOAT(NEVHEP)
      DO I=1,100              
 	CALL MFINAL3(I)             
        CALL MCOPY(I,I+100)
        CALL MOPERA(I+100,'F',I+100,I+100,(XNORM),0.D0)
 	CALL MFINAL3(I+100)             
      ENDDO                          
C
      do j=1,2
        k=(j-1)*50
        call multitop(100+k+ 1,99,2,3,'tt pt',' ','LOG')
        call multitop(100+k+ 2,99,2,3,'tt log[pt]',' ','LOG')
        call multitop(100+k+ 3,99,2,3,'tt inv m',' ','LOG')
        call multitop(100+k+ 4,99,2,3,'tt azimt',' ','LOG')
        call multitop(100+k+ 5,99,2,3,'tt del R',' ','LOG')
        call multitop(100+k+ 6,99,2,3,'tb pt',' ','LOG')
        call multitop(100+k+ 7,99,2,3,'tb log[pt]',' ','LOG')
        call multitop(100+k+ 8,99,2,3,'t pt',' ','LOG')
        call multitop(100+k+ 9,99,2,3,'t log[pt]',' ','LOG')
        call multitop(100+k+10,99,2,3,'tt Delta eta',' ','LOG')
        call multitop(100+k+11,99,2,3,'y_tt',' ','LOG')
        call multitop(100+k+12,99,2,3,'tt Delta y',' ','LOG')
        call multitop(100+k+13,99,2,3,'tt azimt',' ','LOG')
        call multitop(100+k+14,99,2,3,'tt del R',' ','LOG')
        call multitop(100+k+15,99,2,3,'tb y',' ','LOG')
        call multitop(100+k+16,99,2,3,'t y',' ','LOG')
        call multitop(100+k+17,99,2,3,'tt log[pi-azimt]',' ','LOG')
      enddo
      do j=1,2
        k=(j-1)*50
        call multitop(100+k+18,99,2,3,'tt pt',' ','LOG')
        call multitop(100+k+19,99,2,3,'tb pt',' ','LOG')
        call multitop(100+k+20,99,2,3,'t pt',' ','LOG')
      enddo
c
      CLOSE(99)
      END


C----------------------------------------------------------------------
      SUBROUTINE HWANAL
C     USER'S ROUTINE TO ANALYSE DATA FROM EVENT
C----------------------------------------------------------------------
      INCLUDE 'HERWIG65.INC'
      DOUBLE PRECISION HWVDOT,PSUM(4)
      INTEGER ICHSUM,ICHINI,IHEP
      LOGICAL DIDSOF,flcuts,siq1flag,siq2flag,ddflag
      INTEGER ID,ID1,IST,IQ1,IQ2,IT1,IT2,ILP,INU,IBQ,ILM,INB,IBB,IJ
      DOUBLE PRECISION YCUT,PTCUT,ptlp,ylp,getrapidity,ptnu,ynu,
     # ptbq,ybq,ptlm,ylm,ptnb,ynb,ptbb,ybb,ptbqbb,dphibqbb,
     # getdelphi,xmbqbb,getinvm,ptlplm,dphilplm,xmlplm,ptbqlm,
     # dphibqlm,xmbqlm,ptbblp,dphibblp,xmbblp,ptbqnb,dphibqnb,
     # xmbqnb,ptbbnu,dphibbnu,xmbbnu,ptq1,ptq2,ptg,yq1,yq2,
     # etaq1,getpseudorap,etaq2,azi,azinorm,qqm,dr,yqq
      DOUBLE PRECISION XPTQ(5),XPTB(5),XPLP(5),XPNU(5),XPBQ(5),XPLM(5),
     # XPNB(5),XPBB(5)
      DOUBLE PRECISION YPBQBB(4),YPLPLM(4),YPBQLM(4),YPBBLP(4),
     # YPBQNB(4),YPBBNU(4),YPTQTB(4)
      REAL*8 PI
      PARAMETER (PI=3.14159265358979312D0)
      REAL*8 WWW0
      INTEGER KK,IVLEP1,IVLEP2
      COMMON/VVLIN/IVLEP1,IVLEP2
c

      IF (IERROR.NE.0) RETURN
c
C INCOMING PARTONS MAY TRAVEL IN THE SAME DIRECTION: IT'S A POWER-SUPPRESSED
C EFFECT, SO THROW THE EVENT AWAY

      IF(SIGN(1.D0,PHEP(3,4)).EQ.SIGN(1.D0,PHEP(3,5)))THEN
        CALL HWWARN('HWANAL',111)
        GOTO 999
      ENDIF
      WWW0=EVWGT
      CALL HWVSUM(4,PHEP(1,1),PHEP(1,2),PSUM)
      CALL HWVSCA(4,-1D0,PSUM,PSUM)
      ICHSUM=0
      ICHINI=ICHRG(IDHW(1))+ICHRG(IDHW(2))
      DIDSOF=.FALSE.
      IQ1=0
      IQ2=0
      DO 100 IHEP=1,NHEP
C UNCOMMENT THE FOLLOWING WHEN REMOVING THE CHECK ON MOMENTUM 
C        IF(IQ1*IQ2.EQ.1) GOTO 11
        IF (IDHW(IHEP).EQ.16) DIDSOF=.TRUE.
        IF (ISTHEP(IHEP).EQ.1) THEN
          CALL HWVSUM(4,PHEP(1,IHEP),PSUM,PSUM)
          ICHSUM=ICHSUM+ICHRG(IDHW(IHEP))
        ENDIF
        IST=ISTHEP(IHEP)      
        ID=IDHW(IHEP)
        ID1=IDHEP(IHEP)
        IF(IST.EQ.155.AND.ID1.EQ.6)THEN
C FOUND A TOP; KEEP ONLY THE FIRST ON RECORD
          IQ1=IQ1+1
          IF(IQ1.EQ.1)IT1=IHEP
        ELSEIF(IST.EQ.155.AND.ID1.EQ.-6)THEN
C FOUND AN ANTITOP; KEEP ONLY THE FIRST ON RECORD
          IQ2=IQ2+1
          IF(IQ2.EQ.1)IT2=IHEP
        ENDIF
  100 CONTINUE
      IF(IQ1*IQ2.EQ.0.AND.IERROR.EQ.0)CALL HWWARN('HWANAL',501)
C CHECK MOMENTUM AND CHARGE CONSERVATION
      IF (HWVDOT(3,PSUM,PSUM).GT.1.E-4*PHEP(4,1)**2) THEN
         CALL HWUEPR
         CALL HWWARN('HWANAL',112)
         GOTO 999
      ENDIF
      IF (ICHSUM.NE.ICHINI) THEN
         CALL HWUEPR
         CALL HWWARN('HWANAL',113)
         GOTO 999
      ENDIF
C FILL THE FOUR-MOMENTA
      DO IJ=1,5
         XPTQ(IJ)=PHEP(IJ,IT1)
         XPTB(IJ)=PHEP(IJ,IT2)
      ENDDO
      DO IJ=1,4
         YPTQTB(IJ)=XPTQ(IJ)+XPTB(IJ)
      ENDDO
C FILL THE HISTOS
      YCUT=2.5D0
      PTCUT=30.D0
C
      ptq1 = dsqrt(xptq(1)**2+xptq(2)**2)
      ptq2 = dsqrt(xptb(1)**2+xptb(2)**2)
      ptg = dsqrt(yptqtb(1)**2+yptqtb(2)**2)
      yq1=getrapidity(xptq(4),xptq(3))
      yq2=getrapidity(xptb(4),xptb(3))
      etaq1=getpseudorap(xptq(4),xptq(1),xptq(2),xptq(3))
      etaq2=getpseudorap(xptb(4),xptb(1),xptb(2),xptb(3))
      azi=getdelphi(xptq(1),xptq(2),xptb(1),xptb(2))
      azinorm = (pi-azi)/pi
      qqm=getinvm(yptqtb(4),yptqtb(1),yptqtb(2),yptqtb(3))
      dr  = dsqrt(azi**2+(etaq1-etaq2)**2)
      yqq=getrapidity(yptqtb(4),yptqtb(3))
c-------------------------------------------------------------
      siq1flag=ptq1.gt.ptcut.and.abs(yq1).lt.ycut
      siq2flag=ptq2.gt.ptcut.and.abs(yq2).lt.ycut
      ddflag=siq1flag.and.siq2flag
c-------------------------------------------------------------
      call mfill(1,(ptg),(WWW0))
      call mfill(18,(ptg),(WWW0))
      if(ptg.gt.0) call mfill(2,(log10(ptg)),(WWW0))
      call mfill(3,(qqm),(WWW0))
      call mfill(4,(azi),(WWW0))
      call mfill(13,(azi),(WWW0))
      if(azinorm.gt.0)call mfill(17,(log10(azinorm)),(WWW0))
      call mfill(5,(dr),(WWW0))
      call mfill(14,(dr),(WWW0))
      call mfill(10,(etaq1-etaq2),(WWW0))
      call mfill(11,(yqq),(WWW0))
      call mfill(12,(yq1-yq2),(WWW0))
      call mfill(6,(ptq2),(WWW0))
      call mfill(19,(ptq2),(WWW0))
      if(ptq2.gt.0) call mfill(7,(log10(ptq2)),(WWW0))
      call mfill(15,(yq2),(WWW0))
      call mfill(8,(ptq1),(WWW0))
      call mfill(20,(ptq1),(WWW0))
      if(ptq1.gt.0) call mfill(9,(log10(ptq1)),(WWW0))
      call mfill(16,(yq1),(WWW0))
c
c***************************************************** with cuts
c
      kk=50
      if(ddflag)then
        call mfill(kk+1,(ptg),(WWW0))
        call mfill(kk+18,(ptg),(WWW0))
        if(ptg.gt.0) call mfill(kk+2,(log10(ptg)),(WWW0))
        call mfill(kk+3,(qqm),(WWW0))
        call mfill(kk+4,(azi),(WWW0))
        call mfill(kk+13,(azi),(WWW0))
        if(azinorm.gt.0) 
     #    call mfill(kk+17,(log10(azinorm)),(WWW0))
        call mfill(kk+5,(dr),(WWW0))
        call mfill(kk+14,(dr),(WWW0))
        call mfill(kk+10,(etaq1-etaq2),(WWW0))
        call mfill(kk+11,(yqq),(WWW0))
        call mfill(kk+12,(yq1-yq2),(WWW0))
      endif
      if(abs(yq2).lt.ycut)then
        call mfill(kk+6,(ptq2),(WWW0))
        call mfill(kk+19,(ptq2),(WWW0))
        if(ptq2.gt.0) call mfill(kk+7,(log10(ptq2)),(WWW0))
      endif
      if(ptq2.gt.ptcut)call mfill(kk+15,(yq2),(WWW0))
      if(abs(yq1).lt.ycut)then
        call mfill(kk+8,(ptq1),(WWW0))
        call mfill(kk+20,(ptq1),(WWW0))
        if(ptq1.gt.0) call mfill(kk+9,(log10(ptq1)),(WWW0))
      endif
      if(ptq1.gt.ptcut)call mfill(kk+16,(yq1),(WWW0))

 999  return
      end


      function getrapidity(en,pl)
      implicit none
      real*8 getrapidity,en,pl,tiny,xplus,xminus,y
      parameter (tiny=1.d-8)
c
      xplus=en+pl
      xminus=en-pl
      if(xplus.gt.tiny.and.xminus.gt.tiny)then
        if( (xplus/xminus).gt.tiny )then
          y=0.5d0*log( xplus/xminus )
        else
          y=sign(1.d0,pl)*1.d8
        endif
      else
        y=sign(1.d0,pl)*1.d8
      endif
      getrapidity=y
      return
      end


      function getpseudorap(en,ptx,pty,pl)
      implicit none
      real*8 getpseudorap,en,ptx,pty,pl,tiny,pt,eta,th
      parameter (tiny=1.d-5)
c
      pt=sqrt(ptx**2+pty**2)
      if(pt.lt.tiny.and.abs(pl).lt.tiny)then
        eta=sign(1.d0,pl)*1.d8
      else
        th=atan2(pt,pl)
        eta=-log(tan(th/2.d0))
      endif
      getpseudorap=eta
      return
      end


      function getinvm(en,ptx,pty,pl)
      implicit none
      real*8 getinvm,en,ptx,pty,pl,tiny,tmp
      parameter (tiny=1.d-5)
c
      tmp=en**2-ptx**2-pty**2-pl**2
      if(tmp.gt.0.d0)then
        tmp=sqrt(tmp)
      elseif(tmp.gt.-tiny)then
        tmp=0.d0
      else
        write(*,*)'Attempt to compute a negative mass'
        stop
      endif
      getinvm=tmp
      return
      end


      function getdelphi(ptx1,pty1,ptx2,pty2)
      implicit none
      real*8 getdelphi,ptx1,pty1,ptx2,pty2,tiny,pt1,pt2,tmp
      parameter (tiny=1.d-5)
c
      pt1=sqrt(ptx1**2+pty1**2)
      pt2=sqrt(ptx2**2+pty2**2)
      if(pt1.ne.0.d0.and.pt2.ne.0.d0)then
        tmp=ptx1*ptx2+pty1*pty2
        tmp=tmp/(pt1*pt2)
        if(abs(tmp).gt.1.d0+tiny)then
          write(*,*)'Cosine larger than 1'
          stop
        elseif(abs(tmp).ge.1.d0)then
          tmp=sign(1.d0,tmp)
        endif
        tmp=acos(tmp)
      else
        tmp=1.d8
      endif
      getdelphi=tmp
      return
      end