
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
  800039:	68 60 0e 80 00       	push   $0x800e60
  80003e:	e8 d7 01 00 00       	call   80021a <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 db 0e 80 00       	push   $0x800edb
  80005b:	6a 11                	push   $0x11
  80005d:	68 f8 0e 80 00       	push   $0x800ef8
  800062:	e8 da 00 00 00       	call   800141 <_panic>
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
  800096:	68 80 0e 80 00       	push   $0x800e80
  80009b:	6a 16                	push   $0x16
  80009d:	68 f8 0e 80 00       	push   $0x800ef8
  8000a2:	e8 9a 00 00 00       	call   800141 <_panic>
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
  8000b4:	68 a8 0e 80 00       	push   $0x800ea8
  8000b9:	e8 5c 01 00 00       	call   80021a <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 07 0f 80 00       	push   $0x800f07
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 f8 0e 80 00       	push   $0x800ef8
  8000d7:	e8 65 00 00 00       	call   800141 <_panic>

008000dc <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000e7:	c7 05 20 20 c0 00 00 	movl   $0x0,0xc02020
  8000ee:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  8000f1:	e8 b0 0a 00 00       	call   800ba6 <sys_getenvid>
  8000f6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fb:	8d 04 40             	lea    (%eax,%eax,2),%eax
  8000fe:	c1 e0 05             	shl    $0x5,%eax
  800101:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800106:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010b:	85 db                	test   %ebx,%ebx
  80010d:	7e 07                	jle    800116 <libmain+0x3a>
		binaryname = argv[0];
  80010f:	8b 06                	mov    (%esi),%eax
  800111:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800116:	83 ec 08             	sub    $0x8,%esp
  800119:	56                   	push   %esi
  80011a:	53                   	push   %ebx
  80011b:	e8 13 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800120:	e8 0a 00 00 00       	call   80012f <exit>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012b:	5b                   	pop    %ebx
  80012c:	5e                   	pop    %esi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800135:	6a 00                	push   $0x0
  800137:	e8 29 0a 00 00       	call   800b65 <sys_env_destroy>
}
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800146:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800149:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80014f:	e8 52 0a 00 00       	call   800ba6 <sys_getenvid>
  800154:	83 ec 0c             	sub    $0xc,%esp
  800157:	ff 75 0c             	pushl  0xc(%ebp)
  80015a:	ff 75 08             	pushl  0x8(%ebp)
  80015d:	56                   	push   %esi
  80015e:	50                   	push   %eax
  80015f:	68 28 0f 80 00       	push   $0x800f28
  800164:	e8 b1 00 00 00       	call   80021a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800169:	83 c4 18             	add    $0x18,%esp
  80016c:	53                   	push   %ebx
  80016d:	ff 75 10             	pushl  0x10(%ebp)
  800170:	e8 54 00 00 00       	call   8001c9 <vcprintf>
	cprintf("\n");
  800175:	c7 04 24 f6 0e 80 00 	movl   $0x800ef6,(%esp)
  80017c:	e8 99 00 00 00       	call   80021a <cprintf>
  800181:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800184:	cc                   	int3   
  800185:	eb fd                	jmp    800184 <_panic+0x43>

00800187 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	53                   	push   %ebx
  80018b:	83 ec 04             	sub    $0x4,%esp
  80018e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800191:	8b 13                	mov    (%ebx),%edx
  800193:	8d 42 01             	lea    0x1(%edx),%eax
  800196:	89 03                	mov    %eax,(%ebx)
  800198:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019f:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a4:	75 1a                	jne    8001c0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a6:	83 ec 08             	sub    $0x8,%esp
  8001a9:	68 ff 00 00 00       	push   $0xff
  8001ae:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b1:	50                   	push   %eax
  8001b2:	e8 71 09 00 00       	call   800b28 <sys_cputs>
		b->idx = 0;
  8001b7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001bd:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c7:	c9                   	leave  
  8001c8:	c3                   	ret    

008001c9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d9:	00 00 00 
	b.cnt = 0;
  8001dc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e6:	ff 75 0c             	pushl  0xc(%ebp)
  8001e9:	ff 75 08             	pushl  0x8(%ebp)
  8001ec:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	68 87 01 80 00       	push   $0x800187
  8001f8:	e8 54 01 00 00       	call   800351 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fd:	83 c4 08             	add    $0x8,%esp
  800200:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800206:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020c:	50                   	push   %eax
  80020d:	e8 16 09 00 00       	call   800b28 <sys_cputs>

	return b.cnt;
}
  800212:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800220:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800223:	50                   	push   %eax
  800224:	ff 75 08             	pushl  0x8(%ebp)
  800227:	e8 9d ff ff ff       	call   8001c9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022c:	c9                   	leave  
  80022d:	c3                   	ret    

0080022e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	57                   	push   %edi
  800232:	56                   	push   %esi
  800233:	53                   	push   %ebx
  800234:	83 ec 1c             	sub    $0x1c,%esp
  800237:	89 c7                	mov    %eax,%edi
  800239:	89 d6                	mov    %edx,%esi
  80023b:	8b 45 08             	mov    0x8(%ebp),%eax
  80023e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800241:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800244:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800247:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80024a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800252:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800255:	39 d3                	cmp    %edx,%ebx
  800257:	72 05                	jb     80025e <printnum+0x30>
  800259:	39 45 10             	cmp    %eax,0x10(%ebp)
  80025c:	77 45                	ja     8002a3 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025e:	83 ec 0c             	sub    $0xc,%esp
  800261:	ff 75 18             	pushl  0x18(%ebp)
  800264:	8b 45 14             	mov    0x14(%ebp),%eax
  800267:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80026a:	53                   	push   %ebx
  80026b:	ff 75 10             	pushl  0x10(%ebp)
  80026e:	83 ec 08             	sub    $0x8,%esp
  800271:	ff 75 e4             	pushl  -0x1c(%ebp)
  800274:	ff 75 e0             	pushl  -0x20(%ebp)
  800277:	ff 75 dc             	pushl  -0x24(%ebp)
  80027a:	ff 75 d8             	pushl  -0x28(%ebp)
  80027d:	e8 4e 09 00 00       	call   800bd0 <__udivdi3>
  800282:	83 c4 18             	add    $0x18,%esp
  800285:	52                   	push   %edx
  800286:	50                   	push   %eax
  800287:	89 f2                	mov    %esi,%edx
  800289:	89 f8                	mov    %edi,%eax
  80028b:	e8 9e ff ff ff       	call   80022e <printnum>
  800290:	83 c4 20             	add    $0x20,%esp
  800293:	eb 18                	jmp    8002ad <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800295:	83 ec 08             	sub    $0x8,%esp
  800298:	56                   	push   %esi
  800299:	ff 75 18             	pushl  0x18(%ebp)
  80029c:	ff d7                	call   *%edi
  80029e:	83 c4 10             	add    $0x10,%esp
  8002a1:	eb 03                	jmp    8002a6 <printnum+0x78>
  8002a3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a6:	83 eb 01             	sub    $0x1,%ebx
  8002a9:	85 db                	test   %ebx,%ebx
  8002ab:	7f e8                	jg     800295 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	56                   	push   %esi
  8002b1:	83 ec 04             	sub    $0x4,%esp
  8002b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8002bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c0:	e8 3b 0a 00 00       	call   800d00 <__umoddi3>
  8002c5:	83 c4 14             	add    $0x14,%esp
  8002c8:	0f be 80 4c 0f 80 00 	movsbl 0x800f4c(%eax),%eax
  8002cf:	50                   	push   %eax
  8002d0:	ff d7                	call   *%edi
}
  8002d2:	83 c4 10             	add    $0x10,%esp
  8002d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d8:	5b                   	pop    %ebx
  8002d9:	5e                   	pop    %esi
  8002da:	5f                   	pop    %edi
  8002db:	5d                   	pop    %ebp
  8002dc:	c3                   	ret    

