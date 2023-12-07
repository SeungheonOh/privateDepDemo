{
  description = "A very basic flake";

  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";

    # Doesn't really have to use flake-parts, flake-utils and other library or even without
    # any library would work. flake-parts is used because I like it.
    flake-parts.url = "github:hercules-ci/flake-parts";

    # This is not private repository. This is a public repository for demonstration purposes.
    # To use repository that actually is private, url should ssh so that nix can pull from private repository.
    # e.g. "git+ssh://git@github.com/Bob/myPrivateRepo.git"
    # note: you need to have ssh authentication to the git service provider to use this.
    privateDepDemoLib.url = "github:seungheonoh/privateDepDemoLib";
  };

  outputs = inputs@{ nixpkgs, flake-parts, haskellNix, ... }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" "aarch64-linux" ];
      perSystem = { options, config, self', inputs', lib, system, ... }:
        let
          # Need this to use haskell.nix. This adds overlay and config to the nixpkgs.
          pkgs = import nixpkgs {
            overlays = [ haskellNix.overlay ];
            inherit system;
            inherit (haskellNix) config;
          };

          ghcVersion = "ghc963";

          hackageUtils =
            import ./mk-hackage.nix { inherit system pkgs lib; };

          customHackage =
            hackageUtils.mkHackage
              ghcVersion
              [ "${inputs.privateDepDemoLib}"
              ];

          project = pkgs.haskell-nix.project' {
            src = ./.;
            compiler-nix-name = ghcVersion;

            modules = customHackage.modules;
            extra-hackages = customHackage.extra-hackages;
            extra-hackage-tarballs = customHackage.extra-hackage-tarballs;
          };
          flake = project.flake { };
        in
          { inherit (flake) packages devShells; } // {
            packages.sayHello =
              pkgs.writeShellScript "helloWorld" ''
              echo "hello world"
            '';
          };
    };
}
