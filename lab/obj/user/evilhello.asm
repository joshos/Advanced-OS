
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 4d 00 00 00       	call   800092 <sys_cputs>
  800045:	83 c4 10             	add    $0x10,%esp
}
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	83 ec 08             	sub    $0x8,%esp
  800050:	8b 45 08             	mov    0x8(%ebp),%eax
  800053:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800056:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80005d:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 c0                	test   %eax,%eax
  800062:	7e 08                	jle    80006c <libmain+0x22>
		binaryname = argv[0];
  800064:	8b 0a                	mov    (%edx),%ecx
  800066:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80006c:	83 ec 08             	sub    $0x8,%esp
  80006f:	52                   	push   %edx
  800070:	50                   	push   %eax
  800071:	e8 bd ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800076:	e8 05 00 00 00       	call   800080 <exit>
  80007b:	83 c4 10             	add    $0x10,%esp
}
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800086:	6a 00                	push   $0x0
  800088:	e8 42 00 00 00       	call   8000cf <sys_env_destroy>
  80008d:	83 c4 10             	add    $0x10,%esp
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	57                   	push   %edi
  800096:	56                   	push   %esi
  800097:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800098:	b8 00 00 00 00       	mov    $0x0,%eax
  80009d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a3:	89 c3                	mov    %eax,%ebx
  8000a5:	89 c7                	mov    %eax,%edi
  8000a7:	89 c6                	mov    %eax,%esi
  8000a9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5f                   	pop    %edi
  8000ae:	5d                   	pop    %ebp
  8000af:	c3                   	ret    

008000b0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c0:	89 d1                	mov    %edx,%ecx
  8000c2:	89 d3                	mov    %edx,%ebx
  8000c4:	89 d7                	mov    %edx,%edi
  8000c6:	89 d6                	mov    %edx,%esi
  8000c8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
  8000d5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dd:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e5:	89 cb                	mov    %ecx,%ebx
  8000e7:	89 cf                	mov    %ecx,%edi
  8000e9:	89 ce                	mov    %ecx,%esi
  8000eb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	7e 17                	jle    800108 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f1:	83 ec 0c             	sub    $0xc,%esp
  8000f4:	50                   	push   %eax
  8000f5:	6a 03                	push   $0x3
  8000f7:	68 aa 0d 80 00       	push   $0x800daa
  8000fc:	6a 23                	push   $0x23
  8000fe:	68 c7 0d 80 00       	push   $0x800dc7
  800103:	e8 27 00 00 00       	call   80012f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010b:	5b                   	pop    %ebx
  80010c:	5e                   	pop    %esi
  80010d:	5f                   	pop    %edi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	57                   	push   %edi
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800116:	ba 00 00 00 00       	mov    $0x0,%edx
  80011b:	b8 02 00 00 00       	mov    $0x2,%eax
  800120:	89 d1                	mov    %edx,%ecx
  800122:	89 d3                	mov    %edx,%ebx
  800124:	89 d7                	mov    %edx,%edi
  800126:	89 d6                	mov    %edx,%esi
  800128:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800134:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800137:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80013d:	e8 ce ff ff ff       	call   800110 <sys_getenvid>
  800142:	83 ec 0c             	sub    $0xc,%esp
  800145:	ff 75 0c             	pushl  0xc(%ebp)
  800148:	ff 75 08             	pushl  0x8(%ebp)
  80014b:	56                   	push   %esi
  80014c:	50                   	push   %eax
  80014d:	68 d8 0d 80 00       	push   $0x800dd8
  800152:	e8 b1 00 00 00       	call   800208 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800157:	83 c4 18             	add    $0x18,%esp
  80015a:	53                   	push   %ebx
  80015b:	ff 75 10             	pushl  0x10(%ebp)
  80015e:	e8 54 00 00 00       	call   8001b7 <vcprintf>
	cprintf("\n");
  800163:	c7 04 24 fc 0d 80 00 	movl   $0x800dfc,(%esp)
  80016a:	e8 99 00 00 00       	call   800208 <cprintf>
  80016f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800172:	cc                   	int3   
  800173:	eb fd                	jmp    800172 <_panic+0x43>

00800175 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	53                   	push   %ebx
  800179:	83 ec 04             	sub    $0x4,%esp
  80017c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017f:	8b 13                	mov    (%ebx),%edx
  800181:	8d 42 01             	lea    0x1(%edx),%eax
  800184:	89 03                	mov    %eax,(%ebx)
  800186:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800189:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800192:	75 1a                	jne    8001ae <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800194:	83 ec 08             	sub    $0x8,%esp
  800197:	68 ff 00 00 00       	push   $0xff
  80019c:	8d 43 08             	lea    0x8(%ebx),%eax
  80019f:	50                   	push   %eax
  8001a0:	e8 ed fe ff ff       	call   800092 <sys_cputs>
		b->idx = 0;
  8001a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ab:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ae:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    

