
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
  80003f:	68 e0 0d 80 00       	push   $0x800de0
  800044:	e8 fd 00 00 00       	call   800146 <cprintf>
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
  800063:	e8 6a 0a 00 00       	call   800ad2 <sys_getenvid>
  800068:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006d:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800070:	c1 e0 05             	shl    $0x5,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 db                	test   %ebx,%ebx
  80007f:	7e 07                	jle    800088 <libmain+0x3a>
		binaryname = argv[0];
  800081:	8b 06                	mov    (%esi),%eax
  800083:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800088:	83 ec 08             	sub    $0x8,%esp
  80008b:	56                   	push   %esi
  80008c:	53                   	push   %ebx
  80008d:	e8 a1 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800092:	e8 0a 00 00 00       	call   8000a1 <exit>
}
  800097:	83 c4 10             	add    $0x10,%esp
  80009a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009d:	5b                   	pop    %ebx
  80009e:	5e                   	pop    %esi
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    

008000a1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a7:	6a 00                	push   $0x0
  8000a9:	e8 e3 09 00 00       	call   800a91 <sys_env_destroy>
}
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	c9                   	leave  
  8000b2:	c3                   	ret    

008000b3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	53                   	push   %ebx
  8000b7:	83 ec 04             	sub    $0x4,%esp
  8000ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000bd:	8b 13                	mov    (%ebx),%edx
  8000bf:	8d 42 01             	lea    0x1(%edx),%eax
  8000c2:	89 03                	mov    %eax,(%ebx)
  8000c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000cb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d0:	75 1a                	jne    8000ec <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d2:	83 ec 08             	sub    $0x8,%esp
  8000d5:	68 ff 00 00 00       	push   $0xff
  8000da:	8d 43 08             	lea    0x8(%ebx),%eax
  8000dd:	50                   	push   %eax
  8000de:	e8 71 09 00 00       	call   800a54 <sys_cputs>
		b->idx = 0;
  8000e3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000ec:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f3:	c9                   	leave  
  8000f4:	c3                   	ret    

008000f5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000fe:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800105:	00 00 00 
	b.cnt = 0;
  800108:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800112:	ff 75 0c             	pushl  0xc(%ebp)
  800115:	ff 75 08             	pushl  0x8(%ebp)
  800118:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80011e:	50                   	push   %eax
  80011f:	68 b3 00 80 00       	push   $0x8000b3
  800124:	e8 54 01 00 00       	call   80027d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800132:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800138:	50                   	push   %eax
  800139:	e8 16 09 00 00       	call   800a54 <sys_cputs>

	return b.cnt;
}
  80013e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80014c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014f:	50                   	push   %eax
  800150:	ff 75 08             	pushl  0x8(%ebp)
  800153:	e8 9d ff ff ff       	call   8000f5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800158:	c9                   	leave  
  800159:	c3                   	ret    

0080015a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 1c             	sub    $0x1c,%esp
  800163:	89 c7                	mov    %eax,%edi
  800165:	89 d6                	mov    %edx,%esi
  800167:	8b 45 08             	mov    0x8(%ebp),%eax
  80016a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800170:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800173:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800176:	bb 00 00 00 00       	mov    $0x0,%ebx
  80017b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80017e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800181:	39 d3                	cmp    %edx,%ebx
  800183:	72 05                	jb     80018a <printnum+0x30>
  800185:	39 45 10             	cmp    %eax,0x10(%ebp)
  800188:	77 45                	ja     8001cf <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	ff 75 18             	pushl  0x18(%ebp)
  800190:	8b 45 14             	mov    0x14(%ebp),%eax
  800193:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800196:	53                   	push   %ebx
  800197:	ff 75 10             	pushl  0x10(%ebp)
  80019a:	83 ec 08             	sub    $0x8,%esp
  80019d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a9:	e8 92 09 00 00       	call   800b40 <__udivdi3>
  8001ae:	83 c4 18             	add    $0x18,%esp
  8001b1:	52                   	push   %edx
  8001b2:	50                   	push   %eax
  8001b3:	89 f2                	mov    %esi,%edx
  8001b5:	89 f8                	mov    %edi,%eax
  8001b7:	e8 9e ff ff ff       	call   80015a <printnum>
  8001bc:	83 c4 20             	add    $0x20,%esp
  8001bf:	eb 18                	jmp    8001d9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c1:	83 ec 08             	sub    $0x8,%esp
  8001c4:	56                   	push   %esi
  8001c5:	ff 75 18             	pushl  0x18(%ebp)
  8001c8:	ff d7                	call   *%edi
  8001ca:	83 c4 10             	add    $0x10,%esp
  8001cd:	eb 03                	jmp    8001d2 <printnum+0x78>
  8001cf:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d2:	83 eb 01             	sub    $0x1,%ebx
  8001d5:	85 db                	test   %ebx,%ebx
  8001d7:	7f e8                	jg     8001c1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	56                   	push   %esi
  8001dd:	83 ec 04             	sub    $0x4,%esp
  8001e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ec:	e8 7f 0a 00 00       	call   800c70 <__umoddi3>
  8001f1:	83 c4 14             	add    $0x14,%esp
  8001f4:	0f be 80 08 0e 80 00 	movsbl 0x800e08(%eax),%eax
  8001fb:	50                   	push   %eax
  8001fc:	ff d7                	call   *%edi
}
  8001fe:	83 c4 10             	add    $0x10,%esp
  800201:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800204:	5b                   	pop    %ebx
  800205:	5e                   	pop    %esi
  800206:	5f                   	pop    %edi
  800207:	5d                   	pop    %ebp
  800208:	c3                   	ret    

00800209 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80020c:	83 fa 01             	cmp    $0x1,%edx
  80020f:	7e 0e                	jle    80021f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800211:	8b 10                	mov    (%eax),%edx
  800213:	8d 4a 08             	lea    0x8(%edx),%ecx
  800216:	89 08                	mov    %ecx,(%eax)
  800218:	8b 02                	mov    (%edx),%eax
  80021a:	8b 52 04             	mov    0x4(%edx),%edx
  80021d:	eb 22                	jmp    800241 <getuint+0x38>
	else if (lflag)
  80021f:	85 d2                	test   %edx,%edx
  800221:	74 10                	je     800233 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800223:	8b 10                	mov    (%eax),%edx
  800225:	8d 4a 04             	lea    0x4(%edx),%ecx
  800228:	89 08                	mov    %ecx,(%eax)
  80022a:	8b 02                	mov    (%edx),%eax
  80022c:	ba 00 00 00 00       	mov    $0x0,%edx
  800231:	eb 0e                	jmp    800241 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800233:	8b 10                	mov    (%eax),%edx
  800235:	8d 4a 04             	lea    0x4(%edx),%ecx
  800238:	89 08                	mov    %ecx,(%eax)
  80023a:	8b 02                	mov    (%edx),%eax
  80023c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800241:	5d                   	pop    %ebp
  800242:	c3                   	ret    

