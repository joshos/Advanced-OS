
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
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
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer #code breaks if paging is not enabled.
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp
	# We move 0 to ebp => init function. 
	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 20 11 f0       	mov    $0xf0112000,%esp

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
f0100043:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 70 49 11 f0       	mov    $0xf0114970,%eax
f010004b:	2d 00 43 11 f0       	sub    $0xf0114300,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 00 43 11 f0 	movl   $0xf0114300,(%esp)
f0100063:	e8 6f 22 00 00       	call   f01022d7 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 92 04 00 00       	call   f01004ff <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 80 27 10 f0 	movl   $0xf0102780,(%esp)
f010007c:	e8 e8 16 00 00       	call   f0101769 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 60 0e 00 00       	call   f0100ee6 <mem_init>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010008d:	e8 6d 07 00 00       	call   f01007ff <monitor>
f0100092:	eb f2                	jmp    f0100086 <i386_init+0x46>

f0100094 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	56                   	push   %esi
f0100098:	53                   	push   %ebx
f0100099:	83 ec 10             	sub    $0x10,%esp
f010009c:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010009f:	83 3d 60 49 11 f0 00 	cmpl   $0x0,0xf0114960
f01000a6:	75 3d                	jne    f01000e5 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000a8:	89 35 60 49 11 f0    	mov    %esi,0xf0114960

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000ae:	fa                   	cli    
f01000af:	fc                   	cld    

	va_start(ap, fmt);
f01000b0:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000b3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000b6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01000bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000c1:	c7 04 24 9b 27 10 f0 	movl   $0xf010279b,(%esp)
f01000c8:	e8 9c 16 00 00       	call   f0101769 <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 5d 16 00 00       	call   f0101736 <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 ab 2a 10 f0 	movl   $0xf0102aab,(%esp)
f01000e0:	e8 84 16 00 00       	call   f0101769 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000ec:	e8 0e 07 00 00       	call   f01007ff <monitor>
f01000f1:	eb f2                	jmp    f01000e5 <_panic+0x51>

f01000f3 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000f3:	55                   	push   %ebp
f01000f4:	89 e5                	mov    %esp,%ebp
f01000f6:	53                   	push   %ebx
f01000f7:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01000fa:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100100:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100104:	8b 45 08             	mov    0x8(%ebp),%eax
f0100107:	89 44 24 04          	mov    %eax,0x4(%esp)
f010010b:	c7 04 24 b3 27 10 f0 	movl   $0xf01027b3,(%esp)
f0100112:	e8 52 16 00 00       	call   f0101769 <cprintf>
	vcprintf(fmt, ap);
f0100117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011b:	8b 45 10             	mov    0x10(%ebp),%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 10 16 00 00       	call   f0101736 <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 ab 2a 10 f0 	movl   $0xf0102aab,(%esp)
f010012d:	e8 37 16 00 00       	call   f0101769 <cprintf>
	va_end(ap);
}
f0100132:	83 c4 14             	add    $0x14,%esp
f0100135:	5b                   	pop    %ebx
f0100136:	5d                   	pop    %ebp
f0100137:	c3                   	ret    
f0100138:	66 90                	xchg   %ax,%ax
f010013a:	66 90                	xchg   %ax,%ax
f010013c:	66 90                	xchg   %ax,%ax
f010013e:	66 90                	xchg   %ax,%ax

f0100140 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100140:	55                   	push   %ebp
f0100141:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100143:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100148:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100149:	a8 01                	test   $0x1,%al
f010014b:	74 08                	je     f0100155 <serial_proc_data+0x15>
f010014d:	b2 f8                	mov    $0xf8,%dl
f010014f:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100150:	0f b6 c0             	movzbl %al,%eax
f0100153:	eb 05                	jmp    f010015a <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100155:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010015a:	5d                   	pop    %ebp
f010015b:	c3                   	ret    

f010015c <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010015c:	55                   	push   %ebp
f010015d:	89 e5                	mov    %esp,%ebp
f010015f:	53                   	push   %ebx
f0100160:	83 ec 04             	sub    $0x4,%esp
f0100163:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100165:	eb 2a                	jmp    f0100191 <cons_intr+0x35>
		if (c == 0)
f0100167:	85 d2                	test   %edx,%edx
f0100169:	74 26                	je     f0100191 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f010016b:	a1 24 45 11 f0       	mov    0xf0114524,%eax
f0100170:	8d 48 01             	lea    0x1(%eax),%ecx
f0100173:	89 0d 24 45 11 f0    	mov    %ecx,0xf0114524
f0100179:	88 90 20 43 11 f0    	mov    %dl,-0xfeebce0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f010017f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100185:	75 0a                	jne    f0100191 <cons_intr+0x35>
			cons.wpos = 0;
f0100187:	c7 05 24 45 11 f0 00 	movl   $0x0,0xf0114524
f010018e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100191:	ff d3                	call   *%ebx
f0100193:	89 c2                	mov    %eax,%edx
f0100195:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100198:	75 cd                	jne    f0100167 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010019a:	83 c4 04             	add    $0x4,%esp
f010019d:	5b                   	pop    %ebx
f010019e:	5d                   	pop    %ebp
f010019f:	c3                   	ret    

f01001a0 <kbd_proc_data>:
f01001a0:	ba 64 00 00 00       	mov    $0x64,%edx
f01001a5:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001a6:	a8 01                	test   $0x1,%al
f01001a8:	0f 84 ef 00 00 00    	je     f010029d <kbd_proc_data+0xfd>
f01001ae:	b2 60                	mov    $0x60,%dl
f01001b0:	ec                   	in     (%dx),%al
f01001b1:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001b3:	3c e0                	cmp    $0xe0,%al
f01001b5:	75 0d                	jne    f01001c4 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f01001b7:	83 0d 00 43 11 f0 40 	orl    $0x40,0xf0114300
		return 0;
f01001be:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001c3:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001c4:	55                   	push   %ebp
f01001c5:	89 e5                	mov    %esp,%ebp
f01001c7:	53                   	push   %ebx
f01001c8:	83 ec 14             	sub    $0x14,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001cb:	84 c0                	test   %al,%al
f01001cd:	79 37                	jns    f0100206 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001cf:	8b 0d 00 43 11 f0    	mov    0xf0114300,%ecx
f01001d5:	89 cb                	mov    %ecx,%ebx
f01001d7:	83 e3 40             	and    $0x40,%ebx
f01001da:	83 e0 7f             	and    $0x7f,%eax
f01001dd:	85 db                	test   %ebx,%ebx
f01001df:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001e2:	0f b6 d2             	movzbl %dl,%edx
f01001e5:	0f b6 82 20 29 10 f0 	movzbl -0xfefd6e0(%edx),%eax
f01001ec:	83 c8 40             	or     $0x40,%eax
f01001ef:	0f b6 c0             	movzbl %al,%eax
f01001f2:	f7 d0                	not    %eax
f01001f4:	21 c1                	and    %eax,%ecx
f01001f6:	89 0d 00 43 11 f0    	mov    %ecx,0xf0114300
		return 0;
f01001fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100201:	e9 9d 00 00 00       	jmp    f01002a3 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100206:	8b 0d 00 43 11 f0    	mov    0xf0114300,%ecx
f010020c:	f6 c1 40             	test   $0x40,%cl
f010020f:	74 0e                	je     f010021f <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100211:	83 c8 80             	or     $0xffffff80,%eax
f0100214:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100216:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100219:	89 0d 00 43 11 f0    	mov    %ecx,0xf0114300
	}

	shift |= shiftcode[data];
f010021f:	0f b6 d2             	movzbl %dl,%edx
f0100222:	0f b6 82 20 29 10 f0 	movzbl -0xfefd6e0(%edx),%eax
f0100229:	0b 05 00 43 11 f0    	or     0xf0114300,%eax
	shift ^= togglecode[data];
f010022f:	0f b6 8a 20 28 10 f0 	movzbl -0xfefd7e0(%edx),%ecx
f0100236:	31 c8                	xor    %ecx,%eax
f0100238:	a3 00 43 11 f0       	mov    %eax,0xf0114300

	c = charcode[shift & (CTL | SHIFT)][data];
f010023d:	89 c1                	mov    %eax,%ecx
f010023f:	83 e1 03             	and    $0x3,%ecx
f0100242:	8b 0c 8d 00 28 10 f0 	mov    -0xfefd800(,%ecx,4),%ecx
f0100249:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010024d:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100250:	a8 08                	test   $0x8,%al
f0100252:	74 1b                	je     f010026f <kbd_proc_data+0xcf>
		if ('a' <= c && c <= 'z')
f0100254:	89 da                	mov    %ebx,%edx
f0100256:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100259:	83 f9 19             	cmp    $0x19,%ecx
f010025c:	77 05                	ja     f0100263 <kbd_proc_data+0xc3>
			c += 'A' - 'a';
f010025e:	83 eb 20             	sub    $0x20,%ebx
f0100261:	eb 0c                	jmp    f010026f <kbd_proc_data+0xcf>
		else if ('A' <= c && c <= 'Z')
f0100263:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100266:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100269:	83 fa 19             	cmp    $0x19,%edx
f010026c:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010026f:	f7 d0                	not    %eax
f0100271:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100273:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100275:	f6 c2 06             	test   $0x6,%dl
f0100278:	75 29                	jne    f01002a3 <kbd_proc_data+0x103>
f010027a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100280:	75 21                	jne    f01002a3 <kbd_proc_data+0x103>
		cprintf("Rebooting!\n");
f0100282:	c7 04 24 cd 27 10 f0 	movl   $0xf01027cd,(%esp)
f0100289:	e8 db 14 00 00       	call   f0101769 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010028e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100293:	b8 03 00 00 00       	mov    $0x3,%eax
f0100298:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100299:	89 d8                	mov    %ebx,%eax
f010029b:	eb 06                	jmp    f01002a3 <kbd_proc_data+0x103>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010029d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002a2:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002a3:	83 c4 14             	add    $0x14,%esp
f01002a6:	5b                   	pop    %ebx
f01002a7:	5d                   	pop    %ebp
f01002a8:	c3                   	ret    

f01002a9 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002a9:	55                   	push   %ebp
f01002aa:	89 e5                	mov    %esp,%ebp
f01002ac:	57                   	push   %edi
f01002ad:	56                   	push   %esi
f01002ae:	53                   	push   %ebx
f01002af:	83 ec 1c             	sub    $0x1c,%esp
f01002b2:	89 c7                	mov    %eax,%edi
f01002b4:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002b9:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002be:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002c3:	eb 06                	jmp    f01002cb <cons_putc+0x22>
f01002c5:	89 ca                	mov    %ecx,%edx
f01002c7:	ec                   	in     (%dx),%al
f01002c8:	ec                   	in     (%dx),%al
f01002c9:	ec                   	in     (%dx),%al
f01002ca:	ec                   	in     (%dx),%al
f01002cb:	89 f2                	mov    %esi,%edx
f01002cd:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002ce:	a8 20                	test   $0x20,%al
f01002d0:	75 05                	jne    f01002d7 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002d2:	83 eb 01             	sub    $0x1,%ebx
f01002d5:	75 ee                	jne    f01002c5 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01002d7:	89 f8                	mov    %edi,%eax
f01002d9:	0f b6 c0             	movzbl %al,%eax
f01002dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002df:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002e4:	ee                   	out    %al,(%dx)
f01002e5:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ea:	be 79 03 00 00       	mov    $0x379,%esi
f01002ef:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002f4:	eb 06                	jmp    f01002fc <cons_putc+0x53>
f01002f6:	89 ca                	mov    %ecx,%edx
f01002f8:	ec                   	in     (%dx),%al
f01002f9:	ec                   	in     (%dx),%al
f01002fa:	ec                   	in     (%dx),%al
f01002fb:	ec                   	in     (%dx),%al
f01002fc:	89 f2                	mov    %esi,%edx
f01002fe:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002ff:	84 c0                	test   %al,%al
f0100301:	78 05                	js     f0100308 <cons_putc+0x5f>
f0100303:	83 eb 01             	sub    $0x1,%ebx
f0100306:	75 ee                	jne    f01002f6 <cons_putc+0x4d>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100308:	ba 78 03 00 00       	mov    $0x378,%edx
f010030d:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100311:	ee                   	out    %al,(%dx)
f0100312:	b2 7a                	mov    $0x7a,%dl
f0100314:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100319:	ee                   	out    %al,(%dx)
f010031a:	b8 08 00 00 00       	mov    $0x8,%eax
f010031f:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100320:	89 fa                	mov    %edi,%edx
f0100322:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100328:	89 f8                	mov    %edi,%eax
f010032a:	80 cc 07             	or     $0x7,%ah
f010032d:	85 d2                	test   %edx,%edx
f010032f:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100332:	89 f8                	mov    %edi,%eax
f0100334:	0f b6 c0             	movzbl %al,%eax
f0100337:	83 f8 09             	cmp    $0x9,%eax
f010033a:	74 76                	je     f01003b2 <cons_putc+0x109>
f010033c:	83 f8 09             	cmp    $0x9,%eax
f010033f:	7f 0a                	jg     f010034b <cons_putc+0xa2>
f0100341:	83 f8 08             	cmp    $0x8,%eax
f0100344:	74 16                	je     f010035c <cons_putc+0xb3>
f0100346:	e9 9b 00 00 00       	jmp    f01003e6 <cons_putc+0x13d>
f010034b:	83 f8 0a             	cmp    $0xa,%eax
f010034e:	66 90                	xchg   %ax,%ax
f0100350:	74 3a                	je     f010038c <cons_putc+0xe3>
f0100352:	83 f8 0d             	cmp    $0xd,%eax
f0100355:	74 3d                	je     f0100394 <cons_putc+0xeb>
f0100357:	e9 8a 00 00 00       	jmp    f01003e6 <cons_putc+0x13d>
	case '\b':
		if (crt_pos > 0) {
f010035c:	0f b7 05 28 45 11 f0 	movzwl 0xf0114528,%eax
f0100363:	66 85 c0             	test   %ax,%ax
f0100366:	0f 84 e5 00 00 00    	je     f0100451 <cons_putc+0x1a8>
			crt_pos--;
f010036c:	83 e8 01             	sub    $0x1,%eax
f010036f:	66 a3 28 45 11 f0    	mov    %ax,0xf0114528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100375:	0f b7 c0             	movzwl %ax,%eax
f0100378:	66 81 e7 00 ff       	and    $0xff00,%di
f010037d:	83 cf 20             	or     $0x20,%edi
f0100380:	8b 15 2c 45 11 f0    	mov    0xf011452c,%edx
f0100386:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010038a:	eb 78                	jmp    f0100404 <cons_putc+0x15b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010038c:	66 83 05 28 45 11 f0 	addw   $0x50,0xf0114528
f0100393:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100394:	0f b7 05 28 45 11 f0 	movzwl 0xf0114528,%eax
f010039b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003a1:	c1 e8 16             	shr    $0x16,%eax
f01003a4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003a7:	c1 e0 04             	shl    $0x4,%eax
f01003aa:	66 a3 28 45 11 f0    	mov    %ax,0xf0114528
f01003b0:	eb 52                	jmp    f0100404 <cons_putc+0x15b>
		break;
	case '\t':
		cons_putc(' ');
f01003b2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b7:	e8 ed fe ff ff       	call   f01002a9 <cons_putc>
		cons_putc(' ');
f01003bc:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c1:	e8 e3 fe ff ff       	call   f01002a9 <cons_putc>
		cons_putc(' ');
f01003c6:	b8 20 00 00 00       	mov    $0x20,%eax
f01003cb:	e8 d9 fe ff ff       	call   f01002a9 <cons_putc>
		cons_putc(' ');
f01003d0:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d5:	e8 cf fe ff ff       	call   f01002a9 <cons_putc>
		cons_putc(' ');
f01003da:	b8 20 00 00 00       	mov    $0x20,%eax
f01003df:	e8 c5 fe ff ff       	call   f01002a9 <cons_putc>
f01003e4:	eb 1e                	jmp    f0100404 <cons_putc+0x15b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003e6:	0f b7 05 28 45 11 f0 	movzwl 0xf0114528,%eax
f01003ed:	8d 50 01             	lea    0x1(%eax),%edx
f01003f0:	66 89 15 28 45 11 f0 	mov    %dx,0xf0114528
f01003f7:	0f b7 c0             	movzwl %ax,%eax
f01003fa:	8b 15 2c 45 11 f0    	mov    0xf011452c,%edx
f0100400:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100404:	66 81 3d 28 45 11 f0 	cmpw   $0x7cf,0xf0114528
f010040b:	cf 07 
f010040d:	76 42                	jbe    f0100451 <cons_putc+0x1a8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010040f:	a1 2c 45 11 f0       	mov    0xf011452c,%eax
f0100414:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010041b:	00 
f010041c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100422:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100426:	89 04 24             	mov    %eax,(%esp)
f0100429:	e8 f6 1e 00 00       	call   f0102324 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010042e:	8b 15 2c 45 11 f0    	mov    0xf011452c,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100434:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100439:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010043f:	83 c0 01             	add    $0x1,%eax
f0100442:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100447:	75 f0                	jne    f0100439 <cons_putc+0x190>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100449:	66 83 2d 28 45 11 f0 	subw   $0x50,0xf0114528
f0100450:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100451:	8b 0d 30 45 11 f0    	mov    0xf0114530,%ecx
f0100457:	b8 0e 00 00 00       	mov    $0xe,%eax
f010045c:	89 ca                	mov    %ecx,%edx
f010045e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010045f:	0f b7 1d 28 45 11 f0 	movzwl 0xf0114528,%ebx
f0100466:	8d 71 01             	lea    0x1(%ecx),%esi
f0100469:	89 d8                	mov    %ebx,%eax
f010046b:	66 c1 e8 08          	shr    $0x8,%ax
f010046f:	89 f2                	mov    %esi,%edx
f0100471:	ee                   	out    %al,(%dx)
f0100472:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100477:	89 ca                	mov    %ecx,%edx
f0100479:	ee                   	out    %al,(%dx)
f010047a:	89 d8                	mov    %ebx,%eax
f010047c:	89 f2                	mov    %esi,%edx
f010047e:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010047f:	83 c4 1c             	add    $0x1c,%esp
f0100482:	5b                   	pop    %ebx
f0100483:	5e                   	pop    %esi
f0100484:	5f                   	pop    %edi
f0100485:	5d                   	pop    %ebp
f0100486:	c3                   	ret    

f0100487 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100487:	80 3d 34 45 11 f0 00 	cmpb   $0x0,0xf0114534
f010048e:	74 11                	je     f01004a1 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100490:	55                   	push   %ebp
f0100491:	89 e5                	mov    %esp,%ebp
f0100493:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100496:	b8 40 01 10 f0       	mov    $0xf0100140,%eax
f010049b:	e8 bc fc ff ff       	call   f010015c <cons_intr>
}
f01004a0:	c9                   	leave  
f01004a1:	f3 c3                	repz ret 

f01004a3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004a3:	55                   	push   %ebp
f01004a4:	89 e5                	mov    %esp,%ebp
f01004a6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004a9:	b8 a0 01 10 f0       	mov    $0xf01001a0,%eax
f01004ae:	e8 a9 fc ff ff       	call   f010015c <cons_intr>
}
f01004b3:	c9                   	leave  
f01004b4:	c3                   	ret    

f01004b5 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004b5:	55                   	push   %ebp
f01004b6:	89 e5                	mov    %esp,%ebp
f01004b8:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004bb:	e8 c7 ff ff ff       	call   f0100487 <serial_intr>
	kbd_intr();
f01004c0:	e8 de ff ff ff       	call   f01004a3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004c5:	a1 20 45 11 f0       	mov    0xf0114520,%eax
f01004ca:	3b 05 24 45 11 f0    	cmp    0xf0114524,%eax
f01004d0:	74 26                	je     f01004f8 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004d2:	8d 50 01             	lea    0x1(%eax),%edx
f01004d5:	89 15 20 45 11 f0    	mov    %edx,0xf0114520
f01004db:	0f b6 88 20 43 11 f0 	movzbl -0xfeebce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004e2:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004e4:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004ea:	75 11                	jne    f01004fd <cons_getc+0x48>
			cons.rpos = 0;
f01004ec:	c7 05 20 45 11 f0 00 	movl   $0x0,0xf0114520
f01004f3:	00 00 00 
f01004f6:	eb 05                	jmp    f01004fd <cons_getc+0x48>
		return c;
	}
	return 0;
f01004f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004fd:	c9                   	leave  
f01004fe:	c3                   	ret    

