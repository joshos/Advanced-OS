
obj/user/buggyhello2:     file format elf32-i386


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

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 4d 00 00 00       	call   800096 <sys_cputs>
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
  80005a:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800061:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 c0                	test   %eax,%eax
  800066:	7e 08                	jle    800070 <libmain+0x22>
		binaryname = argv[0];
  800068:	8b 0a                	mov    (%edx),%ecx
  80006a:	89 0d 04 20 80 00    	mov    %ecx,0x802004

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
  80008c:	e8 42 00 00 00       	call   8000d3 <sys_env_destroy>
  800091:	83 c4 10             	add    $0x10,%esp
}
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	57                   	push   %edi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009c:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a7:	89 c3                	mov    %eax,%ebx
  8000a9:	89 c7                	mov    %eax,%edi
  8000ab:	89 c6                	mov    %eax,%esi
  8000ad:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5f                   	pop    %edi
  8000b2:	5d                   	pop    %ebp
  8000b3:	c3                   	ret    

008000b4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c4:	89 d1                	mov    %edx,%ecx
  8000c6:	89 d3                	mov    %edx,%ebx
  8000c8:	89 d7                	mov    %edx,%edi
  8000ca:	89 d6                	mov    %edx,%esi
  8000cc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e9:	89 cb                	mov    %ecx,%ebx
  8000eb:	89 cf                	mov    %ecx,%edi
  8000ed:	89 ce                	mov    %ecx,%esi
  8000ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f1:	85 c0                	test   %eax,%eax
  8000f3:	7e 17                	jle    80010c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	50                   	push   %eax
  8000f9:	6a 03                	push   $0x3
  8000fb:	68 b8 0d 80 00       	push   $0x800db8
  800100:	6a 23                	push   $0x23
  800102:	68 d5 0d 80 00       	push   $0x800dd5
  800107:	e8 27 00 00 00       	call   800133 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5f                   	pop    %edi
  800112:	5d                   	pop    %ebp
  800113:	c3                   	ret    

00800114 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	57                   	push   %edi
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011a:	ba 00 00 00 00       	mov    $0x0,%edx
  80011f:	b8 02 00 00 00       	mov    $0x2,%eax
  800124:	89 d1                	mov    %edx,%ecx
  800126:	89 d3                	mov    %edx,%ebx
  800128:	89 d7                	mov    %edx,%edi
  80012a:	89 d6                	mov    %edx,%esi
  80012c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800138:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013b:	8b 35 04 20 80 00    	mov    0x802004,%esi
  800141:	e8 ce ff ff ff       	call   800114 <sys_getenvid>
  800146:	83 ec 0c             	sub    $0xc,%esp
  800149:	ff 75 0c             	pushl  0xc(%ebp)
  80014c:	ff 75 08             	pushl  0x8(%ebp)
  80014f:	56                   	push   %esi
  800150:	50                   	push   %eax
  800151:	68 e4 0d 80 00       	push   $0x800de4
  800156:	e8 b1 00 00 00       	call   80020c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015b:	83 c4 18             	add    $0x18,%esp
  80015e:	53                   	push   %ebx
  80015f:	ff 75 10             	pushl  0x10(%ebp)
  800162:	e8 54 00 00 00       	call   8001bb <vcprintf>
	cprintf("\n");
  800167:	c7 04 24 ac 0d 80 00 	movl   $0x800dac,(%esp)
  80016e:	e8 99 00 00 00       	call   80020c <cprintf>
  800173:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800176:	cc                   	int3   
  800177:	eb fd                	jmp    800176 <_panic+0x43>

