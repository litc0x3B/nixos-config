# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "litc-nixos-pc"; # Define your hostname.
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
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    packages = with pkgs; [
      tree
    ];
  };


	environment.variables = {
			# SUDO_EDITOR = "geany";
			NIXPKGS_ALLOW_UNFREE = 1;
      WLR_NO_HARDWARE_CURSORS = 1;
      EDITOR = "vim";
      SUDO_EDITOR = "vim";
      # Отключает аппаратные DRM-модификаторы, которые ломают картинку в ВМ
      # AQ_NO_MODIFIERS = 1;
      # LIBGL_ALWAYS_SOFTWARE=1;
      # WLR_RENDERER = "pixman";
	};

  # programs.firefox.enable = true;

  nixpkgs.overlays = [
    inputs.nur.overlays.default
  ];

  # List packages installed	 in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    foot
    nautilus-python# probably needed for open-any-terminal
    nautilus
    loupe 
    gnome-secrets
    ffmpegthumbnailer
    libheif

    git
    xeyes #x11 test utility
    xwayland-satellite
    nixd #nix lsp
    nixfmt-rfc-style #nix code formatter 
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


    # flat-remix-icon-theme
    # fallbacks probably?
    # adwaita-icon-theme
    # hicolor-icon-theme
  ];

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

  fonts.packages = [pkgs.nerd-fonts.fira-code];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  programs.nix-ld.enable = true;
  virtualisation.containers.registries.search = [ "docker.io" "quay.io" ];  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  programs.niri.enable = true;
  # programs.dms-shell.enable = true;

  # Display Manager / Greeter
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --asterisks --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # GNOME Keyring & unlock via greetd PAM
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # Ensure tuigreet cache directory exists for remembering user/session
  systemd.tmpfiles.rules = [
    "d '/var/cache/tuigreet' 0755 greeter greeter - -"
  ];

  # GNOME Services & Nautilus integration
  services.gvfs.enable = true;             # Virtual filesystem (trash, smb, sftp, mtp)
  services.udisks2.enable = true;          # Storage devices & external drive mounting
  services.gnome.sushi.enable = true;      # File preview on Spacebar
  services.gnome.tinysparql.enable = true; # File indexer & search database (Tracker)
  services.gnome.localsearch.enable = true;
  virtualisation.virtualbox.guest.enable = false;
  virtualisation.virtualbox.guest.dragAndDrop = false;
  virtualisation.vmware.guest.enable = true;
  
  programs.zsh.ohMyZsh.enable = true;
  programs.zsh.enable = true;
  programs.zsh.syntaxHighlighting.enable = true;
  programs.zsh.autosuggestions.enable = true;
  # programs.zsh.ohMyZsh.plugins = ["git" "zsh-autosuggestions" "zsh-syntax-highlighting"];
  
  nixpkgs.config.allowUnfree = true; 

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "kitty";
  };
  

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}

