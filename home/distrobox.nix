{ pkgs, osConfig, config, ... }:
let
  writeInitScript = flag: body:
  let
    fullFlagPath = "/var/lib/.distrobox_init_${flag}";
    script = pkgs.writeText "distrobox-init-${flag}.sh" ''
      set -e
      # exec only once
      [ -f "${fullFlagPath}" ] && exit 0

      ${body}

      # success flag
      touch "${fullFlagPath}"
    '';
  in
    "sh /run/host${script}";
in
{
  programs.distrobox = {
    enable = true;

    settings = {
      clean_path = 1;
    };

    containers = {
      arch-base =
        let
          packages = [
            "reflector"
            "yay"
            "yazi"
            "neovim"
            "kitty"
            "zsh"
            "zoxide"
            "fzf" #fzf-tab zsh plugin
          ];
        in
        {
          image = "archlinux:latest";
          pre_init_hooks = writeInitScript "base-pre" ''
            # chaotic aur
            pacman-key --init
            pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
            pacman-key --lsign-key 3056513887B78AEB
            pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm
            pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
            cat << 'EOF' >> /etc/pacman.conf
            [chaotic-aur]
            Include = /etc/pacman.d/chaotic-mirrorlist
            EOF

            pacman -Syu --noconfirm

            ln -s /run/host/run/systemd/system /run/systemd
            mkdir -p /run/dbus
            ln -s /run/host/run/dbus/system_bus_socket /run/dbus
          '';
          additional_packages = "${builtins.concatStringsSep " " packages}";
          init_hooks = writeInitScript "base" ''
            reflector --country RU --protocol https --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
            usermod -s /usr/bin/zsh ${config.home.username}
          '';
          nvidia = builtins.elem "nvidia" osConfig.services.xserver.videoDrivers;
          entry = false;
        };
      arch =
        let
          packages = [
            "dotnet-sdk"
            "dotnet-runtime"
            "aspnet-runtime"
            "aspnet-targeting-pack"
            "python"
            "visual-studio-code-bin"
            "appmanager"
          ];
        in
        {
          additional_packages = "${builtins.concatStringsSep " " packages}";
          include = "arch-base";
          entry = true;
          exported_apps="code";
        };
        appimages =
          let
            packages = [
              "appmanager"
            ];
          in
          {
            additional_packages = "${builtins.concatStringsSep " " packages}";
            include = "arch-base";
            entry = true;
            exported_apps="AppManager";
            volume = [
              "appimages-appimages:${config.home.homeDirectory}/Applications"
              "appimages-desktops-entries:${config.home.homeDirectory}/.local/share/applications"
              "appimages-bin:${config.home.homeDirectory}/.local/bin"
              "appimages-appmanager-share:${config.home.homeDirectory}/.local/share/app-manager"
            ];
            pre_init_hooks = writeInitScript "appimages-pre" ''
                          chown -R ${config.home.username}: \
                              ${config.home.homeDirectory}/Applications \
                              ${config.home.homeDirectory}/.local/share/applications \
                              ${config.home.homeDirectory}/.local/bin \
                              ${config.home.homeDirectory}/.local/share/app-manager \
            '';
          };
    };
  };
}
