
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
  800039:	68 c0 0d 80 00       	push   $0x800dc0
  80003e:	e8 f6 00 00 00       	call   800139 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 ce 0d 80 00       	push   $0x800dce
  800054:	e8 e0 00 00 00       	call   800139 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	83 ec 08             	sub    $0x8,%esp
  800064:	8b 45 08             	mov    0x8(%ebp),%eax
  800067:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800071:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800074:	85 c0                	test   %eax,%eax
  800076:	7e 08                	jle    800080 <libmain+0x22>
		binaryname = argv[0];
  800078:	8b 0a                	mov    (%edx),%ecx
  80007a:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800080:	83 ec 08             	sub    $0x8,%esp
  800083:	52                   	push   %edx
  800084:	50                   	push   %eax
  800085:	e8 a9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008a:	e8 05 00 00 00       	call   800094 <exit>
}
  80008f:	83 c4 10             	add    $0x10,%esp
  800092:	c9                   	leave  
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 e3 09 00 00       	call   800a84 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	53                   	push   %ebx
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b0:	8b 13                	mov    (%ebx),%edx
  8000b2:	8d 42 01             	lea    0x1(%edx),%eax
  8000b5:	89 03                	mov    %eax,(%ebx)
  8000b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c3:	75 1a                	jne    8000df <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000c5:	83 ec 08             	sub    $0x8,%esp
  8000c8:	68 ff 00 00 00       	push   $0xff
  8000cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d0:	50                   	push   %eax
  8000d1:	e8 71 09 00 00       	call   800a47 <sys_cputs>
		b->idx = 0;
  8000d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    

008000e8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000f8:	00 00 00 
	b.cnt = 0;
  8000fb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800102:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800105:	ff 75 0c             	pushl  0xc(%ebp)
  800108:	ff 75 08             	pushl  0x8(%ebp)
  80010b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800111:	50                   	push   %eax
  800112:	68 a6 00 80 00       	push   $0x8000a6
  800117:	e8 54 01 00 00       	call   800270 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011c:	83 c4 08             	add    $0x8,%esp
  80011f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800125:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 16 09 00 00       	call   800a47 <sys_cputs>

	return b.cnt;
}
  800131:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800137:	c9                   	leave  
  800138:	c3                   	ret    

00800139 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80013f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800142:	50                   	push   %eax
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	e8 9d ff ff ff       	call   8000e8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
  800153:	83 ec 1c             	sub    $0x1c,%esp
  800156:	89 c7                	mov    %eax,%edi
  800158:	89 d6                	mov    %edx,%esi
  80015a:	8b 45 08             	mov    0x8(%ebp),%eax
  80015d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800160:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800163:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800166:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800169:	bb 00 00 00 00       	mov    $0x0,%ebx
  80016e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800171:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800174:	39 d3                	cmp    %edx,%ebx
  800176:	72 05                	jb     80017d <printnum+0x30>
  800178:	39 45 10             	cmp    %eax,0x10(%ebp)
  80017b:	77 45                	ja     8001c2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	ff 75 18             	pushl  0x18(%ebp)
  800183:	8b 45 14             	mov    0x14(%ebp),%eax
  800186:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800189:	53                   	push   %ebx
  80018a:	ff 75 10             	pushl  0x10(%ebp)
  80018d:	83 ec 08             	sub    $0x8,%esp
  800190:	ff 75 e4             	pushl  -0x1c(%ebp)
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	ff 75 dc             	pushl  -0x24(%ebp)
  800199:	ff 75 d8             	pushl  -0x28(%ebp)
  80019c:	e8 8f 09 00 00       	call   800b30 <__udivdi3>
  8001a1:	83 c4 18             	add    $0x18,%esp
  8001a4:	52                   	push   %edx
  8001a5:	50                   	push   %eax
  8001a6:	89 f2                	mov    %esi,%edx
  8001a8:	89 f8                	mov    %edi,%eax
  8001aa:	e8 9e ff ff ff       	call   80014d <printnum>
  8001af:	83 c4 20             	add    $0x20,%esp
  8001b2:	eb 18                	jmp    8001cc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	56                   	push   %esi
  8001b8:	ff 75 18             	pushl  0x18(%ebp)
  8001bb:	ff d7                	call   *%edi
  8001bd:	83 c4 10             	add    $0x10,%esp
  8001c0:	eb 03                	jmp    8001c5 <printnum+0x78>
  8001c2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c5:	83 eb 01             	sub    $0x1,%ebx
  8001c8:	85 db                	test   %ebx,%ebx
  8001ca:	7f e8                	jg     8001b4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	83 ec 04             	sub    $0x4,%esp
  8001d3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001dc:	ff 75 d8             	pushl  -0x28(%ebp)
  8001df:	e8 7c 0a 00 00       	call   800c60 <__umoddi3>
  8001e4:	83 c4 14             	add    $0x14,%esp
  8001e7:	0f be 80 ef 0d 80 00 	movsbl 0x800def(%eax),%eax
  8001ee:	50                   	push   %eax
  8001ef:	ff d7                	call   *%edi
}
  8001f1:	83 c4 10             	add    $0x10,%esp
  8001f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f7:	5b                   	pop    %ebx
  8001f8:	5e                   	pop    %esi
  8001f9:	5f                   	pop    %edi
  8001fa:	5d                   	pop    %ebp
  8001fb:	c3                   	ret    

