
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 e0 0d 80 00       	push   $0x800de0
  80003e:	e8 13 01 00 00       	call   800156 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 ee 0d 80 00       	push   $0x800dee
  800054:	e8 fd 00 00 00       	call   800156 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800069:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800070:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  800073:	e8 6a 0a 00 00       	call   800ae2 <sys_getenvid>
  800078:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007d:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800080:	c1 e0 05             	shl    $0x5,%eax
  800083:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800088:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008d:	85 db                	test   %ebx,%ebx
  80008f:	7e 07                	jle    800098 <libmain+0x3a>
		binaryname = argv[0];
  800091:	8b 06                	mov    (%esi),%eax
  800093:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800098:	83 ec 08             	sub    $0x8,%esp
  80009b:	56                   	push   %esi
  80009c:	53                   	push   %ebx
  80009d:	e8 91 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a2:	e8 0a 00 00 00       	call   8000b1 <exit>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ad:	5b                   	pop    %ebx
  8000ae:	5e                   	pop    %esi
  8000af:	5d                   	pop    %ebp
  8000b0:	c3                   	ret    

008000b1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b1:	55                   	push   %ebp
  8000b2:	89 e5                	mov    %esp,%ebp
  8000b4:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b7:	6a 00                	push   $0x0
  8000b9:	e8 e3 09 00 00       	call   800aa1 <sys_env_destroy>
}
  8000be:	83 c4 10             	add    $0x10,%esp
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	53                   	push   %ebx
  8000c7:	83 ec 04             	sub    $0x4,%esp
  8000ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000cd:	8b 13                	mov    (%ebx),%edx
  8000cf:	8d 42 01             	lea    0x1(%edx),%eax
  8000d2:	89 03                	mov    %eax,(%ebx)
  8000d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000db:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e0:	75 1a                	jne    8000fc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	68 ff 00 00 00       	push   $0xff
  8000ea:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ed:	50                   	push   %eax
  8000ee:	e8 71 09 00 00       	call   800a64 <sys_cputs>
		b->idx = 0;
  8000f3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000fc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800100:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800103:	c9                   	leave  
  800104:	c3                   	ret    

00800105 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800115:	00 00 00 
	b.cnt = 0;
  800118:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800122:	ff 75 0c             	pushl  0xc(%ebp)
  800125:	ff 75 08             	pushl  0x8(%ebp)
  800128:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012e:	50                   	push   %eax
  80012f:	68 c3 00 80 00       	push   $0x8000c3
  800134:	e8 54 01 00 00       	call   80028d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800139:	83 c4 08             	add    $0x8,%esp
  80013c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800142:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800148:	50                   	push   %eax
  800149:	e8 16 09 00 00       	call   800a64 <sys_cputs>

	return b.cnt;
}
  80014e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800154:	c9                   	leave  
  800155:	c3                   	ret    

00800156 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015f:	50                   	push   %eax
  800160:	ff 75 08             	pushl  0x8(%ebp)
  800163:	e8 9d ff ff ff       	call   800105 <vcprintf>
	va_end(ap);

	return cnt;
}
  800168:	c9                   	leave  
  800169:	c3                   	ret    

0080016a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 1c             	sub    $0x1c,%esp
  800173:	89 c7                	mov    %eax,%edi
  800175:	89 d6                	mov    %edx,%esi
  800177:	8b 45 08             	mov    0x8(%ebp),%eax
  80017a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800180:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800183:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800186:	bb 00 00 00 00       	mov    $0x0,%ebx
  80018b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80018e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800191:	39 d3                	cmp    %edx,%ebx
  800193:	72 05                	jb     80019a <printnum+0x30>
  800195:	39 45 10             	cmp    %eax,0x10(%ebp)
  800198:	77 45                	ja     8001df <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019a:	83 ec 0c             	sub    $0xc,%esp
  80019d:	ff 75 18             	pushl  0x18(%ebp)
  8001a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a6:	53                   	push   %ebx
  8001a7:	ff 75 10             	pushl  0x10(%ebp)
  8001aa:	83 ec 08             	sub    $0x8,%esp
  8001ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b3:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b9:	e8 92 09 00 00       	call   800b50 <__udivdi3>
  8001be:	83 c4 18             	add    $0x18,%esp
  8001c1:	52                   	push   %edx
  8001c2:	50                   	push   %eax
  8001c3:	89 f2                	mov    %esi,%edx
  8001c5:	89 f8                	mov    %edi,%eax
  8001c7:	e8 9e ff ff ff       	call   80016a <printnum>
  8001cc:	83 c4 20             	add    $0x20,%esp
  8001cf:	eb 18                	jmp    8001e9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d1:	83 ec 08             	sub    $0x8,%esp
  8001d4:	56                   	push   %esi
  8001d5:	ff 75 18             	pushl  0x18(%ebp)
  8001d8:	ff d7                	call   *%edi
  8001da:	83 c4 10             	add    $0x10,%esp
  8001dd:	eb 03                	jmp    8001e2 <printnum+0x78>
  8001df:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e2:	83 eb 01             	sub    $0x1,%ebx
  8001e5:	85 db                	test   %ebx,%ebx
  8001e7:	7f e8                	jg     8001d1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e9:	83 ec 08             	sub    $0x8,%esp
  8001ec:	56                   	push   %esi
  8001ed:	83 ec 04             	sub    $0x4,%esp
  8001f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001fc:	e8 7f 0a 00 00       	call   800c80 <__umoddi3>
  800201:	83 c4 14             	add    $0x14,%esp
  800204:	0f be 80 0f 0e 80 00 	movsbl 0x800e0f(%eax),%eax
  80020b:	50                   	push   %eax
  80020c:	ff d7                	call   *%edi
}
  80020e:	83 c4 10             	add    $0x10,%esp
  800211:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5f                   	pop    %edi
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    

00800219 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80021c:	83 fa 01             	cmp    $0x1,%edx
  80021f:	7e 0e                	jle    80022f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800221:	8b 10                	mov    (%eax),%edx
  800223:	8d 4a 08             	lea    0x8(%edx),%ecx
  800226:	89 08                	mov    %ecx,(%eax)
  800228:	8b 02                	mov    (%edx),%eax
  80022a:	8b 52 04             	mov    0x4(%edx),%edx
  80022d:	eb 22                	jmp    800251 <getuint+0x38>
	else if (lflag)
  80022f:	85 d2                	test   %edx,%edx
  800231:	74 10                	je     800243 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800233:	8b 10                	mov    (%eax),%edx
  800235:	8d 4a 04             	lea    0x4(%edx),%ecx
  800238:	89 08                	mov    %ecx,(%eax)
  80023a:	8b 02                	mov    (%edx),%eax
  80023c:	ba 00 00 00 00       	mov    $0x0,%edx
  800241:	eb 0e                	jmp    800251 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800243:	8b 10                	mov    (%eax),%edx
  800245:	8d 4a 04             	lea    0x4(%edx),%ecx
  800248:	89 08                	mov    %ecx,(%eax)
  80024a:	8b 02                	mov    (%edx),%eax
  80024c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800251:	5d                   	pop    %ebp
  800252:	c3                   	ret    

