# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/zfs/zfs-9999.ebuild,v 1.37 2012/08/22 07:51:18 ryao Exp $

EAPI="4"

AT_M4DIR="config"
AUTOTOOLS_AUTORECONF="1"
AUTOTOOLS_IN_SOURCE_BUILD="1"

inherit bash-completion-r1 flag-o-matic git-2 toolchain-funcs autotools-utils

DESCRIPTION="Userland utilities for ZFS Linux kernel module"
HOMEPAGE="http://zfsonlinux.org/"
SRC_URI=""
EGIT_REPO_URI="git://github.com/ryao/zfs.git"
EGIT_BRANCH="${EGIT_BRANCH:-gentoo}"

LICENSE="BSD-2 CDDL MIT"
SLOT="0"
IUSE="custom-cflags kernel-builtin +rootfs test-suite static-libs"
RESTRICT="test"

COMMON_DEPEND="
	sys-apps/util-linux[static-libs?]
	sys-libs/zlib[static-libs(+)?]
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"

RDEPEND="${COMMON_DEPEND}
	!kernel-builtin? ( =sys-fs/zfs-kmod-${PV}* )
	!sys-fs/zfs-fuse
	!prefix? ( virtual/udev )
	test-suite? (
		sys-apps/gawk
		sys-apps/util-linux
		sys-devel/bc
		sys-block/parted
		sys-fs/lsscsi
		sys-fs/mdadm
		sys-process/procps
		virtual/modutils
		)
	rootfs? (
		app-arch/cpio
		app-misc/pax-utils
		)
"

src_prepare() {
	# Workaround for hard coded path
	sed -i "s|/sbin/lsmod|/bin/lsmod|" scripts/common.sh.in || die
	# Workaround rename
	sed -i "s|/usr/bin/scsi-rescan|/usr/sbin/rescan-scsi-bus|" scripts/common.sh.in || die

	autotools-utils_src_prepare
}

src_configure() {
	use custom-cflags || strip-flags
	local myeconfargs=(
		--bindir="${EPREFIX}/bin"
		--sbindir="${EPREFIX}/sbin"
		--with-config=user
		--with-linux="${KV_DIR}"
		--with-linux-obj="${KV_OUT_DIR}"
		--with-udevdir="$($(tc-getPKG_CONFIG) --variable=udevdir udev)"
	)
	autotools-utils_src_configure
}

src_install() {
	autotools-utils_src_install
	gen_usr_ldscript -a uutil nvpair zpool zfs
	rm -rf "${ED}usr/share/dracut"
	use test-suite || rm -rf "${ED}usr/libexec"

	if use rootfs
	then
		doinitd "${FILESDIR}/zfs-shutdown"
		exeinto /usr/share/zfs
		doexe "${FILESDIR}/linuxrc"
	fi

	newbashcomp "${FILESDIR}/bash-completion" zfs

}

pkg_postinst() {

	[ -e "${EROOT}/etc/runlevels/boot/zfs" ] \
		|| ewarn 'You should add zfs to the boot runlevel.'

	use rootfs && ([ -e "${EROOT}/etc/runlevels/shutdown/zfs-shutdown" ] \
		|| ewarn 'You should add zfs-shutdown to the shutdown runlevel.')

	eerror "This ebuild is from the zfs-overlay, which is meant strictly for"
	eerror "development. Everyone who has not spoken directly to ryao should NOT use"
	eerror "it. If you have not spoken to ryao, please delete the overlay and"
	eerror "rebuild ${P} from the main tree."
}
