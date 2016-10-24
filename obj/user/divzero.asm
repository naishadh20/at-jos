
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
  800051:	68 e0 0d 80 00       	push   $0x800de0
  800056:	e8 fd 00 00 00       	call   800158 <cprintf>
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
  800075:	e8 6a 0a 00 00       	call   800ae4 <sys_getenvid>
  80007a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007f:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800082:	c1 e0 05             	shl    $0x5,%eax
  800085:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008a:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008f:	85 db                	test   %ebx,%ebx
  800091:	7e 07                	jle    80009a <libmain+0x3a>
		binaryname = argv[0];
  800093:	8b 06                	mov    (%esi),%eax
  800095:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009a:	83 ec 08             	sub    $0x8,%esp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	e8 8f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a4:	e8 0a 00 00 00       	call   8000b3 <exit>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    

008000b3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 e3 09 00 00       	call   800aa3 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	53                   	push   %ebx
  8000c9:	83 ec 04             	sub    $0x4,%esp
  8000cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000cf:	8b 13                	mov    (%ebx),%edx
  8000d1:	8d 42 01             	lea    0x1(%edx),%eax
  8000d4:	89 03                	mov    %eax,(%ebx)
  8000d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000dd:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e2:	75 1a                	jne    8000fe <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000e4:	83 ec 08             	sub    $0x8,%esp
  8000e7:	68 ff 00 00 00       	push   $0xff
  8000ec:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ef:	50                   	push   %eax
  8000f0:	e8 71 09 00 00       	call   800a66 <sys_cputs>
		b->idx = 0;
  8000f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000fb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000fe:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800102:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800105:	c9                   	leave  
  800106:	c3                   	ret    

00800107 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800110:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800117:	00 00 00 
	b.cnt = 0;
  80011a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800121:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800124:	ff 75 0c             	pushl  0xc(%ebp)
  800127:	ff 75 08             	pushl  0x8(%ebp)
  80012a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800130:	50                   	push   %eax
  800131:	68 c5 00 80 00       	push   $0x8000c5
  800136:	e8 54 01 00 00       	call   80028f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80013b:	83 c4 08             	add    $0x8,%esp
  80013e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800144:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80014a:	50                   	push   %eax
  80014b:	e8 16 09 00 00       	call   800a66 <sys_cputs>

	return b.cnt;
}
  800150:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800161:	50                   	push   %eax
  800162:	ff 75 08             	pushl  0x8(%ebp)
  800165:	e8 9d ff ff ff       	call   800107 <vcprintf>
	va_end(ap);

	return cnt;
}
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	57                   	push   %edi
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
  800172:	83 ec 1c             	sub    $0x1c,%esp
  800175:	89 c7                	mov    %eax,%edi
  800177:	89 d6                	mov    %edx,%esi
  800179:	8b 45 08             	mov    0x8(%ebp),%eax
  80017c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800182:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800185:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800188:	bb 00 00 00 00       	mov    $0x0,%ebx
  80018d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800190:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800193:	39 d3                	cmp    %edx,%ebx
  800195:	72 05                	jb     80019c <printnum+0x30>
  800197:	39 45 10             	cmp    %eax,0x10(%ebp)
  80019a:	77 45                	ja     8001e1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019c:	83 ec 0c             	sub    $0xc,%esp
  80019f:	ff 75 18             	pushl  0x18(%ebp)
  8001a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a8:	53                   	push   %ebx
  8001a9:	ff 75 10             	pushl  0x10(%ebp)
  8001ac:	83 ec 08             	sub    $0x8,%esp
  8001af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8001bb:	e8 90 09 00 00       	call   800b50 <__udivdi3>
  8001c0:	83 c4 18             	add    $0x18,%esp
  8001c3:	52                   	push   %edx
  8001c4:	50                   	push   %eax
  8001c5:	89 f2                	mov    %esi,%edx
  8001c7:	89 f8                	mov    %edi,%eax
  8001c9:	e8 9e ff ff ff       	call   80016c <printnum>
  8001ce:	83 c4 20             	add    $0x20,%esp
  8001d1:	eb 18                	jmp    8001eb <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d3:	83 ec 08             	sub    $0x8,%esp
  8001d6:	56                   	push   %esi
  8001d7:	ff 75 18             	pushl  0x18(%ebp)
  8001da:	ff d7                	call   *%edi
  8001dc:	83 c4 10             	add    $0x10,%esp
  8001df:	eb 03                	jmp    8001e4 <printnum+0x78>
  8001e1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001e4:	83 eb 01             	sub    $0x1,%ebx
  8001e7:	85 db                	test   %ebx,%ebx
  8001e9:	7f e8                	jg     8001d3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	56                   	push   %esi
  8001ef:	83 ec 04             	sub    $0x4,%esp
  8001f2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001fb:	ff 75 d8             	pushl  -0x28(%ebp)
  8001fe:	e8 7d 0a 00 00       	call   800c80 <__umoddi3>
  800203:	83 c4 14             	add    $0x14,%esp
  800206:	0f be 80 f8 0d 80 00 	movsbl 0x800df8(%eax),%eax
  80020d:	50                   	push   %eax
  80020e:	ff d7                	call   *%edi
}
  800210:	83 c4 10             	add    $0x10,%esp
  800213:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800216:	5b                   	pop    %ebx
  800217:	5e                   	pop    %esi
  800218:	5f                   	pop    %edi
  800219:	5d                   	pop    %ebp
  80021a:	c3                   	ret    

