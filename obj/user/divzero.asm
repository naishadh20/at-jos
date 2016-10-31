
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 c0 0f 80 00       	push   $0x800fc0
  800056:	e8 fa 00 00 00       	call   800155 <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006b:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800072:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  800075:	e8 67 0a 00 00       	call   800ae1 <sys_getenvid>
  80007a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800082:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800087:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008c:	85 db                	test   %ebx,%ebx
  80008e:	7e 07                	jle    800097 <libmain+0x37>
		binaryname = argv[0];
  800090:	8b 06                	mov    (%esi),%eax
  800092:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800097:	83 ec 08             	sub    $0x8,%esp
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
  80009c:	e8 92 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a1:	e8 0a 00 00 00       	call   8000b0 <exit>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ac:	5b                   	pop    %ebx
  8000ad:	5e                   	pop    %esi
  8000ae:	5d                   	pop    %ebp
  8000af:	c3                   	ret    

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b6:	6a 00                	push   $0x0
  8000b8:	e8 e3 09 00 00       	call   800aa0 <sys_env_destroy>
}
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	c9                   	leave  
  8000c1:	c3                   	ret    

008000c2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	53                   	push   %ebx
  8000c6:	83 ec 04             	sub    $0x4,%esp
  8000c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000cc:	8b 13                	mov    (%ebx),%edx
  8000ce:	8d 42 01             	lea    0x1(%edx),%eax
  8000d1:	89 03                	mov    %eax,(%ebx)
  8000d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000df:	75 1a                	jne    8000fb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000e1:	83 ec 08             	sub    $0x8,%esp
  8000e4:	68 ff 00 00 00       	push   $0xff
  8000e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ec:	50                   	push   %eax
  8000ed:	e8 71 09 00 00       	call   800a63 <sys_cputs>
		b->idx = 0;
  8000f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000fb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800114:	00 00 00 
	b.cnt = 0;
  800117:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800121:	ff 75 0c             	pushl  0xc(%ebp)
  800124:	ff 75 08             	pushl  0x8(%ebp)
  800127:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	68 c2 00 80 00       	push   $0x8000c2
  800133:	e8 54 01 00 00       	call   80028c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800138:	83 c4 08             	add    $0x8,%esp
  80013b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800141:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800147:	50                   	push   %eax
  800148:	e8 16 09 00 00       	call   800a63 <sys_cputs>

	return b.cnt;
}
  80014d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015e:	50                   	push   %eax
  80015f:	ff 75 08             	pushl  0x8(%ebp)
  800162:	e8 9d ff ff ff       	call   800104 <vcprintf>
	va_end(ap);

	return cnt;
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    

00800169 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	57                   	push   %edi
  80016d:	56                   	push   %esi
  80016e:	53                   	push   %ebx
  80016f:	83 ec 1c             	sub    $0x1c,%esp
  800172:	89 c7                	mov    %eax,%edi
  800174:	89 d6                	mov    %edx,%esi
  800176:	8b 45 08             	mov    0x8(%ebp),%eax
  800179:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800182:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800185:	bb 00 00 00 00       	mov    $0x0,%ebx
  80018a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80018d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800190:	39 d3                	cmp    %edx,%ebx
  800192:	72 05                	jb     800199 <printnum+0x30>
  800194:	39 45 10             	cmp    %eax,0x10(%ebp)
  800197:	77 45                	ja     8001de <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800199:	83 ec 0c             	sub    $0xc,%esp
  80019c:	ff 75 18             	pushl  0x18(%ebp)
  80019f:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a5:	53                   	push   %ebx
  8001a6:	ff 75 10             	pushl  0x10(%ebp)
  8001a9:	83 ec 08             	sub    $0x8,%esp
  8001ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001af:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b8:	e8 63 0b 00 00       	call   800d20 <__udivdi3>
  8001bd:	83 c4 18             	add    $0x18,%esp
  8001c0:	52                   	push   %edx
  8001c1:	50                   	push   %eax
  8001c2:	89 f2                	mov    %esi,%edx
  8001c4:	89 f8                	mov    %edi,%eax
  8001c6:	e8 9e ff ff ff       	call   800169 <printnum>
  8001cb:	83 c4 20             	add    $0x20,%esp
  8001ce:	eb 18                	jmp    8001e8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d0:	83 ec 08             	sub    $0x8,%esp
  8001d3:	56                   	push   %esi
  8001d4:	ff 75 18             	pushl  0x18(%ebp)
  8001d7:	ff d7                	call   *%edi
  8001d9:	83 c4 10             	add    $0x10,%esp
  8001dc:	eb 03                	jmp    8001e1 <printnum+0x78>
  8001de:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e1:	83 eb 01             	sub    $0x1,%ebx
  8001e4:	85 db                	test   %ebx,%ebx
  8001e6:	7f e8                	jg     8001d0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	56                   	push   %esi
  8001ec:	83 ec 04             	sub    $0x4,%esp
  8001ef:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f5:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f8:	ff 75 d8             	pushl  -0x28(%ebp)
  8001fb:	e8 50 0c 00 00       	call   800e50 <__umoddi3>
  800200:	83 c4 14             	add    $0x14,%esp
  800203:	0f be 80 d8 0f 80 00 	movsbl 0x800fd8(%eax),%eax
  80020a:	50                   	push   %eax
  80020b:	ff d7                	call   *%edi
}
  80020d:	83 c4 10             	add    $0x10,%esp
  800210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800213:	5b                   	pop    %ebx
  800214:	5e                   	pop    %esi
  800215:	5f                   	pop    %edi
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    

00800218 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80021b:	83 fa 01             	cmp    $0x1,%edx
  80021e:	7e 0e                	jle    80022e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800220:	8b 10                	mov    (%eax),%edx
  800222:	8d 4a 08             	lea    0x8(%edx),%ecx
  800225:	89 08                	mov    %ecx,(%eax)
  800227:	8b 02                	mov    (%edx),%eax
  800229:	8b 52 04             	mov    0x4(%edx),%edx
  80022c:	eb 22                	jmp    800250 <getuint+0x38>
	else if (lflag)
  80022e:	85 d2                	test   %edx,%edx
  800230:	74 10                	je     800242 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800232:	8b 10                	mov    (%eax),%edx
  800234:	8d 4a 04             	lea    0x4(%edx),%ecx
  800237:	89 08                	mov    %ecx,(%eax)
  800239:	8b 02                	mov    (%edx),%eax
  80023b:	ba 00 00 00 00       	mov    $0x0,%edx
  800240:	eb 0e                	jmp    800250 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800242:	8b 10                	mov    (%eax),%edx
  800244:	8d 4a 04             	lea    0x4(%edx),%ecx
  800247:	89 08                	mov    %ecx,(%eax)
  800249:	8b 02                	mov    (%edx),%eax
  80024b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800250:	5d                   	pop    %ebp
  800251:	c3                   	ret    

