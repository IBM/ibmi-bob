# Testing BOB

## Doctest 
makei/utils.py can be tested via doctest
Requires PYTHONPATH being set to the ibmi-bob project root so that the 'makei' module is recognized. 
```
SET PYTHONPATH=<bob project root>
python makei/utils.py -v
```

## VS Code Test Explorer
makei/tests contains tests that can be run through VS Code Test Explorer extension

## Running makei
Use the https://github.com/edmundreinhardt/bob-recursive-example and do a `makei b -e <yourlib>` into an empty directory
Use the https://github.com/worksofliam/company_system and do a `makei b -e <yourlib>` into an empty directory
( tests with an empty iproj.json includePath)

Touch one file and do a makei again and see only those affected files build
Touch one file and do a `makei c -f <sourcefile>` and see only the target built