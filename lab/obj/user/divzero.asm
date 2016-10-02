
obj/user/divzero:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 c0 0d 80 00       	push   $0x800dc0
  800056:	e8 e0 00 00 00       	call   80013b <cprintf>
  80005b:	83 c4 10             	add    $0x10,%esp
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	8b 45 08             	mov    0x8(%ebp),%eax
  800069:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006c:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800073:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 c0                	test   %eax,%eax
  800078:	7e 08                	jle    800082 <libmain+0x22>
		binaryname = argv[0];
  80007a:	8b 0a                	mov    (%edx),%ecx
  80007c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800082:	83 ec 08             	sub    $0x8,%esp
  800085:	52                   	push   %edx
  800086:	50                   	push   %eax
  800087:	e8 a7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008c:	e8 05 00 00 00       	call   800096 <exit>
  800091:	83 c4 10             	add    $0x10,%esp
}
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009c:	6a 00                	push   $0x0
  80009e:	e8 a9 09 00 00       	call   800a4c <sys_env_destroy>
  8000a3:	83 c4 10             	add    $0x10,%esp
}
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	53                   	push   %ebx
  8000ac:	83 ec 04             	sub    $0x4,%esp
  8000af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b2:	8b 13                	mov    (%ebx),%edx
  8000b4:	8d 42 01             	lea    0x1(%edx),%eax
  8000b7:	89 03                	mov    %eax,(%ebx)
  8000b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c5:	75 1a                	jne    8000e1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	68 ff 00 00 00       	push   $0xff
  8000cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d2:	50                   	push   %eax
  8000d3:	e8 37 09 00 00       	call   800a0f <sys_cputs>
		b->idx = 0;
  8000d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000de:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e8:	c9                   	leave  
  8000e9:	c3                   	ret    

008000ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fa:	00 00 00 
	b.cnt = 0;
  8000fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800104:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800107:	ff 75 0c             	pushl  0xc(%ebp)
  80010a:	ff 75 08             	pushl  0x8(%ebp)
  80010d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800113:	50                   	push   %eax
  800114:	68 a8 00 80 00       	push   $0x8000a8
  800119:	e8 4f 01 00 00       	call   80026d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011e:	83 c4 08             	add    $0x8,%esp
  800121:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800127:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	e8 dc 08 00 00       	call   800a0f <sys_cputs>

	return b.cnt;
}
  800133:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800141:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800144:	50                   	push   %eax
  800145:	ff 75 08             	pushl  0x8(%ebp)
  800148:	e8 9d ff ff ff       	call   8000ea <vcprintf>
	va_end(ap);

	return cnt;
}
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	57                   	push   %edi
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
  800155:	83 ec 1c             	sub    $0x1c,%esp
  800158:	89 c7                	mov    %eax,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	8b 45 08             	mov    0x8(%ebp),%eax
  80015f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800162:	89 d1                	mov    %edx,%ecx
  800164:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800167:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80016a:	8b 45 10             	mov    0x10(%ebp),%eax
  80016d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800170:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800173:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80017a:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80017d:	72 05                	jb     800184 <printnum+0x35>
  80017f:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800182:	77 3e                	ja     8001c2 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	ff 75 18             	pushl  0x18(%ebp)
  80018a:	83 eb 01             	sub    $0x1,%ebx
  80018d:	53                   	push   %ebx
  80018e:	50                   	push   %eax
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	ff 75 e4             	pushl  -0x1c(%ebp)
  800195:	ff 75 e0             	pushl  -0x20(%ebp)
  800198:	ff 75 dc             	pushl  -0x24(%ebp)
  80019b:	ff 75 d8             	pushl  -0x28(%ebp)
  80019e:	e8 5d 09 00 00       	call   800b00 <__udivdi3>
  8001a3:	83 c4 18             	add    $0x18,%esp
  8001a6:	52                   	push   %edx
  8001a7:	50                   	push   %eax
  8001a8:	89 f2                	mov    %esi,%edx
  8001aa:	89 f8                	mov    %edi,%eax
  8001ac:	e8 9e ff ff ff       	call   80014f <printnum>
  8001b1:	83 c4 20             	add    $0x20,%esp
  8001b4:	eb 13                	jmp    8001c9 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b6:	83 ec 08             	sub    $0x8,%esp
  8001b9:	56                   	push   %esi
  8001ba:	ff 75 18             	pushl  0x18(%ebp)
  8001bd:	ff d7                	call   *%edi
  8001bf:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c2:	83 eb 01             	sub    $0x1,%ebx
  8001c5:	85 db                	test   %ebx,%ebx
  8001c7:	7f ed                	jg     8001b6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	56                   	push   %esi
  8001cd:	83 ec 04             	sub    $0x4,%esp
  8001d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001dc:	e8 4f 0a 00 00       	call   800c30 <__umoddi3>
  8001e1:	83 c4 14             	add    $0x14,%esp
  8001e4:	0f be 80 d8 0d 80 00 	movsbl 0x800dd8(%eax),%eax
  8001eb:	50                   	push   %eax
  8001ec:	ff d7                	call   *%edi
  8001ee:	83 c4 10             	add    $0x10,%esp
}
  8001f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f4:	5b                   	pop    %ebx
  8001f5:	5e                   	pop    %esi
  8001f6:	5f                   	pop    %edi
  8001f7:	5d                   	pop    %ebp
  8001f8:	c3                   	ret    

008001f9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8001fc:	83 fa 01             	cmp    $0x1,%edx
  8001ff:	7e 0e                	jle    80020f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800201:	8b 10                	mov    (%eax),%edx
  800203:	8d 4a 08             	lea    0x8(%edx),%ecx
  800206:	89 08                	mov    %ecx,(%eax)
  800208:	8b 02                	mov    (%edx),%eax
  80020a:	8b 52 04             	mov    0x4(%edx),%edx
  80020d:	eb 22                	jmp    800231 <getuint+0x38>
	else if (lflag)
  80020f:	85 d2                	test   %edx,%edx
  800211:	74 10                	je     800223 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800213:	8b 10                	mov    (%eax),%edx
  800215:	8d 4a 04             	lea    0x4(%edx),%ecx
  800218:	89 08                	mov    %ecx,(%eax)
  80021a:	8b 02                	mov    (%edx),%eax
  80021c:	ba 00 00 00 00       	mov    $0x0,%edx
  800221:	eb 0e                	jmp    800231 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800223:	8b 10                	mov    (%eax),%edx
  800225:	8d 4a 04             	lea    0x4(%edx),%ecx
  800228:	89 08                	mov    %ecx,(%eax)
  80022a:	8b 02                	mov    (%edx),%eax
  80022c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    

00800233 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800239:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80023d:	8b 10                	mov    (%eax),%edx
  80023f:	3b 50 04             	cmp    0x4(%eax),%edx
  800242:	73 0a                	jae    80024e <sprintputch+0x1b>
		*b->buf++ = ch;
  800244:	8d 4a 01             	lea    0x1(%edx),%ecx
  800247:	89 08                	mov    %ecx,(%eax)
  800249:	8b 45 08             	mov    0x8(%ebp),%eax
  80024c:	88 02                	mov    %al,(%edx)
}
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    

