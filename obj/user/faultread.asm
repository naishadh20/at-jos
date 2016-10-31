
obj/user/faultread:     file format elf32-i386


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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	ff 35 00 00 00 00    	pushl  0x0
  80003f:	68 a0 0f 80 00       	push   $0x800fa0
  800044:	e8 fa 00 00 00       	call   800143 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800059:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800060:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  800063:	e8 67 0a 00 00       	call   800acf <sys_getenvid>
  800068:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800070:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800075:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 db                	test   %ebx,%ebx
  80007c:	7e 07                	jle    800085 <libmain+0x37>
		binaryname = argv[0];
  80007e:	8b 06                	mov    (%esi),%eax
  800080:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800085:	83 ec 08             	sub    $0x8,%esp
  800088:	56                   	push   %esi
  800089:	53                   	push   %ebx
  80008a:	e8 a4 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008f:	e8 0a 00 00 00       	call   80009e <exit>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009a:	5b                   	pop    %ebx
  80009b:	5e                   	pop    %esi
  80009c:	5d                   	pop    %ebp
  80009d:	c3                   	ret    

0080009e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a4:	6a 00                	push   $0x0
  8000a6:	e8 e3 09 00 00       	call   800a8e <sys_env_destroy>
}
  8000ab:	83 c4 10             	add    $0x10,%esp
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	53                   	push   %ebx
  8000b4:	83 ec 04             	sub    $0x4,%esp
  8000b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ba:	8b 13                	mov    (%ebx),%edx
  8000bc:	8d 42 01             	lea    0x1(%edx),%eax
  8000bf:	89 03                	mov    %eax,(%ebx)
  8000c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cd:	75 1a                	jne    8000e9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000cf:	83 ec 08             	sub    $0x8,%esp
  8000d2:	68 ff 00 00 00       	push   $0xff
  8000d7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000da:	50                   	push   %eax
  8000db:	e8 71 09 00 00       	call   800a51 <sys_cputs>
		b->idx = 0;
  8000e0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    

008000f2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000fb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800102:	00 00 00 
	b.cnt = 0;
  800105:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010f:	ff 75 0c             	pushl  0xc(%ebp)
  800112:	ff 75 08             	pushl  0x8(%ebp)
  800115:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80011b:	50                   	push   %eax
  80011c:	68 b0 00 80 00       	push   $0x8000b0
  800121:	e8 54 01 00 00       	call   80027a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800126:	83 c4 08             	add    $0x8,%esp
  800129:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80012f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800135:	50                   	push   %eax
  800136:	e8 16 09 00 00       	call   800a51 <sys_cputs>

	return b.cnt;
}
  80013b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800149:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014c:	50                   	push   %eax
  80014d:	ff 75 08             	pushl  0x8(%ebp)
  800150:	e8 9d ff ff ff       	call   8000f2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	57                   	push   %edi
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
  80015d:	83 ec 1c             	sub    $0x1c,%esp
  800160:	89 c7                	mov    %eax,%edi
  800162:	89 d6                	mov    %edx,%esi
  800164:	8b 45 08             	mov    0x8(%ebp),%eax
  800167:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80016d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800170:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800173:	bb 00 00 00 00       	mov    $0x0,%ebx
  800178:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80017b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80017e:	39 d3                	cmp    %edx,%ebx
  800180:	72 05                	jb     800187 <printnum+0x30>
  800182:	39 45 10             	cmp    %eax,0x10(%ebp)
  800185:	77 45                	ja     8001cc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	ff 75 18             	pushl  0x18(%ebp)
  80018d:	8b 45 14             	mov    0x14(%ebp),%eax
  800190:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800193:	53                   	push   %ebx
  800194:	ff 75 10             	pushl  0x10(%ebp)
  800197:	83 ec 08             	sub    $0x8,%esp
  80019a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80019d:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a6:	e8 65 0b 00 00       	call   800d10 <__udivdi3>
  8001ab:	83 c4 18             	add    $0x18,%esp
  8001ae:	52                   	push   %edx
  8001af:	50                   	push   %eax
  8001b0:	89 f2                	mov    %esi,%edx
  8001b2:	89 f8                	mov    %edi,%eax
  8001b4:	e8 9e ff ff ff       	call   800157 <printnum>
  8001b9:	83 c4 20             	add    $0x20,%esp
  8001bc:	eb 18                	jmp    8001d6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001be:	83 ec 08             	sub    $0x8,%esp
  8001c1:	56                   	push   %esi
  8001c2:	ff 75 18             	pushl  0x18(%ebp)
  8001c5:	ff d7                	call   *%edi
  8001c7:	83 c4 10             	add    $0x10,%esp
  8001ca:	eb 03                	jmp    8001cf <printnum+0x78>
  8001cc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001cf:	83 eb 01             	sub    $0x1,%ebx
  8001d2:	85 db                	test   %ebx,%ebx
  8001d4:	7f e8                	jg     8001be <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d6:	83 ec 08             	sub    $0x8,%esp
  8001d9:	56                   	push   %esi
  8001da:	83 ec 04             	sub    $0x4,%esp
  8001dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e3:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e6:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e9:	e8 52 0c 00 00       	call   800e40 <__umoddi3>
  8001ee:	83 c4 14             	add    $0x14,%esp
  8001f1:	0f be 80 c8 0f 80 00 	movsbl 0x800fc8(%eax),%eax
  8001f8:	50                   	push   %eax
  8001f9:	ff d7                	call   *%edi
}
  8001fb:	83 c4 10             	add    $0x10,%esp
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800209:	83 fa 01             	cmp    $0x1,%edx
  80020c:	7e 0e                	jle    80021c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80020e:	8b 10                	mov    (%eax),%edx
  800210:	8d 4a 08             	lea    0x8(%edx),%ecx
  800213:	89 08                	mov    %ecx,(%eax)
  800215:	8b 02                	mov    (%edx),%eax
  800217:	8b 52 04             	mov    0x4(%edx),%edx
  80021a:	eb 22                	jmp    80023e <getuint+0x38>
	else if (lflag)
  80021c:	85 d2                	test   %edx,%edx
  80021e:	74 10                	je     800230 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800220:	8b 10                	mov    (%eax),%edx
  800222:	8d 4a 04             	lea    0x4(%edx),%ecx
  800225:	89 08                	mov    %ecx,(%eax)
  800227:	8b 02                	mov    (%edx),%eax
  800229:	ba 00 00 00 00       	mov    $0x0,%edx
  80022e:	eb 0e                	jmp    80023e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800230:	8b 10                	mov    (%eax),%edx
  800232:	8d 4a 04             	lea    0x4(%edx),%ecx
  800235:	89 08                	mov    %ecx,(%eax)
  800237:	8b 02                	mov    (%edx),%eax
  800239:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800246:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80024a:	8b 10                	mov    (%eax),%edx
  80024c:	3b 50 04             	cmp    0x4(%eax),%edx
  80024f:	73 0a                	jae    80025b <sprintputch+0x1b>
		*b->buf++ = ch;
  800251:	8d 4a 01             	lea    0x1(%edx),%ecx
  800254:	89 08                	mov    %ecx,(%eax)
  800256:	8b 45 08             	mov    0x8(%ebp),%eax
  800259:	88 02                	mov    %al,(%edx)
}
  80025b:	5d                   	pop    %ebp
  80025c:	c3                   	ret    

