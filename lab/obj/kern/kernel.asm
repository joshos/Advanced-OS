
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
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
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
	movl	$0x0,%ebp			# nuke frame pointer
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
f010004b:	68 00 19 10 f0       	push   $0xf0101900
f0100050:	e8 06 09 00 00       	call   f010095b <cprintf>
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
f0100076:	e8 f8 06 00 00       	call   f0100773 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 1c 19 10 f0       	push   $0xf010191c
f0100087:	e8 cf 08 00 00       	call   f010095b <cprintf>
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
f01000ac:	e8 95 13 00 00       	call   f0101446 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 9a 04 00 00       	call   f0100550 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 37 19 10 f0       	push   $0xf0101937
f01000c3:	e8 93 08 00 00       	call   f010095b <cprintf>

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
f01000dc:	e8 0c 07 00 00       	call   f01007ed <monitor>
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
	asm volatile("cli; cld");
f01000fd:	fa                   	cli    
f01000fe:	fc                   	cld    

	va_start(ap, fmt);
f01000ff:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100102:	83 ec 04             	sub    $0x4,%esp
f0100105:	ff 75 0c             	pushl  0xc(%ebp)
f0100108:	ff 75 08             	pushl  0x8(%ebp)
f010010b:	68 52 19 10 f0       	push   $0xf0101952
f0100110:	e8 46 08 00 00       	call   f010095b <cprintf>
	vcprintf(fmt, ap);
f0100115:	83 c4 08             	add    $0x8,%esp
f0100118:	53                   	push   %ebx
f0100119:	56                   	push   %esi
f010011a:	e8 16 08 00 00       	call   f0100935 <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 8e 19 10 f0 	movl   $0xf010198e,(%esp)
f0100126:	e8 30 08 00 00       	call   f010095b <cprintf>
	va_end(ap);
f010012b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	83 ec 0c             	sub    $0xc,%esp
f0100131:	6a 00                	push   $0x0
f0100133:	e8 b5 06 00 00       	call   f01007ed <monitor>
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
f010014d:	68 6a 19 10 f0       	push   $0xf010196a
f0100152:	e8 04 08 00 00       	call   f010095b <cprintf>
	vcprintf(fmt, ap);
f0100157:	83 c4 08             	add    $0x8,%esp
f010015a:	53                   	push   %ebx
f010015b:	ff 75 10             	pushl  0x10(%ebp)
f010015e:	e8 d2 07 00 00       	call   f0100935 <vcprintf>
	cprintf("\n");
f0100163:	c7 04 24 8e 19 10 f0 	movl   $0xf010198e,(%esp)
f010016a:	e8 ec 07 00 00       	call   f010095b <cprintf>
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

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
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
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01001dd:	a8 01                	test   $0x1,%al
f01001df:	0f 84 f8 00 00 00    	je     f01002dd <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01001e5:	a8 20                	test   $0x20,%al
f01001e7:	0f 85 f6 00 00 00    	jne    f01002e3 <kbd_proc_data+0x10c>
f01001ed:	b2 60                	mov    $0x60,%dl
f01001ef:	ec                   	in     (%dx),%al
f01001f0:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001f2:	3c e0                	cmp    $0xe0,%al
f01001f4:	75 0d                	jne    f0100203 <kbd_proc_data+0x2c>
		// E0 escape character
		shift |= E0ESC;
f01001f6:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f01001fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100202:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100203:	55                   	push   %ebp
f0100204:	89 e5                	mov    %esp,%ebp
f0100206:	53                   	push   %ebx
f0100207:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010020a:	84 c0                	test   %al,%al
f010020c:	79 36                	jns    f0100244 <kbd_proc_data+0x6d>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010020e:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100214:	89 cb                	mov    %ecx,%ebx
f0100216:	83 e3 40             	and    $0x40,%ebx
f0100219:	83 e0 7f             	and    $0x7f,%eax
f010021c:	85 db                	test   %ebx,%ebx
f010021e:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100221:	0f b6 d2             	movzbl %dl,%edx
f0100224:	0f b6 82 00 1b 10 f0 	movzbl -0xfefe500(%edx),%eax
f010022b:	83 c8 40             	or     $0x40,%eax
f010022e:	0f b6 c0             	movzbl %al,%eax
f0100231:	f7 d0                	not    %eax
f0100233:	21 c8                	and    %ecx,%eax
f0100235:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f010023a:	b8 00 00 00 00       	mov    $0x0,%eax
f010023f:	e9 a7 00 00 00       	jmp    f01002eb <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100244:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010024a:	f6 c1 40             	test   $0x40,%cl
f010024d:	74 0e                	je     f010025d <kbd_proc_data+0x86>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010024f:	83 c8 80             	or     $0xffffff80,%eax
f0100252:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100254:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100257:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f010025d:	0f b6 c2             	movzbl %dl,%eax
f0100260:	0f b6 90 00 1b 10 f0 	movzbl -0xfefe500(%eax),%edx
f0100267:	0b 15 00 23 11 f0    	or     0xf0112300,%edx
	shift ^= togglecode[data];
f010026d:	0f b6 88 00 1a 10 f0 	movzbl -0xfefe600(%eax),%ecx
f0100274:	31 ca                	xor    %ecx,%edx
f0100276:	89 15 00 23 11 f0    	mov    %edx,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f010027c:	89 d1                	mov    %edx,%ecx
f010027e:	83 e1 03             	and    $0x3,%ecx
f0100281:	8b 0c 8d c0 19 10 f0 	mov    -0xfefe640(,%ecx,4),%ecx
f0100288:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
f010028c:	0f b6 d8             	movzbl %al,%ebx
	if (shift & CAPSLOCK) {
f010028f:	f6 c2 08             	test   $0x8,%dl
f0100292:	74 1b                	je     f01002af <kbd_proc_data+0xd8>
		if ('a' <= c && c <= 'z')
f0100294:	89 d8                	mov    %ebx,%eax
f0100296:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100299:	83 f9 19             	cmp    $0x19,%ecx
f010029c:	77 05                	ja     f01002a3 <kbd_proc_data+0xcc>
			c += 'A' - 'a';
f010029e:	83 eb 20             	sub    $0x20,%ebx
f01002a1:	eb 0c                	jmp    f01002af <kbd_proc_data+0xd8>
		else if ('A' <= c && c <= 'Z')
f01002a3:	83 e8 41             	sub    $0x41,%eax
			c += 'a' - 'A';
f01002a6:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002a9:	83 f8 19             	cmp    $0x19,%eax
f01002ac:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002af:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002b5:	75 32                	jne    f01002e9 <kbd_proc_data+0x112>
f01002b7:	f7 d2                	not    %edx
f01002b9:	f6 c2 06             	test   $0x6,%dl
f01002bc:	75 2b                	jne    f01002e9 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01002be:	83 ec 0c             	sub    $0xc,%esp
f01002c1:	68 84 19 10 f0       	push   $0xf0101984
f01002c6:	e8 90 06 00 00       	call   f010095b <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002cb:	ba 92 00 00 00       	mov    $0x92,%edx
f01002d0:	b8 03 00 00 00       	mov    $0x3,%eax
f01002d5:	ee                   	out    %al,(%dx)
f01002d6:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002d9:	89 d8                	mov    %ebx,%eax
f01002db:	eb 0e                	jmp    f01002eb <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01002dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002e2:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01002e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002e8:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002e9:	89 d8                	mov    %ebx,%eax
}
f01002eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002ee:	c9                   	leave  
f01002ef:	c3                   	ret    

f01002f0 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002f0:	55                   	push   %ebp
f01002f1:	89 e5                	mov    %esp,%ebp
f01002f3:	57                   	push   %edi
f01002f4:	56                   	push   %esi
f01002f5:	53                   	push   %ebx
f01002f6:	83 ec 1c             	sub    $0x1c,%esp
f01002f9:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002fb:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100300:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100305:	b9 84 00 00 00       	mov    $0x84,%ecx
f010030a:	eb 09                	jmp    f0100315 <cons_putc+0x25>
f010030c:	89 ca                	mov    %ecx,%edx
f010030e:	ec                   	in     (%dx),%al
f010030f:	ec                   	in     (%dx),%al
f0100310:	ec                   	in     (%dx),%al
f0100311:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100312:	83 c3 01             	add    $0x1,%ebx
f0100315:	89 f2                	mov    %esi,%edx
f0100317:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100318:	a8 20                	test   $0x20,%al
f010031a:	75 08                	jne    f0100324 <cons_putc+0x34>
f010031c:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100322:	7e e8                	jle    f010030c <cons_putc+0x1c>
f0100324:	89 f8                	mov    %edi,%eax
f0100326:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100329:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010032e:	89 f8                	mov    %edi,%eax
f0100330:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100331:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100336:	be 79 03 00 00       	mov    $0x379,%esi
f010033b:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100340:	eb 09                	jmp    f010034b <cons_putc+0x5b>
f0100342:	89 ca                	mov    %ecx,%edx
f0100344:	ec                   	in     (%dx),%al
f0100345:	ec                   	in     (%dx),%al
f0100346:	ec                   	in     (%dx),%al
f0100347:	ec                   	in     (%dx),%al
f0100348:	83 c3 01             	add    $0x1,%ebx
f010034b:	89 f2                	mov    %esi,%edx
f010034d:	ec                   	in     (%dx),%al
f010034e:	84 c0                	test   %al,%al
f0100350:	78 08                	js     f010035a <cons_putc+0x6a>
f0100352:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100358:	7e e8                	jle    f0100342 <cons_putc+0x52>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010035a:	ba 78 03 00 00       	mov    $0x378,%edx
f010035f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100363:	ee                   	out    %al,(%dx)
f0100364:	b2 7a                	mov    $0x7a,%dl
f0100366:	b8 0d 00 00 00       	mov    $0xd,%eax
f010036b:	ee                   	out    %al,(%dx)
f010036c:	b8 08 00 00 00       	mov    $0x8,%eax
f0100371:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100372:	89 fa                	mov    %edi,%edx
f0100374:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010037a:	89 f8                	mov    %edi,%eax
f010037c:	80 cc 07             	or     $0x7,%ah
f010037f:	85 d2                	test   %edx,%edx
f0100381:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100384:	89 f8                	mov    %edi,%eax
f0100386:	0f b6 c0             	movzbl %al,%eax
f0100389:	83 f8 09             	cmp    $0x9,%eax
f010038c:	74 74                	je     f0100402 <cons_putc+0x112>
f010038e:	83 f8 09             	cmp    $0x9,%eax
f0100391:	7f 0a                	jg     f010039d <cons_putc+0xad>
f0100393:	83 f8 08             	cmp    $0x8,%eax
f0100396:	74 14                	je     f01003ac <cons_putc+0xbc>
f0100398:	e9 99 00 00 00       	jmp    f0100436 <cons_putc+0x146>
f010039d:	83 f8 0a             	cmp    $0xa,%eax
f01003a0:	74 3a                	je     f01003dc <cons_putc+0xec>
f01003a2:	83 f8 0d             	cmp    $0xd,%eax
f01003a5:	74 3d                	je     f01003e4 <cons_putc+0xf4>
f01003a7:	e9 8a 00 00 00       	jmp    f0100436 <cons_putc+0x146>
	case '\b':
		if (crt_pos > 0) {
f01003ac:	0f b7 05 48 25 11 f0 	movzwl 0xf0112548,%eax
f01003b3:	66 85 c0             	test   %ax,%ax
f01003b6:	0f 84 e6 00 00 00    	je     f01004a2 <cons_putc+0x1b2>
			crt_pos--;
f01003bc:	83 e8 01             	sub    $0x1,%eax
f01003bf:	66 a3 48 25 11 f0    	mov    %ax,0xf0112548
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003c5:	0f b7 c0             	movzwl %ax,%eax
f01003c8:	66 81 e7 00 ff       	and    $0xff00,%di
f01003cd:	83 cf 20             	or     $0x20,%edi
f01003d0:	8b 15 4c 25 11 f0    	mov    0xf011254c,%edx
f01003d6:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003da:	eb 78                	jmp    f0100454 <cons_putc+0x164>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003dc:	66 83 05 48 25 11 f0 	addw   $0x50,0xf0112548
f01003e3:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003e4:	0f b7 05 48 25 11 f0 	movzwl 0xf0112548,%eax
f01003eb:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003f1:	c1 e8 16             	shr    $0x16,%eax
f01003f4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003f7:	c1 e0 04             	shl    $0x4,%eax
f01003fa:	66 a3 48 25 11 f0    	mov    %ax,0xf0112548
f0100400:	eb 52                	jmp    f0100454 <cons_putc+0x164>
		break;
	case '\t':
		cons_putc(' ');
f0100402:	b8 20 00 00 00       	mov    $0x20,%eax
f0100407:	e8 e4 fe ff ff       	call   f01002f0 <cons_putc>
		cons_putc(' ');
f010040c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100411:	e8 da fe ff ff       	call   f01002f0 <cons_putc>
		cons_putc(' ');
f0100416:	b8 20 00 00 00       	mov    $0x20,%eax
f010041b:	e8 d0 fe ff ff       	call   f01002f0 <cons_putc>
		cons_putc(' ');
f0100420:	b8 20 00 00 00       	mov    $0x20,%eax
f0100425:	e8 c6 fe ff ff       	call   f01002f0 <cons_putc>
		cons_putc(' ');
f010042a:	b8 20 00 00 00       	mov    $0x20,%eax
f010042f:	e8 bc fe ff ff       	call   f01002f0 <cons_putc>
f0100434:	eb 1e                	jmp    f0100454 <cons_putc+0x164>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100436:	0f b7 05 48 25 11 f0 	movzwl 0xf0112548,%eax
f010043d:	8d 50 01             	lea    0x1(%eax),%edx
f0100440:	66 89 15 48 25 11 f0 	mov    %dx,0xf0112548
f0100447:	0f b7 c0             	movzwl %ax,%eax
f010044a:	8b 15 4c 25 11 f0    	mov    0xf011254c,%edx
f0100450:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100454:	66 81 3d 48 25 11 f0 	cmpw   $0x7cf,0xf0112548
f010045b:	cf 07 
f010045d:	76 43                	jbe    f01004a2 <cons_putc+0x1b2>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010045f:	a1 4c 25 11 f0       	mov    0xf011254c,%eax
f0100464:	83 ec 04             	sub    $0x4,%esp
f0100467:	68 00 0f 00 00       	push   $0xf00
f010046c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100472:	52                   	push   %edx
f0100473:	50                   	push   %eax
f0100474:	e8 1a 10 00 00       	call   f0101493 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100479:	8b 15 4c 25 11 f0    	mov    0xf011254c,%edx
f010047f:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100485:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010048b:	83 c4 10             	add    $0x10,%esp
f010048e:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100493:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100496:	39 d0                	cmp    %edx,%eax
f0100498:	75 f4                	jne    f010048e <cons_putc+0x19e>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010049a:	66 83 2d 48 25 11 f0 	subw   $0x50,0xf0112548
f01004a1:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004a2:	8b 0d 50 25 11 f0    	mov    0xf0112550,%ecx
f01004a8:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004ad:	89 ca                	mov    %ecx,%edx
f01004af:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004b0:	0f b7 1d 48 25 11 f0 	movzwl 0xf0112548,%ebx
f01004b7:	8d 71 01             	lea    0x1(%ecx),%esi
f01004ba:	89 d8                	mov    %ebx,%eax
f01004bc:	66 c1 e8 08          	shr    $0x8,%ax
f01004c0:	89 f2                	mov    %esi,%edx
f01004c2:	ee                   	out    %al,(%dx)
f01004c3:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004c8:	89 ca                	mov    %ecx,%edx
f01004ca:	ee                   	out    %al,(%dx)
f01004cb:	89 d8                	mov    %ebx,%eax
f01004cd:	89 f2                	mov    %esi,%edx
f01004cf:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004d3:	5b                   	pop    %ebx
f01004d4:	5e                   	pop    %esi
f01004d5:	5f                   	pop    %edi
f01004d6:	5d                   	pop    %ebp
f01004d7:	c3                   	ret    

f01004d8 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004d8:	80 3d 54 25 11 f0 00 	cmpb   $0x0,0xf0112554
f01004df:	74 11                	je     f01004f2 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004e1:	55                   	push   %ebp
f01004e2:	89 e5                	mov    %esp,%ebp
f01004e4:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004e7:	b8 77 01 10 f0       	mov    $0xf0100177,%eax
f01004ec:	e8 a2 fc ff ff       	call   f0100193 <cons_intr>
}
f01004f1:	c9                   	leave  
f01004f2:	f3 c3                	repz ret 

