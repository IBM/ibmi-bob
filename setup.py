import pathlib

from setuptools import find_packages, setup

here = pathlib.Path(__file__).parent.resolve()


def read(rel_path: str) -> str:
    here = pathlib.Path(__file__).parent.resolve()
    return (here / rel_path).read_text(encoding='utf-8')


def get_version(rel_path: str) -> str:
    for line in read(rel_path).splitlines():
        if line.startswith("__version__"):
            delim = '"' if '"' in line else "'"
            return line.split(delim)[1]
    raise RuntimeError("Unable to find version string.")


setup(
    name="bob",
    version=get_version("src/makei/__init__.py"),
    description="A build system for creating IBM i-native objects using GNU Make.",
    packages=find_packages(
        where="src",
        exclude=["docs", "tests*", ],
    ),
    url="https://github.com/IBM/ibmi-bob/",
    project_urls={
        "Documentation": "https://ibm.github.io/ibmi-bob",
        "Source": "https://github.com/IBM/ibmi-bob/",
    },
    package_dir={"": "src"},
    python_requires=">=3.6",
    long_description=read("README.md"),
    license="Apache License 2.0",
    keywords=["bob", "IBM i", "QSYS", "make", "build"],
    scripts=[
        "bin/makei",
        "bin/crtfrmstmf",
    ],
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: Apache Software License",
        "Operating System :: Other OS",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Topic :: Software Development :: Build Tools",
        "Topic :: System :: Operating System Kernels :: IBM i",
    ],
)
