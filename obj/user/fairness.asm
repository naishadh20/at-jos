
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 e2 0a 00 00       	call   800b22 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 b1 0c 00 00       	call   800d0f <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 60 10 80 00       	push   $0x801060
  80006a:	e8 27 01 00 00       	call   800196 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 71 10 80 00       	push   $0x801071
  800083:	e8 0e 01 00 00       	call   800196 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 8a 0c 00 00       	call   800d26 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000ac:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000b3:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  8000b6:	e8 67 0a 00 00       	call   800b22 <sys_getenvid>
  8000bb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000c3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c8:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000cd:	85 db                	test   %ebx,%ebx
  8000cf:	7e 07                	jle    8000d8 <libmain+0x37>
		binaryname = argv[0];
  8000d1:	8b 06                	mov    (%esi),%eax
  8000d3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d8:	83 ec 08             	sub    $0x8,%esp
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	e8 51 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e2:	e8 0a 00 00 00       	call   8000f1 <exit>
}
  8000e7:	83 c4 10             	add    $0x10,%esp
  8000ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ed:	5b                   	pop    %ebx
  8000ee:	5e                   	pop    %esi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000f7:	6a 00                	push   $0x0
  8000f9:	e8 e3 09 00 00       	call   800ae1 <sys_env_destroy>
}
  8000fe:	83 c4 10             	add    $0x10,%esp
  800101:	c9                   	leave  
  800102:	c3                   	ret    

00800103 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	53                   	push   %ebx
  800107:	83 ec 04             	sub    $0x4,%esp
  80010a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010d:	8b 13                	mov    (%ebx),%edx
  80010f:	8d 42 01             	lea    0x1(%edx),%eax
  800112:	89 03                	mov    %eax,(%ebx)
  800114:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800117:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80011b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800120:	75 1a                	jne    80013c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800122:	83 ec 08             	sub    $0x8,%esp
  800125:	68 ff 00 00 00       	push   $0xff
  80012a:	8d 43 08             	lea    0x8(%ebx),%eax
  80012d:	50                   	push   %eax
  80012e:	e8 71 09 00 00       	call   800aa4 <sys_cputs>
		b->idx = 0;
  800133:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800139:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800140:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800143:	c9                   	leave  
  800144:	c3                   	ret    

00800145 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800155:	00 00 00 
	b.cnt = 0;
  800158:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800162:	ff 75 0c             	pushl  0xc(%ebp)
  800165:	ff 75 08             	pushl  0x8(%ebp)
  800168:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016e:	50                   	push   %eax
  80016f:	68 03 01 80 00       	push   $0x800103
  800174:	e8 54 01 00 00       	call   8002cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800179:	83 c4 08             	add    $0x8,%esp
  80017c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800182:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800188:	50                   	push   %eax
  800189:	e8 16 09 00 00       	call   800aa4 <sys_cputs>

	return b.cnt;
}
  80018e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800194:	c9                   	leave  
  800195:	c3                   	ret    

00800196 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019f:	50                   	push   %eax
  8001a0:	ff 75 08             	pushl  0x8(%ebp)
  8001a3:	e8 9d ff ff ff       	call   800145 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    

008001aa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	57                   	push   %edi
  8001ae:	56                   	push   %esi
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 1c             	sub    $0x1c,%esp
  8001b3:	89 c7                	mov    %eax,%edi
  8001b5:	89 d6                	mov    %edx,%esi
  8001b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ce:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001d1:	39 d3                	cmp    %edx,%ebx
  8001d3:	72 05                	jb     8001da <printnum+0x30>
  8001d5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d8:	77 45                	ja     80021f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	ff 75 18             	pushl  0x18(%ebp)
  8001e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e6:	53                   	push   %ebx
  8001e7:	ff 75 10             	pushl  0x10(%ebp)
  8001ea:	83 ec 08             	sub    $0x8,%esp
  8001ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f9:	e8 c2 0b 00 00       	call   800dc0 <__udivdi3>
  8001fe:	83 c4 18             	add    $0x18,%esp
  800201:	52                   	push   %edx
  800202:	50                   	push   %eax
  800203:	89 f2                	mov    %esi,%edx
  800205:	89 f8                	mov    %edi,%eax
  800207:	e8 9e ff ff ff       	call   8001aa <printnum>
  80020c:	83 c4 20             	add    $0x20,%esp
  80020f:	eb 18                	jmp    800229 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	ff 75 18             	pushl  0x18(%ebp)
  800218:	ff d7                	call   *%edi
  80021a:	83 c4 10             	add    $0x10,%esp
  80021d:	eb 03                	jmp    800222 <printnum+0x78>
  80021f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800222:	83 eb 01             	sub    $0x1,%ebx
  800225:	85 db                	test   %ebx,%ebx
  800227:	7f e8                	jg     800211 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800229:	83 ec 08             	sub    $0x8,%esp
  80022c:	56                   	push   %esi
  80022d:	83 ec 04             	sub    $0x4,%esp
  800230:	ff 75 e4             	pushl  -0x1c(%ebp)
  800233:	ff 75 e0             	pushl  -0x20(%ebp)
  800236:	ff 75 dc             	pushl  -0x24(%ebp)
  800239:	ff 75 d8             	pushl  -0x28(%ebp)
  80023c:	e8 af 0c 00 00       	call   800ef0 <__umoddi3>
  800241:	83 c4 14             	add    $0x14,%esp
  800244:	0f be 80 92 10 80 00 	movsbl 0x801092(%eax),%eax
  80024b:	50                   	push   %eax
  80024c:	ff d7                	call   *%edi
}
  80024e:	83 c4 10             	add    $0x10,%esp
  800251:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800254:	5b                   	pop    %ebx
  800255:	5e                   	pop    %esi
  800256:	5f                   	pop    %edi
  800257:	5d                   	pop    %ebp
  800258:	c3                   	ret    

00800259 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80025c:	83 fa 01             	cmp    $0x1,%edx
  80025f:	7e 0e                	jle    80026f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800261:	8b 10                	mov    (%eax),%edx
  800263:	8d 4a 08             	lea    0x8(%edx),%ecx
  800266:	89 08                	mov    %ecx,(%eax)
  800268:	8b 02                	mov    (%edx),%eax
  80026a:	8b 52 04             	mov    0x4(%edx),%edx
  80026d:	eb 22                	jmp    800291 <getuint+0x38>
	else if (lflag)
  80026f:	85 d2                	test   %edx,%edx
  800271:	74 10                	je     800283 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800273:	8b 10                	mov    (%eax),%edx
  800275:	8d 4a 04             	lea    0x4(%edx),%ecx
  800278:	89 08                	mov    %ecx,(%eax)
  80027a:	8b 02                	mov    (%edx),%eax
  80027c:	ba 00 00 00 00       	mov    $0x0,%edx
  800281:	eb 0e                	jmp    800291 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800283:	8b 10                	mov    (%eax),%edx
  800285:	8d 4a 04             	lea    0x4(%edx),%ecx
  800288:	89 08                	mov    %ecx,(%eax)
  80028a:	8b 02                	mov    (%edx),%eax
  80028c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800291:	5d                   	pop    %ebp
  800292:	c3                   	ret    