0080025d <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800263:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800266:	50                   	push   %eax
  800267:	ff 75 10             	pushl  0x10(%ebp)
  80026a:	ff 75 0c             	pushl  0xc(%ebp)
  80026d:	ff 75 08             	pushl  0x8(%ebp)
  800270:	e8 05 00 00 00       	call   80027a <vprintfmt>
	va_end(ap);
}
  800275:	83 c4 10             	add    $0x10,%esp
  800278:	c9                   	leave  
  800279:	c3                   	ret    

0080027a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	57                   	push   %edi
  80027e:	56                   	push   %esi
  80027f:	53                   	push   %ebx
  800280:	83 ec 2c             	sub    $0x2c,%esp
  800283:	8b 75 08             	mov    0x8(%ebp),%esi
  800286:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800289:	8b 7d 10             	mov    0x10(%ebp),%edi
  80028c:	eb 12                	jmp    8002a0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80028e:	85 c0                	test   %eax,%eax
  800290:	0f 84 cb 03 00 00    	je     800661 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	53                   	push   %ebx
  80029a:	50                   	push   %eax
  80029b:	ff d6                	call   *%esi
  80029d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a0:	83 c7 01             	add    $0x1,%edi
  8002a3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002a7:	83 f8 25             	cmp    $0x25,%eax
  8002aa:	75 e2                	jne    80028e <vprintfmt+0x14>
  8002ac:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002b0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002b7:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002be:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ca:	eb 07                	jmp    8002d3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002cf:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d3:	8d 47 01             	lea    0x1(%edi),%eax
  8002d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d9:	0f b6 07             	movzbl (%edi),%eax
  8002dc:	0f b6 c8             	movzbl %al,%ecx
  8002df:	83 e8 23             	sub    $0x23,%eax
  8002e2:	3c 55                	cmp    $0x55,%al
  8002e4:	0f 87 5c 03 00 00    	ja     800646 <vprintfmt+0x3cc>
  8002ea:	0f b6 c0             	movzbl %al,%eax
  8002ed:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  8002f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002f7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002fb:	eb d6                	jmp    8002d3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800300:	b8 00 00 00 00       	mov    $0x0,%eax
  800305:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800308:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80030b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80030f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800312:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800315:	83 fa 09             	cmp    $0x9,%edx
  800318:	77 39                	ja     800353 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80031a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80031d:	eb e9                	jmp    800308 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80031f:	8b 45 14             	mov    0x14(%ebp),%eax
  800322:	8d 48 04             	lea    0x4(%eax),%ecx
  800325:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800328:	8b 00                	mov    (%eax),%eax
  80032a:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800330:	eb 27                	jmp    800359 <vprintfmt+0xdf>
  800332:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800335:	85 c0                	test   %eax,%eax
  800337:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033c:	0f 49 c8             	cmovns %eax,%ecx
  80033f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800345:	eb 8c                	jmp    8002d3 <vprintfmt+0x59>
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80034a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800351:	eb 80                	jmp    8002d3 <vprintfmt+0x59>
  800353:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800356:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800359:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80035d:	0f 89 70 ff ff ff    	jns    8002d3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800363:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800366:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800369:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800370:	e9 5e ff ff ff       	jmp    8002d3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800375:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80037b:	e9 53 ff ff ff       	jmp    8002d3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800380:	8b 45 14             	mov    0x14(%ebp),%eax
  800383:	8d 50 04             	lea    0x4(%eax),%edx
  800386:	89 55 14             	mov    %edx,0x14(%ebp)
  800389:	83 ec 08             	sub    $0x8,%esp
  80038c:	53                   	push   %ebx
  80038d:	ff 30                	pushl  (%eax)
  80038f:	ff d6                	call   *%esi
			break;
  800391:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800397:	e9 04 ff ff ff       	jmp    8002a0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80039c:	8b 45 14             	mov    0x14(%ebp),%eax
  80039f:	8d 50 04             	lea    0x4(%eax),%edx
  8003a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a5:	8b 00                	mov    (%eax),%eax
  8003a7:	99                   	cltd   
  8003a8:	31 d0                	xor    %edx,%eax
  8003aa:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ac:	83 f8 09             	cmp    $0x9,%eax
  8003af:	7f 0b                	jg     8003bc <vprintfmt+0x142>
  8003b1:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  8003b8:	85 d2                	test   %edx,%edx
  8003ba:	75 18                	jne    8003d4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003bc:	50                   	push   %eax
  8003bd:	68 e0 0f 80 00       	push   $0x800fe0
  8003c2:	53                   	push   %ebx
  8003c3:	56                   	push   %esi
  8003c4:	e8 94 fe ff ff       	call   80025d <printfmt>
  8003c9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003cf:	e9 cc fe ff ff       	jmp    8002a0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003d4:	52                   	push   %edx
  8003d5:	68 e9 0f 80 00       	push   $0x800fe9
  8003da:	53                   	push   %ebx
  8003db:	56                   	push   %esi
  8003dc:	e8 7c fe ff ff       	call   80025d <printfmt>
  8003e1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e7:	e9 b4 fe ff ff       	jmp    8002a0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ef:	8d 50 04             	lea    0x4(%eax),%edx
  8003f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003f7:	85 ff                	test   %edi,%edi
  8003f9:	b8 d9 0f 80 00       	mov    $0x800fd9,%eax
  8003fe:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800401:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800405:	0f 8e 94 00 00 00    	jle    80049f <vprintfmt+0x225>
  80040b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80040f:	0f 84 98 00 00 00    	je     8004ad <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	ff 75 c8             	pushl  -0x38(%ebp)
  80041b:	57                   	push   %edi
  80041c:	e8 c8 02 00 00       	call   8006e9 <strnlen>
  800421:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800424:	29 c1                	sub    %eax,%ecx
  800426:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800429:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800430:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800433:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800436:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800438:	eb 0f                	jmp    800449 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	53                   	push   %ebx
  80043e:	ff 75 e0             	pushl  -0x20(%ebp)
  800441:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800443:	83 ef 01             	sub    $0x1,%edi
  800446:	83 c4 10             	add    $0x10,%esp
  800449:	85 ff                	test   %edi,%edi
  80044b:	7f ed                	jg     80043a <vprintfmt+0x1c0>
  80044d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800450:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800453:	85 c9                	test   %ecx,%ecx
  800455:	b8 00 00 00 00       	mov    $0x0,%eax
  80045a:	0f 49 c1             	cmovns %ecx,%eax
  80045d:	29 c1                	sub    %eax,%ecx
  80045f:	89 75 08             	mov    %esi,0x8(%ebp)
  800462:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800465:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800468:	89 cb                	mov    %ecx,%ebx
  80046a:	eb 4d                	jmp    8004b9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80046c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800470:	74 1b                	je     80048d <vprintfmt+0x213>
  800472:	0f be c0             	movsbl %al,%eax
  800475:	83 e8 20             	sub    $0x20,%eax
  800478:	83 f8 5e             	cmp    $0x5e,%eax
  80047b:	76 10                	jbe    80048d <vprintfmt+0x213>
					putch('?', putdat);
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	ff 75 0c             	pushl  0xc(%ebp)
  800483:	6a 3f                	push   $0x3f
  800485:	ff 55 08             	call   *0x8(%ebp)
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	eb 0d                	jmp    80049a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	ff 75 0c             	pushl  0xc(%ebp)
  800493:	52                   	push   %edx
  800494:	ff 55 08             	call   *0x8(%ebp)
  800497:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049a:	83 eb 01             	sub    $0x1,%ebx
  80049d:	eb 1a                	jmp    8004b9 <vprintfmt+0x23f>
  80049f:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a2:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ab:	eb 0c                	jmp    8004b9 <vprintfmt+0x23f>
  8004ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b0:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b9:	83 c7 01             	add    $0x1,%edi
  8004bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c0:	0f be d0             	movsbl %al,%edx
  8004c3:	85 d2                	test   %edx,%edx
  8004c5:	74 23                	je     8004ea <vprintfmt+0x270>
  8004c7:	85 f6                	test   %esi,%esi
  8004c9:	78 a1                	js     80046c <vprintfmt+0x1f2>
  8004cb:	83 ee 01             	sub    $0x1,%esi
  8004ce:	79 9c                	jns    80046c <vprintfmt+0x1f2>
  8004d0:	89 df                	mov    %ebx,%edi
  8004d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d8:	eb 18                	jmp    8004f2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	53                   	push   %ebx
  8004de:	6a 20                	push   $0x20
  8004e0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e2:	83 ef 01             	sub    $0x1,%edi
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	eb 08                	jmp    8004f2 <vprintfmt+0x278>
  8004ea:	89 df                	mov    %ebx,%edi
  8004ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f2:	85 ff                	test   %edi,%edi
  8004f4:	7f e4                	jg     8004da <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f9:	e9 a2 fd ff ff       	jmp    8002a0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004fe:	83 fa 01             	cmp    $0x1,%edx
  800501:	7e 16                	jle    800519 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8d 50 08             	lea    0x8(%eax),%edx
  800509:	89 55 14             	mov    %edx,0x14(%ebp)
  80050c:	8b 50 04             	mov    0x4(%eax),%edx
  80050f:	8b 00                	mov    (%eax),%eax
  800511:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800514:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800517:	eb 32                	jmp    80054b <vprintfmt+0x2d1>
	else if (lflag)
  800519:	85 d2                	test   %edx,%edx
  80051b:	74 18                	je     800535 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80051d:	8b 45 14             	mov    0x14(%ebp),%eax
  800520:	8d 50 04             	lea    0x4(%eax),%edx
  800523:	89 55 14             	mov    %edx,0x14(%ebp)
  800526:	8b 00                	mov    (%eax),%eax
  800528:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80052b:	89 c1                	mov    %eax,%ecx
  80052d:	c1 f9 1f             	sar    $0x1f,%ecx
  800530:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800533:	eb 16                	jmp    80054b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 04             	lea    0x4(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	8b 00                	mov    (%eax),%eax
  800540:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800543:	89 c1                	mov    %eax,%ecx
  800545:	c1 f9 1f             	sar    $0x1f,%ecx
  800548:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80054b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80054e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800551:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800554:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800557:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800560:	0f 89 a8 00 00 00    	jns    80060e <vprintfmt+0x394>
				putch('-', putdat);
  800566:	83 ec 08             	sub    $0x8,%esp
  800569:	53                   	push   %ebx
  80056a:	6a 2d                	push   $0x2d
  80056c:	ff d6                	call   *%esi
				num = -(long long) num;
  80056e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800571:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800574:	f7 d8                	neg    %eax
  800576:	83 d2 00             	adc    $0x0,%edx
  800579:	f7 da                	neg    %edx
  80057b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800581:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800584:	b8 0a 00 00 00       	mov    $0xa,%eax
  800589:	e9 80 00 00 00       	jmp    80060e <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058e:	8d 45 14             	lea    0x14(%ebp),%eax
  800591:	e8 70 fc ff ff       	call   800206 <getuint>
  800596:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800599:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80059c:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005a1:	eb 6b                	jmp    80060e <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a6:	e8 5b fc ff ff       	call   800206 <getuint>
  8005ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  8005b1:	6a 04                	push   $0x4
  8005b3:	6a 03                	push   $0x3
  8005b5:	6a 01                	push   $0x1
  8005b7:	68 ec 0f 80 00       	push   $0x800fec
  8005bc:	e8 82 fb ff ff       	call   800143 <cprintf>
			goto number;
  8005c1:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  8005c4:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  8005c9:	eb 43                	jmp    80060e <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	53                   	push   %ebx
  8005cf:	6a 30                	push   $0x30
  8005d1:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d3:	83 c4 08             	add    $0x8,%esp
  8005d6:	53                   	push   %ebx
  8005d7:	6a 78                	push   $0x78
  8005d9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8d 50 04             	lea    0x4(%eax),%edx
  8005e1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e4:	8b 00                	mov    (%eax),%eax
  8005e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8005eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005f1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005f4:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005f9:	eb 13                	jmp    80060e <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fe:	e8 03 fc ff ff       	call   800206 <getuint>
  800603:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800606:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800609:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80060e:	83 ec 0c             	sub    $0xc,%esp
  800611:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800615:	52                   	push   %edx
  800616:	ff 75 e0             	pushl  -0x20(%ebp)
  800619:	50                   	push   %eax
  80061a:	ff 75 dc             	pushl  -0x24(%ebp)
  80061d:	ff 75 d8             	pushl  -0x28(%ebp)
  800620:	89 da                	mov    %ebx,%edx
  800622:	89 f0                	mov    %esi,%eax
  800624:	e8 2e fb ff ff       	call   800157 <printnum>

			break;
  800629:	83 c4 20             	add    $0x20,%esp
  80062c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80062f:	e9 6c fc ff ff       	jmp    8002a0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	51                   	push   %ecx
  800639:	ff d6                	call   *%esi
			break;
  80063b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800641:	e9 5a fc ff ff       	jmp    8002a0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	6a 25                	push   $0x25
  80064c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80064e:	83 c4 10             	add    $0x10,%esp
  800651:	eb 03                	jmp    800656 <vprintfmt+0x3dc>
  800653:	83 ef 01             	sub    $0x1,%edi
  800656:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80065a:	75 f7                	jne    800653 <vprintfmt+0x3d9>
  80065c:	e9 3f fc ff ff       	jmp    8002a0 <vprintfmt+0x26>
			break;
		}

	}

}
  800661:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800664:	5b                   	pop    %ebx
  800665:	5e                   	pop    %esi
  800666:	5f                   	pop    %edi
  800667:	5d                   	pop    %ebp
  800668:	c3                   	ret    

