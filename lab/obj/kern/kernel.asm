
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot On standard x86 PCs address 0x472 controls whether or not one does a cold or warm reboot. By writing 0x1234 to this address, the BIOS should do a warm reboot, and if zero is written to this address a cold reboot will occur.
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 50 11 00       	mov    $0x115000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax # 0x80001001
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax    #relocated address: 0xf010002f,%eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer #Code Breaks if paging is not enabled.
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp  
f0100034:	bc 00 50 11 f0       	mov    $0xf0115000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 90 79 11 f0       	mov    $0xf0117990,%eax
f010004b:	2d 00 73 11 f0       	sub    $0xf0117300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 73 11 f0       	push   $0xf0117300
f0100058:	e8 c9 31 00 00       	call   f0103226 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 85 04 00 00       	call   f01004e7 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 00 37 10 f0       	push   $0xf0103700
f010006f:	e8 c6 26 00 00       	call   f010273a <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 c1 0f 00 00       	call   f010103a <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 fe 06 00 00       	call   f0100784 <monitor>
f0100086:	83 c4 10             	add    $0x10,%esp
f0100089:	eb f1                	jmp    f010007c <i386_init+0x3c>

f010008b <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010008b:	55                   	push   %ebp
f010008c:	89 e5                	mov    %esp,%ebp
f010008e:	56                   	push   %esi
f010008f:	53                   	push   %ebx
f0100090:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100093:	83 3d 80 79 11 f0 00 	cmpl   $0x0,0xf0117980
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 80 79 11 f0    	mov    %esi,0xf0117980

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000a2:	fa                   	cli    
f01000a3:	fc                   	cld    

	va_start(ap, fmt);
f01000a4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a7:	83 ec 04             	sub    $0x4,%esp
f01000aa:	ff 75 0c             	pushl  0xc(%ebp)
f01000ad:	ff 75 08             	pushl  0x8(%ebp)
f01000b0:	68 1b 37 10 f0       	push   $0xf010371b
f01000b5:	e8 80 26 00 00       	call   f010273a <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 50 26 00 00       	call   f0102714 <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 e5 46 10 f0 	movl   $0xf01046e5,(%esp)
f01000cb:	e8 6a 26 00 00       	call   f010273a <cprintf>
	va_end(ap);
f01000d0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 a7 06 00 00       	call   f0100784 <monitor>
f01000dd:	83 c4 10             	add    $0x10,%esp
f01000e0:	eb f1                	jmp    f01000d3 <_panic+0x48>

f01000e2 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000e2:	55                   	push   %ebp
f01000e3:	89 e5                	mov    %esp,%ebp
f01000e5:	53                   	push   %ebx
f01000e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000e9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000ec:	ff 75 0c             	pushl  0xc(%ebp)
f01000ef:	ff 75 08             	pushl  0x8(%ebp)
f01000f2:	68 33 37 10 f0       	push   $0xf0103733
f01000f7:	e8 3e 26 00 00       	call   f010273a <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 0c 26 00 00       	call   f0102714 <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 e5 46 10 f0 	movl   $0xf01046e5,(%esp)
f010010f:	e8 26 26 00 00       	call   f010273a <cprintf>
	va_end(ap);
f0100114:	83 c4 10             	add    $0x10,%esp
}
f0100117:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010011a:	c9                   	leave  
f010011b:	c3                   	ret    

f010011c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010011c:	55                   	push   %ebp
f010011d:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010011f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100124:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100125:	a8 01                	test   $0x1,%al
f0100127:	74 08                	je     f0100131 <serial_proc_data+0x15>
f0100129:	b2 f8                	mov    $0xf8,%dl
f010012b:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010012c:	0f b6 c0             	movzbl %al,%eax
f010012f:	eb 05                	jmp    f0100136 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100131:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100136:	5d                   	pop    %ebp
f0100137:	c3                   	ret    

f0100138 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100138:	55                   	push   %ebp
f0100139:	89 e5                	mov    %esp,%ebp
f010013b:	53                   	push   %ebx
f010013c:	83 ec 04             	sub    $0x4,%esp
f010013f:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100141:	eb 2a                	jmp    f010016d <cons_intr+0x35>
		if (c == 0)
f0100143:	85 d2                	test   %edx,%edx
f0100145:	74 26                	je     f010016d <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f0100147:	a1 44 75 11 f0       	mov    0xf0117544,%eax
f010014c:	8d 48 01             	lea    0x1(%eax),%ecx
f010014f:	89 0d 44 75 11 f0    	mov    %ecx,0xf0117544
f0100155:	88 90 40 73 11 f0    	mov    %dl,-0xfee8cc0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f010015b:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100161:	75 0a                	jne    f010016d <cons_intr+0x35>
			cons.wpos = 0;
f0100163:	c7 05 44 75 11 f0 00 	movl   $0x0,0xf0117544
f010016a:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010016d:	ff d3                	call   *%ebx
f010016f:	89 c2                	mov    %eax,%edx
f0100171:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100174:	75 cd                	jne    f0100143 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100176:	83 c4 04             	add    $0x4,%esp
f0100179:	5b                   	pop    %ebx
f010017a:	5d                   	pop    %ebp
f010017b:	c3                   	ret    

f010017c <kbd_proc_data>:
f010017c:	ba 64 00 00 00       	mov    $0x64,%edx
f0100181:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100182:	a8 01                	test   $0x1,%al
f0100184:	0f 84 f0 00 00 00    	je     f010027a <kbd_proc_data+0xfe>
f010018a:	b2 60                	mov    $0x60,%dl
f010018c:	ec                   	in     (%dx),%al
f010018d:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010018f:	3c e0                	cmp    $0xe0,%al
f0100191:	75 0d                	jne    f01001a0 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f0100193:	83 0d 00 73 11 f0 40 	orl    $0x40,0xf0117300
		return 0;
f010019a:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010019f:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001a0:	55                   	push   %ebp
f01001a1:	89 e5                	mov    %esp,%ebp
f01001a3:	53                   	push   %ebx
f01001a4:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001a7:	84 c0                	test   %al,%al
f01001a9:	79 36                	jns    f01001e1 <kbd_proc_data+0x65>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001ab:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f01001b1:	89 cb                	mov    %ecx,%ebx
f01001b3:	83 e3 40             	and    $0x40,%ebx
f01001b6:	83 e0 7f             	and    $0x7f,%eax
f01001b9:	85 db                	test   %ebx,%ebx
f01001bb:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001be:	0f b6 d2             	movzbl %dl,%edx
f01001c1:	0f b6 82 c0 38 10 f0 	movzbl -0xfefc740(%edx),%eax
f01001c8:	83 c8 40             	or     $0x40,%eax
f01001cb:	0f b6 c0             	movzbl %al,%eax
f01001ce:	f7 d0                	not    %eax
f01001d0:	21 c8                	and    %ecx,%eax
f01001d2:	a3 00 73 11 f0       	mov    %eax,0xf0117300
		return 0;
f01001d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01001dc:	e9 a1 00 00 00       	jmp    f0100282 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f01001e1:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f01001e7:	f6 c1 40             	test   $0x40,%cl
f01001ea:	74 0e                	je     f01001fa <kbd_proc_data+0x7e>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001ec:	83 c8 80             	or     $0xffffff80,%eax
f01001ef:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001f1:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001f4:	89 0d 00 73 11 f0    	mov    %ecx,0xf0117300
	}

	shift |= shiftcode[data];
f01001fa:	0f b6 c2             	movzbl %dl,%eax
f01001fd:	0f b6 90 c0 38 10 f0 	movzbl -0xfefc740(%eax),%edx
f0100204:	0b 15 00 73 11 f0    	or     0xf0117300,%edx
	shift ^= togglecode[data];
f010020a:	0f b6 88 c0 37 10 f0 	movzbl -0xfefc840(%eax),%ecx
f0100211:	31 ca                	xor    %ecx,%edx
f0100213:	89 15 00 73 11 f0    	mov    %edx,0xf0117300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100219:	89 d1                	mov    %edx,%ecx
f010021b:	83 e1 03             	and    $0x3,%ecx
f010021e:	8b 0c 8d 80 37 10 f0 	mov    -0xfefc880(,%ecx,4),%ecx
f0100225:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
f0100229:	0f b6 d8             	movzbl %al,%ebx
	if (shift & CAPSLOCK) {
f010022c:	f6 c2 08             	test   $0x8,%dl
f010022f:	74 1b                	je     f010024c <kbd_proc_data+0xd0>
		if ('a' <= c && c <= 'z')
f0100231:	89 d8                	mov    %ebx,%eax
f0100233:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100236:	83 f9 19             	cmp    $0x19,%ecx
f0100239:	77 05                	ja     f0100240 <kbd_proc_data+0xc4>
			c += 'A' - 'a';
f010023b:	83 eb 20             	sub    $0x20,%ebx
f010023e:	eb 0c                	jmp    f010024c <kbd_proc_data+0xd0>
		else if ('A' <= c && c <= 'Z')
f0100240:	83 e8 41             	sub    $0x41,%eax
			c += 'a' - 'A';
f0100243:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100246:	83 f8 19             	cmp    $0x19,%eax
f0100249:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010024c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100252:	75 2c                	jne    f0100280 <kbd_proc_data+0x104>
f0100254:	f7 d2                	not    %edx
f0100256:	f6 c2 06             	test   $0x6,%dl
f0100259:	75 25                	jne    f0100280 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f010025b:	83 ec 0c             	sub    $0xc,%esp
f010025e:	68 4d 37 10 f0       	push   $0xf010374d
f0100263:	e8 d2 24 00 00       	call   f010273a <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100268:	ba 92 00 00 00       	mov    $0x92,%edx
f010026d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100272:	ee                   	out    %al,(%dx)
f0100273:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100276:	89 d8                	mov    %ebx,%eax
f0100278:	eb 08                	jmp    f0100282 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010027a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010027f:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100280:	89 d8                	mov    %ebx,%eax
}
f0100282:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100285:	c9                   	leave  
f0100286:	c3                   	ret    

f0100287 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100287:	55                   	push   %ebp
f0100288:	89 e5                	mov    %esp,%ebp
f010028a:	57                   	push   %edi
f010028b:	56                   	push   %esi
f010028c:	53                   	push   %ebx
f010028d:	83 ec 1c             	sub    $0x1c,%esp
f0100290:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100292:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100297:	be fd 03 00 00       	mov    $0x3fd,%esi
f010029c:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002a1:	eb 09                	jmp    f01002ac <cons_putc+0x25>
f01002a3:	89 ca                	mov    %ecx,%edx
f01002a5:	ec                   	in     (%dx),%al
f01002a6:	ec                   	in     (%dx),%al
f01002a7:	ec                   	in     (%dx),%al
f01002a8:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002a9:	83 c3 01             	add    $0x1,%ebx
f01002ac:	89 f2                	mov    %esi,%edx
f01002ae:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002af:	a8 20                	test   $0x20,%al
f01002b1:	75 08                	jne    f01002bb <cons_putc+0x34>
f01002b3:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002b9:	7e e8                	jle    f01002a3 <cons_putc+0x1c>
f01002bb:	89 f8                	mov    %edi,%eax
f01002bd:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002c0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002c5:	89 f8                	mov    %edi,%eax
f01002c7:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002c8:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002cd:	be 79 03 00 00       	mov    $0x379,%esi
f01002d2:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002d7:	eb 09                	jmp    f01002e2 <cons_putc+0x5b>
f01002d9:	89 ca                	mov    %ecx,%edx
f01002db:	ec                   	in     (%dx),%al
f01002dc:	ec                   	in     (%dx),%al
f01002dd:	ec                   	in     (%dx),%al
f01002de:	ec                   	in     (%dx),%al
f01002df:	83 c3 01             	add    $0x1,%ebx
f01002e2:	89 f2                	mov    %esi,%edx
f01002e4:	ec                   	in     (%dx),%al
f01002e5:	84 c0                	test   %al,%al
f01002e7:	78 08                	js     f01002f1 <cons_putc+0x6a>
f01002e9:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002ef:	7e e8                	jle    f01002d9 <cons_putc+0x52>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002f1:	ba 78 03 00 00       	mov    $0x378,%edx
f01002f6:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01002fa:	ee                   	out    %al,(%dx)
f01002fb:	b2 7a                	mov    $0x7a,%dl
f01002fd:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100302:	ee                   	out    %al,(%dx)
f0100303:	b8 08 00 00 00       	mov    $0x8,%eax
f0100308:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100309:	89 fa                	mov    %edi,%edx
f010030b:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100311:	89 f8                	mov    %edi,%eax
f0100313:	80 cc 07             	or     $0x7,%ah
f0100316:	85 d2                	test   %edx,%edx
f0100318:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010031b:	89 f8                	mov    %edi,%eax
f010031d:	0f b6 c0             	movzbl %al,%eax
f0100320:	83 f8 09             	cmp    $0x9,%eax
f0100323:	74 74                	je     f0100399 <cons_putc+0x112>
f0100325:	83 f8 09             	cmp    $0x9,%eax
f0100328:	7f 0a                	jg     f0100334 <cons_putc+0xad>
f010032a:	83 f8 08             	cmp    $0x8,%eax
f010032d:	74 14                	je     f0100343 <cons_putc+0xbc>
f010032f:	e9 99 00 00 00       	jmp    f01003cd <cons_putc+0x146>
f0100334:	83 f8 0a             	cmp    $0xa,%eax
f0100337:	74 3a                	je     f0100373 <cons_putc+0xec>
f0100339:	83 f8 0d             	cmp    $0xd,%eax
f010033c:	74 3d                	je     f010037b <cons_putc+0xf4>
f010033e:	e9 8a 00 00 00       	jmp    f01003cd <cons_putc+0x146>
	case '\b':
		if (crt_pos > 0) {
f0100343:	0f b7 05 48 75 11 f0 	movzwl 0xf0117548,%eax
f010034a:	66 85 c0             	test   %ax,%ax
f010034d:	0f 84 e6 00 00 00    	je     f0100439 <cons_putc+0x1b2>
			crt_pos--;
f0100353:	83 e8 01             	sub    $0x1,%eax
f0100356:	66 a3 48 75 11 f0    	mov    %ax,0xf0117548
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010035c:	0f b7 c0             	movzwl %ax,%eax
f010035f:	66 81 e7 00 ff       	and    $0xff00,%di
f0100364:	83 cf 20             	or     $0x20,%edi
f0100367:	8b 15 4c 75 11 f0    	mov    0xf011754c,%edx
f010036d:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100371:	eb 78                	jmp    f01003eb <cons_putc+0x164>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100373:	66 83 05 48 75 11 f0 	addw   $0x50,0xf0117548
f010037a:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010037b:	0f b7 05 48 75 11 f0 	movzwl 0xf0117548,%eax
f0100382:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100388:	c1 e8 16             	shr    $0x16,%eax
f010038b:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010038e:	c1 e0 04             	shl    $0x4,%eax
f0100391:	66 a3 48 75 11 f0    	mov    %ax,0xf0117548
f0100397:	eb 52                	jmp    f01003eb <cons_putc+0x164>
		break;
	case '\t':
		cons_putc(' ');
f0100399:	b8 20 00 00 00       	mov    $0x20,%eax
f010039e:	e8 e4 fe ff ff       	call   f0100287 <cons_putc>
		cons_putc(' ');
f01003a3:	b8 20 00 00 00       	mov    $0x20,%eax
f01003a8:	e8 da fe ff ff       	call   f0100287 <cons_putc>
		cons_putc(' ');
f01003ad:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b2:	e8 d0 fe ff ff       	call   f0100287 <cons_putc>
		cons_putc(' ');
f01003b7:	b8 20 00 00 00       	mov    $0x20,%eax
f01003bc:	e8 c6 fe ff ff       	call   f0100287 <cons_putc>
		cons_putc(' ');
f01003c1:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c6:	e8 bc fe ff ff       	call   f0100287 <cons_putc>
f01003cb:	eb 1e                	jmp    f01003eb <cons_putc+0x164>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003cd:	0f b7 05 48 75 11 f0 	movzwl 0xf0117548,%eax
f01003d4:	8d 50 01             	lea    0x1(%eax),%edx
f01003d7:	66 89 15 48 75 11 f0 	mov    %dx,0xf0117548
f01003de:	0f b7 c0             	movzwl %ax,%eax
f01003e1:	8b 15 4c 75 11 f0    	mov    0xf011754c,%edx
f01003e7:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003eb:	66 81 3d 48 75 11 f0 	cmpw   $0x7cf,0xf0117548
f01003f2:	cf 07 
f01003f4:	76 43                	jbe    f0100439 <cons_putc+0x1b2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01003f6:	a1 4c 75 11 f0       	mov    0xf011754c,%eax
f01003fb:	83 ec 04             	sub    $0x4,%esp
f01003fe:	68 00 0f 00 00       	push   $0xf00
f0100403:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100409:	52                   	push   %edx
f010040a:	50                   	push   %eax
f010040b:	e8 63 2e 00 00       	call   f0103273 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100410:	8b 15 4c 75 11 f0    	mov    0xf011754c,%edx
f0100416:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010041c:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100422:	83 c4 10             	add    $0x10,%esp
f0100425:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010042a:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010042d:	39 d0                	cmp    %edx,%eax
f010042f:	75 f4                	jne    f0100425 <cons_putc+0x19e>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100431:	66 83 2d 48 75 11 f0 	subw   $0x50,0xf0117548
f0100438:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100439:	8b 0d 50 75 11 f0    	mov    0xf0117550,%ecx
f010043f:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100444:	89 ca                	mov    %ecx,%edx
f0100446:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100447:	0f b7 1d 48 75 11 f0 	movzwl 0xf0117548,%ebx
f010044e:	8d 71 01             	lea    0x1(%ecx),%esi
f0100451:	89 d8                	mov    %ebx,%eax
f0100453:	66 c1 e8 08          	shr    $0x8,%ax
f0100457:	89 f2                	mov    %esi,%edx
f0100459:	ee                   	out    %al,(%dx)
f010045a:	b8 0f 00 00 00       	mov    $0xf,%eax
f010045f:	89 ca                	mov    %ecx,%edx
f0100461:	ee                   	out    %al,(%dx)
f0100462:	89 d8                	mov    %ebx,%eax
f0100464:	89 f2                	mov    %esi,%edx
f0100466:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100467:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010046a:	5b                   	pop    %ebx
f010046b:	5e                   	pop    %esi
f010046c:	5f                   	pop    %edi
f010046d:	5d                   	pop    %ebp
f010046e:	c3                   	ret    

f010046f <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f010046f:	80 3d 54 75 11 f0 00 	cmpb   $0x0,0xf0117554
f0100476:	74 11                	je     f0100489 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100478:	55                   	push   %ebp
f0100479:	89 e5                	mov    %esp,%ebp
f010047b:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f010047e:	b8 1c 01 10 f0       	mov    $0xf010011c,%eax
f0100483:	e8 b0 fc ff ff       	call   f0100138 <cons_intr>
}
f0100488:	c9                   	leave  
f0100489:	f3 c3                	repz ret 

f010048b <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010048b:	55                   	push   %ebp
f010048c:	89 e5                	mov    %esp,%ebp
f010048e:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100491:	b8 7c 01 10 f0       	mov    $0xf010017c,%eax
f0100496:	e8 9d fc ff ff       	call   f0100138 <cons_intr>
}
f010049b:	c9                   	leave  
f010049c:	c3                   	ret    

f010049d <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010049d:	55                   	push   %ebp
f010049e:	89 e5                	mov    %esp,%ebp
f01004a0:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004a3:	e8 c7 ff ff ff       	call   f010046f <serial_intr>
	kbd_intr();
f01004a8:	e8 de ff ff ff       	call   f010048b <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004ad:	a1 40 75 11 f0       	mov    0xf0117540,%eax
f01004b2:	3b 05 44 75 11 f0    	cmp    0xf0117544,%eax
f01004b8:	74 26                	je     f01004e0 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004ba:	8d 50 01             	lea    0x1(%eax),%edx
f01004bd:	89 15 40 75 11 f0    	mov    %edx,0xf0117540
f01004c3:	0f b6 88 40 73 11 f0 	movzbl -0xfee8cc0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004ca:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004cc:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004d2:	75 11                	jne    f01004e5 <cons_getc+0x48>
			cons.rpos = 0;
f01004d4:	c7 05 40 75 11 f0 00 	movl   $0x0,0xf0117540
f01004db:	00 00 00 
f01004de:	eb 05                	jmp    f01004e5 <cons_getc+0x48>
		return c;
	}
	return 0;
f01004e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004e5:	c9                   	leave  
f01004e6:	c3                   	ret    

f01004e7 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004e7:	55                   	push   %ebp
f01004e8:	89 e5                	mov    %esp,%ebp
f01004ea:	57                   	push   %edi
f01004eb:	56                   	push   %esi
f01004ec:	53                   	push   %ebx
f01004ed:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01004f0:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01004f7:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01004fe:	5a a5 
	if (*cp != 0xA55A) {
f0100500:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100507:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010050b:	74 11                	je     f010051e <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010050d:	c7 05 50 75 11 f0 b4 	movl   $0x3b4,0xf0117550
f0100514:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100517:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010051c:	eb 16                	jmp    f0100534 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010051e:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100525:	c7 05 50 75 11 f0 d4 	movl   $0x3d4,0xf0117550
f010052c:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010052f:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100534:	8b 3d 50 75 11 f0    	mov    0xf0117550,%edi
f010053a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010053f:	89 fa                	mov    %edi,%edx
f0100541:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100542:	8d 4f 01             	lea    0x1(%edi),%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100545:	89 ca                	mov    %ecx,%edx
f0100547:	ec                   	in     (%dx),%al
f0100548:	0f b6 c0             	movzbl %al,%eax
f010054b:	c1 e0 08             	shl    $0x8,%eax
f010054e:	89 c3                	mov    %eax,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100550:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100555:	89 fa                	mov    %edi,%edx
f0100557:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100558:	89 ca                	mov    %ecx,%edx
f010055a:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010055b:	89 35 4c 75 11 f0    	mov    %esi,0xf011754c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100561:	0f b6 c8             	movzbl %al,%ecx
f0100564:	89 d8                	mov    %ebx,%eax
f0100566:	09 c8                	or     %ecx,%eax

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100568:	66 a3 48 75 11 f0    	mov    %ax,0xf0117548
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010056e:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100573:	b8 00 00 00 00       	mov    $0x0,%eax
f0100578:	89 da                	mov    %ebx,%edx
f010057a:	ee                   	out    %al,(%dx)
f010057b:	b2 fb                	mov    $0xfb,%dl
f010057d:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100582:	ee                   	out    %al,(%dx)
f0100583:	be f8 03 00 00       	mov    $0x3f8,%esi
f0100588:	b8 0c 00 00 00       	mov    $0xc,%eax
f010058d:	89 f2                	mov    %esi,%edx
f010058f:	ee                   	out    %al,(%dx)
f0100590:	b2 f9                	mov    $0xf9,%dl
f0100592:	b8 00 00 00 00       	mov    $0x0,%eax
f0100597:	ee                   	out    %al,(%dx)
f0100598:	b2 fb                	mov    $0xfb,%dl
f010059a:	b8 03 00 00 00       	mov    $0x3,%eax
f010059f:	ee                   	out    %al,(%dx)
f01005a0:	b2 fc                	mov    $0xfc,%dl
f01005a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01005a7:	ee                   	out    %al,(%dx)
f01005a8:	b2 f9                	mov    $0xf9,%dl
f01005aa:	b8 01 00 00 00       	mov    $0x1,%eax
f01005af:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b0:	b2 fd                	mov    $0xfd,%dl
f01005b2:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005b3:	3c ff                	cmp    $0xff,%al
f01005b5:	0f 95 c1             	setne  %cl
f01005b8:	88 0d 54 75 11 f0    	mov    %cl,0xf0117554
f01005be:	89 da                	mov    %ebx,%edx
f01005c0:	ec                   	in     (%dx),%al
f01005c1:	89 f2                	mov    %esi,%edx
f01005c3:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005c4:	84 c9                	test   %cl,%cl
f01005c6:	75 10                	jne    f01005d8 <cons_init+0xf1>
		cprintf("Serial port does not exist!\n");
f01005c8:	83 ec 0c             	sub    $0xc,%esp
f01005cb:	68 59 37 10 f0       	push   $0xf0103759
f01005d0:	e8 65 21 00 00       	call   f010273a <cprintf>
f01005d5:	83 c4 10             	add    $0x10,%esp
}
f01005d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005db:	5b                   	pop    %ebx
f01005dc:	5e                   	pop    %esi
f01005dd:	5f                   	pop    %edi
f01005de:	5d                   	pop    %ebp
f01005df:	c3                   	ret    

f01005e0 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005e0:	55                   	push   %ebp
f01005e1:	89 e5                	mov    %esp,%ebp
f01005e3:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01005e9:	e8 99 fc ff ff       	call   f0100287 <cons_putc>
}
f01005ee:	c9                   	leave  
f01005ef:	c3                   	ret    

f01005f0 <getchar>:

int
getchar(void)
{
f01005f0:	55                   	push   %ebp
f01005f1:	89 e5                	mov    %esp,%ebp
f01005f3:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01005f6:	e8 a2 fe ff ff       	call   f010049d <cons_getc>
f01005fb:	85 c0                	test   %eax,%eax
f01005fd:	74 f7                	je     f01005f6 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01005ff:	c9                   	leave  
f0100600:	c3                   	ret    

f0100601 <iscons>:

int
iscons(int fdnum)
{
f0100601:	55                   	push   %ebp
f0100602:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100604:	b8 01 00 00 00       	mov    $0x1,%eax
f0100609:	5d                   	pop    %ebp
f010060a:	c3                   	ret    

f010060b <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010060b:	55                   	push   %ebp
f010060c:	89 e5                	mov    %esp,%ebp
f010060e:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100611:	68 c0 39 10 f0       	push   $0xf01039c0
f0100616:	68 de 39 10 f0       	push   $0xf01039de
f010061b:	68 e3 39 10 f0       	push   $0xf01039e3
f0100620:	e8 15 21 00 00       	call   f010273a <cprintf>
f0100625:	83 c4 0c             	add    $0xc,%esp
f0100628:	68 98 3a 10 f0       	push   $0xf0103a98
f010062d:	68 ec 39 10 f0       	push   $0xf01039ec
f0100632:	68 e3 39 10 f0       	push   $0xf01039e3
f0100637:	e8 fe 20 00 00       	call   f010273a <cprintf>
f010063c:	83 c4 0c             	add    $0xc,%esp
f010063f:	68 f5 39 10 f0       	push   $0xf01039f5
f0100644:	68 0c 3a 10 f0       	push   $0xf0103a0c
f0100649:	68 e3 39 10 f0       	push   $0xf01039e3
f010064e:	e8 e7 20 00 00       	call   f010273a <cprintf>
	return 0;
}
f0100653:	b8 00 00 00 00       	mov    $0x0,%eax
f0100658:	c9                   	leave  
f0100659:	c3                   	ret    

f010065a <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010065a:	55                   	push   %ebp
f010065b:	89 e5                	mov    %esp,%ebp
f010065d:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100660:	68 16 3a 10 f0       	push   $0xf0103a16
f0100665:	e8 d0 20 00 00       	call   f010273a <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010066a:	83 c4 08             	add    $0x8,%esp
f010066d:	68 0c 00 10 00       	push   $0x10000c
f0100672:	68 c0 3a 10 f0       	push   $0xf0103ac0
f0100677:	e8 be 20 00 00       	call   f010273a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010067c:	83 c4 0c             	add    $0xc,%esp
f010067f:	68 0c 00 10 00       	push   $0x10000c
f0100684:	68 0c 00 10 f0       	push   $0xf010000c
f0100689:	68 e8 3a 10 f0       	push   $0xf0103ae8
f010068e:	e8 a7 20 00 00       	call   f010273a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100693:	83 c4 0c             	add    $0xc,%esp
f0100696:	68 d5 36 10 00       	push   $0x1036d5
f010069b:	68 d5 36 10 f0       	push   $0xf01036d5
f01006a0:	68 0c 3b 10 f0       	push   $0xf0103b0c
f01006a5:	e8 90 20 00 00       	call   f010273a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006aa:	83 c4 0c             	add    $0xc,%esp
f01006ad:	68 00 73 11 00       	push   $0x117300
f01006b2:	68 00 73 11 f0       	push   $0xf0117300
f01006b7:	68 30 3b 10 f0       	push   $0xf0103b30
f01006bc:	e8 79 20 00 00       	call   f010273a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006c1:	83 c4 0c             	add    $0xc,%esp
f01006c4:	68 90 79 11 00       	push   $0x117990
f01006c9:	68 90 79 11 f0       	push   $0xf0117990
f01006ce:	68 54 3b 10 f0       	push   $0xf0103b54
f01006d3:	e8 62 20 00 00       	call   f010273a <cprintf>
f01006d8:	b8 8f 7d 11 f0       	mov    $0xf0117d8f,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006dd:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006e2:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01006e5:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006ea:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006f0:	85 c0                	test   %eax,%eax
f01006f2:	0f 48 c2             	cmovs  %edx,%eax
f01006f5:	c1 f8 0a             	sar    $0xa,%eax
f01006f8:	50                   	push   %eax
f01006f9:	68 78 3b 10 f0       	push   $0xf0103b78
f01006fe:	e8 37 20 00 00       	call   f010273a <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100703:	b8 00 00 00 00       	mov    $0x0,%eax
f0100708:	c9                   	leave  
f0100709:	c3                   	ret    

f010070a <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010070a:	55                   	push   %ebp
f010070b:	89 e5                	mov    %esp,%ebp
f010070d:	56                   	push   %esi
f010070e:	53                   	push   %ebx
f010070f:	83 ec 2c             	sub    $0x2c,%esp
	// Your code here.
	uint32_t * ebp = (uint32_t *)read_ebp();
f0100712:	89 eb                	mov    %ebp,%ebx
	struct Eipdebuginfo info; 
	cprintf("\nStack backtrace:\n");
f0100714:	68 2f 3a 10 f0       	push   $0xf0103a2f
f0100719:	e8 1c 20 00 00       	call   f010273a <cprintf>
	for(;ebp>0x0;)
f010071e:	83 c4 10             	add    $0x10,%esp
	{
		cprintf("  ebp %08x  eip  %08x args %08x %08x %08x %08x %08x\n",ebp,ebp[1], ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
		debuginfo_eip(ebp[1],&info);
f0100721:	8d 75 e0             	lea    -0x20(%ebp),%esi
{
	// Your code here.
	uint32_t * ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info; 
	cprintf("\nStack backtrace:\n");
	for(;ebp>0x0;)
f0100724:	eb 4e                	jmp    f0100774 <mon_backtrace+0x6a>
	{
		cprintf("  ebp %08x  eip  %08x args %08x %08x %08x %08x %08x\n",ebp,ebp[1], ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
f0100726:	ff 73 18             	pushl  0x18(%ebx)
f0100729:	ff 73 14             	pushl  0x14(%ebx)
f010072c:	ff 73 10             	pushl  0x10(%ebx)
f010072f:	ff 73 0c             	pushl  0xc(%ebx)
f0100732:	ff 73 08             	pushl  0x8(%ebx)
f0100735:	ff 73 04             	pushl  0x4(%ebx)
f0100738:	53                   	push   %ebx
f0100739:	68 a4 3b 10 f0       	push   $0xf0103ba4
f010073e:	e8 f7 1f 00 00       	call   f010273a <cprintf>
		debuginfo_eip(ebp[1],&info);
f0100743:	83 c4 18             	add    $0x18,%esp
f0100746:	56                   	push   %esi
f0100747:	ff 73 04             	pushl  0x4(%ebx)
f010074a:	e8 01 21 00 00       	call   f0102850 <debuginfo_eip>
		cprintf("         %s:%d: %.*s+%u\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, ((uint32_t)ebp[1]-(uint32_t)(info.eip_fn_addr)));
f010074f:	83 c4 08             	add    $0x8,%esp
f0100752:	8b 43 04             	mov    0x4(%ebx),%eax
f0100755:	2b 45 f0             	sub    -0x10(%ebp),%eax
f0100758:	50                   	push   %eax
f0100759:	ff 75 e8             	pushl  -0x18(%ebp)
f010075c:	ff 75 ec             	pushl  -0x14(%ebp)
f010075f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100762:	ff 75 e0             	pushl  -0x20(%ebp)
f0100765:	68 42 3a 10 f0       	push   $0xf0103a42
f010076a:	e8 cb 1f 00 00       	call   f010273a <cprintf>
		ebp = (uint32_t *)*ebp;
f010076f:	8b 1b                	mov    (%ebx),%ebx
f0100771:	83 c4 20             	add    $0x20,%esp
{
	// Your code here.
	uint32_t * ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info; 
	cprintf("\nStack backtrace:\n");
	for(;ebp>0x0;)
f0100774:	85 db                	test   %ebx,%ebx
f0100776:	75 ae                	jne    f0100726 <mon_backtrace+0x1c>
		debuginfo_eip(ebp[1],&info);
		cprintf("         %s:%d: %.*s+%u\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, ((uint32_t)ebp[1]-(uint32_t)(info.eip_fn_addr)));
		ebp = (uint32_t *)*ebp;
	}
	return 0;
}
f0100778:	b8 00 00 00 00       	mov    $0x0,%eax
f010077d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100780:	5b                   	pop    %ebx
f0100781:	5e                   	pop    %esi
f0100782:	5d                   	pop    %ebp
f0100783:	c3                   	ret    

f0100784 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100784:	55                   	push   %ebp
f0100785:	89 e5                	mov    %esp,%ebp
f0100787:	57                   	push   %edi
f0100788:	56                   	push   %esi
f0100789:	53                   	push   %ebx
f010078a:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010078d:	68 dc 3b 10 f0       	push   $0xf0103bdc
f0100792:	e8 a3 1f 00 00       	call   f010273a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100797:	c7 04 24 00 3c 10 f0 	movl   $0xf0103c00,(%esp)
f010079e:	e8 97 1f 00 00       	call   f010273a <cprintf>
f01007a3:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01007a6:	83 ec 0c             	sub    $0xc,%esp
f01007a9:	68 5b 3a 10 f0       	push   $0xf0103a5b
f01007ae:	e8 1c 28 00 00       	call   f0102fcf <readline>
f01007b3:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007b5:	83 c4 10             	add    $0x10,%esp
f01007b8:	85 c0                	test   %eax,%eax
f01007ba:	74 ea                	je     f01007a6 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007bc:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007c3:	be 00 00 00 00       	mov    $0x0,%esi
f01007c8:	eb 0a                	jmp    f01007d4 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007ca:	c6 03 00             	movb   $0x0,(%ebx)
f01007cd:	89 f7                	mov    %esi,%edi
f01007cf:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01007d2:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007d4:	0f b6 03             	movzbl (%ebx),%eax
f01007d7:	84 c0                	test   %al,%al
f01007d9:	74 63                	je     f010083e <monitor+0xba>
f01007db:	83 ec 08             	sub    $0x8,%esp
f01007de:	0f be c0             	movsbl %al,%eax
f01007e1:	50                   	push   %eax
f01007e2:	68 5f 3a 10 f0       	push   $0xf0103a5f
f01007e7:	e8 fd 29 00 00       	call   f01031e9 <strchr>
f01007ec:	83 c4 10             	add    $0x10,%esp
f01007ef:	85 c0                	test   %eax,%eax
f01007f1:	75 d7                	jne    f01007ca <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f01007f3:	80 3b 00             	cmpb   $0x0,(%ebx)
f01007f6:	74 46                	je     f010083e <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01007f8:	83 fe 0f             	cmp    $0xf,%esi
f01007fb:	75 14                	jne    f0100811 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007fd:	83 ec 08             	sub    $0x8,%esp
f0100800:	6a 10                	push   $0x10
f0100802:	68 64 3a 10 f0       	push   $0xf0103a64
f0100807:	e8 2e 1f 00 00       	call   f010273a <cprintf>
f010080c:	83 c4 10             	add    $0x10,%esp
f010080f:	eb 95                	jmp    f01007a6 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100811:	8d 7e 01             	lea    0x1(%esi),%edi
f0100814:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100818:	eb 03                	jmp    f010081d <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010081a:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010081d:	0f b6 03             	movzbl (%ebx),%eax
f0100820:	84 c0                	test   %al,%al
f0100822:	74 ae                	je     f01007d2 <monitor+0x4e>
f0100824:	83 ec 08             	sub    $0x8,%esp
f0100827:	0f be c0             	movsbl %al,%eax
f010082a:	50                   	push   %eax
f010082b:	68 5f 3a 10 f0       	push   $0xf0103a5f
f0100830:	e8 b4 29 00 00       	call   f01031e9 <strchr>
f0100835:	83 c4 10             	add    $0x10,%esp
f0100838:	85 c0                	test   %eax,%eax
f010083a:	74 de                	je     f010081a <monitor+0x96>
f010083c:	eb 94                	jmp    f01007d2 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f010083e:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100845:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100846:	85 f6                	test   %esi,%esi
f0100848:	0f 84 58 ff ff ff    	je     f01007a6 <monitor+0x22>
f010084e:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100853:	83 ec 08             	sub    $0x8,%esp
f0100856:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100859:	ff 34 85 40 3c 10 f0 	pushl  -0xfefc3c0(,%eax,4)
f0100860:	ff 75 a8             	pushl  -0x58(%ebp)
f0100863:	e8 23 29 00 00       	call   f010318b <strcmp>
f0100868:	83 c4 10             	add    $0x10,%esp
f010086b:	85 c0                	test   %eax,%eax
f010086d:	75 22                	jne    f0100891 <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f010086f:	83 ec 04             	sub    $0x4,%esp
f0100872:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100875:	ff 75 08             	pushl  0x8(%ebp)
f0100878:	8d 55 a8             	lea    -0x58(%ebp),%edx
f010087b:	52                   	push   %edx
f010087c:	56                   	push   %esi
f010087d:	ff 14 85 48 3c 10 f0 	call   *-0xfefc3b8(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100884:	83 c4 10             	add    $0x10,%esp
f0100887:	85 c0                	test   %eax,%eax
f0100889:	0f 89 17 ff ff ff    	jns    f01007a6 <monitor+0x22>
f010088f:	eb 20                	jmp    f01008b1 <monitor+0x12d>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100891:	83 c3 01             	add    $0x1,%ebx
f0100894:	83 fb 03             	cmp    $0x3,%ebx
f0100897:	75 ba                	jne    f0100853 <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100899:	83 ec 08             	sub    $0x8,%esp
f010089c:	ff 75 a8             	pushl  -0x58(%ebp)
f010089f:	68 81 3a 10 f0       	push   $0xf0103a81
f01008a4:	e8 91 1e 00 00       	call   f010273a <cprintf>
f01008a9:	83 c4 10             	add    $0x10,%esp
f01008ac:	e9 f5 fe ff ff       	jmp    f01007a6 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008b4:	5b                   	pop    %ebx
f01008b5:	5e                   	pop    %esi
f01008b6:	5f                   	pop    %edi
f01008b7:	5d                   	pop    %ebp
f01008b8:	c3                   	ret    

f01008b9 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01008b9:	55                   	push   %ebp
f01008ba:	89 e5                	mov    %esp,%ebp
f01008bc:	57                   	push   %edi
f01008bd:	56                   	push   %esi
f01008be:	53                   	push   %ebx
f01008bf:	83 ec 1c             	sub    $0x1c,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01008c2:	83 3d 58 75 11 f0 00 	cmpl   $0x0,0xf0117558
f01008c9:	75 11                	jne    f01008dc <boot_alloc+0x23>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01008cb:	ba 8f 89 11 f0       	mov    $0xf011898f,%edx
f01008d0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01008d6:	89 15 58 75 11 f0    	mov    %edx,0xf0117558
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	//cprintf("\nBoot alloc_ next_free val:%x",nextfree);
	int i = n / PGSIZE;
f01008dc:	89 c3                	mov    %eax,%ebx
f01008de:	c1 eb 0c             	shr    $0xc,%ebx
	if(n%PGSIZE != 0 && i!=0)
f01008e1:	85 db                	test   %ebx,%ebx
f01008e3:	74 0e                	je     f01008f3 <boot_alloc+0x3a>
f01008e5:	a9 ff 0f 00 00       	test   $0xfff,%eax
f01008ea:	0f 95 c2             	setne  %dl
		i += 1;
f01008ed:	80 fa 01             	cmp    $0x1,%dl
f01008f0:	83 db ff             	sbb    $0xffffffff,%ebx
	int j;
	//cprintf("\nNext Address start:%p, Value of I:%d",nextfree,i);
	returnAddress = (void *)nextfree;
f01008f3:	8b 35 58 75 11 f0    	mov    0xf0117558,%esi
f01008f9:	89 f7                	mov    %esi,%edi
f01008fb:	89 75 e4             	mov    %esi,-0x1c(%ebp)
	if (n!=0)
f01008fe:	85 c0                	test   %eax,%eax
f0100900:	74 4b                	je     f010094d <boot_alloc+0x94>
	{
		for(j = 0; j < i; j++)
		{
			if((uint32_t)nextfree - KERNBASE > npages * PGSIZE)     // (npages * PGSIZE) corresponds to the available physical memory.
f0100902:	8b 35 84 79 11 f0    	mov    0xf0117984,%esi
f0100908:	c1 e6 0c             	shl    $0xc,%esi
f010090b:	89 f8                	mov    %edi,%eax
f010090d:	ba 00 00 00 00       	mov    $0x0,%edx
f0100912:	eb 2e                	jmp    f0100942 <boot_alloc+0x89>
f0100914:	8d 88 00 10 00 00    	lea    0x1000(%eax),%ecx
f010091a:	05 00 00 00 10       	add    $0x10000000,%eax
f010091f:	39 c6                	cmp    %eax,%esi
f0100921:	73 1a                	jae    f010093d <boot_alloc+0x84>
f0100923:	89 3d 58 75 11 f0    	mov    %edi,0xf0117558
			{
				panic("cannot allocate more memory...!!\n");
f0100929:	83 ec 04             	sub    $0x4,%esp
f010092c:	68 64 3c 10 f0       	push   $0xf0103c64
f0100931:	6a 73                	push   $0x73
f0100933:	68 34 44 10 f0       	push   $0xf0104434
f0100938:	e8 4e f7 ff ff       	call   f010008b <_panic>
	int j;
	//cprintf("\nNext Address start:%p, Value of I:%d",nextfree,i);
	returnAddress = (void *)nextfree;
	if (n!=0)
	{
		for(j = 0; j < i; j++)
f010093d:	83 c2 01             	add    $0x1,%edx
f0100940:	89 c8                	mov    %ecx,%eax
f0100942:	89 c7                	mov    %eax,%edi
f0100944:	39 d3                	cmp    %edx,%ebx
f0100946:	7f cc                	jg     f0100914 <boot_alloc+0x5b>
f0100948:	a3 58 75 11 f0       	mov    %eax,0xf0117558
		}
	}
	
	//cprintf("\nNext Address start after loop:%p\n",nextfree);
	return returnAddress;
}
f010094d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100950:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100953:	5b                   	pop    %ebx
f0100954:	5e                   	pop    %esi
f0100955:	5f                   	pop    %edi
f0100956:	5d                   	pop    %ebp
f0100957:	c3                   	ret    

f0100958 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100958:	89 d1                	mov    %edx,%ecx
f010095a:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f010095d:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100960:	a8 01                	test   $0x1,%al
f0100962:	74 52                	je     f01009b6 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100964:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100969:	89 c1                	mov    %eax,%ecx
f010096b:	c1 e9 0c             	shr    $0xc,%ecx
f010096e:	3b 0d 84 79 11 f0    	cmp    0xf0117984,%ecx
f0100974:	72 1b                	jb     f0100991 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100976:	55                   	push   %ebp
f0100977:	89 e5                	mov    %esp,%ebp
f0100979:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010097c:	50                   	push   %eax
f010097d:	68 88 3c 10 f0       	push   $0xf0103c88
f0100982:	68 35 03 00 00       	push   $0x335
f0100987:	68 34 44 10 f0       	push   $0xf0104434
f010098c:	e8 fa f6 ff ff       	call   f010008b <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100991:	c1 ea 0c             	shr    $0xc,%edx
f0100994:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010099a:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01009a1:	89 c2                	mov    %eax,%edx
f01009a3:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01009a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009ab:	85 d2                	test   %edx,%edx
f01009ad:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01009b2:	0f 44 c2             	cmove  %edx,%eax
f01009b5:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01009b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f01009bb:	c3                   	ret    

f01009bc <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01009bc:	55                   	push   %ebp
f01009bd:	89 e5                	mov    %esp,%ebp
f01009bf:	57                   	push   %edi
f01009c0:	56                   	push   %esi
f01009c1:	53                   	push   %ebx
f01009c2:	83 ec 3c             	sub    $0x3c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01009c5:	84 c0                	test   %al,%al
f01009c7:	0f 85 7a 02 00 00    	jne    f0100c47 <check_page_free_list+0x28b>
f01009cd:	e9 87 02 00 00       	jmp    f0100c59 <check_page_free_list+0x29d>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f01009d2:	83 ec 04             	sub    $0x4,%esp
f01009d5:	68 ac 3c 10 f0       	push   $0xf0103cac
f01009da:	68 78 02 00 00       	push   $0x278
f01009df:	68 34 44 10 f0       	push   $0xf0104434
f01009e4:	e8 a2 f6 ff ff       	call   f010008b <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01009e9:	8d 55 d8             	lea    -0x28(%ebp),%edx
f01009ec:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01009ef:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01009f2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01009f5:	89 c2                	mov    %eax,%edx
f01009f7:	2b 15 8c 79 11 f0    	sub    0xf011798c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01009fd:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a03:	0f 95 c2             	setne  %dl
f0100a06:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a09:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a0d:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a0f:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a13:	8b 00                	mov    (%eax),%eax
f0100a15:	85 c0                	test   %eax,%eax
f0100a17:	75 dc                	jne    f01009f5 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a1c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a22:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a25:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a28:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a2a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a2d:	a3 5c 75 11 f0       	mov    %eax,0xf011755c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a32:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a37:	8b 1d 5c 75 11 f0    	mov    0xf011755c,%ebx
f0100a3d:	eb 53                	jmp    f0100a92 <check_page_free_list+0xd6>
f0100a3f:	89 d8                	mov    %ebx,%eax
f0100a41:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f0100a47:	c1 f8 03             	sar    $0x3,%eax
f0100a4a:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a4d:	89 c2                	mov    %eax,%edx
f0100a4f:	c1 ea 16             	shr    $0x16,%edx
f0100a52:	39 f2                	cmp    %esi,%edx
f0100a54:	73 3a                	jae    f0100a90 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a56:	89 c2                	mov    %eax,%edx
f0100a58:	c1 ea 0c             	shr    $0xc,%edx
f0100a5b:	3b 15 84 79 11 f0    	cmp    0xf0117984,%edx
f0100a61:	72 12                	jb     f0100a75 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a63:	50                   	push   %eax
f0100a64:	68 88 3c 10 f0       	push   $0xf0103c88
f0100a69:	6a 52                	push   $0x52
f0100a6b:	68 40 44 10 f0       	push   $0xf0104440
f0100a70:	e8 16 f6 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100a75:	83 ec 04             	sub    $0x4,%esp
f0100a78:	68 80 00 00 00       	push   $0x80
f0100a7d:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100a82:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100a87:	50                   	push   %eax
f0100a88:	e8 99 27 00 00       	call   f0103226 <memset>
f0100a8d:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a90:	8b 1b                	mov    (%ebx),%ebx
f0100a92:	85 db                	test   %ebx,%ebx
f0100a94:	75 a9                	jne    f0100a3f <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100a96:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a9b:	e8 19 fe ff ff       	call   f01008b9 <boot_alloc>
f0100aa0:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100aa3:	8b 15 5c 75 11 f0    	mov    0xf011755c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100aa9:	8b 0d 8c 79 11 f0    	mov    0xf011798c,%ecx
		assert(pp < pages + npages);
f0100aaf:	a1 84 79 11 f0       	mov    0xf0117984,%eax
f0100ab4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100ab7:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100aba:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100abd:	be 00 00 00 00       	mov    $0x0,%esi
f0100ac2:	bf 00 00 00 00       	mov    $0x0,%edi
f0100ac7:	89 75 cc             	mov    %esi,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100aca:	e9 33 01 00 00       	jmp    f0100c02 <check_page_free_list+0x246>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100acf:	39 ca                	cmp    %ecx,%edx
f0100ad1:	73 19                	jae    f0100aec <check_page_free_list+0x130>
f0100ad3:	68 4e 44 10 f0       	push   $0xf010444e
f0100ad8:	68 5a 44 10 f0       	push   $0xf010445a
f0100add:	68 92 02 00 00       	push   $0x292
f0100ae2:	68 34 44 10 f0       	push   $0xf0104434
f0100ae7:	e8 9f f5 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100aec:	39 da                	cmp    %ebx,%edx
f0100aee:	72 19                	jb     f0100b09 <check_page_free_list+0x14d>
f0100af0:	68 6f 44 10 f0       	push   $0xf010446f
f0100af5:	68 5a 44 10 f0       	push   $0xf010445a
f0100afa:	68 93 02 00 00       	push   $0x293
f0100aff:	68 34 44 10 f0       	push   $0xf0104434
f0100b04:	e8 82 f5 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b09:	89 d0                	mov    %edx,%eax
f0100b0b:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b0e:	a8 07                	test   $0x7,%al
f0100b10:	74 19                	je     f0100b2b <check_page_free_list+0x16f>
f0100b12:	68 d0 3c 10 f0       	push   $0xf0103cd0
f0100b17:	68 5a 44 10 f0       	push   $0xf010445a
f0100b1c:	68 94 02 00 00       	push   $0x294
f0100b21:	68 34 44 10 f0       	push   $0xf0104434
f0100b26:	e8 60 f5 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b2b:	c1 f8 03             	sar    $0x3,%eax
f0100b2e:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b31:	85 c0                	test   %eax,%eax
f0100b33:	75 19                	jne    f0100b4e <check_page_free_list+0x192>
f0100b35:	68 83 44 10 f0       	push   $0xf0104483
f0100b3a:	68 5a 44 10 f0       	push   $0xf010445a
f0100b3f:	68 97 02 00 00       	push   $0x297
f0100b44:	68 34 44 10 f0       	push   $0xf0104434
f0100b49:	e8 3d f5 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b4e:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b53:	75 19                	jne    f0100b6e <check_page_free_list+0x1b2>
f0100b55:	68 94 44 10 f0       	push   $0xf0104494
f0100b5a:	68 5a 44 10 f0       	push   $0xf010445a
f0100b5f:	68 98 02 00 00       	push   $0x298
f0100b64:	68 34 44 10 f0       	push   $0xf0104434
f0100b69:	e8 1d f5 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100b6e:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100b73:	75 19                	jne    f0100b8e <check_page_free_list+0x1d2>
f0100b75:	68 04 3d 10 f0       	push   $0xf0103d04
f0100b7a:	68 5a 44 10 f0       	push   $0xf010445a
f0100b7f:	68 99 02 00 00       	push   $0x299
f0100b84:	68 34 44 10 f0       	push   $0xf0104434
f0100b89:	e8 fd f4 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100b8e:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100b93:	75 19                	jne    f0100bae <check_page_free_list+0x1f2>
f0100b95:	68 ad 44 10 f0       	push   $0xf01044ad
f0100b9a:	68 5a 44 10 f0       	push   $0xf010445a
f0100b9f:	68 9a 02 00 00       	push   $0x29a
f0100ba4:	68 34 44 10 f0       	push   $0xf0104434
f0100ba9:	e8 dd f4 ff ff       	call   f010008b <_panic>
f0100bae:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100bb1:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100bb6:	76 3f                	jbe    f0100bf7 <check_page_free_list+0x23b>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bb8:	89 c6                	mov    %eax,%esi
f0100bba:	c1 ee 0c             	shr    $0xc,%esi
f0100bbd:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f0100bc0:	77 12                	ja     f0100bd4 <check_page_free_list+0x218>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bc2:	50                   	push   %eax
f0100bc3:	68 88 3c 10 f0       	push   $0xf0103c88
f0100bc8:	6a 52                	push   $0x52
f0100bca:	68 40 44 10 f0       	push   $0xf0104440
f0100bcf:	e8 b7 f4 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0100bd4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bd9:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100bdc:	76 1e                	jbe    f0100bfc <check_page_free_list+0x240>
f0100bde:	68 28 3d 10 f0       	push   $0xf0103d28
f0100be3:	68 5a 44 10 f0       	push   $0xf010445a
f0100be8:	68 9b 02 00 00       	push   $0x29b
f0100bed:	68 34 44 10 f0       	push   $0xf0104434
f0100bf2:	e8 94 f4 ff ff       	call   f010008b <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100bf7:	83 c7 01             	add    $0x1,%edi
f0100bfa:	eb 04                	jmp    f0100c00 <check_page_free_list+0x244>
		else
			++nfree_extmem;
f0100bfc:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c00:	8b 12                	mov    (%edx),%edx
f0100c02:	85 d2                	test   %edx,%edx
f0100c04:	0f 85 c5 fe ff ff    	jne    f0100acf <check_page_free_list+0x113>
f0100c0a:	8b 75 cc             	mov    -0x34(%ebp),%esi
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100c0d:	85 ff                	test   %edi,%edi
f0100c0f:	7f 19                	jg     f0100c2a <check_page_free_list+0x26e>
f0100c11:	68 c7 44 10 f0       	push   $0xf01044c7
f0100c16:	68 5a 44 10 f0       	push   $0xf010445a
f0100c1b:	68 a3 02 00 00       	push   $0x2a3
f0100c20:	68 34 44 10 f0       	push   $0xf0104434
f0100c25:	e8 61 f4 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100c2a:	85 f6                	test   %esi,%esi
f0100c2c:	7f 42                	jg     f0100c70 <check_page_free_list+0x2b4>
f0100c2e:	68 d9 44 10 f0       	push   $0xf01044d9
f0100c33:	68 5a 44 10 f0       	push   $0xf010445a
f0100c38:	68 a4 02 00 00       	push   $0x2a4
f0100c3d:	68 34 44 10 f0       	push   $0xf0104434
f0100c42:	e8 44 f4 ff ff       	call   f010008b <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100c47:	a1 5c 75 11 f0       	mov    0xf011755c,%eax
f0100c4c:	85 c0                	test   %eax,%eax
f0100c4e:	0f 85 95 fd ff ff    	jne    f01009e9 <check_page_free_list+0x2d>
f0100c54:	e9 79 fd ff ff       	jmp    f01009d2 <check_page_free_list+0x16>
f0100c59:	83 3d 5c 75 11 f0 00 	cmpl   $0x0,0xf011755c
f0100c60:	0f 84 6c fd ff ff    	je     f01009d2 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c66:	be 00 04 00 00       	mov    $0x400,%esi
f0100c6b:	e9 c7 fd ff ff       	jmp    f0100a37 <check_page_free_list+0x7b>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100c70:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c73:	5b                   	pop    %ebx
f0100c74:	5e                   	pop    %esi
f0100c75:	5f                   	pop    %edi
f0100c76:	5d                   	pop    %ebp
f0100c77:	c3                   	ret    

f0100c78 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100c78:	55                   	push   %ebp
f0100c79:	89 e5                	mov    %esp,%ebp
f0100c7b:	56                   	push   %esi
f0100c7c:	53                   	push   %ebx
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	
	uint32_t pagesForKern = ((uint32_t)boot_alloc(0) - (KERNBASE + ONEMB)) / PGSIZE; 
f0100c7d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c82:	e8 32 fc ff ff       	call   f01008b9 <boot_alloc>
f0100c87:	8d 98 00 00 f0 0f    	lea    0xff00000(%eax),%ebx
f0100c8d:	c1 eb 0c             	shr    $0xc,%ebx
f0100c90:	8b 35 5c 75 11 f0    	mov    0xf011755c,%esi
	uint32_t pagesForIOHole = (uint32_t)(EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	uint32_t kernPagesStart = (uint32_t)(ONEMB) / PGSIZE;
	//cprintf("\nPages:%x",pages);
	for (i = 0; i < npages; i++)
f0100c96:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100c9b:	ba 00 00 00 00       	mov    $0x0,%edx
		{
			pages[i].pp_ref = 1;
			continue;
		}
		// Pages for kernel
		if(i >= kernPagesStart && i <= kernPagesStart+pagesForKern )
f0100ca0:	81 c3 00 01 00 00    	add    $0x100,%ebx
	
	uint32_t pagesForKern = ((uint32_t)boot_alloc(0) - (KERNBASE + ONEMB)) / PGSIZE; 
	uint32_t pagesForIOHole = (uint32_t)(EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	uint32_t kernPagesStart = (uint32_t)(ONEMB) / PGSIZE;
	//cprintf("\nPages:%x",pages);
	for (i = 0; i < npages; i++)
f0100ca6:	eb 62                	jmp    f0100d0a <page_init+0x92>
	{
		if(i==0)
f0100ca8:	85 d2                	test   %edx,%edx
f0100caa:	75 0d                	jne    f0100cb9 <page_init+0x41>
		{
			pages[i].pp_ref = 1;
f0100cac:	a1 8c 79 11 f0       	mov    0xf011798c,%eax
f0100cb1:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			continue;
f0100cb7:	eb 4b                	jmp    f0100d04 <page_init+0x8c>
f0100cb9:	8d 82 60 ff ff ff    	lea    -0xa0(%edx),%eax
		}
		// IO Hole
		if(i >= ((uint32_t)IOPHYSMEM / PGSIZE) && i < (((uint32_t)IOPHYSMEM / PGSIZE) + pagesForIOHole) )
f0100cbf:	83 f8 5f             	cmp    $0x5f,%eax
f0100cc2:	77 0e                	ja     f0100cd2 <page_init+0x5a>
		{
			pages[i].pp_ref = 1;
f0100cc4:	a1 8c 79 11 f0       	mov    0xf011798c,%eax
f0100cc9:	66 c7 44 08 04 01 00 	movw   $0x1,0x4(%eax,%ecx,1)
			continue;
f0100cd0:	eb 32                	jmp    f0100d04 <page_init+0x8c>
		}
		// Pages for kernel
		if(i >= kernPagesStart && i <= kernPagesStart+pagesForKern )
f0100cd2:	81 fa ff 00 00 00    	cmp    $0xff,%edx
f0100cd8:	76 12                	jbe    f0100cec <page_init+0x74>
f0100cda:	39 da                	cmp    %ebx,%edx
f0100cdc:	77 0e                	ja     f0100cec <page_init+0x74>
		{
			pages[i].pp_ref = 1;
f0100cde:	a1 8c 79 11 f0       	mov    0xf011798c,%eax
f0100ce3:	66 c7 44 08 04 01 00 	movw   $0x1,0x4(%eax,%ecx,1)
			continue;
f0100cea:	eb 18                	jmp    f0100d04 <page_init+0x8c>
		}
		
		
		pages[i].pp_ref = 0;
f0100cec:	89 c8                	mov    %ecx,%eax
f0100cee:	03 05 8c 79 11 f0    	add    0xf011798c,%eax
f0100cf4:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
		pages[i].pp_link = page_free_list;
f0100cfa:	89 30                	mov    %esi,(%eax)
		page_free_list = &pages[i];
f0100cfc:	89 ce                	mov    %ecx,%esi
f0100cfe:	03 35 8c 79 11 f0    	add    0xf011798c,%esi
	
	uint32_t pagesForKern = ((uint32_t)boot_alloc(0) - (KERNBASE + ONEMB)) / PGSIZE; 
	uint32_t pagesForIOHole = (uint32_t)(EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	uint32_t kernPagesStart = (uint32_t)(ONEMB) / PGSIZE;
	//cprintf("\nPages:%x",pages);
	for (i = 0; i < npages; i++)
f0100d04:	83 c2 01             	add    $0x1,%edx
f0100d07:	83 c1 08             	add    $0x8,%ecx
f0100d0a:	3b 15 84 79 11 f0    	cmp    0xf0117984,%edx
f0100d10:	72 96                	jb     f0100ca8 <page_init+0x30>
f0100d12:	89 35 5c 75 11 f0    	mov    %esi,0xf011755c
		
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100d18:	5b                   	pop    %ebx
f0100d19:	5e                   	pop    %esi
f0100d1a:	5d                   	pop    %ebp
f0100d1b:	c3                   	ret    

f0100d1c <page_alloc>:
//
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo * page_alloc(int alloc_flags)
{
f0100d1c:	55                   	push   %ebp
f0100d1d:	89 e5                	mov    %esp,%ebp
f0100d1f:	53                   	push   %ebx
f0100d20:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	struct PageInfo * left = page_free_list;
f0100d23:	8b 1d 5c 75 11 f0    	mov    0xf011755c,%ebx
	struct PageInfo * alloc = NULL;
	
	//cprintf("\nLeft: %p",left);
	if(left != 0x0)
f0100d29:	85 db                	test   %ebx,%ebx
f0100d2b:	74 5c                	je     f0100d89 <page_alloc+0x6d>
	{
		//cprintf("\nInside the if loop in alloc");
		page_free_list = left->pp_link;
f0100d2d:	8b 03                	mov    (%ebx),%eax
f0100d2f:	a3 5c 75 11 f0       	mov    %eax,0xf011755c
		left->pp_link = NULL;
f0100d34:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(alloc_flags & ALLOC_ZERO)
		{	
			memset(page2kva(left), 0, PGSIZE);
		}
		return left;	
f0100d3a:	89 d8                	mov    %ebx,%eax
	if(left != 0x0)
	{
		//cprintf("\nInside the if loop in alloc");
		page_free_list = left->pp_link;
		left->pp_link = NULL;
		if(alloc_flags & ALLOC_ZERO)
f0100d3c:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100d40:	74 4c                	je     f0100d8e <page_alloc+0x72>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d42:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f0100d48:	c1 f8 03             	sar    $0x3,%eax
f0100d4b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d4e:	89 c2                	mov    %eax,%edx
f0100d50:	c1 ea 0c             	shr    $0xc,%edx
f0100d53:	3b 15 84 79 11 f0    	cmp    0xf0117984,%edx
f0100d59:	72 12                	jb     f0100d6d <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d5b:	50                   	push   %eax
f0100d5c:	68 88 3c 10 f0       	push   $0xf0103c88
f0100d61:	6a 52                	push   $0x52
f0100d63:	68 40 44 10 f0       	push   $0xf0104440
f0100d68:	e8 1e f3 ff ff       	call   f010008b <_panic>
		{	
			memset(page2kva(left), 0, PGSIZE);
f0100d6d:	83 ec 04             	sub    $0x4,%esp
f0100d70:	68 00 10 00 00       	push   $0x1000
f0100d75:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100d77:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d7c:	50                   	push   %eax
f0100d7d:	e8 a4 24 00 00       	call   f0103226 <memset>
f0100d82:	83 c4 10             	add    $0x10,%esp
		}
		return left;	
f0100d85:	89 d8                	mov    %ebx,%eax
f0100d87:	eb 05                	jmp    f0100d8e <page_alloc+0x72>
	}
	else
	{
		//panic("Out of memory. ");
		//cprintf("\nalloc value: %p",alloc);
		return 0;
f0100d89:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//cprintf("\nalloc value: %p",alloc);
	//cprintf("\nValue of page_free: %p",page_free_list);
	
}
f0100d8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100d91:	c9                   	leave  
f0100d92:	c3                   	ret    

f0100d93 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100d93:	55                   	push   %ebp
f0100d94:	89 e5                	mov    %esp,%ebp
f0100d96:	83 ec 08             	sub    $0x8,%esp
f0100d99:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	//cprintf("\npp Value in page free:%p",pp);
	if(pp->pp_link != 0x0 || pp->pp_ref != 0)
f0100d9c:	83 38 00             	cmpl   $0x0,(%eax)
f0100d9f:	75 07                	jne    f0100da8 <page_free+0x15>
f0100da1:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100da6:	74 17                	je     f0100dbf <page_free+0x2c>
	{
		panic("\npp_ref or pp_link is non-zero");
f0100da8:	83 ec 04             	sub    $0x4,%esp
f0100dab:	68 70 3d 10 f0       	push   $0xf0103d70
f0100db0:	68 70 01 00 00       	push   $0x170
f0100db5:	68 34 44 10 f0       	push   $0xf0104434
f0100dba:	e8 cc f2 ff ff       	call   f010008b <_panic>
	}
	else
	{
		pp->pp_link = page_free_list;
f0100dbf:	8b 15 5c 75 11 f0    	mov    0xf011755c,%edx
f0100dc5:	89 10                	mov    %edx,(%eax)
		page_free_list = pp;
f0100dc7:	a3 5c 75 11 f0       	mov    %eax,0xf011755c
	}
}
f0100dcc:	c9                   	leave  
f0100dcd:	c3                   	ret    

f0100dce <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100dce:	55                   	push   %ebp
f0100dcf:	89 e5                	mov    %esp,%ebp
f0100dd1:	83 ec 08             	sub    $0x8,%esp
f0100dd4:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100dd7:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100ddb:	83 e8 01             	sub    $0x1,%eax
f0100dde:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100de2:	66 85 c0             	test   %ax,%ax
f0100de5:	75 0c                	jne    f0100df3 <page_decref+0x25>
		page_free(pp);
f0100de7:	83 ec 0c             	sub    $0xc,%esp
f0100dea:	52                   	push   %edx
f0100deb:	e8 a3 ff ff ff       	call   f0100d93 <page_free>
f0100df0:	83 c4 10             	add    $0x10,%esp
}
f0100df3:	c9                   	leave  
f0100df4:	c3                   	ret    

f0100df5 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100df5:	55                   	push   %ebp
f0100df6:	89 e5                	mov    %esp,%ebp
f0100df8:	56                   	push   %esi
f0100df9:	53                   	push   %ebx
f0100dfa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pde_t * pde = &pgdir[PDX(va)];
f0100dfd:	89 de                	mov    %ebx,%esi
f0100dff:	c1 ee 16             	shr    $0x16,%esi
f0100e02:	c1 e6 02             	shl    $0x2,%esi
f0100e05:	03 75 08             	add    0x8(%ebp),%esi
	pte_t * ptab;
	struct PageInfo * new_page;
	//cprintf("\nPDE Value:%x \nva value:%x\npgdir:%x\nvalue of Pde:%x",pde,va,pgdir,*pde);
	if(((*pde) & PTE_P)) //check if the page is present
f0100e08:	8b 16                	mov    (%esi),%edx
f0100e0a:	f6 c2 01             	test   $0x1,%dl
f0100e0d:	74 30                	je     f0100e3f <pgdir_walk+0x4a>
	{
		//cprintf("\nIn if");
		ptab = (pte_t *)KADDR(PTE_ADDR(*pde));  //get the virtual address of the page table start as we have to dereference it later.
f0100e0f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e15:	89 d0                	mov    %edx,%eax
f0100e17:	c1 e8 0c             	shr    $0xc,%eax
f0100e1a:	3b 05 84 79 11 f0    	cmp    0xf0117984,%eax
f0100e20:	72 15                	jb     f0100e37 <pgdir_walk+0x42>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e22:	52                   	push   %edx
f0100e23:	68 88 3c 10 f0       	push   $0xf0103c88
f0100e28:	68 a5 01 00 00       	push   $0x1a5
f0100e2d:	68 34 44 10 f0       	push   $0xf0104434
f0100e32:	e8 54 f2 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0100e37:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100e3d:	eb 5f                	jmp    f0100e9e <pgdir_walk+0xa9>
	}
	else
	{
		
		if(create)  //If page is not present and the caller wants to allocate a new page then
f0100e3f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100e43:	74 67                	je     f0100eac <pgdir_walk+0xb7>
		{
			//cprintf("\nIn create");
			new_page = page_alloc(1);
f0100e45:	83 ec 0c             	sub    $0xc,%esp
f0100e48:	6a 01                	push   $0x1
f0100e4a:	e8 cd fe ff ff       	call   f0100d1c <page_alloc>
			if(new_page == NULL)   //No free pages available
f0100e4f:	83 c4 10             	add    $0x10,%esp
f0100e52:	85 c0                	test   %eax,%eax
f0100e54:	74 5d                	je     f0100eb3 <pgdir_walk+0xbe>
				return NULL;
			else  //Page is available
			{
				new_page->pp_ref++;   //Increase the reference counter of the page.
f0100e56:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e5b:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f0100e61:	89 c2                	mov    %eax,%edx
f0100e63:	c1 fa 03             	sar    $0x3,%edx
f0100e66:	c1 e2 0c             	shl    $0xc,%edx
				//cprintf("\nNew_page physical value:%p\nnew page val:%p\npages:%p",page2pa(new_page),new_page,pages);
				*pde = page2pa(new_page) | PTE_P | PTE_W | PTE_U;   //Setup the permission bits. 
f0100e69:	89 d0                	mov    %edx,%eax
f0100e6b:	83 c8 07             	or     $0x7,%eax
f0100e6e:	89 06                	mov    %eax,(%esi)
				//cprintf("\n*pde:%p\nmanual page to pa:%x\ndifference:%u",
				//*pde,((new_page - pages)<<PGSHIFT),(new_page - pages));
				ptab = (pte_t *)KADDR(PTE_ADDR(*pde));
f0100e70:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e76:	89 d0                	mov    %edx,%eax
f0100e78:	c1 e8 0c             	shr    $0xc,%eax
f0100e7b:	3b 05 84 79 11 f0    	cmp    0xf0117984,%eax
f0100e81:	72 15                	jb     f0100e98 <pgdir_walk+0xa3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e83:	52                   	push   %edx
f0100e84:	68 88 3c 10 f0       	push   $0xf0103c88
f0100e89:	68 b7 01 00 00       	push   $0x1b7
f0100e8e:	68 34 44 10 f0       	push   $0xf0104434
f0100e93:	e8 f3 f1 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0100e98:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
			//cprintf("\nReturrning NULL");
			return NULL;	
		}
	}
	//cprintf("\nPTE Value at end:%p",&ptab[PTX(va)]);
	return &ptab[PTX(va)];
f0100e9e:	c1 eb 0a             	shr    $0xa,%ebx
f0100ea1:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100ea7:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f0100eaa:	eb 0c                	jmp    f0100eb8 <pgdir_walk+0xc3>
			}
		}
		else
		{
			//cprintf("\nReturrning NULL");
			return NULL;	
f0100eac:	b8 00 00 00 00       	mov    $0x0,%eax
f0100eb1:	eb 05                	jmp    f0100eb8 <pgdir_walk+0xc3>
		if(create)  //If page is not present and the caller wants to allocate a new page then
		{
			//cprintf("\nIn create");
			new_page = page_alloc(1);
			if(new_page == NULL)   //No free pages available
				return NULL;
f0100eb3:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;	
		}
	}
	//cprintf("\nPTE Value at end:%p",&ptab[PTX(va)]);
	return &ptab[PTX(va)];
}
f0100eb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ebb:	5b                   	pop    %ebx
f0100ebc:	5e                   	pop    %esi
f0100ebd:	5d                   	pop    %ebp
f0100ebe:	c3                   	ret    

f0100ebf <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100ebf:	55                   	push   %ebp
f0100ec0:	89 e5                	mov    %esp,%ebp
f0100ec2:	57                   	push   %edi
f0100ec3:	56                   	push   %esi
f0100ec4:	53                   	push   %ebx
f0100ec5:	83 ec 1c             	sub    $0x1c,%esp
f0100ec8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// Fill this function in
	//cprintf("\nVA:%x, PA:%x, size:%u",va,pa,size);
	uintptr_t tmpVa = va+size; 
f0100ecb:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
f0100ece:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	
	for(;va<tmpVa;)
f0100ed1:	89 d3                	mov    %edx,%ebx
f0100ed3:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100ed6:	29 d7                	sub    %edx,%edi
f0100ed8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100edb:	83 c8 01             	or     $0x1,%eax
f0100ede:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100ee1:	eb 3f                	jmp    f0100f22 <boot_map_region+0x63>
	{
		pte_t * pte = pgdir_walk(pgdir, (void *)va, true);
f0100ee3:	83 ec 04             	sub    $0x4,%esp
f0100ee6:	6a 01                	push   $0x1
f0100ee8:	53                   	push   %ebx
f0100ee9:	ff 75 e0             	pushl  -0x20(%ebp)
f0100eec:	e8 04 ff ff ff       	call   f0100df5 <pgdir_walk>
		if(pte == NULL)
f0100ef1:	83 c4 10             	add    $0x10,%esp
f0100ef4:	85 c0                	test   %eax,%eax
f0100ef6:	75 17                	jne    f0100f0f <boot_map_region+0x50>
			panic("Something bad happened in Bootmap region");
f0100ef8:	83 ec 04             	sub    $0x4,%esp
f0100efb:	68 90 3d 10 f0       	push   $0xf0103d90
f0100f00:	68 db 01 00 00       	push   $0x1db
f0100f05:	68 34 44 10 f0       	push   $0xf0104434
f0100f0a:	e8 7c f1 ff ff       	call   f010008b <_panic>
		else
		{
			*pte = pa | perm | PTE_P;
f0100f0f:	0b 75 dc             	or     -0x24(%ebp),%esi
f0100f12:	89 30                	mov    %esi,(%eax)
			//cprintf("\nValue of PTE in boot MAP:%x  diff of tmpVA:%p,  ",*pte, tmpVa-va);
			
			if(va >= 0xFFFFF000)			
f0100f14:	81 fb ff ef ff ff    	cmp    $0xffffefff,%ebx
f0100f1a:	77 0e                	ja     f0100f2a <boot_map_region+0x6b>
				break;
			va += PGSIZE;
f0100f1c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100f22:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
{
	// Fill this function in
	//cprintf("\nVA:%x, PA:%x, size:%u",va,pa,size);
	uintptr_t tmpVa = va+size; 
	
	for(;va<tmpVa;)
f0100f25:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0100f28:	72 b9                	jb     f0100ee3 <boot_map_region+0x24>
				break;
			va += PGSIZE;
			pa += PGSIZE;
		}
	}	
}
f0100f2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f2d:	5b                   	pop    %ebx
f0100f2e:	5e                   	pop    %esi
f0100f2f:	5f                   	pop    %edi
f0100f30:	5d                   	pop    %ebp
f0100f31:	c3                   	ret    

f0100f32 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f32:	55                   	push   %ebp
f0100f33:	89 e5                	mov    %esp,%ebp
f0100f35:	53                   	push   %ebx
f0100f36:	83 ec 08             	sub    $0x8,%esp
f0100f39:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t * pte = pgdir_walk(pgdir, va, false);
f0100f3c:	6a 00                	push   $0x0
f0100f3e:	ff 75 0c             	pushl  0xc(%ebp)
f0100f41:	ff 75 08             	pushl  0x8(%ebp)
f0100f44:	e8 ac fe ff ff       	call   f0100df5 <pgdir_walk>
	//cprintf("\nIn lookup pte value: %x",pte);
	if(pte == 0x0)
f0100f49:	83 c4 10             	add    $0x10,%esp
f0100f4c:	85 c0                	test   %eax,%eax
f0100f4e:	74 36                	je     f0100f86 <page_lookup+0x54>
	{
		return NULL;
	}
	else
	{
		if(pte_store != NULL)
f0100f50:	85 db                	test   %ebx,%ebx
f0100f52:	74 02                	je     f0100f56 <page_lookup+0x24>
			*pte_store = pte;
f0100f54:	89 03                	mov    %eax,(%ebx)
		if(PTE_P & * pte)
f0100f56:	8b 00                	mov    (%eax),%eax
f0100f58:	a8 01                	test   $0x1,%al
f0100f5a:	74 31                	je     f0100f8d <page_lookup+0x5b>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f5c:	c1 e8 0c             	shr    $0xc,%eax
f0100f5f:	3b 05 84 79 11 f0    	cmp    0xf0117984,%eax
f0100f65:	72 14                	jb     f0100f7b <page_lookup+0x49>
		panic("pa2page called with invalid pa");
f0100f67:	83 ec 04             	sub    $0x4,%esp
f0100f6a:	68 bc 3d 10 f0       	push   $0xf0103dbc
f0100f6f:	6a 4b                	push   $0x4b
f0100f71:	68 40 44 10 f0       	push   $0xf0104440
f0100f76:	e8 10 f1 ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f0100f7b:	8b 15 8c 79 11 f0    	mov    0xf011798c,%edx
f0100f81:	8d 04 c2             	lea    (%edx,%eax,8),%eax
		{
			//cprintf("\nvalue at PTE :%x",*pte);
			return pa2page(*pte);
f0100f84:	eb 0c                	jmp    f0100f92 <page_lookup+0x60>
	// Fill this function in
	pte_t * pte = pgdir_walk(pgdir, va, false);
	//cprintf("\nIn lookup pte value: %x",pte);
	if(pte == 0x0)
	{
		return NULL;
f0100f86:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f8b:	eb 05                	jmp    f0100f92 <page_lookup+0x60>
		{
			//cprintf("\nvalue at PTE :%x",*pte);
			return pa2page(*pte);
		}
	}
	return NULL;
f0100f8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100f92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f95:	c9                   	leave  
f0100f96:	c3                   	ret    

f0100f97 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100f97:	55                   	push   %ebp
f0100f98:	89 e5                	mov    %esp,%ebp
f0100f9a:	53                   	push   %ebx
f0100f9b:	83 ec 18             	sub    $0x18,%esp
f0100f9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t * pte;// = pgdir_walk(pgdir, va, false);
	struct PageInfo * ret = page_lookup(pgdir, va, &pte);
f0100fa1:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100fa4:	50                   	push   %eax
f0100fa5:	53                   	push   %ebx
f0100fa6:	ff 75 08             	pushl  0x8(%ebp)
f0100fa9:	e8 84 ff ff ff       	call   f0100f32 <page_lookup>
	if(ret == NULL)
f0100fae:	83 c4 10             	add    $0x10,%esp
f0100fb1:	85 c0                	test   %eax,%eax
f0100fb3:	74 18                	je     f0100fcd <page_remove+0x36>
		return;
	else
	{
		page_decref(ret);
f0100fb5:	83 ec 0c             	sub    $0xc,%esp
f0100fb8:	50                   	push   %eax
f0100fb9:	e8 10 fe ff ff       	call   f0100dce <page_decref>
		*pte = 0x0;
f0100fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100fc1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100fc7:	0f 01 3b             	invlpg (%ebx)
f0100fca:	83 c4 10             	add    $0x10,%esp
		tlb_invalidate(pgdir, va);
	}
	//cprintf("\nret value in ");
	
}
f0100fcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100fd0:	c9                   	leave  
f0100fd1:	c3                   	ret    

f0100fd2 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100fd2:	55                   	push   %ebp
f0100fd3:	89 e5                	mov    %esp,%ebp
f0100fd5:	57                   	push   %edi
f0100fd6:	56                   	push   %esi
f0100fd7:	53                   	push   %ebx
f0100fd8:	83 ec 10             	sub    $0x10,%esp
f0100fdb:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100fde:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	
	pte_t * pte = pgdir_walk(pgdir,va, true);
f0100fe1:	6a 01                	push   $0x1
f0100fe3:	57                   	push   %edi
f0100fe4:	ff 75 08             	pushl  0x8(%ebp)
f0100fe7:	e8 09 fe ff ff       	call   f0100df5 <pgdir_walk>
f0100fec:	89 c3                	mov    %eax,%ebx
	
	if(pte)
f0100fee:	83 c4 10             	add    $0x10,%esp
f0100ff1:	85 c0                	test   %eax,%eax
f0100ff3:	74 38                	je     f010102d <page_insert+0x5b>
	{		
		pp->pp_ref++; 
f0100ff5:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
		if(*pte & PTE_P)
f0100ffa:	f6 00 01             	testb  $0x1,(%eax)
f0100ffd:	74 0f                	je     f010100e <page_insert+0x3c>
		{
			page_remove(pgdir, va);
f0100fff:	83 ec 08             	sub    $0x8,%esp
f0101002:	57                   	push   %edi
f0101003:	ff 75 08             	pushl  0x8(%ebp)
f0101006:	e8 8c ff ff ff       	call   f0100f97 <page_remove>
f010100b:	83 c4 10             	add    $0x10,%esp
f010100e:	8b 55 14             	mov    0x14(%ebp),%edx
f0101011:	83 ca 01             	or     $0x1,%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101014:	89 f0                	mov    %esi,%eax
f0101016:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f010101c:	c1 f8 03             	sar    $0x3,%eax
		}
		*pte = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
f010101f:	c1 e0 0c             	shl    $0xc,%eax
f0101022:	09 d0                	or     %edx,%eax
f0101024:	89 03                	mov    %eax,(%ebx)
	}
	else
		return -E_NO_MEM;
	
	return 0;
f0101026:	b8 00 00 00 00       	mov    $0x0,%eax
f010102b:	eb 05                	jmp    f0101032 <page_insert+0x60>
			page_remove(pgdir, va);
		}
		*pte = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
	}
	else
		return -E_NO_MEM;
f010102d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	
	return 0;
}
f0101032:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101035:	5b                   	pop    %ebx
f0101036:	5e                   	pop    %esi
f0101037:	5f                   	pop    %edi
f0101038:	5d                   	pop    %ebp
f0101039:	c3                   	ret    

f010103a <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010103a:	55                   	push   %ebp
f010103b:	89 e5                	mov    %esp,%ebp
f010103d:	57                   	push   %edi
f010103e:	56                   	push   %esi
f010103f:	53                   	push   %ebx
f0101040:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101043:	6a 15                	push   $0x15
f0101045:	e8 8f 16 00 00       	call   f01026d9 <mc146818_read>
f010104a:	89 c3                	mov    %eax,%ebx
f010104c:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101053:	e8 81 16 00 00       	call   f01026d9 <mc146818_read>
f0101058:	c1 e0 08             	shl    $0x8,%eax
f010105b:	09 d8                	or     %ebx,%eax
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010105d:	c1 e0 0a             	shl    $0xa,%eax
f0101060:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101066:	85 c0                	test   %eax,%eax
f0101068:	0f 48 c2             	cmovs  %edx,%eax
f010106b:	c1 f8 0c             	sar    $0xc,%eax
f010106e:	a3 60 75 11 f0       	mov    %eax,0xf0117560
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101073:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f010107a:	e8 5a 16 00 00       	call   f01026d9 <mc146818_read>
f010107f:	89 c3                	mov    %eax,%ebx
f0101081:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101088:	e8 4c 16 00 00       	call   f01026d9 <mc146818_read>
f010108d:	c1 e0 08             	shl    $0x8,%eax
f0101090:	09 d8                	or     %ebx,%eax
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101092:	c1 e0 0a             	shl    $0xa,%eax
f0101095:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010109b:	83 c4 10             	add    $0x10,%esp
f010109e:	85 c0                	test   %eax,%eax
f01010a0:	0f 48 c2             	cmovs  %edx,%eax
f01010a3:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01010a6:	85 c0                	test   %eax,%eax
f01010a8:	74 0e                	je     f01010b8 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01010aa:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01010b0:	89 15 84 79 11 f0    	mov    %edx,0xf0117984
f01010b6:	eb 0c                	jmp    f01010c4 <mem_init+0x8a>
	else
		npages = npages_basemem;
f01010b8:	8b 15 60 75 11 f0    	mov    0xf0117560,%edx
f01010be:	89 15 84 79 11 f0    	mov    %edx,0xf0117984

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK npages:%u\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024),
f01010c4:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK npages:%u\n",
f01010c7:	c1 e8 0a             	shr    $0xa,%eax
f01010ca:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f01010cb:	a1 60 75 11 f0       	mov    0xf0117560,%eax
f01010d0:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK npages:%u\n",
f01010d3:	c1 e8 0a             	shr    $0xa,%eax
f01010d6:	50                   	push   %eax
		npages * PGSIZE / 1024,
f01010d7:	a1 84 79 11 f0       	mov    0xf0117984,%eax
f01010dc:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK npages:%u\n",
f01010df:	c1 e8 0a             	shr    $0xa,%eax
f01010e2:	50                   	push   %eax
f01010e3:	68 dc 3d 10 f0       	push   $0xf0103ddc
f01010e8:	e8 4d 16 00 00       	call   f010273a <cprintf>
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	//cprintf("\nnext_ptr 1:%x",boot_alloc(0));
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01010ed:	b8 00 10 00 00       	mov    $0x1000,%eax
f01010f2:	e8 c2 f7 ff ff       	call   f01008b9 <boot_alloc>
f01010f7:	a3 88 79 11 f0       	mov    %eax,0xf0117988
	memset(kern_pgdir, 0, PGSIZE);
f01010fc:	83 c4 0c             	add    $0xc,%esp
f01010ff:	68 00 10 00 00       	push   $0x1000
f0101104:	6a 00                	push   $0x0
f0101106:	50                   	push   %eax
f0101107:	e8 1a 21 00 00       	call   f0103226 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010110c:	a1 88 79 11 f0       	mov    0xf0117988,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101111:	83 c4 10             	add    $0x10,%esp
f0101114:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101119:	77 15                	ja     f0101130 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010111b:	50                   	push   %eax
f010111c:	68 24 3e 10 f0       	push   $0xf0103e24
f0101121:	68 a0 00 00 00       	push   $0xa0
f0101126:	68 34 44 10 f0       	push   $0xf0104434
f010112b:	e8 5b ef ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101130:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101136:	83 ca 05             	or     $0x5,%edx
f0101139:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	//cprintf("kern_pgdir[PDX(UCPT)]:%p, PDX[UVPT]:%u",kern_pgdir[PDX(UVPT)], ((((uintptr_t) (UVPT)) >> 22) & 0x3FF));
	pages = (struct PageInfo *) boot_alloc(npages*sizeof(struct PageInfo));
f010113f:	a1 84 79 11 f0       	mov    0xf0117984,%eax
f0101144:	c1 e0 03             	shl    $0x3,%eax
f0101147:	e8 6d f7 ff ff       	call   f01008b9 <boot_alloc>
f010114c:	a3 8c 79 11 f0       	mov    %eax,0xf011798c
	memset(pages, 0, npages*sizeof(struct PageInfo));
f0101151:	83 ec 04             	sub    $0x4,%esp
f0101154:	8b 0d 84 79 11 f0    	mov    0xf0117984,%ecx
f010115a:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101161:	52                   	push   %edx
f0101162:	6a 00                	push   $0x0
f0101164:	50                   	push   %eax
f0101165:	e8 bc 20 00 00       	call   f0103226 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010116a:	e8 09 fb ff ff       	call   f0100c78 <page_init>

	check_page_free_list(1);
f010116f:	b8 01 00 00 00       	mov    $0x1,%eax
f0101174:	e8 43 f8 ff ff       	call   f01009bc <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101179:	83 c4 10             	add    $0x10,%esp
f010117c:	83 3d 8c 79 11 f0 00 	cmpl   $0x0,0xf011798c
f0101183:	75 17                	jne    f010119c <mem_init+0x162>
		panic("'pages' is a null pointer!");
f0101185:	83 ec 04             	sub    $0x4,%esp
f0101188:	68 ea 44 10 f0       	push   $0xf01044ea
f010118d:	68 b5 02 00 00       	push   $0x2b5
f0101192:	68 34 44 10 f0       	push   $0xf0104434
f0101197:	e8 ef ee ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010119c:	a1 5c 75 11 f0       	mov    0xf011755c,%eax
f01011a1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01011a6:	eb 05                	jmp    f01011ad <mem_init+0x173>
		++nfree;
f01011a8:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01011ab:	8b 00                	mov    (%eax),%eax
f01011ad:	85 c0                	test   %eax,%eax
f01011af:	75 f7                	jne    f01011a8 <mem_init+0x16e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01011b1:	83 ec 0c             	sub    $0xc,%esp
f01011b4:	6a 00                	push   $0x0
f01011b6:	e8 61 fb ff ff       	call   f0100d1c <page_alloc>
f01011bb:	89 c7                	mov    %eax,%edi
f01011bd:	83 c4 10             	add    $0x10,%esp
f01011c0:	85 c0                	test   %eax,%eax
f01011c2:	75 19                	jne    f01011dd <mem_init+0x1a3>
f01011c4:	68 05 45 10 f0       	push   $0xf0104505
f01011c9:	68 5a 44 10 f0       	push   $0xf010445a
f01011ce:	68 bd 02 00 00       	push   $0x2bd
f01011d3:	68 34 44 10 f0       	push   $0xf0104434
f01011d8:	e8 ae ee ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01011dd:	83 ec 0c             	sub    $0xc,%esp
f01011e0:	6a 00                	push   $0x0
f01011e2:	e8 35 fb ff ff       	call   f0100d1c <page_alloc>
f01011e7:	89 c6                	mov    %eax,%esi
f01011e9:	83 c4 10             	add    $0x10,%esp
f01011ec:	85 c0                	test   %eax,%eax
f01011ee:	75 19                	jne    f0101209 <mem_init+0x1cf>
f01011f0:	68 1b 45 10 f0       	push   $0xf010451b
f01011f5:	68 5a 44 10 f0       	push   $0xf010445a
f01011fa:	68 be 02 00 00       	push   $0x2be
f01011ff:	68 34 44 10 f0       	push   $0xf0104434
f0101204:	e8 82 ee ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101209:	83 ec 0c             	sub    $0xc,%esp
f010120c:	6a 00                	push   $0x0
f010120e:	e8 09 fb ff ff       	call   f0100d1c <page_alloc>
f0101213:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101216:	83 c4 10             	add    $0x10,%esp
f0101219:	85 c0                	test   %eax,%eax
f010121b:	75 19                	jne    f0101236 <mem_init+0x1fc>
f010121d:	68 31 45 10 f0       	push   $0xf0104531
f0101222:	68 5a 44 10 f0       	push   $0xf010445a
f0101227:	68 bf 02 00 00       	push   $0x2bf
f010122c:	68 34 44 10 f0       	push   $0xf0104434
f0101231:	e8 55 ee ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101236:	39 f7                	cmp    %esi,%edi
f0101238:	75 19                	jne    f0101253 <mem_init+0x219>
f010123a:	68 47 45 10 f0       	push   $0xf0104547
f010123f:	68 5a 44 10 f0       	push   $0xf010445a
f0101244:	68 c2 02 00 00       	push   $0x2c2
f0101249:	68 34 44 10 f0       	push   $0xf0104434
f010124e:	e8 38 ee ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101253:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101256:	39 c7                	cmp    %eax,%edi
f0101258:	74 04                	je     f010125e <mem_init+0x224>
f010125a:	39 c6                	cmp    %eax,%esi
f010125c:	75 19                	jne    f0101277 <mem_init+0x23d>
f010125e:	68 48 3e 10 f0       	push   $0xf0103e48
f0101263:	68 5a 44 10 f0       	push   $0xf010445a
f0101268:	68 c3 02 00 00       	push   $0x2c3
f010126d:	68 34 44 10 f0       	push   $0xf0104434
f0101272:	e8 14 ee ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101277:	8b 0d 8c 79 11 f0    	mov    0xf011798c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010127d:	8b 15 84 79 11 f0    	mov    0xf0117984,%edx
f0101283:	c1 e2 0c             	shl    $0xc,%edx
f0101286:	89 f8                	mov    %edi,%eax
f0101288:	29 c8                	sub    %ecx,%eax
f010128a:	c1 f8 03             	sar    $0x3,%eax
f010128d:	c1 e0 0c             	shl    $0xc,%eax
f0101290:	39 d0                	cmp    %edx,%eax
f0101292:	72 19                	jb     f01012ad <mem_init+0x273>
f0101294:	68 59 45 10 f0       	push   $0xf0104559
f0101299:	68 5a 44 10 f0       	push   $0xf010445a
f010129e:	68 c4 02 00 00       	push   $0x2c4
f01012a3:	68 34 44 10 f0       	push   $0xf0104434
f01012a8:	e8 de ed ff ff       	call   f010008b <_panic>
f01012ad:	89 f0                	mov    %esi,%eax
f01012af:	29 c8                	sub    %ecx,%eax
f01012b1:	c1 f8 03             	sar    $0x3,%eax
f01012b4:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01012b7:	39 c2                	cmp    %eax,%edx
f01012b9:	77 19                	ja     f01012d4 <mem_init+0x29a>
f01012bb:	68 76 45 10 f0       	push   $0xf0104576
f01012c0:	68 5a 44 10 f0       	push   $0xf010445a
f01012c5:	68 c5 02 00 00       	push   $0x2c5
f01012ca:	68 34 44 10 f0       	push   $0xf0104434
f01012cf:	e8 b7 ed ff ff       	call   f010008b <_panic>
f01012d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012d7:	29 c8                	sub    %ecx,%eax
f01012d9:	c1 f8 03             	sar    $0x3,%eax
f01012dc:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01012df:	39 c2                	cmp    %eax,%edx
f01012e1:	77 19                	ja     f01012fc <mem_init+0x2c2>
f01012e3:	68 93 45 10 f0       	push   $0xf0104593
f01012e8:	68 5a 44 10 f0       	push   $0xf010445a
f01012ed:	68 c6 02 00 00       	push   $0x2c6
f01012f2:	68 34 44 10 f0       	push   $0xf0104434
f01012f7:	e8 8f ed ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01012fc:	a1 5c 75 11 f0       	mov    0xf011755c,%eax
f0101301:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101304:	c7 05 5c 75 11 f0 00 	movl   $0x0,0xf011755c
f010130b:	00 00 00 
	//cprintf("\nI am Here..!!");
	// should be no free memory
	assert(!page_alloc(0));
f010130e:	83 ec 0c             	sub    $0xc,%esp
f0101311:	6a 00                	push   $0x0
f0101313:	e8 04 fa ff ff       	call   f0100d1c <page_alloc>
f0101318:	83 c4 10             	add    $0x10,%esp
f010131b:	85 c0                	test   %eax,%eax
f010131d:	74 19                	je     f0101338 <mem_init+0x2fe>
f010131f:	68 b0 45 10 f0       	push   $0xf01045b0
f0101324:	68 5a 44 10 f0       	push   $0xf010445a
f0101329:	68 cd 02 00 00       	push   $0x2cd
f010132e:	68 34 44 10 f0       	push   $0xf0104434
f0101333:	e8 53 ed ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101338:	83 ec 0c             	sub    $0xc,%esp
f010133b:	57                   	push   %edi
f010133c:	e8 52 fa ff ff       	call   f0100d93 <page_free>
	page_free(pp1);
f0101341:	89 34 24             	mov    %esi,(%esp)
f0101344:	e8 4a fa ff ff       	call   f0100d93 <page_free>
	page_free(pp2);
f0101349:	83 c4 04             	add    $0x4,%esp
f010134c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010134f:	e8 3f fa ff ff       	call   f0100d93 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101354:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010135b:	e8 bc f9 ff ff       	call   f0100d1c <page_alloc>
f0101360:	89 c6                	mov    %eax,%esi
f0101362:	83 c4 10             	add    $0x10,%esp
f0101365:	85 c0                	test   %eax,%eax
f0101367:	75 19                	jne    f0101382 <mem_init+0x348>
f0101369:	68 05 45 10 f0       	push   $0xf0104505
f010136e:	68 5a 44 10 f0       	push   $0xf010445a
f0101373:	68 d4 02 00 00       	push   $0x2d4
f0101378:	68 34 44 10 f0       	push   $0xf0104434
f010137d:	e8 09 ed ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101382:	83 ec 0c             	sub    $0xc,%esp
f0101385:	6a 00                	push   $0x0
f0101387:	e8 90 f9 ff ff       	call   f0100d1c <page_alloc>
f010138c:	89 c7                	mov    %eax,%edi
f010138e:	83 c4 10             	add    $0x10,%esp
f0101391:	85 c0                	test   %eax,%eax
f0101393:	75 19                	jne    f01013ae <mem_init+0x374>
f0101395:	68 1b 45 10 f0       	push   $0xf010451b
f010139a:	68 5a 44 10 f0       	push   $0xf010445a
f010139f:	68 d5 02 00 00       	push   $0x2d5
f01013a4:	68 34 44 10 f0       	push   $0xf0104434
f01013a9:	e8 dd ec ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01013ae:	83 ec 0c             	sub    $0xc,%esp
f01013b1:	6a 00                	push   $0x0
f01013b3:	e8 64 f9 ff ff       	call   f0100d1c <page_alloc>
f01013b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01013bb:	83 c4 10             	add    $0x10,%esp
f01013be:	85 c0                	test   %eax,%eax
f01013c0:	75 19                	jne    f01013db <mem_init+0x3a1>
f01013c2:	68 31 45 10 f0       	push   $0xf0104531
f01013c7:	68 5a 44 10 f0       	push   $0xf010445a
f01013cc:	68 d6 02 00 00       	push   $0x2d6
f01013d1:	68 34 44 10 f0       	push   $0xf0104434
f01013d6:	e8 b0 ec ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01013db:	39 fe                	cmp    %edi,%esi
f01013dd:	75 19                	jne    f01013f8 <mem_init+0x3be>
f01013df:	68 47 45 10 f0       	push   $0xf0104547
f01013e4:	68 5a 44 10 f0       	push   $0xf010445a
f01013e9:	68 d8 02 00 00       	push   $0x2d8
f01013ee:	68 34 44 10 f0       	push   $0xf0104434
f01013f3:	e8 93 ec ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013f8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013fb:	39 c6                	cmp    %eax,%esi
f01013fd:	74 04                	je     f0101403 <mem_init+0x3c9>
f01013ff:	39 c7                	cmp    %eax,%edi
f0101401:	75 19                	jne    f010141c <mem_init+0x3e2>
f0101403:	68 48 3e 10 f0       	push   $0xf0103e48
f0101408:	68 5a 44 10 f0       	push   $0xf010445a
f010140d:	68 d9 02 00 00       	push   $0x2d9
f0101412:	68 34 44 10 f0       	push   $0xf0104434
f0101417:	e8 6f ec ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f010141c:	83 ec 0c             	sub    $0xc,%esp
f010141f:	6a 00                	push   $0x0
f0101421:	e8 f6 f8 ff ff       	call   f0100d1c <page_alloc>
f0101426:	83 c4 10             	add    $0x10,%esp
f0101429:	85 c0                	test   %eax,%eax
f010142b:	74 19                	je     f0101446 <mem_init+0x40c>
f010142d:	68 b0 45 10 f0       	push   $0xf01045b0
f0101432:	68 5a 44 10 f0       	push   $0xf010445a
f0101437:	68 da 02 00 00       	push   $0x2da
f010143c:	68 34 44 10 f0       	push   $0xf0104434
f0101441:	e8 45 ec ff ff       	call   f010008b <_panic>
f0101446:	89 f0                	mov    %esi,%eax
f0101448:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f010144e:	c1 f8 03             	sar    $0x3,%eax
f0101451:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101454:	89 c2                	mov    %eax,%edx
f0101456:	c1 ea 0c             	shr    $0xc,%edx
f0101459:	3b 15 84 79 11 f0    	cmp    0xf0117984,%edx
f010145f:	72 12                	jb     f0101473 <mem_init+0x439>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101461:	50                   	push   %eax
f0101462:	68 88 3c 10 f0       	push   $0xf0103c88
f0101467:	6a 52                	push   $0x52
f0101469:	68 40 44 10 f0       	push   $0xf0104440
f010146e:	e8 18 ec ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101473:	83 ec 04             	sub    $0x4,%esp
f0101476:	68 00 10 00 00       	push   $0x1000
f010147b:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010147d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101482:	50                   	push   %eax
f0101483:	e8 9e 1d 00 00       	call   f0103226 <memset>
	page_free(pp0);
f0101488:	89 34 24             	mov    %esi,(%esp)
f010148b:	e8 03 f9 ff ff       	call   f0100d93 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101490:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101497:	e8 80 f8 ff ff       	call   f0100d1c <page_alloc>
f010149c:	83 c4 10             	add    $0x10,%esp
f010149f:	85 c0                	test   %eax,%eax
f01014a1:	75 19                	jne    f01014bc <mem_init+0x482>
f01014a3:	68 bf 45 10 f0       	push   $0xf01045bf
f01014a8:	68 5a 44 10 f0       	push   $0xf010445a
f01014ad:	68 df 02 00 00       	push   $0x2df
f01014b2:	68 34 44 10 f0       	push   $0xf0104434
f01014b7:	e8 cf eb ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f01014bc:	39 c6                	cmp    %eax,%esi
f01014be:	74 19                	je     f01014d9 <mem_init+0x49f>
f01014c0:	68 dd 45 10 f0       	push   $0xf01045dd
f01014c5:	68 5a 44 10 f0       	push   $0xf010445a
f01014ca:	68 e0 02 00 00       	push   $0x2e0
f01014cf:	68 34 44 10 f0       	push   $0xf0104434
f01014d4:	e8 b2 eb ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014d9:	89 f0                	mov    %esi,%eax
f01014db:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f01014e1:	c1 f8 03             	sar    $0x3,%eax
f01014e4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014e7:	89 c2                	mov    %eax,%edx
f01014e9:	c1 ea 0c             	shr    $0xc,%edx
f01014ec:	3b 15 84 79 11 f0    	cmp    0xf0117984,%edx
f01014f2:	72 12                	jb     f0101506 <mem_init+0x4cc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014f4:	50                   	push   %eax
f01014f5:	68 88 3c 10 f0       	push   $0xf0103c88
f01014fa:	6a 52                	push   $0x52
f01014fc:	68 40 44 10 f0       	push   $0xf0104440
f0101501:	e8 85 eb ff ff       	call   f010008b <_panic>
f0101506:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f010150c:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101512:	80 38 00             	cmpb   $0x0,(%eax)
f0101515:	74 19                	je     f0101530 <mem_init+0x4f6>
f0101517:	68 ed 45 10 f0       	push   $0xf01045ed
f010151c:	68 5a 44 10 f0       	push   $0xf010445a
f0101521:	68 e3 02 00 00       	push   $0x2e3
f0101526:	68 34 44 10 f0       	push   $0xf0104434
f010152b:	e8 5b eb ff ff       	call   f010008b <_panic>
f0101530:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101533:	39 d0                	cmp    %edx,%eax
f0101535:	75 db                	jne    f0101512 <mem_init+0x4d8>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101537:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010153a:	a3 5c 75 11 f0       	mov    %eax,0xf011755c

	// free the pages we took
	page_free(pp0);
f010153f:	83 ec 0c             	sub    $0xc,%esp
f0101542:	56                   	push   %esi
f0101543:	e8 4b f8 ff ff       	call   f0100d93 <page_free>
	page_free(pp1);
f0101548:	89 3c 24             	mov    %edi,(%esp)
f010154b:	e8 43 f8 ff ff       	call   f0100d93 <page_free>
	page_free(pp2);
f0101550:	83 c4 04             	add    $0x4,%esp
f0101553:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101556:	e8 38 f8 ff ff       	call   f0100d93 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010155b:	a1 5c 75 11 f0       	mov    0xf011755c,%eax
f0101560:	83 c4 10             	add    $0x10,%esp
f0101563:	eb 05                	jmp    f010156a <mem_init+0x530>
		--nfree;
f0101565:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101568:	8b 00                	mov    (%eax),%eax
f010156a:	85 c0                	test   %eax,%eax
f010156c:	75 f7                	jne    f0101565 <mem_init+0x52b>
		--nfree;
	assert(nfree == 0);
f010156e:	85 db                	test   %ebx,%ebx
f0101570:	74 19                	je     f010158b <mem_init+0x551>
f0101572:	68 f7 45 10 f0       	push   $0xf01045f7
f0101577:	68 5a 44 10 f0       	push   $0xf010445a
f010157c:	68 f0 02 00 00       	push   $0x2f0
f0101581:	68 34 44 10 f0       	push   $0xf0104434
f0101586:	e8 00 eb ff ff       	call   f010008b <_panic>

	cprintf("\ncheck_page_alloc() succeeded!\n");
f010158b:	83 ec 0c             	sub    $0xc,%esp
f010158e:	68 68 3e 10 f0       	push   $0xf0103e68
f0101593:	e8 a2 11 00 00       	call   f010273a <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101598:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010159f:	e8 78 f7 ff ff       	call   f0100d1c <page_alloc>
f01015a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015a7:	83 c4 10             	add    $0x10,%esp
f01015aa:	85 c0                	test   %eax,%eax
f01015ac:	75 19                	jne    f01015c7 <mem_init+0x58d>
f01015ae:	68 05 45 10 f0       	push   $0xf0104505
f01015b3:	68 5a 44 10 f0       	push   $0xf010445a
f01015b8:	68 49 03 00 00       	push   $0x349
f01015bd:	68 34 44 10 f0       	push   $0xf0104434
f01015c2:	e8 c4 ea ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01015c7:	83 ec 0c             	sub    $0xc,%esp
f01015ca:	6a 00                	push   $0x0
f01015cc:	e8 4b f7 ff ff       	call   f0100d1c <page_alloc>
f01015d1:	89 c3                	mov    %eax,%ebx
f01015d3:	83 c4 10             	add    $0x10,%esp
f01015d6:	85 c0                	test   %eax,%eax
f01015d8:	75 19                	jne    f01015f3 <mem_init+0x5b9>
f01015da:	68 1b 45 10 f0       	push   $0xf010451b
f01015df:	68 5a 44 10 f0       	push   $0xf010445a
f01015e4:	68 4a 03 00 00       	push   $0x34a
f01015e9:	68 34 44 10 f0       	push   $0xf0104434
f01015ee:	e8 98 ea ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01015f3:	83 ec 0c             	sub    $0xc,%esp
f01015f6:	6a 00                	push   $0x0
f01015f8:	e8 1f f7 ff ff       	call   f0100d1c <page_alloc>
f01015fd:	89 c6                	mov    %eax,%esi
f01015ff:	83 c4 10             	add    $0x10,%esp
f0101602:	85 c0                	test   %eax,%eax
f0101604:	75 19                	jne    f010161f <mem_init+0x5e5>
f0101606:	68 31 45 10 f0       	push   $0xf0104531
f010160b:	68 5a 44 10 f0       	push   $0xf010445a
f0101610:	68 4b 03 00 00       	push   $0x34b
f0101615:	68 34 44 10 f0       	push   $0xf0104434
f010161a:	e8 6c ea ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010161f:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101622:	75 19                	jne    f010163d <mem_init+0x603>
f0101624:	68 47 45 10 f0       	push   $0xf0104547
f0101629:	68 5a 44 10 f0       	push   $0xf010445a
f010162e:	68 4e 03 00 00       	push   $0x34e
f0101633:	68 34 44 10 f0       	push   $0xf0104434
f0101638:	e8 4e ea ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010163d:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101640:	74 04                	je     f0101646 <mem_init+0x60c>
f0101642:	39 c3                	cmp    %eax,%ebx
f0101644:	75 19                	jne    f010165f <mem_init+0x625>
f0101646:	68 48 3e 10 f0       	push   $0xf0103e48
f010164b:	68 5a 44 10 f0       	push   $0xf010445a
f0101650:	68 4f 03 00 00       	push   $0x34f
f0101655:	68 34 44 10 f0       	push   $0xf0104434
f010165a:	e8 2c ea ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010165f:	a1 5c 75 11 f0       	mov    0xf011755c,%eax
f0101664:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101667:	c7 05 5c 75 11 f0 00 	movl   $0x0,0xf011755c
f010166e:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101671:	83 ec 0c             	sub    $0xc,%esp
f0101674:	6a 00                	push   $0x0
f0101676:	e8 a1 f6 ff ff       	call   f0100d1c <page_alloc>
f010167b:	83 c4 10             	add    $0x10,%esp
f010167e:	85 c0                	test   %eax,%eax
f0101680:	74 19                	je     f010169b <mem_init+0x661>
f0101682:	68 b0 45 10 f0       	push   $0xf01045b0
f0101687:	68 5a 44 10 f0       	push   $0xf010445a
f010168c:	68 56 03 00 00       	push   $0x356
f0101691:	68 34 44 10 f0       	push   $0xf0104434
f0101696:	e8 f0 e9 ff ff       	call   f010008b <_panic>
	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010169b:	83 ec 04             	sub    $0x4,%esp
f010169e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01016a1:	50                   	push   %eax
f01016a2:	6a 00                	push   $0x0
f01016a4:	ff 35 88 79 11 f0    	pushl  0xf0117988
f01016aa:	e8 83 f8 ff ff       	call   f0100f32 <page_lookup>
f01016af:	83 c4 10             	add    $0x10,%esp
f01016b2:	85 c0                	test   %eax,%eax
f01016b4:	74 19                	je     f01016cf <mem_init+0x695>
f01016b6:	68 88 3e 10 f0       	push   $0xf0103e88
f01016bb:	68 5a 44 10 f0       	push   $0xf010445a
f01016c0:	68 58 03 00 00       	push   $0x358
f01016c5:	68 34 44 10 f0       	push   $0xf0104434
f01016ca:	e8 bc e9 ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01016cf:	6a 02                	push   $0x2
f01016d1:	6a 00                	push   $0x0
f01016d3:	53                   	push   %ebx
f01016d4:	ff 35 88 79 11 f0    	pushl  0xf0117988
f01016da:	e8 f3 f8 ff ff       	call   f0100fd2 <page_insert>
f01016df:	83 c4 10             	add    $0x10,%esp
f01016e2:	85 c0                	test   %eax,%eax
f01016e4:	78 19                	js     f01016ff <mem_init+0x6c5>
f01016e6:	68 c0 3e 10 f0       	push   $0xf0103ec0
f01016eb:	68 5a 44 10 f0       	push   $0xf010445a
f01016f0:	68 5b 03 00 00       	push   $0x35b
f01016f5:	68 34 44 10 f0       	push   $0xf0104434
f01016fa:	e8 8c e9 ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01016ff:	83 ec 0c             	sub    $0xc,%esp
f0101702:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101705:	e8 89 f6 ff ff       	call   f0100d93 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010170a:	6a 02                	push   $0x2
f010170c:	6a 00                	push   $0x0
f010170e:	53                   	push   %ebx
f010170f:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0101715:	e8 b8 f8 ff ff       	call   f0100fd2 <page_insert>
f010171a:	83 c4 20             	add    $0x20,%esp
f010171d:	85 c0                	test   %eax,%eax
f010171f:	74 19                	je     f010173a <mem_init+0x700>
f0101721:	68 f0 3e 10 f0       	push   $0xf0103ef0
f0101726:	68 5a 44 10 f0       	push   $0xf010445a
f010172b:	68 5f 03 00 00       	push   $0x35f
f0101730:	68 34 44 10 f0       	push   $0xf0104434
f0101735:	e8 51 e9 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010173a:	8b 3d 88 79 11 f0    	mov    0xf0117988,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101740:	a1 8c 79 11 f0       	mov    0xf011798c,%eax
f0101745:	89 c1                	mov    %eax,%ecx
f0101747:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010174a:	8b 17                	mov    (%edi),%edx
f010174c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101752:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101755:	29 c8                	sub    %ecx,%eax
f0101757:	c1 f8 03             	sar    $0x3,%eax
f010175a:	c1 e0 0c             	shl    $0xc,%eax
f010175d:	39 c2                	cmp    %eax,%edx
f010175f:	74 19                	je     f010177a <mem_init+0x740>
f0101761:	68 20 3f 10 f0       	push   $0xf0103f20
f0101766:	68 5a 44 10 f0       	push   $0xf010445a
f010176b:	68 60 03 00 00       	push   $0x360
f0101770:	68 34 44 10 f0       	push   $0xf0104434
f0101775:	e8 11 e9 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010177a:	ba 00 00 00 00       	mov    $0x0,%edx
f010177f:	89 f8                	mov    %edi,%eax
f0101781:	e8 d2 f1 ff ff       	call   f0100958 <check_va2pa>
f0101786:	89 da                	mov    %ebx,%edx
f0101788:	2b 55 cc             	sub    -0x34(%ebp),%edx
f010178b:	c1 fa 03             	sar    $0x3,%edx
f010178e:	c1 e2 0c             	shl    $0xc,%edx
f0101791:	39 d0                	cmp    %edx,%eax
f0101793:	74 19                	je     f01017ae <mem_init+0x774>
f0101795:	68 48 3f 10 f0       	push   $0xf0103f48
f010179a:	68 5a 44 10 f0       	push   $0xf010445a
f010179f:	68 61 03 00 00       	push   $0x361
f01017a4:	68 34 44 10 f0       	push   $0xf0104434
f01017a9:	e8 dd e8 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f01017ae:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01017b3:	74 19                	je     f01017ce <mem_init+0x794>
f01017b5:	68 02 46 10 f0       	push   $0xf0104602
f01017ba:	68 5a 44 10 f0       	push   $0xf010445a
f01017bf:	68 62 03 00 00       	push   $0x362
f01017c4:	68 34 44 10 f0       	push   $0xf0104434
f01017c9:	e8 bd e8 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f01017ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017d1:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01017d6:	74 19                	je     f01017f1 <mem_init+0x7b7>
f01017d8:	68 13 46 10 f0       	push   $0xf0104613
f01017dd:	68 5a 44 10 f0       	push   $0xf010445a
f01017e2:	68 63 03 00 00       	push   $0x363
f01017e7:	68 34 44 10 f0       	push   $0xf0104434
f01017ec:	e8 9a e8 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01017f1:	6a 02                	push   $0x2
f01017f3:	68 00 10 00 00       	push   $0x1000
f01017f8:	56                   	push   %esi
f01017f9:	57                   	push   %edi
f01017fa:	e8 d3 f7 ff ff       	call   f0100fd2 <page_insert>
f01017ff:	83 c4 10             	add    $0x10,%esp
f0101802:	85 c0                	test   %eax,%eax
f0101804:	74 19                	je     f010181f <mem_init+0x7e5>
f0101806:	68 78 3f 10 f0       	push   $0xf0103f78
f010180b:	68 5a 44 10 f0       	push   $0xf010445a
f0101810:	68 66 03 00 00       	push   $0x366
f0101815:	68 34 44 10 f0       	push   $0xf0104434
f010181a:	e8 6c e8 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010181f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101824:	a1 88 79 11 f0       	mov    0xf0117988,%eax
f0101829:	e8 2a f1 ff ff       	call   f0100958 <check_va2pa>
f010182e:	89 f2                	mov    %esi,%edx
f0101830:	2b 15 8c 79 11 f0    	sub    0xf011798c,%edx
f0101836:	c1 fa 03             	sar    $0x3,%edx
f0101839:	c1 e2 0c             	shl    $0xc,%edx
f010183c:	39 d0                	cmp    %edx,%eax
f010183e:	74 19                	je     f0101859 <mem_init+0x81f>
f0101840:	68 b4 3f 10 f0       	push   $0xf0103fb4
f0101845:	68 5a 44 10 f0       	push   $0xf010445a
f010184a:	68 67 03 00 00       	push   $0x367
f010184f:	68 34 44 10 f0       	push   $0xf0104434
f0101854:	e8 32 e8 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101859:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010185e:	74 19                	je     f0101879 <mem_init+0x83f>
f0101860:	68 24 46 10 f0       	push   $0xf0104624
f0101865:	68 5a 44 10 f0       	push   $0xf010445a
f010186a:	68 68 03 00 00       	push   $0x368
f010186f:	68 34 44 10 f0       	push   $0xf0104434
f0101874:	e8 12 e8 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101879:	83 ec 0c             	sub    $0xc,%esp
f010187c:	6a 00                	push   $0x0
f010187e:	e8 99 f4 ff ff       	call   f0100d1c <page_alloc>
f0101883:	83 c4 10             	add    $0x10,%esp
f0101886:	85 c0                	test   %eax,%eax
f0101888:	74 19                	je     f01018a3 <mem_init+0x869>
f010188a:	68 b0 45 10 f0       	push   $0xf01045b0
f010188f:	68 5a 44 10 f0       	push   $0xf010445a
f0101894:	68 6b 03 00 00       	push   $0x36b
f0101899:	68 34 44 10 f0       	push   $0xf0104434
f010189e:	e8 e8 e7 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01018a3:	6a 02                	push   $0x2
f01018a5:	68 00 10 00 00       	push   $0x1000
f01018aa:	56                   	push   %esi
f01018ab:	ff 35 88 79 11 f0    	pushl  0xf0117988
f01018b1:	e8 1c f7 ff ff       	call   f0100fd2 <page_insert>
f01018b6:	83 c4 10             	add    $0x10,%esp
f01018b9:	85 c0                	test   %eax,%eax
f01018bb:	74 19                	je     f01018d6 <mem_init+0x89c>
f01018bd:	68 78 3f 10 f0       	push   $0xf0103f78
f01018c2:	68 5a 44 10 f0       	push   $0xf010445a
f01018c7:	68 6e 03 00 00       	push   $0x36e
f01018cc:	68 34 44 10 f0       	push   $0xf0104434
f01018d1:	e8 b5 e7 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018d6:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018db:	a1 88 79 11 f0       	mov    0xf0117988,%eax
f01018e0:	e8 73 f0 ff ff       	call   f0100958 <check_va2pa>
f01018e5:	89 f2                	mov    %esi,%edx
f01018e7:	2b 15 8c 79 11 f0    	sub    0xf011798c,%edx
f01018ed:	c1 fa 03             	sar    $0x3,%edx
f01018f0:	c1 e2 0c             	shl    $0xc,%edx
f01018f3:	39 d0                	cmp    %edx,%eax
f01018f5:	74 19                	je     f0101910 <mem_init+0x8d6>
f01018f7:	68 b4 3f 10 f0       	push   $0xf0103fb4
f01018fc:	68 5a 44 10 f0       	push   $0xf010445a
f0101901:	68 6f 03 00 00       	push   $0x36f
f0101906:	68 34 44 10 f0       	push   $0xf0104434
f010190b:	e8 7b e7 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101910:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101915:	74 19                	je     f0101930 <mem_init+0x8f6>
f0101917:	68 24 46 10 f0       	push   $0xf0104624
f010191c:	68 5a 44 10 f0       	push   $0xf010445a
f0101921:	68 70 03 00 00       	push   $0x370
f0101926:	68 34 44 10 f0       	push   $0xf0104434
f010192b:	e8 5b e7 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101930:	83 ec 0c             	sub    $0xc,%esp
f0101933:	6a 00                	push   $0x0
f0101935:	e8 e2 f3 ff ff       	call   f0100d1c <page_alloc>
f010193a:	83 c4 10             	add    $0x10,%esp
f010193d:	85 c0                	test   %eax,%eax
f010193f:	74 19                	je     f010195a <mem_init+0x920>
f0101941:	68 b0 45 10 f0       	push   $0xf01045b0
f0101946:	68 5a 44 10 f0       	push   $0xf010445a
f010194b:	68 74 03 00 00       	push   $0x374
f0101950:	68 34 44 10 f0       	push   $0xf0104434
f0101955:	e8 31 e7 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f010195a:	8b 15 88 79 11 f0    	mov    0xf0117988,%edx
f0101960:	8b 02                	mov    (%edx),%eax
f0101962:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101967:	89 c1                	mov    %eax,%ecx
f0101969:	c1 e9 0c             	shr    $0xc,%ecx
f010196c:	3b 0d 84 79 11 f0    	cmp    0xf0117984,%ecx
f0101972:	72 15                	jb     f0101989 <mem_init+0x94f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101974:	50                   	push   %eax
f0101975:	68 88 3c 10 f0       	push   $0xf0103c88
f010197a:	68 77 03 00 00       	push   $0x377
f010197f:	68 34 44 10 f0       	push   $0xf0104434
f0101984:	e8 02 e7 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101989:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010198e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101991:	83 ec 04             	sub    $0x4,%esp
f0101994:	6a 00                	push   $0x0
f0101996:	68 00 10 00 00       	push   $0x1000
f010199b:	52                   	push   %edx
f010199c:	e8 54 f4 ff ff       	call   f0100df5 <pgdir_walk>
f01019a1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01019a4:	8d 51 04             	lea    0x4(%ecx),%edx
f01019a7:	83 c4 10             	add    $0x10,%esp
f01019aa:	39 d0                	cmp    %edx,%eax
f01019ac:	74 19                	je     f01019c7 <mem_init+0x98d>
f01019ae:	68 e4 3f 10 f0       	push   $0xf0103fe4
f01019b3:	68 5a 44 10 f0       	push   $0xf010445a
f01019b8:	68 78 03 00 00       	push   $0x378
f01019bd:	68 34 44 10 f0       	push   $0xf0104434
f01019c2:	e8 c4 e6 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01019c7:	6a 06                	push   $0x6
f01019c9:	68 00 10 00 00       	push   $0x1000
f01019ce:	56                   	push   %esi
f01019cf:	ff 35 88 79 11 f0    	pushl  0xf0117988
f01019d5:	e8 f8 f5 ff ff       	call   f0100fd2 <page_insert>
f01019da:	83 c4 10             	add    $0x10,%esp
f01019dd:	85 c0                	test   %eax,%eax
f01019df:	74 19                	je     f01019fa <mem_init+0x9c0>
f01019e1:	68 24 40 10 f0       	push   $0xf0104024
f01019e6:	68 5a 44 10 f0       	push   $0xf010445a
f01019eb:	68 7b 03 00 00       	push   $0x37b
f01019f0:	68 34 44 10 f0       	push   $0xf0104434
f01019f5:	e8 91 e6 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019fa:	8b 3d 88 79 11 f0    	mov    0xf0117988,%edi
f0101a00:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a05:	89 f8                	mov    %edi,%eax
f0101a07:	e8 4c ef ff ff       	call   f0100958 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a0c:	89 f2                	mov    %esi,%edx
f0101a0e:	2b 15 8c 79 11 f0    	sub    0xf011798c,%edx
f0101a14:	c1 fa 03             	sar    $0x3,%edx
f0101a17:	c1 e2 0c             	shl    $0xc,%edx
f0101a1a:	39 d0                	cmp    %edx,%eax
f0101a1c:	74 19                	je     f0101a37 <mem_init+0x9fd>
f0101a1e:	68 b4 3f 10 f0       	push   $0xf0103fb4
f0101a23:	68 5a 44 10 f0       	push   $0xf010445a
f0101a28:	68 7c 03 00 00       	push   $0x37c
f0101a2d:	68 34 44 10 f0       	push   $0xf0104434
f0101a32:	e8 54 e6 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101a37:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a3c:	74 19                	je     f0101a57 <mem_init+0xa1d>
f0101a3e:	68 24 46 10 f0       	push   $0xf0104624
f0101a43:	68 5a 44 10 f0       	push   $0xf010445a
f0101a48:	68 7d 03 00 00       	push   $0x37d
f0101a4d:	68 34 44 10 f0       	push   $0xf0104434
f0101a52:	e8 34 e6 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101a57:	83 ec 04             	sub    $0x4,%esp
f0101a5a:	6a 00                	push   $0x0
f0101a5c:	68 00 10 00 00       	push   $0x1000
f0101a61:	57                   	push   %edi
f0101a62:	e8 8e f3 ff ff       	call   f0100df5 <pgdir_walk>
f0101a67:	83 c4 10             	add    $0x10,%esp
f0101a6a:	f6 00 04             	testb  $0x4,(%eax)
f0101a6d:	75 19                	jne    f0101a88 <mem_init+0xa4e>
f0101a6f:	68 64 40 10 f0       	push   $0xf0104064
f0101a74:	68 5a 44 10 f0       	push   $0xf010445a
f0101a79:	68 7e 03 00 00       	push   $0x37e
f0101a7e:	68 34 44 10 f0       	push   $0xf0104434
f0101a83:	e8 03 e6 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101a88:	a1 88 79 11 f0       	mov    0xf0117988,%eax
f0101a8d:	f6 00 04             	testb  $0x4,(%eax)
f0101a90:	75 19                	jne    f0101aab <mem_init+0xa71>
f0101a92:	68 35 46 10 f0       	push   $0xf0104635
f0101a97:	68 5a 44 10 f0       	push   $0xf010445a
f0101a9c:	68 7f 03 00 00       	push   $0x37f
f0101aa1:	68 34 44 10 f0       	push   $0xf0104434
f0101aa6:	e8 e0 e5 ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101aab:	6a 02                	push   $0x2
f0101aad:	68 00 10 00 00       	push   $0x1000
f0101ab2:	56                   	push   %esi
f0101ab3:	50                   	push   %eax
f0101ab4:	e8 19 f5 ff ff       	call   f0100fd2 <page_insert>
f0101ab9:	83 c4 10             	add    $0x10,%esp
f0101abc:	85 c0                	test   %eax,%eax
f0101abe:	74 19                	je     f0101ad9 <mem_init+0xa9f>
f0101ac0:	68 78 3f 10 f0       	push   $0xf0103f78
f0101ac5:	68 5a 44 10 f0       	push   $0xf010445a
f0101aca:	68 82 03 00 00       	push   $0x382
f0101acf:	68 34 44 10 f0       	push   $0xf0104434
f0101ad4:	e8 b2 e5 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ad9:	83 ec 04             	sub    $0x4,%esp
f0101adc:	6a 00                	push   $0x0
f0101ade:	68 00 10 00 00       	push   $0x1000
f0101ae3:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0101ae9:	e8 07 f3 ff ff       	call   f0100df5 <pgdir_walk>
f0101aee:	83 c4 10             	add    $0x10,%esp
f0101af1:	f6 00 02             	testb  $0x2,(%eax)
f0101af4:	75 19                	jne    f0101b0f <mem_init+0xad5>
f0101af6:	68 98 40 10 f0       	push   $0xf0104098
f0101afb:	68 5a 44 10 f0       	push   $0xf010445a
f0101b00:	68 83 03 00 00       	push   $0x383
f0101b05:	68 34 44 10 f0       	push   $0xf0104434
f0101b0a:	e8 7c e5 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b0f:	83 ec 04             	sub    $0x4,%esp
f0101b12:	6a 00                	push   $0x0
f0101b14:	68 00 10 00 00       	push   $0x1000
f0101b19:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0101b1f:	e8 d1 f2 ff ff       	call   f0100df5 <pgdir_walk>
f0101b24:	83 c4 10             	add    $0x10,%esp
f0101b27:	f6 00 04             	testb  $0x4,(%eax)
f0101b2a:	74 19                	je     f0101b45 <mem_init+0xb0b>
f0101b2c:	68 cc 40 10 f0       	push   $0xf01040cc
f0101b31:	68 5a 44 10 f0       	push   $0xf010445a
f0101b36:	68 84 03 00 00       	push   $0x384
f0101b3b:	68 34 44 10 f0       	push   $0xf0104434
f0101b40:	e8 46 e5 ff ff       	call   f010008b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101b45:	6a 02                	push   $0x2
f0101b47:	68 00 00 40 00       	push   $0x400000
f0101b4c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b4f:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0101b55:	e8 78 f4 ff ff       	call   f0100fd2 <page_insert>
f0101b5a:	83 c4 10             	add    $0x10,%esp
f0101b5d:	85 c0                	test   %eax,%eax
f0101b5f:	78 19                	js     f0101b7a <mem_init+0xb40>
f0101b61:	68 04 41 10 f0       	push   $0xf0104104
f0101b66:	68 5a 44 10 f0       	push   $0xf010445a
f0101b6b:	68 87 03 00 00       	push   $0x387
f0101b70:	68 34 44 10 f0       	push   $0xf0104434
f0101b75:	e8 11 e5 ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101b7a:	6a 02                	push   $0x2
f0101b7c:	68 00 10 00 00       	push   $0x1000
f0101b81:	53                   	push   %ebx
f0101b82:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0101b88:	e8 45 f4 ff ff       	call   f0100fd2 <page_insert>
f0101b8d:	83 c4 10             	add    $0x10,%esp
f0101b90:	85 c0                	test   %eax,%eax
f0101b92:	74 19                	je     f0101bad <mem_init+0xb73>
f0101b94:	68 3c 41 10 f0       	push   $0xf010413c
f0101b99:	68 5a 44 10 f0       	push   $0xf010445a
f0101b9e:	68 8a 03 00 00       	push   $0x38a
f0101ba3:	68 34 44 10 f0       	push   $0xf0104434
f0101ba8:	e8 de e4 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bad:	83 ec 04             	sub    $0x4,%esp
f0101bb0:	6a 00                	push   $0x0
f0101bb2:	68 00 10 00 00       	push   $0x1000
f0101bb7:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0101bbd:	e8 33 f2 ff ff       	call   f0100df5 <pgdir_walk>
f0101bc2:	83 c4 10             	add    $0x10,%esp
f0101bc5:	f6 00 04             	testb  $0x4,(%eax)
f0101bc8:	74 19                	je     f0101be3 <mem_init+0xba9>
f0101bca:	68 cc 40 10 f0       	push   $0xf01040cc
f0101bcf:	68 5a 44 10 f0       	push   $0xf010445a
f0101bd4:	68 8b 03 00 00       	push   $0x38b
f0101bd9:	68 34 44 10 f0       	push   $0xf0104434
f0101bde:	e8 a8 e4 ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101be3:	8b 3d 88 79 11 f0    	mov    0xf0117988,%edi
f0101be9:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bee:	89 f8                	mov    %edi,%eax
f0101bf0:	e8 63 ed ff ff       	call   f0100958 <check_va2pa>
f0101bf5:	89 c1                	mov    %eax,%ecx
f0101bf7:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101bfa:	89 d8                	mov    %ebx,%eax
f0101bfc:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f0101c02:	c1 f8 03             	sar    $0x3,%eax
f0101c05:	c1 e0 0c             	shl    $0xc,%eax
f0101c08:	39 c1                	cmp    %eax,%ecx
f0101c0a:	74 19                	je     f0101c25 <mem_init+0xbeb>
f0101c0c:	68 78 41 10 f0       	push   $0xf0104178
f0101c11:	68 5a 44 10 f0       	push   $0xf010445a
f0101c16:	68 8e 03 00 00       	push   $0x38e
f0101c1b:	68 34 44 10 f0       	push   $0xf0104434
f0101c20:	e8 66 e4 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c25:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c2a:	89 f8                	mov    %edi,%eax
f0101c2c:	e8 27 ed ff ff       	call   f0100958 <check_va2pa>
f0101c31:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101c34:	74 19                	je     f0101c4f <mem_init+0xc15>
f0101c36:	68 a4 41 10 f0       	push   $0xf01041a4
f0101c3b:	68 5a 44 10 f0       	push   $0xf010445a
f0101c40:	68 8f 03 00 00       	push   $0x38f
f0101c45:	68 34 44 10 f0       	push   $0xf0104434
f0101c4a:	e8 3c e4 ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c4f:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101c54:	74 19                	je     f0101c6f <mem_init+0xc35>
f0101c56:	68 4b 46 10 f0       	push   $0xf010464b
f0101c5b:	68 5a 44 10 f0       	push   $0xf010445a
f0101c60:	68 91 03 00 00       	push   $0x391
f0101c65:	68 34 44 10 f0       	push   $0xf0104434
f0101c6a:	e8 1c e4 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101c6f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101c74:	74 19                	je     f0101c8f <mem_init+0xc55>
f0101c76:	68 5c 46 10 f0       	push   $0xf010465c
f0101c7b:	68 5a 44 10 f0       	push   $0xf010445a
f0101c80:	68 92 03 00 00       	push   $0x392
f0101c85:	68 34 44 10 f0       	push   $0xf0104434
f0101c8a:	e8 fc e3 ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c8f:	83 ec 0c             	sub    $0xc,%esp
f0101c92:	6a 00                	push   $0x0
f0101c94:	e8 83 f0 ff ff       	call   f0100d1c <page_alloc>
f0101c99:	83 c4 10             	add    $0x10,%esp
f0101c9c:	85 c0                	test   %eax,%eax
f0101c9e:	74 04                	je     f0101ca4 <mem_init+0xc6a>
f0101ca0:	39 c6                	cmp    %eax,%esi
f0101ca2:	74 19                	je     f0101cbd <mem_init+0xc83>
f0101ca4:	68 d4 41 10 f0       	push   $0xf01041d4
f0101ca9:	68 5a 44 10 f0       	push   $0xf010445a
f0101cae:	68 95 03 00 00       	push   $0x395
f0101cb3:	68 34 44 10 f0       	push   $0xf0104434
f0101cb8:	e8 ce e3 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101cbd:	83 ec 08             	sub    $0x8,%esp
f0101cc0:	6a 00                	push   $0x0
f0101cc2:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0101cc8:	e8 ca f2 ff ff       	call   f0100f97 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ccd:	8b 3d 88 79 11 f0    	mov    0xf0117988,%edi
f0101cd3:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cd8:	89 f8                	mov    %edi,%eax
f0101cda:	e8 79 ec ff ff       	call   f0100958 <check_va2pa>
f0101cdf:	83 c4 10             	add    $0x10,%esp
f0101ce2:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ce5:	74 19                	je     f0101d00 <mem_init+0xcc6>
f0101ce7:	68 f8 41 10 f0       	push   $0xf01041f8
f0101cec:	68 5a 44 10 f0       	push   $0xf010445a
f0101cf1:	68 99 03 00 00       	push   $0x399
f0101cf6:	68 34 44 10 f0       	push   $0xf0104434
f0101cfb:	e8 8b e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d00:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d05:	89 f8                	mov    %edi,%eax
f0101d07:	e8 4c ec ff ff       	call   f0100958 <check_va2pa>
f0101d0c:	89 da                	mov    %ebx,%edx
f0101d0e:	2b 15 8c 79 11 f0    	sub    0xf011798c,%edx
f0101d14:	c1 fa 03             	sar    $0x3,%edx
f0101d17:	c1 e2 0c             	shl    $0xc,%edx
f0101d1a:	39 d0                	cmp    %edx,%eax
f0101d1c:	74 19                	je     f0101d37 <mem_init+0xcfd>
f0101d1e:	68 a4 41 10 f0       	push   $0xf01041a4
f0101d23:	68 5a 44 10 f0       	push   $0xf010445a
f0101d28:	68 9a 03 00 00       	push   $0x39a
f0101d2d:	68 34 44 10 f0       	push   $0xf0104434
f0101d32:	e8 54 e3 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101d37:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d3c:	74 19                	je     f0101d57 <mem_init+0xd1d>
f0101d3e:	68 02 46 10 f0       	push   $0xf0104602
f0101d43:	68 5a 44 10 f0       	push   $0xf010445a
f0101d48:	68 9b 03 00 00       	push   $0x39b
f0101d4d:	68 34 44 10 f0       	push   $0xf0104434
f0101d52:	e8 34 e3 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101d57:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d5c:	74 19                	je     f0101d77 <mem_init+0xd3d>
f0101d5e:	68 5c 46 10 f0       	push   $0xf010465c
f0101d63:	68 5a 44 10 f0       	push   $0xf010445a
f0101d68:	68 9c 03 00 00       	push   $0x39c
f0101d6d:	68 34 44 10 f0       	push   $0xf0104434
f0101d72:	e8 14 e3 ff ff       	call   f010008b <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d77:	6a 00                	push   $0x0
f0101d79:	68 00 10 00 00       	push   $0x1000
f0101d7e:	53                   	push   %ebx
f0101d7f:	57                   	push   %edi
f0101d80:	e8 4d f2 ff ff       	call   f0100fd2 <page_insert>
f0101d85:	83 c4 10             	add    $0x10,%esp
f0101d88:	85 c0                	test   %eax,%eax
f0101d8a:	74 19                	je     f0101da5 <mem_init+0xd6b>
f0101d8c:	68 1c 42 10 f0       	push   $0xf010421c
f0101d91:	68 5a 44 10 f0       	push   $0xf010445a
f0101d96:	68 9f 03 00 00       	push   $0x39f
f0101d9b:	68 34 44 10 f0       	push   $0xf0104434
f0101da0:	e8 e6 e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref);
f0101da5:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101daa:	75 19                	jne    f0101dc5 <mem_init+0xd8b>
f0101dac:	68 6d 46 10 f0       	push   $0xf010466d
f0101db1:	68 5a 44 10 f0       	push   $0xf010445a
f0101db6:	68 a0 03 00 00       	push   $0x3a0
f0101dbb:	68 34 44 10 f0       	push   $0xf0104434
f0101dc0:	e8 c6 e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_link == NULL);
f0101dc5:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101dc8:	74 19                	je     f0101de3 <mem_init+0xda9>
f0101dca:	68 79 46 10 f0       	push   $0xf0104679
f0101dcf:	68 5a 44 10 f0       	push   $0xf010445a
f0101dd4:	68 a1 03 00 00       	push   $0x3a1
f0101dd9:	68 34 44 10 f0       	push   $0xf0104434
f0101dde:	e8 a8 e2 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101de3:	83 ec 08             	sub    $0x8,%esp
f0101de6:	68 00 10 00 00       	push   $0x1000
f0101deb:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0101df1:	e8 a1 f1 ff ff       	call   f0100f97 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101df6:	8b 3d 88 79 11 f0    	mov    0xf0117988,%edi
f0101dfc:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e01:	89 f8                	mov    %edi,%eax
f0101e03:	e8 50 eb ff ff       	call   f0100958 <check_va2pa>
f0101e08:	83 c4 10             	add    $0x10,%esp
f0101e0b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e0e:	74 19                	je     f0101e29 <mem_init+0xdef>
f0101e10:	68 f8 41 10 f0       	push   $0xf01041f8
f0101e15:	68 5a 44 10 f0       	push   $0xf010445a
f0101e1a:	68 a5 03 00 00       	push   $0x3a5
f0101e1f:	68 34 44 10 f0       	push   $0xf0104434
f0101e24:	e8 62 e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101e29:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e2e:	89 f8                	mov    %edi,%eax
f0101e30:	e8 23 eb ff ff       	call   f0100958 <check_va2pa>
f0101e35:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e38:	74 19                	je     f0101e53 <mem_init+0xe19>
f0101e3a:	68 54 42 10 f0       	push   $0xf0104254
f0101e3f:	68 5a 44 10 f0       	push   $0xf010445a
f0101e44:	68 a6 03 00 00       	push   $0x3a6
f0101e49:	68 34 44 10 f0       	push   $0xf0104434
f0101e4e:	e8 38 e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0101e53:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e58:	74 19                	je     f0101e73 <mem_init+0xe39>
f0101e5a:	68 8e 46 10 f0       	push   $0xf010468e
f0101e5f:	68 5a 44 10 f0       	push   $0xf010445a
f0101e64:	68 a7 03 00 00       	push   $0x3a7
f0101e69:	68 34 44 10 f0       	push   $0xf0104434
f0101e6e:	e8 18 e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101e73:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e78:	74 19                	je     f0101e93 <mem_init+0xe59>
f0101e7a:	68 5c 46 10 f0       	push   $0xf010465c
f0101e7f:	68 5a 44 10 f0       	push   $0xf010445a
f0101e84:	68 a8 03 00 00       	push   $0x3a8
f0101e89:	68 34 44 10 f0       	push   $0xf0104434
f0101e8e:	e8 f8 e1 ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101e93:	83 ec 0c             	sub    $0xc,%esp
f0101e96:	6a 00                	push   $0x0
f0101e98:	e8 7f ee ff ff       	call   f0100d1c <page_alloc>
f0101e9d:	83 c4 10             	add    $0x10,%esp
f0101ea0:	85 c0                	test   %eax,%eax
f0101ea2:	74 04                	je     f0101ea8 <mem_init+0xe6e>
f0101ea4:	39 c3                	cmp    %eax,%ebx
f0101ea6:	74 19                	je     f0101ec1 <mem_init+0xe87>
f0101ea8:	68 7c 42 10 f0       	push   $0xf010427c
f0101ead:	68 5a 44 10 f0       	push   $0xf010445a
f0101eb2:	68 ab 03 00 00       	push   $0x3ab
f0101eb7:	68 34 44 10 f0       	push   $0xf0104434
f0101ebc:	e8 ca e1 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101ec1:	83 ec 0c             	sub    $0xc,%esp
f0101ec4:	6a 00                	push   $0x0
f0101ec6:	e8 51 ee ff ff       	call   f0100d1c <page_alloc>
f0101ecb:	83 c4 10             	add    $0x10,%esp
f0101ece:	85 c0                	test   %eax,%eax
f0101ed0:	74 19                	je     f0101eeb <mem_init+0xeb1>
f0101ed2:	68 b0 45 10 f0       	push   $0xf01045b0
f0101ed7:	68 5a 44 10 f0       	push   $0xf010445a
f0101edc:	68 ae 03 00 00       	push   $0x3ae
f0101ee1:	68 34 44 10 f0       	push   $0xf0104434
f0101ee6:	e8 a0 e1 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101eeb:	8b 0d 88 79 11 f0    	mov    0xf0117988,%ecx
f0101ef1:	8b 11                	mov    (%ecx),%edx
f0101ef3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ef9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101efc:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f0101f02:	c1 f8 03             	sar    $0x3,%eax
f0101f05:	c1 e0 0c             	shl    $0xc,%eax
f0101f08:	39 c2                	cmp    %eax,%edx
f0101f0a:	74 19                	je     f0101f25 <mem_init+0xeeb>
f0101f0c:	68 20 3f 10 f0       	push   $0xf0103f20
f0101f11:	68 5a 44 10 f0       	push   $0xf010445a
f0101f16:	68 b1 03 00 00       	push   $0x3b1
f0101f1b:	68 34 44 10 f0       	push   $0xf0104434
f0101f20:	e8 66 e1 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0101f25:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101f2b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f2e:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101f33:	74 19                	je     f0101f4e <mem_init+0xf14>
f0101f35:	68 13 46 10 f0       	push   $0xf0104613
f0101f3a:	68 5a 44 10 f0       	push   $0xf010445a
f0101f3f:	68 b3 03 00 00       	push   $0x3b3
f0101f44:	68 34 44 10 f0       	push   $0xf0104434
f0101f49:	e8 3d e1 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0101f4e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f51:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101f57:	83 ec 0c             	sub    $0xc,%esp
f0101f5a:	50                   	push   %eax
f0101f5b:	e8 33 ee ff ff       	call   f0100d93 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101f60:	83 c4 0c             	add    $0xc,%esp
f0101f63:	6a 01                	push   $0x1
f0101f65:	68 00 10 40 00       	push   $0x401000
f0101f6a:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0101f70:	e8 80 ee ff ff       	call   f0100df5 <pgdir_walk>
f0101f75:	89 c7                	mov    %eax,%edi
f0101f77:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101f7a:	a1 88 79 11 f0       	mov    0xf0117988,%eax
f0101f7f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f82:	8b 40 04             	mov    0x4(%eax),%eax
f0101f85:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f8a:	8b 0d 84 79 11 f0    	mov    0xf0117984,%ecx
f0101f90:	89 c2                	mov    %eax,%edx
f0101f92:	c1 ea 0c             	shr    $0xc,%edx
f0101f95:	83 c4 10             	add    $0x10,%esp
f0101f98:	39 ca                	cmp    %ecx,%edx
f0101f9a:	72 15                	jb     f0101fb1 <mem_init+0xf77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f9c:	50                   	push   %eax
f0101f9d:	68 88 3c 10 f0       	push   $0xf0103c88
f0101fa2:	68 ba 03 00 00       	push   $0x3ba
f0101fa7:	68 34 44 10 f0       	push   $0xf0104434
f0101fac:	e8 da e0 ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f0101fb1:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101fb6:	39 c7                	cmp    %eax,%edi
f0101fb8:	74 19                	je     f0101fd3 <mem_init+0xf99>
f0101fba:	68 9f 46 10 f0       	push   $0xf010469f
f0101fbf:	68 5a 44 10 f0       	push   $0xf010445a
f0101fc4:	68 bb 03 00 00       	push   $0x3bb
f0101fc9:	68 34 44 10 f0       	push   $0xf0104434
f0101fce:	e8 b8 e0 ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f0101fd3:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101fd6:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101fdd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fe0:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101fe6:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f0101fec:	c1 f8 03             	sar    $0x3,%eax
f0101fef:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ff2:	89 c2                	mov    %eax,%edx
f0101ff4:	c1 ea 0c             	shr    $0xc,%edx
f0101ff7:	39 d1                	cmp    %edx,%ecx
f0101ff9:	77 12                	ja     f010200d <mem_init+0xfd3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ffb:	50                   	push   %eax
f0101ffc:	68 88 3c 10 f0       	push   $0xf0103c88
f0102001:	6a 52                	push   $0x52
f0102003:	68 40 44 10 f0       	push   $0xf0104440
f0102008:	e8 7e e0 ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010200d:	83 ec 04             	sub    $0x4,%esp
f0102010:	68 00 10 00 00       	push   $0x1000
f0102015:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f010201a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010201f:	50                   	push   %eax
f0102020:	e8 01 12 00 00       	call   f0103226 <memset>
	page_free(pp0);
f0102025:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102028:	89 3c 24             	mov    %edi,(%esp)
f010202b:	e8 63 ed ff ff       	call   f0100d93 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102030:	83 c4 0c             	add    $0xc,%esp
f0102033:	6a 01                	push   $0x1
f0102035:	6a 00                	push   $0x0
f0102037:	ff 35 88 79 11 f0    	pushl  0xf0117988
f010203d:	e8 b3 ed ff ff       	call   f0100df5 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102042:	89 fa                	mov    %edi,%edx
f0102044:	2b 15 8c 79 11 f0    	sub    0xf011798c,%edx
f010204a:	c1 fa 03             	sar    $0x3,%edx
f010204d:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102050:	89 d0                	mov    %edx,%eax
f0102052:	c1 e8 0c             	shr    $0xc,%eax
f0102055:	83 c4 10             	add    $0x10,%esp
f0102058:	3b 05 84 79 11 f0    	cmp    0xf0117984,%eax
f010205e:	72 12                	jb     f0102072 <mem_init+0x1038>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102060:	52                   	push   %edx
f0102061:	68 88 3c 10 f0       	push   $0xf0103c88
f0102066:	6a 52                	push   $0x52
f0102068:	68 40 44 10 f0       	push   $0xf0104440
f010206d:	e8 19 e0 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0102072:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102078:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010207b:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102081:	f6 00 01             	testb  $0x1,(%eax)
f0102084:	74 19                	je     f010209f <mem_init+0x1065>
f0102086:	68 b7 46 10 f0       	push   $0xf01046b7
f010208b:	68 5a 44 10 f0       	push   $0xf010445a
f0102090:	68 c5 03 00 00       	push   $0x3c5
f0102095:	68 34 44 10 f0       	push   $0xf0104434
f010209a:	e8 ec df ff ff       	call   f010008b <_panic>
f010209f:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01020a2:	39 d0                	cmp    %edx,%eax
f01020a4:	75 db                	jne    f0102081 <mem_init+0x1047>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01020a6:	a1 88 79 11 f0       	mov    0xf0117988,%eax
f01020ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01020b1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020b4:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01020ba:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01020bd:	89 0d 5c 75 11 f0    	mov    %ecx,0xf011755c

	// free the pages we took
	page_free(pp0);
f01020c3:	83 ec 0c             	sub    $0xc,%esp
f01020c6:	50                   	push   %eax
f01020c7:	e8 c7 ec ff ff       	call   f0100d93 <page_free>
	page_free(pp1);
f01020cc:	89 1c 24             	mov    %ebx,(%esp)
f01020cf:	e8 bf ec ff ff       	call   f0100d93 <page_free>
	page_free(pp2);
f01020d4:	89 34 24             	mov    %esi,(%esp)
f01020d7:	e8 b7 ec ff ff       	call   f0100d93 <page_free>

	cprintf("check_page() succeeded!\n");
f01020dc:	c7 04 24 ce 46 10 f0 	movl   $0xf01046ce,(%esp)
f01020e3:	e8 52 06 00 00       	call   f010273a <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01020e8:	a1 84 79 11 f0       	mov    0xf0117984,%eax
f01020ed:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f01020f4:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	
	boot_map_region(kern_pgdir, UPAGES, n, PADDR(pages), PTE_U | PTE_P);
f01020fa:	a1 8c 79 11 f0       	mov    0xf011798c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01020ff:	83 c4 10             	add    $0x10,%esp
f0102102:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102107:	77 15                	ja     f010211e <mem_init+0x10e4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102109:	50                   	push   %eax
f010210a:	68 24 3e 10 f0       	push   $0xf0103e24
f010210f:	68 c6 00 00 00       	push   $0xc6
f0102114:	68 34 44 10 f0       	push   $0xf0104434
f0102119:	e8 6d df ff ff       	call   f010008b <_panic>
f010211e:	83 ec 08             	sub    $0x8,%esp
f0102121:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102123:	05 00 00 00 10       	add    $0x10000000,%eax
f0102128:	50                   	push   %eax
f0102129:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010212e:	a1 88 79 11 f0       	mov    0xf0117988,%eax
f0102133:	e8 87 ed ff ff       	call   f0100ebf <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102138:	83 c4 10             	add    $0x10,%esp
f010213b:	b8 00 d0 10 f0       	mov    $0xf010d000,%eax
f0102140:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102145:	77 15                	ja     f010215c <mem_init+0x1122>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102147:	50                   	push   %eax
f0102148:	68 24 3e 10 f0       	push   $0xf0103e24
f010214d:	68 d3 00 00 00       	push   $0xd3
f0102152:	68 34 44 10 f0       	push   $0xf0104434
f0102157:	e8 2f df ff ff       	call   f010008b <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, 8*PGSIZE, PADDR(bootstack), PTE_W | PTE_P);
f010215c:	83 ec 08             	sub    $0x8,%esp
f010215f:	6a 03                	push   $0x3
f0102161:	68 00 d0 10 00       	push   $0x10d000
f0102166:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010216b:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102170:	a1 88 79 11 f0       	mov    0xf0117988,%eax
f0102175:	e8 45 ed ff ff       	call   f0100ebf <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	//boot_map_region(kern_pgdir, KERNBASE, npages*PGSIZE, PADDR((void*)KERNBASE), PTE_W | PTE_P); //npages*PGSIZE
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff-0xf0000000, 0, PTE_W | PTE_P);
f010217a:	83 c4 08             	add    $0x8,%esp
f010217d:	6a 03                	push   $0x3
f010217f:	6a 00                	push   $0x0
f0102181:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102186:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010218b:	a1 88 79 11 f0       	mov    0xf0117988,%eax
f0102190:	e8 2a ed ff ff       	call   f0100ebf <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102195:	8b 35 88 79 11 f0    	mov    0xf0117988,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010219b:	a1 84 79 11 f0       	mov    0xf0117984,%eax
f01021a0:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01021a3:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01021aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01021af:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021b2:	8b 3d 8c 79 11 f0    	mov    0xf011798c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021b8:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01021bb:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01021be:	bb 00 00 00 00       	mov    $0x0,%ebx
f01021c3:	eb 55                	jmp    f010221a <mem_init+0x11e0>
f01021c5:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01021cb:	89 f0                	mov    %esi,%eax
f01021cd:	e8 86 e7 ff ff       	call   f0100958 <check_va2pa>
f01021d2:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01021d9:	77 15                	ja     f01021f0 <mem_init+0x11b6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021db:	57                   	push   %edi
f01021dc:	68 24 3e 10 f0       	push   $0xf0103e24
f01021e1:	68 08 03 00 00       	push   $0x308
f01021e6:	68 34 44 10 f0       	push   $0xf0104434
f01021eb:	e8 9b de ff ff       	call   f010008b <_panic>
f01021f0:	8d 94 1f 00 00 00 10 	lea    0x10000000(%edi,%ebx,1),%edx
f01021f7:	39 c2                	cmp    %eax,%edx
f01021f9:	74 19                	je     f0102214 <mem_init+0x11da>
f01021fb:	68 a0 42 10 f0       	push   $0xf01042a0
f0102200:	68 5a 44 10 f0       	push   $0xf010445a
f0102205:	68 08 03 00 00       	push   $0x308
f010220a:	68 34 44 10 f0       	push   $0xf0104434
f010220f:	e8 77 de ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102214:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010221a:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010221d:	77 a6                	ja     f01021c5 <mem_init+0x118b>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010221f:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102222:	c1 e7 0c             	shl    $0xc,%edi
f0102225:	bb 00 00 00 00       	mov    $0x0,%ebx
f010222a:	eb 30                	jmp    f010225c <mem_init+0x1222>
f010222c:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102232:	89 f0                	mov    %esi,%eax
f0102234:	e8 1f e7 ff ff       	call   f0100958 <check_va2pa>
f0102239:	39 c3                	cmp    %eax,%ebx
f010223b:	74 19                	je     f0102256 <mem_init+0x121c>
f010223d:	68 d4 42 10 f0       	push   $0xf01042d4
f0102242:	68 5a 44 10 f0       	push   $0xf010445a
f0102247:	68 0d 03 00 00       	push   $0x30d
f010224c:	68 34 44 10 f0       	push   $0xf0104434
f0102251:	e8 35 de ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102256:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010225c:	39 fb                	cmp    %edi,%ebx
f010225e:	72 cc                	jb     f010222c <mem_init+0x11f2>
f0102260:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102265:	89 da                	mov    %ebx,%edx
f0102267:	89 f0                	mov    %esi,%eax
f0102269:	e8 ea e6 ff ff       	call   f0100958 <check_va2pa>
f010226e:	8d 93 00 50 11 10    	lea    0x10115000(%ebx),%edx
f0102274:	39 c2                	cmp    %eax,%edx
f0102276:	74 19                	je     f0102291 <mem_init+0x1257>
f0102278:	68 fc 42 10 f0       	push   $0xf01042fc
f010227d:	68 5a 44 10 f0       	push   $0xf010445a
f0102282:	68 11 03 00 00       	push   $0x311
f0102287:	68 34 44 10 f0       	push   $0xf0104434
f010228c:	e8 fa dd ff ff       	call   f010008b <_panic>
f0102291:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102297:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f010229d:	75 c6                	jne    f0102265 <mem_init+0x122b>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010229f:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01022a4:	89 f0                	mov    %esi,%eax
f01022a6:	e8 ad e6 ff ff       	call   f0100958 <check_va2pa>
f01022ab:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022ae:	74 51                	je     f0102301 <mem_init+0x12c7>
f01022b0:	68 44 43 10 f0       	push   $0xf0104344
f01022b5:	68 5a 44 10 f0       	push   $0xf010445a
f01022ba:	68 12 03 00 00       	push   $0x312
f01022bf:	68 34 44 10 f0       	push   $0xf0104434
f01022c4:	e8 c2 dd ff ff       	call   f010008b <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01022c9:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01022ce:	72 36                	jb     f0102306 <mem_init+0x12cc>
f01022d0:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01022d5:	76 07                	jbe    f01022de <mem_init+0x12a4>
f01022d7:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01022dc:	75 28                	jne    f0102306 <mem_init+0x12cc>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f01022de:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f01022e2:	0f 85 83 00 00 00    	jne    f010236b <mem_init+0x1331>
f01022e8:	68 e7 46 10 f0       	push   $0xf01046e7
f01022ed:	68 5a 44 10 f0       	push   $0xf010445a
f01022f2:	68 1a 03 00 00       	push   $0x31a
f01022f7:	68 34 44 10 f0       	push   $0xf0104434
f01022fc:	e8 8a dd ff ff       	call   f010008b <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102301:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102306:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010230b:	76 3f                	jbe    f010234c <mem_init+0x1312>
				assert(pgdir[i] & PTE_P);
f010230d:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102310:	f6 c2 01             	test   $0x1,%dl
f0102313:	75 19                	jne    f010232e <mem_init+0x12f4>
f0102315:	68 e7 46 10 f0       	push   $0xf01046e7
f010231a:	68 5a 44 10 f0       	push   $0xf010445a
f010231f:	68 1e 03 00 00       	push   $0x31e
f0102324:	68 34 44 10 f0       	push   $0xf0104434
f0102329:	e8 5d dd ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f010232e:	f6 c2 02             	test   $0x2,%dl
f0102331:	75 38                	jne    f010236b <mem_init+0x1331>
f0102333:	68 f8 46 10 f0       	push   $0xf01046f8
f0102338:	68 5a 44 10 f0       	push   $0xf010445a
f010233d:	68 1f 03 00 00       	push   $0x31f
f0102342:	68 34 44 10 f0       	push   $0xf0104434
f0102347:	e8 3f dd ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f010234c:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102350:	74 19                	je     f010236b <mem_init+0x1331>
f0102352:	68 09 47 10 f0       	push   $0xf0104709
f0102357:	68 5a 44 10 f0       	push   $0xf010445a
f010235c:	68 21 03 00 00       	push   $0x321
f0102361:	68 34 44 10 f0       	push   $0xf0104434
f0102366:	e8 20 dd ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010236b:	83 c0 01             	add    $0x1,%eax
f010236e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102373:	0f 86 50 ff ff ff    	jbe    f01022c9 <mem_init+0x128f>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102379:	83 ec 0c             	sub    $0xc,%esp
f010237c:	68 74 43 10 f0       	push   $0xf0104374
f0102381:	e8 b4 03 00 00       	call   f010273a <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102386:	a1 88 79 11 f0       	mov    0xf0117988,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010238b:	83 c4 10             	add    $0x10,%esp
f010238e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102393:	77 15                	ja     f01023aa <mem_init+0x1370>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102395:	50                   	push   %eax
f0102396:	68 24 3e 10 f0       	push   $0xf0103e24
f010239b:	68 ea 00 00 00       	push   $0xea
f01023a0:	68 34 44 10 f0       	push   $0xf0104434
f01023a5:	e8 e1 dc ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f01023aa:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01023af:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01023b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01023b7:	e8 00 e6 ff ff       	call   f01009bc <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01023bc:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f01023bf:	83 e0 f3             	and    $0xfffffff3,%eax
f01023c2:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01023c7:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01023ca:	83 ec 0c             	sub    $0xc,%esp
f01023cd:	6a 00                	push   $0x0
f01023cf:	e8 48 e9 ff ff       	call   f0100d1c <page_alloc>
f01023d4:	89 c3                	mov    %eax,%ebx
f01023d6:	83 c4 10             	add    $0x10,%esp
f01023d9:	85 c0                	test   %eax,%eax
f01023db:	75 19                	jne    f01023f6 <mem_init+0x13bc>
f01023dd:	68 05 45 10 f0       	push   $0xf0104505
f01023e2:	68 5a 44 10 f0       	push   $0xf010445a
f01023e7:	68 e0 03 00 00       	push   $0x3e0
f01023ec:	68 34 44 10 f0       	push   $0xf0104434
f01023f1:	e8 95 dc ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01023f6:	83 ec 0c             	sub    $0xc,%esp
f01023f9:	6a 00                	push   $0x0
f01023fb:	e8 1c e9 ff ff       	call   f0100d1c <page_alloc>
f0102400:	89 c7                	mov    %eax,%edi
f0102402:	83 c4 10             	add    $0x10,%esp
f0102405:	85 c0                	test   %eax,%eax
f0102407:	75 19                	jne    f0102422 <mem_init+0x13e8>
f0102409:	68 1b 45 10 f0       	push   $0xf010451b
f010240e:	68 5a 44 10 f0       	push   $0xf010445a
f0102413:	68 e1 03 00 00       	push   $0x3e1
f0102418:	68 34 44 10 f0       	push   $0xf0104434
f010241d:	e8 69 dc ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0102422:	83 ec 0c             	sub    $0xc,%esp
f0102425:	6a 00                	push   $0x0
f0102427:	e8 f0 e8 ff ff       	call   f0100d1c <page_alloc>
f010242c:	89 c6                	mov    %eax,%esi
f010242e:	83 c4 10             	add    $0x10,%esp
f0102431:	85 c0                	test   %eax,%eax
f0102433:	75 19                	jne    f010244e <mem_init+0x1414>
f0102435:	68 31 45 10 f0       	push   $0xf0104531
f010243a:	68 5a 44 10 f0       	push   $0xf010445a
f010243f:	68 e2 03 00 00       	push   $0x3e2
f0102444:	68 34 44 10 f0       	push   $0xf0104434
f0102449:	e8 3d dc ff ff       	call   f010008b <_panic>
	page_free(pp0);
f010244e:	83 ec 0c             	sub    $0xc,%esp
f0102451:	53                   	push   %ebx
f0102452:	e8 3c e9 ff ff       	call   f0100d93 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102457:	89 f8                	mov    %edi,%eax
f0102459:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f010245f:	c1 f8 03             	sar    $0x3,%eax
f0102462:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102465:	89 c2                	mov    %eax,%edx
f0102467:	c1 ea 0c             	shr    $0xc,%edx
f010246a:	83 c4 10             	add    $0x10,%esp
f010246d:	3b 15 84 79 11 f0    	cmp    0xf0117984,%edx
f0102473:	72 12                	jb     f0102487 <mem_init+0x144d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102475:	50                   	push   %eax
f0102476:	68 88 3c 10 f0       	push   $0xf0103c88
f010247b:	6a 52                	push   $0x52
f010247d:	68 40 44 10 f0       	push   $0xf0104440
f0102482:	e8 04 dc ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102487:	83 ec 04             	sub    $0x4,%esp
f010248a:	68 00 10 00 00       	push   $0x1000
f010248f:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102491:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102496:	50                   	push   %eax
f0102497:	e8 8a 0d 00 00       	call   f0103226 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010249c:	89 f0                	mov    %esi,%eax
f010249e:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f01024a4:	c1 f8 03             	sar    $0x3,%eax
f01024a7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024aa:	89 c2                	mov    %eax,%edx
f01024ac:	c1 ea 0c             	shr    $0xc,%edx
f01024af:	83 c4 10             	add    $0x10,%esp
f01024b2:	3b 15 84 79 11 f0    	cmp    0xf0117984,%edx
f01024b8:	72 12                	jb     f01024cc <mem_init+0x1492>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024ba:	50                   	push   %eax
f01024bb:	68 88 3c 10 f0       	push   $0xf0103c88
f01024c0:	6a 52                	push   $0x52
f01024c2:	68 40 44 10 f0       	push   $0xf0104440
f01024c7:	e8 bf db ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01024cc:	83 ec 04             	sub    $0x4,%esp
f01024cf:	68 00 10 00 00       	push   $0x1000
f01024d4:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f01024d6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024db:	50                   	push   %eax
f01024dc:	e8 45 0d 00 00       	call   f0103226 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01024e1:	6a 02                	push   $0x2
f01024e3:	68 00 10 00 00       	push   $0x1000
f01024e8:	57                   	push   %edi
f01024e9:	ff 35 88 79 11 f0    	pushl  0xf0117988
f01024ef:	e8 de ea ff ff       	call   f0100fd2 <page_insert>
	assert(pp1->pp_ref == 1);
f01024f4:	83 c4 20             	add    $0x20,%esp
f01024f7:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01024fc:	74 19                	je     f0102517 <mem_init+0x14dd>
f01024fe:	68 02 46 10 f0       	push   $0xf0104602
f0102503:	68 5a 44 10 f0       	push   $0xf010445a
f0102508:	68 e7 03 00 00       	push   $0x3e7
f010250d:	68 34 44 10 f0       	push   $0xf0104434
f0102512:	e8 74 db ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102517:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010251e:	01 01 01 
f0102521:	74 19                	je     f010253c <mem_init+0x1502>
f0102523:	68 94 43 10 f0       	push   $0xf0104394
f0102528:	68 5a 44 10 f0       	push   $0xf010445a
f010252d:	68 e8 03 00 00       	push   $0x3e8
f0102532:	68 34 44 10 f0       	push   $0xf0104434
f0102537:	e8 4f db ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010253c:	6a 02                	push   $0x2
f010253e:	68 00 10 00 00       	push   $0x1000
f0102543:	56                   	push   %esi
f0102544:	ff 35 88 79 11 f0    	pushl  0xf0117988
f010254a:	e8 83 ea ff ff       	call   f0100fd2 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010254f:	83 c4 10             	add    $0x10,%esp
f0102552:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102559:	02 02 02 
f010255c:	74 19                	je     f0102577 <mem_init+0x153d>
f010255e:	68 b8 43 10 f0       	push   $0xf01043b8
f0102563:	68 5a 44 10 f0       	push   $0xf010445a
f0102568:	68 ea 03 00 00       	push   $0x3ea
f010256d:	68 34 44 10 f0       	push   $0xf0104434
f0102572:	e8 14 db ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0102577:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010257c:	74 19                	je     f0102597 <mem_init+0x155d>
f010257e:	68 24 46 10 f0       	push   $0xf0104624
f0102583:	68 5a 44 10 f0       	push   $0xf010445a
f0102588:	68 eb 03 00 00       	push   $0x3eb
f010258d:	68 34 44 10 f0       	push   $0xf0104434
f0102592:	e8 f4 da ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0102597:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010259c:	74 19                	je     f01025b7 <mem_init+0x157d>
f010259e:	68 8e 46 10 f0       	push   $0xf010468e
f01025a3:	68 5a 44 10 f0       	push   $0xf010445a
f01025a8:	68 ec 03 00 00       	push   $0x3ec
f01025ad:	68 34 44 10 f0       	push   $0xf0104434
f01025b2:	e8 d4 da ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01025b7:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01025be:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025c1:	89 f0                	mov    %esi,%eax
f01025c3:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f01025c9:	c1 f8 03             	sar    $0x3,%eax
f01025cc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025cf:	89 c2                	mov    %eax,%edx
f01025d1:	c1 ea 0c             	shr    $0xc,%edx
f01025d4:	3b 15 84 79 11 f0    	cmp    0xf0117984,%edx
f01025da:	72 12                	jb     f01025ee <mem_init+0x15b4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025dc:	50                   	push   %eax
f01025dd:	68 88 3c 10 f0       	push   $0xf0103c88
f01025e2:	6a 52                	push   $0x52
f01025e4:	68 40 44 10 f0       	push   $0xf0104440
f01025e9:	e8 9d da ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01025ee:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01025f5:	03 03 03 
f01025f8:	74 19                	je     f0102613 <mem_init+0x15d9>
f01025fa:	68 dc 43 10 f0       	push   $0xf01043dc
f01025ff:	68 5a 44 10 f0       	push   $0xf010445a
f0102604:	68 ee 03 00 00       	push   $0x3ee
f0102609:	68 34 44 10 f0       	push   $0xf0104434
f010260e:	e8 78 da ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102613:	83 ec 08             	sub    $0x8,%esp
f0102616:	68 00 10 00 00       	push   $0x1000
f010261b:	ff 35 88 79 11 f0    	pushl  0xf0117988
f0102621:	e8 71 e9 ff ff       	call   f0100f97 <page_remove>
	assert(pp2->pp_ref == 0);
f0102626:	83 c4 10             	add    $0x10,%esp
f0102629:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010262e:	74 19                	je     f0102649 <mem_init+0x160f>
f0102630:	68 5c 46 10 f0       	push   $0xf010465c
f0102635:	68 5a 44 10 f0       	push   $0xf010445a
f010263a:	68 f0 03 00 00       	push   $0x3f0
f010263f:	68 34 44 10 f0       	push   $0xf0104434
f0102644:	e8 42 da ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102649:	8b 0d 88 79 11 f0    	mov    0xf0117988,%ecx
f010264f:	8b 11                	mov    (%ecx),%edx
f0102651:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102657:	89 d8                	mov    %ebx,%eax
f0102659:	2b 05 8c 79 11 f0    	sub    0xf011798c,%eax
f010265f:	c1 f8 03             	sar    $0x3,%eax
f0102662:	c1 e0 0c             	shl    $0xc,%eax
f0102665:	39 c2                	cmp    %eax,%edx
f0102667:	74 19                	je     f0102682 <mem_init+0x1648>
f0102669:	68 20 3f 10 f0       	push   $0xf0103f20
f010266e:	68 5a 44 10 f0       	push   $0xf010445a
f0102673:	68 f3 03 00 00       	push   $0x3f3
f0102678:	68 34 44 10 f0       	push   $0xf0104434
f010267d:	e8 09 da ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102682:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102688:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010268d:	74 19                	je     f01026a8 <mem_init+0x166e>
f010268f:	68 13 46 10 f0       	push   $0xf0104613
f0102694:	68 5a 44 10 f0       	push   $0xf010445a
f0102699:	68 f5 03 00 00       	push   $0x3f5
f010269e:	68 34 44 10 f0       	push   $0xf0104434
f01026a3:	e8 e3 d9 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f01026a8:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01026ae:	83 ec 0c             	sub    $0xc,%esp
f01026b1:	53                   	push   %ebx
f01026b2:	e8 dc e6 ff ff       	call   f0100d93 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01026b7:	c7 04 24 08 44 10 f0 	movl   $0xf0104408,(%esp)
f01026be:	e8 77 00 00 00       	call   f010273a <cprintf>
f01026c3:	83 c4 10             	add    $0x10,%esp
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01026c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01026c9:	5b                   	pop    %ebx
f01026ca:	5e                   	pop    %esi
f01026cb:	5f                   	pop    %edi
f01026cc:	5d                   	pop    %ebp
f01026cd:	c3                   	ret    

f01026ce <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01026ce:	55                   	push   %ebp
f01026cf:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01026d1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01026d4:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01026d7:	5d                   	pop    %ebp
f01026d8:	c3                   	ret    

f01026d9 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01026d9:	55                   	push   %ebp
f01026da:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01026dc:	ba 70 00 00 00       	mov    $0x70,%edx
f01026e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01026e4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01026e5:	b2 71                	mov    $0x71,%dl
f01026e7:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01026e8:	0f b6 c0             	movzbl %al,%eax
}
f01026eb:	5d                   	pop    %ebp
f01026ec:	c3                   	ret    

f01026ed <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01026ed:	55                   	push   %ebp
f01026ee:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01026f0:	ba 70 00 00 00       	mov    $0x70,%edx
f01026f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01026f8:	ee                   	out    %al,(%dx)
f01026f9:	b2 71                	mov    $0x71,%dl
f01026fb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01026fe:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01026ff:	5d                   	pop    %ebp
f0102700:	c3                   	ret    

f0102701 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102701:	55                   	push   %ebp
f0102702:	89 e5                	mov    %esp,%ebp
f0102704:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102707:	ff 75 08             	pushl  0x8(%ebp)
f010270a:	e8 d1 de ff ff       	call   f01005e0 <cputchar>
f010270f:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0102712:	c9                   	leave  
f0102713:	c3                   	ret    

f0102714 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102714:	55                   	push   %ebp
f0102715:	89 e5                	mov    %esp,%ebp
f0102717:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010271a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102721:	ff 75 0c             	pushl  0xc(%ebp)
f0102724:	ff 75 08             	pushl  0x8(%ebp)
f0102727:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010272a:	50                   	push   %eax
f010272b:	68 01 27 10 f0       	push   $0xf0102701
f0102730:	e8 7e 04 00 00       	call   f0102bb3 <vprintfmt>
	return cnt;
}
f0102735:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102738:	c9                   	leave  
f0102739:	c3                   	ret    

f010273a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010273a:	55                   	push   %ebp
f010273b:	89 e5                	mov    %esp,%ebp
f010273d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102740:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102743:	50                   	push   %eax
f0102744:	ff 75 08             	pushl  0x8(%ebp)
f0102747:	e8 c8 ff ff ff       	call   f0102714 <vcprintf>
	va_end(ap);

	return cnt;
}
f010274c:	c9                   	leave  
f010274d:	c3                   	ret    

f010274e <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010274e:	55                   	push   %ebp
f010274f:	89 e5                	mov    %esp,%ebp
f0102751:	57                   	push   %edi
f0102752:	56                   	push   %esi
f0102753:	53                   	push   %ebx
f0102754:	83 ec 14             	sub    $0x14,%esp
f0102757:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010275a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010275d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102760:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102763:	8b 1a                	mov    (%edx),%ebx
f0102765:	8b 01                	mov    (%ecx),%eax
f0102767:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010276a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0102771:	e9 88 00 00 00       	jmp    f01027fe <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0102776:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102779:	01 d8                	add    %ebx,%eax
f010277b:	89 c6                	mov    %eax,%esi
f010277d:	c1 ee 1f             	shr    $0x1f,%esi
f0102780:	01 c6                	add    %eax,%esi
f0102782:	d1 fe                	sar    %esi
f0102784:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0102787:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010278a:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010278d:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010278f:	eb 03                	jmp    f0102794 <stab_binsearch+0x46>
			m--;
f0102791:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102794:	39 c3                	cmp    %eax,%ebx
f0102796:	7f 1f                	jg     f01027b7 <stab_binsearch+0x69>
f0102798:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010279c:	83 ea 0c             	sub    $0xc,%edx
f010279f:	39 f9                	cmp    %edi,%ecx
f01027a1:	75 ee                	jne    f0102791 <stab_binsearch+0x43>
f01027a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01027a6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01027a9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01027ac:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01027b0:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01027b3:	76 18                	jbe    f01027cd <stab_binsearch+0x7f>
f01027b5:	eb 05                	jmp    f01027bc <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01027b7:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01027ba:	eb 42                	jmp    f01027fe <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01027bc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01027bf:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01027c1:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01027c4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01027cb:	eb 31                	jmp    f01027fe <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01027cd:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01027d0:	73 17                	jae    f01027e9 <stab_binsearch+0x9b>
			*region_right = m - 1;
f01027d2:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01027d5:	83 e8 01             	sub    $0x1,%eax
f01027d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01027db:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01027de:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01027e0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01027e7:	eb 15                	jmp    f01027fe <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01027e9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01027ec:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01027ef:	89 1e                	mov    %ebx,(%esi)
			l = m;
			addr++;
f01027f1:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01027f5:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01027f7:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01027fe:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0102801:	0f 8e 6f ff ff ff    	jle    f0102776 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102807:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010280b:	75 0f                	jne    f010281c <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f010280d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102810:	8b 00                	mov    (%eax),%eax
f0102812:	83 e8 01             	sub    $0x1,%eax
f0102815:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102818:	89 06                	mov    %eax,(%esi)
f010281a:	eb 2c                	jmp    f0102848 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010281c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010281f:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102821:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102824:	8b 0e                	mov    (%esi),%ecx
f0102826:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102829:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010282c:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010282f:	eb 03                	jmp    f0102834 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102831:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102834:	39 c8                	cmp    %ecx,%eax
f0102836:	7e 0b                	jle    f0102843 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0102838:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010283c:	83 ea 0c             	sub    $0xc,%edx
f010283f:	39 fb                	cmp    %edi,%ebx
f0102841:	75 ee                	jne    f0102831 <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102843:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102846:	89 06                	mov    %eax,(%esi)
	}
}
f0102848:	83 c4 14             	add    $0x14,%esp
f010284b:	5b                   	pop    %ebx
f010284c:	5e                   	pop    %esi
f010284d:	5f                   	pop    %edi
f010284e:	5d                   	pop    %ebp
f010284f:	c3                   	ret    