008001fc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8001ff:	83 fa 01             	cmp    $0x1,%edx
  800202:	7e 0e                	jle    800212 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800204:	8b 10                	mov    (%eax),%edx
  800206:	8d 4a 08             	lea    0x8(%edx),%ecx
  800209:	89 08                	mov    %ecx,(%eax)
  80020b:	8b 02                	mov    (%edx),%eax
  80020d:	8b 52 04             	mov    0x4(%edx),%edx
  800210:	eb 22                	jmp    800234 <getuint+0x38>
	else if (lflag)
  800212:	85 d2                	test   %edx,%edx
  800214:	74 10                	je     800226 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800216:	8b 10                	mov    (%eax),%edx
  800218:	8d 4a 04             	lea    0x4(%edx),%ecx
  80021b:	89 08                	mov    %ecx,(%eax)
  80021d:	8b 02                	mov    (%edx),%eax
  80021f:	ba 00 00 00 00       	mov    $0x0,%edx
  800224:	eb 0e                	jmp    800234 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800226:	8b 10                	mov    (%eax),%edx
  800228:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022b:	89 08                	mov    %ecx,(%eax)
  80022d:	8b 02                	mov    (%edx),%eax
  80022f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800240:	8b 10                	mov    (%eax),%edx
  800242:	3b 50 04             	cmp    0x4(%eax),%edx
  800245:	73 0a                	jae    800251 <sprintputch+0x1b>
		*b->buf++ = ch;
  800247:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024a:	89 08                	mov    %ecx,(%eax)
  80024c:	8b 45 08             	mov    0x8(%ebp),%eax
  80024f:	88 02                	mov    %al,(%edx)
}
  800251:	5d                   	pop    %ebp
  800252:	c3                   	ret    