f01004f4 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004f4:	55                   	push   %ebp
f01004f5:	89 e5                	mov    %esp,%ebp
f01004f7:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004fa:	b8 d7 01 10 f0       	mov    $0xf01001d7,%eax
f01004ff:	e8 8f fc ff ff       	call   f0100193 <cons_intr>
}
f0100504:	c9                   	leave  
f0100505:	c3                   	ret    

f0100506 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100506:	55                   	push   %ebp
f0100507:	89 e5                	mov    %esp,%ebp
f0100509:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010050c:	e8 c7 ff ff ff       	call   f01004d8 <serial_intr>
	kbd_intr();
f0100511:	e8 de ff ff ff       	call   f01004f4 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100516:	a1 40 25 11 f0       	mov    0xf0112540,%eax
f010051b:	3b 05 44 25 11 f0    	cmp    0xf0112544,%eax
f0100521:	74 26                	je     f0100549 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100523:	8d 50 01             	lea    0x1(%eax),%edx
f0100526:	89 15 40 25 11 f0    	mov    %edx,0xf0112540
f010052c:	0f b6 88 40 23 11 f0 	movzbl -0xfeedcc0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100533:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100535:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010053b:	75 11                	jne    f010054e <cons_getc+0x48>
			cons.rpos = 0;
f010053d:	c7 05 40 25 11 f0 00 	movl   $0x0,0xf0112540
f0100544:	00 00 00 
f0100547:	eb 05                	jmp    f010054e <cons_getc+0x48>
		return c;
	}
	return 0;
f0100549:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010054e:	c9                   	leave  
f010054f:	c3                   	ret    

f0100550 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100550:	55                   	push   %ebp
f0100551:	89 e5                	mov    %esp,%ebp
f0100553:	57                   	push   %edi
f0100554:	56                   	push   %esi
f0100555:	53                   	push   %ebx
f0100556:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100559:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100560:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100567:	5a a5 
	if (*cp != 0xA55A) {
f0100569:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100570:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100574:	74 11                	je     f0100587 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100576:	c7 05 50 25 11 f0 b4 	movl   $0x3b4,0xf0112550
f010057d:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100580:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100585:	eb 16                	jmp    f010059d <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100587:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010058e:	c7 05 50 25 11 f0 d4 	movl   $0x3d4,0xf0112550
f0100595:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100598:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010059d:	8b 3d 50 25 11 f0    	mov    0xf0112550,%edi
f01005a3:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005a8:	89 fa                	mov    %edi,%edx
f01005aa:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005ab:	8d 4f 01             	lea    0x1(%edi),%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005ae:	89 ca                	mov    %ecx,%edx
f01005b0:	ec                   	in     (%dx),%al
f01005b1:	0f b6 c0             	movzbl %al,%eax
f01005b4:	c1 e0 08             	shl    $0x8,%eax
f01005b7:	89 c3                	mov    %eax,%ebx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005b9:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005be:	89 fa                	mov    %edi,%edx
f01005c0:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c1:	89 ca                	mov    %ecx,%edx
f01005c3:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005c4:	89 35 4c 25 11 f0    	mov    %esi,0xf011254c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005ca:	0f b6 c8             	movzbl %al,%ecx
f01005cd:	89 d8                	mov    %ebx,%eax
f01005cf:	09 c8                	or     %ecx,%eax

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005d1:	66 a3 48 25 11 f0    	mov    %ax,0xf0112548
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005d7:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01005e1:	89 da                	mov    %ebx,%edx
f01005e3:	ee                   	out    %al,(%dx)
f01005e4:	b2 fb                	mov    $0xfb,%dl
f01005e6:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005eb:	ee                   	out    %al,(%dx)
f01005ec:	be f8 03 00 00       	mov    $0x3f8,%esi
f01005f1:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005f6:	89 f2                	mov    %esi,%edx
f01005f8:	ee                   	out    %al,(%dx)
f01005f9:	b2 f9                	mov    $0xf9,%dl
f01005fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100600:	ee                   	out    %al,(%dx)
f0100601:	b2 fb                	mov    $0xfb,%dl
f0100603:	b8 03 00 00 00       	mov    $0x3,%eax
f0100608:	ee                   	out    %al,(%dx)
f0100609:	b2 fc                	mov    $0xfc,%dl
f010060b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100610:	ee                   	out    %al,(%dx)
f0100611:	b2 f9                	mov    $0xf9,%dl
f0100613:	b8 01 00 00 00       	mov    $0x1,%eax
f0100618:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100619:	b2 fd                	mov    $0xfd,%dl
f010061b:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010061c:	3c ff                	cmp    $0xff,%al
f010061e:	0f 95 c1             	setne  %cl
f0100621:	88 0d 54 25 11 f0    	mov    %cl,0xf0112554
f0100627:	89 da                	mov    %ebx,%edx
f0100629:	ec                   	in     (%dx),%al
f010062a:	89 f2                	mov    %esi,%edx
f010062c:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010062d:	84 c9                	test   %cl,%cl
f010062f:	75 10                	jne    f0100641 <cons_init+0xf1>
		cprintf("Serial port does not exist!\n");
f0100631:	83 ec 0c             	sub    $0xc,%esp
f0100634:	68 90 19 10 f0       	push   $0xf0101990
f0100639:	e8 1d 03 00 00       	call   f010095b <cprintf>
f010063e:	83 c4 10             	add    $0x10,%esp
}
f0100641:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100644:	5b                   	pop    %ebx
f0100645:	5e                   	pop    %esi
f0100646:	5f                   	pop    %edi
f0100647:	5d                   	pop    %ebp
f0100648:	c3                   	ret    

f0100649 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100649:	55                   	push   %ebp
f010064a:	89 e5                	mov    %esp,%ebp
f010064c:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010064f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100652:	e8 99 fc ff ff       	call   f01002f0 <cons_putc>
}
f0100657:	c9                   	leave  
f0100658:	c3                   	ret    

f0100659 <getchar>:

