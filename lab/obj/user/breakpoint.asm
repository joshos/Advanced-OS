
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	83 ec 08             	sub    $0x8,%esp
  80003f:	8b 45 08             	mov    0x8(%ebp),%eax
  800042:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800045:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  80004c:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80004f:	85 c0                	test   %eax,%eax
  800051:	7e 08                	jle    80005b <libmain+0x22>
		binaryname = argv[0];
  800053:	8b 0a                	mov    (%edx),%ecx
  800055:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  80005b:	83 ec 08             	sub    $0x8,%esp
  80005e:	52                   	push   %edx
  80005f:	50                   	push   %eax
  800060:	e8 ce ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800065:	e8 05 00 00 00       	call   80006f <exit>
  80006a:	83 c4 10             	add    $0x10,%esp
}
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800075:	6a 00                	push   $0x0
  800077:	e8 42 00 00 00       	call   8000be <sys_env_destroy>
  80007c:	83 c4 10             	add    $0x10,%esp
}
  80007f:	c9                   	leave  
  800080:	c3                   	ret    

00800081 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800081:	55                   	push   %ebp
  800082:	89 e5                	mov    %esp,%ebp
  800084:	57                   	push   %edi
  800085:	56                   	push   %esi
  800086:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
  80008c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80008f:	8b 55 08             	mov    0x8(%ebp),%edx
  800092:	89 c3                	mov    %eax,%ebx
  800094:	89 c7                	mov    %eax,%edi
  800096:	89 c6                	mov    %eax,%esi
  800098:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80009a:	5b                   	pop    %ebx
  80009b:	5e                   	pop    %esi
  80009c:	5f                   	pop    %edi
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    

0080009f <sys_cgetc>:

int
sys_cgetc(void)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	57                   	push   %edi
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8000af:	89 d1                	mov    %edx,%ecx
  8000b1:	89 d3                	mov    %edx,%ebx
  8000b3:	89 d7                	mov    %edx,%edi
  8000b5:	89 d6                	mov    %edx,%esi
  8000b7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000cc:	b8 03 00 00 00       	mov    $0x3,%eax
  8000d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d4:	89 cb                	mov    %ecx,%ebx
  8000d6:	89 cf                	mov    %ecx,%edi
  8000d8:	89 ce                	mov    %ecx,%esi
  8000da:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	7e 17                	jle    8000f7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e0:	83 ec 0c             	sub    $0xc,%esp
  8000e3:	50                   	push   %eax
  8000e4:	6a 03                	push   $0x3
  8000e6:	68 8a 0d 80 00       	push   $0x800d8a
  8000eb:	6a 23                	push   $0x23
  8000ed:	68 a7 0d 80 00       	push   $0x800da7
  8000f2:	e8 27 00 00 00       	call   80011e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5f                   	pop    %edi
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	57                   	push   %edi
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800105:	ba 00 00 00 00       	mov    $0x0,%edx
  80010a:	b8 02 00 00 00       	mov    $0x2,%eax
  80010f:	89 d1                	mov    %edx,%ecx
  800111:	89 d3                	mov    %edx,%ebx
  800113:	89 d7                	mov    %edx,%edi
  800115:	89 d6                	mov    %edx,%esi
  800117:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800119:	5b                   	pop    %ebx
  80011a:	5e                   	pop    %esi
  80011b:	5f                   	pop    %edi
  80011c:	5d                   	pop    %ebp
  80011d:	c3                   	ret    

0080011e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800123:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800126:	8b 35 00 10 80 00    	mov    0x801000,%esi
  80012c:	e8 ce ff ff ff       	call   8000ff <sys_getenvid>
  800131:	83 ec 0c             	sub    $0xc,%esp
  800134:	ff 75 0c             	pushl  0xc(%ebp)
  800137:	ff 75 08             	pushl  0x8(%ebp)
  80013a:	56                   	push   %esi
  80013b:	50                   	push   %eax
  80013c:	68 b8 0d 80 00       	push   $0x800db8
  800141:	e8 b1 00 00 00       	call   8001f7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800146:	83 c4 18             	add    $0x18,%esp
  800149:	53                   	push   %ebx
  80014a:	ff 75 10             	pushl  0x10(%ebp)
  80014d:	e8 54 00 00 00       	call   8001a6 <vcprintf>
	cprintf("\n");
  800152:	c7 04 24 dc 0d 80 00 	movl   $0x800ddc,(%esp)
  800159:	e8 99 00 00 00       	call   8001f7 <cprintf>
  80015e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800161:	cc                   	int3   
  800162:	eb fd                	jmp    800161 <_panic+0x43>

00800164 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	53                   	push   %ebx
  800168:	83 ec 04             	sub    $0x4,%esp
  80016b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016e:	8b 13                	mov    (%ebx),%edx
  800170:	8d 42 01             	lea    0x1(%edx),%eax
  800173:	89 03                	mov    %eax,(%ebx)
  800175:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800178:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800181:	75 1a                	jne    80019d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800183:	83 ec 08             	sub    $0x8,%esp
  800186:	68 ff 00 00 00       	push   $0xff
  80018b:	8d 43 08             	lea    0x8(%ebx),%eax
  80018e:	50                   	push   %eax
  80018f:	e8 ed fe ff ff       	call   800081 <sys_cputs>
		b->idx = 0;
  800194:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80019d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a4:	c9                   	leave  
  8001a5:	c3                   	ret    