008001b7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c7:	00 00 00 
	b.cnt = 0;
  8001ca:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d4:	ff 75 0c             	pushl  0xc(%ebp)
  8001d7:	ff 75 08             	pushl  0x8(%ebp)
  8001da:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	68 75 01 80 00       	push   $0x800175
  8001e6:	e8 4f 01 00 00       	call   80033a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001eb:	83 c4 08             	add    $0x8,%esp
  8001ee:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 92 fe ff ff       	call   800092 <sys_cputs>

	return b.cnt;
}
  800200:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800211:	50                   	push   %eax
  800212:	ff 75 08             	pushl  0x8(%ebp)
  800215:	e8 9d ff ff ff       	call   8001b7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 1c             	sub    $0x1c,%esp
  800225:	89 c7                	mov    %eax,%edi
  800227:	89 d6                	mov    %edx,%esi
  800229:	8b 45 08             	mov    0x8(%ebp),%eax
  80022c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022f:	89 d1                	mov    %edx,%ecx
  800231:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800234:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800237:	8b 45 10             	mov    0x10(%ebp),%eax
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800240:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800247:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80024a:	72 05                	jb     800251 <printnum+0x35>
  80024c:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80024f:	77 3e                	ja     80028f <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800251:	83 ec 0c             	sub    $0xc,%esp
  800254:	ff 75 18             	pushl  0x18(%ebp)
  800257:	83 eb 01             	sub    $0x1,%ebx
  80025a:	53                   	push   %ebx
  80025b:	50                   	push   %eax
  80025c:	83 ec 08             	sub    $0x8,%esp
  80025f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800262:	ff 75 e0             	pushl  -0x20(%ebp)
  800265:	ff 75 dc             	pushl  -0x24(%ebp)
  800268:	ff 75 d8             	pushl  -0x28(%ebp)
  80026b:	e8 70 08 00 00       	call   800ae0 <__udivdi3>
  800270:	83 c4 18             	add    $0x18,%esp
  800273:	52                   	push   %edx
  800274:	50                   	push   %eax
  800275:	89 f2                	mov    %esi,%edx
  800277:	89 f8                	mov    %edi,%eax
  800279:	e8 9e ff ff ff       	call   80021c <printnum>
  80027e:	83 c4 20             	add    $0x20,%esp
  800281:	eb 13                	jmp    800296 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800283:	83 ec 08             	sub    $0x8,%esp
  800286:	56                   	push   %esi
  800287:	ff 75 18             	pushl  0x18(%ebp)
  80028a:	ff d7                	call   *%edi
  80028c:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028f:	83 eb 01             	sub    $0x1,%ebx
  800292:	85 db                	test   %ebx,%ebx
  800294:	7f ed                	jg     800283 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	56                   	push   %esi
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a9:	e8 62 09 00 00       	call   800c10 <__umoddi3>
  8002ae:	83 c4 14             	add    $0x14,%esp
  8002b1:	0f be 80 fe 0d 80 00 	movsbl 0x800dfe(%eax),%eax
  8002b8:	50                   	push   %eax
  8002b9:	ff d7                	call   *%edi
  8002bb:	83 c4 10             	add    $0x10,%esp
}
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c9:	83 fa 01             	cmp    $0x1,%edx
  8002cc:	7e 0e                	jle    8002dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	8b 52 04             	mov    0x4(%edx),%edx
  8002da:	eb 22                	jmp    8002fe <getuint+0x38>
	else if (lflag)
  8002dc:	85 d2                	test   %edx,%edx
  8002de:	74 10                	je     8002f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ee:	eb 0e                	jmp    8002fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800306:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030a:	8b 10                	mov    (%eax),%edx
  80030c:	3b 50 04             	cmp    0x4(%eax),%edx
  80030f:	73 0a                	jae    80031b <sprintputch+0x1b>
		*b->buf++ = ch;
  800311:	8d 4a 01             	lea    0x1(%edx),%ecx
  800314:	89 08                	mov    %ecx,(%eax)
  800316:	8b 45 08             	mov    0x8(%ebp),%eax
  800319:	88 02                	mov    %al,(%edx)
}
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800323:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 10             	pushl  0x10(%ebp)
  80032a:	ff 75 0c             	pushl  0xc(%ebp)
  80032d:	ff 75 08             	pushl  0x8(%ebp)
  800330:	e8 05 00 00 00       	call   80033a <vprintfmt>
	va_end(ap);
  800335:	83 c4 10             	add    $0x10,%esp
}
  800338:	c9                   	leave  
  800339:	c3                   	ret    

