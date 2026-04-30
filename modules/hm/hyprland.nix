{ pkgs, ... }:
{
  wayland.windowManager.hyprland.plugins = [
    pkgs.hyprlandPlugins.hyprscrolling
  ];

  hydenix.hm.hyprland.extraConfig = ''
    plugin = ${pkgs.hyprlandPlugins.hyprscrolling}/lib/libhyprscrolling.so

    plugin {
        hyprscrolling {
            column_width = 0.66

            follow_focus = true
            focus_fit_method = 1

            fullscreen_on_one_column = true
        }
    }

    general {
        layout = scrolling 
    }

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
    unbind = Alt, Return

    # mainMod + \ open float kitty terminal on center
    bind = $mainMod,code:51,exec,[centerwindow 1] windows-control -c 'floatkitty' -e "kitty --class floatkitty" -w 66
    bind = ALT,code:51,exec,[centerwindow 1] windows-control -c 'floatkitty' -e "kitty --class floatkitty" -w 66 

    bind = $mainMod, Return, exec, kitty # launch terminal emulator
    bind = $mainMod, D, exec, pkill -x rofi || rofilaunch.sh d # launch application launcher
    bind = $mainMod, C, exec, windows-control -c google-chrome -e $BROWSER -w 8 -m "goto" # launch web browser
    bind = $mainMod, F, fullscreen

    # hide window
    bind = $mainMod ctrl,u,exec,windows-control h 

    # show hide window
    bind = $mainMod ctrl,i,exec,windows-control s 

    # swap window
    bind = $mainMod shift,l,exec, hyprctl dispatch swapwindow r
    bind = $mainMod shift,h,exec, hyprctl dispatch swapwindow l
    bind = $mainMod shift,k,exec, hyprctl dispatch swapwindow u
    bind = $mainMod shift,j,exec, hyprctl dispatch swapwindow d

    # # Move focus with mainMod + arrow keys
    # bind = $mainMod, h, movefocus, l
    # bind = $mainMod, l, movefocus, r
    # bind = $mainMod, k, movefocus, u
    # bind = $mainMod, j, movefocus, d

    # --- 焦点移动 (Focus) ---
    # 使用 layoutmsg focus 可以实现循环移动并自动居中
    bind = $mainMod, h, layoutmsg, focus l
    bind = $mainMod, l, layoutmsg, focus r
    bind = $mainMod, k, layoutmsg, focus u
    bind = $mainMod, j, layoutmsg, focus d

    # --- 窗口位置交换 (Swap) ---
    bind = $mainMod SHIFT, h, layoutmsg, swapcol l
    bind = $mainMod SHIFT, l, layoutmsg, swapcol r

    # --- 窗口宽度调整 (Resize) ---
    # 可以在预设的比例（0.33, 0.5, 0.66, 1.0）之间循环切换
    bind = $mainMod, R, layoutmsg, colresize +conf

    # --- 提升为独立列 (Promote) ---
    # 如果窗口被垂直堆叠了，可以用这个命令将其拉出来变成独立的一列
    bind = $mainMod, Y, layoutmsg, promote

    # --- 适配屏幕 (Fit) ---
    # 快速将当前窗口或所有窗口调整至适合屏幕
    bind = $mainMod, Equal, layoutmsg, fit active

  '';

}