00800253 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800259:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025c:	50                   	push   %eax
  80025d:	ff 75 10             	pushl  0x10(%ebp)
  800260:	ff 75 0c             	pushl  0xc(%ebp)
  800263:	ff 75 08             	pushl  0x8(%ebp)
  800266:	e8 05 00 00 00       	call   800270 <vprintfmt>
	va_end(ap);
}
  80026b:	83 c4 10             	add    $0x10,%esp
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 2c             	sub    $0x2c,%esp
  800279:	8b 75 08             	mov    0x8(%ebp),%esi
  80027c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80027f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800282:	eb 12                	jmp    800296 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800284:	85 c0                	test   %eax,%eax
  800286:	0f 84 cb 03 00 00    	je     800657 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  80028c:	83 ec 08             	sub    $0x8,%esp
  80028f:	53                   	push   %ebx
  800290:	50                   	push   %eax
  800291:	ff d6                	call   *%esi
  800293:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800296:	83 c7 01             	add    $0x1,%edi
  800299:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80029d:	83 f8 25             	cmp    $0x25,%eax
  8002a0:	75 e2                	jne    800284 <vprintfmt+0x14>
  8002a2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002a6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ad:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002b4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c0:	eb 07                	jmp    8002c9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002c5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c9:	8d 47 01             	lea    0x1(%edi),%eax
  8002cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cf:	0f b6 07             	movzbl (%edi),%eax
  8002d2:	0f b6 c8             	movzbl %al,%ecx
  8002d5:	83 e8 23             	sub    $0x23,%eax
  8002d8:	3c 55                	cmp    $0x55,%al
  8002da:	0f 87 5c 03 00 00    	ja     80063c <vprintfmt+0x3cc>
  8002e0:	0f b6 c0             	movzbl %al,%eax
  8002e3:	ff 24 85 a0 0e 80 00 	jmp    *0x800ea0(,%eax,4)
  8002ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002ed:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f1:	eb d6                	jmp    8002c9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002fe:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800301:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800305:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800308:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80030b:	83 fa 09             	cmp    $0x9,%edx
  80030e:	77 39                	ja     800349 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800310:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800313:	eb e9                	jmp    8002fe <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800315:	8b 45 14             	mov    0x14(%ebp),%eax
  800318:	8d 48 04             	lea    0x4(%eax),%ecx
  80031b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80031e:	8b 00                	mov    (%eax),%eax
  800320:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800323:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800326:	eb 27                	jmp    80034f <vprintfmt+0xdf>
  800328:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032b:	85 c0                	test   %eax,%eax
  80032d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800332:	0f 49 c8             	cmovns %eax,%ecx
  800335:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80033b:	eb 8c                	jmp    8002c9 <vprintfmt+0x59>
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800340:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800347:	eb 80                	jmp    8002c9 <vprintfmt+0x59>
  800349:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80034c:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80034f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800353:	0f 89 70 ff ff ff    	jns    8002c9 <vprintfmt+0x59>
				width = precision, precision = -1;
  800359:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80035c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800366:	e9 5e ff ff ff       	jmp    8002c9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80036b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800371:	e9 53 ff ff ff       	jmp    8002c9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800376:	8b 45 14             	mov    0x14(%ebp),%eax
  800379:	8d 50 04             	lea    0x4(%eax),%edx
  80037c:	89 55 14             	mov    %edx,0x14(%ebp)
  80037f:	83 ec 08             	sub    $0x8,%esp
  800382:	53                   	push   %ebx
  800383:	ff 30                	pushl  (%eax)
  800385:	ff d6                	call   *%esi
			break;
  800387:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80038d:	e9 04 ff ff ff       	jmp    800296 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800392:	8b 45 14             	mov    0x14(%ebp),%eax
  800395:	8d 50 04             	lea    0x4(%eax),%edx
  800398:	89 55 14             	mov    %edx,0x14(%ebp)
  80039b:	8b 00                	mov    (%eax),%eax
  80039d:	99                   	cltd   
  80039e:	31 d0                	xor    %edx,%eax
  8003a0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a2:	83 f8 07             	cmp    $0x7,%eax
  8003a5:	7f 0b                	jg     8003b2 <vprintfmt+0x142>
  8003a7:	8b 14 85 00 10 80 00 	mov    0x801000(,%eax,4),%edx
  8003ae:	85 d2                	test   %edx,%edx
  8003b0:	75 18                	jne    8003ca <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003b2:	50                   	push   %eax
  8003b3:	68 07 0e 80 00       	push   $0x800e07
  8003b8:	53                   	push   %ebx
  8003b9:	56                   	push   %esi
  8003ba:	e8 94 fe ff ff       	call   800253 <printfmt>
  8003bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003c5:	e9 cc fe ff ff       	jmp    800296 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003ca:	52                   	push   %edx
  8003cb:	68 10 0e 80 00       	push   $0x800e10
  8003d0:	53                   	push   %ebx
  8003d1:	56                   	push   %esi
  8003d2:	e8 7c fe ff ff       	call   800253 <printfmt>
  8003d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003dd:	e9 b4 fe ff ff       	jmp    800296 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e5:	8d 50 04             	lea    0x4(%eax),%edx
  8003e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003eb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003ed:	85 ff                	test   %edi,%edi
  8003ef:	b8 00 0e 80 00       	mov    $0x800e00,%eax
  8003f4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003f7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003fb:	0f 8e 94 00 00 00    	jle    800495 <vprintfmt+0x225>
  800401:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800405:	0f 84 98 00 00 00    	je     8004a3 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	ff 75 c8             	pushl  -0x38(%ebp)
  800411:	57                   	push   %edi
  800412:	e8 c8 02 00 00       	call   8006df <strnlen>
  800417:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80041a:	29 c1                	sub    %eax,%ecx
  80041c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80041f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800422:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800426:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800429:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80042c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80042e:	eb 0f                	jmp    80043f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800430:	83 ec 08             	sub    $0x8,%esp
  800433:	53                   	push   %ebx
  800434:	ff 75 e0             	pushl  -0x20(%ebp)
  800437:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800439:	83 ef 01             	sub    $0x1,%edi
  80043c:	83 c4 10             	add    $0x10,%esp
  80043f:	85 ff                	test   %edi,%edi
  800441:	7f ed                	jg     800430 <vprintfmt+0x1c0>
  800443:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800446:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800449:	85 c9                	test   %ecx,%ecx
  80044b:	b8 00 00 00 00       	mov    $0x0,%eax
  800450:	0f 49 c1             	cmovns %ecx,%eax
  800453:	29 c1                	sub    %eax,%ecx
  800455:	89 75 08             	mov    %esi,0x8(%ebp)
  800458:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80045b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80045e:	89 cb                	mov    %ecx,%ebx
  800460:	eb 4d                	jmp    8004af <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800462:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800466:	74 1b                	je     800483 <vprintfmt+0x213>
  800468:	0f be c0             	movsbl %al,%eax
  80046b:	83 e8 20             	sub    $0x20,%eax
  80046e:	83 f8 5e             	cmp    $0x5e,%eax
  800471:	76 10                	jbe    800483 <vprintfmt+0x213>
					putch('?', putdat);
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	ff 75 0c             	pushl  0xc(%ebp)
  800479:	6a 3f                	push   $0x3f
  80047b:	ff 55 08             	call   *0x8(%ebp)
  80047e:	83 c4 10             	add    $0x10,%esp
  800481:	eb 0d                	jmp    800490 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	ff 75 0c             	pushl  0xc(%ebp)
  800489:	52                   	push   %edx
  80048a:	ff 55 08             	call   *0x8(%ebp)
  80048d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800490:	83 eb 01             	sub    $0x1,%ebx
  800493:	eb 1a                	jmp    8004af <vprintfmt+0x23f>
  800495:	89 75 08             	mov    %esi,0x8(%ebp)
  800498:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80049b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a1:	eb 0c                	jmp    8004af <vprintfmt+0x23f>
  8004a3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a6:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ac:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004af:	83 c7 01             	add    $0x1,%edi
  8004b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b6:	0f be d0             	movsbl %al,%edx
  8004b9:	85 d2                	test   %edx,%edx
  8004bb:	74 23                	je     8004e0 <vprintfmt+0x270>
  8004bd:	85 f6                	test   %esi,%esi
  8004bf:	78 a1                	js     800462 <vprintfmt+0x1f2>
  8004c1:	83 ee 01             	sub    $0x1,%esi
  8004c4:	79 9c                	jns    800462 <vprintfmt+0x1f2>
  8004c6:	89 df                	mov    %ebx,%edi
  8004c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ce:	eb 18                	jmp    8004e8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	53                   	push   %ebx
  8004d4:	6a 20                	push   $0x20
  8004d6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004d8:	83 ef 01             	sub    $0x1,%edi
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	eb 08                	jmp    8004e8 <vprintfmt+0x278>
  8004e0:	89 df                	mov    %ebx,%edi
  8004e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e8:	85 ff                	test   %edi,%edi
  8004ea:	7f e4                	jg     8004d0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ef:	e9 a2 fd ff ff       	jmp    800296 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004f4:	83 fa 01             	cmp    $0x1,%edx
  8004f7:	7e 16                	jle    80050f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 50 08             	lea    0x8(%eax),%edx
  8004ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800502:	8b 50 04             	mov    0x4(%eax),%edx
  800505:	8b 00                	mov    (%eax),%eax
  800507:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80050a:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80050d:	eb 32                	jmp    800541 <vprintfmt+0x2d1>
	else if (lflag)
  80050f:	85 d2                	test   %edx,%edx
  800511:	74 18                	je     80052b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8d 50 04             	lea    0x4(%eax),%edx
  800519:	89 55 14             	mov    %edx,0x14(%ebp)
  80051c:	8b 00                	mov    (%eax),%eax
  80051e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800521:	89 c1                	mov    %eax,%ecx
  800523:	c1 f9 1f             	sar    $0x1f,%ecx
  800526:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800529:	eb 16                	jmp    800541 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 50 04             	lea    0x4(%eax),%edx
  800531:	89 55 14             	mov    %edx,0x14(%ebp)
  800534:	8b 00                	mov    (%eax),%eax
  800536:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800539:	89 c1                	mov    %eax,%ecx
  80053b:	c1 f9 1f             	sar    $0x1f,%ecx
  80053e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800541:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800544:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800547:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80054d:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800552:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800556:	0f 89 a8 00 00 00    	jns    800604 <vprintfmt+0x394>
				putch('-', putdat);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	53                   	push   %ebx
  800560:	6a 2d                	push   $0x2d
  800562:	ff d6                	call   *%esi
				num = -(long long) num;
  800564:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800567:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80056a:	f7 d8                	neg    %eax
  80056c:	83 d2 00             	adc    $0x0,%edx
  80056f:	f7 da                	neg    %edx
  800571:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800574:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800577:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80057a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057f:	e9 80 00 00 00       	jmp    800604 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800584:	8d 45 14             	lea    0x14(%ebp),%eax
  800587:	e8 70 fc ff ff       	call   8001fc <getuint>
  80058c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800592:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800597:	eb 6b                	jmp    800604 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800599:	8d 45 14             	lea    0x14(%ebp),%eax
  80059c:	e8 5b fc ff ff       	call   8001fc <getuint>
  8005a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  8005a7:	6a 04                	push   $0x4
  8005a9:	6a 03                	push   $0x3
  8005ab:	6a 01                	push   $0x1
  8005ad:	68 13 0e 80 00       	push   $0x800e13
  8005b2:	e8 82 fb ff ff       	call   800139 <cprintf>
			goto number;
  8005b7:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  8005ba:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  8005bf:	eb 43                	jmp    800604 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	53                   	push   %ebx
  8005c5:	6a 30                	push   $0x30
  8005c7:	ff d6                	call   *%esi
			putch('x', putdat);
  8005c9:	83 c4 08             	add    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	6a 78                	push   $0x78
  8005cf:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 50 04             	lea    0x4(%eax),%edx
  8005d7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005da:	8b 00                	mov    (%eax),%eax
  8005dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005e7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005ea:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005ef:	eb 13                	jmp    800604 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f4:	e8 03 fc ff ff       	call   8001fc <getuint>
  8005f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8005ff:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800604:	83 ec 0c             	sub    $0xc,%esp
  800607:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  80060b:	52                   	push   %edx
  80060c:	ff 75 e0             	pushl  -0x20(%ebp)
  80060f:	50                   	push   %eax
  800610:	ff 75 dc             	pushl  -0x24(%ebp)
  800613:	ff 75 d8             	pushl  -0x28(%ebp)
  800616:	89 da                	mov    %ebx,%edx
  800618:	89 f0                	mov    %esi,%eax
  80061a:	e8 2e fb ff ff       	call   80014d <printnum>

			break;
  80061f:	83 c4 20             	add    $0x20,%esp
  800622:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800625:	e9 6c fc ff ff       	jmp    800296 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	51                   	push   %ecx
  80062f:	ff d6                	call   *%esi
			break;
  800631:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800634:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800637:	e9 5a fc ff ff       	jmp    800296 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	6a 25                	push   $0x25
  800642:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800644:	83 c4 10             	add    $0x10,%esp
  800647:	eb 03                	jmp    80064c <vprintfmt+0x3dc>
  800649:	83 ef 01             	sub    $0x1,%edi
  80064c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800650:	75 f7                	jne    800649 <vprintfmt+0x3d9>
  800652:	e9 3f fc ff ff       	jmp    800296 <vprintfmt+0x26>
			break;
		}

	}

}
  800657:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065a:	5b                   	pop    %ebx
  80065b:	5e                   	pop    %esi
  80065c:	5f                   	pop    %edi
  80065d:	5d                   	pop    %ebp
  80065e:	c3                   	ret    

