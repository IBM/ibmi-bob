# Create a new project

## Interactive Setup

We have provided an interactive initializing program inside `makei` which walk you through a list of options and sets up the project for you. To create a project, run:

```bash
makei init
```

At the end you will see:

```diff
The following files will be added to the project
+ /home/tongkun/init-test/iproj.json
+ /home/tongkun/init-test/.ibmi.json
+ /home/tongkun/init-test/Rules.mk
Continue? (yes)
```

Simply press enter to confirm the changes and you have created a minimal bob project.

> [!NOTE]
>
> You may notice that the `.ibmi.json` will be created only if you have specified a different `EBCDIC CCSID`. This is because the `EBCDIC CCSID` is part of the directory level metadata.

## Manually Setup

You may choose to manually setup the project by creating 

- [x] `iproj.json` at the project root
- [x] `.ibmi.json` at the directories you want to overide build variables
- [x] `Rules.mk` at each level of the project defining the targets



So far, we have created:

- [project level metadata iproj.json](prepare-the-project/iproj-json)
- [directory level metadata .ibmi.json](prepare-the-project/ibmi-json)

- [Rules.mk](prepare-the-project/rules-mk.md) defining the directory level targets to build

