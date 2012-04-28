# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="Support library for standalone executables from FreeBSD"
HOMEPAGE="http://www.freebsd.org/"
SRC_URI="mirror://gentoo/freebsd-contrib-${PV}.tar.bz2
			mirror://gentoo/freebsd-lib-${PV}.tar.bz2
			mirror://gentoo/freebsd-include-${PV}.tar.bz2
			mirror://gentoo/freebsd-sys-${PV}.tar.bz2"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="virtual/pmake
	=sys-freebsd/freebsd-mk-defs-${PV}*"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_prepare() {
	mkdir "${T}/include"
	cd "${T}/include"
	for i in assert time string strings limits stdio unistd stdlib stddef uuid; do
		ln -s "${S}/include/${i}.h"
	done

	ln -s "${S}/include/arpa"

	ln -s "${S}/sys/i386/include" machine
	ln -s "${S}/sys/x86/include" x86

	for i in net netinet netinet6 sys ufs; do
		ln -s "${S}/sys/${i}"
	done

	mkdir isofs
	ln -s "${S}/sys/fs/cd9660" isofs/

	ln -s "${S}/contrib/openbsm/sys/bsm"
	ln -s "${S}/contrib/bzip2/bzlib.h"

}

src_compile() {

	cd "${WORKDIR}/lib/libstand"
	env MAKESYSPATH=/usr/share/mk/freebsd __MAKE_CONF= CFLAGS="-nostdinc -I /var/tmp/portage/sys-libs/libstand-9.0/temp/include -O2 -pipe" pmake MACHINE_CPUARCH=amd64 MACHINE_ARCH=amd64 || die "Build failure"

}

src_install() {

	cd "${WORKDIR}/lib/libstand"

	dodir /usr/lib
	dodir /usr/include
	dodir /usr/share/man/man3
	install -C -m 444   libstand.a "${ED}usr/lib"
	install -C -m 444   libstand_p.a "${ED}usr/lib"
	install -C -m 444  stand.h "${ED}usr/include"
	install -m 444 libstand.3.gz "${ED}usr/share/man/man3"

}
