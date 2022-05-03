# .ibmi.json

> [!NOTE]
>
> Specifics of directory level metadata

* The attributes specified in iproj.json hold true for all subdirectories by default
* If a subdirectory wants to override the object library or target CCSID, they can use the .ibmi.json  file in that subdirectory
* A .ibmi.json file can occur in any directory within a project including the root.  It specifies which OBJLIB and TGTCCSID should be used when compiling the source within this directory
* For each source stream file we don’t need the following
  * Member source type can be derived from file extension, i.e. name.rpgle
  * Target object type can be derived from the extension prefix if it is not the default.  I.e. the default for RPGLE members is to be compiled to MODULES but if they are compiled to PGM then the name becomes name.pgm.rpgle
    Or name.srvpgm.sqlrpgle
  * Member text can be specified on the IFS files as OBJATR – however they cannot be specified in the linux or Windows files systems nor can it be stored in git.  It can be specified in long names of the form `<objname>-<descriptive text>.<membertype>`  i.e. `MYMOD-Module_containing_cool_stuff.rpgle`
  * However this long name will affect include references in source and some developers may object to the name being changed, so it can be stored in a special comment beginning with %TEXT in the first 20 lines of the source

## Configuration Options

### build

#### build.objlib

specifies the name of the environment variable containing the name of the target library in which to build objects.  This is optional and if not specified, the value of parent directory .ibmi.json are used. If none of those are specified, the iproj.json objlib attribute is used.  If no objlib is specified in the parent directories then the *CURLIB of the job is used.  If the *CURLIB is desired, then an explicit value of `*CURLIB` should be used.

#### build.tgtCcsid

specifies the target EBCDIC CCSID for compilers to use as TGTCCSID

## Example of the .ibmi.json file

```json
{
    "version":"0.0.1",
    "build": {
            "objlib":"&L01",
            "tgtCcsid":"*JOB"
    } 
}
```

The objlib is a variable L01 that can be set at build time. This allows different directories to compile into different object libraries.
The EBCDIC CCSID that the source will be compiled in will be the CCSID of the current JOB.



## Schema for .ibmi.json

```json
{
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "object",
    "properties": {
        "version": {
            "type": "string",
            "description": "version of this file format, used for migration purposes "
        },
        "build": {
            "type": "object",
            "description": "Build settings for all streams files compiled from the current directory",
            "properties": {
                "objlib": {
                    "type": "string",
                    "description": "Objects created by building source in this directory will be put into the `OBJLIB` library.\n - If not specified, `*CURLIB` is used as the `OBJLIB`.",
                    "markdownDescription": "Objects created by building source in this directory will be put into the `OBJLIB` library.\n - If not specified, `*CURLIB` is used as the `OBJLIB`."
                },
                "tgtCcsid": {
                    "type": "string",
                    "description": "The value of the `TGTCCSID` to be used when compiling source in this directory.\n - If not specified, `*JOB` is used as the `TGTCCSID`.",
                    "markdownDescription": "The value of the `TGTCCSID` to be used when compiling source in this directory.\n - If not specified, `*JOB` is used as the `TGTCCSID`."
                }
            },
            "defaultSnippets": [
                {
                    "label": "build",
                    "description": "Build options",
                    "body": {
                        "objlib": "$1",
                        "tgtCcsid": "^${2:*JOB}"
                    }
                }
            ]
        }
    },
    "required": [
        "version",
        "build"
    ]
}
```

