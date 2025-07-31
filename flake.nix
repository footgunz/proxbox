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
      # Use git describe to get version, fallback to 0.0.0 for local builds
      version = if (self ? rev) then builtins.substring 1 (builtins.stringLength self.rev) self.rev else "0.0.0";

      binaryUrls = {
        "x86_64-linux" = {
          url = "https://github.com/footgunz/proxbox/releases/download/v${version}/proxbox-linux-amd64";
          sha256 = "sha256-Dn52VpIniJWvwj75XAD1xqj2i7Sppqxo9STgNtiOlY8=";
        };
        "aarch64-linux" = {
          url = "https://github.com/footgunz/proxbox/releases/download/v${version}/proxbox-linux-arm64";
          sha256 = "sha256-fYZXp+LFIqbfi1Zi+sVN3g5vfJRkZOAH+q87Eta1SV8=";
        };
        "x86_64-darwin" = {
          url = "https://github.com/footgunz/proxbox/releases/download/v${version}/proxbox-darwin-amd64";
          sha256 = "sha256-unlIhZW4hkE7lJBIQbdl5dl6MVgMzS4arwIMmhch3T8=";
        };
        "aarch64-darwin" = {
          url = "https://github.com/footgunz/proxbox/releases/download/v${version}/proxbox-darwin-arm64";
          sha256 = "sha256-SMlf8wt8cBISvfzK7fEdBwBmgo2o4mAndZWLeb+SJQg=";
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
