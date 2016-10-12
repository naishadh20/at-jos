
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
  80003f:	68 c0 0d 80 00       	push   $0x800dc0
  800044:	e8 e0 00 00 00       	call   800129 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	83 ec 08             	sub    $0x8,%esp
  800054:	8b 45 08             	mov    0x8(%ebp),%eax
  800057:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800061:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 c0                	test   %eax,%eax
  800066:	7e 08                	jle    800070 <libmain+0x22>
		binaryname = argv[0];
  800068:	8b 0a                	mov    (%edx),%ecx
  80006a:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800070:	83 ec 08             	sub    $0x8,%esp
  800073:	52                   	push   %edx
  800074:	50                   	push   %eax
  800075:	e8 b9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007a:	e8 05 00 00 00       	call   800084 <exit>
}
  80007f:	83 c4 10             	add    $0x10,%esp
  800082:	c9                   	leave  
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008a:	6a 00                	push   $0x0
  80008c:	e8 e3 09 00 00       	call   800a74 <sys_env_destroy>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	53                   	push   %ebx
  80009a:	83 ec 04             	sub    $0x4,%esp
  80009d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000a0:	8b 13                	mov    (%ebx),%edx
  8000a2:	8d 42 01             	lea    0x1(%edx),%eax
  8000a5:	89 03                	mov    %eax,(%ebx)
  8000a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000b3:	75 1a                	jne    8000cf <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000b5:	83 ec 08             	sub    $0x8,%esp
  8000b8:	68 ff 00 00 00       	push   $0xff
  8000bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000c0:	50                   	push   %eax
  8000c1:	e8 71 09 00 00       	call   800a37 <sys_cputs>
		b->idx = 0;
  8000c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000cc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000cf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000e8:	00 00 00 
	b.cnt = 0;
  8000eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000f5:	ff 75 0c             	pushl  0xc(%ebp)
  8000f8:	ff 75 08             	pushl  0x8(%ebp)
  8000fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800101:	50                   	push   %eax
  800102:	68 96 00 80 00       	push   $0x800096
  800107:	e8 54 01 00 00       	call   800260 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80010c:	83 c4 08             	add    $0x8,%esp
  80010f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800115:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80011b:	50                   	push   %eax
  80011c:	e8 16 09 00 00       	call   800a37 <sys_cputs>

	return b.cnt;
}
  800121:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800127:	c9                   	leave  
  800128:	c3                   	ret    

00800129 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80012f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800132:	50                   	push   %eax
  800133:	ff 75 08             	pushl  0x8(%ebp)
  800136:	e8 9d ff ff ff       	call   8000d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80013b:	c9                   	leave  
  80013c:	c3                   	ret    

0080013d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	57                   	push   %edi
  800141:	56                   	push   %esi
  800142:	53                   	push   %ebx
  800143:	83 ec 1c             	sub    $0x1c,%esp
  800146:	89 c7                	mov    %eax,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	8b 45 08             	mov    0x8(%ebp),%eax
  80014d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800150:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800153:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800156:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800159:	bb 00 00 00 00       	mov    $0x0,%ebx
  80015e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800161:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800164:	39 d3                	cmp    %edx,%ebx
  800166:	72 05                	jb     80016d <printnum+0x30>
  800168:	39 45 10             	cmp    %eax,0x10(%ebp)
  80016b:	77 45                	ja     8001b2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80016d:	83 ec 0c             	sub    $0xc,%esp
  800170:	ff 75 18             	pushl  0x18(%ebp)
  800173:	8b 45 14             	mov    0x14(%ebp),%eax
  800176:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800179:	53                   	push   %ebx
  80017a:	ff 75 10             	pushl  0x10(%ebp)
  80017d:	83 ec 08             	sub    $0x8,%esp
  800180:	ff 75 e4             	pushl  -0x1c(%ebp)
  800183:	ff 75 e0             	pushl  -0x20(%ebp)
  800186:	ff 75 dc             	pushl  -0x24(%ebp)
  800189:	ff 75 d8             	pushl  -0x28(%ebp)
  80018c:	e8 8f 09 00 00       	call   800b20 <__udivdi3>
  800191:	83 c4 18             	add    $0x18,%esp
  800194:	52                   	push   %edx
  800195:	50                   	push   %eax
  800196:	89 f2                	mov    %esi,%edx
  800198:	89 f8                	mov    %edi,%eax
  80019a:	e8 9e ff ff ff       	call   80013d <printnum>
  80019f:	83 c4 20             	add    $0x20,%esp
  8001a2:	eb 18                	jmp    8001bc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001a4:	83 ec 08             	sub    $0x8,%esp
  8001a7:	56                   	push   %esi
  8001a8:	ff 75 18             	pushl  0x18(%ebp)
  8001ab:	ff d7                	call   *%edi
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	eb 03                	jmp    8001b5 <printnum+0x78>
  8001b2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001b5:	83 eb 01             	sub    $0x1,%ebx
  8001b8:	85 db                	test   %ebx,%ebx
  8001ba:	7f e8                	jg     8001a4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	56                   	push   %esi
  8001c0:	83 ec 04             	sub    $0x4,%esp
  8001c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8001cf:	e8 7c 0a 00 00       	call   800c50 <__umoddi3>
  8001d4:	83 c4 14             	add    $0x14,%esp
  8001d7:	0f be 80 e8 0d 80 00 	movsbl 0x800de8(%eax),%eax
  8001de:	50                   	push   %eax
  8001df:	ff d7                	call   *%edi
}
  8001e1:	83 c4 10             	add    $0x10,%esp
  8001e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e7:	5b                   	pop    %ebx
  8001e8:	5e                   	pop    %esi
  8001e9:	5f                   	pop    %edi
  8001ea:	5d                   	pop    %ebp
  8001eb:	c3                   	ret    

008001ec <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8001ef:	83 fa 01             	cmp    $0x1,%edx
  8001f2:	7e 0e                	jle    800202 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8001f4:	8b 10                	mov    (%eax),%edx
  8001f6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8001f9:	89 08                	mov    %ecx,(%eax)
  8001fb:	8b 02                	mov    (%edx),%eax
  8001fd:	8b 52 04             	mov    0x4(%edx),%edx
  800200:	eb 22                	jmp    800224 <getuint+0x38>
	else if (lflag)
  800202:	85 d2                	test   %edx,%edx
  800204:	74 10                	je     800216 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800206:	8b 10                	mov    (%eax),%edx
  800208:	8d 4a 04             	lea    0x4(%edx),%ecx
  80020b:	89 08                	mov    %ecx,(%eax)
  80020d:	8b 02                	mov    (%edx),%eax
  80020f:	ba 00 00 00 00       	mov    $0x0,%edx
  800214:	eb 0e                	jmp    800224 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800216:	8b 10                	mov    (%eax),%edx
  800218:	8d 4a 04             	lea    0x4(%edx),%ecx
  80021b:	89 08                	mov    %ecx,(%eax)
  80021d:	8b 02                	mov    (%edx),%eax
  80021f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80022c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800230:	8b 10                	mov    (%eax),%edx
  800232:	3b 50 04             	cmp    0x4(%eax),%edx
  800235:	73 0a                	jae    800241 <sprintputch+0x1b>
		*b->buf++ = ch;
  800237:	8d 4a 01             	lea    0x1(%edx),%ecx
  80023a:	89 08                	mov    %ecx,(%eax)
  80023c:	8b 45 08             	mov    0x8(%ebp),%eax
  80023f:	88 02                	mov    %al,(%edx)
}
  800241:	5d                   	pop    %ebp
  800242:	c3                   	ret    