0080021b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80021e:	83 fa 01             	cmp    $0x1,%edx
  800221:	7e 0e                	jle    800231 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800223:	8b 10                	mov    (%eax),%edx
  800225:	8d 4a 08             	lea    0x8(%edx),%ecx
  800228:	89 08                	mov    %ecx,(%eax)
  80022a:	8b 02                	mov    (%edx),%eax
  80022c:	8b 52 04             	mov    0x4(%edx),%edx
  80022f:	eb 22                	jmp    800253 <getuint+0x38>
	else if (lflag)
  800231:	85 d2                	test   %edx,%edx
  800233:	74 10                	je     800245 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800235:	8b 10                	mov    (%eax),%edx
  800237:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023a:	89 08                	mov    %ecx,(%eax)
  80023c:	8b 02                	mov    (%edx),%eax
  80023e:	ba 00 00 00 00       	mov    $0x0,%edx
  800243:	eb 0e                	jmp    800253 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800245:	8b 10                	mov    (%eax),%edx
  800247:	8d 4a 04             	lea    0x4(%edx),%ecx
  80024a:	89 08                	mov    %ecx,(%eax)
  80024c:	8b 02                	mov    (%edx),%eax
  80024e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    

00800255 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80025b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025f:	8b 10                	mov    (%eax),%edx
  800261:	3b 50 04             	cmp    0x4(%eax),%edx
  800264:	73 0a                	jae    800270 <sprintputch+0x1b>
		*b->buf++ = ch;
  800266:	8d 4a 01             	lea    0x1(%edx),%ecx
  800269:	89 08                	mov    %ecx,(%eax)
  80026b:	8b 45 08             	mov    0x8(%ebp),%eax
  80026e:	88 02                	mov    %al,(%edx)
}
  800270:	5d                   	pop    %ebp
  800271:	c3                   	ret    

00800272 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800278:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027b:	50                   	push   %eax
  80027c:	ff 75 10             	pushl  0x10(%ebp)
  80027f:	ff 75 0c             	pushl  0xc(%ebp)
  800282:	ff 75 08             	pushl  0x8(%ebp)
  800285:	e8 05 00 00 00       	call   80028f <vprintfmt>
	va_end(ap);
}
  80028a:	83 c4 10             	add    $0x10,%esp
  80028d:	c9                   	leave  
  80028e:	c3                   	ret    

