![](../../wiki/images/bob-logo-bw.png)

# Better Object Builder
Better Object Builder, or _Bob_, is a free and open source build system for the IBM i platform that is used to build native "QSYS" objects.  It was developed by [S4i Systems](http://www.s4isystems.com), a leader in Electronic Document Management, to build their own software, and is under active development.  It is released under the [Apache 2.0 license](LICENSE) to the open source community so that others can contribute and benefit.

# Why Better Object Builder?
Here's what makes Bob different.

* **Speed.**  Bob only compiles objects that need recompiling, like from new or changed source code.

* **Reliability.**  Bob understands the relationships between your objects, so if an item changes, then it and everything depending on it will be rebuilt.

* **Industry standard.**  Object dependencies are specified using standard makefile syntax, and the actual build engine is [GNU Make](https://www.gnu.org/software/make/) -- exactly like tens of thousands of Linux and Unix software projects.

* **Flexibility.**  Most objects defined to Bob typically build using your default values.  Have a program that requires a custom activation group or a data area that needs to be created with a certain value?  No problem, overriding compile parameters is trivial, and writing custom recipes for special objects is very straightforward.  If you can code it, you can build it.

* **Ease of use.**  Invoking a build of an entire codebase is done with just a single command.  Or, if the Rational Developer for i integration pieces are installed, a single button click.

Learn more about installing and using Bob in the [wiki](../../wiki).

---

_Send source code to the i and build it with one button press:_ 
![](../../wiki/images/Bob-quick-RDi-build.mov.gif)