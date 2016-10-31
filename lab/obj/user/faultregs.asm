
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 64 05 00 00       	call   800595 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	8b 45 08             	mov    0x8(%ebp),%eax
  800043:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800047:	89 54 24 08          	mov    %edx,0x8(%esp)
  80004b:	c7 44 24 04 51 16 80 	movl   $0x801651,0x4(%esp)
  800052:	00 
  800053:	c7 04 24 20 16 80 00 	movl   $0x801620,(%esp)
  80005a:	e8 a1 06 00 00       	call   800700 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  80005f:	8b 03                	mov    (%ebx),%eax
  800061:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800065:	8b 06                	mov    (%esi),%eax
  800067:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006b:	c7 44 24 04 30 16 80 	movl   $0x801630,0x4(%esp)
  800072:	00 
  800073:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  80007a:	e8 81 06 00 00       	call   800700 <cprintf>
  80007f:	8b 03                	mov    (%ebx),%eax
  800081:	39 06                	cmp    %eax,(%esi)
  800083:	75 13                	jne    800098 <check_regs+0x65>
  800085:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  80008c:	e8 6f 06 00 00       	call   800700 <cprintf>

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  800091:	bf 00 00 00 00       	mov    $0x0,%edi
  800096:	eb 11                	jmp    8000a9 <check_regs+0x76>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800098:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  80009f:	e8 5c 06 00 00       	call   800700 <cprintf>
  8000a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000a9:	8b 43 04             	mov    0x4(%ebx),%eax
  8000ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b0:	8b 46 04             	mov    0x4(%esi),%eax
  8000b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b7:	c7 44 24 04 52 16 80 	movl   $0x801652,0x4(%esp)
  8000be:	00 
  8000bf:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  8000c6:	e8 35 06 00 00       	call   800700 <cprintf>
  8000cb:	8b 43 04             	mov    0x4(%ebx),%eax
  8000ce:	39 46 04             	cmp    %eax,0x4(%esi)
  8000d1:	75 0e                	jne    8000e1 <check_regs+0xae>
  8000d3:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  8000da:	e8 21 06 00 00       	call   800700 <cprintf>
  8000df:	eb 11                	jmp    8000f2 <check_regs+0xbf>
  8000e1:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  8000e8:	e8 13 06 00 00       	call   800700 <cprintf>
  8000ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f2:	8b 43 08             	mov    0x8(%ebx),%eax
  8000f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f9:	8b 46 08             	mov    0x8(%esi),%eax
  8000fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800100:	c7 44 24 04 56 16 80 	movl   $0x801656,0x4(%esp)
  800107:	00 
  800108:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  80010f:	e8 ec 05 00 00       	call   800700 <cprintf>
  800114:	8b 43 08             	mov    0x8(%ebx),%eax
  800117:	39 46 08             	cmp    %eax,0x8(%esi)
  80011a:	75 0e                	jne    80012a <check_regs+0xf7>
  80011c:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  800123:	e8 d8 05 00 00       	call   800700 <cprintf>
  800128:	eb 11                	jmp    80013b <check_regs+0x108>
  80012a:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  800131:	e8 ca 05 00 00       	call   800700 <cprintf>
  800136:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013b:	8b 43 10             	mov    0x10(%ebx),%eax
  80013e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800142:	8b 46 10             	mov    0x10(%esi),%eax
  800145:	89 44 24 08          	mov    %eax,0x8(%esp)
  800149:	c7 44 24 04 5a 16 80 	movl   $0x80165a,0x4(%esp)
  800150:	00 
  800151:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  800158:	e8 a3 05 00 00       	call   800700 <cprintf>
  80015d:	8b 43 10             	mov    0x10(%ebx),%eax
  800160:	39 46 10             	cmp    %eax,0x10(%esi)
  800163:	75 0e                	jne    800173 <check_regs+0x140>
  800165:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  80016c:	e8 8f 05 00 00       	call   800700 <cprintf>
  800171:	eb 11                	jmp    800184 <check_regs+0x151>
  800173:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  80017a:	e8 81 05 00 00       	call   800700 <cprintf>
  80017f:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800184:	8b 43 14             	mov    0x14(%ebx),%eax
  800187:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018b:	8b 46 14             	mov    0x14(%esi),%eax
  80018e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800192:	c7 44 24 04 5e 16 80 	movl   $0x80165e,0x4(%esp)
  800199:	00 
  80019a:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  8001a1:	e8 5a 05 00 00       	call   800700 <cprintf>
  8001a6:	8b 43 14             	mov    0x14(%ebx),%eax
  8001a9:	39 46 14             	cmp    %eax,0x14(%esi)
  8001ac:	75 0e                	jne    8001bc <check_regs+0x189>
  8001ae:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  8001b5:	e8 46 05 00 00       	call   800700 <cprintf>
  8001ba:	eb 11                	jmp    8001cd <check_regs+0x19a>
  8001bc:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  8001c3:	e8 38 05 00 00       	call   800700 <cprintf>
  8001c8:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001cd:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d4:	8b 46 18             	mov    0x18(%esi),%eax
  8001d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001db:	c7 44 24 04 62 16 80 	movl   $0x801662,0x4(%esp)
  8001e2:	00 
  8001e3:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  8001ea:	e8 11 05 00 00       	call   800700 <cprintf>
  8001ef:	8b 43 18             	mov    0x18(%ebx),%eax
  8001f2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001f5:	75 0e                	jne    800205 <check_regs+0x1d2>
  8001f7:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  8001fe:	e8 fd 04 00 00       	call   800700 <cprintf>
  800203:	eb 11                	jmp    800216 <check_regs+0x1e3>
  800205:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  80020c:	e8 ef 04 00 00       	call   800700 <cprintf>
  800211:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021d:	8b 46 1c             	mov    0x1c(%esi),%eax
  800220:	89 44 24 08          	mov    %eax,0x8(%esp)
  800224:	c7 44 24 04 66 16 80 	movl   $0x801666,0x4(%esp)
  80022b:	00 
  80022c:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  800233:	e8 c8 04 00 00       	call   800700 <cprintf>
  800238:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80023b:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80023e:	75 0e                	jne    80024e <check_regs+0x21b>
  800240:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  800247:	e8 b4 04 00 00       	call   800700 <cprintf>
  80024c:	eb 11                	jmp    80025f <check_regs+0x22c>
  80024e:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  800255:	e8 a6 04 00 00       	call   800700 <cprintf>
  80025a:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  80025f:	8b 43 20             	mov    0x20(%ebx),%eax
  800262:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800266:	8b 46 20             	mov    0x20(%esi),%eax
  800269:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026d:	c7 44 24 04 6a 16 80 	movl   $0x80166a,0x4(%esp)
  800274:	00 
  800275:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  80027c:	e8 7f 04 00 00       	call   800700 <cprintf>
  800281:	8b 43 20             	mov    0x20(%ebx),%eax
  800284:	39 46 20             	cmp    %eax,0x20(%esi)
  800287:	75 0e                	jne    800297 <check_regs+0x264>
  800289:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  800290:	e8 6b 04 00 00       	call   800700 <cprintf>
  800295:	eb 11                	jmp    8002a8 <check_regs+0x275>
  800297:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  80029e:	e8 5d 04 00 00       	call   800700 <cprintf>
  8002a3:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a8:	8b 43 24             	mov    0x24(%ebx),%eax
  8002ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002af:	8b 46 24             	mov    0x24(%esi),%eax
  8002b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b6:	c7 44 24 04 6e 16 80 	movl   $0x80166e,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  8002c5:	e8 36 04 00 00       	call   800700 <cprintf>
  8002ca:	8b 43 24             	mov    0x24(%ebx),%eax
  8002cd:	39 46 24             	cmp    %eax,0x24(%esi)
  8002d0:	75 0e                	jne    8002e0 <check_regs+0x2ad>
  8002d2:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  8002d9:	e8 22 04 00 00       	call   800700 <cprintf>
  8002de:	eb 11                	jmp    8002f1 <check_regs+0x2be>
  8002e0:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  8002e7:	e8 14 04 00 00       	call   800700 <cprintf>
  8002ec:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f8:	8b 46 28             	mov    0x28(%esi),%eax
  8002fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ff:	c7 44 24 04 75 16 80 	movl   $0x801675,0x4(%esp)
  800306:	00 
  800307:	c7 04 24 34 16 80 00 	movl   $0x801634,(%esp)
  80030e:	e8 ed 03 00 00       	call   800700 <cprintf>
  800313:	8b 43 28             	mov    0x28(%ebx),%eax
  800316:	39 46 28             	cmp    %eax,0x28(%esi)
  800319:	75 25                	jne    800340 <check_regs+0x30d>
  80031b:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  800322:	e8 d9 03 00 00       	call   800700 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800327:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032e:	c7 04 24 79 16 80 00 	movl   $0x801679,(%esp)
  800335:	e8 c6 03 00 00       	call   800700 <cprintf>
	if (!mismatch)
  80033a:	85 ff                	test   %edi,%edi
  80033c:	74 23                	je     800361 <check_regs+0x32e>
  80033e:	eb 2f                	jmp    80036f <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800340:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  800347:	e8 b4 03 00 00       	call   800700 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800353:	c7 04 24 79 16 80 00 	movl   $0x801679,(%esp)
  80035a:	e8 a1 03 00 00       	call   800700 <cprintf>
  80035f:	eb 0e                	jmp    80036f <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800361:	c7 04 24 44 16 80 00 	movl   $0x801644,(%esp)
  800368:	e8 93 03 00 00       	call   800700 <cprintf>
  80036d:	eb 0c                	jmp    80037b <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  80036f:	c7 04 24 48 16 80 00 	movl   $0x801648,(%esp)
  800376:	e8 85 03 00 00       	call   800700 <cprintf>
}
  80037b:	83 c4 1c             	add    $0x1c,%esp
  80037e:	5b                   	pop    %ebx
  80037f:	5e                   	pop    %esi
  800380:	5f                   	pop    %edi
  800381:	5d                   	pop    %ebp
  800382:	c3                   	ret    

