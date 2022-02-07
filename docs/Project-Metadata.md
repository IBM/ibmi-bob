# Metadata for IBM i project

## Vision

The IBM i projects will self-describe how to build themselves as much as possible.  The Project needs to know how to get source from stream files in a directory hierarchy in a project presumably managed by git, into the IBM i and compiled with all attributes intact.  The final goal is that a Git project can contain all the information to build a working application.  I.e. a git hook can trigger the cloning, building, and deploying of a project without any additional dependencies on a target IBM i.

## Technical Assumptions

* Metadata will be stored in JSON because:
  * JSON is the most popular persistence mechanism because it is lightweight and easily derstood by both humans and computers
  * JSON is native any node.js based platform and has readily available tooling in all others
* All third parties should generate/use the common metadata. Third-parties can store additional metadata in additional JSON within the same file.
* Places to store information
  * Project level json – in the root directory of the project - iproj.json (analogous to package.json) – could be used for storing name of project, version information, dependencies, git repo, description, license  AND IBM i attributes like target object library, target CCSID, LIBL, initial CL and include directories
(part of the vision to make an IBM i package manager that is still in progress)
  * Directory level json - .ibmi.json in each directory allows overriding of target library and CCSID in  for that directory and its sub-directories.
  * Comments  in the code itself

### Attributes stored

#### For a user/workspace

Information for a project that will vary per deployment and so should not be hardcoded in the project.  

* Hostname/ip address
* Userid
* (note that the password or private key is stored in a secure location depending on the development platform)
* IFS build directory
* Variables (can be used to name libraries for the object library or library list, or directories for the include path).  This allows the same project definition to target a different build library from one developer to another.  It would also allow Bob to be used in CI/CD pipelines.  Before invoke a Bob build, an environment variable should be set with the same name as the Bob variable and with the desired value for that build.  So if the iproj.json said to use &objlib1 for the OBJLIB for compiles within a directory and the PASE command `export objlib1=PROJ_QA1` is run,  then the environment variable objlib1 would be set to “PROJ_QA” before invoking the build command.  Within the build shell script the value could be referenced via &objlib1.  Similarly the CI/CD mechanisms can set up  directories and object libraries using the exact same environment variable names. 
* Tooling like RDi might provide a UI to edit these values.

#### For a project

* The project will be referred to by its relative path
* This metadata is specified in a iproj.json file in the root directory of the project
* Even an empty iproj.json file will mark a directory as a project.  
* Projects cannot be nested, only the ancestor directory containing the iproj.json will be considered a project
* Attributes
  * version – version of this file format, used for migration purposes 
  * description - Description of project
  * includePath – array of include directories to search (can contain references to named directories)
    * For build directories of other projects we could use some special syntax like ${project:payroll:buildDir} and ${project:payroll:includePath} which can also be included (Not yet in used)
  * objlib - Name of library for compiled object (if not specified defaults to *CURLIB)
  * tgtccsid - Target CCSID (if not specified defaults to JOB CCSID)
  * preUsrlibl - Libraries to add before USRLIBL (can contain references to named libraries)
  * postUsrlibl - Libraries to add after USRLIBL (can contain references to named libraries)
  * curlib - connection will have that set as its CURLIB in the LIBL.  Note that if objlib is not specified, then this will also serve as the objlib
  * setIBMiEnvCmd – array of CL to run when the Rest Portal or Build job begins.  This can include ADDENVVAR, OVRxxx. SETASPGRP etc.
  * buildCommand- PASE command line used to build this entire project.  The following substitution variables are supported:
    * {filename} resolves to the base file name being edited.
    * {path} resolves to the full IFS path corresponding to the source in the editor.
    * {host} resolves to the IBM i hostname.
    * {usrprf} the user profile that the command will be executed under.
    * {branch} resolves to the name of the current git branch if this project is managed by git.
  * compileCommand - PASE command line used to compile a specific source file in this project. The same substitution parameters as in the buildCommand are supported.
  * repository  - git repository
  * license – license for this project
  * extensions – any software vendor can extend the metadata with attributes that are useful to the functionality they provide 
  * uses – (not yet in use): prerequisite projects (note that 2 projects might use each other and infinite loops need to be avoided)
    * Include path will be appended to
    * Large companies may have multiple versions of the project at different levels (core, regional, country, district).  These versions can be at distinct levels (tag in  git)
    * library list adjusted from pre-requisite projects 
    * Project-name$tag:tag-value
      * I.e. acme/core$tag:1.53
  * installProjectScript – (not yet in use): shell script that will be run in synchronized buildDir to do one-time setup of the IBM i.  This could include creating libraries and compiling CL programs for setup and build.