008001a6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001af:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b6:	00 00 00 
	b.cnt = 0;
  8001b9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c3:	ff 75 0c             	pushl  0xc(%ebp)
  8001c6:	ff 75 08             	pushl  0x8(%ebp)
  8001c9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cf:	50                   	push   %eax
  8001d0:	68 64 01 80 00       	push   $0x800164
  8001d5:	e8 4f 01 00 00       	call   800329 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001da:	83 c4 08             	add    $0x8,%esp
  8001dd:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e9:	50                   	push   %eax
  8001ea:	e8 92 fe ff ff       	call   800081 <sys_cputs>

	return b.cnt;
}
  8001ef:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800200:	50                   	push   %eax
  800201:	ff 75 08             	pushl  0x8(%ebp)
  800204:	e8 9d ff ff ff       	call   8001a6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	57                   	push   %edi
  80020f:	56                   	push   %esi
  800210:	53                   	push   %ebx
  800211:	83 ec 1c             	sub    $0x1c,%esp
  800214:	89 c7                	mov    %eax,%edi
  800216:	89 d6                	mov    %edx,%esi
  800218:	8b 45 08             	mov    0x8(%ebp),%eax
  80021b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021e:	89 d1                	mov    %edx,%ecx
  800220:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800223:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800226:	8b 45 10             	mov    0x10(%ebp),%eax
  800229:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80022f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800236:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800239:	72 05                	jb     800240 <printnum+0x35>
  80023b:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80023e:	77 3e                	ja     80027e <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	ff 75 18             	pushl  0x18(%ebp)
  800246:	83 eb 01             	sub    $0x1,%ebx
  800249:	53                   	push   %ebx
  80024a:	50                   	push   %eax
  80024b:	83 ec 08             	sub    $0x8,%esp
  80024e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800251:	ff 75 e0             	pushl  -0x20(%ebp)
  800254:	ff 75 dc             	pushl  -0x24(%ebp)
  800257:	ff 75 d8             	pushl  -0x28(%ebp)
  80025a:	e8 71 08 00 00       	call   800ad0 <__udivdi3>
  80025f:	83 c4 18             	add    $0x18,%esp
  800262:	52                   	push   %edx
  800263:	50                   	push   %eax
  800264:	89 f2                	mov    %esi,%edx
  800266:	89 f8                	mov    %edi,%eax
  800268:	e8 9e ff ff ff       	call   80020b <printnum>
  80026d:	83 c4 20             	add    $0x20,%esp
  800270:	eb 13                	jmp    800285 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800272:	83 ec 08             	sub    $0x8,%esp
  800275:	56                   	push   %esi
  800276:	ff 75 18             	pushl  0x18(%ebp)
  800279:	ff d7                	call   *%edi
  80027b:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027e:	83 eb 01             	sub    $0x1,%ebx
  800281:	85 db                	test   %ebx,%ebx
  800283:	7f ed                	jg     800272 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	56                   	push   %esi
  800289:	83 ec 04             	sub    $0x4,%esp
  80028c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028f:	ff 75 e0             	pushl  -0x20(%ebp)
  800292:	ff 75 dc             	pushl  -0x24(%ebp)
  800295:	ff 75 d8             	pushl  -0x28(%ebp)
  800298:	e8 63 09 00 00       	call   800c00 <__umoddi3>
  80029d:	83 c4 14             	add    $0x14,%esp
  8002a0:	0f be 80 de 0d 80 00 	movsbl 0x800dde(%eax),%eax
  8002a7:	50                   	push   %eax
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b8:	83 fa 01             	cmp    $0x1,%edx
  8002bb:	7e 0e                	jle    8002cb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002bd:	8b 10                	mov    (%eax),%edx
  8002bf:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c2:	89 08                	mov    %ecx,(%eax)
  8002c4:	8b 02                	mov    (%edx),%eax
  8002c6:	8b 52 04             	mov    0x4(%edx),%edx
  8002c9:	eb 22                	jmp    8002ed <getuint+0x38>
	else if (lflag)
  8002cb:	85 d2                	test   %edx,%edx
  8002cd:	74 10                	je     8002df <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002cf:	8b 10                	mov    (%eax),%edx
  8002d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d4:	89 08                	mov    %ecx,(%eax)
  8002d6:	8b 02                	mov    (%edx),%eax
  8002d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dd:	eb 0e                	jmp    8002ed <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002df:	8b 10                	mov    (%eax),%edx
  8002e1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e4:	89 08                	mov    %ecx,(%eax)
  8002e6:	8b 02                	mov    (%edx),%eax
  8002e8:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f9:	8b 10                	mov    (%eax),%edx
  8002fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fe:	73 0a                	jae    80030a <sprintputch+0x1b>
		*b->buf++ = ch;
  800300:	8d 4a 01             	lea    0x1(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 45 08             	mov    0x8(%ebp),%eax
  800308:	88 02                	mov    %al,(%edx)
}
  80030a:	5d                   	pop    %ebp
  80030b:	c3                   	ret    

0080030c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800312:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800315:	50                   	push   %eax
  800316:	ff 75 10             	pushl  0x10(%ebp)
  800319:	ff 75 0c             	pushl  0xc(%ebp)
  80031c:	ff 75 08             	pushl  0x8(%ebp)
  80031f:	e8 05 00 00 00       	call   800329 <vprintfmt>
	va_end(ap);
  800324:	83 c4 10             	add    $0x10,%esp
}
  800327:	c9                   	leave  
  800328:	c3                   	ret    