00800669 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800669:	55                   	push   %ebp
  80066a:	89 e5                	mov    %esp,%ebp
  80066c:	83 ec 18             	sub    $0x18,%esp
  80066f:	8b 45 08             	mov    0x8(%ebp),%eax
  800672:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800675:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800678:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80067c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80067f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800686:	85 c0                	test   %eax,%eax
  800688:	74 26                	je     8006b0 <vsnprintf+0x47>
  80068a:	85 d2                	test   %edx,%edx
  80068c:	7e 22                	jle    8006b0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80068e:	ff 75 14             	pushl  0x14(%ebp)
  800691:	ff 75 10             	pushl  0x10(%ebp)
  800694:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800697:	50                   	push   %eax
  800698:	68 40 02 80 00       	push   $0x800240
  80069d:	e8 d8 fb ff ff       	call   80027a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ab:	83 c4 10             	add    $0x10,%esp
  8006ae:	eb 05                	jmp    8006b5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006b5:	c9                   	leave  
  8006b6:	c3                   	ret    

008006b7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006bd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c0:	50                   	push   %eax
  8006c1:	ff 75 10             	pushl  0x10(%ebp)
  8006c4:	ff 75 0c             	pushl  0xc(%ebp)
  8006c7:	ff 75 08             	pushl  0x8(%ebp)
  8006ca:	e8 9a ff ff ff       	call   800669 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006cf:	c9                   	leave  
  8006d0:	c3                   	ret    