int
getchar(void)
{
f0100659:	55                   	push   %ebp
f010065a:	89 e5                	mov    %esp,%ebp
f010065c:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010065f:	e8 a2 fe ff ff       	call   f0100506 <cons_getc>
f0100664:	85 c0                	test   %eax,%eax
f0100666:	74 f7                	je     f010065f <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100668:	c9                   	leave  
f0100669:	c3                   	ret    

f010066a <iscons>:

int
iscons(int fdnum)
{
f010066a:	55                   	push   %ebp
f010066b:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010066d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100672:	5d                   	pop    %ebp
f0100673:	c3                   	ret    

f0100674 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100674:	55                   	push   %ebp
f0100675:	89 e5                	mov    %esp,%ebp
f0100677:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010067a:	68 00 1c 10 f0       	push   $0xf0101c00
f010067f:	68 1e 1c 10 f0       	push   $0xf0101c1e
f0100684:	68 23 1c 10 f0       	push   $0xf0101c23
f0100689:	e8 cd 02 00 00       	call   f010095b <cprintf>
f010068e:	83 c4 0c             	add    $0xc,%esp
f0100691:	68 d8 1c 10 f0       	push   $0xf0101cd8
f0100696:	68 2c 1c 10 f0       	push   $0xf0101c2c
f010069b:	68 23 1c 10 f0       	push   $0xf0101c23
f01006a0:	e8 b6 02 00 00       	call   f010095b <cprintf>
f01006a5:	83 c4 0c             	add    $0xc,%esp
f01006a8:	68 35 1c 10 f0       	push   $0xf0101c35
f01006ad:	68 4c 1c 10 f0       	push   $0xf0101c4c
f01006b2:	68 23 1c 10 f0       	push   $0xf0101c23
f01006b7:	e8 9f 02 00 00       	call   f010095b <cprintf>
	return 0;
}
f01006bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01006c1:	c9                   	leave  
f01006c2:	c3                   	ret    

f01006c3 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006c3:	55                   	push   %ebp
f01006c4:	89 e5                	mov    %esp,%ebp
f01006c6:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006c9:	68 56 1c 10 f0       	push   $0xf0101c56
f01006ce:	e8 88 02 00 00       	call   f010095b <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006d3:	83 c4 08             	add    $0x8,%esp
f01006d6:	68 0c 00 10 00       	push   $0x10000c
f01006db:	68 00 1d 10 f0       	push   $0xf0101d00
f01006e0:	e8 76 02 00 00       	call   f010095b <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006e5:	83 c4 0c             	add    $0xc,%esp
f01006e8:	68 0c 00 10 00       	push   $0x10000c
f01006ed:	68 0c 00 10 f0       	push   $0xf010000c
f01006f2:	68 28 1d 10 f0       	push   $0xf0101d28
f01006f7:	e8 5f 02 00 00       	call   f010095b <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006fc:	83 c4 0c             	add    $0xc,%esp
f01006ff:	68 f5 18 10 00       	push   $0x1018f5
f0100704:	68 f5 18 10 f0       	push   $0xf01018f5
f0100709:	68 4c 1d 10 f0       	push   $0xf0101d4c
f010070e:	e8 48 02 00 00       	call   f010095b <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100713:	83 c4 0c             	add    $0xc,%esp
f0100716:	68 00 23 11 00       	push   $0x112300
f010071b:	68 00 23 11 f0       	push   $0xf0112300
f0100720:	68 70 1d 10 f0       	push   $0xf0101d70
f0100725:	e8 31 02 00 00       	call   f010095b <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010072a:	83 c4 0c             	add    $0xc,%esp
f010072d:	68 84 29 11 00       	push   $0x112984
f0100732:	68 84 29 11 f0       	push   $0xf0112984
f0100737:	68 94 1d 10 f0       	push   $0xf0101d94
f010073c:	e8 1a 02 00 00       	call   f010095b <cprintf>
f0100741:	b8 83 2d 11 f0       	mov    $0xf0112d83,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100746:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010074b:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010074e:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100753:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100759:	85 c0                	test   %eax,%eax
f010075b:	0f 48 c2             	cmovs  %edx,%eax
f010075e:	c1 f8 0a             	sar    $0xa,%eax
f0100761:	50                   	push   %eax
f0100762:	68 b8 1d 10 f0       	push   $0xf0101db8
f0100767:	e8 ef 01 00 00       	call   f010095b <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010076c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100771:	c9                   	leave  
f0100772:	c3                   	ret    

f0100773 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100773:	55                   	push   %ebp
f0100774:	89 e5                	mov    %esp,%ebp
f0100776:	56                   	push   %esi
f0100777:	53                   	push   %ebx
f0100778:	83 ec 2c             	sub    $0x2c,%esp
	// Your code here.
	uint32_t * ebp = (uint32_t *)read_ebp();
f010077b:	89 eb                	mov    %ebp,%ebx
	struct Eipdebuginfo info; 
	cprintf("\nStack backtrace:\n");
f010077d:	68 6f 1c 10 f0       	push   $0xf0101c6f
f0100782:	e8 d4 01 00 00       	call   f010095b <cprintf>
	for(;ebp != 0x0;)
f0100787:	83 c4 10             	add    $0x10,%esp
	{
		cprintf("  ebp %08x  eip  %08x args %08x %08x %08x %08x %08x\n",ebp,ebp[1], ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
		debuginfo_eip(ebp[1],&info);
f010078a:	8d 75 e0             	lea    -0x20(%ebp),%esi
{
	// Your code here.
	uint32_t * ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info; 
	cprintf("\nStack backtrace:\n");
	for(;ebp != 0x0;)
f010078d:	eb 4e                	jmp    f01007dd <mon_backtrace+0x6a>
	{
		cprintf("  ebp %08x  eip  %08x args %08x %08x %08x %08x %08x\n",ebp,ebp[1], ebp[2], ebp[3], ebp[4], ebp[5], ebp[6]);
f010078f:	ff 73 18             	pushl  0x18(%ebx)
f0100792:	ff 73 14             	pushl  0x14(%ebx)
f0100795:	ff 73 10             	pushl  0x10(%ebx)
f0100798:	ff 73 0c             	pushl  0xc(%ebx)
f010079b:	ff 73 08             	pushl  0x8(%ebx)
f010079e:	ff 73 04             	pushl  0x4(%ebx)
f01007a1:	53                   	push   %ebx
f01007a2:	68 e4 1d 10 f0       	push   $0xf0101de4
f01007a7:	e8 af 01 00 00       	call   f010095b <cprintf>
		debuginfo_eip(ebp[1],&info);
f01007ac:	83 c4 18             	add    $0x18,%esp
f01007af:	56                   	push   %esi
f01007b0:	ff 73 04             	pushl  0x4(%ebx)
f01007b3:	e8 b9 02 00 00       	call   f0100a71 <debuginfo_eip>
		cprintf("         %s:%d: %.*s+%u\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, ((uint32_t)ebp[1]-(uint32_t)(info.eip_fn_addr)));
f01007b8:	83 c4 08             	add    $0x8,%esp
f01007bb:	8b 43 04             	mov    0x4(%ebx),%eax
f01007be:	2b 45 f0             	sub    -0x10(%ebp),%eax
f01007c1:	50                   	push   %eax
f01007c2:	ff 75 e8             	pushl  -0x18(%ebp)
f01007c5:	ff 75 ec             	pushl  -0x14(%ebp)
f01007c8:	ff 75 e4             	pushl  -0x1c(%ebp)
f01007cb:	ff 75 e0             	pushl  -0x20(%ebp)
f01007ce:	68 82 1c 10 f0       	push   $0xf0101c82
f01007d3:	e8 83 01 00 00       	call   f010095b <cprintf>
		ebp = (uint32_t *)*ebp;
f01007d8:	8b 1b                	mov    (%ebx),%ebx
f01007da:	83 c4 20             	add    $0x20,%esp
{
	// Your code here.
	uint32_t * ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo info; 
	cprintf("\nStack backtrace:\n");
	for(;ebp != 0x0;)
f01007dd:	85 db                	test   %ebx,%ebx
f01007df:	75 ae                	jne    f010078f <mon_backtrace+0x1c>
		debuginfo_eip(ebp[1],&info);
		cprintf("         %s:%d: %.*s+%u\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, ((uint32_t)ebp[1]-(uint32_t)(info.eip_fn_addr)));
		ebp = (uint32_t *)*ebp;
	}
	return 0;
}
f01007e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01007e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007e9:	5b                   	pop    %ebx
f01007ea:	5e                   	pop    %esi
f01007eb:	5d                   	pop    %ebp
f01007ec:	c3                   	ret    

f01007ed <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007ed:	55                   	push   %ebp
f01007ee:	89 e5                	mov    %esp,%ebp
f01007f0:	57                   	push   %edi
f01007f1:	56                   	push   %esi
f01007f2:	53                   	push   %ebx
f01007f3:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007f6:	68 1c 1e 10 f0       	push   $0xf0101e1c
f01007fb:	e8 5b 01 00 00       	call   f010095b <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100800:	c7 04 24 40 1e 10 f0 	movl   $0xf0101e40,(%esp)
f0100807:	e8 4f 01 00 00       	call   f010095b <cprintf>
f010080c:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f010080f:	83 ec 0c             	sub    $0xc,%esp
f0100812:	68 9b 1c 10 f0       	push   $0xf0101c9b
f0100817:	e8 d3 09 00 00       	call   f01011ef <readline>
f010081c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010081e:	83 c4 10             	add    $0x10,%esp
f0100821:	85 c0                	test   %eax,%eax
f0100823:	74 ea                	je     f010080f <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100825:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010082c:	be 00 00 00 00       	mov    $0x0,%esi
f0100831:	eb 0a                	jmp    f010083d <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100833:	c6 03 00             	movb   $0x0,(%ebx)
f0100836:	89 f7                	mov    %esi,%edi
f0100838:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010083b:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010083d:	0f b6 03             	movzbl (%ebx),%eax
f0100840:	84 c0                	test   %al,%al
f0100842:	74 63                	je     f01008a7 <monitor+0xba>
f0100844:	83 ec 08             	sub    $0x8,%esp
f0100847:	0f be c0             	movsbl %al,%eax
f010084a:	50                   	push   %eax
f010084b:	68 9f 1c 10 f0       	push   $0xf0101c9f
f0100850:	e8 b4 0b 00 00       	call   f0101409 <strchr>
f0100855:	83 c4 10             	add    $0x10,%esp
f0100858:	85 c0                	test   %eax,%eax
f010085a:	75 d7                	jne    f0100833 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f010085c:	80 3b 00             	cmpb   $0x0,(%ebx)
f010085f:	74 46                	je     f01008a7 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100861:	83 fe 0f             	cmp    $0xf,%esi
f0100864:	75 14                	jne    f010087a <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100866:	83 ec 08             	sub    $0x8,%esp
f0100869:	6a 10                	push   $0x10
f010086b:	68 a4 1c 10 f0       	push   $0xf0101ca4
f0100870:	e8 e6 00 00 00       	call   f010095b <cprintf>
f0100875:	83 c4 10             	add    $0x10,%esp
f0100878:	eb 95                	jmp    f010080f <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f010087a:	8d 7e 01             	lea    0x1(%esi),%edi
f010087d:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100881:	eb 03                	jmp    f0100886 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100883:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100886:	0f b6 03             	movzbl (%ebx),%eax
f0100889:	84 c0                	test   %al,%al
f010088b:	74 ae                	je     f010083b <monitor+0x4e>
f010088d:	83 ec 08             	sub    $0x8,%esp
f0100890:	0f be c0             	movsbl %al,%eax
f0100893:	50                   	push   %eax
f0100894:	68 9f 1c 10 f0       	push   $0xf0101c9f
f0100899:	e8 6b 0b 00 00       	call   f0101409 <strchr>
f010089e:	83 c4 10             	add    $0x10,%esp
f01008a1:	85 c0                	test   %eax,%eax
f01008a3:	74 de                	je     f0100883 <monitor+0x96>
f01008a5:	eb 94                	jmp    f010083b <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01008a7:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008ae:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008af:	85 f6                	test   %esi,%esi
f01008b1:	0f 84 58 ff ff ff    	je     f010080f <monitor+0x22>
f01008b7:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008bc:	83 ec 08             	sub    $0x8,%esp
f01008bf:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008c2:	ff 34 85 80 1e 10 f0 	pushl  -0xfefe180(,%eax,4)
f01008c9:	ff 75 a8             	pushl  -0x58(%ebp)
f01008cc:	e8 da 0a 00 00       	call   f01013ab <strcmp>
f01008d1:	83 c4 10             	add    $0x10,%esp
f01008d4:	85 c0                	test   %eax,%eax
f01008d6:	75 22                	jne    f01008fa <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f01008d8:	83 ec 04             	sub    $0x4,%esp
f01008db:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008de:	ff 75 08             	pushl  0x8(%ebp)
f01008e1:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008e4:	52                   	push   %edx
f01008e5:	56                   	push   %esi
f01008e6:	ff 14 85 88 1e 10 f0 	call   *-0xfefe178(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008ed:	83 c4 10             	add    $0x10,%esp
f01008f0:	85 c0                	test   %eax,%eax
f01008f2:	0f 89 17 ff ff ff    	jns    f010080f <monitor+0x22>
f01008f8:	eb 20                	jmp    f010091a <monitor+0x12d>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01008fa:	83 c3 01             	add    $0x1,%ebx
f01008fd:	83 fb 03             	cmp    $0x3,%ebx
f0100900:	75 ba                	jne    f01008bc <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100902:	83 ec 08             	sub    $0x8,%esp
f0100905:	ff 75 a8             	pushl  -0x58(%ebp)
f0100908:	68 c1 1c 10 f0       	push   $0xf0101cc1
f010090d:	e8 49 00 00 00       	call   f010095b <cprintf>
f0100912:	83 c4 10             	add    $0x10,%esp
f0100915:	e9 f5 fe ff ff       	jmp    f010080f <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010091a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010091d:	5b                   	pop    %ebx
f010091e:	5e                   	pop    %esi
f010091f:	5f                   	pop    %edi
f0100920:	5d                   	pop    %ebp
f0100921:	c3                   	ret    

f0100922 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100922:	55                   	push   %ebp
f0100923:	89 e5                	mov    %esp,%ebp
f0100925:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100928:	ff 75 08             	pushl  0x8(%ebp)
f010092b:	e8 19 fd ff ff       	call   f0100649 <cputchar>
f0100930:	83 c4 10             	add    $0x10,%esp
	*cnt++;
}
f0100933:	c9                   	leave  
f0100934:	c3                   	ret    

f0100935 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100935:	55                   	push   %ebp
f0100936:	89 e5                	mov    %esp,%ebp
f0100938:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010093b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100942:	ff 75 0c             	pushl  0xc(%ebp)
f0100945:	ff 75 08             	pushl  0x8(%ebp)
f0100948:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010094b:	50                   	push   %eax
f010094c:	68 22 09 10 f0       	push   $0xf0100922
f0100951:	e8 7d 04 00 00       	call   f0100dd3 <vprintfmt>
	return cnt;
}
f0100956:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100959:	c9                   	leave  
f010095a:	c3                   	ret    

f010095b <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010095b:	55                   	push   %ebp
f010095c:	89 e5                	mov    %esp,%ebp
f010095e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100961:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100964:	50                   	push   %eax
f0100965:	ff 75 08             	pushl  0x8(%ebp)
f0100968:	e8 c8 ff ff ff       	call   f0100935 <vcprintf>
	va_end(ap);

	return cnt;
}
f010096d:	c9                   	leave  
f010096e:	c3                   	ret    

f010096f <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010096f:	55                   	push   %ebp
f0100970:	89 e5                	mov    %esp,%ebp
f0100972:	57                   	push   %edi
f0100973:	56                   	push   %esi
f0100974:	53                   	push   %ebx
f0100975:	83 ec 14             	sub    $0x14,%esp
f0100978:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010097b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010097e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100981:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100984:	8b 1a                	mov    (%edx),%ebx
f0100986:	8b 01                	mov    (%ecx),%eax
f0100988:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010098b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100992:	e9 88 00 00 00       	jmp    f0100a1f <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0100997:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010099a:	01 d8                	add    %ebx,%eax
f010099c:	89 c6                	mov    %eax,%esi
f010099e:	c1 ee 1f             	shr    $0x1f,%esi
f01009a1:	01 c6                	add    %eax,%esi
f01009a3:	d1 fe                	sar    %esi
f01009a5:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01009a8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009ab:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01009ae:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009b0:	eb 03                	jmp    f01009b5 <stab_binsearch+0x46>
			m--;
f01009b2:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009b5:	39 c3                	cmp    %eax,%ebx
f01009b7:	7f 1f                	jg     f01009d8 <stab_binsearch+0x69>
f01009b9:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01009bd:	83 ea 0c             	sub    $0xc,%edx
f01009c0:	39 f9                	cmp    %edi,%ecx
f01009c2:	75 ee                	jne    f01009b2 <stab_binsearch+0x43>
f01009c4:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01009c7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01009ca:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009cd:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01009d1:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01009d4:	76 18                	jbe    f01009ee <stab_binsearch+0x7f>
f01009d6:	eb 05                	jmp    f01009dd <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01009d8:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01009db:	eb 42                	jmp    f0100a1f <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01009dd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01009e0:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01009e2:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01009e5:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01009ec:	eb 31                	jmp    f0100a1f <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01009ee:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01009f1:	73 17                	jae    f0100a0a <stab_binsearch+0x9b>
			*region_right = m - 1;
f01009f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01009f6:	83 e8 01             	sub    $0x1,%eax
f01009f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01009ff:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a01:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a08:	eb 15                	jmp    f0100a1f <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a0a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a0d:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0100a10:	89 1e                	mov    %ebx,(%esi)
			l = m;
			addr++;
f0100a12:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a16:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a18:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a1f:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a22:	0f 8e 6f ff ff ff    	jle    f0100997 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a28:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100a2c:	75 0f                	jne    f0100a3d <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0100a2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a31:	8b 00                	mov    (%eax),%eax
f0100a33:	83 e8 01             	sub    $0x1,%eax
f0100a36:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a39:	89 06                	mov    %eax,(%esi)
f0100a3b:	eb 2c                	jmp    f0100a69 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a40:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a42:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a45:	8b 0e                	mov    (%esi),%ecx
f0100a47:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a4a:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100a4d:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a50:	eb 03                	jmp    f0100a55 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a52:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a55:	39 c8                	cmp    %ecx,%eax
f0100a57:	7e 0b                	jle    f0100a64 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0100a59:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100a5d:	83 ea 0c             	sub    $0xc,%edx
f0100a60:	39 fb                	cmp    %edi,%ebx
f0100a62:	75 ee                	jne    f0100a52 <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100a64:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a67:	89 06                	mov    %eax,(%esi)
	}
}
f0100a69:	83 c4 14             	add    $0x14,%esp
f0100a6c:	5b                   	pop    %ebx
f0100a6d:	5e                   	pop    %esi
f0100a6e:	5f                   	pop    %edi
f0100a6f:	5d                   	pop    %ebp
f0100a70:	c3                   	ret    

f0100a71 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a71:	55                   	push   %ebp
f0100a72:	89 e5                	mov    %esp,%ebp
f0100a74:	57                   	push   %edi
f0100a75:	56                   	push   %esi
f0100a76:	53                   	push   %ebx
f0100a77:	83 ec 3c             	sub    $0x3c,%esp
f0100a7a:	8b 75 08             	mov    0x8(%ebp),%esi
f0100a7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a80:	c7 03 a4 1e 10 f0    	movl   $0xf0101ea4,(%ebx)
	info->eip_line = 0;
f0100a86:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100a8d:	c7 43 08 a4 1e 10 f0 	movl   $0xf0101ea4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100a94:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100a9b:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100a9e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100aa5:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100aab:	76 11                	jbe    f0100abe <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100aad:	b8 d8 72 10 f0       	mov    $0xf01072d8,%eax
f0100ab2:	3d f5 59 10 f0       	cmp    $0xf01059f5,%eax
f0100ab7:	77 19                	ja     f0100ad2 <debuginfo_eip+0x61>
f0100ab9:	e9 a8 01 00 00       	jmp    f0100c66 <debuginfo_eip+0x1f5>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100abe:	83 ec 04             	sub    $0x4,%esp
f0100ac1:	68 ae 1e 10 f0       	push   $0xf0101eae
f0100ac6:	6a 7f                	push   $0x7f
f0100ac8:	68 bb 1e 10 f0       	push   $0xf0101ebb
f0100acd:	e8 14 f6 ff ff       	call   f01000e6 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ad2:	80 3d d7 72 10 f0 00 	cmpb   $0x0,0xf01072d7
f0100ad9:	0f 85 8e 01 00 00    	jne    f0100c6d <debuginfo_eip+0x1fc>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100adf:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100ae6:	b8 f4 59 10 f0       	mov    $0xf01059f4,%eax
f0100aeb:	2d dc 20 10 f0       	sub    $0xf01020dc,%eax
f0100af0:	c1 f8 02             	sar    $0x2,%eax
f0100af3:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100af9:	83 e8 01             	sub    $0x1,%eax
f0100afc:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100aff:	83 ec 08             	sub    $0x8,%esp
f0100b02:	56                   	push   %esi
f0100b03:	6a 64                	push   $0x64
f0100b05:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b08:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b0b:	b8 dc 20 10 f0       	mov    $0xf01020dc,%eax
f0100b10:	e8 5a fe ff ff       	call   f010096f <stab_binsearch>
	if (lfile == 0)
f0100b15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b18:	83 c4 10             	add    $0x10,%esp
f0100b1b:	85 c0                	test   %eax,%eax
f0100b1d:	0f 84 51 01 00 00    	je     f0100c74 <debuginfo_eip+0x203>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b23:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b26:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b29:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b2c:	83 ec 08             	sub    $0x8,%esp
f0100b2f:	56                   	push   %esi
f0100b30:	6a 24                	push   $0x24
f0100b32:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b35:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b38:	b8 dc 20 10 f0       	mov    $0xf01020dc,%eax
f0100b3d:	e8 2d fe ff ff       	call   f010096f <stab_binsearch>

	if (lfun <= rfun) {
f0100b42:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b45:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100b48:	83 c4 10             	add    $0x10,%esp
f0100b4b:	39 d0                	cmp    %edx,%eax
f0100b4d:	7f 3f                	jg     f0100b8e <debuginfo_eip+0x11d>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b4f:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100b52:	c1 e1 02             	shl    $0x2,%ecx
f0100b55:	8d b9 dc 20 10 f0    	lea    -0xfefdf24(%ecx),%edi
f0100b5b:	8b 89 dc 20 10 f0    	mov    -0xfefdf24(%ecx),%ecx
f0100b61:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100b64:	b9 d8 72 10 f0       	mov    $0xf01072d8,%ecx
f0100b69:	81 e9 f5 59 10 f0    	sub    $0xf01059f5,%ecx
f0100b6f:	39 4d c4             	cmp    %ecx,-0x3c(%ebp)
f0100b72:	73 0c                	jae    f0100b80 <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b74:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0100b77:	81 c1 f5 59 10 f0    	add    $0xf01059f5,%ecx
f0100b7d:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b80:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100b83:	89 4b 10             	mov    %ecx,0x10(%ebx)
		//addr -= info->eip_fn_addr;
		// Search within the function definition for the line number.
		lline = lfun;
f0100b86:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100b89:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100b8c:	eb 0f                	jmp    f0100b9d <debuginfo_eip+0x12c>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100b8e:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100b91:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b94:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100b97:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b9a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100b9d:	83 ec 08             	sub    $0x8,%esp
f0100ba0:	6a 3a                	push   $0x3a
f0100ba2:	ff 73 08             	pushl  0x8(%ebx)
f0100ba5:	e8 80 08 00 00       	call   f010142a <strfind>
f0100baa:	2b 43 08             	sub    0x8(%ebx),%eax
f0100bad:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100bb0:	83 c4 08             	add    $0x8,%esp
f0100bb3:	56                   	push   %esi
f0100bb4:	6a 44                	push   $0x44
f0100bb6:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100bb9:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100bbc:	b8 dc 20 10 f0       	mov    $0xf01020dc,%eax
f0100bc1:	e8 a9 fd ff ff       	call   f010096f <stab_binsearch>
	if(lline>rline)
f0100bc6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100bc9:	83 c4 10             	add    $0x10,%esp
f0100bcc:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0100bcf:	0f 8f a6 00 00 00    	jg     f0100c7b <debuginfo_eip+0x20a>
	{
		return -1;
	}
	else
		info->eip_line = stabs[rline].n_desc;
f0100bd5:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100bd8:	0f b7 04 85 e2 20 10 	movzwl -0xfefdf1e(,%eax,4),%eax
f0100bdf:	f0 
f0100be0:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100be3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100be6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100be9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100bec:	8d 14 95 dc 20 10 f0 	lea    -0xfefdf24(,%edx,4),%edx
f0100bf3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100bf6:	eb 06                	jmp    f0100bfe <debuginfo_eip+0x18d>
f0100bf8:	83 e8 01             	sub    $0x1,%eax
f0100bfb:	83 ea 0c             	sub    $0xc,%edx
f0100bfe:	39 c7                	cmp    %eax,%edi
f0100c00:	7f 23                	jg     f0100c25 <debuginfo_eip+0x1b4>
	       && stabs[lline].n_type != N_SOL
f0100c02:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100c06:	80 f9 84             	cmp    $0x84,%cl
f0100c09:	74 7e                	je     f0100c89 <debuginfo_eip+0x218>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c0b:	80 f9 64             	cmp    $0x64,%cl
f0100c0e:	75 e8                	jne    f0100bf8 <debuginfo_eip+0x187>
f0100c10:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0100c14:	74 e2                	je     f0100bf8 <debuginfo_eip+0x187>
f0100c16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100c19:	eb 71                	jmp    f0100c8c <debuginfo_eip+0x21b>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c1b:	81 c2 f5 59 10 f0    	add    $0xf01059f5,%edx
f0100c21:	89 13                	mov    %edx,(%ebx)
f0100c23:	eb 03                	jmp    f0100c28 <debuginfo_eip+0x1b7>
f0100c25:	8b 5d 0c             	mov    0xc(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c28:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c2b:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c2e:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c33:	39 f2                	cmp    %esi,%edx
f0100c35:	7d 76                	jge    f0100cad <debuginfo_eip+0x23c>
		for (lline = lfun + 1;
f0100c37:	83 c2 01             	add    $0x1,%edx
f0100c3a:	89 d0                	mov    %edx,%eax
f0100c3c:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100c3f:	8d 14 95 dc 20 10 f0 	lea    -0xfefdf24(,%edx,4),%edx
f0100c46:	eb 04                	jmp    f0100c4c <debuginfo_eip+0x1db>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100c48:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100c4c:	39 c6                	cmp    %eax,%esi
f0100c4e:	7e 32                	jle    f0100c82 <debuginfo_eip+0x211>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c50:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100c54:	83 c0 01             	add    $0x1,%eax
f0100c57:	83 c2 0c             	add    $0xc,%edx
f0100c5a:	80 f9 a0             	cmp    $0xa0,%cl
f0100c5d:	74 e9                	je     f0100c48 <debuginfo_eip+0x1d7>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c5f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c64:	eb 47                	jmp    f0100cad <debuginfo_eip+0x23c>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100c66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c6b:	eb 40                	jmp    f0100cad <debuginfo_eip+0x23c>
f0100c6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c72:	eb 39                	jmp    f0100cad <debuginfo_eip+0x23c>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100c74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c79:	eb 32                	jmp    f0100cad <debuginfo_eip+0x23c>
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if(lline>rline)
	{
		return -1;
f0100c7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c80:	eb 2b                	jmp    f0100cad <debuginfo_eip+0x23c>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c82:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c87:	eb 24                	jmp    f0100cad <debuginfo_eip+0x23c>
f0100c89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c8c:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100c8f:	8b 14 85 dc 20 10 f0 	mov    -0xfefdf24(,%eax,4),%edx
f0100c96:	b8 d8 72 10 f0       	mov    $0xf01072d8,%eax
f0100c9b:	2d f5 59 10 f0       	sub    $0xf01059f5,%eax
f0100ca0:	39 c2                	cmp    %eax,%edx
f0100ca2:	0f 82 73 ff ff ff    	jb     f0100c1b <debuginfo_eip+0x1aa>
f0100ca8:	e9 7b ff ff ff       	jmp    f0100c28 <debuginfo_eip+0x1b7>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
}
f0100cad:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cb0:	5b                   	pop    %ebx
f0100cb1:	5e                   	pop    %esi
f0100cb2:	5f                   	pop    %edi
f0100cb3:	5d                   	pop    %ebp
f0100cb4:	c3                   	ret    

f0100cb5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100cb5:	55                   	push   %ebp
f0100cb6:	89 e5                	mov    %esp,%ebp
f0100cb8:	57                   	push   %edi
f0100cb9:	56                   	push   %esi
f0100cba:	53                   	push   %ebx
f0100cbb:	83 ec 1c             	sub    $0x1c,%esp
f0100cbe:	89 c7                	mov    %eax,%edi
f0100cc0:	89 d6                	mov    %edx,%esi
f0100cc2:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cc5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100cc8:	89 d1                	mov    %edx,%ecx
f0100cca:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100ccd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100cd0:	8b 45 10             	mov    0x10(%ebp),%eax
f0100cd3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100cd6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100cd9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100ce0:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f0100ce3:	72 05                	jb     f0100cea <printnum+0x35>
f0100ce5:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0100ce8:	77 3e                	ja     f0100d28 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100cea:	83 ec 0c             	sub    $0xc,%esp
f0100ced:	ff 75 18             	pushl  0x18(%ebp)
f0100cf0:	83 eb 01             	sub    $0x1,%ebx
f0100cf3:	53                   	push   %ebx
f0100cf4:	50                   	push   %eax
f0100cf5:	83 ec 08             	sub    $0x8,%esp
f0100cf8:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100cfb:	ff 75 e0             	pushl  -0x20(%ebp)
f0100cfe:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d01:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d04:	e8 47 09 00 00       	call   f0101650 <__udivdi3>
f0100d09:	83 c4 18             	add    $0x18,%esp
f0100d0c:	52                   	push   %edx
f0100d0d:	50                   	push   %eax
f0100d0e:	89 f2                	mov    %esi,%edx
f0100d10:	89 f8                	mov    %edi,%eax
f0100d12:	e8 9e ff ff ff       	call   f0100cb5 <printnum>
f0100d17:	83 c4 20             	add    $0x20,%esp
f0100d1a:	eb 13                	jmp    f0100d2f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d1c:	83 ec 08             	sub    $0x8,%esp
f0100d1f:	56                   	push   %esi
f0100d20:	ff 75 18             	pushl  0x18(%ebp)
f0100d23:	ff d7                	call   *%edi
f0100d25:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d28:	83 eb 01             	sub    $0x1,%ebx
f0100d2b:	85 db                	test   %ebx,%ebx
f0100d2d:	7f ed                	jg     f0100d1c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d2f:	83 ec 08             	sub    $0x8,%esp
f0100d32:	56                   	push   %esi
f0100d33:	83 ec 04             	sub    $0x4,%esp
f0100d36:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d39:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d3c:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d3f:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d42:	e8 39 0a 00 00       	call   f0101780 <__umoddi3>
f0100d47:	83 c4 14             	add    $0x14,%esp
f0100d4a:	0f be 80 c9 1e 10 f0 	movsbl -0xfefe137(%eax),%eax
f0100d51:	50                   	push   %eax
f0100d52:	ff d7                	call   *%edi
f0100d54:	83 c4 10             	add    $0x10,%esp
}
f0100d57:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d5a:	5b                   	pop    %ebx
f0100d5b:	5e                   	pop    %esi
f0100d5c:	5f                   	pop    %edi
f0100d5d:	5d                   	pop    %ebp
f0100d5e:	c3                   	ret    

f0100d5f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100d5f:	55                   	push   %ebp
f0100d60:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d62:	83 fa 01             	cmp    $0x1,%edx
f0100d65:	7e 0e                	jle    f0100d75 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100d67:	8b 10                	mov    (%eax),%edx
f0100d69:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100d6c:	89 08                	mov    %ecx,(%eax)
f0100d6e:	8b 02                	mov    (%edx),%eax
f0100d70:	8b 52 04             	mov    0x4(%edx),%edx
f0100d73:	eb 22                	jmp    f0100d97 <getuint+0x38>
	else if (lflag)
f0100d75:	85 d2                	test   %edx,%edx
f0100d77:	74 10                	je     f0100d89 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100d79:	8b 10                	mov    (%eax),%edx
f0100d7b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d7e:	89 08                	mov    %ecx,(%eax)
f0100d80:	8b 02                	mov    (%edx),%eax
f0100d82:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d87:	eb 0e                	jmp    f0100d97 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100d89:	8b 10                	mov    (%eax),%edx
f0100d8b:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d8e:	89 08                	mov    %ecx,(%eax)
f0100d90:	8b 02                	mov    (%edx),%eax
f0100d92:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100d97:	5d                   	pop    %ebp
f0100d98:	c3                   	ret    

f0100d99 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100d99:	55                   	push   %ebp
f0100d9a:	89 e5                	mov    %esp,%ebp
f0100d9c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100d9f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100da3:	8b 10                	mov    (%eax),%edx
f0100da5:	3b 50 04             	cmp    0x4(%eax),%edx
f0100da8:	73 0a                	jae    f0100db4 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100daa:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100dad:	89 08                	mov    %ecx,(%eax)
f0100daf:	8b 45 08             	mov    0x8(%ebp),%eax
f0100db2:	88 02                	mov    %al,(%edx)
}
f0100db4:	5d                   	pop    %ebp
f0100db5:	c3                   	ret    

f0100db6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100db6:	55                   	push   %ebp
f0100db7:	89 e5                	mov    %esp,%ebp
f0100db9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100dbc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100dbf:	50                   	push   %eax
f0100dc0:	ff 75 10             	pushl  0x10(%ebp)
f0100dc3:	ff 75 0c             	pushl  0xc(%ebp)
f0100dc6:	ff 75 08             	pushl  0x8(%ebp)
f0100dc9:	e8 05 00 00 00       	call   f0100dd3 <vprintfmt>
	va_end(ap);
f0100dce:	83 c4 10             	add    $0x10,%esp
}
f0100dd1:	c9                   	leave  
f0100dd2:	c3                   	ret    

f0100dd3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100dd3:	55                   	push   %ebp
f0100dd4:	89 e5                	mov    %esp,%ebp
f0100dd6:	57                   	push   %edi
f0100dd7:	56                   	push   %esi
f0100dd8:	53                   	push   %ebx
f0100dd9:	83 ec 2c             	sub    $0x2c,%esp
f0100ddc:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ddf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100de2:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100de5:	eb 12                	jmp    f0100df9 <vprintfmt+0x26>

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
		{
			if (ch == '\0')
f0100de7:	85 c0                	test   %eax,%eax
f0100de9:	0f 84 90 03 00 00    	je     f010117f <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
f0100def:	83 ec 08             	sub    $0x8,%esp
f0100df2:	53                   	push   %ebx
f0100df3:	50                   	push   %eax
f0100df4:	ff d6                	call   *%esi
f0100df6:	83 c4 10             	add    $0x10,%esp
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
f0100df9:	83 c7 01             	add    $0x1,%edi
f0100dfc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100e00:	83 f8 25             	cmp    $0x25,%eax
f0100e03:	75 e2                	jne    f0100de7 <vprintfmt+0x14>
f0100e05:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100e09:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100e10:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100e17:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100e1e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e23:	eb 07                	jmp    f0100e2c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100e25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		{

			// flag to pad on the right
			case '-':
				padc = '-';
f0100e28:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100e2c:	8d 47 01             	lea    0x1(%edi),%eax
f0100e2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e32:	0f b6 07             	movzbl (%edi),%eax
f0100e35:	0f b6 c8             	movzbl %al,%ecx
f0100e38:	83 e8 23             	sub    $0x23,%eax
f0100e3b:	3c 55                	cmp    $0x55,%al
f0100e3d:	0f 87 21 03 00 00    	ja     f0101164 <vprintfmt+0x391>
f0100e43:	0f b6 c0             	movzbl %al,%eax
f0100e46:	ff 24 85 58 1f 10 f0 	jmp    *-0xfefe0a8(,%eax,4)
f0100e4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				padc = '-';
				goto reswitch;

			// flag to pad with 0's instead of spaces
			case '0':
				padc = '0';
f0100e50:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100e54:	eb d6                	jmp    f0100e2c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100e56:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e59:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e5e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
					precision = precision * 10 + ch - '0';
f0100e61:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100e64:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
					ch = *fmt;
f0100e68:	0f be 0f             	movsbl (%edi),%ecx
					if (ch < '0' || ch > '9')
f0100e6b:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0100e6e:	83 fa 09             	cmp    $0x9,%edx
f0100e71:	77 39                	ja     f0100eac <vprintfmt+0xd9>
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
f0100e73:	83 c7 01             	add    $0x1,%edi
					precision = precision * 10 + ch - '0';
					ch = *fmt;
					if (ch < '0' || ch > '9')
						break;
				}
f0100e76:	eb e9                	jmp    f0100e61 <vprintfmt+0x8e>
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
f0100e78:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e7b:	8d 48 04             	lea    0x4(%eax),%ecx
f0100e7e:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100e81:	8b 00                	mov    (%eax),%eax
f0100e83:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100e86:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				}
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
				goto process_precision;
f0100e89:	eb 27                	jmp    f0100eb2 <vprintfmt+0xdf>
f0100e8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e8e:	85 c0                	test   %eax,%eax
f0100e90:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e95:	0f 49 c8             	cmovns %eax,%ecx
f0100e98:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100e9b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e9e:	eb 8c                	jmp    f0100e2c <vprintfmt+0x59>
f0100ea0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				if (width < 0)
					width = 0;
				goto reswitch;

			case '#':
				altflag = 1;
f0100ea3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				goto reswitch;
f0100eaa:	eb 80                	jmp    f0100e2c <vprintfmt+0x59>
f0100eac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100eaf:	89 45 d0             	mov    %eax,-0x30(%ebp)

			process_precision:
				if (width < 0)
f0100eb2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100eb6:	0f 89 70 ff ff ff    	jns    f0100e2c <vprintfmt+0x59>
					width = precision, precision = -1;
f0100ebc:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100ebf:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ec2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100ec9:	e9 5e ff ff ff       	jmp    f0100e2c <vprintfmt+0x59>
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
f0100ece:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100ed1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
				goto reswitch;
f0100ed4:	e9 53 ff ff ff       	jmp    f0100e2c <vprintfmt+0x59>

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
f0100ed9:	8b 45 14             	mov    0x14(%ebp),%eax
f0100edc:	8d 50 04             	lea    0x4(%eax),%edx
f0100edf:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ee2:	83 ec 08             	sub    $0x8,%esp
f0100ee5:	53                   	push   %ebx
f0100ee6:	ff 30                	pushl  (%eax)
f0100ee8:	ff d6                	call   *%esi
				break;
f0100eea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100eed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
				break;
f0100ef0:	e9 04 ff ff ff       	jmp    f0100df9 <vprintfmt+0x26>

			// error message
			case 'e':
				err = va_arg(ap, int);
f0100ef5:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ef8:	8d 50 04             	lea    0x4(%eax),%edx
f0100efb:	89 55 14             	mov    %edx,0x14(%ebp)
f0100efe:	8b 00                	mov    (%eax),%eax
f0100f00:	99                   	cltd   
f0100f01:	31 d0                	xor    %edx,%eax
f0100f03:	29 d0                	sub    %edx,%eax
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f05:	83 f8 06             	cmp    $0x6,%eax
f0100f08:	7f 0b                	jg     f0100f15 <vprintfmt+0x142>
f0100f0a:	8b 14 85 b0 20 10 f0 	mov    -0xfefdf50(,%eax,4),%edx
f0100f11:	85 d2                	test   %edx,%edx
f0100f13:	75 18                	jne    f0100f2d <vprintfmt+0x15a>
					printfmt(putch, putdat, "error %d", err);
f0100f15:	50                   	push   %eax
f0100f16:	68 e1 1e 10 f0       	push   $0xf0101ee1
f0100f1b:	53                   	push   %ebx
f0100f1c:	56                   	push   %esi
f0100f1d:	e8 94 fe ff ff       	call   f0100db6 <printfmt>
f0100f22:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100f25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			case 'e':
				err = va_arg(ap, int);
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
					printfmt(putch, putdat, "error %d", err);
f0100f28:	e9 cc fe ff ff       	jmp    f0100df9 <vprintfmt+0x26>
				else
					printfmt(putch, putdat, "%s", p);
f0100f2d:	52                   	push   %edx
f0100f2e:	68 ea 1e 10 f0       	push   $0xf0101eea
f0100f33:	53                   	push   %ebx
f0100f34:	56                   	push   %esi
f0100f35:	e8 7c fe ff ff       	call   f0100db6 <printfmt>
f0100f3a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0100f3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f40:	e9 b4 fe ff ff       	jmp    f0100df9 <vprintfmt+0x26>
f0100f45:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100f48:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100f4b:	89 45 cc             	mov    %eax,-0x34(%ebp)
					printfmt(putch, putdat, "%s", p);
				break;

			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
f0100f4e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f51:	8d 50 04             	lea    0x4(%eax),%edx
f0100f54:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f57:	8b 38                	mov    (%eax),%edi
					p = "(null)";
f0100f59:	85 ff                	test   %edi,%edi
f0100f5b:	ba da 1e 10 f0       	mov    $0xf0101eda,%edx
f0100f60:	0f 44 fa             	cmove  %edx,%edi
				if (width > 0 && padc != '-')
f0100f63:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100f67:	0f 84 92 00 00 00    	je     f0100fff <vprintfmt+0x22c>
f0100f6d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0100f71:	0f 8e 96 00 00 00    	jle    f010100d <vprintfmt+0x23a>
					for (width -= strnlen(p, precision); width > 0; width--)
f0100f77:	83 ec 08             	sub    $0x8,%esp
f0100f7a:	51                   	push   %ecx
f0100f7b:	57                   	push   %edi
f0100f7c:	e8 5f 03 00 00       	call   f01012e0 <strnlen>
f0100f81:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100f84:	29 c1                	sub    %eax,%ecx
f0100f86:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100f89:	83 c4 10             	add    $0x10,%esp
						putch(padc, putdat);
f0100f8c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100f90:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f93:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100f96:	89 cf                	mov    %ecx,%edi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
f0100f98:	eb 0f                	jmp    f0100fa9 <vprintfmt+0x1d6>
						putch(padc, putdat);
f0100f9a:	83 ec 08             	sub    $0x8,%esp
f0100f9d:	53                   	push   %ebx
f0100f9e:	ff 75 e0             	pushl  -0x20(%ebp)
f0100fa1:	ff d6                	call   *%esi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
f0100fa3:	83 ef 01             	sub    $0x1,%edi
f0100fa6:	83 c4 10             	add    $0x10,%esp
f0100fa9:	85 ff                	test   %edi,%edi
f0100fab:	7f ed                	jg     f0100f9a <vprintfmt+0x1c7>
f0100fad:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100fb0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100fb3:	85 c9                	test   %ecx,%ecx
f0100fb5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fba:	0f 49 c1             	cmovns %ecx,%eax
f0100fbd:	29 c1                	sub    %eax,%ecx
f0100fbf:	89 75 08             	mov    %esi,0x8(%ebp)
f0100fc2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100fc5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100fc8:	89 cb                	mov    %ecx,%ebx
f0100fca:	eb 4d                	jmp    f0101019 <vprintfmt+0x246>
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
f0100fcc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100fd0:	74 1b                	je     f0100fed <vprintfmt+0x21a>
f0100fd2:	0f be c0             	movsbl %al,%eax
f0100fd5:	83 e8 20             	sub    $0x20,%eax
f0100fd8:	83 f8 5e             	cmp    $0x5e,%eax
f0100fdb:	76 10                	jbe    f0100fed <vprintfmt+0x21a>
						putch('?', putdat);
f0100fdd:	83 ec 08             	sub    $0x8,%esp
f0100fe0:	ff 75 0c             	pushl  0xc(%ebp)
f0100fe3:	6a 3f                	push   $0x3f
f0100fe5:	ff 55 08             	call   *0x8(%ebp)
f0100fe8:	83 c4 10             	add    $0x10,%esp
f0100feb:	eb 0d                	jmp    f0100ffa <vprintfmt+0x227>
					else
						putch(ch, putdat);
f0100fed:	83 ec 08             	sub    $0x8,%esp
f0100ff0:	ff 75 0c             	pushl  0xc(%ebp)
f0100ff3:	52                   	push   %edx
f0100ff4:	ff 55 08             	call   *0x8(%ebp)
f0100ff7:	83 c4 10             	add    $0x10,%esp
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100ffa:	83 eb 01             	sub    $0x1,%ebx
f0100ffd:	eb 1a                	jmp    f0101019 <vprintfmt+0x246>
f0100fff:	89 75 08             	mov    %esi,0x8(%ebp)
f0101002:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101005:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101008:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010100b:	eb 0c                	jmp    f0101019 <vprintfmt+0x246>
f010100d:	89 75 08             	mov    %esi,0x8(%ebp)
f0101010:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101013:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101016:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101019:	83 c7 01             	add    $0x1,%edi
f010101c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101020:	0f be d0             	movsbl %al,%edx
f0101023:	85 d2                	test   %edx,%edx
f0101025:	74 23                	je     f010104a <vprintfmt+0x277>
f0101027:	85 f6                	test   %esi,%esi
f0101029:	78 a1                	js     f0100fcc <vprintfmt+0x1f9>
f010102b:	83 ee 01             	sub    $0x1,%esi
f010102e:	79 9c                	jns    f0100fcc <vprintfmt+0x1f9>
f0101030:	89 df                	mov    %ebx,%edi
f0101032:	8b 75 08             	mov    0x8(%ebp),%esi
f0101035:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101038:	eb 18                	jmp    f0101052 <vprintfmt+0x27f>
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
					putch(' ', putdat);
f010103a:	83 ec 08             	sub    $0x8,%esp
f010103d:	53                   	push   %ebx
f010103e:	6a 20                	push   $0x20
f0101040:	ff d6                	call   *%esi
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
f0101042:	83 ef 01             	sub    $0x1,%edi
f0101045:	83 c4 10             	add    $0x10,%esp
f0101048:	eb 08                	jmp    f0101052 <vprintfmt+0x27f>
f010104a:	89 df                	mov    %ebx,%edi
f010104c:	8b 75 08             	mov    0x8(%ebp),%esi
f010104f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101052:	85 ff                	test   %edi,%edi
f0101054:	7f e4                	jg     f010103a <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f0101056:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101059:	e9 9b fd ff ff       	jmp    f0100df9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010105e:	83 fa 01             	cmp    $0x1,%edx
f0101061:	7e 16                	jle    f0101079 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
f0101063:	8b 45 14             	mov    0x14(%ebp),%eax
f0101066:	8d 50 08             	lea    0x8(%eax),%edx
f0101069:	89 55 14             	mov    %edx,0x14(%ebp)
f010106c:	8b 50 04             	mov    0x4(%eax),%edx
f010106f:	8b 00                	mov    (%eax),%eax
f0101071:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101074:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101077:	eb 32                	jmp    f01010ab <vprintfmt+0x2d8>
	else if (lflag)
f0101079:	85 d2                	test   %edx,%edx
f010107b:	74 18                	je     f0101095 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
f010107d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101080:	8d 50 04             	lea    0x4(%eax),%edx
f0101083:	89 55 14             	mov    %edx,0x14(%ebp)
f0101086:	8b 00                	mov    (%eax),%eax
f0101088:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010108b:	89 c1                	mov    %eax,%ecx
f010108d:	c1 f9 1f             	sar    $0x1f,%ecx
f0101090:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101093:	eb 16                	jmp    f01010ab <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
f0101095:	8b 45 14             	mov    0x14(%ebp),%eax
f0101098:	8d 50 04             	lea    0x4(%eax),%edx
f010109b:	89 55 14             	mov    %edx,0x14(%ebp)
f010109e:	8b 00                	mov    (%eax),%eax
f01010a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010a3:	89 c1                	mov    %eax,%ecx
f01010a5:	c1 f9 1f             	sar    $0x1f,%ecx
f01010a8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(' ', putdat);
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
f01010ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010ae:	8b 55 dc             	mov    -0x24(%ebp),%edx
				if ((long long) num < 0) {
					putch('-', putdat);
					num = -(long long) num;
				}
				base = 10;
f01010b1:	b9 0a 00 00 00       	mov    $0xa,%ecx
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
				if ((long long) num < 0) {
f01010b6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01010ba:	79 74                	jns    f0101130 <vprintfmt+0x35d>
					putch('-', putdat);
f01010bc:	83 ec 08             	sub    $0x8,%esp
f01010bf:	53                   	push   %ebx
f01010c0:	6a 2d                	push   $0x2d
f01010c2:	ff d6                	call   *%esi
					num = -(long long) num;
f01010c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01010ca:	f7 d8                	neg    %eax
f01010cc:	83 d2 00             	adc    $0x0,%edx
f01010cf:	f7 da                	neg    %edx
f01010d1:	83 c4 10             	add    $0x10,%esp
				}
				base = 10;
f01010d4:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01010d9:	eb 55                	jmp    f0101130 <vprintfmt+0x35d>
				goto number;

			// unsigned decimal
			case 'u':
				num = getuint(&ap, lflag);
f01010db:	8d 45 14             	lea    0x14(%ebp),%eax
f01010de:	e8 7c fc ff ff       	call   f0100d5f <getuint>
				base = 10;
f01010e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
				goto number;
f01010e8:	eb 46                	jmp    f0101130 <vprintfmt+0x35d>
				// Replace this with your code.
				/*putch('X', putdat);
				putch('X', putdat);
				putch('X', putdat);*/
				
				num = getuint(&ap, lflag);
f01010ea:	8d 45 14             	lea    0x14(%ebp),%eax
f01010ed:	e8 6d fc ff ff       	call   f0100d5f <getuint>
				base = 8;
f01010f2:	b9 08 00 00 00       	mov    $0x8,%ecx
				goto number;
f01010f7:	eb 37                	jmp    f0101130 <vprintfmt+0x35d>

			// pointer
			case 'p':
				putch('0', putdat);
f01010f9:	83 ec 08             	sub    $0x8,%esp
f01010fc:	53                   	push   %ebx
f01010fd:	6a 30                	push   $0x30
f01010ff:	ff d6                	call   *%esi
				putch('x', putdat);
f0101101:	83 c4 08             	add    $0x8,%esp
f0101104:	53                   	push   %ebx
f0101105:	6a 78                	push   $0x78
f0101107:	ff d6                	call   *%esi
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
f0101109:	8b 45 14             	mov    0x14(%ebp),%eax
f010110c:	8d 50 04             	lea    0x4(%eax),%edx
f010110f:	89 55 14             	mov    %edx,0x14(%ebp)

			// pointer
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
f0101112:	8b 00                	mov    (%eax),%eax
f0101114:	ba 00 00 00 00       	mov    $0x0,%edx
					(uintptr_t) va_arg(ap, void *);
				base = 16;
				goto number;
f0101119:	83 c4 10             	add    $0x10,%esp
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
				base = 16;
f010111c:	b9 10 00 00 00       	mov    $0x10,%ecx
				goto number;
f0101121:	eb 0d                	jmp    f0101130 <vprintfmt+0x35d>

			// (unsigned) hexadecimal
			case 'x':
				num = getuint(&ap, lflag);
f0101123:	8d 45 14             	lea    0x14(%ebp),%eax
f0101126:	e8 34 fc ff ff       	call   f0100d5f <getuint>
				base = 16;
f010112b:	b9 10 00 00 00       	mov    $0x10,%ecx
			number:
				printnum(putch, putdat, num, base, width, padc);
f0101130:	83 ec 0c             	sub    $0xc,%esp
f0101133:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101137:	57                   	push   %edi
f0101138:	ff 75 e0             	pushl  -0x20(%ebp)
f010113b:	51                   	push   %ecx
f010113c:	52                   	push   %edx
f010113d:	50                   	push   %eax
f010113e:	89 da                	mov    %ebx,%edx
f0101140:	89 f0                	mov    %esi,%eax
f0101142:	e8 6e fb ff ff       	call   f0100cb5 <printnum>
				break;
f0101147:	83 c4 20             	add    $0x20,%esp
f010114a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010114d:	e9 a7 fc ff ff       	jmp    f0100df9 <vprintfmt+0x26>

			// escaped '%' character
			case '%':
				putch(ch, putdat);
f0101152:	83 ec 08             	sub    $0x8,%esp
f0101155:	53                   	push   %ebx
f0101156:	51                   	push   %ecx
f0101157:	ff d6                	call   *%esi
				break;
f0101159:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
f010115c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				break;

			// escaped '%' character
			case '%':
				putch(ch, putdat);
				break;
f010115f:	e9 95 fc ff ff       	jmp    f0100df9 <vprintfmt+0x26>

			// unrecognized escape sequence - just print it literally
			default:
				putch('%', putdat);
f0101164:	83 ec 08             	sub    $0x8,%esp
f0101167:	53                   	push   %ebx
f0101168:	6a 25                	push   $0x25
f010116a:	ff d6                	call   *%esi
				for (fmt--; fmt[-1] != '%'; fmt--)
f010116c:	83 c4 10             	add    $0x10,%esp
f010116f:	eb 03                	jmp    f0101174 <vprintfmt+0x3a1>
f0101171:	83 ef 01             	sub    $0x1,%edi
f0101174:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0101178:	75 f7                	jne    f0101171 <vprintfmt+0x39e>
f010117a:	e9 7a fc ff ff       	jmp    f0100df9 <vprintfmt+0x26>
					/* do nothing */;
				break;
		}
	}
}
f010117f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101182:	5b                   	pop    %ebx
f0101183:	5e                   	pop    %esi
f0101184:	5f                   	pop    %edi
f0101185:	5d                   	pop    %ebp
f0101186:	c3                   	ret    

