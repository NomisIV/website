# Updating My Server

I have an HP Z800 in my closet, acting as my server.
It hosts this website, some personal stuff,
and a couple game servers.
It ran NixOS off of three hard drives (1x 160GB and 2x 1TB),
which were configured to make one big partition using LVM.

![An image of an HP Z800 with the side panel off](https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fimages.harlander.com%2Fartikel%2F1000x1000%2Fhp-z800-3.jpg&f=1&nofb=1)

> NomisIV: Isn't it magnificent?

## The IO-wait problem

While the mega composite drive worked great,
I had some problems with IO-wait.
This is essentially how much time the processor waits for data from
the hard drives, so lower numbers are better.

When loading my server with demanding tasks,
and especially when updating,
I would easily get spikes of IO-wait up to 70-80%.
It would almost freeze the server, and made everything really sluggish.
This was less than ideal.

Another problem was the lack of any redundancy in the storage configuration.
If any drive failed, I'd obviously lose data.
This is also less than ideal for a 100% uptime server.

## The new hard drives

After some searching online I found someone selling hard drives for cheap.
I bought two of them, to make up a total of four 1TB drives.

Since there were only three drive carriages in the server when I bought it,
I couldn't fit all the hard drives in their own carriages.
Thinking outside the box,
I managed to prop up one hard drive on top of another using an eraser.

## Updating the BIOS

After installing the hard drives using questionable -
albeit *revertible* - methods,
I wanted to update the BIOS to the latest version.
I had already had a crack at this a while ago,
but ultimately I gave up because I just couldn't get it to work.
There are different ways to go about doing it,
but none of the ways seemed to work like they should.
This time I didn't forget that I have a work laptop with windows on it,
so I could use that to create a bootable Windows 10 USB,
and then temporarily install it on the server solely to update the BIOS.

### Windows 10 USB shenanigans

Creating a bootable Windows 10 USB drive is quite a straightforward process.
You download a program off of Microsoft's website,
and then you launch it and navigate the options it presents
while waiting at least a minute between every step.
And if you're lucky you don't have to restart the process,
waiting on all the same steps again.

After the first time of the quiz,
I reached a bad end, where it didn't find my USB drive.
"Fine", I thought, "I'll just reformat it".
I opened disk management in Windows,
and immediately got disappointed,
as Windows didn't dare touch the USB because of the EFI partition it contained
(indicating that it was bootable).
So I moved back to Linux, and used trusty `fdisk` to give it a fresh partition
table.
Then I realized that Windows 10 doesn't recognize a drive if it's empty,
But after using `fdisk` to format the drive and giving it a `vfat` partition,
Windows finally recognized it.
Huzzah.

And then it was just a matter of waiting a bit more for the quizlet setup
to complete.

However, after all this effort, Windows 10 said that it couldn't install
onto the new RAID setup, and referred me to the installation log file
(which is where, exactly??).

Then I tried using Windows to format the USB drive to a proper FAT32
partition, moved the BIOS binary there and it just worked.

## Installing NixOS

So now that I've passed the hard part I just have to install NixOS,
which in theory is super simple:

1. Prepare the disks
1. Mount the partitions
1. `git clone <repo>` or `nixos-generate-config --root /mnt`
1. `nixos-install`

However, there were more problems to rectify.
Probably because the RAID card was intel based,
it could integrate nicely with the Linux kernel,
which meant that instead of just not having to worry about it,
the parity checking was handled in it's own process.
This meant including the right drivers,
and also performing the right command-dances to get `mdadm` to find the root
partition at boot.

Eventually I just gave up, and returned to LVM,
like I had done before.
And to my surprise, LVM actually used the same tools to manage the RAID setup,
but it actually just handled it without problem.

Finally, I had updated my server.
Why is it that the seemingly simple things end up being so difficult?
