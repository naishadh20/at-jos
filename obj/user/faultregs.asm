
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
  80002c:	e8 60 05 00 00       	call   800591 <libmain>
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
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 51 15 80 00       	push   $0x801551
  800049:	68 20 15 80 00       	push   $0x801520
  80004e:	e8 79 06 00 00       	call   8006cc <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 30 15 80 00       	push   $0x801530
  80005c:	68 34 15 80 00       	push   $0x801534
  800061:	e8 66 06 00 00       	call   8006cc <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 44 15 80 00       	push   $0x801544
  800077:	e8 50 06 00 00       	call   8006cc <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 48 15 80 00       	push   $0x801548
  80008e:	e8 39 06 00 00       	call   8006cc <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 52 15 80 00       	push   $0x801552
  8000a6:	68 34 15 80 00       	push   $0x801534
  8000ab:	e8 1c 06 00 00       	call   8006cc <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 44 15 80 00       	push   $0x801544
  8000c3:	e8 04 06 00 00       	call   8006cc <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 48 15 80 00       	push   $0x801548
  8000d5:	e8 f2 05 00 00       	call   8006cc <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 56 15 80 00       	push   $0x801556
  8000ed:	68 34 15 80 00       	push   $0x801534
  8000f2:	e8 d5 05 00 00       	call   8006cc <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 44 15 80 00       	push   $0x801544
  80010a:	e8 bd 05 00 00       	call   8006cc <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 48 15 80 00       	push   $0x801548
  80011c:	e8 ab 05 00 00       	call   8006cc <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 5a 15 80 00       	push   $0x80155a
  800134:	68 34 15 80 00       	push   $0x801534
  800139:	e8 8e 05 00 00       	call   8006cc <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 44 15 80 00       	push   $0x801544
  800151:	e8 76 05 00 00       	call   8006cc <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 48 15 80 00       	push   $0x801548
  800163:	e8 64 05 00 00       	call   8006cc <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 5e 15 80 00       	push   $0x80155e
  80017b:	68 34 15 80 00       	push   $0x801534
  800180:	e8 47 05 00 00       	call   8006cc <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 44 15 80 00       	push   $0x801544
  800198:	e8 2f 05 00 00       	call   8006cc <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 48 15 80 00       	push   $0x801548
  8001aa:	e8 1d 05 00 00       	call   8006cc <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 62 15 80 00       	push   $0x801562
  8001c2:	68 34 15 80 00       	push   $0x801534
  8001c7:	e8 00 05 00 00       	call   8006cc <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 44 15 80 00       	push   $0x801544
  8001df:	e8 e8 04 00 00       	call   8006cc <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 48 15 80 00       	push   $0x801548
  8001f1:	e8 d6 04 00 00       	call   8006cc <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 66 15 80 00       	push   $0x801566
  800209:	68 34 15 80 00       	push   $0x801534
  80020e:	e8 b9 04 00 00       	call   8006cc <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 44 15 80 00       	push   $0x801544
  800226:	e8 a1 04 00 00       	call   8006cc <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 48 15 80 00       	push   $0x801548
  800238:	e8 8f 04 00 00       	call   8006cc <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 6a 15 80 00       	push   $0x80156a
  800250:	68 34 15 80 00       	push   $0x801534
  800255:	e8 72 04 00 00       	call   8006cc <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 44 15 80 00       	push   $0x801544
  80026d:	e8 5a 04 00 00       	call   8006cc <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 48 15 80 00       	push   $0x801548
  80027f:	e8 48 04 00 00       	call   8006cc <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 6e 15 80 00       	push   $0x80156e
  800297:	68 34 15 80 00       	push   $0x801534
  80029c:	e8 2b 04 00 00       	call   8006cc <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 44 15 80 00       	push   $0x801544
  8002b4:	e8 13 04 00 00       	call   8006cc <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 75 15 80 00       	push   $0x801575
  8002c4:	68 34 15 80 00       	push   $0x801534
  8002c9:	e8 fe 03 00 00       	call   8006cc <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 48 15 80 00       	push   $0x801548
  8002e3:	e8 e4 03 00 00       	call   8006cc <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 75 15 80 00       	push   $0x801575
  8002f3:	68 34 15 80 00       	push   $0x801534
  8002f8:	e8 cf 03 00 00       	call   8006cc <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 44 15 80 00       	push   $0x801544
  800312:	e8 b5 03 00 00       	call   8006cc <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 79 15 80 00       	push   $0x801579
  800322:	e8 a5 03 00 00       	call   8006cc <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 48 15 80 00       	push   $0x801548
  800338:	e8 8f 03 00 00       	call   8006cc <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 79 15 80 00       	push   $0x801579
  800348:	e8 7f 03 00 00       	call   8006cc <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 44 15 80 00       	push   $0x801544
  80035a:	e8 6d 03 00 00       	call   8006cc <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 48 15 80 00       	push   $0x801548
  80036c:	e8 5b 03 00 00       	call   8006cc <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 44 15 80 00       	push   $0x801544
  80037e:	e8 49 03 00 00       	call   8006cc <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 79 15 80 00       	push   $0x801579
  80038e:	e8 39 03 00 00       	call   8006cc <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 e0 15 80 00       	push   $0x8015e0
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 87 15 80 00       	push   $0x801587
  8003c6:	e8 28 02 00 00       	call   8005f3 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 60 20 80 00    	mov    %edx,0x802060
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 64 20 80 00    	mov    %edx,0x802064
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 68 20 80 00    	mov    %edx,0x802068
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 70 20 80 00    	mov    %edx,0x802070
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 74 20 80 00    	mov    %edx,0x802074
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 78 20 80 00    	mov    %edx,0x802078
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  800425:	8b 40 30             	mov    0x30(%eax),%eax
  800428:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	68 9f 15 80 00       	push   $0x80159f
  800435:	68 ad 15 80 00       	push   $0x8015ad
  80043a:	b9 60 20 80 00       	mov    $0x802060,%ecx
  80043f:	ba 98 15 80 00       	mov    $0x801598,%edx
  800444:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  800449:	e8 e5 fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80044e:	83 c4 0c             	add    $0xc,%esp
  800451:	6a 07                	push   $0x7
  800453:	68 00 00 40 00       	push   $0x400000
  800458:	6a 00                	push   $0x0
  80045a:	e8 37 0c 00 00       	call   801096 <sys_page_alloc>
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	85 c0                	test   %eax,%eax
  800464:	79 12                	jns    800478 <pgfault+0xd8>
		panic("sys_page_alloc: %e", r);
  800466:	50                   	push   %eax
  800467:	68 b4 15 80 00       	push   $0x8015b4
  80046c:	6a 5c                	push   $0x5c
  80046e:	68 87 15 80 00       	push   $0x801587
  800473:	e8 7b 01 00 00       	call   8005f3 <_panic>
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <umain>:

void
umain(int argc, char **argv)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800480:	68 a0 03 80 00       	push   $0x8003a0
  800485:	e8 bb 0d 00 00       	call   801245 <set_pgfault_handler>

	__asm __volatile(
  80048a:	50                   	push   %eax
  80048b:	9c                   	pushf  
  80048c:	58                   	pop    %eax
  80048d:	0d d5 08 00 00       	or     $0x8d5,%eax
  800492:	50                   	push   %eax
  800493:	9d                   	popf   
  800494:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  800499:	8d 05 d4 04 80 00    	lea    0x8004d4,%eax
  80049f:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004a4:	58                   	pop    %eax
  8004a5:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8004ab:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8004b1:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  8004b7:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  8004bd:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8004c3:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  8004c9:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  8004ce:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  8004d4:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004db:	00 00 00 
  8004de:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8004e4:	89 35 24 20 80 00    	mov    %esi,0x802024
  8004ea:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8004f0:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  8004f6:	89 15 34 20 80 00    	mov    %edx,0x802034
  8004fc:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800502:	a3 3c 20 80 00       	mov    %eax,0x80203c
  800507:	89 25 48 20 80 00    	mov    %esp,0x802048
  80050d:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  800513:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  800519:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  80051f:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  800525:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  80052b:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  800531:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  800536:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  80053c:	50                   	push   %eax
  80053d:	9c                   	pushf  
  80053e:	58                   	pop    %eax
  80053f:	a3 44 20 80 00       	mov    %eax,0x802044
  800544:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80054f:	74 10                	je     800561 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	68 14 16 80 00       	push   $0x801614
  800559:	e8 6e 01 00 00       	call   8006cc <cprintf>
  80055e:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800561:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  800566:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	68 c7 15 80 00       	push   $0x8015c7
  800573:	68 d8 15 80 00       	push   $0x8015d8
  800578:	b9 20 20 80 00       	mov    $0x802020,%ecx
  80057d:	ba 98 15 80 00       	mov    $0x801598,%edx
  800582:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  800587:	e8 a7 fa ff ff       	call   800033 <check_regs>
}
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	c9                   	leave  
  800590:	c3                   	ret    