00800250 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800256:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800259:	50                   	push   %eax
  80025a:	ff 75 10             	pushl  0x10(%ebp)
  80025d:	ff 75 0c             	pushl  0xc(%ebp)
  800260:	ff 75 08             	pushl  0x8(%ebp)
  800263:	e8 05 00 00 00       	call   80026d <vprintfmt>
	va_end(ap);
  800268:	83 c4 10             	add    $0x10,%esp
}
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	57                   	push   %edi
  800271:	56                   	push   %esi
  800272:	53                   	push   %ebx
  800273:	83 ec 2c             	sub    $0x2c,%esp
  800276:	8b 75 08             	mov    0x8(%ebp),%esi
  800279:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80027c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80027f:	eb 12                	jmp    800293 <vprintfmt+0x26>

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
		{
			if (ch == '\0')
  800281:	85 c0                	test   %eax,%eax
  800283:	0f 84 90 03 00 00    	je     800619 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800289:	83 ec 08             	sub    $0x8,%esp
  80028c:	53                   	push   %ebx
  80028d:	50                   	push   %eax
  80028e:	ff d6                	call   *%esi
  800290:	83 c4 10             	add    $0x10,%esp
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
  800293:	83 c7 01             	add    $0x1,%edi
  800296:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80029a:	83 f8 25             	cmp    $0x25,%eax
  80029d:	75 e2                	jne    800281 <vprintfmt+0x14>
  80029f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002a3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002aa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002b1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bd:	eb 07                	jmp    8002c6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8002bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		{

			// flag to pad on the right
			case '-':
				padc = '-';
  8002c2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8002c6:	8d 47 01             	lea    0x1(%edi),%eax
  8002c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cc:	0f b6 07             	movzbl (%edi),%eax
  8002cf:	0f b6 c8             	movzbl %al,%ecx
  8002d2:	83 e8 23             	sub    $0x23,%eax
  8002d5:	3c 55                	cmp    $0x55,%al
  8002d7:	0f 87 21 03 00 00    	ja     8005fe <vprintfmt+0x391>
  8002dd:	0f b6 c0             	movzbl %al,%eax
  8002e0:	ff 24 85 80 0e 80 00 	jmp    *0x800e80(,%eax,4)
  8002e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				padc = '-';
				goto reswitch;

			// flag to pad with 0's instead of spaces
			case '0':
				padc = '0';
  8002ea:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002ee:	eb d6                	jmp    8002c6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8002f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8002f8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
					precision = precision * 10 + ch - '0';
  8002fb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002fe:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
					ch = *fmt;
  800302:	0f be 0f             	movsbl (%edi),%ecx
					if (ch < '0' || ch > '9')
  800305:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800308:	83 fa 09             	cmp    $0x9,%edx
  80030b:	77 39                	ja     800346 <vprintfmt+0xd9>
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
  80030d:	83 c7 01             	add    $0x1,%edi
					precision = precision * 10 + ch - '0';
					ch = *fmt;
					if (ch < '0' || ch > '9')
						break;
				}
  800310:	eb e9                	jmp    8002fb <vprintfmt+0x8e>
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
  800312:	8b 45 14             	mov    0x14(%ebp),%eax
  800315:	8d 48 04             	lea    0x4(%eax),%ecx
  800318:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80031b:	8b 00                	mov    (%eax),%eax
  80031d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800320:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				}
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
				goto process_precision;
  800323:	eb 27                	jmp    80034c <vprintfmt+0xdf>
  800325:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800328:	85 c0                	test   %eax,%eax
  80032a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032f:	0f 49 c8             	cmovns %eax,%ecx
  800332:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800335:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800338:	eb 8c                	jmp    8002c6 <vprintfmt+0x59>
  80033a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				if (width < 0)
					width = 0;
				goto reswitch;

			case '#':
				altflag = 1;
  80033d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				goto reswitch;
  800344:	eb 80                	jmp    8002c6 <vprintfmt+0x59>
  800346:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800349:	89 45 d0             	mov    %eax,-0x30(%ebp)

			process_precision:
				if (width < 0)
  80034c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800350:	0f 89 70 ff ff ff    	jns    8002c6 <vprintfmt+0x59>
					width = precision, precision = -1;
  800356:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800359:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800363:	e9 5e ff ff ff       	jmp    8002c6 <vprintfmt+0x59>
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
  800368:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
				goto reswitch;
  80036e:	e9 53 ff ff ff       	jmp    8002c6 <vprintfmt+0x59>

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
  800373:	8b 45 14             	mov    0x14(%ebp),%eax
  800376:	8d 50 04             	lea    0x4(%eax),%edx
  800379:	89 55 14             	mov    %edx,0x14(%ebp)
  80037c:	83 ec 08             	sub    $0x8,%esp
  80037f:	53                   	push   %ebx
  800380:	ff 30                	pushl  (%eax)
  800382:	ff d6                	call   *%esi
				break;
  800384:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
				break;
  80038a:	e9 04 ff ff ff       	jmp    800293 <vprintfmt+0x26>

			// error message
			case 'e':
				err = va_arg(ap, int);
  80038f:	8b 45 14             	mov    0x14(%ebp),%eax
  800392:	8d 50 04             	lea    0x4(%eax),%edx
  800395:	89 55 14             	mov    %edx,0x14(%ebp)
  800398:	8b 00                	mov    (%eax),%eax
  80039a:	99                   	cltd   
  80039b:	31 d0                	xor    %edx,%eax
  80039d:	29 d0                	sub    %edx,%eax
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80039f:	83 f8 07             	cmp    $0x7,%eax
  8003a2:	7f 0b                	jg     8003af <vprintfmt+0x142>
  8003a4:	8b 14 85 e0 0f 80 00 	mov    0x800fe0(,%eax,4),%edx
  8003ab:	85 d2                	test   %edx,%edx
  8003ad:	75 18                	jne    8003c7 <vprintfmt+0x15a>
					printfmt(putch, putdat, "error %d", err);
  8003af:	50                   	push   %eax
  8003b0:	68 f0 0d 80 00       	push   $0x800df0
  8003b5:	53                   	push   %ebx
  8003b6:	56                   	push   %esi
  8003b7:	e8 94 fe ff ff       	call   800250 <printfmt>
  8003bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			case 'e':
				err = va_arg(ap, int);
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
					printfmt(putch, putdat, "error %d", err);
  8003c2:	e9 cc fe ff ff       	jmp    800293 <vprintfmt+0x26>
				else
					printfmt(putch, putdat, "%s", p);
  8003c7:	52                   	push   %edx
  8003c8:	68 f9 0d 80 00       	push   $0x800df9
  8003cd:	53                   	push   %ebx
  8003ce:	56                   	push   %esi
  8003cf:	e8 7c fe ff ff       	call   800250 <printfmt>
  8003d4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003da:	e9 b4 fe ff ff       	jmp    800293 <vprintfmt+0x26>
  8003df:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e5:	89 45 cc             	mov    %eax,-0x34(%ebp)
					printfmt(putch, putdat, "%s", p);
				break;

			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
  8003e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003eb:	8d 50 04             	lea    0x4(%eax),%edx
  8003ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f1:	8b 38                	mov    (%eax),%edi
					p = "(null)";
  8003f3:	85 ff                	test   %edi,%edi
  8003f5:	ba e9 0d 80 00       	mov    $0x800de9,%edx
  8003fa:	0f 44 fa             	cmove  %edx,%edi
				if (width > 0 && padc != '-')
  8003fd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800401:	0f 84 92 00 00 00    	je     800499 <vprintfmt+0x22c>
  800407:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80040b:	0f 8e 96 00 00 00    	jle    8004a7 <vprintfmt+0x23a>
					for (width -= strnlen(p, precision); width > 0; width--)
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	51                   	push   %ecx
  800415:	57                   	push   %edi
  800416:	e8 86 02 00 00       	call   8006a1 <strnlen>
  80041b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80041e:	29 c1                	sub    %eax,%ecx
  800420:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800423:	83 c4 10             	add    $0x10,%esp
						putch(padc, putdat);
  800426:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80042a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800430:	89 cf                	mov    %ecx,%edi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  800432:	eb 0f                	jmp    800443 <vprintfmt+0x1d6>
						putch(padc, putdat);
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	53                   	push   %ebx
  800438:	ff 75 e0             	pushl  -0x20(%ebp)
  80043b:	ff d6                	call   *%esi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  80043d:	83 ef 01             	sub    $0x1,%edi
  800440:	83 c4 10             	add    $0x10,%esp
  800443:	85 ff                	test   %edi,%edi
  800445:	7f ed                	jg     800434 <vprintfmt+0x1c7>
  800447:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80044a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80044d:	85 c9                	test   %ecx,%ecx
  80044f:	b8 00 00 00 00       	mov    $0x0,%eax
  800454:	0f 49 c1             	cmovns %ecx,%eax
  800457:	29 c1                	sub    %eax,%ecx
  800459:	89 75 08             	mov    %esi,0x8(%ebp)
  80045c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80045f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800462:	89 cb                	mov    %ecx,%ebx
  800464:	eb 4d                	jmp    8004b3 <vprintfmt+0x246>
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
  800466:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80046a:	74 1b                	je     800487 <vprintfmt+0x21a>
  80046c:	0f be c0             	movsbl %al,%eax
  80046f:	83 e8 20             	sub    $0x20,%eax
  800472:	83 f8 5e             	cmp    $0x5e,%eax
  800475:	76 10                	jbe    800487 <vprintfmt+0x21a>
						putch('?', putdat);
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	ff 75 0c             	pushl  0xc(%ebp)
  80047d:	6a 3f                	push   $0x3f
  80047f:	ff 55 08             	call   *0x8(%ebp)
  800482:	83 c4 10             	add    $0x10,%esp
  800485:	eb 0d                	jmp    800494 <vprintfmt+0x227>
					else
						putch(ch, putdat);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	ff 75 0c             	pushl  0xc(%ebp)
  80048d:	52                   	push   %edx
  80048e:	ff 55 08             	call   *0x8(%ebp)
  800491:	83 c4 10             	add    $0x10,%esp
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800494:	83 eb 01             	sub    $0x1,%ebx
  800497:	eb 1a                	jmp    8004b3 <vprintfmt+0x246>
  800499:	89 75 08             	mov    %esi,0x8(%ebp)
  80049c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80049f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a5:	eb 0c                	jmp    8004b3 <vprintfmt+0x246>
  8004a7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004aa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ad:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b3:	83 c7 01             	add    $0x1,%edi
  8004b6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ba:	0f be d0             	movsbl %al,%edx
  8004bd:	85 d2                	test   %edx,%edx
  8004bf:	74 23                	je     8004e4 <vprintfmt+0x277>
  8004c1:	85 f6                	test   %esi,%esi
  8004c3:	78 a1                	js     800466 <vprintfmt+0x1f9>
  8004c5:	83 ee 01             	sub    $0x1,%esi
  8004c8:	79 9c                	jns    800466 <vprintfmt+0x1f9>
  8004ca:	89 df                	mov    %ebx,%edi
  8004cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d2:	eb 18                	jmp    8004ec <vprintfmt+0x27f>
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
					putch(' ', putdat);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	53                   	push   %ebx
  8004d8:	6a 20                	push   $0x20
  8004da:	ff d6                	call   *%esi
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
  8004dc:	83 ef 01             	sub    $0x1,%edi
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	eb 08                	jmp    8004ec <vprintfmt+0x27f>
  8004e4:	89 df                	mov    %ebx,%edi
  8004e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ec:	85 ff                	test   %edi,%edi
  8004ee:	7f e4                	jg     8004d4 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f3:	e9 9b fd ff ff       	jmp    800293 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004f8:	83 fa 01             	cmp    $0x1,%edx
  8004fb:	7e 16                	jle    800513 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8004fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800500:	8d 50 08             	lea    0x8(%eax),%edx
  800503:	89 55 14             	mov    %edx,0x14(%ebp)
  800506:	8b 50 04             	mov    0x4(%eax),%edx
  800509:	8b 00                	mov    (%eax),%eax
  80050b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800511:	eb 32                	jmp    800545 <vprintfmt+0x2d8>
	else if (lflag)
  800513:	85 d2                	test   %edx,%edx
  800515:	74 18                	je     80052f <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 50 04             	lea    0x4(%eax),%edx
  80051d:	89 55 14             	mov    %edx,0x14(%ebp)
  800520:	8b 00                	mov    (%eax),%eax
  800522:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800525:	89 c1                	mov    %eax,%ecx
  800527:	c1 f9 1f             	sar    $0x1f,%ecx
  80052a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80052d:	eb 16                	jmp    800545 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8d 50 04             	lea    0x4(%eax),%edx
  800535:	89 55 14             	mov    %edx,0x14(%ebp)
  800538:	8b 00                	mov    (%eax),%eax
  80053a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053d:	89 c1                	mov    %eax,%ecx
  80053f:	c1 f9 1f             	sar    $0x1f,%ecx
  800542:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(' ', putdat);
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
  800545:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800548:	8b 55 dc             	mov    -0x24(%ebp),%edx
				if ((long long) num < 0) {
					putch('-', putdat);
					num = -(long long) num;
				}
				base = 10;
  80054b:	b9 0a 00 00 00       	mov    $0xa,%ecx
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
				if ((long long) num < 0) {
  800550:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800554:	79 74                	jns    8005ca <vprintfmt+0x35d>
					putch('-', putdat);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	53                   	push   %ebx
  80055a:	6a 2d                	push   $0x2d
  80055c:	ff d6                	call   *%esi
					num = -(long long) num;
  80055e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800561:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800564:	f7 d8                	neg    %eax
  800566:	83 d2 00             	adc    $0x0,%edx
  800569:	f7 da                	neg    %edx
  80056b:	83 c4 10             	add    $0x10,%esp
				}
				base = 10;
  80056e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800573:	eb 55                	jmp    8005ca <vprintfmt+0x35d>
				goto number;

			// unsigned decimal
			case 'u':
				num = getuint(&ap, lflag);
  800575:	8d 45 14             	lea    0x14(%ebp),%eax
  800578:	e8 7c fc ff ff       	call   8001f9 <getuint>
				base = 10;
  80057d:	b9 0a 00 00 00       	mov    $0xa,%ecx
				goto number;
  800582:	eb 46                	jmp    8005ca <vprintfmt+0x35d>
				// Replace this with your code.
				/*putch('X', putdat);
				putch('X', putdat);
				putch('X', putdat);*/
				
				num = getuint(&ap, lflag);
  800584:	8d 45 14             	lea    0x14(%ebp),%eax
  800587:	e8 6d fc ff ff       	call   8001f9 <getuint>
				base = 8;
  80058c:	b9 08 00 00 00       	mov    $0x8,%ecx
				goto number;
  800591:	eb 37                	jmp    8005ca <vprintfmt+0x35d>

			// pointer
			case 'p':
				putch('0', putdat);
  800593:	83 ec 08             	sub    $0x8,%esp
  800596:	53                   	push   %ebx
  800597:	6a 30                	push   $0x30
  800599:	ff d6                	call   *%esi
				putch('x', putdat);
  80059b:	83 c4 08             	add    $0x8,%esp
  80059e:	53                   	push   %ebx
  80059f:	6a 78                	push   $0x78
  8005a1:	ff d6                	call   *%esi
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 50 04             	lea    0x4(%eax),%edx
  8005a9:	89 55 14             	mov    %edx,0x14(%ebp)

			// pointer
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
  8005ac:	8b 00                	mov    (%eax),%eax
  8005ae:	ba 00 00 00 00       	mov    $0x0,%edx
					(uintptr_t) va_arg(ap, void *);
				base = 16;
				goto number;
  8005b3:	83 c4 10             	add    $0x10,%esp
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
				base = 16;
  8005b6:	b9 10 00 00 00       	mov    $0x10,%ecx
				goto number;
  8005bb:	eb 0d                	jmp    8005ca <vprintfmt+0x35d>

			// (unsigned) hexadecimal
			case 'x':
				num = getuint(&ap, lflag);
  8005bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c0:	e8 34 fc ff ff       	call   8001f9 <getuint>
				base = 16;
  8005c5:	b9 10 00 00 00       	mov    $0x10,%ecx
			number:
				printnum(putch, putdat, num, base, width, padc);
  8005ca:	83 ec 0c             	sub    $0xc,%esp
  8005cd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005d1:	57                   	push   %edi
  8005d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8005d5:	51                   	push   %ecx
  8005d6:	52                   	push   %edx
  8005d7:	50                   	push   %eax
  8005d8:	89 da                	mov    %ebx,%edx
  8005da:	89 f0                	mov    %esi,%eax
  8005dc:	e8 6e fb ff ff       	call   80014f <printnum>
				break;
  8005e1:	83 c4 20             	add    $0x20,%esp
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e7:	e9 a7 fc ff ff       	jmp    800293 <vprintfmt+0x26>

			// escaped '%' character
			case '%':
				putch(ch, putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	51                   	push   %ecx
  8005f1:	ff d6                	call   *%esi
				break;
  8005f3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8005f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				break;

			// escaped '%' character
			case '%':
				putch(ch, putdat);
				break;
  8005f9:	e9 95 fc ff ff       	jmp    800293 <vprintfmt+0x26>

			// unrecognized escape sequence - just print it literally
			default:
				putch('%', putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 25                	push   $0x25
  800604:	ff d6                	call   *%esi
				for (fmt--; fmt[-1] != '%'; fmt--)
  800606:	83 c4 10             	add    $0x10,%esp
  800609:	eb 03                	jmp    80060e <vprintfmt+0x3a1>
  80060b:	83 ef 01             	sub    $0x1,%edi
  80060e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800612:	75 f7                	jne    80060b <vprintfmt+0x39e>
  800614:	e9 7a fc ff ff       	jmp    800293 <vprintfmt+0x26>
					/* do nothing */;
				break;
		}
	}
}
  800619:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061c:	5b                   	pop    %ebx
  80061d:	5e                   	pop    %esi
  80061e:	5f                   	pop    %edi
  80061f:	5d                   	pop    %ebp
  800620:	c3                   	ret    

