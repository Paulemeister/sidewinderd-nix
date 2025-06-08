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
            default = "${config.home.username}";
          };
          capture_delays = lib.mkOption {
            type = lib.types.bool;
            default = true;
          };
          "pid-file" = lib.mkOption {
            type = lib.types.str;
            default = "/tmp/sidewinderd.pid";
          };
          workdir = lib.mkOption {
            type = lib.types.str;
            default = config.xdg.configHome + "/sidewinderd/";
          };
        };
      };
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.sidewinderd = {
      Unit.Description = "Sidewinderd Daemon";
      Install.WantedBy = ["default.target"];
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.sidewinderd}/bin/sidewinderd -c ${config.xdg.configHome + "/sidewinderd/sidewinderd.conf"}";
      };
    };
    #environment.systemPackages = [pkgs.sidewinderd];

    xdg.configFile."sidewinderd/sidewinderd.conf".text =
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
}
