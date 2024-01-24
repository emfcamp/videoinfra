{
  description = "Streams 'R' Us infrastructure";
  inputs.nixos.url = "nixpkgs/23.11";
  inputs.irccat = {
    url = "github:irccloud/irccat";
    flake = false;
  };

  outputs = { self, nixos, irccat }: {
    nixosConfigurations = {
      macmini = nixos.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./hosts/macmini/configuration.nix
          ./irccat.nix
          ({ pkgs, ... }: let
            irccatPort = 6969;
          in {
            environment.systemPackages = [ pkgs.vim ];
            services.sshd.enable = true;
            services.tailscale = {
              enable = true;
              extraUpFlags = [ "--ssh" ];
            };
            services.irccat = {
              enable = true;
              package = pkgs.irccat.overrideAttrs {
                src = irccat;
              };
              config = {
                irc.server = "irc.libera.chat:6697";
                irc.nick = "sru-bot";
                irc.channels = "#emfcamp-video";
                http = {
		  listen = "localhost:${toString irccatPort}";
                  listeners.github = {
                    default_channel = "#emfcamp-video";
                  };
                };
              };
            };
          })
        ];
      };
    };
  };
}
