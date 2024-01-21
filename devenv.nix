{ pkgs, ... }:

{
  cachix.pull = [ "apex" ];
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [ pkgs.git ];

  devcontainer= {
    enable = true;
    settings = {
      image = "ghcr.io/mcdonc/devenv:pyrewrite";
      customizations.vscode.extensions = [
        "ms-python.python"
        "ms-python.vscode-pylance"
        "visualstudioexptteam.vscodeintellicode"
        "jnoortheen.nix-ide"
      ];
    };
  };

  services.postgres = {
    enable = true;
    package = pkgs.postgresql_15;
    initialDatabases = [{ name = "testdb"; }];
    extensions = extensions: [ extensions.postgis extensions.timescaledb ];
    settings.shared_preload_libraries = "timescaledb";
    initialScript = "CREATE EXTENSION IF NOT EXISTS timescaledb;";
  };

  services.mongodb = { enable = true; };

  # https://devenv.sh/scripts/
  scripts.hello.exec = "echo hello from $GREET";

  enterShell = ''
    hello
    git --version
  '';

  # https://devenv.sh/languages/
  # languages.nix.enable = true;

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # https://devenv.sh/processes/
  # processes.ping.exec = "ping example.com";

  # See full reference at https://devenv.sh/reference/options/
}