008006d1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d1:	55                   	push   %ebp
  8006d2:	89 e5                	mov    %esp,%ebp
  8006d4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006dc:	eb 03                	jmp    8006e1 <strlen+0x10>
		n++;
  8006de:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006e5:	75 f7                	jne    8006de <strlen+0xd>
		n++;
	return n;
}
  8006e7:	5d                   	pop    %ebp
  8006e8:	c3                   	ret    

008006e9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f7:	eb 03                	jmp    8006fc <strnlen+0x13>
		n++;
  8006f9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fc:	39 c2                	cmp    %eax,%edx
  8006fe:	74 08                	je     800708 <strnlen+0x1f>
  800700:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800704:	75 f3                	jne    8006f9 <strnlen+0x10>
  800706:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	53                   	push   %ebx
  80070e:	8b 45 08             	mov    0x8(%ebp),%eax
  800711:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800714:	89 c2                	mov    %eax,%edx
  800716:	83 c2 01             	add    $0x1,%edx
  800719:	83 c1 01             	add    $0x1,%ecx
  80071c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800720:	88 5a ff             	mov    %bl,-0x1(%edx)
  800723:	84 db                	test   %bl,%bl
  800725:	75 ef                	jne    800716 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800727:	5b                   	pop    %ebx
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	53                   	push   %ebx
  80072e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800731:	53                   	push   %ebx
  800732:	e8 9a ff ff ff       	call   8006d1 <strlen>
  800737:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	01 d8                	add    %ebx,%eax
  80073f:	50                   	push   %eax
  800740:	e8 c5 ff ff ff       	call   80070a <strcpy>
	return dst;
}
  800745:	89 d8                	mov    %ebx,%eax
  800747:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	56                   	push   %esi
  800750:	53                   	push   %ebx
  800751:	8b 75 08             	mov    0x8(%ebp),%esi
  800754:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800757:	89 f3                	mov    %esi,%ebx
  800759:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075c:	89 f2                	mov    %esi,%edx
  80075e:	eb 0f                	jmp    80076f <strncpy+0x23>
		*dst++ = *src;
  800760:	83 c2 01             	add    $0x1,%edx
  800763:	0f b6 01             	movzbl (%ecx),%eax
  800766:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800769:	80 39 01             	cmpb   $0x1,(%ecx)
  80076c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076f:	39 da                	cmp    %ebx,%edx
  800771:	75 ed                	jne    800760 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800773:	89 f0                	mov    %esi,%eax
  800775:	5b                   	pop    %ebx
  800776:	5e                   	pop    %esi
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	56                   	push   %esi
  80077d:	53                   	push   %ebx
  80077e:	8b 75 08             	mov    0x8(%ebp),%esi
  800781:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800784:	8b 55 10             	mov    0x10(%ebp),%edx
  800787:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800789:	85 d2                	test   %edx,%edx
  80078b:	74 21                	je     8007ae <strlcpy+0x35>
  80078d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800791:	89 f2                	mov    %esi,%edx
  800793:	eb 09                	jmp    80079e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800795:	83 c2 01             	add    $0x1,%edx
  800798:	83 c1 01             	add    $0x1,%ecx
  80079b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80079e:	39 c2                	cmp    %eax,%edx
  8007a0:	74 09                	je     8007ab <strlcpy+0x32>
  8007a2:	0f b6 19             	movzbl (%ecx),%ebx
  8007a5:	84 db                	test   %bl,%bl
  8007a7:	75 ec                	jne    800795 <strlcpy+0x1c>
  8007a9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007ab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ae:	29 f0                	sub    %esi,%eax
}
  8007b0:	5b                   	pop    %ebx
  8007b1:	5e                   	pop    %esi
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007bd:	eb 06                	jmp    8007c5 <strcmp+0x11>
		p++, q++;
  8007bf:	83 c1 01             	add    $0x1,%ecx
  8007c2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c5:	0f b6 01             	movzbl (%ecx),%eax
  8007c8:	84 c0                	test   %al,%al
  8007ca:	74 04                	je     8007d0 <strcmp+0x1c>
  8007cc:	3a 02                	cmp    (%edx),%al
  8007ce:	74 ef                	je     8007bf <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d0:	0f b6 c0             	movzbl %al,%eax
  8007d3:	0f b6 12             	movzbl (%edx),%edx
  8007d6:	29 d0                	sub    %edx,%eax
}
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	53                   	push   %ebx
  8007de:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e4:	89 c3                	mov    %eax,%ebx
  8007e6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007e9:	eb 06                	jmp    8007f1 <strncmp+0x17>
		n--, p++, q++;
  8007eb:	83 c0 01             	add    $0x1,%eax
  8007ee:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f1:	39 d8                	cmp    %ebx,%eax
  8007f3:	74 15                	je     80080a <strncmp+0x30>
  8007f5:	0f b6 08             	movzbl (%eax),%ecx
  8007f8:	84 c9                	test   %cl,%cl
  8007fa:	74 04                	je     800800 <strncmp+0x26>
  8007fc:	3a 0a                	cmp    (%edx),%cl
  8007fe:	74 eb                	je     8007eb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800800:	0f b6 00             	movzbl (%eax),%eax
  800803:	0f b6 12             	movzbl (%edx),%edx
  800806:	29 d0                	sub    %edx,%eax
  800808:	eb 05                	jmp    80080f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80080a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80080f:	5b                   	pop    %ebx
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80081c:	eb 07                	jmp    800825 <strchr+0x13>
		if (*s == c)
  80081e:	38 ca                	cmp    %cl,%dl
  800820:	74 0f                	je     800831 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800822:	83 c0 01             	add    $0x1,%eax
  800825:	0f b6 10             	movzbl (%eax),%edx
  800828:	84 d2                	test   %dl,%dl
  80082a:	75 f2                	jne    80081e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80082c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	8b 45 08             	mov    0x8(%ebp),%eax
  800839:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80083d:	eb 03                	jmp    800842 <strfind+0xf>
  80083f:	83 c0 01             	add    $0x1,%eax
  800842:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800845:	38 ca                	cmp    %cl,%dl
  800847:	74 04                	je     80084d <strfind+0x1a>
  800849:	84 d2                	test   %dl,%dl
  80084b:	75 f2                	jne    80083f <strfind+0xc>
			break;
	return (char *) s;
}
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	57                   	push   %edi
  800853:	56                   	push   %esi
  800854:	53                   	push   %ebx
  800855:	8b 7d 08             	mov    0x8(%ebp),%edi
  800858:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80085b:	85 c9                	test   %ecx,%ecx
  80085d:	74 36                	je     800895 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80085f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800865:	75 28                	jne    80088f <memset+0x40>
  800867:	f6 c1 03             	test   $0x3,%cl
  80086a:	75 23                	jne    80088f <memset+0x40>
		c &= 0xFF;
  80086c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800870:	89 d3                	mov    %edx,%ebx
  800872:	c1 e3 08             	shl    $0x8,%ebx
  800875:	89 d6                	mov    %edx,%esi
  800877:	c1 e6 18             	shl    $0x18,%esi
  80087a:	89 d0                	mov    %edx,%eax
  80087c:	c1 e0 10             	shl    $0x10,%eax
  80087f:	09 f0                	or     %esi,%eax
  800881:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800883:	89 d8                	mov    %ebx,%eax
  800885:	09 d0                	or     %edx,%eax
  800887:	c1 e9 02             	shr    $0x2,%ecx
  80088a:	fc                   	cld    
  80088b:	f3 ab                	rep stos %eax,%es:(%edi)
  80088d:	eb 06                	jmp    800895 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80088f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800892:	fc                   	cld    
  800893:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800895:	89 f8                	mov    %edi,%eax
  800897:	5b                   	pop    %ebx
  800898:	5e                   	pop    %esi
  800899:	5f                   	pop    %edi
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	57                   	push   %edi
  8008a0:	56                   	push   %esi
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008aa:	39 c6                	cmp    %eax,%esi
  8008ac:	73 35                	jae    8008e3 <memmove+0x47>
  8008ae:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b1:	39 d0                	cmp    %edx,%eax
  8008b3:	73 2e                	jae    8008e3 <memmove+0x47>
		s += n;
		d += n;
  8008b5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b8:	89 d6                	mov    %edx,%esi
  8008ba:	09 fe                	or     %edi,%esi
  8008bc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008c2:	75 13                	jne    8008d7 <memmove+0x3b>
  8008c4:	f6 c1 03             	test   $0x3,%cl
  8008c7:	75 0e                	jne    8008d7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008c9:	83 ef 04             	sub    $0x4,%edi
  8008cc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008cf:	c1 e9 02             	shr    $0x2,%ecx
  8008d2:	fd                   	std    
  8008d3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d5:	eb 09                	jmp    8008e0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008d7:	83 ef 01             	sub    $0x1,%edi
  8008da:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008dd:	fd                   	std    
  8008de:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e0:	fc                   	cld    
  8008e1:	eb 1d                	jmp    800900 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e3:	89 f2                	mov    %esi,%edx
  8008e5:	09 c2                	or     %eax,%edx
  8008e7:	f6 c2 03             	test   $0x3,%dl
  8008ea:	75 0f                	jne    8008fb <memmove+0x5f>
  8008ec:	f6 c1 03             	test   $0x3,%cl
  8008ef:	75 0a                	jne    8008fb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008f1:	c1 e9 02             	shr    $0x2,%ecx
  8008f4:	89 c7                	mov    %eax,%edi
  8008f6:	fc                   	cld    
  8008f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f9:	eb 05                	jmp    800900 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008fb:	89 c7                	mov    %eax,%edi
  8008fd:	fc                   	cld    
  8008fe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800900:	5e                   	pop    %esi
  800901:	5f                   	pop    %edi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800907:	ff 75 10             	pushl  0x10(%ebp)
  80090a:	ff 75 0c             	pushl  0xc(%ebp)
  80090d:	ff 75 08             	pushl  0x8(%ebp)
  800910:	e8 87 ff ff ff       	call   80089c <memmove>
}
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	56                   	push   %esi
  80091b:	53                   	push   %ebx
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800922:	89 c6                	mov    %eax,%esi
  800924:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800927:	eb 1a                	jmp    800943 <memcmp+0x2c>
		if (*s1 != *s2)
  800929:	0f b6 08             	movzbl (%eax),%ecx
  80092c:	0f b6 1a             	movzbl (%edx),%ebx
  80092f:	38 d9                	cmp    %bl,%cl
  800931:	74 0a                	je     80093d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800933:	0f b6 c1             	movzbl %cl,%eax
  800936:	0f b6 db             	movzbl %bl,%ebx
  800939:	29 d8                	sub    %ebx,%eax
  80093b:	eb 0f                	jmp    80094c <memcmp+0x35>
		s1++, s2++;
  80093d:	83 c0 01             	add    $0x1,%eax
  800940:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800943:	39 f0                	cmp    %esi,%eax
  800945:	75 e2                	jne    800929 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800947:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80094c:	5b                   	pop    %ebx
  80094d:	5e                   	pop    %esi
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	53                   	push   %ebx
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800957:	89 c1                	mov    %eax,%ecx
  800959:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80095c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800960:	eb 0a                	jmp    80096c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800962:	0f b6 10             	movzbl (%eax),%edx
  800965:	39 da                	cmp    %ebx,%edx
  800967:	74 07                	je     800970 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800969:	83 c0 01             	add    $0x1,%eax
  80096c:	39 c8                	cmp    %ecx,%eax
  80096e:	72 f2                	jb     800962 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800970:	5b                   	pop    %ebx
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	57                   	push   %edi
  800977:	56                   	push   %esi
  800978:	53                   	push   %ebx
  800979:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097f:	eb 03                	jmp    800984 <strtol+0x11>
		s++;
  800981:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800984:	0f b6 01             	movzbl (%ecx),%eax
  800987:	3c 20                	cmp    $0x20,%al
  800989:	74 f6                	je     800981 <strtol+0xe>
  80098b:	3c 09                	cmp    $0x9,%al
  80098d:	74 f2                	je     800981 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80098f:	3c 2b                	cmp    $0x2b,%al
  800991:	75 0a                	jne    80099d <strtol+0x2a>
		s++;
  800993:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800996:	bf 00 00 00 00       	mov    $0x0,%edi
  80099b:	eb 11                	jmp    8009ae <strtol+0x3b>
  80099d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009a2:	3c 2d                	cmp    $0x2d,%al
  8009a4:	75 08                	jne    8009ae <strtol+0x3b>
		s++, neg = 1;
  8009a6:	83 c1 01             	add    $0x1,%ecx
  8009a9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ae:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009b4:	75 15                	jne    8009cb <strtol+0x58>
  8009b6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b9:	75 10                	jne    8009cb <strtol+0x58>
  8009bb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009bf:	75 7c                	jne    800a3d <strtol+0xca>
		s += 2, base = 16;
  8009c1:	83 c1 02             	add    $0x2,%ecx
  8009c4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c9:	eb 16                	jmp    8009e1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009cb:	85 db                	test   %ebx,%ebx
  8009cd:	75 12                	jne    8009e1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009cf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009d4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d7:	75 08                	jne    8009e1 <strtol+0x6e>
		s++, base = 8;
  8009d9:	83 c1 01             	add    $0x1,%ecx
  8009dc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e9:	0f b6 11             	movzbl (%ecx),%edx
  8009ec:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009ef:	89 f3                	mov    %esi,%ebx
  8009f1:	80 fb 09             	cmp    $0x9,%bl
  8009f4:	77 08                	ja     8009fe <strtol+0x8b>
			dig = *s - '0';
  8009f6:	0f be d2             	movsbl %dl,%edx
  8009f9:	83 ea 30             	sub    $0x30,%edx
  8009fc:	eb 22                	jmp    800a20 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009fe:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a01:	89 f3                	mov    %esi,%ebx
  800a03:	80 fb 19             	cmp    $0x19,%bl
  800a06:	77 08                	ja     800a10 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a08:	0f be d2             	movsbl %dl,%edx
  800a0b:	83 ea 57             	sub    $0x57,%edx
  800a0e:	eb 10                	jmp    800a20 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a10:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a13:	89 f3                	mov    %esi,%ebx
  800a15:	80 fb 19             	cmp    $0x19,%bl
  800a18:	77 16                	ja     800a30 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a1a:	0f be d2             	movsbl %dl,%edx
  800a1d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a20:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a23:	7d 0b                	jge    800a30 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a25:	83 c1 01             	add    $0x1,%ecx
  800a28:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a2c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a2e:	eb b9                	jmp    8009e9 <strtol+0x76>

	if (endptr)
  800a30:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a34:	74 0d                	je     800a43 <strtol+0xd0>
		*endptr = (char *) s;
  800a36:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a39:	89 0e                	mov    %ecx,(%esi)
  800a3b:	eb 06                	jmp    800a43 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3d:	85 db                	test   %ebx,%ebx
  800a3f:	74 98                	je     8009d9 <strtol+0x66>
  800a41:	eb 9e                	jmp    8009e1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a43:	89 c2                	mov    %eax,%edx
  800a45:	f7 da                	neg    %edx
  800a47:	85 ff                	test   %edi,%edi
  800a49:	0f 45 c2             	cmovne %edx,%eax
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5f                   	pop    %edi
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	57                   	push   %edi
  800a55:	56                   	push   %esi
  800a56:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a57:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a62:	89 c3                	mov    %eax,%ebx
  800a64:	89 c7                	mov    %eax,%edi
  800a66:	89 c6                	mov    %eax,%esi
  800a68:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5f                   	pop    %edi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <sys_cgetc>:

int
sys_cgetc(void)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	57                   	push   %edi
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a75:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7a:	b8 01 00 00 00       	mov    $0x1,%eax
  800a7f:	89 d1                	mov    %edx,%ecx
  800a81:	89 d3                	mov    %edx,%ebx
  800a83:	89 d7                	mov    %edx,%edi
  800a85:	89 d6                	mov    %edx,%esi
  800a87:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	57                   	push   %edi
  800a92:	56                   	push   %esi
  800a93:	53                   	push   %ebx
  800a94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a97:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9c:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa1:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa4:	89 cb                	mov    %ecx,%ebx
  800aa6:	89 cf                	mov    %ecx,%edi
  800aa8:	89 ce                	mov    %ecx,%esi
  800aaa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aac:	85 c0                	test   %eax,%eax
  800aae:	7e 17                	jle    800ac7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab0:	83 ec 0c             	sub    $0xc,%esp
  800ab3:	50                   	push   %eax
  800ab4:	6a 03                	push   $0x3
  800ab6:	68 28 12 80 00       	push   $0x801228
  800abb:	6a 23                	push   $0x23
  800abd:	68 45 12 80 00       	push   $0x801245
  800ac2:	e8 f5 01 00 00       	call   800cbc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad5:	ba 00 00 00 00       	mov    $0x0,%edx
  800ada:	b8 02 00 00 00       	mov    $0x2,%eax
  800adf:	89 d1                	mov    %edx,%ecx
  800ae1:	89 d3                	mov    %edx,%ebx
  800ae3:	89 d7                	mov    %edx,%edi
  800ae5:	89 d6                	mov    %edx,%esi
  800ae7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <sys_yield>:

void
sys_yield(void)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af4:	ba 00 00 00 00       	mov    $0x0,%edx
  800af9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800afe:	89 d1                	mov    %edx,%ecx
  800b00:	89 d3                	mov    %edx,%ebx
  800b02:	89 d7                	mov    %edx,%edi
  800b04:	89 d6                	mov    %edx,%esi
  800b06:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	57                   	push   %edi
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
  800b13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	be 00 00 00 00       	mov    $0x0,%esi
  800b1b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b23:	8b 55 08             	mov    0x8(%ebp),%edx
  800b26:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b29:	89 f7                	mov    %esi,%edi
  800b2b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	7e 17                	jle    800b48 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b31:	83 ec 0c             	sub    $0xc,%esp
  800b34:	50                   	push   %eax
  800b35:	6a 04                	push   $0x4
  800b37:	68 28 12 80 00       	push   $0x801228
  800b3c:	6a 23                	push   $0x23
  800b3e:	68 45 12 80 00       	push   $0x801245
  800b43:	e8 74 01 00 00       	call   800cbc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4b:	5b                   	pop    %ebx
  800b4c:	5e                   	pop    %esi
  800b4d:	5f                   	pop    %edi
  800b4e:	5d                   	pop    %ebp
  800b4f:	c3                   	ret    

00800b50 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	57                   	push   %edi
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
  800b56:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b59:	b8 05 00 00 00       	mov    $0x5,%eax
  800b5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b61:	8b 55 08             	mov    0x8(%ebp),%edx
  800b64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b67:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b6a:	8b 75 18             	mov    0x18(%ebp),%esi
  800b6d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b6f:	85 c0                	test   %eax,%eax
  800b71:	7e 17                	jle    800b8a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b73:	83 ec 0c             	sub    $0xc,%esp
  800b76:	50                   	push   %eax
  800b77:	6a 05                	push   $0x5
  800b79:	68 28 12 80 00       	push   $0x801228
  800b7e:	6a 23                	push   $0x23
  800b80:	68 45 12 80 00       	push   $0x801245
  800b85:	e8 32 01 00 00       	call   800cbc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
  800b98:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba0:	b8 06 00 00 00       	mov    $0x6,%eax
  800ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	89 df                	mov    %ebx,%edi
  800bad:	89 de                	mov    %ebx,%esi
  800baf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bb1:	85 c0                	test   %eax,%eax
  800bb3:	7e 17                	jle    800bcc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb5:	83 ec 0c             	sub    $0xc,%esp
  800bb8:	50                   	push   %eax
  800bb9:	6a 06                	push   $0x6
  800bbb:	68 28 12 80 00       	push   $0x801228
  800bc0:	6a 23                	push   $0x23
  800bc2:	68 45 12 80 00       	push   $0x801245
  800bc7:	e8 f0 00 00 00       	call   800cbc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
  800bda:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be2:	b8 08 00 00 00       	mov    $0x8,%eax
  800be7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bea:	8b 55 08             	mov    0x8(%ebp),%edx
  800bed:	89 df                	mov    %ebx,%edi
  800bef:	89 de                	mov    %ebx,%esi
  800bf1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	7e 17                	jle    800c0e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf7:	83 ec 0c             	sub    $0xc,%esp
  800bfa:	50                   	push   %eax
  800bfb:	6a 08                	push   $0x8
  800bfd:	68 28 12 80 00       	push   $0x801228
  800c02:	6a 23                	push   $0x23
  800c04:	68 45 12 80 00       	push   $0x801245
  800c09:	e8 ae 00 00 00       	call   800cbc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
  800c1c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c24:	b8 09 00 00 00       	mov    $0x9,%eax
  800c29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2f:	89 df                	mov    %ebx,%edi
  800c31:	89 de                	mov    %ebx,%esi
  800c33:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c35:	85 c0                	test   %eax,%eax
  800c37:	7e 17                	jle    800c50 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c39:	83 ec 0c             	sub    $0xc,%esp
  800c3c:	50                   	push   %eax
  800c3d:	6a 09                	push   $0x9
  800c3f:	68 28 12 80 00       	push   $0x801228
  800c44:	6a 23                	push   $0x23
  800c46:	68 45 12 80 00       	push   $0x801245
  800c4b:	e8 6c 00 00 00       	call   800cbc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c53:	5b                   	pop    %ebx
  800c54:	5e                   	pop    %esi
  800c55:	5f                   	pop    %edi
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	be 00 00 00 00       	mov    $0x0,%esi
  800c63:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c71:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c74:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c89:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c91:	89 cb                	mov    %ecx,%ebx
  800c93:	89 cf                	mov    %ecx,%edi
  800c95:	89 ce                	mov    %ecx,%esi
  800c97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 17                	jle    800cb4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 0c                	push   $0xc
  800ca3:	68 28 12 80 00       	push   $0x801228
  800ca8:	6a 23                	push   $0x23
  800caa:	68 45 12 80 00       	push   $0x801245
  800caf:	e8 08 00 00 00       	call   800cbc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800cc1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800cc4:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800cca:	e8 00 fe ff ff       	call   800acf <sys_getenvid>
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	ff 75 0c             	pushl  0xc(%ebp)
  800cd5:	ff 75 08             	pushl  0x8(%ebp)
  800cd8:	56                   	push   %esi
  800cd9:	50                   	push   %eax
  800cda:	68 54 12 80 00       	push   $0x801254
  800cdf:	e8 5f f4 ff ff       	call   800143 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ce4:	83 c4 18             	add    $0x18,%esp
  800ce7:	53                   	push   %ebx
  800ce8:	ff 75 10             	pushl  0x10(%ebp)
  800ceb:	e8 02 f4 ff ff       	call   8000f2 <vcprintf>
	cprintf("\n");
  800cf0:	c7 04 24 bc 0f 80 00 	movl   $0x800fbc,(%esp)
  800cf7:	e8 47 f4 ff ff       	call   800143 <cprintf>
  800cfc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cff:	cc                   	int3   
  800d00:	eb fd                	jmp    800cff <_panic+0x43>
  800d02:	66 90                	xchg   %ax,%ax
  800d04:	66 90                	xchg   %ax,%ax
  800d06:	66 90                	xchg   %ax,%ax
  800d08:	66 90                	xchg   %ax,%ax
  800d0a:	66 90                	xchg   %ax,%ax
  800d0c:	66 90                	xchg   %ax,%ax
  800d0e:	66 90                	xchg   %ax,%ax

