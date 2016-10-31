
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
  80002c:	e8 31 00 00 00       	call   800062 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	89 44 24 04          	mov    %eax,0x4(%esp)
  800054:	c7 04 24 c0 10 80 00 	movl   $0x8010c0,(%esp)
  80005b:	e8 17 01 00 00       	call   800177 <cprintf>
}
  800060:	c9                   	leave  
  800061:	c3                   	ret    

00800062 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800062:	55                   	push   %ebp
  800063:	89 e5                	mov    %esp,%ebp
  800065:	57                   	push   %edi
  800066:	56                   	push   %esi
  800067:	53                   	push   %ebx
  800068:	83 ec 1c             	sub    $0x1c,%esp
  80006b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = envs[sys_getenvid];
	//envid2env(sys_getenvid, &thisenv, 1);
	//((sys_getenvid) & (1024 - 1))
	int envid = sys_getenvid();
  800071:	e8 0f 0b 00 00       	call   800b85 <sys_getenvid>
	int index = envid & (1023);
  800076:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007b:	89 c6                	mov    %eax,%esi
	cprintf("Value of x:%x\n",index);
  80007d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800081:	c7 04 24 ce 10 80 00 	movl   $0x8010ce,(%esp)
  800088:	e8 ea 00 00 00       	call   800177 <cprintf>
	thisenv = &envs[index];
  80008d:	6b f6 7c             	imul   $0x7c,%esi,%esi
  800090:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  800096:	89 35 08 20 80 00    	mov    %esi,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009c:	85 db                	test   %ebx,%ebx
  80009e:	7e 07                	jle    8000a7 <libmain+0x45>
		binaryname = argv[0];
  8000a0:	8b 07                	mov    (%edi),%eax
  8000a2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8000ab:	89 1c 24             	mov    %ebx,(%esp)
  8000ae:	e8 80 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b3:	e8 08 00 00 00       	call   8000c0 <exit>
}
  8000b8:	83 c4 1c             	add    $0x1c,%esp
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000cd:	e8 61 0a 00 00       	call   800b33 <sys_env_destroy>
}
  8000d2:	c9                   	leave  
  8000d3:	c3                   	ret    

008000d4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	53                   	push   %ebx
  8000d8:	83 ec 14             	sub    $0x14,%esp
  8000db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000de:	8b 13                	mov    (%ebx),%edx
  8000e0:	8d 42 01             	lea    0x1(%edx),%eax
  8000e3:	89 03                	mov    %eax,(%ebx)
  8000e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ec:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f1:	75 19                	jne    80010c <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8000f3:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8000fa:	00 
  8000fb:	8d 43 08             	lea    0x8(%ebx),%eax
  8000fe:	89 04 24             	mov    %eax,(%esp)
  800101:	e8 f0 09 00 00       	call   800af6 <sys_cputs>
		b->idx = 0;
  800106:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80010c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800110:	83 c4 14             	add    $0x14,%esp
  800113:	5b                   	pop    %ebx
  800114:	5d                   	pop    %ebp
  800115:	c3                   	ret    

00800116 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80011f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800126:	00 00 00 
	b.cnt = 0;
  800129:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800130:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800133:	8b 45 0c             	mov    0xc(%ebp),%eax
  800136:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013a:	8b 45 08             	mov    0x8(%ebp),%eax
  80013d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800141:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800147:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014b:	c7 04 24 d4 00 80 00 	movl   $0x8000d4,(%esp)
  800152:	e8 b7 01 00 00       	call   80030e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800157:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800161:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800167:	89 04 24             	mov    %eax,(%esp)
  80016a:	e8 87 09 00 00       	call   800af6 <sys_cputs>

	return b.cnt;
}
  80016f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800175:	c9                   	leave  
  800176:	c3                   	ret    

00800177 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80017d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800180:	89 44 24 04          	mov    %eax,0x4(%esp)
  800184:	8b 45 08             	mov    0x8(%ebp),%eax
  800187:	89 04 24             	mov    %eax,(%esp)
  80018a:	e8 87 ff ff ff       	call   800116 <vcprintf>
	va_end(ap);

	return cnt;
}
  80018f:	c9                   	leave  
  800190:	c3                   	ret    
  800191:	66 90                	xchg   %ax,%ax
  800193:	66 90                	xchg   %ax,%ax
  800195:	66 90                	xchg   %ax,%ax
  800197:	66 90                	xchg   %ax,%ax
  800199:	66 90                	xchg   %ax,%ax
  80019b:	66 90                	xchg   %ax,%ax
  80019d:	66 90                	xchg   %ax,%ax
  80019f:	90                   	nop

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 3c             	sub    $0x3c,%esp
  8001a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ac:	89 d7                	mov    %edx,%edi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b7:	89 c3                	mov    %eax,%ebx
  8001b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8001bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001cd:	39 d9                	cmp    %ebx,%ecx
  8001cf:	72 05                	jb     8001d6 <printnum+0x36>
  8001d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8001d4:	77 69                	ja     80023f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8001d9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8001dd:	83 ee 01             	sub    $0x1,%esi
  8001e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8001ec:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8001f0:	89 c3                	mov    %eax,%ebx
  8001f2:	89 d6                	mov    %edx,%esi
  8001f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8001fa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8001fe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800202:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800205:	89 04 24             	mov    %eax,(%esp)
  800208:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80020b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020f:	e8 1c 0c 00 00       	call   800e30 <__udivdi3>
  800214:	89 d9                	mov    %ebx,%ecx
  800216:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80021a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80021e:	89 04 24             	mov    %eax,(%esp)
  800221:	89 54 24 04          	mov    %edx,0x4(%esp)
  800225:	89 fa                	mov    %edi,%edx
  800227:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80022a:	e8 71 ff ff ff       	call   8001a0 <printnum>
  80022f:	eb 1b                	jmp    80024c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800231:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800235:	8b 45 18             	mov    0x18(%ebp),%eax
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	ff d3                	call   *%ebx
  80023d:	eb 03                	jmp    800242 <printnum+0xa2>
  80023f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800242:	83 ee 01             	sub    $0x1,%esi
  800245:	85 f6                	test   %esi,%esi
  800247:	7f e8                	jg     800231 <printnum+0x91>
  800249:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800250:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800254:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800257:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80025a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80025e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800262:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800265:	89 04 24             	mov    %eax,(%esp)
  800268:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80026b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026f:	e8 ec 0c 00 00       	call   800f60 <__umoddi3>
  800274:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800278:	0f be 80 e7 10 80 00 	movsbl 0x8010e7(%eax),%eax
  80027f:	89 04 24             	mov    %eax,(%esp)
  800282:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800285:	ff d0                	call   *%eax
}
  800287:	83 c4 3c             	add    $0x3c,%esp
  80028a:	5b                   	pop    %ebx
  80028b:	5e                   	pop    %esi
  80028c:	5f                   	pop    %edi
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800292:	83 fa 01             	cmp    $0x1,%edx
  800295:	7e 0e                	jle    8002a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800297:	8b 10                	mov    (%eax),%edx
  800299:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029c:	89 08                	mov    %ecx,(%eax)
  80029e:	8b 02                	mov    (%edx),%eax
  8002a0:	8b 52 04             	mov    0x4(%edx),%edx
  8002a3:	eb 22                	jmp    8002c7 <getuint+0x38>
	else if (lflag)
  8002a5:	85 d2                	test   %edx,%edx
  8002a7:	74 10                	je     8002b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a9:	8b 10                	mov    (%eax),%edx
  8002ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ae:	89 08                	mov    %ecx,(%eax)
  8002b0:	8b 02                	mov    (%edx),%eax
  8002b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b7:	eb 0e                	jmp    8002c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b9:	8b 10                	mov    (%eax),%edx
  8002bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002be:	89 08                	mov    %ecx,(%eax)
  8002c0:	8b 02                	mov    (%edx),%eax
  8002c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d8:	73 0a                	jae    8002e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	88 02                	mov    %al,(%edx)
}
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800301:	8b 45 08             	mov    0x8(%ebp),%eax
  800304:	89 04 24             	mov    %eax,(%esp)
  800307:	e8 02 00 00 00       	call   80030e <vprintfmt>
	va_end(ap);
}
  80030c:	c9                   	leave  
  80030d:	c3                   	ret    

