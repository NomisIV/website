inputs:
with inputs; let
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  lib = import ./lib.nix {inherit pkgs;};
in
  with lib;
    mkSite "nomisiv.com" (let
      substitutions = {
        age = pkgs.lib.strings.removeSuffix "\n" (builtins.readFile (
          pkgs.runCommand
          "age"
          {buildInputs = with pkgs; [dateutils];}
          "datediff 20020219101400 ${self.lastModifiedDate} \\\
            -i %Y%m%d%H%M%S -f %Y > $out"
        ));
        email =
          pkgs.lib.strings.removeSuffix "\n"
          (builtins.readFile ./email.html);
      };

      customHtmlTemplate = {
        title,
        body,
        extraSubs ? {},
      }:
        htmlTemplate (
          self: let
            header = with pkgs.lib; let
              pathSteps =
                map
                (n: lists.take n (map (strings.removeSuffix ".html") self.path))
                (lists.range 1 (builtins.length self.path));

              pathLinks =
                pkgs.lib.strings.concatMapStringsSep
                " / " (
                  seg:
                    if lists.last seg == "index"
                    then ""
                    else let
                      href = strings.concatStringsSep "/" seg;
                      text = lists.last seg;
                    in "<a href='/${href}'>${text}</a>"
                )
                pathSteps;
            in "<a href='/'>nomisiv.com</a> / ${pathLinks}";

            description =
              pkgs.lib.strings.escapeXML
              (builtins.readFile ./description.txt);
          in {
            inherit title description header;
            body = mdToHtml (substitute (substitutions // extraSubs) body) self;
            footer = "";
            favicon = "/favicon.ico";
            stylesheets = ["/style.css"];
            themeColor = "#d79921";
            openGraph = {
              inherit description;
              url = "nomisiv.com";
              title = title;
              image = "/assets/card.png";
            };
          }
        );

      customMdToPdf = file:
        mdToPdf
        (substitute substitutions file)
        (scssToCss (
          substitute
          {diosevka = diosevka.packages.x86_64-linux.ttf;}
          ./src/pdf.scss
        ));
    in {
      "index.html" = customHtmlTemplate {
        title = "NomisIV";
        body = ./src/index.md;
      };

      "about.html" = customHtmlTemplate {
        title = "About Me";
        body = ./src/about.md;
      };

      "contact.html" = customHtmlTemplate {
        title = "Contact Me";
        body = ./src/contact.md;
      };

      "lists.html" = customHtmlTemplate {
        title = "My Lists";
        body = ./src/lists.md;
      };

      "projects.html" = customHtmlTemplate {
        title = "My Projects";
        body = ./src/projects.md;
      };

      "wishlist.html" = customHtmlTemplate {
        title = "Wishlist";
        body = ./src/wishlist.md;
      };

      "cv-se.html" = customHtmlTemplate {
        title = "CV - Simon Gutgesell";
        body = ./src/cv-se.md;
      };

      "cv-en.html" = customHtmlTemplate {
        title = "CV - Simon Gutgesell";
        body = ./src/cv-en.md;
      };

      "cv-se.pdf" = customMdToPdf ./src/cv-se.md;

      "cv-en.pdf" = customMdToPdf ./src/cv-en.md;

      "style.css" = scssToCss ./src/style.scss;

      "favicon.ico" = svgToIco ./src/favicon.svg;

      "robots.txt" = self: ./src/robots.txt;

      assets = {
        "nomisiv.svg" = self: ./src/assets/nomisiv.svg;
        "card.png" = self: ./src/assets/card.png;
        fonts = self:
          diosevka.packages.x86_64-linux.woff2
          + "/share/fonts/diosevka/woff2";
        memes = self: ./src/assets/memes;
      };

      blog = let
        blogPagesList = [
          {
            date = "2022-06-06";
            title = "Updating My Server";
          }
          {
            date = "2022-02-02";
            title = "How I Rebuilt This Website";
          }
          {
            date = "2021-10-08";
            title = "Android Sucks";
          }
          {
            date = "2021-09-18";
            title = "My Battlestation Part 2";
          }
          {
            date = "2021-08-23";
            title = "My Battlestation Part 1";
          }
          {
            date = "2021-06-05";
            title = "How I Built This Website";
          }
        ];

        linkOf = page: "${page.date}-${camelCaseToKebabCase page.title}";
      in
        {
          "index.html" = customHtmlTemplate {
            title = "No one asked";
            body = ./src/blog/index.md;
            extraSubs = {
              blog = builtins.concatStringsSep "\n" (
                map
                (
                  value: "- [${value.date} ${value.title}](/blog/${linkOf value})"
                )
                blogPagesList
              );
            };
          };
        }
        // builtins.listToAttrs (map (blogPost: {
            name = linkOf blogPost + ".html";
            value = customHtmlTemplate {
              title = blogPost.title;
              body = ./src/blog + ("/" + linkOf blogPost) + ".md";
            };
          })
          blogPagesList);

      errors = let
        errorPagesList = [
          {
            code = 404;
            message = "Not Found";
          }
          {
            code = 500;
            message = "Internal server Error";
          }
        ];
      in
        builtins.listToAttrs (map (errorPage: {
            name = "${toString errorPage.code}.html";
            value = htmlTemplate (self: {
              title = "${toString errorPage.code} ${errorPage.message}";
              description = null;
              openGraph = null;
              header = "";
              footer = "";
              body =
                mdToHtml (
                  ./src/errors
                  + ("/" + toString errorPage.code)
                  + ".md"
                )
                self;
              favicon = "/favicon.ico";
              stylesheets = ["/style.css"];
              themeColor = "#cc241d";
            });
          })
          errorPagesList);
    })
