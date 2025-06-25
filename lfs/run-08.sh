cd /sources
echo '======================================'
echo '>>>>>>> man-pages-6.12 >>>>>>>'
tar xf man-pages-6.12.tar.xz
cd man-pages-6.12
rm -v man3/crypt*
make -R GIT=false prefix=/usr install

cd /sources
rm -rf man-pages-6.12
echo '<<<<<<< man-pages-6.12 <<<<<<<'
echo '======================================'
echo '>>>>>>> iana-etc-20250123 >>>>>>>'
tar xf iana-etc-20250123.tar.gz
cd iana-etc-20250123
cp services protocols /etc

cd /sources
rm -rf iana-etc-20250123
echo '<<<<<<< iana-etc-20250123 <<<<<<<'
echo '======================================'
echo '>>>>>>> glibc-2.41 >>>>>>>'
tar xf glibc-2.41.tar.xz
cd glibc-2.41
patch -Np1 -i ../glibc-2.41-fhs-1.patch
mkdir -v build
cd       build
echo "rootsbindir=/usr/sbin" > configparms
../configure --prefix=/usr                            \
             --disable-werror                         \
             --enable-kernel=5.4                      \
             --enable-stack-protector=strong          \
             --disable-nscd                           \
             libc_cv_slibdir=/usr/lib
make
make check
touch /etc/ld.so.conf
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
make install
sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd
localedef -i C -f UTF-8 C.UTF-8
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i el_GR -f ISO-8859-7 el_GR
localedef -i en_GB -f ISO-8859-1 en_GB
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_ES -f ISO-8859-15 es_ES@euro
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i is_IS -f ISO-8859-1 is_IS
localedef -i is_IS -f UTF-8 is_IS.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f ISO-8859-15 it_IT@euro
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i se_NO -f UTF-8 se_NO.UTF-8
localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
localedef -i zh_TW -f UTF-8 zh_TW.UTF-8
make localedata/install-locales
localedef -i C -f UTF-8 C.UTF-8
localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files systemd
group: files systemd
shadow: files systemd

hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF
tar -xf ../../tzdata2025a.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward; do
    zic -L /dev/null   -d $ZONEINFO       ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
    zic -L leapseconds -d $ZONEINFO/right ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO tz
ln -sfv /usr/share/zoneinfo/Asia/Seoul /etc/localtime
cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF
cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv /etc/ld.so.conf.d

cd /sources
rm -rf glibc-2.41
echo '<<<<<<< glibc-2.41 <<<<<<<'
echo '======================================'
echo '>>>>>>> zlib-1.3.1 >>>>>>>'
tar xf zlib-1.3.1.tar.gz
cd zlib-1.3.1
./configure --prefix=/usr
make
make check
make install
rm -fv /usr/lib/libz.a

cd /sources
rm -rf zlib-1.3.1
echo '<<<<<<< zlib-1.3.1 <<<<<<<'
echo '======================================'
echo '>>>>>>> bzip2-1.0.8 >>>>>>>'
tar xf bzip2-1.0.8.tar.gz
cd bzip2-1.0.8
patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so
make clean
make
make PREFIX=/usr install
cp -av libbz2.so.* /usr/lib
ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so
cp -v bzip2-shared /usr/bin/bzip2
for i in /usr/bin/{bzcat,bunzip2}; do
  ln -sfv bzip2 $i
done
rm -fv /usr/lib/libbz2.a

cd /sources
rm -rf bzip2-1.0.8
echo '<<<<<<< bzip2-1.0.8 <<<<<<<'
echo '======================================'
echo '>>>>>>> xz-5.6.4 >>>>>>>'
tar xf xz-5.6.4.tar.xz
cd xz-5.6.4
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.6.4
make
make check
make install

cd /sources
rm -rf xz-5.6.4
echo '<<<<<<< xz-5.6.4 <<<<<<<'
echo '======================================'
echo '>>>>>>> lz4-1.10.0 >>>>>>>'
tar xf lz4-1.10.0.tar.gz
cd lz4-1.10.0
make BUILD_STATIC=no PREFIX=/usr
make -j1 check
make BUILD_STATIC=no PREFIX=/usr install

cd /sources
rm -rf lz4-1.10.0
echo '<<<<<<< lz4-1.10.0 <<<<<<<'
echo '======================================'
echo '>>>>>>> zstd-1.5.7 >>>>>>>'
tar xf zstd-1.5.7.tar.gz
cd zstd-1.5.7
make prefix=/usr
make check
make prefix=/usr install
rm -v /usr/lib/libzstd.a

cd /sources
rm -rf zstd-1.5.7
echo '<<<<<<< zstd-1.5.7 <<<<<<<'
echo '======================================'
echo '>>>>>>> file-5.46 >>>>>>>'
tar xf file-5.46.tar.gz
cd file-5.46
./configure --prefix=/usr
make
make check
make install