0080030e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 3c             	sub    $0x3c,%esp
  800317:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80031a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80031d:	eb 14                	jmp    800333 <vprintfmt+0x25>

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
		{
			if (ch == '\0')
  80031f:	85 c0                	test   %eax,%eax
  800321:	0f 84 b3 03 00 00    	je     8006da <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800327:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80032b:	89 04 24             	mov    %eax,(%esp)
  80032e:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
  800331:	89 f3                	mov    %esi,%ebx
  800333:	8d 73 01             	lea    0x1(%ebx),%esi
  800336:	0f b6 03             	movzbl (%ebx),%eax
  800339:	83 f8 25             	cmp    $0x25,%eax
  80033c:	75 e1                	jne    80031f <vprintfmt+0x11>
  80033e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800342:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800349:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800350:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800357:	ba 00 00 00 00       	mov    $0x0,%edx
  80035c:	eb 1d                	jmp    80037b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  80035e:	89 de                	mov    %ebx,%esi
		{

			// flag to pad on the right
			case '-':
				padc = '-';
  800360:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800364:	eb 15                	jmp    80037b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800366:	89 de                	mov    %ebx,%esi
				padc = '-';
				goto reswitch;

			// flag to pad with 0's instead of spaces
			case '0':
				padc = '0';
  800368:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80036c:	eb 0d                	jmp    80037b <vprintfmt+0x6d>
				altflag = 1;
				goto reswitch;

			process_precision:
				if (width < 0)
					width = precision, precision = -1;
  80036e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800371:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800374:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  80037b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80037e:	0f b6 0e             	movzbl (%esi),%ecx
  800381:	0f b6 c1             	movzbl %cl,%eax
  800384:	83 e9 23             	sub    $0x23,%ecx
  800387:	80 f9 55             	cmp    $0x55,%cl
  80038a:	0f 87 2a 03 00 00    	ja     8006ba <vprintfmt+0x3ac>
  800390:	0f b6 c9             	movzbl %cl,%ecx
  800393:	ff 24 8d a0 11 80 00 	jmp    *0x8011a0(,%ecx,4)
  80039a:	89 de                	mov    %ebx,%esi
  80039c:	b9 00 00 00 00       	mov    $0x0,%ecx
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
					precision = precision * 10 + ch - '0';
  8003a1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003a4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
					ch = *fmt;
  8003a8:	0f be 06             	movsbl (%esi),%eax
					if (ch < '0' || ch > '9')
  8003ab:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003ae:	83 fb 09             	cmp    $0x9,%ebx
  8003b1:	77 36                	ja     8003e9 <vprintfmt+0xdb>
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
  8003b3:	83 c6 01             	add    $0x1,%esi
					precision = precision * 10 + ch - '0';
					ch = *fmt;
					if (ch < '0' || ch > '9')
						break;
				}
  8003b6:	eb e9                	jmp    8003a1 <vprintfmt+0x93>
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
  8003b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bb:	8d 48 04             	lea    0x4(%eax),%ecx
  8003be:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003c1:	8b 00                	mov    (%eax),%eax
  8003c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003c6:	89 de                	mov    %ebx,%esi
				}
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
				goto process_precision;
  8003c8:	eb 22                	jmp    8003ec <vprintfmt+0xde>
  8003ca:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8003cd:	85 c9                	test   %ecx,%ecx
  8003cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d4:	0f 49 c1             	cmovns %ecx,%eax
  8003d7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003da:	89 de                	mov    %ebx,%esi
  8003dc:	eb 9d                	jmp    80037b <vprintfmt+0x6d>
  8003de:	89 de                	mov    %ebx,%esi
				if (width < 0)
					width = 0;
				goto reswitch;

			case '#':
				altflag = 1;
  8003e0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
				goto reswitch;
  8003e7:	eb 92                	jmp    80037b <vprintfmt+0x6d>
  8003e9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

			process_precision:
				if (width < 0)
  8003ec:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8003f0:	79 89                	jns    80037b <vprintfmt+0x6d>
  8003f2:	e9 77 ff ff ff       	jmp    80036e <vprintfmt+0x60>
					width = precision, precision = -1;
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
  8003f7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003fa:	89 de                	mov    %ebx,%esi
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
				goto reswitch;
  8003fc:	e9 7a ff ff ff       	jmp    80037b <vprintfmt+0x6d>

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	8d 50 04             	lea    0x4(%eax),%edx
  800407:	89 55 14             	mov    %edx,0x14(%ebp)
  80040a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80040e:	8b 00                	mov    (%eax),%eax
  800410:	89 04 24             	mov    %eax,(%esp)
  800413:	ff 55 08             	call   *0x8(%ebp)
				break;
  800416:	e9 18 ff ff ff       	jmp    800333 <vprintfmt+0x25>

			// error message
			case 'e':
				err = va_arg(ap, int);
  80041b:	8b 45 14             	mov    0x14(%ebp),%eax
  80041e:	8d 50 04             	lea    0x4(%eax),%edx
  800421:	89 55 14             	mov    %edx,0x14(%ebp)
  800424:	8b 00                	mov    (%eax),%eax
  800426:	99                   	cltd   
  800427:	31 d0                	xor    %edx,%eax
  800429:	29 d0                	sub    %edx,%eax
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042b:	83 f8 09             	cmp    $0x9,%eax
  80042e:	7f 0b                	jg     80043b <vprintfmt+0x12d>
  800430:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  800437:	85 d2                	test   %edx,%edx
  800439:	75 20                	jne    80045b <vprintfmt+0x14d>
					printfmt(putch, putdat, "error %d", err);
  80043b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043f:	c7 44 24 08 ff 10 80 	movl   $0x8010ff,0x8(%esp)
  800446:	00 
  800447:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80044b:	8b 45 08             	mov    0x8(%ebp),%eax
  80044e:	89 04 24             	mov    %eax,(%esp)
  800451:	e8 90 fe ff ff       	call   8002e6 <printfmt>
  800456:	e9 d8 fe ff ff       	jmp    800333 <vprintfmt+0x25>
				else
					printfmt(putch, putdat, "%s", p);
  80045b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045f:	c7 44 24 08 08 11 80 	movl   $0x801108,0x8(%esp)
  800466:	00 
  800467:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80046b:	8b 45 08             	mov    0x8(%ebp),%eax
  80046e:	89 04 24             	mov    %eax,(%esp)
  800471:	e8 70 fe ff ff       	call   8002e6 <printfmt>
  800476:	e9 b8 fe ff ff       	jmp    800333 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  80047b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80047e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800481:	89 45 d0             	mov    %eax,-0x30(%ebp)
					printfmt(putch, putdat, "%s", p);
				break;

			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	8d 50 04             	lea    0x4(%eax),%edx
  80048a:	89 55 14             	mov    %edx,0x14(%ebp)
  80048d:	8b 30                	mov    (%eax),%esi
					p = "(null)";
  80048f:	85 f6                	test   %esi,%esi
  800491:	b8 f8 10 80 00       	mov    $0x8010f8,%eax
  800496:	0f 44 f0             	cmove  %eax,%esi
				if (width > 0 && padc != '-')
  800499:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80049d:	0f 84 97 00 00 00    	je     80053a <vprintfmt+0x22c>
  8004a3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004a7:	0f 8e 9b 00 00 00    	jle    800548 <vprintfmt+0x23a>
					for (width -= strnlen(p, precision); width > 0; width--)
  8004ad:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004b1:	89 34 24             	mov    %esi,(%esp)
  8004b4:	e8 cf 02 00 00       	call   800788 <strnlen>
  8004b9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004bc:	29 c2                	sub    %eax,%edx
  8004be:	89 55 d0             	mov    %edx,-0x30(%ebp)
						putch(padc, putdat);
  8004c1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004c8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8004cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ce:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8004d1:	89 d3                	mov    %edx,%ebx
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  8004d3:	eb 0f                	jmp    8004e4 <vprintfmt+0x1d6>
						putch(padc, putdat);
  8004d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004dc:	89 04 24             	mov    %eax,(%esp)
  8004df:	ff d6                	call   *%esi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  8004e1:	83 eb 01             	sub    $0x1,%ebx
  8004e4:	85 db                	test   %ebx,%ebx
  8004e6:	7f ed                	jg     8004d5 <vprintfmt+0x1c7>
  8004e8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8004eb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8004ee:	85 d2                	test   %edx,%edx
  8004f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f5:	0f 49 c2             	cmovns %edx,%eax
  8004f8:	29 c2                	sub    %eax,%edx
  8004fa:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8004fd:	89 d7                	mov    %edx,%edi
  8004ff:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800502:	eb 50                	jmp    800554 <vprintfmt+0x246>
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
  800504:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800508:	74 1e                	je     800528 <vprintfmt+0x21a>
  80050a:	0f be d2             	movsbl %dl,%edx
  80050d:	83 ea 20             	sub    $0x20,%edx
  800510:	83 fa 5e             	cmp    $0x5e,%edx
  800513:	76 13                	jbe    800528 <vprintfmt+0x21a>
						putch('?', putdat);
  800515:	8b 45 0c             	mov    0xc(%ebp),%eax
  800518:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800523:	ff 55 08             	call   *0x8(%ebp)
  800526:	eb 0d                	jmp    800535 <vprintfmt+0x227>
					else
						putch(ch, putdat);
  800528:	8b 55 0c             	mov    0xc(%ebp),%edx
  80052b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80052f:	89 04 24             	mov    %eax,(%esp)
  800532:	ff 55 08             	call   *0x8(%ebp)
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800535:	83 ef 01             	sub    $0x1,%edi
  800538:	eb 1a                	jmp    800554 <vprintfmt+0x246>
  80053a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80053d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800540:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800543:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800546:	eb 0c                	jmp    800554 <vprintfmt+0x246>
  800548:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80054b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80054e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800551:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800554:	83 c6 01             	add    $0x1,%esi
  800557:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80055b:	0f be c2             	movsbl %dl,%eax
  80055e:	85 c0                	test   %eax,%eax
  800560:	74 27                	je     800589 <vprintfmt+0x27b>
  800562:	85 db                	test   %ebx,%ebx
  800564:	78 9e                	js     800504 <vprintfmt+0x1f6>
  800566:	83 eb 01             	sub    $0x1,%ebx
  800569:	79 99                	jns    800504 <vprintfmt+0x1f6>
  80056b:	89 f8                	mov    %edi,%eax
  80056d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800570:	8b 75 08             	mov    0x8(%ebp),%esi
  800573:	89 c3                	mov    %eax,%ebx
  800575:	eb 1a                	jmp    800591 <vprintfmt+0x283>
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
					putch(' ', putdat);
  800577:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80057b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800582:	ff d6                	call   *%esi
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
  800584:	83 eb 01             	sub    $0x1,%ebx
  800587:	eb 08                	jmp    800591 <vprintfmt+0x283>
  800589:	89 fb                	mov    %edi,%ebx
  80058b:	8b 75 08             	mov    0x8(%ebp),%esi
  80058e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800591:	85 db                	test   %ebx,%ebx
  800593:	7f e2                	jg     800577 <vprintfmt+0x269>
  800595:	89 75 08             	mov    %esi,0x8(%ebp)
  800598:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80059b:	e9 93 fd ff ff       	jmp    800333 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a0:	83 fa 01             	cmp    $0x1,%edx
  8005a3:	7e 16                	jle    8005bb <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 50 08             	lea    0x8(%eax),%edx
  8005ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ae:	8b 50 04             	mov    0x4(%eax),%edx
  8005b1:	8b 00                	mov    (%eax),%eax
  8005b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005b9:	eb 32                	jmp    8005ed <vprintfmt+0x2df>
	else if (lflag)
  8005bb:	85 d2                	test   %edx,%edx
  8005bd:	74 18                	je     8005d7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8d 50 04             	lea    0x4(%eax),%edx
  8005c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c8:	8b 30                	mov    (%eax),%esi
  8005ca:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005cd:	89 f0                	mov    %esi,%eax
  8005cf:	c1 f8 1f             	sar    $0x1f,%eax
  8005d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005d5:	eb 16                	jmp    8005ed <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 50 04             	lea    0x4(%eax),%edx
  8005dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e0:	8b 30                	mov    (%eax),%esi
  8005e2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005e5:	89 f0                	mov    %esi,%eax
  8005e7:	c1 f8 1f             	sar    $0x1f,%eax
  8005ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(' ', putdat);
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
  8005ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
				if ((long long) num < 0) {
					putch('-', putdat);
					num = -(long long) num;
				}
				base = 10;
  8005f3:	b9 0a 00 00 00       	mov    $0xa,%ecx
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
				if ((long long) num < 0) {
  8005f8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005fc:	0f 89 80 00 00 00    	jns    800682 <vprintfmt+0x374>
					putch('-', putdat);
  800602:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800606:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80060d:	ff 55 08             	call   *0x8(%ebp)
					num = -(long long) num;
  800610:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800613:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800616:	f7 d8                	neg    %eax
  800618:	83 d2 00             	adc    $0x0,%edx
  80061b:	f7 da                	neg    %edx
				}
				base = 10;
  80061d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800622:	eb 5e                	jmp    800682 <vprintfmt+0x374>
				goto number;

			// unsigned decimal
			case 'u':
				num = getuint(&ap, lflag);
  800624:	8d 45 14             	lea    0x14(%ebp),%eax
  800627:	e8 63 fc ff ff       	call   80028f <getuint>
				base = 10;
  80062c:	b9 0a 00 00 00       	mov    $0xa,%ecx
				goto number;
  800631:	eb 4f                	jmp    800682 <vprintfmt+0x374>
				// Replace this with your code.
				/*putch('X', putdat);
				putch('X', putdat);
				putch('X', putdat);*/
				
				num = getuint(&ap, lflag);
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	e8 54 fc ff ff       	call   80028f <getuint>
				base = 8;
  80063b:	b9 08 00 00 00       	mov    $0x8,%ecx
				goto number;
  800640:	eb 40                	jmp    800682 <vprintfmt+0x374>

			// pointer
			case 'p':
				putch('0', putdat);
  800642:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800646:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80064d:	ff 55 08             	call   *0x8(%ebp)
				putch('x', putdat);
  800650:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800654:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80065b:	ff 55 08             	call   *0x8(%ebp)
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)

			// pointer
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	ba 00 00 00 00       	mov    $0x0,%edx
					(uintptr_t) va_arg(ap, void *);
				base = 16;
  80066e:	b9 10 00 00 00       	mov    $0x10,%ecx
				goto number;
  800673:	eb 0d                	jmp    800682 <vprintfmt+0x374>

			// (unsigned) hexadecimal
			case 'x':
				num = getuint(&ap, lflag);
  800675:	8d 45 14             	lea    0x14(%ebp),%eax
  800678:	e8 12 fc ff ff       	call   80028f <getuint>
				base = 16;
  80067d:	b9 10 00 00 00       	mov    $0x10,%ecx
			number:
				printnum(putch, putdat, num, base, width, padc);
  800682:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800686:	89 74 24 10          	mov    %esi,0x10(%esp)
  80068a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80068d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800691:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800695:	89 04 24             	mov    %eax,(%esp)
  800698:	89 54 24 04          	mov    %edx,0x4(%esp)
  80069c:	89 fa                	mov    %edi,%edx
  80069e:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a1:	e8 fa fa ff ff       	call   8001a0 <printnum>
				break;
  8006a6:	e9 88 fc ff ff       	jmp    800333 <vprintfmt+0x25>

			// escaped '%' character
			case '%':
				putch(ch, putdat);
  8006ab:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006af:	89 04 24             	mov    %eax,(%esp)
  8006b2:	ff 55 08             	call   *0x8(%ebp)
				break;
  8006b5:	e9 79 fc ff ff       	jmp    800333 <vprintfmt+0x25>

			// unrecognized escape sequence - just print it literally
			default:
				putch('%', putdat);
  8006ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006be:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006c5:	ff 55 08             	call   *0x8(%ebp)
				for (fmt--; fmt[-1] != '%'; fmt--)
  8006c8:	89 f3                	mov    %esi,%ebx
  8006ca:	eb 03                	jmp    8006cf <vprintfmt+0x3c1>
  8006cc:	83 eb 01             	sub    $0x1,%ebx
  8006cf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8006d3:	75 f7                	jne    8006cc <vprintfmt+0x3be>
  8006d5:	e9 59 fc ff ff       	jmp    800333 <vprintfmt+0x25>
					/* do nothing */;
				break;
		}
	}
}
  8006da:	83 c4 3c             	add    $0x3c,%esp
  8006dd:	5b                   	pop    %ebx
  8006de:	5e                   	pop    %esi
  8006df:	5f                   	pop    %edi
  8006e0:	5d                   	pop    %ebp
  8006e1:	c3                   	ret    