0080028f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	57                   	push   %edi
  800293:	56                   	push   %esi
  800294:	53                   	push   %ebx
  800295:	83 ec 2c             	sub    $0x2c,%esp
  800298:	8b 75 08             	mov    0x8(%ebp),%esi
  80029b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80029e:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a1:	eb 12                	jmp    8002b5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002a3:	85 c0                	test   %eax,%eax
  8002a5:	0f 84 cb 03 00 00    	je     800676 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  8002ab:	83 ec 08             	sub    $0x8,%esp
  8002ae:	53                   	push   %ebx
  8002af:	50                   	push   %eax
  8002b0:	ff d6                	call   *%esi
  8002b2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b5:	83 c7 01             	add    $0x1,%edi
  8002b8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002bc:	83 f8 25             	cmp    $0x25,%eax
  8002bf:	75 e2                	jne    8002a3 <vprintfmt+0x14>
  8002c1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002cc:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002d3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002da:	ba 00 00 00 00       	mov    $0x0,%edx
  8002df:	eb 07                	jmp    8002e8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002e4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e8:	8d 47 01             	lea    0x1(%edi),%eax
  8002eb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ee:	0f b6 07             	movzbl (%edi),%eax
  8002f1:	0f b6 c8             	movzbl %al,%ecx
  8002f4:	83 e8 23             	sub    $0x23,%eax
  8002f7:	3c 55                	cmp    $0x55,%al
  8002f9:	0f 87 5c 03 00 00    	ja     80065b <vprintfmt+0x3cc>
  8002ff:	0f b6 c0             	movzbl %al,%eax
  800302:	ff 24 85 a0 0e 80 00 	jmp    *0x800ea0(,%eax,4)
  800309:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80030c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800310:	eb d6                	jmp    8002e8 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800312:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800315:	b8 00 00 00 00       	mov    $0x0,%eax
  80031a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80031d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800320:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800324:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800327:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80032a:	83 fa 09             	cmp    $0x9,%edx
  80032d:	77 39                	ja     800368 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80032f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800332:	eb e9                	jmp    80031d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800334:	8b 45 14             	mov    0x14(%ebp),%eax
  800337:	8d 48 04             	lea    0x4(%eax),%ecx
  80033a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80033d:	8b 00                	mov    (%eax),%eax
  80033f:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800345:	eb 27                	jmp    80036e <vprintfmt+0xdf>
  800347:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034a:	85 c0                	test   %eax,%eax
  80034c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800351:	0f 49 c8             	cmovns %eax,%ecx
  800354:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035a:	eb 8c                	jmp    8002e8 <vprintfmt+0x59>
  80035c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80035f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800366:	eb 80                	jmp    8002e8 <vprintfmt+0x59>
  800368:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80036b:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80036e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800372:	0f 89 70 ff ff ff    	jns    8002e8 <vprintfmt+0x59>
				width = precision, precision = -1;
  800378:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80037b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037e:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800385:	e9 5e ff ff ff       	jmp    8002e8 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80038a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800390:	e9 53 ff ff ff       	jmp    8002e8 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800395:	8b 45 14             	mov    0x14(%ebp),%eax
  800398:	8d 50 04             	lea    0x4(%eax),%edx
  80039b:	89 55 14             	mov    %edx,0x14(%ebp)
  80039e:	83 ec 08             	sub    $0x8,%esp
  8003a1:	53                   	push   %ebx
  8003a2:	ff 30                	pushl  (%eax)
  8003a4:	ff d6                	call   *%esi
			break;
  8003a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ac:	e9 04 ff ff ff       	jmp    8002b5 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	8d 50 04             	lea    0x4(%eax),%edx
  8003b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ba:	8b 00                	mov    (%eax),%eax
  8003bc:	99                   	cltd   
  8003bd:	31 d0                	xor    %edx,%eax
  8003bf:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c1:	83 f8 07             	cmp    $0x7,%eax
  8003c4:	7f 0b                	jg     8003d1 <vprintfmt+0x142>
  8003c6:	8b 14 85 00 10 80 00 	mov    0x801000(,%eax,4),%edx
  8003cd:	85 d2                	test   %edx,%edx
  8003cf:	75 18                	jne    8003e9 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003d1:	50                   	push   %eax
  8003d2:	68 10 0e 80 00       	push   $0x800e10
  8003d7:	53                   	push   %ebx
  8003d8:	56                   	push   %esi
  8003d9:	e8 94 fe ff ff       	call   800272 <printfmt>
  8003de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003e4:	e9 cc fe ff ff       	jmp    8002b5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003e9:	52                   	push   %edx
  8003ea:	68 19 0e 80 00       	push   $0x800e19
  8003ef:	53                   	push   %ebx
  8003f0:	56                   	push   %esi
  8003f1:	e8 7c fe ff ff       	call   800272 <printfmt>
  8003f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fc:	e9 b4 fe ff ff       	jmp    8002b5 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	8d 50 04             	lea    0x4(%eax),%edx
  800407:	89 55 14             	mov    %edx,0x14(%ebp)
  80040a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80040c:	85 ff                	test   %edi,%edi
  80040e:	b8 09 0e 80 00       	mov    $0x800e09,%eax
  800413:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800416:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041a:	0f 8e 94 00 00 00    	jle    8004b4 <vprintfmt+0x225>
  800420:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800424:	0f 84 98 00 00 00    	je     8004c2 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	ff 75 c8             	pushl  -0x38(%ebp)
  800430:	57                   	push   %edi
  800431:	e8 c8 02 00 00       	call   8006fe <strnlen>
  800436:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800439:	29 c1                	sub    %eax,%ecx
  80043b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80043e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800441:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800445:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800448:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80044b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80044d:	eb 0f                	jmp    80045e <vprintfmt+0x1cf>
					putch(padc, putdat);
  80044f:	83 ec 08             	sub    $0x8,%esp
  800452:	53                   	push   %ebx
  800453:	ff 75 e0             	pushl  -0x20(%ebp)
  800456:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800458:	83 ef 01             	sub    $0x1,%edi
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	85 ff                	test   %edi,%edi
  800460:	7f ed                	jg     80044f <vprintfmt+0x1c0>
  800462:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800465:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800468:	85 c9                	test   %ecx,%ecx
  80046a:	b8 00 00 00 00       	mov    $0x0,%eax
  80046f:	0f 49 c1             	cmovns %ecx,%eax
  800472:	29 c1                	sub    %eax,%ecx
  800474:	89 75 08             	mov    %esi,0x8(%ebp)
  800477:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80047a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80047d:	89 cb                	mov    %ecx,%ebx
  80047f:	eb 4d                	jmp    8004ce <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800481:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800485:	74 1b                	je     8004a2 <vprintfmt+0x213>
  800487:	0f be c0             	movsbl %al,%eax
  80048a:	83 e8 20             	sub    $0x20,%eax
  80048d:	83 f8 5e             	cmp    $0x5e,%eax
  800490:	76 10                	jbe    8004a2 <vprintfmt+0x213>
					putch('?', putdat);
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	ff 75 0c             	pushl  0xc(%ebp)
  800498:	6a 3f                	push   $0x3f
  80049a:	ff 55 08             	call   *0x8(%ebp)
  80049d:	83 c4 10             	add    $0x10,%esp
  8004a0:	eb 0d                	jmp    8004af <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	ff 75 0c             	pushl  0xc(%ebp)
  8004a8:	52                   	push   %edx
  8004a9:	ff 55 08             	call   *0x8(%ebp)
  8004ac:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004af:	83 eb 01             	sub    $0x1,%ebx
  8004b2:	eb 1a                	jmp    8004ce <vprintfmt+0x23f>
  8004b4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b7:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004ba:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004bd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c0:	eb 0c                	jmp    8004ce <vprintfmt+0x23f>
  8004c2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c5:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004c8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ce:	83 c7 01             	add    $0x1,%edi
  8004d1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d5:	0f be d0             	movsbl %al,%edx
  8004d8:	85 d2                	test   %edx,%edx
  8004da:	74 23                	je     8004ff <vprintfmt+0x270>
  8004dc:	85 f6                	test   %esi,%esi
  8004de:	78 a1                	js     800481 <vprintfmt+0x1f2>
  8004e0:	83 ee 01             	sub    $0x1,%esi
  8004e3:	79 9c                	jns    800481 <vprintfmt+0x1f2>
  8004e5:	89 df                	mov    %ebx,%edi
  8004e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ed:	eb 18                	jmp    800507 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	53                   	push   %ebx
  8004f3:	6a 20                	push   $0x20
  8004f5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f7:	83 ef 01             	sub    $0x1,%edi
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	eb 08                	jmp    800507 <vprintfmt+0x278>
  8004ff:	89 df                	mov    %ebx,%edi
  800501:	8b 75 08             	mov    0x8(%ebp),%esi
  800504:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800507:	85 ff                	test   %edi,%edi
  800509:	7f e4                	jg     8004ef <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050e:	e9 a2 fd ff ff       	jmp    8002b5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800513:	83 fa 01             	cmp    $0x1,%edx
  800516:	7e 16                	jle    80052e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 50 08             	lea    0x8(%eax),%edx
  80051e:	89 55 14             	mov    %edx,0x14(%ebp)
  800521:	8b 50 04             	mov    0x4(%eax),%edx
  800524:	8b 00                	mov    (%eax),%eax
  800526:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800529:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80052c:	eb 32                	jmp    800560 <vprintfmt+0x2d1>
	else if (lflag)
  80052e:	85 d2                	test   %edx,%edx
  800530:	74 18                	je     80054a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800532:	8b 45 14             	mov    0x14(%ebp),%eax
  800535:	8d 50 04             	lea    0x4(%eax),%edx
  800538:	89 55 14             	mov    %edx,0x14(%ebp)
  80053b:	8b 00                	mov    (%eax),%eax
  80053d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800540:	89 c1                	mov    %eax,%ecx
  800542:	c1 f9 1f             	sar    $0x1f,%ecx
  800545:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800548:	eb 16                	jmp    800560 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800558:	89 c1                	mov    %eax,%ecx
  80055a:	c1 f9 1f             	sar    $0x1f,%ecx
  80055d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800560:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800563:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800566:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800569:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80056c:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800571:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800575:	0f 89 a8 00 00 00    	jns    800623 <vprintfmt+0x394>
				putch('-', putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	53                   	push   %ebx
  80057f:	6a 2d                	push   $0x2d
  800581:	ff d6                	call   *%esi
				num = -(long long) num;
  800583:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800586:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800589:	f7 d8                	neg    %eax
  80058b:	83 d2 00             	adc    $0x0,%edx
  80058e:	f7 da                	neg    %edx
  800590:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800593:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800596:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800599:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059e:	e9 80 00 00 00       	jmp    800623 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a6:	e8 70 fc ff ff       	call   80021b <getuint>
  8005ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005b1:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005b6:	eb 6b                	jmp    800623 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bb:	e8 5b fc ff ff       	call   80021b <getuint>
  8005c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  8005c6:	6a 04                	push   $0x4
  8005c8:	6a 03                	push   $0x3
  8005ca:	6a 01                	push   $0x1
  8005cc:	68 1c 0e 80 00       	push   $0x800e1c
  8005d1:	e8 82 fb ff ff       	call   800158 <cprintf>
			goto number;
  8005d6:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  8005d9:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  8005de:	eb 43                	jmp    800623 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e0:	83 ec 08             	sub    $0x8,%esp
  8005e3:	53                   	push   %ebx
  8005e4:	6a 30                	push   $0x30
  8005e6:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e8:	83 c4 08             	add    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	6a 78                	push   $0x78
  8005ee:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8d 50 04             	lea    0x4(%eax),%edx
  8005f6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005f9:	8b 00                	mov    (%eax),%eax
  8005fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800600:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800603:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800606:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800609:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80060e:	eb 13                	jmp    800623 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800610:	8d 45 14             	lea    0x14(%ebp),%eax
  800613:	e8 03 fc ff ff       	call   80021b <getuint>
  800618:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80061e:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800623:	83 ec 0c             	sub    $0xc,%esp
  800626:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80062a:	52                   	push   %edx
  80062b:	ff 75 e0             	pushl  -0x20(%ebp)
  80062e:	50                   	push   %eax
  80062f:	ff 75 dc             	pushl  -0x24(%ebp)
  800632:	ff 75 d8             	pushl  -0x28(%ebp)
  800635:	89 da                	mov    %ebx,%edx
  800637:	89 f0                	mov    %esi,%eax
  800639:	e8 2e fb ff ff       	call   80016c <printnum>

			break;
  80063e:	83 c4 20             	add    $0x20,%esp
  800641:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800644:	e9 6c fc ff ff       	jmp    8002b5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	51                   	push   %ecx
  80064e:	ff d6                	call   *%esi
			break;
  800650:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800653:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800656:	e9 5a fc ff ff       	jmp    8002b5 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	53                   	push   %ebx
  80065f:	6a 25                	push   $0x25
  800661:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800663:	83 c4 10             	add    $0x10,%esp
  800666:	eb 03                	jmp    80066b <vprintfmt+0x3dc>
  800668:	83 ef 01             	sub    $0x1,%edi
  80066b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80066f:	75 f7                	jne    800668 <vprintfmt+0x3d9>
  800671:	e9 3f fc ff ff       	jmp    8002b5 <vprintfmt+0x26>
			break;
		}

	}

}
  800676:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800679:	5b                   	pop    %ebx
  80067a:	5e                   	pop    %esi
  80067b:	5f                   	pop    %edi
  80067c:	5d                   	pop    %ebp
  80067d:	c3                   	ret    