00800621 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800621:	55                   	push   %ebp
  800622:	89 e5                	mov    %esp,%ebp
  800624:	83 ec 18             	sub    $0x18,%esp
  800627:	8b 45 08             	mov    0x8(%ebp),%eax
  80062a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80062d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800630:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800634:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800637:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80063e:	85 c0                	test   %eax,%eax
  800640:	74 26                	je     800668 <vsnprintf+0x47>
  800642:	85 d2                	test   %edx,%edx
  800644:	7e 22                	jle    800668 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800646:	ff 75 14             	pushl  0x14(%ebp)
  800649:	ff 75 10             	pushl  0x10(%ebp)
  80064c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80064f:	50                   	push   %eax
  800650:	68 33 02 80 00       	push   $0x800233
  800655:	e8 13 fc ff ff       	call   80026d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80065a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80065d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800663:	83 c4 10             	add    $0x10,%esp
  800666:	eb 05                	jmp    80066d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800668:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80066d:	c9                   	leave  
  80066e:	c3                   	ret    

0080066f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80066f:	55                   	push   %ebp
  800670:	89 e5                	mov    %esp,%ebp
  800672:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800675:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800678:	50                   	push   %eax
  800679:	ff 75 10             	pushl  0x10(%ebp)
  80067c:	ff 75 0c             	pushl  0xc(%ebp)
  80067f:	ff 75 08             	pushl  0x8(%ebp)
  800682:	e8 9a ff ff ff       	call   800621 <vsnprintf>
	va_end(ap);

	return rc;
}
  800687:	c9                   	leave  
  800688:	c3                   	ret    

