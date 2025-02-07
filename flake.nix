{
  description = "HTTP and SOCKS proxy server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};
      version = builtins.readFile ./VERSION;

      binaryUrls = {
        "x86_64-linux" = {
          url = "https://github.com/footgunz/proxbox/releases/download/v${version}/proxbox-linux-amd64";
          sha256 = "sha256-PVaU5kXm8cH+YRMYNQqxfOampdBxqyGcWM558A8uqsQ=";
        };
        "aarch64-linux" = {
          url = "https://github.com/footgunz/proxbox/releases/download/v${version}/proxbox-linux-arm64";
          sha256 = "sha256-L+PRrmz2SmXarAYqQQjSsqfe+K+bMh2Ym7JgiHKuaKY=";
        };
        "x86_64-darwin" = {
          url = "https://github.com/footgunz/proxbox/releases/download/v${version}/proxbox-darwin-amd64";
          sha256 = "sha256-N66ZEMNPaE1HUKbAUo5D926ul3HsuIprEFcOcfXPmv0=";
        };
        "aarch64-darwin" = {
          url = "https://github.com/footgunz/proxbox/releases/download/v${version}/proxbox-darwin-arm64";
          sha256 = "sha256-Cn14PeZPmmZDYuOzYO0EH4I7QLTHJB0egYSxX2jnm+U=";
        };
      };
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.buildGoModule {
            pname = "proxbox";
            inherit version;
            src = ./.;

            vendorHash = "sha256-E0sUSuzsxRCmKydKvyfGq7719fSy7gxFbzxseXHRq+Y=";

            ldflags = [
              "-s"  # Strip symbol table
              "-w"  # Strip DWARF debugging info
              "-X github.com/footgunz/proxbox/cmd.Version=${version}"
              "-X github.com/footgunz/proxbox/cmd.CommitSHA=${self.rev or "dev"}"
            ];

            meta = with pkgs.lib; {
              description = "HTTP and SOCKS proxy server";
              homepage = "https://github.com/footgunz/proxbox";
              license = licenses.mit;
              maintainers = [ ];
            };
          };

          binary = pkgs.stdenv.mkDerivation {
            pname = "proxbox-bin";
            inherit version;

            src = pkgs.fetchurl (binaryUrls.${system});

            dontUnpack = true;

            installPhase = ''
              mkdir -p $out/bin
              cp $src $out/bin/proxbox
              chmod +x $out/bin/proxbox
            '';

            meta = with pkgs.lib; {
              description = "HTTP and SOCKS proxy server (pre-built binary)";
              homepage = "https://github.com/footgunz/proxbox";
              license = licenses.mit;
              maintainers = [ ];
              platforms = [ system ];
            };
          };
        });

      devShells = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              go
              gopls
              go-tools
            ];
          };
        });
    };
}
