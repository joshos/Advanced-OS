
obj/user/faultreadkernel:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80003f:	68 a0 0d 80 00       	push   $0x800da0
  800044:	e8 e0 00 00 00       	call   800129 <cprintf>
  800049:	83 c4 10             	add    $0x10,%esp
}
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	83 ec 08             	sub    $0x8,%esp
  800054:	8b 45 08             	mov    0x8(%ebp),%eax
  800057:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800061:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 c0                	test   %eax,%eax
  800066:	7e 08                	jle    800070 <libmain+0x22>
		binaryname = argv[0];
  800068:	8b 0a                	mov    (%edx),%ecx
  80006a:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800070:	83 ec 08             	sub    $0x8,%esp
  800073:	52                   	push   %edx
  800074:	50                   	push   %eax
  800075:	e8 b9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007a:	e8 05 00 00 00       	call   800084 <exit>
  80007f:	83 c4 10             	add    $0x10,%esp
}
  800082:	c9                   	leave  
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008a:	6a 00                	push   $0x0
  80008c:	e8 a9 09 00 00       	call   800a3a <sys_env_destroy>
  800091:	83 c4 10             	add    $0x10,%esp
}
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	53                   	push   %ebx
  80009a:	83 ec 04             	sub    $0x4,%esp
  80009d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000a0:	8b 13                	mov    (%ebx),%edx
  8000a2:	8d 42 01             	lea    0x1(%edx),%eax
  8000a5:	89 03                	mov    %eax,(%ebx)
  8000a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000b3:	75 1a                	jne    8000cf <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000b5:	83 ec 08             	sub    $0x8,%esp
  8000b8:	68 ff 00 00 00       	push   $0xff
  8000bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000c0:	50                   	push   %eax
  8000c1:	e8 37 09 00 00       	call   8009fd <sys_cputs>
		b->idx = 0;
  8000c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000cc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000cf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000e8:	00 00 00 
	b.cnt = 0;
  8000eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000f5:	ff 75 0c             	pushl  0xc(%ebp)
  8000f8:	ff 75 08             	pushl  0x8(%ebp)
  8000fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800101:	50                   	push   %eax
  800102:	68 96 00 80 00       	push   $0x800096
  800107:	e8 4f 01 00 00       	call   80025b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80010c:	83 c4 08             	add    $0x8,%esp
  80010f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800115:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80011b:	50                   	push   %eax
  80011c:	e8 dc 08 00 00       	call   8009fd <sys_cputs>

	return b.cnt;
}
  800121:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800127:	c9                   	leave  
  800128:	c3                   	ret    

00800129 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80012f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800132:	50                   	push   %eax
  800133:	ff 75 08             	pushl  0x8(%ebp)
  800136:	e8 9d ff ff ff       	call   8000d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80013b:	c9                   	leave  
  80013c:	c3                   	ret    

0080013d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	57                   	push   %edi
  800141:	56                   	push   %esi
  800142:	53                   	push   %ebx
  800143:	83 ec 1c             	sub    $0x1c,%esp
  800146:	89 c7                	mov    %eax,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	8b 45 08             	mov    0x8(%ebp),%eax
  80014d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800150:	89 d1                	mov    %edx,%ecx
  800152:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800155:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800158:	8b 45 10             	mov    0x10(%ebp),%eax
  80015b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80015e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800161:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800168:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80016b:	72 05                	jb     800172 <printnum+0x35>
  80016d:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800170:	77 3e                	ja     8001b0 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800172:	83 ec 0c             	sub    $0xc,%esp
  800175:	ff 75 18             	pushl  0x18(%ebp)
  800178:	83 eb 01             	sub    $0x1,%ebx
  80017b:	53                   	push   %ebx
  80017c:	50                   	push   %eax
  80017d:	83 ec 08             	sub    $0x8,%esp
  800180:	ff 75 e4             	pushl  -0x1c(%ebp)
  800183:	ff 75 e0             	pushl  -0x20(%ebp)
  800186:	ff 75 dc             	pushl  -0x24(%ebp)
  800189:	ff 75 d8             	pushl  -0x28(%ebp)
  80018c:	e8 4f 09 00 00       	call   800ae0 <__udivdi3>
  800191:	83 c4 18             	add    $0x18,%esp
  800194:	52                   	push   %edx
  800195:	50                   	push   %eax
  800196:	89 f2                	mov    %esi,%edx
  800198:	89 f8                	mov    %edi,%eax
  80019a:	e8 9e ff ff ff       	call   80013d <printnum>
  80019f:	83 c4 20             	add    $0x20,%esp
  8001a2:	eb 13                	jmp    8001b7 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001a4:	83 ec 08             	sub    $0x8,%esp
  8001a7:	56                   	push   %esi
  8001a8:	ff 75 18             	pushl  0x18(%ebp)
  8001ab:	ff d7                	call   *%edi
  8001ad:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001b0:	83 eb 01             	sub    $0x1,%ebx
  8001b3:	85 db                	test   %ebx,%ebx
  8001b5:	7f ed                	jg     8001a4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001b7:	83 ec 08             	sub    $0x8,%esp
  8001ba:	56                   	push   %esi
  8001bb:	83 ec 04             	sub    $0x4,%esp
  8001be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c4:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c7:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ca:	e8 41 0a 00 00       	call   800c10 <__umoddi3>
  8001cf:	83 c4 14             	add    $0x14,%esp
  8001d2:	0f be 80 d1 0d 80 00 	movsbl 0x800dd1(%eax),%eax
  8001d9:	50                   	push   %eax
  8001da:	ff d7                	call   *%edi
  8001dc:	83 c4 10             	add    $0x10,%esp
}
  8001df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5f                   	pop    %edi
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    

008001e7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8001ea:	83 fa 01             	cmp    $0x1,%edx
  8001ed:	7e 0e                	jle    8001fd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8001ef:	8b 10                	mov    (%eax),%edx
  8001f1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8001f4:	89 08                	mov    %ecx,(%eax)
  8001f6:	8b 02                	mov    (%edx),%eax
  8001f8:	8b 52 04             	mov    0x4(%edx),%edx
  8001fb:	eb 22                	jmp    80021f <getuint+0x38>
	else if (lflag)
  8001fd:	85 d2                	test   %edx,%edx
  8001ff:	74 10                	je     800211 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800201:	8b 10                	mov    (%eax),%edx
  800203:	8d 4a 04             	lea    0x4(%edx),%ecx
  800206:	89 08                	mov    %ecx,(%eax)
  800208:	8b 02                	mov    (%edx),%eax
  80020a:	ba 00 00 00 00       	mov    $0x0,%edx
  80020f:	eb 0e                	jmp    80021f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800211:	8b 10                	mov    (%eax),%edx
  800213:	8d 4a 04             	lea    0x4(%edx),%ecx
  800216:	89 08                	mov    %ecx,(%eax)
  800218:	8b 02                	mov    (%edx),%eax
  80021a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800227:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80022b:	8b 10                	mov    (%eax),%edx
  80022d:	3b 50 04             	cmp    0x4(%eax),%edx
  800230:	73 0a                	jae    80023c <sprintputch+0x1b>
		*b->buf++ = ch;
  800232:	8d 4a 01             	lea    0x1(%edx),%ecx
  800235:	89 08                	mov    %ecx,(%eax)
  800237:	8b 45 08             	mov    0x8(%ebp),%eax
  80023a:	88 02                	mov    %al,(%edx)
}
  80023c:	5d                   	pop    %ebp
  80023d:	c3                   	ret    