008006e2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	83 ec 28             	sub    $0x28,%esp
  8006e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ff:	85 c0                	test   %eax,%eax
  800701:	74 30                	je     800733 <vsnprintf+0x51>
  800703:	85 d2                	test   %edx,%edx
  800705:	7e 2c                	jle    800733 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80070e:	8b 45 10             	mov    0x10(%ebp),%eax
  800711:	89 44 24 08          	mov    %eax,0x8(%esp)
  800715:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800718:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071c:	c7 04 24 c9 02 80 00 	movl   $0x8002c9,(%esp)
  800723:	e8 e6 fb ff ff       	call   80030e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800728:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800731:	eb 05                	jmp    800738 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800733:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800738:	c9                   	leave  
  800739:	c3                   	ret    

0080073a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800740:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800743:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800747:	8b 45 10             	mov    0x10(%ebp),%eax
  80074a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80074e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800751:	89 44 24 04          	mov    %eax,0x4(%esp)
  800755:	8b 45 08             	mov    0x8(%ebp),%eax
  800758:	89 04 24             	mov    %eax,(%esp)
  80075b:	e8 82 ff ff ff       	call   8006e2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800760:	c9                   	leave  
  800761:	c3                   	ret    
  800762:	66 90                	xchg   %ax,%ax
  800764:	66 90                	xchg   %ax,%ax
  800766:	66 90                	xchg   %ax,%ax
  800768:	66 90                	xchg   %ax,%ax
  80076a:	66 90                	xchg   %ax,%ax
  80076c:	66 90                	xchg   %ax,%ax
  80076e:	66 90                	xchg   %ax,%ax