00800243 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80024c:	50                   	push   %eax
  80024d:	ff 75 10             	pushl  0x10(%ebp)
  800250:	ff 75 0c             	pushl  0xc(%ebp)
  800253:	ff 75 08             	pushl  0x8(%ebp)
  800256:	e8 05 00 00 00       	call   800260 <vprintfmt>
	va_end(ap);
}
  80025b:	83 c4 10             	add    $0x10,%esp
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 2c             	sub    $0x2c,%esp
  800269:	8b 75 08             	mov    0x8(%ebp),%esi
  80026c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80026f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800272:	eb 12                	jmp    800286 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800274:	85 c0                	test   %eax,%eax
  800276:	0f 84 cb 03 00 00    	je     800647 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  80027c:	83 ec 08             	sub    $0x8,%esp
  80027f:	53                   	push   %ebx
  800280:	50                   	push   %eax
  800281:	ff d6                	call   *%esi
  800283:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800286:	83 c7 01             	add    $0x1,%edi
  800289:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80028d:	83 f8 25             	cmp    $0x25,%eax
  800290:	75 e2                	jne    800274 <vprintfmt+0x14>
  800292:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800296:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80029d:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002a4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8002b0:	eb 07                	jmp    8002b9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002b5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002b9:	8d 47 01             	lea    0x1(%edi),%eax
  8002bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002bf:	0f b6 07             	movzbl (%edi),%eax
  8002c2:	0f b6 c8             	movzbl %al,%ecx
  8002c5:	83 e8 23             	sub    $0x23,%eax
  8002c8:	3c 55                	cmp    $0x55,%al
  8002ca:	0f 87 5c 03 00 00    	ja     80062c <vprintfmt+0x3cc>
  8002d0:	0f b6 c0             	movzbl %al,%eax
  8002d3:	ff 24 85 a0 0e 80 00 	jmp    *0x800ea0(,%eax,4)
  8002da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002dd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002e1:	eb d6                	jmp    8002b9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8002eb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002ee:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002f1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8002f5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8002f8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8002fb:	83 fa 09             	cmp    $0x9,%edx
  8002fe:	77 39                	ja     800339 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800300:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800303:	eb e9                	jmp    8002ee <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800305:	8b 45 14             	mov    0x14(%ebp),%eax
  800308:	8d 48 04             	lea    0x4(%eax),%ecx
  80030b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80030e:	8b 00                	mov    (%eax),%eax
  800310:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800313:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800316:	eb 27                	jmp    80033f <vprintfmt+0xdf>
  800318:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80031b:	85 c0                	test   %eax,%eax
  80031d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800322:	0f 49 c8             	cmovns %eax,%ecx
  800325:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80032b:	eb 8c                	jmp    8002b9 <vprintfmt+0x59>
  80032d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800330:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800337:	eb 80                	jmp    8002b9 <vprintfmt+0x59>
  800339:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80033c:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80033f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800343:	0f 89 70 ff ff ff    	jns    8002b9 <vprintfmt+0x59>
				width = precision, precision = -1;
  800349:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80034c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80034f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800356:	e9 5e ff ff ff       	jmp    8002b9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80035b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800361:	e9 53 ff ff ff       	jmp    8002b9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800366:	8b 45 14             	mov    0x14(%ebp),%eax
  800369:	8d 50 04             	lea    0x4(%eax),%edx
  80036c:	89 55 14             	mov    %edx,0x14(%ebp)
  80036f:	83 ec 08             	sub    $0x8,%esp
  800372:	53                   	push   %ebx
  800373:	ff 30                	pushl  (%eax)
  800375:	ff d6                	call   *%esi
			break;
  800377:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80037d:	e9 04 ff ff ff       	jmp    800286 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800382:	8b 45 14             	mov    0x14(%ebp),%eax
  800385:	8d 50 04             	lea    0x4(%eax),%edx
  800388:	89 55 14             	mov    %edx,0x14(%ebp)
  80038b:	8b 00                	mov    (%eax),%eax
  80038d:	99                   	cltd   
  80038e:	31 d0                	xor    %edx,%eax
  800390:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800392:	83 f8 07             	cmp    $0x7,%eax
  800395:	7f 0b                	jg     8003a2 <vprintfmt+0x142>
  800397:	8b 14 85 00 10 80 00 	mov    0x801000(,%eax,4),%edx
  80039e:	85 d2                	test   %edx,%edx
  8003a0:	75 18                	jne    8003ba <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003a2:	50                   	push   %eax
  8003a3:	68 00 0e 80 00       	push   $0x800e00
  8003a8:	53                   	push   %ebx
  8003a9:	56                   	push   %esi
  8003aa:	e8 94 fe ff ff       	call   800243 <printfmt>
  8003af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003b5:	e9 cc fe ff ff       	jmp    800286 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003ba:	52                   	push   %edx
  8003bb:	68 09 0e 80 00       	push   $0x800e09
  8003c0:	53                   	push   %ebx
  8003c1:	56                   	push   %esi
  8003c2:	e8 7c fe ff ff       	call   800243 <printfmt>
  8003c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003cd:	e9 b4 fe ff ff       	jmp    800286 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8d 50 04             	lea    0x4(%eax),%edx
  8003d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003db:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003dd:	85 ff                	test   %edi,%edi
  8003df:	b8 f9 0d 80 00       	mov    $0x800df9,%eax
  8003e4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003e7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003eb:	0f 8e 94 00 00 00    	jle    800485 <vprintfmt+0x225>
  8003f1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003f5:	0f 84 98 00 00 00    	je     800493 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003fb:	83 ec 08             	sub    $0x8,%esp
  8003fe:	ff 75 c8             	pushl  -0x38(%ebp)
  800401:	57                   	push   %edi
  800402:	e8 c8 02 00 00       	call   8006cf <strnlen>
  800407:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80040a:	29 c1                	sub    %eax,%ecx
  80040c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80040f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800412:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800416:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800419:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80041c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80041e:	eb 0f                	jmp    80042f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	53                   	push   %ebx
  800424:	ff 75 e0             	pushl  -0x20(%ebp)
  800427:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800429:	83 ef 01             	sub    $0x1,%edi
  80042c:	83 c4 10             	add    $0x10,%esp
  80042f:	85 ff                	test   %edi,%edi
  800431:	7f ed                	jg     800420 <vprintfmt+0x1c0>
  800433:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800436:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800439:	85 c9                	test   %ecx,%ecx
  80043b:	b8 00 00 00 00       	mov    $0x0,%eax
  800440:	0f 49 c1             	cmovns %ecx,%eax
  800443:	29 c1                	sub    %eax,%ecx
  800445:	89 75 08             	mov    %esi,0x8(%ebp)
  800448:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80044b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80044e:	89 cb                	mov    %ecx,%ebx
  800450:	eb 4d                	jmp    80049f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800452:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800456:	74 1b                	je     800473 <vprintfmt+0x213>
  800458:	0f be c0             	movsbl %al,%eax
  80045b:	83 e8 20             	sub    $0x20,%eax
  80045e:	83 f8 5e             	cmp    $0x5e,%eax
  800461:	76 10                	jbe    800473 <vprintfmt+0x213>
					putch('?', putdat);
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	ff 75 0c             	pushl  0xc(%ebp)
  800469:	6a 3f                	push   $0x3f
  80046b:	ff 55 08             	call   *0x8(%ebp)
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	eb 0d                	jmp    800480 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	ff 75 0c             	pushl  0xc(%ebp)
  800479:	52                   	push   %edx
  80047a:	ff 55 08             	call   *0x8(%ebp)
  80047d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800480:	83 eb 01             	sub    $0x1,%ebx
  800483:	eb 1a                	jmp    80049f <vprintfmt+0x23f>
  800485:	89 75 08             	mov    %esi,0x8(%ebp)
  800488:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80048b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800491:	eb 0c                	jmp    80049f <vprintfmt+0x23f>
  800493:	89 75 08             	mov    %esi,0x8(%ebp)
  800496:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800499:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80049f:	83 c7 01             	add    $0x1,%edi
  8004a2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a6:	0f be d0             	movsbl %al,%edx
  8004a9:	85 d2                	test   %edx,%edx
  8004ab:	74 23                	je     8004d0 <vprintfmt+0x270>
  8004ad:	85 f6                	test   %esi,%esi
  8004af:	78 a1                	js     800452 <vprintfmt+0x1f2>
  8004b1:	83 ee 01             	sub    $0x1,%esi
  8004b4:	79 9c                	jns    800452 <vprintfmt+0x1f2>
  8004b6:	89 df                	mov    %ebx,%edi
  8004b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004be:	eb 18                	jmp    8004d8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	53                   	push   %ebx
  8004c4:	6a 20                	push   $0x20
  8004c6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004c8:	83 ef 01             	sub    $0x1,%edi
  8004cb:	83 c4 10             	add    $0x10,%esp
  8004ce:	eb 08                	jmp    8004d8 <vprintfmt+0x278>
  8004d0:	89 df                	mov    %ebx,%edi
  8004d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d8:	85 ff                	test   %edi,%edi
  8004da:	7f e4                	jg     8004c0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004df:	e9 a2 fd ff ff       	jmp    800286 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004e4:	83 fa 01             	cmp    $0x1,%edx
  8004e7:	7e 16                	jle    8004ff <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8004e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ec:	8d 50 08             	lea    0x8(%eax),%edx
  8004ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f2:	8b 50 04             	mov    0x4(%eax),%edx
  8004f5:	8b 00                	mov    (%eax),%eax
  8004f7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004fa:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8004fd:	eb 32                	jmp    800531 <vprintfmt+0x2d1>
	else if (lflag)
  8004ff:	85 d2                	test   %edx,%edx
  800501:	74 18                	je     80051b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8d 50 04             	lea    0x4(%eax),%edx
  800509:	89 55 14             	mov    %edx,0x14(%ebp)
  80050c:	8b 00                	mov    (%eax),%eax
  80050e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800511:	89 c1                	mov    %eax,%ecx
  800513:	c1 f9 1f             	sar    $0x1f,%ecx
  800516:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800519:	eb 16                	jmp    800531 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 50 04             	lea    0x4(%eax),%edx
  800521:	89 55 14             	mov    %edx,0x14(%ebp)
  800524:	8b 00                	mov    (%eax),%eax
  800526:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800529:	89 c1                	mov    %eax,%ecx
  80052b:	c1 f9 1f             	sar    $0x1f,%ecx
  80052e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800531:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800534:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800537:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80053d:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800542:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800546:	0f 89 a8 00 00 00    	jns    8005f4 <vprintfmt+0x394>
				putch('-', putdat);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	53                   	push   %ebx
  800550:	6a 2d                	push   $0x2d
  800552:	ff d6                	call   *%esi
				num = -(long long) num;
  800554:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800557:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80055a:	f7 d8                	neg    %eax
  80055c:	83 d2 00             	adc    $0x0,%edx
  80055f:	f7 da                	neg    %edx
  800561:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800564:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800567:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80056a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056f:	e9 80 00 00 00       	jmp    8005f4 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800574:	8d 45 14             	lea    0x14(%ebp),%eax
  800577:	e8 70 fc ff ff       	call   8001ec <getuint>
  80057c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800582:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800587:	eb 6b                	jmp    8005f4 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800589:	8d 45 14             	lea    0x14(%ebp),%eax
  80058c:	e8 5b fc ff ff       	call   8001ec <getuint>
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800597:	6a 04                	push   $0x4
  800599:	6a 03                	push   $0x3
  80059b:	6a 01                	push   $0x1
  80059d:	68 0c 0e 80 00       	push   $0x800e0c
  8005a2:	e8 82 fb ff ff       	call   800129 <cprintf>
			goto number;
  8005a7:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  8005aa:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  8005af:	eb 43                	jmp    8005f4 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	53                   	push   %ebx
  8005b5:	6a 30                	push   $0x30
  8005b7:	ff d6                	call   *%esi
			putch('x', putdat);
  8005b9:	83 c4 08             	add    $0x8,%esp
  8005bc:	53                   	push   %ebx
  8005bd:	6a 78                	push   $0x78
  8005bf:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8d 50 04             	lea    0x4(%eax),%edx
  8005c7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ca:	8b 00                	mov    (%eax),%eax
  8005cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8005d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005d7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005da:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005df:	eb 13                	jmp    8005f4 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e4:	e8 03 fc ff ff       	call   8001ec <getuint>
  8005e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8005ef:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f4:	83 ec 0c             	sub    $0xc,%esp
  8005f7:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8005fb:	52                   	push   %edx
  8005fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ff:	50                   	push   %eax
  800600:	ff 75 dc             	pushl  -0x24(%ebp)
  800603:	ff 75 d8             	pushl  -0x28(%ebp)
  800606:	89 da                	mov    %ebx,%edx
  800608:	89 f0                	mov    %esi,%eax
  80060a:	e8 2e fb ff ff       	call   80013d <printnum>

			break;
  80060f:	83 c4 20             	add    $0x20,%esp
  800612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800615:	e9 6c fc ff ff       	jmp    800286 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	53                   	push   %ebx
  80061e:	51                   	push   %ecx
  80061f:	ff d6                	call   *%esi
			break;
  800621:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800624:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800627:	e9 5a fc ff ff       	jmp    800286 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 25                	push   $0x25
  800632:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	eb 03                	jmp    80063c <vprintfmt+0x3dc>
  800639:	83 ef 01             	sub    $0x1,%edi
  80063c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800640:	75 f7                	jne    800639 <vprintfmt+0x3d9>
  800642:	e9 3f fc ff ff       	jmp    800286 <vprintfmt+0x26>
			break;
		}

	}

}
  800647:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064a:	5b                   	pop    %ebx
  80064b:	5e                   	pop    %esi
  80064c:	5f                   	pop    %edi
  80064d:	5d                   	pop    %ebp
  80064e:	c3                   	ret    