00800252 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800258:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025c:	8b 10                	mov    (%eax),%edx
  80025e:	3b 50 04             	cmp    0x4(%eax),%edx
  800261:	73 0a                	jae    80026d <sprintputch+0x1b>
		*b->buf++ = ch;
  800263:	8d 4a 01             	lea    0x1(%edx),%ecx
  800266:	89 08                	mov    %ecx,(%eax)
  800268:	8b 45 08             	mov    0x8(%ebp),%eax
  80026b:	88 02                	mov    %al,(%edx)
}
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800275:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800278:	50                   	push   %eax
  800279:	ff 75 10             	pushl  0x10(%ebp)
  80027c:	ff 75 0c             	pushl  0xc(%ebp)
  80027f:	ff 75 08             	pushl  0x8(%ebp)
  800282:	e8 05 00 00 00       	call   80028c <vprintfmt>
	va_end(ap);
}
  800287:	83 c4 10             	add    $0x10,%esp
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	53                   	push   %ebx
  800292:	83 ec 2c             	sub    $0x2c,%esp
  800295:	8b 75 08             	mov    0x8(%ebp),%esi
  800298:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80029b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029e:	eb 12                	jmp    8002b2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002a0:	85 c0                	test   %eax,%eax
  8002a2:	0f 84 cb 03 00 00    	je     800673 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	53                   	push   %ebx
  8002ac:	50                   	push   %eax
  8002ad:	ff d6                	call   *%esi
  8002af:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b2:	83 c7 01             	add    $0x1,%edi
  8002b5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002b9:	83 f8 25             	cmp    $0x25,%eax
  8002bc:	75 e2                	jne    8002a0 <vprintfmt+0x14>
  8002be:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002c9:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002d0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dc:	eb 07                	jmp    8002e5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002de:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002e1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e5:	8d 47 01             	lea    0x1(%edi),%eax
  8002e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002eb:	0f b6 07             	movzbl (%edi),%eax
  8002ee:	0f b6 c8             	movzbl %al,%ecx
  8002f1:	83 e8 23             	sub    $0x23,%eax
  8002f4:	3c 55                	cmp    $0x55,%al
  8002f6:	0f 87 5c 03 00 00    	ja     800658 <vprintfmt+0x3cc>
  8002fc:	0f b6 c0             	movzbl %al,%eax
  8002ff:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  800306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800309:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030d:	eb d6                	jmp    8002e5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800312:	b8 00 00 00 00       	mov    $0x0,%eax
  800317:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80031a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800321:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800324:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800327:	83 fa 09             	cmp    $0x9,%edx
  80032a:	77 39                	ja     800365 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80032c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80032f:	eb e9                	jmp    80031a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800331:	8b 45 14             	mov    0x14(%ebp),%eax
  800334:	8d 48 04             	lea    0x4(%eax),%ecx
  800337:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80033a:	8b 00                	mov    (%eax),%eax
  80033c:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800342:	eb 27                	jmp    80036b <vprintfmt+0xdf>
  800344:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800347:	85 c0                	test   %eax,%eax
  800349:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034e:	0f 49 c8             	cmovns %eax,%ecx
  800351:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800357:	eb 8c                	jmp    8002e5 <vprintfmt+0x59>
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80035c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800363:	eb 80                	jmp    8002e5 <vprintfmt+0x59>
  800365:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800368:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80036b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036f:	0f 89 70 ff ff ff    	jns    8002e5 <vprintfmt+0x59>
				width = precision, precision = -1;
  800375:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800378:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037b:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800382:	e9 5e ff ff ff       	jmp    8002e5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800387:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80038d:	e9 53 ff ff ff       	jmp    8002e5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800392:	8b 45 14             	mov    0x14(%ebp),%eax
  800395:	8d 50 04             	lea    0x4(%eax),%edx
  800398:	89 55 14             	mov    %edx,0x14(%ebp)
  80039b:	83 ec 08             	sub    $0x8,%esp
  80039e:	53                   	push   %ebx
  80039f:	ff 30                	pushl  (%eax)
  8003a1:	ff d6                	call   *%esi
			break;
  8003a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003a9:	e9 04 ff ff ff       	jmp    8002b2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b1:	8d 50 04             	lea    0x4(%eax),%edx
  8003b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b7:	8b 00                	mov    (%eax),%eax
  8003b9:	99                   	cltd   
  8003ba:	31 d0                	xor    %edx,%eax
  8003bc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003be:	83 f8 09             	cmp    $0x9,%eax
  8003c1:	7f 0b                	jg     8003ce <vprintfmt+0x142>
  8003c3:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  8003ca:	85 d2                	test   %edx,%edx
  8003cc:	75 18                	jne    8003e6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003ce:	50                   	push   %eax
  8003cf:	68 f0 0f 80 00       	push   $0x800ff0
  8003d4:	53                   	push   %ebx
  8003d5:	56                   	push   %esi
  8003d6:	e8 94 fe ff ff       	call   80026f <printfmt>
  8003db:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003e1:	e9 cc fe ff ff       	jmp    8002b2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003e6:	52                   	push   %edx
  8003e7:	68 f9 0f 80 00       	push   $0x800ff9
  8003ec:	53                   	push   %ebx
  8003ed:	56                   	push   %esi
  8003ee:	e8 7c fe ff ff       	call   80026f <printfmt>
  8003f3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f9:	e9 b4 fe ff ff       	jmp    8002b2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800401:	8d 50 04             	lea    0x4(%eax),%edx
  800404:	89 55 14             	mov    %edx,0x14(%ebp)
  800407:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800409:	85 ff                	test   %edi,%edi
  80040b:	b8 e9 0f 80 00       	mov    $0x800fe9,%eax
  800410:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800413:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800417:	0f 8e 94 00 00 00    	jle    8004b1 <vprintfmt+0x225>
  80041d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800421:	0f 84 98 00 00 00    	je     8004bf <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800427:	83 ec 08             	sub    $0x8,%esp
  80042a:	ff 75 c8             	pushl  -0x38(%ebp)
  80042d:	57                   	push   %edi
  80042e:	e8 c8 02 00 00       	call   8006fb <strnlen>
  800433:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800436:	29 c1                	sub    %eax,%ecx
  800438:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80043b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80043e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800442:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800445:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800448:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80044a:	eb 0f                	jmp    80045b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	53                   	push   %ebx
  800450:	ff 75 e0             	pushl  -0x20(%ebp)
  800453:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800455:	83 ef 01             	sub    $0x1,%edi
  800458:	83 c4 10             	add    $0x10,%esp
  80045b:	85 ff                	test   %edi,%edi
  80045d:	7f ed                	jg     80044c <vprintfmt+0x1c0>
  80045f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800462:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800465:	85 c9                	test   %ecx,%ecx
  800467:	b8 00 00 00 00       	mov    $0x0,%eax
  80046c:	0f 49 c1             	cmovns %ecx,%eax
  80046f:	29 c1                	sub    %eax,%ecx
  800471:	89 75 08             	mov    %esi,0x8(%ebp)
  800474:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800477:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80047a:	89 cb                	mov    %ecx,%ebx
  80047c:	eb 4d                	jmp    8004cb <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80047e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800482:	74 1b                	je     80049f <vprintfmt+0x213>
  800484:	0f be c0             	movsbl %al,%eax
  800487:	83 e8 20             	sub    $0x20,%eax
  80048a:	83 f8 5e             	cmp    $0x5e,%eax
  80048d:	76 10                	jbe    80049f <vprintfmt+0x213>
					putch('?', putdat);
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	ff 75 0c             	pushl  0xc(%ebp)
  800495:	6a 3f                	push   $0x3f
  800497:	ff 55 08             	call   *0x8(%ebp)
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	eb 0d                	jmp    8004ac <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	ff 75 0c             	pushl  0xc(%ebp)
  8004a5:	52                   	push   %edx
  8004a6:	ff 55 08             	call   *0x8(%ebp)
  8004a9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ac:	83 eb 01             	sub    $0x1,%ebx
  8004af:	eb 1a                	jmp    8004cb <vprintfmt+0x23f>
  8004b1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b4:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004b7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ba:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004bd:	eb 0c                	jmp    8004cb <vprintfmt+0x23f>
  8004bf:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c2:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004c5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004cb:	83 c7 01             	add    $0x1,%edi
  8004ce:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d2:	0f be d0             	movsbl %al,%edx
  8004d5:	85 d2                	test   %edx,%edx
  8004d7:	74 23                	je     8004fc <vprintfmt+0x270>
  8004d9:	85 f6                	test   %esi,%esi
  8004db:	78 a1                	js     80047e <vprintfmt+0x1f2>
  8004dd:	83 ee 01             	sub    $0x1,%esi
  8004e0:	79 9c                	jns    80047e <vprintfmt+0x1f2>
  8004e2:	89 df                	mov    %ebx,%edi
  8004e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ea:	eb 18                	jmp    800504 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ec:	83 ec 08             	sub    $0x8,%esp
  8004ef:	53                   	push   %ebx
  8004f0:	6a 20                	push   $0x20
  8004f2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f4:	83 ef 01             	sub    $0x1,%edi
  8004f7:	83 c4 10             	add    $0x10,%esp
  8004fa:	eb 08                	jmp    800504 <vprintfmt+0x278>
  8004fc:	89 df                	mov    %ebx,%edi
  8004fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800501:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800504:	85 ff                	test   %edi,%edi
  800506:	7f e4                	jg     8004ec <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050b:	e9 a2 fd ff ff       	jmp    8002b2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800510:	83 fa 01             	cmp    $0x1,%edx
  800513:	7e 16                	jle    80052b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 50 08             	lea    0x8(%eax),%edx
  80051b:	89 55 14             	mov    %edx,0x14(%ebp)
  80051e:	8b 50 04             	mov    0x4(%eax),%edx
  800521:	8b 00                	mov    (%eax),%eax
  800523:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800526:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800529:	eb 32                	jmp    80055d <vprintfmt+0x2d1>
	else if (lflag)
  80052b:	85 d2                	test   %edx,%edx
  80052d:	74 18                	je     800547 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8d 50 04             	lea    0x4(%eax),%edx
  800535:	89 55 14             	mov    %edx,0x14(%ebp)
  800538:	8b 00                	mov    (%eax),%eax
  80053a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80053d:	89 c1                	mov    %eax,%ecx
  80053f:	c1 f9 1f             	sar    $0x1f,%ecx
  800542:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800545:	eb 16                	jmp    80055d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800547:	8b 45 14             	mov    0x14(%ebp),%eax
  80054a:	8d 50 04             	lea    0x4(%eax),%edx
  80054d:	89 55 14             	mov    %edx,0x14(%ebp)
  800550:	8b 00                	mov    (%eax),%eax
  800552:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800555:	89 c1                	mov    %eax,%ecx
  800557:	c1 f9 1f             	sar    $0x1f,%ecx
  80055a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80055d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800560:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800563:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800566:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800569:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80056e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800572:	0f 89 a8 00 00 00    	jns    800620 <vprintfmt+0x394>
				putch('-', putdat);
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	53                   	push   %ebx
  80057c:	6a 2d                	push   $0x2d
  80057e:	ff d6                	call   *%esi
				num = -(long long) num;
  800580:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800583:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800586:	f7 d8                	neg    %eax
  800588:	83 d2 00             	adc    $0x0,%edx
  80058b:	f7 da                	neg    %edx
  80058d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800590:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800593:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800596:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059b:	e9 80 00 00 00       	jmp    800620 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a3:	e8 70 fc ff ff       	call   800218 <getuint>
  8005a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005ae:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005b3:	eb 6b                	jmp    800620 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b8:	e8 5b fc ff ff       	call   800218 <getuint>
  8005bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  8005c3:	6a 04                	push   $0x4
  8005c5:	6a 03                	push   $0x3
  8005c7:	6a 01                	push   $0x1
  8005c9:	68 fc 0f 80 00       	push   $0x800ffc
  8005ce:	e8 82 fb ff ff       	call   800155 <cprintf>
			goto number;
  8005d3:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  8005d6:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  8005db:	eb 43                	jmp    800620 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	53                   	push   %ebx
  8005e1:	6a 30                	push   $0x30
  8005e3:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e5:	83 c4 08             	add    $0x8,%esp
  8005e8:	53                   	push   %ebx
  8005e9:	6a 78                	push   $0x78
  8005eb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 50 04             	lea    0x4(%eax),%edx
  8005f3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005f6:	8b 00                	mov    (%eax),%eax
  8005f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800600:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800603:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800606:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80060b:	eb 13                	jmp    800620 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060d:	8d 45 14             	lea    0x14(%ebp),%eax
  800610:	e8 03 fc ff ff       	call   800218 <getuint>
  800615:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800618:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80061b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800620:	83 ec 0c             	sub    $0xc,%esp
  800623:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800627:	52                   	push   %edx
  800628:	ff 75 e0             	pushl  -0x20(%ebp)
  80062b:	50                   	push   %eax
  80062c:	ff 75 dc             	pushl  -0x24(%ebp)
  80062f:	ff 75 d8             	pushl  -0x28(%ebp)
  800632:	89 da                	mov    %ebx,%edx
  800634:	89 f0                	mov    %esi,%eax
  800636:	e8 2e fb ff ff       	call   800169 <printnum>

			break;
  80063b:	83 c4 20             	add    $0x20,%esp
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800641:	e9 6c fc ff ff       	jmp    8002b2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	51                   	push   %ecx
  80064b:	ff d6                	call   *%esi
			break;
  80064d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800650:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800653:	e9 5a fc ff ff       	jmp    8002b2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	53                   	push   %ebx
  80065c:	6a 25                	push   $0x25
  80065e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	eb 03                	jmp    800668 <vprintfmt+0x3dc>
  800665:	83 ef 01             	sub    $0x1,%edi
  800668:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80066c:	75 f7                	jne    800665 <vprintfmt+0x3d9>
  80066e:	e9 3f fc ff ff       	jmp    8002b2 <vprintfmt+0x26>
			break;
		}

	}

}
  800673:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800676:	5b                   	pop    %ebx
  800677:	5e                   	pop    %esi
  800678:	5f                   	pop    %edi
  800679:	5d                   	pop    %ebp
  80067a:	c3                   	ret    

