
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 4d 00 00 00       	call   80008f <sys_cputs>
  800042:	83 c4 10             	add    $0x10,%esp
}
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	83 ec 08             	sub    $0x8,%esp
  80004d:	8b 45 08             	mov    0x8(%ebp),%eax
  800050:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800053:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80005a:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005d:	85 c0                	test   %eax,%eax
  80005f:	7e 08                	jle    800069 <libmain+0x22>
		binaryname = argv[0];
  800061:	8b 0a                	mov    (%edx),%ecx
  800063:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800069:	83 ec 08             	sub    $0x8,%esp
  80006c:	52                   	push   %edx
  80006d:	50                   	push   %eax
  80006e:	e8 c0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800073:	e8 05 00 00 00       	call   80007d <exit>
  800078:	83 c4 10             	add    $0x10,%esp
}
  80007b:	c9                   	leave  
  80007c:	c3                   	ret    

0080007d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007d:	55                   	push   %ebp
  80007e:	89 e5                	mov    %esp,%ebp
  800080:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800083:	6a 00                	push   $0x0
  800085:	e8 42 00 00 00       	call   8000cc <sys_env_destroy>
  80008a:	83 c4 10             	add    $0x10,%esp
}
  80008d:	c9                   	leave  
  80008e:	c3                   	ret    

0080008f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80008f:	55                   	push   %ebp
  800090:	89 e5                	mov    %esp,%ebp
  800092:	57                   	push   %edi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800095:	b8 00 00 00 00       	mov    $0x0,%eax
  80009a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009d:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a0:	89 c3                	mov    %eax,%ebx
  8000a2:	89 c7                	mov    %eax,%edi
  8000a4:	89 c6                	mov    %eax,%esi
  8000a6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000a8:	5b                   	pop    %ebx
  8000a9:	5e                   	pop    %esi
  8000aa:	5f                   	pop    %edi
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    

008000ad <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ad:	55                   	push   %ebp
  8000ae:	89 e5                	mov    %esp,%ebp
  8000b0:	57                   	push   %edi
  8000b1:	56                   	push   %esi
  8000b2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bd:	89 d1                	mov    %edx,%ecx
  8000bf:	89 d3                	mov    %edx,%ebx
  8000c1:	89 d7                	mov    %edx,%edi
  8000c3:	89 d6                	mov    %edx,%esi
  8000c5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
  8000d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000da:	b8 03 00 00 00       	mov    $0x3,%eax
  8000df:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e2:	89 cb                	mov    %ecx,%ebx
  8000e4:	89 cf                	mov    %ecx,%edi
  8000e6:	89 ce                	mov    %ecx,%esi
  8000e8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ea:	85 c0                	test   %eax,%eax
  8000ec:	7e 17                	jle    800105 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	50                   	push   %eax
  8000f2:	6a 03                	push   $0x3
  8000f4:	68 aa 0d 80 00       	push   $0x800daa
  8000f9:	6a 23                	push   $0x23
  8000fb:	68 c7 0d 80 00       	push   $0x800dc7
  800100:	e8 27 00 00 00       	call   80012c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800113:	ba 00 00 00 00       	mov    $0x0,%edx
  800118:	b8 02 00 00 00       	mov    $0x2,%eax
  80011d:	89 d1                	mov    %edx,%ecx
  80011f:	89 d3                	mov    %edx,%ebx
  800121:	89 d7                	mov    %edx,%edi
  800123:	89 d6                	mov    %edx,%esi
  800125:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	56                   	push   %esi
  800130:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800131:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800134:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80013a:	e8 ce ff ff ff       	call   80010d <sys_getenvid>
  80013f:	83 ec 0c             	sub    $0xc,%esp
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	ff 75 08             	pushl  0x8(%ebp)
  800148:	56                   	push   %esi
  800149:	50                   	push   %eax
  80014a:	68 d8 0d 80 00       	push   $0x800dd8
  80014f:	e8 b1 00 00 00       	call   800205 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800154:	83 c4 18             	add    $0x18,%esp
  800157:	53                   	push   %ebx
  800158:	ff 75 10             	pushl  0x10(%ebp)
  80015b:	e8 54 00 00 00       	call   8001b4 <vcprintf>
	cprintf("\n");
  800160:	c7 04 24 fc 0d 80 00 	movl   $0x800dfc,(%esp)
  800167:	e8 99 00 00 00       	call   800205 <cprintf>
  80016c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016f:	cc                   	int3   
  800170:	eb fd                	jmp    80016f <_panic+0x43>

