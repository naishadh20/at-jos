
obj/user/sendpage:     file format elf32-i386


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
  80002c:	e8 68 01 00 00       	call   800199 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 c9 0d 00 00       	call   800e07 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9f 00 00 00    	jne    8000e8 <umain+0xb5>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 d9 0d 00 00       	call   800e35 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 80 11 80 00       	push   $0x801180
  80006c:	e8 1d 02 00 00       	call   80028e <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 20 80 00    	pushl  0x802004
  80007a:	e8 9d 07 00 00       	call   80081c <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 20 80 00    	pushl  0x802004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 92 08 00 00       	call   800925 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 94 11 80 00       	push   $0x801194
  8000a2:	e8 e7 01 00 00       	call   80028e <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 20 80 00    	pushl  0x802000
  8000b3:	e8 64 07 00 00       	call   80081c <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 20 80 00    	pushl  0x802000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 80 09 00 00       	call   800a4f <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 6c 0d 00 00       	call   800e4c <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 58 0b 00 00       	call   800c58 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 20 80 00    	pushl  0x802004
  800109:	e8 0e 07 00 00       	call   80081c <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 20 80 00    	pushl  0x802004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 2a 09 00 00       	call   800a4f <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 16 0d 00 00       	call   800e4c <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 ec 0c 00 00       	call   800e35 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 80 11 80 00       	push   $0x801180
  800159:	e8 30 01 00 00       	call   80028e <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 20 80 00    	pushl  0x802000
  800167:	e8 b0 06 00 00       	call   80081c <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 20 80 00    	pushl  0x802000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 a5 07 00 00       	call   800925 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 b4 11 80 00       	push   $0x8011b4
  80018f:	e8 fa 00 00 00       	call   80028e <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
	return;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001a4:	c7 05 0c 20 80 00 00 	movl   $0x0,0x80200c
  8001ab:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  8001ae:	e8 67 0a 00 00       	call   800c1a <sys_getenvid>
  8001b3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001b8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001bb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001c0:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001c5:	85 db                	test   %ebx,%ebx
  8001c7:	7e 07                	jle    8001d0 <libmain+0x37>
		binaryname = argv[0];
  8001c9:	8b 06                	mov    (%esi),%eax
  8001cb:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  8001d0:	83 ec 08             	sub    $0x8,%esp
  8001d3:	56                   	push   %esi
  8001d4:	53                   	push   %ebx
  8001d5:	e8 59 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001da:	e8 0a 00 00 00       	call   8001e9 <exit>
}
  8001df:	83 c4 10             	add    $0x10,%esp
  8001e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e5:	5b                   	pop    %ebx
  8001e6:	5e                   	pop    %esi
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    

008001e9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8001ef:	6a 00                	push   $0x0
  8001f1:	e8 e3 09 00 00       	call   800bd9 <sys_env_destroy>
}
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	c9                   	leave  
  8001fa:	c3                   	ret    

008001fb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	53                   	push   %ebx
  8001ff:	83 ec 04             	sub    $0x4,%esp
  800202:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800205:	8b 13                	mov    (%ebx),%edx
  800207:	8d 42 01             	lea    0x1(%edx),%eax
  80020a:	89 03                	mov    %eax,(%ebx)
  80020c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800213:	3d ff 00 00 00       	cmp    $0xff,%eax
  800218:	75 1a                	jne    800234 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80021a:	83 ec 08             	sub    $0x8,%esp
  80021d:	68 ff 00 00 00       	push   $0xff
  800222:	8d 43 08             	lea    0x8(%ebx),%eax
  800225:	50                   	push   %eax
  800226:	e8 71 09 00 00       	call   800b9c <sys_cputs>
		b->idx = 0;
  80022b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800231:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800234:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800238:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80023b:	c9                   	leave  
  80023c:	c3                   	ret    

0080023d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800246:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024d:	00 00 00 
	b.cnt = 0;
  800250:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800257:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800266:	50                   	push   %eax
  800267:	68 fb 01 80 00       	push   $0x8001fb
  80026c:	e8 54 01 00 00       	call   8003c5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800271:	83 c4 08             	add    $0x8,%esp
  800274:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80027a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800280:	50                   	push   %eax
  800281:	e8 16 09 00 00       	call   800b9c <sys_cputs>

	return b.cnt;
}
  800286:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028c:	c9                   	leave  
  80028d:	c3                   	ret    

0080028e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800294:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800297:	50                   	push   %eax
  800298:	ff 75 08             	pushl  0x8(%ebp)
  80029b:	e8 9d ff ff ff       	call   80023d <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a0:	c9                   	leave  
  8002a1:	c3                   	ret    

008002a2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	57                   	push   %edi
  8002a6:	56                   	push   %esi
  8002a7:	53                   	push   %ebx
  8002a8:	83 ec 1c             	sub    $0x1c,%esp
  8002ab:	89 c7                	mov    %eax,%edi
  8002ad:	89 d6                	mov    %edx,%esi
  8002af:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002c9:	39 d3                	cmp    %edx,%ebx
  8002cb:	72 05                	jb     8002d2 <printnum+0x30>
  8002cd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d0:	77 45                	ja     800317 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d2:	83 ec 0c             	sub    $0xc,%esp
  8002d5:	ff 75 18             	pushl  0x18(%ebp)
  8002d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8002db:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002de:	53                   	push   %ebx
  8002df:	ff 75 10             	pushl  0x10(%ebp)
  8002e2:	83 ec 08             	sub    $0x8,%esp
  8002e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002eb:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f1:	e8 fa 0b 00 00       	call   800ef0 <__udivdi3>
  8002f6:	83 c4 18             	add    $0x18,%esp
  8002f9:	52                   	push   %edx
  8002fa:	50                   	push   %eax
  8002fb:	89 f2                	mov    %esi,%edx
  8002fd:	89 f8                	mov    %edi,%eax
  8002ff:	e8 9e ff ff ff       	call   8002a2 <printnum>
  800304:	83 c4 20             	add    $0x20,%esp
  800307:	eb 18                	jmp    800321 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	56                   	push   %esi
  80030d:	ff 75 18             	pushl  0x18(%ebp)
  800310:	ff d7                	call   *%edi
  800312:	83 c4 10             	add    $0x10,%esp
  800315:	eb 03                	jmp    80031a <printnum+0x78>
  800317:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80031a:	83 eb 01             	sub    $0x1,%ebx
  80031d:	85 db                	test   %ebx,%ebx
  80031f:	7f e8                	jg     800309 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800321:	83 ec 08             	sub    $0x8,%esp
  800324:	56                   	push   %esi
  800325:	83 ec 04             	sub    $0x4,%esp
  800328:	ff 75 e4             	pushl  -0x1c(%ebp)
  80032b:	ff 75 e0             	pushl  -0x20(%ebp)
  80032e:	ff 75 dc             	pushl  -0x24(%ebp)
  800331:	ff 75 d8             	pushl  -0x28(%ebp)
  800334:	e8 e7 0c 00 00       	call   801020 <__umoddi3>
  800339:	83 c4 14             	add    $0x14,%esp
  80033c:	0f be 80 2c 12 80 00 	movsbl 0x80122c(%eax),%eax
  800343:	50                   	push   %eax
  800344:	ff d7                	call   *%edi
}
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034c:	5b                   	pop    %ebx
  80034d:	5e                   	pop    %esi
  80034e:	5f                   	pop    %edi
  80034f:	5d                   	pop    %ebp
  800350:	c3                   	ret    

