#
# Copyright (c) 2019 Rinvay <hrinvay@gmail.com>
#
# This is free software, licensed under the MIT.
# See /LICENSE for more information.
#


include $(TOPDIR)/rules.mk

PKG_NAME:=luci-netx-wireguard
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI for wireguard and udpspeeder
	PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
	LuCI for wireguard and udpspeeder.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DATA) ./src/usr/bin/wireguard $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/share/wireguard
	$(INSTALL_DATA) ./src/usr/share/wireguard/dnsmasq_gfwlist_ipset.conf $(1)/usr/share/wireguard/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./src/etc/hotplug.d/iface/30-wireguard $(1)/etc/hotplug.d/iface/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) ./src/luci/i18n/wireguard.zh-cn.lmo $(1)/usr/lib/lua/luci/i18n/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./src/luci/controller/*.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./src/luci/model/cbi/*.lua $(1)/usr/lib/lua/luci/model/cbi/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
	$(INSTALL_DATA) ./src/luci/view/*.htm $(1)/usr/lib/lua/luci/view/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./src/etc/config/wireguard $(1)/etc/config/wireguard
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./src/etc/init.d/wireguard $(1)/etc/init.d/wireguard
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
