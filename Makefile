TARGET = main

# Define the linker script location and chip architecture.
LD_SCRIPT = STM32F303RE.ld
MCU_SPEC  = cortex-m4

# FreeRTOS Portable
FREERTOS_PORT_I = ./freertos/Source/portable/GCC/ARM_CM4F
FREERTOS_PORT_C = $(FREERTOS_PORT_I)/port.c

# Toolchain definitions (ARM bare metal defaults)
TOOLCHAIN = "D:\Program Files (x86)\GNU Arm Embedded Toolchain\9 2020-q2-update"
CC = $(TOOLCHAIN)/bin/arm-none-eabi-gcc
AS = $(TOOLCHAIN)/bin/arm-none-eabi-as
LD = $(TOOLCHAIN)/bin/arm-none-eabi-ld
OC = $(TOOLCHAIN)/bin/arm-none-eabi-objcopy
OD = $(TOOLCHAIN)/bin/arm-none-eabi-objdump
OS = $(TOOLCHAIN)/bin/arm-none-eabi-size

# Assembly directives.
ASFLAGS += -c
ASFLAGS += -O0
ASFLAGS += -mcpu=$(MCU_SPEC)
ASFLAGS += -mthumb
ASFLAGS += -Wall
# (Set error messages to appear on a single line.)
ASFLAGS += -fmessage-length=0

# C compilation directives
CFLAGS += -mcpu=$(MCU_SPEC)
CFLAGS += -mthumb
CFLAGS += -Wall
CFLAGS += -g
# (Set error messages to appear on a single line.)
CFLAGS += -fmessage-length=0
# (Set system to ignore semihosted junk)
CFLAGS += --specs=nosys.specs

CFLAGS += -mhard-float
CFLAGS += -mfloat-abi=hard
CFLAGS += -mfpu=fpv4-sp-d16

# Linker directives.
LSCRIPT = ./ld/$(LD_SCRIPT)
LFLAGS += -mcpu=$(MCU_SPEC)
LFLAGS += -mthumb
LFLAGS += -Wall
LFLAGS += --specs=nosys.specs
LFLAGS += -nostdlib
LFLAGS += -lgcc
LFLAGS += -T$(LSCRIPT)

LFLAGS += -mhard-float
LFLAGS += -mfloat-abi=hard
LFLAGS += -mfpu=fpv4-sp-d16

AS_SRC   =  ./src/startup_stm32f303retx.s
C_SRC    =  ./src/main.c
C_SRC		+=	$(FREERTOS_PORT_C)
C_SRC   += ./freertos/Source/list.c
C_SRC   += ./freertos/Source/tasks.c
C_SRC   += ./freertos/Source/queue.c

INCLUDE  =  -I./src
INCLUDE  += -I./device_headers
INCLUDE  += -I./freertos/Source/include
INCLUDE  += -I$(FREERTOS_PORT_I)

OBJS  = $(AS_SRC:.s=.o)
OBJS += $(C_SRC:.c=.o)

.PHONY: all
all: $(TARGET).bin

%.o: %.s
	$(CC) -x assembler-with-cpp $(ASFLAGS) $< -o $@

%.o: %.c
	$(CC) -c $(CFLAGS) $(INCLUDE) $< -o $@

$(TARGET).elf: $(OBJS)
	$(CC) $^ $(LFLAGS) -o $@

$(TARGET).bin: $(TARGET).elf
	$(OC) -S -O binary $< $@
	$(OS) $<

.PHONY: clean
clean:
	rm -f $(OBJS)
	rm -f $(TARGET).elf
	rm -f $(TARGET).bin