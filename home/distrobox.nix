{ ... }:
{
  programs.distrobox = {
    enable = true;

    settings = {
      container_image_default = "docker.io/cachyos/cachyos:latest";
      container_name_default = "cachyos";
      container_additional_packages = "git base-devel yay";
      container_manager = "podman";
    };

    containers = {
      cachyos = {
        image = "docker.io/cachyos/cachyos:latest";
        additional_packages = "git base-devel yay";
      };
    };
  };
}