f0102850 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102850:	55                   	push   %ebp
f0102851:	89 e5                	mov    %esp,%ebp
f0102853:	57                   	push   %edi
f0102854:	56                   	push   %esi
f0102855:	53                   	push   %ebx
f0102856:	83 ec 3c             	sub    $0x3c,%esp
f0102859:	8b 75 08             	mov    0x8(%ebp),%esi
f010285c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010285f:	c7 03 17 47 10 f0    	movl   $0xf0104717,(%ebx)
	info->eip_line = 0;
f0102865:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010286c:	c7 43 08 17 47 10 f0 	movl   $0xf0104717,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102873:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010287a:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010287d:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102884:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010288a:	76 11                	jbe    f010289d <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010288c:	b8 55 c4 10 f0       	mov    $0xf010c455,%eax
f0102891:	3d ad a6 10 f0       	cmp    $0xf010a6ad,%eax
f0102896:	77 19                	ja     f01028b1 <debuginfo_eip+0x61>
f0102898:	e9 a9 01 00 00       	jmp    f0102a46 <debuginfo_eip+0x1f6>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f010289d:	83 ec 04             	sub    $0x4,%esp
f01028a0:	68 21 47 10 f0       	push   $0xf0104721
f01028a5:	6a 7f                	push   $0x7f
f01028a7:	68 2e 47 10 f0       	push   $0xf010472e
f01028ac:	e8 da d7 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01028b1:	80 3d 54 c4 10 f0 00 	cmpb   $0x0,0xf010c454
f01028b8:	0f 85 8f 01 00 00    	jne    f0102a4d <debuginfo_eip+0x1fd>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01028be:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01028c5:	b8 ac a6 10 f0       	mov    $0xf010a6ac,%eax
f01028ca:	2d 70 49 10 f0       	sub    $0xf0104970,%eax
f01028cf:	c1 f8 02             	sar    $0x2,%eax
f01028d2:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01028d8:	83 e8 01             	sub    $0x1,%eax
f01028db:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01028de:	83 ec 08             	sub    $0x8,%esp
f01028e1:	56                   	push   %esi
f01028e2:	6a 64                	push   $0x64
f01028e4:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01028e7:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01028ea:	b8 70 49 10 f0       	mov    $0xf0104970,%eax
f01028ef:	e8 5a fe ff ff       	call   f010274e <stab_binsearch>
	if (lfile == 0)
