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
          sha256 = "sha256-pMkBSMN3yjLHf+0qJocQXt3m2wXQd1LuSk7EMEF9zPc=";
        };
        "aarch64-linux" = {
          url = "https://github.com/footgunz/proxbox/releases/download/v${version}/proxbox-linux-arm64";
          sha256 = "sha256-BTQ67zx2pLRyLxQ7LUYWJpFR/VWuaykQpKDM3gueGUE=";
        };
        "x86_64-darwin" = {
          url = "https://github.com/footgunz/proxbox/releases/download/v${version}/proxbox-darwin-amd64";
          sha256 = "sha256-AB9BpyMcWBnuAMigt20B5vFpechgSCOA7/yRyFMyQCk=";
        };
        "aarch64-darwin" = {
          url = "https://github.com/footgunz/proxbox/releases/download/v${version}/proxbox-darwin-arm64";
          sha256 = "sha256-FAKNFhAqfOen926c7QonaSV26dZ7FJZ3nfd8O+VaUsk=";
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
