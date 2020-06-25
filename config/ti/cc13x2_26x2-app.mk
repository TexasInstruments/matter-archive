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
#         Common makefile definitions for building applications based on the
#         Texas Instruments SDK
#


# ==================================================
# Sanity Checks
# ==================================================

ifndef ARM_GCC_INSTALL_ROOT
$(error ENVIRONMENT ERROR: ARM_GCC_INSTALL_ROOT not set)
endif


# ==================================================
# General definitions
# ==================================================

.DEFAULT_GOAL := all

APP_EXE = $(OUTPUT_DIR)/$(APP).out
APP_HEX = $(OUTPUT_DIR)/$(APP).hex

SRCS =
ALL_SRCS = $(SRCS) $(EXTRA_SRCS)
OBJS = $(foreach file,$(ALL_SRCS),$(call ObjFileName,$(file)))

OUTPUT_DIR = $(PROJECT_ROOT)/build
OBJS_DIR = $(OUTPUT_DIR)/objs
DEPS_DIR = $(OUTPUT_DIR)/deps

SOC_TUNE_FLAGS = \
    -mcpu=cortex-m4 \
    -march=armv7e-m \
    -mthumb \
    -mfloat-abi=hard \
    -mfpu=fpv4-sp-d16 \
    -mabi=aapcs

DEBUG_FLAGS = \
    -Os \
    -g3 \
    -gdwarf-3 \
    -gstrict-dwarf

# XXX: Seth can we get C specific compile options??
STD_CFLAGS = \
    $(SOC_TUNE_FLAGS) \
    $(DEBUG_FLAGS) \
    -fdata-sections \
    -ffunction-sections \
    -fno-builtin-malloc \
    -fno-common \
    -Wall \
    --specs=nano.specs \
    --specs=nosys.specs


STD_CXXFLAGS = \
    $(SOC_TUNE_FLAGS) \
    $(DEBUG_FLAGS) \
    -fno-rtti \
    -fno-exceptions \
    -fno-unwind-tables \
    -Wno-c++14-compat \
    -std=gnu++11

STD_ASFLAGS = \
    $(SOC_TUNE_FLAGS) \
    $(DEBUG_FLAGS) \
    -x assembler-with-cpp

STD_LDFLAGS = \
    $(SOC_TUNE_FLAGS) \
    $(DEBUG_FLAGS) \
    -fdata-sections \
    -ffunction-sections \
    -fno-builtin-malloc \
    -fno-common \
    -nostartfiles \
    -Wall \
    -Wl,--gc-sections \
    --specs=nano.specs \
    --specs=nosys.specs \
    -T$(LINKER_SCRIPT)

# XXX: Seth do we need C++ std libs?
STD_LIBS = \
    -ldrivers \
    -lfreertos \
    -ldriverlib \
    -lrf_multiMode \
    -lgcc \
    -lc \
    -lstdc++ \
    -lm \
    -lnosys

STD_INC_DIRS = 

# XXX: Seth, why do we have to define this??
STD_DEFINES = \
    HAVE_CONFIG_H

STD_COMPILE_PREREQUISITES = ti-sdk-check

STD_LINK_PREREQUISITES = ti-sdk-check

DEFINE_FLAGS = $(foreach def,$(STD_DEFINES) $(DEFINES),-D$(def))

INC_FLAGS = $(foreach dir,$(INC_DIRS) $(STD_INC_DIRS),-I$(dir))

# ==================================================
# Toolchain and external utilities / files
# ==================================================

# XXX: Seth does this have to be as exact here? do we need the gcc install root?
TARGET_TUPLE = arm-none-eabi

CC      = $(ARM_GCC_INSTALL_ROOT)/bin/$(TARGET_TUPLE)-gcc
CXX     = $(ARM_GCC_INSTALL_ROOT)/bin/$(TARGET_TUPLE)-c++
CPP     = $(ARM_GCC_INSTALL_ROOT)/bin/$(TARGET_TUPLE)-cpp
AS      = $(ARM_GCC_INSTALL_ROOT)/bin/$(TARGET_TUPLE)-as
AR      = $(ARM_GCC_INSTALL_ROOT)/bin/$(TARGET_TUPLE)-ar
LD      = $(ARM_GCC_INSTALL_ROOT)/bin/$(TARGET_TUPLE)-ld
NM      = $(ARM_GCC_INSTALL_ROOT)/bin/$(TARGET_TUPLE)-nm
OBJDUMP = $(ARM_GCC_INSTALL_ROOT)/bin/$(TARGET_TUPLE)-objdump
OBJCOPY = $(ARM_GCC_INSTALL_ROOT)/bin/$(TARGET_TUPLE)-objcopy
SIZE    = $(ARM_GCC_INSTALL_ROOT)/bin/$(TARGET_TUPLE)-size
RANLIB  = $(ARM_GCC_INSTALL_ROOT)/bin/$(TARGET_TUPLE)-ranlib

INSTALL = /usr/bin/install
INSTALLFLAGS = -C -v

ifneq (, $(shell which ccache))
CCACHE = ccache
endif


# ==================================================
# Build options
# ==================================================

DEBUG ?= 1
OPT ?= 1
VERBOSE ?= 0
MMD ?= 0

ifeq ($(VERBOSE),1)
  NO_ECHO :=
  HDR_PREFIX := ==================== 
else
  NO_ECHO := @
  HDR_PREFIX :=
endif

# ==================================================
# Utility definitions
# ==================================================

# Convert source file name to object file name
define ObjFileName
$(OBJS_DIR)/$(notdir $1).o 
endef

