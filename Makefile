##########################################
# Project
##########################################

TARGET = secure-doorlock
BUILD_DIR = build

##########################################
# Toolchain
##########################################

CC = arm-none-eabi-gcc
CXX = arm-none-eabi-g++
AS = arm-none-eabi-as
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size

##########################################
# MCU and FPU
##########################################

CPU = -mcpu=cortex-m4
FPU = -mfpu=fpv4-sp-d16
FLOAT-ABI = -mfloat-abi=hard
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)

##########################################
# Paths
##########################################

CMSIS_DIR = app/Drivers/CMSIS
HAL_DIR = app/Drivers/STM32F4xx_HAL_Driver
FREERTOS_DIR = app/Middlewares/Third_Party/FreeRTOS
CORE_DIR = app/Core
USER_CPP_DIR = app/user_app
STARTUP_DIR = app/Startup

INCLUDES = \
  -I$(CMSIS_DIR)/Device/ST/STM32F4xx/Include \
  -I$(CMSIS_DIR)/Include \
  -I$(HAL_DIR)/Inc \
  -I$(CORE_DIR)/Inc \
  -I$(FREERTOS_DIR)/Source/include \
  -I$(FREERTOS_DIR)/Source/portable/GCC/ARM_CM4F \
  -I$(USER_CPP_DIR)

##########################################
# Sources
##########################################

C_SOURCES := \
  $(wildcard $(CORE_DIR)/Src/*.c) \
  $(wildcard $(HAL_DIR)/Src/*.c) \
  $(wildcard $(FREERTOS_DIR)/Source/*.c) \
  $(wildcard $(FREERTOS_DIR)/Source/portable/GCC/ARM_CM4F/*.c) \
  $(FREERTOS_DIR)/Source/portable/MemMang/heap_4.c

CPP_SOURCES := $(wildcard $(USER_CPP_DIR)/*.cpp)
ASM_SOURCES := $(wildcard $(STARTUP_DIR)/*.s)

##########################################
# Object generation
##########################################

C_OBJS = $(patsubst %.c, $(BUILD_DIR)/%.o, $(C_SOURCES))
CPP_OBJS = $(patsubst %.cpp, $(BUILD_DIR)/%.o, $(CPP_SOURCES))
ASM_OBJS = $(patsubst %.s, $(BUILD_DIR)/%.o, $(ASM_SOURCES))
OBJS = $(C_OBJS) $(CPP_OBJS) $(ASM_OBJS)

##########################################
# Compiler Flags
##########################################

CFLAGS = $(MCU) -Wall -O2 -ffunction-sections -fdata-sections -std=c99
CXXFLAGS = $(MCU) -Wall -O2 -ffunction-sections -fdata-sections -fno-exceptions -std=c++17
ASFLAGS = $(MCU)
LDFLAGS = $(MCU) -specs=nosys.specs -Wl,--gc-sections -T/C:/Projects/secure-doorlock/app/STM32F412ZGTX_FLASH.ld

##########################################
# Rules
##########################################

all: $(BUILD_DIR)/$(TARGET).elf

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) -c $< -o $@ $(CFLAGS) $(INCLUDES)

$(BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
	$(CXX) -c $< -o $@ $(CXXFLAGS) $(INCLUDES)

$(BUILD_DIR)/%.o: %.s
	@mkdir -p $(dir $@)
	$(AS) -c $< -o $@ $(ASFLAGS)

$(BUILD_DIR)/$(TARGET).elf: $(OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CXX) $(OBJS) -o $@ $(LDFLAGS)
	$(OBJCOPY) -O ihex $@ $(BUILD_DIR)/$(TARGET).hex
	$(OBJCOPY) -O binary $@ $(BUILD_DIR)/$(TARGET).bin
	$(SIZE) $@

clean:
	rm -rf $(BUILD_DIR)

flash: $(BUILD_DIR)/$(TARGET).elf
	st-flash write $(BUILD_DIR)/$(TARGET).bin 0x8000000

.PHONY: all clean flash
