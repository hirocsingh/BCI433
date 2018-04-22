000100180329     F**************************************************************************
000101180329     F*  CUSTOMER18 READ BY NATIVE LANGUAGE (ILE RPG)
000102180329     F*  CONTACTF18 ROW RETRIEVED WITH EMBEDDED SQL
000103180329     F*  DETAIL REPORT LINE INCLUDES INFORMATION FROM CUSTOMER17 AND CONTACTF18
000104180329     F*  SUMMARY REPORT INFORMATION RETRIEVED WITH EMBEDDED SQL STATEMENTS
000105180329     F**************************************************************************
000106180329
000107180329     FCUSTOMER18IF   E             DISK    RENAME(CUSTOMER18:CUSTOMERRF)
000108180329     FQPRINT    O    F  132        PRINTER OFLIND(*INOF) FORMOFL(30) FORMLEN(66)
000111180329     D CONTACTW18    E DS
000112180329     D ContactTotal    S              5  0
000113180329     D CustomerTotal   S              5  0
000114180329     D UnknownTotal    S              5  0
000115180329     D OldestDate      S               D
000116180329     D MostRecentDate  S               D
000117180329     D User            S             10
000118180329     D Server          S             10
000119180329     D TimeStamp       S               Z
000120180329     D DateIn          S              5  0
000123180329     D IndLastDateC    S              4B 0
000124180329     D IndNextDateC    S              4B 0
000125180329
000126180329     D Dummy           S              1  0
000127180329     D Flag            S              7
000128180329     D NextCallDate    S               D
000129180329     C/EJECT
000130180329     C**************************************************************************
000131180329     C*                        ***   M A I N   R O U T I N E   ***
000132180329     C**************************************************************************
000133180329      /FREE
000134180329                EXSR SummaryInfo;
000135180329                EXCEPT HEADINGS;
000136180329                READ CUSTOMER18;
000137180329                DOW NOT %EOF;
000138180329                    EXSR SQLSelect;
000139180329                    IF *INOF = *ON;
000140180329                       EXCEPT HEADINGS;
000141180329                       *INOF = *OFF;
000142180329                    ENDIF;
000143180329                    EXCEPT DETAIL;
000144180329                   READ CUSTOMER18;
000145180329                ENDDO;
000146180329                EXCEPT TOTALS;
000147180329                *INLR = *ON;
000148180329                RETURN;
000149180329        //*************************************************************************
000150180329        //   S Q L S E L E C T   S U B R O U T I N E
000151180329   //   //********************************************************************
000152180329   //                  BEGSR    SQLSelect ;
000153180329   //    // A row from the contacts table that has the same customer number found in the
000154180329   //    // record read from the CUSTOMER17 file. That row is retrieved to find out the last
000155180329   //    // date called, phone number, comments and the salesperson number.
000156180329   //
000157180329   //    //  The call back interval is added to the last date called to determine the
000158180329   //    //  next date to call.  Since null values may be stored in the last date called
000159180329   //    // indicator variables are used.
000160180329                                EXEC SQL
000161180329                                     SELECT PHNLDC + PHNCIT DAYS, PHNLDC,
000162180329                                       CSTPHN, PHNCOM, CSTSLN
000163180329                                     INTO :NextCallDate :IndNextDateC,
000164180329                                          :PHNLDC :IndLastDateC,
000165180329                                          :CSTPHN, :PHNCOM, :CSTSLN
000166180329                                     FROM BCI433LIB/CONTACTW18
000167180329                                     WHERE CSTNUM = :CSTNUM;
000168180329
000169180329                                     IF IndLastDateC = -1;
000170180329                                       CSTPHN = 'UNKNOWN DATE';
000171180329                                       NextCallDate = D'9999-09-09';
000172180329                                       PHNLDC = D'9999-09-09';
000173180329
000174180329                                     ELSE;
000175180329                                       IF IndLastDateC <> 0;
000176180329                                         CSTPHN = 'Date Problem';
000177180329                                         NextCallDate = D'9999-09-09';
000178180329                                         PHNLDC = D'9999-09-09';
000180180329                                       ENDIF;
000181180329                                     ENDIF;
000182180329
000183180329                                     SELECT;
000184180329                                       WHEN SQLSTATE = '00000';
000185180329                                         DUMMY = 0;
000186180329                                       WHEN SQLSTATE = '02000';
000187180329                                         CSTPHN = 'Not Found';
000188180329                                         NextCallDate =  D'9999-09-09';
000189180329                                         PHNLDC =  D'9999-09-09';
000190180329                                         PHNCOM = *ALL'*';
000191180329                                         CSTSLN = *ALL'*';
000192180329                                       WHEN %Subst (SQLSTATE :1 :2) = '01';
000194180329                                         NextCallDate =  D'9999-09-09';
000195180329                                         PHNLDC =  D'9999-09-09';
000196180329                                         PHNCOM = *ALL'*';
000197180329                                         CSTSLN = *ALL'*';
000198180329                                         CSTPHN = *ALL'*';
000199180329                                       OTHER;
000200180329                                         NextCallDate =  D'9999-09-09';
000201180329                                         PHNLDC =  D'9999-09-09';
000202180329                                         PHNCOM = *ALL'*';
000203180329                                         CSTSLN = *ALL'*';
000204180329                                         CSTPHN = *ALL'*';
000205180329                                     ENDSL;
000206180409                                     IF   PHNLDC = OLDESTDATE;
000207180409                                             FLAG = '<------';
000208180409                                     ELSE;
000209180409                                             FLAG = '';
000210180409                                     ENDIF;
000211180409
000212180409
000213180409
000246180329                         ENDSR ;
000247180329        //**********************************************************************
000248180329        // S U M M A R Y I N F O   S U B R O U T I N E
000249180329        //**********************************************************************
000250180329                         BEGSR  SummaryInfo;
000251180329        //  D E T E R M I N E   T O T A L S   F O R   CONTACTW18 & CUSTOMER18
000252180329                                 EXEC SQL
000253180329                                   SELECT COUNT(*) INTO :ContactTotal
000254180329                                   FROM  BCI433LIB/CONTACTW18;
000255180329
000256180329                                   IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
000257180329                                     ContactTotal = -99999;
000258180329                                   ENDIF;
000274180329        // D E T E R M I N E   N U M B E R   O F   U N K N O W N   L A S T   D A T E
000275180329       //  C A L L E D   R E C O R D S
000276180329                                 EXEC SQL
000277180329                                   SELECT COUNT(*)
000278180329                                     INTO :UnknownTotal
000279180329                                     FROM BCI433LIB/CONTACTW18
000280180329                                     WHERE CstLastCAllDate IS NULL;
000281180329
000282180329
000283180329                                   IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
000284180329                                     UnknownTotal =-99999;
000285180329                                   ENDIF;
000294180329        //  D E T E R M I N E   O L D E S T   &  M O S T   R E C E N T  L A S T
000295180329       //   C A L L B A C K   D A T E S
000296180329                                 EXEC SQL
000297180329                                   SELECT MIN(PHNLDC) INTO :OldestDate
000298180329                                     FROM BCI433LIB/CONTACTW18;
000299180329
000300180329                                   IF (SQLCODE <> 0) OR (SQLWN0 = 'W')
000301180329                                      AND (SQLWN2 <> 'W');
000304180329                                     OldestDate = D'9999-09-09';
000305180329                                   ENDIF;
000306180329
000307180329                                 EXEC SQL
000308180329                                   SELECT MAX(PHNLDC) INTO :MostRecentDate
000309180329                                     FROM BCI433LIB/CONTACTW18;
000310180329
000311180329                                   IF (SQLCODE <> 0) OR (SQLWN0 = 'W')
000312180329                                     AND (SQLWN2 <> 'W');
000313180329                                     MostRecentDate = D'9999-09-09';
000314180329                                   ENDIF;
000330180329       // D E T E R M I N E   T H E   U S E R,  S E R V E R,  &   T I M E S T A M P
000331180329                                 EXEC SQL
000332180329                                   SELECT USER, CURRENT TIMESTAMP,CURRENT SERVER
000333180329                                     INTO :User, :Timestamp, :Server
000334180329                                     FROM SYSIBM/SYSDUMMY1;
000335180329                ENDSR;
000342180329
000343180329      /END-FREE
000344180329     OQPRINT    E            HEADINGS       2 02
000345180329     O                                            5 'USER:'
000346180329     O                       USER                16
000347180329     O                                           28 'TIMESTAMP:'
000348180329     O                       TIMESTAMP           55
000349180329     O                                           64 'SERVER:'
000350180329     O                       SERVER              75
000351180329     O                                           87 'PAGE:'
000352180329     O                       PAGE                90
000353180329     O          E            HEADINGS       2
000354180329     O                                           54 'Phone Log Report'
000355180329     O                       UDATE         Y     89
000356180329     O          E            HEADINGS       1
000357180329     O                                            5 'Sales'
000358180329     O                                           15 'Customer'
000359180329     O                                           31 'Customer Name'
000360180329     O                                           59 'Telephone'
000361180329     O                                           75 'Last Call'
000362180329     O                                           88 'Oldest Call'
000363180329     O                                          101 'Next Call'
000364180329     O          E            HEADINGS       2
000365180329     O                                            3 'ID'
000366180329     O                                           13 'Number'
000367180329     O                                           73 'Date'
000368180329     O                                           85 'Date'
000369180329     O                                           98 'Date'
000370180329     O          E            DETAIL         1
000371180329     O                       CSTSLN               3
000372180329     O                       CSTNUM              13
000373180329     O                       CSTNAM              48
000374180329     O                       CSTPHN              64
000375180329     O                       PHNLDC              75
000376180329     O                       FLAG                86
000377180329     O                       NextCallDate       101
000378180329     O          E            TOTALS      2  2
000379180329     O                                           32 'Summary Information'
000380180329     O          E            TOTALS         1
000381180329     O                                           26 'CONTACTW18 Total Records:'
000382180329     O                       ContactTotal  1     34
000383180329     O          E            TOTALS         1
000384180329     O                                           26 'CUSTOMER18 Total Records:'
000385180329     O                       CustomerTotal 1     34
000386180329     O          E            TOTALS      1  1
000387180329     O                                           27 'Oldest Last Callback Date:'
000388180329     O                       OldestDate          42
000389180329     O          E            TOTALS         1
000390180329     O                                           27 'Most Recent Callback Date:'
000391180329     O                       MostRecentDate      42
000392180329     O          E            TOTALS      2  1
000393180329     O                                           22 'Total Records with an'
000394180329     O                                           47 'Unknown Last Date Called'
000395180329     O                                           62 'in CONTACTW18:'
000396180329     O                       UnknownTotal        70
