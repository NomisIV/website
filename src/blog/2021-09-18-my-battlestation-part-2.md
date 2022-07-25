# My Battlestation - Part 2: Hardware

This is the second blog post in the series about my battlestation.
To read the first post, click [here](/blog/my-battlestation-part-1).

Just like the last post, my intentions with this series is not to *flex*,
but rather to document, review and inform others about my thinking process behind my choices.

For some context about my computer:
Just before Black Friday in 2019,
me and my friends started thinking about building our own computers.
I hadn't really decided what components I wanted, and I wasn't very experienced
(I had acquired most of my knowledge by watching [Linus Tech Tips](https://www.youtube.com/c/LinusTechTips) on YouTube).
So in the end I basically scrambled the list of original parts together in about 15 minutes,
while my friends were driving next towns to the computer hardware store.

## Motherboard

[ASUS TUF B450-PLUS GAMING](https://www.asus.com/Motherboards-Components/Motherboards/TUF-Gaming/TUF-B450-PLUS-GAMING/)

I basically went for the cheapest motherboard I could find that supported the AM4 CPU socket,
for future compatibility.
I have no real complaints, nor praises,
but it does what it should with discrete RGB zones for a subtle *Gamer* look.

## Central Processing Unit

[AMD Ryzen 7 2700X (8 cores)](https://www.amd.com/en/products/cpu/amd-ryzen-7-2700x)

This was about the time where AMD overtook Intel when it came to processors.
I remember comparing this processor to some intel i5 that cost about twice as much,
and only offered 20% more performance.
So AMD was quite an obvious choice.
I wanted something with a lot of cores,
so I opted for the slightly older 2700X instead of the newer 3600.
It costed about the same, and had two more cores.
Another thing I took into consideration was upgrading to a faster processor
(or rather, the fastest the chipset would allow)
once they were getting into the second hand marked for less.

### CPU Cooler

[Corsiar H100X AIO Water Cooler (2x120mm)](https://www.corsair.com/us/en/Categories/Products/Liquid-Cooling/Hydro-Series-H100x-High-Performance-Liquid-CPU-Cooler/p/CW-9060040-WW)

The original configuration for my computer used the stock cooler,
and while it definitely sufficed,
I could not adjust the fan curve to something that wouldn't repeatedly
ramp up and calm back down again.
During the pandemic and online studies I got particularly annoyed at this,
and started looking for something with a bit more *thermal mass*.
In the end I settled for a second hand AIO,
which was cheap and good value.
My only complaint is that the water pump is slightly annoying,
but luckily the sound isn't very penetrative.

## Random Access Memory

[16GB (2x8GB) Corsair Venegance RGB PRO DDR4](https://www.corsair.com/us/en/Categories/Products/Memory/Vengeance-PRO-RGB-Black/p/CMW16GX4M2A2666C16)

I originally went for some HyperX sticks,
but after a lot of troubleshooting and bluescreens I diagnosed them with broken,
and tried my luck with these instead.
I opted for 16GB instead of 32GB, because otherwise I'd never use all 4 RAM-slots on the motherboard.

## Graphical Processing Unit

[XFX Merc 319 AMD Radeon RX 6700 XT](https://www.xfxforce.com/shop/xfx-speedster-merc-319-amd-radeon-tm-rx-6700-xt-black-gaming-graphics-card-with-12gb-gddr6-hdmi-3xdp-amd-rdna-tm-2)

Shortly after upgrading to my latest monitor,
I realized that my "old" RTX 2060 wasn't up for the task in heavier games.
Plus for some linux-related reasons,
I could only ever get the monitor up to 144Hz,
which was a bit sad since I had paid for all 170Hz myself.
I also wanted to try out [wayland](https://wayland.freedesktop.org/) and [swaywm](https://swaywm.org/),
which is the next-gen graphical environment and window manager for linux,
and since sway's Nvidia support only goes as far as the runtime flag `--my-next-gpu-wont-be-nvidia`,
and also since the open source drivers for Nvidia are unofficial and low-key crap,
I was definitely buying a Radeon card.

The problem was that this was in the middle of the global GPU crisis,
where the GPUs I wanted costed even more than I wanted.
However, I was lucky to find a second-hand one for only just as much as the retail price.
This was a great deal at the time.
The card had been used for crypto mining probably since launch,
but since it was so new at the time,
that was only a couple of months at most.

After receiving the card I had some really interesting problems
where the linux kernel I used didn't support the GPU yet.
But after waiting about a week for the kernel update to reach the repos,
things started working.

## Power Supply

[Corsiar RM750](https://www.corsair.com/us/en/Categories/Products/Power-Supply-Units/RM-Series%E2%84%A2/p/CP-9020234-NA)

When choosing the power supply,
I looked for something fully modular
and something powerful enough to power whatever I threw into the computer.
I figured that 750W would probably be enough,
unless I wanted double graphics cards or something,
but since that's kinda dead by now,
that wasn't really something I wanted anyway.

## Case

[Corsiar Carbide 275R Black](https://www.corsair.com/us/en/Categories/Products/Cases/Carbide-Series-275R-Tempered-Glass-Mid-Tower-Gaming-Case/p/CC-9011132-WW)

I wanted a glass side panel on the case,
so I could see all the expensive components I'd just purchased,
and this was basically the cheapest one.
In the end I'm really satisfied with it.
It's got most things in the right places,
and it looks good.
The front panel is removable and also easily customizable with stickers,
which is an added bonus.