00800329 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	57                   	push   %edi
  80032d:	56                   	push   %esi
  80032e:	53                   	push   %ebx
  80032f:	83 ec 2c             	sub    $0x2c,%esp
  800332:	8b 75 08             	mov    0x8(%ebp),%esi
  800335:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800338:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033b:	eb 12                	jmp    80034f <vprintfmt+0x26>

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
		{
			if (ch == '\0')
  80033d:	85 c0                	test   %eax,%eax
  80033f:	0f 84 90 03 00 00    	je     8006d5 <vprintfmt+0x3ac>
				return;
			putch(ch, putdat);
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	53                   	push   %ebx
  800349:	50                   	push   %eax
  80034a:	ff d6                	call   *%esi
  80034c:	83 c4 10             	add    $0x10,%esp
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
  80034f:	83 c7 01             	add    $0x1,%edi
  800352:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800356:	83 f8 25             	cmp    $0x25,%eax
  800359:	75 e2                	jne    80033d <vprintfmt+0x14>
  80035b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800366:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800374:	ba 00 00 00 00       	mov    $0x0,%edx
  800379:	eb 07                	jmp    800382 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  80037b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		{

			// flag to pad on the right
			case '-':
				padc = '-';
  80037e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800382:	8d 47 01             	lea    0x1(%edi),%eax
  800385:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800388:	0f b6 07             	movzbl (%edi),%eax
  80038b:	0f b6 c8             	movzbl %al,%ecx
  80038e:	83 e8 23             	sub    $0x23,%eax
  800391:	3c 55                	cmp    $0x55,%al
  800393:	0f 87 21 03 00 00    	ja     8006ba <vprintfmt+0x391>
  800399:	0f b6 c0             	movzbl %al,%eax
  80039c:	ff 24 85 80 0e 80 00 	jmp    *0x800e80(,%eax,4)
  8003a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				padc = '-';
				goto reswitch;

			// flag to pad with 0's instead of spaces
			case '0':
				padc = '0';
  8003a6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003aa:	eb d6                	jmp    800382 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003af:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
					precision = precision * 10 + ch - '0';
  8003b7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ba:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
					ch = *fmt;
  8003be:	0f be 0f             	movsbl (%edi),%ecx
					if (ch < '0' || ch > '9')
  8003c1:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c4:	83 fa 09             	cmp    $0x9,%edx
  8003c7:	77 39                	ja     800402 <vprintfmt+0xd9>
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
  8003c9:	83 c7 01             	add    $0x1,%edi
					precision = precision * 10 + ch - '0';
					ch = *fmt;
					if (ch < '0' || ch > '9')
						break;
				}
  8003cc:	eb e9                	jmp    8003b7 <vprintfmt+0x8e>
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
  8003ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d1:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d4:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d7:	8b 00                	mov    (%eax),%eax
  8003d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				}
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
				goto process_precision;
  8003df:	eb 27                	jmp    800408 <vprintfmt+0xdf>
  8003e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e4:	85 c0                	test   %eax,%eax
  8003e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003eb:	0f 49 c8             	cmovns %eax,%ecx
  8003ee:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f4:	eb 8c                	jmp    800382 <vprintfmt+0x59>
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				if (width < 0)
					width = 0;
				goto reswitch;

			case '#':
				altflag = 1;
  8003f9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				goto reswitch;
  800400:	eb 80                	jmp    800382 <vprintfmt+0x59>
  800402:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800405:	89 45 d0             	mov    %eax,-0x30(%ebp)

			process_precision:
				if (width < 0)
  800408:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040c:	0f 89 70 ff ff ff    	jns    800382 <vprintfmt+0x59>
					width = precision, precision = -1;
  800412:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800415:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800418:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041f:	e9 5e ff ff ff       	jmp    800382 <vprintfmt+0x59>
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
  800424:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
				goto reswitch;
  80042a:	e9 53 ff ff ff       	jmp    800382 <vprintfmt+0x59>

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8d 50 04             	lea    0x4(%eax),%edx
  800435:	89 55 14             	mov    %edx,0x14(%ebp)
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	53                   	push   %ebx
  80043c:	ff 30                	pushl  (%eax)
  80043e:	ff d6                	call   *%esi
				break;
  800440:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800443:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				goto reswitch;

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
				break;
  800446:	e9 04 ff ff ff       	jmp    80034f <vprintfmt+0x26>

			// error message
			case 'e':
				err = va_arg(ap, int);
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8d 50 04             	lea    0x4(%eax),%edx
  800451:	89 55 14             	mov    %edx,0x14(%ebp)
  800454:	8b 00                	mov    (%eax),%eax
  800456:	99                   	cltd   
  800457:	31 d0                	xor    %edx,%eax
  800459:	29 d0                	sub    %edx,%eax
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045b:	83 f8 07             	cmp    $0x7,%eax
  80045e:	7f 0b                	jg     80046b <vprintfmt+0x142>
  800460:	8b 14 85 e0 0f 80 00 	mov    0x800fe0(,%eax,4),%edx
  800467:	85 d2                	test   %edx,%edx
  800469:	75 18                	jne    800483 <vprintfmt+0x15a>
					printfmt(putch, putdat, "error %d", err);
  80046b:	50                   	push   %eax
  80046c:	68 f6 0d 80 00       	push   $0x800df6
  800471:	53                   	push   %ebx
  800472:	56                   	push   %esi
  800473:	e8 94 fe ff ff       	call   80030c <printfmt>
  800478:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  80047b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			case 'e':
				err = va_arg(ap, int);
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
					printfmt(putch, putdat, "error %d", err);
  80047e:	e9 cc fe ff ff       	jmp    80034f <vprintfmt+0x26>
				else
					printfmt(putch, putdat, "%s", p);
  800483:	52                   	push   %edx
  800484:	68 ff 0d 80 00       	push   $0x800dff
  800489:	53                   	push   %ebx
  80048a:	56                   	push   %esi
  80048b:	e8 7c fe ff ff       	call   80030c <printfmt>
  800490:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800493:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800496:	e9 b4 fe ff ff       	jmp    80034f <vprintfmt+0x26>
  80049b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80049e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a1:	89 45 cc             	mov    %eax,-0x34(%ebp)
					printfmt(putch, putdat, "%s", p);
				break;

			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
  8004a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a7:	8d 50 04             	lea    0x4(%eax),%edx
  8004aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ad:	8b 38                	mov    (%eax),%edi
					p = "(null)";
  8004af:	85 ff                	test   %edi,%edi
  8004b1:	ba ef 0d 80 00       	mov    $0x800def,%edx
  8004b6:	0f 44 fa             	cmove  %edx,%edi
				if (width > 0 && padc != '-')
  8004b9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004bd:	0f 84 92 00 00 00    	je     800555 <vprintfmt+0x22c>
  8004c3:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8004c7:	0f 8e 96 00 00 00    	jle    800563 <vprintfmt+0x23a>
					for (width -= strnlen(p, precision); width > 0; width--)
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	51                   	push   %ecx
  8004d1:	57                   	push   %edi
  8004d2:	e8 86 02 00 00       	call   80075d <strnlen>
  8004d7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004da:	29 c1                	sub    %eax,%ecx
  8004dc:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004df:	83 c4 10             	add    $0x10,%esp
						putch(padc, putdat);
  8004e2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ec:	89 cf                	mov    %ecx,%edi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  8004ee:	eb 0f                	jmp    8004ff <vprintfmt+0x1d6>
						putch(padc, putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	53                   	push   %ebx
  8004f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f7:	ff d6                	call   *%esi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  8004f9:	83 ef 01             	sub    $0x1,%edi
  8004fc:	83 c4 10             	add    $0x10,%esp
  8004ff:	85 ff                	test   %edi,%edi
  800501:	7f ed                	jg     8004f0 <vprintfmt+0x1c7>
  800503:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800506:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800509:	85 c9                	test   %ecx,%ecx
  80050b:	b8 00 00 00 00       	mov    $0x0,%eax
  800510:	0f 49 c1             	cmovns %ecx,%eax
  800513:	29 c1                	sub    %eax,%ecx
  800515:	89 75 08             	mov    %esi,0x8(%ebp)
  800518:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051e:	89 cb                	mov    %ecx,%ebx
  800520:	eb 4d                	jmp    80056f <vprintfmt+0x246>
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
  800522:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800526:	74 1b                	je     800543 <vprintfmt+0x21a>
  800528:	0f be c0             	movsbl %al,%eax
  80052b:	83 e8 20             	sub    $0x20,%eax
  80052e:	83 f8 5e             	cmp    $0x5e,%eax
  800531:	76 10                	jbe    800543 <vprintfmt+0x21a>
						putch('?', putdat);
  800533:	83 ec 08             	sub    $0x8,%esp
  800536:	ff 75 0c             	pushl  0xc(%ebp)
  800539:	6a 3f                	push   $0x3f
  80053b:	ff 55 08             	call   *0x8(%ebp)
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	eb 0d                	jmp    800550 <vprintfmt+0x227>
					else
						putch(ch, putdat);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	ff 75 0c             	pushl  0xc(%ebp)
  800549:	52                   	push   %edx
  80054a:	ff 55 08             	call   *0x8(%ebp)
  80054d:	83 c4 10             	add    $0x10,%esp
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800550:	83 eb 01             	sub    $0x1,%ebx
  800553:	eb 1a                	jmp    80056f <vprintfmt+0x246>
  800555:	89 75 08             	mov    %esi,0x8(%ebp)
  800558:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800561:	eb 0c                	jmp    80056f <vprintfmt+0x246>
  800563:	89 75 08             	mov    %esi,0x8(%ebp)
  800566:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800569:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056f:	83 c7 01             	add    $0x1,%edi
  800572:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800576:	0f be d0             	movsbl %al,%edx
  800579:	85 d2                	test   %edx,%edx
  80057b:	74 23                	je     8005a0 <vprintfmt+0x277>
  80057d:	85 f6                	test   %esi,%esi
  80057f:	78 a1                	js     800522 <vprintfmt+0x1f9>
  800581:	83 ee 01             	sub    $0x1,%esi
  800584:	79 9c                	jns    800522 <vprintfmt+0x1f9>
  800586:	89 df                	mov    %ebx,%edi
  800588:	8b 75 08             	mov    0x8(%ebp),%esi
  80058b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058e:	eb 18                	jmp    8005a8 <vprintfmt+0x27f>
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
					putch(' ', putdat);
  800590:	83 ec 08             	sub    $0x8,%esp
  800593:	53                   	push   %ebx
  800594:	6a 20                	push   $0x20
  800596:	ff d6                	call   *%esi
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
  800598:	83 ef 01             	sub    $0x1,%edi
  80059b:	83 c4 10             	add    $0x10,%esp
  80059e:	eb 08                	jmp    8005a8 <vprintfmt+0x27f>
  8005a0:	89 df                	mov    %ebx,%edi
  8005a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a8:	85 ff                	test   %edi,%edi
  8005aa:	7f e4                	jg     800590 <vprintfmt+0x267>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8005ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005af:	e9 9b fd ff ff       	jmp    80034f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b4:	83 fa 01             	cmp    $0x1,%edx
  8005b7:	7e 16                	jle    8005cf <vprintfmt+0x2a6>
		return va_arg(*ap, long long);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 50 08             	lea    0x8(%eax),%edx
  8005bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c2:	8b 50 04             	mov    0x4(%eax),%edx
  8005c5:	8b 00                	mov    (%eax),%eax
  8005c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cd:	eb 32                	jmp    800601 <vprintfmt+0x2d8>
	else if (lflag)
  8005cf:	85 d2                	test   %edx,%edx
  8005d1:	74 18                	je     8005eb <vprintfmt+0x2c2>
		return va_arg(*ap, long);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 50 04             	lea    0x4(%eax),%edx
  8005d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dc:	8b 00                	mov    (%eax),%eax
  8005de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e1:	89 c1                	mov    %eax,%ecx
  8005e3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e9:	eb 16                	jmp    800601 <vprintfmt+0x2d8>
	else
		return va_arg(*ap, int);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 50 04             	lea    0x4(%eax),%edx
  8005f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f4:	8b 00                	mov    (%eax),%eax
  8005f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f9:	89 c1                	mov    %eax,%ecx
  8005fb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
					putch(' ', putdat);
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
  800601:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800604:	8b 55 dc             	mov    -0x24(%ebp),%edx
				if ((long long) num < 0) {
					putch('-', putdat);
					num = -(long long) num;
				}
				base = 10;
  800607:	b9 0a 00 00 00       	mov    $0xa,%ecx
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
				if ((long long) num < 0) {
  80060c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800610:	79 74                	jns    800686 <vprintfmt+0x35d>
					putch('-', putdat);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 2d                	push   $0x2d
  800618:	ff d6                	call   *%esi
					num = -(long long) num;
  80061a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800620:	f7 d8                	neg    %eax
  800622:	83 d2 00             	adc    $0x0,%edx
  800625:	f7 da                	neg    %edx
  800627:	83 c4 10             	add    $0x10,%esp
				}
				base = 10;
  80062a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80062f:	eb 55                	jmp    800686 <vprintfmt+0x35d>
				goto number;

			// unsigned decimal
			case 'u':
				num = getuint(&ap, lflag);
  800631:	8d 45 14             	lea    0x14(%ebp),%eax
  800634:	e8 7c fc ff ff       	call   8002b5 <getuint>
				base = 10;
  800639:	b9 0a 00 00 00       	mov    $0xa,%ecx
				goto number;
  80063e:	eb 46                	jmp    800686 <vprintfmt+0x35d>
				// Replace this with your code.
				/*putch('X', putdat);
				putch('X', putdat);
				putch('X', putdat);*/
				
				num = getuint(&ap, lflag);
  800640:	8d 45 14             	lea    0x14(%ebp),%eax
  800643:	e8 6d fc ff ff       	call   8002b5 <getuint>
				base = 8;
  800648:	b9 08 00 00 00       	mov    $0x8,%ecx
				goto number;
  80064d:	eb 37                	jmp    800686 <vprintfmt+0x35d>

			// pointer
			case 'p':
				putch('0', putdat);
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	53                   	push   %ebx
  800653:	6a 30                	push   $0x30
  800655:	ff d6                	call   *%esi
				putch('x', putdat);
  800657:	83 c4 08             	add    $0x8,%esp
  80065a:	53                   	push   %ebx
  80065b:	6a 78                	push   $0x78
  80065d:	ff d6                	call   *%esi
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8d 50 04             	lea    0x4(%eax),%edx
  800665:	89 55 14             	mov    %edx,0x14(%ebp)

			// pointer
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
  800668:	8b 00                	mov    (%eax),%eax
  80066a:	ba 00 00 00 00       	mov    $0x0,%edx
					(uintptr_t) va_arg(ap, void *);
				base = 16;
				goto number;
  80066f:	83 c4 10             	add    $0x10,%esp
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
				base = 16;
  800672:	b9 10 00 00 00       	mov    $0x10,%ecx
				goto number;
  800677:	eb 0d                	jmp    800686 <vprintfmt+0x35d>

			// (unsigned) hexadecimal
			case 'x':
				num = getuint(&ap, lflag);
  800679:	8d 45 14             	lea    0x14(%ebp),%eax
  80067c:	e8 34 fc ff ff       	call   8002b5 <getuint>
				base = 16;
  800681:	b9 10 00 00 00       	mov    $0x10,%ecx
			number:
				printnum(putch, putdat, num, base, width, padc);
  800686:	83 ec 0c             	sub    $0xc,%esp
  800689:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80068d:	57                   	push   %edi
  80068e:	ff 75 e0             	pushl  -0x20(%ebp)
  800691:	51                   	push   %ecx
  800692:	52                   	push   %edx
  800693:	50                   	push   %eax
  800694:	89 da                	mov    %ebx,%edx
  800696:	89 f0                	mov    %esi,%eax
  800698:	e8 6e fb ff ff       	call   80020b <printnum>
				break;
  80069d:	83 c4 20             	add    $0x20,%esp
  8006a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a3:	e9 a7 fc ff ff       	jmp    80034f <vprintfmt+0x26>

			// escaped '%' character
			case '%':
				putch(ch, putdat);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	53                   	push   %ebx
  8006ac:	51                   	push   %ecx
  8006ad:	ff d6                	call   *%esi
				break;
  8006af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8006b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
				break;

			// escaped '%' character
			case '%':
				putch(ch, putdat);
				break;
  8006b5:	e9 95 fc ff ff       	jmp    80034f <vprintfmt+0x26>

			// unrecognized escape sequence - just print it literally
			default:
				putch('%', putdat);
  8006ba:	83 ec 08             	sub    $0x8,%esp
  8006bd:	53                   	push   %ebx
  8006be:	6a 25                	push   $0x25
  8006c0:	ff d6                	call   *%esi
				for (fmt--; fmt[-1] != '%'; fmt--)
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	eb 03                	jmp    8006ca <vprintfmt+0x3a1>
  8006c7:	83 ef 01             	sub    $0x1,%edi
  8006ca:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ce:	75 f7                	jne    8006c7 <vprintfmt+0x39e>
  8006d0:	e9 7a fc ff ff       	jmp    80034f <vprintfmt+0x26>
					/* do nothing */;
				break;
		}
	}
}
  8006d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d8:	5b                   	pop    %ebx
  8006d9:	5e                   	pop    %esi
  8006da:	5f                   	pop    %edi
  8006db:	5d                   	pop    %ebp
  8006dc:	c3                   	ret    