00800d10 <__udivdi3>:
  800d10:	55                   	push   %ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 1c             	sub    $0x1c,%esp
  800d17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d27:	85 f6                	test   %esi,%esi
  800d29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d2d:	89 ca                	mov    %ecx,%edx
  800d2f:	89 f8                	mov    %edi,%eax
  800d31:	75 3d                	jne    800d70 <__udivdi3+0x60>
  800d33:	39 cf                	cmp    %ecx,%edi
  800d35:	0f 87 c5 00 00 00    	ja     800e00 <__udivdi3+0xf0>
  800d3b:	85 ff                	test   %edi,%edi
  800d3d:	89 fd                	mov    %edi,%ebp
  800d3f:	75 0b                	jne    800d4c <__udivdi3+0x3c>
  800d41:	b8 01 00 00 00       	mov    $0x1,%eax
  800d46:	31 d2                	xor    %edx,%edx
  800d48:	f7 f7                	div    %edi
  800d4a:	89 c5                	mov    %eax,%ebp
  800d4c:	89 c8                	mov    %ecx,%eax
  800d4e:	31 d2                	xor    %edx,%edx
  800d50:	f7 f5                	div    %ebp
  800d52:	89 c1                	mov    %eax,%ecx
  800d54:	89 d8                	mov    %ebx,%eax
  800d56:	89 cf                	mov    %ecx,%edi
  800d58:	f7 f5                	div    %ebp
  800d5a:	89 c3                	mov    %eax,%ebx
  800d5c:	89 d8                	mov    %ebx,%eax
  800d5e:	89 fa                	mov    %edi,%edx
  800d60:	83 c4 1c             	add    $0x1c,%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    
  800d68:	90                   	nop
  800d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d70:	39 ce                	cmp    %ecx,%esi
  800d72:	77 74                	ja     800de8 <__udivdi3+0xd8>
  800d74:	0f bd fe             	bsr    %esi,%edi
  800d77:	83 f7 1f             	xor    $0x1f,%edi
  800d7a:	0f 84 98 00 00 00    	je     800e18 <__udivdi3+0x108>
  800d80:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d85:	89 f9                	mov    %edi,%ecx
  800d87:	89 c5                	mov    %eax,%ebp
  800d89:	29 fb                	sub    %edi,%ebx
  800d8b:	d3 e6                	shl    %cl,%esi
  800d8d:	89 d9                	mov    %ebx,%ecx
  800d8f:	d3 ed                	shr    %cl,%ebp
  800d91:	89 f9                	mov    %edi,%ecx
  800d93:	d3 e0                	shl    %cl,%eax
  800d95:	09 ee                	or     %ebp,%esi
  800d97:	89 d9                	mov    %ebx,%ecx
  800d99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d9d:	89 d5                	mov    %edx,%ebp
  800d9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800da3:	d3 ed                	shr    %cl,%ebp
  800da5:	89 f9                	mov    %edi,%ecx
  800da7:	d3 e2                	shl    %cl,%edx
  800da9:	89 d9                	mov    %ebx,%ecx
  800dab:	d3 e8                	shr    %cl,%eax
  800dad:	09 c2                	or     %eax,%edx
  800daf:	89 d0                	mov    %edx,%eax
  800db1:	89 ea                	mov    %ebp,%edx
  800db3:	f7 f6                	div    %esi
  800db5:	89 d5                	mov    %edx,%ebp
  800db7:	89 c3                	mov    %eax,%ebx
  800db9:	f7 64 24 0c          	mull   0xc(%esp)
  800dbd:	39 d5                	cmp    %edx,%ebp
  800dbf:	72 10                	jb     800dd1 <__udivdi3+0xc1>
  800dc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800dc5:	89 f9                	mov    %edi,%ecx
  800dc7:	d3 e6                	shl    %cl,%esi
  800dc9:	39 c6                	cmp    %eax,%esi
  800dcb:	73 07                	jae    800dd4 <__udivdi3+0xc4>
  800dcd:	39 d5                	cmp    %edx,%ebp
  800dcf:	75 03                	jne    800dd4 <__udivdi3+0xc4>
  800dd1:	83 eb 01             	sub    $0x1,%ebx
  800dd4:	31 ff                	xor    %edi,%edi
  800dd6:	89 d8                	mov    %ebx,%eax
  800dd8:	89 fa                	mov    %edi,%edx
  800dda:	83 c4 1c             	add    $0x1c,%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    
  800de2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800de8:	31 ff                	xor    %edi,%edi
  800dea:	31 db                	xor    %ebx,%ebx
  800dec:	89 d8                	mov    %ebx,%eax
  800dee:	89 fa                	mov    %edi,%edx
  800df0:	83 c4 1c             	add    $0x1c,%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    
  800df8:	90                   	nop
  800df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e00:	89 d8                	mov    %ebx,%eax
  800e02:	f7 f7                	div    %edi
  800e04:	31 ff                	xor    %edi,%edi
  800e06:	89 c3                	mov    %eax,%ebx
  800e08:	89 d8                	mov    %ebx,%eax
  800e0a:	89 fa                	mov    %edi,%edx
  800e0c:	83 c4 1c             	add    $0x1c,%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    
  800e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e18:	39 ce                	cmp    %ecx,%esi
  800e1a:	72 0c                	jb     800e28 <__udivdi3+0x118>
  800e1c:	31 db                	xor    %ebx,%ebx
  800e1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e22:	0f 87 34 ff ff ff    	ja     800d5c <__udivdi3+0x4c>
  800e28:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e2d:	e9 2a ff ff ff       	jmp    800d5c <__udivdi3+0x4c>
  800e32:	66 90                	xchg   %ax,%ax
  800e34:	66 90                	xchg   %ax,%ax
  800e36:	66 90                	xchg   %ax,%ax
  800e38:	66 90                	xchg   %ax,%ax
  800e3a:	66 90                	xchg   %ax,%ax
  800e3c:	66 90                	xchg   %ax,%ax
  800e3e:	66 90                	xchg   %ax,%ax

