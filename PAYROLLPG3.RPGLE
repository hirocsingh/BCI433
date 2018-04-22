000100180319     FCONFIRMPY2CF   E             WORKSTN
000101180319     FSHIFTRATESIF   E             DISK    RENAME(SHIFTRATES:SHIFTRATER)
000102180319     FALLSHIFT  IF   E           K DISK    RENAME(ALLSHIFT:ALLSHIFTR)
000103180319     FPAYRPT2   O    E             PRINTER OFLIND(*IN01)
000104180319     DHOURSOVER        S              3  0
000105180319     DMAIN             PR                  EXTPGM('PAYROLLPG3')
000106180319     DSHIFTTYPE                      30
000107180319     DMAIN             PI
000108180319     DSHIFTTYPE                      30
000109180319
000110180319      /FREE
000111180319               READ SHIFTRATES;
000112180319               WRITE TITLE;
000113180319               WRITE COLHDG;
000114180319               READ ALLSHIFT;
000115180319               DOW NOT %EOF;
000116180319                   EXSR PAYSR;
000117180319                   IF *IN01;
000118180319                       WRITE TITLE;
000119180319                       WRITE COLHDG;
000120180319                       *IN01 = *OFF;
000121180319                   ENDIF;
000122180319                   WRITE EMPDETAIL;
000123180319                   READ ALLSHIFT;
000124180319               ENDDO;
000125180319               TOTEMPPAY = TOTREGPAY + TOTOVTPAY;
000126180319               WRITE TOTALS;
000127180319               EXFMT RECORD1;
000128180319               *INLR = *ON;
000129180319               RETURN;
000130180319
000131180319               BEGSR PAYSR;
000132180319                      SELECT;
000133180319                        WHEN WORKSHIFT = 'D';
000134180319                          HOURLYRATE = DAYRATE;
000135180319                        WHEN WORKSHIFT = 'N';
000136180319                          HOURLYRATE = NIGHTRATE;
000137180319                        WHEN WORKSHIFT = 'A';
000138180319                          HOURLYRATE = AFTNRATE;
000139180319                      ENDSL;
000140180319
000141180319                      SELECT;
000142180319                        WHEN PAYGRADE = '1';
000143180319                          EVAL(H) HOURLYRATE *= 1.073;
000144180319                        WHEN PAYGRADE = '2';
000145180319                          EVAL(H) HOURLYRATE *= 1.054;
000146180319                        WHEN PAYGRADE = '3';
000147180319                          EVAL(H) HOURLYRATE *= 0.955;
000148180319                      ENDSL;
000149180319                      HOURSOVER = HRSWORKED - 40;
000150180319                      SELECT;
000151180319                        WHEN (HOURSOVER > 0);
000152180319                          REGULARPAY = 40 * HOURLYRATE;
000153180319                          EVAL(H) OVERPAY = HOURSOVER * HOURLYRATE * 1.5;
000154180319                          TOTREGPAY += REGULARPAY;
000155180319                          TOTOVTPAY += OVERPAY;
000156180319                        OTHER;
000157180319                          REGULARPAY = HRSWORKED * HOURLYRATE;
000158180319                          OVERPAY = 0;
000159180319                          TOTREGPAY += REGULARPAY;
000160180319                      ENDSL;
000161180319                      TOTALPAY = REGULARPAY + OVERPAY;
000162180319               ENDSR;
000163180319