00800179 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 04             	sub    $0x4,%esp
  800180:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800183:	8b 13                	mov    (%ebx),%edx
  800185:	8d 42 01             	lea    0x1(%edx),%eax
  800188:	89 03                	mov    %eax,(%ebx)
  80018a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800191:	3d ff 00 00 00       	cmp    $0xff,%eax
  800196:	75 1a                	jne    8001b2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800198:	83 ec 08             	sub    $0x8,%esp
  80019b:	68 ff 00 00 00       	push   $0xff
  8001a0:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 ed fe ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  8001a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001af:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cb:	00 00 00 
	b.cnt = 0;
  8001ce:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d8:	ff 75 0c             	pushl  0xc(%ebp)
  8001db:	ff 75 08             	pushl  0x8(%ebp)
  8001de:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e4:	50                   	push   %eax
  8001e5:	68 79 01 80 00       	push   $0x800179
  8001ea:	e8 4f 01 00 00       	call   80033e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ef:	83 c4 08             	add    $0x8,%esp
  8001f2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	e8 92 fe ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  800204:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800212:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800215:	50                   	push   %eax
  800216:	ff 75 08             	pushl  0x8(%ebp)
  800219:	e8 9d ff ff ff       	call   8001bb <vcprintf>
	va_end(ap);

	return cnt;
}
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 1c             	sub    $0x1c,%esp
  800229:	89 c7                	mov    %eax,%edi
  80022b:	89 d6                	mov    %edx,%esi
  80022d:	8b 45 08             	mov    0x8(%ebp),%eax
  800230:	8b 55 0c             	mov    0xc(%ebp),%edx
  800233:	89 d1                	mov    %edx,%ecx
  800235:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800238:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80023b:	8b 45 10             	mov    0x10(%ebp),%eax
  80023e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800241:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800244:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80024b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80024e:	72 05                	jb     800255 <printnum+0x35>
  800250:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800253:	77 3e                	ja     800293 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800255:	83 ec 0c             	sub    $0xc,%esp
  800258:	ff 75 18             	pushl  0x18(%ebp)
  80025b:	83 eb 01             	sub    $0x1,%ebx
  80025e:	53                   	push   %ebx
  80025f:	50                   	push   %eax
  800260:	83 ec 08             	sub    $0x8,%esp
  800263:	ff 75 e4             	pushl  -0x1c(%ebp)
  800266:	ff 75 e0             	pushl  -0x20(%ebp)
  800269:	ff 75 dc             	pushl  -0x24(%ebp)
  80026c:	ff 75 d8             	pushl  -0x28(%ebp)
  80026f:	e8 6c 08 00 00       	call   800ae0 <__udivdi3>
  800274:	83 c4 18             	add    $0x18,%esp
  800277:	52                   	push   %edx
  800278:	50                   	push   %eax
  800279:	89 f2                	mov    %esi,%edx
  80027b:	89 f8                	mov    %edi,%eax
  80027d:	e8 9e ff ff ff       	call   800220 <printnum>
  800282:	83 c4 20             	add    $0x20,%esp
  800285:	eb 13                	jmp    80029a <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800287:	83 ec 08             	sub    $0x8,%esp
  80028a:	56                   	push   %esi
  80028b:	ff 75 18             	pushl  0x18(%ebp)
  80028e:	ff d7                	call   *%edi
  800290:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800293:	83 eb 01             	sub    $0x1,%ebx
  800296:	85 db                	test   %ebx,%ebx
  800298:	7f ed                	jg     800287 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	56                   	push   %esi
  80029e:	83 ec 04             	sub    $0x4,%esp
  8002a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a7:	ff 75 dc             	pushl  -0x24(%ebp)
  8002aa:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ad:	e8 5e 09 00 00       	call   800c10 <__umoddi3>
  8002b2:	83 c4 14             	add    $0x14,%esp
  8002b5:	0f be 80 08 0e 80 00 	movsbl 0x800e08(%eax),%eax
  8002bc:	50                   	push   %eax
  8002bd:	ff d7                	call   *%edi
  8002bf:	83 c4 10             	add    $0x10,%esp
}
  8002c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c5:	5b                   	pop    %ebx
  8002c6:	5e                   	pop    %esi
  8002c7:	5f                   	pop    %edi
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002cd:	83 fa 01             	cmp    $0x1,%edx
  8002d0:	7e 0e                	jle    8002e0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d2:	8b 10                	mov    (%eax),%edx
  8002d4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d7:	89 08                	mov    %ecx,(%eax)
  8002d9:	8b 02                	mov    (%edx),%eax
  8002db:	8b 52 04             	mov    0x4(%edx),%edx
  8002de:	eb 22                	jmp    800302 <getuint+0x38>
	else if (lflag)
  8002e0:	85 d2                	test   %edx,%edx
  8002e2:	74 10                	je     8002f4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e9:	89 08                	mov    %ecx,(%eax)
  8002eb:	8b 02                	mov    (%edx),%eax
  8002ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f2:	eb 0e                	jmp    800302 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f4:	8b 10                	mov    (%eax),%edx
  8002f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f9:	89 08                	mov    %ecx,(%eax)
  8002fb:	8b 02                	mov    (%edx),%eax
  8002fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800302:	5d                   	pop    %ebp
  800303:	c3                   	ret    

00800304 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	3b 50 04             	cmp    0x4(%eax),%edx
  800313:	73 0a                	jae    80031f <sprintputch+0x1b>
		*b->buf++ = ch;
  800315:	8d 4a 01             	lea    0x1(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 45 08             	mov    0x8(%ebp),%eax
  80031d:	88 02                	mov    %al,(%edx)
}
  80031f:	5d                   	pop    %ebp
  800320:	c3                   	ret    

00800321 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800327:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80032a:	50                   	push   %eax
  80032b:	ff 75 10             	pushl  0x10(%ebp)
  80032e:	ff 75 0c             	pushl  0xc(%ebp)
  800331:	ff 75 08             	pushl  0x8(%ebp)
  800334:	e8 05 00 00 00       	call   80033e <vprintfmt>
	va_end(ap);
  800339:	83 c4 10             	add    $0x10,%esp
}
  80033c:	c9                   	leave  
  80033d:	c3                   	ret    