00800243 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800249:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80024d:	8b 10                	mov    (%eax),%edx
  80024f:	3b 50 04             	cmp    0x4(%eax),%edx
  800252:	73 0a                	jae    80025e <sprintputch+0x1b>
		*b->buf++ = ch;
  800254:	8d 4a 01             	lea    0x1(%edx),%ecx
  800257:	89 08                	mov    %ecx,(%eax)
  800259:	8b 45 08             	mov    0x8(%ebp),%eax
  80025c:	88 02                	mov    %al,(%edx)
}
  80025e:	5d                   	pop    %ebp
  80025f:	c3                   	ret    

00800260 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800266:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800269:	50                   	push   %eax
  80026a:	ff 75 10             	pushl  0x10(%ebp)
  80026d:	ff 75 0c             	pushl  0xc(%ebp)
  800270:	ff 75 08             	pushl  0x8(%ebp)
  800273:	e8 05 00 00 00       	call   80027d <vprintfmt>
	va_end(ap);
}
  800278:	83 c4 10             	add    $0x10,%esp
  80027b:	c9                   	leave  
  80027c:	c3                   	ret    

0080027d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	57                   	push   %edi
  800281:	56                   	push   %esi
  800282:	53                   	push   %ebx
  800283:	83 ec 2c             	sub    $0x2c,%esp
  800286:	8b 75 08             	mov    0x8(%ebp),%esi
  800289:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80028c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80028f:	eb 12                	jmp    8002a3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800291:	85 c0                	test   %eax,%eax
  800293:	0f 84 cb 03 00 00    	je     800664 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	53                   	push   %ebx
  80029d:	50                   	push   %eax
  80029e:	ff d6                	call   *%esi
  8002a0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a3:	83 c7 01             	add    $0x1,%edi
  8002a6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002aa:	83 f8 25             	cmp    $0x25,%eax
  8002ad:	75 e2                	jne    800291 <vprintfmt+0x14>
  8002af:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002b3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ba:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002c1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cd:	eb 07                	jmp    8002d6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002d2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d6:	8d 47 01             	lea    0x1(%edi),%eax
  8002d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002dc:	0f b6 07             	movzbl (%edi),%eax
  8002df:	0f b6 c8             	movzbl %al,%ecx
  8002e2:	83 e8 23             	sub    $0x23,%eax
  8002e5:	3c 55                	cmp    $0x55,%al
  8002e7:	0f 87 5c 03 00 00    	ja     800649 <vprintfmt+0x3cc>
  8002ed:	0f b6 c0             	movzbl %al,%eax
  8002f0:	ff 24 85 c0 0e 80 00 	jmp    *0x800ec0(,%eax,4)
  8002f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002fa:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002fe:	eb d6                	jmp    8002d6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800300:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800303:	b8 00 00 00 00       	mov    $0x0,%eax
  800308:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80030b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80030e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800312:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800315:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800318:	83 fa 09             	cmp    $0x9,%edx
  80031b:	77 39                	ja     800356 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80031d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800320:	eb e9                	jmp    80030b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800322:	8b 45 14             	mov    0x14(%ebp),%eax
  800325:	8d 48 04             	lea    0x4(%eax),%ecx
  800328:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80032b:	8b 00                	mov    (%eax),%eax
  80032d:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800330:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800333:	eb 27                	jmp    80035c <vprintfmt+0xdf>
  800335:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800338:	85 c0                	test   %eax,%eax
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	0f 49 c8             	cmovns %eax,%ecx
  800342:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800348:	eb 8c                	jmp    8002d6 <vprintfmt+0x59>
  80034a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80034d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800354:	eb 80                	jmp    8002d6 <vprintfmt+0x59>
  800356:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800359:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80035c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800360:	0f 89 70 ff ff ff    	jns    8002d6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800366:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800369:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036c:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800373:	e9 5e ff ff ff       	jmp    8002d6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800378:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80037e:	e9 53 ff ff ff       	jmp    8002d6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800383:	8b 45 14             	mov    0x14(%ebp),%eax
  800386:	8d 50 04             	lea    0x4(%eax),%edx
  800389:	89 55 14             	mov    %edx,0x14(%ebp)
  80038c:	83 ec 08             	sub    $0x8,%esp
  80038f:	53                   	push   %ebx
  800390:	ff 30                	pushl  (%eax)
  800392:	ff d6                	call   *%esi
			break;
  800394:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800397:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80039a:	e9 04 ff ff ff       	jmp    8002a3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80039f:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a2:	8d 50 04             	lea    0x4(%eax),%edx
  8003a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a8:	8b 00                	mov    (%eax),%eax
  8003aa:	99                   	cltd   
  8003ab:	31 d0                	xor    %edx,%eax
  8003ad:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003af:	83 f8 07             	cmp    $0x7,%eax
  8003b2:	7f 0b                	jg     8003bf <vprintfmt+0x142>
  8003b4:	8b 14 85 20 10 80 00 	mov    0x801020(,%eax,4),%edx
  8003bb:	85 d2                	test   %edx,%edx
  8003bd:	75 18                	jne    8003d7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003bf:	50                   	push   %eax
  8003c0:	68 20 0e 80 00       	push   $0x800e20
  8003c5:	53                   	push   %ebx
  8003c6:	56                   	push   %esi
  8003c7:	e8 94 fe ff ff       	call   800260 <printfmt>
  8003cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d2:	e9 cc fe ff ff       	jmp    8002a3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003d7:	52                   	push   %edx
  8003d8:	68 29 0e 80 00       	push   $0x800e29
  8003dd:	53                   	push   %ebx
  8003de:	56                   	push   %esi
  8003df:	e8 7c fe ff ff       	call   800260 <printfmt>
  8003e4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ea:	e9 b4 fe ff ff       	jmp    8002a3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 50 04             	lea    0x4(%eax),%edx
  8003f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003fa:	85 ff                	test   %edi,%edi
  8003fc:	b8 19 0e 80 00       	mov    $0x800e19,%eax
  800401:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800404:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800408:	0f 8e 94 00 00 00    	jle    8004a2 <vprintfmt+0x225>
  80040e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800412:	0f 84 98 00 00 00    	je     8004b0 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800418:	83 ec 08             	sub    $0x8,%esp
  80041b:	ff 75 c8             	pushl  -0x38(%ebp)
  80041e:	57                   	push   %edi
  80041f:	e8 c8 02 00 00       	call   8006ec <strnlen>
  800424:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800427:	29 c1                	sub    %eax,%ecx
  800429:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80042c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800433:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800436:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800439:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80043b:	eb 0f                	jmp    80044c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	53                   	push   %ebx
  800441:	ff 75 e0             	pushl  -0x20(%ebp)
  800444:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800446:	83 ef 01             	sub    $0x1,%edi
  800449:	83 c4 10             	add    $0x10,%esp
  80044c:	85 ff                	test   %edi,%edi
  80044e:	7f ed                	jg     80043d <vprintfmt+0x1c0>
  800450:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800453:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800456:	85 c9                	test   %ecx,%ecx
  800458:	b8 00 00 00 00       	mov    $0x0,%eax
  80045d:	0f 49 c1             	cmovns %ecx,%eax
  800460:	29 c1                	sub    %eax,%ecx
  800462:	89 75 08             	mov    %esi,0x8(%ebp)
  800465:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800468:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80046b:	89 cb                	mov    %ecx,%ebx
  80046d:	eb 4d                	jmp    8004bc <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80046f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800473:	74 1b                	je     800490 <vprintfmt+0x213>
  800475:	0f be c0             	movsbl %al,%eax
  800478:	83 e8 20             	sub    $0x20,%eax
  80047b:	83 f8 5e             	cmp    $0x5e,%eax
  80047e:	76 10                	jbe    800490 <vprintfmt+0x213>
					putch('?', putdat);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	ff 75 0c             	pushl  0xc(%ebp)
  800486:	6a 3f                	push   $0x3f
  800488:	ff 55 08             	call   *0x8(%ebp)
  80048b:	83 c4 10             	add    $0x10,%esp
  80048e:	eb 0d                	jmp    80049d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	ff 75 0c             	pushl  0xc(%ebp)
  800496:	52                   	push   %edx
  800497:	ff 55 08             	call   *0x8(%ebp)
  80049a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049d:	83 eb 01             	sub    $0x1,%ebx
  8004a0:	eb 1a                	jmp    8004bc <vprintfmt+0x23f>
  8004a2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a5:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004a8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ab:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ae:	eb 0c                	jmp    8004bc <vprintfmt+0x23f>
  8004b0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b3:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004b6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004bc:	83 c7 01             	add    $0x1,%edi
  8004bf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c3:	0f be d0             	movsbl %al,%edx
  8004c6:	85 d2                	test   %edx,%edx
  8004c8:	74 23                	je     8004ed <vprintfmt+0x270>
  8004ca:	85 f6                	test   %esi,%esi
  8004cc:	78 a1                	js     80046f <vprintfmt+0x1f2>
  8004ce:	83 ee 01             	sub    $0x1,%esi
  8004d1:	79 9c                	jns    80046f <vprintfmt+0x1f2>
  8004d3:	89 df                	mov    %ebx,%edi
  8004d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004db:	eb 18                	jmp    8004f5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	53                   	push   %ebx
  8004e1:	6a 20                	push   $0x20
  8004e3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e5:	83 ef 01             	sub    $0x1,%edi
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	eb 08                	jmp    8004f5 <vprintfmt+0x278>
  8004ed:	89 df                	mov    %ebx,%edi
  8004ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f5:	85 ff                	test   %edi,%edi
  8004f7:	7f e4                	jg     8004dd <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004fc:	e9 a2 fd ff ff       	jmp    8002a3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800501:	83 fa 01             	cmp    $0x1,%edx
  800504:	7e 16                	jle    80051c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 50 08             	lea    0x8(%eax),%edx
  80050c:	89 55 14             	mov    %edx,0x14(%ebp)
  80050f:	8b 50 04             	mov    0x4(%eax),%edx
  800512:	8b 00                	mov    (%eax),%eax
  800514:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800517:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80051a:	eb 32                	jmp    80054e <vprintfmt+0x2d1>
	else if (lflag)
  80051c:	85 d2                	test   %edx,%edx
  80051e:	74 18                	je     800538 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 50 04             	lea    0x4(%eax),%edx
  800526:	89 55 14             	mov    %edx,0x14(%ebp)
  800529:	8b 00                	mov    (%eax),%eax
  80052b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80052e:	89 c1                	mov    %eax,%ecx
  800530:	c1 f9 1f             	sar    $0x1f,%ecx
  800533:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800536:	eb 16                	jmp    80054e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 50 04             	lea    0x4(%eax),%edx
  80053e:	89 55 14             	mov    %edx,0x14(%ebp)
  800541:	8b 00                	mov    (%eax),%eax
  800543:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800546:	89 c1                	mov    %eax,%ecx
  800548:	c1 f9 1f             	sar    $0x1f,%ecx
  80054b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80054e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800551:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800554:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800557:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055a:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800563:	0f 89 a8 00 00 00    	jns    800611 <vprintfmt+0x394>
				putch('-', putdat);
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	53                   	push   %ebx
  80056d:	6a 2d                	push   $0x2d
  80056f:	ff d6                	call   *%esi
				num = -(long long) num;
  800571:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800574:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800577:	f7 d8                	neg    %eax
  800579:	83 d2 00             	adc    $0x0,%edx
  80057c:	f7 da                	neg    %edx
  80057e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800581:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800584:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800587:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058c:	e9 80 00 00 00       	jmp    800611 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800591:	8d 45 14             	lea    0x14(%ebp),%eax
  800594:	e8 70 fc ff ff       	call   800209 <getuint>
  800599:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80059f:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005a4:	eb 6b                	jmp    800611 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a9:	e8 5b fc ff ff       	call   800209 <getuint>
  8005ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  8005b4:	6a 04                	push   $0x4
  8005b6:	6a 03                	push   $0x3
  8005b8:	6a 01                	push   $0x1
  8005ba:	68 2c 0e 80 00       	push   $0x800e2c
  8005bf:	e8 82 fb ff ff       	call   800146 <cprintf>
			goto number;
  8005c4:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  8005c7:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  8005cc:	eb 43                	jmp    800611 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ce:	83 ec 08             	sub    $0x8,%esp
  8005d1:	53                   	push   %ebx
  8005d2:	6a 30                	push   $0x30
  8005d4:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d6:	83 c4 08             	add    $0x8,%esp
  8005d9:	53                   	push   %ebx
  8005da:	6a 78                	push   $0x78
  8005dc:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 50 04             	lea    0x4(%eax),%edx
  8005e4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005e7:	8b 00                	mov    (%eax),%eax
  8005e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005f4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005f7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005fc:	eb 13                	jmp    800611 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800601:	e8 03 fc ff ff       	call   800209 <getuint>
  800606:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800609:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80060c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800611:	83 ec 0c             	sub    $0xc,%esp
  800614:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800618:	52                   	push   %edx
  800619:	ff 75 e0             	pushl  -0x20(%ebp)
  80061c:	50                   	push   %eax
  80061d:	ff 75 dc             	pushl  -0x24(%ebp)
  800620:	ff 75 d8             	pushl  -0x28(%ebp)
  800623:	89 da                	mov    %ebx,%edx
  800625:	89 f0                	mov    %esi,%eax
  800627:	e8 2e fb ff ff       	call   80015a <printnum>

			break;
  80062c:	83 c4 20             	add    $0x20,%esp
  80062f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800632:	e9 6c fc ff ff       	jmp    8002a3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800637:	83 ec 08             	sub    $0x8,%esp
  80063a:	53                   	push   %ebx
  80063b:	51                   	push   %ecx
  80063c:	ff d6                	call   *%esi
			break;
  80063e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800641:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800644:	e9 5a fc ff ff       	jmp    8002a3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 25                	push   $0x25
  80064f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	eb 03                	jmp    800659 <vprintfmt+0x3dc>
  800656:	83 ef 01             	sub    $0x1,%edi
  800659:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80065d:	75 f7                	jne    800656 <vprintfmt+0x3d9>
  80065f:	e9 3f fc ff ff       	jmp    8002a3 <vprintfmt+0x26>
			break;
		}

	}

}
  800664:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800667:	5b                   	pop    %ebx
  800668:	5e                   	pop    %esi
  800669:	5f                   	pop    %edi
  80066a:	5d                   	pop    %ebp
  80066b:	c3                   	ret    