0080064f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80064f:	55                   	push   %ebp
  800650:	89 e5                	mov    %esp,%ebp
  800652:	83 ec 18             	sub    $0x18,%esp
  800655:	8b 45 08             	mov    0x8(%ebp),%eax
  800658:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80065b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80065e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800662:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800665:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80066c:	85 c0                	test   %eax,%eax
  80066e:	74 26                	je     800696 <vsnprintf+0x47>
  800670:	85 d2                	test   %edx,%edx
  800672:	7e 22                	jle    800696 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800674:	ff 75 14             	pushl  0x14(%ebp)
  800677:	ff 75 10             	pushl  0x10(%ebp)
  80067a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80067d:	50                   	push   %eax
  80067e:	68 26 02 80 00       	push   $0x800226
  800683:	e8 d8 fb ff ff       	call   800260 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800688:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80068b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80068e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	eb 05                	jmp    80069b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800696:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80069b:	c9                   	leave  
  80069c:	c3                   	ret    

0080069d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006a6:	50                   	push   %eax
  8006a7:	ff 75 10             	pushl  0x10(%ebp)
  8006aa:	ff 75 0c             	pushl  0xc(%ebp)
  8006ad:	ff 75 08             	pushl  0x8(%ebp)
  8006b0:	e8 9a ff ff ff       	call   80064f <vsnprintf>
	va_end(ap);

	return rc;
}
  8006b5:	c9                   	leave  
  8006b6:	c3                   	ret    