0080033e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	57                   	push   %edi
  800342:	56                   	push   %esi
  800343:	53                   	push   %ebx
  800344:	83 ec 2c             	sub    $0x2c,%esp
  800347:	8b 75 08             	mov    0x8(%ebp),%esi
  80034a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80034d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800350:	eb 12                	jmp    800364 <vprintfmt+0x26>

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
		{
			if (ch == '\0')
  800352:	85 c0                	test   %eax,%eax
  800354:	0f 84 90 03 00 00    	je     8006ea <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  80035a:	83 ec 08             	sub    $0x8,%esp
  80035d:	53                   	push   %ebx
  80035e:	50                   	push   %eax
  80035f:	ff d6                	call   *%esi
  800361:	83 c4 10             	add    $0x10,%esp
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
  800364:	83 c7 01             	add    $0x1,%edi
  800367:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80036b:	83 f8 25             	cmp    $0x25,%eax
  80036e:	75 e2                	jne    800352 <vprintfmt+0x14>
  800370:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800374:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80037b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800382:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800389:	ba 00 00 00 00       	mov    $0x0,%edx
  80038e:	eb 07                	jmp    800397 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		{

			// flag to pad on the right
			case '-':
				padc = '-';
  800393:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800397:	8d 47 01             	lea    0x1(%edi),%eax
  80039a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039d:	0f b6 07             	movzbl (%edi),%eax
  8003a0:	0f b6 c8             	movzbl %al,%ecx
  8003a3:	83 e8 23             	sub    $0x23,%eax
  8003a6:	3c 55                	cmp    $0x55,%al
  8003a8:	0f 87 21 03 00 00    	ja     8006cf <vprintfmt+0x391>
  8003ae:	0f b6 c0             	movzbl %al,%eax
  8003b1:	ff 24 85 a0 0e 80 00 	jmp    *0x800ea0(,%eax,4)
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				padc = '-';
				goto reswitch;

			// flag to pad with 0's instead of spaces
			case '0':
				padc = '0';
  8003bb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003bf:	eb d6                	jmp    800397 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
					precision = precision * 10 + ch - '0';
  8003cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003cf:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
					ch = *fmt;
  8003d3:	0f be 0f             	movsbl (%edi),%ecx
					if (ch < '0' || ch > '9')
  8003d6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d9:	83 fa 09             	cmp    $0x9,%edx
  8003dc:	77 39                	ja     800417 <vprintfmt+0xd9>
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
  8003de:	83 c7 01             	add    $0x1,%edi
					precision = precision * 10 + ch - '0';
					ch = *fmt;
					if (ch < '0' || ch > '9')
						break;
				}
  8003e1:	eb e9                	jmp    8003cc <vprintfmt+0x8e>
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
  8003e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e6:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ec:	8b 00                	mov    (%eax),%eax
  8003ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				}
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
				goto process_precision;
  8003f4:	eb 27                	jmp    80041d <vprintfmt+0xdf>
  8003f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f9:	85 c0                	test   %eax,%eax
  8003fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800400:	0f 49 c8             	cmovns %eax,%ecx
  800403:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800409:	eb 8c                	jmp    800397 <vprintfmt+0x59>
  80040b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				if (width < 0)
					width = 0;
				goto reswitch;

			case '#':
				altflag = 1;
  80040e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				goto reswitch;
  800415:	eb 80                	jmp    800397 <vprintfmt+0x59>
  800417:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80041a:	89 45 d0             	mov    %eax,-0x30(%ebp)

			process_precision:
				if (width < 0)
  80041d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800421:	0f 89 70 ff ff ff    	jns    800397 <vprintfmt+0x59>
					width = precision, precision = -1;
  800427:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80042a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800434:	e9 5e ff ff ff       	jmp    800397 <vprintfmt+0x59>
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
  800439:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
				goto reswitch;
  80043f:	e9 53 ff ff ff       	jmp    800397 <vprintfmt+0x59>

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8d 50 04             	lea    0x4(%eax),%edx
  80044a:	89 55 14             	mov    %edx,0x14(%ebp)
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	53                   	push   %ebx
  800451:	ff 30                	pushl  (%eax)
  800453:	ff d6                	call   *%esi
				break;
  800455:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800458:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
				break;
  80045b:	e9 04 ff ff ff       	jmp    800364 <vprintfmt+0x26>

			// error message
			case 'e':
				err = va_arg(ap, int);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	8b 00                	mov    (%eax),%eax
  80046b:	99                   	cltd   
  80046c:	31 d0                	xor    %edx,%eax
  80046e:	29 d0                	sub    %edx,%eax
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800470:	83 f8 07             	cmp    $0x7,%eax
  800473:	7f 0b                	jg     800480 <vprintfmt+0x142>
  800475:	8b 14 85 00 10 80 00 	mov    0x801000(,%eax,4),%edx
  80047c:	85 d2                	test   %edx,%edx
  80047e:	75 18                	jne    800498 <vprintfmt+0x15a>
					printfmt(putch, putdat, "error %d", err);
  800480:	50                   	push   %eax
  800481:	68 20 0e 80 00       	push   $0x800e20
  800486:	53                   	push   %ebx
  800487:	56                   	push   %esi
  800488:	e8 94 fe ff ff       	call   800321 <printfmt>
  80048d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			case 'e':
				err = va_arg(ap, int);
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
					printfmt(putch, putdat, "error %d", err);
  800493:	e9 cc fe ff ff       	jmp    800364 <vprintfmt+0x26>
				else
					printfmt(putch, putdat, "%s", p);
  800498:	52                   	push   %edx
  800499:	68 29 0e 80 00       	push   $0x800e29
  80049e:	53                   	push   %ebx
  80049f:	56                   	push   %esi
  8004a0:	e8 7c fe ff ff       	call   800321 <printfmt>
  8004a5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8004a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ab:	e9 b4 fe ff ff       	jmp    800364 <vprintfmt+0x26>
  8004b0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004b6:	89 45 cc             	mov    %eax,-0x34(%ebp)
					printfmt(putch, putdat, "%s", p);
				break;

			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bc:	8d 50 04             	lea    0x4(%eax),%edx
  8004bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c2:	8b 38                	mov    (%eax),%edi
					p = "(null)";
  8004c4:	85 ff                	test   %edi,%edi
  8004c6:	ba 19 0e 80 00       	mov    $0x800e19,%edx
  8004cb:	0f 44 fa             	cmove  %edx,%edi
				if (width > 0 && padc != '-')
  8004ce:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d2:	0f 84 92 00 00 00    	je     80056a <vprintfmt+0x22c>
  8004d8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004dc:	0f 8e 96 00 00 00    	jle    800578 <vprintfmt+0x23a>
					for (width -= strnlen(p, precision); width > 0; width--)
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	51                   	push   %ecx
  8004e6:	57                   	push   %edi
  8004e7:	e8 86 02 00 00       	call   800772 <strnlen>
  8004ec:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004ef:	29 c1                	sub    %eax,%ecx
  8004f1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004f4:	83 c4 10             	add    $0x10,%esp
						putch(padc, putdat);
  8004f7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004fe:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800501:	89 cf                	mov    %ecx,%edi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  800503:	eb 0f                	jmp    800514 <vprintfmt+0x1d6>
						putch(padc, putdat);
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	53                   	push   %ebx
  800509:	ff 75 e0             	pushl  -0x20(%ebp)
  80050c:	ff d6                	call   *%esi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  80050e:	83 ef 01             	sub    $0x1,%edi
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	85 ff                	test   %edi,%edi
  800516:	7f ed                	jg     800505 <vprintfmt+0x1c7>
  800518:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80051b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80051e:	85 c9                	test   %ecx,%ecx
  800520:	b8 00 00 00 00       	mov    $0x0,%eax
  800525:	0f 49 c1             	cmovns %ecx,%eax
  800528:	29 c1                	sub    %eax,%ecx
  80052a:	89 75 08             	mov    %esi,0x8(%ebp)
  80052d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800530:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800533:	89 cb                	mov    %ecx,%ebx
  800535:	eb 4d                	jmp    800584 <vprintfmt+0x246>
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
  800537:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80053b:	74 1b                	je     800558 <vprintfmt+0x21a>
  80053d:	0f be c0             	movsbl %al,%eax
  800540:	83 e8 20             	sub    $0x20,%eax
  800543:	83 f8 5e             	cmp    $0x5e,%eax
  800546:	76 10                	jbe    800558 <vprintfmt+0x21a>
						putch('?', putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	ff 75 0c             	pushl  0xc(%ebp)
  80054e:	6a 3f                	push   $0x3f
  800550:	ff 55 08             	call   *0x8(%ebp)
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	eb 0d                	jmp    800565 <vprintfmt+0x227>
					else
						putch(ch, putdat);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	ff 75 0c             	pushl  0xc(%ebp)
  80055e:	52                   	push   %edx
  80055f:	ff 55 08             	call   *0x8(%ebp)
  800562:	83 c4 10             	add    $0x10,%esp
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800565:	83 eb 01             	sub    $0x1,%ebx
  800568:	eb 1a                	jmp    800584 <vprintfmt+0x246>
  80056a:	89 75 08             	mov    %esi,0x8(%ebp)
  80056d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800570:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800573:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800576:	eb 0c                	jmp    800584 <vprintfmt+0x246>
  800578:	89 75 08             	mov    %esi,0x8(%ebp)
  80057b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80057e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800581:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800584:	83 c7 01             	add    $0x1,%edi
  800587:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80058b:	0f be d0             	movsbl %al,%edx
  80058e:	85 d2                	test   %edx,%edx
  800590:	74 23                	je     8005b5 <vprintfmt+0x277>
  800592:	85 f6                	test   %esi,%esi
  800594:	78 a1                	js     800537 <vprintfmt+0x1f9>
  800596:	83 ee 01             	sub    $0x1,%esi
  800599:	79 9c                	jns    800537 <vprintfmt+0x1f9>
  80059b:	89 df                	mov    %ebx,%edi
  80059d:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a3:	eb 18                	jmp    8005bd <vprintfmt+0x27f>
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
					putch(' ', putdat);
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	53                   	push   %ebx
  8005a9:	6a 20                	push   $0x20
  8005ab:	ff d6                	call   *%esi
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
  8005ad:	83 ef 01             	sub    $0x1,%edi
  8005b0:	83 c4 10             	add    $0x10,%esp
  8005b3:	eb 08                	jmp    8005bd <vprintfmt+0x27f>
  8005b5:	89 df                	mov    %ebx,%edi
  8005b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bd:	85 ff                	test   %edi,%edi
  8005bf:	7f e4                	jg     8005a5 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8005c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c4:	e9 9b fd ff ff       	jmp    800364 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c9:	83 fa 01             	cmp    $0x1,%edx
  8005cc:	7e 16                	jle    8005e4 <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8d 50 08             	lea    0x8(%eax),%edx
  8005d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d7:	8b 50 04             	mov    0x4(%eax),%edx
  8005da:	8b 00                	mov    (%eax),%eax
  8005dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005df:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e2:	eb 32                	jmp    800616 <vprintfmt+0x2d8>
	else if (lflag)
  8005e4:	85 d2                	test   %edx,%edx
  8005e6:	74 18                	je     800600 <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f1:	8b 00                	mov    (%eax),%eax
  8005f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f6:	89 c1                	mov    %eax,%ecx
  8005f8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005fe:	eb 16                	jmp    800616 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 00                	mov    (%eax),%eax
  80060b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060e:	89 c1                	mov    %eax,%ecx
  800610:	c1 f9 1f             	sar    $0x1f,%ecx
  800613:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(' ', putdat);
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
  800616:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800619:	8b 55 dc             	mov    -0x24(%ebp),%edx
				if ((long long) num < 0) {
					putch('-', putdat);
					num = -(long long) num;
				}
				base = 10;
  80061c:	b9 0a 00 00 00       	mov    $0xa,%ecx
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
				if ((long long) num < 0) {
  800621:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800625:	79 74                	jns    80069b <vprintfmt+0x35d>
					putch('-', putdat);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	53                   	push   %ebx
  80062b:	6a 2d                	push   $0x2d
  80062d:	ff d6                	call   *%esi
					num = -(long long) num;
  80062f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800632:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800635:	f7 d8                	neg    %eax
  800637:	83 d2 00             	adc    $0x0,%edx
  80063a:	f7 da                	neg    %edx
  80063c:	83 c4 10             	add    $0x10,%esp
				}
				base = 10;
  80063f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800644:	eb 55                	jmp    80069b <vprintfmt+0x35d>
				goto number;

			// unsigned decimal
			case 'u':
				num = getuint(&ap, lflag);
  800646:	8d 45 14             	lea    0x14(%ebp),%eax
  800649:	e8 7c fc ff ff       	call   8002ca <getuint>
				base = 10;
  80064e:	b9 0a 00 00 00       	mov    $0xa,%ecx
				goto number;
  800653:	eb 46                	jmp    80069b <vprintfmt+0x35d>
				// Replace this with your code.
				/*putch('X', putdat);
				putch('X', putdat);
				putch('X', putdat);*/
				
				num = getuint(&ap, lflag);
  800655:	8d 45 14             	lea    0x14(%ebp),%eax
  800658:	e8 6d fc ff ff       	call   8002ca <getuint>
				base = 8;
  80065d:	b9 08 00 00 00       	mov    $0x8,%ecx
				goto number;
  800662:	eb 37                	jmp    80069b <vprintfmt+0x35d>

			// pointer
			case 'p':
				putch('0', putdat);
  800664:	83 ec 08             	sub    $0x8,%esp
  800667:	53                   	push   %ebx
  800668:	6a 30                	push   $0x30
  80066a:	ff d6                	call   *%esi
				putch('x', putdat);
  80066c:	83 c4 08             	add    $0x8,%esp
  80066f:	53                   	push   %ebx
  800670:	6a 78                	push   $0x78
  800672:	ff d6                	call   *%esi
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8d 50 04             	lea    0x4(%eax),%edx
  80067a:	89 55 14             	mov    %edx,0x14(%ebp)

			// pointer
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	ba 00 00 00 00       	mov    $0x0,%edx
					(uintptr_t) va_arg(ap, void *);
				base = 16;
				goto number;
  800684:	83 c4 10             	add    $0x10,%esp
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
				base = 16;
  800687:	b9 10 00 00 00       	mov    $0x10,%ecx
				goto number;
  80068c:	eb 0d                	jmp    80069b <vprintfmt+0x35d>

			// (unsigned) hexadecimal
			case 'x':
				num = getuint(&ap, lflag);
  80068e:	8d 45 14             	lea    0x14(%ebp),%eax
  800691:	e8 34 fc ff ff       	call   8002ca <getuint>
				base = 16;
  800696:	b9 10 00 00 00       	mov    $0x10,%ecx
			number:
				printnum(putch, putdat, num, base, width, padc);
  80069b:	83 ec 0c             	sub    $0xc,%esp
  80069e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a2:	57                   	push   %edi
  8006a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a6:	51                   	push   %ecx
  8006a7:	52                   	push   %edx
  8006a8:	50                   	push   %eax
  8006a9:	89 da                	mov    %ebx,%edx
  8006ab:	89 f0                	mov    %esi,%eax
  8006ad:	e8 6e fb ff ff       	call   800220 <printnum>
				break;
  8006b2:	83 c4 20             	add    $0x20,%esp
  8006b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006b8:	e9 a7 fc ff ff       	jmp    800364 <vprintfmt+0x26>

			// escaped '%' character
			case '%':
				putch(ch, putdat);
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	53                   	push   %ebx
  8006c1:	51                   	push   %ecx
  8006c2:	ff d6                	call   *%esi
				break;
  8006c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8006c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				break;

			// escaped '%' character
			case '%':
				putch(ch, putdat);
				break;
  8006ca:	e9 95 fc ff ff       	jmp    800364 <vprintfmt+0x26>

			// unrecognized escape sequence - just print it literally
			default:
				putch('%', putdat);
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	53                   	push   %ebx
  8006d3:	6a 25                	push   $0x25
  8006d5:	ff d6                	call   *%esi
				for (fmt--; fmt[-1] != '%'; fmt--)
  8006d7:	83 c4 10             	add    $0x10,%esp
  8006da:	eb 03                	jmp    8006df <vprintfmt+0x3a1>
  8006dc:	83 ef 01             	sub    $0x1,%edi
  8006df:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e3:	75 f7                	jne    8006dc <vprintfmt+0x39e>
  8006e5:	e9 7a fc ff ff       	jmp    800364 <vprintfmt+0x26>
					/* do nothing */;
				break;
		}
	}
}
  8006ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ed:	5b                   	pop    %ebx
  8006ee:	5e                   	pop    %esi
  8006ef:	5f                   	pop    %edi
  8006f0:	5d                   	pop    %ebp
  8006f1:	c3                   	ret    

