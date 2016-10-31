
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 e0 00 00 00       	call   800111 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800048:	e8 38 0c 00 00       	call   800c85 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800054:	e8 7f 0e 00 00       	call   800ed8 <fork>
  800059:	85 c0                	test   %eax,%eax
  80005b:	74 0a                	je     800067 <umain+0x27>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80005d:	83 c3 01             	add    $0x1,%ebx
  800060:	83 fb 14             	cmp    $0x14,%ebx
  800063:	75 ef                	jne    800054 <umain+0x14>
  800065:	eb 16                	jmp    80007d <umain+0x3d>
		if (fork() == 0)
			break;
	if (i == 20) {
  800067:	83 fb 14             	cmp    $0x14,%ebx
  80006a:	74 11                	je     80007d <umain+0x3d>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800072:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800075:	81 c2 04 00 c0 ee    	add    $0xeec00004,%edx
  80007b:	eb 0c                	jmp    800089 <umain+0x49>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  80007d:	e8 22 0c 00 00       	call   800ca4 <sys_yield>
		return;
  800082:	e9 83 00 00 00       	jmp    80010a <umain+0xca>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800087:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800089:	8b 42 50             	mov    0x50(%edx),%eax
  80008c:	85 c0                	test   %eax,%eax
  80008e:	66 90                	xchg   %ax,%ax
  800090:	75 f5                	jne    800087 <umain+0x47>
  800092:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800097:	e8 08 0c 00 00       	call   800ca4 <sys_yield>
  80009c:	b8 10 27 00 00       	mov    $0x2710,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000a1:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000a7:	83 c2 01             	add    $0x1,%edx
  8000aa:	89 15 04 20 80 00    	mov    %edx,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000b0:	83 e8 01             	sub    $0x1,%eax
  8000b3:	75 ec                	jne    8000a1 <umain+0x61>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000b5:	83 eb 01             	sub    $0x1,%ebx
  8000b8:	75 dd                	jne    800097 <umain+0x57>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000ba:	a1 04 20 80 00       	mov    0x802004,%eax
  8000bf:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000c4:	74 25                	je     8000eb <umain+0xab>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000c6:	a1 04 20 80 00       	mov    0x802004,%eax
  8000cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000cf:	c7 44 24 08 c0 11 80 	movl   $0x8011c0,0x8(%esp)
  8000d6:	00 
  8000d7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000de:	00 
  8000df:	c7 04 24 e8 11 80 00 	movl   $0x8011e8,(%esp)
  8000e6:	e8 98 00 00 00       	call   800183 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000eb:	a1 08 20 80 00       	mov    0x802008,%eax
  8000f0:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000f3:	8b 40 48             	mov    0x48(%eax),%eax
  8000f6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000fe:	c7 04 24 fb 11 80 00 	movl   $0x8011fb,(%esp)
  800105:	e8 72 01 00 00       	call   80027c <cprintf>

}
  80010a:	83 c4 10             	add    $0x10,%esp
  80010d:	5b                   	pop    %ebx
  80010e:	5e                   	pop    %esi
  80010f:	5d                   	pop    %ebp
  800110:	c3                   	ret    

00800111 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	57                   	push   %edi
  800115:	56                   	push   %esi
  800116:	53                   	push   %ebx
  800117:	83 ec 1c             	sub    $0x1c,%esp
  80011a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80011d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = envs[sys_getenvid];
	//envid2env(sys_getenvid, &thisenv, 1);
	//((sys_getenvid) & (1024 - 1))
	int envid = sys_getenvid();
  800120:	e8 60 0b 00 00       	call   800c85 <sys_getenvid>
	int index = envid & (1023);
  800125:	25 ff 03 00 00       	and    $0x3ff,%eax
  80012a:	89 c6                	mov    %eax,%esi
	cprintf("Value of x:%x\n",index);
  80012c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800130:	c7 04 24 19 12 80 00 	movl   $0x801219,(%esp)
  800137:	e8 40 01 00 00       	call   80027c <cprintf>
	thisenv = &envs[index];
  80013c:	6b f6 7c             	imul   $0x7c,%esi,%esi
  80013f:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  800145:	89 35 08 20 80 00    	mov    %esi,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80014b:	85 db                	test   %ebx,%ebx
  80014d:	7e 07                	jle    800156 <libmain+0x45>
		binaryname = argv[0];
  80014f:	8b 07                	mov    (%edi),%eax
  800151:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800156:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80015a:	89 1c 24             	mov    %ebx,(%esp)
  80015d:	e8 de fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800162:	e8 08 00 00 00       	call   80016f <exit>
}
  800167:	83 c4 1c             	add    $0x1c,%esp
  80016a:	5b                   	pop    %ebx
  80016b:	5e                   	pop    %esi
  80016c:	5f                   	pop    %edi
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    

0080016f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80016f:	55                   	push   %ebp
  800170:	89 e5                	mov    %esp,%ebp
  800172:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800175:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80017c:	e8 b2 0a 00 00       	call   800c33 <sys_env_destroy>
}
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	56                   	push   %esi
  800187:	53                   	push   %ebx
  800188:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80018b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800194:	e8 ec 0a 00 00       	call   800c85 <sys_getenvid>
  800199:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019c:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001a7:	89 74 24 08          	mov    %esi,0x8(%esp)
  8001ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001af:	c7 04 24 34 12 80 00 	movl   $0x801234,(%esp)
  8001b6:	e8 c1 00 00 00       	call   80027c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001bf:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c2:	89 04 24             	mov    %eax,(%esp)
  8001c5:	e8 51 00 00 00       	call   80021b <vcprintf>
	cprintf("\n");
  8001ca:	c7 04 24 17 12 80 00 	movl   $0x801217,(%esp)
  8001d1:	e8 a6 00 00 00       	call   80027c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001d6:	cc                   	int3   
  8001d7:	eb fd                	jmp    8001d6 <_panic+0x53>

008001d9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 14             	sub    $0x14,%esp
  8001e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e3:	8b 13                	mov    (%ebx),%edx
  8001e5:	8d 42 01             	lea    0x1(%edx),%eax
  8001e8:	89 03                	mov    %eax,(%ebx)
  8001ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f6:	75 19                	jne    800211 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001f8:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ff:	00 
  800200:	8d 43 08             	lea    0x8(%ebx),%eax
  800203:	89 04 24             	mov    %eax,(%esp)
  800206:	e8 eb 09 00 00       	call   800bf6 <sys_cputs>
		b->idx = 0;
  80020b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800211:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800215:	83 c4 14             	add    $0x14,%esp
  800218:	5b                   	pop    %ebx
  800219:	5d                   	pop    %ebp
  80021a:	c3                   	ret    

0080021b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800224:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80022b:	00 00 00 
	b.cnt = 0;
  80022e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800235:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800238:	8b 45 0c             	mov    0xc(%ebp),%eax
  80023b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80023f:	8b 45 08             	mov    0x8(%ebp),%eax
  800242:	89 44 24 08          	mov    %eax,0x8(%esp)
  800246:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800250:	c7 04 24 d9 01 80 00 	movl   $0x8001d9,(%esp)
  800257:	e8 b2 01 00 00       	call   80040e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80025c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800262:	89 44 24 04          	mov    %eax,0x4(%esp)
  800266:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80026c:	89 04 24             	mov    %eax,(%esp)
  80026f:	e8 82 09 00 00       	call   800bf6 <sys_cputs>

	return b.cnt;
}
  800274:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027a:	c9                   	leave  
  80027b:	c3                   	ret    