0080033a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	57                   	push   %edi
  80033e:	56                   	push   %esi
  80033f:	53                   	push   %ebx
  800340:	83 ec 2c             	sub    $0x2c,%esp
  800343:	8b 75 08             	mov    0x8(%ebp),%esi
  800346:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800349:	8b 7d 10             	mov    0x10(%ebp),%edi
  80034c:	eb 12                	jmp    800360 <vprintfmt+0x26>

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
		{
			if (ch == '\0')
  80034e:	85 c0                	test   %eax,%eax
  800350:	0f 84 90 03 00 00    	je     8006e6 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800356:	83 ec 08             	sub    $0x8,%esp
  800359:	53                   	push   %ebx
  80035a:	50                   	push   %eax
  80035b:	ff d6                	call   *%esi
  80035d:	83 c4 10             	add    $0x10,%esp
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
  800360:	83 c7 01             	add    $0x1,%edi
  800363:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800367:	83 f8 25             	cmp    $0x25,%eax
  80036a:	75 e2                	jne    80034e <vprintfmt+0x14>
  80036c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800370:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800377:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800385:	ba 00 00 00 00       	mov    $0x0,%edx
  80038a:	eb 07                	jmp    800393 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		{

			// flag to pad on the right
			case '-':
				padc = '-';
  80038f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800393:	8d 47 01             	lea    0x1(%edi),%eax
  800396:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800399:	0f b6 07             	movzbl (%edi),%eax
  80039c:	0f b6 c8             	movzbl %al,%ecx
  80039f:	83 e8 23             	sub    $0x23,%eax
  8003a2:	3c 55                	cmp    $0x55,%al
  8003a4:	0f 87 21 03 00 00    	ja     8006cb <vprintfmt+0x391>
  8003aa:	0f b6 c0             	movzbl %al,%eax
  8003ad:	ff 24 85 a0 0e 80 00 	jmp    *0x800ea0(,%eax,4)
  8003b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				padc = '-';
				goto reswitch;

			// flag to pad with 0's instead of spaces
			case '0':
				padc = '0';
  8003b7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003bb:	eb d6                	jmp    800393 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
					precision = precision * 10 + ch - '0';
  8003c8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003cb:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
					ch = *fmt;
  8003cf:	0f be 0f             	movsbl (%edi),%ecx
					if (ch < '0' || ch > '9')
  8003d2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d5:	83 fa 09             	cmp    $0x9,%edx
  8003d8:	77 39                	ja     800413 <vprintfmt+0xd9>
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
  8003da:	83 c7 01             	add    $0x1,%edi
					precision = precision * 10 + ch - '0';
					ch = *fmt;
					if (ch < '0' || ch > '9')
						break;
				}
  8003dd:	eb e9                	jmp    8003c8 <vprintfmt+0x8e>
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
  8003df:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e2:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e8:	8b 00                	mov    (%eax),%eax
  8003ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				}
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
				goto process_precision;
  8003f0:	eb 27                	jmp    800419 <vprintfmt+0xdf>
  8003f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f5:	85 c0                	test   %eax,%eax
  8003f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fc:	0f 49 c8             	cmovns %eax,%ecx
  8003ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800402:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800405:	eb 8c                	jmp    800393 <vprintfmt+0x59>
  800407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				if (width < 0)
					width = 0;
				goto reswitch;

			case '#':
				altflag = 1;
  80040a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				goto reswitch;
  800411:	eb 80                	jmp    800393 <vprintfmt+0x59>
  800413:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800416:	89 45 d0             	mov    %eax,-0x30(%ebp)

			process_precision:
				if (width < 0)
  800419:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041d:	0f 89 70 ff ff ff    	jns    800393 <vprintfmt+0x59>
					width = precision, precision = -1;
  800423:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800426:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800429:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800430:	e9 5e ff ff ff       	jmp    800393 <vprintfmt+0x59>
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
  800435:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
				goto reswitch;
  80043b:	e9 53 ff ff ff       	jmp    800393 <vprintfmt+0x59>

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	53                   	push   %ebx
  80044d:	ff 30                	pushl  (%eax)
  80044f:	ff d6                	call   *%esi
				break;
  800451:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
				break;
  800457:	e9 04 ff ff ff       	jmp    800360 <vprintfmt+0x26>

			// error message
			case 'e':
				err = va_arg(ap, int);
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	8b 00                	mov    (%eax),%eax
  800467:	99                   	cltd   
  800468:	31 d0                	xor    %edx,%eax
  80046a:	29 d0                	sub    %edx,%eax
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046c:	83 f8 07             	cmp    $0x7,%eax
  80046f:	7f 0b                	jg     80047c <vprintfmt+0x142>
  800471:	8b 14 85 00 10 80 00 	mov    0x801000(,%eax,4),%edx
  800478:	85 d2                	test   %edx,%edx
  80047a:	75 18                	jne    800494 <vprintfmt+0x15a>
					printfmt(putch, putdat, "error %d", err);
  80047c:	50                   	push   %eax
  80047d:	68 16 0e 80 00       	push   $0x800e16
  800482:	53                   	push   %ebx
  800483:	56                   	push   %esi
  800484:	e8 94 fe ff ff       	call   80031d <printfmt>
  800489:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  80048c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			case 'e':
				err = va_arg(ap, int);
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
					printfmt(putch, putdat, "error %d", err);
  80048f:	e9 cc fe ff ff       	jmp    800360 <vprintfmt+0x26>
				else
					printfmt(putch, putdat, "%s", p);
  800494:	52                   	push   %edx
  800495:	68 1f 0e 80 00       	push   $0x800e1f
  80049a:	53                   	push   %ebx
  80049b:	56                   	push   %esi
  80049c:	e8 7c fe ff ff       	call   80031d <printfmt>
  8004a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8004a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a7:	e9 b4 fe ff ff       	jmp    800360 <vprintfmt+0x26>
  8004ac:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004af:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004b2:	89 45 cc             	mov    %eax,-0x34(%ebp)
					printfmt(putch, putdat, "%s", p);
				break;

			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
  8004b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b8:	8d 50 04             	lea    0x4(%eax),%edx
  8004bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004be:	8b 38                	mov    (%eax),%edi
					p = "(null)";
  8004c0:	85 ff                	test   %edi,%edi
  8004c2:	ba 0f 0e 80 00       	mov    $0x800e0f,%edx
  8004c7:	0f 44 fa             	cmove  %edx,%edi
				if (width > 0 && padc != '-')
  8004ca:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ce:	0f 84 92 00 00 00    	je     800566 <vprintfmt+0x22c>
  8004d4:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004d8:	0f 8e 96 00 00 00    	jle    800574 <vprintfmt+0x23a>
					for (width -= strnlen(p, precision); width > 0; width--)
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	51                   	push   %ecx
  8004e2:	57                   	push   %edi
  8004e3:	e8 86 02 00 00       	call   80076e <strnlen>
  8004e8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004eb:	29 c1                	sub    %eax,%ecx
  8004ed:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004f0:	83 c4 10             	add    $0x10,%esp
						putch(padc, putdat);
  8004f3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004fa:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004fd:	89 cf                	mov    %ecx,%edi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  8004ff:	eb 0f                	jmp    800510 <vprintfmt+0x1d6>
						putch(padc, putdat);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	53                   	push   %ebx
  800505:	ff 75 e0             	pushl  -0x20(%ebp)
  800508:	ff d6                	call   *%esi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  80050a:	83 ef 01             	sub    $0x1,%edi
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	85 ff                	test   %edi,%edi
  800512:	7f ed                	jg     800501 <vprintfmt+0x1c7>
  800514:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800517:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80051a:	85 c9                	test   %ecx,%ecx
  80051c:	b8 00 00 00 00       	mov    $0x0,%eax
  800521:	0f 49 c1             	cmovns %ecx,%eax
  800524:	29 c1                	sub    %eax,%ecx
  800526:	89 75 08             	mov    %esi,0x8(%ebp)
  800529:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80052c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052f:	89 cb                	mov    %ecx,%ebx
  800531:	eb 4d                	jmp    800580 <vprintfmt+0x246>
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
  800533:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800537:	74 1b                	je     800554 <vprintfmt+0x21a>
  800539:	0f be c0             	movsbl %al,%eax
  80053c:	83 e8 20             	sub    $0x20,%eax
  80053f:	83 f8 5e             	cmp    $0x5e,%eax
  800542:	76 10                	jbe    800554 <vprintfmt+0x21a>
						putch('?', putdat);
  800544:	83 ec 08             	sub    $0x8,%esp
  800547:	ff 75 0c             	pushl  0xc(%ebp)
  80054a:	6a 3f                	push   $0x3f
  80054c:	ff 55 08             	call   *0x8(%ebp)
  80054f:	83 c4 10             	add    $0x10,%esp
  800552:	eb 0d                	jmp    800561 <vprintfmt+0x227>
					else
						putch(ch, putdat);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	ff 75 0c             	pushl  0xc(%ebp)
  80055a:	52                   	push   %edx
  80055b:	ff 55 08             	call   *0x8(%ebp)
  80055e:	83 c4 10             	add    $0x10,%esp
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800561:	83 eb 01             	sub    $0x1,%ebx
  800564:	eb 1a                	jmp    800580 <vprintfmt+0x246>
  800566:	89 75 08             	mov    %esi,0x8(%ebp)
  800569:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800572:	eb 0c                	jmp    800580 <vprintfmt+0x246>
  800574:	89 75 08             	mov    %esi,0x8(%ebp)
  800577:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80057a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800580:	83 c7 01             	add    $0x1,%edi
  800583:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800587:	0f be d0             	movsbl %al,%edx
  80058a:	85 d2                	test   %edx,%edx
  80058c:	74 23                	je     8005b1 <vprintfmt+0x277>
  80058e:	85 f6                	test   %esi,%esi
  800590:	78 a1                	js     800533 <vprintfmt+0x1f9>
  800592:	83 ee 01             	sub    $0x1,%esi
  800595:	79 9c                	jns    800533 <vprintfmt+0x1f9>
  800597:	89 df                	mov    %ebx,%edi
  800599:	8b 75 08             	mov    0x8(%ebp),%esi
  80059c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059f:	eb 18                	jmp    8005b9 <vprintfmt+0x27f>
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
					putch(' ', putdat);
  8005a1:	83 ec 08             	sub    $0x8,%esp
  8005a4:	53                   	push   %ebx
  8005a5:	6a 20                	push   $0x20
  8005a7:	ff d6                	call   *%esi
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
  8005a9:	83 ef 01             	sub    $0x1,%edi
  8005ac:	83 c4 10             	add    $0x10,%esp
  8005af:	eb 08                	jmp    8005b9 <vprintfmt+0x27f>
  8005b1:	89 df                	mov    %ebx,%edi
  8005b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b9:	85 ff                	test   %edi,%edi
  8005bb:	7f e4                	jg     8005a1 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8005bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c0:	e9 9b fd ff ff       	jmp    800360 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c5:	83 fa 01             	cmp    $0x1,%edx
  8005c8:	7e 16                	jle    8005e0 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 08             	lea    0x8(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 50 04             	mov    0x4(%eax),%edx
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005db:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005de:	eb 32                	jmp    800612 <vprintfmt+0x2d8>
	else if (lflag)
  8005e0:	85 d2                	test   %edx,%edx
  8005e2:	74 18                	je     8005fc <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ed:	8b 00                	mov    (%eax),%eax
  8005ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f2:	89 c1                	mov    %eax,%ecx
  8005f4:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005fa:	eb 16                	jmp    800612 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 50 04             	lea    0x4(%eax),%edx
  800602:	89 55 14             	mov    %edx,0x14(%ebp)
  800605:	8b 00                	mov    (%eax),%eax
  800607:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060a:	89 c1                	mov    %eax,%ecx
  80060c:	c1 f9 1f             	sar    $0x1f,%ecx
  80060f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(' ', putdat);
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
  800612:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800615:	8b 55 dc             	mov    -0x24(%ebp),%edx
				if ((long long) num < 0) {
					putch('-', putdat);
					num = -(long long) num;
				}
				base = 10;
  800618:	b9 0a 00 00 00       	mov    $0xa,%ecx
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
				if ((long long) num < 0) {
  80061d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800621:	79 74                	jns    800697 <vprintfmt+0x35d>
					putch('-', putdat);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	53                   	push   %ebx
  800627:	6a 2d                	push   $0x2d
  800629:	ff d6                	call   *%esi
					num = -(long long) num;
  80062b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80062e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800631:	f7 d8                	neg    %eax
  800633:	83 d2 00             	adc    $0x0,%edx
  800636:	f7 da                	neg    %edx
  800638:	83 c4 10             	add    $0x10,%esp
				}
				base = 10;
  80063b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800640:	eb 55                	jmp    800697 <vprintfmt+0x35d>
				goto number;

			// unsigned decimal
			case 'u':
				num = getuint(&ap, lflag);
  800642:	8d 45 14             	lea    0x14(%ebp),%eax
  800645:	e8 7c fc ff ff       	call   8002c6 <getuint>
				base = 10;
  80064a:	b9 0a 00 00 00       	mov    $0xa,%ecx
				goto number;
  80064f:	eb 46                	jmp    800697 <vprintfmt+0x35d>
				// Replace this with your code.
				/*putch('X', putdat);
				putch('X', putdat);
				putch('X', putdat);*/
				
				num = getuint(&ap, lflag);
  800651:	8d 45 14             	lea    0x14(%ebp),%eax
  800654:	e8 6d fc ff ff       	call   8002c6 <getuint>
				base = 8;
  800659:	b9 08 00 00 00       	mov    $0x8,%ecx
				goto number;
  80065e:	eb 37                	jmp    800697 <vprintfmt+0x35d>

			// pointer
			case 'p':
				putch('0', putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	53                   	push   %ebx
  800664:	6a 30                	push   $0x30
  800666:	ff d6                	call   *%esi
				putch('x', putdat);
  800668:	83 c4 08             	add    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 78                	push   $0x78
  80066e:	ff d6                	call   *%esi
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8d 50 04             	lea    0x4(%eax),%edx
  800676:	89 55 14             	mov    %edx,0x14(%ebp)

			// pointer
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
  800679:	8b 00                	mov    (%eax),%eax
  80067b:	ba 00 00 00 00       	mov    $0x0,%edx
					(uintptr_t) va_arg(ap, void *);
				base = 16;
				goto number;
  800680:	83 c4 10             	add    $0x10,%esp
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
				base = 16;
  800683:	b9 10 00 00 00       	mov    $0x10,%ecx
				goto number;
  800688:	eb 0d                	jmp    800697 <vprintfmt+0x35d>

			// (unsigned) hexadecimal
			case 'x':
				num = getuint(&ap, lflag);
  80068a:	8d 45 14             	lea    0x14(%ebp),%eax
  80068d:	e8 34 fc ff ff       	call   8002c6 <getuint>
				base = 16;
  800692:	b9 10 00 00 00       	mov    $0x10,%ecx
			number:
				printnum(putch, putdat, num, base, width, padc);
  800697:	83 ec 0c             	sub    $0xc,%esp
  80069a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80069e:	57                   	push   %edi
  80069f:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a2:	51                   	push   %ecx
  8006a3:	52                   	push   %edx
  8006a4:	50                   	push   %eax
  8006a5:	89 da                	mov    %ebx,%edx
  8006a7:	89 f0                	mov    %esi,%eax
  8006a9:	e8 6e fb ff ff       	call   80021c <printnum>
				break;
  8006ae:	83 c4 20             	add    $0x20,%esp
  8006b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b4:	e9 a7 fc ff ff       	jmp    800360 <vprintfmt+0x26>

			// escaped '%' character
			case '%':
				putch(ch, putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	51                   	push   %ecx
  8006be:	ff d6                	call   *%esi
				break;
  8006c0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8006c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				break;

			// escaped '%' character
			case '%':
				putch(ch, putdat);
				break;
  8006c6:	e9 95 fc ff ff       	jmp    800360 <vprintfmt+0x26>

			// unrecognized escape sequence - just print it literally
			default:
				putch('%', putdat);
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	6a 25                	push   $0x25
  8006d1:	ff d6                	call   *%esi
				for (fmt--; fmt[-1] != '%'; fmt--)
  8006d3:	83 c4 10             	add    $0x10,%esp
  8006d6:	eb 03                	jmp    8006db <vprintfmt+0x3a1>
  8006d8:	83 ef 01             	sub    $0x1,%edi
  8006db:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006df:	75 f7                	jne    8006d8 <vprintfmt+0x39e>
  8006e1:	e9 7a fc ff ff       	jmp    800360 <vprintfmt+0x26>
					/* do nothing */;
				break;
		}
	}
}
  8006e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e9:	5b                   	pop    %ebx
  8006ea:	5e                   	pop    %esi
  8006eb:	5f                   	pop    %edi
  8006ec:	5d                   	pop    %ebp
  8006ed:	c3                   	ret    

