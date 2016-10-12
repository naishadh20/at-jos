
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 40 0e 80 00       	push   $0x800e40
  80003e:	e8 ba 01 00 00       	call   8001fd <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 bb 0e 80 00       	push   $0x800ebb
  80005b:	6a 11                	push   $0x11
  80005d:	68 d8 0e 80 00       	push   $0x800ed8
  800062:	e8 bd 00 00 00       	call   800124 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800067:	83 c0 01             	add    $0x1,%eax
  80006a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006f:	75 da                	jne    80004b <umain+0x18>
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800076:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 ef                	jne    800076 <umain+0x43>
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  80008c:	3b 04 85 20 20 80 00 	cmp    0x802020(,%eax,4),%eax
  800093:	74 12                	je     8000a7 <umain+0x74>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800095:	50                   	push   %eax
  800096:	68 60 0e 80 00       	push   $0x800e60
  80009b:	6a 16                	push   $0x16
  80009d:	68 d8 0e 80 00       	push   $0x800ed8
  8000a2:	e8 7d 00 00 00       	call   800124 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a7:	83 c0 01             	add    $0x1,%eax
  8000aa:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000af:	75 db                	jne    80008c <umain+0x59>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 88 0e 80 00       	push   $0x800e88
  8000b9:	e8 3f 01 00 00       	call   8001fd <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 e7 0e 80 00       	push   $0x800ee7
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 d8 0e 80 00       	push   $0x800ed8
  8000d7:	e8 48 00 00 00       	call   800124 <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8000e5:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000e8:	c7 05 20 20 c0 00 00 	movl   $0x0,0xc02020
  8000ef:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	7e 08                	jle    8000fe <libmain+0x22>
		binaryname = argv[0];
  8000f6:	8b 0a                	mov    (%edx),%ecx
  8000f8:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  8000fe:	83 ec 08             	sub    $0x8,%esp
  800101:	52                   	push   %edx
  800102:	50                   	push   %eax
  800103:	e8 2b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800108:	e8 05 00 00 00       	call   800112 <exit>
}
  80010d:	83 c4 10             	add    $0x10,%esp
  800110:	c9                   	leave  
  800111:	c3                   	ret    

00800112 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800112:	55                   	push   %ebp
  800113:	89 e5                	mov    %esp,%ebp
  800115:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800118:	6a 00                	push   $0x0
  80011a:	e8 29 0a 00 00       	call   800b48 <sys_env_destroy>
}
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	c9                   	leave  
  800123:	c3                   	ret    

00800124 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	56                   	push   %esi
  800128:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800129:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80012c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800132:	e8 52 0a 00 00       	call   800b89 <sys_getenvid>
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	ff 75 0c             	pushl  0xc(%ebp)
  80013d:	ff 75 08             	pushl  0x8(%ebp)
  800140:	56                   	push   %esi
  800141:	50                   	push   %eax
  800142:	68 08 0f 80 00       	push   $0x800f08
  800147:	e8 b1 00 00 00       	call   8001fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80014c:	83 c4 18             	add    $0x18,%esp
  80014f:	53                   	push   %ebx
  800150:	ff 75 10             	pushl  0x10(%ebp)
  800153:	e8 54 00 00 00       	call   8001ac <vcprintf>
	cprintf("\n");
  800158:	c7 04 24 d6 0e 80 00 	movl   $0x800ed6,(%esp)
  80015f:	e8 99 00 00 00       	call   8001fd <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800167:	cc                   	int3   
  800168:	eb fd                	jmp    800167 <_panic+0x43>

0080016a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	53                   	push   %ebx
  80016e:	83 ec 04             	sub    $0x4,%esp
  800171:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800174:	8b 13                	mov    (%ebx),%edx
  800176:	8d 42 01             	lea    0x1(%edx),%eax
  800179:	89 03                	mov    %eax,(%ebx)
  80017b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800182:	3d ff 00 00 00       	cmp    $0xff,%eax
  800187:	75 1a                	jne    8001a3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800189:	83 ec 08             	sub    $0x8,%esp
  80018c:	68 ff 00 00 00       	push   $0xff
  800191:	8d 43 08             	lea    0x8(%ebx),%eax
  800194:	50                   	push   %eax
  800195:	e8 71 09 00 00       	call   800b0b <sys_cputs>
		b->idx = 0;
  80019a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001aa:	c9                   	leave  
  8001ab:	c3                   	ret    

008001ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bc:	00 00 00 
	b.cnt = 0;
  8001bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c9:	ff 75 0c             	pushl  0xc(%ebp)
  8001cc:	ff 75 08             	pushl  0x8(%ebp)
  8001cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d5:	50                   	push   %eax
  8001d6:	68 6a 01 80 00       	push   $0x80016a
  8001db:	e8 54 01 00 00       	call   800334 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e0:	83 c4 08             	add    $0x8,%esp
  8001e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	e8 16 09 00 00       	call   800b0b <sys_cputs>

	return b.cnt;
}
  8001f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fb:	c9                   	leave  
  8001fc:	c3                   	ret    

