# Universal Windows Drivers for ITPros
So you are an ITPro, sysdamin, systems architect or just a geek working with Windows deployments.
I have gathered here all the important information what every ITPro should know about Universal Windows Drivers (UWD) and Hardware Support Apps (HSA).
From ITPro's perspective, there are some severe design issues and problems with UWD's. 

## What is Universal Windows Driver
From ITPro's perspective the most important feature of UWD's is traditional Windows driver's ability to download and install an application (HSA) from Microsoft Store.
UWD has two parts,
1. "Traditional" driver (.inf format) and
2. App in Microsoft Store.



Microsoft has pretty good documentation for developers how UWD and HSA's are designed work. It might be a good idea to take a look at it.

[Microsoft Docs: Pairing a driver with a Universal Windows Platform (UWP) app](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/pairing-app-and-driver-versions)

To keep it short, if a driver's .inf file has the following lines in it:
```
SoftwareType=2
SoftwareId=pfn://<PackageFamilyName>
```
Windows will automatically reach out to Microsoft Store, download and install the driver's HSA. This happens hidden in the background and the app will be installed for the system.
When a user signs in, Windows will populate a "copy" of the app for the user just like it happens with all modern applications.

### HSA's in Microsoft Store
Although HSA's are just Windows (modern) apps, they have a few specialitien. They are hidden in the Store. You cannot find them using Store's search.
You can, however, find them using a Store "deep link". You can work your way from the driver .inf file using PackageFamilyName to get the actual app link for the Store.

## Windows has a nasty bug
There is a bug in Windows. During first user logon, Windows will delete sideloaded apps. This means that all UWP HSA's installed will also be deleted. 