0080065f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80065f:	55                   	push   %ebp
  800660:	89 e5                	mov    %esp,%ebp
  800662:	83 ec 18             	sub    $0x18,%esp
  800665:	8b 45 08             	mov    0x8(%ebp),%eax
  800668:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80066b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80066e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800672:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800675:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80067c:	85 c0                	test   %eax,%eax
  80067e:	74 26                	je     8006a6 <vsnprintf+0x47>
  800680:	85 d2                	test   %edx,%edx
  800682:	7e 22                	jle    8006a6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800684:	ff 75 14             	pushl  0x14(%ebp)
  800687:	ff 75 10             	pushl  0x10(%ebp)
  80068a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80068d:	50                   	push   %eax
  80068e:	68 36 02 80 00       	push   $0x800236
  800693:	e8 d8 fb ff ff       	call   800270 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800698:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80069b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80069e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a1:	83 c4 10             	add    $0x10,%esp
  8006a4:	eb 05                	jmp    8006ab <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006ab:	c9                   	leave  
  8006ac:	c3                   	ret    

008006ad <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006b3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006b6:	50                   	push   %eax
  8006b7:	ff 75 10             	pushl  0x10(%ebp)
  8006ba:	ff 75 0c             	pushl  0xc(%ebp)
  8006bd:	ff 75 08             	pushl  0x8(%ebp)
  8006c0:	e8 9a ff ff ff       	call   80065f <vsnprintf>
	va_end(ap);

	return rc;
}
  8006c5:	c9                   	leave  
  8006c6:	c3                   	ret    