00800172 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	53                   	push   %ebx
  800176:	83 ec 04             	sub    $0x4,%esp
  800179:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017c:	8b 13                	mov    (%ebx),%edx
  80017e:	8d 42 01             	lea    0x1(%edx),%eax
  800181:	89 03                	mov    %eax,(%ebx)
  800183:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800186:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018f:	75 1a                	jne    8001ab <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800191:	83 ec 08             	sub    $0x8,%esp
  800194:	68 ff 00 00 00       	push   $0xff
  800199:	8d 43 08             	lea    0x8(%ebx),%eax
  80019c:	50                   	push   %eax
  80019d:	e8 ed fe ff ff       	call   80008f <sys_cputs>
		b->idx = 0;
  8001a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c4:	00 00 00 
	b.cnt = 0;
  8001c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d1:	ff 75 0c             	pushl  0xc(%ebp)
  8001d4:	ff 75 08             	pushl  0x8(%ebp)
  8001d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001dd:	50                   	push   %eax
  8001de:	68 72 01 80 00       	push   $0x800172
  8001e3:	e8 4f 01 00 00       	call   800337 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e8:	83 c4 08             	add    $0x8,%esp
  8001eb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f7:	50                   	push   %eax
  8001f8:	e8 92 fe ff ff       	call   80008f <sys_cputs>

	return b.cnt;
}
  8001fd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020e:	50                   	push   %eax
  80020f:	ff 75 08             	pushl  0x8(%ebp)
  800212:	e8 9d ff ff ff       	call   8001b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 1c             	sub    $0x1c,%esp
  800222:	89 c7                	mov    %eax,%edi
  800224:	89 d6                	mov    %edx,%esi
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022c:	89 d1                	mov    %edx,%ecx
  80022e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800231:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800234:	8b 45 10             	mov    0x10(%ebp),%eax
  800237:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80023d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800244:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800247:	72 05                	jb     80024e <printnum+0x35>
  800249:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80024c:	77 3e                	ja     80028c <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	ff 75 18             	pushl  0x18(%ebp)
  800254:	83 eb 01             	sub    $0x1,%ebx
  800257:	53                   	push   %ebx
  800258:	50                   	push   %eax
  800259:	83 ec 08             	sub    $0x8,%esp
  80025c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025f:	ff 75 e0             	pushl  -0x20(%ebp)
  800262:	ff 75 dc             	pushl  -0x24(%ebp)
  800265:	ff 75 d8             	pushl  -0x28(%ebp)
  800268:	e8 73 08 00 00       	call   800ae0 <__udivdi3>
  80026d:	83 c4 18             	add    $0x18,%esp
  800270:	52                   	push   %edx
  800271:	50                   	push   %eax
  800272:	89 f2                	mov    %esi,%edx
  800274:	89 f8                	mov    %edi,%eax
  800276:	e8 9e ff ff ff       	call   800219 <printnum>
  80027b:	83 c4 20             	add    $0x20,%esp
  80027e:	eb 13                	jmp    800293 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800280:	83 ec 08             	sub    $0x8,%esp
  800283:	56                   	push   %esi
  800284:	ff 75 18             	pushl  0x18(%ebp)
  800287:	ff d7                	call   *%edi
  800289:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028c:	83 eb 01             	sub    $0x1,%ebx
  80028f:	85 db                	test   %ebx,%ebx
  800291:	7f ed                	jg     800280 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	56                   	push   %esi
  800297:	83 ec 04             	sub    $0x4,%esp
  80029a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029d:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a6:	e8 65 09 00 00       	call   800c10 <__umoddi3>
  8002ab:	83 c4 14             	add    $0x14,%esp
  8002ae:	0f be 80 fe 0d 80 00 	movsbl 0x800dfe(%eax),%eax
  8002b5:	50                   	push   %eax
  8002b6:	ff d7                	call   *%edi
  8002b8:	83 c4 10             	add    $0x10,%esp
}
  8002bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c6:	83 fa 01             	cmp    $0x1,%edx
  8002c9:	7e 0e                	jle    8002d9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	8b 52 04             	mov    0x4(%edx),%edx
  8002d7:	eb 22                	jmp    8002fb <getuint+0x38>
	else if (lflag)
  8002d9:	85 d2                	test   %edx,%edx
  8002db:	74 10                	je     8002ed <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002eb:	eb 0e                	jmp    8002fb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800303:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800307:	8b 10                	mov    (%eax),%edx
  800309:	3b 50 04             	cmp    0x4(%eax),%edx
  80030c:	73 0a                	jae    800318 <sprintputch+0x1b>
		*b->buf++ = ch;
  80030e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 45 08             	mov    0x8(%ebp),%eax
  800316:	88 02                	mov    %al,(%edx)
}
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800320:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800323:	50                   	push   %eax
  800324:	ff 75 10             	pushl  0x10(%ebp)
  800327:	ff 75 0c             	pushl  0xc(%ebp)
  80032a:	ff 75 08             	pushl  0x8(%ebp)
  80032d:	e8 05 00 00 00       	call   800337 <vprintfmt>
	va_end(ap);
  800332:	83 c4 10             	add    $0x10,%esp
}
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	57                   	push   %edi
  80033b:	56                   	push   %esi
  80033c:	53                   	push   %ebx
  80033d:	83 ec 2c             	sub    $0x2c,%esp
  800340:	8b 75 08             	mov    0x8(%ebp),%esi
  800343:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800346:	8b 7d 10             	mov    0x10(%ebp),%edi
  800349:	eb 12                	jmp    80035d <vprintfmt+0x26>

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
		{
			if (ch == '\0')
  80034b:	85 c0                	test   %eax,%eax
  80034d:	0f 84 90 03 00 00    	je     8006e3 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800353:	83 ec 08             	sub    $0x8,%esp
  800356:	53                   	push   %ebx
  800357:	50                   	push   %eax
  800358:	ff d6                	call   *%esi
  80035a:	83 c4 10             	add    $0x10,%esp
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
  80035d:	83 c7 01             	add    $0x1,%edi
  800360:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800364:	83 f8 25             	cmp    $0x25,%eax
  800367:	75 e2                	jne    80034b <vprintfmt+0x14>
  800369:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80036d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800374:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80037b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
  800387:	eb 07                	jmp    800390 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		{

			// flag to pad on the right
			case '-':
				padc = '-';
  80038c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800390:	8d 47 01             	lea    0x1(%edi),%eax
  800393:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800396:	0f b6 07             	movzbl (%edi),%eax
  800399:	0f b6 c8             	movzbl %al,%ecx
  80039c:	83 e8 23             	sub    $0x23,%eax
  80039f:	3c 55                	cmp    $0x55,%al
  8003a1:	0f 87 21 03 00 00    	ja     8006c8 <vprintfmt+0x391>
  8003a7:	0f b6 c0             	movzbl %al,%eax
  8003aa:	ff 24 85 a0 0e 80 00 	jmp    *0x800ea0(,%eax,4)
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				padc = '-';
				goto reswitch;

			// flag to pad with 0's instead of spaces
			case '0':
				padc = '0';
  8003b4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b8:	eb d6                	jmp    800390 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
					precision = precision * 10 + ch - '0';
  8003c5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
					ch = *fmt;
  8003cc:	0f be 0f             	movsbl (%edi),%ecx
					if (ch < '0' || ch > '9')
  8003cf:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d2:	83 fa 09             	cmp    $0x9,%edx
  8003d5:	77 39                	ja     800410 <vprintfmt+0xd9>
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
  8003d7:	83 c7 01             	add    $0x1,%edi
					precision = precision * 10 + ch - '0';
					ch = *fmt;
					if (ch < '0' || ch > '9')
						break;
				}
  8003da:	eb e9                	jmp    8003c5 <vprintfmt+0x8e>
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
  8003dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003df:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e5:	8b 00                	mov    (%eax),%eax
  8003e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				}
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
				goto process_precision;
  8003ed:	eb 27                	jmp    800416 <vprintfmt+0xdf>
  8003ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f2:	85 c0                	test   %eax,%eax
  8003f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f9:	0f 49 c8             	cmovns %eax,%ecx
  8003fc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800402:	eb 8c                	jmp    800390 <vprintfmt+0x59>
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				if (width < 0)
					width = 0;
				goto reswitch;

			case '#':
				altflag = 1;
  800407:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				goto reswitch;
  80040e:	eb 80                	jmp    800390 <vprintfmt+0x59>
  800410:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800413:	89 45 d0             	mov    %eax,-0x30(%ebp)

			process_precision:
				if (width < 0)
  800416:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041a:	0f 89 70 ff ff ff    	jns    800390 <vprintfmt+0x59>
					width = precision, precision = -1;
  800420:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800423:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800426:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042d:	e9 5e ff ff ff       	jmp    800390 <vprintfmt+0x59>
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
  800432:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
				goto reswitch;
  800438:	e9 53 ff ff ff       	jmp    800390 <vprintfmt+0x59>

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 50 04             	lea    0x4(%eax),%edx
  800443:	89 55 14             	mov    %edx,0x14(%ebp)
  800446:	83 ec 08             	sub    $0x8,%esp
  800449:	53                   	push   %ebx
  80044a:	ff 30                	pushl  (%eax)
  80044c:	ff d6                	call   *%esi
				break;
  80044e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800451:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
				break;
  800454:	e9 04 ff ff ff       	jmp    80035d <vprintfmt+0x26>

			// error message
			case 'e':
				err = va_arg(ap, int);
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	8d 50 04             	lea    0x4(%eax),%edx
  80045f:	89 55 14             	mov    %edx,0x14(%ebp)
  800462:	8b 00                	mov    (%eax),%eax
  800464:	99                   	cltd   
  800465:	31 d0                	xor    %edx,%eax
  800467:	29 d0                	sub    %edx,%eax
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800469:	83 f8 07             	cmp    $0x7,%eax
  80046c:	7f 0b                	jg     800479 <vprintfmt+0x142>
  80046e:	8b 14 85 00 10 80 00 	mov    0x801000(,%eax,4),%edx
  800475:	85 d2                	test   %edx,%edx
  800477:	75 18                	jne    800491 <vprintfmt+0x15a>
					printfmt(putch, putdat, "error %d", err);
  800479:	50                   	push   %eax
  80047a:	68 16 0e 80 00       	push   $0x800e16
  80047f:	53                   	push   %ebx
  800480:	56                   	push   %esi
  800481:	e8 94 fe ff ff       	call   80031a <printfmt>
  800486:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			case 'e':
				err = va_arg(ap, int);
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
					printfmt(putch, putdat, "error %d", err);
  80048c:	e9 cc fe ff ff       	jmp    80035d <vprintfmt+0x26>
				else
					printfmt(putch, putdat, "%s", p);
  800491:	52                   	push   %edx
  800492:	68 1f 0e 80 00       	push   $0x800e1f
  800497:	53                   	push   %ebx
  800498:	56                   	push   %esi
  800499:	e8 7c fe ff ff       	call   80031a <printfmt>
  80049e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a4:	e9 b4 fe ff ff       	jmp    80035d <vprintfmt+0x26>
  8004a9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004af:	89 45 cc             	mov    %eax,-0x34(%ebp)
					printfmt(putch, putdat, "%s", p);
				break;

			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8d 50 04             	lea    0x4(%eax),%edx
  8004b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bb:	8b 38                	mov    (%eax),%edi
					p = "(null)";
  8004bd:	85 ff                	test   %edi,%edi
  8004bf:	ba 0f 0e 80 00       	mov    $0x800e0f,%edx
  8004c4:	0f 44 fa             	cmove  %edx,%edi
				if (width > 0 && padc != '-')
  8004c7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004cb:	0f 84 92 00 00 00    	je     800563 <vprintfmt+0x22c>
  8004d1:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004d5:	0f 8e 96 00 00 00    	jle    800571 <vprintfmt+0x23a>
					for (width -= strnlen(p, precision); width > 0; width--)
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	51                   	push   %ecx
  8004df:	57                   	push   %edi
  8004e0:	e8 86 02 00 00       	call   80076b <strnlen>
  8004e5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004e8:	29 c1                	sub    %eax,%ecx
  8004ea:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004ed:	83 c4 10             	add    $0x10,%esp
						putch(padc, putdat);
  8004f0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004fa:	89 cf                	mov    %ecx,%edi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  8004fc:	eb 0f                	jmp    80050d <vprintfmt+0x1d6>
						putch(padc, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	53                   	push   %ebx
  800502:	ff 75 e0             	pushl  -0x20(%ebp)
  800505:	ff d6                	call   *%esi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  800507:	83 ef 01             	sub    $0x1,%edi
  80050a:	83 c4 10             	add    $0x10,%esp
  80050d:	85 ff                	test   %edi,%edi
  80050f:	7f ed                	jg     8004fe <vprintfmt+0x1c7>
  800511:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800514:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800517:	85 c9                	test   %ecx,%ecx
  800519:	b8 00 00 00 00       	mov    $0x0,%eax
  80051e:	0f 49 c1             	cmovns %ecx,%eax
  800521:	29 c1                	sub    %eax,%ecx
  800523:	89 75 08             	mov    %esi,0x8(%ebp)
  800526:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800529:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052c:	89 cb                	mov    %ecx,%ebx
  80052e:	eb 4d                	jmp    80057d <vprintfmt+0x246>
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
  800530:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800534:	74 1b                	je     800551 <vprintfmt+0x21a>
  800536:	0f be c0             	movsbl %al,%eax
  800539:	83 e8 20             	sub    $0x20,%eax
  80053c:	83 f8 5e             	cmp    $0x5e,%eax
  80053f:	76 10                	jbe    800551 <vprintfmt+0x21a>
						putch('?', putdat);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	ff 75 0c             	pushl  0xc(%ebp)
  800547:	6a 3f                	push   $0x3f
  800549:	ff 55 08             	call   *0x8(%ebp)
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	eb 0d                	jmp    80055e <vprintfmt+0x227>
					else
						putch(ch, putdat);
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	ff 75 0c             	pushl  0xc(%ebp)
  800557:	52                   	push   %edx
  800558:	ff 55 08             	call   *0x8(%ebp)
  80055b:	83 c4 10             	add    $0x10,%esp
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055e:	83 eb 01             	sub    $0x1,%ebx
  800561:	eb 1a                	jmp    80057d <vprintfmt+0x246>
  800563:	89 75 08             	mov    %esi,0x8(%ebp)
  800566:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800569:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056f:	eb 0c                	jmp    80057d <vprintfmt+0x246>
  800571:	89 75 08             	mov    %esi,0x8(%ebp)
  800574:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800577:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057d:	83 c7 01             	add    $0x1,%edi
  800580:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800584:	0f be d0             	movsbl %al,%edx
  800587:	85 d2                	test   %edx,%edx
  800589:	74 23                	je     8005ae <vprintfmt+0x277>
  80058b:	85 f6                	test   %esi,%esi
  80058d:	78 a1                	js     800530 <vprintfmt+0x1f9>
  80058f:	83 ee 01             	sub    $0x1,%esi
  800592:	79 9c                	jns    800530 <vprintfmt+0x1f9>
  800594:	89 df                	mov    %ebx,%edi
  800596:	8b 75 08             	mov    0x8(%ebp),%esi
  800599:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059c:	eb 18                	jmp    8005b6 <vprintfmt+0x27f>
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
					putch(' ', putdat);
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	53                   	push   %ebx
  8005a2:	6a 20                	push   $0x20
  8005a4:	ff d6                	call   *%esi
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
  8005a6:	83 ef 01             	sub    $0x1,%edi
  8005a9:	83 c4 10             	add    $0x10,%esp
  8005ac:	eb 08                	jmp    8005b6 <vprintfmt+0x27f>
  8005ae:	89 df                	mov    %ebx,%edi
  8005b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b6:	85 ff                	test   %edi,%edi
  8005b8:	7f e4                	jg     80059e <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8005ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bd:	e9 9b fd ff ff       	jmp    80035d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c2:	83 fa 01             	cmp    $0x1,%edx
  8005c5:	7e 16                	jle    8005dd <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 50 08             	lea    0x8(%eax),%edx
  8005cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d0:	8b 50 04             	mov    0x4(%eax),%edx
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005db:	eb 32                	jmp    80060f <vprintfmt+0x2d8>
	else if (lflag)
  8005dd:	85 d2                	test   %edx,%edx
  8005df:	74 18                	je     8005f9 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8d 50 04             	lea    0x4(%eax),%edx
  8005e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ea:	8b 00                	mov    (%eax),%eax
  8005ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ef:	89 c1                	mov    %eax,%ecx
  8005f1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f7:	eb 16                	jmp    80060f <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 50 04             	lea    0x4(%eax),%edx
  8005ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800602:	8b 00                	mov    (%eax),%eax
  800604:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800607:	89 c1                	mov    %eax,%ecx
  800609:	c1 f9 1f             	sar    $0x1f,%ecx
  80060c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(' ', putdat);
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
  80060f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800612:	8b 55 dc             	mov    -0x24(%ebp),%edx
				if ((long long) num < 0) {
					putch('-', putdat);
					num = -(long long) num;
				}
				base = 10;
  800615:	b9 0a 00 00 00       	mov    $0xa,%ecx
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
				if ((long long) num < 0) {
  80061a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061e:	79 74                	jns    800694 <vprintfmt+0x35d>
					putch('-', putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	53                   	push   %ebx
  800624:	6a 2d                	push   $0x2d
  800626:	ff d6                	call   *%esi
					num = -(long long) num;
  800628:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80062b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80062e:	f7 d8                	neg    %eax
  800630:	83 d2 00             	adc    $0x0,%edx
  800633:	f7 da                	neg    %edx
  800635:	83 c4 10             	add    $0x10,%esp
				}
				base = 10;
  800638:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80063d:	eb 55                	jmp    800694 <vprintfmt+0x35d>
				goto number;

			// unsigned decimal
			case 'u':
				num = getuint(&ap, lflag);
  80063f:	8d 45 14             	lea    0x14(%ebp),%eax
  800642:	e8 7c fc ff ff       	call   8002c3 <getuint>
				base = 10;
  800647:	b9 0a 00 00 00       	mov    $0xa,%ecx
				goto number;
  80064c:	eb 46                	jmp    800694 <vprintfmt+0x35d>
				// Replace this with your code.
				/*putch('X', putdat);
				putch('X', putdat);
				putch('X', putdat);*/
				
				num = getuint(&ap, lflag);
  80064e:	8d 45 14             	lea    0x14(%ebp),%eax
  800651:	e8 6d fc ff ff       	call   8002c3 <getuint>
				base = 8;
  800656:	b9 08 00 00 00       	mov    $0x8,%ecx
				goto number;
  80065b:	eb 37                	jmp    800694 <vprintfmt+0x35d>

			// pointer
			case 'p':
				putch('0', putdat);
  80065d:	83 ec 08             	sub    $0x8,%esp
  800660:	53                   	push   %ebx
  800661:	6a 30                	push   $0x30
  800663:	ff d6                	call   *%esi
				putch('x', putdat);
  800665:	83 c4 08             	add    $0x8,%esp
  800668:	53                   	push   %ebx
  800669:	6a 78                	push   $0x78
  80066b:	ff d6                	call   *%esi
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8d 50 04             	lea    0x4(%eax),%edx
  800673:	89 55 14             	mov    %edx,0x14(%ebp)

			// pointer
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
  800676:	8b 00                	mov    (%eax),%eax
  800678:	ba 00 00 00 00       	mov    $0x0,%edx
					(uintptr_t) va_arg(ap, void *);
				base = 16;
				goto number;
  80067d:	83 c4 10             	add    $0x10,%esp
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
				base = 16;
  800680:	b9 10 00 00 00       	mov    $0x10,%ecx
				goto number;
  800685:	eb 0d                	jmp    800694 <vprintfmt+0x35d>

			// (unsigned) hexadecimal
			case 'x':
				num = getuint(&ap, lflag);
  800687:	8d 45 14             	lea    0x14(%ebp),%eax
  80068a:	e8 34 fc ff ff       	call   8002c3 <getuint>
				base = 16;
  80068f:	b9 10 00 00 00       	mov    $0x10,%ecx
			number:
				printnum(putch, putdat, num, base, width, padc);
  800694:	83 ec 0c             	sub    $0xc,%esp
  800697:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80069b:	57                   	push   %edi
  80069c:	ff 75 e0             	pushl  -0x20(%ebp)
  80069f:	51                   	push   %ecx
  8006a0:	52                   	push   %edx
  8006a1:	50                   	push   %eax
  8006a2:	89 da                	mov    %ebx,%edx
  8006a4:	89 f0                	mov    %esi,%eax
  8006a6:	e8 6e fb ff ff       	call   800219 <printnum>
				break;
  8006ab:	83 c4 20             	add    $0x20,%esp
  8006ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b1:	e9 a7 fc ff ff       	jmp    80035d <vprintfmt+0x26>

			// escaped '%' character
			case '%':
				putch(ch, putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	51                   	push   %ecx
  8006bb:	ff d6                	call   *%esi
				break;
  8006bd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8006c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				break;

			// escaped '%' character
			case '%':
				putch(ch, putdat);
				break;
  8006c3:	e9 95 fc ff ff       	jmp    80035d <vprintfmt+0x26>

			// unrecognized escape sequence - just print it literally
			default:
				putch('%', putdat);
  8006c8:	83 ec 08             	sub    $0x8,%esp
  8006cb:	53                   	push   %ebx
  8006cc:	6a 25                	push   $0x25
  8006ce:	ff d6                	call   *%esi
				for (fmt--; fmt[-1] != '%'; fmt--)
  8006d0:	83 c4 10             	add    $0x10,%esp
  8006d3:	eb 03                	jmp    8006d8 <vprintfmt+0x3a1>
  8006d5:	83 ef 01             	sub    $0x1,%edi
  8006d8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006dc:	75 f7                	jne    8006d5 <vprintfmt+0x39e>
  8006de:	e9 7a fc ff ff       	jmp    80035d <vprintfmt+0x26>
					/* do nothing */;
				break;
		}
	}
}
  8006e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e6:	5b                   	pop    %ebx
  8006e7:	5e                   	pop    %esi
  8006e8:	5f                   	pop    %edi
  8006e9:	5d                   	pop    %ebp
  8006ea:	c3                   	ret    

