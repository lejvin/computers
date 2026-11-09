{ pkgs, lib, ... }:
let
  clipboardHistory = pkgs.writeShellApplication {
    name = "clipboard-history";
    runtimeInputs = with pkgs; [
      cliphist
      fuzzel
      wl-clipboard
    ];
    text = ''
      if ! selection="$(cliphist list | fuzzel --dmenu --prompt 'Clipboard: ')"; then
        exit 0
      fi
      if [[ -n "$selection" ]]; then
        printf '%s\n' "$selection" | cliphist decode | wl-copy
      fi
    '';
  };
in
{
  # Let Firefox video playback inhibit Sway's idle timer directly.
  # The GTK portal can report success without actually inhibiting idle on Sway.
  home.sessionVariables.MOZ_WAKE_LOCK_TYPE = "WaylandIdleInhibit";

  home.pointerCursor.sway.enable = true;

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };

  programs.swaylock = {
    enable = true;
    settings.color = "1e1e2e";
  };

  services.mako = {
    enable = true;
    settings.default-timeout = 5000;
  };

  services.cliphist.enable = true;

  services.swayidle = {
    enable = true;
    # Wait for swaylock to acquire the lock before allowing sleep.
    extraArgs = [ "-w" ];
    timeouts = [
      {
        timeout = 600;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
    ];
    events = {
      before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
      lock = "${pkgs.swaylock}/bin/swaylock -f";
    };
  };

  programs.fuzzel.enable = true;

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.mainBar = {
      layer = "top";
      position = "bottom";
      height = 26;
      modules-left = [
        "sway/workspaces"
        "sway/mode"
      ];
      modules-right = [
        "backlight"
        "pulseaudio"
        "network"
        "battery"
        "disk"
        "cpu"
        "memory"
        "clock"
        "tray"
      ];
      backlight.format = "Brightness {percent}%";
      pulseaudio = {
        format = "Vol {volume}%";
        format-muted = "Muted";
        on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };
      network = {
        format-wifi = "Wi-Fi {essid} {signalStrength}%";
        format-ethernet = "LAN {ipaddr}";
        format-disconnected = "Offline";
      };
      battery = {
        format = "Bat {capacity}%";
        format-charging = "Bat {capacity}% +";
        states = {
          warning = 20;
          critical = 10;
        };
      };
      disk = {
        path = "/";
        format = "Disk {free}";
      };
      cpu.format = "CPU {usage}%";
      memory.format = "RAM {used:0.1f}G";
      clock = {
        format = "{:%Y-%m-%d %H:%M}";
        tooltip-format = "{:%A, %d %B %Y}";
      };
      tray = {
        icon-size = 20;
        spacing = 8;
      };
    };
    style = ''
      * { font-family: monospace; font-size: 12px; }
      window#waybar { background: #000000; color: #ffffff; }
      #workspaces button { padding: 0 6px; border-radius: 0; color: #ffffff; }
      #workspaces button.focused { background: #285577; }
      #workspaces button.urgent, #battery.critical { background: #900000; }
      #mode, #pulseaudio, #network, #battery, #disk, #cpu, #memory, #clock, #tray {
        padding: 0 8px;
      }
      #tray menu { background: #222222; color: #ffffff; }
      #tray menu menuitem:hover { background: #285577; }
    '';
  };

  systemd.user.services.waybar.Service.RestartSec = "5s";

  programs.foot = {
    enable = true;
    settings.main.font = "monospace:size=12";
  };

  programs.swayimg.enable = true;

  home.packages = with pkgs; [
    wl-clipboard
    sway-contrib.grimshot
  ];

  # Enable sway window manager
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraConfig = ''
      popup_during_fullscreen smart
    '';
    config = rec {
      modifier = "Mod4";
      bars = [ ];
      keybindings = lib.mkOptionDefault {
        "${modifier}+l" = "exec ${pkgs.swaylock}/bin/swaylock -f";
        "${modifier}+Shift+v" = "exec ${lib.getExe clipboardHistory}";
        "${modifier}+d" = "exec ${lib.getExe pkgs.fuzzel}";
        "Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify copy area";
        "Shift+Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify copy screen";
        "${modifier}+Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify copy active";
        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
        "XF86AudioRaiseVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioPause" = "exec ${pkgs.playerctl}/bin/playerctl pause";
        "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
        "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
        "XF86AudioStop" = "exec ${pkgs.playerctl}/bin/playerctl stop";
      };
      window = {
        titlebar = false;
      };
      terminal = "foot";
      input = {
        "*" = {
          xkb_layout = "se";
        };
        "type:touchpad" = {
          natural_scroll = "enabled";
        };
      };
      output = {
        "*" = {
          bg = "${./wallpaper.jpg} fill";
        };
        "eDP-1" = {
          scale = lib.mkDefault "1.25";
        };
      };
    };
  };
}