00800383 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	83 ec 28             	sub    $0x28,%esp
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038c:	8b 10                	mov    (%eax),%edx
  80038e:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800394:	74 27                	je     8003bd <pgfault+0x3a>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800396:	8b 40 28             	mov    0x28(%eax),%eax
  800399:	89 44 24 10          	mov    %eax,0x10(%esp)
  80039d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a1:	c7 44 24 08 e0 16 80 	movl   $0x8016e0,0x8(%esp)
  8003a8:	00 
  8003a9:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b0:	00 
  8003b1:	c7 04 24 87 16 80 00 	movl   $0x801687,(%esp)
  8003b8:	e8 4a 02 00 00       	call   800607 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003bd:	8b 50 08             	mov    0x8(%eax),%edx
  8003c0:	89 15 60 20 80 00    	mov    %edx,0x802060
  8003c6:	8b 50 0c             	mov    0xc(%eax),%edx
  8003c9:	89 15 64 20 80 00    	mov    %edx,0x802064
  8003cf:	8b 50 10             	mov    0x10(%eax),%edx
  8003d2:	89 15 68 20 80 00    	mov    %edx,0x802068
  8003d8:	8b 50 14             	mov    0x14(%eax),%edx
  8003db:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  8003e1:	8b 50 18             	mov    0x18(%eax),%edx
  8003e4:	89 15 70 20 80 00    	mov    %edx,0x802070
  8003ea:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003ed:	89 15 74 20 80 00    	mov    %edx,0x802074
  8003f3:	8b 50 20             	mov    0x20(%eax),%edx
  8003f6:	89 15 78 20 80 00    	mov    %edx,0x802078
  8003fc:	8b 50 24             	mov    0x24(%eax),%edx
  8003ff:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800405:	8b 50 28             	mov    0x28(%eax),%edx
  800408:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags;
  80040e:	8b 50 2c             	mov    0x2c(%eax),%edx
  800411:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  800417:	8b 40 30             	mov    0x30(%eax),%eax
  80041a:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80041f:	c7 44 24 04 9f 16 80 	movl   $0x80169f,0x4(%esp)
  800426:	00 
  800427:	c7 04 24 ad 16 80 00 	movl   $0x8016ad,(%esp)
  80042e:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800433:	ba 98 16 80 00       	mov    $0x801698,%edx
  800438:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  80043d:	e8 f1 fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800442:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800449:	00 
  80044a:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  800451:	00 
  800452:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800459:	e8 e5 0c 00 00       	call   801143 <sys_page_alloc>
  80045e:	85 c0                	test   %eax,%eax
  800460:	79 20                	jns    800482 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800462:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800466:	c7 44 24 08 b4 16 80 	movl   $0x8016b4,0x8(%esp)
  80046d:	00 
  80046e:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800475:	00 
  800476:	c7 04 24 87 16 80 00 	movl   $0x801687,(%esp)
  80047d:	e8 85 01 00 00       	call   800607 <_panic>
}
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <umain>:

void
umain(int argc, char **argv)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  80048a:	c7 04 24 83 03 80 00 	movl   $0x800383,(%esp)
  800491:	e8 c2 0e 00 00       	call   801358 <set_pgfault_handler>

	__asm __volatile(
  800496:	50                   	push   %eax
  800497:	9c                   	pushf  
  800498:	58                   	pop    %eax
  800499:	0d d5 08 00 00       	or     $0x8d5,%eax
  80049e:	50                   	push   %eax
  80049f:	9d                   	popf   
  8004a0:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  8004a5:	8d 05 e0 04 80 00    	lea    0x8004e0,%eax
  8004ab:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004b0:	58                   	pop    %eax
  8004b1:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8004b7:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8004bd:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  8004c3:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  8004c9:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8004cf:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  8004d5:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  8004da:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  8004e0:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e7:	00 00 00 
  8004ea:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8004f0:	89 35 24 20 80 00    	mov    %esi,0x802024
  8004f6:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8004fc:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  800502:	89 15 34 20 80 00    	mov    %edx,0x802034
  800508:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  80050e:	a3 3c 20 80 00       	mov    %eax,0x80203c
  800513:	89 25 48 20 80 00    	mov    %esp,0x802048
  800519:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  80051f:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  800525:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  80052b:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  800531:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  800537:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  80053d:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  800542:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  800548:	50                   	push   %eax
  800549:	9c                   	pushf  
  80054a:	58                   	pop    %eax
  80054b:	a3 44 20 80 00       	mov    %eax,0x802044
  800550:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800551:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800558:	74 0c                	je     800566 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  80055a:	c7 04 24 14 17 80 00 	movl   $0x801714,(%esp)
  800561:	e8 9a 01 00 00       	call   800700 <cprintf>
	after.eip = before.eip;
  800566:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  80056b:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  800570:	c7 44 24 04 c7 16 80 	movl   $0x8016c7,0x4(%esp)
  800577:	00 
  800578:	c7 04 24 d8 16 80 00 	movl   $0x8016d8,(%esp)
  80057f:	b9 20 20 80 00       	mov    $0x802020,%ecx
  800584:	ba 98 16 80 00       	mov    $0x801698,%edx
  800589:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  80058e:	e8 a0 fa ff ff       	call   800033 <check_regs>
}
  800593:	c9                   	leave  
  800594:	c3                   	ret    

00800595 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800595:	55                   	push   %ebp
  800596:	89 e5                	mov    %esp,%ebp
  800598:	57                   	push   %edi
  800599:	56                   	push   %esi
  80059a:	53                   	push   %ebx
  80059b:	83 ec 1c             	sub    $0x1c,%esp
  80059e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//thisenv = envs[sys_getenvid];
	//envid2env(sys_getenvid, &thisenv, 1);
	//((sys_getenvid) & (1024 - 1))
	int envid = sys_getenvid();
  8005a4:	e8 5c 0b 00 00       	call   801105 <sys_getenvid>
	int index = envid & (1023);
  8005a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005ae:	89 c6                	mov    %eax,%esi
	cprintf("Value of x:%x\n",index);
  8005b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b4:	c7 04 24 33 17 80 00 	movl   $0x801733,(%esp)
  8005bb:	e8 40 01 00 00       	call   800700 <cprintf>
	thisenv = &envs[index];
  8005c0:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8005c3:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8005c9:	89 35 cc 20 80 00    	mov    %esi,0x8020cc
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005cf:	85 db                	test   %ebx,%ebx
  8005d1:	7e 07                	jle    8005da <libmain+0x45>
		binaryname = argv[0];
  8005d3:	8b 07                	mov    (%edi),%eax
  8005d5:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8005da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005de:	89 1c 24             	mov    %ebx,(%esp)
  8005e1:	e8 9e fe ff ff       	call   800484 <umain>

	// exit gracefully
	exit();
  8005e6:	e8 08 00 00 00       	call   8005f3 <exit>
}
  8005eb:	83 c4 1c             	add    $0x1c,%esp
  8005ee:	5b                   	pop    %ebx
  8005ef:	5e                   	pop    %esi
  8005f0:	5f                   	pop    %edi
  8005f1:	5d                   	pop    %ebp
  8005f2:	c3                   	ret    

008005f3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005f3:	55                   	push   %ebp
  8005f4:	89 e5                	mov    %esp,%ebp
  8005f6:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8005f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800600:	e8 ae 0a 00 00       	call   8010b3 <sys_env_destroy>
}
  800605:	c9                   	leave  
  800606:	c3                   	ret    

00800607 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800607:	55                   	push   %ebp
  800608:	89 e5                	mov    %esp,%ebp
  80060a:	56                   	push   %esi
  80060b:	53                   	push   %ebx
  80060c:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80060f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800612:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800618:	e8 e8 0a 00 00       	call   801105 <sys_getenvid>
  80061d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800620:	89 54 24 10          	mov    %edx,0x10(%esp)
  800624:	8b 55 08             	mov    0x8(%ebp),%edx
  800627:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80062b:	89 74 24 08          	mov    %esi,0x8(%esp)
  80062f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800633:	c7 04 24 4c 17 80 00 	movl   $0x80174c,(%esp)
  80063a:	e8 c1 00 00 00       	call   800700 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80063f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800643:	8b 45 10             	mov    0x10(%ebp),%eax
  800646:	89 04 24             	mov    %eax,(%esp)
  800649:	e8 51 00 00 00       	call   80069f <vcprintf>
	cprintf("\n");
  80064e:	c7 04 24 50 16 80 00 	movl   $0x801650,(%esp)
  800655:	e8 a6 00 00 00       	call   800700 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80065a:	cc                   	int3   
  80065b:	eb fd                	jmp    80065a <_panic+0x53>

0080065d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80065d:	55                   	push   %ebp
  80065e:	89 e5                	mov    %esp,%ebp
  800660:	53                   	push   %ebx
  800661:	83 ec 14             	sub    $0x14,%esp
  800664:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800667:	8b 13                	mov    (%ebx),%edx
  800669:	8d 42 01             	lea    0x1(%edx),%eax
  80066c:	89 03                	mov    %eax,(%ebx)
  80066e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800671:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800675:	3d ff 00 00 00       	cmp    $0xff,%eax
  80067a:	75 19                	jne    800695 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80067c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800683:	00 
  800684:	8d 43 08             	lea    0x8(%ebx),%eax
  800687:	89 04 24             	mov    %eax,(%esp)
  80068a:	e8 e7 09 00 00       	call   801076 <sys_cputs>
		b->idx = 0;
  80068f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800695:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800699:	83 c4 14             	add    $0x14,%esp
  80069c:	5b                   	pop    %ebx
  80069d:	5d                   	pop    %ebp
  80069e:	c3                   	ret    

0080069f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8006a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006af:	00 00 00 
	b.cnt = 0;
  8006b2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006b9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d4:	c7 04 24 5d 06 80 00 	movl   $0x80065d,(%esp)
  8006db:	e8 ae 01 00 00       	call   80088e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006e0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ea:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006f0:	89 04 24             	mov    %eax,(%esp)
  8006f3:	e8 7e 09 00 00       	call   801076 <sys_cputs>

	return b.cnt;
}
  8006f8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006fe:	c9                   	leave  
  8006ff:	c3                   	ret    

00800700 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800706:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800709:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070d:	8b 45 08             	mov    0x8(%ebp),%eax
  800710:	89 04 24             	mov    %eax,(%esp)
  800713:	e8 87 ff ff ff       	call   80069f <vcprintf>
	va_end(ap);

	return cnt;
}
  800718:	c9                   	leave  
  800719:	c3                   	ret    
  80071a:	66 90                	xchg   %ax,%ax
  80071c:	66 90                	xchg   %ax,%ax
  80071e:	66 90                	xchg   %ax,%ax

