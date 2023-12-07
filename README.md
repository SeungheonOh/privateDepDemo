# Private Dependency Demo with Haskell.nix and Nix flake

This repository pulls dependency from [privateDepDemoLib](https://github.com/SeungheonOh/privateDepDemoLib) and uses 
one of function the dependency defines. For demonstration's sake, privateDepDemoLib is *not* private; however, it can be 
private if that is required. Dependency(s) are entirely managed by Nix, meaning that cabal is not pulling any code from 
github(or any other source) directly. The fact that dependencies are managed fully by Nix makes it easier to deal with private
dependencies.

The flake is striped down as much as possible besides the parts that is required to manage dependency using Haskell.nix 
and flake. For production uses, more components must be added for CI checks, pre-comit hooks, and other development utilities.

Run it with `nix run .#run`
