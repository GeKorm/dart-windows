# Build Steps

### 1. Prerequisites
Download and install the following programs:

* [Inno Setup](http://www.jrsoftware.org/isdl.php)
* [Inno Download Plugin](https://code.google.com/p/inno-download-plugin/) (check the "*Add IDP include path to ISPPBuiltins.iss*" option during installation)

### 2. File structure
Download and extract this repository. Paths in the .iss files are relative, so altering the structure
requires modifying the relevant strings. Then, take the folders `ansi` and `unicode` found in the `compiler/` directory,
and move them to the *Inno Download Plugin* installation directory, replacing the existing files.
This is fixes some grammar and spelling errors.

### 3. Compilation order
First, in Inno Setup compile (Build -> Compile or Ctrl + F9) the two updaters, `dart_x64_dev_update.iss` and `dart_x64_stable_update.iss`. 
Then, compile the two installers `dart_x64_dev_setup.iss` and `dart_x64_stable_setup.iss`. The executables are located in `bin/`