00800720 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	57                   	push   %edi
  800724:	56                   	push   %esi
  800725:	53                   	push   %ebx
  800726:	83 ec 3c             	sub    $0x3c,%esp
  800729:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80072c:	89 d7                	mov    %edx,%edi
  80072e:	8b 45 08             	mov    0x8(%ebp),%eax
  800731:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800734:	8b 45 0c             	mov    0xc(%ebp),%eax
  800737:	89 c3                	mov    %eax,%ebx
  800739:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80073c:	8b 45 10             	mov    0x10(%ebp),%eax
  80073f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800742:	b9 00 00 00 00       	mov    $0x0,%ecx
  800747:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80074a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80074d:	39 d9                	cmp    %ebx,%ecx
  80074f:	72 05                	jb     800756 <printnum+0x36>
  800751:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800754:	77 69                	ja     8007bf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800756:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800759:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80075d:	83 ee 01             	sub    $0x1,%esi
  800760:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800764:	89 44 24 08          	mov    %eax,0x8(%esp)
  800768:	8b 44 24 08          	mov    0x8(%esp),%eax
  80076c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800770:	89 c3                	mov    %eax,%ebx
  800772:	89 d6                	mov    %edx,%esi
  800774:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800777:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80077a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80077e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800782:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800785:	89 04 24             	mov    %eax,(%esp)
  800788:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80078b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078f:	e8 fc 0b 00 00       	call   801390 <__udivdi3>
  800794:	89 d9                	mov    %ebx,%ecx
  800796:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80079a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80079e:	89 04 24             	mov    %eax,(%esp)
  8007a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a5:	89 fa                	mov    %edi,%edx
  8007a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007aa:	e8 71 ff ff ff       	call   800720 <printnum>
  8007af:	eb 1b                	jmp    8007cc <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007b5:	8b 45 18             	mov    0x18(%ebp),%eax
  8007b8:	89 04 24             	mov    %eax,(%esp)
  8007bb:	ff d3                	call   *%ebx
  8007bd:	eb 03                	jmp    8007c2 <printnum+0xa2>
  8007bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007c2:	83 ee 01             	sub    $0x1,%esi
  8007c5:	85 f6                	test   %esi,%esi
  8007c7:	7f e8                	jg     8007b1 <printnum+0x91>
  8007c9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8007d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007de:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007e5:	89 04 24             	mov    %eax,(%esp)
  8007e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ef:	e8 cc 0c 00 00       	call   8014c0 <__umoddi3>
  8007f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007f8:	0f be 80 6f 17 80 00 	movsbl 0x80176f(%eax),%eax
  8007ff:	89 04 24             	mov    %eax,(%esp)
  800802:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800805:	ff d0                	call   *%eax
}
  800807:	83 c4 3c             	add    $0x3c,%esp
  80080a:	5b                   	pop    %ebx
  80080b:	5e                   	pop    %esi
  80080c:	5f                   	pop    %edi
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800812:	83 fa 01             	cmp    $0x1,%edx
  800815:	7e 0e                	jle    800825 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800817:	8b 10                	mov    (%eax),%edx
  800819:	8d 4a 08             	lea    0x8(%edx),%ecx
  80081c:	89 08                	mov    %ecx,(%eax)
  80081e:	8b 02                	mov    (%edx),%eax
  800820:	8b 52 04             	mov    0x4(%edx),%edx
  800823:	eb 22                	jmp    800847 <getuint+0x38>
	else if (lflag)
  800825:	85 d2                	test   %edx,%edx
  800827:	74 10                	je     800839 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800829:	8b 10                	mov    (%eax),%edx
  80082b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80082e:	89 08                	mov    %ecx,(%eax)
  800830:	8b 02                	mov    (%edx),%eax
  800832:	ba 00 00 00 00       	mov    $0x0,%edx
  800837:	eb 0e                	jmp    800847 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800839:	8b 10                	mov    (%eax),%edx
  80083b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80083e:	89 08                	mov    %ecx,(%eax)
  800840:	8b 02                	mov    (%edx),%eax
  800842:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80084f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800853:	8b 10                	mov    (%eax),%edx
  800855:	3b 50 04             	cmp    0x4(%eax),%edx
  800858:	73 0a                	jae    800864 <sprintputch+0x1b>
		*b->buf++ = ch;
  80085a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80085d:	89 08                	mov    %ecx,(%eax)
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	88 02                	mov    %al,(%edx)
}
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80086c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80086f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800873:	8b 45 10             	mov    0x10(%ebp),%eax
  800876:	89 44 24 08          	mov    %eax,0x8(%esp)
  80087a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	89 04 24             	mov    %eax,(%esp)
  800887:	e8 02 00 00 00       	call   80088e <vprintfmt>
	va_end(ap);
}
  80088c:	c9                   	leave  
  80088d:	c3                   	ret    

