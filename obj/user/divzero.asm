
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
  800051:	68 c0 0d 80 00       	push   $0x800dc0
  800056:	e8 e0 00 00 00       	call   80013b <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	8b 45 08             	mov    0x8(%ebp),%eax
  800069:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006c:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800073:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 c0                	test   %eax,%eax
  800078:	7e 08                	jle    800082 <libmain+0x22>
		binaryname = argv[0];
  80007a:	8b 0a                	mov    (%edx),%ecx
  80007c:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800082:	83 ec 08             	sub    $0x8,%esp
  800085:	52                   	push   %edx
  800086:	50                   	push   %eax
  800087:	e8 a7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008c:	e8 05 00 00 00       	call   800096 <exit>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009c:	6a 00                	push   $0x0
  80009e:	e8 e3 09 00 00       	call   800a86 <sys_env_destroy>
}
  8000a3:	83 c4 10             	add    $0x10,%esp
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	53                   	push   %ebx
  8000ac:	83 ec 04             	sub    $0x4,%esp
  8000af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b2:	8b 13                	mov    (%ebx),%edx
  8000b4:	8d 42 01             	lea    0x1(%edx),%eax
  8000b7:	89 03                	mov    %eax,(%ebx)
  8000b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000bc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c5:	75 1a                	jne    8000e1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	68 ff 00 00 00       	push   $0xff
  8000cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d2:	50                   	push   %eax
  8000d3:	e8 71 09 00 00       	call   800a49 <sys_cputs>
		b->idx = 0;
  8000d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000de:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e8:	c9                   	leave  
  8000e9:	c3                   	ret    

008000ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fa:	00 00 00 
	b.cnt = 0;
  8000fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800104:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800107:	ff 75 0c             	pushl  0xc(%ebp)
  80010a:	ff 75 08             	pushl  0x8(%ebp)
  80010d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800113:	50                   	push   %eax
  800114:	68 a8 00 80 00       	push   $0x8000a8
  800119:	e8 54 01 00 00       	call   800272 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011e:	83 c4 08             	add    $0x8,%esp
  800121:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800127:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	e8 16 09 00 00       	call   800a49 <sys_cputs>

	return b.cnt;
}
  800133:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800141:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800144:	50                   	push   %eax
  800145:	ff 75 08             	pushl  0x8(%ebp)
  800148:	e8 9d ff ff ff       	call   8000ea <vcprintf>
	va_end(ap);

	return cnt;
}
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	57                   	push   %edi
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
  800155:	83 ec 1c             	sub    $0x1c,%esp
  800158:	89 c7                	mov    %eax,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	8b 45 08             	mov    0x8(%ebp),%eax
  80015f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800162:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800165:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800168:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80016b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800170:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800173:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800176:	39 d3                	cmp    %edx,%ebx
  800178:	72 05                	jb     80017f <printnum+0x30>
  80017a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80017d:	77 45                	ja     8001c4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	ff 75 18             	pushl  0x18(%ebp)
  800185:	8b 45 14             	mov    0x14(%ebp),%eax
  800188:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80018b:	53                   	push   %ebx
  80018c:	ff 75 10             	pushl  0x10(%ebp)
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	ff 75 e4             	pushl  -0x1c(%ebp)
  800195:	ff 75 e0             	pushl  -0x20(%ebp)
  800198:	ff 75 dc             	pushl  -0x24(%ebp)
  80019b:	ff 75 d8             	pushl  -0x28(%ebp)
  80019e:	e8 8d 09 00 00       	call   800b30 <__udivdi3>
  8001a3:	83 c4 18             	add    $0x18,%esp
  8001a6:	52                   	push   %edx
  8001a7:	50                   	push   %eax
  8001a8:	89 f2                	mov    %esi,%edx
  8001aa:	89 f8                	mov    %edi,%eax
  8001ac:	e8 9e ff ff ff       	call   80014f <printnum>
  8001b1:	83 c4 20             	add    $0x20,%esp
  8001b4:	eb 18                	jmp    8001ce <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b6:	83 ec 08             	sub    $0x8,%esp
  8001b9:	56                   	push   %esi
  8001ba:	ff 75 18             	pushl  0x18(%ebp)
  8001bd:	ff d7                	call   *%edi
  8001bf:	83 c4 10             	add    $0x10,%esp
  8001c2:	eb 03                	jmp    8001c7 <printnum+0x78>
  8001c4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c7:	83 eb 01             	sub    $0x1,%ebx
  8001ca:	85 db                	test   %ebx,%ebx
  8001cc:	7f e8                	jg     8001b6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001ce:	83 ec 08             	sub    $0x8,%esp
  8001d1:	56                   	push   %esi
  8001d2:	83 ec 04             	sub    $0x4,%esp
  8001d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001db:	ff 75 dc             	pushl  -0x24(%ebp)
  8001de:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e1:	e8 7a 0a 00 00       	call   800c60 <__umoddi3>
  8001e6:	83 c4 14             	add    $0x14,%esp
  8001e9:	0f be 80 d8 0d 80 00 	movsbl 0x800dd8(%eax),%eax
  8001f0:	50                   	push   %eax
  8001f1:	ff d7                	call   *%edi
}
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f9:	5b                   	pop    %ebx
  8001fa:	5e                   	pop    %esi
  8001fb:	5f                   	pop    %edi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800201:	83 fa 01             	cmp    $0x1,%edx
  800204:	7e 0e                	jle    800214 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800206:	8b 10                	mov    (%eax),%edx
  800208:	8d 4a 08             	lea    0x8(%edx),%ecx
  80020b:	89 08                	mov    %ecx,(%eax)
  80020d:	8b 02                	mov    (%edx),%eax
  80020f:	8b 52 04             	mov    0x4(%edx),%edx
  800212:	eb 22                	jmp    800236 <getuint+0x38>
	else if (lflag)
  800214:	85 d2                	test   %edx,%edx
  800216:	74 10                	je     800228 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800218:	8b 10                	mov    (%eax),%edx
  80021a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80021d:	89 08                	mov    %ecx,(%eax)
  80021f:	8b 02                	mov    (%edx),%eax
  800221:	ba 00 00 00 00       	mov    $0x0,%edx
  800226:	eb 0e                	jmp    800236 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800228:	8b 10                	mov    (%eax),%edx
  80022a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022d:	89 08                	mov    %ecx,(%eax)
  80022f:	8b 02                	mov    (%edx),%eax
  800231:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800236:	5d                   	pop    %ebp
  800237:	c3                   	ret    

00800238 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800242:	8b 10                	mov    (%eax),%edx
  800244:	3b 50 04             	cmp    0x4(%eax),%edx
  800247:	73 0a                	jae    800253 <sprintputch+0x1b>
		*b->buf++ = ch;
  800249:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024c:	89 08                	mov    %ecx,(%eax)
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	88 02                	mov    %al,(%edx)
}
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    

