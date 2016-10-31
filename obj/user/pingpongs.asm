
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 42 0d 00 00       	call   800d83 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004e:	e8 2c 0b 00 00       	call   800b7f <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 e0 10 80 00       	push   $0x8010e0
  80005d:	e8 91 01 00 00       	call   8001f3 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 15 0b 00 00       	call   800b7f <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 fa 10 80 00       	push   $0x8010fa
  800074:	e8 7a 01 00 00       	call   8001f3 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 2a 0d 00 00       	call   800db1 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 00 0d 00 00       	call   800d9a <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 20 80 00       	mov    0x802004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 cc 0a 00 00       	call   800b7f <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 10 11 80 00       	push   $0x801110
  8000c2:	e8 2c 01 00 00       	call   8001f3 <cprintf>
		if (val == 10)
  8000c7:	a1 04 20 80 00       	mov    0x802004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 c7 0c 00 00       	call   800db1 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800109:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800110:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  800113:	e8 67 0a 00 00       	call   800b7f <sys_getenvid>
  800118:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800120:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800125:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012a:	85 db                	test   %ebx,%ebx
  80012c:	7e 07                	jle    800135 <libmain+0x37>
		binaryname = argv[0];
  80012e:	8b 06                	mov    (%esi),%eax
  800130:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800135:	83 ec 08             	sub    $0x8,%esp
  800138:	56                   	push   %esi
  800139:	53                   	push   %ebx
  80013a:	e8 f4 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013f:	e8 0a 00 00 00       	call   80014e <exit>
}
  800144:	83 c4 10             	add    $0x10,%esp
  800147:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80014a:	5b                   	pop    %ebx
  80014b:	5e                   	pop    %esi
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800154:	6a 00                	push   $0x0
  800156:	e8 e3 09 00 00       	call   800b3e <sys_env_destroy>
}
  80015b:	83 c4 10             	add    $0x10,%esp
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	53                   	push   %ebx
  800164:	83 ec 04             	sub    $0x4,%esp
  800167:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016a:	8b 13                	mov    (%ebx),%edx
  80016c:	8d 42 01             	lea    0x1(%edx),%eax
  80016f:	89 03                	mov    %eax,(%ebx)
  800171:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800174:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800178:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017d:	75 1a                	jne    800199 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017f:	83 ec 08             	sub    $0x8,%esp
  800182:	68 ff 00 00 00       	push   $0xff
  800187:	8d 43 08             	lea    0x8(%ebx),%eax
  80018a:	50                   	push   %eax
  80018b:	e8 71 09 00 00       	call   800b01 <sys_cputs>
		b->idx = 0;
  800190:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800196:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800199:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    

008001a2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ab:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b2:	00 00 00 
	b.cnt = 0;
  8001b5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bf:	ff 75 0c             	pushl  0xc(%ebp)
  8001c2:	ff 75 08             	pushl  0x8(%ebp)
  8001c5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cb:	50                   	push   %eax
  8001cc:	68 60 01 80 00       	push   $0x800160
  8001d1:	e8 54 01 00 00       	call   80032a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d6:	83 c4 08             	add    $0x8,%esp
  8001d9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001df:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e5:	50                   	push   %eax
  8001e6:	e8 16 09 00 00       	call   800b01 <sys_cputs>

	return b.cnt;
}
  8001eb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f1:	c9                   	leave  
  8001f2:	c3                   	ret    

008001f3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f3:	55                   	push   %ebp
  8001f4:	89 e5                	mov    %esp,%ebp
  8001f6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fc:	50                   	push   %eax
  8001fd:	ff 75 08             	pushl  0x8(%ebp)
  800200:	e8 9d ff ff ff       	call   8001a2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800205:	c9                   	leave  
  800206:	c3                   	ret    

00800207 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	57                   	push   %edi
  80020b:	56                   	push   %esi
  80020c:	53                   	push   %ebx
  80020d:	83 ec 1c             	sub    $0x1c,%esp
  800210:	89 c7                	mov    %eax,%edi
  800212:	89 d6                	mov    %edx,%esi
  800214:	8b 45 08             	mov    0x8(%ebp),%eax
  800217:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800220:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800223:	bb 00 00 00 00       	mov    $0x0,%ebx
  800228:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80022b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022e:	39 d3                	cmp    %edx,%ebx
  800230:	72 05                	jb     800237 <printnum+0x30>
  800232:	39 45 10             	cmp    %eax,0x10(%ebp)
  800235:	77 45                	ja     80027c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800237:	83 ec 0c             	sub    $0xc,%esp
  80023a:	ff 75 18             	pushl  0x18(%ebp)
  80023d:	8b 45 14             	mov    0x14(%ebp),%eax
  800240:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024d:	ff 75 e0             	pushl  -0x20(%ebp)
  800250:	ff 75 dc             	pushl  -0x24(%ebp)
  800253:	ff 75 d8             	pushl  -0x28(%ebp)
  800256:	e8 f5 0b 00 00       	call   800e50 <__udivdi3>
  80025b:	83 c4 18             	add    $0x18,%esp
  80025e:	52                   	push   %edx
  80025f:	50                   	push   %eax
  800260:	89 f2                	mov    %esi,%edx
  800262:	89 f8                	mov    %edi,%eax
  800264:	e8 9e ff ff ff       	call   800207 <printnum>
  800269:	83 c4 20             	add    $0x20,%esp
  80026c:	eb 18                	jmp    800286 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026e:	83 ec 08             	sub    $0x8,%esp
  800271:	56                   	push   %esi
  800272:	ff 75 18             	pushl  0x18(%ebp)
  800275:	ff d7                	call   *%edi
  800277:	83 c4 10             	add    $0x10,%esp
  80027a:	eb 03                	jmp    80027f <printnum+0x78>
  80027c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027f:	83 eb 01             	sub    $0x1,%ebx
  800282:	85 db                	test   %ebx,%ebx
  800284:	7f e8                	jg     80026e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800286:	83 ec 08             	sub    $0x8,%esp
  800289:	56                   	push   %esi
  80028a:	83 ec 04             	sub    $0x4,%esp
  80028d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800290:	ff 75 e0             	pushl  -0x20(%ebp)
  800293:	ff 75 dc             	pushl  -0x24(%ebp)
  800296:	ff 75 d8             	pushl  -0x28(%ebp)
  800299:	e8 e2 0c 00 00       	call   800f80 <__umoddi3>
  80029e:	83 c4 14             	add    $0x14,%esp
  8002a1:	0f be 80 40 11 80 00 	movsbl 0x801140(%eax),%eax
  8002a8:	50                   	push   %eax
  8002a9:	ff d7                	call   *%edi
}
  8002ab:	83 c4 10             	add    $0x10,%esp
  8002ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b1:	5b                   	pop    %ebx
  8002b2:	5e                   	pop    %esi
  8002b3:	5f                   	pop    %edi
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b9:	83 fa 01             	cmp    $0x1,%edx
  8002bc:	7e 0e                	jle    8002cc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002be:	8b 10                	mov    (%eax),%edx
  8002c0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c3:	89 08                	mov    %ecx,(%eax)
  8002c5:	8b 02                	mov    (%edx),%eax
  8002c7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ca:	eb 22                	jmp    8002ee <getuint+0x38>
	else if (lflag)
  8002cc:	85 d2                	test   %edx,%edx
  8002ce:	74 10                	je     8002e0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 02                	mov    (%edx),%eax
  8002d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002de:	eb 0e                	jmp    8002ee <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fa:	8b 10                	mov    (%eax),%edx
  8002fc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ff:	73 0a                	jae    80030b <sprintputch+0x1b>
		*b->buf++ = ch;
  800301:	8d 4a 01             	lea    0x1(%edx),%ecx
  800304:	89 08                	mov    %ecx,(%eax)
  800306:	8b 45 08             	mov    0x8(%ebp),%eax
  800309:	88 02                	mov    %al,(%edx)
}
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800313:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800316:	50                   	push   %eax
  800317:	ff 75 10             	pushl  0x10(%ebp)
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	ff 75 08             	pushl  0x8(%ebp)
  800320:	e8 05 00 00 00       	call   80032a <vprintfmt>
	va_end(ap);
}
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	c9                   	leave  
  800329:	c3                   	ret    