00800293 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800299:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029d:	8b 10                	mov    (%eax),%edx
  80029f:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a2:	73 0a                	jae    8002ae <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a7:	89 08                	mov    %ecx,(%eax)
  8002a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ac:	88 02                	mov    %al,(%edx)
}
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002b6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b9:	50                   	push   %eax
  8002ba:	ff 75 10             	pushl  0x10(%ebp)
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	e8 05 00 00 00       	call   8002cd <vprintfmt>
	va_end(ap);
}
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	c9                   	leave  
  8002cc:	c3                   	ret    

008002cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	57                   	push   %edi
  8002d1:	56                   	push   %esi
  8002d2:	53                   	push   %ebx
  8002d3:	83 ec 2c             	sub    $0x2c,%esp
  8002d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002dc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002df:	eb 12                	jmp    8002f3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	0f 84 cb 03 00 00    	je     8006b4 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  8002e9:	83 ec 08             	sub    $0x8,%esp
  8002ec:	53                   	push   %ebx
  8002ed:	50                   	push   %eax
  8002ee:	ff d6                	call   *%esi
  8002f0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f3:	83 c7 01             	add    $0x1,%edi
  8002f6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002fa:	83 f8 25             	cmp    $0x25,%eax
  8002fd:	75 e2                	jne    8002e1 <vprintfmt+0x14>
  8002ff:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800303:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80030a:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800311:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800318:	ba 00 00 00 00       	mov    $0x0,%edx
  80031d:	eb 07                	jmp    800326 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800322:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8d 47 01             	lea    0x1(%edi),%eax
  800329:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032c:	0f b6 07             	movzbl (%edi),%eax
  80032f:	0f b6 c8             	movzbl %al,%ecx
  800332:	83 e8 23             	sub    $0x23,%eax
  800335:	3c 55                	cmp    $0x55,%al
  800337:	0f 87 5c 03 00 00    	ja     800699 <vprintfmt+0x3cc>
  80033d:	0f b6 c0             	movzbl %al,%eax
  800340:	ff 24 85 60 11 80 00 	jmp    *0x801160(,%eax,4)
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80034e:	eb d6                	jmp    800326 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800353:	b8 00 00 00 00       	mov    $0x0,%eax
  800358:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800362:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800365:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800368:	83 fa 09             	cmp    $0x9,%edx
  80036b:	77 39                	ja     8003a6 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800370:	eb e9                	jmp    80035b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800372:	8b 45 14             	mov    0x14(%ebp),%eax
  800375:	8d 48 04             	lea    0x4(%eax),%ecx
  800378:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80037b:	8b 00                	mov    (%eax),%eax
  80037d:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800383:	eb 27                	jmp    8003ac <vprintfmt+0xdf>
  800385:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800388:	85 c0                	test   %eax,%eax
  80038a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038f:	0f 49 c8             	cmovns %eax,%ecx
  800392:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800398:	eb 8c                	jmp    800326 <vprintfmt+0x59>
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80039d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003a4:	eb 80                	jmp    800326 <vprintfmt+0x59>
  8003a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a9:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8003ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b0:	0f 89 70 ff ff ff    	jns    800326 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003b6:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003bc:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003c3:	e9 5e ff ff ff       	jmp    800326 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003c8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ce:	e9 53 ff ff ff       	jmp    800326 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	8d 50 04             	lea    0x4(%eax),%edx
  8003d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003dc:	83 ec 08             	sub    $0x8,%esp
  8003df:	53                   	push   %ebx
  8003e0:	ff 30                	pushl  (%eax)
  8003e2:	ff d6                	call   *%esi
			break;
  8003e4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ea:	e9 04 ff ff ff       	jmp    8002f3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f2:	8d 50 04             	lea    0x4(%eax),%edx
  8003f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f8:	8b 00                	mov    (%eax),%eax
  8003fa:	99                   	cltd   
  8003fb:	31 d0                	xor    %edx,%eax
  8003fd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ff:	83 f8 09             	cmp    $0x9,%eax
  800402:	7f 0b                	jg     80040f <vprintfmt+0x142>
  800404:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  80040b:	85 d2                	test   %edx,%edx
  80040d:	75 18                	jne    800427 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80040f:	50                   	push   %eax
  800410:	68 aa 10 80 00       	push   $0x8010aa
  800415:	53                   	push   %ebx
  800416:	56                   	push   %esi
  800417:	e8 94 fe ff ff       	call   8002b0 <printfmt>
  80041c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800422:	e9 cc fe ff ff       	jmp    8002f3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800427:	52                   	push   %edx
  800428:	68 b3 10 80 00       	push   $0x8010b3
  80042d:	53                   	push   %ebx
  80042e:	56                   	push   %esi
  80042f:	e8 7c fe ff ff       	call   8002b0 <printfmt>
  800434:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043a:	e9 b4 fe ff ff       	jmp    8002f3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 50 04             	lea    0x4(%eax),%edx
  800445:	89 55 14             	mov    %edx,0x14(%ebp)
  800448:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80044a:	85 ff                	test   %edi,%edi
  80044c:	b8 a3 10 80 00       	mov    $0x8010a3,%eax
  800451:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800454:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800458:	0f 8e 94 00 00 00    	jle    8004f2 <vprintfmt+0x225>
  80045e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800462:	0f 84 98 00 00 00    	je     800500 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	ff 75 c8             	pushl  -0x38(%ebp)
  80046e:	57                   	push   %edi
  80046f:	e8 c8 02 00 00       	call   80073c <strnlen>
  800474:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800477:	29 c1                	sub    %eax,%ecx
  800479:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80047c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80047f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800483:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800486:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800489:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048b:	eb 0f                	jmp    80049c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	53                   	push   %ebx
  800491:	ff 75 e0             	pushl  -0x20(%ebp)
  800494:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800496:	83 ef 01             	sub    $0x1,%edi
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	85 ff                	test   %edi,%edi
  80049e:	7f ed                	jg     80048d <vprintfmt+0x1c0>
  8004a0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004a6:	85 c9                	test   %ecx,%ecx
  8004a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ad:	0f 49 c1             	cmovns %ecx,%eax
  8004b0:	29 c1                	sub    %eax,%ecx
  8004b2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b5:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004b8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004bb:	89 cb                	mov    %ecx,%ebx
  8004bd:	eb 4d                	jmp    80050c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004bf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c3:	74 1b                	je     8004e0 <vprintfmt+0x213>
  8004c5:	0f be c0             	movsbl %al,%eax
  8004c8:	83 e8 20             	sub    $0x20,%eax
  8004cb:	83 f8 5e             	cmp    $0x5e,%eax
  8004ce:	76 10                	jbe    8004e0 <vprintfmt+0x213>
					putch('?', putdat);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	ff 75 0c             	pushl  0xc(%ebp)
  8004d6:	6a 3f                	push   $0x3f
  8004d8:	ff 55 08             	call   *0x8(%ebp)
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	eb 0d                	jmp    8004ed <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	ff 75 0c             	pushl  0xc(%ebp)
  8004e6:	52                   	push   %edx
  8004e7:	ff 55 08             	call   *0x8(%ebp)
  8004ea:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ed:	83 eb 01             	sub    $0x1,%ebx
  8004f0:	eb 1a                	jmp    80050c <vprintfmt+0x23f>
  8004f2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f5:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004f8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fe:	eb 0c                	jmp    80050c <vprintfmt+0x23f>
  800500:	89 75 08             	mov    %esi,0x8(%ebp)
  800503:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800506:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800509:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050c:	83 c7 01             	add    $0x1,%edi
  80050f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800513:	0f be d0             	movsbl %al,%edx
  800516:	85 d2                	test   %edx,%edx
  800518:	74 23                	je     80053d <vprintfmt+0x270>
  80051a:	85 f6                	test   %esi,%esi
  80051c:	78 a1                	js     8004bf <vprintfmt+0x1f2>
  80051e:	83 ee 01             	sub    $0x1,%esi
  800521:	79 9c                	jns    8004bf <vprintfmt+0x1f2>
  800523:	89 df                	mov    %ebx,%edi
  800525:	8b 75 08             	mov    0x8(%ebp),%esi
  800528:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052b:	eb 18                	jmp    800545 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	53                   	push   %ebx
  800531:	6a 20                	push   $0x20
  800533:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800535:	83 ef 01             	sub    $0x1,%edi
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	eb 08                	jmp    800545 <vprintfmt+0x278>
  80053d:	89 df                	mov    %ebx,%edi
  80053f:	8b 75 08             	mov    0x8(%ebp),%esi
  800542:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800545:	85 ff                	test   %edi,%edi
  800547:	7f e4                	jg     80052d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800549:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054c:	e9 a2 fd ff ff       	jmp    8002f3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800551:	83 fa 01             	cmp    $0x1,%edx
  800554:	7e 16                	jle    80056c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8d 50 08             	lea    0x8(%eax),%edx
  80055c:	89 55 14             	mov    %edx,0x14(%ebp)
  80055f:	8b 50 04             	mov    0x4(%eax),%edx
  800562:	8b 00                	mov    (%eax),%eax
  800564:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800567:	89 55 cc             	mov    %edx,-0x34(%ebp)
  80056a:	eb 32                	jmp    80059e <vprintfmt+0x2d1>
	else if (lflag)
  80056c:	85 d2                	test   %edx,%edx
  80056e:	74 18                	je     800588 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 50 04             	lea    0x4(%eax),%edx
  800576:	89 55 14             	mov    %edx,0x14(%ebp)
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80057e:	89 c1                	mov    %eax,%ecx
  800580:	c1 f9 1f             	sar    $0x1f,%ecx
  800583:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800586:	eb 16                	jmp    80059e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8d 50 04             	lea    0x4(%eax),%edx
  80058e:	89 55 14             	mov    %edx,0x14(%ebp)
  800591:	8b 00                	mov    (%eax),%eax
  800593:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800596:	89 c1                	mov    %eax,%ecx
  800598:	c1 f9 1f             	sar    $0x1f,%ecx
  80059b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005a1:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005aa:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005af:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005b3:	0f 89 a8 00 00 00    	jns    800661 <vprintfmt+0x394>
				putch('-', putdat);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	53                   	push   %ebx
  8005bd:	6a 2d                	push   $0x2d
  8005bf:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c1:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005c4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005c7:	f7 d8                	neg    %eax
  8005c9:	83 d2 00             	adc    $0x0,%edx
  8005cc:	f7 da                	neg    %edx
  8005ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005dc:	e9 80 00 00 00       	jmp    800661 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e4:	e8 70 fc ff ff       	call   800259 <getuint>
  8005e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  8005ef:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005f4:	eb 6b                	jmp    800661 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f9:	e8 5b fc ff ff       	call   800259 <getuint>
  8005fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800601:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800604:	6a 04                	push   $0x4
  800606:	6a 03                	push   $0x3
  800608:	6a 01                	push   $0x1
  80060a:	68 b6 10 80 00       	push   $0x8010b6
  80060f:	e8 82 fb ff ff       	call   800196 <cprintf>
			goto number;
  800614:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  800617:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  80061c:	eb 43                	jmp    800661 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	53                   	push   %ebx
  800622:	6a 30                	push   $0x30
  800624:	ff d6                	call   *%esi
			putch('x', putdat);
  800626:	83 c4 08             	add    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	6a 78                	push   $0x78
  80062c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 04             	lea    0x4(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800637:	8b 00                	mov    (%eax),%eax
  800639:	ba 00 00 00 00       	mov    $0x0,%edx
  80063e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800641:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800644:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800647:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80064c:	eb 13                	jmp    800661 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80064e:	8d 45 14             	lea    0x14(%ebp),%eax
  800651:	e8 03 fc ff ff       	call   800259 <getuint>
  800656:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800659:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80065c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800661:	83 ec 0c             	sub    $0xc,%esp
  800664:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800668:	52                   	push   %edx
  800669:	ff 75 e0             	pushl  -0x20(%ebp)
  80066c:	50                   	push   %eax
  80066d:	ff 75 dc             	pushl  -0x24(%ebp)
  800670:	ff 75 d8             	pushl  -0x28(%ebp)
  800673:	89 da                	mov    %ebx,%edx
  800675:	89 f0                	mov    %esi,%eax
  800677:	e8 2e fb ff ff       	call   8001aa <printnum>

			break;
  80067c:	83 c4 20             	add    $0x20,%esp
  80067f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800682:	e9 6c fc ff ff       	jmp    8002f3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	51                   	push   %ecx
  80068c:	ff d6                	call   *%esi
			break;
  80068e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800691:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800694:	e9 5a fc ff ff       	jmp    8002f3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800699:	83 ec 08             	sub    $0x8,%esp
  80069c:	53                   	push   %ebx
  80069d:	6a 25                	push   $0x25
  80069f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a1:	83 c4 10             	add    $0x10,%esp
  8006a4:	eb 03                	jmp    8006a9 <vprintfmt+0x3dc>
  8006a6:	83 ef 01             	sub    $0x1,%edi
  8006a9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ad:	75 f7                	jne    8006a6 <vprintfmt+0x3d9>
  8006af:	e9 3f fc ff ff       	jmp    8002f3 <vprintfmt+0x26>
			break;
		}

	}

}
  8006b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b7:	5b                   	pop    %ebx
  8006b8:	5e                   	pop    %esi
  8006b9:	5f                   	pop    %edi
  8006ba:	5d                   	pop    %ebp
  8006bb:	c3                   	ret    