008006eb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006eb:	55                   	push   %ebp
  8006ec:	89 e5                	mov    %esp,%ebp
  8006ee:	83 ec 18             	sub    $0x18,%esp
  8006f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006fa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006fe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800701:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800708:	85 c0                	test   %eax,%eax
  80070a:	74 26                	je     800732 <vsnprintf+0x47>
  80070c:	85 d2                	test   %edx,%edx
  80070e:	7e 22                	jle    800732 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800710:	ff 75 14             	pushl  0x14(%ebp)
  800713:	ff 75 10             	pushl  0x10(%ebp)
  800716:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800719:	50                   	push   %eax
  80071a:	68 fd 02 80 00       	push   $0x8002fd
  80071f:	e8 13 fc ff ff       	call   800337 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800724:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800727:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072d:	83 c4 10             	add    $0x10,%esp
  800730:	eb 05                	jmp    800737 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800732:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800737:	c9                   	leave  
  800738:	c3                   	ret    

00800739 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80073f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800742:	50                   	push   %eax
  800743:	ff 75 10             	pushl  0x10(%ebp)
  800746:	ff 75 0c             	pushl  0xc(%ebp)
  800749:	ff 75 08             	pushl  0x8(%ebp)
  80074c:	e8 9a ff ff ff       	call   8006eb <vsnprintf>
	va_end(ap);

	return rc;
}
  800751:	c9                   	leave  
  800752:	c3                   	ret    

