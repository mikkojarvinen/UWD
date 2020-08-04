# Universal Windows Drivers for ITPros
So, you are an ITPro, sysdamin, systems architect or just a geek working with Windows deployments.
Here you can find all the important information what every ITPro should know about Universal Windows Drivers (UWD) and Hardware Support Apps (HSA).
From ITPro's perspective, there are some severe design issues and problems with UWD's. If you are not careful, you will end up having computers with broken drivers.

## What is Universal Windows Driver
Compared to the traditional Windows drivers, the most important feature of UWD's is driver's ability to trigger a download and installation of a app (HSA) from Microsoft Store that the driver needs.
UWD has two parts,
1. "Traditional" driver (.inf format) and
2. App in Microsoft Store.

Microsoft has pretty good documentation for developers how UWD and HSA's are designed work. It might be a good idea to take a look at it.

[Microsoft Docs: Pairing a driver with a Universal Windows Platform (UWP) app](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/pairing-app-and-driver-versions)

When it comes to the driver installations and management, for UWD's we have two different worlds. Driver in .inf format and it's Store counterpart.

![UWD and HSA](https://github.com/mikkojarvinen/UWD/blob/master/UWD-HSA.png "UWD and HSA")

To keep it short, if a driver's .inf file has the following lines in it:
```
SoftwareType=2
SoftwareId=pfn://<PackageFamilyName>
```
Windows will automatically reach out to Microsoft Store, download and install the driver's HSA. This happens hidden in the background and the app will be installed for the system.
When a user signs in, Windows will populate a "copy" of the HSA app for the user just like it happens with all modern applications.

### HSA's in Microsoft Store
Although HSA's are just Windows (modern) apps, they are a bit different.
1. **Hidden**. You cannot find HSA's using Store's search. (But there is a way to find them.)
2. **Only in Store**. Microsoft has a policy which prohibits computer manufacturers to distribute install packages for HSA's. (This is hopefully changing in the future.)
3. **Not for users**. Because HSA is meant for a specific device driver, it should never be installed by or for the user.
This brings us a few problems. How can you install HSA manually? What is HSA installation fails? What if the computer does not have network connection or access to the Microsoft Store?

### HSA automatic updates from Microsoft Store
If Windows has access to the Microsoft Store, installed HSA's will be automatically updated if newer version is available on Store. It does not matter if HSA has been installed the "natural way" during UWD install process, sideloaded to the offline image or (re)installed to an online live system from .appx\[bundle\]. For you servicing HSA's this means you don't have to worry too much about deploying the latest version. This is good news.

## Windows has a bug: HSA's will be deleted!
There is a bug in Windows 1809 and newer, which affects Windows and driver installations. _During first user logon Windows will delete external sideloaded apps._ This means that **all HSA's will also be deleted** and the driver will be broken. How badly, depends on the driver. You might just end up missing a somewhat useless App or in the worst case the functionality of the driver depends on the existence of HSA.
For example, without it's HSA app, Wawes MaxxAudio driver cannot operate computer's 3.5mm headphone jack rendering the connector completely unusable.
If first user logon has already happened, delete operations will not happen.

It is questonable if Microsoft is ever going to fix this. In the meantime, we just need to survive.

To reproduce this bug, you'll need a computer which has at least one device with UWD driver. Most likely any modern laptop will do the job.
1. Install Windows from unmodified .iso image
2. Give Windows internet connection but do not finish OOBE or sign in
3. Let Windows discover devices and find drivers for them from WU (Shift+F10, devmgmt.msc, see devices being detected)
4. Let UWD driver(s) to download and install HSA from Microsoft Store (Shift+F10, regedit.exe, see HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceSetup\InstalledPfns)
5. Sign in (fresly installed HSA's will now be deleted)
6. Open Event viewer and log Microsoft/Windows/Microsoft-Windows-AppXDeploymentServer/Operational
7. Sort by Event ID, find Event 809, select it, sort by Date and Time. You will see Event IDs 809 and 819 that clearly tell you HSA's have been deleted
8. See also `C:\Program Files\WindowsApps\DeletedAllUserPackages` to find out HSA's have been deleted

## UHFT - UWD HSA Fix Tool (Coming soon!)
You can use UHFT (UWD HSA Fix Tool) - yes it is an acronym monster :-) - which will detect any missing HSA's in Windows and install them. You will have to get the files for the installation packages by yourself because distributing them is not allowed. There is a few examples and .stub files to get you started with the idea. UHFT is just surprisingly simple PowerShell script so you can modify it for for your needs. One idea is to create MEMCM compliance rule for HSA's.

UHFT does not care about on computer models. It checks the missing HSA's that should be installed on the system so it is safe to run on all your systems.

## Sideloading Apps and MEMCM
If you use MEMCM (ConfigMgr) for Windows deployments or just offline service your images, you can sideload Apps with dism.exe into Windows.
You can prevent Apps being deleted during first logon by changing the sideloading policy registry setting in Windows image to "Allow all trusted apps" and giving dism a switch REGION=ALL.
While this method works also for HSA's, it does not help with automated driver installations as you are not giving any commands and **you will still need the install packages for the HSA's**.
Sune Thomsens has written an excellent blog about this topic: (https://www.osdsune.com/home/blog/2020/deploy-uwp-osd)

### How to get Store link and download HSA install package
As mentioned, although you cannot use Store search to find a HSA, you can find them using a Store "deep link".
Without access to the HSA in Store, you cannot download the offline installation package.
You can, however, work your way from the driver .inf file using PackageFamilyName to get the actual app link for the Store.
Using that link in Store for Business or Store for Education, you can finally download HSA install package for offline use.

**Notice!** If application in Store does not allow offline installations, then you are pretty much out of luck. One such app is "ST Microelectronics Dell Free Fall Data Protection".

Let's use "Intel Grapchics Command Center" as an example.
1. In Intel UHD Graphics drivers, there is (among others) a driver file `igcc_dch.inf`. If you open the file and search for `pfn://` you will find the following PackageFamilyName link.
```pfn://AppUp.IntelGraphicsExperience_8j3eq9eme6ctt```
2. Next we need a Windows with Store App. We need to create the following string and open it with in Windows' Run... command (Win+R)
```ms-windows-store://pdp/?PFN=AppUp.IntelGraphicsExperience_8j3eq9eme6ctt```
3. Store opens the Intel Graphics Command Center app. In the App details, just next right to the review starts, find "Share" and click it
4. Click "Copy link"
5. Now we have a link to the Store with ProductId. Paste it in the web browser (InPrivate mode preferred)
```https://www.microsoft.com/store/productId/9PLFNLNT3G5G```
5. See the URL will change to the following.
```https://www.microsoft.com/en-us/p/intel-graphics-command-center/9plfnlnt3g5g```
6. Now we need to create a working link for Store for Business/Education and open it in a browser while signed in the Store for Business/Education as a Store admin.
```https://educationstore.microsoft.com/en-us/store/details/intel-graphics-command-center/9plfnlnt3g5g```
7. Change License type to "Offline" and click "Get the app" (**Notice!** If there is no offline licensing available software vendor has opted out and you cannot download install package.)
8. You will get a popup that software has been added to your inventory. Click "Close" 
9. Click "Manage"
(You will be taken straight to the download page, which you can find later from "Products and Services". On the right of the Intel Grapchics Control Center, click three dots menu "..." and Download for offline use)
11. Download appx(bundle) for the HSA as well as for all the required frameworks. License is probably not needed.

