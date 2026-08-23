{ config, ... }:

{
  programs.htop = {
    enable = true;

    settings =
      with config.lib.htop;
      {
        fields = with fields; [
          PID
          USER
          PRIORITY
          NICE
          M_VIRT
          M_RESIDENT
          M_PRIV
          STATE
          PERCENT_CPU
          PERCENT_MEM
          TIME
          COMM
        ];
        hide_kernel_threads = true;
        hide_userland_threads = false;
        hide_running_in_container = false;
        shadow_other_users = false;
        show_thread_names = false;
        show_program_path = true;
        highlight_base_name = false;
        highlight_deleted_exe = true;
        shadow_distribution_path_prefix = false;
        highlight_megabytes = true;
        highlight_threads = true;
        highlight_changes = false;
        highlight_changes_delay_secs = 5;
        find_comm_in_cmdline = true;
        strip_exe_from_cmdline = true;
        show_merged_command = false;
        header_margin = true;
        screen_tabs = true;
        detailed_cpu_time = false;
        cpu_count_from_one = false;
        show_cpu_smt_labels = false;
        show_cpu_usage = true;
        show_cpu_frequency = false;
        show_cpu_temperature = false;
        degree_fahrenheit = false;
        show_cached_memory = true;
        update_process_names = false;
        account_guest_in_cpu_meter = false;
        color_scheme = 6;
        save_config_on_exit = false;
        enable_mouse = true;
        delay = 15;
        hide_function_bar = false;
        header_layout = "two_50_50";
        tree_view = false;
        sort_key = fields.PERCENT_CPU;
        tree_sort_key = fields.PID;
        sort_direction = -1;
        tree_sort_direction = 1;
        tree_view_always_by_pid = false;
        all_branches_collapsed = false;
      }
      // leftMeters [
        (bar "LeftCPUs2")
        (bar "Memory")
        (bar "Swap")
      ]
      // rightMeters [
        (bar "RightCPUs2")
        (text "Tasks")
        (text "LoadAverage")
        (text "Uptime")
      ];
  };
}
