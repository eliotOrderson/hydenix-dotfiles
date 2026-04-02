{

  programs.git = {
    enable = true;
    userName = "eliot";
    userEmail = "eliotorderson@gmail.com";

    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
    };

    extraConfig = {
      pull.rebase = false;
      init.defaultBranch = "main";
    };
  };
}
