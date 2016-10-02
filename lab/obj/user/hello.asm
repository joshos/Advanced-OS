
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 a0 0d 80 00       	push   $0x800da0
  80003e:	e8 f6 00 00 00       	call   800139 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 ae 0d 80 00       	push   $0x800dae
  800054:	e8 e0 00 00 00       	call   800139 <cprintf>
  800059:	83 c4 10             	add    $0x10,%esp
}
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	83 ec 08             	sub    $0x8,%esp
  800064:	8b 45 08             	mov    0x8(%ebp),%eax
  800067:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800071:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800074:	85 c0                	test   %eax,%eax
  800076:	7e 08                	jle    800080 <libmain+0x22>
		binaryname = argv[0];
  800078:	8b 0a                	mov    (%edx),%ecx
  80007a:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800080:	83 ec 08             	sub    $0x8,%esp
  800083:	52                   	push   %edx
  800084:	50                   	push   %eax
  800085:	e8 a9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008a:	e8 05 00 00 00       	call   800094 <exit>
  80008f:	83 c4 10             	add    $0x10,%esp
}
  800092:	c9                   	leave  
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 a9 09 00 00       	call   800a4a <sys_env_destroy>
  8000a1:	83 c4 10             	add    $0x10,%esp
}
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	53                   	push   %ebx
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b0:	8b 13                	mov    (%ebx),%edx
  8000b2:	8d 42 01             	lea    0x1(%edx),%eax
  8000b5:	89 03                	mov    %eax,(%ebx)
  8000b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c3:	75 1a                	jne    8000df <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000c5:	83 ec 08             	sub    $0x8,%esp
  8000c8:	68 ff 00 00 00       	push   $0xff
  8000cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d0:	50                   	push   %eax
  8000d1:	e8 37 09 00 00       	call   800a0d <sys_cputs>
		b->idx = 0;
  8000d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    

008000e8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000f8:	00 00 00 
	b.cnt = 0;
  8000fb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800102:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800105:	ff 75 0c             	pushl  0xc(%ebp)
  800108:	ff 75 08             	pushl  0x8(%ebp)
  80010b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800111:	50                   	push   %eax
  800112:	68 a6 00 80 00       	push   $0x8000a6
  800117:	e8 4f 01 00 00       	call   80026b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011c:	83 c4 08             	add    $0x8,%esp
  80011f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800125:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 dc 08 00 00       	call   800a0d <sys_cputs>

	return b.cnt;
}
  800131:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80013f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800142:	50                   	push   %eax
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	e8 9d ff ff ff       	call   8000e8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
  800153:	83 ec 1c             	sub    $0x1c,%esp
  800156:	89 c7                	mov    %eax,%edi
  800158:	89 d6                	mov    %edx,%esi
  80015a:	8b 45 08             	mov    0x8(%ebp),%eax
  80015d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800160:	89 d1                	mov    %edx,%ecx
  800162:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800165:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800168:	8b 45 10             	mov    0x10(%ebp),%eax
  80016b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80016e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800171:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800178:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80017b:	72 05                	jb     800182 <printnum+0x35>
  80017d:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800180:	77 3e                	ja     8001c0 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	ff 75 18             	pushl  0x18(%ebp)
  800188:	83 eb 01             	sub    $0x1,%ebx
  80018b:	53                   	push   %ebx
  80018c:	50                   	push   %eax
  80018d:	83 ec 08             	sub    $0x8,%esp
  800190:	ff 75 e4             	pushl  -0x1c(%ebp)
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	ff 75 dc             	pushl  -0x24(%ebp)
  800199:	ff 75 d8             	pushl  -0x28(%ebp)
  80019c:	e8 4f 09 00 00       	call   800af0 <__udivdi3>
  8001a1:	83 c4 18             	add    $0x18,%esp
  8001a4:	52                   	push   %edx
  8001a5:	50                   	push   %eax
  8001a6:	89 f2                	mov    %esi,%edx
  8001a8:	89 f8                	mov    %edi,%eax
  8001aa:	e8 9e ff ff ff       	call   80014d <printnum>
  8001af:	83 c4 20             	add    $0x20,%esp
  8001b2:	eb 13                	jmp    8001c7 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	56                   	push   %esi
  8001b8:	ff 75 18             	pushl  0x18(%ebp)
  8001bb:	ff d7                	call   *%edi
  8001bd:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c0:	83 eb 01             	sub    $0x1,%ebx
  8001c3:	85 db                	test   %ebx,%ebx
  8001c5:	7f ed                	jg     8001b4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	56                   	push   %esi
  8001cb:	83 ec 04             	sub    $0x4,%esp
  8001ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d4:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8001da:	e8 41 0a 00 00       	call   800c20 <__umoddi3>
  8001df:	83 c4 14             	add    $0x14,%esp
  8001e2:	0f be 80 cf 0d 80 00 	movsbl 0x800dcf(%eax),%eax
  8001e9:	50                   	push   %eax
  8001ea:	ff d7                	call   *%edi
  8001ec:	83 c4 10             	add    $0x10,%esp
}
  8001ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f2:	5b                   	pop    %ebx
  8001f3:	5e                   	pop    %esi
  8001f4:	5f                   	pop    %edi
  8001f5:	5d                   	pop    %ebp
  8001f6:	c3                   	ret    