0080066c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80066c:	55                   	push   %ebp
  80066d:	89 e5                	mov    %esp,%ebp
  80066f:	83 ec 18             	sub    $0x18,%esp
  800672:	8b 45 08             	mov    0x8(%ebp),%eax
  800675:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800678:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80067b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80067f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800682:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800689:	85 c0                	test   %eax,%eax
  80068b:	74 26                	je     8006b3 <vsnprintf+0x47>
  80068d:	85 d2                	test   %edx,%edx
  80068f:	7e 22                	jle    8006b3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800691:	ff 75 14             	pushl  0x14(%ebp)
  800694:	ff 75 10             	pushl  0x10(%ebp)
  800697:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80069a:	50                   	push   %eax
  80069b:	68 43 02 80 00       	push   $0x800243
  8006a0:	e8 d8 fb ff ff       	call   80027d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ae:	83 c4 10             	add    $0x10,%esp
  8006b1:	eb 05                	jmp    8006b8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006b8:	c9                   	leave  
  8006b9:	c3                   	ret    

008006ba <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c3:	50                   	push   %eax
  8006c4:	ff 75 10             	pushl  0x10(%ebp)
  8006c7:	ff 75 0c             	pushl  0xc(%ebp)
  8006ca:	ff 75 08             	pushl  0x8(%ebp)
  8006cd:	e8 9a ff ff ff       	call   80066c <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d2:	c9                   	leave  
  8006d3:	c3                   	ret    

