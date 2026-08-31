{
  config,
  lib,
  pkgs,
  ...
}:

let
  colors = lib.mapAttrs (_: v: "#${v}") config.myPalette;
  hasBattery = config.myHost.batteryPath != "";
  backlightDevice = config.myHost.backlightDevice;
  hasBacklight = backlightDevice != "";

  qml =
    {
      name,
      path,
      extraArgs ? { },
    }:
    {
      name = "quickshell/bar/${name}";
      value.text = import path (
        {
          inherit colors;
        }
        // extraArgs
      );
    };

  files = [
    {
      name = "shell.qml";
      path = ./bar.nix;
      extraArgs = {
        inherit hasBattery;
      };
    }
    {
      name = "OsLogo.qml";
      path = ./widgets/os-logo.nix;
    }
    {
      name = "Workspaces.qml";
      path = ./widgets/workspaces.nix;
    }
    {
      name = "FocusedApp.qml";
      path = ./widgets/focused-app.nix;
    }
    {
      name = "Clock.qml";
      path = ./widgets/clock.nix;
    }
    {
      name = "Tray.qml";
      path = ./widgets/tray.nix;
    }
    {
      name = "Bluetooth.qml";
      path = ./widgets/bluetooth.nix;
    }
    {
      name = "BluetoothPanel.qml";
      path = ./widgets/bluetooth-panel.nix;
    }
    {
      name = "Volume.qml";
      path = ./widgets/volume.nix;
    }
    {
      name = "VolumePanel.qml";
      path = ./widgets/volume-panel.nix;
    }
    {
      name = "Wifi.qml";
      path = ./widgets/wifi.nix;
    }
    {
      name = "VolumeSlider.qml";
      path = ./widgets/volume-slider.nix;
    }
    {
      name = "ControlPanel.qml";
      path = ./widgets/control-panel.nix;
      extraArgs = {
        inherit backlightDevice hasBacklight;
      };
    }
    {
      name = "Control.qml";
      path = ./widgets/control.nix;
    }
  ]
  ++ lib.optionals hasBattery [
    {
      name = "Battery.qml";
      path = ./widgets/battery.nix;
    }
  ];
in
{
  programs.quickshell = {
    enable = true;
    package = pkgs.quickshell;
  };

  xdg.configFile = builtins.listToAttrs (map qml files);
}