0080067b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80067b:	55                   	push   %ebp
  80067c:	89 e5                	mov    %esp,%ebp
  80067e:	83 ec 18             	sub    $0x18,%esp
  800681:	8b 45 08             	mov    0x8(%ebp),%eax
  800684:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800687:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80068a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80068e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800691:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800698:	85 c0                	test   %eax,%eax
  80069a:	74 26                	je     8006c2 <vsnprintf+0x47>
  80069c:	85 d2                	test   %edx,%edx
  80069e:	7e 22                	jle    8006c2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a0:	ff 75 14             	pushl  0x14(%ebp)
  8006a3:	ff 75 10             	pushl  0x10(%ebp)
  8006a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a9:	50                   	push   %eax
  8006aa:	68 52 02 80 00       	push   $0x800252
  8006af:	e8 d8 fb ff ff       	call   80028c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	eb 05                	jmp    8006c7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c7:	c9                   	leave  
  8006c8:	c3                   	ret    

008006c9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006cf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d2:	50                   	push   %eax
  8006d3:	ff 75 10             	pushl  0x10(%ebp)
  8006d6:	ff 75 0c             	pushl  0xc(%ebp)
  8006d9:	ff 75 08             	pushl  0x8(%ebp)
  8006dc:	e8 9a ff ff ff       	call   80067b <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    

