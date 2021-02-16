**free
//********************************************************************
//                 Better Object Builder
//
// Copyright 2017 S4i Systems, Inc.
//
// Module       : TEST010
// Written By   : Jeff Berman
// Date Written : 05/25/17
//
// Description:
// ------------
// Read and print some names.
//
//****************************************************************
// Modification History
//
// Init   Task ID    Date       Description
// ----   --------   --------   -----------
//****************************************************************

dcl-f test01a disk keyed;

//================== Field definitions ===========================
dcl-s response  char(10);

//========================= Mainline =============================
dou       %eof(test01a);
    read      test01a;
    if        not %eof;
    dsply(e) first;
    endif;
enddo

dsply(e)                response

*inlr = *on
return;