008001fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800203:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800206:	50                   	push   %eax
  800207:	ff 75 08             	pushl  0x8(%ebp)
  80020a:	e8 9d ff ff ff       	call   8001ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	57                   	push   %edi
  800215:	56                   	push   %esi
  800216:	53                   	push   %ebx
  800217:	83 ec 1c             	sub    $0x1c,%esp
  80021a:	89 c7                	mov    %eax,%edi
  80021c:	89 d6                	mov    %edx,%esi
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	8b 55 0c             	mov    0xc(%ebp),%edx
  800224:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800227:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80022d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800232:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800235:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800238:	39 d3                	cmp    %edx,%ebx
  80023a:	72 05                	jb     800241 <printnum+0x30>
  80023c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023f:	77 45                	ja     800286 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800241:	83 ec 0c             	sub    $0xc,%esp
  800244:	ff 75 18             	pushl  0x18(%ebp)
  800247:	8b 45 14             	mov    0x14(%ebp),%eax
  80024a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80024d:	53                   	push   %ebx
  80024e:	ff 75 10             	pushl  0x10(%ebp)
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	ff 75 e4             	pushl  -0x1c(%ebp)
  800257:	ff 75 e0             	pushl  -0x20(%ebp)
  80025a:	ff 75 dc             	pushl  -0x24(%ebp)
  80025d:	ff 75 d8             	pushl  -0x28(%ebp)
  800260:	e8 4b 09 00 00       	call   800bb0 <__udivdi3>
  800265:	83 c4 18             	add    $0x18,%esp
  800268:	52                   	push   %edx
  800269:	50                   	push   %eax
  80026a:	89 f2                	mov    %esi,%edx
  80026c:	89 f8                	mov    %edi,%eax
  80026e:	e8 9e ff ff ff       	call   800211 <printnum>
  800273:	83 c4 20             	add    $0x20,%esp
  800276:	eb 18                	jmp    800290 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800278:	83 ec 08             	sub    $0x8,%esp
  80027b:	56                   	push   %esi
  80027c:	ff 75 18             	pushl  0x18(%ebp)
  80027f:	ff d7                	call   *%edi
  800281:	83 c4 10             	add    $0x10,%esp
  800284:	eb 03                	jmp    800289 <printnum+0x78>
  800286:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800289:	83 eb 01             	sub    $0x1,%ebx
  80028c:	85 db                	test   %ebx,%ebx
  80028e:	7f e8                	jg     800278 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	56                   	push   %esi
  800294:	83 ec 04             	sub    $0x4,%esp
  800297:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029a:	ff 75 e0             	pushl  -0x20(%ebp)
  80029d:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a3:	e8 38 0a 00 00       	call   800ce0 <__umoddi3>
  8002a8:	83 c4 14             	add    $0x14,%esp
  8002ab:	0f be 80 2c 0f 80 00 	movsbl 0x800f2c(%eax),%eax
  8002b2:	50                   	push   %eax
  8002b3:	ff d7                	call   *%edi
}
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bb:	5b                   	pop    %ebx
  8002bc:	5e                   	pop    %esi
  8002bd:	5f                   	pop    %edi
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c3:	83 fa 01             	cmp    $0x1,%edx
  8002c6:	7e 0e                	jle    8002d6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c8:	8b 10                	mov    (%eax),%edx
  8002ca:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002cd:	89 08                	mov    %ecx,(%eax)
  8002cf:	8b 02                	mov    (%edx),%eax
  8002d1:	8b 52 04             	mov    0x4(%edx),%edx
  8002d4:	eb 22                	jmp    8002f8 <getuint+0x38>
	else if (lflag)
  8002d6:	85 d2                	test   %edx,%edx
  8002d8:	74 10                	je     8002ea <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002da:	8b 10                	mov    (%eax),%edx
  8002dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002df:	89 08                	mov    %ecx,(%eax)
  8002e1:	8b 02                	mov    (%edx),%eax
  8002e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e8:	eb 0e                	jmp    8002f8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 02                	mov    (%edx),%eax
  8002f3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f8:	5d                   	pop    %ebp
  8002f9:	c3                   	ret    

008002fa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
  8002fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800300:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800304:	8b 10                	mov    (%eax),%edx
  800306:	3b 50 04             	cmp    0x4(%eax),%edx
  800309:	73 0a                	jae    800315 <sprintputch+0x1b>
		*b->buf++ = ch;
  80030b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030e:	89 08                	mov    %ecx,(%eax)
  800310:	8b 45 08             	mov    0x8(%ebp),%eax
  800313:	88 02                	mov    %al,(%edx)
}
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80031d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800320:	50                   	push   %eax
  800321:	ff 75 10             	pushl  0x10(%ebp)
  800324:	ff 75 0c             	pushl  0xc(%ebp)
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	e8 05 00 00 00       	call   800334 <vprintfmt>
	va_end(ap);
}
  80032f:	83 c4 10             	add    $0x10,%esp
  800332:	c9                   	leave  
  800333:	c3                   	ret    

