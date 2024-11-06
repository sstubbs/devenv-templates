{ pkgs, inputs, ... }: {
  name = inputs.self.projectName;

  packages = with pkgs; [
    cargo-watch
    clippy
  ] ++ (with inputs.self.commonDeps pkgs; buildInputs ++ nativeBuildInputs);

  languages.rust.enable = true;

  enterShell = ''
    echo "Rust development environment ready!"
    rustc --version
    cargo --version
  '';

  processes = {
    build.exec = "cargo build --release";
    test.exec = "cargo test";
    watch.exec = "cargo watch -x run";
    container.exec = "nix build .#container";
  };
}

