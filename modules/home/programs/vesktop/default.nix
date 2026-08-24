{ config, lib, ... }:

let
  raw = config.myPalette;
  colors = lib.mapAttrs (_: v: "#${v}") raw;
in
{
  programs.vesktop = {
    enable = true;

    vencord.extraQuickCss = ''
      * {
        --background-primary: ${colors.base00} !important;
        --background-secondary: ${colors.base01} !important;
        --background-secondary-alt: ${colors.base02} !important;
        --background-tertiary: ${colors.base03} !important;
        --background-accent: ${colors.base02} !important;
        --background-floating: ${colors.base02} !important;
        --background-modifier-hover: ${colors.base03} !important;
        --background-modifier-selected: ${colors.base03} !important;
        --background-modifier-active: ${colors.base03} !important;
        --background-modifier-subtle: ${colors.base01} !important;
        --background-nested-floating: ${colors.base01} !important;

        --text-normal: ${colors.base0F} !important;
        --text-muted: ${colors.base08} !important;
        --text-link: ${colors.base0D} !important;
        --text-positive: ${colors.base0F} !important;
        --text-warning: ${colors.base0F} !important;
        --text-danger: ${colors.base0F} !important;
        --text-brand: ${colors.base0F} !important;
        --text-secondary: ${colors.base08} !important;
        --text-faint: ${colors.base04} !important;
        --header-primary: ${colors.base0F} !important;
        --header-secondary: ${colors.base08} !important;

        --interactive-normal: ${colors.base08} !important;
        --interactive-hover: ${colors.base0F} !important;
        --interactive-active: ${colors.base0F} !important;
        --interactive-muted: ${colors.base04} !important;

        --brand-experiment: ${colors.base03} !important;
        --brand-experiment-560: ${colors.base03} !important;
        --button-secondary-background: ${colors.base03} !important;
        --button-secondary-background-hover: ${colors.base02} !important;
        --button-secondary-text: ${colors.base0F} !important;
        --button-secondary-border: ${colors.base03} !important;

        --status-positive: ${colors.base0F} !important;
        --status-warning: ${colors.base0F} !important;
        --status-danger: ${colors.base0F} !important;
        --status-dnd: ${colors.base0F} !important;

        --scrollbar-thin-thumb: ${colors.base03} !important;
        --scrollbar-auto-thumb: ${colors.base03} !important;
        --scrollbar-thin-track: transparent !important;
        --scrollbar-auto-track: transparent !important;

        --input-background: ${colors.base02} !important;
        --input-border: ${colors.base03} !important;

        --card-bg: ${colors.base01} !important;
        --card-elevated-bg: ${colors.base02} !important;
        --tooltip-background: ${colors.base02} !important;
        --tooltip-color: ${colors.base0F} !important;
        --popout-background: ${colors.base01} !important;

        --channel-icon: ${colors.base08} !important;
        --channel-text-area-placeholder: ${colors.base04} !important;
        --channels-default: ${colors.base08} !important;
        --interactive-hover-highlight: ${colors.base0F} !important;
        --mention-foreground: ${colors.base0F} !important;
        --mention-background: ${colors.base03} !important;
        --scrollbar-auto-scrollbar-color-thumb: ${colors.base03} !important;
        --scrollbar-auto-scrollbar-color-track: transparent !important;
        --standard-underline-link-color: ${colors.base0D} !important;
      }

      .guilds-1qVjlf,
      .sidebar-1tnSQ8,
      .sidePanel-1COjTi {
        background-color: ${colors.base01} !important;
      }

      .channels-1YIRaB,
      .listDefault-2F-J2K,
      .list-1YIBZQ {
        background-color: ${colors.base00} !important;
      }

      .chatContent-1Uy7by,
      .content-1SgpWY,
      .memberList-1YrQk0 {
        background-color: ${colors.base00} !important;
      }

      .toolbar-1t6brx,
      .searchBar-2DGWDV {
        background-color: ${colors.base01} !important;
      }

      .modalRoot-1-KsBs,
      .modal-3HDQZV {
        background-color: ${colors.base01} !important;
      }

      .contextMenu-2h-eBb {
        background-color: ${colors.base01} !important;
        border-color: ${colors.base03} !important;
      }
      .contextMenu-2h-eBb .item-1YgJvn:hover {
        background-color: ${colors.base03} !important;
      }

      .rolePill-2IgRLl {
        background-color: ${colors.base02} !important;
        color: ${colors.base08} !important;
      }

      .reaction-1VHgf2 {
        background-color: ${colors.base02} !important;
        border-color: ${colors.base03} !important;
        color: ${colors.base0F} !important;
      }

      .mention-1FmfqS {
        background-color: ${colors.base03} !important;
        color: ${colors.base0F} !important;
      }

      .premiumIcon-1_fT5C,
      .boostingIcon-23WqCE {
        filter: grayscale(1) brightness(0.8);
      }

      [class*="colorBrand"] {
        color: ${colors.base0D} !important;
      }
      [class*="brand-"] {
        color: ${colors.base0F} !important;
      }

      ::-webkit-scrollbar {
        width: 6px;
      }
      ::-webkit-scrollbar-thumb {
        background: ${colors.base03} !important;
        border-radius: 3px;
      }
      ::-webkit-scrollbar-track {
        background: transparent !important;
      }

      .peopleColumn-2 ThyV,
      .tierRegion-2h-JEE {
        backdrop-filter: none !important;
        background-color: ${colors.base01} !important;
      }
    '';
  };
}
