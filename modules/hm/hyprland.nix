{

  hydenix.hm.hyprland.extraConfig = ''
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
