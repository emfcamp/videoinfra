# TODO: upstream this
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.irccat;
  format = pkgs.formats.json {};
  cfgFile = format.generate "config.json" cfg.config;
in
{
  options = {
    services.irccat = {
      enable = mkEnableOption (lib.mdDoc "Irccat irc event sender");
      package = mkPackageOption pkgs "irccat" {};
      config = mkOption {
        type = types.submodule {
          freeformType = format.type;
          options.irc.server = mkOption {
            type = types.str;
            description = lib.mdDoc ''
              The host:port of the IRC server to connect to
            '';
            example = "irc.libera.chat:6697";
          };
          options.irc.tls = mkOption {
            type = types.bool;
            default = true;
            description = lib.mdDoc ''
              Whether to secure the IRC connection with TLS
            '';
          };
          options.irc.nick = mkOption {
            type = types.str;
            description = lib.mdDoc ''
              The nick irccat will use
            '';
          };
          options.http.listen = mkOption {
            type = types.str;
            description = mdDoc ''
              The listen address:port to listen on for HTTP
            '';
          };
        };
        description = ''
          irccat configuration. For supported values, see the 
          [example json](https://github.com/irccloud/irccat/blob/master/examples/irccat.json).
        '';
      };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.irccat = {
      description = "Irccat IRC event sender";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/irccat -config ${cfgFile}";
        DynamicUser = true;

        # Basic hardening
        NoNewPrivileges = "yes";
        PrivateTmp = "yes";
        PrivateDevices = "yes";
        DevicePolicy = "closed";
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ProtectControlGroups = "yes";
        ProtectKernelModules = "yes";
        ProtectKernelTunables = "yes";
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
        RestrictNamespaces = "yes";
        RestrictRealtime = "yes";
        RestrictSUIDSGID = "yes";
        MemoryDenyWriteExecute = "yes";
        LockPersonality = "yes";
      };
    };
  };
}