00800253 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800259:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025d:	8b 10                	mov    (%eax),%edx
  80025f:	3b 50 04             	cmp    0x4(%eax),%edx
  800262:	73 0a                	jae    80026e <sprintputch+0x1b>
		*b->buf++ = ch;
  800264:	8d 4a 01             	lea    0x1(%edx),%ecx
  800267:	89 08                	mov    %ecx,(%eax)
  800269:	8b 45 08             	mov    0x8(%ebp),%eax
  80026c:	88 02                	mov    %al,(%edx)
}
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800276:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800279:	50                   	push   %eax
  80027a:	ff 75 10             	pushl  0x10(%ebp)
  80027d:	ff 75 0c             	pushl  0xc(%ebp)
  800280:	ff 75 08             	pushl  0x8(%ebp)
  800283:	e8 05 00 00 00       	call   80028d <vprintfmt>
	va_end(ap);
}
  800288:	83 c4 10             	add    $0x10,%esp
  80028b:	c9                   	leave  
  80028c:	c3                   	ret    

0080028d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	57                   	push   %edi
  800291:	56                   	push   %esi
  800292:	53                   	push   %ebx
  800293:	83 ec 2c             	sub    $0x2c,%esp
  800296:	8b 75 08             	mov    0x8(%ebp),%esi
  800299:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80029c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029f:	eb 12                	jmp    8002b3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002a1:	85 c0                	test   %eax,%eax
  8002a3:	0f 84 cb 03 00 00    	je     800674 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	53                   	push   %ebx
  8002ad:	50                   	push   %eax
  8002ae:	ff d6                	call   *%esi
  8002b0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b3:	83 c7 01             	add    $0x1,%edi
  8002b6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002ba:	83 f8 25             	cmp    $0x25,%eax
  8002bd:	75 e2                	jne    8002a1 <vprintfmt+0x14>
  8002bf:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ca:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002d1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dd:	eb 07                	jmp    8002e6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002df:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002e2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e6:	8d 47 01             	lea    0x1(%edi),%eax
  8002e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ec:	0f b6 07             	movzbl (%edi),%eax
  8002ef:	0f b6 c8             	movzbl %al,%ecx
  8002f2:	83 e8 23             	sub    $0x23,%eax
  8002f5:	3c 55                	cmp    $0x55,%al
  8002f7:	0f 87 5c 03 00 00    	ja     800659 <vprintfmt+0x3cc>
  8002fd:	0f b6 c0             	movzbl %al,%eax
  800300:	ff 24 85 c0 0e 80 00 	jmp    *0x800ec0(,%eax,4)
  800307:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80030a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030e:	eb d6                	jmp    8002e6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800310:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800313:	b8 00 00 00 00       	mov    $0x0,%eax
  800318:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80031b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800322:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800325:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800328:	83 fa 09             	cmp    $0x9,%edx
  80032b:	77 39                	ja     800366 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80032d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800330:	eb e9                	jmp    80031b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800332:	8b 45 14             	mov    0x14(%ebp),%eax
  800335:	8d 48 04             	lea    0x4(%eax),%ecx
  800338:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80033b:	8b 00                	mov    (%eax),%eax
  80033d:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800343:	eb 27                	jmp    80036c <vprintfmt+0xdf>
  800345:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800348:	85 c0                	test   %eax,%eax
  80034a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034f:	0f 49 c8             	cmovns %eax,%ecx
  800352:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800358:	eb 8c                	jmp    8002e6 <vprintfmt+0x59>
  80035a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80035d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800364:	eb 80                	jmp    8002e6 <vprintfmt+0x59>
  800366:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800369:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80036c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800370:	0f 89 70 ff ff ff    	jns    8002e6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800376:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800379:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037c:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800383:	e9 5e ff ff ff       	jmp    8002e6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800388:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80038e:	e9 53 ff ff ff       	jmp    8002e6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800393:	8b 45 14             	mov    0x14(%ebp),%eax
  800396:	8d 50 04             	lea    0x4(%eax),%edx
  800399:	89 55 14             	mov    %edx,0x14(%ebp)
  80039c:	83 ec 08             	sub    $0x8,%esp
  80039f:	53                   	push   %ebx
  8003a0:	ff 30                	pushl  (%eax)
  8003a2:	ff d6                	call   *%esi
			break;
  8003a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003aa:	e9 04 ff ff ff       	jmp    8002b3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003af:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b2:	8d 50 04             	lea    0x4(%eax),%edx
  8003b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b8:	8b 00                	mov    (%eax),%eax
  8003ba:	99                   	cltd   
  8003bb:	31 d0                	xor    %edx,%eax
  8003bd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003bf:	83 f8 07             	cmp    $0x7,%eax
  8003c2:	7f 0b                	jg     8003cf <vprintfmt+0x142>
  8003c4:	8b 14 85 20 10 80 00 	mov    0x801020(,%eax,4),%edx
  8003cb:	85 d2                	test   %edx,%edx
  8003cd:	75 18                	jne    8003e7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003cf:	50                   	push   %eax
  8003d0:	68 27 0e 80 00       	push   $0x800e27
  8003d5:	53                   	push   %ebx
  8003d6:	56                   	push   %esi
  8003d7:	e8 94 fe ff ff       	call   800270 <printfmt>
  8003dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003e2:	e9 cc fe ff ff       	jmp    8002b3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003e7:	52                   	push   %edx
  8003e8:	68 30 0e 80 00       	push   $0x800e30
  8003ed:	53                   	push   %ebx
  8003ee:	56                   	push   %esi
  8003ef:	e8 7c fe ff ff       	call   800270 <printfmt>
  8003f4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fa:	e9 b4 fe ff ff       	jmp    8002b3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800402:	8d 50 04             	lea    0x4(%eax),%edx
  800405:	89 55 14             	mov    %edx,0x14(%ebp)
  800408:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80040a:	85 ff                	test   %edi,%edi
  80040c:	b8 20 0e 80 00       	mov    $0x800e20,%eax
  800411:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800414:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800418:	0f 8e 94 00 00 00    	jle    8004b2 <vprintfmt+0x225>
  80041e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800422:	0f 84 98 00 00 00    	je     8004c0 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	ff 75 c8             	pushl  -0x38(%ebp)
  80042e:	57                   	push   %edi
  80042f:	e8 c8 02 00 00       	call   8006fc <strnlen>
  800434:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800437:	29 c1                	sub    %eax,%ecx
  800439:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80043c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80043f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800443:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800446:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800449:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80044b:	eb 0f                	jmp    80045c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	53                   	push   %ebx
  800451:	ff 75 e0             	pushl  -0x20(%ebp)
  800454:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800456:	83 ef 01             	sub    $0x1,%edi
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 ff                	test   %edi,%edi
  80045e:	7f ed                	jg     80044d <vprintfmt+0x1c0>
  800460:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800463:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800466:	85 c9                	test   %ecx,%ecx
  800468:	b8 00 00 00 00       	mov    $0x0,%eax
  80046d:	0f 49 c1             	cmovns %ecx,%eax
  800470:	29 c1                	sub    %eax,%ecx
  800472:	89 75 08             	mov    %esi,0x8(%ebp)
  800475:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800478:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80047b:	89 cb                	mov    %ecx,%ebx
  80047d:	eb 4d                	jmp    8004cc <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80047f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800483:	74 1b                	je     8004a0 <vprintfmt+0x213>
  800485:	0f be c0             	movsbl %al,%eax
  800488:	83 e8 20             	sub    $0x20,%eax
  80048b:	83 f8 5e             	cmp    $0x5e,%eax
  80048e:	76 10                	jbe    8004a0 <vprintfmt+0x213>
					putch('?', putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	ff 75 0c             	pushl  0xc(%ebp)
  800496:	6a 3f                	push   $0x3f
  800498:	ff 55 08             	call   *0x8(%ebp)
  80049b:	83 c4 10             	add    $0x10,%esp
  80049e:	eb 0d                	jmp    8004ad <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004a0:	83 ec 08             	sub    $0x8,%esp
  8004a3:	ff 75 0c             	pushl  0xc(%ebp)
  8004a6:	52                   	push   %edx
  8004a7:	ff 55 08             	call   *0x8(%ebp)
  8004aa:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ad:	83 eb 01             	sub    $0x1,%ebx
  8004b0:	eb 1a                	jmp    8004cc <vprintfmt+0x23f>
  8004b2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b5:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004b8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004bb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004be:	eb 0c                	jmp    8004cc <vprintfmt+0x23f>
  8004c0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c3:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004c6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004cc:	83 c7 01             	add    $0x1,%edi
  8004cf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d3:	0f be d0             	movsbl %al,%edx
  8004d6:	85 d2                	test   %edx,%edx
  8004d8:	74 23                	je     8004fd <vprintfmt+0x270>
  8004da:	85 f6                	test   %esi,%esi
  8004dc:	78 a1                	js     80047f <vprintfmt+0x1f2>
  8004de:	83 ee 01             	sub    $0x1,%esi
  8004e1:	79 9c                	jns    80047f <vprintfmt+0x1f2>
  8004e3:	89 df                	mov    %ebx,%edi
  8004e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004eb:	eb 18                	jmp    800505 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	53                   	push   %ebx
  8004f1:	6a 20                	push   $0x20
  8004f3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f5:	83 ef 01             	sub    $0x1,%edi
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	eb 08                	jmp    800505 <vprintfmt+0x278>
  8004fd:	89 df                	mov    %ebx,%edi
  8004ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800502:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800505:	85 ff                	test   %edi,%edi
  800507:	7f e4                	jg     8004ed <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800509:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050c:	e9 a2 fd ff ff       	jmp    8002b3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800511:	83 fa 01             	cmp    $0x1,%edx
  800514:	7e 16                	jle    80052c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 50 08             	lea    0x8(%eax),%edx
  80051c:	89 55 14             	mov    %edx,0x14(%ebp)
  80051f:	8b 50 04             	mov    0x4(%eax),%edx
  800522:	8b 00                	mov    (%eax),%eax
  800524:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800527:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80052a:	eb 32                	jmp    80055e <vprintfmt+0x2d1>
	else if (lflag)
  80052c:	85 d2                	test   %edx,%edx
  80052e:	74 18                	je     800548 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8d 50 04             	lea    0x4(%eax),%edx
  800536:	89 55 14             	mov    %edx,0x14(%ebp)
  800539:	8b 00                	mov    (%eax),%eax
  80053b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80053e:	89 c1                	mov    %eax,%ecx
  800540:	c1 f9 1f             	sar    $0x1f,%ecx
  800543:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800546:	eb 16                	jmp    80055e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8d 50 04             	lea    0x4(%eax),%edx
  80054e:	89 55 14             	mov    %edx,0x14(%ebp)
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800556:	89 c1                	mov    %eax,%ecx
  800558:	c1 f9 1f             	sar    $0x1f,%ecx
  80055b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80055e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800561:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800564:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800567:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80056a:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80056f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800573:	0f 89 a8 00 00 00    	jns    800621 <vprintfmt+0x394>
				putch('-', putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	53                   	push   %ebx
  80057d:	6a 2d                	push   $0x2d
  80057f:	ff d6                	call   *%esi
				num = -(long long) num;
  800581:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800584:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800587:	f7 d8                	neg    %eax
  800589:	83 d2 00             	adc    $0x0,%edx
  80058c:	f7 da                	neg    %edx
  80058e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800591:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800594:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800597:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059c:	e9 80 00 00 00       	jmp    800621 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a4:	e8 70 fc ff ff       	call   800219 <getuint>
  8005a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ac:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005af:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005b4:	eb 6b                	jmp    800621 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b9:	e8 5b fc ff ff       	call   800219 <getuint>
  8005be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  8005c4:	6a 04                	push   $0x4
  8005c6:	6a 03                	push   $0x3
  8005c8:	6a 01                	push   $0x1
  8005ca:	68 33 0e 80 00       	push   $0x800e33
  8005cf:	e8 82 fb ff ff       	call   800156 <cprintf>
			goto number;
  8005d4:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  8005d7:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  8005dc:	eb 43                	jmp    800621 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  8005de:	83 ec 08             	sub    $0x8,%esp
  8005e1:	53                   	push   %ebx
  8005e2:	6a 30                	push   $0x30
  8005e4:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e6:	83 c4 08             	add    $0x8,%esp
  8005e9:	53                   	push   %ebx
  8005ea:	6a 78                	push   $0x78
  8005ec:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 50 04             	lea    0x4(%eax),%edx
  8005f4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005f7:	8b 00                	mov    (%eax),%eax
  8005f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800601:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800604:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800607:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80060c:	eb 13                	jmp    800621 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060e:	8d 45 14             	lea    0x14(%ebp),%eax
  800611:	e8 03 fc ff ff       	call   800219 <getuint>
  800616:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800619:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80061c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800621:	83 ec 0c             	sub    $0xc,%esp
  800624:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800628:	52                   	push   %edx
  800629:	ff 75 e0             	pushl  -0x20(%ebp)
  80062c:	50                   	push   %eax
  80062d:	ff 75 dc             	pushl  -0x24(%ebp)
  800630:	ff 75 d8             	pushl  -0x28(%ebp)
  800633:	89 da                	mov    %ebx,%edx
  800635:	89 f0                	mov    %esi,%eax
  800637:	e8 2e fb ff ff       	call   80016a <printnum>

			break;
  80063c:	83 c4 20             	add    $0x20,%esp
  80063f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800642:	e9 6c fc ff ff       	jmp    8002b3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800647:	83 ec 08             	sub    $0x8,%esp
  80064a:	53                   	push   %ebx
  80064b:	51                   	push   %ecx
  80064c:	ff d6                	call   *%esi
			break;
  80064e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800651:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800654:	e9 5a fc ff ff       	jmp    8002b3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	53                   	push   %ebx
  80065d:	6a 25                	push   $0x25
  80065f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	eb 03                	jmp    800669 <vprintfmt+0x3dc>
  800666:	83 ef 01             	sub    $0x1,%edi
  800669:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80066d:	75 f7                	jne    800666 <vprintfmt+0x3d9>
  80066f:	e9 3f fc ff ff       	jmp    8002b3 <vprintfmt+0x26>
			break;
		}

	}

}
  800674:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800677:	5b                   	pop    %ebx
  800678:	5e                   	pop    %esi
  800679:	5f                   	pop    %edi
  80067a:	5d                   	pop    %ebp
  80067b:	c3                   	ret    