008006dd <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	83 ec 18             	sub    $0x18,%esp
  8006e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ec:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fa:	85 c0                	test   %eax,%eax
  8006fc:	74 26                	je     800724 <vsnprintf+0x47>
  8006fe:	85 d2                	test   %edx,%edx
  800700:	7e 22                	jle    800724 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800702:	ff 75 14             	pushl  0x14(%ebp)
  800705:	ff 75 10             	pushl  0x10(%ebp)
  800708:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070b:	50                   	push   %eax
  80070c:	68 ef 02 80 00       	push   $0x8002ef
  800711:	e8 13 fc ff ff       	call   800329 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800716:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800719:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	eb 05                	jmp    800729 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800724:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800729:	c9                   	leave  
  80072a:	c3                   	ret    

0080072b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800731:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800734:	50                   	push   %eax
  800735:	ff 75 10             	pushl  0x10(%ebp)
  800738:	ff 75 0c             	pushl  0xc(%ebp)
  80073b:	ff 75 08             	pushl  0x8(%ebp)
  80073e:	e8 9a ff ff ff       	call   8006dd <vsnprintf>
	va_end(ap);

	return rc;
}
  800743:	c9                   	leave  
  800744:	c3                   	ret    

00800745 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074b:	b8 00 00 00 00       	mov    $0x0,%eax
  800750:	eb 03                	jmp    800755 <strlen+0x10>
		n++;
  800752:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800755:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800759:	75 f7                	jne    800752 <strlen+0xd>
		n++;
	return n;
}
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800763:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800766:	ba 00 00 00 00       	mov    $0x0,%edx
  80076b:	eb 03                	jmp    800770 <strnlen+0x13>
		n++;
  80076d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800770:	39 c2                	cmp    %eax,%edx
  800772:	74 08                	je     80077c <strnlen+0x1f>
  800774:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800778:	75 f3                	jne    80076d <strnlen+0x10>
  80077a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80077c:	5d                   	pop    %ebp
  80077d:	c3                   	ret    