00800770 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800776:	b8 00 00 00 00       	mov    $0x0,%eax
  80077b:	eb 03                	jmp    800780 <strlen+0x10>
		n++;
  80077d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800780:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800784:	75 f7                	jne    80077d <strlen+0xd>
		n++;
	return n;
}
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800791:	b8 00 00 00 00       	mov    $0x0,%eax
  800796:	eb 03                	jmp    80079b <strnlen+0x13>
		n++;
  800798:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079b:	39 d0                	cmp    %edx,%eax
  80079d:	74 06                	je     8007a5 <strnlen+0x1d>
  80079f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a3:	75 f3                	jne    800798 <strnlen+0x10>
		n++;
	return n;
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b1:	89 c2                	mov    %eax,%edx
  8007b3:	83 c2 01             	add    $0x1,%edx
  8007b6:	83 c1 01             	add    $0x1,%ecx
  8007b9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007bd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c0:	84 db                	test   %bl,%bl
  8007c2:	75 ef                	jne    8007b3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c4:	5b                   	pop    %ebx
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	53                   	push   %ebx
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d1:	89 1c 24             	mov    %ebx,(%esp)
  8007d4:	e8 97 ff ff ff       	call   800770 <strlen>
	strcpy(dst + len, src);
  8007d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e0:	01 d8                	add    %ebx,%eax
  8007e2:	89 04 24             	mov    %eax,(%esp)
  8007e5:	e8 bd ff ff ff       	call   8007a7 <strcpy>
	return dst;
}
  8007ea:	89 d8                	mov    %ebx,%eax
  8007ec:	83 c4 08             	add    $0x8,%esp
  8007ef:	5b                   	pop    %ebx
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	56                   	push   %esi
  8007f6:	53                   	push   %ebx
  8007f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fd:	89 f3                	mov    %esi,%ebx
  8007ff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800802:	89 f2                	mov    %esi,%edx
  800804:	eb 0f                	jmp    800815 <strncpy+0x23>
		*dst++ = *src;
  800806:	83 c2 01             	add    $0x1,%edx
  800809:	0f b6 01             	movzbl (%ecx),%eax
  80080c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080f:	80 39 01             	cmpb   $0x1,(%ecx)
  800812:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800815:	39 da                	cmp    %ebx,%edx
  800817:	75 ed                	jne    800806 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800819:	89 f0                	mov    %esi,%eax
  80081b:	5b                   	pop    %ebx
  80081c:	5e                   	pop    %esi
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	56                   	push   %esi
  800823:	53                   	push   %ebx
  800824:	8b 75 08             	mov    0x8(%ebp),%esi
  800827:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80082d:	89 f0                	mov    %esi,%eax
  80082f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800833:	85 c9                	test   %ecx,%ecx
  800835:	75 0b                	jne    800842 <strlcpy+0x23>
  800837:	eb 1d                	jmp    800856 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800839:	83 c0 01             	add    $0x1,%eax
  80083c:	83 c2 01             	add    $0x1,%edx
  80083f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800842:	39 d8                	cmp    %ebx,%eax
  800844:	74 0b                	je     800851 <strlcpy+0x32>
  800846:	0f b6 0a             	movzbl (%edx),%ecx
  800849:	84 c9                	test   %cl,%cl
  80084b:	75 ec                	jne    800839 <strlcpy+0x1a>
  80084d:	89 c2                	mov    %eax,%edx
  80084f:	eb 02                	jmp    800853 <strlcpy+0x34>
  800851:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800853:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800856:	29 f0                	sub    %esi,%eax
}
  800858:	5b                   	pop    %ebx
  800859:	5e                   	pop    %esi
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800862:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800865:	eb 06                	jmp    80086d <strcmp+0x11>
		p++, q++;
  800867:	83 c1 01             	add    $0x1,%ecx
  80086a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80086d:	0f b6 01             	movzbl (%ecx),%eax
  800870:	84 c0                	test   %al,%al
  800872:	74 04                	je     800878 <strcmp+0x1c>
  800874:	3a 02                	cmp    (%edx),%al
  800876:	74 ef                	je     800867 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800878:	0f b6 c0             	movzbl %al,%eax
  80087b:	0f b6 12             	movzbl (%edx),%edx
  80087e:	29 d0                	sub    %edx,%eax
}
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	53                   	push   %ebx
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088c:	89 c3                	mov    %eax,%ebx
  80088e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800891:	eb 06                	jmp    800899 <strncmp+0x17>
		n--, p++, q++;
  800893:	83 c0 01             	add    $0x1,%eax
  800896:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800899:	39 d8                	cmp    %ebx,%eax
  80089b:	74 15                	je     8008b2 <strncmp+0x30>
  80089d:	0f b6 08             	movzbl (%eax),%ecx
  8008a0:	84 c9                	test   %cl,%cl
  8008a2:	74 04                	je     8008a8 <strncmp+0x26>
  8008a4:	3a 0a                	cmp    (%edx),%cl
  8008a6:	74 eb                	je     800893 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a8:	0f b6 00             	movzbl (%eax),%eax
  8008ab:	0f b6 12             	movzbl (%edx),%edx
  8008ae:	29 d0                	sub    %edx,%eax
  8008b0:	eb 05                	jmp    8008b7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b7:	5b                   	pop    %ebx
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c4:	eb 07                	jmp    8008cd <strchr+0x13>
		if (*s == c)
  8008c6:	38 ca                	cmp    %cl,%dl
  8008c8:	74 0f                	je     8008d9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ca:	83 c0 01             	add    $0x1,%eax
  8008cd:	0f b6 10             	movzbl (%eax),%edx
  8008d0:	84 d2                	test   %dl,%dl
  8008d2:	75 f2                	jne    8008c6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e5:	eb 07                	jmp    8008ee <strfind+0x13>
		if (*s == c)
  8008e7:	38 ca                	cmp    %cl,%dl
  8008e9:	74 0a                	je     8008f5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008eb:	83 c0 01             	add    $0x1,%eax
  8008ee:	0f b6 10             	movzbl (%eax),%edx
  8008f1:	84 d2                	test   %dl,%dl
  8008f3:	75 f2                	jne    8008e7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	57                   	push   %edi
  8008fb:	56                   	push   %esi
  8008fc:	53                   	push   %ebx
  8008fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800900:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800903:	85 c9                	test   %ecx,%ecx
  800905:	74 36                	je     80093d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800907:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80090d:	75 28                	jne    800937 <memset+0x40>
  80090f:	f6 c1 03             	test   $0x3,%cl
  800912:	75 23                	jne    800937 <memset+0x40>
		c &= 0xFF;
  800914:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800918:	89 d3                	mov    %edx,%ebx
  80091a:	c1 e3 08             	shl    $0x8,%ebx
  80091d:	89 d6                	mov    %edx,%esi
  80091f:	c1 e6 18             	shl    $0x18,%esi
  800922:	89 d0                	mov    %edx,%eax
  800924:	c1 e0 10             	shl    $0x10,%eax
  800927:	09 f0                	or     %esi,%eax
  800929:	09 c2                	or     %eax,%edx
  80092b:	89 d0                	mov    %edx,%eax
  80092d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80092f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800932:	fc                   	cld    
  800933:	f3 ab                	rep stos %eax,%es:(%edi)
  800935:	eb 06                	jmp    80093d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800937:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093a:	fc                   	cld    
  80093b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80093d:	89 f8                	mov    %edi,%eax
  80093f:	5b                   	pop    %ebx
  800940:	5e                   	pop    %esi
  800941:	5f                   	pop    %edi
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	57                   	push   %edi
  800948:	56                   	push   %esi
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80094f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800952:	39 c6                	cmp    %eax,%esi
  800954:	73 35                	jae    80098b <memmove+0x47>
  800956:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800959:	39 d0                	cmp    %edx,%eax
  80095b:	73 2e                	jae    80098b <memmove+0x47>
		s += n;
		d += n;
  80095d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800960:	89 d6                	mov    %edx,%esi
  800962:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800964:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096a:	75 13                	jne    80097f <memmove+0x3b>
  80096c:	f6 c1 03             	test   $0x3,%cl
  80096f:	75 0e                	jne    80097f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800971:	83 ef 04             	sub    $0x4,%edi
  800974:	8d 72 fc             	lea    -0x4(%edx),%esi
  800977:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80097a:	fd                   	std    
  80097b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097d:	eb 09                	jmp    800988 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80097f:	83 ef 01             	sub    $0x1,%edi
  800982:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800985:	fd                   	std    
  800986:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800988:	fc                   	cld    
  800989:	eb 1d                	jmp    8009a8 <memmove+0x64>
  80098b:	89 f2                	mov    %esi,%edx
  80098d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098f:	f6 c2 03             	test   $0x3,%dl
  800992:	75 0f                	jne    8009a3 <memmove+0x5f>
  800994:	f6 c1 03             	test   $0x3,%cl
  800997:	75 0a                	jne    8009a3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800999:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80099c:	89 c7                	mov    %eax,%edi
  80099e:	fc                   	cld    
  80099f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a1:	eb 05                	jmp    8009a8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a3:	89 c7                	mov    %eax,%edi
  8009a5:	fc                   	cld    
  8009a6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a8:	5e                   	pop    %esi
  8009a9:	5f                   	pop    %edi
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	89 04 24             	mov    %eax,(%esp)
  8009c6:	e8 79 ff ff ff       	call   800944 <memmove>
}
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	56                   	push   %esi
  8009d1:	53                   	push   %ebx
  8009d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d8:	89 d6                	mov    %edx,%esi
  8009da:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009dd:	eb 1a                	jmp    8009f9 <memcmp+0x2c>
		if (*s1 != *s2)
  8009df:	0f b6 02             	movzbl (%edx),%eax
  8009e2:	0f b6 19             	movzbl (%ecx),%ebx
  8009e5:	38 d8                	cmp    %bl,%al
  8009e7:	74 0a                	je     8009f3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e9:	0f b6 c0             	movzbl %al,%eax
  8009ec:	0f b6 db             	movzbl %bl,%ebx
  8009ef:	29 d8                	sub    %ebx,%eax
  8009f1:	eb 0f                	jmp    800a02 <memcmp+0x35>
		s1++, s2++;
  8009f3:	83 c2 01             	add    $0x1,%edx
  8009f6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f9:	39 f2                	cmp    %esi,%edx
  8009fb:	75 e2                	jne    8009df <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a02:	5b                   	pop    %ebx
  800a03:	5e                   	pop    %esi
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a0f:	89 c2                	mov    %eax,%edx
  800a11:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a14:	eb 07                	jmp    800a1d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a16:	38 08                	cmp    %cl,(%eax)
  800a18:	74 07                	je     800a21 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	39 d0                	cmp    %edx,%eax
  800a1f:	72 f5                	jb     800a16 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	57                   	push   %edi
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
  800a29:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2f:	eb 03                	jmp    800a34 <strtol+0x11>
		s++;
  800a31:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a34:	0f b6 0a             	movzbl (%edx),%ecx
  800a37:	80 f9 09             	cmp    $0x9,%cl
  800a3a:	74 f5                	je     800a31 <strtol+0xe>
  800a3c:	80 f9 20             	cmp    $0x20,%cl
  800a3f:	74 f0                	je     800a31 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a41:	80 f9 2b             	cmp    $0x2b,%cl
  800a44:	75 0a                	jne    800a50 <strtol+0x2d>
		s++;
  800a46:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4e:	eb 11                	jmp    800a61 <strtol+0x3e>
  800a50:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a55:	80 f9 2d             	cmp    $0x2d,%cl
  800a58:	75 07                	jne    800a61 <strtol+0x3e>
		s++, neg = 1;
  800a5a:	8d 52 01             	lea    0x1(%edx),%edx
  800a5d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a61:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800a66:	75 15                	jne    800a7d <strtol+0x5a>
  800a68:	80 3a 30             	cmpb   $0x30,(%edx)
  800a6b:	75 10                	jne    800a7d <strtol+0x5a>
  800a6d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a71:	75 0a                	jne    800a7d <strtol+0x5a>
		s += 2, base = 16;
  800a73:	83 c2 02             	add    $0x2,%edx
  800a76:	b8 10 00 00 00       	mov    $0x10,%eax
  800a7b:	eb 10                	jmp    800a8d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800a7d:	85 c0                	test   %eax,%eax
  800a7f:	75 0c                	jne    800a8d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a81:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a83:	80 3a 30             	cmpb   $0x30,(%edx)
  800a86:	75 05                	jne    800a8d <strtol+0x6a>
		s++, base = 8;
  800a88:	83 c2 01             	add    $0x1,%edx
  800a8b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800a8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a92:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a95:	0f b6 0a             	movzbl (%edx),%ecx
  800a98:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800a9b:	89 f0                	mov    %esi,%eax
  800a9d:	3c 09                	cmp    $0x9,%al
  800a9f:	77 08                	ja     800aa9 <strtol+0x86>
			dig = *s - '0';
  800aa1:	0f be c9             	movsbl %cl,%ecx
  800aa4:	83 e9 30             	sub    $0x30,%ecx
  800aa7:	eb 20                	jmp    800ac9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800aa9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800aac:	89 f0                	mov    %esi,%eax
  800aae:	3c 19                	cmp    $0x19,%al
  800ab0:	77 08                	ja     800aba <strtol+0x97>
			dig = *s - 'a' + 10;
  800ab2:	0f be c9             	movsbl %cl,%ecx
  800ab5:	83 e9 57             	sub    $0x57,%ecx
  800ab8:	eb 0f                	jmp    800ac9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800aba:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800abd:	89 f0                	mov    %esi,%eax
  800abf:	3c 19                	cmp    $0x19,%al
  800ac1:	77 16                	ja     800ad9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800ac3:	0f be c9             	movsbl %cl,%ecx
  800ac6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ac9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800acc:	7d 0f                	jge    800add <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800ace:	83 c2 01             	add    $0x1,%edx
  800ad1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800ad5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800ad7:	eb bc                	jmp    800a95 <strtol+0x72>
  800ad9:	89 d8                	mov    %ebx,%eax
  800adb:	eb 02                	jmp    800adf <strtol+0xbc>
  800add:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800adf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae3:	74 05                	je     800aea <strtol+0xc7>
		*endptr = (char *) s;
  800ae5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800aea:	f7 d8                	neg    %eax
  800aec:	85 ff                	test   %edi,%edi
  800aee:	0f 44 c3             	cmove  %ebx,%eax
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5f                   	pop    %edi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	57                   	push   %edi
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afc:	b8 00 00 00 00       	mov    $0x0,%eax
  800b01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b04:	8b 55 08             	mov    0x8(%ebp),%edx
  800b07:	89 c3                	mov    %eax,%ebx
  800b09:	89 c7                	mov    %eax,%edi
  800b0b:	89 c6                	mov    %eax,%esi
  800b0d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b24:	89 d1                	mov    %edx,%ecx
  800b26:	89 d3                	mov    %edx,%ebx
  800b28:	89 d7                	mov    %edx,%edi
  800b2a:	89 d6                	mov    %edx,%esi
  800b2c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5f                   	pop    %edi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
  800b39:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b41:	b8 03 00 00 00       	mov    $0x3,%eax
  800b46:	8b 55 08             	mov    0x8(%ebp),%edx
  800b49:	89 cb                	mov    %ecx,%ebx
  800b4b:	89 cf                	mov    %ecx,%edi
  800b4d:	89 ce                	mov    %ecx,%esi
  800b4f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b51:	85 c0                	test   %eax,%eax
  800b53:	7e 28                	jle    800b7d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b59:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b60:	00 
  800b61:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800b68:	00 
  800b69:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b70:	00 
  800b71:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800b78:	e8 5b 02 00 00       	call   800dd8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7d:	83 c4 2c             	add    $0x2c,%esp
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b90:	b8 02 00 00 00       	mov    $0x2,%eax
  800b95:	89 d1                	mov    %edx,%ecx
  800b97:	89 d3                	mov    %edx,%ebx
  800b99:	89 d7                	mov    %edx,%edi
  800b9b:	89 d6                	mov    %edx,%esi
  800b9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_yield>:

void
sys_yield(void)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baa:	ba 00 00 00 00       	mov    $0x0,%edx
  800baf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bb4:	89 d1                	mov    %edx,%ecx
  800bb6:	89 d3                	mov    %edx,%ebx
  800bb8:	89 d7                	mov    %edx,%edi
  800bba:	89 d6                	mov    %edx,%esi
  800bbc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bbe:	5b                   	pop    %ebx
  800bbf:	5e                   	pop    %esi
  800bc0:	5f                   	pop    %edi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcc:	be 00 00 00 00       	mov    $0x0,%esi
  800bd1:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdf:	89 f7                	mov    %esi,%edi
  800be1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be3:	85 c0                	test   %eax,%eax
  800be5:	7e 28                	jle    800c0f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800beb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bf2:	00 
  800bf3:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800bfa:	00 
  800bfb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c02:	00 
  800c03:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800c0a:	e8 c9 01 00 00       	call   800dd8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c0f:	83 c4 2c             	add    $0x2c,%esp
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
  800c1d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c20:	b8 05 00 00 00       	mov    $0x5,%eax
  800c25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c28:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c31:	8b 75 18             	mov    0x18(%ebp),%esi
  800c34:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c36:	85 c0                	test   %eax,%eax
  800c38:	7e 28                	jle    800c62 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c3e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c45:	00 
  800c46:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800c4d:	00 
  800c4e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c55:	00 
  800c56:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800c5d:	e8 76 01 00 00       	call   800dd8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c62:	83 c4 2c             	add    $0x2c,%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c78:	b8 06 00 00 00       	mov    $0x6,%eax
  800c7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c80:	8b 55 08             	mov    0x8(%ebp),%edx
  800c83:	89 df                	mov    %ebx,%edi
  800c85:	89 de                	mov    %ebx,%esi
  800c87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	7e 28                	jle    800cb5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c91:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c98:	00 
  800c99:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800ca0:	00 
  800ca1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca8:	00 
  800ca9:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800cb0:	e8 23 01 00 00       	call   800dd8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb5:	83 c4 2c             	add    $0x2c,%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccb:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd6:	89 df                	mov    %ebx,%edi
  800cd8:	89 de                	mov    %ebx,%esi
  800cda:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	7e 28                	jle    800d08 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ceb:	00 
  800cec:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800cf3:	00 
  800cf4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfb:	00 
  800cfc:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800d03:	e8 d0 00 00 00       	call   800dd8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d08:	83 c4 2c             	add    $0x2c,%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	57                   	push   %edi
  800d14:	56                   	push   %esi
  800d15:	53                   	push   %ebx
  800d16:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1e:	b8 09 00 00 00       	mov    $0x9,%eax
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	89 df                	mov    %ebx,%edi
  800d2b:	89 de                	mov    %ebx,%esi
  800d2d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2f:	85 c0                	test   %eax,%eax
  800d31:	7e 28                	jle    800d5b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d37:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d3e:	00 
  800d3f:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800d46:	00 
  800d47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4e:	00 
  800d4f:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800d56:	e8 7d 00 00 00       	call   800dd8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d5b:	83 c4 2c             	add    $0x2c,%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	57                   	push   %edi
  800d67:	56                   	push   %esi
  800d68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d69:	be 00 00 00 00       	mov    $0x0,%esi
  800d6e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d94:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	89 cb                	mov    %ecx,%ebx
  800d9e:	89 cf                	mov    %ecx,%edi
  800da0:	89 ce                	mov    %ecx,%esi
  800da2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da4:	85 c0                	test   %eax,%eax
  800da6:	7e 28                	jle    800dd0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dac:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800db3:	00 
  800db4:	c7 44 24 08 28 13 80 	movl   $0x801328,0x8(%esp)
  800dbb:	00 
  800dbc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc3:	00 
  800dc4:	c7 04 24 45 13 80 00 	movl   $0x801345,(%esp)
  800dcb:	e8 08 00 00 00       	call   800dd8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dd0:	83 c4 2c             	add    $0x2c,%esp
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	56                   	push   %esi
  800ddc:	53                   	push   %ebx
  800ddd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800de0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800de3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800de9:	e8 97 fd ff ff       	call   800b85 <sys_getenvid>
  800dee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800df1:	89 54 24 10          	mov    %edx,0x10(%esp)
  800df5:	8b 55 08             	mov    0x8(%ebp),%edx
  800df8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dfc:	89 74 24 08          	mov    %esi,0x8(%esp)
  800e00:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e04:	c7 04 24 54 13 80 00 	movl   $0x801354,(%esp)
  800e0b:	e8 67 f3 ff ff       	call   800177 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e10:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e14:	8b 45 10             	mov    0x10(%ebp),%eax
  800e17:	89 04 24             	mov    %eax,(%esp)
  800e1a:	e8 f7 f2 ff ff       	call   800116 <vcprintf>
	cprintf("\n");
  800e1f:	c7 04 24 cc 10 80 00 	movl   $0x8010cc,(%esp)
  800e26:	e8 4c f3 ff ff       	call   800177 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e2b:	cc                   	int3   
  800e2c:	eb fd                	jmp    800e2b <_panic+0x53>
  800e2e:	66 90                	xchg   %ax,%ax

