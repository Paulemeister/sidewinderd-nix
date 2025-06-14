{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.sidewinderd;
in {
  options.services.sidewinderd = {
    enable = lib.mkEnableOption "sidewinderd Daemon";
    settings = lib.mkOption {
      type = lib.types.submodule {
        options = {
          user = lib.mkOption {
            type = lib.types.str;
            default = "root";
          };
          capture_delays = lib.mkOption {
            type = lib.types.bool;
            default = true;
          };
          "pid-file" = lib.mkOption {
            type = lib.types.str;
            default = "/var/run/sidewinderd.pid";
          };
          workdir = lib.mkOption {
            type = lib.types.str;
            default = "/var/lib/sidewinderd";
          };
        };
      };
      default = {};
    };
    addUdevRule = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        If true, adds a udev rule that enables the
        read/write acces to /dev/hidraw* for the
        `plugdev` group.
        Also adds the `plugdev` group.
        Add your user to that group to enable sidewinderd
        to run non privileged.
        (required for usage with the home-manager module)
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.sidewinderd = {
      description = "Sidewinderd Daemon";
      after = ["multi-user.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.sidewinderd}/bin/sidewinderd";
      };
    };
    environment.systemPackages = [pkgs.sidewinderd];

    system.activationScripts.makeSidewinderPath = ''
      mkdir -p ${cfg.settings.workdir}
    '';
    environment.etc."sidewinderd.conf".text =
      lib.generators.toKeyValue {
        mkKeyValue = k: v:
        # Wenn Wert ein String: in Anführungszeichen
        # Booleans und Zahlen: wie gewohnt, aber mit Semikolon
        let
          vStr =
            if builtins.isBool v
            then
              (
                if v
                then "true"
                else "false"
              )
            else if builtins.isInt v
            then toString v
            else "\"${v}\"";
        in "${k} = ${vStr};";
      }
      cfg.settings;
  };
  # // lib.mkIf cfg.addUdevRule {
  #   services.udev.extraRules = ''
  #     KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev"
  #   '';
  #   users.groups.plugdev = {};
  # };
}