00800753 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800759:	b8 00 00 00 00       	mov    $0x0,%eax
  80075e:	eb 03                	jmp    800763 <strlen+0x10>
		n++;
  800760:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800763:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800767:	75 f7                	jne    800760 <strlen+0xd>
		n++;
	return n;
}
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800771:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800774:	ba 00 00 00 00       	mov    $0x0,%edx
  800779:	eb 03                	jmp    80077e <strnlen+0x13>
		n++;
  80077b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077e:	39 c2                	cmp    %eax,%edx
  800780:	74 08                	je     80078a <strnlen+0x1f>
  800782:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800786:	75 f3                	jne    80077b <strnlen+0x10>
  800788:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80078a:	5d                   	pop    %ebp
  80078b:	c3                   	ret    

0080078c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	53                   	push   %ebx
  800790:	8b 45 08             	mov    0x8(%ebp),%eax
  800793:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800796:	89 c2                	mov    %eax,%edx
  800798:	83 c2 01             	add    $0x1,%edx
  80079b:	83 c1 01             	add    $0x1,%ecx
  80079e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007a2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a5:	84 db                	test   %bl,%bl
  8007a7:	75 ef                	jne    800798 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a9:	5b                   	pop    %ebx
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	53                   	push   %ebx
  8007b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b3:	53                   	push   %ebx
  8007b4:	e8 9a ff ff ff       	call   800753 <strlen>
  8007b9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007bc:	ff 75 0c             	pushl  0xc(%ebp)
  8007bf:	01 d8                	add    %ebx,%eax
  8007c1:	50                   	push   %eax
  8007c2:	e8 c5 ff ff ff       	call   80078c <strcpy>
	return dst;
}
  8007c7:	89 d8                	mov    %ebx,%eax
  8007c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007cc:	c9                   	leave  
  8007cd:	c3                   	ret    