00800e30 <__udivdi3>:
  800e30:	55                   	push   %ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	83 ec 0c             	sub    $0xc,%esp
  800e36:	8b 44 24 28          	mov    0x28(%esp),%eax
  800e3a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800e3e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800e42:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800e46:	85 c0                	test   %eax,%eax
  800e48:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e4c:	89 ea                	mov    %ebp,%edx
  800e4e:	89 0c 24             	mov    %ecx,(%esp)
  800e51:	75 2d                	jne    800e80 <__udivdi3+0x50>
  800e53:	39 e9                	cmp    %ebp,%ecx
  800e55:	77 61                	ja     800eb8 <__udivdi3+0x88>
  800e57:	85 c9                	test   %ecx,%ecx
  800e59:	89 ce                	mov    %ecx,%esi
  800e5b:	75 0b                	jne    800e68 <__udivdi3+0x38>
  800e5d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e62:	31 d2                	xor    %edx,%edx
  800e64:	f7 f1                	div    %ecx
  800e66:	89 c6                	mov    %eax,%esi
  800e68:	31 d2                	xor    %edx,%edx
  800e6a:	89 e8                	mov    %ebp,%eax
  800e6c:	f7 f6                	div    %esi
  800e6e:	89 c5                	mov    %eax,%ebp
  800e70:	89 f8                	mov    %edi,%eax
  800e72:	f7 f6                	div    %esi
  800e74:	89 ea                	mov    %ebp,%edx
  800e76:	83 c4 0c             	add    $0xc,%esp
  800e79:	5e                   	pop    %esi
  800e7a:	5f                   	pop    %edi
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    
  800e7d:	8d 76 00             	lea    0x0(%esi),%esi
  800e80:	39 e8                	cmp    %ebp,%eax
  800e82:	77 24                	ja     800ea8 <__udivdi3+0x78>
  800e84:	0f bd e8             	bsr    %eax,%ebp
  800e87:	83 f5 1f             	xor    $0x1f,%ebp
  800e8a:	75 3c                	jne    800ec8 <__udivdi3+0x98>
  800e8c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e90:	39 34 24             	cmp    %esi,(%esp)
  800e93:	0f 86 9f 00 00 00    	jbe    800f38 <__udivdi3+0x108>
  800e99:	39 d0                	cmp    %edx,%eax
  800e9b:	0f 82 97 00 00 00    	jb     800f38 <__udivdi3+0x108>
  800ea1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea8:	31 d2                	xor    %edx,%edx
  800eaa:	31 c0                	xor    %eax,%eax
  800eac:	83 c4 0c             	add    $0xc,%esp
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    
  800eb3:	90                   	nop
  800eb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800eb8:	89 f8                	mov    %edi,%eax
  800eba:	f7 f1                	div    %ecx
  800ebc:	31 d2                	xor    %edx,%edx
  800ebe:	83 c4 0c             	add    $0xc,%esp
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    
  800ec5:	8d 76 00             	lea    0x0(%esi),%esi
  800ec8:	89 e9                	mov    %ebp,%ecx
  800eca:	8b 3c 24             	mov    (%esp),%edi
  800ecd:	d3 e0                	shl    %cl,%eax
  800ecf:	89 c6                	mov    %eax,%esi
  800ed1:	b8 20 00 00 00       	mov    $0x20,%eax
  800ed6:	29 e8                	sub    %ebp,%eax
  800ed8:	89 c1                	mov    %eax,%ecx
  800eda:	d3 ef                	shr    %cl,%edi
  800edc:	89 e9                	mov    %ebp,%ecx
  800ede:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ee2:	8b 3c 24             	mov    (%esp),%edi
  800ee5:	09 74 24 08          	or     %esi,0x8(%esp)
  800ee9:	89 d6                	mov    %edx,%esi
  800eeb:	d3 e7                	shl    %cl,%edi
  800eed:	89 c1                	mov    %eax,%ecx
  800eef:	89 3c 24             	mov    %edi,(%esp)
  800ef2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ef6:	d3 ee                	shr    %cl,%esi
  800ef8:	89 e9                	mov    %ebp,%ecx
  800efa:	d3 e2                	shl    %cl,%edx
  800efc:	89 c1                	mov    %eax,%ecx
  800efe:	d3 ef                	shr    %cl,%edi
  800f00:	09 d7                	or     %edx,%edi
  800f02:	89 f2                	mov    %esi,%edx
  800f04:	89 f8                	mov    %edi,%eax
  800f06:	f7 74 24 08          	divl   0x8(%esp)
  800f0a:	89 d6                	mov    %edx,%esi
  800f0c:	89 c7                	mov    %eax,%edi
  800f0e:	f7 24 24             	mull   (%esp)
  800f11:	39 d6                	cmp    %edx,%esi
  800f13:	89 14 24             	mov    %edx,(%esp)
  800f16:	72 30                	jb     800f48 <__udivdi3+0x118>
  800f18:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f1c:	89 e9                	mov    %ebp,%ecx
  800f1e:	d3 e2                	shl    %cl,%edx
  800f20:	39 c2                	cmp    %eax,%edx
  800f22:	73 05                	jae    800f29 <__udivdi3+0xf9>
  800f24:	3b 34 24             	cmp    (%esp),%esi
  800f27:	74 1f                	je     800f48 <__udivdi3+0x118>
  800f29:	89 f8                	mov    %edi,%eax
  800f2b:	31 d2                	xor    %edx,%edx
  800f2d:	e9 7a ff ff ff       	jmp    800eac <__udivdi3+0x7c>
  800f32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f38:	31 d2                	xor    %edx,%edx
  800f3a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3f:	e9 68 ff ff ff       	jmp    800eac <__udivdi3+0x7c>
  800f44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f48:	8d 47 ff             	lea    -0x1(%edi),%eax
  800f4b:	31 d2                	xor    %edx,%edx
  800f4d:	83 c4 0c             	add    $0xc,%esp
  800f50:	5e                   	pop    %esi
  800f51:	5f                   	pop    %edi
  800f52:	5d                   	pop    %ebp
  800f53:	c3                   	ret    
  800f54:	66 90                	xchg   %ax,%ax
  800f56:	66 90                	xchg   %ax,%ax
  800f58:	66 90                	xchg   %ax,%ax
  800f5a:	66 90                	xchg   %ax,%ax
  800f5c:	66 90                	xchg   %ax,%ax
  800f5e:	66 90                	xchg   %ax,%ax