00800591 <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	56                   	push   %esi
  800595:	53                   	push   %ebx
  800596:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800599:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80059c:	c7 05 cc 20 80 00 00 	movl   $0x0,0x8020cc
  8005a3:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  8005a6:	e8 ad 0a 00 00       	call   801058 <sys_getenvid>
  8005ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005b0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005b8:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005bd:	85 db                	test   %ebx,%ebx
  8005bf:	7e 07                	jle    8005c8 <libmain+0x37>
		binaryname = argv[0];
  8005c1:	8b 06                	mov    (%esi),%eax
  8005c3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	56                   	push   %esi
  8005cc:	53                   	push   %ebx
  8005cd:	e8 a8 fe ff ff       	call   80047a <umain>

	// exit gracefully
	exit();
  8005d2:	e8 0a 00 00 00       	call   8005e1 <exit>
}
  8005d7:	83 c4 10             	add    $0x10,%esp
  8005da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005dd:	5b                   	pop    %ebx
  8005de:	5e                   	pop    %esi
  8005df:	5d                   	pop    %ebp
  8005e0:	c3                   	ret    

008005e1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005e1:	55                   	push   %ebp
  8005e2:	89 e5                	mov    %esp,%ebp
  8005e4:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8005e7:	6a 00                	push   $0x0
  8005e9:	e8 29 0a 00 00       	call   801017 <sys_env_destroy>
}
  8005ee:	83 c4 10             	add    $0x10,%esp
  8005f1:	c9                   	leave  
  8005f2:	c3                   	ret    

008005f3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f3:	55                   	push   %ebp
  8005f4:	89 e5                	mov    %esp,%ebp
  8005f6:	56                   	push   %esi
  8005f7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005f8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005fb:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800601:	e8 52 0a 00 00       	call   801058 <sys_getenvid>
  800606:	83 ec 0c             	sub    $0xc,%esp
  800609:	ff 75 0c             	pushl  0xc(%ebp)
  80060c:	ff 75 08             	pushl  0x8(%ebp)
  80060f:	56                   	push   %esi
  800610:	50                   	push   %eax
  800611:	68 40 16 80 00       	push   $0x801640
  800616:	e8 b1 00 00 00       	call   8006cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80061b:	83 c4 18             	add    $0x18,%esp
  80061e:	53                   	push   %ebx
  80061f:	ff 75 10             	pushl  0x10(%ebp)
  800622:	e8 54 00 00 00       	call   80067b <vcprintf>
	cprintf("\n");
  800627:	c7 04 24 50 15 80 00 	movl   $0x801550,(%esp)
  80062e:	e8 99 00 00 00       	call   8006cc <cprintf>
  800633:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800636:	cc                   	int3   
  800637:	eb fd                	jmp    800636 <_panic+0x43>

00800639 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800639:	55                   	push   %ebp
  80063a:	89 e5                	mov    %esp,%ebp
  80063c:	53                   	push   %ebx
  80063d:	83 ec 04             	sub    $0x4,%esp
  800640:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800643:	8b 13                	mov    (%ebx),%edx
  800645:	8d 42 01             	lea    0x1(%edx),%eax
  800648:	89 03                	mov    %eax,(%ebx)
  80064a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80064d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800651:	3d ff 00 00 00       	cmp    $0xff,%eax
  800656:	75 1a                	jne    800672 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	68 ff 00 00 00       	push   $0xff
  800660:	8d 43 08             	lea    0x8(%ebx),%eax
  800663:	50                   	push   %eax
  800664:	e8 71 09 00 00       	call   800fda <sys_cputs>
		b->idx = 0;
  800669:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80066f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800672:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800676:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800679:	c9                   	leave  
  80067a:	c3                   	ret    

0080067b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80067b:	55                   	push   %ebp
  80067c:	89 e5                	mov    %esp,%ebp
  80067e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800684:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80068b:	00 00 00 
	b.cnt = 0;
  80068e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800695:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800698:	ff 75 0c             	pushl  0xc(%ebp)
  80069b:	ff 75 08             	pushl  0x8(%ebp)
  80069e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a4:	50                   	push   %eax
  8006a5:	68 39 06 80 00       	push   $0x800639
  8006aa:	e8 54 01 00 00       	call   800803 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006af:	83 c4 08             	add    $0x8,%esp
  8006b2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006b8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006be:	50                   	push   %eax
  8006bf:	e8 16 09 00 00       	call   800fda <sys_cputs>

	return b.cnt;
}
  8006c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006ca:	c9                   	leave  
  8006cb:	c3                   	ret    

008006cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d5:	50                   	push   %eax
  8006d6:	ff 75 08             	pushl  0x8(%ebp)
  8006d9:	e8 9d ff ff ff       	call   80067b <vcprintf>
	va_end(ap);

	return cnt;
}
  8006de:	c9                   	leave  
  8006df:	c3                   	ret    

008006e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	57                   	push   %edi
  8006e4:	56                   	push   %esi
  8006e5:	53                   	push   %ebx
  8006e6:	83 ec 1c             	sub    $0x1c,%esp
  8006e9:	89 c7                	mov    %eax,%edi
  8006eb:	89 d6                	mov    %edx,%esi
  8006ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8006fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800701:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800704:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800707:	39 d3                	cmp    %edx,%ebx
  800709:	72 05                	jb     800710 <printnum+0x30>
  80070b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80070e:	77 45                	ja     800755 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800710:	83 ec 0c             	sub    $0xc,%esp
  800713:	ff 75 18             	pushl  0x18(%ebp)
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80071c:	53                   	push   %ebx
  80071d:	ff 75 10             	pushl  0x10(%ebp)
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	ff 75 e4             	pushl  -0x1c(%ebp)
  800726:	ff 75 e0             	pushl  -0x20(%ebp)
  800729:	ff 75 dc             	pushl  -0x24(%ebp)
  80072c:	ff 75 d8             	pushl  -0x28(%ebp)
  80072f:	e8 4c 0b 00 00       	call   801280 <__udivdi3>
  800734:	83 c4 18             	add    $0x18,%esp
  800737:	52                   	push   %edx
  800738:	50                   	push   %eax
  800739:	89 f2                	mov    %esi,%edx
  80073b:	89 f8                	mov    %edi,%eax
  80073d:	e8 9e ff ff ff       	call   8006e0 <printnum>
  800742:	83 c4 20             	add    $0x20,%esp
  800745:	eb 18                	jmp    80075f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	56                   	push   %esi
  80074b:	ff 75 18             	pushl  0x18(%ebp)
  80074e:	ff d7                	call   *%edi
  800750:	83 c4 10             	add    $0x10,%esp
  800753:	eb 03                	jmp    800758 <printnum+0x78>
  800755:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800758:	83 eb 01             	sub    $0x1,%ebx
  80075b:	85 db                	test   %ebx,%ebx
  80075d:	7f e8                	jg     800747 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80075f:	83 ec 08             	sub    $0x8,%esp
  800762:	56                   	push   %esi
  800763:	83 ec 04             	sub    $0x4,%esp
  800766:	ff 75 e4             	pushl  -0x1c(%ebp)
  800769:	ff 75 e0             	pushl  -0x20(%ebp)
  80076c:	ff 75 dc             	pushl  -0x24(%ebp)
  80076f:	ff 75 d8             	pushl  -0x28(%ebp)
  800772:	e8 39 0c 00 00       	call   8013b0 <__umoddi3>
  800777:	83 c4 14             	add    $0x14,%esp
  80077a:	0f be 80 63 16 80 00 	movsbl 0x801663(%eax),%eax
  800781:	50                   	push   %eax
  800782:	ff d7                	call   *%edi
}
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078a:	5b                   	pop    %ebx
  80078b:	5e                   	pop    %esi
  80078c:	5f                   	pop    %edi
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800792:	83 fa 01             	cmp    $0x1,%edx
  800795:	7e 0e                	jle    8007a5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800797:	8b 10                	mov    (%eax),%edx
  800799:	8d 4a 08             	lea    0x8(%edx),%ecx
  80079c:	89 08                	mov    %ecx,(%eax)
  80079e:	8b 02                	mov    (%edx),%eax
  8007a0:	8b 52 04             	mov    0x4(%edx),%edx
  8007a3:	eb 22                	jmp    8007c7 <getuint+0x38>
	else if (lflag)
  8007a5:	85 d2                	test   %edx,%edx
  8007a7:	74 10                	je     8007b9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007a9:	8b 10                	mov    (%eax),%edx
  8007ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007ae:	89 08                	mov    %ecx,(%eax)
  8007b0:	8b 02                	mov    (%edx),%eax
  8007b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b7:	eb 0e                	jmp    8007c7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007b9:	8b 10                	mov    (%eax),%edx
  8007bb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007be:	89 08                	mov    %ecx,(%eax)
  8007c0:	8b 02                	mov    (%edx),%eax
  8007c2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007d3:	8b 10                	mov    (%eax),%edx
  8007d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8007d8:	73 0a                	jae    8007e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007dd:	89 08                	mov    %ecx,(%eax)
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	88 02                	mov    %al,(%edx)
}
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007ef:	50                   	push   %eax
  8007f0:	ff 75 10             	pushl  0x10(%ebp)
  8007f3:	ff 75 0c             	pushl  0xc(%ebp)
  8007f6:	ff 75 08             	pushl  0x8(%ebp)
  8007f9:	e8 05 00 00 00       	call   800803 <vprintfmt>
	va_end(ap);
}
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	c9                   	leave  
  800802:	c3                   	ret    