f01028f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01028f7:	83 c4 10             	add    $0x10,%esp
f01028fa:	85 c0                	test   %eax,%eax
f01028fc:	0f 84 52 01 00 00    	je     f0102a54 <debuginfo_eip+0x204>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102902:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102905:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102908:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010290b:	83 ec 08             	sub    $0x8,%esp
f010290e:	56                   	push   %esi
f010290f:	6a 24                	push   $0x24
f0102911:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102914:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102917:	b8 70 49 10 f0       	mov    $0xf0104970,%eax
f010291c:	e8 2d fe ff ff       	call   f010274e <stab_binsearch>

	if (lfun <= rfun) {
f0102921:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102924:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102927:	83 c4 10             	add    $0x10,%esp
f010292a:	39 d0                	cmp    %edx,%eax
f010292c:	7f 40                	jg     f010296e <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010292e:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0102931:	c1 e1 02             	shl    $0x2,%ecx
f0102934:	8d b9 70 49 10 f0    	lea    -0xfefb690(%ecx),%edi
f010293a:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f010293d:	8b b9 70 49 10 f0    	mov    -0xfefb690(%ecx),%edi
f0102943:	b9 55 c4 10 f0       	mov    $0xf010c455,%ecx
f0102948:	81 e9 ad a6 10 f0    	sub    $0xf010a6ad,%ecx
f010294e:	39 cf                	cmp    %ecx,%edi
f0102950:	73 09                	jae    f010295b <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102952:	81 c7 ad a6 10 f0    	add    $0xf010a6ad,%edi
f0102958:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010295b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010295e:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102961:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102964:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102966:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102969:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010296c:	eb 0f                	jmp    f010297d <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010296e:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102971:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102974:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102977:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010297a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010297d:	83 ec 08             	sub    $0x8,%esp
f0102980:	6a 3a                	push   $0x3a
f0102982:	ff 73 08             	pushl  0x8(%ebx)
f0102985:	e8 80 08 00 00       	call   f010320a <strfind>
f010298a:	2b 43 08             	sub    0x8(%ebx),%eax
f010298d:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102990:	83 c4 08             	add    $0x8,%esp
f0102993:	56                   	push   %esi
f0102994:	6a 44                	push   $0x44
f0102996:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102999:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010299c:	b8 70 49 10 f0       	mov    $0xf0104970,%eax
f01029a1:	e8 a8 fd ff ff       	call   f010274e <stab_binsearch>
	if(lline>rline)
f01029a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029a9:	83 c4 10             	add    $0x10,%esp
f01029ac:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01029af:	0f 8f a6 00 00 00    	jg     f0102a5b <debuginfo_eip+0x20b>
	{
		return -1;
	}
	else
		info->eip_line = stabs[lline].n_desc;
f01029b5:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01029b8:	0f b7 04 85 76 49 10 	movzwl -0xfefb68a(,%eax,4),%eax
f01029bf:	f0 
f01029c0:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01029c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01029c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029c9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01029cc:	8d 14 95 70 49 10 f0 	lea    -0xfefb690(,%edx,4),%edx
f01029d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01029d6:	eb 06                	jmp    f01029de <debuginfo_eip+0x18e>
f01029d8:	83 e8 01             	sub    $0x1,%eax
f01029db:	83 ea 0c             	sub    $0xc,%edx
f01029de:	39 c7                	cmp    %eax,%edi
f01029e0:	7f 23                	jg     f0102a05 <debuginfo_eip+0x1b5>
	       && stabs[lline].n_type != N_SOL
f01029e2:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01029e6:	80 f9 84             	cmp    $0x84,%cl
f01029e9:	74 7e                	je     f0102a69 <debuginfo_eip+0x219>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01029eb:	80 f9 64             	cmp    $0x64,%cl
f01029ee:	75 e8                	jne    f01029d8 <debuginfo_eip+0x188>
f01029f0:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f01029f4:	74 e2                	je     f01029d8 <debuginfo_eip+0x188>
f01029f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01029f9:	eb 71                	jmp    f0102a6c <debuginfo_eip+0x21c>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01029fb:	81 c2 ad a6 10 f0    	add    $0xf010a6ad,%edx
f0102a01:	89 13                	mov    %edx,(%ebx)
f0102a03:	eb 03                	jmp    f0102a08 <debuginfo_eip+0x1b8>
f0102a05:	8b 5d 0c             	mov    0xc(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102a08:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102a0b:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102a0e:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102a13:	39 f2                	cmp    %esi,%edx
f0102a15:	7d 76                	jge    f0102a8d <debuginfo_eip+0x23d>
		for (lline = lfun + 1;
f0102a17:	83 c2 01             	add    $0x1,%edx
f0102a1a:	89 d0                	mov    %edx,%eax
f0102a1c:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102a1f:	8d 14 95 70 49 10 f0 	lea    -0xfefb690(,%edx,4),%edx
f0102a26:	eb 04                	jmp    f0102a2c <debuginfo_eip+0x1dc>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102a28:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102a2c:	39 c6                	cmp    %eax,%esi
f0102a2e:	7e 32                	jle    f0102a62 <debuginfo_eip+0x212>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102a30:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102a34:	83 c0 01             	add    $0x1,%eax
f0102a37:	83 c2 0c             	add    $0xc,%edx
f0102a3a:	80 f9 a0             	cmp    $0xa0,%cl
f0102a3d:	74 e9                	je     f0102a28 <debuginfo_eip+0x1d8>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102a3f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a44:	eb 47                	jmp    f0102a8d <debuginfo_eip+0x23d>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102a46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102a4b:	eb 40                	jmp    f0102a8d <debuginfo_eip+0x23d>
f0102a4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102a52:	eb 39                	jmp    f0102a8d <debuginfo_eip+0x23d>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0102a54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102a59:	eb 32                	jmp    f0102a8d <debuginfo_eip+0x23d>
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if(lline>rline)
	{
		return -1;
f0102a5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102a60:	eb 2b                	jmp    f0102a8d <debuginfo_eip+0x23d>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102a62:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a67:	eb 24                	jmp    f0102a8d <debuginfo_eip+0x23d>
f0102a69:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102a6c:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102a6f:	8b 14 85 70 49 10 f0 	mov    -0xfefb690(,%eax,4),%edx
f0102a76:	b8 55 c4 10 f0       	mov    $0xf010c455,%eax
f0102a7b:	2d ad a6 10 f0       	sub    $0xf010a6ad,%eax
f0102a80:	39 c2                	cmp    %eax,%edx
f0102a82:	0f 82 73 ff ff ff    	jb     f01029fb <debuginfo_eip+0x1ab>
f0102a88:	e9 7b ff ff ff       	jmp    f0102a08 <debuginfo_eip+0x1b8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
}
f0102a8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102a90:	5b                   	pop    %ebx
f0102a91:	5e                   	pop    %esi
f0102a92:	5f                   	pop    %edi
f0102a93:	5d                   	pop    %ebp
f0102a94:	c3                   	ret    

f0102a95 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102a95:	55                   	push   %ebp
f0102a96:	89 e5                	mov    %esp,%ebp
f0102a98:	57                   	push   %edi
f0102a99:	56                   	push   %esi
f0102a9a:	53                   	push   %ebx
f0102a9b:	83 ec 1c             	sub    $0x1c,%esp
f0102a9e:	89 c7                	mov    %eax,%edi
f0102aa0:	89 d6                	mov    %edx,%esi
f0102aa2:	8b 45 08             	mov    0x8(%ebp),%eax
f0102aa5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102aa8:	89 d1                	mov    %edx,%ecx
f0102aaa:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102aad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102ab0:	8b 45 10             	mov    0x10(%ebp),%eax
f0102ab3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102ab6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102ab9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0102ac0:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f0102ac3:	72 05                	jb     f0102aca <printnum+0x35>
f0102ac5:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0102ac8:	77 3e                	ja     f0102b08 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102aca:	83 ec 0c             	sub    $0xc,%esp
f0102acd:	ff 75 18             	pushl  0x18(%ebp)
f0102ad0:	83 eb 01             	sub    $0x1,%ebx
f0102ad3:	53                   	push   %ebx
f0102ad4:	50                   	push   %eax
f0102ad5:	83 ec 08             	sub    $0x8,%esp
f0102ad8:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102adb:	ff 75 e0             	pushl  -0x20(%ebp)
f0102ade:	ff 75 dc             	pushl  -0x24(%ebp)
f0102ae1:	ff 75 d8             	pushl  -0x28(%ebp)
f0102ae4:	e8 47 09 00 00       	call   f0103430 <__udivdi3>
f0102ae9:	83 c4 18             	add    $0x18,%esp
f0102aec:	52                   	push   %edx
f0102aed:	50                   	push   %eax
f0102aee:	89 f2                	mov    %esi,%edx
f0102af0:	89 f8                	mov    %edi,%eax
f0102af2:	e8 9e ff ff ff       	call   f0102a95 <printnum>
f0102af7:	83 c4 20             	add    $0x20,%esp
f0102afa:	eb 13                	jmp    f0102b0f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102afc:	83 ec 08             	sub    $0x8,%esp
f0102aff:	56                   	push   %esi
f0102b00:	ff 75 18             	pushl  0x18(%ebp)
f0102b03:	ff d7                	call   *%edi
f0102b05:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102b08:	83 eb 01             	sub    $0x1,%ebx
f0102b0b:	85 db                	test   %ebx,%ebx
f0102b0d:	7f ed                	jg     f0102afc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102b0f:	83 ec 08             	sub    $0x8,%esp
f0102b12:	56                   	push   %esi
f0102b13:	83 ec 04             	sub    $0x4,%esp
f0102b16:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102b19:	ff 75 e0             	pushl  -0x20(%ebp)
f0102b1c:	ff 75 dc             	pushl  -0x24(%ebp)
f0102b1f:	ff 75 d8             	pushl  -0x28(%ebp)
f0102b22:	e8 39 0a 00 00       	call   f0103560 <__umoddi3>
f0102b27:	83 c4 14             	add    $0x14,%esp
f0102b2a:	0f be 80 3c 47 10 f0 	movsbl -0xfefb8c4(%eax),%eax
f0102b31:	50                   	push   %eax
f0102b32:	ff d7                	call   *%edi
f0102b34:	83 c4 10             	add    $0x10,%esp
}
f0102b37:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102b3a:	5b                   	pop    %ebx
f0102b3b:	5e                   	pop    %esi
f0102b3c:	5f                   	pop    %edi
f0102b3d:	5d                   	pop    %ebp
f0102b3e:	c3                   	ret    

f0102b3f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102b3f:	55                   	push   %ebp
f0102b40:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102b42:	83 fa 01             	cmp    $0x1,%edx
f0102b45:	7e 0e                	jle    f0102b55 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0102b47:	8b 10                	mov    (%eax),%edx
f0102b49:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102b4c:	89 08                	mov    %ecx,(%eax)
f0102b4e:	8b 02                	mov    (%edx),%eax
f0102b50:	8b 52 04             	mov    0x4(%edx),%edx
f0102b53:	eb 22                	jmp    f0102b77 <getuint+0x38>
	else if (lflag)
f0102b55:	85 d2                	test   %edx,%edx
f0102b57:	74 10                	je     f0102b69 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102b59:	8b 10                	mov    (%eax),%edx
f0102b5b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102b5e:	89 08                	mov    %ecx,(%eax)
f0102b60:	8b 02                	mov    (%edx),%eax
f0102b62:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b67:	eb 0e                	jmp    f0102b77 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102b69:	8b 10                	mov    (%eax),%edx
f0102b6b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102b6e:	89 08                	mov    %ecx,(%eax)
f0102b70:	8b 02                	mov    (%edx),%eax
f0102b72:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102b77:	5d                   	pop    %ebp
f0102b78:	c3                   	ret    

f0102b79 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102b79:	55                   	push   %ebp
f0102b7a:	89 e5                	mov    %esp,%ebp
f0102b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102b7f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102b83:	8b 10                	mov    (%eax),%edx
f0102b85:	3b 50 04             	cmp    0x4(%eax),%edx
f0102b88:	73 0a                	jae    f0102b94 <sprintputch+0x1b>
		*b->buf++ = ch;
f0102b8a:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102b8d:	89 08                	mov    %ecx,(%eax)
f0102b8f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b92:	88 02                	mov    %al,(%edx)
}
f0102b94:	5d                   	pop    %ebp
f0102b95:	c3                   	ret    

f0102b96 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102b96:	55                   	push   %ebp
f0102b97:	89 e5                	mov    %esp,%ebp
f0102b99:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102b9c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102b9f:	50                   	push   %eax
f0102ba0:	ff 75 10             	pushl  0x10(%ebp)
f0102ba3:	ff 75 0c             	pushl  0xc(%ebp)
f0102ba6:	ff 75 08             	pushl  0x8(%ebp)
f0102ba9:	e8 05 00 00 00       	call   f0102bb3 <vprintfmt>
	va_end(ap);
f0102bae:	83 c4 10             	add    $0x10,%esp
}
f0102bb1:	c9                   	leave  
f0102bb2:	c3                   	ret    

