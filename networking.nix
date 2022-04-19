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

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 139 445 6006 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];
  networking.firewall.checkReversePath = false;

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish.addresses = true;
    publish.domain = true;
  };

  # services.squid = {
  #   enable = true;
  #   proxyPort = 3128;
  #   extraConfig = ''
  #     https_port 3129
  #   '';
  # };

  services.jellyfin.enable = true;
}