00800351 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800354:	83 fa 01             	cmp    $0x1,%edx
  800357:	7e 0e                	jle    800367 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80035e:	89 08                	mov    %ecx,(%eax)
  800360:	8b 02                	mov    (%edx),%eax
  800362:	8b 52 04             	mov    0x4(%edx),%edx
  800365:	eb 22                	jmp    800389 <getuint+0x38>
	else if (lflag)
  800367:	85 d2                	test   %edx,%edx
  800369:	74 10                	je     80037b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80036b:	8b 10                	mov    (%eax),%edx
  80036d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800370:	89 08                	mov    %ecx,(%eax)
  800372:	8b 02                	mov    (%edx),%eax
  800374:	ba 00 00 00 00       	mov    $0x0,%edx
  800379:	eb 0e                	jmp    800389 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80037b:	8b 10                	mov    (%eax),%edx
  80037d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800380:	89 08                	mov    %ecx,(%eax)
  800382:	8b 02                	mov    (%edx),%eax
  800384:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800389:	5d                   	pop    %ebp
  80038a:	c3                   	ret    

0080038b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
  80038e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800391:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800395:	8b 10                	mov    (%eax),%edx
  800397:	3b 50 04             	cmp    0x4(%eax),%edx
  80039a:	73 0a                	jae    8003a6 <sprintputch+0x1b>
		*b->buf++ = ch;
  80039c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80039f:	89 08                	mov    %ecx,(%eax)
  8003a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a4:	88 02                	mov    %al,(%edx)
}
  8003a6:	5d                   	pop    %ebp
  8003a7:	c3                   	ret    

008003a8 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003ae:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003b1:	50                   	push   %eax
  8003b2:	ff 75 10             	pushl  0x10(%ebp)
  8003b5:	ff 75 0c             	pushl  0xc(%ebp)
  8003b8:	ff 75 08             	pushl  0x8(%ebp)
  8003bb:	e8 05 00 00 00       	call   8003c5 <vprintfmt>
	va_end(ap);
}
  8003c0:	83 c4 10             	add    $0x10,%esp
  8003c3:	c9                   	leave  
  8003c4:	c3                   	ret    