008006f2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	83 ec 18             	sub    $0x18,%esp
  8006f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800701:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800705:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800708:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070f:	85 c0                	test   %eax,%eax
  800711:	74 26                	je     800739 <vsnprintf+0x47>
  800713:	85 d2                	test   %edx,%edx
  800715:	7e 22                	jle    800739 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800717:	ff 75 14             	pushl  0x14(%ebp)
  80071a:	ff 75 10             	pushl  0x10(%ebp)
  80071d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800720:	50                   	push   %eax
  800721:	68 04 03 80 00       	push   $0x800304
  800726:	e8 13 fc ff ff       	call   80033e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800731:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	eb 05                	jmp    80073e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800739:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80073e:	c9                   	leave  
  80073f:	c3                   	ret    

00800740 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800749:	50                   	push   %eax
  80074a:	ff 75 10             	pushl  0x10(%ebp)
  80074d:	ff 75 0c             	pushl  0xc(%ebp)
  800750:	ff 75 08             	pushl  0x8(%ebp)
  800753:	e8 9a ff ff ff       	call   8006f2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800758:	c9                   	leave  
  800759:	c3                   	ret    

0080075a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800760:	b8 00 00 00 00       	mov    $0x0,%eax
  800765:	eb 03                	jmp    80076a <strlen+0x10>
		n++;
  800767:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80076e:	75 f7                	jne    800767 <strlen+0xd>
		n++;
	return n;
}
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800778:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077b:	ba 00 00 00 00       	mov    $0x0,%edx
  800780:	eb 03                	jmp    800785 <strnlen+0x13>
		n++;
  800782:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800785:	39 c2                	cmp    %eax,%edx
  800787:	74 08                	je     800791 <strnlen+0x1f>
  800789:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80078d:	75 f3                	jne    800782 <strnlen+0x10>
  80078f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	53                   	push   %ebx
  800797:	8b 45 08             	mov    0x8(%ebp),%eax
  80079a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079d:	89 c2                	mov    %eax,%edx
  80079f:	83 c2 01             	add    $0x1,%edx
  8007a2:	83 c1 01             	add    $0x1,%ecx
  8007a5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007a9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ac:	84 db                	test   %bl,%bl
  8007ae:	75 ef                	jne    80079f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b0:	5b                   	pop    %ebx
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	53                   	push   %ebx
  8007b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ba:	53                   	push   %ebx
  8007bb:	e8 9a ff ff ff       	call   80075a <strlen>
  8007c0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c3:	ff 75 0c             	pushl  0xc(%ebp)
  8007c6:	01 d8                	add    %ebx,%eax
  8007c8:	50                   	push   %eax
  8007c9:	e8 c5 ff ff ff       	call   800793 <strcpy>
	return dst;
}
  8007ce:	89 d8                	mov    %ebx,%eax
  8007d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d3:	c9                   	leave  
  8007d4:	c3                   	ret    

