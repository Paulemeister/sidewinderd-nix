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
      type = with lib.types; attrsOf (oneOf [str bool int]);
      default = {
        user = "root";
        capture_delays = true;
        "pid-file" = "/var/run/sidewinderd.pid";
        workdir = "/var/lib/sidewinderd";
      };
      description = ''
        Schlüssel/Wert-Paare für sidewinderd.conf.

        Zum Beispiel:
          user = "root";
          capture_delays = true;
          pid-file = "/var/run/sidewinderd.pid";
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
}
