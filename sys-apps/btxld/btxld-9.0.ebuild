# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

DESCRIPTION="Support library for standalone executables from FreeBSD"
HOMEPAGE="http://www.freebsd.org/"
SRC_URI="mirror://gentoo/freebsd-usbin-${PV}.tar.bz2
			mirror://gentoo/freebsd-sys-${PV}.tar.bz2"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-libs/libbsd
	=sys-freebsd/freebsd-mk-defs-${PV}*
	virtual/pmake"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_prepare() {
	epatch "${FILESDIR}/${P}-endian.patch"
	sed -i 's/a_midmag/a_info/g' "${S}/sys/sys/imgact_aout.h"
	sed -i 's/#include <sys\/elf_common.h>/&\n#include <stdint.h>/' "${S}/sys/sys/elf32.h"

	mkdir -p "${T}/include/machine"
	mkdir -p "${T}/include/sys"

	cd "${T}/include/sys"
	ln -s "${S}/sys/sys/elf32.h"
	ln -s "${S}/sys/sys/elf_common.h"

	cd "${T}/include/machine"
	ln -s "${S}/sys/i386/include/exec.h"
}

src_compile() {

	cd "${S}/usr.sbin/btxld"
	env MAKESYSPATH=/usr/share/mk/freebsd __MAKE_CONF= CFLAGS="-imacros ${S}/sys/sys/imgact_aout.h -I ${T}/include -O2 -pipe -DMID_I386=134" pmake || die "Build failure"

}

src_install() {

	cd "${WORKDIR}/usr.sbin/btxld"

	dodir /usr/sbin
	dodir /usr/share/man/man8

	install -s -m 555   btxld "${ED}usr/sbin"
	install -m 444 btxld.8.gz  "${ED}usr/share/man/man8"

}