00800334 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	57                   	push   %edi
  800338:	56                   	push   %esi
  800339:	53                   	push   %ebx
  80033a:	83 ec 2c             	sub    $0x2c,%esp
  80033d:	8b 75 08             	mov    0x8(%ebp),%esi
  800340:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800343:	8b 7d 10             	mov    0x10(%ebp),%edi
  800346:	eb 12                	jmp    80035a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800348:	85 c0                	test   %eax,%eax
  80034a:	0f 84 cb 03 00 00    	je     80071b <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800350:	83 ec 08             	sub    $0x8,%esp
  800353:	53                   	push   %ebx
  800354:	50                   	push   %eax
  800355:	ff d6                	call   *%esi
  800357:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035a:	83 c7 01             	add    $0x1,%edi
  80035d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800361:	83 f8 25             	cmp    $0x25,%eax
  800364:	75 e2                	jne    800348 <vprintfmt+0x14>
  800366:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80036a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800371:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800378:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80037f:	ba 00 00 00 00       	mov    $0x0,%edx
  800384:	eb 07                	jmp    80038d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800386:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800389:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038d:	8d 47 01             	lea    0x1(%edi),%eax
  800390:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800393:	0f b6 07             	movzbl (%edi),%eax
  800396:	0f b6 c8             	movzbl %al,%ecx
  800399:	83 e8 23             	sub    $0x23,%eax
  80039c:	3c 55                	cmp    $0x55,%al
  80039e:	0f 87 5c 03 00 00    	ja     800700 <vprintfmt+0x3cc>
  8003a4:	0f b6 c0             	movzbl %al,%eax
  8003a7:	ff 24 85 e0 0f 80 00 	jmp    *0x800fe0(,%eax,4)
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b5:	eb d6                	jmp    80038d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003cc:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003cf:	83 fa 09             	cmp    $0x9,%edx
  8003d2:	77 39                	ja     80040d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d7:	eb e9                	jmp    8003c2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dc:	8d 48 04             	lea    0x4(%eax),%ecx
  8003df:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e2:	8b 00                	mov    (%eax),%eax
  8003e4:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ea:	eb 27                	jmp    800413 <vprintfmt+0xdf>
  8003ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ef:	85 c0                	test   %eax,%eax
  8003f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f6:	0f 49 c8             	cmovns %eax,%ecx
  8003f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ff:	eb 8c                	jmp    80038d <vprintfmt+0x59>
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800404:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80040b:	eb 80                	jmp    80038d <vprintfmt+0x59>
  80040d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800410:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800413:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800417:	0f 89 70 ff ff ff    	jns    80038d <vprintfmt+0x59>
				width = precision, precision = -1;
  80041d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800420:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800423:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80042a:	e9 5e ff ff ff       	jmp    80038d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800435:	e9 53 ff ff ff       	jmp    80038d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 50 04             	lea    0x4(%eax),%edx
  800440:	89 55 14             	mov    %edx,0x14(%ebp)
  800443:	83 ec 08             	sub    $0x8,%esp
  800446:	53                   	push   %ebx
  800447:	ff 30                	pushl  (%eax)
  800449:	ff d6                	call   *%esi
			break;
  80044b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800451:	e9 04 ff ff ff       	jmp    80035a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	8d 50 04             	lea    0x4(%eax),%edx
  80045c:	89 55 14             	mov    %edx,0x14(%ebp)
  80045f:	8b 00                	mov    (%eax),%eax
  800461:	99                   	cltd   
  800462:	31 d0                	xor    %edx,%eax
  800464:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800466:	83 f8 07             	cmp    $0x7,%eax
  800469:	7f 0b                	jg     800476 <vprintfmt+0x142>
  80046b:	8b 14 85 40 11 80 00 	mov    0x801140(,%eax,4),%edx
  800472:	85 d2                	test   %edx,%edx
  800474:	75 18                	jne    80048e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800476:	50                   	push   %eax
  800477:	68 44 0f 80 00       	push   $0x800f44
  80047c:	53                   	push   %ebx
  80047d:	56                   	push   %esi
  80047e:	e8 94 fe ff ff       	call   800317 <printfmt>
  800483:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800489:	e9 cc fe ff ff       	jmp    80035a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80048e:	52                   	push   %edx
  80048f:	68 4d 0f 80 00       	push   $0x800f4d
  800494:	53                   	push   %ebx
  800495:	56                   	push   %esi
  800496:	e8 7c fe ff ff       	call   800317 <printfmt>
  80049b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a1:	e9 b4 fe ff ff       	jmp    80035a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8d 50 04             	lea    0x4(%eax),%edx
  8004ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8004af:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b1:	85 ff                	test   %edi,%edi
  8004b3:	b8 3d 0f 80 00       	mov    $0x800f3d,%eax
  8004b8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004bf:	0f 8e 94 00 00 00    	jle    800559 <vprintfmt+0x225>
  8004c5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c9:	0f 84 98 00 00 00    	je     800567 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	ff 75 c8             	pushl  -0x38(%ebp)
  8004d5:	57                   	push   %edi
  8004d6:	e8 c8 02 00 00       	call   8007a3 <strnlen>
  8004db:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004de:	29 c1                	sub    %eax,%ecx
  8004e0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004e3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ed:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f2:	eb 0f                	jmp    800503 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	53                   	push   %ebx
  8004f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004fb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fd:	83 ef 01             	sub    $0x1,%edi
  800500:	83 c4 10             	add    $0x10,%esp
  800503:	85 ff                	test   %edi,%edi
  800505:	7f ed                	jg     8004f4 <vprintfmt+0x1c0>
  800507:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80050a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80050d:	85 c9                	test   %ecx,%ecx
  80050f:	b8 00 00 00 00       	mov    $0x0,%eax
  800514:	0f 49 c1             	cmovns %ecx,%eax
  800517:	29 c1                	sub    %eax,%ecx
  800519:	89 75 08             	mov    %esi,0x8(%ebp)
  80051c:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80051f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800522:	89 cb                	mov    %ecx,%ebx
  800524:	eb 4d                	jmp    800573 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800526:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052a:	74 1b                	je     800547 <vprintfmt+0x213>
  80052c:	0f be c0             	movsbl %al,%eax
  80052f:	83 e8 20             	sub    $0x20,%eax
  800532:	83 f8 5e             	cmp    $0x5e,%eax
  800535:	76 10                	jbe    800547 <vprintfmt+0x213>
					putch('?', putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	ff 75 0c             	pushl  0xc(%ebp)
  80053d:	6a 3f                	push   $0x3f
  80053f:	ff 55 08             	call   *0x8(%ebp)
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	eb 0d                	jmp    800554 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800547:	83 ec 08             	sub    $0x8,%esp
  80054a:	ff 75 0c             	pushl  0xc(%ebp)
  80054d:	52                   	push   %edx
  80054e:	ff 55 08             	call   *0x8(%ebp)
  800551:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800554:	83 eb 01             	sub    $0x1,%ebx
  800557:	eb 1a                	jmp    800573 <vprintfmt+0x23f>
  800559:	89 75 08             	mov    %esi,0x8(%ebp)
  80055c:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80055f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800562:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800565:	eb 0c                	jmp    800573 <vprintfmt+0x23f>
  800567:	89 75 08             	mov    %esi,0x8(%ebp)
  80056a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80056d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800570:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800573:	83 c7 01             	add    $0x1,%edi
  800576:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80057a:	0f be d0             	movsbl %al,%edx
  80057d:	85 d2                	test   %edx,%edx
  80057f:	74 23                	je     8005a4 <vprintfmt+0x270>
  800581:	85 f6                	test   %esi,%esi
  800583:	78 a1                	js     800526 <vprintfmt+0x1f2>
  800585:	83 ee 01             	sub    $0x1,%esi
  800588:	79 9c                	jns    800526 <vprintfmt+0x1f2>
  80058a:	89 df                	mov    %ebx,%edi
  80058c:	8b 75 08             	mov    0x8(%ebp),%esi
  80058f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800592:	eb 18                	jmp    8005ac <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800594:	83 ec 08             	sub    $0x8,%esp
  800597:	53                   	push   %ebx
  800598:	6a 20                	push   $0x20
  80059a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059c:	83 ef 01             	sub    $0x1,%edi
  80059f:	83 c4 10             	add    $0x10,%esp
  8005a2:	eb 08                	jmp    8005ac <vprintfmt+0x278>
  8005a4:	89 df                	mov    %ebx,%edi
  8005a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ac:	85 ff                	test   %edi,%edi
  8005ae:	7f e4                	jg     800594 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b3:	e9 a2 fd ff ff       	jmp    80035a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b8:	83 fa 01             	cmp    $0x1,%edx
  8005bb:	7e 16                	jle    8005d3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 50 08             	lea    0x8(%eax),%edx
  8005c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c6:	8b 50 04             	mov    0x4(%eax),%edx
  8005c9:	8b 00                	mov    (%eax),%eax
  8005cb:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005ce:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005d1:	eb 32                	jmp    800605 <vprintfmt+0x2d1>
	else if (lflag)
  8005d3:	85 d2                	test   %edx,%edx
  8005d5:	74 18                	je     8005ef <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 50 04             	lea    0x4(%eax),%edx
  8005dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e0:	8b 00                	mov    (%eax),%eax
  8005e2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005e5:	89 c1                	mov    %eax,%ecx
  8005e7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ea:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005ed:	eb 16                	jmp    800605 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 50 04             	lea    0x4(%eax),%edx
  8005f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005fd:	89 c1                	mov    %eax,%ecx
  8005ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800602:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800605:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800608:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80060b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800611:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800616:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80061a:	0f 89 a8 00 00 00    	jns    8006c8 <vprintfmt+0x394>
				putch('-', putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	53                   	push   %ebx
  800624:	6a 2d                	push   $0x2d
  800626:	ff d6                	call   *%esi
				num = -(long long) num;
  800628:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80062b:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80062e:	f7 d8                	neg    %eax
  800630:	83 d2 00             	adc    $0x0,%edx
  800633:	f7 da                	neg    %edx
  800635:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800638:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80063b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80063e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800643:	e9 80 00 00 00       	jmp    8006c8 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800648:	8d 45 14             	lea    0x14(%ebp),%eax
  80064b:	e8 70 fc ff ff       	call   8002c0 <getuint>
  800650:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800653:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800656:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80065b:	eb 6b                	jmp    8006c8 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80065d:	8d 45 14             	lea    0x14(%ebp),%eax
  800660:	e8 5b fc ff ff       	call   8002c0 <getuint>
  800665:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800668:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  80066b:	6a 04                	push   $0x4
  80066d:	6a 03                	push   $0x3
  80066f:	6a 01                	push   $0x1
  800671:	68 50 0f 80 00       	push   $0x800f50
  800676:	e8 82 fb ff ff       	call   8001fd <cprintf>
			goto number;
  80067b:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  80067e:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  800683:	eb 43                	jmp    8006c8 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	6a 30                	push   $0x30
  80068b:	ff d6                	call   *%esi
			putch('x', putdat);
  80068d:	83 c4 08             	add    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	6a 78                	push   $0x78
  800693:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8d 50 04             	lea    0x4(%eax),%edx
  80069b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80069e:	8b 00                	mov    (%eax),%eax
  8006a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a8:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ab:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ae:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006b3:	eb 13                	jmp    8006c8 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b8:	e8 03 fc ff ff       	call   8002c0 <getuint>
  8006bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006c3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c8:	83 ec 0c             	sub    $0xc,%esp
  8006cb:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006cf:	52                   	push   %edx
  8006d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d3:	50                   	push   %eax
  8006d4:	ff 75 dc             	pushl  -0x24(%ebp)
  8006d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8006da:	89 da                	mov    %ebx,%edx
  8006dc:	89 f0                	mov    %esi,%eax
  8006de:	e8 2e fb ff ff       	call   800211 <printnum>

			break;
  8006e3:	83 c4 20             	add    $0x20,%esp
  8006e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e9:	e9 6c fc ff ff       	jmp    80035a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	53                   	push   %ebx
  8006f2:	51                   	push   %ecx
  8006f3:	ff d6                	call   *%esi
			break;
  8006f5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006fb:	e9 5a fc ff ff       	jmp    80035a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	53                   	push   %ebx
  800704:	6a 25                	push   $0x25
  800706:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	eb 03                	jmp    800710 <vprintfmt+0x3dc>
  80070d:	83 ef 01             	sub    $0x1,%edi
  800710:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800714:	75 f7                	jne    80070d <vprintfmt+0x3d9>
  800716:	e9 3f fc ff ff       	jmp    80035a <vprintfmt+0x26>
			break;
		}

	}

}
  80071b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071e:	5b                   	pop    %ebx
  80071f:	5e                   	pop    %esi
  800720:	5f                   	pop    %edi
  800721:	5d                   	pop    %ebp
  800722:	c3                   	ret    

