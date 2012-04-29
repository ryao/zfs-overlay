# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="Bootloader for booting off GPT formatted ZFS disks."
HOMEPAGE="http://www.freebsd.org/"
SRC_URI="mirror://gentoo/freebsd-contrib-${PV}.tar.bz2
			mirror://gentoo/freebsd-lib-${PV}.tar.bz2
			mirror://gentoo/freebsd-include-${PV}.tar.bz2
			mirror://gentoo/freebsd-sys-${PV}.tar.bz2"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="sys-apps/btxld
	=sys-freebsd/freebsd-mk-defs-${PV}*
	virtual/pmake"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_prepare() {
	#sed -i 's/-m elf_i386_fbsd/-m elf_i386/' "${S}/sys/boot/i386/Makefile.inc"
	sed -i 's/-m elf_i386_fbsd//' "${S}/sys/boot/i386/Makefile.inc"
	#sed -i 's/ ${BTXLDR}//' "${S}/sys/boot/i386/loader/Makefile"

	mkdir "${T}/include"
	cd "${T}/include"
	for i in assert ctype inttypes _ctype link runetype time string strings limits stdio unistd stdlib stddef uuid nlist a.out setjmp bitstring; do
		ln -s "${S}/include/${i}.h"
	done

	ln -s "${S}/sys/i386/include/stdarg.h"

	ln -s "${S}/sys/i386/include" machine
	ln -s "${S}/sys/x86/include" x86

	for i in sys/errno.h net netinet netinet6 sys ufs; do
		ln -s "${S}/sys/${i}"
	done

	ln -s /usr/include/stand.h "${T}/include/"
	ln -s "${S}/sys/boot/ficl/i386/sysdep.h"
	ln -s "${S}/lib/msun/src/math.h"

}

src_compile() {

	export MAKESYSPATH=/usr/share/mk/freebsd
	export __MAKE_CONF=

	cd "${S}/sys/boot/i386/pmbr"
	pmake || die "Failure building pmbr"

	cd "${S}/sys/boot/i386/btx/btx"
	env AFLAGS="--32" CFLAGS="-m32" pmake || die "Failure building btx/btx"

	cd "${S}/sys/boot/i386/btx/lib"
	env AFLAGS="--32" CFLAGS="-m32" pmake || die "Failure building btx/lib"

	cd "${S}/sys/boot/i386/gptzfsboot"
	env LD="ld -m elf_i386" CC="gcc -m32 -nostdinc -I ${T}/include" pmake || die "Failure building gptzfsboot"

	cd "${S}/sys/boot/ficl"
	env LD="ld -m elf_i386" CC="gcc -m32 -nostdinc -I ${T}/include" pmake MACHINE_CPUARCH=amd64 MACHINE_ARCH=amd64 || die "Failure building ficl"

	cd "${S}/sys/boot/zfs"
	env LD="ld -m elf_i386" CC="gcc -m32 -nostdinc -I ${T}/include" pmake MACHINE_CPUARCH=amd64 MACHINE_ARCH=amd64 || die "Failure building zfs"

	cd "${S}/sys/boot/i386/libi386"
	env LD="ld -m elf_i386" CC="gcc -m32 -nostdinc -I ${T}/include" pmake MACHINE_CPUARCH=amd64 MACHINE_ARCH=amd64 || die "Failure building libi386"

	cd "${S}/sys/boot/i386/btx/btxldr"
	${CC:-cc} -O2 -pipe  -DLOADER_ADDRESS=0x200000 -ffreestanding -mpreferred-stack-boundary=2  -mno-mmx -mno-3dnow -mno-sse -mno-sse2 -mno-sse3 -msoft-float -m32 -march=i386 -std=gnu99 -m32 -c btxldr.S
	${CC:-cc} -O2 -pipe  -DLOADER_ADDRESS=0x200000 -ffreestanding -mpreferred-stack-boundary=2  -mno-mmx -mno-3dnow -mno-sse -mno-sse2 -mno-sse3 -msoft-float -m32 -march=i386 -std=gnu99 -e start -Ttext 0x200000 -Wl,-N,-S,--oformat,binary -nostdlib -o btxldr btxldr.o

	cd "${S}/sys/boot/i386/zfsloader"
	env LD="ld -m elf_i386" CC="gcc -m32 -nostdinc -I ${T}/include" pmake MACHINE_CPUARCH=amd64 MACHINE_ARCH=amd64 || die "Failure building zfsloader"

}

src_install() {
	dodir /boot

	cd "${S}/sys/boot/i386/pmbr"
	install -m 444   pmbr "${ED}/boot"

	cd "${S}/sys/boot/i386/gptzfsboot"
	install -m 444 gptzfsboot "${ED}/boot"

	cd "${S}/sys/boot/i386/zfsloader"
	install -m 555 -b zfsloader "${ED}boot/zfsloader"

}
