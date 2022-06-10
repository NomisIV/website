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
    nixosModule.default = (import ./module.nix) inputs;

    packages.x86_64-linux.default = (import ./site.nix) inputs;

    formatter.x86_64-linux = pkgs.alejandra;
  };
}