0080067c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80067c:	55                   	push   %ebp
  80067d:	89 e5                	mov    %esp,%ebp
  80067f:	83 ec 18             	sub    $0x18,%esp
  800682:	8b 45 08             	mov    0x8(%ebp),%eax
  800685:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800688:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80068b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800692:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800699:	85 c0                	test   %eax,%eax
  80069b:	74 26                	je     8006c3 <vsnprintf+0x47>
  80069d:	85 d2                	test   %edx,%edx
  80069f:	7e 22                	jle    8006c3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a1:	ff 75 14             	pushl  0x14(%ebp)
  8006a4:	ff 75 10             	pushl  0x10(%ebp)
  8006a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006aa:	50                   	push   %eax
  8006ab:	68 53 02 80 00       	push   $0x800253
  8006b0:	e8 d8 fb ff ff       	call   80028d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	eb 05                	jmp    8006c8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c8:	c9                   	leave  
  8006c9:	c3                   	ret    

008006ca <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d3:	50                   	push   %eax
  8006d4:	ff 75 10             	pushl  0x10(%ebp)
  8006d7:	ff 75 0c             	pushl  0xc(%ebp)
  8006da:	ff 75 08             	pushl  0x8(%ebp)
  8006dd:	e8 9a ff ff ff       	call   80067c <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ef:	eb 03                	jmp    8006f4 <strlen+0x10>
		n++;
  8006f1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f8:	75 f7                	jne    8006f1 <strlen+0xd>
		n++;
	return n;
}
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800702:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800705:	ba 00 00 00 00       	mov    $0x0,%edx
  80070a:	eb 03                	jmp    80070f <strnlen+0x13>
		n++;
  80070c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070f:	39 c2                	cmp    %eax,%edx
  800711:	74 08                	je     80071b <strnlen+0x1f>
  800713:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800717:	75 f3                	jne    80070c <strnlen+0x10>
  800719:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80071b:	5d                   	pop    %ebp
  80071c:	c3                   	ret    