00800689 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800689:	55                   	push   %ebp
  80068a:	89 e5                	mov    %esp,%ebp
  80068c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80068f:	b8 00 00 00 00       	mov    $0x0,%eax
  800694:	eb 03                	jmp    800699 <strlen+0x10>
		n++;
  800696:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800699:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80069d:	75 f7                	jne    800696 <strlen+0xd>
		n++;
	return n;
}
  80069f:	5d                   	pop    %ebp
  8006a0:	c3                   	ret    

008006a1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006a1:	55                   	push   %ebp
  8006a2:	89 e5                	mov    %esp,%ebp
  8006a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006a7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8006af:	eb 03                	jmp    8006b4 <strnlen+0x13>
		n++;
  8006b1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006b4:	39 c2                	cmp    %eax,%edx
  8006b6:	74 08                	je     8006c0 <strnlen+0x1f>
  8006b8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006bc:	75 f3                	jne    8006b1 <strnlen+0x10>
  8006be:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006c0:	5d                   	pop    %ebp
  8006c1:	c3                   	ret    

008006c2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	53                   	push   %ebx
  8006c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006cc:	89 c2                	mov    %eax,%edx
  8006ce:	83 c2 01             	add    $0x1,%edx
  8006d1:	83 c1 01             	add    $0x1,%ecx
  8006d4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006d8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006db:	84 db                	test   %bl,%bl
  8006dd:	75 ef                	jne    8006ce <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006df:	5b                   	pop    %ebx
  8006e0:	5d                   	pop    %ebp
  8006e1:	c3                   	ret    

008006e2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	53                   	push   %ebx
  8006e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006e9:	53                   	push   %ebx
  8006ea:	e8 9a ff ff ff       	call   800689 <strlen>
  8006ef:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8006f2:	ff 75 0c             	pushl  0xc(%ebp)
  8006f5:	01 d8                	add    %ebx,%eax
  8006f7:	50                   	push   %eax
  8006f8:	e8 c5 ff ff ff       	call   8006c2 <strcpy>
	return dst;
}
  8006fd:	89 d8                	mov    %ebx,%eax
  8006ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800702:	c9                   	leave  
  800703:	c3                   	ret    

00800704 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	56                   	push   %esi
  800708:	53                   	push   %ebx
  800709:	8b 75 08             	mov    0x8(%ebp),%esi
  80070c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80070f:	89 f3                	mov    %esi,%ebx
  800711:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800714:	89 f2                	mov    %esi,%edx
  800716:	eb 0f                	jmp    800727 <strncpy+0x23>
		*dst++ = *src;
  800718:	83 c2 01             	add    $0x1,%edx
  80071b:	0f b6 01             	movzbl (%ecx),%eax
  80071e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800721:	80 39 01             	cmpb   $0x1,(%ecx)
  800724:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800727:	39 da                	cmp    %ebx,%edx
  800729:	75 ed                	jne    800718 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80072b:	89 f0                	mov    %esi,%eax
  80072d:	5b                   	pop    %ebx
  80072e:	5e                   	pop    %esi
  80072f:	5d                   	pop    %ebp
  800730:	c3                   	ret    