f01004ff <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004ff:	55                   	push   %ebp
f0100500:	89 e5                	mov    %esp,%ebp
f0100502:	57                   	push   %edi
f0100503:	56                   	push   %esi
f0100504:	53                   	push   %ebx
f0100505:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100508:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010050f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100516:	5a a5 
	if (*cp != 0xA55A) {
f0100518:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010051f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100523:	74 11                	je     f0100536 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100525:	c7 05 30 45 11 f0 b4 	movl   $0x3b4,0xf0114530
f010052c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010052f:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f0100534:	eb 16                	jmp    f010054c <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100536:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010053d:	c7 05 30 45 11 f0 d4 	movl   $0x3d4,0xf0114530
f0100544:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100547:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010054c:	8b 0d 30 45 11 f0    	mov    0xf0114530,%ecx
f0100552:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100557:	89 ca                	mov    %ecx,%edx
f0100559:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010055a:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010055d:	89 da                	mov    %ebx,%edx
f010055f:	ec                   	in     (%dx),%al
f0100560:	0f b6 f0             	movzbl %al,%esi
f0100563:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100566:	b8 0f 00 00 00       	mov    $0xf,%eax
f010056b:	89 ca                	mov    %ecx,%edx
f010056d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010056e:	89 da                	mov    %ebx,%edx
f0100570:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100571:	89 3d 2c 45 11 f0    	mov    %edi,0xf011452c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100577:	0f b6 d8             	movzbl %al,%ebx
f010057a:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010057c:	66 89 35 28 45 11 f0 	mov    %si,0xf0114528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100583:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100588:	b8 00 00 00 00       	mov    $0x0,%eax
f010058d:	89 f2                	mov    %esi,%edx
f010058f:	ee                   	out    %al,(%dx)
f0100590:	b2 fb                	mov    $0xfb,%dl
f0100592:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100597:	ee                   	out    %al,(%dx)
f0100598:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010059d:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005a2:	89 da                	mov    %ebx,%edx
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
f01005cd:	88 0d 34 45 11 f0    	mov    %cl,0xf0114534
f01005d3:	89 f2                	mov    %esi,%edx
f01005d5:	ec                   	in     (%dx),%al
f01005d6:	89 da                	mov    %ebx,%edx
f01005d8:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005d9:	84 c9                	test   %cl,%cl
f01005db:	75 0c                	jne    f01005e9 <cons_init+0xea>
		cprintf("Serial port does not exist!\n");
f01005dd:	c7 04 24 d9 27 10 f0 	movl   $0xf01027d9,(%esp)
f01005e4:	e8 80 11 00 00       	call   f0101769 <cprintf>
}
f01005e9:	83 c4 1c             	add    $0x1c,%esp
f01005ec:	5b                   	pop    %ebx
f01005ed:	5e                   	pop    %esi
f01005ee:	5f                   	pop    %edi
f01005ef:	5d                   	pop    %ebp
f01005f0:	c3                   	ret    

f01005f1 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005f1:	55                   	push   %ebp
f01005f2:	89 e5                	mov    %esp,%ebp
f01005f4:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01005fa:	e8 aa fc ff ff       	call   f01002a9 <cons_putc>
}
f01005ff:	c9                   	leave  
f0100600:	c3                   	ret    

f0100601 <getchar>:

int
getchar(void)
{
f0100601:	55                   	push   %ebp
f0100602:	89 e5                	mov    %esp,%ebp
f0100604:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100607:	e8 a9 fe ff ff       	call   f01004b5 <cons_getc>
f010060c:	85 c0                	test   %eax,%eax
f010060e:	74 f7                	je     f0100607 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100610:	c9                   	leave  
f0100611:	c3                   	ret    

f0100612 <iscons>:

int
iscons(int fdnum)
{
f0100612:	55                   	push   %ebp
f0100613:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100615:	b8 01 00 00 00       	mov    $0x1,%eax
f010061a:	5d                   	pop    %ebp
f010061b:	c3                   	ret    
f010061c:	66 90                	xchg   %ax,%ax
f010061e:	66 90                	xchg   %ax,%ax

f0100620 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
f0100623:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100626:	c7 44 24 08 20 2a 10 	movl   $0xf0102a20,0x8(%esp)
f010062d:	f0 
f010062e:	c7 44 24 04 3e 2a 10 	movl   $0xf0102a3e,0x4(%esp)
f0100635:	f0 
f0100636:	c7 04 24 43 2a 10 f0 	movl   $0xf0102a43,(%esp)
f010063d:	e8 27 11 00 00       	call   f0101769 <cprintf>
f0100642:	c7 44 24 08 ec 2a 10 	movl   $0xf0102aec,0x8(%esp)
f0100649:	f0 
f010064a:	c7 44 24 04 4c 2a 10 	movl   $0xf0102a4c,0x4(%esp)
f0100651:	f0 
f0100652:	c7 04 24 43 2a 10 f0 	movl   $0xf0102a43,(%esp)
f0100659:	e8 0b 11 00 00       	call   f0101769 <cprintf>
f010065e:	c7 44 24 08 55 2a 10 	movl   $0xf0102a55,0x8(%esp)
f0100665:	f0 
f0100666:	c7 44 24 04 5e 2a 10 	movl   $0xf0102a5e,0x4(%esp)
f010066d:	f0 
f010066e:	c7 04 24 43 2a 10 f0 	movl   $0xf0102a43,(%esp)
f0100675:	e8 ef 10 00 00       	call   f0101769 <cprintf>
	return 0;
}
f010067a:	b8 00 00 00 00       	mov    $0x0,%eax
f010067f:	c9                   	leave  
f0100680:	c3                   	ret    

f0100681 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100681:	55                   	push   %ebp
f0100682:	89 e5                	mov    %esp,%ebp
f0100684:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100687:	c7 04 24 68 2a 10 f0 	movl   $0xf0102a68,(%esp)
f010068e:	e8 d6 10 00 00       	call   f0101769 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100693:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010069a:	00 
f010069b:	c7 04 24 14 2b 10 f0 	movl   $0xf0102b14,(%esp)
f01006a2:	e8 c2 10 00 00       	call   f0101769 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006a7:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006ae:	00 
f01006af:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006b6:	f0 
f01006b7:	c7 04 24 3c 2b 10 f0 	movl   $0xf0102b3c,(%esp)
f01006be:	e8 a6 10 00 00       	call   f0101769 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006c3:	c7 44 24 08 67 27 10 	movl   $0x102767,0x8(%esp)
f01006ca:	00 
f01006cb:	c7 44 24 04 67 27 10 	movl   $0xf0102767,0x4(%esp)
f01006d2:	f0 
f01006d3:	c7 04 24 60 2b 10 f0 	movl   $0xf0102b60,(%esp)
f01006da:	e8 8a 10 00 00       	call   f0101769 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006df:	c7 44 24 08 00 43 11 	movl   $0x114300,0x8(%esp)
f01006e6:	00 
f01006e7:	c7 44 24 04 00 43 11 	movl   $0xf0114300,0x4(%esp)
f01006ee:	f0 
f01006ef:	c7 04 24 84 2b 10 f0 	movl   $0xf0102b84,(%esp)
f01006f6:	e8 6e 10 00 00       	call   f0101769 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006fb:	c7 44 24 08 70 49 11 	movl   $0x114970,0x8(%esp)
f0100702:	00 
f0100703:	c7 44 24 04 70 49 11 	movl   $0xf0114970,0x4(%esp)
f010070a:	f0 
f010070b:	c7 04 24 a8 2b 10 f0 	movl   $0xf0102ba8,(%esp)
f0100712:	e8 52 10 00 00       	call   f0101769 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100717:	b8 6f 4d 11 f0       	mov    $0xf0114d6f,%eax
f010071c:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100721:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100726:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010072c:	85 c0                	test   %eax,%eax
f010072e:	0f 48 c2             	cmovs  %edx,%eax
f0100731:	c1 f8 0a             	sar    $0xa,%eax
f0100734:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100738:	c7 04 24 cc 2b 10 f0 	movl   $0xf0102bcc,(%esp)
f010073f:	e8 25 10 00 00       	call   f0101769 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100744:	b8 00 00 00 00       	mov    $0x0,%eax
f0100749:	c9                   	leave  
f010074a:	c3                   	ret    

f010074b <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010074b:	55                   	push   %ebp
f010074c:	89 e5                	mov    %esp,%ebp
f010074e:	56                   	push   %esi
f010074f:	53                   	push   %ebx
f0100750:	83 ec 40             	sub    $0x40,%esp
	// Your code here.
	uint32_t *myebp = (uint32_t *)read_ebp();		//read ebp, is an asm function: directly reads ebp register
f0100753:	89 eb                	mov    %ebp,%ebx
	struct Eipdebuginfo info;
	while (myebp){

					
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", myebp,myebp[1],myebp[2],myebp[3],myebp[4],myebp[5],myebp[6]);
		if(debuginfo_eip((uintptr_t)myebp[1],&info) == -1)
f0100755:	8d 75 e0             	lea    -0x20(%ebp),%esi
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	uint32_t *myebp = (uint32_t *)read_ebp();		//read ebp, is an asm function: directly reads ebp register
	struct Eipdebuginfo info;
	while (myebp){
f0100758:	e9 8e 00 00 00       	jmp    f01007eb <mon_backtrace+0xa0>

					
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", myebp,myebp[1],myebp[2],myebp[3],myebp[4],myebp[5],myebp[6]);
f010075d:	8b 43 18             	mov    0x18(%ebx),%eax
f0100760:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100764:	8b 43 14             	mov    0x14(%ebx),%eax
f0100767:	89 44 24 18          	mov    %eax,0x18(%esp)
f010076b:	8b 43 10             	mov    0x10(%ebx),%eax
f010076e:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100772:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100775:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100779:	8b 43 08             	mov    0x8(%ebx),%eax
f010077c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100780:	8b 43 04             	mov    0x4(%ebx),%eax
f0100783:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100787:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010078b:	c7 04 24 f8 2b 10 f0 	movl   $0xf0102bf8,(%esp)
f0100792:	e8 d2 0f 00 00       	call   f0101769 <cprintf>
		if(debuginfo_eip((uintptr_t)myebp[1],&info) == -1)
f0100797:	89 74 24 04          	mov    %esi,0x4(%esp)
f010079b:	8b 43 04             	mov    0x4(%ebx),%eax
f010079e:	89 04 24             	mov    %eax,(%esp)
f01007a1:	e8 ba 10 00 00       	call   f0101860 <debuginfo_eip>
f01007a6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01007a9:	75 0c                	jne    f01007b7 <mon_backtrace+0x6c>
			cprintf("Debug ebp info error\n");
f01007ab:	c7 04 24 81 2a 10 f0 	movl   $0xf0102a81,(%esp)
f01007b2:	e8 b2 0f 00 00       	call   f0101769 <cprintf>
		
cprintf("     %s:%u: %.*s+%u \n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,myebp[1]-info.eip_fn_addr);	
f01007b7:	8b 43 04             	mov    0x4(%ebx),%eax
f01007ba:	2b 45 f0             	sub    -0x10(%ebp),%eax
f01007bd:	89 44 24 14          	mov    %eax,0x14(%esp)
f01007c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01007c4:	89 44 24 10          	mov    %eax,0x10(%esp)
f01007c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01007cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01007cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01007d2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01007d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007dd:	c7 04 24 97 2a 10 f0 	movl   $0xf0102a97,(%esp)
f01007e4:	e8 80 0f 00 00       	call   f0101769 <cprintf>
//cprintf("     %s:%u: %s+%u \n",info.eip_file,info.eip_line,info.eip_fn_name,myebp[1]-info.eip_fn_addr);		
		myebp = (uint32_t *)myebp[0];	
f01007e9:	8b 1b                	mov    (%ebx),%ebx
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	uint32_t *myebp = (uint32_t *)read_ebp();		//read ebp, is an asm function: directly reads ebp register
	struct Eipdebuginfo info;
	while (myebp){
f01007eb:	85 db                	test   %ebx,%ebx
f01007ed:	0f 85 6a ff ff ff    	jne    f010075d <mon_backtrace+0x12>
		myebp = (uint32_t *)myebp[0];	
		
	}	
	
	return 0;
}
f01007f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f8:	83 c4 40             	add    $0x40,%esp
f01007fb:	5b                   	pop    %ebx
f01007fc:	5e                   	pop    %esi
f01007fd:	5d                   	pop    %ebp
f01007fe:	c3                   	ret    

f01007ff <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007ff:	55                   	push   %ebp
f0100800:	89 e5                	mov    %esp,%ebp
f0100802:	57                   	push   %edi
f0100803:	56                   	push   %esi
f0100804:	53                   	push   %ebx
f0100805:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100808:	c7 04 24 2c 2c 10 f0 	movl   $0xf0102c2c,(%esp)
f010080f:	e8 55 0f 00 00       	call   f0101769 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100814:	c7 04 24 50 2c 10 f0 	movl   $0xf0102c50,(%esp)
f010081b:	e8 49 0f 00 00       	call   f0101769 <cprintf>


	while (1) {
		buf = readline("K> ");
f0100820:	c7 04 24 ad 2a 10 f0 	movl   $0xf0102aad,(%esp)
f0100827:	e8 54 18 00 00       	call   f0102080 <readline>
f010082c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010082e:	85 c0                	test   %eax,%eax
f0100830:	74 ee                	je     f0100820 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100832:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100839:	be 00 00 00 00       	mov    $0x0,%esi
f010083e:	eb 0a                	jmp    f010084a <monitor+0x4b>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100840:	c6 03 00             	movb   $0x0,(%ebx)
f0100843:	89 f7                	mov    %esi,%edi
f0100845:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100848:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010084a:	0f b6 03             	movzbl (%ebx),%eax
f010084d:	84 c0                	test   %al,%al
f010084f:	74 63                	je     f01008b4 <monitor+0xb5>
f0100851:	0f be c0             	movsbl %al,%eax
f0100854:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100858:	c7 04 24 b1 2a 10 f0 	movl   $0xf0102ab1,(%esp)
f010085f:	e8 36 1a 00 00       	call   f010229a <strchr>
f0100864:	85 c0                	test   %eax,%eax
f0100866:	75 d8                	jne    f0100840 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f0100868:	80 3b 00             	cmpb   $0x0,(%ebx)
f010086b:	74 47                	je     f01008b4 <monitor+0xb5>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010086d:	83 fe 0f             	cmp    $0xf,%esi
f0100870:	75 16                	jne    f0100888 <monitor+0x89>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100872:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100879:	00 
f010087a:	c7 04 24 b6 2a 10 f0 	movl   $0xf0102ab6,(%esp)
f0100881:	e8 e3 0e 00 00       	call   f0101769 <cprintf>
f0100886:	eb 98                	jmp    f0100820 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f0100888:	8d 7e 01             	lea    0x1(%esi),%edi
f010088b:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010088f:	eb 03                	jmp    f0100894 <monitor+0x95>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100891:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100894:	0f b6 03             	movzbl (%ebx),%eax
f0100897:	84 c0                	test   %al,%al
f0100899:	74 ad                	je     f0100848 <monitor+0x49>
f010089b:	0f be c0             	movsbl %al,%eax
f010089e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008a2:	c7 04 24 b1 2a 10 f0 	movl   $0xf0102ab1,(%esp)
f01008a9:	e8 ec 19 00 00       	call   f010229a <strchr>
f01008ae:	85 c0                	test   %eax,%eax
f01008b0:	74 df                	je     f0100891 <monitor+0x92>
f01008b2:	eb 94                	jmp    f0100848 <monitor+0x49>
			buf++;
	}
	argv[argc] = 0;
f01008b4:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008bb:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008bc:	85 f6                	test   %esi,%esi
f01008be:	0f 84 5c ff ff ff    	je     f0100820 <monitor+0x21>
f01008c4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01008c9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008cc:	8b 04 85 80 2c 10 f0 	mov    -0xfefd380(,%eax,4),%eax
f01008d3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008d7:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008da:	89 04 24             	mov    %eax,(%esp)
f01008dd:	e8 5a 19 00 00       	call   f010223c <strcmp>
f01008e2:	85 c0                	test   %eax,%eax
f01008e4:	75 24                	jne    f010090a <monitor+0x10b>
			return commands[i].func(argc, argv, tf);
f01008e6:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008e9:	8b 55 08             	mov    0x8(%ebp),%edx
f01008ec:	89 54 24 08          	mov    %edx,0x8(%esp)
f01008f0:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01008f3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01008f7:	89 34 24             	mov    %esi,(%esp)
f01008fa:	ff 14 85 88 2c 10 f0 	call   *-0xfefd378(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100901:	85 c0                	test   %eax,%eax
f0100903:	78 25                	js     f010092a <monitor+0x12b>
f0100905:	e9 16 ff ff ff       	jmp    f0100820 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010090a:	83 c3 01             	add    $0x1,%ebx
f010090d:	83 fb 03             	cmp    $0x3,%ebx
f0100910:	75 b7                	jne    f01008c9 <monitor+0xca>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100912:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100915:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100919:	c7 04 24 d3 2a 10 f0 	movl   $0xf0102ad3,(%esp)
f0100920:	e8 44 0e 00 00       	call   f0101769 <cprintf>
f0100925:	e9 f6 fe ff ff       	jmp    f0100820 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010092a:	83 c4 5c             	add    $0x5c,%esp
f010092d:	5b                   	pop    %ebx
f010092e:	5e                   	pop    %esi
f010092f:	5f                   	pop    %edi
f0100930:	5d                   	pop    %ebp
f0100931:	c3                   	ret    

f0100932 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100932:	55                   	push   %ebp
f0100933:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100935:	83 3d 44 45 11 f0 00 	cmpl   $0x0,0xf0114544
f010093c:	75 11                	jne    f010094f <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010093e:	ba 6f 59 11 f0       	mov    $0xf011596f,%edx
f0100943:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100949:	89 15 44 45 11 f0    	mov    %edx,0xf0114544
	// LAB 2: Your code here.
	
	if(n%PGSIZE)
		page_chunk = (n/PGSIZE) + 1;
	else
		page_chunk = (n/PGSIZE);
f010094f:	89 c2                	mov    %eax,%edx
f0100951:	c1 ea 0c             	shr    $0xc,%edx
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	
	if(n%PGSIZE)
f0100954:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0100959:	74 08                	je     f0100963 <boot_alloc+0x31>
		page_chunk = (n/PGSIZE) + 1;
f010095b:	89 c2                	mov    %eax,%edx
f010095d:	c1 ea 0c             	shr    $0xc,%edx
f0100960:	83 c2 01             	add    $0x1,%edx
	else
		page_chunk = (n/PGSIZE);
	
	if(!n)
f0100963:	85 c0                	test   %eax,%eax
f0100965:	75 07                	jne    f010096e <boot_alloc+0x3c>
		return nextfree;
f0100967:	a1 44 45 11 f0       	mov    0xf0114544,%eax
f010096c:	eb 15                	jmp    f0100983 <boot_alloc+0x51>

	oldnextfree = nextfree;
f010096e:	a1 44 45 11 f0       	mov    0xf0114544,%eax
f0100973:	a3 40 45 11 f0       	mov    %eax,0xf0114540
	nextfree = nextfree + (page_chunk*PGSIZE);
f0100978:	c1 e2 0c             	shl    $0xc,%edx
f010097b:	01 c2                	add    %eax,%edx
f010097d:	89 15 44 45 11 f0    	mov    %edx,0xf0114544
	if(nextfree - KERNBASE > (char *)(npages*PGSIZE)){}
	//	panic("Kernel panic");
	//cprintf("second:Add %x\n",nextfree);
	return oldnextfree;
}
f0100983:	5d                   	pop    %ebp
f0100984:	c3                   	ret    

f0100985 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100985:	89 d1                	mov    %edx,%ecx
f0100987:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f010098a:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f010098d:	a8 01                	test   $0x1,%al
f010098f:	74 5d                	je     f01009ee <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100991:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100996:	89 c1                	mov    %eax,%ecx
f0100998:	c1 e9 0c             	shr    $0xc,%ecx
f010099b:	3b 0d 64 49 11 f0    	cmp    0xf0114964,%ecx
f01009a1:	72 26                	jb     f01009c9 <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009a3:	55                   	push   %ebp
f01009a4:	89 e5                	mov    %esp,%ebp
f01009a6:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009ad:	c7 44 24 08 a4 2c 10 	movl   $0xf0102ca4,0x8(%esp)
f01009b4:	f0 
f01009b5:	c7 44 24 04 c4 02 00 	movl   $0x2c4,0x4(%esp)
f01009bc:	00 
f01009bd:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f01009c4:	e8 cb f6 ff ff       	call   f0100094 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f01009c9:	c1 ea 0c             	shr    $0xc,%edx
f01009cc:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01009d2:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01009d9:	89 c2                	mov    %eax,%edx
f01009db:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01009de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009e3:	85 d2                	test   %edx,%edx
f01009e5:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01009ea:	0f 44 c2             	cmove  %edx,%eax
f01009ed:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01009ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f01009f3:	c3                   	ret    

f01009f4 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01009f4:	55                   	push   %ebp
f01009f5:	89 e5                	mov    %esp,%ebp
f01009f7:	57                   	push   %edi
f01009f8:	56                   	push   %esi
f01009f9:	53                   	push   %ebx
f01009fa:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01009fd:	84 c0                	test   %al,%al
f01009ff:	0f 85 07 03 00 00    	jne    f0100d0c <check_page_free_list+0x318>
f0100a05:	e9 14 03 00 00       	jmp    f0100d1e <check_page_free_list+0x32a>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a0a:	c7 44 24 08 c8 2c 10 	movl   $0xf0102cc8,0x8(%esp)
f0100a11:	f0 
f0100a12:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
f0100a19:	00 
f0100a1a:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0100a21:	e8 6e f6 ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a26:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a29:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a2c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a2f:	89 55 e4             	mov    %edx,-0x1c(%ebp)

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	//return (physaddr_t)(((uint32_t)pp - (uint32_t)pages) << PGSHIFT);
	return (pp - pages) << PGSHIFT;
f0100a32:	89 c2                	mov    %eax,%edx
f0100a34:	2b 15 6c 49 11 f0    	sub    0xf011496c,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a3a:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a40:	0f 95 c2             	setne  %dl
f0100a43:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a46:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a4a:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a4c:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a50:	8b 00                	mov    (%eax),%eax
f0100a52:	85 c0                	test   %eax,%eax
f0100a54:	75 dc                	jne    f0100a32 <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a59:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a62:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a65:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100a67:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100a6a:	a3 48 45 11 f0       	mov    %eax,0xf0114548
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a6f:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a74:	8b 1d 48 45 11 f0    	mov    0xf0114548,%ebx
f0100a7a:	eb 63                	jmp    f0100adf <check_page_free_list+0xeb>
f0100a7c:	89 d8                	mov    %ebx,%eax
f0100a7e:	2b 05 6c 49 11 f0    	sub    0xf011496c,%eax
f0100a84:	c1 f8 03             	sar    $0x3,%eax
f0100a87:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100a8a:	89 c2                	mov    %eax,%edx
f0100a8c:	c1 ea 16             	shr    $0x16,%edx
f0100a8f:	39 f2                	cmp    %esi,%edx
f0100a91:	73 4a                	jae    f0100add <check_page_free_list+0xe9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a93:	89 c2                	mov    %eax,%edx
f0100a95:	c1 ea 0c             	shr    $0xc,%edx
f0100a98:	3b 15 64 49 11 f0    	cmp    0xf0114964,%edx
f0100a9e:	72 20                	jb     f0100ac0 <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100aa0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100aa4:	c7 44 24 08 a4 2c 10 	movl   $0xf0102ca4,0x8(%esp)
f0100aab:	f0 
f0100aac:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f0100ab3:	00 
f0100ab4:	c7 04 24 68 2e 10 f0 	movl   $0xf0102e68,(%esp)
f0100abb:	e8 d4 f5 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100ac0:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100ac7:	00 
f0100ac8:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100acf:	00 
	return (void *)(pa + KERNBASE);
f0100ad0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ad5:	89 04 24             	mov    %eax,(%esp)
f0100ad8:	e8 fa 17 00 00       	call   f01022d7 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100add:	8b 1b                	mov    (%ebx),%ebx
f0100adf:	85 db                	test   %ebx,%ebx
f0100ae1:	75 99                	jne    f0100a7c <check_page_free_list+0x88>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100ae3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ae8:	e8 45 fe ff ff       	call   f0100932 <boot_alloc>
f0100aed:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100af0:	8b 15 48 45 11 f0    	mov    0xf0114548,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100af6:	8b 0d 6c 49 11 f0    	mov    0xf011496c,%ecx
		assert(pp < pages + npages);
f0100afc:	a1 64 49 11 f0       	mov    0xf0114964,%eax
f0100b01:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100b04:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100b07:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b0a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b0d:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b12:	89 5d cc             	mov    %ebx,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b15:	e9 97 01 00 00       	jmp    f0100cb1 <check_page_free_list+0x2bd>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b1a:	39 ca                	cmp    %ecx,%edx
f0100b1c:	73 24                	jae    f0100b42 <check_page_free_list+0x14e>
f0100b1e:	c7 44 24 0c 76 2e 10 	movl   $0xf0102e76,0xc(%esp)
f0100b25:	f0 
f0100b26:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0100b2d:	f0 
f0100b2e:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
f0100b35:	00 
f0100b36:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0100b3d:	e8 52 f5 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100b42:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100b45:	72 24                	jb     f0100b6b <check_page_free_list+0x177>
f0100b47:	c7 44 24 0c 97 2e 10 	movl   $0xf0102e97,0xc(%esp)
f0100b4e:	f0 
f0100b4f:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0100b56:	f0 
f0100b57:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
f0100b5e:	00 
f0100b5f:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0100b66:	e8 29 f5 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b6b:	89 d0                	mov    %edx,%eax
f0100b6d:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100b70:	a8 07                	test   $0x7,%al
f0100b72:	74 24                	je     f0100b98 <check_page_free_list+0x1a4>
f0100b74:	c7 44 24 0c ec 2c 10 	movl   $0xf0102cec,0xc(%esp)
f0100b7b:	f0 
f0100b7c:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0100b83:	f0 
f0100b84:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
f0100b8b:	00 
f0100b8c:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0100b93:	e8 fc f4 ff ff       	call   f0100094 <_panic>

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	//return (physaddr_t)(((uint32_t)pp - (uint32_t)pages) << PGSHIFT);
	return (pp - pages) << PGSHIFT;
f0100b98:	c1 f8 03             	sar    $0x3,%eax
f0100b9b:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100b9e:	85 c0                	test   %eax,%eax
f0100ba0:	75 24                	jne    f0100bc6 <check_page_free_list+0x1d2>
f0100ba2:	c7 44 24 0c ab 2e 10 	movl   $0xf0102eab,0xc(%esp)
f0100ba9:	f0 
f0100baa:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0100bb1:	f0 
f0100bb2:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
f0100bb9:	00 
f0100bba:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0100bc1:	e8 ce f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bc6:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bcb:	75 24                	jne    f0100bf1 <check_page_free_list+0x1fd>
f0100bcd:	c7 44 24 0c bc 2e 10 	movl   $0xf0102ebc,0xc(%esp)
f0100bd4:	f0 
f0100bd5:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0100bdc:	f0 
f0100bdd:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
f0100be4:	00 
f0100be5:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0100bec:	e8 a3 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100bf1:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100bf6:	75 24                	jne    f0100c1c <check_page_free_list+0x228>
f0100bf8:	c7 44 24 0c 20 2d 10 	movl   $0xf0102d20,0xc(%esp)
f0100bff:	f0 
f0100c00:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0100c07:	f0 
f0100c08:	c7 44 24 04 28 02 00 	movl   $0x228,0x4(%esp)
f0100c0f:	00 
f0100c10:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0100c17:	e8 78 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c1c:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c21:	75 24                	jne    f0100c47 <check_page_free_list+0x253>
f0100c23:	c7 44 24 0c d5 2e 10 	movl   $0xf0102ed5,0xc(%esp)
f0100c2a:	f0 
f0100c2b:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0100c32:	f0 
f0100c33:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
f0100c3a:	00 
f0100c3b:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0100c42:	e8 4d f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c47:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c4c:	76 58                	jbe    f0100ca6 <check_page_free_list+0x2b2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c4e:	89 c3                	mov    %eax,%ebx
f0100c50:	c1 eb 0c             	shr    $0xc,%ebx
f0100c53:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0100c56:	77 20                	ja     f0100c78 <check_page_free_list+0x284>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c58:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c5c:	c7 44 24 08 a4 2c 10 	movl   $0xf0102ca4,0x8(%esp)
f0100c63:	f0 
f0100c64:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f0100c6b:	00 
f0100c6c:	c7 04 24 68 2e 10 f0 	movl   $0xf0102e68,(%esp)
f0100c73:	e8 1c f4 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100c78:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c7d:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100c80:	76 2a                	jbe    f0100cac <check_page_free_list+0x2b8>
f0100c82:	c7 44 24 0c 44 2d 10 	movl   $0xf0102d44,0xc(%esp)
f0100c89:	f0 
f0100c8a:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0100c91:	f0 
f0100c92:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
f0100c99:	00 
f0100c9a:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0100ca1:	e8 ee f3 ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100ca6:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
f0100caa:	eb 03                	jmp    f0100caf <check_page_free_list+0x2bb>
		else
			++nfree_extmem;
f0100cac:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100caf:	8b 12                	mov    (%edx),%edx
f0100cb1:	85 d2                	test   %edx,%edx
f0100cb3:	0f 85 61 fe ff ff    	jne    f0100b1a <check_page_free_list+0x126>
f0100cb9:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100cbc:	85 db                	test   %ebx,%ebx
f0100cbe:	7f 24                	jg     f0100ce4 <check_page_free_list+0x2f0>
f0100cc0:	c7 44 24 0c ef 2e 10 	movl   $0xf0102eef,0xc(%esp)
f0100cc7:	f0 
f0100cc8:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0100ccf:	f0 
f0100cd0:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
f0100cd7:	00 
f0100cd8:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0100cdf:	e8 b0 f3 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100ce4:	85 ff                	test   %edi,%edi
f0100ce6:	7f 4d                	jg     f0100d35 <check_page_free_list+0x341>
f0100ce8:	c7 44 24 0c 01 2f 10 	movl   $0xf0102f01,0xc(%esp)
f0100cef:	f0 
f0100cf0:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0100cf7:	f0 
f0100cf8:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
f0100cff:	00 
f0100d00:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0100d07:	e8 88 f3 ff ff       	call   f0100094 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100d0c:	a1 48 45 11 f0       	mov    0xf0114548,%eax
f0100d11:	85 c0                	test   %eax,%eax
f0100d13:	0f 85 0d fd ff ff    	jne    f0100a26 <check_page_free_list+0x32>
f0100d19:	e9 ec fc ff ff       	jmp    f0100a0a <check_page_free_list+0x16>
f0100d1e:	83 3d 48 45 11 f0 00 	cmpl   $0x0,0xf0114548
f0100d25:	0f 84 df fc ff ff    	je     f0100a0a <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d2b:	be 00 04 00 00       	mov    $0x400,%esi
f0100d30:	e9 3f fd ff ff       	jmp    f0100a74 <check_page_free_list+0x80>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100d35:	83 c4 4c             	add    $0x4c,%esp
f0100d38:	5b                   	pop    %ebx
f0100d39:	5e                   	pop    %esi
f0100d3a:	5f                   	pop    %edi
f0100d3b:	5d                   	pop    %ebp
f0100d3c:	c3                   	ret    

f0100d3d <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100d3d:	55                   	push   %ebp
f0100d3e:	89 e5                	mov    %esp,%ebp
f0100d40:	57                   	push   %edi
f0100d41:	56                   	push   %esi
f0100d42:	53                   	push   %ebx
f0100d43:	83 ec 04             	sub    $0x4,%esp
	// free pages!

	size_t i;
	static size_t IoHoleSize;
	static size_t IoHoleStart;
	IoHoleSize = (uint32_t)((EXTPHYSMEM-IOPHYSMEM))/PGSIZE;
f0100d46:	c7 05 3c 45 11 f0 60 	movl   $0x60,0xf011453c
f0100d4d:	00 00 00 
	IoHoleStart = (uint32_t)(IOPHYSMEM)/PGSIZE;
f0100d50:	c7 05 38 45 11 f0 a0 	movl   $0xa0,0xf0114538
f0100d57:	00 00 00 
	uint32_t KernEndPage = (uint32_t)((uint32_t)((boot_alloc(0)-KERNBASE)+ONEMB)/PGSIZE);
f0100d5a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d5f:	e8 ce fb ff ff       	call   f0100932 <boot_alloc>
f0100d64:	8d b8 00 00 10 10    	lea    0x10100000(%eax),%edi
f0100d6a:	c1 ef 0c             	shr    $0xc,%edi
	uint32_t KernPageStart = (uint32_t)((uint32_t)ONEMB/PGSIZE);	
	


	pages[0].pp_ref=1;
f0100d6d:	a1 6c 49 11 f0       	mov    0xf011496c,%eax
f0100d72:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link= NULL;  //marking page 0 as in use.
f0100d78:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	
	for (i = 1; i < npages; i++) {	

//IoHoleStart = [160 and IoHoleEnd = 256)
		if(i>=IoHoleStart && i<IoHoleStart+IoHoleSize){		//Marking the IO hole as allocated
f0100d7e:	a1 38 45 11 f0       	mov    0xf0114538,%eax
f0100d83:	89 c6                	mov    %eax,%esi
f0100d85:	03 35 3c 45 11 f0    	add    0xf011453c,%esi
f0100d8b:	89 75 f0             	mov    %esi,-0x10(%ebp)
f0100d8e:	8b 35 48 45 11 f0    	mov    0xf0114548,%esi


	pages[0].pp_ref=1;
	pages[0].pp_link= NULL;  //marking page 0 as in use.
	
	for (i = 1; i < npages; i++) {	
f0100d94:	b9 08 00 00 00       	mov    $0x8,%ecx
f0100d99:	ba 01 00 00 00       	mov    $0x1,%edx
f0100d9e:	eb 5f                	jmp    f0100dff <page_init+0xc2>

//IoHoleStart = [160 and IoHoleEnd = 256)
		if(i>=IoHoleStart && i<IoHoleStart+IoHoleSize){		//Marking the IO hole as allocated
f0100da0:	39 c2                	cmp    %eax,%edx
f0100da2:	72 1b                	jb     f0100dbf <page_init+0x82>
f0100da4:	3b 55 f0             	cmp    -0x10(%ebp),%edx
f0100da7:	73 16                	jae    f0100dbf <page_init+0x82>
				pages[i].pp_ref=1;
f0100da9:	89 cb                	mov    %ecx,%ebx
f0100dab:	03 1d 6c 49 11 f0    	add    0xf011496c,%ebx
f0100db1:	66 c7 43 04 01 00    	movw   $0x1,0x4(%ebx)
				pages[i].pp_link= NULL;
f0100db7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
				continue;
f0100dbd:	eb 3a                	jmp    f0100df9 <page_init+0xbc>
			}	
		
//KernPageStart = [256 and KernEndPage = 312), so kernelsize = 56 pages!	
			if(i>=KernPageStart && i<=KernEndPage){			//Marking kernel pages that are in use as allocated
f0100dbf:	39 fa                	cmp    %edi,%edx
f0100dc1:	77 1e                	ja     f0100de1 <page_init+0xa4>
f0100dc3:	81 fa ff 00 00 00    	cmp    $0xff,%edx
f0100dc9:	76 16                	jbe    f0100de1 <page_init+0xa4>
				pages[i].pp_ref=1;
f0100dcb:	89 cb                	mov    %ecx,%ebx
f0100dcd:	03 1d 6c 49 11 f0    	add    0xf011496c,%ebx
f0100dd3:	66 c7 43 04 01 00    	movw   $0x1,0x4(%ebx)
				pages[i].pp_link= NULL;
f0100dd9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
				continue;
f0100ddf:	eb 18                	jmp    f0100df9 <page_init+0xbc>
			}
			pages[i].pp_ref = 0;
f0100de1:	89 cb                	mov    %ecx,%ebx
f0100de3:	03 1d 6c 49 11 f0    	add    0xf011496c,%ebx
f0100de9:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
			pages[i].pp_link = page_free_list;
f0100def:	89 33                	mov    %esi,(%ebx)
			page_free_list = &pages[i];
f0100df1:	89 ce                	mov    %ecx,%esi
f0100df3:	03 35 6c 49 11 f0    	add    0xf011496c,%esi


	pages[0].pp_ref=1;
	pages[0].pp_link= NULL;  //marking page 0 as in use.
	
	for (i = 1; i < npages; i++) {	
f0100df9:	83 c2 01             	add    $0x1,%edx
f0100dfc:	83 c1 08             	add    $0x8,%ecx
f0100dff:	3b 15 64 49 11 f0    	cmp    0xf0114964,%edx
f0100e05:	72 99                	jb     f0100da0 <page_init+0x63>
f0100e07:	89 35 48 45 11 f0    	mov    %esi,0xf0114548
	
	
	

	
}
f0100e0d:	83 c4 04             	add    $0x4,%esp
f0100e10:	5b                   	pop    %ebx
f0100e11:	5e                   	pop    %esi
f0100e12:	5f                   	pop    %edi
f0100e13:	5d                   	pop    %ebp
f0100e14:	c3                   	ret    

f0100e15 <page_alloc>:
//
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *page_alloc(int alloc_flags)	//if alloc_flags=1, return a clean page
{
f0100e15:	55                   	push   %ebp
f0100e16:	89 e5                	mov    %esp,%ebp
f0100e18:	53                   	push   %ebx
f0100e19:	83 ec 14             	sub    $0x14,%esp

	if(page_free_list == NULL)
f0100e1c:	8b 1d 48 45 11 f0    	mov    0xf0114548,%ebx
f0100e22:	85 db                	test   %ebx,%ebx
f0100e24:	74 75                	je     f0100e9b <page_alloc+0x86>
		return NULL;			//Panic: All pages are used
	struct PageInfo *NewHead = page_free_list->pp_link;
f0100e26:	8b 03                	mov    (%ebx),%eax
	struct PageInfo *OldHead = page_free_list;
	OldHead->pp_ref = 0;
f0100e28:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	OldHead->pp_link = NULL;
f0100e2e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	page_free_list = NewHead;
f0100e34:	a3 48 45 11 f0       	mov    %eax,0xf0114548

	
	if(alloc_flags & ALLOC_ZERO)
		memset((page2kva(OldHead)), 0, PGSIZE);
	
	return OldHead;
f0100e39:	89 d8                	mov    %ebx,%eax
	OldHead->pp_ref = 0;
	OldHead->pp_link = NULL;
	page_free_list = NewHead;

	
	if(alloc_flags & ALLOC_ZERO)
f0100e3b:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e3f:	74 5f                	je     f0100ea0 <page_alloc+0x8b>

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	//return (physaddr_t)(((uint32_t)pp - (uint32_t)pages) << PGSHIFT);
	return (pp - pages) << PGSHIFT;
f0100e41:	2b 05 6c 49 11 f0    	sub    0xf011496c,%eax
f0100e47:	c1 f8 03             	sar    $0x3,%eax
f0100e4a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e4d:	89 c2                	mov    %eax,%edx
f0100e4f:	c1 ea 0c             	shr    $0xc,%edx
f0100e52:	3b 15 64 49 11 f0    	cmp    0xf0114964,%edx
f0100e58:	72 20                	jb     f0100e7a <page_alloc+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e5a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e5e:	c7 44 24 08 a4 2c 10 	movl   $0xf0102ca4,0x8(%esp)
f0100e65:	f0 
f0100e66:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f0100e6d:	00 
f0100e6e:	c7 04 24 68 2e 10 f0 	movl   $0xf0102e68,(%esp)
f0100e75:	e8 1a f2 ff ff       	call   f0100094 <_panic>
		memset((page2kva(OldHead)), 0, PGSIZE);
f0100e7a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100e81:	00 
f0100e82:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100e89:	00 
	return (void *)(pa + KERNBASE);
f0100e8a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e8f:	89 04 24             	mov    %eax,(%esp)
f0100e92:	e8 40 14 00 00       	call   f01022d7 <memset>
	
	return OldHead;
f0100e97:	89 d8                	mov    %ebx,%eax
f0100e99:	eb 05                	jmp    f0100ea0 <page_alloc+0x8b>
// Hint: use page2kva and memset
struct PageInfo *page_alloc(int alloc_flags)	//if alloc_flags=1, return a clean page
{

	if(page_free_list == NULL)
		return NULL;			//Panic: All pages are used
f0100e9b:	b8 00 00 00 00       	mov    $0x0,%eax
	if(alloc_flags & ALLOC_ZERO)
		memset((page2kva(OldHead)), 0, PGSIZE);
	
	return OldHead;

}
f0100ea0:	83 c4 14             	add    $0x14,%esp
f0100ea3:	5b                   	pop    %ebx
f0100ea4:	5d                   	pop    %ebp
f0100ea5:	c3                   	ret    

f0100ea6 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100ea6:	55                   	push   %ebp
f0100ea7:	89 e5                	mov    %esp,%ebp
f0100ea9:	83 ec 18             	sub    $0x18,%esp
f0100eac:	8b 45 08             	mov    0x8(%ebp),%eax

	if((pp->pp_link !=NULL )||(pp->pp_ref!= 0))
f0100eaf:	83 38 00             	cmpl   $0x0,(%eax)
f0100eb2:	75 07                	jne    f0100ebb <page_free+0x15>
f0100eb4:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100eb9:	74 1c                	je     f0100ed7 <page_free+0x31>
			panic("Page not free");
f0100ebb:	c7 44 24 08 12 2f 10 	movl   $0xf0102f12,0x8(%esp)
f0100ec2:	f0 
f0100ec3:	c7 44 24 04 5f 01 00 	movl   $0x15f,0x4(%esp)
f0100eca:	00 
f0100ecb:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0100ed2:	e8 bd f1 ff ff       	call   f0100094 <_panic>
	
	//pp->pp_ref = 0;
	pp->pp_link = page_free_list;
f0100ed7:	8b 15 48 45 11 f0    	mov    0xf0114548,%edx
f0100edd:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100edf:	a3 48 45 11 f0       	mov    %eax,0xf0114548
	
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
}
f0100ee4:	c9                   	leave  
f0100ee5:	c3                   	ret    

f0100ee6 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100ee6:	55                   	push   %ebp
f0100ee7:	89 e5                	mov    %esp,%ebp
f0100ee9:	57                   	push   %edi
f0100eea:	56                   	push   %esi
f0100eeb:	53                   	push   %ebx
f0100eec:	83 ec 2c             	sub    $0x2c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100eef:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f0100ef6:	e8 fe 07 00 00       	call   f01016f9 <mc146818_read>
f0100efb:	89 c3                	mov    %eax,%ebx
f0100efd:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0100f04:	e8 f0 07 00 00       	call   f01016f9 <mc146818_read>
f0100f09:	c1 e0 08             	shl    $0x8,%eax
f0100f0c:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100f0e:	89 d8                	mov    %ebx,%eax
f0100f10:	c1 e0 0a             	shl    $0xa,%eax
f0100f13:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100f19:	85 c0                	test   %eax,%eax
f0100f1b:	0f 48 c2             	cmovs  %edx,%eax
f0100f1e:	c1 f8 0c             	sar    $0xc,%eax
f0100f21:	a3 4c 45 11 f0       	mov    %eax,0xf011454c
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100f26:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f0100f2d:	e8 c7 07 00 00       	call   f01016f9 <mc146818_read>
f0100f32:	89 c3                	mov    %eax,%ebx
f0100f34:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0100f3b:	e8 b9 07 00 00       	call   f01016f9 <mc146818_read>
f0100f40:	c1 e0 08             	shl    $0x8,%eax
f0100f43:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0100f45:	89 d8                	mov    %ebx,%eax
f0100f47:	c1 e0 0a             	shl    $0xa,%eax
f0100f4a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100f50:	85 c0                	test   %eax,%eax
f0100f52:	0f 48 c2             	cmovs  %edx,%eax
f0100f55:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100f58:	85 c0                	test   %eax,%eax
f0100f5a:	74 0e                	je     f0100f6a <mem_init+0x84>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0100f5c:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0100f62:	89 15 64 49 11 f0    	mov    %edx,0xf0114964
f0100f68:	eb 0c                	jmp    f0100f76 <mem_init+0x90>
	else
		npages = npages_basemem;
f0100f6a:	8b 15 4c 45 11 f0    	mov    0xf011454c,%edx
f0100f70:	89 15 64 49 11 f0    	mov    %edx,0xf0114964

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0100f76:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100f79:	c1 e8 0a             	shr    $0xa,%eax
f0100f7c:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0100f80:	a1 4c 45 11 f0       	mov    0xf011454c,%eax
f0100f85:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100f88:	c1 e8 0a             	shr    $0xa,%eax
f0100f8b:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f0100f8f:	a1 64 49 11 f0       	mov    0xf0114964,%eax
f0100f94:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100f97:	c1 e8 0a             	shr    $0xa,%eax
f0100f9a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f9e:	c7 04 24 8c 2d 10 f0 	movl   $0xf0102d8c,(%esp)
f0100fa5:	e8 bf 07 00 00       	call   f0101769 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100faa:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100faf:	e8 7e f9 ff ff       	call   f0100932 <boot_alloc>
f0100fb4:	a3 68 49 11 f0       	mov    %eax,0xf0114968
	memset(kern_pgdir, 0, PGSIZE);
f0100fb9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100fc0:	00 
f0100fc1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100fc8:	00 
f0100fc9:	89 04 24             	mov    %eax,(%esp)
f0100fcc:	e8 06 13 00 00       	call   f01022d7 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100fd1:	a1 68 49 11 f0       	mov    0xf0114968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100fd6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100fdb:	77 20                	ja     f0100ffd <mem_init+0x117>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100fdd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fe1:	c7 44 24 08 c8 2d 10 	movl   $0xf0102dc8,0x8(%esp)
f0100fe8:	f0 
f0100fe9:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
f0100ff0:	00 
f0100ff1:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0100ff8:	e8 97 f0 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100ffd:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101003:	83 ca 05             	or     $0x5,%edx
f0101006:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	
	
	
	pages = (struct PageInfo*)boot_alloc(npages*sizeof(struct PageInfo));
f010100c:	a1 64 49 11 f0       	mov    0xf0114964,%eax
f0101011:	c1 e0 03             	shl    $0x3,%eax
f0101014:	e8 19 f9 ff ff       	call   f0100932 <boot_alloc>
f0101019:	a3 6c 49 11 f0       	mov    %eax,0xf011496c

	memset(pages, 0, npages*sizeof(struct PageInfo));
f010101e:	8b 3d 64 49 11 f0    	mov    0xf0114964,%edi
f0101024:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f010102b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010102f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101036:	00 
f0101037:	89 04 24             	mov    %eax,(%esp)
f010103a:	e8 98 12 00 00       	call   f01022d7 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010103f:	e8 f9 fc ff ff       	call   f0100d3d <page_init>

	check_page_free_list(1);
f0101044:	b8 01 00 00 00       	mov    $0x1,%eax
f0101049:	e8 a6 f9 ff ff       	call   f01009f4 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010104e:	83 3d 6c 49 11 f0 00 	cmpl   $0x0,0xf011496c
f0101055:	75 1c                	jne    f0101073 <mem_init+0x18d>
		panic("'pages' is a null pointer!");
f0101057:	c7 44 24 08 20 2f 10 	movl   $0xf0102f20,0x8(%esp)
f010105e:	f0 
f010105f:	c7 44 24 04 44 02 00 	movl   $0x244,0x4(%esp)
f0101066:	00 
f0101067:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f010106e:	e8 21 f0 ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101073:	a1 48 45 11 f0       	mov    0xf0114548,%eax
f0101078:	bb 00 00 00 00       	mov    $0x0,%ebx
f010107d:	eb 05                	jmp    f0101084 <mem_init+0x19e>
		++nfree;
f010107f:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101082:	8b 00                	mov    (%eax),%eax
f0101084:	85 c0                	test   %eax,%eax
f0101086:	75 f7                	jne    f010107f <mem_init+0x199>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101088:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010108f:	e8 81 fd ff ff       	call   f0100e15 <page_alloc>
f0101094:	89 c7                	mov    %eax,%edi
f0101096:	85 c0                	test   %eax,%eax
f0101098:	75 24                	jne    f01010be <mem_init+0x1d8>
f010109a:	c7 44 24 0c 3b 2f 10 	movl   $0xf0102f3b,0xc(%esp)
f01010a1:	f0 
f01010a2:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f01010a9:	f0 
f01010aa:	c7 44 24 04 4c 02 00 	movl   $0x24c,0x4(%esp)
f01010b1:	00 
f01010b2:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f01010b9:	e8 d6 ef ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01010be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01010c5:	e8 4b fd ff ff       	call   f0100e15 <page_alloc>
f01010ca:	89 c6                	mov    %eax,%esi
f01010cc:	85 c0                	test   %eax,%eax
f01010ce:	75 24                	jne    f01010f4 <mem_init+0x20e>
f01010d0:	c7 44 24 0c 51 2f 10 	movl   $0xf0102f51,0xc(%esp)
f01010d7:	f0 
f01010d8:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f01010df:	f0 
f01010e0:	c7 44 24 04 4d 02 00 	movl   $0x24d,0x4(%esp)
f01010e7:	00 
f01010e8:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f01010ef:	e8 a0 ef ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01010f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01010fb:	e8 15 fd ff ff       	call   f0100e15 <page_alloc>
f0101100:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101103:	85 c0                	test   %eax,%eax
f0101105:	75 24                	jne    f010112b <mem_init+0x245>
f0101107:	c7 44 24 0c 67 2f 10 	movl   $0xf0102f67,0xc(%esp)
f010110e:	f0 
f010110f:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0101116:	f0 
f0101117:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
f010111e:	00 
f010111f:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0101126:	e8 69 ef ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010112b:	39 f7                	cmp    %esi,%edi
f010112d:	75 24                	jne    f0101153 <mem_init+0x26d>
f010112f:	c7 44 24 0c 7d 2f 10 	movl   $0xf0102f7d,0xc(%esp)
f0101136:	f0 
f0101137:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f010113e:	f0 
f010113f:	c7 44 24 04 51 02 00 	movl   $0x251,0x4(%esp)
f0101146:	00 
f0101147:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f010114e:	e8 41 ef ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101153:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101156:	39 c6                	cmp    %eax,%esi
f0101158:	74 04                	je     f010115e <mem_init+0x278>
f010115a:	39 c7                	cmp    %eax,%edi
f010115c:	75 24                	jne    f0101182 <mem_init+0x29c>
f010115e:	c7 44 24 0c ec 2d 10 	movl   $0xf0102dec,0xc(%esp)
f0101165:	f0 
f0101166:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f010116d:	f0 
f010116e:	c7 44 24 04 52 02 00 	movl   $0x252,0x4(%esp)
f0101175:	00 
f0101176:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f010117d:	e8 12 ef ff ff       	call   f0100094 <_panic>

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	//return (physaddr_t)(((uint32_t)pp - (uint32_t)pages) << PGSHIFT);
	return (pp - pages) << PGSHIFT;
f0101182:	8b 15 6c 49 11 f0    	mov    0xf011496c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101188:	a1 64 49 11 f0       	mov    0xf0114964,%eax
f010118d:	c1 e0 0c             	shl    $0xc,%eax
f0101190:	89 f9                	mov    %edi,%ecx
f0101192:	29 d1                	sub    %edx,%ecx
f0101194:	c1 f9 03             	sar    $0x3,%ecx
f0101197:	c1 e1 0c             	shl    $0xc,%ecx
f010119a:	39 c1                	cmp    %eax,%ecx
f010119c:	72 24                	jb     f01011c2 <mem_init+0x2dc>
f010119e:	c7 44 24 0c 8f 2f 10 	movl   $0xf0102f8f,0xc(%esp)
f01011a5:	f0 
f01011a6:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f01011ad:	f0 
f01011ae:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
f01011b5:	00 
f01011b6:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f01011bd:	e8 d2 ee ff ff       	call   f0100094 <_panic>
f01011c2:	89 f1                	mov    %esi,%ecx
f01011c4:	29 d1                	sub    %edx,%ecx
f01011c6:	c1 f9 03             	sar    $0x3,%ecx
f01011c9:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01011cc:	39 c8                	cmp    %ecx,%eax
f01011ce:	77 24                	ja     f01011f4 <mem_init+0x30e>
f01011d0:	c7 44 24 0c ac 2f 10 	movl   $0xf0102fac,0xc(%esp)
f01011d7:	f0 
f01011d8:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f01011df:	f0 
f01011e0:	c7 44 24 04 54 02 00 	movl   $0x254,0x4(%esp)
f01011e7:	00 
f01011e8:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f01011ef:	e8 a0 ee ff ff       	call   f0100094 <_panic>
f01011f4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01011f7:	29 d1                	sub    %edx,%ecx
f01011f9:	89 ca                	mov    %ecx,%edx
f01011fb:	c1 fa 03             	sar    $0x3,%edx
f01011fe:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101201:	39 d0                	cmp    %edx,%eax
f0101203:	77 24                	ja     f0101229 <mem_init+0x343>
f0101205:	c7 44 24 0c c9 2f 10 	movl   $0xf0102fc9,0xc(%esp)
f010120c:	f0 
f010120d:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0101214:	f0 
f0101215:	c7 44 24 04 55 02 00 	movl   $0x255,0x4(%esp)
f010121c:	00 
f010121d:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0101224:	e8 6b ee ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101229:	a1 48 45 11 f0       	mov    0xf0114548,%eax
f010122e:	89 45 e0             	mov    %eax,-0x20(%ebp)
	page_free_list = 0;
f0101231:	c7 05 48 45 11 f0 00 	movl   $0x0,0xf0114548
f0101238:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010123b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101242:	e8 ce fb ff ff       	call   f0100e15 <page_alloc>
f0101247:	85 c0                	test   %eax,%eax
f0101249:	74 24                	je     f010126f <mem_init+0x389>
f010124b:	c7 44 24 0c e6 2f 10 	movl   $0xf0102fe6,0xc(%esp)
f0101252:	f0 
f0101253:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f010125a:	f0 
f010125b:	c7 44 24 04 5c 02 00 	movl   $0x25c,0x4(%esp)
f0101262:	00 
f0101263:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f010126a:	e8 25 ee ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010126f:	89 3c 24             	mov    %edi,(%esp)
f0101272:	e8 2f fc ff ff       	call   f0100ea6 <page_free>
	page_free(pp1);
f0101277:	89 34 24             	mov    %esi,(%esp)
f010127a:	e8 27 fc ff ff       	call   f0100ea6 <page_free>
	page_free(pp2);
f010127f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101282:	89 04 24             	mov    %eax,(%esp)
f0101285:	e8 1c fc ff ff       	call   f0100ea6 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010128a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101291:	e8 7f fb ff ff       	call   f0100e15 <page_alloc>
f0101296:	89 c6                	mov    %eax,%esi
f0101298:	85 c0                	test   %eax,%eax
f010129a:	75 24                	jne    f01012c0 <mem_init+0x3da>
f010129c:	c7 44 24 0c 3b 2f 10 	movl   $0xf0102f3b,0xc(%esp)
f01012a3:	f0 
f01012a4:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f01012ab:	f0 
f01012ac:	c7 44 24 04 63 02 00 	movl   $0x263,0x4(%esp)
f01012b3:	00 
f01012b4:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f01012bb:	e8 d4 ed ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01012c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012c7:	e8 49 fb ff ff       	call   f0100e15 <page_alloc>
f01012cc:	89 c7                	mov    %eax,%edi
f01012ce:	85 c0                	test   %eax,%eax
f01012d0:	75 24                	jne    f01012f6 <mem_init+0x410>
f01012d2:	c7 44 24 0c 51 2f 10 	movl   $0xf0102f51,0xc(%esp)
f01012d9:	f0 
f01012da:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f01012e1:	f0 
f01012e2:	c7 44 24 04 64 02 00 	movl   $0x264,0x4(%esp)
f01012e9:	00 
f01012ea:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f01012f1:	e8 9e ed ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01012f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012fd:	e8 13 fb ff ff       	call   f0100e15 <page_alloc>
f0101302:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101305:	85 c0                	test   %eax,%eax
f0101307:	75 24                	jne    f010132d <mem_init+0x447>
f0101309:	c7 44 24 0c 67 2f 10 	movl   $0xf0102f67,0xc(%esp)
f0101310:	f0 
f0101311:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0101318:	f0 
f0101319:	c7 44 24 04 65 02 00 	movl   $0x265,0x4(%esp)
f0101320:	00 
f0101321:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0101328:	e8 67 ed ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010132d:	39 fe                	cmp    %edi,%esi
f010132f:	75 24                	jne    f0101355 <mem_init+0x46f>
f0101331:	c7 44 24 0c 7d 2f 10 	movl   $0xf0102f7d,0xc(%esp)
f0101338:	f0 
f0101339:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0101340:	f0 
f0101341:	c7 44 24 04 67 02 00 	movl   $0x267,0x4(%esp)
f0101348:	00 
f0101349:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0101350:	e8 3f ed ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101355:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101358:	39 c7                	cmp    %eax,%edi
f010135a:	74 04                	je     f0101360 <mem_init+0x47a>
f010135c:	39 c6                	cmp    %eax,%esi
f010135e:	75 24                	jne    f0101384 <mem_init+0x49e>
f0101360:	c7 44 24 0c ec 2d 10 	movl   $0xf0102dec,0xc(%esp)
f0101367:	f0 
f0101368:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f010136f:	f0 
f0101370:	c7 44 24 04 68 02 00 	movl   $0x268,0x4(%esp)
f0101377:	00 
f0101378:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f010137f:	e8 10 ed ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101384:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010138b:	e8 85 fa ff ff       	call   f0100e15 <page_alloc>
f0101390:	85 c0                	test   %eax,%eax
f0101392:	74 24                	je     f01013b8 <mem_init+0x4d2>
f0101394:	c7 44 24 0c e6 2f 10 	movl   $0xf0102fe6,0xc(%esp)
f010139b:	f0 
f010139c:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f01013a3:	f0 
f01013a4:	c7 44 24 04 69 02 00 	movl   $0x269,0x4(%esp)
f01013ab:	00 
f01013ac:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f01013b3:	e8 dc ec ff ff       	call   f0100094 <_panic>
f01013b8:	89 f0                	mov    %esi,%eax
f01013ba:	2b 05 6c 49 11 f0    	sub    0xf011496c,%eax
f01013c0:	c1 f8 03             	sar    $0x3,%eax
f01013c3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013c6:	89 c2                	mov    %eax,%edx
f01013c8:	c1 ea 0c             	shr    $0xc,%edx
f01013cb:	3b 15 64 49 11 f0    	cmp    0xf0114964,%edx
f01013d1:	72 20                	jb     f01013f3 <mem_init+0x50d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013d7:	c7 44 24 08 a4 2c 10 	movl   $0xf0102ca4,0x8(%esp)
f01013de:	f0 
f01013df:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f01013e6:	00 
f01013e7:	c7 04 24 68 2e 10 f0 	movl   $0xf0102e68,(%esp)
f01013ee:	e8 a1 ec ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01013f3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01013fa:	00 
f01013fb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101402:	00 
	return (void *)(pa + KERNBASE);
f0101403:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101408:	89 04 24             	mov    %eax,(%esp)
f010140b:	e8 c7 0e 00 00       	call   f01022d7 <memset>
	page_free(pp0);
f0101410:	89 34 24             	mov    %esi,(%esp)
f0101413:	e8 8e fa ff ff       	call   f0100ea6 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101418:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010141f:	e8 f1 f9 ff ff       	call   f0100e15 <page_alloc>
f0101424:	85 c0                	test   %eax,%eax
f0101426:	75 24                	jne    f010144c <mem_init+0x566>
f0101428:	c7 44 24 0c f5 2f 10 	movl   $0xf0102ff5,0xc(%esp)
f010142f:	f0 
f0101430:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0101437:	f0 
f0101438:	c7 44 24 04 6e 02 00 	movl   $0x26e,0x4(%esp)
f010143f:	00 
f0101440:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0101447:	e8 48 ec ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f010144c:	39 c6                	cmp    %eax,%esi
f010144e:	74 24                	je     f0101474 <mem_init+0x58e>
f0101450:	c7 44 24 0c 13 30 10 	movl   $0xf0103013,0xc(%esp)
f0101457:	f0 
f0101458:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f010145f:	f0 
f0101460:	c7 44 24 04 6f 02 00 	movl   $0x26f,0x4(%esp)
f0101467:	00 
f0101468:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f010146f:	e8 20 ec ff ff       	call   f0100094 <_panic>

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	//return (physaddr_t)(((uint32_t)pp - (uint32_t)pages) << PGSHIFT);
	return (pp - pages) << PGSHIFT;
f0101474:	89 f0                	mov    %esi,%eax
f0101476:	2b 05 6c 49 11 f0    	sub    0xf011496c,%eax
f010147c:	c1 f8 03             	sar    $0x3,%eax
f010147f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101482:	89 c2                	mov    %eax,%edx
f0101484:	c1 ea 0c             	shr    $0xc,%edx
f0101487:	3b 15 64 49 11 f0    	cmp    0xf0114964,%edx
f010148d:	72 20                	jb     f01014af <mem_init+0x5c9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010148f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101493:	c7 44 24 08 a4 2c 10 	movl   $0xf0102ca4,0x8(%esp)
f010149a:	f0 
f010149b:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f01014a2:	00 
f01014a3:	c7 04 24 68 2e 10 f0 	movl   $0xf0102e68,(%esp)
f01014aa:	e8 e5 eb ff ff       	call   f0100094 <_panic>
f01014af:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01014b5:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01014bb:	80 38 00             	cmpb   $0x0,(%eax)
f01014be:	74 24                	je     f01014e4 <mem_init+0x5fe>
f01014c0:	c7 44 24 0c 23 30 10 	movl   $0xf0103023,0xc(%esp)
f01014c7:	f0 
f01014c8:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f01014cf:	f0 
f01014d0:	c7 44 24 04 72 02 00 	movl   $0x272,0x4(%esp)
f01014d7:	00 
f01014d8:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f01014df:	e8 b0 eb ff ff       	call   f0100094 <_panic>
f01014e4:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01014e7:	39 d0                	cmp    %edx,%eax
f01014e9:	75 d0                	jne    f01014bb <mem_init+0x5d5>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01014eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01014ee:	a3 48 45 11 f0       	mov    %eax,0xf0114548

	// free the pages we took
	page_free(pp0);
f01014f3:	89 34 24             	mov    %esi,(%esp)
f01014f6:	e8 ab f9 ff ff       	call   f0100ea6 <page_free>
	page_free(pp1);
f01014fb:	89 3c 24             	mov    %edi,(%esp)
f01014fe:	e8 a3 f9 ff ff       	call   f0100ea6 <page_free>
	page_free(pp2);
f0101503:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101506:	89 04 24             	mov    %eax,(%esp)
f0101509:	e8 98 f9 ff ff       	call   f0100ea6 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010150e:	a1 48 45 11 f0       	mov    0xf0114548,%eax
f0101513:	eb 05                	jmp    f010151a <mem_init+0x634>
		--nfree;
f0101515:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101518:	8b 00                	mov    (%eax),%eax
f010151a:	85 c0                	test   %eax,%eax
f010151c:	75 f7                	jne    f0101515 <mem_init+0x62f>
		--nfree;
	assert(nfree == 0);
f010151e:	85 db                	test   %ebx,%ebx
f0101520:	74 24                	je     f0101546 <mem_init+0x660>
f0101522:	c7 44 24 0c 2d 30 10 	movl   $0xf010302d,0xc(%esp)
f0101529:	f0 
f010152a:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0101531:	f0 
f0101532:	c7 44 24 04 7f 02 00 	movl   $0x27f,0x4(%esp)
f0101539:	00 
f010153a:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0101541:	e8 4e eb ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101546:	c7 04 24 0c 2e 10 f0 	movl   $0xf0102e0c,(%esp)
f010154d:	e8 17 02 00 00       	call   f0101769 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101552:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101559:	e8 b7 f8 ff ff       	call   f0100e15 <page_alloc>
f010155e:	89 c3                	mov    %eax,%ebx
f0101560:	85 c0                	test   %eax,%eax
f0101562:	75 24                	jne    f0101588 <mem_init+0x6a2>
f0101564:	c7 44 24 0c 3b 2f 10 	movl   $0xf0102f3b,0xc(%esp)
f010156b:	f0 
f010156c:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0101573:	f0 
f0101574:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f010157b:	00 
f010157c:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0101583:	e8 0c eb ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101588:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010158f:	e8 81 f8 ff ff       	call   f0100e15 <page_alloc>
f0101594:	89 c6                	mov    %eax,%esi
f0101596:	85 c0                	test   %eax,%eax
f0101598:	75 24                	jne    f01015be <mem_init+0x6d8>
f010159a:	c7 44 24 0c 51 2f 10 	movl   $0xf0102f51,0xc(%esp)
f01015a1:	f0 
f01015a2:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f01015a9:	f0 
f01015aa:	c7 44 24 04 d9 02 00 	movl   $0x2d9,0x4(%esp)
f01015b1:	00 
f01015b2:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f01015b9:	e8 d6 ea ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01015be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015c5:	e8 4b f8 ff ff       	call   f0100e15 <page_alloc>
f01015ca:	85 c0                	test   %eax,%eax
f01015cc:	75 24                	jne    f01015f2 <mem_init+0x70c>
f01015ce:	c7 44 24 0c 67 2f 10 	movl   $0xf0102f67,0xc(%esp)
f01015d5:	f0 
f01015d6:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f01015dd:	f0 
f01015de:	c7 44 24 04 da 02 00 	movl   $0x2da,0x4(%esp)
f01015e5:	00 
f01015e6:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f01015ed:	e8 a2 ea ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015f2:	39 f3                	cmp    %esi,%ebx
f01015f4:	75 24                	jne    f010161a <mem_init+0x734>
f01015f6:	c7 44 24 0c 7d 2f 10 	movl   $0xf0102f7d,0xc(%esp)
f01015fd:	f0 
f01015fe:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0101605:	f0 
f0101606:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f010160d:	00 
f010160e:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0101615:	e8 7a ea ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010161a:	39 c6                	cmp    %eax,%esi
f010161c:	74 04                	je     f0101622 <mem_init+0x73c>
f010161e:	39 c3                	cmp    %eax,%ebx
f0101620:	75 24                	jne    f0101646 <mem_init+0x760>
f0101622:	c7 44 24 0c ec 2d 10 	movl   $0xf0102dec,0xc(%esp)
f0101629:	f0 
f010162a:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0101631:	f0 
f0101632:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f0101639:	00 
f010163a:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f0101641:	e8 4e ea ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;
f0101646:	c7 05 48 45 11 f0 00 	movl   $0x0,0xf0114548
f010164d:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101650:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101657:	e8 b9 f7 ff ff       	call   f0100e15 <page_alloc>
f010165c:	85 c0                	test   %eax,%eax
f010165e:	74 24                	je     f0101684 <mem_init+0x79e>
f0101660:	c7 44 24 0c e6 2f 10 	movl   $0xf0102fe6,0xc(%esp)
f0101667:	f0 
f0101668:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f010166f:	f0 
f0101670:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
f0101677:	00 
f0101678:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f010167f:	e8 10 ea ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101684:	c7 44 24 0c 2c 2e 10 	movl   $0xf0102e2c,0xc(%esp)
f010168b:	f0 
f010168c:	c7 44 24 08 82 2e 10 	movl   $0xf0102e82,0x8(%esp)
f0101693:	f0 
f0101694:	c7 44 24 04 eb 02 00 	movl   $0x2eb,0x4(%esp)
f010169b:	00 
f010169c:	c7 04 24 5c 2e 10 f0 	movl   $0xf0102e5c,(%esp)
f01016a3:	e8 ec e9 ff ff       	call   f0100094 <_panic>

f01016a8 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f01016a8:	55                   	push   %ebp
f01016a9:	89 e5                	mov    %esp,%ebp
f01016ab:	83 ec 18             	sub    $0x18,%esp
f01016ae:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f01016b1:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f01016b5:	8d 51 ff             	lea    -0x1(%ecx),%edx
f01016b8:	66 89 50 04          	mov    %dx,0x4(%eax)
f01016bc:	66 85 d2             	test   %dx,%dx
f01016bf:	75 08                	jne    f01016c9 <page_decref+0x21>
		page_free(pp);
f01016c1:	89 04 24             	mov    %eax,(%esp)
f01016c4:	e8 dd f7 ff ff       	call   f0100ea6 <page_free>
}
f01016c9:	c9                   	leave  
f01016ca:	c3                   	ret    

f01016cb <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01016cb:	55                   	push   %ebp
f01016cc:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f01016ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01016d3:	5d                   	pop    %ebp
f01016d4:	c3                   	ret    

f01016d5 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01016d5:	55                   	push   %ebp
f01016d6:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f01016d8:	b8 00 00 00 00       	mov    $0x0,%eax
f01016dd:	5d                   	pop    %ebp
f01016de:	c3                   	ret    

f01016df <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01016df:	55                   	push   %ebp
f01016e0:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f01016e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01016e7:	5d                   	pop    %ebp
f01016e8:	c3                   	ret    

f01016e9 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01016e9:	55                   	push   %ebp
f01016ea:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f01016ec:	5d                   	pop    %ebp
f01016ed:	c3                   	ret    

f01016ee <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01016ee:	55                   	push   %ebp
f01016ef:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01016f1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016f4:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01016f7:	5d                   	pop    %ebp
f01016f8:	c3                   	ret    

f01016f9 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01016f9:	55                   	push   %ebp
f01016fa:	89 e5                	mov    %esp,%ebp
f01016fc:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0101700:	ba 70 00 00 00       	mov    $0x70,%edx
f0101705:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0101706:	b2 71                	mov    $0x71,%dl
f0101708:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0101709:	0f b6 c0             	movzbl %al,%eax
}
f010170c:	5d                   	pop    %ebp
f010170d:	c3                   	ret    

f010170e <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010170e:	55                   	push   %ebp
f010170f:	89 e5                	mov    %esp,%ebp
f0101711:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0101715:	ba 70 00 00 00       	mov    $0x70,%edx
f010171a:	ee                   	out    %al,(%dx)
f010171b:	b2 71                	mov    $0x71,%dl
f010171d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101720:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0101721:	5d                   	pop    %ebp
f0101722:	c3                   	ret    

f0101723 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0101723:	55                   	push   %ebp
f0101724:	89 e5                	mov    %esp,%ebp
f0101726:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0101729:	8b 45 08             	mov    0x8(%ebp),%eax
f010172c:	89 04 24             	mov    %eax,(%esp)
f010172f:	e8 bd ee ff ff       	call   f01005f1 <cputchar>
	*cnt++;
}
f0101734:	c9                   	leave  
f0101735:	c3                   	ret    

f0101736 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0101736:	55                   	push   %ebp
f0101737:	89 e5                	mov    %esp,%ebp
f0101739:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010173c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0101743:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101746:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010174a:	8b 45 08             	mov    0x8(%ebp),%eax
f010174d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101751:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101754:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101758:	c7 04 24 23 17 10 f0 	movl   $0xf0101723,(%esp)
f010175f:	e8 ba 04 00 00       	call   f0101c1e <vprintfmt>
	return cnt;
}
f0101764:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101767:	c9                   	leave  
f0101768:	c3                   	ret    

f0101769 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0101769:	55                   	push   %ebp
f010176a:	89 e5                	mov    %esp,%ebp
f010176c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010176f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0101772:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101776:	8b 45 08             	mov    0x8(%ebp),%eax
f0101779:	89 04 24             	mov    %eax,(%esp)
f010177c:	e8 b5 ff ff ff       	call   f0101736 <vcprintf>
	va_end(ap);

	return cnt;
}
f0101781:	c9                   	leave  
f0101782:	c3                   	ret    

f0101783 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0101783:	55                   	push   %ebp
f0101784:	89 e5                	mov    %esp,%ebp
f0101786:	57                   	push   %edi
f0101787:	56                   	push   %esi
f0101788:	53                   	push   %ebx
f0101789:	83 ec 10             	sub    $0x10,%esp
f010178c:	89 c6                	mov    %eax,%esi
f010178e:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0101791:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101794:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0101797:	8b 1a                	mov    (%edx),%ebx
f0101799:	8b 01                	mov    (%ecx),%eax
f010179b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010179e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f01017a5:	eb 77                	jmp    f010181e <stab_binsearch+0x9b>
		int true_m = (l + r) / 2, m = true_m;
f01017a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01017aa:	01 d8                	add    %ebx,%eax
f01017ac:	b9 02 00 00 00       	mov    $0x2,%ecx
f01017b1:	99                   	cltd   
f01017b2:	f7 f9                	idiv   %ecx
f01017b4:	89 c1                	mov    %eax,%ecx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)		//seraching from middle to left most
f01017b6:	eb 01                	jmp    f01017b9 <stab_binsearch+0x36>
			m--;