0080032a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	57                   	push   %edi
  80032e:	56                   	push   %esi
  80032f:	53                   	push   %ebx
  800330:	83 ec 2c             	sub    $0x2c,%esp
  800333:	8b 75 08             	mov    0x8(%ebp),%esi
  800336:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800339:	8b 7d 10             	mov    0x10(%ebp),%edi
  80033c:	eb 12                	jmp    800350 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80033e:	85 c0                	test   %eax,%eax
  800340:	0f 84 cb 03 00 00    	je     800711 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800346:	83 ec 08             	sub    $0x8,%esp
  800349:	53                   	push   %ebx
  80034a:	50                   	push   %eax
  80034b:	ff d6                	call   *%esi
  80034d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800350:	83 c7 01             	add    $0x1,%edi
  800353:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800357:	83 f8 25             	cmp    $0x25,%eax
  80035a:	75 e2                	jne    80033e <vprintfmt+0x14>
  80035c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800360:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800367:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80036e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800375:	ba 00 00 00 00       	mov    $0x0,%edx
  80037a:	eb 07                	jmp    800383 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8d 47 01             	lea    0x1(%edi),%eax
  800386:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800389:	0f b6 07             	movzbl (%edi),%eax
  80038c:	0f b6 c8             	movzbl %al,%ecx
  80038f:	83 e8 23             	sub    $0x23,%eax
  800392:	3c 55                	cmp    $0x55,%al
  800394:	0f 87 5c 03 00 00    	ja     8006f6 <vprintfmt+0x3cc>
  80039a:	0f b6 c0             	movzbl %al,%eax
  80039d:	ff 24 85 20 12 80 00 	jmp    *0x801220(,%eax,4)
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003ab:	eb d6                	jmp    800383 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003bb:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003bf:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c5:	83 fa 09             	cmp    $0x9,%edx
  8003c8:	77 39                	ja     800403 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ca:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003cd:	eb e9                	jmp    8003b8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d2:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d8:	8b 00                	mov    (%eax),%eax
  8003da:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e0:	eb 27                	jmp    800409 <vprintfmt+0xdf>
  8003e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e5:	85 c0                	test   %eax,%eax
  8003e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ec:	0f 49 c8             	cmovns %eax,%ecx
  8003ef:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f5:	eb 8c                	jmp    800383 <vprintfmt+0x59>
  8003f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003fa:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800401:	eb 80                	jmp    800383 <vprintfmt+0x59>
  800403:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800406:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800409:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040d:	0f 89 70 ff ff ff    	jns    800383 <vprintfmt+0x59>
				width = precision, precision = -1;
  800413:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800416:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800419:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800420:	e9 5e ff ff ff       	jmp    800383 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800425:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042b:	e9 53 ff ff ff       	jmp    800383 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 50 04             	lea    0x4(%eax),%edx
  800436:	89 55 14             	mov    %edx,0x14(%ebp)
  800439:	83 ec 08             	sub    $0x8,%esp
  80043c:	53                   	push   %ebx
  80043d:	ff 30                	pushl  (%eax)
  80043f:	ff d6                	call   *%esi
			break;
  800441:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800447:	e9 04 ff ff ff       	jmp    800350 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044c:	8b 45 14             	mov    0x14(%ebp),%eax
  80044f:	8d 50 04             	lea    0x4(%eax),%edx
  800452:	89 55 14             	mov    %edx,0x14(%ebp)
  800455:	8b 00                	mov    (%eax),%eax
  800457:	99                   	cltd   
  800458:	31 d0                	xor    %edx,%eax
  80045a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045c:	83 f8 09             	cmp    $0x9,%eax
  80045f:	7f 0b                	jg     80046c <vprintfmt+0x142>
  800461:	8b 14 85 80 13 80 00 	mov    0x801380(,%eax,4),%edx
  800468:	85 d2                	test   %edx,%edx
  80046a:	75 18                	jne    800484 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80046c:	50                   	push   %eax
  80046d:	68 58 11 80 00       	push   $0x801158
  800472:	53                   	push   %ebx
  800473:	56                   	push   %esi
  800474:	e8 94 fe ff ff       	call   80030d <printfmt>
  800479:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047f:	e9 cc fe ff ff       	jmp    800350 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800484:	52                   	push   %edx
  800485:	68 61 11 80 00       	push   $0x801161
  80048a:	53                   	push   %ebx
  80048b:	56                   	push   %esi
  80048c:	e8 7c fe ff ff       	call   80030d <printfmt>
  800491:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800497:	e9 b4 fe ff ff       	jmp    800350 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049c:	8b 45 14             	mov    0x14(%ebp),%eax
  80049f:	8d 50 04             	lea    0x4(%eax),%edx
  8004a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a7:	85 ff                	test   %edi,%edi
  8004a9:	b8 51 11 80 00       	mov    $0x801151,%eax
  8004ae:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b5:	0f 8e 94 00 00 00    	jle    80054f <vprintfmt+0x225>
  8004bb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004bf:	0f 84 98 00 00 00    	je     80055d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	ff 75 c8             	pushl  -0x38(%ebp)
  8004cb:	57                   	push   %edi
  8004cc:	e8 c8 02 00 00       	call   800799 <strnlen>
  8004d1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d4:	29 c1                	sub    %eax,%ecx
  8004d6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004d9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004dc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e8:	eb 0f                	jmp    8004f9 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	53                   	push   %ebx
  8004ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f3:	83 ef 01             	sub    $0x1,%edi
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	85 ff                	test   %edi,%edi
  8004fb:	7f ed                	jg     8004ea <vprintfmt+0x1c0>
  8004fd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800500:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800503:	85 c9                	test   %ecx,%ecx
  800505:	b8 00 00 00 00       	mov    $0x0,%eax
  80050a:	0f 49 c1             	cmovns %ecx,%eax
  80050d:	29 c1                	sub    %eax,%ecx
  80050f:	89 75 08             	mov    %esi,0x8(%ebp)
  800512:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800515:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800518:	89 cb                	mov    %ecx,%ebx
  80051a:	eb 4d                	jmp    800569 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800520:	74 1b                	je     80053d <vprintfmt+0x213>
  800522:	0f be c0             	movsbl %al,%eax
  800525:	83 e8 20             	sub    $0x20,%eax
  800528:	83 f8 5e             	cmp    $0x5e,%eax
  80052b:	76 10                	jbe    80053d <vprintfmt+0x213>
					putch('?', putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	ff 75 0c             	pushl  0xc(%ebp)
  800533:	6a 3f                	push   $0x3f
  800535:	ff 55 08             	call   *0x8(%ebp)
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	eb 0d                	jmp    80054a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	ff 75 0c             	pushl  0xc(%ebp)
  800543:	52                   	push   %edx
  800544:	ff 55 08             	call   *0x8(%ebp)
  800547:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054a:	83 eb 01             	sub    $0x1,%ebx
  80054d:	eb 1a                	jmp    800569 <vprintfmt+0x23f>
  80054f:	89 75 08             	mov    %esi,0x8(%ebp)
  800552:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800555:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800558:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055b:	eb 0c                	jmp    800569 <vprintfmt+0x23f>
  80055d:	89 75 08             	mov    %esi,0x8(%ebp)
  800560:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800563:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800566:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800569:	83 c7 01             	add    $0x1,%edi
  80056c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800570:	0f be d0             	movsbl %al,%edx
  800573:	85 d2                	test   %edx,%edx
  800575:	74 23                	je     80059a <vprintfmt+0x270>
  800577:	85 f6                	test   %esi,%esi
  800579:	78 a1                	js     80051c <vprintfmt+0x1f2>
  80057b:	83 ee 01             	sub    $0x1,%esi
  80057e:	79 9c                	jns    80051c <vprintfmt+0x1f2>
  800580:	89 df                	mov    %ebx,%edi
  800582:	8b 75 08             	mov    0x8(%ebp),%esi
  800585:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800588:	eb 18                	jmp    8005a2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058a:	83 ec 08             	sub    $0x8,%esp
  80058d:	53                   	push   %ebx
  80058e:	6a 20                	push   $0x20
  800590:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800592:	83 ef 01             	sub    $0x1,%edi
  800595:	83 c4 10             	add    $0x10,%esp
  800598:	eb 08                	jmp    8005a2 <vprintfmt+0x278>
  80059a:	89 df                	mov    %ebx,%edi
  80059c:	8b 75 08             	mov    0x8(%ebp),%esi
  80059f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a2:	85 ff                	test   %edi,%edi
  8005a4:	7f e4                	jg     80058a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a9:	e9 a2 fd ff ff       	jmp    800350 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ae:	83 fa 01             	cmp    $0x1,%edx
  8005b1:	7e 16                	jle    8005c9 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8d 50 08             	lea    0x8(%eax),%edx
  8005b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bc:	8b 50 04             	mov    0x4(%eax),%edx
  8005bf:	8b 00                	mov    (%eax),%eax
  8005c1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005c4:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005c7:	eb 32                	jmp    8005fb <vprintfmt+0x2d1>
	else if (lflag)
  8005c9:	85 d2                	test   %edx,%edx
  8005cb:	74 18                	je     8005e5 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8d 50 04             	lea    0x4(%eax),%edx
  8005d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005db:	89 c1                	mov    %eax,%ecx
  8005dd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005e3:	eb 16                	jmp    8005fb <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8d 50 04             	lea    0x4(%eax),%edx
  8005eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ee:	8b 00                	mov    (%eax),%eax
  8005f0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005f3:	89 c1                	mov    %eax,%ecx
  8005f5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005fb:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005fe:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800601:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800604:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800607:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80060c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800610:	0f 89 a8 00 00 00    	jns    8006be <vprintfmt+0x394>
				putch('-', putdat);
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	53                   	push   %ebx
  80061a:	6a 2d                	push   $0x2d
  80061c:	ff d6                	call   *%esi
				num = -(long long) num;
  80061e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800621:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800624:	f7 d8                	neg    %eax
  800626:	83 d2 00             	adc    $0x0,%edx
  800629:	f7 da                	neg    %edx
  80062b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800631:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800634:	b8 0a 00 00 00       	mov    $0xa,%eax
  800639:	e9 80 00 00 00       	jmp    8006be <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063e:	8d 45 14             	lea    0x14(%ebp),%eax
  800641:	e8 70 fc ff ff       	call   8002b6 <getuint>
  800646:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800649:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80064c:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800651:	eb 6b                	jmp    8006be <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	e8 5b fc ff ff       	call   8002b6 <getuint>
  80065b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800661:	6a 04                	push   $0x4
  800663:	6a 03                	push   $0x3
  800665:	6a 01                	push   $0x1
  800667:	68 64 11 80 00       	push   $0x801164
  80066c:	e8 82 fb ff ff       	call   8001f3 <cprintf>
			goto number;
  800671:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  800674:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  800679:	eb 43                	jmp    8006be <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  80067b:	83 ec 08             	sub    $0x8,%esp
  80067e:	53                   	push   %ebx
  80067f:	6a 30                	push   $0x30
  800681:	ff d6                	call   *%esi
			putch('x', putdat);
  800683:	83 c4 08             	add    $0x8,%esp
  800686:	53                   	push   %ebx
  800687:	6a 78                	push   $0x78
  800689:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8d 50 04             	lea    0x4(%eax),%edx
  800691:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800694:	8b 00                	mov    (%eax),%eax
  800696:	ba 00 00 00 00       	mov    $0x0,%edx
  80069b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069e:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a4:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006a9:	eb 13                	jmp    8006be <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ae:	e8 03 fc ff ff       	call   8002b6 <getuint>
  8006b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006b9:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006c5:	52                   	push   %edx
  8006c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c9:	50                   	push   %eax
  8006ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8006cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8006d0:	89 da                	mov    %ebx,%edx
  8006d2:	89 f0                	mov    %esi,%eax
  8006d4:	e8 2e fb ff ff       	call   800207 <printnum>

			break;
  8006d9:	83 c4 20             	add    $0x20,%esp
  8006dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006df:	e9 6c fc ff ff       	jmp    800350 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e4:	83 ec 08             	sub    $0x8,%esp
  8006e7:	53                   	push   %ebx
  8006e8:	51                   	push   %ecx
  8006e9:	ff d6                	call   *%esi
			break;
  8006eb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f1:	e9 5a fc ff ff       	jmp    800350 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	53                   	push   %ebx
  8006fa:	6a 25                	push   $0x25
  8006fc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	eb 03                	jmp    800706 <vprintfmt+0x3dc>
  800703:	83 ef 01             	sub    $0x1,%edi
  800706:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80070a:	75 f7                	jne    800703 <vprintfmt+0x3d9>
  80070c:	e9 3f fc ff ff       	jmp    800350 <vprintfmt+0x26>
			break;
		}

	}

}
  800711:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800714:	5b                   	pop    %ebx
  800715:	5e                   	pop    %esi
  800716:	5f                   	pop    %edi
  800717:	5d                   	pop    %ebp
  800718:	c3                   	ret    

