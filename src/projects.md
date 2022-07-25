# Current Projects

These are (most of) my programming projects,
where I create what I want, how I want.
They are roughly arranged in chronological order.

## `polygraph` - A system statistics visualizer

Is Grafana too complicated?
Is netdata cool, but a bit too quirky and rigid?
PolyGraph will let you view metrics and statistics from your computer in the browser,
but without the pain.
The backend is written in rust,
and the frontend in elm (at least for now).

## `planera` - A TUI calendar program

`planera` is a TUI program for scheduling.
It understands CalDav and iCal calendars,
and can generate a schedule and an agenda from them.
This is useful for accessing a [radicale](https://radicale.org) server
from the terminal.

## `swayhide` - A window swallower for sway

[Link to GitHub](https://github.com/NomisIV/swayhide)

This is a small piece I wrote because I couldn't find an alternative.
It's *heavily* based on
[jamesofarrell/i3-swallow](https://github.com/jamesofarrell/i3-swallow)
but, *of course*, rewritten in Rust because I'm a masochist or something.

It's a *window swallower*, which's purpose is to "swallow" / hide windows.
The main purpose of this program is to hide a terminal window when starting
a graphical program in it.

# Old projects

I leave no guarantees on the quality of the code!

## `sand` - A sandbox programming language

[Link to GitHub](https://github.com/NomisIV/sand)

I'm writing my own programming language called sand.
I think it will be a purely functional and object oriented language,
if that isn't an oxymoron.
The syntax kind of looks like a mix of Ruby and Rust.
Currently I have only implemented a proof-of-concept parser and interpreter,
which is advanced enough to run a simple hello world program.

## `pioneerctl` - A remote control for *some* pioneer recievers

[Link to GitHub](https://github.com/NomisIV/pioneerctl)

This is a CLI remote for older network-enabled Pioneer recievers.
It's actively developed in rust,
and the only offically supported reciever is my VSX-923,
because it's the only one I have to test on.

This project started as a school project,
written as a graphical and java-based program,
and inspired by the android app [mkulesh/onpc](https://github.com/mkulesh/onpc).

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
