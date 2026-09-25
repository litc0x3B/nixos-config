# Repository Guidelines for AI Agents

NixOS flake configuration with Home Manager for host `litc-nixos-pc`.

## Project Structure

- `flake.nix` — Flake entrypoint (inputs, outputs, host and home-manager integration).
- `configuration.nix` — System-level NixOS configuration.
- `home.nix` — User-level configuration (Home Manager for user `litc`).
- `niri-conf.kdl` — Niri Wayland compositor keybindings and layout.
- `noctalia.kdl` — Noctalia status bar / desktop widget configuration.

## System Stack

- **OS**: NixOS (branch `nixos-26.05`).
- **Compositor**: Niri (launched via `niri-session`).
- **Login Manager**: `greetd` + `tuigreet`.
- **Default Shell**: Zsh (`oh-my-zsh`).
- **Default Terminals**: Kitty / Foot.

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
- **Always ask before changing config:** Explain in detail what changes your are going to make and why they are needed and wait for response. Never proceed editing without explicit consent.
- **Ask if you need to make permanent changes:** You can perform necessary commands outside of the scope of this project or create and edit temporary files or files inside your dedicated agent folder. However if you need to execute tool that could introduce permanent changes you have to ask user explicitly.
- **Keep this file up to date**: If project structure or system stack changes you need to update this file. Keep it concise though.
