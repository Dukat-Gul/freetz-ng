include $(TOOLCHAIN_DIR)/make/kernel/ccache/ccache.mk
include $(TOOLCHAIN_DIR)/make/target/ccache/ccache.mk
include $(TOOLCHAIN_DIR)/make/target/libtool-host/libtool-host.mk
include $(TOOLCHAIN_DIR)/make/target/uclibc/uclibc.mk

ifeq ($(strip $(FREETZ_TOOLCHAIN_CCACHE)),y)
	CCACHE:=ccache-kernel ccache
endif

KERNEL_TOOLCHAIN_MD5_mips_3.4.6:=039952c9f77f9b52b154033b867a635f
KERNEL_TOOLCHAIN_MD5_mips_4.4.6:=d1cec96dce042c3a445a4d388489490c
KERNEL_TOOLCHAIN_MD5_mipsel_3.4.6:=9f24808b8a9e83d55753a7a5a21866d0
KERNEL_TOOLCHAIN_MD5_mipsel_4.4.6:=6aa5a634d4c61987cf11f18c1cee6ae3
KERNEL_TOOLCHAIN_MD5:=$(KERNEL_TOOLCHAIN_MD5_$(TARGET_ARCH)_$(KERNEL_TOOLCHAIN_GCC_VERSION))

KERNEL_TOOLCHAIN_VERSION:=0.4
KERNEL_TOOLCHAIN_SOURCE:=$(TARGET_ARCH)_gcc-$(KERNEL_TOOLCHAIN_GCC_VERSION)-freetz-$(KERNEL_TOOLCHAIN_VERSION)-shared-glibc.tar.lzma

TARGET_TOOLCHAIN_MD5_mips_4.4.6_0.9.29:=e8b16c883b6197064633cc3a8cadb5b4
TARGET_TOOLCHAIN_MD5_mips_4.4.6_0.9.30.3:=34774a25d7742120721f7762ce84a923
TARGET_TOOLCHAIN_MD5_mips_4.5.3_0.9.31.1:=c0ee2424ff2f20e27b5b9fb408f7bd88
TARGET_TOOLCHAIN_MD5_mipsel_4.4.6_0.9.28:=d9b6fc886b0f73c2e953152456e96c71
TARGET_TOOLCHAIN_MD5_mipsel_4.4.6_0.9.29:=1cd835b09db755d01409b5618c457a70
TARGET_TOOLCHAIN_MD5_mipsel_4.5.3_0.9.31.1:=6c55b7d34a38583cb7bb4053ed5067d9
TARGET_TOOLCHAIN_MD5:=$(TARGET_TOOLCHAIN_MD5_$(TARGET_ARCH)_$(TARGET_TOOLCHAIN_GCC_VERSION)_$(TARGET_TOOLCHAIN_UCLIBC_VERSION))

TARGET_TOOLCHAIN_VERSION:=0.4
TARGET_TOOLCHAIN_SOURCE:=$(TARGET_ARCH)_gcc-$(TARGET_TOOLCHAIN_GCC_VERSION)_uClibc-$(TARGET_TOOLCHAIN_UCLIBC_VERSION)-freetz-$(TARGET_TOOLCHAIN_VERSION)-shared-glibc.tar.lzma

$(KERNEL_TOOLCHAIN_DIR):
	@mkdir -p $@

$(TARGET_TOOLCHAIN_DIR):
	@mkdir -p $@

$(DL_DIR)/$(KERNEL_TOOLCHAIN_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(KERNEL_TOOLCHAIN_SOURCE) "" $(KERNEL_TOOLCHAIN_MD5)

$(DL_DIR)/$(TARGET_TOOLCHAIN_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TARGET_TOOLCHAIN_SOURCE) "" $(TARGET_TOOLCHAIN_MD5)

download-toolchain: $(KERNEL_CROSS_COMPILER) kernel-configured \
			$(TARGET_CROSS_COMPILER) target-toolchain-kernel-headers \
			$(TARGET_SPECIFIC_ROOT_DIR)/lib/libc.so.0 \
			$(CCACHE) $(STDCXXLIB) $(TARGET_CXX_CROSS_COMPILER_SYMLINK_TIMESTAMP) libtool-host $(if $(FREETZ_PACKAGE_GDB_HOST),gdbhost)

gcc-kernel: $(KERNEL_CROSS_COMPILER)
$(KERNEL_CROSS_COMPILER): $(DL_DIR)/$(KERNEL_TOOLCHAIN_SOURCE) | \
		$(KERNEL_TOOLCHAIN_SYMLINK_DOT_FILE) $(TOOLS_DIR)/busybox
	mkdir -p $(TOOLCHAIN_DIR)/build
	$(RM) -r $(TOOLCHAIN_BUILD_DIR)/$(KERNEL_TOOLCHAIN_COMPILER)
	$(TOOLS_DIR)/busybox tar $(VERBOSE) -xaf $(DL_DIR)/$(KERNEL_TOOLCHAIN_SOURCE) -C $(TOOLCHAIN_DIR)/build
	@touch $@

gcc: $(TARGET_CROSS_COMPILER)
$(TARGET_CROSS_COMPILER): $(DL_DIR)/$(TARGET_TOOLCHAIN_SOURCE) | \
		$(TARGET_TOOLCHAIN_SYMLINK_DOT_FILE) $(TOOLS_DIR)/busybox
	mkdir -p $(TOOLCHAIN_DIR)/build
	$(RM) -r $(TOOLCHAIN_BUILD_DIR)/$(TARGET_TOOLCHAIN_COMPILER)
	$(TOOLS_DIR)/busybox tar $(VERBOSE) -xaf $(DL_DIR)/$(TARGET_TOOLCHAIN_SOURCE) -C $(TOOLCHAIN_DIR)/build
	@touch $@

download-toolchain-clean:

download-toolchain-dirclean: kernel-toolchain-dirclean target-toolchain-dirclean

download-toolchain-distclean: kernel-toolchain-distclean target-toolchain-distclean

kernel-toolchain-dirclean:

target-toolchain-dirclean:

.PHONY: gcc-kernel gcc
