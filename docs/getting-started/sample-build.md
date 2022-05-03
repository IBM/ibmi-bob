# Build the sample project

Now that everything is installed and configured, let's build a [sample project](https://github.com/edmundreinhardt/bob-recursive-example).

## Perform a build

1. **First create a library to build to.**

   ```cl
   CRTLIB LIB(BOBTEST) TEXT('Better Object Builder test project')
   ```
   
2. **Sign in to ssh and get the source from a sample git project**

   ```shell
   ssh ibmi01
   git clone https://github.com/edmundreinhardt/bob-recursive-example
   cd bob-recursive-example
   ```

   If you didn't have git, simply do a `yum install git` to get it.

3. **Set an environment variable to point to the library you created**

   ```shell
   export lib1=BOBTEST
   ```

4. **Run the build using:**

   ```shell
   makei build
   ```

> [!TIP]
>
> Alternatively, you may combine the above two commands using makei's shortcut:<br>
> `makei b -e lib1=BOBTEST`

5. **You should see output similar to this.**

  ```
   $ makei b -e lib1=BOBTEST
   Set variable <lib1> to 'BOBTEST'
   > make -k BUILDVARSMKPATH="/tmp/tmpigspspcr" -k BOB="/home/tongkun/git/ibmi-bob" -f "/home/tongkun/git/ibmi-bob/mk/Makefile" all
   === Creating RPG module [XML001.RPGLE]
   crtrpgmod module(BOBTEST/XML001) srcstmf('/home/tongkun/git/bob-recursive-example/QRPGLESRC/XML001.RPGLE') AUT() DBGVIEW(*ALL) OPTION(*EVENTF) OUTPUT(*PRINT) TEXT('') TGTCCSID(297) TGTRLS()
   ✓ XML001.MODULE was created successfully!
   ...
   ...
   Objects:             13 failed 97 succeed 110 total
   └ Failed objects:    ART301.MODULE FARTICLE.SRVPGM ART200D.FILE ORD100D.FILE ORD101D.FILE ART200.PGM ART201.PGM ART202.PGM ORD100.PGM ORD700.PGM ARTLSTDAT.FILE CUSSEQ.DTAARA ORDERCUS.FILE
   Build Completed!
  ```

  * all of the output is stored in `.logs/output.log`
  * all of the job logs are gathered in '.logs/joblog.json` and can be viewed with any JSON viewer
  * the event files for all compiles are gathered under the `.evfevent` directory

## The sample build process in action (quadruple speed)

<!-- ![Sample Build Demo](sample-build.assets/sample-build.gif) -->


> [!TIP]
> A few other options can be used:<br>
>   `makei c -f functionsVAT/VAT300.RPGLE` to compile the `VAT300.RPGLE` into `VAT300.MODULE`<br>
>   `makei b -d functionsVAT` to build the `functionsVAT` subdirectory<br>
>   Check out the [usage of makei](cli/makei.md)
