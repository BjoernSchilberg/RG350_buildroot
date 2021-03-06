################################################################################
#
# rhash
#
################################################################################

RHASH_VERSION = 1.3.5
RHASH_SOURCE = rhash-$(RHASH_VERSION)-src.tar.gz
RHASH_SITE = https://sourceforge.net/projects/rhash/files/rhash/$(RHASH_VERSION)
RHASH_LICENSE = MIT
RHASH_LICENSE_FILES = COPYING
RHASH_INSTALL_STAGING = YES
RHASH_DEPENDENCIES = $(TARGET_NLS_DEPENDENCIES)
RHASH_ADDLDFLAGS = $(TARGET_NLS_LIBS)
RHASH_ADDCFLAGS = $(if $(BR2_SYSTEM_ENABLE_NLS),-DUSE_GETTEXT)

ifeq ($(BR2_PACKAGE_OPENSSL)x$(BR2_PREFER_STATIC_LIB),yx)
RHASH_DEPENDENCIES += openssl
RHASH_ADDCFLAGS += -DOPENSSL_RUNTIME -rdynamic
RHASH_ADDLDFLAGS += -ldl
endif

RHASH_MAKE_OPT = \
	ADDCFLAGS="$(RHASH_ADDCFLAGS)" \
	ADDLDFLAGS="$(RHASH_ADDLDFLAGS)" \
	PREFIX="/usr"

ifeq ($(BR2_PREFER_STATIC_LIB),y)
RHASH_BUILD_TARGETS = lib-static
RHASH_INSTALL_TARGETS = install-lib-static
else
RHASH_BUILD_TARGETS = lib-static lib-shared build-shared
RHASH_INSTALL_TARGETS = install-lib-static install-lib-shared uninstall-so-link install-so-link
endif

define RHASH_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) \
		$(RHASH_MAKE_OPT) $(RHASH_BUILD_TARGETS)
endef

define RHASH_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)/librhash \
		DESTDIR="$(STAGING_DIR)" $(RHASH_MAKE_OPT) $(RHASH_INSTALL_TARGETS) \
		install-headers
endef

ifeq ($(BR2_PACKAGE_RHASH_BIN),y)
define RHASH_INSTALL_TARGET_RHASH_BIN
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) \
		DESTDIR="$(TARGET_DIR)" $(RHASH_MAKE_OPT) install-shared
endef
define RHASH_INSTALL_HOST_RHASH_BIN
	$(HOST_MAKE_ENV) $(HOST_CONFIGURE_OPTS) $(MAKE) -C $(@D) \
		DESTDIR="$(HOST_DIR)" $(RHASH_MAKE_OPT) install-shared
endef
endif

define RHASH_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)/librhash \
		DESTDIR="$(TARGET_DIR)" $(RHASH_MAKE_OPT) $(RHASH_INSTALL_TARGETS)
	$(RHASH_INSTALL_TARGET_RHASH_BIN)
endef

define HOST_RHASH_BUILD_CMDS
	$(HOST_MAKE_ENV) $(HOST_CONFIGURE_OPTS) $(MAKE) -C $(@D) \
		$(RHASH_MAKE_OPT) $(RHASH_BUILD_TARGETS)
endef

define HOST_RHASH_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(HOST_CONFIGURE_OPTS) $(MAKE) -C $(@D)/librhash \
		DESTDIR="$(HOST_DIR)" $(RHASH_MAKE_OPT) $(RHASH_INSTALL_TARGETS)
	$(RHASH_INSTALL_HOST_RHASH_BIN)
endef

$(eval $(generic-package))
$(eval $(host-generic-package))
