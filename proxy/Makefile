include $(TOPDIR)/rules.mk

PKG_NAME:=proxy
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/proxy
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Proxy Service
  PKG_MAINTAINER:=RexChou <rexchou2012@gmail.com>
endef

define Package/proxy/description
  A proxy service for OpenWrt
endef

define Build/Prepare
  mkdir -p $(PKG_BUILD_DIR)
  $(CP) ./files/* $(PKG_BUILD_DIR)/
endef

define Package/proxy/install
  $(INSTALL_DIR) $(1)/etc/init.d
  $(INSTALL_BIN) ./files/proxy.init $(1)/etc/init.d/proxy

  $(INSTALL_DIR) $(1)/etc/config
  $(INSTALL_CONF) ./files/proxy.conf $(1)/etc/config/proxy

  $(INSTALL_DIR) $(1)/usr/bin
  $(INSTALL_BIN) $(PKG_BUILD_DIR)/proxy $(1)/usr/bin/proxy
  $(INSTALL_BIN) $(PKG_BUILD_DIR)/firewall.proxy $(1)/bin/firewall.proxy
endef

$(eval $(call BuildPackage,proxy))
