{
  # PipeWire audio stack (NixOS 26.05 options).
  #
  # No codec/ALSA/hardware-specific settings: physical audio device
  # verification happens on the real Aspire 7.

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true; # wpctl binds + pavucontrol/waybar pulseaudio modules
    wireplumber.enable = true;
  };
}
