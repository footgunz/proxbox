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
