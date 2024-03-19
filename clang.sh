#!/bin/bash

##----------------------------------------------------------##
# Specify Kernel Directory
export KERNEL_DIR="$(pwd)"

git submodule update --init --recursive --remote

##----------------------------------------------------------##
# Device Name and Model
MODEL=POCO
DEVICE=gki

# Kernel Defconfig
export DEFCONFIG=gki_defconfig

export CROSS_COMPILE=$KERNEL_DIR/clang-r498229b/bin/aarch64-linux-gnu-
export CC=$KERNEL_DIR/clang-r498229b/bin/clang

export PATH=$KERNEL_DIR/clang-r498229b/bin:$PATH
export PATH=$KERNEL_DIR/build-tools/path/linux-x86:$PATH
export PATH=$KERNEL_DIR/gas/linux-x86:$PATH
export TARGET_SOC=s5e9925
export LLVM=1 LLVM_IAS=1
export ARCH=arm64
export KBUILD_BUILD_HOST=Pancali
export KBUILD_BUILD_USER="unknown"

IMAGE="$(pwd)/arch/arm64/boot/Image.gz"

export KERNEL_MAKE_ENV="LOCALVERSION=-SUPER.KERNEL-Marble"

# Date and Time
export DATE=$(TZ=Asia/Jakarta date +"%Y%m%d-%T")
# Specify Final Zip Name
export ZIPNAME="SUPER.KERNEL-MARBLE-(clang)-$(TZ=Asia/Jakarta date +"%Y%m%d-%H%M").zip"


clang(){
  if [ ! -d $KERNEL_DIR/clang-r498229b ]; then
  wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r498229b.tar.gz && mkdir clang-r498229b && tar -xzf clang-r498229b.tar.gz -C clang-r498229b/
  CLANG_VERSION=$(clang --version | grep version | sed "s|clang version ||")
  fi
}

gas(){
  if [ ! -d $KERNEL_DIR/gas/linux-x86 ]; then
    git clone https://android.googlesource.com/platform/prebuilts/gas/linux-x86 $KERNEL_DIR/gas/linux-x86
  fi
}

build_tools(){
  if [ ! -d $KERNEL_DIR/build-tools ]; then
    git clone https://android.googlesource.com/platform/prebuilts/build-tools $KERNEL_DIR/build-tools
  fi
}

build_kernel() {

  echo "***** Compiling kernel *****"
  [ ! -d "out" ] && mkdir out
  make -j$(nproc) -C $(pwd) $KERNEL_MAKE_ENV ${DEFCONFIG}
  make -j$(nproc) -C $(pwd) $KERNEL_MAKE_ENV

  echo "**** Verify Image.gz ****"
  ls $(pwd)/arch/arm64/boot/Image.gz

}

anykernel3() {

cp $(pwd)/arch/arm64/boot/Image.gz AnyKernel3
cd AnyKernel3 || exit 1
zip -r9 ${ZIPNAME} *
MD5CHECK=$(md5sum "$ZIPNAME" | cut -d' ' -f1)
echo "Zip: $ZIPNAME"
curl -T $ZIPNAME https://oshi.at
# curl --upload-file $ZIPNAME https://free.keep.sh
cd ..
    
}


# Run once
clang
gas
build_tools
build_kernel
anykernel3
