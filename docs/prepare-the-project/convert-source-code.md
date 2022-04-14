# Convert source code for use with Better Object Builder

Bob expects source code to reside on a PC/Mac as standard text files.  This enables it to be version controlled with Git and edited with standard PC code editors.  If your source code currently resides on an IBM i in source physical files, use the following information to get your code ready for use with Bob.

Copy your code to a directory on your computer in whatever fashion you'd like, as long as the code:

* is in an appropriate character encoding for your environment (we recommend UTF-8)
* has LF line endings
* has had the leading date and SEU sequence number fields removed
* has had trailing blanks removed
* has filenames ending with appropriate file extensions (`.PF`, `.CLLE`, `.RPGLE`, etc.)

## Convert to a Bob project
Bob expects a special file called `iproj.json` at the root of the set of files you want to build.  This is fully described in [Project metadata](project-metadata)
All you need is the presence of this file with 
## Converting with the CVTSRCF command

When Bob was installed on the IBM i, a source code conversion tool was placed into the BOBTOOLS library: command CVTSRCF.  It will convert all members in a given source physical file to properly encoded, terminated, and named source files in an IFS directory.  By default the source files will be encoded as UTF-8, but pressing F10 on the command prompt will reveal a parameter to specify an alternate CCSID. Before running this tool, verify that the CCSID of the source physical file is set correctly; a value of 65535 can result in an improper conversion.

CVTSRCF is an ILE front end to the shell script `cvtsrcpf` in the Bob installation directory (typically `/Build/Bob`). If you wish to use the script directly, type `/Build/Bob/cvtsrcpf --help` from a shell terminal for instructions.

To convert:

1. On the IBM i, type `BOBTOOLS/CVTSRCF` and press `F4` to prompt the command.
1. Enter the source physical file name and library, and the directory in which to place the converted source files.
1. Optionally, press `F10` to reveal advanced parameters, and specify a target CCSID, such as 1252 for Windows Latin-1, 819 for ISO-8859-1, or whatever encoding is correct for your environment.
1. When the conversion has completed, copy the directory to your PC so that it can be [defined](Prepare-project) to RDi as a project.

## Converting with RDi

RDi is no longer recommended as a way to convert source members to PC source files. We have seen cases where conversion errors occur, likely due to CCSID issues, both when converting to an IFS directory and when converting directly to a PC/Mac file system. For now, Better Object Builder's CVTSRCF command is the recommended conversion tool.