ARTICLE.FILE:  ARTICLE-Article_File.PF \
  SAMREF.FILE
ART301D.FILE:  ART301D-Function_Select_an_article.DSPF\
  ARTICLE.FILE VATDEF.FILE
ART301D.FILE: DFRWRT = *NO
ART301D.FILE: ENHDSP = *NO

DETORD.FILE:  DETORD.PF SAMREF.FILE
ORD500O.FILE: ORD500O.PRTF ORDER.FILE CUSTOMER.FILE \
  DETORD.FILE ARTICLE.FILE
TMPDETORD.FILE: 	
 	system -i "CPYF FROMFILE($(OBJLIB)/DETORD) TOFILE($(OBJLIB)/TMPDETORD) \ 
	CRTFILE(*YES)"