0080088e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	57                   	push   %edi
  800892:	56                   	push   %esi
  800893:	53                   	push   %ebx
  800894:	83 ec 3c             	sub    $0x3c,%esp
  800897:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80089a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80089d:	eb 14                	jmp    8008b3 <vprintfmt+0x25>

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
		{
			if (ch == '\0')
  80089f:	85 c0                	test   %eax,%eax
  8008a1:	0f 84 b3 03 00 00    	je     800c5a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
  8008a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ab:	89 04 24             	mov    %eax,(%esp)
  8008ae:	ff 55 08             	call   *0x8(%ebp)
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) 
	{
		while ((ch = *(unsigned char *) fmt++) != '%') 
  8008b1:	89 f3                	mov    %esi,%ebx
  8008b3:	8d 73 01             	lea    0x1(%ebx),%esi
  8008b6:	0f b6 03             	movzbl (%ebx),%eax
  8008b9:	83 f8 25             	cmp    $0x25,%eax
  8008bc:	75 e1                	jne    80089f <vprintfmt+0x11>
  8008be:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8008c2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  8008c9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8008d0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
  8008d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8008dc:	eb 1d                	jmp    8008fb <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8008de:	89 de                	mov    %ebx,%esi
		{

			// flag to pad on the right
			case '-':
				padc = '-';
  8008e0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8008e4:	eb 15                	jmp    8008fb <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8008e6:	89 de                	mov    %ebx,%esi
				padc = '-';
				goto reswitch;

			// flag to pad with 0's instead of spaces
			case '0':
				padc = '0';
  8008e8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8008ec:	eb 0d                	jmp    8008fb <vprintfmt+0x6d>
				altflag = 1;
				goto reswitch;

			process_precision:
				if (width < 0)
					width = precision, precision = -1;
  8008ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8008f1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008f4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8008fb:	8d 5e 01             	lea    0x1(%esi),%ebx
  8008fe:	0f b6 0e             	movzbl (%esi),%ecx
  800901:	0f b6 c1             	movzbl %cl,%eax
  800904:	83 e9 23             	sub    $0x23,%ecx
  800907:	80 f9 55             	cmp    $0x55,%cl
  80090a:	0f 87 2a 03 00 00    	ja     800c3a <vprintfmt+0x3ac>
  800910:	0f b6 c9             	movzbl %cl,%ecx
  800913:	ff 24 8d 40 18 80 00 	jmp    *0x801840(,%ecx,4)
  80091a:	89 de                	mov    %ebx,%esi
  80091c:	b9 00 00 00 00       	mov    $0x0,%ecx
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
					precision = precision * 10 + ch - '0';
  800921:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800924:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
					ch = *fmt;
  800928:	0f be 06             	movsbl (%esi),%eax
					if (ch < '0' || ch > '9')
  80092b:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80092e:	83 fb 09             	cmp    $0x9,%ebx
  800931:	77 36                	ja     800969 <vprintfmt+0xdb>
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				for (precision = 0; ; ++fmt) {
  800933:	83 c6 01             	add    $0x1,%esi
					precision = precision * 10 + ch - '0';
					ch = *fmt;
					if (ch < '0' || ch > '9')
						break;
				}
  800936:	eb e9                	jmp    800921 <vprintfmt+0x93>
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
  800938:	8b 45 14             	mov    0x14(%ebp),%eax
  80093b:	8d 48 04             	lea    0x4(%eax),%ecx
  80093e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800941:	8b 00                	mov    (%eax),%eax
  800943:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  800946:	89 de                	mov    %ebx,%esi
				}
				goto process_precision;

			case '*':
				precision = va_arg(ap, int);
				goto process_precision;
  800948:	eb 22                	jmp    80096c <vprintfmt+0xde>
  80094a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80094d:	85 c9                	test   %ecx,%ecx
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
  800954:	0f 49 c1             	cmovns %ecx,%eax
  800957:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  80095a:	89 de                	mov    %ebx,%esi
  80095c:	eb 9d                	jmp    8008fb <vprintfmt+0x6d>
  80095e:	89 de                	mov    %ebx,%esi
				if (width < 0)
					width = 0;
				goto reswitch;

			case '#':
				altflag = 1;
  800960:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
				goto reswitch;
  800967:	eb 92                	jmp    8008fb <vprintfmt+0x6d>
  800969:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

			process_precision:
				if (width < 0)
  80096c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800970:	79 89                	jns    8008fb <vprintfmt+0x6d>
  800972:	e9 77 ff ff ff       	jmp    8008ee <vprintfmt+0x60>
					width = precision, precision = -1;
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
  800977:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  80097a:	89 de                	mov    %ebx,%esi
				goto reswitch;

			// long flag (doubled for long long)
			case 'l':
				lflag++;
				goto reswitch;
  80097c:	e9 7a ff ff ff       	jmp    8008fb <vprintfmt+0x6d>

			// character
			case 'c':
				putch(va_arg(ap, int), putdat);
  800981:	8b 45 14             	mov    0x14(%ebp),%eax
  800984:	8d 50 04             	lea    0x4(%eax),%edx
  800987:	89 55 14             	mov    %edx,0x14(%ebp)
  80098a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80098e:	8b 00                	mov    (%eax),%eax
  800990:	89 04 24             	mov    %eax,(%esp)
  800993:	ff 55 08             	call   *0x8(%ebp)
				break;
  800996:	e9 18 ff ff ff       	jmp    8008b3 <vprintfmt+0x25>

			// error message
			case 'e':
				err = va_arg(ap, int);
  80099b:	8b 45 14             	mov    0x14(%ebp),%eax
  80099e:	8d 50 04             	lea    0x4(%eax),%edx
  8009a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a4:	8b 00                	mov    (%eax),%eax
  8009a6:	99                   	cltd   
  8009a7:	31 d0                	xor    %edx,%eax
  8009a9:	29 d0                	sub    %edx,%eax
				if (err < 0)
					err = -err;
				if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009ab:	83 f8 09             	cmp    $0x9,%eax
  8009ae:	7f 0b                	jg     8009bb <vprintfmt+0x12d>
  8009b0:	8b 14 85 a0 19 80 00 	mov    0x8019a0(,%eax,4),%edx
  8009b7:	85 d2                	test   %edx,%edx
  8009b9:	75 20                	jne    8009db <vprintfmt+0x14d>
					printfmt(putch, putdat, "error %d", err);
  8009bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009bf:	c7 44 24 08 87 17 80 	movl   $0x801787,0x8(%esp)
  8009c6:	00 
  8009c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	89 04 24             	mov    %eax,(%esp)
  8009d1:	e8 90 fe ff ff       	call   800866 <printfmt>
  8009d6:	e9 d8 fe ff ff       	jmp    8008b3 <vprintfmt+0x25>
				else
					printfmt(putch, putdat, "%s", p);
  8009db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009df:	c7 44 24 08 90 17 80 	movl   $0x801790,0x8(%esp)
  8009e6:	00 
  8009e7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	89 04 24             	mov    %eax,(%esp)
  8009f1:	e8 70 fe ff ff       	call   800866 <printfmt>
  8009f6:	e9 b8 fe ff ff       	jmp    8008b3 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) 
  8009fb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8009fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a01:	89 45 d0             	mov    %eax,-0x30(%ebp)
					printfmt(putch, putdat, "%s", p);
				break;

			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
  800a04:	8b 45 14             	mov    0x14(%ebp),%eax
  800a07:	8d 50 04             	lea    0x4(%eax),%edx
  800a0a:	89 55 14             	mov    %edx,0x14(%ebp)
  800a0d:	8b 30                	mov    (%eax),%esi
					p = "(null)";
  800a0f:	85 f6                	test   %esi,%esi
  800a11:	b8 80 17 80 00       	mov    $0x801780,%eax
  800a16:	0f 44 f0             	cmove  %eax,%esi
				if (width > 0 && padc != '-')
  800a19:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800a1d:	0f 84 97 00 00 00    	je     800aba <vprintfmt+0x22c>
  800a23:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800a27:	0f 8e 9b 00 00 00    	jle    800ac8 <vprintfmt+0x23a>
					for (width -= strnlen(p, precision); width > 0; width--)
  800a2d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a31:	89 34 24             	mov    %esi,(%esp)
  800a34:	e8 cf 02 00 00       	call   800d08 <strnlen>
  800a39:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a3c:	29 c2                	sub    %eax,%edx
  800a3e:	89 55 d0             	mov    %edx,-0x30(%ebp)
						putch(padc, putdat);
  800a41:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800a45:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a48:	89 75 d8             	mov    %esi,-0x28(%ebp)
  800a4b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a4e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a51:	89 d3                	mov    %edx,%ebx
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  800a53:	eb 0f                	jmp    800a64 <vprintfmt+0x1d6>
						putch(padc, putdat);
  800a55:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a59:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a5c:	89 04 24             	mov    %eax,(%esp)
  800a5f:	ff d6                	call   *%esi
			// string
			case 's':
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
  800a61:	83 eb 01             	sub    $0x1,%ebx
  800a64:	85 db                	test   %ebx,%ebx
  800a66:	7f ed                	jg     800a55 <vprintfmt+0x1c7>
  800a68:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800a6b:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800a6e:	85 d2                	test   %edx,%edx
  800a70:	b8 00 00 00 00       	mov    $0x0,%eax
  800a75:	0f 49 c2             	cmovns %edx,%eax
  800a78:	29 c2                	sub    %eax,%edx
  800a7a:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800a7d:	89 d7                	mov    %edx,%edi
  800a7f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800a82:	eb 50                	jmp    800ad4 <vprintfmt+0x246>
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
  800a84:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a88:	74 1e                	je     800aa8 <vprintfmt+0x21a>
  800a8a:	0f be d2             	movsbl %dl,%edx
  800a8d:	83 ea 20             	sub    $0x20,%edx
  800a90:	83 fa 5e             	cmp    $0x5e,%edx
  800a93:	76 13                	jbe    800aa8 <vprintfmt+0x21a>
						putch('?', putdat);
  800a95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a98:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800aa3:	ff 55 08             	call   *0x8(%ebp)
  800aa6:	eb 0d                	jmp    800ab5 <vprintfmt+0x227>
					else
						putch(ch, putdat);
  800aa8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aab:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aaf:	89 04 24             	mov    %eax,(%esp)
  800ab2:	ff 55 08             	call   *0x8(%ebp)
				if ((p = va_arg(ap, char *)) == NULL)
					p = "(null)";
				if (width > 0 && padc != '-')
					for (width -= strnlen(p, precision); width > 0; width--)
						putch(padc, putdat);
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab5:	83 ef 01             	sub    $0x1,%edi
  800ab8:	eb 1a                	jmp    800ad4 <vprintfmt+0x246>
  800aba:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800abd:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800ac0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ac3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800ac6:	eb 0c                	jmp    800ad4 <vprintfmt+0x246>
  800ac8:	89 7d 0c             	mov    %edi,0xc(%ebp)
  800acb:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800ace:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ad1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800ad4:	83 c6 01             	add    $0x1,%esi
  800ad7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
  800adb:	0f be c2             	movsbl %dl,%eax
  800ade:	85 c0                	test   %eax,%eax
  800ae0:	74 27                	je     800b09 <vprintfmt+0x27b>
  800ae2:	85 db                	test   %ebx,%ebx
  800ae4:	78 9e                	js     800a84 <vprintfmt+0x1f6>
  800ae6:	83 eb 01             	sub    $0x1,%ebx
  800ae9:	79 99                	jns    800a84 <vprintfmt+0x1f6>
  800aeb:	89 f8                	mov    %edi,%eax
  800aed:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800af0:	8b 75 08             	mov    0x8(%ebp),%esi
  800af3:	89 c3                	mov    %eax,%ebx
  800af5:	eb 1a                	jmp    800b11 <vprintfmt+0x283>
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
					putch(' ', putdat);
  800af7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800afb:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800b02:	ff d6                	call   *%esi
				for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
					if (altflag && (ch < ' ' || ch > '~'))
						putch('?', putdat);
					else
						putch(ch, putdat);
				for (; width > 0; width--)
  800b04:	83 eb 01             	sub    $0x1,%ebx
  800b07:	eb 08                	jmp    800b11 <vprintfmt+0x283>
  800b09:	89 fb                	mov    %edi,%ebx
  800b0b:	8b 75 08             	mov    0x8(%ebp),%esi
  800b0e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b11:	85 db                	test   %ebx,%ebx
  800b13:	7f e2                	jg     800af7 <vprintfmt+0x269>
  800b15:	89 75 08             	mov    %esi,0x8(%ebp)
  800b18:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b1b:	e9 93 fd ff ff       	jmp    8008b3 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b20:	83 fa 01             	cmp    $0x1,%edx
  800b23:	7e 16                	jle    800b3b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
  800b25:	8b 45 14             	mov    0x14(%ebp),%eax
  800b28:	8d 50 08             	lea    0x8(%eax),%edx
  800b2b:	89 55 14             	mov    %edx,0x14(%ebp)
  800b2e:	8b 50 04             	mov    0x4(%eax),%edx
  800b31:	8b 00                	mov    (%eax),%eax
  800b33:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b36:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b39:	eb 32                	jmp    800b6d <vprintfmt+0x2df>
	else if (lflag)
  800b3b:	85 d2                	test   %edx,%edx
  800b3d:	74 18                	je     800b57 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
  800b3f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b42:	8d 50 04             	lea    0x4(%eax),%edx
  800b45:	89 55 14             	mov    %edx,0x14(%ebp)
  800b48:	8b 30                	mov    (%eax),%esi
  800b4a:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800b4d:	89 f0                	mov    %esi,%eax
  800b4f:	c1 f8 1f             	sar    $0x1f,%eax
  800b52:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b55:	eb 16                	jmp    800b6d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
  800b57:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5a:	8d 50 04             	lea    0x4(%eax),%edx
  800b5d:	89 55 14             	mov    %edx,0x14(%ebp)
  800b60:	8b 30                	mov    (%eax),%esi
  800b62:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800b65:	89 f0                	mov    %esi,%eax
  800b67:	c1 f8 1f             	sar    $0x1f,%eax
  800b6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
					putch(' ', putdat);
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
  800b6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b70:	8b 55 e4             	mov    -0x1c(%ebp),%edx
				if ((long long) num < 0) {
					putch('-', putdat);
					num = -(long long) num;
				}
				base = 10;
  800b73:	b9 0a 00 00 00       	mov    $0xa,%ecx
				break;

			// (signed) decimal
			case 'd':
				num = getint(&ap, lflag);
				if ((long long) num < 0) {
  800b78:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b7c:	0f 89 80 00 00 00    	jns    800c02 <vprintfmt+0x374>
					putch('-', putdat);
  800b82:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b86:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b8d:	ff 55 08             	call   *0x8(%ebp)
					num = -(long long) num;
  800b90:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b93:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b96:	f7 d8                	neg    %eax
  800b98:	83 d2 00             	adc    $0x0,%edx
  800b9b:	f7 da                	neg    %edx
				}
				base = 10;
  800b9d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800ba2:	eb 5e                	jmp    800c02 <vprintfmt+0x374>
				goto number;

			// unsigned decimal
			case 'u':
				num = getuint(&ap, lflag);
  800ba4:	8d 45 14             	lea    0x14(%ebp),%eax
  800ba7:	e8 63 fc ff ff       	call   80080f <getuint>
				base = 10;
  800bac:	b9 0a 00 00 00       	mov    $0xa,%ecx
				goto number;
  800bb1:	eb 4f                	jmp    800c02 <vprintfmt+0x374>
				// Replace this with your code.
				/*putch('X', putdat);
				putch('X', putdat);
				putch('X', putdat);*/
				
				num = getuint(&ap, lflag);
  800bb3:	8d 45 14             	lea    0x14(%ebp),%eax
  800bb6:	e8 54 fc ff ff       	call   80080f <getuint>
				base = 8;
  800bbb:	b9 08 00 00 00       	mov    $0x8,%ecx
				goto number;
  800bc0:	eb 40                	jmp    800c02 <vprintfmt+0x374>

			// pointer
			case 'p':
				putch('0', putdat);
  800bc2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bc6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800bcd:	ff 55 08             	call   *0x8(%ebp)
				putch('x', putdat);
  800bd0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bd4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800bdb:	ff 55 08             	call   *0x8(%ebp)
				num = (unsigned long long)
					(uintptr_t) va_arg(ap, void *);
  800bde:	8b 45 14             	mov    0x14(%ebp),%eax
  800be1:	8d 50 04             	lea    0x4(%eax),%edx
  800be4:	89 55 14             	mov    %edx,0x14(%ebp)

			// pointer
			case 'p':
				putch('0', putdat);
				putch('x', putdat);
				num = (unsigned long long)
  800be7:	8b 00                	mov    (%eax),%eax
  800be9:	ba 00 00 00 00       	mov    $0x0,%edx
					(uintptr_t) va_arg(ap, void *);
				base = 16;
  800bee:	b9 10 00 00 00       	mov    $0x10,%ecx
				goto number;
  800bf3:	eb 0d                	jmp    800c02 <vprintfmt+0x374>

			// (unsigned) hexadecimal
			case 'x':
				num = getuint(&ap, lflag);
  800bf5:	8d 45 14             	lea    0x14(%ebp),%eax
  800bf8:	e8 12 fc ff ff       	call   80080f <getuint>
				base = 16;
  800bfd:	b9 10 00 00 00       	mov    $0x10,%ecx
			number:
				printnum(putch, putdat, num, base, width, padc);
  800c02:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
  800c06:	89 74 24 10          	mov    %esi,0x10(%esp)
  800c0a:	8b 75 dc             	mov    -0x24(%ebp),%esi
  800c0d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800c11:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c15:	89 04 24             	mov    %eax,(%esp)
  800c18:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c1c:	89 fa                	mov    %edi,%edx
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	e8 fa fa ff ff       	call   800720 <printnum>
				break;
  800c26:	e9 88 fc ff ff       	jmp    8008b3 <vprintfmt+0x25>

			// escaped '%' character
			case '%':
				putch(ch, putdat);
  800c2b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c2f:	89 04 24             	mov    %eax,(%esp)
  800c32:	ff 55 08             	call   *0x8(%ebp)
				break;
  800c35:	e9 79 fc ff ff       	jmp    8008b3 <vprintfmt+0x25>

			// unrecognized escape sequence - just print it literally
			default:
				putch('%', putdat);
  800c3a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c3e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c45:	ff 55 08             	call   *0x8(%ebp)
				for (fmt--; fmt[-1] != '%'; fmt--)
  800c48:	89 f3                	mov    %esi,%ebx
  800c4a:	eb 03                	jmp    800c4f <vprintfmt+0x3c1>
  800c4c:	83 eb 01             	sub    $0x1,%ebx
  800c4f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  800c53:	75 f7                	jne    800c4c <vprintfmt+0x3be>
  800c55:	e9 59 fc ff ff       	jmp    8008b3 <vprintfmt+0x25>
					/* do nothing */;
				break;
		}
	}
}
  800c5a:	83 c4 3c             	add    $0x3c,%esp
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	83 ec 28             	sub    $0x28,%esp
  800c68:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c71:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c75:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c78:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	74 30                	je     800cb3 <vsnprintf+0x51>
  800c83:	85 d2                	test   %edx,%edx
  800c85:	7e 2c                	jle    800cb3 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c87:	8b 45 14             	mov    0x14(%ebp),%eax
  800c8a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c8e:	8b 45 10             	mov    0x10(%ebp),%eax
  800c91:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c95:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c98:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c9c:	c7 04 24 49 08 80 00 	movl   $0x800849,(%esp)
  800ca3:	e8 e6 fb ff ff       	call   80088e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ca8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb1:	eb 05                	jmp    800cb8 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800cb3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800cb8:	c9                   	leave  
  800cb9:	c3                   	ret    