008006bc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	83 ec 18             	sub    $0x18,%esp
  8006c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006cb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006cf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d9:	85 c0                	test   %eax,%eax
  8006db:	74 26                	je     800703 <vsnprintf+0x47>
  8006dd:	85 d2                	test   %edx,%edx
  8006df:	7e 22                	jle    800703 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e1:	ff 75 14             	pushl  0x14(%ebp)
  8006e4:	ff 75 10             	pushl  0x10(%ebp)
  8006e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ea:	50                   	push   %eax
  8006eb:	68 93 02 80 00       	push   $0x800293
  8006f0:	e8 d8 fb ff ff       	call   8002cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	eb 05                	jmp    800708 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800703:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800708:	c9                   	leave  
  800709:	c3                   	ret    

0080070a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800710:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800713:	50                   	push   %eax
  800714:	ff 75 10             	pushl  0x10(%ebp)
  800717:	ff 75 0c             	pushl  0xc(%ebp)
  80071a:	ff 75 08             	pushl  0x8(%ebp)
  80071d:	e8 9a ff ff ff       	call   8006bc <vsnprintf>
	va_end(ap);

	return rc;
}
  800722:	c9                   	leave  
  800723:	c3                   	ret    

00800724 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80072a:	b8 00 00 00 00       	mov    $0x0,%eax
  80072f:	eb 03                	jmp    800734 <strlen+0x10>
		n++;
  800731:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800734:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800738:	75 f7                	jne    800731 <strlen+0xd>
		n++;
	return n;
}
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800742:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800745:	ba 00 00 00 00       	mov    $0x0,%edx
  80074a:	eb 03                	jmp    80074f <strnlen+0x13>
		n++;
  80074c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074f:	39 c2                	cmp    %eax,%edx
  800751:	74 08                	je     80075b <strnlen+0x1f>
  800753:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800757:	75 f3                	jne    80074c <strnlen+0x10>
  800759:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	53                   	push   %ebx
  800761:	8b 45 08             	mov    0x8(%ebp),%eax
  800764:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800767:	89 c2                	mov    %eax,%edx
  800769:	83 c2 01             	add    $0x1,%edx
  80076c:	83 c1 01             	add    $0x1,%ecx
  80076f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800773:	88 5a ff             	mov    %bl,-0x1(%edx)
  800776:	84 db                	test   %bl,%bl
  800778:	75 ef                	jne    800769 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80077a:	5b                   	pop    %ebx
  80077b:	5d                   	pop    %ebp
  80077c:	c3                   	ret    

