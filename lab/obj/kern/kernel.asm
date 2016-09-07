
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
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 40 18 10 f0       	push   $0xf0101840
f0100050:	e8 81 08 00 00       	call   f01008d6 <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 d3 06 00 00       	call   f010074e <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 5c 18 10 f0       	push   $0xf010185c
f0100087:	e8 4a 08 00 00       	call   f01008d6 <cprintf>
f010008c:	83 c4 10             	add    $0x10,%esp
}
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 84 29 11 f0       	mov    $0xf0112984,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 a3 12 00 00       	call   f0101354 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 8c 04 00 00       	call   f0100542 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 77 18 10 f0       	push   $0xf0101877
f01000c3:	e8 0e 08 00 00       	call   f01008d6 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>
f01000d4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d7:	83 ec 0c             	sub    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	e8 77 06 00 00       	call   f0100758 <monitor>
f01000e1:	83 c4 10             	add    $0x10,%esp
f01000e4:	eb f1                	jmp    f01000d7 <i386_init+0x43>

f01000e6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e6:	55                   	push   %ebp
f01000e7:	89 e5                	mov    %esp,%ebp
f01000e9:	56                   	push   %esi
f01000ea:	53                   	push   %ebx
f01000eb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ee:	83 3d 80 29 11 f0 00 	cmpl   $0x0,0xf0112980
f01000f5:	75 37                	jne    f010012e <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000f7:	89 35 80 29 11 f0    	mov    %esi,0xf0112980

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000fd:	fa                   	cli    
f01000fe:	fc                   	cld    

	va_start(ap, fmt);
f01000ff:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100102:	83 ec 04             	sub    $0x4,%esp
f0100105:	ff 75 0c             	pushl  0xc(%ebp)
f0100108:	ff 75 08             	pushl  0x8(%ebp)
f010010b:	68 92 18 10 f0       	push   $0xf0101892
f0100110:	e8 c1 07 00 00       	call   f01008d6 <cprintf>
	vcprintf(fmt, ap);
f0100115:	83 c4 08             	add    $0x8,%esp
f0100118:	53                   	push   %ebx
f0100119:	56                   	push   %esi
f010011a:	e8 91 07 00 00       	call   f01008b0 <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 ce 18 10 f0 	movl   $0xf01018ce,(%esp)
f0100126:	e8 ab 07 00 00       	call   f01008d6 <cprintf>
	va_end(ap);
f010012b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	83 ec 0c             	sub    $0xc,%esp
f0100131:	6a 00                	push   $0x0
f0100133:	e8 20 06 00 00       	call   f0100758 <monitor>
f0100138:	83 c4 10             	add    $0x10,%esp
f010013b:	eb f1                	jmp    f010012e <_panic+0x48>

f010013d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013d:	55                   	push   %ebp
f010013e:	89 e5                	mov    %esp,%ebp
f0100140:	53                   	push   %ebx
f0100141:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100144:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100147:	ff 75 0c             	pushl  0xc(%ebp)
f010014a:	ff 75 08             	pushl  0x8(%ebp)
f010014d:	68 aa 18 10 f0       	push   $0xf01018aa
f0100152:	e8 7f 07 00 00       	call   f01008d6 <cprintf>
	vcprintf(fmt, ap);
f0100157:	83 c4 08             	add    $0x8,%esp
f010015a:	53                   	push   %ebx
f010015b:	ff 75 10             	pushl  0x10(%ebp)
f010015e:	e8 4d 07 00 00       	call   f01008b0 <vcprintf>
	cprintf("\n");
f0100163:	c7 04 24 ce 18 10 f0 	movl   $0xf01018ce,(%esp)
f010016a:	e8 67 07 00 00       	call   f01008d6 <cprintf>
	va_end(ap);
f010016f:	83 c4 10             	add    $0x10,%esp
}
f0100172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100175:	c9                   	leave  
f0100176:	c3                   	ret    

f0100177 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100177:	55                   	push   %ebp
f0100178:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010017f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100180:	a8 01                	test   $0x1,%al
f0100182:	74 08                	je     f010018c <serial_proc_data+0x15>
f0100184:	b2 f8                	mov    $0xf8,%dl
f0100186:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100187:	0f b6 c0             	movzbl %al,%eax
f010018a:	eb 05                	jmp    f0100191 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010018c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100191:	5d                   	pop    %ebp
f0100192:	c3                   	ret    

f0100193 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100193:	55                   	push   %ebp
f0100194:	89 e5                	mov    %esp,%ebp
f0100196:	53                   	push   %ebx
f0100197:	83 ec 04             	sub    $0x4,%esp
f010019a:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010019c:	eb 2a                	jmp    f01001c8 <cons_intr+0x35>
		if (c == 0)
f010019e:	85 d2                	test   %edx,%edx
f01001a0:	74 26                	je     f01001c8 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a2:	a1 44 25 11 f0       	mov    0xf0112544,%eax
f01001a7:	8d 48 01             	lea    0x1(%eax),%ecx
f01001aa:	89 0d 44 25 11 f0    	mov    %ecx,0xf0112544
f01001b0:	88 90 40 23 11 f0    	mov    %dl,-0xfeedcc0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01001b6:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01001bc:	75 0a                	jne    f01001c8 <cons_intr+0x35>
			cons.wpos = 0;
f01001be:	c7 05 44 25 11 f0 00 	movl   $0x0,0xf0112544
f01001c5:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001c8:	ff d3                	call   *%ebx
f01001ca:	89 c2                	mov    %eax,%edx
f01001cc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001cf:	75 cd                	jne    f010019e <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001d1:	83 c4 04             	add    $0x4,%esp
f01001d4:	5b                   	pop    %ebx
f01001d5:	5d                   	pop    %ebp
f01001d6:	c3                   	ret    

f01001d7 <kbd_proc_data>:
f01001d7:	ba 64 00 00 00       	mov    $0x64,%edx
f01001dc:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001dd:	a8 01                	test   $0x1,%al
f01001df:	0f 84 f0 00 00 00    	je     f01002d5 <kbd_proc_data+0xfe>
f01001e5:	b2 60                	mov    $0x60,%dl
f01001e7:	ec                   	in     (%dx),%al
f01001e8:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001ea:	3c e0                	cmp    $0xe0,%al
f01001ec:	75 0d                	jne    f01001fb <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f01001ee:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f01001f5:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001fa:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001fb:	55                   	push   %ebp
f01001fc:	89 e5                	mov    %esp,%ebp
f01001fe:	53                   	push   %ebx
f01001ff:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100202:	84 c0                	test   %al,%al
f0100204:	79 36                	jns    f010023c <kbd_proc_data+0x65>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100206:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010020c:	89 cb                	mov    %ecx,%ebx
f010020e:	83 e3 40             	and    $0x40,%ebx
f0100211:	83 e0 7f             	and    $0x7f,%eax
f0100214:	85 db                	test   %ebx,%ebx
f0100216:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100219:	0f b6 d2             	movzbl %dl,%edx
f010021c:	0f b6 82 40 1a 10 f0 	movzbl -0xfefe5c0(%edx),%eax
f0100223:	83 c8 40             	or     $0x40,%eax
f0100226:	0f b6 c0             	movzbl %al,%eax
f0100229:	f7 d0                	not    %eax
f010022b:	21 c8                	and    %ecx,%eax
f010022d:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f0100232:	b8 00 00 00 00       	mov    $0x0,%eax
f0100237:	e9 a1 00 00 00       	jmp    f01002dd <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f010023c:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100242:	f6 c1 40             	test   $0x40,%cl
f0100245:	74 0e                	je     f0100255 <kbd_proc_data+0x7e>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100247:	83 c8 80             	or     $0xffffff80,%eax
f010024a:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010024c:	83 e1 bf             	and    $0xffffffbf,%ecx
f010024f:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f0100255:	0f b6 c2             	movzbl %dl,%eax
f0100258:	0f b6 90 40 1a 10 f0 	movzbl -0xfefe5c0(%eax),%edx
f010025f:	0b 15 00 23 11 f0    	or     0xf0112300,%edx
	shift ^= togglecode[data];
f0100265:	0f b6 88 40 19 10 f0 	movzbl -0xfefe6c0(%eax),%ecx
f010026c:	31 ca                	xor    %ecx,%edx
f010026e:	89 15 00 23 11 f0    	mov    %edx,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100274:	89 d1                	mov    %edx,%ecx
f0100276:	83 e1 03             	and    $0x3,%ecx
f0100279:	8b 0c 8d 00 19 10 f0 	mov    -0xfefe700(,%ecx,4),%ecx
f0100280:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
f0100284:	0f b6 d8             	movzbl %al,%ebx
	if (shift & CAPSLOCK) {
f0100287:	f6 c2 08             	test   $0x8,%dl
f010028a:	74 1b                	je     f01002a7 <kbd_proc_data+0xd0>
		if ('a' <= c && c <= 'z')
f010028c:	89 d8                	mov    %ebx,%eax
f010028e:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100291:	83 f9 19             	cmp    $0x19,%ecx
f0100294:	77 05                	ja     f010029b <kbd_proc_data+0xc4>
			c += 'A' - 'a';
f0100296:	83 eb 20             	sub    $0x20,%ebx
f0100299:	eb 0c                	jmp    f01002a7 <kbd_proc_data+0xd0>
		else if ('A' <= c && c <= 'Z')
f010029b:	83 e8 41             	sub    $0x41,%eax
			c += 'a' - 'A';
f010029e:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002a1:	83 f8 19             	cmp    $0x19,%eax
f01002a4:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002a7:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002ad:	75 2c                	jne    f01002db <kbd_proc_data+0x104>
f01002af:	f7 d2                	not    %edx
f01002b1:	f6 c2 06             	test   $0x6,%dl
f01002b4:	75 25                	jne    f01002db <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01002b6:	83 ec 0c             	sub    $0xc,%esp
f01002b9:	68 c4 18 10 f0       	push   $0xf01018c4
f01002be:	e8 13 06 00 00       	call   f01008d6 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002c3:	ba 92 00 00 00       	mov    $0x92,%edx
f01002c8:	b8 03 00 00 00       	mov    $0x3,%eax
f01002cd:	ee                   	out    %al,(%dx)
f01002ce:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002d1:	89 d8                	mov    %ebx,%eax
f01002d3:	eb 08                	jmp    f01002dd <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002da:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002db:	89 d8                	mov    %ebx,%eax
}
f01002dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002e0:	c9                   	leave  
f01002e1:	c3                   	ret    

