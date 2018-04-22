000100180312     FCONFIRMPAYCF   E             WORKSTN
000101180312     FSHIFTRATESIF   E             DISK    RENAME(SHIFTRATES:SHIFTRATER)
000102180312     FALLSHIFT  IF   E           K DISK    RENAME(ALLSHIFT:ALLSHIFTR)
000104180312     FPAYRPT    O    E             PRINTER OFLIND(*IN01)
000105180312     DHOURSOVER        S              3  0
000106180312
000107180312      /FREE
000108180312               READ SHIFTRATES;
000109180312               WRITE TITLE;
000110180312               WRITE COLHDG;
000111180312               READ ALLSHIFT;
000112180312               DOW NOT %EOF;
000113180312                   EXSR PAYSR;
000114180312                   IF *IN01;
000115180312                       WRITE TITLE;
000116180312                       WRITE COLHDG;
000117180312                       *IN01 = *OFF;
000118180312                   ENDIF;
000119180312                   WRITE EMPDETAIL;
000120180312                   READ ALLSHIFT;
000121180312               ENDDO;
000122180312               TOTEMPPAY = TOTREGPAY + TOTOVTPAY;
000123180312               WRITE TOTALS;
000124180312               EXFMT RECORD1;
000125180312               *INLR = *ON;
000126180312               RETURN;
000127180312
000128180312               BEGSR PAYSR;
000129180312                      SELECT;
000130180312                        WHEN WORKSHIFT = 'D';
000131180312                          HOURLYRATE = DAYRATE;
000132180312                        WHEN WORKSHIFT = 'N';
000133180312                          HOURLYRATE = NIGHTRATE;
000134180312                        WHEN WORKSHIFT = 'A';
000135180312                          HOURLYRATE = AFTNRATE;
000136180312                      ENDSL;
000137180312
000138180312                      SELECT;
000139180312                        WHEN PAYGRADE = '1';
000140180312                          EVAL(H) HOURLYRATE *= 1.073;
000141180312                        WHEN PAYGRADE = '2';
000142180312                          EVAL(H) HOURLYRATE *= 1.054;
000143180312                        WHEN PAYGRADE = '3';
000144180312                          EVAL(H) HOURLYRATE *= 0.955;
000145180312                      ENDSL;
000146180312                      HOURSOVER = HRSWORKED - 40;
000147180312                      SELECT;
000148180312                        WHEN (HOURSOVER > 0);
000149180312                          REGULARPAY = 40 * HOURLYRATE;
000150180312                          EVAL(H) OVERPAY = HOURSOVER * HOURLYRATE * 1.5;
000151180312                          TOTREGPAY += REGULARPAY;
000152180312                          TOTOVTPAY += OVERPAY;
000153180312                        OTHER;
000154180312                          REGULARPAY = HRSWORKED * HOURLYRATE;
000155180312                          OVERPAY = 0;
000156180312                          TOTREGPAY += REGULARPAY;
000157180312                      ENDSL;
000158180312                      TOTALPAY = REGULARPAY + OVERPAY;
000159180312               ENDSR;
000160180312
