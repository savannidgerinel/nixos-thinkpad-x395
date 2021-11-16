{ config, lib, pkgs, ... }:

let
  before-sleep = pkgs.writeScript "before-sleep" ''
    #!${pkgs.bash}/bin/bash
    ${pkgs.zenstates}/bin/zenstates --c6-disable
  '';

in {
  systemd.services.before-sleep = {
    description = "Jobs to run before going to sleep";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${before-sleep}";
    };
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];
  };

}
