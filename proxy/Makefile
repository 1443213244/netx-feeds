# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.

include $(TOPDIR)/rules.mk

PKG_NAME:=proxy
PKG_VERSION:=0.1
PKG_RELEASE:=20220102

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=proxy.
	URL:=http://www.esong.com/
endef

define Package/$(PKG_NAME)/description
	proxy.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/proxy $(1)/usr/bin/proxy
	$(INSTALL_BIN) ./files/firewall.proxy $(1)/usr/bin/firewall.proxy
	$(INSTALL_BIN) ./files/proxy-config-script.sh $(1)/usr/bin/proxy-config-script
	$(INSTALL_BIN) ./files/proxy-test.sh $(1)/usr/bin/proxy-test
	
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/proxy.conf $(1)/etc/config/proxy
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/proxy.init $(1)/etc/init.d/proxy
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
