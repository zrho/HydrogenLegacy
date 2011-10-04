OUTPUT_FORMAT(elf64-x86-64)
ENTRY(boot32)
SECTIONS
{
    .text 0x100000 :
    {
        code = .; _code = .; __code = .;
        *(.multiboot)
        *(.text)
    }

    .data :
    {
        data = .; _data = .; __data = .;
        *(.data)
        *(.rodata)
        . = ALIGN(4096);
    }

    .bss :
    {
        bss = .; _bss = .; __bss = .;
        *(.bss)
    }

    end = .; _end = .; __end = .;
}
