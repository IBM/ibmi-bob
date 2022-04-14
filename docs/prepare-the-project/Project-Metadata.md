# Metadata for IBM i project

## Vision

The IBM i projects will self-describe how to build themselves as much as possible.  The Project needs to know how to get source from stream files in a directory hierarchy in a project presumably managed by git, into the IBM i and compiled with all attributes intact.  The final goal is that a Git project can contain all the information to build a working application.  I.e. a git hook can trigger the cloning, building, and deploying of a project without any additional dependencies on a target IBM i.

## Technical Assumptions

* Metadata will be stored in JSON because:
  * JSON is the most popular persistence mechanism because it is lightweight and easily derstood by both humans and computers
  * JSON is native any node.js based platform and has readily available tooling in all others
* All third parties should generate/use the common metadata. Third-parties can store additional metadata in additional JSON within the same file.
* Places to store information
  * Project level json – in the root directory of the project - iproj.json (analogous to package.json) – could be used for storing name of project, version information, dependencies, git repo, description, license  AND IBM i attributes like target object library, target CCSID, LIBL, initial CL and include directories
  (part of the vision to make an IBM i package manager that is still in progress)
  * Directory level json - .ibmi.json in each directory allows overriding of target library and CCSID in  for that directory and its sub-directories.
  * Comments  in the code itself

### Attributes stored

#### For a user/workspace

Information for a project that will vary per deployment and so should not be hardcoded in the project.  

* Hostname/ip address
* Userid
* (note that the password or private key is stored in a secure location depending on the development platform)
* IFS build directory
* Variables (can be used to name libraries for the object library or library list, or directories for the include path).  This allows the same project definition to target a different build library from one developer to another.  It would also allow Bob to be used in CI/CD pipelines.  Before invoke a Bob build, an environment variable should be set with the same name as the Bob variable and with the desired value for that build.  So if the iproj.json said to use &objlib1 for the OBJLIB for compiles within a directory and the PASE command `export objlib1=PROJ_QA1` is run,  then the environment variable objlib1 would be set to “PROJ_QA” before invoking the build command.  Within the build shell script the value could be referenced via &objlib1.  Similarly the CI/CD mechanisms can set up  directories and object libraries using the exact same environment variable names. 
* Tooling like RDi might provide a UI to edit these values.
