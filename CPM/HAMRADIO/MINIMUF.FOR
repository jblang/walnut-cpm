
C     THIS VERSION WRITTEN FOR FORTRAN 77 USED ON PDP-11
C     BY GERRY KERSUS, W1GD
C
C     Also works FB on a VAX-11/780  (N2IC)

      REAL A(2), C0(2), G6(2), G7(2), G8(2), Z(2)
      REAL T1(2), T3(2), T4(2), T9(2)

      CHARACTER*3 PA
      PI=3.14159


C     NORTH LATITUDE AND WEST LONGITUDE IS POSITIVE
C     OLAT IS HARD-CODED FOR THE ORIGINATING STATION LATITUDE
      OLAT=40.0
C     OLON IS HARD-CODED FOR THE ORIGINATING STATION LONGITUDE
      OLON=-105.0
C     DLAT & DLON ARE DESTINATION LATITUDE & LONGITUDE
      PRINT *, 'ENTER DESTINATION LATITUDE AND LONGITUDE'
      READ *, DLAT, DLON
      DLON =-DLON

C     INPUT MONTH AS A NUMBER FROM 1 TO 12
      PRINT *, 'ENTER MONTH (1-12)'
      READ *, M0

C     INPUT DAY AS A NUMBER FROM 1 TO 31
      PRINT *, 'ENTER DAY (1-31)'
      READ *, D0

C     S0 IS THE SUNSPOT NUMBER
C     SF IS THE SOLAR FLUX
      PRINT *, 'ENTER SOLAR FLUX'
      READ *, SF
      S0=625.*(SQRT((0.73)**2-0.0032*(65.-SF))-.73)
      IS0=NINT (S0)

C     PA INDICATES LONG PATH ("L") OR SHORT PATH ('S')
      PA='S'

      W1=-(OLON-180.*(1+SGN(OLON-.001)))*PI/180.
      W2=-(DLON-180.*(1+SGN(DLON-.001)))*PI/180.
      A1=OLAT*PI/180.
      A2=DLAT*PI/180.

C     ROTATE LONGITUDES
      W3=W2-W1+.001
      W3=PI*(1-SGN(W3))+W3
      H1=SIN(A1)*SIN(A2)+COS(A1)*COS(A2)*COS(W3)
      G1=ATAN(SQRT(1-H1*H1)/H1)+PI/2.*(1-SGN(H1))
      IF (PA .EQ. 'L') THEN
      G1=PI+PI-G1
      ELSE
      CONTINUE
      END IF
C     PATH LENGTH IN 4 KM UNITS
      H0=INT(1.59*G1)+1.
C     CALCULATE BEARING
      H9=(SIN(A2)-H1*SIN(A1))/SIN(G1)/COS(A1)
      H9=ATAN(SQRT(1-H9*H9)/H9)+PI/2.*(1-SGN(H9))
      H9=H9*SGN(W3-PI)*SGN(PI-G1)
      H9=H9+PI*(1-SGN(H9))
      IB1=INT(H9*180./PI+.5)
      PRINT 1, ' MONTH:', M0, ' SUNSPOT NO.', IS0
1     FORMAT (A, I2, A, I3)
      PRINT 5, ' LONG/SHORT = ', PA, ' BEARING:', IB1
5     FORMAT (A, A, A, I3)
      PRINT *, ' GMT        HPF        MUF        LUF'
      
      Y6=ATAN(1./TAN(G1/(H0+1.))-.952/SIN(G1/(H0+1.)))
      IF (Y6 .LT. .314) THEN
      Y6=.314
      ELSE
      END IF

      Y6=1./SQRT(1.-.965*COS(Y6)**2)
      Y1=.0172*(10.+(M0-1.)*30.4+D0)
      Y2=.409*COS(Y1)
      Y1=.13*SIN(Y1)+.156*SIN(Y1+Y1)
C     DIRECTION COSINE
      H9=(SIN(A1)-COS(G1)*SIN(A2))/SIN(G1)/COS(A2)
      Z9=SIN(2.5*G1/H0)
      Z9=1.+2.5*Z9*SQRT(Z9)
      Z0=1.-.5/H0

      DO 20 N = 1, 2
      A9=COS(G1*Z0)*SIN(A2)+SIN(G1*Z0)*COS(A2)*H9
      A0=PI/2.-(ATAN(SQRT(1.-A9*A9)/A9)+PI/2.*(1-SGN(A9)))
      W0=(COS(G1*Z0)-SIN(A2)*A9)/COS(A2)/COS(A0)
      W0=ATAN(SQRT(1.-W0*W0)/W0)+PI/2.*(1.-SGN(W0))
      W0=PI-SGN(PI-G1*Z0)*(PI-W0)
      W0=W3+W0*SGN(W3-PI)*SGN(PI-G1)+W1-.001
      W0=W0-PI*(1.-SGN(PI+PI-W0))
      T0=3.82*W0+12.+Y1
      T0=T0-12.*(1.+SGN(T0-24.))*SGN(ABS(T0-24.))

      IF (COS(A0+Y2) .LE. -.26)THEN
      T1(N)=0.
      GO TO 15
      ELSE
      END IF
      T1(N)=(SIN(Y2)*A9-.26)/(COS(Y2)*COS(A0)+.001)
      T1(N)=12.-ATAN(T1(N)/SQRT(ABS(1.-T1(N)*T1(N))))*24./PI
      T7=T0-T1(N)/2.
      T3(N)=T7+12.*(1.-SGN(T7))*SGN(ABS(T7))
      T7=T0+T1(N)/2.
      T4(N)=T7-12.*(1.+SGN(T7-24.))*SGN(ABS(T7-24.))
      C0(N)=ABS(COS(A0+Y2))
      T9(N)=9.7*(C0(N)**8)
      IF (T9(N) .LT. .1) THEN
      T9(N)=.1
      ELSE
      END IF