f01017b8:	49                   	dec    %ecx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)		//seraching from middle to left most
f01017b9:	39 d9                	cmp    %ebx,%ecx
f01017bb:	7c 1d                	jl     f01017da <stab_binsearch+0x57>
f01017bd:	6b d1 0c             	imul   $0xc,%ecx,%edx
f01017c0:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f01017c5:	39 fa                	cmp    %edi,%edx
f01017c7:	75 ef                	jne    f01017b8 <stab_binsearch+0x35>
f01017c9:	89 4d ec             	mov    %ecx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01017cc:	6b d1 0c             	imul   $0xc,%ecx,%edx
f01017cf:	8b 54 16 08          	mov    0x8(%esi,%edx,1),%edx
f01017d3:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01017d6:	73 18                	jae    f01017f0 <stab_binsearch+0x6d>
f01017d8:	eb 05                	jmp    f01017df <stab_binsearch+0x5c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)		//seraching from middle to left most
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01017da:	8d 58 01             	lea    0x1(%eax),%ebx
			continue;
f01017dd:	eb 3f                	jmp    f010181e <stab_binsearch+0x9b>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01017df:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01017e2:	89 0b                	mov    %ecx,(%ebx)
			l = true_m + 1;
f01017e4:	8d 58 01             	lea    0x1(%eax),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01017e7:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f01017ee:	eb 2e                	jmp    f010181e <stab_binsearch+0x9b>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01017f0:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01017f3:	73 15                	jae    f010180a <stab_binsearch+0x87>
			*region_right = m - 1;