f0101187 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101187:	55                   	push   %ebp
f0101188:	89 e5                	mov    %esp,%ebp
f010118a:	83 ec 18             	sub    $0x18,%esp
f010118d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101190:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101193:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101196:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010119a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010119d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01011a4:	85 c0                	test   %eax,%eax
f01011a6:	74 26                	je     f01011ce <vsnprintf+0x47>
f01011a8:	85 d2                	test   %edx,%edx
f01011aa:	7e 22                	jle    f01011ce <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01011ac:	ff 75 14             	pushl  0x14(%ebp)
f01011af:	ff 75 10             	pushl  0x10(%ebp)
f01011b2:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01011b5:	50                   	push   %eax
f01011b6:	68 99 0d 10 f0       	push   $0xf0100d99
f01011bb:	e8 13 fc ff ff       	call   f0100dd3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01011c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01011c3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01011c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011c9:	83 c4 10             	add    $0x10,%esp
f01011cc:	eb 05                	jmp    f01011d3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01011ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01011d3:	c9                   	leave  
f01011d4:	c3                   	ret    

f01011d5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01011d5:	55                   	push   %ebp
f01011d6:	89 e5                	mov    %esp,%ebp
f01011d8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01011db:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01011de:	50                   	push   %eax
f01011df:	ff 75 10             	pushl  0x10(%ebp)
f01011e2:	ff 75 0c             	pushl  0xc(%ebp)
f01011e5:	ff 75 08             	pushl  0x8(%ebp)
f01011e8:	e8 9a ff ff ff       	call   f0101187 <vsnprintf>
	va_end(ap);

	return rc;
}
f01011ed:	c9                   	leave  
f01011ee:	c3                   	ret    