00800803 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	57                   	push   %edi
  800807:	56                   	push   %esi
  800808:	53                   	push   %ebx
  800809:	83 ec 2c             	sub    $0x2c,%esp
  80080c:	8b 75 08             	mov    0x8(%ebp),%esi
  80080f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800812:	8b 7d 10             	mov    0x10(%ebp),%edi
  800815:	eb 12                	jmp    800829 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800817:	85 c0                	test   %eax,%eax
  800819:	0f 84 cb 03 00 00    	je     800bea <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	53                   	push   %ebx
  800823:	50                   	push   %eax
  800824:	ff d6                	call   *%esi
  800826:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800829:	83 c7 01             	add    $0x1,%edi
  80082c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800830:	83 f8 25             	cmp    $0x25,%eax
  800833:	75 e2                	jne    800817 <vprintfmt+0x14>
  800835:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800839:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800840:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800847:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80084e:	ba 00 00 00 00       	mov    $0x0,%edx
  800853:	eb 07                	jmp    80085c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800855:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800858:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085c:	8d 47 01             	lea    0x1(%edi),%eax
  80085f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800862:	0f b6 07             	movzbl (%edi),%eax
  800865:	0f b6 c8             	movzbl %al,%ecx
  800868:	83 e8 23             	sub    $0x23,%eax
  80086b:	3c 55                	cmp    $0x55,%al
  80086d:	0f 87 5c 03 00 00    	ja     800bcf <vprintfmt+0x3cc>
  800873:	0f b6 c0             	movzbl %al,%eax
  800876:	ff 24 85 40 17 80 00 	jmp    *0x801740(,%eax,4)
  80087d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800880:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800884:	eb d6                	jmp    80085c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800886:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800889:	b8 00 00 00 00       	mov    $0x0,%eax
  80088e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800891:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800894:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800898:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80089b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80089e:	83 fa 09             	cmp    $0x9,%edx
  8008a1:	77 39                	ja     8008dc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008a3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008a6:	eb e9                	jmp    800891 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ab:	8d 48 04             	lea    0x4(%eax),%ecx
  8008ae:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008b1:	8b 00                	mov    (%eax),%eax
  8008b3:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008b9:	eb 27                	jmp    8008e2 <vprintfmt+0xdf>
  8008bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008be:	85 c0                	test   %eax,%eax
  8008c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c5:	0f 49 c8             	cmovns %eax,%ecx
  8008c8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ce:	eb 8c                	jmp    80085c <vprintfmt+0x59>
  8008d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008d3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008da:	eb 80                	jmp    80085c <vprintfmt+0x59>
  8008dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008df:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8008e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008e6:	0f 89 70 ff ff ff    	jns    80085c <vprintfmt+0x59>
				width = precision, precision = -1;
  8008ec:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8008ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008f2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8008f9:	e9 5e ff ff ff       	jmp    80085c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008fe:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800901:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800904:	e9 53 ff ff ff       	jmp    80085c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800909:	8b 45 14             	mov    0x14(%ebp),%eax
  80090c:	8d 50 04             	lea    0x4(%eax),%edx
  80090f:	89 55 14             	mov    %edx,0x14(%ebp)
  800912:	83 ec 08             	sub    $0x8,%esp
  800915:	53                   	push   %ebx
  800916:	ff 30                	pushl  (%eax)
  800918:	ff d6                	call   *%esi
			break;
  80091a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80091d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800920:	e9 04 ff ff ff       	jmp    800829 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800925:	8b 45 14             	mov    0x14(%ebp),%eax
  800928:	8d 50 04             	lea    0x4(%eax),%edx
  80092b:	89 55 14             	mov    %edx,0x14(%ebp)
  80092e:	8b 00                	mov    (%eax),%eax
  800930:	99                   	cltd   
  800931:	31 d0                	xor    %edx,%eax
  800933:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800935:	83 f8 09             	cmp    $0x9,%eax
  800938:	7f 0b                	jg     800945 <vprintfmt+0x142>
  80093a:	8b 14 85 a0 18 80 00 	mov    0x8018a0(,%eax,4),%edx
  800941:	85 d2                	test   %edx,%edx
  800943:	75 18                	jne    80095d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800945:	50                   	push   %eax
  800946:	68 7b 16 80 00       	push   $0x80167b
  80094b:	53                   	push   %ebx
  80094c:	56                   	push   %esi
  80094d:	e8 94 fe ff ff       	call   8007e6 <printfmt>
  800952:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800955:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800958:	e9 cc fe ff ff       	jmp    800829 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80095d:	52                   	push   %edx
  80095e:	68 84 16 80 00       	push   $0x801684
  800963:	53                   	push   %ebx
  800964:	56                   	push   %esi
  800965:	e8 7c fe ff ff       	call   8007e6 <printfmt>
  80096a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800970:	e9 b4 fe ff ff       	jmp    800829 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800975:	8b 45 14             	mov    0x14(%ebp),%eax
  800978:	8d 50 04             	lea    0x4(%eax),%edx
  80097b:	89 55 14             	mov    %edx,0x14(%ebp)
  80097e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800980:	85 ff                	test   %edi,%edi
  800982:	b8 74 16 80 00       	mov    $0x801674,%eax
  800987:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80098a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80098e:	0f 8e 94 00 00 00    	jle    800a28 <vprintfmt+0x225>
  800994:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800998:	0f 84 98 00 00 00    	je     800a36 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80099e:	83 ec 08             	sub    $0x8,%esp
  8009a1:	ff 75 c8             	pushl  -0x38(%ebp)
  8009a4:	57                   	push   %edi
  8009a5:	e8 c8 02 00 00       	call   800c72 <strnlen>
  8009aa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009ad:	29 c1                	sub    %eax,%ecx
  8009af:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8009b2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009b5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009bc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009bf:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c1:	eb 0f                	jmp    8009d2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8009c3:	83 ec 08             	sub    $0x8,%esp
  8009c6:	53                   	push   %ebx
  8009c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8009ca:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009cc:	83 ef 01             	sub    $0x1,%edi
  8009cf:	83 c4 10             	add    $0x10,%esp
  8009d2:	85 ff                	test   %edi,%edi
  8009d4:	7f ed                	jg     8009c3 <vprintfmt+0x1c0>
  8009d6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009d9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8009dc:	85 c9                	test   %ecx,%ecx
  8009de:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e3:	0f 49 c1             	cmovns %ecx,%eax
  8009e6:	29 c1                	sub    %eax,%ecx
  8009e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8009eb:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8009ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009f1:	89 cb                	mov    %ecx,%ebx
  8009f3:	eb 4d                	jmp    800a42 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009f9:	74 1b                	je     800a16 <vprintfmt+0x213>
  8009fb:	0f be c0             	movsbl %al,%eax
  8009fe:	83 e8 20             	sub    $0x20,%eax
  800a01:	83 f8 5e             	cmp    $0x5e,%eax
  800a04:	76 10                	jbe    800a16 <vprintfmt+0x213>
					putch('?', putdat);
  800a06:	83 ec 08             	sub    $0x8,%esp
  800a09:	ff 75 0c             	pushl  0xc(%ebp)
  800a0c:	6a 3f                	push   $0x3f
  800a0e:	ff 55 08             	call   *0x8(%ebp)
  800a11:	83 c4 10             	add    $0x10,%esp
  800a14:	eb 0d                	jmp    800a23 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800a16:	83 ec 08             	sub    $0x8,%esp
  800a19:	ff 75 0c             	pushl  0xc(%ebp)
  800a1c:	52                   	push   %edx
  800a1d:	ff 55 08             	call   *0x8(%ebp)
  800a20:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a23:	83 eb 01             	sub    $0x1,%ebx
  800a26:	eb 1a                	jmp    800a42 <vprintfmt+0x23f>
  800a28:	89 75 08             	mov    %esi,0x8(%ebp)
  800a2b:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800a2e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a31:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a34:	eb 0c                	jmp    800a42 <vprintfmt+0x23f>
  800a36:	89 75 08             	mov    %esi,0x8(%ebp)
  800a39:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800a3c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a3f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a42:	83 c7 01             	add    $0x1,%edi
  800a45:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a49:	0f be d0             	movsbl %al,%edx
  800a4c:	85 d2                	test   %edx,%edx
  800a4e:	74 23                	je     800a73 <vprintfmt+0x270>
  800a50:	85 f6                	test   %esi,%esi
  800a52:	78 a1                	js     8009f5 <vprintfmt+0x1f2>
  800a54:	83 ee 01             	sub    $0x1,%esi
  800a57:	79 9c                	jns    8009f5 <vprintfmt+0x1f2>
  800a59:	89 df                	mov    %ebx,%edi
  800a5b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a61:	eb 18                	jmp    800a7b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a63:	83 ec 08             	sub    $0x8,%esp
  800a66:	53                   	push   %ebx
  800a67:	6a 20                	push   $0x20
  800a69:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a6b:	83 ef 01             	sub    $0x1,%edi
  800a6e:	83 c4 10             	add    $0x10,%esp
  800a71:	eb 08                	jmp    800a7b <vprintfmt+0x278>
  800a73:	89 df                	mov    %ebx,%edi
  800a75:	8b 75 08             	mov    0x8(%ebp),%esi
  800a78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a7b:	85 ff                	test   %edi,%edi
  800a7d:	7f e4                	jg     800a63 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a7f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a82:	e9 a2 fd ff ff       	jmp    800829 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a87:	83 fa 01             	cmp    $0x1,%edx
  800a8a:	7e 16                	jle    800aa2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800a8c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8f:	8d 50 08             	lea    0x8(%eax),%edx
  800a92:	89 55 14             	mov    %edx,0x14(%ebp)
  800a95:	8b 50 04             	mov    0x4(%eax),%edx
  800a98:	8b 00                	mov    (%eax),%eax
  800a9a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800a9d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800aa0:	eb 32                	jmp    800ad4 <vprintfmt+0x2d1>
	else if (lflag)
  800aa2:	85 d2                	test   %edx,%edx
  800aa4:	74 18                	je     800abe <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800aa6:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa9:	8d 50 04             	lea    0x4(%eax),%edx
  800aac:	89 55 14             	mov    %edx,0x14(%ebp)
  800aaf:	8b 00                	mov    (%eax),%eax
  800ab1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800ab4:	89 c1                	mov    %eax,%ecx
  800ab6:	c1 f9 1f             	sar    $0x1f,%ecx
  800ab9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800abc:	eb 16                	jmp    800ad4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800abe:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac1:	8d 50 04             	lea    0x4(%eax),%edx
  800ac4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac7:	8b 00                	mov    (%eax),%eax
  800ac9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800acc:	89 c1                	mov    %eax,%ecx
  800ace:	c1 f9 1f             	sar    $0x1f,%ecx
  800ad1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800ad7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800ada:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800add:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ae0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ae5:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800ae9:	0f 89 a8 00 00 00    	jns    800b97 <vprintfmt+0x394>
				putch('-', putdat);
  800aef:	83 ec 08             	sub    $0x8,%esp
  800af2:	53                   	push   %ebx
  800af3:	6a 2d                	push   $0x2d
  800af5:	ff d6                	call   *%esi
				num = -(long long) num;
  800af7:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800afa:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800afd:	f7 d8                	neg    %eax
  800aff:	83 d2 00             	adc    $0x0,%edx
  800b02:	f7 da                	neg    %edx
  800b04:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b07:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b0a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b0d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b12:	e9 80 00 00 00       	jmp    800b97 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b17:	8d 45 14             	lea    0x14(%ebp),%eax
  800b1a:	e8 70 fc ff ff       	call   80078f <getuint>
  800b1f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b22:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800b25:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800b2a:	eb 6b                	jmp    800b97 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800b2c:	8d 45 14             	lea    0x14(%ebp),%eax
  800b2f:	e8 5b fc ff ff       	call   80078f <getuint>
  800b34:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b37:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800b3a:	6a 04                	push   $0x4
  800b3c:	6a 03                	push   $0x3
  800b3e:	6a 01                	push   $0x1
  800b40:	68 87 16 80 00       	push   $0x801687
  800b45:	e8 82 fb ff ff       	call   8006cc <cprintf>
			goto number;
  800b4a:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  800b4d:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  800b52:	eb 43                	jmp    800b97 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  800b54:	83 ec 08             	sub    $0x8,%esp
  800b57:	53                   	push   %ebx
  800b58:	6a 30                	push   $0x30
  800b5a:	ff d6                	call   *%esi
			putch('x', putdat);
  800b5c:	83 c4 08             	add    $0x8,%esp
  800b5f:	53                   	push   %ebx
  800b60:	6a 78                	push   $0x78
  800b62:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b64:	8b 45 14             	mov    0x14(%ebp),%eax
  800b67:	8d 50 04             	lea    0x4(%eax),%edx
  800b6a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b6d:	8b 00                	mov    (%eax),%eax
  800b6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b74:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b77:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b7a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b7d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b82:	eb 13                	jmp    800b97 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b84:	8d 45 14             	lea    0x14(%ebp),%eax
  800b87:	e8 03 fc ff ff       	call   80078f <getuint>
  800b8c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b8f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800b92:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b97:	83 ec 0c             	sub    $0xc,%esp
  800b9a:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800b9e:	52                   	push   %edx
  800b9f:	ff 75 e0             	pushl  -0x20(%ebp)
  800ba2:	50                   	push   %eax
  800ba3:	ff 75 dc             	pushl  -0x24(%ebp)
  800ba6:	ff 75 d8             	pushl  -0x28(%ebp)
  800ba9:	89 da                	mov    %ebx,%edx
  800bab:	89 f0                	mov    %esi,%eax
  800bad:	e8 2e fb ff ff       	call   8006e0 <printnum>

			break;
  800bb2:	83 c4 20             	add    $0x20,%esp
  800bb5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bb8:	e9 6c fc ff ff       	jmp    800829 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800bbd:	83 ec 08             	sub    $0x8,%esp
  800bc0:	53                   	push   %ebx
  800bc1:	51                   	push   %ecx
  800bc2:	ff d6                	call   *%esi
			break;
  800bc4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bc7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800bca:	e9 5a fc ff ff       	jmp    800829 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800bcf:	83 ec 08             	sub    $0x8,%esp
  800bd2:	53                   	push   %ebx
  800bd3:	6a 25                	push   $0x25
  800bd5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800bd7:	83 c4 10             	add    $0x10,%esp
  800bda:	eb 03                	jmp    800bdf <vprintfmt+0x3dc>
  800bdc:	83 ef 01             	sub    $0x1,%edi
  800bdf:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800be3:	75 f7                	jne    800bdc <vprintfmt+0x3d9>
  800be5:	e9 3f fc ff ff       	jmp    800829 <vprintfmt+0x26>
			break;
		}

	}

}
  800bea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	83 ec 18             	sub    $0x18,%esp
  800bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bfe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c01:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c05:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c08:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	74 26                	je     800c39 <vsnprintf+0x47>
  800c13:	85 d2                	test   %edx,%edx
  800c15:	7e 22                	jle    800c39 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c17:	ff 75 14             	pushl  0x14(%ebp)
  800c1a:	ff 75 10             	pushl  0x10(%ebp)
  800c1d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c20:	50                   	push   %eax
  800c21:	68 c9 07 80 00       	push   $0x8007c9
  800c26:	e8 d8 fb ff ff       	call   800803 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c2b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c2e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c34:	83 c4 10             	add    $0x10,%esp
  800c37:	eb 05                	jmp    800c3e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c39:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c3e:	c9                   	leave  
  800c3f:	c3                   	ret    

