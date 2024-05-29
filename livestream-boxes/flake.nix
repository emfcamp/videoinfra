{ inputs.nixpkgs.url = "nixpkgs/nixos-23.11";
  inputs.ajantv2.url =
    "git+https://git.hacksrus.org/Streams-R-Us/ajantv2-nix.git";
  description = "Setup for 'livestream' boxes in Hacks'R'Us racks";

  outputs = { self, nixpkgs, ajantv2 }: let
    mkStreambox = {hostname, ip_addr}: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ajantv2.nixosModules.default
        ({config, lib, pkgs, ...}: {
          imports = [ ./configuration.nix ];
          networking = {
            hostName = hostname;
            interfaces.eth0.ipv4.addresses = [{
              address = ip_addr;
              prefixLength = 24;
            }];
          };
        })
      ];
    };
    in {
    nixosConfigurations = {
      livestream-blue = mkStreambox { hostname = "livestream-blue"; ip_addr = "172.31.152.107"; };
      livestream-yellow = mkStreambox { hostname = "livestream-yellow"; ip_addr = "172.31.152.117"; };
      livestream-green = mkStreambox { hostname = "livestream-green"; ip_addr = "172.31.152.127"; };
    };
  };
}