0080077d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	53                   	push   %ebx
  800781:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800784:	53                   	push   %ebx
  800785:	e8 9a ff ff ff       	call   800724 <strlen>
  80078a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80078d:	ff 75 0c             	pushl  0xc(%ebp)
  800790:	01 d8                	add    %ebx,%eax
  800792:	50                   	push   %eax
  800793:	e8 c5 ff ff ff       	call   80075d <strcpy>
	return dst;
}
  800798:	89 d8                	mov    %ebx,%eax
  80079a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    

0080079f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	56                   	push   %esi
  8007a3:	53                   	push   %ebx
  8007a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007aa:	89 f3                	mov    %esi,%ebx
  8007ac:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007af:	89 f2                	mov    %esi,%edx
  8007b1:	eb 0f                	jmp    8007c2 <strncpy+0x23>
		*dst++ = *src;
  8007b3:	83 c2 01             	add    $0x1,%edx
  8007b6:	0f b6 01             	movzbl (%ecx),%eax
  8007b9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007bc:	80 39 01             	cmpb   $0x1,(%ecx)
  8007bf:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c2:	39 da                	cmp    %ebx,%edx
  8007c4:	75 ed                	jne    8007b3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c6:	89 f0                	mov    %esi,%eax
  8007c8:	5b                   	pop    %ebx
  8007c9:	5e                   	pop    %esi
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	56                   	push   %esi
  8007d0:	53                   	push   %ebx
  8007d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d7:	8b 55 10             	mov    0x10(%ebp),%edx
  8007da:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007dc:	85 d2                	test   %edx,%edx
  8007de:	74 21                	je     800801 <strlcpy+0x35>
  8007e0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007e4:	89 f2                	mov    %esi,%edx
  8007e6:	eb 09                	jmp    8007f1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e8:	83 c2 01             	add    $0x1,%edx
  8007eb:	83 c1 01             	add    $0x1,%ecx
  8007ee:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007f1:	39 c2                	cmp    %eax,%edx
  8007f3:	74 09                	je     8007fe <strlcpy+0x32>
  8007f5:	0f b6 19             	movzbl (%ecx),%ebx
  8007f8:	84 db                	test   %bl,%bl
  8007fa:	75 ec                	jne    8007e8 <strlcpy+0x1c>
  8007fc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007fe:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800801:	29 f0                	sub    %esi,%eax
}
  800803:	5b                   	pop    %ebx
  800804:	5e                   	pop    %esi
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800810:	eb 06                	jmp    800818 <strcmp+0x11>
		p++, q++;
  800812:	83 c1 01             	add    $0x1,%ecx
  800815:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800818:	0f b6 01             	movzbl (%ecx),%eax
  80081b:	84 c0                	test   %al,%al
  80081d:	74 04                	je     800823 <strcmp+0x1c>
  80081f:	3a 02                	cmp    (%edx),%al
  800821:	74 ef                	je     800812 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800823:	0f b6 c0             	movzbl %al,%eax
  800826:	0f b6 12             	movzbl (%edx),%edx
  800829:	29 d0                	sub    %edx,%eax
}
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	53                   	push   %ebx
  800831:	8b 45 08             	mov    0x8(%ebp),%eax
  800834:	8b 55 0c             	mov    0xc(%ebp),%edx
  800837:	89 c3                	mov    %eax,%ebx
  800839:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80083c:	eb 06                	jmp    800844 <strncmp+0x17>
		n--, p++, q++;
  80083e:	83 c0 01             	add    $0x1,%eax
  800841:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800844:	39 d8                	cmp    %ebx,%eax
  800846:	74 15                	je     80085d <strncmp+0x30>
  800848:	0f b6 08             	movzbl (%eax),%ecx
  80084b:	84 c9                	test   %cl,%cl
  80084d:	74 04                	je     800853 <strncmp+0x26>
  80084f:	3a 0a                	cmp    (%edx),%cl
  800851:	74 eb                	je     80083e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800853:	0f b6 00             	movzbl (%eax),%eax
  800856:	0f b6 12             	movzbl (%edx),%edx
  800859:	29 d0                	sub    %edx,%eax
  80085b:	eb 05                	jmp    800862 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800862:	5b                   	pop    %ebx
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086f:	eb 07                	jmp    800878 <strchr+0x13>
		if (*s == c)
  800871:	38 ca                	cmp    %cl,%dl
  800873:	74 0f                	je     800884 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800875:	83 c0 01             	add    $0x1,%eax
  800878:	0f b6 10             	movzbl (%eax),%edx
  80087b:	84 d2                	test   %dl,%dl
  80087d:	75 f2                	jne    800871 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80087f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800890:	eb 03                	jmp    800895 <strfind+0xf>
  800892:	83 c0 01             	add    $0x1,%eax
  800895:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800898:	38 ca                	cmp    %cl,%dl
  80089a:	74 04                	je     8008a0 <strfind+0x1a>
  80089c:	84 d2                	test   %dl,%dl
  80089e:	75 f2                	jne    800892 <strfind+0xc>
			break;
	return (char *) s;
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	57                   	push   %edi
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
  8008a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ae:	85 c9                	test   %ecx,%ecx
  8008b0:	74 36                	je     8008e8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b8:	75 28                	jne    8008e2 <memset+0x40>
  8008ba:	f6 c1 03             	test   $0x3,%cl
  8008bd:	75 23                	jne    8008e2 <memset+0x40>
		c &= 0xFF;
  8008bf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c3:	89 d3                	mov    %edx,%ebx
  8008c5:	c1 e3 08             	shl    $0x8,%ebx
  8008c8:	89 d6                	mov    %edx,%esi
  8008ca:	c1 e6 18             	shl    $0x18,%esi
  8008cd:	89 d0                	mov    %edx,%eax
  8008cf:	c1 e0 10             	shl    $0x10,%eax
  8008d2:	09 f0                	or     %esi,%eax
  8008d4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008d6:	89 d8                	mov    %ebx,%eax
  8008d8:	09 d0                	or     %edx,%eax
  8008da:	c1 e9 02             	shr    $0x2,%ecx
  8008dd:	fc                   	cld    
  8008de:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e0:	eb 06                	jmp    8008e8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e5:	fc                   	cld    
  8008e6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e8:	89 f8                	mov    %edi,%eax
  8008ea:	5b                   	pop    %ebx
  8008eb:	5e                   	pop    %esi
  8008ec:	5f                   	pop    %edi
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	57                   	push   %edi
  8008f3:	56                   	push   %esi
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008fd:	39 c6                	cmp    %eax,%esi
  8008ff:	73 35                	jae    800936 <memmove+0x47>
  800901:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800904:	39 d0                	cmp    %edx,%eax
  800906:	73 2e                	jae    800936 <memmove+0x47>
		s += n;
		d += n;
  800908:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090b:	89 d6                	mov    %edx,%esi
  80090d:	09 fe                	or     %edi,%esi
  80090f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800915:	75 13                	jne    80092a <memmove+0x3b>
  800917:	f6 c1 03             	test   $0x3,%cl
  80091a:	75 0e                	jne    80092a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80091c:	83 ef 04             	sub    $0x4,%edi
  80091f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800922:	c1 e9 02             	shr    $0x2,%ecx
  800925:	fd                   	std    
  800926:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800928:	eb 09                	jmp    800933 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80092a:	83 ef 01             	sub    $0x1,%edi
  80092d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800930:	fd                   	std    
  800931:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800933:	fc                   	cld    
  800934:	eb 1d                	jmp    800953 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800936:	89 f2                	mov    %esi,%edx
  800938:	09 c2                	or     %eax,%edx
  80093a:	f6 c2 03             	test   $0x3,%dl
  80093d:	75 0f                	jne    80094e <memmove+0x5f>
  80093f:	f6 c1 03             	test   $0x3,%cl
  800942:	75 0a                	jne    80094e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800944:	c1 e9 02             	shr    $0x2,%ecx
  800947:	89 c7                	mov    %eax,%edi
  800949:	fc                   	cld    
  80094a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094c:	eb 05                	jmp    800953 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80094e:	89 c7                	mov    %eax,%edi
  800950:	fc                   	cld    
  800951:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800953:	5e                   	pop    %esi
  800954:	5f                   	pop    %edi
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80095a:	ff 75 10             	pushl  0x10(%ebp)
  80095d:	ff 75 0c             	pushl  0xc(%ebp)
  800960:	ff 75 08             	pushl  0x8(%ebp)
  800963:	e8 87 ff ff ff       	call   8008ef <memmove>
}
  800968:	c9                   	leave  
  800969:	c3                   	ret    