008003c5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	57                   	push   %edi
  8003c9:	56                   	push   %esi
  8003ca:	53                   	push   %ebx
  8003cb:	83 ec 2c             	sub    $0x2c,%esp
  8003ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8003d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003d4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003d7:	eb 12                	jmp    8003eb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d9:	85 c0                	test   %eax,%eax
  8003db:	0f 84 cb 03 00 00    	je     8007ac <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  8003e1:	83 ec 08             	sub    $0x8,%esp
  8003e4:	53                   	push   %ebx
  8003e5:	50                   	push   %eax
  8003e6:	ff d6                	call   *%esi
  8003e8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003eb:	83 c7 01             	add    $0x1,%edi
  8003ee:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003f2:	83 f8 25             	cmp    $0x25,%eax
  8003f5:	75 e2                	jne    8003d9 <vprintfmt+0x14>
  8003f7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003fb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800402:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800409:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800410:	ba 00 00 00 00       	mov    $0x0,%edx
  800415:	eb 07                	jmp    80041e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80041a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	8d 47 01             	lea    0x1(%edi),%eax
  800421:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800424:	0f b6 07             	movzbl (%edi),%eax
  800427:	0f b6 c8             	movzbl %al,%ecx
  80042a:	83 e8 23             	sub    $0x23,%eax
  80042d:	3c 55                	cmp    $0x55,%al
  80042f:	0f 87 5c 03 00 00    	ja     800791 <vprintfmt+0x3cc>
  800435:	0f b6 c0             	movzbl %al,%eax
  800438:	ff 24 85 00 13 80 00 	jmp    *0x801300(,%eax,4)
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800442:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800446:	eb d6                	jmp    80041e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044b:	b8 00 00 00 00       	mov    $0x0,%eax
  800450:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800453:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800456:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80045a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80045d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800460:	83 fa 09             	cmp    $0x9,%edx
  800463:	77 39                	ja     80049e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800465:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800468:	eb e9                	jmp    800453 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80046a:	8b 45 14             	mov    0x14(%ebp),%eax
  80046d:	8d 48 04             	lea    0x4(%eax),%ecx
  800470:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800473:	8b 00                	mov    (%eax),%eax
  800475:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80047b:	eb 27                	jmp    8004a4 <vprintfmt+0xdf>
  80047d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800480:	85 c0                	test   %eax,%eax
  800482:	b9 00 00 00 00       	mov    $0x0,%ecx
  800487:	0f 49 c8             	cmovns %eax,%ecx
  80048a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800490:	eb 8c                	jmp    80041e <vprintfmt+0x59>
  800492:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800495:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80049c:	eb 80                	jmp    80041e <vprintfmt+0x59>
  80049e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004a1:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8004a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a8:	0f 89 70 ff ff ff    	jns    80041e <vprintfmt+0x59>
				width = precision, precision = -1;
  8004ae:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b4:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8004bb:	e9 5e ff ff ff       	jmp    80041e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004c6:	e9 53 ff ff ff       	jmp    80041e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ce:	8d 50 04             	lea    0x4(%eax),%edx
  8004d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	53                   	push   %ebx
  8004d8:	ff 30                	pushl  (%eax)
  8004da:	ff d6                	call   *%esi
			break;
  8004dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004e2:	e9 04 ff ff ff       	jmp    8003eb <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ea:	8d 50 04             	lea    0x4(%eax),%edx
  8004ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f0:	8b 00                	mov    (%eax),%eax
  8004f2:	99                   	cltd   
  8004f3:	31 d0                	xor    %edx,%eax
  8004f5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f7:	83 f8 09             	cmp    $0x9,%eax
  8004fa:	7f 0b                	jg     800507 <vprintfmt+0x142>
  8004fc:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  800503:	85 d2                	test   %edx,%edx
  800505:	75 18                	jne    80051f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800507:	50                   	push   %eax
  800508:	68 44 12 80 00       	push   $0x801244
  80050d:	53                   	push   %ebx
  80050e:	56                   	push   %esi
  80050f:	e8 94 fe ff ff       	call   8003a8 <printfmt>
  800514:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800517:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80051a:	e9 cc fe ff ff       	jmp    8003eb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80051f:	52                   	push   %edx
  800520:	68 4d 12 80 00       	push   $0x80124d
  800525:	53                   	push   %ebx
  800526:	56                   	push   %esi
  800527:	e8 7c fe ff ff       	call   8003a8 <printfmt>
  80052c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800532:	e9 b4 fe ff ff       	jmp    8003eb <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8d 50 04             	lea    0x4(%eax),%edx
  80053d:	89 55 14             	mov    %edx,0x14(%ebp)
  800540:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800542:	85 ff                	test   %edi,%edi
  800544:	b8 3d 12 80 00       	mov    $0x80123d,%eax
  800549:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80054c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800550:	0f 8e 94 00 00 00    	jle    8005ea <vprintfmt+0x225>
  800556:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80055a:	0f 84 98 00 00 00    	je     8005f8 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	ff 75 c8             	pushl  -0x38(%ebp)
  800566:	57                   	push   %edi
  800567:	e8 c8 02 00 00       	call   800834 <strnlen>
  80056c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056f:	29 c1                	sub    %eax,%ecx
  800571:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800574:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800577:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80057b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800581:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	eb 0f                	jmp    800594 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	53                   	push   %ebx
  800589:	ff 75 e0             	pushl  -0x20(%ebp)
  80058c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058e:	83 ef 01             	sub    $0x1,%edi
  800591:	83 c4 10             	add    $0x10,%esp
  800594:	85 ff                	test   %edi,%edi
  800596:	7f ed                	jg     800585 <vprintfmt+0x1c0>
  800598:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80059b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80059e:	85 c9                	test   %ecx,%ecx
  8005a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a5:	0f 49 c1             	cmovns %ecx,%eax
  8005a8:	29 c1                	sub    %eax,%ecx
  8005aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ad:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8005b0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b3:	89 cb                	mov    %ecx,%ebx
  8005b5:	eb 4d                	jmp    800604 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005bb:	74 1b                	je     8005d8 <vprintfmt+0x213>
  8005bd:	0f be c0             	movsbl %al,%eax
  8005c0:	83 e8 20             	sub    $0x20,%eax
  8005c3:	83 f8 5e             	cmp    $0x5e,%eax
  8005c6:	76 10                	jbe    8005d8 <vprintfmt+0x213>
					putch('?', putdat);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	ff 75 0c             	pushl  0xc(%ebp)
  8005ce:	6a 3f                	push   $0x3f
  8005d0:	ff 55 08             	call   *0x8(%ebp)
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	eb 0d                	jmp    8005e5 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8005d8:	83 ec 08             	sub    $0x8,%esp
  8005db:	ff 75 0c             	pushl  0xc(%ebp)
  8005de:	52                   	push   %edx
  8005df:	ff 55 08             	call   *0x8(%ebp)
  8005e2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e5:	83 eb 01             	sub    $0x1,%ebx
  8005e8:	eb 1a                	jmp    800604 <vprintfmt+0x23f>
  8005ea:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ed:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8005f0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f6:	eb 0c                	jmp    800604 <vprintfmt+0x23f>
  8005f8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005fb:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8005fe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800601:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800604:	83 c7 01             	add    $0x1,%edi
  800607:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80060b:	0f be d0             	movsbl %al,%edx
  80060e:	85 d2                	test   %edx,%edx
  800610:	74 23                	je     800635 <vprintfmt+0x270>
  800612:	85 f6                	test   %esi,%esi
  800614:	78 a1                	js     8005b7 <vprintfmt+0x1f2>
  800616:	83 ee 01             	sub    $0x1,%esi
  800619:	79 9c                	jns    8005b7 <vprintfmt+0x1f2>
  80061b:	89 df                	mov    %ebx,%edi
  80061d:	8b 75 08             	mov    0x8(%ebp),%esi
  800620:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800623:	eb 18                	jmp    80063d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	6a 20                	push   $0x20
  80062b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062d:	83 ef 01             	sub    $0x1,%edi
  800630:	83 c4 10             	add    $0x10,%esp
  800633:	eb 08                	jmp    80063d <vprintfmt+0x278>
  800635:	89 df                	mov    %ebx,%edi
  800637:	8b 75 08             	mov    0x8(%ebp),%esi
  80063a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063d:	85 ff                	test   %edi,%edi
  80063f:	7f e4                	jg     800625 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800641:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800644:	e9 a2 fd ff ff       	jmp    8003eb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800649:	83 fa 01             	cmp    $0x1,%edx
  80064c:	7e 16                	jle    800664 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 50 08             	lea    0x8(%eax),%edx
  800654:	89 55 14             	mov    %edx,0x14(%ebp)
  800657:	8b 50 04             	mov    0x4(%eax),%edx
  80065a:	8b 00                	mov    (%eax),%eax
  80065c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80065f:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800662:	eb 32                	jmp    800696 <vprintfmt+0x2d1>
	else if (lflag)
  800664:	85 d2                	test   %edx,%edx
  800666:	74 18                	je     800680 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8d 50 04             	lea    0x4(%eax),%edx
  80066e:	89 55 14             	mov    %edx,0x14(%ebp)
  800671:	8b 00                	mov    (%eax),%eax
  800673:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800676:	89 c1                	mov    %eax,%ecx
  800678:	c1 f9 1f             	sar    $0x1f,%ecx
  80067b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80067e:	eb 16                	jmp    800696 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 04             	lea    0x4(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)
  800689:	8b 00                	mov    (%eax),%eax
  80068b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80068e:	89 c1                	mov    %eax,%ecx
  800690:	c1 f9 1f             	sar    $0x1f,%ecx
  800693:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800696:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800699:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80069c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a2:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a7:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006ab:	0f 89 a8 00 00 00    	jns    800759 <vprintfmt+0x394>
				putch('-', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	6a 2d                	push   $0x2d
  8006b7:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8006bc:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8006bf:	f7 d8                	neg    %eax
  8006c1:	83 d2 00             	adc    $0x0,%edx
  8006c4:	f7 da                	neg    %edx
  8006c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006cc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d4:	e9 80 00 00 00       	jmp    800759 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006d9:	8d 45 14             	lea    0x14(%ebp),%eax
  8006dc:	e8 70 fc ff ff       	call   800351 <getuint>
  8006e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8006e7:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8006ec:	eb 6b                	jmp    800759 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f1:	e8 5b fc ff ff       	call   800351 <getuint>
  8006f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  8006fc:	6a 04                	push   $0x4
  8006fe:	6a 03                	push   $0x3
  800700:	6a 01                	push   $0x1
  800702:	68 50 12 80 00       	push   $0x801250
  800707:	e8 82 fb ff ff       	call   80028e <cprintf>
			goto number;
  80070c:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  80070f:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  800714:	eb 43                	jmp    800759 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	53                   	push   %ebx
  80071a:	6a 30                	push   $0x30
  80071c:	ff d6                	call   *%esi
			putch('x', putdat);
  80071e:	83 c4 08             	add    $0x8,%esp
  800721:	53                   	push   %ebx
  800722:	6a 78                	push   $0x78
  800724:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8d 50 04             	lea    0x4(%eax),%edx
  80072c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80072f:	8b 00                	mov    (%eax),%eax
  800731:	ba 00 00 00 00       	mov    $0x0,%edx
  800736:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800739:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80073c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80073f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800744:	eb 13                	jmp    800759 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
  800749:	e8 03 fc ff ff       	call   800351 <getuint>
  80074e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800751:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800754:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800759:	83 ec 0c             	sub    $0xc,%esp
  80075c:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800760:	52                   	push   %edx
  800761:	ff 75 e0             	pushl  -0x20(%ebp)
  800764:	50                   	push   %eax
  800765:	ff 75 dc             	pushl  -0x24(%ebp)
  800768:	ff 75 d8             	pushl  -0x28(%ebp)
  80076b:	89 da                	mov    %ebx,%edx
  80076d:	89 f0                	mov    %esi,%eax
  80076f:	e8 2e fb ff ff       	call   8002a2 <printnum>

			break;
  800774:	83 c4 20             	add    $0x20,%esp
  800777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077a:	e9 6c fc ff ff       	jmp    8003eb <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80077f:	83 ec 08             	sub    $0x8,%esp
  800782:	53                   	push   %ebx
  800783:	51                   	push   %ecx
  800784:	ff d6                	call   *%esi
			break;
  800786:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800789:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80078c:	e9 5a fc ff ff       	jmp    8003eb <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800791:	83 ec 08             	sub    $0x8,%esp
  800794:	53                   	push   %ebx
  800795:	6a 25                	push   $0x25
  800797:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800799:	83 c4 10             	add    $0x10,%esp
  80079c:	eb 03                	jmp    8007a1 <vprintfmt+0x3dc>
  80079e:	83 ef 01             	sub    $0x1,%edi
  8007a1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007a5:	75 f7                	jne    80079e <vprintfmt+0x3d9>
  8007a7:	e9 3f fc ff ff       	jmp    8003eb <vprintfmt+0x26>
			break;
		}

	}

}
  8007ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007af:	5b                   	pop    %ebx
  8007b0:	5e                   	pop    %esi
  8007b1:	5f                   	pop    %edi
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 18             	sub    $0x18,%esp
  8007ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d1:	85 c0                	test   %eax,%eax
  8007d3:	74 26                	je     8007fb <vsnprintf+0x47>
  8007d5:	85 d2                	test   %edx,%edx
  8007d7:	7e 22                	jle    8007fb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d9:	ff 75 14             	pushl  0x14(%ebp)
  8007dc:	ff 75 10             	pushl  0x10(%ebp)
  8007df:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e2:	50                   	push   %eax
  8007e3:	68 8b 03 80 00       	push   $0x80038b
  8007e8:	e8 d8 fb ff ff       	call   8003c5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f6:	83 c4 10             	add    $0x10,%esp
  8007f9:	eb 05                	jmp    800800 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800808:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080b:	50                   	push   %eax
  80080c:	ff 75 10             	pushl  0x10(%ebp)
  80080f:	ff 75 0c             	pushl  0xc(%ebp)
  800812:	ff 75 08             	pushl  0x8(%ebp)
  800815:	e8 9a ff ff ff       	call   8007b4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80081a:	c9                   	leave  
  80081b:	c3                   	ret    