00800731 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	56                   	push   %esi
  800735:	53                   	push   %ebx
  800736:	8b 75 08             	mov    0x8(%ebp),%esi
  800739:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80073c:	8b 55 10             	mov    0x10(%ebp),%edx
  80073f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800741:	85 d2                	test   %edx,%edx
  800743:	74 21                	je     800766 <strlcpy+0x35>
  800745:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800749:	89 f2                	mov    %esi,%edx
  80074b:	eb 09                	jmp    800756 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80074d:	83 c2 01             	add    $0x1,%edx
  800750:	83 c1 01             	add    $0x1,%ecx
  800753:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800756:	39 c2                	cmp    %eax,%edx
  800758:	74 09                	je     800763 <strlcpy+0x32>
  80075a:	0f b6 19             	movzbl (%ecx),%ebx
  80075d:	84 db                	test   %bl,%bl
  80075f:	75 ec                	jne    80074d <strlcpy+0x1c>
  800761:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800763:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800766:	29 f0                	sub    %esi,%eax
}
  800768:	5b                   	pop    %ebx
  800769:	5e                   	pop    %esi
  80076a:	5d                   	pop    %ebp
  80076b:	c3                   	ret    

0080076c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800772:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800775:	eb 06                	jmp    80077d <strcmp+0x11>
		p++, q++;
  800777:	83 c1 01             	add    $0x1,%ecx
  80077a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80077d:	0f b6 01             	movzbl (%ecx),%eax
  800780:	84 c0                	test   %al,%al
  800782:	74 04                	je     800788 <strcmp+0x1c>
  800784:	3a 02                	cmp    (%edx),%al
  800786:	74 ef                	je     800777 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800788:	0f b6 c0             	movzbl %al,%eax
  80078b:	0f b6 12             	movzbl (%edx),%edx
  80078e:	29 d0                	sub    %edx,%eax
}
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	53                   	push   %ebx
  800796:	8b 45 08             	mov    0x8(%ebp),%eax
  800799:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079c:	89 c3                	mov    %eax,%ebx
  80079e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007a1:	eb 06                	jmp    8007a9 <strncmp+0x17>
		n--, p++, q++;
  8007a3:	83 c0 01             	add    $0x1,%eax
  8007a6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007a9:	39 d8                	cmp    %ebx,%eax
  8007ab:	74 15                	je     8007c2 <strncmp+0x30>
  8007ad:	0f b6 08             	movzbl (%eax),%ecx
  8007b0:	84 c9                	test   %cl,%cl
  8007b2:	74 04                	je     8007b8 <strncmp+0x26>
  8007b4:	3a 0a                	cmp    (%edx),%cl
  8007b6:	74 eb                	je     8007a3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007b8:	0f b6 00             	movzbl (%eax),%eax
  8007bb:	0f b6 12             	movzbl (%edx),%edx
  8007be:	29 d0                	sub    %edx,%eax
  8007c0:	eb 05                	jmp    8007c7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007c7:	5b                   	pop    %ebx
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007d4:	eb 07                	jmp    8007dd <strchr+0x13>
		if (*s == c)
  8007d6:	38 ca                	cmp    %cl,%dl
  8007d8:	74 0f                	je     8007e9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007da:	83 c0 01             	add    $0x1,%eax
  8007dd:	0f b6 10             	movzbl (%eax),%edx
  8007e0:	84 d2                	test   %dl,%dl
  8007e2:	75 f2                	jne    8007d6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007f5:	eb 03                	jmp    8007fa <strfind+0xf>
  8007f7:	83 c0 01             	add    $0x1,%eax
  8007fa:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8007fd:	84 d2                	test   %dl,%dl
  8007ff:	74 04                	je     800805 <strfind+0x1a>
  800801:	38 ca                	cmp    %cl,%dl
  800803:	75 f2                	jne    8007f7 <strfind+0xc>
			break;
	return (char *) s;
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	57                   	push   %edi
  80080b:	56                   	push   %esi
  80080c:	53                   	push   %ebx
  80080d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800810:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800813:	85 c9                	test   %ecx,%ecx
  800815:	74 36                	je     80084d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800817:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80081d:	75 28                	jne    800847 <memset+0x40>
  80081f:	f6 c1 03             	test   $0x3,%cl
  800822:	75 23                	jne    800847 <memset+0x40>
		c &= 0xFF;
  800824:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800828:	89 d3                	mov    %edx,%ebx
  80082a:	c1 e3 08             	shl    $0x8,%ebx
  80082d:	89 d6                	mov    %edx,%esi
  80082f:	c1 e6 18             	shl    $0x18,%esi
  800832:	89 d0                	mov    %edx,%eax
  800834:	c1 e0 10             	shl    $0x10,%eax
  800837:	09 f0                	or     %esi,%eax
  800839:	09 c2                	or     %eax,%edx
  80083b:	89 d0                	mov    %edx,%eax
  80083d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80083f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800842:	fc                   	cld    
  800843:	f3 ab                	rep stos %eax,%es:(%edi)
  800845:	eb 06                	jmp    80084d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800847:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084a:	fc                   	cld    
  80084b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80084d:	89 f8                	mov    %edi,%eax
  80084f:	5b                   	pop    %ebx
  800850:	5e                   	pop    %esi
  800851:	5f                   	pop    %edi
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	57                   	push   %edi
  800858:	56                   	push   %esi
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80085f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800862:	39 c6                	cmp    %eax,%esi
  800864:	73 35                	jae    80089b <memmove+0x47>
  800866:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800869:	39 d0                	cmp    %edx,%eax
  80086b:	73 2e                	jae    80089b <memmove+0x47>
		s += n;
		d += n;
  80086d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800870:	89 d6                	mov    %edx,%esi
  800872:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800874:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80087a:	75 13                	jne    80088f <memmove+0x3b>
  80087c:	f6 c1 03             	test   $0x3,%cl
  80087f:	75 0e                	jne    80088f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800881:	83 ef 04             	sub    $0x4,%edi
  800884:	8d 72 fc             	lea    -0x4(%edx),%esi
  800887:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80088a:	fd                   	std    
  80088b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80088d:	eb 09                	jmp    800898 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80088f:	83 ef 01             	sub    $0x1,%edi
  800892:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800895:	fd                   	std    
  800896:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800898:	fc                   	cld    
  800899:	eb 1d                	jmp    8008b8 <memmove+0x64>
  80089b:	89 f2                	mov    %esi,%edx
  80089d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80089f:	f6 c2 03             	test   $0x3,%dl
  8008a2:	75 0f                	jne    8008b3 <memmove+0x5f>
  8008a4:	f6 c1 03             	test   $0x3,%cl
  8008a7:	75 0a                	jne    8008b3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008a9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008ac:	89 c7                	mov    %eax,%edi
  8008ae:	fc                   	cld    
  8008af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008b1:	eb 05                	jmp    8008b8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008b3:	89 c7                	mov    %eax,%edi
  8008b5:	fc                   	cld    
  8008b6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008b8:	5e                   	pop    %esi
  8008b9:	5f                   	pop    %edi
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008bf:	ff 75 10             	pushl  0x10(%ebp)
  8008c2:	ff 75 0c             	pushl  0xc(%ebp)
  8008c5:	ff 75 08             	pushl  0x8(%ebp)
  8008c8:	e8 87 ff ff ff       	call   800854 <memmove>
}
  8008cd:	c9                   	leave  
  8008ce:	c3                   	ret    

