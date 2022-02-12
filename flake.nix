{
  description = "A flake for generating the content of my website";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs;
    diosevka.url = github:NomisIV/diosevka;
  };

  outputs = inputs:
    with inputs;
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      lib = import ./lib.nix { inherit pkgs; };
    in
    with lib;
    {
      defaultPackage.x86_64-linux = mkSite {
        base_url = "nomisiv.com";
        pages = let
          substitutions = {
            age = toString 19; # TODO: Make sure this is up to date
            email = pkgs.lib.strings.removeSuffix "\n" (builtins.readFile ./email.html);
          };

          customHtmlTemplate = { title, body, extraSubs ? { } }: htmlTemplate (let
            description = pkgs.lib.strings.escapeXML (builtins.readFile ./description.txt);
          in {
            inherit title description;
            body = mdToHtml (substitute (substitutions // extraSubs) body);
            favicon = "/favicon.ico";
            stylesheets = [ "/style.css" ];
            themeColor = "#d79921";
            openGraph = {
              inherit description;
              url = "nomisiv.com";
              title = title;
              image = "/assets/card.png";
            };
          });

          assetsPages = {
            logo = mkFile "/nomisiv.svg" ./src/assets/nomisiv.svg;
            card = mkFile "/card.png" ./src/assets/card.png;
            diosevka = mkFile "/fonts/" (diosevka.packages.x86_64-linux.woff2 + "/share/fonts/diosevka/woff2");
            memes = mkFile "/memes/" ./src/assets/memes;
          };

          blogPagesList = [
            { date = "2022-02-02"; title = "How I Rebuilt This Website"; link = "/2022-02-02-how-i-rebuilt-this-website"; }
            { date = "2021-10-08"; title = "Android Sucks";              link = "/2021-10-08-android-sucks";              }
            { date = "2021-09-18"; title = "My Battlestation Part 2";    link = "/2021-09-18-my-battlestation-part-2";    }
            { date = "2021-08-23"; title = "My Battlestation Part 1";    link = "/2021-08-23-my-battlestation-part-1";    }
            { date = "2021-06-05"; title = "How I Built This Website";   link = "/2021-06-05-how-i-built-this-website";   }
          ];

          blogPages = {
            index = mkFile "/index.html" (customHtmlTemplate {
              title = "No one asked";
              body = ./src/blog/index.md;
              extraSubs = {
                blog = builtins.concatStringsSep "\n" (
                  map (value: "- [${value.date} ${value.title}](/blog${value.link})") blogPagesList
                );
              };
            });
          } // builtins.listToAttrs (map (blogPost: {
            name = blogPost.date;
            value = mkFile "${blogPost.link}.html" (customHtmlTemplate {
              title = blogPost.title;
              body = ./src/blog + blogPost.link + ".md";
            });
          }) blogPagesList);

          errorPagesList = [
            { code = 404; message = "Not Found";             }
            { code = 500; message = "Internal server Error"; }
          ];

          errorPages = builtins.listToAttrs (map (errorPage: {
            name = "e${toString errorPage.code}";
            value = mkFile "/${toString errorPage.code}.html" (htmlTemplate {
              title = "${toString errorPage.code} ${errorPage.message}";
              body = mdToHtml (./src/errors + ("/" + toString errorPage.code) + ".md");
              favicon = "/favicon.ico";
              stylesheets = [ "/style.css" ];
              themeColor = "#cc241d";
            });
          }) errorPagesList);
        in {
          index = mkFile "/index.html" (customHtmlTemplate {
            title = "NomisIV";
            body = ./src/index.md;
          });

          about = mkFile "/about.html" (customHtmlTemplate {
            title = "About Me";
            body = ./src/about.md;
          });

          contact = mkFile "/contact.html" (customHtmlTemplate {
            title = "Contact Me";
            body = ./src/contact.md;
          });

          lists = mkFile "/lists.html" (customHtmlTemplate {
            title = "My Lists";
            body = ./src/lists.md;
          });

          projects = mkFile "/projects.html" (customHtmlTemplate {
            title = "My Projects";
            body = ./src/projects.md;
          });

          wishlist = mkFile "/wishlist.html" (customHtmlTemplate {
            title = "Wishlist";
            body = ./src/wishlist.md;
          });

          cv-se = mkFile "/cv-se.html" (customHtmlTemplate {
            title = "CV - Simon Gutgesell";
            body = ./src/cv-se.md;
          });

          cv-se-pdf = mkFile "/cv-se.pdf" (
            mdToPdf
            (substitute substitutions ./src/cv-se.md)
            (scssToCss (substitute { diosevka = diosevka.packages.x86_64-linux.ttf; } ./src/pdf.scss))
          );

          style = mkFile "/style.css" (scssToCss ./src/style.scss);

          favicon = mkFile "/favicon.ico" (svgToIco ./src/favicon.svg);

          robots = mkFile "/robots.txt" ./src/robots.txt;

          assets = mkFolder "/assets" assetsPages;

          blog = mkFolder "/blog" blogPages;

          errors = mkFolder "/errors" errorPages;
        };
      };
    };
}