00800723 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	83 ec 18             	sub    $0x18,%esp
  800729:	8b 45 08             	mov    0x8(%ebp),%eax
  80072c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800732:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800736:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800739:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800740:	85 c0                	test   %eax,%eax
  800742:	74 26                	je     80076a <vsnprintf+0x47>
  800744:	85 d2                	test   %edx,%edx
  800746:	7e 22                	jle    80076a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800748:	ff 75 14             	pushl  0x14(%ebp)
  80074b:	ff 75 10             	pushl  0x10(%ebp)
  80074e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800751:	50                   	push   %eax
  800752:	68 fa 02 80 00       	push   $0x8002fa
  800757:	e8 d8 fb ff ff       	call   800334 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80075c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800762:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800765:	83 c4 10             	add    $0x10,%esp
  800768:	eb 05                	jmp    80076f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80076a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80076f:	c9                   	leave  
  800770:	c3                   	ret    

00800771 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800777:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80077a:	50                   	push   %eax
  80077b:	ff 75 10             	pushl  0x10(%ebp)
  80077e:	ff 75 0c             	pushl  0xc(%ebp)
  800781:	ff 75 08             	pushl  0x8(%ebp)
  800784:	e8 9a ff ff ff       	call   800723 <vsnprintf>
	va_end(ap);

	return rc;
}
  800789:	c9                   	leave  
  80078a:	c3                   	ret    

0080078b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800791:	b8 00 00 00 00       	mov    $0x0,%eax
  800796:	eb 03                	jmp    80079b <strlen+0x10>
		n++;
  800798:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80079b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079f:	75 f7                	jne    800798 <strlen+0xd>
		n++;
	return n;
}
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b1:	eb 03                	jmp    8007b6 <strnlen+0x13>
		n++;
  8007b3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b6:	39 c2                	cmp    %eax,%edx
  8007b8:	74 08                	je     8007c2 <strnlen+0x1f>
  8007ba:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007be:	75 f3                	jne    8007b3 <strnlen+0x10>
  8007c0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	53                   	push   %ebx
  8007c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ce:	89 c2                	mov    %eax,%edx
  8007d0:	83 c2 01             	add    $0x1,%edx
  8007d3:	83 c1 01             	add    $0x1,%ecx
  8007d6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007da:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007dd:	84 db                	test   %bl,%bl
  8007df:	75 ef                	jne    8007d0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007e1:	5b                   	pop    %ebx
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	53                   	push   %ebx
  8007e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007eb:	53                   	push   %ebx
  8007ec:	e8 9a ff ff ff       	call   80078b <strlen>
  8007f1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f4:	ff 75 0c             	pushl  0xc(%ebp)
  8007f7:	01 d8                	add    %ebx,%eax
  8007f9:	50                   	push   %eax
  8007fa:	e8 c5 ff ff ff       	call   8007c4 <strcpy>
	return dst;
}
  8007ff:	89 d8                	mov    %ebx,%eax
  800801:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800804:	c9                   	leave  
  800805:	c3                   	ret    

