# Updating My Server

I have my own server in my closet,
hosting various services like this website
and various game servers too.
It runs NixOS just like every other computer of mine,
and it did this off of three hard drives (1x 160GB and 2x 1TB).
In NixOS I had these drives configured in LVM
to make one big partition.

## The IO-wait problem

While the mega composite drive worked great,
I had some problems with IO-wait.
For non-linux and tech -users,
this is essentially the time that the processor waits for data from
the hard drives,
and high numbers indicate that the disks are a bottleneck of the system.

When loading my server with demanding tasks,
and especially when updating,
I could easily get spikes of IO-wait up to 70-80%.
This, was less than ideal.

Another problem was the lack of any redundancy in the storage configuration.
If any drive failed, I'd lose data.
This is also less than ideal for a 100% uptime server.

## Ordering my hard drives

After some searching online I found someone selling hard drives for cheap.
I bought two of them, since I already had two 1TB drives.

## Installing the hard drives

Since there were only three drive carriages in the server when I bought it,
I couldn't fit all the hard drives in their own carriages.
I had to think outside the box,
and using an eraser, I managed to prop up one hard drive on top of another,
without bending the port too much.

## Updating the BIOS

I had already had a crack at this a while ago,
but ultimately I gave up because I just couldn't get it to work.
There are different ways to go about doing this,
but none of the ways seemed to work like they should.
This time I remembered that I have a work laptop with windows on it,
so I could use that to create a bootable Windows 10 USB,
and then install that on the server.

### Windows 10 USB shenanigans

Creating a bootable Windows 10 USB drive should be a quite straightforward
process.
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
