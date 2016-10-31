
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 20 0b 00 00       	call   800b62 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 60 10 80 00       	push   $0x801060
  80004c:	e8 85 01 00 00       	call   8001d6 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 e1 06 00 00       	call   800764 <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 71 10 80 00       	push   $0x801071
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 a5 06 00 00       	call   80074a <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 a2 0c 00 00       	call   800d4f <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 6f 00 00 00       	call   800131 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 70 10 80 00       	push   $0x801070
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000ec:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000f3:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  8000f6:	e8 67 0a 00 00       	call   800b62 <sys_getenvid>
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800108:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010d:	85 db                	test   %ebx,%ebx
  80010f:	7e 07                	jle    800118 <libmain+0x37>
		binaryname = argv[0];
  800111:	8b 06                	mov    (%esi),%eax
  800113:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800118:	83 ec 08             	sub    $0x8,%esp
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
  80011d:	e8 aa ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  800122:	e8 0a 00 00 00       	call   800131 <exit>
}
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    

00800131 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800137:	6a 00                	push   $0x0
  800139:	e8 e3 09 00 00       	call   800b21 <sys_env_destroy>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	53                   	push   %ebx
  800147:	83 ec 04             	sub    $0x4,%esp
  80014a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014d:	8b 13                	mov    (%ebx),%edx
  80014f:	8d 42 01             	lea    0x1(%edx),%eax
  800152:	89 03                	mov    %eax,(%ebx)
  800154:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800157:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80015b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800160:	75 1a                	jne    80017c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800162:	83 ec 08             	sub    $0x8,%esp
  800165:	68 ff 00 00 00       	push   $0xff
  80016a:	8d 43 08             	lea    0x8(%ebx),%eax
  80016d:	50                   	push   %eax
  80016e:	e8 71 09 00 00       	call   800ae4 <sys_cputs>
		b->idx = 0;
  800173:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800179:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800180:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800195:	00 00 00 
	b.cnt = 0;
  800198:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a2:	ff 75 0c             	pushl  0xc(%ebp)
  8001a5:	ff 75 08             	pushl  0x8(%ebp)
  8001a8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ae:	50                   	push   %eax
  8001af:	68 43 01 80 00       	push   $0x800143
  8001b4:	e8 54 01 00 00       	call   80030d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b9:	83 c4 08             	add    $0x8,%esp
  8001bc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 16 09 00 00       	call   800ae4 <sys_cputs>

	return b.cnt;
}
  8001ce:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d4:	c9                   	leave  
  8001d5:	c3                   	ret    

008001d6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001dc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001df:	50                   	push   %eax
  8001e0:	ff 75 08             	pushl  0x8(%ebp)
  8001e3:	e8 9d ff ff ff       	call   800185 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e8:	c9                   	leave  
  8001e9:	c3                   	ret    

008001ea <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	57                   	push   %edi
  8001ee:	56                   	push   %esi
  8001ef:	53                   	push   %ebx
  8001f0:	83 ec 1c             	sub    $0x1c,%esp
  8001f3:	89 c7                	mov    %eax,%edi
  8001f5:	89 d6                	mov    %edx,%esi
  8001f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800200:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800203:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800206:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80020e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800211:	39 d3                	cmp    %edx,%ebx
  800213:	72 05                	jb     80021a <printnum+0x30>
  800215:	39 45 10             	cmp    %eax,0x10(%ebp)
  800218:	77 45                	ja     80025f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80021a:	83 ec 0c             	sub    $0xc,%esp
  80021d:	ff 75 18             	pushl  0x18(%ebp)
  800220:	8b 45 14             	mov    0x14(%ebp),%eax
  800223:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800226:	53                   	push   %ebx
  800227:	ff 75 10             	pushl  0x10(%ebp)
  80022a:	83 ec 08             	sub    $0x8,%esp
  80022d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800230:	ff 75 e0             	pushl  -0x20(%ebp)
  800233:	ff 75 dc             	pushl  -0x24(%ebp)
  800236:	ff 75 d8             	pushl  -0x28(%ebp)
  800239:	e8 92 0b 00 00       	call   800dd0 <__udivdi3>
  80023e:	83 c4 18             	add    $0x18,%esp
  800241:	52                   	push   %edx
  800242:	50                   	push   %eax
  800243:	89 f2                	mov    %esi,%edx
  800245:	89 f8                	mov    %edi,%eax
  800247:	e8 9e ff ff ff       	call   8001ea <printnum>
  80024c:	83 c4 20             	add    $0x20,%esp
  80024f:	eb 18                	jmp    800269 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	56                   	push   %esi
  800255:	ff 75 18             	pushl  0x18(%ebp)
  800258:	ff d7                	call   *%edi
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	eb 03                	jmp    800262 <printnum+0x78>
  80025f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800262:	83 eb 01             	sub    $0x1,%ebx
  800265:	85 db                	test   %ebx,%ebx
  800267:	7f e8                	jg     800251 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	83 ec 04             	sub    $0x4,%esp
  800270:	ff 75 e4             	pushl  -0x1c(%ebp)
  800273:	ff 75 e0             	pushl  -0x20(%ebp)
  800276:	ff 75 dc             	pushl  -0x24(%ebp)
  800279:	ff 75 d8             	pushl  -0x28(%ebp)
  80027c:	e8 7f 0c 00 00       	call   800f00 <__umoddi3>
  800281:	83 c4 14             	add    $0x14,%esp
  800284:	0f be 80 80 10 80 00 	movsbl 0x801080(%eax),%eax
  80028b:	50                   	push   %eax
  80028c:	ff d7                	call   *%edi
}
  80028e:	83 c4 10             	add    $0x10,%esp
  800291:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800294:	5b                   	pop    %ebx
  800295:	5e                   	pop    %esi
  800296:	5f                   	pop    %edi
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80029c:	83 fa 01             	cmp    $0x1,%edx
  80029f:	7e 0e                	jle    8002af <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002a1:	8b 10                	mov    (%eax),%edx
  8002a3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a6:	89 08                	mov    %ecx,(%eax)
  8002a8:	8b 02                	mov    (%edx),%eax
  8002aa:	8b 52 04             	mov    0x4(%edx),%edx
  8002ad:	eb 22                	jmp    8002d1 <getuint+0x38>
	else if (lflag)
  8002af:	85 d2                	test   %edx,%edx
  8002b1:	74 10                	je     8002c3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b3:	8b 10                	mov    (%eax),%edx
  8002b5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b8:	89 08                	mov    %ecx,(%eax)
  8002ba:	8b 02                	mov    (%edx),%eax
  8002bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c1:	eb 0e                	jmp    8002d1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c3:	8b 10                	mov    (%eax),%edx
  8002c5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c8:	89 08                	mov    %ecx,(%eax)
  8002ca:	8b 02                	mov    (%edx),%eax
  8002cc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002d1:	5d                   	pop    %ebp
  8002d2:	c3                   	ret    

008002d3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e2:	73 0a                	jae    8002ee <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e7:	89 08                	mov    %ecx,(%eax)
  8002e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ec:	88 02                	mov    %al,(%edx)
}
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002f6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f9:	50                   	push   %eax
  8002fa:	ff 75 10             	pushl  0x10(%ebp)
  8002fd:	ff 75 0c             	pushl  0xc(%ebp)
  800300:	ff 75 08             	pushl  0x8(%ebp)
  800303:	e8 05 00 00 00       	call   80030d <vprintfmt>
	va_end(ap);
}
  800308:	83 c4 10             	add    $0x10,%esp
  80030b:	c9                   	leave  
  80030c:	c3                   	ret    

