# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=gost
PKG_VERSION:=2.11.4
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ginuerzh/gost/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=aa3211282fce695584795fac20da77a2ac68d3e08602118afb0747bd64c1eac4

PKG_LICENSE:=MIT
PKG_LICENSE_FILE:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/ginuerzh/gost
GO_PKG_BUILD_PKG:=github.com/ginuerzh/gost/cmd/gost

# 修改适应 asuswrt-merlin.386.7.2，执行路径为 /opt/bin
# 更多 golang package 用变量参考:
#  https://github.com/openwrt/packages/blob/master/lang/golang/golang-package.mk
GO_PKG_INSTALL_BIN_PATH:=/bin

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/gost
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GO Simple Tunnel
  URL:=https://github.com/ginuerzh/gost
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
