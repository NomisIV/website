# Projects in the cradle

## `tim` - Terminal Interface Mail client

There isn't a single non-sucky email client for the terminal.
Most of them are just unnecessarily complicated, or terrible to configure.
So I decided to write my own in rust :)

### Features

- It's configured *sensibly* in TOML
- First class multi account support
- IMAP + SMTP only. (POP is kinda dead)
- Just works. (Not yet though)

# Current Projects

These are (most of) my programming projects,
where I create what I want, how I want.
They are roughly arranged in chronological order.

## This website

[Link to GitHub](https://github.com/NomisIV/servera)

If you are interested in how this website works,
you can read my blog post explaining it [here](/blog/how-i-built-this-website)

## `swayhide` - A window swallower for sway

[Link to GitHub](https://github.com/NomisIV/swayhide)

This is a small piece I wrote because I couldn't find an alternative.
It's *heavily* based on
[jamesofarrell/i3-swallow](https://github.com/jamesofarrell/i3-swallow)
but, *of course*, rewritten in Rust because I'm a masochist or something.

It's a *window swallower*, which's purpose is to "swallow" / hide windows.
The main purpose of this program is to hide a terminal window when starting
a graphical program in it.

## `pioneerctl` - A remote control for *some* pioneer recievers

[Link to GitHub](https://github.com/NomisIV/pioneerctl)

This is a CLI remote for older network-enabled Pioneer recievers.
It's actively developed in rust,
and the only offically supported reciever is my VSX-923,
because it's the only one I have to test on.

This project started as a school project,
written as a graphical and java-based program,
and inspired by the android app [mkulesh/onpc](https://github.com/mkulesh/onpc).

# Old projects

I leave no guarantees on the quality of the code!

## D-LAN 2021

[Link to current website](https://d-lan.se)

In 2020/2021 I managed the website for a yearly LAN-party held at the campus of my college.
I wrote the back-end in node, and the front-end was created using a custom
library for making HTML pages with TypeScript code.
The styling was done with SCSS compiled to CSS.

## Kylbrants Foton (Kylbrant's Photos)

[Link to the website](https://kylbrants-foton.se/)

This is a website I made as a school project.
It is a photo shop for a hobbyist photographer that worked at the farm I lived in at the time.
I'm really proud of the CSS :)

## js-datepicker

[Link to GitHub](https://github.com/NomisIV/js-datepicker)

I couldn't find a datepicker that I liked for Ullvischema, so I built my own.

## Ullvischema.tk

[Link to GitHub](https://github.com/NomisIV/ullvischema.tk)

In high school the web-based schedule viewer was trash, so I built my own.
This was my first software project ever,
and the client-side JavaScript were the first lines of code I've ever written.

In practice it wasn't that difficult though.
The schedule was loaded as an image, with parameters in the url.
All I had to do was to whip up some relevant parameters,
craft a url with them,
and ask their servers for that particular image.
It worked wonders though :)