0080023e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800244:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800247:	50                   	push   %eax
  800248:	ff 75 10             	pushl  0x10(%ebp)
  80024b:	ff 75 0c             	pushl  0xc(%ebp)
  80024e:	ff 75 08             	pushl  0x8(%ebp)
  800251:	e8 05 00 00 00       	call   80025b <vprintfmt>
	va_end(ap);
  800256:	83 c4 10             	add    $0x10,%esp
}
  800259:	c9                   	leave  
  80025a:	c3                   	ret    

0080025b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	57                   	push   %edi
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
  800261:	83 ec 2c             	sub    $0x2c,%esp
  800264:	8b 75 08             	mov    0x8(%ebp),%esi
  800267:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80026a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80026d:	eb 12                	jmp    800281 <vprintfmt+0x26>

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
		{
			if (ch == '\0')
  80026f:	85 c0                	test   %eax,%eax
  800271:	0f 84 90 03 00 00    	je     800607 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800277:	83 ec 08             	sub    $0x8,%esp
  80027a:	53                   	push   %ebx
  80027b:	50                   	push   %eax
  80027c:	ff d6                	call   *%esi
  80027e:	83 c4 10             	add    $0x10,%esp
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
  800281:	83 c7 01             	add    $0x1,%edi
  800284:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800288:	83 f8 25             	cmp    $0x25,%eax
  80028b:	75 e2                	jne    80026f <vprintfmt+0x14>
  80028d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800291:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800298:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80029f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ab:	eb 07                	jmp    8002b4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8002ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		{

			// flag to pad on the right
			case '-':
				padc = '-';
  8002b0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8002b4:	8d 47 01             	lea    0x1(%edi),%eax
  8002b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ba:	0f b6 07             	movzbl (%edi),%eax
  8002bd:	0f b6 c8             	movzbl %al,%ecx
  8002c0:	83 e8 23             	sub    $0x23,%eax
  8002c3:	3c 55                	cmp    $0x55,%al
  8002c5:	0f 87 21 03 00 00    	ja     8005ec <vprintfmt+0x391>
  8002cb:	0f b6 c0             	movzbl %al,%eax
  8002ce:	ff 24 85 60 0e 80 00 	jmp    *0x800e60(,%eax,4)
  8002d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				padc = '-';
				goto reswitch;

			// flag to pad with 0's instead of spaces
			case '0':
				padc = '0';
  8002d8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002dc:	eb d6                	jmp    8002b4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8002de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
					precision = precision * 10 + ch - '0';
  8002e9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002ec:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
					ch = *fmt;
  8002f0:	0f be 0f             	movsbl (%edi),%ecx
					if (ch < '0' || ch > '9')
  8002f3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8002f6:	83 fa 09             	cmp    $0x9,%edx
  8002f9:	77 39                	ja     800334 <vprintfmt+0xd9>
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
  8002fb:	83 c7 01             	add    $0x1,%edi
					precision = precision * 10 + ch - '0';
					ch = *fmt;
					if (ch < '0' || ch > '9')
						break;
				}
  8002fe:	eb e9                	jmp    8002e9 <vprintfmt+0x8e>
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
  800300:	8b 45 14             	mov    0x14(%ebp),%eax
  800303:	8d 48 04             	lea    0x4(%eax),%ecx
  800306:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800309:	8b 00                	mov    (%eax),%eax
  80030b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  80030e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				}
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
				goto process_precision;
  800311:	eb 27                	jmp    80033a <vprintfmt+0xdf>
  800313:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800316:	85 c0                	test   %eax,%eax
  800318:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031d:	0f 49 c8             	cmovns %eax,%ecx
  800320:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800323:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800326:	eb 8c                	jmp    8002b4 <vprintfmt+0x59>
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				if (width < 0)
					width = 0;
				goto reswitch;

			case '#':
				altflag = 1;
  80032b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				goto reswitch;
  800332:	eb 80                	jmp    8002b4 <vprintfmt+0x59>
  800334:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800337:	89 45 d0             	mov    %eax,-0x30(%ebp)

			process_precision:
				if (width < 0)
  80033a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80033e:	0f 89 70 ff ff ff    	jns    8002b4 <vprintfmt+0x59>
					width = precision, precision = -1;
  800344:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800347:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80034a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800351:	e9 5e ff ff ff       	jmp    8002b4 <vprintfmt+0x59>
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
  800356:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
				goto reswitch;
  80035c:	e9 53 ff ff ff       	jmp    8002b4 <vprintfmt+0x59>

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
  800361:	8b 45 14             	mov    0x14(%ebp),%eax
  800364:	8d 50 04             	lea    0x4(%eax),%edx
  800367:	89 55 14             	mov    %edx,0x14(%ebp)
  80036a:	83 ec 08             	sub    $0x8,%esp
  80036d:	53                   	push   %ebx
  80036e:	ff 30                	pushl  (%eax)
  800370:	ff d6                	call   *%esi
				break;
  800372:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
				break;
  800378:	e9 04 ff ff ff       	jmp    800281 <vprintfmt+0x26>

			// error message
			case 'e':
				err = va_arg(ap, int);
  80037d:	8b 45 14             	mov    0x14(%ebp),%eax
  800380:	8d 50 04             	lea    0x4(%eax),%edx
  800383:	89 55 14             	mov    %edx,0x14(%ebp)
  800386:	8b 00                	mov    (%eax),%eax
  800388:	99                   	cltd   
  800389:	31 d0                	xor    %edx,%eax
  80038b:	29 d0                	sub    %edx,%eax
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80038d:	83 f8 07             	cmp    $0x7,%eax
  800390:	7f 0b                	jg     80039d <vprintfmt+0x142>
  800392:	8b 14 85 c0 0f 80 00 	mov    0x800fc0(,%eax,4),%edx
  800399:	85 d2                	test   %edx,%edx
  80039b:	75 18                	jne    8003b5 <vprintfmt+0x15a>
					printfmt(putch, putdat, "error %d", err);
  80039d:	50                   	push   %eax
  80039e:	68 e9 0d 80 00       	push   $0x800de9
  8003a3:	53                   	push   %ebx
  8003a4:	56                   	push   %esi
  8003a5:	e8 94 fe ff ff       	call   80023e <printfmt>
  8003aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			case 'e':
				err = va_arg(ap, int);
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
					printfmt(putch, putdat, "error %d", err);
  8003b0:	e9 cc fe ff ff       	jmp    800281 <vprintfmt+0x26>
				else
					printfmt(putch, putdat, "%s", p);
  8003b5:	52                   	push   %edx
  8003b6:	68 f2 0d 80 00       	push   $0x800df2
  8003bb:	53                   	push   %ebx
  8003bc:	56                   	push   %esi
  8003bd:	e8 7c fe ff ff       	call   80023e <printfmt>
  8003c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c8:	e9 b4 fe ff ff       	jmp    800281 <vprintfmt+0x26>
  8003cd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d3:	89 45 cc             	mov    %eax,-0x34(%ebp)
					printfmt(putch, putdat, "%s", p);
				break;

			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
  8003d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d9:	8d 50 04             	lea    0x4(%eax),%edx
  8003dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8003df:	8b 38                	mov    (%eax),%edi
					p = "(null)";
  8003e1:	85 ff                	test   %edi,%edi
  8003e3:	ba e2 0d 80 00       	mov    $0x800de2,%edx
  8003e8:	0f 44 fa             	cmove  %edx,%edi
				if (width > 0 && padc != '-')
  8003eb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003ef:	0f 84 92 00 00 00    	je     800487 <vprintfmt+0x22c>
  8003f5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8003f9:	0f 8e 96 00 00 00    	jle    800495 <vprintfmt+0x23a>
					for (width -= strnlen(p, precision); width > 0; width--)
  8003ff:	83 ec 08             	sub    $0x8,%esp
  800402:	51                   	push   %ecx
  800403:	57                   	push   %edi
  800404:	e8 86 02 00 00       	call   80068f <strnlen>
  800409:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80040c:	29 c1                	sub    %eax,%ecx
  80040e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800411:	83 c4 10             	add    $0x10,%esp
						putch(padc, putdat);
  800414:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800418:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80041e:	89 cf                	mov    %ecx,%edi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  800420:	eb 0f                	jmp    800431 <vprintfmt+0x1d6>
						putch(padc, putdat);
  800422:	83 ec 08             	sub    $0x8,%esp
  800425:	53                   	push   %ebx
  800426:	ff 75 e0             	pushl  -0x20(%ebp)
  800429:	ff d6                	call   *%esi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  80042b:	83 ef 01             	sub    $0x1,%edi
  80042e:	83 c4 10             	add    $0x10,%esp
  800431:	85 ff                	test   %edi,%edi
  800433:	7f ed                	jg     800422 <vprintfmt+0x1c7>
  800435:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800438:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80043b:	85 c9                	test   %ecx,%ecx
  80043d:	b8 00 00 00 00       	mov    $0x0,%eax
  800442:	0f 49 c1             	cmovns %ecx,%eax
  800445:	29 c1                	sub    %eax,%ecx
  800447:	89 75 08             	mov    %esi,0x8(%ebp)
  80044a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80044d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800450:	89 cb                	mov    %ecx,%ebx
  800452:	eb 4d                	jmp    8004a1 <vprintfmt+0x246>
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
  800454:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800458:	74 1b                	je     800475 <vprintfmt+0x21a>
  80045a:	0f be c0             	movsbl %al,%eax
  80045d:	83 e8 20             	sub    $0x20,%eax
  800460:	83 f8 5e             	cmp    $0x5e,%eax
  800463:	76 10                	jbe    800475 <vprintfmt+0x21a>
						putch('?', putdat);
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	ff 75 0c             	pushl  0xc(%ebp)
  80046b:	6a 3f                	push   $0x3f
  80046d:	ff 55 08             	call   *0x8(%ebp)
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	eb 0d                	jmp    800482 <vprintfmt+0x227>
					else
						putch(ch, putdat);
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	ff 75 0c             	pushl  0xc(%ebp)
  80047b:	52                   	push   %edx
  80047c:	ff 55 08             	call   *0x8(%ebp)
  80047f:	83 c4 10             	add    $0x10,%esp
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800482:	83 eb 01             	sub    $0x1,%ebx
  800485:	eb 1a                	jmp    8004a1 <vprintfmt+0x246>
  800487:	89 75 08             	mov    %esi,0x8(%ebp)
  80048a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800490:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800493:	eb 0c                	jmp    8004a1 <vprintfmt+0x246>
  800495:	89 75 08             	mov    %esi,0x8(%ebp)
  800498:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80049b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a1:	83 c7 01             	add    $0x1,%edi
  8004a4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a8:	0f be d0             	movsbl %al,%edx
  8004ab:	85 d2                	test   %edx,%edx
  8004ad:	74 23                	je     8004d2 <vprintfmt+0x277>
  8004af:	85 f6                	test   %esi,%esi
  8004b1:	78 a1                	js     800454 <vprintfmt+0x1f9>
  8004b3:	83 ee 01             	sub    $0x1,%esi
  8004b6:	79 9c                	jns    800454 <vprintfmt+0x1f9>
  8004b8:	89 df                	mov    %ebx,%edi
  8004ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c0:	eb 18                	jmp    8004da <vprintfmt+0x27f>
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
					putch(' ', putdat);
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	53                   	push   %ebx
  8004c6:	6a 20                	push   $0x20
  8004c8:	ff d6                	call   *%esi
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
  8004ca:	83 ef 01             	sub    $0x1,%edi
  8004cd:	83 c4 10             	add    $0x10,%esp
  8004d0:	eb 08                	jmp    8004da <vprintfmt+0x27f>
  8004d2:	89 df                	mov    %ebx,%edi
  8004d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004da:	85 ff                	test   %edi,%edi
  8004dc:	7f e4                	jg     8004c2 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8004de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e1:	e9 9b fd ff ff       	jmp    800281 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004e6:	83 fa 01             	cmp    $0x1,%edx
  8004e9:	7e 16                	jle    800501 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8d 50 08             	lea    0x8(%eax),%edx
  8004f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f4:	8b 50 04             	mov    0x4(%eax),%edx
  8004f7:	8b 00                	mov    (%eax),%eax
  8004f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004ff:	eb 32                	jmp    800533 <vprintfmt+0x2d8>
	else if (lflag)
  800501:	85 d2                	test   %edx,%edx
  800503:	74 18                	je     80051d <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8d 50 04             	lea    0x4(%eax),%edx
  80050b:	89 55 14             	mov    %edx,0x14(%ebp)
  80050e:	8b 00                	mov    (%eax),%eax
  800510:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800513:	89 c1                	mov    %eax,%ecx
  800515:	c1 f9 1f             	sar    $0x1f,%ecx
  800518:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80051b:	eb 16                	jmp    800533 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  80051d:	8b 45 14             	mov    0x14(%ebp),%eax
  800520:	8d 50 04             	lea    0x4(%eax),%edx
  800523:	89 55 14             	mov    %edx,0x14(%ebp)
  800526:	8b 00                	mov    (%eax),%eax
  800528:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052b:	89 c1                	mov    %eax,%ecx
  80052d:	c1 f9 1f             	sar    $0x1f,%ecx
  800530:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(' ', putdat);
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
  800533:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800536:	8b 55 dc             	mov    -0x24(%ebp),%edx
				if ((long long) num < 0) {
					putch('-', putdat);
					num = -(long long) num;
				}
				base = 10;
  800539:	b9 0a 00 00 00       	mov    $0xa,%ecx
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
				if ((long long) num < 0) {
  80053e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800542:	79 74                	jns    8005b8 <vprintfmt+0x35d>
					putch('-', putdat);
  800544:	83 ec 08             	sub    $0x8,%esp
  800547:	53                   	push   %ebx
  800548:	6a 2d                	push   $0x2d
  80054a:	ff d6                	call   *%esi
					num = -(long long) num;
  80054c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80054f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800552:	f7 d8                	neg    %eax
  800554:	83 d2 00             	adc    $0x0,%edx
  800557:	f7 da                	neg    %edx
  800559:	83 c4 10             	add    $0x10,%esp
				}
				base = 10;
  80055c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800561:	eb 55                	jmp    8005b8 <vprintfmt+0x35d>
				goto number;

			// unsigned decimal
			case 'u':
				num = getuint(&ap, lflag);
  800563:	8d 45 14             	lea    0x14(%ebp),%eax
  800566:	e8 7c fc ff ff       	call   8001e7 <getuint>
				base = 10;
  80056b:	b9 0a 00 00 00       	mov    $0xa,%ecx
				goto number;
  800570:	eb 46                	jmp    8005b8 <vprintfmt+0x35d>
				// Replace this with your code.
				/*putch('X', putdat);
				putch('X', putdat);
				putch('X', putdat);*/
				
				num = getuint(&ap, lflag);
  800572:	8d 45 14             	lea    0x14(%ebp),%eax
  800575:	e8 6d fc ff ff       	call   8001e7 <getuint>
				base = 8;
  80057a:	b9 08 00 00 00       	mov    $0x8,%ecx
				goto number;
  80057f:	eb 37                	jmp    8005b8 <vprintfmt+0x35d>

			// pointer
			case 'p':
				putch('0', putdat);
  800581:	83 ec 08             	sub    $0x8,%esp
  800584:	53                   	push   %ebx
  800585:	6a 30                	push   $0x30
  800587:	ff d6                	call   *%esi
				putch('x', putdat);
  800589:	83 c4 08             	add    $0x8,%esp
  80058c:	53                   	push   %ebx
  80058d:	6a 78                	push   $0x78
  80058f:	ff d6                	call   *%esi
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8d 50 04             	lea    0x4(%eax),%edx
  800597:	89 55 14             	mov    %edx,0x14(%ebp)

			// pointer
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
  80059a:	8b 00                	mov    (%eax),%eax
  80059c:	ba 00 00 00 00       	mov    $0x0,%edx
					(uintptr_t) va_arg(ap, void *);
				base = 16;
				goto number;
  8005a1:	83 c4 10             	add    $0x10,%esp
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
				base = 16;
  8005a4:	b9 10 00 00 00       	mov    $0x10,%ecx
				goto number;
  8005a9:	eb 0d                	jmp    8005b8 <vprintfmt+0x35d>

			// (unsigned) hexadecimal
			case 'x':
				num = getuint(&ap, lflag);
  8005ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ae:	e8 34 fc ff ff       	call   8001e7 <getuint>
				base = 16;
  8005b3:	b9 10 00 00 00       	mov    $0x10,%ecx
			number:
				printnum(putch, putdat, num, base, width, padc);
  8005b8:	83 ec 0c             	sub    $0xc,%esp
  8005bb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005bf:	57                   	push   %edi
  8005c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8005c3:	51                   	push   %ecx
  8005c4:	52                   	push   %edx
  8005c5:	50                   	push   %eax
  8005c6:	89 da                	mov    %ebx,%edx
  8005c8:	89 f0                	mov    %esi,%eax
  8005ca:	e8 6e fb ff ff       	call   80013d <printnum>
				break;
  8005cf:	83 c4 20             	add    $0x20,%esp
  8005d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d5:	e9 a7 fc ff ff       	jmp    800281 <vprintfmt+0x26>

			// escaped '%' character
			case '%':
				putch(ch, putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	53                   	push   %ebx
  8005de:	51                   	push   %ecx
  8005df:	ff d6                	call   *%esi
				break;
  8005e1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				break;

			// escaped '%' character
			case '%':
				putch(ch, putdat);
				break;
  8005e7:	e9 95 fc ff ff       	jmp    800281 <vprintfmt+0x26>

			// unrecognized escape sequence - just print it literally
			default:
				putch('%', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	6a 25                	push   $0x25
  8005f2:	ff d6                	call   *%esi
				for (fmt--; fmt[-1] != '%'; fmt--)
  8005f4:	83 c4 10             	add    $0x10,%esp
  8005f7:	eb 03                	jmp    8005fc <vprintfmt+0x3a1>
  8005f9:	83 ef 01             	sub    $0x1,%edi
  8005fc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800600:	75 f7                	jne    8005f9 <vprintfmt+0x39e>
  800602:	e9 7a fc ff ff       	jmp    800281 <vprintfmt+0x26>
					/* do nothing */;
				break;
		}
	}
}
  800607:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80060a:	5b                   	pop    %ebx
  80060b:	5e                   	pop    %esi
  80060c:	5f                   	pop    %edi
  80060d:	5d                   	pop    %ebp
  80060e:	c3                   	ret    