00800cba <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cc0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cc3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cc7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cca:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd8:	89 04 24             	mov    %eax,(%esp)
  800cdb:	e8 82 ff ff ff       	call   800c62 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ce0:	c9                   	leave  
  800ce1:	c3                   	ret    
  800ce2:	66 90                	xchg   %ax,%ax
  800ce4:	66 90                	xchg   %ax,%ax
  800ce6:	66 90                	xchg   %ax,%ax
  800ce8:	66 90                	xchg   %ax,%ax
  800cea:	66 90                	xchg   %ax,%ax
  800cec:	66 90                	xchg   %ax,%ax
  800cee:	66 90                	xchg   %ax,%ax

00800cf0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cf6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfb:	eb 03                	jmp    800d00 <strlen+0x10>
		n++;
  800cfd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d00:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d04:	75 f7                	jne    800cfd <strlen+0xd>
		n++;
	return n;
}
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d11:	b8 00 00 00 00       	mov    $0x0,%eax
  800d16:	eb 03                	jmp    800d1b <strnlen+0x13>
		n++;
  800d18:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d1b:	39 d0                	cmp    %edx,%eax
  800d1d:	74 06                	je     800d25 <strnlen+0x1d>
  800d1f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d23:	75 f3                	jne    800d18 <strnlen+0x10>
		n++;
	return n;
}
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	53                   	push   %ebx
  800d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d31:	89 c2                	mov    %eax,%edx
  800d33:	83 c2 01             	add    $0x1,%edx
  800d36:	83 c1 01             	add    $0x1,%ecx
  800d39:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d3d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d40:	84 db                	test   %bl,%bl
  800d42:	75 ef                	jne    800d33 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d44:	5b                   	pop    %ebx
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 08             	sub    $0x8,%esp
  800d4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d51:	89 1c 24             	mov    %ebx,(%esp)
  800d54:	e8 97 ff ff ff       	call   800cf0 <strlen>
	strcpy(dst + len, src);
  800d59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d60:	01 d8                	add    %ebx,%eax
  800d62:	89 04 24             	mov    %eax,(%esp)
  800d65:	e8 bd ff ff ff       	call   800d27 <strcpy>
	return dst;
}
  800d6a:	89 d8                	mov    %ebx,%eax
  800d6c:	83 c4 08             	add    $0x8,%esp
  800d6f:	5b                   	pop    %ebx
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	56                   	push   %esi
  800d76:	53                   	push   %ebx
  800d77:	8b 75 08             	mov    0x8(%ebp),%esi
  800d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7d:	89 f3                	mov    %esi,%ebx
  800d7f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d82:	89 f2                	mov    %esi,%edx
  800d84:	eb 0f                	jmp    800d95 <strncpy+0x23>
		*dst++ = *src;
  800d86:	83 c2 01             	add    $0x1,%edx
  800d89:	0f b6 01             	movzbl (%ecx),%eax
  800d8c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d8f:	80 39 01             	cmpb   $0x1,(%ecx)
  800d92:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d95:	39 da                	cmp    %ebx,%edx
  800d97:	75 ed                	jne    800d86 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d99:	89 f0                	mov    %esi,%eax
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	8b 75 08             	mov    0x8(%ebp),%esi
  800da7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800daa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800dad:	89 f0                	mov    %esi,%eax
  800daf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800db3:	85 c9                	test   %ecx,%ecx
  800db5:	75 0b                	jne    800dc2 <strlcpy+0x23>
  800db7:	eb 1d                	jmp    800dd6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800db9:	83 c0 01             	add    $0x1,%eax
  800dbc:	83 c2 01             	add    $0x1,%edx
  800dbf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800dc2:	39 d8                	cmp    %ebx,%eax
  800dc4:	74 0b                	je     800dd1 <strlcpy+0x32>
  800dc6:	0f b6 0a             	movzbl (%edx),%ecx
  800dc9:	84 c9                	test   %cl,%cl
  800dcb:	75 ec                	jne    800db9 <strlcpy+0x1a>
  800dcd:	89 c2                	mov    %eax,%edx
  800dcf:	eb 02                	jmp    800dd3 <strlcpy+0x34>
  800dd1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800dd3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800dd6:	29 f0                	sub    %esi,%eax
}
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800de5:	eb 06                	jmp    800ded <strcmp+0x11>
		p++, q++;
  800de7:	83 c1 01             	add    $0x1,%ecx
  800dea:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ded:	0f b6 01             	movzbl (%ecx),%eax
  800df0:	84 c0                	test   %al,%al
  800df2:	74 04                	je     800df8 <strcmp+0x1c>
  800df4:	3a 02                	cmp    (%edx),%al
  800df6:	74 ef                	je     800de7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800df8:	0f b6 c0             	movzbl %al,%eax
  800dfb:	0f b6 12             	movzbl (%edx),%edx
  800dfe:	29 d0                	sub    %edx,%eax
}
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	53                   	push   %ebx
  800e06:	8b 45 08             	mov    0x8(%ebp),%eax
  800e09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e0c:	89 c3                	mov    %eax,%ebx
  800e0e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e11:	eb 06                	jmp    800e19 <strncmp+0x17>
		n--, p++, q++;
  800e13:	83 c0 01             	add    $0x1,%eax
  800e16:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e19:	39 d8                	cmp    %ebx,%eax
  800e1b:	74 15                	je     800e32 <strncmp+0x30>
  800e1d:	0f b6 08             	movzbl (%eax),%ecx
  800e20:	84 c9                	test   %cl,%cl
  800e22:	74 04                	je     800e28 <strncmp+0x26>
  800e24:	3a 0a                	cmp    (%edx),%cl
  800e26:	74 eb                	je     800e13 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e28:	0f b6 00             	movzbl (%eax),%eax
  800e2b:	0f b6 12             	movzbl (%edx),%edx
  800e2e:	29 d0                	sub    %edx,%eax
  800e30:	eb 05                	jmp    800e37 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e32:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e37:	5b                   	pop    %ebx
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    

00800e3a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e40:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e44:	eb 07                	jmp    800e4d <strchr+0x13>
		if (*s == c)
  800e46:	38 ca                	cmp    %cl,%dl
  800e48:	74 0f                	je     800e59 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e4a:	83 c0 01             	add    $0x1,%eax
  800e4d:	0f b6 10             	movzbl (%eax),%edx
  800e50:	84 d2                	test   %dl,%dl
  800e52:	75 f2                	jne    800e46 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    

00800e5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e65:	eb 07                	jmp    800e6e <strfind+0x13>
		if (*s == c)
  800e67:	38 ca                	cmp    %cl,%dl
  800e69:	74 0a                	je     800e75 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e6b:	83 c0 01             	add    $0x1,%eax
  800e6e:	0f b6 10             	movzbl (%eax),%edx
  800e71:	84 d2                	test   %dl,%dl
  800e73:	75 f2                	jne    800e67 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	57                   	push   %edi
  800e7b:	56                   	push   %esi
  800e7c:	53                   	push   %ebx
  800e7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e80:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e83:	85 c9                	test   %ecx,%ecx
  800e85:	74 36                	je     800ebd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e87:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e8d:	75 28                	jne    800eb7 <memset+0x40>
  800e8f:	f6 c1 03             	test   $0x3,%cl
  800e92:	75 23                	jne    800eb7 <memset+0x40>
		c &= 0xFF;
  800e94:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e98:	89 d3                	mov    %edx,%ebx
  800e9a:	c1 e3 08             	shl    $0x8,%ebx
  800e9d:	89 d6                	mov    %edx,%esi
  800e9f:	c1 e6 18             	shl    $0x18,%esi
  800ea2:	89 d0                	mov    %edx,%eax
  800ea4:	c1 e0 10             	shl    $0x10,%eax
  800ea7:	09 f0                	or     %esi,%eax
  800ea9:	09 c2                	or     %eax,%edx
  800eab:	89 d0                	mov    %edx,%eax
  800ead:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800eaf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800eb2:	fc                   	cld    
  800eb3:	f3 ab                	rep stos %eax,%es:(%edi)
  800eb5:	eb 06                	jmp    800ebd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800eb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eba:	fc                   	cld    
  800ebb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ebd:	89 f8                	mov    %edi,%eax
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	57                   	push   %edi
  800ec8:	56                   	push   %esi
  800ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ecf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ed2:	39 c6                	cmp    %eax,%esi
  800ed4:	73 35                	jae    800f0b <memmove+0x47>
  800ed6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ed9:	39 d0                	cmp    %edx,%eax
  800edb:	73 2e                	jae    800f0b <memmove+0x47>
		s += n;
		d += n;
  800edd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ee0:	89 d6                	mov    %edx,%esi
  800ee2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ee4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800eea:	75 13                	jne    800eff <memmove+0x3b>
  800eec:	f6 c1 03             	test   $0x3,%cl
  800eef:	75 0e                	jne    800eff <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ef1:	83 ef 04             	sub    $0x4,%edi
  800ef4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ef7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800efa:	fd                   	std    
  800efb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800efd:	eb 09                	jmp    800f08 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800eff:	83 ef 01             	sub    $0x1,%edi
  800f02:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f05:	fd                   	std    
  800f06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f08:	fc                   	cld    
  800f09:	eb 1d                	jmp    800f28 <memmove+0x64>
  800f0b:	89 f2                	mov    %esi,%edx
  800f0d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f0f:	f6 c2 03             	test   $0x3,%dl
  800f12:	75 0f                	jne    800f23 <memmove+0x5f>
  800f14:	f6 c1 03             	test   $0x3,%cl
  800f17:	75 0a                	jne    800f23 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f19:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f1c:	89 c7                	mov    %eax,%edi
  800f1e:	fc                   	cld    
  800f1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f21:	eb 05                	jmp    800f28 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f23:	89 c7                	mov    %eax,%edi
  800f25:	fc                   	cld    
  800f26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f28:	5e                   	pop    %esi
  800f29:	5f                   	pop    %edi
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f32:	8b 45 10             	mov    0x10(%ebp),%eax
  800f35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f40:	8b 45 08             	mov    0x8(%ebp),%eax
  800f43:	89 04 24             	mov    %eax,(%esp)
  800f46:	e8 79 ff ff ff       	call   800ec4 <memmove>
}
  800f4b:	c9                   	leave  
  800f4c:	c3                   	ret    

