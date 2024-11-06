{ pkgs, config, ... }: {
  packages = [ pkgs.hello ];
  enterShell = "hello";
  processes.run.exec = "hello";
}