008008cf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	56                   	push   %esi
  8008d3:	53                   	push   %ebx
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008da:	89 c6                	mov    %eax,%esi
  8008dc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008df:	eb 1a                	jmp    8008fb <memcmp+0x2c>
		if (*s1 != *s2)
  8008e1:	0f b6 08             	movzbl (%eax),%ecx
  8008e4:	0f b6 1a             	movzbl (%edx),%ebx
  8008e7:	38 d9                	cmp    %bl,%cl
  8008e9:	74 0a                	je     8008f5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008eb:	0f b6 c1             	movzbl %cl,%eax
  8008ee:	0f b6 db             	movzbl %bl,%ebx
  8008f1:	29 d8                	sub    %ebx,%eax
  8008f3:	eb 0f                	jmp    800904 <memcmp+0x35>
		s1++, s2++;
  8008f5:	83 c0 01             	add    $0x1,%eax
  8008f8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008fb:	39 f0                	cmp    %esi,%eax
  8008fd:	75 e2                	jne    8008e1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8008ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800904:	5b                   	pop    %ebx
  800905:	5e                   	pop    %esi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800911:	89 c2                	mov    %eax,%edx
  800913:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800916:	eb 07                	jmp    80091f <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800918:	38 08                	cmp    %cl,(%eax)
  80091a:	74 07                	je     800923 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80091c:	83 c0 01             	add    $0x1,%eax
  80091f:	39 d0                	cmp    %edx,%eax
  800921:	72 f5                	jb     800918 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	57                   	push   %edi
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800931:	eb 03                	jmp    800936 <strtol+0x11>
		s++;
  800933:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800936:	0f b6 01             	movzbl (%ecx),%eax
  800939:	3c 09                	cmp    $0x9,%al
  80093b:	74 f6                	je     800933 <strtol+0xe>
  80093d:	3c 20                	cmp    $0x20,%al
  80093f:	74 f2                	je     800933 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800941:	3c 2b                	cmp    $0x2b,%al
  800943:	75 0a                	jne    80094f <strtol+0x2a>
		s++;
  800945:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800948:	bf 00 00 00 00       	mov    $0x0,%edi
  80094d:	eb 10                	jmp    80095f <strtol+0x3a>
  80094f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800954:	3c 2d                	cmp    $0x2d,%al
  800956:	75 07                	jne    80095f <strtol+0x3a>
		s++, neg = 1;
  800958:	8d 49 01             	lea    0x1(%ecx),%ecx
  80095b:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80095f:	85 db                	test   %ebx,%ebx
  800961:	0f 94 c0             	sete   %al
  800964:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80096a:	75 19                	jne    800985 <strtol+0x60>
  80096c:	80 39 30             	cmpb   $0x30,(%ecx)
  80096f:	75 14                	jne    800985 <strtol+0x60>
  800971:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800975:	0f 85 82 00 00 00    	jne    8009fd <strtol+0xd8>
		s += 2, base = 16;
  80097b:	83 c1 02             	add    $0x2,%ecx
  80097e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800983:	eb 16                	jmp    80099b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800985:	84 c0                	test   %al,%al
  800987:	74 12                	je     80099b <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800989:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80098e:	80 39 30             	cmpb   $0x30,(%ecx)
  800991:	75 08                	jne    80099b <strtol+0x76>
		s++, base = 8;
  800993:	83 c1 01             	add    $0x1,%ecx
  800996:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80099b:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009a3:	0f b6 11             	movzbl (%ecx),%edx
  8009a6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009a9:	89 f3                	mov    %esi,%ebx
  8009ab:	80 fb 09             	cmp    $0x9,%bl
  8009ae:	77 08                	ja     8009b8 <strtol+0x93>
			dig = *s - '0';
  8009b0:	0f be d2             	movsbl %dl,%edx
  8009b3:	83 ea 30             	sub    $0x30,%edx
  8009b6:	eb 22                	jmp    8009da <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8009b8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009bb:	89 f3                	mov    %esi,%ebx
  8009bd:	80 fb 19             	cmp    $0x19,%bl
  8009c0:	77 08                	ja     8009ca <strtol+0xa5>
			dig = *s - 'a' + 10;
  8009c2:	0f be d2             	movsbl %dl,%edx
  8009c5:	83 ea 57             	sub    $0x57,%edx
  8009c8:	eb 10                	jmp    8009da <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8009ca:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009cd:	89 f3                	mov    %esi,%ebx
  8009cf:	80 fb 19             	cmp    $0x19,%bl
  8009d2:	77 16                	ja     8009ea <strtol+0xc5>
			dig = *s - 'A' + 10;
  8009d4:	0f be d2             	movsbl %dl,%edx
  8009d7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009da:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009dd:	7d 0f                	jge    8009ee <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8009df:	83 c1 01             	add    $0x1,%ecx
  8009e2:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009e6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009e8:	eb b9                	jmp    8009a3 <strtol+0x7e>
  8009ea:	89 c2                	mov    %eax,%edx
  8009ec:	eb 02                	jmp    8009f0 <strtol+0xcb>
  8009ee:	89 c2                	mov    %eax,%edx

	if (endptr)
  8009f0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009f4:	74 0d                	je     800a03 <strtol+0xde>
		*endptr = (char *) s;
  8009f6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f9:	89 0e                	mov    %ecx,(%esi)
  8009fb:	eb 06                	jmp    800a03 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009fd:	84 c0                	test   %al,%al
  8009ff:	75 92                	jne    800993 <strtol+0x6e>
  800a01:	eb 98                	jmp    80099b <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a03:	f7 da                	neg    %edx
  800a05:	85 ff                	test   %edi,%edi
  800a07:	0f 45 c2             	cmovne %edx,%eax
}
  800a0a:	5b                   	pop    %ebx
  800a0b:	5e                   	pop    %esi
  800a0c:	5f                   	pop    %edi
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	57                   	push   %edi
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a20:	89 c3                	mov    %eax,%ebx
  800a22:	89 c7                	mov    %eax,%edi
  800a24:	89 c6                	mov    %eax,%esi
  800a26:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a28:	5b                   	pop    %ebx
  800a29:	5e                   	pop    %esi
  800a2a:	5f                   	pop    %edi
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <sys_cgetc>:

int
sys_cgetc(void)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	57                   	push   %edi
  800a31:	56                   	push   %esi
  800a32:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a33:	ba 00 00 00 00       	mov    $0x0,%edx
  800a38:	b8 01 00 00 00       	mov    $0x1,%eax
  800a3d:	89 d1                	mov    %edx,%ecx
  800a3f:	89 d3                	mov    %edx,%ebx
  800a41:	89 d7                	mov    %edx,%edi
  800a43:	89 d6                	mov    %edx,%esi
  800a45:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a47:	5b                   	pop    %ebx
  800a48:	5e                   	pop    %esi
  800a49:	5f                   	pop    %edi
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	57                   	push   %edi
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
  800a52:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a5a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a62:	89 cb                	mov    %ecx,%ebx
  800a64:	89 cf                	mov    %ecx,%edi
  800a66:	89 ce                	mov    %ecx,%esi
  800a68:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a6a:	85 c0                	test   %eax,%eax
  800a6c:	7e 17                	jle    800a85 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a6e:	83 ec 0c             	sub    $0xc,%esp
  800a71:	50                   	push   %eax
  800a72:	6a 03                	push   $0x3
  800a74:	68 00 10 80 00       	push   $0x801000
  800a79:	6a 23                	push   $0x23
  800a7b:	68 1d 10 80 00       	push   $0x80101d
  800a80:	e8 27 00 00 00       	call   800aac <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a88:	5b                   	pop    %ebx
  800a89:	5e                   	pop    %esi
  800a8a:	5f                   	pop    %edi
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	57                   	push   %edi
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a93:	ba 00 00 00 00       	mov    $0x0,%edx
  800a98:	b8 02 00 00 00       	mov    $0x2,%eax
  800a9d:	89 d1                	mov    %edx,%ecx
  800a9f:	89 d3                	mov    %edx,%ebx
  800aa1:	89 d7                	mov    %edx,%edi
  800aa3:	89 d6                	mov    %edx,%esi
  800aa5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aa7:	5b                   	pop    %ebx
  800aa8:	5e                   	pop    %esi
  800aa9:	5f                   	pop    %edi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ab1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ab4:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800aba:	e8 ce ff ff ff       	call   800a8d <sys_getenvid>
  800abf:	83 ec 0c             	sub    $0xc,%esp
  800ac2:	ff 75 0c             	pushl  0xc(%ebp)
  800ac5:	ff 75 08             	pushl  0x8(%ebp)
  800ac8:	56                   	push   %esi
  800ac9:	50                   	push   %eax
  800aca:	68 2c 10 80 00       	push   $0x80102c
  800acf:	e8 67 f6 ff ff       	call   80013b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ad4:	83 c4 18             	add    $0x18,%esp
  800ad7:	53                   	push   %ebx
  800ad8:	ff 75 10             	pushl  0x10(%ebp)
  800adb:	e8 0a f6 ff ff       	call   8000ea <vcprintf>
	cprintf("\n");
  800ae0:	c7 04 24 cc 0d 80 00 	movl   $0x800dcc,(%esp)
  800ae7:	e8 4f f6 ff ff       	call   80013b <cprintf>
  800aec:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800aef:	cc                   	int3   
  800af0:	eb fd                	jmp    800aef <_panic+0x43>
  800af2:	66 90                	xchg   %ax,%ax
  800af4:	66 90                	xchg   %ax,%ax
  800af6:	66 90                	xchg   %ax,%ax
  800af8:	66 90                	xchg   %ax,%ax
  800afa:	66 90                	xchg   %ax,%ax
  800afc:	66 90                	xchg   %ax,%ax
  800afe:	66 90                	xchg   %ax,%ax

00800b00 <__udivdi3>:
  800b00:	55                   	push   %ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	83 ec 10             	sub    $0x10,%esp
  800b06:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800b0a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800b0e:	8b 74 24 24          	mov    0x24(%esp),%esi
  800b12:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800b16:	85 d2                	test   %edx,%edx
  800b18:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b1c:	89 34 24             	mov    %esi,(%esp)
  800b1f:	89 c8                	mov    %ecx,%eax
  800b21:	75 35                	jne    800b58 <__udivdi3+0x58>
  800b23:	39 f1                	cmp    %esi,%ecx
  800b25:	0f 87 bd 00 00 00    	ja     800be8 <__udivdi3+0xe8>
  800b2b:	85 c9                	test   %ecx,%ecx
  800b2d:	89 cd                	mov    %ecx,%ebp
  800b2f:	75 0b                	jne    800b3c <__udivdi3+0x3c>
  800b31:	b8 01 00 00 00       	mov    $0x1,%eax
  800b36:	31 d2                	xor    %edx,%edx
  800b38:	f7 f1                	div    %ecx
  800b3a:	89 c5                	mov    %eax,%ebp
  800b3c:	89 f0                	mov    %esi,%eax
  800b3e:	31 d2                	xor    %edx,%edx
  800b40:	f7 f5                	div    %ebp
  800b42:	89 c6                	mov    %eax,%esi
  800b44:	89 f8                	mov    %edi,%eax
  800b46:	f7 f5                	div    %ebp
  800b48:	89 f2                	mov    %esi,%edx
  800b4a:	83 c4 10             	add    $0x10,%esp
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    
  800b51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800b58:	3b 14 24             	cmp    (%esp),%edx
  800b5b:	77 7b                	ja     800bd8 <__udivdi3+0xd8>
  800b5d:	0f bd f2             	bsr    %edx,%esi
  800b60:	83 f6 1f             	xor    $0x1f,%esi
  800b63:	0f 84 97 00 00 00    	je     800c00 <__udivdi3+0x100>
  800b69:	bd 20 00 00 00       	mov    $0x20,%ebp
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	89 f1                	mov    %esi,%ecx
  800b72:	29 f5                	sub    %esi,%ebp
  800b74:	d3 e7                	shl    %cl,%edi
  800b76:	89 c2                	mov    %eax,%edx
  800b78:	89 e9                	mov    %ebp,%ecx
  800b7a:	d3 ea                	shr    %cl,%edx
  800b7c:	89 f1                	mov    %esi,%ecx
  800b7e:	09 fa                	or     %edi,%edx
  800b80:	8b 3c 24             	mov    (%esp),%edi
  800b83:	d3 e0                	shl    %cl,%eax
  800b85:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b89:	89 e9                	mov    %ebp,%ecx
  800b8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b8f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800b93:	89 fa                	mov    %edi,%edx
  800b95:	d3 ea                	shr    %cl,%edx
  800b97:	89 f1                	mov    %esi,%ecx
  800b99:	d3 e7                	shl    %cl,%edi
  800b9b:	89 e9                	mov    %ebp,%ecx
  800b9d:	d3 e8                	shr    %cl,%eax
  800b9f:	09 c7                	or     %eax,%edi
  800ba1:	89 f8                	mov    %edi,%eax
  800ba3:	f7 74 24 08          	divl   0x8(%esp)
  800ba7:	89 d5                	mov    %edx,%ebp
  800ba9:	89 c7                	mov    %eax,%edi
  800bab:	f7 64 24 0c          	mull   0xc(%esp)
  800baf:	39 d5                	cmp    %edx,%ebp
  800bb1:	89 14 24             	mov    %edx,(%esp)
  800bb4:	72 11                	jb     800bc7 <__udivdi3+0xc7>
  800bb6:	8b 54 24 04          	mov    0x4(%esp),%edx
  800bba:	89 f1                	mov    %esi,%ecx
  800bbc:	d3 e2                	shl    %cl,%edx
  800bbe:	39 c2                	cmp    %eax,%edx
  800bc0:	73 5e                	jae    800c20 <__udivdi3+0x120>
  800bc2:	3b 2c 24             	cmp    (%esp),%ebp
  800bc5:	75 59                	jne    800c20 <__udivdi3+0x120>
  800bc7:	8d 47 ff             	lea    -0x1(%edi),%eax
  800bca:	31 f6                	xor    %esi,%esi
  800bcc:	89 f2                	mov    %esi,%edx
  800bce:	83 c4 10             	add    $0x10,%esp
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    
  800bd5:	8d 76 00             	lea    0x0(%esi),%esi
  800bd8:	31 f6                	xor    %esi,%esi
  800bda:	31 c0                	xor    %eax,%eax
  800bdc:	89 f2                	mov    %esi,%edx
  800bde:	83 c4 10             	add    $0x10,%esp
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    
  800be5:	8d 76 00             	lea    0x0(%esi),%esi
  800be8:	89 f2                	mov    %esi,%edx
  800bea:	31 f6                	xor    %esi,%esi
  800bec:	89 f8                	mov    %edi,%eax
  800bee:	f7 f1                	div    %ecx
  800bf0:	89 f2                	mov    %esi,%edx
  800bf2:	83 c4 10             	add    $0x10,%esp
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    
  800bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c00:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800c04:	76 0b                	jbe    800c11 <__udivdi3+0x111>
  800c06:	31 c0                	xor    %eax,%eax
  800c08:	3b 14 24             	cmp    (%esp),%edx
  800c0b:	0f 83 37 ff ff ff    	jae    800b48 <__udivdi3+0x48>
  800c11:	b8 01 00 00 00       	mov    $0x1,%eax
  800c16:	e9 2d ff ff ff       	jmp    800b48 <__udivdi3+0x48>
  800c1b:	90                   	nop
  800c1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c20:	89 f8                	mov    %edi,%eax
  800c22:	31 f6                	xor    %esi,%esi
  800c24:	e9 1f ff ff ff       	jmp    800b48 <__udivdi3+0x48>
  800c29:	66 90                	xchg   %ax,%ax
  800c2b:	66 90                	xchg   %ax,%ax
  800c2d:	66 90                	xchg   %ax,%ax
  800c2f:	90                   	nop

