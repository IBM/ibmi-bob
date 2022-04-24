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