f01017f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01017f8:	48                   	dec    %eax
f01017f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01017fc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01017ff:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101801:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0101808:	eb 14                	jmp    f010181e <stab_binsearch+0x9b>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010180a:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010180d:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0101810:	89 18                	mov    %ebx,(%eax)
			l = m;
			addr++;
f0101812:	ff 45 0c             	incl   0xc(%ebp)
f0101815:	89 cb                	mov    %ecx,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101817:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010181e:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0101821:	7e 84                	jle    f01017a7 <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0101823:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0101827:	75 0d                	jne    f0101836 <stab_binsearch+0xb3>
		*region_right = *region_left - 1;
f0101829:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010182c:	8b 00                	mov    (%eax),%eax
f010182e:	48                   	dec    %eax
f010182f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101832:	89 07                	mov    %eax,(%edi)
f0101834:	eb 22                	jmp    f0101858 <stab_binsearch+0xd5>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101836:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101839:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010183b:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f010183e:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101840:	eb 01                	jmp    f0101843 <stab_binsearch+0xc0>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0101842:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101843:	39 c1                	cmp    %eax,%ecx
f0101845:	7d 0c                	jge    f0101853 <stab_binsearch+0xd0>
f0101847:	6b d0 0c             	imul   $0xc,%eax,%edx
		     l > *region_left && stabs[l].n_type != type;
f010184a:	0f b6 54 16 04       	movzbl 0x4(%esi,%edx,1),%edx
f010184f:	39 fa                	cmp    %edi,%edx
f0101851:	75 ef                	jne    f0101842 <stab_binsearch+0xbf>
		     l--)
			/* do nothing */;
		*region_left = l;
f0101853:	8b 7d e8             	mov    -0x18(%ebp),%edi
f0101856:	89 07                	mov    %eax,(%edi)
	}
}
f0101858:	83 c4 10             	add    $0x10,%esp
f010185b:	5b                   	pop    %ebx
f010185c:	5e                   	pop    %esi
f010185d:	5f                   	pop    %edi
f010185e:	5d                   	pop    %ebp
f010185f:	c3                   	ret    

f0101860 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0101860:	55                   	push   %ebp
f0101861:	89 e5                	mov    %esp,%ebp
f0101863:	57                   	push   %edi
f0101864:	56                   	push   %esi
f0101865:	53                   	push   %ebx
f0101866:	83 ec 3c             	sub    $0x3c,%esp
f0101869:	8b 75 08             	mov    0x8(%ebp),%esi
f010186c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010186f:	c7 03 38 30 10 f0    	movl   $0xf0103038,(%ebx)
	info->eip_line = 0;
f0101875:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010187c:	c7 43 08 38 30 10 f0 	movl   $0xf0103038,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0101883:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010188a:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010188d:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0101894:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010189a:	76 12                	jbe    f01018ae <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010189c:	b8 70 9c 10 f0       	mov    $0xf0109c70,%eax
f01018a1:	3d 1d 7f 10 f0       	cmp    $0xf0107f1d,%eax
f01018a6:	0f 86 cd 01 00 00    	jbe    f0101a79 <debuginfo_eip+0x219>
f01018ac:	eb 1c                	jmp    f01018ca <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f01018ae:	c7 44 24 08 42 30 10 	movl   $0xf0103042,0x8(%esp)
f01018b5:	f0 
f01018b6:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f01018bd:	00 
f01018be:	c7 04 24 4f 30 10 f0 	movl   $0xf010304f,(%esp)
f01018c5:	e8 ca e7 ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01018ca:	80 3d 6f 9c 10 f0 00 	cmpb   $0x0,0xf0109c6f
f01018d1:	0f 85 a9 01 00 00    	jne    f0101a80 <debuginfo_eip+0x220>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01018d7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01018de:	b8 1c 7f 10 f0       	mov    $0xf0107f1c,%eax
f01018e3:	2d 90 32 10 f0       	sub    $0xf0103290,%eax
f01018e8:	c1 f8 02             	sar    $0x2,%eax
f01018eb:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01018f1:	83 e8 01             	sub    $0x1,%eax
f01018f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);		//N_SO since we are searching source file
f01018f7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018fb:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0101902:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0101905:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0101908:	b8 90 32 10 f0       	mov    $0xf0103290,%eax
f010190d:	e8 71 fe ff ff       	call   f0101783 <stab_binsearch>
	if (lfile == 0)
f0101912:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101915:	85 c0                	test   %eax,%eax
f0101917:	0f 84 6a 01 00 00    	je     f0101a87 <debuginfo_eip+0x227>
		return -1;

	//info->eip_file =(char *)stabs[rfile].n_strx;
	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010191d:	89 45 dc             	mov    %eax,-0x24(%ebp)


	rfun = rfile;
f0101920:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101923:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);		//N_FUN since we are searching function 
f0101926:	89 74 24 04          	mov    %esi,0x4(%esp)
f010192a:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0101931:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0101934:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101937:	b8 90 32 10 f0       	mov    $0xf0103290,%eax
f010193c:	e8 42 fe ff ff       	call   f0101783 <stab_binsearch>

	if (lfun <= rfun) {
f0101941:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101944:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101947:	39 d0                	cmp    %edx,%eax
f0101949:	7f 3d                	jg     f0101988 <debuginfo_eip+0x128>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010194b:	6b c8 0c             	imul   $0xc,%eax,%ecx
f010194e:	8d b9 90 32 10 f0    	lea    -0xfefcd70(%ecx),%edi
f0101954:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0101957:	8b 89 90 32 10 f0    	mov    -0xfefcd70(%ecx),%ecx
f010195d:	bf 70 9c 10 f0       	mov    $0xf0109c70,%edi
f0101962:	81 ef 1d 7f 10 f0    	sub    $0xf0107f1d,%edi
f0101968:	39 f9                	cmp    %edi,%ecx
f010196a:	73 09                	jae    f0101975 <debuginfo_eip+0x115>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010196c:	81 c1 1d 7f 10 f0    	add    $0xf0107f1d,%ecx
f0101972:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0101975:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0101978:	8b 4f 08             	mov    0x8(%edi),%ecx
f010197b:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010197e:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0101980:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0101983:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0101986:	eb 0f                	jmp    f0101997 <debuginfo_eip+0x137>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0101988:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010198b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010198e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0101991:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101994:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0101997:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010199e:	00 
f010199f:	8b 43 08             	mov    0x8(%ebx),%eax
f01019a2:	89 04 24             	mov    %eax,(%esp)
f01019a5:	e8 11 09 00 00       	call   f01022bb <strfind>
f01019aa:	2b 43 08             	sub    0x8(%ebx),%eax
f01019ad:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01019b0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01019b4:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01019bb:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01019be:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01019c1:	b8 90 32 10 f0       	mov    $0xf0103290,%eax
f01019c6:	e8 b8 fd ff ff       	call   f0101783 <stab_binsearch>
	if(lline > rline)	//Check bounds
f01019cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019ce:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f01019d1:	0f 8f b7 00 00 00    	jg     f0101a8e <debuginfo_eip+0x22e>
		return -1;	//error

	info->eip_line = stabs[lline].n_desc;
f01019d7:	6b c0 0c             	imul   $0xc,%eax,%eax
f01019da:	0f b7 80 96 32 10 f0 	movzwl -0xfefcd6a(%eax),%eax
f01019e1:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01019e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01019e7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01019ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019ed:	6b d0 0c             	imul   $0xc,%eax,%edx
f01019f0:	81 c2 90 32 10 f0    	add    $0xf0103290,%edx
f01019f6:	eb 06                	jmp    f01019fe <debuginfo_eip+0x19e>
f01019f8:	83 e8 01             	sub    $0x1,%eax
f01019fb:	83 ea 0c             	sub    $0xc,%edx
f01019fe:	89 c6                	mov    %eax,%esi
f0101a00:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0101a03:	7f 33                	jg     f0101a38 <debuginfo_eip+0x1d8>
	       && stabs[lline].n_type != N_SOL
f0101a05:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0101a09:	80 f9 84             	cmp    $0x84,%cl
f0101a0c:	74 0b                	je     f0101a19 <debuginfo_eip+0x1b9>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0101a0e:	80 f9 64             	cmp    $0x64,%cl
f0101a11:	75 e5                	jne    f01019f8 <debuginfo_eip+0x198>
f0101a13:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0101a17:	74 df                	je     f01019f8 <debuginfo_eip+0x198>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0101a19:	6b f6 0c             	imul   $0xc,%esi,%esi
f0101a1c:	8b 86 90 32 10 f0    	mov    -0xfefcd70(%esi),%eax
f0101a22:	ba 70 9c 10 f0       	mov    $0xf0109c70,%edx
f0101a27:	81 ea 1d 7f 10 f0    	sub    $0xf0107f1d,%edx
f0101a2d:	39 d0                	cmp    %edx,%eax
f0101a2f:	73 07                	jae    f0101a38 <debuginfo_eip+0x1d8>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0101a31:	05 1d 7f 10 f0       	add    $0xf0107f1d,%eax
f0101a36:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101a38:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101a3b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101a3e:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101a43:	39 ca                	cmp    %ecx,%edx
f0101a45:	7d 53                	jge    f0101a9a <debuginfo_eip+0x23a>
		for (lline = lfun + 1;
f0101a47:	8d 42 01             	lea    0x1(%edx),%eax
f0101a4a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101a4d:	89 c2                	mov    %eax,%edx
f0101a4f:	6b c0 0c             	imul   $0xc,%eax,%eax
f0101a52:	05 90 32 10 f0       	add    $0xf0103290,%eax
f0101a57:	89 ce                	mov    %ecx,%esi
f0101a59:	eb 04                	jmp    f0101a5f <debuginfo_eip+0x1ff>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0101a5b:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0101a5f:	39 d6                	cmp    %edx,%esi
f0101a61:	7e 32                	jle    f0101a95 <debuginfo_eip+0x235>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0101a63:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0101a67:	83 c2 01             	add    $0x1,%edx
f0101a6a:	83 c0 0c             	add    $0xc,%eax
f0101a6d:	80 f9 a0             	cmp    $0xa0,%cl
f0101a70:	74 e9                	je     f0101a5b <debuginfo_eip+0x1fb>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101a72:	b8 00 00 00 00       	mov    $0x0,%eax
f0101a77:	eb 21                	jmp    f0101a9a <debuginfo_eip+0x23a>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0101a79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101a7e:	eb 1a                	jmp    f0101a9a <debuginfo_eip+0x23a>
f0101a80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101a85:	eb 13                	jmp    f0101a9a <debuginfo_eip+0x23a>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);		//N_SO since we are searching source file
	if (lfile == 0)
		return -1;
f0101a87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101a8c:	eb 0c                	jmp    f0101a9a <debuginfo_eip+0x23a>
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if(lline > rline)	//Check bounds
		return -1;	//error
f0101a8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101a93:	eb 05                	jmp    f0101a9a <debuginfo_eip+0x23a>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101a95:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101a9a:	83 c4 3c             	add    $0x3c,%esp
f0101a9d:	5b                   	pop    %ebx
f0101a9e:	5e                   	pop    %esi
f0101a9f:	5f                   	pop    %edi
f0101aa0:	5d                   	pop    %ebp
f0101aa1:	c3                   	ret    
f0101aa2:	66 90                	xchg   %ax,%ax
f0101aa4:	66 90                	xchg   %ax,%ax
f0101aa6:	66 90                	xchg   %ax,%ax
f0101aa8:	66 90                	xchg   %ax,%ax
f0101aaa:	66 90                	xchg   %ax,%ax
f0101aac:	66 90                	xchg   %ax,%ax
f0101aae:	66 90                	xchg   %ax,%ax

f0101ab0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0101ab0:	55                   	push   %ebp
f0101ab1:	89 e5                	mov    %esp,%ebp
f0101ab3:	57                   	push   %edi
f0101ab4:	56                   	push   %esi
f0101ab5:	53                   	push   %ebx
f0101ab6:	83 ec 3c             	sub    $0x3c,%esp
f0101ab9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101abc:	89 d7                	mov    %edx,%edi
f0101abe:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ac1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101ac7:	89 c3                	mov    %eax,%ebx
f0101ac9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101acc:	8b 45 10             	mov    0x10(%ebp),%eax
f0101acf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0101ad2:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101ad7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101ada:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101add:	39 d9                	cmp    %ebx,%ecx
f0101adf:	72 05                	jb     f0101ae6 <printnum+0x36>
f0101ae1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0101ae4:	77 69                	ja     f0101b4f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0101ae6:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0101ae9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0101aed:	83 ee 01             	sub    $0x1,%esi
f0101af0:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101af4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101af8:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101afc:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0101b00:	89 c3                	mov    %eax,%ebx
f0101b02:	89 d6                	mov    %edx,%esi
f0101b04:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101b07:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101b0a:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101b0e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101b12:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101b15:	89 04 24             	mov    %eax,(%esp)
f0101b18:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b1f:	e8 bc 09 00 00       	call   f01024e0 <__udivdi3>
f0101b24:	89 d9                	mov    %ebx,%ecx
f0101b26:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101b2a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101b2e:	89 04 24             	mov    %eax,(%esp)
f0101b31:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101b35:	89 fa                	mov    %edi,%edx
f0101b37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101b3a:	e8 71 ff ff ff       	call   f0101ab0 <printnum>
f0101b3f:	eb 1b                	jmp    f0101b5c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0101b41:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101b45:	8b 45 18             	mov    0x18(%ebp),%eax
f0101b48:	89 04 24             	mov    %eax,(%esp)
f0101b4b:	ff d3                	call   *%ebx
f0101b4d:	eb 03                	jmp    f0101b52 <printnum+0xa2>
f0101b4f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0101b52:	83 ee 01             	sub    $0x1,%esi
f0101b55:	85 f6                	test   %esi,%esi
f0101b57:	7f e8                	jg     f0101b41 <printnum+0x91>
f0101b59:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101b5c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101b60:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0101b64:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101b67:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101b6a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101b6e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101b72:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101b75:	89 04 24             	mov    %eax,(%esp)
f0101b78:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b7b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101b7f:	e8 8c 0a 00 00       	call   f0102610 <__umoddi3>
f0101b84:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101b88:	0f be 80 5d 30 10 f0 	movsbl -0xfefcfa3(%eax),%eax
f0101b8f:	89 04 24             	mov    %eax,(%esp)
f0101b92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101b95:	ff d0                	call   *%eax
}
f0101b97:	83 c4 3c             	add    $0x3c,%esp
f0101b9a:	5b                   	pop    %ebx
f0101b9b:	5e                   	pop    %esi
f0101b9c:	5f                   	pop    %edi
f0101b9d:	5d                   	pop    %ebp
f0101b9e:	c3                   	ret    

