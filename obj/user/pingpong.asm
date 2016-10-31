
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 eb 0c 00 00       	call   800d2c <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 f0 0a 00 00       	call   800b3f <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 a0 10 80 00       	push   $0x8010a0
  800059:	e8 55 01 00 00       	call   8001b3 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 05 0d 00 00       	call   800d71 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 db 0c 00 00       	call   800d5a <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 b6 0a 00 00       	call   800b3f <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 b6 10 80 00       	push   $0x8010b6
  800091:	e8 1d 01 00 00       	call   8001b3 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 c3 0c 00 00       	call   800d71 <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000c9:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000d0:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  8000d3:	e8 67 0a 00 00       	call   800b3f <sys_getenvid>
  8000d8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e5:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ea:	85 db                	test   %ebx,%ebx
  8000ec:	7e 07                	jle    8000f5 <libmain+0x37>
		binaryname = argv[0];
  8000ee:	8b 06                	mov    (%esi),%eax
  8000f0:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f5:	83 ec 08             	sub    $0x8,%esp
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
  8000fa:	e8 34 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ff:	e8 0a 00 00 00       	call   80010e <exit>
}
  800104:	83 c4 10             	add    $0x10,%esp
  800107:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    

0080010e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800114:	6a 00                	push   $0x0
  800116:	e8 e3 09 00 00       	call   800afe <sys_env_destroy>
}
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	c9                   	leave  
  80011f:	c3                   	ret    

00800120 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	53                   	push   %ebx
  800124:	83 ec 04             	sub    $0x4,%esp
  800127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012a:	8b 13                	mov    (%ebx),%edx
  80012c:	8d 42 01             	lea    0x1(%edx),%eax
  80012f:	89 03                	mov    %eax,(%ebx)
  800131:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800134:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800138:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013d:	75 1a                	jne    800159 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013f:	83 ec 08             	sub    $0x8,%esp
  800142:	68 ff 00 00 00       	push   $0xff
  800147:	8d 43 08             	lea    0x8(%ebx),%eax
  80014a:	50                   	push   %eax
  80014b:	e8 71 09 00 00       	call   800ac1 <sys_cputs>
		b->idx = 0;
  800150:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800156:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800159:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800172:	00 00 00 
	b.cnt = 0;
  800175:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017f:	ff 75 0c             	pushl  0xc(%ebp)
  800182:	ff 75 08             	pushl  0x8(%ebp)
  800185:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018b:	50                   	push   %eax
  80018c:	68 20 01 80 00       	push   $0x800120
  800191:	e8 54 01 00 00       	call   8002ea <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800196:	83 c4 08             	add    $0x8,%esp
  800199:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a5:	50                   	push   %eax
  8001a6:	e8 16 09 00 00       	call   800ac1 <sys_cputs>

	return b.cnt;
}
  8001ab:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b1:	c9                   	leave  
  8001b2:	c3                   	ret    

008001b3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bc:	50                   	push   %eax
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	e8 9d ff ff ff       	call   800162 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c5:	c9                   	leave  
  8001c6:	c3                   	ret    

008001c7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	57                   	push   %edi
  8001cb:	56                   	push   %esi
  8001cc:	53                   	push   %ebx
  8001cd:	83 ec 1c             	sub    $0x1c,%esp
  8001d0:	89 c7                	mov    %eax,%edi
  8001d2:	89 d6                	mov    %edx,%esi
  8001d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001eb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ee:	39 d3                	cmp    %edx,%ebx
  8001f0:	72 05                	jb     8001f7 <printnum+0x30>
  8001f2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f5:	77 45                	ja     80023c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f7:	83 ec 0c             	sub    $0xc,%esp
  8001fa:	ff 75 18             	pushl  0x18(%ebp)
  8001fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800200:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	83 ec 08             	sub    $0x8,%esp
  80020a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020d:	ff 75 e0             	pushl  -0x20(%ebp)
  800210:	ff 75 dc             	pushl  -0x24(%ebp)
  800213:	ff 75 d8             	pushl  -0x28(%ebp)
  800216:	e8 f5 0b 00 00       	call   800e10 <__udivdi3>
  80021b:	83 c4 18             	add    $0x18,%esp
  80021e:	52                   	push   %edx
  80021f:	50                   	push   %eax
  800220:	89 f2                	mov    %esi,%edx
  800222:	89 f8                	mov    %edi,%eax
  800224:	e8 9e ff ff ff       	call   8001c7 <printnum>
  800229:	83 c4 20             	add    $0x20,%esp
  80022c:	eb 18                	jmp    800246 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022e:	83 ec 08             	sub    $0x8,%esp
  800231:	56                   	push   %esi
  800232:	ff 75 18             	pushl  0x18(%ebp)
  800235:	ff d7                	call   *%edi
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	eb 03                	jmp    80023f <printnum+0x78>
  80023c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023f:	83 eb 01             	sub    $0x1,%ebx
  800242:	85 db                	test   %ebx,%ebx
  800244:	7f e8                	jg     80022e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800246:	83 ec 08             	sub    $0x8,%esp
  800249:	56                   	push   %esi
  80024a:	83 ec 04             	sub    $0x4,%esp
  80024d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800250:	ff 75 e0             	pushl  -0x20(%ebp)
  800253:	ff 75 dc             	pushl  -0x24(%ebp)
  800256:	ff 75 d8             	pushl  -0x28(%ebp)
  800259:	e8 e2 0c 00 00       	call   800f40 <__umoddi3>
  80025e:	83 c4 14             	add    $0x14,%esp
  800261:	0f be 80 d3 10 80 00 	movsbl 0x8010d3(%eax),%eax
  800268:	50                   	push   %eax
  800269:	ff d7                	call   *%edi
}
  80026b:	83 c4 10             	add    $0x10,%esp
  80026e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800271:	5b                   	pop    %ebx
  800272:	5e                   	pop    %esi
  800273:	5f                   	pop    %edi
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    

00800276 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800279:	83 fa 01             	cmp    $0x1,%edx
  80027c:	7e 0e                	jle    80028c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	8d 4a 08             	lea    0x8(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 02                	mov    (%edx),%eax
  800287:	8b 52 04             	mov    0x4(%edx),%edx
  80028a:	eb 22                	jmp    8002ae <getuint+0x38>
	else if (lflag)
  80028c:	85 d2                	test   %edx,%edx
  80028e:	74 10                	je     8002a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800290:	8b 10                	mov    (%eax),%edx
  800292:	8d 4a 04             	lea    0x4(%edx),%ecx
  800295:	89 08                	mov    %ecx,(%eax)
  800297:	8b 02                	mov    (%edx),%eax
  800299:	ba 00 00 00 00       	mov    $0x0,%edx
  80029e:	eb 0e                	jmp    8002ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ba:	8b 10                	mov    (%eax),%edx
  8002bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bf:	73 0a                	jae    8002cb <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c4:	89 08                	mov    %ecx,(%eax)
  8002c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c9:	88 02                	mov    %al,(%edx)
}
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d6:	50                   	push   %eax
  8002d7:	ff 75 10             	pushl  0x10(%ebp)
  8002da:	ff 75 0c             	pushl  0xc(%ebp)
  8002dd:	ff 75 08             	pushl  0x8(%ebp)
  8002e0:	e8 05 00 00 00       	call   8002ea <vprintfmt>
	va_end(ap);
}
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	c9                   	leave  
  8002e9:	c3                   	ret    