008006d4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006da:	b8 00 00 00 00       	mov    $0x0,%eax
  8006df:	eb 03                	jmp    8006e4 <strlen+0x10>
		n++;
  8006e1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006e8:	75 f7                	jne    8006e1 <strlen+0xd>
		n++;
	return n;
}
  8006ea:	5d                   	pop    %ebp
  8006eb:	c3                   	ret    

008006ec <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8006fa:	eb 03                	jmp    8006ff <strnlen+0x13>
		n++;
  8006fc:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ff:	39 c2                	cmp    %eax,%edx
  800701:	74 08                	je     80070b <strnlen+0x1f>
  800703:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800707:	75 f3                	jne    8006fc <strnlen+0x10>
  800709:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	53                   	push   %ebx
  800711:	8b 45 08             	mov    0x8(%ebp),%eax
  800714:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800717:	89 c2                	mov    %eax,%edx
  800719:	83 c2 01             	add    $0x1,%edx
  80071c:	83 c1 01             	add    $0x1,%ecx
  80071f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800723:	88 5a ff             	mov    %bl,-0x1(%edx)
  800726:	84 db                	test   %bl,%bl
  800728:	75 ef                	jne    800719 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80072a:	5b                   	pop    %ebx
  80072b:	5d                   	pop    %ebp
  80072c:	c3                   	ret    

0080072d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	53                   	push   %ebx
  800731:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800734:	53                   	push   %ebx
  800735:	e8 9a ff ff ff       	call   8006d4 <strlen>
  80073a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80073d:	ff 75 0c             	pushl  0xc(%ebp)
  800740:	01 d8                	add    %ebx,%eax
  800742:	50                   	push   %eax
  800743:	e8 c5 ff ff ff       	call   80070d <strcpy>
	return dst;
}
  800748:	89 d8                	mov    %ebx,%eax
  80074a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80074d:	c9                   	leave  
  80074e:	c3                   	ret    

0080074f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	56                   	push   %esi
  800753:	53                   	push   %ebx
  800754:	8b 75 08             	mov    0x8(%ebp),%esi
  800757:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80075a:	89 f3                	mov    %esi,%ebx
  80075c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075f:	89 f2                	mov    %esi,%edx
  800761:	eb 0f                	jmp    800772 <strncpy+0x23>
		*dst++ = *src;
  800763:	83 c2 01             	add    $0x1,%edx
  800766:	0f b6 01             	movzbl (%ecx),%eax
  800769:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80076c:	80 39 01             	cmpb   $0x1,(%ecx)
  80076f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800772:	39 da                	cmp    %ebx,%edx
  800774:	75 ed                	jne    800763 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800776:	89 f0                	mov    %esi,%eax
  800778:	5b                   	pop    %ebx
  800779:	5e                   	pop    %esi
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	56                   	push   %esi
  800780:	53                   	push   %ebx
  800781:	8b 75 08             	mov    0x8(%ebp),%esi
  800784:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800787:	8b 55 10             	mov    0x10(%ebp),%edx
  80078a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80078c:	85 d2                	test   %edx,%edx
  80078e:	74 21                	je     8007b1 <strlcpy+0x35>
  800790:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800794:	89 f2                	mov    %esi,%edx
  800796:	eb 09                	jmp    8007a1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800798:	83 c2 01             	add    $0x1,%edx
  80079b:	83 c1 01             	add    $0x1,%ecx
  80079e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007a1:	39 c2                	cmp    %eax,%edx
  8007a3:	74 09                	je     8007ae <strlcpy+0x32>
  8007a5:	0f b6 19             	movzbl (%ecx),%ebx
  8007a8:	84 db                	test   %bl,%bl
  8007aa:	75 ec                	jne    800798 <strlcpy+0x1c>
  8007ac:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007ae:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b1:	29 f0                	sub    %esi,%eax
}
  8007b3:	5b                   	pop    %ebx
  8007b4:	5e                   	pop    %esi
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c0:	eb 06                	jmp    8007c8 <strcmp+0x11>
		p++, q++;
  8007c2:	83 c1 01             	add    $0x1,%ecx
  8007c5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c8:	0f b6 01             	movzbl (%ecx),%eax
  8007cb:	84 c0                	test   %al,%al
  8007cd:	74 04                	je     8007d3 <strcmp+0x1c>
  8007cf:	3a 02                	cmp    (%edx),%al
  8007d1:	74 ef                	je     8007c2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d3:	0f b6 c0             	movzbl %al,%eax
  8007d6:	0f b6 12             	movzbl (%edx),%edx
  8007d9:	29 d0                	sub    %edx,%eax
}
  8007db:	5d                   	pop    %ebp
  8007dc:	c3                   	ret    

