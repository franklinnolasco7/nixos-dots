{ pkgs, ... }:

let
  json = pkgs.formats.json { };
in
{
  programs.micro = {
    enable = true;

    settings = {
      colorscheme = "dimspectra";
    };
  };

  xdg.configFile = {
    "micro/bindings.json".source = json.generate "micro-bindings" {
      "Alt-/" = "lua:comment.comment";
      "CtrlUnderscore" = "lua:comment.comment";
    };

    "micro/colorschemes/dimspectra.micro".text = ''
      color-link default                  "#B8B8B8,#101010"
      color-link comment                  "italic #5C6370"
      color-link comment.bright           "italic #6B7280"
      color-link identifier               "#BFC7D5"
      color-link identifier.class         "#61AFEF"
      color-link identifier.macro         "#C678DD"
      color-link identifier.var           "#BFC7D5"
      color-link constant                 "#D19A66"
      color-link constant.bool            "#D19A66"
      color-link constant.bool.true       "#D19A66"
      color-link constant.bool.false      "#D19A66"
      color-link constant.number          "#D19A66"
      color-link constant.string          "#98C379"
      color-link constant.string.url      "underline #56B6C2"
      color-link constant.specialChar     "#56B6C2"
      color-link statement                "bold #C678DD"
      color-link symbol                   "#8B92A3"
      color-link symbol.brackets          "#8B92A3"
      color-link symbol.operator          "#6B7280"
      color-link symbol.tag               "#E5C07B"
      color-link preproc                  "#E06C75"
      color-link preproc.shebang          "italic #E06C75"
      color-link type                     "#E5C07B"
      color-link type.keyword             "bold #C678DD"
      color-link special                  "#56B6C2"
      color-link underlined               "underline #61AFEF"
      color-link error                    "bold #E06C75"
      color-link error-message            "bold #E06C75"
      color-link message                  "#B8B8B8"
      color-link todo                     "bold #E5C07B"
      color-link selection                "#101010,#3A3A3A"
      color-link hlsearch                 "#101010,#61AFEF"
      color-link statusline               "#B8B8B8,#181818"
      color-link statusline.inactive      "#5C6370,#181818"
      color-link statusline.suggestions   "#B8B8B8,#181818"
      color-link tabbar                   "#5C6370,#101010"
      color-link tabbar.active            "#E5E5E5,#181818"
      color-link indent-char              "#3A3A3A,#101010"
      color-link line-number              "#5C6370,#101010"
      color-link current-line-number      "bold #E5E5E5,#101010"
      color-link cursor-line              "#181818"
      color-link color-column             "#1C1C1C"
      color-link divider                  "#232323,#101010"
      color-link scrollbar                "#232323,#101010"
      color-link ignore                   "#5C6370"
      color-link match-brace              "bold #56B6C2,#101010"
      color-link gutter-info              "#61AFEF,#101010"
      color-link gutter-error             "#E06C75,#101010"
      color-link gutter-warning           "#E5C07B,#101010"
      color-link diff-added               "#98C379,#101010"
      color-link diff-modified            "#E5C07B,#101010"
      color-link diff-deleted             "#E06C75,#101010"
      color-link tab-error                "#E06C75"
      color-link trailingws               "#E06C75"
    '';
  };
}
