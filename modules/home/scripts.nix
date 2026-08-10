{ ... }:

{
  home.file.".local/bin" = {
    source = ../../home/.local/bin;
    recursive = true;
    executable = true;
  };
}