00800255 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80025b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025e:	50                   	push   %eax
  80025f:	ff 75 10             	pushl  0x10(%ebp)
  800262:	ff 75 0c             	pushl  0xc(%ebp)
  800265:	ff 75 08             	pushl  0x8(%ebp)
  800268:	e8 05 00 00 00       	call   800272 <vprintfmt>
	va_end(ap);
}
  80026d:	83 c4 10             	add    $0x10,%esp
  800270:	c9                   	leave  
  800271:	c3                   	ret    

00800272 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	57                   	push   %edi
  800276:	56                   	push   %esi
  800277:	53                   	push   %ebx
  800278:	83 ec 2c             	sub    $0x2c,%esp
  80027b:	8b 75 08             	mov    0x8(%ebp),%esi
  80027e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800281:	8b 7d 10             	mov    0x10(%ebp),%edi
  800284:	eb 12                	jmp    800298 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800286:	85 c0                	test   %eax,%eax
  800288:	0f 84 cb 03 00 00    	je     800659 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	53                   	push   %ebx
  800292:	50                   	push   %eax
  800293:	ff d6                	call   *%esi
  800295:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800298:	83 c7 01             	add    $0x1,%edi
  80029b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80029f:	83 f8 25             	cmp    $0x25,%eax
  8002a2:	75 e2                	jne    800286 <vprintfmt+0x14>
  8002a4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002a8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002af:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002b6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c2:	eb 07                	jmp    8002cb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002c7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002cb:	8d 47 01             	lea    0x1(%edi),%eax
  8002ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002d1:	0f b6 07             	movzbl (%edi),%eax
  8002d4:	0f b6 c8             	movzbl %al,%ecx
  8002d7:	83 e8 23             	sub    $0x23,%eax
  8002da:	3c 55                	cmp    $0x55,%al
  8002dc:	0f 87 5c 03 00 00    	ja     80063e <vprintfmt+0x3cc>
  8002e2:	0f b6 c0             	movzbl %al,%eax
  8002e5:	ff 24 85 80 0e 80 00 	jmp    *0x800e80(,%eax,4)
  8002ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002ef:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f3:	eb d6                	jmp    8002cb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800300:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800303:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800307:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80030a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80030d:	83 fa 09             	cmp    $0x9,%edx
  800310:	77 39                	ja     80034b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800312:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800315:	eb e9                	jmp    800300 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800317:	8b 45 14             	mov    0x14(%ebp),%eax
  80031a:	8d 48 04             	lea    0x4(%eax),%ecx
  80031d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800320:	8b 00                	mov    (%eax),%eax
  800322:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800325:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800328:	eb 27                	jmp    800351 <vprintfmt+0xdf>
  80032a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032d:	85 c0                	test   %eax,%eax
  80032f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800334:	0f 49 c8             	cmovns %eax,%ecx
  800337:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80033d:	eb 8c                	jmp    8002cb <vprintfmt+0x59>
  80033f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800342:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800349:	eb 80                	jmp    8002cb <vprintfmt+0x59>
  80034b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80034e:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800351:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800355:	0f 89 70 ff ff ff    	jns    8002cb <vprintfmt+0x59>
				width = precision, precision = -1;
  80035b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80035e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800361:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800368:	e9 5e ff ff ff       	jmp    8002cb <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80036d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800373:	e9 53 ff ff ff       	jmp    8002cb <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800378:	8b 45 14             	mov    0x14(%ebp),%eax
  80037b:	8d 50 04             	lea    0x4(%eax),%edx
  80037e:	89 55 14             	mov    %edx,0x14(%ebp)
  800381:	83 ec 08             	sub    $0x8,%esp
  800384:	53                   	push   %ebx
  800385:	ff 30                	pushl  (%eax)
  800387:	ff d6                	call   *%esi
			break;
  800389:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80038f:	e9 04 ff ff ff       	jmp    800298 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800394:	8b 45 14             	mov    0x14(%ebp),%eax
  800397:	8d 50 04             	lea    0x4(%eax),%edx
  80039a:	89 55 14             	mov    %edx,0x14(%ebp)
  80039d:	8b 00                	mov    (%eax),%eax
  80039f:	99                   	cltd   
  8003a0:	31 d0                	xor    %edx,%eax
  8003a2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a4:	83 f8 07             	cmp    $0x7,%eax
  8003a7:	7f 0b                	jg     8003b4 <vprintfmt+0x142>
  8003a9:	8b 14 85 e0 0f 80 00 	mov    0x800fe0(,%eax,4),%edx
  8003b0:	85 d2                	test   %edx,%edx
  8003b2:	75 18                	jne    8003cc <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003b4:	50                   	push   %eax
  8003b5:	68 f0 0d 80 00       	push   $0x800df0
  8003ba:	53                   	push   %ebx
  8003bb:	56                   	push   %esi
  8003bc:	e8 94 fe ff ff       	call   800255 <printfmt>
  8003c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003c7:	e9 cc fe ff ff       	jmp    800298 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003cc:	52                   	push   %edx
  8003cd:	68 f9 0d 80 00       	push   $0x800df9
  8003d2:	53                   	push   %ebx
  8003d3:	56                   	push   %esi
  8003d4:	e8 7c fe ff ff       	call   800255 <printfmt>
  8003d9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003df:	e9 b4 fe ff ff       	jmp    800298 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ed:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003ef:	85 ff                	test   %edi,%edi
  8003f1:	b8 e9 0d 80 00       	mov    $0x800de9,%eax
  8003f6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003f9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003fd:	0f 8e 94 00 00 00    	jle    800497 <vprintfmt+0x225>
  800403:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800407:	0f 84 98 00 00 00    	je     8004a5 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80040d:	83 ec 08             	sub    $0x8,%esp
  800410:	ff 75 c8             	pushl  -0x38(%ebp)
  800413:	57                   	push   %edi
  800414:	e8 c8 02 00 00       	call   8006e1 <strnlen>
  800419:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80041c:	29 c1                	sub    %eax,%ecx
  80041e:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800421:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800424:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800428:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80042e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800430:	eb 0f                	jmp    800441 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	53                   	push   %ebx
  800436:	ff 75 e0             	pushl  -0x20(%ebp)
  800439:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80043b:	83 ef 01             	sub    $0x1,%edi
  80043e:	83 c4 10             	add    $0x10,%esp
  800441:	85 ff                	test   %edi,%edi
  800443:	7f ed                	jg     800432 <vprintfmt+0x1c0>
  800445:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800448:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80044b:	85 c9                	test   %ecx,%ecx
  80044d:	b8 00 00 00 00       	mov    $0x0,%eax
  800452:	0f 49 c1             	cmovns %ecx,%eax
  800455:	29 c1                	sub    %eax,%ecx
  800457:	89 75 08             	mov    %esi,0x8(%ebp)
  80045a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80045d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800460:	89 cb                	mov    %ecx,%ebx
  800462:	eb 4d                	jmp    8004b1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800464:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800468:	74 1b                	je     800485 <vprintfmt+0x213>
  80046a:	0f be c0             	movsbl %al,%eax
  80046d:	83 e8 20             	sub    $0x20,%eax
  800470:	83 f8 5e             	cmp    $0x5e,%eax
  800473:	76 10                	jbe    800485 <vprintfmt+0x213>
					putch('?', putdat);
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	ff 75 0c             	pushl  0xc(%ebp)
  80047b:	6a 3f                	push   $0x3f
  80047d:	ff 55 08             	call   *0x8(%ebp)
  800480:	83 c4 10             	add    $0x10,%esp
  800483:	eb 0d                	jmp    800492 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	ff 75 0c             	pushl  0xc(%ebp)
  80048b:	52                   	push   %edx
  80048c:	ff 55 08             	call   *0x8(%ebp)
  80048f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800492:	83 eb 01             	sub    $0x1,%ebx
  800495:	eb 1a                	jmp    8004b1 <vprintfmt+0x23f>
  800497:	89 75 08             	mov    %esi,0x8(%ebp)
  80049a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80049d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a3:	eb 0c                	jmp    8004b1 <vprintfmt+0x23f>
  8004a5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a8:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004ab:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ae:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b1:	83 c7 01             	add    $0x1,%edi
  8004b4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b8:	0f be d0             	movsbl %al,%edx
  8004bb:	85 d2                	test   %edx,%edx
  8004bd:	74 23                	je     8004e2 <vprintfmt+0x270>
  8004bf:	85 f6                	test   %esi,%esi
  8004c1:	78 a1                	js     800464 <vprintfmt+0x1f2>
  8004c3:	83 ee 01             	sub    $0x1,%esi
  8004c6:	79 9c                	jns    800464 <vprintfmt+0x1f2>
  8004c8:	89 df                	mov    %ebx,%edi
  8004ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d0:	eb 18                	jmp    8004ea <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	53                   	push   %ebx
  8004d6:	6a 20                	push   $0x20
  8004d8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004da:	83 ef 01             	sub    $0x1,%edi
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	eb 08                	jmp    8004ea <vprintfmt+0x278>
  8004e2:	89 df                	mov    %ebx,%edi
  8004e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ea:	85 ff                	test   %edi,%edi
  8004ec:	7f e4                	jg     8004d2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f1:	e9 a2 fd ff ff       	jmp    800298 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004f6:	83 fa 01             	cmp    $0x1,%edx
  8004f9:	7e 16                	jle    800511 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8004fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fe:	8d 50 08             	lea    0x8(%eax),%edx
  800501:	89 55 14             	mov    %edx,0x14(%ebp)
  800504:	8b 50 04             	mov    0x4(%eax),%edx
  800507:	8b 00                	mov    (%eax),%eax
  800509:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80050c:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80050f:	eb 32                	jmp    800543 <vprintfmt+0x2d1>
	else if (lflag)
  800511:	85 d2                	test   %edx,%edx
  800513:	74 18                	je     80052d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 50 04             	lea    0x4(%eax),%edx
  80051b:	89 55 14             	mov    %edx,0x14(%ebp)
  80051e:	8b 00                	mov    (%eax),%eax
  800520:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800523:	89 c1                	mov    %eax,%ecx
  800525:	c1 f9 1f             	sar    $0x1f,%ecx
  800528:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80052b:	eb 16                	jmp    800543 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 50 04             	lea    0x4(%eax),%edx
  800533:	89 55 14             	mov    %edx,0x14(%ebp)
  800536:	8b 00                	mov    (%eax),%eax
  800538:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80053b:	89 c1                	mov    %eax,%ecx
  80053d:	c1 f9 1f             	sar    $0x1f,%ecx
  800540:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800543:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800546:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800549:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80054f:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800554:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800558:	0f 89 a8 00 00 00    	jns    800606 <vprintfmt+0x394>
				putch('-', putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	53                   	push   %ebx
  800562:	6a 2d                	push   $0x2d
  800564:	ff d6                	call   *%esi
				num = -(long long) num;
  800566:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800569:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80056c:	f7 d8                	neg    %eax
  80056e:	83 d2 00             	adc    $0x0,%edx
  800571:	f7 da                	neg    %edx
  800573:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800576:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800579:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80057c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800581:	e9 80 00 00 00       	jmp    800606 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800586:	8d 45 14             	lea    0x14(%ebp),%eax
  800589:	e8 70 fc ff ff       	call   8001fe <getuint>
  80058e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800591:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800594:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800599:	eb 6b                	jmp    800606 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80059b:	8d 45 14             	lea    0x14(%ebp),%eax
  80059e:	e8 5b fc ff ff       	call   8001fe <getuint>
  8005a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  8005a9:	6a 04                	push   $0x4
  8005ab:	6a 03                	push   $0x3
  8005ad:	6a 01                	push   $0x1
  8005af:	68 fc 0d 80 00       	push   $0x800dfc
  8005b4:	e8 82 fb ff ff       	call   80013b <cprintf>
			goto number;
  8005b9:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  8005bc:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  8005c1:	eb 43                	jmp    800606 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	53                   	push   %ebx
  8005c7:	6a 30                	push   $0x30
  8005c9:	ff d6                	call   *%esi
			putch('x', putdat);
  8005cb:	83 c4 08             	add    $0x8,%esp
  8005ce:	53                   	push   %ebx
  8005cf:	6a 78                	push   $0x78
  8005d1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 50 04             	lea    0x4(%eax),%edx
  8005d9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005dc:	8b 00                	mov    (%eax),%eax
  8005de:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005e9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ec:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005f1:	eb 13                	jmp    800606 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f6:	e8 03 fc ff ff       	call   8001fe <getuint>
  8005fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800601:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800606:	83 ec 0c             	sub    $0xc,%esp
  800609:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80060d:	52                   	push   %edx
  80060e:	ff 75 e0             	pushl  -0x20(%ebp)
  800611:	50                   	push   %eax
  800612:	ff 75 dc             	pushl  -0x24(%ebp)
  800615:	ff 75 d8             	pushl  -0x28(%ebp)
  800618:	89 da                	mov    %ebx,%edx
  80061a:	89 f0                	mov    %esi,%eax
  80061c:	e8 2e fb ff ff       	call   80014f <printnum>

			break;
  800621:	83 c4 20             	add    $0x20,%esp
  800624:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800627:	e9 6c fc ff ff       	jmp    800298 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	51                   	push   %ecx
  800631:	ff d6                	call   *%esi
			break;
  800633:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800639:	e9 5a fc ff ff       	jmp    800298 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	53                   	push   %ebx
  800642:	6a 25                	push   $0x25
  800644:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800646:	83 c4 10             	add    $0x10,%esp
  800649:	eb 03                	jmp    80064e <vprintfmt+0x3dc>
  80064b:	83 ef 01             	sub    $0x1,%edi
  80064e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800652:	75 f7                	jne    80064b <vprintfmt+0x3d9>
  800654:	e9 3f fc ff ff       	jmp    800298 <vprintfmt+0x26>
			break;
		}

	}

}
  800659:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065c:	5b                   	pop    %ebx
  80065d:	5e                   	pop    %esi
  80065e:	5f                   	pop    %edi
  80065f:	5d                   	pop    %ebp
  800660:	c3                   	ret    

