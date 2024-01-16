{config, pkgs, ...}: {
  imports =
    [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "macmini";

  time.timeZone = "Europe/London";

  users.users.samw = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    git
    htop
    vim
    wget
  ];

  services.openssh.enable = true;
  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--ssh" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