00800e40 <__umoddi3>:
  800e40:	55                   	push   %ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
  800e44:	83 ec 1c             	sub    $0x1c,%esp
  800e47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e57:	85 d2                	test   %edx,%edx
  800e59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e61:	89 f3                	mov    %esi,%ebx
  800e63:	89 3c 24             	mov    %edi,(%esp)
  800e66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e6a:	75 1c                	jne    800e88 <__umoddi3+0x48>
  800e6c:	39 f7                	cmp    %esi,%edi
  800e6e:	76 50                	jbe    800ec0 <__umoddi3+0x80>
  800e70:	89 c8                	mov    %ecx,%eax
  800e72:	89 f2                	mov    %esi,%edx
  800e74:	f7 f7                	div    %edi
  800e76:	89 d0                	mov    %edx,%eax
  800e78:	31 d2                	xor    %edx,%edx
  800e7a:	83 c4 1c             	add    $0x1c,%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
  800e82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e88:	39 f2                	cmp    %esi,%edx
  800e8a:	89 d0                	mov    %edx,%eax
  800e8c:	77 52                	ja     800ee0 <__umoddi3+0xa0>
  800e8e:	0f bd ea             	bsr    %edx,%ebp
  800e91:	83 f5 1f             	xor    $0x1f,%ebp
  800e94:	75 5a                	jne    800ef0 <__umoddi3+0xb0>
  800e96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e9a:	0f 82 e0 00 00 00    	jb     800f80 <__umoddi3+0x140>
  800ea0:	39 0c 24             	cmp    %ecx,(%esp)
  800ea3:	0f 86 d7 00 00 00    	jbe    800f80 <__umoddi3+0x140>
  800ea9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ead:	8b 54 24 04          	mov    0x4(%esp),%edx
  800eb1:	83 c4 1c             	add    $0x1c,%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	85 ff                	test   %edi,%edi
  800ec2:	89 fd                	mov    %edi,%ebp
  800ec4:	75 0b                	jne    800ed1 <__umoddi3+0x91>
  800ec6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ecb:	31 d2                	xor    %edx,%edx
  800ecd:	f7 f7                	div    %edi
  800ecf:	89 c5                	mov    %eax,%ebp
  800ed1:	89 f0                	mov    %esi,%eax
  800ed3:	31 d2                	xor    %edx,%edx
  800ed5:	f7 f5                	div    %ebp
  800ed7:	89 c8                	mov    %ecx,%eax
  800ed9:	f7 f5                	div    %ebp
  800edb:	89 d0                	mov    %edx,%eax
  800edd:	eb 99                	jmp    800e78 <__umoddi3+0x38>
  800edf:	90                   	nop
  800ee0:	89 c8                	mov    %ecx,%eax
  800ee2:	89 f2                	mov    %esi,%edx
  800ee4:	83 c4 1c             	add    $0x1c,%esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5f                   	pop    %edi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    
  800eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	8b 34 24             	mov    (%esp),%esi
  800ef3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ef8:	89 e9                	mov    %ebp,%ecx
  800efa:	29 ef                	sub    %ebp,%edi
  800efc:	d3 e0                	shl    %cl,%eax
  800efe:	89 f9                	mov    %edi,%ecx
  800f00:	89 f2                	mov    %esi,%edx
  800f02:	d3 ea                	shr    %cl,%edx
  800f04:	89 e9                	mov    %ebp,%ecx
  800f06:	09 c2                	or     %eax,%edx
  800f08:	89 d8                	mov    %ebx,%eax
  800f0a:	89 14 24             	mov    %edx,(%esp)
  800f0d:	89 f2                	mov    %esi,%edx
  800f0f:	d3 e2                	shl    %cl,%edx
  800f11:	89 f9                	mov    %edi,%ecx
  800f13:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f1b:	d3 e8                	shr    %cl,%eax
  800f1d:	89 e9                	mov    %ebp,%ecx
  800f1f:	89 c6                	mov    %eax,%esi
  800f21:	d3 e3                	shl    %cl,%ebx
  800f23:	89 f9                	mov    %edi,%ecx
  800f25:	89 d0                	mov    %edx,%eax
  800f27:	d3 e8                	shr    %cl,%eax
  800f29:	89 e9                	mov    %ebp,%ecx
  800f2b:	09 d8                	or     %ebx,%eax
  800f2d:	89 d3                	mov    %edx,%ebx
  800f2f:	89 f2                	mov    %esi,%edx
  800f31:	f7 34 24             	divl   (%esp)
  800f34:	89 d6                	mov    %edx,%esi
  800f36:	d3 e3                	shl    %cl,%ebx
  800f38:	f7 64 24 04          	mull   0x4(%esp)
  800f3c:	39 d6                	cmp    %edx,%esi
  800f3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f42:	89 d1                	mov    %edx,%ecx
  800f44:	89 c3                	mov    %eax,%ebx
  800f46:	72 08                	jb     800f50 <__umoddi3+0x110>
  800f48:	75 11                	jne    800f5b <__umoddi3+0x11b>
  800f4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f4e:	73 0b                	jae    800f5b <__umoddi3+0x11b>
  800f50:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f54:	1b 14 24             	sbb    (%esp),%edx
  800f57:	89 d1                	mov    %edx,%ecx
  800f59:	89 c3                	mov    %eax,%ebx
  800f5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f5f:	29 da                	sub    %ebx,%edx
  800f61:	19 ce                	sbb    %ecx,%esi
  800f63:	89 f9                	mov    %edi,%ecx
  800f65:	89 f0                	mov    %esi,%eax
  800f67:	d3 e0                	shl    %cl,%eax
  800f69:	89 e9                	mov    %ebp,%ecx
  800f6b:	d3 ea                	shr    %cl,%edx
  800f6d:	89 e9                	mov    %ebp,%ecx
  800f6f:	d3 ee                	shr    %cl,%esi
  800f71:	09 d0                	or     %edx,%eax
  800f73:	89 f2                	mov    %esi,%edx
  800f75:	83 c4 1c             	add    $0x1c,%esp
  800f78:	5b                   	pop    %ebx
  800f79:	5e                   	pop    %esi
  800f7a:	5f                   	pop    %edi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi
  800f80:	29 f9                	sub    %edi,%ecx
  800f82:	19 d6                	sbb    %edx,%esi
  800f84:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f8c:	e9 18 ff ff ff       	jmp    800ea9 <__umoddi3+0x69>