0080027c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800282:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800285:	89 44 24 04          	mov    %eax,0x4(%esp)
  800289:	8b 45 08             	mov    0x8(%ebp),%eax
  80028c:	89 04 24             	mov    %eax,(%esp)
  80028f:	e8 87 ff ff ff       	call   80021b <vcprintf>
	va_end(ap);

	return cnt;
}
  800294:	c9                   	leave  
  800295:	c3                   	ret    
  800296:	66 90                	xchg   %ax,%ax
  800298:	66 90                	xchg   %ax,%ax
  80029a:	66 90                	xchg   %ax,%ax
  80029c:	66 90                	xchg   %ax,%ax
  80029e:	66 90                	xchg   %ax,%ax

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 3c             	sub    $0x3c,%esp
  8002a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ac:	89 d7                	mov    %edx,%edi
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b7:	89 c3                	mov    %eax,%ebx
  8002b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8002bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002cd:	39 d9                	cmp    %ebx,%ecx
  8002cf:	72 05                	jb     8002d6 <printnum+0x36>
  8002d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8002d4:	77 69                	ja     80033f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8002d9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002dd:	83 ee 01             	sub    $0x1,%esi
  8002e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8002ec:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8002f0:	89 c3                	mov    %eax,%ebx
  8002f2:	89 d6                	mov    %edx,%esi
  8002f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8002fa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8002fe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800302:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800305:	89 04 24             	mov    %eax,(%esp)
  800308:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80030b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030f:	e8 0c 0c 00 00       	call   800f20 <__udivdi3>
  800314:	89 d9                	mov    %ebx,%ecx
  800316:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80031a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80031e:	89 04 24             	mov    %eax,(%esp)
  800321:	89 54 24 04          	mov    %edx,0x4(%esp)
  800325:	89 fa                	mov    %edi,%edx
  800327:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80032a:	e8 71 ff ff ff       	call   8002a0 <printnum>
  80032f:	eb 1b                	jmp    80034c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800331:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800335:	8b 45 18             	mov    0x18(%ebp),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	ff d3                	call   *%ebx
  80033d:	eb 03                	jmp    800342 <printnum+0xa2>
  80033f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800342:	83 ee 01             	sub    $0x1,%esi
  800345:	85 f6                	test   %esi,%esi
  800347:	7f e8                	jg     800331 <printnum+0x91>
  800349:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800350:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800354:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800357:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80035a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80035e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800362:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800365:	89 04 24             	mov    %eax,(%esp)
  800368:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80036b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036f:	e8 dc 0c 00 00       	call   801050 <__umoddi3>
  800374:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800378:	0f be 80 58 12 80 00 	movsbl 0x801258(%eax),%eax
  80037f:	89 04 24             	mov    %eax,(%esp)
  800382:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800385:	ff d0                	call   *%eax
}
  800387:	83 c4 3c             	add    $0x3c,%esp
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5f                   	pop    %edi
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800392:	83 fa 01             	cmp    $0x1,%edx
  800395:	7e 0e                	jle    8003a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800397:	8b 10                	mov    (%eax),%edx
  800399:	8d 4a 08             	lea    0x8(%edx),%ecx
  80039c:	89 08                	mov    %ecx,(%eax)
  80039e:	8b 02                	mov    (%edx),%eax
  8003a0:	8b 52 04             	mov    0x4(%edx),%edx
  8003a3:	eb 22                	jmp    8003c7 <getuint+0x38>
	else if (lflag)
  8003a5:	85 d2                	test   %edx,%edx
  8003a7:	74 10                	je     8003b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ae:	89 08                	mov    %ecx,(%eax)
  8003b0:	8b 02                	mov    (%edx),%eax
  8003b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b7:	eb 0e                	jmp    8003c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b9:	8b 10                	mov    (%eax),%edx
  8003bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003be:	89 08                	mov    %ecx,(%eax)
  8003c0:	8b 02                	mov    (%edx),%eax
  8003c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c7:	5d                   	pop    %ebp
  8003c8:	c3                   	ret    

008003c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c9:	55                   	push   %ebp
  8003ca:	89 e5                	mov    %esp,%ebp
  8003cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003d3:	8b 10                	mov    (%eax),%edx
  8003d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d8:	73 0a                	jae    8003e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003dd:	89 08                	mov    %ecx,(%eax)
  8003df:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e2:	88 02                	mov    %al,(%edx)
}
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    

008003e6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800401:	8b 45 08             	mov    0x8(%ebp),%eax
  800404:	89 04 24             	mov    %eax,(%esp)
  800407:	e8 02 00 00 00       	call   80040e <vprintfmt>
	va_end(ap);
}
  80040c:	c9                   	leave  
  80040d:	c3                   	ret    