00800719 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	83 ec 18             	sub    $0x18,%esp
  80071f:	8b 45 08             	mov    0x8(%ebp),%eax
  800722:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800725:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800728:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800736:	85 c0                	test   %eax,%eax
  800738:	74 26                	je     800760 <vsnprintf+0x47>
  80073a:	85 d2                	test   %edx,%edx
  80073c:	7e 22                	jle    800760 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073e:	ff 75 14             	pushl  0x14(%ebp)
  800741:	ff 75 10             	pushl  0x10(%ebp)
  800744:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800747:	50                   	push   %eax
  800748:	68 f0 02 80 00       	push   $0x8002f0
  80074d:	e8 d8 fb ff ff       	call   80032a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800752:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800755:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800758:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075b:	83 c4 10             	add    $0x10,%esp
  80075e:	eb 05                	jmp    800765 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800760:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800765:	c9                   	leave  
  800766:	c3                   	ret    

00800767 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800770:	50                   	push   %eax
  800771:	ff 75 10             	pushl  0x10(%ebp)
  800774:	ff 75 0c             	pushl  0xc(%ebp)
  800777:	ff 75 08             	pushl  0x8(%ebp)
  80077a:	e8 9a ff ff ff       	call   800719 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077f:	c9                   	leave  
  800780:	c3                   	ret    

