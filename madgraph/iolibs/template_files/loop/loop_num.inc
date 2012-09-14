C THE CORE SUBROUTINE CALLED BY CUTTOOLS WHICH CONTAINS THE HELAS CALLS BUILDING THE LOOP

      SUBROUTINE LOOPNUM(Q,RES)
C  
C CONSTANTS 
C 
	  INTEGER    NCOMB
      PARAMETER (NCOMB=%(ncomb)d)
	  INTEGER    NEXTERNAL
      PARAMETER (NEXTERNAL=%(nexternal)d)
	  %(nbornamps_decl)s
      INTEGER    NLOOPAMPS
      PARAMETER (NLOOPAMPS=%(nloopamps)d)
	  INTEGER    NWAVEFUNCS
      PARAMETER (NWAVEFUNCS=%(nwavefuncs)d)
	  INTEGER    MAXLCOUPLINGS
      PARAMETER (MAXLCOUPLINGS=%(maxlcouplings)d)
	  %(complex_dp_format)s IMAG1
      PARAMETER (IMAG1=(0D0,1D0))
C  
C ARGUMENTS 
C  
      %(complex_dp_format)s Q(0:3)
      %(complex_dp_format)s RES
C  
C LOCAL VARIABLES 
C
      %(complex_dp_format)s CFTOT
      %(complex_dp_format)s BUFF
      INTEGER I,H
C
C GLOBAL VARIABLES
C
      INTEGER WE(NEXTERNAL)	  
      INTEGER ID, SYMFACT,AMPLNUM
      COMMON/LOOP/WE,ID,SYMFACT,AMPLNUM

	  LOGICAL GOODHEL(NCOMB)
	  LOGICAL GOODAMP(NLOOPAMPS,NCOMB)
	  common/Filters/GOODAMP,GOODHEL

	  INTEGER NTRY
	  LOGICAL CHECKPHASE,HELDOUBLECHECKED
	  %(real_dp_format)s REF
      common/INIT/NTRY,CHECKPHASE,HELDOUBLECHECKED,REF

	  INTEGER CF_D(NLOOPAMPS,%(color_matrix_size)s)
	  INTEGER CF_N(NLOOPAMPS,%(color_matrix_size)s)
	  common/CF/CF_D,CF_N

	  %(dp_born_amps_decl)s
	  %(complex_dp_format)s W(20,NWAVEFUNCS%(ncomb_helas_objs)s)
	  common/WFCTS/W  

	  INTEGER HELPICKED
	  common/HELCHOICE/HELPICKED

	  RES=(0.0d0,0.0d0)

  DO H=1,NCOMB
  IF (((HELPICKED.EQ.-1).OR.(HELPICKED.EQ.H)).AND.((CHECKPHASE.OR..NOT.HELDOUBLECHECKED).OR.(GOODHEL(H).AND.GOODAMP(AMPLNUM,H)))) THEN
    CALL LOOPNUMHEL(-Q,BUFF,H)
	%(dp_squaring)s
  ENDIF
  ENDDO
	  RES=RES/SYMFACT

	  END

      SUBROUTINE LOOPNUMHEL(Q,RES,H)
C  
C CONSTANTS 
C  
      INTEGER    NEXTERNAL
      PARAMETER (NEXTERNAL=%(nexternal)d)
	  INTEGER    MAXLCOUPLINGS
      PARAMETER (MAXLCOUPLINGS=%(maxlcouplings)d)
	  INTEGER    NMAXLOOPWFS
      PARAMETER (NMAXLOOPWFS=(NEXTERNAL+2))
	  %(real_dp_format)s     ZERO
	  PARAMETER (ZERO=0.D0)
	  INTEGER    NWAVEFUNCS
      PARAMETER (NWAVEFUNCS=%(nwavefuncs)d)
	  %(nbornamps_decl)s
      INTEGER    NLOOPAMPS
      PARAMETER (NLOOPAMPS=%(nloopamps)d)
	  INTEGER    NCOMB
      PARAMETER (NCOMB=%(ncomb)d)
C  
C ARGUMENTS 
C  
      %(complex_dp_format)s Q(0:3)
      %(complex_dp_format)s RES
	  INTEGER H
C  
C LOCAL VARIABLES 
C
      %(complex_dp_format)s BUFF(4)
      %(complex_dp_format)s WL(20,NMAXLOOPWFS)
      INTEGER I
C
C GLOBAL VARIABLES
C
	  %(complex_dp_format)s LC(MAXLCOUPLINGS)
	  %(mass_dp_format)s ML(NEXTERNAL+2)
      COMMON/DP_LOOP/LC,ML

      INTEGER WE(NEXTERNAL)  
      INTEGER ID, SYMFACT,AMPLNUM
      COMMON/LOOP/WE,ID,SYMFACT,AMPLNUM

	  %(dp_born_amps_decl)s	  
	  %(complex_dp_format)s W(20,NWAVEFUNCS%(ncomb_helas_objs)s)
	  common/WFCTS/W  