# Convert source file name to dependency file name
define DepFileName
$(DEPS_DIR)/$(notdir $1).d
endef

# Newline
define NL


endef


# ==================================================
# General build rules
# ==================================================

.PHONY : $(APP) clean help ti-sdk-check

# Convert executable to Intel hex format
%.hex : %.out
	$(NO_ECHO)$(OBJCOPY) -O ihex $< $@

# Clean build output
clean ::
	@echo "RM $(OUTPUT_DIR)"
	$(NO_ECHO)rm -rf $(OUTPUT_DIR)

# Print help
export HelpText
help :
	@echo "$${HelpText}"

# Verify the TI SDK is found and meets the required minimum version
# XXX: Seth update with TI SDK variables from the top of this makefile
ti-sdk-check :
	echo "TODO Seth, update this"


# ==================================================
# Late-bound rules for building the application
# ==================================================

define AppBuildRules

# Default all rule
all : $(APP)

# General target for building the application
$(APP) : $(APP_HEX)

# Rule to link the application executable
$(APP_EXE) : $(OBJS) $(STD_LINK_PREREQUISITES) | $(OUTPUT_DIR)
	@echo "$$(HDR_PREFIX)LD $$@"
	$(NO_ECHO)$$(CC) $$(STD_LDFLAGS) $$(LDFLAGS) $$(DEBUG_FLAGS) $$(OPT_FLAGS) -Wl,-Map=$$(@:.out=.map) $$(OBJS) -Wl,--start-group $$(LIBS) $$(STD_LIBS) -Wl,--end-group -o $$@
	$(NO_ECHO)$$(SIZE) $$@

# Individual build rules for each application source file
$(foreach file,$(filter %.c,$(ALL_SRCS)),$(call CCRule,$(file)))
$(foreach file,$(filter %.cpp,$(ALL_SRCS)),$(call CXXRule,$(file)))
$(foreach file,$(filter %.S,$(ALL_SRCS)),$(call ASRule,$(file)))
$(foreach file,$(filter %.s,$(ALL_SRCS)),$(call ASRule,$(file)))

# Rule to create the output directory / subdirectories
$(OUTPUT_DIR) $(OBJS_DIR) $(DEPS_DIR) :
	@echo "MKDIR $$@"
	$(NO_ECHO)mkdir -p "$$@"

# Include generated dependency files
include $$(wildcard $(DEPS_DIR)/*.d)

endef

# Generates late-bound rule for building an object file from a C file 
define CCRule
$(call DepFileName,$1) : ;
$(call ObjFileName,$1): $1 $(call DepFileName,$1) | $(OBJS_DIR) $(DEPS_DIR) $(STD_COMPILE_PREREQUISITES)
	@echo "$$(HDR_PREFIX)CC $1"
	$(NO_ECHO) $$(CCACHE) $$(CC) -c $$(STD_CFLAGS) $$(CFLAGS) $$(DEBUG_FLAGS) $$(OPT_FLAGS) $$(DEFINE_FLAGS) $$(INC_FLAGS) -MT $$@ -MMD -MP -MF $(call DepFileName,$1).tmp -o $$@ $1
	$(NO_ECHO)mv $(call DepFileName,$1).tmp $(call DepFileName,$1)
$(NL)
endef

# Generates late-bound rule for building an object file from a C++ file 
define CXXRule
$(call DepFileName,$1) : ;
$(call ObjFileName,$1): $1 $(call DepFileName,$1) | $(OBJS_DIR) $(DEPS_DIR) $(STD_COMPILE_PREREQUISITES)
	@echo "$$(HDR_PREFIX)CXX $1"
	$(NO_ECHO) $$(CCACHE) $$(CXX) -c $$(AUTODEP_FLAGS) $$(STD_CFLAGS) $$(CFLAGS) $$(STD_CXXFLAGS) $$(CXXFLAGS) $$(DEBUG_FLAGS) $$(OPT_FLAGS) $$(DEFINE_FLAGS) $$(INC_FLAGS) -MT $$@ -MMD -MP -MF $(call DepFileName,$1).tmp -o $$@ $1
	$(NO_ECHO)mv $(call DepFileName,$1).tmp $(call DepFileName,$1)
$(NL)
endef

# Generates late-bound rule for building an object file from an assembly file 
define ASRule
$(call ObjFileName,$1): $1 | $(OBJS_DIR) $(STD_COMPILE_PREREQUISITES)
	@echo "$$(HDR_PREFIX)AS $1"
	$(NO_ECHO)$$(CC) -c -x assembler-with-cpp $$(STD_ASFLAGS) $$(ASFLAGS) $$(DEBUG_FLAGS) $$(OPT_FLAGS) $$(DEFINE_FLAGS) $$(INC_FLAGS) -o $$@ $1
$(NL)
endef


# ==================================================
# Function for generating all late-bound rules
# ==================================================

# List of variables containing late-bound rules that should
# be evaluated when GenerateBuildRules is called.
LATE_BOUND_RULES = AppBuildRules

define GenerateBuildRules
$(foreach rule,$(LATE_BOUND_RULES),$(eval $($(rule))))
endef


# ==================================================
# Help Definitions
# ==================================================

# Desciptions of make targets
define TargetHelp
  all                   Build the $(APP) application.
  
  clean                 Clean all build outputs.
  
  help                  Print this help message.
endef

# Desciptions of build options
define OptionHelp
  VERBOSE=[1|0]         Show commands as they are being executed.
endef

# Overall help text
define HelpText
Makefile for building the $(APP) application.

Available targets:

$(TargetHelp)

Build options:

$(OptionHelp)

endef