00800781 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800787:	b8 00 00 00 00       	mov    $0x0,%eax
  80078c:	eb 03                	jmp    800791 <strlen+0x10>
		n++;
  80078e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800791:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800795:	75 f7                	jne    80078e <strlen+0xd>
		n++;
	return n;
}
  800797:	5d                   	pop    %ebp
  800798:	c3                   	ret    

00800799 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a7:	eb 03                	jmp    8007ac <strnlen+0x13>
		n++;
  8007a9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ac:	39 c2                	cmp    %eax,%edx
  8007ae:	74 08                	je     8007b8 <strnlen+0x1f>
  8007b0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b4:	75 f3                	jne    8007a9 <strnlen+0x10>
  8007b6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c4:	89 c2                	mov    %eax,%edx
  8007c6:	83 c2 01             	add    $0x1,%edx
  8007c9:	83 c1 01             	add    $0x1,%ecx
  8007cc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d3:	84 db                	test   %bl,%bl
  8007d5:	75 ef                	jne    8007c6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d7:	5b                   	pop    %ebx
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	53                   	push   %ebx
  8007de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e1:	53                   	push   %ebx
  8007e2:	e8 9a ff ff ff       	call   800781 <strlen>
  8007e7:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ea:	ff 75 0c             	pushl  0xc(%ebp)
  8007ed:	01 d8                	add    %ebx,%eax
  8007ef:	50                   	push   %eax
  8007f0:	e8 c5 ff ff ff       	call   8007ba <strcpy>
	return dst;
}
  8007f5:	89 d8                	mov    %ebx,%eax
  8007f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	56                   	push   %esi
  800800:	53                   	push   %ebx
  800801:	8b 75 08             	mov    0x8(%ebp),%esi
  800804:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800807:	89 f3                	mov    %esi,%ebx
  800809:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080c:	89 f2                	mov    %esi,%edx
  80080e:	eb 0f                	jmp    80081f <strncpy+0x23>
		*dst++ = *src;
  800810:	83 c2 01             	add    $0x1,%edx
  800813:	0f b6 01             	movzbl (%ecx),%eax
  800816:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800819:	80 39 01             	cmpb   $0x1,(%ecx)
  80081c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081f:	39 da                	cmp    %ebx,%edx
  800821:	75 ed                	jne    800810 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800823:	89 f0                	mov    %esi,%eax
  800825:	5b                   	pop    %ebx
  800826:	5e                   	pop    %esi
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	56                   	push   %esi
  80082d:	53                   	push   %ebx
  80082e:	8b 75 08             	mov    0x8(%ebp),%esi
  800831:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800834:	8b 55 10             	mov    0x10(%ebp),%edx
  800837:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800839:	85 d2                	test   %edx,%edx
  80083b:	74 21                	je     80085e <strlcpy+0x35>
  80083d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800841:	89 f2                	mov    %esi,%edx
  800843:	eb 09                	jmp    80084e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800845:	83 c2 01             	add    $0x1,%edx
  800848:	83 c1 01             	add    $0x1,%ecx
  80084b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084e:	39 c2                	cmp    %eax,%edx
  800850:	74 09                	je     80085b <strlcpy+0x32>
  800852:	0f b6 19             	movzbl (%ecx),%ebx
  800855:	84 db                	test   %bl,%bl
  800857:	75 ec                	jne    800845 <strlcpy+0x1c>
  800859:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80085b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085e:	29 f0                	sub    %esi,%eax
}
  800860:	5b                   	pop    %ebx
  800861:	5e                   	pop    %esi
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086d:	eb 06                	jmp    800875 <strcmp+0x11>
		p++, q++;
  80086f:	83 c1 01             	add    $0x1,%ecx
  800872:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800875:	0f b6 01             	movzbl (%ecx),%eax
  800878:	84 c0                	test   %al,%al
  80087a:	74 04                	je     800880 <strcmp+0x1c>
  80087c:	3a 02                	cmp    (%edx),%al
  80087e:	74 ef                	je     80086f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800880:	0f b6 c0             	movzbl %al,%eax
  800883:	0f b6 12             	movzbl (%edx),%edx
  800886:	29 d0                	sub    %edx,%eax
}
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	53                   	push   %ebx
  80088e:	8b 45 08             	mov    0x8(%ebp),%eax
  800891:	8b 55 0c             	mov    0xc(%ebp),%edx
  800894:	89 c3                	mov    %eax,%ebx
  800896:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800899:	eb 06                	jmp    8008a1 <strncmp+0x17>
		n--, p++, q++;
  80089b:	83 c0 01             	add    $0x1,%eax
  80089e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a1:	39 d8                	cmp    %ebx,%eax
  8008a3:	74 15                	je     8008ba <strncmp+0x30>
  8008a5:	0f b6 08             	movzbl (%eax),%ecx
  8008a8:	84 c9                	test   %cl,%cl
  8008aa:	74 04                	je     8008b0 <strncmp+0x26>
  8008ac:	3a 0a                	cmp    (%edx),%cl
  8008ae:	74 eb                	je     80089b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b0:	0f b6 00             	movzbl (%eax),%eax
  8008b3:	0f b6 12             	movzbl (%edx),%edx
  8008b6:	29 d0                	sub    %edx,%eax
  8008b8:	eb 05                	jmp    8008bf <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ba:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bf:	5b                   	pop    %ebx
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cc:	eb 07                	jmp    8008d5 <strchr+0x13>
		if (*s == c)
  8008ce:	38 ca                	cmp    %cl,%dl
  8008d0:	74 0f                	je     8008e1 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d2:	83 c0 01             	add    $0x1,%eax
  8008d5:	0f b6 10             	movzbl (%eax),%edx
  8008d8:	84 d2                	test   %dl,%dl
  8008da:	75 f2                	jne    8008ce <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ed:	eb 03                	jmp    8008f2 <strfind+0xf>
  8008ef:	83 c0 01             	add    $0x1,%eax
  8008f2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f5:	38 ca                	cmp    %cl,%dl
  8008f7:	74 04                	je     8008fd <strfind+0x1a>
  8008f9:	84 d2                	test   %dl,%dl
  8008fb:	75 f2                	jne    8008ef <strfind+0xc>
			break;
	return (char *) s;
}
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	57                   	push   %edi
  800903:	56                   	push   %esi
  800904:	53                   	push   %ebx
  800905:	8b 7d 08             	mov    0x8(%ebp),%edi
  800908:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090b:	85 c9                	test   %ecx,%ecx
  80090d:	74 36                	je     800945 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800915:	75 28                	jne    80093f <memset+0x40>
  800917:	f6 c1 03             	test   $0x3,%cl
  80091a:	75 23                	jne    80093f <memset+0x40>
		c &= 0xFF;
  80091c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800920:	89 d3                	mov    %edx,%ebx
  800922:	c1 e3 08             	shl    $0x8,%ebx
  800925:	89 d6                	mov    %edx,%esi
  800927:	c1 e6 18             	shl    $0x18,%esi
  80092a:	89 d0                	mov    %edx,%eax
  80092c:	c1 e0 10             	shl    $0x10,%eax
  80092f:	09 f0                	or     %esi,%eax
  800931:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800933:	89 d8                	mov    %ebx,%eax
  800935:	09 d0                	or     %edx,%eax
  800937:	c1 e9 02             	shr    $0x2,%ecx
  80093a:	fc                   	cld    
  80093b:	f3 ab                	rep stos %eax,%es:(%edi)
  80093d:	eb 06                	jmp    800945 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800942:	fc                   	cld    
  800943:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800945:	89 f8                	mov    %edi,%eax
  800947:	5b                   	pop    %ebx
  800948:	5e                   	pop    %esi
  800949:	5f                   	pop    %edi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	57                   	push   %edi
  800950:	56                   	push   %esi
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	8b 75 0c             	mov    0xc(%ebp),%esi
  800957:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095a:	39 c6                	cmp    %eax,%esi
  80095c:	73 35                	jae    800993 <memmove+0x47>
  80095e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800961:	39 d0                	cmp    %edx,%eax
  800963:	73 2e                	jae    800993 <memmove+0x47>
		s += n;
		d += n;
  800965:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800968:	89 d6                	mov    %edx,%esi
  80096a:	09 fe                	or     %edi,%esi
  80096c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800972:	75 13                	jne    800987 <memmove+0x3b>
  800974:	f6 c1 03             	test   $0x3,%cl
  800977:	75 0e                	jne    800987 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800979:	83 ef 04             	sub    $0x4,%edi
  80097c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097f:	c1 e9 02             	shr    $0x2,%ecx
  800982:	fd                   	std    
  800983:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800985:	eb 09                	jmp    800990 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800987:	83 ef 01             	sub    $0x1,%edi
  80098a:	8d 72 ff             	lea    -0x1(%edx),%esi
  80098d:	fd                   	std    
  80098e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800990:	fc                   	cld    
  800991:	eb 1d                	jmp    8009b0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800993:	89 f2                	mov    %esi,%edx
  800995:	09 c2                	or     %eax,%edx
  800997:	f6 c2 03             	test   $0x3,%dl
  80099a:	75 0f                	jne    8009ab <memmove+0x5f>
  80099c:	f6 c1 03             	test   $0x3,%cl
  80099f:	75 0a                	jne    8009ab <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a1:	c1 e9 02             	shr    $0x2,%ecx
  8009a4:	89 c7                	mov    %eax,%edi
  8009a6:	fc                   	cld    
  8009a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a9:	eb 05                	jmp    8009b0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ab:	89 c7                	mov    %eax,%edi
  8009ad:	fc                   	cld    
  8009ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b0:	5e                   	pop    %esi
  8009b1:	5f                   	pop    %edi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b7:	ff 75 10             	pushl  0x10(%ebp)
  8009ba:	ff 75 0c             	pushl  0xc(%ebp)
  8009bd:	ff 75 08             	pushl  0x8(%ebp)
  8009c0:	e8 87 ff ff ff       	call   80094c <memmove>
}
  8009c5:	c9                   	leave  
  8009c6:	c3                   	ret    