008006c7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006c7:	55                   	push   %ebp
  8006c8:	89 e5                	mov    %esp,%ebp
  8006ca:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d2:	eb 03                	jmp    8006d7 <strlen+0x10>
		n++;
  8006d4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006db:	75 f7                	jne    8006d4 <strlen+0xd>
		n++;
	return n;
}
  8006dd:	5d                   	pop    %ebp
  8006de:	c3                   	ret    

008006df <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ed:	eb 03                	jmp    8006f2 <strnlen+0x13>
		n++;
  8006ef:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f2:	39 c2                	cmp    %eax,%edx
  8006f4:	74 08                	je     8006fe <strnlen+0x1f>
  8006f6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006fa:	75 f3                	jne    8006ef <strnlen+0x10>
  8006fc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006fe:	5d                   	pop    %ebp
  8006ff:	c3                   	ret    

00800700 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	53                   	push   %ebx
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80070a:	89 c2                	mov    %eax,%edx
  80070c:	83 c2 01             	add    $0x1,%edx
  80070f:	83 c1 01             	add    $0x1,%ecx
  800712:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800716:	88 5a ff             	mov    %bl,-0x1(%edx)
  800719:	84 db                	test   %bl,%bl
  80071b:	75 ef                	jne    80070c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80071d:	5b                   	pop    %ebx
  80071e:	5d                   	pop    %ebp
  80071f:	c3                   	ret    

00800720 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	53                   	push   %ebx
  800724:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800727:	53                   	push   %ebx
  800728:	e8 9a ff ff ff       	call   8006c7 <strlen>
  80072d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800730:	ff 75 0c             	pushl  0xc(%ebp)
  800733:	01 d8                	add    %ebx,%eax
  800735:	50                   	push   %eax
  800736:	e8 c5 ff ff ff       	call   800700 <strcpy>
	return dst;
}
  80073b:	89 d8                	mov    %ebx,%eax
  80073d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800740:	c9                   	leave  
  800741:	c3                   	ret    

00800742 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800742:	55                   	push   %ebp
  800743:	89 e5                	mov    %esp,%ebp
  800745:	56                   	push   %esi
  800746:	53                   	push   %ebx
  800747:	8b 75 08             	mov    0x8(%ebp),%esi
  80074a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80074d:	89 f3                	mov    %esi,%ebx
  80074f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800752:	89 f2                	mov    %esi,%edx
  800754:	eb 0f                	jmp    800765 <strncpy+0x23>
		*dst++ = *src;
  800756:	83 c2 01             	add    $0x1,%edx
  800759:	0f b6 01             	movzbl (%ecx),%eax
  80075c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80075f:	80 39 01             	cmpb   $0x1,(%ecx)
  800762:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800765:	39 da                	cmp    %ebx,%edx
  800767:	75 ed                	jne    800756 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800769:	89 f0                	mov    %esi,%eax
  80076b:	5b                   	pop    %ebx
  80076c:	5e                   	pop    %esi
  80076d:	5d                   	pop    %ebp
  80076e:	c3                   	ret    

0080076f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	56                   	push   %esi
  800773:	53                   	push   %ebx
  800774:	8b 75 08             	mov    0x8(%ebp),%esi
  800777:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077a:	8b 55 10             	mov    0x10(%ebp),%edx
  80077d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80077f:	85 d2                	test   %edx,%edx
  800781:	74 21                	je     8007a4 <strlcpy+0x35>
  800783:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800787:	89 f2                	mov    %esi,%edx
  800789:	eb 09                	jmp    800794 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80078b:	83 c2 01             	add    $0x1,%edx
  80078e:	83 c1 01             	add    $0x1,%ecx
  800791:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800794:	39 c2                	cmp    %eax,%edx
  800796:	74 09                	je     8007a1 <strlcpy+0x32>
  800798:	0f b6 19             	movzbl (%ecx),%ebx
  80079b:	84 db                	test   %bl,%bl
  80079d:	75 ec                	jne    80078b <strlcpy+0x1c>
  80079f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007a1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007a4:	29 f0                	sub    %esi,%eax
}
  8007a6:	5b                   	pop    %ebx
  8007a7:	5e                   	pop    %esi
  8007a8:	5d                   	pop    %ebp
  8007a9:	c3                   	ret    

