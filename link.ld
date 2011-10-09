OUTPUT_FORMAT(elf64-x86-64)
ENTRY(boot32)
SECTIONS
{
    .text 0x100000 :
    {
        code = .;
        *(.text)
    }

    .data :
    {
        data = .;
        *(.data)
        *(.rodata)
    }

    .bss :
    {
    	. = ALIGN(4096);
        bss = .;
        *(.bss)
    }

    end = .;
}