0080071d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	53                   	push   %ebx
  800721:	8b 45 08             	mov    0x8(%ebp),%eax
  800724:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800727:	89 c2                	mov    %eax,%edx
  800729:	83 c2 01             	add    $0x1,%edx
  80072c:	83 c1 01             	add    $0x1,%ecx
  80072f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800733:	88 5a ff             	mov    %bl,-0x1(%edx)
  800736:	84 db                	test   %bl,%bl
  800738:	75 ef                	jne    800729 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80073a:	5b                   	pop    %ebx
  80073b:	5d                   	pop    %ebp
  80073c:	c3                   	ret    

0080073d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	53                   	push   %ebx
  800741:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800744:	53                   	push   %ebx
  800745:	e8 9a ff ff ff       	call   8006e4 <strlen>
  80074a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80074d:	ff 75 0c             	pushl  0xc(%ebp)
  800750:	01 d8                	add    %ebx,%eax
  800752:	50                   	push   %eax
  800753:	e8 c5 ff ff ff       	call   80071d <strcpy>
	return dst;
}
  800758:	89 d8                	mov    %ebx,%eax
  80075a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075d:	c9                   	leave  
  80075e:	c3                   	ret    

0080075f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	56                   	push   %esi
  800763:	53                   	push   %ebx
  800764:	8b 75 08             	mov    0x8(%ebp),%esi
  800767:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80076a:	89 f3                	mov    %esi,%ebx
  80076c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076f:	89 f2                	mov    %esi,%edx
  800771:	eb 0f                	jmp    800782 <strncpy+0x23>
		*dst++ = *src;
  800773:	83 c2 01             	add    $0x1,%edx
  800776:	0f b6 01             	movzbl (%ecx),%eax
  800779:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80077c:	80 39 01             	cmpb   $0x1,(%ecx)
  80077f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800782:	39 da                	cmp    %ebx,%edx
  800784:	75 ed                	jne    800773 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800786:	89 f0                	mov    %esi,%eax
  800788:	5b                   	pop    %ebx
  800789:	5e                   	pop    %esi
  80078a:	5d                   	pop    %ebp
  80078b:	c3                   	ret    

0080078c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	56                   	push   %esi
  800790:	53                   	push   %ebx
  800791:	8b 75 08             	mov    0x8(%ebp),%esi
  800794:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800797:	8b 55 10             	mov    0x10(%ebp),%edx
  80079a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079c:	85 d2                	test   %edx,%edx
  80079e:	74 21                	je     8007c1 <strlcpy+0x35>
  8007a0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a4:	89 f2                	mov    %esi,%edx
  8007a6:	eb 09                	jmp    8007b1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a8:	83 c2 01             	add    $0x1,%edx
  8007ab:	83 c1 01             	add    $0x1,%ecx
  8007ae:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007b1:	39 c2                	cmp    %eax,%edx
  8007b3:	74 09                	je     8007be <strlcpy+0x32>
  8007b5:	0f b6 19             	movzbl (%ecx),%ebx
  8007b8:	84 db                	test   %bl,%bl
  8007ba:	75 ec                	jne    8007a8 <strlcpy+0x1c>
  8007bc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007be:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007c1:	29 f0                	sub    %esi,%eax
}
  8007c3:	5b                   	pop    %ebx
  8007c4:	5e                   	pop    %esi
  8007c5:	5d                   	pop    %ebp
  8007c6:	c3                   	ret    

008007c7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d0:	eb 06                	jmp    8007d8 <strcmp+0x11>
		p++, q++;
  8007d2:	83 c1 01             	add    $0x1,%ecx
  8007d5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d8:	0f b6 01             	movzbl (%ecx),%eax
  8007db:	84 c0                	test   %al,%al
  8007dd:	74 04                	je     8007e3 <strcmp+0x1c>
  8007df:	3a 02                	cmp    (%edx),%al
  8007e1:	74 ef                	je     8007d2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e3:	0f b6 c0             	movzbl %al,%eax
  8007e6:	0f b6 12             	movzbl (%edx),%edx
  8007e9:	29 d0                	sub    %edx,%eax
}
  8007eb:	5d                   	pop    %ebp
  8007ec:	c3                   	ret    

