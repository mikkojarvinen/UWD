# Find missing HSA's and install them if install package is available in Packages folder
$InstalledPfns = Get-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceSetup\InstalledPfns | Select-Object -ExpandProperty Property

foreach ($InstalledPfn in $InstalledPfns)
  {
  $InstalledPn = $InstalledPfn -split "_"
  $InstalledPackage = Get-AppxPackage -AllUsers $InstalledPn[0]
  if ($InstalledPackage.Status -eq "Ok")
    # UWP HSA is installed, everything is ok for this driver
    { Write-Output "Installed:  $InstalledPfn" }
  else 
    # UWP HSA is missing, we will try to install the app
    {
    Write-Output "HSA not found:  $InstalledPfn"
    $packagepath = "$PSScriptRoot\Packages\" + $InstalledPfn + "\install.ps1"
    If (Test-Path -Path $packagepath)
      {
      $filepath = "powershell.exe -executionpolicy bypass -file '$PSScriptRoot\Packages\" + $InstalledPfn + "\install.ps1'"
      Write-Output "  Running:  $filepath"
      try
        {
        Invoke-Expression $filepath
        }
      catch
        {
        Write-Output "    Error:  $_"
        }
      }
    Else
      {
         Write-Output "File not found:  $packagepath"
      }
    }
  }