008009c7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	56                   	push   %esi
  8009cb:	53                   	push   %ebx
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d2:	89 c6                	mov    %eax,%esi
  8009d4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d7:	eb 1a                	jmp    8009f3 <memcmp+0x2c>
		if (*s1 != *s2)
  8009d9:	0f b6 08             	movzbl (%eax),%ecx
  8009dc:	0f b6 1a             	movzbl (%edx),%ebx
  8009df:	38 d9                	cmp    %bl,%cl
  8009e1:	74 0a                	je     8009ed <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e3:	0f b6 c1             	movzbl %cl,%eax
  8009e6:	0f b6 db             	movzbl %bl,%ebx
  8009e9:	29 d8                	sub    %ebx,%eax
  8009eb:	eb 0f                	jmp    8009fc <memcmp+0x35>
		s1++, s2++;
  8009ed:	83 c0 01             	add    $0x1,%eax
  8009f0:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f3:	39 f0                	cmp    %esi,%eax
  8009f5:	75 e2                	jne    8009d9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fc:	5b                   	pop    %ebx
  8009fd:	5e                   	pop    %esi
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	53                   	push   %ebx
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a07:	89 c1                	mov    %eax,%ecx
  800a09:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a10:	eb 0a                	jmp    800a1c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a12:	0f b6 10             	movzbl (%eax),%edx
  800a15:	39 da                	cmp    %ebx,%edx
  800a17:	74 07                	je     800a20 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a19:	83 c0 01             	add    $0x1,%eax
  800a1c:	39 c8                	cmp    %ecx,%eax
  800a1e:	72 f2                	jb     800a12 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a20:	5b                   	pop    %ebx
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	57                   	push   %edi
  800a27:	56                   	push   %esi
  800a28:	53                   	push   %ebx
  800a29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2f:	eb 03                	jmp    800a34 <strtol+0x11>
		s++;
  800a31:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a34:	0f b6 01             	movzbl (%ecx),%eax
  800a37:	3c 20                	cmp    $0x20,%al
  800a39:	74 f6                	je     800a31 <strtol+0xe>
  800a3b:	3c 09                	cmp    $0x9,%al
  800a3d:	74 f2                	je     800a31 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3f:	3c 2b                	cmp    $0x2b,%al
  800a41:	75 0a                	jne    800a4d <strtol+0x2a>
		s++;
  800a43:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a46:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4b:	eb 11                	jmp    800a5e <strtol+0x3b>
  800a4d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a52:	3c 2d                	cmp    $0x2d,%al
  800a54:	75 08                	jne    800a5e <strtol+0x3b>
		s++, neg = 1;
  800a56:	83 c1 01             	add    $0x1,%ecx
  800a59:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a64:	75 15                	jne    800a7b <strtol+0x58>
  800a66:	80 39 30             	cmpb   $0x30,(%ecx)
  800a69:	75 10                	jne    800a7b <strtol+0x58>
  800a6b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6f:	75 7c                	jne    800aed <strtol+0xca>
		s += 2, base = 16;
  800a71:	83 c1 02             	add    $0x2,%ecx
  800a74:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a79:	eb 16                	jmp    800a91 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a7b:	85 db                	test   %ebx,%ebx
  800a7d:	75 12                	jne    800a91 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a84:	80 39 30             	cmpb   $0x30,(%ecx)
  800a87:	75 08                	jne    800a91 <strtol+0x6e>
		s++, base = 8;
  800a89:	83 c1 01             	add    $0x1,%ecx
  800a8c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
  800a96:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a99:	0f b6 11             	movzbl (%ecx),%edx
  800a9c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9f:	89 f3                	mov    %esi,%ebx
  800aa1:	80 fb 09             	cmp    $0x9,%bl
  800aa4:	77 08                	ja     800aae <strtol+0x8b>
			dig = *s - '0';
  800aa6:	0f be d2             	movsbl %dl,%edx
  800aa9:	83 ea 30             	sub    $0x30,%edx
  800aac:	eb 22                	jmp    800ad0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aae:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab1:	89 f3                	mov    %esi,%ebx
  800ab3:	80 fb 19             	cmp    $0x19,%bl
  800ab6:	77 08                	ja     800ac0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab8:	0f be d2             	movsbl %dl,%edx
  800abb:	83 ea 57             	sub    $0x57,%edx
  800abe:	eb 10                	jmp    800ad0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac3:	89 f3                	mov    %esi,%ebx
  800ac5:	80 fb 19             	cmp    $0x19,%bl
  800ac8:	77 16                	ja     800ae0 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aca:	0f be d2             	movsbl %dl,%edx
  800acd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad3:	7d 0b                	jge    800ae0 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad5:	83 c1 01             	add    $0x1,%ecx
  800ad8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800adc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ade:	eb b9                	jmp    800a99 <strtol+0x76>

	if (endptr)
  800ae0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae4:	74 0d                	je     800af3 <strtol+0xd0>
		*endptr = (char *) s;
  800ae6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae9:	89 0e                	mov    %ecx,(%esi)
  800aeb:	eb 06                	jmp    800af3 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aed:	85 db                	test   %ebx,%ebx
  800aef:	74 98                	je     800a89 <strtol+0x66>
  800af1:	eb 9e                	jmp    800a91 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af3:	89 c2                	mov    %eax,%edx
  800af5:	f7 da                	neg    %edx
  800af7:	85 ff                	test   %edi,%edi
  800af9:	0f 45 c2             	cmovne %edx,%eax
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b12:	89 c3                	mov    %eax,%ebx
  800b14:	89 c7                	mov    %eax,%edi
  800b16:	89 c6                	mov    %eax,%esi
  800b18:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2f:	89 d1                	mov    %edx,%ecx
  800b31:	89 d3                	mov    %edx,%ebx
  800b33:	89 d7                	mov    %edx,%edi
  800b35:	89 d6                	mov    %edx,%esi
  800b37:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b47:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b51:	8b 55 08             	mov    0x8(%ebp),%edx
  800b54:	89 cb                	mov    %ecx,%ebx
  800b56:	89 cf                	mov    %ecx,%edi
  800b58:	89 ce                	mov    %ecx,%esi
  800b5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5c:	85 c0                	test   %eax,%eax
  800b5e:	7e 17                	jle    800b77 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	50                   	push   %eax
  800b64:	6a 03                	push   $0x3
  800b66:	68 a8 13 80 00       	push   $0x8013a8
  800b6b:	6a 23                	push   $0x23
  800b6d:	68 c5 13 80 00       	push   $0x8013c5
  800b72:	e8 8a 02 00 00       	call   800e01 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    

