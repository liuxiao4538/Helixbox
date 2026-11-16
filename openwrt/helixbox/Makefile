# OpenWrt Makefile — luci-app-Helixbox
# 放回 package 目录后 make menuconfig 勾选即可；也可 ./build_ipk.sh 直接打 ipk
include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-Helixbox
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

LUCI_TITLE:=Helixbox Download Accelerator
LUCI_DEPENDS:=+lighttpd +lighttpd-mod-redirect +lighttpd-mod-proxy +curl +iputils-ping
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

$(eval $(call BuildPackage,$(PKG_NAME)))