0080077e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	53                   	push   %ebx
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800788:	89 c2                	mov    %eax,%edx
  80078a:	83 c2 01             	add    $0x1,%edx
  80078d:	83 c1 01             	add    $0x1,%ecx
  800790:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800794:	88 5a ff             	mov    %bl,-0x1(%edx)
  800797:	84 db                	test   %bl,%bl
  800799:	75 ef                	jne    80078a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80079b:	5b                   	pop    %ebx
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	53                   	push   %ebx
  8007a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a5:	53                   	push   %ebx
  8007a6:	e8 9a ff ff ff       	call   800745 <strlen>
  8007ab:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ae:	ff 75 0c             	pushl  0xc(%ebp)
  8007b1:	01 d8                	add    %ebx,%eax
  8007b3:	50                   	push   %eax
  8007b4:	e8 c5 ff ff ff       	call   80077e <strcpy>
	return dst;
}
  8007b9:	89 d8                	mov    %ebx,%eax
  8007bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	56                   	push   %esi
  8007c4:	53                   	push   %ebx
  8007c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cb:	89 f3                	mov    %esi,%ebx
  8007cd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d0:	89 f2                	mov    %esi,%edx
  8007d2:	eb 0f                	jmp    8007e3 <strncpy+0x23>
		*dst++ = *src;
  8007d4:	83 c2 01             	add    $0x1,%edx
  8007d7:	0f b6 01             	movzbl (%ecx),%eax
  8007da:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007dd:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e3:	39 da                	cmp    %ebx,%edx
  8007e5:	75 ed                	jne    8007d4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e7:	89 f0                	mov    %esi,%eax
  8007e9:	5b                   	pop    %ebx
  8007ea:	5e                   	pop    %esi
  8007eb:	5d                   	pop    %ebp
  8007ec:	c3                   	ret    

008007ed <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	56                   	push   %esi
  8007f1:	53                   	push   %ebx
  8007f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f8:	8b 55 10             	mov    0x10(%ebp),%edx
  8007fb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007fd:	85 d2                	test   %edx,%edx
  8007ff:	74 21                	je     800822 <strlcpy+0x35>
  800801:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800805:	89 f2                	mov    %esi,%edx
  800807:	eb 09                	jmp    800812 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800809:	83 c2 01             	add    $0x1,%edx
  80080c:	83 c1 01             	add    $0x1,%ecx
  80080f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800812:	39 c2                	cmp    %eax,%edx
  800814:	74 09                	je     80081f <strlcpy+0x32>
  800816:	0f b6 19             	movzbl (%ecx),%ebx
  800819:	84 db                	test   %bl,%bl
  80081b:	75 ec                	jne    800809 <strlcpy+0x1c>
  80081d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80081f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800822:	29 f0                	sub    %esi,%eax
}
  800824:	5b                   	pop    %ebx
  800825:	5e                   	pop    %esi
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800831:	eb 06                	jmp    800839 <strcmp+0x11>
		p++, q++;
  800833:	83 c1 01             	add    $0x1,%ecx
  800836:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800839:	0f b6 01             	movzbl (%ecx),%eax
  80083c:	84 c0                	test   %al,%al
  80083e:	74 04                	je     800844 <strcmp+0x1c>
  800840:	3a 02                	cmp    (%edx),%al
  800842:	74 ef                	je     800833 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800844:	0f b6 c0             	movzbl %al,%eax
  800847:	0f b6 12             	movzbl (%edx),%edx
  80084a:	29 d0                	sub    %edx,%eax
}
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	53                   	push   %ebx
  800852:	8b 45 08             	mov    0x8(%ebp),%eax
  800855:	8b 55 0c             	mov    0xc(%ebp),%edx
  800858:	89 c3                	mov    %eax,%ebx
  80085a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085d:	eb 06                	jmp    800865 <strncmp+0x17>
		n--, p++, q++;
  80085f:	83 c0 01             	add    $0x1,%eax
  800862:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800865:	39 d8                	cmp    %ebx,%eax
  800867:	74 15                	je     80087e <strncmp+0x30>
  800869:	0f b6 08             	movzbl (%eax),%ecx
  80086c:	84 c9                	test   %cl,%cl
  80086e:	74 04                	je     800874 <strncmp+0x26>
  800870:	3a 0a                	cmp    (%edx),%cl
  800872:	74 eb                	je     80085f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800874:	0f b6 00             	movzbl (%eax),%eax
  800877:	0f b6 12             	movzbl (%edx),%edx
  80087a:	29 d0                	sub    %edx,%eax
  80087c:	eb 05                	jmp    800883 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800883:	5b                   	pop    %ebx
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800890:	eb 07                	jmp    800899 <strchr+0x13>
		if (*s == c)
  800892:	38 ca                	cmp    %cl,%dl
  800894:	74 0f                	je     8008a5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800896:	83 c0 01             	add    $0x1,%eax
  800899:	0f b6 10             	movzbl (%eax),%edx
  80089c:	84 d2                	test   %dl,%dl
  80089e:	75 f2                	jne    800892 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ad:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b1:	eb 03                	jmp    8008b6 <strfind+0xf>
  8008b3:	83 c0 01             	add    $0x1,%eax
  8008b6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b9:	84 d2                	test   %dl,%dl
  8008bb:	74 04                	je     8008c1 <strfind+0x1a>
  8008bd:	38 ca                	cmp    %cl,%dl
  8008bf:	75 f2                	jne    8008b3 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	57                   	push   %edi
  8008c7:	56                   	push   %esi
  8008c8:	53                   	push   %ebx
  8008c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008cf:	85 c9                	test   %ecx,%ecx
  8008d1:	74 36                	je     800909 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d9:	75 28                	jne    800903 <memset+0x40>
  8008db:	f6 c1 03             	test   $0x3,%cl
  8008de:	75 23                	jne    800903 <memset+0x40>
		c &= 0xFF;
  8008e0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e4:	89 d3                	mov    %edx,%ebx
  8008e6:	c1 e3 08             	shl    $0x8,%ebx
  8008e9:	89 d6                	mov    %edx,%esi
  8008eb:	c1 e6 18             	shl    $0x18,%esi
  8008ee:	89 d0                	mov    %edx,%eax
  8008f0:	c1 e0 10             	shl    $0x10,%eax
  8008f3:	09 f0                	or     %esi,%eax
  8008f5:	09 c2                	or     %eax,%edx
  8008f7:	89 d0                	mov    %edx,%eax
  8008f9:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008fb:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8008fe:	fc                   	cld    
  8008ff:	f3 ab                	rep stos %eax,%es:(%edi)
  800901:	eb 06                	jmp    800909 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800903:	8b 45 0c             	mov    0xc(%ebp),%eax
  800906:	fc                   	cld    
  800907:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800909:	89 f8                	mov    %edi,%eax
  80090b:	5b                   	pop    %ebx
  80090c:	5e                   	pop    %esi
  80090d:	5f                   	pop    %edi
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	57                   	push   %edi
  800914:	56                   	push   %esi
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091e:	39 c6                	cmp    %eax,%esi
  800920:	73 35                	jae    800957 <memmove+0x47>
  800922:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800925:	39 d0                	cmp    %edx,%eax
  800927:	73 2e                	jae    800957 <memmove+0x47>
		s += n;
		d += n;
  800929:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80092c:	89 d6                	mov    %edx,%esi
  80092e:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800930:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800936:	75 13                	jne    80094b <memmove+0x3b>
  800938:	f6 c1 03             	test   $0x3,%cl
  80093b:	75 0e                	jne    80094b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80093d:	83 ef 04             	sub    $0x4,%edi
  800940:	8d 72 fc             	lea    -0x4(%edx),%esi
  800943:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800946:	fd                   	std    
  800947:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800949:	eb 09                	jmp    800954 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80094b:	83 ef 01             	sub    $0x1,%edi
  80094e:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800951:	fd                   	std    
  800952:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800954:	fc                   	cld    
  800955:	eb 1d                	jmp    800974 <memmove+0x64>
  800957:	89 f2                	mov    %esi,%edx
  800959:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095b:	f6 c2 03             	test   $0x3,%dl
  80095e:	75 0f                	jne    80096f <memmove+0x5f>
  800960:	f6 c1 03             	test   $0x3,%cl
  800963:	75 0a                	jne    80096f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800965:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800968:	89 c7                	mov    %eax,%edi
  80096a:	fc                   	cld    
  80096b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096d:	eb 05                	jmp    800974 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096f:	89 c7                	mov    %eax,%edi
  800971:	fc                   	cld    
  800972:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800974:	5e                   	pop    %esi
  800975:	5f                   	pop    %edi
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097b:	ff 75 10             	pushl  0x10(%ebp)
  80097e:	ff 75 0c             	pushl  0xc(%ebp)
  800981:	ff 75 08             	pushl  0x8(%ebp)
  800984:	e8 87 ff ff ff       	call   800910 <memmove>
}
  800989:	c9                   	leave  
  80098a:	c3                   	ret    