f01002e2 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002e2:	55                   	push   %ebp
f01002e3:	89 e5                	mov    %esp,%ebp
f01002e5:	57                   	push   %edi
f01002e6:	56                   	push   %esi
f01002e7:	53                   	push   %ebx
f01002e8:	83 ec 1c             	sub    $0x1c,%esp
f01002eb:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002ed:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f2:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002f7:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002fc:	eb 09                	jmp    f0100307 <cons_putc+0x25>
f01002fe:	89 ca                	mov    %ecx,%edx
f0100300:	ec                   	in     (%dx),%al
f0100301:	ec                   	in     (%dx),%al
f0100302:	ec                   	in     (%dx),%al
f0100303:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100304:	83 c3 01             	add    $0x1,%ebx
f0100307:	89 f2                	mov    %esi,%edx
f0100309:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010030a:	a8 20                	test   $0x20,%al
f010030c:	75 08                	jne    f0100316 <cons_putc+0x34>
f010030e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100314:	7e e8                	jle    f01002fe <cons_putc+0x1c>
f0100316:	89 f8                	mov    %edi,%eax
f0100318:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010031b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100320:	89 f8                	mov    %edi,%eax
f0100322:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100323:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100328:	be 79 03 00 00       	mov    $0x379,%esi
f010032d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100332:	eb 09                	jmp    f010033d <cons_putc+0x5b>
f0100334:	89 ca                	mov    %ecx,%edx
f0100336:	ec                   	in     (%dx),%al
f0100337:	ec                   	in     (%dx),%al
f0100338:	ec                   	in     (%dx),%al
f0100339:	ec                   	in     (%dx),%al
f010033a:	83 c3 01             	add    $0x1,%ebx
f010033d:	89 f2                	mov    %esi,%edx
f010033f:	ec                   	in     (%dx),%al
f0100340:	84 c0                	test   %al,%al
f0100342:	78 08                	js     f010034c <cons_putc+0x6a>
f0100344:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010034a:	7e e8                	jle    f0100334 <cons_putc+0x52>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010034c:	ba 78 03 00 00       	mov    $0x378,%edx
f0100351:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100355:	ee                   	out    %al,(%dx)
f0100356:	b2 7a                	mov    $0x7a,%dl
f0100358:	b8 0d 00 00 00       	mov    $0xd,%eax
f010035d:	ee                   	out    %al,(%dx)
f010035e:	b8 08 00 00 00       	mov    $0x8,%eax
f0100363:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100364:	89 fa                	mov    %edi,%edx
f0100366:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010036c:	89 f8                	mov    %edi,%eax
f010036e:	80 cc 07             	or     $0x7,%ah
f0100371:	85 d2                	test   %edx,%edx
f0100373:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100376:	89 f8                	mov    %edi,%eax
f0100378:	0f b6 c0             	movzbl %al,%eax
f010037b:	83 f8 09             	cmp    $0x9,%eax
f010037e:	74 74                	je     f01003f4 <cons_putc+0x112>
f0100380:	83 f8 09             	cmp    $0x9,%eax
f0100383:	7f 0a                	jg     f010038f <cons_putc+0xad>
f0100385:	83 f8 08             	cmp    $0x8,%eax
f0100388:	74 14                	je     f010039e <cons_putc+0xbc>
f010038a:	e9 99 00 00 00       	jmp    f0100428 <cons_putc+0x146>
f010038f:	83 f8 0a             	cmp    $0xa,%eax
f0100392:	74 3a                	je     f01003ce <cons_putc+0xec>
f0100394:	83 f8 0d             	cmp    $0xd,%eax
f0100397:	74 3d                	je     f01003d6 <cons_putc+0xf4>
f0100399:	e9 8a 00 00 00       	jmp    f0100428 <cons_putc+0x146>
	case '\b':
		if (crt_pos > 0) {
f010039e:	0f b7 05 48 25 11 f0 	movzwl 0xf0112548,%eax
f01003a5:	66 85 c0             	test   %ax,%ax
f01003a8:	0f 84 e6 00 00 00    	je     f0100494 <cons_putc+0x1b2>
			crt_pos--;
f01003ae:	83 e8 01             	sub    $0x1,%eax
f01003b1:	66 a3 48 25 11 f0    	mov    %ax,0xf0112548
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003b7:	0f b7 c0             	movzwl %ax,%eax
f01003ba:	66 81 e7 00 ff       	and    $0xff00,%di
f01003bf:	83 cf 20             	or     $0x20,%edi
f01003c2:	8b 15 4c 25 11 f0    	mov    0xf011254c,%edx
f01003c8:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003cc:	eb 78                	jmp    f0100446 <cons_putc+0x164>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003ce:	66 83 05 48 25 11 f0 	addw   $0x50,0xf0112548
f01003d5:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003d6:	0f b7 05 48 25 11 f0 	movzwl 0xf0112548,%eax
f01003dd:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003e3:	c1 e8 16             	shr    $0x16,%eax
f01003e6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003e9:	c1 e0 04             	shl    $0x4,%eax
f01003ec:	66 a3 48 25 11 f0    	mov    %ax,0xf0112548
f01003f2:	eb 52                	jmp    f0100446 <cons_putc+0x164>
		break;
	case '\t':
		cons_putc(' ');
f01003f4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f9:	e8 e4 fe ff ff       	call   f01002e2 <cons_putc>
		cons_putc(' ');
f01003fe:	b8 20 00 00 00       	mov    $0x20,%eax
f0100403:	e8 da fe ff ff       	call   f01002e2 <cons_putc>
		cons_putc(' ');
f0100408:	b8 20 00 00 00       	mov    $0x20,%eax
f010040d:	e8 d0 fe ff ff       	call   f01002e2 <cons_putc>
		cons_putc(' ');
f0100412:	b8 20 00 00 00       	mov    $0x20,%eax
f0100417:	e8 c6 fe ff ff       	call   f01002e2 <cons_putc>
		cons_putc(' ');
f010041c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100421:	e8 bc fe ff ff       	call   f01002e2 <cons_putc>
f0100426:	eb 1e                	jmp    f0100446 <cons_putc+0x164>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100428:	0f b7 05 48 25 11 f0 	movzwl 0xf0112548,%eax
f010042f:	8d 50 01             	lea    0x1(%eax),%edx
f0100432:	66 89 15 48 25 11 f0 	mov    %dx,0xf0112548
f0100439:	0f b7 c0             	movzwl %ax,%eax
f010043c:	8b 15 4c 25 11 f0    	mov    0xf011254c,%edx
f0100442:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100446:	66 81 3d 48 25 11 f0 	cmpw   $0x7cf,0xf0112548
f010044d:	cf 07 
f010044f:	76 43                	jbe    f0100494 <cons_putc+0x1b2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100451:	a1 4c 25 11 f0       	mov    0xf011254c,%eax
f0100456:	83 ec 04             	sub    $0x4,%esp
f0100459:	68 00 0f 00 00       	push   $0xf00
f010045e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100464:	52                   	push   %edx
f0100465:	50                   	push   %eax
f0100466:	e8 36 0f 00 00       	call   f01013a1 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010046b:	8b 15 4c 25 11 f0    	mov    0xf011254c,%edx
f0100471:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100477:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010047d:	83 c4 10             	add    $0x10,%esp
f0100480:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100485:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100488:	39 d0                	cmp    %edx,%eax
f010048a:	75 f4                	jne    f0100480 <cons_putc+0x19e>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010048c:	66 83 2d 48 25 11 f0 	subw   $0x50,0xf0112548
f0100493:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100494:	8b 0d 50 25 11 f0    	mov    0xf0112550,%ecx
f010049a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010049f:	89 ca                	mov    %ecx,%edx
f01004a1:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004a2:	0f b7 1d 48 25 11 f0 	movzwl 0xf0112548,%ebx
f01004a9:	8d 71 01             	lea    0x1(%ecx),%esi
f01004ac:	89 d8                	mov    %ebx,%eax
f01004ae:	66 c1 e8 08          	shr    $0x8,%ax
f01004b2:	89 f2                	mov    %esi,%edx
f01004b4:	ee                   	out    %al,(%dx)
f01004b5:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004ba:	89 ca                	mov    %ecx,%edx
f01004bc:	ee                   	out    %al,(%dx)
f01004bd:	89 d8                	mov    %ebx,%eax
f01004bf:	89 f2                	mov    %esi,%edx
f01004c1:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004c5:	5b                   	pop    %ebx
f01004c6:	5e                   	pop    %esi
f01004c7:	5f                   	pop    %edi
f01004c8:	5d                   	pop    %ebp
f01004c9:	c3                   	ret    

f01004ca <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004ca:	80 3d 54 25 11 f0 00 	cmpb   $0x0,0xf0112554
f01004d1:	74 11                	je     f01004e4 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004d3:	55                   	push   %ebp
f01004d4:	89 e5                	mov    %esp,%ebp
f01004d6:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004d9:	b8 77 01 10 f0       	mov    $0xf0100177,%eax
f01004de:	e8 b0 fc ff ff       	call   f0100193 <cons_intr>
}
f01004e3:	c9                   	leave  
f01004e4:	f3 c3                	repz ret 

f01004e6 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004e6:	55                   	push   %ebp
f01004e7:	89 e5                	mov    %esp,%ebp
f01004e9:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004ec:	b8 d7 01 10 f0       	mov    $0xf01001d7,%eax
f01004f1:	e8 9d fc ff ff       	call   f0100193 <cons_intr>
}
f01004f6:	c9                   	leave  
f01004f7:	c3                   	ret    

f01004f8 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004f8:	55                   	push   %ebp
f01004f9:	89 e5                	mov    %esp,%ebp
f01004fb:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004fe:	e8 c7 ff ff ff       	call   f01004ca <serial_intr>
	kbd_intr();
f0100503:	e8 de ff ff ff       	call   f01004e6 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100508:	a1 40 25 11 f0       	mov    0xf0112540,%eax
f010050d:	3b 05 44 25 11 f0    	cmp    0xf0112544,%eax
f0100513:	74 26                	je     f010053b <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100515:	8d 50 01             	lea    0x1(%eax),%edx
f0100518:	89 15 40 25 11 f0    	mov    %edx,0xf0112540
f010051e:	0f b6 88 40 23 11 f0 	movzbl -0xfeedcc0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100525:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100527:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010052d:	75 11                	jne    f0100540 <cons_getc+0x48>
			cons.rpos = 0;
f010052f:	c7 05 40 25 11 f0 00 	movl   $0x0,0xf0112540
f0100536:	00 00 00 
f0100539:	eb 05                	jmp    f0100540 <cons_getc+0x48>
		return c;
	}
	return 0;
f010053b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100540:	c9                   	leave  
f0100541:	c3                   	ret    

f0100542 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100542:	55                   	push   %ebp
f0100543:	89 e5                	mov    %esp,%ebp
f0100545:	57                   	push   %edi
f0100546:	56                   	push   %esi
f0100547:	53                   	push   %ebx
f0100548:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010054b:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100552:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100559:	5a a5 
	if (*cp != 0xA55A) {
f010055b:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100562:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100566:	74 11                	je     f0100579 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100568:	c7 05 50 25 11 f0 b4 	movl   $0x3b4,0xf0112550
f010056f:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100572:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100577:	eb 16                	jmp    f010058f <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100579:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100580:	c7 05 50 25 11 f0 d4 	movl   $0x3d4,0xf0112550
f0100587:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010058a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010058f:	8b 3d 50 25 11 f0    	mov    0xf0112550,%edi
f0100595:	b8 0e 00 00 00       	mov    $0xe,%eax
f010059a:	89 fa                	mov    %edi,%edx
f010059c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010059d:	8d 4f 01             	lea    0x1(%edi),%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005a0:	89 ca                	mov    %ecx,%edx
f01005a2:	ec                   	in     (%dx),%al
f01005a3:	0f b6 c0             	movzbl %al,%eax
f01005a6:	c1 e0 08             	shl    $0x8,%eax
f01005a9:	89 c3                	mov    %eax,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ab:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005b0:	89 fa                	mov    %edi,%edx
f01005b2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b3:	89 ca                	mov    %ecx,%edx
f01005b5:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005b6:	89 35 4c 25 11 f0    	mov    %esi,0xf011254c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005bc:	0f b6 c8             	movzbl %al,%ecx
f01005bf:	89 d8                	mov    %ebx,%eax
f01005c1:	09 c8                	or     %ecx,%eax

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005c3:	66 a3 48 25 11 f0    	mov    %ax,0xf0112548
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005c9:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01005d3:	89 da                	mov    %ebx,%edx
f01005d5:	ee                   	out    %al,(%dx)
f01005d6:	b2 fb                	mov    $0xfb,%dl
f01005d8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005dd:	ee                   	out    %al,(%dx)
f01005de:	be f8 03 00 00       	mov    $0x3f8,%esi
f01005e3:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005e8:	89 f2                	mov    %esi,%edx
f01005ea:	ee                   	out    %al,(%dx)
f01005eb:	b2 f9                	mov    $0xf9,%dl
f01005ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01005f2:	ee                   	out    %al,(%dx)
f01005f3:	b2 fb                	mov    $0xfb,%dl
f01005f5:	b8 03 00 00 00       	mov    $0x3,%eax
f01005fa:	ee                   	out    %al,(%dx)
f01005fb:	b2 fc                	mov    $0xfc,%dl
f01005fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100602:	ee                   	out    %al,(%dx)
f0100603:	b2 f9                	mov    $0xf9,%dl
f0100605:	b8 01 00 00 00       	mov    $0x1,%eax
f010060a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010060b:	b2 fd                	mov    $0xfd,%dl
f010060d:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010060e:	3c ff                	cmp    $0xff,%al
f0100610:	0f 95 c1             	setne  %cl
f0100613:	88 0d 54 25 11 f0    	mov    %cl,0xf0112554
f0100619:	89 da                	mov    %ebx,%edx
f010061b:	ec                   	in     (%dx),%al
f010061c:	89 f2                	mov    %esi,%edx
f010061e:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010061f:	84 c9                	test   %cl,%cl
f0100621:	75 10                	jne    f0100633 <cons_init+0xf1>
		cprintf("Serial port does not exist!\n");
f0100623:	83 ec 0c             	sub    $0xc,%esp
f0100626:	68 d0 18 10 f0       	push   $0xf01018d0
f010062b:	e8 a6 02 00 00       	call   f01008d6 <cprintf>
f0100630:	83 c4 10             	add    $0x10,%esp
}
f0100633:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100636:	5b                   	pop    %ebx
f0100637:	5e                   	pop    %esi
f0100638:	5f                   	pop    %edi
f0100639:	5d                   	pop    %ebp
f010063a:	c3                   	ret    

f010063b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010063b:	55                   	push   %ebp
f010063c:	89 e5                	mov    %esp,%ebp
f010063e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100641:	8b 45 08             	mov    0x8(%ebp),%eax
f0100644:	e8 99 fc ff ff       	call   f01002e2 <cons_putc>
}
f0100649:	c9                   	leave  
f010064a:	c3                   	ret    

f010064b <getchar>:

int
getchar(void)
{
f010064b:	55                   	push   %ebp
f010064c:	89 e5                	mov    %esp,%ebp
f010064e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100651:	e8 a2 fe ff ff       	call   f01004f8 <cons_getc>
f0100656:	85 c0                	test   %eax,%eax
f0100658:	74 f7                	je     f0100651 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010065a:	c9                   	leave  
f010065b:	c3                   	ret    

f010065c <iscons>:

int
iscons(int fdnum)
{
f010065c:	55                   	push   %ebp
f010065d:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010065f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100664:	5d                   	pop    %ebp
f0100665:	c3                   	ret    

f0100666 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100666:	55                   	push   %ebp
f0100667:	89 e5                	mov    %esp,%ebp
f0100669:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010066c:	68 40 1b 10 f0       	push   $0xf0101b40
f0100671:	68 5e 1b 10 f0       	push   $0xf0101b5e
f0100676:	68 63 1b 10 f0       	push   $0xf0101b63
f010067b:	e8 56 02 00 00       	call   f01008d6 <cprintf>
f0100680:	83 c4 0c             	add    $0xc,%esp
f0100683:	68 cc 1b 10 f0       	push   $0xf0101bcc
f0100688:	68 6c 1b 10 f0       	push   $0xf0101b6c
f010068d:	68 63 1b 10 f0       	push   $0xf0101b63
f0100692:	e8 3f 02 00 00       	call   f01008d6 <cprintf>
	return 0;
}
f0100697:	b8 00 00 00 00       	mov    $0x0,%eax
f010069c:	c9                   	leave  
f010069d:	c3                   	ret    

f010069e <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010069e:	55                   	push   %ebp
f010069f:	89 e5                	mov    %esp,%ebp
f01006a1:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006a4:	68 75 1b 10 f0       	push   $0xf0101b75
f01006a9:	e8 28 02 00 00       	call   f01008d6 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006ae:	83 c4 08             	add    $0x8,%esp
f01006b1:	68 0c 00 10 00       	push   $0x10000c
f01006b6:	68 f4 1b 10 f0       	push   $0xf0101bf4
f01006bb:	e8 16 02 00 00       	call   f01008d6 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006c0:	83 c4 0c             	add    $0xc,%esp
f01006c3:	68 0c 00 10 00       	push   $0x10000c
f01006c8:	68 0c 00 10 f0       	push   $0xf010000c
f01006cd:	68 1c 1c 10 f0       	push   $0xf0101c1c
f01006d2:	e8 ff 01 00 00       	call   f01008d6 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006d7:	83 c4 0c             	add    $0xc,%esp
f01006da:	68 05 18 10 00       	push   $0x101805
f01006df:	68 05 18 10 f0       	push   $0xf0101805
f01006e4:	68 40 1c 10 f0       	push   $0xf0101c40
f01006e9:	e8 e8 01 00 00       	call   f01008d6 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006ee:	83 c4 0c             	add    $0xc,%esp
f01006f1:	68 00 23 11 00       	push   $0x112300
f01006f6:	68 00 23 11 f0       	push   $0xf0112300
f01006fb:	68 64 1c 10 f0       	push   $0xf0101c64
f0100700:	e8 d1 01 00 00       	call   f01008d6 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100705:	83 c4 0c             	add    $0xc,%esp
f0100708:	68 84 29 11 00       	push   $0x112984
f010070d:	68 84 29 11 f0       	push   $0xf0112984
f0100712:	68 88 1c 10 f0       	push   $0xf0101c88
f0100717:	e8 ba 01 00 00       	call   f01008d6 <cprintf>
f010071c:	b8 83 2d 11 f0       	mov    $0xf0112d83,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100721:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100726:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100729:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010072e:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100734:	85 c0                	test   %eax,%eax
f0100736:	0f 48 c2             	cmovs  %edx,%eax
f0100739:	c1 f8 0a             	sar    $0xa,%eax
f010073c:	50                   	push   %eax
f010073d:	68 ac 1c 10 f0       	push   $0xf0101cac
f0100742:	e8 8f 01 00 00       	call   f01008d6 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100747:	b8 00 00 00 00       	mov    $0x0,%eax
f010074c:	c9                   	leave  
f010074d:	c3                   	ret    

f010074e <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010074e:	55                   	push   %ebp
f010074f:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100751:	b8 00 00 00 00       	mov    $0x0,%eax
f0100756:	5d                   	pop    %ebp
f0100757:	c3                   	ret    

f0100758 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100758:	55                   	push   %ebp
f0100759:	89 e5                	mov    %esp,%ebp
f010075b:	57                   	push   %edi
f010075c:	56                   	push   %esi
f010075d:	53                   	push   %ebx
f010075e:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100761:	68 d8 1c 10 f0       	push   $0xf0101cd8
f0100766:	e8 6b 01 00 00       	call   f01008d6 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010076b:	c7 04 24 fc 1c 10 f0 	movl   $0xf0101cfc,(%esp)
f0100772:	e8 5f 01 00 00       	call   f01008d6 <cprintf>
f0100777:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f010077a:	83 ec 0c             	sub    $0xc,%esp
f010077d:	68 8e 1b 10 f0       	push   $0xf0101b8e
f0100782:	e8 76 09 00 00       	call   f01010fd <readline>
f0100787:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100789:	83 c4 10             	add    $0x10,%esp
f010078c:	85 c0                	test   %eax,%eax
f010078e:	74 ea                	je     f010077a <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100790:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100797:	be 00 00 00 00       	mov    $0x0,%esi
f010079c:	eb 0a                	jmp    f01007a8 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010079e:	c6 03 00             	movb   $0x0,(%ebx)
f01007a1:	89 f7                	mov    %esi,%edi
f01007a3:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01007a6:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007a8:	0f b6 03             	movzbl (%ebx),%eax
f01007ab:	84 c0                	test   %al,%al
f01007ad:	74 63                	je     f0100812 <monitor+0xba>
f01007af:	83 ec 08             	sub    $0x8,%esp
f01007b2:	0f be c0             	movsbl %al,%eax
f01007b5:	50                   	push   %eax
f01007b6:	68 92 1b 10 f0       	push   $0xf0101b92
f01007bb:	e8 57 0b 00 00       	call   f0101317 <strchr>
f01007c0:	83 c4 10             	add    $0x10,%esp
f01007c3:	85 c0                	test   %eax,%eax
f01007c5:	75 d7                	jne    f010079e <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f01007c7:	80 3b 00             	cmpb   $0x0,(%ebx)
f01007ca:	74 46                	je     f0100812 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01007cc:	83 fe 0f             	cmp    $0xf,%esi
f01007cf:	75 14                	jne    f01007e5 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007d1:	83 ec 08             	sub    $0x8,%esp
f01007d4:	6a 10                	push   $0x10
f01007d6:	68 97 1b 10 f0       	push   $0xf0101b97
f01007db:	e8 f6 00 00 00       	call   f01008d6 <cprintf>
f01007e0:	83 c4 10             	add    $0x10,%esp
f01007e3:	eb 95                	jmp    f010077a <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f01007e5:	8d 7e 01             	lea    0x1(%esi),%edi
f01007e8:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01007ec:	eb 03                	jmp    f01007f1 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01007ee:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01007f1:	0f b6 03             	movzbl (%ebx),%eax
f01007f4:	84 c0                	test   %al,%al
f01007f6:	74 ae                	je     f01007a6 <monitor+0x4e>
f01007f8:	83 ec 08             	sub    $0x8,%esp
f01007fb:	0f be c0             	movsbl %al,%eax
f01007fe:	50                   	push   %eax
f01007ff:	68 92 1b 10 f0       	push   $0xf0101b92
f0100804:	e8 0e 0b 00 00       	call   f0101317 <strchr>
f0100809:	83 c4 10             	add    $0x10,%esp
f010080c:	85 c0                	test   %eax,%eax
f010080e:	74 de                	je     f01007ee <monitor+0x96>
f0100810:	eb 94                	jmp    f01007a6 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f0100812:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100819:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010081a:	85 f6                	test   %esi,%esi
f010081c:	0f 84 58 ff ff ff    	je     f010077a <monitor+0x22>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100822:	83 ec 08             	sub    $0x8,%esp
f0100825:	68 5e 1b 10 f0       	push   $0xf0101b5e
f010082a:	ff 75 a8             	pushl  -0x58(%ebp)
f010082d:	e8 87 0a 00 00       	call   f01012b9 <strcmp>
f0100832:	83 c4 10             	add    $0x10,%esp
f0100835:	85 c0                	test   %eax,%eax
f0100837:	74 1b                	je     f0100854 <monitor+0xfc>
f0100839:	83 ec 08             	sub    $0x8,%esp
f010083c:	68 6c 1b 10 f0       	push   $0xf0101b6c
f0100841:	ff 75 a8             	pushl  -0x58(%ebp)
f0100844:	e8 70 0a 00 00       	call   f01012b9 <strcmp>
f0100849:	83 c4 10             	add    $0x10,%esp
f010084c:	85 c0                	test   %eax,%eax
f010084e:	75 2d                	jne    f010087d <monitor+0x125>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100850:	b0 01                	mov    $0x1,%al
f0100852:	eb 05                	jmp    f0100859 <monitor+0x101>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100854:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100859:	83 ec 04             	sub    $0x4,%esp
f010085c:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010085f:	01 d0                	add    %edx,%eax
f0100861:	ff 75 08             	pushl  0x8(%ebp)
f0100864:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100867:	51                   	push   %ecx
f0100868:	56                   	push   %esi
f0100869:	ff 14 85 2c 1d 10 f0 	call   *-0xfefe2d4(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100870:	83 c4 10             	add    $0x10,%esp
f0100873:	85 c0                	test   %eax,%eax
f0100875:	0f 89 ff fe ff ff    	jns    f010077a <monitor+0x22>
f010087b:	eb 18                	jmp    f0100895 <monitor+0x13d>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010087d:	83 ec 08             	sub    $0x8,%esp
f0100880:	ff 75 a8             	pushl  -0x58(%ebp)
f0100883:	68 b4 1b 10 f0       	push   $0xf0101bb4
f0100888:	e8 49 00 00 00       	call   f01008d6 <cprintf>
f010088d:	83 c4 10             	add    $0x10,%esp
f0100890:	e9 e5 fe ff ff       	jmp    f010077a <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100895:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100898:	5b                   	pop    %ebx
f0100899:	5e                   	pop    %esi
f010089a:	5f                   	pop    %edi
f010089b:	5d                   	pop    %ebp
f010089c:	c3                   	ret    

f010089d <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010089d:	55                   	push   %ebp
f010089e:	89 e5                	mov    %esp,%ebp
f01008a0:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01008a3:	ff 75 08             	pushl  0x8(%ebp)
f01008a6:	e8 90 fd ff ff       	call   f010063b <cputchar>
f01008ab:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f01008ae:	c9                   	leave  
f01008af:	c3                   	ret    

f01008b0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01008b0:	55                   	push   %ebp
f01008b1:	89 e5                	mov    %esp,%ebp
f01008b3:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01008b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01008bd:	ff 75 0c             	pushl  0xc(%ebp)
f01008c0:	ff 75 08             	pushl  0x8(%ebp)
f01008c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01008c6:	50                   	push   %eax
f01008c7:	68 9d 08 10 f0       	push   $0xf010089d
f01008cc:	e8 10 04 00 00       	call   f0100ce1 <vprintfmt>
	return cnt;
}
f01008d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01008d4:	c9                   	leave  
f01008d5:	c3                   	ret    

f01008d6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01008d6:	55                   	push   %ebp
f01008d7:	89 e5                	mov    %esp,%ebp
f01008d9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01008dc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01008df:	50                   	push   %eax
f01008e0:	ff 75 08             	pushl  0x8(%ebp)
f01008e3:	e8 c8 ff ff ff       	call   f01008b0 <vcprintf>
	va_end(ap);

	return cnt;
}
f01008e8:	c9                   	leave  
f01008e9:	c3                   	ret    

f01008ea <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01008ea:	55                   	push   %ebp
f01008eb:	89 e5                	mov    %esp,%ebp
f01008ed:	57                   	push   %edi
f01008ee:	56                   	push   %esi
f01008ef:	53                   	push   %ebx
f01008f0:	83 ec 14             	sub    $0x14,%esp
f01008f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01008f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01008f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01008fc:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01008ff:	8b 1a                	mov    (%edx),%ebx
f0100901:	8b 01                	mov    (%ecx),%eax
f0100903:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100906:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010090d:	e9 88 00 00 00       	jmp    f010099a <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0100912:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100915:	01 d8                	add    %ebx,%eax
f0100917:	89 c6                	mov    %eax,%esi
f0100919:	c1 ee 1f             	shr    $0x1f,%esi
f010091c:	01 c6                	add    %eax,%esi
f010091e:	d1 fe                	sar    %esi
f0100920:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100923:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100926:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0100929:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010092b:	eb 03                	jmp    f0100930 <stab_binsearch+0x46>
			m--;
f010092d:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100930:	39 c3                	cmp    %eax,%ebx
f0100932:	7f 1f                	jg     f0100953 <stab_binsearch+0x69>
f0100934:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100938:	83 ea 0c             	sub    $0xc,%edx
f010093b:	39 f9                	cmp    %edi,%ecx
f010093d:	75 ee                	jne    f010092d <stab_binsearch+0x43>
f010093f:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100942:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100945:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100948:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010094c:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010094f:	76 18                	jbe    f0100969 <stab_binsearch+0x7f>
f0100951:	eb 05                	jmp    f0100958 <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100953:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100956:	eb 42                	jmp    f010099a <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0100958:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010095b:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010095d:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100960:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100967:	eb 31                	jmp    f010099a <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100969:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010096c:	73 17                	jae    f0100985 <stab_binsearch+0x9b>
			*region_right = m - 1;
f010096e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100971:	83 e8 01             	sub    $0x1,%eax
f0100974:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100977:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010097a:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010097c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100983:	eb 15                	jmp    f010099a <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100985:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100988:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f010098b:	89 1e                	mov    %ebx,(%esi)
			l = m;
			addr++;
f010098d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100991:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100993:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010099a:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010099d:	0f 8e 6f ff ff ff    	jle    f0100912 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01009a3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01009a7:	75 0f                	jne    f01009b8 <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f01009a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009ac:	8b 00                	mov    (%eax),%eax
f01009ae:	83 e8 01             	sub    $0x1,%eax
f01009b1:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01009b4:	89 06                	mov    %eax,(%esi)
f01009b6:	eb 2c                	jmp    f01009e4 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01009bb:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01009bd:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01009c0:	8b 0e                	mov    (%esi),%ecx
f01009c2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01009c5:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01009c8:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009cb:	eb 03                	jmp    f01009d0 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01009cd:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009d0:	39 c8                	cmp    %ecx,%eax
f01009d2:	7e 0b                	jle    f01009df <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f01009d4:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01009d8:	83 ea 0c             	sub    $0xc,%edx
f01009db:	39 fb                	cmp    %edi,%ebx
f01009dd:	75 ee                	jne    f01009cd <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f01009df:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01009e2:	89 06                	mov    %eax,(%esi)
	}
}
f01009e4:	83 c4 14             	add    $0x14,%esp
f01009e7:	5b                   	pop    %ebx
f01009e8:	5e                   	pop    %esi
f01009e9:	5f                   	pop    %edi
f01009ea:	5d                   	pop    %ebp
f01009eb:	c3                   	ret    

f01009ec <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01009ec:	55                   	push   %ebp
f01009ed:	89 e5                	mov    %esp,%ebp
f01009ef:	57                   	push   %edi
f01009f0:	56                   	push   %esi
f01009f1:	53                   	push   %ebx
f01009f2:	83 ec 1c             	sub    $0x1c,%esp
f01009f5:	8b 7d 08             	mov    0x8(%ebp),%edi
f01009f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01009fb:	c7 06 3c 1d 10 f0    	movl   $0xf0101d3c,(%esi)
	info->eip_line = 0;
f0100a01:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100a08:	c7 46 08 3c 1d 10 f0 	movl   $0xf0101d3c,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100a0f:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100a16:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100a19:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100a20:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100a26:	76 11                	jbe    f0100a39 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a28:	b8 65 70 10 f0       	mov    $0xf0107065,%eax
f0100a2d:	3d ad 57 10 f0       	cmp    $0xf01057ad,%eax
f0100a32:	77 19                	ja     f0100a4d <debuginfo_eip+0x61>
f0100a34:	e9 4c 01 00 00       	jmp    f0100b85 <debuginfo_eip+0x199>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100a39:	83 ec 04             	sub    $0x4,%esp
f0100a3c:	68 46 1d 10 f0       	push   $0xf0101d46
f0100a41:	6a 7f                	push   $0x7f
f0100a43:	68 53 1d 10 f0       	push   $0xf0101d53
f0100a48:	e8 99 f6 ff ff       	call   f01000e6 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a4d:	80 3d 64 70 10 f0 00 	cmpb   $0x0,0xf0107064
f0100a54:	0f 85 32 01 00 00    	jne    f0100b8c <debuginfo_eip+0x1a0>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100a5a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100a61:	b8 ac 57 10 f0       	mov    $0xf01057ac,%eax
f0100a66:	2d 90 1f 10 f0       	sub    $0xf0101f90,%eax
f0100a6b:	c1 f8 02             	sar    $0x2,%eax
f0100a6e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100a74:	83 e8 01             	sub    $0x1,%eax
f0100a77:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100a7a:	83 ec 08             	sub    $0x8,%esp
f0100a7d:	57                   	push   %edi
f0100a7e:	6a 64                	push   $0x64
f0100a80:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100a83:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100a86:	b8 90 1f 10 f0       	mov    $0xf0101f90,%eax
f0100a8b:	e8 5a fe ff ff       	call   f01008ea <stab_binsearch>
	if (lfile == 0)