0080060f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80060f:	55                   	push   %ebp
  800610:	89 e5                	mov    %esp,%ebp
  800612:	83 ec 18             	sub    $0x18,%esp
  800615:	8b 45 08             	mov    0x8(%ebp),%eax
  800618:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80061b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80061e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800622:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800625:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80062c:	85 c0                	test   %eax,%eax
  80062e:	74 26                	je     800656 <vsnprintf+0x47>
  800630:	85 d2                	test   %edx,%edx
  800632:	7e 22                	jle    800656 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800634:	ff 75 14             	pushl  0x14(%ebp)
  800637:	ff 75 10             	pushl  0x10(%ebp)
  80063a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80063d:	50                   	push   %eax
  80063e:	68 21 02 80 00       	push   $0x800221
  800643:	e8 13 fc ff ff       	call   80025b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800648:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80064b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80064e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	eb 05                	jmp    80065b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800656:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80065b:	c9                   	leave  
  80065c:	c3                   	ret    

0080065d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80065d:	55                   	push   %ebp
  80065e:	89 e5                	mov    %esp,%ebp
  800660:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800663:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800666:	50                   	push   %eax
  800667:	ff 75 10             	pushl  0x10(%ebp)
  80066a:	ff 75 0c             	pushl  0xc(%ebp)
  80066d:	ff 75 08             	pushl  0x8(%ebp)
  800670:	e8 9a ff ff ff       	call   80060f <vsnprintf>
	va_end(ap);

	return rc;
}
  800675:	c9                   	leave  
  800676:	c3                   	ret    

