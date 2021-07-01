{ config, lib, pkgs, ... }:

{
  networking = {
    hostName = "garnet"; # Define your hostname.
    networkmanager.enable = true;
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp3s0f0.useDHCP = false;
  networking.interfaces.wlp1s0.useDHCP = false;

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish.addresses = true;
    publish.domain = true;
  };
}