15    Z0=1.-Z0
      U2=INT(12./T1(N))
      U3=INT(T1(N)/12.)
      Z(N)=Z9*.75*((12./T1(N)-1.)*SGN(U2)+1.)
      Z(N)=Z(N)*(1+S0/100.*(1-(T1(N)/12.-1.)*SGN(U3)))
      A9=ABS(A0+.21*SIN(W0+.35))   
      G2=.5
      IF (A9 .GE. (PI/4.)) THEN
      Z(N)=Z(N)*(1.-.1*(1.+COS(A9*4.)))
      G2=.2
      ELSE
      END IF

      A(N)=SIN(A9*4.)*G2
      G8(N)=PI*T9(N)/T1(N)
      T7=T1(N)/T9(N)
      IF (T7 .GT. 85.) THEN
      T7=85.
      ELSE
      END IF

      G7(N)=C0(N)*G8(N)*(EXP(-T7)+1.)
      G6(N)=G7(N)*EXP((T1(N)-24.)/2.)
20    CONTINUE
      DO 90 J = 1, 24
      T5=J-1.
      R9=100.
      E9=0.
      DO 80 N = 1, 2
      G0=0.
      G3=PI/2.
      IF (T1(N) .EQ. 0.) THEN
      GO TO 40
      ELSE
      CONTINUE
      END IF
      IF (T4(N) .LT. T3(N)) THEN
      GO TO 25
      ELSE
      CONTINUE
      END IF
C     DAYTIME ?
      IF (((T5-T3(N))*(T4(N)-T5)) .GT. 0.) THEN
      GO TO 30
      ELSE
      GO TO 45
      END IF
C     NIGHT TIME ?
25    IF (((T5-T4(N))*(T3(N)-T5)) .GT. 0.) THEN
      GO TO 45
      ELSE
      END IF
C     EFFECTIVE COS X (DAY)
30    T6=T5+12.*(1.+SGN(T3(N)-T5))*SGN(ABS(T3(N)-T5))
      G4=PI*(T6-T3(N))/T1(N)
      T8=(T3(N)-T6)/T9(N)

      IF (ABS(T8) .GT. 85.) THEN
      T8=85.*SGN(T8)
      ELSE
      END IF
      G0=C0(N)*(SIN(G4)+G8(N)*(EXP(T8)-COS(G4)))
      G3=PI/2.
       
      IF ((T6-T3(N)) .GT. (T1(N)/2.+3.)) THEN
      GO TO 35
      ELSE
      G3=(T6-T3(N))/(T1(N)/2.+3.)*G3
      ENDIF
35    G3=G3*(1.+SGN(A(N)))
      IF (G0 .LT. G6(N)) THEN
      G0=G6(N)
      ELSE
      END IF
C     F0F2
40    G2=SQRT(7.+45*SQRT(G0/(1.+G8(N)*G8(N))))

C     HPF
      G2=G2*Z(N)*1.27*(1.+SIN(G3)*A(N))
      GO TO 50
C     EFFECTIVE COS X (NIGHT)
45    T6=T5+12.*(1.+SGN(T4(N)-T5))*SGN(ABS(T4(N)-T5))
      G4=PI*(T6-T4(N))/(24.-T1(N))
      G0=G7(N)*EXP((T4(N)-T6)/2.)
      G3=G4+(PI-G4)/4.*(1.+SGN(A(N)))
      G4=0.
      GO TO 40
50    IF (G2 .LT. R9) THEN
      R9=G2
      ELSE
      END IF
C     E LAYER
      Y8=.2
      IF (T1(N) .EQ. 0.) THEN
      GO TO 55
      ELSE IF ((T1(N)*G4) .EQ. 0.) THEN
      GO TO 55
      ELSE
      END IF
      Y9=C0(N)*SIN(PI*(T6-T3(N))/T1(N))
      IF (Y9 .LE. .174) THEN
      Y8=(ATAN(SQRT(1.-Y9*Y9)/Y9)*180./PI-76.)**(-.4)
      ELSE
      Y8=Y9**(.3)
      END IF
55    Y9=(3.4+.00544*S0)*Y8*Y6
      IF (Y9 .LE. 7.) THEN
      Y9=.91*Y9-.37
      ELSE
      Y9=(1.33*Y9-3.31)**(2.)/7
      END IF

      IF (E9 .LT. Y9) THEN
      E9=Y9
      ELSE
      END IF
80    CONTINUE

      IT5=INT(T5)
      HPF=(R9+.5)
      RMUF=(R9/1.27+.5)
      RLUF=(E9+.5)
      PRINT 85, IT5, HPF, RMUF, RLUF
85    FORMAT (I6, 3F6.1)
      
90    CONTINUE

      END

      FUNCTION SGN (X)
C     THIS ROUTINE PROVIDES SIGNUM FUNCTION FOR ARGUMENT X
      SGN=SIGN (0.5, X)-SIGN (0.5, -X)
      RETURN
      END
