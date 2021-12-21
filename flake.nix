{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs;
    diosevka.url = github:NomisIV/diosevka;
  };

  outputs = inputs: with inputs; let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;

    dependencies = with pkgs; [
      sassc # TODO: Package a new rust sass library instead
      cmark-gfm
      imagemagick
      python3
      which
      minify
    ];

    website = pkgs.stdenv.mkDerivation {
      name = "nomisiv.com";
      src = self;
      buildInputs = dependencies;
      postPatch = ''
        patchShebangs ./scripts
      '';
      makeFlags = [
        "DIOSEVKA=${diosevka.packages.x86_64-linux.woff2}/share/fonts/iosevka/woff2"
        "DATA=src"
        "OUT=build"
      ];
      installPhase = ''
        cp -r build $out
      '';
    };
  in {
    defaultPackage.x86_64-linux = website;
    devShell.x86_64-linux = pkgs.mkShell {
      buildInputs = dependencies;
    };
  };
}