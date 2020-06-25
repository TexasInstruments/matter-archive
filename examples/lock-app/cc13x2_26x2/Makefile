#
#   Copyright (c) 2020 Project CHIP Authors
#   Copyright (c) 2020 Texas Instruments Incorporated
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

# 
#   @file
#         Makefile for building the CHIP CC1352 Lock Example Application.
#

PROJECT_ROOT := $(realpath .)

# XXX: Seth, couldn't get the linked directory to work in Vagrant :(
CHIP_ROOT ?= $(realpath $(PROJECT_ROOT)/../../.. )
BUILD_SUPPORT_DIR = $(CHIP_ROOT)/config/ti

FREERTOS_ROOT           = $(HOME)/third_party/FreeRTOSv10.3.1
CORESDK_INSTALL_DIR     = $(HOME)/ti/simplelink_cc13x2_26x2_sdk_4_30_00_42_eng
SYSCONFIG_INSTALL_DIR   = $(HOME)/ti/sysconfig_1.6.0
ARM_GCC_INSTALL_ROOT    = $(HOME)/third_party/gcc-arm-none-eabi-9-2020-q2-update

ifndef BOARD
$(warning ENVIRONMENT WARNING: BOARD not set, defaulting to CC1352R1_LAUNCHXL)

BOARD = CC1352R1_LAUNCHXL
endif

BOARD_CC13X2 = \
    CC1352P1_LAUNCHXL \
    CC1352P_2_LAUNCHXL \
    CC1352P_4_LAUNCHXL \
    CC1352R1_LAUNCHXL

BOARD_CC26X2 = \
    CC2652RB_LAUNCHXL \
    CC26X2R1_LAUNCHXL

ifneq ($(filter $(BOARD), $(BOARD_CC13X2)),)
SOC_FAMILY  = cc13x2
DEFINES     = DeviceFamily_CC13X2
endif

ifneq ($(filter $(BOARD), $(BOARD_CC26X2)),)
SOC_FAMILY  = cc26x2
DEFINES     = DeviceFamily_CC26X2
endif

ifndef SOC_FAMILY
$(error ENVIRONMENT WARNING: SOC_FAMILY not set, BOARD was not set to a valid TI Development Kit)
endif


include $(BUILD_SUPPORT_DIR)/cc13x2_26x2-app.mk
include $(BUILD_SUPPORT_DIR)/cc13x2_26x2-chip.mk
include $(BUILD_SUPPORT_DIR)/cc13x2_26x2-freertos.mk

SYSCFG_OUTPUT_DIR = $(OUTPUT_DIR)/syscfg_$(BOARD)

APP = chip-$(BOARD)-lock-example

# XXX: do not release with these files, they are for building
# mbedtls_stubs.c
# nv/crc.c
# nv/nvocmp.c

APP_SRCS = \
    $(PROJECT_ROOT)/main/main.cpp \
    $(PROJECT_ROOT)/main/AppTask.cpp \
    $(PROJECT_ROOT)/main/BoltLockManager.cpp \
    $(PROJECT_ROOT)/main/ZclCallbacks.cpp \
    $(PROJECT_ROOT)/freertos/gcc/CXXExceptionStubs.cpp \
    $(PROJECT_ROOT)/freertos/mbedtls_stubs.c \
    $(PROJECT_ROOT)/freertos/nv/crc.c \
    $(PROJECT_ROOT)/freertos/nv/nvocmp.c \
    $(CHIP_ROOT)/examples/common/chip-app-server/Server.cpp \
    $(CHIP_ROOT)/examples/common/chip-app-server/DataModelHandler.cpp \
    $(CHIP_ROOT)/src/app/util/af-event.cpp \
    $(CHIP_ROOT)/src/app/util/attribute-size.c \
    $(CHIP_ROOT)/src/app/util/attribute-storage.c \
    $(CHIP_ROOT)/src/app/util/attribute-table.c \
    $(CHIP_ROOT)/src/app/util/chip-response.cpp \
    $(CHIP_ROOT)/src/app/util/client-api.c \
    $(CHIP_ROOT)/src/app/util/ember-print.cpp \
    $(CHIP_ROOT)/src/app/util/message.c \
    $(CHIP_ROOT)/src/app/util/process-cluster-message.c \
    $(CHIP_ROOT)/src/app/util/process-global-message.c \
    $(CHIP_ROOT)/src/app/util/util.c \
    $(CHIP_ROOT)/src/app/clusters/on-off-server/on-off.c \
    $(CHIP_ROOT)/examples/lock-app/lock-common/gen/call-command-handler.c \
    $(CHIP_ROOT)/examples/lock-app/lock-common/gen/callback-stub.c \
    $(CHIP_ROOT)/examples/lock-app/lock-common/gen/znet-bookkeeping.c