0080030d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	57                   	push   %edi
  800311:	56                   	push   %esi
  800312:	53                   	push   %ebx
  800313:	83 ec 2c             	sub    $0x2c,%esp
  800316:	8b 75 08             	mov    0x8(%ebp),%esi
  800319:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031f:	eb 12                	jmp    800333 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800321:	85 c0                	test   %eax,%eax
  800323:	0f 84 cb 03 00 00    	je     8006f4 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800329:	83 ec 08             	sub    $0x8,%esp
  80032c:	53                   	push   %ebx
  80032d:	50                   	push   %eax
  80032e:	ff d6                	call   *%esi
  800330:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800333:	83 c7 01             	add    $0x1,%edi
  800336:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80033a:	83 f8 25             	cmp    $0x25,%eax
  80033d:	75 e2                	jne    800321 <vprintfmt+0x14>
  80033f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800343:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80034a:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800351:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800358:	ba 00 00 00 00       	mov    $0x0,%edx
  80035d:	eb 07                	jmp    800366 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800362:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8d 47 01             	lea    0x1(%edi),%eax
  800369:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036c:	0f b6 07             	movzbl (%edi),%eax
  80036f:	0f b6 c8             	movzbl %al,%ecx
  800372:	83 e8 23             	sub    $0x23,%eax
  800375:	3c 55                	cmp    $0x55,%al
  800377:	0f 87 5c 03 00 00    	ja     8006d9 <vprintfmt+0x3cc>
  80037d:	0f b6 c0             	movzbl %al,%eax
  800380:	ff 24 85 60 11 80 00 	jmp    *0x801160(,%eax,4)
  800387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80038a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80038e:	eb d6                	jmp    800366 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800393:	b8 00 00 00 00       	mov    $0x0,%eax
  800398:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80039b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003a2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003a5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003a8:	83 fa 09             	cmp    $0x9,%edx
  8003ab:	77 39                	ja     8003e6 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ad:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b0:	eb e9                	jmp    80039b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b5:	8d 48 04             	lea    0x4(%eax),%ecx
  8003b8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003bb:	8b 00                	mov    (%eax),%eax
  8003bd:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003c3:	eb 27                	jmp    8003ec <vprintfmt+0xdf>
  8003c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c8:	85 c0                	test   %eax,%eax
  8003ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003cf:	0f 49 c8             	cmovns %eax,%ecx
  8003d2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d8:	eb 8c                	jmp    800366 <vprintfmt+0x59>
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003dd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e4:	eb 80                	jmp    800366 <vprintfmt+0x59>
  8003e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003e9:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8003ec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f0:	0f 89 70 ff ff ff    	jns    800366 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003f6:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fc:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800403:	e9 5e ff ff ff       	jmp    800366 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800408:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040e:	e9 53 ff ff ff       	jmp    800366 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800413:	8b 45 14             	mov    0x14(%ebp),%eax
  800416:	8d 50 04             	lea    0x4(%eax),%edx
  800419:	89 55 14             	mov    %edx,0x14(%ebp)
  80041c:	83 ec 08             	sub    $0x8,%esp
  80041f:	53                   	push   %ebx
  800420:	ff 30                	pushl  (%eax)
  800422:	ff d6                	call   *%esi
			break;
  800424:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80042a:	e9 04 ff ff ff       	jmp    800333 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8d 50 04             	lea    0x4(%eax),%edx
  800435:	89 55 14             	mov    %edx,0x14(%ebp)
  800438:	8b 00                	mov    (%eax),%eax
  80043a:	99                   	cltd   
  80043b:	31 d0                	xor    %edx,%eax
  80043d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043f:	83 f8 09             	cmp    $0x9,%eax
  800442:	7f 0b                	jg     80044f <vprintfmt+0x142>
  800444:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  80044b:	85 d2                	test   %edx,%edx
  80044d:	75 18                	jne    800467 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80044f:	50                   	push   %eax
  800450:	68 98 10 80 00       	push   $0x801098
  800455:	53                   	push   %ebx
  800456:	56                   	push   %esi
  800457:	e8 94 fe ff ff       	call   8002f0 <printfmt>
  80045c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800462:	e9 cc fe ff ff       	jmp    800333 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800467:	52                   	push   %edx
  800468:	68 a1 10 80 00       	push   $0x8010a1
  80046d:	53                   	push   %ebx
  80046e:	56                   	push   %esi
  80046f:	e8 7c fe ff ff       	call   8002f0 <printfmt>
  800474:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047a:	e9 b4 fe ff ff       	jmp    800333 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8d 50 04             	lea    0x4(%eax),%edx
  800485:	89 55 14             	mov    %edx,0x14(%ebp)
  800488:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80048a:	85 ff                	test   %edi,%edi
  80048c:	b8 91 10 80 00       	mov    $0x801091,%eax
  800491:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800494:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800498:	0f 8e 94 00 00 00    	jle    800532 <vprintfmt+0x225>
  80049e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a2:	0f 84 98 00 00 00    	je     800540 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	ff 75 c8             	pushl  -0x38(%ebp)
  8004ae:	57                   	push   %edi
  8004af:	e8 c8 02 00 00       	call   80077c <strnlen>
  8004b4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b7:	29 c1                	sub    %eax,%ecx
  8004b9:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004bc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004bf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cb:	eb 0f                	jmp    8004dc <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	53                   	push   %ebx
  8004d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d6:	83 ef 01             	sub    $0x1,%edi
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	85 ff                	test   %edi,%edi
  8004de:	7f ed                	jg     8004cd <vprintfmt+0x1c0>
  8004e0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004e6:	85 c9                	test   %ecx,%ecx
  8004e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ed:	0f 49 c1             	cmovns %ecx,%eax
  8004f0:	29 c1                	sub    %eax,%ecx
  8004f2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f5:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8004f8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fb:	89 cb                	mov    %ecx,%ebx
  8004fd:	eb 4d                	jmp    80054c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ff:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800503:	74 1b                	je     800520 <vprintfmt+0x213>
  800505:	0f be c0             	movsbl %al,%eax
  800508:	83 e8 20             	sub    $0x20,%eax
  80050b:	83 f8 5e             	cmp    $0x5e,%eax
  80050e:	76 10                	jbe    800520 <vprintfmt+0x213>
					putch('?', putdat);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	ff 75 0c             	pushl  0xc(%ebp)
  800516:	6a 3f                	push   $0x3f
  800518:	ff 55 08             	call   *0x8(%ebp)
  80051b:	83 c4 10             	add    $0x10,%esp
  80051e:	eb 0d                	jmp    80052d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	ff 75 0c             	pushl  0xc(%ebp)
  800526:	52                   	push   %edx
  800527:	ff 55 08             	call   *0x8(%ebp)
  80052a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052d:	83 eb 01             	sub    $0x1,%ebx
  800530:	eb 1a                	jmp    80054c <vprintfmt+0x23f>
  800532:	89 75 08             	mov    %esi,0x8(%ebp)
  800535:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800538:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053e:	eb 0c                	jmp    80054c <vprintfmt+0x23f>
  800540:	89 75 08             	mov    %esi,0x8(%ebp)
  800543:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800546:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800549:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054c:	83 c7 01             	add    $0x1,%edi
  80054f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800553:	0f be d0             	movsbl %al,%edx
  800556:	85 d2                	test   %edx,%edx
  800558:	74 23                	je     80057d <vprintfmt+0x270>
  80055a:	85 f6                	test   %esi,%esi
  80055c:	78 a1                	js     8004ff <vprintfmt+0x1f2>
  80055e:	83 ee 01             	sub    $0x1,%esi
  800561:	79 9c                	jns    8004ff <vprintfmt+0x1f2>
  800563:	89 df                	mov    %ebx,%edi
  800565:	8b 75 08             	mov    0x8(%ebp),%esi
  800568:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056b:	eb 18                	jmp    800585 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	53                   	push   %ebx
  800571:	6a 20                	push   $0x20
  800573:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800575:	83 ef 01             	sub    $0x1,%edi
  800578:	83 c4 10             	add    $0x10,%esp
  80057b:	eb 08                	jmp    800585 <vprintfmt+0x278>
  80057d:	89 df                	mov    %ebx,%edi
  80057f:	8b 75 08             	mov    0x8(%ebp),%esi
  800582:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800585:	85 ff                	test   %edi,%edi
  800587:	7f e4                	jg     80056d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800589:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058c:	e9 a2 fd ff ff       	jmp    800333 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800591:	83 fa 01             	cmp    $0x1,%edx
  800594:	7e 16                	jle    8005ac <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8d 50 08             	lea    0x8(%eax),%edx
  80059c:	89 55 14             	mov    %edx,0x14(%ebp)
  80059f:	8b 50 04             	mov    0x4(%eax),%edx
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005a7:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005aa:	eb 32                	jmp    8005de <vprintfmt+0x2d1>
	else if (lflag)
  8005ac:	85 d2                	test   %edx,%edx
  8005ae:	74 18                	je     8005c8 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 04             	lea    0x4(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b9:	8b 00                	mov    (%eax),%eax
  8005bb:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005be:	89 c1                	mov    %eax,%ecx
  8005c0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005c6:	eb 16                	jmp    8005de <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 50 04             	lea    0x4(%eax),%edx
  8005ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005d6:	89 c1                	mov    %eax,%ecx
  8005d8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005db:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005de:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005e1:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ea:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005ef:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005f3:	0f 89 a8 00 00 00    	jns    8006a1 <vprintfmt+0x394>
				putch('-', putdat);
  8005f9:	83 ec 08             	sub    $0x8,%esp
  8005fc:	53                   	push   %ebx
  8005fd:	6a 2d                	push   $0x2d
  8005ff:	ff d6                	call   *%esi
				num = -(long long) num;
  800601:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800604:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800607:	f7 d8                	neg    %eax
  800609:	83 d2 00             	adc    $0x0,%edx
  80060c:	f7 da                	neg    %edx
  80060e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800611:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800614:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800617:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061c:	e9 80 00 00 00       	jmp    8006a1 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800621:	8d 45 14             	lea    0x14(%ebp),%eax
  800624:	e8 70 fc ff ff       	call   800299 <getuint>
  800629:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80062f:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800634:	eb 6b                	jmp    8006a1 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800636:	8d 45 14             	lea    0x14(%ebp),%eax
  800639:	e8 5b fc ff ff       	call   800299 <getuint>
  80063e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800641:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800644:	6a 04                	push   $0x4
  800646:	6a 03                	push   $0x3
  800648:	6a 01                	push   $0x1
  80064a:	68 a4 10 80 00       	push   $0x8010a4
  80064f:	e8 82 fb ff ff       	call   8001d6 <cprintf>
			goto number;
  800654:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  800657:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  80065c:	eb 43                	jmp    8006a1 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	53                   	push   %ebx
  800662:	6a 30                	push   $0x30
  800664:	ff d6                	call   *%esi
			putch('x', putdat);
  800666:	83 c4 08             	add    $0x8,%esp
  800669:	53                   	push   %ebx
  80066a:	6a 78                	push   $0x78
  80066c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80066e:	8b 45 14             	mov    0x14(%ebp),%eax
  800671:	8d 50 04             	lea    0x4(%eax),%edx
  800674:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800677:	8b 00                	mov    (%eax),%eax
  800679:	ba 00 00 00 00       	mov    $0x0,%edx
  80067e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800681:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800684:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800687:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80068c:	eb 13                	jmp    8006a1 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80068e:	8d 45 14             	lea    0x14(%ebp),%eax
  800691:	e8 03 fc ff ff       	call   800299 <getuint>
  800696:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800699:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  80069c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a1:	83 ec 0c             	sub    $0xc,%esp
  8006a4:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006a8:	52                   	push   %edx
  8006a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ac:	50                   	push   %eax
  8006ad:	ff 75 dc             	pushl  -0x24(%ebp)
  8006b0:	ff 75 d8             	pushl  -0x28(%ebp)
  8006b3:	89 da                	mov    %ebx,%edx
  8006b5:	89 f0                	mov    %esi,%eax
  8006b7:	e8 2e fb ff ff       	call   8001ea <printnum>

			break;
  8006bc:	83 c4 20             	add    $0x20,%esp
  8006bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c2:	e9 6c fc ff ff       	jmp    800333 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c7:	83 ec 08             	sub    $0x8,%esp
  8006ca:	53                   	push   %ebx
  8006cb:	51                   	push   %ecx
  8006cc:	ff d6                	call   *%esi
			break;
  8006ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d4:	e9 5a fc ff ff       	jmp    800333 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	53                   	push   %ebx
  8006dd:	6a 25                	push   $0x25
  8006df:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	eb 03                	jmp    8006e9 <vprintfmt+0x3dc>
  8006e6:	83 ef 01             	sub    $0x1,%edi
  8006e9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006ed:	75 f7                	jne    8006e6 <vprintfmt+0x3d9>
  8006ef:	e9 3f fc ff ff       	jmp    800333 <vprintfmt+0x26>
			break;
		}

	}

}
  8006f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	83 ec 18             	sub    $0x18,%esp
  800702:	8b 45 08             	mov    0x8(%ebp),%eax
  800705:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800708:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800712:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800719:	85 c0                	test   %eax,%eax
  80071b:	74 26                	je     800743 <vsnprintf+0x47>
  80071d:	85 d2                	test   %edx,%edx
  80071f:	7e 22                	jle    800743 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800721:	ff 75 14             	pushl  0x14(%ebp)
  800724:	ff 75 10             	pushl  0x10(%ebp)
  800727:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072a:	50                   	push   %eax
  80072b:	68 d3 02 80 00       	push   $0x8002d3
  800730:	e8 d8 fb ff ff       	call   80030d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800735:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800738:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	eb 05                	jmp    800748 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800743:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800748:	c9                   	leave  
  800749:	c3                   	ret    

