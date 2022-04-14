# iproj.json

?> Specifics of bob's project level metadata

* The project will be referred to by its relative path
* This metadata is specified in a iproj.json file in the root directory of the project
* Even an empty iproj.json file will mark a directory as a project.  
* Projects cannot be nested, only the ancestor directory containing the iproj.json will be considered a project

## Configuration Options

### version

version of this file format, used for migration purposes 

### description

Description of project

### includePath

array of include directories to search (can contain references to named directories)

* For build directories of other projects we could use some special syntax like ${project:payroll:buildDir} and ${project:payroll:includePath} which can also be included (Not yet in used)

### objlib 

Name of library for compiled object (if not specified defaults to *CURLIB)

### tgtccsid

Target CCSID (if not specified defaults to JOB CCSID)

### preUsrlibl

Libraries to add before USRLIBL (can contain references to named libraries)

### postUsrlib

Libraries to add after USRLIBL (can contain references to named libraries)

### curlib

connection will have that set as its CURLIB in the LIBL.  Note that if objlib is not specified, then this will also serve as the objlib

### setIBMiEnvCmd

array of CL to run when the Rest Portal or Build job begins.  This can include ADDENVVAR, OVRxxx. SETASPGRP etc.

### buildCommand

!> Not yet in use

PASE command line used to build this entire project.  The following substitution variables are supported:

* {filename} resolves to the base file name being edited.
* {path} resolves to the full IFS path corresponding to the source in the editor.
* {host} resolves to the IBM i hostname.
* {usrprf} the user profile that the command will be executed under.
* {branch} resolves to the name of the current git branch if this project is managed by git.

### compileCommand

!> Not yet in use

PASE command line used to compile a specific source file in this project. The same substitution parameters as in the buildCommand are supported.

### repository

git repository

### license

license for this project

### extensions

any software vendor can extend the metadata with attributes that are useful to the functionality they provide 

### uses

!> Not yet in use

prerequisite projects (note that 2 projects might use each other and infinite loops need to be avoided)

* Include path will be appended to
* Large companies may have multiple versions of the project at different levels (core, regional, country, district).  These versions can be at distinct levels (tag in  git)
* library list adjusted from pre-requisite projects 
* Project-name$tag:tag-value
  * I.e. acme/core$tag:1.53

### installProjectScript

!> Not yet in use

shell script that will be run in synchronized buildDir to do one-time setup of the IBM i.  This could include creating libraries and compiling CL programs for setup and build.

## Example of the iproj.json file

In this example we have a project with the description of Payroll application for ACME which has a variable named accounting whose value is used for the object library and the is set as CURLIB and which appears at the beginning of the USRLIBL followed by ACMEUTIL. The library whose name is the value of the variable tax is at the end of the USER portion of the LIBL.  Include files are searched for in the the subdirectory prototypes.   To initialize the environment, the SETUP program in the &accounting library name is called.  ARCAD tooling is storing an additional attribute for the libraryPrefix which their tooling uses. 

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



## Schema for iproj.json

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

### 