C ----------
C BEGIN CODE
C ----------
      RES=(0.D0,0.D0)
      %(loop_helas_calls)s
      END

      SUBROUTINE MPLOOPNUM(Q,RES)
	  
      INCLUDE 'cts_mprec.h'
	  IMPLICIT NONE	  
C  
C CONSTANTS 
C 
	  INTEGER    NCOMB
      PARAMETER (NCOMB=%(ncomb)d)
	  INTEGER    NEXTERNAL
      PARAMETER (NEXTERNAL=%(nexternal)d)
	  %(nbornamps_decl)s	  
      INTEGER    NLOOPAMPS
      PARAMETER (NLOOPAMPS=%(nloopamps)d)
	  INTEGER    NWAVEFUNCS
      PARAMETER (NWAVEFUNCS=%(nwavefuncs)d)
	  INTEGER    MAXLCOUPLINGS
      PARAMETER (MAXLCOUPLINGS=%(maxlcouplings)d)
	  %(complex_mp_format)s IMAG1
      PARAMETER (IMAG1=(0E0_16,1E0_16))
C  
C ARGUMENTS 
C  
      INCLUDE 'cts_mpc.h'                                             , INTENT(IN), DIMENSION(0:3) :: Q
      INCLUDE 'cts_mpc.h'                                             , INTENT(OUT) :: RES
C  
C LOCAL VARIABLES 
C
      %(complex_mp_format)s QPRES
      %(complex_mp_format)s QPQ(0:3)
      %(real_mp_format)s QPP(0:3,NEXTERNAL)
      INTEGER I,J,H
	  %(complex_mp_format)s CFTOT
      %(complex_mp_format)s BUFF
C  
C GLOBAL VARIABLES
C 
	  LOGICAL MP_DONE
	  common/MP_DONE/MP_DONE

	  %(real_dp_format)s PS(0:3,NEXTERNAL)
	  common/PSPOINT/PS

      INTEGER WE(NEXTERNAL)  
      INTEGER ID, SYMFACT,AMPLNUM
      COMMON/LOOP/WE,ID,SYMFACT,AMPLNUM

	  LOGICAL GOODHEL(NCOMB)
	  LOGICAL GOODAMP(NLOOPAMPS,NCOMB)
	  common/Filters/GOODAMP,GOODHEL

	  INTEGER NTRY
	  LOGICAL CHECKPHASE,HELDOUBLECHECKED
	  %(real_dp_format)s REF
      common/INIT/NTRY,CHECKPHASE,HELDOUBLECHECKED,REF

	  INTEGER CF_D(NLOOPAMPS,%(color_matrix_size)s)
	  INTEGER CF_N(NLOOPAMPS,%(color_matrix_size)s)
	  common/CF/CF_D,CF_N

	  %(mp_born_amps_decl)s	  
	  %(complex_mp_format)s W(20,NWAVEFUNCS%(ncomb_helas_objs)s)
	  common/MP_WFS/W	

	  INTEGER HELPICKED
	  common/HELCHOICE/HELPICKED
C ----------
C BEGIN CODE
C ----------
      DO I=0,3
        QPQ(I) = Q(I)
      ENDDO
	  QPRES=(0.0E0_16,0.0E0_16)	  

      IF(.NOT.MP_DONE) THEN
	    DO I=1,NEXTERNAL
		  DO J=0,3
		    QPP(J,I)=PS(J,I)
		  ENDDO
		ENDDO
		CALL MP_UPDATE_AS_PARAM()
		CALL MP_IMPROVE_PS_POINT_PRECISION(QPP)
	    CALL MP_BORN_AMPS_AND_WFS(QPP)
	    MP_DONE=.TRUE.
	  ENDIF

  DO H=1,NCOMB
  IF (((HELPICKED.EQ.-1).OR.(HELPICKED.EQ.H)).AND.((CHECKPHASE.OR..NOT.HELDOUBLECHECKED).OR.(GOODHEL(H).AND.GOODAMP(AMPLNUM,H)))) THEN
    CALL MPLOOPNUMHEL(-QPQ,BUFF,H)
	%(mp_squaring)s
  ENDIF
  ENDDO
	  QPRES=QPRES/SYMFACT

	  RES=QPRES
      END

	  SUBROUTINE MP_IMPROVE_PS_POINT_PRECISION(P)
C  
C CONSTANTS 
C 
	  INTEGER    NEXTERNAL
      PARAMETER (NEXTERNAL=%(nexternal)d)
	  %(real_mp_format)s     ZERO
	  PARAMETER (ZERO=0E0_16)
C  
C ARGUMENTS 
C
      %(real_mp_format)s P(0:3,NEXTERNAL)
