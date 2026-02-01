MEMORY
{
   BRAM (RWX) : ORIGIN = 0x0000, LENGTH = 0x0C00  /* 3kB RAM */
}
SECTIONS
{
    everything :
    {
	. = ALIGN(4);
	start.o (.text)
        *(.*)
    } >BRAM
}