008007ed <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	53                   	push   %ebx
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f7:	89 c3                	mov    %eax,%ebx
  8007f9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007fc:	eb 06                	jmp    800804 <strncmp+0x17>
		n--, p++, q++;
  8007fe:	83 c0 01             	add    $0x1,%eax
  800801:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800804:	39 d8                	cmp    %ebx,%eax
  800806:	74 15                	je     80081d <strncmp+0x30>
  800808:	0f b6 08             	movzbl (%eax),%ecx
  80080b:	84 c9                	test   %cl,%cl
  80080d:	74 04                	je     800813 <strncmp+0x26>
  80080f:	3a 0a                	cmp    (%edx),%cl
  800811:	74 eb                	je     8007fe <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800813:	0f b6 00             	movzbl (%eax),%eax
  800816:	0f b6 12             	movzbl (%edx),%edx
  800819:	29 d0                	sub    %edx,%eax
  80081b:	eb 05                	jmp    800822 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80081d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800822:	5b                   	pop    %ebx
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082f:	eb 07                	jmp    800838 <strchr+0x13>
		if (*s == c)
  800831:	38 ca                	cmp    %cl,%dl
  800833:	74 0f                	je     800844 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800835:	83 c0 01             	add    $0x1,%eax
  800838:	0f b6 10             	movzbl (%eax),%edx
  80083b:	84 d2                	test   %dl,%dl
  80083d:	75 f2                	jne    800831 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80083f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800844:	5d                   	pop    %ebp
  800845:	c3                   	ret    

00800846 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	8b 45 08             	mov    0x8(%ebp),%eax
  80084c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800850:	eb 03                	jmp    800855 <strfind+0xf>
  800852:	83 c0 01             	add    $0x1,%eax
  800855:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800858:	38 ca                	cmp    %cl,%dl
  80085a:	74 04                	je     800860 <strfind+0x1a>
  80085c:	84 d2                	test   %dl,%dl
  80085e:	75 f2                	jne    800852 <strfind+0xc>
			break;
	return (char *) s;
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	57                   	push   %edi
  800866:	56                   	push   %esi
  800867:	53                   	push   %ebx
  800868:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80086e:	85 c9                	test   %ecx,%ecx
  800870:	74 36                	je     8008a8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800872:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800878:	75 28                	jne    8008a2 <memset+0x40>
  80087a:	f6 c1 03             	test   $0x3,%cl
  80087d:	75 23                	jne    8008a2 <memset+0x40>
		c &= 0xFF;
  80087f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800883:	89 d3                	mov    %edx,%ebx
  800885:	c1 e3 08             	shl    $0x8,%ebx
  800888:	89 d6                	mov    %edx,%esi
  80088a:	c1 e6 18             	shl    $0x18,%esi
  80088d:	89 d0                	mov    %edx,%eax
  80088f:	c1 e0 10             	shl    $0x10,%eax
  800892:	09 f0                	or     %esi,%eax
  800894:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800896:	89 d8                	mov    %ebx,%eax
  800898:	09 d0                	or     %edx,%eax
  80089a:	c1 e9 02             	shr    $0x2,%ecx
  80089d:	fc                   	cld    
  80089e:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a0:	eb 06                	jmp    8008a8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a5:	fc                   	cld    
  8008a6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a8:	89 f8                	mov    %edi,%eax
  8008aa:	5b                   	pop    %ebx
  8008ab:	5e                   	pop    %esi
  8008ac:	5f                   	pop    %edi
  8008ad:	5d                   	pop    %ebp
  8008ae:	c3                   	ret    

008008af <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008af:	55                   	push   %ebp
  8008b0:	89 e5                	mov    %esp,%ebp
  8008b2:	57                   	push   %edi
  8008b3:	56                   	push   %esi
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008bd:	39 c6                	cmp    %eax,%esi
  8008bf:	73 35                	jae    8008f6 <memmove+0x47>
  8008c1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c4:	39 d0                	cmp    %edx,%eax
  8008c6:	73 2e                	jae    8008f6 <memmove+0x47>
		s += n;
		d += n;
  8008c8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008cb:	89 d6                	mov    %edx,%esi
  8008cd:	09 fe                	or     %edi,%esi
  8008cf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d5:	75 13                	jne    8008ea <memmove+0x3b>
  8008d7:	f6 c1 03             	test   $0x3,%cl
  8008da:	75 0e                	jne    8008ea <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008dc:	83 ef 04             	sub    $0x4,%edi
  8008df:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e2:	c1 e9 02             	shr    $0x2,%ecx
  8008e5:	fd                   	std    
  8008e6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e8:	eb 09                	jmp    8008f3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ea:	83 ef 01             	sub    $0x1,%edi
  8008ed:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008f0:	fd                   	std    
  8008f1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f3:	fc                   	cld    
  8008f4:	eb 1d                	jmp    800913 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f6:	89 f2                	mov    %esi,%edx
  8008f8:	09 c2                	or     %eax,%edx
  8008fa:	f6 c2 03             	test   $0x3,%dl
  8008fd:	75 0f                	jne    80090e <memmove+0x5f>
  8008ff:	f6 c1 03             	test   $0x3,%cl
  800902:	75 0a                	jne    80090e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800904:	c1 e9 02             	shr    $0x2,%ecx
  800907:	89 c7                	mov    %eax,%edi
  800909:	fc                   	cld    
  80090a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090c:	eb 05                	jmp    800913 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80090e:	89 c7                	mov    %eax,%edi
  800910:	fc                   	cld    
  800911:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800913:	5e                   	pop    %esi
  800914:	5f                   	pop    %edi
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80091a:	ff 75 10             	pushl  0x10(%ebp)
  80091d:	ff 75 0c             	pushl  0xc(%ebp)
  800920:	ff 75 08             	pushl  0x8(%ebp)
  800923:	e8 87 ff ff ff       	call   8008af <memmove>
}
  800928:	c9                   	leave  
  800929:	c3                   	ret    