008006e3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ee:	eb 03                	jmp    8006f3 <strlen+0x10>
		n++;
  8006f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f7:	75 f7                	jne    8006f0 <strlen+0xd>
		n++;
	return n;
}
  8006f9:	5d                   	pop    %ebp
  8006fa:	c3                   	ret    

008006fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800701:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800704:	ba 00 00 00 00       	mov    $0x0,%edx
  800709:	eb 03                	jmp    80070e <strnlen+0x13>
		n++;
  80070b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070e:	39 c2                	cmp    %eax,%edx
  800710:	74 08                	je     80071a <strnlen+0x1f>
  800712:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800716:	75 f3                	jne    80070b <strnlen+0x10>
  800718:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80071a:	5d                   	pop    %ebp
  80071b:	c3                   	ret    

0080071c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	53                   	push   %ebx
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800726:	89 c2                	mov    %eax,%edx
  800728:	83 c2 01             	add    $0x1,%edx
  80072b:	83 c1 01             	add    $0x1,%ecx
  80072e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800732:	88 5a ff             	mov    %bl,-0x1(%edx)
  800735:	84 db                	test   %bl,%bl
  800737:	75 ef                	jne    800728 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800739:	5b                   	pop    %ebx
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	53                   	push   %ebx
  800740:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800743:	53                   	push   %ebx
  800744:	e8 9a ff ff ff       	call   8006e3 <strlen>
  800749:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80074c:	ff 75 0c             	pushl  0xc(%ebp)
  80074f:	01 d8                	add    %ebx,%eax
  800751:	50                   	push   %eax
  800752:	e8 c5 ff ff ff       	call   80071c <strcpy>
	return dst;
}
  800757:	89 d8                	mov    %ebx,%eax
  800759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    

0080075e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	56                   	push   %esi
  800762:	53                   	push   %ebx
  800763:	8b 75 08             	mov    0x8(%ebp),%esi
  800766:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800769:	89 f3                	mov    %esi,%ebx
  80076b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076e:	89 f2                	mov    %esi,%edx
  800770:	eb 0f                	jmp    800781 <strncpy+0x23>
		*dst++ = *src;
  800772:	83 c2 01             	add    $0x1,%edx
  800775:	0f b6 01             	movzbl (%ecx),%eax
  800778:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80077b:	80 39 01             	cmpb   $0x1,(%ecx)
  80077e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800781:	39 da                	cmp    %ebx,%edx
  800783:	75 ed                	jne    800772 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800785:	89 f0                	mov    %esi,%eax
  800787:	5b                   	pop    %ebx
  800788:	5e                   	pop    %esi
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	56                   	push   %esi
  80078f:	53                   	push   %ebx
  800790:	8b 75 08             	mov    0x8(%ebp),%esi
  800793:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800796:	8b 55 10             	mov    0x10(%ebp),%edx
  800799:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079b:	85 d2                	test   %edx,%edx
  80079d:	74 21                	je     8007c0 <strlcpy+0x35>
  80079f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a3:	89 f2                	mov    %esi,%edx
  8007a5:	eb 09                	jmp    8007b0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a7:	83 c2 01             	add    $0x1,%edx
  8007aa:	83 c1 01             	add    $0x1,%ecx
  8007ad:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007b0:	39 c2                	cmp    %eax,%edx
  8007b2:	74 09                	je     8007bd <strlcpy+0x32>
  8007b4:	0f b6 19             	movzbl (%ecx),%ebx
  8007b7:	84 db                	test   %bl,%bl
  8007b9:	75 ec                	jne    8007a7 <strlcpy+0x1c>
  8007bb:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007bd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007c0:	29 f0                	sub    %esi,%eax
}
  8007c2:	5b                   	pop    %ebx
  8007c3:	5e                   	pop    %esi
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007cf:	eb 06                	jmp    8007d7 <strcmp+0x11>
		p++, q++;
  8007d1:	83 c1 01             	add    $0x1,%ecx
  8007d4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d7:	0f b6 01             	movzbl (%ecx),%eax
  8007da:	84 c0                	test   %al,%al
  8007dc:	74 04                	je     8007e2 <strcmp+0x1c>
  8007de:	3a 02                	cmp    (%edx),%al
  8007e0:	74 ef                	je     8007d1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e2:	0f b6 c0             	movzbl %al,%eax
  8007e5:	0f b6 12             	movzbl (%edx),%edx
  8007e8:	29 d0                	sub    %edx,%eax
}
  8007ea:	5d                   	pop    %ebp
  8007eb:	c3                   	ret    