f01011ef <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01011ef:	55                   	push   %ebp
f01011f0:	89 e5                	mov    %esp,%ebp
f01011f2:	57                   	push   %edi
f01011f3:	56                   	push   %esi
f01011f4:	53                   	push   %ebx
f01011f5:	83 ec 0c             	sub    $0xc,%esp
f01011f8:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01011fb:	85 c0                	test   %eax,%eax
f01011fd:	74 11                	je     f0101210 <readline+0x21>
		cprintf("%s", prompt);
f01011ff:	83 ec 08             	sub    $0x8,%esp
f0101202:	50                   	push   %eax
f0101203:	68 ea 1e 10 f0       	push   $0xf0101eea
f0101208:	e8 4e f7 ff ff       	call   f010095b <cprintf>
f010120d:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101210:	83 ec 0c             	sub    $0xc,%esp
f0101213:	6a 00                	push   $0x0
f0101215:	e8 50 f4 ff ff       	call   f010066a <iscons>
f010121a:	89 c7                	mov    %eax,%edi
f010121c:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010121f:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101224:	e8 30 f4 ff ff       	call   f0100659 <getchar>
f0101229:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010122b:	85 c0                	test   %eax,%eax
f010122d:	79 18                	jns    f0101247 <readline+0x58>
			cprintf("read error: %e\n", c);