0080092a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	56                   	push   %esi
  80092e:	53                   	push   %ebx
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 55 0c             	mov    0xc(%ebp),%edx
  800935:	89 c6                	mov    %eax,%esi
  800937:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093a:	eb 1a                	jmp    800956 <memcmp+0x2c>
		if (*s1 != *s2)
  80093c:	0f b6 08             	movzbl (%eax),%ecx
  80093f:	0f b6 1a             	movzbl (%edx),%ebx
  800942:	38 d9                	cmp    %bl,%cl
  800944:	74 0a                	je     800950 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800946:	0f b6 c1             	movzbl %cl,%eax
  800949:	0f b6 db             	movzbl %bl,%ebx
  80094c:	29 d8                	sub    %ebx,%eax
  80094e:	eb 0f                	jmp    80095f <memcmp+0x35>
		s1++, s2++;
  800950:	83 c0 01             	add    $0x1,%eax
  800953:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800956:	39 f0                	cmp    %esi,%eax
  800958:	75 e2                	jne    80093c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80095a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095f:	5b                   	pop    %ebx
  800960:	5e                   	pop    %esi
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	53                   	push   %ebx
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80096a:	89 c1                	mov    %eax,%ecx
  80096c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80096f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800973:	eb 0a                	jmp    80097f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800975:	0f b6 10             	movzbl (%eax),%edx
  800978:	39 da                	cmp    %ebx,%edx
  80097a:	74 07                	je     800983 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80097c:	83 c0 01             	add    $0x1,%eax
  80097f:	39 c8                	cmp    %ecx,%eax
  800981:	72 f2                	jb     800975 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800983:	5b                   	pop    %ebx
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	57                   	push   %edi
  80098a:	56                   	push   %esi
  80098b:	53                   	push   %ebx
  80098c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800992:	eb 03                	jmp    800997 <strtol+0x11>
		s++;
  800994:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800997:	0f b6 01             	movzbl (%ecx),%eax
  80099a:	3c 20                	cmp    $0x20,%al
  80099c:	74 f6                	je     800994 <strtol+0xe>
  80099e:	3c 09                	cmp    $0x9,%al
  8009a0:	74 f2                	je     800994 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a2:	3c 2b                	cmp    $0x2b,%al
  8009a4:	75 0a                	jne    8009b0 <strtol+0x2a>
		s++;
  8009a6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a9:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ae:	eb 11                	jmp    8009c1 <strtol+0x3b>
  8009b0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b5:	3c 2d                	cmp    $0x2d,%al
  8009b7:	75 08                	jne    8009c1 <strtol+0x3b>
		s++, neg = 1;
  8009b9:	83 c1 01             	add    $0x1,%ecx
  8009bc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c7:	75 15                	jne    8009de <strtol+0x58>
  8009c9:	80 39 30             	cmpb   $0x30,(%ecx)
  8009cc:	75 10                	jne    8009de <strtol+0x58>
  8009ce:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009d2:	75 7c                	jne    800a50 <strtol+0xca>
		s += 2, base = 16;
  8009d4:	83 c1 02             	add    $0x2,%ecx
  8009d7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009dc:	eb 16                	jmp    8009f4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009de:	85 db                	test   %ebx,%ebx
  8009e0:	75 12                	jne    8009f4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e7:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ea:	75 08                	jne    8009f4 <strtol+0x6e>
		s++, base = 8;
  8009ec:	83 c1 01             	add    $0x1,%ecx
  8009ef:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009fc:	0f b6 11             	movzbl (%ecx),%edx
  8009ff:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a02:	89 f3                	mov    %esi,%ebx
  800a04:	80 fb 09             	cmp    $0x9,%bl
  800a07:	77 08                	ja     800a11 <strtol+0x8b>
			dig = *s - '0';
  800a09:	0f be d2             	movsbl %dl,%edx
  800a0c:	83 ea 30             	sub    $0x30,%edx
  800a0f:	eb 22                	jmp    800a33 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a11:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a14:	89 f3                	mov    %esi,%ebx
  800a16:	80 fb 19             	cmp    $0x19,%bl
  800a19:	77 08                	ja     800a23 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a1b:	0f be d2             	movsbl %dl,%edx
  800a1e:	83 ea 57             	sub    $0x57,%edx
  800a21:	eb 10                	jmp    800a33 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a23:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a26:	89 f3                	mov    %esi,%ebx
  800a28:	80 fb 19             	cmp    $0x19,%bl
  800a2b:	77 16                	ja     800a43 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a2d:	0f be d2             	movsbl %dl,%edx
  800a30:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a33:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a36:	7d 0b                	jge    800a43 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a38:	83 c1 01             	add    $0x1,%ecx
  800a3b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a3f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a41:	eb b9                	jmp    8009fc <strtol+0x76>

	if (endptr)
  800a43:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a47:	74 0d                	je     800a56 <strtol+0xd0>
		*endptr = (char *) s;
  800a49:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4c:	89 0e                	mov    %ecx,(%esi)
  800a4e:	eb 06                	jmp    800a56 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a50:	85 db                	test   %ebx,%ebx
  800a52:	74 98                	je     8009ec <strtol+0x66>
  800a54:	eb 9e                	jmp    8009f4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a56:	89 c2                	mov    %eax,%edx
  800a58:	f7 da                	neg    %edx
  800a5a:	85 ff                	test   %edi,%edi
  800a5c:	0f 45 c2             	cmovne %edx,%eax
}
  800a5f:	5b                   	pop    %ebx
  800a60:	5e                   	pop    %esi
  800a61:	5f                   	pop    %edi
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a72:	8b 55 08             	mov    0x8(%ebp),%edx
  800a75:	89 c3                	mov    %eax,%ebx
  800a77:	89 c7                	mov    %eax,%edi
  800a79:	89 c6                	mov    %eax,%esi
  800a7b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5e                   	pop    %esi
  800a7f:	5f                   	pop    %edi
  800a80:	5d                   	pop    %ebp
  800a81:	c3                   	ret    

00800a82 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	57                   	push   %edi
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a88:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a92:	89 d1                	mov    %edx,%ecx
  800a94:	89 d3                	mov    %edx,%ebx
  800a96:	89 d7                	mov    %edx,%edi
  800a98:	89 d6                	mov    %edx,%esi
  800a9a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a9c:	5b                   	pop    %ebx
  800a9d:	5e                   	pop    %esi
  800a9e:	5f                   	pop    %edi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	57                   	push   %edi
  800aa5:	56                   	push   %esi
  800aa6:	53                   	push   %ebx
  800aa7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aaa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aaf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab7:	89 cb                	mov    %ecx,%ebx
  800ab9:	89 cf                	mov    %ecx,%edi
  800abb:	89 ce                	mov    %ecx,%esi
  800abd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800abf:	85 c0                	test   %eax,%eax
  800ac1:	7e 17                	jle    800ada <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac3:	83 ec 0c             	sub    $0xc,%esp
  800ac6:	50                   	push   %eax
  800ac7:	6a 03                	push   $0x3
  800ac9:	68 40 10 80 00       	push   $0x801040
  800ace:	6a 23                	push   $0x23
  800ad0:	68 5d 10 80 00       	push   $0x80105d
  800ad5:	e8 27 00 00 00       	call   800b01 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ada:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae8:	ba 00 00 00 00       	mov    $0x0,%edx
  800aed:	b8 02 00 00 00       	mov    $0x2,%eax
  800af2:	89 d1                	mov    %edx,%ecx
  800af4:	89 d3                	mov    %edx,%ebx
  800af6:	89 d7                	mov    %edx,%edi
  800af8:	89 d6                	mov    %edx,%esi
  800afa:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b06:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b09:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800b0f:	e8 ce ff ff ff       	call   800ae2 <sys_getenvid>
  800b14:	83 ec 0c             	sub    $0xc,%esp
  800b17:	ff 75 0c             	pushl  0xc(%ebp)
  800b1a:	ff 75 08             	pushl  0x8(%ebp)
  800b1d:	56                   	push   %esi
  800b1e:	50                   	push   %eax
  800b1f:	68 6c 10 80 00       	push   $0x80106c
  800b24:	e8 2d f6 ff ff       	call   800156 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b29:	83 c4 18             	add    $0x18,%esp
  800b2c:	53                   	push   %ebx
  800b2d:	ff 75 10             	pushl  0x10(%ebp)
  800b30:	e8 d0 f5 ff ff       	call   800105 <vcprintf>
	cprintf("\n");
  800b35:	c7 04 24 43 0e 80 00 	movl   $0x800e43,(%esp)
  800b3c:	e8 15 f6 ff ff       	call   800156 <cprintf>
  800b41:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b44:	cc                   	int3   
  800b45:	eb fd                	jmp    800b44 <_panic+0x43>
  800b47:	66 90                	xchg   %ax,%ax
  800b49:	66 90                	xchg   %ax,%ax
  800b4b:	66 90                	xchg   %ax,%ax
  800b4d:	66 90                	xchg   %ax,%ax
  800b4f:	90                   	nop

