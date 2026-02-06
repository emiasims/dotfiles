# Variables
GIT := git@github.com:milisims
SSH := $(HOME)/.ssh
CFG := $(HOME)/.config
SRC := $(HOME)/.local/src
BIN := $(HOME)/.local/bin
SHARE := $(HOME)/.local/share
UV := $(BIN)/uv
VENV := $(SHARE)/venv
DOTCFG := $(HOME)/.cfg
LOCAL := $(BIN)/update-nvim  # sentinel for checked out right

# Whee pretty
SHELL := /bin/bash
CRED=\033[0;31m
CGRN=\033[0;32m
CYLW=\033[0;33m
CGREY=\033[1;30m
CEND=\033[0m\n

# Targets
all: dot uv nvim

dot: | $(LOCAL) $(SSH)
config: | $(LOCAL) $(SHARE)/fonts/SymbolsNerdFontMono-Regular.ttf
uv: | $(UV) $(VENV)/base
nvim: | $(BIN)/nvim $(SRC)/nvim-runtime $(SHARE)/nvim/venv vimfiles
vimfiles: | $(CFG)/nvim $(SHARE)/nvim/lazy

.PHONY: all dot config uv nvim vimfiles

# Rules
$(SSH): | $(SSH)/id_rsa.pub
  # todo?

$(SSH)/id_rsa.pub:
	@echo -e "$(CYLW)"
	ssh-keygen -t rsa -q -N "" -f $(HOME)/.ssh/id_rsa

$(DOTCFG):
	@echo -e "$(CYLW)> Cloning config$(CGREY)"
	git clone --bare $(GIT)/dotfiles.git $(DOTCFG)
	git config --global alias.cfg '!git -C $HOME --git-dir=$$HOME/.cfg'
	@echo -e "$(CGRN)== Cloned config$(CEND)"

$(LOCAL): | $(DOTCFG)
	@echo -e "$(CYLW)> Installing dotfiles$(CGREY)"
	git cfg sparse-checkout set --cone .config .local
	git cfg config status.showUntrackedFiles no
	git cfg config core.worktree $HOME
	@git cfg reset -q HEAD
	@git cfg restore .
	fish -c 'set_my_colors'
	git cfg status
	@echo -e "$(CGRN)== Installed dotfiles$(CEND)"

$(SHARE)/fonts/SymbolsNerdFontMono-Regular.ttf:
	@echo -e "$(CYLW)> Installing font symbols$(CGREY)"
	mkdir -p $(SHARE)/fonts
	wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.tar.xz -O $(SHARE)/fonts/NerdFontsSymbolsOnly.tar.xz
	tar -C $(SHARE)/fonts -xvJf $(SHARE)/fonts/NerdFontsSymbolsOnly.tar.xz --wildcards '*.ttf'
	rm $(SHARE)/fonts/NerdFontsSymbolsOnly.tar.xz
	@echo -e "$(CGRN)== Installed font symbols$(CEND)"

$(UV):
	@echo -e "$(CYLW)> Installing uv$(CGREY)"
	curl -LsSf https://astral.sh/uv/install.sh | sh
	$(UV) python install --color never
	@echo -en "$(CGREY)"  # color doesn't work right for python install
	mkdir -p $(VENV)
	@echo -e "$(CGRN)== Installed uv$(CEND)"

$(BIN)/nvim: | $(SRC)/nvim-runtime
	@echo -e "$(CYLW)"
	ln -s $(SRC)/nvim-runtime/bin/AppRun $@

$(CFG)/nvim: | $(DOTGIT)
	@echo -e "$(CYLW)> Cloning vimfiles$(CGREY)"
	git clone $(GIT)/vimfiles.git $@
	@echo -e "$(CGRN)== Cloned vimfiles$(CEND)"

$(SRC)/nvim-runtime: | $(DOTGIT) $(LOCAL)
	@echo -e "$(CYLW)> Installing neovim$(CGREY)"
	$(BIN)/update-nvim
	@echo -e "$(CGRN)== Installed nvim$(CEND)"

$(SHARE)/nvim/lazy: | $(BIN)/nvim $(CFG)/nvim
	@echo -e "$(CYLW)> Installing nvim plugins$(CGREY)"
	$(BIN)/nvim --headless '+Lazy! sync' +qa
	@echo -e "$(CGRN)== Installed nvim plugins$(CEND)"

$(HOME)/.vim: | $(CFG)/nvim
	@echo -e "$(CYLW)"
	ln -s $(CFG)/nvim $@

$(SHARE)/nvim/venv: | $(UV)
	@echo -e "$(CYLW)> Setting up nvim-base venv$(CGREY)"
	$(UV) venv $@ --seed --color never
	$@/bin/pip install pynvim
	@echo -e "$(CGRN)== Set up nvim-base venv$(CEND)"

$(VENV)/base: | $(UV)
	@echo -e "$(CYLW)> Setting up base venv$(CGREY)"
	$(UV) venv $@ --seed --color never
	$@/bin/pip install ipython pipx
	@echo -e "$(CGRN)== Set up base venv$(CEND)"

.PHONY: hide
hide:
	git cfg sparse-checkout set --cone .config .local

# Cleaning
clean-install:
	@echo -en "$(CRED)"
	rm -f $(HOME)/makefile

# not install
clean-all: clean-cfg clean-uv clean-vimfiles clean-fonts

clean-cfg:
	@echo -en "$(CRED)"
	git cfg stash -q
	git cfg sparse-checkout set --no-cone
	echo '!*' > $(DOTCFG)/info/sparse-checkout
	git cfg sparse-checkout reapply

clean-uv:
	@echo -en "$(CRED)"
	rm -f $(BIN)/uv
	rm -f $(BIN)/uvx
	rm -rf $(SHARE)/uv
	rm -rf $(VENV)
	# rm -rf $(SHARE)/nvim/venv

clean-vimfiles:
	@echo -en "$(CRED)"
	rm -rf $(CFG)/nvim $(SHARE)/nvim

clean-fonts:
	@echo -en "$(CRED)"
	rm -f $(SHARE)/fonts/SymbolsNerdFont-Regular.ttf
	rm -f $(SHARE)/fonts/SymbolsNerdFontMono-Regular.ttf

.PHONY: clean-install clean-all clean-cfg clean-uv clean-vimfiles clean-fonts
