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
#         Component makefile for incorporating FreeRTOS into and application
#         based on the Texas Instruments SDK
#

# ==================================================
# Sanity Checks
# ==================================================

ifndef ARM_GCC_INSTALL_ROOT
$(error ENVIRONMENT ERROR: ARM_GCC_INSTALL_ROOT not set)
endif

ifndef CORESDK_INSTALL_DIR
$(error ENVIRONMENT ERROR: CORESDK_INSTALL_DIR not set)
endif

ifndef FREERTOS_ROOT
$(error ENVIRONMENT ERROR: FREERTOS_ROOT not set)
endif

ifndef SOC_FAMILY
$(error ENVIRONMENT ERROR: SOC_FAMILY not set)
endif

SOC_FAMILY_VALID = \
    cc13x2 \
    cc26x2

ifeq ($(filter $(SOC_FAMILY), $(SOC_FAMILY_VALID)),)
$(error ENVIRONMENT ERROR: SOC_FAMILY not set to a valid value [$(SOC_FAMILY_VALID)])
endif

# ==================================================
# General settings
# ==================================================

FREERTOS_OUTPUT_DIR = $(OUTPUT_DIR)/freertos_$(SOC_FAMILY)

# XXX: Seth CC13X2 specific FreeRTOS makefile and drivers
# Assumes GCC as the toolchain
CORESDK_FREERTOS_DIR = $(CORESDK_INSTALL_DIR)/kernel/freertos/builds/cc13x2_cc26x2/release/gcc
FREERTOS_LIB = $(CORESDK_FREERTOS_DIR)/freertos.lib
# am4fg is the extension for gcc build arm m4f drivers
DRIVERS_LIB = $(CORESDK_INSTALL_DIR)/source/ti/drivers/lib/gcc/m4f/drivers_$(SOC_FAMILY).a
DRIVER_LIB = $(CORESDK_INSTALL_DIR)/source/ti/devices/cc13x2_cc26x2/driverlib/bin/gcc/driverlib.lib
RFDRIVER_LIB = $(CORESDK_INSTALL_DIR)/source/ti/drivers/rf/lib/rf_multiMode_$(SOC_FAMILY).am4fg

STD_LDFLAGS += \
    -L$(FREERTOS_OUTPUT_DIR)

# moved to -app.mk to ensure link order
#STD_LIBS += \
#    -ldrivers \
#    -lfreertos \
#    -ldriverlib \
#    -lrf_multimode

STD_LINK_PREREQUISITES += \
    $(FREERTOS_OUTPUT_DIR)/libfreertos.a \
    $(FREERTOS_OUTPUT_DIR)/libdrivers.a \
    $(FREERTOS_OUTPUT_DIR)/libdriverlib.a \
    $(FREERTOS_OUTPUT_DIR)/librf_multiMode.a

STD_INC_DIRS += \
    $(FREERTOS_ROOT)/FreeRTOS/Source/include/ \
    $(FREERTOS_ROOT)/FreeRTOS/Source/portable/GCC/ARM_CM4F/ \
    $(CORESDK_INSTALL_DIR)/kernel/freertos/builds/cc13x2_cc26x2/release/ \
    $(CORESDK_INSTALL_DIR)/source/ \
    $(ARM_GCC_INSTALL_ROOT)/arm-none-eabi/include/newlib-nano \
    $(ARM_GCC_INSTALL_ROOT)/arm-none-eabi/include

# XXX: Seth, check TI-POSIX port availability
# TI-POSIX portability layer not included due to nlfaultinjection package
#   $(CORESDK_INSTALL_DIR)/source/ti/posix/gcc/ \
#   $(CORESDK_INSTALL_DIR)/source/ti/posix/freertos/
#

# XXX: Seth, have to disable static LwIP task creation because it is broken and we enable static construction
STD_DEFINES += \
    LWIP_FREERTOS_USE_STATIC_TCPIP_TASK=0

# Add FreeRTOSBuildRules to the list of late-bound build rules that will be
# evaluated when GenerateBuildRules is called.
LATE_BOUND_RULES += FreeRTOSBuildRules

STD_COMPILE_PREREQUISITES += install-freertos

# ==================================================
# Rules for configuring, building and installing FreeRTOS from source.
# ==================================================