0080096a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	56                   	push   %esi
  80096e:	53                   	push   %ebx
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	8b 55 0c             	mov    0xc(%ebp),%edx
  800975:	89 c6                	mov    %eax,%esi
  800977:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097a:	eb 1a                	jmp    800996 <memcmp+0x2c>
		if (*s1 != *s2)
  80097c:	0f b6 08             	movzbl (%eax),%ecx
  80097f:	0f b6 1a             	movzbl (%edx),%ebx
  800982:	38 d9                	cmp    %bl,%cl
  800984:	74 0a                	je     800990 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800986:	0f b6 c1             	movzbl %cl,%eax
  800989:	0f b6 db             	movzbl %bl,%ebx
  80098c:	29 d8                	sub    %ebx,%eax
  80098e:	eb 0f                	jmp    80099f <memcmp+0x35>
		s1++, s2++;
  800990:	83 c0 01             	add    $0x1,%eax
  800993:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800996:	39 f0                	cmp    %esi,%eax
  800998:	75 e2                	jne    80097c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80099a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80099f:	5b                   	pop    %ebx
  8009a0:	5e                   	pop    %esi
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	53                   	push   %ebx
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009aa:	89 c1                	mov    %eax,%ecx
  8009ac:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009af:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b3:	eb 0a                	jmp    8009bf <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b5:	0f b6 10             	movzbl (%eax),%edx
  8009b8:	39 da                	cmp    %ebx,%edx
  8009ba:	74 07                	je     8009c3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009bc:	83 c0 01             	add    $0x1,%eax
  8009bf:	39 c8                	cmp    %ecx,%eax
  8009c1:	72 f2                	jb     8009b5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009c3:	5b                   	pop    %ebx
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	57                   	push   %edi
  8009ca:	56                   	push   %esi
  8009cb:	53                   	push   %ebx
  8009cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d2:	eb 03                	jmp    8009d7 <strtol+0x11>
		s++;
  8009d4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d7:	0f b6 01             	movzbl (%ecx),%eax
  8009da:	3c 20                	cmp    $0x20,%al
  8009dc:	74 f6                	je     8009d4 <strtol+0xe>
  8009de:	3c 09                	cmp    $0x9,%al
  8009e0:	74 f2                	je     8009d4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e2:	3c 2b                	cmp    $0x2b,%al
  8009e4:	75 0a                	jne    8009f0 <strtol+0x2a>
		s++;
  8009e6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e9:	bf 00 00 00 00       	mov    $0x0,%edi
  8009ee:	eb 11                	jmp    800a01 <strtol+0x3b>
  8009f0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009f5:	3c 2d                	cmp    $0x2d,%al
  8009f7:	75 08                	jne    800a01 <strtol+0x3b>
		s++, neg = 1;
  8009f9:	83 c1 01             	add    $0x1,%ecx
  8009fc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a01:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a07:	75 15                	jne    800a1e <strtol+0x58>
  800a09:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0c:	75 10                	jne    800a1e <strtol+0x58>
  800a0e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a12:	75 7c                	jne    800a90 <strtol+0xca>
		s += 2, base = 16;
  800a14:	83 c1 02             	add    $0x2,%ecx
  800a17:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a1c:	eb 16                	jmp    800a34 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a1e:	85 db                	test   %ebx,%ebx
  800a20:	75 12                	jne    800a34 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a22:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a27:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2a:	75 08                	jne    800a34 <strtol+0x6e>
		s++, base = 8;
  800a2c:	83 c1 01             	add    $0x1,%ecx
  800a2f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
  800a39:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a3c:	0f b6 11             	movzbl (%ecx),%edx
  800a3f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a42:	89 f3                	mov    %esi,%ebx
  800a44:	80 fb 09             	cmp    $0x9,%bl
  800a47:	77 08                	ja     800a51 <strtol+0x8b>
			dig = *s - '0';
  800a49:	0f be d2             	movsbl %dl,%edx
  800a4c:	83 ea 30             	sub    $0x30,%edx
  800a4f:	eb 22                	jmp    800a73 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a51:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a54:	89 f3                	mov    %esi,%ebx
  800a56:	80 fb 19             	cmp    $0x19,%bl
  800a59:	77 08                	ja     800a63 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a5b:	0f be d2             	movsbl %dl,%edx
  800a5e:	83 ea 57             	sub    $0x57,%edx
  800a61:	eb 10                	jmp    800a73 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a63:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a66:	89 f3                	mov    %esi,%ebx
  800a68:	80 fb 19             	cmp    $0x19,%bl
  800a6b:	77 16                	ja     800a83 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a6d:	0f be d2             	movsbl %dl,%edx
  800a70:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a73:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a76:	7d 0b                	jge    800a83 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a78:	83 c1 01             	add    $0x1,%ecx
  800a7b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a81:	eb b9                	jmp    800a3c <strtol+0x76>

	if (endptr)
  800a83:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a87:	74 0d                	je     800a96 <strtol+0xd0>
		*endptr = (char *) s;
  800a89:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8c:	89 0e                	mov    %ecx,(%esi)
  800a8e:	eb 06                	jmp    800a96 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a90:	85 db                	test   %ebx,%ebx
  800a92:	74 98                	je     800a2c <strtol+0x66>
  800a94:	eb 9e                	jmp    800a34 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a96:	89 c2                	mov    %eax,%edx
  800a98:	f7 da                	neg    %edx
  800a9a:	85 ff                	test   %edi,%edi
  800a9c:	0f 45 c2             	cmovne %edx,%eax
}
  800a9f:	5b                   	pop    %ebx
  800aa0:	5e                   	pop    %esi
  800aa1:	5f                   	pop    %edi
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	57                   	push   %edi
  800aa8:	56                   	push   %esi
  800aa9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab5:	89 c3                	mov    %eax,%ebx
  800ab7:	89 c7                	mov    %eax,%edi
  800ab9:	89 c6                	mov    %eax,%esi
  800abb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5f                   	pop    %edi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac8:	ba 00 00 00 00       	mov    $0x0,%edx
  800acd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad2:	89 d1                	mov    %edx,%ecx
  800ad4:	89 d3                	mov    %edx,%ebx
  800ad6:	89 d7                	mov    %edx,%edi
  800ad8:	89 d6                	mov    %edx,%esi
  800ada:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aef:	b8 03 00 00 00       	mov    $0x3,%eax
  800af4:	8b 55 08             	mov    0x8(%ebp),%edx
  800af7:	89 cb                	mov    %ecx,%ebx
  800af9:	89 cf                	mov    %ecx,%edi
  800afb:	89 ce                	mov    %ecx,%esi
  800afd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aff:	85 c0                	test   %eax,%eax
  800b01:	7e 17                	jle    800b1a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b03:	83 ec 0c             	sub    $0xc,%esp
  800b06:	50                   	push   %eax
  800b07:	6a 03                	push   $0x3
  800b09:	68 e8 12 80 00       	push   $0x8012e8
  800b0e:	6a 23                	push   $0x23
  800b10:	68 05 13 80 00       	push   $0x801305
  800b15:	e8 5c 02 00 00       	call   800d76 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b28:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b32:	89 d1                	mov    %edx,%ecx
  800b34:	89 d3                	mov    %edx,%ebx
  800b36:	89 d7                	mov    %edx,%edi
  800b38:	89 d6                	mov    %edx,%esi
  800b3a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_yield>:

void
sys_yield(void)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b47:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b51:	89 d1                	mov    %edx,%ecx
  800b53:	89 d3                	mov    %edx,%ebx
  800b55:	89 d7                	mov    %edx,%edi
  800b57:	89 d6                	mov    %edx,%esi
  800b59:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
  800b66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b69:	be 00 00 00 00       	mov    $0x0,%esi
  800b6e:	b8 04 00 00 00       	mov    $0x4,%eax
  800b73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7c:	89 f7                	mov    %esi,%edi
  800b7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b80:	85 c0                	test   %eax,%eax
  800b82:	7e 17                	jle    800b9b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b84:	83 ec 0c             	sub    $0xc,%esp
  800b87:	50                   	push   %eax
  800b88:	6a 04                	push   $0x4
  800b8a:	68 e8 12 80 00       	push   $0x8012e8
  800b8f:	6a 23                	push   $0x23
  800b91:	68 05 13 80 00       	push   $0x801305
  800b96:	e8 db 01 00 00       	call   800d76 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
  800ba9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bac:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bbd:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc2:	85 c0                	test   %eax,%eax
  800bc4:	7e 17                	jle    800bdd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc6:	83 ec 0c             	sub    $0xc,%esp
  800bc9:	50                   	push   %eax
  800bca:	6a 05                	push   $0x5
  800bcc:	68 e8 12 80 00       	push   $0x8012e8
  800bd1:	6a 23                	push   $0x23
  800bd3:	68 05 13 80 00       	push   $0x801305
  800bd8:	e8 99 01 00 00       	call   800d76 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	57                   	push   %edi
  800be9:	56                   	push   %esi
  800bea:	53                   	push   %ebx
  800beb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf3:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfe:	89 df                	mov    %ebx,%edi
  800c00:	89 de                	mov    %ebx,%esi
  800c02:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c04:	85 c0                	test   %eax,%eax
  800c06:	7e 17                	jle    800c1f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c08:	83 ec 0c             	sub    $0xc,%esp
  800c0b:	50                   	push   %eax
  800c0c:	6a 06                	push   $0x6
  800c0e:	68 e8 12 80 00       	push   $0x8012e8
  800c13:	6a 23                	push   $0x23
  800c15:	68 05 13 80 00       	push   $0x801305
  800c1a:	e8 57 01 00 00       	call   800d76 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
  800c2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c35:	b8 08 00 00 00       	mov    $0x8,%eax
  800c3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c40:	89 df                	mov    %ebx,%edi
  800c42:	89 de                	mov    %ebx,%esi
  800c44:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c46:	85 c0                	test   %eax,%eax
  800c48:	7e 17                	jle    800c61 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4a:	83 ec 0c             	sub    $0xc,%esp
  800c4d:	50                   	push   %eax
  800c4e:	6a 08                	push   $0x8
  800c50:	68 e8 12 80 00       	push   $0x8012e8
  800c55:	6a 23                	push   $0x23
  800c57:	68 05 13 80 00       	push   $0x801305
  800c5c:	e8 15 01 00 00       	call   800d76 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5f                   	pop    %edi
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c77:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c82:	89 df                	mov    %ebx,%edi
  800c84:	89 de                	mov    %ebx,%esi
  800c86:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	7e 17                	jle    800ca3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8c:	83 ec 0c             	sub    $0xc,%esp
  800c8f:	50                   	push   %eax
  800c90:	6a 09                	push   $0x9
  800c92:	68 e8 12 80 00       	push   $0x8012e8
  800c97:	6a 23                	push   $0x23
  800c99:	68 05 13 80 00       	push   $0x801305
  800c9e:	e8 d3 00 00 00       	call   800d76 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb1:	be 00 00 00 00       	mov    $0x0,%esi
  800cb6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cc7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cdc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	89 cb                	mov    %ecx,%ebx
  800ce6:	89 cf                	mov    %ecx,%edi
  800ce8:	89 ce                	mov    %ecx,%esi
  800cea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cec:	85 c0                	test   %eax,%eax
  800cee:	7e 17                	jle    800d07 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf0:	83 ec 0c             	sub    $0xc,%esp
  800cf3:	50                   	push   %eax
  800cf4:	6a 0c                	push   $0xc
  800cf6:	68 e8 12 80 00       	push   $0x8012e8
  800cfb:	6a 23                	push   $0x23
  800cfd:	68 05 13 80 00       	push   $0x801305
  800d02:	e8 6f 00 00 00       	call   800d76 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800d15:	68 13 13 80 00       	push   $0x801313
  800d1a:	6a 1a                	push   $0x1a
  800d1c:	68 2c 13 80 00       	push   $0x80132c
  800d21:	e8 50 00 00 00       	call   800d76 <_panic>