f0100a90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a93:	83 c4 10             	add    $0x10,%esp
f0100a96:	85 c0                	test   %eax,%eax
f0100a98:	0f 84 f5 00 00 00    	je     f0100b93 <debuginfo_eip+0x1a7>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100a9e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100aa1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100aa4:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100aa7:	83 ec 08             	sub    $0x8,%esp
f0100aaa:	57                   	push   %edi
f0100aab:	6a 24                	push   $0x24
f0100aad:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100ab0:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ab3:	b8 90 1f 10 f0       	mov    $0xf0101f90,%eax
f0100ab8:	e8 2d fe ff ff       	call   f01008ea <stab_binsearch>

	if (lfun <= rfun) {
f0100abd:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100ac0:	83 c4 10             	add    $0x10,%esp
f0100ac3:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0100ac6:	7f 31                	jg     f0100af9 <debuginfo_eip+0x10d>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100ac8:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100acb:	c1 e0 02             	shl    $0x2,%eax
f0100ace:	8d 90 90 1f 10 f0    	lea    -0xfefe070(%eax),%edx
f0100ad4:	8b 88 90 1f 10 f0    	mov    -0xfefe070(%eax),%ecx
f0100ada:	b8 65 70 10 f0       	mov    $0xf0107065,%eax
f0100adf:	2d ad 57 10 f0       	sub    $0xf01057ad,%eax
f0100ae4:	39 c1                	cmp    %eax,%ecx
f0100ae6:	73 09                	jae    f0100af1 <debuginfo_eip+0x105>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100ae8:	81 c1 ad 57 10 f0    	add    $0xf01057ad,%ecx
f0100aee:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100af1:	8b 42 08             	mov    0x8(%edx),%eax
f0100af4:	89 46 10             	mov    %eax,0x10(%esi)
f0100af7:	eb 06                	jmp    f0100aff <debuginfo_eip+0x113>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100af9:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100afc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100aff:	83 ec 08             	sub    $0x8,%esp
f0100b02:	6a 3a                	push   $0x3a
f0100b04:	ff 76 08             	pushl  0x8(%esi)
f0100b07:	e8 2c 08 00 00       	call   f0101338 <strfind>
f0100b0c:	2b 46 08             	sub    0x8(%esi),%eax
f0100b0f:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b12:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b15:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b18:	8d 04 85 90 1f 10 f0 	lea    -0xfefe070(,%eax,4),%eax
f0100b1f:	83 c4 10             	add    $0x10,%esp
f0100b22:	eb 06                	jmp    f0100b2a <debuginfo_eip+0x13e>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100b24:	83 eb 01             	sub    $0x1,%ebx
f0100b27:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b2a:	39 fb                	cmp    %edi,%ebx
f0100b2c:	7c 1e                	jl     f0100b4c <debuginfo_eip+0x160>
	       && stabs[lline].n_type != N_SOL
f0100b2e:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0100b32:	80 fa 84             	cmp    $0x84,%dl
f0100b35:	74 6a                	je     f0100ba1 <debuginfo_eip+0x1b5>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100b37:	80 fa 64             	cmp    $0x64,%dl
f0100b3a:	75 e8                	jne    f0100b24 <debuginfo_eip+0x138>
f0100b3c:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100b40:	74 e2                	je     f0100b24 <debuginfo_eip+0x138>
f0100b42:	eb 5d                	jmp    f0100ba1 <debuginfo_eip+0x1b5>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100b44:	81 c2 ad 57 10 f0    	add    $0xf01057ad,%edx
f0100b4a:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100b4c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100b4f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100b52:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100b57:	39 cb                	cmp    %ecx,%ebx
f0100b59:	7d 60                	jge    f0100bbb <debuginfo_eip+0x1cf>
		for (lline = lfun + 1;
f0100b5b:	8d 53 01             	lea    0x1(%ebx),%edx
f0100b5e:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b61:	8d 04 85 90 1f 10 f0 	lea    -0xfefe070(,%eax,4),%eax
f0100b68:	eb 07                	jmp    f0100b71 <debuginfo_eip+0x185>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100b6a:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100b6e:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100b71:	39 ca                	cmp    %ecx,%edx
f0100b73:	74 25                	je     f0100b9a <debuginfo_eip+0x1ae>
f0100b75:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100b78:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0100b7c:	74 ec                	je     f0100b6a <debuginfo_eip+0x17e>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100b7e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b83:	eb 36                	jmp    f0100bbb <debuginfo_eip+0x1cf>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100b85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b8a:	eb 2f                	jmp    f0100bbb <debuginfo_eip+0x1cf>
f0100b8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b91:	eb 28                	jmp    f0100bbb <debuginfo_eip+0x1cf>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100b93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b98:	eb 21                	jmp    f0100bbb <debuginfo_eip+0x1cf>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100b9a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b9f:	eb 1a                	jmp    f0100bbb <debuginfo_eip+0x1cf>
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100ba1:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ba4:	8b 14 85 90 1f 10 f0 	mov    -0xfefe070(,%eax,4),%edx
f0100bab:	b8 65 70 10 f0       	mov    $0xf0107065,%eax
f0100bb0:	2d ad 57 10 f0       	sub    $0xf01057ad,%eax
f0100bb5:	39 c2                	cmp    %eax,%edx
f0100bb7:	72 8b                	jb     f0100b44 <debuginfo_eip+0x158>
f0100bb9:	eb 91                	jmp    f0100b4c <debuginfo_eip+0x160>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
}
f0100bbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100bbe:	5b                   	pop    %ebx
f0100bbf:	5e                   	pop    %esi
f0100bc0:	5f                   	pop    %edi
f0100bc1:	5d                   	pop    %ebp
f0100bc2:	c3                   	ret    

f0100bc3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100bc3:	55                   	push   %ebp
f0100bc4:	89 e5                	mov    %esp,%ebp
f0100bc6:	57                   	push   %edi
f0100bc7:	56                   	push   %esi
f0100bc8:	53                   	push   %ebx
f0100bc9:	83 ec 1c             	sub    $0x1c,%esp
f0100bcc:	89 c7                	mov    %eax,%edi
f0100bce:	89 d6                	mov    %edx,%esi
f0100bd0:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bd3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100bd6:	89 d1                	mov    %edx,%ecx
f0100bd8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100bdb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100bde:	8b 45 10             	mov    0x10(%ebp),%eax
f0100be1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100be4:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100be7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100bee:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f0100bf1:	72 05                	jb     f0100bf8 <printnum+0x35>
f0100bf3:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100bf6:	77 3e                	ja     f0100c36 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100bf8:	83 ec 0c             	sub    $0xc,%esp
f0100bfb:	ff 75 18             	pushl  0x18(%ebp)
f0100bfe:	83 eb 01             	sub    $0x1,%ebx
f0100c01:	53                   	push   %ebx
f0100c02:	50                   	push   %eax
f0100c03:	83 ec 08             	sub    $0x8,%esp
f0100c06:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100c09:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c0c:	ff 75 dc             	pushl  -0x24(%ebp)
f0100c0f:	ff 75 d8             	pushl  -0x28(%ebp)
f0100c12:	e8 49 09 00 00       	call   f0101560 <__udivdi3>
f0100c17:	83 c4 18             	add    $0x18,%esp
f0100c1a:	52                   	push   %edx
f0100c1b:	50                   	push   %eax
f0100c1c:	89 f2                	mov    %esi,%edx
f0100c1e:	89 f8                	mov    %edi,%eax
f0100c20:	e8 9e ff ff ff       	call   f0100bc3 <printnum>
f0100c25:	83 c4 20             	add    $0x20,%esp
f0100c28:	eb 13                	jmp    f0100c3d <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100c2a:	83 ec 08             	sub    $0x8,%esp
f0100c2d:	56                   	push   %esi
f0100c2e:	ff 75 18             	pushl  0x18(%ebp)
f0100c31:	ff d7                	call   *%edi
f0100c33:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100c36:	83 eb 01             	sub    $0x1,%ebx
f0100c39:	85 db                	test   %ebx,%ebx
f0100c3b:	7f ed                	jg     f0100c2a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100c3d:	83 ec 08             	sub    $0x8,%esp
f0100c40:	56                   	push   %esi
f0100c41:	83 ec 04             	sub    $0x4,%esp
f0100c44:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100c47:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c4a:	ff 75 dc             	pushl  -0x24(%ebp)
f0100c4d:	ff 75 d8             	pushl  -0x28(%ebp)
f0100c50:	e8 3b 0a 00 00       	call   f0101690 <__umoddi3>
f0100c55:	83 c4 14             	add    $0x14,%esp
f0100c58:	0f be 80 61 1d 10 f0 	movsbl -0xfefe29f(%eax),%eax
f0100c5f:	50                   	push   %eax
f0100c60:	ff d7                	call   *%edi
f0100c62:	83 c4 10             	add    $0x10,%esp
}
f0100c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c68:	5b                   	pop    %ebx
f0100c69:	5e                   	pop    %esi
f0100c6a:	5f                   	pop    %edi
f0100c6b:	5d                   	pop    %ebp
f0100c6c:	c3                   	ret    

f0100c6d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100c6d:	55                   	push   %ebp
f0100c6e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100c70:	83 fa 01             	cmp    $0x1,%edx
f0100c73:	7e 0e                	jle    f0100c83 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100c75:	8b 10                	mov    (%eax),%edx
f0100c77:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100c7a:	89 08                	mov    %ecx,(%eax)
f0100c7c:	8b 02                	mov    (%edx),%eax
f0100c7e:	8b 52 04             	mov    0x4(%edx),%edx
f0100c81:	eb 22                	jmp    f0100ca5 <getuint+0x38>
	else if (lflag)
f0100c83:	85 d2                	test   %edx,%edx
f0100c85:	74 10                	je     f0100c97 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100c87:	8b 10                	mov    (%eax),%edx
f0100c89:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100c8c:	89 08                	mov    %ecx,(%eax)
f0100c8e:	8b 02                	mov    (%edx),%eax
f0100c90:	ba 00 00 00 00       	mov    $0x0,%edx
f0100c95:	eb 0e                	jmp    f0100ca5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100c97:	8b 10                	mov    (%eax),%edx
f0100c99:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100c9c:	89 08                	mov    %ecx,(%eax)
f0100c9e:	8b 02                	mov    (%edx),%eax
f0100ca0:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100ca5:	5d                   	pop    %ebp
f0100ca6:	c3                   	ret    

f0100ca7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100ca7:	55                   	push   %ebp
f0100ca8:	89 e5                	mov    %esp,%ebp
f0100caa:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100cad:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100cb1:	8b 10                	mov    (%eax),%edx
f0100cb3:	3b 50 04             	cmp    0x4(%eax),%edx
f0100cb6:	73 0a                	jae    f0100cc2 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100cb8:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100cbb:	89 08                	mov    %ecx,(%eax)
f0100cbd:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cc0:	88 02                	mov    %al,(%edx)
}
f0100cc2:	5d                   	pop    %ebp
f0100cc3:	c3                   	ret    

f0100cc4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100cc4:	55                   	push   %ebp
f0100cc5:	89 e5                	mov    %esp,%ebp
f0100cc7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100cca:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100ccd:	50                   	push   %eax
f0100cce:	ff 75 10             	pushl  0x10(%ebp)
f0100cd1:	ff 75 0c             	pushl  0xc(%ebp)
f0100cd4:	ff 75 08             	pushl  0x8(%ebp)
f0100cd7:	e8 05 00 00 00       	call   f0100ce1 <vprintfmt>
	va_end(ap);
f0100cdc:	83 c4 10             	add    $0x10,%esp
}
f0100cdf:	c9                   	leave  
f0100ce0:	c3                   	ret    

f0100ce1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100ce1:	55                   	push   %ebp
f0100ce2:	89 e5                	mov    %esp,%ebp
f0100ce4:	57                   	push   %edi
f0100ce5:	56                   	push   %esi
f0100ce6:	53                   	push   %ebx
f0100ce7:	83 ec 2c             	sub    $0x2c,%esp
f0100cea:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ced:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100cf0:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100cf3:	eb 12                	jmp    f0100d07 <vprintfmt+0x26>

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
		{
			if (ch == '\0')
f0100cf5:	85 c0                	test   %eax,%eax
f0100cf7:	0f 84 90 03 00 00    	je     f010108d <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
f0100cfd:	83 ec 08             	sub    $0x8,%esp
f0100d00:	53                   	push   %ebx
f0100d01:	50                   	push   %eax
f0100d02:	ff d6                	call   *%esi
f0100d04:	83 c4 10             	add    $0x10,%esp
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
f0100d07:	83 c7 01             	add    $0x1,%edi
f0100d0a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100d0e:	83 f8 25             	cmp    $0x25,%eax
f0100d11:	75 e2                	jne    f0100cf5 <vprintfmt+0x14>
f0100d13:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100d17:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100d1e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100d25:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100d2c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d31:	eb 07                	jmp    f0100d3a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100d33:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		{

			// flag to pad on the right
			case '-':
				padc = '-';
f0100d36:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100d3a:	8d 47 01             	lea    0x1(%edi),%eax
f0100d3d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d40:	0f b6 07             	movzbl (%edi),%eax
f0100d43:	0f b6 c8             	movzbl %al,%ecx
f0100d46:	83 e8 23             	sub    $0x23,%eax
f0100d49:	3c 55                	cmp    $0x55,%al
f0100d4b:	0f 87 21 03 00 00    	ja     f0101072 <vprintfmt+0x391>
f0100d51:	0f b6 c0             	movzbl %al,%eax
f0100d54:	ff 24 85 00 1e 10 f0 	jmp    *-0xfefe200(,%eax,4)
f0100d5b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				padc = '-';
				goto reswitch;

			// flag to pad with 0's instead of spaces
			case '0':
				padc = '0';
f0100d5e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100d62:	eb d6                	jmp    f0100d3a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100d64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d67:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d6c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
					precision = precision * 10 + ch - '0';
f0100d6f:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100d72:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
					ch = *fmt;
f0100d76:	0f be 0f             	movsbl (%edi),%ecx
					if (ch < '0' || ch > '9')
f0100d79:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0100d7c:	83 fa 09             	cmp    $0x9,%edx
f0100d7f:	77 39                	ja     f0100dba <vprintfmt+0xd9>
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
f0100d81:	83 c7 01             	add    $0x1,%edi
					precision = precision * 10 + ch - '0';
					ch = *fmt;
					if (ch < '0' || ch > '9')
						break;
				}
f0100d84:	eb e9                	jmp    f0100d6f <vprintfmt+0x8e>
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
f0100d86:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d89:	8d 48 04             	lea    0x4(%eax),%ecx
f0100d8c:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100d8f:	8b 00                	mov    (%eax),%eax
f0100d91:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100d94:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				}
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
				goto process_precision;