define FreeRTOSBuildRules

$(FREERTOS_LIB) :
	@echo "$(HDR_PREFIX)MAKE $(CORESDK_FREERTOS_DIR)"
	$(NO_ECHO)$(MAKE) -C $(CORESDK_FREERTOS_DIR)

# XXX: Seth, these copies look alot the same, automake rule?

# XXX: Seth We could probably avoid the copy and just link the libraries
$(FREERTOS_OUTPUT_DIR)/libfreertos.a : $(FREERTOS_LIB) $(FREERTOS_OUTPUT_DIR)
	@echo "$(HDR_PREFIX)CP $(FREERTOS_LIB)"
	$(NO_ECHO)cp $(FREERTOS_LIB) $(FREERTOS_OUTPUT_DIR)/libfreertos.a 

# XXX: Seth We could probably avoid the copy and just link the libraries
$(FREERTOS_OUTPUT_DIR)/libdrivers.a : $(DRIVERS_LIB) $(FREERTOS_OUTPUT_DIR)
	@echo "$(HDR_PREFIX)CP $(DRIVERS_LIB)"
	$(NO_ECHO)cp $(DRIVERS_LIB) $(FREERTOS_OUTPUT_DIR)/libdrivers.a 

# XXX: Seth We could probably avoid the copy and just link the libraries
$(FREERTOS_OUTPUT_DIR)/libdriverlib.a : $(DRIVER_LIB) $(FREERTOS_OUTPUT_DIR)
	@echo "$(HDR_PREFIX)CP $(DRIVER_LIB)"
	$(NO_ECHO)cp $(DRIVER_LIB) $(FREERTOS_OUTPUT_DIR)/libdriverlib.a 

# XXX: Seth We could probably avoid the copy and just link the libraries
$(FREERTOS_OUTPUT_DIR)/librf_multiMode.a : $(RFDRIVER_LIB) $(FREERTOS_OUTPUT_DIR)
	@echo "$(HDR_PREFIX)CP $(RFDRIVER_LIB)"
	$(NO_ECHO)cp $(RFDRIVER_LIB) $(FREERTOS_OUTPUT_DIR)/librf_multiMode.a 


.phony: $(FREERTOS_OUTPUT_DIR)
$(FREERTOS_OUTPUT_DIR) :
	@echo "$(HDR_PREFIX)MKDIR $@"
	$(NO_ECHO)mkdir -p $(FREERTOS_OUTPUT_DIR)

.phony: build-freertos
build-freertos : $(FREERTOS_OUTPUT_DIR)/libfreertos.a $(FREERTOS_OUTPUT_DIR)/libdrivers.a $(FREERTOS_OUTPUT_DIR)/libdriverlib.a $(FREERTOS_OUTPUT_DIR)/librf_multiMode.a

.phony: install-freertos
install-freertos :  build-freertos
	@echo "$(HDR_PREFIX)CP $(FREERTOS_OUTPUT_DIR)"
	$(NO_ECHO)cp -r $(FREERTOS_ROOT)/FreeRTOS/Source/include $(FREERTOS_OUTPUT_DIR)/

# export import.mak variables for the SimpleLink SDK
export SYSCONFIG_TOOL         = $(SYSCONFIG_INSTALL_DIR)/sysconfig_cli.sh
export FREERTOS_INSTALL_DIR   = $(FREERTOS_ROOT)
export GCC_ARMCOMPILER        = $(ARM_GCC_INSTALL_ROOT)

.phony: clean-freertos
clean-freertos :
	@echo "$(HDR_PREFIX)RM $(FREERTOS_OUTPUT_DIR)"
	$(NO_ECHO)rm -rf $(FREERTOS_OUTPUT_DIR)
	@echo "$(HDR_PREFIX)MAKE $(CORESDK_FREERTOS_DIR) clean"
	$(NO_ECHO)$(MAKE) -C $(CORESDK_FREERTOS_DIR) clean

clean:: clean-freertos

endef


# ==================================================
# FreeRTOS-specific help definitions
# ==================================================

define TargetHelp +=

  build-freertos        Build the FreeRTOS library.

  install-freertos      Install FreeRTOS library and headers in
                        build output directory for use by application.

  clean-freertos        Clean all build outputs produced by the FreeRTOS
                        build process.
endef