008002dd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e0:	83 fa 01             	cmp    $0x1,%edx
  8002e3:	7e 0e                	jle    8002f3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e5:	8b 10                	mov    (%eax),%edx
  8002e7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ea:	89 08                	mov    %ecx,(%eax)
  8002ec:	8b 02                	mov    (%edx),%eax
  8002ee:	8b 52 04             	mov    0x4(%edx),%edx
  8002f1:	eb 22                	jmp    800315 <getuint+0x38>
	else if (lflag)
  8002f3:	85 d2                	test   %edx,%edx
  8002f5:	74 10                	je     800307 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f7:	8b 10                	mov    (%eax),%edx
  8002f9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fc:	89 08                	mov    %ecx,(%eax)
  8002fe:	8b 02                	mov    (%edx),%eax
  800300:	ba 00 00 00 00       	mov    $0x0,%edx
  800305:	eb 0e                	jmp    800315 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800307:	8b 10                	mov    (%eax),%edx
  800309:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030c:	89 08                	mov    %ecx,(%eax)
  80030e:	8b 02                	mov    (%edx),%eax
  800310:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80031d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800321:	8b 10                	mov    (%eax),%edx
  800323:	3b 50 04             	cmp    0x4(%eax),%edx
  800326:	73 0a                	jae    800332 <sprintputch+0x1b>
		*b->buf++ = ch;
  800328:	8d 4a 01             	lea    0x1(%edx),%ecx
  80032b:	89 08                	mov    %ecx,(%eax)
  80032d:	8b 45 08             	mov    0x8(%ebp),%eax
  800330:	88 02                	mov    %al,(%edx)
}
  800332:	5d                   	pop    %ebp
  800333:	c3                   	ret    

00800334 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80033a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033d:	50                   	push   %eax
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	ff 75 0c             	pushl  0xc(%ebp)
  800344:	ff 75 08             	pushl  0x8(%ebp)
  800347:	e8 05 00 00 00       	call   800351 <vprintfmt>
	va_end(ap);
}
  80034c:	83 c4 10             	add    $0x10,%esp
  80034f:	c9                   	leave  
  800350:	c3                   	ret    