##### Example iproj.json
In this example we have a project with the description of Payroll application for ACME which has a variable named accounting whose value is used for the object library and the is set as CURLIB and which appears at the beginning of the USRLIBL followed by ACMEUTIL.  The library whose name is the value of the variable tax is at the end of the USER portion of the LIBL.  Include files are searched for in the the subdirectory prototypes.   To initialize the environment, the SETUP program in the &accounting library name is called.  ARCAD tooling is storing an additional attribute for the libraryPrefix which their tooling uses. 
```json
 {
    "version": "0.0.1",
    "description": "Payroll application for ACME",
    "objlib": "&accounting",
    "curlib": "&accounting",
    "includePath": ["prototypes"],
    "preUsrlibl": "&accounting, ACMEUTIL",
    "postUsrlibl": "&tax",
    "setIBMiEnvCmd": ["CALL &accounting/SETUP"],
    "repository" : "https://github.com/acme/backoffice",
    "extensions": {
        "arcad": {
            "libraryPrefix": "ARC"
        }
    }
}
```

##### Here is the schema for the iproj.json file

```json
{
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "object",
    "properties": {
        "description": {
            "type": "string",
            "description": "Descriptive application name"
        },
        "version": {
            "type": "string",
            "description": "version of this file format, used for migration purposes "
        },
        "includePath": {
            "type": "array",
            "description": "directories to be searched for includes/copy file (can contain variable references)",
            "items": {    
                "type": "string"
            }
        },
        "repository": {
            "type": "string",
            "description": "URL of repository of this projects home"
        },
        "objlib": {
            "type": "string",
            "description": "target library for compiled objects (if not specified defaults to *CURLIB)"
        },
        "curlib": {
            "type": "string",
            "description": "library that is CURLIB in the LIBL for project's connection.  Note that if objlib is not specified, then this will also serve as the objlib"
        },
        "preUsrlibl": {
            "type": "array",
            "description": "libraries to add at the beginning of the user portion of the LIBL (can contain references to named libraries)",
            "items": {    
                "type": "string"
            }
        },
        "postUsrlibl": {
            "type": "array",
            "description": "libraries to add at the end of the user portion of the LIBL (can contain references to named libraries)",
            "items": {    
                "type": "string"
            }
        },
        "license": {
            "type": "string",
            "description": "licensing terms for this project"
        },
        "setIBMiEnvCmd": {
            "type": "array",
            "description": "list of CL commands to be executed whenever this project connects to the IBM i.  Typically this involves LIBL, ENVVAR and iASP setup.",
            "items": {    
                "type": "string"
            }
        },
        "buildCommand": {
            "type": "string",
            "description": "PASE command line used to build this entire project.  The following substitution variables are supported:\n {filename} resolves to the base file name being edited.\n {path} resolves to the full IFS path corresponding to the source in the editor.\n {host} resolves to the IBM i hostname.\n {usrprf} the user profile that the command will be executed under.\n {branch} resolves to the name of the current git branch if this project is managed by git."
        },
        "compileCommand": {
            "type": "string",
            "description": "PASE command line used to compile a specific source file in this project. The following substitution variables are supported:\n {filename} resolves to the base file name being edited.\n {path} resolves to the full IFS path corresponding to the source in the editor.\n {host} resolves to the IBM i hostname.\n {usrprf} the user profile that the command will be executed under.\n {branch} resolves to the name of the current git branch if this project is managed by git."
        },

        "extensions": {
            "type": "object",
            "description": "attributes used by external software vendors to provide additional functionality",
            "items": {
                "type": "object"
            }
        }
    }
 }
```

### Directory level metadata

* The attributes specified in iproj.json hold true for all subdirectories by default
* If a subdirectory wants to override the object library or target CCSID, they can use the .ibmi.json  file in that subdirectory
* A .ibmi.json file can occur in any directory within a project including the root.  It specifies which OBJLIB and TGTCCSID should be used when compiling the source within this directory
  * objlib specifies the name of the environment variable containing the name of the target library in which to build objects.  This is optional and if not specified, the value of parent directory .ibmi.json are used. If none of those are specified, the iproj.json objlib attribute is used.  If no objlib is specified in the parent directories then the *CURLIB of the job is used.  If the *CURLIB is desired, then an explicity value of `*CURLIB` should be used.
  * tgtCcsid specifies the target EBCDIC CCSID for compilers to use as TGTCCSID
  * For each source stream file we don’t need the following
    * Member source type can be derived from file extension, i.e. name.rpgle
    * Target object type can be derived from the extension prefix if it is not the default.  I.e. the default for RPGLE members is to be compiled to MODULES but if they are compiled to PGM then the name becomes name.pgm.rpgle
Or name.srvpgm.sqlrpgle
    * Member text can be specified on the IFS files as OBJATR – however they cannot be specified in the linux or Windows files systems nor can it be stored in git.  It can be specified in long names of the form `<objname> - <descriptive text>.<membertype>`  i.e. MYMOD-Module_containing_cool_stuff.rpgle
    * However this long name will affect include references in source and some customers may object to it in the name, so it can be stored in a special comment beginning with %TEXT in the first 20 lines of the source

Here is an example of the .ibmi.json file
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

Below is the schema for the .ibmi.json file.

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