00800b50 <__udivdi3>:
  800b50:	55                   	push   %ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	83 ec 1c             	sub    $0x1c,%esp
  800b57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800b5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800b5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800b63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b67:	85 f6                	test   %esi,%esi
  800b69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b6d:	89 ca                	mov    %ecx,%edx
  800b6f:	89 f8                	mov    %edi,%eax
  800b71:	75 3d                	jne    800bb0 <__udivdi3+0x60>
  800b73:	39 cf                	cmp    %ecx,%edi
  800b75:	0f 87 c5 00 00 00    	ja     800c40 <__udivdi3+0xf0>
  800b7b:	85 ff                	test   %edi,%edi
  800b7d:	89 fd                	mov    %edi,%ebp
  800b7f:	75 0b                	jne    800b8c <__udivdi3+0x3c>
  800b81:	b8 01 00 00 00       	mov    $0x1,%eax
  800b86:	31 d2                	xor    %edx,%edx
  800b88:	f7 f7                	div    %edi
  800b8a:	89 c5                	mov    %eax,%ebp
  800b8c:	89 c8                	mov    %ecx,%eax
  800b8e:	31 d2                	xor    %edx,%edx
  800b90:	f7 f5                	div    %ebp
  800b92:	89 c1                	mov    %eax,%ecx
  800b94:	89 d8                	mov    %ebx,%eax
  800b96:	89 cf                	mov    %ecx,%edi
  800b98:	f7 f5                	div    %ebp
  800b9a:	89 c3                	mov    %eax,%ebx
  800b9c:	89 d8                	mov    %ebx,%eax
  800b9e:	89 fa                	mov    %edi,%edx
  800ba0:	83 c4 1c             	add    $0x1c,%esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    
  800ba8:	90                   	nop
  800ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800bb0:	39 ce                	cmp    %ecx,%esi
  800bb2:	77 74                	ja     800c28 <__udivdi3+0xd8>
  800bb4:	0f bd fe             	bsr    %esi,%edi
  800bb7:	83 f7 1f             	xor    $0x1f,%edi
  800bba:	0f 84 98 00 00 00    	je     800c58 <__udivdi3+0x108>
  800bc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800bc5:	89 f9                	mov    %edi,%ecx
  800bc7:	89 c5                	mov    %eax,%ebp
  800bc9:	29 fb                	sub    %edi,%ebx
  800bcb:	d3 e6                	shl    %cl,%esi
  800bcd:	89 d9                	mov    %ebx,%ecx
  800bcf:	d3 ed                	shr    %cl,%ebp
  800bd1:	89 f9                	mov    %edi,%ecx
  800bd3:	d3 e0                	shl    %cl,%eax
  800bd5:	09 ee                	or     %ebp,%esi
  800bd7:	89 d9                	mov    %ebx,%ecx
  800bd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bdd:	89 d5                	mov    %edx,%ebp
  800bdf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800be3:	d3 ed                	shr    %cl,%ebp
  800be5:	89 f9                	mov    %edi,%ecx
  800be7:	d3 e2                	shl    %cl,%edx
  800be9:	89 d9                	mov    %ebx,%ecx
  800beb:	d3 e8                	shr    %cl,%eax
  800bed:	09 c2                	or     %eax,%edx
  800bef:	89 d0                	mov    %edx,%eax
  800bf1:	89 ea                	mov    %ebp,%edx
  800bf3:	f7 f6                	div    %esi
  800bf5:	89 d5                	mov    %edx,%ebp
  800bf7:	89 c3                	mov    %eax,%ebx
  800bf9:	f7 64 24 0c          	mull   0xc(%esp)
  800bfd:	39 d5                	cmp    %edx,%ebp
  800bff:	72 10                	jb     800c11 <__udivdi3+0xc1>
  800c01:	8b 74 24 08          	mov    0x8(%esp),%esi
  800c05:	89 f9                	mov    %edi,%ecx
  800c07:	d3 e6                	shl    %cl,%esi
  800c09:	39 c6                	cmp    %eax,%esi
  800c0b:	73 07                	jae    800c14 <__udivdi3+0xc4>
  800c0d:	39 d5                	cmp    %edx,%ebp
  800c0f:	75 03                	jne    800c14 <__udivdi3+0xc4>
  800c11:	83 eb 01             	sub    $0x1,%ebx
  800c14:	31 ff                	xor    %edi,%edi
  800c16:	89 d8                	mov    %ebx,%eax
  800c18:	89 fa                	mov    %edi,%edx
  800c1a:	83 c4 1c             	add    $0x1c,%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    
  800c22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c28:	31 ff                	xor    %edi,%edi
  800c2a:	31 db                	xor    %ebx,%ebx
  800c2c:	89 d8                	mov    %ebx,%eax
  800c2e:	89 fa                	mov    %edi,%edx
  800c30:	83 c4 1c             	add    $0x1c,%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    
  800c38:	90                   	nop
  800c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c40:	89 d8                	mov    %ebx,%eax
  800c42:	f7 f7                	div    %edi
  800c44:	31 ff                	xor    %edi,%edi
  800c46:	89 c3                	mov    %eax,%ebx
  800c48:	89 d8                	mov    %ebx,%eax
  800c4a:	89 fa                	mov    %edi,%edx
  800c4c:	83 c4 1c             	add    $0x1c,%esp
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    
  800c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c58:	39 ce                	cmp    %ecx,%esi
  800c5a:	72 0c                	jb     800c68 <__udivdi3+0x118>
  800c5c:	31 db                	xor    %ebx,%ebx
  800c5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800c62:	0f 87 34 ff ff ff    	ja     800b9c <__udivdi3+0x4c>
  800c68:	bb 01 00 00 00       	mov    $0x1,%ebx
  800c6d:	e9 2a ff ff ff       	jmp    800b9c <__udivdi3+0x4c>
  800c72:	66 90                	xchg   %ax,%ax
  800c74:	66 90                	xchg   %ax,%ax
  800c76:	66 90                	xchg   %ax,%ax
  800c78:	66 90                	xchg   %ax,%ax
  800c7a:	66 90                	xchg   %ax,%ax
  800c7c:	66 90                	xchg   %ax,%ax
  800c7e:	66 90                	xchg   %ax,%ax

