{
  config,
  lib,
  pkgs,
  ...
}:

let
  minimal = config.myProfile == "minimal";
  raw = config.myPalette;
  c = lib.mapAttrs (_: v: "#${v}") raw;
in
{
  programs.btop = {
    enable = true;
    package = pkgs.btop;

    settings = {
      color_theme = lib.mkForce (if minimal then "TTY" else "monochrome");
      theme_background = true;
      truecolor = true;
      force_tty = false;
      disable_presets = "Off";
      presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
      vim_keys = false;
      disable_mouse = false;
      rounded_corners = true;
      terminal_sync = true;
      graph_symbol = "braille";
      graph_symbol_cpu = "default";
      graph_symbol_gpu = "default";
      graph_symbol_mem = "default";
      graph_symbol_net = "default";
      graph_symbol_proc = "default";
      shown_boxes = "cpu mem net proc";
      update_ms = 2000;
      proc_sorting = "cpu lazy";
      proc_reversed = false;
      proc_tree = false;
      proc_colors = true;
      proc_gradient = true;
      proc_per_core = false;
      proc_mem_bytes = true;
      proc_cpu_graphs = true;
      proc_info_smaps = false;
      proc_left = false;
      proc_filter_kernel = false;
      proc_follow_detailed = true;
      proc_aggregate = false;
      keep_dead_proc_usage = false;
      cpu_graph_upper = "Auto";
      cpu_graph_lower = "Auto";
      show_gpu_info = "Auto";
      cpu_invert_lower = true;
      cpu_single_graph = false;
      cpu_bottom = false;
      show_uptime = true;
      show_cpu_watts = true;
      check_temp = true;
      cpu_sensor = "Auto";
      show_coretemp = true;
      cpu_core_map = "";
      temp_scale = "celsius";
      base_10_sizes = false;
      show_cpu_freq = true;
      freq_mode = "first";
      clock_format = "%X";
      background_update = true;
      custom_cpu_name = "";
      disks_filter = "";
      mem_graphs = true;
      mem_below_net = false;
      zfs_arc_cached = true;
      show_swap = true;
      swap_disk = true;
      show_disks = true;
      only_physical = true;
      use_fstab = true;
      zfs_hide_datasets = false;
      disk_free_priv = false;
      show_io_stat = true;
      io_mode = false;
      io_graph_combined = false;
      io_graph_speeds = "";
      swap_upload_download = false;
      net_download = 100;
      net_upload = 100;
      net_auto = true;
      net_sync = true;
      net_iface = "";
      base_10_bitrate = "Auto";
      show_battery = true;
      selected_battery = "Auto";
      show_battery_watts = true;
      log_level = "WARNING";
      save_config_on_exit = false;
      nvml_measure_pcie_speeds = true;
      rsmi_measure_pcie_speeds = true;
      gpu_mirror_graph = true;
      shown_gpus = "nvidia amd intel";
      custom_gpu_name0 = "";
      custom_gpu_name1 = "";
      custom_gpu_name2 = "";
      custom_gpu_name3 = "";
      custom_gpu_name4 = "";
      custom_gpu_name5 = "";
    };
  };

  xdg.configFile."btop/themes/monochrome.theme" = lib.mkIf (!minimal) {
    text = ''
      theme[main_bg]="${c.base00}"
      theme[main_fg]="${c.base05}"

      theme[title]="${c.base05}"

      theme[hi_fg]="${c.base0D}"

      theme[selected_bg]="${c.base0D}"
      theme[selected_fg]="${c.base00}"

      theme[inactive_fg]="${c.base03}"

      theme[graph_text]="${c.base05}"

      theme[meter_bg]="${c.base02}"

      theme[proc_misc]="${c.base0E}"

      theme[cpu_box]="${c.base0D}"
      theme[mem_box]="${c.base0B}"
      theme[net_box]="${c.base08}"
      theme[proc_box]="${c.base0C}"

      theme[div_line]="${c.base02}"

      theme[temp_start]="${c.base0E}"
      theme[temp_mid]="${c.base0A}"
      theme[temp_end]="${c.base08}"

      theme[cpu_start]="${c.base0D}"
      theme[cpu_mid]="${c.base0C}"
      theme[cpu_end]="${c.base0B}"

      theme[free_start]="${c.base0E}"
      theme[free_mid]="${c.base0A}"
      theme[free_end]="${c.base08}"

      theme[cached_start]="${c.base0C}"
      theme[cached_mid]="${c.base0D}"
      theme[cached_end]="${c.base0E}"

      theme[available_start]="${c.base0A}"
      theme[available_mid]="${c.base09}"
      theme[available_end]="${c.base08}"

      theme[used_start]="${c.base0B}"
      theme[used_mid]="${c.base0C}"
      theme[used_end]="${c.base0D}"

      theme[download_start]="${c.base0D}"
      theme[download_mid]="${c.base0B}"
      theme[download_end]="${c.base0C}"

      theme[upload_start]="${c.base0E}"
      theme[upload_mid]="${c.base0A}"
      theme[upload_end]="${c.base08}"

      theme[process_start]="${c.base0B}"
      theme[process_mid]="${c.base0C}"
      theme[process_end]="${c.base0D}"
    '';
  };
}