00800677 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800677:	55                   	push   %ebp
  800678:	89 e5                	mov    %esp,%ebp
  80067a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80067d:	b8 00 00 00 00       	mov    $0x0,%eax
  800682:	eb 03                	jmp    800687 <strlen+0x10>
		n++;
  800684:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800687:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80068b:	75 f7                	jne    800684 <strlen+0xd>
		n++;
	return n;
}
  80068d:	5d                   	pop    %ebp
  80068e:	c3                   	ret    

0080068f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80068f:	55                   	push   %ebp
  800690:	89 e5                	mov    %esp,%ebp
  800692:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800695:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800698:	ba 00 00 00 00       	mov    $0x0,%edx
  80069d:	eb 03                	jmp    8006a2 <strnlen+0x13>
		n++;
  80069f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006a2:	39 c2                	cmp    %eax,%edx
  8006a4:	74 08                	je     8006ae <strnlen+0x1f>
  8006a6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006aa:	75 f3                	jne    80069f <strnlen+0x10>
  8006ac:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006ae:	5d                   	pop    %ebp
  8006af:	c3                   	ret    

008006b0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006b0:	55                   	push   %ebp
  8006b1:	89 e5                	mov    %esp,%ebp
  8006b3:	53                   	push   %ebx
  8006b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006ba:	89 c2                	mov    %eax,%edx
  8006bc:	83 c2 01             	add    $0x1,%edx
  8006bf:	83 c1 01             	add    $0x1,%ecx
  8006c2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006c6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006c9:	84 db                	test   %bl,%bl
  8006cb:	75 ef                	jne    8006bc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006cd:	5b                   	pop    %ebx
  8006ce:	5d                   	pop    %ebp
  8006cf:	c3                   	ret    

008006d0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	53                   	push   %ebx
  8006d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006d7:	53                   	push   %ebx
  8006d8:	e8 9a ff ff ff       	call   800677 <strlen>
  8006dd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8006e0:	ff 75 0c             	pushl  0xc(%ebp)
  8006e3:	01 d8                	add    %ebx,%eax
  8006e5:	50                   	push   %eax
  8006e6:	e8 c5 ff ff ff       	call   8006b0 <strcpy>
	return dst;
}
  8006eb:	89 d8                	mov    %ebx,%eax
  8006ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    