f0100d97:	eb 27                	jmp    f0100dc0 <vprintfmt+0xdf>
f0100d99:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d9c:	85 c0                	test   %eax,%eax
f0100d9e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100da3:	0f 49 c8             	cmovns %eax,%ecx
f0100da6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100da9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100dac:	eb 8c                	jmp    f0100d3a <vprintfmt+0x59>
f0100dae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				if (width < 0)
					width = 0;
				goto reswitch;

			case '#':
				altflag = 1;
f0100db1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				goto reswitch;
f0100db8:	eb 80                	jmp    f0100d3a <vprintfmt+0x59>
f0100dba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100dbd:	89 45 d0             	mov    %eax,-0x30(%ebp)

			process_precision:
				if (width < 0)
f0100dc0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100dc4:	0f 89 70 ff ff ff    	jns    f0100d3a <vprintfmt+0x59>
					width = precision, precision = -1;
f0100dca:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100dcd:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100dd0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100dd7:	e9 5e ff ff ff       	jmp    f0100d3a <vprintfmt+0x59>
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
f0100ddc:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100ddf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
				goto reswitch;
f0100de2:	e9 53 ff ff ff       	jmp    f0100d3a <vprintfmt+0x59>

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
f0100de7:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dea:	8d 50 04             	lea    0x4(%eax),%edx
f0100ded:	89 55 14             	mov    %edx,0x14(%ebp)
f0100df0:	83 ec 08             	sub    $0x8,%esp
f0100df3:	53                   	push   %ebx
f0100df4:	ff 30                	pushl  (%eax)
f0100df6:	ff d6                	call   *%esi
				break;
f0100df8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100dfb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
				break;
f0100dfe:	e9 04 ff ff ff       	jmp    f0100d07 <vprintfmt+0x26>

			// error message
			case 'e':
				err = va_arg(ap, int);
f0100e03:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e06:	8d 50 04             	lea    0x4(%eax),%edx
f0100e09:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e0c:	8b 00                	mov    (%eax),%eax
f0100e0e:	99                   	cltd   
f0100e0f:	31 d0                	xor    %edx,%eax
f0100e11:	29 d0                	sub    %edx,%eax
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100e13:	83 f8 07             	cmp    $0x7,%eax
f0100e16:	7f 0b                	jg     f0100e23 <vprintfmt+0x142>
f0100e18:	8b 14 85 60 1f 10 f0 	mov    -0xfefe0a0(,%eax,4),%edx
f0100e1f:	85 d2                	test   %edx,%edx
f0100e21:	75 18                	jne    f0100e3b <vprintfmt+0x15a>
					printfmt(putch, putdat, "error %d", err);
f0100e23:	50                   	push   %eax
f0100e24:	68 79 1d 10 f0       	push   $0xf0101d79
f0100e29:	53                   	push   %ebx
f0100e2a:	56                   	push   %esi
f0100e2b:	e8 94 fe ff ff       	call   f0100cc4 <printfmt>
f0100e30:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100e33:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			case 'e':
				err = va_arg(ap, int);
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
					printfmt(putch, putdat, "error %d", err);
f0100e36:	e9 cc fe ff ff       	jmp    f0100d07 <vprintfmt+0x26>
				else
					printfmt(putch, putdat, "%s", p);
f0100e3b:	52                   	push   %edx
f0100e3c:	68 82 1d 10 f0       	push   $0xf0101d82
f0100e41:	53                   	push   %ebx
f0100e42:	56                   	push   %esi
f0100e43:	e8 7c fe ff ff       	call   f0100cc4 <printfmt>
f0100e48:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100e4b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e4e:	e9 b4 fe ff ff       	jmp    f0100d07 <vprintfmt+0x26>
f0100e53:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100e56:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e59:	89 45 cc             	mov    %eax,-0x34(%ebp)
					printfmt(putch, putdat, "%s", p);
				break;

			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
f0100e5c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e5f:	8d 50 04             	lea    0x4(%eax),%edx
f0100e62:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e65:	8b 38                	mov    (%eax),%edi
					p = "(null)";
f0100e67:	85 ff                	test   %edi,%edi
f0100e69:	ba 72 1d 10 f0       	mov    $0xf0101d72,%edx
f0100e6e:	0f 44 fa             	cmove  %edx,%edi
				if (width > 0 && padc != '-')
f0100e71:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100e75:	0f 84 92 00 00 00    	je     f0100f0d <vprintfmt+0x22c>
f0100e7b:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0100e7f:	0f 8e 96 00 00 00    	jle    f0100f1b <vprintfmt+0x23a>
					for (width -= strnlen(p, precision); width > 0; width--)
f0100e85:	83 ec 08             	sub    $0x8,%esp
f0100e88:	51                   	push   %ecx
f0100e89:	57                   	push   %edi
f0100e8a:	e8 5f 03 00 00       	call   f01011ee <strnlen>
f0100e8f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100e92:	29 c1                	sub    %eax,%ecx
f0100e94:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100e97:	83 c4 10             	add    $0x10,%esp
						putch(padc, putdat);
f0100e9a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100e9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ea1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100ea4:	89 cf                	mov    %ecx,%edi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
f0100ea6:	eb 0f                	jmp    f0100eb7 <vprintfmt+0x1d6>
						putch(padc, putdat);
f0100ea8:	83 ec 08             	sub    $0x8,%esp
f0100eab:	53                   	push   %ebx
f0100eac:	ff 75 e0             	pushl  -0x20(%ebp)
f0100eaf:	ff d6                	call   *%esi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
f0100eb1:	83 ef 01             	sub    $0x1,%edi
f0100eb4:	83 c4 10             	add    $0x10,%esp
f0100eb7:	85 ff                	test   %edi,%edi
f0100eb9:	7f ed                	jg     f0100ea8 <vprintfmt+0x1c7>
f0100ebb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100ebe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100ec1:	85 c9                	test   %ecx,%ecx
f0100ec3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ec8:	0f 49 c1             	cmovns %ecx,%eax
f0100ecb:	29 c1                	sub    %eax,%ecx
f0100ecd:	89 75 08             	mov    %esi,0x8(%ebp)
f0100ed0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100ed3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100ed6:	89 cb                	mov    %ecx,%ebx
f0100ed8:	eb 4d                	jmp    f0100f27 <vprintfmt+0x246>
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
f0100eda:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100ede:	74 1b                	je     f0100efb <vprintfmt+0x21a>
f0100ee0:	0f be c0             	movsbl %al,%eax
f0100ee3:	83 e8 20             	sub    $0x20,%eax
f0100ee6:	83 f8 5e             	cmp    $0x5e,%eax
f0100ee9:	76 10                	jbe    f0100efb <vprintfmt+0x21a>
						putch('?', putdat);
f0100eeb:	83 ec 08             	sub    $0x8,%esp
f0100eee:	ff 75 0c             	pushl  0xc(%ebp)
f0100ef1:	6a 3f                	push   $0x3f
f0100ef3:	ff 55 08             	call   *0x8(%ebp)
f0100ef6:	83 c4 10             	add    $0x10,%esp
f0100ef9:	eb 0d                	jmp    f0100f08 <vprintfmt+0x227>
					else
						putch(ch, putdat);
f0100efb:	83 ec 08             	sub    $0x8,%esp
f0100efe:	ff 75 0c             	pushl  0xc(%ebp)
f0100f01:	52                   	push   %edx
f0100f02:	ff 55 08             	call   *0x8(%ebp)
f0100f05:	83 c4 10             	add    $0x10,%esp
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100f08:	83 eb 01             	sub    $0x1,%ebx
f0100f0b:	eb 1a                	jmp    f0100f27 <vprintfmt+0x246>
f0100f0d:	89 75 08             	mov    %esi,0x8(%ebp)
f0100f10:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100f13:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100f16:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100f19:	eb 0c                	jmp    f0100f27 <vprintfmt+0x246>
f0100f1b:	89 75 08             	mov    %esi,0x8(%ebp)
f0100f1e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100f21:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100f24:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100f27:	83 c7 01             	add    $0x1,%edi
f0100f2a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100f2e:	0f be d0             	movsbl %al,%edx
f0100f31:	85 d2                	test   %edx,%edx
f0100f33:	74 23                	je     f0100f58 <vprintfmt+0x277>
f0100f35:	85 f6                	test   %esi,%esi
f0100f37:	78 a1                	js     f0100eda <vprintfmt+0x1f9>
f0100f39:	83 ee 01             	sub    $0x1,%esi
f0100f3c:	79 9c                	jns    f0100eda <vprintfmt+0x1f9>
f0100f3e:	89 df                	mov    %ebx,%edi
f0100f40:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f46:	eb 18                	jmp    f0100f60 <vprintfmt+0x27f>
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
					putch(' ', putdat);
f0100f48:	83 ec 08             	sub    $0x8,%esp
f0100f4b:	53                   	push   %ebx
f0100f4c:	6a 20                	push   $0x20
f0100f4e:	ff d6                	call   *%esi
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
f0100f50:	83 ef 01             	sub    $0x1,%edi
f0100f53:	83 c4 10             	add    $0x10,%esp
f0100f56:	eb 08                	jmp    f0100f60 <vprintfmt+0x27f>
f0100f58:	89 df                	mov    %ebx,%edi
f0100f5a:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f60:	85 ff                	test   %edi,%edi
f0100f62:	7f e4                	jg     f0100f48 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100f64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f67:	e9 9b fd ff ff       	jmp    f0100d07 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100f6c:	83 fa 01             	cmp    $0x1,%edx
f0100f6f:	7e 16                	jle    f0100f87 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
f0100f71:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f74:	8d 50 08             	lea    0x8(%eax),%edx
f0100f77:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f7a:	8b 50 04             	mov    0x4(%eax),%edx
f0100f7d:	8b 00                	mov    (%eax),%eax
f0100f7f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f82:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100f85:	eb 32                	jmp    f0100fb9 <vprintfmt+0x2d8>
	else if (lflag)
f0100f87:	85 d2                	test   %edx,%edx
f0100f89:	74 18                	je     f0100fa3 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
f0100f8b:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f8e:	8d 50 04             	lea    0x4(%eax),%edx
f0100f91:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f94:	8b 00                	mov    (%eax),%eax
f0100f96:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f99:	89 c1                	mov    %eax,%ecx
f0100f9b:	c1 f9 1f             	sar    $0x1f,%ecx
f0100f9e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100fa1:	eb 16                	jmp    f0100fb9 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
f0100fa3:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fa6:	8d 50 04             	lea    0x4(%eax),%edx
f0100fa9:	89 55 14             	mov    %edx,0x14(%ebp)
f0100fac:	8b 00                	mov    (%eax),%eax
f0100fae:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100fb1:	89 c1                	mov    %eax,%ecx
f0100fb3:	c1 f9 1f             	sar    $0x1f,%ecx
f0100fb6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(' ', putdat);
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
f0100fb9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100fbc:	8b 55 dc             	mov    -0x24(%ebp),%edx
				if ((long long) num < 0) {
					putch('-', putdat);
					num = -(long long) num;
				}
				base = 10;
f0100fbf:	b9 0a 00 00 00       	mov    $0xa,%ecx
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
				if ((long long) num < 0) {
f0100fc4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100fc8:	79 74                	jns    f010103e <vprintfmt+0x35d>
					putch('-', putdat);
f0100fca:	83 ec 08             	sub    $0x8,%esp
f0100fcd:	53                   	push   %ebx
f0100fce:	6a 2d                	push   $0x2d
f0100fd0:	ff d6                	call   *%esi
					num = -(long long) num;
f0100fd2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100fd5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100fd8:	f7 d8                	neg    %eax
f0100fda:	83 d2 00             	adc    $0x0,%edx
f0100fdd:	f7 da                	neg    %edx
f0100fdf:	83 c4 10             	add    $0x10,%esp
				}
				base = 10;
f0100fe2:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0100fe7:	eb 55                	jmp    f010103e <vprintfmt+0x35d>
				goto number;

			// unsigned decimal
			case 'u':
				num = getuint(&ap, lflag);
f0100fe9:	8d 45 14             	lea    0x14(%ebp),%eax
f0100fec:	e8 7c fc ff ff       	call   f0100c6d <getuint>
				base = 10;
f0100ff1:	b9 0a 00 00 00       	mov    $0xa,%ecx
				goto number;
f0100ff6:	eb 46                	jmp    f010103e <vprintfmt+0x35d>
				// Replace this with your code.
				/*putch('X', putdat);
				putch('X', putdat);
				putch('X', putdat);*/
				
				num = getuint(&ap, lflag);
f0100ff8:	8d 45 14             	lea    0x14(%ebp),%eax
f0100ffb:	e8 6d fc ff ff       	call   f0100c6d <getuint>
				base = 8;
f0101000:	b9 08 00 00 00       	mov    $0x8,%ecx
				goto number;
f0101005:	eb 37                	jmp    f010103e <vprintfmt+0x35d>

			// pointer
			case 'p':
				putch('0', putdat);
f0101007:	83 ec 08             	sub    $0x8,%esp
f010100a:	53                   	push   %ebx
f010100b:	6a 30                	push   $0x30
f010100d:	ff d6                	call   *%esi
				putch('x', putdat);
f010100f:	83 c4 08             	add    $0x8,%esp
f0101012:	53                   	push   %ebx
f0101013:	6a 78                	push   $0x78
f0101015:	ff d6                	call   *%esi
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
f0101017:	8b 45 14             	mov    0x14(%ebp),%eax
f010101a:	8d 50 04             	lea    0x4(%eax),%edx
f010101d:	89 55 14             	mov    %edx,0x14(%ebp)

			// pointer
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
f0101020:	8b 00                	mov    (%eax),%eax
f0101022:	ba 00 00 00 00       	mov    $0x0,%edx
					(uintptr_t) va_arg(ap, void *);
				base = 16;
				goto number;
f0101027:	83 c4 10             	add    $0x10,%esp
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
				base = 16;
f010102a:	b9 10 00 00 00       	mov    $0x10,%ecx
				goto number;
f010102f:	eb 0d                	jmp    f010103e <vprintfmt+0x35d>

			// (unsigned) hexadecimal
			case 'x':
				num = getuint(&ap, lflag);
f0101031:	8d 45 14             	lea    0x14(%ebp),%eax
f0101034:	e8 34 fc ff ff       	call   f0100c6d <getuint>
				base = 16;
f0101039:	b9 10 00 00 00       	mov    $0x10,%ecx
			number:
				printnum(putch, putdat, num, base, width, padc);