008007dd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e7:	89 c3                	mov    %eax,%ebx
  8007e9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007ec:	eb 06                	jmp    8007f4 <strncmp+0x17>
		n--, p++, q++;
  8007ee:	83 c0 01             	add    $0x1,%eax
  8007f1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f4:	39 d8                	cmp    %ebx,%eax
  8007f6:	74 15                	je     80080d <strncmp+0x30>
  8007f8:	0f b6 08             	movzbl (%eax),%ecx
  8007fb:	84 c9                	test   %cl,%cl
  8007fd:	74 04                	je     800803 <strncmp+0x26>
  8007ff:	3a 0a                	cmp    (%edx),%cl
  800801:	74 eb                	je     8007ee <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800803:	0f b6 00             	movzbl (%eax),%eax
  800806:	0f b6 12             	movzbl (%edx),%edx
  800809:	29 d0                	sub    %edx,%eax
  80080b:	eb 05                	jmp    800812 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80080d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800812:	5b                   	pop    %ebx
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	8b 45 08             	mov    0x8(%ebp),%eax
  80081b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80081f:	eb 07                	jmp    800828 <strchr+0x13>
		if (*s == c)
  800821:	38 ca                	cmp    %cl,%dl
  800823:	74 0f                	je     800834 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800825:	83 c0 01             	add    $0x1,%eax
  800828:	0f b6 10             	movzbl (%eax),%edx
  80082b:	84 d2                	test   %dl,%dl
  80082d:	75 f2                	jne    800821 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80082f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	8b 45 08             	mov    0x8(%ebp),%eax
  80083c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800840:	eb 03                	jmp    800845 <strfind+0xf>
  800842:	83 c0 01             	add    $0x1,%eax
  800845:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800848:	38 ca                	cmp    %cl,%dl
  80084a:	74 04                	je     800850 <strfind+0x1a>
  80084c:	84 d2                	test   %dl,%dl
  80084e:	75 f2                	jne    800842 <strfind+0xc>
			break;
	return (char *) s;
}
  800850:	5d                   	pop    %ebp
  800851:	c3                   	ret    

00800852 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	57                   	push   %edi
  800856:	56                   	push   %esi
  800857:	53                   	push   %ebx
  800858:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80085e:	85 c9                	test   %ecx,%ecx
  800860:	74 36                	je     800898 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800862:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800868:	75 28                	jne    800892 <memset+0x40>
  80086a:	f6 c1 03             	test   $0x3,%cl
  80086d:	75 23                	jne    800892 <memset+0x40>
		c &= 0xFF;
  80086f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800873:	89 d3                	mov    %edx,%ebx
  800875:	c1 e3 08             	shl    $0x8,%ebx
  800878:	89 d6                	mov    %edx,%esi
  80087a:	c1 e6 18             	shl    $0x18,%esi
  80087d:	89 d0                	mov    %edx,%eax
  80087f:	c1 e0 10             	shl    $0x10,%eax
  800882:	09 f0                	or     %esi,%eax
  800884:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800886:	89 d8                	mov    %ebx,%eax
  800888:	09 d0                	or     %edx,%eax
  80088a:	c1 e9 02             	shr    $0x2,%ecx
  80088d:	fc                   	cld    
  80088e:	f3 ab                	rep stos %eax,%es:(%edi)
  800890:	eb 06                	jmp    800898 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800892:	8b 45 0c             	mov    0xc(%ebp),%eax
  800895:	fc                   	cld    
  800896:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800898:	89 f8                	mov    %edi,%eax
  80089a:	5b                   	pop    %ebx
  80089b:	5e                   	pop    %esi
  80089c:	5f                   	pop    %edi
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	57                   	push   %edi
  8008a3:	56                   	push   %esi
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ad:	39 c6                	cmp    %eax,%esi
  8008af:	73 35                	jae    8008e6 <memmove+0x47>
  8008b1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b4:	39 d0                	cmp    %edx,%eax
  8008b6:	73 2e                	jae    8008e6 <memmove+0x47>
		s += n;
		d += n;
  8008b8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008bb:	89 d6                	mov    %edx,%esi
  8008bd:	09 fe                	or     %edi,%esi
  8008bf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008c5:	75 13                	jne    8008da <memmove+0x3b>
  8008c7:	f6 c1 03             	test   $0x3,%cl
  8008ca:	75 0e                	jne    8008da <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008cc:	83 ef 04             	sub    $0x4,%edi
  8008cf:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d2:	c1 e9 02             	shr    $0x2,%ecx
  8008d5:	fd                   	std    
  8008d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d8:	eb 09                	jmp    8008e3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008da:	83 ef 01             	sub    $0x1,%edi
  8008dd:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008e0:	fd                   	std    
  8008e1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e3:	fc                   	cld    
  8008e4:	eb 1d                	jmp    800903 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e6:	89 f2                	mov    %esi,%edx
  8008e8:	09 c2                	or     %eax,%edx
  8008ea:	f6 c2 03             	test   $0x3,%dl
  8008ed:	75 0f                	jne    8008fe <memmove+0x5f>
  8008ef:	f6 c1 03             	test   $0x3,%cl
  8008f2:	75 0a                	jne    8008fe <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008f4:	c1 e9 02             	shr    $0x2,%ecx
  8008f7:	89 c7                	mov    %eax,%edi
  8008f9:	fc                   	cld    
  8008fa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008fc:	eb 05                	jmp    800903 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008fe:	89 c7                	mov    %eax,%edi
  800900:	fc                   	cld    
  800901:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800903:	5e                   	pop    %esi
  800904:	5f                   	pop    %edi
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80090a:	ff 75 10             	pushl  0x10(%ebp)
  80090d:	ff 75 0c             	pushl  0xc(%ebp)
  800910:	ff 75 08             	pushl  0x8(%ebp)
  800913:	e8 87 ff ff ff       	call   80089f <memmove>
}
  800918:	c9                   	leave  
  800919:	c3                   	ret    

