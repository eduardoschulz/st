{
  description = "st terminal flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # or a specific commit
    flake-utils.url = "github:numtide/flake-utils"; # for utility functions
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        main = pkgs.stdenv.mkDerivation {
          pname = "st";
          version =
            "0.9.2"; # change this depending on which version you are building

          outputs = [ "out" "terminfo" ];
          src = [ ./. ];

          nativeBuildInputs =
            [ pkgs.pkg-config pkgs.ncurses pkgs.fontconfig pkgs.freetype ];

          buildInputs = [ pkgs.xorg.libX11 pkgs.xorg.libXft ];

          strictDeps = true;

          makeFlags = [ "PKG_CONFIG=${pkgs.stdenv.cc.targetPrefix}pkg-config" ];

          preInstall = ''
            export TERMINFO=$terminfo/share/terminfo
            mkdir -p $TERMINFO $out/nix-support
            echo "$terminfo" >> $out/nix-support/propagated-user-env-packages
          '';

          prePatch = ''
            sed -i "s@/usr/local@$out@" config.mk
          '';

          installFlags = [ "PREFIX=$(out)" ];

          #   makeFlags = [ "CC=${pkgs.stdenv.cc.targetPrefix}cc" ];

        };
      in {
        packages.default = main;
#        defaultPackage = main;
      });
}

