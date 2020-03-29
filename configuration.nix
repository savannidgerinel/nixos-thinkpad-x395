# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  before-sleep = pkgs.writeScript "before-sleep" ''
    #!${pkgs.bash}/bin/bash
    ${pkgs.python3}/bin/python /home/savanni/src/ZenStates-Linux/zenstates.py -l
    ${pkgs.python3}/bin/python /home/savanni/src/ZenStates-Linux/zenstates.py --c6-disable
  '';
  after-wakeup = pkgs.writeScript "after-wakeup" ''
    #!${pkgs.bash}/bin/bash
    ${pkgs.python3}/bin/python /home/savanni/src/ZenStates-Linux/zenstates.py -l
    ${pkgs.python3}/bin/python /home/savanni/src/ZenStates-Linux/zenstates.py --c6-disable
  '';
  nixpkgsUnstableSmall = builtins.fetchTarball {
    url = https://nixos.org/channels/nixos-unstable-small/nixexprs.tar.xz;
  };
  pkgsUnstableSmall = import nixpkgsUnstableSmall {};

in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Debugging suspend/resume issues: https://bbs.archlinux.org/viewtopic.php?id=248278
  boot.kernelParams = [ "acpi_osi=Linux" "acpi_backlight=none" "processor.max_cstate=4" "amd_iommu=off" "idle=nomwait" "initcall_debug" ];
  boot.kernelPackages = pkgsUnstableSmall.linuxPackages_latest;
  # boot.kernelModules = [ "kvm-amd" ];
  boot.blacklistedKernelModules = [ "btusb" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  # boot.extraModprobeConfig = ''
  #   options iwlwifi 11n_disable=1 swcrypto=1
  # '';

  networking.hostName = "garnet"; # Define your hostname.
  networking.wireless = {
    enable = true;
    extraConfig = ''
      ctrl_interface=/run/wpa_supplicant
      ctrl_interface_group=wheel
    '';
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp3s0f0.useDHCP = false;
  networking.interfaces.wlp1s0.useDHCP = true;

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish.addresses = true;
    publish.domain = true;
  };

  services.dbus.packages = [ pkgs.gnome3.dconf ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_US.UTF-8";
  };

  # System-udev-settle never succeeds, so this effectively disables it
  systemd.services.systemd-udev-settle.serviceConfig.ExecStart = ["" "${pkgs.coreutils}/bin/true"];

  # Set your time zone.
  time.timeZone = "America/New_York";
  # time.timeZone = "America/Denver";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    allowSFTP = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.samsungUnifiedLinuxDriver ];
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";

    wacom.enable = true;

    displayManager = {
      lightdm = {
        enable = true;
        autoLogin.enable = true;
        autoLogin.user = "savanni";
      };
    };
    desktopManager.xfce.enable = true;
    windowManager.i3.enable = true;
    windowManager.default = "i3";

    videoDrivers = [ "amdgpu" ];

    libinput.enable = true;
    libinput.tapping = false;

    config = ''
      Section "InputClass"
        Identifier "built-in keyboard"
        MatchProduct "AT Translated Set 2 keyboard"
        Option "XkbLayout" "dvorak"
        Option "XkbOptions" "esperanto:dvorak,lv3:caps_switch"
      EndSection

      Section "InputClass"
        Identifier "ErgoDox EZ"
        MatchVendor "ZSA"
        MatchProduct "ZSA Ergodox EZ"
        Option "XkbLayout" "us"
        Option "XkbOptions" "esperanto:qwerty,lv3:caps_switch"
      EndSection

      # https://bbs.archlinux.org/viewtopic.php?pid=1874850#p1874850
      Section "Device"
        Identifier "AMDGPU"
        Driver "amdgpu"
        Option "DRI" "2"
      EndSection
    '';
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.savanni = {
    isNormalUser = true;
    extraGroups = [ "audio" "docker" "wheel" ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

  # Enable backlight management
  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -s sysfs/backlight/amdgpu_bl0 -A 10"; }
      { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -s sysfs/backlight/amdgpu_bl0 -U 10"; }
      # This one is supposed to be catching the F7/monitor switch key, but I don't see any indication that it's running the monitor switch command.
      # { keys = [ 227 ]; events = [ "key" ]; command = "/home/savanni/monitor-switch.sh"; }
    ];
  };

  systemd.services.before-sleep = {
    description = "Remove network services before sleep";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${before-sleep}";
    };
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];
  };

  systemd.services.after-wakeup = {
    description = "Remove network services after sleep";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${after-wakeup}";
    };
    wantedBy = [ "sleep.target" ];
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
  };

  services.fwupd.enable = true;

  virtualisation.docker.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    vim
    lynx
    powertop
    xscreensaver
    xkbset
    xorg.xmodmap
    wpa_supplicant_gui
    cudatoolkit
    firefox
    zoom-us
    python3
  ];
}

