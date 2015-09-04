SOURCES=git-radar radar-base.sh prompt.zsh prompt.bash fetch.sh
PREFIX=$(HOME)/.local

all:
	@echo 'Simple Install script for *git-radar* '
	@echo 'For a normal installation for your user only use:'
	@echo '    make install'
	@echo ''
	@echo 'If you want to install *git-radar* system wide you should change'
	@echo 'the prefix'
	@echo ''
	@echo '    PREFIX=/usr/local/bin make install'
	@echo ''
	@echo 'For a development install (symlinking files) do:'
	@echo ''
	@echo '	make develop'

.PHONY: install develop

install: $(SOURCES)
	@echo 'Installing in ' $(PREFIX)/bin
	cp git-radar $(PREFIX)/bin
	cp radar-base.sh $(PREFIX)/bin
	cp prompt.zsh $(PREFIX)/bin
	cp prompt.bash $(PREFIX)/bin
	cp fetch.sh $(PREFIX)/bin


develop: $(SOURCES)
	@echo 'Symlinking in ' $(PREFIX)/bin
	ln -s $(PWD)/git-radar $(PREFIX)/bin/git-radar
	ln -s $(PWD)/radar-base.sh $(PREFIX)/bin/radar-base.sh
	ln -s $(PWD)/prompt.zsh $(PREFIX)/bin/prompt.zsh
	ln -s $(PWD)/prompt.bash $(PREFIX)/bin/prompt.bash
	ln -s $(PWD)/fetch.sh $(PREFIX)/bin/fetch.sh
