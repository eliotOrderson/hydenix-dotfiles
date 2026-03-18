{ ... }:
{

  hydenix.hm.shell.zsh.plugins = [ "sudo" ];
  hydenix.hm.shell.zsh.configText = ''
    export PATH=$PATH:~/.npm-global/bin
    eval "$(zoxide init zsh)"
    function lf() {
      local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
      yazi "$@" --cwd-file="$tmp"
      if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
      fi
      rm -f -- "$tmp"
    }

    alias tar-zstd="tar -I 'zstd -T0' -cvf"
    alias untar-zstd="tar -I 'zstd -T0' -vxf"
    alias encrypt="age -e -p"
    alias decrypt="age -d"

    # ==========================================================================
    # 1. 历史记录管理 (History Settings)
    # ==========================================================================

    # 立即将命令追加到历史文件中，而不是等 shell 退出
    setopt INC_APPEND_HISTORY
    # 多终端实时共享历史记录
    setopt SHARE_HISTORY
    # 记录命令的开始时间戳和执行时长 (强烈建议开启)
    setopt EXTENDED_HISTORY
    # 如果新命令与历史记录中的上一条重复，则不记录
    setopt HIST_IGNORE_DUPS
    # 彻底去重：如果新命令已存在，则删除旧记录，将新记录移至末尾
    setopt HIST_IGNORE_ALL_DUPS
    # 在命令前加空格，该命令不会被存入历史（用于输入密码等敏感操作）
    setopt HIST_IGNORE_SPACE
    # 自动删除历史命令中多余的空格
    setopt HIST_REDUCE_BLANKS
    # 使用文件锁防止多终端同时写入历史文件时发生损坏
    setopt HIST_FCNTL_LOCK 2>/dev/null

    # 历史记录容量设置
    export HISTSIZE=50000
    export SAVEHIST=50000
    # 在 NixOS 中，家目录通常由变量控制，这样写最稳妥
    export HISTFILE="$HOME/.config/zsh/.zsh_history"

    # ==========================================================================
    # 2. 目录导航与路径 (Navigation & Directory Stack)
    # ==========================================================================

    # 自动将 cd 过的目录压入堆栈，可以使用 'cd -' 查看并跳转
    setopt AUTO_PUSHD
    # 堆栈中不记录重复的路径
    setopt PUSHD_IGNORE_DUPS
    # 如果输入一个路径但没敲 cd，只要该路径存在，就自动跳转进去
    setopt AUTO_CD

    # ==========================================================================
    # 3. 智能辅助 (Smart Extras)
    # ==========================================================================

    # 自动纠正命令的拼写错误 (例如敲了 'sl' 会提示是否运行 'ls')
    setopt CORRECT
    # 完成补全后，自动去掉末尾多余的斜杠
    setopt AUTO_REMOVE_SLASH

    # ==========================================================================
    # 4. 环境变量 (Environment Variables)
    # ==========================================================================


  '';
}