0080091a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	56                   	push   %esi
  80091e:	53                   	push   %ebx
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
  800925:	89 c6                	mov    %eax,%esi
  800927:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092a:	eb 1a                	jmp    800946 <memcmp+0x2c>
		if (*s1 != *s2)
  80092c:	0f b6 08             	movzbl (%eax),%ecx
  80092f:	0f b6 1a             	movzbl (%edx),%ebx
  800932:	38 d9                	cmp    %bl,%cl
  800934:	74 0a                	je     800940 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800936:	0f b6 c1             	movzbl %cl,%eax
  800939:	0f b6 db             	movzbl %bl,%ebx
  80093c:	29 d8                	sub    %ebx,%eax
  80093e:	eb 0f                	jmp    80094f <memcmp+0x35>
		s1++, s2++;
  800940:	83 c0 01             	add    $0x1,%eax
  800943:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800946:	39 f0                	cmp    %esi,%eax
  800948:	75 e2                	jne    80092c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80094a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80094f:	5b                   	pop    %ebx
  800950:	5e                   	pop    %esi
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	53                   	push   %ebx
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80095a:	89 c1                	mov    %eax,%ecx
  80095c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80095f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800963:	eb 0a                	jmp    80096f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800965:	0f b6 10             	movzbl (%eax),%edx
  800968:	39 da                	cmp    %ebx,%edx
  80096a:	74 07                	je     800973 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096c:	83 c0 01             	add    $0x1,%eax
  80096f:	39 c8                	cmp    %ecx,%eax
  800971:	72 f2                	jb     800965 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800973:	5b                   	pop    %ebx
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	57                   	push   %edi
  80097a:	56                   	push   %esi
  80097b:	53                   	push   %ebx
  80097c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800982:	eb 03                	jmp    800987 <strtol+0x11>
		s++;
  800984:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800987:	0f b6 01             	movzbl (%ecx),%eax
  80098a:	3c 20                	cmp    $0x20,%al
  80098c:	74 f6                	je     800984 <strtol+0xe>
  80098e:	3c 09                	cmp    $0x9,%al
  800990:	74 f2                	je     800984 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800992:	3c 2b                	cmp    $0x2b,%al
  800994:	75 0a                	jne    8009a0 <strtol+0x2a>
		s++;
  800996:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800999:	bf 00 00 00 00       	mov    $0x0,%edi
  80099e:	eb 11                	jmp    8009b1 <strtol+0x3b>
  8009a0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009a5:	3c 2d                	cmp    $0x2d,%al
  8009a7:	75 08                	jne    8009b1 <strtol+0x3b>
		s++, neg = 1;
  8009a9:	83 c1 01             	add    $0x1,%ecx
  8009ac:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009b7:	75 15                	jne    8009ce <strtol+0x58>
  8009b9:	80 39 30             	cmpb   $0x30,(%ecx)
  8009bc:	75 10                	jne    8009ce <strtol+0x58>
  8009be:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009c2:	75 7c                	jne    800a40 <strtol+0xca>
		s += 2, base = 16;
  8009c4:	83 c1 02             	add    $0x2,%ecx
  8009c7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009cc:	eb 16                	jmp    8009e4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009ce:	85 db                	test   %ebx,%ebx
  8009d0:	75 12                	jne    8009e4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009d2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009d7:	80 39 30             	cmpb   $0x30,(%ecx)
  8009da:	75 08                	jne    8009e4 <strtol+0x6e>
		s++, base = 8;
  8009dc:	83 c1 01             	add    $0x1,%ecx
  8009df:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009ec:	0f b6 11             	movzbl (%ecx),%edx
  8009ef:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009f2:	89 f3                	mov    %esi,%ebx
  8009f4:	80 fb 09             	cmp    $0x9,%bl
  8009f7:	77 08                	ja     800a01 <strtol+0x8b>
			dig = *s - '0';
  8009f9:	0f be d2             	movsbl %dl,%edx
  8009fc:	83 ea 30             	sub    $0x30,%edx
  8009ff:	eb 22                	jmp    800a23 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a01:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a04:	89 f3                	mov    %esi,%ebx
  800a06:	80 fb 19             	cmp    $0x19,%bl
  800a09:	77 08                	ja     800a13 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a0b:	0f be d2             	movsbl %dl,%edx
  800a0e:	83 ea 57             	sub    $0x57,%edx
  800a11:	eb 10                	jmp    800a23 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a13:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a16:	89 f3                	mov    %esi,%ebx
  800a18:	80 fb 19             	cmp    $0x19,%bl
  800a1b:	77 16                	ja     800a33 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a1d:	0f be d2             	movsbl %dl,%edx
  800a20:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a23:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a26:	7d 0b                	jge    800a33 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a28:	83 c1 01             	add    $0x1,%ecx
  800a2b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a2f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a31:	eb b9                	jmp    8009ec <strtol+0x76>

	if (endptr)
  800a33:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a37:	74 0d                	je     800a46 <strtol+0xd0>
		*endptr = (char *) s;
  800a39:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3c:	89 0e                	mov    %ecx,(%esi)
  800a3e:	eb 06                	jmp    800a46 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a40:	85 db                	test   %ebx,%ebx
  800a42:	74 98                	je     8009dc <strtol+0x66>
  800a44:	eb 9e                	jmp    8009e4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a46:	89 c2                	mov    %eax,%edx
  800a48:	f7 da                	neg    %edx
  800a4a:	85 ff                	test   %edi,%edi
  800a4c:	0f 45 c2             	cmovne %edx,%eax
}
  800a4f:	5b                   	pop    %ebx
  800a50:	5e                   	pop    %esi
  800a51:	5f                   	pop    %edi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a62:	8b 55 08             	mov    0x8(%ebp),%edx
  800a65:	89 c3                	mov    %eax,%ebx
  800a67:	89 c7                	mov    %eax,%edi
  800a69:	89 c6                	mov    %eax,%esi
  800a6b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a6d:	5b                   	pop    %ebx
  800a6e:	5e                   	pop    %esi
  800a6f:	5f                   	pop    %edi
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	57                   	push   %edi
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a78:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800a82:	89 d1                	mov    %edx,%ecx
  800a84:	89 d3                	mov    %edx,%ebx
  800a86:	89 d7                	mov    %edx,%edi
  800a88:	89 d6                	mov    %edx,%esi
  800a8a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5f                   	pop    %edi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	57                   	push   %edi
  800a95:	56                   	push   %esi
  800a96:	53                   	push   %ebx
  800a97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9f:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa4:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa7:	89 cb                	mov    %ecx,%ebx
  800aa9:	89 cf                	mov    %ecx,%edi
  800aab:	89 ce                	mov    %ecx,%esi
  800aad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aaf:	85 c0                	test   %eax,%eax
  800ab1:	7e 17                	jle    800aca <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab3:	83 ec 0c             	sub    $0xc,%esp
  800ab6:	50                   	push   %eax
  800ab7:	6a 03                	push   $0x3
  800ab9:	68 40 10 80 00       	push   $0x801040
  800abe:	6a 23                	push   $0x23
  800ac0:	68 5d 10 80 00       	push   $0x80105d
  800ac5:	e8 27 00 00 00       	call   800af1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800acd:	5b                   	pop    %ebx
  800ace:	5e                   	pop    %esi
  800acf:	5f                   	pop    %edi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	57                   	push   %edi
  800ad6:	56                   	push   %esi
  800ad7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad8:	ba 00 00 00 00       	mov    $0x0,%edx
  800add:	b8 02 00 00 00       	mov    $0x2,%eax
  800ae2:	89 d1                	mov    %edx,%ecx
  800ae4:	89 d3                	mov    %edx,%ebx
  800ae6:	89 d7                	mov    %edx,%edi
  800ae8:	89 d6                	mov    %edx,%esi
  800aea:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5f                   	pop    %edi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800af6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800af9:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800aff:	e8 ce ff ff ff       	call   800ad2 <sys_getenvid>
  800b04:	83 ec 0c             	sub    $0xc,%esp
  800b07:	ff 75 0c             	pushl  0xc(%ebp)
  800b0a:	ff 75 08             	pushl  0x8(%ebp)
  800b0d:	56                   	push   %esi
  800b0e:	50                   	push   %eax
  800b0f:	68 6c 10 80 00       	push   $0x80106c
  800b14:	e8 2d f6 ff ff       	call   800146 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b19:	83 c4 18             	add    $0x18,%esp
  800b1c:	53                   	push   %ebx
  800b1d:	ff 75 10             	pushl  0x10(%ebp)
  800b20:	e8 d0 f5 ff ff       	call   8000f5 <vcprintf>
	cprintf("\n");
  800b25:	c7 04 24 fc 0d 80 00 	movl   $0x800dfc,(%esp)
  800b2c:	e8 15 f6 ff ff       	call   800146 <cprintf>
  800b31:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b34:	cc                   	int3   
  800b35:	eb fd                	jmp    800b34 <_panic+0x43>
  800b37:	66 90                	xchg   %ax,%ax
  800b39:	66 90                	xchg   %ax,%ax
  800b3b:	66 90                	xchg   %ax,%ax
  800b3d:	66 90                	xchg   %ax,%ax
  800b3f:	90                   	nop

