# Metadata for IBM i project

## Vision

The IBM i projects will self-describe how to build themselves as much as possible.  The project could be git cloned directly into an IFS directory or onto a client that is more convenient for editing and synchronized to the IFS directory it is built from. The project metadata needs to have sufficient information to specify the environment for both editing and compiling. The ultimate goal is that a Git project can contain all the information to build a working application. I.e. a git hook can trigger the cloning, building, and deploying of a project without any additional dependencies on a target IBM i.

## Technical Assumptions

* Metadata will be stored in JSON because:
  * JSON is the most popular persistence mechanism because it is lightweight and easily understood by both humans and computers
  * JSON is native any node.js based platform and has readily available tooling in all others
* All third parties should generate/use the common metadata. Third-parties can store additional metadata in additional JSON within the same file.
* Places to store information
  * Project level JSON – in the root directory of the project - iproj.json (analogous to package.json) – could be used for storing name of project, version information, dependencies, git repo, description, license  AND IBM i attributes like target object library, target CCSID, LIBL, initial CL and include directories
  (part of the vision to make an IBM i package manager that is still in progress)
  * Directory level JSON - .ibmi.json in each directory allows overriding of target library and CCSID in  for that directory and its sub-directories.
  * Comments  in the code itself

