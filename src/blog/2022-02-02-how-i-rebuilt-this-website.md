# How I rebuilt this website

**NOTE:** You can read about how my website used to work
[here](/blog/2021-06-05-how-i-built-this-website).
This blog post will assume you've read the old blog post.

## The problem

While most of the old design had good ideas, there were some shortcomings.
As it turns out, spawning a child process to generate dynamic content is slow.
I don't mean that it's *slow* slow, but when it comes to a web server everything
needs to be super fast.
There is a model called the waterfall model which is used when analyzing load
times for webservers,
as it clearly shows the stages in the process which takes the most time.
Most of these steps usually take one or two milliseconds.
Some might take a handful.
And then the page generation takes 50ms,
so yeah, it's actually a lot.

## The solution

But fear not, as I was already thinking of a solution while discovering this.
In my constant search to make the web server faster yet,
I had found a rust crate which seemed very promising:
[cached](https://crates.io/crates/cached).
Basically,
I could just annotate the functions I wanted to be cached in the web server,
so that the result wouldn't be calculated every time I called it.
I actually went as far as to cache every single response,
and was really impressed with how I with minor effort had sped up the web sever
tenfold.

But the solution wasn't perfect,
because sometimes the cache would have to refresh.
And that meant waiting those dreaded 50ms.

![I've won but at what cost](/assets/memes/ive-won-but-at-what-cost.jpg)

## Another solution

So then I thought to myself:

> Why don't I just give up on this and generate the content beforehand like
> a normal person?

And with this I found inspiration in the
[nixos-homepage](https://github.com/NixOS/nixos-homepage)
repository.
Because of course I need to build everything with nix.
Their approach to things was to generate the content statically using a
`Makefile`, and then wrap that in a nix flake.
For me this came with the added bonus of being able to integrate my custom
build of [Iosevka](https://typeof.net/Iosevka/)
(called [Diosevka](https://github.com/NomisIV/diosevka))
into the website sources with minimal pain.

Writing the Makefile, I discovered what a joy it is.
It almost feels like magic when your project finally builds using one single
command.

All in all, this solution worked great,
but I still felt like it could be better.

## Falling down the rabbit hole of using nix for everything

Then one day I found the
[styx](https://github.com/styx-static/styx)
static site generator,
which caught my attention.

> Wait I can build my entire website in Nix??

Trying it out, however, I got the feeling of being too handheld,
as it's difficult to see what's actually going on.
I usually get this feeling when trying new frameworks and tools out.
Nix as a language doesn't make this any better,
since it's a great language for abstracting things and hiding complexities.
So instead I decided to try to make my own custom static site generator in nix.
And while experimenting I saw a lot of promise.

### Side note:

While writing anything moderately complex in nix,
you probably want to use functions.
Here are the documentation pages that I used when writing
my own static site generator:

- [nixpkgs library functions](https://nixos.org/manual/nixpkgs/stable/#sec-functions-library)
- [nix builtin functions](https://nixos.org/manual/nix/unstable/expressions/builtins.html)

You're welcome.

## The new website

Just like before, the contents of the website is written in markdown.
However, now it's converted to html using nix, `cmark-gfm`,
and some more nix magic.
If you're interested in understanding how it works,
you can read the source code
[here](https://github.com/NomisIV/website/blob/master/lib.nix).

Since the web server didn't have to convert the content on the fly anymore,
I could technically have used whatever webserver I wanted to.
However, I could not find a single server that did everything I wanted to,
so I just repurposed the old server to a new and very general one.
You can read more about it [here](https://github.com/NomisIV/servera).
