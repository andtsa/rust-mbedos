M_CRASH_DATA_RAM_SIZE = 0x100;
STACK_SIZE = 0x400;
MEMORY
{
    FLASH (rx) : ORIGIN = 0x8000000, LENGTH = 0x100000
    SRAM_DTC (xrw) : ORIGIN = (0x20000000 + (((180 * 4) + 7) & 0xFFFFFFF8)), LENGTH = (0x20000 - (((180 * 4) + 7) & 0xFFFFFFF8))
    SRAM (xrw) : ORIGIN = 0x24000000, LENGTH = 0x50000
    SRAM_LOWER (xrw) : ORIGIN = 0x30000000, LENGTH = 32K
    SRAM_UPPER (xrw) : ORIGIN = 0x38000000, LENGTH = 16K
    SRAM_ITC (xrw) : ORIGIN = 0x00000000, LENGTH = 64K
}
ENTRY(Reset_Handler)
SECTIONS
{
    .text :
    {
        KEEP(*(.isr_vector))
        *(.text*)
        KEEP(*(.init))
        KEEP(*(.fini))
        *crtbegin.o(.ctors)
        *crtbegin?.o(.ctors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
        *(SORT(.ctors.*))
        *(.ctors)
        *crtbegin.o(.dtors)
        *crtbegin?.o(.dtors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
        *(SORT(.dtors.*))
        *(.dtors)
        *(.rodata*)
        KEEP(*(.eh_frame*))
    } > FLASH
    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } > FLASH
    __exidx_start = .;
    .ARM.exidx :
    {
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > FLASH
    __exidx_end = .;
    __etext = .;
    _sidata = .;
    .crash_data_ram :
    {
        . = ALIGN(8);
        __CRASH_DATA_RAM__ = .;
        __CRASH_DATA_RAM_START__ = .;
        KEEP(*(.keep.crash_data_ram))
        *(.m_crash_data_ram)
        . += M_CRASH_DATA_RAM_SIZE;
        . = ALIGN(8);
        __CRASH_DATA_RAM_END__ = .;
    } > SRAM_UPPER
    .stack (NOLOAD):
    {
        __StackLimit = .;
        *(.stack*);
        . += STACK_SIZE - (. - __StackLimit);
    } > SRAM_DTC
    __StackTop = ADDR(.stack) + SIZEOF(.stack);
    _estack = __StackTop;
    __StackLimit = ADDR(.stack);
    PROVIDE(__stack = __StackTop);
    .heap_0 (COPY):
    {
        __mbed_sbrk_start_0 = .;
        . += (ORIGIN(SRAM_DTC) + LENGTH(SRAM_DTC) - .);
        __mbed_krbs_start_0 = .;
    } > SRAM_DTC
    ASSERT(__mbed_krbs_start_0 <= (ORIGIN(SRAM_DTC)+LENGTH(SRAM_DTC)), "Heap is too big for SRAM_DTC")
    .data : AT (__etext)
    {
        __data_start__ = .;
        _sdata = .;
        *(vtable)
        *(.data*)
        . = ALIGN(8);
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP(*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);
        . = ALIGN(8);
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array))
        PROVIDE_HIDDEN (__init_array_end = .);
        . = ALIGN(8);
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array))
        PROVIDE_HIDDEN (__fini_array_end = .);
        KEEP(*(.jcr*))
        . = ALIGN(8);
        __data_end__ = .;
        _edata = .;
    } > SRAM
    ASSERT(__data_end__ <= (ORIGIN(SRAM)+LENGTH(SRAM)), ".data is too big for SRAM")
    .uninitialized (NOLOAD):
    {
        . = ALIGN(32);
        __uninitialized_start = .;
        *(.uninitialized)
        KEEP(*(.keep.uninitialized))
        . = ALIGN(32);
        __uninitialized_end = .;
    } > SRAM
    .bss :
    {
        . = ALIGN(8);
        __bss_start__ = .;
        _sbss = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(8);
        __bss_end__ = .;
        _ebss = .;
    } > SRAM
    ASSERT(__bss_end__ <= (ORIGIN(SRAM)+LENGTH(SRAM)), "BSS is too big for SRAM")
    .heap (COPY):
    {
        __end__ = .;
        end = __end__;
        __mbed_sbrk_start = .;
        *(.heap*)
        . += (ORIGIN(SRAM) + LENGTH(SRAM) - .);
        __mbed_krbs_start = .;
        __HeapLimit = .;
    } > SRAM
    ASSERT(__HeapLimit <= (ORIGIN(SRAM)+LENGTH(SRAM)), "Heap is too big for SRAM")
}