f0102bb3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102bb3:	55                   	push   %ebp
f0102bb4:	89 e5                	mov    %esp,%ebp
f0102bb6:	57                   	push   %edi
f0102bb7:	56                   	push   %esi
f0102bb8:	53                   	push   %ebx
f0102bb9:	83 ec 2c             	sub    $0x2c,%esp
f0102bbc:	8b 75 08             	mov    0x8(%ebp),%esi
f0102bbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102bc2:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102bc5:	eb 12                	jmp    f0102bd9 <vprintfmt+0x26>

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
		{
			if (ch == '\0')
f0102bc7:	85 c0                	test   %eax,%eax
f0102bc9:	0f 84 90 03 00 00    	je     f0102f5f <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
f0102bcf:	83 ec 08             	sub    $0x8,%esp
f0102bd2:	53                   	push   %ebx
f0102bd3:	50                   	push   %eax
f0102bd4:	ff d6                	call   *%esi
f0102bd6:	83 c4 10             	add    $0x10,%esp
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
f0102bd9:	83 c7 01             	add    $0x1,%edi
f0102bdc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102be0:	83 f8 25             	cmp    $0x25,%eax
f0102be3:	75 e2                	jne    f0102bc7 <vprintfmt+0x14>
f0102be5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0102be9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0102bf0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102bf7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0102bfe:	ba 00 00 00 00       	mov    $0x0,%edx
f0102c03:	eb 07                	jmp    f0102c0c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0102c05:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		{

			// flag to pad on the right
			case '-':
				padc = '-';
f0102c08:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0102c0c:	8d 47 01             	lea    0x1(%edi),%eax
f0102c0f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102c12:	0f b6 07             	movzbl (%edi),%eax
f0102c15:	0f b6 c8             	movzbl %al,%ecx
f0102c18:	83 e8 23             	sub    $0x23,%eax
f0102c1b:	3c 55                	cmp    $0x55,%al
f0102c1d:	0f 87 21 03 00 00    	ja     f0102f44 <vprintfmt+0x391>
f0102c23:	0f b6 c0             	movzbl %al,%eax
f0102c26:	ff 24 85 e0 47 10 f0 	jmp    *-0xfefb820(,%eax,4)
f0102c2d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				padc = '-';
				goto reswitch;

			// flag to pad with 0's instead of spaces
			case '0':
				padc = '0';
f0102c30:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102c34:	eb d6                	jmp    f0102c0c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0102c36:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102c39:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c3e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
					precision = precision * 10 + ch - '0';
f0102c41:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102c44:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
					ch = *fmt;
f0102c48:	0f be 0f             	movsbl (%edi),%ecx
					if (ch < '0' || ch > '9')
f0102c4b:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0102c4e:	83 fa 09             	cmp    $0x9,%edx
f0102c51:	77 39                	ja     f0102c8c <vprintfmt+0xd9>
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
f0102c53:	83 c7 01             	add    $0x1,%edi
					precision = precision * 10 + ch - '0';
					ch = *fmt;
					if (ch < '0' || ch > '9')
						break;
				}
f0102c56:	eb e9                	jmp    f0102c41 <vprintfmt+0x8e>
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
f0102c58:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c5b:	8d 48 04             	lea    0x4(%eax),%ecx
f0102c5e:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102c61:	8b 00                	mov    (%eax),%eax
f0102c63:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0102c66:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				}
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
				goto process_precision;