00800f4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f4d:	55                   	push   %ebp
  800f4e:	89 e5                	mov    %esp,%ebp
  800f50:	56                   	push   %esi
  800f51:	53                   	push   %ebx
  800f52:	8b 55 08             	mov    0x8(%ebp),%edx
  800f55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f58:	89 d6                	mov    %edx,%esi
  800f5a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f5d:	eb 1a                	jmp    800f79 <memcmp+0x2c>
		if (*s1 != *s2)
  800f5f:	0f b6 02             	movzbl (%edx),%eax
  800f62:	0f b6 19             	movzbl (%ecx),%ebx
  800f65:	38 d8                	cmp    %bl,%al
  800f67:	74 0a                	je     800f73 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f69:	0f b6 c0             	movzbl %al,%eax
  800f6c:	0f b6 db             	movzbl %bl,%ebx
  800f6f:	29 d8                	sub    %ebx,%eax
  800f71:	eb 0f                	jmp    800f82 <memcmp+0x35>
		s1++, s2++;
  800f73:	83 c2 01             	add    $0x1,%edx
  800f76:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f79:	39 f2                	cmp    %esi,%edx
  800f7b:	75 e2                	jne    800f5f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f82:	5b                   	pop    %ebx
  800f83:	5e                   	pop    %esi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f8f:	89 c2                	mov    %eax,%edx
  800f91:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f94:	eb 07                	jmp    800f9d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f96:	38 08                	cmp    %cl,(%eax)
  800f98:	74 07                	je     800fa1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f9a:	83 c0 01             	add    $0x1,%eax
  800f9d:	39 d0                	cmp    %edx,%eax
  800f9f:	72 f5                	jb     800f96 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	57                   	push   %edi
  800fa7:	56                   	push   %esi
  800fa8:	53                   	push   %ebx
  800fa9:	8b 55 08             	mov    0x8(%ebp),%edx
  800fac:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800faf:	eb 03                	jmp    800fb4 <strtol+0x11>
		s++;
  800fb1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fb4:	0f b6 0a             	movzbl (%edx),%ecx
  800fb7:	80 f9 09             	cmp    $0x9,%cl
  800fba:	74 f5                	je     800fb1 <strtol+0xe>
  800fbc:	80 f9 20             	cmp    $0x20,%cl
  800fbf:	74 f0                	je     800fb1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fc1:	80 f9 2b             	cmp    $0x2b,%cl
  800fc4:	75 0a                	jne    800fd0 <strtol+0x2d>
		s++;
  800fc6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800fc9:	bf 00 00 00 00       	mov    $0x0,%edi
  800fce:	eb 11                	jmp    800fe1 <strtol+0x3e>
  800fd0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800fd5:	80 f9 2d             	cmp    $0x2d,%cl
  800fd8:	75 07                	jne    800fe1 <strtol+0x3e>
		s++, neg = 1;
  800fda:	8d 52 01             	lea    0x1(%edx),%edx
  800fdd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fe1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800fe6:	75 15                	jne    800ffd <strtol+0x5a>
  800fe8:	80 3a 30             	cmpb   $0x30,(%edx)
  800feb:	75 10                	jne    800ffd <strtol+0x5a>
  800fed:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ff1:	75 0a                	jne    800ffd <strtol+0x5a>
		s += 2, base = 16;
  800ff3:	83 c2 02             	add    $0x2,%edx
  800ff6:	b8 10 00 00 00       	mov    $0x10,%eax
  800ffb:	eb 10                	jmp    80100d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	75 0c                	jne    80100d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801001:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801003:	80 3a 30             	cmpb   $0x30,(%edx)
  801006:	75 05                	jne    80100d <strtol+0x6a>
		s++, base = 8;
  801008:	83 c2 01             	add    $0x1,%edx
  80100b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80100d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801012:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801015:	0f b6 0a             	movzbl (%edx),%ecx
  801018:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80101b:	89 f0                	mov    %esi,%eax
  80101d:	3c 09                	cmp    $0x9,%al
  80101f:	77 08                	ja     801029 <strtol+0x86>
			dig = *s - '0';
  801021:	0f be c9             	movsbl %cl,%ecx
  801024:	83 e9 30             	sub    $0x30,%ecx
  801027:	eb 20                	jmp    801049 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801029:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80102c:	89 f0                	mov    %esi,%eax
  80102e:	3c 19                	cmp    $0x19,%al
  801030:	77 08                	ja     80103a <strtol+0x97>
			dig = *s - 'a' + 10;
  801032:	0f be c9             	movsbl %cl,%ecx
  801035:	83 e9 57             	sub    $0x57,%ecx
  801038:	eb 0f                	jmp    801049 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80103a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80103d:	89 f0                	mov    %esi,%eax
  80103f:	3c 19                	cmp    $0x19,%al
  801041:	77 16                	ja     801059 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801043:	0f be c9             	movsbl %cl,%ecx
  801046:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801049:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80104c:	7d 0f                	jge    80105d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80104e:	83 c2 01             	add    $0x1,%edx
  801051:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801055:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801057:	eb bc                	jmp    801015 <strtol+0x72>
  801059:	89 d8                	mov    %ebx,%eax
  80105b:	eb 02                	jmp    80105f <strtol+0xbc>
  80105d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80105f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801063:	74 05                	je     80106a <strtol+0xc7>
		*endptr = (char *) s;
  801065:	8b 75 0c             	mov    0xc(%ebp),%esi
  801068:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80106a:	f7 d8                	neg    %eax
  80106c:	85 ff                	test   %edi,%edi
  80106e:	0f 44 c3             	cmove  %ebx,%eax
}
  801071:	5b                   	pop    %ebx
  801072:	5e                   	pop    %esi
  801073:	5f                   	pop    %edi
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    

00801076 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	57                   	push   %edi
  80107a:	56                   	push   %esi
  80107b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107c:	b8 00 00 00 00       	mov    $0x0,%eax
  801081:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801084:	8b 55 08             	mov    0x8(%ebp),%edx
  801087:	89 c3                	mov    %eax,%ebx
  801089:	89 c7                	mov    %eax,%edi
  80108b:	89 c6                	mov    %eax,%esi
  80108d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5f                   	pop    %edi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <sys_cgetc>:

int
sys_cgetc(void)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	57                   	push   %edi
  801098:	56                   	push   %esi
  801099:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109a:	ba 00 00 00 00       	mov    $0x0,%edx
  80109f:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a4:	89 d1                	mov    %edx,%ecx
  8010a6:	89 d3                	mov    %edx,%ebx
  8010a8:	89 d7                	mov    %edx,%edi
  8010aa:	89 d6                	mov    %edx,%esi
  8010ac:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010ae:	5b                   	pop    %ebx
  8010af:	5e                   	pop    %esi
  8010b0:	5f                   	pop    %edi
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	57                   	push   %edi
  8010b7:	56                   	push   %esi
  8010b8:	53                   	push   %ebx
  8010b9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c1:	b8 03 00 00 00       	mov    $0x3,%eax
  8010c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c9:	89 cb                	mov    %ecx,%ebx
  8010cb:	89 cf                	mov    %ecx,%edi
  8010cd:	89 ce                	mov    %ecx,%esi
  8010cf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	7e 28                	jle    8010fd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010d9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010e0:	00 
  8010e1:	c7 44 24 08 c8 19 80 	movl   $0x8019c8,0x8(%esp)
  8010e8:	00 
  8010e9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010f0:	00 
  8010f1:	c7 04 24 e5 19 80 00 	movl   $0x8019e5,(%esp)
  8010f8:	e8 0a f5 ff ff       	call   800607 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010fd:	83 c4 2c             	add    $0x2c,%esp
  801100:	5b                   	pop    %ebx
  801101:	5e                   	pop    %esi
  801102:	5f                   	pop    %edi
  801103:	5d                   	pop    %ebp
  801104:	c3                   	ret    

00801105 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	57                   	push   %edi
  801109:	56                   	push   %esi
  80110a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80110b:	ba 00 00 00 00       	mov    $0x0,%edx
  801110:	b8 02 00 00 00       	mov    $0x2,%eax
  801115:	89 d1                	mov    %edx,%ecx
  801117:	89 d3                	mov    %edx,%ebx
  801119:	89 d7                	mov    %edx,%edi
  80111b:	89 d6                	mov    %edx,%esi
  80111d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80111f:	5b                   	pop    %ebx
  801120:	5e                   	pop    %esi
  801121:	5f                   	pop    %edi
  801122:	5d                   	pop    %ebp
  801123:	c3                   	ret    

00801124 <sys_yield>:

void
sys_yield(void)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	57                   	push   %edi
  801128:	56                   	push   %esi
  801129:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80112a:	ba 00 00 00 00       	mov    $0x0,%edx
  80112f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801134:	89 d1                	mov    %edx,%ecx
  801136:	89 d3                	mov    %edx,%ebx
  801138:	89 d7                	mov    %edx,%edi
  80113a:	89 d6                	mov    %edx,%esi
  80113c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80113e:	5b                   	pop    %ebx
  80113f:	5e                   	pop    %esi
  801140:	5f                   	pop    %edi
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80114c:	be 00 00 00 00       	mov    $0x0,%esi
  801151:	b8 04 00 00 00       	mov    $0x4,%eax
  801156:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801159:	8b 55 08             	mov    0x8(%ebp),%edx
  80115c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80115f:	89 f7                	mov    %esi,%edi
  801161:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801163:	85 c0                	test   %eax,%eax
  801165:	7e 28                	jle    80118f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801167:	89 44 24 10          	mov    %eax,0x10(%esp)
  80116b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801172:	00 
  801173:	c7 44 24 08 c8 19 80 	movl   $0x8019c8,0x8(%esp)
  80117a:	00 
  80117b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801182:	00 
  801183:	c7 04 24 e5 19 80 00 	movl   $0x8019e5,(%esp)
  80118a:	e8 78 f4 ff ff       	call   800607 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80118f:	83 c4 2c             	add    $0x2c,%esp
  801192:	5b                   	pop    %ebx
  801193:	5e                   	pop    %esi
  801194:	5f                   	pop    %edi
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    

00801197 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	57                   	push   %edi
  80119b:	56                   	push   %esi
  80119c:	53                   	push   %ebx
  80119d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8011a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011ae:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011b1:	8b 75 18             	mov    0x18(%ebp),%esi
  8011b4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	7e 28                	jle    8011e2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011be:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8011c5:	00 
  8011c6:	c7 44 24 08 c8 19 80 	movl   $0x8019c8,0x8(%esp)
  8011cd:	00 
  8011ce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011d5:	00 
  8011d6:	c7 04 24 e5 19 80 00 	movl   $0x8019e5,(%esp)
  8011dd:	e8 25 f4 ff ff       	call   800607 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011e2:	83 c4 2c             	add    $0x2c,%esp
  8011e5:	5b                   	pop    %ebx
  8011e6:	5e                   	pop    %esi
  8011e7:	5f                   	pop    %edi
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    

008011ea <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	57                   	push   %edi
  8011ee:	56                   	push   %esi
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f8:	b8 06 00 00 00       	mov    $0x6,%eax
  8011fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801200:	8b 55 08             	mov    0x8(%ebp),%edx
  801203:	89 df                	mov    %ebx,%edi
  801205:	89 de                	mov    %ebx,%esi
  801207:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801209:	85 c0                	test   %eax,%eax
  80120b:	7e 28                	jle    801235 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80120d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801211:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801218:	00 
  801219:	c7 44 24 08 c8 19 80 	movl   $0x8019c8,0x8(%esp)
  801220:	00 
  801221:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801228:	00 
  801229:	c7 04 24 e5 19 80 00 	movl   $0x8019e5,(%esp)
  801230:	e8 d2 f3 ff ff       	call   800607 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801235:	83 c4 2c             	add    $0x2c,%esp
  801238:	5b                   	pop    %ebx
  801239:	5e                   	pop    %esi
  80123a:	5f                   	pop    %edi
  80123b:	5d                   	pop    %ebp
  80123c:	c3                   	ret    

0080123d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	57                   	push   %edi
  801241:	56                   	push   %esi
  801242:	53                   	push   %ebx
  801243:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801246:	bb 00 00 00 00       	mov    $0x0,%ebx
  80124b:	b8 08 00 00 00       	mov    $0x8,%eax
  801250:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801253:	8b 55 08             	mov    0x8(%ebp),%edx
  801256:	89 df                	mov    %ebx,%edi
  801258:	89 de                	mov    %ebx,%esi
  80125a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80125c:	85 c0                	test   %eax,%eax
  80125e:	7e 28                	jle    801288 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801260:	89 44 24 10          	mov    %eax,0x10(%esp)
  801264:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80126b:	00 
  80126c:	c7 44 24 08 c8 19 80 	movl   $0x8019c8,0x8(%esp)
  801273:	00 
  801274:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80127b:	00 
  80127c:	c7 04 24 e5 19 80 00 	movl   $0x8019e5,(%esp)
  801283:	e8 7f f3 ff ff       	call   800607 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801288:	83 c4 2c             	add    $0x2c,%esp
  80128b:	5b                   	pop    %ebx
  80128c:	5e                   	pop    %esi
  80128d:	5f                   	pop    %edi
  80128e:	5d                   	pop    %ebp
  80128f:	c3                   	ret    

00801290 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	57                   	push   %edi
  801294:	56                   	push   %esi
  801295:	53                   	push   %ebx
  801296:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801299:	bb 00 00 00 00       	mov    $0x0,%ebx
  80129e:	b8 09 00 00 00       	mov    $0x9,%eax
  8012a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a9:	89 df                	mov    %ebx,%edi
  8012ab:	89 de                	mov    %ebx,%esi
  8012ad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	7e 28                	jle    8012db <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012b3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012be:	00 
  8012bf:	c7 44 24 08 c8 19 80 	movl   $0x8019c8,0x8(%esp)
  8012c6:	00 
  8012c7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012ce:	00 
  8012cf:	c7 04 24 e5 19 80 00 	movl   $0x8019e5,(%esp)
  8012d6:	e8 2c f3 ff ff       	call   800607 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012db:	83 c4 2c             	add    $0x2c,%esp
  8012de:	5b                   	pop    %ebx
  8012df:	5e                   	pop    %esi
  8012e0:	5f                   	pop    %edi
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    

008012e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	57                   	push   %edi
  8012e7:	56                   	push   %esi
  8012e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012e9:	be 00 00 00 00       	mov    $0x0,%esi
  8012ee:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012ff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801301:	5b                   	pop    %ebx
  801302:	5e                   	pop    %esi
  801303:	5f                   	pop    %edi
  801304:	5d                   	pop    %ebp
  801305:	c3                   	ret    

00801306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801306:	55                   	push   %ebp
  801307:	89 e5                	mov    %esp,%ebp
  801309:	57                   	push   %edi
  80130a:	56                   	push   %esi
  80130b:	53                   	push   %ebx
  80130c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80130f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801314:	b8 0c 00 00 00       	mov    $0xc,%eax
  801319:	8b 55 08             	mov    0x8(%ebp),%edx
  80131c:	89 cb                	mov    %ecx,%ebx
  80131e:	89 cf                	mov    %ecx,%edi
  801320:	89 ce                	mov    %ecx,%esi
  801322:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801324:	85 c0                	test   %eax,%eax
  801326:	7e 28                	jle    801350 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801328:	89 44 24 10          	mov    %eax,0x10(%esp)
  80132c:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801333:	00 
  801334:	c7 44 24 08 c8 19 80 	movl   $0x8019c8,0x8(%esp)
  80133b:	00 
  80133c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801343:	00 
  801344:	c7 04 24 e5 19 80 00 	movl   $0x8019e5,(%esp)
  80134b:	e8 b7 f2 ff ff       	call   800607 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801350:	83 c4 2c             	add    $0x2c,%esp
  801353:	5b                   	pop    %ebx
  801354:	5e                   	pop    %esi
  801355:	5f                   	pop    %edi
  801356:	5d                   	pop    %ebp
  801357:	c3                   	ret    

00801358 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80135e:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  801365:	75 1c                	jne    801383 <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  801367:	c7 44 24 08 f4 19 80 	movl   $0x8019f4,0x8(%esp)
  80136e:	00 
  80136f:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801376:	00 
  801377:	c7 04 24 18 1a 80 00 	movl   $0x801a18,(%esp)
  80137e:	e8 84 f2 ff ff       	call   800607 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801383:	8b 45 08             	mov    0x8(%ebp),%eax
  801386:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  80138b:	c9                   	leave  
  80138c:	c3                   	ret    
  80138d:	66 90                	xchg   %ax,%ax
  80138f:	90                   	nop

