{
  outputs = { ... }: {
    overlays.default = (self: super: {

      python311 = super.python311.override {
        packageOverrides = pyself: pysuper: {
          click = pysuper.click.overrideAttrs (_: {
            setuptoolsCheckPhase = "true";
            pytestCheckPhase = "true";
            doCheck = false;
          });
          sphinx-better-theme = pysuper.sphinx-better-theme.overrideAttrs
            (_: { pythonCatchConflictsPhase = "true"; });
          sphinx = pysuper.sphinx.overrideAttrs (_: {
            setuptoolsCheckPhase = "true";
            pytestCheckPhase = "true";
            doCheck = false;
          });
        };
      };

      thrift = super.thrift.overrideAttrs (_: { checkPhase = "true"; });

      openssl_1_1_with_tls_1_0 = super.openssl_1_1.override {
        # overrides etc/ssl/openssl.cnf
        # SQL Server 2008 needs TLS 1.0
        conf = ./openssl.cnf;
      };

      krb5_with_openssl_1_1 = super.krb5.override {
        # krb5 uses openssl too
        openssl = self.openssl_1_1_with_tls_1_0;
      };

      libkrb5_with_openssl_1_1 = self.krb5_with_openssl_1_1.override {
        # krb5 uses openssl too
        type = "lib";
      };

      unixODBCDrivers = super.unixODBCDrivers // {
        msodbcsql17 = super.unixODBCDrivers.msodbcsql17.overrideAttrs (old: {
          postFixup = ''
            patchelf --set-rpath ${
              super.lib.makeLibraryPath [
                super.unixODBC
                self.openssl_1_1_with_tls_1_0
                self.libkrb5_with_openssl_1_1
                super.libuuid
                super.stdenv.cc.cc
              ]
            } $out/${super.unixODBCDrivers.msodbcsql17.passthru.driver}
          '';
        });
      };
    });
  };
}