00800c80 <__umoddi3>:
  800c80:	55                   	push   %ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 1c             	sub    $0x1c,%esp
  800c87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c97:	85 d2                	test   %edx,%edx
  800c99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ca1:	89 f3                	mov    %esi,%ebx
  800ca3:	89 3c 24             	mov    %edi,(%esp)
  800ca6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800caa:	75 1c                	jne    800cc8 <__umoddi3+0x48>
  800cac:	39 f7                	cmp    %esi,%edi
  800cae:	76 50                	jbe    800d00 <__umoddi3+0x80>
  800cb0:	89 c8                	mov    %ecx,%eax
  800cb2:	89 f2                	mov    %esi,%edx
  800cb4:	f7 f7                	div    %edi
  800cb6:	89 d0                	mov    %edx,%eax
  800cb8:	31 d2                	xor    %edx,%edx
  800cba:	83 c4 1c             	add    $0x1c,%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    
  800cc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cc8:	39 f2                	cmp    %esi,%edx
  800cca:	89 d0                	mov    %edx,%eax
  800ccc:	77 52                	ja     800d20 <__umoddi3+0xa0>
  800cce:	0f bd ea             	bsr    %edx,%ebp
  800cd1:	83 f5 1f             	xor    $0x1f,%ebp
  800cd4:	75 5a                	jne    800d30 <__umoddi3+0xb0>
  800cd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800cda:	0f 82 e0 00 00 00    	jb     800dc0 <__umoddi3+0x140>
  800ce0:	39 0c 24             	cmp    %ecx,(%esp)
  800ce3:	0f 86 d7 00 00 00    	jbe    800dc0 <__umoddi3+0x140>
  800ce9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ced:	8b 54 24 04          	mov    0x4(%esp),%edx
  800cf1:	83 c4 1c             	add    $0x1c,%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    
  800cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d00:	85 ff                	test   %edi,%edi
  800d02:	89 fd                	mov    %edi,%ebp
  800d04:	75 0b                	jne    800d11 <__umoddi3+0x91>
  800d06:	b8 01 00 00 00       	mov    $0x1,%eax
  800d0b:	31 d2                	xor    %edx,%edx
  800d0d:	f7 f7                	div    %edi
  800d0f:	89 c5                	mov    %eax,%ebp
  800d11:	89 f0                	mov    %esi,%eax
  800d13:	31 d2                	xor    %edx,%edx
  800d15:	f7 f5                	div    %ebp
  800d17:	89 c8                	mov    %ecx,%eax
  800d19:	f7 f5                	div    %ebp
  800d1b:	89 d0                	mov    %edx,%eax
  800d1d:	eb 99                	jmp    800cb8 <__umoddi3+0x38>
  800d1f:	90                   	nop
  800d20:	89 c8                	mov    %ecx,%eax
  800d22:	89 f2                	mov    %esi,%edx
  800d24:	83 c4 1c             	add    $0x1c,%esp
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    
  800d2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d30:	8b 34 24             	mov    (%esp),%esi
  800d33:	bf 20 00 00 00       	mov    $0x20,%edi
  800d38:	89 e9                	mov    %ebp,%ecx
  800d3a:	29 ef                	sub    %ebp,%edi
  800d3c:	d3 e0                	shl    %cl,%eax
  800d3e:	89 f9                	mov    %edi,%ecx
  800d40:	89 f2                	mov    %esi,%edx
  800d42:	d3 ea                	shr    %cl,%edx
  800d44:	89 e9                	mov    %ebp,%ecx
  800d46:	09 c2                	or     %eax,%edx
  800d48:	89 d8                	mov    %ebx,%eax
  800d4a:	89 14 24             	mov    %edx,(%esp)
  800d4d:	89 f2                	mov    %esi,%edx
  800d4f:	d3 e2                	shl    %cl,%edx
  800d51:	89 f9                	mov    %edi,%ecx
  800d53:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d57:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d5b:	d3 e8                	shr    %cl,%eax
  800d5d:	89 e9                	mov    %ebp,%ecx
  800d5f:	89 c6                	mov    %eax,%esi
  800d61:	d3 e3                	shl    %cl,%ebx
  800d63:	89 f9                	mov    %edi,%ecx
  800d65:	89 d0                	mov    %edx,%eax
  800d67:	d3 e8                	shr    %cl,%eax
  800d69:	89 e9                	mov    %ebp,%ecx
  800d6b:	09 d8                	or     %ebx,%eax
  800d6d:	89 d3                	mov    %edx,%ebx
  800d6f:	89 f2                	mov    %esi,%edx
  800d71:	f7 34 24             	divl   (%esp)
  800d74:	89 d6                	mov    %edx,%esi
  800d76:	d3 e3                	shl    %cl,%ebx
  800d78:	f7 64 24 04          	mull   0x4(%esp)
  800d7c:	39 d6                	cmp    %edx,%esi
  800d7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d82:	89 d1                	mov    %edx,%ecx
  800d84:	89 c3                	mov    %eax,%ebx
  800d86:	72 08                	jb     800d90 <__umoddi3+0x110>
  800d88:	75 11                	jne    800d9b <__umoddi3+0x11b>
  800d8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800d8e:	73 0b                	jae    800d9b <__umoddi3+0x11b>
  800d90:	2b 44 24 04          	sub    0x4(%esp),%eax
  800d94:	1b 14 24             	sbb    (%esp),%edx
  800d97:	89 d1                	mov    %edx,%ecx
  800d99:	89 c3                	mov    %eax,%ebx
  800d9b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800d9f:	29 da                	sub    %ebx,%edx
  800da1:	19 ce                	sbb    %ecx,%esi
  800da3:	89 f9                	mov    %edi,%ecx
  800da5:	89 f0                	mov    %esi,%eax
  800da7:	d3 e0                	shl    %cl,%eax
  800da9:	89 e9                	mov    %ebp,%ecx
  800dab:	d3 ea                	shr    %cl,%edx
  800dad:	89 e9                	mov    %ebp,%ecx
  800daf:	d3 ee                	shr    %cl,%esi
  800db1:	09 d0                	or     %edx,%eax
  800db3:	89 f2                	mov    %esi,%edx
  800db5:	83 c4 1c             	add    $0x1c,%esp
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    
  800dbd:	8d 76 00             	lea    0x0(%esi),%esi
  800dc0:	29 f9                	sub    %edi,%ecx
  800dc2:	19 d6                	sbb    %edx,%esi
  800dc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dc8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dcc:	e9 18 ff ff ff       	jmp    800ce9 <__umoddi3+0x69>
