{ config, lib, pkgs, ... }:

let
  unstable = import <unstable> { };
in {
  programs.sway = {
    enable = true;
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
        unstable.xdg-desktop-portal
        unstable.xdg-desktop-portal-wlr
        unstable.xfce.thunar
      ];
  };

  # Enable backlight management
  # programs.light.enable = true;
  # services.actkbd = {
  #   enable = true;
  #   bindings = [
  #     { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -s sysfs/backlight/amdgpu_bl0 -A 10"; }
  #     { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -s sysfs/backlight/amdgpu_bl0 -U 10"; }
  #     # This one is supposed to be catching the F7/monitor switch key, but I don't see any indication that it's running the monitor switch command.
  #     # { keys = [ 227 ]; events = [ "key" ]; command = "/home/savanni/monitor-switch.sh"; }
  #   ];
  # };

  fonts.fonts = with pkgs; [
    font-awesome
    fira-code
  ];

}

