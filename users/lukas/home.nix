{ pkgs, lib, ... }:

let
  pythonEnv = pkgs.python3.withPackages (
    ps: with ps; [
      scipy
      numpy
      pandas
      matplotlib
      pip
      jupyter
      notebook
      ipykernel
      debugpy
    ]
  );
in
{

  imports = [
    ../../home/thunderbird
  ];

  home.username = "lukas";
  home.homeDirectory = "/home/lukas";

  programs.obsidian.enable = true;

  home.pointerCursor = {
    enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    colorScheme = "dark";
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  services.easyeffects.enable = true;

  programs.firefox = {
    enable = true;
    # The UHD 620 lacks AV1 hardware decoding; software decoding stutters on live video.
    policies.Preferences."media.av1.enabled" = {
      Value = false;
      Status = "locked";
    };
  };

  programs.mpv.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
      "inode/directory" = [ "thunar.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/mw-matlabconnector" = [ "mw-matlabconnector.desktop" ];
      "x-scheme-handler/mw-simulink" = [ "mw-simulink.desktop" ];
      "x-scheme-handler/mw-matlab" = [ "mw-matlab.desktop" ];
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      nil
      nixfmt
      marksman
      prettier
    ];
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        line-number = "relative";
        cursorline = true;
        bufferline = "multiple";
        color-modes = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides.render = true;
      };
    };
    languages.language = [
      {
        name = "nix";
        language-servers = [ "nil" ];
        formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
        auto-format = true;
      }
      {
        name = "markdown";
        language-servers = [ "marksman" ];
        formatter = {
          command = "${pkgs.prettier}/bin/prettier";
          args = [
            "--parser"
            "markdown"
            "--prose-wrap"
            "preserve"
          ];
        };
        auto-format = true;
        text-width = 80;
        soft-wrap = {
          enable = true;
          wrap-at-text-width = true;
        };
      }
    ];
  };

  programs.vscode = {
    enable = true;
    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      extensions =
        (with pkgs.vscode-extensions; [
          ms-toolsai.jupyter
          tomoki1207.pdf
          catppuccin.catppuccin-vsc
          myriad-dreamin.tinymist
          ms-python.python
          ms-python.debugpy
          ms-python.vscode-pylance
          jnoortheen.nix-ide
          ms-vscode.cpptools-extension-pack
          ms-vscode.cpptools
        ])
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            publisher = "stmicroelectronics";
            name = "stm32-vscode-extension";
            version = "3.11.0";
            sha256 = "sha256-GNhX9uclUcutozlx68OtlQpKseT00998Rl07ct3KMdA=";
          }
        ];
      userSettings = {
        "python.defaultInterpreterPath" = "${pythonEnv}/bin/python3";
        "chat.disableAIFeatures" = true;
        "workbench.colorTheme" = "Catppuccin Mocha";
        "editor.lineNumbers" = "relative";
        "editor.renderLineHighlight" = "all";
        "editor.guides.indentation" = true;
        "editor.cursorStyle" = "line";
        "editor.minimap.enabled" = false;

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.nil}/bin/nil";
        "nix.serverSettings".nil.formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
          "editor.formatOnSave" = true;
        };

        "tinymist.preview.refresh" = "onType";
        "[typst]" = {
          "editor.defaultFormatter" = "myriad-dreamin.tinymist";
          "editor.wordWrap" = "on";
        };

        "markdown.validate.enabled" = true;
        "[markdown]" = {
          "editor.wordWrap" = "bounded";
          "editor.wordWrapColumn" = 80;
        };
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Lukas Ejvinsson";
        email = "lukas@ejvinsson.se";
      };
      init.defaultBranch = "main";
    };
  };

  programs.codex = {
    enable = true;
  };

  programs.fastfetch = {
    enable = true;
  };

  services.gammastep = {
    enable = true;
    provider = "geoclue2";
  };

  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = false;
      selection-notification = false;
    };
  };
  home.packages = with pkgs; [
    teams-for-linux
    gimp
    nextcloud-client
    qbittorrent
    gammastep
    xdg-utils
    playerctl
    remmina
    qalculate-gtk
    libqalculate
    gnuplot
    pythonEnv
    freecad
    gmsh
    netgen
    prusa-slicer
  ];

  home.stateVersion = "26.05";

}
