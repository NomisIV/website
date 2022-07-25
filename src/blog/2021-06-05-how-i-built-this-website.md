# How I built this website

**NOTE:** This blog post has been superseded by [this one](/blog/2022-02-02-how-i-rebuilt-this-website) instead

## Starting a new web project

The first thing to do when starting a new project is chosing a programming language.
I'm quite a fan of [rust](https://runst-lang.org),
and there are many web frameworks in the [cargo](https://crates.io) repositories,
so this was quite an easy choice.
However when it came to which web framework to use I wasn't as sure.
I had already tried [rocket](https://rocket.rs),
but it requires the absolutely latest version of rust,
which I didn't want to bother with.
So instead I settled for [actix](https://actix.rs/).
It's a very boring web framework,
but it does exactly what it should.

A week after I discovered that rocket had a beta version,
which successfully compiled using normal rust.
So I switched.

## Design

I had recently started exploring the
[gopher](https://en.wikipedia.org/wiki/Gopher_%28protocol%29)
and
[gemini](https://gemini.circumlunar.space/)
protocols,
and I really enjoyed their conservative approach.
The idea is that you only can have text and links on a website.

No images. No CSS. No JS.

To mimic the style of that using the normal web technologies,
I had to restrain myself from creating cool JavaScript and fancy animations.
This came with the benefit of being able to focus more on the actual content,
rather than the presentation.
I can spend hours on writing fancy CSS,
but fancy CSS doesn't make a website alone:
content does.

Whilst I constrained the format to be spartan,
I allowed myself to still make it look fancy.
The colors on this website are taken from the
[gruvbox colorscheme](https://github.com/gruvbox-community/gruvbox),
and the font is my own version of
[Iosevka](https://typeof.net/Iosevka).
I also tried to keep some markdown artefacts,
to make it look more advanced.

## Techical design

Let's get into the really nerdy stuff now!

### Content

One of the first things I decided was to not write a single html file.
The first reason being that html offers more than I need.
Remember, I needed to restrict myself.
The second reason is that it's a horrible markup language to write in.
So instead I'm using markdown.
It's minimalistic,
and it's common enough to have good support in programming languages.
But since web browsers cannot render markdown like they render html,
I convert the markdown to html on my server,
before sending it to your browser.

### Styling

When it came to styling,
I wanted to "enhance" my developer experince like I had with html.
I had a little experience with
[sass](https://sass-lang.com/)
from another web project,
and I found a crate (code library) that could convert sass to css for me.
*Great!*
So all the sass I write is compiled to a single css file,
which is then included in every website.
When I figure out how to make the browser cache it,
it will only have to download it once!

### Dynamic content

Due to markdown being so limited,
I had no way of creating dynamic content
(like the lists of all pages on the front page).
To remedy this,
I wanted another layer of "enhancement" with templating functionality.
I wanted to be able to specify a point in a markdown document
where I wanted the dynamic content to be inserted,
and then I also wanted a way to generate the content
in some sort of scripting language.

But what language would I use?

I had some experience with lua,
and it's supposedly specifically developed for integrating into stuff.
I had a go with it,
but quickly realized that you couldn't list a directory.
[This](https://stackoverflow.com/questions/5303174/how-to-get-list-of-directories-in-lua)
is litterally the only solution I could find,
where you would spawn an external shell command.
So a child process *inside* a child process.
Yeah, no. There has to be a better way.

The better way that I found was to take a step back.
You can easily generate text in any programming language,
the hard part is getting it *into* the document.
But then it hit me that it's very easy to run a child process in rust,
and more importantly, get it's output
(which would have been in a terminal, had it been run normally).
The completed solution is that
the tags where I want dynamic content to be inserted
*include* the command to run to get it's output.
I decided to use python as the language of choice here,
because it's kind of like shell scripting but *actually good*,
which was about the functionality I was looking for.

Example time:
Let's say I want to generate my age dynamically.
What I then do is that I insert `$\{my age}` (but without the backslash)
where I would like my age to be inserted.
When the server sees that tag,
it runs the `my age` command as a subprocess,
and substitutes the output of the command with the tag itself.

It's  super convenient!

## Project organization

This is still technical, but I'll try to keep it breif.

### Data separation

I have organized the project so that
the web server is completely separate from the content.
This is useful,
since it means I can distribute the server without distributing the contents
of the website.

### Building

The project is built using
[nix](https://nixos.org)
and
[naersk](https://github.com/nix-community/naersk),
and finally it's packaged into a [docker](https://www.docker.com/)-container
before it's put on my server.

### Viewing the source code

Of course you can take a look at the source code of the website
[here](https://github.com/NomisIV/servera)
