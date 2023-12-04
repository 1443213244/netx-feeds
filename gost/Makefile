# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=gost
PKG_VERSION:=3.0.0-rc6
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/go-gost/gost/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=ad3a6257dacd48d4bc8df7489967c980d686ecad6ce9dc4d00f7849a00ad4a38

PKG_LICENSE:=MIT
PKG_LICENSE_FILE:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/go-gost/gost
GO_PKG_BUILD_PKG:=github.com/go-gost/gost/cmd/gost

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/gost
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GO Simple Tunnel
  URL:=https://github.com/go-gost/gost
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/gost/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gost $(1)/usr/bin/sooo
	$(INSTALL_DIR) $(1)/usr/share/sooo
	$(INSTALL_BIN) $(CURDIR)/files/cn.zone $(1)/usr/share/sooo/cn.zone
	$(INSTALL_BIN) $(CURDIR)/files/gfwlist.conf $(1)/usr/share/sooo/gfwlist.conf

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/sooo.config $(1)/etc/config/sooo
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/sooo.init $(1)/etc/init.d/sooo
endef

$(eval $(call GoBinPackage,gost))
$(eval $(call BuildPackage,gost))