008007ec <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	53                   	push   %ebx
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f6:	89 c3                	mov    %eax,%ebx
  8007f8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007fb:	eb 06                	jmp    800803 <strncmp+0x17>
		n--, p++, q++;
  8007fd:	83 c0 01             	add    $0x1,%eax
  800800:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800803:	39 d8                	cmp    %ebx,%eax
  800805:	74 15                	je     80081c <strncmp+0x30>
  800807:	0f b6 08             	movzbl (%eax),%ecx
  80080a:	84 c9                	test   %cl,%cl
  80080c:	74 04                	je     800812 <strncmp+0x26>
  80080e:	3a 0a                	cmp    (%edx),%cl
  800810:	74 eb                	je     8007fd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800812:	0f b6 00             	movzbl (%eax),%eax
  800815:	0f b6 12             	movzbl (%edx),%edx
  800818:	29 d0                	sub    %edx,%eax
  80081a:	eb 05                	jmp    800821 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80081c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800821:	5b                   	pop    %ebx
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082e:	eb 07                	jmp    800837 <strchr+0x13>
		if (*s == c)
  800830:	38 ca                	cmp    %cl,%dl
  800832:	74 0f                	je     800843 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800834:	83 c0 01             	add    $0x1,%eax
  800837:	0f b6 10             	movzbl (%eax),%edx
  80083a:	84 d2                	test   %dl,%dl
  80083c:	75 f2                	jne    800830 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80083e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084f:	eb 03                	jmp    800854 <strfind+0xf>
  800851:	83 c0 01             	add    $0x1,%eax
  800854:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800857:	38 ca                	cmp    %cl,%dl
  800859:	74 04                	je     80085f <strfind+0x1a>
  80085b:	84 d2                	test   %dl,%dl
  80085d:	75 f2                	jne    800851 <strfind+0xc>
			break;
	return (char *) s;
}
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	57                   	push   %edi
  800865:	56                   	push   %esi
  800866:	53                   	push   %ebx
  800867:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80086d:	85 c9                	test   %ecx,%ecx
  80086f:	74 36                	je     8008a7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800871:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800877:	75 28                	jne    8008a1 <memset+0x40>
  800879:	f6 c1 03             	test   $0x3,%cl
  80087c:	75 23                	jne    8008a1 <memset+0x40>
		c &= 0xFF;
  80087e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800882:	89 d3                	mov    %edx,%ebx
  800884:	c1 e3 08             	shl    $0x8,%ebx
  800887:	89 d6                	mov    %edx,%esi
  800889:	c1 e6 18             	shl    $0x18,%esi
  80088c:	89 d0                	mov    %edx,%eax
  80088e:	c1 e0 10             	shl    $0x10,%eax
  800891:	09 f0                	or     %esi,%eax
  800893:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800895:	89 d8                	mov    %ebx,%eax
  800897:	09 d0                	or     %edx,%eax
  800899:	c1 e9 02             	shr    $0x2,%ecx
  80089c:	fc                   	cld    
  80089d:	f3 ab                	rep stos %eax,%es:(%edi)
  80089f:	eb 06                	jmp    8008a7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a4:	fc                   	cld    
  8008a5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a7:	89 f8                	mov    %edi,%eax
  8008a9:	5b                   	pop    %ebx
  8008aa:	5e                   	pop    %esi
  8008ab:	5f                   	pop    %edi
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	57                   	push   %edi
  8008b2:	56                   	push   %esi
  8008b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008bc:	39 c6                	cmp    %eax,%esi
  8008be:	73 35                	jae    8008f5 <memmove+0x47>
  8008c0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c3:	39 d0                	cmp    %edx,%eax
  8008c5:	73 2e                	jae    8008f5 <memmove+0x47>
		s += n;
		d += n;
  8008c7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ca:	89 d6                	mov    %edx,%esi
  8008cc:	09 fe                	or     %edi,%esi
  8008ce:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d4:	75 13                	jne    8008e9 <memmove+0x3b>
  8008d6:	f6 c1 03             	test   $0x3,%cl
  8008d9:	75 0e                	jne    8008e9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008db:	83 ef 04             	sub    $0x4,%edi
  8008de:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e1:	c1 e9 02             	shr    $0x2,%ecx
  8008e4:	fd                   	std    
  8008e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e7:	eb 09                	jmp    8008f2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e9:	83 ef 01             	sub    $0x1,%edi
  8008ec:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008ef:	fd                   	std    
  8008f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f2:	fc                   	cld    
  8008f3:	eb 1d                	jmp    800912 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f5:	89 f2                	mov    %esi,%edx
  8008f7:	09 c2                	or     %eax,%edx
  8008f9:	f6 c2 03             	test   $0x3,%dl
  8008fc:	75 0f                	jne    80090d <memmove+0x5f>
  8008fe:	f6 c1 03             	test   $0x3,%cl
  800901:	75 0a                	jne    80090d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800903:	c1 e9 02             	shr    $0x2,%ecx
  800906:	89 c7                	mov    %eax,%edi
  800908:	fc                   	cld    
  800909:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090b:	eb 05                	jmp    800912 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80090d:	89 c7                	mov    %eax,%edi
  80090f:	fc                   	cld    
  800910:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800912:	5e                   	pop    %esi
  800913:	5f                   	pop    %edi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800919:	ff 75 10             	pushl  0x10(%ebp)
  80091c:	ff 75 0c             	pushl  0xc(%ebp)
  80091f:	ff 75 08             	pushl  0x8(%ebp)
  800922:	e8 87 ff ff ff       	call   8008ae <memmove>
}
  800927:	c9                   	leave  
  800928:	c3                   	ret    

00800929 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	56                   	push   %esi
  80092d:	53                   	push   %ebx
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 55 0c             	mov    0xc(%ebp),%edx
  800934:	89 c6                	mov    %eax,%esi
  800936:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800939:	eb 1a                	jmp    800955 <memcmp+0x2c>
		if (*s1 != *s2)
  80093b:	0f b6 08             	movzbl (%eax),%ecx
  80093e:	0f b6 1a             	movzbl (%edx),%ebx
  800941:	38 d9                	cmp    %bl,%cl
  800943:	74 0a                	je     80094f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800945:	0f b6 c1             	movzbl %cl,%eax
  800948:	0f b6 db             	movzbl %bl,%ebx
  80094b:	29 d8                	sub    %ebx,%eax
  80094d:	eb 0f                	jmp    80095e <memcmp+0x35>
		s1++, s2++;
  80094f:	83 c0 01             	add    $0x1,%eax
  800952:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800955:	39 f0                	cmp    %esi,%eax
  800957:	75 e2                	jne    80093b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800959:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095e:	5b                   	pop    %ebx
  80095f:	5e                   	pop    %esi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	53                   	push   %ebx
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800969:	89 c1                	mov    %eax,%ecx
  80096b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80096e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800972:	eb 0a                	jmp    80097e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800974:	0f b6 10             	movzbl (%eax),%edx
  800977:	39 da                	cmp    %ebx,%edx
  800979:	74 07                	je     800982 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80097b:	83 c0 01             	add    $0x1,%eax
  80097e:	39 c8                	cmp    %ecx,%eax
  800980:	72 f2                	jb     800974 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800982:	5b                   	pop    %ebx
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	57                   	push   %edi
  800989:	56                   	push   %esi
  80098a:	53                   	push   %ebx
  80098b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800991:	eb 03                	jmp    800996 <strtol+0x11>
		s++;
  800993:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800996:	0f b6 01             	movzbl (%ecx),%eax
  800999:	3c 20                	cmp    $0x20,%al
  80099b:	74 f6                	je     800993 <strtol+0xe>
  80099d:	3c 09                	cmp    $0x9,%al
  80099f:	74 f2                	je     800993 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a1:	3c 2b                	cmp    $0x2b,%al
  8009a3:	75 0a                	jne    8009af <strtol+0x2a>
		s++;
  8009a5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a8:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ad:	eb 11                	jmp    8009c0 <strtol+0x3b>
  8009af:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b4:	3c 2d                	cmp    $0x2d,%al
  8009b6:	75 08                	jne    8009c0 <strtol+0x3b>
		s++, neg = 1;
  8009b8:	83 c1 01             	add    $0x1,%ecx
  8009bb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c6:	75 15                	jne    8009dd <strtol+0x58>
  8009c8:	80 39 30             	cmpb   $0x30,(%ecx)
  8009cb:	75 10                	jne    8009dd <strtol+0x58>
  8009cd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009d1:	75 7c                	jne    800a4f <strtol+0xca>
		s += 2, base = 16;
  8009d3:	83 c1 02             	add    $0x2,%ecx
  8009d6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009db:	eb 16                	jmp    8009f3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009dd:	85 db                	test   %ebx,%ebx
  8009df:	75 12                	jne    8009f3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e9:	75 08                	jne    8009f3 <strtol+0x6e>
		s++, base = 8;
  8009eb:	83 c1 01             	add    $0x1,%ecx
  8009ee:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009fb:	0f b6 11             	movzbl (%ecx),%edx
  8009fe:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a01:	89 f3                	mov    %esi,%ebx
  800a03:	80 fb 09             	cmp    $0x9,%bl
  800a06:	77 08                	ja     800a10 <strtol+0x8b>
			dig = *s - '0';
  800a08:	0f be d2             	movsbl %dl,%edx
  800a0b:	83 ea 30             	sub    $0x30,%edx
  800a0e:	eb 22                	jmp    800a32 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a10:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a13:	89 f3                	mov    %esi,%ebx
  800a15:	80 fb 19             	cmp    $0x19,%bl
  800a18:	77 08                	ja     800a22 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a1a:	0f be d2             	movsbl %dl,%edx
  800a1d:	83 ea 57             	sub    $0x57,%edx
  800a20:	eb 10                	jmp    800a32 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a22:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a25:	89 f3                	mov    %esi,%ebx
  800a27:	80 fb 19             	cmp    $0x19,%bl
  800a2a:	77 16                	ja     800a42 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a2c:	0f be d2             	movsbl %dl,%edx
  800a2f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a32:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a35:	7d 0b                	jge    800a42 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a37:	83 c1 01             	add    $0x1,%ecx
  800a3a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a3e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a40:	eb b9                	jmp    8009fb <strtol+0x76>

	if (endptr)
  800a42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a46:	74 0d                	je     800a55 <strtol+0xd0>
		*endptr = (char *) s;
  800a48:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4b:	89 0e                	mov    %ecx,(%esi)
  800a4d:	eb 06                	jmp    800a55 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4f:	85 db                	test   %ebx,%ebx
  800a51:	74 98                	je     8009eb <strtol+0x66>
  800a53:	eb 9e                	jmp    8009f3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a55:	89 c2                	mov    %eax,%edx
  800a57:	f7 da                	neg    %edx
  800a59:	85 ff                	test   %edi,%edi
  800a5b:	0f 45 c2             	cmovne %edx,%eax
}
  800a5e:	5b                   	pop    %ebx
  800a5f:	5e                   	pop    %esi
  800a60:	5f                   	pop    %edi
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	57                   	push   %edi
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a71:	8b 55 08             	mov    0x8(%ebp),%edx
  800a74:	89 c3                	mov    %eax,%ebx
  800a76:	89 c7                	mov    %eax,%edi
  800a78:	89 c6                	mov    %eax,%esi
  800a7a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7c:	5b                   	pop    %ebx
  800a7d:	5e                   	pop    %esi
  800a7e:	5f                   	pop    %edi
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	57                   	push   %edi
  800a85:	56                   	push   %esi
  800a86:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a87:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8c:	b8 01 00 00 00       	mov    $0x1,%eax
  800a91:	89 d1                	mov    %edx,%ecx
  800a93:	89 d3                	mov    %edx,%ebx
  800a95:	89 d7                	mov    %edx,%edi
  800a97:	89 d6                	mov    %edx,%esi
  800a99:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aae:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab6:	89 cb                	mov    %ecx,%ebx
  800ab8:	89 cf                	mov    %ecx,%edi
  800aba:	89 ce                	mov    %ecx,%esi
  800abc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	7e 17                	jle    800ad9 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac2:	83 ec 0c             	sub    $0xc,%esp
  800ac5:	50                   	push   %eax
  800ac6:	6a 03                	push   $0x3
  800ac8:	68 48 12 80 00       	push   $0x801248
  800acd:	6a 23                	push   $0x23
  800acf:	68 65 12 80 00       	push   $0x801265
  800ad4:	e8 f5 01 00 00       	call   800cce <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae7:	ba 00 00 00 00       	mov    $0x0,%edx
  800aec:	b8 02 00 00 00       	mov    $0x2,%eax
  800af1:	89 d1                	mov    %edx,%ecx
  800af3:	89 d3                	mov    %edx,%ebx
  800af5:	89 d7                	mov    %edx,%edi
  800af7:	89 d6                	mov    %edx,%esi
  800af9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <sys_yield>:

void
sys_yield(void)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b06:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b10:	89 d1                	mov    %edx,%ecx
  800b12:	89 d3                	mov    %edx,%ebx
  800b14:	89 d7                	mov    %edx,%edi
  800b16:	89 d6                	mov    %edx,%esi
  800b18:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
  800b25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b28:	be 00 00 00 00       	mov    $0x0,%esi
  800b2d:	b8 04 00 00 00       	mov    $0x4,%eax
  800b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b35:	8b 55 08             	mov    0x8(%ebp),%edx
  800b38:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b3b:	89 f7                	mov    %esi,%edi
  800b3d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3f:	85 c0                	test   %eax,%eax
  800b41:	7e 17                	jle    800b5a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b43:	83 ec 0c             	sub    $0xc,%esp
  800b46:	50                   	push   %eax
  800b47:	6a 04                	push   $0x4
  800b49:	68 48 12 80 00       	push   $0x801248
  800b4e:	6a 23                	push   $0x23
  800b50:	68 65 12 80 00       	push   $0x801265
  800b55:	e8 74 01 00 00       	call   800cce <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6b:	b8 05 00 00 00       	mov    $0x5,%eax
  800b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
  800b76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b79:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b7c:	8b 75 18             	mov    0x18(%ebp),%esi
  800b7f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b81:	85 c0                	test   %eax,%eax
  800b83:	7e 17                	jle    800b9c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b85:	83 ec 0c             	sub    $0xc,%esp
  800b88:	50                   	push   %eax
  800b89:	6a 05                	push   $0x5
  800b8b:	68 48 12 80 00       	push   $0x801248
  800b90:	6a 23                	push   $0x23
  800b92:	68 65 12 80 00       	push   $0x801265
  800b97:	e8 32 01 00 00       	call   800cce <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5f                   	pop    %edi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
  800baa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb2:	b8 06 00 00 00       	mov    $0x6,%eax
  800bb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bba:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbd:	89 df                	mov    %ebx,%edi
  800bbf:	89 de                	mov    %ebx,%esi
  800bc1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc3:	85 c0                	test   %eax,%eax
  800bc5:	7e 17                	jle    800bde <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc7:	83 ec 0c             	sub    $0xc,%esp
  800bca:	50                   	push   %eax
  800bcb:	6a 06                	push   $0x6
  800bcd:	68 48 12 80 00       	push   $0x801248
  800bd2:	6a 23                	push   $0x23
  800bd4:	68 65 12 80 00       	push   $0x801265
  800bd9:	e8 f0 00 00 00       	call   800cce <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be1:	5b                   	pop    %ebx
  800be2:	5e                   	pop    %esi
  800be3:	5f                   	pop    %edi
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
  800bec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf4:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bff:	89 df                	mov    %ebx,%edi
  800c01:	89 de                	mov    %ebx,%esi
  800c03:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c05:	85 c0                	test   %eax,%eax
  800c07:	7e 17                	jle    800c20 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c09:	83 ec 0c             	sub    $0xc,%esp
  800c0c:	50                   	push   %eax
  800c0d:	6a 08                	push   $0x8
  800c0f:	68 48 12 80 00       	push   $0x801248
  800c14:	6a 23                	push   $0x23
  800c16:	68 65 12 80 00       	push   $0x801265
  800c1b:	e8 ae 00 00 00       	call   800cce <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	57                   	push   %edi
  800c2c:	56                   	push   %esi
  800c2d:	53                   	push   %ebx
  800c2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c36:	b8 09 00 00 00       	mov    $0x9,%eax
  800c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c41:	89 df                	mov    %ebx,%edi
  800c43:	89 de                	mov    %ebx,%esi
  800c45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c47:	85 c0                	test   %eax,%eax
  800c49:	7e 17                	jle    800c62 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4b:	83 ec 0c             	sub    $0xc,%esp
  800c4e:	50                   	push   %eax
  800c4f:	6a 09                	push   $0x9
  800c51:	68 48 12 80 00       	push   $0x801248
  800c56:	6a 23                	push   $0x23
  800c58:	68 65 12 80 00       	push   $0x801265
  800c5d:	e8 6c 00 00 00       	call   800cce <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c70:	be 00 00 00 00       	mov    $0x0,%esi
  800c75:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c83:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c86:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ca0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca3:	89 cb                	mov    %ecx,%ebx
  800ca5:	89 cf                	mov    %ecx,%edi
  800ca7:	89 ce                	mov    %ecx,%esi
  800ca9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cab:	85 c0                	test   %eax,%eax
  800cad:	7e 17                	jle    800cc6 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caf:	83 ec 0c             	sub    $0xc,%esp
  800cb2:	50                   	push   %eax
  800cb3:	6a 0c                	push   $0xc
  800cb5:	68 48 12 80 00       	push   $0x801248
  800cba:	6a 23                	push   $0x23
  800cbc:	68 65 12 80 00       	push   $0x801265
  800cc1:	e8 08 00 00 00       	call   800cce <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800cd3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800cd6:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800cdc:	e8 00 fe ff ff       	call   800ae1 <sys_getenvid>
  800ce1:	83 ec 0c             	sub    $0xc,%esp
  800ce4:	ff 75 0c             	pushl  0xc(%ebp)
  800ce7:	ff 75 08             	pushl  0x8(%ebp)
  800cea:	56                   	push   %esi
  800ceb:	50                   	push   %eax
  800cec:	68 74 12 80 00       	push   $0x801274
  800cf1:	e8 5f f4 ff ff       	call   800155 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800cf6:	83 c4 18             	add    $0x18,%esp
  800cf9:	53                   	push   %ebx
  800cfa:	ff 75 10             	pushl  0x10(%ebp)
  800cfd:	e8 02 f4 ff ff       	call   800104 <vcprintf>
	cprintf("\n");
  800d02:	c7 04 24 cc 0f 80 00 	movl   $0x800fcc,(%esp)
  800d09:	e8 47 f4 ff ff       	call   800155 <cprintf>
  800d0e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d11:	cc                   	int3   
  800d12:	eb fd                	jmp    800d11 <_panic+0x43>
  800d14:	66 90                	xchg   %ax,%ax
  800d16:	66 90                	xchg   %ax,%ax
  800d18:	66 90                	xchg   %ax,%ax
  800d1a:	66 90                	xchg   %ax,%ax
  800d1c:	66 90                	xchg   %ax,%ax
  800d1e:	66 90                	xchg   %ax,%ax