f0102c69:	eb 27                	jmp    f0102c92 <vprintfmt+0xdf>
f0102c6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102c6e:	85 c0                	test   %eax,%eax
f0102c70:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102c75:	0f 49 c8             	cmovns %eax,%ecx
f0102c78:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0102c7b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102c7e:	eb 8c                	jmp    f0102c0c <vprintfmt+0x59>
f0102c80:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				if (width < 0)
					width = 0;
				goto reswitch;

			case '#':
				altflag = 1;
f0102c83:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				goto reswitch;
f0102c8a:	eb 80                	jmp    f0102c0c <vprintfmt+0x59>
f0102c8c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102c8f:	89 45 d0             	mov    %eax,-0x30(%ebp)

			process_precision:
				if (width < 0)
f0102c92:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102c96:	0f 89 70 ff ff ff    	jns    f0102c0c <vprintfmt+0x59>
					width = precision, precision = -1;
f0102c9c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102c9f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102ca2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102ca9:	e9 5e ff ff ff       	jmp    f0102c0c <vprintfmt+0x59>
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
f0102cae:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0102cb1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
				goto reswitch;
f0102cb4:	e9 53 ff ff ff       	jmp    f0102c0c <vprintfmt+0x59>

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
f0102cb9:	8b 45 14             	mov    0x14(%ebp),%eax
f0102cbc:	8d 50 04             	lea    0x4(%eax),%edx
f0102cbf:	89 55 14             	mov    %edx,0x14(%ebp)
f0102cc2:	83 ec 08             	sub    $0x8,%esp
f0102cc5:	53                   	push   %ebx
f0102cc6:	ff 30                	pushl  (%eax)
f0102cc8:	ff d6                	call   *%esi
				break;
