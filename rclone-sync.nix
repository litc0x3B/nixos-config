{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.rclone-sync;

  pairType = lib.types.coercedTo
    (lib.types.listOf lib.types.str)
    (list:
      if builtins.length list >= 2 then {
        path1 = builtins.elemAt list 0;
        path2 = builtins.elemAt list 1;
        extraArgs = [ ];
        createPath1 = null;
        createPath2 = null;
        resyncOnFirstRun = null;
        autoResync = null;
      } else
        throw "rclone-sync: pair must contain at least 2 elements [ path1 path2 ]"
    )
    (lib.types.submodule {
      options = {
        path1 = lib.mkOption {
          type = lib.types.str;
          description = "First path (Path1) for rclone bisync (local directory or remote:path).";
          example = "/home/litc/Documents";
        };

        path2 = lib.mkOption {
          type = lib.types.str;
          description = "Second path (Path2) for rclone bisync (remote:path or local directory).";
          example = "remote:Documents";
        };

        createPath1 = lib.mkOption {
          type = lib.types.nullOr lib.types.bool;
          default = null;
          description = "Whether to create Path1 if missing. Inherits from services.rclone-sync.createPath1 if null.";
        };

        createPath2 = lib.mkOption {
          type = lib.types.nullOr lib.types.bool;
          default = null;
          description = "Whether to create Path2 if missing. Inherits from services.rclone-sync.createPath2 if null.";
        };

        resyncOnFirstRun = lib.mkOption {
          type = lib.types.nullOr lib.types.bool;
          default = null;
          description = "Whether to auto-resync only on the initial run. Inherits from services.rclone-sync.resyncOnFirstRun if null.";
        };

        autoResync = lib.mkOption {
          type = lib.types.nullOr lib.types.bool;
          default = null;
          description = "Whether to auto-resync on subsequent desync errors. Inherits from services.rclone-sync.autoResync if null.";
        };

        extraArgs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Additional arguments specific to this sync pair.";
          example = [ "--check-access" ];
        };
      };
    });

  syncScript = pkgs.writeShellScript "rclone-sync-all" ''
    set -uo pipefail

    RCLONE="${cfg.package}/bin/rclone"
    STATE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/rclone-sync"
    TMPLOG=$(mktemp)
    trap 'rm -f "$TMPLOG"' EXIT INT TERM
    EXIT_CODE=0

    mkdir -p "$STATE_DIR"

    ensure_path() {
      local target="$1"
      local create_flag="$2"
      local label="$3"

      if [[ "$target" == /* ]]; then
        if [ ! -d "$target" ]; then
          if [ "$create_flag" = "1" ]; then
            echo "[rclone-sync] Creating local $label directory '$target'..."
            mkdir -p "$target"
          else
            echo "[rclone-sync] Error: local $label '$target' does not exist and create$label is false. Skipping (is external disk mounted?)." >&2
            return 1
          fi
        fi
      else
        if [ "$create_flag" = "1" ]; then
          echo "[rclone-sync] Ensuring remote $label '$target' exists..."
          if ! "$RCLONE" mkdir "$target"; then
            echo "[rclone-sync] Error: Failed to create remote $label '$target'" >&2
            return 1
          fi
        fi
      fi
      return 0
    }

    record_initialized() {
      local marker="$1"
      local p1="$2"
      local p2="$3"
      {
        echo "Initialized: $(date)"
        echo "Path1: $p1"
        echo "Path2: $p2"
      } > "$marker"
    }

    clean_path() {
      local p="$1"
      p="''${p#/}"
      p="''${p//\//_}"
      p="''${p//:/_}"
      p="''${p// /_}"
      echo -n "$p"
    }

    echo "=== Starting rclone sync job at $(date) ==="

    ${lib.concatMapStringsSep "\n" (pair:
      let
        cPath1 = if pair.createPath1 != null then pair.createPath1 else cfg.createPath1;
        cPath2 = if pair.createPath2 != null then pair.createPath2 else cfg.createPath2;
        rFirst = if pair.resyncOnFirstRun != null then pair.resyncOnFirstRun else cfg.resyncOnFirstRun;
        aResync = if pair.autoResync != null then pair.autoResync else cfg.autoResync;
      in ''
        P1_CLEAN=$(clean_path ${lib.escapeShellArg pair.path1})
        P2_CLEAN=$(clean_path ${lib.escapeShellArg pair.path2})
        MARKER_FILE="$STATE_DIR/''${P1_CLEAN}..''${P2_CLEAN}.initialized"

        echo "--- Syncing '${pair.path1}' <-> '${pair.path2}' ---"
        if ! ensure_path ${lib.escapeShellArg pair.path1} "${if cPath1 then "1" else "0"}" "Path1" || \
           ! ensure_path ${lib.escapeShellArg pair.path2} "${if cPath2 then "1" else "0"}" "Path2"; then
          EXIT_CODE=1
        else
          RCLONE_EXIT=0
          "$RCLONE" bisync \
            ${lib.escapeShellArg pair.path1} \
            ${lib.escapeShellArg pair.path2} \
            --resilient \
            --max-lock ${lib.escapeShellArg cfg.maxLock} \
            ${lib.escapeShellArgs cfg.extraArgs} \
            ${lib.escapeShellArgs pair.extraArgs} >"$TMPLOG" 2>&1 || RCLONE_EXIT=$?
          cat "$TMPLOG"

          if [ "$RCLONE_EXIT" -eq 0 ]; then
            if [ ! -f "$MARKER_FILE" ]; then
              record_initialized "$MARKER_FILE" ${lib.escapeShellArg pair.path1} ${lib.escapeShellArg pair.path2}
            fi
          else
            if grep -qiE "cannot find prior|first bisync|must use.*--resync" "$TMPLOG"; then
              if [ ! -f "$MARKER_FILE" ]; then
                # Never synchronized before on this system
                if [ "${if rFirst then "1" else "0"}" = "1" ]; then
                  echo "[rclone-sync] First-time sync detected for '${pair.path1}' <-> '${pair.path2}'."
                  echo "[rclone-sync] Performing automatic initial --resync (resync-mode: ${cfg.resyncMode})..."
                  if "$RCLONE" bisync \
                    ${lib.escapeShellArg pair.path1} \
                    ${lib.escapeShellArg pair.path2} \
                    --resync \
                    --resync-mode ${lib.escapeShellArg cfg.resyncMode} \
                    --resilient \
                    --max-lock ${lib.escapeShellArg cfg.maxLock} \
                    ${lib.escapeShellArgs cfg.extraArgs} \
                    ${lib.escapeShellArgs pair.extraArgs}; then
                    record_initialized "$MARKER_FILE" ${lib.escapeShellArg pair.path1} ${lib.escapeShellArg pair.path2}
                    echo "[rclone-sync] Initial baseline established successfully for '${pair.path1}' <-> '${pair.path2}'"
                  else
                    echo "[rclone-sync] Error: initial resync failed for '${pair.path1}' <-> '${pair.path2}'" >&2
                    EXIT_CODE=1
                  fi
                else
                  echo "[rclone-sync] Error: pair '${pair.path1}' <-> '${pair.path2}' has never been initialized and resyncOnFirstRun is false." >&2
                  echo "[rclone-sync] Run 'rclone-sync-init' manually to perform initial sync." >&2
                  EXIT_CODE=1
                fi
              else
                # Already synchronized before: this is a subsequent desync/conflict error!
                if [ "${if aResync then "1" else "0"}" = "1" ]; then
                  echo "[rclone-sync] Desynchronization detected for already initialized pair '${pair.path1}' <-> '${pair.path2}'."
                  echo "[rclone-sync] autoResync is true: performing automatic recovery --resync..."
                  if ! "$RCLONE" bisync \
                    ${lib.escapeShellArg pair.path1} \
                    ${lib.escapeShellArg pair.path2} \
                    --resync \
                    --resync-mode ${lib.escapeShellArg cfg.resyncMode} \
                    --resilient \
                    --max-lock ${lib.escapeShellArg cfg.maxLock} \
                    ${lib.escapeShellArgs cfg.extraArgs} \
                    ${lib.escapeShellArgs pair.extraArgs}; then
                    echo "[rclone-sync] Error: recovery resync failed for '${pair.path1}' <-> '${pair.path2}'" >&2
                    EXIT_CODE=1
                  else
                    echo "[rclone-sync] Recovery resync completed successfully for '${pair.path1}' <-> '${pair.path2}'"
                  fi
                else
                  echo "[rclone-sync] ERROR: Desynchronization detected for previously initialized pair '${pair.path1}' <-> '${pair.path2}'!" >&2
                  echo "[rclone-sync] Automatic resync is disabled (autoResync = false) to prevent accidental data loss." >&2
                  echo "[rclone-sync] Please inspect differences and run 'rclone-sync-init' manually if you wish to resync." >&2
                  EXIT_CODE=1
                fi
              fi
            else
              echo "[rclone-sync] Error: sync failed for '${pair.path1}' <-> '${pair.path2}'" >&2
              EXIT_CODE=1
            fi
          fi
        fi
      ''
    ) cfg.paths}

    echo "=== Finished rclone sync job at $(date) (exit code: $EXIT_CODE) ==="
    exit "$EXIT_CODE"
  '';

  initScript = pkgs.writeShellScriptBin "rclone-sync-init" ''
    set -u

    RCLONE="${cfg.package}/bin/rclone"
    STATE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/rclone-sync"
    EXIT_CODE=0

    mkdir -p "$STATE_DIR"

    ensure_path() {
      local target="$1"
      local create_flag="$2"
      local label="$3"

      if [[ "$target" == /* ]]; then
        if [ ! -d "$target" ]; then
          if [ "$create_flag" = "1" ]; then
            echo "[rclone-sync-init] Creating local $label directory '$target'..."
            mkdir -p "$target"
          else
            echo "[rclone-sync-init] Error: local $label '$target' does not exist and create$label is false. Skipping (is external disk mounted?)." >&2
            return 1
          fi
        fi
      else
        if [ "$create_flag" = "1" ]; then
          echo "[rclone-sync-init] Ensuring remote $label '$target' exists..."
          if ! "$RCLONE" mkdir "$target"; then
            echo "[rclone-sync-init] Error: Failed to create remote $label '$target'" >&2
            return 1
          fi
        fi
      fi
      return 0
    }

    record_initialized() {
      local marker="$1"
      local p1="$2"
      local p2="$3"
      {
        echo "Initialized: $(date)"
        echo "Path1: $p1"
        echo "Path2: $p2"
      } > "$marker"
    }

    clean_path() {
      local p="$1"
      p="''${p#/}"
      p="''${p//\//_}"
      p="''${p//:/_}"
      p="''${p// /_}"
      echo -n "$p"
    }

    echo "=== Starting manual rclone bisync initialization (--resync) ==="

    ${lib.concatMapStringsSep "\n" (pair:
      let
        cPath1 = if pair.createPath1 != null then pair.createPath1 else cfg.createPath1;
        cPath2 = if pair.createPath2 != null then pair.createPath2 else cfg.createPath2;
      in ''
        P1_CLEAN=$(clean_path ${lib.escapeShellArg pair.path1})
        P2_CLEAN=$(clean_path ${lib.escapeShellArg pair.path2})
        MARKER_FILE="$STATE_DIR/''${P1_CLEAN}..''${P2_CLEAN}.initialized"

        echo "--- Initializing '${pair.path1}' <-> '${pair.path2}' (resync-mode: ${cfg.resyncMode}) ---"
        if ! ensure_path ${lib.escapeShellArg pair.path1} "${if cPath1 then "1" else "0"}" "Path1" || \
           ! ensure_path ${lib.escapeShellArg pair.path2} "${if cPath2 then "1" else "0"}" "Path2"; then
          EXIT_CODE=1
        else
          if "$RCLONE" bisync \
            ${lib.escapeShellArg pair.path1} \
            ${lib.escapeShellArg pair.path2} \
            --resync \
            --resync-mode ${lib.escapeShellArg cfg.resyncMode} \
            --resilient \
            --max-lock ${lib.escapeShellArg cfg.maxLock} \
            ${lib.escapeShellArgs cfg.extraArgs} \
            ${lib.escapeShellArgs pair.extraArgs} \
            "$@"; then
            record_initialized "$MARKER_FILE" ${lib.escapeShellArg pair.path1} ${lib.escapeShellArg pair.path2}
            echo "[rclone-sync-init] Baseline marked as initialized for '${pair.path1}' <-> '${pair.path2}'"
          else
            echo "[rclone-sync-init] Error: Failed to initialize '${pair.path1}' <-> '${pair.path2}'" >&2
            EXIT_CODE=1
          fi
        fi
      ''
    ) cfg.paths}

    if [ "$EXIT_CODE" -eq 0 ]; then
      echo "=== Initial resync for all paths completed successfully ==="
    else
      echo "=== Initial resync completed with errors (exit code: $EXIT_CODE) ===" >&2
    fi
    exit "$EXIT_CODE"
  '';
in
{
  options.services.rclone-sync = {
    enable = lib.mkEnableOption "periodic rclone bisync synchronization";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.rclone;
      defaultText = lib.literalExpression "pkgs.rclone";
      description = "The rclone package to use.";
    };

    intervalMinutes = lib.mkOption {
      type = lib.types.ints.positive;
      default = 5;
      description = "Interval in minutes (n) between sync runs.";
      example = 5;
    };

    maxLock = lib.mkOption {
      type = lib.types.str;
      default =
        if cfg.intervalMinutes > 1 then
          "${toString (cfg.intervalMinutes - 1)}m"
        else
          "30s";
      defaultText = lib.literalExpression ''"''${toString (config.services.rclone-sync.intervalMinutes - 1)}m"'';
      description = "Duration for rclone --max-lock flag. Defaults to (n - 1)m.";
    };

    resyncOnFirstRun = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Automatically run initial `--resync` only when a pair has never been synchronized before
        (tracked via marker files in ~/.local/state/rclone-sync/).
        Subsequent desynchronizations will NOT be automatically resynced unless autoResync is true.
      '';
    };

    autoResync = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Automatically run `--resync` on subsequent runs if an already-initialized pair
        experiences a desynchronization error. Defaults to false to prevent accidental data loss.
      '';
    };

    resyncMode = lib.mkOption {
      type = lib.types.enum [
        "newer"
        "path1"
        "path2"
        "older"
        "larger"
        "smaller"
      ];
      default = "newer";
      description = ''
        During `--resync`, which file version to prefer when both sides have the same file
        with differences. Recommended: `newer`.
      '';
    };

    createPath1 = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to automatically create Path1 if it does not exist.
        Defaults to false for safety (protects against unmounted external drives/mountpoints).
      '';
    };

    createPath2 = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to automatically create Path2 if it does not exist.
        Defaults to false for safety (protects against unmounted external drives/mountpoints).
      '';
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Global extra arguments to pass to rclone bisync.";
      example = [ "--verbose" ];
    };

    paths = lib.mkOption {
      type = lib.types.listOf pairType;
      default = [ ];
      description = ''
        List of sync pairs [(path1, path2)]. Each pair can be a 2-element list `[ path1 path2 ]`
        or an attribute set `{ path1 = "..."; path2 = "..."; createPath1 = false; createPath2 = false; extraArgs = [ ... ]; }`.
      '';
      example = lib.literalExpression ''
        [
          [ "/home/litc/Documents" "remote:Documents" ]
          {
            path1 = "/home/litc/Pictures";
            path2 = "remote:Pictures";
            createPath1 = true;
            createPath2 = true;
            extraArgs = [ "--check-access" ];
          }
        ]
      '';
    };
  };

  config = lib.mkIf (cfg.enable && cfg.paths != [ ]) {
    home.packages = [ initScript ];

    systemd.user.services.rclone-sync = {
      Unit = {
        Description = "Periodic rclone bisync service";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${syncScript}";
        Environment = [
          "PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.gnugrep cfg.package ]}"
        ];
      };
    };

    systemd.user.timers.rclone-sync = {
      Unit = {
        Description = "Timer for periodic rclone bisync service";
      };

      Timer = {
        OnBootSec = "2m";
        OnUnitActiveSec = "${toString cfg.intervalMinutes}m";
        Persistent = true;
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