008006b7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c2:	eb 03                	jmp    8006c7 <strlen+0x10>
		n++;
  8006c4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006cb:	75 f7                	jne    8006c4 <strlen+0xd>
		n++;
	return n;
}
  8006cd:	5d                   	pop    %ebp
  8006ce:	c3                   	ret    

008006cf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006dd:	eb 03                	jmp    8006e2 <strnlen+0x13>
		n++;
  8006df:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e2:	39 c2                	cmp    %eax,%edx
  8006e4:	74 08                	je     8006ee <strnlen+0x1f>
  8006e6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006ea:	75 f3                	jne    8006df <strnlen+0x10>
  8006ec:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006ee:	5d                   	pop    %ebp
  8006ef:	c3                   	ret    

008006f0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	53                   	push   %ebx
  8006f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006fa:	89 c2                	mov    %eax,%edx
  8006fc:	83 c2 01             	add    $0x1,%edx
  8006ff:	83 c1 01             	add    $0x1,%ecx
  800702:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800706:	88 5a ff             	mov    %bl,-0x1(%edx)
  800709:	84 db                	test   %bl,%bl
  80070b:	75 ef                	jne    8006fc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80070d:	5b                   	pop    %ebx
  80070e:	5d                   	pop    %ebp
  80070f:	c3                   	ret    

00800710 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	53                   	push   %ebx
  800714:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800717:	53                   	push   %ebx
  800718:	e8 9a ff ff ff       	call   8006b7 <strlen>
  80071d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800720:	ff 75 0c             	pushl  0xc(%ebp)
  800723:	01 d8                	add    %ebx,%eax
  800725:	50                   	push   %eax
  800726:	e8 c5 ff ff ff       	call   8006f0 <strcpy>
	return dst;
}
  80072b:	89 d8                	mov    %ebx,%eax
  80072d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800730:	c9                   	leave  
  800731:	c3                   	ret    

00800732 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	56                   	push   %esi
  800736:	53                   	push   %ebx
  800737:	8b 75 08             	mov    0x8(%ebp),%esi
  80073a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80073d:	89 f3                	mov    %esi,%ebx
  80073f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800742:	89 f2                	mov    %esi,%edx
  800744:	eb 0f                	jmp    800755 <strncpy+0x23>
		*dst++ = *src;
  800746:	83 c2 01             	add    $0x1,%edx
  800749:	0f b6 01             	movzbl (%ecx),%eax
  80074c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80074f:	80 39 01             	cmpb   $0x1,(%ecx)
  800752:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800755:	39 da                	cmp    %ebx,%edx
  800757:	75 ed                	jne    800746 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800759:	89 f0                	mov    %esi,%eax
  80075b:	5b                   	pop    %ebx
  80075c:	5e                   	pop    %esi
  80075d:	5d                   	pop    %ebp
  80075e:	c3                   	ret    