00800c30 <__umoddi3>:
  800c30:	55                   	push   %ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	83 ec 20             	sub    $0x20,%esp
  800c36:	8b 44 24 34          	mov    0x34(%esp),%eax
  800c3a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c3e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c42:	89 c6                	mov    %eax,%esi
  800c44:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c48:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c4c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800c50:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c54:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800c58:	89 74 24 18          	mov    %esi,0x18(%esp)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	89 c2                	mov    %eax,%edx
  800c60:	75 1e                	jne    800c80 <__umoddi3+0x50>
  800c62:	39 f7                	cmp    %esi,%edi
  800c64:	76 52                	jbe    800cb8 <__umoddi3+0x88>
  800c66:	89 c8                	mov    %ecx,%eax
  800c68:	89 f2                	mov    %esi,%edx
  800c6a:	f7 f7                	div    %edi
  800c6c:	89 d0                	mov    %edx,%eax
  800c6e:	31 d2                	xor    %edx,%edx
  800c70:	83 c4 20             	add    $0x20,%esp
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    
  800c77:	89 f6                	mov    %esi,%esi
  800c79:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800c80:	39 f0                	cmp    %esi,%eax
  800c82:	77 5c                	ja     800ce0 <__umoddi3+0xb0>
  800c84:	0f bd e8             	bsr    %eax,%ebp
  800c87:	83 f5 1f             	xor    $0x1f,%ebp
  800c8a:	75 64                	jne    800cf0 <__umoddi3+0xc0>
  800c8c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800c90:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800c94:	0f 86 f6 00 00 00    	jbe    800d90 <__umoddi3+0x160>
  800c9a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800c9e:	0f 82 ec 00 00 00    	jb     800d90 <__umoddi3+0x160>
  800ca4:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ca8:	8b 54 24 18          	mov    0x18(%esp),%edx
  800cac:	83 c4 20             	add    $0x20,%esp
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    
  800cb3:	90                   	nop
  800cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cb8:	85 ff                	test   %edi,%edi
  800cba:	89 fd                	mov    %edi,%ebp
  800cbc:	75 0b                	jne    800cc9 <__umoddi3+0x99>
  800cbe:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc3:	31 d2                	xor    %edx,%edx
  800cc5:	f7 f7                	div    %edi
  800cc7:	89 c5                	mov    %eax,%ebp
  800cc9:	8b 44 24 10          	mov    0x10(%esp),%eax
  800ccd:	31 d2                	xor    %edx,%edx
  800ccf:	f7 f5                	div    %ebp
  800cd1:	89 c8                	mov    %ecx,%eax
  800cd3:	f7 f5                	div    %ebp
  800cd5:	eb 95                	jmp    800c6c <__umoddi3+0x3c>
  800cd7:	89 f6                	mov    %esi,%esi
  800cd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ce0:	89 c8                	mov    %ecx,%eax
  800ce2:	89 f2                	mov    %esi,%edx
  800ce4:	83 c4 20             	add    $0x20,%esp
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    
  800ceb:	90                   	nop
  800cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cf0:	b8 20 00 00 00       	mov    $0x20,%eax
  800cf5:	89 e9                	mov    %ebp,%ecx
  800cf7:	29 e8                	sub    %ebp,%eax
  800cf9:	d3 e2                	shl    %cl,%edx
  800cfb:	89 c7                	mov    %eax,%edi
  800cfd:	89 44 24 18          	mov    %eax,0x18(%esp)
  800d01:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800d05:	89 f9                	mov    %edi,%ecx
  800d07:	d3 e8                	shr    %cl,%eax
  800d09:	89 c1                	mov    %eax,%ecx
  800d0b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800d0f:	09 d1                	or     %edx,%ecx
  800d11:	89 fa                	mov    %edi,%edx
  800d13:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800d17:	89 e9                	mov    %ebp,%ecx
  800d19:	d3 e0                	shl    %cl,%eax
  800d1b:	89 f9                	mov    %edi,%ecx
  800d1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d21:	89 f0                	mov    %esi,%eax
  800d23:	d3 e8                	shr    %cl,%eax
  800d25:	89 e9                	mov    %ebp,%ecx
  800d27:	89 c7                	mov    %eax,%edi
  800d29:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800d2d:	d3 e6                	shl    %cl,%esi
  800d2f:	89 d1                	mov    %edx,%ecx
  800d31:	89 fa                	mov    %edi,%edx
  800d33:	d3 e8                	shr    %cl,%eax
  800d35:	89 e9                	mov    %ebp,%ecx
  800d37:	09 f0                	or     %esi,%eax
  800d39:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800d3d:	f7 74 24 10          	divl   0x10(%esp)
  800d41:	d3 e6                	shl    %cl,%esi
  800d43:	89 d1                	mov    %edx,%ecx
  800d45:	f7 64 24 0c          	mull   0xc(%esp)
  800d49:	39 d1                	cmp    %edx,%ecx
  800d4b:	89 74 24 14          	mov    %esi,0x14(%esp)
  800d4f:	89 d7                	mov    %edx,%edi
  800d51:	89 c6                	mov    %eax,%esi
  800d53:	72 0a                	jb     800d5f <__umoddi3+0x12f>
  800d55:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800d59:	73 10                	jae    800d6b <__umoddi3+0x13b>
  800d5b:	39 d1                	cmp    %edx,%ecx
  800d5d:	75 0c                	jne    800d6b <__umoddi3+0x13b>
  800d5f:	89 d7                	mov    %edx,%edi
  800d61:	89 c6                	mov    %eax,%esi
  800d63:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800d67:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800d6b:	89 ca                	mov    %ecx,%edx
  800d6d:	89 e9                	mov    %ebp,%ecx
  800d6f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800d73:	29 f0                	sub    %esi,%eax
  800d75:	19 fa                	sbb    %edi,%edx
  800d77:	d3 e8                	shr    %cl,%eax
  800d79:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800d7e:	89 d7                	mov    %edx,%edi
  800d80:	d3 e7                	shl    %cl,%edi
  800d82:	89 e9                	mov    %ebp,%ecx
  800d84:	09 f8                	or     %edi,%eax
  800d86:	d3 ea                	shr    %cl,%edx
  800d88:	83 c4 20             	add    $0x20,%esp
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    
  800d8f:	90                   	nop
  800d90:	8b 74 24 10          	mov    0x10(%esp),%esi
  800d94:	29 f9                	sub    %edi,%ecx
  800d96:	19 c6                	sbb    %eax,%esi
  800d98:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800d9c:	89 74 24 18          	mov    %esi,0x18(%esp)
  800da0:	e9 ff fe ff ff       	jmp    800ca4 <__umoddi3+0x74>
