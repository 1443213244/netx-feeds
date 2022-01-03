#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=live
PKG_VERSION:=0.1
PKG_RELEASE:=20220102

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=live.
	URL:=http://www.esong.com/
endef

define Package/$(PKG_NAME)/description
live.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/live.lua $(1)/usr/bin/live
	
	$(INSTALL_DIR) $(1)/etc/live
	$(INSTALL_CONF) ./files/lastserver.json $(1)/etc/live/lastserver.json
	$(INSTALL_CONF) ./files/server.json $(1)/etc/live/server.json
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/live.init $(1)/etc/init.d/live
	
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_BIN) ./files/live.config $(1)/etc/config/live
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
