{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.dynamic-shortcuts;
in {
  options.services.dynamic-shortcuts = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, allow dynamic shortcuts.
      '';
    };
    # array of derivations
    shortcuts = mkOption {
      type = types.listOf types.package;
      description = ''
        Array of packages in nixpkgs you want to shortcut;
      '';
    };
  };

  config = let
    inherit (builtins) parseDrvName listToAttrs map;
    # pkg -> {shortcutValue}
    packageToShortcut = package: let
      fallbackName = (parseDrvName package.name).name;
      meta = (parseDrvName package.name).meta or {};
    in {
      name = "${meta.mainProgram or fallbackName}.desktop";
      value = {
        text = ''
          [Desktop Entry]
          Version=1.0
          Type=Application
          Name=${fallbackName}
          Comment=${meta.description or "Run ${fallbackName}"}
          Exec=sh -c '${pkgs.libnotify}/bin/notify-send "Launching ${meta.name or fallbackName}..." && nix run nixpkgs#${fallbackName}'
          Icon=${meta.icon or meta.mainProgram or fallbackName}
          Terminal=false
          Categories=Dynamic Shortcuts
        '';
      };
    };
    # [pkgs] -> [shortcutValue]
    shortcutsList = map packageToShortcut cfg.shortcuts;
  in
    lib.mkIf cfg.enable {
      home.file = listToAttrs (map
        (app: {
          name = ".local/share/applications/${app.name}";
          inherit (app) value;
        })
        shortcutsList);
    };
}
