      SUBROUTINE RODAS(N,FCN,IFCN,X,Y,XEND,H,
     &                  RTOL,ATOL,ITOL,
     &                  JAC ,IJAC,MLJAC,MUJAC,DFX,IDFX,
     &                  MAS ,IMAS,MLMAS,MUMAS,
     &                  SOLOUT,IOUT,
     &                  WORK,LWORK,IWORK,LIWORK,RPAR,IPAR,IDID)
C ----------------------------------------------------------
C     NUMERICAL SOLUTION OF A STIFF (OR DIFFERENTIAL ALGEBRAIC)
C     SYSTEM OF FIRST 0RDER ORDINARY DIFFERENTIAL EQUATIONS  MY'=F(X,Y).
C     THIS IS AN EMBEDDED ROSENBROCK METHOD OF ORDER (3)4
C     (WITH STEP SIZE CONTROL).
C     C.F. SECTIONS IV.7  AND VI.3
C
C     AUTHORS: E. HAIRER AND G. WANNER
C              UNIVERSITE DE GENEVE, DEPT. DE MATHEMATIQUES
C              CH-1211 GENEVE 24, SWITZERLAND
C              E-MAIL:  Ernst.Hairer@math.unige.ch
C                       Gerhard.Wanner@math.unige.ch
C
C     THIS CODE IS PART OF THE BOOK:
C         E. HAIRER AND G. WANNER, SOLVING ORDINARY DIFFERENTIAL
C         EQUATIONS II. STIFF AND DIFFERENTIAL-ALGEBRAIC PROBLEMS.
C         SPRINGER SERIES IN COMPUTATIONAL MATHEMATICS 14,
C         SPRINGER-VERLAG 1991, SECOND EDITION 1996.
C
C     VERSION OF OCTOBER 28, 1996
C
C     INPUT PARAMETERS
C     ----------------
C     N           DIMENSION OF THE SYSTEM
C
C     FCN         NAME (EXTERNAL) OF SUBROUTINE COMPUTING THE
C                 VALUE OF F(X,Y):
C                    SUBROUTINE FCN(N,X,Y,F,RPAR,IPAR)
C                    DOUBLE PRECISION X,Y(N),F(N)
C                    F(1)=...   ETC.
C                 RPAR, IPAR (SEE BELOW)
C
C     IFCN        GIVES INFORMATION ON FCN:
C                    IFCN=0: F(X,Y) INDEPENDENT OF X (AUTONOMOUS)
C                    IFCN=1: F(X,Y) MAY DEPEND ON X (NON-AUTONOMOUS)
C
C     X           INITIAL X-VALUE
C
C     Y(N)        INITIAL VALUES FOR Y
C
C     XEND        FINAL X-VALUE (XEND-X MAY BE POSITIVE OR NEGATIVE)
C
C     H           INITIAL STEP SIZE GUESS;
C                 FOR STIFF EQUATIONS WITH INITIAL TRANSIENT,
C                 H=1.D0/(NORM OF F'), USUALLY 1.D-2 OR 1.D-3, IS GOOD.
C                 THIS CHOICE IS NOT VERY IMPORTANT, THE CODE QUICKLY
C                 ADAPTS ITS STEP SIZE (IF H=0.D0, THE CODE PUTS H=1.D-6).
C
C     RTOL,ATOL   RELATIVE AND ABSOLUTE ERROR TOLERANCES. THEY
C                 CAN BE BOTH SCALARS OR ELSE BOTH VECTORS OF LENGTH N.
C
C     ITOL        SWITCH FOR RTOL AND ATOL:
C                   ITOL=0: BOTH RTOL AND ATOL ARE SCALARS.
C                     THE CODE KEEPS, ROUGHLY, THE LOCAL ERROR OF
C                     Y(I) BELOW RTOL*ABS(Y(I))+ATOL
C                   ITOL=1: BOTH RTOL AND ATOL ARE VECTORS.
C                     THE CODE KEEPS THE LOCAL ERROR OF Y(I) BELOW
C                     RTOL(I)*ABS(Y(I))+ATOL(I).
C
C     JAC         NAME (EXTERNAL) OF THE SUBROUTINE WHICH COMPUTES
C                 THE PARTIAL DERIVATIVES OF F(X,Y) WITH RESPECT TO Y
C                 (THIS ROUTINE IS ONLY CALLED IF IJAC=1; SUPPLY
C                 A DUMMY SUBROUTINE IN THE CASE IJAC=0).
C                 FOR IJAC=1, THIS SUBROUTINE MUST HAVE THE FORM
C                    SUBROUTINE JAC(N,X,Y,DFY,LDFY,RPAR,IPAR)
C                    DOUBLE PRECISION X,Y(N),DFY(LDFY,N)
C                    DFY(1,1)= ...
C                 LDFY, THE COLOMN-LENGTH OF THE ARRAY, IS
C                 FURNISHED BY THE CALLING PROGRAM.
C                 IF (MLJAC.EQ.N) THE JACOBIAN IS SUPPOSED TO
C                    BE FULL AND THE PARTIAL DERIVATIVES ARE
C                    STORED IN DFY AS
C                       DFY(I,J) = PARTIAL F(I) / PARTIAL Y(J)
C                 ELSE, THE JACOBIAN IS TAKEN AS BANDED AND
C                    THE PARTIAL DERIVATIVES ARE STORED
C                    DIAGONAL-WISE AS
C                       DFY(I-J+MUJAC+1,J) = PARTIAL F(I) / PARTIAL Y(J).
C
C     IJAC        SWITCH FOR THE COMPUTATION OF THE JACOBIAN:
C                    IJAC=0: JACOBIAN IS COMPUTED INTERNALLY BY FINITE
C                       DIFFERENCES, SUBROUTINE "JAC" IS NEVER CALLED.
C                    IJAC=1: JACOBIAN IS SUPPLIED BY SUBROUTINE JAC.
C
C     MLJAC       SWITCH FOR THE BANDED STRUCTURE OF THE JACOBIAN:
C                    MLJAC=N: JACOBIAN IS A FULL MATRIX. THE LINEAR
C                       ALGEBRA IS DONE BY FULL-MATRIX GAUSS-ELIMINATION.
C                    0<=MLJAC<N: MLJAC IS THE LOWER BANDWITH OF JACOBIAN
C                       MATRIX (>= NUMBER OF NON-ZERO DIAGONALS BELOW
C                       THE MAIN DIAGONAL).
C
C     MUJAC       UPPER BANDWITH OF JACOBIAN  MATRIX (>= NUMBER OF NON-
C                 ZERO DIAGONALS ABOVE THE MAIN DIAGONAL).
C                 NEED NOT BE DEFINED IF MLJAC=N.
C
C     DFX         NAME (EXTERNAL) OF THE SUBROUTINE WHICH COMPUTES
C                 THE PARTIAL DERIVATIVES OF F(X,Y) WITH RESPECT TO X
C                 (THIS ROUTINE IS ONLY CALLED IF IDFX=1 AND IFCN=1;
C                 SUPPLY A DUMMY SUBROUTINE IN THE CASE IDFX=0 OR IFCN=0).
C                 OTHERWISE, THIS SUBROUTINE MUST HAVE THE FORM
C                    SUBROUTINE DFX(N,X,Y,FX,RPAR,IPAR)
C                    DOUBLE PRECISION X,Y(N),FX(N)
C                    FX(1)= ...
C
C     IDFX        SWITCH FOR THE COMPUTATION OF THE DF/DX:
C                    IDFX=0: DF/DX IS COMPUTED INTERNALLY BY FINITE
C                       DIFFERENCES, SUBROUTINE "DFX" IS NEVER CALLED.
C                    IDFX=1: DF/DX IS SUPPLIED BY SUBROUTINE DFX.
C
C     ----   MAS,IMAS,MLMAS, AND MUMAS HAVE ANALOG MEANINGS      -----
C     ----   FOR THE "MASS MATRIX" (THE MATRIX "M" OF SECTION IV.8): -
C
C     MAS         NAME (EXTERNAL) OF SUBROUTINE COMPUTING THE MASS-
C                 MATRIX M.
C                 IF IMAS=0, THIS MATRIX IS ASSUMED TO BE THE IDENTITY
C                 MATRIX AND NEEDS NOT TO BE DEFINED;
C                 SUPPLY A DUMMY SUBROUTINE IN THIS CASE.
C                 IF IMAS=1, THE SUBROUTINE MAS IS OF THE FORM
C                    SUBROUTINE MAS(N,AM,LMAS,RPAR,IPAR)
C                    DOUBLE PRECISION AM(LMAS,N)
C                    AM(1,1)= ....
C                    IF (MLMAS.EQ.N) THE MASS-MATRIX IS STORED
C                    AS FULL MATRIX LIKE
C                         AM(I,J) = M(I,J)
C                    ELSE, THE MATRIX IS TAKEN AS BANDED AND STORED
C                    DIAGONAL-WISE AS
C                         AM(I-J+MUMAS+1,J) = M(I,J).
C
C     IMAS       GIVES INFORMATION ON THE MASS-MATRIX:
C                    IMAS=0: M IS SUPPOSED TO BE THE IDENTITY
C                       MATRIX, MAS IS NEVER CALLED.
C                    IMAS=1: MASS-MATRIX  IS SUPPLIED.
C
C     MLMAS       SWITCH FOR THE BANDED STRUCTURE OF THE MASS-MATRIX:
C                    MLMAS=N: THE FULL MATRIX CASE. THE LINEAR
C                       ALGEBRA IS DONE BY FULL-MATRIX GAUSS-ELIMINATION.
C                    0<=MLMAS<N: MLMAS IS THE LOWER BANDWITH OF THE
C                       MATRIX (>= NUMBER OF NON-ZERO DIAGONALS BELOW
C                       THE MAIN DIAGONAL).
C                 MLMAS IS SUPPOSED TO BE .LE. MLJAC.
C
C     MUMAS       UPPER BANDWITH OF MASS-MATRIX (>= NUMBER OF NON-
C                 ZERO DIAGONALS ABOVE THE MAIN DIAGONAL).
C                 NEED NOT BE DEFINED IF MLMAS=N.
C                 MUMAS IS SUPPOSED TO BE .LE. MUJAC.
C
C     SOLOUT      NAME (EXTERNAL) OF SUBROUTINE PROVIDING THE
C                 NUMERICAL SOLUTION DURING INTEGRATION.
C                 IF IOUT=1, IT IS CALLED AFTER EVERY SUCCESSFUL STEP.
C                 SUPPLY A DUMMY SUBROUTINE IF IOUT=0.
C                 IT MUST HAVE THE FORM
C                    SUBROUTINE SOLOUT (NR,XOLD,X,Y,CONT,LRC,N,
C                                       RPAR,IPAR,IRTRN)
C                    DOUBLE PRECISION X,Y(N),CONT(LRC)
C                    ....
C                 SOLOUT FURNISHES THE SOLUTION "Y" AT THE NR-TH
C                    GRID-POINT "X" (THEREBY THE INITIAL VALUE IS
C                    THE FIRST GRID-POINT).
C                 "XOLD" IS THE PRECEEDING GRID-POINT.
C                 "IRTRN" SERVES TO INTERRUPT THE INTEGRATION. IF IRTRN
C                    IS SET <0, RODAS RETURNS TO THE CALLING PROGRAM.
C
C          -----  CONTINUOUS OUTPUT: -----
C                 DURING CALLS TO "SOLOUT", A CONTINUOUS SOLUTION
C                 FOR THE INTERVAL [XOLD,X] IS AVAILABLE THROUGH
C                 THE FUNCTION
C                        >>>   CONTRO(I,S,CONT,LRC)   <<<
C                 WHICH PROVIDES AN APPROXIMATION TO THE I-TH
C                 COMPONENT OF THE SOLUTION AT THE POINT S. THE VALUE
C                 S SHOULD LIE IN THE INTERVAL [XOLD,X].
C
C     IOUT        GIVES INFORMATION ON THE SUBROUTINE SOLOUT:
C                    IOUT=0: SUBROUTINE IS NEVER CALLED
C                    IOUT=1: SUBROUTINE IS USED FOR OUTPUT
C
C     WORK        ARRAY OF WORKING SPACE OF LENGTH "LWORK".
C                 SERVES AS WORKING SPACE FOR ALL VECTORS AND MATRICES.
C                 "LWORK" MUST BE AT LEAST
C                             N*(LJAC+LMAS+LE1+14)+20
C                 WHERE
C                    LJAC=N              IF MLJAC=N (FULL JACOBIAN)
C                    LJAC=MLJAC+MUJAC+1  IF MLJAC<N (BANDED JAC.)
C                 AND
C                    LMAS=0              IF IMAS=0
C                    LMAS=N              IF IMAS=1 AND MLMAS=N (FULL)
C                    LMAS=MLMAS+MUMAS+1  IF MLMAS<N (BANDED MASS-M.)
C                 AND
C                    LE1=N               IF MLJAC=N (FULL JACOBIAN)
C                    LE1=2*MLJAC+MUJAC+1 IF MLJAC<N (BANDED JAC.).
C                 IN THE USUAL CASE WHERE THE JACOBIAN IS FULL AND THE
C                 MASS-MATRIX IS THE INDENTITY (IMAS=0), THE MINIMUM
C                 STORAGE REQUIREMENT IS
C                             LWORK = 2*N*N+14*N+20.
C                 IF IWORK(9)=M1>0 THEN "LWORK" MUST BE AT LEAST
C                          N*(LJAC+14)+(N-M1)*(LMAS+LE1)+20
C                 WHERE IN THE DEFINITIONS OF LJAC, LMAS AND LE1 THE
C                 NUMBER N CAN BE REPLACED BY N-M1.
C
C     LWORK       DECLARED LENGTH OF ARRAY "WORK".
C
C     IWORK       INTEGER WORKING SPACE OF LENGTH "LIWORK".
C                 "LIWORK" MUST BE AT LEAST N+20.
C
C     LIWORK      DECLARED LENGTH OF ARRAY "IWORK".
C
C     RPAR, IPAR  REAL AND INTEGER PARAMETERS (OR PARAMETER ARRAYS) WHICH
C                 CAN BE USED FOR COMMUNICATION BETWEEN YOUR CALLING
C                 PROGRAM AND THE FCN, DFX, JAC, MAS, SOLOUT SUBROUTINES.
C
C ----------------------------------------------------------------------
C
C     SOPHISTICATED SETTING OF PARAMETERS
C     -----------------------------------
C              SEVERAL PARAMETERS OF THE CODE ARE TUNED TO MAKE IT WORK
C              WELL. THEY MAY BE DEFINED BY SETTING WORK(1),..,WORK(4)
C              AS WELL AS IWORK(1),IWORK(2) DIFFERENT FROM ZERO.
C              FOR ZERO INPUT, THE CODE CHOOSES DEFAULT VALUES:
C
C    IWORK(1)  THIS IS THE MAXIMAL NUMBER OF ALLOWED STEPS.
C              THE DEFAULT VALUE (FOR IWORK(1)=0) IS 100000.
C
C    IWORK(2)  SWITCH FOR THE CHOICE OF THE COEFFICIENTS
C              IF IWORK(2).EQ.1  METHOD (SEE BOOK, PAGE 452)
C              IF IWORK(2).EQ.2  SAME METHOD WITH DIFFERENT PARAMETERS
C              IF IWORK(2).EQ.3  METHOD WITH COEFF. OF GERD STEINEBACH
C              THE DEFAULT VALUE (FOR IWORK(2)=0) IS IWORK(2)=1.
C
C    IWORK(3)  SWITCH FOR STEP SIZE STRATEGY
C              IF IWORK(3).EQ.1  MOD. PREDICTIVE CONTROLLER (GUSTAFSSON)
C              IF IWORK(3).EQ.2  CLASSICAL APPROACH
C              THE DEFAULT VALUE (FOR IWORK(3)=0) IS IWORK(3)=1.
C
C       IF THE DIFFERENTIAL SYSTEM HAS THE SPECIAL STRUCTURE THAT
C            Y(I)' = Y(I+M2)   FOR  I=1,...,M1,
C       WITH M1 A MULTIPLE OF M2, A SUBSTANTIAL GAIN IN COMPUTERTIME
C       CAN BE ACHIEVED BY SETTING THE PARAMETERS IWORK(9) AND IWORK(10).
C       E.G., FOR SECOND ORDER SYSTEMS P'=V, V'=G(P,V), WHERE P AND V ARE
C       VECTORS OF DIMENSION N/2, ONE HAS TO PUT M1=M2=N/2.
C       FOR M1>0 SOME OF THE INPUT PARAMETERS HAVE DIFFERENT MEANINGS:
C       - JAC: ONLY THE ELEMENTS OF THE NON-TRIVIAL PART OF THE
C              JACOBIAN HAVE TO BE STORED
C              IF (MLJAC.EQ.N-M1) THE JACOBIAN IS SUPPOSED TO BE FULL
C                 DFY(I,J) = PARTIAL F(I+M1) / PARTIAL Y(J)
C                FOR I=1,N-M1 AND J=1,N.
C              ELSE, THE JACOBIAN IS BANDED ( M1 = M2 * MM )
C                 DFY(I-J+MUJAC+1,J+K*M2) = PARTIAL F(I+M1) / PARTIAL Y(J+K*M2)
C                FOR I=1,MLJAC+MUJAC+1 AND J=1,M2 AND K=0,MM.
C       - MLJAC: MLJAC=N-M1: IF THE NON-TRIVIAL PART OF THE JACOBIAN IS FULL
C                0<=MLJAC<N-M1: IF THE (MM+1) SUBMATRICES (FOR K=0,MM)
C                     PARTIAL F(I+M1) / PARTIAL Y(J+K*M2),  I,J=1,M2
C                    ARE BANDED, MLJAC IS THE MAXIMAL LOWER BANDWIDTH
C                    OF THESE MM+1 SUBMATRICES
C       - MUJAC: MAXIMAL UPPER BANDWIDTH OF THESE MM+1 SUBMATRICES
C                NEED NOT BE DEFINED IF MLJAC=N-M1
C       - MAS: IF IMAS=0 THIS MATRIX IS ASSUMED TO BE THE IDENTITY AND
C              NEED NOT BE DEFINED. SUPPLY A DUMMY SUBROUTINE IN THIS CASE.
C              IT IS ASSUMED THAT ONLY THE ELEMENTS OF RIGHT LOWER BLOCK OF
C              DIMENSION N-M1 DIFFER FROM THAT OF THE IDENTITY MATRIX.
C              IF (MLMAS.EQ.N-M1) THIS SUBMATRIX IS SUPPOSED TO BE FULL
C                 AM(I,J) = M(I+M1,J+M1)     FOR I=1,N-M1 AND J=1,N-M1.
C              ELSE, THE MASS MATRIX IS BANDED
C                 AM(I-J+MUMAS+1,J) = M(I+M1,J+M1)
C       - MLMAS: MLMAS=N-M1: IF THE NON-TRIVIAL PART OF M IS FULL
C                0<=MLMAS<N-M1: LOWER BANDWIDTH OF THE MASS MATRIX
C       - MUMAS: UPPER BANDWIDTH OF THE MASS MATRIX
C                NEED NOT BE DEFINED IF MLMAS=N-M1
C
C    IWORK(9)  THE VALUE OF M1.  DEFAULT M1=0.
C
C    IWORK(10) THE VALUE OF M2.  DEFAULT M2=M1.
C
C    WORK(1)   UROUND, THE ROUNDING UNIT, DEFAULT 1.D-16.
C
C    WORK(2)   MAXIMAL STEP SIZE, DEFAULT XEND-X.
C
C    WORK(3), WORK(4)   PARAMETERS FOR STEP SIZE SELECTION
C              THE NEW STEP SIZE IS CHOSEN SUBJECT TO THE RESTRICTION
C                 WORK(3) <= HNEW/HOLD <= WORK(4)
C              DEFAULT VALUES: WORK(3)=0.2D0, WORK(4)=6.D0
C
C    WORK(5)   THE SAFETY FACTOR IN STEP SIZE PREDICTION,
C              DEFAULT 0.9D0.
C
C-----------------------------------------------------------------------
C
C     OUTPUT PARAMETERS
C     -----------------
C     X           X-VALUE WHERE THE SOLUTION IS COMPUTED
C                 (AFTER SUCCESSFUL RETURN X=XEND)
C
C     Y(N)        SOLUTION AT X
C
C     H           PREDICTED STEP SIZE OF THE LAST ACCEPTED STEP
C
C     IDID        REPORTS ON SUCCESSFULNESS UPON RETURN:
C                   IDID= 1  COMPUTATION SUCCESSFUL,
C                   IDID= 2  COMPUT. SUCCESSFUL (INTERRUPTED BY SOLOUT)
C                   IDID=-1  INPUT IS NOT CONSISTENT,
C                   IDID=-2  LARGER NMAX IS NEEDED,
C                   IDID=-3  STEP SIZE BECOMES TOO SMALL,
C                   IDID=-4  MATRIX IS REPEATEDLY SINGULAR.
C
C   IWORK(14)  NFCN    NUMBER OF FUNCTION EVALUATIONS (THOSE FOR NUMERICAL
C                      EVALUATION OF THE JACOBIAN ARE NOT COUNTED)
C   IWORK(15)  NJAC    NUMBER OF JACOBIAN EVALUATIONS (EITHER ANALYTICALLY
C                      OR NUMERICALLY)
C   IWORK(16)  NSTEP   NUMBER OF COMPUTED STEPS
C   IWORK(17)  NACCPT  NUMBER OF ACCEPTED STEPS
C   IWORK(18)  NREJCT  NUMBER OF REJECTED STEPS (DUE TO ERROR TEST),
C                      (STEP REJECTIONS IN THE FIRST STEP ARE NOT COUNTED)
C   IWORK(19)  NDEC    NUMBER OF LU-DECOMPOSITIONS (N-DIMENSIONAL MATRIX)
C   IWORK(20)  NSOL    NUMBER OF FORWARD-BACKWARD SUBSTITUTIONS
C ---------------------------------------------------------
C *** *** *** *** *** *** *** *** *** *** *** *** ***
C          DECLARATIONS
C *** *** *** *** *** *** *** *** *** *** *** *** ***
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION Y(N),ATOL(*),RTOL(*),WORK(LWORK),IWORK(LIWORK)
      DIMENSION RPAR(*),IPAR(*)
      LOGICAL AUTNMS,IMPLCT,JBAND,ARRET,PRED
      EXTERNAL FCN,JAC,DFX,MAS,SOLOUT
C *** *** *** *** *** *** ***
C        SETTING THE PARAMETERS
C *** *** *** *** *** *** ***
      NFCN=0
      NACCPT=0
      NREJCT=0
      NSTEP=0
      NJAC=0
      NDEC=0
      NSOL=0
      ARRET=.FALSE.
C -------- NMAX , THE MAXIMAL NUMBER OF STEPS -----
      IF(IWORK(1).EQ.0)THEN
         NMAX=100000
      ELSE
         NMAX=IWORK(1)
         IF(NMAX.LE.0)THEN
            WRITE(6,*)' WRONG INPUT IWORK(1)=',IWORK(1)
            ARRET=.TRUE.
         END IF
      END IF
C -------- METH   COEFFICIENTS OF THE METHOD
      IF(IWORK(2).EQ.0)THEN
         METH=1
      ELSE
         METH=IWORK(2)
         IF(METH.LE.0.OR.METH.GE.4)THEN
            WRITE(6,*)' CURIOUS INPUT IWORK(2)=',IWORK(2)
            ARRET=.TRUE.
         END IF
      END IF
C -------- PRED   STEP SIZE CONTROL
      IF(IWORK(3).LE.1)THEN
         PRED=.TRUE.
      ELSE
         PRED=.FALSE.
      END IF
C -------- PARAMETER FOR SECOND ORDER EQUATIONS
      M1=IWORK(9)
      M2=IWORK(10)
      NM1=N-M1
      IF (M1.EQ.0) M2=N
      IF (M2.EQ.0) M2=M1
      IF (M1.LT.0.OR.M2.LT.0.OR.M1+M2.GT.N) THEN
       WRITE(6,*)' CURIOUS INPUT FOR IWORK(9,10)=',M1,M2
       ARRET=.TRUE.
      END IF
C -------- UROUND   SMALLEST NUMBER SATISFYING 1.D0+UROUND>1.D0
      IF(WORK(1).EQ.0.D0)THEN
         UROUND=1.D-16
      ELSE
         UROUND=WORK(1)
         IF(UROUND.LT.1.D-16.OR.UROUND.GE.1.D0)THEN
            WRITE(6,*)' COEFFICIENTS HAVE 16 DIGITS, UROUND=',WORK(1)
            ARRET=.TRUE.
         END IF
      END IF
C -------- MAXIMAL STEP SIZE
      IF(WORK(2).EQ.0.D0)THEN
         HMAX=XEND-X
      ELSE
         HMAX=WORK(2)
      END IF
C -------  FAC1,FAC2     PARAMETERS FOR STEP SIZE SELECTION
      IF(WORK(3).EQ.0.D0)THEN
         FAC1=5.D0
      ELSE
         FAC1=1.D0/WORK(3)
      END IF
      IF(WORK(4).EQ.0.D0)THEN
         FAC2=1.D0/6.0D0
      ELSE
         FAC2=1.D0/WORK(4)
      END IF
      IF (FAC1.LT.1.0D0.OR.FAC2.GT.1.0D0) THEN
            WRITE(6,*)' CURIOUS INPUT WORK(3,4)=',WORK(3),WORK(4)
            ARRET=.TRUE.
         END IF
C --------- SAFE     SAFETY FACTOR IN STEP SIZE PREDICTION
      IF (WORK(5).EQ.0.0D0) THEN
         SAFE=0.9D0
      ELSE
         SAFE=WORK(5)
         IF (SAFE.LE.0.001D0.OR.SAFE.GE.1.0D0) THEN
            WRITE(6,*)' CURIOUS INPUT FOR WORK(5)=',WORK(5)
            ARRET=.TRUE.
         END IF
      END IF
C --------- CHECK IF TOLERANCES ARE O.K.
      IF (ITOL.EQ.0) THEN
          IF (ATOL(1).LE.0.D0.OR.RTOL(1).LE.10.D0*UROUND) THEN
              WRITE (6,*) ' TOLERANCES ARE TOO SMALL'
              ARRET=.TRUE.
          END IF
      ELSE
          DO I=1,N
             IF (ATOL(I).LE.0.D0.OR.RTOL(I).LE.10.D0*UROUND) THEN
                WRITE (6,*) ' TOLERANCES(',I,') ARE TOO SMALL'
                ARRET=.TRUE.
             END IF
          END DO
      END IF
C *** *** *** *** *** *** *** *** *** *** *** *** ***
C         COMPUTATION OF ARRAY ENTRIES
C *** *** *** *** *** *** *** *** *** *** *** *** ***
C ---- AUTONOMOUS, IMPLICIT, BANDED OR NOT ?
      AUTNMS=IFCN.EQ.0
      IMPLCT=IMAS.NE.0
      JBAND=MLJAC.LT.NM1
C -------- COMPUTATION OF THE ROW-DIMENSIONS OF THE 2-ARRAYS ---
C -- JACOBIAN AND MATRIX E
      IF(JBAND)THEN
         LDJAC=MLJAC+MUJAC+1
         LDE=MLJAC+LDJAC
      ELSE
         MLJAC=NM1
         MUJAC=NM1
         LDJAC=NM1
         LDE=NM1
      END IF
C -- MASS MATRIX
      IF (IMPLCT) THEN
          IF (MLMAS.NE.NM1) THEN
              LDMAS=MLMAS+MUMAS+1
              IF (JBAND) THEN
                 IJOB=4
              ELSE
                 IJOB=3
              END IF
          ELSE
              LDMAS=NM1
              IJOB=5
          END IF
C ------ BANDWITH OF "MAS" NOT LARGER THAN BANDWITH OF "JAC"
          IF (MLMAS.GT.MLJAC.OR.MUMAS.GT.MUJAC) THEN
              WRITE (6,*) 'BANDWITH OF "MAS" NOT LARGER THAN BANDWITH OF
     & "JAC"'
            ARRET=.TRUE.
          END IF
      ELSE
          LDMAS=0
          IF (JBAND) THEN
             IJOB=2
          ELSE
             IJOB=1
          END IF
      END IF
      LDMAS2=MAX(1,LDMAS)
C ------- PREPARE THE ENTRY-POINTS FOR THE ARRAYS IN WORK -----
      IEYNEW=21
      IEDY1=IEYNEW+N
      IEDY=IEDY1+N
      IEAK1=IEDY+N
      IEAK2=IEAK1+N
      IEAK3=IEAK2+N
      IEAK4=IEAK3+N
      IEAK5=IEAK4+N
      IEAK6=IEAK5+N
      IEFX =IEAK6+N
      IECON=IEFX+N
      IEJAC=IECON+4*N
      IEMAS=IEJAC+N*LDJAC
      IEE  =IEMAS+NM1*LDMAS
C ------ TOTAL STORAGE REQUIREMENT -----------
      ISTORE=IEE+NM1*LDE-1
      IF(ISTORE.GT.LWORK)THEN
         WRITE(6,*)' INSUFFICIENT STORAGE FOR WORK, MIN. LWORK=',ISTORE
         ARRET=.TRUE.
      END IF
C ------- ENTRY POINTS FOR INTEGER WORKSPACE -----
      IEIP=21
      ISTORE=IEIP+NM1-1
      IF(ISTORE.GT.LIWORK)THEN
         WRITE(6,*)' INSUFF. STORAGE FOR IWORK, MIN. LIWORK=',ISTORE
         ARRET=.TRUE.
      END IF
C ------ WHEN A FAIL HAS OCCURED, WE RETURN WITH IDID=-1
      IF (ARRET) THEN
         IDID=-1
         RETURN
      END IF
C -------- CALL TO CORE INTEGRATOR ------------
      CALL ROSCOR(N,FCN,X,Y,XEND,HMAX,H,RTOL,ATOL,ITOL,JAC,IJAC,
     &   MLJAC,MUJAC,DFX,IDFX,MAS,MLMAS,MUMAS,SOLOUT,IOUT,IDID,NMAX,
     &   UROUND,METH,IJOB,FAC1,FAC2,SAFE,AUTNMS,IMPLCT,JBAND,PRED,LDJAC,
     &   LDE,LDMAS2,WORK(IEYNEW),WORK(IEDY1),WORK(IEDY),WORK(IEAK1),
     &   WORK(IEAK2),WORK(IEAK3),WORK(IEAK4),WORK(IEAK5),WORK(IEAK6),
     &   WORK(IEFX),WORK(IEJAC),WORK(IEE),WORK(IEMAS),IWORK(IEIP),
     &   WORK(IECON),
     &   M1,M2,NM1,NFCN,NJAC,NSTEP,NACCPT,NREJCT,NDEC,NSOL,RPAR,IPAR)
      IWORK(14)=NFCN
      IWORK(15)=NJAC
      IWORK(16)=NSTEP
      IWORK(17)=NACCPT
      IWORK(18)=NREJCT
      IWORK(19)=NDEC
      IWORK(20)=NSOL
C ----------- RETURN -----------
      RETURN
      END
C
C
C
C  ----- ... AND HERE IS THE CORE INTEGRATOR  ----------
C
      SUBROUTINE ROSCOR(N,FCN,X,Y,XEND,HMAX,H,RTOL,ATOL,ITOL,JAC,IJAC,
     &  MLJAC,MUJAC,DFX,IDFX,MAS,MLMAS,MUMAS,SOLOUT,IOUT,IDID,NMAX,
     &  UROUND,METH,IJOB,FAC1,FAC2,SAFE,AUTNMS,IMPLCT,BANDED,PRED,LDJAC,
     &  LDE,LDMAS,YNEW,DY1,DY,AK1,AK2,AK3,AK4,AK5,AK6,FX,FJAC,E,FMAS,IP,
     &  CONT,
     &  M1,M2,NM1,NFCN,NJAC,NSTEP,NACCPT,NREJCT,NDEC,NSOL,RPAR,IPAR)
C ----------------------------------------------------------
C     CORE INTEGRATOR FOR RODAS
C     PARAMETERS SAME AS IN RODAS WITH WORKSPACE ADDED
C ----------------------------------------------------------
C         DECLARATIONS
C ----------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION Y(N),YNEW(N),DY1(N),DY(N),AK1(N),
     *  AK2(N),AK3(N),AK4(N),AK5(N),AK6(N),FX(N),RPAR(*),IPAR(*),
     *  FJAC(LDJAC,N),E(LDE,NM1),FMAS(LDMAS,NM1),ATOL(*),RTOL(*)
      DIMENSION CONT(4*N)
      INTEGER IP(NM1)
      LOGICAL REJECT,AUTNMS,IMPLCT,BANDED,LAST,PRED
      COMMON/LINAL/MLE,MUE,MBJAC,MBB,MDIAG,MDIFF,MBDIAG
      COMMON /CONROS/XOLD,HOUT,NN
C$omp threadprivate(/LINAL/,/CONROS/)
C *** *** *** *** *** *** ***
C  INITIALISATIONS
C *** *** *** *** *** *** ***
      NN=N
      NN2=2*N
      NN3=3*N
      LRC=4*N
C ------- COMPUTE MASS MATRIX FOR IMPLICIT CASE ----------
      IF (IMPLCT) CALL MAS (NM1,FMAS,LDMAS,RPAR,IPAR)
C ------ SET THE PARAMETERS OF THE METHOD -----
      CALL ROCOE(METH,A21,A31,A32,A41,A42,A43,A51,A52,A53,A54,
     &    C21,C31,C32,C41,C42,C43,C51,C52,C53,C54,C61,
     &    C62,C63,C64,C65,GAMMA,C2,C3,C4,D1,D2,D3,D4,
     &    D21,D22,D23,D24,D25,D31,D32,D33,D34,D35)
C --- INITIAL PREPARATIONS
      IF (M1.GT.0) IJOB=IJOB+10
      POSNEG=SIGN(1.D0,XEND-X)
      HMAXN=MIN(ABS(HMAX),ABS(XEND-X))
      IF (ABS(H).LE.10.D0*UROUND) H=1.0D-6
      H=MIN(ABS(H),HMAXN)
      H=SIGN(H,POSNEG)
      REJECT=.FALSE.
      LAST=.FALSE.
      NSING=0
      IRTRN=1
      IF (AUTNMS) THEN
         HD1=0.0D0
         HD2=0.0D0
         HD3=0.0D0
         HD4=0.0D0
      END IF
C -------- PREPARE BAND-WIDTHS --------
      MBDIAG=MUMAS+1
      IF (BANDED) THEN
          MLE=MLJAC
          MUE=MUJAC
          MBJAC=MLJAC+MUJAC+1
          MBB=MLMAS+MUMAS+1
          MDIAG=MLE+MUE+1
          MDIFF=MLE+MUE-MUMAS
      END IF
      IF (IOUT.NE.0) THEN
          XOLD=X
          IRTRN=1
          HOUT=H
          CALL SOLOUT(NACCPT+1,XOLD,X,Y,CONT,LRC,N,
     &                RPAR,IPAR,IRTRN)
          IF (IRTRN.LT.0) GOTO 179
      END IF
C --- BASIC INTEGRATION STEP
 1    IF (NSTEP.GT.NMAX) GOTO 178
      IF (0.1D0*ABS(H).LE.ABS(X)*UROUND) GOTO 177
      IF (LAST) THEN
          H=HOPT
          IDID=1
          RETURN
      END IF
      HOPT=H
      IF ((X+H*1.0001D0-XEND)*POSNEG.GE.0.D0) THEN
         H=XEND-X
         LAST=.TRUE.
      END IF
C *** *** *** *** *** *** ***
C  COMPUTATION OF THE JACOBIAN
C *** *** *** *** *** *** ***
      CALL FCN(N,X,Y,DY1,RPAR,IPAR)
      NFCN=NFCN+1
      NJAC=NJAC+1
      IF (IJAC.EQ.0) THEN
C --- COMPUTE JACOBIAN MATRIX NUMERICALLY
         IF (BANDED) THEN
C --- JACOBIAN IS BANDED
            MUJACP=MUJAC+1
            MD=MIN(MBJAC,N)
            DO MM=1,M1/M2+1
               DO K=1,MD
                  J=K+(MM-1)*M2
 12               AK2(J)=Y(J)
                  AK3(J)=DSQRT(UROUND*MAX(1.D-5,ABS(Y(J))))
                  Y(J)=Y(J)+AK3(J)
                  J=J+MD
                  IF (J.LE.MM*M2) GOTO 12
                  CALL FCN(N,X,Y,AK1,RPAR,IPAR)
                  J=K+(MM-1)*M2
                  J1=K
                  LBEG=MAX(1,J1-MUJAC)+M1
 14               LEND=MIN(M2,J1+MLJAC)+M1
                  Y(J)=AK2(J)
                  MUJACJ=MUJACP-J1-M1
                  DO L=LBEG,LEND
                     FJAC(L+MUJACJ,J)=(AK1(L)-DY1(L))/AK3(J)
                  END DO
                  J=J+MD
                  J1=J1+MD
                  LBEG=LEND+1
                  IF (J.LE.MM*M2) GOTO 14
               END DO
            END DO
         ELSE
C --- JACOBIAN IS FULL
            DO I=1,N
               YSAFE=Y(I)
               DELT=DSQRT(UROUND*MAX(1.D-5,ABS(YSAFE)))
               Y(I)=YSAFE+DELT
               CALL FCN(N,X,Y,AK1,RPAR,IPAR)
               DO J=M1+1,N
                 FJAC(J-M1,I)=(AK1(J)-DY1(J))/DELT
               END DO
               Y(I)=YSAFE
            END DO
         END IF
      ELSE
C --- COMPUTE JACOBIAN MATRIX ANALYTICALLY
         CALL JAC(N,X,Y,FJAC,LDJAC,RPAR,IPAR)
      END IF
      IF (.NOT.AUTNMS) THEN
         IF (IDFX.EQ.0) THEN
C --- COMPUTE NUMERICALLY THE DERIVATIVE WITH RESPECT TO X
            DELT=SQRT(UROUND*MAX(1.D-5,ABS(X)))
            XDELT=X+DELT
            CALL FCN(N,XDELT,Y,AK1,RPAR,IPAR)
            DO J=1,N
               FX(J)=(AK1(J)-DY1(J))/DELT
            END DO
         ELSE
C --- COMPUTE ANALYTICALLY THE DERIVATIVE WITH RESPECT TO X
            CALL DFX(N,X,Y,FX,RPAR,IPAR)
         END IF
      END IF
   2  CONTINUE
C *** *** *** *** *** *** ***
C  COMPUTE THE STAGES
C *** *** *** *** *** *** ***
      FAC=1.D0/(H*GAMMA)
      CALL DECOMR(N,FJAC,LDJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &            M1,M2,NM1,FAC,E,LDE,IP,IER,IJOB,IMPLCT,IP)
      IF (IER.NE.0) GOTO 80
      NDEC=NDEC+1
C --- PREPARE FOR THE COMPUTATION OF THE 6 STAGES
      HC21=C21/H
      HC31=C31/H
      HC32=C32/H
      HC41=C41/H
      HC42=C42/H
      HC43=C43/H
      HC51=C51/H
      HC52=C52/H
      HC53=C53/H
      HC54=C54/H
      HC61=C61/H
      HC62=C62/H
      HC63=C63/H
      HC64=C64/H
      HC65=C65/H
      IF (.NOT.AUTNMS) THEN
         HD1=H*D1
         HD2=H*D2
         HD3=H*D3
         HD4=H*D4
      END IF
C --- THE STAGES
      CALL SLVROD(N,FJAC,LDJAC,MLJAC,MUJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &    M1,M2,NM1,FAC,E,LDE,IP,DY1,AK1,FX,YNEW,HD1,IJOB,.FALSE.)
      DO  I=1,N
         YNEW(I)=Y(I)+A21*AK1(I)
      END DO
      CALL FCN(N,X+C2*H,YNEW,DY,RPAR,IPAR)
      DO I=1,N
         YNEW(I)=HC21*AK1(I)
      END DO
      CALL SLVROD(N,FJAC,LDJAC,MLJAC,MUJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &    M1,M2,NM1,FAC,E,LDE,IP,DY,AK2,FX,YNEW,HD2,IJOB,.TRUE.)
      DO I=1,N
         YNEW(I)=Y(I)+A31*AK1(I)+A32*AK2(I)
      END DO
      CALL FCN(N,X+C3*H,YNEW,DY,RPAR,IPAR)
      DO I=1,N
         YNEW(I)=HC31*AK1(I)+HC32*AK2(I)
      END DO
      CALL SLVROD(N,FJAC,LDJAC,MLJAC,MUJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &    M1,M2,NM1,FAC,E,LDE,IP,DY,AK3,FX,YNEW,HD3,IJOB,.TRUE.)
      DO I=1,N
         YNEW(I)=Y(I)+A41*AK1(I)+A42*AK2(I)+A43*AK3(I)
      END DO
      CALL FCN(N,X+C4*H,YNEW,DY,RPAR,IPAR)
      DO I=1,N
         YNEW(I)=HC41*AK1(I)+HC42*AK2(I)+HC43*AK3(I)
      END DO
      CALL SLVROD(N,FJAC,LDJAC,MLJAC,MUJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &    M1,M2,NM1,FAC,E,LDE,IP,DY,AK4,FX,YNEW,HD4,IJOB,.TRUE.)
      DO I=1,N
         YNEW(I)=Y(I)+A51*AK1(I)+A52*AK2(I)+A53*AK3(I)+A54*AK4(I)
      END DO
      CALL FCN(N,X+H,YNEW,DY,RPAR,IPAR)
      DO I=1,N
         AK6(I)=HC52*AK2(I)+HC54*AK4(I)+HC51*AK1(I)+HC53*AK3(I)
      END DO
      CALL SLVROD(N,FJAC,LDJAC,MLJAC,MUJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &    M1,M2,NM1,FAC,E,LDE,IP,DY,AK5,FX,AK6,0.D0,IJOB,.TRUE.)
C ------------ EMBEDDED SOLUTION ---------------
      DO I=1,N
         YNEW(I)=YNEW(I)+AK5(I)
      END DO
      CALL FCN(N,X+H,YNEW,DY,RPAR,IPAR)
      DO I=1,N
         CONT(I)=HC61*AK1(I)+HC62*AK2(I)+HC65*AK5(I)
     &              +HC64*AK4(I)+HC63*AK3(I)
      END DO
      CALL SLVROD(N,FJAC,LDJAC,MLJAC,MUJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &    M1,M2,NM1,FAC,E,LDE,IP,DY,AK6,FX,CONT,0.D0,IJOB,.TRUE.)
C ------------ NEW SOLUTION ---------------
      DO  I=1,N
         YNEW(I)=YNEW(I)+AK6(I)
      END DO
      NSOL=NSOL+6
      NFCN=NFCN+5
C ------------ DENSE OUTPUT ----------
      IF (IOUT.NE.0) THEN
         DO I=1,N
            CONT(I)=Y(I)
            CONT(I+NN2)=D21*AK1(I)+D22*AK2(I)+D23*AK3(I)+D24*AK4(I)
     &               +D25*AK5(I)
            CONT(I+NN3)=D31*AK1(I)+D32*AK2(I)+D33*AK3(I)+D34*AK4(I)
     &               +D35*AK5(I)
         END DO
      END IF
C *** *** *** *** *** *** ***
C  ERROR ESTIMATION
C *** *** *** *** *** *** ***
      NSTEP=NSTEP+1
C ------------ COMPUTE ERROR ESTIMATION ----------------
      ERR=0.D0
      DO I=1,N
         IF (ITOL.EQ.0) THEN
            SK=ATOL(1)+RTOL(1)*MAX(ABS(Y(I)),ABS(YNEW(I)))
         ELSE
            SK=ATOL(I)+RTOL(I)*MAX(ABS(Y(I)),ABS(YNEW(I)))
         END IF
         ERR=ERR+(AK6(I)/SK)**2
      END DO
      ERR=SQRT(ERR/N)
C --- COMPUTATION OF HNEW
C --- WE REQUIRE .2<=HNEW/H<=6.
      FAC=MAX(FAC2,MIN(FAC1,(ERR)**0.25D0/SAFE))
      HNEW=H/FAC
C *** *** *** *** *** *** ***
C  IS THE ERROR SMALL ENOUGH ?
C *** *** *** *** *** *** ***
      IF (ERR.LE.1.D0) THEN
C --- STEP IS ACCEPTED
         NACCPT=NACCPT+1
         IF (PRED) THEN
C       --- PREDICTIVE CONTROLLER OF GUSTAFSSON
            IF (NACCPT.GT.1) THEN
               FACGUS=(HACC/H)*(ERR**2/ERRACC)**0.25D0/SAFE
               FACGUS=MAX(FAC2,MIN(FAC1,FACGUS))
               FAC=MAX(FAC,FACGUS)
               HNEW=H/FAC
            END IF
            HACC=H
            ERRACC=MAX(1.0D-2,ERR)
         END IF
         DO I=1,N
            Y(I)=YNEW(I)
         END DO
         XOLD=X
         X=X+H
         IF (IOUT.NE.0) THEN
            DO I=1,N
               CONT(NN+I)=Y(I)
            END DO
            IRTRN=1
            HOUT=H
            CALL SOLOUT(NACCPT+1,XOLD,X,Y,CONT,LRC,N,
     &                   RPAR,IPAR,IRTRN)
            IF (IRTRN.LT.0) GOTO 179
         END IF
         IF (ABS(HNEW).GT.HMAXN) HNEW=POSNEG*HMAXN
         IF (REJECT) HNEW=POSNEG*MIN(ABS(HNEW),ABS(H))
         REJECT=.FALSE.
         H=HNEW
         GOTO 1
      ELSE
C --- STEP IS REJECTED
         REJECT=.TRUE.
         LAST=.FALSE.
         H=HNEW
         IF (NACCPT.GE.1) NREJCT=NREJCT+1
         GOTO 2
      END IF
C --- SINGULAR MATRIX
  80  NSING=NSING+1
      IF (NSING.GE.5) GOTO 176
      H=H*0.5D0
      REJECT=.TRUE.
      LAST=.FALSE.
      GOTO 2
C --- FAIL EXIT
 176  CONTINUE
      WRITE(6,979)X
      WRITE(6,*) ' MATRIX IS REPEATEDLY SINGULAR, IER=',IER
      IDID=-4
      RETURN
 177  CONTINUE
      WRITE(6,979)X
      WRITE(6,*) ' STEP SIZE T0O SMALL, H=',H
      IDID=-3
      RETURN
 178  CONTINUE
      WRITE(6,979)X
      WRITE(6,*) ' MORE THAN NMAX =',NMAX,'STEPS ARE NEEDED'
      IDID=-2
      RETURN
C --- EXIT CAUSED BY SOLOUT
 179  CONTINUE
      WRITE(6,979)X
 979  FORMAT(' EXIT OF RODAS AT X=',E18.4)
      IDID=2
      RETURN
      END
C
      FUNCTION CONTRO(I,X,CONT,LRC)
C ----------------------------------------------------------
C     THIS FUNCTION CAN BE USED FOR CONTINUOUS OUTPUT IN CONNECTION
C     WITH THE OUTPUT-SUBROUTINE FOR RODAS. IT PROVIDES AN
C     APPROXIMATION TO THE I-TH COMPONENT OF THE SOLUTION AT X.
C ----------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION CONT(LRC)
      COMMON /CONROS/XOLD,H,N
C$omp threadprivate(/CONROS/)
      S=(X-XOLD)/H
      CONTRO=CONT(I)*(1-S)+S*(CONT(I+N)+(1-S)*(CONT(I+N*2)
     &      +S*CONT(I+N*3)))
      RETURN
      END
C
      SUBROUTINE ROCOE(METH,A21,A31,A32,A41,A42,A43,A51,A52,A53,A54,
     &  C21,C31,C32,C41,C42,C43,C51,C52,C53,C54,C61,
     &  C62,C63,C64,C65,GAMMA,C2,C3,C4,D1,D2,D3,D4,
     &  D21,D22,D23,D24,D25,D31,D32,D33,D34,D35)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      GOTO (1,2,3), METH
 1      C2=0.386D0
        C3=0.21D0
        C4=0.63D0
        BET2P=0.0317D0
        BET3P=0.0635D0
        BET4P=0.3438D0
       D1= 0.2500000000000000D+00
       D2=-0.1043000000000000D+00
       D3= 0.1035000000000000D+00
       D4=-0.3620000000000023D-01
       A21= 0.1544000000000000D+01
       A31= 0.9466785280815826D+00
       A32= 0.2557011698983284D+00
       A41= 0.3314825187068521D+01
       A42= 0.2896124015972201D+01
       A43= 0.9986419139977817D+00
       A51= 0.1221224509226641D+01
       A52= 0.6019134481288629D+01
       A53= 0.1253708332932087D+02
       A54=-0.6878860361058950D+00
       C21=-0.5668800000000000D+01
       C31=-0.2430093356833875D+01
       C32=-0.2063599157091915D+00
       C41=-0.1073529058151375D+00
       C42=-0.9594562251023355D+01
       C43=-0.2047028614809616D+02
       C51= 0.7496443313967647D+01
       C52=-0.1024680431464352D+02
       C53=-0.3399990352819905D+02
       C54= 0.1170890893206160D+02
       C61= 0.8083246795921522D+01
       C62=-0.7981132988064893D+01
       C63=-0.3152159432874371D+02
       C64= 0.1631930543123136D+02
       C65=-0.6058818238834054D+01
       GAMMA= 0.2500000000000000D+00

       D21= 0.1012623508344586D+02
       D22=-0.7487995877610167D+01
       D23=-0.3480091861555747D+02
       D24=-0.7992771707568823D+01
       D25= 0.1025137723295662D+01
       D31=-0.6762803392801253D+00
       D32= 0.6087714651680015D+01
       D33= 0.1643084320892478D+02
       D34= 0.2476722511418386D+02
       D35=-0.6594389125716872D+01
      RETURN
C
 2      C2=0.3507221D0
        C3=0.2557041D0
        C4=0.6817790D0
        BET2P=0.0317D0
        BET3P=0.0047369D0
        BET4P=0.3438D0
       D1= 0.2500000000000000D+00
       D2=-0.6902209999999998D-01
       D3=-0.9671999999999459D-03
       D4=-0.8797900000000025D-01
       A21= 0.1402888400000000D+01
       A31= 0.6581212688557198D+00
       A32=-0.1320936088384301D+01
       A41= 0.7131197445744498D+01
       A42= 0.1602964143958207D+02
       A43=-0.5561572550509766D+01
       A51= 0.2273885722420363D+02
       A52= 0.6738147284535289D+02
       A53=-0.3121877493038560D+02
       A54= 0.7285641833203814D+00
       C21=-0.5104353600000000D+01
       C31=-0.2899967805418783D+01
       C32= 0.4040399359702244D+01
       C41=-0.3264449927841361D+02
       C42=-0.9935311008728094D+02
       C43= 0.4999119122405989D+02
       C51=-0.7646023087151691D+02
       C52=-0.2785942120829058D+03
       C53= 0.1539294840910643D+03
       C54= 0.1097101866258358D+02
       C61=-0.7629701586804983D+02
       C62=-0.2942795630511232D+03
       C63= 0.1620029695867566D+03
       C64= 0.2365166903095270D+02
       C65=-0.7652977706771382D+01
       GAMMA= 0.2500000000000000D+00

       D21=-0.3871940424117216D+02
       D22=-0.1358025833007622D+03
       D23= 0.6451068857505875D+02
       D24=-0.4192663174613162D+01
       D25=-0.2531932050335060D+01
       D31=-0.1499268484949843D+02
       D32=-0.7630242396627033D+02
       D33= 0.5865928432851416D+02
       D34= 0.1661359034616402D+02
       D35=-0.6758691794084156D+00
      RETURN
c
C Coefficients for RODAS with order 4 for linear parabolic problems
C Gerd Steinebach (1993)
  3     GAMMA = 0.25D0
	      C2=3.d0*GAMMA
        C3=0.21D0
        C4=0.63D0
	      BET2P=0.D0
	      BET3P=c3*c3*(c3/6.d0-GAMMA/2.d0)/(GAMMA*GAMMA)
        BET4P=0.3438D0
       D1= 0.2500000000000000D+00
       D2=-0.5000000000000000D+00
       D3=-0.2350400000000000D-01
       D4=-0.3620000000000000D-01
       A21= 0.3000000000000000D+01
       A31= 0.1831036793486759D+01
       A32= 0.4955183967433795D+00
       A41= 0.2304376582692669D+01
       A42=-0.5249275245743001D-01
       A43=-0.1176798761832782D+01
       A51=-0.7170454962423024D+01
       A52=-0.4741636671481785D+01
       A53=-0.1631002631330971D+02
       A54=-0.1062004044111401D+01
       C21=-0.1200000000000000D+02
       C31=-0.8791795173947035D+01
       C32=-0.2207865586973518D+01
       C41= 0.1081793056857153D+02
       C42= 0.6780270611428266D+01
       C43= 0.1953485944642410D+02
       C51= 0.3419095006749676D+02
       C52= 0.1549671153725963D+02
       C53= 0.5474760875964130D+02
       C54= 0.1416005392148534D+02
       C61= 0.3462605830930532D+02
       C62= 0.1530084976114473D+02
       C63= 0.5699955578662667D+02
       C64= 0.1840807009793095D+02
       C65=-0.5714285714285717D+01
c
       D21= 0.2509876703708589D+02
       D22= 0.1162013104361867D+02
       D23= 0.2849148307714626D+02
       D24=-0.5664021568594133D+01
       D25= 0.0000000000000000D+00
       D31= 0.1638054557396973D+01
       D32=-0.7373619806678748D+00
       D33= 0.8477918219238990D+01
       D34= 0.1599253148779520D+02
       D35=-0.1882352941176471D+01
      RETURN
      END
