{
  description = "Flake utils demo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        outlook_src = pkgs.fetchurl {
          url = "https://go.microsoft.com/fwlink/p/?linkid=525137";
          sha256 = "sha256-NUCQo3BbHizAOuY41JASAsMZOwSEIIAjji6HRkjs4Xs=";
          curlOptsList = [ "-L" ];
        };
      in
      {
        packages = rec {
          outlook = pkgs.stdenv.mkDerivation {
            name = "outlook.app";
            src = outlook_src;
            phases = [ "unpackPhase" "installPhase" ];
            unpackPhase = ''
              ${pkgs.xar}/bin/xar -xf $src
              cat Microsoft_Outlook.pkg/Payload | gunzip -dc | ${pkgs.cpio}/bin/cpio -i
            '';
            installPhase = ''
              mkdir -p $out/Applications
              cp -r Microsoft\ Outlook.app $out/Applications/Microsoft\ Outlook.app
            '';
          };
          outlookWrapper = pkgs.writeShellScriptBin "outlookWrapper" ''
            open ${outlook}/Applications/Microsoft\ Outlook.app
          '';
          default = outlook;
        };
        apps = rec {
          outlook = flake-utils.lib.mkApp { drv = self.packages.${system}.outlookWrapper; };
          default = outlook;
        };
      }
    );
}
