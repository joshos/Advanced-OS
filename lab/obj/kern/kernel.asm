
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
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
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
f0100034:	bc 00 80 11 f0       	mov    $0xf0118000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


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
f0100046:	b8 10 9f 17 f0       	mov    $0xf0179f10,%eax
f010004b:	2d 9d 8f 17 f0       	sub    $0xf0178f9d,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 9d 8f 17 f0       	push   $0xf0178f9d
f0100058:	e8 63 3d 00 00       	call   f0103dc0 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 9a 04 00 00       	call   f01004fc <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 80 42 10 f0       	push   $0xf0104280
f010006f:	e8 75 2e 00 00       	call   f0102ee9 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 0a 10 00 00       	call   f0101083 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100079:	e8 b2 28 00 00       	call   f0102930 <env_init>
	trap_init();
f010007e:	e8 d7 2e 00 00       	call   f0102f5a <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_divzero, ENV_TYPE_USER);
f0100083:	83 c4 08             	add    $0x8,%esp
f0100086:	6a 00                	push   $0x0
f0100088:	68 0c fd 13 f0       	push   $0xf013fd0c
f010008d:	e8 64 2a 00 00       	call   f0102af6 <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100092:	83 c4 04             	add    $0x4,%esp
f0100095:	ff 35 28 92 17 f0    	pushl  0xf0179228
f010009b:	e8 82 2d 00 00       	call   f0102e22 <env_run>

f01000a0 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000a0:	55                   	push   %ebp
f01000a1:	89 e5                	mov    %esp,%ebp
f01000a3:	56                   	push   %esi
f01000a4:	53                   	push   %ebx
f01000a5:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000a8:	83 3d 00 9f 17 f0 00 	cmpl   $0x0,0xf0179f00
f01000af:	75 37                	jne    f01000e8 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000b1:	89 35 00 9f 17 f0    	mov    %esi,0xf0179f00

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000b7:	fa                   	cli    
f01000b8:	fc                   	cld    

	va_start(ap, fmt);
f01000b9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000bc:	83 ec 04             	sub    $0x4,%esp
f01000bf:	ff 75 0c             	pushl  0xc(%ebp)
f01000c2:	ff 75 08             	pushl  0x8(%ebp)
f01000c5:	68 9b 42 10 f0       	push   $0xf010429b
f01000ca:	e8 1a 2e 00 00       	call   f0102ee9 <cprintf>
	vcprintf(fmt, ap);
f01000cf:	83 c4 08             	add    $0x8,%esp
f01000d2:	53                   	push   %ebx
f01000d3:	56                   	push   %esi
f01000d4:	e8 ea 2d 00 00       	call   f0102ec3 <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 9d 52 10 f0 	movl   $0xf010529d,(%esp)
f01000e0:	e8 04 2e 00 00       	call   f0102ee9 <cprintf>
	va_end(ap);
f01000e5:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e8:	83 ec 0c             	sub    $0xc,%esp
f01000eb:	6a 00                	push   $0x0
f01000ed:	e8 a7 06 00 00       	call   f0100799 <monitor>
f01000f2:	83 c4 10             	add    $0x10,%esp
f01000f5:	eb f1                	jmp    f01000e8 <_panic+0x48>

f01000f7 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000f7:	55                   	push   %ebp
f01000f8:	89 e5                	mov    %esp,%ebp
f01000fa:	53                   	push   %ebx
f01000fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000fe:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100101:	ff 75 0c             	pushl  0xc(%ebp)
f0100104:	ff 75 08             	pushl  0x8(%ebp)
f0100107:	68 b3 42 10 f0       	push   $0xf01042b3
f010010c:	e8 d8 2d 00 00       	call   f0102ee9 <cprintf>
	vcprintf(fmt, ap);
f0100111:	83 c4 08             	add    $0x8,%esp
f0100114:	53                   	push   %ebx
f0100115:	ff 75 10             	pushl  0x10(%ebp)
f0100118:	e8 a6 2d 00 00       	call   f0102ec3 <vcprintf>
	cprintf("\n");
f010011d:	c7 04 24 9d 52 10 f0 	movl   $0xf010529d,(%esp)
f0100124:	e8 c0 2d 00 00       	call   f0102ee9 <cprintf>
	va_end(ap);
f0100129:	83 c4 10             	add    $0x10,%esp
}
f010012c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010012f:	c9                   	leave  
f0100130:	c3                   	ret    

f0100131 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100131:	55                   	push   %ebp
f0100132:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100134:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100139:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010013a:	a8 01                	test   $0x1,%al
f010013c:	74 08                	je     f0100146 <serial_proc_data+0x15>
f010013e:	b2 f8                	mov    $0xf8,%dl
f0100140:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100141:	0f b6 c0             	movzbl %al,%eax
f0100144:	eb 05                	jmp    f010014b <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100146:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010014b:	5d                   	pop    %ebp
f010014c:	c3                   	ret    

f010014d <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010014d:	55                   	push   %ebp
f010014e:	89 e5                	mov    %esp,%ebp
f0100150:	53                   	push   %ebx
f0100151:	83 ec 04             	sub    $0x4,%esp
f0100154:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100156:	eb 2a                	jmp    f0100182 <cons_intr+0x35>
		if (c == 0)
f0100158:	85 d2                	test   %edx,%edx
f010015a:	74 26                	je     f0100182 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f010015c:	a1 04 92 17 f0       	mov    0xf0179204,%eax
f0100161:	8d 48 01             	lea    0x1(%eax),%ecx
f0100164:	89 0d 04 92 17 f0    	mov    %ecx,0xf0179204
f010016a:	88 90 00 90 17 f0    	mov    %dl,-0xfe87000(%eax)
		if (cons.wpos == CONSBUFSIZE)
f0100170:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100176:	75 0a                	jne    f0100182 <cons_intr+0x35>
			cons.wpos = 0;
f0100178:	c7 05 04 92 17 f0 00 	movl   $0x0,0xf0179204
f010017f:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100182:	ff d3                	call   *%ebx
f0100184:	89 c2                	mov    %eax,%edx
f0100186:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100189:	75 cd                	jne    f0100158 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010018b:	83 c4 04             	add    $0x4,%esp
f010018e:	5b                   	pop    %ebx
f010018f:	5d                   	pop    %ebp
f0100190:	c3                   	ret    

f0100191 <kbd_proc_data>:
f0100191:	ba 64 00 00 00       	mov    $0x64,%edx
f0100196:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100197:	a8 01                	test   $0x1,%al
f0100199:	0f 84 f0 00 00 00    	je     f010028f <kbd_proc_data+0xfe>
f010019f:	b2 60                	mov    $0x60,%dl
f01001a1:	ec                   	in     (%dx),%al
f01001a2:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001a4:	3c e0                	cmp    $0xe0,%al
f01001a6:	75 0d                	jne    f01001b5 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f01001a8:	83 0d c0 8f 17 f0 40 	orl    $0x40,0xf0178fc0
		return 0;
f01001af:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001b4:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001b5:	55                   	push   %ebp
f01001b6:	89 e5                	mov    %esp,%ebp
f01001b8:	53                   	push   %ebx
f01001b9:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001bc:	84 c0                	test   %al,%al
f01001be:	79 36                	jns    f01001f6 <kbd_proc_data+0x65>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001c0:	8b 0d c0 8f 17 f0    	mov    0xf0178fc0,%ecx
f01001c6:	89 cb                	mov    %ecx,%ebx
f01001c8:	83 e3 40             	and    $0x40,%ebx
f01001cb:	83 e0 7f             	and    $0x7f,%eax
f01001ce:	85 db                	test   %ebx,%ebx
f01001d0:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001d3:	0f b6 d2             	movzbl %dl,%edx
f01001d6:	0f b6 82 40 44 10 f0 	movzbl -0xfefbbc0(%edx),%eax
f01001dd:	83 c8 40             	or     $0x40,%eax
f01001e0:	0f b6 c0             	movzbl %al,%eax
f01001e3:	f7 d0                	not    %eax
f01001e5:	21 c8                	and    %ecx,%eax
f01001e7:	a3 c0 8f 17 f0       	mov    %eax,0xf0178fc0
		return 0;
f01001ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01001f1:	e9 a1 00 00 00       	jmp    f0100297 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f01001f6:	8b 0d c0 8f 17 f0    	mov    0xf0178fc0,%ecx
f01001fc:	f6 c1 40             	test   $0x40,%cl
f01001ff:	74 0e                	je     f010020f <kbd_proc_data+0x7e>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100201:	83 c8 80             	or     $0xffffff80,%eax
f0100204:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100206:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100209:	89 0d c0 8f 17 f0    	mov    %ecx,0xf0178fc0
	}

	shift |= shiftcode[data];
f010020f:	0f b6 c2             	movzbl %dl,%eax
f0100212:	0f b6 90 40 44 10 f0 	movzbl -0xfefbbc0(%eax),%edx
f0100219:	0b 15 c0 8f 17 f0    	or     0xf0178fc0,%edx
	shift ^= togglecode[data];
f010021f:	0f b6 88 40 43 10 f0 	movzbl -0xfefbcc0(%eax),%ecx
f0100226:	31 ca                	xor    %ecx,%edx
f0100228:	89 15 c0 8f 17 f0    	mov    %edx,0xf0178fc0

	c = charcode[shift & (CTL | SHIFT)][data];
f010022e:	89 d1                	mov    %edx,%ecx
f0100230:	83 e1 03             	and    $0x3,%ecx
f0100233:	8b 0c 8d 00 43 10 f0 	mov    -0xfefbd00(,%ecx,4),%ecx
f010023a:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
f010023e:	0f b6 d8             	movzbl %al,%ebx
	if (shift & CAPSLOCK) {
f0100241:	f6 c2 08             	test   $0x8,%dl
f0100244:	74 1b                	je     f0100261 <kbd_proc_data+0xd0>
		if ('a' <= c && c <= 'z')
f0100246:	89 d8                	mov    %ebx,%eax
f0100248:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010024b:	83 f9 19             	cmp    $0x19,%ecx
f010024e:	77 05                	ja     f0100255 <kbd_proc_data+0xc4>
			c += 'A' - 'a';
f0100250:	83 eb 20             	sub    $0x20,%ebx
f0100253:	eb 0c                	jmp    f0100261 <kbd_proc_data+0xd0>
		else if ('A' <= c && c <= 'Z')
f0100255:	83 e8 41             	sub    $0x41,%eax
			c += 'a' - 'A';
f0100258:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010025b:	83 f8 19             	cmp    $0x19,%eax
f010025e:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100261:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100267:	75 2c                	jne    f0100295 <kbd_proc_data+0x104>
f0100269:	f7 d2                	not    %edx
f010026b:	f6 c2 06             	test   $0x6,%dl
f010026e:	75 25                	jne    f0100295 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f0100270:	83 ec 0c             	sub    $0xc,%esp
f0100273:	68 cd 42 10 f0       	push   $0xf01042cd
f0100278:	e8 6c 2c 00 00       	call   f0102ee9 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010027d:	ba 92 00 00 00       	mov    $0x92,%edx
f0100282:	b8 03 00 00 00       	mov    $0x3,%eax
f0100287:	ee                   	out    %al,(%dx)
f0100288:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010028b:	89 d8                	mov    %ebx,%eax
f010028d:	eb 08                	jmp    f0100297 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010028f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100294:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100295:	89 d8                	mov    %ebx,%eax
}
f0100297:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010029a:	c9                   	leave  
f010029b:	c3                   	ret    

f010029c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010029c:	55                   	push   %ebp
f010029d:	89 e5                	mov    %esp,%ebp
f010029f:	57                   	push   %edi
f01002a0:	56                   	push   %esi
f01002a1:	53                   	push   %ebx
f01002a2:	83 ec 1c             	sub    $0x1c,%esp
f01002a5:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002a7:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ac:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002b1:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002b6:	eb 09                	jmp    f01002c1 <cons_putc+0x25>
f01002b8:	89 ca                	mov    %ecx,%edx
f01002ba:	ec                   	in     (%dx),%al
f01002bb:	ec                   	in     (%dx),%al
f01002bc:	ec                   	in     (%dx),%al
f01002bd:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002be:	83 c3 01             	add    $0x1,%ebx
f01002c1:	89 f2                	mov    %esi,%edx
f01002c3:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002c4:	a8 20                	test   $0x20,%al
f01002c6:	75 08                	jne    f01002d0 <cons_putc+0x34>
f01002c8:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002ce:	7e e8                	jle    f01002b8 <cons_putc+0x1c>
f01002d0:	89 f8                	mov    %edi,%eax
f01002d2:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002da:	89 f8                	mov    %edi,%eax
f01002dc:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002dd:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002e2:	be 79 03 00 00       	mov    $0x379,%esi
f01002e7:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002ec:	eb 09                	jmp    f01002f7 <cons_putc+0x5b>
f01002ee:	89 ca                	mov    %ecx,%edx
f01002f0:	ec                   	in     (%dx),%al
f01002f1:	ec                   	in     (%dx),%al
f01002f2:	ec                   	in     (%dx),%al
f01002f3:	ec                   	in     (%dx),%al
f01002f4:	83 c3 01             	add    $0x1,%ebx
f01002f7:	89 f2                	mov    %esi,%edx
f01002f9:	ec                   	in     (%dx),%al
f01002fa:	84 c0                	test   %al,%al
f01002fc:	78 08                	js     f0100306 <cons_putc+0x6a>
f01002fe:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100304:	7e e8                	jle    f01002ee <cons_putc+0x52>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100306:	ba 78 03 00 00       	mov    $0x378,%edx
f010030b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010030f:	ee                   	out    %al,(%dx)
f0100310:	b2 7a                	mov    $0x7a,%dl
f0100312:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100317:	ee                   	out    %al,(%dx)
f0100318:	b8 08 00 00 00       	mov    $0x8,%eax
f010031d:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010031e:	89 fa                	mov    %edi,%edx
f0100320:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100326:	89 f8                	mov    %edi,%eax
f0100328:	80 cc 07             	or     $0x7,%ah
f010032b:	85 d2                	test   %edx,%edx
f010032d:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100330:	89 f8                	mov    %edi,%eax
f0100332:	0f b6 c0             	movzbl %al,%eax
f0100335:	83 f8 09             	cmp    $0x9,%eax
f0100338:	74 74                	je     f01003ae <cons_putc+0x112>
f010033a:	83 f8 09             	cmp    $0x9,%eax
f010033d:	7f 0a                	jg     f0100349 <cons_putc+0xad>
f010033f:	83 f8 08             	cmp    $0x8,%eax
f0100342:	74 14                	je     f0100358 <cons_putc+0xbc>
f0100344:	e9 99 00 00 00       	jmp    f01003e2 <cons_putc+0x146>
f0100349:	83 f8 0a             	cmp    $0xa,%eax
f010034c:	74 3a                	je     f0100388 <cons_putc+0xec>
f010034e:	83 f8 0d             	cmp    $0xd,%eax
f0100351:	74 3d                	je     f0100390 <cons_putc+0xf4>
f0100353:	e9 8a 00 00 00       	jmp    f01003e2 <cons_putc+0x146>
	case '\b':
		if (crt_pos > 0) {
f0100358:	0f b7 05 08 92 17 f0 	movzwl 0xf0179208,%eax
f010035f:	66 85 c0             	test   %ax,%ax
f0100362:	0f 84 e6 00 00 00    	je     f010044e <cons_putc+0x1b2>
			crt_pos--;
f0100368:	83 e8 01             	sub    $0x1,%eax
f010036b:	66 a3 08 92 17 f0    	mov    %ax,0xf0179208
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100371:	0f b7 c0             	movzwl %ax,%eax
f0100374:	66 81 e7 00 ff       	and    $0xff00,%di
f0100379:	83 cf 20             	or     $0x20,%edi
f010037c:	8b 15 0c 92 17 f0    	mov    0xf017920c,%edx
f0100382:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100386:	eb 78                	jmp    f0100400 <cons_putc+0x164>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100388:	66 83 05 08 92 17 f0 	addw   $0x50,0xf0179208
f010038f:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100390:	0f b7 05 08 92 17 f0 	movzwl 0xf0179208,%eax
f0100397:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010039d:	c1 e8 16             	shr    $0x16,%eax
f01003a0:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003a3:	c1 e0 04             	shl    $0x4,%eax
f01003a6:	66 a3 08 92 17 f0    	mov    %ax,0xf0179208
f01003ac:	eb 52                	jmp    f0100400 <cons_putc+0x164>
		break;
	case '\t':
		cons_putc(' ');
f01003ae:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b3:	e8 e4 fe ff ff       	call   f010029c <cons_putc>
		cons_putc(' ');
f01003b8:	b8 20 00 00 00       	mov    $0x20,%eax
f01003bd:	e8 da fe ff ff       	call   f010029c <cons_putc>
		cons_putc(' ');
f01003c2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c7:	e8 d0 fe ff ff       	call   f010029c <cons_putc>
		cons_putc(' ');
f01003cc:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d1:	e8 c6 fe ff ff       	call   f010029c <cons_putc>
		cons_putc(' ');
f01003d6:	b8 20 00 00 00       	mov    $0x20,%eax
f01003db:	e8 bc fe ff ff       	call   f010029c <cons_putc>
f01003e0:	eb 1e                	jmp    f0100400 <cons_putc+0x164>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003e2:	0f b7 05 08 92 17 f0 	movzwl 0xf0179208,%eax
f01003e9:	8d 50 01             	lea    0x1(%eax),%edx
f01003ec:	66 89 15 08 92 17 f0 	mov    %dx,0xf0179208
f01003f3:	0f b7 c0             	movzwl %ax,%eax
f01003f6:	8b 15 0c 92 17 f0    	mov    0xf017920c,%edx
f01003fc:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100400:	66 81 3d 08 92 17 f0 	cmpw   $0x7cf,0xf0179208
f0100407:	cf 07 
f0100409:	76 43                	jbe    f010044e <cons_putc+0x1b2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010040b:	a1 0c 92 17 f0       	mov    0xf017920c,%eax
f0100410:	83 ec 04             	sub    $0x4,%esp
f0100413:	68 00 0f 00 00       	push   $0xf00
f0100418:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010041e:	52                   	push   %edx
f010041f:	50                   	push   %eax
f0100420:	e8 e8 39 00 00       	call   f0103e0d <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100425:	8b 15 0c 92 17 f0    	mov    0xf017920c,%edx
f010042b:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100431:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100437:	83 c4 10             	add    $0x10,%esp
f010043a:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010043f:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100442:	39 d0                	cmp    %edx,%eax
f0100444:	75 f4                	jne    f010043a <cons_putc+0x19e>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100446:	66 83 2d 08 92 17 f0 	subw   $0x50,0xf0179208
f010044d:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010044e:	8b 0d 10 92 17 f0    	mov    0xf0179210,%ecx
f0100454:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100459:	89 ca                	mov    %ecx,%edx
f010045b:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010045c:	0f b7 1d 08 92 17 f0 	movzwl 0xf0179208,%ebx
f0100463:	8d 71 01             	lea    0x1(%ecx),%esi
f0100466:	89 d8                	mov    %ebx,%eax
f0100468:	66 c1 e8 08          	shr    $0x8,%ax
f010046c:	89 f2                	mov    %esi,%edx
f010046e:	ee                   	out    %al,(%dx)
f010046f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100474:	89 ca                	mov    %ecx,%edx
f0100476:	ee                   	out    %al,(%dx)
f0100477:	89 d8                	mov    %ebx,%eax
f0100479:	89 f2                	mov    %esi,%edx
f010047b:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010047c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010047f:	5b                   	pop    %ebx
f0100480:	5e                   	pop    %esi
f0100481:	5f                   	pop    %edi
f0100482:	5d                   	pop    %ebp
f0100483:	c3                   	ret    

f0100484 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100484:	80 3d 14 92 17 f0 00 	cmpb   $0x0,0xf0179214
f010048b:	74 11                	je     f010049e <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010048d:	55                   	push   %ebp
f010048e:	89 e5                	mov    %esp,%ebp
f0100490:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100493:	b8 31 01 10 f0       	mov    $0xf0100131,%eax
f0100498:	e8 b0 fc ff ff       	call   f010014d <cons_intr>
}
f010049d:	c9                   	leave  
f010049e:	f3 c3                	repz ret 

f01004a0 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004a0:	55                   	push   %ebp
f01004a1:	89 e5                	mov    %esp,%ebp
f01004a3:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004a6:	b8 91 01 10 f0       	mov    $0xf0100191,%eax
f01004ab:	e8 9d fc ff ff       	call   f010014d <cons_intr>
}
f01004b0:	c9                   	leave  
f01004b1:	c3                   	ret    

f01004b2 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004b2:	55                   	push   %ebp
f01004b3:	89 e5                	mov    %esp,%ebp
f01004b5:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004b8:	e8 c7 ff ff ff       	call   f0100484 <serial_intr>
	kbd_intr();
f01004bd:	e8 de ff ff ff       	call   f01004a0 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004c2:	a1 00 92 17 f0       	mov    0xf0179200,%eax
f01004c7:	3b 05 04 92 17 f0    	cmp    0xf0179204,%eax
f01004cd:	74 26                	je     f01004f5 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004cf:	8d 50 01             	lea    0x1(%eax),%edx
f01004d2:	89 15 00 92 17 f0    	mov    %edx,0xf0179200
f01004d8:	0f b6 88 00 90 17 f0 	movzbl -0xfe87000(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004df:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004e1:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004e7:	75 11                	jne    f01004fa <cons_getc+0x48>
			cons.rpos = 0;
f01004e9:	c7 05 00 92 17 f0 00 	movl   $0x0,0xf0179200
f01004f0:	00 00 00 
f01004f3:	eb 05                	jmp    f01004fa <cons_getc+0x48>
		return c;
	}
	return 0;
f01004f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004fa:	c9                   	leave  
f01004fb:	c3                   	ret    

f01004fc <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004fc:	55                   	push   %ebp
f01004fd:	89 e5                	mov    %esp,%ebp
f01004ff:	57                   	push   %edi
f0100500:	56                   	push   %esi
f0100501:	53                   	push   %ebx
f0100502:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100505:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010050c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100513:	5a a5 
	if (*cp != 0xA55A) {
f0100515:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010051c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100520:	74 11                	je     f0100533 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100522:	c7 05 10 92 17 f0 b4 	movl   $0x3b4,0xf0179210
f0100529:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010052c:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100531:	eb 16                	jmp    f0100549 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100533:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010053a:	c7 05 10 92 17 f0 d4 	movl   $0x3d4,0xf0179210
f0100541:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100544:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100549:	8b 3d 10 92 17 f0    	mov    0xf0179210,%edi
f010054f:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100554:	89 fa                	mov    %edi,%edx
f0100556:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100557:	8d 4f 01             	lea    0x1(%edi),%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010055a:	89 ca                	mov    %ecx,%edx
f010055c:	ec                   	in     (%dx),%al
f010055d:	0f b6 c0             	movzbl %al,%eax
f0100560:	c1 e0 08             	shl    $0x8,%eax
f0100563:	89 c3                	mov    %eax,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100565:	b8 0f 00 00 00       	mov    $0xf,%eax
f010056a:	89 fa                	mov    %edi,%edx
f010056c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010056d:	89 ca                	mov    %ecx,%edx
f010056f:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100570:	89 35 0c 92 17 f0    	mov    %esi,0xf017920c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100576:	0f b6 c8             	movzbl %al,%ecx
f0100579:	89 d8                	mov    %ebx,%eax
f010057b:	09 c8                	or     %ecx,%eax

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010057d:	66 a3 08 92 17 f0    	mov    %ax,0xf0179208
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100583:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100588:	b8 00 00 00 00       	mov    $0x0,%eax
f010058d:	89 da                	mov    %ebx,%edx
f010058f:	ee                   	out    %al,(%dx)
f0100590:	b2 fb                	mov    $0xfb,%dl
f0100592:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100597:	ee                   	out    %al,(%dx)
f0100598:	be f8 03 00 00       	mov    $0x3f8,%esi
f010059d:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005a2:	89 f2                	mov    %esi,%edx
f01005a4:	ee                   	out    %al,(%dx)
f01005a5:	b2 f9                	mov    $0xf9,%dl
f01005a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ac:	ee                   	out    %al,(%dx)
f01005ad:	b2 fb                	mov    $0xfb,%dl
f01005af:	b8 03 00 00 00       	mov    $0x3,%eax
f01005b4:	ee                   	out    %al,(%dx)
f01005b5:	b2 fc                	mov    $0xfc,%dl
f01005b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01005bc:	ee                   	out    %al,(%dx)
f01005bd:	b2 f9                	mov    $0xf9,%dl
f01005bf:	b8 01 00 00 00       	mov    $0x1,%eax
f01005c4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c5:	b2 fd                	mov    $0xfd,%dl
f01005c7:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005c8:	3c ff                	cmp    $0xff,%al
f01005ca:	0f 95 c1             	setne  %cl
f01005cd:	88 0d 14 92 17 f0    	mov    %cl,0xf0179214
f01005d3:	89 da                	mov    %ebx,%edx
f01005d5:	ec                   	in     (%dx),%al
f01005d6:	89 f2                	mov    %esi,%edx
f01005d8:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005d9:	84 c9                	test   %cl,%cl
f01005db:	75 10                	jne    f01005ed <cons_init+0xf1>
		cprintf("Serial port does not exist!\n");
f01005dd:	83 ec 0c             	sub    $0xc,%esp
f01005e0:	68 d9 42 10 f0       	push   $0xf01042d9
f01005e5:	e8 ff 28 00 00       	call   f0102ee9 <cprintf>
f01005ea:	83 c4 10             	add    $0x10,%esp
}
f01005ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005f0:	5b                   	pop    %ebx
f01005f1:	5e                   	pop    %esi
f01005f2:	5f                   	pop    %edi
f01005f3:	5d                   	pop    %ebp
f01005f4:	c3                   	ret    

f01005f5 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005f5:	55                   	push   %ebp
f01005f6:	89 e5                	mov    %esp,%ebp
f01005f8:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01005fe:	e8 99 fc ff ff       	call   f010029c <cons_putc>
}
f0100603:	c9                   	leave  
f0100604:	c3                   	ret    

f0100605 <getchar>:

