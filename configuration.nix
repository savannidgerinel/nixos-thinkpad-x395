# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  unstable = import <unstable> {
    config = { allowUnfree = true; };
  };

  local = import /home/savanni/src/nixpkgs {
    config = { allowUnfree = true; };
  };

  # _1password-gui = local._1password-gui;
  # _1password-gui = local._1password-gui.override {
  #   polkitPolicyOwners = [ "savanni" ];
  # };
  _1password-gui = let ver = "8.7.0-41.BETA";
    in local._1password-gui.overrideAttrs ({ ... }: {
      version = ver;
      src = pkgs.fetchurl {
        url = "https://downloads.1password.com/linux/tar/beta/x86_64/1password-${ver}.x64.tar.gz";
        sha256 = "BXyn8KGrx8uvaU7iISEJ6L6R7wWxb6sfgktKqKkKpxg=";
      };
      postInstallPhase = ''
      '';
    });

in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      ./networking.nix

      ./security.nix

      # ./sleep.nix

      ./gui.nix

      /home/savanni/src/nixpkgs/nixos/modules/programs/_1password-gui.nix
    ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?

  nixpkgs.config.allowUnfree = true;

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Debugging suspend/resume issues: https://bbs.archlinux.org/viewtopic.php?id=248278
  # boot.kernelParams = [ "acpi_osi=Linux" "acpi_backlight=none" "processor.max_cstate=4" "amd_iommu=off" "idle=nomwait" "initcall_debug" ];
  boot.kernelParams = [ "acpi_osi=Linux" "acpi_backlight=none" ];
  # boot.kernelPackages = pkgsUnstableSmall.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_5_14;
  boot.kernelPackages = pkgs.linuxPackages_5_15;
  # boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_5_15.override {
  #   argsOverride = rec {
  #     src = pkgs.fetchurl {
  #       url = "mirror://kernel/linux/kernel/v5.x/linux-${version}.tar.xz";
  #       sha256 = "1pr7qh2wjw7h6r3fixg9ia5r3na7vdb6b4sp9wnbifnqckahzwis";
  #     };
  #     version = "5.14.18";
  #     modDirVersion = "5.14.18";
  #   };
  # });
  # boot.kernelModules = [ "kvm-amd" ];
  boot.kernelModules = [ "fuse" "kvm-amd" "msr" "kvm-intel" "amdgpu" "acpi_call" "usbmon" "usbserial" "timer_stats" ];

  # boot.blacklistedKernelModules = [ "btusb" ];
  # boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  # boot.extraModprobeConfig = ''
  #   options iwlwifi 11n_disable=1
  # '';

  services.dbus.packages = [ pkgs.gnome3.dconf ];

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "eo.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "dvorak";
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # System-udev-settle never succeeds, so this effectively disables it
  systemd.services.systemd-udev-settle.serviceConfig.ExecStart = ["" "${pkgs.coreutils}/bin/true"];
  services.udev = {
    packages = [ pkgs.yubikey-personalization pkgs.libu2f-host ];
    extraRules = ''
      ACTION=="add", KERNEL=="ttyUSB0", MODE="0660", GROUP="dialout"
      SUBSYSTEM=="usb", ATTRS{product}=="USBtiny", ATTRS{idProduct}=="0c9f", ATTRS{idVendor}=="1781", MODE="0660", GROUP="dialout"
      ACTION=="add", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c52b", MODE="0660", GROUP="dialout"
      # SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c52b", MODE="0660"
      # SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0660", TAG+="uaccess"
      # KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess", OPTIONS+="static_node=uinput"
      # KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0660", TAG+="uaccess"
      # KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0660", TAG+="uaccess"
    '';
  };
  services.pcscd.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";
  # time.timeZone = "America/Denver";

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.samsungUnifiedLinuxDriver ];
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = false;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    extraConfig = ''
      load-module module-switch-on-connect
    '';
    package = pkgs.pulseaudioFull;
  };

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    # jack.enable = true;

    # media-session.config.bluez-monitor.rules = [
    #   {
    #     matches = [ { "device.name" = "~bluez_card.*"; } ];
    #     actions = {
    #       "update-props" = {
    #         "bluez5.reconnect-profiles" = [ "a2dp_sink" ];
    #         "bluez.msbc-support" = true;
    #       };
    #     };
    #   }
    #   {
    #     matches = [
    #       { "node.name" = "~bluez_input.*"; }
    #       { "node.name" = "~bluez_output.*"; }
    #     ];
    #     actions = {
    #       "node.pause_on_idle" = false;
    #     };
    #   }
    # ];
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      unstable.rocm-opencl-icd
      unstable.rocm-opencl-runtime
    ];
  };

  services.gvfs = {
    enable = true;
    package = pkgs.lib.mkForce pkgs.gnome3.gvfs;
  };

  services.samba.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.savanni = {
    isNormalUser = true;
    extraGroups = [ "audio" "docker" "wheel" "dialout" "video" "networkmanager" "libvirtd" ];
  };

  services.power-profiles-daemon.enable = true;

  services.tlp = {
    enable = false;
  };

  services.fwupd.enable = true;

  virtualisation = {
    docker.enable = false;

    # virtualbox.host = {
    #   enable = true;
    #   enableExtensionPack = true;
    # };

    libvirtd.enable = false;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    unixtools.ifconfig
    efibootmgr
    xdg_utils
    lxqt.lxqt-policykit
    brightnessctl
    solaar
    # _1password-gui
    cifs-utils
    xdg-launch
    gnome.gnome-tweak-tool
  ];

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
  };

  services.blueman.enable = true;

  systemd.coredump.enable = true;

  programs._1password-gui = {
    enable = true;
    groupId = 5000;
    polkitPolicyOwners = [ "savanni" ];
    package = _1password-gui;
  };

  services.nginx = {
    enable = false;
  #   virtualHosts."star-trek-valen.localhost" = {
  #       addSSL = false;
  #       enableACME = false;
  #       root = "/home/savanni/Documents/star-trek-valen/public/";
  #   };
    virtualHosts."numenera.localhost" = {
        addSSL = false;
        enableACME = false;
        root = "/home/savanni/Documents/numenera/public/";
    };

  #   virtualHosts."wiki.localhost" = {
  #       addSSL = false;
  #       enableACME = false;
  #       root = "/home/savanni/Documents/wiki/public/";
  #   };
  };

  # services.gitea = {
  #   enable = true;
  #   stateDir = "/home/gitea";
  #   disableRegistration = true;
  # };
}