00800c40 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c46:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c49:	50                   	push   %eax
  800c4a:	ff 75 10             	pushl  0x10(%ebp)
  800c4d:	ff 75 0c             	pushl  0xc(%ebp)
  800c50:	ff 75 08             	pushl  0x8(%ebp)
  800c53:	e8 9a ff ff ff       	call   800bf2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c58:	c9                   	leave  
  800c59:	c3                   	ret    

00800c5a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c60:	b8 00 00 00 00       	mov    $0x0,%eax
  800c65:	eb 03                	jmp    800c6a <strlen+0x10>
		n++;
  800c67:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c6a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c6e:	75 f7                	jne    800c67 <strlen+0xd>
		n++;
	return n;
}
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c78:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c80:	eb 03                	jmp    800c85 <strnlen+0x13>
		n++;
  800c82:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c85:	39 c2                	cmp    %eax,%edx
  800c87:	74 08                	je     800c91 <strnlen+0x1f>
  800c89:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c8d:	75 f3                	jne    800c82 <strnlen+0x10>
  800c8f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	53                   	push   %ebx
  800c97:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c9d:	89 c2                	mov    %eax,%edx
  800c9f:	83 c2 01             	add    $0x1,%edx
  800ca2:	83 c1 01             	add    $0x1,%ecx
  800ca5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800ca9:	88 5a ff             	mov    %bl,-0x1(%edx)
  800cac:	84 db                	test   %bl,%bl
  800cae:	75 ef                	jne    800c9f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800cb0:	5b                   	pop    %ebx
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	53                   	push   %ebx
  800cb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cba:	53                   	push   %ebx
  800cbb:	e8 9a ff ff ff       	call   800c5a <strlen>
  800cc0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800cc3:	ff 75 0c             	pushl  0xc(%ebp)
  800cc6:	01 d8                	add    %ebx,%eax
  800cc8:	50                   	push   %eax
  800cc9:	e8 c5 ff ff ff       	call   800c93 <strcpy>
	return dst;
}
  800cce:	89 d8                	mov    %ebx,%eax
  800cd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cd3:	c9                   	leave  
  800cd4:	c3                   	ret    