0080040e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80040e:	55                   	push   %ebp
  80040f:	89 e5                	mov    %esp,%ebp
  800411:	57                   	push   %edi
  800412:	56                   	push   %esi
  800413:	53                   	push   %ebx
  800414:	83 ec 3c             	sub    $0x3c,%esp
  800417:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80041a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80041d:	eb 14                	jmp    800433 <vprintfmt+0x25>

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
		{
			if (ch == '\0')
  80041f:	85 c0                	test   %eax,%eax
  800421:	0f 84 b3 03 00 00    	je     8007da <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  800427:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80042b:	89 04 24             	mov    %eax,(%esp)
  80042e:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
  800431:	89 f3                	mov    %esi,%ebx
  800433:	8d 73 01             	lea    0x1(%ebx),%esi
  800436:	0f b6 03             	movzbl (%ebx),%eax
  800439:	83 f8 25             	cmp    $0x25,%eax
  80043c:	75 e1                	jne    80041f <vprintfmt+0x11>
  80043e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800442:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  800449:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800450:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  800457:	ba 00 00 00 00       	mov    $0x0,%edx
  80045c:	eb 1d                	jmp    80047b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  80045e:	89 de                	mov    %ebx,%esi
		{

			// flag to pad on the right
			case '-':
				padc = '-';
  800460:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800464:	eb 15                	jmp    80047b <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800466:	89 de                	mov    %ebx,%esi
				padc = '-';
				goto reswitch;

			// flag to pad with 0's instead of spaces
			case '0':
				padc = '0';
  800468:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80046c:	eb 0d                	jmp    80047b <vprintfmt+0x6d>
				altflag = 1;
				goto reswitch;

			process_precision:
				if (width < 0)
					width = precision, precision = -1;
  80046e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800471:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800474:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  80047b:	8d 5e 01             	lea    0x1(%esi),%ebx
  80047e:	0f b6 0e             	movzbl (%esi),%ecx
  800481:	0f b6 c1             	movzbl %cl,%eax
  800484:	83 e9 23             	sub    $0x23,%ecx
  800487:	80 f9 55             	cmp    $0x55,%cl
  80048a:	0f 87 2a 03 00 00    	ja     8007ba <vprintfmt+0x3ac>
  800490:	0f b6 c9             	movzbl %cl,%ecx
  800493:	ff 24 8d 20 13 80 00 	jmp    *0x801320(,%ecx,4)
  80049a:	89 de                	mov    %ebx,%esi
  80049c:	b9 00 00 00 00       	mov    $0x0,%ecx
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
					precision = precision * 10 + ch - '0';
  8004a1:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004a4:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
					ch = *fmt;
  8004a8:	0f be 06             	movsbl (%esi),%eax
					if (ch < '0' || ch > '9')
  8004ab:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004ae:	83 fb 09             	cmp    $0x9,%ebx
  8004b1:	77 36                	ja     8004e9 <vprintfmt+0xdb>
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
  8004b3:	83 c6 01             	add    $0x1,%esi
					precision = precision * 10 + ch - '0';
					ch = *fmt;
					if (ch < '0' || ch > '9')
						break;
				}
  8004b6:	eb e9                	jmp    8004a1 <vprintfmt+0x93>
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
  8004b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bb:	8d 48 04             	lea    0x4(%eax),%ecx
  8004be:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004c1:	8b 00                	mov    (%eax),%eax
  8004c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8004c6:	89 de                	mov    %ebx,%esi
				}
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
				goto process_precision;
  8004c8:	eb 22                	jmp    8004ec <vprintfmt+0xde>
  8004ca:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004cd:	85 c9                	test   %ecx,%ecx
  8004cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d4:	0f 49 c1             	cmovns %ecx,%eax
  8004d7:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8004da:	89 de                	mov    %ebx,%esi
  8004dc:	eb 9d                	jmp    80047b <vprintfmt+0x6d>
  8004de:	89 de                	mov    %ebx,%esi
				if (width < 0)
					width = 0;
				goto reswitch;

			case '#':
				altflag = 1;
  8004e0:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
				goto reswitch;
  8004e7:	eb 92                	jmp    80047b <vprintfmt+0x6d>
  8004e9:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

			process_precision:
				if (width < 0)
  8004ec:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004f0:	79 89                	jns    80047b <vprintfmt+0x6d>
  8004f2:	e9 77 ff ff ff       	jmp    80046e <vprintfmt+0x60>
					width = precision, precision = -1;
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
  8004f7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8004fa:	89 de                	mov    %ebx,%esi
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
				goto reswitch;
  8004fc:	e9 7a ff ff ff       	jmp    80047b <vprintfmt+0x6d>

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8d 50 04             	lea    0x4(%eax),%edx
  800507:	89 55 14             	mov    %edx,0x14(%ebp)
  80050a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80050e:	8b 00                	mov    (%eax),%eax
  800510:	89 04 24             	mov    %eax,(%esp)
  800513:	ff 55 08             	call   *0x8(%ebp)
				break;
  800516:	e9 18 ff ff ff       	jmp    800433 <vprintfmt+0x25>

			// error message
			case 'e':
				err = va_arg(ap, int);
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 50 04             	lea    0x4(%eax),%edx
  800521:	89 55 14             	mov    %edx,0x14(%ebp)
  800524:	8b 00                	mov    (%eax),%eax
  800526:	99                   	cltd   
  800527:	31 d0                	xor    %edx,%eax
  800529:	29 d0                	sub    %edx,%eax
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80052b:	83 f8 09             	cmp    $0x9,%eax
  80052e:	7f 0b                	jg     80053b <vprintfmt+0x12d>
  800530:	8b 14 85 80 14 80 00 	mov    0x801480(,%eax,4),%edx
  800537:	85 d2                	test   %edx,%edx
  800539:	75 20                	jne    80055b <vprintfmt+0x14d>
					printfmt(putch, putdat, "error %d", err);
  80053b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053f:	c7 44 24 08 70 12 80 	movl   $0x801270,0x8(%esp)
  800546:	00 
  800547:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80054b:	8b 45 08             	mov    0x8(%ebp),%eax
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	e8 90 fe ff ff       	call   8003e6 <printfmt>
  800556:	e9 d8 fe ff ff       	jmp    800433 <vprintfmt+0x25>
				else
					printfmt(putch, putdat, "%s", p);
  80055b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80055f:	c7 44 24 08 79 12 80 	movl   $0x801279,0x8(%esp)
  800566:	00 
  800567:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80056b:	8b 45 08             	mov    0x8(%ebp),%eax
  80056e:	89 04 24             	mov    %eax,(%esp)
  800571:	e8 70 fe ff ff       	call   8003e6 <printfmt>
  800576:	e9 b8 fe ff ff       	jmp    800433 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  80057b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80057e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800581:	89 45 d0             	mov    %eax,-0x30(%ebp)
					printfmt(putch, putdat, "%s", p);
				break;

			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8d 50 04             	lea    0x4(%eax),%edx
  80058a:	89 55 14             	mov    %edx,0x14(%ebp)
  80058d:	8b 30                	mov    (%eax),%esi
					p = "(null)";
  80058f:	85 f6                	test   %esi,%esi
  800591:	b8 69 12 80 00       	mov    $0x801269,%eax
  800596:	0f 44 f0             	cmove  %eax,%esi
				if (width > 0 && padc != '-')
  800599:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80059d:	0f 84 97 00 00 00    	je     80063a <vprintfmt+0x22c>
  8005a3:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005a7:	0f 8e 9b 00 00 00    	jle    800648 <vprintfmt+0x23a>
					for (width -= strnlen(p, precision); width > 0; width--)
  8005ad:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005b1:	89 34 24             	mov    %esi,(%esp)
  8005b4:	e8 cf 02 00 00       	call   800888 <strnlen>
  8005b9:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005bc:	29 c2                	sub    %eax,%edx
  8005be:	89 55 d0             	mov    %edx,-0x30(%ebp)
						putch(padc, putdat);
  8005c1:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005c8:	89 75 d8             	mov    %esi,-0x28(%ebp)
  8005cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ce:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8005d1:	89 d3                	mov    %edx,%ebx
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  8005d3:	eb 0f                	jmp    8005e4 <vprintfmt+0x1d6>
						putch(padc, putdat);
  8005d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005dc:	89 04 24             	mov    %eax,(%esp)
  8005df:	ff d6                	call   *%esi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	83 eb 01             	sub    $0x1,%ebx
  8005e4:	85 db                	test   %ebx,%ebx
  8005e6:	7f ed                	jg     8005d5 <vprintfmt+0x1c7>
  8005e8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8005eb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  8005ee:	85 d2                	test   %edx,%edx
  8005f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f5:	0f 49 c2             	cmovns %edx,%eax
  8005f8:	29 c2                	sub    %eax,%edx
  8005fa:	89 7d 0c             	mov    %edi,0xc(%ebp)
  8005fd:	89 d7                	mov    %edx,%edi
  8005ff:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800602:	eb 50                	jmp    800654 <vprintfmt+0x246>
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
  800604:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800608:	74 1e                	je     800628 <vprintfmt+0x21a>
  80060a:	0f be d2             	movsbl %dl,%edx
  80060d:	83 ea 20             	sub    $0x20,%edx
  800610:	83 fa 5e             	cmp    $0x5e,%edx
  800613:	76 13                	jbe    800628 <vprintfmt+0x21a>
						putch('?', putdat);
  800615:	8b 45 0c             	mov    0xc(%ebp),%eax
  800618:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800623:	ff 55 08             	call   *0x8(%ebp)
  800626:	eb 0d                	jmp    800635 <vprintfmt+0x227>
					else
						putch(ch, putdat);
  800628:	8b 55 0c             	mov    0xc(%ebp),%edx
  80062b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062f:	89 04 24             	mov    %eax,(%esp)
  800632:	ff 55 08             	call   *0x8(%ebp)
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800635:	83 ef 01             	sub    $0x1,%edi
  800638:	eb 1a                	jmp    800654 <vprintfmt+0x246>
  80063a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80063d:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800640:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800643:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800646:	eb 0c                	jmp    800654 <vprintfmt+0x246>
  800648:	89 7d 0c             	mov    %edi,0xc(%ebp)
  80064b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80064e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800651:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800654:	83 c6 01             	add    $0x1,%esi
  800657:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  80065b:	0f be c2             	movsbl %dl,%eax
  80065e:	85 c0                	test   %eax,%eax
  800660:	74 27                	je     800689 <vprintfmt+0x27b>
  800662:	85 db                	test   %ebx,%ebx
  800664:	78 9e                	js     800604 <vprintfmt+0x1f6>
  800666:	83 eb 01             	sub    $0x1,%ebx
  800669:	79 99                	jns    800604 <vprintfmt+0x1f6>
  80066b:	89 f8                	mov    %edi,%eax
  80066d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800670:	8b 75 08             	mov    0x8(%ebp),%esi
  800673:	89 c3                	mov    %eax,%ebx
  800675:	eb 1a                	jmp    800691 <vprintfmt+0x283>
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
					putch(' ', putdat);
  800677:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80067b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800682:	ff d6                	call   *%esi
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
  800684:	83 eb 01             	sub    $0x1,%ebx
  800687:	eb 08                	jmp    800691 <vprintfmt+0x283>
  800689:	89 fb                	mov    %edi,%ebx
  80068b:	8b 75 08             	mov    0x8(%ebp),%esi
  80068e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800691:	85 db                	test   %ebx,%ebx
  800693:	7f e2                	jg     800677 <vprintfmt+0x269>
  800695:	89 75 08             	mov    %esi,0x8(%ebp)
  800698:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80069b:	e9 93 fd ff ff       	jmp    800433 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a0:	83 fa 01             	cmp    $0x1,%edx
  8006a3:	7e 16                	jle    8006bb <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8d 50 08             	lea    0x8(%eax),%edx
  8006ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ae:	8b 50 04             	mov    0x4(%eax),%edx
  8006b1:	8b 00                	mov    (%eax),%eax
  8006b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006b9:	eb 32                	jmp    8006ed <vprintfmt+0x2df>
	else if (lflag)
  8006bb:	85 d2                	test   %edx,%edx
  8006bd:	74 18                	je     8006d7 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8d 50 04             	lea    0x4(%eax),%edx
  8006c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c8:	8b 30                	mov    (%eax),%esi
  8006ca:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	c1 f8 1f             	sar    $0x1f,%eax
  8006d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006d5:	eb 16                	jmp    8006ed <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8d 50 04             	lea    0x4(%eax),%edx
  8006dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e0:	8b 30                	mov    (%eax),%esi
  8006e2:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006e5:	89 f0                	mov    %esi,%eax
  8006e7:	c1 f8 1f             	sar    $0x1f,%eax
  8006ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(' ', putdat);
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
  8006ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
				if ((long long) num < 0) {
					putch('-', putdat);
					num = -(long long) num;
				}
				base = 10;
  8006f3:	b9 0a 00 00 00       	mov    $0xa,%ecx
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
				if ((long long) num < 0) {
  8006f8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006fc:	0f 89 80 00 00 00    	jns    800782 <vprintfmt+0x374>
					putch('-', putdat);
  800702:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800706:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80070d:	ff 55 08             	call   *0x8(%ebp)
					num = -(long long) num;
  800710:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800713:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800716:	f7 d8                	neg    %eax
  800718:	83 d2 00             	adc    $0x0,%edx
  80071b:	f7 da                	neg    %edx
				}
				base = 10;
  80071d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800722:	eb 5e                	jmp    800782 <vprintfmt+0x374>
				goto number;

			// unsigned decimal
			case 'u':
				num = getuint(&ap, lflag);
  800724:	8d 45 14             	lea    0x14(%ebp),%eax
  800727:	e8 63 fc ff ff       	call   80038f <getuint>
				base = 10;
  80072c:	b9 0a 00 00 00       	mov    $0xa,%ecx
				goto number;
  800731:	eb 4f                	jmp    800782 <vprintfmt+0x374>
				// Replace this with your code.
				/*putch('X', putdat);
				putch('X', putdat);
				putch('X', putdat);*/
				
				num = getuint(&ap, lflag);
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
  800736:	e8 54 fc ff ff       	call   80038f <getuint>
				base = 8;
  80073b:	b9 08 00 00 00       	mov    $0x8,%ecx
				goto number;
  800740:	eb 40                	jmp    800782 <vprintfmt+0x374>

			// pointer
			case 'p':
				putch('0', putdat);
  800742:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800746:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80074d:	ff 55 08             	call   *0x8(%ebp)
				putch('x', putdat);
  800750:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800754:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80075b:	ff 55 08             	call   *0x8(%ebp)
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	8d 50 04             	lea    0x4(%eax),%edx
  800764:	89 55 14             	mov    %edx,0x14(%ebp)

			// pointer
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
  800767:	8b 00                	mov    (%eax),%eax
  800769:	ba 00 00 00 00       	mov    $0x0,%edx
					(uintptr_t) va_arg(ap, void *);
				base = 16;
  80076e:	b9 10 00 00 00       	mov    $0x10,%ecx
				goto number;
  800773:	eb 0d                	jmp    800782 <vprintfmt+0x374>

			// (unsigned) hexadecimal
			case 'x':
				num = getuint(&ap, lflag);
  800775:	8d 45 14             	lea    0x14(%ebp),%eax
  800778:	e8 12 fc ff ff       	call   80038f <getuint>
				base = 16;
  80077d:	b9 10 00 00 00       	mov    $0x10,%ecx
			number:
				printnum(putch, putdat, num, base, width, padc);
  800782:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800786:	89 74 24 10          	mov    %esi,0x10(%esp)
  80078a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  80078d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800791:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800795:	89 04 24             	mov    %eax,(%esp)
  800798:	89 54 24 04          	mov    %edx,0x4(%esp)
  80079c:	89 fa                	mov    %edi,%edx
  80079e:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a1:	e8 fa fa ff ff       	call   8002a0 <printnum>
				break;
  8007a6:	e9 88 fc ff ff       	jmp    800433 <vprintfmt+0x25>

			// escaped '%' character
			case '%':
				putch(ch, putdat);
  8007ab:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007af:	89 04 24             	mov    %eax,(%esp)
  8007b2:	ff 55 08             	call   *0x8(%ebp)
				break;
  8007b5:	e9 79 fc ff ff       	jmp    800433 <vprintfmt+0x25>

			// unrecognized escape sequence - just print it literally
			default:
				putch('%', putdat);
  8007ba:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007be:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007c5:	ff 55 08             	call   *0x8(%ebp)
				for (fmt--; fmt[-1] != '%'; fmt--)
  8007c8:	89 f3                	mov    %esi,%ebx
  8007ca:	eb 03                	jmp    8007cf <vprintfmt+0x3c1>
  8007cc:	83 eb 01             	sub    $0x1,%ebx
  8007cf:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  8007d3:	75 f7                	jne    8007cc <vprintfmt+0x3be>
  8007d5:	e9 59 fc ff ff       	jmp    800433 <vprintfmt+0x25>
					/* do nothing */;
				break;
		}
	}
}
  8007da:	83 c4 3c             	add    $0x3c,%esp
  8007dd:	5b                   	pop    %ebx
  8007de:	5e                   	pop    %esi
  8007df:	5f                   	pop    %edi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	83 ec 28             	sub    $0x28,%esp
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ff:	85 c0                	test   %eax,%eax
  800801:	74 30                	je     800833 <vsnprintf+0x51>
  800803:	85 d2                	test   %edx,%edx
  800805:	7e 2c                	jle    800833 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800807:	8b 45 14             	mov    0x14(%ebp),%eax
  80080a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080e:	8b 45 10             	mov    0x10(%ebp),%eax
  800811:	89 44 24 08          	mov    %eax,0x8(%esp)
  800815:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800818:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081c:	c7 04 24 c9 03 80 00 	movl   $0x8003c9,(%esp)
  800823:	e8 e6 fb ff ff       	call   80040e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800828:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800831:	eb 05                	jmp    800838 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800833:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800840:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800843:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800847:	8b 45 10             	mov    0x10(%ebp),%eax
  80084a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800851:	89 44 24 04          	mov    %eax,0x4(%esp)
  800855:	8b 45 08             	mov    0x8(%ebp),%eax
  800858:	89 04 24             	mov    %eax,(%esp)
  80085b:	e8 82 ff ff ff       	call   8007e2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800860:	c9                   	leave  
  800861:	c3                   	ret    
  800862:	66 90                	xchg   %ax,%ax
  800864:	66 90                	xchg   %ax,%ax
  800866:	66 90                	xchg   %ax,%ax
  800868:	66 90                	xchg   %ax,%ax
  80086a:	66 90                	xchg   %ax,%ax
  80086c:	66 90                	xchg   %ax,%ax
  80086e:	66 90                	xchg   %ax,%ax