int
getchar(void)
{
f0100605:	55                   	push   %ebp
f0100606:	89 e5                	mov    %esp,%ebp
f0100608:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010060b:	e8 a2 fe ff ff       	call   f01004b2 <cons_getc>
f0100610:	85 c0                	test   %eax,%eax
f0100612:	74 f7                	je     f010060b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100614:	c9                   	leave  
f0100615:	c3                   	ret    

f0100616 <iscons>:

int
iscons(int fdnum)
{
f0100616:	55                   	push   %ebp
f0100617:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100619:	b8 01 00 00 00       	mov    $0x1,%eax
f010061e:	5d                   	pop    %ebp
f010061f:	c3                   	ret    

f0100620 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
f0100623:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100626:	68 40 45 10 f0       	push   $0xf0104540
f010062b:	68 5e 45 10 f0       	push   $0xf010455e
f0100630:	68 63 45 10 f0       	push   $0xf0104563
f0100635:	e8 af 28 00 00       	call   f0102ee9 <cprintf>
f010063a:	83 c4 0c             	add    $0xc,%esp
f010063d:	68 18 46 10 f0       	push   $0xf0104618
f0100642:	68 6c 45 10 f0       	push   $0xf010456c
f0100647:	68 63 45 10 f0       	push   $0xf0104563
f010064c:	e8 98 28 00 00       	call   f0102ee9 <cprintf>
f0100651:	83 c4 0c             	add    $0xc,%esp
f0100654:	68 75 45 10 f0       	push   $0xf0104575
f0100659:	68 8c 45 10 f0       	push   $0xf010458c
f010065e:	68 63 45 10 f0       	push   $0xf0104563
f0100663:	e8 81 28 00 00       	call   f0102ee9 <cprintf>
	return 0;
}
f0100668:	b8 00 00 00 00       	mov    $0x0,%eax
f010066d:	c9                   	leave  
f010066e:	c3                   	ret    

f010066f <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010066f:	55                   	push   %ebp
f0100670:	89 e5                	mov    %esp,%ebp
f0100672:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100675:	68 96 45 10 f0       	push   $0xf0104596
f010067a:	e8 6a 28 00 00       	call   f0102ee9 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010067f:	83 c4 08             	add    $0x8,%esp
f0100682:	68 0c 00 10 00       	push   $0x10000c
f0100687:	68 40 46 10 f0       	push   $0xf0104640
f010068c:	e8 58 28 00 00       	call   f0102ee9 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100691:	83 c4 0c             	add    $0xc,%esp
f0100694:	68 0c 00 10 00       	push   $0x10000c
f0100699:	68 0c 00 10 f0       	push   $0xf010000c
f010069e:	68 68 46 10 f0       	push   $0xf0104668
f01006a3:	e8 41 28 00 00       	call   f0102ee9 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006a8:	83 c4 0c             	add    $0xc,%esp
f01006ab:	68 75 42 10 00       	push   $0x104275
f01006b0:	68 75 42 10 f0       	push   $0xf0104275
f01006b5:	68 8c 46 10 f0       	push   $0xf010468c
f01006ba:	e8 2a 28 00 00       	call   f0102ee9 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006bf:	83 c4 0c             	add    $0xc,%esp
f01006c2:	68 9d 8f 17 00       	push   $0x178f9d
f01006c7:	68 9d 8f 17 f0       	push   $0xf0178f9d
f01006cc:	68 b0 46 10 f0       	push   $0xf01046b0
f01006d1:	e8 13 28 00 00       	call   f0102ee9 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006d6:	83 c4 0c             	add    $0xc,%esp
f01006d9:	68 10 9f 17 00       	push   $0x179f10
f01006de:	68 10 9f 17 f0       	push   $0xf0179f10
f01006e3:	68 d4 46 10 f0       	push   $0xf01046d4
f01006e8:	e8 fc 27 00 00       	call   f0102ee9 <cprintf>
f01006ed:	b8 0f a3 17 f0       	mov    $0xf017a30f,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006f2:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006f7:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01006fa:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006ff:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100705:	85 c0                	test   %eax,%eax
f0100707:	0f 48 c2             	cmovs  %edx,%eax
f010070a:	c1 f8 0a             	sar    $0xa,%eax
f010070d:	50                   	push   %eax
f010070e:	68 f8 46 10 f0       	push   $0xf01046f8
f0100713:	e8 d1 27 00 00       	call   f0102ee9 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100718:	b8 00 00 00 00       	mov    $0x0,%eax
f010071d:	c9                   	leave  
f010071e:	c3                   	ret    

f010071f <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010071f:	55                   	push   %ebp
f0100720:	89 e5                	mov    %esp,%ebp
f0100722:	56                   	push   %esi
f0100723:	53                   	push   %ebx
f0100724:	83 ec 2c             	sub    $0x2c,%esp
	// Your code here.
	uint32_t * ebp = (uint32_t *)read_ebp();
f0100727:	89 eb                	mov    %ebp,%ebx
	struct Eipdebuginfo info; 
	cprintf("\nStack backtrace:\n");
f0100729:	68 af 45 10 f0       	push   $0xf01045af
f010072e:	e8 b6 27 00 00       	call   f0102ee9 <cprintf>
	for(;ebp>0x0;)
f0100733:	83 c4 10             	add    $0x10,%esp
	{
		cprintf("  ebp %08x  eip  %08x args %08x %08x %08x %08x %08x\n",ebp,ebp[1], ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
		debuginfo_eip(ebp[1],&info);
f0100736:	8d 75 e0             	lea    -0x20(%ebp),%esi
{
	// Your code here.
	uint32_t * ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info; 
	cprintf("\nStack backtrace:\n");
	for(;ebp>0x0;)
f0100739:	eb 4e                	jmp    f0100789 <mon_backtrace+0x6a>
	{
		cprintf("  ebp %08x  eip  %08x args %08x %08x %08x %08x %08x\n",ebp,ebp[1], ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
f010073b:	ff 73 18             	pushl  0x18(%ebx)
f010073e:	ff 73 14             	pushl  0x14(%ebx)
f0100741:	ff 73 10             	pushl  0x10(%ebx)
f0100744:	ff 73 0c             	pushl  0xc(%ebx)
f0100747:	ff 73 08             	pushl  0x8(%ebx)
f010074a:	ff 73 04             	pushl  0x4(%ebx)
f010074d:	53                   	push   %ebx
f010074e:	68 24 47 10 f0       	push   $0xf0104724
f0100753:	e8 91 27 00 00       	call   f0102ee9 <cprintf>
		debuginfo_eip(ebp[1],&info);
f0100758:	83 c4 18             	add    $0x18,%esp
f010075b:	56                   	push   %esi
f010075c:	ff 73 04             	pushl  0x4(%ebx)
f010075f:	e8 89 2c 00 00       	call   f01033ed <debuginfo_eip>
		cprintf("         %s:%d: %.*s+%u\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, ((uint32_t)ebp[1]-(uint32_t)(info.eip_fn_addr)));
f0100764:	83 c4 08             	add    $0x8,%esp
f0100767:	8b 43 04             	mov    0x4(%ebx),%eax
f010076a:	2b 45 f0             	sub    -0x10(%ebp),%eax
f010076d:	50                   	push   %eax
f010076e:	ff 75 e8             	pushl  -0x18(%ebp)
f0100771:	ff 75 ec             	pushl  -0x14(%ebp)
f0100774:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100777:	ff 75 e0             	pushl  -0x20(%ebp)
f010077a:	68 c2 45 10 f0       	push   $0xf01045c2
f010077f:	e8 65 27 00 00       	call   f0102ee9 <cprintf>
		ebp = (uint32_t *)*ebp;
f0100784:	8b 1b                	mov    (%ebx),%ebx
f0100786:	83 c4 20             	add    $0x20,%esp
{
	// Your code here.
	uint32_t * ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info; 
	cprintf("\nStack backtrace:\n");
	for(;ebp>0x0;)
f0100789:	85 db                	test   %ebx,%ebx
f010078b:	75 ae                	jne    f010073b <mon_backtrace+0x1c>
		debuginfo_eip(ebp[1],&info);
		cprintf("         %s:%d: %.*s+%u\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, ((uint32_t)ebp[1]-(uint32_t)(info.eip_fn_addr)));
		ebp = (uint32_t *)*ebp;
	}
	return 0;
}
f010078d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100792:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100795:	5b                   	pop    %ebx
f0100796:	5e                   	pop    %esi
f0100797:	5d                   	pop    %ebp
f0100798:	c3                   	ret    

f0100799 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100799:	55                   	push   %ebp
f010079a:	89 e5                	mov    %esp,%ebp
f010079c:	57                   	push   %edi
f010079d:	56                   	push   %esi
f010079e:	53                   	push   %ebx
f010079f:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007a2:	68 5c 47 10 f0       	push   $0xf010475c
f01007a7:	e8 3d 27 00 00       	call   f0102ee9 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007ac:	c7 04 24 80 47 10 f0 	movl   $0xf0104780,(%esp)
f01007b3:	e8 31 27 00 00       	call   f0102ee9 <cprintf>

	if (tf != NULL)
f01007b8:	83 c4 10             	add    $0x10,%esp
f01007bb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01007bf:	74 0e                	je     f01007cf <monitor+0x36>
		print_trapframe(tf);
f01007c1:	83 ec 0c             	sub    $0xc,%esp
f01007c4:	ff 75 08             	pushl  0x8(%ebp)
f01007c7:	e8 51 28 00 00       	call   f010301d <print_trapframe>
f01007cc:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01007cf:	83 ec 0c             	sub    $0xc,%esp
f01007d2:	68 db 45 10 f0       	push   $0xf01045db
f01007d7:	e8 8d 33 00 00       	call   f0103b69 <readline>
f01007dc:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007de:	83 c4 10             	add    $0x10,%esp
f01007e1:	85 c0                	test   %eax,%eax
f01007e3:	74 ea                	je     f01007cf <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007e5:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007ec:	be 00 00 00 00       	mov    $0x0,%esi
f01007f1:	eb 0a                	jmp    f01007fd <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007f3:	c6 03 00             	movb   $0x0,(%ebx)
f01007f6:	89 f7                	mov    %esi,%edi
f01007f8:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01007fb:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007fd:	0f b6 03             	movzbl (%ebx),%eax
f0100800:	84 c0                	test   %al,%al
f0100802:	74 63                	je     f0100867 <monitor+0xce>
f0100804:	83 ec 08             	sub    $0x8,%esp
f0100807:	0f be c0             	movsbl %al,%eax
f010080a:	50                   	push   %eax
f010080b:	68 df 45 10 f0       	push   $0xf01045df
f0100810:	e8 6e 35 00 00       	call   f0103d83 <strchr>
f0100815:	83 c4 10             	add    $0x10,%esp
f0100818:	85 c0                	test   %eax,%eax
f010081a:	75 d7                	jne    f01007f3 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f010081c:	80 3b 00             	cmpb   $0x0,(%ebx)
f010081f:	74 46                	je     f0100867 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100821:	83 fe 0f             	cmp    $0xf,%esi
f0100824:	75 14                	jne    f010083a <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100826:	83 ec 08             	sub    $0x8,%esp
f0100829:	6a 10                	push   $0x10
f010082b:	68 e4 45 10 f0       	push   $0xf01045e4
f0100830:	e8 b4 26 00 00       	call   f0102ee9 <cprintf>
f0100835:	83 c4 10             	add    $0x10,%esp
f0100838:	eb 95                	jmp    f01007cf <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f010083a:	8d 7e 01             	lea    0x1(%esi),%edi
f010083d:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100841:	eb 03                	jmp    f0100846 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100843:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100846:	0f b6 03             	movzbl (%ebx),%eax
f0100849:	84 c0                	test   %al,%al
f010084b:	74 ae                	je     f01007fb <monitor+0x62>
f010084d:	83 ec 08             	sub    $0x8,%esp
f0100850:	0f be c0             	movsbl %al,%eax
f0100853:	50                   	push   %eax
f0100854:	68 df 45 10 f0       	push   $0xf01045df
f0100859:	e8 25 35 00 00       	call   f0103d83 <strchr>
f010085e:	83 c4 10             	add    $0x10,%esp
f0100861:	85 c0                	test   %eax,%eax
f0100863:	74 de                	je     f0100843 <monitor+0xaa>
f0100865:	eb 94                	jmp    f01007fb <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100867:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010086e:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010086f:	85 f6                	test   %esi,%esi
f0100871:	0f 84 58 ff ff ff    	je     f01007cf <monitor+0x36>
f0100877:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010087c:	83 ec 08             	sub    $0x8,%esp
f010087f:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100882:	ff 34 85 c0 47 10 f0 	pushl  -0xfefb840(,%eax,4)
f0100889:	ff 75 a8             	pushl  -0x58(%ebp)
f010088c:	e8 94 34 00 00       	call   f0103d25 <strcmp>
f0100891:	83 c4 10             	add    $0x10,%esp
f0100894:	85 c0                	test   %eax,%eax
f0100896:	75 22                	jne    f01008ba <monitor+0x121>
			return commands[i].func(argc, argv, tf);
f0100898:	83 ec 04             	sub    $0x4,%esp
f010089b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010089e:	ff 75 08             	pushl  0x8(%ebp)
f01008a1:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008a4:	52                   	push   %edx
f01008a5:	56                   	push   %esi
f01008a6:	ff 14 85 c8 47 10 f0 	call   *-0xfefb838(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008ad:	83 c4 10             	add    $0x10,%esp
f01008b0:	85 c0                	test   %eax,%eax
f01008b2:	0f 89 17 ff ff ff    	jns    f01007cf <monitor+0x36>
f01008b8:	eb 20                	jmp    f01008da <monitor+0x141>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01008ba:	83 c3 01             	add    $0x1,%ebx
f01008bd:	83 fb 03             	cmp    $0x3,%ebx
f01008c0:	75 ba                	jne    f010087c <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008c2:	83 ec 08             	sub    $0x8,%esp
f01008c5:	ff 75 a8             	pushl  -0x58(%ebp)
f01008c8:	68 01 46 10 f0       	push   $0xf0104601
f01008cd:	e8 17 26 00 00       	call   f0102ee9 <cprintf>
f01008d2:	83 c4 10             	add    $0x10,%esp
f01008d5:	e9 f5 fe ff ff       	jmp    f01007cf <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008da:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008dd:	5b                   	pop    %ebx
f01008de:	5e                   	pop    %esi
f01008df:	5f                   	pop    %edi
f01008e0:	5d                   	pop    %ebp
f01008e1:	c3                   	ret    

f01008e2 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f01008e2:	55                   	push   %ebp
f01008e3:	89 e5                	mov    %esp,%ebp
f01008e5:	57                   	push   %edi
f01008e6:	56                   	push   %esi
f01008e7:	53                   	push   %ebx
f01008e8:	83 ec 1c             	sub    $0x1c,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01008eb:	83 3d 18 92 17 f0 00 	cmpl   $0x0,0xf0179218
f01008f2:	75 11                	jne    f0100905 <boot_alloc+0x23>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01008f4:	ba 0f af 17 f0       	mov    $0xf017af0f,%edx
f01008f9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01008ff:	89 15 18 92 17 f0    	mov    %edx,0xf0179218
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	//cprintf("\nBoot alloc_ next_free val:%x",nextfree);
	int i = n / PGSIZE;
f0100905:	89 c3                	mov    %eax,%ebx
f0100907:	c1 eb 0c             	shr    $0xc,%ebx
	if(n%PGSIZE != 0 && i!=0)
f010090a:	85 db                	test   %ebx,%ebx
f010090c:	74 0e                	je     f010091c <boot_alloc+0x3a>
f010090e:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0100913:	0f 95 c2             	setne  %dl
		i += 1;
f0100916:	80 fa 01             	cmp    $0x1,%dl
f0100919:	83 db ff             	sbb    $0xffffffff,%ebx
	int j;
	//cprintf("\nNext Address start:%p, Value of I:%d",nextfree,i);
	returnAddress = (void *)nextfree;
f010091c:	8b 35 18 92 17 f0    	mov    0xf0179218,%esi
f0100922:	89 f7                	mov    %esi,%edi
f0100924:	89 75 e4             	mov    %esi,-0x1c(%ebp)
	if (n!=0)
f0100927:	85 c0                	test   %eax,%eax
f0100929:	74 4b                	je     f0100976 <boot_alloc+0x94>
	{
		for(j = 0; j < i; j++)
		{
			if((uint32_t)nextfree - KERNBASE > npages * PGSIZE)     // (npages * PGSIZE) corresponds to the available physical memory.
f010092b:	8b 35 04 9f 17 f0    	mov    0xf0179f04,%esi
f0100931:	c1 e6 0c             	shl    $0xc,%esi
f0100934:	89 f8                	mov    %edi,%eax
f0100936:	ba 00 00 00 00       	mov    $0x0,%edx
f010093b:	eb 2e                	jmp    f010096b <boot_alloc+0x89>
f010093d:	8d 88 00 10 00 00    	lea    0x1000(%eax),%ecx
f0100943:	05 00 00 00 10       	add    $0x10000000,%eax
f0100948:	39 c6                	cmp    %eax,%esi
f010094a:	73 1a                	jae    f0100966 <boot_alloc+0x84>
f010094c:	89 3d 18 92 17 f0    	mov    %edi,0xf0179218
			{
				panic("cannot allocate more memory...!!\n");
f0100952:	83 ec 04             	sub    $0x4,%esp
f0100955:	68 e4 47 10 f0       	push   $0xf01047e4
f010095a:	6a 74                	push   $0x74
f010095c:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0100961:	e8 3a f7 ff ff       	call   f01000a0 <_panic>
	int j;
	//cprintf("\nNext Address start:%p, Value of I:%d",nextfree,i);
	returnAddress = (void *)nextfree;
	if (n!=0)
	{
		for(j = 0; j < i; j++)
f0100966:	83 c2 01             	add    $0x1,%edx
f0100969:	89 c8                	mov    %ecx,%eax
f010096b:	89 c7                	mov    %eax,%edi
f010096d:	39 d3                	cmp    %edx,%ebx
f010096f:	7f cc                	jg     f010093d <boot_alloc+0x5b>
f0100971:	a3 18 92 17 f0       	mov    %eax,0xf0179218
		}
	}
	
	//cprintf("\nNext Address start after loop:%p\n",nextfree);
	return returnAddress;
}
f0100976:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100979:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010097c:	5b                   	pop    %ebx
f010097d:	5e                   	pop    %esi
f010097e:	5f                   	pop    %edi
f010097f:	5d                   	pop    %ebp
f0100980:	c3                   	ret    

f0100981 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100981:	89 d1                	mov    %edx,%ecx
f0100983:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100986:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100989:	a8 01                	test   $0x1,%al
f010098b:	74 52                	je     f01009df <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010098d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100992:	89 c1                	mov    %eax,%ecx
f0100994:	c1 e9 0c             	shr    $0xc,%ecx
f0100997:	3b 0d 04 9f 17 f0    	cmp    0xf0179f04,%ecx
f010099d:	72 1b                	jb     f01009ba <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f010099f:	55                   	push   %ebp
f01009a0:	89 e5                	mov    %esp,%ebp
f01009a2:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009a5:	50                   	push   %eax
f01009a6:	68 08 48 10 f0       	push   $0xf0104808
f01009ab:	68 82 03 00 00       	push   $0x382
f01009b0:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01009b5:	e8 e6 f6 ff ff       	call   f01000a0 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f01009ba:	c1 ea 0c             	shr    $0xc,%edx
f01009bd:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009c3:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01009ca:	89 c2                	mov    %eax,%edx
f01009cc:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01009cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009d4:	85 d2                	test   %edx,%edx
f01009d6:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01009db:	0f 44 c2             	cmove  %edx,%eax
f01009de:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01009df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f01009e4:	c3                   	ret    

f01009e5 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01009e5:	55                   	push   %ebp
f01009e6:	89 e5                	mov    %esp,%ebp
f01009e8:	57                   	push   %edi
f01009e9:	56                   	push   %esi
f01009ea:	53                   	push   %ebx
f01009eb:	83 ec 3c             	sub    $0x3c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01009ee:	84 c0                	test   %al,%al
f01009f0:	0f 85 7a 02 00 00    	jne    f0100c70 <check_page_free_list+0x28b>
f01009f6:	e9 87 02 00 00       	jmp    f0100c82 <check_page_free_list+0x29d>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f01009fb:	83 ec 04             	sub    $0x4,%esp
f01009fe:	68 2c 48 10 f0       	push   $0xf010482c
f0100a03:	68 c0 02 00 00       	push   $0x2c0
f0100a08:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0100a0d:	e8 8e f6 ff ff       	call   f01000a0 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a12:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a15:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a18:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a1b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a1e:	89 c2                	mov    %eax,%edx
f0100a20:	2b 15 0c 9f 17 f0    	sub    0xf0179f0c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a26:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a2c:	0f 95 c2             	setne  %dl
f0100a2f:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a32:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a36:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a38:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a3c:	8b 00                	mov    (%eax),%eax
f0100a3e:	85 c0                	test   %eax,%eax
f0100a40:	75 dc                	jne    f0100a1e <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a45:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a4b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a4e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a51:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a53:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a56:	a3 1c 92 17 f0       	mov    %eax,0xf017921c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a5b:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a60:	8b 1d 1c 92 17 f0    	mov    0xf017921c,%ebx
f0100a66:	eb 53                	jmp    f0100abb <check_page_free_list+0xd6>
f0100a68:	89 d8                	mov    %ebx,%eax
f0100a6a:	2b 05 0c 9f 17 f0    	sub    0xf0179f0c,%eax
f0100a70:	c1 f8 03             	sar    $0x3,%eax
f0100a73:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a76:	89 c2                	mov    %eax,%edx
f0100a78:	c1 ea 16             	shr    $0x16,%edx
f0100a7b:	39 f2                	cmp    %esi,%edx
f0100a7d:	73 3a                	jae    f0100ab9 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a7f:	89 c2                	mov    %eax,%edx
f0100a81:	c1 ea 0c             	shr    $0xc,%edx
f0100a84:	3b 15 04 9f 17 f0    	cmp    0xf0179f04,%edx
f0100a8a:	72 12                	jb     f0100a9e <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a8c:	50                   	push   %eax
f0100a8d:	68 08 48 10 f0       	push   $0xf0104808
f0100a92:	6a 56                	push   $0x56
f0100a94:	68 e5 4f 10 f0       	push   $0xf0104fe5
f0100a99:	e8 02 f6 ff ff       	call   f01000a0 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100a9e:	83 ec 04             	sub    $0x4,%esp
f0100aa1:	68 80 00 00 00       	push   $0x80
f0100aa6:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100aab:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ab0:	50                   	push   %eax
f0100ab1:	e8 0a 33 00 00       	call   f0103dc0 <memset>
f0100ab6:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ab9:	8b 1b                	mov    (%ebx),%ebx
f0100abb:	85 db                	test   %ebx,%ebx
f0100abd:	75 a9                	jne    f0100a68 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100abf:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ac4:	e8 19 fe ff ff       	call   f01008e2 <boot_alloc>
f0100ac9:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100acc:	8b 15 1c 92 17 f0    	mov    0xf017921c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ad2:	8b 0d 0c 9f 17 f0    	mov    0xf0179f0c,%ecx
		assert(pp < pages + npages);
f0100ad8:	a1 04 9f 17 f0       	mov    0xf0179f04,%eax
f0100add:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100ae0:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ae3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100ae6:	be 00 00 00 00       	mov    $0x0,%esi
f0100aeb:	bf 00 00 00 00       	mov    $0x0,%edi
f0100af0:	89 75 cc             	mov    %esi,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100af3:	e9 33 01 00 00       	jmp    f0100c2b <check_page_free_list+0x246>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100af8:	39 ca                	cmp    %ecx,%edx
f0100afa:	73 19                	jae    f0100b15 <check_page_free_list+0x130>
f0100afc:	68 f3 4f 10 f0       	push   $0xf0104ff3
f0100b01:	68 ff 4f 10 f0       	push   $0xf0104fff
f0100b06:	68 da 02 00 00       	push   $0x2da
f0100b0b:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0100b10:	e8 8b f5 ff ff       	call   f01000a0 <_panic>
		assert(pp < pages + npages);
f0100b15:	39 da                	cmp    %ebx,%edx
f0100b17:	72 19                	jb     f0100b32 <check_page_free_list+0x14d>
f0100b19:	68 14 50 10 f0       	push   $0xf0105014
f0100b1e:	68 ff 4f 10 f0       	push   $0xf0104fff
f0100b23:	68 db 02 00 00       	push   $0x2db
f0100b28:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0100b2d:	e8 6e f5 ff ff       	call   f01000a0 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b32:	89 d0                	mov    %edx,%eax
f0100b34:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b37:	a8 07                	test   $0x7,%al
f0100b39:	74 19                	je     f0100b54 <check_page_free_list+0x16f>
f0100b3b:	68 50 48 10 f0       	push   $0xf0104850
f0100b40:	68 ff 4f 10 f0       	push   $0xf0104fff
f0100b45:	68 dc 02 00 00       	push   $0x2dc
f0100b4a:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0100b4f:	e8 4c f5 ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b54:	c1 f8 03             	sar    $0x3,%eax
f0100b57:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b5a:	85 c0                	test   %eax,%eax
f0100b5c:	75 19                	jne    f0100b77 <check_page_free_list+0x192>
f0100b5e:	68 28 50 10 f0       	push   $0xf0105028
f0100b63:	68 ff 4f 10 f0       	push   $0xf0104fff
f0100b68:	68 df 02 00 00       	push   $0x2df
f0100b6d:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0100b72:	e8 29 f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100b77:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b7c:	75 19                	jne    f0100b97 <check_page_free_list+0x1b2>
f0100b7e:	68 39 50 10 f0       	push   $0xf0105039
f0100b83:	68 ff 4f 10 f0       	push   $0xf0104fff
f0100b88:	68 e0 02 00 00       	push   $0x2e0
f0100b8d:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0100b92:	e8 09 f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100b97:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100b9c:	75 19                	jne    f0100bb7 <check_page_free_list+0x1d2>
f0100b9e:	68 84 48 10 f0       	push   $0xf0104884
f0100ba3:	68 ff 4f 10 f0       	push   $0xf0104fff
f0100ba8:	68 e1 02 00 00       	push   $0x2e1
f0100bad:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0100bb2:	e8 e9 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100bb7:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100bbc:	75 19                	jne    f0100bd7 <check_page_free_list+0x1f2>
f0100bbe:	68 52 50 10 f0       	push   $0xf0105052
f0100bc3:	68 ff 4f 10 f0       	push   $0xf0104fff
f0100bc8:	68 e2 02 00 00       	push   $0x2e2
f0100bcd:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0100bd2:	e8 c9 f4 ff ff       	call   f01000a0 <_panic>
f0100bd7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100bda:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100bdf:	76 3f                	jbe    f0100c20 <check_page_free_list+0x23b>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100be1:	89 c6                	mov    %eax,%esi
f0100be3:	c1 ee 0c             	shr    $0xc,%esi
f0100be6:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f0100be9:	77 12                	ja     f0100bfd <check_page_free_list+0x218>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100beb:	50                   	push   %eax
f0100bec:	68 08 48 10 f0       	push   $0xf0104808
f0100bf1:	6a 56                	push   $0x56
f0100bf3:	68 e5 4f 10 f0       	push   $0xf0104fe5
f0100bf8:	e8 a3 f4 ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f0100bfd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c02:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100c05:	76 1e                	jbe    f0100c25 <check_page_free_list+0x240>
f0100c07:	68 a8 48 10 f0       	push   $0xf01048a8
f0100c0c:	68 ff 4f 10 f0       	push   $0xf0104fff
f0100c11:	68 e3 02 00 00       	push   $0x2e3
f0100c16:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0100c1b:	e8 80 f4 ff ff       	call   f01000a0 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100c20:	83 c7 01             	add    $0x1,%edi
f0100c23:	eb 04                	jmp    f0100c29 <check_page_free_list+0x244>
		else
			++nfree_extmem;
f0100c25:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c29:	8b 12                	mov    (%edx),%edx
f0100c2b:	85 d2                	test   %edx,%edx
f0100c2d:	0f 85 c5 fe ff ff    	jne    f0100af8 <check_page_free_list+0x113>
f0100c33:	8b 75 cc             	mov    -0x34(%ebp),%esi
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100c36:	85 ff                	test   %edi,%edi
f0100c38:	7f 19                	jg     f0100c53 <check_page_free_list+0x26e>
f0100c3a:	68 6c 50 10 f0       	push   $0xf010506c
f0100c3f:	68 ff 4f 10 f0       	push   $0xf0104fff
f0100c44:	68 eb 02 00 00       	push   $0x2eb
f0100c49:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0100c4e:	e8 4d f4 ff ff       	call   f01000a0 <_panic>
	assert(nfree_extmem > 0);
f0100c53:	85 f6                	test   %esi,%esi
f0100c55:	7f 42                	jg     f0100c99 <check_page_free_list+0x2b4>
f0100c57:	68 7e 50 10 f0       	push   $0xf010507e
f0100c5c:	68 ff 4f 10 f0       	push   $0xf0104fff
f0100c61:	68 ec 02 00 00       	push   $0x2ec
f0100c66:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0100c6b:	e8 30 f4 ff ff       	call   f01000a0 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100c70:	a1 1c 92 17 f0       	mov    0xf017921c,%eax
f0100c75:	85 c0                	test   %eax,%eax
f0100c77:	0f 85 95 fd ff ff    	jne    f0100a12 <check_page_free_list+0x2d>
f0100c7d:	e9 79 fd ff ff       	jmp    f01009fb <check_page_free_list+0x16>
f0100c82:	83 3d 1c 92 17 f0 00 	cmpl   $0x0,0xf017921c
f0100c89:	0f 84 6c fd ff ff    	je     f01009fb <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c8f:	be 00 04 00 00       	mov    $0x400,%esi
f0100c94:	e9 c7 fd ff ff       	jmp    f0100a60 <check_page_free_list+0x7b>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c9c:	5b                   	pop    %ebx
f0100c9d:	5e                   	pop    %esi
f0100c9e:	5f                   	pop    %edi
f0100c9f:	5d                   	pop    %ebp
f0100ca0:	c3                   	ret    

f0100ca1 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100ca1:	55                   	push   %ebp
f0100ca2:	89 e5                	mov    %esp,%ebp
f0100ca4:	56                   	push   %esi
f0100ca5:	53                   	push   %ebx
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	
	uint32_t pagesForKern = ((uint32_t)boot_alloc(0) - (KERNBASE + ONEMB)) / PGSIZE; 
f0100ca6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cab:	e8 32 fc ff ff       	call   f01008e2 <boot_alloc>
f0100cb0:	8d 98 00 00 f0 0f    	lea    0xff00000(%eax),%ebx
f0100cb6:	c1 eb 0c             	shr    $0xc,%ebx
f0100cb9:	8b 35 1c 92 17 f0    	mov    0xf017921c,%esi
	uint32_t pagesForIOHole = (uint32_t)(EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	uint32_t kernPagesStart = (uint32_t)(ONEMB) / PGSIZE;
	//cprintf("\nPages:%x",pages);
	for (i = 0; i < npages; i++)
f0100cbf:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100cc4:	ba 00 00 00 00       	mov    $0x0,%edx
		{
			pages[i].pp_ref = 1;
			continue;
		}
		// Pages for kernel
		if(i >= kernPagesStart && i <= kernPagesStart+pagesForKern )
f0100cc9:	81 c3 00 01 00 00    	add    $0x100,%ebx
	
	uint32_t pagesForKern = ((uint32_t)boot_alloc(0) - (KERNBASE + ONEMB)) / PGSIZE; 
	uint32_t pagesForIOHole = (uint32_t)(EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	uint32_t kernPagesStart = (uint32_t)(ONEMB) / PGSIZE;
	//cprintf("\nPages:%x",pages);
	for (i = 0; i < npages; i++)
f0100ccf:	eb 62                	jmp    f0100d33 <page_init+0x92>
	{
		if(i==0)
f0100cd1:	85 d2                	test   %edx,%edx
f0100cd3:	75 0d                	jne    f0100ce2 <page_init+0x41>
		{
			pages[i].pp_ref = 1;
f0100cd5:	a1 0c 9f 17 f0       	mov    0xf0179f0c,%eax
f0100cda:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			continue;
f0100ce0:	eb 4b                	jmp    f0100d2d <page_init+0x8c>
f0100ce2:	8d 82 60 ff ff ff    	lea    -0xa0(%edx),%eax
		}
		// IO Hole
		if(i >= ((uint32_t)IOPHYSMEM / PGSIZE) && i < (((uint32_t)IOPHYSMEM / PGSIZE) + pagesForIOHole) )
f0100ce8:	83 f8 5f             	cmp    $0x5f,%eax
f0100ceb:	77 0e                	ja     f0100cfb <page_init+0x5a>
		{
			pages[i].pp_ref = 1;
f0100ced:	a1 0c 9f 17 f0       	mov    0xf0179f0c,%eax
f0100cf2:	66 c7 44 08 04 01 00 	movw   $0x1,0x4(%eax,%ecx,1)
			continue;
f0100cf9:	eb 32                	jmp    f0100d2d <page_init+0x8c>
		}
		// Pages for kernel
		if(i >= kernPagesStart && i <= kernPagesStart+pagesForKern )
f0100cfb:	81 fa ff 00 00 00    	cmp    $0xff,%edx
f0100d01:	76 12                	jbe    f0100d15 <page_init+0x74>
f0100d03:	39 da                	cmp    %ebx,%edx
f0100d05:	77 0e                	ja     f0100d15 <page_init+0x74>
		{
			pages[i].pp_ref = 1;
f0100d07:	a1 0c 9f 17 f0       	mov    0xf0179f0c,%eax
f0100d0c:	66 c7 44 08 04 01 00 	movw   $0x1,0x4(%eax,%ecx,1)
			continue;
f0100d13:	eb 18                	jmp    f0100d2d <page_init+0x8c>
		}
		
		
		pages[i].pp_ref = 0;
f0100d15:	89 c8                	mov    %ecx,%eax
f0100d17:	03 05 0c 9f 17 f0    	add    0xf0179f0c,%eax
f0100d1d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
		pages[i].pp_link = page_free_list;
f0100d23:	89 30                	mov    %esi,(%eax)
		page_free_list = &pages[i];
f0100d25:	89 ce                	mov    %ecx,%esi
f0100d27:	03 35 0c 9f 17 f0    	add    0xf0179f0c,%esi
	
	uint32_t pagesForKern = ((uint32_t)boot_alloc(0) - (KERNBASE + ONEMB)) / PGSIZE; 
	uint32_t pagesForIOHole = (uint32_t)(EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	uint32_t kernPagesStart = (uint32_t)(ONEMB) / PGSIZE;
	//cprintf("\nPages:%x",pages);
	for (i = 0; i < npages; i++)
f0100d2d:	83 c2 01             	add    $0x1,%edx
f0100d30:	83 c1 08             	add    $0x8,%ecx
f0100d33:	3b 15 04 9f 17 f0    	cmp    0xf0179f04,%edx
f0100d39:	72 96                	jb     f0100cd1 <page_init+0x30>
f0100d3b:	89 35 1c 92 17 f0    	mov    %esi,0xf017921c
		
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100d41:	5b                   	pop    %ebx
f0100d42:	5e                   	pop    %esi
f0100d43:	5d                   	pop    %ebp
f0100d44:	c3                   	ret    

f0100d45 <page_alloc>:
//
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo * page_alloc(int alloc_flags)
{
f0100d45:	55                   	push   %ebp
f0100d46:	89 e5                	mov    %esp,%ebp
f0100d48:	53                   	push   %ebx
f0100d49:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	struct PageInfo * left = page_free_list;
f0100d4c:	8b 1d 1c 92 17 f0    	mov    0xf017921c,%ebx
	struct PageInfo * alloc = NULL;
	
	//cprintf("\nLeft: %p",left);
	if(left != 0x0)
f0100d52:	85 db                	test   %ebx,%ebx
f0100d54:	74 5c                	je     f0100db2 <page_alloc+0x6d>
	{
		//cprintf("\nInside the if loop in alloc");
		page_free_list = left->pp_link;
f0100d56:	8b 03                	mov    (%ebx),%eax
f0100d58:	a3 1c 92 17 f0       	mov    %eax,0xf017921c
		left->pp_link = NULL;
f0100d5d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(alloc_flags & ALLOC_ZERO)
		{	
			memset(page2kva(left), 0, PGSIZE);
		}
		return left;	
f0100d63:	89 d8                	mov    %ebx,%eax
	if(left != 0x0)
	{
		//cprintf("\nInside the if loop in alloc");
		page_free_list = left->pp_link;
		left->pp_link = NULL;
		if(alloc_flags & ALLOC_ZERO)
f0100d65:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100d69:	74 4c                	je     f0100db7 <page_alloc+0x72>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d6b:	2b 05 0c 9f 17 f0    	sub    0xf0179f0c,%eax
f0100d71:	c1 f8 03             	sar    $0x3,%eax
f0100d74:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d77:	89 c2                	mov    %eax,%edx
f0100d79:	c1 ea 0c             	shr    $0xc,%edx
f0100d7c:	3b 15 04 9f 17 f0    	cmp    0xf0179f04,%edx
f0100d82:	72 12                	jb     f0100d96 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d84:	50                   	push   %eax
f0100d85:	68 08 48 10 f0       	push   $0xf0104808
f0100d8a:	6a 56                	push   $0x56
f0100d8c:	68 e5 4f 10 f0       	push   $0xf0104fe5
f0100d91:	e8 0a f3 ff ff       	call   f01000a0 <_panic>
		{	
			memset(page2kva(left), 0, PGSIZE);
f0100d96:	83 ec 04             	sub    $0x4,%esp
f0100d99:	68 00 10 00 00       	push   $0x1000
f0100d9e:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100da0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100da5:	50                   	push   %eax
f0100da6:	e8 15 30 00 00       	call   f0103dc0 <memset>
f0100dab:	83 c4 10             	add    $0x10,%esp
		}
		return left;	
f0100dae:	89 d8                	mov    %ebx,%eax
f0100db0:	eb 05                	jmp    f0100db7 <page_alloc+0x72>
	}
	else
	{
		//panic("Out of memory. ");
		//cprintf("\nalloc value: %p",alloc);
		return 0;
f0100db2:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//cprintf("\nalloc value: %p",alloc);
	//cprintf("\nValue of page_free: %p",page_free_list);
	
}
f0100db7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100dba:	c9                   	leave  
f0100dbb:	c3                   	ret    

f0100dbc <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100dbc:	55                   	push   %ebp
f0100dbd:	89 e5                	mov    %esp,%ebp
f0100dbf:	83 ec 08             	sub    $0x8,%esp
f0100dc2:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	//cprintf("\npp Value in page free:%p",pp);
	if(pp->pp_link != 0x0 || pp->pp_ref != 0)
f0100dc5:	83 38 00             	cmpl   $0x0,(%eax)
f0100dc8:	75 07                	jne    f0100dd1 <page_free+0x15>
f0100dca:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100dcf:	74 17                	je     f0100de8 <page_free+0x2c>
	{
		panic("\npp_ref or pp_link is non-zero");
f0100dd1:	83 ec 04             	sub    $0x4,%esp
f0100dd4:	68 f0 48 10 f0       	push   $0xf01048f0
f0100dd9:	68 82 01 00 00       	push   $0x182
f0100dde:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0100de3:	e8 b8 f2 ff ff       	call   f01000a0 <_panic>
	}
	else
	{
		pp->pp_link = page_free_list;
f0100de8:	8b 15 1c 92 17 f0    	mov    0xf017921c,%edx
f0100dee:	89 10                	mov    %edx,(%eax)
		page_free_list = pp;
f0100df0:	a3 1c 92 17 f0       	mov    %eax,0xf017921c
	}
}
f0100df5:	c9                   	leave  
f0100df6:	c3                   	ret    

f0100df7 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100df7:	55                   	push   %ebp
f0100df8:	89 e5                	mov    %esp,%ebp
f0100dfa:	83 ec 08             	sub    $0x8,%esp
f0100dfd:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100e00:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100e04:	83 e8 01             	sub    $0x1,%eax
f0100e07:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100e0b:	66 85 c0             	test   %ax,%ax
f0100e0e:	75 0c                	jne    f0100e1c <page_decref+0x25>
		page_free(pp);
f0100e10:	83 ec 0c             	sub    $0xc,%esp
f0100e13:	52                   	push   %edx
f0100e14:	e8 a3 ff ff ff       	call   f0100dbc <page_free>
f0100e19:	83 c4 10             	add    $0x10,%esp
}
f0100e1c:	c9                   	leave  
f0100e1d:	c3                   	ret    

f0100e1e <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100e1e:	55                   	push   %ebp
f0100e1f:	89 e5                	mov    %esp,%ebp
f0100e21:	56                   	push   %esi
f0100e22:	53                   	push   %ebx
f0100e23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pde_t * pde = &pgdir[PDX(va)];
f0100e26:	89 de                	mov    %ebx,%esi
f0100e28:	c1 ee 16             	shr    $0x16,%esi
f0100e2b:	c1 e6 02             	shl    $0x2,%esi
f0100e2e:	03 75 08             	add    0x8(%ebp),%esi
	pte_t * ptab;
	struct PageInfo * new_page;
	//cprintf("\nPDE Value:%x \nva value:%x\npgdir:%x\nvalue of Pde:%x",pde,va,pgdir,*pde);
	if(((*pde) & PTE_P)) //check if the page is present
f0100e31:	8b 16                	mov    (%esi),%edx
f0100e33:	f6 c2 01             	test   $0x1,%dl
f0100e36:	74 30                	je     f0100e68 <pgdir_walk+0x4a>
	{
		//cprintf("\nIn if");
		ptab = (pte_t *)KADDR(PTE_ADDR(*pde));  //get the virtual address of the page table start as we have to dereference it later.
f0100e38:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e3e:	89 d0                	mov    %edx,%eax
f0100e40:	c1 e8 0c             	shr    $0xc,%eax
f0100e43:	3b 05 04 9f 17 f0    	cmp    0xf0179f04,%eax
f0100e49:	72 15                	jb     f0100e60 <pgdir_walk+0x42>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e4b:	52                   	push   %edx
f0100e4c:	68 08 48 10 f0       	push   $0xf0104808
f0100e51:	68 b7 01 00 00       	push   $0x1b7
f0100e56:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0100e5b:	e8 40 f2 ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f0100e60:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100e66:	eb 5f                	jmp    f0100ec7 <pgdir_walk+0xa9>
	}
	else
	{
		
		if(create)  //If page is not present and the caller wants to allocate a new page then
f0100e68:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100e6c:	74 67                	je     f0100ed5 <pgdir_walk+0xb7>
		{
			//cprintf("\nIn create");
			new_page = page_alloc(1);
f0100e6e:	83 ec 0c             	sub    $0xc,%esp
f0100e71:	6a 01                	push   $0x1
f0100e73:	e8 cd fe ff ff       	call   f0100d45 <page_alloc>
			if(new_page == NULL)   //No free pages available
f0100e78:	83 c4 10             	add    $0x10,%esp
f0100e7b:	85 c0                	test   %eax,%eax
f0100e7d:	74 5d                	je     f0100edc <pgdir_walk+0xbe>
				return NULL;
			else  //Page is available
			{
				new_page->pp_ref++;   //Increase the reference counter of the page.
f0100e7f:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e84:	2b 05 0c 9f 17 f0    	sub    0xf0179f0c,%eax
f0100e8a:	89 c2                	mov    %eax,%edx
f0100e8c:	c1 fa 03             	sar    $0x3,%edx
f0100e8f:	c1 e2 0c             	shl    $0xc,%edx
				//cprintf("\nNew_page physical value:%p\nnew page val:%p\npages:%p",page2pa(new_page),new_page,pages);
				*pde = page2pa(new_page) | PTE_P | PTE_W | PTE_U;   //Setup the permission bits. 
f0100e92:	89 d0                	mov    %edx,%eax
f0100e94:	83 c8 07             	or     $0x7,%eax
f0100e97:	89 06                	mov    %eax,(%esi)
				//cprintf("\n*pde:%p\nmanual page to pa:%x\ndifference:%u",
				//*pde,((new_page - pages)<<PGSHIFT),(new_page - pages));
				ptab = (pte_t *)KADDR(PTE_ADDR(*pde));
f0100e99:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e9f:	89 d0                	mov    %edx,%eax
f0100ea1:	c1 e8 0c             	shr    $0xc,%eax
f0100ea4:	3b 05 04 9f 17 f0    	cmp    0xf0179f04,%eax
f0100eaa:	72 15                	jb     f0100ec1 <pgdir_walk+0xa3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100eac:	52                   	push   %edx
f0100ead:	68 08 48 10 f0       	push   $0xf0104808
f0100eb2:	68 c9 01 00 00       	push   $0x1c9
f0100eb7:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0100ebc:	e8 df f1 ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f0100ec1:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
			//cprintf("\nReturrning NULL");
			return NULL;	
		}
	}
	//cprintf("\nPTE Value at end:%p",&ptab[PTX(va)]);
	return &ptab[PTX(va)];
f0100ec7:	c1 eb 0a             	shr    $0xa,%ebx
f0100eca:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100ed0:	8d 04 1a             	lea    (%edx,%ebx,1),%eax
f0100ed3:	eb 0c                	jmp    f0100ee1 <pgdir_walk+0xc3>
			}
		}
		else
		{
			//cprintf("\nReturrning NULL");
			return NULL;	
f0100ed5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100eda:	eb 05                	jmp    f0100ee1 <pgdir_walk+0xc3>
		if(create)  //If page is not present and the caller wants to allocate a new page then
		{
			//cprintf("\nIn create");
			new_page = page_alloc(1);
			if(new_page == NULL)   //No free pages available
				return NULL;
f0100edc:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;	
		}
	}
	//cprintf("\nPTE Value at end:%p",&ptab[PTX(va)]);
	return &ptab[PTX(va)];
}
f0100ee1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ee4:	5b                   	pop    %ebx
f0100ee5:	5e                   	pop    %esi
f0100ee6:	5d                   	pop    %ebp
f0100ee7:	c3                   	ret    

f0100ee8 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100ee8:	55                   	push   %ebp
f0100ee9:	89 e5                	mov    %esp,%ebp
f0100eeb:	57                   	push   %edi
f0100eec:	56                   	push   %esi
f0100eed:	53                   	push   %ebx
f0100eee:	83 ec 1c             	sub    $0x1c,%esp
f0100ef1:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// Fill this function in
	//cprintf("\nVA:%x, PA:%x, size:%x",va,pa,size);
	uintptr_t tmpVa = va+size; 
	//cprintf("\ntmpVA:%x",tmpVa);
	if(tmpVa < va)
f0100ef4:	01 d1                	add    %edx,%ecx
f0100ef6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100ef9:	73 58                	jae    f0100f53 <boot_map_region+0x6b>
		panic("\ntmpVa is greater than 32 bits");
f0100efb:	83 ec 04             	sub    $0x4,%esp
f0100efe:	68 10 49 10 f0       	push   $0xf0104910
f0100f03:	68 ea 01 00 00       	push   $0x1ea
f0100f08:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0100f0d:	e8 8e f1 ff ff       	call   f01000a0 <_panic>
	//cprintf("\nVA:%x, PA:%x, tmpVa:%x",va,pa,tmpVa);
	
	for(;va<tmpVa;)
	{
		
		pte_t * pte = pgdir_walk(pgdir, (void *)va, true);
f0100f12:	83 ec 04             	sub    $0x4,%esp
f0100f15:	6a 01                	push   $0x1
f0100f17:	53                   	push   %ebx
f0100f18:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f1b:	e8 fe fe ff ff       	call   f0100e1e <pgdir_walk>
		if(pte == NULL)
f0100f20:	83 c4 10             	add    $0x10,%esp
f0100f23:	85 c0                	test   %eax,%eax
f0100f25:	75 17                	jne    f0100f3e <boot_map_region+0x56>
			panic("Out of Free Memory");
f0100f27:	83 ec 04             	sub    $0x4,%esp
f0100f2a:	68 8f 50 10 f0       	push   $0xf010508f
f0100f2f:	68 f2 01 00 00       	push   $0x1f2
f0100f34:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0100f39:	e8 62 f1 ff ff       	call   f01000a0 <_panic>
		else
		{
			*pte = pa | perm | PTE_P;
f0100f3e:	0b 75 dc             	or     -0x24(%ebp),%esi
f0100f41:	89 30                	mov    %esi,(%eax)
			//cprintf("\nValue of PTE in boot MAP:%x  diff of tmpVA:%p,  ",*pte, tmpVa-va);
			
			if(va >= 0xFFFFF000)
f0100f43:	81 fb ff ef ff ff    	cmp    $0xffffefff,%ebx
f0100f49:	77 20                	ja     f0100f6b <boot_map_region+0x83>
			{			
				//cprintf("\nI am Here\nva:%x\npa:%x",va,pa);
				break;
			}
			va += PGSIZE;
f0100f4b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100f51:	eb 10                	jmp    f0100f63 <boot_map_region+0x7b>
f0100f53:	89 d3                	mov    %edx,%ebx
f0100f55:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100f58:	29 d7                	sub    %edx,%edi
f0100f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f5d:	83 c8 01             	or     $0x1,%eax
f0100f60:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100f63:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
	//cprintf("\ntmpVA:%x",tmpVa);
	if(tmpVa < va)
		panic("\ntmpVa is greater than 32 bits");
	//cprintf("\nVA:%x, PA:%x, tmpVa:%x",va,pa,tmpVa);
	
	for(;va<tmpVa;)
f0100f66:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0100f69:	72 a7                	jb     f0100f12 <boot_map_region+0x2a>
			va += PGSIZE;
			pa += PGSIZE;
		}
	}	
	//cprintf("\nVA after:%x, PA after:%x",va,pa,size);
}
f0100f6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f6e:	5b                   	pop    %ebx
f0100f6f:	5e                   	pop    %esi
f0100f70:	5f                   	pop    %edi
f0100f71:	5d                   	pop    %ebp
f0100f72:	c3                   	ret    

f0100f73 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f73:	55                   	push   %ebp
f0100f74:	89 e5                	mov    %esp,%ebp
f0100f76:	53                   	push   %ebx
f0100f77:	83 ec 08             	sub    $0x8,%esp
f0100f7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t * pte = pgdir_walk(pgdir, va, false);
f0100f7d:	6a 00                	push   $0x0
f0100f7f:	ff 75 0c             	pushl  0xc(%ebp)
f0100f82:	ff 75 08             	pushl  0x8(%ebp)
f0100f85:	e8 94 fe ff ff       	call   f0100e1e <pgdir_walk>
	//cprintf("\nIn lookup pte value: %x",pte);
	if(pte == 0x0)
f0100f8a:	83 c4 10             	add    $0x10,%esp
f0100f8d:	85 c0                	test   %eax,%eax
f0100f8f:	74 37                	je     f0100fc8 <page_lookup+0x55>
	{
		return NULL;
	}
	else
	{
		if(*pte_store != NULL)
f0100f91:	83 3b 00             	cmpl   $0x0,(%ebx)
f0100f94:	74 02                	je     f0100f98 <page_lookup+0x25>
			*pte_store = pte;
f0100f96:	89 03                	mov    %eax,(%ebx)
		if(PTE_P & * pte)
f0100f98:	8b 00                	mov    (%eax),%eax
f0100f9a:	a8 01                	test   $0x1,%al
f0100f9c:	74 31                	je     f0100fcf <page_lookup+0x5c>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f9e:	c1 e8 0c             	shr    $0xc,%eax
f0100fa1:	3b 05 04 9f 17 f0    	cmp    0xf0179f04,%eax
f0100fa7:	72 14                	jb     f0100fbd <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0100fa9:	83 ec 04             	sub    $0x4,%esp
f0100fac:	68 30 49 10 f0       	push   $0xf0104930
f0100fb1:	6a 4f                	push   $0x4f
f0100fb3:	68 e5 4f 10 f0       	push   $0xf0104fe5
f0100fb8:	e8 e3 f0 ff ff       	call   f01000a0 <_panic>
	return &pages[PGNUM(pa)];
f0100fbd:	8b 15 0c 9f 17 f0    	mov    0xf0179f0c,%edx
f0100fc3:	8d 04 c2             	lea    (%edx,%eax,8),%eax
		{
			//cprintf("\nvalue at PTE :%x",*pte);
			return pa2page(*pte);
f0100fc6:	eb 0c                	jmp    f0100fd4 <page_lookup+0x61>
	// Fill this function in
	pte_t * pte = pgdir_walk(pgdir, va, false);
	//cprintf("\nIn lookup pte value: %x",pte);
	if(pte == 0x0)
	{
		return NULL;
f0100fc8:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fcd:	eb 05                	jmp    f0100fd4 <page_lookup+0x61>
		{
			//cprintf("\nvalue at PTE :%x",*pte);
			return pa2page(*pte);
		}
	}
	return NULL;
f0100fcf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100fd4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100fd7:	c9                   	leave  
f0100fd8:	c3                   	ret    

f0100fd9 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100fd9:	55                   	push   %ebp
f0100fda:	89 e5                	mov    %esp,%ebp
f0100fdc:	53                   	push   %ebx
f0100fdd:	83 ec 18             	sub    $0x18,%esp
f0100fe0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t * pte = (pte_t *)0x1;// = pgdir_walk(pgdir, va, false); //Make sure that *pte is not NULL. Used in page_lookup.
f0100fe3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	struct PageInfo * ret = page_lookup(pgdir, va, &pte);
f0100fea:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100fed:	50                   	push   %eax
f0100fee:	53                   	push   %ebx
f0100fef:	ff 75 08             	pushl  0x8(%ebp)
f0100ff2:	e8 7c ff ff ff       	call   f0100f73 <page_lookup>
	if(ret == NULL)
f0100ff7:	83 c4 10             	add    $0x10,%esp
f0100ffa:	85 c0                	test   %eax,%eax
f0100ffc:	74 18                	je     f0101016 <page_remove+0x3d>
		return;
	else
	{
		page_decref(ret);
f0100ffe:	83 ec 0c             	sub    $0xc,%esp
f0101001:	50                   	push   %eax
f0101002:	e8 f0 fd ff ff       	call   f0100df7 <page_decref>
		*pte = 0x0;
f0101007:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010100a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101010:	0f 01 3b             	invlpg (%ebx)
f0101013:	83 c4 10             	add    $0x10,%esp
		tlb_invalidate(pgdir, va);
	}
	//cprintf("\nret value in ");
	
}
f0101016:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101019:	c9                   	leave  
f010101a:	c3                   	ret    

f010101b <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010101b:	55                   	push   %ebp
f010101c:	89 e5                	mov    %esp,%ebp
f010101e:	57                   	push   %edi
f010101f:	56                   	push   %esi
f0101020:	53                   	push   %ebx
f0101021:	83 ec 10             	sub    $0x10,%esp
f0101024:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101027:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	
	pte_t * pte = pgdir_walk(pgdir,va, true);
f010102a:	6a 01                	push   $0x1
f010102c:	57                   	push   %edi
f010102d:	ff 75 08             	pushl  0x8(%ebp)
f0101030:	e8 e9 fd ff ff       	call   f0100e1e <pgdir_walk>
f0101035:	89 c3                	mov    %eax,%ebx
	
	if(pte)
f0101037:	83 c4 10             	add    $0x10,%esp
f010103a:	85 c0                	test   %eax,%eax
f010103c:	74 38                	je     f0101076 <page_insert+0x5b>
	{		
		pp->pp_ref++; 
f010103e:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
		if(*pte & PTE_P)
f0101043:	f6 00 01             	testb  $0x1,(%eax)
f0101046:	74 0f                	je     f0101057 <page_insert+0x3c>
		{
			page_remove(pgdir, va);
f0101048:	83 ec 08             	sub    $0x8,%esp
f010104b:	57                   	push   %edi
f010104c:	ff 75 08             	pushl  0x8(%ebp)
f010104f:	e8 85 ff ff ff       	call   f0100fd9 <page_remove>
f0101054:	83 c4 10             	add    $0x10,%esp
f0101057:	8b 55 14             	mov    0x14(%ebp),%edx
f010105a:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010105d:	89 f0                	mov    %esi,%eax
f010105f:	2b 05 0c 9f 17 f0    	sub    0xf0179f0c,%eax
f0101065:	c1 f8 03             	sar    $0x3,%eax
		}
		*pte = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
f0101068:	c1 e0 0c             	shl    $0xc,%eax
f010106b:	09 d0                	or     %edx,%eax
f010106d:	89 03                	mov    %eax,(%ebx)
	}
	else
		return -E_NO_MEM;
	
	return 0;
f010106f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101074:	eb 05                	jmp    f010107b <page_insert+0x60>
			page_remove(pgdir, va);
		}
		*pte = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
	}
	else
		return -E_NO_MEM;
f0101076:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	
	return 0;
}
f010107b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010107e:	5b                   	pop    %ebx
f010107f:	5e                   	pop    %esi
f0101080:	5f                   	pop    %edi
f0101081:	5d                   	pop    %ebp
f0101082:	c3                   	ret    

f0101083 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101083:	55                   	push   %ebp
f0101084:	89 e5                	mov    %esp,%ebp
f0101086:	57                   	push   %edi
f0101087:	56                   	push   %esi
f0101088:	53                   	push   %ebx
f0101089:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010108c:	6a 15                	push   $0x15
f010108e:	e8 f5 1d 00 00       	call   f0102e88 <mc146818_read>
f0101093:	89 c3                	mov    %eax,%ebx
f0101095:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f010109c:	e8 e7 1d 00 00       	call   f0102e88 <mc146818_read>
f01010a1:	c1 e0 08             	shl    $0x8,%eax
f01010a4:	09 d8                	or     %ebx,%eax
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01010a6:	c1 e0 0a             	shl    $0xa,%eax
f01010a9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01010af:	85 c0                	test   %eax,%eax
f01010b1:	0f 48 c2             	cmovs  %edx,%eax
f01010b4:	c1 f8 0c             	sar    $0xc,%eax
f01010b7:	a3 20 92 17 f0       	mov    %eax,0xf0179220
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01010bc:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01010c3:	e8 c0 1d 00 00       	call   f0102e88 <mc146818_read>
f01010c8:	89 c3                	mov    %eax,%ebx
f01010ca:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01010d1:	e8 b2 1d 00 00       	call   f0102e88 <mc146818_read>
f01010d6:	c1 e0 08             	shl    $0x8,%eax
f01010d9:	09 d8                	or     %ebx,%eax
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01010db:	c1 e0 0a             	shl    $0xa,%eax
f01010de:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01010e4:	83 c4 10             	add    $0x10,%esp
f01010e7:	85 c0                	test   %eax,%eax
f01010e9:	0f 48 c2             	cmovs  %edx,%eax
f01010ec:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01010ef:	85 c0                	test   %eax,%eax
f01010f1:	74 0e                	je     f0101101 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01010f3:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01010f9:	89 15 04 9f 17 f0    	mov    %edx,0xf0179f04
f01010ff:	eb 0c                	jmp    f010110d <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101101:	8b 15 20 92 17 f0    	mov    0xf0179220,%edx
f0101107:	89 15 04 9f 17 f0    	mov    %edx,0xf0179f04

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK npages:%u\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024),
f010110d:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK npages:%u\n",
f0101110:	c1 e8 0a             	shr    $0xa,%eax
f0101113:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101114:	a1 20 92 17 f0       	mov    0xf0179220,%eax
f0101119:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK npages:%u\n",
f010111c:	c1 e8 0a             	shr    $0xa,%eax
f010111f:	50                   	push   %eax
		npages * PGSIZE / 1024,
f0101120:	a1 04 9f 17 f0       	mov    0xf0179f04,%eax
f0101125:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK npages:%u\n",
f0101128:	c1 e8 0a             	shr    $0xa,%eax
f010112b:	50                   	push   %eax
f010112c:	68 50 49 10 f0       	push   $0xf0104950
f0101131:	e8 b3 1d 00 00       	call   f0102ee9 <cprintf>
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	//cprintf("\nnext_ptr 1:%x",boot_alloc(0));
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101136:	b8 00 10 00 00       	mov    $0x1000,%eax
f010113b:	e8 a2 f7 ff ff       	call   f01008e2 <boot_alloc>
f0101140:	a3 08 9f 17 f0       	mov    %eax,0xf0179f08
	memset(kern_pgdir, 0, PGSIZE);
f0101145:	83 c4 0c             	add    $0xc,%esp
f0101148:	68 00 10 00 00       	push   $0x1000
f010114d:	6a 00                	push   $0x0
f010114f:	50                   	push   %eax
f0101150:	e8 6b 2c 00 00       	call   f0103dc0 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101155:	a1 08 9f 17 f0       	mov    0xf0179f08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010115a:	83 c4 10             	add    $0x10,%esp
f010115d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101162:	77 15                	ja     f0101179 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101164:	50                   	push   %eax
f0101165:	68 98 49 10 f0       	push   $0xf0104998
f010116a:	68 a1 00 00 00       	push   $0xa1
f010116f:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101174:	e8 27 ef ff ff       	call   f01000a0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101179:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010117f:	83 ca 05             	or     $0x5,%edx
f0101182:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	//cprintf("kern_pgdir[PDX(UCPT)]:%p, PDX[UVPT]:%u",kern_pgdir[PDX(UVPT)], ((((uintptr_t) (UVPT)) >> 22) & 0x3FF));
	pages = (struct PageInfo *) boot_alloc(npages*sizeof(struct PageInfo));
f0101188:	a1 04 9f 17 f0       	mov    0xf0179f04,%eax
f010118d:	c1 e0 03             	shl    $0x3,%eax
f0101190:	e8 4d f7 ff ff       	call   f01008e2 <boot_alloc>
f0101195:	a3 0c 9f 17 f0       	mov    %eax,0xf0179f0c
	memset(pages, 0, npages*sizeof(struct PageInfo));
f010119a:	83 ec 04             	sub    $0x4,%esp
f010119d:	8b 3d 04 9f 17 f0    	mov    0xf0179f04,%edi
f01011a3:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f01011aa:	52                   	push   %edx
f01011ab:	6a 00                	push   $0x0
f01011ad:	50                   	push   %eax
f01011ae:	e8 0d 2c 00 00       	call   f0103dc0 <memset>
	//cprintf("\nnext_ptr:%x",boot_alloc(0));
	//cprintf("size of pageInfo: %d",sizeof(struct PageInfo));
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env * )boot_alloc(NENV*sizeof(struct Env));
f01011b3:	b8 00 80 01 00       	mov    $0x18000,%eax
f01011b8:	e8 25 f7 ff ff       	call   f01008e2 <boot_alloc>
f01011bd:	a3 28 92 17 f0       	mov    %eax,0xf0179228
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01011c2:	e8 da fa ff ff       	call   f0100ca1 <page_init>

	check_page_free_list(1);
f01011c7:	b8 01 00 00 00       	mov    $0x1,%eax
f01011cc:	e8 14 f8 ff ff       	call   f01009e5 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01011d1:	83 c4 10             	add    $0x10,%esp
f01011d4:	83 3d 0c 9f 17 f0 00 	cmpl   $0x0,0xf0179f0c
f01011db:	75 17                	jne    f01011f4 <mem_init+0x171>
		panic("'pages' is a null pointer!");
f01011dd:	83 ec 04             	sub    $0x4,%esp
f01011e0:	68 a2 50 10 f0       	push   $0xf01050a2
f01011e5:	68 fd 02 00 00       	push   $0x2fd
f01011ea:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01011ef:	e8 ac ee ff ff       	call   f01000a0 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01011f4:	a1 1c 92 17 f0       	mov    0xf017921c,%eax
f01011f9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01011fe:	eb 05                	jmp    f0101205 <mem_init+0x182>
		++nfree;
f0101200:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101203:	8b 00                	mov    (%eax),%eax
f0101205:	85 c0                	test   %eax,%eax
f0101207:	75 f7                	jne    f0101200 <mem_init+0x17d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101209:	83 ec 0c             	sub    $0xc,%esp
f010120c:	6a 00                	push   $0x0
f010120e:	e8 32 fb ff ff       	call   f0100d45 <page_alloc>
f0101213:	89 c7                	mov    %eax,%edi
f0101215:	83 c4 10             	add    $0x10,%esp
f0101218:	85 c0                	test   %eax,%eax
f010121a:	75 19                	jne    f0101235 <mem_init+0x1b2>
f010121c:	68 bd 50 10 f0       	push   $0xf01050bd
f0101221:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101226:	68 05 03 00 00       	push   $0x305
f010122b:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101230:	e8 6b ee ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0101235:	83 ec 0c             	sub    $0xc,%esp
f0101238:	6a 00                	push   $0x0
f010123a:	e8 06 fb ff ff       	call   f0100d45 <page_alloc>
f010123f:	89 c6                	mov    %eax,%esi
f0101241:	83 c4 10             	add    $0x10,%esp
f0101244:	85 c0                	test   %eax,%eax
f0101246:	75 19                	jne    f0101261 <mem_init+0x1de>
f0101248:	68 d3 50 10 f0       	push   $0xf01050d3
f010124d:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101252:	68 06 03 00 00       	push   $0x306
f0101257:	68 d9 4f 10 f0       	push   $0xf0104fd9
f010125c:	e8 3f ee ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f0101261:	83 ec 0c             	sub    $0xc,%esp
f0101264:	6a 00                	push   $0x0
f0101266:	e8 da fa ff ff       	call   f0100d45 <page_alloc>
f010126b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010126e:	83 c4 10             	add    $0x10,%esp
f0101271:	85 c0                	test   %eax,%eax
f0101273:	75 19                	jne    f010128e <mem_init+0x20b>
f0101275:	68 e9 50 10 f0       	push   $0xf01050e9
f010127a:	68 ff 4f 10 f0       	push   $0xf0104fff
f010127f:	68 07 03 00 00       	push   $0x307
f0101284:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101289:	e8 12 ee ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010128e:	39 f7                	cmp    %esi,%edi
f0101290:	75 19                	jne    f01012ab <mem_init+0x228>
f0101292:	68 ff 50 10 f0       	push   $0xf01050ff
f0101297:	68 ff 4f 10 f0       	push   $0xf0104fff
f010129c:	68 0a 03 00 00       	push   $0x30a
f01012a1:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01012a6:	e8 f5 ed ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01012ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012ae:	39 c7                	cmp    %eax,%edi
f01012b0:	74 04                	je     f01012b6 <mem_init+0x233>
f01012b2:	39 c6                	cmp    %eax,%esi
f01012b4:	75 19                	jne    f01012cf <mem_init+0x24c>
f01012b6:	68 bc 49 10 f0       	push   $0xf01049bc
f01012bb:	68 ff 4f 10 f0       	push   $0xf0104fff
f01012c0:	68 0b 03 00 00       	push   $0x30b
f01012c5:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01012ca:	e8 d1 ed ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012cf:	8b 0d 0c 9f 17 f0    	mov    0xf0179f0c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01012d5:	8b 15 04 9f 17 f0    	mov    0xf0179f04,%edx
f01012db:	c1 e2 0c             	shl    $0xc,%edx
f01012de:	89 f8                	mov    %edi,%eax
f01012e0:	29 c8                	sub    %ecx,%eax
f01012e2:	c1 f8 03             	sar    $0x3,%eax
f01012e5:	c1 e0 0c             	shl    $0xc,%eax
f01012e8:	39 d0                	cmp    %edx,%eax
f01012ea:	72 19                	jb     f0101305 <mem_init+0x282>
f01012ec:	68 11 51 10 f0       	push   $0xf0105111
f01012f1:	68 ff 4f 10 f0       	push   $0xf0104fff
f01012f6:	68 0c 03 00 00       	push   $0x30c
f01012fb:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101300:	e8 9b ed ff ff       	call   f01000a0 <_panic>
f0101305:	89 f0                	mov    %esi,%eax
f0101307:	29 c8                	sub    %ecx,%eax
f0101309:	c1 f8 03             	sar    $0x3,%eax
f010130c:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f010130f:	39 c2                	cmp    %eax,%edx
f0101311:	77 19                	ja     f010132c <mem_init+0x2a9>
f0101313:	68 2e 51 10 f0       	push   $0xf010512e
f0101318:	68 ff 4f 10 f0       	push   $0xf0104fff
f010131d:	68 0d 03 00 00       	push   $0x30d
f0101322:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101327:	e8 74 ed ff ff       	call   f01000a0 <_panic>
f010132c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010132f:	29 c8                	sub    %ecx,%eax
f0101331:	c1 f8 03             	sar    $0x3,%eax
f0101334:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101337:	39 c2                	cmp    %eax,%edx
f0101339:	77 19                	ja     f0101354 <mem_init+0x2d1>
f010133b:	68 4b 51 10 f0       	push   $0xf010514b
f0101340:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101345:	68 0e 03 00 00       	push   $0x30e
f010134a:	68 d9 4f 10 f0       	push   $0xf0104fd9
f010134f:	e8 4c ed ff ff       	call   f01000a0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101354:	a1 1c 92 17 f0       	mov    0xf017921c,%eax
f0101359:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010135c:	c7 05 1c 92 17 f0 00 	movl   $0x0,0xf017921c
f0101363:	00 00 00 
	//cprintf("\nI am Here..!!");
	// should be no free memory
	assert(!page_alloc(0));
f0101366:	83 ec 0c             	sub    $0xc,%esp
f0101369:	6a 00                	push   $0x0
f010136b:	e8 d5 f9 ff ff       	call   f0100d45 <page_alloc>
f0101370:	83 c4 10             	add    $0x10,%esp
f0101373:	85 c0                	test   %eax,%eax
f0101375:	74 19                	je     f0101390 <mem_init+0x30d>
f0101377:	68 68 51 10 f0       	push   $0xf0105168
f010137c:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101381:	68 15 03 00 00       	push   $0x315
f0101386:	68 d9 4f 10 f0       	push   $0xf0104fd9
f010138b:	e8 10 ed ff ff       	call   f01000a0 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101390:	83 ec 0c             	sub    $0xc,%esp
f0101393:	57                   	push   %edi
f0101394:	e8 23 fa ff ff       	call   f0100dbc <page_free>
	page_free(pp1);
f0101399:	89 34 24             	mov    %esi,(%esp)
f010139c:	e8 1b fa ff ff       	call   f0100dbc <page_free>
	page_free(pp2);
f01013a1:	83 c4 04             	add    $0x4,%esp
f01013a4:	ff 75 d4             	pushl  -0x2c(%ebp)
f01013a7:	e8 10 fa ff ff       	call   f0100dbc <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01013ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01013b3:	e8 8d f9 ff ff       	call   f0100d45 <page_alloc>
f01013b8:	89 c6                	mov    %eax,%esi
f01013ba:	83 c4 10             	add    $0x10,%esp
f01013bd:	85 c0                	test   %eax,%eax
f01013bf:	75 19                	jne    f01013da <mem_init+0x357>
f01013c1:	68 bd 50 10 f0       	push   $0xf01050bd
f01013c6:	68 ff 4f 10 f0       	push   $0xf0104fff
f01013cb:	68 1c 03 00 00       	push   $0x31c
f01013d0:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01013d5:	e8 c6 ec ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01013da:	83 ec 0c             	sub    $0xc,%esp
f01013dd:	6a 00                	push   $0x0
f01013df:	e8 61 f9 ff ff       	call   f0100d45 <page_alloc>
f01013e4:	89 c7                	mov    %eax,%edi
f01013e6:	83 c4 10             	add    $0x10,%esp
f01013e9:	85 c0                	test   %eax,%eax
f01013eb:	75 19                	jne    f0101406 <mem_init+0x383>
f01013ed:	68 d3 50 10 f0       	push   $0xf01050d3
f01013f2:	68 ff 4f 10 f0       	push   $0xf0104fff
f01013f7:	68 1d 03 00 00       	push   $0x31d
f01013fc:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101401:	e8 9a ec ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f0101406:	83 ec 0c             	sub    $0xc,%esp
f0101409:	6a 00                	push   $0x0
f010140b:	e8 35 f9 ff ff       	call   f0100d45 <page_alloc>
f0101410:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101413:	83 c4 10             	add    $0x10,%esp
f0101416:	85 c0                	test   %eax,%eax
f0101418:	75 19                	jne    f0101433 <mem_init+0x3b0>
f010141a:	68 e9 50 10 f0       	push   $0xf01050e9
f010141f:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101424:	68 1e 03 00 00       	push   $0x31e
f0101429:	68 d9 4f 10 f0       	push   $0xf0104fd9
f010142e:	e8 6d ec ff ff       	call   f01000a0 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101433:	39 fe                	cmp    %edi,%esi
f0101435:	75 19                	jne    f0101450 <mem_init+0x3cd>
f0101437:	68 ff 50 10 f0       	push   $0xf01050ff
f010143c:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101441:	68 20 03 00 00       	push   $0x320
f0101446:	68 d9 4f 10 f0       	push   $0xf0104fd9
f010144b:	e8 50 ec ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101450:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101453:	39 c6                	cmp    %eax,%esi
f0101455:	74 04                	je     f010145b <mem_init+0x3d8>
f0101457:	39 c7                	cmp    %eax,%edi
f0101459:	75 19                	jne    f0101474 <mem_init+0x3f1>
f010145b:	68 bc 49 10 f0       	push   $0xf01049bc
f0101460:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101465:	68 21 03 00 00       	push   $0x321
f010146a:	68 d9 4f 10 f0       	push   $0xf0104fd9
f010146f:	e8 2c ec ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f0101474:	83 ec 0c             	sub    $0xc,%esp
f0101477:	6a 00                	push   $0x0
f0101479:	e8 c7 f8 ff ff       	call   f0100d45 <page_alloc>
f010147e:	83 c4 10             	add    $0x10,%esp
f0101481:	85 c0                	test   %eax,%eax
f0101483:	74 19                	je     f010149e <mem_init+0x41b>
f0101485:	68 68 51 10 f0       	push   $0xf0105168
f010148a:	68 ff 4f 10 f0       	push   $0xf0104fff
f010148f:	68 22 03 00 00       	push   $0x322
f0101494:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101499:	e8 02 ec ff ff       	call   f01000a0 <_panic>
f010149e:	89 f0                	mov    %esi,%eax
f01014a0:	2b 05 0c 9f 17 f0    	sub    0xf0179f0c,%eax
f01014a6:	c1 f8 03             	sar    $0x3,%eax
f01014a9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014ac:	89 c2                	mov    %eax,%edx
f01014ae:	c1 ea 0c             	shr    $0xc,%edx
f01014b1:	3b 15 04 9f 17 f0    	cmp    0xf0179f04,%edx
f01014b7:	72 12                	jb     f01014cb <mem_init+0x448>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014b9:	50                   	push   %eax
f01014ba:	68 08 48 10 f0       	push   $0xf0104808
f01014bf:	6a 56                	push   $0x56
f01014c1:	68 e5 4f 10 f0       	push   $0xf0104fe5
f01014c6:	e8 d5 eb ff ff       	call   f01000a0 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01014cb:	83 ec 04             	sub    $0x4,%esp
f01014ce:	68 00 10 00 00       	push   $0x1000
f01014d3:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01014d5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01014da:	50                   	push   %eax
f01014db:	e8 e0 28 00 00       	call   f0103dc0 <memset>
	page_free(pp0);
f01014e0:	89 34 24             	mov    %esi,(%esp)
f01014e3:	e8 d4 f8 ff ff       	call   f0100dbc <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01014e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01014ef:	e8 51 f8 ff ff       	call   f0100d45 <page_alloc>
f01014f4:	83 c4 10             	add    $0x10,%esp
f01014f7:	85 c0                	test   %eax,%eax
f01014f9:	75 19                	jne    f0101514 <mem_init+0x491>
f01014fb:	68 77 51 10 f0       	push   $0xf0105177
f0101500:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101505:	68 27 03 00 00       	push   $0x327
f010150a:	68 d9 4f 10 f0       	push   $0xf0104fd9
f010150f:	e8 8c eb ff ff       	call   f01000a0 <_panic>
	assert(pp && pp0 == pp);
f0101514:	39 c6                	cmp    %eax,%esi
f0101516:	74 19                	je     f0101531 <mem_init+0x4ae>
f0101518:	68 95 51 10 f0       	push   $0xf0105195
f010151d:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101522:	68 28 03 00 00       	push   $0x328
f0101527:	68 d9 4f 10 f0       	push   $0xf0104fd9
f010152c:	e8 6f eb ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101531:	89 f0                	mov    %esi,%eax
f0101533:	2b 05 0c 9f 17 f0    	sub    0xf0179f0c,%eax
f0101539:	c1 f8 03             	sar    $0x3,%eax
f010153c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010153f:	89 c2                	mov    %eax,%edx
f0101541:	c1 ea 0c             	shr    $0xc,%edx
f0101544:	3b 15 04 9f 17 f0    	cmp    0xf0179f04,%edx
f010154a:	72 12                	jb     f010155e <mem_init+0x4db>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010154c:	50                   	push   %eax
f010154d:	68 08 48 10 f0       	push   $0xf0104808
f0101552:	6a 56                	push   $0x56
f0101554:	68 e5 4f 10 f0       	push   $0xf0104fe5
f0101559:	e8 42 eb ff ff       	call   f01000a0 <_panic>
f010155e:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101564:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010156a:	80 38 00             	cmpb   $0x0,(%eax)
f010156d:	74 19                	je     f0101588 <mem_init+0x505>
f010156f:	68 a5 51 10 f0       	push   $0xf01051a5
f0101574:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101579:	68 2b 03 00 00       	push   $0x32b
f010157e:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101583:	e8 18 eb ff ff       	call   f01000a0 <_panic>
f0101588:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010158b:	39 d0                	cmp    %edx,%eax
f010158d:	75 db                	jne    f010156a <mem_init+0x4e7>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010158f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101592:	a3 1c 92 17 f0       	mov    %eax,0xf017921c

	// free the pages we took
	page_free(pp0);
f0101597:	83 ec 0c             	sub    $0xc,%esp
f010159a:	56                   	push   %esi
f010159b:	e8 1c f8 ff ff       	call   f0100dbc <page_free>
	page_free(pp1);
f01015a0:	89 3c 24             	mov    %edi,(%esp)
f01015a3:	e8 14 f8 ff ff       	call   f0100dbc <page_free>
	page_free(pp2);
f01015a8:	83 c4 04             	add    $0x4,%esp
f01015ab:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015ae:	e8 09 f8 ff ff       	call   f0100dbc <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015b3:	a1 1c 92 17 f0       	mov    0xf017921c,%eax
f01015b8:	83 c4 10             	add    $0x10,%esp
f01015bb:	eb 05                	jmp    f01015c2 <mem_init+0x53f>
		--nfree;
f01015bd:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015c0:	8b 00                	mov    (%eax),%eax
f01015c2:	85 c0                	test   %eax,%eax
f01015c4:	75 f7                	jne    f01015bd <mem_init+0x53a>
		--nfree;
	assert(nfree == 0);
f01015c6:	85 db                	test   %ebx,%ebx
f01015c8:	74 19                	je     f01015e3 <mem_init+0x560>
f01015ca:	68 af 51 10 f0       	push   $0xf01051af
f01015cf:	68 ff 4f 10 f0       	push   $0xf0104fff
f01015d4:	68 38 03 00 00       	push   $0x338
f01015d9:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01015de:	e8 bd ea ff ff       	call   f01000a0 <_panic>

	cprintf("\ncheck_page_alloc() succeeded!\n");
f01015e3:	83 ec 0c             	sub    $0xc,%esp
f01015e6:	68 dc 49 10 f0       	push   $0xf01049dc
f01015eb:	e8 f9 18 00 00       	call   f0102ee9 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015f7:	e8 49 f7 ff ff       	call   f0100d45 <page_alloc>
f01015fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015ff:	83 c4 10             	add    $0x10,%esp
f0101602:	85 c0                	test   %eax,%eax
f0101604:	75 19                	jne    f010161f <mem_init+0x59c>
f0101606:	68 bd 50 10 f0       	push   $0xf01050bd
f010160b:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101610:	68 96 03 00 00       	push   $0x396
f0101615:	68 d9 4f 10 f0       	push   $0xf0104fd9
f010161a:	e8 81 ea ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f010161f:	83 ec 0c             	sub    $0xc,%esp
f0101622:	6a 00                	push   $0x0
f0101624:	e8 1c f7 ff ff       	call   f0100d45 <page_alloc>
f0101629:	89 c3                	mov    %eax,%ebx
f010162b:	83 c4 10             	add    $0x10,%esp
f010162e:	85 c0                	test   %eax,%eax
f0101630:	75 19                	jne    f010164b <mem_init+0x5c8>
f0101632:	68 d3 50 10 f0       	push   $0xf01050d3
f0101637:	68 ff 4f 10 f0       	push   $0xf0104fff
f010163c:	68 97 03 00 00       	push   $0x397
f0101641:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101646:	e8 55 ea ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f010164b:	83 ec 0c             	sub    $0xc,%esp
f010164e:	6a 00                	push   $0x0
f0101650:	e8 f0 f6 ff ff       	call   f0100d45 <page_alloc>
f0101655:	89 c6                	mov    %eax,%esi
f0101657:	83 c4 10             	add    $0x10,%esp
f010165a:	85 c0                	test   %eax,%eax
f010165c:	75 19                	jne    f0101677 <mem_init+0x5f4>
f010165e:	68 e9 50 10 f0       	push   $0xf01050e9
f0101663:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101668:	68 98 03 00 00       	push   $0x398
f010166d:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101672:	e8 29 ea ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101677:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010167a:	75 19                	jne    f0101695 <mem_init+0x612>
f010167c:	68 ff 50 10 f0       	push   $0xf01050ff
f0101681:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101686:	68 9b 03 00 00       	push   $0x39b
f010168b:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101690:	e8 0b ea ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101695:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101698:	74 04                	je     f010169e <mem_init+0x61b>
f010169a:	39 c3                	cmp    %eax,%ebx
f010169c:	75 19                	jne    f01016b7 <mem_init+0x634>
f010169e:	68 bc 49 10 f0       	push   $0xf01049bc
f01016a3:	68 ff 4f 10 f0       	push   $0xf0104fff
f01016a8:	68 9c 03 00 00       	push   $0x39c
f01016ad:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01016b2:	e8 e9 e9 ff ff       	call   f01000a0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01016b7:	a1 1c 92 17 f0       	mov    0xf017921c,%eax
f01016bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01016bf:	c7 05 1c 92 17 f0 00 	movl   $0x0,0xf017921c
f01016c6:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01016c9:	83 ec 0c             	sub    $0xc,%esp
f01016cc:	6a 00                	push   $0x0
f01016ce:	e8 72 f6 ff ff       	call   f0100d45 <page_alloc>
f01016d3:	83 c4 10             	add    $0x10,%esp
f01016d6:	85 c0                	test   %eax,%eax
f01016d8:	74 19                	je     f01016f3 <mem_init+0x670>
f01016da:	68 68 51 10 f0       	push   $0xf0105168
f01016df:	68 ff 4f 10 f0       	push   $0xf0104fff
f01016e4:	68 a3 03 00 00       	push   $0x3a3
f01016e9:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01016ee:	e8 ad e9 ff ff       	call   f01000a0 <_panic>
	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01016f3:	83 ec 04             	sub    $0x4,%esp
f01016f6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01016f9:	50                   	push   %eax
f01016fa:	6a 00                	push   $0x0
f01016fc:	ff 35 08 9f 17 f0    	pushl  0xf0179f08
f0101702:	e8 6c f8 ff ff       	call   f0100f73 <page_lookup>
f0101707:	83 c4 10             	add    $0x10,%esp
f010170a:	85 c0                	test   %eax,%eax
f010170c:	74 19                	je     f0101727 <mem_init+0x6a4>
f010170e:	68 fc 49 10 f0       	push   $0xf01049fc
f0101713:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101718:	68 a5 03 00 00       	push   $0x3a5
f010171d:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101722:	e8 79 e9 ff ff       	call   f01000a0 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101727:	6a 02                	push   $0x2
f0101729:	6a 00                	push   $0x0
f010172b:	53                   	push   %ebx
f010172c:	ff 35 08 9f 17 f0    	pushl  0xf0179f08
f0101732:	e8 e4 f8 ff ff       	call   f010101b <page_insert>
f0101737:	83 c4 10             	add    $0x10,%esp
f010173a:	85 c0                	test   %eax,%eax
f010173c:	78 19                	js     f0101757 <mem_init+0x6d4>
f010173e:	68 34 4a 10 f0       	push   $0xf0104a34
f0101743:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101748:	68 a8 03 00 00       	push   $0x3a8
f010174d:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101752:	e8 49 e9 ff ff       	call   f01000a0 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101757:	83 ec 0c             	sub    $0xc,%esp
f010175a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010175d:	e8 5a f6 ff ff       	call   f0100dbc <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101762:	6a 02                	push   $0x2
f0101764:	6a 00                	push   $0x0
f0101766:	53                   	push   %ebx
f0101767:	ff 35 08 9f 17 f0    	pushl  0xf0179f08
f010176d:	e8 a9 f8 ff ff       	call   f010101b <page_insert>
f0101772:	83 c4 20             	add    $0x20,%esp
f0101775:	85 c0                	test   %eax,%eax
f0101777:	74 19                	je     f0101792 <mem_init+0x70f>
f0101779:	68 64 4a 10 f0       	push   $0xf0104a64
f010177e:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101783:	68 ac 03 00 00       	push   $0x3ac
f0101788:	68 d9 4f 10 f0       	push   $0xf0104fd9
f010178d:	e8 0e e9 ff ff       	call   f01000a0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101792:	8b 3d 08 9f 17 f0    	mov    0xf0179f08,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101798:	a1 0c 9f 17 f0       	mov    0xf0179f0c,%eax
f010179d:	89 c1                	mov    %eax,%ecx
f010179f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01017a2:	8b 17                	mov    (%edi),%edx
f01017a4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01017aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017ad:	29 c8                	sub    %ecx,%eax
f01017af:	c1 f8 03             	sar    $0x3,%eax
f01017b2:	c1 e0 0c             	shl    $0xc,%eax
f01017b5:	39 c2                	cmp    %eax,%edx
f01017b7:	74 19                	je     f01017d2 <mem_init+0x74f>
f01017b9:	68 94 4a 10 f0       	push   $0xf0104a94
f01017be:	68 ff 4f 10 f0       	push   $0xf0104fff
f01017c3:	68 ad 03 00 00       	push   $0x3ad
f01017c8:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01017cd:	e8 ce e8 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01017d2:	ba 00 00 00 00       	mov    $0x0,%edx
f01017d7:	89 f8                	mov    %edi,%eax
f01017d9:	e8 a3 f1 ff ff       	call   f0100981 <check_va2pa>
f01017de:	89 da                	mov    %ebx,%edx
f01017e0:	2b 55 cc             	sub    -0x34(%ebp),%edx
f01017e3:	c1 fa 03             	sar    $0x3,%edx
f01017e6:	c1 e2 0c             	shl    $0xc,%edx
f01017e9:	39 d0                	cmp    %edx,%eax
f01017eb:	74 19                	je     f0101806 <mem_init+0x783>
f01017ed:	68 bc 4a 10 f0       	push   $0xf0104abc
f01017f2:	68 ff 4f 10 f0       	push   $0xf0104fff
f01017f7:	68 ae 03 00 00       	push   $0x3ae
f01017fc:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101801:	e8 9a e8 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f0101806:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010180b:	74 19                	je     f0101826 <mem_init+0x7a3>
f010180d:	68 ba 51 10 f0       	push   $0xf01051ba
f0101812:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101817:	68 af 03 00 00       	push   $0x3af
f010181c:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101821:	e8 7a e8 ff ff       	call   f01000a0 <_panic>
	assert(pp0->pp_ref == 1);
f0101826:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101829:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010182e:	74 19                	je     f0101849 <mem_init+0x7c6>
f0101830:	68 cb 51 10 f0       	push   $0xf01051cb
f0101835:	68 ff 4f 10 f0       	push   $0xf0104fff
f010183a:	68 b0 03 00 00       	push   $0x3b0
f010183f:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101844:	e8 57 e8 ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101849:	6a 02                	push   $0x2
f010184b:	68 00 10 00 00       	push   $0x1000
f0101850:	56                   	push   %esi
f0101851:	57                   	push   %edi
f0101852:	e8 c4 f7 ff ff       	call   f010101b <page_insert>
f0101857:	83 c4 10             	add    $0x10,%esp
f010185a:	85 c0                	test   %eax,%eax
f010185c:	74 19                	je     f0101877 <mem_init+0x7f4>
f010185e:	68 ec 4a 10 f0       	push   $0xf0104aec
f0101863:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101868:	68 b3 03 00 00       	push   $0x3b3
f010186d:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101872:	e8 29 e8 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101877:	ba 00 10 00 00       	mov    $0x1000,%edx
f010187c:	a1 08 9f 17 f0       	mov    0xf0179f08,%eax
f0101881:	e8 fb f0 ff ff       	call   f0100981 <check_va2pa>
f0101886:	89 f2                	mov    %esi,%edx
f0101888:	2b 15 0c 9f 17 f0    	sub    0xf0179f0c,%edx
f010188e:	c1 fa 03             	sar    $0x3,%edx
f0101891:	c1 e2 0c             	shl    $0xc,%edx
f0101894:	39 d0                	cmp    %edx,%eax
f0101896:	74 19                	je     f01018b1 <mem_init+0x82e>
f0101898:	68 28 4b 10 f0       	push   $0xf0104b28
f010189d:	68 ff 4f 10 f0       	push   $0xf0104fff
f01018a2:	68 b4 03 00 00       	push   $0x3b4
f01018a7:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01018ac:	e8 ef e7 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f01018b1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01018b6:	74 19                	je     f01018d1 <mem_init+0x84e>
f01018b8:	68 dc 51 10 f0       	push   $0xf01051dc
f01018bd:	68 ff 4f 10 f0       	push   $0xf0104fff
f01018c2:	68 b5 03 00 00       	push   $0x3b5
f01018c7:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01018cc:	e8 cf e7 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01018d1:	83 ec 0c             	sub    $0xc,%esp
f01018d4:	6a 00                	push   $0x0
f01018d6:	e8 6a f4 ff ff       	call   f0100d45 <page_alloc>
f01018db:	83 c4 10             	add    $0x10,%esp
f01018de:	85 c0                	test   %eax,%eax
f01018e0:	74 19                	je     f01018fb <mem_init+0x878>
f01018e2:	68 68 51 10 f0       	push   $0xf0105168
f01018e7:	68 ff 4f 10 f0       	push   $0xf0104fff
f01018ec:	68 b8 03 00 00       	push   $0x3b8
f01018f1:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01018f6:	e8 a5 e7 ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01018fb:	6a 02                	push   $0x2
f01018fd:	68 00 10 00 00       	push   $0x1000
f0101902:	56                   	push   %esi
f0101903:	ff 35 08 9f 17 f0    	pushl  0xf0179f08
f0101909:	e8 0d f7 ff ff       	call   f010101b <page_insert>
f010190e:	83 c4 10             	add    $0x10,%esp
f0101911:	85 c0                	test   %eax,%eax
f0101913:	74 19                	je     f010192e <mem_init+0x8ab>
f0101915:	68 ec 4a 10 f0       	push   $0xf0104aec
f010191a:	68 ff 4f 10 f0       	push   $0xf0104fff
f010191f:	68 bb 03 00 00       	push   $0x3bb
f0101924:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101929:	e8 72 e7 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010192e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101933:	a1 08 9f 17 f0       	mov    0xf0179f08,%eax
f0101938:	e8 44 f0 ff ff       	call   f0100981 <check_va2pa>
f010193d:	89 f2                	mov    %esi,%edx
f010193f:	2b 15 0c 9f 17 f0    	sub    0xf0179f0c,%edx
f0101945:	c1 fa 03             	sar    $0x3,%edx
f0101948:	c1 e2 0c             	shl    $0xc,%edx
f010194b:	39 d0                	cmp    %edx,%eax
f010194d:	74 19                	je     f0101968 <mem_init+0x8e5>
f010194f:	68 28 4b 10 f0       	push   $0xf0104b28
f0101954:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101959:	68 bc 03 00 00       	push   $0x3bc
f010195e:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101963:	e8 38 e7 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101968:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010196d:	74 19                	je     f0101988 <mem_init+0x905>
f010196f:	68 dc 51 10 f0       	push   $0xf01051dc
f0101974:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101979:	68 bd 03 00 00       	push   $0x3bd
f010197e:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101983:	e8 18 e7 ff ff       	call   f01000a0 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101988:	83 ec 0c             	sub    $0xc,%esp
f010198b:	6a 00                	push   $0x0
f010198d:	e8 b3 f3 ff ff       	call   f0100d45 <page_alloc>
f0101992:	83 c4 10             	add    $0x10,%esp
f0101995:	85 c0                	test   %eax,%eax
f0101997:	74 19                	je     f01019b2 <mem_init+0x92f>
f0101999:	68 68 51 10 f0       	push   $0xf0105168
f010199e:	68 ff 4f 10 f0       	push   $0xf0104fff
f01019a3:	68 c1 03 00 00       	push   $0x3c1
f01019a8:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01019ad:	e8 ee e6 ff ff       	call   f01000a0 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01019b2:	8b 15 08 9f 17 f0    	mov    0xf0179f08,%edx
f01019b8:	8b 02                	mov    (%edx),%eax
f01019ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01019bf:	89 c1                	mov    %eax,%ecx
f01019c1:	c1 e9 0c             	shr    $0xc,%ecx
f01019c4:	3b 0d 04 9f 17 f0    	cmp    0xf0179f04,%ecx
f01019ca:	72 15                	jb     f01019e1 <mem_init+0x95e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019cc:	50                   	push   %eax
f01019cd:	68 08 48 10 f0       	push   $0xf0104808
f01019d2:	68 c4 03 00 00       	push   $0x3c4
f01019d7:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01019dc:	e8 bf e6 ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f01019e1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01019e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01019e9:	83 ec 04             	sub    $0x4,%esp
f01019ec:	6a 00                	push   $0x0
f01019ee:	68 00 10 00 00       	push   $0x1000
f01019f3:	52                   	push   %edx
f01019f4:	e8 25 f4 ff ff       	call   f0100e1e <pgdir_walk>
f01019f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01019fc:	8d 57 04             	lea    0x4(%edi),%edx
f01019ff:	83 c4 10             	add    $0x10,%esp
f0101a02:	39 d0                	cmp    %edx,%eax
f0101a04:	74 19                	je     f0101a1f <mem_init+0x99c>
f0101a06:	68 58 4b 10 f0       	push   $0xf0104b58
f0101a0b:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101a10:	68 c5 03 00 00       	push   $0x3c5
f0101a15:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101a1a:	e8 81 e6 ff ff       	call   f01000a0 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101a1f:	6a 06                	push   $0x6
f0101a21:	68 00 10 00 00       	push   $0x1000
f0101a26:	56                   	push   %esi
f0101a27:	ff 35 08 9f 17 f0    	pushl  0xf0179f08
f0101a2d:	e8 e9 f5 ff ff       	call   f010101b <page_insert>
f0101a32:	83 c4 10             	add    $0x10,%esp
f0101a35:	85 c0                	test   %eax,%eax
f0101a37:	74 19                	je     f0101a52 <mem_init+0x9cf>
f0101a39:	68 98 4b 10 f0       	push   $0xf0104b98
f0101a3e:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101a43:	68 c8 03 00 00       	push   $0x3c8
f0101a48:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101a4d:	e8 4e e6 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a52:	8b 3d 08 9f 17 f0    	mov    0xf0179f08,%edi
f0101a58:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a5d:	89 f8                	mov    %edi,%eax
f0101a5f:	e8 1d ef ff ff       	call   f0100981 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a64:	89 f2                	mov    %esi,%edx
f0101a66:	2b 15 0c 9f 17 f0    	sub    0xf0179f0c,%edx
f0101a6c:	c1 fa 03             	sar    $0x3,%edx
f0101a6f:	c1 e2 0c             	shl    $0xc,%edx
f0101a72:	39 d0                	cmp    %edx,%eax
f0101a74:	74 19                	je     f0101a8f <mem_init+0xa0c>
f0101a76:	68 28 4b 10 f0       	push   $0xf0104b28
f0101a7b:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101a80:	68 c9 03 00 00       	push   $0x3c9
f0101a85:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101a8a:	e8 11 e6 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101a8f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a94:	74 19                	je     f0101aaf <mem_init+0xa2c>
f0101a96:	68 dc 51 10 f0       	push   $0xf01051dc
f0101a9b:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101aa0:	68 ca 03 00 00       	push   $0x3ca
f0101aa5:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101aaa:	e8 f1 e5 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101aaf:	83 ec 04             	sub    $0x4,%esp
f0101ab2:	6a 00                	push   $0x0
f0101ab4:	68 00 10 00 00       	push   $0x1000
f0101ab9:	57                   	push   %edi
f0101aba:	e8 5f f3 ff ff       	call   f0100e1e <pgdir_walk>
f0101abf:	83 c4 10             	add    $0x10,%esp
f0101ac2:	f6 00 04             	testb  $0x4,(%eax)
f0101ac5:	75 19                	jne    f0101ae0 <mem_init+0xa5d>
f0101ac7:	68 d8 4b 10 f0       	push   $0xf0104bd8
f0101acc:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101ad1:	68 cb 03 00 00       	push   $0x3cb
f0101ad6:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101adb:	e8 c0 e5 ff ff       	call   f01000a0 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101ae0:	a1 08 9f 17 f0       	mov    0xf0179f08,%eax
f0101ae5:	f6 00 04             	testb  $0x4,(%eax)
f0101ae8:	75 19                	jne    f0101b03 <mem_init+0xa80>
f0101aea:	68 ed 51 10 f0       	push   $0xf01051ed
f0101aef:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101af4:	68 cc 03 00 00       	push   $0x3cc
f0101af9:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101afe:	e8 9d e5 ff ff       	call   f01000a0 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b03:	6a 02                	push   $0x2
f0101b05:	68 00 10 00 00       	push   $0x1000
f0101b0a:	56                   	push   %esi
f0101b0b:	50                   	push   %eax
f0101b0c:	e8 0a f5 ff ff       	call   f010101b <page_insert>
f0101b11:	83 c4 10             	add    $0x10,%esp
f0101b14:	85 c0                	test   %eax,%eax
f0101b16:	74 19                	je     f0101b31 <mem_init+0xaae>
f0101b18:	68 ec 4a 10 f0       	push   $0xf0104aec
f0101b1d:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101b22:	68 cf 03 00 00       	push   $0x3cf
f0101b27:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101b2c:	e8 6f e5 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b31:	83 ec 04             	sub    $0x4,%esp
f0101b34:	6a 00                	push   $0x0
f0101b36:	68 00 10 00 00       	push   $0x1000
f0101b3b:	ff 35 08 9f 17 f0    	pushl  0xf0179f08
f0101b41:	e8 d8 f2 ff ff       	call   f0100e1e <pgdir_walk>
f0101b46:	83 c4 10             	add    $0x10,%esp
f0101b49:	f6 00 02             	testb  $0x2,(%eax)
f0101b4c:	75 19                	jne    f0101b67 <mem_init+0xae4>
f0101b4e:	68 0c 4c 10 f0       	push   $0xf0104c0c
f0101b53:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101b58:	68 d0 03 00 00       	push   $0x3d0
f0101b5d:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101b62:	e8 39 e5 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b67:	83 ec 04             	sub    $0x4,%esp
f0101b6a:	6a 00                	push   $0x0
f0101b6c:	68 00 10 00 00       	push   $0x1000
f0101b71:	ff 35 08 9f 17 f0    	pushl  0xf0179f08
f0101b77:	e8 a2 f2 ff ff       	call   f0100e1e <pgdir_walk>
f0101b7c:	83 c4 10             	add    $0x10,%esp
f0101b7f:	f6 00 04             	testb  $0x4,(%eax)
f0101b82:	74 19                	je     f0101b9d <mem_init+0xb1a>
f0101b84:	68 40 4c 10 f0       	push   $0xf0104c40
f0101b89:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101b8e:	68 d1 03 00 00       	push   $0x3d1
f0101b93:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101b98:	e8 03 e5 ff ff       	call   f01000a0 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101b9d:	6a 02                	push   $0x2
f0101b9f:	68 00 00 40 00       	push   $0x400000
f0101ba4:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101ba7:	ff 35 08 9f 17 f0    	pushl  0xf0179f08
f0101bad:	e8 69 f4 ff ff       	call   f010101b <page_insert>
f0101bb2:	83 c4 10             	add    $0x10,%esp
f0101bb5:	85 c0                	test   %eax,%eax
f0101bb7:	78 19                	js     f0101bd2 <mem_init+0xb4f>
f0101bb9:	68 78 4c 10 f0       	push   $0xf0104c78
f0101bbe:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101bc3:	68 d4 03 00 00       	push   $0x3d4
f0101bc8:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101bcd:	e8 ce e4 ff ff       	call   f01000a0 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101bd2:	6a 02                	push   $0x2
f0101bd4:	68 00 10 00 00       	push   $0x1000
f0101bd9:	53                   	push   %ebx
f0101bda:	ff 35 08 9f 17 f0    	pushl  0xf0179f08
f0101be0:	e8 36 f4 ff ff       	call   f010101b <page_insert>
f0101be5:	83 c4 10             	add    $0x10,%esp
f0101be8:	85 c0                	test   %eax,%eax
f0101bea:	74 19                	je     f0101c05 <mem_init+0xb82>
f0101bec:	68 b0 4c 10 f0       	push   $0xf0104cb0
f0101bf1:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101bf6:	68 d7 03 00 00       	push   $0x3d7
f0101bfb:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101c00:	e8 9b e4 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c05:	83 ec 04             	sub    $0x4,%esp
f0101c08:	6a 00                	push   $0x0
f0101c0a:	68 00 10 00 00       	push   $0x1000
f0101c0f:	ff 35 08 9f 17 f0    	pushl  0xf0179f08
f0101c15:	e8 04 f2 ff ff       	call   f0100e1e <pgdir_walk>
f0101c1a:	83 c4 10             	add    $0x10,%esp
f0101c1d:	f6 00 04             	testb  $0x4,(%eax)
f0101c20:	74 19                	je     f0101c3b <mem_init+0xbb8>
f0101c22:	68 40 4c 10 f0       	push   $0xf0104c40
f0101c27:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101c2c:	68 d8 03 00 00       	push   $0x3d8
f0101c31:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101c36:	e8 65 e4 ff ff       	call   f01000a0 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101c3b:	8b 3d 08 9f 17 f0    	mov    0xf0179f08,%edi
f0101c41:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c46:	89 f8                	mov    %edi,%eax
f0101c48:	e8 34 ed ff ff       	call   f0100981 <check_va2pa>
f0101c4d:	89 c1                	mov    %eax,%ecx
f0101c4f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101c52:	89 d8                	mov    %ebx,%eax
f0101c54:	2b 05 0c 9f 17 f0    	sub    0xf0179f0c,%eax
f0101c5a:	c1 f8 03             	sar    $0x3,%eax
f0101c5d:	c1 e0 0c             	shl    $0xc,%eax
f0101c60:	39 c1                	cmp    %eax,%ecx
f0101c62:	74 19                	je     f0101c7d <mem_init+0xbfa>
f0101c64:	68 ec 4c 10 f0       	push   $0xf0104cec
f0101c69:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101c6e:	68 db 03 00 00       	push   $0x3db
f0101c73:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101c78:	e8 23 e4 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c7d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c82:	89 f8                	mov    %edi,%eax
f0101c84:	e8 f8 ec ff ff       	call   f0100981 <check_va2pa>
f0101c89:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101c8c:	74 19                	je     f0101ca7 <mem_init+0xc24>
f0101c8e:	68 18 4d 10 f0       	push   $0xf0104d18
f0101c93:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101c98:	68 dc 03 00 00       	push   $0x3dc
f0101c9d:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101ca2:	e8 f9 e3 ff ff       	call   f01000a0 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101ca7:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101cac:	74 19                	je     f0101cc7 <mem_init+0xc44>
f0101cae:	68 03 52 10 f0       	push   $0xf0105203
f0101cb3:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101cb8:	68 de 03 00 00       	push   $0x3de
f0101cbd:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101cc2:	e8 d9 e3 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101cc7:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ccc:	74 19                	je     f0101ce7 <mem_init+0xc64>
f0101cce:	68 14 52 10 f0       	push   $0xf0105214
f0101cd3:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101cd8:	68 df 03 00 00       	push   $0x3df
f0101cdd:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101ce2:	e8 b9 e3 ff ff       	call   f01000a0 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101ce7:	83 ec 0c             	sub    $0xc,%esp
f0101cea:	6a 00                	push   $0x0
f0101cec:	e8 54 f0 ff ff       	call   f0100d45 <page_alloc>
f0101cf1:	83 c4 10             	add    $0x10,%esp
f0101cf4:	85 c0                	test   %eax,%eax
f0101cf6:	74 04                	je     f0101cfc <mem_init+0xc79>
f0101cf8:	39 c6                	cmp    %eax,%esi
f0101cfa:	74 19                	je     f0101d15 <mem_init+0xc92>
f0101cfc:	68 48 4d 10 f0       	push   $0xf0104d48
f0101d01:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101d06:	68 e2 03 00 00       	push   $0x3e2
f0101d0b:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101d10:	e8 8b e3 ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101d15:	83 ec 08             	sub    $0x8,%esp
f0101d18:	6a 00                	push   $0x0
f0101d1a:	ff 35 08 9f 17 f0    	pushl  0xf0179f08
f0101d20:	e8 b4 f2 ff ff       	call   f0100fd9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d25:	8b 3d 08 9f 17 f0    	mov    0xf0179f08,%edi
f0101d2b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d30:	89 f8                	mov    %edi,%eax
f0101d32:	e8 4a ec ff ff       	call   f0100981 <check_va2pa>
f0101d37:	83 c4 10             	add    $0x10,%esp
f0101d3a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d3d:	74 19                	je     f0101d58 <mem_init+0xcd5>
f0101d3f:	68 6c 4d 10 f0       	push   $0xf0104d6c
f0101d44:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101d49:	68 e6 03 00 00       	push   $0x3e6
f0101d4e:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101d53:	e8 48 e3 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d58:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d5d:	89 f8                	mov    %edi,%eax
f0101d5f:	e8 1d ec ff ff       	call   f0100981 <check_va2pa>
f0101d64:	89 da                	mov    %ebx,%edx
f0101d66:	2b 15 0c 9f 17 f0    	sub    0xf0179f0c,%edx
f0101d6c:	c1 fa 03             	sar    $0x3,%edx
f0101d6f:	c1 e2 0c             	shl    $0xc,%edx
f0101d72:	39 d0                	cmp    %edx,%eax
f0101d74:	74 19                	je     f0101d8f <mem_init+0xd0c>
f0101d76:	68 18 4d 10 f0       	push   $0xf0104d18
f0101d7b:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101d80:	68 e7 03 00 00       	push   $0x3e7
f0101d85:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101d8a:	e8 11 e3 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f0101d8f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d94:	74 19                	je     f0101daf <mem_init+0xd2c>
f0101d96:	68 ba 51 10 f0       	push   $0xf01051ba
f0101d9b:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101da0:	68 e8 03 00 00       	push   $0x3e8
f0101da5:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101daa:	e8 f1 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101daf:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101db4:	74 19                	je     f0101dcf <mem_init+0xd4c>
f0101db6:	68 14 52 10 f0       	push   $0xf0105214
f0101dbb:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101dc0:	68 e9 03 00 00       	push   $0x3e9
f0101dc5:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101dca:	e8 d1 e2 ff ff       	call   f01000a0 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101dcf:	6a 00                	push   $0x0
f0101dd1:	68 00 10 00 00       	push   $0x1000
f0101dd6:	53                   	push   %ebx
f0101dd7:	57                   	push   %edi
f0101dd8:	e8 3e f2 ff ff       	call   f010101b <page_insert>
f0101ddd:	83 c4 10             	add    $0x10,%esp
f0101de0:	85 c0                	test   %eax,%eax
f0101de2:	74 19                	je     f0101dfd <mem_init+0xd7a>
f0101de4:	68 90 4d 10 f0       	push   $0xf0104d90
f0101de9:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101dee:	68 ec 03 00 00       	push   $0x3ec
f0101df3:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101df8:	e8 a3 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref);
f0101dfd:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e02:	75 19                	jne    f0101e1d <mem_init+0xd9a>
f0101e04:	68 25 52 10 f0       	push   $0xf0105225
f0101e09:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101e0e:	68 ed 03 00 00       	push   $0x3ed
f0101e13:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101e18:	e8 83 e2 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_link == NULL);
f0101e1d:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101e20:	74 19                	je     f0101e3b <mem_init+0xdb8>
f0101e22:	68 31 52 10 f0       	push   $0xf0105231
f0101e27:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101e2c:	68 ee 03 00 00       	push   $0x3ee
f0101e31:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101e36:	e8 65 e2 ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101e3b:	83 ec 08             	sub    $0x8,%esp
f0101e3e:	68 00 10 00 00       	push   $0x1000
f0101e43:	ff 35 08 9f 17 f0    	pushl  0xf0179f08
f0101e49:	e8 8b f1 ff ff       	call   f0100fd9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e4e:	8b 3d 08 9f 17 f0    	mov    0xf0179f08,%edi
f0101e54:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e59:	89 f8                	mov    %edi,%eax
f0101e5b:	e8 21 eb ff ff       	call   f0100981 <check_va2pa>
f0101e60:	83 c4 10             	add    $0x10,%esp
f0101e63:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e66:	74 19                	je     f0101e81 <mem_init+0xdfe>
f0101e68:	68 6c 4d 10 f0       	push   $0xf0104d6c
f0101e6d:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101e72:	68 f2 03 00 00       	push   $0x3f2
f0101e77:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101e7c:	e8 1f e2 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101e81:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e86:	89 f8                	mov    %edi,%eax
f0101e88:	e8 f4 ea ff ff       	call   f0100981 <check_va2pa>
f0101e8d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e90:	74 19                	je     f0101eab <mem_init+0xe28>
f0101e92:	68 c8 4d 10 f0       	push   $0xf0104dc8
f0101e97:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101e9c:	68 f3 03 00 00       	push   $0x3f3
f0101ea1:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101ea6:	e8 f5 e1 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f0101eab:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101eb0:	74 19                	je     f0101ecb <mem_init+0xe48>
f0101eb2:	68 46 52 10 f0       	push   $0xf0105246
f0101eb7:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101ebc:	68 f4 03 00 00       	push   $0x3f4
f0101ec1:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101ec6:	e8 d5 e1 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101ecb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ed0:	74 19                	je     f0101eeb <mem_init+0xe68>
f0101ed2:	68 14 52 10 f0       	push   $0xf0105214
f0101ed7:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101edc:	68 f5 03 00 00       	push   $0x3f5
f0101ee1:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101ee6:	e8 b5 e1 ff ff       	call   f01000a0 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101eeb:	83 ec 0c             	sub    $0xc,%esp
f0101eee:	6a 00                	push   $0x0
f0101ef0:	e8 50 ee ff ff       	call   f0100d45 <page_alloc>
f0101ef5:	83 c4 10             	add    $0x10,%esp
f0101ef8:	85 c0                	test   %eax,%eax
f0101efa:	74 04                	je     f0101f00 <mem_init+0xe7d>
f0101efc:	39 c3                	cmp    %eax,%ebx
f0101efe:	74 19                	je     f0101f19 <mem_init+0xe96>
f0101f00:	68 f0 4d 10 f0       	push   $0xf0104df0
f0101f05:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101f0a:	68 f8 03 00 00       	push   $0x3f8
f0101f0f:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101f14:	e8 87 e1 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f19:	83 ec 0c             	sub    $0xc,%esp
f0101f1c:	6a 00                	push   $0x0
f0101f1e:	e8 22 ee ff ff       	call   f0100d45 <page_alloc>
f0101f23:	83 c4 10             	add    $0x10,%esp
f0101f26:	85 c0                	test   %eax,%eax
f0101f28:	74 19                	je     f0101f43 <mem_init+0xec0>
f0101f2a:	68 68 51 10 f0       	push   $0xf0105168
f0101f2f:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101f34:	68 fb 03 00 00       	push   $0x3fb
f0101f39:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101f3e:	e8 5d e1 ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f43:	8b 0d 08 9f 17 f0    	mov    0xf0179f08,%ecx
f0101f49:	8b 11                	mov    (%ecx),%edx
f0101f4b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101f51:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f54:	2b 05 0c 9f 17 f0    	sub    0xf0179f0c,%eax
f0101f5a:	c1 f8 03             	sar    $0x3,%eax
f0101f5d:	c1 e0 0c             	shl    $0xc,%eax
f0101f60:	39 c2                	cmp    %eax,%edx
f0101f62:	74 19                	je     f0101f7d <mem_init+0xefa>
f0101f64:	68 94 4a 10 f0       	push   $0xf0104a94
f0101f69:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101f6e:	68 fe 03 00 00       	push   $0x3fe
f0101f73:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101f78:	e8 23 e1 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f0101f7d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101f83:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f86:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101f8b:	74 19                	je     f0101fa6 <mem_init+0xf23>
f0101f8d:	68 cb 51 10 f0       	push   $0xf01051cb
f0101f92:	68 ff 4f 10 f0       	push   $0xf0104fff
f0101f97:	68 00 04 00 00       	push   $0x400
f0101f9c:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0101fa1:	e8 fa e0 ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f0101fa6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fa9:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101faf:	83 ec 0c             	sub    $0xc,%esp
f0101fb2:	50                   	push   %eax
f0101fb3:	e8 04 ee ff ff       	call   f0100dbc <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101fb8:	83 c4 0c             	add    $0xc,%esp
f0101fbb:	6a 01                	push   $0x1
f0101fbd:	68 00 10 40 00       	push   $0x401000
f0101fc2:	ff 35 08 9f 17 f0    	pushl  0xf0179f08
f0101fc8:	e8 51 ee ff ff       	call   f0100e1e <pgdir_walk>
f0101fcd:	89 c7                	mov    %eax,%edi
f0101fcf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101fd2:	a1 08 9f 17 f0       	mov    0xf0179f08,%eax
f0101fd7:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101fda:	8b 40 04             	mov    0x4(%eax),%eax
f0101fdd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fe2:	8b 0d 04 9f 17 f0    	mov    0xf0179f04,%ecx
f0101fe8:	89 c2                	mov    %eax,%edx
f0101fea:	c1 ea 0c             	shr    $0xc,%edx
f0101fed:	83 c4 10             	add    $0x10,%esp
f0101ff0:	39 ca                	cmp    %ecx,%edx
f0101ff2:	72 15                	jb     f0102009 <mem_init+0xf86>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ff4:	50                   	push   %eax
f0101ff5:	68 08 48 10 f0       	push   $0xf0104808
f0101ffa:	68 07 04 00 00       	push   $0x407
f0101fff:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0102004:	e8 97 e0 ff ff       	call   f01000a0 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102009:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010200e:	39 c7                	cmp    %eax,%edi
f0102010:	74 19                	je     f010202b <mem_init+0xfa8>
f0102012:	68 57 52 10 f0       	push   $0xf0105257
f0102017:	68 ff 4f 10 f0       	push   $0xf0104fff
f010201c:	68 08 04 00 00       	push   $0x408
f0102021:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0102026:	e8 75 e0 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010202b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010202e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102035:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102038:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010203e:	2b 05 0c 9f 17 f0    	sub    0xf0179f0c,%eax
f0102044:	c1 f8 03             	sar    $0x3,%eax
f0102047:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010204a:	89 c2                	mov    %eax,%edx
f010204c:	c1 ea 0c             	shr    $0xc,%edx
f010204f:	39 d1                	cmp    %edx,%ecx
f0102051:	77 12                	ja     f0102065 <mem_init+0xfe2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102053:	50                   	push   %eax
f0102054:	68 08 48 10 f0       	push   $0xf0104808
f0102059:	6a 56                	push   $0x56
f010205b:	68 e5 4f 10 f0       	push   $0xf0104fe5
f0102060:	e8 3b e0 ff ff       	call   f01000a0 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102065:	83 ec 04             	sub    $0x4,%esp
f0102068:	68 00 10 00 00       	push   $0x1000
f010206d:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102072:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102077:	50                   	push   %eax
f0102078:	e8 43 1d 00 00       	call   f0103dc0 <memset>
	page_free(pp0);
f010207d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102080:	89 3c 24             	mov    %edi,(%esp)
f0102083:	e8 34 ed ff ff       	call   f0100dbc <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102088:	83 c4 0c             	add    $0xc,%esp
f010208b:	6a 01                	push   $0x1
f010208d:	6a 00                	push   $0x0
f010208f:	ff 35 08 9f 17 f0    	pushl  0xf0179f08
f0102095:	e8 84 ed ff ff       	call   f0100e1e <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010209a:	89 fa                	mov    %edi,%edx
f010209c:	2b 15 0c 9f 17 f0    	sub    0xf0179f0c,%edx
f01020a2:	c1 fa 03             	sar    $0x3,%edx
f01020a5:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020a8:	89 d0                	mov    %edx,%eax
f01020aa:	c1 e8 0c             	shr    $0xc,%eax
f01020ad:	83 c4 10             	add    $0x10,%esp
f01020b0:	3b 05 04 9f 17 f0    	cmp    0xf0179f04,%eax
f01020b6:	72 12                	jb     f01020ca <mem_init+0x1047>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020b8:	52                   	push   %edx
f01020b9:	68 08 48 10 f0       	push   $0xf0104808
f01020be:	6a 56                	push   $0x56
f01020c0:	68 e5 4f 10 f0       	push   $0xf0104fe5
f01020c5:	e8 d6 df ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f01020ca:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01020d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01020d3:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01020d9:	f6 00 01             	testb  $0x1,(%eax)
f01020dc:	74 19                	je     f01020f7 <mem_init+0x1074>
f01020de:	68 6f 52 10 f0       	push   $0xf010526f
f01020e3:	68 ff 4f 10 f0       	push   $0xf0104fff
f01020e8:	68 12 04 00 00       	push   $0x412
f01020ed:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01020f2:	e8 a9 df ff ff       	call   f01000a0 <_panic>
f01020f7:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01020fa:	39 d0                	cmp    %edx,%eax
f01020fc:	75 db                	jne    f01020d9 <mem_init+0x1056>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01020fe:	a1 08 9f 17 f0       	mov    0xf0179f08,%eax
f0102103:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102109:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010210c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102112:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102115:	89 3d 1c 92 17 f0    	mov    %edi,0xf017921c

	// free the pages we took
	page_free(pp0);
f010211b:	83 ec 0c             	sub    $0xc,%esp
f010211e:	50                   	push   %eax
f010211f:	e8 98 ec ff ff       	call   f0100dbc <page_free>
	page_free(pp1);
f0102124:	89 1c 24             	mov    %ebx,(%esp)
f0102127:	e8 90 ec ff ff       	call   f0100dbc <page_free>
	page_free(pp2);
f010212c:	89 34 24             	mov    %esi,(%esp)
f010212f:	e8 88 ec ff ff       	call   f0100dbc <page_free>

	cprintf("check_page() succeeded!\n");
f0102134:	c7 04 24 86 52 10 f0 	movl   $0xf0105286,(%esp)
f010213b:	e8 a9 0d 00 00       	call   f0102ee9 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102140:	a1 04 9f 17 f0       	mov    0xf0179f04,%eax
f0102145:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f010214c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	//cprintf("\nValue of N:%d,Number of pages:%d\n",n,n/PGSIZE);
	
	boot_map_region(kern_pgdir, UPAGES, n, PADDR(pages), PTE_U | PTE_P);
f0102152:	a1 0c 9f 17 f0       	mov    0xf0179f0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102157:	83 c4 10             	add    $0x10,%esp
f010215a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010215f:	77 15                	ja     f0102176 <mem_init+0x10f3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102161:	50                   	push   %eax
f0102162:	68 98 49 10 f0       	push   $0xf0104998
f0102167:	68 cc 00 00 00       	push   $0xcc
f010216c:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0102171:	e8 2a df ff ff       	call   f01000a0 <_panic>
f0102176:	83 ec 08             	sub    $0x8,%esp
f0102179:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f010217b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102180:	50                   	push   %eax
f0102181:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102186:	a1 08 9f 17 f0       	mov    0xf0179f08,%eax
f010218b:	e8 58 ed ff ff       	call   f0100ee8 <boot_map_region>
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	//cprintf("\nValue n for envs:%d\nvalue of NENV:%d\nSize of ENV struct:%d\nUNVS:%x\nAddition n+UENV:%x",n,NENV,sizeof(struct Env),UENVS,n+UENVS);
	boot_map_region(kern_pgdir, UENVS, n, PADDR(envs), PTE_U | PTE_P);
f0102190:	a1 28 92 17 f0       	mov    0xf0179228,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102195:	83 c4 10             	add    $0x10,%esp
f0102198:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010219d:	77 15                	ja     f01021b4 <mem_init+0x1131>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010219f:	50                   	push   %eax
f01021a0:	68 98 49 10 f0       	push   $0xf0104998
f01021a5:	68 d6 00 00 00       	push   $0xd6
f01021aa:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01021af:	e8 ec de ff ff       	call   f01000a0 <_panic>
f01021b4:	83 ec 08             	sub    $0x8,%esp
f01021b7:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f01021b9:	05 00 00 00 10       	add    $0x10000000,%eax
f01021be:	50                   	push   %eax
f01021bf:	b9 00 80 01 00       	mov    $0x18000,%ecx
f01021c4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01021c9:	a1 08 9f 17 f0       	mov    0xf0179f08,%eax
f01021ce:	e8 15 ed ff ff       	call   f0100ee8 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021d3:	83 c4 10             	add    $0x10,%esp
f01021d6:	b8 00 00 11 f0       	mov    $0xf0110000,%eax
f01021db:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021e0:	77 15                	ja     f01021f7 <mem_init+0x1174>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021e2:	50                   	push   %eax
f01021e3:	68 98 49 10 f0       	push   $0xf0104998
f01021e8:	68 e4 00 00 00       	push   $0xe4
f01021ed:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01021f2:	e8 a9 de ff ff       	call   f01000a0 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f01021f7:	83 ec 08             	sub    $0x8,%esp
f01021fa:	6a 03                	push   $0x3
f01021fc:	68 00 00 11 00       	push   $0x110000
f0102201:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102206:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010220b:	a1 08 9f 17 f0       	mov    0xf0179f08,%eax
f0102210:	e8 d3 ec ff ff       	call   f0100ee8 <boot_map_region>
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	//boot_map_region(kern_pgdir, KERNBASE, npages*PGSIZE, PADDR((void*)KERNBASE), PTE_W | PTE_P); //npages*PGSIZE
	//cprintf("Size:%x",(ROUNDUP(0xffffffff-0xf0000000,PGSIZE)));
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff-0xf0000000, 0, PTE_W | PTE_P);
f0102215:	83 c4 08             	add    $0x8,%esp
f0102218:	6a 03                	push   $0x3
f010221a:	6a 00                	push   $0x0
f010221c:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0102221:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102226:	a1 08 9f 17 f0       	mov    0xf0179f08,%eax
f010222b:	e8 b8 ec ff ff       	call   f0100ee8 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102230:	8b 1d 08 9f 17 f0    	mov    0xf0179f08,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102236:	a1 04 9f 17 f0       	mov    0xf0179f04,%eax
f010223b:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010223e:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102245:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010224a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010224d:	8b 3d 0c 9f 17 f0    	mov    0xf0179f0c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102253:	89 7d d0             	mov    %edi,-0x30(%ebp)
f0102256:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102259:	be 00 00 00 00       	mov    $0x0,%esi
f010225e:	eb 55                	jmp    f01022b5 <mem_init+0x1232>
f0102260:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102266:	89 d8                	mov    %ebx,%eax
f0102268:	e8 14 e7 ff ff       	call   f0100981 <check_va2pa>
f010226d:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102274:	77 15                	ja     f010228b <mem_init+0x1208>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102276:	57                   	push   %edi
f0102277:	68 98 49 10 f0       	push   $0xf0104998
f010227c:	68 50 03 00 00       	push   $0x350
f0102281:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0102286:	e8 15 de ff ff       	call   f01000a0 <_panic>
f010228b:	8d 94 37 00 00 00 10 	lea    0x10000000(%edi,%esi,1),%edx
f0102292:	39 c2                	cmp    %eax,%edx
f0102294:	74 19                	je     f01022af <mem_init+0x122c>
f0102296:	68 14 4e 10 f0       	push   $0xf0104e14
f010229b:	68 ff 4f 10 f0       	push   $0xf0104fff
f01022a0:	68 50 03 00 00       	push   $0x350
f01022a5:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01022aa:	e8 f1 dd ff ff       	call   f01000a0 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01022af:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01022b5:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f01022b8:	77 a6                	ja     f0102260 <mem_init+0x11dd>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01022ba:	8b 3d 28 92 17 f0    	mov    0xf0179228,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01022c0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01022c3:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f01022c8:	89 f2                	mov    %esi,%edx
f01022ca:	89 d8                	mov    %ebx,%eax
f01022cc:	e8 b0 e6 ff ff       	call   f0100981 <check_va2pa>
f01022d1:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01022d8:	77 15                	ja     f01022ef <mem_init+0x126c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01022da:	57                   	push   %edi
f01022db:	68 98 49 10 f0       	push   $0xf0104998
f01022e0:	68 55 03 00 00       	push   $0x355
f01022e5:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01022ea:	e8 b1 dd ff ff       	call   f01000a0 <_panic>
f01022ef:	8d 94 37 00 00 40 21 	lea    0x21400000(%edi,%esi,1),%edx
f01022f6:	39 c2                	cmp    %eax,%edx
f01022f8:	74 19                	je     f0102313 <mem_init+0x1290>
f01022fa:	68 48 4e 10 f0       	push   $0xf0104e48
f01022ff:	68 ff 4f 10 f0       	push   $0xf0104fff
f0102304:	68 55 03 00 00       	push   $0x355
f0102309:	68 d9 4f 10 f0       	push   $0xf0104fd9
f010230e:	e8 8d dd ff ff       	call   f01000a0 <_panic>
f0102313:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102319:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f010231f:	75 a7                	jne    f01022c8 <mem_init+0x1245>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102321:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102324:	c1 e7 0c             	shl    $0xc,%edi
f0102327:	be 00 00 00 00       	mov    $0x0,%esi
f010232c:	eb 30                	jmp    f010235e <mem_init+0x12db>
f010232e:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102334:	89 d8                	mov    %ebx,%eax
f0102336:	e8 46 e6 ff ff       	call   f0100981 <check_va2pa>
f010233b:	39 c6                	cmp    %eax,%esi
f010233d:	74 19                	je     f0102358 <mem_init+0x12d5>
f010233f:	68 7c 4e 10 f0       	push   $0xf0104e7c
f0102344:	68 ff 4f 10 f0       	push   $0xf0104fff
f0102349:	68 59 03 00 00       	push   $0x359
f010234e:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0102353:	e8 48 dd ff ff       	call   f01000a0 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102358:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010235e:	39 fe                	cmp    %edi,%esi
f0102360:	72 cc                	jb     f010232e <mem_init+0x12ab>
f0102362:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102367:	89 f2                	mov    %esi,%edx
f0102369:	89 d8                	mov    %ebx,%eax
f010236b:	e8 11 e6 ff ff       	call   f0100981 <check_va2pa>
f0102370:	8d 96 00 80 11 10    	lea    0x10118000(%esi),%edx
f0102376:	39 c2                	cmp    %eax,%edx
f0102378:	74 19                	je     f0102393 <mem_init+0x1310>
f010237a:	68 a4 4e 10 f0       	push   $0xf0104ea4
f010237f:	68 ff 4f 10 f0       	push   $0xf0104fff
f0102384:	68 5d 03 00 00       	push   $0x35d
f0102389:	68 d9 4f 10 f0       	push   $0xf0104fd9
f010238e:	e8 0d dd ff ff       	call   f01000a0 <_panic>
f0102393:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102399:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f010239f:	75 c6                	jne    f0102367 <mem_init+0x12e4>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01023a1:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01023a6:	89 d8                	mov    %ebx,%eax
f01023a8:	e8 d4 e5 ff ff       	call   f0100981 <check_va2pa>
f01023ad:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023b0:	74 51                	je     f0102403 <mem_init+0x1380>
f01023b2:	68 ec 4e 10 f0       	push   $0xf0104eec
f01023b7:	68 ff 4f 10 f0       	push   $0xf0104fff
f01023bc:	68 5e 03 00 00       	push   $0x35e
f01023c1:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01023c6:	e8 d5 dc ff ff       	call   f01000a0 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01023cb:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01023d0:	72 36                	jb     f0102408 <mem_init+0x1385>
f01023d2:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01023d7:	76 07                	jbe    f01023e0 <mem_init+0x135d>
f01023d9:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01023de:	75 28                	jne    f0102408 <mem_init+0x1385>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f01023e0:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f01023e4:	0f 85 83 00 00 00    	jne    f010246d <mem_init+0x13ea>
f01023ea:	68 9f 52 10 f0       	push   $0xf010529f
f01023ef:	68 ff 4f 10 f0       	push   $0xf0104fff
f01023f4:	68 67 03 00 00       	push   $0x367
f01023f9:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01023fe:	e8 9d dc ff ff       	call   f01000a0 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102403:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102408:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010240d:	76 3f                	jbe    f010244e <mem_init+0x13cb>
				assert(pgdir[i] & PTE_P);
f010240f:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102412:	f6 c2 01             	test   $0x1,%dl
f0102415:	75 19                	jne    f0102430 <mem_init+0x13ad>
f0102417:	68 9f 52 10 f0       	push   $0xf010529f
f010241c:	68 ff 4f 10 f0       	push   $0xf0104fff
f0102421:	68 6b 03 00 00       	push   $0x36b
f0102426:	68 d9 4f 10 f0       	push   $0xf0104fd9
f010242b:	e8 70 dc ff ff       	call   f01000a0 <_panic>
				assert(pgdir[i] & PTE_W);
f0102430:	f6 c2 02             	test   $0x2,%dl
f0102433:	75 38                	jne    f010246d <mem_init+0x13ea>
f0102435:	68 b0 52 10 f0       	push   $0xf01052b0
f010243a:	68 ff 4f 10 f0       	push   $0xf0104fff
f010243f:	68 6c 03 00 00       	push   $0x36c
f0102444:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0102449:	e8 52 dc ff ff       	call   f01000a0 <_panic>
			} else
				assert(pgdir[i] == 0);
f010244e:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102452:	74 19                	je     f010246d <mem_init+0x13ea>
f0102454:	68 c1 52 10 f0       	push   $0xf01052c1
f0102459:	68 ff 4f 10 f0       	push   $0xf0104fff
f010245e:	68 6e 03 00 00       	push   $0x36e
f0102463:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0102468:	e8 33 dc ff ff       	call   f01000a0 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010246d:	83 c0 01             	add    $0x1,%eax
f0102470:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102475:	0f 86 50 ff ff ff    	jbe    f01023cb <mem_init+0x1348>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010247b:	83 ec 0c             	sub    $0xc,%esp
f010247e:	68 1c 4f 10 f0       	push   $0xf0104f1c
f0102483:	e8 61 0a 00 00       	call   f0102ee9 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102488:	a1 08 9f 17 f0       	mov    0xf0179f08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010248d:	83 c4 10             	add    $0x10,%esp
f0102490:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102495:	77 15                	ja     f01024ac <mem_init+0x1429>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102497:	50                   	push   %eax
f0102498:	68 98 49 10 f0       	push   $0xf0104998
f010249d:	68 fc 00 00 00       	push   $0xfc
f01024a2:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01024a7:	e8 f4 db ff ff       	call   f01000a0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01024ac:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01024b1:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01024b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01024b9:	e8 27 e5 ff ff       	call   f01009e5 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01024be:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f01024c1:	83 e0 f3             	and    $0xfffffff3,%eax
f01024c4:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01024c9:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01024cc:	83 ec 0c             	sub    $0xc,%esp
f01024cf:	6a 00                	push   $0x0
f01024d1:	e8 6f e8 ff ff       	call   f0100d45 <page_alloc>
f01024d6:	89 c3                	mov    %eax,%ebx
f01024d8:	83 c4 10             	add    $0x10,%esp
f01024db:	85 c0                	test   %eax,%eax
f01024dd:	75 19                	jne    f01024f8 <mem_init+0x1475>
f01024df:	68 bd 50 10 f0       	push   $0xf01050bd
f01024e4:	68 ff 4f 10 f0       	push   $0xf0104fff
f01024e9:	68 2d 04 00 00       	push   $0x42d
f01024ee:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01024f3:	e8 a8 db ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01024f8:	83 ec 0c             	sub    $0xc,%esp
f01024fb:	6a 00                	push   $0x0
f01024fd:	e8 43 e8 ff ff       	call   f0100d45 <page_alloc>
f0102502:	89 c7                	mov    %eax,%edi
f0102504:	83 c4 10             	add    $0x10,%esp
f0102507:	85 c0                	test   %eax,%eax
f0102509:	75 19                	jne    f0102524 <mem_init+0x14a1>
f010250b:	68 d3 50 10 f0       	push   $0xf01050d3
f0102510:	68 ff 4f 10 f0       	push   $0xf0104fff
f0102515:	68 2e 04 00 00       	push   $0x42e
f010251a:	68 d9 4f 10 f0       	push   $0xf0104fd9
f010251f:	e8 7c db ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f0102524:	83 ec 0c             	sub    $0xc,%esp
f0102527:	6a 00                	push   $0x0
f0102529:	e8 17 e8 ff ff       	call   f0100d45 <page_alloc>
f010252e:	89 c6                	mov    %eax,%esi
f0102530:	83 c4 10             	add    $0x10,%esp
f0102533:	85 c0                	test   %eax,%eax
f0102535:	75 19                	jne    f0102550 <mem_init+0x14cd>
f0102537:	68 e9 50 10 f0       	push   $0xf01050e9
f010253c:	68 ff 4f 10 f0       	push   $0xf0104fff
f0102541:	68 2f 04 00 00       	push   $0x42f
f0102546:	68 d9 4f 10 f0       	push   $0xf0104fd9
f010254b:	e8 50 db ff ff       	call   f01000a0 <_panic>
	page_free(pp0);
f0102550:	83 ec 0c             	sub    $0xc,%esp
f0102553:	53                   	push   %ebx
f0102554:	e8 63 e8 ff ff       	call   f0100dbc <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102559:	89 f8                	mov    %edi,%eax
f010255b:	2b 05 0c 9f 17 f0    	sub    0xf0179f0c,%eax
f0102561:	c1 f8 03             	sar    $0x3,%eax
f0102564:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102567:	89 c2                	mov    %eax,%edx
f0102569:	c1 ea 0c             	shr    $0xc,%edx
f010256c:	83 c4 10             	add    $0x10,%esp
f010256f:	3b 15 04 9f 17 f0    	cmp    0xf0179f04,%edx
f0102575:	72 12                	jb     f0102589 <mem_init+0x1506>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102577:	50                   	push   %eax
f0102578:	68 08 48 10 f0       	push   $0xf0104808
f010257d:	6a 56                	push   $0x56
f010257f:	68 e5 4f 10 f0       	push   $0xf0104fe5
f0102584:	e8 17 db ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102589:	83 ec 04             	sub    $0x4,%esp
f010258c:	68 00 10 00 00       	push   $0x1000
f0102591:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102593:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102598:	50                   	push   %eax
f0102599:	e8 22 18 00 00       	call   f0103dc0 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010259e:	89 f0                	mov    %esi,%eax
f01025a0:	2b 05 0c 9f 17 f0    	sub    0xf0179f0c,%eax
f01025a6:	c1 f8 03             	sar    $0x3,%eax
f01025a9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025ac:	89 c2                	mov    %eax,%edx
f01025ae:	c1 ea 0c             	shr    $0xc,%edx
f01025b1:	83 c4 10             	add    $0x10,%esp
f01025b4:	3b 15 04 9f 17 f0    	cmp    0xf0179f04,%edx
f01025ba:	72 12                	jb     f01025ce <mem_init+0x154b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025bc:	50                   	push   %eax
f01025bd:	68 08 48 10 f0       	push   $0xf0104808
f01025c2:	6a 56                	push   $0x56
f01025c4:	68 e5 4f 10 f0       	push   $0xf0104fe5
f01025c9:	e8 d2 da ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01025ce:	83 ec 04             	sub    $0x4,%esp
f01025d1:	68 00 10 00 00       	push   $0x1000
f01025d6:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f01025d8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01025dd:	50                   	push   %eax
f01025de:	e8 dd 17 00 00       	call   f0103dc0 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01025e3:	6a 02                	push   $0x2
f01025e5:	68 00 10 00 00       	push   $0x1000
f01025ea:	57                   	push   %edi
f01025eb:	ff 35 08 9f 17 f0    	pushl  0xf0179f08
f01025f1:	e8 25 ea ff ff       	call   f010101b <page_insert>
	assert(pp1->pp_ref == 1);
f01025f6:	83 c4 20             	add    $0x20,%esp
f01025f9:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01025fe:	74 19                	je     f0102619 <mem_init+0x1596>
f0102600:	68 ba 51 10 f0       	push   $0xf01051ba
f0102605:	68 ff 4f 10 f0       	push   $0xf0104fff
f010260a:	68 34 04 00 00       	push   $0x434
f010260f:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0102614:	e8 87 da ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102619:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102620:	01 01 01 
f0102623:	74 19                	je     f010263e <mem_init+0x15bb>
f0102625:	68 3c 4f 10 f0       	push   $0xf0104f3c
f010262a:	68 ff 4f 10 f0       	push   $0xf0104fff
f010262f:	68 35 04 00 00       	push   $0x435
f0102634:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0102639:	e8 62 da ff ff       	call   f01000a0 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010263e:	6a 02                	push   $0x2
f0102640:	68 00 10 00 00       	push   $0x1000
f0102645:	56                   	push   %esi
f0102646:	ff 35 08 9f 17 f0    	pushl  0xf0179f08
f010264c:	e8 ca e9 ff ff       	call   f010101b <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102651:	83 c4 10             	add    $0x10,%esp
f0102654:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010265b:	02 02 02 
f010265e:	74 19                	je     f0102679 <mem_init+0x15f6>
f0102660:	68 60 4f 10 f0       	push   $0xf0104f60
f0102665:	68 ff 4f 10 f0       	push   $0xf0104fff
f010266a:	68 37 04 00 00       	push   $0x437
f010266f:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0102674:	e8 27 da ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0102679:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010267e:	74 19                	je     f0102699 <mem_init+0x1616>
f0102680:	68 dc 51 10 f0       	push   $0xf01051dc
f0102685:	68 ff 4f 10 f0       	push   $0xf0104fff
f010268a:	68 38 04 00 00       	push   $0x438
f010268f:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0102694:	e8 07 da ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f0102699:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010269e:	74 19                	je     f01026b9 <mem_init+0x1636>
f01026a0:	68 46 52 10 f0       	push   $0xf0105246
f01026a5:	68 ff 4f 10 f0       	push   $0xf0104fff
f01026aa:	68 39 04 00 00       	push   $0x439
f01026af:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01026b4:	e8 e7 d9 ff ff       	call   f01000a0 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01026b9:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01026c0:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01026c3:	89 f0                	mov    %esi,%eax
f01026c5:	2b 05 0c 9f 17 f0    	sub    0xf0179f0c,%eax
f01026cb:	c1 f8 03             	sar    $0x3,%eax
f01026ce:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026d1:	89 c2                	mov    %eax,%edx
f01026d3:	c1 ea 0c             	shr    $0xc,%edx
f01026d6:	3b 15 04 9f 17 f0    	cmp    0xf0179f04,%edx
f01026dc:	72 12                	jb     f01026f0 <mem_init+0x166d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026de:	50                   	push   %eax
f01026df:	68 08 48 10 f0       	push   $0xf0104808
f01026e4:	6a 56                	push   $0x56
f01026e6:	68 e5 4f 10 f0       	push   $0xf0104fe5
f01026eb:	e8 b0 d9 ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01026f0:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01026f7:	03 03 03 
f01026fa:	74 19                	je     f0102715 <mem_init+0x1692>
f01026fc:	68 84 4f 10 f0       	push   $0xf0104f84
f0102701:	68 ff 4f 10 f0       	push   $0xf0104fff
f0102706:	68 3b 04 00 00       	push   $0x43b
f010270b:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0102710:	e8 8b d9 ff ff       	call   f01000a0 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102715:	83 ec 08             	sub    $0x8,%esp
f0102718:	68 00 10 00 00       	push   $0x1000
f010271d:	ff 35 08 9f 17 f0    	pushl  0xf0179f08
f0102723:	e8 b1 e8 ff ff       	call   f0100fd9 <page_remove>
	assert(pp2->pp_ref == 0);
f0102728:	83 c4 10             	add    $0x10,%esp
f010272b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102730:	74 19                	je     f010274b <mem_init+0x16c8>
f0102732:	68 14 52 10 f0       	push   $0xf0105214
f0102737:	68 ff 4f 10 f0       	push   $0xf0104fff
f010273c:	68 3d 04 00 00       	push   $0x43d
f0102741:	68 d9 4f 10 f0       	push   $0xf0104fd9
f0102746:	e8 55 d9 ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010274b:	8b 0d 08 9f 17 f0    	mov    0xf0179f08,%ecx
f0102751:	8b 11                	mov    (%ecx),%edx
f0102753:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102759:	89 d8                	mov    %ebx,%eax
f010275b:	2b 05 0c 9f 17 f0    	sub    0xf0179f0c,%eax
f0102761:	c1 f8 03             	sar    $0x3,%eax
f0102764:	c1 e0 0c             	shl    $0xc,%eax
f0102767:	39 c2                	cmp    %eax,%edx
f0102769:	74 19                	je     f0102784 <mem_init+0x1701>
f010276b:	68 94 4a 10 f0       	push   $0xf0104a94
f0102770:	68 ff 4f 10 f0       	push   $0xf0104fff
f0102775:	68 40 04 00 00       	push   $0x440
f010277a:	68 d9 4f 10 f0       	push   $0xf0104fd9
f010277f:	e8 1c d9 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f0102784:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010278a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010278f:	74 19                	je     f01027aa <mem_init+0x1727>
f0102791:	68 cb 51 10 f0       	push   $0xf01051cb
f0102796:	68 ff 4f 10 f0       	push   $0xf0104fff
f010279b:	68 42 04 00 00       	push   $0x442
f01027a0:	68 d9 4f 10 f0       	push   $0xf0104fd9
f01027a5:	e8 f6 d8 ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f01027aa:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01027b0:	83 ec 0c             	sub    $0xc,%esp
f01027b3:	53                   	push   %ebx
f01027b4:	e8 03 e6 ff ff       	call   f0100dbc <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01027b9:	c7 04 24 b0 4f 10 f0 	movl   $0xf0104fb0,(%esp)
f01027c0:	e8 24 07 00 00       	call   f0102ee9 <cprintf>
f01027c5:	83 c4 10             	add    $0x10,%esp
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01027c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01027cb:	5b                   	pop    %ebx
f01027cc:	5e                   	pop    %esi
f01027cd:	5f                   	pop    %edi
f01027ce:	5d                   	pop    %ebp
f01027cf:	c3                   	ret    

f01027d0 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01027d0:	55                   	push   %ebp
f01027d1:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01027d3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01027d6:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01027d9:	5d                   	pop    %ebp
f01027da:	c3                   	ret    

f01027db <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01027db:	55                   	push   %ebp
f01027dc:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.

	return 0;
}
f01027de:	b8 00 00 00 00       	mov    $0x0,%eax
f01027e3:	5d                   	pop    %ebp
f01027e4:	c3                   	ret    

f01027e5 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01027e5:	55                   	push   %ebp
f01027e6:	89 e5                	mov    %esp,%ebp
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
		cprintf("[%08x] user_mem_check assertion failure for "
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
	}
}
f01027e8:	5d                   	pop    %ebp
f01027e9:	c3                   	ret    