00800806 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	56                   	push   %esi
  80080a:	53                   	push   %ebx
  80080b:	8b 75 08             	mov    0x8(%ebp),%esi
  80080e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800811:	89 f3                	mov    %esi,%ebx
  800813:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800816:	89 f2                	mov    %esi,%edx
  800818:	eb 0f                	jmp    800829 <strncpy+0x23>
		*dst++ = *src;
  80081a:	83 c2 01             	add    $0x1,%edx
  80081d:	0f b6 01             	movzbl (%ecx),%eax
  800820:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800823:	80 39 01             	cmpb   $0x1,(%ecx)
  800826:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800829:	39 da                	cmp    %ebx,%edx
  80082b:	75 ed                	jne    80081a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80082d:	89 f0                	mov    %esi,%eax
  80082f:	5b                   	pop    %ebx
  800830:	5e                   	pop    %esi
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	56                   	push   %esi
  800837:	53                   	push   %ebx
  800838:	8b 75 08             	mov    0x8(%ebp),%esi
  80083b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083e:	8b 55 10             	mov    0x10(%ebp),%edx
  800841:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800843:	85 d2                	test   %edx,%edx
  800845:	74 21                	je     800868 <strlcpy+0x35>
  800847:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80084b:	89 f2                	mov    %esi,%edx
  80084d:	eb 09                	jmp    800858 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80084f:	83 c2 01             	add    $0x1,%edx
  800852:	83 c1 01             	add    $0x1,%ecx
  800855:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800858:	39 c2                	cmp    %eax,%edx
  80085a:	74 09                	je     800865 <strlcpy+0x32>
  80085c:	0f b6 19             	movzbl (%ecx),%ebx
  80085f:	84 db                	test   %bl,%bl
  800861:	75 ec                	jne    80084f <strlcpy+0x1c>
  800863:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800865:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800868:	29 f0                	sub    %esi,%eax
}
  80086a:	5b                   	pop    %ebx
  80086b:	5e                   	pop    %esi
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800874:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800877:	eb 06                	jmp    80087f <strcmp+0x11>
		p++, q++;
  800879:	83 c1 01             	add    $0x1,%ecx
  80087c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80087f:	0f b6 01             	movzbl (%ecx),%eax
  800882:	84 c0                	test   %al,%al
  800884:	74 04                	je     80088a <strcmp+0x1c>
  800886:	3a 02                	cmp    (%edx),%al
  800888:	74 ef                	je     800879 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088a:	0f b6 c0             	movzbl %al,%eax
  80088d:	0f b6 12             	movzbl (%edx),%edx
  800890:	29 d0                	sub    %edx,%eax
}
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	53                   	push   %ebx
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089e:	89 c3                	mov    %eax,%ebx
  8008a0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a3:	eb 06                	jmp    8008ab <strncmp+0x17>
		n--, p++, q++;
  8008a5:	83 c0 01             	add    $0x1,%eax
  8008a8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ab:	39 d8                	cmp    %ebx,%eax
  8008ad:	74 15                	je     8008c4 <strncmp+0x30>
  8008af:	0f b6 08             	movzbl (%eax),%ecx
  8008b2:	84 c9                	test   %cl,%cl
  8008b4:	74 04                	je     8008ba <strncmp+0x26>
  8008b6:	3a 0a                	cmp    (%edx),%cl
  8008b8:	74 eb                	je     8008a5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ba:	0f b6 00             	movzbl (%eax),%eax
  8008bd:	0f b6 12             	movzbl (%edx),%edx
  8008c0:	29 d0                	sub    %edx,%eax
  8008c2:	eb 05                	jmp    8008c9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c9:	5b                   	pop    %ebx
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d6:	eb 07                	jmp    8008df <strchr+0x13>
		if (*s == c)
  8008d8:	38 ca                	cmp    %cl,%dl
  8008da:	74 0f                	je     8008eb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008dc:	83 c0 01             	add    $0x1,%eax
  8008df:	0f b6 10             	movzbl (%eax),%edx
  8008e2:	84 d2                	test   %dl,%dl
  8008e4:	75 f2                	jne    8008d8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f7:	eb 03                	jmp    8008fc <strfind+0xf>
  8008f9:	83 c0 01             	add    $0x1,%eax
  8008fc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ff:	38 ca                	cmp    %cl,%dl
  800901:	74 04                	je     800907 <strfind+0x1a>
  800903:	84 d2                	test   %dl,%dl
  800905:	75 f2                	jne    8008f9 <strfind+0xc>
			break;
	return (char *) s;
}
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	57                   	push   %edi
  80090d:	56                   	push   %esi
  80090e:	53                   	push   %ebx
  80090f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800912:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800915:	85 c9                	test   %ecx,%ecx
  800917:	74 36                	je     80094f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800919:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091f:	75 28                	jne    800949 <memset+0x40>
  800921:	f6 c1 03             	test   $0x3,%cl
  800924:	75 23                	jne    800949 <memset+0x40>
		c &= 0xFF;
  800926:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092a:	89 d3                	mov    %edx,%ebx
  80092c:	c1 e3 08             	shl    $0x8,%ebx
  80092f:	89 d6                	mov    %edx,%esi
  800931:	c1 e6 18             	shl    $0x18,%esi
  800934:	89 d0                	mov    %edx,%eax
  800936:	c1 e0 10             	shl    $0x10,%eax
  800939:	09 f0                	or     %esi,%eax
  80093b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80093d:	89 d8                	mov    %ebx,%eax
  80093f:	09 d0                	or     %edx,%eax
  800941:	c1 e9 02             	shr    $0x2,%ecx
  800944:	fc                   	cld    
  800945:	f3 ab                	rep stos %eax,%es:(%edi)
  800947:	eb 06                	jmp    80094f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800949:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094c:	fc                   	cld    
  80094d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094f:	89 f8                	mov    %edi,%eax
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5f                   	pop    %edi
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	57                   	push   %edi
  80095a:	56                   	push   %esi
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800961:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800964:	39 c6                	cmp    %eax,%esi
  800966:	73 35                	jae    80099d <memmove+0x47>
  800968:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096b:	39 d0                	cmp    %edx,%eax
  80096d:	73 2e                	jae    80099d <memmove+0x47>
		s += n;
		d += n;
  80096f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800972:	89 d6                	mov    %edx,%esi
  800974:	09 fe                	or     %edi,%esi
  800976:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80097c:	75 13                	jne    800991 <memmove+0x3b>
  80097e:	f6 c1 03             	test   $0x3,%cl
  800981:	75 0e                	jne    800991 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800983:	83 ef 04             	sub    $0x4,%edi
  800986:	8d 72 fc             	lea    -0x4(%edx),%esi
  800989:	c1 e9 02             	shr    $0x2,%ecx
  80098c:	fd                   	std    
  80098d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098f:	eb 09                	jmp    80099a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800991:	83 ef 01             	sub    $0x1,%edi
  800994:	8d 72 ff             	lea    -0x1(%edx),%esi
  800997:	fd                   	std    
  800998:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099a:	fc                   	cld    
  80099b:	eb 1d                	jmp    8009ba <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099d:	89 f2                	mov    %esi,%edx
  80099f:	09 c2                	or     %eax,%edx
  8009a1:	f6 c2 03             	test   $0x3,%dl
  8009a4:	75 0f                	jne    8009b5 <memmove+0x5f>
  8009a6:	f6 c1 03             	test   $0x3,%cl
  8009a9:	75 0a                	jne    8009b5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009ab:	c1 e9 02             	shr    $0x2,%ecx
  8009ae:	89 c7                	mov    %eax,%edi
  8009b0:	fc                   	cld    
  8009b1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b3:	eb 05                	jmp    8009ba <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b5:	89 c7                	mov    %eax,%edi
  8009b7:	fc                   	cld    
  8009b8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ba:	5e                   	pop    %esi
  8009bb:	5f                   	pop    %edi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009c1:	ff 75 10             	pushl  0x10(%ebp)
  8009c4:	ff 75 0c             	pushl  0xc(%ebp)
  8009c7:	ff 75 08             	pushl  0x8(%ebp)
  8009ca:	e8 87 ff ff ff       	call   800956 <memmove>
}
  8009cf:	c9                   	leave  
  8009d0:	c3                   	ret    