0080074a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800750:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800753:	50                   	push   %eax
  800754:	ff 75 10             	pushl  0x10(%ebp)
  800757:	ff 75 0c             	pushl  0xc(%ebp)
  80075a:	ff 75 08             	pushl  0x8(%ebp)
  80075d:	e8 9a ff ff ff       	call   8006fc <vsnprintf>
	va_end(ap);

	return rc;
}
  800762:	c9                   	leave  
  800763:	c3                   	ret    

00800764 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80076a:	b8 00 00 00 00       	mov    $0x0,%eax
  80076f:	eb 03                	jmp    800774 <strlen+0x10>
		n++;
  800771:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800774:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800778:	75 f7                	jne    800771 <strlen+0xd>
		n++;
	return n;
}
  80077a:	5d                   	pop    %ebp
  80077b:	c3                   	ret    

0080077c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800782:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800785:	ba 00 00 00 00       	mov    $0x0,%edx
  80078a:	eb 03                	jmp    80078f <strnlen+0x13>
		n++;
  80078c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078f:	39 c2                	cmp    %eax,%edx
  800791:	74 08                	je     80079b <strnlen+0x1f>
  800793:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800797:	75 f3                	jne    80078c <strnlen+0x10>
  800799:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	53                   	push   %ebx
  8007a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a7:	89 c2                	mov    %eax,%edx
  8007a9:	83 c2 01             	add    $0x1,%edx
  8007ac:	83 c1 01             	add    $0x1,%ecx
  8007af:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007b3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b6:	84 db                	test   %bl,%bl
  8007b8:	75 ef                	jne    8007a9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ba:	5b                   	pop    %ebx
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	53                   	push   %ebx
  8007c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c4:	53                   	push   %ebx
  8007c5:	e8 9a ff ff ff       	call   800764 <strlen>
  8007ca:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007cd:	ff 75 0c             	pushl  0xc(%ebp)
  8007d0:	01 d8                	add    %ebx,%eax
  8007d2:	50                   	push   %eax
  8007d3:	e8 c5 ff ff ff       	call   80079d <strcpy>
	return dst;
}
  8007d8:	89 d8                	mov    %ebx,%eax
  8007da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007dd:	c9                   	leave  
  8007de:	c3                   	ret    