00800661 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800661:	55                   	push   %ebp
  800662:	89 e5                	mov    %esp,%ebp
  800664:	83 ec 18             	sub    $0x18,%esp
  800667:	8b 45 08             	mov    0x8(%ebp),%eax
  80066a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80066d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800670:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800674:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800677:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80067e:	85 c0                	test   %eax,%eax
  800680:	74 26                	je     8006a8 <vsnprintf+0x47>
  800682:	85 d2                	test   %edx,%edx
  800684:	7e 22                	jle    8006a8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800686:	ff 75 14             	pushl  0x14(%ebp)
  800689:	ff 75 10             	pushl  0x10(%ebp)
  80068c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80068f:	50                   	push   %eax
  800690:	68 38 02 80 00       	push   $0x800238
  800695:	e8 d8 fb ff ff       	call   800272 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80069a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80069d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb 05                	jmp    8006ad <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ad:	c9                   	leave  
  8006ae:	c3                   	ret    

008006af <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006af:	55                   	push   %ebp
  8006b0:	89 e5                	mov    %esp,%ebp
  8006b2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006b5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006b8:	50                   	push   %eax
  8006b9:	ff 75 10             	pushl  0x10(%ebp)
  8006bc:	ff 75 0c             	pushl  0xc(%ebp)
  8006bf:	ff 75 08             	pushl  0x8(%ebp)
  8006c2:	e8 9a ff ff ff       	call   800661 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006c7:	c9                   	leave  
  8006c8:	c3                   	ret    

