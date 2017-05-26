      *********************************************************************
      *                 Better Object Builder
      *
      * Copyright 2017 S4i Systems, Inc.
      *
      * Module       : TEST010
      * Written By   : Jeff Berman
      * Date Written : 05/25/17
      *
      * Description:
      * ------------
      * Read and print some names.
      *
      *****************************************************************
      * Modification History
      *
      * Init   Task ID    Date       Description
      * ----   --------   --------   -----------
      *****************************************************************

     ftest01a   if   e           k disk

      *================== Field definitions ===========================
     d response        s             10

      *========================= Mainline =============================

     c                   dou       %eof(test01a)
     c                   read      test01a
     c                   if        not %eof
     c     first         dsply(e)
     c                   endif
     c                   enddo

     c                   dsply(e)                response

     c                   eval      *inlr = *on
     c                   return