008002ea <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	57                   	push   %edi
  8002ee:	56                   	push   %esi
  8002ef:	53                   	push   %ebx
  8002f0:	83 ec 2c             	sub    $0x2c,%esp
  8002f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fc:	eb 12                	jmp    800310 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002fe:	85 c0                	test   %eax,%eax
  800300:	0f 84 cb 03 00 00    	je     8006d1 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800306:	83 ec 08             	sub    $0x8,%esp
  800309:	53                   	push   %ebx
  80030a:	50                   	push   %eax
  80030b:	ff d6                	call   *%esi
  80030d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800310:	83 c7 01             	add    $0x1,%edi
  800313:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800317:	83 f8 25             	cmp    $0x25,%eax
  80031a:	75 e2                	jne    8002fe <vprintfmt+0x14>
  80031c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800320:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800327:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80032e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800335:	ba 00 00 00 00       	mov    $0x0,%edx
  80033a:	eb 07                	jmp    800343 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80033f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800343:	8d 47 01             	lea    0x1(%edi),%eax
  800346:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800349:	0f b6 07             	movzbl (%edi),%eax
  80034c:	0f b6 c8             	movzbl %al,%ecx
  80034f:	83 e8 23             	sub    $0x23,%eax
  800352:	3c 55                	cmp    $0x55,%al
  800354:	0f 87 5c 03 00 00    	ja     8006b6 <vprintfmt+0x3cc>
  80035a:	0f b6 c0             	movzbl %al,%eax
  80035d:	ff 24 85 a0 11 80 00 	jmp    *0x8011a0(,%eax,4)
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800367:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036b:	eb d6                	jmp    800343 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800370:	b8 00 00 00 00       	mov    $0x0,%eax
  800375:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800378:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80037f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800382:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800385:	83 fa 09             	cmp    $0x9,%edx
  800388:	77 39                	ja     8003c3 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038d:	eb e9                	jmp    800378 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80038f:	8b 45 14             	mov    0x14(%ebp),%eax
  800392:	8d 48 04             	lea    0x4(%eax),%ecx
  800395:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800398:	8b 00                	mov    (%eax),%eax
  80039a:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a0:	eb 27                	jmp    8003c9 <vprintfmt+0xdf>
  8003a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a5:	85 c0                	test   %eax,%eax
  8003a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ac:	0f 49 c8             	cmovns %eax,%ecx
  8003af:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b5:	eb 8c                	jmp    800343 <vprintfmt+0x59>
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ba:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c1:	eb 80                	jmp    800343 <vprintfmt+0x59>
  8003c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c6:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8003c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cd:	0f 89 70 ff ff ff    	jns    800343 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003d3:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d9:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003e0:	e9 5e ff ff ff       	jmp    800343 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e5:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003eb:	e9 53 ff ff ff       	jmp    800343 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f3:	8d 50 04             	lea    0x4(%eax),%edx
  8003f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	53                   	push   %ebx
  8003fd:	ff 30                	pushl  (%eax)
  8003ff:	ff d6                	call   *%esi
			break;
  800401:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800407:	e9 04 ff ff ff       	jmp    800310 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 50 04             	lea    0x4(%eax),%edx
  800412:	89 55 14             	mov    %edx,0x14(%ebp)
  800415:	8b 00                	mov    (%eax),%eax
  800417:	99                   	cltd   
  800418:	31 d0                	xor    %edx,%eax
  80041a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041c:	83 f8 09             	cmp    $0x9,%eax
  80041f:	7f 0b                	jg     80042c <vprintfmt+0x142>
  800421:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  800428:	85 d2                	test   %edx,%edx
  80042a:	75 18                	jne    800444 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80042c:	50                   	push   %eax
  80042d:	68 eb 10 80 00       	push   $0x8010eb
  800432:	53                   	push   %ebx
  800433:	56                   	push   %esi
  800434:	e8 94 fe ff ff       	call   8002cd <printfmt>
  800439:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80043f:	e9 cc fe ff ff       	jmp    800310 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800444:	52                   	push   %edx
  800445:	68 f4 10 80 00       	push   $0x8010f4
  80044a:	53                   	push   %ebx
  80044b:	56                   	push   %esi
  80044c:	e8 7c fe ff ff       	call   8002cd <printfmt>
  800451:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800457:	e9 b4 fe ff ff       	jmp    800310 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800467:	85 ff                	test   %edi,%edi
  800469:	b8 e4 10 80 00       	mov    $0x8010e4,%eax
  80046e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800471:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800475:	0f 8e 94 00 00 00    	jle    80050f <vprintfmt+0x225>
  80047b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80047f:	0f 84 98 00 00 00    	je     80051d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	ff 75 c8             	pushl  -0x38(%ebp)
  80048b:	57                   	push   %edi
  80048c:	e8 c8 02 00 00       	call   800759 <strnlen>
  800491:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800494:	29 c1                	sub    %eax,%ecx
  800496:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800499:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a8:	eb 0f                	jmp    8004b9 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	53                   	push   %ebx
  8004ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b3:	83 ef 01             	sub    $0x1,%edi
  8004b6:	83 c4 10             	add    $0x10,%esp
  8004b9:	85 ff                	test   %edi,%edi
  8004bb:	7f ed                	jg     8004aa <vprintfmt+0x1c0>
  8004bd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004c3:	85 c9                	test   %ecx,%ecx
  8004c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ca:	0f 49 c1             	cmovns %ecx,%eax
  8004cd:	29 c1                	sub    %eax,%ecx
  8004cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d2:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d8:	89 cb                	mov    %ecx,%ebx
  8004da:	eb 4d                	jmp    800529 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004dc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e0:	74 1b                	je     8004fd <vprintfmt+0x213>
  8004e2:	0f be c0             	movsbl %al,%eax
  8004e5:	83 e8 20             	sub    $0x20,%eax
  8004e8:	83 f8 5e             	cmp    $0x5e,%eax
  8004eb:	76 10                	jbe    8004fd <vprintfmt+0x213>
					putch('?', putdat);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	ff 75 0c             	pushl  0xc(%ebp)
  8004f3:	6a 3f                	push   $0x3f
  8004f5:	ff 55 08             	call   *0x8(%ebp)
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	eb 0d                	jmp    80050a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	ff 75 0c             	pushl  0xc(%ebp)
  800503:	52                   	push   %edx
  800504:	ff 55 08             	call   *0x8(%ebp)
  800507:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050a:	83 eb 01             	sub    $0x1,%ebx
  80050d:	eb 1a                	jmp    800529 <vprintfmt+0x23f>
  80050f:	89 75 08             	mov    %esi,0x8(%ebp)
  800512:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800515:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800518:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051b:	eb 0c                	jmp    800529 <vprintfmt+0x23f>
  80051d:	89 75 08             	mov    %esi,0x8(%ebp)
  800520:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800523:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800526:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800529:	83 c7 01             	add    $0x1,%edi
  80052c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800530:	0f be d0             	movsbl %al,%edx
  800533:	85 d2                	test   %edx,%edx
  800535:	74 23                	je     80055a <vprintfmt+0x270>
  800537:	85 f6                	test   %esi,%esi
  800539:	78 a1                	js     8004dc <vprintfmt+0x1f2>
  80053b:	83 ee 01             	sub    $0x1,%esi
  80053e:	79 9c                	jns    8004dc <vprintfmt+0x1f2>
  800540:	89 df                	mov    %ebx,%edi
  800542:	8b 75 08             	mov    0x8(%ebp),%esi
  800545:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800548:	eb 18                	jmp    800562 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	53                   	push   %ebx
  80054e:	6a 20                	push   $0x20
  800550:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800552:	83 ef 01             	sub    $0x1,%edi
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	eb 08                	jmp    800562 <vprintfmt+0x278>
  80055a:	89 df                	mov    %ebx,%edi
  80055c:	8b 75 08             	mov    0x8(%ebp),%esi
  80055f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800562:	85 ff                	test   %edi,%edi
  800564:	7f e4                	jg     80054a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800566:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800569:	e9 a2 fd ff ff       	jmp    800310 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056e:	83 fa 01             	cmp    $0x1,%edx
  800571:	7e 16                	jle    800589 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 50 08             	lea    0x8(%eax),%edx
  800579:	89 55 14             	mov    %edx,0x14(%ebp)
  80057c:	8b 50 04             	mov    0x4(%eax),%edx
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800584:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800587:	eb 32                	jmp    8005bb <vprintfmt+0x2d1>
	else if (lflag)
  800589:	85 d2                	test   %edx,%edx
  80058b:	74 18                	je     8005a5 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8d 50 04             	lea    0x4(%eax),%edx
  800593:	89 55 14             	mov    %edx,0x14(%ebp)
  800596:	8b 00                	mov    (%eax),%eax
  800598:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80059b:	89 c1                	mov    %eax,%ecx
  80059d:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005a3:	eb 16                	jmp    8005bb <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 50 04             	lea    0x4(%eax),%edx
  8005ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ae:	8b 00                	mov    (%eax),%eax
  8005b0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005b3:	89 c1                	mov    %eax,%ecx
  8005b5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bb:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005be:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005cc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005d0:	0f 89 a8 00 00 00    	jns    80067e <vprintfmt+0x394>
				putch('-', putdat);
  8005d6:	83 ec 08             	sub    $0x8,%esp
  8005d9:	53                   	push   %ebx
  8005da:	6a 2d                	push   $0x2d
  8005dc:	ff d6                	call   *%esi
				num = -(long long) num;
  8005de:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005e1:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005e4:	f7 d8                	neg    %eax
  8005e6:	83 d2 00             	adc    $0x0,%edx
  8005e9:	f7 da                	neg    %edx
  8005eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f1:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005f4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f9:	e9 80 00 00 00       	jmp    80067e <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800601:	e8 70 fc ff ff       	call   800276 <getuint>
  800606:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800609:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80060c:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800611:	eb 6b                	jmp    80067e <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800613:	8d 45 14             	lea    0x14(%ebp),%eax
  800616:	e8 5b fc ff ff       	call   800276 <getuint>
  80061b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800621:	6a 04                	push   $0x4
  800623:	6a 03                	push   $0x3
  800625:	6a 01                	push   $0x1
  800627:	68 f7 10 80 00       	push   $0x8010f7
  80062c:	e8 82 fb ff ff       	call   8001b3 <cprintf>
			goto number;
  800631:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  800634:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  800639:	eb 43                	jmp    80067e <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	53                   	push   %ebx
  80063f:	6a 30                	push   $0x30
  800641:	ff d6                	call   *%esi
			putch('x', putdat);
  800643:	83 c4 08             	add    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	6a 78                	push   $0x78
  800649:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8d 50 04             	lea    0x4(%eax),%edx
  800651:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800654:	8b 00                	mov    (%eax),%eax
  800656:	ba 00 00 00 00       	mov    $0x0,%edx
  80065b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065e:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800661:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800664:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800669:	eb 13                	jmp    80067e <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80066b:	8d 45 14             	lea    0x14(%ebp),%eax
  80066e:	e8 03 fc ff ff       	call   800276 <getuint>
  800673:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800676:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  800679:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067e:	83 ec 0c             	sub    $0xc,%esp
  800681:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800685:	52                   	push   %edx
  800686:	ff 75 e0             	pushl  -0x20(%ebp)
  800689:	50                   	push   %eax
  80068a:	ff 75 dc             	pushl  -0x24(%ebp)
  80068d:	ff 75 d8             	pushl  -0x28(%ebp)
  800690:	89 da                	mov    %ebx,%edx
  800692:	89 f0                	mov    %esi,%eax
  800694:	e8 2e fb ff ff       	call   8001c7 <printnum>

			break;
  800699:	83 c4 20             	add    $0x20,%esp
  80069c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069f:	e9 6c fc ff ff       	jmp    800310 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	53                   	push   %ebx
  8006a8:	51                   	push   %ecx
  8006a9:	ff d6                	call   *%esi
			break;
  8006ab:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b1:	e9 5a fc ff ff       	jmp    800310 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	6a 25                	push   $0x25
  8006bc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	eb 03                	jmp    8006c6 <vprintfmt+0x3dc>
  8006c3:	83 ef 01             	sub    $0x1,%edi
  8006c6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ca:	75 f7                	jne    8006c3 <vprintfmt+0x3d9>
  8006cc:	e9 3f fc ff ff       	jmp    800310 <vprintfmt+0x26>
			break;
		}

	}

}
  8006d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d4:	5b                   	pop    %ebx
  8006d5:	5e                   	pop    %esi
  8006d6:	5f                   	pop    %edi
  8006d7:	5d                   	pop    %ebp
  8006d8:	c3                   	ret    