0080098b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	56                   	push   %esi
  80098f:	53                   	push   %ebx
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 55 0c             	mov    0xc(%ebp),%edx
  800996:	89 c6                	mov    %eax,%esi
  800998:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099b:	eb 1a                	jmp    8009b7 <memcmp+0x2c>
		if (*s1 != *s2)
  80099d:	0f b6 08             	movzbl (%eax),%ecx
  8009a0:	0f b6 1a             	movzbl (%edx),%ebx
  8009a3:	38 d9                	cmp    %bl,%cl
  8009a5:	74 0a                	je     8009b1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a7:	0f b6 c1             	movzbl %cl,%eax
  8009aa:	0f b6 db             	movzbl %bl,%ebx
  8009ad:	29 d8                	sub    %ebx,%eax
  8009af:	eb 0f                	jmp    8009c0 <memcmp+0x35>
		s1++, s2++;
  8009b1:	83 c0 01             	add    $0x1,%eax
  8009b4:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b7:	39 f0                	cmp    %esi,%eax
  8009b9:	75 e2                	jne    80099d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c0:	5b                   	pop    %ebx
  8009c1:	5e                   	pop    %esi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009cd:	89 c2                	mov    %eax,%edx
  8009cf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009d2:	eb 07                	jmp    8009db <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d4:	38 08                	cmp    %cl,(%eax)
  8009d6:	74 07                	je     8009df <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d8:	83 c0 01             	add    $0x1,%eax
  8009db:	39 d0                	cmp    %edx,%eax
  8009dd:	72 f5                	jb     8009d4 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    

008009e1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	57                   	push   %edi
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ed:	eb 03                	jmp    8009f2 <strtol+0x11>
		s++;
  8009ef:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f2:	0f b6 01             	movzbl (%ecx),%eax
  8009f5:	3c 09                	cmp    $0x9,%al
  8009f7:	74 f6                	je     8009ef <strtol+0xe>
  8009f9:	3c 20                	cmp    $0x20,%al
  8009fb:	74 f2                	je     8009ef <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fd:	3c 2b                	cmp    $0x2b,%al
  8009ff:	75 0a                	jne    800a0b <strtol+0x2a>
		s++;
  800a01:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a04:	bf 00 00 00 00       	mov    $0x0,%edi
  800a09:	eb 10                	jmp    800a1b <strtol+0x3a>
  800a0b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a10:	3c 2d                	cmp    $0x2d,%al
  800a12:	75 07                	jne    800a1b <strtol+0x3a>
		s++, neg = 1;
  800a14:	8d 49 01             	lea    0x1(%ecx),%ecx
  800a17:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1b:	85 db                	test   %ebx,%ebx
  800a1d:	0f 94 c0             	sete   %al
  800a20:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a26:	75 19                	jne    800a41 <strtol+0x60>
  800a28:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2b:	75 14                	jne    800a41 <strtol+0x60>
  800a2d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a31:	0f 85 82 00 00 00    	jne    800ab9 <strtol+0xd8>
		s += 2, base = 16;
  800a37:	83 c1 02             	add    $0x2,%ecx
  800a3a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a3f:	eb 16                	jmp    800a57 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a41:	84 c0                	test   %al,%al
  800a43:	74 12                	je     800a57 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a45:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4d:	75 08                	jne    800a57 <strtol+0x76>
		s++, base = 8;
  800a4f:	83 c1 01             	add    $0x1,%ecx
  800a52:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a57:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a5f:	0f b6 11             	movzbl (%ecx),%edx
  800a62:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a65:	89 f3                	mov    %esi,%ebx
  800a67:	80 fb 09             	cmp    $0x9,%bl
  800a6a:	77 08                	ja     800a74 <strtol+0x93>
			dig = *s - '0';
  800a6c:	0f be d2             	movsbl %dl,%edx
  800a6f:	83 ea 30             	sub    $0x30,%edx
  800a72:	eb 22                	jmp    800a96 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800a74:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a77:	89 f3                	mov    %esi,%ebx
  800a79:	80 fb 19             	cmp    $0x19,%bl
  800a7c:	77 08                	ja     800a86 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800a7e:	0f be d2             	movsbl %dl,%edx
  800a81:	83 ea 57             	sub    $0x57,%edx
  800a84:	eb 10                	jmp    800a96 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800a86:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a89:	89 f3                	mov    %esi,%ebx
  800a8b:	80 fb 19             	cmp    $0x19,%bl
  800a8e:	77 16                	ja     800aa6 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a90:	0f be d2             	movsbl %dl,%edx
  800a93:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a96:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a99:	7d 0f                	jge    800aaa <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800a9b:	83 c1 01             	add    $0x1,%ecx
  800a9e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa4:	eb b9                	jmp    800a5f <strtol+0x7e>
  800aa6:	89 c2                	mov    %eax,%edx
  800aa8:	eb 02                	jmp    800aac <strtol+0xcb>
  800aaa:	89 c2                	mov    %eax,%edx

	if (endptr)
  800aac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab0:	74 0d                	je     800abf <strtol+0xde>
		*endptr = (char *) s;
  800ab2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab5:	89 0e                	mov    %ecx,(%esi)
  800ab7:	eb 06                	jmp    800abf <strtol+0xde>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab9:	84 c0                	test   %al,%al
  800abb:	75 92                	jne    800a4f <strtol+0x6e>
  800abd:	eb 98                	jmp    800a57 <strtol+0x76>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800abf:	f7 da                	neg    %edx
  800ac1:	85 ff                	test   %edi,%edi
  800ac3:	0f 45 c2             	cmovne %edx,%eax
}
  800ac6:	5b                   	pop    %ebx
  800ac7:	5e                   	pop    %esi
  800ac8:	5f                   	pop    %edi
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    
  800acb:	66 90                	xchg   %ax,%ax
  800acd:	66 90                	xchg   %ax,%ax
  800acf:	90                   	nop

