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

### 3. Build BOB RPM

* Create a new draft version named `v{r.v.m}` where `{r.v.m}` is the new version number
* make sure you update bob.spec to the new release level
* publish the release so the curl commmand below will find it
* Execute the following commands

```bash
export BOB_VERSION=r.v.m 
cd ~/rpmbuild
curl "https://raw.githubusercontent.com/IBM/ibmi-bob/v${BOB_VERSION}/bob.spec" -o SPECS/bob.spec
rpmbuild -ba SPECS/bob.SPEC
```

* The rpm is now created under `~/rpmbuild/RPMS/PPC64` directory.
* upload to the version and republish it

### 4. Install BOB RPM

* Run the follow to install BOB from the RPM
* The BOB_VERSION should be the same as above, if it is still set there is no need to do this again.
* The `rpm -e` command removes the previously installed version of BOB so that we can install the new one without conflict.

```bash
export BOB_VERSION=r.v.m 
rpm -e `rpm -qa | grep -i bob`
rpm -i ~/rpmbuild/RPMS/PPC64/bob-${BOB_VERSION}-0.ibmi7.3.ppc64.rpm
```

### 5. Test BOB RPM

Then test according to the [Testing instructions](testing.md)