0080067e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80067e:	55                   	push   %ebp
  80067f:	89 e5                	mov    %esp,%ebp
  800681:	83 ec 18             	sub    $0x18,%esp
  800684:	8b 45 08             	mov    0x8(%ebp),%eax
  800687:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80068a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80068d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800691:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800694:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80069b:	85 c0                	test   %eax,%eax
  80069d:	74 26                	je     8006c5 <vsnprintf+0x47>
  80069f:	85 d2                	test   %edx,%edx
  8006a1:	7e 22                	jle    8006c5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a3:	ff 75 14             	pushl  0x14(%ebp)
  8006a6:	ff 75 10             	pushl  0x10(%ebp)
  8006a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ac:	50                   	push   %eax
  8006ad:	68 55 02 80 00       	push   $0x800255
  8006b2:	e8 d8 fb ff ff       	call   80028f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ba:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	eb 05                	jmp    8006ca <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ca:	c9                   	leave  
  8006cb:	c3                   	ret    

008006cc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006d5:	50                   	push   %eax
  8006d6:	ff 75 10             	pushl  0x10(%ebp)
  8006d9:	ff 75 0c             	pushl  0xc(%ebp)
  8006dc:	ff 75 08             	pushl  0x8(%ebp)
  8006df:	e8 9a ff ff ff       	call   80067e <vsnprintf>
	va_end(ap);

	return rc;
}
  8006e4:	c9                   	leave  
  8006e5:	c3                   	ret    