00800b7f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b85:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8a:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8f:	89 d1                	mov    %edx,%ecx
  800b91:	89 d3                	mov    %edx,%ebx
  800b93:	89 d7                	mov    %edx,%edi
  800b95:	89 d6                	mov    %edx,%esi
  800b97:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_yield>:

void
sys_yield(void)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bae:	89 d1                	mov    %edx,%ecx
  800bb0:	89 d3                	mov    %edx,%ebx
  800bb2:	89 d7                	mov    %edx,%edi
  800bb4:	89 d6                	mov    %edx,%esi
  800bb6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	be 00 00 00 00       	mov    $0x0,%esi
  800bcb:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd9:	89 f7                	mov    %esi,%edi
  800bdb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bdd:	85 c0                	test   %eax,%eax
  800bdf:	7e 17                	jle    800bf8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	50                   	push   %eax
  800be5:	6a 04                	push   $0x4
  800be7:	68 a8 13 80 00       	push   $0x8013a8
  800bec:	6a 23                	push   $0x23
  800bee:	68 c5 13 80 00       	push   $0x8013c5
  800bf3:	e8 09 02 00 00       	call   800e01 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c09:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c11:	8b 55 08             	mov    0x8(%ebp),%edx
  800c14:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c17:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c1a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	7e 17                	jle    800c3a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	50                   	push   %eax
  800c27:	6a 05                	push   $0x5
  800c29:	68 a8 13 80 00       	push   $0x8013a8
  800c2e:	6a 23                	push   $0x23
  800c30:	68 c5 13 80 00       	push   $0x8013c5
  800c35:	e8 c7 01 00 00       	call   800e01 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c50:	b8 06 00 00 00       	mov    $0x6,%eax
  800c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c58:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5b:	89 df                	mov    %ebx,%edi
  800c5d:	89 de                	mov    %ebx,%esi
  800c5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c61:	85 c0                	test   %eax,%eax
  800c63:	7e 17                	jle    800c7c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c65:	83 ec 0c             	sub    $0xc,%esp
  800c68:	50                   	push   %eax
  800c69:	6a 06                	push   $0x6
  800c6b:	68 a8 13 80 00       	push   $0x8013a8
  800c70:	6a 23                	push   $0x23
  800c72:	68 c5 13 80 00       	push   $0x8013c5
  800c77:	e8 85 01 00 00       	call   800e01 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c92:	b8 08 00 00 00       	mov    $0x8,%eax
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	89 df                	mov    %ebx,%edi
  800c9f:	89 de                	mov    %ebx,%esi
  800ca1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	7e 17                	jle    800cbe <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	50                   	push   %eax
  800cab:	6a 08                	push   $0x8
  800cad:	68 a8 13 80 00       	push   $0x8013a8
  800cb2:	6a 23                	push   $0x23
  800cb4:	68 c5 13 80 00       	push   $0x8013c5
  800cb9:	e8 43 01 00 00       	call   800e01 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd4:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	89 df                	mov    %ebx,%edi
  800ce1:	89 de                	mov    %ebx,%esi
  800ce3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	7e 17                	jle    800d00 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce9:	83 ec 0c             	sub    $0xc,%esp
  800cec:	50                   	push   %eax
  800ced:	6a 09                	push   $0x9
  800cef:	68 a8 13 80 00       	push   $0x8013a8
  800cf4:	6a 23                	push   $0x23
  800cf6:	68 c5 13 80 00       	push   $0x8013c5
  800cfb:	e8 01 01 00 00       	call   800e01 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0e:	be 00 00 00 00       	mov    $0x0,%esi
  800d13:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d21:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d24:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d26:	5b                   	pop    %ebx
  800d27:	5e                   	pop    %esi
  800d28:	5f                   	pop    %edi
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
  800d31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d34:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d39:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d41:	89 cb                	mov    %ecx,%ebx
  800d43:	89 cf                	mov    %ecx,%edi
  800d45:	89 ce                	mov    %ecx,%esi
  800d47:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7e 17                	jle    800d64 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4d:	83 ec 0c             	sub    $0xc,%esp
  800d50:	50                   	push   %eax
  800d51:	6a 0c                	push   $0xc
  800d53:	68 a8 13 80 00       	push   $0x8013a8
  800d58:	6a 23                	push   $0x23
  800d5a:	68 c5 13 80 00       	push   $0x8013c5
  800d5f:	e8 9d 00 00 00       	call   800e01 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800d72:	68 df 13 80 00       	push   $0x8013df
  800d77:	6a 51                	push   $0x51
  800d79:	68 d3 13 80 00       	push   $0x8013d3
  800d7e:	e8 7e 00 00 00       	call   800e01 <_panic>

00800d83 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d89:	68 de 13 80 00       	push   $0x8013de
  800d8e:	6a 58                	push   $0x58
  800d90:	68 d3 13 80 00       	push   $0x8013d3
  800d95:	e8 67 00 00 00       	call   800e01 <_panic>

00800d9a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800da0:	68 f4 13 80 00       	push   $0x8013f4
  800da5:	6a 1a                	push   $0x1a
  800da7:	68 0d 14 80 00       	push   $0x80140d
  800dac:	e8 50 00 00 00       	call   800e01 <_panic>

00800db1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800db7:	68 17 14 80 00       	push   $0x801417
  800dbc:	6a 2a                	push   $0x2a
  800dbe:	68 0d 14 80 00       	push   $0x80140d
  800dc3:	e8 39 00 00 00       	call   800e01 <_panic>