00801390 <__udivdi3>:
  801390:	55                   	push   %ebp
  801391:	57                   	push   %edi
  801392:	56                   	push   %esi
  801393:	83 ec 0c             	sub    $0xc,%esp
  801396:	8b 44 24 28          	mov    0x28(%esp),%eax
  80139a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80139e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8013a2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8013ac:	89 ea                	mov    %ebp,%edx
  8013ae:	89 0c 24             	mov    %ecx,(%esp)
  8013b1:	75 2d                	jne    8013e0 <__udivdi3+0x50>
  8013b3:	39 e9                	cmp    %ebp,%ecx
  8013b5:	77 61                	ja     801418 <__udivdi3+0x88>
  8013b7:	85 c9                	test   %ecx,%ecx
  8013b9:	89 ce                	mov    %ecx,%esi
  8013bb:	75 0b                	jne    8013c8 <__udivdi3+0x38>
  8013bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8013c2:	31 d2                	xor    %edx,%edx
  8013c4:	f7 f1                	div    %ecx
  8013c6:	89 c6                	mov    %eax,%esi
  8013c8:	31 d2                	xor    %edx,%edx
  8013ca:	89 e8                	mov    %ebp,%eax
  8013cc:	f7 f6                	div    %esi
  8013ce:	89 c5                	mov    %eax,%ebp
  8013d0:	89 f8                	mov    %edi,%eax
  8013d2:	f7 f6                	div    %esi
  8013d4:	89 ea                	mov    %ebp,%edx
  8013d6:	83 c4 0c             	add    $0xc,%esp
  8013d9:	5e                   	pop    %esi
  8013da:	5f                   	pop    %edi
  8013db:	5d                   	pop    %ebp
  8013dc:	c3                   	ret    
  8013dd:	8d 76 00             	lea    0x0(%esi),%esi
  8013e0:	39 e8                	cmp    %ebp,%eax
  8013e2:	77 24                	ja     801408 <__udivdi3+0x78>
  8013e4:	0f bd e8             	bsr    %eax,%ebp
  8013e7:	83 f5 1f             	xor    $0x1f,%ebp
  8013ea:	75 3c                	jne    801428 <__udivdi3+0x98>
  8013ec:	8b 74 24 04          	mov    0x4(%esp),%esi
  8013f0:	39 34 24             	cmp    %esi,(%esp)
  8013f3:	0f 86 9f 00 00 00    	jbe    801498 <__udivdi3+0x108>
  8013f9:	39 d0                	cmp    %edx,%eax
  8013fb:	0f 82 97 00 00 00    	jb     801498 <__udivdi3+0x108>
  801401:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801408:	31 d2                	xor    %edx,%edx
  80140a:	31 c0                	xor    %eax,%eax
  80140c:	83 c4 0c             	add    $0xc,%esp
  80140f:	5e                   	pop    %esi
  801410:	5f                   	pop    %edi
  801411:	5d                   	pop    %ebp
  801412:	c3                   	ret    
  801413:	90                   	nop
  801414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801418:	89 f8                	mov    %edi,%eax
  80141a:	f7 f1                	div    %ecx
  80141c:	31 d2                	xor    %edx,%edx
  80141e:	83 c4 0c             	add    $0xc,%esp
  801421:	5e                   	pop    %esi
  801422:	5f                   	pop    %edi
  801423:	5d                   	pop    %ebp
  801424:	c3                   	ret    
  801425:	8d 76 00             	lea    0x0(%esi),%esi
  801428:	89 e9                	mov    %ebp,%ecx
  80142a:	8b 3c 24             	mov    (%esp),%edi
  80142d:	d3 e0                	shl    %cl,%eax
  80142f:	89 c6                	mov    %eax,%esi
  801431:	b8 20 00 00 00       	mov    $0x20,%eax
  801436:	29 e8                	sub    %ebp,%eax
  801438:	89 c1                	mov    %eax,%ecx
  80143a:	d3 ef                	shr    %cl,%edi
  80143c:	89 e9                	mov    %ebp,%ecx
  80143e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801442:	8b 3c 24             	mov    (%esp),%edi
  801445:	09 74 24 08          	or     %esi,0x8(%esp)
  801449:	89 d6                	mov    %edx,%esi
  80144b:	d3 e7                	shl    %cl,%edi
  80144d:	89 c1                	mov    %eax,%ecx
  80144f:	89 3c 24             	mov    %edi,(%esp)
  801452:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801456:	d3 ee                	shr    %cl,%esi
  801458:	89 e9                	mov    %ebp,%ecx
  80145a:	d3 e2                	shl    %cl,%edx
  80145c:	89 c1                	mov    %eax,%ecx
  80145e:	d3 ef                	shr    %cl,%edi
  801460:	09 d7                	or     %edx,%edi
  801462:	89 f2                	mov    %esi,%edx
  801464:	89 f8                	mov    %edi,%eax
  801466:	f7 74 24 08          	divl   0x8(%esp)
  80146a:	89 d6                	mov    %edx,%esi
  80146c:	89 c7                	mov    %eax,%edi
  80146e:	f7 24 24             	mull   (%esp)
  801471:	39 d6                	cmp    %edx,%esi
  801473:	89 14 24             	mov    %edx,(%esp)
  801476:	72 30                	jb     8014a8 <__udivdi3+0x118>
  801478:	8b 54 24 04          	mov    0x4(%esp),%edx
  80147c:	89 e9                	mov    %ebp,%ecx
  80147e:	d3 e2                	shl    %cl,%edx
  801480:	39 c2                	cmp    %eax,%edx
  801482:	73 05                	jae    801489 <__udivdi3+0xf9>
  801484:	3b 34 24             	cmp    (%esp),%esi
  801487:	74 1f                	je     8014a8 <__udivdi3+0x118>
  801489:	89 f8                	mov    %edi,%eax
  80148b:	31 d2                	xor    %edx,%edx
  80148d:	e9 7a ff ff ff       	jmp    80140c <__udivdi3+0x7c>
  801492:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801498:	31 d2                	xor    %edx,%edx
  80149a:	b8 01 00 00 00       	mov    $0x1,%eax
  80149f:	e9 68 ff ff ff       	jmp    80140c <__udivdi3+0x7c>
  8014a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014a8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8014ab:	31 d2                	xor    %edx,%edx
  8014ad:	83 c4 0c             	add    $0xc,%esp
  8014b0:	5e                   	pop    %esi
  8014b1:	5f                   	pop    %edi
  8014b2:	5d                   	pop    %ebp
  8014b3:	c3                   	ret    
  8014b4:	66 90                	xchg   %ax,%ax
  8014b6:	66 90                	xchg   %ax,%ax
  8014b8:	66 90                	xchg   %ax,%ax
  8014ba:	66 90                	xchg   %ax,%ax
  8014bc:	66 90                	xchg   %ax,%ax
  8014be:	66 90                	xchg   %ax,%ax

008014c0 <__umoddi3>:
  8014c0:	55                   	push   %ebp
  8014c1:	57                   	push   %edi
  8014c2:	56                   	push   %esi
  8014c3:	83 ec 14             	sub    $0x14,%esp
  8014c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8014ca:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8014ce:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8014d2:	89 c7                	mov    %eax,%edi
  8014d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8014dc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8014e0:	89 34 24             	mov    %esi,(%esp)
  8014e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	89 c2                	mov    %eax,%edx
  8014eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8014ef:	75 17                	jne    801508 <__umoddi3+0x48>
  8014f1:	39 fe                	cmp    %edi,%esi
  8014f3:	76 4b                	jbe    801540 <__umoddi3+0x80>
  8014f5:	89 c8                	mov    %ecx,%eax
  8014f7:	89 fa                	mov    %edi,%edx
  8014f9:	f7 f6                	div    %esi
  8014fb:	89 d0                	mov    %edx,%eax
  8014fd:	31 d2                	xor    %edx,%edx
  8014ff:	83 c4 14             	add    $0x14,%esp
  801502:	5e                   	pop    %esi
  801503:	5f                   	pop    %edi
  801504:	5d                   	pop    %ebp
  801505:	c3                   	ret    
  801506:	66 90                	xchg   %ax,%ax
  801508:	39 f8                	cmp    %edi,%eax
  80150a:	77 54                	ja     801560 <__umoddi3+0xa0>
  80150c:	0f bd e8             	bsr    %eax,%ebp
  80150f:	83 f5 1f             	xor    $0x1f,%ebp
  801512:	75 5c                	jne    801570 <__umoddi3+0xb0>
  801514:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801518:	39 3c 24             	cmp    %edi,(%esp)
  80151b:	0f 87 e7 00 00 00    	ja     801608 <__umoddi3+0x148>
  801521:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801525:	29 f1                	sub    %esi,%ecx
  801527:	19 c7                	sbb    %eax,%edi
  801529:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80152d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801531:	8b 44 24 08          	mov    0x8(%esp),%eax
  801535:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801539:	83 c4 14             	add    $0x14,%esp
  80153c:	5e                   	pop    %esi
  80153d:	5f                   	pop    %edi
  80153e:	5d                   	pop    %ebp
  80153f:	c3                   	ret    
  801540:	85 f6                	test   %esi,%esi
  801542:	89 f5                	mov    %esi,%ebp
  801544:	75 0b                	jne    801551 <__umoddi3+0x91>
  801546:	b8 01 00 00 00       	mov    $0x1,%eax
  80154b:	31 d2                	xor    %edx,%edx
  80154d:	f7 f6                	div    %esi
  80154f:	89 c5                	mov    %eax,%ebp
  801551:	8b 44 24 04          	mov    0x4(%esp),%eax
  801555:	31 d2                	xor    %edx,%edx
  801557:	f7 f5                	div    %ebp
  801559:	89 c8                	mov    %ecx,%eax
  80155b:	f7 f5                	div    %ebp
  80155d:	eb 9c                	jmp    8014fb <__umoddi3+0x3b>
  80155f:	90                   	nop
  801560:	89 c8                	mov    %ecx,%eax
  801562:	89 fa                	mov    %edi,%edx
  801564:	83 c4 14             	add    $0x14,%esp
  801567:	5e                   	pop    %esi
  801568:	5f                   	pop    %edi
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    
  80156b:	90                   	nop
  80156c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801570:	8b 04 24             	mov    (%esp),%eax
  801573:	be 20 00 00 00       	mov    $0x20,%esi
  801578:	89 e9                	mov    %ebp,%ecx
  80157a:	29 ee                	sub    %ebp,%esi
  80157c:	d3 e2                	shl    %cl,%edx
  80157e:	89 f1                	mov    %esi,%ecx
  801580:	d3 e8                	shr    %cl,%eax
  801582:	89 e9                	mov    %ebp,%ecx
  801584:	89 44 24 04          	mov    %eax,0x4(%esp)
  801588:	8b 04 24             	mov    (%esp),%eax
  80158b:	09 54 24 04          	or     %edx,0x4(%esp)
  80158f:	89 fa                	mov    %edi,%edx
  801591:	d3 e0                	shl    %cl,%eax
  801593:	89 f1                	mov    %esi,%ecx
  801595:	89 44 24 08          	mov    %eax,0x8(%esp)
  801599:	8b 44 24 10          	mov    0x10(%esp),%eax
  80159d:	d3 ea                	shr    %cl,%edx
  80159f:	89 e9                	mov    %ebp,%ecx
  8015a1:	d3 e7                	shl    %cl,%edi
  8015a3:	89 f1                	mov    %esi,%ecx
  8015a5:	d3 e8                	shr    %cl,%eax
  8015a7:	89 e9                	mov    %ebp,%ecx
  8015a9:	09 f8                	or     %edi,%eax
  8015ab:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8015af:	f7 74 24 04          	divl   0x4(%esp)
  8015b3:	d3 e7                	shl    %cl,%edi
  8015b5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015b9:	89 d7                	mov    %edx,%edi
  8015bb:	f7 64 24 08          	mull   0x8(%esp)
  8015bf:	39 d7                	cmp    %edx,%edi
  8015c1:	89 c1                	mov    %eax,%ecx
  8015c3:	89 14 24             	mov    %edx,(%esp)
  8015c6:	72 2c                	jb     8015f4 <__umoddi3+0x134>
  8015c8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8015cc:	72 22                	jb     8015f0 <__umoddi3+0x130>
  8015ce:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8015d2:	29 c8                	sub    %ecx,%eax
  8015d4:	19 d7                	sbb    %edx,%edi
  8015d6:	89 e9                	mov    %ebp,%ecx
  8015d8:	89 fa                	mov    %edi,%edx
  8015da:	d3 e8                	shr    %cl,%eax
  8015dc:	89 f1                	mov    %esi,%ecx
  8015de:	d3 e2                	shl    %cl,%edx
  8015e0:	89 e9                	mov    %ebp,%ecx
  8015e2:	d3 ef                	shr    %cl,%edi
  8015e4:	09 d0                	or     %edx,%eax
  8015e6:	89 fa                	mov    %edi,%edx
  8015e8:	83 c4 14             	add    $0x14,%esp
  8015eb:	5e                   	pop    %esi
  8015ec:	5f                   	pop    %edi
  8015ed:	5d                   	pop    %ebp
  8015ee:	c3                   	ret    
  8015ef:	90                   	nop
  8015f0:	39 d7                	cmp    %edx,%edi
  8015f2:	75 da                	jne    8015ce <__umoddi3+0x10e>
  8015f4:	8b 14 24             	mov    (%esp),%edx
  8015f7:	89 c1                	mov    %eax,%ecx
  8015f9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8015fd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801601:	eb cb                	jmp    8015ce <__umoddi3+0x10e>
  801603:	90                   	nop
  801604:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801608:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80160c:	0f 82 0f ff ff ff    	jb     801521 <__umoddi3+0x61>
  801612:	e9 1a ff ff ff       	jmp    801531 <__umoddi3+0x71>