008007df <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	56                   	push   %esi
  8007e3:	53                   	push   %ebx
  8007e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ea:	89 f3                	mov    %esi,%ebx
  8007ec:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ef:	89 f2                	mov    %esi,%edx
  8007f1:	eb 0f                	jmp    800802 <strncpy+0x23>
		*dst++ = *src;
  8007f3:	83 c2 01             	add    $0x1,%edx
  8007f6:	0f b6 01             	movzbl (%ecx),%eax
  8007f9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007fc:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ff:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800802:	39 da                	cmp    %ebx,%edx
  800804:	75 ed                	jne    8007f3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800806:	89 f0                	mov    %esi,%eax
  800808:	5b                   	pop    %ebx
  800809:	5e                   	pop    %esi
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	56                   	push   %esi
  800810:	53                   	push   %ebx
  800811:	8b 75 08             	mov    0x8(%ebp),%esi
  800814:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800817:	8b 55 10             	mov    0x10(%ebp),%edx
  80081a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081c:	85 d2                	test   %edx,%edx
  80081e:	74 21                	je     800841 <strlcpy+0x35>
  800820:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800824:	89 f2                	mov    %esi,%edx
  800826:	eb 09                	jmp    800831 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800828:	83 c2 01             	add    $0x1,%edx
  80082b:	83 c1 01             	add    $0x1,%ecx
  80082e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800831:	39 c2                	cmp    %eax,%edx
  800833:	74 09                	je     80083e <strlcpy+0x32>
  800835:	0f b6 19             	movzbl (%ecx),%ebx
  800838:	84 db                	test   %bl,%bl
  80083a:	75 ec                	jne    800828 <strlcpy+0x1c>
  80083c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80083e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800841:	29 f0                	sub    %esi,%eax
}
  800843:	5b                   	pop    %ebx
  800844:	5e                   	pop    %esi
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800850:	eb 06                	jmp    800858 <strcmp+0x11>
		p++, q++;
  800852:	83 c1 01             	add    $0x1,%ecx
  800855:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800858:	0f b6 01             	movzbl (%ecx),%eax
  80085b:	84 c0                	test   %al,%al
  80085d:	74 04                	je     800863 <strcmp+0x1c>
  80085f:	3a 02                	cmp    (%edx),%al
  800861:	74 ef                	je     800852 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800863:	0f b6 c0             	movzbl %al,%eax
  800866:	0f b6 12             	movzbl (%edx),%edx
  800869:	29 d0                	sub    %edx,%eax
}
  80086b:	5d                   	pop    %ebp
  80086c:	c3                   	ret    

0080086d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	53                   	push   %ebx
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	8b 55 0c             	mov    0xc(%ebp),%edx
  800877:	89 c3                	mov    %eax,%ebx
  800879:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80087c:	eb 06                	jmp    800884 <strncmp+0x17>
		n--, p++, q++;
  80087e:	83 c0 01             	add    $0x1,%eax
  800881:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800884:	39 d8                	cmp    %ebx,%eax
  800886:	74 15                	je     80089d <strncmp+0x30>
  800888:	0f b6 08             	movzbl (%eax),%ecx
  80088b:	84 c9                	test   %cl,%cl
  80088d:	74 04                	je     800893 <strncmp+0x26>
  80088f:	3a 0a                	cmp    (%edx),%cl
  800891:	74 eb                	je     80087e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800893:	0f b6 00             	movzbl (%eax),%eax
  800896:	0f b6 12             	movzbl (%edx),%edx
  800899:	29 d0                	sub    %edx,%eax
  80089b:	eb 05                	jmp    8008a2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a2:	5b                   	pop    %ebx
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008af:	eb 07                	jmp    8008b8 <strchr+0x13>
		if (*s == c)
  8008b1:	38 ca                	cmp    %cl,%dl
  8008b3:	74 0f                	je     8008c4 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b5:	83 c0 01             	add    $0x1,%eax
  8008b8:	0f b6 10             	movzbl (%eax),%edx
  8008bb:	84 d2                	test   %dl,%dl
  8008bd:	75 f2                	jne    8008b1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d0:	eb 03                	jmp    8008d5 <strfind+0xf>
  8008d2:	83 c0 01             	add    $0x1,%eax
  8008d5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d8:	38 ca                	cmp    %cl,%dl
  8008da:	74 04                	je     8008e0 <strfind+0x1a>
  8008dc:	84 d2                	test   %dl,%dl
  8008de:	75 f2                	jne    8008d2 <strfind+0xc>
			break;
	return (char *) s;
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	57                   	push   %edi
  8008e6:	56                   	push   %esi
  8008e7:	53                   	push   %ebx
  8008e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008ee:	85 c9                	test   %ecx,%ecx
  8008f0:	74 36                	je     800928 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f8:	75 28                	jne    800922 <memset+0x40>
  8008fa:	f6 c1 03             	test   $0x3,%cl
  8008fd:	75 23                	jne    800922 <memset+0x40>
		c &= 0xFF;
  8008ff:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800903:	89 d3                	mov    %edx,%ebx
  800905:	c1 e3 08             	shl    $0x8,%ebx
  800908:	89 d6                	mov    %edx,%esi
  80090a:	c1 e6 18             	shl    $0x18,%esi
  80090d:	89 d0                	mov    %edx,%eax
  80090f:	c1 e0 10             	shl    $0x10,%eax
  800912:	09 f0                	or     %esi,%eax
  800914:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800916:	89 d8                	mov    %ebx,%eax
  800918:	09 d0                	or     %edx,%eax
  80091a:	c1 e9 02             	shr    $0x2,%ecx
  80091d:	fc                   	cld    
  80091e:	f3 ab                	rep stos %eax,%es:(%edi)
  800920:	eb 06                	jmp    800928 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800922:	8b 45 0c             	mov    0xc(%ebp),%eax
  800925:	fc                   	cld    
  800926:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800928:	89 f8                	mov    %edi,%eax
  80092a:	5b                   	pop    %ebx
  80092b:	5e                   	pop    %esi
  80092c:	5f                   	pop    %edi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	57                   	push   %edi
  800933:	56                   	push   %esi
  800934:	8b 45 08             	mov    0x8(%ebp),%eax
  800937:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80093d:	39 c6                	cmp    %eax,%esi
  80093f:	73 35                	jae    800976 <memmove+0x47>
  800941:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800944:	39 d0                	cmp    %edx,%eax
  800946:	73 2e                	jae    800976 <memmove+0x47>
		s += n;
		d += n;
  800948:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094b:	89 d6                	mov    %edx,%esi
  80094d:	09 fe                	or     %edi,%esi
  80094f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800955:	75 13                	jne    80096a <memmove+0x3b>
  800957:	f6 c1 03             	test   $0x3,%cl
  80095a:	75 0e                	jne    80096a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80095c:	83 ef 04             	sub    $0x4,%edi
  80095f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800962:	c1 e9 02             	shr    $0x2,%ecx
  800965:	fd                   	std    
  800966:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800968:	eb 09                	jmp    800973 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80096a:	83 ef 01             	sub    $0x1,%edi
  80096d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800970:	fd                   	std    
  800971:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800973:	fc                   	cld    
  800974:	eb 1d                	jmp    800993 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800976:	89 f2                	mov    %esi,%edx
  800978:	09 c2                	or     %eax,%edx
  80097a:	f6 c2 03             	test   $0x3,%dl
  80097d:	75 0f                	jne    80098e <memmove+0x5f>
  80097f:	f6 c1 03             	test   $0x3,%cl
  800982:	75 0a                	jne    80098e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800984:	c1 e9 02             	shr    $0x2,%ecx
  800987:	89 c7                	mov    %eax,%edi
  800989:	fc                   	cld    
  80098a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098c:	eb 05                	jmp    800993 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80098e:	89 c7                	mov    %eax,%edi
  800990:	fc                   	cld    
  800991:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800993:	5e                   	pop    %esi
  800994:	5f                   	pop    %edi
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80099a:	ff 75 10             	pushl  0x10(%ebp)
  80099d:	ff 75 0c             	pushl  0xc(%ebp)
  8009a0:	ff 75 08             	pushl  0x8(%ebp)
  8009a3:	e8 87 ff ff ff       	call   80092f <memmove>
}
  8009a8:	c9                   	leave  
  8009a9:	c3                   	ret    