008006e6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f1:	eb 03                	jmp    8006f6 <strlen+0x10>
		n++;
  8006f3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006fa:	75 f7                	jne    8006f3 <strlen+0xd>
		n++;
	return n;
}
  8006fc:	5d                   	pop    %ebp
  8006fd:	c3                   	ret    

008006fe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006fe:	55                   	push   %ebp
  8006ff:	89 e5                	mov    %esp,%ebp
  800701:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800704:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800707:	ba 00 00 00 00       	mov    $0x0,%edx
  80070c:	eb 03                	jmp    800711 <strnlen+0x13>
		n++;
  80070e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800711:	39 c2                	cmp    %eax,%edx
  800713:	74 08                	je     80071d <strnlen+0x1f>
  800715:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800719:	75 f3                	jne    80070e <strnlen+0x10>
  80071b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	53                   	push   %ebx
  800723:	8b 45 08             	mov    0x8(%ebp),%eax
  800726:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800729:	89 c2                	mov    %eax,%edx
  80072b:	83 c2 01             	add    $0x1,%edx
  80072e:	83 c1 01             	add    $0x1,%ecx
  800731:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800735:	88 5a ff             	mov    %bl,-0x1(%edx)
  800738:	84 db                	test   %bl,%bl
  80073a:	75 ef                	jne    80072b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80073c:	5b                   	pop    %ebx
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	53                   	push   %ebx
  800743:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800746:	53                   	push   %ebx
  800747:	e8 9a ff ff ff       	call   8006e6 <strlen>
  80074c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80074f:	ff 75 0c             	pushl  0xc(%ebp)
  800752:	01 d8                	add    %ebx,%eax
  800754:	50                   	push   %eax
  800755:	e8 c5 ff ff ff       	call   80071f <strcpy>
	return dst;
}
  80075a:	89 d8                	mov    %ebx,%eax
  80075c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	56                   	push   %esi
  800765:	53                   	push   %ebx
  800766:	8b 75 08             	mov    0x8(%ebp),%esi
  800769:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80076c:	89 f3                	mov    %esi,%ebx
  80076e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800771:	89 f2                	mov    %esi,%edx
  800773:	eb 0f                	jmp    800784 <strncpy+0x23>
		*dst++ = *src;
  800775:	83 c2 01             	add    $0x1,%edx
  800778:	0f b6 01             	movzbl (%ecx),%eax
  80077b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80077e:	80 39 01             	cmpb   $0x1,(%ecx)
  800781:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800784:	39 da                	cmp    %ebx,%edx
  800786:	75 ed                	jne    800775 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800788:	89 f0                	mov    %esi,%eax
  80078a:	5b                   	pop    %ebx
  80078b:	5e                   	pop    %esi
  80078c:	5d                   	pop    %ebp
  80078d:	c3                   	ret    