f01027ea <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01027ea:	55                   	push   %ebp
f01027eb:	89 e5                	mov    %esp,%ebp
f01027ed:	57                   	push   %edi
f01027ee:	56                   	push   %esi
f01027ef:	53                   	push   %ebx
f01027f0:	83 ec 0c             	sub    $0xc,%esp
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	va = ROUNDDOWN(va,PGSIZE);
f01027f3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01027f9:	89 d6                	mov    %edx,%esi
	void * tmp = va+len;
	if(tmp < va)
f01027fb:	01 ca                	add    %ecx,%edx
f01027fd:	73 17                	jae    f0102816 <region_alloc+0x2c>
		panic("va+len is greater than 4GB.");
f01027ff:	83 ec 04             	sub    $0x4,%esp
f0102802:	68 cf 52 10 f0       	push   $0xf01052cf
f0102807:	68 23 01 00 00       	push   $0x123
f010280c:	68 eb 52 10 f0       	push   $0xf01052eb
f0102811:	e8 8a d8 ff ff       	call   f01000a0 <_panic>
f0102816:	89 c7                	mov    %eax,%edi
	tmp = ROUNDUP(va+len,PGSIZE);
	len = ROUNDUP(len,PGSIZE);
f0102818:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
	int numberOfPages = len/PGSIZE;
