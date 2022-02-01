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

      substitutions = {
        age = toString 19; # TODO: Make sure this is up to date
        # TODO: Make an obfuscator function for this
        email = "<a href=\"&#109;&#97;&#105;&#108;&#116;&#111;&#58;&#115;&#105;&#109;&#111;&#110;&#64;&#110;&#111;&#109;&#105;&#115;&#105;&#118;&#46;&#99;&#111;&#109;\">&#115;&#105;&#109;&#111;&#110;&#64;&#110;&#111;&#109;&#105;&#115;&#105;&#118;&#46;&#99;&#111;&#109;</a>";
      };

      customHtmlTemplate = { title, body }: lib.htmlTemplate (let
        description = pkgs.lib.strings.escapeXML "This is my personal website, where you can read about me and my projects. I also have a blog called \"No one asked\", where I answer questions that no one asked.";
      in {
        inherit title description;
        body = lib.substitute substitutions (lib.mdToHtml body);
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

      customErrorHtmlTemplate = { title, body }: lib.htmlTemplate {
        inherit title;
        body = lib.mdToHtml body;
        favicon = "/favicon.ico";
        stylesheets = [ "/style.css" ];
        themeColor = "#cc241d";
      };
    in
    with lib;
    {
      defaultPackage.x86_64-linux = mkSite {
        base_url = "nomisiv.com";
        pages = let
          assetsPages = {
            logo = mkFile "/nomisiv.svg" ./src/assets/nomisiv.svg;
            card = mkFile "/card.png" ./src/assets/card.png;
            diosevka = mkFile "/fonts/" (diosevka.packages.x86_64-linux.woff2 + "/share/fonts/diosevka/woff2");
          };

          blogPages = {
            index = mkFile "/index.html" (customHtmlTemplate {
              title = "No one asked";
              body = substitute {
                blog = builtins.concatStringsSep "\n" (
                  builtins.map (value: "- [${value.name}](${value.link})") blogPagesFancy
                  );
                } ./src/blog/index.md;
            });

            android-sucks = mkFile "/2021-10-08-android-sucks.html" (customHtmlTemplate {
              title = "Android Sucks";
              body = ./src/blog/2021-10-08-android-sucks.md;
            });
          };

          # TODO: Somehow derive this from blogPages
          blogPagesFancy = [
            { name = "2021-10-08 Android Sucks"; link = "/blog/2021-10-08-android-sucks"; }
          ];

          errorPages = {
            e404 = mkFile "/404.html" (customErrorHtmlTemplate {
              title = "404 Not Found";
              body = ./src/errors/404.md;
            });

            e500 = mkFile "/500.html" (customErrorHtmlTemplate {
              title = "500 Internal Server Error";
              body = ./src/errors/500.md;
            });
          };
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

          cv-se-pdf = mkFile "/cv-se.pdf" (mdToPdf (substitute substitutions ./src/cv-se.md));

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
