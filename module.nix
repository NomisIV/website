inputs: {
  lib,
  config,
  ...
}: let
  cfg = config.services.nomisiv-website;
in {
  options.services.nomisiv-website = with lib; {
    enable = mkEnableOption "NomisIV's website";

    openFirewall =
      mkEnableOption
      "open the port for the website in the firewall";

    port = mkOption {
      type = types.port;
      default = 8000;
      description = "The port to serve the website at";
    };

    user = mkOption {
      type = types.str;
      default = "nomisiv-website";
      description = "The user to run the website as";
    };

    group = mkOption {
      type = types.str;
      default = "nomisiv-website";
      description = "The group to run the website as";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.nomisiv-website = {
      description = "NomisIV website web server";
      after = ["network.target"];
      requires = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = "${servera.packages.x86_64-linux.default}/bin/servera ${toString cfg.port} ${self.packages.x86_64-linux.default}";
        User = cfg.user;
        Group = cfg.group;
      };
    };

    # Open firewall
    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.port];
    };

    # Add user and group
    users.users = lib.mkIf (cfg.user == "nomisiv-website") {
      nomisiv-website = {
        group = cfg.group;
        uid = 350;
      };
    };

    users.groups = lib.mkIf (cfg.group == "nomisiv-website") {
      nomisiv-website.gid = 350;
    };
  };
}