008009d1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009dc:	89 c6                	mov    %eax,%esi
  8009de:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e1:	eb 1a                	jmp    8009fd <memcmp+0x2c>
		if (*s1 != *s2)
  8009e3:	0f b6 08             	movzbl (%eax),%ecx
  8009e6:	0f b6 1a             	movzbl (%edx),%ebx
  8009e9:	38 d9                	cmp    %bl,%cl
  8009eb:	74 0a                	je     8009f7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ed:	0f b6 c1             	movzbl %cl,%eax
  8009f0:	0f b6 db             	movzbl %bl,%ebx
  8009f3:	29 d8                	sub    %ebx,%eax
  8009f5:	eb 0f                	jmp    800a06 <memcmp+0x35>
		s1++, s2++;
  8009f7:	83 c0 01             	add    $0x1,%eax
  8009fa:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fd:	39 f0                	cmp    %esi,%eax
  8009ff:	75 e2                	jne    8009e3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a06:	5b                   	pop    %ebx
  800a07:	5e                   	pop    %esi
  800a08:	5d                   	pop    %ebp
  800a09:	c3                   	ret    

00800a0a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	53                   	push   %ebx
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a11:	89 c1                	mov    %eax,%ecx
  800a13:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a16:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1a:	eb 0a                	jmp    800a26 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1c:	0f b6 10             	movzbl (%eax),%edx
  800a1f:	39 da                	cmp    %ebx,%edx
  800a21:	74 07                	je     800a2a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a23:	83 c0 01             	add    $0x1,%eax
  800a26:	39 c8                	cmp    %ecx,%eax
  800a28:	72 f2                	jb     800a1c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a2a:	5b                   	pop    %ebx
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	57                   	push   %edi
  800a31:	56                   	push   %esi
  800a32:	53                   	push   %ebx
  800a33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a39:	eb 03                	jmp    800a3e <strtol+0x11>
		s++;
  800a3b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3e:	0f b6 01             	movzbl (%ecx),%eax
  800a41:	3c 20                	cmp    $0x20,%al
  800a43:	74 f6                	je     800a3b <strtol+0xe>
  800a45:	3c 09                	cmp    $0x9,%al
  800a47:	74 f2                	je     800a3b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a49:	3c 2b                	cmp    $0x2b,%al
  800a4b:	75 0a                	jne    800a57 <strtol+0x2a>
		s++;
  800a4d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a50:	bf 00 00 00 00       	mov    $0x0,%edi
  800a55:	eb 11                	jmp    800a68 <strtol+0x3b>
  800a57:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a5c:	3c 2d                	cmp    $0x2d,%al
  800a5e:	75 08                	jne    800a68 <strtol+0x3b>
		s++, neg = 1;
  800a60:	83 c1 01             	add    $0x1,%ecx
  800a63:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a68:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a6e:	75 15                	jne    800a85 <strtol+0x58>
  800a70:	80 39 30             	cmpb   $0x30,(%ecx)
  800a73:	75 10                	jne    800a85 <strtol+0x58>
  800a75:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a79:	75 7c                	jne    800af7 <strtol+0xca>
		s += 2, base = 16;
  800a7b:	83 c1 02             	add    $0x2,%ecx
  800a7e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a83:	eb 16                	jmp    800a9b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a85:	85 db                	test   %ebx,%ebx
  800a87:	75 12                	jne    800a9b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a89:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a91:	75 08                	jne    800a9b <strtol+0x6e>
		s++, base = 8;
  800a93:	83 c1 01             	add    $0x1,%ecx
  800a96:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa3:	0f b6 11             	movzbl (%ecx),%edx
  800aa6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa9:	89 f3                	mov    %esi,%ebx
  800aab:	80 fb 09             	cmp    $0x9,%bl
  800aae:	77 08                	ja     800ab8 <strtol+0x8b>
			dig = *s - '0';
  800ab0:	0f be d2             	movsbl %dl,%edx
  800ab3:	83 ea 30             	sub    $0x30,%edx
  800ab6:	eb 22                	jmp    800ada <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ab8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800abb:	89 f3                	mov    %esi,%ebx
  800abd:	80 fb 19             	cmp    $0x19,%bl
  800ac0:	77 08                	ja     800aca <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ac2:	0f be d2             	movsbl %dl,%edx
  800ac5:	83 ea 57             	sub    $0x57,%edx
  800ac8:	eb 10                	jmp    800ada <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aca:	8d 72 bf             	lea    -0x41(%edx),%esi
  800acd:	89 f3                	mov    %esi,%ebx
  800acf:	80 fb 19             	cmp    $0x19,%bl
  800ad2:	77 16                	ja     800aea <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ad4:	0f be d2             	movsbl %dl,%edx
  800ad7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ada:	3b 55 10             	cmp    0x10(%ebp),%edx
  800add:	7d 0b                	jge    800aea <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800adf:	83 c1 01             	add    $0x1,%ecx
  800ae2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ae8:	eb b9                	jmp    800aa3 <strtol+0x76>

	if (endptr)
  800aea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aee:	74 0d                	je     800afd <strtol+0xd0>
		*endptr = (char *) s;
  800af0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af3:	89 0e                	mov    %ecx,(%esi)
  800af5:	eb 06                	jmp    800afd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af7:	85 db                	test   %ebx,%ebx
  800af9:	74 98                	je     800a93 <strtol+0x66>
  800afb:	eb 9e                	jmp    800a9b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800afd:	89 c2                	mov    %eax,%edx
  800aff:	f7 da                	neg    %edx
  800b01:	85 ff                	test   %edi,%edi
  800b03:	0f 45 c2             	cmovne %edx,%eax
}
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	5f                   	pop    %edi
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b11:	b8 00 00 00 00       	mov    $0x0,%eax
  800b16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b19:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1c:	89 c3                	mov    %eax,%ebx
  800b1e:	89 c7                	mov    %eax,%edi
  800b20:	89 c6                	mov    %eax,%esi
  800b22:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b34:	b8 01 00 00 00       	mov    $0x1,%eax
  800b39:	89 d1                	mov    %edx,%ecx
  800b3b:	89 d3                	mov    %edx,%ebx
  800b3d:	89 d7                	mov    %edx,%edi
  800b3f:	89 d6                	mov    %edx,%esi
  800b41:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5f                   	pop    %edi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b51:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b56:	b8 03 00 00 00       	mov    $0x3,%eax
  800b5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5e:	89 cb                	mov    %ecx,%ebx
  800b60:	89 cf                	mov    %ecx,%edi
  800b62:	89 ce                	mov    %ecx,%esi
  800b64:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b66:	85 c0                	test   %eax,%eax
  800b68:	7e 17                	jle    800b81 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6a:	83 ec 0c             	sub    $0xc,%esp
  800b6d:	50                   	push   %eax
  800b6e:	6a 03                	push   $0x3
  800b70:	68 60 11 80 00       	push   $0x801160
  800b75:	6a 23                	push   $0x23
  800b77:	68 7d 11 80 00       	push   $0x80117d
  800b7c:	e8 a3 f5 ff ff       	call   800124 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b94:	b8 02 00 00 00       	mov    $0x2,%eax
  800b99:	89 d1                	mov    %edx,%ecx
  800b9b:	89 d3                	mov    %edx,%ebx
  800b9d:	89 d7                	mov    %edx,%edi
  800b9f:	89 d6                	mov    %edx,%esi
  800ba1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    
  800ba8:	66 90                	xchg   %ax,%ax
  800baa:	66 90                	xchg   %ax,%ax
  800bac:	66 90                	xchg   %ax,%ax
  800bae:	66 90                	xchg   %ax,%ax