0080081c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800822:	b8 00 00 00 00       	mov    $0x0,%eax
  800827:	eb 03                	jmp    80082c <strlen+0x10>
		n++;
  800829:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80082c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800830:	75 f7                	jne    800829 <strlen+0xd>
		n++;
	return n;
}
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083d:	ba 00 00 00 00       	mov    $0x0,%edx
  800842:	eb 03                	jmp    800847 <strnlen+0x13>
		n++;
  800844:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800847:	39 c2                	cmp    %eax,%edx
  800849:	74 08                	je     800853 <strnlen+0x1f>
  80084b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80084f:	75 f3                	jne    800844 <strnlen+0x10>
  800851:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	53                   	push   %ebx
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085f:	89 c2                	mov    %eax,%edx
  800861:	83 c2 01             	add    $0x1,%edx
  800864:	83 c1 01             	add    $0x1,%ecx
  800867:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80086b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80086e:	84 db                	test   %bl,%bl
  800870:	75 ef                	jne    800861 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800872:	5b                   	pop    %ebx
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	53                   	push   %ebx
  800879:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80087c:	53                   	push   %ebx
  80087d:	e8 9a ff ff ff       	call   80081c <strlen>
  800882:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800885:	ff 75 0c             	pushl  0xc(%ebp)
  800888:	01 d8                	add    %ebx,%eax
  80088a:	50                   	push   %eax
  80088b:	e8 c5 ff ff ff       	call   800855 <strcpy>
	return dst;
}
  800890:	89 d8                	mov    %ebx,%eax
  800892:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800895:	c9                   	leave  
  800896:	c3                   	ret    

00800897 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	56                   	push   %esi
  80089b:	53                   	push   %ebx
  80089c:	8b 75 08             	mov    0x8(%ebp),%esi
  80089f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a2:	89 f3                	mov    %esi,%ebx
  8008a4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a7:	89 f2                	mov    %esi,%edx
  8008a9:	eb 0f                	jmp    8008ba <strncpy+0x23>
		*dst++ = *src;
  8008ab:	83 c2 01             	add    $0x1,%edx
  8008ae:	0f b6 01             	movzbl (%ecx),%eax
  8008b1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b4:	80 39 01             	cmpb   $0x1,(%ecx)
  8008b7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ba:	39 da                	cmp    %ebx,%edx
  8008bc:	75 ed                	jne    8008ab <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008be:	89 f0                	mov    %esi,%eax
  8008c0:	5b                   	pop    %ebx
  8008c1:	5e                   	pop    %esi
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	56                   	push   %esi
  8008c8:	53                   	push   %ebx
  8008c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cf:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d4:	85 d2                	test   %edx,%edx
  8008d6:	74 21                	je     8008f9 <strlcpy+0x35>
  8008d8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008dc:	89 f2                	mov    %esi,%edx
  8008de:	eb 09                	jmp    8008e9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008e0:	83 c2 01             	add    $0x1,%edx
  8008e3:	83 c1 01             	add    $0x1,%ecx
  8008e6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008e9:	39 c2                	cmp    %eax,%edx
  8008eb:	74 09                	je     8008f6 <strlcpy+0x32>
  8008ed:	0f b6 19             	movzbl (%ecx),%ebx
  8008f0:	84 db                	test   %bl,%bl
  8008f2:	75 ec                	jne    8008e0 <strlcpy+0x1c>
  8008f4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008f6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f9:	29 f0                	sub    %esi,%eax
}
  8008fb:	5b                   	pop    %ebx
  8008fc:	5e                   	pop    %esi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800905:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800908:	eb 06                	jmp    800910 <strcmp+0x11>
		p++, q++;
  80090a:	83 c1 01             	add    $0x1,%ecx
  80090d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800910:	0f b6 01             	movzbl (%ecx),%eax
  800913:	84 c0                	test   %al,%al
  800915:	74 04                	je     80091b <strcmp+0x1c>
  800917:	3a 02                	cmp    (%edx),%al
  800919:	74 ef                	je     80090a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80091b:	0f b6 c0             	movzbl %al,%eax
  80091e:	0f b6 12             	movzbl (%edx),%edx
  800921:	29 d0                	sub    %edx,%eax
}
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	53                   	push   %ebx
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092f:	89 c3                	mov    %eax,%ebx
  800931:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800934:	eb 06                	jmp    80093c <strncmp+0x17>
		n--, p++, q++;
  800936:	83 c0 01             	add    $0x1,%eax
  800939:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80093c:	39 d8                	cmp    %ebx,%eax
  80093e:	74 15                	je     800955 <strncmp+0x30>
  800940:	0f b6 08             	movzbl (%eax),%ecx
  800943:	84 c9                	test   %cl,%cl
  800945:	74 04                	je     80094b <strncmp+0x26>
  800947:	3a 0a                	cmp    (%edx),%cl
  800949:	74 eb                	je     800936 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80094b:	0f b6 00             	movzbl (%eax),%eax
  80094e:	0f b6 12             	movzbl (%edx),%edx
  800951:	29 d0                	sub    %edx,%eax
  800953:	eb 05                	jmp    80095a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800955:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80095a:	5b                   	pop    %ebx
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800967:	eb 07                	jmp    800970 <strchr+0x13>
		if (*s == c)
  800969:	38 ca                	cmp    %cl,%dl
  80096b:	74 0f                	je     80097c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80096d:	83 c0 01             	add    $0x1,%eax
  800970:	0f b6 10             	movzbl (%eax),%edx
  800973:	84 d2                	test   %dl,%dl
  800975:	75 f2                	jne    800969 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800977:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800988:	eb 03                	jmp    80098d <strfind+0xf>
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800990:	38 ca                	cmp    %cl,%dl
  800992:	74 04                	je     800998 <strfind+0x1a>
  800994:	84 d2                	test   %dl,%dl
  800996:	75 f2                	jne    80098a <strfind+0xc>
			break;
	return (char *) s;
}
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	57                   	push   %edi
  80099e:	56                   	push   %esi
  80099f:	53                   	push   %ebx
  8009a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a6:	85 c9                	test   %ecx,%ecx
  8009a8:	74 36                	je     8009e0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009aa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b0:	75 28                	jne    8009da <memset+0x40>
  8009b2:	f6 c1 03             	test   $0x3,%cl
  8009b5:	75 23                	jne    8009da <memset+0x40>
		c &= 0xFF;
  8009b7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009bb:	89 d3                	mov    %edx,%ebx
  8009bd:	c1 e3 08             	shl    $0x8,%ebx
  8009c0:	89 d6                	mov    %edx,%esi
  8009c2:	c1 e6 18             	shl    $0x18,%esi
  8009c5:	89 d0                	mov    %edx,%eax
  8009c7:	c1 e0 10             	shl    $0x10,%eax
  8009ca:	09 f0                	or     %esi,%eax
  8009cc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009ce:	89 d8                	mov    %ebx,%eax
  8009d0:	09 d0                	or     %edx,%eax
  8009d2:	c1 e9 02             	shr    $0x2,%ecx
  8009d5:	fc                   	cld    
  8009d6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d8:	eb 06                	jmp    8009e0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009dd:	fc                   	cld    
  8009de:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e0:	89 f8                	mov    %edi,%eax
  8009e2:	5b                   	pop    %ebx
  8009e3:	5e                   	pop    %esi
  8009e4:	5f                   	pop    %edi
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f5:	39 c6                	cmp    %eax,%esi
  8009f7:	73 35                	jae    800a2e <memmove+0x47>
  8009f9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009fc:	39 d0                	cmp    %edx,%eax
  8009fe:	73 2e                	jae    800a2e <memmove+0x47>
		s += n;
		d += n;
  800a00:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a03:	89 d6                	mov    %edx,%esi
  800a05:	09 fe                	or     %edi,%esi
  800a07:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a0d:	75 13                	jne    800a22 <memmove+0x3b>
  800a0f:	f6 c1 03             	test   $0x3,%cl
  800a12:	75 0e                	jne    800a22 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a14:	83 ef 04             	sub    $0x4,%edi
  800a17:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1a:	c1 e9 02             	shr    $0x2,%ecx
  800a1d:	fd                   	std    
  800a1e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a20:	eb 09                	jmp    800a2b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a22:	83 ef 01             	sub    $0x1,%edi
  800a25:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a28:	fd                   	std    
  800a29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a2b:	fc                   	cld    
  800a2c:	eb 1d                	jmp    800a4b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2e:	89 f2                	mov    %esi,%edx
  800a30:	09 c2                	or     %eax,%edx
  800a32:	f6 c2 03             	test   $0x3,%dl
  800a35:	75 0f                	jne    800a46 <memmove+0x5f>
  800a37:	f6 c1 03             	test   $0x3,%cl
  800a3a:	75 0a                	jne    800a46 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a3c:	c1 e9 02             	shr    $0x2,%ecx
  800a3f:	89 c7                	mov    %eax,%edi
  800a41:	fc                   	cld    
  800a42:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a44:	eb 05                	jmp    800a4b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a46:	89 c7                	mov    %eax,%edi
  800a48:	fc                   	cld    
  800a49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a4b:	5e                   	pop    %esi
  800a4c:	5f                   	pop    %edi
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a52:	ff 75 10             	pushl  0x10(%ebp)
  800a55:	ff 75 0c             	pushl  0xc(%ebp)
  800a58:	ff 75 08             	pushl  0x8(%ebp)
  800a5b:	e8 87 ff ff ff       	call   8009e7 <memmove>
}
  800a60:	c9                   	leave  
  800a61:	c3                   	ret    