00800351 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	57                   	push   %edi
  800355:	56                   	push   %esi
  800356:	53                   	push   %ebx
  800357:	83 ec 2c             	sub    $0x2c,%esp
  80035a:	8b 75 08             	mov    0x8(%ebp),%esi
  80035d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800360:	8b 7d 10             	mov    0x10(%ebp),%edi
  800363:	eb 12                	jmp    800377 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800365:	85 c0                	test   %eax,%eax
  800367:	0f 84 cb 03 00 00    	je     800738 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  80036d:	83 ec 08             	sub    $0x8,%esp
  800370:	53                   	push   %ebx
  800371:	50                   	push   %eax
  800372:	ff d6                	call   *%esi
  800374:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800377:	83 c7 01             	add    $0x1,%edi
  80037a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80037e:	83 f8 25             	cmp    $0x25,%eax
  800381:	75 e2                	jne    800365 <vprintfmt+0x14>
  800383:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800387:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80038e:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800395:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80039c:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a1:	eb 07                	jmp    8003aa <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8d 47 01             	lea    0x1(%edi),%eax
  8003ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b0:	0f b6 07             	movzbl (%edi),%eax
  8003b3:	0f b6 c8             	movzbl %al,%ecx
  8003b6:	83 e8 23             	sub    $0x23,%eax
  8003b9:	3c 55                	cmp    $0x55,%al
  8003bb:	0f 87 5c 03 00 00    	ja     80071d <vprintfmt+0x3cc>
  8003c1:	0f b6 c0             	movzbl %al,%eax
  8003c4:	ff 24 85 00 10 80 00 	jmp    *0x801000(,%eax,4)
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ce:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003d2:	eb d6                	jmp    8003aa <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003dc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003df:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003e2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003ec:	83 fa 09             	cmp    $0x9,%edx
  8003ef:	77 39                	ja     80042a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f4:	eb e9                	jmp    8003df <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f9:	8d 48 04             	lea    0x4(%eax),%ecx
  8003fc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ff:	8b 00                	mov    (%eax),%eax
  800401:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800407:	eb 27                	jmp    800430 <vprintfmt+0xdf>
  800409:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040c:	85 c0                	test   %eax,%eax
  80040e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800413:	0f 49 c8             	cmovns %eax,%ecx
  800416:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041c:	eb 8c                	jmp    8003aa <vprintfmt+0x59>
  80041e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800421:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800428:	eb 80                	jmp    8003aa <vprintfmt+0x59>
  80042a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80042d:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800430:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800434:	0f 89 70 ff ff ff    	jns    8003aa <vprintfmt+0x59>
				width = precision, precision = -1;
  80043a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80043d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800440:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800447:	e9 5e ff ff ff       	jmp    8003aa <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80044c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800452:	e9 53 ff ff ff       	jmp    8003aa <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800457:	8b 45 14             	mov    0x14(%ebp),%eax
  80045a:	8d 50 04             	lea    0x4(%eax),%edx
  80045d:	89 55 14             	mov    %edx,0x14(%ebp)
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	53                   	push   %ebx
  800464:	ff 30                	pushl  (%eax)
  800466:	ff d6                	call   *%esi
			break;
  800468:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80046e:	e9 04 ff ff ff       	jmp    800377 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800473:	8b 45 14             	mov    0x14(%ebp),%eax
  800476:	8d 50 04             	lea    0x4(%eax),%edx
  800479:	89 55 14             	mov    %edx,0x14(%ebp)
  80047c:	8b 00                	mov    (%eax),%eax
  80047e:	99                   	cltd   
  80047f:	31 d0                	xor    %edx,%eax
  800481:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800483:	83 f8 07             	cmp    $0x7,%eax
  800486:	7f 0b                	jg     800493 <vprintfmt+0x142>
  800488:	8b 14 85 60 11 80 00 	mov    0x801160(,%eax,4),%edx
  80048f:	85 d2                	test   %edx,%edx
  800491:	75 18                	jne    8004ab <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800493:	50                   	push   %eax
  800494:	68 64 0f 80 00       	push   $0x800f64
  800499:	53                   	push   %ebx
  80049a:	56                   	push   %esi
  80049b:	e8 94 fe ff ff       	call   800334 <printfmt>
  8004a0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a6:	e9 cc fe ff ff       	jmp    800377 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004ab:	52                   	push   %edx
  8004ac:	68 6d 0f 80 00       	push   $0x800f6d
  8004b1:	53                   	push   %ebx
  8004b2:	56                   	push   %esi
  8004b3:	e8 7c fe ff ff       	call   800334 <printfmt>
  8004b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004be:	e9 b4 fe ff ff       	jmp    800377 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c6:	8d 50 04             	lea    0x4(%eax),%edx
  8004c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cc:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ce:	85 ff                	test   %edi,%edi
  8004d0:	b8 5d 0f 80 00       	mov    $0x800f5d,%eax
  8004d5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004dc:	0f 8e 94 00 00 00    	jle    800576 <vprintfmt+0x225>
  8004e2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e6:	0f 84 98 00 00 00    	je     800584 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	ff 75 c8             	pushl  -0x38(%ebp)
  8004f2:	57                   	push   %edi
  8004f3:	e8 c8 02 00 00       	call   8007c0 <strnlen>
  8004f8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004fb:	29 c1                	sub    %eax,%ecx
  8004fd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800500:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800503:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800507:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80050d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050f:	eb 0f                	jmp    800520 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	53                   	push   %ebx
  800515:	ff 75 e0             	pushl  -0x20(%ebp)
  800518:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051a:	83 ef 01             	sub    $0x1,%edi
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	85 ff                	test   %edi,%edi
  800522:	7f ed                	jg     800511 <vprintfmt+0x1c0>
  800524:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800527:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80052a:	85 c9                	test   %ecx,%ecx
  80052c:	b8 00 00 00 00       	mov    $0x0,%eax
  800531:	0f 49 c1             	cmovns %ecx,%eax
  800534:	29 c1                	sub    %eax,%ecx
  800536:	89 75 08             	mov    %esi,0x8(%ebp)
  800539:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80053c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053f:	89 cb                	mov    %ecx,%ebx
  800541:	eb 4d                	jmp    800590 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800543:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800547:	74 1b                	je     800564 <vprintfmt+0x213>
  800549:	0f be c0             	movsbl %al,%eax
  80054c:	83 e8 20             	sub    $0x20,%eax
  80054f:	83 f8 5e             	cmp    $0x5e,%eax
  800552:	76 10                	jbe    800564 <vprintfmt+0x213>
					putch('?', putdat);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	ff 75 0c             	pushl  0xc(%ebp)
  80055a:	6a 3f                	push   $0x3f
  80055c:	ff 55 08             	call   *0x8(%ebp)
  80055f:	83 c4 10             	add    $0x10,%esp
  800562:	eb 0d                	jmp    800571 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	ff 75 0c             	pushl  0xc(%ebp)
  80056a:	52                   	push   %edx
  80056b:	ff 55 08             	call   *0x8(%ebp)
  80056e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800571:	83 eb 01             	sub    $0x1,%ebx
  800574:	eb 1a                	jmp    800590 <vprintfmt+0x23f>
  800576:	89 75 08             	mov    %esi,0x8(%ebp)
  800579:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80057c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800582:	eb 0c                	jmp    800590 <vprintfmt+0x23f>
  800584:	89 75 08             	mov    %esi,0x8(%ebp)
  800587:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80058a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800590:	83 c7 01             	add    $0x1,%edi
  800593:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800597:	0f be d0             	movsbl %al,%edx
  80059a:	85 d2                	test   %edx,%edx
  80059c:	74 23                	je     8005c1 <vprintfmt+0x270>
  80059e:	85 f6                	test   %esi,%esi
  8005a0:	78 a1                	js     800543 <vprintfmt+0x1f2>
  8005a2:	83 ee 01             	sub    $0x1,%esi
  8005a5:	79 9c                	jns    800543 <vprintfmt+0x1f2>
  8005a7:	89 df                	mov    %ebx,%edi
  8005a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005af:	eb 18                	jmp    8005c9 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	53                   	push   %ebx
  8005b5:	6a 20                	push   $0x20
  8005b7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b9:	83 ef 01             	sub    $0x1,%edi
  8005bc:	83 c4 10             	add    $0x10,%esp
  8005bf:	eb 08                	jmp    8005c9 <vprintfmt+0x278>
  8005c1:	89 df                	mov    %ebx,%edi
  8005c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c9:	85 ff                	test   %edi,%edi
  8005cb:	7f e4                	jg     8005b1 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d0:	e9 a2 fd ff ff       	jmp    800377 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d5:	83 fa 01             	cmp    $0x1,%edx
  8005d8:	7e 16                	jle    8005f0 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8d 50 08             	lea    0x8(%eax),%edx
  8005e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e3:	8b 50 04             	mov    0x4(%eax),%edx
  8005e6:	8b 00                	mov    (%eax),%eax
  8005e8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005eb:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005ee:	eb 32                	jmp    800622 <vprintfmt+0x2d1>
	else if (lflag)
  8005f0:	85 d2                	test   %edx,%edx
  8005f2:	74 18                	je     80060c <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 04             	lea    0x4(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fd:	8b 00                	mov    (%eax),%eax
  8005ff:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800602:	89 c1                	mov    %eax,%ecx
  800604:	c1 f9 1f             	sar    $0x1f,%ecx
  800607:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80060a:	eb 16                	jmp    800622 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8d 50 04             	lea    0x4(%eax),%edx
  800612:	89 55 14             	mov    %edx,0x14(%ebp)
  800615:	8b 00                	mov    (%eax),%eax
  800617:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80061a:	89 c1                	mov    %eax,%ecx
  80061c:	c1 f9 1f             	sar    $0x1f,%ecx
  80061f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800622:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800625:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800628:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80062e:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800633:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800637:	0f 89 a8 00 00 00    	jns    8006e5 <vprintfmt+0x394>
				putch('-', putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	53                   	push   %ebx
  800641:	6a 2d                	push   $0x2d
  800643:	ff d6                	call   *%esi
				num = -(long long) num;
  800645:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800648:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80064b:	f7 d8                	neg    %eax
  80064d:	83 d2 00             	adc    $0x0,%edx
  800650:	f7 da                	neg    %edx
  800652:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800655:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800658:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80065b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800660:	e9 80 00 00 00       	jmp    8006e5 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800665:	8d 45 14             	lea    0x14(%ebp),%eax
  800668:	e8 70 fc ff ff       	call   8002dd <getuint>
  80066d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800670:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800673:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800678:	eb 6b                	jmp    8006e5 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80067a:	8d 45 14             	lea    0x14(%ebp),%eax
  80067d:	e8 5b fc ff ff       	call   8002dd <getuint>
  800682:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800685:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800688:	6a 04                	push   $0x4
  80068a:	6a 03                	push   $0x3
  80068c:	6a 01                	push   $0x1
  80068e:	68 70 0f 80 00       	push   $0x800f70
  800693:	e8 82 fb ff ff       	call   80021a <cprintf>
			goto number;
  800698:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  80069b:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  8006a0:	eb 43                	jmp    8006e5 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a2:	83 ec 08             	sub    $0x8,%esp
  8006a5:	53                   	push   %ebx
  8006a6:	6a 30                	push   $0x30
  8006a8:	ff d6                	call   *%esi
			putch('x', putdat);
  8006aa:	83 c4 08             	add    $0x8,%esp
  8006ad:	53                   	push   %ebx
  8006ae:	6a 78                	push   $0x78
  8006b0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 50 04             	lea    0x4(%eax),%edx
  8006b8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006bb:	8b 00                	mov    (%eax),%eax
  8006bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c5:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006cb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d0:	eb 13                	jmp    8006e5 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d5:	e8 03 fc ff ff       	call   8002dd <getuint>
  8006da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006e0:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e5:	83 ec 0c             	sub    $0xc,%esp
  8006e8:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006ec:	52                   	push   %edx
  8006ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f0:	50                   	push   %eax
  8006f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8006f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8006f7:	89 da                	mov    %ebx,%edx
  8006f9:	89 f0                	mov    %esi,%eax
  8006fb:	e8 2e fb ff ff       	call   80022e <printnum>

			break;
  800700:	83 c4 20             	add    $0x20,%esp
  800703:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800706:	e9 6c fc ff ff       	jmp    800377 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	53                   	push   %ebx
  80070f:	51                   	push   %ecx
  800710:	ff d6                	call   *%esi
			break;
  800712:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800715:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800718:	e9 5a fc ff ff       	jmp    800377 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80071d:	83 ec 08             	sub    $0x8,%esp
  800720:	53                   	push   %ebx
  800721:	6a 25                	push   $0x25
  800723:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800725:	83 c4 10             	add    $0x10,%esp
  800728:	eb 03                	jmp    80072d <vprintfmt+0x3dc>
  80072a:	83 ef 01             	sub    $0x1,%edi
  80072d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800731:	75 f7                	jne    80072a <vprintfmt+0x3d9>
  800733:	e9 3f fc ff ff       	jmp    800377 <vprintfmt+0x26>
			break;
		}

	}

}
  800738:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80073b:	5b                   	pop    %ebx
  80073c:	5e                   	pop    %esi
  80073d:	5f                   	pop    %edi
  80073e:	5d                   	pop    %ebp
  80073f:	c3                   	ret    

