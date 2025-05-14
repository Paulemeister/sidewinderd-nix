{
  description = "Sidewinderd Flake";

  inputs.nixpkgs.url = "nixpkgs/nixos-24.11";

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    pkgs = import nixpkgs;
    sidewinderd = pkgs.callPackage ./default.nix {};
  in {
    packages."x86_64-linux".sidewinderd = sidewinderd;

    nixosModules.sidewinderd = {
      config,
      lib,
      pkgs,
      ...
    }: {
      options.services.sidewinderd.enable = lib.mkEnableOption "Sidewinderd systemd-Dienst";

      config = lib.mkIf config.services.sidewinderd.enable {
        systemd.services.sidewinderd = {
          description = "Sidewinderd Daemon";
          after = ["multi-user.target"];
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${sidewinderd}/bin/sidewinderd";
          };
        };
        environment.systemPackages = [sidewinderd];
      };
    };
  };
}