00800d26 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800d2c:	68 36 13 80 00       	push   $0x801336
  800d31:	6a 2a                	push   $0x2a
  800d33:	68 2c 13 80 00       	push   $0x80132c
  800d38:	e8 39 00 00 00       	call   800d76 <_panic>

00800d3d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800d43:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800d48:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800d4b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800d51:	8b 52 50             	mov    0x50(%edx),%edx
  800d54:	39 ca                	cmp    %ecx,%edx
  800d56:	75 0d                	jne    800d65 <ipc_find_env+0x28>
			return envs[i].env_id;
  800d58:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800d5b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800d60:	8b 40 48             	mov    0x48(%eax),%eax
  800d63:	eb 0f                	jmp    800d74 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800d65:	83 c0 01             	add    $0x1,%eax
  800d68:	3d 00 04 00 00       	cmp    $0x400,%eax
  800d6d:	75 d9                	jne    800d48 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800d6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    

00800d76 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	56                   	push   %esi
  800d7a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d7b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d7e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d84:	e8 99 fd ff ff       	call   800b22 <sys_getenvid>
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	ff 75 0c             	pushl  0xc(%ebp)
  800d8f:	ff 75 08             	pushl  0x8(%ebp)
  800d92:	56                   	push   %esi
  800d93:	50                   	push   %eax
  800d94:	68 50 13 80 00       	push   $0x801350
  800d99:	e8 f8 f3 ff ff       	call   800196 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d9e:	83 c4 18             	add    $0x18,%esp
  800da1:	53                   	push   %ebx
  800da2:	ff 75 10             	pushl  0x10(%ebp)
  800da5:	e8 9b f3 ff ff       	call   800145 <vcprintf>
	cprintf("\n");
  800daa:	c7 04 24 c6 10 80 00 	movl   $0x8010c6,(%esp)
  800db1:	e8 e0 f3 ff ff       	call   800196 <cprintf>
  800db6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800db9:	cc                   	int3   
  800dba:	eb fd                	jmp    800db9 <_panic+0x43>
  800dbc:	66 90                	xchg   %ax,%ax
  800dbe:	66 90                	xchg   %ax,%ax

00800dc0 <__udivdi3>:
  800dc0:	55                   	push   %ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 1c             	sub    $0x1c,%esp
  800dc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800dcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800dcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800dd7:	85 f6                	test   %esi,%esi
  800dd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ddd:	89 ca                	mov    %ecx,%edx
  800ddf:	89 f8                	mov    %edi,%eax
  800de1:	75 3d                	jne    800e20 <__udivdi3+0x60>
  800de3:	39 cf                	cmp    %ecx,%edi
  800de5:	0f 87 c5 00 00 00    	ja     800eb0 <__udivdi3+0xf0>
  800deb:	85 ff                	test   %edi,%edi
  800ded:	89 fd                	mov    %edi,%ebp
  800def:	75 0b                	jne    800dfc <__udivdi3+0x3c>
  800df1:	b8 01 00 00 00       	mov    $0x1,%eax
  800df6:	31 d2                	xor    %edx,%edx
  800df8:	f7 f7                	div    %edi
  800dfa:	89 c5                	mov    %eax,%ebp
  800dfc:	89 c8                	mov    %ecx,%eax
  800dfe:	31 d2                	xor    %edx,%edx
  800e00:	f7 f5                	div    %ebp
  800e02:	89 c1                	mov    %eax,%ecx
  800e04:	89 d8                	mov    %ebx,%eax
  800e06:	89 cf                	mov    %ecx,%edi
  800e08:	f7 f5                	div    %ebp
  800e0a:	89 c3                	mov    %eax,%ebx
  800e0c:	89 d8                	mov    %ebx,%eax
  800e0e:	89 fa                	mov    %edi,%edx
  800e10:	83 c4 1c             	add    $0x1c,%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    
  800e18:	90                   	nop
  800e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e20:	39 ce                	cmp    %ecx,%esi
  800e22:	77 74                	ja     800e98 <__udivdi3+0xd8>
  800e24:	0f bd fe             	bsr    %esi,%edi
  800e27:	83 f7 1f             	xor    $0x1f,%edi
  800e2a:	0f 84 98 00 00 00    	je     800ec8 <__udivdi3+0x108>
  800e30:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e35:	89 f9                	mov    %edi,%ecx
  800e37:	89 c5                	mov    %eax,%ebp
  800e39:	29 fb                	sub    %edi,%ebx
  800e3b:	d3 e6                	shl    %cl,%esi
  800e3d:	89 d9                	mov    %ebx,%ecx
  800e3f:	d3 ed                	shr    %cl,%ebp
  800e41:	89 f9                	mov    %edi,%ecx
  800e43:	d3 e0                	shl    %cl,%eax
  800e45:	09 ee                	or     %ebp,%esi
  800e47:	89 d9                	mov    %ebx,%ecx
  800e49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e4d:	89 d5                	mov    %edx,%ebp
  800e4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e53:	d3 ed                	shr    %cl,%ebp
  800e55:	89 f9                	mov    %edi,%ecx
  800e57:	d3 e2                	shl    %cl,%edx
  800e59:	89 d9                	mov    %ebx,%ecx
  800e5b:	d3 e8                	shr    %cl,%eax
  800e5d:	09 c2                	or     %eax,%edx
  800e5f:	89 d0                	mov    %edx,%eax
  800e61:	89 ea                	mov    %ebp,%edx
  800e63:	f7 f6                	div    %esi
  800e65:	89 d5                	mov    %edx,%ebp
  800e67:	89 c3                	mov    %eax,%ebx
  800e69:	f7 64 24 0c          	mull   0xc(%esp)
  800e6d:	39 d5                	cmp    %edx,%ebp
  800e6f:	72 10                	jb     800e81 <__udivdi3+0xc1>
  800e71:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e75:	89 f9                	mov    %edi,%ecx
  800e77:	d3 e6                	shl    %cl,%esi
  800e79:	39 c6                	cmp    %eax,%esi
  800e7b:	73 07                	jae    800e84 <__udivdi3+0xc4>
  800e7d:	39 d5                	cmp    %edx,%ebp
  800e7f:	75 03                	jne    800e84 <__udivdi3+0xc4>
  800e81:	83 eb 01             	sub    $0x1,%ebx
  800e84:	31 ff                	xor    %edi,%edi
  800e86:	89 d8                	mov    %ebx,%eax
  800e88:	89 fa                	mov    %edi,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	31 ff                	xor    %edi,%edi
  800e9a:	31 db                	xor    %ebx,%ebx
  800e9c:	89 d8                	mov    %ebx,%eax
  800e9e:	89 fa                	mov    %edi,%edx
  800ea0:	83 c4 1c             	add    $0x1c,%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    
  800ea8:	90                   	nop
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	89 d8                	mov    %ebx,%eax
  800eb2:	f7 f7                	div    %edi
  800eb4:	31 ff                	xor    %edi,%edi
  800eb6:	89 c3                	mov    %eax,%ebx
  800eb8:	89 d8                	mov    %ebx,%eax
  800eba:	89 fa                	mov    %edi,%edx
  800ebc:	83 c4 1c             	add    $0x1c,%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    
  800ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	39 ce                	cmp    %ecx,%esi
  800eca:	72 0c                	jb     800ed8 <__udivdi3+0x118>
  800ecc:	31 db                	xor    %ebx,%ebx
  800ece:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ed2:	0f 87 34 ff ff ff    	ja     800e0c <__udivdi3+0x4c>
  800ed8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800edd:	e9 2a ff ff ff       	jmp    800e0c <__udivdi3+0x4c>
  800ee2:	66 90                	xchg   %ax,%ax
  800ee4:	66 90                	xchg   %ax,%ax
  800ee6:	66 90                	xchg   %ax,%ax
  800ee8:	66 90                	xchg   %ax,%ax
  800eea:	66 90                	xchg   %ax,%ax
  800eec:	66 90                	xchg   %ax,%ax
  800eee:	66 90                	xchg   %ax,%ax

