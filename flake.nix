{
  description = "A very basic flake";

  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";

    # Doesn't really have to use flake-parts, flake-utils and other library or even without
    # any library would work. flake-parts is used because I like it.
    flake-parts.url = "github:hercules-ci/flake-parts";

    # What do I have to put here?
    # This is not private repository. This is a public repository for demonstration purposes.
    # To use repository that actually is private, url should ssh so that nix can pull from private repository.
    # e.g. "git+ssh://git@github.com/Bob/myPrivateRepo.git"
    # note: you need to have ssh authentication to the git service provider to use this.
    #
    # How do I change my private package version?
    # Since flake inputs is locked using git rev hashes that's how version is handled here.
    # You can either provide explicit revision hash like down below "?rev=abc123..."
    # or running `nix flake lock --update-input privateDepDemoLib` without giving explicit revision hash.
    # For clarity's sake, I recommand using explicit revision hash.
    privateDepDemoLib.url = "github:seungheonoh/privateDepDemoLib?rev=a55190ba48f05593444a1f1db5c073b731344064";
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
                # It's possible to add as much packages as needed here.
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
            packages.run = flake.packages."privateDepDemo:exe:privateDepDemo";
            packages.sayHello =
              pkgs.writeShellScript "helloWorld" ''
              echo "hello world"
            '';
          };
    };
}
