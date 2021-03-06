# UHFT - UWD HSA Fix Tool
Universal Windows Driver Hardware Support Application Fix Tool can be used to detect HSA's that have been installed during Windows installation but deleted by Windows during first user logon.

UHFT simply reads the values under registry key
```
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceSetup\InstalledPfns
```
and checks if a corresponding HSA is installed or missing on the system.

## Detect only
Run `Is-HSACompliant.ps1` and it will return "Yes" the system is OK. If the system is missing one or more previously installed HSA's the script will return "No".
You can use `Is-HSACompliant.ps1` as a MEMCM (ConfigMgr) compliance configuration item PowerShell script to detect if you have systems with deleted HSA's.

## Detect and install (fix deleted HSA's)

Run the script with administrative premissions or as a local system.
```
powershell.exe /executionpolicy bypass .\Repair-UWDApps.ps1
```
To install the missing HSA's, under folder `Packages` you will need to have  a folder named **Package Family Name** and in that folder 
1. file `install.ps1` which will be run if package needs to be installed,
2. installation package for the HSA and
3. dependency packages.

Just see the examples. The files already under `Packages` folder are just placeholders giving you the idea what is needed.

### Detecting missing HSA's (app that have been never installed)
Detecting HSA's that have never been installed but should be installed is tricky. You can scan the system to find device drivers that have a `pfn://` string in the .inf file:
```
Get-ChildItem -Path "C:\Windows\System32\DriverStore\FileRepository\*.inf" -Recurse | Select-String "pfn://" -List | Select Path, Filename
```
The problem with this detection method is that a driver files can exist in DriverStore but Windows does not necessarily use the drivers at all. That is why this detection method is not being used in the script.

### Other Apps
Additionally computer manufacturers have specific hardware-related apps for specific model. Those apps are not HSA's at all and should be installed as any (modern/store) application. There is no way to automatically detect if these apps are missing. You will just have to know these by yourself. :-)