008009aa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	56                   	push   %esi
  8009ae:	53                   	push   %ebx
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b5:	89 c6                	mov    %eax,%esi
  8009b7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ba:	eb 1a                	jmp    8009d6 <memcmp+0x2c>
		if (*s1 != *s2)
  8009bc:	0f b6 08             	movzbl (%eax),%ecx
  8009bf:	0f b6 1a             	movzbl (%edx),%ebx
  8009c2:	38 d9                	cmp    %bl,%cl
  8009c4:	74 0a                	je     8009d0 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c6:	0f b6 c1             	movzbl %cl,%eax
  8009c9:	0f b6 db             	movzbl %bl,%ebx
  8009cc:	29 d8                	sub    %ebx,%eax
  8009ce:	eb 0f                	jmp    8009df <memcmp+0x35>
		s1++, s2++;
  8009d0:	83 c0 01             	add    $0x1,%eax
  8009d3:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d6:	39 f0                	cmp    %esi,%eax
  8009d8:	75 e2                	jne    8009bc <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009df:	5b                   	pop    %ebx
  8009e0:	5e                   	pop    %esi
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	53                   	push   %ebx
  8009e7:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009ea:	89 c1                	mov    %eax,%ecx
  8009ec:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ef:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f3:	eb 0a                	jmp    8009ff <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f5:	0f b6 10             	movzbl (%eax),%edx
  8009f8:	39 da                	cmp    %ebx,%edx
  8009fa:	74 07                	je     800a03 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009fc:	83 c0 01             	add    $0x1,%eax
  8009ff:	39 c8                	cmp    %ecx,%eax
  800a01:	72 f2                	jb     8009f5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a03:	5b                   	pop    %ebx
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	57                   	push   %edi
  800a0a:	56                   	push   %esi
  800a0b:	53                   	push   %ebx
  800a0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a12:	eb 03                	jmp    800a17 <strtol+0x11>
		s++;
  800a14:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a17:	0f b6 01             	movzbl (%ecx),%eax
  800a1a:	3c 20                	cmp    $0x20,%al
  800a1c:	74 f6                	je     800a14 <strtol+0xe>
  800a1e:	3c 09                	cmp    $0x9,%al
  800a20:	74 f2                	je     800a14 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a22:	3c 2b                	cmp    $0x2b,%al
  800a24:	75 0a                	jne    800a30 <strtol+0x2a>
		s++;
  800a26:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a29:	bf 00 00 00 00       	mov    $0x0,%edi
  800a2e:	eb 11                	jmp    800a41 <strtol+0x3b>
  800a30:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a35:	3c 2d                	cmp    $0x2d,%al
  800a37:	75 08                	jne    800a41 <strtol+0x3b>
		s++, neg = 1;
  800a39:	83 c1 01             	add    $0x1,%ecx
  800a3c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a41:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a47:	75 15                	jne    800a5e <strtol+0x58>
  800a49:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4c:	75 10                	jne    800a5e <strtol+0x58>
  800a4e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a52:	75 7c                	jne    800ad0 <strtol+0xca>
		s += 2, base = 16;
  800a54:	83 c1 02             	add    $0x2,%ecx
  800a57:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a5c:	eb 16                	jmp    800a74 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a5e:	85 db                	test   %ebx,%ebx
  800a60:	75 12                	jne    800a74 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a62:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a67:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6a:	75 08                	jne    800a74 <strtol+0x6e>
		s++, base = 8;
  800a6c:	83 c1 01             	add    $0x1,%ecx
  800a6f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a74:	b8 00 00 00 00       	mov    $0x0,%eax
  800a79:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a7c:	0f b6 11             	movzbl (%ecx),%edx
  800a7f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a82:	89 f3                	mov    %esi,%ebx
  800a84:	80 fb 09             	cmp    $0x9,%bl
  800a87:	77 08                	ja     800a91 <strtol+0x8b>
			dig = *s - '0';
  800a89:	0f be d2             	movsbl %dl,%edx
  800a8c:	83 ea 30             	sub    $0x30,%edx
  800a8f:	eb 22                	jmp    800ab3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a91:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a94:	89 f3                	mov    %esi,%ebx
  800a96:	80 fb 19             	cmp    $0x19,%bl
  800a99:	77 08                	ja     800aa3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a9b:	0f be d2             	movsbl %dl,%edx
  800a9e:	83 ea 57             	sub    $0x57,%edx
  800aa1:	eb 10                	jmp    800ab3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aa3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa6:	89 f3                	mov    %esi,%ebx
  800aa8:	80 fb 19             	cmp    $0x19,%bl
  800aab:	77 16                	ja     800ac3 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aad:	0f be d2             	movsbl %dl,%edx
  800ab0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ab3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab6:	7d 0b                	jge    800ac3 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab8:	83 c1 01             	add    $0x1,%ecx
  800abb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800abf:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ac1:	eb b9                	jmp    800a7c <strtol+0x76>

	if (endptr)
  800ac3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac7:	74 0d                	je     800ad6 <strtol+0xd0>
		*endptr = (char *) s;
  800ac9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800acc:	89 0e                	mov    %ecx,(%esi)
  800ace:	eb 06                	jmp    800ad6 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad0:	85 db                	test   %ebx,%ebx
  800ad2:	74 98                	je     800a6c <strtol+0x66>
  800ad4:	eb 9e                	jmp    800a74 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad6:	89 c2                	mov    %eax,%edx
  800ad8:	f7 da                	neg    %edx
  800ada:	85 ff                	test   %edi,%edi
  800adc:	0f 45 c2             	cmovne %edx,%eax
}
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800aea:	b8 00 00 00 00       	mov    $0x0,%eax
  800aef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af2:	8b 55 08             	mov    0x8(%ebp),%edx
  800af5:	89 c3                	mov    %eax,%ebx
  800af7:	89 c7                	mov    %eax,%edi
  800af9:	89 c6                	mov    %eax,%esi
  800afb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b08:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b12:	89 d1                	mov    %edx,%ecx
  800b14:	89 d3                	mov    %edx,%ebx
  800b16:	89 d7                	mov    %edx,%edi
  800b18:	89 d6                	mov    %edx,%esi
  800b1a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	53                   	push   %ebx
  800b27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b34:	8b 55 08             	mov    0x8(%ebp),%edx
  800b37:	89 cb                	mov    %ecx,%ebx
  800b39:	89 cf                	mov    %ecx,%edi
  800b3b:	89 ce                	mov    %ecx,%esi
  800b3d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3f:	85 c0                	test   %eax,%eax
  800b41:	7e 17                	jle    800b5a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b43:	83 ec 0c             	sub    $0xc,%esp
  800b46:	50                   	push   %eax
  800b47:	6a 03                	push   $0x3
  800b49:	68 e8 12 80 00       	push   $0x8012e8
  800b4e:	6a 23                	push   $0x23
  800b50:	68 05 13 80 00       	push   $0x801305
  800b55:	e8 23 02 00 00       	call   800d7d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b68:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6d:	b8 02 00 00 00       	mov    $0x2,%eax
  800b72:	89 d1                	mov    %edx,%ecx
  800b74:	89 d3                	mov    %edx,%ebx
  800b76:	89 d7                	mov    %edx,%edi
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <sys_yield>:

void
sys_yield(void)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b87:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b91:	89 d1                	mov    %edx,%ecx
  800b93:	89 d3                	mov    %edx,%ebx
  800b95:	89 d7                	mov    %edx,%edi
  800b97:	89 d6                	mov    %edx,%esi
  800b99:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
  800ba6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	be 00 00 00 00       	mov    $0x0,%esi
  800bae:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbc:	89 f7                	mov    %esi,%edi
  800bbe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	7e 17                	jle    800bdb <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc4:	83 ec 0c             	sub    $0xc,%esp
  800bc7:	50                   	push   %eax
  800bc8:	6a 04                	push   $0x4
  800bca:	68 e8 12 80 00       	push   $0x8012e8
  800bcf:	6a 23                	push   $0x23
  800bd1:	68 05 13 80 00       	push   $0x801305
  800bd6:	e8 a2 01 00 00       	call   800d7d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bec:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfa:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bfd:	8b 75 18             	mov    0x18(%ebp),%esi
  800c00:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c02:	85 c0                	test   %eax,%eax
  800c04:	7e 17                	jle    800c1d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c06:	83 ec 0c             	sub    $0xc,%esp
  800c09:	50                   	push   %eax
  800c0a:	6a 05                	push   $0x5
  800c0c:	68 e8 12 80 00       	push   $0x8012e8
  800c11:	6a 23                	push   $0x23
  800c13:	68 05 13 80 00       	push   $0x801305
  800c18:	e8 60 01 00 00       	call   800d7d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
  800c2b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c33:	b8 06 00 00 00       	mov    $0x6,%eax
  800c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3e:	89 df                	mov    %ebx,%edi
  800c40:	89 de                	mov    %ebx,%esi
  800c42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c44:	85 c0                	test   %eax,%eax
  800c46:	7e 17                	jle    800c5f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c48:	83 ec 0c             	sub    $0xc,%esp
  800c4b:	50                   	push   %eax
  800c4c:	6a 06                	push   $0x6
  800c4e:	68 e8 12 80 00       	push   $0x8012e8
  800c53:	6a 23                	push   $0x23
  800c55:	68 05 13 80 00       	push   $0x801305
  800c5a:	e8 1e 01 00 00       	call   800d7d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c75:	b8 08 00 00 00       	mov    $0x8,%eax
  800c7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c80:	89 df                	mov    %ebx,%edi
  800c82:	89 de                	mov    %ebx,%esi
  800c84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c86:	85 c0                	test   %eax,%eax
  800c88:	7e 17                	jle    800ca1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8a:	83 ec 0c             	sub    $0xc,%esp
  800c8d:	50                   	push   %eax
  800c8e:	6a 08                	push   $0x8
  800c90:	68 e8 12 80 00       	push   $0x8012e8
  800c95:	6a 23                	push   $0x23
  800c97:	68 05 13 80 00       	push   $0x801305
  800c9c:	e8 dc 00 00 00       	call   800d7d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
  800caf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb7:	b8 09 00 00 00       	mov    $0x9,%eax
  800cbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc2:	89 df                	mov    %ebx,%edi
  800cc4:	89 de                	mov    %ebx,%esi
  800cc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc8:	85 c0                	test   %eax,%eax
  800cca:	7e 17                	jle    800ce3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccc:	83 ec 0c             	sub    $0xc,%esp
  800ccf:	50                   	push   %eax
  800cd0:	6a 09                	push   $0x9
  800cd2:	68 e8 12 80 00       	push   $0x8012e8
  800cd7:	6a 23                	push   $0x23
  800cd9:	68 05 13 80 00       	push   $0x801305
  800cde:	e8 9a 00 00 00       	call   800d7d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    

00800ceb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	57                   	push   %edi
  800cef:	56                   	push   %esi
  800cf0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf1:	be 00 00 00 00       	mov    $0x0,%esi
  800cf6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d04:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d07:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	89 cb                	mov    %ecx,%ebx
  800d26:	89 cf                	mov    %ecx,%edi
  800d28:	89 ce                	mov    %ecx,%esi
  800d2a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7e 17                	jle    800d47 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	50                   	push   %eax
  800d34:	6a 0c                	push   $0xc
  800d36:	68 e8 12 80 00       	push   $0x8012e8
  800d3b:	6a 23                	push   $0x23
  800d3d:	68 05 13 80 00       	push   $0x801305
  800d42:	e8 36 00 00 00       	call   800d7d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800d55:	68 1f 13 80 00       	push   $0x80131f
  800d5a:	6a 51                	push   $0x51
  800d5c:	68 13 13 80 00       	push   $0x801313
  800d61:	e8 17 00 00 00       	call   800d7d <_panic>

