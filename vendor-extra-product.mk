#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

VENDOR_EXTRA_PATH := vendor/extra

VENDOR_EXTRA_TARGET_DEVICE := $(shell echo -n $(TARGET_PRODUCT) | sed -e 's/^[a-z]*_//g')

# Inherit vendor/extra configs
$(call inherit-product, $(VENDOR_EXTRA_PATH)/config/properties.mk)
$(call inherit-product, $(VENDOR_EXTRA_PATH)/config/security.mk)

# Inherit MiuiCamera Makefile
$(call inherit-product-if-exists, vendor/xiaomi/miuicamera-$(VENDOR_EXTRA_TARGET_DEVICE)/device.mk)

# Boot animation
TARGET_BOOTANIMATION_HALF_RES := true

# Bellis
PRODUCT_PACKAGES += \
    Bellis

# Init
PRODUCT_PACKAGES += \
    init.extra.rc

# Iperf3
PRODUCT_PACKAGES += \
    iperf3

# Kernel
OVERRIDE_ENABLE_UFFD_GC := true
PRODUCT_ENABLE_UFFD_GC := true

# Overlays
PRODUCT_PACKAGES += \
    FrameworkOverlayEXTRA \
    NfcOverlayEXTRA \
    SettingsOverlayEXTRA \
    SettingsProviderOverlayEXTRA \
    SimpleDeviceConfigOverlayEXTRA \
    SystemUIOverlayEXTRA \
    UpdaterOverlayEXTRA

ifneq ($(filter cerro dodge lisa nairo racer tiro venus,$(VENDOR_EXTRA_TARGET_DEVICE)),)
$(call soong_config_set,lineage_extra,product_has_nfc,true)
endif

# tinymix
PRODUCT_PACKAGES += \
    tinymix