C
C LOCAL VARIABLES 
C
      INTEGER I,J
	  %(real_mp_format)s BUFF,REF
	  %(real_dp_format)s MASSES(NEXTERNAL-1)	  
C  
C GLOBAL VARIABLES
C 
      include 'mp_coupl_same_name.inc'

	  %(masses_def)s

	  DO I=0,3
	    REF=ZERO
		BUFF=ZERO
		DO J=1,NEXTERNAL
		  REF=REF+ABS(P(I,J))
		ENDDO
        DO J=1,%(n_initial)d		
		  BUFF=BUFF-P(I,J)
		ENDDO
        DO J=%(n_initial)d+1,NEXTERNAL	
		  BUFF=BUFF+P(I,J)
		ENDDO
		IF ((BUFF/REF).GT.1.0E-9_16) THEN
		  STOP 'Four-momentum conservation is not accurate enough.'		  
		ENDIF
	  ENDDO

	  DO I=1,NEXTERNAL-1
	    REF=ABS(P(0,I))+ABS(P(1,I))+ABS(P(2,I))+ABS(P(3,I))
		IF ((SQRT(ABS(P(0,I)**2-P(1,I)**2-P(2,I)**2-P(3,I)**2-MASSES(I)**2))/REF).GT.1.0E-4_16) THEN
		  STOP 'Four-momentum conservation is not accurate enough.'
		ELSE
	      P(3,I)=SIGN(SQRT(ABS(P(0,I)**2-P(1,I)**2-P(2,I)**2-MASSES(I)**2)),P(3,I))
		ENDIF
	  ENDDO

	  DO I=0,3
	    BUFF=0.0E0_16 
        DO J=1,%(n_initial)d
		  BUFF=BUFF+P(I,J)
		ENDDO
		DO J=%(n_initial)d+1,NEXTERNAL-1
		  BUFF=BUFF-P(I,J)		
		ENDDO
		P(I,NEXTERNAL)=BUFF
	  ENDDO

	  END

      SUBROUTINE MPLOOPNUMHEL(Q,RES,H)
C  
C CONSTANTS 
C  
      INTEGER    NEXTERNAL
      PARAMETER (NEXTERNAL=%(nexternal)d)
	  INTEGER    MAXLCOUPLINGS
      PARAMETER (MAXLCOUPLINGS=%(maxlcouplings)d)
	  INTEGER    NMAXLOOPWFS
      PARAMETER (NMAXLOOPWFS=(NEXTERNAL+2))
	  %(real_mp_format)s     ZERO
	  PARAMETER (ZERO=0E0_16)
	  INTEGER    NWAVEFUNCS
      PARAMETER (NWAVEFUNCS=%(nwavefuncs)d)
	  %(nbornamps_decl)s	  
      INTEGER    NLOOPAMPS
      PARAMETER (NLOOPAMPS=%(nloopamps)d)
	  INTEGER    NCOMB
      PARAMETER (NCOMB=%(ncomb)d)
C  
C ARGUMENTS 
C  
      %(complex_mp_format)s Q(0:3)
      %(complex_mp_format)s RES
	  INTEGER H
C  
C LOCAL VARIABLES 
C
      %(complex_mp_format)s BUFF(4)
      %(complex_mp_format)s WL(20,NMAXLOOPWFS)
      INTEGER I
C
C GLOBAL VARIABLES
C
	  %(complex_mp_format)s LC(MAXLCOUPLINGS)
	  %(mass_mp_format)s ML(NEXTERNAL+2)
      COMMON/MP_LOOP/LC,ML

      INTEGER WE(NEXTERNAL)
      INTEGER ID, SYMFACT,AMPLNUM
      COMMON/LOOP/WE,ID,SYMFACT,AMPLNUM

	  %(mp_born_amps_decl)s	  
	  %(complex_mp_format)s W(20,NWAVEFUNCS%(ncomb_helas_objs)s)
	  common/MP_WFS/W
C ----------
C BEGIN CODE
C ----------
      RES=(0E0_16,0E0_16)
      %(mp_loop_helas_calls)s
      END

      SUBROUTINE MPLOOPNUM_DUMMY(Q,RES)
C  
C ARGUMENTS 
C  
      INCLUDE 'cts_mprec.h'
      INCLUDE 'cts_mpc.h'                                             , INTENT(IN), DIMENSION(0:3) :: Q
      INCLUDE 'cts_mpc.h'                                             , INTENT(OUT) :: RES
C  
C LOCAL VARIABLES 
C
      COMPLEX*16 DRES
      COMPLEX*16 DQ(0:3)
      INTEGER I
C ----------
C BEGIN CODE
C ----------
      DO I=0,3
        DQ(I) = Q(I)
      ENDDO

      CALL LOOPNUM(DQ,DRES)
      RES=DRES

      END