00800d66 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800d6c:	68 1e 13 80 00       	push   $0x80131e
  800d71:	6a 58                	push   $0x58
  800d73:	68 13 13 80 00       	push   $0x801313
  800d78:	e8 00 00 00 00       	call   800d7d <_panic>

00800d7d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d82:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d85:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d8b:	e8 d2 fd ff ff       	call   800b62 <sys_getenvid>
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	ff 75 0c             	pushl  0xc(%ebp)
  800d96:	ff 75 08             	pushl  0x8(%ebp)
  800d99:	56                   	push   %esi
  800d9a:	50                   	push   %eax
  800d9b:	68 34 13 80 00       	push   $0x801334
  800da0:	e8 31 f4 ff ff       	call   8001d6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800da5:	83 c4 18             	add    $0x18,%esp
  800da8:	53                   	push   %ebx
  800da9:	ff 75 10             	pushl  0x10(%ebp)
  800dac:	e8 d4 f3 ff ff       	call   800185 <vcprintf>
	cprintf("\n");
  800db1:	c7 04 24 6f 10 80 00 	movl   $0x80106f,(%esp)
  800db8:	e8 19 f4 ff ff       	call   8001d6 <cprintf>
  800dbd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dc0:	cc                   	int3   
  800dc1:	eb fd                	jmp    800dc0 <_panic+0x43>
  800dc3:	66 90                	xchg   %ax,%ax
  800dc5:	66 90                	xchg   %ax,%ax
  800dc7:	66 90                	xchg   %ax,%ax
  800dc9:	66 90                	xchg   %ax,%ax
  800dcb:	66 90                	xchg   %ax,%ax
  800dcd:	66 90                	xchg   %ax,%ax
  800dcf:	90                   	nop

00800dd0 <__udivdi3>:
  800dd0:	55                   	push   %ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 1c             	sub    $0x1c,%esp
  800dd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800ddb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800ddf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800de3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800de7:	85 f6                	test   %esi,%esi
  800de9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ded:	89 ca                	mov    %ecx,%edx
  800def:	89 f8                	mov    %edi,%eax
  800df1:	75 3d                	jne    800e30 <__udivdi3+0x60>
  800df3:	39 cf                	cmp    %ecx,%edi
  800df5:	0f 87 c5 00 00 00    	ja     800ec0 <__udivdi3+0xf0>
  800dfb:	85 ff                	test   %edi,%edi
  800dfd:	89 fd                	mov    %edi,%ebp
  800dff:	75 0b                	jne    800e0c <__udivdi3+0x3c>
  800e01:	b8 01 00 00 00       	mov    $0x1,%eax
  800e06:	31 d2                	xor    %edx,%edx
  800e08:	f7 f7                	div    %edi
  800e0a:	89 c5                	mov    %eax,%ebp
  800e0c:	89 c8                	mov    %ecx,%eax
  800e0e:	31 d2                	xor    %edx,%edx
  800e10:	f7 f5                	div    %ebp
  800e12:	89 c1                	mov    %eax,%ecx
  800e14:	89 d8                	mov    %ebx,%eax
  800e16:	89 cf                	mov    %ecx,%edi
  800e18:	f7 f5                	div    %ebp
  800e1a:	89 c3                	mov    %eax,%ebx
  800e1c:	89 d8                	mov    %ebx,%eax
  800e1e:	89 fa                	mov    %edi,%edx
  800e20:	83 c4 1c             	add    $0x1c,%esp
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    
  800e28:	90                   	nop
  800e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e30:	39 ce                	cmp    %ecx,%esi
  800e32:	77 74                	ja     800ea8 <__udivdi3+0xd8>
  800e34:	0f bd fe             	bsr    %esi,%edi
  800e37:	83 f7 1f             	xor    $0x1f,%edi
  800e3a:	0f 84 98 00 00 00    	je     800ed8 <__udivdi3+0x108>
  800e40:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e45:	89 f9                	mov    %edi,%ecx
  800e47:	89 c5                	mov    %eax,%ebp
  800e49:	29 fb                	sub    %edi,%ebx
  800e4b:	d3 e6                	shl    %cl,%esi
  800e4d:	89 d9                	mov    %ebx,%ecx
  800e4f:	d3 ed                	shr    %cl,%ebp
  800e51:	89 f9                	mov    %edi,%ecx
  800e53:	d3 e0                	shl    %cl,%eax
  800e55:	09 ee                	or     %ebp,%esi
  800e57:	89 d9                	mov    %ebx,%ecx
  800e59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e5d:	89 d5                	mov    %edx,%ebp
  800e5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e63:	d3 ed                	shr    %cl,%ebp
  800e65:	89 f9                	mov    %edi,%ecx
  800e67:	d3 e2                	shl    %cl,%edx
  800e69:	89 d9                	mov    %ebx,%ecx
  800e6b:	d3 e8                	shr    %cl,%eax
  800e6d:	09 c2                	or     %eax,%edx
  800e6f:	89 d0                	mov    %edx,%eax
  800e71:	89 ea                	mov    %ebp,%edx
  800e73:	f7 f6                	div    %esi
  800e75:	89 d5                	mov    %edx,%ebp
  800e77:	89 c3                	mov    %eax,%ebx
  800e79:	f7 64 24 0c          	mull   0xc(%esp)
  800e7d:	39 d5                	cmp    %edx,%ebp
  800e7f:	72 10                	jb     800e91 <__udivdi3+0xc1>
  800e81:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e85:	89 f9                	mov    %edi,%ecx
  800e87:	d3 e6                	shl    %cl,%esi
  800e89:	39 c6                	cmp    %eax,%esi
  800e8b:	73 07                	jae    800e94 <__udivdi3+0xc4>
  800e8d:	39 d5                	cmp    %edx,%ebp
  800e8f:	75 03                	jne    800e94 <__udivdi3+0xc4>
  800e91:	83 eb 01             	sub    $0x1,%ebx
  800e94:	31 ff                	xor    %edi,%edi
  800e96:	89 d8                	mov    %ebx,%eax
  800e98:	89 fa                	mov    %edi,%edx
  800e9a:	83 c4 1c             	add    $0x1c,%esp
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    
  800ea2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ea8:	31 ff                	xor    %edi,%edi
  800eaa:	31 db                	xor    %ebx,%ebx
  800eac:	89 d8                	mov    %ebx,%eax
  800eae:	89 fa                	mov    %edi,%edx
  800eb0:	83 c4 1c             	add    $0x1c,%esp
  800eb3:	5b                   	pop    %ebx
  800eb4:	5e                   	pop    %esi
  800eb5:	5f                   	pop    %edi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    
  800eb8:	90                   	nop
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	89 d8                	mov    %ebx,%eax
  800ec2:	f7 f7                	div    %edi
  800ec4:	31 ff                	xor    %edi,%edi
  800ec6:	89 c3                	mov    %eax,%ebx
  800ec8:	89 d8                	mov    %ebx,%eax
  800eca:	89 fa                	mov    %edi,%edx
  800ecc:	83 c4 1c             	add    $0x1c,%esp
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    
  800ed4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ed8:	39 ce                	cmp    %ecx,%esi
  800eda:	72 0c                	jb     800ee8 <__udivdi3+0x118>
  800edc:	31 db                	xor    %ebx,%ebx
  800ede:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ee2:	0f 87 34 ff ff ff    	ja     800e1c <__udivdi3+0x4c>
  800ee8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800eed:	e9 2a ff ff ff       	jmp    800e1c <__udivdi3+0x4c>
  800ef2:	66 90                	xchg   %ax,%ax
  800ef4:	66 90                	xchg   %ax,%ax
  800ef6:	66 90                	xchg   %ax,%ax
  800ef8:	66 90                	xchg   %ax,%ax
  800efa:	66 90                	xchg   %ax,%ax
  800efc:	66 90                	xchg   %ax,%ax
  800efe:	66 90                	xchg   %ax,%ax

