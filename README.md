# Universal Windows Drivers for ITPros

**Table of Contents**
- [Universal Windows Drivers for ITPros](#universal-windows-drivers-for-itpros)
  * [What is Universal Windows Driver](#what-is-universal-windows-driver)
    + [HSA's in Microsoft Store](#hsas-in-microsoft-store)
    + [HSA automatic updates from Microsoft Store](#hsa-automatic-updates-from-microsoft-store)
  * [Problematic UWD drivers](#problematic-uwd-drivers)
    + [Waves MaxxAudio Pro for Dell 2020: HSA not installed](#waves-maxxaudio-pro-for-dell-2020-hsa-not-installed)
    + [AMD Radeon Software: No installation package](#amd-radeon-software-no-installation-package)
  * [Windows has a bug: HSA's will be deleted!](#windows-has-a-bug-hsas-will-be-deleted)
    + [Detecting deleted HSA's](#detecting-deleted-hsas)
    + [How to manually fix deleted HSA's](#how-to-manually-fix-deleted-hsas)
  * [UHFT - UWD HSA Fix Tool](#uhft---uwd-hsa-fix-tool)
  * [Sideloading Apps](#sideloading-apps)
    + [MEMCM](#memcm)
    + [Online system](#online-system)
  * [How to get Store link and download HSA install package](#how-to-get-store-link-and-download-hsa-install-package)

So, you are an ITPro, sysdamin, systems architect or just a geek working with Windows deployments.
Here you can find all the important information what every ITPro should know about Universal Windows Drivers (UWD) and Hardware Support Apps (HSA).
From ITPro's perspective, there are some severe design issues and problems with UWD's. If you are not careful, you will end up having computers with broken drivers.

## What is Universal Windows Driver
Compared to the traditional Windows drivers, the most important feature of UWD's is driver's ability to trigger a download and installation of a app (HSA) from Microsoft Store that the driver needs.
UWD has two parts,
1. "Traditional" driver (.inf format) and
2. App in Microsoft Store.

Microsoft has pretty good documentation for developers how UWD and HSA's are designed work. It might be a good idea to take a quick look at the docs.

[Microsoft Docs: INF AddSoftware Directive](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/inf-addsoftware-directive)

[Microsoft Docs: Pairing a driver with a Universal Windows Platform (UWP) app](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/pairing-app-and-driver-versions)

When it comes to the driver installation and management, for UWD's we have two different worlds. Driver in .inf format and it's Store counterpart.

![UWD and HSA](https://github.com/mikkojarvinen/UWD/blob/master/UWD-HSA.png "UWD and HSA")

To keep it short, if a driver's .inf file has the following lines in it:
```
SoftwareType=2
SoftwareId=pfn://<PackageFamilyName>
```
Windows will automatically reach out to Microsoft Store, download and install the driver's HSA. This happens hidden in the background and the app will be installed for the system. Other option is to install HSA manually to Windows either in offline or online mode. In that case you will need the install packages.
When a user signs in, Windows will populate a "copy" of the HSA app for the user just like it happens with all modern applications.

### HSA's in Microsoft Store
Although HSA's are just Windows (modern) apps, they are a bit different.
1. **Hidden**. You cannot find HSA's using Store's search. (But there is a way to find them if you have Store "deep link". See below how to download a HSA from Store.)
2. **Originally only in Store**. Microsoft had a policy that didn't allow computer manufacturers to distribute install packages for HSA's. This policy has been overturned and **since August 2020 you can download HSA install packages from computer manufacturer's driver downloads web pages**.
3. **Not for users**. Because HSA is meant for a specific device driver, it should never be installed by or for the user. Only install - or provision to use fancier term - to a device.
This brings us a few problems. How can you install HSA manually? What if HSA installation fails? What if the computer does not have network connection or access to the Microsoft Store?

### HSA automatic updates from Microsoft Store
If Windows has access to the Microsoft Store, installed HSA's will be automatically updated if newer version is available on Store. It does not matter if HSA has been installed the "natural way" during UWD install process, sideloaded to the offline image or (re)installed to an online live system from .appx\[bundle\]. If you are offline servicing HSA's this means you don't have to worry too much about deploying the latest version. This is good news.

## Problematic UWD drivers
UWD and HSA installations work very well when every part of the process is working as expected. Unfortunately, some drivers seems to have problems making the installations difficult or impossible.

### Waves MaxxAudio Pro for Dell 2020: HSA not installed
There seems to be an issue in `WavesAPO9De.inf` driver and the HSA "Waves MaxxAudio Pro for Dell 2020" never gets installed from the Store. One way to fix this automatically is to "stamp" the computers where the driver is used
```
reg.exe add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceSetup\InstalledPfns /v WavesAudio.MaxxAudioProforDell2020_fh4rh281wavaa /t REG_DWORD /d 1 /f
```
and then let the [UWD HSA Fix Tool](#uhft---uwd-hsa-fix-tool) take care of the HSA installation. Of course, you will need to first download the installation package from Dell Support site and then add it to the `packages` folder of the tool.

### AMD Radeon Software: No installation package
Installation package for the "AMD Radeon Software" cannot be downloaded from the Microsoft Store. Withtout package, there is no way to do offline installs. If this app has been deleted because of the [bug in Windows](#windows-has-a-bug-hsas-will-be-deleted) the you can use the [manual driver and HSA reinstallation fix](#how-to-manually-fix-deleted-hsas).

## Windows has a bug: HSA's will be deleted!

**Update!** Microsoft has fixed this issue in Windows 10 20H2.

There is a bug in Windows 1809 and newer until 20H2, which affects Windows and driver installations. _During first user logon Windows will delete external sideloaded apps._ This means that **all HSA's will also be deleted** and the driver will be broken. How badly, depends on the driver. You might just end up missing a somewhat useless App or in the worst case the functionality of the driver depends on the existence of HSA.
For example, without it's HSA app, Wawes MaxxAudio driver cannot operate computer's 3.5mm headphone jack rendering the connector completely unusable. Without Intel Graphics Control Panel you willl get a picture on your screen but are missing all the Intel's video adjustment goodies (?) HSA provides.
If first user logon has already happened, delete operations will not happen.

To reproduce this bug, you'll need a computer which has at least one device with UWD driver. Most likely any modern laptop will do the job.
1. Install Windows (versions 1809-20H1) from unmodified .iso image
2. Give Windows internet connection but do not finish OOBE or sign in
3. Let Windows discover devices and find drivers for them from WU (Shift+F10, devmgmt.msc, see devices being detected)
4. Let UWD driver(s) to download and install HSA from Microsoft Store (Shift+F10, regedit.exe, see HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceSetup\InstalledPfns)
5. Sign in (fresly installed HSA's will now be deleted)
6. Open Event viewer and log Microsoft/Windows/Microsoft-Windows-AppXDeploymentServer/Operational
7. Sort by Event ID, find Event 809, select it, sort by Date and Time. You will see Event IDs 809 and 819 that clearly tell you HSA's have been deleted
8. See also `C:\Program Files\WindowsApps\DeletedAllUserPackages` to find out HSA's have been deleted

### Detecting deleted HSA's
When Windows installs a UWD driver, it will use the pfn:// link in driver .inf file to get driver's HSA from the Store. In the background, HSA is downloaded and installed. After a successful installation Windows adds a DWORD registry value with a Package Family Name and value "1" under registry key
```
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceSetup\InstalledPfns
```
(InstalledPfns key does not exist if there is no HSA installed on the system.)
If there is a Package Family Name value in registry, but no installed app with the same Package Family Name, we know the app is missing.


### How to manually fix deleted HSA's
You can force Windows to download and install HSA again. You will have to remove the InstalledPfn registry "label" for that HSA and let Windows install the device again:
1. Remove HSA's registry value under `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceSetup\InstalledPfns`
2. From device manager, find the device that uses UWD driver.
3. Uninstall device and driver
4. Scan for hardware changes
5. Windows will find the device again, installs the driver and downloads and installs HSA back to the computer

## UHFT - UWD HSA Fix Tool
[UHFT - UWD HSA Fix Tool](https://github.com/mikkojarvinen/UWD/tree/master/UWDHSAFixTool)

You can use UHFT (UWD HSA Fix Tool) to detect any missing HSA's in Windows and install them. You will have to get the files for the installation packages by yourself. There are few examples and empty filenames to get you started with the idea. UHFT is just a simple PowerShell script so you can modify it for for your needs. It is possible to create MEMCM compliance rule for HSA's to only detect how many devices you have that are missing HSA's.

UHFT does not care about on computer models. It simply checks the missing HSA's that should be installed on the system so it is safe to run it on all your systems.

## Sideloading Apps
You can sideload Store Apps (and HSA's) into Windows.
### MEMCM
If you use MEMCM (ConfigMgr) for Windows deployments or just offline service your images, you can sideload Apps with dism.exe into Windows.
You can prevent Apps being deleted during first logon by changing the sideloading policy registry setting in Windows image to "Allow all trusted apps" and giving dism a switch REGION=ALL.
While this method works also for HSA's, it does not help with automated driver installations as you are not giving any commands and **you will still need the install packages for the HSA's**.
Sune Thomsen has written an excellent blog about this topic: (https://www.osdsune.com/home/blog/2020/deploy-uwp-osd)
### Online system
You can add HSA's also in live online Windows. Jus use dism the following way:
```
dism.exe /online /Add-ProvisionedAppxPackage /PackagePath:".\<package appx/appxbundle>" /SkipLicense /Region:"all"
```
Put all the dependency packages in the same folder as HSA. Don't worry about the license.

## How to get Store link and download HSA install package

**Notice!** Beginning from August 2020, you can find HSA's from computer manufacturer's driver download web page. This is probably easier than the following way.

As mentioned, although HSA's are hidden in the Store, you can find them using a Store "deep link".
And without access to the HSA in Store, you cannot download the offline installation package.
You can, however, work your way from the driver .inf file using PackageFamilyName to get the actual app link for the Store.
Using that link in Store for Business or Store for Education, you can finally download HSA install package for offline use.

**Notice!** If application in Store does not allow offline installations, then you are pretty much out of luck. One such app is "ST Microelectronics Dell Free Fall Data Protection".

Let's use "Intel Grapchics Command Center" as an example.
1. In (one version of) Intel UHD Graphics drivers, there is (among others) a driver file `igcc_dch.inf`. If you open the file and search for `pfn://` you will find the following PackageFamilyName link (defined in Strings section).
```pfn://AppUp.IntelGraphicsExperience_8j3eq9eme6ctt```
2. Next we need a Windows with Store App. We need to create the following string and open it with in Windows' Run... command (Win+R)
```ms-windows-store://pdp/?PFN=AppUp.IntelGraphicsExperience_8j3eq9eme6ctt```
3. Store App opens an shows us the Intel Graphics Command Center app. In the App details, just next to and on the right hand size of the review starts, click "Share".
4. Click "Copy link".
5. Now we have a link to the Store with ProductId. Paste it in the web browser (InPrivate mode preferred).
```https://www.microsoft.com/store/productId/9PLFNLNT3G5G```
5. See the URL will change to the following.
```https://www.microsoft.com/en-us/p/intel-graphics-command-center/9plfnlnt3g5g```
6. Now we need to create a working link for Store for Business/Education and open it in a browser while signed in the Store for Business/Education as a Store admin.
```https://educationstore.microsoft.com/en-us/store/details/intel-graphics-command-center/9plfnlnt3g5g```
7. Change License type to "Offline" and click "Get the app" (**Notice!** If there is no offline licensing available, software vendor has opted out to allow offline installs and you cannot download install package.)
8. You will get a popup that software has been added to your inventory. Click "Close".
9. Click "Manage".
(You will be taken straight to the download page, which you can find later from "Products and Services". On the right of the Intel Grapchics Control Center, click three dots menu "..." and Download for offline use.)
11. Download appx(bundle) for the HSA as well as for all the required frameworks. License is not needed for HSA's.