00800f60 <__umoddi3>:
  800f60:	55                   	push   %ebp
  800f61:	57                   	push   %edi
  800f62:	56                   	push   %esi
  800f63:	83 ec 14             	sub    $0x14,%esp
  800f66:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f6a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f6e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  800f72:	89 c7                	mov    %eax,%edi
  800f74:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f78:	8b 44 24 30          	mov    0x30(%esp),%eax
  800f7c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800f80:	89 34 24             	mov    %esi,(%esp)
  800f83:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f87:	85 c0                	test   %eax,%eax
  800f89:	89 c2                	mov    %eax,%edx
  800f8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f8f:	75 17                	jne    800fa8 <__umoddi3+0x48>
  800f91:	39 fe                	cmp    %edi,%esi
  800f93:	76 4b                	jbe    800fe0 <__umoddi3+0x80>
  800f95:	89 c8                	mov    %ecx,%eax
  800f97:	89 fa                	mov    %edi,%edx
  800f99:	f7 f6                	div    %esi
  800f9b:	89 d0                	mov    %edx,%eax
  800f9d:	31 d2                	xor    %edx,%edx
  800f9f:	83 c4 14             	add    $0x14,%esp
  800fa2:	5e                   	pop    %esi
  800fa3:	5f                   	pop    %edi
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    
  800fa6:	66 90                	xchg   %ax,%ax
  800fa8:	39 f8                	cmp    %edi,%eax
  800faa:	77 54                	ja     801000 <__umoddi3+0xa0>
  800fac:	0f bd e8             	bsr    %eax,%ebp
  800faf:	83 f5 1f             	xor    $0x1f,%ebp
  800fb2:	75 5c                	jne    801010 <__umoddi3+0xb0>
  800fb4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fb8:	39 3c 24             	cmp    %edi,(%esp)
  800fbb:	0f 87 e7 00 00 00    	ja     8010a8 <__umoddi3+0x148>
  800fc1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fc5:	29 f1                	sub    %esi,%ecx
  800fc7:	19 c7                	sbb    %eax,%edi
  800fc9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fcd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fd1:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fd5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fd9:	83 c4 14             	add    $0x14,%esp
  800fdc:	5e                   	pop    %esi
  800fdd:	5f                   	pop    %edi
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    
  800fe0:	85 f6                	test   %esi,%esi
  800fe2:	89 f5                	mov    %esi,%ebp
  800fe4:	75 0b                	jne    800ff1 <__umoddi3+0x91>
  800fe6:	b8 01 00 00 00       	mov    $0x1,%eax
  800feb:	31 d2                	xor    %edx,%edx
  800fed:	f7 f6                	div    %esi
  800fef:	89 c5                	mov    %eax,%ebp
  800ff1:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ff5:	31 d2                	xor    %edx,%edx
  800ff7:	f7 f5                	div    %ebp
  800ff9:	89 c8                	mov    %ecx,%eax
  800ffb:	f7 f5                	div    %ebp
  800ffd:	eb 9c                	jmp    800f9b <__umoddi3+0x3b>
  800fff:	90                   	nop
  801000:	89 c8                	mov    %ecx,%eax
  801002:	89 fa                	mov    %edi,%edx
  801004:	83 c4 14             	add    $0x14,%esp
  801007:	5e                   	pop    %esi
  801008:	5f                   	pop    %edi
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    
  80100b:	90                   	nop
  80100c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801010:	8b 04 24             	mov    (%esp),%eax
  801013:	be 20 00 00 00       	mov    $0x20,%esi
  801018:	89 e9                	mov    %ebp,%ecx
  80101a:	29 ee                	sub    %ebp,%esi
  80101c:	d3 e2                	shl    %cl,%edx
  80101e:	89 f1                	mov    %esi,%ecx
  801020:	d3 e8                	shr    %cl,%eax
  801022:	89 e9                	mov    %ebp,%ecx
  801024:	89 44 24 04          	mov    %eax,0x4(%esp)
  801028:	8b 04 24             	mov    (%esp),%eax
  80102b:	09 54 24 04          	or     %edx,0x4(%esp)
  80102f:	89 fa                	mov    %edi,%edx
  801031:	d3 e0                	shl    %cl,%eax
  801033:	89 f1                	mov    %esi,%ecx
  801035:	89 44 24 08          	mov    %eax,0x8(%esp)
  801039:	8b 44 24 10          	mov    0x10(%esp),%eax
  80103d:	d3 ea                	shr    %cl,%edx
  80103f:	89 e9                	mov    %ebp,%ecx
  801041:	d3 e7                	shl    %cl,%edi
  801043:	89 f1                	mov    %esi,%ecx
  801045:	d3 e8                	shr    %cl,%eax
  801047:	89 e9                	mov    %ebp,%ecx
  801049:	09 f8                	or     %edi,%eax
  80104b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80104f:	f7 74 24 04          	divl   0x4(%esp)
  801053:	d3 e7                	shl    %cl,%edi
  801055:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801059:	89 d7                	mov    %edx,%edi
  80105b:	f7 64 24 08          	mull   0x8(%esp)
  80105f:	39 d7                	cmp    %edx,%edi
  801061:	89 c1                	mov    %eax,%ecx
  801063:	89 14 24             	mov    %edx,(%esp)
  801066:	72 2c                	jb     801094 <__umoddi3+0x134>
  801068:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80106c:	72 22                	jb     801090 <__umoddi3+0x130>
  80106e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801072:	29 c8                	sub    %ecx,%eax
  801074:	19 d7                	sbb    %edx,%edi
  801076:	89 e9                	mov    %ebp,%ecx
  801078:	89 fa                	mov    %edi,%edx
  80107a:	d3 e8                	shr    %cl,%eax
  80107c:	89 f1                	mov    %esi,%ecx
  80107e:	d3 e2                	shl    %cl,%edx
  801080:	89 e9                	mov    %ebp,%ecx
  801082:	d3 ef                	shr    %cl,%edi
  801084:	09 d0                	or     %edx,%eax
  801086:	89 fa                	mov    %edi,%edx
  801088:	83 c4 14             	add    $0x14,%esp
  80108b:	5e                   	pop    %esi
  80108c:	5f                   	pop    %edi
  80108d:	5d                   	pop    %ebp
  80108e:	c3                   	ret    
  80108f:	90                   	nop
  801090:	39 d7                	cmp    %edx,%edi
  801092:	75 da                	jne    80106e <__umoddi3+0x10e>
  801094:	8b 14 24             	mov    (%esp),%edx
  801097:	89 c1                	mov    %eax,%ecx
  801099:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80109d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8010a1:	eb cb                	jmp    80106e <__umoddi3+0x10e>
  8010a3:	90                   	nop
  8010a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010a8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8010ac:	0f 82 0f ff ff ff    	jb     800fc1 <__umoddi3+0x61>
  8010b2:	e9 1a ff ff ff       	jmp    800fd1 <__umoddi3+0x71>