00800b40 <__udivdi3>:
  800b40:	55                   	push   %ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	83 ec 1c             	sub    $0x1c,%esp
  800b47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800b4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800b4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800b53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b57:	85 f6                	test   %esi,%esi
  800b59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b5d:	89 ca                	mov    %ecx,%edx
  800b5f:	89 f8                	mov    %edi,%eax
  800b61:	75 3d                	jne    800ba0 <__udivdi3+0x60>
  800b63:	39 cf                	cmp    %ecx,%edi
  800b65:	0f 87 c5 00 00 00    	ja     800c30 <__udivdi3+0xf0>
  800b6b:	85 ff                	test   %edi,%edi
  800b6d:	89 fd                	mov    %edi,%ebp
  800b6f:	75 0b                	jne    800b7c <__udivdi3+0x3c>
  800b71:	b8 01 00 00 00       	mov    $0x1,%eax
  800b76:	31 d2                	xor    %edx,%edx
  800b78:	f7 f7                	div    %edi
  800b7a:	89 c5                	mov    %eax,%ebp
  800b7c:	89 c8                	mov    %ecx,%eax
  800b7e:	31 d2                	xor    %edx,%edx
  800b80:	f7 f5                	div    %ebp
  800b82:	89 c1                	mov    %eax,%ecx
  800b84:	89 d8                	mov    %ebx,%eax
  800b86:	89 cf                	mov    %ecx,%edi
  800b88:	f7 f5                	div    %ebp
  800b8a:	89 c3                	mov    %eax,%ebx
  800b8c:	89 d8                	mov    %ebx,%eax
  800b8e:	89 fa                	mov    %edi,%edx
  800b90:	83 c4 1c             	add    $0x1c,%esp
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    
  800b98:	90                   	nop
  800b99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ba0:	39 ce                	cmp    %ecx,%esi
  800ba2:	77 74                	ja     800c18 <__udivdi3+0xd8>
  800ba4:	0f bd fe             	bsr    %esi,%edi
  800ba7:	83 f7 1f             	xor    $0x1f,%edi
  800baa:	0f 84 98 00 00 00    	je     800c48 <__udivdi3+0x108>
  800bb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800bb5:	89 f9                	mov    %edi,%ecx
  800bb7:	89 c5                	mov    %eax,%ebp
  800bb9:	29 fb                	sub    %edi,%ebx
  800bbb:	d3 e6                	shl    %cl,%esi
  800bbd:	89 d9                	mov    %ebx,%ecx
  800bbf:	d3 ed                	shr    %cl,%ebp
  800bc1:	89 f9                	mov    %edi,%ecx
  800bc3:	d3 e0                	shl    %cl,%eax
  800bc5:	09 ee                	or     %ebp,%esi
  800bc7:	89 d9                	mov    %ebx,%ecx
  800bc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bcd:	89 d5                	mov    %edx,%ebp
  800bcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800bd3:	d3 ed                	shr    %cl,%ebp
  800bd5:	89 f9                	mov    %edi,%ecx
  800bd7:	d3 e2                	shl    %cl,%edx
  800bd9:	89 d9                	mov    %ebx,%ecx
  800bdb:	d3 e8                	shr    %cl,%eax
  800bdd:	09 c2                	or     %eax,%edx
  800bdf:	89 d0                	mov    %edx,%eax
  800be1:	89 ea                	mov    %ebp,%edx
  800be3:	f7 f6                	div    %esi
  800be5:	89 d5                	mov    %edx,%ebp
  800be7:	89 c3                	mov    %eax,%ebx
  800be9:	f7 64 24 0c          	mull   0xc(%esp)
  800bed:	39 d5                	cmp    %edx,%ebp
  800bef:	72 10                	jb     800c01 <__udivdi3+0xc1>
  800bf1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800bf5:	89 f9                	mov    %edi,%ecx
  800bf7:	d3 e6                	shl    %cl,%esi
  800bf9:	39 c6                	cmp    %eax,%esi
  800bfb:	73 07                	jae    800c04 <__udivdi3+0xc4>
  800bfd:	39 d5                	cmp    %edx,%ebp
  800bff:	75 03                	jne    800c04 <__udivdi3+0xc4>
  800c01:	83 eb 01             	sub    $0x1,%ebx
  800c04:	31 ff                	xor    %edi,%edi
  800c06:	89 d8                	mov    %ebx,%eax
  800c08:	89 fa                	mov    %edi,%edx
  800c0a:	83 c4 1c             	add    $0x1c,%esp
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    
  800c12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c18:	31 ff                	xor    %edi,%edi
  800c1a:	31 db                	xor    %ebx,%ebx
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
  800c30:	89 d8                	mov    %ebx,%eax
  800c32:	f7 f7                	div    %edi
  800c34:	31 ff                	xor    %edi,%edi
  800c36:	89 c3                	mov    %eax,%ebx
  800c38:	89 d8                	mov    %ebx,%eax
  800c3a:	89 fa                	mov    %edi,%edx
  800c3c:	83 c4 1c             	add    $0x1c,%esp
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    
  800c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c48:	39 ce                	cmp    %ecx,%esi
  800c4a:	72 0c                	jb     800c58 <__udivdi3+0x118>
  800c4c:	31 db                	xor    %ebx,%ebx
  800c4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800c52:	0f 87 34 ff ff ff    	ja     800b8c <__udivdi3+0x4c>
  800c58:	bb 01 00 00 00       	mov    $0x1,%ebx
  800c5d:	e9 2a ff ff ff       	jmp    800b8c <__udivdi3+0x4c>
  800c62:	66 90                	xchg   %ax,%ax
  800c64:	66 90                	xchg   %ax,%ax
  800c66:	66 90                	xchg   %ax,%ax
  800c68:	66 90                	xchg   %ax,%ax
  800c6a:	66 90                	xchg   %ax,%ax
  800c6c:	66 90                	xchg   %ax,%ax
  800c6e:	66 90                	xchg   %ax,%ax