f0102cca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0102ccd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
				break;
f0102cd0:	e9 04 ff ff ff       	jmp    f0102bd9 <vprintfmt+0x26>

			// error message
			case 'e':
				err = va_arg(ap, int);
f0102cd5:	8b 45 14             	mov    0x14(%ebp),%eax
f0102cd8:	8d 50 04             	lea    0x4(%eax),%edx
f0102cdb:	89 55 14             	mov    %edx,0x14(%ebp)
f0102cde:	8b 00                	mov    (%eax),%eax
f0102ce0:	99                   	cltd   
f0102ce1:	31 d0                	xor    %edx,%eax
f0102ce3:	29 d0                	sub    %edx,%eax
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102ce5:	83 f8 07             	cmp    $0x7,%eax
f0102ce8:	7f 0b                	jg     f0102cf5 <vprintfmt+0x142>
f0102cea:	8b 14 85 40 49 10 f0 	mov    -0xfefb6c0(,%eax,4),%edx
f0102cf1:	85 d2                	test   %edx,%edx
f0102cf3:	75 18                	jne    f0102d0d <vprintfmt+0x15a>
					printfmt(putch, putdat, "error %d", err);
f0102cf5:	50                   	push   %eax
f0102cf6:	68 54 47 10 f0       	push   $0xf0104754
f0102cfb:	53                   	push   %ebx
f0102cfc:	56                   	push   %esi
f0102cfd:	e8 94 fe ff ff       	call   f0102b96 <printfmt>
f0102d02:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0102d05:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			case 'e':
				err = va_arg(ap, int);
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
					printfmt(putch, putdat, "error %d", err);
f0102d08:	e9 cc fe ff ff       	jmp    f0102bd9 <vprintfmt+0x26>
				else
					printfmt(putch, putdat, "%s", p);
f0102d0d:	52                   	push   %edx
f0102d0e:	68 6c 44 10 f0       	push   $0xf010446c
f0102d13:	53                   	push   %ebx
f0102d14:	56                   	push   %esi
f0102d15:	e8 7c fe ff ff       	call   f0102b96 <printfmt>
f0102d1a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0102d1d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102d20:	e9 b4 fe ff ff       	jmp    f0102bd9 <vprintfmt+0x26>
f0102d25:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102d28:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d2b:	89 45 cc             	mov    %eax,-0x34(%ebp)
					printfmt(putch, putdat, "%s", p);
				break;

			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
f0102d2e:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d31:	8d 50 04             	lea    0x4(%eax),%edx
f0102d34:	89 55 14             	mov    %edx,0x14(%ebp)
f0102d37:	8b 38                	mov    (%eax),%edi
					p = "(null)";
f0102d39:	85 ff                	test   %edi,%edi
f0102d3b:	ba 4d 47 10 f0       	mov    $0xf010474d,%edx
f0102d40:	0f 44 fa             	cmove  %edx,%edi
				if (width > 0 && padc != '-')
f0102d43:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102d47:	0f 84 92 00 00 00    	je     f0102ddf <vprintfmt+0x22c>
f0102d4d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0102d51:	0f 8e 96 00 00 00    	jle    f0102ded <vprintfmt+0x23a>
					for (width -= strnlen(p, precision); width > 0; width--)
f0102d57:	83 ec 08             	sub    $0x8,%esp
f0102d5a:	51                   	push   %ecx
f0102d5b:	57                   	push   %edi
f0102d5c:	e8 5f 03 00 00       	call   f01030c0 <strnlen>
f0102d61:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102d64:	29 c1                	sub    %eax,%ecx
f0102d66:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0102d69:	83 c4 10             	add    $0x10,%esp
						putch(padc, putdat);
f0102d6c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102d70:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102d73:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102d76:	89 cf                	mov    %ecx,%edi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
f0102d78:	eb 0f                	jmp    f0102d89 <vprintfmt+0x1d6>
						putch(padc, putdat);
f0102d7a:	83 ec 08             	sub    $0x8,%esp
f0102d7d:	53                   	push   %ebx
f0102d7e:	ff 75 e0             	pushl  -0x20(%ebp)
f0102d81:	ff d6                	call   *%esi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
f0102d83:	83 ef 01             	sub    $0x1,%edi
f0102d86:	83 c4 10             	add    $0x10,%esp
f0102d89:	85 ff                	test   %edi,%edi
f0102d8b:	7f ed                	jg     f0102d7a <vprintfmt+0x1c7>
f0102d8d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102d90:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102d93:	85 c9                	test   %ecx,%ecx
f0102d95:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d9a:	0f 49 c1             	cmovns %ecx,%eax
f0102d9d:	29 c1                	sub    %eax,%ecx
f0102d9f:	89 75 08             	mov    %esi,0x8(%ebp)
f0102da2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102da5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102da8:	89 cb                	mov    %ecx,%ebx
f0102daa:	eb 4d                	jmp    f0102df9 <vprintfmt+0x246>
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
f0102dac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102db0:	74 1b                	je     f0102dcd <vprintfmt+0x21a>
f0102db2:	0f be c0             	movsbl %al,%eax
f0102db5:	83 e8 20             	sub    $0x20,%eax
f0102db8:	83 f8 5e             	cmp    $0x5e,%eax
f0102dbb:	76 10                	jbe    f0102dcd <vprintfmt+0x21a>
						putch('?', putdat);
f0102dbd:	83 ec 08             	sub    $0x8,%esp
f0102dc0:	ff 75 0c             	pushl  0xc(%ebp)
f0102dc3:	6a 3f                	push   $0x3f
f0102dc5:	ff 55 08             	call   *0x8(%ebp)
f0102dc8:	83 c4 10             	add    $0x10,%esp
f0102dcb:	eb 0d                	jmp    f0102dda <vprintfmt+0x227>
					else
						putch(ch, putdat);
f0102dcd:	83 ec 08             	sub    $0x8,%esp
f0102dd0:	ff 75 0c             	pushl  0xc(%ebp)
f0102dd3:	52                   	push   %edx
f0102dd4:	ff 55 08             	call   *0x8(%ebp)
f0102dd7:	83 c4 10             	add    $0x10,%esp
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102dda:	83 eb 01             	sub    $0x1,%ebx
f0102ddd:	eb 1a                	jmp    f0102df9 <vprintfmt+0x246>
f0102ddf:	89 75 08             	mov    %esi,0x8(%ebp)
f0102de2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102de5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102de8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102deb:	eb 0c                	jmp    f0102df9 <vprintfmt+0x246>
f0102ded:	89 75 08             	mov    %esi,0x8(%ebp)
f0102df0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102df3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102df6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102df9:	83 c7 01             	add    $0x1,%edi
f0102dfc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102e00:	0f be d0             	movsbl %al,%edx
f0102e03:	85 d2                	test   %edx,%edx
f0102e05:	74 23                	je     f0102e2a <vprintfmt+0x277>
f0102e07:	85 f6                	test   %esi,%esi
f0102e09:	78 a1                	js     f0102dac <vprintfmt+0x1f9>
f0102e0b:	83 ee 01             	sub    $0x1,%esi
f0102e0e:	79 9c                	jns    f0102dac <vprintfmt+0x1f9>
f0102e10:	89 df                	mov    %ebx,%edi
f0102e12:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e15:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e18:	eb 18                	jmp    f0102e32 <vprintfmt+0x27f>
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
					putch(' ', putdat);
f0102e1a:	83 ec 08             	sub    $0x8,%esp
f0102e1d:	53                   	push   %ebx
f0102e1e:	6a 20                	push   $0x20
f0102e20:	ff d6                	call   *%esi
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
f0102e22:	83 ef 01             	sub    $0x1,%edi
f0102e25:	83 c4 10             	add    $0x10,%esp
f0102e28:	eb 08                	jmp    f0102e32 <vprintfmt+0x27f>
f0102e2a:	89 df                	mov    %ebx,%edi
f0102e2c:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102e32:	85 ff                	test   %edi,%edi
f0102e34:	7f e4                	jg     f0102e1a <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0102e36:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102e39:	e9 9b fd ff ff       	jmp    f0102bd9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102e3e:	83 fa 01             	cmp    $0x1,%edx
f0102e41:	7e 16                	jle    f0102e59 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
f0102e43:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e46:	8d 50 08             	lea    0x8(%eax),%edx
f0102e49:	89 55 14             	mov    %edx,0x14(%ebp)
f0102e4c:	8b 50 04             	mov    0x4(%eax),%edx
f0102e4f:	8b 00                	mov    (%eax),%eax
f0102e51:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e54:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102e57:	eb 32                	jmp    f0102e8b <vprintfmt+0x2d8>
	else if (lflag)
f0102e59:	85 d2                	test   %edx,%edx
f0102e5b:	74 18                	je     f0102e75 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
f0102e5d:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e60:	8d 50 04             	lea    0x4(%eax),%edx
f0102e63:	89 55 14             	mov    %edx,0x14(%ebp)
f0102e66:	8b 00                	mov    (%eax),%eax
f0102e68:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e6b:	89 c1                	mov    %eax,%ecx
f0102e6d:	c1 f9 1f             	sar    $0x1f,%ecx
f0102e70:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102e73:	eb 16                	jmp    f0102e8b <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
f0102e75:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e78:	8d 50 04             	lea    0x4(%eax),%edx
f0102e7b:	89 55 14             	mov    %edx,0x14(%ebp)
f0102e7e:	8b 00                	mov    (%eax),%eax
f0102e80:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102e83:	89 c1                	mov    %eax,%ecx
f0102e85:	c1 f9 1f             	sar    $0x1f,%ecx
f0102e88:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(' ', putdat);
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
f0102e8b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102e8e:	8b 55 dc             	mov    -0x24(%ebp),%edx
				if ((long long) num < 0) {
					putch('-', putdat);
					num = -(long long) num;
				}
				base = 10;
f0102e91:	b9 0a 00 00 00       	mov    $0xa,%ecx
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
				if ((long long) num < 0) {
f0102e96:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102e9a:	79 74                	jns    f0102f10 <vprintfmt+0x35d>
					putch('-', putdat);
f0102e9c:	83 ec 08             	sub    $0x8,%esp
f0102e9f:	53                   	push   %ebx
f0102ea0:	6a 2d                	push   $0x2d
f0102ea2:	ff d6                	call   *%esi
					num = -(long long) num;
f0102ea4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102ea7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102eaa:	f7 d8                	neg    %eax
f0102eac:	83 d2 00             	adc    $0x0,%edx
f0102eaf:	f7 da                	neg    %edx
f0102eb1:	83 c4 10             	add    $0x10,%esp
				}
				base = 10;
f0102eb4:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0102eb9:	eb 55                	jmp    f0102f10 <vprintfmt+0x35d>
				goto number;

			// unsigned decimal
			case 'u':
				num = getuint(&ap, lflag);
f0102ebb:	8d 45 14             	lea    0x14(%ebp),%eax
f0102ebe:	e8 7c fc ff ff       	call   f0102b3f <getuint>
				base = 10;
f0102ec3:	b9 0a 00 00 00       	mov    $0xa,%ecx
				goto number;
f0102ec8:	eb 46                	jmp    f0102f10 <vprintfmt+0x35d>
				// Replace this with your code.
				/*putch('X', putdat);
				putch('X', putdat);
				putch('X', putdat);*/
				
				num = getuint(&ap, lflag);
f0102eca:	8d 45 14             	lea    0x14(%ebp),%eax
f0102ecd:	e8 6d fc ff ff       	call   f0102b3f <getuint>
				base = 8;
f0102ed2:	b9 08 00 00 00       	mov    $0x8,%ecx
				goto number;
f0102ed7:	eb 37                	jmp    f0102f10 <vprintfmt+0x35d>

			// pointer
			case 'p':
				putch('0', putdat);
f0102ed9:	83 ec 08             	sub    $0x8,%esp
f0102edc:	53                   	push   %ebx
f0102edd:	6a 30                	push   $0x30
f0102edf:	ff d6                	call   *%esi
				putch('x', putdat);
f0102ee1:	83 c4 08             	add    $0x8,%esp
f0102ee4:	53                   	push   %ebx
f0102ee5:	6a 78                	push   $0x78
f0102ee7:	ff d6                	call   *%esi
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
f0102ee9:	8b 45 14             	mov    0x14(%ebp),%eax
f0102eec:	8d 50 04             	lea    0x4(%eax),%edx
f0102eef:	89 55 14             	mov    %edx,0x14(%ebp)

			// pointer
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
f0102ef2:	8b 00                	mov    (%eax),%eax
f0102ef4:	ba 00 00 00 00       	mov    $0x0,%edx
					(uintptr_t) va_arg(ap, void *);
				base = 16;
				goto number;
f0102ef9:	83 c4 10             	add    $0x10,%esp
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
				base = 16;
f0102efc:	b9 10 00 00 00       	mov    $0x10,%ecx
				goto number;
f0102f01:	eb 0d                	jmp    f0102f10 <vprintfmt+0x35d>

			// (unsigned) hexadecimal
			case 'x':
				num = getuint(&ap, lflag);
f0102f03:	8d 45 14             	lea    0x14(%ebp),%eax
f0102f06:	e8 34 fc ff ff       	call   f0102b3f <getuint>
				base = 16;
f0102f0b:	b9 10 00 00 00       	mov    $0x10,%ecx
			number:
				printnum(putch, putdat, num, base, width, padc);
f0102f10:	83 ec 0c             	sub    $0xc,%esp
f0102f13:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0102f17:	57                   	push   %edi
f0102f18:	ff 75 e0             	pushl  -0x20(%ebp)
f0102f1b:	51                   	push   %ecx
f0102f1c:	52                   	push   %edx
f0102f1d:	50                   	push   %eax
f0102f1e:	89 da                	mov    %ebx,%edx
f0102f20:	89 f0                	mov    %esi,%eax
f0102f22:	e8 6e fb ff ff       	call   f0102a95 <printnum>
				break;
f0102f27:	83 c4 20             	add    $0x20,%esp
f0102f2a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102f2d:	e9 a7 fc ff ff       	jmp    f0102bd9 <vprintfmt+0x26>

			// escaped '%' character
			case '%':
				putch(ch, putdat);
f0102f32:	83 ec 08             	sub    $0x8,%esp
f0102f35:	53                   	push   %ebx
f0102f36:	51                   	push   %ecx
f0102f37:	ff d6                	call   *%esi
				break;
f0102f39:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0102f3c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				break;

			// escaped '%' character
			case '%':
				putch(ch, putdat);
				break;
f0102f3f:	e9 95 fc ff ff       	jmp    f0102bd9 <vprintfmt+0x26>

			// unrecognized escape sequence - just print it literally
			default:
				putch('%', putdat);
f0102f44:	83 ec 08             	sub    $0x8,%esp
f0102f47:	53                   	push   %ebx
f0102f48:	6a 25                	push   $0x25
f0102f4a:	ff d6                	call   *%esi
				for (fmt--; fmt[-1] != '%'; fmt--)
f0102f4c:	83 c4 10             	add    $0x10,%esp
f0102f4f:	eb 03                	jmp    f0102f54 <vprintfmt+0x3a1>
f0102f51:	83 ef 01             	sub    $0x1,%edi
f0102f54:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0102f58:	75 f7                	jne    f0102f51 <vprintfmt+0x39e>
f0102f5a:	e9 7a fc ff ff       	jmp    f0102bd9 <vprintfmt+0x26>
					/* do nothing */;
				break;
		}
	}
}
f0102f5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f62:	5b                   	pop    %ebx
f0102f63:	5e                   	pop    %esi
f0102f64:	5f                   	pop    %edi
f0102f65:	5d                   	pop    %ebp
f0102f66:	c3                   	ret    

f0102f67 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0102f67:	55                   	push   %ebp
f0102f68:	89 e5                	mov    %esp,%ebp
f0102f6a:	83 ec 18             	sub    $0x18,%esp
f0102f6d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f70:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0102f73:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102f76:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0102f7a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102f7d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0102f84:	85 c0                	test   %eax,%eax
f0102f86:	74 26                	je     f0102fae <vsnprintf+0x47>
f0102f88:	85 d2                	test   %edx,%edx
f0102f8a:	7e 22                	jle    f0102fae <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0102f8c:	ff 75 14             	pushl  0x14(%ebp)
f0102f8f:	ff 75 10             	pushl  0x10(%ebp)
f0102f92:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0102f95:	50                   	push   %eax
f0102f96:	68 79 2b 10 f0       	push   $0xf0102b79
f0102f9b:	e8 13 fc ff ff       	call   f0102bb3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0102fa0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102fa3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0102fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102fa9:	83 c4 10             	add    $0x10,%esp
f0102fac:	eb 05                	jmp    f0102fb3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0102fae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0102fb3:	c9                   	leave  
f0102fb4:	c3                   	ret    

f0102fb5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0102fb5:	55                   	push   %ebp
f0102fb6:	89 e5                	mov    %esp,%ebp
f0102fb8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0102fbb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0102fbe:	50                   	push   %eax
f0102fbf:	ff 75 10             	pushl  0x10(%ebp)
f0102fc2:	ff 75 0c             	pushl  0xc(%ebp)
f0102fc5:	ff 75 08             	pushl  0x8(%ebp)
f0102fc8:	e8 9a ff ff ff       	call   f0102f67 <vsnprintf>
	va_end(ap);

	return rc;
}
f0102fcd:	c9                   	leave  
f0102fce:	c3                   	ret    

f0102fcf <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0102fcf:	55                   	push   %ebp
f0102fd0:	89 e5                	mov    %esp,%ebp
f0102fd2:	57                   	push   %edi
f0102fd3:	56                   	push   %esi
f0102fd4:	53                   	push   %ebx
f0102fd5:	83 ec 0c             	sub    $0xc,%esp
f0102fd8:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0102fdb:	85 c0                	test   %eax,%eax
f0102fdd:	74 11                	je     f0102ff0 <readline+0x21>
		cprintf("%s", prompt);
f0102fdf:	83 ec 08             	sub    $0x8,%esp
f0102fe2:	50                   	push   %eax
f0102fe3:	68 6c 44 10 f0       	push   $0xf010446c
f0102fe8:	e8 4d f7 ff ff       	call   f010273a <cprintf>
f0102fed:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0102ff0:	83 ec 0c             	sub    $0xc,%esp
f0102ff3:	6a 00                	push   $0x0
f0102ff5:	e8 07 d6 ff ff       	call   f0100601 <iscons>
f0102ffa:	89 c7                	mov    %eax,%edi
f0102ffc:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0102fff:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103004:	e8 e7 d5 ff ff       	call   f01005f0 <getchar>
f0103009:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010300b:	85 c0                	test   %eax,%eax
f010300d:	79 18                	jns    f0103027 <readline+0x58>
			cprintf("read error: %e\n", c);
f010300f:	83 ec 08             	sub    $0x8,%esp
f0103012:	50                   	push   %eax
f0103013:	68 60 49 10 f0       	push   $0xf0104960
f0103018:	e8 1d f7 ff ff       	call   f010273a <cprintf>
			return NULL;
f010301d:	83 c4 10             	add    $0x10,%esp
f0103020:	b8 00 00 00 00       	mov    $0x0,%eax
f0103025:	eb 79                	jmp    f01030a0 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103027:	83 f8 7f             	cmp    $0x7f,%eax
f010302a:	0f 94 c2             	sete   %dl
f010302d:	83 f8 08             	cmp    $0x8,%eax
f0103030:	0f 94 c0             	sete   %al
f0103033:	08 c2                	or     %al,%dl
f0103035:	74 1a                	je     f0103051 <readline+0x82>
f0103037:	85 f6                	test   %esi,%esi
f0103039:	7e 16                	jle    f0103051 <readline+0x82>
			if (echoing)
f010303b:	85 ff                	test   %edi,%edi
f010303d:	74 0d                	je     f010304c <readline+0x7d>
				cputchar('\b');
f010303f:	83 ec 0c             	sub    $0xc,%esp
f0103042:	6a 08                	push   $0x8
f0103044:	e8 97 d5 ff ff       	call   f01005e0 <cputchar>
f0103049:	83 c4 10             	add    $0x10,%esp
			i--;
f010304c:	83 ee 01             	sub    $0x1,%esi
f010304f:	eb b3                	jmp    f0103004 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103051:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103057:	7f 20                	jg     f0103079 <readline+0xaa>
f0103059:	83 fb 1f             	cmp    $0x1f,%ebx
f010305c:	7e 1b                	jle    f0103079 <readline+0xaa>
			if (echoing)
f010305e:	85 ff                	test   %edi,%edi
f0103060:	74 0c                	je     f010306e <readline+0x9f>
				cputchar(c);
f0103062:	83 ec 0c             	sub    $0xc,%esp
f0103065:	53                   	push   %ebx
f0103066:	e8 75 d5 ff ff       	call   f01005e0 <cputchar>
f010306b:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010306e:	88 9e 80 75 11 f0    	mov    %bl,-0xfee8a80(%esi)
f0103074:	8d 76 01             	lea    0x1(%esi),%esi
f0103077:	eb 8b                	jmp    f0103004 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0103079:	83 fb 0d             	cmp    $0xd,%ebx
f010307c:	74 05                	je     f0103083 <readline+0xb4>
f010307e:	83 fb 0a             	cmp    $0xa,%ebx
f0103081:	75 81                	jne    f0103004 <readline+0x35>
			if (echoing)
f0103083:	85 ff                	test   %edi,%edi
f0103085:	74 0d                	je     f0103094 <readline+0xc5>
				cputchar('\n');
f0103087:	83 ec 0c             	sub    $0xc,%esp
f010308a:	6a 0a                	push   $0xa
f010308c:	e8 4f d5 ff ff       	call   f01005e0 <cputchar>
f0103091:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0103094:	c6 86 80 75 11 f0 00 	movb   $0x0,-0xfee8a80(%esi)
			return buf;
f010309b:	b8 80 75 11 f0       	mov    $0xf0117580,%eax
		}
	}
}
f01030a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01030a3:	5b                   	pop    %ebx
f01030a4:	5e                   	pop    %esi
f01030a5:	5f                   	pop    %edi
f01030a6:	5d                   	pop    %ebp
f01030a7:	c3                   	ret    

f01030a8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01030a8:	55                   	push   %ebp
f01030a9:	89 e5                	mov    %esp,%ebp
f01030ab:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01030ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01030b3:	eb 03                	jmp    f01030b8 <strlen+0x10>
		n++;
f01030b5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01030b8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01030bc:	75 f7                	jne    f01030b5 <strlen+0xd>
		n++;
	return n;
}
f01030be:	5d                   	pop    %ebp
f01030bf:	c3                   	ret    

f01030c0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01030c0:	55                   	push   %ebp
f01030c1:	89 e5                	mov    %esp,%ebp
f01030c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01030c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01030c9:	ba 00 00 00 00       	mov    $0x0,%edx
f01030ce:	eb 03                	jmp    f01030d3 <strnlen+0x13>
		n++;
f01030d0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01030d3:	39 c2                	cmp    %eax,%edx
f01030d5:	74 08                	je     f01030df <strnlen+0x1f>
f01030d7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01030db:	75 f3                	jne    f01030d0 <strnlen+0x10>
f01030dd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01030df:	5d                   	pop    %ebp
f01030e0:	c3                   	ret    

f01030e1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01030e1:	55                   	push   %ebp
f01030e2:	89 e5                	mov    %esp,%ebp
f01030e4:	53                   	push   %ebx
f01030e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01030e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01030eb:	89 c2                	mov    %eax,%edx
f01030ed:	83 c2 01             	add    $0x1,%edx
f01030f0:	83 c1 01             	add    $0x1,%ecx
f01030f3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01030f7:	88 5a ff             	mov    %bl,-0x1(%edx)
f01030fa:	84 db                	test   %bl,%bl
f01030fc:	75 ef                	jne    f01030ed <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01030fe:	5b                   	pop    %ebx
f01030ff:	5d                   	pop    %ebp
f0103100:	c3                   	ret    

f0103101 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103101:	55                   	push   %ebp
f0103102:	89 e5                	mov    %esp,%ebp
f0103104:	53                   	push   %ebx
f0103105:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103108:	53                   	push   %ebx
f0103109:	e8 9a ff ff ff       	call   f01030a8 <strlen>
f010310e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103111:	ff 75 0c             	pushl  0xc(%ebp)
f0103114:	01 d8                	add    %ebx,%eax
f0103116:	50                   	push   %eax
f0103117:	e8 c5 ff ff ff       	call   f01030e1 <strcpy>
	return dst;
}
f010311c:	89 d8                	mov    %ebx,%eax
f010311e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103121:	c9                   	leave  
f0103122:	c3                   	ret    

f0103123 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103123:	55                   	push   %ebp
f0103124:	89 e5                	mov    %esp,%ebp
f0103126:	56                   	push   %esi
f0103127:	53                   	push   %ebx
f0103128:	8b 75 08             	mov    0x8(%ebp),%esi
f010312b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010312e:	89 f3                	mov    %esi,%ebx
f0103130:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103133:	89 f2                	mov    %esi,%edx
f0103135:	eb 0f                	jmp    f0103146 <strncpy+0x23>
		*dst++ = *src;