00800d20 <__udivdi3>:
  800d20:	55                   	push   %ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 1c             	sub    $0x1c,%esp
  800d27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d37:	85 f6                	test   %esi,%esi
  800d39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d3d:	89 ca                	mov    %ecx,%edx
  800d3f:	89 f8                	mov    %edi,%eax
  800d41:	75 3d                	jne    800d80 <__udivdi3+0x60>
  800d43:	39 cf                	cmp    %ecx,%edi
  800d45:	0f 87 c5 00 00 00    	ja     800e10 <__udivdi3+0xf0>
  800d4b:	85 ff                	test   %edi,%edi
  800d4d:	89 fd                	mov    %edi,%ebp
  800d4f:	75 0b                	jne    800d5c <__udivdi3+0x3c>
  800d51:	b8 01 00 00 00       	mov    $0x1,%eax
  800d56:	31 d2                	xor    %edx,%edx
  800d58:	f7 f7                	div    %edi
  800d5a:	89 c5                	mov    %eax,%ebp
  800d5c:	89 c8                	mov    %ecx,%eax
  800d5e:	31 d2                	xor    %edx,%edx
  800d60:	f7 f5                	div    %ebp
  800d62:	89 c1                	mov    %eax,%ecx
  800d64:	89 d8                	mov    %ebx,%eax
  800d66:	89 cf                	mov    %ecx,%edi
  800d68:	f7 f5                	div    %ebp
  800d6a:	89 c3                	mov    %eax,%ebx
  800d6c:	89 d8                	mov    %ebx,%eax
  800d6e:	89 fa                	mov    %edi,%edx
  800d70:	83 c4 1c             	add    $0x1c,%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    
  800d78:	90                   	nop
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	39 ce                	cmp    %ecx,%esi
  800d82:	77 74                	ja     800df8 <__udivdi3+0xd8>
  800d84:	0f bd fe             	bsr    %esi,%edi
  800d87:	83 f7 1f             	xor    $0x1f,%edi
  800d8a:	0f 84 98 00 00 00    	je     800e28 <__udivdi3+0x108>
  800d90:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d95:	89 f9                	mov    %edi,%ecx
  800d97:	89 c5                	mov    %eax,%ebp
  800d99:	29 fb                	sub    %edi,%ebx
  800d9b:	d3 e6                	shl    %cl,%esi
  800d9d:	89 d9                	mov    %ebx,%ecx
  800d9f:	d3 ed                	shr    %cl,%ebp
  800da1:	89 f9                	mov    %edi,%ecx
  800da3:	d3 e0                	shl    %cl,%eax
  800da5:	09 ee                	or     %ebp,%esi
  800da7:	89 d9                	mov    %ebx,%ecx
  800da9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dad:	89 d5                	mov    %edx,%ebp
  800daf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800db3:	d3 ed                	shr    %cl,%ebp
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	d3 e2                	shl    %cl,%edx
  800db9:	89 d9                	mov    %ebx,%ecx
  800dbb:	d3 e8                	shr    %cl,%eax
  800dbd:	09 c2                	or     %eax,%edx
  800dbf:	89 d0                	mov    %edx,%eax
  800dc1:	89 ea                	mov    %ebp,%edx
  800dc3:	f7 f6                	div    %esi
  800dc5:	89 d5                	mov    %edx,%ebp
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	f7 64 24 0c          	mull   0xc(%esp)
  800dcd:	39 d5                	cmp    %edx,%ebp
  800dcf:	72 10                	jb     800de1 <__udivdi3+0xc1>
  800dd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800dd5:	89 f9                	mov    %edi,%ecx
  800dd7:	d3 e6                	shl    %cl,%esi
  800dd9:	39 c6                	cmp    %eax,%esi
  800ddb:	73 07                	jae    800de4 <__udivdi3+0xc4>
  800ddd:	39 d5                	cmp    %edx,%ebp
  800ddf:	75 03                	jne    800de4 <__udivdi3+0xc4>
  800de1:	83 eb 01             	sub    $0x1,%ebx
  800de4:	31 ff                	xor    %edi,%edi
  800de6:	89 d8                	mov    %ebx,%eax
  800de8:	89 fa                	mov    %edi,%edx
  800dea:	83 c4 1c             	add    $0x1c,%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    
  800df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df8:	31 ff                	xor    %edi,%edi
  800dfa:	31 db                	xor    %ebx,%ebx
  800dfc:	89 d8                	mov    %ebx,%eax
  800dfe:	89 fa                	mov    %edi,%edx
  800e00:	83 c4 1c             	add    $0x1c,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
  800e08:	90                   	nop
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	89 d8                	mov    %ebx,%eax
  800e12:	f7 f7                	div    %edi
  800e14:	31 ff                	xor    %edi,%edi
  800e16:	89 c3                	mov    %eax,%ebx
  800e18:	89 d8                	mov    %ebx,%eax
  800e1a:	89 fa                	mov    %edi,%edx
  800e1c:	83 c4 1c             	add    $0x1c,%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	39 ce                	cmp    %ecx,%esi
  800e2a:	72 0c                	jb     800e38 <__udivdi3+0x118>
  800e2c:	31 db                	xor    %ebx,%ebx
  800e2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e32:	0f 87 34 ff ff ff    	ja     800d6c <__udivdi3+0x4c>
  800e38:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e3d:	e9 2a ff ff ff       	jmp    800d6c <__udivdi3+0x4c>
  800e42:	66 90                	xchg   %ax,%ax
  800e44:	66 90                	xchg   %ax,%ax
  800e46:	66 90                	xchg   %ax,%ax
  800e48:	66 90                	xchg   %ax,%ax
  800e4a:	66 90                	xchg   %ax,%ax
  800e4c:	66 90                	xchg   %ax,%ax
  800e4e:	66 90                	xchg   %ax,%ax