00800c70 <__umoddi3>:
  800c70:	55                   	push   %ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 1c             	sub    $0x1c,%esp
  800c77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c87:	85 d2                	test   %edx,%edx
  800c89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c91:	89 f3                	mov    %esi,%ebx
  800c93:	89 3c 24             	mov    %edi,(%esp)
  800c96:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c9a:	75 1c                	jne    800cb8 <__umoddi3+0x48>
  800c9c:	39 f7                	cmp    %esi,%edi
  800c9e:	76 50                	jbe    800cf0 <__umoddi3+0x80>
  800ca0:	89 c8                	mov    %ecx,%eax
  800ca2:	89 f2                	mov    %esi,%edx
  800ca4:	f7 f7                	div    %edi
  800ca6:	89 d0                	mov    %edx,%eax
  800ca8:	31 d2                	xor    %edx,%edx
  800caa:	83 c4 1c             	add    $0x1c,%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    
  800cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cb8:	39 f2                	cmp    %esi,%edx
  800cba:	89 d0                	mov    %edx,%eax
  800cbc:	77 52                	ja     800d10 <__umoddi3+0xa0>
  800cbe:	0f bd ea             	bsr    %edx,%ebp
  800cc1:	83 f5 1f             	xor    $0x1f,%ebp
  800cc4:	75 5a                	jne    800d20 <__umoddi3+0xb0>
  800cc6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800cca:	0f 82 e0 00 00 00    	jb     800db0 <__umoddi3+0x140>
  800cd0:	39 0c 24             	cmp    %ecx,(%esp)
  800cd3:	0f 86 d7 00 00 00    	jbe    800db0 <__umoddi3+0x140>
  800cd9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800cdd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ce1:	83 c4 1c             	add    $0x1c,%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    
  800ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cf0:	85 ff                	test   %edi,%edi
  800cf2:	89 fd                	mov    %edi,%ebp
  800cf4:	75 0b                	jne    800d01 <__umoddi3+0x91>
  800cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfb:	31 d2                	xor    %edx,%edx
  800cfd:	f7 f7                	div    %edi
  800cff:	89 c5                	mov    %eax,%ebp
  800d01:	89 f0                	mov    %esi,%eax
  800d03:	31 d2                	xor    %edx,%edx
  800d05:	f7 f5                	div    %ebp
  800d07:	89 c8                	mov    %ecx,%eax
  800d09:	f7 f5                	div    %ebp
  800d0b:	89 d0                	mov    %edx,%eax
  800d0d:	eb 99                	jmp    800ca8 <__umoddi3+0x38>
  800d0f:	90                   	nop
  800d10:	89 c8                	mov    %ecx,%eax
  800d12:	89 f2                	mov    %esi,%edx
  800d14:	83 c4 1c             	add    $0x1c,%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    
  800d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d20:	8b 34 24             	mov    (%esp),%esi
  800d23:	bf 20 00 00 00       	mov    $0x20,%edi
  800d28:	89 e9                	mov    %ebp,%ecx
  800d2a:	29 ef                	sub    %ebp,%edi
  800d2c:	d3 e0                	shl    %cl,%eax
  800d2e:	89 f9                	mov    %edi,%ecx
  800d30:	89 f2                	mov    %esi,%edx
  800d32:	d3 ea                	shr    %cl,%edx
  800d34:	89 e9                	mov    %ebp,%ecx
  800d36:	09 c2                	or     %eax,%edx
  800d38:	89 d8                	mov    %ebx,%eax
  800d3a:	89 14 24             	mov    %edx,(%esp)
  800d3d:	89 f2                	mov    %esi,%edx
  800d3f:	d3 e2                	shl    %cl,%edx
  800d41:	89 f9                	mov    %edi,%ecx
  800d43:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d4b:	d3 e8                	shr    %cl,%eax
  800d4d:	89 e9                	mov    %ebp,%ecx
  800d4f:	89 c6                	mov    %eax,%esi
  800d51:	d3 e3                	shl    %cl,%ebx
  800d53:	89 f9                	mov    %edi,%ecx
  800d55:	89 d0                	mov    %edx,%eax
  800d57:	d3 e8                	shr    %cl,%eax
  800d59:	89 e9                	mov    %ebp,%ecx
  800d5b:	09 d8                	or     %ebx,%eax
  800d5d:	89 d3                	mov    %edx,%ebx
  800d5f:	89 f2                	mov    %esi,%edx
  800d61:	f7 34 24             	divl   (%esp)
  800d64:	89 d6                	mov    %edx,%esi
  800d66:	d3 e3                	shl    %cl,%ebx
  800d68:	f7 64 24 04          	mull   0x4(%esp)
  800d6c:	39 d6                	cmp    %edx,%esi
  800d6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d72:	89 d1                	mov    %edx,%ecx
  800d74:	89 c3                	mov    %eax,%ebx
  800d76:	72 08                	jb     800d80 <__umoddi3+0x110>
  800d78:	75 11                	jne    800d8b <__umoddi3+0x11b>
  800d7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800d7e:	73 0b                	jae    800d8b <__umoddi3+0x11b>
  800d80:	2b 44 24 04          	sub    0x4(%esp),%eax
  800d84:	1b 14 24             	sbb    (%esp),%edx
  800d87:	89 d1                	mov    %edx,%ecx
  800d89:	89 c3                	mov    %eax,%ebx
  800d8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800d8f:	29 da                	sub    %ebx,%edx
  800d91:	19 ce                	sbb    %ecx,%esi
  800d93:	89 f9                	mov    %edi,%ecx
  800d95:	89 f0                	mov    %esi,%eax
  800d97:	d3 e0                	shl    %cl,%eax
  800d99:	89 e9                	mov    %ebp,%ecx
  800d9b:	d3 ea                	shr    %cl,%edx
  800d9d:	89 e9                	mov    %ebp,%ecx
  800d9f:	d3 ee                	shr    %cl,%esi
  800da1:	09 d0                	or     %edx,%eax
  800da3:	89 f2                	mov    %esi,%edx
  800da5:	83 c4 1c             	add    $0x1c,%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    
  800dad:	8d 76 00             	lea    0x0(%esi),%esi
  800db0:	29 f9                	sub    %edi,%ecx
  800db2:	19 d6                	sbb    %edx,%esi
  800db4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800db8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dbc:	e9 18 ff ff ff       	jmp    800cd9 <__umoddi3+0x69>
