#!/bin/bash

##----------------------------------------------------------##
# Specify Kernel Directory
KERNEL_DIR="$(pwd)"

##----------------------------------------------------------##
# Device Name and Model
MODEL=POCO
DEVICE=gki

# Kernel Defconfig
DEFCONFIG=${DEVICE}_defconfig

export CROSS_COMPILE=$KERNEL_DIR/clang-r416183b/bin/aarch64-linux-gnu-
export CC=$KERNEL_DIR/clang-r416183b/bin/clang

export PATH=$KERNEL_DIR/clang-r416183b/bin:$PATH
export PATH=$KERNEL_DIR/build-tools/path/linux-x86:$PATH
export PATH=$KERNEL_DIR/gas/linux-x86:$PATH
export TARGET_SOC=s5e9925
export LLVM=1 LLVM_IAS=1
export ARCH=arm64
export KBUILD_BUILD_HOST=Pancali
export KBUILD_BUILD_USER="unknown"

IMAGE=$(pwd)/out/arch/arm64/boot/Image

KERNEL_MAKE_ENV="LOCALVERSION=-SUPER.KERNEL-Marble"

# Date and Time
DATE=$(TZ=Asia/Jakarta date +"%Y%m%d-%T")
# Specify Final Zip Name
ZIPNAME="SUPER.KERNEL-MARBLE-CLO-$(TZ=Asia/Jakarta date +"%Y%m%d-%H%M").zip"


clang(){
  if [ ! -d $KERNEL_DIR/clang-r416183b ]; then
    pause 'clone Android Clang/LLVM Prebuilts'
    git clone https://github.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-r416183b $KERNEL_DIR/clang-r416183b
  fi
}

gas(){
  if [ ! -d $KERNEL_DIR/gas/linux-x86 ]; then
    pause 'clone prebuilt binaries of GNU `as` (the assembler)'
    git clone https://android.googlesource.com/platform/prebuilts/gas/linux-x86 $KERNEL_DIR/gas/linux-x86
  fi
}

build_tools(){
  if [ ! -d $KERNEL_DIR/build-tools ]; then
    pause 'clone prebuilt binaries of build tools'
    git clone https://android.googlesource.com/platform/prebuilts/build-tools $KERNEL_DIR/build-tools
  fi
}

build_kernel(){

  echo "***** Compiling kernel *****"
  [ ! -d "out" ] && mkdir out
  make -j$(nproc) -C $(pwd) $KERNEL_MAKE_ENV ${DEFCONFIG}
  make -j$(nproc) -C $(pwd) $KERNEL_MAKE_ENV

}

anykernel3(){

cp $IMAGE AnyKernel3
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
