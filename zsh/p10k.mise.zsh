# Powerlevel10k prompt segments for mise
# Adapted from https://github.com/romkatv/powerlevel10k/issues/2212

() {
  function prompt_mise() {
    local plugins=("${(@f)$(mise ls --current --local 2>/dev/null | awk '{print $1, $2}')}")
    local plugin
    for plugin in ${(k)plugins}; do
      local parts=("${(@s/ /)plugin}")
      local tool=${(U)parts[1]}
      local version=${parts[2]}
      p10k segment -r -i "${tool}_ICON" -s $tool -t "$version"
    done
  }

  # Colors (default)
  typeset -g POWERLEVEL9K_MISE_FOREGROUND=0
  typeset -g POWERLEVEL9K_MISE_BACKGROUND=7

  # Ruby version from mise.
  typeset -g POWERLEVEL9K_MISE_RUBY_FOREGROUND=0
  typeset -g POWERLEVEL9K_MISE_RUBY_BACKGROUND=1
  # typeset -g POWERLEVEL9K_MISE_RUBY_VISUAL_IDENTIFIER_EXPANSION='⭐'

  # Python version from mise.
  typeset -g POWERLEVEL9K_MISE_PYTHON_FOREGROUND=0
  typeset -g POWERLEVEL9K_MISE_PYTHON_BACKGROUND=4
  # typeset -g POWERLEVEL9K_MISE_PYTHON_VISUAL_IDENTIFIER_EXPANSION='⭐'

  # Go version from mise.
  typeset -g POWERLEVEL9K_MISE_GO_FOREGROUND=0
  typeset -g POWERLEVEL9K_MISE_GO_BACKGROUND=4
  # typeset -g POWERLEVEL9K_MISE_GOLANG_VISUAL_IDENTIFIER_EXPANSION='⭐'

  # Node.js version from mise.
  typeset -g POWERLEVEL9K_MISE_NODE_FOREGROUND=0
  typeset -g POWERLEVEL9K_MISE_NODE_BACKGROUND=2
  # typeset -g POWERLEVEL9K_MISE_NODEJS_VISUAL_IDENTIFIER_EXPANSION='⭐'

  # Rust version from mise.
  typeset -g POWERLEVEL9K_MISE_RUST_FOREGROUND=0
  typeset -g POWERLEVEL9K_MISE_RUST_BACKGROUND=208
  # typeset -g POWERLEVEL9K_MISE_RUST_VISUAL_IDENTIFIER_EXPANSION='⭐'

  # .NET Core version from mise.
  typeset -g POWERLEVEL9K_MISE_DOTNET_FOREGROUND=0
  typeset -g POWERLEVEL9K_MISE_DOTNET_BACKGROUND=5
  # typeset -g POWERLEVEL9K_MISE_DOTNET_CORE_VISUAL_IDENTIFIER_EXPANSION='⭐'

  # Lua version from mise.
  typeset -g POWERLEVEL9K_MISE_LUA_FOREGROUND=0
  typeset -g POWERLEVEL9K_MISE_LUA_BACKGROUND=4
  # typeset -g POWERLEVEL9K_MISE_LUA_VISUAL_IDENTIFIER_EXPANSION='⭐'

  # Java version from mise.
  typeset -g POWERLEVEL9K_MISE_JAVA_FOREGROUND=1
  typeset -g POWERLEVEL9K_MISE_JAVA_BACKGROUND=7
  # typeset -g POWERLEVEL9K_MISE_JAVA_VISUAL_IDENTIFIER_EXPANSION='⭐'

  # Elixir version from mise.
  typeset -g POWERLEVEL9K_MISE_ELIXIR_FOREGROUND=0
  typeset -g POWERLEVEL9K_MISE_ELIXIR_BACKGROUND=5
  # typeset -g POWERLEVEL9K_MISE_ELIXIR_VISUAL_IDENTIFIER_EXPANSION='⭐'
}