00800a62 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	56                   	push   %esi
  800a66:	53                   	push   %ebx
  800a67:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6d:	89 c6                	mov    %eax,%esi
  800a6f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a72:	eb 1a                	jmp    800a8e <memcmp+0x2c>
		if (*s1 != *s2)
  800a74:	0f b6 08             	movzbl (%eax),%ecx
  800a77:	0f b6 1a             	movzbl (%edx),%ebx
  800a7a:	38 d9                	cmp    %bl,%cl
  800a7c:	74 0a                	je     800a88 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a7e:	0f b6 c1             	movzbl %cl,%eax
  800a81:	0f b6 db             	movzbl %bl,%ebx
  800a84:	29 d8                	sub    %ebx,%eax
  800a86:	eb 0f                	jmp    800a97 <memcmp+0x35>
		s1++, s2++;
  800a88:	83 c0 01             	add    $0x1,%eax
  800a8b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a8e:	39 f0                	cmp    %esi,%eax
  800a90:	75 e2                	jne    800a74 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a97:	5b                   	pop    %ebx
  800a98:	5e                   	pop    %esi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	53                   	push   %ebx
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aa2:	89 c1                	mov    %eax,%ecx
  800aa4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aa7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aab:	eb 0a                	jmp    800ab7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aad:	0f b6 10             	movzbl (%eax),%edx
  800ab0:	39 da                	cmp    %ebx,%edx
  800ab2:	74 07                	je     800abb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab4:	83 c0 01             	add    $0x1,%eax
  800ab7:	39 c8                	cmp    %ecx,%eax
  800ab9:	72 f2                	jb     800aad <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800abb:	5b                   	pop    %ebx
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
  800ac4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aca:	eb 03                	jmp    800acf <strtol+0x11>
		s++;
  800acc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800acf:	0f b6 01             	movzbl (%ecx),%eax
  800ad2:	3c 20                	cmp    $0x20,%al
  800ad4:	74 f6                	je     800acc <strtol+0xe>
  800ad6:	3c 09                	cmp    $0x9,%al
  800ad8:	74 f2                	je     800acc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ada:	3c 2b                	cmp    $0x2b,%al
  800adc:	75 0a                	jne    800ae8 <strtol+0x2a>
		s++;
  800ade:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae6:	eb 11                	jmp    800af9 <strtol+0x3b>
  800ae8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800aed:	3c 2d                	cmp    $0x2d,%al
  800aef:	75 08                	jne    800af9 <strtol+0x3b>
		s++, neg = 1;
  800af1:	83 c1 01             	add    $0x1,%ecx
  800af4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aff:	75 15                	jne    800b16 <strtol+0x58>
  800b01:	80 39 30             	cmpb   $0x30,(%ecx)
  800b04:	75 10                	jne    800b16 <strtol+0x58>
  800b06:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b0a:	75 7c                	jne    800b88 <strtol+0xca>
		s += 2, base = 16;
  800b0c:	83 c1 02             	add    $0x2,%ecx
  800b0f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b14:	eb 16                	jmp    800b2c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b16:	85 db                	test   %ebx,%ebx
  800b18:	75 12                	jne    800b2c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b1a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800b22:	75 08                	jne    800b2c <strtol+0x6e>
		s++, base = 8;
  800b24:	83 c1 01             	add    $0x1,%ecx
  800b27:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b31:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b34:	0f b6 11             	movzbl (%ecx),%edx
  800b37:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b3a:	89 f3                	mov    %esi,%ebx
  800b3c:	80 fb 09             	cmp    $0x9,%bl
  800b3f:	77 08                	ja     800b49 <strtol+0x8b>
			dig = *s - '0';
  800b41:	0f be d2             	movsbl %dl,%edx
  800b44:	83 ea 30             	sub    $0x30,%edx
  800b47:	eb 22                	jmp    800b6b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b49:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b4c:	89 f3                	mov    %esi,%ebx
  800b4e:	80 fb 19             	cmp    $0x19,%bl
  800b51:	77 08                	ja     800b5b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b53:	0f be d2             	movsbl %dl,%edx
  800b56:	83 ea 57             	sub    $0x57,%edx
  800b59:	eb 10                	jmp    800b6b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b5b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b5e:	89 f3                	mov    %esi,%ebx
  800b60:	80 fb 19             	cmp    $0x19,%bl
  800b63:	77 16                	ja     800b7b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b65:	0f be d2             	movsbl %dl,%edx
  800b68:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b6b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b6e:	7d 0b                	jge    800b7b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b70:	83 c1 01             	add    $0x1,%ecx
  800b73:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b77:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b79:	eb b9                	jmp    800b34 <strtol+0x76>

	if (endptr)
  800b7b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7f:	74 0d                	je     800b8e <strtol+0xd0>
		*endptr = (char *) s;
  800b81:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b84:	89 0e                	mov    %ecx,(%esi)
  800b86:	eb 06                	jmp    800b8e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b88:	85 db                	test   %ebx,%ebx
  800b8a:	74 98                	je     800b24 <strtol+0x66>
  800b8c:	eb 9e                	jmp    800b2c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b8e:	89 c2                	mov    %eax,%edx
  800b90:	f7 da                	neg    %edx
  800b92:	85 ff                	test   %edi,%edi
  800b94:	0f 45 c2             	cmovne %edx,%eax
}
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bad:	89 c3                	mov    %eax,%ebx
  800baf:	89 c7                	mov    %eax,%edi
  800bb1:	89 c6                	mov    %eax,%esi
  800bb3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_cgetc>:

