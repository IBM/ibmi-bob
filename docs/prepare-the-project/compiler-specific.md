# How source is compiled from the IFS

| Language    | Compile from IFS                | Specify EBCDIC encoding |
| :---------- | :------------------------------ | :---------------------- |
| ILE RPG     | SRCSTMF() <sup>[1](#fn1)</sup> | TGTCCSID() <sup>[2](#fn2)</sup> |
| ILE C/CPP   | SRCSTMF() <sup>[1](#fn1)</sup> | TGTCCSID() <sup>[2](#fn2)</sup> |
| ILE COBOL   | SRCSTMF() <sup>[1](#fn1)</sup> | TGTCCSID() <sup>[3](#fn3)</sup> |
| ILE CL      | limited to CRTFRMSTMF <sup>[5](#fn5)</sup> | CRTFRMSTMF -ccsid <sup>[4](#fn4)</sup> |
| BND         | SRCSTMF() <sup>[1](#fn1)</sup> | n/a no national chars |
| SQL         | RUNSQLSTM SRCSTMF() | UTF8 is supported |
| OPM, DDS, PNLGRP, MENU, CMD   | CRTFRMSTMF <sup>[4](#fn4)</sup> | CRTFRMSTMF -ccsid <sup>[4](#fn4)</sup> |

The value for the EBCDIC CCSID used to compile is derived from the [.ibmi.json](prepare-the-project/ibmi-json.md) `tgtCcsid` attribute.  This can be overridden at every directory level and if not overridden it derives its value from the parent directory.  If not specified at all it will be the `TGTCCSID(*JOB)` value where it takes the CCSID of the job.

<a name="fn1">1</a> Modern ILE compilers support the `SRCSTMF(ifs/path)` parameter to compile directly from the 
IFS file system.  There are not issues with line length etc.

<a name="fn2">2</a>: Modern compilers support the `TGTCCSID(ebcdic-ccsid)` parameter to specify the CCSID that the UTF-8 IFS source should be transformed to before compiling. 

<a name="fn3">3</a>: COBOL TGTCCSID() parameter was recently added.  You may have to install PTFs to get this support. 

7.3:
- The ILE COBOL command processing program for CRTBNDCBL and CRTCBLMOD: 5770WDS SI81472
- ILE COBOL compiler: 5770WDS SI81475
- ILE COBOL commands CRTBNDCBL and CRTCBLMOD: 5770WDS SI81473

7.4: TR8 or
- The ILE COBOL command processing program for CRTBNDCBL and CRTCBLMOD: 5770WDS SI81006
- ILE COBOL compiler: 5770WDS SI81553
- ILE COBOL commands CRTBNDCBL and CRTCBLMOD: 5770WDS SI81023

7.5: TR2 or 
- The ILE COBOL command processing program for CRTBNDCBL and CRTCBLMOD: 5770WDS SI81047
- ILE COBOL compiler: 5770WDS SI81048
- ILE COBOL commands CRTBNDCBL and CRTCBLMOD: 5770WDS SI81049

Otherwise the compile will fail because the TGTCCSID parameter will not be recognized.

<a name="fn4">4</a>:
`crtfmrstmf` copies the stream file to a source member in SRC-PF create in QTEMP.  The `-ccsid` parameter specifies the encoding for that SRC-PF.  However it is important that the job running the compile is able to read that encoding without losing any characters.  Note that this is no different than compiling from a QSYS member.

<a name="fn5">5</a> CL has the `SRCSTMF` parameter but not the `TGTCCSID` parameter.  In order to support national characters in CL, BOB has elected to use the `crtfrmstmf` support.