SYSCFG_FILE = $(PROJECT_ROOT)/freertos/chip.syscfg
SYSCFG_SRCS = \
    $(SYSCFG_OUTPUT_DIR)/ti_devices_config.c \
    $(SYSCFG_OUTPUT_DIR)/ti_drivers_config.c \
    $(SYSCFG_OUTPUT_DIR)/ti_radio_config.c

SRCS = \
    $(APP_SRCS) \
    $(SYSCFG_SRCS)

INC_DIRS = \
    $(PROJECT_ROOT) \
    $(SYSCFG_OUTPUT_DIR) \
    $(PROJECT_ROOT)/main \
    $(PROJECT_ROOT)/main/include \
    $(CHIP_ROOT)/src/include \
    $(CHIP_ROOT)/src/lib \
    $(CHIP_ROOT)/src \
    $(CHIP_ROOT)/src/app/util \
    $(CHIP_ROOT)/src/system \
    $(CHIP_ROOT)/examples/common/chip-app-server/include \
    $(CHIP_ROOT)/examples/lock-app/lock-common

LIBS =

DEFINES += \
    MBEDTLS_CONFIG_FILE=\<cc13x2_26x2-mbedtls-config.h\> \
    NVOCMP_FREERTOS_MUTEX=1

ifdef DEVICE_FIRMWARE_REVISION
DEFINES += \
    CHIP_DEVICE_CONFIG_DEVICE_FIRMWARE_REVISION=\"$(DEVICE_FIRMWARE_REVISION)\"
endif

# A product's firmware usually comes with two build "flavors":
# 1) a "development" build which typically enables debugging artifacts along with logging,
# and disables security and optimizations and
# 2) a "release" build which targets end-user devices
# and disables debugging artifacts and logging, and enables security and optimizations.
#
# To facilitate supporting these two build flavors, the sample app source code supports
# the build configuration option BUILD_RELEASE. By default, BUILD_RELEASE is not defined
# and a development build is produced. If make is invoked with BUILD_RELEASE=1, then
# a "pseudo-release" build is produced.
#
# We say "pseudo-release" build because the sample app is never to be used as-is
# as the firmware for an end-user device. However, since real products may start off with
# the sample app source code, we show how the BUILD_RELEASE build configuration option
# can be used to produce two build flavors (development and release) of the firmware.
#
# IMPORTANT: By no means does the use of BUILD_RELEASE in the sample app cover all key aspects that
# one should be concerned with (e.g. security, performance) when targeting real world end-user
# devices. This is simply provided for guidance on how to support two build flavors.

ifdef BUILD_RELEASE
    DEFINES += BUILD_RELEASE=1
    # Disable Thread logging.
    CHIP_DEFINES += CHIP_CONFIG_LOG_LEVEL=OT_LOG_LEVEL_NONE
else
    DEFINES += BUILD_RELEASE=0
    # Increase Tread logging level to INFO.
    CHIP_DEFINES += CHIP_CONFIG_LOG_LEVEL=OT_LOG_LEVEL_INFO
endif

CHIP_PROJECT_CONFIG = $(PROJECT_ROOT)/main/include/CHIPProjectConfig.h

LINKER_SCRIPT = $(PROJECT_ROOT)/freertos/CC13X2_26X2_FREERTOS.lds

# XXX: Seth, move sysconfig to -app.mk ?
$(SYSCFG_OUTPUT_DIR) :
	@echo "$(HDR_PREFIX)MKDIR $@"
	$(NO_ECHO)mkdir -p $@

$(SYSCFG_OUTPUT_DIR)/chip.witness : $(SYSCFG_FILE) $(SYSCFG_OUTPUT_DIR)
	$(NO_ECHO)rm -f $(SYSCFG_OUTPUT_DIR)/chip.tmp
	$(NO_ECHO)touch $(SYSCFG_OUTPUT_DIR)/chip.tmp
	$(SYSCONFIG_INSTALL_DIR)/sysconfig_cli.sh -s $(CORESDK_INSTALL_DIR)/.metadata/product.json -o "$(SYSCFG_OUTPUT_DIR)" --compiler gcc --board /ti/boards/$(BOARD) "$(SYSCFG_FILE)"
	$(NO_ECHO)mv -f $(SYSCFG_OUTPUT_DIR)/chip.tmp $@

$(SYSCFG_SRCS) : $(SYSCFG_OUTPUT_DIR)/chip.witness

# Force syscfg to run before the other source files
$(APP_SRCS) : $(SYSCFG_OUTPUT_DIR)/chip.witness

$(call GenerateBuildRules)
