# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils

DESCRIPTION="Cryptographic message digest library from FreeBSD"
HOMEPAGE="http://martin.hinner.info/libmd/"
SRC_URI="ftp://ftp.penguin.cz/pub/users/mhi/libmd/libmd-0.3.tar.bz2"

LICENSE="MIT public-domain RSA-MD4 RSA-MD5"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/${P}-fix-header.patch"
	epatch "${FILESDIR}/${P}-fix-make.patch"
	sed -i "s:\$(BUILDROOT)/usr/lib:\$(BUILDROOT)/usr/$(get_libdir):" "${S}/Makefile.in"
	sed -i "s:\$(BUILDROOT)/usr/man:\$(BUILDROOT)/usr/share/man:" "${S}/Makefile.in"
}

src_install() {
	emake BUILDROOT="${ED}" install
}
