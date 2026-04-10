{

  hydenix.hm.hyprland.extraConfig = ''
    opengl {
        # 某些情况下开启这个能提升渲染效率
        nvidia_anti_flicker = true
    }

    decoration {
        # 屏幕着色器路径 
        screen_shader = ~/.config/hypr/shaders/self_vibrance.frag

        rounding = 10

        # --- 透明度控制 ---
        active_opacity = 1.0
        inactive_opacity = 0.85
        fullscreen_opacity = 1.0

        # --- 模糊设置 (新版本中 blur 块依然保留) ---
        blur {
            enabled = true
            size = 5
            passes = 3
            new_optimizations = true
            xray = true

            contrast = 1.0
            brightness = 1.0
            vibrancy = 0.1
            vibrancy_darkness = 0.0
        }

        # --- 阴影设置
        shadow {
            enabled = true
            range = 10
            render_power = 2        # 阴影扩散的强度 (建议设为 3)
            color = rgba(00000044)
        }
    }


    $BROWSER = google-chrome-stable
    $scrPath = ~/.local/share/bin

    # windowrule
    windowrulev2 = float,class:^(floatkitty)$
    windowrulev2 = opacity 0.70 0.70,class:^(floatkitty)$
    windowrulev2 = size 80% 80%,stayfocused,class:^(floatkitty)$
    windowrulev2 = opacity 0.90 0.90,initialClass:^(Google-chrome)$
    windowrulev2 =fullscreen, class:^(neovide)$

    # pin chrome to workspace 8
    windowrulev2 = workspace 8,initialClass:^(google-chrome)$


    # keybindings
    unbind = $mainMod, C
    unbind = $mainMod, A
    unbind = $mainMod, T
    unbind = $mainMod, F
    unbind = $mainMod, L
    unbind = ind = Alt, Return


    bind = $mainMod, Return, exec, kitty # launch terminal emulator
    bind = $mainMod, D, exec, pkill -x rofi || rofilaunch.sh d # launch application launcher
    bind = $mainMod, C, exec, windows-control -c google-chrome -e $BROWSER -w 8 -m "goto" # launch web browser
    bind = $mainMod, F, fullscreen


    # swap window
    bind = $mainMod shift,l,exec, hyprctl dispatch swapwindow r
    bind = $mainMod shift,h,exec, hyprctl dispatch swapwindow l
    bind = $mainMod shift,k,exec, hyprctl dispatch swapwindow u
    bind = $mainMod shift,j,exec, hyprctl dispatch swapwindow d

    # Move focus with mainMod + arrow keys
    bind = $mainMod, h, movefocus, l
    bind = $mainMod, l, movefocus, r
    bind = $mainMod, k, movefocus, u
    bind = $mainMod, j, movefocus, d

    # mainMod + \ open float kitty terminal on center
    bind = $mainMod,code:51,exec,[centerwindow 1] windows-control -c 'floatkitty' -e "kitty --class floatkitty" -w 66
    bind = ALT,code:51,exec,[centerwindow 1] windows-control -c 'floatkitty' -e "kitty --class floatkitty" -w 66 

    # hide window
    bind = $mainMod ctrl,h,exec,windows-control h 

    # show hide window
    bind = $mainMod ctrl,i,exec,windows-control s 

  '';

}