0080075f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	56                   	push   %esi
  800763:	53                   	push   %ebx
  800764:	8b 75 08             	mov    0x8(%ebp),%esi
  800767:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80076a:	8b 55 10             	mov    0x10(%ebp),%edx
  80076d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80076f:	85 d2                	test   %edx,%edx
  800771:	74 21                	je     800794 <strlcpy+0x35>
  800773:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800777:	89 f2                	mov    %esi,%edx
  800779:	eb 09                	jmp    800784 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80077b:	83 c2 01             	add    $0x1,%edx
  80077e:	83 c1 01             	add    $0x1,%ecx
  800781:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800784:	39 c2                	cmp    %eax,%edx
  800786:	74 09                	je     800791 <strlcpy+0x32>
  800788:	0f b6 19             	movzbl (%ecx),%ebx
  80078b:	84 db                	test   %bl,%bl
  80078d:	75 ec                	jne    80077b <strlcpy+0x1c>
  80078f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800791:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800794:	29 f0                	sub    %esi,%eax
}
  800796:	5b                   	pop    %ebx
  800797:	5e                   	pop    %esi
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007a3:	eb 06                	jmp    8007ab <strcmp+0x11>
		p++, q++;
  8007a5:	83 c1 01             	add    $0x1,%ecx
  8007a8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007ab:	0f b6 01             	movzbl (%ecx),%eax
  8007ae:	84 c0                	test   %al,%al
  8007b0:	74 04                	je     8007b6 <strcmp+0x1c>
  8007b2:	3a 02                	cmp    (%edx),%al
  8007b4:	74 ef                	je     8007a5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007b6:	0f b6 c0             	movzbl %al,%eax
  8007b9:	0f b6 12             	movzbl (%edx),%edx
  8007bc:	29 d0                	sub    %edx,%eax
}
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	53                   	push   %ebx
  8007c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ca:	89 c3                	mov    %eax,%ebx
  8007cc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007cf:	eb 06                	jmp    8007d7 <strncmp+0x17>
		n--, p++, q++;
  8007d1:	83 c0 01             	add    $0x1,%eax
  8007d4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007d7:	39 d8                	cmp    %ebx,%eax
  8007d9:	74 15                	je     8007f0 <strncmp+0x30>
  8007db:	0f b6 08             	movzbl (%eax),%ecx
  8007de:	84 c9                	test   %cl,%cl
  8007e0:	74 04                	je     8007e6 <strncmp+0x26>
  8007e2:	3a 0a                	cmp    (%edx),%cl
  8007e4:	74 eb                	je     8007d1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e6:	0f b6 00             	movzbl (%eax),%eax
  8007e9:	0f b6 12             	movzbl (%edx),%edx
  8007ec:	29 d0                	sub    %edx,%eax
  8007ee:	eb 05                	jmp    8007f5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007f5:	5b                   	pop    %ebx
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800802:	eb 07                	jmp    80080b <strchr+0x13>
		if (*s == c)
  800804:	38 ca                	cmp    %cl,%dl
  800806:	74 0f                	je     800817 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800808:	83 c0 01             	add    $0x1,%eax
  80080b:	0f b6 10             	movzbl (%eax),%edx
  80080e:	84 d2                	test   %dl,%dl
  800810:	75 f2                	jne    800804 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800823:	eb 03                	jmp    800828 <strfind+0xf>
  800825:	83 c0 01             	add    $0x1,%eax
  800828:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80082b:	38 ca                	cmp    %cl,%dl
  80082d:	74 04                	je     800833 <strfind+0x1a>
  80082f:	84 d2                	test   %dl,%dl
  800831:	75 f2                	jne    800825 <strfind+0xc>
			break;
	return (char *) s;
}
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	57                   	push   %edi
  800839:	56                   	push   %esi
  80083a:	53                   	push   %ebx
  80083b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80083e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800841:	85 c9                	test   %ecx,%ecx
  800843:	74 36                	je     80087b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800845:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80084b:	75 28                	jne    800875 <memset+0x40>
  80084d:	f6 c1 03             	test   $0x3,%cl
  800850:	75 23                	jne    800875 <memset+0x40>
		c &= 0xFF;
  800852:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800856:	89 d3                	mov    %edx,%ebx
  800858:	c1 e3 08             	shl    $0x8,%ebx
  80085b:	89 d6                	mov    %edx,%esi
  80085d:	c1 e6 18             	shl    $0x18,%esi
  800860:	89 d0                	mov    %edx,%eax
  800862:	c1 e0 10             	shl    $0x10,%eax
  800865:	09 f0                	or     %esi,%eax
  800867:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800869:	89 d8                	mov    %ebx,%eax
  80086b:	09 d0                	or     %edx,%eax
  80086d:	c1 e9 02             	shr    $0x2,%ecx
  800870:	fc                   	cld    
  800871:	f3 ab                	rep stos %eax,%es:(%edi)
  800873:	eb 06                	jmp    80087b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800875:	8b 45 0c             	mov    0xc(%ebp),%eax
  800878:	fc                   	cld    
  800879:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80087b:	89 f8                	mov    %edi,%eax
  80087d:	5b                   	pop    %ebx
  80087e:	5e                   	pop    %esi
  80087f:	5f                   	pop    %edi
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	57                   	push   %edi
  800886:	56                   	push   %esi
  800887:	8b 45 08             	mov    0x8(%ebp),%eax
  80088a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80088d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800890:	39 c6                	cmp    %eax,%esi
  800892:	73 35                	jae    8008c9 <memmove+0x47>
  800894:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800897:	39 d0                	cmp    %edx,%eax
  800899:	73 2e                	jae    8008c9 <memmove+0x47>
		s += n;
		d += n;
  80089b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80089e:	89 d6                	mov    %edx,%esi
  8008a0:	09 fe                	or     %edi,%esi
  8008a2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008a8:	75 13                	jne    8008bd <memmove+0x3b>
  8008aa:	f6 c1 03             	test   $0x3,%cl
  8008ad:	75 0e                	jne    8008bd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008af:	83 ef 04             	sub    $0x4,%edi
  8008b2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008b5:	c1 e9 02             	shr    $0x2,%ecx
  8008b8:	fd                   	std    
  8008b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008bb:	eb 09                	jmp    8008c6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008bd:	83 ef 01             	sub    $0x1,%edi
  8008c0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008c3:	fd                   	std    
  8008c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008c6:	fc                   	cld    
  8008c7:	eb 1d                	jmp    8008e6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c9:	89 f2                	mov    %esi,%edx
  8008cb:	09 c2                	or     %eax,%edx
  8008cd:	f6 c2 03             	test   $0x3,%dl
  8008d0:	75 0f                	jne    8008e1 <memmove+0x5f>
  8008d2:	f6 c1 03             	test   $0x3,%cl
  8008d5:	75 0a                	jne    8008e1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008d7:	c1 e9 02             	shr    $0x2,%ecx
  8008da:	89 c7                	mov    %eax,%edi
  8008dc:	fc                   	cld    
  8008dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008df:	eb 05                	jmp    8008e6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e1:	89 c7                	mov    %eax,%edi
  8008e3:	fc                   	cld    
  8008e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008e6:	5e                   	pop    %esi
  8008e7:	5f                   	pop    %edi
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008ed:	ff 75 10             	pushl  0x10(%ebp)
  8008f0:	ff 75 0c             	pushl  0xc(%ebp)
  8008f3:	ff 75 08             	pushl  0x8(%ebp)
  8008f6:	e8 87 ff ff ff       	call   800882 <memmove>
}
  8008fb:	c9                   	leave  
  8008fc:	c3                   	ret    