00800870 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
  80087b:	eb 03                	jmp    800880 <strlen+0x10>
		n++;
  80087d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800880:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800884:	75 f7                	jne    80087d <strlen+0xd>
		n++;
	return n;
}
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
  800896:	eb 03                	jmp    80089b <strnlen+0x13>
		n++;
  800898:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089b:	39 d0                	cmp    %edx,%eax
  80089d:	74 06                	je     8008a5 <strnlen+0x1d>
  80089f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008a3:	75 f3                	jne    800898 <strnlen+0x10>
		n++;
	return n;
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	53                   	push   %ebx
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b1:	89 c2                	mov    %eax,%edx
  8008b3:	83 c2 01             	add    $0x1,%edx
  8008b6:	83 c1 01             	add    $0x1,%ecx
  8008b9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008bd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008c0:	84 db                	test   %bl,%bl
  8008c2:	75 ef                	jne    8008b3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008c4:	5b                   	pop    %ebx
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	53                   	push   %ebx
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d1:	89 1c 24             	mov    %ebx,(%esp)
  8008d4:	e8 97 ff ff ff       	call   800870 <strlen>
	strcpy(dst + len, src);
  8008d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008dc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008e0:	01 d8                	add    %ebx,%eax
  8008e2:	89 04 24             	mov    %eax,(%esp)
  8008e5:	e8 bd ff ff ff       	call   8008a7 <strcpy>
	return dst;
}
  8008ea:	89 d8                	mov    %ebx,%eax
  8008ec:	83 c4 08             	add    $0x8,%esp
  8008ef:	5b                   	pop    %ebx
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fd:	89 f3                	mov    %esi,%ebx
  8008ff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800902:	89 f2                	mov    %esi,%edx
  800904:	eb 0f                	jmp    800915 <strncpy+0x23>
		*dst++ = *src;
  800906:	83 c2 01             	add    $0x1,%edx
  800909:	0f b6 01             	movzbl (%ecx),%eax
  80090c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80090f:	80 39 01             	cmpb   $0x1,(%ecx)
  800912:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800915:	39 da                	cmp    %ebx,%edx
  800917:	75 ed                	jne    800906 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800919:	89 f0                	mov    %esi,%eax
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	56                   	push   %esi
  800923:	53                   	push   %ebx
  800924:	8b 75 08             	mov    0x8(%ebp),%esi
  800927:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80092d:	89 f0                	mov    %esi,%eax
  80092f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800933:	85 c9                	test   %ecx,%ecx
  800935:	75 0b                	jne    800942 <strlcpy+0x23>
  800937:	eb 1d                	jmp    800956 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800939:	83 c0 01             	add    $0x1,%eax
  80093c:	83 c2 01             	add    $0x1,%edx
  80093f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800942:	39 d8                	cmp    %ebx,%eax
  800944:	74 0b                	je     800951 <strlcpy+0x32>
  800946:	0f b6 0a             	movzbl (%edx),%ecx
  800949:	84 c9                	test   %cl,%cl
  80094b:	75 ec                	jne    800939 <strlcpy+0x1a>
  80094d:	89 c2                	mov    %eax,%edx
  80094f:	eb 02                	jmp    800953 <strlcpy+0x34>
  800951:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800953:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800956:	29 f0                	sub    %esi,%eax
}
  800958:	5b                   	pop    %ebx
  800959:	5e                   	pop    %esi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800962:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800965:	eb 06                	jmp    80096d <strcmp+0x11>
		p++, q++;
  800967:	83 c1 01             	add    $0x1,%ecx
  80096a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80096d:	0f b6 01             	movzbl (%ecx),%eax
  800970:	84 c0                	test   %al,%al
  800972:	74 04                	je     800978 <strcmp+0x1c>
  800974:	3a 02                	cmp    (%edx),%al
  800976:	74 ef                	je     800967 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800978:	0f b6 c0             	movzbl %al,%eax
  80097b:	0f b6 12             	movzbl (%edx),%edx
  80097e:	29 d0                	sub    %edx,%eax
}
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	53                   	push   %ebx
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098c:	89 c3                	mov    %eax,%ebx
  80098e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800991:	eb 06                	jmp    800999 <strncmp+0x17>
		n--, p++, q++;
  800993:	83 c0 01             	add    $0x1,%eax
  800996:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800999:	39 d8                	cmp    %ebx,%eax
  80099b:	74 15                	je     8009b2 <strncmp+0x30>
  80099d:	0f b6 08             	movzbl (%eax),%ecx
  8009a0:	84 c9                	test   %cl,%cl
  8009a2:	74 04                	je     8009a8 <strncmp+0x26>
  8009a4:	3a 0a                	cmp    (%edx),%cl
  8009a6:	74 eb                	je     800993 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a8:	0f b6 00             	movzbl (%eax),%eax
  8009ab:	0f b6 12             	movzbl (%edx),%edx
  8009ae:	29 d0                	sub    %edx,%eax
  8009b0:	eb 05                	jmp    8009b7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009b7:	5b                   	pop    %ebx
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c4:	eb 07                	jmp    8009cd <strchr+0x13>
		if (*s == c)
  8009c6:	38 ca                	cmp    %cl,%dl
  8009c8:	74 0f                	je     8009d9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	0f b6 10             	movzbl (%eax),%edx
  8009d0:	84 d2                	test   %dl,%dl
  8009d2:	75 f2                	jne    8009c6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e5:	eb 07                	jmp    8009ee <strfind+0x13>
		if (*s == c)
  8009e7:	38 ca                	cmp    %cl,%dl
  8009e9:	74 0a                	je     8009f5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009eb:	83 c0 01             	add    $0x1,%eax
  8009ee:	0f b6 10             	movzbl (%eax),%edx
  8009f1:	84 d2                	test   %dl,%dl
  8009f3:	75 f2                	jne    8009e7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	57                   	push   %edi
  8009fb:	56                   	push   %esi
  8009fc:	53                   	push   %ebx
  8009fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a03:	85 c9                	test   %ecx,%ecx
  800a05:	74 36                	je     800a3d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a07:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0d:	75 28                	jne    800a37 <memset+0x40>
  800a0f:	f6 c1 03             	test   $0x3,%cl
  800a12:	75 23                	jne    800a37 <memset+0x40>
		c &= 0xFF;
  800a14:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a18:	89 d3                	mov    %edx,%ebx
  800a1a:	c1 e3 08             	shl    $0x8,%ebx
  800a1d:	89 d6                	mov    %edx,%esi
  800a1f:	c1 e6 18             	shl    $0x18,%esi
  800a22:	89 d0                	mov    %edx,%eax
  800a24:	c1 e0 10             	shl    $0x10,%eax
  800a27:	09 f0                	or     %esi,%eax
  800a29:	09 c2                	or     %eax,%edx
  800a2b:	89 d0                	mov    %edx,%eax
  800a2d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a2f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a32:	fc                   	cld    
  800a33:	f3 ab                	rep stos %eax,%es:(%edi)
  800a35:	eb 06                	jmp    800a3d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3a:	fc                   	cld    
  800a3b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a3d:	89 f8                	mov    %edi,%eax
  800a3f:	5b                   	pop    %ebx
  800a40:	5e                   	pop    %esi
  800a41:	5f                   	pop    %edi
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	57                   	push   %edi
  800a48:	56                   	push   %esi
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a52:	39 c6                	cmp    %eax,%esi
  800a54:	73 35                	jae    800a8b <memmove+0x47>
  800a56:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a59:	39 d0                	cmp    %edx,%eax
  800a5b:	73 2e                	jae    800a8b <memmove+0x47>
		s += n;
		d += n;
  800a5d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a60:	89 d6                	mov    %edx,%esi
  800a62:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a64:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a6a:	75 13                	jne    800a7f <memmove+0x3b>
  800a6c:	f6 c1 03             	test   $0x3,%cl
  800a6f:	75 0e                	jne    800a7f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a71:	83 ef 04             	sub    $0x4,%edi
  800a74:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a77:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a7a:	fd                   	std    
  800a7b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7d:	eb 09                	jmp    800a88 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a7f:	83 ef 01             	sub    $0x1,%edi
  800a82:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a85:	fd                   	std    
  800a86:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a88:	fc                   	cld    
  800a89:	eb 1d                	jmp    800aa8 <memmove+0x64>
  800a8b:	89 f2                	mov    %esi,%edx
  800a8d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8f:	f6 c2 03             	test   $0x3,%dl
  800a92:	75 0f                	jne    800aa3 <memmove+0x5f>
  800a94:	f6 c1 03             	test   $0x3,%cl
  800a97:	75 0a                	jne    800aa3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a99:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a9c:	89 c7                	mov    %eax,%edi
  800a9e:	fc                   	cld    
  800a9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa1:	eb 05                	jmp    800aa8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa3:	89 c7                	mov    %eax,%edi
  800aa5:	fc                   	cld    
  800aa6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa8:	5e                   	pop    %esi
  800aa9:	5f                   	pop    %edi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	89 04 24             	mov    %eax,(%esp)
  800ac6:	e8 79 ff ff ff       	call   800a44 <memmove>
}
  800acb:	c9                   	leave  
  800acc:	c3                   	ret    