f010103e:	83 ec 0c             	sub    $0xc,%esp
f0101041:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101045:	57                   	push   %edi
f0101046:	ff 75 e0             	pushl  -0x20(%ebp)
f0101049:	51                   	push   %ecx
f010104a:	52                   	push   %edx
f010104b:	50                   	push   %eax
f010104c:	89 da                	mov    %ebx,%edx
f010104e:	89 f0                	mov    %esi,%eax
f0101050:	e8 6e fb ff ff       	call   f0100bc3 <printnum>
				break;
f0101055:	83 c4 20             	add    $0x20,%esp
f0101058:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010105b:	e9 a7 fc ff ff       	jmp    f0100d07 <vprintfmt+0x26>

			// escaped '%' character
			case '%':
				putch(ch, putdat);
f0101060:	83 ec 08             	sub    $0x8,%esp
f0101063:	53                   	push   %ebx
f0101064:	51                   	push   %ecx
f0101065:	ff d6                	call   *%esi
				break;
f0101067:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f010106a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				break;

			// escaped '%' character
			case '%':
				putch(ch, putdat);
				break;
f010106d:	e9 95 fc ff ff       	jmp    f0100d07 <vprintfmt+0x26>

			// unrecognized escape sequence - just print it literally
			default:
				putch('%', putdat);
f0101072:	83 ec 08             	sub    $0x8,%esp
f0101075:	53                   	push   %ebx
f0101076:	6a 25                	push   $0x25
f0101078:	ff d6                	call   *%esi
				for (fmt--; fmt[-1] != '%'; fmt--)
f010107a:	83 c4 10             	add    $0x10,%esp
f010107d:	eb 03                	jmp    f0101082 <vprintfmt+0x3a1>
f010107f:	83 ef 01             	sub    $0x1,%edi
f0101082:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0101086:	75 f7                	jne    f010107f <vprintfmt+0x39e>
f0101088:	e9 7a fc ff ff       	jmp    f0100d07 <vprintfmt+0x26>
					/* do nothing */;
				break;
		}
	}
}
f010108d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101090:	5b                   	pop    %ebx
f0101091:	5e                   	pop    %esi
f0101092:	5f                   	pop    %edi
f0101093:	5d                   	pop    %ebp
f0101094:	c3                   	ret    

f0101095 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101095:	55                   	push   %ebp
f0101096:	89 e5                	mov    %esp,%ebp
f0101098:	83 ec 18             	sub    $0x18,%esp
f010109b:	8b 45 08             	mov    0x8(%ebp),%eax
f010109e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01010a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01010a4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01010a8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01010ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01010b2:	85 c0                	test   %eax,%eax
f01010b4:	74 26                	je     f01010dc <vsnprintf+0x47>
f01010b6:	85 d2                	test   %edx,%edx
f01010b8:	7e 22                	jle    f01010dc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01010ba:	ff 75 14             	pushl  0x14(%ebp)
f01010bd:	ff 75 10             	pushl  0x10(%ebp)
f01010c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01010c3:	50                   	push   %eax
f01010c4:	68 a7 0c 10 f0       	push   $0xf0100ca7
f01010c9:	e8 13 fc ff ff       	call   f0100ce1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01010ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01010d1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01010d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01010d7:	83 c4 10             	add    $0x10,%esp
f01010da:	eb 05                	jmp    f01010e1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01010dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01010e1:	c9                   	leave  
f01010e2:	c3                   	ret    

f01010e3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01010e3:	55                   	push   %ebp
f01010e4:	89 e5                	mov    %esp,%ebp
f01010e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01010e9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01010ec:	50                   	push   %eax
f01010ed:	ff 75 10             	pushl  0x10(%ebp)
f01010f0:	ff 75 0c             	pushl  0xc(%ebp)
f01010f3:	ff 75 08             	pushl  0x8(%ebp)
f01010f6:	e8 9a ff ff ff       	call   f0101095 <vsnprintf>
	va_end(ap);

	return rc;
}
f01010fb:	c9                   	leave  
f01010fc:	c3                   	ret    

f01010fd <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01010fd:	55                   	push   %ebp
f01010fe:	89 e5                	mov    %esp,%ebp
f0101100:	57                   	push   %edi
f0101101:	56                   	push   %esi
f0101102:	53                   	push   %ebx
f0101103:	83 ec 0c             	sub    $0xc,%esp
f0101106:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101109:	85 c0                	test   %eax,%eax
f010110b:	74 11                	je     f010111e <readline+0x21>
		cprintf("%s", prompt);
f010110d:	83 ec 08             	sub    $0x8,%esp
f0101110:	50                   	push   %eax
f0101111:	68 82 1d 10 f0       	push   $0xf0101d82
f0101116:	e8 bb f7 ff ff       	call   f01008d6 <cprintf>
f010111b:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010111e:	83 ec 0c             	sub    $0xc,%esp
f0101121:	6a 00                	push   $0x0
f0101123:	e8 34 f5 ff ff       	call   f010065c <iscons>
f0101128:	89 c7                	mov    %eax,%edi
f010112a:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010112d:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101132:	e8 14 f5 ff ff       	call   f010064b <getchar>
f0101137:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101139:	85 c0                	test   %eax,%eax
f010113b:	79 18                	jns    f0101155 <readline+0x58>
			cprintf("read error: %e\n", c);
f010113d:	83 ec 08             	sub    $0x8,%esp
f0101140:	50                   	push   %eax
f0101141:	68 80 1f 10 f0       	push   $0xf0101f80
f0101146:	e8 8b f7 ff ff       	call   f01008d6 <cprintf>
			return NULL;
f010114b:	83 c4 10             	add    $0x10,%esp
f010114e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101153:	eb 79                	jmp    f01011ce <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101155:	83 f8 7f             	cmp    $0x7f,%eax
f0101158:	0f 94 c2             	sete   %dl
f010115b:	83 f8 08             	cmp    $0x8,%eax
f010115e:	0f 94 c0             	sete   %al
f0101161:	08 c2                	or     %al,%dl
f0101163:	74 1a                	je     f010117f <readline+0x82>
f0101165:	85 f6                	test   %esi,%esi
f0101167:	7e 16                	jle    f010117f <readline+0x82>
			if (echoing)
f0101169:	85 ff                	test   %edi,%edi
f010116b:	74 0d                	je     f010117a <readline+0x7d>
				cputchar('\b');
f010116d:	83 ec 0c             	sub    $0xc,%esp
f0101170:	6a 08                	push   $0x8
f0101172:	e8 c4 f4 ff ff       	call   f010063b <cputchar>
f0101177:	83 c4 10             	add    $0x10,%esp
			i--;
f010117a:	83 ee 01             	sub    $0x1,%esi
f010117d:	eb b3                	jmp    f0101132 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010117f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101185:	7f 20                	jg     f01011a7 <readline+0xaa>
f0101187:	83 fb 1f             	cmp    $0x1f,%ebx
f010118a:	7e 1b                	jle    f01011a7 <readline+0xaa>
			if (echoing)
f010118c:	85 ff                	test   %edi,%edi
f010118e:	74 0c                	je     f010119c <readline+0x9f>
				cputchar(c);
f0101190:	83 ec 0c             	sub    $0xc,%esp
f0101193:	53                   	push   %ebx
f0101194:	e8 a2 f4 ff ff       	call   f010063b <cputchar>
f0101199:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010119c:	88 9e 80 25 11 f0    	mov    %bl,-0xfeeda80(%esi)
f01011a2:	8d 76 01             	lea    0x1(%esi),%esi
f01011a5:	eb 8b                	jmp    f0101132 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01011a7:	83 fb 0d             	cmp    $0xd,%ebx
f01011aa:	74 05                	je     f01011b1 <readline+0xb4>
f01011ac:	83 fb 0a             	cmp    $0xa,%ebx
f01011af:	75 81                	jne    f0101132 <readline+0x35>
			if (echoing)
f01011b1:	85 ff                	test   %edi,%edi
f01011b3:	74 0d                	je     f01011c2 <readline+0xc5>
				cputchar('\n');
f01011b5:	83 ec 0c             	sub    $0xc,%esp
f01011b8:	6a 0a                	push   $0xa
f01011ba:	e8 7c f4 ff ff       	call   f010063b <cputchar>
f01011bf:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01011c2:	c6 86 80 25 11 f0 00 	movb   $0x0,-0xfeeda80(%esi)
			return buf;
f01011c9:	b8 80 25 11 f0       	mov    $0xf0112580,%eax
		}
	}
}
f01011ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011d1:	5b                   	pop    %ebx
f01011d2:	5e                   	pop    %esi
f01011d3:	5f                   	pop    %edi
f01011d4:	5d                   	pop    %ebp
f01011d5:	c3                   	ret    

f01011d6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01011d6:	55                   	push   %ebp
f01011d7:	89 e5                	mov    %esp,%ebp
f01011d9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01011dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01011e1:	eb 03                	jmp    f01011e6 <strlen+0x10>
		n++;
f01011e3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01011e6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01011ea:	75 f7                	jne    f01011e3 <strlen+0xd>
		n++;
	return n;
}
f01011ec:	5d                   	pop    %ebp
f01011ed:	c3                   	ret    

f01011ee <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01011ee:	55                   	push   %ebp
f01011ef:	89 e5                	mov    %esp,%ebp
f01011f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01011f4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01011f7:	ba 00 00 00 00       	mov    $0x0,%edx
f01011fc:	eb 03                	jmp    f0101201 <strnlen+0x13>
		n++;
f01011fe:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101201:	39 c2                	cmp    %eax,%edx
f0101203:	74 08                	je     f010120d <strnlen+0x1f>
f0101205:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0101209:	75 f3                	jne    f01011fe <strnlen+0x10>
f010120b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010120d:	5d                   	pop    %ebp
f010120e:	c3                   	ret    

f010120f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010120f:	55                   	push   %ebp
f0101210:	89 e5                	mov    %esp,%ebp
f0101212:	53                   	push   %ebx
f0101213:	8b 45 08             	mov    0x8(%ebp),%eax
f0101216:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101219:	89 c2                	mov    %eax,%edx
f010121b:	83 c2 01             	add    $0x1,%edx
f010121e:	83 c1 01             	add    $0x1,%ecx
f0101221:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101225:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101228:	84 db                	test   %bl,%bl
f010122a:	75 ef                	jne    f010121b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010122c:	5b                   	pop    %ebx
f010122d:	5d                   	pop    %ebp
f010122e:	c3                   	ret    

f010122f <strcat>:

char *
strcat(char *dst, const char *src)
{
f010122f:	55                   	push   %ebp
f0101230:	89 e5                	mov    %esp,%ebp
f0101232:	53                   	push   %ebx
f0101233:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101236:	53                   	push   %ebx
f0101237:	e8 9a ff ff ff       	call   f01011d6 <strlen>
f010123c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010123f:	ff 75 0c             	pushl  0xc(%ebp)
f0101242:	01 d8                	add    %ebx,%eax
f0101244:	50                   	push   %eax
f0101245:	e8 c5 ff ff ff       	call   f010120f <strcpy>
	return dst;
}
f010124a:	89 d8                	mov    %ebx,%eax
f010124c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010124f:	c9                   	leave  
f0101250:	c3                   	ret    

f0101251 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101251:	55                   	push   %ebp
f0101252:	89 e5                	mov    %esp,%ebp
f0101254:	56                   	push   %esi
f0101255:	53                   	push   %ebx
f0101256:	8b 75 08             	mov    0x8(%ebp),%esi
f0101259:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010125c:	89 f3                	mov    %esi,%ebx
f010125e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101261:	89 f2                	mov    %esi,%edx
f0101263:	eb 0f                	jmp    f0101274 <strncpy+0x23>
		*dst++ = *src;
f0101265:	83 c2 01             	add    $0x1,%edx
f0101268:	0f b6 01             	movzbl (%ecx),%eax
f010126b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010126e:	80 39 01             	cmpb   $0x1,(%ecx)
f0101271:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101274:	39 da                	cmp    %ebx,%edx
f0101276:	75 ed                	jne    f0101265 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101278:	89 f0                	mov    %esi,%eax
f010127a:	5b                   	pop    %ebx
f010127b:	5e                   	pop    %esi
f010127c:	5d                   	pop    %ebp
f010127d:	c3                   	ret    

f010127e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010127e:	55                   	push   %ebp
f010127f:	89 e5                	mov    %esp,%ebp
f0101281:	56                   	push   %esi
f0101282:	53                   	push   %ebx
f0101283:	8b 75 08             	mov    0x8(%ebp),%esi
f0101286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101289:	8b 55 10             	mov    0x10(%ebp),%edx
f010128c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010128e:	85 d2                	test   %edx,%edx
f0101290:	74 21                	je     f01012b3 <strlcpy+0x35>
f0101292:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101296:	89 f2                	mov    %esi,%edx
f0101298:	eb 09                	jmp    f01012a3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010129a:	83 c2 01             	add    $0x1,%edx
f010129d:	83 c1 01             	add    $0x1,%ecx
f01012a0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01012a3:	39 c2                	cmp    %eax,%edx
f01012a5:	74 09                	je     f01012b0 <strlcpy+0x32>
f01012a7:	0f b6 19             	movzbl (%ecx),%ebx
f01012aa:	84 db                	test   %bl,%bl
f01012ac:	75 ec                	jne    f010129a <strlcpy+0x1c>
f01012ae:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01012b0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01012b3:	29 f0                	sub    %esi,%eax
}
f01012b5:	5b                   	pop    %ebx
f01012b6:	5e                   	pop    %esi
f01012b7:	5d                   	pop    %ebp
f01012b8:	c3                   	ret    

f01012b9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01012b9:	55                   	push   %ebp
f01012ba:	89 e5                	mov    %esp,%ebp
f01012bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01012bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01012c2:	eb 06                	jmp    f01012ca <strcmp+0x11>
		p++, q++;
f01012c4:	83 c1 01             	add    $0x1,%ecx
f01012c7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01012ca:	0f b6 01             	movzbl (%ecx),%eax
f01012cd:	84 c0                	test   %al,%al
f01012cf:	74 04                	je     f01012d5 <strcmp+0x1c>
f01012d1:	3a 02                	cmp    (%edx),%al
f01012d3:	74 ef                	je     f01012c4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01012d5:	0f b6 c0             	movzbl %al,%eax
f01012d8:	0f b6 12             	movzbl (%edx),%edx
f01012db:	29 d0                	sub    %edx,%eax
}
f01012dd:	5d                   	pop    %ebp
f01012de:	c3                   	ret    

f01012df <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01012df:	55                   	push   %ebp
f01012e0:	89 e5                	mov    %esp,%ebp
f01012e2:	53                   	push   %ebx
f01012e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01012e6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01012e9:	89 c3                	mov    %eax,%ebx
f01012eb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01012ee:	eb 06                	jmp    f01012f6 <strncmp+0x17>
		n--, p++, q++;
