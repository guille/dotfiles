FROM alpine:latest

WORKDIR /root

RUN echo "export DOTFILES_OS=Linux" >> ~/.zvars && \
	echo "export DOTFILES_DISTRO=Alpine" >> ~/.zvars

# xterm-256color ?
RUN echo "export TERMINAL=ghostty" >> ~/.zshenv.local && \
	echo "export EDITOR=nvim" >> ~/.zshenv.local

RUN apk add --no-cache \
	musl-locales \
	zsh zsh-autosuggestions zsh-syntax-highlighting zsh-completions \
	git delta neovim bat eza fd fzf htop nnn ripgrep \
	jq yq curl \
	mise \
	helm kubectl kubectx

# Mise setup
RUN mise settings set experimental true && \
	mise use -g usage github:romkatv/gitstatus@1.5.4

RUN echo "export GITSTATUS_CACHE_DIR=$(mise bin-paths github:romkatv/gitstatus)" >> ~/.zshenv.local


# TODO: Get around creating so many layers

COPY ripgrep/ripgreprc .config/ripgrep/ripgreprc

COPY fd/fdignore .config/fd/ignore

COPY bat/custom.tmTheme .config/bat/themes/custom.tmTheme
COPY bat/config .config/bat/config
RUN bat cache --build

COPY zsh/zshrc.zsh .zshrc
COPY zsh/zshenv.zsh .zshenv
COPY zsh/zkeys.zsh .zkeys
COPY zsh/zaliases.zsh .zaliases
COPY zsh/p10k.zsh .p10k.zsh
COPY zsh/p10k.mise.zsh .p10k.mise.zsh
COPY zsh/zsh-history-substring-search.zsh .zhist_substr
COPY zsh/powerlevel10k .powerlevel10k
COPY zsh/fzf-tab .fzf-tab

COPY nvim/ .config/nvim/lua
# Ugh
RUN mv .config/nvim/lua/init.lua .config/nvim/init.lua

ENTRYPOINT ["/bin/zsh"]