00800acd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad8:	89 d6                	mov    %edx,%esi
  800ada:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800add:	eb 1a                	jmp    800af9 <memcmp+0x2c>
		if (*s1 != *s2)
  800adf:	0f b6 02             	movzbl (%edx),%eax
  800ae2:	0f b6 19             	movzbl (%ecx),%ebx
  800ae5:	38 d8                	cmp    %bl,%al
  800ae7:	74 0a                	je     800af3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ae9:	0f b6 c0             	movzbl %al,%eax
  800aec:	0f b6 db             	movzbl %bl,%ebx
  800aef:	29 d8                	sub    %ebx,%eax
  800af1:	eb 0f                	jmp    800b02 <memcmp+0x35>
		s1++, s2++;
  800af3:	83 c2 01             	add    $0x1,%edx
  800af6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af9:	39 f2                	cmp    %esi,%edx
  800afb:	75 e2                	jne    800adf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800afd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b0f:	89 c2                	mov    %eax,%edx
  800b11:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b14:	eb 07                	jmp    800b1d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b16:	38 08                	cmp    %cl,(%eax)
  800b18:	74 07                	je     800b21 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b1a:	83 c0 01             	add    $0x1,%eax
  800b1d:	39 d0                	cmp    %edx,%eax
  800b1f:	72 f5                	jb     800b16 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2f:	eb 03                	jmp    800b34 <strtol+0x11>
		s++;
  800b31:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b34:	0f b6 0a             	movzbl (%edx),%ecx
  800b37:	80 f9 09             	cmp    $0x9,%cl
  800b3a:	74 f5                	je     800b31 <strtol+0xe>
  800b3c:	80 f9 20             	cmp    $0x20,%cl
  800b3f:	74 f0                	je     800b31 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b41:	80 f9 2b             	cmp    $0x2b,%cl
  800b44:	75 0a                	jne    800b50 <strtol+0x2d>
		s++;
  800b46:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b49:	bf 00 00 00 00       	mov    $0x0,%edi
  800b4e:	eb 11                	jmp    800b61 <strtol+0x3e>
  800b50:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b55:	80 f9 2d             	cmp    $0x2d,%cl
  800b58:	75 07                	jne    800b61 <strtol+0x3e>
		s++, neg = 1;
  800b5a:	8d 52 01             	lea    0x1(%edx),%edx
  800b5d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b61:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800b66:	75 15                	jne    800b7d <strtol+0x5a>
  800b68:	80 3a 30             	cmpb   $0x30,(%edx)
  800b6b:	75 10                	jne    800b7d <strtol+0x5a>
  800b6d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b71:	75 0a                	jne    800b7d <strtol+0x5a>
		s += 2, base = 16;
  800b73:	83 c2 02             	add    $0x2,%edx
  800b76:	b8 10 00 00 00       	mov    $0x10,%eax
  800b7b:	eb 10                	jmp    800b8d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	75 0c                	jne    800b8d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b81:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b83:	80 3a 30             	cmpb   $0x30,(%edx)
  800b86:	75 05                	jne    800b8d <strtol+0x6a>
		s++, base = 8;
  800b88:	83 c2 01             	add    $0x1,%edx
  800b8b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  800b8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b92:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b95:	0f b6 0a             	movzbl (%edx),%ecx
  800b98:	8d 71 d0             	lea    -0x30(%ecx),%esi
  800b9b:	89 f0                	mov    %esi,%eax
  800b9d:	3c 09                	cmp    $0x9,%al
  800b9f:	77 08                	ja     800ba9 <strtol+0x86>
			dig = *s - '0';
  800ba1:	0f be c9             	movsbl %cl,%ecx
  800ba4:	83 e9 30             	sub    $0x30,%ecx
  800ba7:	eb 20                	jmp    800bc9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800ba9:	8d 71 9f             	lea    -0x61(%ecx),%esi
  800bac:	89 f0                	mov    %esi,%eax
  800bae:	3c 19                	cmp    $0x19,%al
  800bb0:	77 08                	ja     800bba <strtol+0x97>
			dig = *s - 'a' + 10;
  800bb2:	0f be c9             	movsbl %cl,%ecx
  800bb5:	83 e9 57             	sub    $0x57,%ecx
  800bb8:	eb 0f                	jmp    800bc9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  800bba:	8d 71 bf             	lea    -0x41(%ecx),%esi
  800bbd:	89 f0                	mov    %esi,%eax
  800bbf:	3c 19                	cmp    $0x19,%al
  800bc1:	77 16                	ja     800bd9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  800bc3:	0f be c9             	movsbl %cl,%ecx
  800bc6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bc9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  800bcc:	7d 0f                	jge    800bdd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  800bce:	83 c2 01             	add    $0x1,%edx
  800bd1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  800bd5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  800bd7:	eb bc                	jmp    800b95 <strtol+0x72>
  800bd9:	89 d8                	mov    %ebx,%eax
  800bdb:	eb 02                	jmp    800bdf <strtol+0xbc>
  800bdd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  800bdf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be3:	74 05                	je     800bea <strtol+0xc7>
		*endptr = (char *) s;
  800be5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  800bea:	f7 d8                	neg    %eax
  800bec:	85 ff                	test   %edi,%edi
  800bee:	0f 44 c3             	cmove  %ebx,%eax
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	b8 00 00 00 00       	mov    $0x0,%eax
  800c01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c04:	8b 55 08             	mov    0x8(%ebp),%edx
  800c07:	89 c3                	mov    %eax,%ebx
  800c09:	89 c7                	mov    %eax,%edi
  800c0b:	89 c6                	mov    %eax,%esi
  800c0d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c24:	89 d1                	mov    %edx,%ecx
  800c26:	89 d3                	mov    %edx,%ebx
  800c28:	89 d7                	mov    %edx,%edi
  800c2a:	89 d6                	mov    %edx,%esi
  800c2c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c41:	b8 03 00 00 00       	mov    $0x3,%eax
  800c46:	8b 55 08             	mov    0x8(%ebp),%edx
  800c49:	89 cb                	mov    %ecx,%ebx
  800c4b:	89 cf                	mov    %ecx,%edi
  800c4d:	89 ce                	mov    %ecx,%esi
  800c4f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c51:	85 c0                	test   %eax,%eax
  800c53:	7e 28                	jle    800c7d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c55:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c59:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c60:	00 
  800c61:	c7 44 24 08 a8 14 80 	movl   $0x8014a8,0x8(%esp)
  800c68:	00 
  800c69:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c70:	00 
  800c71:	c7 04 24 c5 14 80 00 	movl   $0x8014c5,(%esp)
  800c78:	e8 06 f5 ff ff       	call   800183 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7d:	83 c4 2c             	add    $0x2c,%esp
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5f                   	pop    %edi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c90:	b8 02 00 00 00       	mov    $0x2,%eax
  800c95:	89 d1                	mov    %edx,%ecx
  800c97:	89 d3                	mov    %edx,%ebx
  800c99:	89 d7                	mov    %edx,%edi
  800c9b:	89 d6                	mov    %edx,%esi
  800c9d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_yield>:

void
sys_yield(void)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	ba 00 00 00 00       	mov    $0x0,%edx
  800caf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb4:	89 d1                	mov    %edx,%ecx
  800cb6:	89 d3                	mov    %edx,%ebx
  800cb8:	89 d7                	mov    %edx,%edi
  800cba:	89 d6                	mov    %edx,%esi
  800cbc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	be 00 00 00 00       	mov    $0x0,%esi
  800cd1:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdf:	89 f7                	mov    %esi,%edi
  800ce1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 28                	jle    800d0f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ceb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cf2:	00 
  800cf3:	c7 44 24 08 a8 14 80 	movl   $0x8014a8,0x8(%esp)
  800cfa:	00 
  800cfb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d02:	00 
  800d03:	c7 04 24 c5 14 80 00 	movl   $0x8014c5,(%esp)
  800d0a:	e8 74 f4 ff ff       	call   800183 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d0f:	83 c4 2c             	add    $0x2c,%esp
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d20:	b8 05 00 00 00       	mov    $0x5,%eax
  800d25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d28:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d31:	8b 75 18             	mov    0x18(%ebp),%esi
  800d34:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7e 28                	jle    800d62 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d45:	00 
  800d46:	c7 44 24 08 a8 14 80 	movl   $0x8014a8,0x8(%esp)
  800d4d:	00 
  800d4e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d55:	00 
  800d56:	c7 04 24 c5 14 80 00 	movl   $0x8014c5,(%esp)
  800d5d:	e8 21 f4 ff ff       	call   800183 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d62:	83 c4 2c             	add    $0x2c,%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
  800d70:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d78:	b8 06 00 00 00       	mov    $0x6,%eax
  800d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d80:	8b 55 08             	mov    0x8(%ebp),%edx
  800d83:	89 df                	mov    %ebx,%edi
  800d85:	89 de                	mov    %ebx,%esi
  800d87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	7e 28                	jle    800db5 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d91:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d98:	00 
  800d99:	c7 44 24 08 a8 14 80 	movl   $0x8014a8,0x8(%esp)
  800da0:	00 
  800da1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da8:	00 
  800da9:	c7 04 24 c5 14 80 00 	movl   $0x8014c5,(%esp)
  800db0:	e8 ce f3 ff ff       	call   800183 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db5:	83 c4 2c             	add    $0x2c,%esp
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	57                   	push   %edi
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
  800dc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcb:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd6:	89 df                	mov    %ebx,%edi
  800dd8:	89 de                	mov    %ebx,%esi
  800dda:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	7e 28                	jle    800e08 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800deb:	00 
  800dec:	c7 44 24 08 a8 14 80 	movl   $0x8014a8,0x8(%esp)
  800df3:	00 
  800df4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dfb:	00 
  800dfc:	c7 04 24 c5 14 80 00 	movl   $0x8014c5,(%esp)
  800e03:	e8 7b f3 ff ff       	call   800183 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e08:	83 c4 2c             	add    $0x2c,%esp
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
  800e16:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1e:	b8 09 00 00 00       	mov    $0x9,%eax
  800e23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e26:	8b 55 08             	mov    0x8(%ebp),%edx
  800e29:	89 df                	mov    %ebx,%edi
  800e2b:	89 de                	mov    %ebx,%esi
  800e2d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	7e 28                	jle    800e5b <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e37:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e3e:	00 
  800e3f:	c7 44 24 08 a8 14 80 	movl   $0x8014a8,0x8(%esp)
  800e46:	00 
  800e47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4e:	00 
  800e4f:	c7 04 24 c5 14 80 00 	movl   $0x8014c5,(%esp)
  800e56:	e8 28 f3 ff ff       	call   800183 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e5b:	83 c4 2c             	add    $0x2c,%esp
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e69:	be 00 00 00 00       	mov    $0x0,%esi
  800e6e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e76:	8b 55 08             	mov    0x8(%ebp),%edx
  800e79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e7f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	57                   	push   %edi
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
  800e8c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e94:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e99:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9c:	89 cb                	mov    %ecx,%ebx
  800e9e:	89 cf                	mov    %ecx,%edi
  800ea0:	89 ce                	mov    %ecx,%esi
  800ea2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	7e 28                	jle    800ed0 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eac:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800eb3:	00 
  800eb4:	c7 44 24 08 a8 14 80 	movl   $0x8014a8,0x8(%esp)
  800ebb:	00 
  800ebc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec3:	00 
  800ec4:	c7 04 24 c5 14 80 00 	movl   $0x8014c5,(%esp)
  800ecb:	e8 b3 f2 ff ff       	call   800183 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ed0:	83 c4 2c             	add    $0x2c,%esp
  800ed3:	5b                   	pop    %ebx
  800ed4:	5e                   	pop    %esi
  800ed5:	5f                   	pop    %edi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800ede:	c7 44 24 08 df 14 80 	movl   $0x8014df,0x8(%esp)
  800ee5:	00 
  800ee6:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800eed:	00 
  800eee:	c7 04 24 d3 14 80 00 	movl   $0x8014d3,(%esp)
  800ef5:	e8 89 f2 ff ff       	call   800183 <_panic>

