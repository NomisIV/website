{
  description = "A flake for generating the content of my website";

  outputs = {
    self,
    nixpkgs,
    diosevka,
    servera,
  } @ inputs: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    nixosModules.default = (import ./module.nix) inputs;

    packages.x86_64-linux.default = (import ./site.nix) inputs;

    apps.x86_64-linux.default = {
      type = "app";

      program = builtins.toString (pkgs.writeScript "website" ''
        ${servera.packages.x86_64-linux.default}/bin/servera 8000 ${self.packages.x86_64-linux.default}
      '');
    };

    formatter.x86_64-linux = pkgs.alejandra;
  };
}