f01012f0:	83 c0 01             	add    $0x1,%eax
f01012f3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01012f6:	39 d8                	cmp    %ebx,%eax
f01012f8:	74 15                	je     f010130f <strncmp+0x30>
f01012fa:	0f b6 08             	movzbl (%eax),%ecx
f01012fd:	84 c9                	test   %cl,%cl
f01012ff:	74 04                	je     f0101305 <strncmp+0x26>
f0101301:	3a 0a                	cmp    (%edx),%cl
f0101303:	74 eb                	je     f01012f0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101305:	0f b6 00             	movzbl (%eax),%eax
f0101308:	0f b6 12             	movzbl (%edx),%edx
f010130b:	29 d0                	sub    %edx,%eax
f010130d:	eb 05                	jmp    f0101314 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010130f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101314:	5b                   	pop    %ebx
f0101315:	5d                   	pop    %ebp
f0101316:	c3                   	ret    

f0101317 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101317:	55                   	push   %ebp
f0101318:	89 e5                	mov    %esp,%ebp
f010131a:	8b 45 08             	mov    0x8(%ebp),%eax
f010131d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101321:	eb 07                	jmp    f010132a <strchr+0x13>
		if (*s == c)
f0101323:	38 ca                	cmp    %cl,%dl
f0101325:	74 0f                	je     f0101336 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101327:	83 c0 01             	add    $0x1,%eax
f010132a:	0f b6 10             	movzbl (%eax),%edx
f010132d:	84 d2                	test   %dl,%dl
f010132f:	75 f2                	jne    f0101323 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101331:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101336:	5d                   	pop    %ebp
f0101337:	c3                   	ret    

f0101338 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101338:	55                   	push   %ebp
f0101339:	89 e5                	mov    %esp,%ebp
f010133b:	8b 45 08             	mov    0x8(%ebp),%eax
f010133e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101342:	eb 03                	jmp    f0101347 <strfind+0xf>
f0101344:	83 c0 01             	add    $0x1,%eax
f0101347:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010134a:	84 d2                	test   %dl,%dl
f010134c:	74 04                	je     f0101352 <strfind+0x1a>
f010134e:	38 ca                	cmp    %cl,%dl
f0101350:	75 f2                	jne    f0101344 <strfind+0xc>
			break;
	return (char *) s;
}
f0101352:	5d                   	pop    %ebp
f0101353:	c3                   	ret    

f0101354 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101354:	55                   	push   %ebp
f0101355:	89 e5                	mov    %esp,%ebp
f0101357:	57                   	push   %edi
f0101358:	56                   	push   %esi
f0101359:	53                   	push   %ebx
f010135a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010135d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101360:	85 c9                	test   %ecx,%ecx
f0101362:	74 36                	je     f010139a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101364:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010136a:	75 28                	jne    f0101394 <memset+0x40>
f010136c:	f6 c1 03             	test   $0x3,%cl
f010136f:	75 23                	jne    f0101394 <memset+0x40>
		c &= 0xFF;
f0101371:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101375:	89 d3                	mov    %edx,%ebx
f0101377:	c1 e3 08             	shl    $0x8,%ebx
f010137a:	89 d6                	mov    %edx,%esi
f010137c:	c1 e6 18             	shl    $0x18,%esi
f010137f:	89 d0                	mov    %edx,%eax
f0101381:	c1 e0 10             	shl    $0x10,%eax
f0101384:	09 f0                	or     %esi,%eax
f0101386:	09 c2                	or     %eax,%edx
f0101388:	89 d0                	mov    %edx,%eax
f010138a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010138c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f010138f:	fc                   	cld    
f0101390:	f3 ab                	rep stos %eax,%es:(%edi)
f0101392:	eb 06                	jmp    f010139a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101394:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101397:	fc                   	cld    
f0101398:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010139a:	89 f8                	mov    %edi,%eax
f010139c:	5b                   	pop    %ebx
f010139d:	5e                   	pop    %esi
f010139e:	5f                   	pop    %edi
f010139f:	5d                   	pop    %ebp
f01013a0:	c3                   	ret    

f01013a1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01013a1:	55                   	push   %ebp
f01013a2:	89 e5                	mov    %esp,%ebp
f01013a4:	57                   	push   %edi
f01013a5:	56                   	push   %esi
f01013a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01013a9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01013ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01013af:	39 c6                	cmp    %eax,%esi
f01013b1:	73 35                	jae    f01013e8 <memmove+0x47>
f01013b3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01013b6:	39 d0                	cmp    %edx,%eax
f01013b8:	73 2e                	jae    f01013e8 <memmove+0x47>
		s += n;
		d += n;
f01013ba:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f01013bd:	89 d6                	mov    %edx,%esi
f01013bf:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01013c1:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01013c7:	75 13                	jne    f01013dc <memmove+0x3b>
f01013c9:	f6 c1 03             	test   $0x3,%cl
f01013cc:	75 0e                	jne    f01013dc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01013ce:	83 ef 04             	sub    $0x4,%edi
f01013d1:	8d 72 fc             	lea    -0x4(%edx),%esi
f01013d4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01013d7:	fd                   	std    
f01013d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01013da:	eb 09                	jmp    f01013e5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01013dc:	83 ef 01             	sub    $0x1,%edi
f01013df:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01013e2:	fd                   	std    
f01013e3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01013e5:	fc                   	cld    
f01013e6:	eb 1d                	jmp    f0101405 <memmove+0x64>
f01013e8:	89 f2                	mov    %esi,%edx
f01013ea:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01013ec:	f6 c2 03             	test   $0x3,%dl
f01013ef:	75 0f                	jne    f0101400 <memmove+0x5f>
f01013f1:	f6 c1 03             	test   $0x3,%cl
f01013f4:	75 0a                	jne    f0101400 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01013f6:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01013f9:	89 c7                	mov    %eax,%edi
f01013fb:	fc                   	cld    
f01013fc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01013fe:	eb 05                	jmp    f0101405 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101400:	89 c7                	mov    %eax,%edi
f0101402:	fc                   	cld    
f0101403:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101405:	5e                   	pop    %esi
f0101406:	5f                   	pop    %edi
f0101407:	5d                   	pop    %ebp
f0101408:	c3                   	ret    

f0101409 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101409:	55                   	push   %ebp
f010140a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010140c:	ff 75 10             	pushl  0x10(%ebp)
f010140f:	ff 75 0c             	pushl  0xc(%ebp)
f0101412:	ff 75 08             	pushl  0x8(%ebp)
f0101415:	e8 87 ff ff ff       	call   f01013a1 <memmove>
}
f010141a:	c9                   	leave  
f010141b:	c3                   	ret    

f010141c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010141c:	55                   	push   %ebp
f010141d:	89 e5                	mov    %esp,%ebp
f010141f:	56                   	push   %esi
f0101420:	53                   	push   %ebx
f0101421:	8b 45 08             	mov    0x8(%ebp),%eax
f0101424:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101427:	89 c6                	mov    %eax,%esi
f0101429:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010142c:	eb 1a                	jmp    f0101448 <memcmp+0x2c>
		if (*s1 != *s2)
f010142e:	0f b6 08             	movzbl (%eax),%ecx
f0101431:	0f b6 1a             	movzbl (%edx),%ebx
f0101434:	38 d9                	cmp    %bl,%cl
f0101436:	74 0a                	je     f0101442 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0101438:	0f b6 c1             	movzbl %cl,%eax
f010143b:	0f b6 db             	movzbl %bl,%ebx
f010143e:	29 d8                	sub    %ebx,%eax
f0101440:	eb 0f                	jmp    f0101451 <memcmp+0x35>
		s1++, s2++;
f0101442:	83 c0 01             	add    $0x1,%eax
f0101445:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101448:	39 f0                	cmp    %esi,%eax
f010144a:	75 e2                	jne    f010142e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010144c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101451:	5b                   	pop    %ebx
f0101452:	5e                   	pop    %esi
f0101453:	5d                   	pop    %ebp
f0101454:	c3                   	ret    

f0101455 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101455:	55                   	push   %ebp
f0101456:	89 e5                	mov    %esp,%ebp
f0101458:	8b 45 08             	mov    0x8(%ebp),%eax
f010145b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010145e:	89 c2                	mov    %eax,%edx
f0101460:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101463:	eb 07                	jmp    f010146c <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101465:	38 08                	cmp    %cl,(%eax)
f0101467:	74 07                	je     f0101470 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101469:	83 c0 01             	add    $0x1,%eax
f010146c:	39 d0                	cmp    %edx,%eax
f010146e:	72 f5                	jb     f0101465 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101470:	5d                   	pop    %ebp
f0101471:	c3                   	ret    

f0101472 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101472:	55                   	push   %ebp
f0101473:	89 e5                	mov    %esp,%ebp
f0101475:	57                   	push   %edi
f0101476:	56                   	push   %esi
f0101477:	53                   	push   %ebx
f0101478:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010147b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010147e:	eb 03                	jmp    f0101483 <strtol+0x11>
		s++;
f0101480:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101483:	0f b6 01             	movzbl (%ecx),%eax
f0101486:	3c 09                	cmp    $0x9,%al
f0101488:	74 f6                	je     f0101480 <strtol+0xe>
f010148a:	3c 20                	cmp    $0x20,%al
f010148c:	74 f2                	je     f0101480 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010148e:	3c 2b                	cmp    $0x2b,%al
f0101490:	75 0a                	jne    f010149c <strtol+0x2a>
		s++;
f0101492:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101495:	bf 00 00 00 00       	mov    $0x0,%edi
f010149a:	eb 10                	jmp    f01014ac <strtol+0x3a>
f010149c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01014a1:	3c 2d                	cmp    $0x2d,%al
f01014a3:	75 07                	jne    f01014ac <strtol+0x3a>
		s++, neg = 1;
f01014a5:	8d 49 01             	lea    0x1(%ecx),%ecx
f01014a8:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01014ac:	85 db                	test   %ebx,%ebx
f01014ae:	0f 94 c0             	sete   %al
f01014b1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01014b7:	75 19                	jne    f01014d2 <strtol+0x60>
f01014b9:	80 39 30             	cmpb   $0x30,(%ecx)
f01014bc:	75 14                	jne    f01014d2 <strtol+0x60>
f01014be:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01014c2:	0f 85 82 00 00 00    	jne    f010154a <strtol+0xd8>
		s += 2, base = 16;
f01014c8:	83 c1 02             	add    $0x2,%ecx
f01014cb:	bb 10 00 00 00       	mov    $0x10,%ebx
f01014d0:	eb 16                	jmp    f01014e8 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01014d2:	84 c0                	test   %al,%al
f01014d4:	74 12                	je     f01014e8 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01014d6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01014db:	80 39 30             	cmpb   $0x30,(%ecx)
f01014de:	75 08                	jne    f01014e8 <strtol+0x76>
		s++, base = 8;
f01014e0:	83 c1 01             	add    $0x1,%ecx
f01014e3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01014e8:	b8 00 00 00 00       	mov    $0x0,%eax
f01014ed:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01014f0:	0f b6 11             	movzbl (%ecx),%edx
f01014f3:	8d 72 d0             	lea    -0x30(%edx),%esi
f01014f6:	89 f3                	mov    %esi,%ebx
f01014f8:	80 fb 09             	cmp    $0x9,%bl
f01014fb:	77 08                	ja     f0101505 <strtol+0x93>
			dig = *s - '0';
f01014fd:	0f be d2             	movsbl %dl,%edx
f0101500:	83 ea 30             	sub    $0x30,%edx
f0101503:	eb 22                	jmp    f0101527 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
f0101505:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101508:	89 f3                	mov    %esi,%ebx
f010150a:	80 fb 19             	cmp    $0x19,%bl
f010150d:	77 08                	ja     f0101517 <strtol+0xa5>
			dig = *s - 'a' + 10;
f010150f:	0f be d2             	movsbl %dl,%edx
f0101512:	83 ea 57             	sub    $0x57,%edx
f0101515:	eb 10                	jmp    f0101527 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
f0101517:	8d 72 bf             	lea    -0x41(%edx),%esi
f010151a:	89 f3                	mov    %esi,%ebx
f010151c:	80 fb 19             	cmp    $0x19,%bl
f010151f:	77 16                	ja     f0101537 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0101521:	0f be d2             	movsbl %dl,%edx
f0101524:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0101527:	3b 55 10             	cmp    0x10(%ebp),%edx
f010152a:	7d 0f                	jge    f010153b <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
f010152c:	83 c1 01             	add    $0x1,%ecx
f010152f:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101533:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0101535:	eb b9                	jmp    f01014f0 <strtol+0x7e>
f0101537:	89 c2                	mov    %eax,%edx
f0101539:	eb 02                	jmp    f010153d <strtol+0xcb>
f010153b:	89 c2                	mov    %eax,%edx

	if (endptr)
f010153d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101541:	74 0d                	je     f0101550 <strtol+0xde>
		*endptr = (char *) s;
f0101543:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101546:	89 0e                	mov    %ecx,(%esi)
f0101548:	eb 06                	jmp    f0101550 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010154a:	84 c0                	test   %al,%al
f010154c:	75 92                	jne    f01014e0 <strtol+0x6e>
f010154e:	eb 98                	jmp    f01014e8 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0101550:	f7 da                	neg    %edx
f0101552:	85 ff                	test   %edi,%edi
f0101554:	0f 45 c2             	cmovne %edx,%eax
}
f0101557:	5b                   	pop    %ebx
f0101558:	5e                   	pop    %esi
f0101559:	5f                   	pop    %edi
f010155a:	5d                   	pop    %ebp
f010155b:	c3                   	ret    
f010155c:	66 90                	xchg   %ax,%ax
f010155e:	66 90                	xchg   %ax,%ax