00800efa <sfork>:
}

// Challenge!
int
sfork(void)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800f00:	c7 44 24 08 de 14 80 	movl   $0x8014de,0x8(%esp)
  800f07:	00 
  800f08:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800f0f:	00 
  800f10:	c7 04 24 d3 14 80 00 	movl   $0x8014d3,(%esp)
  800f17:	e8 67 f2 ff ff       	call   800183 <_panic>
  800f1c:	66 90                	xchg   %ax,%ax
  800f1e:	66 90                	xchg   %ax,%ax

00800f20 <__udivdi3>:
  800f20:	55                   	push   %ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	83 ec 0c             	sub    $0xc,%esp
  800f26:	8b 44 24 28          	mov    0x28(%esp),%eax
  800f2a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  800f2e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  800f32:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  800f36:	85 c0                	test   %eax,%eax
  800f38:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f3c:	89 ea                	mov    %ebp,%edx
  800f3e:	89 0c 24             	mov    %ecx,(%esp)
  800f41:	75 2d                	jne    800f70 <__udivdi3+0x50>
  800f43:	39 e9                	cmp    %ebp,%ecx
  800f45:	77 61                	ja     800fa8 <__udivdi3+0x88>
  800f47:	85 c9                	test   %ecx,%ecx
  800f49:	89 ce                	mov    %ecx,%esi
  800f4b:	75 0b                	jne    800f58 <__udivdi3+0x38>
  800f4d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f52:	31 d2                	xor    %edx,%edx
  800f54:	f7 f1                	div    %ecx
  800f56:	89 c6                	mov    %eax,%esi
  800f58:	31 d2                	xor    %edx,%edx
  800f5a:	89 e8                	mov    %ebp,%eax
  800f5c:	f7 f6                	div    %esi
  800f5e:	89 c5                	mov    %eax,%ebp
  800f60:	89 f8                	mov    %edi,%eax
  800f62:	f7 f6                	div    %esi
  800f64:	89 ea                	mov    %ebp,%edx
  800f66:	83 c4 0c             	add    $0xc,%esp
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    
  800f6d:	8d 76 00             	lea    0x0(%esi),%esi
  800f70:	39 e8                	cmp    %ebp,%eax
  800f72:	77 24                	ja     800f98 <__udivdi3+0x78>
  800f74:	0f bd e8             	bsr    %eax,%ebp
  800f77:	83 f5 1f             	xor    $0x1f,%ebp
  800f7a:	75 3c                	jne    800fb8 <__udivdi3+0x98>
  800f7c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f80:	39 34 24             	cmp    %esi,(%esp)
  800f83:	0f 86 9f 00 00 00    	jbe    801028 <__udivdi3+0x108>
  800f89:	39 d0                	cmp    %edx,%eax
  800f8b:	0f 82 97 00 00 00    	jb     801028 <__udivdi3+0x108>
  800f91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f98:	31 d2                	xor    %edx,%edx
  800f9a:	31 c0                	xor    %eax,%eax
  800f9c:	83 c4 0c             	add    $0xc,%esp
  800f9f:	5e                   	pop    %esi
  800fa0:	5f                   	pop    %edi
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    
  800fa3:	90                   	nop
  800fa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fa8:	89 f8                	mov    %edi,%eax
  800faa:	f7 f1                	div    %ecx
  800fac:	31 d2                	xor    %edx,%edx
  800fae:	83 c4 0c             	add    $0xc,%esp
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    
  800fb5:	8d 76 00             	lea    0x0(%esi),%esi
  800fb8:	89 e9                	mov    %ebp,%ecx
  800fba:	8b 3c 24             	mov    (%esp),%edi
  800fbd:	d3 e0                	shl    %cl,%eax
  800fbf:	89 c6                	mov    %eax,%esi
  800fc1:	b8 20 00 00 00       	mov    $0x20,%eax
  800fc6:	29 e8                	sub    %ebp,%eax
  800fc8:	89 c1                	mov    %eax,%ecx
  800fca:	d3 ef                	shr    %cl,%edi
  800fcc:	89 e9                	mov    %ebp,%ecx
  800fce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fd2:	8b 3c 24             	mov    (%esp),%edi
  800fd5:	09 74 24 08          	or     %esi,0x8(%esp)
  800fd9:	89 d6                	mov    %edx,%esi
  800fdb:	d3 e7                	shl    %cl,%edi
  800fdd:	89 c1                	mov    %eax,%ecx
  800fdf:	89 3c 24             	mov    %edi,(%esp)
  800fe2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800fe6:	d3 ee                	shr    %cl,%esi
  800fe8:	89 e9                	mov    %ebp,%ecx
  800fea:	d3 e2                	shl    %cl,%edx
  800fec:	89 c1                	mov    %eax,%ecx
  800fee:	d3 ef                	shr    %cl,%edi
  800ff0:	09 d7                	or     %edx,%edi
  800ff2:	89 f2                	mov    %esi,%edx
  800ff4:	89 f8                	mov    %edi,%eax
  800ff6:	f7 74 24 08          	divl   0x8(%esp)
  800ffa:	89 d6                	mov    %edx,%esi
  800ffc:	89 c7                	mov    %eax,%edi
  800ffe:	f7 24 24             	mull   (%esp)
  801001:	39 d6                	cmp    %edx,%esi
  801003:	89 14 24             	mov    %edx,(%esp)
  801006:	72 30                	jb     801038 <__udivdi3+0x118>
  801008:	8b 54 24 04          	mov    0x4(%esp),%edx
  80100c:	89 e9                	mov    %ebp,%ecx
  80100e:	d3 e2                	shl    %cl,%edx
  801010:	39 c2                	cmp    %eax,%edx
  801012:	73 05                	jae    801019 <__udivdi3+0xf9>
  801014:	3b 34 24             	cmp    (%esp),%esi
  801017:	74 1f                	je     801038 <__udivdi3+0x118>
  801019:	89 f8                	mov    %edi,%eax
  80101b:	31 d2                	xor    %edx,%edx
  80101d:	e9 7a ff ff ff       	jmp    800f9c <__udivdi3+0x7c>
  801022:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801028:	31 d2                	xor    %edx,%edx
  80102a:	b8 01 00 00 00       	mov    $0x1,%eax
  80102f:	e9 68 ff ff ff       	jmp    800f9c <__udivdi3+0x7c>
  801034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801038:	8d 47 ff             	lea    -0x1(%edi),%eax
  80103b:	31 d2                	xor    %edx,%edx
  80103d:	83 c4 0c             	add    $0xc,%esp
  801040:	5e                   	pop    %esi
  801041:	5f                   	pop    %edi
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    
  801044:	66 90                	xchg   %ax,%ax
  801046:	66 90                	xchg   %ax,%ax
  801048:	66 90                	xchg   %ax,%ax
  80104a:	66 90                	xchg   %ax,%ax
  80104c:	66 90                	xchg   %ax,%ax
  80104e:	66 90                	xchg   %ax,%ax