008006c9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d4:	eb 03                	jmp    8006d9 <strlen+0x10>
		n++;
  8006d6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006dd:	75 f7                	jne    8006d6 <strlen+0xd>
		n++;
	return n;
}
  8006df:	5d                   	pop    %ebp
  8006e0:	c3                   	ret    

008006e1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006e1:	55                   	push   %ebp
  8006e2:	89 e5                	mov    %esp,%ebp
  8006e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ef:	eb 03                	jmp    8006f4 <strnlen+0x13>
		n++;
  8006f1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f4:	39 c2                	cmp    %eax,%edx
  8006f6:	74 08                	je     800700 <strnlen+0x1f>
  8006f8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006fc:	75 f3                	jne    8006f1 <strnlen+0x10>
  8006fe:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	53                   	push   %ebx
  800706:	8b 45 08             	mov    0x8(%ebp),%eax
  800709:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80070c:	89 c2                	mov    %eax,%edx
  80070e:	83 c2 01             	add    $0x1,%edx
  800711:	83 c1 01             	add    $0x1,%ecx
  800714:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800718:	88 5a ff             	mov    %bl,-0x1(%edx)
  80071b:	84 db                	test   %bl,%bl
  80071d:	75 ef                	jne    80070e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80071f:	5b                   	pop    %ebx
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    