008006ee <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ee:	55                   	push   %ebp
  8006ef:	89 e5                	mov    %esp,%ebp
  8006f1:	83 ec 18             	sub    $0x18,%esp
  8006f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006fd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800701:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800704:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070b:	85 c0                	test   %eax,%eax
  80070d:	74 26                	je     800735 <vsnprintf+0x47>
  80070f:	85 d2                	test   %edx,%edx
  800711:	7e 22                	jle    800735 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800713:	ff 75 14             	pushl  0x14(%ebp)
  800716:	ff 75 10             	pushl  0x10(%ebp)
  800719:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071c:	50                   	push   %eax
  80071d:	68 00 03 80 00       	push   $0x800300
  800722:	e8 13 fc ff ff       	call   80033a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800727:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	eb 05                	jmp    80073a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800735:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    

0080073c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800742:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800745:	50                   	push   %eax
  800746:	ff 75 10             	pushl  0x10(%ebp)
  800749:	ff 75 0c             	pushl  0xc(%ebp)
  80074c:	ff 75 08             	pushl  0x8(%ebp)
  80074f:	e8 9a ff ff ff       	call   8006ee <vsnprintf>
	va_end(ap);

	return rc;
}
  800754:	c9                   	leave  
  800755:	c3                   	ret    

00800756 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075c:	b8 00 00 00 00       	mov    $0x0,%eax
  800761:	eb 03                	jmp    800766 <strlen+0x10>
		n++;
  800763:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800766:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076a:	75 f7                	jne    800763 <strlen+0xd>
		n++;
	return n;
}
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800774:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800777:	ba 00 00 00 00       	mov    $0x0,%edx
  80077c:	eb 03                	jmp    800781 <strnlen+0x13>
		n++;
  80077e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800781:	39 c2                	cmp    %eax,%edx
  800783:	74 08                	je     80078d <strnlen+0x1f>
  800785:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800789:	75 f3                	jne    80077e <strnlen+0x10>
  80078b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	53                   	push   %ebx
  800793:	8b 45 08             	mov    0x8(%ebp),%eax
  800796:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800799:	89 c2                	mov    %eax,%edx
  80079b:	83 c2 01             	add    $0x1,%edx
  80079e:	83 c1 01             	add    $0x1,%ecx
  8007a1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007a5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a8:	84 db                	test   %bl,%bl
  8007aa:	75 ef                	jne    80079b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ac:	5b                   	pop    %ebx
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	53                   	push   %ebx
  8007b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b6:	53                   	push   %ebx
  8007b7:	e8 9a ff ff ff       	call   800756 <strlen>
  8007bc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007bf:	ff 75 0c             	pushl  0xc(%ebp)
  8007c2:	01 d8                	add    %ebx,%eax
  8007c4:	50                   	push   %eax
  8007c5:	e8 c5 ff ff ff       	call   80078f <strcpy>
	return dst;
}
  8007ca:	89 d8                	mov    %ebx,%eax
  8007cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    