int
sys_cgetc(void)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bca:	89 d1                	mov    %edx,%ecx
  800bcc:	89 d3                	mov    %edx,%ebx
  800bce:	89 d7                	mov    %edx,%edi
  800bd0:	89 d6                	mov    %edx,%esi
  800bd2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800be7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bec:	8b 55 08             	mov    0x8(%ebp),%edx
  800bef:	89 cb                	mov    %ecx,%ebx
  800bf1:	89 cf                	mov    %ecx,%edi
  800bf3:	89 ce                	mov    %ecx,%esi
  800bf5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	7e 17                	jle    800c12 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfb:	83 ec 0c             	sub    $0xc,%esp
  800bfe:	50                   	push   %eax
  800bff:	6a 03                	push   $0x3
  800c01:	68 88 14 80 00       	push   $0x801488
  800c06:	6a 23                	push   $0x23
  800c08:	68 a5 14 80 00       	push   $0x8014a5
  800c0d:	e8 8a 02 00 00       	call   800e9c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c20:	ba 00 00 00 00       	mov    $0x0,%edx
  800c25:	b8 02 00 00 00       	mov    $0x2,%eax
  800c2a:	89 d1                	mov    %edx,%ecx
  800c2c:	89 d3                	mov    %edx,%ebx
  800c2e:	89 d7                	mov    %edx,%edi
  800c30:	89 d6                	mov    %edx,%esi
  800c32:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_yield>:

void
sys_yield(void)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c44:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c49:	89 d1                	mov    %edx,%ecx
  800c4b:	89 d3                	mov    %edx,%ebx
  800c4d:	89 d7                	mov    %edx,%edi
  800c4f:	89 d6                	mov    %edx,%esi
  800c51:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c53:	5b                   	pop    %ebx
  800c54:	5e                   	pop    %esi
  800c55:	5f                   	pop    %edi
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c61:	be 00 00 00 00       	mov    $0x0,%esi
  800c66:	b8 04 00 00 00       	mov    $0x4,%eax
  800c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c74:	89 f7                	mov    %esi,%edi
  800c76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	7e 17                	jle    800c93 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7c:	83 ec 0c             	sub    $0xc,%esp
  800c7f:	50                   	push   %eax
  800c80:	6a 04                	push   $0x4
  800c82:	68 88 14 80 00       	push   $0x801488
  800c87:	6a 23                	push   $0x23
  800c89:	68 a5 14 80 00       	push   $0x8014a5
  800c8e:	e8 09 02 00 00       	call   800e9c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca4:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cac:	8b 55 08             	mov    0x8(%ebp),%edx
  800caf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb5:	8b 75 18             	mov    0x18(%ebp),%esi
  800cb8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	7e 17                	jle    800cd5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbe:	83 ec 0c             	sub    $0xc,%esp
  800cc1:	50                   	push   %eax
  800cc2:	6a 05                	push   $0x5
  800cc4:	68 88 14 80 00       	push   $0x801488
  800cc9:	6a 23                	push   $0x23
  800ccb:	68 a5 14 80 00       	push   $0x8014a5
  800cd0:	e8 c7 01 00 00       	call   800e9c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
  800ce3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ceb:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	89 df                	mov    %ebx,%edi
  800cf8:	89 de                	mov    %ebx,%esi
  800cfa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	7e 17                	jle    800d17 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d00:	83 ec 0c             	sub    $0xc,%esp
  800d03:	50                   	push   %eax
  800d04:	6a 06                	push   $0x6
  800d06:	68 88 14 80 00       	push   $0x801488
  800d0b:	6a 23                	push   $0x23
  800d0d:	68 a5 14 80 00       	push   $0x8014a5
  800d12:	e8 85 01 00 00       	call   800e9c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
  800d25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d35:	8b 55 08             	mov    0x8(%ebp),%edx
  800d38:	89 df                	mov    %ebx,%edi
  800d3a:	89 de                	mov    %ebx,%esi
  800d3c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	7e 17                	jle    800d59 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d42:	83 ec 0c             	sub    $0xc,%esp
  800d45:	50                   	push   %eax
  800d46:	6a 08                	push   $0x8
  800d48:	68 88 14 80 00       	push   $0x801488
  800d4d:	6a 23                	push   $0x23
  800d4f:	68 a5 14 80 00       	push   $0x8014a5
  800d54:	e8 43 01 00 00       	call   800e9c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5c:	5b                   	pop    %ebx
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	57                   	push   %edi
  800d65:	56                   	push   %esi
  800d66:	53                   	push   %ebx
  800d67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6f:	b8 09 00 00 00       	mov    $0x9,%eax
  800d74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d77:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7a:	89 df                	mov    %ebx,%edi
  800d7c:	89 de                	mov    %ebx,%esi
  800d7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d80:	85 c0                	test   %eax,%eax
  800d82:	7e 17                	jle    800d9b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d84:	83 ec 0c             	sub    $0xc,%esp
  800d87:	50                   	push   %eax
  800d88:	6a 09                	push   $0x9
  800d8a:	68 88 14 80 00       	push   $0x801488
  800d8f:	6a 23                	push   $0x23
  800d91:	68 a5 14 80 00       	push   $0x8014a5
  800d96:	e8 01 01 00 00       	call   800e9c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	be 00 00 00 00       	mov    $0x0,%esi
  800dae:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	57                   	push   %edi
  800dca:	56                   	push   %esi
  800dcb:	53                   	push   %ebx
  800dcc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	89 cb                	mov    %ecx,%ebx
  800dde:	89 cf                	mov    %ecx,%edi
  800de0:	89 ce                	mov    %ecx,%esi
  800de2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de4:	85 c0                	test   %eax,%eax
  800de6:	7e 17                	jle    800dff <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de8:	83 ec 0c             	sub    $0xc,%esp
  800deb:	50                   	push   %eax
  800dec:	6a 0c                	push   $0xc
  800dee:	68 88 14 80 00       	push   $0x801488
  800df3:	6a 23                	push   $0x23
  800df5:	68 a5 14 80 00       	push   $0x8014a5
  800dfa:	e8 9d 00 00 00       	call   800e9c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e02:	5b                   	pop    %ebx
  800e03:	5e                   	pop    %esi
  800e04:	5f                   	pop    %edi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800e0d:	68 bf 14 80 00       	push   $0x8014bf
  800e12:	6a 51                	push   $0x51
  800e14:	68 b3 14 80 00       	push   $0x8014b3
  800e19:	e8 7e 00 00 00       	call   800e9c <_panic>

00800e1e <sfork>:
}

// Challenge!
int
sfork(void)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800e24:	68 be 14 80 00       	push   $0x8014be
  800e29:	6a 58                	push   $0x58
  800e2b:	68 b3 14 80 00       	push   $0x8014b3
  800e30:	e8 67 00 00 00       	call   800e9c <_panic>

00800e35 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800e3b:	68 d4 14 80 00       	push   $0x8014d4
  800e40:	6a 1a                	push   $0x1a
  800e42:	68 ed 14 80 00       	push   $0x8014ed
  800e47:	e8 50 00 00 00       	call   800e9c <_panic>

00800e4c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800e52:	68 f7 14 80 00       	push   $0x8014f7
  800e57:	6a 2a                	push   $0x2a
  800e59:	68 ed 14 80 00       	push   $0x8014ed
  800e5e:	e8 39 00 00 00       	call   800e9c <_panic>

00800e63 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e69:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e6e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e71:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e77:	8b 52 50             	mov    0x50(%edx),%edx
  800e7a:	39 ca                	cmp    %ecx,%edx
  800e7c:	75 0d                	jne    800e8b <ipc_find_env+0x28>
			return envs[i].env_id;
  800e7e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e81:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e86:	8b 40 48             	mov    0x48(%eax),%eax
  800e89:	eb 0f                	jmp    800e9a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e8b:	83 c0 01             	add    $0x1,%eax
  800e8e:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e93:	75 d9                	jne    800e6e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e95:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    