cd /sources
rm -rf file-5.46
echo '<<<<<<< file-5.46 <<<<<<<'
echo '======================================'
echo '>>>>>>> readline-8.2.13 >>>>>>>'
tar xf readline-8.2.13.tar.gz
cd readline-8.2.13
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install
sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf
./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.2.13
make SHLIB_LIBS="-lncursesw"
make install
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.2.13

cd /sources
rm -rf readline-8.2.13
echo '<<<<<<< readline-8.2.13 <<<<<<<'
echo '======================================'
echo '>>>>>>> m4-1.4.19 >>>>>>>'
tar xf m4-1.4.19.tar.xz
cd m4-1.4.19
./configure --prefix=/usr
make
make check
make install

cd /sources
rm -rf m4-1.4.19
echo '<<<<<<< m4-1.4.19 <<<<<<<'
echo '======================================'
echo '>>>>>>> bc-7.0.3 >>>>>>>'
tar xf bc-7.0.3.tar.xz
cd bc-7.0.3
CC=gcc ./configure --prefix=/usr -G -O3 -r
make
make test
make install

cd /sources
rm -rf bc-7.0.3
echo '<<<<<<< bc-7.0.3 <<<<<<<'
echo '======================================'
echo '>>>>>>> flex-2.6.4 >>>>>>>'
tar xf flex-2.6.4.tar.gz
cd flex-2.6.4
./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static
make
make check
make install
ln -sv flex   /usr/bin/lex
ln -sv flex.1 /usr/share/man/man1/lex.1

cd /sources
rm -rf flex-2.6.4
echo '<<<<<<< flex-2.6.4 <<<<<<<'
echo '======================================'
echo '>>>>>>> tcl8.6.16-src >>>>>>>'
tar xf tcl8.6.16-src.tar.gz
cd tcl8.6.16-src
SRCDIR=$(pwd)
cd unix
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --disable-rpath
make

sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.10|/usr/lib/tdbc1.1.10|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.10/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/tdbc1.1.10/library|/usr/lib/tcl8.6|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.10|/usr/include|"            \
    -i pkgs/tdbc1.1.10/tdbcConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/itcl4.3.2|/usr/lib/itcl4.3.2|" \
    -e "s|$SRCDIR/pkgs/itcl4.3.2/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/itcl4.3.2|/usr/include|"            \
    -i pkgs/itcl4.3.2/itclConfig.sh