008006f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	56                   	push   %esi
  8006f6:	53                   	push   %ebx
  8006f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006fd:	89 f3                	mov    %esi,%ebx
  8006ff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800702:	89 f2                	mov    %esi,%edx
  800704:	eb 0f                	jmp    800715 <strncpy+0x23>
		*dst++ = *src;
  800706:	83 c2 01             	add    $0x1,%edx
  800709:	0f b6 01             	movzbl (%ecx),%eax
  80070c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80070f:	80 39 01             	cmpb   $0x1,(%ecx)
  800712:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800715:	39 da                	cmp    %ebx,%edx
  800717:	75 ed                	jne    800706 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800719:	89 f0                	mov    %esi,%eax
  80071b:	5b                   	pop    %ebx
  80071c:	5e                   	pop    %esi
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	56                   	push   %esi
  800723:	53                   	push   %ebx
  800724:	8b 75 08             	mov    0x8(%ebp),%esi
  800727:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80072a:	8b 55 10             	mov    0x10(%ebp),%edx
  80072d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80072f:	85 d2                	test   %edx,%edx
  800731:	74 21                	je     800754 <strlcpy+0x35>
  800733:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800737:	89 f2                	mov    %esi,%edx
  800739:	eb 09                	jmp    800744 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80073b:	83 c2 01             	add    $0x1,%edx
  80073e:	83 c1 01             	add    $0x1,%ecx
  800741:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800744:	39 c2                	cmp    %eax,%edx
  800746:	74 09                	je     800751 <strlcpy+0x32>
  800748:	0f b6 19             	movzbl (%ecx),%ebx
  80074b:	84 db                	test   %bl,%bl
  80074d:	75 ec                	jne    80073b <strlcpy+0x1c>
  80074f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800751:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800754:	29 f0                	sub    %esi,%eax
}
  800756:	5b                   	pop    %ebx
  800757:	5e                   	pop    %esi
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800760:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800763:	eb 06                	jmp    80076b <strcmp+0x11>
		p++, q++;
  800765:	83 c1 01             	add    $0x1,%ecx
  800768:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80076b:	0f b6 01             	movzbl (%ecx),%eax
  80076e:	84 c0                	test   %al,%al
  800770:	74 04                	je     800776 <strcmp+0x1c>
  800772:	3a 02                	cmp    (%edx),%al
  800774:	74 ef                	je     800765 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800776:	0f b6 c0             	movzbl %al,%eax
  800779:	0f b6 12             	movzbl (%edx),%edx
  80077c:	29 d0                	sub    %edx,%eax
}
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078a:	89 c3                	mov    %eax,%ebx
  80078c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80078f:	eb 06                	jmp    800797 <strncmp+0x17>
		n--, p++, q++;
  800791:	83 c0 01             	add    $0x1,%eax
  800794:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800797:	39 d8                	cmp    %ebx,%eax
  800799:	74 15                	je     8007b0 <strncmp+0x30>
  80079b:	0f b6 08             	movzbl (%eax),%ecx
  80079e:	84 c9                	test   %cl,%cl
  8007a0:	74 04                	je     8007a6 <strncmp+0x26>
  8007a2:	3a 0a                	cmp    (%edx),%cl
  8007a4:	74 eb                	je     800791 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007a6:	0f b6 00             	movzbl (%eax),%eax
  8007a9:	0f b6 12             	movzbl (%edx),%edx
  8007ac:	29 d0                	sub    %edx,%eax
  8007ae:	eb 05                	jmp    8007b5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007b0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007b5:	5b                   	pop    %ebx
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007be:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007c2:	eb 07                	jmp    8007cb <strchr+0x13>
		if (*s == c)
  8007c4:	38 ca                	cmp    %cl,%dl
  8007c6:	74 0f                	je     8007d7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007c8:	83 c0 01             	add    $0x1,%eax
  8007cb:	0f b6 10             	movzbl (%eax),%edx
  8007ce:	84 d2                	test   %dl,%dl
  8007d0:	75 f2                	jne    8007c4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007df:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e3:	eb 03                	jmp    8007e8 <strfind+0xf>
  8007e5:	83 c0 01             	add    $0x1,%eax
  8007e8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8007eb:	84 d2                	test   %dl,%dl
  8007ed:	74 04                	je     8007f3 <strfind+0x1a>
  8007ef:	38 ca                	cmp    %cl,%dl
  8007f1:	75 f2                	jne    8007e5 <strfind+0xc>
			break;
	return (char *) s;
}
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	57                   	push   %edi
  8007f9:	56                   	push   %esi
  8007fa:	53                   	push   %ebx
  8007fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800801:	85 c9                	test   %ecx,%ecx
  800803:	74 36                	je     80083b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800805:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80080b:	75 28                	jne    800835 <memset+0x40>
  80080d:	f6 c1 03             	test   $0x3,%cl
  800810:	75 23                	jne    800835 <memset+0x40>
		c &= 0xFF;
  800812:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800816:	89 d3                	mov    %edx,%ebx
  800818:	c1 e3 08             	shl    $0x8,%ebx
  80081b:	89 d6                	mov    %edx,%esi
  80081d:	c1 e6 18             	shl    $0x18,%esi
  800820:	89 d0                	mov    %edx,%eax
  800822:	c1 e0 10             	shl    $0x10,%eax
  800825:	09 f0                	or     %esi,%eax
  800827:	09 c2                	or     %eax,%edx
  800829:	89 d0                	mov    %edx,%eax
  80082b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80082d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800830:	fc                   	cld    
  800831:	f3 ab                	rep stos %eax,%es:(%edi)
  800833:	eb 06                	jmp    80083b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800835:	8b 45 0c             	mov    0xc(%ebp),%eax
  800838:	fc                   	cld    
  800839:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80083b:	89 f8                	mov    %edi,%eax
  80083d:	5b                   	pop    %ebx
  80083e:	5e                   	pop    %esi
  80083f:	5f                   	pop    %edi
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	57                   	push   %edi
  800846:	56                   	push   %esi
  800847:	8b 45 08             	mov    0x8(%ebp),%eax
  80084a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80084d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800850:	39 c6                	cmp    %eax,%esi
  800852:	73 35                	jae    800889 <memmove+0x47>
  800854:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800857:	39 d0                	cmp    %edx,%eax
  800859:	73 2e                	jae    800889 <memmove+0x47>
		s += n;
		d += n;
  80085b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80085e:	89 d6                	mov    %edx,%esi
  800860:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800862:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800868:	75 13                	jne    80087d <memmove+0x3b>
  80086a:	f6 c1 03             	test   $0x3,%cl
  80086d:	75 0e                	jne    80087d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80086f:	83 ef 04             	sub    $0x4,%edi
  800872:	8d 72 fc             	lea    -0x4(%edx),%esi
  800875:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800878:	fd                   	std    
  800879:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80087b:	eb 09                	jmp    800886 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80087d:	83 ef 01             	sub    $0x1,%edi
  800880:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800883:	fd                   	std    
  800884:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800886:	fc                   	cld    
  800887:	eb 1d                	jmp    8008a6 <memmove+0x64>
  800889:	89 f2                	mov    %esi,%edx
  80088b:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80088d:	f6 c2 03             	test   $0x3,%dl
  800890:	75 0f                	jne    8008a1 <memmove+0x5f>
  800892:	f6 c1 03             	test   $0x3,%cl
  800895:	75 0a                	jne    8008a1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800897:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80089a:	89 c7                	mov    %eax,%edi
  80089c:	fc                   	cld    
  80089d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80089f:	eb 05                	jmp    8008a6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008a1:	89 c7                	mov    %eax,%edi
  8008a3:	fc                   	cld    
  8008a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008a6:	5e                   	pop    %esi
  8008a7:	5f                   	pop    %edi
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008ad:	ff 75 10             	pushl  0x10(%ebp)
  8008b0:	ff 75 0c             	pushl  0xc(%ebp)
  8008b3:	ff 75 08             	pushl  0x8(%ebp)
  8008b6:	e8 87 ff ff ff       	call   800842 <memmove>
}
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c8:	89 c6                	mov    %eax,%esi
  8008ca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008cd:	eb 1a                	jmp    8008e9 <memcmp+0x2c>
		if (*s1 != *s2)
  8008cf:	0f b6 08             	movzbl (%eax),%ecx
  8008d2:	0f b6 1a             	movzbl (%edx),%ebx
  8008d5:	38 d9                	cmp    %bl,%cl
  8008d7:	74 0a                	je     8008e3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008d9:	0f b6 c1             	movzbl %cl,%eax
  8008dc:	0f b6 db             	movzbl %bl,%ebx
  8008df:	29 d8                	sub    %ebx,%eax
  8008e1:	eb 0f                	jmp    8008f2 <memcmp+0x35>
		s1++, s2++;
  8008e3:	83 c0 01             	add    $0x1,%eax
  8008e6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008e9:	39 f0                	cmp    %esi,%eax
  8008eb:	75 e2                	jne    8008cf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8008ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f2:	5b                   	pop    %ebx
  8008f3:	5e                   	pop    %esi
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8008ff:	89 c2                	mov    %eax,%edx
  800901:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800904:	eb 07                	jmp    80090d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800906:	38 08                	cmp    %cl,(%eax)
  800908:	74 07                	je     800911 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80090a:	83 c0 01             	add    $0x1,%eax
  80090d:	39 d0                	cmp    %edx,%eax
  80090f:	72 f5                	jb     800906 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	57                   	push   %edi
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80091f:	eb 03                	jmp    800924 <strtol+0x11>
		s++;
  800921:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800924:	0f b6 01             	movzbl (%ecx),%eax
  800927:	3c 09                	cmp    $0x9,%al
  800929:	74 f6                	je     800921 <strtol+0xe>
  80092b:	3c 20                	cmp    $0x20,%al
  80092d:	74 f2                	je     800921 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80092f:	3c 2b                	cmp    $0x2b,%al
  800931:	75 0a                	jne    80093d <strtol+0x2a>
		s++;
  800933:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800936:	bf 00 00 00 00       	mov    $0x0,%edi
  80093b:	eb 10                	jmp    80094d <strtol+0x3a>
  80093d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800942:	3c 2d                	cmp    $0x2d,%al
  800944:	75 07                	jne    80094d <strtol+0x3a>
		s++, neg = 1;
  800946:	8d 49 01             	lea    0x1(%ecx),%ecx
  800949:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80094d:	85 db                	test   %ebx,%ebx
  80094f:	0f 94 c0             	sete   %al
  800952:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800958:	75 19                	jne    800973 <strtol+0x60>
  80095a:	80 39 30             	cmpb   $0x30,(%ecx)
  80095d:	75 14                	jne    800973 <strtol+0x60>
  80095f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800963:	0f 85 82 00 00 00    	jne    8009eb <strtol+0xd8>
		s += 2, base = 16;
  800969:	83 c1 02             	add    $0x2,%ecx
  80096c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800971:	eb 16                	jmp    800989 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800973:	84 c0                	test   %al,%al
  800975:	74 12                	je     800989 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800977:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80097c:	80 39 30             	cmpb   $0x30,(%ecx)
  80097f:	75 08                	jne    800989 <strtol+0x76>
		s++, base = 8;
  800981:	83 c1 01             	add    $0x1,%ecx
  800984:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800989:	b8 00 00 00 00       	mov    $0x0,%eax
  80098e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800991:	0f b6 11             	movzbl (%ecx),%edx
  800994:	8d 72 d0             	lea    -0x30(%edx),%esi
  800997:	89 f3                	mov    %esi,%ebx
  800999:	80 fb 09             	cmp    $0x9,%bl
  80099c:	77 08                	ja     8009a6 <strtol+0x93>
			dig = *s - '0';
  80099e:	0f be d2             	movsbl %dl,%edx
  8009a1:	83 ea 30             	sub    $0x30,%edx
  8009a4:	eb 22                	jmp    8009c8 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8009a6:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009a9:	89 f3                	mov    %esi,%ebx
  8009ab:	80 fb 19             	cmp    $0x19,%bl
  8009ae:	77 08                	ja     8009b8 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8009b0:	0f be d2             	movsbl %dl,%edx
  8009b3:	83 ea 57             	sub    $0x57,%edx
  8009b6:	eb 10                	jmp    8009c8 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8009b8:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009bb:	89 f3                	mov    %esi,%ebx
  8009bd:	80 fb 19             	cmp    $0x19,%bl
  8009c0:	77 16                	ja     8009d8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8009c2:	0f be d2             	movsbl %dl,%edx
  8009c5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009c8:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009cb:	7d 0f                	jge    8009dc <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8009cd:	83 c1 01             	add    $0x1,%ecx
  8009d0:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009d4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009d6:	eb b9                	jmp    800991 <strtol+0x7e>
  8009d8:	89 c2                	mov    %eax,%edx
  8009da:	eb 02                	jmp    8009de <strtol+0xcb>
  8009dc:	89 c2                	mov    %eax,%edx

	if (endptr)
  8009de:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009e2:	74 0d                	je     8009f1 <strtol+0xde>
		*endptr = (char *) s;
  8009e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e7:	89 0e                	mov    %ecx,(%esi)
  8009e9:	eb 06                	jmp    8009f1 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009eb:	84 c0                	test   %al,%al
  8009ed:	75 92                	jne    800981 <strtol+0x6e>
  8009ef:	eb 98                	jmp    800989 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8009f1:	f7 da                	neg    %edx
  8009f3:	85 ff                	test   %edi,%edi
  8009f5:	0f 45 c2             	cmovne %edx,%eax
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5e                   	pop    %esi
  8009fa:	5f                   	pop    %edi
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	57                   	push   %edi
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
  800a08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0e:	89 c3                	mov    %eax,%ebx
  800a10:	89 c7                	mov    %eax,%edi
  800a12:	89 c6                	mov    %eax,%esi
  800a14:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a16:	5b                   	pop    %ebx
  800a17:	5e                   	pop    %esi
  800a18:	5f                   	pop    %edi
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	57                   	push   %edi
  800a1f:	56                   	push   %esi
  800a20:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a21:	ba 00 00 00 00       	mov    $0x0,%edx
  800a26:	b8 01 00 00 00       	mov    $0x1,%eax
  800a2b:	89 d1                	mov    %edx,%ecx
  800a2d:	89 d3                	mov    %edx,%ebx
  800a2f:	89 d7                	mov    %edx,%edi
  800a31:	89 d6                	mov    %edx,%esi
  800a33:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5f                   	pop    %edi
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	57                   	push   %edi
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
  800a40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a48:	b8 03 00 00 00       	mov    $0x3,%eax
  800a4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a50:	89 cb                	mov    %ecx,%ebx
  800a52:	89 cf                	mov    %ecx,%edi
  800a54:	89 ce                	mov    %ecx,%esi
  800a56:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a58:	85 c0                	test   %eax,%eax
  800a5a:	7e 17                	jle    800a73 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a5c:	83 ec 0c             	sub    $0xc,%esp
  800a5f:	50                   	push   %eax
  800a60:	6a 03                	push   $0x3
  800a62:	68 e0 0f 80 00       	push   $0x800fe0
  800a67:	6a 23                	push   $0x23
  800a69:	68 fd 0f 80 00       	push   $0x800ffd
  800a6e:	e8 27 00 00 00       	call   800a9a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5f                   	pop    %edi
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	57                   	push   %edi
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a81:	ba 00 00 00 00       	mov    $0x0,%edx
  800a86:	b8 02 00 00 00       	mov    $0x2,%eax
  800a8b:	89 d1                	mov    %edx,%ecx
  800a8d:	89 d3                	mov    %edx,%ebx
  800a8f:	89 d7                	mov    %edx,%edi
  800a91:	89 d6                	mov    %edx,%esi
  800a93:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a9f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800aa2:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800aa8:	e8 ce ff ff ff       	call   800a7b <sys_getenvid>
  800aad:	83 ec 0c             	sub    $0xc,%esp
  800ab0:	ff 75 0c             	pushl  0xc(%ebp)
  800ab3:	ff 75 08             	pushl  0x8(%ebp)
  800ab6:	56                   	push   %esi
  800ab7:	50                   	push   %eax
  800ab8:	68 0c 10 80 00       	push   $0x80100c
  800abd:	e8 67 f6 ff ff       	call   800129 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ac2:	83 c4 18             	add    $0x18,%esp
  800ac5:	53                   	push   %ebx
  800ac6:	ff 75 10             	pushl  0x10(%ebp)
  800ac9:	e8 0a f6 ff ff       	call   8000d8 <vcprintf>
	cprintf("\n");
  800ace:	c7 04 24 30 10 80 00 	movl   $0x801030,(%esp)
  800ad5:	e8 4f f6 ff ff       	call   800129 <cprintf>
  800ada:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800add:	cc                   	int3   
  800ade:	eb fd                	jmp    800add <_panic+0x43>