00800740 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	83 ec 18             	sub    $0x18,%esp
  800746:	8b 45 08             	mov    0x8(%ebp),%eax
  800749:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800753:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800756:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075d:	85 c0                	test   %eax,%eax
  80075f:	74 26                	je     800787 <vsnprintf+0x47>
  800761:	85 d2                	test   %edx,%edx
  800763:	7e 22                	jle    800787 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800765:	ff 75 14             	pushl  0x14(%ebp)
  800768:	ff 75 10             	pushl  0x10(%ebp)
  80076b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076e:	50                   	push   %eax
  80076f:	68 17 03 80 00       	push   $0x800317
  800774:	e8 d8 fb ff ff       	call   800351 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800779:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	eb 05                	jmp    80078c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800787:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80078c:	c9                   	leave  
  80078d:	c3                   	ret    

0080078e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800794:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800797:	50                   	push   %eax
  800798:	ff 75 10             	pushl  0x10(%ebp)
  80079b:	ff 75 0c             	pushl  0xc(%ebp)
  80079e:	ff 75 08             	pushl  0x8(%ebp)
  8007a1:	e8 9a ff ff ff       	call   800740 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b3:	eb 03                	jmp    8007b8 <strlen+0x10>
		n++;
  8007b5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007bc:	75 f7                	jne    8007b5 <strlen+0xd>
		n++;
	return n;
}
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ce:	eb 03                	jmp    8007d3 <strnlen+0x13>
		n++;
  8007d0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d3:	39 c2                	cmp    %eax,%edx
  8007d5:	74 08                	je     8007df <strnlen+0x1f>
  8007d7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007db:	75 f3                	jne    8007d0 <strnlen+0x10>
  8007dd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	53                   	push   %ebx
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007eb:	89 c2                	mov    %eax,%edx
  8007ed:	83 c2 01             	add    $0x1,%edx
  8007f0:	83 c1 01             	add    $0x1,%ecx
  8007f3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007f7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007fa:	84 db                	test   %bl,%bl
  8007fc:	75 ef                	jne    8007ed <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007fe:	5b                   	pop    %ebx
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	53                   	push   %ebx
  800805:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800808:	53                   	push   %ebx
  800809:	e8 9a ff ff ff       	call   8007a8 <strlen>
  80080e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800811:	ff 75 0c             	pushl  0xc(%ebp)
  800814:	01 d8                	add    %ebx,%eax
  800816:	50                   	push   %eax
  800817:	e8 c5 ff ff ff       	call   8007e1 <strcpy>
	return dst;
}
  80081c:	89 d8                	mov    %ebx,%eax
  80081e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800821:	c9                   	leave  
  800822:	c3                   	ret    