008006d9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
  8006dc:	83 ec 18             	sub    $0x18,%esp
  8006df:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ec:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f6:	85 c0                	test   %eax,%eax
  8006f8:	74 26                	je     800720 <vsnprintf+0x47>
  8006fa:	85 d2                	test   %edx,%edx
  8006fc:	7e 22                	jle    800720 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fe:	ff 75 14             	pushl  0x14(%ebp)
  800701:	ff 75 10             	pushl  0x10(%ebp)
  800704:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800707:	50                   	push   %eax
  800708:	68 b0 02 80 00       	push   $0x8002b0
  80070d:	e8 d8 fb ff ff       	call   8002ea <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800712:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800715:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800718:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071b:	83 c4 10             	add    $0x10,%esp
  80071e:	eb 05                	jmp    800725 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800720:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800725:	c9                   	leave  
  800726:	c3                   	ret    

00800727 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800730:	50                   	push   %eax
  800731:	ff 75 10             	pushl  0x10(%ebp)
  800734:	ff 75 0c             	pushl  0xc(%ebp)
  800737:	ff 75 08             	pushl  0x8(%ebp)
  80073a:	e8 9a ff ff ff       	call   8006d9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073f:	c9                   	leave  
  800740:	c3                   	ret    

00800741 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
  800744:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800747:	b8 00 00 00 00       	mov    $0x0,%eax
  80074c:	eb 03                	jmp    800751 <strlen+0x10>
		n++;
  80074e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800751:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800755:	75 f7                	jne    80074e <strlen+0xd>
		n++;
	return n;
}
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800762:	ba 00 00 00 00       	mov    $0x0,%edx
  800767:	eb 03                	jmp    80076c <strnlen+0x13>
		n++;
  800769:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076c:	39 c2                	cmp    %eax,%edx
  80076e:	74 08                	je     800778 <strnlen+0x1f>
  800770:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800774:	75 f3                	jne    800769 <strnlen+0x10>
  800776:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	53                   	push   %ebx
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800784:	89 c2                	mov    %eax,%edx
  800786:	83 c2 01             	add    $0x1,%edx
  800789:	83 c1 01             	add    $0x1,%ecx
  80078c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800790:	88 5a ff             	mov    %bl,-0x1(%edx)
  800793:	84 db                	test   %bl,%bl
  800795:	75 ef                	jne    800786 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800797:	5b                   	pop    %ebx
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	53                   	push   %ebx
  80079e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a1:	53                   	push   %ebx
  8007a2:	e8 9a ff ff ff       	call   800741 <strlen>
  8007a7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007aa:	ff 75 0c             	pushl  0xc(%ebp)
  8007ad:	01 d8                	add    %ebx,%eax
  8007af:	50                   	push   %eax
  8007b0:	e8 c5 ff ff ff       	call   80077a <strcpy>
	return dst;
}
  8007b5:	89 d8                	mov    %ebx,%eax
  8007b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	56                   	push   %esi
  8007c0:	53                   	push   %ebx
  8007c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c7:	89 f3                	mov    %esi,%ebx
  8007c9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cc:	89 f2                	mov    %esi,%edx
  8007ce:	eb 0f                	jmp    8007df <strncpy+0x23>
		*dst++ = *src;
  8007d0:	83 c2 01             	add    $0x1,%edx
  8007d3:	0f b6 01             	movzbl (%ecx),%eax
  8007d6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d9:	80 39 01             	cmpb   $0x1,(%ecx)
  8007dc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007df:	39 da                	cmp    %ebx,%edx
  8007e1:	75 ed                	jne    8007d0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e3:	89 f0                	mov    %esi,%eax
  8007e5:	5b                   	pop    %ebx
  8007e6:	5e                   	pop    %esi
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	56                   	push   %esi
  8007ed:	53                   	push   %ebx
  8007ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f4:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f9:	85 d2                	test   %edx,%edx
  8007fb:	74 21                	je     80081e <strlcpy+0x35>
  8007fd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800801:	89 f2                	mov    %esi,%edx
  800803:	eb 09                	jmp    80080e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800805:	83 c2 01             	add    $0x1,%edx
  800808:	83 c1 01             	add    $0x1,%ecx
  80080b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080e:	39 c2                	cmp    %eax,%edx
  800810:	74 09                	je     80081b <strlcpy+0x32>
  800812:	0f b6 19             	movzbl (%ecx),%ebx
  800815:	84 db                	test   %bl,%bl
  800817:	75 ec                	jne    800805 <strlcpy+0x1c>
  800819:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80081b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081e:	29 f0                	sub    %esi,%eax
}
  800820:	5b                   	pop    %ebx
  800821:	5e                   	pop    %esi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082d:	eb 06                	jmp    800835 <strcmp+0x11>
		p++, q++;
  80082f:	83 c1 01             	add    $0x1,%ecx
  800832:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800835:	0f b6 01             	movzbl (%ecx),%eax
  800838:	84 c0                	test   %al,%al
  80083a:	74 04                	je     800840 <strcmp+0x1c>
  80083c:	3a 02                	cmp    (%edx),%al
  80083e:	74 ef                	je     80082f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800840:	0f b6 c0             	movzbl %al,%eax
  800843:	0f b6 12             	movzbl (%edx),%edx
  800846:	29 d0                	sub    %edx,%eax
}
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	53                   	push   %ebx
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	8b 55 0c             	mov    0xc(%ebp),%edx
  800854:	89 c3                	mov    %eax,%ebx
  800856:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800859:	eb 06                	jmp    800861 <strncmp+0x17>
		n--, p++, q++;
  80085b:	83 c0 01             	add    $0x1,%eax
  80085e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800861:	39 d8                	cmp    %ebx,%eax
  800863:	74 15                	je     80087a <strncmp+0x30>
  800865:	0f b6 08             	movzbl (%eax),%ecx
  800868:	84 c9                	test   %cl,%cl
  80086a:	74 04                	je     800870 <strncmp+0x26>
  80086c:	3a 0a                	cmp    (%edx),%cl
  80086e:	74 eb                	je     80085b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800870:	0f b6 00             	movzbl (%eax),%eax
  800873:	0f b6 12             	movzbl (%edx),%edx
  800876:	29 d0                	sub    %edx,%eax
  800878:	eb 05                	jmp    80087f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80087a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087f:	5b                   	pop    %ebx
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088c:	eb 07                	jmp    800895 <strchr+0x13>
		if (*s == c)
  80088e:	38 ca                	cmp    %cl,%dl
  800890:	74 0f                	je     8008a1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800892:	83 c0 01             	add    $0x1,%eax
  800895:	0f b6 10             	movzbl (%eax),%edx
  800898:	84 d2                	test   %dl,%dl
  80089a:	75 f2                	jne    80088e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80089c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ad:	eb 03                	jmp    8008b2 <strfind+0xf>
  8008af:	83 c0 01             	add    $0x1,%eax
  8008b2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b5:	38 ca                	cmp    %cl,%dl
  8008b7:	74 04                	je     8008bd <strfind+0x1a>
  8008b9:	84 d2                	test   %dl,%dl
  8008bb:	75 f2                	jne    8008af <strfind+0xc>
			break;
	return (char *) s;
}
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	57                   	push   %edi
  8008c3:	56                   	push   %esi
  8008c4:	53                   	push   %ebx
  8008c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008cb:	85 c9                	test   %ecx,%ecx
  8008cd:	74 36                	je     800905 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d5:	75 28                	jne    8008ff <memset+0x40>
  8008d7:	f6 c1 03             	test   $0x3,%cl
  8008da:	75 23                	jne    8008ff <memset+0x40>
		c &= 0xFF;
  8008dc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e0:	89 d3                	mov    %edx,%ebx
  8008e2:	c1 e3 08             	shl    $0x8,%ebx
  8008e5:	89 d6                	mov    %edx,%esi
  8008e7:	c1 e6 18             	shl    $0x18,%esi
  8008ea:	89 d0                	mov    %edx,%eax
  8008ec:	c1 e0 10             	shl    $0x10,%eax
  8008ef:	09 f0                	or     %esi,%eax
  8008f1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f3:	89 d8                	mov    %ebx,%eax
  8008f5:	09 d0                	or     %edx,%eax
  8008f7:	c1 e9 02             	shr    $0x2,%ecx
  8008fa:	fc                   	cld    
  8008fb:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fd:	eb 06                	jmp    800905 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800902:	fc                   	cld    
  800903:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800905:	89 f8                	mov    %edi,%eax
  800907:	5b                   	pop    %ebx
  800908:	5e                   	pop    %esi
  800909:	5f                   	pop    %edi
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	57                   	push   %edi
  800910:	56                   	push   %esi
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	8b 75 0c             	mov    0xc(%ebp),%esi
  800917:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091a:	39 c6                	cmp    %eax,%esi
  80091c:	73 35                	jae    800953 <memmove+0x47>
  80091e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800921:	39 d0                	cmp    %edx,%eax
  800923:	73 2e                	jae    800953 <memmove+0x47>
		s += n;
		d += n;
  800925:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800928:	89 d6                	mov    %edx,%esi
  80092a:	09 fe                	or     %edi,%esi
  80092c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800932:	75 13                	jne    800947 <memmove+0x3b>
  800934:	f6 c1 03             	test   $0x3,%cl
  800937:	75 0e                	jne    800947 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800939:	83 ef 04             	sub    $0x4,%edi
  80093c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093f:	c1 e9 02             	shr    $0x2,%ecx
  800942:	fd                   	std    
  800943:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800945:	eb 09                	jmp    800950 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800947:	83 ef 01             	sub    $0x1,%edi
  80094a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80094d:	fd                   	std    
  80094e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800950:	fc                   	cld    
  800951:	eb 1d                	jmp    800970 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800953:	89 f2                	mov    %esi,%edx
  800955:	09 c2                	or     %eax,%edx
  800957:	f6 c2 03             	test   $0x3,%dl
  80095a:	75 0f                	jne    80096b <memmove+0x5f>
  80095c:	f6 c1 03             	test   $0x3,%cl
  80095f:	75 0a                	jne    80096b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800961:	c1 e9 02             	shr    $0x2,%ecx
  800964:	89 c7                	mov    %eax,%edi
  800966:	fc                   	cld    
  800967:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800969:	eb 05                	jmp    800970 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096b:	89 c7                	mov    %eax,%edi
  80096d:	fc                   	cld    
  80096e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800970:	5e                   	pop    %esi
  800971:	5f                   	pop    %edi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800977:	ff 75 10             	pushl  0x10(%ebp)
  80097a:	ff 75 0c             	pushl  0xc(%ebp)
  80097d:	ff 75 08             	pushl  0x8(%ebp)
  800980:	e8 87 ff ff ff       	call   80090c <memmove>
}
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	56                   	push   %esi
  80098b:	53                   	push   %ebx
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800992:	89 c6                	mov    %eax,%esi
  800994:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800997:	eb 1a                	jmp    8009b3 <memcmp+0x2c>
		if (*s1 != *s2)
  800999:	0f b6 08             	movzbl (%eax),%ecx
  80099c:	0f b6 1a             	movzbl (%edx),%ebx
  80099f:	38 d9                	cmp    %bl,%cl
  8009a1:	74 0a                	je     8009ad <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a3:	0f b6 c1             	movzbl %cl,%eax
  8009a6:	0f b6 db             	movzbl %bl,%ebx
  8009a9:	29 d8                	sub    %ebx,%eax
  8009ab:	eb 0f                	jmp    8009bc <memcmp+0x35>
		s1++, s2++;
  8009ad:	83 c0 01             	add    $0x1,%eax
  8009b0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b3:	39 f0                	cmp    %esi,%eax
  8009b5:	75 e2                	jne    800999 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bc:	5b                   	pop    %ebx
  8009bd:	5e                   	pop    %esi
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	53                   	push   %ebx
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c7:	89 c1                	mov    %eax,%ecx
  8009c9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d0:	eb 0a                	jmp    8009dc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d2:	0f b6 10             	movzbl (%eax),%edx
  8009d5:	39 da                	cmp    %ebx,%edx
  8009d7:	74 07                	je     8009e0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d9:	83 c0 01             	add    $0x1,%eax
  8009dc:	39 c8                	cmp    %ecx,%eax
  8009de:	72 f2                	jb     8009d2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e0:	5b                   	pop    %ebx
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	57                   	push   %edi
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ef:	eb 03                	jmp    8009f4 <strtol+0x11>
		s++;
  8009f1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f4:	0f b6 01             	movzbl (%ecx),%eax
  8009f7:	3c 20                	cmp    $0x20,%al
  8009f9:	74 f6                	je     8009f1 <strtol+0xe>
  8009fb:	3c 09                	cmp    $0x9,%al
  8009fd:	74 f2                	je     8009f1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ff:	3c 2b                	cmp    $0x2b,%al
  800a01:	75 0a                	jne    800a0d <strtol+0x2a>
		s++;
  800a03:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a06:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0b:	eb 11                	jmp    800a1e <strtol+0x3b>
  800a0d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a12:	3c 2d                	cmp    $0x2d,%al
  800a14:	75 08                	jne    800a1e <strtol+0x3b>
		s++, neg = 1;
  800a16:	83 c1 01             	add    $0x1,%ecx
  800a19:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a24:	75 15                	jne    800a3b <strtol+0x58>
  800a26:	80 39 30             	cmpb   $0x30,(%ecx)
  800a29:	75 10                	jne    800a3b <strtol+0x58>
  800a2b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2f:	75 7c                	jne    800aad <strtol+0xca>
		s += 2, base = 16;
  800a31:	83 c1 02             	add    $0x2,%ecx
  800a34:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a39:	eb 16                	jmp    800a51 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a3b:	85 db                	test   %ebx,%ebx
  800a3d:	75 12                	jne    800a51 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a44:	80 39 30             	cmpb   $0x30,(%ecx)
  800a47:	75 08                	jne    800a51 <strtol+0x6e>
		s++, base = 8;
  800a49:	83 c1 01             	add    $0x1,%ecx
  800a4c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a51:	b8 00 00 00 00       	mov    $0x0,%eax
  800a56:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a59:	0f b6 11             	movzbl (%ecx),%edx
  800a5c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5f:	89 f3                	mov    %esi,%ebx
  800a61:	80 fb 09             	cmp    $0x9,%bl
  800a64:	77 08                	ja     800a6e <strtol+0x8b>
			dig = *s - '0';
  800a66:	0f be d2             	movsbl %dl,%edx
  800a69:	83 ea 30             	sub    $0x30,%edx
  800a6c:	eb 22                	jmp    800a90 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a6e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a71:	89 f3                	mov    %esi,%ebx
  800a73:	80 fb 19             	cmp    $0x19,%bl
  800a76:	77 08                	ja     800a80 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a78:	0f be d2             	movsbl %dl,%edx
  800a7b:	83 ea 57             	sub    $0x57,%edx
  800a7e:	eb 10                	jmp    800a90 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a80:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a83:	89 f3                	mov    %esi,%ebx
  800a85:	80 fb 19             	cmp    $0x19,%bl
  800a88:	77 16                	ja     800aa0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a8a:	0f be d2             	movsbl %dl,%edx
  800a8d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a90:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a93:	7d 0b                	jge    800aa0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a95:	83 c1 01             	add    $0x1,%ecx
  800a98:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a9c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9e:	eb b9                	jmp    800a59 <strtol+0x76>

	if (endptr)
  800aa0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa4:	74 0d                	je     800ab3 <strtol+0xd0>
		*endptr = (char *) s;
  800aa6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa9:	89 0e                	mov    %ecx,(%esi)
  800aab:	eb 06                	jmp    800ab3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aad:	85 db                	test   %ebx,%ebx
  800aaf:	74 98                	je     800a49 <strtol+0x66>
  800ab1:	eb 9e                	jmp    800a51 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab3:	89 c2                	mov    %eax,%edx
  800ab5:	f7 da                	neg    %edx
  800ab7:	85 ff                	test   %edi,%edi
  800ab9:	0f 45 c2             	cmovne %edx,%eax
}
  800abc:	5b                   	pop    %ebx
  800abd:	5e                   	pop    %esi
  800abe:	5f                   	pop    %edi
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	57                   	push   %edi
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
  800acc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad2:	89 c3                	mov    %eax,%ebx
  800ad4:	89 c7                	mov    %eax,%edi
  800ad6:	89 c6                	mov    %eax,%esi
  800ad8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5f                   	pop    %edi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <sys_cgetc>:

int
sys_cgetc(void)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aea:	b8 01 00 00 00       	mov    $0x1,%eax
  800aef:	89 d1                	mov    %edx,%ecx
  800af1:	89 d3                	mov    %edx,%ebx
  800af3:	89 d7                	mov    %edx,%edi
  800af5:	89 d6                	mov    %edx,%esi
  800af7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
  800b04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b07:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b11:	8b 55 08             	mov    0x8(%ebp),%edx
  800b14:	89 cb                	mov    %ecx,%ebx
  800b16:	89 cf                	mov    %ecx,%edi
  800b18:	89 ce                	mov    %ecx,%esi
  800b1a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b1c:	85 c0                	test   %eax,%eax
  800b1e:	7e 17                	jle    800b37 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b20:	83 ec 0c             	sub    $0xc,%esp
  800b23:	50                   	push   %eax
  800b24:	6a 03                	push   $0x3
  800b26:	68 28 13 80 00       	push   $0x801328
  800b2b:	6a 23                	push   $0x23
  800b2d:	68 45 13 80 00       	push   $0x801345
  800b32:	e8 8a 02 00 00       	call   800dc1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b45:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4f:	89 d1                	mov    %edx,%ecx
  800b51:	89 d3                	mov    %edx,%ebx
  800b53:	89 d7                	mov    %edx,%edi
  800b55:	89 d6                	mov    %edx,%esi
  800b57:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <sys_yield>:

void
sys_yield(void)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
  800b69:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b6e:	89 d1                	mov    %edx,%ecx
  800b70:	89 d3                	mov    %edx,%ebx
  800b72:	89 d7                	mov    %edx,%edi
  800b74:	89 d6                	mov    %edx,%esi
  800b76:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
  800b83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b86:	be 00 00 00 00       	mov    $0x0,%esi
  800b8b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b93:	8b 55 08             	mov    0x8(%ebp),%edx
  800b96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b99:	89 f7                	mov    %esi,%edi
  800b9b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9d:	85 c0                	test   %eax,%eax
  800b9f:	7e 17                	jle    800bb8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba1:	83 ec 0c             	sub    $0xc,%esp
  800ba4:	50                   	push   %eax
  800ba5:	6a 04                	push   $0x4
  800ba7:	68 28 13 80 00       	push   $0x801328
  800bac:	6a 23                	push   $0x23
  800bae:	68 45 13 80 00       	push   $0x801345
  800bb3:	e8 09 02 00 00       	call   800dc1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc9:	b8 05 00 00 00       	mov    $0x5,%eax
  800bce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bda:	8b 75 18             	mov    0x18(%ebp),%esi
  800bdd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bdf:	85 c0                	test   %eax,%eax
  800be1:	7e 17                	jle    800bfa <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be3:	83 ec 0c             	sub    $0xc,%esp
  800be6:	50                   	push   %eax
  800be7:	6a 05                	push   $0x5
  800be9:	68 28 13 80 00       	push   $0x801328
  800bee:	6a 23                	push   $0x23
  800bf0:	68 45 13 80 00       	push   $0x801345
  800bf5:	e8 c7 01 00 00       	call   800dc1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c10:	b8 06 00 00 00       	mov    $0x6,%eax
  800c15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c18:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1b:	89 df                	mov    %ebx,%edi
  800c1d:	89 de                	mov    %ebx,%esi
  800c1f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c21:	85 c0                	test   %eax,%eax
  800c23:	7e 17                	jle    800c3c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c25:	83 ec 0c             	sub    $0xc,%esp
  800c28:	50                   	push   %eax
  800c29:	6a 06                	push   $0x6
  800c2b:	68 28 13 80 00       	push   $0x801328
  800c30:	6a 23                	push   $0x23
  800c32:	68 45 13 80 00       	push   $0x801345
  800c37:	e8 85 01 00 00       	call   800dc1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c52:	b8 08 00 00 00       	mov    $0x8,%eax
  800c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	89 df                	mov    %ebx,%edi
  800c5f:	89 de                	mov    %ebx,%esi
  800c61:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c63:	85 c0                	test   %eax,%eax
  800c65:	7e 17                	jle    800c7e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	50                   	push   %eax
  800c6b:	6a 08                	push   $0x8
  800c6d:	68 28 13 80 00       	push   $0x801328
  800c72:	6a 23                	push   $0x23
  800c74:	68 45 13 80 00       	push   $0x801345
  800c79:	e8 43 01 00 00       	call   800dc1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c94:	b8 09 00 00 00       	mov    $0x9,%eax
  800c99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9f:	89 df                	mov    %ebx,%edi
  800ca1:	89 de                	mov    %ebx,%esi
  800ca3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	7e 17                	jle    800cc0 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca9:	83 ec 0c             	sub    $0xc,%esp
  800cac:	50                   	push   %eax
  800cad:	6a 09                	push   $0x9
  800caf:	68 28 13 80 00       	push   $0x801328
  800cb4:	6a 23                	push   $0x23
  800cb6:	68 45 13 80 00       	push   $0x801345
  800cbb:	e8 01 01 00 00       	call   800dc1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	be 00 00 00 00       	mov    $0x0,%esi
  800cd3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	57                   	push   %edi
  800cef:	56                   	push   %esi
  800cf0:	53                   	push   %ebx
  800cf1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	89 cb                	mov    %ecx,%ebx
  800d03:	89 cf                	mov    %ecx,%edi
  800d05:	89 ce                	mov    %ecx,%esi
  800d07:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	7e 17                	jle    800d24 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0d:	83 ec 0c             	sub    $0xc,%esp
  800d10:	50                   	push   %eax
  800d11:	6a 0c                	push   $0xc
  800d13:	68 28 13 80 00       	push   $0x801328
  800d18:	6a 23                	push   $0x23
  800d1a:	68 45 13 80 00       	push   $0x801345
  800d1f:	e8 9d 00 00 00       	call   800dc1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800d32:	68 5f 13 80 00       	push   $0x80135f
  800d37:	6a 51                	push   $0x51
  800d39:	68 53 13 80 00       	push   $0x801353
  800d3e:	e8 7e 00 00 00       	call   800dc1 <_panic>

