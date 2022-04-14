# Installation

?> ⚠️ Some software needs to be installed on the IBM i before Bob can be installed.
Please follow the [instructions to install prerequisites](getting-started/prerequisites.md) before continuing here.

## Install via yum package manager
!> Make sure you have installed the IBM i package repositories `ibmi-repos`.
<br>
If not, run `yum install ibmi-repos` before installing `bob`.


```bash
# Install bob
yum install bob
```



## Install via prebuilt RPM packages

1. IBM provides many open source technologies ported to work on IBM i. Bob depends of a few of them, namely `bash`, `rsync`, `awk` and (optionally) `curl`. 
2. Download the latest 
 ```bash
 curl -L https://github.com/IBM/ibmi-bob/releases/latest/download/bob.ppc64.rpm -o bob.ppc64.rpm
 ```
3. Install the rpm
```bash
# install bob from rpm file
rpm -i bob.ppc64.rpm
```
or upgrade from a previous version
```bash
# upgrade bob from rpm file
rpm -U bob.ppc64.rpm
```