008008fd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	56                   	push   %esi
  800901:	53                   	push   %ebx
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	8b 55 0c             	mov    0xc(%ebp),%edx
  800908:	89 c6                	mov    %eax,%esi
  80090a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80090d:	eb 1a                	jmp    800929 <memcmp+0x2c>
		if (*s1 != *s2)
  80090f:	0f b6 08             	movzbl (%eax),%ecx
  800912:	0f b6 1a             	movzbl (%edx),%ebx
  800915:	38 d9                	cmp    %bl,%cl
  800917:	74 0a                	je     800923 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800919:	0f b6 c1             	movzbl %cl,%eax
  80091c:	0f b6 db             	movzbl %bl,%ebx
  80091f:	29 d8                	sub    %ebx,%eax
  800921:	eb 0f                	jmp    800932 <memcmp+0x35>
		s1++, s2++;
  800923:	83 c0 01             	add    $0x1,%eax
  800926:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800929:	39 f0                	cmp    %esi,%eax
  80092b:	75 e2                	jne    80090f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80092d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800932:	5b                   	pop    %ebx
  800933:	5e                   	pop    %esi
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	53                   	push   %ebx
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80093d:	89 c1                	mov    %eax,%ecx
  80093f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800942:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800946:	eb 0a                	jmp    800952 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800948:	0f b6 10             	movzbl (%eax),%edx
  80094b:	39 da                	cmp    %ebx,%edx
  80094d:	74 07                	je     800956 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80094f:	83 c0 01             	add    $0x1,%eax
  800952:	39 c8                	cmp    %ecx,%eax
  800954:	72 f2                	jb     800948 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800956:	5b                   	pop    %ebx
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	57                   	push   %edi
  80095d:	56                   	push   %esi
  80095e:	53                   	push   %ebx
  80095f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800962:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800965:	eb 03                	jmp    80096a <strtol+0x11>
		s++;
  800967:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096a:	0f b6 01             	movzbl (%ecx),%eax
  80096d:	3c 20                	cmp    $0x20,%al
  80096f:	74 f6                	je     800967 <strtol+0xe>
  800971:	3c 09                	cmp    $0x9,%al
  800973:	74 f2                	je     800967 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800975:	3c 2b                	cmp    $0x2b,%al
  800977:	75 0a                	jne    800983 <strtol+0x2a>
		s++;
  800979:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80097c:	bf 00 00 00 00       	mov    $0x0,%edi
  800981:	eb 11                	jmp    800994 <strtol+0x3b>
  800983:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800988:	3c 2d                	cmp    $0x2d,%al
  80098a:	75 08                	jne    800994 <strtol+0x3b>
		s++, neg = 1;
  80098c:	83 c1 01             	add    $0x1,%ecx
  80098f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800994:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80099a:	75 15                	jne    8009b1 <strtol+0x58>
  80099c:	80 39 30             	cmpb   $0x30,(%ecx)
  80099f:	75 10                	jne    8009b1 <strtol+0x58>
  8009a1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009a5:	75 7c                	jne    800a23 <strtol+0xca>
		s += 2, base = 16;
  8009a7:	83 c1 02             	add    $0x2,%ecx
  8009aa:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009af:	eb 16                	jmp    8009c7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009b1:	85 db                	test   %ebx,%ebx
  8009b3:	75 12                	jne    8009c7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009b5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ba:	80 39 30             	cmpb   $0x30,(%ecx)
  8009bd:	75 08                	jne    8009c7 <strtol+0x6e>
		s++, base = 8;
  8009bf:	83 c1 01             	add    $0x1,%ecx
  8009c2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009cf:	0f b6 11             	movzbl (%ecx),%edx
  8009d2:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009d5:	89 f3                	mov    %esi,%ebx
  8009d7:	80 fb 09             	cmp    $0x9,%bl
  8009da:	77 08                	ja     8009e4 <strtol+0x8b>
			dig = *s - '0';
  8009dc:	0f be d2             	movsbl %dl,%edx
  8009df:	83 ea 30             	sub    $0x30,%edx
  8009e2:	eb 22                	jmp    800a06 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009e4:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009e7:	89 f3                	mov    %esi,%ebx
  8009e9:	80 fb 19             	cmp    $0x19,%bl
  8009ec:	77 08                	ja     8009f6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009ee:	0f be d2             	movsbl %dl,%edx
  8009f1:	83 ea 57             	sub    $0x57,%edx
  8009f4:	eb 10                	jmp    800a06 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009f6:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009f9:	89 f3                	mov    %esi,%ebx
  8009fb:	80 fb 19             	cmp    $0x19,%bl
  8009fe:	77 16                	ja     800a16 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a00:	0f be d2             	movsbl %dl,%edx
  800a03:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a06:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a09:	7d 0b                	jge    800a16 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a0b:	83 c1 01             	add    $0x1,%ecx
  800a0e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a12:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a14:	eb b9                	jmp    8009cf <strtol+0x76>

	if (endptr)
  800a16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a1a:	74 0d                	je     800a29 <strtol+0xd0>
		*endptr = (char *) s;
  800a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1f:	89 0e                	mov    %ecx,(%esi)
  800a21:	eb 06                	jmp    800a29 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a23:	85 db                	test   %ebx,%ebx
  800a25:	74 98                	je     8009bf <strtol+0x66>
  800a27:	eb 9e                	jmp    8009c7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a29:	89 c2                	mov    %eax,%edx
  800a2b:	f7 da                	neg    %edx
  800a2d:	85 ff                	test   %edi,%edi
  800a2f:	0f 45 c2             	cmovne %edx,%eax
}
  800a32:	5b                   	pop    %ebx
  800a33:	5e                   	pop    %esi
  800a34:	5f                   	pop    %edi
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	57                   	push   %edi
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a45:	8b 55 08             	mov    0x8(%ebp),%edx
  800a48:	89 c3                	mov    %eax,%ebx
  800a4a:	89 c7                	mov    %eax,%edi
  800a4c:	89 c6                	mov    %eax,%esi
  800a4e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a50:	5b                   	pop    %ebx
  800a51:	5e                   	pop    %esi
  800a52:	5f                   	pop    %edi
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	57                   	push   %edi
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a60:	b8 01 00 00 00       	mov    $0x1,%eax
  800a65:	89 d1                	mov    %edx,%ecx
  800a67:	89 d3                	mov    %edx,%ebx
  800a69:	89 d7                	mov    %edx,%edi
  800a6b:	89 d6                	mov    %edx,%esi
  800a6d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a6f:	5b                   	pop    %ebx
  800a70:	5e                   	pop    %esi
  800a71:	5f                   	pop    %edi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
  800a7a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a82:	b8 03 00 00 00       	mov    $0x3,%eax
  800a87:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8a:	89 cb                	mov    %ecx,%ebx
  800a8c:	89 cf                	mov    %ecx,%edi
  800a8e:	89 ce                	mov    %ecx,%esi
  800a90:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800a92:	85 c0                	test   %eax,%eax
  800a94:	7e 17                	jle    800aad <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a96:	83 ec 0c             	sub    $0xc,%esp
  800a99:	50                   	push   %eax
  800a9a:	6a 03                	push   $0x3
  800a9c:	68 20 10 80 00       	push   $0x801020
  800aa1:	6a 23                	push   $0x23
  800aa3:	68 3d 10 80 00       	push   $0x80103d
  800aa8:	e8 27 00 00 00       	call   800ad4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5f                   	pop    %edi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	57                   	push   %edi
  800ab9:	56                   	push   %esi
  800aba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ac5:	89 d1                	mov    %edx,%ecx
  800ac7:	89 d3                	mov    %edx,%ebx
  800ac9:	89 d7                	mov    %edx,%edi
  800acb:	89 d6                	mov    %edx,%esi
  800acd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5f                   	pop    %edi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ad9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800adc:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ae2:	e8 ce ff ff ff       	call   800ab5 <sys_getenvid>
  800ae7:	83 ec 0c             	sub    $0xc,%esp
  800aea:	ff 75 0c             	pushl  0xc(%ebp)
  800aed:	ff 75 08             	pushl  0x8(%ebp)
  800af0:	56                   	push   %esi
  800af1:	50                   	push   %eax
  800af2:	68 4c 10 80 00       	push   $0x80104c
  800af7:	e8 2d f6 ff ff       	call   800129 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800afc:	83 c4 18             	add    $0x18,%esp
  800aff:	53                   	push   %ebx
  800b00:	ff 75 10             	pushl  0x10(%ebp)
  800b03:	e8 d0 f5 ff ff       	call   8000d8 <vcprintf>
	cprintf("\n");
  800b08:	c7 04 24 dc 0d 80 00 	movl   $0x800ddc,(%esp)
  800b0f:	e8 15 f6 ff ff       	call   800129 <cprintf>
  800b14:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b17:	cc                   	int3   
  800b18:	eb fd                	jmp    800b17 <_panic+0x43>
  800b1a:	66 90                	xchg   %ax,%ax
  800b1c:	66 90                	xchg   %ax,%ax
  800b1e:	66 90                	xchg   %ax,%ax

