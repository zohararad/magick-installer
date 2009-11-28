#!/bin/sh

# Installs ImageMagick and all dependencies from source on snow leopard
# requires wget to be installed.
# Please download and install wget from http://www.gnu.org/software/wget/ before running this script

# ===== setup some global variables =====

# directory to install ImageMagick and dependencies
PREFIX=/opt

# directory to use for source building. Leave as /usr/local/src if unsure
BUILD_DIR=/usr/local/src

# make sure sub-directory structure of target install directory is in $PATH, so
# configure scripts will easily find dependencies
export PATH=$PREFIX/bin:$PREFIX/lib:$PREFIX/include:$PATH

# ===== prepare or enter build directory =====
if [ -d $BUILD_DIR ]; then
	cd $BUILD_DIR
else
	mkdir -p $BUILD_DIR
	cd $BUILD_DIR
fi

# ===== begin installation =====

# install freetype
echo 'installing freetype'
if [ -d freetype-2.3.9 ]; then
	cd freetype-2.3.9
	make clean
else
	wget http://sourceforge.net/projects/freetype/files/freetype2/2.3.9/freetype-2.3.9.tar.gz/download -O- | tar xz
	cd freetype-2.3.9
fi
./configure --prefix=$PREFIX
make
make install
cd ..

# install libpng
echo 'installing libpng'
if [ -d libpng-1.2.40 ]; then
	cd libpng-1.2.40
	make clean
else
	wget http://downloads.sourceforge.net/project/libpng/00-libpng-stable/1.2.40/libpng-1.2.40.tar.gz?use_mirror=garr -O- | tar xj
	cd libpng-1.2.40
fi
./configure --prefix=$PREFIX
make
make install
cd ..

# install jpeg
echo 'installing jpeg'
if [ -d jpeg-7 ]; then
	cd jpeg-7
	make clean
else 
	wget http://www.ijg.org/files/jpegsrc.v7.tar.gz -O- | tar xz
	cd jpeg-7
	ln -sf `which glibtool` ./libtool
fi
export MACOSX_DEPLOYMENT_TARGET=10.5
./configure --enable-shared --prefix=$PREFIX
make
make install
cd ..

# install libtiff

echo 'installing tiff'
if [ -d tiff-3.8.2 ]; then
	cd tiff-3.8.2
	make clean
else
	wget http://dl.maptools.org/dl/libtiff/tiff-3.8.2.tar.gz -O- | tar xz
	cd tiff-3.8.2
fi
./configure --prefix=$PREFIX
make
make install
cd ..

# install libwmf
echo 'installing libwmf'
if [ -d libwmf-0.2.8.4 ]; then
	cd libwmf-0.2.8.4
	make clean
else
	wget http://sourceforge.net/projects/wvware/files/libwmf/0.2.8.4/libwmf-0.2.8.4.tar.gz/download -O- | tar xz
	cd libwmf-0.2.8.4
fi
./configure --prefix=$PREFIX --with-png=$PREFIX --with-jpeg=$PREFIX --with-freetype=$PREFIX
make
make install
cd ..

# install lcms
echo 'installing lcms'
if [ -d lcms-1.18 ]; then
	cd lcms-1.18
	make clean
else
	wget http://www.littlecms.com/lcms-1.18a.tar.gz -O- | tar xz
	cd lcms-1.18
fi
./configure --prefix=$PREFIX
make
make install
cd ..

# install ghostscript and fonts
echo 'installing ghostscript and ghostfonts'
if [ -d ghostscript-8.70 ]; then
	cd ghostscript-8.70
	make clean
else 
	wget http://ghostscript.com/releases/ghostscript-8.70.tar.gz -O- | tar xz
	cd ghostscript-8.70
fi
./configure --prefix=$PREFIX
make
make install
cd ..

if [ -d $PREFIX/share/ghostscript ]; then
	echo 'ghostscript fonts already exist'
else
	wget http://sourceforge.net/projects/gs-fonts/files/gs-fonts/8.11%20%28base%2035%2C%20GPL%29/ghostscript-fonts-std-8.11.tar.gz/download -O- | tar xz
	mv fonts $PREFIX/share/ghostscript
fi

# install ImageMagick
# note ImageMagick is compiled with  --disable-openmp to fix SEGFAULT in Snow Leopard
# you can remove this flag if compiling on Leopard
echo 'installing ImageMagick'
if [ -d ImageMagick-6.5.8-0 ]; then
	cd ImageMagick-6.5.8-0
	make clean
else
	wget http://image_magick.veidrodis.com/image_magick/ImageMagick-6.5.8-0.tar.gz -O- | tar xz
	cd ImageMagick-6.5.8-0
fi
export CPPFLAGS=-I$PREFIX/include
export LDFLAGS=-L$PREFIX/lib
./configure --prefix=$PREFIX --disable-static --with-modules --without-perl --without-magick-plus-plus --with-quantum-depth=8 --disable-openmp --with-gs-font-dir=$PREFIX/share/ghostscript/fonts
make
make install

rm ./libtool