00800823 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	56                   	push   %esi
  800827:	53                   	push   %ebx
  800828:	8b 75 08             	mov    0x8(%ebp),%esi
  80082b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082e:	89 f3                	mov    %esi,%ebx
  800830:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800833:	89 f2                	mov    %esi,%edx
  800835:	eb 0f                	jmp    800846 <strncpy+0x23>
		*dst++ = *src;
  800837:	83 c2 01             	add    $0x1,%edx
  80083a:	0f b6 01             	movzbl (%ecx),%eax
  80083d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800840:	80 39 01             	cmpb   $0x1,(%ecx)
  800843:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800846:	39 da                	cmp    %ebx,%edx
  800848:	75 ed                	jne    800837 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80084a:	89 f0                	mov    %esi,%eax
  80084c:	5b                   	pop    %ebx
  80084d:	5e                   	pop    %esi
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	56                   	push   %esi
  800854:	53                   	push   %ebx
  800855:	8b 75 08             	mov    0x8(%ebp),%esi
  800858:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085b:	8b 55 10             	mov    0x10(%ebp),%edx
  80085e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800860:	85 d2                	test   %edx,%edx
  800862:	74 21                	je     800885 <strlcpy+0x35>
  800864:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800868:	89 f2                	mov    %esi,%edx
  80086a:	eb 09                	jmp    800875 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80086c:	83 c2 01             	add    $0x1,%edx
  80086f:	83 c1 01             	add    $0x1,%ecx
  800872:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800875:	39 c2                	cmp    %eax,%edx
  800877:	74 09                	je     800882 <strlcpy+0x32>
  800879:	0f b6 19             	movzbl (%ecx),%ebx
  80087c:	84 db                	test   %bl,%bl
  80087e:	75 ec                	jne    80086c <strlcpy+0x1c>
  800880:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800882:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800885:	29 f0                	sub    %esi,%eax
}
  800887:	5b                   	pop    %ebx
  800888:	5e                   	pop    %esi
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800891:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800894:	eb 06                	jmp    80089c <strcmp+0x11>
		p++, q++;
  800896:	83 c1 01             	add    $0x1,%ecx
  800899:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80089c:	0f b6 01             	movzbl (%ecx),%eax
  80089f:	84 c0                	test   %al,%al
  8008a1:	74 04                	je     8008a7 <strcmp+0x1c>
  8008a3:	3a 02                	cmp    (%edx),%al
  8008a5:	74 ef                	je     800896 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a7:	0f b6 c0             	movzbl %al,%eax
  8008aa:	0f b6 12             	movzbl (%edx),%edx
  8008ad:	29 d0                	sub    %edx,%eax
}
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	53                   	push   %ebx
  8008b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bb:	89 c3                	mov    %eax,%ebx
  8008bd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c0:	eb 06                	jmp    8008c8 <strncmp+0x17>
		n--, p++, q++;
  8008c2:	83 c0 01             	add    $0x1,%eax
  8008c5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c8:	39 d8                	cmp    %ebx,%eax
  8008ca:	74 15                	je     8008e1 <strncmp+0x30>
  8008cc:	0f b6 08             	movzbl (%eax),%ecx
  8008cf:	84 c9                	test   %cl,%cl
  8008d1:	74 04                	je     8008d7 <strncmp+0x26>
  8008d3:	3a 0a                	cmp    (%edx),%cl
  8008d5:	74 eb                	je     8008c2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d7:	0f b6 00             	movzbl (%eax),%eax
  8008da:	0f b6 12             	movzbl (%edx),%edx
  8008dd:	29 d0                	sub    %edx,%eax
  8008df:	eb 05                	jmp    8008e6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e6:	5b                   	pop    %ebx
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f3:	eb 07                	jmp    8008fc <strchr+0x13>
		if (*s == c)
  8008f5:	38 ca                	cmp    %cl,%dl
  8008f7:	74 0f                	je     800908 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f9:	83 c0 01             	add    $0x1,%eax
  8008fc:	0f b6 10             	movzbl (%eax),%edx
  8008ff:	84 d2                	test   %dl,%dl
  800901:	75 f2                	jne    8008f5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800914:	eb 03                	jmp    800919 <strfind+0xf>
  800916:	83 c0 01             	add    $0x1,%eax
  800919:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80091c:	38 ca                	cmp    %cl,%dl
  80091e:	74 04                	je     800924 <strfind+0x1a>
  800920:	84 d2                	test   %dl,%dl
  800922:	75 f2                	jne    800916 <strfind+0xc>
			break;
	return (char *) s;
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	57                   	push   %edi
  80092a:	56                   	push   %esi
  80092b:	53                   	push   %ebx
  80092c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800932:	85 c9                	test   %ecx,%ecx
  800934:	74 36                	je     80096c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800936:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093c:	75 28                	jne    800966 <memset+0x40>
  80093e:	f6 c1 03             	test   $0x3,%cl
  800941:	75 23                	jne    800966 <memset+0x40>
		c &= 0xFF;
  800943:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800947:	89 d3                	mov    %edx,%ebx
  800949:	c1 e3 08             	shl    $0x8,%ebx
  80094c:	89 d6                	mov    %edx,%esi
  80094e:	c1 e6 18             	shl    $0x18,%esi
  800951:	89 d0                	mov    %edx,%eax
  800953:	c1 e0 10             	shl    $0x10,%eax
  800956:	09 f0                	or     %esi,%eax
  800958:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80095a:	89 d8                	mov    %ebx,%eax
  80095c:	09 d0                	or     %edx,%eax
  80095e:	c1 e9 02             	shr    $0x2,%ecx
  800961:	fc                   	cld    
  800962:	f3 ab                	rep stos %eax,%es:(%edi)
  800964:	eb 06                	jmp    80096c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	fc                   	cld    
  80096a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096c:	89 f8                	mov    %edi,%eax
  80096e:	5b                   	pop    %ebx
  80096f:	5e                   	pop    %esi
  800970:	5f                   	pop    %edi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	57                   	push   %edi
  800977:	56                   	push   %esi
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800981:	39 c6                	cmp    %eax,%esi
  800983:	73 35                	jae    8009ba <memmove+0x47>
  800985:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800988:	39 d0                	cmp    %edx,%eax
  80098a:	73 2e                	jae    8009ba <memmove+0x47>
		s += n;
		d += n;
  80098c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098f:	89 d6                	mov    %edx,%esi
  800991:	09 fe                	or     %edi,%esi
  800993:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800999:	75 13                	jne    8009ae <memmove+0x3b>
  80099b:	f6 c1 03             	test   $0x3,%cl
  80099e:	75 0e                	jne    8009ae <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009a0:	83 ef 04             	sub    $0x4,%edi
  8009a3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a6:	c1 e9 02             	shr    $0x2,%ecx
  8009a9:	fd                   	std    
  8009aa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ac:	eb 09                	jmp    8009b7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ae:	83 ef 01             	sub    $0x1,%edi
  8009b1:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009b4:	fd                   	std    
  8009b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b7:	fc                   	cld    
  8009b8:	eb 1d                	jmp    8009d7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ba:	89 f2                	mov    %esi,%edx
  8009bc:	09 c2                	or     %eax,%edx
  8009be:	f6 c2 03             	test   $0x3,%dl
  8009c1:	75 0f                	jne    8009d2 <memmove+0x5f>
  8009c3:	f6 c1 03             	test   $0x3,%cl
  8009c6:	75 0a                	jne    8009d2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009c8:	c1 e9 02             	shr    $0x2,%ecx
  8009cb:	89 c7                	mov    %eax,%edi
  8009cd:	fc                   	cld    
  8009ce:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d0:	eb 05                	jmp    8009d7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d2:	89 c7                	mov    %eax,%edi
  8009d4:	fc                   	cld    
  8009d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d7:	5e                   	pop    %esi
  8009d8:	5f                   	pop    %edi
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009de:	ff 75 10             	pushl  0x10(%ebp)
  8009e1:	ff 75 0c             	pushl  0xc(%ebp)
  8009e4:	ff 75 08             	pushl  0x8(%ebp)
  8009e7:	e8 87 ff ff ff       	call   800973 <memmove>
}
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	56                   	push   %esi
  8009f2:	53                   	push   %ebx
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f9:	89 c6                	mov    %eax,%esi
  8009fb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fe:	eb 1a                	jmp    800a1a <memcmp+0x2c>
		if (*s1 != *s2)
  800a00:	0f b6 08             	movzbl (%eax),%ecx
  800a03:	0f b6 1a             	movzbl (%edx),%ebx
  800a06:	38 d9                	cmp    %bl,%cl
  800a08:	74 0a                	je     800a14 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a0a:	0f b6 c1             	movzbl %cl,%eax
  800a0d:	0f b6 db             	movzbl %bl,%ebx
  800a10:	29 d8                	sub    %ebx,%eax
  800a12:	eb 0f                	jmp    800a23 <memcmp+0x35>
		s1++, s2++;
  800a14:	83 c0 01             	add    $0x1,%eax
  800a17:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1a:	39 f0                	cmp    %esi,%eax
  800a1c:	75 e2                	jne    800a00 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a23:	5b                   	pop    %ebx
  800a24:	5e                   	pop    %esi
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	53                   	push   %ebx
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a2e:	89 c1                	mov    %eax,%ecx
  800a30:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a33:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a37:	eb 0a                	jmp    800a43 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a39:	0f b6 10             	movzbl (%eax),%edx
  800a3c:	39 da                	cmp    %ebx,%edx
  800a3e:	74 07                	je     800a47 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a40:	83 c0 01             	add    $0x1,%eax
  800a43:	39 c8                	cmp    %ecx,%eax
  800a45:	72 f2                	jb     800a39 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a47:	5b                   	pop    %ebx
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	57                   	push   %edi
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
  800a50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a56:	eb 03                	jmp    800a5b <strtol+0x11>
		s++;
  800a58:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5b:	0f b6 01             	movzbl (%ecx),%eax
  800a5e:	3c 20                	cmp    $0x20,%al
  800a60:	74 f6                	je     800a58 <strtol+0xe>
  800a62:	3c 09                	cmp    $0x9,%al
  800a64:	74 f2                	je     800a58 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a66:	3c 2b                	cmp    $0x2b,%al
  800a68:	75 0a                	jne    800a74 <strtol+0x2a>
		s++;
  800a6a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a6d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a72:	eb 11                	jmp    800a85 <strtol+0x3b>
  800a74:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a79:	3c 2d                	cmp    $0x2d,%al
  800a7b:	75 08                	jne    800a85 <strtol+0x3b>
		s++, neg = 1;
  800a7d:	83 c1 01             	add    $0x1,%ecx
  800a80:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a85:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a8b:	75 15                	jne    800aa2 <strtol+0x58>
  800a8d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a90:	75 10                	jne    800aa2 <strtol+0x58>
  800a92:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a96:	75 7c                	jne    800b14 <strtol+0xca>
		s += 2, base = 16;
  800a98:	83 c1 02             	add    $0x2,%ecx
  800a9b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa0:	eb 16                	jmp    800ab8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aa2:	85 db                	test   %ebx,%ebx
  800aa4:	75 12                	jne    800ab8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aab:	80 39 30             	cmpb   $0x30,(%ecx)
  800aae:	75 08                	jne    800ab8 <strtol+0x6e>
		s++, base = 8;
  800ab0:	83 c1 01             	add    $0x1,%ecx
  800ab3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ab8:	b8 00 00 00 00       	mov    $0x0,%eax
  800abd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac0:	0f b6 11             	movzbl (%ecx),%edx
  800ac3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ac6:	89 f3                	mov    %esi,%ebx
  800ac8:	80 fb 09             	cmp    $0x9,%bl
  800acb:	77 08                	ja     800ad5 <strtol+0x8b>
			dig = *s - '0';
  800acd:	0f be d2             	movsbl %dl,%edx
  800ad0:	83 ea 30             	sub    $0x30,%edx
  800ad3:	eb 22                	jmp    800af7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ad5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad8:	89 f3                	mov    %esi,%ebx
  800ada:	80 fb 19             	cmp    $0x19,%bl
  800add:	77 08                	ja     800ae7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800adf:	0f be d2             	movsbl %dl,%edx
  800ae2:	83 ea 57             	sub    $0x57,%edx
  800ae5:	eb 10                	jmp    800af7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ae7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aea:	89 f3                	mov    %esi,%ebx
  800aec:	80 fb 19             	cmp    $0x19,%bl
  800aef:	77 16                	ja     800b07 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800af1:	0f be d2             	movsbl %dl,%edx
  800af4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800af7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800afa:	7d 0b                	jge    800b07 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800afc:	83 c1 01             	add    $0x1,%ecx
  800aff:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b03:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b05:	eb b9                	jmp    800ac0 <strtol+0x76>

	if (endptr)
  800b07:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0b:	74 0d                	je     800b1a <strtol+0xd0>
		*endptr = (char *) s;
  800b0d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b10:	89 0e                	mov    %ecx,(%esi)
  800b12:	eb 06                	jmp    800b1a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b14:	85 db                	test   %ebx,%ebx
  800b16:	74 98                	je     800ab0 <strtol+0x66>
  800b18:	eb 9e                	jmp    800ab8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b1a:	89 c2                	mov    %eax,%edx
  800b1c:	f7 da                	neg    %edx
  800b1e:	85 ff                	test   %edi,%edi
  800b20:	0f 45 c2             	cmovne %edx,%eax
}
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5f                   	pop    %edi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b36:	8b 55 08             	mov    0x8(%ebp),%edx
  800b39:	89 c3                	mov    %eax,%ebx
  800b3b:	89 c7                	mov    %eax,%edi
  800b3d:	89 c6                	mov    %eax,%esi
  800b3f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b51:	b8 01 00 00 00       	mov    $0x1,%eax
  800b56:	89 d1                	mov    %edx,%ecx
  800b58:	89 d3                	mov    %edx,%ebx
  800b5a:	89 d7                	mov    %edx,%edi
  800b5c:	89 d6                	mov    %edx,%esi
  800b5e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b73:	b8 03 00 00 00       	mov    $0x3,%eax
  800b78:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7b:	89 cb                	mov    %ecx,%ebx
  800b7d:	89 cf                	mov    %ecx,%edi
  800b7f:	89 ce                	mov    %ecx,%esi
  800b81:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b83:	85 c0                	test   %eax,%eax
  800b85:	7e 17                	jle    800b9e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b87:	83 ec 0c             	sub    $0xc,%esp
  800b8a:	50                   	push   %eax
  800b8b:	6a 03                	push   $0x3
  800b8d:	68 80 11 80 00       	push   $0x801180
  800b92:	6a 23                	push   $0x23
  800b94:	68 9d 11 80 00       	push   $0x80119d
  800b99:	e8 a3 f5 ff ff       	call   800141 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bac:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb1:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb6:	89 d1                	mov    %edx,%ecx
  800bb8:	89 d3                	mov    %edx,%ebx
  800bba:	89 d7                	mov    %edx,%edi
  800bbc:	89 d6                	mov    %edx,%esi
  800bbe:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    
  800bc5:	66 90                	xchg   %ax,%ax
  800bc7:	66 90                	xchg   %ax,%ax
  800bc9:	66 90                	xchg   %ax,%ax
  800bcb:	66 90                	xchg   %ax,%ax
  800bcd:	66 90                	xchg   %ax,%ax
  800bcf:	90                   	nop