00800bb0 <__udivdi3>:
  800bb0:	55                   	push   %ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 1c             	sub    $0x1c,%esp
  800bb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800bbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800bbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800bc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800bc7:	85 f6                	test   %esi,%esi
  800bc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800bcd:	89 ca                	mov    %ecx,%edx
  800bcf:	89 f8                	mov    %edi,%eax
  800bd1:	75 3d                	jne    800c10 <__udivdi3+0x60>
  800bd3:	39 cf                	cmp    %ecx,%edi
  800bd5:	0f 87 c5 00 00 00    	ja     800ca0 <__udivdi3+0xf0>
  800bdb:	85 ff                	test   %edi,%edi
  800bdd:	89 fd                	mov    %edi,%ebp
  800bdf:	75 0b                	jne    800bec <__udivdi3+0x3c>
  800be1:	b8 01 00 00 00       	mov    $0x1,%eax
  800be6:	31 d2                	xor    %edx,%edx
  800be8:	f7 f7                	div    %edi
  800bea:	89 c5                	mov    %eax,%ebp
  800bec:	89 c8                	mov    %ecx,%eax
  800bee:	31 d2                	xor    %edx,%edx
  800bf0:	f7 f5                	div    %ebp
  800bf2:	89 c1                	mov    %eax,%ecx
  800bf4:	89 d8                	mov    %ebx,%eax
  800bf6:	89 cf                	mov    %ecx,%edi
  800bf8:	f7 f5                	div    %ebp
  800bfa:	89 c3                	mov    %eax,%ebx
  800bfc:	89 d8                	mov    %ebx,%eax
  800bfe:	89 fa                	mov    %edi,%edx
  800c00:	83 c4 1c             	add    $0x1c,%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    
  800c08:	90                   	nop
  800c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c10:	39 ce                	cmp    %ecx,%esi
  800c12:	77 74                	ja     800c88 <__udivdi3+0xd8>
  800c14:	0f bd fe             	bsr    %esi,%edi
  800c17:	83 f7 1f             	xor    $0x1f,%edi
  800c1a:	0f 84 98 00 00 00    	je     800cb8 <__udivdi3+0x108>
  800c20:	bb 20 00 00 00       	mov    $0x20,%ebx
  800c25:	89 f9                	mov    %edi,%ecx
  800c27:	89 c5                	mov    %eax,%ebp
  800c29:	29 fb                	sub    %edi,%ebx
  800c2b:	d3 e6                	shl    %cl,%esi
  800c2d:	89 d9                	mov    %ebx,%ecx
  800c2f:	d3 ed                	shr    %cl,%ebp
  800c31:	89 f9                	mov    %edi,%ecx
  800c33:	d3 e0                	shl    %cl,%eax
  800c35:	09 ee                	or     %ebp,%esi
  800c37:	89 d9                	mov    %ebx,%ecx
  800c39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c3d:	89 d5                	mov    %edx,%ebp
  800c3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800c43:	d3 ed                	shr    %cl,%ebp
  800c45:	89 f9                	mov    %edi,%ecx
  800c47:	d3 e2                	shl    %cl,%edx
  800c49:	89 d9                	mov    %ebx,%ecx
  800c4b:	d3 e8                	shr    %cl,%eax
  800c4d:	09 c2                	or     %eax,%edx
  800c4f:	89 d0                	mov    %edx,%eax
  800c51:	89 ea                	mov    %ebp,%edx
  800c53:	f7 f6                	div    %esi
  800c55:	89 d5                	mov    %edx,%ebp
  800c57:	89 c3                	mov    %eax,%ebx
  800c59:	f7 64 24 0c          	mull   0xc(%esp)
  800c5d:	39 d5                	cmp    %edx,%ebp
  800c5f:	72 10                	jb     800c71 <__udivdi3+0xc1>
  800c61:	8b 74 24 08          	mov    0x8(%esp),%esi
  800c65:	89 f9                	mov    %edi,%ecx
  800c67:	d3 e6                	shl    %cl,%esi
  800c69:	39 c6                	cmp    %eax,%esi
  800c6b:	73 07                	jae    800c74 <__udivdi3+0xc4>
  800c6d:	39 d5                	cmp    %edx,%ebp
  800c6f:	75 03                	jne    800c74 <__udivdi3+0xc4>
  800c71:	83 eb 01             	sub    $0x1,%ebx
  800c74:	31 ff                	xor    %edi,%edi
  800c76:	89 d8                	mov    %ebx,%eax
  800c78:	89 fa                	mov    %edi,%edx
  800c7a:	83 c4 1c             	add    $0x1c,%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    
  800c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c88:	31 ff                	xor    %edi,%edi
  800c8a:	31 db                	xor    %ebx,%ebx
  800c8c:	89 d8                	mov    %ebx,%eax
  800c8e:	89 fa                	mov    %edi,%edx
  800c90:	83 c4 1c             	add    $0x1c,%esp
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    
  800c98:	90                   	nop
  800c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ca0:	89 d8                	mov    %ebx,%eax
  800ca2:	f7 f7                	div    %edi
  800ca4:	31 ff                	xor    %edi,%edi
  800ca6:	89 c3                	mov    %eax,%ebx
  800ca8:	89 d8                	mov    %ebx,%eax
  800caa:	89 fa                	mov    %edi,%edx
  800cac:	83 c4 1c             	add    $0x1c,%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    
  800cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cb8:	39 ce                	cmp    %ecx,%esi
  800cba:	72 0c                	jb     800cc8 <__udivdi3+0x118>
  800cbc:	31 db                	xor    %ebx,%ebx
  800cbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800cc2:	0f 87 34 ff ff ff    	ja     800bfc <__udivdi3+0x4c>
  800cc8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ccd:	e9 2a ff ff ff       	jmp    800bfc <__udivdi3+0x4c>
  800cd2:	66 90                	xchg   %ax,%ax
  800cd4:	66 90                	xchg   %ax,%ax
  800cd6:	66 90                	xchg   %ax,%ax
  800cd8:	66 90                	xchg   %ax,%ax
  800cda:	66 90                	xchg   %ax,%ax
  800cdc:	66 90                	xchg   %ax,%ax
  800cde:	66 90                	xchg   %ax,%ax