00800d43 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d49:	68 5e 13 80 00       	push   $0x80135e
  800d4e:	6a 58                	push   $0x58
  800d50:	68 53 13 80 00       	push   $0x801353
  800d55:	e8 67 00 00 00       	call   800dc1 <_panic>

00800d5a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800d60:	68 74 13 80 00       	push   $0x801374
  800d65:	6a 1a                	push   $0x1a
  800d67:	68 8d 13 80 00       	push   $0x80138d
  800d6c:	e8 50 00 00 00       	call   800dc1 <_panic>

00800d71 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800d77:	68 97 13 80 00       	push   $0x801397
  800d7c:	6a 2a                	push   $0x2a
  800d7e:	68 8d 13 80 00       	push   $0x80138d
  800d83:	e8 39 00 00 00       	call   800dc1 <_panic>

00800d88 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800d8e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800d93:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800d96:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800d9c:	8b 52 50             	mov    0x50(%edx),%edx
  800d9f:	39 ca                	cmp    %ecx,%edx
  800da1:	75 0d                	jne    800db0 <ipc_find_env+0x28>
			return envs[i].env_id;
  800da3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800da6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800dab:	8b 40 48             	mov    0x48(%eax),%eax
  800dae:	eb 0f                	jmp    800dbf <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800db0:	83 c0 01             	add    $0x1,%eax
  800db3:	3d 00 04 00 00       	cmp    $0x400,%eax
  800db8:	75 d9                	jne    800d93 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800dba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dc6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dc9:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800dcf:	e8 6b fd ff ff       	call   800b3f <sys_getenvid>
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	ff 75 0c             	pushl  0xc(%ebp)
  800dda:	ff 75 08             	pushl  0x8(%ebp)
  800ddd:	56                   	push   %esi
  800dde:	50                   	push   %eax
  800ddf:	68 b0 13 80 00       	push   $0x8013b0
  800de4:	e8 ca f3 ff ff       	call   8001b3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800de9:	83 c4 18             	add    $0x18,%esp
  800dec:	53                   	push   %ebx
  800ded:	ff 75 10             	pushl  0x10(%ebp)
  800df0:	e8 6d f3 ff ff       	call   800162 <vcprintf>
	cprintf("\n");
  800df5:	c7 04 24 07 11 80 00 	movl   $0x801107,(%esp)
  800dfc:	e8 b2 f3 ff ff       	call   8001b3 <cprintf>
  800e01:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e04:	cc                   	int3   
  800e05:	eb fd                	jmp    800e04 <_panic+0x43>
  800e07:	66 90                	xchg   %ax,%ax
  800e09:	66 90                	xchg   %ax,%ax
  800e0b:	66 90                	xchg   %ax,%ax
  800e0d:	66 90                	xchg   %ax,%ax
  800e0f:	90                   	nop

