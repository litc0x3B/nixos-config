{ config, lib, pkgs, ... }:
{
  security.sudo.wheelNeedsPassword = false;

  users.users.litc = lib.mkForce {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    # Беспарольный вход для sudo
    initialPassword = "nixos";
  };

  services.getty.autologinUser = lib.mkForce "litc";

  isoImage.squashfsCompression = "zstd -Xcompression-level 19";
}