008007ce <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	56                   	push   %esi
  8007d2:	53                   	push   %ebx
  8007d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d9:	89 f3                	mov    %esi,%ebx
  8007db:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007de:	89 f2                	mov    %esi,%edx
  8007e0:	eb 0f                	jmp    8007f1 <strncpy+0x23>
		*dst++ = *src;
  8007e2:	83 c2 01             	add    $0x1,%edx
  8007e5:	0f b6 01             	movzbl (%ecx),%eax
  8007e8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007eb:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ee:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f1:	39 da                	cmp    %ebx,%edx
  8007f3:	75 ed                	jne    8007e2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007f5:	89 f0                	mov    %esi,%eax
  8007f7:	5b                   	pop    %ebx
  8007f8:	5e                   	pop    %esi
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	56                   	push   %esi
  8007ff:	53                   	push   %ebx
  800800:	8b 75 08             	mov    0x8(%ebp),%esi
  800803:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800806:	8b 55 10             	mov    0x10(%ebp),%edx
  800809:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080b:	85 d2                	test   %edx,%edx
  80080d:	74 21                	je     800830 <strlcpy+0x35>
  80080f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800813:	89 f2                	mov    %esi,%edx
  800815:	eb 09                	jmp    800820 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800817:	83 c2 01             	add    $0x1,%edx
  80081a:	83 c1 01             	add    $0x1,%ecx
  80081d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800820:	39 c2                	cmp    %eax,%edx
  800822:	74 09                	je     80082d <strlcpy+0x32>
  800824:	0f b6 19             	movzbl (%ecx),%ebx
  800827:	84 db                	test   %bl,%bl
  800829:	75 ec                	jne    800817 <strlcpy+0x1c>
  80082b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80082d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800830:	29 f0                	sub    %esi,%eax
}
  800832:	5b                   	pop    %ebx
  800833:	5e                   	pop    %esi
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083f:	eb 06                	jmp    800847 <strcmp+0x11>
		p++, q++;
  800841:	83 c1 01             	add    $0x1,%ecx
  800844:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800847:	0f b6 01             	movzbl (%ecx),%eax
  80084a:	84 c0                	test   %al,%al
  80084c:	74 04                	je     800852 <strcmp+0x1c>
  80084e:	3a 02                	cmp    (%edx),%al
  800850:	74 ef                	je     800841 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800852:	0f b6 c0             	movzbl %al,%eax
  800855:	0f b6 12             	movzbl (%edx),%edx
  800858:	29 d0                	sub    %edx,%eax
}
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	53                   	push   %ebx
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	8b 55 0c             	mov    0xc(%ebp),%edx
  800866:	89 c3                	mov    %eax,%ebx
  800868:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80086b:	eb 06                	jmp    800873 <strncmp+0x17>
		n--, p++, q++;
  80086d:	83 c0 01             	add    $0x1,%eax
  800870:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800873:	39 d8                	cmp    %ebx,%eax
  800875:	74 15                	je     80088c <strncmp+0x30>
  800877:	0f b6 08             	movzbl (%eax),%ecx
  80087a:	84 c9                	test   %cl,%cl
  80087c:	74 04                	je     800882 <strncmp+0x26>
  80087e:	3a 0a                	cmp    (%edx),%cl
  800880:	74 eb                	je     80086d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800882:	0f b6 00             	movzbl (%eax),%eax
  800885:	0f b6 12             	movzbl (%edx),%edx
  800888:	29 d0                	sub    %edx,%eax
  80088a:	eb 05                	jmp    800891 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80088c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800891:	5b                   	pop    %ebx
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089e:	eb 07                	jmp    8008a7 <strchr+0x13>
		if (*s == c)
  8008a0:	38 ca                	cmp    %cl,%dl
  8008a2:	74 0f                	je     8008b3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a4:	83 c0 01             	add    $0x1,%eax
  8008a7:	0f b6 10             	movzbl (%eax),%edx
  8008aa:	84 d2                	test   %dl,%dl
  8008ac:	75 f2                	jne    8008a0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bf:	eb 03                	jmp    8008c4 <strfind+0xf>
  8008c1:	83 c0 01             	add    $0x1,%eax
  8008c4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c7:	84 d2                	test   %dl,%dl
  8008c9:	74 04                	je     8008cf <strfind+0x1a>
  8008cb:	38 ca                	cmp    %cl,%dl
  8008cd:	75 f2                	jne    8008c1 <strfind+0xc>
			break;
	return (char *) s;
}
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	57                   	push   %edi
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008da:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008dd:	85 c9                	test   %ecx,%ecx
  8008df:	74 36                	je     800917 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e7:	75 28                	jne    800911 <memset+0x40>
  8008e9:	f6 c1 03             	test   $0x3,%cl
  8008ec:	75 23                	jne    800911 <memset+0x40>
		c &= 0xFF;
  8008ee:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f2:	89 d3                	mov    %edx,%ebx
  8008f4:	c1 e3 08             	shl    $0x8,%ebx
  8008f7:	89 d6                	mov    %edx,%esi
  8008f9:	c1 e6 18             	shl    $0x18,%esi
  8008fc:	89 d0                	mov    %edx,%eax
  8008fe:	c1 e0 10             	shl    $0x10,%eax
  800901:	09 f0                	or     %esi,%eax
  800903:	09 c2                	or     %eax,%edx
  800905:	89 d0                	mov    %edx,%eax
  800907:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800909:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80090c:	fc                   	cld    
  80090d:	f3 ab                	rep stos %eax,%es:(%edi)
  80090f:	eb 06                	jmp    800917 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800911:	8b 45 0c             	mov    0xc(%ebp),%eax
  800914:	fc                   	cld    
  800915:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800917:	89 f8                	mov    %edi,%eax
  800919:	5b                   	pop    %ebx
  80091a:	5e                   	pop    %esi
  80091b:	5f                   	pop    %edi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	57                   	push   %edi
  800922:	56                   	push   %esi
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 75 0c             	mov    0xc(%ebp),%esi
  800929:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80092c:	39 c6                	cmp    %eax,%esi
  80092e:	73 35                	jae    800965 <memmove+0x47>
  800930:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800933:	39 d0                	cmp    %edx,%eax
  800935:	73 2e                	jae    800965 <memmove+0x47>
		s += n;
		d += n;
  800937:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80093a:	89 d6                	mov    %edx,%esi
  80093c:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800944:	75 13                	jne    800959 <memmove+0x3b>
  800946:	f6 c1 03             	test   $0x3,%cl
  800949:	75 0e                	jne    800959 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80094b:	83 ef 04             	sub    $0x4,%edi
  80094e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800951:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800954:	fd                   	std    
  800955:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800957:	eb 09                	jmp    800962 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800959:	83 ef 01             	sub    $0x1,%edi
  80095c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80095f:	fd                   	std    
  800960:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800962:	fc                   	cld    
  800963:	eb 1d                	jmp    800982 <memmove+0x64>
  800965:	89 f2                	mov    %esi,%edx
  800967:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800969:	f6 c2 03             	test   $0x3,%dl
  80096c:	75 0f                	jne    80097d <memmove+0x5f>
  80096e:	f6 c1 03             	test   $0x3,%cl
  800971:	75 0a                	jne    80097d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800973:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800976:	89 c7                	mov    %eax,%edi
  800978:	fc                   	cld    
  800979:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097b:	eb 05                	jmp    800982 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80097d:	89 c7                	mov    %eax,%edi
  80097f:	fc                   	cld    
  800980:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800982:	5e                   	pop    %esi
  800983:	5f                   	pop    %edi
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800989:	ff 75 10             	pushl  0x10(%ebp)
  80098c:	ff 75 0c             	pushl  0xc(%ebp)
  80098f:	ff 75 08             	pushl  0x8(%ebp)
  800992:	e8 87 ff ff ff       	call   80091e <memmove>
}
  800997:	c9                   	leave  
  800998:	c3                   	ret    