00800e10 <__udivdi3>:
  800e10:	55                   	push   %ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 1c             	sub    $0x1c,%esp
  800e17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e27:	85 f6                	test   %esi,%esi
  800e29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e2d:	89 ca                	mov    %ecx,%edx
  800e2f:	89 f8                	mov    %edi,%eax
  800e31:	75 3d                	jne    800e70 <__udivdi3+0x60>
  800e33:	39 cf                	cmp    %ecx,%edi
  800e35:	0f 87 c5 00 00 00    	ja     800f00 <__udivdi3+0xf0>
  800e3b:	85 ff                	test   %edi,%edi
  800e3d:	89 fd                	mov    %edi,%ebp
  800e3f:	75 0b                	jne    800e4c <__udivdi3+0x3c>
  800e41:	b8 01 00 00 00       	mov    $0x1,%eax
  800e46:	31 d2                	xor    %edx,%edx
  800e48:	f7 f7                	div    %edi
  800e4a:	89 c5                	mov    %eax,%ebp
  800e4c:	89 c8                	mov    %ecx,%eax
  800e4e:	31 d2                	xor    %edx,%edx
  800e50:	f7 f5                	div    %ebp
  800e52:	89 c1                	mov    %eax,%ecx
  800e54:	89 d8                	mov    %ebx,%eax
  800e56:	89 cf                	mov    %ecx,%edi
  800e58:	f7 f5                	div    %ebp
  800e5a:	89 c3                	mov    %eax,%ebx
  800e5c:	89 d8                	mov    %ebx,%eax
  800e5e:	89 fa                	mov    %edi,%edx
  800e60:	83 c4 1c             	add    $0x1c,%esp
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    
  800e68:	90                   	nop
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	39 ce                	cmp    %ecx,%esi
  800e72:	77 74                	ja     800ee8 <__udivdi3+0xd8>
  800e74:	0f bd fe             	bsr    %esi,%edi
  800e77:	83 f7 1f             	xor    $0x1f,%edi
  800e7a:	0f 84 98 00 00 00    	je     800f18 <__udivdi3+0x108>
  800e80:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e85:	89 f9                	mov    %edi,%ecx
  800e87:	89 c5                	mov    %eax,%ebp
  800e89:	29 fb                	sub    %edi,%ebx
  800e8b:	d3 e6                	shl    %cl,%esi
  800e8d:	89 d9                	mov    %ebx,%ecx
  800e8f:	d3 ed                	shr    %cl,%ebp
  800e91:	89 f9                	mov    %edi,%ecx
  800e93:	d3 e0                	shl    %cl,%eax
  800e95:	09 ee                	or     %ebp,%esi
  800e97:	89 d9                	mov    %ebx,%ecx
  800e99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e9d:	89 d5                	mov    %edx,%ebp
  800e9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ea3:	d3 ed                	shr    %cl,%ebp
  800ea5:	89 f9                	mov    %edi,%ecx
  800ea7:	d3 e2                	shl    %cl,%edx
  800ea9:	89 d9                	mov    %ebx,%ecx
  800eab:	d3 e8                	shr    %cl,%eax
  800ead:	09 c2                	or     %eax,%edx
  800eaf:	89 d0                	mov    %edx,%eax
  800eb1:	89 ea                	mov    %ebp,%edx
  800eb3:	f7 f6                	div    %esi
  800eb5:	89 d5                	mov    %edx,%ebp
  800eb7:	89 c3                	mov    %eax,%ebx
  800eb9:	f7 64 24 0c          	mull   0xc(%esp)
  800ebd:	39 d5                	cmp    %edx,%ebp
  800ebf:	72 10                	jb     800ed1 <__udivdi3+0xc1>
  800ec1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ec5:	89 f9                	mov    %edi,%ecx
  800ec7:	d3 e6                	shl    %cl,%esi
  800ec9:	39 c6                	cmp    %eax,%esi
  800ecb:	73 07                	jae    800ed4 <__udivdi3+0xc4>
  800ecd:	39 d5                	cmp    %edx,%ebp
  800ecf:	75 03                	jne    800ed4 <__udivdi3+0xc4>
  800ed1:	83 eb 01             	sub    $0x1,%ebx
  800ed4:	31 ff                	xor    %edi,%edi
  800ed6:	89 d8                	mov    %ebx,%eax
  800ed8:	89 fa                	mov    %edi,%edx
  800eda:	83 c4 1c             	add    $0x1c,%esp
  800edd:	5b                   	pop    %ebx
  800ede:	5e                   	pop    %esi
  800edf:	5f                   	pop    %edi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    
  800ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ee8:	31 ff                	xor    %edi,%edi
  800eea:	31 db                	xor    %ebx,%ebx
  800eec:	89 d8                	mov    %ebx,%eax
  800eee:	89 fa                	mov    %edi,%edx
  800ef0:	83 c4 1c             	add    $0x1c,%esp
  800ef3:	5b                   	pop    %ebx
  800ef4:	5e                   	pop    %esi
  800ef5:	5f                   	pop    %edi
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    
  800ef8:	90                   	nop
  800ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f00:	89 d8                	mov    %ebx,%eax
  800f02:	f7 f7                	div    %edi
  800f04:	31 ff                	xor    %edi,%edi
  800f06:	89 c3                	mov    %eax,%ebx
  800f08:	89 d8                	mov    %ebx,%eax
  800f0a:	89 fa                	mov    %edi,%edx
  800f0c:	83 c4 1c             	add    $0x1c,%esp
  800f0f:	5b                   	pop    %ebx
  800f10:	5e                   	pop    %esi
  800f11:	5f                   	pop    %edi
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    
  800f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f18:	39 ce                	cmp    %ecx,%esi
  800f1a:	72 0c                	jb     800f28 <__udivdi3+0x118>
  800f1c:	31 db                	xor    %ebx,%ebx
  800f1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f22:	0f 87 34 ff ff ff    	ja     800e5c <__udivdi3+0x4c>
  800f28:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f2d:	e9 2a ff ff ff       	jmp    800e5c <__udivdi3+0x4c>
  800f32:	66 90                	xchg   %ax,%ax
  800f34:	66 90                	xchg   %ax,%ax
  800f36:	66 90                	xchg   %ax,%ax
  800f38:	66 90                	xchg   %ax,%ax
  800f3a:	66 90                	xchg   %ax,%ax
  800f3c:	66 90                	xchg   %ax,%ax
  800f3e:	66 90                	xchg   %ax,%ax