unset SRCDIR
make test
make install
chmod -v u+w /usr/lib/libtcl8.6.so
make install-private-headers
ln -sfv tclsh8.6 /usr/bin/tclsh
mv /usr/share/man/man3/{Thread,Tcl_Thread}.3
cd ..
tar -xf ../tcl8.6.16-html.tar.gz --strip-components=1
mkdir -v -p /usr/share/doc/tcl-8.6.16
cp -v -r  ./html/* /usr/share/doc/tcl-8.6.16

cd /sources
rm -rf tcl8.6.16-src
echo '<<<<<<< tcl8.6.16-src <<<<<<<'
echo '======================================'
echo '>>>>>>> expect5.45.4 >>>>>>>'
tar xf expect5.45.4.tar.gz
cd expect5.45.4
python3 -c 'from pty import spawn; spawn(["echo", "ok"])'
patch -Np1 -i ../expect-5.45.4-gcc14-1.patch
./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --disable-rpath         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include
make
make test
make install
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib

cd /sources
rm -rf expect5.45.4
echo '<<<<<<< expect5.45.4 <<<<<<<'
echo '======================================'
echo '>>>>>>> dejagnu-1.6.3 >>>>>>>'
tar xf dejagnu-1.6.3.tar.gz
cd dejagnu-1.6.3
mkdir -v build
cd       build
../configure --prefix=/usr
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi
make check
make install
install -v -dm755  /usr/share/doc/dejagnu-1.6.3
install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3
cd ..

cd /sources
rm -rf dejagnu-1.6.3
echo '<<<<<<< dejagnu-1.6.3 <<<<<<<'
echo '======================================'
echo '>>>>>>> pkgconf-2.3.0 >>>>>>>'
tar xf pkgconf-2.3.0.tar.xz
cd pkgconf-2.3.0
./configure --prefix=/usr              \
            --disable-static           \
            --docdir=/usr/share/doc/pkgconf-2.3.0
make
make install
ln -sv pkgconf   /usr/bin/pkg-config
ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1

cd /sources
rm -rf pkgconf-2.3.0
echo '<<<<<<< pkgconf-2.3.0 <<<<<<<'
echo '======================================'
echo '>>>>>>> binutils-2.44 >>>>>>>'
tar xf binutils-2.44.tar.xz
cd binutils-2.44
mkdir -v build
cd       build
../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --enable-new-dtags  \
             --with-system-zlib  \
             --enable-default-hash-style=gnu
make tooldir=/usr
make -k check
grep '^FAIL:' $(find -name '*.log')
make tooldir=/usr install
rm -rfv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a \
        /usr/share/doc/gprofng/

cd /sources
rm -rf binutils-2.44
echo '<<<<<<< binutils-2.44 <<<<<<<'
echo '======================================'
echo '>>>>>>> gmp-6.3.0 >>>>>>>'
tar xf gmp-6.3.0.tar.xz
cd gmp-6.3.0
./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0
make
make html
make check 2>&1 | tee gmp-check-log
awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
make install
make install-html

cd /sources
rm -rf gmp-6.3.0
echo '<<<<<<< gmp-6.3.0 <<<<<<<'
echo '======================================'
echo '>>>>>>> mpfr-4.2.1 >>>>>>>'
tar xf mpfr-4.2.1.tar.xz
cd mpfr-4.2.1
./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.2.1
make
make html
make check
make install
make install-html

cd /sources
rm -rf mpfr-4.2.1
echo '<<<<<<< mpfr-4.2.1 <<<<<<<'
echo '======================================'
echo '>>>>>>> mpc-1.3.1 >>>>>>>'
tar xf mpc-1.3.1.tar.gz
cd mpc-1.3.1
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.3.1
make
make html
make check
make install
make install-html

cd /sources
rm -rf mpc-1.3.1
echo '<<<<<<< mpc-1.3.1 <<<<<<<'
echo '======================================'
echo '>>>>>>> attr-2.5.2 >>>>>>>'
tar xf attr-2.5.2.tar.gz
cd attr-2.5.2
./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.2
make
make check
make install

cd /sources
rm -rf attr-2.5.2
echo '<<<<<<< attr-2.5.2 <<<<<<<'
echo '======================================'
echo '>>>>>>> acl-2.3.2 >>>>>>>'
tar xf acl-2.3.2.tar.xz
cd acl-2.3.2
./configure --prefix=/usr         \
            --disable-static      \
            --docdir=/usr/share/doc/acl-2.3.2
make
make check
make install

cd /sources
rm -rf acl-2.3.2
echo '<<<<<<< acl-2.3.2 <<<<<<<'
echo '======================================'
echo '>>>>>>> libcap-2.73 >>>>>>>'
tar xf libcap-2.73.tar.xz
cd libcap-2.73
sed -i '/install -m.*STA/d' libcap/Makefile
make prefix=/usr lib=lib
make test
make prefix=/usr lib=lib install

cd /sources
rm -rf libcap-2.73
echo '<<<<<<< libcap-2.73 <<<<<<<'
echo '======================================'
echo '>>>>>>> libxcrypt-4.4.38 >>>>>>>'
tar xf libxcrypt-4.4.38.tar.xz
cd libxcrypt-4.4.38
./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens
make
make check
make install

cd /sources
rm -rf libxcrypt-4.4.38
echo '<<<<<<< libxcrypt-4.4.38 <<<<<<<'
echo '======================================'
echo '>>>>>>> shadow-4.17.3 >>>>>>>'
tar xf shadow-4.17.3.tar.xz
cd shadow-4.17.3
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;
sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
    -e 's:/var/spool/mail:/var/mail:'                   \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                  \
    -i etc/login.defs
touch /usr/bin/passwd
./configure --sysconfdir=/etc   \
            --disable-static    \
            --with-{b,yes}crypt \
            --without-libbsd    \
            --with-group-name-max-length=32
make
make exec_prefix=/usr install
make -C man install-man
pwconv
grpconv
# passwd root

cd /sources
rm -rf shadow-4.17.3
echo '<<<<<<< shadow-4.17.3 <<<<<<<'
echo '======================================'
echo '>>>>>>> gcc-14.2.0 >>>>>>>'
tar xf gcc-14.2.0.tar.xz
cd gcc-14.2.0
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac
mkdir -v build
cd       build
../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --enable-default-pie     \
             --enable-default-ssp     \
             --enable-host-pie        \
             --disable-multilib       \
             --disable-bootstrap      \
             --disable-fixincludes    \
             --with-system-zlib
make
ulimit -s -H unlimited
sed -e '/cpython/d'               -i ../gcc/testsuite/gcc.dg/plugin/plugin.exp
sed -e 's/no-pic /&-no-pie /'     -i ../gcc/testsuite/gcc.target/i386/pr113689-1.c
sed -e 's/300000/(1|300000)/'     -i ../libgomp/testsuite/libgomp.c-c++-common/pr109062.c
sed -e 's/{ target nonpic } //' \
    -e '/GOTPCREL/d'              -i ../gcc/testsuite/gcc.target/i386/fentryname3.c
# chown -R tester .
# su tester -c "PATH=$PATH make -k check"
make install
chown -v -R root:root \
    /usr/lib/gcc/$(gcc -dumpmachine)/14.2.0/include{,-fixed}
ln -svr /usr/bin/cpp /usr/lib
ln -sv gcc.1 /usr/share/man/man1/cc.1
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/14.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/
echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'
grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' dummy.log
grep -B4 '^ /usr/include' dummy.log
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
grep "/lib.*/libc.so.6 " dummy.log
grep found dummy.log
rm -v dummy.c a.out dummy.log
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

