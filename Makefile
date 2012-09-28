NAME    := minecraft-server
VERSION := 1.3.2
ARCH    := noarch
OS      := el6

ITERATION    := 1
DESCRIPTION  := [pschultz] Minecraft is a game about placing blocks to build anything you can imagine. At night monsters come out, make sure to build a shelter before that happens.
MAINTAINER   := Peter Schultz <schultz.peter@hotmail.com>

INSTALL_ROOT := inst_root
JARBALL      := minecraft_server.jar
SOURCE_URL   := https://s3.amazonaws.com/MinecraftDownload/launcher/$(JARBALL)
PACKAGE      := $(NAME)-$(VERSION)-$(ITERATION).$(OS).$(ARCH).rpm

INST_PREFIX  := opt/minecraft
INIT_SCRIPT  := etc/init.d/$(NAME)
SYSCONFIG    := etc/sysconfig/$(NAME)

INIT_SCRIPT_SRC := https://github.com/pschultz/minecraft-server.init/raw/master/init.d/minecraft-server
SYSCONFIG_SRC   := https://github.com/pschultz/minecraft-server.init/raw/master/sysconfig/minecraft-server

.PHONY: all clean distclean
.NOTPARALLEL:

all: $(PACKAGE)

$(PACKAGE): $(INSTALL_ROOT)/$(INST_PREFIX)/$(JARBALL) $(INSTALL_ROOT)/$(INIT_SCRIPT) $(INSTALL_ROOT)/$(SYSCONFIG)
	fpm -s dir -t rpm -a all -n $(NAME) -p $(PACKAGE) -v $(VERSION) -C "$(INSTALL_ROOT)" \
		--iteration $(ITERATION) \
		--description '$(DESCRIPTION)' \
		--maintainer "$(MAINTAINER)" \
		--exclude '.git*' \
		--exclude '*/.git*' \
		-d jre -d mcwrapper \
		opt etc

$(INSTALL_ROOT)/$(INST_PREFIX)/$(JARBALL): $(JARBALL) $(INSTALL_ROOT)/$(INST_PREFIX)
	cp "$<" "$@"

$(INSTALL_ROOT)/$(INST_PREFIX):
	mkdir -p "$@"

$(INSTALL_ROOT)/$(INIT_SCRIPT):
	wget $(INIT_SCRIPT_SRC) -O "$@"
	chmod +x "$@"

$(INSTALL_ROOT)/$(SYSCONFIG):
	wget $(SYSCONFIG_SRC) -O "$@"

$(JARBALL):
	wget '$(SOURCE_URL)' -O $(JARBALL)

clean: 
	rm -f $(PACKAGE)

distclean: clean
	rm -rf $(JARBALL) $(INSTALL_ROOT)/$(INST_PREFIX)
