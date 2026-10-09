# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  # Настройки загрузчика (bootloader) перенесены в hosts/<hostName>/default.nix

  # Hostname задается в flake.nix / hosts/<hostName>
  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  #  console = {
  #    font = "Lat2-Terminus16";
  #    keyMap = "us";
  #    useXkbConfig = true; # use xkb.options in tty.
  #  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = false;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.litc = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "cdrom"
    ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    initialPassword = "1234";
    packages = with pkgs; [
      tree
    ];
  };
  programs.zsh.enable = true;

  environment.variables = {
    # SUDO_EDITOR = "geany";
    NIXPKGS_ALLOW_UNFREE = 1;
    # WLR_NO_HARDWARE_CURSORS = 1;
    # Отключает аппаратные DRM-модификаторы, которые ломают картинку в ВМ
    # AQ_NO_MODIFIERS = 1;
    # LIBGL_ALWAYS_SOFTWARE=1;
    # WLR_RENDERER = "pixman";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  # programs.firefox.enable = true;

  nixpkgs.overlays = [
    inputs.nur.overlays.default
    (final: prev: {
      niri-window-pin = inputs.niri-utils.packages.${prev.system}.niri-window-pin;
    })
    inputs.rc-sync.overlays.default
  ];

  # List packages installed	 in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    foot
    nautilus-python # probably needed for open-any-terminal
    nautilus
    loupe
    gnome-secrets
    ffmpegthumbnailer
    libheif

    git
    xeyes # x11 test utility
    xwayland-satellite
    nixd # nix lsp
    nixfmt-rfc-style # nix code formatter
    btop
    # antigravity-cli
    nodejs
    distrobox
    fastfetch
    yazi
    ouch-rar

    #secrets and shit
    sops
    age

    kdePackages.kate
    kdePackages.breeze
  ];

  programs.cdemu = {
    enable = true;
    gui = true;
  };

  # services.dbus.packages = [
  #   pkgs.loupe
  #   pkgs.nautilus
  #   pkgs.file-roller
  # ];

  environment.pathsToLink = [ "/share/icons" ];

  # security.wrappers.sing-box = {
  #   source = "${pkgs.sing-box}/bin/sing-box";
  #   capabilities = "cap_net_admin,cap_net_bind_service=+ep";
  # };

  security.polkit.enable = true;
  # Нужно в unstable
  # security.polkit.enablePkexecWrapper = true;
  security.sudo.extraConfig = ''
    # Символ \u0007 (BEL) заставит терминал среагировать при появлении промпта:
    Defaults passprompt = "${builtins.fromJSON ''"\u0007"''}[sudo] password for %p: "
  '';

  fonts.packages = [ pkgs.nerd-fonts.fira-code ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  programs.nix-ld.enable = true;
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 4d --keep 3 --optimise";
    };
    flake = "/home/litc/Nixos";
  };
  virtualisation.containers.registries.search = [
    "docker.io"
    "quay.io"
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable Flatpak service and portal integration
  services.flatpak.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  programs.niri.enable = true;
  # programs.dms-shell.enable = true;

  # Display Manager / Greeter (по умолчанию Noctalia Greeter)
  services.displayManager.noctalia-greeter = {
    enable = lib.mkDefault true;
    package = pkgs.noctalia-greeter;
    passwordless-sync-users = [ "litc" ];
    # cursorTheme = {
    #   package = pkgs.bibata-cursors;
    #   name = "Bibata-Modern-Ice";
    # };
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = "greeter";
      };
    };
  };

  # GNOME Keyring & unlock via greetd PAM
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # GNOME Services & Nautilus integration
  services.gvfs.enable = true; # Virtual filesystem (trash, smb, sftp, mtp)
  services.udisks2.enable = true; # Storage devices & external drive mounting
  services.gnome.sushi.enable = true; # File preview on Spacebar
  services.gnome.tinysparql.enable = true; # File indexer & search database (Tracker)
  # Настройки гостевых дополнений виртуализации перенесены в hosts/litc-nixos-vm/default.nix

  nixpkgs.config.allowUnfree = true;

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
    }
  ];

  programs.qtengine = {
    enable = true;
    config = {
      theme = {
        colorScheme = "/home/litc/.local/share/color-schemes/noctalia.colors";
        iconTheme = config.home-manager.users.litc.gtk.iconTheme.name;
        style = "breeze";

        # font = {
        #   family = "Sans Serif";
        #   # size = 10;
        #   weight = -1;
        # };
        # fontFixed = {
        #   family = "FiraCode Nerd Font";
        #   # size = 10;
        #   weight = -1;
        # };
      };
      # misc = {
      #   singleClickActivate = false;
      #   menusHaveIcons = true;
      #   shortcutsForContextMenus = true;
      # };
    };
  };

  programs.steam.enable = true;
  programs.craftapps = {
    enable = true;
    apps.pdfcraft.enable = true;
  };

  system.stateVersion = "26.05"; # DO NOT CHANGE THIS!

}