008007d1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	56                   	push   %esi
  8007d5:	53                   	push   %ebx
  8007d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007dc:	89 f3                	mov    %esi,%ebx
  8007de:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e1:	89 f2                	mov    %esi,%edx
  8007e3:	eb 0f                	jmp    8007f4 <strncpy+0x23>
		*dst++ = *src;
  8007e5:	83 c2 01             	add    $0x1,%edx
  8007e8:	0f b6 01             	movzbl (%ecx),%eax
  8007eb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ee:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f4:	39 da                	cmp    %ebx,%edx
  8007f6:	75 ed                	jne    8007e5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f8:	89 f0                	mov    %esi,%eax
  8007fa:	5b                   	pop    %ebx
  8007fb:	5e                   	pop    %esi
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	56                   	push   %esi
  800802:	53                   	push   %ebx
  800803:	8b 75 08             	mov    0x8(%ebp),%esi
  800806:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800809:	8b 55 10             	mov    0x10(%ebp),%edx
  80080c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080e:	85 d2                	test   %edx,%edx
  800810:	74 21                	je     800833 <strlcpy+0x35>
  800812:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800816:	89 f2                	mov    %esi,%edx
  800818:	eb 09                	jmp    800823 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081a:	83 c2 01             	add    $0x1,%edx
  80081d:	83 c1 01             	add    $0x1,%ecx
  800820:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800823:	39 c2                	cmp    %eax,%edx
  800825:	74 09                	je     800830 <strlcpy+0x32>
  800827:	0f b6 19             	movzbl (%ecx),%ebx
  80082a:	84 db                	test   %bl,%bl
  80082c:	75 ec                	jne    80081a <strlcpy+0x1c>
  80082e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800830:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800833:	29 f0                	sub    %esi,%eax
}
  800835:	5b                   	pop    %ebx
  800836:	5e                   	pop    %esi
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800839:	55                   	push   %ebp
  80083a:	89 e5                	mov    %esp,%ebp
  80083c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800842:	eb 06                	jmp    80084a <strcmp+0x11>
		p++, q++;
  800844:	83 c1 01             	add    $0x1,%ecx
  800847:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80084a:	0f b6 01             	movzbl (%ecx),%eax
  80084d:	84 c0                	test   %al,%al
  80084f:	74 04                	je     800855 <strcmp+0x1c>
  800851:	3a 02                	cmp    (%edx),%al
  800853:	74 ef                	je     800844 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800855:	0f b6 c0             	movzbl %al,%eax
  800858:	0f b6 12             	movzbl (%edx),%edx
  80085b:	29 d0                	sub    %edx,%eax
}
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	53                   	push   %ebx
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	8b 55 0c             	mov    0xc(%ebp),%edx
  800869:	89 c3                	mov    %eax,%ebx
  80086b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80086e:	eb 06                	jmp    800876 <strncmp+0x17>
		n--, p++, q++;
  800870:	83 c0 01             	add    $0x1,%eax
  800873:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800876:	39 d8                	cmp    %ebx,%eax
  800878:	74 15                	je     80088f <strncmp+0x30>
  80087a:	0f b6 08             	movzbl (%eax),%ecx
  80087d:	84 c9                	test   %cl,%cl
  80087f:	74 04                	je     800885 <strncmp+0x26>
  800881:	3a 0a                	cmp    (%edx),%cl
  800883:	74 eb                	je     800870 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800885:	0f b6 00             	movzbl (%eax),%eax
  800888:	0f b6 12             	movzbl (%edx),%edx
  80088b:	29 d0                	sub    %edx,%eax
  80088d:	eb 05                	jmp    800894 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80088f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800894:	5b                   	pop    %ebx
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a1:	eb 07                	jmp    8008aa <strchr+0x13>
		if (*s == c)
  8008a3:	38 ca                	cmp    %cl,%dl
  8008a5:	74 0f                	je     8008b6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a7:	83 c0 01             	add    $0x1,%eax
  8008aa:	0f b6 10             	movzbl (%eax),%edx
  8008ad:	84 d2                	test   %dl,%dl
  8008af:	75 f2                	jne    8008a3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c2:	eb 03                	jmp    8008c7 <strfind+0xf>
  8008c4:	83 c0 01             	add    $0x1,%eax
  8008c7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ca:	84 d2                	test   %dl,%dl
  8008cc:	74 04                	je     8008d2 <strfind+0x1a>
  8008ce:	38 ca                	cmp    %cl,%dl
  8008d0:	75 f2                	jne    8008c4 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	57                   	push   %edi
  8008d8:	56                   	push   %esi
  8008d9:	53                   	push   %ebx
  8008da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e0:	85 c9                	test   %ecx,%ecx
  8008e2:	74 36                	je     80091a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ea:	75 28                	jne    800914 <memset+0x40>
  8008ec:	f6 c1 03             	test   $0x3,%cl
  8008ef:	75 23                	jne    800914 <memset+0x40>
		c &= 0xFF;
  8008f1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f5:	89 d3                	mov    %edx,%ebx
  8008f7:	c1 e3 08             	shl    $0x8,%ebx
  8008fa:	89 d6                	mov    %edx,%esi
  8008fc:	c1 e6 18             	shl    $0x18,%esi
  8008ff:	89 d0                	mov    %edx,%eax
  800901:	c1 e0 10             	shl    $0x10,%eax
  800904:	09 f0                	or     %esi,%eax
  800906:	09 c2                	or     %eax,%edx
  800908:	89 d0                	mov    %edx,%eax
  80090a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80090c:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80090f:	fc                   	cld    
  800910:	f3 ab                	rep stos %eax,%es:(%edi)
  800912:	eb 06                	jmp    80091a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800914:	8b 45 0c             	mov    0xc(%ebp),%eax
  800917:	fc                   	cld    
  800918:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091a:	89 f8                	mov    %edi,%eax
  80091c:	5b                   	pop    %ebx
  80091d:	5e                   	pop    %esi
  80091e:	5f                   	pop    %edi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	57                   	push   %edi
  800925:	56                   	push   %esi
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	8b 75 0c             	mov    0xc(%ebp),%esi
  80092c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092f:	39 c6                	cmp    %eax,%esi
  800931:	73 35                	jae    800968 <memmove+0x47>
  800933:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800936:	39 d0                	cmp    %edx,%eax
  800938:	73 2e                	jae    800968 <memmove+0x47>
		s += n;
		d += n;
  80093a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80093d:	89 d6                	mov    %edx,%esi
  80093f:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800941:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800947:	75 13                	jne    80095c <memmove+0x3b>
  800949:	f6 c1 03             	test   $0x3,%cl
  80094c:	75 0e                	jne    80095c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80094e:	83 ef 04             	sub    $0x4,%edi
  800951:	8d 72 fc             	lea    -0x4(%edx),%esi
  800954:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800957:	fd                   	std    
  800958:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095a:	eb 09                	jmp    800965 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80095c:	83 ef 01             	sub    $0x1,%edi
  80095f:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800962:	fd                   	std    
  800963:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800965:	fc                   	cld    
  800966:	eb 1d                	jmp    800985 <memmove+0x64>
  800968:	89 f2                	mov    %esi,%edx
  80096a:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096c:	f6 c2 03             	test   $0x3,%dl
  80096f:	75 0f                	jne    800980 <memmove+0x5f>
  800971:	f6 c1 03             	test   $0x3,%cl
  800974:	75 0a                	jne    800980 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800976:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800979:	89 c7                	mov    %eax,%edi
  80097b:	fc                   	cld    
  80097c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097e:	eb 05                	jmp    800985 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800980:	89 c7                	mov    %eax,%edi
  800982:	fc                   	cld    
  800983:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800985:	5e                   	pop    %esi
  800986:	5f                   	pop    %edi
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80098c:	ff 75 10             	pushl  0x10(%ebp)
  80098f:	ff 75 0c             	pushl  0xc(%ebp)
  800992:	ff 75 08             	pushl  0x8(%ebp)
  800995:	e8 87 ff ff ff       	call   800921 <memmove>
}
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	56                   	push   %esi
  8009a0:	53                   	push   %ebx
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a7:	89 c6                	mov    %eax,%esi
  8009a9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ac:	eb 1a                	jmp    8009c8 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ae:	0f b6 08             	movzbl (%eax),%ecx
  8009b1:	0f b6 1a             	movzbl (%edx),%ebx
  8009b4:	38 d9                	cmp    %bl,%cl
  8009b6:	74 0a                	je     8009c2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009b8:	0f b6 c1             	movzbl %cl,%eax
  8009bb:	0f b6 db             	movzbl %bl,%ebx
  8009be:	29 d8                	sub    %ebx,%eax
  8009c0:	eb 0f                	jmp    8009d1 <memcmp+0x35>
		s1++, s2++;
  8009c2:	83 c0 01             	add    $0x1,%eax
  8009c5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c8:	39 f0                	cmp    %esi,%eax
  8009ca:	75 e2                	jne    8009ae <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d1:	5b                   	pop    %ebx
  8009d2:	5e                   	pop    %esi
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009de:	89 c2                	mov    %eax,%edx
  8009e0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e3:	eb 07                	jmp    8009ec <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e5:	38 08                	cmp    %cl,(%eax)
  8009e7:	74 07                	je     8009f0 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e9:	83 c0 01             	add    $0x1,%eax
  8009ec:	39 d0                	cmp    %edx,%eax
  8009ee:	72 f5                	jb     8009e5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	57                   	push   %edi
  8009f6:	56                   	push   %esi
  8009f7:	53                   	push   %ebx
  8009f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fe:	eb 03                	jmp    800a03 <strtol+0x11>
		s++;
  800a00:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a03:	0f b6 01             	movzbl (%ecx),%eax
  800a06:	3c 09                	cmp    $0x9,%al
  800a08:	74 f6                	je     800a00 <strtol+0xe>
  800a0a:	3c 20                	cmp    $0x20,%al
  800a0c:	74 f2                	je     800a00 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a0e:	3c 2b                	cmp    $0x2b,%al
  800a10:	75 0a                	jne    800a1c <strtol+0x2a>
		s++;
  800a12:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a15:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1a:	eb 10                	jmp    800a2c <strtol+0x3a>
  800a1c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a21:	3c 2d                	cmp    $0x2d,%al
  800a23:	75 07                	jne    800a2c <strtol+0x3a>
		s++, neg = 1;
  800a25:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a28:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2c:	85 db                	test   %ebx,%ebx
  800a2e:	0f 94 c0             	sete   %al
  800a31:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a37:	75 19                	jne    800a52 <strtol+0x60>
  800a39:	80 39 30             	cmpb   $0x30,(%ecx)
  800a3c:	75 14                	jne    800a52 <strtol+0x60>
  800a3e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a42:	0f 85 82 00 00 00    	jne    800aca <strtol+0xd8>
		s += 2, base = 16;
  800a48:	83 c1 02             	add    $0x2,%ecx
  800a4b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a50:	eb 16                	jmp    800a68 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a52:	84 c0                	test   %al,%al
  800a54:	74 12                	je     800a68 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a56:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5e:	75 08                	jne    800a68 <strtol+0x76>
		s++, base = 8;
  800a60:	83 c1 01             	add    $0x1,%ecx
  800a63:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a70:	0f b6 11             	movzbl (%ecx),%edx
  800a73:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a76:	89 f3                	mov    %esi,%ebx
  800a78:	80 fb 09             	cmp    $0x9,%bl
  800a7b:	77 08                	ja     800a85 <strtol+0x93>
			dig = *s - '0';
  800a7d:	0f be d2             	movsbl %dl,%edx
  800a80:	83 ea 30             	sub    $0x30,%edx
  800a83:	eb 22                	jmp    800aa7 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a85:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a88:	89 f3                	mov    %esi,%ebx
  800a8a:	80 fb 19             	cmp    $0x19,%bl
  800a8d:	77 08                	ja     800a97 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a8f:	0f be d2             	movsbl %dl,%edx
  800a92:	83 ea 57             	sub    $0x57,%edx
  800a95:	eb 10                	jmp    800aa7 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a97:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9a:	89 f3                	mov    %esi,%ebx
  800a9c:	80 fb 19             	cmp    $0x19,%bl
  800a9f:	77 16                	ja     800ab7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aa1:	0f be d2             	movsbl %dl,%edx
  800aa4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aa7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aaa:	7d 0f                	jge    800abb <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800aac:	83 c1 01             	add    $0x1,%ecx
  800aaf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab5:	eb b9                	jmp    800a70 <strtol+0x7e>
  800ab7:	89 c2                	mov    %eax,%edx
  800ab9:	eb 02                	jmp    800abd <strtol+0xcb>
  800abb:	89 c2                	mov    %eax,%edx

	if (endptr)
  800abd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac1:	74 0d                	je     800ad0 <strtol+0xde>
		*endptr = (char *) s;
  800ac3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac6:	89 0e                	mov    %ecx,(%esi)
  800ac8:	eb 06                	jmp    800ad0 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aca:	84 c0                	test   %al,%al
  800acc:	75 92                	jne    800a60 <strtol+0x6e>
  800ace:	eb 98                	jmp    800a68 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad0:	f7 da                	neg    %edx
  800ad2:	85 ff                	test   %edi,%edi
  800ad4:	0f 45 c2             	cmovne %edx,%eax
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    
  800adc:	66 90                	xchg   %ax,%ax
  800ade:	66 90                	xchg   %ax,%ax

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