00800722 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	53                   	push   %ebx
  800726:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800729:	53                   	push   %ebx
  80072a:	e8 9a ff ff ff       	call   8006c9 <strlen>
  80072f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800732:	ff 75 0c             	pushl  0xc(%ebp)
  800735:	01 d8                	add    %ebx,%eax
  800737:	50                   	push   %eax
  800738:	e8 c5 ff ff ff       	call   800702 <strcpy>
	return dst;
}
  80073d:	89 d8                	mov    %ebx,%eax
  80073f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	56                   	push   %esi
  800748:	53                   	push   %ebx
  800749:	8b 75 08             	mov    0x8(%ebp),%esi
  80074c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80074f:	89 f3                	mov    %esi,%ebx
  800751:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800754:	89 f2                	mov    %esi,%edx
  800756:	eb 0f                	jmp    800767 <strncpy+0x23>
		*dst++ = *src;
  800758:	83 c2 01             	add    $0x1,%edx
  80075b:	0f b6 01             	movzbl (%ecx),%eax
  80075e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800761:	80 39 01             	cmpb   $0x1,(%ecx)
  800764:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800767:	39 da                	cmp    %ebx,%edx
  800769:	75 ed                	jne    800758 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80076b:	89 f0                	mov    %esi,%eax
  80076d:	5b                   	pop    %ebx
  80076e:	5e                   	pop    %esi
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	56                   	push   %esi
  800775:	53                   	push   %ebx
  800776:	8b 75 08             	mov    0x8(%ebp),%esi
  800779:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077c:	8b 55 10             	mov    0x10(%ebp),%edx
  80077f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800781:	85 d2                	test   %edx,%edx
  800783:	74 21                	je     8007a6 <strlcpy+0x35>
  800785:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800789:	89 f2                	mov    %esi,%edx
  80078b:	eb 09                	jmp    800796 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80078d:	83 c2 01             	add    $0x1,%edx
  800790:	83 c1 01             	add    $0x1,%ecx
  800793:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800796:	39 c2                	cmp    %eax,%edx
  800798:	74 09                	je     8007a3 <strlcpy+0x32>
  80079a:	0f b6 19             	movzbl (%ecx),%ebx
  80079d:	84 db                	test   %bl,%bl
  80079f:	75 ec                	jne    80078d <strlcpy+0x1c>
  8007a1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007a3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007a6:	29 f0                	sub    %esi,%eax
}
  8007a8:	5b                   	pop    %ebx
  8007a9:	5e                   	pop    %esi
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007b5:	eb 06                	jmp    8007bd <strcmp+0x11>
		p++, q++;
  8007b7:	83 c1 01             	add    $0x1,%ecx
  8007ba:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007bd:	0f b6 01             	movzbl (%ecx),%eax
  8007c0:	84 c0                	test   %al,%al
  8007c2:	74 04                	je     8007c8 <strcmp+0x1c>
  8007c4:	3a 02                	cmp    (%edx),%al
  8007c6:	74 ef                	je     8007b7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c8:	0f b6 c0             	movzbl %al,%eax
  8007cb:	0f b6 12             	movzbl (%edx),%edx
  8007ce:	29 d0                	sub    %edx,%eax
}
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	53                   	push   %ebx
  8007d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007dc:	89 c3                	mov    %eax,%ebx
  8007de:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007e1:	eb 06                	jmp    8007e9 <strncmp+0x17>
		n--, p++, q++;
  8007e3:	83 c0 01             	add    $0x1,%eax
  8007e6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007e9:	39 d8                	cmp    %ebx,%eax
  8007eb:	74 15                	je     800802 <strncmp+0x30>
  8007ed:	0f b6 08             	movzbl (%eax),%ecx
  8007f0:	84 c9                	test   %cl,%cl
  8007f2:	74 04                	je     8007f8 <strncmp+0x26>
  8007f4:	3a 0a                	cmp    (%edx),%cl
  8007f6:	74 eb                	je     8007e3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f8:	0f b6 00             	movzbl (%eax),%eax
  8007fb:	0f b6 12             	movzbl (%edx),%edx
  8007fe:	29 d0                	sub    %edx,%eax
  800800:	eb 05                	jmp    800807 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800807:	5b                   	pop    %ebx
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	8b 45 08             	mov    0x8(%ebp),%eax
  800810:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800814:	eb 07                	jmp    80081d <strchr+0x13>
		if (*s == c)
  800816:	38 ca                	cmp    %cl,%dl
  800818:	74 0f                	je     800829 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80081a:	83 c0 01             	add    $0x1,%eax
  80081d:	0f b6 10             	movzbl (%eax),%edx
  800820:	84 d2                	test   %dl,%dl
  800822:	75 f2                	jne    800816 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800824:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	8b 45 08             	mov    0x8(%ebp),%eax
  800831:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800835:	eb 03                	jmp    80083a <strfind+0xf>
  800837:	83 c0 01             	add    $0x1,%eax
  80083a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80083d:	38 ca                	cmp    %cl,%dl
  80083f:	74 04                	je     800845 <strfind+0x1a>
  800841:	84 d2                	test   %dl,%dl
  800843:	75 f2                	jne    800837 <strfind+0xc>
			break;
	return (char *) s;
}
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	57                   	push   %edi
  80084b:	56                   	push   %esi
  80084c:	53                   	push   %ebx
  80084d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800850:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800853:	85 c9                	test   %ecx,%ecx
  800855:	74 36                	je     80088d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800857:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80085d:	75 28                	jne    800887 <memset+0x40>
  80085f:	f6 c1 03             	test   $0x3,%cl
  800862:	75 23                	jne    800887 <memset+0x40>
		c &= 0xFF;
  800864:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800868:	89 d3                	mov    %edx,%ebx
  80086a:	c1 e3 08             	shl    $0x8,%ebx
  80086d:	89 d6                	mov    %edx,%esi
  80086f:	c1 e6 18             	shl    $0x18,%esi
  800872:	89 d0                	mov    %edx,%eax
  800874:	c1 e0 10             	shl    $0x10,%eax
  800877:	09 f0                	or     %esi,%eax
  800879:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80087b:	89 d8                	mov    %ebx,%eax
  80087d:	09 d0                	or     %edx,%eax
  80087f:	c1 e9 02             	shr    $0x2,%ecx
  800882:	fc                   	cld    
  800883:	f3 ab                	rep stos %eax,%es:(%edi)
  800885:	eb 06                	jmp    80088d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800887:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088a:	fc                   	cld    
  80088b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80088d:	89 f8                	mov    %edi,%eax
  80088f:	5b                   	pop    %ebx
  800890:	5e                   	pop    %esi
  800891:	5f                   	pop    %edi
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	57                   	push   %edi
  800898:	56                   	push   %esi
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80089f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008a2:	39 c6                	cmp    %eax,%esi
  8008a4:	73 35                	jae    8008db <memmove+0x47>
  8008a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a9:	39 d0                	cmp    %edx,%eax
  8008ab:	73 2e                	jae    8008db <memmove+0x47>
		s += n;
		d += n;
  8008ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b0:	89 d6                	mov    %edx,%esi
  8008b2:	09 fe                	or     %edi,%esi
  8008b4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008ba:	75 13                	jne    8008cf <memmove+0x3b>
  8008bc:	f6 c1 03             	test   $0x3,%cl
  8008bf:	75 0e                	jne    8008cf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008c1:	83 ef 04             	sub    $0x4,%edi
  8008c4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008c7:	c1 e9 02             	shr    $0x2,%ecx
  8008ca:	fd                   	std    
  8008cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008cd:	eb 09                	jmp    8008d8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008cf:	83 ef 01             	sub    $0x1,%edi
  8008d2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008d5:	fd                   	std    
  8008d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008d8:	fc                   	cld    
  8008d9:	eb 1d                	jmp    8008f8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008db:	89 f2                	mov    %esi,%edx
  8008dd:	09 c2                	or     %eax,%edx
  8008df:	f6 c2 03             	test   $0x3,%dl
  8008e2:	75 0f                	jne    8008f3 <memmove+0x5f>
  8008e4:	f6 c1 03             	test   $0x3,%cl
  8008e7:	75 0a                	jne    8008f3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008e9:	c1 e9 02             	shr    $0x2,%ecx
  8008ec:	89 c7                	mov    %eax,%edi
  8008ee:	fc                   	cld    
  8008ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f1:	eb 05                	jmp    8008f8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f3:	89 c7                	mov    %eax,%edi
  8008f5:	fc                   	cld    
  8008f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008f8:	5e                   	pop    %esi
  8008f9:	5f                   	pop    %edi
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008ff:	ff 75 10             	pushl  0x10(%ebp)
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	ff 75 08             	pushl  0x8(%ebp)
  800908:	e8 87 ff ff ff       	call   800894 <memmove>
}
  80090d:	c9                   	leave  
  80090e:	c3                   	ret    