00800ef0 <__umoddi3>:
  800ef0:	55                   	push   %ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 1c             	sub    $0x1c,%esp
  800ef7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800efb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800eff:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f07:	85 d2                	test   %edx,%edx
  800f09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f11:	89 f3                	mov    %esi,%ebx
  800f13:	89 3c 24             	mov    %edi,(%esp)
  800f16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f1a:	75 1c                	jne    800f38 <__umoddi3+0x48>
  800f1c:	39 f7                	cmp    %esi,%edi
  800f1e:	76 50                	jbe    800f70 <__umoddi3+0x80>
  800f20:	89 c8                	mov    %ecx,%eax
  800f22:	89 f2                	mov    %esi,%edx
  800f24:	f7 f7                	div    %edi
  800f26:	89 d0                	mov    %edx,%eax
  800f28:	31 d2                	xor    %edx,%edx
  800f2a:	83 c4 1c             	add    $0x1c,%esp
  800f2d:	5b                   	pop    %ebx
  800f2e:	5e                   	pop    %esi
  800f2f:	5f                   	pop    %edi
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    
  800f32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f38:	39 f2                	cmp    %esi,%edx
  800f3a:	89 d0                	mov    %edx,%eax
  800f3c:	77 52                	ja     800f90 <__umoddi3+0xa0>
  800f3e:	0f bd ea             	bsr    %edx,%ebp
  800f41:	83 f5 1f             	xor    $0x1f,%ebp
  800f44:	75 5a                	jne    800fa0 <__umoddi3+0xb0>
  800f46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f4a:	0f 82 e0 00 00 00    	jb     801030 <__umoddi3+0x140>
  800f50:	39 0c 24             	cmp    %ecx,(%esp)
  800f53:	0f 86 d7 00 00 00    	jbe    801030 <__umoddi3+0x140>
  800f59:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f61:	83 c4 1c             	add    $0x1c,%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	85 ff                	test   %edi,%edi
  800f72:	89 fd                	mov    %edi,%ebp
  800f74:	75 0b                	jne    800f81 <__umoddi3+0x91>
  800f76:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	f7 f7                	div    %edi
  800f7f:	89 c5                	mov    %eax,%ebp
  800f81:	89 f0                	mov    %esi,%eax
  800f83:	31 d2                	xor    %edx,%edx
  800f85:	f7 f5                	div    %ebp
  800f87:	89 c8                	mov    %ecx,%eax
  800f89:	f7 f5                	div    %ebp
  800f8b:	89 d0                	mov    %edx,%eax
  800f8d:	eb 99                	jmp    800f28 <__umoddi3+0x38>
  800f8f:	90                   	nop
  800f90:	89 c8                	mov    %ecx,%eax
  800f92:	89 f2                	mov    %esi,%edx
  800f94:	83 c4 1c             	add    $0x1c,%esp
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    
  800f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fa0:	8b 34 24             	mov    (%esp),%esi
  800fa3:	bf 20 00 00 00       	mov    $0x20,%edi
  800fa8:	89 e9                	mov    %ebp,%ecx
  800faa:	29 ef                	sub    %ebp,%edi
  800fac:	d3 e0                	shl    %cl,%eax
  800fae:	89 f9                	mov    %edi,%ecx
  800fb0:	89 f2                	mov    %esi,%edx
  800fb2:	d3 ea                	shr    %cl,%edx
  800fb4:	89 e9                	mov    %ebp,%ecx
  800fb6:	09 c2                	or     %eax,%edx
  800fb8:	89 d8                	mov    %ebx,%eax
  800fba:	89 14 24             	mov    %edx,(%esp)
  800fbd:	89 f2                	mov    %esi,%edx
  800fbf:	d3 e2                	shl    %cl,%edx
  800fc1:	89 f9                	mov    %edi,%ecx
  800fc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fcb:	d3 e8                	shr    %cl,%eax
  800fcd:	89 e9                	mov    %ebp,%ecx
  800fcf:	89 c6                	mov    %eax,%esi
  800fd1:	d3 e3                	shl    %cl,%ebx
  800fd3:	89 f9                	mov    %edi,%ecx
  800fd5:	89 d0                	mov    %edx,%eax
  800fd7:	d3 e8                	shr    %cl,%eax
  800fd9:	89 e9                	mov    %ebp,%ecx
  800fdb:	09 d8                	or     %ebx,%eax
  800fdd:	89 d3                	mov    %edx,%ebx
  800fdf:	89 f2                	mov    %esi,%edx
  800fe1:	f7 34 24             	divl   (%esp)
  800fe4:	89 d6                	mov    %edx,%esi
  800fe6:	d3 e3                	shl    %cl,%ebx
  800fe8:	f7 64 24 04          	mull   0x4(%esp)
  800fec:	39 d6                	cmp    %edx,%esi
  800fee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ff2:	89 d1                	mov    %edx,%ecx
  800ff4:	89 c3                	mov    %eax,%ebx
  800ff6:	72 08                	jb     801000 <__umoddi3+0x110>
  800ff8:	75 11                	jne    80100b <__umoddi3+0x11b>
  800ffa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800ffe:	73 0b                	jae    80100b <__umoddi3+0x11b>
  801000:	2b 44 24 04          	sub    0x4(%esp),%eax
  801004:	1b 14 24             	sbb    (%esp),%edx
  801007:	89 d1                	mov    %edx,%ecx
  801009:	89 c3                	mov    %eax,%ebx
  80100b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80100f:	29 da                	sub    %ebx,%edx
  801011:	19 ce                	sbb    %ecx,%esi
  801013:	89 f9                	mov    %edi,%ecx
  801015:	89 f0                	mov    %esi,%eax
  801017:	d3 e0                	shl    %cl,%eax
  801019:	89 e9                	mov    %ebp,%ecx
  80101b:	d3 ea                	shr    %cl,%edx
  80101d:	89 e9                	mov    %ebp,%ecx
  80101f:	d3 ee                	shr    %cl,%esi
  801021:	09 d0                	or     %edx,%eax
  801023:	89 f2                	mov    %esi,%edx
  801025:	83 c4 1c             	add    $0x1c,%esp
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    
  80102d:	8d 76 00             	lea    0x0(%esi),%esi
  801030:	29 f9                	sub    %edi,%ecx
  801032:	19 d6                	sbb    %edx,%esi
  801034:	89 74 24 04          	mov    %esi,0x4(%esp)
  801038:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80103c:	e9 18 ff ff ff       	jmp    800f59 <__umoddi3+0x69>
