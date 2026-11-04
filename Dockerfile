FROM alpine:latest

LABEL org.opencontainers.image.source=https://github.com/guille/dotfiles

WORKDIR /root

RUN apk add --no-cache \
	musl-locales \
	zsh zsh-autosuggestions zsh-syntax-highlighting zsh-completions \
	git delta neovim bat eza fd fzf htop nnn ripgrep zoxide \
	jq yq curl ncurses \
	mise \
	helm kubectl kubectx

# Mise setup
RUN mise settings set experimental true && \
	mise use -g usage github:romkatv/gitstatus@1.5.4 forgejo:mergiraf/mergiraf@latest

RUN echo "export GITSTATUS_CACHE_DIR=$(mise bin-paths github:romkatv/gitstatus)" >> ~/.zshenv.local


COPY ripgrep/ripgreprc .config/ripgrep/ripgreprc

COPY fd/fdignore .config/fd/ignore

COPY bat/custom.tmTheme .config/bat/themes/custom.tmTheme
COPY bat/config .config/bat/config
RUN bat cache --build

COPY git/gitconfig .gitconfig
COPY git/gitconfig-delta.gitconfig .gitconfig-delta
COPY git/gitmessage .gitmessage
# No SSH keys or display in the image: plain https and $EDITOR
RUN git config --global commit.gpgSign false && \
	git config --global tag.gpgSign false && \
	git config --global --unset core.editor && \
	git config --global --unset sequence.editor && \
	git config --global --remove-section 'url.git@github.com:' && \
	mkdir -p .config/git && echo '* merge=mergiraf' > .config/git/attributes

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

RUN echo "export DOTFILES_OS=Linux" >> ~/.zvars && \
	echo "export DOTFILES_DISTRO=Alpine" >> ~/.zvars

# not everything recognises ghostty
RUN echo "export TERM=xterm-256color" >> ~/.zshenv.local && \
	echo "export EDITOR=nvim" >> ~/.zshenv.local

ENTRYPOINT ["/bin/zsh"]
