{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  packages = with pkgs; [
    jq
    exoscale-cli
    opentofu
    github-cli
  ];

  git-hooks.hooks = {

  };

  tasks = { };

  enterShell = ''
    echo "FH Burgenland BITI devenv ready"
  '';
}