008007aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007aa:	55                   	push   %ebp
  8007ab:	89 e5                	mov    %esp,%ebp
  8007ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007b3:	eb 06                	jmp    8007bb <strcmp+0x11>
		p++, q++;
  8007b5:	83 c1 01             	add    $0x1,%ecx
  8007b8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007bb:	0f b6 01             	movzbl (%ecx),%eax
  8007be:	84 c0                	test   %al,%al
  8007c0:	74 04                	je     8007c6 <strcmp+0x1c>
  8007c2:	3a 02                	cmp    (%edx),%al
  8007c4:	74 ef                	je     8007b5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c6:	0f b6 c0             	movzbl %al,%eax
  8007c9:	0f b6 12             	movzbl (%edx),%edx
  8007cc:	29 d0                	sub    %edx,%eax
}
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	53                   	push   %ebx
  8007d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007da:	89 c3                	mov    %eax,%ebx
  8007dc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007df:	eb 06                	jmp    8007e7 <strncmp+0x17>
		n--, p++, q++;
  8007e1:	83 c0 01             	add    $0x1,%eax
  8007e4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007e7:	39 d8                	cmp    %ebx,%eax
  8007e9:	74 15                	je     800800 <strncmp+0x30>
  8007eb:	0f b6 08             	movzbl (%eax),%ecx
  8007ee:	84 c9                	test   %cl,%cl
  8007f0:	74 04                	je     8007f6 <strncmp+0x26>
  8007f2:	3a 0a                	cmp    (%edx),%cl
  8007f4:	74 eb                	je     8007e1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f6:	0f b6 00             	movzbl (%eax),%eax
  8007f9:	0f b6 12             	movzbl (%edx),%edx
  8007fc:	29 d0                	sub    %edx,%eax
  8007fe:	eb 05                	jmp    800805 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800800:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800805:	5b                   	pop    %ebx
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800812:	eb 07                	jmp    80081b <strchr+0x13>
		if (*s == c)
  800814:	38 ca                	cmp    %cl,%dl
  800816:	74 0f                	je     800827 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800818:	83 c0 01             	add    $0x1,%eax
  80081b:	0f b6 10             	movzbl (%eax),%edx
  80081e:	84 d2                	test   %dl,%dl
  800820:	75 f2                	jne    800814 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800822:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800833:	eb 03                	jmp    800838 <strfind+0xf>
  800835:	83 c0 01             	add    $0x1,%eax
  800838:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80083b:	38 ca                	cmp    %cl,%dl
  80083d:	74 04                	je     800843 <strfind+0x1a>
  80083f:	84 d2                	test   %dl,%dl
  800841:	75 f2                	jne    800835 <strfind+0xc>
			break;
	return (char *) s;
}
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	57                   	push   %edi
  800849:	56                   	push   %esi
  80084a:	53                   	push   %ebx
  80084b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800851:	85 c9                	test   %ecx,%ecx
  800853:	74 36                	je     80088b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800855:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80085b:	75 28                	jne    800885 <memset+0x40>
  80085d:	f6 c1 03             	test   $0x3,%cl
  800860:	75 23                	jne    800885 <memset+0x40>
		c &= 0xFF;
  800862:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800866:	89 d3                	mov    %edx,%ebx
  800868:	c1 e3 08             	shl    $0x8,%ebx
  80086b:	89 d6                	mov    %edx,%esi
  80086d:	c1 e6 18             	shl    $0x18,%esi
  800870:	89 d0                	mov    %edx,%eax
  800872:	c1 e0 10             	shl    $0x10,%eax
  800875:	09 f0                	or     %esi,%eax
  800877:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800879:	89 d8                	mov    %ebx,%eax
  80087b:	09 d0                	or     %edx,%eax
  80087d:	c1 e9 02             	shr    $0x2,%ecx
  800880:	fc                   	cld    
  800881:	f3 ab                	rep stos %eax,%es:(%edi)
  800883:	eb 06                	jmp    80088b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800885:	8b 45 0c             	mov    0xc(%ebp),%eax
  800888:	fc                   	cld    
  800889:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80088b:	89 f8                	mov    %edi,%eax
  80088d:	5b                   	pop    %ebx
  80088e:	5e                   	pop    %esi
  80088f:	5f                   	pop    %edi
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    

