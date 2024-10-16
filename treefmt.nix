{ ... }:

{
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  programs.rustfmt.enable = true;
  settings.global.excludes = [
    ".direnv/*"
    ".env"
    ".envrc"
    ".gitignore"
    "target/*"
    "src/test.rs"
  ];
}