008001f7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8001fa:	83 fa 01             	cmp    $0x1,%edx
  8001fd:	7e 0e                	jle    80020d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8001ff:	8b 10                	mov    (%eax),%edx
  800201:	8d 4a 08             	lea    0x8(%edx),%ecx
  800204:	89 08                	mov    %ecx,(%eax)
  800206:	8b 02                	mov    (%edx),%eax
  800208:	8b 52 04             	mov    0x4(%edx),%edx
  80020b:	eb 22                	jmp    80022f <getuint+0x38>
	else if (lflag)
  80020d:	85 d2                	test   %edx,%edx
  80020f:	74 10                	je     800221 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800211:	8b 10                	mov    (%eax),%edx
  800213:	8d 4a 04             	lea    0x4(%edx),%ecx
  800216:	89 08                	mov    %ecx,(%eax)
  800218:	8b 02                	mov    (%edx),%eax
  80021a:	ba 00 00 00 00       	mov    $0x0,%edx
  80021f:	eb 0e                	jmp    80022f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800221:	8b 10                	mov    (%eax),%edx
  800223:	8d 4a 04             	lea    0x4(%edx),%ecx
  800226:	89 08                	mov    %ecx,(%eax)
  800228:	8b 02                	mov    (%edx),%eax
  80022a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800237:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80023b:	8b 10                	mov    (%eax),%edx
  80023d:	3b 50 04             	cmp    0x4(%eax),%edx
  800240:	73 0a                	jae    80024c <sprintputch+0x1b>
		*b->buf++ = ch;
  800242:	8d 4a 01             	lea    0x1(%edx),%ecx
  800245:	89 08                	mov    %ecx,(%eax)
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	88 02                	mov    %al,(%edx)
}
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800254:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800257:	50                   	push   %eax
  800258:	ff 75 10             	pushl  0x10(%ebp)
  80025b:	ff 75 0c             	pushl  0xc(%ebp)
  80025e:	ff 75 08             	pushl  0x8(%ebp)
  800261:	e8 05 00 00 00       	call   80026b <vprintfmt>
	va_end(ap);
  800266:	83 c4 10             	add    $0x10,%esp
}
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 2c             	sub    $0x2c,%esp
  800274:	8b 75 08             	mov    0x8(%ebp),%esi
  800277:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80027a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80027d:	eb 12                	jmp    800291 <vprintfmt+0x26>

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
		{
			if (ch == '\0')
  80027f:	85 c0                	test   %eax,%eax
  800281:	0f 84 90 03 00 00    	je     800617 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800287:	83 ec 08             	sub    $0x8,%esp
  80028a:	53                   	push   %ebx
  80028b:	50                   	push   %eax
  80028c:	ff d6                	call   *%esi
  80028e:	83 c4 10             	add    $0x10,%esp
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
  800291:	83 c7 01             	add    $0x1,%edi
  800294:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800298:	83 f8 25             	cmp    $0x25,%eax
  80029b:	75 e2                	jne    80027f <vprintfmt+0x14>
  80029d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002a1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002a8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002af:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002bb:	eb 07                	jmp    8002c4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8002bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		{

			// flag to pad on the right
			case '-':
				padc = '-';
  8002c0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8002c4:	8d 47 01             	lea    0x1(%edi),%eax
  8002c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ca:	0f b6 07             	movzbl (%edi),%eax
  8002cd:	0f b6 c8             	movzbl %al,%ecx
  8002d0:	83 e8 23             	sub    $0x23,%eax
  8002d3:	3c 55                	cmp    $0x55,%al
  8002d5:	0f 87 21 03 00 00    	ja     8005fc <vprintfmt+0x391>
  8002db:	0f b6 c0             	movzbl %al,%eax
  8002de:	ff 24 85 60 0e 80 00 	jmp    *0x800e60(,%eax,4)
  8002e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				padc = '-';
				goto reswitch;

			// flag to pad with 0's instead of spaces
			case '0':
				padc = '0';
  8002e8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002ec:	eb d6                	jmp    8002c4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8002ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8002f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
					precision = precision * 10 + ch - '0';
  8002f9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002fc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
					ch = *fmt;
  800300:	0f be 0f             	movsbl (%edi),%ecx
					if (ch < '0' || ch > '9')
  800303:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800306:	83 fa 09             	cmp    $0x9,%edx
  800309:	77 39                	ja     800344 <vprintfmt+0xd9>
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
  80030b:	83 c7 01             	add    $0x1,%edi
					precision = precision * 10 + ch - '0';
					ch = *fmt;
					if (ch < '0' || ch > '9')
						break;
				}
  80030e:	eb e9                	jmp    8002f9 <vprintfmt+0x8e>
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
  800310:	8b 45 14             	mov    0x14(%ebp),%eax
  800313:	8d 48 04             	lea    0x4(%eax),%ecx
  800316:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800319:	8b 00                	mov    (%eax),%eax
  80031b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  80031e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				}
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
				goto process_precision;
  800321:	eb 27                	jmp    80034a <vprintfmt+0xdf>
  800323:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800326:	85 c0                	test   %eax,%eax
  800328:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032d:	0f 49 c8             	cmovns %eax,%ecx
  800330:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800333:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800336:	eb 8c                	jmp    8002c4 <vprintfmt+0x59>
  800338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				if (width < 0)
					width = 0;
				goto reswitch;

			case '#':
				altflag = 1;
  80033b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				goto reswitch;
  800342:	eb 80                	jmp    8002c4 <vprintfmt+0x59>
  800344:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800347:	89 45 d0             	mov    %eax,-0x30(%ebp)

			process_precision:
				if (width < 0)
  80034a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80034e:	0f 89 70 ff ff ff    	jns    8002c4 <vprintfmt+0x59>
					width = precision, precision = -1;
  800354:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800357:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800361:	e9 5e ff ff ff       	jmp    8002c4 <vprintfmt+0x59>
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
  800366:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
				goto reswitch;
  80036c:	e9 53 ff ff ff       	jmp    8002c4 <vprintfmt+0x59>

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
  800371:	8b 45 14             	mov    0x14(%ebp),%eax
  800374:	8d 50 04             	lea    0x4(%eax),%edx
  800377:	89 55 14             	mov    %edx,0x14(%ebp)
  80037a:	83 ec 08             	sub    $0x8,%esp
  80037d:	53                   	push   %ebx
  80037e:	ff 30                	pushl  (%eax)
  800380:	ff d6                	call   *%esi
				break;
  800382:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
				break;
  800388:	e9 04 ff ff ff       	jmp    800291 <vprintfmt+0x26>

			// error message
			case 'e':
				err = va_arg(ap, int);
  80038d:	8b 45 14             	mov    0x14(%ebp),%eax
  800390:	8d 50 04             	lea    0x4(%eax),%edx
  800393:	89 55 14             	mov    %edx,0x14(%ebp)
  800396:	8b 00                	mov    (%eax),%eax
  800398:	99                   	cltd   
  800399:	31 d0                	xor    %edx,%eax
  80039b:	29 d0                	sub    %edx,%eax
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80039d:	83 f8 07             	cmp    $0x7,%eax
  8003a0:	7f 0b                	jg     8003ad <vprintfmt+0x142>
  8003a2:	8b 14 85 c0 0f 80 00 	mov    0x800fc0(,%eax,4),%edx
  8003a9:	85 d2                	test   %edx,%edx
  8003ab:	75 18                	jne    8003c5 <vprintfmt+0x15a>
					printfmt(putch, putdat, "error %d", err);
  8003ad:	50                   	push   %eax
  8003ae:	68 e7 0d 80 00       	push   $0x800de7
  8003b3:	53                   	push   %ebx
  8003b4:	56                   	push   %esi
  8003b5:	e8 94 fe ff ff       	call   80024e <printfmt>
  8003ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			case 'e':
				err = va_arg(ap, int);
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
					printfmt(putch, putdat, "error %d", err);
  8003c0:	e9 cc fe ff ff       	jmp    800291 <vprintfmt+0x26>
				else
					printfmt(putch, putdat, "%s", p);
  8003c5:	52                   	push   %edx
  8003c6:	68 f0 0d 80 00       	push   $0x800df0
  8003cb:	53                   	push   %ebx
  8003cc:	56                   	push   %esi
  8003cd:	e8 7c fe ff ff       	call   80024e <printfmt>
  8003d2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d8:	e9 b4 fe ff ff       	jmp    800291 <vprintfmt+0x26>
  8003dd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e3:	89 45 cc             	mov    %eax,-0x34(%ebp)
					printfmt(putch, putdat, "%s", p);
				break;

			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 50 04             	lea    0x4(%eax),%edx
  8003ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ef:	8b 38                	mov    (%eax),%edi
					p = "(null)";
  8003f1:	85 ff                	test   %edi,%edi
  8003f3:	ba e0 0d 80 00       	mov    $0x800de0,%edx
  8003f8:	0f 44 fa             	cmove  %edx,%edi
				if (width > 0 && padc != '-')
  8003fb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003ff:	0f 84 92 00 00 00    	je     800497 <vprintfmt+0x22c>
  800405:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800409:	0f 8e 96 00 00 00    	jle    8004a5 <vprintfmt+0x23a>
					for (width -= strnlen(p, precision); width > 0; width--)
  80040f:	83 ec 08             	sub    $0x8,%esp
  800412:	51                   	push   %ecx
  800413:	57                   	push   %edi
  800414:	e8 86 02 00 00       	call   80069f <strnlen>
  800419:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80041c:	29 c1                	sub    %eax,%ecx
  80041e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800421:	83 c4 10             	add    $0x10,%esp
						putch(padc, putdat);
  800424:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800428:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80042e:	89 cf                	mov    %ecx,%edi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  800430:	eb 0f                	jmp    800441 <vprintfmt+0x1d6>
						putch(padc, putdat);
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	53                   	push   %ebx
  800436:	ff 75 e0             	pushl  -0x20(%ebp)
  800439:	ff d6                	call   *%esi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  80043b:	83 ef 01             	sub    $0x1,%edi
  80043e:	83 c4 10             	add    $0x10,%esp
  800441:	85 ff                	test   %edi,%edi
  800443:	7f ed                	jg     800432 <vprintfmt+0x1c7>
  800445:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800448:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80044b:	85 c9                	test   %ecx,%ecx
  80044d:	b8 00 00 00 00       	mov    $0x0,%eax
  800452:	0f 49 c1             	cmovns %ecx,%eax
  800455:	29 c1                	sub    %eax,%ecx
  800457:	89 75 08             	mov    %esi,0x8(%ebp)
  80045a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80045d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800460:	89 cb                	mov    %ecx,%ebx
  800462:	eb 4d                	jmp    8004b1 <vprintfmt+0x246>
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
  800464:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800468:	74 1b                	je     800485 <vprintfmt+0x21a>
  80046a:	0f be c0             	movsbl %al,%eax
  80046d:	83 e8 20             	sub    $0x20,%eax
  800470:	83 f8 5e             	cmp    $0x5e,%eax
  800473:	76 10                	jbe    800485 <vprintfmt+0x21a>
						putch('?', putdat);
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	ff 75 0c             	pushl  0xc(%ebp)
  80047b:	6a 3f                	push   $0x3f
  80047d:	ff 55 08             	call   *0x8(%ebp)
  800480:	83 c4 10             	add    $0x10,%esp
  800483:	eb 0d                	jmp    800492 <vprintfmt+0x227>
					else
						putch(ch, putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	ff 75 0c             	pushl  0xc(%ebp)
  80048b:	52                   	push   %edx
  80048c:	ff 55 08             	call   *0x8(%ebp)
  80048f:	83 c4 10             	add    $0x10,%esp
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800492:	83 eb 01             	sub    $0x1,%ebx
  800495:	eb 1a                	jmp    8004b1 <vprintfmt+0x246>
  800497:	89 75 08             	mov    %esi,0x8(%ebp)
  80049a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80049d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a3:	eb 0c                	jmp    8004b1 <vprintfmt+0x246>
  8004a5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ab:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ae:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b1:	83 c7 01             	add    $0x1,%edi
  8004b4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b8:	0f be d0             	movsbl %al,%edx
  8004bb:	85 d2                	test   %edx,%edx
  8004bd:	74 23                	je     8004e2 <vprintfmt+0x277>
  8004bf:	85 f6                	test   %esi,%esi
  8004c1:	78 a1                	js     800464 <vprintfmt+0x1f9>
  8004c3:	83 ee 01             	sub    $0x1,%esi
  8004c6:	79 9c                	jns    800464 <vprintfmt+0x1f9>
  8004c8:	89 df                	mov    %ebx,%edi
  8004ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d0:	eb 18                	jmp    8004ea <vprintfmt+0x27f>
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
					putch(' ', putdat);
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	53                   	push   %ebx
  8004d6:	6a 20                	push   $0x20
  8004d8:	ff d6                	call   *%esi
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
  8004da:	83 ef 01             	sub    $0x1,%edi
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	eb 08                	jmp    8004ea <vprintfmt+0x27f>
  8004e2:	89 df                	mov    %ebx,%edi
  8004e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ea:	85 ff                	test   %edi,%edi
  8004ec:	7f e4                	jg     8004d2 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8004ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f1:	e9 9b fd ff ff       	jmp    800291 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004f6:	83 fa 01             	cmp    $0x1,%edx
  8004f9:	7e 16                	jle    800511 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8004fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fe:	8d 50 08             	lea    0x8(%eax),%edx
  800501:	89 55 14             	mov    %edx,0x14(%ebp)
  800504:	8b 50 04             	mov    0x4(%eax),%edx
  800507:	8b 00                	mov    (%eax),%eax
  800509:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80050f:	eb 32                	jmp    800543 <vprintfmt+0x2d8>
	else if (lflag)
  800511:	85 d2                	test   %edx,%edx
  800513:	74 18                	je     80052d <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 50 04             	lea    0x4(%eax),%edx
  80051b:	89 55 14             	mov    %edx,0x14(%ebp)
  80051e:	8b 00                	mov    (%eax),%eax
  800520:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800523:	89 c1                	mov    %eax,%ecx
  800525:	c1 f9 1f             	sar    $0x1f,%ecx
  800528:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80052b:	eb 16                	jmp    800543 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 50 04             	lea    0x4(%eax),%edx
  800533:	89 55 14             	mov    %edx,0x14(%ebp)
  800536:	8b 00                	mov    (%eax),%eax
  800538:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053b:	89 c1                	mov    %eax,%ecx
  80053d:	c1 f9 1f             	sar    $0x1f,%ecx
  800540:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(' ', putdat);
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
  800543:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800546:	8b 55 dc             	mov    -0x24(%ebp),%edx
				if ((long long) num < 0) {
					putch('-', putdat);
					num = -(long long) num;
				}
				base = 10;
  800549:	b9 0a 00 00 00       	mov    $0xa,%ecx
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
				if ((long long) num < 0) {
  80054e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800552:	79 74                	jns    8005c8 <vprintfmt+0x35d>
					putch('-', putdat);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	53                   	push   %ebx
  800558:	6a 2d                	push   $0x2d
  80055a:	ff d6                	call   *%esi
					num = -(long long) num;
  80055c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80055f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800562:	f7 d8                	neg    %eax
  800564:	83 d2 00             	adc    $0x0,%edx
  800567:	f7 da                	neg    %edx
  800569:	83 c4 10             	add    $0x10,%esp
				}
				base = 10;
  80056c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800571:	eb 55                	jmp    8005c8 <vprintfmt+0x35d>
				goto number;

			// unsigned decimal
			case 'u':
				num = getuint(&ap, lflag);
  800573:	8d 45 14             	lea    0x14(%ebp),%eax
  800576:	e8 7c fc ff ff       	call   8001f7 <getuint>
				base = 10;
  80057b:	b9 0a 00 00 00       	mov    $0xa,%ecx
				goto number;
  800580:	eb 46                	jmp    8005c8 <vprintfmt+0x35d>
				// Replace this with your code.
				/*putch('X', putdat);
				putch('X', putdat);
				putch('X', putdat);*/
				
				num = getuint(&ap, lflag);
  800582:	8d 45 14             	lea    0x14(%ebp),%eax
  800585:	e8 6d fc ff ff       	call   8001f7 <getuint>
				base = 8;
  80058a:	b9 08 00 00 00       	mov    $0x8,%ecx
				goto number;
  80058f:	eb 37                	jmp    8005c8 <vprintfmt+0x35d>

			// pointer
			case 'p':
				putch('0', putdat);
  800591:	83 ec 08             	sub    $0x8,%esp
  800594:	53                   	push   %ebx
  800595:	6a 30                	push   $0x30
  800597:	ff d6                	call   *%esi
				putch('x', putdat);
  800599:	83 c4 08             	add    $0x8,%esp
  80059c:	53                   	push   %ebx
  80059d:	6a 78                	push   $0x78
  80059f:	ff d6                	call   *%esi
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8d 50 04             	lea    0x4(%eax),%edx
  8005a7:	89 55 14             	mov    %edx,0x14(%ebp)

			// pointer
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
  8005aa:	8b 00                	mov    (%eax),%eax
  8005ac:	ba 00 00 00 00       	mov    $0x0,%edx
					(uintptr_t) va_arg(ap, void *);
				base = 16;
				goto number;
  8005b1:	83 c4 10             	add    $0x10,%esp
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
				base = 16;
  8005b4:	b9 10 00 00 00       	mov    $0x10,%ecx
				goto number;
  8005b9:	eb 0d                	jmp    8005c8 <vprintfmt+0x35d>

			// (unsigned) hexadecimal
			case 'x':
				num = getuint(&ap, lflag);
  8005bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005be:	e8 34 fc ff ff       	call   8001f7 <getuint>
				base = 16;
  8005c3:	b9 10 00 00 00       	mov    $0x10,%ecx
			number:
				printnum(putch, putdat, num, base, width, padc);
  8005c8:	83 ec 0c             	sub    $0xc,%esp
  8005cb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005cf:	57                   	push   %edi
  8005d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8005d3:	51                   	push   %ecx
  8005d4:	52                   	push   %edx
  8005d5:	50                   	push   %eax
  8005d6:	89 da                	mov    %ebx,%edx
  8005d8:	89 f0                	mov    %esi,%eax
  8005da:	e8 6e fb ff ff       	call   80014d <printnum>
				break;
  8005df:	83 c4 20             	add    $0x20,%esp
  8005e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e5:	e9 a7 fc ff ff       	jmp    800291 <vprintfmt+0x26>

			// escaped '%' character
			case '%':
				putch(ch, putdat);
  8005ea:	83 ec 08             	sub    $0x8,%esp
  8005ed:	53                   	push   %ebx
  8005ee:	51                   	push   %ecx
  8005ef:	ff d6                	call   *%esi
				break;
  8005f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8005f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				break;

			// escaped '%' character
			case '%':
				putch(ch, putdat);
				break;
  8005f7:	e9 95 fc ff ff       	jmp    800291 <vprintfmt+0x26>

			// unrecognized escape sequence - just print it literally
			default:
				putch('%', putdat);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	53                   	push   %ebx
  800600:	6a 25                	push   $0x25
  800602:	ff d6                	call   *%esi
				for (fmt--; fmt[-1] != '%'; fmt--)
  800604:	83 c4 10             	add    $0x10,%esp
  800607:	eb 03                	jmp    80060c <vprintfmt+0x3a1>
  800609:	83 ef 01             	sub    $0x1,%edi
  80060c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800610:	75 f7                	jne    800609 <vprintfmt+0x39e>
  800612:	e9 7a fc ff ff       	jmp    800291 <vprintfmt+0x26>
					/* do nothing */;
				break;
		}
	}
}
  800617:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061a:	5b                   	pop    %ebx
  80061b:	5e                   	pop    %esi
  80061c:	5f                   	pop    %edi
  80061d:	5d                   	pop    %ebp
  80061e:	c3                   	ret    

