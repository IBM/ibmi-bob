# Getting Started
We are glad you are interested in contributing to bob. This document will help you get started.

## Get the source code

To work on bob, you need to get the source code. You can do this by cloning the repository:

```bash
git clone git@github.com:IBM/ibmi-bob.git
cd ibmi-bob
```

## Overview of the source structure
<object data="http:/ibm.github.io/ibmi-bob/#/contributing/Bob_Details.pdf" type="application/pdf" width="700px" height="700px">
    <embed src="http:/ibm.github.io/ibmi-bob/#/contributing/Bob_Details.pdf">
        <p>This browser does not support PDFs. Please download the PDF to view it: <a href="http:/ibm.github.io/ibmi-bob/#/contributing/Bob_Details.pdf">Download PDF</a>.</p>
    </embed>
</object>

## Set up the develop environment
For developing bob, you should install `Python3` and `nox` on your computer.

To install nox. Often, you can run the following to install and use it.
```base
python -m pip install nox
```

We recommend you to use `virtualenv` to create a virtual environment for bob development.
We've configured `nox` to set up the virtual environment for you. You can run the following
command to create a virtual environment and install all the dependencies.
```bash
nox -s dev
```

## Run the tests
To run the tests, you can run the following command:
```bash
nox -s test
```

## Run the linter
To run the linter, you can run the following command:
```bash
nox -s lint
```

## TODO: Release process
1. Once all the tests and linters pass, you can create a pull request to the `master` branch.
2. Switch to the `master` branch and pull the latest code.
3. Update the CHANGELOG file under the `changelogs` folder. Make sure you add the new version.
4. Use `nox -s release -- {major, minor, patch, build}` to release a new version. For example, 
if you want to release a new patch version, you can run `nox -s release -- patch`. This will bump
the version number, create a new tag, and push the tag to the remote repository.
5. Once the new tag is pushed, the CI will automatically
   1. build the RPM and upload it to the release
   2. create the spec file and create a new pull request to the spec file repository

## Versioning
The version number is defined in the `src/makei/__init__.py` file and is handled by `bump2version` package.
The format of the version number is `{major}.{minor}.{patch}-{build}`. For example, the version number is `2.4.6-0`.