00800bd0 <__udivdi3>:
  800bd0:	55                   	push   %ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 1c             	sub    $0x1c,%esp
  800bd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800bdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800bdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800be3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800be7:	85 f6                	test   %esi,%esi
  800be9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800bed:	89 ca                	mov    %ecx,%edx
  800bef:	89 f8                	mov    %edi,%eax
  800bf1:	75 3d                	jne    800c30 <__udivdi3+0x60>
  800bf3:	39 cf                	cmp    %ecx,%edi
  800bf5:	0f 87 c5 00 00 00    	ja     800cc0 <__udivdi3+0xf0>
  800bfb:	85 ff                	test   %edi,%edi
  800bfd:	89 fd                	mov    %edi,%ebp
  800bff:	75 0b                	jne    800c0c <__udivdi3+0x3c>
  800c01:	b8 01 00 00 00       	mov    $0x1,%eax
  800c06:	31 d2                	xor    %edx,%edx
  800c08:	f7 f7                	div    %edi
  800c0a:	89 c5                	mov    %eax,%ebp
  800c0c:	89 c8                	mov    %ecx,%eax
  800c0e:	31 d2                	xor    %edx,%edx
  800c10:	f7 f5                	div    %ebp
  800c12:	89 c1                	mov    %eax,%ecx
  800c14:	89 d8                	mov    %ebx,%eax
  800c16:	89 cf                	mov    %ecx,%edi
  800c18:	f7 f5                	div    %ebp
  800c1a:	89 c3                	mov    %eax,%ebx
  800c1c:	89 d8                	mov    %ebx,%eax
  800c1e:	89 fa                	mov    %edi,%edx
  800c20:	83 c4 1c             	add    $0x1c,%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    
  800c28:	90                   	nop
  800c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c30:	39 ce                	cmp    %ecx,%esi
  800c32:	77 74                	ja     800ca8 <__udivdi3+0xd8>
  800c34:	0f bd fe             	bsr    %esi,%edi
  800c37:	83 f7 1f             	xor    $0x1f,%edi
  800c3a:	0f 84 98 00 00 00    	je     800cd8 <__udivdi3+0x108>
  800c40:	bb 20 00 00 00       	mov    $0x20,%ebx
  800c45:	89 f9                	mov    %edi,%ecx
  800c47:	89 c5                	mov    %eax,%ebp
  800c49:	29 fb                	sub    %edi,%ebx
  800c4b:	d3 e6                	shl    %cl,%esi
  800c4d:	89 d9                	mov    %ebx,%ecx
  800c4f:	d3 ed                	shr    %cl,%ebp
  800c51:	89 f9                	mov    %edi,%ecx
  800c53:	d3 e0                	shl    %cl,%eax
  800c55:	09 ee                	or     %ebp,%esi
  800c57:	89 d9                	mov    %ebx,%ecx
  800c59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c5d:	89 d5                	mov    %edx,%ebp
  800c5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800c63:	d3 ed                	shr    %cl,%ebp
  800c65:	89 f9                	mov    %edi,%ecx
  800c67:	d3 e2                	shl    %cl,%edx
  800c69:	89 d9                	mov    %ebx,%ecx
  800c6b:	d3 e8                	shr    %cl,%eax
  800c6d:	09 c2                	or     %eax,%edx
  800c6f:	89 d0                	mov    %edx,%eax
  800c71:	89 ea                	mov    %ebp,%edx
  800c73:	f7 f6                	div    %esi
  800c75:	89 d5                	mov    %edx,%ebp
  800c77:	89 c3                	mov    %eax,%ebx
  800c79:	f7 64 24 0c          	mull   0xc(%esp)
  800c7d:	39 d5                	cmp    %edx,%ebp
  800c7f:	72 10                	jb     800c91 <__udivdi3+0xc1>
  800c81:	8b 74 24 08          	mov    0x8(%esp),%esi
  800c85:	89 f9                	mov    %edi,%ecx
  800c87:	d3 e6                	shl    %cl,%esi
  800c89:	39 c6                	cmp    %eax,%esi
  800c8b:	73 07                	jae    800c94 <__udivdi3+0xc4>
  800c8d:	39 d5                	cmp    %edx,%ebp
  800c8f:	75 03                	jne    800c94 <__udivdi3+0xc4>
  800c91:	83 eb 01             	sub    $0x1,%ebx
  800c94:	31 ff                	xor    %edi,%edi
  800c96:	89 d8                	mov    %ebx,%eax
  800c98:	89 fa                	mov    %edi,%edx
  800c9a:	83 c4 1c             	add    $0x1c,%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    
  800ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ca8:	31 ff                	xor    %edi,%edi
  800caa:	31 db                	xor    %ebx,%ebx
  800cac:	89 d8                	mov    %ebx,%eax
  800cae:	89 fa                	mov    %edi,%edx
  800cb0:	83 c4 1c             	add    $0x1c,%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    
  800cb8:	90                   	nop
  800cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cc0:	89 d8                	mov    %ebx,%eax
  800cc2:	f7 f7                	div    %edi
  800cc4:	31 ff                	xor    %edi,%edi
  800cc6:	89 c3                	mov    %eax,%ebx
  800cc8:	89 d8                	mov    %ebx,%eax
  800cca:	89 fa                	mov    %edi,%edx
  800ccc:	83 c4 1c             	add    $0x1c,%esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    
  800cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cd8:	39 ce                	cmp    %ecx,%esi
  800cda:	72 0c                	jb     800ce8 <__udivdi3+0x118>
  800cdc:	31 db                	xor    %ebx,%ebx
  800cde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ce2:	0f 87 34 ff ff ff    	ja     800c1c <__udivdi3+0x4c>
  800ce8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ced:	e9 2a ff ff ff       	jmp    800c1c <__udivdi3+0x4c>
  800cf2:	66 90                	xchg   %ax,%ax
  800cf4:	66 90                	xchg   %ax,%ax
  800cf6:	66 90                	xchg   %ax,%ax
  800cf8:	66 90                	xchg   %ax,%ax
  800cfa:	66 90                	xchg   %ax,%ax
  800cfc:	66 90                	xchg   %ax,%ax
  800cfe:	66 90                	xchg   %ax,%ax