cd /sources
rm -rf gcc-14.2.0
echo '<<<<<<< gcc-14.2.0 <<<<<<<'
echo '======================================'
echo '>>>>>>> ncurses-6.5 >>>>>>>'
tar xf ncurses-6.5.tar.gz
cd ncurses-6.5
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --with-pkg-config-libdir=/usr/lib/pkgconfig
make
make DESTDIR=$PWD/dest install
install -vm755 dest/usr/lib/libncursesw.so.6.5 /usr/lib
rm -v  dest/usr/lib/libncursesw.so.6.5
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i dest/usr/include/curses.h
cp -av dest/* /
for lib in ncurses form panel menu ; do
    ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
done
ln -sfv libncursesw.so /usr/lib/libcurses.so
cp -v -R doc -T /usr/share/doc/ncurses-6.5

cd /sources
rm -rf ncurses-6.5
echo '<<<<<<< ncurses-6.5 <<<<<<<'
echo '======================================'
echo '>>>>>>> sed-4.9 >>>>>>>'
tar xf sed-4.9.tar.xz
cd sed-4.9
./configure --prefix=/usr
make
make html
chown -R tester .
su tester -c "PATH=$PATH make check"
make install
install -d -m755           /usr/share/doc/sed-4.9
install -m644 doc/sed.html /usr/share/doc/sed-4.9

cd /sources
rm -rf sed-4.9
echo '<<<<<<< sed-4.9 <<<<<<<'
echo '======================================'
echo '>>>>>>> psmisc-23.7 >>>>>>>'
tar xf psmisc-23.7.tar.xz
cd psmisc-23.7
./configure --prefix=/usr
make
make check
make install

cd /sources
rm -rf psmisc-23.7
echo '<<<<<<< psmisc-23.7 <<<<<<<'
echo '======================================'
echo '>>>>>>> gettext-0.24 >>>>>>>'
tar xf gettext-0.24.tar.xz
cd gettext-0.24
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.24
make
make check
make install
chmod -v 0755 /usr/lib/preloadable_libintl.so

cd /sources
rm -rf gettext-0.24
echo '<<<<<<< gettext-0.24 <<<<<<<'
echo '======================================'
echo '>>>>>>> bison-3.8.2 >>>>>>>'
tar xf bison-3.8.2.tar.xz
cd bison-3.8.2
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
make
make check
make install

cd /sources
rm -rf bison-3.8.2
echo '<<<<<<< bison-3.8.2 <<<<<<<'
echo '======================================'
echo '>>>>>>> grep-3.11 >>>>>>>'
tar xf grep-3.11.tar.xz
cd grep-3.11
sed -i "s/echo/#echo/" src/egrep.sh
./configure --prefix=/usr
make
make check
make install

cd /sources
rm -rf grep-3.11
echo '<<<<<<< grep-3.11 <<<<<<<'
echo '======================================'
echo '>>>>>>> bash-5.2.37 >>>>>>>'
tar xf bash-5.2.37.tar.gz
cd bash-5.2.37
./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-5.2.37
make
chown -R tester .
su -s /usr/bin/expect tester << "EOF"
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF
make install
#exec /usr/bin/bash --login

cd /sources
rm -rf bash-5.2.37
echo '<<<<<<< bash-5.2.37 <<<<<<<'
echo '======================================'
echo '>>>>>>> libtool-2.5.4 >>>>>>>'
tar xf libtool-2.5.4.tar.xz
cd libtool-2.5.4
./configure --prefix=/usr
make
make check
make install
rm -fv /usr/lib/libltdl.a

cd /sources
rm -rf libtool-2.5.4
echo '<<<<<<< libtool-2.5.4 <<<<<<<'
echo '======================================'
echo '>>>>>>> gdbm-1.24 >>>>>>>'
tar xf gdbm-1.24.tar.gz
cd gdbm-1.24
./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat
make
make check
make install

cd /sources
rm -rf gdbm-1.24
echo '<<<<<<< gdbm-1.24 <<<<<<<'
echo '======================================'
echo '>>>>>>> gperf-3.1 >>>>>>>'
tar xf gperf-3.1.tar.gz
cd gperf-3.1
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
make
make -j1 check
make install

cd /sources
rm -rf gperf-3.1
echo '<<<<<<< gperf-3.1 <<<<<<<'
echo '======================================'
echo '>>>>>>> expat-2.7.1 >>>>>>>'
tar xf expat-2.7.1.tar.xz
cd expat-2.7.1
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.6.4
make
make check
make install
install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.6.4

cd /sources
rm -rf expat-2.7.1
echo '<<<<<<< expat-2.7.1 <<<<<<<'
echo '======================================'
echo '>>>>>>> inetutils-2.6 >>>>>>>'
tar xf inetutils-2.6.tar.xz
cd inetutils-2.6
sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c
./configure --prefix=/usr        \
            --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers
make
make check
make install
mv -v /usr/{,s}bin/ifconfig

cd /sources
rm -rf inetutils-2.6
echo '<<<<<<< inetutils-2.6 <<<<<<<'
echo '======================================'
echo '>>>>>>> less-668 >>>>>>>'
tar xf less-668.tar.gz
cd less-668
./configure --prefix=/usr --sysconfdir=/etc
make
make check
make install

cd /sources
rm -rf less-668
echo '<<<<<<< less-668 <<<<<<<'
echo '======================================'
echo '>>>>>>> perl-5.40.1 >>>>>>>'
tar xf perl-5.40.1.tar.xz
cd perl-5.40.1
export BUILD_ZLIB=False
export BUILD_BZIP2=0
sh Configure -des                                          \
             -D prefix=/usr                                \
             -D vendorprefix=/usr                          \
             -D privlib=/usr/lib/perl5/5.40/core_perl      \
             -D archlib=/usr/lib/perl5/5.40/core_perl      \
             -D sitelib=/usr/lib/perl5/5.40/site_perl      \
             -D sitearch=/usr/lib/perl5/5.40/site_perl     \
             -D vendorlib=/usr/lib/perl5/5.40/vendor_perl  \
             -D vendorarch=/usr/lib/perl5/5.40/vendor_perl \
             -D man1dir=/usr/share/man/man1                \
             -D man3dir=/usr/share/man/man3                \
             -D pager="/usr/bin/less -isR"                 \
             -D useshrplib                                 \
             -D usethreads
make
TEST_JOBS=$(nproc) make test_harness
make install
unset BUILD_ZLIB BUILD_BZIP2

cd /sources
rm -rf perl-5.40.1
echo '<<<<<<< perl-5.40.1 <<<<<<<'
echo '======================================'
echo '>>>>>>> XML-Parser-2.47 >>>>>>>'
tar xf XML-Parser-2.47.tar.gz
cd XML-Parser-2.47
perl Makefile.PL
make
make test
make install

cd /sources
rm -rf XML-Parser-2.47
echo '<<<<<<< XML-Parser-2.47 <<<<<<<'
echo '======================================'
echo '>>>>>>> intltool-0.51.0 >>>>>>>'
tar xf intltool-0.51.0.tar.gz
cd intltool-0.51.0
sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr
make
make check
make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

cd /sources
rm -rf intltool-0.51.0
echo '<<<<<<< intltool-0.51.0 <<<<<<<'
echo '======================================'
echo '>>>>>>> autoconf-2.72 >>>>>>>'
tar xf autoconf-2.72.tar.xz
cd autoconf-2.72
./configure --prefix=/usr
make
make check
make install

cd /sources
rm -rf autoconf-2.72
echo '<<<<<<< autoconf-2.72 <<<<<<<'
echo '======================================'
echo '>>>>>>> automake-1.17 >>>>>>>'
tar xf automake-1.17.tar.xz
cd automake-1.17
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.17
make
make -j$(($(nproc)>4?$(nproc):4)) check
make install

cd /sources
rm -rf automake-1.17
echo '<<<<<<< automake-1.17 <<<<<<<'
echo '======================================'
echo '>>>>>>> openssl-3.4.1 >>>>>>>'
tar xf openssl-3.4.1.tar.gz
cd openssl-3.4.1
./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
make
HARNESS_JOBS=$(nproc) make test
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.4.1
cp -vfr doc/* /usr/share/doc/openssl-3.4.1

cd /sources
rm -rf openssl-3.4.1
echo '<<<<<<< openssl-3.4.1 <<<<<<<'
echo '======================================'
echo '>>>>>>> elfutils-0.192 >>>>>>>'
tar xf elfutils-0.192.tar.bz2
cd elfutils-0.192
./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy
make
make check
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a

cd /sources
rm -rf elfutils-0.192
echo '<<<<<<< elfutils-0.192 <<<<<<<'
echo '======================================'
echo '>>>>>>> libffi-3.4.7 >>>>>>>'
tar xf libffi-3.4.7.tar.gz
cd libffi-3.4.7
./configure --prefix=/usr          \
            --disable-static       \
            --with-gcc-arch=native
make
make check
make install

cd /sources
rm -rf libffi-3.4.7
echo '<<<<<<< libffi-3.4.7 <<<<<<<'
echo '======================================'
echo '>>>>>>> Python-3.13.2 >>>>>>>'
tar xf Python-3.13.2.tar.xz
cd Python-3.13.2
./configure --prefix=/usr        \
            --enable-shared      \
            --with-system-expat  \
            --enable-optimizations
make
make test TESTOPTS="--timeout 120"
make install
cat > /etc/pip.conf << EOF
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF

install -v -dm755 /usr/share/doc/python-3.13.2/html

tar --strip-components=1  \
    --no-same-owner       \
    --no-same-permissions \
    -C /usr/share/doc/python-3.13.2/html \
    -xvf ../python-3.13.2-docs-html.tar.bz2

cd /sources
rm -rf Python-3.13.2
echo '<<<<<<< Python-3.13.2 <<<<<<<'
echo '======================================'
echo '>>>>>>> flit_core-3.11.0 >>>>>>>'
tar xf flit_core-3.11.0.tar.gz
cd flit_core-3.11.0
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist flit_core

cd /sources
rm -rf flit_core-3.11.0
echo '<<<<<<< flit_core-3.11.0 <<<<<<<'
echo '======================================'
echo '>>>>>>> wheel-0.45.1 >>>>>>>'
tar xf wheel-0.45.1.tar.gz
cd wheel-0.45.1
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist wheel

cd /sources
rm -rf wheel-0.45.1
echo '<<<<<<< wheel-0.45.1 <<<<<<<'
echo '======================================'
echo '>>>>>>> setuptools-75.8.1 >>>>>>>'
tar xf setuptools-75.8.1.tar.gz
cd setuptools-75.8.1
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist setuptools

cd /sources
rm -rf setuptools-75.8.1
echo '<<<<<<< setuptools-75.8.1 <<<<<<<'
echo '======================================'
echo '>>>>>>> ninja-1.12.1 >>>>>>>'
tar xf ninja-1.12.1.tar.gz
cd ninja-1.12.1
sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc
python3 configure.py --bootstrap --verbose
install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja

cd /sources
rm -rf ninja-1.12.1
echo '<<<<<<< ninja-1.12.1 <<<<<<<'
echo '======================================'
echo '>>>>>>> meson-1.7.0 >>>>>>>'
tar xf meson-1.7.0.tar.gz
cd meson-1.7.0
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist meson
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson

cd /sources
rm -rf meson-1.7.0
echo '<<<<<<< meson-1.7.0 <<<<<<<'
echo '======================================'
echo '>>>>>>> kmod-34 >>>>>>>'
tar xf kmod-34.tar.xz
cd kmod-34
mkdir -p build
cd       build

meson setup --prefix=/usr ..    \
            --sbindir=/usr/sbin \
            --buildtype=release \
            -D manpages=false
ninja
ninja install

cd /sources
rm -rf kmod-34
echo '<<<<<<< kmod-34 <<<<<<<'
echo '======================================'
echo '>>>>>>> coreutils-9.6 >>>>>>>'
tar xf coreutils-9.6.tar.xz
cd coreutils-9.6
patch -Np1 -i ../coreutils-9.6-i18n-1.patch
autoreconf -fv
automake -af
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime
make
make NON_ROOT_USERNAME=tester check-root
groupadd -g 102 dummy -U tester
chown -R tester . 
su tester -c "PATH=$PATH make -k RUN_EXPENSIVE_TESTS=yes check" \
   < /dev/null
groupdel dummy
make install
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8

cd /sources
rm -rf coreutils-9.6
echo '<<<<<<< coreutils-9.6 <<<<<<<'
echo '======================================'
echo '>>>>>>> check-0.15.2 >>>>>>>'
tar xf check-0.15.2.tar.gz
cd check-0.15.2
./configure --prefix=/usr --disable-static
make
make check
make docdir=/usr/share/doc/check-0.15.2 install

cd /sources
rm -rf check-0.15.2
echo '<<<<<<< check-0.15.2 <<<<<<<'
echo '======================================'
echo '>>>>>>> diffutils-3.11 >>>>>>>'
tar xf diffutils-3.11.tar.xz
cd diffutils-3.11
./configure --prefix=/usr
make
make check
make install

cd /sources
rm -rf diffutils-3.11
echo '<<<<<<< diffutils-3.11 <<<<<<<'
echo '======================================'
echo '>>>>>>> gawk-5.3.1 >>>>>>>'
tar xf gawk-5.3.1.tar.xz
cd gawk-5.3.1
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr
make
chown -R tester .
su tester -c "PATH=$PATH make check"
rm -f /usr/bin/gawk-5.3.1
make install
ln -sv gawk.1 /usr/share/man/man1/awk.1
install -vDm644 doc/{awkforai.txt,*.{eps,pdf,jpg}} -t /usr/share/doc/gawk-5.3.1

cd /sources
rm -rf gawk-5.3.1
echo '<<<<<<< gawk-5.3.1 <<<<<<<'
echo '======================================'
echo '>>>>>>> findutils-4.10.0 >>>>>>>'
tar xf findutils-4.10.0.tar.xz
cd findutils-4.10.0
./configure --prefix=/usr --localstatedir=/var/lib/locate
make
chown -R tester .
su tester -c "PATH=$PATH make check"
make install

cd /sources
rm -rf findutils-4.10.0
echo '<<<<<<< findutils-4.10.0 <<<<<<<'
echo '======================================'
echo '>>>>>>> groff-1.23.0 >>>>>>>'
tar xf groff-1.23.0.tar.gz
cd groff-1.23.0
PAGE=a4 ./configure --prefix=/usr
make
make check
make install

cd /sources
rm -rf groff-1.23.0
echo '<<<<<<< groff-1.23.0 <<<<<<<'
echo '======================================'
echo '>>>>>>> grub-2.12 >>>>>>>'
tar xf grub-2.12.tar.xz
cd grub-2.12
unset {C,CPP,CXX,LD}FLAGS
echo depends bli part_gpt > grub-core/extra_deps.lst
./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --disable-efiemu       \
            --disable-werror
make
make install
mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions

cd /sources
rm -rf grub-2.12
echo '<<<<<<< grub-2.12 <<<<<<<'
echo '======================================'
echo '>>>>>>> gzip-1.13 >>>>>>>'
tar xf gzip-1.13.tar.xz
cd gzip-1.13
./configure --prefix=/usr
make
make check
make install

cd /sources
rm -rf gzip-1.13
echo '<<<<<<< gzip-1.13 <<<<<<<'
echo '======================================'
echo '>>>>>>> iproute2-6.13.0 >>>>>>>'
tar xf iproute2-6.13.0.tar.xz
cd iproute2-6.13.0
sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
make NETNS_RUN_DIR=/run/netns
make SBINDIR=/usr/sbin install
install -vDm644 COPYING README* -t /usr/share/doc/iproute2-6.13.0

cd /sources
rm -rf iproute2-6.13.0
echo '<<<<<<< iproute2-6.13.0 <<<<<<<'
echo '======================================'
echo '>>>>>>> kbd-2.7.1 >>>>>>>'
tar xf kbd-2.7.1.tar.xz
cd kbd-2.7.1
patch -Np1 -i ../kbd-2.7.1-backspace-1.patch
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
./configure --prefix=/usr --disable-vlock
make
make check
make install
cp -R -v docs/doc -T /usr/share/doc/kbd-2.7.1

cd /sources
rm -rf kbd-2.7.1
echo '<<<<<<< kbd-2.7.1 <<<<<<<'
echo '======================================'
echo '>>>>>>> libpipeline-1.5.8 >>>>>>>'
tar xf libpipeline-1.5.8.tar.gz
cd libpipeline-1.5.8
./configure --prefix=/usr
make
make check
make install

cd /sources
rm -rf libpipeline-1.5.8
echo '<<<<<<< libpipeline-1.5.8 <<<<<<<'
echo '======================================'
echo '>>>>>>> make-4.4.1 >>>>>>>'
tar xf make-4.4.1.tar.gz
cd make-4.4.1
./configure --prefix=/usr
make
chown -R tester .
su tester -c "PATH=$PATH make check"
make install

cd /sources
rm -rf make-4.4.1
echo '<<<<<<< make-4.4.1 <<<<<<<'
echo '======================================'
echo '>>>>>>> patch-2.7.6 >>>>>>>'
tar xf patch-2.7.6.tar.xz
cd patch-2.7.6
./configure --prefix=/usr
make
make check
make install

cd /sources
rm -rf patch-2.7.6
echo '<<<<<<< patch-2.7.6 <<<<<<<'
echo '======================================'
echo '>>>>>>> tar-1.35 >>>>>>>'
tar xf tar-1.35.tar.xz
cd tar-1.35
FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr
make
make check
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.35

cd /sources
rm -rf tar-1.35
echo '<<<<<<< tar-1.35 <<<<<<<'
echo '======================================'
echo '>>>>>>> texinfo-7.2 >>>>>>>'
tar xf texinfo-7.2.tar.xz
cd texinfo-7.2
./configure --prefix=/usr
make
make check
make install
make TEXMF=/usr/share/texmf install-tex
pushd /usr/share/info
  rm -v dir
  for f in *
    do install-info $f dir 2>/dev/null
  done
popd

cd /sources
rm -rf texinfo-7.2
echo '<<<<<<< texinfo-7.2 <<<<<<<'
echo '======================================'
echo '>>>>>>> vim-9.1.1166 >>>>>>>'
tar xf vim-9.1.1166.tar.gz
cd vim-9.1.1166
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
./configure --prefix=/usr
make
chown -R tester .
sed '/test_plugin_glvs/d' -i src/testdir/Make_all.mak
su tester -c "TERM=xterm-256color LANG=en_US.UTF-8 make -j1 test" \
   &> vim-test.log
make install
ln -sv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done
ln -sv ../vim/vim91/doc /usr/share/doc/vim-9.1.1166
cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF
#vim -c ':options'

cd /sources
rm -rf vim-9.1.1166
echo '<<<<<<< vim-9.1.1166 <<<<<<<'
echo '======================================'
echo '>>>>>>> markupsafe-3.0.2 >>>>>>>'
tar xf markupsafe-3.0.2.tar.gz
cd markupsafe-3.0.2
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist Markupsafe

cd /sources
rm -rf markupsafe-3.0.2
echo '<<<<<<< markupsafe-3.0.2 <<<<<<<'
echo '======================================'
echo '>>>>>>> jinja2-3.1.5 >>>>>>>'
tar xf jinja2-3.1.5.tar.gz
cd jinja2-3.1.5
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
pip3 install --no-index --find-links dist Jinja2

cd /sources
rm -rf jinja2-3.1.5
echo '<<<<<<< jinja2-3.1.5 <<<<<<<'
echo '======================================'
echo '>>>>>>> systemd-257.3 >>>>>>>'
tar xf systemd-257.3.tar.gz
cd systemd-257.3
sed -e 's/GROUP="render"/GROUP="video"/' \
    -e 's/GROUP="sgx", //'               \
    -i rules.d/50-udev-default.rules.in
mkdir -p build
cd       build

meson setup ..                \
      --prefix=/usr           \
      --buildtype=release     \
      -D default-dnssec=no    \
      -D firstboot=false      \
      -D install-tests=false  \
      -D ldconfig=false       \
      -D sysusers=false       \
      -D rpmmacrosdir=no      \
      -D homed=disabled       \
      -D userdb=false         \
      -D man=disabled         \
      -D mode=release         \
      -D pamconfdir=no        \
      -D dev-kvm-mode=0660    \
      -D nobody-group=nogroup \
      -D sysupdate=disabled   \
      -D ukify=disabled       \
      -D docdir=/usr/share/doc/systemd-257.3
ninja
echo 'NAME="Linux From Scratch"' > /etc/os-release
ninja test
ninja install
tar -xf ../../systemd-man-pages-257.3.tar.xz \
    --no-same-owner --strip-components=1   \
    -C /usr/share/man
systemd-machine-id-setup
systemctl preset-all

cd /sources
rm -rf systemd-257.3
echo '<<<<<<< systemd-257.3 <<<<<<<'
echo '======================================'
echo '>>>>>>> dbus-1.16.0 >>>>>>>'
tar xf dbus-1.16.0.tar.xz
cd dbus-1.16.0
mkdir build
cd    build

meson setup --prefix=/usr --buildtype=release --wrap-mode=nofallback ..
ninja
ninja test
ninja install
ln -sfv /etc/machine-id /var/lib/dbus

cd /sources
rm -rf dbus-1.16.0
echo '<<<<<<< dbus-1.16.0 <<<<<<<'
echo '======================================'
echo '>>>>>>> man-db-2.13.0 >>>>>>>'
tar xf man-db-2.13.0.tar.xz
cd man-db-2.13.0
./configure --prefix=/usr                         \
            --docdir=/usr/share/doc/man-db-2.13.0 \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap
make
make check
make install

cd /sources
rm -rf man-db-2.13.0
echo '<<<<<<< man-db-2.13.0 <<<<<<<'
echo '======================================'
echo '>>>>>>> procps-ng-4.0.5 >>>>>>>'
tar xf procps-ng-4.0.5.tar.xz
cd procps-ng-4.0.5
./configure --prefix=/usr                           \
            --docdir=/usr/share/doc/procps-ng-4.0.5 \
            --disable-static                        \
            --disable-kill                          \
            --enable-watch8bit                      \
            --with-systemd
make
chown -R tester .
su tester -c "PATH=$PATH make check"
make install

cd /sources
rm -rf procps-ng-4.0.5
echo '<<<<<<< procps-ng-4.0.5 <<<<<<<'
echo '======================================'
echo '>>>>>>> util-linux-2.40.4 >>>>>>>'
tar xf util-linux-2.40.4.tar.xz
cd util-linux-2.40.4
./configure --bindir=/usr/bin     \
            --libdir=/usr/lib     \
            --runstatedir=/run    \
            --sbindir=/usr/sbin   \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-liblastlog2 \
            --disable-static      \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.40.4
make
bash tests/run.sh --srcdir=$PWD --builddir=$PWD
touch /etc/fstab
chown -R tester .
su tester -c "make -k check"
make install

cd /sources
rm -rf util-linux-2.40.4
echo '<<<<<<< util-linux-2.40.4 <<<<<<<'
echo '======================================'
echo '>>>>>>> e2fsprogs-1.47.2 >>>>>>>'
tar xf e2fsprogs-1.47.2.tar.gz
cd e2fsprogs-1.47.2
mkdir -v build
cd       build
../configure --prefix=/usr           \
             --sysconfdir=/etc       \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck
make
make check
make install
rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
sed 's/metadata_csum_seed,//' -i /etc/mke2fs.conf
