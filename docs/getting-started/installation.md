# Installation
> [!WARNING]
> Some software needs to be installed on the IBM i before Bob can be installed.
> Please follow the [instructions to install prerequisites](getting-started/prerequisites.md) before continuing here.

<!-- tabs:start -->

## **Install via yum package manager**

***YUM*** is a package management utility for RPM-based distributions. We recommend using *yum* to install *Bob* and its dependencies.

> [!TIP]
> Make sure you have installed the IBM i package repositories `ibmi-repos`.
>
> If not, run `yum install ibmi-repos` before installing `bob`.
```bash
 # Install bob
yum install bob
```



## **Install via prebuilt RPM packages**

1. Bob depends on many open source packages. You need to install the dependencies first before continuing.

```bash
yum install bash coreutils gawk grep-gnu make-gnu python39 python39-ibm_db sed-gnu
```

2. You may always grab the latest binary from the [releases](https://github.com/ibm/ibmi-bob/releases) page.

To download the latest rpm file on IBM i, run the following

```bash
curl -L https://github.com/IBM/ibmi-bob/releases/latest/download/bob-x.x.x-x.ibmi7.3.ppc64.rpm -o bob.ppc64.rpm
```

**Note:** the path may differ than the URL used above in the `curl` command above. 

* You can manually enter the version in the URL, or 
* you can grab the URL from the [latest release on GitHub](https://github.com/ibm/ibmi-bob/releases).
    * right click on the `.rpm` file and copy the link URL.

3. Install the `.rpm`

```bash
# install bob from rpm file
rpm -i bob.ppc64.rpm
```
or upgrade from a previous version
```bash
# upgrade bob from rpm file
rpm -U bob.ppc64.rpm
```

<!-- tabs:end -->

## Verify Bob is installed correctly

You may check if bob is installed correctly by invoking `makei` on IBM i. You should see an output similar to this.

```
$ makei
usage: makei [-h] [-v] command ...

optional arguments:
  -h, --help     show this help message and exit
  -v, --version  print version information and exit

These are common makei commands:
  command
    init         set up a new or existing project
    info         get information about the current project
    compile (c)  compile a single file
    build (b)    build the whole project
    cvtsrcpf     convert source physical file members to ASCII IFS files
```

If you see something like `makei: A file or directory in the path name does not exist.` Ensure that there is no error in the installation step and that you have [setup the environment](getting-started/prerequisites?id=configure-the-bash_profile) correctly.

If you still have issues, [submit an issue](https://github.com/IBM/ibmi-bob/issues/new).