0080061f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80061f:	55                   	push   %ebp
  800620:	89 e5                	mov    %esp,%ebp
  800622:	83 ec 18             	sub    $0x18,%esp
  800625:	8b 45 08             	mov    0x8(%ebp),%eax
  800628:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80062b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80062e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800632:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800635:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80063c:	85 c0                	test   %eax,%eax
  80063e:	74 26                	je     800666 <vsnprintf+0x47>
  800640:	85 d2                	test   %edx,%edx
  800642:	7e 22                	jle    800666 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800644:	ff 75 14             	pushl  0x14(%ebp)
  800647:	ff 75 10             	pushl  0x10(%ebp)
  80064a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80064d:	50                   	push   %eax
  80064e:	68 31 02 80 00       	push   $0x800231
  800653:	e8 13 fc ff ff       	call   80026b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800658:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80065b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80065e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	eb 05                	jmp    80066b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800666:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80066b:	c9                   	leave  
  80066c:	c3                   	ret    

0080066d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80066d:	55                   	push   %ebp
  80066e:	89 e5                	mov    %esp,%ebp
  800670:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800673:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800676:	50                   	push   %eax
  800677:	ff 75 10             	pushl  0x10(%ebp)
  80067a:	ff 75 0c             	pushl  0xc(%ebp)
  80067d:	ff 75 08             	pushl  0x8(%ebp)
  800680:	e8 9a ff ff ff       	call   80061f <vsnprintf>
	va_end(ap);

	return rc;
}
  800685:	c9                   	leave  
  800686:	c3                   	ret    