00800b20 <__udivdi3>:
  800b20:	55                   	push   %ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
  800b24:	83 ec 1c             	sub    $0x1c,%esp
  800b27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800b2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800b2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800b33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b37:	85 f6                	test   %esi,%esi
  800b39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b3d:	89 ca                	mov    %ecx,%edx
  800b3f:	89 f8                	mov    %edi,%eax
  800b41:	75 3d                	jne    800b80 <__udivdi3+0x60>
  800b43:	39 cf                	cmp    %ecx,%edi
  800b45:	0f 87 c5 00 00 00    	ja     800c10 <__udivdi3+0xf0>
  800b4b:	85 ff                	test   %edi,%edi
  800b4d:	89 fd                	mov    %edi,%ebp
  800b4f:	75 0b                	jne    800b5c <__udivdi3+0x3c>
  800b51:	b8 01 00 00 00       	mov    $0x1,%eax
  800b56:	31 d2                	xor    %edx,%edx
  800b58:	f7 f7                	div    %edi
  800b5a:	89 c5                	mov    %eax,%ebp
  800b5c:	89 c8                	mov    %ecx,%eax
  800b5e:	31 d2                	xor    %edx,%edx
  800b60:	f7 f5                	div    %ebp
  800b62:	89 c1                	mov    %eax,%ecx
  800b64:	89 d8                	mov    %ebx,%eax
  800b66:	89 cf                	mov    %ecx,%edi
  800b68:	f7 f5                	div    %ebp
  800b6a:	89 c3                	mov    %eax,%ebx
  800b6c:	89 d8                	mov    %ebx,%eax
  800b6e:	89 fa                	mov    %edi,%edx
  800b70:	83 c4 1c             	add    $0x1c,%esp
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    
  800b78:	90                   	nop
  800b79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800b80:	39 ce                	cmp    %ecx,%esi
  800b82:	77 74                	ja     800bf8 <__udivdi3+0xd8>
  800b84:	0f bd fe             	bsr    %esi,%edi
  800b87:	83 f7 1f             	xor    $0x1f,%edi
  800b8a:	0f 84 98 00 00 00    	je     800c28 <__udivdi3+0x108>
  800b90:	bb 20 00 00 00       	mov    $0x20,%ebx
  800b95:	89 f9                	mov    %edi,%ecx
  800b97:	89 c5                	mov    %eax,%ebp
  800b99:	29 fb                	sub    %edi,%ebx
  800b9b:	d3 e6                	shl    %cl,%esi
  800b9d:	89 d9                	mov    %ebx,%ecx
  800b9f:	d3 ed                	shr    %cl,%ebp
  800ba1:	89 f9                	mov    %edi,%ecx
  800ba3:	d3 e0                	shl    %cl,%eax
  800ba5:	09 ee                	or     %ebp,%esi
  800ba7:	89 d9                	mov    %ebx,%ecx
  800ba9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bad:	89 d5                	mov    %edx,%ebp
  800baf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800bb3:	d3 ed                	shr    %cl,%ebp
  800bb5:	89 f9                	mov    %edi,%ecx
  800bb7:	d3 e2                	shl    %cl,%edx
  800bb9:	89 d9                	mov    %ebx,%ecx
  800bbb:	d3 e8                	shr    %cl,%eax
  800bbd:	09 c2                	or     %eax,%edx
  800bbf:	89 d0                	mov    %edx,%eax
  800bc1:	89 ea                	mov    %ebp,%edx
  800bc3:	f7 f6                	div    %esi
  800bc5:	89 d5                	mov    %edx,%ebp
  800bc7:	89 c3                	mov    %eax,%ebx
  800bc9:	f7 64 24 0c          	mull   0xc(%esp)
  800bcd:	39 d5                	cmp    %edx,%ebp
  800bcf:	72 10                	jb     800be1 <__udivdi3+0xc1>
  800bd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800bd5:	89 f9                	mov    %edi,%ecx
  800bd7:	d3 e6                	shl    %cl,%esi
  800bd9:	39 c6                	cmp    %eax,%esi
  800bdb:	73 07                	jae    800be4 <__udivdi3+0xc4>
  800bdd:	39 d5                	cmp    %edx,%ebp
  800bdf:	75 03                	jne    800be4 <__udivdi3+0xc4>
  800be1:	83 eb 01             	sub    $0x1,%ebx
  800be4:	31 ff                	xor    %edi,%edi
  800be6:	89 d8                	mov    %ebx,%eax
  800be8:	89 fa                	mov    %edi,%edx
  800bea:	83 c4 1c             	add    $0x1c,%esp
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    
  800bf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800bf8:	31 ff                	xor    %edi,%edi
  800bfa:	31 db                	xor    %ebx,%ebx
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
  800c10:	89 d8                	mov    %ebx,%eax
  800c12:	f7 f7                	div    %edi
  800c14:	31 ff                	xor    %edi,%edi
  800c16:	89 c3                	mov    %eax,%ebx
  800c18:	89 d8                	mov    %ebx,%eax
  800c1a:	89 fa                	mov    %edi,%edx
  800c1c:	83 c4 1c             	add    $0x1c,%esp
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    
  800c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c28:	39 ce                	cmp    %ecx,%esi
  800c2a:	72 0c                	jb     800c38 <__udivdi3+0x118>
  800c2c:	31 db                	xor    %ebx,%ebx
  800c2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800c32:	0f 87 34 ff ff ff    	ja     800b6c <__udivdi3+0x4c>
  800c38:	bb 01 00 00 00       	mov    $0x1,%ebx
  800c3d:	e9 2a ff ff ff       	jmp    800b6c <__udivdi3+0x4c>
  800c42:	66 90                	xchg   %ax,%ax
  800c44:	66 90                	xchg   %ax,%ax
  800c46:	66 90                	xchg   %ax,%ax
  800c48:	66 90                	xchg   %ax,%ax
  800c4a:	66 90                	xchg   %ax,%ax
  800c4c:	66 90                	xchg   %ax,%ax
  800c4e:	66 90                	xchg   %ax,%ax