f0103137:	83 c2 01             	add    $0x1,%edx
f010313a:	0f b6 01             	movzbl (%ecx),%eax
f010313d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103140:	80 39 01             	cmpb   $0x1,(%ecx)
f0103143:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103146:	39 da                	cmp    %ebx,%edx
f0103148:	75 ed                	jne    f0103137 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010314a:	89 f0                	mov    %esi,%eax
f010314c:	5b                   	pop    %ebx
f010314d:	5e                   	pop    %esi
f010314e:	5d                   	pop    %ebp
f010314f:	c3                   	ret    

f0103150 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103150:	55                   	push   %ebp
f0103151:	89 e5                	mov    %esp,%ebp
f0103153:	56                   	push   %esi
f0103154:	53                   	push   %ebx
f0103155:	8b 75 08             	mov    0x8(%ebp),%esi
f0103158:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010315b:	8b 55 10             	mov    0x10(%ebp),%edx
f010315e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103160:	85 d2                	test   %edx,%edx
f0103162:	74 21                	je     f0103185 <strlcpy+0x35>
f0103164:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103168:	89 f2                	mov    %esi,%edx
f010316a:	eb 09                	jmp    f0103175 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010316c:	83 c2 01             	add    $0x1,%edx
f010316f:	83 c1 01             	add    $0x1,%ecx
f0103172:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103175:	39 c2                	cmp    %eax,%edx
f0103177:	74 09                	je     f0103182 <strlcpy+0x32>
f0103179:	0f b6 19             	movzbl (%ecx),%ebx
f010317c:	84 db                	test   %bl,%bl
f010317e:	75 ec                	jne    f010316c <strlcpy+0x1c>
f0103180:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0103182:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103185:	29 f0                	sub    %esi,%eax
}
f0103187:	5b                   	pop    %ebx
f0103188:	5e                   	pop    %esi
f0103189:	5d                   	pop    %ebp
f010318a:	c3                   	ret    

f010318b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010318b:	55                   	push   %ebp
f010318c:	89 e5                	mov    %esp,%ebp
f010318e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103191:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103194:	eb 06                	jmp    f010319c <strcmp+0x11>
		p++, q++;
f0103196:	83 c1 01             	add    $0x1,%ecx
f0103199:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010319c:	0f b6 01             	movzbl (%ecx),%eax
f010319f:	84 c0                	test   %al,%al
f01031a1:	74 04                	je     f01031a7 <strcmp+0x1c>
f01031a3:	3a 02                	cmp    (%edx),%al
f01031a5:	74 ef                	je     f0103196 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01031a7:	0f b6 c0             	movzbl %al,%eax
f01031aa:	0f b6 12             	movzbl (%edx),%edx
f01031ad:	29 d0                	sub    %edx,%eax
}
f01031af:	5d                   	pop    %ebp
f01031b0:	c3                   	ret    

f01031b1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01031b1:	55                   	push   %ebp
f01031b2:	89 e5                	mov    %esp,%ebp
f01031b4:	53                   	push   %ebx
f01031b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01031b8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01031bb:	89 c3                	mov    %eax,%ebx
f01031bd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01031c0:	eb 06                	jmp    f01031c8 <strncmp+0x17>
		n--, p++, q++;
f01031c2:	83 c0 01             	add    $0x1,%eax
f01031c5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01031c8:	39 d8                	cmp    %ebx,%eax
f01031ca:	74 15                	je     f01031e1 <strncmp+0x30>
f01031cc:	0f b6 08             	movzbl (%eax),%ecx
f01031cf:	84 c9                	test   %cl,%cl
f01031d1:	74 04                	je     f01031d7 <strncmp+0x26>
f01031d3:	3a 0a                	cmp    (%edx),%cl
f01031d5:	74 eb                	je     f01031c2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01031d7:	0f b6 00             	movzbl (%eax),%eax
f01031da:	0f b6 12             	movzbl (%edx),%edx
f01031dd:	29 d0                	sub    %edx,%eax
f01031df:	eb 05                	jmp    f01031e6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01031e1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01031e6:	5b                   	pop    %ebx
f01031e7:	5d                   	pop    %ebp
f01031e8:	c3                   	ret    

f01031e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01031e9:	55                   	push   %ebp
f01031ea:	89 e5                	mov    %esp,%ebp
f01031ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01031ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01031f3:	eb 07                	jmp    f01031fc <strchr+0x13>
		if (*s == c)
f01031f5:	38 ca                	cmp    %cl,%dl
f01031f7:	74 0f                	je     f0103208 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01031f9:	83 c0 01             	add    $0x1,%eax
f01031fc:	0f b6 10             	movzbl (%eax),%edx
f01031ff:	84 d2                	test   %dl,%dl
f0103201:	75 f2                	jne    f01031f5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0103203:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103208:	5d                   	pop    %ebp
f0103209:	c3                   	ret    

f010320a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010320a:	55                   	push   %ebp
f010320b:	89 e5                	mov    %esp,%ebp
f010320d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103210:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103214:	eb 03                	jmp    f0103219 <strfind+0xf>
f0103216:	83 c0 01             	add    $0x1,%eax
f0103219:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010321c:	84 d2                	test   %dl,%dl
f010321e:	74 04                	je     f0103224 <strfind+0x1a>
f0103220:	38 ca                	cmp    %cl,%dl
f0103222:	75 f2                	jne    f0103216 <strfind+0xc>
			break;
	return (char *) s;
}
f0103224:	5d                   	pop    %ebp
f0103225:	c3                   	ret    

f0103226 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103226:	55                   	push   %ebp
f0103227:	89 e5                	mov    %esp,%ebp
f0103229:	57                   	push   %edi
f010322a:	56                   	push   %esi
f010322b:	53                   	push   %ebx
f010322c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010322f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103232:	85 c9                	test   %ecx,%ecx
f0103234:	74 36                	je     f010326c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103236:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010323c:	75 28                	jne    f0103266 <memset+0x40>
f010323e:	f6 c1 03             	test   $0x3,%cl
f0103241:	75 23                	jne    f0103266 <memset+0x40>
		c &= 0xFF;
f0103243:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103247:	89 d3                	mov    %edx,%ebx
f0103249:	c1 e3 08             	shl    $0x8,%ebx
f010324c:	89 d6                	mov    %edx,%esi
f010324e:	c1 e6 18             	shl    $0x18,%esi
f0103251:	89 d0                	mov    %edx,%eax
f0103253:	c1 e0 10             	shl    $0x10,%eax
f0103256:	09 f0                	or     %esi,%eax
f0103258:	09 c2                	or     %eax,%edx
f010325a:	89 d0                	mov    %edx,%eax
f010325c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010325e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0103261:	fc                   	cld    
f0103262:	f3 ab                	rep stos %eax,%es:(%edi)
f0103264:	eb 06                	jmp    f010326c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103266:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103269:	fc                   	cld    
f010326a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010326c:	89 f8                	mov    %edi,%eax
f010326e:	5b                   	pop    %ebx
f010326f:	5e                   	pop    %esi
f0103270:	5f                   	pop    %edi
f0103271:	5d                   	pop    %ebp
f0103272:	c3                   	ret    

f0103273 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103273:	55                   	push   %ebp
f0103274:	89 e5                	mov    %esp,%ebp
f0103276:	57                   	push   %edi
f0103277:	56                   	push   %esi
f0103278:	8b 45 08             	mov    0x8(%ebp),%eax
f010327b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010327e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103281:	39 c6                	cmp    %eax,%esi
f0103283:	73 35                	jae    f01032ba <memmove+0x47>
f0103285:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103288:	39 d0                	cmp    %edx,%eax
f010328a:	73 2e                	jae    f01032ba <memmove+0x47>
		s += n;
		d += n;
f010328c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f010328f:	89 d6                	mov    %edx,%esi
f0103291:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103293:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103299:	75 13                	jne    f01032ae <memmove+0x3b>
f010329b:	f6 c1 03             	test   $0x3,%cl
f010329e:	75 0e                	jne    f01032ae <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01032a0:	83 ef 04             	sub    $0x4,%edi
f01032a3:	8d 72 fc             	lea    -0x4(%edx),%esi
f01032a6:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01032a9:	fd                   	std    
f01032aa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01032ac:	eb 09                	jmp    f01032b7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01032ae:	83 ef 01             	sub    $0x1,%edi
f01032b1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01032b4:	fd                   	std    
f01032b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01032b7:	fc                   	cld    
f01032b8:	eb 1d                	jmp    f01032d7 <memmove+0x64>
f01032ba:	89 f2                	mov    %esi,%edx
f01032bc:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01032be:	f6 c2 03             	test   $0x3,%dl
f01032c1:	75 0f                	jne    f01032d2 <memmove+0x5f>
f01032c3:	f6 c1 03             	test   $0x3,%cl
f01032c6:	75 0a                	jne    f01032d2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01032c8:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01032cb:	89 c7                	mov    %eax,%edi
f01032cd:	fc                   	cld    
f01032ce:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01032d0:	eb 05                	jmp    f01032d7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01032d2:	89 c7                	mov    %eax,%edi
f01032d4:	fc                   	cld    
f01032d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01032d7:	5e                   	pop    %esi
f01032d8:	5f                   	pop    %edi
f01032d9:	5d                   	pop    %ebp
f01032da:	c3                   	ret    

f01032db <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01032db:	55                   	push   %ebp
f01032dc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01032de:	ff 75 10             	pushl  0x10(%ebp)
f01032e1:	ff 75 0c             	pushl  0xc(%ebp)
f01032e4:	ff 75 08             	pushl  0x8(%ebp)
f01032e7:	e8 87 ff ff ff       	call   f0103273 <memmove>
}
f01032ec:	c9                   	leave  
f01032ed:	c3                   	ret    

f01032ee <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01032ee:	55                   	push   %ebp
f01032ef:	89 e5                	mov    %esp,%ebp
f01032f1:	56                   	push   %esi
f01032f2:	53                   	push   %ebx
f01032f3:	8b 45 08             	mov    0x8(%ebp),%eax
f01032f6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01032f9:	89 c6                	mov    %eax,%esi
f01032fb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01032fe:	eb 1a                	jmp    f010331a <memcmp+0x2c>
		if (*s1 != *s2)
f0103300:	0f b6 08             	movzbl (%eax),%ecx
f0103303:	0f b6 1a             	movzbl (%edx),%ebx
f0103306:	38 d9                	cmp    %bl,%cl
f0103308:	74 0a                	je     f0103314 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010330a:	0f b6 c1             	movzbl %cl,%eax
f010330d:	0f b6 db             	movzbl %bl,%ebx
f0103310:	29 d8                	sub    %ebx,%eax
f0103312:	eb 0f                	jmp    f0103323 <memcmp+0x35>
		s1++, s2++;
f0103314:	83 c0 01             	add    $0x1,%eax
f0103317:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010331a:	39 f0                	cmp    %esi,%eax
f010331c:	75 e2                	jne    f0103300 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010331e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103323:	5b                   	pop    %ebx
f0103324:	5e                   	pop    %esi
f0103325:	5d                   	pop    %ebp
f0103326:	c3                   	ret    

f0103327 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103327:	55                   	push   %ebp
f0103328:	89 e5                	mov    %esp,%ebp
f010332a:	8b 45 08             	mov    0x8(%ebp),%eax
f010332d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103330:	89 c2                	mov    %eax,%edx
f0103332:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103335:	eb 07                	jmp    f010333e <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103337:	38 08                	cmp    %cl,(%eax)
f0103339:	74 07                	je     f0103342 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010333b:	83 c0 01             	add    $0x1,%eax
f010333e:	39 d0                	cmp    %edx,%eax
f0103340:	72 f5                	jb     f0103337 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103342:	5d                   	pop    %ebp
f0103343:	c3                   	ret    

f0103344 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103344:	55                   	push   %ebp
f0103345:	89 e5                	mov    %esp,%ebp
f0103347:	57                   	push   %edi
f0103348:	56                   	push   %esi
f0103349:	53                   	push   %ebx
f010334a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010334d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103350:	eb 03                	jmp    f0103355 <strtol+0x11>
		s++;
f0103352:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103355:	0f b6 01             	movzbl (%ecx),%eax
f0103358:	3c 09                	cmp    $0x9,%al
f010335a:	74 f6                	je     f0103352 <strtol+0xe>
f010335c:	3c 20                	cmp    $0x20,%al
f010335e:	74 f2                	je     f0103352 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103360:	3c 2b                	cmp    $0x2b,%al
f0103362:	75 0a                	jne    f010336e <strtol+0x2a>
		s++;
f0103364:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103367:	bf 00 00 00 00       	mov    $0x0,%edi
f010336c:	eb 10                	jmp    f010337e <strtol+0x3a>
f010336e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103373:	3c 2d                	cmp    $0x2d,%al
f0103375:	75 07                	jne    f010337e <strtol+0x3a>
		s++, neg = 1;
f0103377:	8d 49 01             	lea    0x1(%ecx),%ecx
f010337a:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010337e:	85 db                	test   %ebx,%ebx
f0103380:	0f 94 c0             	sete   %al
f0103383:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103389:	75 19                	jne    f01033a4 <strtol+0x60>
f010338b:	80 39 30             	cmpb   $0x30,(%ecx)
f010338e:	75 14                	jne    f01033a4 <strtol+0x60>
f0103390:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103394:	0f 85 82 00 00 00    	jne    f010341c <strtol+0xd8>
		s += 2, base = 16;
f010339a:	83 c1 02             	add    $0x2,%ecx
f010339d:	bb 10 00 00 00       	mov    $0x10,%ebx
f01033a2:	eb 16                	jmp    f01033ba <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01033a4:	84 c0                	test   %al,%al
f01033a6:	74 12                	je     f01033ba <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01033a8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01033ad:	80 39 30             	cmpb   $0x30,(%ecx)
f01033b0:	75 08                	jne    f01033ba <strtol+0x76>
		s++, base = 8;
f01033b2:	83 c1 01             	add    $0x1,%ecx
f01033b5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01033ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01033bf:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01033c2:	0f b6 11             	movzbl (%ecx),%edx
f01033c5:	8d 72 d0             	lea    -0x30(%edx),%esi
f01033c8:	89 f3                	mov    %esi,%ebx
f01033ca:	80 fb 09             	cmp    $0x9,%bl
f01033cd:	77 08                	ja     f01033d7 <strtol+0x93>
			dig = *s - '0';
f01033cf:	0f be d2             	movsbl %dl,%edx
f01033d2:	83 ea 30             	sub    $0x30,%edx
f01033d5:	eb 22                	jmp    f01033f9 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
f01033d7:	8d 72 9f             	lea    -0x61(%edx),%esi
f01033da:	89 f3                	mov    %esi,%ebx
f01033dc:	80 fb 19             	cmp    $0x19,%bl
f01033df:	77 08                	ja     f01033e9 <strtol+0xa5>
			dig = *s - 'a' + 10;
f01033e1:	0f be d2             	movsbl %dl,%edx
f01033e4:	83 ea 57             	sub    $0x57,%edx
f01033e7:	eb 10                	jmp    f01033f9 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
f01033e9:	8d 72 bf             	lea    -0x41(%edx),%esi
f01033ec:	89 f3                	mov    %esi,%ebx
f01033ee:	80 fb 19             	cmp    $0x19,%bl
f01033f1:	77 16                	ja     f0103409 <strtol+0xc5>
			dig = *s - 'A' + 10;
f01033f3:	0f be d2             	movsbl %dl,%edx
f01033f6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01033f9:	3b 55 10             	cmp    0x10(%ebp),%edx
f01033fc:	7d 0f                	jge    f010340d <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
f01033fe:	83 c1 01             	add    $0x1,%ecx
f0103401:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103405:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0103407:	eb b9                	jmp    f01033c2 <strtol+0x7e>
f0103409:	89 c2                	mov    %eax,%edx
f010340b:	eb 02                	jmp    f010340f <strtol+0xcb>
f010340d:	89 c2                	mov    %eax,%edx

	if (endptr)
f010340f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103413:	74 0d                	je     f0103422 <strtol+0xde>
		*endptr = (char *) s;
f0103415:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103418:	89 0e                	mov    %ecx,(%esi)
f010341a:	eb 06                	jmp    f0103422 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010341c:	84 c0                	test   %al,%al
f010341e:	75 92                	jne    f01033b2 <strtol+0x6e>
f0103420:	eb 98                	jmp    f01033ba <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0103422:	f7 da                	neg    %edx
f0103424:	85 ff                	test   %edi,%edi
f0103426:	0f 45 c2             	cmovne %edx,%eax
}
f0103429:	5b                   	pop    %ebx
f010342a:	5e                   	pop    %esi
f010342b:	5f                   	pop    %edi
f010342c:	5d                   	pop    %ebp
f010342d:	c3                   	ret    
f010342e:	66 90                	xchg   %ax,%ax

f0103430 <__udivdi3>:
f0103430:	55                   	push   %ebp
f0103431:	57                   	push   %edi
f0103432:	56                   	push   %esi
f0103433:	83 ec 10             	sub    $0x10,%esp
f0103436:	8b 54 24 2c          	mov    0x2c(%esp),%edx
f010343a:	8b 7c 24 20          	mov    0x20(%esp),%edi
f010343e:	8b 74 24 24          	mov    0x24(%esp),%esi
f0103442:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0103446:	85 d2                	test   %edx,%edx
f0103448:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010344c:	89 34 24             	mov    %esi,(%esp)
f010344f:	89 c8                	mov    %ecx,%eax
f0103451:	75 35                	jne    f0103488 <__udivdi3+0x58>
f0103453:	39 f1                	cmp    %esi,%ecx
f0103455:	0f 87 bd 00 00 00    	ja     f0103518 <__udivdi3+0xe8>
f010345b:	85 c9                	test   %ecx,%ecx
f010345d:	89 cd                	mov    %ecx,%ebp
f010345f:	75 0b                	jne    f010346c <__udivdi3+0x3c>
f0103461:	b8 01 00 00 00       	mov    $0x1,%eax
f0103466:	31 d2                	xor    %edx,%edx
f0103468:	f7 f1                	div    %ecx
f010346a:	89 c5                	mov    %eax,%ebp
f010346c:	89 f0                	mov    %esi,%eax
f010346e:	31 d2                	xor    %edx,%edx
f0103470:	f7 f5                	div    %ebp
f0103472:	89 c6                	mov    %eax,%esi
f0103474:	89 f8                	mov    %edi,%eax
f0103476:	f7 f5                	div    %ebp
f0103478:	89 f2                	mov    %esi,%edx
f010347a:	83 c4 10             	add    $0x10,%esp
f010347d:	5e                   	pop    %esi
f010347e:	5f                   	pop    %edi
f010347f:	5d                   	pop    %ebp
f0103480:	c3                   	ret    
f0103481:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103488:	3b 14 24             	cmp    (%esp),%edx
f010348b:	77 7b                	ja     f0103508 <__udivdi3+0xd8>
f010348d:	0f bd f2             	bsr    %edx,%esi
f0103490:	83 f6 1f             	xor    $0x1f,%esi
f0103493:	0f 84 97 00 00 00    	je     f0103530 <__udivdi3+0x100>
f0103499:	bd 20 00 00 00       	mov    $0x20,%ebp
f010349e:	89 d7                	mov    %edx,%edi
f01034a0:	89 f1                	mov    %esi,%ecx
f01034a2:	29 f5                	sub    %esi,%ebp
f01034a4:	d3 e7                	shl    %cl,%edi
f01034a6:	89 c2                	mov    %eax,%edx
f01034a8:	89 e9                	mov    %ebp,%ecx
f01034aa:	d3 ea                	shr    %cl,%edx
f01034ac:	89 f1                	mov    %esi,%ecx
f01034ae:	09 fa                	or     %edi,%edx
f01034b0:	8b 3c 24             	mov    (%esp),%edi
f01034b3:	d3 e0                	shl    %cl,%eax
f01034b5:	89 54 24 08          	mov    %edx,0x8(%esp)
f01034b9:	89 e9                	mov    %ebp,%ecx
f01034bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01034bf:	8b 44 24 04          	mov    0x4(%esp),%eax
f01034c3:	89 fa                	mov    %edi,%edx
f01034c5:	d3 ea                	shr    %cl,%edx
f01034c7:	89 f1                	mov    %esi,%ecx
f01034c9:	d3 e7                	shl    %cl,%edi
f01034cb:	89 e9                	mov    %ebp,%ecx
f01034cd:	d3 e8                	shr    %cl,%eax
f01034cf:	09 c7                	or     %eax,%edi
f01034d1:	89 f8                	mov    %edi,%eax
f01034d3:	f7 74 24 08          	divl   0x8(%esp)
f01034d7:	89 d5                	mov    %edx,%ebp
f01034d9:	89 c7                	mov    %eax,%edi
f01034db:	f7 64 24 0c          	mull   0xc(%esp)
f01034df:	39 d5                	cmp    %edx,%ebp
f01034e1:	89 14 24             	mov    %edx,(%esp)
f01034e4:	72 11                	jb     f01034f7 <__udivdi3+0xc7>
f01034e6:	8b 54 24 04          	mov    0x4(%esp),%edx
f01034ea:	89 f1                	mov    %esi,%ecx
f01034ec:	d3 e2                	shl    %cl,%edx
f01034ee:	39 c2                	cmp    %eax,%edx
f01034f0:	73 5e                	jae    f0103550 <__udivdi3+0x120>
f01034f2:	3b 2c 24             	cmp    (%esp),%ebp
f01034f5:	75 59                	jne    f0103550 <__udivdi3+0x120>
f01034f7:	8d 47 ff             	lea    -0x1(%edi),%eax
f01034fa:	31 f6                	xor    %esi,%esi
f01034fc:	89 f2                	mov    %esi,%edx
f01034fe:	83 c4 10             	add    $0x10,%esp
f0103501:	5e                   	pop    %esi
f0103502:	5f                   	pop    %edi
f0103503:	5d                   	pop    %ebp
f0103504:	c3                   	ret    
f0103505:	8d 76 00             	lea    0x0(%esi),%esi
f0103508:	31 f6                	xor    %esi,%esi
f010350a:	31 c0                	xor    %eax,%eax
f010350c:	89 f2                	mov    %esi,%edx
f010350e:	83 c4 10             	add    $0x10,%esp
f0103511:	5e                   	pop    %esi
f0103512:	5f                   	pop    %edi
f0103513:	5d                   	pop    %ebp
f0103514:	c3                   	ret    
f0103515:	8d 76 00             	lea    0x0(%esi),%esi
f0103518:	89 f2                	mov    %esi,%edx
f010351a:	31 f6                	xor    %esi,%esi
f010351c:	89 f8                	mov    %edi,%eax
f010351e:	f7 f1                	div    %ecx
f0103520:	89 f2                	mov    %esi,%edx
f0103522:	83 c4 10             	add    $0x10,%esp
f0103525:	5e                   	pop    %esi
f0103526:	5f                   	pop    %edi
f0103527:	5d                   	pop    %ebp
f0103528:	c3                   	ret    
f0103529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103530:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0103534:	76 0b                	jbe    f0103541 <__udivdi3+0x111>
f0103536:	31 c0                	xor    %eax,%eax
f0103538:	3b 14 24             	cmp    (%esp),%edx
f010353b:	0f 83 37 ff ff ff    	jae    f0103478 <__udivdi3+0x48>
f0103541:	b8 01 00 00 00       	mov    $0x1,%eax
f0103546:	e9 2d ff ff ff       	jmp    f0103478 <__udivdi3+0x48>
f010354b:	90                   	nop
f010354c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103550:	89 f8                	mov    %edi,%eax
f0103552:	31 f6                	xor    %esi,%esi
f0103554:	e9 1f ff ff ff       	jmp    f0103478 <__udivdi3+0x48>
f0103559:	66 90                	xchg   %ax,%ax
f010355b:	66 90                	xchg   %ax,%ax
f010355d:	66 90                	xchg   %ax,%ax
f010355f:	90                   	nop

f0103560 <__umoddi3>:
f0103560:	55                   	push   %ebp
f0103561:	57                   	push   %edi
f0103562:	56                   	push   %esi
f0103563:	83 ec 20             	sub    $0x20,%esp
f0103566:	8b 44 24 34          	mov    0x34(%esp),%eax
f010356a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010356e:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103572:	89 c6                	mov    %eax,%esi
f0103574:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103578:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010357c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
f0103580:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0103584:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f0103588:	89 74 24 18          	mov    %esi,0x18(%esp)
f010358c:	85 c0                	test   %eax,%eax
f010358e:	89 c2                	mov    %eax,%edx
f0103590:	75 1e                	jne    f01035b0 <__umoddi3+0x50>
f0103592:	39 f7                	cmp    %esi,%edi
f0103594:	76 52                	jbe    f01035e8 <__umoddi3+0x88>
f0103596:	89 c8                	mov    %ecx,%eax
f0103598:	89 f2                	mov    %esi,%edx
f010359a:	f7 f7                	div    %edi
f010359c:	89 d0                	mov    %edx,%eax
f010359e:	31 d2                	xor    %edx,%edx
f01035a0:	83 c4 20             	add    $0x20,%esp
f01035a3:	5e                   	pop    %esi
f01035a4:	5f                   	pop    %edi
f01035a5:	5d                   	pop    %ebp
f01035a6:	c3                   	ret    
f01035a7:	89 f6                	mov    %esi,%esi
f01035a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01035b0:	39 f0                	cmp    %esi,%eax
f01035b2:	77 5c                	ja     f0103610 <__umoddi3+0xb0>
f01035b4:	0f bd e8             	bsr    %eax,%ebp
f01035b7:	83 f5 1f             	xor    $0x1f,%ebp
f01035ba:	75 64                	jne    f0103620 <__umoddi3+0xc0>
f01035bc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
f01035c0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
f01035c4:	0f 86 f6 00 00 00    	jbe    f01036c0 <__umoddi3+0x160>
f01035ca:	3b 44 24 18          	cmp    0x18(%esp),%eax
f01035ce:	0f 82 ec 00 00 00    	jb     f01036c0 <__umoddi3+0x160>
f01035d4:	8b 44 24 14          	mov    0x14(%esp),%eax
f01035d8:	8b 54 24 18          	mov    0x18(%esp),%edx
f01035dc:	83 c4 20             	add    $0x20,%esp
f01035df:	5e                   	pop    %esi
f01035e0:	5f                   	pop    %edi
f01035e1:	5d                   	pop    %ebp
f01035e2:	c3                   	ret    
f01035e3:	90                   	nop
f01035e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01035e8:	85 ff                	test   %edi,%edi
f01035ea:	89 fd                	mov    %edi,%ebp
f01035ec:	75 0b                	jne    f01035f9 <__umoddi3+0x99>
f01035ee:	b8 01 00 00 00       	mov    $0x1,%eax
f01035f3:	31 d2                	xor    %edx,%edx
f01035f5:	f7 f7                	div    %edi
f01035f7:	89 c5                	mov    %eax,%ebp
f01035f9:	8b 44 24 10          	mov    0x10(%esp),%eax
f01035fd:	31 d2                	xor    %edx,%edx
f01035ff:	f7 f5                	div    %ebp
f0103601:	89 c8                	mov    %ecx,%eax
f0103603:	f7 f5                	div    %ebp
f0103605:	eb 95                	jmp    f010359c <__umoddi3+0x3c>
f0103607:	89 f6                	mov    %esi,%esi
f0103609:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0103610:	89 c8                	mov    %ecx,%eax
f0103612:	89 f2                	mov    %esi,%edx
f0103614:	83 c4 20             	add    $0x20,%esp
f0103617:	5e                   	pop    %esi
f0103618:	5f                   	pop    %edi
f0103619:	5d                   	pop    %ebp
f010361a:	c3                   	ret    
f010361b:	90                   	nop
f010361c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103620:	b8 20 00 00 00       	mov    $0x20,%eax
f0103625:	89 e9                	mov    %ebp,%ecx
f0103627:	29 e8                	sub    %ebp,%eax
f0103629:	d3 e2                	shl    %cl,%edx
f010362b:	89 c7                	mov    %eax,%edi
f010362d:	89 44 24 18          	mov    %eax,0x18(%esp)
f0103631:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0103635:	89 f9                	mov    %edi,%ecx
f0103637:	d3 e8                	shr    %cl,%eax
f0103639:	89 c1                	mov    %eax,%ecx
f010363b:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010363f:	09 d1                	or     %edx,%ecx
f0103641:	89 fa                	mov    %edi,%edx
f0103643:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0103647:	89 e9                	mov    %ebp,%ecx
f0103649:	d3 e0                	shl    %cl,%eax
f010364b:	89 f9                	mov    %edi,%ecx
f010364d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103651:	89 f0                	mov    %esi,%eax
f0103653:	d3 e8                	shr    %cl,%eax
f0103655:	89 e9                	mov    %ebp,%ecx
f0103657:	89 c7                	mov    %eax,%edi
f0103659:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f010365d:	d3 e6                	shl    %cl,%esi
f010365f:	89 d1                	mov    %edx,%ecx
f0103661:	89 fa                	mov    %edi,%edx
f0103663:	d3 e8                	shr    %cl,%eax
f0103665:	89 e9                	mov    %ebp,%ecx
f0103667:	09 f0                	or     %esi,%eax
f0103669:	8b 74 24 1c          	mov    0x1c(%esp),%esi
f010366d:	f7 74 24 10          	divl   0x10(%esp)
f0103671:	d3 e6                	shl    %cl,%esi
f0103673:	89 d1                	mov    %edx,%ecx
f0103675:	f7 64 24 0c          	mull   0xc(%esp)
f0103679:	39 d1                	cmp    %edx,%ecx
f010367b:	89 74 24 14          	mov    %esi,0x14(%esp)
f010367f:	89 d7                	mov    %edx,%edi
f0103681:	89 c6                	mov    %eax,%esi
f0103683:	72 0a                	jb     f010368f <__umoddi3+0x12f>
f0103685:	39 44 24 14          	cmp    %eax,0x14(%esp)
f0103689:	73 10                	jae    f010369b <__umoddi3+0x13b>
f010368b:	39 d1                	cmp    %edx,%ecx
f010368d:	75 0c                	jne    f010369b <__umoddi3+0x13b>
f010368f:	89 d7                	mov    %edx,%edi
f0103691:	89 c6                	mov    %eax,%esi
f0103693:	2b 74 24 0c          	sub    0xc(%esp),%esi
f0103697:	1b 7c 24 10          	sbb    0x10(%esp),%edi
f010369b:	89 ca                	mov    %ecx,%edx
f010369d:	89 e9                	mov    %ebp,%ecx
f010369f:	8b 44 24 14          	mov    0x14(%esp),%eax
f01036a3:	29 f0                	sub    %esi,%eax
f01036a5:	19 fa                	sbb    %edi,%edx
f01036a7:	d3 e8                	shr    %cl,%eax
f01036a9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
f01036ae:	89 d7                	mov    %edx,%edi
f01036b0:	d3 e7                	shl    %cl,%edi
f01036b2:	89 e9                	mov    %ebp,%ecx
f01036b4:	09 f8                	or     %edi,%eax
f01036b6:	d3 ea                	shr    %cl,%edx
f01036b8:	83 c4 20             	add    $0x20,%esp
f01036bb:	5e                   	pop    %esi
f01036bc:	5f                   	pop    %edi
f01036bd:	5d                   	pop    %ebp
f01036be:	c3                   	ret    
f01036bf:	90                   	nop
f01036c0:	8b 74 24 10          	mov    0x10(%esp),%esi
f01036c4:	29 f9                	sub    %edi,%ecx
f01036c6:	19 c6                	sbb    %eax,%esi
f01036c8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f01036cc:	89 74 24 18          	mov    %esi,0x18(%esp)
f01036d0:	e9 ff fe ff ff       	jmp    f01035d4 <__umoddi3+0x74>