00800e9c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	56                   	push   %esi
  800ea0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ea1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ea4:	8b 35 08 20 80 00    	mov    0x802008,%esi
  800eaa:	e8 6b fd ff ff       	call   800c1a <sys_getenvid>
  800eaf:	83 ec 0c             	sub    $0xc,%esp
  800eb2:	ff 75 0c             	pushl  0xc(%ebp)
  800eb5:	ff 75 08             	pushl  0x8(%ebp)
  800eb8:	56                   	push   %esi
  800eb9:	50                   	push   %eax
  800eba:	68 10 15 80 00       	push   $0x801510
  800ebf:	e8 ca f3 ff ff       	call   80028e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ec4:	83 c4 18             	add    $0x18,%esp
  800ec7:	53                   	push   %ebx
  800ec8:	ff 75 10             	pushl  0x10(%ebp)
  800ecb:	e8 6d f3 ff ff       	call   80023d <vcprintf>
	cprintf("\n");
  800ed0:	c7 04 24 60 12 80 00 	movl   $0x801260,(%esp)
  800ed7:	e8 b2 f3 ff ff       	call   80028e <cprintf>
  800edc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800edf:	cc                   	int3   
  800ee0:	eb fd                	jmp    800edf <_panic+0x43>
  800ee2:	66 90                	xchg   %ax,%ax
  800ee4:	66 90                	xchg   %ax,%ax
  800ee6:	66 90                	xchg   %ax,%ax
  800ee8:	66 90                	xchg   %ax,%ax
  800eea:	66 90                	xchg   %ax,%ax
  800eec:	66 90                	xchg   %ax,%ax
  800eee:	66 90                	xchg   %ax,%ax

00800ef0 <__udivdi3>:
  800ef0:	55                   	push   %ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 1c             	sub    $0x1c,%esp
  800ef7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800efb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800eff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800f03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f07:	85 f6                	test   %esi,%esi
  800f09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f0d:	89 ca                	mov    %ecx,%edx
  800f0f:	89 f8                	mov    %edi,%eax
  800f11:	75 3d                	jne    800f50 <__udivdi3+0x60>
  800f13:	39 cf                	cmp    %ecx,%edi
  800f15:	0f 87 c5 00 00 00    	ja     800fe0 <__udivdi3+0xf0>
  800f1b:	85 ff                	test   %edi,%edi
  800f1d:	89 fd                	mov    %edi,%ebp
  800f1f:	75 0b                	jne    800f2c <__udivdi3+0x3c>
  800f21:	b8 01 00 00 00       	mov    $0x1,%eax
  800f26:	31 d2                	xor    %edx,%edx
  800f28:	f7 f7                	div    %edi
  800f2a:	89 c5                	mov    %eax,%ebp
  800f2c:	89 c8                	mov    %ecx,%eax
  800f2e:	31 d2                	xor    %edx,%edx
  800f30:	f7 f5                	div    %ebp
  800f32:	89 c1                	mov    %eax,%ecx
  800f34:	89 d8                	mov    %ebx,%eax
  800f36:	89 cf                	mov    %ecx,%edi
  800f38:	f7 f5                	div    %ebp
  800f3a:	89 c3                	mov    %eax,%ebx
  800f3c:	89 d8                	mov    %ebx,%eax
  800f3e:	89 fa                	mov    %edi,%edx
  800f40:	83 c4 1c             	add    $0x1c,%esp
  800f43:	5b                   	pop    %ebx
  800f44:	5e                   	pop    %esi
  800f45:	5f                   	pop    %edi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    
  800f48:	90                   	nop
  800f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f50:	39 ce                	cmp    %ecx,%esi
  800f52:	77 74                	ja     800fc8 <__udivdi3+0xd8>
  800f54:	0f bd fe             	bsr    %esi,%edi
  800f57:	83 f7 1f             	xor    $0x1f,%edi
  800f5a:	0f 84 98 00 00 00    	je     800ff8 <__udivdi3+0x108>
  800f60:	bb 20 00 00 00       	mov    $0x20,%ebx
  800f65:	89 f9                	mov    %edi,%ecx
  800f67:	89 c5                	mov    %eax,%ebp
  800f69:	29 fb                	sub    %edi,%ebx
  800f6b:	d3 e6                	shl    %cl,%esi
  800f6d:	89 d9                	mov    %ebx,%ecx
  800f6f:	d3 ed                	shr    %cl,%ebp
  800f71:	89 f9                	mov    %edi,%ecx
  800f73:	d3 e0                	shl    %cl,%eax
  800f75:	09 ee                	or     %ebp,%esi
  800f77:	89 d9                	mov    %ebx,%ecx
  800f79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f7d:	89 d5                	mov    %edx,%ebp
  800f7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f83:	d3 ed                	shr    %cl,%ebp
  800f85:	89 f9                	mov    %edi,%ecx
  800f87:	d3 e2                	shl    %cl,%edx
  800f89:	89 d9                	mov    %ebx,%ecx
  800f8b:	d3 e8                	shr    %cl,%eax
  800f8d:	09 c2                	or     %eax,%edx
  800f8f:	89 d0                	mov    %edx,%eax
  800f91:	89 ea                	mov    %ebp,%edx
  800f93:	f7 f6                	div    %esi
  800f95:	89 d5                	mov    %edx,%ebp
  800f97:	89 c3                	mov    %eax,%ebx
  800f99:	f7 64 24 0c          	mull   0xc(%esp)
  800f9d:	39 d5                	cmp    %edx,%ebp
  800f9f:	72 10                	jb     800fb1 <__udivdi3+0xc1>
  800fa1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800fa5:	89 f9                	mov    %edi,%ecx
  800fa7:	d3 e6                	shl    %cl,%esi
  800fa9:	39 c6                	cmp    %eax,%esi
  800fab:	73 07                	jae    800fb4 <__udivdi3+0xc4>
  800fad:	39 d5                	cmp    %edx,%ebp
  800faf:	75 03                	jne    800fb4 <__udivdi3+0xc4>
  800fb1:	83 eb 01             	sub    $0x1,%ebx
  800fb4:	31 ff                	xor    %edi,%edi
  800fb6:	89 d8                	mov    %ebx,%eax
  800fb8:	89 fa                	mov    %edi,%edx
  800fba:	83 c4 1c             	add    $0x1c,%esp
  800fbd:	5b                   	pop    %ebx
  800fbe:	5e                   	pop    %esi
  800fbf:	5f                   	pop    %edi
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    
  800fc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fc8:	31 ff                	xor    %edi,%edi
  800fca:	31 db                	xor    %ebx,%ebx
  800fcc:	89 d8                	mov    %ebx,%eax
  800fce:	89 fa                	mov    %edi,%edx
  800fd0:	83 c4 1c             	add    $0x1c,%esp
  800fd3:	5b                   	pop    %ebx
  800fd4:	5e                   	pop    %esi
  800fd5:	5f                   	pop    %edi
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    
  800fd8:	90                   	nop
  800fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fe0:	89 d8                	mov    %ebx,%eax
  800fe2:	f7 f7                	div    %edi
  800fe4:	31 ff                	xor    %edi,%edi
  800fe6:	89 c3                	mov    %eax,%ebx
  800fe8:	89 d8                	mov    %ebx,%eax
  800fea:	89 fa                	mov    %edi,%edx
  800fec:	83 c4 1c             	add    $0x1c,%esp
  800fef:	5b                   	pop    %ebx
  800ff0:	5e                   	pop    %esi
  800ff1:	5f                   	pop    %edi
  800ff2:	5d                   	pop    %ebp
  800ff3:	c3                   	ret    
  800ff4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ff8:	39 ce                	cmp    %ecx,%esi
  800ffa:	72 0c                	jb     801008 <__udivdi3+0x118>
  800ffc:	31 db                	xor    %ebx,%ebx
  800ffe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801002:	0f 87 34 ff ff ff    	ja     800f3c <__udivdi3+0x4c>
  801008:	bb 01 00 00 00       	mov    $0x1,%ebx
  80100d:	e9 2a ff ff ff       	jmp    800f3c <__udivdi3+0x4c>
  801012:	66 90                	xchg   %ax,%ax
  801014:	66 90                	xchg   %ax,%ax
  801016:	66 90                	xchg   %ax,%ax
  801018:	66 90                	xchg   %ax,%ax
  80101a:	66 90                	xchg   %ax,%ax
  80101c:	66 90                	xchg   %ax,%ax
  80101e:	66 90                	xchg   %ax,%ax

