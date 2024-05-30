{ config, lib, pkgs, ... }:
let home = "/home/voc";
in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  services.xserver.enable = true;

  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  hardware.nvidia.package =
    config.boot.kernelPackages.nvidiaPackages.legacy_390;
  nixpkgs.config.nvidia.acceptLicense = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  hardware.pulseaudio.enable = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  hardware.decklink.enable = true;
  virtualisation.docker.enable = true;

  networking.defaultGateway = "172.31.152.1";
  networking.nameservers = [ "8.8.8.8" ];

  users.users.voc = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "audio" ];
    packages = with pkgs; [
      firefox
      tree
      flatpak
      ffmpeg
      htop
      obs-studio
      tigervnc
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    firefox
    pkgs.xorg.xinit
  ];

  services.openssh.enable = true;
  boot.initrd.network.ssh.enable = true;

  # systemd service for vnc server
  systemd.services.vncserver = {
    enable = true;
    environment = {
      PATH = pkgs.lib.mkForce
        "/run/wrappers/bin:${home}/.nix-profile/bin:/nix/profile/bin:${home}/.local/state/nix/profile/bin:/etc/profiles/per-user/user/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
    };
    unitConfig = {
      Description = "Remote desktop service (VNC)";
      After = "syslog.target network.target";
    };

    serviceConfig = {
      Type = "simple";
      User = "user";
      WorkingDirectory = "${home}";

      ExecStartPre =
        "/bin/sh -c '${pkgs.tigervnc}/bin/vncserver -kill :1 > /dev/null 2>&1 || :'";
      ExecStart =
        "${pkgs.xorg.xinit}/bin/xinit ${home}/.vnc/xstartup -- ${pkgs.tigervnc}/bin/Xvnc :1 -interface 127.0.0.1 -rfbauth ${home}/.vnc/passwd";
      ExecStop = "${pkgs.tigervnc}/bin/vncserver -kill :1";

    };

    wantedBy = [ "multi-user.target" ];

  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}
