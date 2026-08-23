{ lib, pkgs, ... }:

let
  notifier = lib.getExe pkgs.gpu-screen-recorder-notification;

  notifyFn = ''
    notify() {
      ${notifier} \
        --text "$1" \
        --timeout 3.0 \
        --icon "$2"
    }
  '';

  recordingSavedNotification = pkgs.writeShellScript "gpu-screen-recorder-saved" ''
    ${notifyFn}

    case "''${2:-}" in
      regular) notify "Recording saved" record ;;
      replay) notify "Replay saved" replay ;;
      *) exit 0 ;;
    esac
  '';
in
{
  home.packages = [
    pkgs.gpu-screen-recorder-notification

    (pkgs.writeShellScriptBin "gsr" ''
      set -u

      RECORDER="gpu-screen-recorder"
      SAVE_DIR="$HOME/Videos"
      STATE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}"
      RUNTIME_DIR="''${XDG_RUNTIME_DIR:-$STATE_DIR}"
      LOG_FILE="$STATE_DIR/gpu-screen-recorder.log"
      PID_FILE="$RUNTIME_DIR/gpu-screen-recorder.pid"
      RECORDING_STATE_FILE="$RUNTIME_DIR/gpu-screen-recorder-recording"
      BUFFER_SECONDS=60

      ${notifyFn}

      show_notification() {
        notify "$1" "$2" >/dev/null 2>&1 &
      }

      recorder_pid() {
        [ -r "$PID_FILE" ] || return 1
        pid=$(cat "$PID_FILE")
        kill -0 "$pid" >/dev/null 2>&1 || return 1
        printf '%s\n' "$pid"
      }

      is_running() {
        recorder_pid >/dev/null
      }

      start() {
        : > "$LOG_FILE"

        if is_running; then
          show_notification "Screen recorder is already running" record
          return 0
        fi

        mkdir -p "$SAVE_DIR" "$STATE_DIR" "$RUNTIME_DIR"
        rm -f "$RECORDING_STATE_FILE"

        (
          unset __NV_PRIME_RENDER_OFFLOAD
          unset __NV_PRIME_RENDER_OFFLOAD_PROVIDER
          unset __GLX_VENDOR_LIBRARY_NAME
          unset __VK_LAYER_NV_optimus
          unset GBM_BACKEND
          unset NVD_BACKEND
          export __EGL_VENDOR_LIBRARY_FILENAMES="${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json"
          export LIBVA_DRIVERS_PATH="${pkgs.mesa}/lib/dri"

          exec "$RECORDER" \
            -w screen \
            -f 60 \
            -s 1920x1080 \
            -q ultra \
            -a default_output \
            -r "$BUFFER_SECONDS" \
            -c mkv \
            -ro "$SAVE_DIR" \
            -sc "${recordingSavedNotification}" \
            -o "$SAVE_DIR"
        ) >>"$LOG_FILE" 2>&1 &
        printf '%s\n' "$!" >"$PID_FILE"

        sleep 1
        if ! is_running; then
          rm -f "$PID_FILE"
          notify-send -a gpu-screen-recorder -u critical "Recording" \
            "Failed to start; see $LOG_FILE"
          return 1
        fi
      }

      stop() {
        pid=$(recorder_pid) || {
          show_notification "Screen recorder is not running" record
          return 1
        }

        kill -INT "$pid"
        rm -f "$PID_FILE" "$RECORDING_STATE_FILE"
        show_notification "Screen recorder stopped" record
      }

      toggle_recording() {
        if ! is_running; then
          start || return 1
        fi
        pid=$(recorder_pid) || return 1

        kill -RTMIN "$pid"
        if [ -f "$RECORDING_STATE_FILE" ]; then
          rm -f "$RECORDING_STATE_FILE"
        else
          : >"$RECORDING_STATE_FILE"
          show_notification "Recording started" record
        fi
      }

      save_replay() {
        pid=$(recorder_pid) || {
          show_notification "Screen recorder is not running" replay
          return 1
        }

        kill -USR1 "$pid"
      }

      case "''${1:-}" in
        toggle) toggle_recording ;;
        start) start ;;
        stop) stop ;;
        save) save_replay ;;
        *)
          echo "Usage: gsr {toggle|start|stop|save}" >&2
          exit 1
          ;;
      esac
    '')
  ];
}
