{

  hydenix.hm.git.enable = false;
  programs.git = {
    enable = true;
    userName = "eliot";
    userEmail = "eliotorderson@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

}