00800687 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80068d:	b8 00 00 00 00       	mov    $0x0,%eax
  800692:	eb 03                	jmp    800697 <strlen+0x10>
		n++;
  800694:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800697:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80069b:	75 f7                	jne    800694 <strlen+0xd>
		n++;
	return n;
}
  80069d:	5d                   	pop    %ebp
  80069e:	c3                   	ret    

0080069f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ad:	eb 03                	jmp    8006b2 <strnlen+0x13>
		n++;
  8006af:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006b2:	39 c2                	cmp    %eax,%edx
  8006b4:	74 08                	je     8006be <strnlen+0x1f>
  8006b6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006ba:	75 f3                	jne    8006af <strnlen+0x10>
  8006bc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006be:	5d                   	pop    %ebp
  8006bf:	c3                   	ret    

008006c0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	53                   	push   %ebx
  8006c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006ca:	89 c2                	mov    %eax,%edx
  8006cc:	83 c2 01             	add    $0x1,%edx
  8006cf:	83 c1 01             	add    $0x1,%ecx
  8006d2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006d6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006d9:	84 db                	test   %bl,%bl
  8006db:	75 ef                	jne    8006cc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006dd:	5b                   	pop    %ebx
  8006de:	5d                   	pop    %ebp
  8006df:	c3                   	ret    

008006e0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	53                   	push   %ebx
  8006e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006e7:	53                   	push   %ebx
  8006e8:	e8 9a ff ff ff       	call   800687 <strlen>
  8006ed:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8006f0:	ff 75 0c             	pushl  0xc(%ebp)
  8006f3:	01 d8                	add    %ebx,%eax
  8006f5:	50                   	push   %eax
  8006f6:	e8 c5 ff ff ff       	call   8006c0 <strcpy>
	return dst;
}
  8006fb:	89 d8                	mov    %ebx,%eax
  8006fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800700:	c9                   	leave  
  800701:	c3                   	ret    

00800702 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	56                   	push   %esi
  800706:	53                   	push   %ebx
  800707:	8b 75 08             	mov    0x8(%ebp),%esi
  80070a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80070d:	89 f3                	mov    %esi,%ebx
  80070f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800712:	89 f2                	mov    %esi,%edx
  800714:	eb 0f                	jmp    800725 <strncpy+0x23>
		*dst++ = *src;
  800716:	83 c2 01             	add    $0x1,%edx
  800719:	0f b6 01             	movzbl (%ecx),%eax
  80071c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80071f:	80 39 01             	cmpb   $0x1,(%ecx)
  800722:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800725:	39 da                	cmp    %ebx,%edx
  800727:	75 ed                	jne    800716 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800729:	89 f0                	mov    %esi,%eax
  80072b:	5b                   	pop    %ebx
  80072c:	5e                   	pop    %esi
  80072d:	5d                   	pop    %ebp
  80072e:	c3                   	ret    