00800892 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	57                   	push   %edi
  800896:	56                   	push   %esi
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80089d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008a0:	39 c6                	cmp    %eax,%esi
  8008a2:	73 35                	jae    8008d9 <memmove+0x47>
  8008a4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008a7:	39 d0                	cmp    %edx,%eax
  8008a9:	73 2e                	jae    8008d9 <memmove+0x47>
		s += n;
		d += n;
  8008ab:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ae:	89 d6                	mov    %edx,%esi
  8008b0:	09 fe                	or     %edi,%esi
  8008b2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008b8:	75 13                	jne    8008cd <memmove+0x3b>
  8008ba:	f6 c1 03             	test   $0x3,%cl
  8008bd:	75 0e                	jne    8008cd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008bf:	83 ef 04             	sub    $0x4,%edi
  8008c2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008c5:	c1 e9 02             	shr    $0x2,%ecx
  8008c8:	fd                   	std    
  8008c9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008cb:	eb 09                	jmp    8008d6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008cd:	83 ef 01             	sub    $0x1,%edi
  8008d0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008d3:	fd                   	std    
  8008d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008d6:	fc                   	cld    
  8008d7:	eb 1d                	jmp    8008f6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d9:	89 f2                	mov    %esi,%edx
  8008db:	09 c2                	or     %eax,%edx
  8008dd:	f6 c2 03             	test   $0x3,%dl
  8008e0:	75 0f                	jne    8008f1 <memmove+0x5f>
  8008e2:	f6 c1 03             	test   $0x3,%cl
  8008e5:	75 0a                	jne    8008f1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008e7:	c1 e9 02             	shr    $0x2,%ecx
  8008ea:	89 c7                	mov    %eax,%edi
  8008ec:	fc                   	cld    
  8008ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ef:	eb 05                	jmp    8008f6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f1:	89 c7                	mov    %eax,%edi
  8008f3:	fc                   	cld    
  8008f4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008f6:	5e                   	pop    %esi
  8008f7:	5f                   	pop    %edi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008fd:	ff 75 10             	pushl  0x10(%ebp)
  800900:	ff 75 0c             	pushl  0xc(%ebp)
  800903:	ff 75 08             	pushl  0x8(%ebp)
  800906:	e8 87 ff ff ff       	call   800892 <memmove>
}
  80090b:	c9                   	leave  
  80090c:	c3                   	ret    