00800dc8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800dce:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800dd3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800dd6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800ddc:	8b 52 50             	mov    0x50(%edx),%edx
  800ddf:	39 ca                	cmp    %ecx,%edx
  800de1:	75 0d                	jne    800df0 <ipc_find_env+0x28>
			return envs[i].env_id;
  800de3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800de6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800deb:	8b 40 48             	mov    0x48(%eax),%eax
  800dee:	eb 0f                	jmp    800dff <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800df0:	83 c0 01             	add    $0x1,%eax
  800df3:	3d 00 04 00 00       	cmp    $0x400,%eax
  800df8:	75 d9                	jne    800dd3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800dfa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800e06:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e09:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e0f:	e8 6b fd ff ff       	call   800b7f <sys_getenvid>
  800e14:	83 ec 0c             	sub    $0xc,%esp
  800e17:	ff 75 0c             	pushl  0xc(%ebp)
  800e1a:	ff 75 08             	pushl  0x8(%ebp)
  800e1d:	56                   	push   %esi
  800e1e:	50                   	push   %eax
  800e1f:	68 30 14 80 00       	push   $0x801430
  800e24:	e8 ca f3 ff ff       	call   8001f3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e29:	83 c4 18             	add    $0x18,%esp
  800e2c:	53                   	push   %ebx
  800e2d:	ff 75 10             	pushl  0x10(%ebp)
  800e30:	e8 6d f3 ff ff       	call   8001a2 <vcprintf>
	cprintf("\n");
  800e35:	c7 04 24 74 11 80 00 	movl   $0x801174,(%esp)
  800e3c:	e8 b2 f3 ff ff       	call   8001f3 <cprintf>
  800e41:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e44:	cc                   	int3   
  800e45:	eb fd                	jmp    800e44 <_panic+0x43>
  800e47:	66 90                	xchg   %ax,%ax
  800e49:	66 90                	xchg   %ax,%ax
  800e4b:	66 90                	xchg   %ax,%ax
  800e4d:	66 90                	xchg   %ax,%ax
  800e4f:	90                   	nop

00800e50 <__udivdi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
  800e57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e67:	85 f6                	test   %esi,%esi
  800e69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e6d:	89 ca                	mov    %ecx,%edx
  800e6f:	89 f8                	mov    %edi,%eax
  800e71:	75 3d                	jne    800eb0 <__udivdi3+0x60>
  800e73:	39 cf                	cmp    %ecx,%edi
  800e75:	0f 87 c5 00 00 00    	ja     800f40 <__udivdi3+0xf0>
  800e7b:	85 ff                	test   %edi,%edi
  800e7d:	89 fd                	mov    %edi,%ebp
  800e7f:	75 0b                	jne    800e8c <__udivdi3+0x3c>
  800e81:	b8 01 00 00 00       	mov    $0x1,%eax
  800e86:	31 d2                	xor    %edx,%edx
  800e88:	f7 f7                	div    %edi
  800e8a:	89 c5                	mov    %eax,%ebp
  800e8c:	89 c8                	mov    %ecx,%eax
  800e8e:	31 d2                	xor    %edx,%edx
  800e90:	f7 f5                	div    %ebp
  800e92:	89 c1                	mov    %eax,%ecx
  800e94:	89 d8                	mov    %ebx,%eax
  800e96:	89 cf                	mov    %ecx,%edi
  800e98:	f7 f5                	div    %ebp
  800e9a:	89 c3                	mov    %eax,%ebx
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
  800eb0:	39 ce                	cmp    %ecx,%esi
  800eb2:	77 74                	ja     800f28 <__udivdi3+0xd8>
  800eb4:	0f bd fe             	bsr    %esi,%edi
  800eb7:	83 f7 1f             	xor    $0x1f,%edi
  800eba:	0f 84 98 00 00 00    	je     800f58 <__udivdi3+0x108>
  800ec0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800ec5:	89 f9                	mov    %edi,%ecx
  800ec7:	89 c5                	mov    %eax,%ebp
  800ec9:	29 fb                	sub    %edi,%ebx
  800ecb:	d3 e6                	shl    %cl,%esi
  800ecd:	89 d9                	mov    %ebx,%ecx
  800ecf:	d3 ed                	shr    %cl,%ebp
  800ed1:	89 f9                	mov    %edi,%ecx
  800ed3:	d3 e0                	shl    %cl,%eax
  800ed5:	09 ee                	or     %ebp,%esi
  800ed7:	89 d9                	mov    %ebx,%ecx
  800ed9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800edd:	89 d5                	mov    %edx,%ebp
  800edf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ee3:	d3 ed                	shr    %cl,%ebp
  800ee5:	89 f9                	mov    %edi,%ecx
  800ee7:	d3 e2                	shl    %cl,%edx
  800ee9:	89 d9                	mov    %ebx,%ecx
  800eeb:	d3 e8                	shr    %cl,%eax
  800eed:	09 c2                	or     %eax,%edx
  800eef:	89 d0                	mov    %edx,%eax
  800ef1:	89 ea                	mov    %ebp,%edx
  800ef3:	f7 f6                	div    %esi
  800ef5:	89 d5                	mov    %edx,%ebp
  800ef7:	89 c3                	mov    %eax,%ebx
  800ef9:	f7 64 24 0c          	mull   0xc(%esp)
  800efd:	39 d5                	cmp    %edx,%ebp
  800eff:	72 10                	jb     800f11 <__udivdi3+0xc1>
  800f01:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f05:	89 f9                	mov    %edi,%ecx
  800f07:	d3 e6                	shl    %cl,%esi
  800f09:	39 c6                	cmp    %eax,%esi
  800f0b:	73 07                	jae    800f14 <__udivdi3+0xc4>
  800f0d:	39 d5                	cmp    %edx,%ebp
  800f0f:	75 03                	jne    800f14 <__udivdi3+0xc4>
  800f11:	83 eb 01             	sub    $0x1,%ebx
  800f14:	31 ff                	xor    %edi,%edi
  800f16:	89 d8                	mov    %ebx,%eax
  800f18:	89 fa                	mov    %edi,%edx
  800f1a:	83 c4 1c             	add    $0x1c,%esp
  800f1d:	5b                   	pop    %ebx
  800f1e:	5e                   	pop    %esi
  800f1f:	5f                   	pop    %edi
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    
  800f22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f28:	31 ff                	xor    %edi,%edi
  800f2a:	31 db                	xor    %ebx,%ebx
  800f2c:	89 d8                	mov    %ebx,%eax
  800f2e:	89 fa                	mov    %edi,%edx
  800f30:	83 c4 1c             	add    $0x1c,%esp
  800f33:	5b                   	pop    %ebx
  800f34:	5e                   	pop    %esi
  800f35:	5f                   	pop    %edi
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    
  800f38:	90                   	nop
  800f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f40:	89 d8                	mov    %ebx,%eax
  800f42:	f7 f7                	div    %edi
  800f44:	31 ff                	xor    %edi,%edi
  800f46:	89 c3                	mov    %eax,%ebx
  800f48:	89 d8                	mov    %ebx,%eax
  800f4a:	89 fa                	mov    %edi,%edx
  800f4c:	83 c4 1c             	add    $0x1c,%esp
  800f4f:	5b                   	pop    %ebx
  800f50:	5e                   	pop    %esi
  800f51:	5f                   	pop    %edi
  800f52:	5d                   	pop    %ebp
  800f53:	c3                   	ret    
  800f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f58:	39 ce                	cmp    %ecx,%esi
  800f5a:	72 0c                	jb     800f68 <__udivdi3+0x118>
  800f5c:	31 db                	xor    %ebx,%ebx
  800f5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f62:	0f 87 34 ff ff ff    	ja     800e9c <__udivdi3+0x4c>
  800f68:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f6d:	e9 2a ff ff ff       	jmp    800e9c <__udivdi3+0x4c>
  800f72:	66 90                	xchg   %ax,%ax
  800f74:	66 90                	xchg   %ax,%ax
  800f76:	66 90                	xchg   %ax,%ax
  800f78:	66 90                	xchg   %ax,%ax
  800f7a:	66 90                	xchg   %ax,%ax
  800f7c:	66 90                	xchg   %ax,%ax
  800f7e:	66 90                	xchg   %ax,%ax