f0101b9f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0101b9f:	55                   	push   %ebp
f0101ba0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0101ba2:	83 fa 01             	cmp    $0x1,%edx
f0101ba5:	7e 0e                	jle    f0101bb5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0101ba7:	8b 10                	mov    (%eax),%edx
f0101ba9:	8d 4a 08             	lea    0x8(%edx),%ecx
f0101bac:	89 08                	mov    %ecx,(%eax)
f0101bae:	8b 02                	mov    (%edx),%eax
f0101bb0:	8b 52 04             	mov    0x4(%edx),%edx
f0101bb3:	eb 22                	jmp    f0101bd7 <getuint+0x38>
	else if (lflag)
f0101bb5:	85 d2                	test   %edx,%edx
f0101bb7:	74 10                	je     f0101bc9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0101bb9:	8b 10                	mov    (%eax),%edx
f0101bbb:	8d 4a 04             	lea    0x4(%edx),%ecx
f0101bbe:	89 08                	mov    %ecx,(%eax)
f0101bc0:	8b 02                	mov    (%edx),%eax
f0101bc2:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bc7:	eb 0e                	jmp    f0101bd7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0101bc9:	8b 10                	mov    (%eax),%edx
f0101bcb:	8d 4a 04             	lea    0x4(%edx),%ecx
f0101bce:	89 08                	mov    %ecx,(%eax)
f0101bd0:	8b 02                	mov    (%edx),%eax
f0101bd2:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0101bd7:	5d                   	pop    %ebp
f0101bd8:	c3                   	ret    

f0101bd9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0101bd9:	55                   	push   %ebp
f0101bda:	89 e5                	mov    %esp,%ebp
f0101bdc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0101bdf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0101be3:	8b 10                	mov    (%eax),%edx
f0101be5:	3b 50 04             	cmp    0x4(%eax),%edx
f0101be8:	73 0a                	jae    f0101bf4 <sprintputch+0x1b>
		*b->buf++ = ch;
f0101bea:	8d 4a 01             	lea    0x1(%edx),%ecx
f0101bed:	89 08                	mov    %ecx,(%eax)
f0101bef:	8b 45 08             	mov    0x8(%ebp),%eax
f0101bf2:	88 02                	mov    %al,(%edx)
}
f0101bf4:	5d                   	pop    %ebp
f0101bf5:	c3                   	ret    

f0101bf6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0101bf6:	55                   	push   %ebp
f0101bf7:	89 e5                	mov    %esp,%ebp
f0101bf9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0101bfc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0101bff:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c03:	8b 45 10             	mov    0x10(%ebp),%eax
f0101c06:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101c0d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c11:	8b 45 08             	mov    0x8(%ebp),%eax
f0101c14:	89 04 24             	mov    %eax,(%esp)
f0101c17:	e8 02 00 00 00       	call   f0101c1e <vprintfmt>
	va_end(ap);
}
f0101c1c:	c9                   	leave  
f0101c1d:	c3                   	ret    

f0101c1e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0101c1e:	55                   	push   %ebp
f0101c1f:	89 e5                	mov    %esp,%ebp
f0101c21:	57                   	push   %edi
f0101c22:	56                   	push   %esi
f0101c23:	53                   	push   %ebx
f0101c24:	83 ec 3c             	sub    $0x3c,%esp
f0101c27:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101c2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0101c2d:	eb 14                	jmp    f0101c43 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0101c2f:	85 c0                	test   %eax,%eax
f0101c31:	0f 84 b3 03 00 00    	je     f0101fea <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
f0101c37:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101c3b:	89 04 24             	mov    %eax,(%esp)
f0101c3e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101c41:	89 f3                	mov    %esi,%ebx
f0101c43:	8d 73 01             	lea    0x1(%ebx),%esi
f0101c46:	0f b6 03             	movzbl (%ebx),%eax
f0101c49:	83 f8 25             	cmp    $0x25,%eax
f0101c4c:	75 e1                	jne    f0101c2f <vprintfmt+0x11>
f0101c4e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0101c52:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0101c59:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0101c60:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f0101c67:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c6c:	eb 1d                	jmp    f0101c8b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c6e:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0101c70:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0101c74:	eb 15                	jmp    f0101c8b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c76:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0101c78:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0101c7c:	eb 0d                	jmp    f0101c8b <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0101c7e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c81:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101c84:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c8b:	8d 5e 01             	lea    0x1(%esi),%ebx
f0101c8e:	0f b6 0e             	movzbl (%esi),%ecx
f0101c91:	0f b6 c1             	movzbl %cl,%eax
f0101c94:	83 e9 23             	sub    $0x23,%ecx
f0101c97:	80 f9 55             	cmp    $0x55,%cl
f0101c9a:	0f 87 2a 03 00 00    	ja     f0101fca <vprintfmt+0x3ac>
f0101ca0:	0f b6 c9             	movzbl %cl,%ecx
f0101ca3:	ff 24 8d 00 31 10 f0 	jmp    *-0xfefcf00(,%ecx,4)
f0101caa:	89 de                	mov    %ebx,%esi
f0101cac:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101cb1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0101cb4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0101cb8:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0101cbb:	8d 58 d0             	lea    -0x30(%eax),%ebx
f0101cbe:	83 fb 09             	cmp    $0x9,%ebx
f0101cc1:	77 36                	ja     f0101cf9 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0101cc3:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0101cc6:	eb e9                	jmp    f0101cb1 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0101cc8:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ccb:	8d 48 04             	lea    0x4(%eax),%ecx
f0101cce:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0101cd1:	8b 00                	mov    (%eax),%eax
f0101cd3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101cd6:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0101cd8:	eb 22                	jmp    f0101cfc <vprintfmt+0xde>
f0101cda:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101cdd:	85 c9                	test   %ecx,%ecx
f0101cdf:	b8 00 00 00 00       	mov    $0x0,%eax
f0101ce4:	0f 49 c1             	cmovns %ecx,%eax
f0101ce7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101cea:	89 de                	mov    %ebx,%esi
f0101cec:	eb 9d                	jmp    f0101c8b <vprintfmt+0x6d>
f0101cee:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101cf0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0101cf7:	eb 92                	jmp    f0101c8b <vprintfmt+0x6d>
f0101cf9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
f0101cfc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101d00:	79 89                	jns    f0101c8b <vprintfmt+0x6d>
f0101d02:	e9 77 ff ff ff       	jmp    f0101c7e <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0101d07:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101d0a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0101d0c:	e9 7a ff ff ff       	jmp    f0101c8b <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0101d11:	8b 45 14             	mov    0x14(%ebp),%eax
f0101d14:	8d 50 04             	lea    0x4(%eax),%edx
f0101d17:	89 55 14             	mov    %edx,0x14(%ebp)
f0101d1a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101d1e:	8b 00                	mov    (%eax),%eax
f0101d20:	89 04 24             	mov    %eax,(%esp)
f0101d23:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101d26:	e9 18 ff ff ff       	jmp    f0101c43 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101d2b:	8b 45 14             	mov    0x14(%ebp),%eax
f0101d2e:	8d 50 04             	lea    0x4(%eax),%edx
f0101d31:	89 55 14             	mov    %edx,0x14(%ebp)
f0101d34:	8b 00                	mov    (%eax),%eax
f0101d36:	99                   	cltd   
f0101d37:	31 d0                	xor    %edx,%eax
f0101d39:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101d3b:	83 f8 07             	cmp    $0x7,%eax
f0101d3e:	7f 0b                	jg     f0101d4b <vprintfmt+0x12d>
f0101d40:	8b 14 85 60 32 10 f0 	mov    -0xfefcda0(,%eax,4),%edx
f0101d47:	85 d2                	test   %edx,%edx
f0101d49:	75 20                	jne    f0101d6b <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
f0101d4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101d4f:	c7 44 24 08 75 30 10 	movl   $0xf0103075,0x8(%esp)
f0101d56:	f0 
f0101d57:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101d5b:	8b 45 08             	mov    0x8(%ebp),%eax
f0101d5e:	89 04 24             	mov    %eax,(%esp)
f0101d61:	e8 90 fe ff ff       	call   f0101bf6 <printfmt>
f0101d66:	e9 d8 fe ff ff       	jmp    f0101c43 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f0101d6b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101d6f:	c7 44 24 08 94 2e 10 	movl   $0xf0102e94,0x8(%esp)
f0101d76:	f0 
f0101d77:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101d7b:	8b 45 08             	mov    0x8(%ebp),%eax
f0101d7e:	89 04 24             	mov    %eax,(%esp)
f0101d81:	e8 70 fe ff ff       	call   f0101bf6 <printfmt>
f0101d86:	e9 b8 fe ff ff       	jmp    f0101c43 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101d8b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101d8e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101d91:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101d94:	8b 45 14             	mov    0x14(%ebp),%eax
f0101d97:	8d 50 04             	lea    0x4(%eax),%edx
f0101d9a:	89 55 14             	mov    %edx,0x14(%ebp)
f0101d9d:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f0101d9f:	85 f6                	test   %esi,%esi
f0101da1:	b8 6e 30 10 f0       	mov    $0xf010306e,%eax
f0101da6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f0101da9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0101dad:	0f 84 97 00 00 00    	je     f0101e4a <vprintfmt+0x22c>
f0101db3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0101db7:	0f 8e 9b 00 00 00    	jle    f0101e58 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101dbd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101dc1:	89 34 24             	mov    %esi,(%esp)
f0101dc4:	e8 9f 03 00 00       	call   f0102168 <strnlen>
f0101dc9:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101dcc:	29 c2                	sub    %eax,%edx
f0101dce:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
f0101dd1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0101dd5:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101dd8:	89 75 d8             	mov    %esi,-0x28(%ebp)
f0101ddb:	8b 75 08             	mov    0x8(%ebp),%esi
f0101dde:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101de1:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101de3:	eb 0f                	jmp    f0101df4 <vprintfmt+0x1d6>
					putch(padc, putdat);
f0101de5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101de9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101dec:	89 04 24             	mov    %eax,(%esp)
f0101def:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101df1:	83 eb 01             	sub    $0x1,%ebx
f0101df4:	85 db                	test   %ebx,%ebx
f0101df6:	7f ed                	jg     f0101de5 <vprintfmt+0x1c7>
f0101df8:	8b 75 d8             	mov    -0x28(%ebp),%esi
f0101dfb:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101dfe:	85 d2                	test   %edx,%edx
f0101e00:	b8 00 00 00 00       	mov    $0x0,%eax
f0101e05:	0f 49 c2             	cmovns %edx,%eax
f0101e08:	29 c2                	sub    %eax,%edx
f0101e0a:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0101e0d:	89 d7                	mov    %edx,%edi
f0101e0f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e12:	eb 50                	jmp    f0101e64 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101e14:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101e18:	74 1e                	je     f0101e38 <vprintfmt+0x21a>
f0101e1a:	0f be d2             	movsbl %dl,%edx
f0101e1d:	83 ea 20             	sub    $0x20,%edx
f0101e20:	83 fa 5e             	cmp    $0x5e,%edx
f0101e23:	76 13                	jbe    f0101e38 <vprintfmt+0x21a>
					putch('?', putdat);
f0101e25:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101e28:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101e2c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0101e33:	ff 55 08             	call   *0x8(%ebp)
f0101e36:	eb 0d                	jmp    f0101e45 <vprintfmt+0x227>
				else
					putch(ch, putdat);
f0101e38:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101e3b:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101e3f:	89 04 24             	mov    %eax,(%esp)
f0101e42:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101e45:	83 ef 01             	sub    $0x1,%edi
f0101e48:	eb 1a                	jmp    f0101e64 <vprintfmt+0x246>
f0101e4a:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0101e4d:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0101e50:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101e53:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e56:	eb 0c                	jmp    f0101e64 <vprintfmt+0x246>
f0101e58:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0101e5b:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0101e5e:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101e61:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e64:	83 c6 01             	add    $0x1,%esi
f0101e67:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f0101e6b:	0f be c2             	movsbl %dl,%eax
f0101e6e:	85 c0                	test   %eax,%eax
f0101e70:	74 27                	je     f0101e99 <vprintfmt+0x27b>
f0101e72:	85 db                	test   %ebx,%ebx
f0101e74:	78 9e                	js     f0101e14 <vprintfmt+0x1f6>
f0101e76:	83 eb 01             	sub    $0x1,%ebx
f0101e79:	79 99                	jns    f0101e14 <vprintfmt+0x1f6>
f0101e7b:	89 f8                	mov    %edi,%eax
f0101e7d:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101e80:	8b 75 08             	mov    0x8(%ebp),%esi
f0101e83:	89 c3                	mov    %eax,%ebx
f0101e85:	eb 1a                	jmp    f0101ea1 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101e87:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101e8b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0101e92:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101e94:	83 eb 01             	sub    $0x1,%ebx
f0101e97:	eb 08                	jmp    f0101ea1 <vprintfmt+0x283>
f0101e99:	89 fb                	mov    %edi,%ebx
f0101e9b:	8b 75 08             	mov    0x8(%ebp),%esi
f0101e9e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101ea1:	85 db                	test   %ebx,%ebx
f0101ea3:	7f e2                	jg     f0101e87 <vprintfmt+0x269>
f0101ea5:	89 75 08             	mov    %esi,0x8(%ebp)
f0101ea8:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0101eab:	e9 93 fd ff ff       	jmp    f0101c43 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101eb0:	83 fa 01             	cmp    $0x1,%edx
f0101eb3:	7e 16                	jle    f0101ecb <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
f0101eb5:	8b 45 14             	mov    0x14(%ebp),%eax
f0101eb8:	8d 50 08             	lea    0x8(%eax),%edx
f0101ebb:	89 55 14             	mov    %edx,0x14(%ebp)
f0101ebe:	8b 50 04             	mov    0x4(%eax),%edx
f0101ec1:	8b 00                	mov    (%eax),%eax
f0101ec3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101ec6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101ec9:	eb 32                	jmp    f0101efd <vprintfmt+0x2df>
	else if (lflag)
f0101ecb:	85 d2                	test   %edx,%edx
f0101ecd:	74 18                	je     f0101ee7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
f0101ecf:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ed2:	8d 50 04             	lea    0x4(%eax),%edx
f0101ed5:	89 55 14             	mov    %edx,0x14(%ebp)
f0101ed8:	8b 30                	mov    (%eax),%esi
f0101eda:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0101edd:	89 f0                	mov    %esi,%eax
f0101edf:	c1 f8 1f             	sar    $0x1f,%eax
f0101ee2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101ee5:	eb 16                	jmp    f0101efd <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
f0101ee7:	8b 45 14             	mov    0x14(%ebp),%eax
f0101eea:	8d 50 04             	lea    0x4(%eax),%edx
f0101eed:	89 55 14             	mov    %edx,0x14(%ebp)
f0101ef0:	8b 30                	mov    (%eax),%esi
f0101ef2:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0101ef5:	89 f0                	mov    %esi,%eax
f0101ef7:	c1 f8 1f             	sar    $0x1f,%eax
f0101efa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101efd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101f00:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101f03:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101f08:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101f0c:	0f 89 80 00 00 00    	jns    f0101f92 <vprintfmt+0x374>
				putch('-', putdat);
f0101f12:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101f16:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101f1d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101f20:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101f23:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101f26:	f7 d8                	neg    %eax
f0101f28:	83 d2 00             	adc    $0x0,%edx
f0101f2b:	f7 da                	neg    %edx
			}
			base = 10;
f0101f2d:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0101f32:	eb 5e                	jmp    f0101f92 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101f34:	8d 45 14             	lea    0x14(%ebp),%eax
f0101f37:	e8 63 fc ff ff       	call   f0101b9f <getuint>
			base = 10;
f0101f3c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0101f41:	eb 4f                	jmp    f0101f92 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0101f43:	8d 45 14             	lea    0x14(%ebp),%eax
f0101f46:	e8 54 fc ff ff       	call   f0101b9f <getuint>
			base = 8;
f0101f4b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0101f50:	eb 40                	jmp    f0101f92 <vprintfmt+0x374>
			
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0101f52:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101f56:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0101f5d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0101f60:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101f64:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0101f6b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101f6e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101f71:	8d 50 04             	lea    0x4(%eax),%edx
f0101f74:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101f77:	8b 00                	mov    (%eax),%eax
f0101f79:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101f7e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0101f83:	eb 0d                	jmp    f0101f92 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101f85:	8d 45 14             	lea    0x14(%ebp),%eax
f0101f88:	e8 12 fc ff ff       	call   f0101b9f <getuint>
			base = 16;
f0101f8d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101f92:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f0101f96:	89 74 24 10          	mov    %esi,0x10(%esp)
f0101f9a:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0101f9d:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101fa1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101fa5:	89 04 24             	mov    %eax,(%esp)
f0101fa8:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101fac:	89 fa                	mov    %edi,%edx
f0101fae:	8b 45 08             	mov    0x8(%ebp),%eax
f0101fb1:	e8 fa fa ff ff       	call   f0101ab0 <printnum>
			break;
