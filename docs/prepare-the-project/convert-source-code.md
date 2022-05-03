# Convert source code for use with Better Object Builder

Bob expects source code to reside on a PC/Mac as standard text files.  This enables it to be version controlled with Git and edited with standard PC code editors.  If your source code currently resides on an IBM i in source physical files, use the following information to get your code ready for use with Bob.

Copy your code to a directory on your computer in whatever fashion you'd like, as long as the code:

* is in an appropriate character encoding for your environment (we recommend UTF-8)
* has LF line endings
* has had the leading date and SEU sequence number fields removed
* has had trailing blanks removed
* has filenames ending with appropriate file extensions (`.PF`, `.CLLE`, `.RPGLE`, etc.)



---

#### **Converting with the `makei cvtsrcpf` command**

The `makei` program comes with a `cvtsrcpf` subcommand, a source code conversion tool. It will convert all members in a given source physical file to properly encoded, terminated, and named source files in an IFS directory.

By default the source files will be encoded as UTF-8, but you may use `-c` option to specify an alternate CCSID.

Before running this tool, verify that the CCSID of the source physical file is set correctly; a value of 65535 can result in an improper conversion.

[How to use `makei svtsrcpf` command](cli/makei?id=cvtsrcpf)


---

Now you have converted the source files into an IFS directory. Make sure put them in a Bob project after conversion. You will need some special files to enable Bob. This is fully described in [Project metadata](project-metadata) and [Create a New Project](prepare-the-project/create-a-new-project).
