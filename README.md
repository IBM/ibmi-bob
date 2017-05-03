# IBMiMake
IBMiMake is a free and open source build system for the IBM i platform that is used to build native "QSYS" objects.

# Why IBMiMake?
Here's what makes IBMiMake different.

* **Speed.**  IBMiMake only compiles objects that need recompiling, like from new or changed source code.

* **Reliability.**  IBMiMake understands the relationships between your objects, so if an item changes then it and everything depending on it will be rebuilt.

* **Industry standard.**  Object dependencies are specified using standard makefile syntax, and the actual build engine is GNU Make -- exactly like tens of thousands of Linux and Unix software projects.

* **Flexibility.**  Most objects defined to IBMiMake typically build using default values.  Have a program that requires a custom activation group or a data area that needs to be created with a certain value?  No problem, overriding compile parameters is trivial, and writing custom recipes for special objects is very straightforward.  If you can code it, you can build it.

* **Ease of use.**  Invoking a build of an entire codebase is a single command.  Or, if the Rational Developer for i integration pieces are installed, a single button click.

Learn more about IBMiMake in the [FAQ](Docs/FAQ.md).
