#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=manygost
PKG_VERSION:=0.1
PKG_RELEASE:=20220102

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=manygost.
	URL:=http://www.esong.com/
endef

define Package/$(PKG_NAME)/description
manygost.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/manygost.lua $(1)/usr/bin/manygost
	
	$(INSTALL_DIR) $(1)/etc/manygost
	$(INSTALL_CONF) ./files/lastserver.json $(1)/etc/manygost/lastserver.json
	$(INSTALL_CONF) ./files/server.json $(1)/etc/manygost/server.json
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/manygost.init $(1)/etc/init.d/manygost
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