0080072f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	56                   	push   %esi
  800733:	53                   	push   %ebx
  800734:	8b 75 08             	mov    0x8(%ebp),%esi
  800737:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80073a:	8b 55 10             	mov    0x10(%ebp),%edx
  80073d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80073f:	85 d2                	test   %edx,%edx
  800741:	74 21                	je     800764 <strlcpy+0x35>
  800743:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800747:	89 f2                	mov    %esi,%edx
  800749:	eb 09                	jmp    800754 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80074b:	83 c2 01             	add    $0x1,%edx
  80074e:	83 c1 01             	add    $0x1,%ecx
  800751:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800754:	39 c2                	cmp    %eax,%edx
  800756:	74 09                	je     800761 <strlcpy+0x32>
  800758:	0f b6 19             	movzbl (%ecx),%ebx
  80075b:	84 db                	test   %bl,%bl
  80075d:	75 ec                	jne    80074b <strlcpy+0x1c>
  80075f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800761:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800764:	29 f0                	sub    %esi,%eax
}
  800766:	5b                   	pop    %ebx
  800767:	5e                   	pop    %esi
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    

0080076a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800770:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800773:	eb 06                	jmp    80077b <strcmp+0x11>
		p++, q++;
  800775:	83 c1 01             	add    $0x1,%ecx
  800778:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80077b:	0f b6 01             	movzbl (%ecx),%eax
  80077e:	84 c0                	test   %al,%al
  800780:	74 04                	je     800786 <strcmp+0x1c>
  800782:	3a 02                	cmp    (%edx),%al
  800784:	74 ef                	je     800775 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800786:	0f b6 c0             	movzbl %al,%eax
  800789:	0f b6 12             	movzbl (%edx),%edx
  80078c:	29 d0                	sub    %edx,%eax
}
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	53                   	push   %ebx
  800794:	8b 45 08             	mov    0x8(%ebp),%eax
  800797:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079a:	89 c3                	mov    %eax,%ebx
  80079c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80079f:	eb 06                	jmp    8007a7 <strncmp+0x17>
		n--, p++, q++;
  8007a1:	83 c0 01             	add    $0x1,%eax
  8007a4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007a7:	39 d8                	cmp    %ebx,%eax
  8007a9:	74 15                	je     8007c0 <strncmp+0x30>
  8007ab:	0f b6 08             	movzbl (%eax),%ecx
  8007ae:	84 c9                	test   %cl,%cl
  8007b0:	74 04                	je     8007b6 <strncmp+0x26>
  8007b2:	3a 0a                	cmp    (%edx),%cl
  8007b4:	74 eb                	je     8007a1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007b6:	0f b6 00             	movzbl (%eax),%eax
  8007b9:	0f b6 12             	movzbl (%edx),%edx
  8007bc:	29 d0                	sub    %edx,%eax
  8007be:	eb 05                	jmp    8007c5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007c0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007c5:	5b                   	pop    %ebx
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007d2:	eb 07                	jmp    8007db <strchr+0x13>
		if (*s == c)
  8007d4:	38 ca                	cmp    %cl,%dl
  8007d6:	74 0f                	je     8007e7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007d8:	83 c0 01             	add    $0x1,%eax
  8007db:	0f b6 10             	movzbl (%eax),%edx
  8007de:	84 d2                	test   %dl,%dl
  8007e0:	75 f2                	jne    8007d4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007f3:	eb 03                	jmp    8007f8 <strfind+0xf>
  8007f5:	83 c0 01             	add    $0x1,%eax
  8007f8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8007fb:	84 d2                	test   %dl,%dl
  8007fd:	74 04                	je     800803 <strfind+0x1a>
  8007ff:	38 ca                	cmp    %cl,%dl
  800801:	75 f2                	jne    8007f5 <strfind+0xc>
			break;
	return (char *) s;
}
  800803:	5d                   	pop    %ebp
  800804:	c3                   	ret    

00800805 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	57                   	push   %edi
  800809:	56                   	push   %esi
  80080a:	53                   	push   %ebx
  80080b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80080e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800811:	85 c9                	test   %ecx,%ecx
  800813:	74 36                	je     80084b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800815:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80081b:	75 28                	jne    800845 <memset+0x40>
  80081d:	f6 c1 03             	test   $0x3,%cl
  800820:	75 23                	jne    800845 <memset+0x40>
		c &= 0xFF;
  800822:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800826:	89 d3                	mov    %edx,%ebx
  800828:	c1 e3 08             	shl    $0x8,%ebx
  80082b:	89 d6                	mov    %edx,%esi
  80082d:	c1 e6 18             	shl    $0x18,%esi
  800830:	89 d0                	mov    %edx,%eax
  800832:	c1 e0 10             	shl    $0x10,%eax
  800835:	09 f0                	or     %esi,%eax
  800837:	09 c2                	or     %eax,%edx
  800839:	89 d0                	mov    %edx,%eax
  80083b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80083d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800840:	fc                   	cld    
  800841:	f3 ab                	rep stos %eax,%es:(%edi)
  800843:	eb 06                	jmp    80084b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800845:	8b 45 0c             	mov    0xc(%ebp),%eax
  800848:	fc                   	cld    
  800849:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80084b:	89 f8                	mov    %edi,%eax
  80084d:	5b                   	pop    %ebx
  80084e:	5e                   	pop    %esi
  80084f:	5f                   	pop    %edi
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	57                   	push   %edi
  800856:	56                   	push   %esi
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80085d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800860:	39 c6                	cmp    %eax,%esi
  800862:	73 35                	jae    800899 <memmove+0x47>
  800864:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800867:	39 d0                	cmp    %edx,%eax
  800869:	73 2e                	jae    800899 <memmove+0x47>
		s += n;
		d += n;
  80086b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80086e:	89 d6                	mov    %edx,%esi
  800870:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800872:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800878:	75 13                	jne    80088d <memmove+0x3b>
  80087a:	f6 c1 03             	test   $0x3,%cl
  80087d:	75 0e                	jne    80088d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80087f:	83 ef 04             	sub    $0x4,%edi
  800882:	8d 72 fc             	lea    -0x4(%edx),%esi
  800885:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800888:	fd                   	std    
  800889:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80088b:	eb 09                	jmp    800896 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80088d:	83 ef 01             	sub    $0x1,%edi
  800890:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800893:	fd                   	std    
  800894:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800896:	fc                   	cld    
  800897:	eb 1d                	jmp    8008b6 <memmove+0x64>
  800899:	89 f2                	mov    %esi,%edx
  80089b:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80089d:	f6 c2 03             	test   $0x3,%dl
  8008a0:	75 0f                	jne    8008b1 <memmove+0x5f>
  8008a2:	f6 c1 03             	test   $0x3,%cl
  8008a5:	75 0a                	jne    8008b1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8008a7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8008aa:	89 c7                	mov    %eax,%edi
  8008ac:	fc                   	cld    
  8008ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008af:	eb 05                	jmp    8008b6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008b1:	89 c7                	mov    %eax,%edi
  8008b3:	fc                   	cld    
  8008b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008b6:	5e                   	pop    %esi
  8008b7:	5f                   	pop    %edi
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008bd:	ff 75 10             	pushl  0x10(%ebp)
  8008c0:	ff 75 0c             	pushl  0xc(%ebp)
  8008c3:	ff 75 08             	pushl  0x8(%ebp)
  8008c6:	e8 87 ff ff ff       	call   800852 <memmove>
}
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    