00800d00 <__umoddi3>:
  800d00:	55                   	push   %ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 1c             	sub    $0x1c,%esp
  800d07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800d0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d17:	85 d2                	test   %edx,%edx
  800d19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d21:	89 f3                	mov    %esi,%ebx
  800d23:	89 3c 24             	mov    %edi,(%esp)
  800d26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d2a:	75 1c                	jne    800d48 <__umoddi3+0x48>
  800d2c:	39 f7                	cmp    %esi,%edi
  800d2e:	76 50                	jbe    800d80 <__umoddi3+0x80>
  800d30:	89 c8                	mov    %ecx,%eax
  800d32:	89 f2                	mov    %esi,%edx
  800d34:	f7 f7                	div    %edi
  800d36:	89 d0                	mov    %edx,%eax
  800d38:	31 d2                	xor    %edx,%edx
  800d3a:	83 c4 1c             	add    $0x1c,%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    
  800d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d48:	39 f2                	cmp    %esi,%edx
  800d4a:	89 d0                	mov    %edx,%eax
  800d4c:	77 52                	ja     800da0 <__umoddi3+0xa0>
  800d4e:	0f bd ea             	bsr    %edx,%ebp
  800d51:	83 f5 1f             	xor    $0x1f,%ebp
  800d54:	75 5a                	jne    800db0 <__umoddi3+0xb0>
  800d56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800d5a:	0f 82 e0 00 00 00    	jb     800e40 <__umoddi3+0x140>
  800d60:	39 0c 24             	cmp    %ecx,(%esp)
  800d63:	0f 86 d7 00 00 00    	jbe    800e40 <__umoddi3+0x140>
  800d69:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d71:	83 c4 1c             	add    $0x1c,%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	85 ff                	test   %edi,%edi
  800d82:	89 fd                	mov    %edi,%ebp
  800d84:	75 0b                	jne    800d91 <__umoddi3+0x91>
  800d86:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8b:	31 d2                	xor    %edx,%edx
  800d8d:	f7 f7                	div    %edi
  800d8f:	89 c5                	mov    %eax,%ebp
  800d91:	89 f0                	mov    %esi,%eax
  800d93:	31 d2                	xor    %edx,%edx
  800d95:	f7 f5                	div    %ebp
  800d97:	89 c8                	mov    %ecx,%eax
  800d99:	f7 f5                	div    %ebp
  800d9b:	89 d0                	mov    %edx,%eax
  800d9d:	eb 99                	jmp    800d38 <__umoddi3+0x38>
  800d9f:	90                   	nop
  800da0:	89 c8                	mov    %ecx,%eax
  800da2:	89 f2                	mov    %esi,%edx
  800da4:	83 c4 1c             	add    $0x1c,%esp
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    
  800dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800db0:	8b 34 24             	mov    (%esp),%esi
  800db3:	bf 20 00 00 00       	mov    $0x20,%edi
  800db8:	89 e9                	mov    %ebp,%ecx
  800dba:	29 ef                	sub    %ebp,%edi
  800dbc:	d3 e0                	shl    %cl,%eax
  800dbe:	89 f9                	mov    %edi,%ecx
  800dc0:	89 f2                	mov    %esi,%edx
  800dc2:	d3 ea                	shr    %cl,%edx
  800dc4:	89 e9                	mov    %ebp,%ecx
  800dc6:	09 c2                	or     %eax,%edx
  800dc8:	89 d8                	mov    %ebx,%eax
  800dca:	89 14 24             	mov    %edx,(%esp)
  800dcd:	89 f2                	mov    %esi,%edx
  800dcf:	d3 e2                	shl    %cl,%edx
  800dd1:	89 f9                	mov    %edi,%ecx
  800dd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800ddb:	d3 e8                	shr    %cl,%eax
  800ddd:	89 e9                	mov    %ebp,%ecx
  800ddf:	89 c6                	mov    %eax,%esi
  800de1:	d3 e3                	shl    %cl,%ebx
  800de3:	89 f9                	mov    %edi,%ecx
  800de5:	89 d0                	mov    %edx,%eax
  800de7:	d3 e8                	shr    %cl,%eax
  800de9:	89 e9                	mov    %ebp,%ecx
  800deb:	09 d8                	or     %ebx,%eax
  800ded:	89 d3                	mov    %edx,%ebx
  800def:	89 f2                	mov    %esi,%edx
  800df1:	f7 34 24             	divl   (%esp)
  800df4:	89 d6                	mov    %edx,%esi
  800df6:	d3 e3                	shl    %cl,%ebx
  800df8:	f7 64 24 04          	mull   0x4(%esp)
  800dfc:	39 d6                	cmp    %edx,%esi
  800dfe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e02:	89 d1                	mov    %edx,%ecx
  800e04:	89 c3                	mov    %eax,%ebx
  800e06:	72 08                	jb     800e10 <__umoddi3+0x110>
  800e08:	75 11                	jne    800e1b <__umoddi3+0x11b>
  800e0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800e0e:	73 0b                	jae    800e1b <__umoddi3+0x11b>
  800e10:	2b 44 24 04          	sub    0x4(%esp),%eax
  800e14:	1b 14 24             	sbb    (%esp),%edx
  800e17:	89 d1                	mov    %edx,%ecx
  800e19:	89 c3                	mov    %eax,%ebx
  800e1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800e1f:	29 da                	sub    %ebx,%edx
  800e21:	19 ce                	sbb    %ecx,%esi
  800e23:	89 f9                	mov    %edi,%ecx
  800e25:	89 f0                	mov    %esi,%eax
  800e27:	d3 e0                	shl    %cl,%eax
  800e29:	89 e9                	mov    %ebp,%ecx
  800e2b:	d3 ea                	shr    %cl,%edx
  800e2d:	89 e9                	mov    %ebp,%ecx
  800e2f:	d3 ee                	shr    %cl,%esi
  800e31:	09 d0                	or     %edx,%eax
  800e33:	89 f2                	mov    %esi,%edx
  800e35:	83 c4 1c             	add    $0x1c,%esp
  800e38:	5b                   	pop    %ebx
  800e39:	5e                   	pop    %esi
  800e3a:	5f                   	pop    %edi
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    
  800e3d:	8d 76 00             	lea    0x0(%esi),%esi
  800e40:	29 f9                	sub    %edi,%ecx
  800e42:	19 d6                	sbb    %edx,%esi
  800e44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e4c:	e9 18 ff ff ff       	jmp    800d69 <__umoddi3+0x69>