00800cd5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
  800cda:	8b 75 08             	mov    0x8(%ebp),%esi
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	89 f3                	mov    %esi,%ebx
  800ce2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ce5:	89 f2                	mov    %esi,%edx
  800ce7:	eb 0f                	jmp    800cf8 <strncpy+0x23>
		*dst++ = *src;
  800ce9:	83 c2 01             	add    $0x1,%edx
  800cec:	0f b6 01             	movzbl (%ecx),%eax
  800cef:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cf2:	80 39 01             	cmpb   $0x1,(%ecx)
  800cf5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cf8:	39 da                	cmp    %ebx,%edx
  800cfa:	75 ed                	jne    800ce9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cfc:	89 f0                	mov    %esi,%eax
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	8b 75 08             	mov    0x8(%ebp),%esi
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	8b 55 10             	mov    0x10(%ebp),%edx
  800d10:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d12:	85 d2                	test   %edx,%edx
  800d14:	74 21                	je     800d37 <strlcpy+0x35>
  800d16:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d1a:	89 f2                	mov    %esi,%edx
  800d1c:	eb 09                	jmp    800d27 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d1e:	83 c2 01             	add    $0x1,%edx
  800d21:	83 c1 01             	add    $0x1,%ecx
  800d24:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d27:	39 c2                	cmp    %eax,%edx
  800d29:	74 09                	je     800d34 <strlcpy+0x32>
  800d2b:	0f b6 19             	movzbl (%ecx),%ebx
  800d2e:	84 db                	test   %bl,%bl
  800d30:	75 ec                	jne    800d1e <strlcpy+0x1c>
  800d32:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d34:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d37:	29 f0                	sub    %esi,%eax
}
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d43:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d46:	eb 06                	jmp    800d4e <strcmp+0x11>
		p++, q++;
  800d48:	83 c1 01             	add    $0x1,%ecx
  800d4b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d4e:	0f b6 01             	movzbl (%ecx),%eax
  800d51:	84 c0                	test   %al,%al
  800d53:	74 04                	je     800d59 <strcmp+0x1c>
  800d55:	3a 02                	cmp    (%edx),%al
  800d57:	74 ef                	je     800d48 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d59:	0f b6 c0             	movzbl %al,%eax
  800d5c:	0f b6 12             	movzbl (%edx),%edx
  800d5f:	29 d0                	sub    %edx,%eax
}
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	53                   	push   %ebx
  800d67:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d6d:	89 c3                	mov    %eax,%ebx
  800d6f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d72:	eb 06                	jmp    800d7a <strncmp+0x17>
		n--, p++, q++;
  800d74:	83 c0 01             	add    $0x1,%eax
  800d77:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d7a:	39 d8                	cmp    %ebx,%eax
  800d7c:	74 15                	je     800d93 <strncmp+0x30>
  800d7e:	0f b6 08             	movzbl (%eax),%ecx
  800d81:	84 c9                	test   %cl,%cl
  800d83:	74 04                	je     800d89 <strncmp+0x26>
  800d85:	3a 0a                	cmp    (%edx),%cl
  800d87:	74 eb                	je     800d74 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d89:	0f b6 00             	movzbl (%eax),%eax
  800d8c:	0f b6 12             	movzbl (%edx),%edx
  800d8f:	29 d0                	sub    %edx,%eax
  800d91:	eb 05                	jmp    800d98 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d93:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d98:	5b                   	pop    %ebx
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800da1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800da5:	eb 07                	jmp    800dae <strchr+0x13>
		if (*s == c)
  800da7:	38 ca                	cmp    %cl,%dl
  800da9:	74 0f                	je     800dba <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dab:	83 c0 01             	add    $0x1,%eax
  800dae:	0f b6 10             	movzbl (%eax),%edx
  800db1:	84 d2                	test   %dl,%dl
  800db3:	75 f2                	jne    800da7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800db5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800dc6:	eb 03                	jmp    800dcb <strfind+0xf>
  800dc8:	83 c0 01             	add    $0x1,%eax
  800dcb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800dce:	38 ca                	cmp    %cl,%dl
  800dd0:	74 04                	je     800dd6 <strfind+0x1a>
  800dd2:	84 d2                	test   %dl,%dl
  800dd4:	75 f2                	jne    800dc8 <strfind+0xc>
			break;
	return (char *) s;
}
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	57                   	push   %edi
  800ddc:	56                   	push   %esi
  800ddd:	53                   	push   %ebx
  800dde:	8b 7d 08             	mov    0x8(%ebp),%edi
  800de1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800de4:	85 c9                	test   %ecx,%ecx
  800de6:	74 36                	je     800e1e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800de8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dee:	75 28                	jne    800e18 <memset+0x40>
  800df0:	f6 c1 03             	test   $0x3,%cl
  800df3:	75 23                	jne    800e18 <memset+0x40>
		c &= 0xFF;
  800df5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800df9:	89 d3                	mov    %edx,%ebx
  800dfb:	c1 e3 08             	shl    $0x8,%ebx
  800dfe:	89 d6                	mov    %edx,%esi
  800e00:	c1 e6 18             	shl    $0x18,%esi
  800e03:	89 d0                	mov    %edx,%eax
  800e05:	c1 e0 10             	shl    $0x10,%eax
  800e08:	09 f0                	or     %esi,%eax
  800e0a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e0c:	89 d8                	mov    %ebx,%eax
  800e0e:	09 d0                	or     %edx,%eax
  800e10:	c1 e9 02             	shr    $0x2,%ecx
  800e13:	fc                   	cld    
  800e14:	f3 ab                	rep stos %eax,%es:(%edi)
  800e16:	eb 06                	jmp    800e1e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1b:	fc                   	cld    
  800e1c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e1e:	89 f8                	mov    %edi,%eax
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e33:	39 c6                	cmp    %eax,%esi
  800e35:	73 35                	jae    800e6c <memmove+0x47>
  800e37:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e3a:	39 d0                	cmp    %edx,%eax
  800e3c:	73 2e                	jae    800e6c <memmove+0x47>
		s += n;
		d += n;
  800e3e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e41:	89 d6                	mov    %edx,%esi
  800e43:	09 fe                	or     %edi,%esi
  800e45:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e4b:	75 13                	jne    800e60 <memmove+0x3b>
  800e4d:	f6 c1 03             	test   $0x3,%cl
  800e50:	75 0e                	jne    800e60 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e52:	83 ef 04             	sub    $0x4,%edi
  800e55:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e58:	c1 e9 02             	shr    $0x2,%ecx
  800e5b:	fd                   	std    
  800e5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e5e:	eb 09                	jmp    800e69 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e60:	83 ef 01             	sub    $0x1,%edi
  800e63:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e66:	fd                   	std    
  800e67:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e69:	fc                   	cld    
  800e6a:	eb 1d                	jmp    800e89 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e6c:	89 f2                	mov    %esi,%edx
  800e6e:	09 c2                	or     %eax,%edx
  800e70:	f6 c2 03             	test   $0x3,%dl
  800e73:	75 0f                	jne    800e84 <memmove+0x5f>
  800e75:	f6 c1 03             	test   $0x3,%cl
  800e78:	75 0a                	jne    800e84 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e7a:	c1 e9 02             	shr    $0x2,%ecx
  800e7d:	89 c7                	mov    %eax,%edi
  800e7f:	fc                   	cld    
  800e80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e82:	eb 05                	jmp    800e89 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e84:	89 c7                	mov    %eax,%edi
  800e86:	fc                   	cld    
  800e87:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e89:	5e                   	pop    %esi
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e90:	ff 75 10             	pushl  0x10(%ebp)
  800e93:	ff 75 0c             	pushl  0xc(%ebp)
  800e96:	ff 75 08             	pushl  0x8(%ebp)
  800e99:	e8 87 ff ff ff       	call   800e25 <memmove>
}
  800e9e:	c9                   	leave  
  800e9f:	c3                   	ret    

00800ea0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	56                   	push   %esi
  800ea4:	53                   	push   %ebx
  800ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eab:	89 c6                	mov    %eax,%esi
  800ead:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eb0:	eb 1a                	jmp    800ecc <memcmp+0x2c>
		if (*s1 != *s2)
  800eb2:	0f b6 08             	movzbl (%eax),%ecx
  800eb5:	0f b6 1a             	movzbl (%edx),%ebx
  800eb8:	38 d9                	cmp    %bl,%cl
  800eba:	74 0a                	je     800ec6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ebc:	0f b6 c1             	movzbl %cl,%eax
  800ebf:	0f b6 db             	movzbl %bl,%ebx
  800ec2:	29 d8                	sub    %ebx,%eax
  800ec4:	eb 0f                	jmp    800ed5 <memcmp+0x35>
		s1++, s2++;
  800ec6:	83 c0 01             	add    $0x1,%eax
  800ec9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ecc:	39 f0                	cmp    %esi,%eax
  800ece:	75 e2                	jne    800eb2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ed0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ed5:	5b                   	pop    %ebx
  800ed6:	5e                   	pop    %esi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	53                   	push   %ebx
  800edd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ee0:	89 c1                	mov    %eax,%ecx
  800ee2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ee5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ee9:	eb 0a                	jmp    800ef5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800eeb:	0f b6 10             	movzbl (%eax),%edx
  800eee:	39 da                	cmp    %ebx,%edx
  800ef0:	74 07                	je     800ef9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ef2:	83 c0 01             	add    $0x1,%eax
  800ef5:	39 c8                	cmp    %ecx,%eax
  800ef7:	72 f2                	jb     800eeb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ef9:	5b                   	pop    %ebx
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	57                   	push   %edi
  800f00:	56                   	push   %esi
  800f01:	53                   	push   %ebx
  800f02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f08:	eb 03                	jmp    800f0d <strtol+0x11>
		s++;
  800f0a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f0d:	0f b6 01             	movzbl (%ecx),%eax
  800f10:	3c 20                	cmp    $0x20,%al
  800f12:	74 f6                	je     800f0a <strtol+0xe>
  800f14:	3c 09                	cmp    $0x9,%al
  800f16:	74 f2                	je     800f0a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f18:	3c 2b                	cmp    $0x2b,%al
  800f1a:	75 0a                	jne    800f26 <strtol+0x2a>
		s++;
  800f1c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f1f:	bf 00 00 00 00       	mov    $0x0,%edi
  800f24:	eb 11                	jmp    800f37 <strtol+0x3b>
  800f26:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f2b:	3c 2d                	cmp    $0x2d,%al
  800f2d:	75 08                	jne    800f37 <strtol+0x3b>
		s++, neg = 1;
  800f2f:	83 c1 01             	add    $0x1,%ecx
  800f32:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f37:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f3d:	75 15                	jne    800f54 <strtol+0x58>
  800f3f:	80 39 30             	cmpb   $0x30,(%ecx)
  800f42:	75 10                	jne    800f54 <strtol+0x58>
  800f44:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f48:	75 7c                	jne    800fc6 <strtol+0xca>
		s += 2, base = 16;
  800f4a:	83 c1 02             	add    $0x2,%ecx
  800f4d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f52:	eb 16                	jmp    800f6a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f54:	85 db                	test   %ebx,%ebx
  800f56:	75 12                	jne    800f6a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f58:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f5d:	80 39 30             	cmpb   $0x30,(%ecx)
  800f60:	75 08                	jne    800f6a <strtol+0x6e>
		s++, base = 8;
  800f62:	83 c1 01             	add    $0x1,%ecx
  800f65:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f72:	0f b6 11             	movzbl (%ecx),%edx
  800f75:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f78:	89 f3                	mov    %esi,%ebx
  800f7a:	80 fb 09             	cmp    $0x9,%bl
  800f7d:	77 08                	ja     800f87 <strtol+0x8b>
			dig = *s - '0';
  800f7f:	0f be d2             	movsbl %dl,%edx
  800f82:	83 ea 30             	sub    $0x30,%edx
  800f85:	eb 22                	jmp    800fa9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f87:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f8a:	89 f3                	mov    %esi,%ebx
  800f8c:	80 fb 19             	cmp    $0x19,%bl
  800f8f:	77 08                	ja     800f99 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f91:	0f be d2             	movsbl %dl,%edx
  800f94:	83 ea 57             	sub    $0x57,%edx
  800f97:	eb 10                	jmp    800fa9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800f99:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f9c:	89 f3                	mov    %esi,%ebx
  800f9e:	80 fb 19             	cmp    $0x19,%bl
  800fa1:	77 16                	ja     800fb9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800fa3:	0f be d2             	movsbl %dl,%edx
  800fa6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800fa9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800fac:	7d 0b                	jge    800fb9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800fae:	83 c1 01             	add    $0x1,%ecx
  800fb1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800fb5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800fb7:	eb b9                	jmp    800f72 <strtol+0x76>

	if (endptr)
  800fb9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fbd:	74 0d                	je     800fcc <strtol+0xd0>
		*endptr = (char *) s;
  800fbf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fc2:	89 0e                	mov    %ecx,(%esi)
  800fc4:	eb 06                	jmp    800fcc <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fc6:	85 db                	test   %ebx,%ebx
  800fc8:	74 98                	je     800f62 <strtol+0x66>
  800fca:	eb 9e                	jmp    800f6a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800fcc:	89 c2                	mov    %eax,%edx
  800fce:	f7 da                	neg    %edx
  800fd0:	85 ff                	test   %edi,%edi
  800fd2:	0f 45 c2             	cmovne %edx,%eax
}
  800fd5:	5b                   	pop    %ebx
  800fd6:	5e                   	pop    %esi
  800fd7:	5f                   	pop    %edi
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    

