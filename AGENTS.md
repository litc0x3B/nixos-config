# Repository Guidelines for AI Agents

NixOS flake configuration with Home Manager for host `litc-nixos-pc`.

## Project Structure

- `flake.nix` — Flake entrypoint (inputs, outputs, host and home-manager integration).
- `configuration.nix` — System-level NixOS configuration.
- `hardware-configuration.nix` — Hardware detection and configuration.
- `disko-config.nix` — Declarative disk partitioning configuration (Disko).
- `home/` — Modular Home Manager configuration for user `litc`:
  - `home/default.nix` — Main entrypoint importing submodules.
  - `home/packages.nix` — User packages and utilities.
  - `home/symlinks.nix` — Symlinks configuration for user dotfiles (`~/.config/*`).
  - `home/zsh.nix` — Zsh shell and plugin configuration.
  - `home/env.nix` — Session environment variables
  - `home/misc.nix` — Miscellaneous settings (git, fonts, etc.).
  - `home/noctalia.nix` — Sets wallpaper image from this repo.
  - `home/wallpaper.png` — Wallpaper image used by noctalia module.
  - `home/yazi.nix` — Yazi file manager configuration.
  - `home/rclone-sync.nix` — Background cloud sync service via rclone.
  - `home/chezmoi.nix` — Chezmoi configuration for mutable/stateful dotfiles.
  - `home/chezmoi-source/` — Source tree for state/configs managed by chezmoi.
  - `home/agy-patched.nix` — Custom package derivation for Antigravity CLI.
  - `home/config/` — Dotfiles and application configurations (niri, noctalia, kitty, zed, micro).
  - `home/noctalia-plugins/ruh-vpn` — Local version of Noctalia ruh-vpn plugin with custom fixes.


## System Stack

- **OS**: NixOS (branch `nixos-26.05`).
- **Compositor**: Niri (launched via `niri-session`).
- **Login Manager**: `greetd` + `tuigreet`.
- **Default Shell**: Zsh (`oh-my-zsh`).
- **Default Terminal**: Kitty.

## Workflow & Rules for Agents

- **Validation**: Always verify changes before recommending applying:
  ```bash
  nix build .#nixosConfigurations.litc-nixos-pc.config.system.build.toplevel --dry-run
  ```
- **Applying changes**: User applies system changes via `nh`:
  ```bash
  nh os switch
  ```
- **Git tracking**: Remember that Nix Flakes only see files tracked by Git. Stage newly created files (`git add <file>`) before evaluation.
- **No breaking changes**: Keep NixOS options idiomatic and preserve existing comments/rationale.
- **Always ask before changing config:** Explain in detail what changes you are going to make and why they are needed and wait for response. Never proceed editing without explicit consent.
- **Ask if you need to make permanent changes:** You can perform necessary commands outside of the scope of this project or create and edit temporary files or files inside your dedicated agent folder. However if you need to execute tool that could introduce permanent changes you have to ask user explicitly.
- **Keep this file up to date**: If project structure or system stack changes you need to update this file. Keep it concise though.
