{
  description = "Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    devenv.url = "github:cachix/devenv";
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, nixpkgs, devenv, systems, ... } @ inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
      projectName = "test-project";
      version = "0.1.0";
      
      commonDeps = pkgs: {
        nativeBuildInputs = [ pkgs.pkg-config ];
        buildInputs = [ pkgs.openssl.dev ];
      };

      mkBuild = system:
        let
          targetArch = {
            nixConfig = if (system == "aarch64-darwin" || system == "aarch64-linux")
              then "aarch64-unknown-linux-gnu" 
              else "x86_64-unknown-linux-gnu";
          };

          targetPkgs = import nixpkgs {
            localSystem = system;
            crossSystem.config = targetArch.nixConfig;
          };

          rustBinary = targetPkgs.rustPlatform.buildRustPackage {
            inherit version;
            pname = projectName;
            src = ./.;
            cargoLock.lockFile = ./Cargo.lock;
            inherit (commonDeps targetPkgs) nativeBuildInputs buildInputs;
          };
        in
        {
          devenv-up = self.devShells.${system}.default.config.procfileScript;
          devenv-test = self.devShells.${system}.default.config.test;
          
          container = targetPkgs.dockerTools.buildImage {
            inherit (rustBinary) name;
            tag = "latest";
            copyToRoot = targetPkgs.buildEnv {
              name = "image-root";
              paths = [ rustBinary targetPkgs.openssl targetPkgs.glibc ];
            };
            created = "now";
            config = {
              Cmd = [ "/bin/${projectName}" ];
              WorkingDir = "/";
            };
          };
        };
    in
    {
      inherit projectName commonDeps;
      packages = forEachSystem mkBuild;
      devShells = forEachSystem (system: {
        default = devenv.lib.mkShell {
          inherit inputs;
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [{ imports = [ ./devenv.nix ]; }];
        };
      });
    };
}

