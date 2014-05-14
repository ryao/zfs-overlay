# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-kernel/vanilla-sources/vanilla-sources-3.3.1.ebuild,v 1.1 2012/04/03 16:04:23 mpagano Exp $

EAPI="5"
SLOT="6/${PV}"
inherit rpm versionator

RV="$(replace_version_separator 3 '-' $PV).el6"

DESCRIPTION="Full sources for the RHEL6 kernel"
HOMEPAGE="http://www.redhat.com/"
SRC_URI="ftp://ftp.redhat.com/pub/redhat/linux/enterprise/6Server/en/os/SRPMS/kernel-${RV}.src.rpm"
SRC_URI="${SRC_URI} ftp://ftp.muug.mb.ca/mirror/centos/6.5/updates/x86_64/Packages/kernel-${RV}.x86_64.rpm"

KEYWORDS="~amd64"
IUSE="binary +config"
RESTRICT="strip test"
LICENSE="GPL-2"
MULTILIB_STRICT_DENY=true

DEPEND="${DEPEND}
	app-arch/cpio"

src_unpack () {
	cd "${T}"
	rpm_src_unpack "${DISTDIR}/kernel-${RV}.x86_64.src.rpm"
	rmdir "${WORKDIR}"
	ln -s "${T}/linux-${RV}" "${WORKDIR}"
}

src_prepare () {
	cd "${T}"
	sed -i \
		-e "s:^\(CONFIG_LOCALVERSION=\"\)\(.*\)\":\1-${RV#*-}.x86_64\":g" \
		"./boot/config-$RV.x86_64"
	cd "${WORKDIR}"
	epatch "${FILESDIR}/${PN}-pmcraid-duplicate-sense-buffer.patch"
	epatch "${FILESDIR}/${PN}-gcc-4.6.patch"
	epatch "${FILESDIR}/${PN}-fix-9p-virtio-rootfs-support.patch"
	epatch_user
}

src_configure() {
	:
}

src_compile() {
	#$(tc-getCC) -o scripts/bin2c scripts/bin2c.c
	#scripts/bin2c ksign_def_public_key __initdata >crypto/signature/key.h
	:
}

src_install () {
	cd "${T}"
	use binary && find {boot,lib} | cpio -dumpl "${D}"
	dodir /usr/src
	find "linux-$RV" | cpio -dumpl "${D}/usr/src" 2>/dev/null
	chmod 755 "${D}/usr/src/linux-$RV"
	use config && ln "./boot/config-$RV.x86_64" "${D}/usr/src/linux-$RV/.config"
	insinto "/usr/src/linux-$RV/crypto/signature"
	doins "${FILESDIR}/key.h"

	#if use config
	#then
	#	ewarn "The CentOS .config file has been installed. Unless you can"
	#	ewarn "generate crypto/signature/key.h, you will want to disable the"
	#	ewarn "following in menuconfig:"
	#	ewarn "CONFIG_CRYPTO_SIGNATURE"
	#	ewarn "CONFIG_CRYPTO_SIGNATURE_DSA"
	#	ewarn "CONFIG_CHECK_SIGNATURE"
	#	ewarn "Otherwise, your kernel will not compile. You have been warned."
	#fi
}
