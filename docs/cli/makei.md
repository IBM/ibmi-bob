# makei

## Synopsis

```bash
usage: makei [-h] [-v] command ...
```

## Options

- **-v, --version**

  print version information and exit

## These are common makei commands

- **command**

  Possible choices: init, compile, c, build, b, cvtsrcpf

## Sub-commands:

### init

?> set up a new or existing project

```
makei init [-h] [-f]
```

#### Options

- -f, --force

  force overwrite any existing files

---

### compile (c)

?> compile a single file

```
makei compile [-h] (-f <filename> | --files <filepaths>) [-o <options>]
              [-e <var>=<value>] [--bob-path <path>]
```

#### Options

- **-f, --file**

  file to compile

- **--files**

  files to compile, separated by colon (:)

- **-o, --make-options**

  options to pass to make

- **-e, --env**

  override environment variables

- **--bob-path**

  path to the bob directory

---

### build (b)

?> build the whole project

```
makei build [-h] [-t <target> | -d <subdir>] [-o <options>] [--bob-path <path>]
            [-e <var>=<value>]
```

#### Options

- **-t, --target**

  target to be built

- **-d, --subdir**

  subdirtory to be built

- **-o, --make-options**

  options to pass to make

- **--bob-path**

  path to the bob directory

- **-e, --env**

  override environment variables
  
  ---

### cvtsrcpf

?> convert source physical file members to ASCII IFS files


```
makei cvtsrcpf [-h] [-c <CCSID>] <file> <library>
```

Converts all members in a source physical file to properly-named (Bob-compatible), ASCII-ish, LF-terminated source files in the current directory in the IFS. Generally speaking, the source member type will become the filename extension.

For example, RPGLE source member `AB1001` will become IFS source file `AB1001.RPGLE`. Four exceptions exist, however: source member types CMD, MENU, and PNLGRP result in filename extensions .CMDSRC, .MENUSRC, and .PNLGRPSRC, respectively, and source member type C residing in source physical file H results in filename extension .H.

By default, source files will be encoded in UTF-8; this can be overridden by using the `-c` option and supplying a CCSID value.
It is likely that the same destination directory will contain converted members from many source physical files.  Therefore, name collisions are possible.  In the event of a duplicate member name and type, the source file name will be adjusted from `member.type` to `member (n).type`, with `n` incremented until a unique name is achieved.

If the source physical file was created successfully, a `.ibmi.json` file with the same CCSID value will be created in the same directory. Note that It will not override an existing `.ibmi.json` file.



#### Arguments

- **file**

  the name of the source file

- **library**

  the name of the library

#### Options

- **-c**

  ccsid to override

#### Example

- Convert source members for file MYLIB/MYSRCFILE into directory `newdir` using the default (UTF-8).'
  ```bash
  cd newdir
  makei cvtsrcpf mysrcfile mylib
  ```

- Convert source members for file MYLIB/MYSRCFILE into directory `newdir` using Windows Latin-1.
  ```bash
  cd newdir
  makei cvtsrcpf -c 1252 mysrcfile mylib
  ```