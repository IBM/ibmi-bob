# Defining Targets using Rules.mk

> [!NOTE]
>
> This page documents how to create a `Rules.mk`, which is a text file that tells Bob how your project structured and what the objects are.

## Overview

Better Object Builder uses GNU Make to determine what code needs to be compiled. Make takes as input a _makefile_, which tells it what objects should be compiled, what source code they need, and what other objects they are dependent on. In Bob, we will reuse a common Makefile in the Bob directory which reads the `Rules.mk` files dynamatically in the project.

By itself, Make has no concept of ILE objects, and doesn't know how to compile an RPG module or bind together a service program.  Better Object Builder provides that functionality in the makefile `def_rules.mk`,  which contains all the special instructions for building various types of IBM i objects. That way, when your `Rules.mk` says "build module XY1001 from source file XY1001.RPGLE", Make will know how to do that.

Each of your projects will have its own sets of `Rules.mk` files to specific that project's objects.

## Rules.mk layout

The `Rules.mk` consists of three sections:

- Subdir declaration
- An _object list_ area where you specify each object that should get built
- A _rules_ area that defines dependency information and custom compile settings for each object

## Creating the Rules.mk

> [!TIP]
>
> You are about to create a `Rules.mk` to describe the objects Bob should build.  If a project directory doesn't yet exist, [create one](prepare-the-project/create-a-new-project) now.

Create a new `Rules.mk` in your project directory.  Open it in any text editor.

### Subdir declaration

In this optional section, you may declare that one or more subdirectories is also part of this project and they may contain some objects to build.

For example:

```makefile
SUBDIRS = functionsVAT QDDSSRC QDTASRC QPNLSRC QCLSRC QMSGSRC QRPGSRC QRPGLESRC QCBLSRC QSRVSRC QILESRVSRC QBNDSRC QILESRC QCMDSRC QSQLSRC
```

This line at the project root directory will tell Bob to build all the subdirectories under the [bob-recursive-example](https://github.com/edmundreinhardt/bob-recursive-example).

### Object List section

The object list section is where you list out each object Bob should build, grouped by object type and separated by spaces.  Object names should be specified as they appear in the Integrated File System (IFS), so program names end in `.PGM`, files end in `.FILE`, etc.  All object names should be in upper case.  For ease of maintenance, it is recommended that the objects are listed alphabetically.  Here's an example of part of an object list section:

```makefile
PFs := VATDEF.FILE

MODULEs := VAT300.MODULE

SRVPGMs := FVAT.SRVPGM
```

In this example, Make is told that one file should be built (one PFs), one module, and one service program.  We haven't yet told it _how_ to build these objects, only that they exist and should be built.

The object types should be one of the followings:  `TRGs` `DTAs` `SQLs` `BNDDs` `PFs` `LFs` `DSPFs` `PRTFs` `CMDs` `SQLs` `MODULEs` `SRVPGMs` `PGMs` `MENUs` `PNLGRPs` `QMQRYs` `WSCSTs` `MSGs`.

### Rules section

The rules section specifies dependency information and custom compile settings. This is where Bob is told which source files and other objects are needed to build each object, and is where object-specific compile settings are overridden.

To create a rule, first write the object name (with the IFS suffix), followed by a colon and a space.  Then write the name of the object's source file:

```makefile
VATDEF.FILE: $(d)/VATDEF.PF SAMREF.FILE
```

The example above is physical file `VATDEF.FILE`.  It is compiled from source code `VATDEF.PF` under the same directory of the `Rules.mk` file.

> [!WARNING]
>
> Note that we have to specify the the source file using the special `$(d)` variable. This is to indicate that the source file is within the current directory. We may remove the need for the `$(d)` variable in future versions.

If the object depends on other objects, add them to the end, separated by spaces:

`VATDEF.FILE` depends on physical file `SAMREF.FILE` which is defined somewhere else in the project.  Specifying dependencies is important, for this is what causes the physical file to automatically get recompiled when source code for its dependent physical file changes.

In summary, for the rules section, simply specify each object, followed by its source file (source-based objects) or primary object (non source-based objects),followed by any remaining dependencies.

---



> [!TIP]
>
> The Bob developers like to add a comment before each object rule that specifies the object name and intended compile command.  We find the syntax coloring helps the eye quickly locate object rules, and the compile command helps clarify what Make should do.  Makefile comments begin with a `#`.

---

#### Overriding compile settings

The generic bob makefile establishes what are hopefully sensible defaults for compile settings.  All of your projects will reference the same `def_rules.mk` file, so you can change its defaults to those shared among your projects (for example, TGTRLS is by default set to `V6R1M0`).

On the other hand, let's say you have an object that needs to be specially compiled at `V7R1M0`.  This directive is implemented by use of [target-specific variables](https://www.gnu.org/software/make/manual/make.html#Target_002dspecific), which is added as a separate line in the object's rule:

```makefile
JB110.MODULE: private TGTRLS := V7R1M0
JB110.MODULE: JB110.RPGLE
```

Above, module `JB110` will be compiled at a target release of `V7R1M0`.  The `private` modifier tells Make that the scope of the TGTRLS override is limited to `JB110.MODULE`.

The current list of overrideable compile attributes is:

* ACTGRP
* AUT
* BNDDIR
* COMMIT
* CURLIB
* DBGVIEW
* DETAIL
* DFTACTGRP
* DLTPCT
* HLPID
* HLPPNLGRP
* OBJTYPE
* OPTION
* PAGESIZE
* PGM
* PMTFILE
* PRDLIB
* REUSEDLT
* RPGPPOPT
* RSTDSP
* SIZE
* STGMDL
* SYSIFCOPT
* TERASPACE
* TEXT
* TYPE
* TGTCCSID
* TGTRLS
* VLDCKR

#### Switches and options

Bob's functionality and behavior can be adjusted by setting the values of certain options in the makefile.  Syntactically, setting an option is identical to overriding a compile attribute (as detailed above); the format is _`object_name: private option := value`_.

Following are the available makefile options.

##### CREATE_TYPEDEF
Setting `CREATE_TYPEDEF` to `YES` for a *FILE object (LF, PF, PRTF) results in a separate include-ready source file being generated that contains a typedef structure for the file object's record formats.  This feature is useful for C code that can no longer rely on `#pragma mapinc`, which doesn't work with IFS source code.  The generated file is named after the original source file, but with `.H` appended (source file `JB001.PF` results in include file `JB001.PF.H`)  Under the covers, the GENCSRC command is called.  Note that in the resulting struct, Bob changes `int` to `long int` to work with the SQL C compiler.

_Example:_

```
# JB001.FILE -- CRTPF
JB001.FILE: private TEXT = Jumbo test file
JB001.FILE: private CREATE_TYPEDEF = YES
JB001.FILE: JB001.PF
```

## Further reading

To learn more about makefile syntax, see the official [GNU Make documentation](https://www.gnu.org/software/make/manual/make.html).  Just remember that every object referenced in a Bob makefile must have an IFS file suffix (`.PGM`, `.FILE`, etc.) and be written in upper case.