0080090d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	56                   	push   %esi
  800911:	53                   	push   %ebx
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	8b 55 0c             	mov    0xc(%ebp),%edx
  800918:	89 c6                	mov    %eax,%esi
  80091a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80091d:	eb 1a                	jmp    800939 <memcmp+0x2c>
		if (*s1 != *s2)
  80091f:	0f b6 08             	movzbl (%eax),%ecx
  800922:	0f b6 1a             	movzbl (%edx),%ebx
  800925:	38 d9                	cmp    %bl,%cl
  800927:	74 0a                	je     800933 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800929:	0f b6 c1             	movzbl %cl,%eax
  80092c:	0f b6 db             	movzbl %bl,%ebx
  80092f:	29 d8                	sub    %ebx,%eax
  800931:	eb 0f                	jmp    800942 <memcmp+0x35>
		s1++, s2++;
  800933:	83 c0 01             	add    $0x1,%eax
  800936:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800939:	39 f0                	cmp    %esi,%eax
  80093b:	75 e2                	jne    80091f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80093d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800942:	5b                   	pop    %ebx
  800943:	5e                   	pop    %esi
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	53                   	push   %ebx
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80094d:	89 c1                	mov    %eax,%ecx
  80094f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800952:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800956:	eb 0a                	jmp    800962 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800958:	0f b6 10             	movzbl (%eax),%edx
  80095b:	39 da                	cmp    %ebx,%edx
  80095d:	74 07                	je     800966 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80095f:	83 c0 01             	add    $0x1,%eax
  800962:	39 c8                	cmp    %ecx,%eax
  800964:	72 f2                	jb     800958 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800966:	5b                   	pop    %ebx
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	57                   	push   %edi
  80096d:	56                   	push   %esi
  80096e:	53                   	push   %ebx
  80096f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800972:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800975:	eb 03                	jmp    80097a <strtol+0x11>
		s++;
  800977:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097a:	0f b6 01             	movzbl (%ecx),%eax
  80097d:	3c 20                	cmp    $0x20,%al
  80097f:	74 f6                	je     800977 <strtol+0xe>
  800981:	3c 09                	cmp    $0x9,%al
  800983:	74 f2                	je     800977 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800985:	3c 2b                	cmp    $0x2b,%al
  800987:	75 0a                	jne    800993 <strtol+0x2a>
		s++;
  800989:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80098c:	bf 00 00 00 00       	mov    $0x0,%edi
  800991:	eb 11                	jmp    8009a4 <strtol+0x3b>
  800993:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800998:	3c 2d                	cmp    $0x2d,%al
  80099a:	75 08                	jne    8009a4 <strtol+0x3b>
		s++, neg = 1;
  80099c:	83 c1 01             	add    $0x1,%ecx
  80099f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009a4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009aa:	75 15                	jne    8009c1 <strtol+0x58>
  8009ac:	80 39 30             	cmpb   $0x30,(%ecx)
  8009af:	75 10                	jne    8009c1 <strtol+0x58>
  8009b1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009b5:	75 7c                	jne    800a33 <strtol+0xca>
		s += 2, base = 16;
  8009b7:	83 c1 02             	add    $0x2,%ecx
  8009ba:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009bf:	eb 16                	jmp    8009d7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009c1:	85 db                	test   %ebx,%ebx
  8009c3:	75 12                	jne    8009d7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009c5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ca:	80 39 30             	cmpb   $0x30,(%ecx)
  8009cd:	75 08                	jne    8009d7 <strtol+0x6e>
		s++, base = 8;
  8009cf:	83 c1 01             	add    $0x1,%ecx
  8009d2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009dc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009df:	0f b6 11             	movzbl (%ecx),%edx
  8009e2:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009e5:	89 f3                	mov    %esi,%ebx
  8009e7:	80 fb 09             	cmp    $0x9,%bl
  8009ea:	77 08                	ja     8009f4 <strtol+0x8b>
			dig = *s - '0';
  8009ec:	0f be d2             	movsbl %dl,%edx
  8009ef:	83 ea 30             	sub    $0x30,%edx
  8009f2:	eb 22                	jmp    800a16 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009f4:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009f7:	89 f3                	mov    %esi,%ebx
  8009f9:	80 fb 19             	cmp    $0x19,%bl
  8009fc:	77 08                	ja     800a06 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009fe:	0f be d2             	movsbl %dl,%edx
  800a01:	83 ea 57             	sub    $0x57,%edx
  800a04:	eb 10                	jmp    800a16 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a06:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a09:	89 f3                	mov    %esi,%ebx
  800a0b:	80 fb 19             	cmp    $0x19,%bl
  800a0e:	77 16                	ja     800a26 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a10:	0f be d2             	movsbl %dl,%edx
  800a13:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a16:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a19:	7d 0b                	jge    800a26 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a1b:	83 c1 01             	add    $0x1,%ecx
  800a1e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a22:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a24:	eb b9                	jmp    8009df <strtol+0x76>

	if (endptr)
  800a26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a2a:	74 0d                	je     800a39 <strtol+0xd0>
		*endptr = (char *) s;
  800a2c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2f:	89 0e                	mov    %ecx,(%esi)
  800a31:	eb 06                	jmp    800a39 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a33:	85 db                	test   %ebx,%ebx
  800a35:	74 98                	je     8009cf <strtol+0x66>
  800a37:	eb 9e                	jmp    8009d7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a39:	89 c2                	mov    %eax,%edx
  800a3b:	f7 da                	neg    %edx
  800a3d:	85 ff                	test   %edi,%edi
  800a3f:	0f 45 c2             	cmovne %edx,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	57                   	push   %edi
  800a4b:	56                   	push   %esi
  800a4c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a55:	8b 55 08             	mov    0x8(%ebp),%edx
  800a58:	89 c3                	mov    %eax,%ebx
  800a5a:	89 c7                	mov    %eax,%edi
  800a5c:	89 c6                	mov    %eax,%esi
  800a5e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a60:	5b                   	pop    %ebx
  800a61:	5e                   	pop    %esi
  800a62:	5f                   	pop    %edi
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	57                   	push   %edi
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a70:	b8 01 00 00 00       	mov    $0x1,%eax
  800a75:	89 d1                	mov    %edx,%ecx
  800a77:	89 d3                	mov    %edx,%ebx
  800a79:	89 d7                	mov    %edx,%edi
  800a7b:	89 d6                	mov    %edx,%esi
  800a7d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a7f:	5b                   	pop    %ebx
  800a80:	5e                   	pop    %esi
  800a81:	5f                   	pop    %edi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
  800a8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a92:	b8 03 00 00 00       	mov    $0x3,%eax
  800a97:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9a:	89 cb                	mov    %ecx,%ebx
  800a9c:	89 cf                	mov    %ecx,%edi
  800a9e:	89 ce                	mov    %ecx,%esi
  800aa0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aa2:	85 c0                	test   %eax,%eax
  800aa4:	7e 17                	jle    800abd <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aa6:	83 ec 0c             	sub    $0xc,%esp
  800aa9:	50                   	push   %eax
  800aaa:	6a 03                	push   $0x3
  800aac:	68 20 10 80 00       	push   $0x801020
  800ab1:	6a 23                	push   $0x23
  800ab3:	68 3d 10 80 00       	push   $0x80103d
  800ab8:	e8 27 00 00 00       	call   800ae4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800abd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ad5:	89 d1                	mov    %edx,%ecx
  800ad7:	89 d3                	mov    %edx,%ebx
  800ad9:	89 d7                	mov    %edx,%edi
  800adb:	89 d6                	mov    %edx,%esi
  800add:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ae9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800aec:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800af2:	e8 ce ff ff ff       	call   800ac5 <sys_getenvid>
  800af7:	83 ec 0c             	sub    $0xc,%esp
  800afa:	ff 75 0c             	pushl  0xc(%ebp)
  800afd:	ff 75 08             	pushl  0x8(%ebp)
  800b00:	56                   	push   %esi
  800b01:	50                   	push   %eax
  800b02:	68 4c 10 80 00       	push   $0x80104c
  800b07:	e8 2d f6 ff ff       	call   800139 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b0c:	83 c4 18             	add    $0x18,%esp
  800b0f:	53                   	push   %ebx
  800b10:	ff 75 10             	pushl  0x10(%ebp)
  800b13:	e8 d0 f5 ff ff       	call   8000e8 <vcprintf>
	cprintf("\n");
  800b18:	c7 04 24 23 0e 80 00 	movl   $0x800e23,(%esp)
  800b1f:	e8 15 f6 ff ff       	call   800139 <cprintf>
  800b24:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b27:	cc                   	int3   
  800b28:	eb fd                	jmp    800b27 <_panic+0x43>
  800b2a:	66 90                	xchg   %ax,%ax
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
