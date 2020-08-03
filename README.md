# Universal Windows Drivers for ITPros
So you are an ITPro, sysdamin, systems architect or just a geek working with Windows deployments.
I have gathered here all the important information what every ITPro should know about Universal Windows Drivers (UWD) and Hardware Support Apps (HSA).
From ITPro's perspective, there are some severe design issues and problems with UWD's. 

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
When a user signs in, Windows will populate a "copy" of the app for the user just like it happens with all modern applications.

### HSA's in Microsoft Store
Although HSA's are just Windows (modern) apps, they are a bit different.
1. **Hidden**. You cannot find HSA's using Store's search. (But there is a way to find them.)
2. **Only in Store**. Microsoft has a policy which prohibits computer manufacturers to distribute install packages for HSA's. (This is hopefully changing in the future.)
3. **Not for users**. Because HSA is meant for a specific device driver, it should never be installed by or for the user.
This brings us a few problems. How can you install HSA manually? What is HSA installation fails? What if the computer does not have network connection or access to the Microsoft Store?

### Getting the Store link for a HSA and download install package
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
7. Select License: Offline and "Get the app"
8. Click "Manage", then "Products and Services"
9. On the right of the Intel Grapchics Control Center, click three dots menu "..." and Download for offline use
10. Download appxbundle and prerequisities

## Windows has a nasty bug
There is a bug in Windows. During first user logon, Windows will delete sideloaded apps. This means that all UWP HSA's installed will also be deleted. 

