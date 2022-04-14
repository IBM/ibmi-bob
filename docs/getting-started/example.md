# Build the sample project

Now that everything is installed and configured, let's build a sample project.

1. First create a library to build to.

   ```cl
   CRTLIB LIB(BOBTEST) TEXT('Better Object Builder test project')
   ```

1. Switch to a shell and get the source from a sample git project

   ```shell
   ssh ibmi01
   git clone https://github.com/edmundreinhardt/bob-recursive-example
   ```
   If you didn't have git, simply do a `yum install git` to get it.

1. Set an environment variable to point to the library you create
   ```shell
   export lib1=BOBTEST
   ```
1. Run the build using:

   ```shell
   makei build
   ```

1. You should see output similar to this.
  ```bash
makei all
     makei: Reading from iproj.json
  ......objlib: BOBTEST
  ......curlib: BOBTEST
  ......tgtCcsid: *JOB
  ......IBMiEnvCmdList:
  ......preUsrlibl: BOBTEST
  ......postUsrlibl:

  Generating makefile for build variables at /tmp/tmp.BN1W6w3Vl8

  >> make -k BUILDVARSMKPATH=/tmp/tmp.BN1W6w3Vl8 COLOR_TTY=false -f /QOpenSys/pkgs/lib/bob/Makefile all
  >> === Creating PF [SAMREF.PF]
  >> CRTFRMSTMF/crtfrmstmf obj(BOBBUILD2/SAMREF) cmd(CRTPF) srcstmf('/home/REINHARD/bob3/bob-recursive-example/common/SAMREF.PF') parms('AUT() DLTPCT(*NONE) OPTION(*EVENTF *SRC *LIST) REUSEDLT(*NO) SIZE() TEXT('''')')
  ```

  * all of the output is stored in `.logs/output.log`
  * all of the job logs are gathered in '.logs/joblog.json` and can be viewed with any JSON viewer
  * the event files for all compiles are gathered under the `.evfevent` directory