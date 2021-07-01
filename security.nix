{ config, lib, pkgs, ... }:

{
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.gnupg = {
    agent.enable = true;
    agent.pinentryFlavor = "gnome3";
    agent.enableSSHSupport = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    allowSFTP = true;
  };
}

