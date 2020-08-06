# Use as a MEMCM compliance configuration item to detect a system with deleted HSA or HSA's
$InstalledPfns = Get-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceSetup\InstalledPfns | Select-Object -ExpandProperty Property
$HSACompliant = "Yes"
foreach ($InstalledPfn in $InstalledPfns)
{
  $InstalledPn = $InstalledPfn -split "_"
  try
  { 
    $InstalledPackage = Get-AppxPackage -AllUsers $InstalledPn[0]
  }
  catch 
  {
    Throw "Error"
  }
  if ($InstalledPackage.Status -eq "Ok") { }
  else { $HSACompliant = "No" }
}
$HSACompliant