008007d5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	56                   	push   %esi
  8007d9:	53                   	push   %ebx
  8007da:	8b 75 08             	mov    0x8(%ebp),%esi
  8007dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e0:	89 f3                	mov    %esi,%ebx
  8007e2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e5:	89 f2                	mov    %esi,%edx
  8007e7:	eb 0f                	jmp    8007f8 <strncpy+0x23>
		*dst++ = *src;
  8007e9:	83 c2 01             	add    $0x1,%edx
  8007ec:	0f b6 01             	movzbl (%ecx),%eax
  8007ef:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f2:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f8:	39 da                	cmp    %ebx,%edx
  8007fa:	75 ed                	jne    8007e9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007fc:	89 f0                	mov    %esi,%eax
  8007fe:	5b                   	pop    %ebx
  8007ff:	5e                   	pop    %esi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    

00800802 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	8b 75 08             	mov    0x8(%ebp),%esi
  80080a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080d:	8b 55 10             	mov    0x10(%ebp),%edx
  800810:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800812:	85 d2                	test   %edx,%edx
  800814:	74 21                	je     800837 <strlcpy+0x35>
  800816:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081a:	89 f2                	mov    %esi,%edx
  80081c:	eb 09                	jmp    800827 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081e:	83 c2 01             	add    $0x1,%edx
  800821:	83 c1 01             	add    $0x1,%ecx
  800824:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800827:	39 c2                	cmp    %eax,%edx
  800829:	74 09                	je     800834 <strlcpy+0x32>
  80082b:	0f b6 19             	movzbl (%ecx),%ebx
  80082e:	84 db                	test   %bl,%bl
  800830:	75 ec                	jne    80081e <strlcpy+0x1c>
  800832:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800834:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800837:	29 f0                	sub    %esi,%eax
}
  800839:	5b                   	pop    %ebx
  80083a:	5e                   	pop    %esi
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800843:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800846:	eb 06                	jmp    80084e <strcmp+0x11>
		p++, q++;
  800848:	83 c1 01             	add    $0x1,%ecx
  80084b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80084e:	0f b6 01             	movzbl (%ecx),%eax
  800851:	84 c0                	test   %al,%al
  800853:	74 04                	je     800859 <strcmp+0x1c>
  800855:	3a 02                	cmp    (%edx),%al
  800857:	74 ef                	je     800848 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800859:	0f b6 c0             	movzbl %al,%eax
  80085c:	0f b6 12             	movzbl (%edx),%edx
  80085f:	29 d0                	sub    %edx,%eax
}
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	53                   	push   %ebx
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086d:	89 c3                	mov    %eax,%ebx
  80086f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800872:	eb 06                	jmp    80087a <strncmp+0x17>
		n--, p++, q++;
  800874:	83 c0 01             	add    $0x1,%eax
  800877:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087a:	39 d8                	cmp    %ebx,%eax
  80087c:	74 15                	je     800893 <strncmp+0x30>
  80087e:	0f b6 08             	movzbl (%eax),%ecx
  800881:	84 c9                	test   %cl,%cl
  800883:	74 04                	je     800889 <strncmp+0x26>
  800885:	3a 0a                	cmp    (%edx),%cl
  800887:	74 eb                	je     800874 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800889:	0f b6 00             	movzbl (%eax),%eax
  80088c:	0f b6 12             	movzbl (%edx),%edx
  80088f:	29 d0                	sub    %edx,%eax
  800891:	eb 05                	jmp    800898 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800893:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800898:	5b                   	pop    %ebx
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a5:	eb 07                	jmp    8008ae <strchr+0x13>
		if (*s == c)
  8008a7:	38 ca                	cmp    %cl,%dl
  8008a9:	74 0f                	je     8008ba <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ab:	83 c0 01             	add    $0x1,%eax
  8008ae:	0f b6 10             	movzbl (%eax),%edx
  8008b1:	84 d2                	test   %dl,%dl
  8008b3:	75 f2                	jne    8008a7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c6:	eb 03                	jmp    8008cb <strfind+0xf>
  8008c8:	83 c0 01             	add    $0x1,%eax
  8008cb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ce:	84 d2                	test   %dl,%dl
  8008d0:	74 04                	je     8008d6 <strfind+0x1a>
  8008d2:	38 ca                	cmp    %cl,%dl
  8008d4:	75 f2                	jne    8008c8 <strfind+0xc>
			break;
	return (char *) s;
}
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	57                   	push   %edi
  8008dc:	56                   	push   %esi
  8008dd:	53                   	push   %ebx
  8008de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e4:	85 c9                	test   %ecx,%ecx
  8008e6:	74 36                	je     80091e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008e8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ee:	75 28                	jne    800918 <memset+0x40>
  8008f0:	f6 c1 03             	test   $0x3,%cl
  8008f3:	75 23                	jne    800918 <memset+0x40>
		c &= 0xFF;
  8008f5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f9:	89 d3                	mov    %edx,%ebx
  8008fb:	c1 e3 08             	shl    $0x8,%ebx
  8008fe:	89 d6                	mov    %edx,%esi
  800900:	c1 e6 18             	shl    $0x18,%esi
  800903:	89 d0                	mov    %edx,%eax
  800905:	c1 e0 10             	shl    $0x10,%eax
  800908:	09 f0                	or     %esi,%eax
  80090a:	09 c2                	or     %eax,%edx
  80090c:	89 d0                	mov    %edx,%eax
  80090e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800910:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800913:	fc                   	cld    
  800914:	f3 ab                	rep stos %eax,%es:(%edi)
  800916:	eb 06                	jmp    80091e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800918:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091b:	fc                   	cld    
  80091c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091e:	89 f8                	mov    %edi,%eax
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5f                   	pop    %edi
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	57                   	push   %edi
  800929:	56                   	push   %esi
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800930:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800933:	39 c6                	cmp    %eax,%esi
  800935:	73 35                	jae    80096c <memmove+0x47>
  800937:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093a:	39 d0                	cmp    %edx,%eax
  80093c:	73 2e                	jae    80096c <memmove+0x47>
		s += n;
		d += n;
  80093e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800941:	89 d6                	mov    %edx,%esi
  800943:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800945:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094b:	75 13                	jne    800960 <memmove+0x3b>
  80094d:	f6 c1 03             	test   $0x3,%cl
  800950:	75 0e                	jne    800960 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800952:	83 ef 04             	sub    $0x4,%edi
  800955:	8d 72 fc             	lea    -0x4(%edx),%esi
  800958:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80095b:	fd                   	std    
  80095c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095e:	eb 09                	jmp    800969 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800960:	83 ef 01             	sub    $0x1,%edi
  800963:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800966:	fd                   	std    
  800967:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800969:	fc                   	cld    
  80096a:	eb 1d                	jmp    800989 <memmove+0x64>
  80096c:	89 f2                	mov    %esi,%edx
  80096e:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800970:	f6 c2 03             	test   $0x3,%dl
  800973:	75 0f                	jne    800984 <memmove+0x5f>
  800975:	f6 c1 03             	test   $0x3,%cl
  800978:	75 0a                	jne    800984 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80097a:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80097d:	89 c7                	mov    %eax,%edi
  80097f:	fc                   	cld    
  800980:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800982:	eb 05                	jmp    800989 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800984:	89 c7                	mov    %eax,%edi
  800986:	fc                   	cld    
  800987:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800989:	5e                   	pop    %esi
  80098a:	5f                   	pop    %edi
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800990:	ff 75 10             	pushl  0x10(%ebp)
  800993:	ff 75 0c             	pushl  0xc(%ebp)
  800996:	ff 75 08             	pushl  0x8(%ebp)
  800999:	e8 87 ff ff ff       	call   800925 <memmove>
}
  80099e:	c9                   	leave  
  80099f:	c3                   	ret    

