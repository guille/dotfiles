# Powerlevel10k prompt segments for mise
# Adapted from https://github.com/romkatv/powerlevel10k/issues/2212

() {
  function prompt_mise() {
    # Fast path: skip if no mise config files in parent dirs
    _p9k_upglob 'mise.toml|mise.local.toml' -.
    local -i upglob_result=$?
    (( upglob_result == 0 )) && return

    # Check cache for this directory
    if ! _p9k_cache_get "$0" "$_p9k__cwd_a"; then
      local -a plugins
      local line
      for line in ${(f)"$(mise ls --current --local 2>/dev/null)"}; do
        local parts=(${=line})
        [[ ${#parts} -ge 2 ]] && plugins+=("$parts[1] $parts[2]")
      done
      _p9k_cache_set "${plugins[@]}"
    fi

    # Use cached results directly
    [[ ${#_p9k__cache_val} -eq 0 ]] && return

    local plugin
    for plugin in $_p9k__cache_val; do
      local parts=(${(@s/ /)plugin})
      [[ ${#parts} -lt 2 ]] && continue
      local tool=${parts[1]}
      local version=${parts[2]}
      [[ -n $version ]] || continue
      # Extract just the tool name for the state:
      # 1. Get basename after last "/" (handles "github:user/tool" -> "tool")
      # 2. Replace ":" with "_" to create valid zsh identifiers
      # Do it in steps to avoid chained expansion that triggers "unrecognized modifier" error
      local tool_base="${tool:t}"
      local tool_clean="${tool_base//:/_}"
      local state="${(U)tool_clean}"
      p10k segment -r -i "${state}_ICON" -s $state -t "$version"
    done
  }

  # Colors (default)
  typeset -g POWERLEVEL9K_MISE_FOREGROUND=0
  typeset -g POWERLEVEL9K_MISE_BACKGROUND=7

  typeset -g POWERLEVEL9K_MISE_RUBY_FOREGROUND=0
  typeset -g POWERLEVEL9K_MISE_RUBY_BACKGROUND=1
  # typeset -g POWERLEVEL9K_MISE_RUBY_VISUAL_IDENTIFIER_EXPANSION='⭐'

  typeset -g POWERLEVEL9K_MISE_PYTHON_FOREGROUND=0
  typeset -g POWERLEVEL9K_MISE_PYTHON_BACKGROUND=4
  # typeset -g POWERLEVEL9K_MISE_PYTHON_VISUAL_IDENTIFIER_EXPANSION='⭐'

  typeset -g POWERLEVEL9K_MISE_GO_FOREGROUND=0
  typeset -g POWERLEVEL9K_MISE_GO_BACKGROUND=4
  # typeset -g POWERLEVEL9K_MISE_GOLANG_VISUAL_IDENTIFIER_EXPANSION='⭐'

  typeset -g POWERLEVEL9K_MISE_NODE_FOREGROUND=0
  typeset -g POWERLEVEL9K_MISE_NODE_BACKGROUND=2
  # typeset -g POWERLEVEL9K_MISE_NODEJS_VISUAL_IDENTIFIER_EXPANSION='⭐'

  typeset -g POWERLEVEL9K_MISE_RUST_FOREGROUND=0
  typeset -g POWERLEVEL9K_MISE_RUST_BACKGROUND=208
  # typeset -g POWERLEVEL9K_MISE_RUST_VISUAL_IDENTIFIER_EXPANSION='⭐'

  typeset -g POWERLEVEL9K_MISE_DOTNET_FOREGROUND=0
  typeset -g POWERLEVEL9K_MISE_DOTNET_BACKGROUND=5
  # typeset -g POWERLEVEL9K_MISE_DOTNET_CORE_VISUAL_IDENTIFIER_EXPANSION='⭐'

  typeset -g POWERLEVEL9K_MISE_LUA_FOREGROUND=0
  typeset -g POWERLEVEL9K_MISE_LUA_BACKGROUND=4
  # typeset -g POWERLEVEL9K_MISE_LUA_VISUAL_IDENTIFIER_EXPANSION='⭐'

  typeset -g POWERLEVEL9K_MISE_JAVA_FOREGROUND=1
  typeset -g POWERLEVEL9K_MISE_JAVA_BACKGROUND=7
  # typeset -g POWERLEVEL9K_MISE_JAVA_VISUAL_IDENTIFIER_EXPANSION='⭐'

  typeset -g POWERLEVEL9K_MISE_ELIXIR_FOREGROUND=0
  typeset -g POWERLEVEL9K_MISE_ELIXIR_BACKGROUND=5
  # typeset -g POWERLEVEL9K_MISE_ELIXIR_VISUAL_IDENTIFIER_EXPANSION='⭐'

  typeset -g POWERLEVEL9K_MISE_HUGO_EXTENDED_FOREGROUND=15
  typeset -g POWERLEVEL9K_MISE_HUGO_EXTENDED_BACKGROUND=198
  typeset -g POWERLEVEL9K_MISE_HUGO_EXTENDED_VISUAL_IDENTIFIER_EXPANSION=' '
}
