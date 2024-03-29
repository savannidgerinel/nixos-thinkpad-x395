{ config, lib, pkgs, ... }:

let
  unstable = import <unstable> { };

  # startsway = pkgs.writeTextFile {
  #   name = "startsway";
  #   destination = "/bin/startsway";
  #   executable = true;
  #   text = ''
  #     #! ${pkgs.bash}/bin/bash
  #     # systemctl --user import-environment
  #     # exec systemctl --user start sway.service
  #     export MOZ_ENABLE_WAYLAND=1
  #     sway
  #     # waitPID=$!
  #   '';
  # };

in {

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    libinput.enable = true;
    xkbVariant = "dvorak";
  };

  programs.sway = {
    enable = false;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; 
      let
        thunar = unstable.xfce.thunar.overrideAttrs {
          thunarPlugins = [ unstable.xfce.thunar-volman unstable.xfce.thunar-archive-plugin ]; };
      in [
        xwayland
        alacritty
        bemenu
        i3status
        mako
        sway
        swayidle
        swaylock
        wl-clipboard
        unstable.xfce.thunar
        gnome3.nautilus
        pinentry
        pinentry-gnome
        xdg-desktop-portal
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gnome
      ];
    extraSessionCommands = ''
      eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh);
      export SSH_AUTH_SOCK;
    '';
  };

  /*
  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;
  xdg.portal.gtkUsePortal = true;
  */

  systemd.user.targets.sway-session = {
    description = "Sway compositor session";
    documentation = [ "man:systemd.special(7)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };

  systemd.user.services.sway = {
    description = "Sway - Wayland window manager";
    documentation = [ "man:sway(5)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
    environment.PATH = lib.mkForce null;
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --debug
      '';
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      font-awesome
      fira-code
    ];
  };
}