008009a0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	56                   	push   %esi
  8009a4:	53                   	push   %ebx
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ab:	89 c6                	mov    %eax,%esi
  8009ad:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b0:	eb 1a                	jmp    8009cc <memcmp+0x2c>
		if (*s1 != *s2)
  8009b2:	0f b6 08             	movzbl (%eax),%ecx
  8009b5:	0f b6 1a             	movzbl (%edx),%ebx
  8009b8:	38 d9                	cmp    %bl,%cl
  8009ba:	74 0a                	je     8009c6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009bc:	0f b6 c1             	movzbl %cl,%eax
  8009bf:	0f b6 db             	movzbl %bl,%ebx
  8009c2:	29 d8                	sub    %ebx,%eax
  8009c4:	eb 0f                	jmp    8009d5 <memcmp+0x35>
		s1++, s2++;
  8009c6:	83 c0 01             	add    $0x1,%eax
  8009c9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009cc:	39 f0                	cmp    %esi,%eax
  8009ce:	75 e2                	jne    8009b2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d5:	5b                   	pop    %ebx
  8009d6:	5e                   	pop    %esi
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009e2:	89 c2                	mov    %eax,%edx
  8009e4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e7:	eb 07                	jmp    8009f0 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e9:	38 08                	cmp    %cl,(%eax)
  8009eb:	74 07                	je     8009f4 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ed:	83 c0 01             	add    $0x1,%eax
  8009f0:	39 d0                	cmp    %edx,%eax
  8009f2:	72 f5                	jb     8009e9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	57                   	push   %edi
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
  8009fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a02:	eb 03                	jmp    800a07 <strtol+0x11>
		s++;
  800a04:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a07:	0f b6 01             	movzbl (%ecx),%eax
  800a0a:	3c 09                	cmp    $0x9,%al
  800a0c:	74 f6                	je     800a04 <strtol+0xe>
  800a0e:	3c 20                	cmp    $0x20,%al
  800a10:	74 f2                	je     800a04 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a12:	3c 2b                	cmp    $0x2b,%al
  800a14:	75 0a                	jne    800a20 <strtol+0x2a>
		s++;
  800a16:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a19:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1e:	eb 10                	jmp    800a30 <strtol+0x3a>
  800a20:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a25:	3c 2d                	cmp    $0x2d,%al
  800a27:	75 07                	jne    800a30 <strtol+0x3a>
		s++, neg = 1;
  800a29:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a2c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a30:	85 db                	test   %ebx,%ebx
  800a32:	0f 94 c0             	sete   %al
  800a35:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3b:	75 19                	jne    800a56 <strtol+0x60>
  800a3d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a40:	75 14                	jne    800a56 <strtol+0x60>
  800a42:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a46:	0f 85 82 00 00 00    	jne    800ace <strtol+0xd8>
		s += 2, base = 16;
  800a4c:	83 c1 02             	add    $0x2,%ecx
  800a4f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a54:	eb 16                	jmp    800a6c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a56:	84 c0                	test   %al,%al
  800a58:	74 12                	je     800a6c <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a62:	75 08                	jne    800a6c <strtol+0x76>
		s++, base = 8;
  800a64:	83 c1 01             	add    $0x1,%ecx
  800a67:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a71:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a74:	0f b6 11             	movzbl (%ecx),%edx
  800a77:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7a:	89 f3                	mov    %esi,%ebx
  800a7c:	80 fb 09             	cmp    $0x9,%bl
  800a7f:	77 08                	ja     800a89 <strtol+0x93>
			dig = *s - '0';
  800a81:	0f be d2             	movsbl %dl,%edx
  800a84:	83 ea 30             	sub    $0x30,%edx
  800a87:	eb 22                	jmp    800aab <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a89:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8c:	89 f3                	mov    %esi,%ebx
  800a8e:	80 fb 19             	cmp    $0x19,%bl
  800a91:	77 08                	ja     800a9b <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a93:	0f be d2             	movsbl %dl,%edx
  800a96:	83 ea 57             	sub    $0x57,%edx
  800a99:	eb 10                	jmp    800aab <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a9b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9e:	89 f3                	mov    %esi,%ebx
  800aa0:	80 fb 19             	cmp    $0x19,%bl
  800aa3:	77 16                	ja     800abb <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aa5:	0f be d2             	movsbl %dl,%edx
  800aa8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aab:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aae:	7d 0f                	jge    800abf <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800ab0:	83 c1 01             	add    $0x1,%ecx
  800ab3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab9:	eb b9                	jmp    800a74 <strtol+0x7e>
  800abb:	89 c2                	mov    %eax,%edx
  800abd:	eb 02                	jmp    800ac1 <strtol+0xcb>
  800abf:	89 c2                	mov    %eax,%edx

	if (endptr)
  800ac1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac5:	74 0d                	je     800ad4 <strtol+0xde>
		*endptr = (char *) s;
  800ac7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aca:	89 0e                	mov    %ecx,(%esi)
  800acc:	eb 06                	jmp    800ad4 <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ace:	84 c0                	test   %al,%al
  800ad0:	75 92                	jne    800a64 <strtol+0x6e>
  800ad2:	eb 98                	jmp    800a6c <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad4:	f7 da                	neg    %edx
  800ad6:	85 ff                	test   %edi,%edi
  800ad8:	0f 45 c2             	cmovne %edx,%eax
}
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5f                   	pop    %edi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

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