00800f40 <__umoddi3>:
  800f40:	55                   	push   %ebp
  800f41:	57                   	push   %edi
  800f42:	56                   	push   %esi
  800f43:	53                   	push   %ebx
  800f44:	83 ec 1c             	sub    $0x1c,%esp
  800f47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f57:	85 d2                	test   %edx,%edx
  800f59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f61:	89 f3                	mov    %esi,%ebx
  800f63:	89 3c 24             	mov    %edi,(%esp)
  800f66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f6a:	75 1c                	jne    800f88 <__umoddi3+0x48>
  800f6c:	39 f7                	cmp    %esi,%edi
  800f6e:	76 50                	jbe    800fc0 <__umoddi3+0x80>
  800f70:	89 c8                	mov    %ecx,%eax
  800f72:	89 f2                	mov    %esi,%edx
  800f74:	f7 f7                	div    %edi
  800f76:	89 d0                	mov    %edx,%eax
  800f78:	31 d2                	xor    %edx,%edx
  800f7a:	83 c4 1c             	add    $0x1c,%esp
  800f7d:	5b                   	pop    %ebx
  800f7e:	5e                   	pop    %esi
  800f7f:	5f                   	pop    %edi
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    
  800f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f88:	39 f2                	cmp    %esi,%edx
  800f8a:	89 d0                	mov    %edx,%eax
  800f8c:	77 52                	ja     800fe0 <__umoddi3+0xa0>
  800f8e:	0f bd ea             	bsr    %edx,%ebp
  800f91:	83 f5 1f             	xor    $0x1f,%ebp
  800f94:	75 5a                	jne    800ff0 <__umoddi3+0xb0>
  800f96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f9a:	0f 82 e0 00 00 00    	jb     801080 <__umoddi3+0x140>
  800fa0:	39 0c 24             	cmp    %ecx,(%esp)
  800fa3:	0f 86 d7 00 00 00    	jbe    801080 <__umoddi3+0x140>
  800fa9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fad:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fb1:	83 c4 1c             	add    $0x1c,%esp
  800fb4:	5b                   	pop    %ebx
  800fb5:	5e                   	pop    %esi
  800fb6:	5f                   	pop    %edi
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    
  800fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	85 ff                	test   %edi,%edi
  800fc2:	89 fd                	mov    %edi,%ebp
  800fc4:	75 0b                	jne    800fd1 <__umoddi3+0x91>
  800fc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fcb:	31 d2                	xor    %edx,%edx
  800fcd:	f7 f7                	div    %edi
  800fcf:	89 c5                	mov    %eax,%ebp
  800fd1:	89 f0                	mov    %esi,%eax
  800fd3:	31 d2                	xor    %edx,%edx
  800fd5:	f7 f5                	div    %ebp
  800fd7:	89 c8                	mov    %ecx,%eax
  800fd9:	f7 f5                	div    %ebp
  800fdb:	89 d0                	mov    %edx,%eax
  800fdd:	eb 99                	jmp    800f78 <__umoddi3+0x38>
  800fdf:	90                   	nop
  800fe0:	89 c8                	mov    %ecx,%eax
  800fe2:	89 f2                	mov    %esi,%edx
  800fe4:	83 c4 1c             	add    $0x1c,%esp
  800fe7:	5b                   	pop    %ebx
  800fe8:	5e                   	pop    %esi
  800fe9:	5f                   	pop    %edi
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    
  800fec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ff0:	8b 34 24             	mov    (%esp),%esi
  800ff3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ff8:	89 e9                	mov    %ebp,%ecx
  800ffa:	29 ef                	sub    %ebp,%edi
  800ffc:	d3 e0                	shl    %cl,%eax
  800ffe:	89 f9                	mov    %edi,%ecx
  801000:	89 f2                	mov    %esi,%edx
  801002:	d3 ea                	shr    %cl,%edx
  801004:	89 e9                	mov    %ebp,%ecx
  801006:	09 c2                	or     %eax,%edx
  801008:	89 d8                	mov    %ebx,%eax
  80100a:	89 14 24             	mov    %edx,(%esp)
  80100d:	89 f2                	mov    %esi,%edx
  80100f:	d3 e2                	shl    %cl,%edx
  801011:	89 f9                	mov    %edi,%ecx
  801013:	89 54 24 04          	mov    %edx,0x4(%esp)
  801017:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80101b:	d3 e8                	shr    %cl,%eax
  80101d:	89 e9                	mov    %ebp,%ecx
  80101f:	89 c6                	mov    %eax,%esi
  801021:	d3 e3                	shl    %cl,%ebx
  801023:	89 f9                	mov    %edi,%ecx
  801025:	89 d0                	mov    %edx,%eax
  801027:	d3 e8                	shr    %cl,%eax
  801029:	89 e9                	mov    %ebp,%ecx
  80102b:	09 d8                	or     %ebx,%eax
  80102d:	89 d3                	mov    %edx,%ebx
  80102f:	89 f2                	mov    %esi,%edx
  801031:	f7 34 24             	divl   (%esp)
  801034:	89 d6                	mov    %edx,%esi
  801036:	d3 e3                	shl    %cl,%ebx
  801038:	f7 64 24 04          	mull   0x4(%esp)
  80103c:	39 d6                	cmp    %edx,%esi
  80103e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801042:	89 d1                	mov    %edx,%ecx
  801044:	89 c3                	mov    %eax,%ebx
  801046:	72 08                	jb     801050 <__umoddi3+0x110>
  801048:	75 11                	jne    80105b <__umoddi3+0x11b>
  80104a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80104e:	73 0b                	jae    80105b <__umoddi3+0x11b>
  801050:	2b 44 24 04          	sub    0x4(%esp),%eax
  801054:	1b 14 24             	sbb    (%esp),%edx
  801057:	89 d1                	mov    %edx,%ecx
  801059:	89 c3                	mov    %eax,%ebx
  80105b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80105f:	29 da                	sub    %ebx,%edx
  801061:	19 ce                	sbb    %ecx,%esi
  801063:	89 f9                	mov    %edi,%ecx
  801065:	89 f0                	mov    %esi,%eax
  801067:	d3 e0                	shl    %cl,%eax
  801069:	89 e9                	mov    %ebp,%ecx
  80106b:	d3 ea                	shr    %cl,%edx
  80106d:	89 e9                	mov    %ebp,%ecx
  80106f:	d3 ee                	shr    %cl,%esi
  801071:	09 d0                	or     %edx,%eax
  801073:	89 f2                	mov    %esi,%edx
  801075:	83 c4 1c             	add    $0x1c,%esp
  801078:	5b                   	pop    %ebx
  801079:	5e                   	pop    %esi
  80107a:	5f                   	pop    %edi
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    
  80107d:	8d 76 00             	lea    0x0(%esi),%esi
  801080:	29 f9                	sub    %edi,%ecx
  801082:	19 d6                	sbb    %edx,%esi
  801084:	89 74 24 04          	mov    %esi,0x4(%esp)
  801088:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80108c:	e9 18 ff ff ff       	jmp    800fa9 <__umoddi3+0x69>
