{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  # Загрузчик UEFI (systemd-boot)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Прошивки для Wi-Fi, Bluetooth и Realtek оборудования
  hardware.enableRedistributableFirmware = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Видеокарта NVIDIA (GTX 1060 / Pascal)
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };

  hardware.nvidia = {
    # Режимы KMS для Wayland / Niri
    modesetting.enable = true;

    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Для Pascal (GTX 1060) и старше открытые модули ядра не поддерживаются
    open = false;

    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };

  # Early KMS: загрузка драйвера NVIDIA в initrd для Plymouth
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  boot.kernelParams = [
  # "nvidia-drm.modeset=1"
  # "nvidia-drm.fbdev=1"
  ];

  # Переменные окружения для Wayland / Niri
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND = "direct";
  };

  # Отключение аппаратного sidetone (мониторинга микрофона) для гарнитуры fifine H13 Chat:
  # 1. soft-mixer исключает регулировку аппаратных микшеров чипа при изменении громкости в PipeWire
  services.pipewire.wireplumber.extraConfig."10-fifine-soft-mixer" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          {
            "device.name" = "alsa_card.usb-MV-SILICON_fifine_H13_Chat_20190808-00";
          }
        ];
        actions = {
          update-props = {
            "api.alsa.soft-mixer" = true;
          };
        };
      }
    ];
  };

  # 2. Выключение свитча и сброс громкости sidetone при инициализации звуковой карты udev
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="sound", KERNEL=="controlC*", ATTRS{idVendor}=="3142", ATTRS{idProduct}=="0021", RUN+="${pkgs.alsa-utils}/bin/amixer -c %n cset numid=3 off", RUN+="${pkgs.alsa-utils}/bin/amixer -c %n cset numid=4 0"
  '';

  # Поддержка файловой системы NTFS
  boot.supportedFilesystems = [ "ntfs" ];

  # Автоматическое монтирование жесткого диска 1TB
  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/1E2A51B62A518BA1";
    fsType = "ntfs-3g";
    options = [
      "nofail"
      "x-systemd.automount"
      "x-gvfs-show"
      "uid=1000"
      "gid=100"
      "dmask=027"
      "fmask=0022"
    ];
  };

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  # Переназначение боковой клавиши мыши (mouse2) на Mod (Super / leftmeta) для niri
  # services.keyd = {
  #   enable = true;
  #   keyboards = {
  #     mouse = {
  #       ids = [
  #         "09da:3130"
  #         "09da:3130:02e2f35b"
  #       ];
  #       settings = {
  #         main = {
  #           mouse2 = "leftmeta";
  #         };
  #       };
  #     };
  #   };
  # };

  services.displayManager.noctalia-greeter = {
    settings = {
      appearance.wallpaper.blur = 0.5;
    };
  };

  # Дополнительные настройки Home Manager для хоста litc-nixos-desktop
  home-manager.users.litc = import ./home;
}
