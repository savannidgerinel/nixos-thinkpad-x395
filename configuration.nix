# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstable = import <unstable> {
    config = { allowUnfree = true; };
  };

  local = import /home/savanni/src/nixpkgs {
    config = { allowUnfree = true; };
  };

in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      ./networking.nix

      ./security.nix

      ./sleep.nix

      ./gui.nix

      # ({ config, lib, pkgs, ... }: import /home/savanni/src/nixpkgs/nixos/modules/programs/1password-gui.nix { 
      # 	pkgs = pkgs // { _1password-gui = local._1password-gui; };
      #   config = config;
      #   lib = lib;
      # })
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
  boot.kernelParams = [ "acpi_osi=Linux" "acpi_backlight=none" "processor.max_cstate=4" "amd_iommu=off" "idle=nomwait" "initcall_debug" ];
  # boot.kernelPackages = pkgsUnstableSmall.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_5_14;
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
  ];

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
  };

  services.blueman.enable = true;

  systemd.coredump.enable = true;

  services.plex = {
    enable = false;
    openFirewall = false;
  };

  # programs._1password-gui = {
  #   enable = true;
  # };

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
}