f010122f:	83 ec 08             	sub    $0x8,%esp
f0101232:	50                   	push   %eax
f0101233:	68 cc 20 10 f0       	push   $0xf01020cc
f0101238:	e8 1e f7 ff ff       	call   f010095b <cprintf>
			return NULL;
f010123d:	83 c4 10             	add    $0x10,%esp
f0101240:	b8 00 00 00 00       	mov    $0x0,%eax
f0101245:	eb 79                	jmp    f01012c0 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101247:	83 f8 7f             	cmp    $0x7f,%eax
f010124a:	0f 94 c2             	sete   %dl
f010124d:	83 f8 08             	cmp    $0x8,%eax
f0101250:	0f 94 c0             	sete   %al
f0101253:	08 c2                	or     %al,%dl
f0101255:	74 1a                	je     f0101271 <readline+0x82>
f0101257:	85 f6                	test   %esi,%esi
f0101259:	7e 16                	jle    f0101271 <readline+0x82>
			if (echoing)
f010125b:	85 ff                	test   %edi,%edi
f010125d:	74 0d                	je     f010126c <readline+0x7d>
				cputchar('\b');
f010125f:	83 ec 0c             	sub    $0xc,%esp
f0101262:	6a 08                	push   $0x8
f0101264:	e8 e0 f3 ff ff       	call   f0100649 <cputchar>
f0101269:	83 c4 10             	add    $0x10,%esp
			i--;
f010126c:	83 ee 01             	sub    $0x1,%esi
f010126f:	eb b3                	jmp    f0101224 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101271:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101277:	7f 20                	jg     f0101299 <readline+0xaa>
f0101279:	83 fb 1f             	cmp    $0x1f,%ebx
f010127c:	7e 1b                	jle    f0101299 <readline+0xaa>
			if (echoing)
f010127e:	85 ff                	test   %edi,%edi
f0101280:	74 0c                	je     f010128e <readline+0x9f>
				cputchar(c);
f0101282:	83 ec 0c             	sub    $0xc,%esp
f0101285:	53                   	push   %ebx
f0101286:	e8 be f3 ff ff       	call   f0100649 <cputchar>
f010128b:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010128e:	88 9e 80 25 11 f0    	mov    %bl,-0xfeeda80(%esi)
f0101294:	8d 76 01             	lea    0x1(%esi),%esi
f0101297:	eb 8b                	jmp    f0101224 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0101299:	83 fb 0d             	cmp    $0xd,%ebx
f010129c:	74 05                	je     f01012a3 <readline+0xb4>
f010129e:	83 fb 0a             	cmp    $0xa,%ebx
f01012a1:	75 81                	jne    f0101224 <readline+0x35>
			if (echoing)
f01012a3:	85 ff                	test   %edi,%edi
f01012a5:	74 0d                	je     f01012b4 <readline+0xc5>
				cputchar('\n');
f01012a7:	83 ec 0c             	sub    $0xc,%esp
f01012aa:	6a 0a                	push   $0xa
f01012ac:	e8 98 f3 ff ff       	call   f0100649 <cputchar>
f01012b1:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01012b4:	c6 86 80 25 11 f0 00 	movb   $0x0,-0xfeeda80(%esi)
			return buf;
f01012bb:	b8 80 25 11 f0       	mov    $0xf0112580,%eax
		}
	}
}
f01012c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012c3:	5b                   	pop    %ebx
f01012c4:	5e                   	pop    %esi
f01012c5:	5f                   	pop    %edi
f01012c6:	5d                   	pop    %ebp
f01012c7:	c3                   	ret    

f01012c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01012c8:	55                   	push   %ebp
f01012c9:	89 e5                	mov    %esp,%ebp
f01012cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01012ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01012d3:	eb 03                	jmp    f01012d8 <strlen+0x10>
		n++;
f01012d5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01012d8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01012dc:	75 f7                	jne    f01012d5 <strlen+0xd>
		n++;
	return n;
}
f01012de:	5d                   	pop    %ebp
f01012df:	c3                   	ret    

f01012e0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01012e0:	55                   	push   %ebp
f01012e1:	89 e5                	mov    %esp,%ebp
f01012e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01012e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01012ee:	eb 03                	jmp    f01012f3 <strnlen+0x13>
		n++;
f01012f0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012f3:	39 c2                	cmp    %eax,%edx
f01012f5:	74 08                	je     f01012ff <strnlen+0x1f>
f01012f7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01012fb:	75 f3                	jne    f01012f0 <strnlen+0x10>
f01012fd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01012ff:	5d                   	pop    %ebp
f0101300:	c3                   	ret    

f0101301 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101301:	55                   	push   %ebp
f0101302:	89 e5                	mov    %esp,%ebp
f0101304:	53                   	push   %ebx
f0101305:	8b 45 08             	mov    0x8(%ebp),%eax
f0101308:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010130b:	89 c2                	mov    %eax,%edx
f010130d:	83 c2 01             	add    $0x1,%edx
f0101310:	83 c1 01             	add    $0x1,%ecx
f0101313:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101317:	88 5a ff             	mov    %bl,-0x1(%edx)
f010131a:	84 db                	test   %bl,%bl
f010131c:	75 ef                	jne    f010130d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010131e:	5b                   	pop    %ebx
f010131f:	5d                   	pop    %ebp
f0101320:	c3                   	ret    

f0101321 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101321:	55                   	push   %ebp
f0101322:	89 e5                	mov    %esp,%ebp
f0101324:	53                   	push   %ebx
f0101325:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101328:	53                   	push   %ebx
f0101329:	e8 9a ff ff ff       	call   f01012c8 <strlen>
f010132e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101331:	ff 75 0c             	pushl  0xc(%ebp)
f0101334:	01 d8                	add    %ebx,%eax
f0101336:	50                   	push   %eax
f0101337:	e8 c5 ff ff ff       	call   f0101301 <strcpy>
	return dst;
}
f010133c:	89 d8                	mov    %ebx,%eax
f010133e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101341:	c9                   	leave  
f0101342:	c3                   	ret    

f0101343 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101343:	55                   	push   %ebp
f0101344:	89 e5                	mov    %esp,%ebp
f0101346:	56                   	push   %esi
f0101347:	53                   	push   %ebx
f0101348:	8b 75 08             	mov    0x8(%ebp),%esi
f010134b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010134e:	89 f3                	mov    %esi,%ebx
f0101350:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101353:	89 f2                	mov    %esi,%edx
f0101355:	eb 0f                	jmp    f0101366 <strncpy+0x23>
		*dst++ = *src;
f0101357:	83 c2 01             	add    $0x1,%edx
f010135a:	0f b6 01             	movzbl (%ecx),%eax
f010135d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101360:	80 39 01             	cmpb   $0x1,(%ecx)
f0101363:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101366:	39 da                	cmp    %ebx,%edx
f0101368:	75 ed                	jne    f0101357 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010136a:	89 f0                	mov    %esi,%eax
f010136c:	5b                   	pop    %ebx
f010136d:	5e                   	pop    %esi
f010136e:	5d                   	pop    %ebp
f010136f:	c3                   	ret    

f0101370 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101370:	55                   	push   %ebp
f0101371:	89 e5                	mov    %esp,%ebp
f0101373:	56                   	push   %esi
f0101374:	53                   	push   %ebx
f0101375:	8b 75 08             	mov    0x8(%ebp),%esi
f0101378:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010137b:	8b 55 10             	mov    0x10(%ebp),%edx
f010137e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101380:	85 d2                	test   %edx,%edx
f0101382:	74 21                	je     f01013a5 <strlcpy+0x35>
f0101384:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101388:	89 f2                	mov    %esi,%edx
f010138a:	eb 09                	jmp    f0101395 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010138c:	83 c2 01             	add    $0x1,%edx
f010138f:	83 c1 01             	add    $0x1,%ecx
f0101392:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101395:	39 c2                	cmp    %eax,%edx
f0101397:	74 09                	je     f01013a2 <strlcpy+0x32>
f0101399:	0f b6 19             	movzbl (%ecx),%ebx
f010139c:	84 db                	test   %bl,%bl
f010139e:	75 ec                	jne    f010138c <strlcpy+0x1c>
f01013a0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01013a2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01013a5:	29 f0                	sub    %esi,%eax
}
f01013a7:	5b                   	pop    %ebx
f01013a8:	5e                   	pop    %esi
f01013a9:	5d                   	pop    %ebp
f01013aa:	c3                   	ret    

f01013ab <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01013ab:	55                   	push   %ebp
f01013ac:	89 e5                	mov    %esp,%ebp
f01013ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01013b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01013b4:	eb 06                	jmp    f01013bc <strcmp+0x11>
		p++, q++;