00800ad0 <__udivdi3>:
  800ad0:	55                   	push   %ebp
  800ad1:	57                   	push   %edi
  800ad2:	56                   	push   %esi
  800ad3:	83 ec 10             	sub    $0x10,%esp
  800ad6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  800ada:	8b 7c 24 20          	mov    0x20(%esp),%edi
  800ade:	8b 74 24 24          	mov    0x24(%esp),%esi
  800ae2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800ae6:	85 d2                	test   %edx,%edx
  800ae8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aec:	89 34 24             	mov    %esi,(%esp)
  800aef:	89 c8                	mov    %ecx,%eax
  800af1:	75 35                	jne    800b28 <__udivdi3+0x58>
  800af3:	39 f1                	cmp    %esi,%ecx
  800af5:	0f 87 bd 00 00 00    	ja     800bb8 <__udivdi3+0xe8>
  800afb:	85 c9                	test   %ecx,%ecx
  800afd:	89 cd                	mov    %ecx,%ebp
  800aff:	75 0b                	jne    800b0c <__udivdi3+0x3c>
  800b01:	b8 01 00 00 00       	mov    $0x1,%eax
  800b06:	31 d2                	xor    %edx,%edx
  800b08:	f7 f1                	div    %ecx
  800b0a:	89 c5                	mov    %eax,%ebp
  800b0c:	89 f0                	mov    %esi,%eax
  800b0e:	31 d2                	xor    %edx,%edx
  800b10:	f7 f5                	div    %ebp
  800b12:	89 c6                	mov    %eax,%esi
  800b14:	89 f8                	mov    %edi,%eax
  800b16:	f7 f5                	div    %ebp
  800b18:	89 f2                	mov    %esi,%edx
  800b1a:	83 c4 10             	add    $0x10,%esp
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    
  800b21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800b28:	3b 14 24             	cmp    (%esp),%edx
  800b2b:	77 7b                	ja     800ba8 <__udivdi3+0xd8>
  800b2d:	0f bd f2             	bsr    %edx,%esi
  800b30:	83 f6 1f             	xor    $0x1f,%esi
  800b33:	0f 84 97 00 00 00    	je     800bd0 <__udivdi3+0x100>
  800b39:	bd 20 00 00 00       	mov    $0x20,%ebp
  800b3e:	89 d7                	mov    %edx,%edi
  800b40:	89 f1                	mov    %esi,%ecx
  800b42:	29 f5                	sub    %esi,%ebp
  800b44:	d3 e7                	shl    %cl,%edi
  800b46:	89 c2                	mov    %eax,%edx
  800b48:	89 e9                	mov    %ebp,%ecx
  800b4a:	d3 ea                	shr    %cl,%edx
  800b4c:	89 f1                	mov    %esi,%ecx
  800b4e:	09 fa                	or     %edi,%edx
  800b50:	8b 3c 24             	mov    (%esp),%edi
  800b53:	d3 e0                	shl    %cl,%eax
  800b55:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b59:	89 e9                	mov    %ebp,%ecx
  800b5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b5f:	8b 44 24 04          	mov    0x4(%esp),%eax
  800b63:	89 fa                	mov    %edi,%edx
  800b65:	d3 ea                	shr    %cl,%edx
  800b67:	89 f1                	mov    %esi,%ecx
  800b69:	d3 e7                	shl    %cl,%edi
  800b6b:	89 e9                	mov    %ebp,%ecx
  800b6d:	d3 e8                	shr    %cl,%eax
  800b6f:	09 c7                	or     %eax,%edi
  800b71:	89 f8                	mov    %edi,%eax
  800b73:	f7 74 24 08          	divl   0x8(%esp)
  800b77:	89 d5                	mov    %edx,%ebp
  800b79:	89 c7                	mov    %eax,%edi
  800b7b:	f7 64 24 0c          	mull   0xc(%esp)
  800b7f:	39 d5                	cmp    %edx,%ebp
  800b81:	89 14 24             	mov    %edx,(%esp)
  800b84:	72 11                	jb     800b97 <__udivdi3+0xc7>
  800b86:	8b 54 24 04          	mov    0x4(%esp),%edx
  800b8a:	89 f1                	mov    %esi,%ecx
  800b8c:	d3 e2                	shl    %cl,%edx
  800b8e:	39 c2                	cmp    %eax,%edx
  800b90:	73 5e                	jae    800bf0 <__udivdi3+0x120>
  800b92:	3b 2c 24             	cmp    (%esp),%ebp
  800b95:	75 59                	jne    800bf0 <__udivdi3+0x120>
  800b97:	8d 47 ff             	lea    -0x1(%edi),%eax
  800b9a:	31 f6                	xor    %esi,%esi
  800b9c:	89 f2                	mov    %esi,%edx
  800b9e:	83 c4 10             	add    $0x10,%esp
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    
  800ba5:	8d 76 00             	lea    0x0(%esi),%esi
  800ba8:	31 f6                	xor    %esi,%esi
  800baa:	31 c0                	xor    %eax,%eax
  800bac:	89 f2                	mov    %esi,%edx
  800bae:	83 c4 10             	add    $0x10,%esp
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    
  800bb5:	8d 76 00             	lea    0x0(%esi),%esi
  800bb8:	89 f2                	mov    %esi,%edx
  800bba:	31 f6                	xor    %esi,%esi
  800bbc:	89 f8                	mov    %edi,%eax
  800bbe:	f7 f1                	div    %ecx
  800bc0:	89 f2                	mov    %esi,%edx
  800bc2:	83 c4 10             	add    $0x10,%esp
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    
  800bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800bd0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800bd4:	76 0b                	jbe    800be1 <__udivdi3+0x111>
  800bd6:	31 c0                	xor    %eax,%eax
  800bd8:	3b 14 24             	cmp    (%esp),%edx
  800bdb:	0f 83 37 ff ff ff    	jae    800b18 <__udivdi3+0x48>
  800be1:	b8 01 00 00 00       	mov    $0x1,%eax
  800be6:	e9 2d ff ff ff       	jmp    800b18 <__udivdi3+0x48>
  800beb:	90                   	nop
  800bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bf0:	89 f8                	mov    %edi,%eax
  800bf2:	31 f6                	xor    %esi,%esi
  800bf4:	e9 1f ff ff ff       	jmp    800b18 <__udivdi3+0x48>
  800bf9:	66 90                	xchg   %ax,%ax
  800bfb:	66 90                	xchg   %ax,%ax
  800bfd:	66 90                	xchg   %ax,%ax
  800bff:	90                   	nop

