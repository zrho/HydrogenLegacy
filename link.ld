OUTPUT_FORMAT(elf64-x86-64)
ENTRY(boot32)
SECTIONS
{
	.bss 0x100000 :
    {
        bss = .;
        *(.bss)
    }

    .text :
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

    end = .;
}
