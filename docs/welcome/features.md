# Better Object Builder features

Some of the major benefits of using a Better Object Builder / Git / RDi development environment are:

* Consistent, repeatable software builds
* At-a-glance version history
* Easily examine code from any point in time
* Easily compare code changes between any two points in time
* Flexible source code version control to fit any development workflow
* Git and Make are ubiquitous; volumes of documentation and help exist
* Automated builds are possible
* Speedy delta builds -- only new and changed code (and code dependent on the changed code) is compiled
* Fast transfer of source files from PC to IBM i
* One-button builds
* Open source.  Free to use and free to modify.

Obviously, we think Bob is pretty great.  But, in fairness, there are some challenges to be aware of:

* Learning curve -- Git and Make are amazing but can also be quite complex.  Fortunately, the vast wealth of online information will help you recover from any mistake.
* Installation -- Installing the IBM i prerequisites used to be daunting but has been reduced to a single rpm command
* PASE -- Since Git (if installed on the IBM i) and Make run in PASE, some familiarity with a Unix-like shell is helpful.  It may be a little outside your comfort zone, but it is a tremendous skill to have.  We have performed search-and-replace instructions on thousands of source files using Sed and regular expressions in mere seconds, and used Grep to almost instantly discover every source file using a specific physical file.
* At its current stage in development, changes to service programs and files result in rebuilds of everything using them.  This is to avoid signature violations and level checks.  This will be addressed in a future version of Bob.

## Supported object types

These IBM i source types can be compiled directly from the IFS

| Object Type | File Extension                                                        |
| :---------- | :-------------------------------------------------------------------- |
| *CMD        | .CMDSRC                                                               |
| *MODULE     | .RPGLE, .CLLE, .C, .SQLC, .CPP, .SQLCPP, .SQLRPGLE, .CBLLE, .SQLCBLLE |
| *PGM        | .PGM.RPGLE, .PGM.SQLRPGLE, .PGM.C, .PGM.CBLLE, .PGM.SQLCBLLE          |
| *SRVPGM     | .BND                                                                  |

Note:

* to make it unambiguous whether a source file is to be compiled into a PGM or MODULE, the PGM source has .PGM.<srctype> as its file extension
* it is very easy to build SRVPGM using binder source.  Simply have a rule like
  * CUSTOMER.SRVPGM: $(d)/CUSTOMER.BND A.MODULE B.MODULE


These older IBM i source types are compiled directly from the IFS using the CRTFRMSTMF open source project that copies the source to QTEMP/QSOURCE before compiling and then fixes the EVENTF members to point to the original IFS source

| Object Type | File Extension                      |
| :---------- | :---------------------------------- |
| *FILE       | .DSPF, .LF, .PF, .PRTF              |
| *MENU       | .MENU                               |
| *MODULE     | .CLLE                               |
| *PGM        | .RPG, .PGM.CLLE                     |
| *PNLGRP     | .PNLGRPSRC                          |
| *WSCST      | .WSCSTSRC                           |
| *QMQRY      | .SQL                                |

Note:

* OPM COBOL .CBL cannot be supported because the OPM COBOL compiler calls RCLRSC which cannot be run from PASE

## Support CL pseudo-source

The following object types are supported as pseudo-source.  
The CL command to create the object is stored in a file with the given extension.  
Note that for *MSGF and *BNDDIR, the CL commands should include the delete of the MSGF and BNDDIR before creating the new one in order to avoid the timestamp getting old and breaking the make processing.

| Object Type | File Extension | CL Command        |
| :---------- | :------------- | :---------------- |
| *MSGF       | .MSGF          | CRTMSGF + ADDMSGD |
| *BNDDIR     | .BNDDIR        | CRTBNDDIR         |
| *PGM        | .ILEPGM        | CRTPGM            |
| *SRVPGM     | .ILESRVPGM     | CRTSRVPGM         |
| *DTAARA     | .DTAARA        | CRTDTAARA         |
| *DTAQ       | .DTAQ          | CRTDTAQ           |
| *TRG        | .SYSTRG        | ADDPFTRG          |

Note:

* this provides a second way of creating programs and service programs using the .ILEPGM and .ILESRVPGM file types.  This gives a high degree of customization in that you can specify any and all parameters on the command and even additional commands.  But it is more work than the simple dependency line needed when building from binder source.

## Support SQL pseudo-source

The following SQL types are supported as pseudo-source.
The set of SQL commands to create the object is stored in a file with the given extension. Typically it is just the CREATE OR REPLACE command, but for example for TABLE, you would also want to include any ALTER TABLE commands as well.  Other ancillary commands needed to complete creation like LABEL ON should also be in the same source file. 

| SQL Type  | QSYS Object | File Extension | SQL COMMAND                 |
| :-------- | :---------- | :------------- | :-------------------------- |
| TABLE     | *FILE       | .TABLE         | CREATE OR REPLACE TABLE     |
| VIEW      | *FILE       | .VIEW          | CREATE OR REPLACE VIEW      |
| PROCEDURE | *PGM        | .SQLPRC        | CREATE OR REPLACE PROCEDURE |
| FUNCTION  | *SRVPGM     | .SQLUDF        | CREATE OR REPLACE FUNCTION  |
| FUNCTION  | *SRVPGM     | .SQLUDT        | CREATE DISTINCT TYPE        |
| TRIGGER   | *PGM        | .SQLTRG        | CREATE OR REPLACE TRIGGER   |
| ALIAS     | *FILE       | .SQLALIAS      | CREATE OR REPLACE ALIAS     |
| SEQUENCE  | *DTAARA     | .SQLSEQ        | CREATE OR REPLACE SEQUENCE  |

Generic SQL statements with file extension .SQL are executed using RUNSQLSTM