00800c50 <__umoddi3>:
  800c50:	55                   	push   %ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
  800c54:	83 ec 1c             	sub    $0x1c,%esp
  800c57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c67:	85 d2                	test   %edx,%edx
  800c69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c71:	89 f3                	mov    %esi,%ebx
  800c73:	89 3c 24             	mov    %edi,(%esp)
  800c76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c7a:	75 1c                	jne    800c98 <__umoddi3+0x48>
  800c7c:	39 f7                	cmp    %esi,%edi
  800c7e:	76 50                	jbe    800cd0 <__umoddi3+0x80>
  800c80:	89 c8                	mov    %ecx,%eax
  800c82:	89 f2                	mov    %esi,%edx
  800c84:	f7 f7                	div    %edi
  800c86:	89 d0                	mov    %edx,%eax
  800c88:	31 d2                	xor    %edx,%edx
  800c8a:	83 c4 1c             	add    $0x1c,%esp
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    
  800c92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c98:	39 f2                	cmp    %esi,%edx
  800c9a:	89 d0                	mov    %edx,%eax
  800c9c:	77 52                	ja     800cf0 <__umoddi3+0xa0>
  800c9e:	0f bd ea             	bsr    %edx,%ebp
  800ca1:	83 f5 1f             	xor    $0x1f,%ebp
  800ca4:	75 5a                	jne    800d00 <__umoddi3+0xb0>
  800ca6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800caa:	0f 82 e0 00 00 00    	jb     800d90 <__umoddi3+0x140>
  800cb0:	39 0c 24             	cmp    %ecx,(%esp)
  800cb3:	0f 86 d7 00 00 00    	jbe    800d90 <__umoddi3+0x140>
  800cb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800cbd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800cc1:	83 c4 1c             	add    $0x1c,%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    
  800cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cd0:	85 ff                	test   %edi,%edi
  800cd2:	89 fd                	mov    %edi,%ebp
  800cd4:	75 0b                	jne    800ce1 <__umoddi3+0x91>
  800cd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800cdb:	31 d2                	xor    %edx,%edx
  800cdd:	f7 f7                	div    %edi
  800cdf:	89 c5                	mov    %eax,%ebp
  800ce1:	89 f0                	mov    %esi,%eax
  800ce3:	31 d2                	xor    %edx,%edx
  800ce5:	f7 f5                	div    %ebp
  800ce7:	89 c8                	mov    %ecx,%eax
  800ce9:	f7 f5                	div    %ebp
  800ceb:	89 d0                	mov    %edx,%eax
  800ced:	eb 99                	jmp    800c88 <__umoddi3+0x38>
  800cef:	90                   	nop
  800cf0:	89 c8                	mov    %ecx,%eax
  800cf2:	89 f2                	mov    %esi,%edx
  800cf4:	83 c4 1c             	add    $0x1c,%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    
  800cfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d00:	8b 34 24             	mov    (%esp),%esi
  800d03:	bf 20 00 00 00       	mov    $0x20,%edi
  800d08:	89 e9                	mov    %ebp,%ecx
  800d0a:	29 ef                	sub    %ebp,%edi
  800d0c:	d3 e0                	shl    %cl,%eax
  800d0e:	89 f9                	mov    %edi,%ecx
  800d10:	89 f2                	mov    %esi,%edx
  800d12:	d3 ea                	shr    %cl,%edx
  800d14:	89 e9                	mov    %ebp,%ecx
  800d16:	09 c2                	or     %eax,%edx
  800d18:	89 d8                	mov    %ebx,%eax
  800d1a:	89 14 24             	mov    %edx,(%esp)
  800d1d:	89 f2                	mov    %esi,%edx
  800d1f:	d3 e2                	shl    %cl,%edx
  800d21:	89 f9                	mov    %edi,%ecx
  800d23:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d2b:	d3 e8                	shr    %cl,%eax
  800d2d:	89 e9                	mov    %ebp,%ecx
  800d2f:	89 c6                	mov    %eax,%esi
  800d31:	d3 e3                	shl    %cl,%ebx
  800d33:	89 f9                	mov    %edi,%ecx
  800d35:	89 d0                	mov    %edx,%eax
  800d37:	d3 e8                	shr    %cl,%eax
  800d39:	89 e9                	mov    %ebp,%ecx
  800d3b:	09 d8                	or     %ebx,%eax
  800d3d:	89 d3                	mov    %edx,%ebx
  800d3f:	89 f2                	mov    %esi,%edx
  800d41:	f7 34 24             	divl   (%esp)
  800d44:	89 d6                	mov    %edx,%esi
  800d46:	d3 e3                	shl    %cl,%ebx
  800d48:	f7 64 24 04          	mull   0x4(%esp)
  800d4c:	39 d6                	cmp    %edx,%esi
  800d4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d52:	89 d1                	mov    %edx,%ecx
  800d54:	89 c3                	mov    %eax,%ebx
  800d56:	72 08                	jb     800d60 <__umoddi3+0x110>
  800d58:	75 11                	jne    800d6b <__umoddi3+0x11b>
  800d5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800d5e:	73 0b                	jae    800d6b <__umoddi3+0x11b>
  800d60:	2b 44 24 04          	sub    0x4(%esp),%eax
  800d64:	1b 14 24             	sbb    (%esp),%edx
  800d67:	89 d1                	mov    %edx,%ecx
  800d69:	89 c3                	mov    %eax,%ebx
  800d6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800d6f:	29 da                	sub    %ebx,%edx
  800d71:	19 ce                	sbb    %ecx,%esi
  800d73:	89 f9                	mov    %edi,%ecx
  800d75:	89 f0                	mov    %esi,%eax
  800d77:	d3 e0                	shl    %cl,%eax
  800d79:	89 e9                	mov    %ebp,%ecx
  800d7b:	d3 ea                	shr    %cl,%edx
  800d7d:	89 e9                	mov    %ebp,%ecx
  800d7f:	d3 ee                	shr    %cl,%esi
  800d81:	09 d0                	or     %edx,%eax
  800d83:	89 f2                	mov    %esi,%edx
  800d85:	83 c4 1c             	add    $0x1c,%esp
  800d88:	5b                   	pop    %ebx
  800d89:	5e                   	pop    %esi
  800d8a:	5f                   	pop    %edi
  800d8b:	5d                   	pop    %ebp
  800d8c:	c3                   	ret    
  800d8d:	8d 76 00             	lea    0x0(%esi),%esi
  800d90:	29 f9                	sub    %edi,%ecx
  800d92:	19 d6                	sbb    %edx,%esi
  800d94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d9c:	e9 18 ff ff ff       	jmp    800cb9 <__umoddi3+0x69>