00801050 <__umoddi3>:
  801050:	55                   	push   %ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	83 ec 14             	sub    $0x14,%esp
  801056:	8b 44 24 28          	mov    0x28(%esp),%eax
  80105a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80105e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801062:	89 c7                	mov    %eax,%edi
  801064:	89 44 24 04          	mov    %eax,0x4(%esp)
  801068:	8b 44 24 30          	mov    0x30(%esp),%eax
  80106c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801070:	89 34 24             	mov    %esi,(%esp)
  801073:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801077:	85 c0                	test   %eax,%eax
  801079:	89 c2                	mov    %eax,%edx
  80107b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80107f:	75 17                	jne    801098 <__umoddi3+0x48>
  801081:	39 fe                	cmp    %edi,%esi
  801083:	76 4b                	jbe    8010d0 <__umoddi3+0x80>
  801085:	89 c8                	mov    %ecx,%eax
  801087:	89 fa                	mov    %edi,%edx
  801089:	f7 f6                	div    %esi
  80108b:	89 d0                	mov    %edx,%eax
  80108d:	31 d2                	xor    %edx,%edx
  80108f:	83 c4 14             	add    $0x14,%esp
  801092:	5e                   	pop    %esi
  801093:	5f                   	pop    %edi
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    
  801096:	66 90                	xchg   %ax,%ax
  801098:	39 f8                	cmp    %edi,%eax
  80109a:	77 54                	ja     8010f0 <__umoddi3+0xa0>
  80109c:	0f bd e8             	bsr    %eax,%ebp
  80109f:	83 f5 1f             	xor    $0x1f,%ebp
  8010a2:	75 5c                	jne    801100 <__umoddi3+0xb0>
  8010a4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010a8:	39 3c 24             	cmp    %edi,(%esp)
  8010ab:	0f 87 e7 00 00 00    	ja     801198 <__umoddi3+0x148>
  8010b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8010b5:	29 f1                	sub    %esi,%ecx
  8010b7:	19 c7                	sbb    %eax,%edi
  8010b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010c1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010c5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8010c9:	83 c4 14             	add    $0x14,%esp
  8010cc:	5e                   	pop    %esi
  8010cd:	5f                   	pop    %edi
  8010ce:	5d                   	pop    %ebp
  8010cf:	c3                   	ret    
  8010d0:	85 f6                	test   %esi,%esi
  8010d2:	89 f5                	mov    %esi,%ebp
  8010d4:	75 0b                	jne    8010e1 <__umoddi3+0x91>
  8010d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010db:	31 d2                	xor    %edx,%edx
  8010dd:	f7 f6                	div    %esi
  8010df:	89 c5                	mov    %eax,%ebp
  8010e1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010e5:	31 d2                	xor    %edx,%edx
  8010e7:	f7 f5                	div    %ebp
  8010e9:	89 c8                	mov    %ecx,%eax
  8010eb:	f7 f5                	div    %ebp
  8010ed:	eb 9c                	jmp    80108b <__umoddi3+0x3b>
  8010ef:	90                   	nop
  8010f0:	89 c8                	mov    %ecx,%eax
  8010f2:	89 fa                	mov    %edi,%edx
  8010f4:	83 c4 14             	add    $0x14,%esp
  8010f7:	5e                   	pop    %esi
  8010f8:	5f                   	pop    %edi
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    
  8010fb:	90                   	nop
  8010fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801100:	8b 04 24             	mov    (%esp),%eax
  801103:	be 20 00 00 00       	mov    $0x20,%esi
  801108:	89 e9                	mov    %ebp,%ecx
  80110a:	29 ee                	sub    %ebp,%esi
  80110c:	d3 e2                	shl    %cl,%edx
  80110e:	89 f1                	mov    %esi,%ecx
  801110:	d3 e8                	shr    %cl,%eax
  801112:	89 e9                	mov    %ebp,%ecx
  801114:	89 44 24 04          	mov    %eax,0x4(%esp)
  801118:	8b 04 24             	mov    (%esp),%eax
  80111b:	09 54 24 04          	or     %edx,0x4(%esp)
  80111f:	89 fa                	mov    %edi,%edx
  801121:	d3 e0                	shl    %cl,%eax
  801123:	89 f1                	mov    %esi,%ecx
  801125:	89 44 24 08          	mov    %eax,0x8(%esp)
  801129:	8b 44 24 10          	mov    0x10(%esp),%eax
  80112d:	d3 ea                	shr    %cl,%edx
  80112f:	89 e9                	mov    %ebp,%ecx
  801131:	d3 e7                	shl    %cl,%edi
  801133:	89 f1                	mov    %esi,%ecx
  801135:	d3 e8                	shr    %cl,%eax
  801137:	89 e9                	mov    %ebp,%ecx
  801139:	09 f8                	or     %edi,%eax
  80113b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80113f:	f7 74 24 04          	divl   0x4(%esp)
  801143:	d3 e7                	shl    %cl,%edi
  801145:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801149:	89 d7                	mov    %edx,%edi
  80114b:	f7 64 24 08          	mull   0x8(%esp)
  80114f:	39 d7                	cmp    %edx,%edi
  801151:	89 c1                	mov    %eax,%ecx
  801153:	89 14 24             	mov    %edx,(%esp)
  801156:	72 2c                	jb     801184 <__umoddi3+0x134>
  801158:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80115c:	72 22                	jb     801180 <__umoddi3+0x130>
  80115e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801162:	29 c8                	sub    %ecx,%eax
  801164:	19 d7                	sbb    %edx,%edi
  801166:	89 e9                	mov    %ebp,%ecx
  801168:	89 fa                	mov    %edi,%edx
  80116a:	d3 e8                	shr    %cl,%eax
  80116c:	89 f1                	mov    %esi,%ecx
  80116e:	d3 e2                	shl    %cl,%edx
  801170:	89 e9                	mov    %ebp,%ecx
  801172:	d3 ef                	shr    %cl,%edi
  801174:	09 d0                	or     %edx,%eax
  801176:	89 fa                	mov    %edi,%edx
  801178:	83 c4 14             	add    $0x14,%esp
  80117b:	5e                   	pop    %esi
  80117c:	5f                   	pop    %edi
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    
  80117f:	90                   	nop
  801180:	39 d7                	cmp    %edx,%edi
  801182:	75 da                	jne    80115e <__umoddi3+0x10e>
  801184:	8b 14 24             	mov    (%esp),%edx
  801187:	89 c1                	mov    %eax,%ecx
  801189:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80118d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801191:	eb cb                	jmp    80115e <__umoddi3+0x10e>
  801193:	90                   	nop
  801194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801198:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80119c:	0f 82 0f ff ff ff    	jb     8010b1 <__umoddi3+0x61>
  8011a2:	e9 1a ff ff ff       	jmp    8010c1 <__umoddi3+0x71>
