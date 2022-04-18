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

  Possible choices: init, compile, c, build, b

## Sub-commands:

### init

set up a new or existing project

```
makei init [-h] [-f]
```

#### Options

- -f, --force

  force overwrite any existing files

---

### compile (c)

compile a single file

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

build the whole project

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