0080090f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	56                   	push   %esi
  800913:	53                   	push   %ebx
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091a:	89 c6                	mov    %eax,%esi
  80091c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80091f:	eb 1a                	jmp    80093b <memcmp+0x2c>
		if (*s1 != *s2)
  800921:	0f b6 08             	movzbl (%eax),%ecx
  800924:	0f b6 1a             	movzbl (%edx),%ebx
  800927:	38 d9                	cmp    %bl,%cl
  800929:	74 0a                	je     800935 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80092b:	0f b6 c1             	movzbl %cl,%eax
  80092e:	0f b6 db             	movzbl %bl,%ebx
  800931:	29 d8                	sub    %ebx,%eax
  800933:	eb 0f                	jmp    800944 <memcmp+0x35>
		s1++, s2++;
  800935:	83 c0 01             	add    $0x1,%eax
  800938:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80093b:	39 f0                	cmp    %esi,%eax
  80093d:	75 e2                	jne    800921 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80093f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800944:	5b                   	pop    %ebx
  800945:	5e                   	pop    %esi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	53                   	push   %ebx
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80094f:	89 c1                	mov    %eax,%ecx
  800951:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800954:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800958:	eb 0a                	jmp    800964 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80095a:	0f b6 10             	movzbl (%eax),%edx
  80095d:	39 da                	cmp    %ebx,%edx
  80095f:	74 07                	je     800968 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800961:	83 c0 01             	add    $0x1,%eax
  800964:	39 c8                	cmp    %ecx,%eax
  800966:	72 f2                	jb     80095a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800968:	5b                   	pop    %ebx
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	57                   	push   %edi
  80096f:	56                   	push   %esi
  800970:	53                   	push   %ebx
  800971:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800974:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800977:	eb 03                	jmp    80097c <strtol+0x11>
		s++;
  800979:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097c:	0f b6 01             	movzbl (%ecx),%eax
  80097f:	3c 20                	cmp    $0x20,%al
  800981:	74 f6                	je     800979 <strtol+0xe>
  800983:	3c 09                	cmp    $0x9,%al
  800985:	74 f2                	je     800979 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800987:	3c 2b                	cmp    $0x2b,%al
  800989:	75 0a                	jne    800995 <strtol+0x2a>
		s++;
  80098b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80098e:	bf 00 00 00 00       	mov    $0x0,%edi
  800993:	eb 11                	jmp    8009a6 <strtol+0x3b>
  800995:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80099a:	3c 2d                	cmp    $0x2d,%al
  80099c:	75 08                	jne    8009a6 <strtol+0x3b>
		s++, neg = 1;
  80099e:	83 c1 01             	add    $0x1,%ecx
  8009a1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ac:	75 15                	jne    8009c3 <strtol+0x58>
  8009ae:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b1:	75 10                	jne    8009c3 <strtol+0x58>
  8009b3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009b7:	75 7c                	jne    800a35 <strtol+0xca>
		s += 2, base = 16;
  8009b9:	83 c1 02             	add    $0x2,%ecx
  8009bc:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c1:	eb 16                	jmp    8009d9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009c3:	85 db                	test   %ebx,%ebx
  8009c5:	75 12                	jne    8009d9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009c7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009cc:	80 39 30             	cmpb   $0x30,(%ecx)
  8009cf:	75 08                	jne    8009d9 <strtol+0x6e>
		s++, base = 8;
  8009d1:	83 c1 01             	add    $0x1,%ecx
  8009d4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009de:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e1:	0f b6 11             	movzbl (%ecx),%edx
  8009e4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009e7:	89 f3                	mov    %esi,%ebx
  8009e9:	80 fb 09             	cmp    $0x9,%bl
  8009ec:	77 08                	ja     8009f6 <strtol+0x8b>
			dig = *s - '0';
  8009ee:	0f be d2             	movsbl %dl,%edx
  8009f1:	83 ea 30             	sub    $0x30,%edx
  8009f4:	eb 22                	jmp    800a18 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009f6:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009f9:	89 f3                	mov    %esi,%ebx
  8009fb:	80 fb 19             	cmp    $0x19,%bl
  8009fe:	77 08                	ja     800a08 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a00:	0f be d2             	movsbl %dl,%edx
  800a03:	83 ea 57             	sub    $0x57,%edx
  800a06:	eb 10                	jmp    800a18 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a08:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a0b:	89 f3                	mov    %esi,%ebx
  800a0d:	80 fb 19             	cmp    $0x19,%bl
  800a10:	77 16                	ja     800a28 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a12:	0f be d2             	movsbl %dl,%edx
  800a15:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a18:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a1b:	7d 0b                	jge    800a28 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a1d:	83 c1 01             	add    $0x1,%ecx
  800a20:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a24:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a26:	eb b9                	jmp    8009e1 <strtol+0x76>

	if (endptr)
  800a28:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a2c:	74 0d                	je     800a3b <strtol+0xd0>
		*endptr = (char *) s;
  800a2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a31:	89 0e                	mov    %ecx,(%esi)
  800a33:	eb 06                	jmp    800a3b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a35:	85 db                	test   %ebx,%ebx
  800a37:	74 98                	je     8009d1 <strtol+0x66>
  800a39:	eb 9e                	jmp    8009d9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a3b:	89 c2                	mov    %eax,%edx
  800a3d:	f7 da                	neg    %edx
  800a3f:	85 ff                	test   %edi,%edi
  800a41:	0f 45 c2             	cmovne %edx,%eax
}
  800a44:	5b                   	pop    %ebx
  800a45:	5e                   	pop    %esi
  800a46:	5f                   	pop    %edi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	57                   	push   %edi
  800a4d:	56                   	push   %esi
  800a4e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a57:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5a:	89 c3                	mov    %eax,%ebx
  800a5c:	89 c7                	mov    %eax,%edi
  800a5e:	89 c6                	mov    %eax,%esi
  800a60:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5f                   	pop    %edi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	57                   	push   %edi
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a72:	b8 01 00 00 00       	mov    $0x1,%eax
  800a77:	89 d1                	mov    %edx,%ecx
  800a79:	89 d3                	mov    %edx,%ebx
  800a7b:	89 d7                	mov    %edx,%edi
  800a7d:	89 d6                	mov    %edx,%esi
  800a7f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5f                   	pop    %edi
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	57                   	push   %edi
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
  800a8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a94:	b8 03 00 00 00       	mov    $0x3,%eax
  800a99:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9c:	89 cb                	mov    %ecx,%ebx
  800a9e:	89 cf                	mov    %ecx,%edi
  800aa0:	89 ce                	mov    %ecx,%esi
  800aa2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aa4:	85 c0                	test   %eax,%eax
  800aa6:	7e 17                	jle    800abf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa8:	83 ec 0c             	sub    $0xc,%esp
  800aab:	50                   	push   %eax
  800aac:	6a 03                	push   $0x3
  800aae:	68 00 10 80 00       	push   $0x801000
  800ab3:	6a 23                	push   $0x23
  800ab5:	68 1d 10 80 00       	push   $0x80101d
  800aba:	e8 27 00 00 00       	call   800ae6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800abf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ad7:	89 d1                	mov    %edx,%ecx
  800ad9:	89 d3                	mov    %edx,%ebx
  800adb:	89 d7                	mov    %edx,%edi
  800add:	89 d6                	mov    %edx,%esi
  800adf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800aeb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800aee:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800af4:	e8 ce ff ff ff       	call   800ac7 <sys_getenvid>
  800af9:	83 ec 0c             	sub    $0xc,%esp
  800afc:	ff 75 0c             	pushl  0xc(%ebp)
  800aff:	ff 75 08             	pushl  0x8(%ebp)
  800b02:	56                   	push   %esi
  800b03:	50                   	push   %eax
  800b04:	68 2c 10 80 00       	push   $0x80102c
  800b09:	e8 2d f6 ff ff       	call   80013b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b0e:	83 c4 18             	add    $0x18,%esp
  800b11:	53                   	push   %ebx
  800b12:	ff 75 10             	pushl  0x10(%ebp)
  800b15:	e8 d0 f5 ff ff       	call   8000ea <vcprintf>
	cprintf("\n");
  800b1a:	c7 04 24 cc 0d 80 00 	movl   $0x800dcc,(%esp)
  800b21:	e8 15 f6 ff ff       	call   80013b <cprintf>
  800b26:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b29:	cc                   	int3   
  800b2a:	eb fd                	jmp    800b29 <_panic+0x43>
  800b2c:	66 90                	xchg   %ax,%ax
  800b2e:	66 90                	xchg   %ax,%ax