f010281e:	c1 eb 0c             	shr    $0xc,%ebx
	while(numberOfPages)
f0102821:	eb 59                	jmp    f010287c <region_alloc+0x92>
	{
		struct PageInfo * p = page_alloc(0);
f0102823:	83 ec 0c             	sub    $0xc,%esp
f0102826:	6a 00                	push   $0x0
f0102828:	e8 18 e5 ff ff       	call   f0100d45 <page_alloc>
		if(p == NULL)
f010282d:	83 c4 10             	add    $0x10,%esp
f0102830:	85 c0                	test   %eax,%eax
f0102832:	75 17                	jne    f010284b <region_alloc+0x61>
			panic("Out of Memory");
f0102834:	83 ec 04             	sub    $0x4,%esp
f0102837:	68 f6 52 10 f0       	push   $0xf01052f6
f010283c:	68 2b 01 00 00       	push   $0x12b
f0102841:	68 eb 52 10 f0       	push   $0xf01052eb
f0102846:	e8 55 d8 ff ff       	call   f01000a0 <_panic>
		int er = page_insert(e->env_pgdir,p,va, PTE_U | PTE_W);
f010284b:	6a 06                	push   $0x6
f010284d:	56                   	push   %esi
f010284e:	50                   	push   %eax
f010284f:	ff 77 5c             	pushl  0x5c(%edi)
f0102852:	e8 c4 e7 ff ff       	call   f010101b <page_insert>
		
		if(er != 0)
f0102857:	83 c4 10             	add    $0x10,%esp
f010285a:	85 c0                	test   %eax,%eax
f010285c:	74 15                	je     f0102873 <region_alloc+0x89>
			panic("Page insert error:%e",er);
f010285e:	50                   	push   %eax
f010285f:	68 04 53 10 f0       	push   $0xf0105304
f0102864:	68 2f 01 00 00       	push   $0x12f
f0102869:	68 eb 52 10 f0       	push   $0xf01052eb
f010286e:	e8 2d d8 ff ff       	call   f01000a0 <_panic>
		
		va += PGSIZE;
f0102873:	81 c6 00 10 00 00    	add    $0x1000,%esi
		numberOfPages--;
f0102879:	83 eb 01             	sub    $0x1,%ebx
	if(tmp < va)
		panic("va+len is greater than 4GB.");
	tmp = ROUNDUP(va+len,PGSIZE);
	len = ROUNDUP(len,PGSIZE);
	int numberOfPages = len/PGSIZE;
	while(numberOfPages)
f010287c:	85 db                	test   %ebx,%ebx
f010287e:	75 a3                	jne    f0102823 <region_alloc+0x39>
		va += PGSIZE;
		numberOfPages--;
	}
	
	
}
f0102880:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102883:	5b                   	pop    %ebx
f0102884:	5e                   	pop    %esi
f0102885:	5f                   	pop    %edi
f0102886:	5d                   	pop    %ebp
f0102887:	c3                   	ret    

