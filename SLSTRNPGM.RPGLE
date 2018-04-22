000100180322     FSALESTRANSIF   E             DISK    RENAME(SALESTRANS:SALESTRANR)
000101180322     FSALESSTAF2UF A E           K DISK
000102180322     FQPRINT    O    F  132        PRINTER OFLIND(*INOF)
000103180322     D SALESTRANSDS    DS
000104180322     D   TDEPT
000105180322     D   TSALESID
000106180322     D   TFNAME
000107180322     D   TLNAME
000108180322     D   TCITY
000109180322     D   TADDRESS
000110180322     D   TPCODE
000111180322     D SALESSTAF2DS    DS
000112180322     D    DEPT
000113180322     D    SALESID
000114180322     D    FNAME
000115180322     D    LNAME
000116180322     D    CITY
000117180322     D    ADDRESS
000118180322     D    PCODE
000119180322     D FullKey         DS                  LikeRec(SALESTFR: *Key)
000120180322     C/FREE
000121180322                   EXCEPT HEADINGS;
000122180322                   READ   SALESTRANS;
000123180322                   DOW NOT %EOF;
000124180326                     FULLKEY = TDEPT + TSALESID;
000125180326                     CHAIN %KDS(FULLKEY) SALESSTAF2;
000126180322
000127180322
000128180322                      SELECT;
000129180322                        WHEN %FOUND(SALESSTAF2);
000130180322                        SELECT;
000131180322                           WHEN TCODE = 'C';
000132180322                              EXSR CHGREC;
000133180322                           WHEN TCODE = 'D';
000134180322                              EXSR DELREC;
000135180322                           OTHER;
000136180322                              EXSR ERROR;
000137180322                        ENDSL;
000138180322                        WHEN NOT %FOUND(SALESSTAF2);
000139180322                           IF TCODE = 'A';
000140180322                              EXSR ADDREC;
000141180322                           ELSE;
000142180322                              EXSR ERROR;
000143180322                           ENDIF;
000144180322                        WHEN %ERROR;
000145180322                              EXSR ERROR;
000146180322                        ENDSL;
000147180322                        EXCEPT DETAIL;
000148180322                        READ SALESTRANS;
000149180322                   ENDDO;
000150180322                   *INLR = *ON;
000151180322                   RETURN;
000152180322         BEGSR  ADDREC;
000153180326                   SALESSTAF2DS = SALESTRANSDS;
000154180326                   Phone = %Dec(TPhone:10:0);
000155180322                   WRITE SALESTFR;
000156180322         ENDSR;
000157180322         BEGSR  CHGREC;
000158180322                   SALESSTAF2DS = SALESTRANSDS;
000159180322                   Phone        = %Dec(TPhone:10:0);
000160180322                   UPDATE SALESTFR;
000161180322         ENDSR;
000162180322         BEGSR  DELREC;
000163180322                   DELETE SALESTFR;
000164180322         ENDSR;
000165180322         BEGSR  ERROR;
000166180322                   TFNAME = 'UPDATE/DELETE/CHANGE';
000167180322                   TLNAME = 'E R R O R';
000168180322         ENDSR;
000169180322      /END-FREE
000170180322     OQPRINT    E            HEADINGS       2 02
000171180322     O                                            8 'PAGE'
000172180322     O                       PAGE                13
000173180322     O                                           50 'SALESSTAFF UPDATE'
000174180322     O                                           64 'DATE'
000175180322     O                       UDATE         Y     73
000176180322     O          E            HEADINGS       1
000177180322     O                                            4 'CODE'
000178180322     O                                           10 'DEPT'
000179180322     O                                           14 'ID'
000180180322     O                                           28 'FIRST NAME'
000181180322     O                                           49 'LAST NAME'
000182180322     O                                           66 'CITY'
000183180322     O                                           91 'ADDRESS'
000184180322     O                                          113 'PHONE'
000185180322     O                                          125 'POSTAL'
000186180322     O          E            HEADINGS       2
000187180322     O                                          124 'CODE'
000188180322     O          E            DETAIL         1
000189180322     O                       TCODE                2
000190180322     O                       TDEPT                9
000191180322     O                       TSALESID            15
000192180322     O                       TFNAME              38
000193180322     O                       TLNAME              60
000194180322     O                       TCITY               82
000195180322     O                       TADDRESS           102
000196180322     O                       TPHONE             116
000197180322     O                       TPCODE             125