00800fda <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	57                   	push   %edi
  800fde:	56                   	push   %esi
  800fdf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe0:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe8:	8b 55 08             	mov    0x8(%ebp),%edx
  800feb:	89 c3                	mov    %eax,%ebx
  800fed:	89 c7                	mov    %eax,%edi
  800fef:	89 c6                	mov    %eax,%esi
  800ff1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ff3:	5b                   	pop    %ebx
  800ff4:	5e                   	pop    %esi
  800ff5:	5f                   	pop    %edi
  800ff6:	5d                   	pop    %ebp
  800ff7:	c3                   	ret    

00800ff8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	57                   	push   %edi
  800ffc:	56                   	push   %esi
  800ffd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffe:	ba 00 00 00 00       	mov    $0x0,%edx
  801003:	b8 01 00 00 00       	mov    $0x1,%eax
  801008:	89 d1                	mov    %edx,%ecx
  80100a:	89 d3                	mov    %edx,%ebx
  80100c:	89 d7                	mov    %edx,%edi
  80100e:	89 d6                	mov    %edx,%esi
  801010:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801012:	5b                   	pop    %ebx
  801013:	5e                   	pop    %esi
  801014:	5f                   	pop    %edi
  801015:	5d                   	pop    %ebp
  801016:	c3                   	ret    

00801017 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	57                   	push   %edi
  80101b:	56                   	push   %esi
  80101c:	53                   	push   %ebx
  80101d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801020:	b9 00 00 00 00       	mov    $0x0,%ecx
  801025:	b8 03 00 00 00       	mov    $0x3,%eax
  80102a:	8b 55 08             	mov    0x8(%ebp),%edx
  80102d:	89 cb                	mov    %ecx,%ebx
  80102f:	89 cf                	mov    %ecx,%edi
  801031:	89 ce                	mov    %ecx,%esi
  801033:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801035:	85 c0                	test   %eax,%eax
  801037:	7e 17                	jle    801050 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801039:	83 ec 0c             	sub    $0xc,%esp
  80103c:	50                   	push   %eax
  80103d:	6a 03                	push   $0x3
  80103f:	68 c8 18 80 00       	push   $0x8018c8
  801044:	6a 23                	push   $0x23
  801046:	68 e5 18 80 00       	push   $0x8018e5
  80104b:	e8 a3 f5 ff ff       	call   8005f3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801050:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	57                   	push   %edi
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105e:	ba 00 00 00 00       	mov    $0x0,%edx
  801063:	b8 02 00 00 00       	mov    $0x2,%eax
  801068:	89 d1                	mov    %edx,%ecx
  80106a:	89 d3                	mov    %edx,%ebx
  80106c:	89 d7                	mov    %edx,%edi
  80106e:	89 d6                	mov    %edx,%esi
  801070:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801072:	5b                   	pop    %ebx
  801073:	5e                   	pop    %esi
  801074:	5f                   	pop    %edi
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <sys_yield>:

void
sys_yield(void)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	57                   	push   %edi
  80107b:	56                   	push   %esi
  80107c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80107d:	ba 00 00 00 00       	mov    $0x0,%edx
  801082:	b8 0a 00 00 00       	mov    $0xa,%eax
  801087:	89 d1                	mov    %edx,%ecx
  801089:	89 d3                	mov    %edx,%ebx
  80108b:	89 d7                	mov    %edx,%edi
  80108d:	89 d6                	mov    %edx,%esi
  80108f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801091:	5b                   	pop    %ebx
  801092:	5e                   	pop    %esi
  801093:	5f                   	pop    %edi
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    

00801096 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	57                   	push   %edi
  80109a:	56                   	push   %esi
  80109b:	53                   	push   %ebx
  80109c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109f:	be 00 00 00 00       	mov    $0x0,%esi
  8010a4:	b8 04 00 00 00       	mov    $0x4,%eax
  8010a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8010af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010b2:	89 f7                	mov    %esi,%edi
  8010b4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	7e 17                	jle    8010d1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ba:	83 ec 0c             	sub    $0xc,%esp
  8010bd:	50                   	push   %eax
  8010be:	6a 04                	push   $0x4
  8010c0:	68 c8 18 80 00       	push   $0x8018c8
  8010c5:	6a 23                	push   $0x23
  8010c7:	68 e5 18 80 00       	push   $0x8018e5
  8010cc:	e8 22 f5 ff ff       	call   8005f3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d4:	5b                   	pop    %ebx
  8010d5:	5e                   	pop    %esi
  8010d6:	5f                   	pop    %edi
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    

008010d9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	57                   	push   %edi
  8010dd:	56                   	push   %esi
  8010de:	53                   	push   %ebx
  8010df:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8010e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010f3:	8b 75 18             	mov    0x18(%ebp),%esi
  8010f6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	7e 17                	jle    801113 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010fc:	83 ec 0c             	sub    $0xc,%esp
  8010ff:	50                   	push   %eax
  801100:	6a 05                	push   $0x5
  801102:	68 c8 18 80 00       	push   $0x8018c8
  801107:	6a 23                	push   $0x23
  801109:	68 e5 18 80 00       	push   $0x8018e5
  80110e:	e8 e0 f4 ff ff       	call   8005f3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801113:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801116:	5b                   	pop    %ebx
  801117:	5e                   	pop    %esi
  801118:	5f                   	pop    %edi
  801119:	5d                   	pop    %ebp
  80111a:	c3                   	ret    

0080111b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	57                   	push   %edi
  80111f:	56                   	push   %esi
  801120:	53                   	push   %ebx
  801121:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801124:	bb 00 00 00 00       	mov    $0x0,%ebx
  801129:	b8 06 00 00 00       	mov    $0x6,%eax
  80112e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801131:	8b 55 08             	mov    0x8(%ebp),%edx
  801134:	89 df                	mov    %ebx,%edi
  801136:	89 de                	mov    %ebx,%esi
  801138:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80113a:	85 c0                	test   %eax,%eax
  80113c:	7e 17                	jle    801155 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80113e:	83 ec 0c             	sub    $0xc,%esp
  801141:	50                   	push   %eax
  801142:	6a 06                	push   $0x6
  801144:	68 c8 18 80 00       	push   $0x8018c8
  801149:	6a 23                	push   $0x23
  80114b:	68 e5 18 80 00       	push   $0x8018e5
  801150:	e8 9e f4 ff ff       	call   8005f3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801155:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801158:	5b                   	pop    %ebx
  801159:	5e                   	pop    %esi
  80115a:	5f                   	pop    %edi
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	57                   	push   %edi
  801161:	56                   	push   %esi
  801162:	53                   	push   %ebx
  801163:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801166:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116b:	b8 08 00 00 00       	mov    $0x8,%eax
  801170:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801173:	8b 55 08             	mov    0x8(%ebp),%edx
  801176:	89 df                	mov    %ebx,%edi
  801178:	89 de                	mov    %ebx,%esi
  80117a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80117c:	85 c0                	test   %eax,%eax
  80117e:	7e 17                	jle    801197 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801180:	83 ec 0c             	sub    $0xc,%esp
  801183:	50                   	push   %eax
  801184:	6a 08                	push   $0x8
  801186:	68 c8 18 80 00       	push   $0x8018c8
  80118b:	6a 23                	push   $0x23
  80118d:	68 e5 18 80 00       	push   $0x8018e5
  801192:	e8 5c f4 ff ff       	call   8005f3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801197:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119a:	5b                   	pop    %ebx
  80119b:	5e                   	pop    %esi
  80119c:	5f                   	pop    %edi
  80119d:	5d                   	pop    %ebp
  80119e:	c3                   	ret    