f0101560 <__udivdi3>:
f0101560:	55                   	push   %ebp
f0101561:	57                   	push   %edi
f0101562:	56                   	push   %esi
f0101563:	83 ec 10             	sub    $0x10,%esp
f0101566:	8b 54 24 2c          	mov    0x2c(%esp),%edx
f010156a:	8b 7c 24 20          	mov    0x20(%esp),%edi
f010156e:	8b 74 24 24          	mov    0x24(%esp),%esi
f0101572:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0101576:	85 d2                	test   %edx,%edx
f0101578:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010157c:	89 34 24             	mov    %esi,(%esp)
f010157f:	89 c8                	mov    %ecx,%eax
f0101581:	75 35                	jne    f01015b8 <__udivdi3+0x58>
f0101583:	39 f1                	cmp    %esi,%ecx
f0101585:	0f 87 bd 00 00 00    	ja     f0101648 <__udivdi3+0xe8>
f010158b:	85 c9                	test   %ecx,%ecx
f010158d:	89 cd                	mov    %ecx,%ebp
f010158f:	75 0b                	jne    f010159c <__udivdi3+0x3c>
f0101591:	b8 01 00 00 00       	mov    $0x1,%eax
f0101596:	31 d2                	xor    %edx,%edx
f0101598:	f7 f1                	div    %ecx
f010159a:	89 c5                	mov    %eax,%ebp
f010159c:	89 f0                	mov    %esi,%eax
f010159e:	31 d2                	xor    %edx,%edx
f01015a0:	f7 f5                	div    %ebp
f01015a2:	89 c6                	mov    %eax,%esi
f01015a4:	89 f8                	mov    %edi,%eax
f01015a6:	f7 f5                	div    %ebp
f01015a8:	89 f2                	mov    %esi,%edx
f01015aa:	83 c4 10             	add    $0x10,%esp
f01015ad:	5e                   	pop    %esi
f01015ae:	5f                   	pop    %edi
f01015af:	5d                   	pop    %ebp
f01015b0:	c3                   	ret    
f01015b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01015b8:	3b 14 24             	cmp    (%esp),%edx
f01015bb:	77 7b                	ja     f0101638 <__udivdi3+0xd8>
f01015bd:	0f bd f2             	bsr    %edx,%esi
f01015c0:	83 f6 1f             	xor    $0x1f,%esi
f01015c3:	0f 84 97 00 00 00    	je     f0101660 <__udivdi3+0x100>
f01015c9:	bd 20 00 00 00       	mov    $0x20,%ebp
f01015ce:	89 d7                	mov    %edx,%edi
f01015d0:	89 f1                	mov    %esi,%ecx
f01015d2:	29 f5                	sub    %esi,%ebp
f01015d4:	d3 e7                	shl    %cl,%edi
f01015d6:	89 c2                	mov    %eax,%edx
f01015d8:	89 e9                	mov    %ebp,%ecx
f01015da:	d3 ea                	shr    %cl,%edx
f01015dc:	89 f1                	mov    %esi,%ecx
f01015de:	09 fa                	or     %edi,%edx
f01015e0:	8b 3c 24             	mov    (%esp),%edi
f01015e3:	d3 e0                	shl    %cl,%eax
f01015e5:	89 54 24 08          	mov    %edx,0x8(%esp)
f01015e9:	89 e9                	mov    %ebp,%ecx
f01015eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015ef:	8b 44 24 04          	mov    0x4(%esp),%eax
f01015f3:	89 fa                	mov    %edi,%edx
f01015f5:	d3 ea                	shr    %cl,%edx
f01015f7:	89 f1                	mov    %esi,%ecx
f01015f9:	d3 e7                	shl    %cl,%edi
f01015fb:	89 e9                	mov    %ebp,%ecx
f01015fd:	d3 e8                	shr    %cl,%eax
f01015ff:	09 c7                	or     %eax,%edi
f0101601:	89 f8                	mov    %edi,%eax
f0101603:	f7 74 24 08          	divl   0x8(%esp)
f0101607:	89 d5                	mov    %edx,%ebp
f0101609:	89 c7                	mov    %eax,%edi
f010160b:	f7 64 24 0c          	mull   0xc(%esp)
f010160f:	39 d5                	cmp    %edx,%ebp
f0101611:	89 14 24             	mov    %edx,(%esp)
f0101614:	72 11                	jb     f0101627 <__udivdi3+0xc7>
f0101616:	8b 54 24 04          	mov    0x4(%esp),%edx
f010161a:	89 f1                	mov    %esi,%ecx
f010161c:	d3 e2                	shl    %cl,%edx
f010161e:	39 c2                	cmp    %eax,%edx
f0101620:	73 5e                	jae    f0101680 <__udivdi3+0x120>
f0101622:	3b 2c 24             	cmp    (%esp),%ebp
f0101625:	75 59                	jne    f0101680 <__udivdi3+0x120>
f0101627:	8d 47 ff             	lea    -0x1(%edi),%eax
f010162a:	31 f6                	xor    %esi,%esi
f010162c:	89 f2                	mov    %esi,%edx
f010162e:	83 c4 10             	add    $0x10,%esp
f0101631:	5e                   	pop    %esi
f0101632:	5f                   	pop    %edi
f0101633:	5d                   	pop    %ebp
f0101634:	c3                   	ret    
f0101635:	8d 76 00             	lea    0x0(%esi),%esi
f0101638:	31 f6                	xor    %esi,%esi
f010163a:	31 c0                	xor    %eax,%eax
f010163c:	89 f2                	mov    %esi,%edx
f010163e:	83 c4 10             	add    $0x10,%esp
f0101641:	5e                   	pop    %esi
f0101642:	5f                   	pop    %edi
f0101643:	5d                   	pop    %ebp
f0101644:	c3                   	ret    
f0101645:	8d 76 00             	lea    0x0(%esi),%esi
f0101648:	89 f2                	mov    %esi,%edx
f010164a:	31 f6                	xor    %esi,%esi
f010164c:	89 f8                	mov    %edi,%eax
f010164e:	f7 f1                	div    %ecx
f0101650:	89 f2                	mov    %esi,%edx
f0101652:	83 c4 10             	add    $0x10,%esp
f0101655:	5e                   	pop    %esi
f0101656:	5f                   	pop    %edi
f0101657:	5d                   	pop    %ebp
f0101658:	c3                   	ret    
f0101659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101660:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0101664:	76 0b                	jbe    f0101671 <__udivdi3+0x111>
f0101666:	31 c0                	xor    %eax,%eax
f0101668:	3b 14 24             	cmp    (%esp),%edx
f010166b:	0f 83 37 ff ff ff    	jae    f01015a8 <__udivdi3+0x48>
f0101671:	b8 01 00 00 00       	mov    $0x1,%eax
f0101676:	e9 2d ff ff ff       	jmp    f01015a8 <__udivdi3+0x48>
f010167b:	90                   	nop
f010167c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101680:	89 f8                	mov    %edi,%eax
f0101682:	31 f6                	xor    %esi,%esi
f0101684:	e9 1f ff ff ff       	jmp    f01015a8 <__udivdi3+0x48>
f0101689:	66 90                	xchg   %ax,%ax
f010168b:	66 90                	xchg   %ax,%ax
f010168d:	66 90                	xchg   %ax,%ax
f010168f:	90                   	nop

f0101690 <__umoddi3>:
f0101690:	55                   	push   %ebp
f0101691:	57                   	push   %edi
f0101692:	56                   	push   %esi
f0101693:	83 ec 20             	sub    $0x20,%esp
f0101696:	8b 44 24 34          	mov    0x34(%esp),%eax
f010169a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010169e:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01016a2:	89 c6                	mov    %eax,%esi
f01016a4:	89 44 24 10          	mov    %eax,0x10(%esp)
f01016a8:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01016ac:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
f01016b0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01016b4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f01016b8:	89 74 24 18          	mov    %esi,0x18(%esp)
f01016bc:	85 c0                	test   %eax,%eax
f01016be:	89 c2                	mov    %eax,%edx
f01016c0:	75 1e                	jne    f01016e0 <__umoddi3+0x50>
f01016c2:	39 f7                	cmp    %esi,%edi
f01016c4:	76 52                	jbe    f0101718 <__umoddi3+0x88>
f01016c6:	89 c8                	mov    %ecx,%eax
f01016c8:	89 f2                	mov    %esi,%edx
f01016ca:	f7 f7                	div    %edi
f01016cc:	89 d0                	mov    %edx,%eax
f01016ce:	31 d2                	xor    %edx,%edx
f01016d0:	83 c4 20             	add    $0x20,%esp
f01016d3:	5e                   	pop    %esi
f01016d4:	5f                   	pop    %edi
f01016d5:	5d                   	pop    %ebp
f01016d6:	c3                   	ret    
f01016d7:	89 f6                	mov    %esi,%esi
f01016d9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01016e0:	39 f0                	cmp    %esi,%eax
f01016e2:	77 5c                	ja     f0101740 <__umoddi3+0xb0>
f01016e4:	0f bd e8             	bsr    %eax,%ebp
f01016e7:	83 f5 1f             	xor    $0x1f,%ebp
f01016ea:	75 64                	jne    f0101750 <__umoddi3+0xc0>
f01016ec:	8b 6c 24 14          	mov    0x14(%esp),%ebp
f01016f0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
f01016f4:	0f 86 f6 00 00 00    	jbe    f01017f0 <__umoddi3+0x160>
f01016fa:	3b 44 24 18          	cmp    0x18(%esp),%eax
f01016fe:	0f 82 ec 00 00 00    	jb     f01017f0 <__umoddi3+0x160>
f0101704:	8b 44 24 14          	mov    0x14(%esp),%eax
f0101708:	8b 54 24 18          	mov    0x18(%esp),%edx
f010170c:	83 c4 20             	add    $0x20,%esp
f010170f:	5e                   	pop    %esi
f0101710:	5f                   	pop    %edi
f0101711:	5d                   	pop    %ebp
f0101712:	c3                   	ret    
f0101713:	90                   	nop
f0101714:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101718:	85 ff                	test   %edi,%edi
f010171a:	89 fd                	mov    %edi,%ebp
f010171c:	75 0b                	jne    f0101729 <__umoddi3+0x99>
f010171e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101723:	31 d2                	xor    %edx,%edx
f0101725:	f7 f7                	div    %edi
f0101727:	89 c5                	mov    %eax,%ebp
f0101729:	8b 44 24 10          	mov    0x10(%esp),%eax
f010172d:	31 d2                	xor    %edx,%edx
f010172f:	f7 f5                	div    %ebp
f0101731:	89 c8                	mov    %ecx,%eax
f0101733:	f7 f5                	div    %ebp
f0101735:	eb 95                	jmp    f01016cc <__umoddi3+0x3c>
f0101737:	89 f6                	mov    %esi,%esi
f0101739:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0101740:	89 c8                	mov    %ecx,%eax
f0101742:	89 f2                	mov    %esi,%edx
f0101744:	83 c4 20             	add    $0x20,%esp
f0101747:	5e                   	pop    %esi
f0101748:	5f                   	pop    %edi
f0101749:	5d                   	pop    %ebp
f010174a:	c3                   	ret    
f010174b:	90                   	nop
f010174c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101750:	b8 20 00 00 00       	mov    $0x20,%eax
f0101755:	89 e9                	mov    %ebp,%ecx
f0101757:	29 e8                	sub    %ebp,%eax
f0101759:	d3 e2                	shl    %cl,%edx
f010175b:	89 c7                	mov    %eax,%edi
f010175d:	89 44 24 18          	mov    %eax,0x18(%esp)
f0101761:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0101765:	89 f9                	mov    %edi,%ecx
f0101767:	d3 e8                	shr    %cl,%eax
f0101769:	89 c1                	mov    %eax,%ecx
f010176b:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010176f:	09 d1                	or     %edx,%ecx
f0101771:	89 fa                	mov    %edi,%edx
f0101773:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0101777:	89 e9                	mov    %ebp,%ecx
f0101779:	d3 e0                	shl    %cl,%eax
f010177b:	89 f9                	mov    %edi,%ecx
f010177d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101781:	89 f0                	mov    %esi,%eax
f0101783:	d3 e8                	shr    %cl,%eax
f0101785:	89 e9                	mov    %ebp,%ecx
f0101787:	89 c7                	mov    %eax,%edi
f0101789:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f010178d:	d3 e6                	shl    %cl,%esi
f010178f:	89 d1                	mov    %edx,%ecx
f0101791:	89 fa                	mov    %edi,%edx
f0101793:	d3 e8                	shr    %cl,%eax
f0101795:	89 e9                	mov    %ebp,%ecx
f0101797:	09 f0                	or     %esi,%eax
f0101799:	8b 74 24 1c          	mov    0x1c(%esp),%esi
f010179d:	f7 74 24 10          	divl   0x10(%esp)
f01017a1:	d3 e6                	shl    %cl,%esi
f01017a3:	89 d1                	mov    %edx,%ecx
f01017a5:	f7 64 24 0c          	mull   0xc(%esp)
f01017a9:	39 d1                	cmp    %edx,%ecx
f01017ab:	89 74 24 14          	mov    %esi,0x14(%esp)
f01017af:	89 d7                	mov    %edx,%edi
f01017b1:	89 c6                	mov    %eax,%esi
f01017b3:	72 0a                	jb     f01017bf <__umoddi3+0x12f>
f01017b5:	39 44 24 14          	cmp    %eax,0x14(%esp)
f01017b9:	73 10                	jae    f01017cb <__umoddi3+0x13b>
f01017bb:	39 d1                	cmp    %edx,%ecx
f01017bd:	75 0c                	jne    f01017cb <__umoddi3+0x13b>
f01017bf:	89 d7                	mov    %edx,%edi
f01017c1:	89 c6                	mov    %eax,%esi
f01017c3:	2b 74 24 0c          	sub    0xc(%esp),%esi
f01017c7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
f01017cb:	89 ca                	mov    %ecx,%edx
f01017cd:	89 e9                	mov    %ebp,%ecx
f01017cf:	8b 44 24 14          	mov    0x14(%esp),%eax
f01017d3:	29 f0                	sub    %esi,%eax
f01017d5:	19 fa                	sbb    %edi,%edx
f01017d7:	d3 e8                	shr    %cl,%eax
f01017d9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
f01017de:	89 d7                	mov    %edx,%edi
f01017e0:	d3 e7                	shl    %cl,%edi
f01017e2:	89 e9                	mov    %ebp,%ecx
f01017e4:	09 f8                	or     %edi,%eax
f01017e6:	d3 ea                	shr    %cl,%edx
f01017e8:	83 c4 20             	add    $0x20,%esp
f01017eb:	5e                   	pop    %esi
f01017ec:	5f                   	pop    %edi
f01017ed:	5d                   	pop    %ebp
f01017ee:	c3                   	ret    
f01017ef:	90                   	nop
f01017f0:	8b 74 24 10          	mov    0x10(%esp),%esi
f01017f4:	29 f9                	sub    %edi,%ecx
f01017f6:	19 c6                	sbb    %eax,%esi
f01017f8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f01017fc:	89 74 24 18          	mov    %esi,0x18(%esp)
f0101800:	e9 ff fe ff ff       	jmp    f0101704 <__umoddi3+0x74>
