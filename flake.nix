{
  description = "A flake for generating the content of my website";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-unstable;
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
            age = builtins.readFile (
              pkgs.runCommand
              "age"
              { buildInputs = with pkgs; [ dateutils ]; }
              "datediff 20020219101400 ${self.lastModifiedDate} -i %Y%m%d%H%M%S -f %Y > $out"
            );
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
            { date = "2022-02-02"; title = "How I Rebuilt This Website"; }
            { date = "2021-10-08"; title = "Android Sucks";              }
            { date = "2021-09-18"; title = "My Battlestation Part 2";    }
            { date = "2021-08-23"; title = "My Battlestation Part 1";    }
            { date = "2021-06-05"; title = "How I Built This Website";   }
          ];

          blogPages = let
            linkOf = page: "/${page.date}-${camelCaseToKebabCase page.title}";
          in {
            index = mkFile "/index.html" (customHtmlTemplate {
              title = "No one asked";
              body = ./src/blog/index.md;
              extraSubs = {
                blog = builtins.concatStringsSep "\n" (
                  map (value: "- [${value.date} ${value.title}](/blog${linkOf value})") blogPagesList
                );
              };
            });
          } // builtins.listToAttrs (map (blogPost: {
            name = blogPost.date;
            value = mkFile "${linkOf blogPost}.html" (customHtmlTemplate {
              title = blogPost.title;
              body = ./src/blog + (linkOf blogPost) + ".md";
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
        in [
          (mkFile "/index.html" (customHtmlTemplate {
            title = "NomisIV";
            body = ./src/index.md;
          }))

          (mkFile "/about.html" (customHtmlTemplate {
            title = "About Me";
            body = ./src/about.md;
          }))

          (mkFile "/contact.html" (customHtmlTemplate {
            title = "Contact Me";
            body = ./src/contact.md;
          }))

          (mkFile "/lists.html" (customHtmlTemplate {
            title = "My Lists";
            body = ./src/lists.md;
          }))

          (mkFile "/projects.html" (customHtmlTemplate {
            title = "My Projects";
            body = ./src/projects.md;
          }))

          (mkFile "/wishlist.html" (customHtmlTemplate {
            title = "Wishlist";
            body = ./src/wishlist.md;
          }))

          (mkFile "/cv-se.html" (customHtmlTemplate {
            title = "CV - Simon Gutgesell";
            body = ./src/cv-se.md;
          }))

          (mkFile "/cv-en.html" (customHtmlTemplate {
            title = "CV - Simon Gutgesell";
            body = ./src/cv-en.md;
          }))

          (mkFile "/cv-se.pdf" (
            mdToPdf
            (substitute substitutions ./src/cv-se.md)
            (scssToCss (substitute { diosevka = diosevka.packages.x86_64-linux.ttf; } ./src/pdf.scss))
          ))

          (mkFile "/cv-en.pdf" (
            mdToPdf
            (substitute substitutions ./src/cv-en.md)
            (scssToCss (substitute { diosevka = diosevka.packages.x86_64-linux.ttf; } ./src/pdf.scss))
          ))

          (mkFile "/style.css" (scssToCss ./src/style.scss))

          (mkFile "/favicon.ico" (svgToIco ./src/favicon.svg))

          (mkFile "/robots.txt" ./src/robots.txt)

          (mkFolder "/assets" assetsPages)

          (mkFolder "/blog" blogPages)

          (mkFolder "/errors" errorPages)
        ];
      };
    };
}
