abbr -a c cargo
abbr -a cb cargo build
abbr -a ct cargo test
abbr -a e nvim
abbr -a g git
abbr -a gs git status
abbr -a gc 'git commit -m'
abbr -a ga 'git add -u'
abbr -a gco 'git checkout'
abbr -a gpu 'git pull upstream'

if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fish_prompt
  set_color green
  echo "$USER> "
end