f01013b6:	83 c1 01             	add    $0x1,%ecx
f01013b9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01013bc:	0f b6 01             	movzbl (%ecx),%eax
f01013bf:	84 c0                	test   %al,%al
f01013c1:	74 04                	je     f01013c7 <strcmp+0x1c>
f01013c3:	3a 02                	cmp    (%edx),%al
f01013c5:	74 ef                	je     f01013b6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01013c7:	0f b6 c0             	movzbl %al,%eax
f01013ca:	0f b6 12             	movzbl (%edx),%edx
f01013cd:	29 d0                	sub    %edx,%eax
}
f01013cf:	5d                   	pop    %ebp
f01013d0:	c3                   	ret    

f01013d1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01013d1:	55                   	push   %ebp
f01013d2:	89 e5                	mov    %esp,%ebp
f01013d4:	53                   	push   %ebx
f01013d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01013d8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01013db:	89 c3                	mov    %eax,%ebx
f01013dd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01013e0:	eb 06                	jmp    f01013e8 <strncmp+0x17>
		n--, p++, q++;
f01013e2:	83 c0 01             	add    $0x1,%eax
f01013e5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01013e8:	39 d8                	cmp    %ebx,%eax
f01013ea:	74 15                	je     f0101401 <strncmp+0x30>
f01013ec:	0f b6 08             	movzbl (%eax),%ecx
f01013ef:	84 c9                	test   %cl,%cl
f01013f1:	74 04                	je     f01013f7 <strncmp+0x26>
f01013f3:	3a 0a                	cmp    (%edx),%cl
f01013f5:	74 eb                	je     f01013e2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01013f7:	0f b6 00             	movzbl (%eax),%eax
f01013fa:	0f b6 12             	movzbl (%edx),%edx
f01013fd:	29 d0                	sub    %edx,%eax
f01013ff:	eb 05                	jmp    f0101406 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101401:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101406:	5b                   	pop    %ebx
f0101407:	5d                   	pop    %ebp
f0101408:	c3                   	ret    

f0101409 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101409:	55                   	push   %ebp
f010140a:	89 e5                	mov    %esp,%ebp
f010140c:	8b 45 08             	mov    0x8(%ebp),%eax
f010140f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101413:	eb 07                	jmp    f010141c <strchr+0x13>
		if (*s == c)
f0101415:	38 ca                	cmp    %cl,%dl
f0101417:	74 0f                	je     f0101428 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101419:	83 c0 01             	add    $0x1,%eax
f010141c:	0f b6 10             	movzbl (%eax),%edx
f010141f:	84 d2                	test   %dl,%dl
f0101421:	75 f2                	jne    f0101415 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101423:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101428:	5d                   	pop    %ebp
f0101429:	c3                   	ret    

f010142a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010142a:	55                   	push   %ebp
f010142b:	89 e5                	mov    %esp,%ebp
f010142d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101430:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101434:	eb 03                	jmp    f0101439 <strfind+0xf>
f0101436:	83 c0 01             	add    $0x1,%eax
f0101439:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010143c:	84 d2                	test   %dl,%dl
f010143e:	74 04                	je     f0101444 <strfind+0x1a>
f0101440:	38 ca                	cmp    %cl,%dl
f0101442:	75 f2                	jne    f0101436 <strfind+0xc>
			break;
	return (char *) s;
}
f0101444:	5d                   	pop    %ebp
f0101445:	c3                   	ret    

f0101446 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101446:	55                   	push   %ebp
f0101447:	89 e5                	mov    %esp,%ebp
f0101449:	57                   	push   %edi
f010144a:	56                   	push   %esi
f010144b:	53                   	push   %ebx
f010144c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010144f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101452:	85 c9                	test   %ecx,%ecx
f0101454:	74 36                	je     f010148c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101456:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010145c:	75 28                	jne    f0101486 <memset+0x40>
f010145e:	f6 c1 03             	test   $0x3,%cl
f0101461:	75 23                	jne    f0101486 <memset+0x40>
		c &= 0xFF;
f0101463:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101467:	89 d3                	mov    %edx,%ebx
f0101469:	c1 e3 08             	shl    $0x8,%ebx
f010146c:	89 d6                	mov    %edx,%esi
f010146e:	c1 e6 18             	shl    $0x18,%esi
f0101471:	89 d0                	mov    %edx,%eax
f0101473:	c1 e0 10             	shl    $0x10,%eax
f0101476:	09 f0                	or     %esi,%eax
f0101478:	09 c2                	or     %eax,%edx
f010147a:	89 d0                	mov    %edx,%eax
f010147c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010147e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0101481:	fc                   	cld    
f0101482:	f3 ab                	rep stos %eax,%es:(%edi)
f0101484:	eb 06                	jmp    f010148c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101486:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101489:	fc                   	cld    
f010148a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010148c:	89 f8                	mov    %edi,%eax
f010148e:	5b                   	pop    %ebx
f010148f:	5e                   	pop    %esi
f0101490:	5f                   	pop    %edi
f0101491:	5d                   	pop    %ebp
f0101492:	c3                   	ret    

f0101493 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101493:	55                   	push   %ebp
f0101494:	89 e5                	mov    %esp,%ebp
f0101496:	57                   	push   %edi
f0101497:	56                   	push   %esi
f0101498:	8b 45 08             	mov    0x8(%ebp),%eax
f010149b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010149e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01014a1:	39 c6                	cmp    %eax,%esi
f01014a3:	73 35                	jae    f01014da <memmove+0x47>
f01014a5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01014a8:	39 d0                	cmp    %edx,%eax
f01014aa:	73 2e                	jae    f01014da <memmove+0x47>
		s += n;
		d += n;
f01014ac:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f01014af:	89 d6                	mov    %edx,%esi
f01014b1:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014b3:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01014b9:	75 13                	jne    f01014ce <memmove+0x3b>
f01014bb:	f6 c1 03             	test   $0x3,%cl
f01014be:	75 0e                	jne    f01014ce <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01014c0:	83 ef 04             	sub    $0x4,%edi
f01014c3:	8d 72 fc             	lea    -0x4(%edx),%esi
f01014c6:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01014c9:	fd                   	std    
f01014ca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014cc:	eb 09                	jmp    f01014d7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01014ce:	83 ef 01             	sub    $0x1,%edi
f01014d1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01014d4:	fd                   	std    
f01014d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01014d7:	fc                   	cld    
f01014d8:	eb 1d                	jmp    f01014f7 <memmove+0x64>
f01014da:	89 f2                	mov    %esi,%edx
f01014dc:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014de:	f6 c2 03             	test   $0x3,%dl
f01014e1:	75 0f                	jne    f01014f2 <memmove+0x5f>
f01014e3:	f6 c1 03             	test   $0x3,%cl
f01014e6:	75 0a                	jne    f01014f2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01014e8:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01014eb:	89 c7                	mov    %eax,%edi
f01014ed:	fc                   	cld    
f01014ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014f0:	eb 05                	jmp    f01014f7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01014f2:	89 c7                	mov    %eax,%edi
f01014f4:	fc                   	cld    
f01014f5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01014f7:	5e                   	pop    %esi
f01014f8:	5f                   	pop    %edi
f01014f9:	5d                   	pop    %ebp
f01014fa:	c3                   	ret    

f01014fb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01014fb:	55                   	push   %ebp
f01014fc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01014fe:	ff 75 10             	pushl  0x10(%ebp)
f0101501:	ff 75 0c             	pushl  0xc(%ebp)
f0101504:	ff 75 08             	pushl  0x8(%ebp)
f0101507:	e8 87 ff ff ff       	call   f0101493 <memmove>
}
f010150c:	c9                   	leave  
f010150d:	c3                   	ret    

f010150e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010150e:	55                   	push   %ebp
f010150f:	89 e5                	mov    %esp,%ebp
f0101511:	56                   	push   %esi
f0101512:	53                   	push   %ebx
f0101513:	8b 45 08             	mov    0x8(%ebp),%eax
f0101516:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101519:	89 c6                	mov    %eax,%esi
f010151b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010151e:	eb 1a                	jmp    f010153a <memcmp+0x2c>
		if (*s1 != *s2)
f0101520:	0f b6 08             	movzbl (%eax),%ecx
f0101523:	0f b6 1a             	movzbl (%edx),%ebx
f0101526:	38 d9                	cmp    %bl,%cl
f0101528:	74 0a                	je     f0101534 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010152a:	0f b6 c1             	movzbl %cl,%eax
f010152d:	0f b6 db             	movzbl %bl,%ebx
f0101530:	29 d8                	sub    %ebx,%eax
f0101532:	eb 0f                	jmp    f0101543 <memcmp+0x35>
		s1++, s2++;
f0101534:	83 c0 01             	add    $0x1,%eax
f0101537:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010153a:	39 f0                	cmp    %esi,%eax
f010153c:	75 e2                	jne    f0101520 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010153e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101543:	5b                   	pop    %ebx
f0101544:	5e                   	pop    %esi
f0101545:	5d                   	pop    %ebp
f0101546:	c3                   	ret    

f0101547 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101547:	55                   	push   %ebp
f0101548:	89 e5                	mov    %esp,%ebp
f010154a:	8b 45 08             	mov    0x8(%ebp),%eax
f010154d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101550:	89 c2                	mov    %eax,%edx
f0101552:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101555:	eb 07                	jmp    f010155e <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101557:	38 08                	cmp    %cl,(%eax)
f0101559:	74 07                	je     f0101562 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010155b:	83 c0 01             	add    $0x1,%eax
f010155e:	39 d0                	cmp    %edx,%eax
f0101560:	72 f5                	jb     f0101557 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101562:	5d                   	pop    %ebp
f0101563:	c3                   	ret    

f0101564 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101564:	55                   	push   %ebp
f0101565:	89 e5                	mov    %esp,%ebp
f0101567:	57                   	push   %edi
f0101568:	56                   	push   %esi
f0101569:	53                   	push   %ebx
f010156a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010156d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101570:	eb 03                	jmp    f0101575 <strtol+0x11>
		s++;
f0101572:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101575:	0f b6 01             	movzbl (%ecx),%eax
f0101578:	3c 09                	cmp    $0x9,%al
f010157a:	74 f6                	je     f0101572 <strtol+0xe>
f010157c:	3c 20                	cmp    $0x20,%al
f010157e:	74 f2                	je     f0101572 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101580:	3c 2b                	cmp    $0x2b,%al
f0101582:	75 0a                	jne    f010158e <strtol+0x2a>
		s++;
f0101584:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101587:	bf 00 00 00 00       	mov    $0x0,%edi
f010158c:	eb 10                	jmp    f010159e <strtol+0x3a>
f010158e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101593:	3c 2d                	cmp    $0x2d,%al
f0101595:	75 07                	jne    f010159e <strtol+0x3a>
		s++, neg = 1;
f0101597:	8d 49 01             	lea    0x1(%ecx),%ecx
f010159a:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010159e:	85 db                	test   %ebx,%ebx
f01015a0:	0f 94 c0             	sete   %al
f01015a3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01015a9:	75 19                	jne    f01015c4 <strtol+0x60>
f01015ab:	80 39 30             	cmpb   $0x30,(%ecx)
f01015ae:	75 14                	jne    f01015c4 <strtol+0x60>
f01015b0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01015b4:	0f 85 82 00 00 00    	jne    f010163c <strtol+0xd8>
		s += 2, base = 16;
f01015ba:	83 c1 02             	add    $0x2,%ecx
f01015bd:	bb 10 00 00 00       	mov    $0x10,%ebx
f01015c2:	eb 16                	jmp    f01015da <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01015c4:	84 c0                	test   %al,%al
f01015c6:	74 12                	je     f01015da <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01015c8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01015cd:	80 39 30             	cmpb   $0x30,(%ecx)
f01015d0:	75 08                	jne    f01015da <strtol+0x76>
		s++, base = 8;
f01015d2:	83 c1 01             	add    $0x1,%ecx
f01015d5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01015da:	b8 00 00 00 00       	mov    $0x0,%eax
f01015df:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01015e2:	0f b6 11             	movzbl (%ecx),%edx
f01015e5:	8d 72 d0             	lea    -0x30(%edx),%esi
f01015e8:	89 f3                	mov    %esi,%ebx
f01015ea:	80 fb 09             	cmp    $0x9,%bl
f01015ed:	77 08                	ja     f01015f7 <strtol+0x93>
			dig = *s - '0';
f01015ef:	0f be d2             	movsbl %dl,%edx
f01015f2:	83 ea 30             	sub    $0x30,%edx
f01015f5:	eb 22                	jmp    f0101619 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
f01015f7:	8d 72 9f             	lea    -0x61(%edx),%esi
f01015fa:	89 f3                	mov    %esi,%ebx
f01015fc:	80 fb 19             	cmp    $0x19,%bl
f01015ff:	77 08                	ja     f0101609 <strtol+0xa5>
			dig = *s - 'a' + 10;
f0101601:	0f be d2             	movsbl %dl,%edx
f0101604:	83 ea 57             	sub    $0x57,%edx
f0101607:	eb 10                	jmp    f0101619 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
f0101609:	8d 72 bf             	lea    -0x41(%edx),%esi
f010160c:	89 f3                	mov    %esi,%ebx
f010160e:	80 fb 19             	cmp    $0x19,%bl
f0101611:	77 16                	ja     f0101629 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0101613:	0f be d2             	movsbl %dl,%edx
f0101616:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0101619:	3b 55 10             	cmp    0x10(%ebp),%edx
f010161c:	7d 0f                	jge    f010162d <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
f010161e:	83 c1 01             	add    $0x1,%ecx
f0101621:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101625:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0101627:	eb b9                	jmp    f01015e2 <strtol+0x7e>
f0101629:	89 c2                	mov    %eax,%edx
f010162b:	eb 02                	jmp    f010162f <strtol+0xcb>
f010162d:	89 c2                	mov    %eax,%edx

	if (endptr)
f010162f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101633:	74 0d                	je     f0101642 <strtol+0xde>
		*endptr = (char *) s;
f0101635:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101638:	89 0e                	mov    %ecx,(%esi)
f010163a:	eb 06                	jmp    f0101642 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010163c:	84 c0                	test   %al,%al
f010163e:	75 92                	jne    f01015d2 <strtol+0x6e>
f0101640:	eb 98                	jmp    f01015da <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0101642:	f7 da                	neg    %edx
f0101644:	85 ff                	test   %edi,%edi
f0101646:	0f 45 c2             	cmovne %edx,%eax
}
f0101649:	5b                   	pop    %ebx
f010164a:	5e                   	pop    %esi
f010164b:	5f                   	pop    %edi
f010164c:	5d                   	pop    %ebp
f010164d:	c3                   	ret    
f010164e:	66 90                	xchg   %ax,%ax

