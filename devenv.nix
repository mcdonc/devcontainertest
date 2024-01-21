{ pkgs, ... }:

let
  mssql-odbc-driver = pkgs.unixODBCDrivers.msodbcsql17;

  odbcini = pkgs.writeTextFile {
    name = "eao_dash-odbcini";
    text = ''
      [${mssql-odbc-driver.fancyName}]
      Description = ${mssql-odbc-driver.meta.description}
      Driver = ${mssql-odbc-driver}/${mssql-odbc-driver.driver}
    '';
  };

  odbcsysini = builtins.dirOf odbcini;
  odbcinstini = builtins.baseNameOf odbcini;

in

{
  packages = with pkgs; [ stdenv.cc.cc mssql-odbc-driver git ];

  process = {
    implementation = "process-compose";
    process-compose = {
      tui = "false";
      port = 9999;
    };
  };

  process-managers.process-compose = {
    enable = true;
  };

  languages.python = {
    libraries = with pkgs; [ zlib imagemagick unixODBC ];
    enable = true;
    version = "3.11.7";
    venv = {
      enable = true;
    };
  };

  pre-commit.hooks = { flake8.enable = true; };

  devcontainer= {
    enable = true;
    settings = {
      updateContentCommand = ''
        cachix use devenv;cachix use apex;cachix use nixpkgs-python;devenv ci'';
      image = "ghcr.io/mcdonc/devenv:pyrewrite";
      customizations.vscode.extensions = [
        "ms-python.python"
        "ms-python.vscode-pylance"
        "visualstudioexptteam.vscodeintellicode"
        "jnoortheen.nix-ide"

      ];
    };
  };

  env.ODBCSYSINI = odbcsysini;
  env.ODBCINSTINI = odbcinstini;

  services.postgres = {
    enable = true;
    package = pkgs.postgresql_15;
    initialDatabases = [{ name = "testdb"; }];
    extensions = extensions: [ extensions.postgis extensions.timescaledb ];
    settings.shared_preload_libraries = "timescaledb";
    initialScript = "CREATE EXTENSION IF NOT EXISTS timescaledb;";
  };

  services.mongodb = { enable = true; };

  env.GREET = "devcontainertest";

  # https://devenv.sh/scripts/
  scripts.hello.exec = "echo hello from $GREET";

  enterShell = ''
    hello
    git --version
  '';

}