00800b30 <__udivdi3>:
  800b30:	55                   	push   %ebp
  800b31:	57                   	push   %edi
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
  800b34:	83 ec 1c             	sub    $0x1c,%esp
  800b37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800b3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800b3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800b43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b47:	85 f6                	test   %esi,%esi
  800b49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b4d:	89 ca                	mov    %ecx,%edx
  800b4f:	89 f8                	mov    %edi,%eax
  800b51:	75 3d                	jne    800b90 <__udivdi3+0x60>
  800b53:	39 cf                	cmp    %ecx,%edi
  800b55:	0f 87 c5 00 00 00    	ja     800c20 <__udivdi3+0xf0>
  800b5b:	85 ff                	test   %edi,%edi
  800b5d:	89 fd                	mov    %edi,%ebp
  800b5f:	75 0b                	jne    800b6c <__udivdi3+0x3c>
  800b61:	b8 01 00 00 00       	mov    $0x1,%eax
  800b66:	31 d2                	xor    %edx,%edx
  800b68:	f7 f7                	div    %edi
  800b6a:	89 c5                	mov    %eax,%ebp
  800b6c:	89 c8                	mov    %ecx,%eax
  800b6e:	31 d2                	xor    %edx,%edx
  800b70:	f7 f5                	div    %ebp
  800b72:	89 c1                	mov    %eax,%ecx
  800b74:	89 d8                	mov    %ebx,%eax
  800b76:	89 cf                	mov    %ecx,%edi
  800b78:	f7 f5                	div    %ebp
  800b7a:	89 c3                	mov    %eax,%ebx
  800b7c:	89 d8                	mov    %ebx,%eax
  800b7e:	89 fa                	mov    %edi,%edx
  800b80:	83 c4 1c             	add    $0x1c,%esp
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5f                   	pop    %edi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    
  800b88:	90                   	nop
  800b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800b90:	39 ce                	cmp    %ecx,%esi
  800b92:	77 74                	ja     800c08 <__udivdi3+0xd8>
  800b94:	0f bd fe             	bsr    %esi,%edi
  800b97:	83 f7 1f             	xor    $0x1f,%edi
  800b9a:	0f 84 98 00 00 00    	je     800c38 <__udivdi3+0x108>
  800ba0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800ba5:	89 f9                	mov    %edi,%ecx
  800ba7:	89 c5                	mov    %eax,%ebp
  800ba9:	29 fb                	sub    %edi,%ebx
  800bab:	d3 e6                	shl    %cl,%esi
  800bad:	89 d9                	mov    %ebx,%ecx
  800baf:	d3 ed                	shr    %cl,%ebp
  800bb1:	89 f9                	mov    %edi,%ecx
  800bb3:	d3 e0                	shl    %cl,%eax
  800bb5:	09 ee                	or     %ebp,%esi
  800bb7:	89 d9                	mov    %ebx,%ecx
  800bb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bbd:	89 d5                	mov    %edx,%ebp
  800bbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800bc3:	d3 ed                	shr    %cl,%ebp
  800bc5:	89 f9                	mov    %edi,%ecx
  800bc7:	d3 e2                	shl    %cl,%edx
  800bc9:	89 d9                	mov    %ebx,%ecx
  800bcb:	d3 e8                	shr    %cl,%eax
  800bcd:	09 c2                	or     %eax,%edx
  800bcf:	89 d0                	mov    %edx,%eax
  800bd1:	89 ea                	mov    %ebp,%edx
  800bd3:	f7 f6                	div    %esi
  800bd5:	89 d5                	mov    %edx,%ebp
  800bd7:	89 c3                	mov    %eax,%ebx
  800bd9:	f7 64 24 0c          	mull   0xc(%esp)
  800bdd:	39 d5                	cmp    %edx,%ebp
  800bdf:	72 10                	jb     800bf1 <__udivdi3+0xc1>
  800be1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800be5:	89 f9                	mov    %edi,%ecx
  800be7:	d3 e6                	shl    %cl,%esi
  800be9:	39 c6                	cmp    %eax,%esi
  800beb:	73 07                	jae    800bf4 <__udivdi3+0xc4>
  800bed:	39 d5                	cmp    %edx,%ebp
  800bef:	75 03                	jne    800bf4 <__udivdi3+0xc4>
  800bf1:	83 eb 01             	sub    $0x1,%ebx
  800bf4:	31 ff                	xor    %edi,%edi
  800bf6:	89 d8                	mov    %ebx,%eax
  800bf8:	89 fa                	mov    %edi,%edx
  800bfa:	83 c4 1c             	add    $0x1c,%esp
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    
  800c02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c08:	31 ff                	xor    %edi,%edi
  800c0a:	31 db                	xor    %ebx,%ebx
  800c0c:	89 d8                	mov    %ebx,%eax
  800c0e:	89 fa                	mov    %edi,%edx
  800c10:	83 c4 1c             	add    $0x1c,%esp
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    
  800c18:	90                   	nop
  800c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c20:	89 d8                	mov    %ebx,%eax
  800c22:	f7 f7                	div    %edi
  800c24:	31 ff                	xor    %edi,%edi
  800c26:	89 c3                	mov    %eax,%ebx
  800c28:	89 d8                	mov    %ebx,%eax
  800c2a:	89 fa                	mov    %edi,%edx
  800c2c:	83 c4 1c             	add    $0x1c,%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    
  800c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c38:	39 ce                	cmp    %ecx,%esi
  800c3a:	72 0c                	jb     800c48 <__udivdi3+0x118>
  800c3c:	31 db                	xor    %ebx,%ebx
  800c3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800c42:	0f 87 34 ff ff ff    	ja     800b7c <__udivdi3+0x4c>
  800c48:	bb 01 00 00 00       	mov    $0x1,%ebx
  800c4d:	e9 2a ff ff ff       	jmp    800b7c <__udivdi3+0x4c>
  800c52:	66 90                	xchg   %ax,%ax
  800c54:	66 90                	xchg   %ax,%ax
  800c56:	66 90                	xchg   %ax,%ax
  800c58:	66 90                	xchg   %ax,%ax
  800c5a:	66 90                	xchg   %ax,%ax
  800c5c:	66 90                	xchg   %ax,%ax
  800c5e:	66 90                	xchg   %ax,%ax