00800ce0 <__umoddi3>:
  800ce0:	55                   	push   %ebp
  800ce1:	57                   	push   %edi
  800ce2:	56                   	push   %esi
  800ce3:	53                   	push   %ebx
  800ce4:	83 ec 1c             	sub    $0x1c,%esp
  800ce7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ceb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800cef:	8b 74 24 34          	mov    0x34(%esp),%esi
  800cf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800cf7:	85 d2                	test   %edx,%edx
  800cf9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800cfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d01:	89 f3                	mov    %esi,%ebx
  800d03:	89 3c 24             	mov    %edi,(%esp)
  800d06:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d0a:	75 1c                	jne    800d28 <__umoddi3+0x48>
  800d0c:	39 f7                	cmp    %esi,%edi
  800d0e:	76 50                	jbe    800d60 <__umoddi3+0x80>
  800d10:	89 c8                	mov    %ecx,%eax
  800d12:	89 f2                	mov    %esi,%edx
  800d14:	f7 f7                	div    %edi
  800d16:	89 d0                	mov    %edx,%eax
  800d18:	31 d2                	xor    %edx,%edx
  800d1a:	83 c4 1c             	add    $0x1c,%esp
  800d1d:	5b                   	pop    %ebx
  800d1e:	5e                   	pop    %esi
  800d1f:	5f                   	pop    %edi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    
  800d22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d28:	39 f2                	cmp    %esi,%edx
  800d2a:	89 d0                	mov    %edx,%eax
  800d2c:	77 52                	ja     800d80 <__umoddi3+0xa0>
  800d2e:	0f bd ea             	bsr    %edx,%ebp
  800d31:	83 f5 1f             	xor    $0x1f,%ebp
  800d34:	75 5a                	jne    800d90 <__umoddi3+0xb0>
  800d36:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800d3a:	0f 82 e0 00 00 00    	jb     800e20 <__umoddi3+0x140>
  800d40:	39 0c 24             	cmp    %ecx,(%esp)
  800d43:	0f 86 d7 00 00 00    	jbe    800e20 <__umoddi3+0x140>
  800d49:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d4d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d51:	83 c4 1c             	add    $0x1c,%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    
  800d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d60:	85 ff                	test   %edi,%edi
  800d62:	89 fd                	mov    %edi,%ebp
  800d64:	75 0b                	jne    800d71 <__umoddi3+0x91>
  800d66:	b8 01 00 00 00       	mov    $0x1,%eax
  800d6b:	31 d2                	xor    %edx,%edx
  800d6d:	f7 f7                	div    %edi
  800d6f:	89 c5                	mov    %eax,%ebp
  800d71:	89 f0                	mov    %esi,%eax
  800d73:	31 d2                	xor    %edx,%edx
  800d75:	f7 f5                	div    %ebp
  800d77:	89 c8                	mov    %ecx,%eax
  800d79:	f7 f5                	div    %ebp
  800d7b:	89 d0                	mov    %edx,%eax
  800d7d:	eb 99                	jmp    800d18 <__umoddi3+0x38>
  800d7f:	90                   	nop
  800d80:	89 c8                	mov    %ecx,%eax
  800d82:	89 f2                	mov    %esi,%edx
  800d84:	83 c4 1c             	add    $0x1c,%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    
  800d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d90:	8b 34 24             	mov    (%esp),%esi
  800d93:	bf 20 00 00 00       	mov    $0x20,%edi
  800d98:	89 e9                	mov    %ebp,%ecx
  800d9a:	29 ef                	sub    %ebp,%edi
  800d9c:	d3 e0                	shl    %cl,%eax
  800d9e:	89 f9                	mov    %edi,%ecx
  800da0:	89 f2                	mov    %esi,%edx
  800da2:	d3 ea                	shr    %cl,%edx
  800da4:	89 e9                	mov    %ebp,%ecx
  800da6:	09 c2                	or     %eax,%edx
  800da8:	89 d8                	mov    %ebx,%eax
  800daa:	89 14 24             	mov    %edx,(%esp)
  800dad:	89 f2                	mov    %esi,%edx
  800daf:	d3 e2                	shl    %cl,%edx
  800db1:	89 f9                	mov    %edi,%ecx
  800db3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800db7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800dbb:	d3 e8                	shr    %cl,%eax
  800dbd:	89 e9                	mov    %ebp,%ecx
  800dbf:	89 c6                	mov    %eax,%esi
  800dc1:	d3 e3                	shl    %cl,%ebx
  800dc3:	89 f9                	mov    %edi,%ecx
  800dc5:	89 d0                	mov    %edx,%eax
  800dc7:	d3 e8                	shr    %cl,%eax
  800dc9:	89 e9                	mov    %ebp,%ecx
  800dcb:	09 d8                	or     %ebx,%eax
  800dcd:	89 d3                	mov    %edx,%ebx
  800dcf:	89 f2                	mov    %esi,%edx
  800dd1:	f7 34 24             	divl   (%esp)
  800dd4:	89 d6                	mov    %edx,%esi
  800dd6:	d3 e3                	shl    %cl,%ebx
  800dd8:	f7 64 24 04          	mull   0x4(%esp)
  800ddc:	39 d6                	cmp    %edx,%esi
  800dde:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800de2:	89 d1                	mov    %edx,%ecx
  800de4:	89 c3                	mov    %eax,%ebx
  800de6:	72 08                	jb     800df0 <__umoddi3+0x110>
  800de8:	75 11                	jne    800dfb <__umoddi3+0x11b>
  800dea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800dee:	73 0b                	jae    800dfb <__umoddi3+0x11b>
  800df0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800df4:	1b 14 24             	sbb    (%esp),%edx
  800df7:	89 d1                	mov    %edx,%ecx
  800df9:	89 c3                	mov    %eax,%ebx
  800dfb:	8b 54 24 08          	mov    0x8(%esp),%edx
  800dff:	29 da                	sub    %ebx,%edx
  800e01:	19 ce                	sbb    %ecx,%esi
  800e03:	89 f9                	mov    %edi,%ecx
  800e05:	89 f0                	mov    %esi,%eax
  800e07:	d3 e0                	shl    %cl,%eax
  800e09:	89 e9                	mov    %ebp,%ecx
  800e0b:	d3 ea                	shr    %cl,%edx
  800e0d:	89 e9                	mov    %ebp,%ecx
  800e0f:	d3 ee                	shr    %cl,%esi
  800e11:	09 d0                	or     %edx,%eax
  800e13:	89 f2                	mov    %esi,%edx
  800e15:	83 c4 1c             	add    $0x1c,%esp
  800e18:	5b                   	pop    %ebx
  800e19:	5e                   	pop    %esi
  800e1a:	5f                   	pop    %edi
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    
  800e1d:	8d 76 00             	lea    0x0(%esi),%esi
  800e20:	29 f9                	sub    %edi,%ecx
  800e22:	19 d6                	sbb    %edx,%esi
  800e24:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e2c:	e9 18 ff ff ff       	jmp    800d49 <__umoddi3+0x69>
