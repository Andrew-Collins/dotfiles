fish_vi_key_bindings
set -gx GTK_THEME Adwaita:dark
set -gx GDK_BACKEND wayland
set -gx EDITOR lvim
set -gx _JAVA_AWT_WM_NONREPARENTING 1
function ki
  GDK_BACKEND=x11 kicad $argv & disown
end

function kid 
  GDK_BACKEND=x11 kicad $argv *.kicad_pro & disown
end

function form_fd 
  echo fd $fd_opts -t$type_opt $loc_opt 
end

function fzf_menu 
  argparse 'h/help' 'f/file' 'd/dir' 'x/exe' -- $argv
  or return
  set fzf_args --multi --ansi --preview-window=:hidden \
      --bind '?:toggle-preview' \
      --bind 'ctrl-j:jump' \
      --bind 'ctrl-y:execute-silent(echo {} | wl-copy)' \
      --bind 'ctrl-e:execute(lvim {} &> /dev/tty)' \
      --bind 'ctrl-z:execute-silent(7z x -y {})+abort' \
      --bind 'ctrl-h:reload(begin; set loc_opt -a --base-directory $HOME; eval (form_fd); end)' \
      --bind 'ctrl-r:reload(begin; set loc_opt ; eval (form_fd); end)' \
      --bind 'ctrl-d:reload(begin; set type_opt d; eval (form_fd); end)' \
      --bind 'ctrl-f:reload(begin; set type_opt f; eval (form_fd); end)' 
      # --bind 'ctrl-o:execute(xdg-open {} & disown)' \
  set -U fd_opts --color=always --strip-cwd-prefix --hidden --exclude=.git
  set -U type_opt f
  set -U loc_opt 

  set src_comm (form_fd)
  if set -q _flag_help 
    echo "help"
    return 0
  else if set -q _flag_exe 
    set src_comm complete -C \'\' \| awk '{print \$1}'
    set -p fzf_args --print-query
  else if set -q _flag_dir
    set type_opt d
    set src_comm (form_fd)
  end
  
  eval $src_comm | fzf $fzf_args
end

if status is-interactive
    fzf_configure_bindings --directory=\cf
    set fzf_dir_opts --preview-window=:hidden \
      --bind '?:toggle-preview' \
      --bind 'ctrl-j:jump' \
      --bind 'ctrl-y:execute-silent(echo {} | wl-copy)' \
      --bind 'ctrl-o:execute(xdg-open {} &)' \
      --bind 'ctrl-e:execute(lvim {} &> /dev/tty)' \
      --bind 'ctrl-x:execute-silent(7z x -y {})+abort' \
      --bind 'ctrl-h:reload(begin; set -U fzf_fd_opts[4] -a; set -U fzf_fd_opts[6] $HOME; set fd_opts --color=always --strip-cwd-prefix $fzf_fd_opts; fd $fd_opts; end)' \
      --bind 'ctrl-r:reload(begin; set -U fzf_fd_opts[4] -i; set -U fzf_fd_opts[6] .; set fd_opts --color=always --strip-cwd-prefix $fzf_fd_opts; fd $fd_opts; end)' \
      --bind 'ctrl-d:reload(begin; set -U fzf_fd_opts[1] -td; set fd_opts --color=always --strip-cwd-prefix $fzf_fd_opts; fd $fd_opts; end)' \
      --bind 'ctrl-f:reload(begin; set -U fzf_fd_opts[1] -tf; set fd_opts --color=always --strip-cwd-prefix $fzf_fd_opts; fd $fd_opts; end)' 
    set fzf_fd_opts -tf --hidden --exclude=.git -i --base-directory .
    set FZF_DEFAULT_COMMAND fd
end