f0101fb6:	e9 88 fc ff ff       	jmp    f0101c43 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101fbb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101fbf:	89 04 24             	mov    %eax,(%esp)
f0101fc2:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101fc5:	e9 79 fc ff ff       	jmp    f0101c43 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101fca:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101fce:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0101fd5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101fd8:	89 f3                	mov    %esi,%ebx
f0101fda:	eb 03                	jmp    f0101fdf <vprintfmt+0x3c1>
f0101fdc:	83 eb 01             	sub    $0x1,%ebx
f0101fdf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0101fe3:	75 f7                	jne    f0101fdc <vprintfmt+0x3be>
f0101fe5:	e9 59 fc ff ff       	jmp    f0101c43 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f0101fea:	83 c4 3c             	add    $0x3c,%esp
f0101fed:	5b                   	pop    %ebx
f0101fee:	5e                   	pop    %esi
f0101fef:	5f                   	pop    %edi
f0101ff0:	5d                   	pop    %ebp
f0101ff1:	c3                   	ret    

f0101ff2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101ff2:	55                   	push   %ebp
f0101ff3:	89 e5                	mov    %esp,%ebp
f0101ff5:	83 ec 28             	sub    $0x28,%esp
f0101ff8:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ffb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101ffe:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102001:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0102005:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102008:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010200f:	85 c0                	test   %eax,%eax
f0102011:	74 30                	je     f0102043 <vsnprintf+0x51>
f0102013:	85 d2                	test   %edx,%edx
f0102015:	7e 2c                	jle    f0102043 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0102017:	8b 45 14             	mov    0x14(%ebp),%eax
f010201a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010201e:	8b 45 10             	mov    0x10(%ebp),%eax
f0102021:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102025:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0102028:	89 44 24 04          	mov    %eax,0x4(%esp)
f010202c:	c7 04 24 d9 1b 10 f0 	movl   $0xf0101bd9,(%esp)
f0102033:	e8 e6 fb ff ff       	call   f0101c1e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0102038:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010203b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010203e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102041:	eb 05                	jmp    f0102048 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0102043:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0102048:	c9                   	leave  
f0102049:	c3                   	ret    

f010204a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010204a:	55                   	push   %ebp
f010204b:	89 e5                	mov    %esp,%ebp
f010204d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0102050:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0102053:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102057:	8b 45 10             	mov    0x10(%ebp),%eax
f010205a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010205e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102061:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102065:	8b 45 08             	mov    0x8(%ebp),%eax
f0102068:	89 04 24             	mov    %eax,(%esp)
f010206b:	e8 82 ff ff ff       	call   f0101ff2 <vsnprintf>
	va_end(ap);

	return rc;
}
f0102070:	c9                   	leave  
f0102071:	c3                   	ret    
f0102072:	66 90                	xchg   %ax,%ax
f0102074:	66 90                	xchg   %ax,%ax
f0102076:	66 90                	xchg   %ax,%ax
f0102078:	66 90                	xchg   %ax,%ax
f010207a:	66 90                	xchg   %ax,%ax
f010207c:	66 90                	xchg   %ax,%ax
f010207e:	66 90                	xchg   %ax,%ax

f0102080 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0102080:	55                   	push   %ebp
f0102081:	89 e5                	mov    %esp,%ebp
f0102083:	57                   	push   %edi
f0102084:	56                   	push   %esi
f0102085:	53                   	push   %ebx
f0102086:	83 ec 1c             	sub    $0x1c,%esp
f0102089:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010208c:	85 c0                	test   %eax,%eax
f010208e:	74 10                	je     f01020a0 <readline+0x20>
		cprintf("%s", prompt);
f0102090:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102094:	c7 04 24 94 2e 10 f0 	movl   $0xf0102e94,(%esp)
f010209b:	e8 c9 f6 ff ff       	call   f0101769 <cprintf>

	i = 0;
	echoing = iscons(0);
f01020a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01020a7:	e8 66 e5 ff ff       	call   f0100612 <iscons>
f01020ac:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01020ae:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01020b3:	e8 49 e5 ff ff       	call   f0100601 <getchar>
f01020b8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01020ba:	85 c0                	test   %eax,%eax
f01020bc:	79 17                	jns    f01020d5 <readline+0x55>
			cprintf("read error: %e\n", c);
f01020be:	89 44 24 04          	mov    %eax,0x4(%esp)
f01020c2:	c7 04 24 80 32 10 f0 	movl   $0xf0103280,(%esp)
f01020c9:	e8 9b f6 ff ff       	call   f0101769 <cprintf>
			return NULL;
f01020ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01020d3:	eb 6d                	jmp    f0102142 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01020d5:	83 f8 7f             	cmp    $0x7f,%eax
f01020d8:	74 05                	je     f01020df <readline+0x5f>
f01020da:	83 f8 08             	cmp    $0x8,%eax
f01020dd:	75 19                	jne    f01020f8 <readline+0x78>
f01020df:	85 f6                	test   %esi,%esi
f01020e1:	7e 15                	jle    f01020f8 <readline+0x78>
			if (echoing)
f01020e3:	85 ff                	test   %edi,%edi
f01020e5:	74 0c                	je     f01020f3 <readline+0x73>
				cputchar('\b');
f01020e7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01020ee:	e8 fe e4 ff ff       	call   f01005f1 <cputchar>
			i--;
f01020f3:	83 ee 01             	sub    $0x1,%esi
f01020f6:	eb bb                	jmp    f01020b3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01020f8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01020fe:	7f 1c                	jg     f010211c <readline+0x9c>
f0102100:	83 fb 1f             	cmp    $0x1f,%ebx
f0102103:	7e 17                	jle    f010211c <readline+0x9c>
			if (echoing)
f0102105:	85 ff                	test   %edi,%edi
f0102107:	74 08                	je     f0102111 <readline+0x91>
				cputchar(c);
f0102109:	89 1c 24             	mov    %ebx,(%esp)
f010210c:	e8 e0 e4 ff ff       	call   f01005f1 <cputchar>
			buf[i++] = c;
f0102111:	88 9e 60 45 11 f0    	mov    %bl,-0xfeebaa0(%esi)
f0102117:	8d 76 01             	lea    0x1(%esi),%esi
f010211a:	eb 97                	jmp    f01020b3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010211c:	83 fb 0d             	cmp    $0xd,%ebx
f010211f:	74 05                	je     f0102126 <readline+0xa6>
f0102121:	83 fb 0a             	cmp    $0xa,%ebx
f0102124:	75 8d                	jne    f01020b3 <readline+0x33>
			if (echoing)
f0102126:	85 ff                	test   %edi,%edi
f0102128:	74 0c                	je     f0102136 <readline+0xb6>
				cputchar('\n');
f010212a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0102131:	e8 bb e4 ff ff       	call   f01005f1 <cputchar>
			buf[i] = 0;
f0102136:	c6 86 60 45 11 f0 00 	movb   $0x0,-0xfeebaa0(%esi)
			return buf;
f010213d:	b8 60 45 11 f0       	mov    $0xf0114560,%eax
		}
	}
}
f0102142:	83 c4 1c             	add    $0x1c,%esp
f0102145:	5b                   	pop    %ebx
f0102146:	5e                   	pop    %esi
f0102147:	5f                   	pop    %edi
f0102148:	5d                   	pop    %ebp
f0102149:	c3                   	ret    
f010214a:	66 90                	xchg   %ax,%ax
f010214c:	66 90                	xchg   %ax,%ax
f010214e:	66 90                	xchg   %ax,%ax

f0102150 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0102150:	55                   	push   %ebp
f0102151:	89 e5                	mov    %esp,%ebp
f0102153:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0102156:	b8 00 00 00 00       	mov    $0x0,%eax
f010215b:	eb 03                	jmp    f0102160 <strlen+0x10>
		n++;
f010215d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0102160:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0102164:	75 f7                	jne    f010215d <strlen+0xd>
		n++;
	return n;
}
f0102166:	5d                   	pop    %ebp
f0102167:	c3                   	ret    

f0102168 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0102168:	55                   	push   %ebp
f0102169:	89 e5                	mov    %esp,%ebp
f010216b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010216e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0102171:	b8 00 00 00 00       	mov    $0x0,%eax
f0102176:	eb 03                	jmp    f010217b <strnlen+0x13>
		n++;
f0102178:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010217b:	39 d0                	cmp    %edx,%eax
f010217d:	74 06                	je     f0102185 <strnlen+0x1d>
f010217f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0102183:	75 f3                	jne    f0102178 <strnlen+0x10>
		n++;
	return n;
}
f0102185:	5d                   	pop    %ebp
f0102186:	c3                   	ret    

f0102187 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0102187:	55                   	push   %ebp
f0102188:	89 e5                	mov    %esp,%ebp
f010218a:	53                   	push   %ebx
f010218b:	8b 45 08             	mov    0x8(%ebp),%eax
f010218e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0102191:	89 c2                	mov    %eax,%edx
f0102193:	83 c2 01             	add    $0x1,%edx
f0102196:	83 c1 01             	add    $0x1,%ecx
f0102199:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010219d:	88 5a ff             	mov    %bl,-0x1(%edx)
f01021a0:	84 db                	test   %bl,%bl
f01021a2:	75 ef                	jne    f0102193 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01021a4:	5b                   	pop    %ebx
f01021a5:	5d                   	pop    %ebp
f01021a6:	c3                   	ret    

f01021a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01021a7:	55                   	push   %ebp
f01021a8:	89 e5                	mov    %esp,%ebp
f01021aa:	53                   	push   %ebx
f01021ab:	83 ec 08             	sub    $0x8,%esp
f01021ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01021b1:	89 1c 24             	mov    %ebx,(%esp)
f01021b4:	e8 97 ff ff ff       	call   f0102150 <strlen>
	strcpy(dst + len, src);
f01021b9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01021bc:	89 54 24 04          	mov    %edx,0x4(%esp)
f01021c0:	01 d8                	add    %ebx,%eax
f01021c2:	89 04 24             	mov    %eax,(%esp)
f01021c5:	e8 bd ff ff ff       	call   f0102187 <strcpy>
	return dst;
}
f01021ca:	89 d8                	mov    %ebx,%eax
f01021cc:	83 c4 08             	add    $0x8,%esp
f01021cf:	5b                   	pop    %ebx
f01021d0:	5d                   	pop    %ebp
f01021d1:	c3                   	ret    

f01021d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01021d2:	55                   	push   %ebp
f01021d3:	89 e5                	mov    %esp,%ebp
f01021d5:	56                   	push   %esi
f01021d6:	53                   	push   %ebx
f01021d7:	8b 75 08             	mov    0x8(%ebp),%esi
f01021da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01021dd:	89 f3                	mov    %esi,%ebx
f01021df:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01021e2:	89 f2                	mov    %esi,%edx
f01021e4:	eb 0f                	jmp    f01021f5 <strncpy+0x23>
		*dst++ = *src;
f01021e6:	83 c2 01             	add    $0x1,%edx
f01021e9:	0f b6 01             	movzbl (%ecx),%eax
f01021ec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01021ef:	80 39 01             	cmpb   $0x1,(%ecx)
f01021f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01021f5:	39 da                	cmp    %ebx,%edx
f01021f7:	75 ed                	jne    f01021e6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01021f9:	89 f0                	mov    %esi,%eax
f01021fb:	5b                   	pop    %ebx
f01021fc:	5e                   	pop    %esi
f01021fd:	5d                   	pop    %ebp
f01021fe:	c3                   	ret    

f01021ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01021ff:	55                   	push   %ebp
f0102200:	89 e5                	mov    %esp,%ebp
f0102202:	56                   	push   %esi
f0102203:	53                   	push   %ebx
f0102204:	8b 75 08             	mov    0x8(%ebp),%esi
f0102207:	8b 55 0c             	mov    0xc(%ebp),%edx
f010220a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010220d:	89 f0                	mov    %esi,%eax
f010220f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0102213:	85 c9                	test   %ecx,%ecx
f0102215:	75 0b                	jne    f0102222 <strlcpy+0x23>
f0102217:	eb 1d                	jmp    f0102236 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0102219:	83 c0 01             	add    $0x1,%eax
f010221c:	83 c2 01             	add    $0x1,%edx
f010221f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0102222:	39 d8                	cmp    %ebx,%eax
f0102224:	74 0b                	je     f0102231 <strlcpy+0x32>
f0102226:	0f b6 0a             	movzbl (%edx),%ecx
f0102229:	84 c9                	test   %cl,%cl
f010222b:	75 ec                	jne    f0102219 <strlcpy+0x1a>
f010222d:	89 c2                	mov    %eax,%edx
f010222f:	eb 02                	jmp    f0102233 <strlcpy+0x34>
f0102231:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0102233:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0102236:	29 f0                	sub    %esi,%eax
}
f0102238:	5b                   	pop    %ebx
f0102239:	5e                   	pop    %esi
f010223a:	5d                   	pop    %ebp
f010223b:	c3                   	ret    

f010223c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010223c:	55                   	push   %ebp
f010223d:	89 e5                	mov    %esp,%ebp
f010223f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0102242:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0102245:	eb 06                	jmp    f010224d <strcmp+0x11>
		p++, q++;
f0102247:	83 c1 01             	add    $0x1,%ecx
f010224a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010224d:	0f b6 01             	movzbl (%ecx),%eax
f0102250:	84 c0                	test   %al,%al
f0102252:	74 04                	je     f0102258 <strcmp+0x1c>
f0102254:	3a 02                	cmp    (%edx),%al
f0102256:	74 ef                	je     f0102247 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0102258:	0f b6 c0             	movzbl %al,%eax
f010225b:	0f b6 12             	movzbl (%edx),%edx
f010225e:	29 d0                	sub    %edx,%eax
}
f0102260:	5d                   	pop    %ebp
f0102261:	c3                   	ret    

f0102262 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0102262:	55                   	push   %ebp
f0102263:	89 e5                	mov    %esp,%ebp
f0102265:	53                   	push   %ebx
f0102266:	8b 45 08             	mov    0x8(%ebp),%eax
f0102269:	8b 55 0c             	mov    0xc(%ebp),%edx
f010226c:	89 c3                	mov    %eax,%ebx
f010226e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0102271:	eb 06                	jmp    f0102279 <strncmp+0x17>
		n--, p++, q++;
f0102273:	83 c0 01             	add    $0x1,%eax
f0102276:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0102279:	39 d8                	cmp    %ebx,%eax
f010227b:	74 15                	je     f0102292 <strncmp+0x30>
f010227d:	0f b6 08             	movzbl (%eax),%ecx
f0102280:	84 c9                	test   %cl,%cl
f0102282:	74 04                	je     f0102288 <strncmp+0x26>
f0102284:	3a 0a                	cmp    (%edx),%cl
f0102286:	74 eb                	je     f0102273 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0102288:	0f b6 00             	movzbl (%eax),%eax
f010228b:	0f b6 12             	movzbl (%edx),%edx
f010228e:	29 d0                	sub    %edx,%eax
f0102290:	eb 05                	jmp    f0102297 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0102292:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0102297:	5b                   	pop    %ebx
f0102298:	5d                   	pop    %ebp
f0102299:	c3                   	ret    

f010229a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010229a:	55                   	push   %ebp
f010229b:	89 e5                	mov    %esp,%ebp
f010229d:	8b 45 08             	mov    0x8(%ebp),%eax
f01022a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01022a4:	eb 07                	jmp    f01022ad <strchr+0x13>
		if (*s == c)
f01022a6:	38 ca                	cmp    %cl,%dl
f01022a8:	74 0f                	je     f01022b9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01022aa:	83 c0 01             	add    $0x1,%eax
f01022ad:	0f b6 10             	movzbl (%eax),%edx
f01022b0:	84 d2                	test   %dl,%dl
f01022b2:	75 f2                	jne    f01022a6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01022b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01022b9:	5d                   	pop    %ebp
f01022ba:	c3                   	ret    

f01022bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01022bb:	55                   	push   %ebp
f01022bc:	89 e5                	mov    %esp,%ebp
f01022be:	8b 45 08             	mov    0x8(%ebp),%eax
f01022c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01022c5:	eb 07                	jmp    f01022ce <strfind+0x13>
		if (*s == c)
f01022c7:	38 ca                	cmp    %cl,%dl
f01022c9:	74 0a                	je     f01022d5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01022cb:	83 c0 01             	add    $0x1,%eax
f01022ce:	0f b6 10             	movzbl (%eax),%edx
f01022d1:	84 d2                	test   %dl,%dl
f01022d3:	75 f2                	jne    f01022c7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f01022d5:	5d                   	pop    %ebp
f01022d6:	c3                   	ret    

f01022d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01022d7:	55                   	push   %ebp
f01022d8:	89 e5                	mov    %esp,%ebp
f01022da:	57                   	push   %edi
f01022db:	56                   	push   %esi
f01022dc:	53                   	push   %ebx
f01022dd:	8b 7d 08             	mov    0x8(%ebp),%edi
f01022e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01022e3:	85 c9                	test   %ecx,%ecx
f01022e5:	74 36                	je     f010231d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01022e7:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01022ed:	75 28                	jne    f0102317 <memset+0x40>
f01022ef:	f6 c1 03             	test   $0x3,%cl
f01022f2:	75 23                	jne    f0102317 <memset+0x40>
		c &= 0xFF;
f01022f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01022f8:	89 d3                	mov    %edx,%ebx
f01022fa:	c1 e3 08             	shl    $0x8,%ebx
f01022fd:	89 d6                	mov    %edx,%esi
f01022ff:	c1 e6 18             	shl    $0x18,%esi
f0102302:	89 d0                	mov    %edx,%eax
f0102304:	c1 e0 10             	shl    $0x10,%eax
f0102307:	09 f0                	or     %esi,%eax
f0102309:	09 c2                	or     %eax,%edx
f010230b:	89 d0                	mov    %edx,%eax
f010230d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010230f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0102312:	fc                   	cld    
f0102313:	f3 ab                	rep stos %eax,%es:(%edi)
f0102315:	eb 06                	jmp    f010231d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0102317:	8b 45 0c             	mov    0xc(%ebp),%eax
f010231a:	fc                   	cld    
f010231b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010231d:	89 f8                	mov    %edi,%eax
f010231f:	5b                   	pop    %ebx
f0102320:	5e                   	pop    %esi
f0102321:	5f                   	pop    %edi
f0102322:	5d                   	pop    %ebp
f0102323:	c3                   	ret    

f0102324 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0102324:	55                   	push   %ebp
f0102325:	89 e5                	mov    %esp,%ebp
f0102327:	57                   	push   %edi
f0102328:	56                   	push   %esi
f0102329:	8b 45 08             	mov    0x8(%ebp),%eax
f010232c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010232f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0102332:	39 c6                	cmp    %eax,%esi
f0102334:	73 35                	jae    f010236b <memmove+0x47>
f0102336:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0102339:	39 d0                	cmp    %edx,%eax
f010233b:	73 2e                	jae    f010236b <memmove+0x47>
		s += n;
		d += n;
f010233d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0102340:	89 d6                	mov    %edx,%esi
f0102342:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0102344:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010234a:	75 13                	jne    f010235f <memmove+0x3b>
f010234c:	f6 c1 03             	test   $0x3,%cl
f010234f:	75 0e                	jne    f010235f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0102351:	83 ef 04             	sub    $0x4,%edi
f0102354:	8d 72 fc             	lea    -0x4(%edx),%esi
f0102357:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010235a:	fd                   	std    
f010235b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010235d:	eb 09                	jmp    f0102368 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010235f:	83 ef 01             	sub    $0x1,%edi
f0102362:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0102365:	fd                   	std    
f0102366:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0102368:	fc                   	cld    
f0102369:	eb 1d                	jmp    f0102388 <memmove+0x64>
f010236b:	89 f2                	mov    %esi,%edx
f010236d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010236f:	f6 c2 03             	test   $0x3,%dl
f0102372:	75 0f                	jne    f0102383 <memmove+0x5f>
f0102374:	f6 c1 03             	test   $0x3,%cl
f0102377:	75 0a                	jne    f0102383 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0102379:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f010237c:	89 c7                	mov    %eax,%edi
f010237e:	fc                   	cld    
f010237f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0102381:	eb 05                	jmp    f0102388 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0102383:	89 c7                	mov    %eax,%edi
f0102385:	fc                   	cld    
f0102386:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0102388:	5e                   	pop    %esi
f0102389:	5f                   	pop    %edi
f010238a:	5d                   	pop    %ebp
f010238b:	c3                   	ret    

f010238c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010238c:	55                   	push   %ebp
f010238d:	89 e5                	mov    %esp,%ebp
f010238f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0102392:	8b 45 10             	mov    0x10(%ebp),%eax
f0102395:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102399:	8b 45 0c             	mov    0xc(%ebp),%eax
f010239c:	89 44 24 04          	mov    %eax,0x4(%esp)
f01023a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01023a3:	89 04 24             	mov    %eax,(%esp)
f01023a6:	e8 79 ff ff ff       	call   f0102324 <memmove>
}
f01023ab:	c9                   	leave  
f01023ac:	c3                   	ret    