00800f00 <__umoddi3>:
  800f00:	55                   	push   %ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 1c             	sub    $0x1c,%esp
  800f07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f17:	85 d2                	test   %edx,%edx
  800f19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f21:	89 f3                	mov    %esi,%ebx
  800f23:	89 3c 24             	mov    %edi,(%esp)
  800f26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f2a:	75 1c                	jne    800f48 <__umoddi3+0x48>
  800f2c:	39 f7                	cmp    %esi,%edi
  800f2e:	76 50                	jbe    800f80 <__umoddi3+0x80>
  800f30:	89 c8                	mov    %ecx,%eax
  800f32:	89 f2                	mov    %esi,%edx
  800f34:	f7 f7                	div    %edi
  800f36:	89 d0                	mov    %edx,%eax
  800f38:	31 d2                	xor    %edx,%edx
  800f3a:	83 c4 1c             	add    $0x1c,%esp
  800f3d:	5b                   	pop    %ebx
  800f3e:	5e                   	pop    %esi
  800f3f:	5f                   	pop    %edi
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    
  800f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f48:	39 f2                	cmp    %esi,%edx
  800f4a:	89 d0                	mov    %edx,%eax
  800f4c:	77 52                	ja     800fa0 <__umoddi3+0xa0>
  800f4e:	0f bd ea             	bsr    %edx,%ebp
  800f51:	83 f5 1f             	xor    $0x1f,%ebp
  800f54:	75 5a                	jne    800fb0 <__umoddi3+0xb0>
  800f56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f5a:	0f 82 e0 00 00 00    	jb     801040 <__umoddi3+0x140>
  800f60:	39 0c 24             	cmp    %ecx,(%esp)
  800f63:	0f 86 d7 00 00 00    	jbe    801040 <__umoddi3+0x140>
  800f69:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f71:	83 c4 1c             	add    $0x1c,%esp
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    
  800f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f80:	85 ff                	test   %edi,%edi
  800f82:	89 fd                	mov    %edi,%ebp
  800f84:	75 0b                	jne    800f91 <__umoddi3+0x91>
  800f86:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8b:	31 d2                	xor    %edx,%edx
  800f8d:	f7 f7                	div    %edi
  800f8f:	89 c5                	mov    %eax,%ebp
  800f91:	89 f0                	mov    %esi,%eax
  800f93:	31 d2                	xor    %edx,%edx
  800f95:	f7 f5                	div    %ebp
  800f97:	89 c8                	mov    %ecx,%eax
  800f99:	f7 f5                	div    %ebp
  800f9b:	89 d0                	mov    %edx,%eax
  800f9d:	eb 99                	jmp    800f38 <__umoddi3+0x38>
  800f9f:	90                   	nop
  800fa0:	89 c8                	mov    %ecx,%eax
  800fa2:	89 f2                	mov    %esi,%edx
  800fa4:	83 c4 1c             	add    $0x1c,%esp
  800fa7:	5b                   	pop    %ebx
  800fa8:	5e                   	pop    %esi
  800fa9:	5f                   	pop    %edi
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    
  800fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	8b 34 24             	mov    (%esp),%esi
  800fb3:	bf 20 00 00 00       	mov    $0x20,%edi
  800fb8:	89 e9                	mov    %ebp,%ecx
  800fba:	29 ef                	sub    %ebp,%edi
  800fbc:	d3 e0                	shl    %cl,%eax
  800fbe:	89 f9                	mov    %edi,%ecx
  800fc0:	89 f2                	mov    %esi,%edx
  800fc2:	d3 ea                	shr    %cl,%edx
  800fc4:	89 e9                	mov    %ebp,%ecx
  800fc6:	09 c2                	or     %eax,%edx
  800fc8:	89 d8                	mov    %ebx,%eax
  800fca:	89 14 24             	mov    %edx,(%esp)
  800fcd:	89 f2                	mov    %esi,%edx
  800fcf:	d3 e2                	shl    %cl,%edx
  800fd1:	89 f9                	mov    %edi,%ecx
  800fd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fdb:	d3 e8                	shr    %cl,%eax
  800fdd:	89 e9                	mov    %ebp,%ecx
  800fdf:	89 c6                	mov    %eax,%esi
  800fe1:	d3 e3                	shl    %cl,%ebx
  800fe3:	89 f9                	mov    %edi,%ecx
  800fe5:	89 d0                	mov    %edx,%eax
  800fe7:	d3 e8                	shr    %cl,%eax
  800fe9:	89 e9                	mov    %ebp,%ecx
  800feb:	09 d8                	or     %ebx,%eax
  800fed:	89 d3                	mov    %edx,%ebx
  800fef:	89 f2                	mov    %esi,%edx
  800ff1:	f7 34 24             	divl   (%esp)
  800ff4:	89 d6                	mov    %edx,%esi
  800ff6:	d3 e3                	shl    %cl,%ebx
  800ff8:	f7 64 24 04          	mull   0x4(%esp)
  800ffc:	39 d6                	cmp    %edx,%esi
  800ffe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801002:	89 d1                	mov    %edx,%ecx
  801004:	89 c3                	mov    %eax,%ebx
  801006:	72 08                	jb     801010 <__umoddi3+0x110>
  801008:	75 11                	jne    80101b <__umoddi3+0x11b>
  80100a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80100e:	73 0b                	jae    80101b <__umoddi3+0x11b>
  801010:	2b 44 24 04          	sub    0x4(%esp),%eax
  801014:	1b 14 24             	sbb    (%esp),%edx
  801017:	89 d1                	mov    %edx,%ecx
  801019:	89 c3                	mov    %eax,%ebx
  80101b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80101f:	29 da                	sub    %ebx,%edx
  801021:	19 ce                	sbb    %ecx,%esi
  801023:	89 f9                	mov    %edi,%ecx
  801025:	89 f0                	mov    %esi,%eax
  801027:	d3 e0                	shl    %cl,%eax
  801029:	89 e9                	mov    %ebp,%ecx
  80102b:	d3 ea                	shr    %cl,%edx
  80102d:	89 e9                	mov    %ebp,%ecx
  80102f:	d3 ee                	shr    %cl,%esi
  801031:	09 d0                	or     %edx,%eax
  801033:	89 f2                	mov    %esi,%edx
  801035:	83 c4 1c             	add    $0x1c,%esp
  801038:	5b                   	pop    %ebx
  801039:	5e                   	pop    %esi
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    
  80103d:	8d 76 00             	lea    0x0(%esi),%esi
  801040:	29 f9                	sub    %edi,%ecx
  801042:	19 d6                	sbb    %edx,%esi
  801044:	89 74 24 04          	mov    %esi,0x4(%esp)
  801048:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80104c:	e9 18 ff ff ff       	jmp    800f69 <__umoddi3+0x69>
