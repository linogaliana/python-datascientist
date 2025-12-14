// Document level settings ----

// Determine if we need to install python packages
globalThis.qpyodideInstallPythonPackagesList = [{{INSTALLPYTHONPACKAGESLIST}}];

// Check to see if we have an empty array, if we do set to skip the installation.
globalThis.qpyodideSetupPythonPackages = !(qpyodideInstallPythonPackagesList.indexOf("") !== -1);

// Display a startup message?
globalThis.qpyodideShowStartupMessage = {{SHOWSTARTUPMESSAGE}};

// Describe the webR settings that should be used
globalThis.qpyodideCustomizedPyodideOptions = {
  "indexURL": "{{INDEXURL}}",
  "env": {
    "HOME": "{{HOMEDIR}}",
  }, 
  stdout: (text) => {qpyodideAddToOutputArray(text, "out");},
  stderr: (text) => {qpyodideAddToOutputArray(text, "error");}
}

// Store cell data
globalThis.qpyodideCellDetails = {{QPYODIDECELLDETAILS}};