f0102888 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102888:	55                   	push   %ebp
f0102889:	89 e5                	mov    %esp,%ebp
f010288b:	8b 55 08             	mov    0x8(%ebp),%edx
f010288e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102891:	85 d2                	test   %edx,%edx
f0102893:	75 11                	jne    f01028a6 <envid2env+0x1e>
		*env_store = curenv;
f0102895:	a1 24 92 17 f0       	mov    0xf0179224,%eax
f010289a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010289d:	89 01                	mov    %eax,(%ecx)
		return 0;
f010289f:	b8 00 00 00 00       	mov    $0x0,%eax
f01028a4:	eb 5e                	jmp    f0102904 <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01028a6:	89 d0                	mov    %edx,%eax
f01028a8:	25 ff 03 00 00       	and    $0x3ff,%eax
f01028ad:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01028b0:	c1 e0 05             	shl    $0x5,%eax
f01028b3:	03 05 28 92 17 f0    	add    0xf0179228,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01028b9:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f01028bd:	74 05                	je     f01028c4 <envid2env+0x3c>
f01028bf:	39 50 48             	cmp    %edx,0x48(%eax)
f01028c2:	74 10                	je     f01028d4 <envid2env+0x4c>
		*env_store = 0;
f01028c4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01028c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01028cd:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01028d2:	eb 30                	jmp    f0102904 <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01028d4:	84 c9                	test   %cl,%cl
f01028d6:	74 22                	je     f01028fa <envid2env+0x72>
f01028d8:	8b 15 24 92 17 f0    	mov    0xf0179224,%edx
f01028de:	39 d0                	cmp    %edx,%eax
f01028e0:	74 18                	je     f01028fa <envid2env+0x72>
f01028e2:	8b 4a 48             	mov    0x48(%edx),%ecx
f01028e5:	39 48 4c             	cmp    %ecx,0x4c(%eax)
f01028e8:	74 10                	je     f01028fa <envid2env+0x72>
		*env_store = 0;
f01028ea:	8b 45 0c             	mov    0xc(%ebp),%eax
f01028ed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01028f3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01028f8:	eb 0a                	jmp    f0102904 <envid2env+0x7c>
	}

	*env_store = e;
f01028fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01028fd:	89 01                	mov    %eax,(%ecx)
	return 0;
f01028ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102904:	5d                   	pop    %ebp
f0102905:	c3                   	ret    

f0102906 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102906:	55                   	push   %ebp
f0102907:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102909:	b8 00 a3 11 f0       	mov    $0xf011a300,%eax
f010290e:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102911:	b8 23 00 00 00       	mov    $0x23,%eax
f0102916:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102918:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f010291a:	b0 10                	mov    $0x10,%al
f010291c:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f010291e:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102920:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102922:	ea 29 29 10 f0 08 00 	ljmp   $0x8,$0xf0102929
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102929:	b0 00                	mov    $0x0,%al
f010292b:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f010292e:	5d                   	pop    %ebp
f010292f:	c3                   	ret    

f0102930 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102930:	55                   	push   %ebp
f0102931:	89 e5                	mov    %esp,%ebp
f0102933:	56                   	push   %esi
f0102934:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = NENV-1;i > -1;i--)    //start from 1023 and go till 0.
	{
		envs[i].env_id = 0;
f0102935:	8b 35 28 92 17 f0    	mov    0xf0179228,%esi
f010293b:	8b 15 2c 92 17 f0    	mov    0xf017922c,%edx
f0102941:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f0102947:	8d 5e a0             	lea    -0x60(%esi),%ebx
f010294a:	89 c1                	mov    %eax,%ecx
f010294c:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list; 
f0102953:	89 50 44             	mov    %edx,0x44(%eax)
f0102956:	83 e8 60             	sub    $0x60,%eax
		env_free_list = &envs[i];
f0102959:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = NENV-1;i > -1;i--)    //start from 1023 and go till 0.
f010295b:	39 d8                	cmp    %ebx,%eax
f010295d:	75 eb                	jne    f010294a <env_init+0x1a>
f010295f:	89 35 2c 92 17 f0    	mov    %esi,0xf017922c
		envs[i].env_link = env_free_list; 
		env_free_list = &envs[i];
		
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0102965:	e8 9c ff ff ff       	call   f0102906 <env_init_percpu>
	
}
f010296a:	5b                   	pop    %ebx
f010296b:	5e                   	pop    %esi
f010296c:	5d                   	pop    %ebp
f010296d:	c3                   	ret    

f010296e <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010296e:	55                   	push   %ebp
f010296f:	89 e5                	mov    %esp,%ebp
f0102971:	53                   	push   %ebx
f0102972:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102975:	8b 1d 2c 92 17 f0    	mov    0xf017922c,%ebx
f010297b:	85 db                	test   %ebx,%ebx
f010297d:	0f 84 62 01 00 00    	je     f0102ae5 <env_alloc+0x177>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102983:	83 ec 0c             	sub    $0xc,%esp
f0102986:	6a 01                	push   $0x1
f0102988:	e8 b8 e3 ff ff       	call   f0100d45 <page_alloc>
f010298d:	83 c4 10             	add    $0x10,%esp
f0102990:	85 c0                	test   %eax,%eax
f0102992:	0f 84 54 01 00 00    	je     f0102aec <env_alloc+0x17e>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;		//almost forgot..!!
f0102998:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f010299d:	2b 05 0c 9f 17 f0    	sub    0xf0179f0c,%eax
f01029a3:	c1 f8 03             	sar    $0x3,%eax
f01029a6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029a9:	89 c2                	mov    %eax,%edx
f01029ab:	c1 ea 0c             	shr    $0xc,%edx
f01029ae:	3b 15 04 9f 17 f0    	cmp    0xf0179f04,%edx
f01029b4:	72 12                	jb     f01029c8 <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029b6:	50                   	push   %eax
f01029b7:	68 08 48 10 f0       	push   $0xf0104808
f01029bc:	6a 56                	push   $0x56
f01029be:	68 e5 4f 10 f0       	push   $0xf0104fe5
f01029c3:	e8 d8 d6 ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f01029c8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01029cd:	89 43 5c             	mov    %eax,0x5c(%ebx)
	e->env_pgdir = (pde_t *)page2kva(p);   //I guess we are done here.
f01029d0:	b8 ec 0e 00 00       	mov    $0xeec,%eax
	for(i = PDX(UTOP);i <= PDX(0xfffff000);i++)
	{
		e->env_pgdir[i] = kern_pgdir[i];
f01029d5:	8b 15 08 9f 17 f0    	mov    0xf0179f08,%edx
f01029db:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f01029de:	8b 53 5c             	mov    0x5c(%ebx),%edx
f01029e1:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f01029e4:	83 c0 04             	add    $0x4,%eax
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;		//almost forgot..!!
	e->env_pgdir = (pde_t *)page2kva(p);   //I guess we are done here.
	for(i = PDX(UTOP);i <= PDX(0xfffff000);i++)
f01029e7:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01029ec:	75 e7                	jne    f01029d5 <env_alloc+0x67>
f01029ee:	66 b8 00 00          	mov    $0x0,%ax
	{
		e->env_pgdir[i] = kern_pgdir[i];
	}
	for(i=0;i<PDX(UTOP);i++)
	{
		e->env_pgdir[i] = 0;
f01029f2:	8b 53 5c             	mov    0x5c(%ebx),%edx
f01029f5:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f01029fc:	83 c0 04             	add    $0x4,%eax
	e->env_pgdir = (pde_t *)page2kva(p);   //I guess we are done here.
	for(i = PDX(UTOP);i <= PDX(0xfffff000);i++)
	{
		e->env_pgdir[i] = kern_pgdir[i];
	}
	for(i=0;i<PDX(UTOP);i++)
f01029ff:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f0102a04:	75 ec                	jne    f01029f2 <env_alloc+0x84>
		e->env_pgdir[i] = 0;
	}
	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102a06:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a09:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a0e:	77 15                	ja     f0102a25 <env_alloc+0xb7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a10:	50                   	push   %eax
f0102a11:	68 98 49 10 f0       	push   $0xf0104998
f0102a16:	68 cb 00 00 00       	push   $0xcb
f0102a1b:	68 eb 52 10 f0       	push   $0xf01052eb
f0102a20:	e8 7b d6 ff ff       	call   f01000a0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102a25:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102a2b:	83 ca 05             	or     $0x5,%edx
f0102a2e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102a34:	8b 43 48             	mov    0x48(%ebx),%eax
f0102a37:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102a3c:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102a41:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a46:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102a49:	89 da                	mov    %ebx,%edx
f0102a4b:	2b 15 28 92 17 f0    	sub    0xf0179228,%edx
f0102a51:	c1 fa 05             	sar    $0x5,%edx
f0102a54:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102a5a:	09 d0                	or     %edx,%eax
f0102a5c:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a62:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102a65:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102a6c:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102a73:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102a7a:	83 ec 04             	sub    $0x4,%esp
f0102a7d:	6a 44                	push   $0x44
f0102a7f:	6a 00                	push   $0x0
f0102a81:	53                   	push   %ebx
f0102a82:	e8 39 13 00 00       	call   f0103dc0 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102a87:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102a8d:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102a93:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102a99:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102aa0:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102aa6:	8b 43 44             	mov    0x44(%ebx),%eax
f0102aa9:	a3 2c 92 17 f0       	mov    %eax,0xf017922c
	*newenv_store = e;
f0102aae:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ab1:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102ab3:	8b 53 48             	mov    0x48(%ebx),%edx
f0102ab6:	a1 24 92 17 f0       	mov    0xf0179224,%eax
f0102abb:	83 c4 10             	add    $0x10,%esp
f0102abe:	85 c0                	test   %eax,%eax
f0102ac0:	74 05                	je     f0102ac7 <env_alloc+0x159>
f0102ac2:	8b 40 48             	mov    0x48(%eax),%eax
f0102ac5:	eb 05                	jmp    f0102acc <env_alloc+0x15e>
f0102ac7:	b8 00 00 00 00       	mov    $0x0,%eax
f0102acc:	83 ec 04             	sub    $0x4,%esp
f0102acf:	52                   	push   %edx
f0102ad0:	50                   	push   %eax
f0102ad1:	68 19 53 10 f0       	push   $0xf0105319
f0102ad6:	e8 0e 04 00 00       	call   f0102ee9 <cprintf>
	return 0;
f0102adb:	83 c4 10             	add    $0x10,%esp
f0102ade:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ae3:	eb 0c                	jmp    f0102af1 <env_alloc+0x183>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102ae5:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102aea:	eb 05                	jmp    f0102af1 <env_alloc+0x183>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102aec:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102af1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102af4:	c9                   	leave  
f0102af5:	c3                   	ret    

f0102af6 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102af6:	55                   	push   %ebp
f0102af7:	89 e5                	mov    %esp,%ebp
f0102af9:	57                   	push   %edi
f0102afa:	56                   	push   %esi
f0102afb:	53                   	push   %ebx
f0102afc:	83 ec 34             	sub    $0x34,%esp
f0102aff:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e;
	int result = env_alloc(&e, 0);
f0102b02:	6a 00                	push   $0x0
f0102b04:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102b07:	50                   	push   %eax
f0102b08:	e8 61 fe ff ff       	call   f010296e <env_alloc>
	if(result != 0)
f0102b0d:	83 c4 10             	add    $0x10,%esp
f0102b10:	85 c0                	test   %eax,%eax
f0102b12:	74 15                	je     f0102b29 <env_create+0x33>
		panic("env_create:%e",result);
f0102b14:	50                   	push   %eax
f0102b15:	68 2e 53 10 f0       	push   $0xf010532e
f0102b1a:	68 9e 01 00 00       	push   $0x19e
f0102b1f:	68 eb 52 10 f0       	push   $0xf01052eb
f0102b24:	e8 77 d5 ff ff       	call   f01000a0 <_panic>
	e->env_type = type;
f0102b29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102b2c:	89 c1                	mov    %eax,%ecx
f0102b2e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102b31:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b34:	89 41 50             	mov    %eax,0x50(%ecx)

	// LAB 3: Your code here.
	//
	struct Proghdr *ph, *eph;
	struct Elf * elf = (struct Elf *)binary;
	if(elf->e_magic != ELF_MAGIC)			//check for a valid ELF.
f0102b37:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102b3d:	74 17                	je     f0102b56 <env_create+0x60>
		panic("Not a valid ELF");
f0102b3f:	83 ec 04             	sub    $0x4,%esp
f0102b42:	68 3c 53 10 f0       	push   $0xf010533c
f0102b47:	68 72 01 00 00       	push   $0x172
f0102b4c:	68 eb 52 10 f0       	push   $0xf01052eb
f0102b51:	e8 4a d5 ff ff       	call   f01000a0 <_panic>
	e->env_tf.tf_eip = (uintptr_t)elf->e_entry;   //Set the trapframe instrtuction pointer eip to entry function of the this ELF binary.
f0102b56:	8b 47 18             	mov    0x18(%edi),%eax
f0102b59:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102b5c:	89 46 30             	mov    %eax,0x30(%esi)
	
	lcr3(PADDR(e->env_pgdir));				//change the address space to this env's pg directory,
f0102b5f:	8b 46 5c             	mov    0x5c(%esi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b62:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b67:	77 15                	ja     f0102b7e <env_create+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b69:	50                   	push   %eax
f0102b6a:	68 98 49 10 f0       	push   $0xf0104998
f0102b6f:	68 75 01 00 00       	push   $0x175
f0102b74:	68 eb 52 10 f0       	push   $0xf01052eb
f0102b79:	e8 22 d5 ff ff       	call   f01000a0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102b7e:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102b83:	0f 22 d8             	mov    %eax,%cr3
	
	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);   //Imitate the Bootloaders code.
f0102b86:	89 fb                	mov    %edi,%ebx
f0102b88:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;	
f0102b8b:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102b8f:	c1 e6 05             	shl    $0x5,%esi
f0102b92:	01 de                	add    %ebx,%esi
f0102b94:	eb 62                	jmp    f0102bf8 <env_create+0x102>
	for (; ph < eph; ph++)
	{
		if(ph->p_type == ELF_PROG_LOAD )
f0102b96:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102b99:	75 5a                	jne    f0102bf5 <env_create+0xff>
		{
			if(ph->p_filesz <= ph->p_memsz)
f0102b9b:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102b9e:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0102ba1:	77 3b                	ja     f0102bde <env_create+0xe8>
			{
				region_alloc(e,(void *)ph->p_va,ph->p_memsz);
f0102ba3:	8b 53 08             	mov    0x8(%ebx),%edx
f0102ba6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ba9:	e8 3c fc ff ff       	call   f01027ea <region_alloc>
				
				memcpy((void *)ph->p_va,(void *)(binary + ph->p_offset), ph->p_filesz);   //Equivalent to readseg function in bootloader. 
f0102bae:	83 ec 04             	sub    $0x4,%esp
f0102bb1:	ff 73 10             	pushl  0x10(%ebx)
f0102bb4:	89 f8                	mov    %edi,%eax
f0102bb6:	03 43 04             	add    0x4(%ebx),%eax
f0102bb9:	50                   	push   %eax
f0102bba:	ff 73 08             	pushl  0x8(%ebx)
f0102bbd:	e8 b3 12 00 00       	call   f0103e75 <memcpy>
																						  
				memset((void *)(ph->p_va+ph->p_filesz),0,(ph->p_memsz - ph->p_filesz));
f0102bc2:	8b 43 10             	mov    0x10(%ebx),%eax
f0102bc5:	83 c4 0c             	add    $0xc,%esp
f0102bc8:	8b 53 14             	mov    0x14(%ebx),%edx
f0102bcb:	29 c2                	sub    %eax,%edx
f0102bcd:	52                   	push   %edx
f0102bce:	6a 00                	push   $0x0
f0102bd0:	03 43 08             	add    0x8(%ebx),%eax
f0102bd3:	50                   	push   %eax
f0102bd4:	e8 e7 11 00 00       	call   f0103dc0 <memset>
f0102bd9:	83 c4 10             	add    $0x10,%esp
f0102bdc:	eb 17                	jmp    f0102bf5 <env_create+0xff>
			}
			else
				panic("Buggy Binary.");
f0102bde:	83 ec 04             	sub    $0x4,%esp
f0102be1:	68 4c 53 10 f0       	push   $0xf010534c
f0102be6:	68 86 01 00 00       	push   $0x186
f0102beb:	68 eb 52 10 f0       	push   $0xf01052eb
f0102bf0:	e8 ab d4 ff ff       	call   f01000a0 <_panic>
	
	lcr3(PADDR(e->env_pgdir));				//change the address space to this env's pg directory,
	
	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);   //Imitate the Bootloaders code.
	eph = ph + elf->e_phnum;	
	for (; ph < eph; ph++)
f0102bf5:	83 c3 20             	add    $0x20,%ebx
f0102bf8:	39 de                	cmp    %ebx,%esi
f0102bfa:	77 9a                	ja     f0102b96 <env_create+0xa0>
	}
	
	
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	region_alloc(e,(void *)( USTACKTOP - PGSIZE), PGSIZE);
f0102bfc:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102c01:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102c06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c09:	e8 dc fb ff ff       	call   f01027ea <region_alloc>
	if(result != 0)
		panic("env_create:%e",result);
	e->env_type = type;
	load_icode(e, binary);
	
}
f0102c0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c11:	5b                   	pop    %ebx
f0102c12:	5e                   	pop    %esi
f0102c13:	5f                   	pop    %edi
f0102c14:	5d                   	pop    %ebp
f0102c15:	c3                   	ret    