00800ae0 <__udivdi3>:
  800ae0:	55                   	push   %ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	83 ec 10             	sub    $0x10,%esp
  800ae6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800aea:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800aee:	8b 74 24 24          	mov    0x24(%esp),%esi
  800af2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800af6:	85 d2                	test   %edx,%edx
  800af8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800afc:	89 34 24             	mov    %esi,(%esp)
  800aff:	89 c8                	mov    %ecx,%eax
  800b01:	75 35                	jne    800b38 <__udivdi3+0x58>
  800b03:	39 f1                	cmp    %esi,%ecx
  800b05:	0f 87 bd 00 00 00    	ja     800bc8 <__udivdi3+0xe8>
  800b0b:	85 c9                	test   %ecx,%ecx
  800b0d:	89 cd                	mov    %ecx,%ebp
  800b0f:	75 0b                	jne    800b1c <__udivdi3+0x3c>
  800b11:	b8 01 00 00 00       	mov    $0x1,%eax
  800b16:	31 d2                	xor    %edx,%edx
  800b18:	f7 f1                	div    %ecx
  800b1a:	89 c5                	mov    %eax,%ebp
  800b1c:	89 f0                	mov    %esi,%eax
  800b1e:	31 d2                	xor    %edx,%edx
  800b20:	f7 f5                	div    %ebp
  800b22:	89 c6                	mov    %eax,%esi
  800b24:	89 f8                	mov    %edi,%eax
  800b26:	f7 f5                	div    %ebp
  800b28:	89 f2                	mov    %esi,%edx
  800b2a:	83 c4 10             	add    $0x10,%esp
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    
  800b31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800b38:	3b 14 24             	cmp    (%esp),%edx
  800b3b:	77 7b                	ja     800bb8 <__udivdi3+0xd8>
  800b3d:	0f bd f2             	bsr    %edx,%esi
  800b40:	83 f6 1f             	xor    $0x1f,%esi
  800b43:	0f 84 97 00 00 00    	je     800be0 <__udivdi3+0x100>
  800b49:	bd 20 00 00 00       	mov    $0x20,%ebp
  800b4e:	89 d7                	mov    %edx,%edi
  800b50:	89 f1                	mov    %esi,%ecx
  800b52:	29 f5                	sub    %esi,%ebp
  800b54:	d3 e7                	shl    %cl,%edi
  800b56:	89 c2                	mov    %eax,%edx
  800b58:	89 e9                	mov    %ebp,%ecx
  800b5a:	d3 ea                	shr    %cl,%edx
  800b5c:	89 f1                	mov    %esi,%ecx
  800b5e:	09 fa                	or     %edi,%edx
  800b60:	8b 3c 24             	mov    (%esp),%edi
  800b63:	d3 e0                	shl    %cl,%eax
  800b65:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b69:	89 e9                	mov    %ebp,%ecx
  800b6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b6f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800b73:	89 fa                	mov    %edi,%edx
  800b75:	d3 ea                	shr    %cl,%edx
  800b77:	89 f1                	mov    %esi,%ecx
  800b79:	d3 e7                	shl    %cl,%edi
  800b7b:	89 e9                	mov    %ebp,%ecx
  800b7d:	d3 e8                	shr    %cl,%eax
  800b7f:	09 c7                	or     %eax,%edi
  800b81:	89 f8                	mov    %edi,%eax
  800b83:	f7 74 24 08          	divl   0x8(%esp)
  800b87:	89 d5                	mov    %edx,%ebp
  800b89:	89 c7                	mov    %eax,%edi
  800b8b:	f7 64 24 0c          	mull   0xc(%esp)
  800b8f:	39 d5                	cmp    %edx,%ebp
  800b91:	89 14 24             	mov    %edx,(%esp)
  800b94:	72 11                	jb     800ba7 <__udivdi3+0xc7>
  800b96:	8b 54 24 04          	mov    0x4(%esp),%edx
  800b9a:	89 f1                	mov    %esi,%ecx
  800b9c:	d3 e2                	shl    %cl,%edx
  800b9e:	39 c2                	cmp    %eax,%edx
  800ba0:	73 5e                	jae    800c00 <__udivdi3+0x120>
  800ba2:	3b 2c 24             	cmp    (%esp),%ebp
  800ba5:	75 59                	jne    800c00 <__udivdi3+0x120>
  800ba7:	8d 47 ff             	lea    -0x1(%edi),%eax
  800baa:	31 f6                	xor    %esi,%esi
  800bac:	89 f2                	mov    %esi,%edx
  800bae:	83 c4 10             	add    $0x10,%esp
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    
  800bb5:	8d 76 00             	lea    0x0(%esi),%esi
  800bb8:	31 f6                	xor    %esi,%esi
  800bba:	31 c0                	xor    %eax,%eax
  800bbc:	89 f2                	mov    %esi,%edx
  800bbe:	83 c4 10             	add    $0x10,%esp
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    
  800bc5:	8d 76 00             	lea    0x0(%esi),%esi
  800bc8:	89 f2                	mov    %esi,%edx
  800bca:	31 f6                	xor    %esi,%esi
  800bcc:	89 f8                	mov    %edi,%eax
  800bce:	f7 f1                	div    %ecx
  800bd0:	89 f2                	mov    %esi,%edx
  800bd2:	83 c4 10             	add    $0x10,%esp
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    
  800bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800be0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800be4:	76 0b                	jbe    800bf1 <__udivdi3+0x111>
  800be6:	31 c0                	xor    %eax,%eax
  800be8:	3b 14 24             	cmp    (%esp),%edx
  800beb:	0f 83 37 ff ff ff    	jae    800b28 <__udivdi3+0x48>
  800bf1:	b8 01 00 00 00       	mov    $0x1,%eax
  800bf6:	e9 2d ff ff ff       	jmp    800b28 <__udivdi3+0x48>
  800bfb:	90                   	nop
  800bfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c00:	89 f8                	mov    %edi,%eax
  800c02:	31 f6                	xor    %esi,%esi
  800c04:	e9 1f ff ff ff       	jmp    800b28 <__udivdi3+0x48>
  800c09:	66 90                	xchg   %ax,%ax
  800c0b:	66 90                	xchg   %ax,%ax
  800c0d:	66 90                	xchg   %ax,%ax
  800c0f:	90                   	nop

