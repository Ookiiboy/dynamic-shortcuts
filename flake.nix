{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    ignoreBoy.url = "github:Ookiiboy/ignoreBoy";
    # Non-flake
    editorconfig.url = "github:Ookiiboy/editor-config/";
    editorconfig.flake = false;
  };

  outputs = {
    self,
    systems,
    nixpkgs,
    pre-commit-hooks,
    editorconfig,
    ignoreBoy,
    ...
  }: let
    forAllSystems = nixpkgs.lib.genAttrs (import systems);
  in {
    formatter = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in
      pkgs.alejandra);
    checks = forAllSystems (system: {
      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          # Nix
          alejandra.enable = true;
          deadnix.enable = true;
          statix.enable = true;
          flake-checker.enable = true;
          # JSON
          check-json.enable = true;
          # Generic - .editorconfig
          editorconfig-checker.enable = true;
        };
      };
    });
    modules = rec {
      default = home-manager;
      home-manager = import ./modules/home-manager.nix;
    };
    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
      ignoreSettings = {
        github.languages = [];
        # gitignoreio.languages = [];
        # gitignoreio.hash = "";
        # Anything custom you might want in your .gitignore you can place in extraConfig.
        extraConfig = ''
          .pre-commit-config.yaml
          .editorconfig
        '';
      };
    in {
      default = pkgs.mkShell {
        # Environment Variables
        ENV = "dev";
        name = "Development_Shell";
        shellHook = ''
          if [ ! -d ".git" ]; then git init; fi
          ln -sf ${editorconfig}/.editorconfig ./.editorconfig
          ${self.checks.${system}.pre-commit-check.shellHook}
          ${ignoreBoy.lib.${system}.gitignore ignoreSettings}
        '';
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
      };
    });
  };
}
