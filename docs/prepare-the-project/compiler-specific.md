# How source is compiled from the IFS

| Language    | Compile from IFS  | Specify EBCDIC encoding |
| :---------- | :---------------- | :---------------------- |
| ILE RPG     | SRCSTMF()  [^fn1] | TGTCCSID() [~fn2]       |
| ILE C/CPP   | SRCSTMF()  [^fn1] | TGTCCSID() [~fn2]       |
| ILE COBOL   | SRCSTMF()  [^fn1] | TGTCCSID() [^fn3] |
| ILE CL      | limited to CRTFRMSTMF  [^fn5]  | CRTFRMSTMF -ccsid [^fn4] |
| OPM, DDS, PNLGRP     | CRTFRMSTMF  [^fn4]       | CRTFRMSTMF -ccsid |

The value for the EBCDIC CCSID used to compile is derived from the [.ibmi.json](prepare-the-project/ibmi-json.md) `tgtCcsid` attribute.  This can be overridden at every directory level and if not overridden it derives its value from the parent directory.  If not specified at all it will be the `TGTCCSID(*JOB)` value where it takes the CCSID of the job.

[^fn1]: Modern ILE compilers support the `SRCSTMF(ifs/path)` parameter to compile directly from the 
IFS file system.  There are not issues with line length etc.

[^fn2]: Modern compilers support the `TGTCCSID(ebcdic-ccsid)` parameter to specify the CCSID that the UTF-8 IFS source should be transformed to before compiling. 

[^fn3]: COBOL TGTCCSID() parameter was recently added.  You will require TR2 in V7R5, or TR8 in V7R4 to get this support. Otherwise the copmile will fail because the TGTCCSID parameter will not be recognized.

[^fn4]:
`crtfmrstmf` copies the stream file to a source member in SRC-PF create in QTEMP.  The `-ccsid` parameter specifies the encoding for that SRC-PF.  However it is important that the job running the compile is able to read that encoding without losing any characters.  Note that this is no different than compiling from a QSYS member.

[^fn5]: CL has the `SRCSTMF` parameter but not the `TGTCCSID` parameter.  In order to support national characters in CL, BOB has elected to use the `crtfrmstmf` support.