f0102c16 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102c16:	55                   	push   %ebp
f0102c17:	89 e5                	mov    %esp,%ebp
f0102c19:	57                   	push   %edi
f0102c1a:	56                   	push   %esi
f0102c1b:	53                   	push   %ebx
f0102c1c:	83 ec 1c             	sub    $0x1c,%esp
f0102c1f:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102c22:	8b 15 24 92 17 f0    	mov    0xf0179224,%edx
f0102c28:	39 d7                	cmp    %edx,%edi
f0102c2a:	75 29                	jne    f0102c55 <env_free+0x3f>
		lcr3(PADDR(kern_pgdir));
f0102c2c:	a1 08 9f 17 f0       	mov    0xf0179f08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c31:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c36:	77 15                	ja     f0102c4d <env_free+0x37>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c38:	50                   	push   %eax
f0102c39:	68 98 49 10 f0       	push   $0xf0104998
f0102c3e:	68 b2 01 00 00       	push   $0x1b2
f0102c43:	68 eb 52 10 f0       	push   $0xf01052eb
f0102c48:	e8 53 d4 ff ff       	call   f01000a0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102c4d:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c52:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102c55:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102c58:	85 d2                	test   %edx,%edx
f0102c5a:	74 05                	je     f0102c61 <env_free+0x4b>
f0102c5c:	8b 42 48             	mov    0x48(%edx),%eax
f0102c5f:	eb 05                	jmp    f0102c66 <env_free+0x50>
f0102c61:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c66:	83 ec 04             	sub    $0x4,%esp
f0102c69:	51                   	push   %ecx
f0102c6a:	50                   	push   %eax
f0102c6b:	68 5a 53 10 f0       	push   $0xf010535a
f0102c70:	e8 74 02 00 00       	call   f0102ee9 <cprintf>
f0102c75:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102c78:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102c7f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102c82:	89 d0                	mov    %edx,%eax
f0102c84:	c1 e0 02             	shl    $0x2,%eax
f0102c87:	89 45 d8             	mov    %eax,-0x28(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102c8a:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102c8d:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102c90:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102c96:	0f 84 a8 00 00 00    	je     f0102d44 <env_free+0x12e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102c9c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ca2:	89 f0                	mov    %esi,%eax
f0102ca4:	c1 e8 0c             	shr    $0xc,%eax
f0102ca7:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102caa:	3b 05 04 9f 17 f0    	cmp    0xf0179f04,%eax
f0102cb0:	72 15                	jb     f0102cc7 <env_free+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cb2:	56                   	push   %esi
f0102cb3:	68 08 48 10 f0       	push   $0xf0104808
f0102cb8:	68 c1 01 00 00       	push   $0x1c1
f0102cbd:	68 eb 52 10 f0       	push   $0xf01052eb
f0102cc2:	e8 d9 d3 ff ff       	call   f01000a0 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102cc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102cca:	c1 e0 16             	shl    $0x16,%eax
f0102ccd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102cd5:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102cdc:	01 
f0102cdd:	74 17                	je     f0102cf6 <env_free+0xe0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102cdf:	83 ec 08             	sub    $0x8,%esp
f0102ce2:	89 d8                	mov    %ebx,%eax
f0102ce4:	c1 e0 0c             	shl    $0xc,%eax
f0102ce7:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102cea:	50                   	push   %eax
f0102ceb:	ff 77 5c             	pushl  0x5c(%edi)
f0102cee:	e8 e6 e2 ff ff       	call   f0100fd9 <page_remove>
f0102cf3:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102cf6:	83 c3 01             	add    $0x1,%ebx
f0102cf9:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102cff:	75 d4                	jne    f0102cd5 <env_free+0xbf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102d01:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102d04:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102d07:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d0e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102d11:	3b 05 04 9f 17 f0    	cmp    0xf0179f04,%eax
f0102d17:	72 14                	jb     f0102d2d <env_free+0x117>
		panic("pa2page called with invalid pa");
f0102d19:	83 ec 04             	sub    $0x4,%esp
f0102d1c:	68 30 49 10 f0       	push   $0xf0104930
f0102d21:	6a 4f                	push   $0x4f
f0102d23:	68 e5 4f 10 f0       	push   $0xf0104fe5
f0102d28:	e8 73 d3 ff ff       	call   f01000a0 <_panic>
		page_decref(pa2page(pa));
f0102d2d:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0102d30:	a1 0c 9f 17 f0       	mov    0xf0179f0c,%eax
f0102d35:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102d38:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102d3b:	50                   	push   %eax
f0102d3c:	e8 b6 e0 ff ff       	call   f0100df7 <page_decref>
f0102d41:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102d44:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102d48:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d4b:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102d50:	0f 85 29 ff ff ff    	jne    f0102c7f <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102d56:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d59:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d5e:	77 15                	ja     f0102d75 <env_free+0x15f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d60:	50                   	push   %eax
f0102d61:	68 98 49 10 f0       	push   $0xf0104998
f0102d66:	68 cf 01 00 00       	push   $0x1cf
f0102d6b:	68 eb 52 10 f0       	push   $0xf01052eb
f0102d70:	e8 2b d3 ff ff       	call   f01000a0 <_panic>
	e->env_pgdir = 0;
f0102d75:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0102d7c:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d81:	c1 e8 0c             	shr    $0xc,%eax
f0102d84:	3b 05 04 9f 17 f0    	cmp    0xf0179f04,%eax
f0102d8a:	72 14                	jb     f0102da0 <env_free+0x18a>
		panic("pa2page called with invalid pa");
f0102d8c:	83 ec 04             	sub    $0x4,%esp
f0102d8f:	68 30 49 10 f0       	push   $0xf0104930
f0102d94:	6a 4f                	push   $0x4f
f0102d96:	68 e5 4f 10 f0       	push   $0xf0104fe5
f0102d9b:	e8 00 d3 ff ff       	call   f01000a0 <_panic>
	page_decref(pa2page(pa));
f0102da0:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0102da3:	8b 15 0c 9f 17 f0    	mov    0xf0179f0c,%edx
f0102da9:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102dac:	50                   	push   %eax
f0102dad:	e8 45 e0 ff ff       	call   f0100df7 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102db2:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102db9:	a1 2c 92 17 f0       	mov    0xf017922c,%eax
f0102dbe:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102dc1:	89 3d 2c 92 17 f0    	mov    %edi,0xf017922c
f0102dc7:	83 c4 10             	add    $0x10,%esp
}
f0102dca:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102dcd:	5b                   	pop    %ebx
f0102dce:	5e                   	pop    %esi
f0102dcf:	5f                   	pop    %edi
f0102dd0:	5d                   	pop    %ebp
f0102dd1:	c3                   	ret    

f0102dd2 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0102dd2:	55                   	push   %ebp
f0102dd3:	89 e5                	mov    %esp,%ebp
f0102dd5:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0102dd8:	ff 75 08             	pushl  0x8(%ebp)
f0102ddb:	e8 36 fe ff ff       	call   f0102c16 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102de0:	c7 04 24 7c 53 10 f0 	movl   $0xf010537c,(%esp)
f0102de7:	e8 fd 00 00 00       	call   f0102ee9 <cprintf>
f0102dec:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0102def:	83 ec 0c             	sub    $0xc,%esp
f0102df2:	6a 00                	push   $0x0
f0102df4:	e8 a0 d9 ff ff       	call   f0100799 <monitor>
f0102df9:	83 c4 10             	add    $0x10,%esp
f0102dfc:	eb f1                	jmp    f0102def <env_destroy+0x1d>

f0102dfe <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102dfe:	55                   	push   %ebp
f0102dff:	89 e5                	mov    %esp,%ebp
f0102e01:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f0102e04:	8b 65 08             	mov    0x8(%ebp),%esp
f0102e07:	61                   	popa   
f0102e08:	07                   	pop    %es
f0102e09:	1f                   	pop    %ds
f0102e0a:	83 c4 08             	add    $0x8,%esp
f0102e0d:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102e0e:	68 70 53 10 f0       	push   $0xf0105370
f0102e13:	68 f7 01 00 00       	push   $0x1f7
f0102e18:	68 eb 52 10 f0       	push   $0xf01052eb
f0102e1d:	e8 7e d2 ff ff       	call   f01000a0 <_panic>

f0102e22 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0102e22:	55                   	push   %ebp
f0102e23:	89 e5                	mov    %esp,%ebp
f0102e25:	83 ec 08             	sub    $0x8,%esp
f0102e28:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv != NULL && curenv != e)
f0102e2b:	8b 15 24 92 17 f0    	mov    0xf0179224,%edx
f0102e31:	39 c2                	cmp    %eax,%edx
f0102e33:	74 11                	je     f0102e46 <env_run+0x24>
f0102e35:	85 d2                	test   %edx,%edx
f0102e37:	74 0d                	je     f0102e46 <env_run+0x24>
	{
		switch(curenv->env_status)
f0102e39:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0102e3d:	75 07                	jne    f0102e46 <env_run+0x24>
		{
			case ENV_RUNNING:
				curenv->env_status = ENV_RUNNABLE;
f0102e3f:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
				break;
		}
	}
	curenv = e;
f0102e46:	a3 24 92 17 f0       	mov    %eax,0xf0179224
	curenv->env_type = ENV_RUNNING;
f0102e4b:	c7 40 50 03 00 00 00 	movl   $0x3,0x50(%eax)
	curenv->env_runs++;
f0102e52:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(e->env_pgdir));
f0102e56:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e59:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102e5f:	77 15                	ja     f0102e76 <env_run+0x54>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e61:	52                   	push   %edx
f0102e62:	68 98 49 10 f0       	push   $0xf0104998
f0102e67:	68 21 02 00 00       	push   $0x221
f0102e6c:	68 eb 52 10 f0       	push   $0xf01052eb
f0102e71:	e8 2a d2 ff ff       	call   f01000a0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102e76:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0102e7c:	0f 22 da             	mov    %edx,%cr3
	env_pop_tf(&e->env_tf);
f0102e7f:	83 ec 0c             	sub    $0xc,%esp
f0102e82:	50                   	push   %eax
f0102e83:	e8 76 ff ff ff       	call   f0102dfe <env_pop_tf>

f0102e88 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102e88:	55                   	push   %ebp
f0102e89:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102e8b:	ba 70 00 00 00       	mov    $0x70,%edx
f0102e90:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e93:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102e94:	b2 71                	mov    $0x71,%dl
f0102e96:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102e97:	0f b6 c0             	movzbl %al,%eax
}
f0102e9a:	5d                   	pop    %ebp
f0102e9b:	c3                   	ret    

f0102e9c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102e9c:	55                   	push   %ebp
f0102e9d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102e9f:	ba 70 00 00 00       	mov    $0x70,%edx
f0102ea4:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ea7:	ee                   	out    %al,(%dx)
f0102ea8:	b2 71                	mov    $0x71,%dl
f0102eaa:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ead:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102eae:	5d                   	pop    %ebp
f0102eaf:	c3                   	ret    

f0102eb0 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102eb0:	55                   	push   %ebp
f0102eb1:	89 e5                	mov    %esp,%ebp
f0102eb3:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102eb6:	ff 75 08             	pushl  0x8(%ebp)
f0102eb9:	e8 37 d7 ff ff       	call   f01005f5 <cputchar>
f0102ebe:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0102ec1:	c9                   	leave  
f0102ec2:	c3                   	ret    

f0102ec3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102ec3:	55                   	push   %ebp
f0102ec4:	89 e5                	mov    %esp,%ebp
f0102ec6:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102ec9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102ed0:	ff 75 0c             	pushl  0xc(%ebp)
f0102ed3:	ff 75 08             	pushl  0x8(%ebp)
f0102ed6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102ed9:	50                   	push   %eax
f0102eda:	68 b0 2e 10 f0       	push   $0xf0102eb0
f0102edf:	e8 69 08 00 00       	call   f010374d <vprintfmt>
	return cnt;
}
f0102ee4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102ee7:	c9                   	leave  
f0102ee8:	c3                   	ret    

f0102ee9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102ee9:	55                   	push   %ebp
f0102eea:	89 e5                	mov    %esp,%ebp
f0102eec:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102eef:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102ef2:	50                   	push   %eax
f0102ef3:	ff 75 08             	pushl  0x8(%ebp)
f0102ef6:	e8 c8 ff ff ff       	call   f0102ec3 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102efb:	c9                   	leave  
f0102efc:	c3                   	ret    

f0102efd <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0102efd:	55                   	push   %ebp
f0102efe:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0102f00:	b8 80 9a 17 f0       	mov    $0xf0179a80,%eax
f0102f05:	c7 05 84 9a 17 f0 00 	movl   $0xf0000000,0xf0179a84
f0102f0c:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0102f0f:	66 c7 05 88 9a 17 f0 	movw   $0x10,0xf0179a88
f0102f16:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0102f18:	66 c7 05 48 a3 11 f0 	movw   $0x67,0xf011a348
f0102f1f:	67 00 
f0102f21:	66 a3 4a a3 11 f0    	mov    %ax,0xf011a34a
f0102f27:	89 c2                	mov    %eax,%edx
f0102f29:	c1 ea 10             	shr    $0x10,%edx
f0102f2c:	88 15 4c a3 11 f0    	mov    %dl,0xf011a34c
f0102f32:	c6 05 4e a3 11 f0 40 	movb   $0x40,0xf011a34e
f0102f39:	c1 e8 18             	shr    $0x18,%eax
f0102f3c:	a2 4f a3 11 f0       	mov    %al,0xf011a34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0102f41:	c6 05 4d a3 11 f0 89 	movb   $0x89,0xf011a34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0102f48:	b8 28 00 00 00       	mov    $0x28,%eax
f0102f4d:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0102f50:	b8 50 a3 11 f0       	mov    $0xf011a350,%eax
f0102f55:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0102f58:	5d                   	pop    %ebp
f0102f59:	c3                   	ret    

f0102f5a <trap_init>:
}


void
trap_init(void)
{
f0102f5a:	55                   	push   %ebp
f0102f5b:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE], 1, GD_KT, trap_Divide_error, 0);
f0102f5d:	b8 bc 32 10 f0       	mov    $0xf01032bc,%eax
f0102f62:	66 a3 40 92 17 f0    	mov    %ax,0xf0179240
f0102f68:	66 c7 05 42 92 17 f0 	movw   $0x8,0xf0179242
f0102f6f:	08 00 
f0102f71:	c6 05 44 92 17 f0 00 	movb   $0x0,0xf0179244
f0102f78:	c6 05 45 92 17 f0 8f 	movb   $0x8f,0xf0179245
f0102f7f:	c1 e8 10             	shr    $0x10,%eax
f0102f82:	66 a3 46 92 17 f0    	mov    %ax,0xf0179246
	// Per-CPU setup 
	trap_init_percpu();
f0102f88:	e8 70 ff ff ff       	call   f0102efd <trap_init_percpu>
}
f0102f8d:	5d                   	pop    %ebp
f0102f8e:	c3                   	ret    

f0102f8f <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0102f8f:	55                   	push   %ebp
f0102f90:	89 e5                	mov    %esp,%ebp
f0102f92:	53                   	push   %ebx
f0102f93:	83 ec 0c             	sub    $0xc,%esp
f0102f96:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0102f99:	ff 33                	pushl  (%ebx)
f0102f9b:	68 b2 53 10 f0       	push   $0xf01053b2
f0102fa0:	e8 44 ff ff ff       	call   f0102ee9 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0102fa5:	83 c4 08             	add    $0x8,%esp
f0102fa8:	ff 73 04             	pushl  0x4(%ebx)
f0102fab:	68 c1 53 10 f0       	push   $0xf01053c1
f0102fb0:	e8 34 ff ff ff       	call   f0102ee9 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0102fb5:	83 c4 08             	add    $0x8,%esp
f0102fb8:	ff 73 08             	pushl  0x8(%ebx)
f0102fbb:	68 d0 53 10 f0       	push   $0xf01053d0
f0102fc0:	e8 24 ff ff ff       	call   f0102ee9 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0102fc5:	83 c4 08             	add    $0x8,%esp
f0102fc8:	ff 73 0c             	pushl  0xc(%ebx)
f0102fcb:	68 df 53 10 f0       	push   $0xf01053df
f0102fd0:	e8 14 ff ff ff       	call   f0102ee9 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0102fd5:	83 c4 08             	add    $0x8,%esp
f0102fd8:	ff 73 10             	pushl  0x10(%ebx)
f0102fdb:	68 ee 53 10 f0       	push   $0xf01053ee
f0102fe0:	e8 04 ff ff ff       	call   f0102ee9 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0102fe5:	83 c4 08             	add    $0x8,%esp
f0102fe8:	ff 73 14             	pushl  0x14(%ebx)
f0102feb:	68 fd 53 10 f0       	push   $0xf01053fd
f0102ff0:	e8 f4 fe ff ff       	call   f0102ee9 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0102ff5:	83 c4 08             	add    $0x8,%esp
f0102ff8:	ff 73 18             	pushl  0x18(%ebx)
f0102ffb:	68 0c 54 10 f0       	push   $0xf010540c
f0103000:	e8 e4 fe ff ff       	call   f0102ee9 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103005:	83 c4 08             	add    $0x8,%esp
f0103008:	ff 73 1c             	pushl  0x1c(%ebx)
f010300b:	68 1b 54 10 f0       	push   $0xf010541b
f0103010:	e8 d4 fe ff ff       	call   f0102ee9 <cprintf>
f0103015:	83 c4 10             	add    $0x10,%esp
}
f0103018:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010301b:	c9                   	leave  
f010301c:	c3                   	ret    

f010301d <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010301d:	55                   	push   %ebp
f010301e:	89 e5                	mov    %esp,%ebp
f0103020:	56                   	push   %esi
f0103021:	53                   	push   %ebx
f0103022:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103025:	83 ec 08             	sub    $0x8,%esp
f0103028:	53                   	push   %ebx
f0103029:	68 51 55 10 f0       	push   $0xf0105551
f010302e:	e8 b6 fe ff ff       	call   f0102ee9 <cprintf>
	print_regs(&tf->tf_regs);
f0103033:	89 1c 24             	mov    %ebx,(%esp)
f0103036:	e8 54 ff ff ff       	call   f0102f8f <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010303b:	83 c4 08             	add    $0x8,%esp
f010303e:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103042:	50                   	push   %eax
f0103043:	68 6c 54 10 f0       	push   $0xf010546c
f0103048:	e8 9c fe ff ff       	call   f0102ee9 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010304d:	83 c4 08             	add    $0x8,%esp
f0103050:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103054:	50                   	push   %eax
f0103055:	68 7f 54 10 f0       	push   $0xf010547f
f010305a:	e8 8a fe ff ff       	call   f0102ee9 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010305f:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103062:	83 c4 10             	add    $0x10,%esp
f0103065:	83 f8 13             	cmp    $0x13,%eax
f0103068:	77 09                	ja     f0103073 <print_trapframe+0x56>
		return excnames[trapno];
f010306a:	8b 14 85 40 57 10 f0 	mov    -0xfefa8c0(,%eax,4),%edx
f0103071:	eb 10                	jmp    f0103083 <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
f0103073:	83 f8 30             	cmp    $0x30,%eax
f0103076:	b9 36 54 10 f0       	mov    $0xf0105436,%ecx
f010307b:	ba 2a 54 10 f0       	mov    $0xf010542a,%edx
f0103080:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103083:	83 ec 04             	sub    $0x4,%esp
f0103086:	52                   	push   %edx
f0103087:	50                   	push   %eax
f0103088:	68 92 54 10 f0       	push   $0xf0105492
f010308d:	e8 57 fe ff ff       	call   f0102ee9 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103092:	83 c4 10             	add    $0x10,%esp
f0103095:	3b 1d 40 9a 17 f0    	cmp    0xf0179a40,%ebx
f010309b:	75 1a                	jne    f01030b7 <print_trapframe+0x9a>
f010309d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01030a1:	75 14                	jne    f01030b7 <print_trapframe+0x9a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01030a3:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01030a6:	83 ec 08             	sub    $0x8,%esp
f01030a9:	50                   	push   %eax
f01030aa:	68 a4 54 10 f0       	push   $0xf01054a4
f01030af:	e8 35 fe ff ff       	call   f0102ee9 <cprintf>
f01030b4:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f01030b7:	83 ec 08             	sub    $0x8,%esp
f01030ba:	ff 73 2c             	pushl  0x2c(%ebx)
f01030bd:	68 b3 54 10 f0       	push   $0xf01054b3
f01030c2:	e8 22 fe ff ff       	call   f0102ee9 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01030c7:	83 c4 10             	add    $0x10,%esp
f01030ca:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01030ce:	75 49                	jne    f0103119 <print_trapframe+0xfc>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01030d0:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01030d3:	89 c2                	mov    %eax,%edx
f01030d5:	83 e2 01             	and    $0x1,%edx
f01030d8:	ba 50 54 10 f0       	mov    $0xf0105450,%edx
f01030dd:	b9 45 54 10 f0       	mov    $0xf0105445,%ecx
f01030e2:	0f 44 ca             	cmove  %edx,%ecx
f01030e5:	89 c2                	mov    %eax,%edx
f01030e7:	83 e2 02             	and    $0x2,%edx
f01030ea:	ba 62 54 10 f0       	mov    $0xf0105462,%edx
f01030ef:	be 5c 54 10 f0       	mov    $0xf010545c,%esi
f01030f4:	0f 45 d6             	cmovne %esi,%edx
f01030f7:	83 e0 04             	and    $0x4,%eax
f01030fa:	be 7c 55 10 f0       	mov    $0xf010557c,%esi
f01030ff:	b8 67 54 10 f0       	mov    $0xf0105467,%eax
f0103104:	0f 44 c6             	cmove  %esi,%eax
f0103107:	51                   	push   %ecx
f0103108:	52                   	push   %edx
f0103109:	50                   	push   %eax
f010310a:	68 c1 54 10 f0       	push   $0xf01054c1
f010310f:	e8 d5 fd ff ff       	call   f0102ee9 <cprintf>
f0103114:	83 c4 10             	add    $0x10,%esp
f0103117:	eb 10                	jmp    f0103129 <print_trapframe+0x10c>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103119:	83 ec 0c             	sub    $0xc,%esp
f010311c:	68 9d 52 10 f0       	push   $0xf010529d
f0103121:	e8 c3 fd ff ff       	call   f0102ee9 <cprintf>
f0103126:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103129:	83 ec 08             	sub    $0x8,%esp
f010312c:	ff 73 30             	pushl  0x30(%ebx)
f010312f:	68 d0 54 10 f0       	push   $0xf01054d0
f0103134:	e8 b0 fd ff ff       	call   f0102ee9 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103139:	83 c4 08             	add    $0x8,%esp
f010313c:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103140:	50                   	push   %eax
f0103141:	68 df 54 10 f0       	push   $0xf01054df
f0103146:	e8 9e fd ff ff       	call   f0102ee9 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010314b:	83 c4 08             	add    $0x8,%esp
f010314e:	ff 73 38             	pushl  0x38(%ebx)
f0103151:	68 f2 54 10 f0       	push   $0xf01054f2
f0103156:	e8 8e fd ff ff       	call   f0102ee9 <cprintf>
	if ((tf->tf_cs & 3) != 0) 
f010315b:	83 c4 10             	add    $0x10,%esp
f010315e:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103162:	74 25                	je     f0103189 <print_trapframe+0x16c>
	{
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103164:	83 ec 08             	sub    $0x8,%esp
f0103167:	ff 73 3c             	pushl  0x3c(%ebx)
f010316a:	68 01 55 10 f0       	push   $0xf0105501
f010316f:	e8 75 fd ff ff       	call   f0102ee9 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103174:	83 c4 08             	add    $0x8,%esp
f0103177:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010317b:	50                   	push   %eax
f010317c:	68 10 55 10 f0       	push   $0xf0105510
f0103181:	e8 63 fd ff ff       	call   f0102ee9 <cprintf>
f0103186:	83 c4 10             	add    $0x10,%esp
	}
}
f0103189:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010318c:	5b                   	pop    %ebx
f010318d:	5e                   	pop    %esi
f010318e:	5d                   	pop    %ebp
f010318f:	c3                   	ret    

f0103190 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103190:	55                   	push   %ebp
f0103191:	89 e5                	mov    %esp,%ebp
f0103193:	57                   	push   %edi
f0103194:	56                   	push   %esi
f0103195:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103198:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103199:	9c                   	pushf  
f010319a:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010319b:	f6 c4 02             	test   $0x2,%ah
f010319e:	74 19                	je     f01031b9 <trap+0x29>
f01031a0:	68 23 55 10 f0       	push   $0xf0105523
f01031a5:	68 ff 4f 10 f0       	push   $0xf0104fff
f01031aa:	68 a8 00 00 00       	push   $0xa8
f01031af:	68 3c 55 10 f0       	push   $0xf010553c
f01031b4:	e8 e7 ce ff ff       	call   f01000a0 <_panic>
	//print_trapframe(tf);
	cprintf("Incoming TRAP frame at %p\n", tf);
f01031b9:	83 ec 08             	sub    $0x8,%esp
f01031bc:	56                   	push   %esi
f01031bd:	68 48 55 10 f0       	push   $0xf0105548
f01031c2:	e8 22 fd ff ff       	call   f0102ee9 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01031c7:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01031cb:	83 e0 03             	and    $0x3,%eax
f01031ce:	83 c4 10             	add    $0x10,%esp
f01031d1:	66 83 f8 03          	cmp    $0x3,%ax
f01031d5:	75 31                	jne    f0103208 <trap+0x78>
		// Trapped from user mode.
		assert(curenv);
f01031d7:	a1 24 92 17 f0       	mov    0xf0179224,%eax
f01031dc:	85 c0                	test   %eax,%eax
f01031de:	75 19                	jne    f01031f9 <trap+0x69>
f01031e0:	68 63 55 10 f0       	push   $0xf0105563
f01031e5:	68 ff 4f 10 f0       	push   $0xf0104fff
f01031ea:	68 ae 00 00 00       	push   $0xae
f01031ef:	68 3c 55 10 f0       	push   $0xf010553c
f01031f4:	e8 a7 ce ff ff       	call   f01000a0 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01031f9:	b9 11 00 00 00       	mov    $0x11,%ecx
f01031fe:	89 c7                	mov    %eax,%edi
f0103200:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103202:	8b 35 24 92 17 f0    	mov    0xf0179224,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103208:	89 35 40 9a 17 f0    	mov    %esi,0xf0179a40
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f010320e:	83 ec 0c             	sub    $0xc,%esp
f0103211:	56                   	push   %esi
f0103212:	e8 06 fe ff ff       	call   f010301d <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103217:	83 c4 10             	add    $0x10,%esp
f010321a:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010321f:	75 17                	jne    f0103238 <trap+0xa8>
		panic("unhandled trap in kernel");
f0103221:	83 ec 04             	sub    $0x4,%esp
f0103224:	68 6a 55 10 f0       	push   $0xf010556a
f0103229:	68 97 00 00 00       	push   $0x97
f010322e:	68 3c 55 10 f0       	push   $0xf010553c
f0103233:	e8 68 ce ff ff       	call   f01000a0 <_panic>
	else {
		env_destroy(curenv);
f0103238:	83 ec 0c             	sub    $0xc,%esp
f010323b:	ff 35 24 92 17 f0    	pushl  0xf0179224
f0103241:	e8 8c fb ff ff       	call   f0102dd2 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103246:	a1 24 92 17 f0       	mov    0xf0179224,%eax
f010324b:	83 c4 10             	add    $0x10,%esp
f010324e:	85 c0                	test   %eax,%eax
f0103250:	74 06                	je     f0103258 <trap+0xc8>
f0103252:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103256:	74 19                	je     f0103271 <trap+0xe1>
f0103258:	68 c8 56 10 f0       	push   $0xf01056c8
f010325d:	68 ff 4f 10 f0       	push   $0xf0104fff
f0103262:	68 c0 00 00 00       	push   $0xc0
f0103267:	68 3c 55 10 f0       	push   $0xf010553c
f010326c:	e8 2f ce ff ff       	call   f01000a0 <_panic>
	env_run(curenv);
f0103271:	83 ec 0c             	sub    $0xc,%esp
f0103274:	50                   	push   %eax
f0103275:	e8 a8 fb ff ff       	call   f0102e22 <env_run>

f010327a <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010327a:	55                   	push   %ebp
f010327b:	89 e5                	mov    %esp,%ebp
f010327d:	53                   	push   %ebx
f010327e:	83 ec 04             	sub    $0x4,%esp
f0103281:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103284:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103287:	ff 73 30             	pushl  0x30(%ebx)
f010328a:	50                   	push   %eax
f010328b:	a1 24 92 17 f0       	mov    0xf0179224,%eax
f0103290:	ff 70 48             	pushl  0x48(%eax)
f0103293:	68 f4 56 10 f0       	push   $0xf01056f4
f0103298:	e8 4c fc ff ff       	call   f0102ee9 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010329d:	89 1c 24             	mov    %ebx,(%esp)
f01032a0:	e8 78 fd ff ff       	call   f010301d <print_trapframe>
	env_destroy(curenv);
f01032a5:	83 c4 04             	add    $0x4,%esp
f01032a8:	ff 35 24 92 17 f0    	pushl  0xf0179224
f01032ae:	e8 1f fb ff ff       	call   f0102dd2 <env_destroy>
f01032b3:	83 c4 10             	add    $0x10,%esp
}
f01032b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01032b9:	c9                   	leave  
f01032ba:	c3                   	ret    
f01032bb:	90                   	nop

f01032bc <trap_Divide_error>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(trap_Divide_error, T_DIVIDE)
f01032bc:	6a 00                	push   $0x0
f01032be:	6a 00                	push   $0x0
f01032c0:	eb 00                	jmp    f01032c2 <_alltraps>

f01032c2 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:
 	pushal
f01032c2:	60                   	pusha  
 	pushl %es
f01032c3:	06                   	push   %es
 	pushl %ds
f01032c4:	1e                   	push   %ds
	//pushl %ss
	movl $GD_KD, %eax
f01032c5:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f01032ca:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f01032cc:	8e c0                	mov    %eax,%es

	pushl %esp
f01032ce:	54                   	push   %esp
	
	call trap
f01032cf:	e8 bc fe ff ff       	call   f0103190 <trap>

f01032d4 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01032d4:	55                   	push   %ebp
f01032d5:	89 e5                	mov    %esp,%ebp
f01032d7:	83 ec 0c             	sub    $0xc,%esp
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	panic("syscall not implemented");
f01032da:	68 90 57 10 f0       	push   $0xf0105790
f01032df:	6a 49                	push   $0x49
f01032e1:	68 a8 57 10 f0       	push   $0xf01057a8
f01032e6:	e8 b5 cd ff ff       	call   f01000a0 <_panic>

f01032eb <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01032eb:	55                   	push   %ebp
f01032ec:	89 e5                	mov    %esp,%ebp
f01032ee:	57                   	push   %edi
f01032ef:	56                   	push   %esi
f01032f0:	53                   	push   %ebx
f01032f1:	83 ec 14             	sub    $0x14,%esp
f01032f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01032f7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01032fa:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01032fd:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103300:	8b 1a                	mov    (%edx),%ebx
f0103302:	8b 01                	mov    (%ecx),%eax
f0103304:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103307:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010330e:	e9 88 00 00 00       	jmp    f010339b <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0103313:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103316:	01 d8                	add    %ebx,%eax
f0103318:	89 c6                	mov    %eax,%esi
f010331a:	c1 ee 1f             	shr    $0x1f,%esi
f010331d:	01 c6                	add    %eax,%esi
f010331f:	d1 fe                	sar    %esi
f0103321:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0103324:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103327:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010332a:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010332c:	eb 03                	jmp    f0103331 <stab_binsearch+0x46>
			m--;
f010332e:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103331:	39 c3                	cmp    %eax,%ebx
f0103333:	7f 1f                	jg     f0103354 <stab_binsearch+0x69>
f0103335:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103339:	83 ea 0c             	sub    $0xc,%edx
f010333c:	39 f9                	cmp    %edi,%ecx
f010333e:	75 ee                	jne    f010332e <stab_binsearch+0x43>
f0103340:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103343:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103346:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103349:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010334d:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103350:	76 18                	jbe    f010336a <stab_binsearch+0x7f>
f0103352:	eb 05                	jmp    f0103359 <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103354:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0103357:	eb 42                	jmp    f010339b <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103359:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010335c:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010335e:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103361:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103368:	eb 31                	jmp    f010339b <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010336a:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010336d:	73 17                	jae    f0103386 <stab_binsearch+0x9b>
			*region_right = m - 1;
f010336f:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103372:	83 e8 01             	sub    $0x1,%eax
f0103375:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103378:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010337b:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010337d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103384:	eb 15                	jmp    f010339b <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103386:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103389:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f010338c:	89 1e                	mov    %ebx,(%esi)
			l = m;
			addr++;
f010338e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103392:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103394:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010339b:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010339e:	0f 8e 6f ff ff ff    	jle    f0103313 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01033a4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01033a8:	75 0f                	jne    f01033b9 <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f01033aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033ad:	8b 00                	mov    (%eax),%eax
f01033af:	83 e8 01             	sub    $0x1,%eax
f01033b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01033b5:	89 06                	mov    %eax,(%esi)
f01033b7:	eb 2c                	jmp    f01033e5 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01033b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01033bc:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01033be:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01033c1:	8b 0e                	mov    (%esi),%ecx
f01033c3:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01033c6:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01033c9:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01033cc:	eb 03                	jmp    f01033d1 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01033ce:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01033d1:	39 c8                	cmp    %ecx,%eax
f01033d3:	7e 0b                	jle    f01033e0 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f01033d5:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01033d9:	83 ea 0c             	sub    $0xc,%edx
f01033dc:	39 fb                	cmp    %edi,%ebx
f01033de:	75 ee                	jne    f01033ce <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f01033e0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01033e3:	89 06                	mov    %eax,(%esi)
	}
}
f01033e5:	83 c4 14             	add    $0x14,%esp
f01033e8:	5b                   	pop    %ebx
f01033e9:	5e                   	pop    %esi
f01033ea:	5f                   	pop    %edi
f01033eb:	5d                   	pop    %ebp
f01033ec:	c3                   	ret    

f01033ed <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01033ed:	55                   	push   %ebp
f01033ee:	89 e5                	mov    %esp,%ebp
f01033f0:	57                   	push   %edi
f01033f1:	56                   	push   %esi
f01033f2:	53                   	push   %ebx
f01033f3:	83 ec 3c             	sub    $0x3c,%esp
f01033f6:	8b 75 08             	mov    0x8(%ebp),%esi
f01033f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01033fc:	c7 03 b7 57 10 f0    	movl   $0xf01057b7,(%ebx)
	info->eip_line = 0;
