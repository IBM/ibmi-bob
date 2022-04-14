How to Build RPM
----------------



## Setup the RPM Build Environment

### 1. Check that you have rpmbuild installed

We will need `rpmbuild` to build RPM from the SPEC file. If you do not have rpm-build installed, use the following command to install it.

```bash
yum install rpm-build
```

### 2. Create directories for RPM building under home

The instruction below will create a `rpmbuild` directory under your home directory to build RPMs.

```bash
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
```



## Build bob RPM

* Create a new draft version named `v{r.v.m}` where `{r.v.m}` is the new version number
* Execute the following commands

```bash
export BOB_VERSION=r.v.m 
cd ~/rpmbuild
curl "https://raw.githubusercontent.com/IBM/ibmi-bob/v${BOB_VERSION}/bob.spec" -o SPECS/bob.spec
rpmbuild -ba SPECS/bob.SPEC
```

* The rpm is now created under `~/rpmbuild/RPMS/PPC64` directory.
* upload to the draft version and publish it