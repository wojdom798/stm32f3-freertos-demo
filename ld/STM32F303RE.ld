/* label for program's entry point */
ENTRY(reset_handler)

/* 
End of RAM -> start of the stack
64 Kb RAM for STM32F303RE
64 Kb RAM = 64 * 1024 = 65536 = 0x10000
(remaining 16 Kb for CCM RAM starting at address 0x08000000)
*/
_estack = 0x20010000;

/* always make sure to have a cusion of 1 Kb of RAM */
_min_leftover_ram = 0x400;


MEMORY
{
  FLASH ( rx )  : ORIGIN = 0x08000000, LENGTH = 512K
  RAM ( rxw )   : ORIGIN = 0x20000000, LENGTH = 64K
}


SECTIONS
{

  /* vector table at the beginning of the FLASH memory */
  .vector_table :
  {
    . = ALIGN(4);
    KEEP (*(.vector_table))
    . = ALIGN(4);
  } >FLASH

  /* the 'text' section contains the main program code */
  .text :
  {
    . = ALIGN(4);
    *(.text)
    *(.text*)
    . = ALIGN(4);
  } >FLASH

  /* read-only data -> constants */
  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)
    *(.rodata*)
    . = ALIGN(4);
  } >FLASH

  /* the 'data' section contains program variables */
  _sidata = .;
  .data : AT(_sidata)
  {
    . = ALIGN(4);
    _sdata = .;
    *(.data)
    *(.data*)
    _edata = .;
    . = ALIGN(4);
  } >RAM

  .bss :
  {
    . = ALIGN(4);
    _sbss = .;
    *(.bss)
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;
  } >RAM

  .dynamic_allocations :
  {
    . = ALIGN(4);
    _ssystem_ram = .;
    . = . + _min_leftover_ram;
    . = ALIGN(4);
    _esystem_ram = .;
  } >RAM

}