f0103402:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103409:	c7 43 08 b7 57 10 f0 	movl   $0xf01057b7,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103410:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103417:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010341a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103421:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103427:	77 21                	ja     f010344a <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103429:	a1 00 00 20 00       	mov    0x200000,%eax
f010342e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f0103431:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0103436:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f010343c:	89 7d c0             	mov    %edi,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f010343f:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0103445:	89 7d bc             	mov    %edi,-0x44(%ebp)
f0103448:	eb 1a                	jmp    f0103464 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010344a:	c7 45 bc 76 fc 10 f0 	movl   $0xf010fc76,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103451:	c7 45 c0 81 d2 10 f0 	movl   $0xf010d281,-0x40(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103458:	b8 80 d2 10 f0       	mov    $0xf010d280,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f010345d:	c7 45 c4 f0 59 10 f0 	movl   $0xf01059f0,-0x3c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103464:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103467:	39 7d c0             	cmp    %edi,-0x40(%ebp)
f010346a:	0f 83 72 01 00 00    	jae    f01035e2 <debuginfo_eip+0x1f5>
f0103470:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0103474:	0f 85 6f 01 00 00    	jne    f01035e9 <debuginfo_eip+0x1fc>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010347a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103481:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103484:	29 f8                	sub    %edi,%eax
f0103486:	c1 f8 02             	sar    $0x2,%eax
f0103489:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010348f:	83 e8 01             	sub    $0x1,%eax
f0103492:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103495:	56                   	push   %esi
f0103496:	6a 64                	push   $0x64
f0103498:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010349b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010349e:	89 f8                	mov    %edi,%eax
f01034a0:	e8 46 fe ff ff       	call   f01032eb <stab_binsearch>
	if (lfile == 0)
f01034a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01034a8:	83 c4 08             	add    $0x8,%esp
f01034ab:	85 c0                	test   %eax,%eax
f01034ad:	0f 84 3d 01 00 00    	je     f01035f0 <debuginfo_eip+0x203>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01034b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01034b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01034bc:	56                   	push   %esi
f01034bd:	6a 24                	push   $0x24
f01034bf:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01034c2:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01034c5:	89 f8                	mov    %edi,%eax
f01034c7:	e8 1f fe ff ff       	call   f01032eb <stab_binsearch>

	if (lfun <= rfun) {
f01034cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01034cf:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01034d2:	83 c4 08             	add    $0x8,%esp
f01034d5:	39 c8                	cmp    %ecx,%eax
f01034d7:	7f 32                	jg     f010350b <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01034d9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01034dc:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01034df:	8d 3c 97             	lea    (%edi,%edx,4),%edi
f01034e2:	8b 17                	mov    (%edi),%edx
f01034e4:	89 55 b8             	mov    %edx,-0x48(%ebp)
f01034e7:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01034ea:	2b 55 c0             	sub    -0x40(%ebp),%edx
f01034ed:	39 55 b8             	cmp    %edx,-0x48(%ebp)
f01034f0:	73 09                	jae    f01034fb <debuginfo_eip+0x10e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01034f2:	8b 55 b8             	mov    -0x48(%ebp),%edx
f01034f5:	03 55 c0             	add    -0x40(%ebp),%edx
f01034f8:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01034fb:	8b 57 08             	mov    0x8(%edi),%edx
f01034fe:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103501:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103503:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103506:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0103509:	eb 0f                	jmp    f010351a <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010350b:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010350e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103511:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103514:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103517:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010351a:	83 ec 08             	sub    $0x8,%esp
f010351d:	6a 3a                	push   $0x3a
f010351f:	ff 73 08             	pushl  0x8(%ebx)
f0103522:	e8 7d 08 00 00       	call   f0103da4 <strfind>
f0103527:	2b 43 08             	sub    0x8(%ebx),%eax
f010352a:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010352d:	83 c4 08             	add    $0x8,%esp
f0103530:	56                   	push   %esi
f0103531:	6a 44                	push   $0x44
f0103533:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103536:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103539:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010353c:	89 f0                	mov    %esi,%eax
f010353e:	e8 a8 fd ff ff       	call   f01032eb <stab_binsearch>
	if(lline>rline)
f0103543:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103546:	83 c4 10             	add    $0x10,%esp
f0103549:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f010354c:	0f 8f a5 00 00 00    	jg     f01035f7 <debuginfo_eip+0x20a>
	{
		return -1;
	}
	else
		info->eip_line = stabs[lline].n_desc;
f0103552:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103555:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f010355a:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010355d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103560:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103563:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103566:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0103569:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010356c:	eb 06                	jmp    f0103574 <debuginfo_eip+0x187>
f010356e:	83 e8 01             	sub    $0x1,%eax
f0103571:	83 ea 0c             	sub    $0xc,%edx
f0103574:	39 c7                	cmp    %eax,%edi
f0103576:	7f 27                	jg     f010359f <debuginfo_eip+0x1b2>
	       && stabs[lline].n_type != N_SOL
f0103578:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010357c:	80 f9 84             	cmp    $0x84,%cl
f010357f:	0f 84 80 00 00 00    	je     f0103605 <debuginfo_eip+0x218>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103585:	80 f9 64             	cmp    $0x64,%cl
f0103588:	75 e4                	jne    f010356e <debuginfo_eip+0x181>
f010358a:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f010358e:	74 de                	je     f010356e <debuginfo_eip+0x181>
f0103590:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103593:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103596:	eb 73                	jmp    f010360b <debuginfo_eip+0x21e>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103598:	03 55 c0             	add    -0x40(%ebp),%edx
f010359b:	89 13                	mov    %edx,(%ebx)
f010359d:	eb 03                	jmp    f01035a2 <debuginfo_eip+0x1b5>
f010359f:	8b 5d 0c             	mov    0xc(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01035a2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01035a5:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01035a8:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01035ad:	39 f2                	cmp    %esi,%edx
f01035af:	7d 76                	jge    f0103627 <debuginfo_eip+0x23a>
		for (lline = lfun + 1;
f01035b1:	83 c2 01             	add    $0x1,%edx
f01035b4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01035b7:	89 d0                	mov    %edx,%eax
f01035b9:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01035bc:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01035bf:	8d 14 97             	lea    (%edi,%edx,4),%edx
f01035c2:	eb 04                	jmp    f01035c8 <debuginfo_eip+0x1db>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01035c4:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01035c8:	39 c6                	cmp    %eax,%esi
f01035ca:	7e 32                	jle    f01035fe <debuginfo_eip+0x211>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01035cc:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01035d0:	83 c0 01             	add    $0x1,%eax
f01035d3:	83 c2 0c             	add    $0xc,%edx
f01035d6:	80 f9 a0             	cmp    $0xa0,%cl
f01035d9:	74 e9                	je     f01035c4 <debuginfo_eip+0x1d7>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01035db:	b8 00 00 00 00       	mov    $0x0,%eax
f01035e0:	eb 45                	jmp    f0103627 <debuginfo_eip+0x23a>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01035e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01035e7:	eb 3e                	jmp    f0103627 <debuginfo_eip+0x23a>
f01035e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01035ee:	eb 37                	jmp    f0103627 <debuginfo_eip+0x23a>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01035f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01035f5:	eb 30                	jmp    f0103627 <debuginfo_eip+0x23a>
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if(lline>rline)
	{
		return -1;
f01035f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01035fc:	eb 29                	jmp    f0103627 <debuginfo_eip+0x23a>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01035fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0103603:	eb 22                	jmp    f0103627 <debuginfo_eip+0x23a>
f0103605:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103608:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010360b:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010360e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103611:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103614:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103617:	2b 45 c0             	sub    -0x40(%ebp),%eax
f010361a:	39 c2                	cmp    %eax,%edx
f010361c:	0f 82 76 ff ff ff    	jb     f0103598 <debuginfo_eip+0x1ab>
f0103622:	e9 7b ff ff ff       	jmp    f01035a2 <debuginfo_eip+0x1b5>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
}
f0103627:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010362a:	5b                   	pop    %ebx
f010362b:	5e                   	pop    %esi
f010362c:	5f                   	pop    %edi
f010362d:	5d                   	pop    %ebp
f010362e:	c3                   	ret    

f010362f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010362f:	55                   	push   %ebp
f0103630:	89 e5                	mov    %esp,%ebp
f0103632:	57                   	push   %edi
f0103633:	56                   	push   %esi
f0103634:	53                   	push   %ebx
f0103635:	83 ec 1c             	sub    $0x1c,%esp
f0103638:	89 c7                	mov    %eax,%edi
f010363a:	89 d6                	mov    %edx,%esi
f010363c:	8b 45 08             	mov    0x8(%ebp),%eax
f010363f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103642:	89 d1                	mov    %edx,%ecx
f0103644:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103647:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010364a:	8b 45 10             	mov    0x10(%ebp),%eax
f010364d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103650:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103653:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010365a:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f010365d:	72 05                	jb     f0103664 <printnum+0x35>
f010365f:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0103662:	77 3e                	ja     f01036a2 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103664:	83 ec 0c             	sub    $0xc,%esp
f0103667:	ff 75 18             	pushl  0x18(%ebp)
f010366a:	83 eb 01             	sub    $0x1,%ebx
f010366d:	53                   	push   %ebx
f010366e:	50                   	push   %eax
f010366f:	83 ec 08             	sub    $0x8,%esp
f0103672:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103675:	ff 75 e0             	pushl  -0x20(%ebp)
f0103678:	ff 75 dc             	pushl  -0x24(%ebp)
f010367b:	ff 75 d8             	pushl  -0x28(%ebp)
f010367e:	e8 4d 09 00 00       	call   f0103fd0 <__udivdi3>
f0103683:	83 c4 18             	add    $0x18,%esp
f0103686:	52                   	push   %edx
f0103687:	50                   	push   %eax
f0103688:	89 f2                	mov    %esi,%edx
f010368a:	89 f8                	mov    %edi,%eax
f010368c:	e8 9e ff ff ff       	call   f010362f <printnum>
f0103691:	83 c4 20             	add    $0x20,%esp
f0103694:	eb 13                	jmp    f01036a9 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103696:	83 ec 08             	sub    $0x8,%esp
f0103699:	56                   	push   %esi
f010369a:	ff 75 18             	pushl  0x18(%ebp)
f010369d:	ff d7                	call   *%edi
f010369f:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01036a2:	83 eb 01             	sub    $0x1,%ebx
f01036a5:	85 db                	test   %ebx,%ebx
f01036a7:	7f ed                	jg     f0103696 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01036a9:	83 ec 08             	sub    $0x8,%esp
f01036ac:	56                   	push   %esi
f01036ad:	83 ec 04             	sub    $0x4,%esp
f01036b0:	ff 75 e4             	pushl  -0x1c(%ebp)
f01036b3:	ff 75 e0             	pushl  -0x20(%ebp)
f01036b6:	ff 75 dc             	pushl  -0x24(%ebp)
f01036b9:	ff 75 d8             	pushl  -0x28(%ebp)
f01036bc:	e8 3f 0a 00 00       	call   f0104100 <__umoddi3>
f01036c1:	83 c4 14             	add    $0x14,%esp
f01036c4:	0f be 80 c1 57 10 f0 	movsbl -0xfefa83f(%eax),%eax
f01036cb:	50                   	push   %eax
f01036cc:	ff d7                	call   *%edi
f01036ce:	83 c4 10             	add    $0x10,%esp
}
f01036d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01036d4:	5b                   	pop    %ebx
f01036d5:	5e                   	pop    %esi
f01036d6:	5f                   	pop    %edi
f01036d7:	5d                   	pop    %ebp
f01036d8:	c3                   	ret    

f01036d9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01036d9:	55                   	push   %ebp
f01036da:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01036dc:	83 fa 01             	cmp    $0x1,%edx
f01036df:	7e 0e                	jle    f01036ef <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01036e1:	8b 10                	mov    (%eax),%edx
f01036e3:	8d 4a 08             	lea    0x8(%edx),%ecx
f01036e6:	89 08                	mov    %ecx,(%eax)
f01036e8:	8b 02                	mov    (%edx),%eax
f01036ea:	8b 52 04             	mov    0x4(%edx),%edx
f01036ed:	eb 22                	jmp    f0103711 <getuint+0x38>
	else if (lflag)
f01036ef:	85 d2                	test   %edx,%edx
f01036f1:	74 10                	je     f0103703 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01036f3:	8b 10                	mov    (%eax),%edx
f01036f5:	8d 4a 04             	lea    0x4(%edx),%ecx
f01036f8:	89 08                	mov    %ecx,(%eax)
f01036fa:	8b 02                	mov    (%edx),%eax
f01036fc:	ba 00 00 00 00       	mov    $0x0,%edx
f0103701:	eb 0e                	jmp    f0103711 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103703:	8b 10                	mov    (%eax),%edx
f0103705:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103708:	89 08                	mov    %ecx,(%eax)
f010370a:	8b 02                	mov    (%edx),%eax
f010370c:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103711:	5d                   	pop    %ebp
f0103712:	c3                   	ret    

f0103713 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103713:	55                   	push   %ebp
f0103714:	89 e5                	mov    %esp,%ebp
f0103716:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103719:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010371d:	8b 10                	mov    (%eax),%edx
f010371f:	3b 50 04             	cmp    0x4(%eax),%edx
f0103722:	73 0a                	jae    f010372e <sprintputch+0x1b>
		*b->buf++ = ch;
f0103724:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103727:	89 08                	mov    %ecx,(%eax)
f0103729:	8b 45 08             	mov    0x8(%ebp),%eax
f010372c:	88 02                	mov    %al,(%edx)
}
f010372e:	5d                   	pop    %ebp
f010372f:	c3                   	ret    

f0103730 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103730:	55                   	push   %ebp
f0103731:	89 e5                	mov    %esp,%ebp
f0103733:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0103736:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103739:	50                   	push   %eax
f010373a:	ff 75 10             	pushl  0x10(%ebp)
f010373d:	ff 75 0c             	pushl  0xc(%ebp)
f0103740:	ff 75 08             	pushl  0x8(%ebp)
f0103743:	e8 05 00 00 00       	call   f010374d <vprintfmt>
	va_end(ap);
f0103748:	83 c4 10             	add    $0x10,%esp
}
f010374b:	c9                   	leave  
f010374c:	c3                   	ret    

f010374d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010374d:	55                   	push   %ebp
f010374e:	89 e5                	mov    %esp,%ebp
f0103750:	57                   	push   %edi
f0103751:	56                   	push   %esi
f0103752:	53                   	push   %ebx
f0103753:	83 ec 2c             	sub    $0x2c,%esp
f0103756:	8b 75 08             	mov    0x8(%ebp),%esi
f0103759:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010375c:	8b 7d 10             	mov    0x10(%ebp),%edi
f010375f:	eb 12                	jmp    f0103773 <vprintfmt+0x26>

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
		{
			if (ch == '\0')
f0103761:	85 c0                	test   %eax,%eax
f0103763:	0f 84 90 03 00 00    	je     f0103af9 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
f0103769:	83 ec 08             	sub    $0x8,%esp
f010376c:	53                   	push   %ebx
f010376d:	50                   	push   %eax
f010376e:	ff d6                	call   *%esi
f0103770:	83 c4 10             	add    $0x10,%esp
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
f0103773:	83 c7 01             	add    $0x1,%edi
f0103776:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010377a:	83 f8 25             	cmp    $0x25,%eax
f010377d:	75 e2                	jne    f0103761 <vprintfmt+0x14>
f010377f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0103783:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f010378a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103791:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0103798:	ba 00 00 00 00       	mov    $0x0,%edx
f010379d:	eb 07                	jmp    f01037a6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f010379f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		{

			// flag to pad on the right
			case '-':
				padc = '-';
f01037a2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f01037a6:	8d 47 01             	lea    0x1(%edi),%eax
f01037a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01037ac:	0f b6 07             	movzbl (%edi),%eax
f01037af:	0f b6 c8             	movzbl %al,%ecx
f01037b2:	83 e8 23             	sub    $0x23,%eax
f01037b5:	3c 55                	cmp    $0x55,%al
f01037b7:	0f 87 21 03 00 00    	ja     f0103ade <vprintfmt+0x391>
f01037bd:	0f b6 c0             	movzbl %al,%eax
f01037c0:	ff 24 85 60 58 10 f0 	jmp    *-0xfefa7a0(,%eax,4)
f01037c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				padc = '-';
				goto reswitch;

			// flag to pad with 0's instead of spaces
			case '0':
				padc = '0';
f01037ca:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f01037ce:	eb d6                	jmp    f01037a6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f01037d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01037d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01037d8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
					precision = precision * 10 + ch - '0';
f01037db:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01037de:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
					ch = *fmt;
f01037e2:	0f be 0f             	movsbl (%edi),%ecx
					if (ch < '0' || ch > '9')
f01037e5:	8d 51 d0             	lea    -0x30(%ecx),%edx
f01037e8:	83 fa 09             	cmp    $0x9,%edx
f01037eb:	77 39                	ja     f0103826 <vprintfmt+0xd9>
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
f01037ed:	83 c7 01             	add    $0x1,%edi
					precision = precision * 10 + ch - '0';
					ch = *fmt;
					if (ch < '0' || ch > '9')
						break;
				}
f01037f0:	eb e9                	jmp    f01037db <vprintfmt+0x8e>
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
f01037f2:	8b 45 14             	mov    0x14(%ebp),%eax
f01037f5:	8d 48 04             	lea    0x4(%eax),%ecx
f01037f8:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01037fb:	8b 00                	mov    (%eax),%eax
f01037fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0103800:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				}
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
				goto process_precision;
f0103803:	eb 27                	jmp    f010382c <vprintfmt+0xdf>
f0103805:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103808:	85 c0                	test   %eax,%eax
f010380a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010380f:	0f 49 c8             	cmovns %eax,%ecx
f0103812:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0103815:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103818:	eb 8c                	jmp    f01037a6 <vprintfmt+0x59>
f010381a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				if (width < 0)
					width = 0;
				goto reswitch;

			case '#':
				altflag = 1;
f010381d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				goto reswitch;
f0103824:	eb 80                	jmp    f01037a6 <vprintfmt+0x59>
f0103826:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103829:	89 45 d0             	mov    %eax,-0x30(%ebp)

			process_precision:
				if (width < 0)
f010382c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103830:	0f 89 70 ff ff ff    	jns    f01037a6 <vprintfmt+0x59>
					width = precision, precision = -1;
f0103836:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103839:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010383c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103843:	e9 5e ff ff ff       	jmp    f01037a6 <vprintfmt+0x59>
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
f0103848:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f010384b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
				goto reswitch;
f010384e:	e9 53 ff ff ff       	jmp    f01037a6 <vprintfmt+0x59>

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
f0103853:	8b 45 14             	mov    0x14(%ebp),%eax
f0103856:	8d 50 04             	lea    0x4(%eax),%edx
f0103859:	89 55 14             	mov    %edx,0x14(%ebp)
f010385c:	83 ec 08             	sub    $0x8,%esp
f010385f:	53                   	push   %ebx
f0103860:	ff 30                	pushl  (%eax)
f0103862:	ff d6                	call   *%esi
				break;
f0103864:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0103867:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
				break;
f010386a:	e9 04 ff ff ff       	jmp    f0103773 <vprintfmt+0x26>

			// error message
			case 'e':
				err = va_arg(ap, int);
f010386f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103872:	8d 50 04             	lea    0x4(%eax),%edx
f0103875:	89 55 14             	mov    %edx,0x14(%ebp)
f0103878:	8b 00                	mov    (%eax),%eax
f010387a:	99                   	cltd   
f010387b:	31 d0                	xor    %edx,%eax
f010387d:	29 d0                	sub    %edx,%eax
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010387f:	83 f8 07             	cmp    $0x7,%eax
f0103882:	7f 0b                	jg     f010388f <vprintfmt+0x142>
f0103884:	8b 14 85 c0 59 10 f0 	mov    -0xfefa640(,%eax,4),%edx
f010388b:	85 d2                	test   %edx,%edx
f010388d:	75 18                	jne    f01038a7 <vprintfmt+0x15a>
					printfmt(putch, putdat, "error %d", err);
f010388f:	50                   	push   %eax
f0103890:	68 d9 57 10 f0       	push   $0xf01057d9
f0103895:	53                   	push   %ebx
f0103896:	56                   	push   %esi
f0103897:	e8 94 fe ff ff       	call   f0103730 <printfmt>
f010389c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f010389f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			case 'e':
				err = va_arg(ap, int);
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
					printfmt(putch, putdat, "error %d", err);
f01038a2:	e9 cc fe ff ff       	jmp    f0103773 <vprintfmt+0x26>
				else
					printfmt(putch, putdat, "%s", p);
f01038a7:	52                   	push   %edx
f01038a8:	68 11 50 10 f0       	push   $0xf0105011
f01038ad:	53                   	push   %ebx
f01038ae:	56                   	push   %esi
f01038af:	e8 7c fe ff ff       	call   f0103730 <printfmt>
f01038b4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f01038b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01038ba:	e9 b4 fe ff ff       	jmp    f0103773 <vprintfmt+0x26>
f01038bf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01038c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038c5:	89 45 cc             	mov    %eax,-0x34(%ebp)
					printfmt(putch, putdat, "%s", p);
				break;

			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
f01038c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01038cb:	8d 50 04             	lea    0x4(%eax),%edx
f01038ce:	89 55 14             	mov    %edx,0x14(%ebp)
f01038d1:	8b 38                	mov    (%eax),%edi
					p = "(null)";
f01038d3:	85 ff                	test   %edi,%edi
f01038d5:	ba d2 57 10 f0       	mov    $0xf01057d2,%edx
f01038da:	0f 44 fa             	cmove  %edx,%edi
				if (width > 0 && padc != '-')
f01038dd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f01038e1:	0f 84 92 00 00 00    	je     f0103979 <vprintfmt+0x22c>
f01038e7:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f01038eb:	0f 8e 96 00 00 00    	jle    f0103987 <vprintfmt+0x23a>
					for (width -= strnlen(p, precision); width > 0; width--)
f01038f1:	83 ec 08             	sub    $0x8,%esp
f01038f4:	51                   	push   %ecx
f01038f5:	57                   	push   %edi
f01038f6:	e8 5f 03 00 00       	call   f0103c5a <strnlen>
f01038fb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01038fe:	29 c1                	sub    %eax,%ecx
f0103900:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0103903:	83 c4 10             	add    $0x10,%esp
						putch(padc, putdat);
f0103906:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010390a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010390d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103910:	89 cf                	mov    %ecx,%edi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
f0103912:	eb 0f                	jmp    f0103923 <vprintfmt+0x1d6>
						putch(padc, putdat);
f0103914:	83 ec 08             	sub    $0x8,%esp
f0103917:	53                   	push   %ebx
f0103918:	ff 75 e0             	pushl  -0x20(%ebp)
f010391b:	ff d6                	call   *%esi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
f010391d:	83 ef 01             	sub    $0x1,%edi
f0103920:	83 c4 10             	add    $0x10,%esp
f0103923:	85 ff                	test   %edi,%edi
f0103925:	7f ed                	jg     f0103914 <vprintfmt+0x1c7>
f0103927:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010392a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010392d:	85 c9                	test   %ecx,%ecx
f010392f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103934:	0f 49 c1             	cmovns %ecx,%eax
f0103937:	29 c1                	sub    %eax,%ecx
f0103939:	89 75 08             	mov    %esi,0x8(%ebp)
f010393c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010393f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103942:	89 cb                	mov    %ecx,%ebx
f0103944:	eb 4d                	jmp    f0103993 <vprintfmt+0x246>
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
f0103946:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010394a:	74 1b                	je     f0103967 <vprintfmt+0x21a>
f010394c:	0f be c0             	movsbl %al,%eax
f010394f:	83 e8 20             	sub    $0x20,%eax
f0103952:	83 f8 5e             	cmp    $0x5e,%eax
f0103955:	76 10                	jbe    f0103967 <vprintfmt+0x21a>
						putch('?', putdat);
f0103957:	83 ec 08             	sub    $0x8,%esp
f010395a:	ff 75 0c             	pushl  0xc(%ebp)
f010395d:	6a 3f                	push   $0x3f
f010395f:	ff 55 08             	call   *0x8(%ebp)
f0103962:	83 c4 10             	add    $0x10,%esp
f0103965:	eb 0d                	jmp    f0103974 <vprintfmt+0x227>
					else
						putch(ch, putdat);
f0103967:	83 ec 08             	sub    $0x8,%esp
f010396a:	ff 75 0c             	pushl  0xc(%ebp)
f010396d:	52                   	push   %edx
f010396e:	ff 55 08             	call   *0x8(%ebp)
f0103971:	83 c4 10             	add    $0x10,%esp
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103974:	83 eb 01             	sub    $0x1,%ebx
f0103977:	eb 1a                	jmp    f0103993 <vprintfmt+0x246>
f0103979:	89 75 08             	mov    %esi,0x8(%ebp)
f010397c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010397f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103982:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103985:	eb 0c                	jmp    f0103993 <vprintfmt+0x246>
f0103987:	89 75 08             	mov    %esi,0x8(%ebp)
f010398a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010398d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103990:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103993:	83 c7 01             	add    $0x1,%edi
f0103996:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010399a:	0f be d0             	movsbl %al,%edx
f010399d:	85 d2                	test   %edx,%edx
f010399f:	74 23                	je     f01039c4 <vprintfmt+0x277>
f01039a1:	85 f6                	test   %esi,%esi
f01039a3:	78 a1                	js     f0103946 <vprintfmt+0x1f9>
f01039a5:	83 ee 01             	sub    $0x1,%esi
f01039a8:	79 9c                	jns    f0103946 <vprintfmt+0x1f9>
f01039aa:	89 df                	mov    %ebx,%edi
f01039ac:	8b 75 08             	mov    0x8(%ebp),%esi
f01039af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01039b2:	eb 18                	jmp    f01039cc <vprintfmt+0x27f>
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
					putch(' ', putdat);
f01039b4:	83 ec 08             	sub    $0x8,%esp
f01039b7:	53                   	push   %ebx
f01039b8:	6a 20                	push   $0x20
f01039ba:	ff d6                	call   *%esi
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
f01039bc:	83 ef 01             	sub    $0x1,%edi
f01039bf:	83 c4 10             	add    $0x10,%esp
f01039c2:	eb 08                	jmp    f01039cc <vprintfmt+0x27f>
f01039c4:	89 df                	mov    %ebx,%edi
f01039c6:	8b 75 08             	mov    0x8(%ebp),%esi
f01039c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01039cc:	85 ff                	test   %edi,%edi
f01039ce:	7f e4                	jg     f01039b4 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f01039d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01039d3:	e9 9b fd ff ff       	jmp    f0103773 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01039d8:	83 fa 01             	cmp    $0x1,%edx
f01039db:	7e 16                	jle    f01039f3 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
f01039dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01039e0:	8d 50 08             	lea    0x8(%eax),%edx
f01039e3:	89 55 14             	mov    %edx,0x14(%ebp)
f01039e6:	8b 50 04             	mov    0x4(%eax),%edx
f01039e9:	8b 00                	mov    (%eax),%eax
f01039eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01039ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01039f1:	eb 32                	jmp    f0103a25 <vprintfmt+0x2d8>
	else if (lflag)
f01039f3:	85 d2                	test   %edx,%edx
f01039f5:	74 18                	je     f0103a0f <vprintfmt+0x2c2>
		return va_arg(*ap, long);
f01039f7:	8b 45 14             	mov    0x14(%ebp),%eax
f01039fa:	8d 50 04             	lea    0x4(%eax),%edx
f01039fd:	89 55 14             	mov    %edx,0x14(%ebp)
f0103a00:	8b 00                	mov    (%eax),%eax
f0103a02:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103a05:	89 c1                	mov    %eax,%ecx
f0103a07:	c1 f9 1f             	sar    $0x1f,%ecx
f0103a0a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103a0d:	eb 16                	jmp    f0103a25 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
f0103a0f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a12:	8d 50 04             	lea    0x4(%eax),%edx
f0103a15:	89 55 14             	mov    %edx,0x14(%ebp)
f0103a18:	8b 00                	mov    (%eax),%eax
f0103a1a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103a1d:	89 c1                	mov    %eax,%ecx
f0103a1f:	c1 f9 1f             	sar    $0x1f,%ecx
f0103a22:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(' ', putdat);
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
f0103a25:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103a28:	8b 55 dc             	mov    -0x24(%ebp),%edx
				if ((long long) num < 0) {
					putch('-', putdat);
					num = -(long long) num;
				}
				base = 10;
f0103a2b:	b9 0a 00 00 00       	mov    $0xa,%ecx
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
				if ((long long) num < 0) {
f0103a30:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103a34:	79 74                	jns    f0103aaa <vprintfmt+0x35d>
					putch('-', putdat);
f0103a36:	83 ec 08             	sub    $0x8,%esp
f0103a39:	53                   	push   %ebx
f0103a3a:	6a 2d                	push   $0x2d
f0103a3c:	ff d6                	call   *%esi
					num = -(long long) num;
f0103a3e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103a41:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a44:	f7 d8                	neg    %eax
f0103a46:	83 d2 00             	adc    $0x0,%edx
f0103a49:	f7 da                	neg    %edx
f0103a4b:	83 c4 10             	add    $0x10,%esp
				}
				base = 10;
f0103a4e:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103a53:	eb 55                	jmp    f0103aaa <vprintfmt+0x35d>
				goto number;

			// unsigned decimal
			case 'u':
				num = getuint(&ap, lflag);
f0103a55:	8d 45 14             	lea    0x14(%ebp),%eax
f0103a58:	e8 7c fc ff ff       	call   f01036d9 <getuint>
				base = 10;
f0103a5d:	b9 0a 00 00 00       	mov    $0xa,%ecx
				goto number;
f0103a62:	eb 46                	jmp    f0103aaa <vprintfmt+0x35d>
				// Replace this with your code.
				/*putch('X', putdat);
				putch('X', putdat);
				putch('X', putdat);*/
				
				num = getuint(&ap, lflag);
f0103a64:	8d 45 14             	lea    0x14(%ebp),%eax
f0103a67:	e8 6d fc ff ff       	call   f01036d9 <getuint>
				base = 8;
f0103a6c:	b9 08 00 00 00       	mov    $0x8,%ecx
				goto number;
f0103a71:	eb 37                	jmp    f0103aaa <vprintfmt+0x35d>

			// pointer
			case 'p':
				putch('0', putdat);
f0103a73:	83 ec 08             	sub    $0x8,%esp
f0103a76:	53                   	push   %ebx
f0103a77:	6a 30                	push   $0x30
f0103a79:	ff d6                	call   *%esi
				putch('x', putdat);
f0103a7b:	83 c4 08             	add    $0x8,%esp
f0103a7e:	53                   	push   %ebx
f0103a7f:	6a 78                	push   $0x78
f0103a81:	ff d6                	call   *%esi
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
f0103a83:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a86:	8d 50 04             	lea    0x4(%eax),%edx
f0103a89:	89 55 14             	mov    %edx,0x14(%ebp)

			// pointer
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
f0103a8c:	8b 00                	mov    (%eax),%eax
f0103a8e:	ba 00 00 00 00       	mov    $0x0,%edx
					(uintptr_t) va_arg(ap, void *);
				base = 16;
				goto number;
f0103a93:	83 c4 10             	add    $0x10,%esp
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
				base = 16;
f0103a96:	b9 10 00 00 00       	mov    $0x10,%ecx
				goto number;
f0103a9b:	eb 0d                	jmp    f0103aaa <vprintfmt+0x35d>

			// (unsigned) hexadecimal
			case 'x':
				num = getuint(&ap, lflag);
f0103a9d:	8d 45 14             	lea    0x14(%ebp),%eax
f0103aa0:	e8 34 fc ff ff       	call   f01036d9 <getuint>
				base = 16;
f0103aa5:	b9 10 00 00 00       	mov    $0x10,%ecx
			number:
				printnum(putch, putdat, num, base, width, padc);
f0103aaa:	83 ec 0c             	sub    $0xc,%esp
f0103aad:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0103ab1:	57                   	push   %edi
f0103ab2:	ff 75 e0             	pushl  -0x20(%ebp)
f0103ab5:	51                   	push   %ecx
f0103ab6:	52                   	push   %edx
f0103ab7:	50                   	push   %eax
f0103ab8:	89 da                	mov    %ebx,%edx
f0103aba:	89 f0                	mov    %esi,%eax
f0103abc:	e8 6e fb ff ff       	call   f010362f <printnum>
				break;
f0103ac1:	83 c4 20             	add    $0x20,%esp
f0103ac4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103ac7:	e9 a7 fc ff ff       	jmp    f0103773 <vprintfmt+0x26>

			// escaped '%' character
			case '%':
				putch(ch, putdat);
f0103acc:	83 ec 08             	sub    $0x8,%esp
f0103acf:	53                   	push   %ebx
f0103ad0:	51                   	push   %ecx
f0103ad1:	ff d6                	call   *%esi
				break;
f0103ad3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0103ad6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				break;

			// escaped '%' character
			case '%':
				putch(ch, putdat);
				break;
f0103ad9:	e9 95 fc ff ff       	jmp    f0103773 <vprintfmt+0x26>

			// unrecognized escape sequence - just print it literally
			default:
				putch('%', putdat);
f0103ade:	83 ec 08             	sub    $0x8,%esp
f0103ae1:	53                   	push   %ebx
f0103ae2:	6a 25                	push   $0x25
f0103ae4:	ff d6                	call   *%esi
				for (fmt--; fmt[-1] != '%'; fmt--)
f0103ae6:	83 c4 10             	add    $0x10,%esp
f0103ae9:	eb 03                	jmp    f0103aee <vprintfmt+0x3a1>
f0103aeb:	83 ef 01             	sub    $0x1,%edi
f0103aee:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0103af2:	75 f7                	jne    f0103aeb <vprintfmt+0x39e>
f0103af4:	e9 7a fc ff ff       	jmp    f0103773 <vprintfmt+0x26>
					/* do nothing */;
				break;
		}
	}
}
f0103af9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103afc:	5b                   	pop    %ebx
f0103afd:	5e                   	pop    %esi
f0103afe:	5f                   	pop    %edi
f0103aff:	5d                   	pop    %ebp
f0103b00:	c3                   	ret    

f0103b01 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103b01:	55                   	push   %ebp
f0103b02:	89 e5                	mov    %esp,%ebp
f0103b04:	83 ec 18             	sub    $0x18,%esp
f0103b07:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b0a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103b0d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103b10:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103b14:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103b17:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103b1e:	85 c0                	test   %eax,%eax
f0103b20:	74 26                	je     f0103b48 <vsnprintf+0x47>
f0103b22:	85 d2                	test   %edx,%edx
f0103b24:	7e 22                	jle    f0103b48 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103b26:	ff 75 14             	pushl  0x14(%ebp)
f0103b29:	ff 75 10             	pushl  0x10(%ebp)
f0103b2c:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103b2f:	50                   	push   %eax
f0103b30:	68 13 37 10 f0       	push   $0xf0103713
f0103b35:	e8 13 fc ff ff       	call   f010374d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103b3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103b3d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103b43:	83 c4 10             	add    $0x10,%esp
f0103b46:	eb 05                	jmp    f0103b4d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103b48:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103b4d:	c9                   	leave  
f0103b4e:	c3                   	ret    

f0103b4f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103b4f:	55                   	push   %ebp
f0103b50:	89 e5                	mov    %esp,%ebp
f0103b52:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103b55:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103b58:	50                   	push   %eax
f0103b59:	ff 75 10             	pushl  0x10(%ebp)
f0103b5c:	ff 75 0c             	pushl  0xc(%ebp)
f0103b5f:	ff 75 08             	pushl  0x8(%ebp)
f0103b62:	e8 9a ff ff ff       	call   f0103b01 <vsnprintf>
	va_end(ap);

	return rc;
}
f0103b67:	c9                   	leave  
f0103b68:	c3                   	ret    

f0103b69 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103b69:	55                   	push   %ebp
f0103b6a:	89 e5                	mov    %esp,%ebp
f0103b6c:	57                   	push   %edi
f0103b6d:	56                   	push   %esi
f0103b6e:	53                   	push   %ebx
f0103b6f:	83 ec 0c             	sub    $0xc,%esp
f0103b72:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103b75:	85 c0                	test   %eax,%eax
f0103b77:	74 11                	je     f0103b8a <readline+0x21>
		cprintf("%s", prompt);
f0103b79:	83 ec 08             	sub    $0x8,%esp
f0103b7c:	50                   	push   %eax
f0103b7d:	68 11 50 10 f0       	push   $0xf0105011
f0103b82:	e8 62 f3 ff ff       	call   f0102ee9 <cprintf>
f0103b87:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103b8a:	83 ec 0c             	sub    $0xc,%esp
f0103b8d:	6a 00                	push   $0x0
f0103b8f:	e8 82 ca ff ff       	call   f0100616 <iscons>
f0103b94:	89 c7                	mov    %eax,%edi
f0103b96:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103b99:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103b9e:	e8 62 ca ff ff       	call   f0100605 <getchar>
f0103ba3:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103ba5:	85 c0                	test   %eax,%eax
f0103ba7:	79 18                	jns    f0103bc1 <readline+0x58>
			cprintf("read error: %e\n", c);
f0103ba9:	83 ec 08             	sub    $0x8,%esp
f0103bac:	50                   	push   %eax
f0103bad:	68 e0 59 10 f0       	push   $0xf01059e0
f0103bb2:	e8 32 f3 ff ff       	call   f0102ee9 <cprintf>
			return NULL;
f0103bb7:	83 c4 10             	add    $0x10,%esp
f0103bba:	b8 00 00 00 00       	mov    $0x0,%eax
f0103bbf:	eb 79                	jmp    f0103c3a <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103bc1:	83 f8 7f             	cmp    $0x7f,%eax
f0103bc4:	0f 94 c2             	sete   %dl
f0103bc7:	83 f8 08             	cmp    $0x8,%eax
f0103bca:	0f 94 c0             	sete   %al
f0103bcd:	08 c2                	or     %al,%dl
f0103bcf:	74 1a                	je     f0103beb <readline+0x82>
f0103bd1:	85 f6                	test   %esi,%esi
f0103bd3:	7e 16                	jle    f0103beb <readline+0x82>
			if (echoing)
f0103bd5:	85 ff                	test   %edi,%edi
f0103bd7:	74 0d                	je     f0103be6 <readline+0x7d>
				cputchar('\b');