00800f80 <__umoddi3>:
  800f80:	55                   	push   %ebp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	53                   	push   %ebx
  800f84:	83 ec 1c             	sub    $0x1c,%esp
  800f87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f97:	85 d2                	test   %edx,%edx
  800f99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fa1:	89 f3                	mov    %esi,%ebx
  800fa3:	89 3c 24             	mov    %edi,(%esp)
  800fa6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800faa:	75 1c                	jne    800fc8 <__umoddi3+0x48>
  800fac:	39 f7                	cmp    %esi,%edi
  800fae:	76 50                	jbe    801000 <__umoddi3+0x80>
  800fb0:	89 c8                	mov    %ecx,%eax
  800fb2:	89 f2                	mov    %esi,%edx
  800fb4:	f7 f7                	div    %edi
  800fb6:	89 d0                	mov    %edx,%eax
  800fb8:	31 d2                	xor    %edx,%edx
  800fba:	83 c4 1c             	add    $0x1c,%esp
  800fbd:	5b                   	pop    %ebx
  800fbe:	5e                   	pop    %esi
  800fbf:	5f                   	pop    %edi
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    
  800fc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fc8:	39 f2                	cmp    %esi,%edx
  800fca:	89 d0                	mov    %edx,%eax
  800fcc:	77 52                	ja     801020 <__umoddi3+0xa0>
  800fce:	0f bd ea             	bsr    %edx,%ebp
  800fd1:	83 f5 1f             	xor    $0x1f,%ebp
  800fd4:	75 5a                	jne    801030 <__umoddi3+0xb0>
  800fd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800fda:	0f 82 e0 00 00 00    	jb     8010c0 <__umoddi3+0x140>
  800fe0:	39 0c 24             	cmp    %ecx,(%esp)
  800fe3:	0f 86 d7 00 00 00    	jbe    8010c0 <__umoddi3+0x140>
  800fe9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fed:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ff1:	83 c4 1c             	add    $0x1c,%esp
  800ff4:	5b                   	pop    %ebx
  800ff5:	5e                   	pop    %esi
  800ff6:	5f                   	pop    %edi
  800ff7:	5d                   	pop    %ebp
  800ff8:	c3                   	ret    
  800ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801000:	85 ff                	test   %edi,%edi
  801002:	89 fd                	mov    %edi,%ebp
  801004:	75 0b                	jne    801011 <__umoddi3+0x91>
  801006:	b8 01 00 00 00       	mov    $0x1,%eax
  80100b:	31 d2                	xor    %edx,%edx
  80100d:	f7 f7                	div    %edi
  80100f:	89 c5                	mov    %eax,%ebp
  801011:	89 f0                	mov    %esi,%eax
  801013:	31 d2                	xor    %edx,%edx
  801015:	f7 f5                	div    %ebp
  801017:	89 c8                	mov    %ecx,%eax
  801019:	f7 f5                	div    %ebp
  80101b:	89 d0                	mov    %edx,%eax
  80101d:	eb 99                	jmp    800fb8 <__umoddi3+0x38>
  80101f:	90                   	nop
  801020:	89 c8                	mov    %ecx,%eax
  801022:	89 f2                	mov    %esi,%edx
  801024:	83 c4 1c             	add    $0x1c,%esp
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	5f                   	pop    %edi
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    
  80102c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801030:	8b 34 24             	mov    (%esp),%esi
  801033:	bf 20 00 00 00       	mov    $0x20,%edi
  801038:	89 e9                	mov    %ebp,%ecx
  80103a:	29 ef                	sub    %ebp,%edi
  80103c:	d3 e0                	shl    %cl,%eax
  80103e:	89 f9                	mov    %edi,%ecx
  801040:	89 f2                	mov    %esi,%edx
  801042:	d3 ea                	shr    %cl,%edx
  801044:	89 e9                	mov    %ebp,%ecx
  801046:	09 c2                	or     %eax,%edx
  801048:	89 d8                	mov    %ebx,%eax
  80104a:	89 14 24             	mov    %edx,(%esp)
  80104d:	89 f2                	mov    %esi,%edx
  80104f:	d3 e2                	shl    %cl,%edx
  801051:	89 f9                	mov    %edi,%ecx
  801053:	89 54 24 04          	mov    %edx,0x4(%esp)
  801057:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80105b:	d3 e8                	shr    %cl,%eax
  80105d:	89 e9                	mov    %ebp,%ecx
  80105f:	89 c6                	mov    %eax,%esi
  801061:	d3 e3                	shl    %cl,%ebx
  801063:	89 f9                	mov    %edi,%ecx
  801065:	89 d0                	mov    %edx,%eax
  801067:	d3 e8                	shr    %cl,%eax
  801069:	89 e9                	mov    %ebp,%ecx
  80106b:	09 d8                	or     %ebx,%eax
  80106d:	89 d3                	mov    %edx,%ebx
  80106f:	89 f2                	mov    %esi,%edx
  801071:	f7 34 24             	divl   (%esp)
  801074:	89 d6                	mov    %edx,%esi
  801076:	d3 e3                	shl    %cl,%ebx
  801078:	f7 64 24 04          	mull   0x4(%esp)
  80107c:	39 d6                	cmp    %edx,%esi
  80107e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801082:	89 d1                	mov    %edx,%ecx
  801084:	89 c3                	mov    %eax,%ebx
  801086:	72 08                	jb     801090 <__umoddi3+0x110>
  801088:	75 11                	jne    80109b <__umoddi3+0x11b>
  80108a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80108e:	73 0b                	jae    80109b <__umoddi3+0x11b>
  801090:	2b 44 24 04          	sub    0x4(%esp),%eax
  801094:	1b 14 24             	sbb    (%esp),%edx
  801097:	89 d1                	mov    %edx,%ecx
  801099:	89 c3                	mov    %eax,%ebx
  80109b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80109f:	29 da                	sub    %ebx,%edx
  8010a1:	19 ce                	sbb    %ecx,%esi
  8010a3:	89 f9                	mov    %edi,%ecx
  8010a5:	89 f0                	mov    %esi,%eax
  8010a7:	d3 e0                	shl    %cl,%eax
  8010a9:	89 e9                	mov    %ebp,%ecx
  8010ab:	d3 ea                	shr    %cl,%edx
  8010ad:	89 e9                	mov    %ebp,%ecx
  8010af:	d3 ee                	shr    %cl,%esi
  8010b1:	09 d0                	or     %edx,%eax
  8010b3:	89 f2                	mov    %esi,%edx
  8010b5:	83 c4 1c             	add    $0x1c,%esp
  8010b8:	5b                   	pop    %ebx
  8010b9:	5e                   	pop    %esi
  8010ba:	5f                   	pop    %edi
  8010bb:	5d                   	pop    %ebp
  8010bc:	c3                   	ret    
  8010bd:	8d 76 00             	lea    0x0(%esi),%esi
  8010c0:	29 f9                	sub    %edi,%ecx
  8010c2:	19 d6                	sbb    %edx,%esi
  8010c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010cc:	e9 18 ff ff ff       	jmp    800fe9 <__umoddi3+0x69>