f01023ad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01023ad:	55                   	push   %ebp
f01023ae:	89 e5                	mov    %esp,%ebp
f01023b0:	56                   	push   %esi
f01023b1:	53                   	push   %ebx
f01023b2:	8b 55 08             	mov    0x8(%ebp),%edx
f01023b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01023b8:	89 d6                	mov    %edx,%esi
f01023ba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01023bd:	eb 1a                	jmp    f01023d9 <memcmp+0x2c>
		if (*s1 != *s2)
f01023bf:	0f b6 02             	movzbl (%edx),%eax
f01023c2:	0f b6 19             	movzbl (%ecx),%ebx
f01023c5:	38 d8                	cmp    %bl,%al
f01023c7:	74 0a                	je     f01023d3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01023c9:	0f b6 c0             	movzbl %al,%eax
f01023cc:	0f b6 db             	movzbl %bl,%ebx
f01023cf:	29 d8                	sub    %ebx,%eax
f01023d1:	eb 0f                	jmp    f01023e2 <memcmp+0x35>
		s1++, s2++;
f01023d3:	83 c2 01             	add    $0x1,%edx
f01023d6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01023d9:	39 f2                	cmp    %esi,%edx
f01023db:	75 e2                	jne    f01023bf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01023dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01023e2:	5b                   	pop    %ebx
f01023e3:	5e                   	pop    %esi
f01023e4:	5d                   	pop    %ebp
f01023e5:	c3                   	ret    

f01023e6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01023e6:	55                   	push   %ebp
f01023e7:	89 e5                	mov    %esp,%ebp
f01023e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01023ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01023ef:	89 c2                	mov    %eax,%edx
f01023f1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01023f4:	eb 07                	jmp    f01023fd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f01023f6:	38 08                	cmp    %cl,(%eax)
f01023f8:	74 07                	je     f0102401 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01023fa:	83 c0 01             	add    $0x1,%eax
f01023fd:	39 d0                	cmp    %edx,%eax
f01023ff:	72 f5                	jb     f01023f6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0102401:	5d                   	pop    %ebp
f0102402:	c3                   	ret    

f0102403 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0102403:	55                   	push   %ebp
f0102404:	89 e5                	mov    %esp,%ebp
f0102406:	57                   	push   %edi
f0102407:	56                   	push   %esi
f0102408:	53                   	push   %ebx
f0102409:	8b 55 08             	mov    0x8(%ebp),%edx
f010240c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010240f:	eb 03                	jmp    f0102414 <strtol+0x11>
		s++;
f0102411:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0102414:	0f b6 0a             	movzbl (%edx),%ecx
f0102417:	80 f9 09             	cmp    $0x9,%cl
f010241a:	74 f5                	je     f0102411 <strtol+0xe>
f010241c:	80 f9 20             	cmp    $0x20,%cl
f010241f:	74 f0                	je     f0102411 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0102421:	80 f9 2b             	cmp    $0x2b,%cl
f0102424:	75 0a                	jne    f0102430 <strtol+0x2d>
		s++;
f0102426:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0102429:	bf 00 00 00 00       	mov    $0x0,%edi
f010242e:	eb 11                	jmp    f0102441 <strtol+0x3e>
f0102430:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0102435:	80 f9 2d             	cmp    $0x2d,%cl
f0102438:	75 07                	jne    f0102441 <strtol+0x3e>
		s++, neg = 1;
f010243a:	8d 52 01             	lea    0x1(%edx),%edx
f010243d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0102441:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0102446:	75 15                	jne    f010245d <strtol+0x5a>
f0102448:	80 3a 30             	cmpb   $0x30,(%edx)
f010244b:	75 10                	jne    f010245d <strtol+0x5a>
f010244d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0102451:	75 0a                	jne    f010245d <strtol+0x5a>
		s += 2, base = 16;
f0102453:	83 c2 02             	add    $0x2,%edx
f0102456:	b8 10 00 00 00       	mov    $0x10,%eax
f010245b:	eb 10                	jmp    f010246d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f010245d:	85 c0                	test   %eax,%eax
f010245f:	75 0c                	jne    f010246d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0102461:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0102463:	80 3a 30             	cmpb   $0x30,(%edx)
f0102466:	75 05                	jne    f010246d <strtol+0x6a>
		s++, base = 8;
f0102468:	83 c2 01             	add    $0x1,%edx
f010246b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f010246d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102472:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0102475:	0f b6 0a             	movzbl (%edx),%ecx
f0102478:	8d 71 d0             	lea    -0x30(%ecx),%esi
f010247b:	89 f0                	mov    %esi,%eax
f010247d:	3c 09                	cmp    $0x9,%al
f010247f:	77 08                	ja     f0102489 <strtol+0x86>
			dig = *s - '0';
f0102481:	0f be c9             	movsbl %cl,%ecx
f0102484:	83 e9 30             	sub    $0x30,%ecx
f0102487:	eb 20                	jmp    f01024a9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0102489:	8d 71 9f             	lea    -0x61(%ecx),%esi
f010248c:	89 f0                	mov    %esi,%eax
f010248e:	3c 19                	cmp    $0x19,%al
f0102490:	77 08                	ja     f010249a <strtol+0x97>
			dig = *s - 'a' + 10;
f0102492:	0f be c9             	movsbl %cl,%ecx
f0102495:	83 e9 57             	sub    $0x57,%ecx
f0102498:	eb 0f                	jmp    f01024a9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f010249a:	8d 71 bf             	lea    -0x41(%ecx),%esi
f010249d:	89 f0                	mov    %esi,%eax
f010249f:	3c 19                	cmp    $0x19,%al
f01024a1:	77 16                	ja     f01024b9 <strtol+0xb6>
			dig = *s - 'A' + 10;
f01024a3:	0f be c9             	movsbl %cl,%ecx
f01024a6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01024a9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f01024ac:	7d 0f                	jge    f01024bd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f01024ae:	83 c2 01             	add    $0x1,%edx
f01024b1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f01024b5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f01024b7:	eb bc                	jmp    f0102475 <strtol+0x72>
f01024b9:	89 d8                	mov    %ebx,%eax
f01024bb:	eb 02                	jmp    f01024bf <strtol+0xbc>
f01024bd:	89 d8                	mov    %ebx,%eax

	if (endptr)
f01024bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01024c3:	74 05                	je     f01024ca <strtol+0xc7>
		*endptr = (char *) s;
f01024c5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01024c8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f01024ca:	f7 d8                	neg    %eax
f01024cc:	85 ff                	test   %edi,%edi
f01024ce:	0f 44 c3             	cmove  %ebx,%eax
}
f01024d1:	5b                   	pop    %ebx
f01024d2:	5e                   	pop    %esi
f01024d3:	5f                   	pop    %edi
f01024d4:	5d                   	pop    %ebp
f01024d5:	c3                   	ret    
f01024d6:	66 90                	xchg   %ax,%ax
f01024d8:	66 90                	xchg   %ax,%ax
f01024da:	66 90                	xchg   %ax,%ax
f01024dc:	66 90                	xchg   %ax,%ax
f01024de:	66 90                	xchg   %ax,%ax

f01024e0 <__udivdi3>:
f01024e0:	55                   	push   %ebp
f01024e1:	57                   	push   %edi
f01024e2:	56                   	push   %esi
f01024e3:	83 ec 0c             	sub    $0xc,%esp
f01024e6:	8b 44 24 28          	mov    0x28(%esp),%eax
f01024ea:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f01024ee:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f01024f2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f01024f6:	85 c0                	test   %eax,%eax
f01024f8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01024fc:	89 ea                	mov    %ebp,%edx
f01024fe:	89 0c 24             	mov    %ecx,(%esp)
f0102501:	75 2d                	jne    f0102530 <__udivdi3+0x50>
f0102503:	39 e9                	cmp    %ebp,%ecx
f0102505:	77 61                	ja     f0102568 <__udivdi3+0x88>
f0102507:	85 c9                	test   %ecx,%ecx
f0102509:	89 ce                	mov    %ecx,%esi
f010250b:	75 0b                	jne    f0102518 <__udivdi3+0x38>
f010250d:	b8 01 00 00 00       	mov    $0x1,%eax
f0102512:	31 d2                	xor    %edx,%edx
f0102514:	f7 f1                	div    %ecx
f0102516:	89 c6                	mov    %eax,%esi
f0102518:	31 d2                	xor    %edx,%edx
f010251a:	89 e8                	mov    %ebp,%eax
f010251c:	f7 f6                	div    %esi
f010251e:	89 c5                	mov    %eax,%ebp
f0102520:	89 f8                	mov    %edi,%eax
f0102522:	f7 f6                	div    %esi
f0102524:	89 ea                	mov    %ebp,%edx
f0102526:	83 c4 0c             	add    $0xc,%esp
f0102529:	5e                   	pop    %esi
f010252a:	5f                   	pop    %edi
f010252b:	5d                   	pop    %ebp
f010252c:	c3                   	ret    
f010252d:	8d 76 00             	lea    0x0(%esi),%esi
f0102530:	39 e8                	cmp    %ebp,%eax
f0102532:	77 24                	ja     f0102558 <__udivdi3+0x78>
f0102534:	0f bd e8             	bsr    %eax,%ebp
f0102537:	83 f5 1f             	xor    $0x1f,%ebp
f010253a:	75 3c                	jne    f0102578 <__udivdi3+0x98>
f010253c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0102540:	39 34 24             	cmp    %esi,(%esp)
f0102543:	0f 86 9f 00 00 00    	jbe    f01025e8 <__udivdi3+0x108>
f0102549:	39 d0                	cmp    %edx,%eax
f010254b:	0f 82 97 00 00 00    	jb     f01025e8 <__udivdi3+0x108>
f0102551:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0102558:	31 d2                	xor    %edx,%edx
f010255a:	31 c0                	xor    %eax,%eax
f010255c:	83 c4 0c             	add    $0xc,%esp
f010255f:	5e                   	pop    %esi
f0102560:	5f                   	pop    %edi
f0102561:	5d                   	pop    %ebp
f0102562:	c3                   	ret    
f0102563:	90                   	nop
f0102564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102568:	89 f8                	mov    %edi,%eax
f010256a:	f7 f1                	div    %ecx
f010256c:	31 d2                	xor    %edx,%edx
f010256e:	83 c4 0c             	add    $0xc,%esp
f0102571:	5e                   	pop    %esi
f0102572:	5f                   	pop    %edi
f0102573:	5d                   	pop    %ebp
f0102574:	c3                   	ret    
f0102575:	8d 76 00             	lea    0x0(%esi),%esi
f0102578:	89 e9                	mov    %ebp,%ecx
f010257a:	8b 3c 24             	mov    (%esp),%edi
f010257d:	d3 e0                	shl    %cl,%eax
f010257f:	89 c6                	mov    %eax,%esi
f0102581:	b8 20 00 00 00       	mov    $0x20,%eax
f0102586:	29 e8                	sub    %ebp,%eax
f0102588:	89 c1                	mov    %eax,%ecx
f010258a:	d3 ef                	shr    %cl,%edi
f010258c:	89 e9                	mov    %ebp,%ecx
f010258e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0102592:	8b 3c 24             	mov    (%esp),%edi
f0102595:	09 74 24 08          	or     %esi,0x8(%esp)
f0102599:	89 d6                	mov    %edx,%esi
f010259b:	d3 e7                	shl    %cl,%edi
f010259d:	89 c1                	mov    %eax,%ecx
f010259f:	89 3c 24             	mov    %edi,(%esp)
f01025a2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01025a6:	d3 ee                	shr    %cl,%esi
f01025a8:	89 e9                	mov    %ebp,%ecx
f01025aa:	d3 e2                	shl    %cl,%edx
f01025ac:	89 c1                	mov    %eax,%ecx
f01025ae:	d3 ef                	shr    %cl,%edi
f01025b0:	09 d7                	or     %edx,%edi
f01025b2:	89 f2                	mov    %esi,%edx
f01025b4:	89 f8                	mov    %edi,%eax
f01025b6:	f7 74 24 08          	divl   0x8(%esp)
f01025ba:	89 d6                	mov    %edx,%esi
f01025bc:	89 c7                	mov    %eax,%edi
f01025be:	f7 24 24             	mull   (%esp)
f01025c1:	39 d6                	cmp    %edx,%esi
f01025c3:	89 14 24             	mov    %edx,(%esp)
f01025c6:	72 30                	jb     f01025f8 <__udivdi3+0x118>
f01025c8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01025cc:	89 e9                	mov    %ebp,%ecx
f01025ce:	d3 e2                	shl    %cl,%edx
f01025d0:	39 c2                	cmp    %eax,%edx
f01025d2:	73 05                	jae    f01025d9 <__udivdi3+0xf9>
f01025d4:	3b 34 24             	cmp    (%esp),%esi
f01025d7:	74 1f                	je     f01025f8 <__udivdi3+0x118>
f01025d9:	89 f8                	mov    %edi,%eax
f01025db:	31 d2                	xor    %edx,%edx
f01025dd:	e9 7a ff ff ff       	jmp    f010255c <__udivdi3+0x7c>
f01025e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01025e8:	31 d2                	xor    %edx,%edx
f01025ea:	b8 01 00 00 00       	mov    $0x1,%eax
f01025ef:	e9 68 ff ff ff       	jmp    f010255c <__udivdi3+0x7c>
f01025f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01025f8:	8d 47 ff             	lea    -0x1(%edi),%eax
f01025fb:	31 d2                	xor    %edx,%edx
f01025fd:	83 c4 0c             	add    $0xc,%esp
f0102600:	5e                   	pop    %esi
f0102601:	5f                   	pop    %edi
f0102602:	5d                   	pop    %ebp
f0102603:	c3                   	ret    
f0102604:	66 90                	xchg   %ax,%ax
f0102606:	66 90                	xchg   %ax,%ax
f0102608:	66 90                	xchg   %ax,%ax
f010260a:	66 90                	xchg   %ax,%ax
f010260c:	66 90                	xchg   %ax,%ax
f010260e:	66 90                	xchg   %ax,%ax

f0102610 <__umoddi3>:
f0102610:	55                   	push   %ebp
f0102611:	57                   	push   %edi
f0102612:	56                   	push   %esi
f0102613:	83 ec 14             	sub    $0x14,%esp
f0102616:	8b 44 24 28          	mov    0x28(%esp),%eax
f010261a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f010261e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0102622:	89 c7                	mov    %eax,%edi
f0102624:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102628:	8b 44 24 30          	mov    0x30(%esp),%eax
f010262c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0102630:	89 34 24             	mov    %esi,(%esp)
f0102633:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0102637:	85 c0                	test   %eax,%eax
f0102639:	89 c2                	mov    %eax,%edx
f010263b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010263f:	75 17                	jne    f0102658 <__umoddi3+0x48>
f0102641:	39 fe                	cmp    %edi,%esi
f0102643:	76 4b                	jbe    f0102690 <__umoddi3+0x80>
f0102645:	89 c8                	mov    %ecx,%eax
f0102647:	89 fa                	mov    %edi,%edx
f0102649:	f7 f6                	div    %esi
f010264b:	89 d0                	mov    %edx,%eax
f010264d:	31 d2                	xor    %edx,%edx
f010264f:	83 c4 14             	add    $0x14,%esp
f0102652:	5e                   	pop    %esi
f0102653:	5f                   	pop    %edi
f0102654:	5d                   	pop    %ebp
f0102655:	c3                   	ret    
f0102656:	66 90                	xchg   %ax,%ax
f0102658:	39 f8                	cmp    %edi,%eax
f010265a:	77 54                	ja     f01026b0 <__umoddi3+0xa0>
f010265c:	0f bd e8             	bsr    %eax,%ebp
f010265f:	83 f5 1f             	xor    $0x1f,%ebp
f0102662:	75 5c                	jne    f01026c0 <__umoddi3+0xb0>
f0102664:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0102668:	39 3c 24             	cmp    %edi,(%esp)
f010266b:	0f 87 e7 00 00 00    	ja     f0102758 <__umoddi3+0x148>
f0102671:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0102675:	29 f1                	sub    %esi,%ecx
f0102677:	19 c7                	sbb    %eax,%edi
f0102679:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010267d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102681:	8b 44 24 08          	mov    0x8(%esp),%eax
f0102685:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0102689:	83 c4 14             	add    $0x14,%esp
f010268c:	5e                   	pop    %esi
f010268d:	5f                   	pop    %edi
f010268e:	5d                   	pop    %ebp
f010268f:	c3                   	ret    
f0102690:	85 f6                	test   %esi,%esi
f0102692:	89 f5                	mov    %esi,%ebp
f0102694:	75 0b                	jne    f01026a1 <__umoddi3+0x91>
f0102696:	b8 01 00 00 00       	mov    $0x1,%eax
f010269b:	31 d2                	xor    %edx,%edx
f010269d:	f7 f6                	div    %esi
f010269f:	89 c5                	mov    %eax,%ebp
f01026a1:	8b 44 24 04          	mov    0x4(%esp),%eax
f01026a5:	31 d2                	xor    %edx,%edx
f01026a7:	f7 f5                	div    %ebp
f01026a9:	89 c8                	mov    %ecx,%eax
f01026ab:	f7 f5                	div    %ebp
f01026ad:	eb 9c                	jmp    f010264b <__umoddi3+0x3b>
f01026af:	90                   	nop
f01026b0:	89 c8                	mov    %ecx,%eax
f01026b2:	89 fa                	mov    %edi,%edx
f01026b4:	83 c4 14             	add    $0x14,%esp
f01026b7:	5e                   	pop    %esi
f01026b8:	5f                   	pop    %edi
f01026b9:	5d                   	pop    %ebp
f01026ba:	c3                   	ret    
f01026bb:	90                   	nop
f01026bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01026c0:	8b 04 24             	mov    (%esp),%eax
f01026c3:	be 20 00 00 00       	mov    $0x20,%esi
f01026c8:	89 e9                	mov    %ebp,%ecx
f01026ca:	29 ee                	sub    %ebp,%esi
f01026cc:	d3 e2                	shl    %cl,%edx
f01026ce:	89 f1                	mov    %esi,%ecx
f01026d0:	d3 e8                	shr    %cl,%eax
f01026d2:	89 e9                	mov    %ebp,%ecx
f01026d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01026d8:	8b 04 24             	mov    (%esp),%eax
f01026db:	09 54 24 04          	or     %edx,0x4(%esp)
f01026df:	89 fa                	mov    %edi,%edx
f01026e1:	d3 e0                	shl    %cl,%eax
f01026e3:	89 f1                	mov    %esi,%ecx
f01026e5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01026e9:	8b 44 24 10          	mov    0x10(%esp),%eax
f01026ed:	d3 ea                	shr    %cl,%edx
f01026ef:	89 e9                	mov    %ebp,%ecx
f01026f1:	d3 e7                	shl    %cl,%edi
f01026f3:	89 f1                	mov    %esi,%ecx
f01026f5:	d3 e8                	shr    %cl,%eax
f01026f7:	89 e9                	mov    %ebp,%ecx
f01026f9:	09 f8                	or     %edi,%eax
f01026fb:	8b 7c 24 10          	mov    0x10(%esp),%edi
f01026ff:	f7 74 24 04          	divl   0x4(%esp)
f0102703:	d3 e7                	shl    %cl,%edi
f0102705:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102709:	89 d7                	mov    %edx,%edi
f010270b:	f7 64 24 08          	mull   0x8(%esp)
f010270f:	39 d7                	cmp    %edx,%edi
f0102711:	89 c1                	mov    %eax,%ecx
f0102713:	89 14 24             	mov    %edx,(%esp)
f0102716:	72 2c                	jb     f0102744 <__umoddi3+0x134>
f0102718:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f010271c:	72 22                	jb     f0102740 <__umoddi3+0x130>
f010271e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0102722:	29 c8                	sub    %ecx,%eax
f0102724:	19 d7                	sbb    %edx,%edi
f0102726:	89 e9                	mov    %ebp,%ecx
f0102728:	89 fa                	mov    %edi,%edx
f010272a:	d3 e8                	shr    %cl,%eax
f010272c:	89 f1                	mov    %esi,%ecx
f010272e:	d3 e2                	shl    %cl,%edx
f0102730:	89 e9                	mov    %ebp,%ecx
f0102732:	d3 ef                	shr    %cl,%edi
f0102734:	09 d0                	or     %edx,%eax
f0102736:	89 fa                	mov    %edi,%edx
f0102738:	83 c4 14             	add    $0x14,%esp
f010273b:	5e                   	pop    %esi
f010273c:	5f                   	pop    %edi
f010273d:	5d                   	pop    %ebp
f010273e:	c3                   	ret    
f010273f:	90                   	nop
f0102740:	39 d7                	cmp    %edx,%edi
f0102742:	75 da                	jne    f010271e <__umoddi3+0x10e>
f0102744:	8b 14 24             	mov    (%esp),%edx
f0102747:	89 c1                	mov    %eax,%ecx
f0102749:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f010274d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f0102751:	eb cb                	jmp    f010271e <__umoddi3+0x10e>
f0102753:	90                   	nop
f0102754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102758:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f010275c:	0f 82 0f ff ff ff    	jb     f0102671 <__umoddi3+0x61>
f0102762:	e9 1a ff ff ff       	jmp    f0102681 <__umoddi3+0x71>