008008cd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
  8008d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d8:	89 c6                	mov    %eax,%esi
  8008da:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008dd:	eb 1a                	jmp    8008f9 <memcmp+0x2c>
		if (*s1 != *s2)
  8008df:	0f b6 08             	movzbl (%eax),%ecx
  8008e2:	0f b6 1a             	movzbl (%edx),%ebx
  8008e5:	38 d9                	cmp    %bl,%cl
  8008e7:	74 0a                	je     8008f3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008e9:	0f b6 c1             	movzbl %cl,%eax
  8008ec:	0f b6 db             	movzbl %bl,%ebx
  8008ef:	29 d8                	sub    %ebx,%eax
  8008f1:	eb 0f                	jmp    800902 <memcmp+0x35>
		s1++, s2++;
  8008f3:	83 c0 01             	add    $0x1,%eax
  8008f6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008f9:	39 f0                	cmp    %esi,%eax
  8008fb:	75 e2                	jne    8008df <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8008fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80090f:	89 c2                	mov    %eax,%edx
  800911:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800914:	eb 07                	jmp    80091d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800916:	38 08                	cmp    %cl,(%eax)
  800918:	74 07                	je     800921 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80091a:	83 c0 01             	add    $0x1,%eax
  80091d:	39 d0                	cmp    %edx,%eax
  80091f:	72 f5                	jb     800916 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	57                   	push   %edi
  800927:	56                   	push   %esi
  800928:	53                   	push   %ebx
  800929:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80092f:	eb 03                	jmp    800934 <strtol+0x11>
		s++;
  800931:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800934:	0f b6 01             	movzbl (%ecx),%eax
  800937:	3c 09                	cmp    $0x9,%al
  800939:	74 f6                	je     800931 <strtol+0xe>
  80093b:	3c 20                	cmp    $0x20,%al
  80093d:	74 f2                	je     800931 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80093f:	3c 2b                	cmp    $0x2b,%al
  800941:	75 0a                	jne    80094d <strtol+0x2a>
		s++;
  800943:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800946:	bf 00 00 00 00       	mov    $0x0,%edi
  80094b:	eb 10                	jmp    80095d <strtol+0x3a>
  80094d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800952:	3c 2d                	cmp    $0x2d,%al
  800954:	75 07                	jne    80095d <strtol+0x3a>
		s++, neg = 1;
  800956:	8d 49 01             	lea    0x1(%ecx),%ecx
  800959:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80095d:	85 db                	test   %ebx,%ebx
  80095f:	0f 94 c0             	sete   %al
  800962:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800968:	75 19                	jne    800983 <strtol+0x60>
  80096a:	80 39 30             	cmpb   $0x30,(%ecx)
  80096d:	75 14                	jne    800983 <strtol+0x60>
  80096f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800973:	0f 85 82 00 00 00    	jne    8009fb <strtol+0xd8>
		s += 2, base = 16;
  800979:	83 c1 02             	add    $0x2,%ecx
  80097c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800981:	eb 16                	jmp    800999 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800983:	84 c0                	test   %al,%al
  800985:	74 12                	je     800999 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800987:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80098c:	80 39 30             	cmpb   $0x30,(%ecx)
  80098f:	75 08                	jne    800999 <strtol+0x76>
		s++, base = 8;
  800991:	83 c1 01             	add    $0x1,%ecx
  800994:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800999:	b8 00 00 00 00       	mov    $0x0,%eax
  80099e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009a1:	0f b6 11             	movzbl (%ecx),%edx
  8009a4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009a7:	89 f3                	mov    %esi,%ebx
  8009a9:	80 fb 09             	cmp    $0x9,%bl
  8009ac:	77 08                	ja     8009b6 <strtol+0x93>
			dig = *s - '0';
  8009ae:	0f be d2             	movsbl %dl,%edx
  8009b1:	83 ea 30             	sub    $0x30,%edx
  8009b4:	eb 22                	jmp    8009d8 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8009b6:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009b9:	89 f3                	mov    %esi,%ebx
  8009bb:	80 fb 19             	cmp    $0x19,%bl
  8009be:	77 08                	ja     8009c8 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8009c0:	0f be d2             	movsbl %dl,%edx
  8009c3:	83 ea 57             	sub    $0x57,%edx
  8009c6:	eb 10                	jmp    8009d8 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8009c8:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009cb:	89 f3                	mov    %esi,%ebx
  8009cd:	80 fb 19             	cmp    $0x19,%bl
  8009d0:	77 16                	ja     8009e8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8009d2:	0f be d2             	movsbl %dl,%edx
  8009d5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009d8:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009db:	7d 0f                	jge    8009ec <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8009dd:	83 c1 01             	add    $0x1,%ecx
  8009e0:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009e4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009e6:	eb b9                	jmp    8009a1 <strtol+0x7e>
  8009e8:	89 c2                	mov    %eax,%edx
  8009ea:	eb 02                	jmp    8009ee <strtol+0xcb>
  8009ec:	89 c2                	mov    %eax,%edx

	if (endptr)
  8009ee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009f2:	74 0d                	je     800a01 <strtol+0xde>
		*endptr = (char *) s;
  8009f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f7:	89 0e                	mov    %ecx,(%esi)
  8009f9:	eb 06                	jmp    800a01 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009fb:	84 c0                	test   %al,%al
  8009fd:	75 92                	jne    800991 <strtol+0x6e>
  8009ff:	eb 98                	jmp    800999 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a01:	f7 da                	neg    %edx
  800a03:	85 ff                	test   %edi,%edi
  800a05:	0f 45 c2             	cmovne %edx,%eax
}
  800a08:	5b                   	pop    %ebx
  800a09:	5e                   	pop    %esi
  800a0a:	5f                   	pop    %edi
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    

00800a0d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	57                   	push   %edi
  800a11:	56                   	push   %esi
  800a12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
  800a18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1e:	89 c3                	mov    %eax,%ebx
  800a20:	89 c7                	mov    %eax,%edi
  800a22:	89 c6                	mov    %eax,%esi
  800a24:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5f                   	pop    %edi
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <sys_cgetc>:

int
sys_cgetc(void)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	57                   	push   %edi
  800a2f:	56                   	push   %esi
  800a30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a31:	ba 00 00 00 00       	mov    $0x0,%edx
  800a36:	b8 01 00 00 00       	mov    $0x1,%eax
  800a3b:	89 d1                	mov    %edx,%ecx
  800a3d:	89 d3                	mov    %edx,%ebx
  800a3f:	89 d7                	mov    %edx,%edi
  800a41:	89 d6                	mov    %edx,%esi
  800a43:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5f                   	pop    %edi
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	57                   	push   %edi
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
  800a50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a58:	b8 03 00 00 00       	mov    $0x3,%eax
  800a5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a60:	89 cb                	mov    %ecx,%ebx
  800a62:	89 cf                	mov    %ecx,%edi
  800a64:	89 ce                	mov    %ecx,%esi
  800a66:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a68:	85 c0                	test   %eax,%eax
  800a6a:	7e 17                	jle    800a83 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a6c:	83 ec 0c             	sub    $0xc,%esp
  800a6f:	50                   	push   %eax
  800a70:	6a 03                	push   $0x3
  800a72:	68 e0 0f 80 00       	push   $0x800fe0
  800a77:	6a 23                	push   $0x23
  800a79:	68 fd 0f 80 00       	push   $0x800ffd
  800a7e:	e8 27 00 00 00       	call   800aaa <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a91:	ba 00 00 00 00       	mov    $0x0,%edx
  800a96:	b8 02 00 00 00       	mov    $0x2,%eax
  800a9b:	89 d1                	mov    %edx,%ecx
  800a9d:	89 d3                	mov    %edx,%ebx
  800a9f:	89 d7                	mov    %edx,%edi
  800aa1:	89 d6                	mov    %edx,%esi
  800aa3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800aaf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ab2:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ab8:	e8 ce ff ff ff       	call   800a8b <sys_getenvid>
  800abd:	83 ec 0c             	sub    $0xc,%esp
  800ac0:	ff 75 0c             	pushl  0xc(%ebp)
  800ac3:	ff 75 08             	pushl  0x8(%ebp)
  800ac6:	56                   	push   %esi
  800ac7:	50                   	push   %eax
  800ac8:	68 0c 10 80 00       	push   $0x80100c
  800acd:	e8 67 f6 ff ff       	call   800139 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ad2:	83 c4 18             	add    $0x18,%esp
  800ad5:	53                   	push   %ebx
  800ad6:	ff 75 10             	pushl  0x10(%ebp)
  800ad9:	e8 0a f6 ff ff       	call   8000e8 <vcprintf>
	cprintf("\n");
  800ade:	c7 04 24 ac 0d 80 00 	movl   $0x800dac,(%esp)
  800ae5:	e8 4f f6 ff ff       	call   800139 <cprintf>
  800aea:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800aed:	cc                   	int3   
  800aee:	eb fd                	jmp    800aed <_panic+0x43>

00800af0 <__udivdi3>:
  800af0:	55                   	push   %ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	83 ec 10             	sub    $0x10,%esp
  800af6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800afa:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800afe:	8b 74 24 24          	mov    0x24(%esp),%esi
  800b02:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800b06:	85 d2                	test   %edx,%edx
  800b08:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b0c:	89 34 24             	mov    %esi,(%esp)
  800b0f:	89 c8                	mov    %ecx,%eax
  800b11:	75 35                	jne    800b48 <__udivdi3+0x58>
  800b13:	39 f1                	cmp    %esi,%ecx
  800b15:	0f 87 bd 00 00 00    	ja     800bd8 <__udivdi3+0xe8>
  800b1b:	85 c9                	test   %ecx,%ecx
  800b1d:	89 cd                	mov    %ecx,%ebp
  800b1f:	75 0b                	jne    800b2c <__udivdi3+0x3c>
  800b21:	b8 01 00 00 00       	mov    $0x1,%eax
  800b26:	31 d2                	xor    %edx,%edx
  800b28:	f7 f1                	div    %ecx
  800b2a:	89 c5                	mov    %eax,%ebp
  800b2c:	89 f0                	mov    %esi,%eax
  800b2e:	31 d2                	xor    %edx,%edx
  800b30:	f7 f5                	div    %ebp
  800b32:	89 c6                	mov    %eax,%esi
  800b34:	89 f8                	mov    %edi,%eax
  800b36:	f7 f5                	div    %ebp
  800b38:	89 f2                	mov    %esi,%edx
  800b3a:	83 c4 10             	add    $0x10,%esp
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    
  800b41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800b48:	3b 14 24             	cmp    (%esp),%edx
  800b4b:	77 7b                	ja     800bc8 <__udivdi3+0xd8>
  800b4d:	0f bd f2             	bsr    %edx,%esi
  800b50:	83 f6 1f             	xor    $0x1f,%esi
  800b53:	0f 84 97 00 00 00    	je     800bf0 <__udivdi3+0x100>
  800b59:	bd 20 00 00 00       	mov    $0x20,%ebp
  800b5e:	89 d7                	mov    %edx,%edi
  800b60:	89 f1                	mov    %esi,%ecx
  800b62:	29 f5                	sub    %esi,%ebp
  800b64:	d3 e7                	shl    %cl,%edi
  800b66:	89 c2                	mov    %eax,%edx
  800b68:	89 e9                	mov    %ebp,%ecx
  800b6a:	d3 ea                	shr    %cl,%edx
  800b6c:	89 f1                	mov    %esi,%ecx
  800b6e:	09 fa                	or     %edi,%edx
  800b70:	8b 3c 24             	mov    (%esp),%edi
  800b73:	d3 e0                	shl    %cl,%eax
  800b75:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b79:	89 e9                	mov    %ebp,%ecx
  800b7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b7f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800b83:	89 fa                	mov    %edi,%edx
  800b85:	d3 ea                	shr    %cl,%edx
  800b87:	89 f1                	mov    %esi,%ecx
  800b89:	d3 e7                	shl    %cl,%edi
  800b8b:	89 e9                	mov    %ebp,%ecx
  800b8d:	d3 e8                	shr    %cl,%eax
  800b8f:	09 c7                	or     %eax,%edi
  800b91:	89 f8                	mov    %edi,%eax
  800b93:	f7 74 24 08          	divl   0x8(%esp)
  800b97:	89 d5                	mov    %edx,%ebp
  800b99:	89 c7                	mov    %eax,%edi
  800b9b:	f7 64 24 0c          	mull   0xc(%esp)
  800b9f:	39 d5                	cmp    %edx,%ebp
  800ba1:	89 14 24             	mov    %edx,(%esp)
  800ba4:	72 11                	jb     800bb7 <__udivdi3+0xc7>
  800ba6:	8b 54 24 04          	mov    0x4(%esp),%edx
  800baa:	89 f1                	mov    %esi,%ecx
  800bac:	d3 e2                	shl    %cl,%edx
  800bae:	39 c2                	cmp    %eax,%edx
  800bb0:	73 5e                	jae    800c10 <__udivdi3+0x120>
  800bb2:	3b 2c 24             	cmp    (%esp),%ebp
  800bb5:	75 59                	jne    800c10 <__udivdi3+0x120>
  800bb7:	8d 47 ff             	lea    -0x1(%edi),%eax
  800bba:	31 f6                	xor    %esi,%esi
  800bbc:	89 f2                	mov    %esi,%edx
  800bbe:	83 c4 10             	add    $0x10,%esp
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    
  800bc5:	8d 76 00             	lea    0x0(%esi),%esi
  800bc8:	31 f6                	xor    %esi,%esi
  800bca:	31 c0                	xor    %eax,%eax
  800bcc:	89 f2                	mov    %esi,%edx
  800bce:	83 c4 10             	add    $0x10,%esp
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    
  800bd5:	8d 76 00             	lea    0x0(%esi),%esi
  800bd8:	89 f2                	mov    %esi,%edx
  800bda:	31 f6                	xor    %esi,%esi
  800bdc:	89 f8                	mov    %edi,%eax
  800bde:	f7 f1                	div    %ecx
  800be0:	89 f2                	mov    %esi,%edx
  800be2:	83 c4 10             	add    $0x10,%esp
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    
  800be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800bf0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800bf4:	76 0b                	jbe    800c01 <__udivdi3+0x111>
  800bf6:	31 c0                	xor    %eax,%eax
  800bf8:	3b 14 24             	cmp    (%esp),%edx
  800bfb:	0f 83 37 ff ff ff    	jae    800b38 <__udivdi3+0x48>
  800c01:	b8 01 00 00 00       	mov    $0x1,%eax
  800c06:	e9 2d ff ff ff       	jmp    800b38 <__udivdi3+0x48>
  800c0b:	90                   	nop
  800c0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c10:	89 f8                	mov    %edi,%eax
  800c12:	31 f6                	xor    %esi,%esi
  800c14:	e9 1f ff ff ff       	jmp    800b38 <__udivdi3+0x48>
  800c19:	66 90                	xchg   %ax,%ax
  800c1b:	66 90                	xchg   %ax,%ax
  800c1d:	66 90                	xchg   %ax,%ax
  800c1f:	90                   	nop

