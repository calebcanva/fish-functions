function __git-branches
  git branch &> /dev/null
  if test $status -eq 0
      git branch --format "%(refname:short)"
  end
end

complete -f -c cb -n "not __fish_seen_subcommand_from (__git-branches)" -a "(__git-branches)"