f0101650 <__udivdi3>:
f0101650:	55                   	push   %ebp
f0101651:	57                   	push   %edi
f0101652:	56                   	push   %esi
f0101653:	83 ec 10             	sub    $0x10,%esp
f0101656:	8b 54 24 2c          	mov    0x2c(%esp),%edx
f010165a:	8b 7c 24 20          	mov    0x20(%esp),%edi
f010165e:	8b 74 24 24          	mov    0x24(%esp),%esi
f0101662:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0101666:	85 d2                	test   %edx,%edx
f0101668:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010166c:	89 34 24             	mov    %esi,(%esp)
f010166f:	89 c8                	mov    %ecx,%eax
f0101671:	75 35                	jne    f01016a8 <__udivdi3+0x58>
f0101673:	39 f1                	cmp    %esi,%ecx
f0101675:	0f 87 bd 00 00 00    	ja     f0101738 <__udivdi3+0xe8>
f010167b:	85 c9                	test   %ecx,%ecx
f010167d:	89 cd                	mov    %ecx,%ebp
f010167f:	75 0b                	jne    f010168c <__udivdi3+0x3c>
f0101681:	b8 01 00 00 00       	mov    $0x1,%eax
f0101686:	31 d2                	xor    %edx,%edx
f0101688:	f7 f1                	div    %ecx
f010168a:	89 c5                	mov    %eax,%ebp
f010168c:	89 f0                	mov    %esi,%eax
f010168e:	31 d2                	xor    %edx,%edx
f0101690:	f7 f5                	div    %ebp
f0101692:	89 c6                	mov    %eax,%esi
f0101694:	89 f8                	mov    %edi,%eax
f0101696:	f7 f5                	div    %ebp
f0101698:	89 f2                	mov    %esi,%edx
f010169a:	83 c4 10             	add    $0x10,%esp
f010169d:	5e                   	pop    %esi
f010169e:	5f                   	pop    %edi
f010169f:	5d                   	pop    %ebp
f01016a0:	c3                   	ret    
f01016a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01016a8:	3b 14 24             	cmp    (%esp),%edx
f01016ab:	77 7b                	ja     f0101728 <__udivdi3+0xd8>
f01016ad:	0f bd f2             	bsr    %edx,%esi
f01016b0:	83 f6 1f             	xor    $0x1f,%esi
f01016b3:	0f 84 97 00 00 00    	je     f0101750 <__udivdi3+0x100>
f01016b9:	bd 20 00 00 00       	mov    $0x20,%ebp
f01016be:	89 d7                	mov    %edx,%edi
f01016c0:	89 f1                	mov    %esi,%ecx
f01016c2:	29 f5                	sub    %esi,%ebp
f01016c4:	d3 e7                	shl    %cl,%edi
f01016c6:	89 c2                	mov    %eax,%edx
f01016c8:	89 e9                	mov    %ebp,%ecx
f01016ca:	d3 ea                	shr    %cl,%edx
f01016cc:	89 f1                	mov    %esi,%ecx
f01016ce:	09 fa                	or     %edi,%edx
f01016d0:	8b 3c 24             	mov    (%esp),%edi
f01016d3:	d3 e0                	shl    %cl,%eax
f01016d5:	89 54 24 08          	mov    %edx,0x8(%esp)
f01016d9:	89 e9                	mov    %ebp,%ecx
f01016db:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016df:	8b 44 24 04          	mov    0x4(%esp),%eax
f01016e3:	89 fa                	mov    %edi,%edx
f01016e5:	d3 ea                	shr    %cl,%edx
f01016e7:	89 f1                	mov    %esi,%ecx
f01016e9:	d3 e7                	shl    %cl,%edi
f01016eb:	89 e9                	mov    %ebp,%ecx
f01016ed:	d3 e8                	shr    %cl,%eax
f01016ef:	09 c7                	or     %eax,%edi
f01016f1:	89 f8                	mov    %edi,%eax
f01016f3:	f7 74 24 08          	divl   0x8(%esp)
f01016f7:	89 d5                	mov    %edx,%ebp
f01016f9:	89 c7                	mov    %eax,%edi
f01016fb:	f7 64 24 0c          	mull   0xc(%esp)
f01016ff:	39 d5                	cmp    %edx,%ebp
f0101701:	89 14 24             	mov    %edx,(%esp)
f0101704:	72 11                	jb     f0101717 <__udivdi3+0xc7>
f0101706:	8b 54 24 04          	mov    0x4(%esp),%edx
f010170a:	89 f1                	mov    %esi,%ecx
f010170c:	d3 e2                	shl    %cl,%edx
f010170e:	39 c2                	cmp    %eax,%edx
f0101710:	73 5e                	jae    f0101770 <__udivdi3+0x120>
f0101712:	3b 2c 24             	cmp    (%esp),%ebp
f0101715:	75 59                	jne    f0101770 <__udivdi3+0x120>
f0101717:	8d 47 ff             	lea    -0x1(%edi),%eax
f010171a:	31 f6                	xor    %esi,%esi
f010171c:	89 f2                	mov    %esi,%edx
f010171e:	83 c4 10             	add    $0x10,%esp
f0101721:	5e                   	pop    %esi
f0101722:	5f                   	pop    %edi
f0101723:	5d                   	pop    %ebp
f0101724:	c3                   	ret    
f0101725:	8d 76 00             	lea    0x0(%esi),%esi
f0101728:	31 f6                	xor    %esi,%esi
f010172a:	31 c0                	xor    %eax,%eax
f010172c:	89 f2                	mov    %esi,%edx
f010172e:	83 c4 10             	add    $0x10,%esp
f0101731:	5e                   	pop    %esi
f0101732:	5f                   	pop    %edi
f0101733:	5d                   	pop    %ebp
f0101734:	c3                   	ret    
f0101735:	8d 76 00             	lea    0x0(%esi),%esi
f0101738:	89 f2                	mov    %esi,%edx
f010173a:	31 f6                	xor    %esi,%esi
f010173c:	89 f8                	mov    %edi,%eax
f010173e:	f7 f1                	div    %ecx
f0101740:	89 f2                	mov    %esi,%edx
f0101742:	83 c4 10             	add    $0x10,%esp
f0101745:	5e                   	pop    %esi
f0101746:	5f                   	pop    %edi
f0101747:	5d                   	pop    %ebp
f0101748:	c3                   	ret    
f0101749:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101750:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0101754:	76 0b                	jbe    f0101761 <__udivdi3+0x111>
f0101756:	31 c0                	xor    %eax,%eax
f0101758:	3b 14 24             	cmp    (%esp),%edx
f010175b:	0f 83 37 ff ff ff    	jae    f0101698 <__udivdi3+0x48>
f0101761:	b8 01 00 00 00       	mov    $0x1,%eax
f0101766:	e9 2d ff ff ff       	jmp    f0101698 <__udivdi3+0x48>
f010176b:	90                   	nop
f010176c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101770:	89 f8                	mov    %edi,%eax
f0101772:	31 f6                	xor    %esi,%esi
f0101774:	e9 1f ff ff ff       	jmp    f0101698 <__udivdi3+0x48>
f0101779:	66 90                	xchg   %ax,%ax
f010177b:	66 90                	xchg   %ax,%ax
f010177d:	66 90                	xchg   %ax,%ax
f010177f:	90                   	nop

f0101780 <__umoddi3>:
f0101780:	55                   	push   %ebp
f0101781:	57                   	push   %edi
f0101782:	56                   	push   %esi
f0101783:	83 ec 20             	sub    $0x20,%esp
f0101786:	8b 44 24 34          	mov    0x34(%esp),%eax
f010178a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010178e:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101792:	89 c6                	mov    %eax,%esi
f0101794:	89 44 24 10          	mov    %eax,0x10(%esp)
f0101798:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010179c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
f01017a0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01017a4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f01017a8:	89 74 24 18          	mov    %esi,0x18(%esp)
f01017ac:	85 c0                	test   %eax,%eax
f01017ae:	89 c2                	mov    %eax,%edx
f01017b0:	75 1e                	jne    f01017d0 <__umoddi3+0x50>
f01017b2:	39 f7                	cmp    %esi,%edi
f01017b4:	76 52                	jbe    f0101808 <__umoddi3+0x88>
f01017b6:	89 c8                	mov    %ecx,%eax
f01017b8:	89 f2                	mov    %esi,%edx
f01017ba:	f7 f7                	div    %edi
f01017bc:	89 d0                	mov    %edx,%eax
f01017be:	31 d2                	xor    %edx,%edx
f01017c0:	83 c4 20             	add    $0x20,%esp
f01017c3:	5e                   	pop    %esi
f01017c4:	5f                   	pop    %edi
f01017c5:	5d                   	pop    %ebp
f01017c6:	c3                   	ret    
f01017c7:	89 f6                	mov    %esi,%esi
f01017c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01017d0:	39 f0                	cmp    %esi,%eax
f01017d2:	77 5c                	ja     f0101830 <__umoddi3+0xb0>
f01017d4:	0f bd e8             	bsr    %eax,%ebp
f01017d7:	83 f5 1f             	xor    $0x1f,%ebp
f01017da:	75 64                	jne    f0101840 <__umoddi3+0xc0>
f01017dc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
f01017e0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
f01017e4:	0f 86 f6 00 00 00    	jbe    f01018e0 <__umoddi3+0x160>
f01017ea:	3b 44 24 18          	cmp    0x18(%esp),%eax
f01017ee:	0f 82 ec 00 00 00    	jb     f01018e0 <__umoddi3+0x160>
f01017f4:	8b 44 24 14          	mov    0x14(%esp),%eax
f01017f8:	8b 54 24 18          	mov    0x18(%esp),%edx
f01017fc:	83 c4 20             	add    $0x20,%esp
f01017ff:	5e                   	pop    %esi
f0101800:	5f                   	pop    %edi
f0101801:	5d                   	pop    %ebp
f0101802:	c3                   	ret    
f0101803:	90                   	nop
f0101804:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101808:	85 ff                	test   %edi,%edi
f010180a:	89 fd                	mov    %edi,%ebp
f010180c:	75 0b                	jne    f0101819 <__umoddi3+0x99>
f010180e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101813:	31 d2                	xor    %edx,%edx
f0101815:	f7 f7                	div    %edi
f0101817:	89 c5                	mov    %eax,%ebp
f0101819:	8b 44 24 10          	mov    0x10(%esp),%eax
f010181d:	31 d2                	xor    %edx,%edx
f010181f:	f7 f5                	div    %ebp
f0101821:	89 c8                	mov    %ecx,%eax
f0101823:	f7 f5                	div    %ebp
f0101825:	eb 95                	jmp    f01017bc <__umoddi3+0x3c>
f0101827:	89 f6                	mov    %esi,%esi
f0101829:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0101830:	89 c8                	mov    %ecx,%eax
f0101832:	89 f2                	mov    %esi,%edx
f0101834:	83 c4 20             	add    $0x20,%esp
f0101837:	5e                   	pop    %esi
f0101838:	5f                   	pop    %edi
f0101839:	5d                   	pop    %ebp
f010183a:	c3                   	ret    
f010183b:	90                   	nop
f010183c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101840:	b8 20 00 00 00       	mov    $0x20,%eax
f0101845:	89 e9                	mov    %ebp,%ecx
f0101847:	29 e8                	sub    %ebp,%eax
f0101849:	d3 e2                	shl    %cl,%edx
f010184b:	89 c7                	mov    %eax,%edi
f010184d:	89 44 24 18          	mov    %eax,0x18(%esp)
f0101851:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0101855:	89 f9                	mov    %edi,%ecx
f0101857:	d3 e8                	shr    %cl,%eax
f0101859:	89 c1                	mov    %eax,%ecx
f010185b:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010185f:	09 d1                	or     %edx,%ecx
f0101861:	89 fa                	mov    %edi,%edx
f0101863:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0101867:	89 e9                	mov    %ebp,%ecx
f0101869:	d3 e0                	shl    %cl,%eax
f010186b:	89 f9                	mov    %edi,%ecx
f010186d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101871:	89 f0                	mov    %esi,%eax
f0101873:	d3 e8                	shr    %cl,%eax
f0101875:	89 e9                	mov    %ebp,%ecx
f0101877:	89 c7                	mov    %eax,%edi
f0101879:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f010187d:	d3 e6                	shl    %cl,%esi
f010187f:	89 d1                	mov    %edx,%ecx
f0101881:	89 fa                	mov    %edi,%edx
f0101883:	d3 e8                	shr    %cl,%eax
f0101885:	89 e9                	mov    %ebp,%ecx
f0101887:	09 f0                	or     %esi,%eax
f0101889:	8b 74 24 1c          	mov    0x1c(%esp),%esi
f010188d:	f7 74 24 10          	divl   0x10(%esp)
f0101891:	d3 e6                	shl    %cl,%esi
f0101893:	89 d1                	mov    %edx,%ecx
f0101895:	f7 64 24 0c          	mull   0xc(%esp)
f0101899:	39 d1                	cmp    %edx,%ecx
f010189b:	89 74 24 14          	mov    %esi,0x14(%esp)
f010189f:	89 d7                	mov    %edx,%edi
f01018a1:	89 c6                	mov    %eax,%esi
f01018a3:	72 0a                	jb     f01018af <__umoddi3+0x12f>
f01018a5:	39 44 24 14          	cmp    %eax,0x14(%esp)
f01018a9:	73 10                	jae    f01018bb <__umoddi3+0x13b>
f01018ab:	39 d1                	cmp    %edx,%ecx
f01018ad:	75 0c                	jne    f01018bb <__umoddi3+0x13b>
f01018af:	89 d7                	mov    %edx,%edi
f01018b1:	89 c6                	mov    %eax,%esi
f01018b3:	2b 74 24 0c          	sub    0xc(%esp),%esi
f01018b7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
f01018bb:	89 ca                	mov    %ecx,%edx
f01018bd:	89 e9                	mov    %ebp,%ecx
f01018bf:	8b 44 24 14          	mov    0x14(%esp),%eax
f01018c3:	29 f0                	sub    %esi,%eax
f01018c5:	19 fa                	sbb    %edi,%edx
f01018c7:	d3 e8                	shr    %cl,%eax
f01018c9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
f01018ce:	89 d7                	mov    %edx,%edi
f01018d0:	d3 e7                	shl    %cl,%edi
f01018d2:	89 e9                	mov    %ebp,%ecx
f01018d4:	09 f8                	or     %edi,%eax
f01018d6:	d3 ea                	shr    %cl,%edx
f01018d8:	83 c4 20             	add    $0x20,%esp
f01018db:	5e                   	pop    %esi
f01018dc:	5f                   	pop    %edi
f01018dd:	5d                   	pop    %ebp
f01018de:	c3                   	ret    
f01018df:	90                   	nop
f01018e0:	8b 74 24 10          	mov    0x10(%esp),%esi
f01018e4:	29 f9                	sub    %edi,%ecx
f01018e6:	19 c6                	sbb    %eax,%esi
f01018e8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f01018ec:	89 74 24 18          	mov    %esi,0x18(%esp)
f01018f0:	e9 ff fe ff ff       	jmp    f01017f4 <__umoddi3+0x74>