00800c10 <__umoddi3>:
  800c10:	55                   	push   %ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	83 ec 20             	sub    $0x20,%esp
  800c16:	8b 44 24 34          	mov    0x34(%esp),%eax
  800c1a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c1e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c22:	89 c6                	mov    %eax,%esi
  800c24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c28:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c2c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800c30:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c34:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800c38:	89 74 24 18          	mov    %esi,0x18(%esp)
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	89 c2                	mov    %eax,%edx
  800c40:	75 1e                	jne    800c60 <__umoddi3+0x50>
  800c42:	39 f7                	cmp    %esi,%edi
  800c44:	76 52                	jbe    800c98 <__umoddi3+0x88>
  800c46:	89 c8                	mov    %ecx,%eax
  800c48:	89 f2                	mov    %esi,%edx
  800c4a:	f7 f7                	div    %edi
  800c4c:	89 d0                	mov    %edx,%eax
  800c4e:	31 d2                	xor    %edx,%edx
  800c50:	83 c4 20             	add    $0x20,%esp
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    
  800c57:	89 f6                	mov    %esi,%esi
  800c59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800c60:	39 f0                	cmp    %esi,%eax
  800c62:	77 5c                	ja     800cc0 <__umoddi3+0xb0>
  800c64:	0f bd e8             	bsr    %eax,%ebp
  800c67:	83 f5 1f             	xor    $0x1f,%ebp
  800c6a:	75 64                	jne    800cd0 <__umoddi3+0xc0>
  800c6c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800c70:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800c74:	0f 86 f6 00 00 00    	jbe    800d70 <__umoddi3+0x160>
  800c7a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800c7e:	0f 82 ec 00 00 00    	jb     800d70 <__umoddi3+0x160>
  800c84:	8b 44 24 14          	mov    0x14(%esp),%eax
  800c88:	8b 54 24 18          	mov    0x18(%esp),%edx
  800c8c:	83 c4 20             	add    $0x20,%esp
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    
  800c93:	90                   	nop
  800c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c98:	85 ff                	test   %edi,%edi
  800c9a:	89 fd                	mov    %edi,%ebp
  800c9c:	75 0b                	jne    800ca9 <__umoddi3+0x99>
  800c9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca3:	31 d2                	xor    %edx,%edx
  800ca5:	f7 f7                	div    %edi
  800ca7:	89 c5                	mov    %eax,%ebp
  800ca9:	8b 44 24 10          	mov    0x10(%esp),%eax
  800cad:	31 d2                	xor    %edx,%edx
  800caf:	f7 f5                	div    %ebp
  800cb1:	89 c8                	mov    %ecx,%eax
  800cb3:	f7 f5                	div    %ebp
  800cb5:	eb 95                	jmp    800c4c <__umoddi3+0x3c>
  800cb7:	89 f6                	mov    %esi,%esi
  800cb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800cc0:	89 c8                	mov    %ecx,%eax
  800cc2:	89 f2                	mov    %esi,%edx
  800cc4:	83 c4 20             	add    $0x20,%esp
  800cc7:	5e                   	pop    %esi
  800cc8:	5f                   	pop    %edi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    
  800ccb:	90                   	nop
  800ccc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cd0:	b8 20 00 00 00       	mov    $0x20,%eax
  800cd5:	89 e9                	mov    %ebp,%ecx
  800cd7:	29 e8                	sub    %ebp,%eax
  800cd9:	d3 e2                	shl    %cl,%edx
  800cdb:	89 c7                	mov    %eax,%edi
  800cdd:	89 44 24 18          	mov    %eax,0x18(%esp)
  800ce1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ce5:	89 f9                	mov    %edi,%ecx
  800ce7:	d3 e8                	shr    %cl,%eax
  800ce9:	89 c1                	mov    %eax,%ecx
  800ceb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cef:	09 d1                	or     %edx,%ecx
  800cf1:	89 fa                	mov    %edi,%edx
  800cf3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800cf7:	89 e9                	mov    %ebp,%ecx
  800cf9:	d3 e0                	shl    %cl,%eax
  800cfb:	89 f9                	mov    %edi,%ecx
  800cfd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d01:	89 f0                	mov    %esi,%eax
  800d03:	d3 e8                	shr    %cl,%eax
  800d05:	89 e9                	mov    %ebp,%ecx
  800d07:	89 c7                	mov    %eax,%edi
  800d09:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800d0d:	d3 e6                	shl    %cl,%esi
  800d0f:	89 d1                	mov    %edx,%ecx
  800d11:	89 fa                	mov    %edi,%edx
  800d13:	d3 e8                	shr    %cl,%eax
  800d15:	89 e9                	mov    %ebp,%ecx
  800d17:	09 f0                	or     %esi,%eax
  800d19:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800d1d:	f7 74 24 10          	divl   0x10(%esp)
  800d21:	d3 e6                	shl    %cl,%esi
  800d23:	89 d1                	mov    %edx,%ecx
  800d25:	f7 64 24 0c          	mull   0xc(%esp)
  800d29:	39 d1                	cmp    %edx,%ecx
  800d2b:	89 74 24 14          	mov    %esi,0x14(%esp)
  800d2f:	89 d7                	mov    %edx,%edi
  800d31:	89 c6                	mov    %eax,%esi
  800d33:	72 0a                	jb     800d3f <__umoddi3+0x12f>
  800d35:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800d39:	73 10                	jae    800d4b <__umoddi3+0x13b>
  800d3b:	39 d1                	cmp    %edx,%ecx
  800d3d:	75 0c                	jne    800d4b <__umoddi3+0x13b>
  800d3f:	89 d7                	mov    %edx,%edi
  800d41:	89 c6                	mov    %eax,%esi
  800d43:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800d47:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800d4b:	89 ca                	mov    %ecx,%edx
  800d4d:	89 e9                	mov    %ebp,%ecx
  800d4f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800d53:	29 f0                	sub    %esi,%eax
  800d55:	19 fa                	sbb    %edi,%edx
  800d57:	d3 e8                	shr    %cl,%eax
  800d59:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800d5e:	89 d7                	mov    %edx,%edi
  800d60:	d3 e7                	shl    %cl,%edi
  800d62:	89 e9                	mov    %ebp,%ecx
  800d64:	09 f8                	or     %edi,%eax
  800d66:	d3 ea                	shr    %cl,%edx
  800d68:	83 c4 20             	add    $0x20,%esp
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    
  800d6f:	90                   	nop
  800d70:	8b 74 24 10          	mov    0x10(%esp),%esi
  800d74:	29 f9                	sub    %edi,%ecx
  800d76:	19 c6                	sbb    %eax,%esi
  800d78:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800d7c:	89 74 24 18          	mov    %esi,0x18(%esp)
  800d80:	e9 ff fe ff ff       	jmp    800c84 <__umoddi3+0x74>