00800c60 <__umoddi3>:
  800c60:	55                   	push   %ebp
  800c61:	57                   	push   %edi
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	83 ec 1c             	sub    $0x1c,%esp
  800c67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c77:	85 d2                	test   %edx,%edx
  800c79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c81:	89 f3                	mov    %esi,%ebx
  800c83:	89 3c 24             	mov    %edi,(%esp)
  800c86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c8a:	75 1c                	jne    800ca8 <__umoddi3+0x48>
  800c8c:	39 f7                	cmp    %esi,%edi
  800c8e:	76 50                	jbe    800ce0 <__umoddi3+0x80>
  800c90:	89 c8                	mov    %ecx,%eax
  800c92:	89 f2                	mov    %esi,%edx
  800c94:	f7 f7                	div    %edi
  800c96:	89 d0                	mov    %edx,%eax
  800c98:	31 d2                	xor    %edx,%edx
  800c9a:	83 c4 1c             	add    $0x1c,%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    
  800ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ca8:	39 f2                	cmp    %esi,%edx
  800caa:	89 d0                	mov    %edx,%eax
  800cac:	77 52                	ja     800d00 <__umoddi3+0xa0>
  800cae:	0f bd ea             	bsr    %edx,%ebp
  800cb1:	83 f5 1f             	xor    $0x1f,%ebp
  800cb4:	75 5a                	jne    800d10 <__umoddi3+0xb0>
  800cb6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800cba:	0f 82 e0 00 00 00    	jb     800da0 <__umoddi3+0x140>
  800cc0:	39 0c 24             	cmp    %ecx,(%esp)
  800cc3:	0f 86 d7 00 00 00    	jbe    800da0 <__umoddi3+0x140>
  800cc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ccd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800cd1:	83 c4 1c             	add    $0x1c,%esp
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    
  800cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ce0:	85 ff                	test   %edi,%edi
  800ce2:	89 fd                	mov    %edi,%ebp
  800ce4:	75 0b                	jne    800cf1 <__umoddi3+0x91>
  800ce6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ceb:	31 d2                	xor    %edx,%edx
  800ced:	f7 f7                	div    %edi
  800cef:	89 c5                	mov    %eax,%ebp
  800cf1:	89 f0                	mov    %esi,%eax
  800cf3:	31 d2                	xor    %edx,%edx
  800cf5:	f7 f5                	div    %ebp
  800cf7:	89 c8                	mov    %ecx,%eax
  800cf9:	f7 f5                	div    %ebp
  800cfb:	89 d0                	mov    %edx,%eax
  800cfd:	eb 99                	jmp    800c98 <__umoddi3+0x38>
  800cff:	90                   	nop
  800d00:	89 c8                	mov    %ecx,%eax
  800d02:	89 f2                	mov    %esi,%edx
  800d04:	83 c4 1c             	add    $0x1c,%esp
  800d07:	5b                   	pop    %ebx
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    
  800d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d10:	8b 34 24             	mov    (%esp),%esi
  800d13:	bf 20 00 00 00       	mov    $0x20,%edi
  800d18:	89 e9                	mov    %ebp,%ecx
  800d1a:	29 ef                	sub    %ebp,%edi
  800d1c:	d3 e0                	shl    %cl,%eax
  800d1e:	89 f9                	mov    %edi,%ecx
  800d20:	89 f2                	mov    %esi,%edx
  800d22:	d3 ea                	shr    %cl,%edx
  800d24:	89 e9                	mov    %ebp,%ecx
  800d26:	09 c2                	or     %eax,%edx
  800d28:	89 d8                	mov    %ebx,%eax
  800d2a:	89 14 24             	mov    %edx,(%esp)
  800d2d:	89 f2                	mov    %esi,%edx
  800d2f:	d3 e2                	shl    %cl,%edx
  800d31:	89 f9                	mov    %edi,%ecx
  800d33:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d3b:	d3 e8                	shr    %cl,%eax
  800d3d:	89 e9                	mov    %ebp,%ecx
  800d3f:	89 c6                	mov    %eax,%esi
  800d41:	d3 e3                	shl    %cl,%ebx
  800d43:	89 f9                	mov    %edi,%ecx
  800d45:	89 d0                	mov    %edx,%eax
  800d47:	d3 e8                	shr    %cl,%eax
  800d49:	89 e9                	mov    %ebp,%ecx
  800d4b:	09 d8                	or     %ebx,%eax
  800d4d:	89 d3                	mov    %edx,%ebx
  800d4f:	89 f2                	mov    %esi,%edx
  800d51:	f7 34 24             	divl   (%esp)
  800d54:	89 d6                	mov    %edx,%esi
  800d56:	d3 e3                	shl    %cl,%ebx
  800d58:	f7 64 24 04          	mull   0x4(%esp)
  800d5c:	39 d6                	cmp    %edx,%esi
  800d5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d62:	89 d1                	mov    %edx,%ecx
  800d64:	89 c3                	mov    %eax,%ebx
  800d66:	72 08                	jb     800d70 <__umoddi3+0x110>
  800d68:	75 11                	jne    800d7b <__umoddi3+0x11b>
  800d6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800d6e:	73 0b                	jae    800d7b <__umoddi3+0x11b>
  800d70:	2b 44 24 04          	sub    0x4(%esp),%eax
  800d74:	1b 14 24             	sbb    (%esp),%edx
  800d77:	89 d1                	mov    %edx,%ecx
  800d79:	89 c3                	mov    %eax,%ebx
  800d7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800d7f:	29 da                	sub    %ebx,%edx
  800d81:	19 ce                	sbb    %ecx,%esi
  800d83:	89 f9                	mov    %edi,%ecx
  800d85:	89 f0                	mov    %esi,%eax
  800d87:	d3 e0                	shl    %cl,%eax
  800d89:	89 e9                	mov    %ebp,%ecx
  800d8b:	d3 ea                	shr    %cl,%edx
  800d8d:	89 e9                	mov    %ebp,%ecx
  800d8f:	d3 ee                	shr    %cl,%esi
  800d91:	09 d0                	or     %edx,%eax
  800d93:	89 f2                	mov    %esi,%edx
  800d95:	83 c4 1c             	add    $0x1c,%esp
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    
  800d9d:	8d 76 00             	lea    0x0(%esi),%esi
  800da0:	29 f9                	sub    %edi,%ecx
  800da2:	19 d6                	sbb    %edx,%esi
  800da4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800da8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dac:	e9 18 ff ff ff       	jmp    800cc9 <__umoddi3+0x69>
