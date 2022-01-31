<!-- Posted 2021-10-08 -->
# Android sucks

About a week ago I updated my phone,
which really isn't a scary thing unless you're running a custom ROM like I am.
After the update I started getting an error message saying that some background service had stopped responding.
I just clicked it away, but it kept coming back and annoying me.
Another thing that already bothered me was how the volume was boosted for some reason
(something to do with Dolby Atmos drivers, maybe?).
So even the lowest volume step was too loud
even after I had increased the number of volume steps to 30.
Nevertheless, I decided enough was enough.
Changes needed to be made.

## Choosing a new android ROM

Before this change I was running a slightly sketchy,
but very customizable ROM called [HavocOS](https://havoc-os.com).
It's amazing when it comes to customizability,
but it's developed by two indian guys with failing harddrives,
and the official support channel was a telegram group.
In the end I did settle for [LineageOS](https://lineageos.org),
which I already had experience of on my old phone.

## Installing a new ROM

The process of installing a new rom on my OnePlus 7 Pro is fairly straightforward.
For the sake of completeness, here are the steps I take:

1. Back up all important data on the phone (don't forget this like I did)
1. Make sure `adb` is installed, or install it
1. Download the recovery image and the base image zip for the ROM you wish to install
1. Make sure "USB debugging" and "Rooted debugging" is enabled in the Developer Settings, or enable it
1. Connect the phone to the computer using a USB-C cable
1. Run `adb reboot fastboot` in a shell to reboot into fastboot
1. Make sure the phone's bootloader is unlocked, or unlock it
1. Run `fastboot flash boot <path to the recovery image>` to flash and boot the new recovery image
1. Select "Apply update" and "Apply from ADB" in the phone's recovery interface
1. Run `adb sideload <path to the base image zip>` to sideload the base image to the phone for flashing
1. Reboot the phone

*Note that these steps are specific to the OnePlus 7 Pro.
Do not follow this blindly if you have another phone*

## Setting up the ROM

When following my own installation instructions I didn't really think twice about what I needed to back up.
I only backed up the bank app we use for authenticating to a lot of online services here in sweden,
but when I tried to restore it on Lineage it failed for some reason.
In the end I had to resort to asking a friend to fix a new one,
because the bank require you to own a Windows or Mac PC because of proprietary drivers and who even uses linux lmao am i right.

Anyway I also lost a bunch of pictures and two 2FA codes, but other than that I was golden!..

One of the first things I set up on my phones is root,
because I cannot bear not being in control of my own devices.
I use [Magisk](https://github.com/topjohnwu/Magisk) for this,
because apparently SuperSU is owned by a sketchy Chinese company or something.
The installation process is basically just flashing a zip-file,
like with the base image for the ROM.

This time I tried to set up [microG](https://microg.org) too,
because one of the benefits (and drawbacks) of running custom ROMs is the lack of Google Play Services.
If you don't know about Google Play Services,
it's basically a spooky service that has a lot of control over your phone,
and it's connected to your google account (obviously).
And if you don't know about microG,
it's basically an open-source replacement for Google Play Services which put's *you* in control of what it does.
One part of what microG does is to enable Google Cloud Messaging,
which many apps use for sending notifications to your phone (one of which being Discord).

I have tried installing microG before, but never really got it to work.
This time however, I did.
And the journey to how I did it is the reason I'm writing this blog post in the first place.

## Setting up Google Cloud Messaging with microG

So, I'll write this as another list, because there are a ridiculus number of steps to this.

1. Make sure you have no other Google Play Services -replacements installed. I had installed a library to get GCam working which prevented me from installing microG
1. If the installed ROM doesn't natively support *signature spoofing*:
	1. Flash the Magisk plugin [Riru](https://github.com/RikkaApps/Riru)
	1. Flash the Magisk plugin [Riru - LSPosed](https://github.com/naicfeng/LSPosed)
	1. Reboot
	1. Download and install [FakeGApps](https://github.com/whew-inc/FakeGApps) from F-Droid or GitHub
	1. In the LSPosed settings, enable the FakeGApps module, and activate it for the recommended apps
1. Download and install `GmsCore.apk` from F-Droid or GitHub
1. Download and install `GsfProxy.apk` from F-Droid or GitHub
1. Download and install `FakeStore.apk` from F-Droid or GitHub
1. Open the microG app (GmsCore) on your phone, click "Self-Check" and make sure all the boxes are ticked
1. In the microG app, enable "Google device registration" and "Cloud Messaging".
1. Install `Discord` from your preferred Google Play Store alternative. If you've already installed it, you need to reinstall it
1. When you start Discord the first time you will be asked if you want to register Discord for cloud messaging. Click yes.

### Explanations and clarifications

- Signature spoofing allows certain apps you allow to override their signatures, which basically means they can pretend to be app that they are not. This is required for allowing microG to pretend that it's actually Google Play Services itself.
- Riru is kind of like a module platform which allows modules to do low-level stuff on the phone. To be honest, I'm not really sure what it does
- The Riru LSPosed module is a layer of "glue" up to the XPosed framework, which allows apps to also do low-level stuff on the phone.
- There are other methods of enabling signature spoofing, but this is the only method I found which didn't rely on writing sketchy commands in a terminal running adb

## Other things I use on my phone

In case someone cares about this (who am I kidding, this blog is literally about the things no one asks me),
here are some other things I like to set up and use on my phone:

- Syncthing for file syncronization between my phone and my computer
- FairEmail as a mail client
- DavX⁵ for synchronizing calendar events and contacts with my WebCal server
- GCam for better photos and auxillary camera support
- FlorisBoar for an open source keyboard
- Scoop for error catching (how the ~~fuck~~ is this not a standard feature of android????)
- Termux for a linux environment on my phone (or even better NixOnDroid)
- OsmAnd~ for replacing Google Maps
- Aurora store for replacing Google Play Store
- Aegis for managing my 2FA-keys
- Passwordstore + OpenKeychain for decrypting and managing my passwords on my phone

## Conclusion

I hope this blog post has given you some insight to the amount of things needed to use an alternative android ROM.
Of course the ROMs are usable without this,
but if you really want a fully functional *and* open source android phone
you really have to walk a thousand miles.
Looking back at the time I've spent on this I could probably have spent it better,
but at least i recieve Discord notifications now.