00800c20 <__umoddi3>:
  800c20:	55                   	push   %ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	83 ec 20             	sub    $0x20,%esp
  800c26:	8b 44 24 34          	mov    0x34(%esp),%eax
  800c2a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c2e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c32:	89 c6                	mov    %eax,%esi
  800c34:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c38:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c3c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800c40:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c44:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800c48:	89 74 24 18          	mov    %esi,0x18(%esp)
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	89 c2                	mov    %eax,%edx
  800c50:	75 1e                	jne    800c70 <__umoddi3+0x50>
  800c52:	39 f7                	cmp    %esi,%edi
  800c54:	76 52                	jbe    800ca8 <__umoddi3+0x88>
  800c56:	89 c8                	mov    %ecx,%eax
  800c58:	89 f2                	mov    %esi,%edx
  800c5a:	f7 f7                	div    %edi
  800c5c:	89 d0                	mov    %edx,%eax
  800c5e:	31 d2                	xor    %edx,%edx
  800c60:	83 c4 20             	add    $0x20,%esp
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    
  800c67:	89 f6                	mov    %esi,%esi
  800c69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800c70:	39 f0                	cmp    %esi,%eax
  800c72:	77 5c                	ja     800cd0 <__umoddi3+0xb0>
  800c74:	0f bd e8             	bsr    %eax,%ebp
  800c77:	83 f5 1f             	xor    $0x1f,%ebp
  800c7a:	75 64                	jne    800ce0 <__umoddi3+0xc0>
  800c7c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800c80:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800c84:	0f 86 f6 00 00 00    	jbe    800d80 <__umoddi3+0x160>
  800c8a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800c8e:	0f 82 ec 00 00 00    	jb     800d80 <__umoddi3+0x160>
  800c94:	8b 44 24 14          	mov    0x14(%esp),%eax
  800c98:	8b 54 24 18          	mov    0x18(%esp),%edx
  800c9c:	83 c4 20             	add    $0x20,%esp
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    
  800ca3:	90                   	nop
  800ca4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ca8:	85 ff                	test   %edi,%edi
  800caa:	89 fd                	mov    %edi,%ebp
  800cac:	75 0b                	jne    800cb9 <__umoddi3+0x99>
  800cae:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb3:	31 d2                	xor    %edx,%edx
  800cb5:	f7 f7                	div    %edi
  800cb7:	89 c5                	mov    %eax,%ebp
  800cb9:	8b 44 24 10          	mov    0x10(%esp),%eax
  800cbd:	31 d2                	xor    %edx,%edx
  800cbf:	f7 f5                	div    %ebp
  800cc1:	89 c8                	mov    %ecx,%eax
  800cc3:	f7 f5                	div    %ebp
  800cc5:	eb 95                	jmp    800c5c <__umoddi3+0x3c>
  800cc7:	89 f6                	mov    %esi,%esi
  800cc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800cd0:	89 c8                	mov    %ecx,%eax
  800cd2:	89 f2                	mov    %esi,%edx
  800cd4:	83 c4 20             	add    $0x20,%esp
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    
  800cdb:	90                   	nop
  800cdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ce0:	b8 20 00 00 00       	mov    $0x20,%eax
  800ce5:	89 e9                	mov    %ebp,%ecx
  800ce7:	29 e8                	sub    %ebp,%eax
  800ce9:	d3 e2                	shl    %cl,%edx
  800ceb:	89 c7                	mov    %eax,%edi
  800ced:	89 44 24 18          	mov    %eax,0x18(%esp)
  800cf1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cf5:	89 f9                	mov    %edi,%ecx
  800cf7:	d3 e8                	shr    %cl,%eax
  800cf9:	89 c1                	mov    %eax,%ecx
  800cfb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cff:	09 d1                	or     %edx,%ecx
  800d01:	89 fa                	mov    %edi,%edx
  800d03:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800d07:	89 e9                	mov    %ebp,%ecx
  800d09:	d3 e0                	shl    %cl,%eax
  800d0b:	89 f9                	mov    %edi,%ecx
  800d0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d11:	89 f0                	mov    %esi,%eax
  800d13:	d3 e8                	shr    %cl,%eax
  800d15:	89 e9                	mov    %ebp,%ecx
  800d17:	89 c7                	mov    %eax,%edi
  800d19:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800d1d:	d3 e6                	shl    %cl,%esi
  800d1f:	89 d1                	mov    %edx,%ecx
  800d21:	89 fa                	mov    %edi,%edx
  800d23:	d3 e8                	shr    %cl,%eax
  800d25:	89 e9                	mov    %ebp,%ecx
  800d27:	09 f0                	or     %esi,%eax
  800d29:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800d2d:	f7 74 24 10          	divl   0x10(%esp)
  800d31:	d3 e6                	shl    %cl,%esi
  800d33:	89 d1                	mov    %edx,%ecx
  800d35:	f7 64 24 0c          	mull   0xc(%esp)
  800d39:	39 d1                	cmp    %edx,%ecx
  800d3b:	89 74 24 14          	mov    %esi,0x14(%esp)
  800d3f:	89 d7                	mov    %edx,%edi
  800d41:	89 c6                	mov    %eax,%esi
  800d43:	72 0a                	jb     800d4f <__umoddi3+0x12f>
  800d45:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800d49:	73 10                	jae    800d5b <__umoddi3+0x13b>
  800d4b:	39 d1                	cmp    %edx,%ecx
  800d4d:	75 0c                	jne    800d5b <__umoddi3+0x13b>
  800d4f:	89 d7                	mov    %edx,%edi
  800d51:	89 c6                	mov    %eax,%esi
  800d53:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800d57:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800d5b:	89 ca                	mov    %ecx,%edx
  800d5d:	89 e9                	mov    %ebp,%ecx
  800d5f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800d63:	29 f0                	sub    %esi,%eax
  800d65:	19 fa                	sbb    %edi,%edx
  800d67:	d3 e8                	shr    %cl,%eax
  800d69:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800d6e:	89 d7                	mov    %edx,%edi
  800d70:	d3 e7                	shl    %cl,%edi
  800d72:	89 e9                	mov    %ebp,%ecx
  800d74:	09 f8                	or     %edi,%eax
  800d76:	d3 ea                	shr    %cl,%edx
  800d78:	83 c4 20             	add    $0x20,%esp
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    
  800d7f:	90                   	nop
  800d80:	8b 74 24 10          	mov    0x10(%esp),%esi
  800d84:	29 f9                	sub    %edi,%ecx
  800d86:	19 c6                	sbb    %eax,%esi
  800d88:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800d8c:	89 74 24 18          	mov    %esi,0x18(%esp)
  800d90:	e9 ff fe ff ff       	jmp    800c94 <__umoddi3+0x74>
