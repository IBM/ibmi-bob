# Installing IBM i Prerequisites

Some software needs to be installed on the IBM i before Bob can be used to compile software.

<!-- TOC -->

- [Install PASE](#install-pase)
- [Install IBM i Open Source Technologies](#install-ibm-i-open-source-technologies)
- [Ensure the SSH daemon is running](#ensure-the-ssh-daemon-is-running)
- [Make Bash the default shell](#make-bash-the-default-shell)

<!-- /TOC -->

## Install PASE

The build system uses Unix and GNU tools which run inside of PASE, so PASE must be installed, if it already isn't.

<https://www.ibm.com/docs/en/i/7.4?topic=i-installing-pase>

## Install IBM i Open Source Technologies

IBM provides many open source technologies ported to work on IBM i. Bob depends of a few of them, namely bash, rsync, awk and (optionally) curl.  

One of the easier ways to manage the set of open source tools is through ACS. Here is some instructions on [how to install and manage the open source packages](https://www.ibm.com/support/pages/getting-started-open-source-package-management-ibm-i-acs)

You can then use the ACS GUI or the command line to make sure that the following packages are installed.

```shell
yum install bash chsh curl db2util gawk jq rsync sed-gnu make-gnu coreutils-gnu grep-gnu
```

It is important that the directory '/QOpenSys/pkgs/bin' directory is on your path.  You can add this line to the .bash_profile file (or create it if it does not exist).

```shell
export PATH=/QOpenSys/pkgs/bin:$PATH
```

## Ensure the SSH daemon is running

Here is some good [background](https://www.seidengroup.com/2020/11/16/getting-started-with-ssh-for-ibm-i/) on ensuring SSH is available on IBM i and why.
Typically the [5733-SC1 Licensed Program Product](https://www.ibm.com/support/pages/node/1128123/) is already installed as part of the operating system.

To start the server:

```CL
===> STRTCPSVR SERVER(*SSHD)
```

### Make Bash the default shell

SSH's default shell on the IBM i is the Bourne shell (_see:_ [_IBM PASE for i shells and utilities V7R4_](https://www.ibm.com/support/knowledgecenter/en/ssw_ibm_i_74/rzalf/rzalfpase.htm)).  We recommend changing this to the [Bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) shell, because Bash is more user-friendly and feature rich.  Changing shells on IBM i is described [here](https://ibmi-oss-docs.readthedocs.io/en/latest/troubleshooting/SETTING_BASH.html).
To do this, run the following command, the first line is only necessary if chsh is not already installed.

```shell
yum install chsh
chsh -s /QOpenSys/pkgs/bin/bash
```

alternatively you can use SQL

```SQL
CALL QSYS2.SET_PASE_SHELL_INFO('*CURRENT', '/QOpenSys/pkgs/bin/bash')
```
## Use internet time server to keep timestamps in sync
Bob uses gmake which compares the timestamps of source and their compiled objects to determine exactly what needs to get compiled.  If you are synchronizing your source to IFS from your IDE or PC workspace, it is important that they agree on what time it is.  The following commands can be used to set up the NTP server to synchronize clocks to an internet server.

```CL
CHGNTPA RMTSYS('0.us.pool.ntp.org') POLLITV(1)
STRTCPSVR SERVER(*NTP) NTPSRV(*CLIENT)
```
The first command says to synchronize with a specific server.  You can find a local server here https://www.ntppool.org/zone/@ if you don't have one in your shop.

Installation of IBM i prerequisites are now complete. :-)