00800c00 <__umoddi3>:
  800c00:	55                   	push   %ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	83 ec 20             	sub    $0x20,%esp
  800c06:	8b 44 24 34          	mov    0x34(%esp),%eax
  800c0a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c0e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c12:	89 c6                	mov    %eax,%esi
  800c14:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c18:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c1c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  800c20:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800c24:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800c28:	89 74 24 18          	mov    %esi,0x18(%esp)
  800c2c:	85 c0                	test   %eax,%eax
  800c2e:	89 c2                	mov    %eax,%edx
  800c30:	75 1e                	jne    800c50 <__umoddi3+0x50>
  800c32:	39 f7                	cmp    %esi,%edi
  800c34:	76 52                	jbe    800c88 <__umoddi3+0x88>
  800c36:	89 c8                	mov    %ecx,%eax
  800c38:	89 f2                	mov    %esi,%edx
  800c3a:	f7 f7                	div    %edi
  800c3c:	89 d0                	mov    %edx,%eax
  800c3e:	31 d2                	xor    %edx,%edx
  800c40:	83 c4 20             	add    $0x20,%esp
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    
  800c47:	89 f6                	mov    %esi,%esi
  800c49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800c50:	39 f0                	cmp    %esi,%eax
  800c52:	77 5c                	ja     800cb0 <__umoddi3+0xb0>
  800c54:	0f bd e8             	bsr    %eax,%ebp
  800c57:	83 f5 1f             	xor    $0x1f,%ebp
  800c5a:	75 64                	jne    800cc0 <__umoddi3+0xc0>
  800c5c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  800c60:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  800c64:	0f 86 f6 00 00 00    	jbe    800d60 <__umoddi3+0x160>
  800c6a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  800c6e:	0f 82 ec 00 00 00    	jb     800d60 <__umoddi3+0x160>
  800c74:	8b 44 24 14          	mov    0x14(%esp),%eax
  800c78:	8b 54 24 18          	mov    0x18(%esp),%edx
  800c7c:	83 c4 20             	add    $0x20,%esp
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    
  800c83:	90                   	nop
  800c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c88:	85 ff                	test   %edi,%edi
  800c8a:	89 fd                	mov    %edi,%ebp
  800c8c:	75 0b                	jne    800c99 <__umoddi3+0x99>
  800c8e:	b8 01 00 00 00       	mov    $0x1,%eax
  800c93:	31 d2                	xor    %edx,%edx
  800c95:	f7 f7                	div    %edi
  800c97:	89 c5                	mov    %eax,%ebp
  800c99:	8b 44 24 10          	mov    0x10(%esp),%eax
  800c9d:	31 d2                	xor    %edx,%edx
  800c9f:	f7 f5                	div    %ebp
  800ca1:	89 c8                	mov    %ecx,%eax
  800ca3:	f7 f5                	div    %ebp
  800ca5:	eb 95                	jmp    800c3c <__umoddi3+0x3c>
  800ca7:	89 f6                	mov    %esi,%esi
  800ca9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800cb0:	89 c8                	mov    %ecx,%eax
  800cb2:	89 f2                	mov    %esi,%edx
  800cb4:	83 c4 20             	add    $0x20,%esp
  800cb7:	5e                   	pop    %esi
  800cb8:	5f                   	pop    %edi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    
  800cbb:	90                   	nop
  800cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cc0:	b8 20 00 00 00       	mov    $0x20,%eax
  800cc5:	89 e9                	mov    %ebp,%ecx
  800cc7:	29 e8                	sub    %ebp,%eax
  800cc9:	d3 e2                	shl    %cl,%edx
  800ccb:	89 c7                	mov    %eax,%edi
  800ccd:	89 44 24 18          	mov    %eax,0x18(%esp)
  800cd1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cd5:	89 f9                	mov    %edi,%ecx
  800cd7:	d3 e8                	shr    %cl,%eax
  800cd9:	89 c1                	mov    %eax,%ecx
  800cdb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cdf:	09 d1                	or     %edx,%ecx
  800ce1:	89 fa                	mov    %edi,%edx
  800ce3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800ce7:	89 e9                	mov    %ebp,%ecx
  800ce9:	d3 e0                	shl    %cl,%eax
  800ceb:	89 f9                	mov    %edi,%ecx
  800ced:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cf1:	89 f0                	mov    %esi,%eax
  800cf3:	d3 e8                	shr    %cl,%eax
  800cf5:	89 e9                	mov    %ebp,%ecx
  800cf7:	89 c7                	mov    %eax,%edi
  800cf9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800cfd:	d3 e6                	shl    %cl,%esi
  800cff:	89 d1                	mov    %edx,%ecx
  800d01:	89 fa                	mov    %edi,%edx
  800d03:	d3 e8                	shr    %cl,%eax
  800d05:	89 e9                	mov    %ebp,%ecx
  800d07:	09 f0                	or     %esi,%eax
  800d09:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  800d0d:	f7 74 24 10          	divl   0x10(%esp)
  800d11:	d3 e6                	shl    %cl,%esi
  800d13:	89 d1                	mov    %edx,%ecx
  800d15:	f7 64 24 0c          	mull   0xc(%esp)
  800d19:	39 d1                	cmp    %edx,%ecx
  800d1b:	89 74 24 14          	mov    %esi,0x14(%esp)
  800d1f:	89 d7                	mov    %edx,%edi
  800d21:	89 c6                	mov    %eax,%esi
  800d23:	72 0a                	jb     800d2f <__umoddi3+0x12f>
  800d25:	39 44 24 14          	cmp    %eax,0x14(%esp)
  800d29:	73 10                	jae    800d3b <__umoddi3+0x13b>
  800d2b:	39 d1                	cmp    %edx,%ecx
  800d2d:	75 0c                	jne    800d3b <__umoddi3+0x13b>
  800d2f:	89 d7                	mov    %edx,%edi
  800d31:	89 c6                	mov    %eax,%esi
  800d33:	2b 74 24 0c          	sub    0xc(%esp),%esi
  800d37:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  800d3b:	89 ca                	mov    %ecx,%edx
  800d3d:	89 e9                	mov    %ebp,%ecx
  800d3f:	8b 44 24 14          	mov    0x14(%esp),%eax
  800d43:	29 f0                	sub    %esi,%eax
  800d45:	19 fa                	sbb    %edi,%edx
  800d47:	d3 e8                	shr    %cl,%eax
  800d49:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  800d4e:	89 d7                	mov    %edx,%edi
  800d50:	d3 e7                	shl    %cl,%edi
  800d52:	89 e9                	mov    %ebp,%ecx
  800d54:	09 f8                	or     %edi,%eax
  800d56:	d3 ea                	shr    %cl,%edx
  800d58:	83 c4 20             	add    $0x20,%esp
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    
  800d5f:	90                   	nop
  800d60:	8b 74 24 10          	mov    0x10(%esp),%esi
  800d64:	29 f9                	sub    %edi,%ecx
  800d66:	19 c6                	sbb    %eax,%esi
  800d68:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800d6c:	89 74 24 18          	mov    %esi,0x18(%esp)
  800d70:	e9 ff fe ff ff       	jmp    800c74 <__umoddi3+0x74>