f0103bd9:	83 ec 0c             	sub    $0xc,%esp
f0103bdc:	6a 08                	push   $0x8
f0103bde:	e8 12 ca ff ff       	call   f01005f5 <cputchar>
f0103be3:	83 c4 10             	add    $0x10,%esp
			i--;
f0103be6:	83 ee 01             	sub    $0x1,%esi
f0103be9:	eb b3                	jmp    f0103b9e <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103beb:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103bf1:	7f 20                	jg     f0103c13 <readline+0xaa>
f0103bf3:	83 fb 1f             	cmp    $0x1f,%ebx
f0103bf6:	7e 1b                	jle    f0103c13 <readline+0xaa>
			if (echoing)
f0103bf8:	85 ff                	test   %edi,%edi
f0103bfa:	74 0c                	je     f0103c08 <readline+0x9f>
				cputchar(c);
f0103bfc:	83 ec 0c             	sub    $0xc,%esp
f0103bff:	53                   	push   %ebx
f0103c00:	e8 f0 c9 ff ff       	call   f01005f5 <cputchar>
f0103c05:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103c08:	88 9e 00 9b 17 f0    	mov    %bl,-0xfe86500(%esi)
f0103c0e:	8d 76 01             	lea    0x1(%esi),%esi
f0103c11:	eb 8b                	jmp    f0103b9e <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0103c13:	83 fb 0d             	cmp    $0xd,%ebx
f0103c16:	74 05                	je     f0103c1d <readline+0xb4>
f0103c18:	83 fb 0a             	cmp    $0xa,%ebx
f0103c1b:	75 81                	jne    f0103b9e <readline+0x35>
			if (echoing)
f0103c1d:	85 ff                	test   %edi,%edi
f0103c1f:	74 0d                	je     f0103c2e <readline+0xc5>
				cputchar('\n');
f0103c21:	83 ec 0c             	sub    $0xc,%esp
f0103c24:	6a 0a                	push   $0xa
f0103c26:	e8 ca c9 ff ff       	call   f01005f5 <cputchar>
f0103c2b:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0103c2e:	c6 86 00 9b 17 f0 00 	movb   $0x0,-0xfe86500(%esi)
			return buf;
f0103c35:	b8 00 9b 17 f0       	mov    $0xf0179b00,%eax
		}
	}
}
f0103c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103c3d:	5b                   	pop    %ebx
f0103c3e:	5e                   	pop    %esi
f0103c3f:	5f                   	pop    %edi
f0103c40:	5d                   	pop    %ebp
f0103c41:	c3                   	ret    

f0103c42 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103c42:	55                   	push   %ebp
f0103c43:	89 e5                	mov    %esp,%ebp
f0103c45:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103c48:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c4d:	eb 03                	jmp    f0103c52 <strlen+0x10>
		n++;
f0103c4f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103c52:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103c56:	75 f7                	jne    f0103c4f <strlen+0xd>
		n++;
	return n;
}
f0103c58:	5d                   	pop    %ebp
f0103c59:	c3                   	ret    

f0103c5a <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103c5a:	55                   	push   %ebp
f0103c5b:	89 e5                	mov    %esp,%ebp
f0103c5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103c60:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103c63:	ba 00 00 00 00       	mov    $0x0,%edx
f0103c68:	eb 03                	jmp    f0103c6d <strnlen+0x13>
		n++;
f0103c6a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103c6d:	39 c2                	cmp    %eax,%edx
f0103c6f:	74 08                	je     f0103c79 <strnlen+0x1f>
f0103c71:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0103c75:	75 f3                	jne    f0103c6a <strnlen+0x10>
f0103c77:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0103c79:	5d                   	pop    %ebp
f0103c7a:	c3                   	ret    

f0103c7b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103c7b:	55                   	push   %ebp
f0103c7c:	89 e5                	mov    %esp,%ebp
f0103c7e:	53                   	push   %ebx
f0103c7f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103c85:	89 c2                	mov    %eax,%edx
f0103c87:	83 c2 01             	add    $0x1,%edx
f0103c8a:	83 c1 01             	add    $0x1,%ecx
f0103c8d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0103c91:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103c94:	84 db                	test   %bl,%bl
f0103c96:	75 ef                	jne    f0103c87 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103c98:	5b                   	pop    %ebx
f0103c99:	5d                   	pop    %ebp
f0103c9a:	c3                   	ret    

f0103c9b <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103c9b:	55                   	push   %ebp
f0103c9c:	89 e5                	mov    %esp,%ebp
f0103c9e:	53                   	push   %ebx
f0103c9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103ca2:	53                   	push   %ebx
f0103ca3:	e8 9a ff ff ff       	call   f0103c42 <strlen>
f0103ca8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103cab:	ff 75 0c             	pushl  0xc(%ebp)
f0103cae:	01 d8                	add    %ebx,%eax
f0103cb0:	50                   	push   %eax
f0103cb1:	e8 c5 ff ff ff       	call   f0103c7b <strcpy>
	return dst;
}
f0103cb6:	89 d8                	mov    %ebx,%eax
f0103cb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103cbb:	c9                   	leave  
f0103cbc:	c3                   	ret    

f0103cbd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103cbd:	55                   	push   %ebp
f0103cbe:	89 e5                	mov    %esp,%ebp
f0103cc0:	56                   	push   %esi
f0103cc1:	53                   	push   %ebx
f0103cc2:	8b 75 08             	mov    0x8(%ebp),%esi
f0103cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103cc8:	89 f3                	mov    %esi,%ebx
f0103cca:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103ccd:	89 f2                	mov    %esi,%edx
f0103ccf:	eb 0f                	jmp    f0103ce0 <strncpy+0x23>
		*dst++ = *src;
f0103cd1:	83 c2 01             	add    $0x1,%edx
f0103cd4:	0f b6 01             	movzbl (%ecx),%eax
f0103cd7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103cda:	80 39 01             	cmpb   $0x1,(%ecx)
f0103cdd:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103ce0:	39 da                	cmp    %ebx,%edx
f0103ce2:	75 ed                	jne    f0103cd1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103ce4:	89 f0                	mov    %esi,%eax
f0103ce6:	5b                   	pop    %ebx
f0103ce7:	5e                   	pop    %esi
f0103ce8:	5d                   	pop    %ebp
f0103ce9:	c3                   	ret    

f0103cea <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103cea:	55                   	push   %ebp
f0103ceb:	89 e5                	mov    %esp,%ebp
f0103ced:	56                   	push   %esi
f0103cee:	53                   	push   %ebx
f0103cef:	8b 75 08             	mov    0x8(%ebp),%esi
f0103cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103cf5:	8b 55 10             	mov    0x10(%ebp),%edx
f0103cf8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103cfa:	85 d2                	test   %edx,%edx
f0103cfc:	74 21                	je     f0103d1f <strlcpy+0x35>
f0103cfe:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103d02:	89 f2                	mov    %esi,%edx
f0103d04:	eb 09                	jmp    f0103d0f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103d06:	83 c2 01             	add    $0x1,%edx
f0103d09:	83 c1 01             	add    $0x1,%ecx
f0103d0c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103d0f:	39 c2                	cmp    %eax,%edx
f0103d11:	74 09                	je     f0103d1c <strlcpy+0x32>
f0103d13:	0f b6 19             	movzbl (%ecx),%ebx
f0103d16:	84 db                	test   %bl,%bl
f0103d18:	75 ec                	jne    f0103d06 <strlcpy+0x1c>
f0103d1a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0103d1c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103d1f:	29 f0                	sub    %esi,%eax
}
f0103d21:	5b                   	pop    %ebx
f0103d22:	5e                   	pop    %esi
f0103d23:	5d                   	pop    %ebp
f0103d24:	c3                   	ret    

f0103d25 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103d25:	55                   	push   %ebp
f0103d26:	89 e5                	mov    %esp,%ebp
f0103d28:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103d2b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103d2e:	eb 06                	jmp    f0103d36 <strcmp+0x11>
		p++, q++;
f0103d30:	83 c1 01             	add    $0x1,%ecx
f0103d33:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103d36:	0f b6 01             	movzbl (%ecx),%eax
f0103d39:	84 c0                	test   %al,%al
f0103d3b:	74 04                	je     f0103d41 <strcmp+0x1c>
f0103d3d:	3a 02                	cmp    (%edx),%al
f0103d3f:	74 ef                	je     f0103d30 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103d41:	0f b6 c0             	movzbl %al,%eax
f0103d44:	0f b6 12             	movzbl (%edx),%edx
f0103d47:	29 d0                	sub    %edx,%eax
}
f0103d49:	5d                   	pop    %ebp
f0103d4a:	c3                   	ret    

f0103d4b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103d4b:	55                   	push   %ebp
f0103d4c:	89 e5                	mov    %esp,%ebp
f0103d4e:	53                   	push   %ebx
f0103d4f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d52:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103d55:	89 c3                	mov    %eax,%ebx
f0103d57:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103d5a:	eb 06                	jmp    f0103d62 <strncmp+0x17>
		n--, p++, q++;
f0103d5c:	83 c0 01             	add    $0x1,%eax
f0103d5f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103d62:	39 d8                	cmp    %ebx,%eax
f0103d64:	74 15                	je     f0103d7b <strncmp+0x30>
f0103d66:	0f b6 08             	movzbl (%eax),%ecx
f0103d69:	84 c9                	test   %cl,%cl
f0103d6b:	74 04                	je     f0103d71 <strncmp+0x26>
f0103d6d:	3a 0a                	cmp    (%edx),%cl
f0103d6f:	74 eb                	je     f0103d5c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103d71:	0f b6 00             	movzbl (%eax),%eax
f0103d74:	0f b6 12             	movzbl (%edx),%edx
f0103d77:	29 d0                	sub    %edx,%eax
f0103d79:	eb 05                	jmp    f0103d80 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103d7b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103d80:	5b                   	pop    %ebx
f0103d81:	5d                   	pop    %ebp
f0103d82:	c3                   	ret    

f0103d83 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103d83:	55                   	push   %ebp
f0103d84:	89 e5                	mov    %esp,%ebp
f0103d86:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d89:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103d8d:	eb 07                	jmp    f0103d96 <strchr+0x13>
		if (*s == c)
f0103d8f:	38 ca                	cmp    %cl,%dl
f0103d91:	74 0f                	je     f0103da2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103d93:	83 c0 01             	add    $0x1,%eax
f0103d96:	0f b6 10             	movzbl (%eax),%edx
f0103d99:	84 d2                	test   %dl,%dl
f0103d9b:	75 f2                	jne    f0103d8f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0103d9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103da2:	5d                   	pop    %ebp
f0103da3:	c3                   	ret    

f0103da4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103da4:	55                   	push   %ebp
f0103da5:	89 e5                	mov    %esp,%ebp
f0103da7:	8b 45 08             	mov    0x8(%ebp),%eax
f0103daa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103dae:	eb 03                	jmp    f0103db3 <strfind+0xf>
f0103db0:	83 c0 01             	add    $0x1,%eax
f0103db3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103db6:	84 d2                	test   %dl,%dl
f0103db8:	74 04                	je     f0103dbe <strfind+0x1a>
f0103dba:	38 ca                	cmp    %cl,%dl
f0103dbc:	75 f2                	jne    f0103db0 <strfind+0xc>
			break;
	return (char *) s;
}
f0103dbe:	5d                   	pop    %ebp
f0103dbf:	c3                   	ret    

f0103dc0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103dc0:	55                   	push   %ebp
f0103dc1:	89 e5                	mov    %esp,%ebp
f0103dc3:	57                   	push   %edi
f0103dc4:	56                   	push   %esi
f0103dc5:	53                   	push   %ebx
f0103dc6:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103dc9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103dcc:	85 c9                	test   %ecx,%ecx
f0103dce:	74 36                	je     f0103e06 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103dd0:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103dd6:	75 28                	jne    f0103e00 <memset+0x40>
f0103dd8:	f6 c1 03             	test   $0x3,%cl
f0103ddb:	75 23                	jne    f0103e00 <memset+0x40>
		c &= 0xFF;
f0103ddd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103de1:	89 d3                	mov    %edx,%ebx
f0103de3:	c1 e3 08             	shl    $0x8,%ebx
f0103de6:	89 d6                	mov    %edx,%esi
f0103de8:	c1 e6 18             	shl    $0x18,%esi
f0103deb:	89 d0                	mov    %edx,%eax
f0103ded:	c1 e0 10             	shl    $0x10,%eax
f0103df0:	09 f0                	or     %esi,%eax
f0103df2:	09 c2                	or     %eax,%edx
f0103df4:	89 d0                	mov    %edx,%eax
f0103df6:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103df8:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0103dfb:	fc                   	cld    
f0103dfc:	f3 ab                	rep stos %eax,%es:(%edi)
f0103dfe:	eb 06                	jmp    f0103e06 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103e00:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e03:	fc                   	cld    
f0103e04:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103e06:	89 f8                	mov    %edi,%eax
f0103e08:	5b                   	pop    %ebx
f0103e09:	5e                   	pop    %esi
f0103e0a:	5f                   	pop    %edi
f0103e0b:	5d                   	pop    %ebp
f0103e0c:	c3                   	ret    

f0103e0d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103e0d:	55                   	push   %ebp
f0103e0e:	89 e5                	mov    %esp,%ebp
f0103e10:	57                   	push   %edi
f0103e11:	56                   	push   %esi
f0103e12:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e15:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103e18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103e1b:	39 c6                	cmp    %eax,%esi
f0103e1d:	73 35                	jae    f0103e54 <memmove+0x47>
f0103e1f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103e22:	39 d0                	cmp    %edx,%eax
f0103e24:	73 2e                	jae    f0103e54 <memmove+0x47>
		s += n;
		d += n;
f0103e26:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0103e29:	89 d6                	mov    %edx,%esi
f0103e2b:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103e2d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103e33:	75 13                	jne    f0103e48 <memmove+0x3b>
f0103e35:	f6 c1 03             	test   $0x3,%cl
f0103e38:	75 0e                	jne    f0103e48 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103e3a:	83 ef 04             	sub    $0x4,%edi
f0103e3d:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103e40:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0103e43:	fd                   	std    
f0103e44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103e46:	eb 09                	jmp    f0103e51 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103e48:	83 ef 01             	sub    $0x1,%edi
f0103e4b:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103e4e:	fd                   	std    
f0103e4f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103e51:	fc                   	cld    
f0103e52:	eb 1d                	jmp    f0103e71 <memmove+0x64>
f0103e54:	89 f2                	mov    %esi,%edx
f0103e56:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103e58:	f6 c2 03             	test   $0x3,%dl
f0103e5b:	75 0f                	jne    f0103e6c <memmove+0x5f>
f0103e5d:	f6 c1 03             	test   $0x3,%cl
f0103e60:	75 0a                	jne    f0103e6c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103e62:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0103e65:	89 c7                	mov    %eax,%edi
f0103e67:	fc                   	cld    
f0103e68:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103e6a:	eb 05                	jmp    f0103e71 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103e6c:	89 c7                	mov    %eax,%edi
f0103e6e:	fc                   	cld    
f0103e6f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103e71:	5e                   	pop    %esi
f0103e72:	5f                   	pop    %edi
f0103e73:	5d                   	pop    %ebp
f0103e74:	c3                   	ret    

f0103e75 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103e75:	55                   	push   %ebp
f0103e76:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0103e78:	ff 75 10             	pushl  0x10(%ebp)
f0103e7b:	ff 75 0c             	pushl  0xc(%ebp)
f0103e7e:	ff 75 08             	pushl  0x8(%ebp)
f0103e81:	e8 87 ff ff ff       	call   f0103e0d <memmove>
}
f0103e86:	c9                   	leave  
f0103e87:	c3                   	ret    

f0103e88 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103e88:	55                   	push   %ebp
f0103e89:	89 e5                	mov    %esp,%ebp
f0103e8b:	56                   	push   %esi
f0103e8c:	53                   	push   %ebx
f0103e8d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e90:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103e93:	89 c6                	mov    %eax,%esi
f0103e95:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103e98:	eb 1a                	jmp    f0103eb4 <memcmp+0x2c>
		if (*s1 != *s2)
f0103e9a:	0f b6 08             	movzbl (%eax),%ecx
f0103e9d:	0f b6 1a             	movzbl (%edx),%ebx
f0103ea0:	38 d9                	cmp    %bl,%cl
f0103ea2:	74 0a                	je     f0103eae <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0103ea4:	0f b6 c1             	movzbl %cl,%eax
f0103ea7:	0f b6 db             	movzbl %bl,%ebx
f0103eaa:	29 d8                	sub    %ebx,%eax
f0103eac:	eb 0f                	jmp    f0103ebd <memcmp+0x35>
		s1++, s2++;
f0103eae:	83 c0 01             	add    $0x1,%eax
f0103eb1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103eb4:	39 f0                	cmp    %esi,%eax
f0103eb6:	75 e2                	jne    f0103e9a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103eb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103ebd:	5b                   	pop    %ebx
f0103ebe:	5e                   	pop    %esi
f0103ebf:	5d                   	pop    %ebp
f0103ec0:	c3                   	ret    

f0103ec1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103ec1:	55                   	push   %ebp
f0103ec2:	89 e5                	mov    %esp,%ebp
f0103ec4:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ec7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103eca:	89 c2                	mov    %eax,%edx
f0103ecc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103ecf:	eb 07                	jmp    f0103ed8 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103ed1:	38 08                	cmp    %cl,(%eax)
f0103ed3:	74 07                	je     f0103edc <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103ed5:	83 c0 01             	add    $0x1,%eax
f0103ed8:	39 d0                	cmp    %edx,%eax
f0103eda:	72 f5                	jb     f0103ed1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103edc:	5d                   	pop    %ebp
f0103edd:	c3                   	ret    

f0103ede <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103ede:	55                   	push   %ebp
f0103edf:	89 e5                	mov    %esp,%ebp
f0103ee1:	57                   	push   %edi
f0103ee2:	56                   	push   %esi
f0103ee3:	53                   	push   %ebx
f0103ee4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103ee7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103eea:	eb 03                	jmp    f0103eef <strtol+0x11>
		s++;
f0103eec:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103eef:	0f b6 01             	movzbl (%ecx),%eax
f0103ef2:	3c 09                	cmp    $0x9,%al
f0103ef4:	74 f6                	je     f0103eec <strtol+0xe>
f0103ef6:	3c 20                	cmp    $0x20,%al
f0103ef8:	74 f2                	je     f0103eec <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103efa:	3c 2b                	cmp    $0x2b,%al
f0103efc:	75 0a                	jne    f0103f08 <strtol+0x2a>
		s++;
f0103efe:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103f01:	bf 00 00 00 00       	mov    $0x0,%edi
f0103f06:	eb 10                	jmp    f0103f18 <strtol+0x3a>
f0103f08:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103f0d:	3c 2d                	cmp    $0x2d,%al
f0103f0f:	75 07                	jne    f0103f18 <strtol+0x3a>
		s++, neg = 1;
f0103f11:	8d 49 01             	lea    0x1(%ecx),%ecx
f0103f14:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103f18:	85 db                	test   %ebx,%ebx
f0103f1a:	0f 94 c0             	sete   %al
f0103f1d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0103f23:	75 19                	jne    f0103f3e <strtol+0x60>
f0103f25:	80 39 30             	cmpb   $0x30,(%ecx)
f0103f28:	75 14                	jne    f0103f3e <strtol+0x60>
f0103f2a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103f2e:	0f 85 82 00 00 00    	jne    f0103fb6 <strtol+0xd8>
		s += 2, base = 16;
f0103f34:	83 c1 02             	add    $0x2,%ecx
f0103f37:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103f3c:	eb 16                	jmp    f0103f54 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0103f3e:	84 c0                	test   %al,%al
f0103f40:	74 12                	je     f0103f54 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103f42:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103f47:	80 39 30             	cmpb   $0x30,(%ecx)
f0103f4a:	75 08                	jne    f0103f54 <strtol+0x76>
		s++, base = 8;
f0103f4c:	83 c1 01             	add    $0x1,%ecx
f0103f4f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0103f54:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f59:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103f5c:	0f b6 11             	movzbl (%ecx),%edx
f0103f5f:	8d 72 d0             	lea    -0x30(%edx),%esi
f0103f62:	89 f3                	mov    %esi,%ebx
f0103f64:	80 fb 09             	cmp    $0x9,%bl
f0103f67:	77 08                	ja     f0103f71 <strtol+0x93>
			dig = *s - '0';
f0103f69:	0f be d2             	movsbl %dl,%edx
f0103f6c:	83 ea 30             	sub    $0x30,%edx
f0103f6f:	eb 22                	jmp    f0103f93 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
f0103f71:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103f74:	89 f3                	mov    %esi,%ebx
f0103f76:	80 fb 19             	cmp    $0x19,%bl
f0103f79:	77 08                	ja     f0103f83 <strtol+0xa5>
			dig = *s - 'a' + 10;
f0103f7b:	0f be d2             	movsbl %dl,%edx
f0103f7e:	83 ea 57             	sub    $0x57,%edx
f0103f81:	eb 10                	jmp    f0103f93 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
f0103f83:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103f86:	89 f3                	mov    %esi,%ebx
f0103f88:	80 fb 19             	cmp    $0x19,%bl
f0103f8b:	77 16                	ja     f0103fa3 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0103f8d:	0f be d2             	movsbl %dl,%edx
f0103f90:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0103f93:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103f96:	7d 0f                	jge    f0103fa7 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
f0103f98:	83 c1 01             	add    $0x1,%ecx
f0103f9b:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103f9f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0103fa1:	eb b9                	jmp    f0103f5c <strtol+0x7e>
f0103fa3:	89 c2                	mov    %eax,%edx
f0103fa5:	eb 02                	jmp    f0103fa9 <strtol+0xcb>
f0103fa7:	89 c2                	mov    %eax,%edx

	if (endptr)
f0103fa9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103fad:	74 0d                	je     f0103fbc <strtol+0xde>
		*endptr = (char *) s;
f0103faf:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103fb2:	89 0e                	mov    %ecx,(%esi)
f0103fb4:	eb 06                	jmp    f0103fbc <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103fb6:	84 c0                	test   %al,%al
f0103fb8:	75 92                	jne    f0103f4c <strtol+0x6e>
f0103fba:	eb 98                	jmp    f0103f54 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0103fbc:	f7 da                	neg    %edx
f0103fbe:	85 ff                	test   %edi,%edi
f0103fc0:	0f 45 c2             	cmovne %edx,%eax
}
f0103fc3:	5b                   	pop    %ebx
f0103fc4:	5e                   	pop    %esi
f0103fc5:	5f                   	pop    %edi
f0103fc6:	5d                   	pop    %ebp
f0103fc7:	c3                   	ret    
f0103fc8:	66 90                	xchg   %ax,%ax
f0103fca:	66 90                	xchg   %ax,%ax
f0103fcc:	66 90                	xchg   %ax,%ax
f0103fce:	66 90                	xchg   %ax,%ax

f0103fd0 <__udivdi3>:
f0103fd0:	55                   	push   %ebp
f0103fd1:	57                   	push   %edi
f0103fd2:	56                   	push   %esi
f0103fd3:	83 ec 10             	sub    $0x10,%esp
f0103fd6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
f0103fda:	8b 7c 24 20          	mov    0x20(%esp),%edi
f0103fde:	8b 74 24 24          	mov    0x24(%esp),%esi
f0103fe2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0103fe6:	85 d2                	test   %edx,%edx
f0103fe8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103fec:	89 34 24             	mov    %esi,(%esp)
f0103fef:	89 c8                	mov    %ecx,%eax
f0103ff1:	75 35                	jne    f0104028 <__udivdi3+0x58>
f0103ff3:	39 f1                	cmp    %esi,%ecx
f0103ff5:	0f 87 bd 00 00 00    	ja     f01040b8 <__udivdi3+0xe8>
f0103ffb:	85 c9                	test   %ecx,%ecx
f0103ffd:	89 cd                	mov    %ecx,%ebp
f0103fff:	75 0b                	jne    f010400c <__udivdi3+0x3c>
f0104001:	b8 01 00 00 00       	mov    $0x1,%eax
f0104006:	31 d2                	xor    %edx,%edx
f0104008:	f7 f1                	div    %ecx
f010400a:	89 c5                	mov    %eax,%ebp
f010400c:	89 f0                	mov    %esi,%eax
f010400e:	31 d2                	xor    %edx,%edx
f0104010:	f7 f5                	div    %ebp
f0104012:	89 c6                	mov    %eax,%esi
f0104014:	89 f8                	mov    %edi,%eax
f0104016:	f7 f5                	div    %ebp
f0104018:	89 f2                	mov    %esi,%edx
f010401a:	83 c4 10             	add    $0x10,%esp
f010401d:	5e                   	pop    %esi
f010401e:	5f                   	pop    %edi
f010401f:	5d                   	pop    %ebp
f0104020:	c3                   	ret    
f0104021:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104028:	3b 14 24             	cmp    (%esp),%edx
f010402b:	77 7b                	ja     f01040a8 <__udivdi3+0xd8>
f010402d:	0f bd f2             	bsr    %edx,%esi
f0104030:	83 f6 1f             	xor    $0x1f,%esi
f0104033:	0f 84 97 00 00 00    	je     f01040d0 <__udivdi3+0x100>
f0104039:	bd 20 00 00 00       	mov    $0x20,%ebp
f010403e:	89 d7                	mov    %edx,%edi
f0104040:	89 f1                	mov    %esi,%ecx
f0104042:	29 f5                	sub    %esi,%ebp
f0104044:	d3 e7                	shl    %cl,%edi
f0104046:	89 c2                	mov    %eax,%edx
f0104048:	89 e9                	mov    %ebp,%ecx
f010404a:	d3 ea                	shr    %cl,%edx
f010404c:	89 f1                	mov    %esi,%ecx
f010404e:	09 fa                	or     %edi,%edx
f0104050:	8b 3c 24             	mov    (%esp),%edi
f0104053:	d3 e0                	shl    %cl,%eax
f0104055:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104059:	89 e9                	mov    %ebp,%ecx
f010405b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010405f:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104063:	89 fa                	mov    %edi,%edx
f0104065:	d3 ea                	shr    %cl,%edx
f0104067:	89 f1                	mov    %esi,%ecx
f0104069:	d3 e7                	shl    %cl,%edi
f010406b:	89 e9                	mov    %ebp,%ecx
f010406d:	d3 e8                	shr    %cl,%eax
f010406f:	09 c7                	or     %eax,%edi
f0104071:	89 f8                	mov    %edi,%eax
f0104073:	f7 74 24 08          	divl   0x8(%esp)
f0104077:	89 d5                	mov    %edx,%ebp
f0104079:	89 c7                	mov    %eax,%edi
f010407b:	f7 64 24 0c          	mull   0xc(%esp)
f010407f:	39 d5                	cmp    %edx,%ebp
f0104081:	89 14 24             	mov    %edx,(%esp)
f0104084:	72 11                	jb     f0104097 <__udivdi3+0xc7>
f0104086:	8b 54 24 04          	mov    0x4(%esp),%edx
f010408a:	89 f1                	mov    %esi,%ecx
f010408c:	d3 e2                	shl    %cl,%edx
f010408e:	39 c2                	cmp    %eax,%edx
f0104090:	73 5e                	jae    f01040f0 <__udivdi3+0x120>
f0104092:	3b 2c 24             	cmp    (%esp),%ebp
f0104095:	75 59                	jne    f01040f0 <__udivdi3+0x120>
f0104097:	8d 47 ff             	lea    -0x1(%edi),%eax
f010409a:	31 f6                	xor    %esi,%esi
f010409c:	89 f2                	mov    %esi,%edx
f010409e:	83 c4 10             	add    $0x10,%esp
f01040a1:	5e                   	pop    %esi
f01040a2:	5f                   	pop    %edi
f01040a3:	5d                   	pop    %ebp
f01040a4:	c3                   	ret    
f01040a5:	8d 76 00             	lea    0x0(%esi),%esi
f01040a8:	31 f6                	xor    %esi,%esi
f01040aa:	31 c0                	xor    %eax,%eax
f01040ac:	89 f2                	mov    %esi,%edx
f01040ae:	83 c4 10             	add    $0x10,%esp
f01040b1:	5e                   	pop    %esi
f01040b2:	5f                   	pop    %edi
f01040b3:	5d                   	pop    %ebp
f01040b4:	c3                   	ret    
f01040b5:	8d 76 00             	lea    0x0(%esi),%esi
f01040b8:	89 f2                	mov    %esi,%edx
f01040ba:	31 f6                	xor    %esi,%esi
f01040bc:	89 f8                	mov    %edi,%eax
f01040be:	f7 f1                	div    %ecx
f01040c0:	89 f2                	mov    %esi,%edx
f01040c2:	83 c4 10             	add    $0x10,%esp
f01040c5:	5e                   	pop    %esi
f01040c6:	5f                   	pop    %edi
f01040c7:	5d                   	pop    %ebp
f01040c8:	c3                   	ret    
f01040c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01040d0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f01040d4:	76 0b                	jbe    f01040e1 <__udivdi3+0x111>
f01040d6:	31 c0                	xor    %eax,%eax
f01040d8:	3b 14 24             	cmp    (%esp),%edx
f01040db:	0f 83 37 ff ff ff    	jae    f0104018 <__udivdi3+0x48>
f01040e1:	b8 01 00 00 00       	mov    $0x1,%eax
f01040e6:	e9 2d ff ff ff       	jmp    f0104018 <__udivdi3+0x48>
f01040eb:	90                   	nop
f01040ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01040f0:	89 f8                	mov    %edi,%eax
f01040f2:	31 f6                	xor    %esi,%esi
f01040f4:	e9 1f ff ff ff       	jmp    f0104018 <__udivdi3+0x48>
f01040f9:	66 90                	xchg   %ax,%ax
f01040fb:	66 90                	xchg   %ax,%ax
f01040fd:	66 90                	xchg   %ax,%ax
f01040ff:	90                   	nop

f0104100 <__umoddi3>:
f0104100:	55                   	push   %ebp
f0104101:	57                   	push   %edi
f0104102:	56                   	push   %esi
f0104103:	83 ec 20             	sub    $0x20,%esp
f0104106:	8b 44 24 34          	mov    0x34(%esp),%eax
f010410a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010410e:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104112:	89 c6                	mov    %eax,%esi
f0104114:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104118:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010411c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
f0104120:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104124:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f0104128:	89 74 24 18          	mov    %esi,0x18(%esp)
f010412c:	85 c0                	test   %eax,%eax
f010412e:	89 c2                	mov    %eax,%edx
f0104130:	75 1e                	jne    f0104150 <__umoddi3+0x50>
f0104132:	39 f7                	cmp    %esi,%edi
f0104134:	76 52                	jbe    f0104188 <__umoddi3+0x88>
f0104136:	89 c8                	mov    %ecx,%eax
f0104138:	89 f2                	mov    %esi,%edx
f010413a:	f7 f7                	div    %edi
f010413c:	89 d0                	mov    %edx,%eax
f010413e:	31 d2                	xor    %edx,%edx
f0104140:	83 c4 20             	add    $0x20,%esp
f0104143:	5e                   	pop    %esi
f0104144:	5f                   	pop    %edi
f0104145:	5d                   	pop    %ebp
f0104146:	c3                   	ret    
f0104147:	89 f6                	mov    %esi,%esi
f0104149:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0104150:	39 f0                	cmp    %esi,%eax
f0104152:	77 5c                	ja     f01041b0 <__umoddi3+0xb0>
f0104154:	0f bd e8             	bsr    %eax,%ebp
f0104157:	83 f5 1f             	xor    $0x1f,%ebp
f010415a:	75 64                	jne    f01041c0 <__umoddi3+0xc0>
f010415c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
f0104160:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
f0104164:	0f 86 f6 00 00 00    	jbe    f0104260 <__umoddi3+0x160>
f010416a:	3b 44 24 18          	cmp    0x18(%esp),%eax
f010416e:	0f 82 ec 00 00 00    	jb     f0104260 <__umoddi3+0x160>
f0104174:	8b 44 24 14          	mov    0x14(%esp),%eax
f0104178:	8b 54 24 18          	mov    0x18(%esp),%edx
f010417c:	83 c4 20             	add    $0x20,%esp
f010417f:	5e                   	pop    %esi
f0104180:	5f                   	pop    %edi
f0104181:	5d                   	pop    %ebp
f0104182:	c3                   	ret    
f0104183:	90                   	nop
f0104184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104188:	85 ff                	test   %edi,%edi
f010418a:	89 fd                	mov    %edi,%ebp
f010418c:	75 0b                	jne    f0104199 <__umoddi3+0x99>
f010418e:	b8 01 00 00 00       	mov    $0x1,%eax
f0104193:	31 d2                	xor    %edx,%edx
f0104195:	f7 f7                	div    %edi
f0104197:	89 c5                	mov    %eax,%ebp
f0104199:	8b 44 24 10          	mov    0x10(%esp),%eax
f010419d:	31 d2                	xor    %edx,%edx
f010419f:	f7 f5                	div    %ebp
f01041a1:	89 c8                	mov    %ecx,%eax
f01041a3:	f7 f5                	div    %ebp
f01041a5:	eb 95                	jmp    f010413c <__umoddi3+0x3c>
f01041a7:	89 f6                	mov    %esi,%esi
f01041a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01041b0:	89 c8                	mov    %ecx,%eax
f01041b2:	89 f2                	mov    %esi,%edx
f01041b4:	83 c4 20             	add    $0x20,%esp
f01041b7:	5e                   	pop    %esi
f01041b8:	5f                   	pop    %edi
f01041b9:	5d                   	pop    %ebp
f01041ba:	c3                   	ret    
f01041bb:	90                   	nop
f01041bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01041c0:	b8 20 00 00 00       	mov    $0x20,%eax
f01041c5:	89 e9                	mov    %ebp,%ecx
f01041c7:	29 e8                	sub    %ebp,%eax
f01041c9:	d3 e2                	shl    %cl,%edx
f01041cb:	89 c7                	mov    %eax,%edi
f01041cd:	89 44 24 18          	mov    %eax,0x18(%esp)
f01041d1:	8b 44 24 0c          	mov    0xc(%esp),%eax
f01041d5:	89 f9                	mov    %edi,%ecx
f01041d7:	d3 e8                	shr    %cl,%eax
f01041d9:	89 c1                	mov    %eax,%ecx
f01041db:	8b 44 24 0c          	mov    0xc(%esp),%eax
f01041df:	09 d1                	or     %edx,%ecx
f01041e1:	89 fa                	mov    %edi,%edx
f01041e3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f01041e7:	89 e9                	mov    %ebp,%ecx
f01041e9:	d3 e0                	shl    %cl,%eax
f01041eb:	89 f9                	mov    %edi,%ecx
f01041ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01041f1:	89 f0                	mov    %esi,%eax
f01041f3:	d3 e8                	shr    %cl,%eax
f01041f5:	89 e9                	mov    %ebp,%ecx
f01041f7:	89 c7                	mov    %eax,%edi
f01041f9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f01041fd:	d3 e6                	shl    %cl,%esi
f01041ff:	89 d1                	mov    %edx,%ecx
f0104201:	89 fa                	mov    %edi,%edx
f0104203:	d3 e8                	shr    %cl,%eax
f0104205:	89 e9                	mov    %ebp,%ecx
f0104207:	09 f0                	or     %esi,%eax
f0104209:	8b 74 24 1c          	mov    0x1c(%esp),%esi
f010420d:	f7 74 24 10          	divl   0x10(%esp)
f0104211:	d3 e6                	shl    %cl,%esi
f0104213:	89 d1                	mov    %edx,%ecx
f0104215:	f7 64 24 0c          	mull   0xc(%esp)
f0104219:	39 d1                	cmp    %edx,%ecx
f010421b:	89 74 24 14          	mov    %esi,0x14(%esp)
f010421f:	89 d7                	mov    %edx,%edi
f0104221:	89 c6                	mov    %eax,%esi
f0104223:	72 0a                	jb     f010422f <__umoddi3+0x12f>
f0104225:	39 44 24 14          	cmp    %eax,0x14(%esp)
f0104229:	73 10                	jae    f010423b <__umoddi3+0x13b>
f010422b:	39 d1                	cmp    %edx,%ecx
f010422d:	75 0c                	jne    f010423b <__umoddi3+0x13b>
f010422f:	89 d7                	mov    %edx,%edi
f0104231:	89 c6                	mov    %eax,%esi
f0104233:	2b 74 24 0c          	sub    0xc(%esp),%esi
f0104237:	1b 7c 24 10          	sbb    0x10(%esp),%edi
f010423b:	89 ca                	mov    %ecx,%edx
f010423d:	89 e9                	mov    %ebp,%ecx
f010423f:	8b 44 24 14          	mov    0x14(%esp),%eax
f0104243:	29 f0                	sub    %esi,%eax
f0104245:	19 fa                	sbb    %edi,%edx
f0104247:	d3 e8                	shr    %cl,%eax
f0104249:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
f010424e:	89 d7                	mov    %edx,%edi
f0104250:	d3 e7                	shl    %cl,%edi
f0104252:	89 e9                	mov    %ebp,%ecx
f0104254:	09 f8                	or     %edi,%eax
f0104256:	d3 ea                	shr    %cl,%edx
f0104258:	83 c4 20             	add    $0x20,%esp
f010425b:	5e                   	pop    %esi
f010425c:	5f                   	pop    %edi
f010425d:	5d                   	pop    %ebp
f010425e:	c3                   	ret    
f010425f:	90                   	nop
f0104260:	8b 74 24 10          	mov    0x10(%esp),%esi
f0104264:	29 f9                	sub    %edi,%ecx
f0104266:	19 c6                	sbb    %eax,%esi
f0104268:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f010426c:	89 74 24 18          	mov    %esi,0x18(%esp)
f0104270:	e9 ff fe ff ff       	jmp    f0104174 <__umoddi3+0x74>
