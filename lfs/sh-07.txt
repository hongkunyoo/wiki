set -euo pipefail
shopt -s inherit_errexit

tar xf gettext-0.24.tar.xz
cd gettext-0.24
./configure --disable-shared
make
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
cd ..
rm -rf gettext-0.24

tar xf bison-3.8.2.tar.xz
cd bison-3.8.2
./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.8.2
make
make install
cd ..
rm -rf bison-3.8.2

tar xf perl-5.40.1.tar.xz
cd perl-5.40.1
sh Configure -des                                         \
             -D prefix=/usr                               \
             -D vendorprefix=/usr                         \
             -D useshrplib                                \
             -D privlib=/usr/lib/perl5/5.40/core_perl     \
             -D archlib=/usr/lib/perl5/5.40/core_perl     \
             -D sitelib=/usr/lib/perl5/5.40/site_perl     \
             -D sitearch=/usr/lib/perl5/5.40/site_perl    \
             -D vendorlib=/usr/lib/perl5/5.40/vendor_perl \
             -D vendorarch=/usr/lib/perl5/5.40/vendor_perl
make
make install
cd ..
rm -rf perl-5.40.1

tar xf Python-3.13.2.tar.xz
cd Python-3.13.2
./configure --prefix=/usr   \
            --enable-shared \
            --without-ensurepip
make
make install
cd ..
rm -rf Python-3.13.2

tar xf texinfo-7.2.tar.xz
cd texinfo-7.2
./configure --prefix=/usr
make
make install
cd ..
rm -rf texinfo-7.2

tar xf util-linux-2.40.4.tar.xz
cd util-linux-2.40.4
mkdir -pv /var/lib/hwclock
./configure --libdir=/usr/lib     \
            --runstatedir=/run    \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-static      \
            --disable-liblastlog2 \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.40.4
make
make install
cd ..
rm -rf util-linux-2.40.4