0080078e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	56                   	push   %esi
  800792:	53                   	push   %ebx
  800793:	8b 75 08             	mov    0x8(%ebp),%esi
  800796:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800799:	8b 55 10             	mov    0x10(%ebp),%edx
  80079c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80079e:	85 d2                	test   %edx,%edx
  8007a0:	74 21                	je     8007c3 <strlcpy+0x35>
  8007a2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007a6:	89 f2                	mov    %esi,%edx
  8007a8:	eb 09                	jmp    8007b3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007aa:	83 c2 01             	add    $0x1,%edx
  8007ad:	83 c1 01             	add    $0x1,%ecx
  8007b0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007b3:	39 c2                	cmp    %eax,%edx
  8007b5:	74 09                	je     8007c0 <strlcpy+0x32>
  8007b7:	0f b6 19             	movzbl (%ecx),%ebx
  8007ba:	84 db                	test   %bl,%bl
  8007bc:	75 ec                	jne    8007aa <strlcpy+0x1c>
  8007be:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007c0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007c3:	29 f0                	sub    %esi,%eax
}
  8007c5:	5b                   	pop    %ebx
  8007c6:	5e                   	pop    %esi
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d2:	eb 06                	jmp    8007da <strcmp+0x11>
		p++, q++;
  8007d4:	83 c1 01             	add    $0x1,%ecx
  8007d7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007da:	0f b6 01             	movzbl (%ecx),%eax
  8007dd:	84 c0                	test   %al,%al
  8007df:	74 04                	je     8007e5 <strcmp+0x1c>
  8007e1:	3a 02                	cmp    (%edx),%al
  8007e3:	74 ef                	je     8007d4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e5:	0f b6 c0             	movzbl %al,%eax
  8007e8:	0f b6 12             	movzbl (%edx),%edx
  8007eb:	29 d0                	sub    %edx,%eax
}
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	53                   	push   %ebx
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f9:	89 c3                	mov    %eax,%ebx
  8007fb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007fe:	eb 06                	jmp    800806 <strncmp+0x17>
		n--, p++, q++;
  800800:	83 c0 01             	add    $0x1,%eax
  800803:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800806:	39 d8                	cmp    %ebx,%eax
  800808:	74 15                	je     80081f <strncmp+0x30>
  80080a:	0f b6 08             	movzbl (%eax),%ecx
  80080d:	84 c9                	test   %cl,%cl
  80080f:	74 04                	je     800815 <strncmp+0x26>
  800811:	3a 0a                	cmp    (%edx),%cl
  800813:	74 eb                	je     800800 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800815:	0f b6 00             	movzbl (%eax),%eax
  800818:	0f b6 12             	movzbl (%edx),%edx
  80081b:	29 d0                	sub    %edx,%eax
  80081d:	eb 05                	jmp    800824 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80081f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800824:	5b                   	pop    %ebx
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	8b 45 08             	mov    0x8(%ebp),%eax
  80082d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800831:	eb 07                	jmp    80083a <strchr+0x13>
		if (*s == c)
  800833:	38 ca                	cmp    %cl,%dl
  800835:	74 0f                	je     800846 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800837:	83 c0 01             	add    $0x1,%eax
  80083a:	0f b6 10             	movzbl (%eax),%edx
  80083d:	84 d2                	test   %dl,%dl
  80083f:	75 f2                	jne    800833 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800841:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800852:	eb 03                	jmp    800857 <strfind+0xf>
  800854:	83 c0 01             	add    $0x1,%eax
  800857:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80085a:	38 ca                	cmp    %cl,%dl
  80085c:	74 04                	je     800862 <strfind+0x1a>
  80085e:	84 d2                	test   %dl,%dl
  800860:	75 f2                	jne    800854 <strfind+0xc>
			break;
	return (char *) s;
}
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	57                   	push   %edi
  800868:	56                   	push   %esi
  800869:	53                   	push   %ebx
  80086a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800870:	85 c9                	test   %ecx,%ecx
  800872:	74 36                	je     8008aa <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800874:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80087a:	75 28                	jne    8008a4 <memset+0x40>
  80087c:	f6 c1 03             	test   $0x3,%cl
  80087f:	75 23                	jne    8008a4 <memset+0x40>
		c &= 0xFF;
  800881:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800885:	89 d3                	mov    %edx,%ebx
  800887:	c1 e3 08             	shl    $0x8,%ebx
  80088a:	89 d6                	mov    %edx,%esi
  80088c:	c1 e6 18             	shl    $0x18,%esi
  80088f:	89 d0                	mov    %edx,%eax
  800891:	c1 e0 10             	shl    $0x10,%eax
  800894:	09 f0                	or     %esi,%eax
  800896:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800898:	89 d8                	mov    %ebx,%eax
  80089a:	09 d0                	or     %edx,%eax
  80089c:	c1 e9 02             	shr    $0x2,%ecx
  80089f:	fc                   	cld    
  8008a0:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a2:	eb 06                	jmp    8008aa <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a7:	fc                   	cld    
  8008a8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008aa:	89 f8                	mov    %edi,%eax
  8008ac:	5b                   	pop    %ebx
  8008ad:	5e                   	pop    %esi
  8008ae:	5f                   	pop    %edi
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	57                   	push   %edi
  8008b5:	56                   	push   %esi
  8008b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008bf:	39 c6                	cmp    %eax,%esi
  8008c1:	73 35                	jae    8008f8 <memmove+0x47>
  8008c3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c6:	39 d0                	cmp    %edx,%eax
  8008c8:	73 2e                	jae    8008f8 <memmove+0x47>
		s += n;
		d += n;
  8008ca:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008cd:	89 d6                	mov    %edx,%esi
  8008cf:	09 fe                	or     %edi,%esi
  8008d1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008d7:	75 13                	jne    8008ec <memmove+0x3b>
  8008d9:	f6 c1 03             	test   $0x3,%cl
  8008dc:	75 0e                	jne    8008ec <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008de:	83 ef 04             	sub    $0x4,%edi
  8008e1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e4:	c1 e9 02             	shr    $0x2,%ecx
  8008e7:	fd                   	std    
  8008e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ea:	eb 09                	jmp    8008f5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008ec:	83 ef 01             	sub    $0x1,%edi
  8008ef:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008f2:	fd                   	std    
  8008f3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f5:	fc                   	cld    
  8008f6:	eb 1d                	jmp    800915 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f8:	89 f2                	mov    %esi,%edx
  8008fa:	09 c2                	or     %eax,%edx
  8008fc:	f6 c2 03             	test   $0x3,%dl
  8008ff:	75 0f                	jne    800910 <memmove+0x5f>
  800901:	f6 c1 03             	test   $0x3,%cl
  800904:	75 0a                	jne    800910 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800906:	c1 e9 02             	shr    $0x2,%ecx
  800909:	89 c7                	mov    %eax,%edi
  80090b:	fc                   	cld    
  80090c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090e:	eb 05                	jmp    800915 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800910:	89 c7                	mov    %eax,%edi
  800912:	fc                   	cld    
  800913:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800915:	5e                   	pop    %esi
  800916:	5f                   	pop    %edi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80091c:	ff 75 10             	pushl  0x10(%ebp)
  80091f:	ff 75 0c             	pushl  0xc(%ebp)
  800922:	ff 75 08             	pushl  0x8(%ebp)
  800925:	e8 87 ff ff ff       	call   8008b1 <memmove>
}
  80092a:	c9                   	leave  
  80092b:	c3                   	ret    

