#!/usr/bin/env zsh
# Print the real p10k prompt for a few throwaway repos and command outcomes.

set -e
tmp=$(mktemp -d)
trap 'rm -rf $tmp' EXIT

repo() {
  git init -q -b master $tmp/$1
  git -C $tmp/$1 -c user.name=p -c user.email=p@p commit -q --allow-empty -m init
}

repo clean

repo modified
touch $tmp/modified/new
echo x > $tmp/modified/staged && git -C $tmp/modified add staged

repo conflicted
git -C $tmp/conflicted switch -q -c other
echo a > $tmp/conflicted/f && git -C $tmp/conflicted add f && git -C $tmp/conflicted -c user.name=p -c user.email=p@p commit -q -m a
git -C $tmp/conflicted switch -q master
echo b > $tmp/conflicted/f && git -C $tmp/conflicted add f && git -C $tmp/conflicted -c user.name=p -c user.email=p@p commit -q -m b
git -C $tmp/conflicted merge -q other >/dev/null 2>&1 || true

repo mise
for tool in python node go; do
  version=$(mise current $tool 2>/dev/null) && [[ -n $version ]] && print "$tool = \"${version%% *}\"" >> $tmp/mise/tools
done
print '[tools]' | cat - $tmp/mise/tools > $tmp/mise/mise.toml && rm $tmp/mise/tools

# name  dir  exit-status  duration-seconds
scenarios=(
  'clean repo'                  clean      0 0
  'staged + untracked, slow'    modified   0 12
  'merge conflict, failed'      conflicted 1 0
  'mise project'                mise       0 0
)

for name dir code secs in $scenarios; do
  print -P "%B$name%b"
  # Fake a finished command so p10k shows its status and duration, then print the prompt it built.
  COLUMNS=${COLUMNS:-120} MISE_TRUSTED_CONFIG_PATHS=$tmp P10K_DIR=$tmp/$dir P10K_CODE=$code P10K_SECS=$secs \
    zsh -ic '
      cd $P10K_DIR
      typeset -g _p9k__line_finished=
      _p9k_preexec2 "" "cmd"
      _p9k__timer_start=$((EPOCHREALTIME - P10K_SECS))
      (exit $P10K_CODE)
      _p9k_precmd
      print -rP -- "$PROMPT"
    ' 2>/dev/null
  print
done
