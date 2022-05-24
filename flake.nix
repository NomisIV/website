{
  description = "A flake for generating the content of my website";

  outputs = {
    self,
    nixpkgs,
    diosevka,
    servera,
  }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    lib = import ./lib.nix {inherit pkgs;};
  in
    with lib; {
      nixosModule = {
        lib,
        config,
        ...
      }: let
        cfg = config.services.nomisiv-website;
      in {
        options.services.nomisiv-website = with lib; {
          enable = mkEnableOption "NomisIV's website";

          openFirewall =
            mkEnableOption
            "open the port for the website in the firewall";

          port = mkOption {
            type = types.port;
            default = 8000;
            description = "The port to serve the website at";
          };

          user = mkOption {
            type = types.str;
            default = "nomisiv-website";
            description = "The user to run the website as";
          };

          group = mkOption {
            type = types.str;
            default = "nomisiv-website";
            description = "The group to run the website as";
          };
        };

        config = lib.mkIf cfg.enable {
          systemd.services.nomisiv-website = {
            description = "NomisIV website web server";
            after = ["network.target"];
            requires = ["network.target"];
            wantedBy = ["multi-user.target"];

            serviceConfig = {
              ExecStart = "${servera.packages.x86_64-linux.default}/bin/servera ${toString cfg.port} ${self.packages.x86_64-linux.default}";
              User = cfg.user;
              Group = cfg.group;
            };
          };

          # Open firewall
          networking.firewall = lib.mkIf cfg.openFirewall {
            allowedTCPPorts = [cfg.port];
          };

          # Add user and group
          users.users = lib.mkIf (cfg.user == "nomisiv-website") {
            nomisiv-website = {
              group = cfg.group;
              uid = 350;
            };
          };

          users.groups = lib.mkIf (cfg.group == "nomisiv-website") {
            nomisiv-website.gid = 350;
          };
        };
      };

      packages.x86_64-linux.default = mkSite "nomisiv.com" (let
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
          htmlTemplate (let
            description =
              pkgs.lib.strings.escapeXML
              (builtins.readFile ./description.txt);
          in {
            inherit title description;
            body = mdToHtml (substitute (substitutions // extraSubs) body);
            favicon = "/favicon.ico";
            stylesheets = ["/style.css"];
            themeColor = "#d79921";
            openGraph = {
              inherit description;
              url = "nomisiv.com";
              title = title;
              image = "/assets/card.png";
            };
          });

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

        "robots.txt" = ./src/robots.txt;

        assets = {
          "nomisiv.svg" = ./src/assets/nomisiv.svg;
          "card.png" = ./src/assets/card.png;
          fonts =
            diosevka.packages.x86_64-linux.woff2
            + "/share/fonts/diosevka/woff2";
          memes = ./src/assets/memes;
        };

        blog = let
          blogPagesList = [
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
              value = htmlTemplate {
                title = "${toString errorPage.code} ${errorPage.message}";
                body = mdToHtml (
                  ./src/errors
                  + ("/" + toString errorPage.code)
                  + ".md"
                );
                favicon = "/favicon.ico";
                stylesheets = ["/style.css"];
                themeColor = "#cc241d";
              };
            })
            errorPagesList);
      });

      formatter.x86_64-linux = pkgs.alejandra;
    };
}