0080119f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80119f:	55                   	push   %ebp
  8011a0:	89 e5                	mov    %esp,%ebp
  8011a2:	57                   	push   %edi
  8011a3:	56                   	push   %esi
  8011a4:	53                   	push   %ebx
  8011a5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ad:	b8 09 00 00 00       	mov    $0x9,%eax
  8011b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b8:	89 df                	mov    %ebx,%edi
  8011ba:	89 de                	mov    %ebx,%esi
  8011bc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	7e 17                	jle    8011d9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c2:	83 ec 0c             	sub    $0xc,%esp
  8011c5:	50                   	push   %eax
  8011c6:	6a 09                	push   $0x9
  8011c8:	68 c8 18 80 00       	push   $0x8018c8
  8011cd:	6a 23                	push   $0x23
  8011cf:	68 e5 18 80 00       	push   $0x8018e5
  8011d4:	e8 1a f4 ff ff       	call   8005f3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dc:	5b                   	pop    %ebx
  8011dd:	5e                   	pop    %esi
  8011de:	5f                   	pop    %edi
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	57                   	push   %edi
  8011e5:	56                   	push   %esi
  8011e6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e7:	be 00 00 00 00       	mov    $0x0,%esi
  8011ec:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011fa:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011fd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011ff:	5b                   	pop    %ebx
  801200:	5e                   	pop    %esi
  801201:	5f                   	pop    %edi
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    

00801204 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	57                   	push   %edi
  801208:	56                   	push   %esi
  801209:	53                   	push   %ebx
  80120a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80120d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801212:	b8 0c 00 00 00       	mov    $0xc,%eax
  801217:	8b 55 08             	mov    0x8(%ebp),%edx
  80121a:	89 cb                	mov    %ecx,%ebx
  80121c:	89 cf                	mov    %ecx,%edi
  80121e:	89 ce                	mov    %ecx,%esi
  801220:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801222:	85 c0                	test   %eax,%eax
  801224:	7e 17                	jle    80123d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801226:	83 ec 0c             	sub    $0xc,%esp
  801229:	50                   	push   %eax
  80122a:	6a 0c                	push   $0xc
  80122c:	68 c8 18 80 00       	push   $0x8018c8
  801231:	6a 23                	push   $0x23
  801233:	68 e5 18 80 00       	push   $0x8018e5
  801238:	e8 b6 f3 ff ff       	call   8005f3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80123d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801240:	5b                   	pop    %ebx
  801241:	5e                   	pop    %esi
  801242:	5f                   	pop    %edi
  801243:	5d                   	pop    %ebp
  801244:	c3                   	ret    

00801245 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80124b:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  801252:	75 14                	jne    801268 <set_pgfault_handler+0x23>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  801254:	83 ec 04             	sub    $0x4,%esp
  801257:	68 f4 18 80 00       	push   $0x8018f4
  80125c:	6a 20                	push   $0x20
  80125e:	68 18 19 80 00       	push   $0x801918
  801263:	e8 8b f3 ff ff       	call   8005f3 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801268:	8b 45 08             	mov    0x8(%ebp),%eax
  80126b:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  801270:	c9                   	leave  
  801271:	c3                   	ret    
  801272:	66 90                	xchg   %ax,%ax
  801274:	66 90                	xchg   %ax,%ax
  801276:	66 90                	xchg   %ax,%ax
  801278:	66 90                	xchg   %ax,%ax
  80127a:	66 90                	xchg   %ax,%ax
  80127c:	66 90                	xchg   %ax,%ax
  80127e:	66 90                	xchg   %ax,%ax

00801280 <__udivdi3>:
  801280:	55                   	push   %ebp
  801281:	57                   	push   %edi
  801282:	56                   	push   %esi
  801283:	53                   	push   %ebx
  801284:	83 ec 1c             	sub    $0x1c,%esp
  801287:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80128b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80128f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801293:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801297:	85 f6                	test   %esi,%esi
  801299:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80129d:	89 ca                	mov    %ecx,%edx
  80129f:	89 f8                	mov    %edi,%eax
  8012a1:	75 3d                	jne    8012e0 <__udivdi3+0x60>
  8012a3:	39 cf                	cmp    %ecx,%edi
  8012a5:	0f 87 c5 00 00 00    	ja     801370 <__udivdi3+0xf0>
  8012ab:	85 ff                	test   %edi,%edi
  8012ad:	89 fd                	mov    %edi,%ebp
  8012af:	75 0b                	jne    8012bc <__udivdi3+0x3c>
  8012b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8012b6:	31 d2                	xor    %edx,%edx
  8012b8:	f7 f7                	div    %edi
  8012ba:	89 c5                	mov    %eax,%ebp
  8012bc:	89 c8                	mov    %ecx,%eax
  8012be:	31 d2                	xor    %edx,%edx
  8012c0:	f7 f5                	div    %ebp
  8012c2:	89 c1                	mov    %eax,%ecx
  8012c4:	89 d8                	mov    %ebx,%eax
  8012c6:	89 cf                	mov    %ecx,%edi
  8012c8:	f7 f5                	div    %ebp
  8012ca:	89 c3                	mov    %eax,%ebx
  8012cc:	89 d8                	mov    %ebx,%eax
  8012ce:	89 fa                	mov    %edi,%edx
  8012d0:	83 c4 1c             	add    $0x1c,%esp
  8012d3:	5b                   	pop    %ebx
  8012d4:	5e                   	pop    %esi
  8012d5:	5f                   	pop    %edi
  8012d6:	5d                   	pop    %ebp
  8012d7:	c3                   	ret    
  8012d8:	90                   	nop
  8012d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012e0:	39 ce                	cmp    %ecx,%esi
  8012e2:	77 74                	ja     801358 <__udivdi3+0xd8>
  8012e4:	0f bd fe             	bsr    %esi,%edi
  8012e7:	83 f7 1f             	xor    $0x1f,%edi
  8012ea:	0f 84 98 00 00 00    	je     801388 <__udivdi3+0x108>
  8012f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8012f5:	89 f9                	mov    %edi,%ecx
  8012f7:	89 c5                	mov    %eax,%ebp
  8012f9:	29 fb                	sub    %edi,%ebx
  8012fb:	d3 e6                	shl    %cl,%esi
  8012fd:	89 d9                	mov    %ebx,%ecx
  8012ff:	d3 ed                	shr    %cl,%ebp
  801301:	89 f9                	mov    %edi,%ecx
  801303:	d3 e0                	shl    %cl,%eax
  801305:	09 ee                	or     %ebp,%esi
  801307:	89 d9                	mov    %ebx,%ecx
  801309:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80130d:	89 d5                	mov    %edx,%ebp
  80130f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801313:	d3 ed                	shr    %cl,%ebp
  801315:	89 f9                	mov    %edi,%ecx
  801317:	d3 e2                	shl    %cl,%edx
  801319:	89 d9                	mov    %ebx,%ecx
  80131b:	d3 e8                	shr    %cl,%eax
  80131d:	09 c2                	or     %eax,%edx
  80131f:	89 d0                	mov    %edx,%eax
  801321:	89 ea                	mov    %ebp,%edx
  801323:	f7 f6                	div    %esi
  801325:	89 d5                	mov    %edx,%ebp
  801327:	89 c3                	mov    %eax,%ebx
  801329:	f7 64 24 0c          	mull   0xc(%esp)
  80132d:	39 d5                	cmp    %edx,%ebp
  80132f:	72 10                	jb     801341 <__udivdi3+0xc1>
  801331:	8b 74 24 08          	mov    0x8(%esp),%esi
  801335:	89 f9                	mov    %edi,%ecx
  801337:	d3 e6                	shl    %cl,%esi
  801339:	39 c6                	cmp    %eax,%esi
  80133b:	73 07                	jae    801344 <__udivdi3+0xc4>
  80133d:	39 d5                	cmp    %edx,%ebp
  80133f:	75 03                	jne    801344 <__udivdi3+0xc4>
  801341:	83 eb 01             	sub    $0x1,%ebx
  801344:	31 ff                	xor    %edi,%edi
  801346:	89 d8                	mov    %ebx,%eax
  801348:	89 fa                	mov    %edi,%edx
  80134a:	83 c4 1c             	add    $0x1c,%esp
  80134d:	5b                   	pop    %ebx
  80134e:	5e                   	pop    %esi
  80134f:	5f                   	pop    %edi
  801350:	5d                   	pop    %ebp
  801351:	c3                   	ret    
  801352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801358:	31 ff                	xor    %edi,%edi
  80135a:	31 db                	xor    %ebx,%ebx
  80135c:	89 d8                	mov    %ebx,%eax
  80135e:	89 fa                	mov    %edi,%edx
  801360:	83 c4 1c             	add    $0x1c,%esp
  801363:	5b                   	pop    %ebx
  801364:	5e                   	pop    %esi
  801365:	5f                   	pop    %edi
  801366:	5d                   	pop    %ebp
  801367:	c3                   	ret    
  801368:	90                   	nop
  801369:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801370:	89 d8                	mov    %ebx,%eax
  801372:	f7 f7                	div    %edi
  801374:	31 ff                	xor    %edi,%edi
  801376:	89 c3                	mov    %eax,%ebx
  801378:	89 d8                	mov    %ebx,%eax
  80137a:	89 fa                	mov    %edi,%edx
  80137c:	83 c4 1c             	add    $0x1c,%esp
  80137f:	5b                   	pop    %ebx
  801380:	5e                   	pop    %esi
  801381:	5f                   	pop    %edi
  801382:	5d                   	pop    %ebp
  801383:	c3                   	ret    
  801384:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801388:	39 ce                	cmp    %ecx,%esi
  80138a:	72 0c                	jb     801398 <__udivdi3+0x118>
  80138c:	31 db                	xor    %ebx,%ebx
  80138e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801392:	0f 87 34 ff ff ff    	ja     8012cc <__udivdi3+0x4c>
  801398:	bb 01 00 00 00       	mov    $0x1,%ebx
  80139d:	e9 2a ff ff ff       	jmp    8012cc <__udivdi3+0x4c>
  8013a2:	66 90                	xchg   %ax,%ax
  8013a4:	66 90                	xchg   %ax,%ax
  8013a6:	66 90                	xchg   %ax,%ax
  8013a8:	66 90                	xchg   %ax,%ax
  8013aa:	66 90                	xchg   %ax,%ax
  8013ac:	66 90                	xchg   %ax,%ax
  8013ae:	66 90                	xchg   %ax,%ax

