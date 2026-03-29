{
  hydenix.hm.terminals.kitty = {
    enable = true;
    configText = ''
      #font_family      JetBrainsMono Nerd Font
      font_size        18.0
      bold_font        auto
      italic_font      auto
      bold_italic_font auto

      window_padding_width 4
      background_opacity 0.8
      confirm_os_window_close 0

      # Mouse
      # cursor_blink_interval 0
      copy_on_select                  yes 
      strip_trailing_spaces           always
      mouse_map right press ungrabbed paste_from_selection

      tab_bar_edge                    bottom
      tab_bar_style                   powerline
      tab_powerline_style             angled
      tab_bar_min_tabs                2
      tab_bar_align                   left

      ######## Keyboard Shortcuts #######
      # tab
      map alt+enter new_tab_with_cwd

      map alt+1 goto_tab 1
      map alt+2 goto_tab 2
      map alt+3 goto_tab 3
      map alt+4  goto_tab 4

      # window
      map alt+ctrl+enter new_window_with_cwd
      map alt+v toggle_layout tall

      map ctrl+= increase_font_size
      map ctrl+- decrease_font_size

      # move course
      # map alt+h neighboring_window left
      # map alt+k neighboring_window bottom
      # map alt+j neighboring_window top
      # map alt+l neighboring_window right
    '';
  };
}