00801020 <__umoddi3>:
  801020:	55                   	push   %ebp
  801021:	57                   	push   %edi
  801022:	56                   	push   %esi
  801023:	53                   	push   %ebx
  801024:	83 ec 1c             	sub    $0x1c,%esp
  801027:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80102b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80102f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801033:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801037:	85 d2                	test   %edx,%edx
  801039:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80103d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801041:	89 f3                	mov    %esi,%ebx
  801043:	89 3c 24             	mov    %edi,(%esp)
  801046:	89 74 24 04          	mov    %esi,0x4(%esp)
  80104a:	75 1c                	jne    801068 <__umoddi3+0x48>
  80104c:	39 f7                	cmp    %esi,%edi
  80104e:	76 50                	jbe    8010a0 <__umoddi3+0x80>
  801050:	89 c8                	mov    %ecx,%eax
  801052:	89 f2                	mov    %esi,%edx
  801054:	f7 f7                	div    %edi
  801056:	89 d0                	mov    %edx,%eax
  801058:	31 d2                	xor    %edx,%edx
  80105a:	83 c4 1c             	add    $0x1c,%esp
  80105d:	5b                   	pop    %ebx
  80105e:	5e                   	pop    %esi
  80105f:	5f                   	pop    %edi
  801060:	5d                   	pop    %ebp
  801061:	c3                   	ret    
  801062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801068:	39 f2                	cmp    %esi,%edx
  80106a:	89 d0                	mov    %edx,%eax
  80106c:	77 52                	ja     8010c0 <__umoddi3+0xa0>
  80106e:	0f bd ea             	bsr    %edx,%ebp
  801071:	83 f5 1f             	xor    $0x1f,%ebp
  801074:	75 5a                	jne    8010d0 <__umoddi3+0xb0>
  801076:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80107a:	0f 82 e0 00 00 00    	jb     801160 <__umoddi3+0x140>
  801080:	39 0c 24             	cmp    %ecx,(%esp)
  801083:	0f 86 d7 00 00 00    	jbe    801160 <__umoddi3+0x140>
  801089:	8b 44 24 08          	mov    0x8(%esp),%eax
  80108d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801091:	83 c4 1c             	add    $0x1c,%esp
  801094:	5b                   	pop    %ebx
  801095:	5e                   	pop    %esi
  801096:	5f                   	pop    %edi
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    
  801099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010a0:	85 ff                	test   %edi,%edi
  8010a2:	89 fd                	mov    %edi,%ebp
  8010a4:	75 0b                	jne    8010b1 <__umoddi3+0x91>
  8010a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ab:	31 d2                	xor    %edx,%edx
  8010ad:	f7 f7                	div    %edi
  8010af:	89 c5                	mov    %eax,%ebp
  8010b1:	89 f0                	mov    %esi,%eax
  8010b3:	31 d2                	xor    %edx,%edx
  8010b5:	f7 f5                	div    %ebp
  8010b7:	89 c8                	mov    %ecx,%eax
  8010b9:	f7 f5                	div    %ebp
  8010bb:	89 d0                	mov    %edx,%eax
  8010bd:	eb 99                	jmp    801058 <__umoddi3+0x38>
  8010bf:	90                   	nop
  8010c0:	89 c8                	mov    %ecx,%eax
  8010c2:	89 f2                	mov    %esi,%edx
  8010c4:	83 c4 1c             	add    $0x1c,%esp
  8010c7:	5b                   	pop    %ebx
  8010c8:	5e                   	pop    %esi
  8010c9:	5f                   	pop    %edi
  8010ca:	5d                   	pop    %ebp
  8010cb:	c3                   	ret    
  8010cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010d0:	8b 34 24             	mov    (%esp),%esi
  8010d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8010d8:	89 e9                	mov    %ebp,%ecx
  8010da:	29 ef                	sub    %ebp,%edi
  8010dc:	d3 e0                	shl    %cl,%eax
  8010de:	89 f9                	mov    %edi,%ecx
  8010e0:	89 f2                	mov    %esi,%edx
  8010e2:	d3 ea                	shr    %cl,%edx
  8010e4:	89 e9                	mov    %ebp,%ecx
  8010e6:	09 c2                	or     %eax,%edx
  8010e8:	89 d8                	mov    %ebx,%eax
  8010ea:	89 14 24             	mov    %edx,(%esp)
  8010ed:	89 f2                	mov    %esi,%edx
  8010ef:	d3 e2                	shl    %cl,%edx
  8010f1:	89 f9                	mov    %edi,%ecx
  8010f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8010fb:	d3 e8                	shr    %cl,%eax
  8010fd:	89 e9                	mov    %ebp,%ecx
  8010ff:	89 c6                	mov    %eax,%esi
  801101:	d3 e3                	shl    %cl,%ebx
  801103:	89 f9                	mov    %edi,%ecx
  801105:	89 d0                	mov    %edx,%eax
  801107:	d3 e8                	shr    %cl,%eax
  801109:	89 e9                	mov    %ebp,%ecx
  80110b:	09 d8                	or     %ebx,%eax
  80110d:	89 d3                	mov    %edx,%ebx
  80110f:	89 f2                	mov    %esi,%edx
  801111:	f7 34 24             	divl   (%esp)
  801114:	89 d6                	mov    %edx,%esi
  801116:	d3 e3                	shl    %cl,%ebx
  801118:	f7 64 24 04          	mull   0x4(%esp)
  80111c:	39 d6                	cmp    %edx,%esi
  80111e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801122:	89 d1                	mov    %edx,%ecx
  801124:	89 c3                	mov    %eax,%ebx
  801126:	72 08                	jb     801130 <__umoddi3+0x110>
  801128:	75 11                	jne    80113b <__umoddi3+0x11b>
  80112a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80112e:	73 0b                	jae    80113b <__umoddi3+0x11b>
  801130:	2b 44 24 04          	sub    0x4(%esp),%eax
  801134:	1b 14 24             	sbb    (%esp),%edx
  801137:	89 d1                	mov    %edx,%ecx
  801139:	89 c3                	mov    %eax,%ebx
  80113b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80113f:	29 da                	sub    %ebx,%edx
  801141:	19 ce                	sbb    %ecx,%esi
  801143:	89 f9                	mov    %edi,%ecx
  801145:	89 f0                	mov    %esi,%eax
  801147:	d3 e0                	shl    %cl,%eax
  801149:	89 e9                	mov    %ebp,%ecx
  80114b:	d3 ea                	shr    %cl,%edx
  80114d:	89 e9                	mov    %ebp,%ecx
  80114f:	d3 ee                	shr    %cl,%esi
  801151:	09 d0                	or     %edx,%eax
  801153:	89 f2                	mov    %esi,%edx
  801155:	83 c4 1c             	add    $0x1c,%esp
  801158:	5b                   	pop    %ebx
  801159:	5e                   	pop    %esi
  80115a:	5f                   	pop    %edi
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    
  80115d:	8d 76 00             	lea    0x0(%esi),%esi
  801160:	29 f9                	sub    %edi,%ecx
  801162:	19 d6                	sbb    %edx,%esi
  801164:	89 74 24 04          	mov    %esi,0x4(%esp)
  801168:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80116c:	e9 18 ff ff ff       	jmp    801089 <__umoddi3+0x69>