008013b0 <__umoddi3>:
  8013b0:	55                   	push   %ebp
  8013b1:	57                   	push   %edi
  8013b2:	56                   	push   %esi
  8013b3:	53                   	push   %ebx
  8013b4:	83 ec 1c             	sub    $0x1c,%esp
  8013b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8013bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8013bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8013c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013c7:	85 d2                	test   %edx,%edx
  8013c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8013cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013d1:	89 f3                	mov    %esi,%ebx
  8013d3:	89 3c 24             	mov    %edi,(%esp)
  8013d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013da:	75 1c                	jne    8013f8 <__umoddi3+0x48>
  8013dc:	39 f7                	cmp    %esi,%edi
  8013de:	76 50                	jbe    801430 <__umoddi3+0x80>
  8013e0:	89 c8                	mov    %ecx,%eax
  8013e2:	89 f2                	mov    %esi,%edx
  8013e4:	f7 f7                	div    %edi
  8013e6:	89 d0                	mov    %edx,%eax
  8013e8:	31 d2                	xor    %edx,%edx
  8013ea:	83 c4 1c             	add    $0x1c,%esp
  8013ed:	5b                   	pop    %ebx
  8013ee:	5e                   	pop    %esi
  8013ef:	5f                   	pop    %edi
  8013f0:	5d                   	pop    %ebp
  8013f1:	c3                   	ret    
  8013f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013f8:	39 f2                	cmp    %esi,%edx
  8013fa:	89 d0                	mov    %edx,%eax
  8013fc:	77 52                	ja     801450 <__umoddi3+0xa0>
  8013fe:	0f bd ea             	bsr    %edx,%ebp
  801401:	83 f5 1f             	xor    $0x1f,%ebp
  801404:	75 5a                	jne    801460 <__umoddi3+0xb0>
  801406:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80140a:	0f 82 e0 00 00 00    	jb     8014f0 <__umoddi3+0x140>
  801410:	39 0c 24             	cmp    %ecx,(%esp)
  801413:	0f 86 d7 00 00 00    	jbe    8014f0 <__umoddi3+0x140>
  801419:	8b 44 24 08          	mov    0x8(%esp),%eax
  80141d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801421:	83 c4 1c             	add    $0x1c,%esp
  801424:	5b                   	pop    %ebx
  801425:	5e                   	pop    %esi
  801426:	5f                   	pop    %edi
  801427:	5d                   	pop    %ebp
  801428:	c3                   	ret    
  801429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801430:	85 ff                	test   %edi,%edi
  801432:	89 fd                	mov    %edi,%ebp
  801434:	75 0b                	jne    801441 <__umoddi3+0x91>
  801436:	b8 01 00 00 00       	mov    $0x1,%eax
  80143b:	31 d2                	xor    %edx,%edx
  80143d:	f7 f7                	div    %edi
  80143f:	89 c5                	mov    %eax,%ebp
  801441:	89 f0                	mov    %esi,%eax
  801443:	31 d2                	xor    %edx,%edx
  801445:	f7 f5                	div    %ebp
  801447:	89 c8                	mov    %ecx,%eax
  801449:	f7 f5                	div    %ebp
  80144b:	89 d0                	mov    %edx,%eax
  80144d:	eb 99                	jmp    8013e8 <__umoddi3+0x38>
  80144f:	90                   	nop
  801450:	89 c8                	mov    %ecx,%eax
  801452:	89 f2                	mov    %esi,%edx
  801454:	83 c4 1c             	add    $0x1c,%esp
  801457:	5b                   	pop    %ebx
  801458:	5e                   	pop    %esi
  801459:	5f                   	pop    %edi
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    
  80145c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801460:	8b 34 24             	mov    (%esp),%esi
  801463:	bf 20 00 00 00       	mov    $0x20,%edi
  801468:	89 e9                	mov    %ebp,%ecx
  80146a:	29 ef                	sub    %ebp,%edi
  80146c:	d3 e0                	shl    %cl,%eax
  80146e:	89 f9                	mov    %edi,%ecx
  801470:	89 f2                	mov    %esi,%edx
  801472:	d3 ea                	shr    %cl,%edx
  801474:	89 e9                	mov    %ebp,%ecx
  801476:	09 c2                	or     %eax,%edx
  801478:	89 d8                	mov    %ebx,%eax
  80147a:	89 14 24             	mov    %edx,(%esp)
  80147d:	89 f2                	mov    %esi,%edx
  80147f:	d3 e2                	shl    %cl,%edx
  801481:	89 f9                	mov    %edi,%ecx
  801483:	89 54 24 04          	mov    %edx,0x4(%esp)
  801487:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80148b:	d3 e8                	shr    %cl,%eax
  80148d:	89 e9                	mov    %ebp,%ecx
  80148f:	89 c6                	mov    %eax,%esi
  801491:	d3 e3                	shl    %cl,%ebx
  801493:	89 f9                	mov    %edi,%ecx
  801495:	89 d0                	mov    %edx,%eax
  801497:	d3 e8                	shr    %cl,%eax
  801499:	89 e9                	mov    %ebp,%ecx
  80149b:	09 d8                	or     %ebx,%eax
  80149d:	89 d3                	mov    %edx,%ebx
  80149f:	89 f2                	mov    %esi,%edx
  8014a1:	f7 34 24             	divl   (%esp)
  8014a4:	89 d6                	mov    %edx,%esi
  8014a6:	d3 e3                	shl    %cl,%ebx
  8014a8:	f7 64 24 04          	mull   0x4(%esp)
  8014ac:	39 d6                	cmp    %edx,%esi
  8014ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014b2:	89 d1                	mov    %edx,%ecx
  8014b4:	89 c3                	mov    %eax,%ebx
  8014b6:	72 08                	jb     8014c0 <__umoddi3+0x110>
  8014b8:	75 11                	jne    8014cb <__umoddi3+0x11b>
  8014ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8014be:	73 0b                	jae    8014cb <__umoddi3+0x11b>
  8014c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8014c4:	1b 14 24             	sbb    (%esp),%edx
  8014c7:	89 d1                	mov    %edx,%ecx
  8014c9:	89 c3                	mov    %eax,%ebx
  8014cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8014cf:	29 da                	sub    %ebx,%edx
  8014d1:	19 ce                	sbb    %ecx,%esi
  8014d3:	89 f9                	mov    %edi,%ecx
  8014d5:	89 f0                	mov    %esi,%eax
  8014d7:	d3 e0                	shl    %cl,%eax
  8014d9:	89 e9                	mov    %ebp,%ecx
  8014db:	d3 ea                	shr    %cl,%edx
  8014dd:	89 e9                	mov    %ebp,%ecx
  8014df:	d3 ee                	shr    %cl,%esi
  8014e1:	09 d0                	or     %edx,%eax
  8014e3:	89 f2                	mov    %esi,%edx
  8014e5:	83 c4 1c             	add    $0x1c,%esp
  8014e8:	5b                   	pop    %ebx
  8014e9:	5e                   	pop    %esi
  8014ea:	5f                   	pop    %edi
  8014eb:	5d                   	pop    %ebp
  8014ec:	c3                   	ret    
  8014ed:	8d 76 00             	lea    0x0(%esi),%esi
  8014f0:	29 f9                	sub    %edi,%ecx
  8014f2:	19 d6                	sbb    %edx,%esi
  8014f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014fc:	e9 18 ff ff ff       	jmp    801419 <__umoddi3+0x69>