0080092c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8b 55 0c             	mov    0xc(%ebp),%edx
  800937:	89 c6                	mov    %eax,%esi
  800939:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093c:	eb 1a                	jmp    800958 <memcmp+0x2c>
		if (*s1 != *s2)
  80093e:	0f b6 08             	movzbl (%eax),%ecx
  800941:	0f b6 1a             	movzbl (%edx),%ebx
  800944:	38 d9                	cmp    %bl,%cl
  800946:	74 0a                	je     800952 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800948:	0f b6 c1             	movzbl %cl,%eax
  80094b:	0f b6 db             	movzbl %bl,%ebx
  80094e:	29 d8                	sub    %ebx,%eax
  800950:	eb 0f                	jmp    800961 <memcmp+0x35>
		s1++, s2++;
  800952:	83 c0 01             	add    $0x1,%eax
  800955:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800958:	39 f0                	cmp    %esi,%eax
  80095a:	75 e2                	jne    80093e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80095c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800961:	5b                   	pop    %ebx
  800962:	5e                   	pop    %esi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	53                   	push   %ebx
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80096c:	89 c1                	mov    %eax,%ecx
  80096e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800971:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800975:	eb 0a                	jmp    800981 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800977:	0f b6 10             	movzbl (%eax),%edx
  80097a:	39 da                	cmp    %ebx,%edx
  80097c:	74 07                	je     800985 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80097e:	83 c0 01             	add    $0x1,%eax
  800981:	39 c8                	cmp    %ecx,%eax
  800983:	72 f2                	jb     800977 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800985:	5b                   	pop    %ebx
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	53                   	push   %ebx
  80098e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800991:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800994:	eb 03                	jmp    800999 <strtol+0x11>
		s++;
  800996:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800999:	0f b6 01             	movzbl (%ecx),%eax
  80099c:	3c 20                	cmp    $0x20,%al
  80099e:	74 f6                	je     800996 <strtol+0xe>
  8009a0:	3c 09                	cmp    $0x9,%al
  8009a2:	74 f2                	je     800996 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009a4:	3c 2b                	cmp    $0x2b,%al
  8009a6:	75 0a                	jne    8009b2 <strtol+0x2a>
		s++;
  8009a8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ab:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b0:	eb 11                	jmp    8009c3 <strtol+0x3b>
  8009b2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009b7:	3c 2d                	cmp    $0x2d,%al
  8009b9:	75 08                	jne    8009c3 <strtol+0x3b>
		s++, neg = 1;
  8009bb:	83 c1 01             	add    $0x1,%ecx
  8009be:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c9:	75 15                	jne    8009e0 <strtol+0x58>
  8009cb:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ce:	75 10                	jne    8009e0 <strtol+0x58>
  8009d0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009d4:	75 7c                	jne    800a52 <strtol+0xca>
		s += 2, base = 16;
  8009d6:	83 c1 02             	add    $0x2,%ecx
  8009d9:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009de:	eb 16                	jmp    8009f6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009e0:	85 db                	test   %ebx,%ebx
  8009e2:	75 12                	jne    8009f6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009e4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e9:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ec:	75 08                	jne    8009f6 <strtol+0x6e>
		s++, base = 8;
  8009ee:	83 c1 01             	add    $0x1,%ecx
  8009f1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009fe:	0f b6 11             	movzbl (%ecx),%edx
  800a01:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a04:	89 f3                	mov    %esi,%ebx
  800a06:	80 fb 09             	cmp    $0x9,%bl
  800a09:	77 08                	ja     800a13 <strtol+0x8b>
			dig = *s - '0';
  800a0b:	0f be d2             	movsbl %dl,%edx
  800a0e:	83 ea 30             	sub    $0x30,%edx
  800a11:	eb 22                	jmp    800a35 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a13:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a16:	89 f3                	mov    %esi,%ebx
  800a18:	80 fb 19             	cmp    $0x19,%bl
  800a1b:	77 08                	ja     800a25 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a1d:	0f be d2             	movsbl %dl,%edx
  800a20:	83 ea 57             	sub    $0x57,%edx
  800a23:	eb 10                	jmp    800a35 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a25:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a28:	89 f3                	mov    %esi,%ebx
  800a2a:	80 fb 19             	cmp    $0x19,%bl
  800a2d:	77 16                	ja     800a45 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a2f:	0f be d2             	movsbl %dl,%edx
  800a32:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a35:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a38:	7d 0b                	jge    800a45 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a3a:	83 c1 01             	add    $0x1,%ecx
  800a3d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a41:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a43:	eb b9                	jmp    8009fe <strtol+0x76>

	if (endptr)
  800a45:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a49:	74 0d                	je     800a58 <strtol+0xd0>
		*endptr = (char *) s;
  800a4b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4e:	89 0e                	mov    %ecx,(%esi)
  800a50:	eb 06                	jmp    800a58 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a52:	85 db                	test   %ebx,%ebx
  800a54:	74 98                	je     8009ee <strtol+0x66>
  800a56:	eb 9e                	jmp    8009f6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a58:	89 c2                	mov    %eax,%edx
  800a5a:	f7 da                	neg    %edx
  800a5c:	85 ff                	test   %edi,%edi
  800a5e:	0f 45 c2             	cmovne %edx,%eax
}
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5f                   	pop    %edi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	57                   	push   %edi
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a74:	8b 55 08             	mov    0x8(%ebp),%edx
  800a77:	89 c3                	mov    %eax,%ebx
  800a79:	89 c7                	mov    %eax,%edi
  800a7b:	89 c6                	mov    %eax,%esi
  800a7d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5f                   	pop    %edi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8f:	b8 01 00 00 00       	mov    $0x1,%eax
  800a94:	89 d1                	mov    %edx,%ecx
  800a96:	89 d3                	mov    %edx,%ebx
  800a98:	89 d7                	mov    %edx,%edi
  800a9a:	89 d6                	mov    %edx,%esi
  800a9c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5f                   	pop    %edi
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
  800aa9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aac:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab9:	89 cb                	mov    %ecx,%ebx
  800abb:	89 cf                	mov    %ecx,%edi
  800abd:	89 ce                	mov    %ecx,%esi
  800abf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ac1:	85 c0                	test   %eax,%eax
  800ac3:	7e 17                	jle    800adc <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ac5:	83 ec 0c             	sub    $0xc,%esp
  800ac8:	50                   	push   %eax
  800ac9:	6a 03                	push   $0x3
  800acb:	68 20 10 80 00       	push   $0x801020
  800ad0:	6a 23                	push   $0x23
  800ad2:	68 3d 10 80 00       	push   $0x80103d
  800ad7:	e8 27 00 00 00       	call   800b03 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800adc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aea:	ba 00 00 00 00       	mov    $0x0,%edx
  800aef:	b8 02 00 00 00       	mov    $0x2,%eax
  800af4:	89 d1                	mov    %edx,%ecx
  800af6:	89 d3                	mov    %edx,%ebx
  800af8:	89 d7                	mov    %edx,%edi
  800afa:	89 d6                	mov    %edx,%esi
  800afc:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5f                   	pop    %edi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b08:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b0b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800b11:	e8 ce ff ff ff       	call   800ae4 <sys_getenvid>
  800b16:	83 ec 0c             	sub    $0xc,%esp
  800b19:	ff 75 0c             	pushl  0xc(%ebp)
  800b1c:	ff 75 08             	pushl  0x8(%ebp)
  800b1f:	56                   	push   %esi
  800b20:	50                   	push   %eax
  800b21:	68 4c 10 80 00       	push   $0x80104c
  800b26:	e8 2d f6 ff ff       	call   800158 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b2b:	83 c4 18             	add    $0x18,%esp
  800b2e:	53                   	push   %ebx
  800b2f:	ff 75 10             	pushl  0x10(%ebp)
  800b32:	e8 d0 f5 ff ff       	call   800107 <vcprintf>
	cprintf("\n");
  800b37:	c7 04 24 ec 0d 80 00 	movl   $0x800dec,(%esp)
  800b3e:	e8 15 f6 ff ff       	call   800158 <cprintf>
  800b43:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b46:	cc                   	int3   
  800b47:	eb fd                	jmp    800b46 <_panic+0x43>
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