00800e50 <__umoddi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
  800e57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e67:	85 d2                	test   %edx,%edx
  800e69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e71:	89 f3                	mov    %esi,%ebx
  800e73:	89 3c 24             	mov    %edi,(%esp)
  800e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e7a:	75 1c                	jne    800e98 <__umoddi3+0x48>
  800e7c:	39 f7                	cmp    %esi,%edi
  800e7e:	76 50                	jbe    800ed0 <__umoddi3+0x80>
  800e80:	89 c8                	mov    %ecx,%eax
  800e82:	89 f2                	mov    %esi,%edx
  800e84:	f7 f7                	div    %edi
  800e86:	89 d0                	mov    %edx,%eax
  800e88:	31 d2                	xor    %edx,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	39 f2                	cmp    %esi,%edx
  800e9a:	89 d0                	mov    %edx,%eax
  800e9c:	77 52                	ja     800ef0 <__umoddi3+0xa0>
  800e9e:	0f bd ea             	bsr    %edx,%ebp
  800ea1:	83 f5 1f             	xor    $0x1f,%ebp
  800ea4:	75 5a                	jne    800f00 <__umoddi3+0xb0>
  800ea6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eaa:	0f 82 e0 00 00 00    	jb     800f90 <__umoddi3+0x140>
  800eb0:	39 0c 24             	cmp    %ecx,(%esp)
  800eb3:	0f 86 d7 00 00 00    	jbe    800f90 <__umoddi3+0x140>
  800eb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ebd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ec1:	83 c4 1c             	add    $0x1c,%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	85 ff                	test   %edi,%edi
  800ed2:	89 fd                	mov    %edi,%ebp
  800ed4:	75 0b                	jne    800ee1 <__umoddi3+0x91>
  800ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	f7 f7                	div    %edi
  800edf:	89 c5                	mov    %eax,%ebp
  800ee1:	89 f0                	mov    %esi,%eax
  800ee3:	31 d2                	xor    %edx,%edx
  800ee5:	f7 f5                	div    %ebp
  800ee7:	89 c8                	mov    %ecx,%eax
  800ee9:	f7 f5                	div    %ebp
  800eeb:	89 d0                	mov    %edx,%eax
  800eed:	eb 99                	jmp    800e88 <__umoddi3+0x38>
  800eef:	90                   	nop
  800ef0:	89 c8                	mov    %ecx,%eax
  800ef2:	89 f2                	mov    %esi,%edx
  800ef4:	83 c4 1c             	add    $0x1c,%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    
  800efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f00:	8b 34 24             	mov    (%esp),%esi
  800f03:	bf 20 00 00 00       	mov    $0x20,%edi
  800f08:	89 e9                	mov    %ebp,%ecx
  800f0a:	29 ef                	sub    %ebp,%edi
  800f0c:	d3 e0                	shl    %cl,%eax
  800f0e:	89 f9                	mov    %edi,%ecx
  800f10:	89 f2                	mov    %esi,%edx
  800f12:	d3 ea                	shr    %cl,%edx
  800f14:	89 e9                	mov    %ebp,%ecx
  800f16:	09 c2                	or     %eax,%edx
  800f18:	89 d8                	mov    %ebx,%eax
  800f1a:	89 14 24             	mov    %edx,(%esp)
  800f1d:	89 f2                	mov    %esi,%edx
  800f1f:	d3 e2                	shl    %cl,%edx
  800f21:	89 f9                	mov    %edi,%ecx
  800f23:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f2b:	d3 e8                	shr    %cl,%eax
  800f2d:	89 e9                	mov    %ebp,%ecx
  800f2f:	89 c6                	mov    %eax,%esi
  800f31:	d3 e3                	shl    %cl,%ebx
  800f33:	89 f9                	mov    %edi,%ecx
  800f35:	89 d0                	mov    %edx,%eax
  800f37:	d3 e8                	shr    %cl,%eax
  800f39:	89 e9                	mov    %ebp,%ecx
  800f3b:	09 d8                	or     %ebx,%eax
  800f3d:	89 d3                	mov    %edx,%ebx
  800f3f:	89 f2                	mov    %esi,%edx
  800f41:	f7 34 24             	divl   (%esp)
  800f44:	89 d6                	mov    %edx,%esi
  800f46:	d3 e3                	shl    %cl,%ebx
  800f48:	f7 64 24 04          	mull   0x4(%esp)
  800f4c:	39 d6                	cmp    %edx,%esi
  800f4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f52:	89 d1                	mov    %edx,%ecx
  800f54:	89 c3                	mov    %eax,%ebx
  800f56:	72 08                	jb     800f60 <__umoddi3+0x110>
  800f58:	75 11                	jne    800f6b <__umoddi3+0x11b>
  800f5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f5e:	73 0b                	jae    800f6b <__umoddi3+0x11b>
  800f60:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f64:	1b 14 24             	sbb    (%esp),%edx
  800f67:	89 d1                	mov    %edx,%ecx
  800f69:	89 c3                	mov    %eax,%ebx
  800f6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f6f:	29 da                	sub    %ebx,%edx
  800f71:	19 ce                	sbb    %ecx,%esi
  800f73:	89 f9                	mov    %edi,%ecx
  800f75:	89 f0                	mov    %esi,%eax
  800f77:	d3 e0                	shl    %cl,%eax
  800f79:	89 e9                	mov    %ebp,%ecx
  800f7b:	d3 ea                	shr    %cl,%edx
  800f7d:	89 e9                	mov    %ebp,%ecx
  800f7f:	d3 ee                	shr    %cl,%esi
  800f81:	09 d0                	or     %edx,%eax
  800f83:	89 f2                	mov    %esi,%edx
  800f85:	83 c4 1c             	add    $0x1c,%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi
  800f90:	29 f9                	sub    %edi,%ecx
  800f92:	19 d6                	sbb    %edx,%esi
  800f94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f9c:	e9 18 ff ff ff       	jmp    800eb9 <__umoddi3+0x69>
