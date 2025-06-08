{
  description = "Sidewinderd Flake";

  inputs.nixpkgs.url = "nixpkgs/nixos-24.11";

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    #  pkgs = import nixpkgs {system = "x86_64-linux";};
    #   sidewinderd = pkgs.callPackage ./default.nix {};
    system = "x86_64-linux";
  in
    {
      #packages."x86_64-linux".sidewinderd = sidewinderd;
      nixosModules.sidewinderd = import ./module.nix;
      homeManagerModules.sidewinderd = import ./home-manager-module.nix;
    }
    // (let
      overlay = final: prev: {
        sidewinderd = self.packages.${system}.sidewinderd;
      };
      pkgs = nixpkgs.legacyPackages.${system}.extend overlay;
    in {
      packages.${system} = {
        sidewinderd = pkgs.callPackage ./default.nix {};
      };
      checks.${system} = {
        sidewinderd-test = import ./sidewinderd-test.nix {inherit pkgs self;};
      };
      overlays.default = overlay;
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [cmake libconfig tinyxml-2 udev clang-tools];
        CMAKE_EXPORT_COMPILE_COMMANDS = 1;
      };
    });
}