00800999 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	56                   	push   %esi
  80099d:	53                   	push   %ebx
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a4:	89 c6                	mov    %eax,%esi
  8009a6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a9:	eb 1a                	jmp    8009c5 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ab:	0f b6 08             	movzbl (%eax),%ecx
  8009ae:	0f b6 1a             	movzbl (%edx),%ebx
  8009b1:	38 d9                	cmp    %bl,%cl
  8009b3:	74 0a                	je     8009bf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009b5:	0f b6 c1             	movzbl %cl,%eax
  8009b8:	0f b6 db             	movzbl %bl,%ebx
  8009bb:	29 d8                	sub    %ebx,%eax
  8009bd:	eb 0f                	jmp    8009ce <memcmp+0x35>
		s1++, s2++;
  8009bf:	83 c0 01             	add    $0x1,%eax
  8009c2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c5:	39 f0                	cmp    %esi,%eax
  8009c7:	75 e2                	jne    8009ab <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ce:	5b                   	pop    %ebx
  8009cf:	5e                   	pop    %esi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009db:	89 c2                	mov    %eax,%edx
  8009dd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e0:	eb 07                	jmp    8009e9 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e2:	38 08                	cmp    %cl,(%eax)
  8009e4:	74 07                	je     8009ed <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e6:	83 c0 01             	add    $0x1,%eax
  8009e9:	39 d0                	cmp    %edx,%eax
  8009eb:	72 f5                	jb     8009e2 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	57                   	push   %edi
  8009f3:	56                   	push   %esi
  8009f4:	53                   	push   %ebx
  8009f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fb:	eb 03                	jmp    800a00 <strtol+0x11>
		s++;
  8009fd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a00:	0f b6 01             	movzbl (%ecx),%eax
  800a03:	3c 09                	cmp    $0x9,%al
  800a05:	74 f6                	je     8009fd <strtol+0xe>
  800a07:	3c 20                	cmp    $0x20,%al
  800a09:	74 f2                	je     8009fd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a0b:	3c 2b                	cmp    $0x2b,%al
  800a0d:	75 0a                	jne    800a19 <strtol+0x2a>
		s++;
  800a0f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a12:	bf 00 00 00 00       	mov    $0x0,%edi
  800a17:	eb 10                	jmp    800a29 <strtol+0x3a>
  800a19:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a1e:	3c 2d                	cmp    $0x2d,%al
  800a20:	75 07                	jne    800a29 <strtol+0x3a>
		s++, neg = 1;
  800a22:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a25:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a29:	85 db                	test   %ebx,%ebx
  800a2b:	0f 94 c0             	sete   %al
  800a2e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a34:	75 19                	jne    800a4f <strtol+0x60>
  800a36:	80 39 30             	cmpb   $0x30,(%ecx)
  800a39:	75 14                	jne    800a4f <strtol+0x60>
  800a3b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a3f:	0f 85 82 00 00 00    	jne    800ac7 <strtol+0xd8>
		s += 2, base = 16;
  800a45:	83 c1 02             	add    $0x2,%ecx
  800a48:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a4d:	eb 16                	jmp    800a65 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a4f:	84 c0                	test   %al,%al
  800a51:	74 12                	je     800a65 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a53:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a58:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5b:	75 08                	jne    800a65 <strtol+0x76>
		s++, base = 8;
  800a5d:	83 c1 01             	add    $0x1,%ecx
  800a60:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a65:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a6d:	0f b6 11             	movzbl (%ecx),%edx
  800a70:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a73:	89 f3                	mov    %esi,%ebx
  800a75:	80 fb 09             	cmp    $0x9,%bl
  800a78:	77 08                	ja     800a82 <strtol+0x93>
			dig = *s - '0';
  800a7a:	0f be d2             	movsbl %dl,%edx
  800a7d:	83 ea 30             	sub    $0x30,%edx
  800a80:	eb 22                	jmp    800aa4 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a82:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a85:	89 f3                	mov    %esi,%ebx
  800a87:	80 fb 19             	cmp    $0x19,%bl
  800a8a:	77 08                	ja     800a94 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a8c:	0f be d2             	movsbl %dl,%edx
  800a8f:	83 ea 57             	sub    $0x57,%edx
  800a92:	eb 10                	jmp    800aa4 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a94:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a97:	89 f3                	mov    %esi,%ebx
  800a99:	80 fb 19             	cmp    $0x19,%bl
  800a9c:	77 16                	ja     800ab4 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a9e:	0f be d2             	movsbl %dl,%edx
  800aa1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aa4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aa7:	7d 0f                	jge    800ab8 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800aa9:	83 c1 01             	add    $0x1,%ecx
  800aac:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab2:	eb b9                	jmp    800a6d <strtol+0x7e>
  800ab4:	89 c2                	mov    %eax,%edx
  800ab6:	eb 02                	jmp    800aba <strtol+0xcb>
  800ab8:	89 c2                	mov    %eax,%edx

	if (endptr)
  800aba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abe:	74 0d                	je     800acd <strtol+0xde>
		*endptr = (char *) s;
  800ac0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac3:	89 0e                	mov    %ecx,(%esi)
  800ac5:	eb 06                	jmp    800acd <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac7:	84 c0                	test   %al,%al
  800ac9:	75 92                	jne    800a5d <strtol+0x6e>
  800acb:	eb 98                	jmp    800a65 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800acd:	f7 da                	neg    %edx
  800acf:	85 ff                	test   %edi,%edi
  800ad1:	0f 45 c2             	cmovne %edx,%eax
}
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    
  800ad9:	66 90                	xchg   %ax,%ax
  800adb:	66 90                	xchg   %ax,%ax
  800add:	66 90                	xchg   %ax,%ax
  800adf:	90                   	nop

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
