
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 40 10 80 00       	push   $0x801040
  800045:	e8 a6 01 00 00       	call   8001f0 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 5c 0b 00 00       	call   800bba <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 60 10 80 00       	push   $0x801060
  80006f:	6a 0f                	push   $0xf
  800071:	68 4a 10 80 00       	push   $0x80104a
  800076:	e8 9c 00 00 00       	call   800117 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 8c 10 80 00       	push   $0x80108c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 db 06 00 00       	call   800764 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 c8 0c 00 00       	call   800d69 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 4e 0a 00 00       	call   800afe <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000c0:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000c7:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  8000ca:	e8 ad 0a 00 00       	call   800b7c <sys_getenvid>
  8000cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000dc:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e1:	85 db                	test   %ebx,%ebx
  8000e3:	7e 07                	jle    8000ec <libmain+0x37>
		binaryname = argv[0];
  8000e5:	8b 06                	mov    (%esi),%eax
  8000e7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ec:	83 ec 08             	sub    $0x8,%esp
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	e8 9b ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000f6:	e8 0a 00 00 00       	call   800105 <exit>
}
  8000fb:	83 c4 10             	add    $0x10,%esp
  8000fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800101:	5b                   	pop    %ebx
  800102:	5e                   	pop    %esi
  800103:	5d                   	pop    %ebp
  800104:	c3                   	ret    

00800105 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010b:	6a 00                	push   $0x0
  80010d:	e8 29 0a 00 00       	call   800b3b <sys_env_destroy>
}
  800112:	83 c4 10             	add    $0x10,%esp
  800115:	c9                   	leave  
  800116:	c3                   	ret    

00800117 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	56                   	push   %esi
  80011b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800125:	e8 52 0a 00 00       	call   800b7c <sys_getenvid>
  80012a:	83 ec 0c             	sub    $0xc,%esp
  80012d:	ff 75 0c             	pushl  0xc(%ebp)
  800130:	ff 75 08             	pushl  0x8(%ebp)
  800133:	56                   	push   %esi
  800134:	50                   	push   %eax
  800135:	68 b8 10 80 00       	push   $0x8010b8
  80013a:	e8 b1 00 00 00       	call   8001f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013f:	83 c4 18             	add    $0x18,%esp
  800142:	53                   	push   %ebx
  800143:	ff 75 10             	pushl  0x10(%ebp)
  800146:	e8 54 00 00 00       	call   80019f <vcprintf>
	cprintf("\n");
  80014b:	c7 04 24 0f 11 80 00 	movl   $0x80110f,(%esp)
  800152:	e8 99 00 00 00       	call   8001f0 <cprintf>
  800157:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80015a:	cc                   	int3   
  80015b:	eb fd                	jmp    80015a <_panic+0x43>

0080015d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	53                   	push   %ebx
  800161:	83 ec 04             	sub    $0x4,%esp
  800164:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800167:	8b 13                	mov    (%ebx),%edx
  800169:	8d 42 01             	lea    0x1(%edx),%eax
  80016c:	89 03                	mov    %eax,(%ebx)
  80016e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800171:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800175:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017a:	75 1a                	jne    800196 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017c:	83 ec 08             	sub    $0x8,%esp
  80017f:	68 ff 00 00 00       	push   $0xff
  800184:	8d 43 08             	lea    0x8(%ebx),%eax
  800187:	50                   	push   %eax
  800188:	e8 71 09 00 00       	call   800afe <sys_cputs>
		b->idx = 0;
  80018d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800193:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800196:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    

0080019f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001af:	00 00 00 
	b.cnt = 0;
  8001b2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bc:	ff 75 0c             	pushl  0xc(%ebp)
  8001bf:	ff 75 08             	pushl  0x8(%ebp)
  8001c2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c8:	50                   	push   %eax
  8001c9:	68 5d 01 80 00       	push   $0x80015d
  8001ce:	e8 54 01 00 00       	call   800327 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d3:	83 c4 08             	add    $0x8,%esp
  8001d6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e2:	50                   	push   %eax
  8001e3:	e8 16 09 00 00       	call   800afe <sys_cputs>

	return b.cnt;
}
  8001e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ee:	c9                   	leave  
  8001ef:	c3                   	ret    

008001f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f9:	50                   	push   %eax
  8001fa:	ff 75 08             	pushl  0x8(%ebp)
  8001fd:	e8 9d ff ff ff       	call   80019f <vcprintf>
	va_end(ap);

	return cnt;
}
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	57                   	push   %edi
  800208:	56                   	push   %esi
  800209:	53                   	push   %ebx
  80020a:	83 ec 1c             	sub    $0x1c,%esp
  80020d:	89 c7                	mov    %eax,%edi
  80020f:	89 d6                	mov    %edx,%esi
  800211:	8b 45 08             	mov    0x8(%ebp),%eax
  800214:	8b 55 0c             	mov    0xc(%ebp),%edx
  800217:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800220:	bb 00 00 00 00       	mov    $0x0,%ebx
  800225:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800228:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022b:	39 d3                	cmp    %edx,%ebx
  80022d:	72 05                	jb     800234 <printnum+0x30>
  80022f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800232:	77 45                	ja     800279 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 18             	pushl  0x18(%ebp)
  80023a:	8b 45 14             	mov    0x14(%ebp),%eax
  80023d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800240:	53                   	push   %ebx
  800241:	ff 75 10             	pushl  0x10(%ebp)
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024a:	ff 75 e0             	pushl  -0x20(%ebp)
  80024d:	ff 75 dc             	pushl  -0x24(%ebp)
  800250:	ff 75 d8             	pushl  -0x28(%ebp)
  800253:	e8 48 0b 00 00       	call   800da0 <__udivdi3>
  800258:	83 c4 18             	add    $0x18,%esp
  80025b:	52                   	push   %edx
  80025c:	50                   	push   %eax
  80025d:	89 f2                	mov    %esi,%edx
  80025f:	89 f8                	mov    %edi,%eax
  800261:	e8 9e ff ff ff       	call   800204 <printnum>
  800266:	83 c4 20             	add    $0x20,%esp
  800269:	eb 18                	jmp    800283 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026b:	83 ec 08             	sub    $0x8,%esp
  80026e:	56                   	push   %esi
  80026f:	ff 75 18             	pushl  0x18(%ebp)
  800272:	ff d7                	call   *%edi
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	eb 03                	jmp    80027c <printnum+0x78>
  800279:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027c:	83 eb 01             	sub    $0x1,%ebx
  80027f:	85 db                	test   %ebx,%ebx
  800281:	7f e8                	jg     80026b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800283:	83 ec 08             	sub    $0x8,%esp
  800286:	56                   	push   %esi
  800287:	83 ec 04             	sub    $0x4,%esp
  80028a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028d:	ff 75 e0             	pushl  -0x20(%ebp)
  800290:	ff 75 dc             	pushl  -0x24(%ebp)
  800293:	ff 75 d8             	pushl  -0x28(%ebp)
  800296:	e8 35 0c 00 00       	call   800ed0 <__umoddi3>
  80029b:	83 c4 14             	add    $0x14,%esp
  80029e:	0f be 80 db 10 80 00 	movsbl 0x8010db(%eax),%eax
  8002a5:	50                   	push   %eax
  8002a6:	ff d7                	call   *%edi
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5f                   	pop    %edi
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b6:	83 fa 01             	cmp    $0x1,%edx
  8002b9:	7e 0e                	jle    8002c9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c0:	89 08                	mov    %ecx,(%eax)
  8002c2:	8b 02                	mov    (%edx),%eax
  8002c4:	8b 52 04             	mov    0x4(%edx),%edx
  8002c7:	eb 22                	jmp    8002eb <getuint+0x38>
	else if (lflag)
  8002c9:	85 d2                	test   %edx,%edx
  8002cb:	74 10                	je     8002dd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002cd:	8b 10                	mov    (%eax),%edx
  8002cf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d2:	89 08                	mov    %ecx,(%eax)
  8002d4:	8b 02                	mov    (%edx),%eax
  8002d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002db:	eb 0e                	jmp    8002eb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002dd:	8b 10                	mov    (%eax),%edx
  8002df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e2:	89 08                	mov    %ecx,(%eax)
  8002e4:	8b 02                	mov    (%edx),%eax
  8002e6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002eb:	5d                   	pop    %ebp
  8002ec:	c3                   	ret    

008002ed <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f7:	8b 10                	mov    (%eax),%edx
  8002f9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fc:	73 0a                	jae    800308 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fe:	8d 4a 01             	lea    0x1(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 45 08             	mov    0x8(%ebp),%eax
  800306:	88 02                	mov    %al,(%edx)
}
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800310:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800313:	50                   	push   %eax
  800314:	ff 75 10             	pushl  0x10(%ebp)
  800317:	ff 75 0c             	pushl  0xc(%ebp)
  80031a:	ff 75 08             	pushl  0x8(%ebp)
  80031d:	e8 05 00 00 00       	call   800327 <vprintfmt>
	va_end(ap);
}
  800322:	83 c4 10             	add    $0x10,%esp
  800325:	c9                   	leave  
  800326:	c3                   	ret    

00800327 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	57                   	push   %edi
  80032b:	56                   	push   %esi
  80032c:	53                   	push   %ebx
  80032d:	83 ec 2c             	sub    $0x2c,%esp
  800330:	8b 75 08             	mov    0x8(%ebp),%esi
  800333:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800336:	8b 7d 10             	mov    0x10(%ebp),%edi
  800339:	eb 12                	jmp    80034d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80033b:	85 c0                	test   %eax,%eax
  80033d:	0f 84 cb 03 00 00    	je     80070e <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800343:	83 ec 08             	sub    $0x8,%esp
  800346:	53                   	push   %ebx
  800347:	50                   	push   %eax
  800348:	ff d6                	call   *%esi
  80034a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80034d:	83 c7 01             	add    $0x1,%edi
  800350:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800354:	83 f8 25             	cmp    $0x25,%eax
  800357:	75 e2                	jne    80033b <vprintfmt+0x14>
  800359:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80035d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800364:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80036b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800372:	ba 00 00 00 00       	mov    $0x0,%edx
  800377:	eb 07                	jmp    800380 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8d 47 01             	lea    0x1(%edi),%eax
  800383:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800386:	0f b6 07             	movzbl (%edi),%eax
  800389:	0f b6 c8             	movzbl %al,%ecx
  80038c:	83 e8 23             	sub    $0x23,%eax
  80038f:	3c 55                	cmp    $0x55,%al
  800391:	0f 87 5c 03 00 00    	ja     8006f3 <vprintfmt+0x3cc>
  800397:	0f b6 c0             	movzbl %al,%eax
  80039a:	ff 24 85 c0 11 80 00 	jmp    *0x8011c0(,%eax,4)
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a8:	eb d6                	jmp    800380 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003bc:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003bf:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c2:	83 fa 09             	cmp    $0x9,%edx
  8003c5:	77 39                	ja     800400 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ca:	eb e9                	jmp    8003b5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003d5:	8b 00                	mov    (%eax),%eax
  8003d7:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003dd:	eb 27                	jmp    800406 <vprintfmt+0xdf>
  8003df:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e2:	85 c0                	test   %eax,%eax
  8003e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e9:	0f 49 c8             	cmovns %eax,%ecx
  8003ec:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f2:	eb 8c                	jmp    800380 <vprintfmt+0x59>
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fe:	eb 80                	jmp    800380 <vprintfmt+0x59>
  800400:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800403:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800406:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040a:	0f 89 70 ff ff ff    	jns    800380 <vprintfmt+0x59>
				width = precision, precision = -1;
  800410:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800413:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800416:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80041d:	e9 5e ff ff ff       	jmp    800380 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800422:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800428:	e9 53 ff ff ff       	jmp    800380 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 50 04             	lea    0x4(%eax),%edx
  800433:	89 55 14             	mov    %edx,0x14(%ebp)
  800436:	83 ec 08             	sub    $0x8,%esp
  800439:	53                   	push   %ebx
  80043a:	ff 30                	pushl  (%eax)
  80043c:	ff d6                	call   *%esi
			break;
  80043e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800444:	e9 04 ff ff ff       	jmp    80034d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 50 04             	lea    0x4(%eax),%edx
  80044f:	89 55 14             	mov    %edx,0x14(%ebp)
  800452:	8b 00                	mov    (%eax),%eax
  800454:	99                   	cltd   
  800455:	31 d0                	xor    %edx,%eax
  800457:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800459:	83 f8 09             	cmp    $0x9,%eax
  80045c:	7f 0b                	jg     800469 <vprintfmt+0x142>
  80045e:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  800465:	85 d2                	test   %edx,%edx
  800467:	75 18                	jne    800481 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800469:	50                   	push   %eax
  80046a:	68 f3 10 80 00       	push   $0x8010f3
  80046f:	53                   	push   %ebx
  800470:	56                   	push   %esi
  800471:	e8 94 fe ff ff       	call   80030a <printfmt>
  800476:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047c:	e9 cc fe ff ff       	jmp    80034d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800481:	52                   	push   %edx
  800482:	68 fc 10 80 00       	push   $0x8010fc
  800487:	53                   	push   %ebx
  800488:	56                   	push   %esi
  800489:	e8 7c fe ff ff       	call   80030a <printfmt>
  80048e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800494:	e9 b4 fe ff ff       	jmp    80034d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800499:	8b 45 14             	mov    0x14(%ebp),%eax
  80049c:	8d 50 04             	lea    0x4(%eax),%edx
  80049f:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004a4:	85 ff                	test   %edi,%edi
  8004a6:	b8 ec 10 80 00       	mov    $0x8010ec,%eax
  8004ab:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b2:	0f 8e 94 00 00 00    	jle    80054c <vprintfmt+0x225>
  8004b8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004bc:	0f 84 98 00 00 00    	je     80055a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	ff 75 c8             	pushl  -0x38(%ebp)
  8004c8:	57                   	push   %edi
  8004c9:	e8 c8 02 00 00       	call   800796 <strnlen>
  8004ce:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d1:	29 c1                	sub    %eax,%ecx
  8004d3:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004d6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004e3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e5:	eb 0f                	jmp    8004f6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ee:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f0:	83 ef 01             	sub    $0x1,%edi
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	85 ff                	test   %edi,%edi
  8004f8:	7f ed                	jg     8004e7 <vprintfmt+0x1c0>
  8004fa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004fd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800500:	85 c9                	test   %ecx,%ecx
  800502:	b8 00 00 00 00       	mov    $0x0,%eax
  800507:	0f 49 c1             	cmovns %ecx,%eax
  80050a:	29 c1                	sub    %eax,%ecx
  80050c:	89 75 08             	mov    %esi,0x8(%ebp)
  80050f:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800512:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800515:	89 cb                	mov    %ecx,%ebx
  800517:	eb 4d                	jmp    800566 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800519:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80051d:	74 1b                	je     80053a <vprintfmt+0x213>
  80051f:	0f be c0             	movsbl %al,%eax
  800522:	83 e8 20             	sub    $0x20,%eax
  800525:	83 f8 5e             	cmp    $0x5e,%eax
  800528:	76 10                	jbe    80053a <vprintfmt+0x213>
					putch('?', putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	ff 75 0c             	pushl  0xc(%ebp)
  800530:	6a 3f                	push   $0x3f
  800532:	ff 55 08             	call   *0x8(%ebp)
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	eb 0d                	jmp    800547 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	ff 75 0c             	pushl  0xc(%ebp)
  800540:	52                   	push   %edx
  800541:	ff 55 08             	call   *0x8(%ebp)
  800544:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800547:	83 eb 01             	sub    $0x1,%ebx
  80054a:	eb 1a                	jmp    800566 <vprintfmt+0x23f>
  80054c:	89 75 08             	mov    %esi,0x8(%ebp)
  80054f:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800552:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800555:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800558:	eb 0c                	jmp    800566 <vprintfmt+0x23f>
  80055a:	89 75 08             	mov    %esi,0x8(%ebp)
  80055d:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800560:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800563:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800566:	83 c7 01             	add    $0x1,%edi
  800569:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056d:	0f be d0             	movsbl %al,%edx
  800570:	85 d2                	test   %edx,%edx
  800572:	74 23                	je     800597 <vprintfmt+0x270>
  800574:	85 f6                	test   %esi,%esi
  800576:	78 a1                	js     800519 <vprintfmt+0x1f2>
  800578:	83 ee 01             	sub    $0x1,%esi
  80057b:	79 9c                	jns    800519 <vprintfmt+0x1f2>
  80057d:	89 df                	mov    %ebx,%edi
  80057f:	8b 75 08             	mov    0x8(%ebp),%esi
  800582:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800585:	eb 18                	jmp    80059f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800587:	83 ec 08             	sub    $0x8,%esp
  80058a:	53                   	push   %ebx
  80058b:	6a 20                	push   $0x20
  80058d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058f:	83 ef 01             	sub    $0x1,%edi
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	eb 08                	jmp    80059f <vprintfmt+0x278>
  800597:	89 df                	mov    %ebx,%edi
  800599:	8b 75 08             	mov    0x8(%ebp),%esi
  80059c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059f:	85 ff                	test   %edi,%edi
  8005a1:	7f e4                	jg     800587 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a6:	e9 a2 fd ff ff       	jmp    80034d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ab:	83 fa 01             	cmp    $0x1,%edx
  8005ae:	7e 16                	jle    8005c6 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 50 08             	lea    0x8(%eax),%edx
  8005b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b9:	8b 50 04             	mov    0x4(%eax),%edx
  8005bc:	8b 00                	mov    (%eax),%eax
  8005be:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005c1:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005c4:	eb 32                	jmp    8005f8 <vprintfmt+0x2d1>
	else if (lflag)
  8005c6:	85 d2                	test   %edx,%edx
  8005c8:	74 18                	je     8005e2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cd:	8d 50 04             	lea    0x4(%eax),%edx
  8005d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005d8:	89 c1                	mov    %eax,%ecx
  8005da:	c1 f9 1f             	sar    $0x1f,%ecx
  8005dd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005e0:	eb 16                	jmp    8005f8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 50 04             	lea    0x4(%eax),%edx
  8005e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005eb:	8b 00                	mov    (%eax),%eax
  8005ed:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005f0:	89 c1                	mov    %eax,%ecx
  8005f2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005fb:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8005fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800601:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800604:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800609:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80060d:	0f 89 a8 00 00 00    	jns    8006bb <vprintfmt+0x394>
				putch('-', putdat);
  800613:	83 ec 08             	sub    $0x8,%esp
  800616:	53                   	push   %ebx
  800617:	6a 2d                	push   $0x2d
  800619:	ff d6                	call   *%esi
				num = -(long long) num;
  80061b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80061e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800621:	f7 d8                	neg    %eax
  800623:	83 d2 00             	adc    $0x0,%edx
  800626:	f7 da                	neg    %edx
  800628:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80062e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800631:	b8 0a 00 00 00       	mov    $0xa,%eax
  800636:	e9 80 00 00 00       	jmp    8006bb <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063b:	8d 45 14             	lea    0x14(%ebp),%eax
  80063e:	e8 70 fc ff ff       	call   8002b3 <getuint>
  800643:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800646:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800649:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80064e:	eb 6b                	jmp    8006bb <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800650:	8d 45 14             	lea    0x14(%ebp),%eax
  800653:	e8 5b fc ff ff       	call   8002b3 <getuint>
  800658:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  80065e:	6a 04                	push   $0x4
  800660:	6a 03                	push   $0x3
  800662:	6a 01                	push   $0x1
  800664:	68 ff 10 80 00       	push   $0x8010ff
  800669:	e8 82 fb ff ff       	call   8001f0 <cprintf>
			goto number;
  80066e:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  800671:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  800676:	eb 43                	jmp    8006bb <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	6a 30                	push   $0x30
  80067e:	ff d6                	call   *%esi
			putch('x', putdat);
  800680:	83 c4 08             	add    $0x8,%esp
  800683:	53                   	push   %ebx
  800684:	6a 78                	push   $0x78
  800686:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8d 50 04             	lea    0x4(%eax),%edx
  80068e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800691:	8b 00                	mov    (%eax),%eax
  800693:	ba 00 00 00 00       	mov    $0x0,%edx
  800698:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069b:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80069e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006a6:	eb 13                	jmp    8006bb <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ab:	e8 03 fc ff ff       	call   8002b3 <getuint>
  8006b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006b6:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006bb:	83 ec 0c             	sub    $0xc,%esp
  8006be:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006c2:	52                   	push   %edx
  8006c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c6:	50                   	push   %eax
  8006c7:	ff 75 dc             	pushl  -0x24(%ebp)
  8006ca:	ff 75 d8             	pushl  -0x28(%ebp)
  8006cd:	89 da                	mov    %ebx,%edx
  8006cf:	89 f0                	mov    %esi,%eax
  8006d1:	e8 2e fb ff ff       	call   800204 <printnum>

			break;
  8006d6:	83 c4 20             	add    $0x20,%esp
  8006d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006dc:	e9 6c fc ff ff       	jmp    80034d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	53                   	push   %ebx
  8006e5:	51                   	push   %ecx
  8006e6:	ff d6                	call   *%esi
			break;
  8006e8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ee:	e9 5a fc ff ff       	jmp    80034d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	53                   	push   %ebx
  8006f7:	6a 25                	push   $0x25
  8006f9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	eb 03                	jmp    800703 <vprintfmt+0x3dc>
  800700:	83 ef 01             	sub    $0x1,%edi
  800703:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800707:	75 f7                	jne    800700 <vprintfmt+0x3d9>
  800709:	e9 3f fc ff ff       	jmp    80034d <vprintfmt+0x26>
			break;
		}

	}

}
  80070e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800711:	5b                   	pop    %ebx
  800712:	5e                   	pop    %esi
  800713:	5f                   	pop    %edi
  800714:	5d                   	pop    %ebp
  800715:	c3                   	ret    

00800716 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800716:	55                   	push   %ebp
  800717:	89 e5                	mov    %esp,%ebp
  800719:	83 ec 18             	sub    $0x18,%esp
  80071c:	8b 45 08             	mov    0x8(%ebp),%eax
  80071f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800722:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800725:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800729:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800733:	85 c0                	test   %eax,%eax
  800735:	74 26                	je     80075d <vsnprintf+0x47>
  800737:	85 d2                	test   %edx,%edx
  800739:	7e 22                	jle    80075d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073b:	ff 75 14             	pushl  0x14(%ebp)
  80073e:	ff 75 10             	pushl  0x10(%ebp)
  800741:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800744:	50                   	push   %eax
  800745:	68 ed 02 80 00       	push   $0x8002ed
  80074a:	e8 d8 fb ff ff       	call   800327 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800752:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800758:	83 c4 10             	add    $0x10,%esp
  80075b:	eb 05                	jmp    800762 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800762:	c9                   	leave  
  800763:	c3                   	ret    

00800764 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076d:	50                   	push   %eax
  80076e:	ff 75 10             	pushl  0x10(%ebp)
  800771:	ff 75 0c             	pushl  0xc(%ebp)
  800774:	ff 75 08             	pushl  0x8(%ebp)
  800777:	e8 9a ff ff ff       	call   800716 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077c:	c9                   	leave  
  80077d:	c3                   	ret    

0080077e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800784:	b8 00 00 00 00       	mov    $0x0,%eax
  800789:	eb 03                	jmp    80078e <strlen+0x10>
		n++;
  80078b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800792:	75 f7                	jne    80078b <strlen+0xd>
		n++;
	return n;
}
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079f:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a4:	eb 03                	jmp    8007a9 <strnlen+0x13>
		n++;
  8007a6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a9:	39 c2                	cmp    %eax,%edx
  8007ab:	74 08                	je     8007b5 <strnlen+0x1f>
  8007ad:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b1:	75 f3                	jne    8007a6 <strnlen+0x10>
  8007b3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c1:	89 c2                	mov    %eax,%edx
  8007c3:	83 c2 01             	add    $0x1,%edx
  8007c6:	83 c1 01             	add    $0x1,%ecx
  8007c9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d0:	84 db                	test   %bl,%bl
  8007d2:	75 ef                	jne    8007c3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d4:	5b                   	pop    %ebx
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007de:	53                   	push   %ebx
  8007df:	e8 9a ff ff ff       	call   80077e <strlen>
  8007e4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ea:	01 d8                	add    %ebx,%eax
  8007ec:	50                   	push   %eax
  8007ed:	e8 c5 ff ff ff       	call   8007b7 <strcpy>
	return dst;
}
  8007f2:	89 d8                	mov    %ebx,%eax
  8007f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    

008007f9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	56                   	push   %esi
  8007fd:	53                   	push   %ebx
  8007fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800801:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800804:	89 f3                	mov    %esi,%ebx
  800806:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800809:	89 f2                	mov    %esi,%edx
  80080b:	eb 0f                	jmp    80081c <strncpy+0x23>
		*dst++ = *src;
  80080d:	83 c2 01             	add    $0x1,%edx
  800810:	0f b6 01             	movzbl (%ecx),%eax
  800813:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800816:	80 39 01             	cmpb   $0x1,(%ecx)
  800819:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081c:	39 da                	cmp    %ebx,%edx
  80081e:	75 ed                	jne    80080d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800820:	89 f0                	mov    %esi,%eax
  800822:	5b                   	pop    %ebx
  800823:	5e                   	pop    %esi
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	56                   	push   %esi
  80082a:	53                   	push   %ebx
  80082b:	8b 75 08             	mov    0x8(%ebp),%esi
  80082e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800831:	8b 55 10             	mov    0x10(%ebp),%edx
  800834:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800836:	85 d2                	test   %edx,%edx
  800838:	74 21                	je     80085b <strlcpy+0x35>
  80083a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083e:	89 f2                	mov    %esi,%edx
  800840:	eb 09                	jmp    80084b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800842:	83 c2 01             	add    $0x1,%edx
  800845:	83 c1 01             	add    $0x1,%ecx
  800848:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084b:	39 c2                	cmp    %eax,%edx
  80084d:	74 09                	je     800858 <strlcpy+0x32>
  80084f:	0f b6 19             	movzbl (%ecx),%ebx
  800852:	84 db                	test   %bl,%bl
  800854:	75 ec                	jne    800842 <strlcpy+0x1c>
  800856:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800858:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085b:	29 f0                	sub    %esi,%eax
}
  80085d:	5b                   	pop    %ebx
  80085e:	5e                   	pop    %esi
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086a:	eb 06                	jmp    800872 <strcmp+0x11>
		p++, q++;
  80086c:	83 c1 01             	add    $0x1,%ecx
  80086f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800872:	0f b6 01             	movzbl (%ecx),%eax
  800875:	84 c0                	test   %al,%al
  800877:	74 04                	je     80087d <strcmp+0x1c>
  800879:	3a 02                	cmp    (%edx),%al
  80087b:	74 ef                	je     80086c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087d:	0f b6 c0             	movzbl %al,%eax
  800880:	0f b6 12             	movzbl (%edx),%edx
  800883:	29 d0                	sub    %edx,%eax
}
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800891:	89 c3                	mov    %eax,%ebx
  800893:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800896:	eb 06                	jmp    80089e <strncmp+0x17>
		n--, p++, q++;
  800898:	83 c0 01             	add    $0x1,%eax
  80089b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089e:	39 d8                	cmp    %ebx,%eax
  8008a0:	74 15                	je     8008b7 <strncmp+0x30>
  8008a2:	0f b6 08             	movzbl (%eax),%ecx
  8008a5:	84 c9                	test   %cl,%cl
  8008a7:	74 04                	je     8008ad <strncmp+0x26>
  8008a9:	3a 0a                	cmp    (%edx),%cl
  8008ab:	74 eb                	je     800898 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ad:	0f b6 00             	movzbl (%eax),%eax
  8008b0:	0f b6 12             	movzbl (%edx),%edx
  8008b3:	29 d0                	sub    %edx,%eax
  8008b5:	eb 05                	jmp    8008bc <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bc:	5b                   	pop    %ebx
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c9:	eb 07                	jmp    8008d2 <strchr+0x13>
		if (*s == c)
  8008cb:	38 ca                	cmp    %cl,%dl
  8008cd:	74 0f                	je     8008de <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008cf:	83 c0 01             	add    $0x1,%eax
  8008d2:	0f b6 10             	movzbl (%eax),%edx
  8008d5:	84 d2                	test   %dl,%dl
  8008d7:	75 f2                	jne    8008cb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ea:	eb 03                	jmp    8008ef <strfind+0xf>
  8008ec:	83 c0 01             	add    $0x1,%eax
  8008ef:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f2:	38 ca                	cmp    %cl,%dl
  8008f4:	74 04                	je     8008fa <strfind+0x1a>
  8008f6:	84 d2                	test   %dl,%dl
  8008f8:	75 f2                	jne    8008ec <strfind+0xc>
			break;
	return (char *) s;
}
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	57                   	push   %edi
  800900:	56                   	push   %esi
  800901:	53                   	push   %ebx
  800902:	8b 7d 08             	mov    0x8(%ebp),%edi
  800905:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800908:	85 c9                	test   %ecx,%ecx
  80090a:	74 36                	je     800942 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800912:	75 28                	jne    80093c <memset+0x40>
  800914:	f6 c1 03             	test   $0x3,%cl
  800917:	75 23                	jne    80093c <memset+0x40>
		c &= 0xFF;
  800919:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091d:	89 d3                	mov    %edx,%ebx
  80091f:	c1 e3 08             	shl    $0x8,%ebx
  800922:	89 d6                	mov    %edx,%esi
  800924:	c1 e6 18             	shl    $0x18,%esi
  800927:	89 d0                	mov    %edx,%eax
  800929:	c1 e0 10             	shl    $0x10,%eax
  80092c:	09 f0                	or     %esi,%eax
  80092e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800930:	89 d8                	mov    %ebx,%eax
  800932:	09 d0                	or     %edx,%eax
  800934:	c1 e9 02             	shr    $0x2,%ecx
  800937:	fc                   	cld    
  800938:	f3 ab                	rep stos %eax,%es:(%edi)
  80093a:	eb 06                	jmp    800942 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093f:	fc                   	cld    
  800940:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800942:	89 f8                	mov    %edi,%eax
  800944:	5b                   	pop    %ebx
  800945:	5e                   	pop    %esi
  800946:	5f                   	pop    %edi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	57                   	push   %edi
  80094d:	56                   	push   %esi
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 75 0c             	mov    0xc(%ebp),%esi
  800954:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800957:	39 c6                	cmp    %eax,%esi
  800959:	73 35                	jae    800990 <memmove+0x47>
  80095b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095e:	39 d0                	cmp    %edx,%eax
  800960:	73 2e                	jae    800990 <memmove+0x47>
		s += n;
		d += n;
  800962:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800965:	89 d6                	mov    %edx,%esi
  800967:	09 fe                	or     %edi,%esi
  800969:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096f:	75 13                	jne    800984 <memmove+0x3b>
  800971:	f6 c1 03             	test   $0x3,%cl
  800974:	75 0e                	jne    800984 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800976:	83 ef 04             	sub    $0x4,%edi
  800979:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097c:	c1 e9 02             	shr    $0x2,%ecx
  80097f:	fd                   	std    
  800980:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800982:	eb 09                	jmp    80098d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800984:	83 ef 01             	sub    $0x1,%edi
  800987:	8d 72 ff             	lea    -0x1(%edx),%esi
  80098a:	fd                   	std    
  80098b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098d:	fc                   	cld    
  80098e:	eb 1d                	jmp    8009ad <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800990:	89 f2                	mov    %esi,%edx
  800992:	09 c2                	or     %eax,%edx
  800994:	f6 c2 03             	test   $0x3,%dl
  800997:	75 0f                	jne    8009a8 <memmove+0x5f>
  800999:	f6 c1 03             	test   $0x3,%cl
  80099c:	75 0a                	jne    8009a8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099e:	c1 e9 02             	shr    $0x2,%ecx
  8009a1:	89 c7                	mov    %eax,%edi
  8009a3:	fc                   	cld    
  8009a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a6:	eb 05                	jmp    8009ad <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a8:	89 c7                	mov    %eax,%edi
  8009aa:	fc                   	cld    
  8009ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ad:	5e                   	pop    %esi
  8009ae:	5f                   	pop    %edi
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b4:	ff 75 10             	pushl  0x10(%ebp)
  8009b7:	ff 75 0c             	pushl  0xc(%ebp)
  8009ba:	ff 75 08             	pushl  0x8(%ebp)
  8009bd:	e8 87 ff ff ff       	call   800949 <memmove>
}
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cf:	89 c6                	mov    %eax,%esi
  8009d1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d4:	eb 1a                	jmp    8009f0 <memcmp+0x2c>
		if (*s1 != *s2)
  8009d6:	0f b6 08             	movzbl (%eax),%ecx
  8009d9:	0f b6 1a             	movzbl (%edx),%ebx
  8009dc:	38 d9                	cmp    %bl,%cl
  8009de:	74 0a                	je     8009ea <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e0:	0f b6 c1             	movzbl %cl,%eax
  8009e3:	0f b6 db             	movzbl %bl,%ebx
  8009e6:	29 d8                	sub    %ebx,%eax
  8009e8:	eb 0f                	jmp    8009f9 <memcmp+0x35>
		s1++, s2++;
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f0:	39 f0                	cmp    %esi,%eax
  8009f2:	75 e2                	jne    8009d6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f9:	5b                   	pop    %ebx
  8009fa:	5e                   	pop    %esi
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	53                   	push   %ebx
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a04:	89 c1                	mov    %eax,%ecx
  800a06:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a09:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0d:	eb 0a                	jmp    800a19 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0f:	0f b6 10             	movzbl (%eax),%edx
  800a12:	39 da                	cmp    %ebx,%edx
  800a14:	74 07                	je     800a1d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a16:	83 c0 01             	add    $0x1,%eax
  800a19:	39 c8                	cmp    %ecx,%eax
  800a1b:	72 f2                	jb     800a0f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1d:	5b                   	pop    %ebx
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	57                   	push   %edi
  800a24:	56                   	push   %esi
  800a25:	53                   	push   %ebx
  800a26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2c:	eb 03                	jmp    800a31 <strtol+0x11>
		s++;
  800a2e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a31:	0f b6 01             	movzbl (%ecx),%eax
  800a34:	3c 20                	cmp    $0x20,%al
  800a36:	74 f6                	je     800a2e <strtol+0xe>
  800a38:	3c 09                	cmp    $0x9,%al
  800a3a:	74 f2                	je     800a2e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3c:	3c 2b                	cmp    $0x2b,%al
  800a3e:	75 0a                	jne    800a4a <strtol+0x2a>
		s++;
  800a40:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a43:	bf 00 00 00 00       	mov    $0x0,%edi
  800a48:	eb 11                	jmp    800a5b <strtol+0x3b>
  800a4a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4f:	3c 2d                	cmp    $0x2d,%al
  800a51:	75 08                	jne    800a5b <strtol+0x3b>
		s++, neg = 1;
  800a53:	83 c1 01             	add    $0x1,%ecx
  800a56:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a61:	75 15                	jne    800a78 <strtol+0x58>
  800a63:	80 39 30             	cmpb   $0x30,(%ecx)
  800a66:	75 10                	jne    800a78 <strtol+0x58>
  800a68:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6c:	75 7c                	jne    800aea <strtol+0xca>
		s += 2, base = 16;
  800a6e:	83 c1 02             	add    $0x2,%ecx
  800a71:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a76:	eb 16                	jmp    800a8e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a78:	85 db                	test   %ebx,%ebx
  800a7a:	75 12                	jne    800a8e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a81:	80 39 30             	cmpb   $0x30,(%ecx)
  800a84:	75 08                	jne    800a8e <strtol+0x6e>
		s++, base = 8;
  800a86:	83 c1 01             	add    $0x1,%ecx
  800a89:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a93:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a96:	0f b6 11             	movzbl (%ecx),%edx
  800a99:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9c:	89 f3                	mov    %esi,%ebx
  800a9e:	80 fb 09             	cmp    $0x9,%bl
  800aa1:	77 08                	ja     800aab <strtol+0x8b>
			dig = *s - '0';
  800aa3:	0f be d2             	movsbl %dl,%edx
  800aa6:	83 ea 30             	sub    $0x30,%edx
  800aa9:	eb 22                	jmp    800acd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aab:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aae:	89 f3                	mov    %esi,%ebx
  800ab0:	80 fb 19             	cmp    $0x19,%bl
  800ab3:	77 08                	ja     800abd <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab5:	0f be d2             	movsbl %dl,%edx
  800ab8:	83 ea 57             	sub    $0x57,%edx
  800abb:	eb 10                	jmp    800acd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abd:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac0:	89 f3                	mov    %esi,%ebx
  800ac2:	80 fb 19             	cmp    $0x19,%bl
  800ac5:	77 16                	ja     800add <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac7:	0f be d2             	movsbl %dl,%edx
  800aca:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800acd:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad0:	7d 0b                	jge    800add <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad2:	83 c1 01             	add    $0x1,%ecx
  800ad5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800adb:	eb b9                	jmp    800a96 <strtol+0x76>

	if (endptr)
  800add:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae1:	74 0d                	je     800af0 <strtol+0xd0>
		*endptr = (char *) s;
  800ae3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae6:	89 0e                	mov    %ecx,(%esi)
  800ae8:	eb 06                	jmp    800af0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aea:	85 db                	test   %ebx,%ebx
  800aec:	74 98                	je     800a86 <strtol+0x66>
  800aee:	eb 9e                	jmp    800a8e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af0:	89 c2                	mov    %eax,%edx
  800af2:	f7 da                	neg    %edx
  800af4:	85 ff                	test   %edi,%edi
  800af6:	0f 45 c2             	cmovne %edx,%eax
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	b8 00 00 00 00       	mov    $0x0,%eax
  800b09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0f:	89 c3                	mov    %eax,%ebx
  800b11:	89 c7                	mov    %eax,%edi
  800b13:	89 c6                	mov    %eax,%esi
  800b15:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2c:	89 d1                	mov    %edx,%ecx
  800b2e:	89 d3                	mov    %edx,%ebx
  800b30:	89 d7                	mov    %edx,%edi
  800b32:	89 d6                	mov    %edx,%esi
  800b34:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
  800b41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b49:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b51:	89 cb                	mov    %ecx,%ebx
  800b53:	89 cf                	mov    %ecx,%edi
  800b55:	89 ce                	mov    %ecx,%esi
  800b57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	7e 17                	jle    800b74 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	50                   	push   %eax
  800b61:	6a 03                	push   $0x3
  800b63:	68 48 13 80 00       	push   $0x801348
  800b68:	6a 23                	push   $0x23
  800b6a:	68 65 13 80 00       	push   $0x801365
  800b6f:	e8 a3 f5 ff ff       	call   800117 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	ba 00 00 00 00       	mov    $0x0,%edx
  800b87:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8c:	89 d1                	mov    %edx,%ecx
  800b8e:	89 d3                	mov    %edx,%ebx
  800b90:	89 d7                	mov    %edx,%edi
  800b92:	89 d6                	mov    %edx,%esi
  800b94:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_yield>:

void
sys_yield(void)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bab:	89 d1                	mov    %edx,%ecx
  800bad:	89 d3                	mov    %edx,%ebx
  800baf:	89 d7                	mov    %edx,%edi
  800bb1:	89 d6                	mov    %edx,%esi
  800bb3:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	be 00 00 00 00       	mov    $0x0,%esi
  800bc8:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd6:	89 f7                	mov    %esi,%edi
  800bd8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	7e 17                	jle    800bf5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bde:	83 ec 0c             	sub    $0xc,%esp
  800be1:	50                   	push   %eax
  800be2:	6a 04                	push   $0x4
  800be4:	68 48 13 80 00       	push   $0x801348
  800be9:	6a 23                	push   $0x23
  800beb:	68 65 13 80 00       	push   $0x801365
  800bf0:	e8 22 f5 ff ff       	call   800117 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	57                   	push   %edi
  800c01:	56                   	push   %esi
  800c02:	53                   	push   %ebx
  800c03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c06:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c14:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c17:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	7e 17                	jle    800c37 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c20:	83 ec 0c             	sub    $0xc,%esp
  800c23:	50                   	push   %eax
  800c24:	6a 05                	push   $0x5
  800c26:	68 48 13 80 00       	push   $0x801348
  800c2b:	6a 23                	push   $0x23
  800c2d:	68 65 13 80 00       	push   $0x801365
  800c32:	e8 e0 f4 ff ff       	call   800117 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c55:	8b 55 08             	mov    0x8(%ebp),%edx
  800c58:	89 df                	mov    %ebx,%edi
  800c5a:	89 de                	mov    %ebx,%esi
  800c5c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	7e 17                	jle    800c79 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c62:	83 ec 0c             	sub    $0xc,%esp
  800c65:	50                   	push   %eax
  800c66:	6a 06                	push   $0x6
  800c68:	68 48 13 80 00       	push   $0x801348
  800c6d:	6a 23                	push   $0x23
  800c6f:	68 65 13 80 00       	push   $0x801365
  800c74:	e8 9e f4 ff ff       	call   800117 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	89 df                	mov    %ebx,%edi
  800c9c:	89 de                	mov    %ebx,%esi
  800c9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	7e 17                	jle    800cbb <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca4:	83 ec 0c             	sub    $0xc,%esp
  800ca7:	50                   	push   %eax
  800ca8:	6a 08                	push   $0x8
  800caa:	68 48 13 80 00       	push   $0x801348
  800caf:	6a 23                	push   $0x23
  800cb1:	68 65 13 80 00       	push   $0x801365
  800cb6:	e8 5c f4 ff ff       	call   800117 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd1:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	89 df                	mov    %ebx,%edi
  800cde:	89 de                	mov    %ebx,%esi
  800ce0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	7e 17                	jle    800cfd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce6:	83 ec 0c             	sub    $0xc,%esp
  800ce9:	50                   	push   %eax
  800cea:	6a 09                	push   $0x9
  800cec:	68 48 13 80 00       	push   $0x801348
  800cf1:	6a 23                	push   $0x23
  800cf3:	68 65 13 80 00       	push   $0x801365
  800cf8:	e8 1a f4 ff ff       	call   800117 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0b:	be 00 00 00 00       	mov    $0x0,%esi
  800d10:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d18:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d21:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
  800d2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d36:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	89 cb                	mov    %ecx,%ebx
  800d40:	89 cf                	mov    %ecx,%edi
  800d42:	89 ce                	mov    %ecx,%esi
  800d44:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d46:	85 c0                	test   %eax,%eax
  800d48:	7e 17                	jle    800d61 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4a:	83 ec 0c             	sub    $0xc,%esp
  800d4d:	50                   	push   %eax
  800d4e:	6a 0c                	push   $0xc
  800d50:	68 48 13 80 00       	push   $0x801348
  800d55:	6a 23                	push   $0x23
  800d57:	68 65 13 80 00       	push   $0x801365
  800d5c:	e8 b6 f3 ff ff       	call   800117 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d6f:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d76:	75 14                	jne    800d8c <set_pgfault_handler+0x23>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800d78:	83 ec 04             	sub    $0x4,%esp
  800d7b:	68 74 13 80 00       	push   $0x801374
  800d80:	6a 20                	push   $0x20
  800d82:	68 98 13 80 00       	push   $0x801398
  800d87:	e8 8b f3 ff ff       	call   800117 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8f:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d94:	c9                   	leave  
  800d95:	c3                   	ret    
  800d96:	66 90                	xchg   %ax,%ax
  800d98:	66 90                	xchg   %ax,%ax
  800d9a:	66 90                	xchg   %ax,%ax
  800d9c:	66 90                	xchg   %ax,%ax
  800d9e:	66 90                	xchg   %ax,%ax

00800da0 <__udivdi3>:
  800da0:	55                   	push   %ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	83 ec 1c             	sub    $0x1c,%esp
  800da7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800dab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800daf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800db3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800db7:	85 f6                	test   %esi,%esi
  800db9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800dbd:	89 ca                	mov    %ecx,%edx
  800dbf:	89 f8                	mov    %edi,%eax
  800dc1:	75 3d                	jne    800e00 <__udivdi3+0x60>
  800dc3:	39 cf                	cmp    %ecx,%edi
  800dc5:	0f 87 c5 00 00 00    	ja     800e90 <__udivdi3+0xf0>
  800dcb:	85 ff                	test   %edi,%edi
  800dcd:	89 fd                	mov    %edi,%ebp
  800dcf:	75 0b                	jne    800ddc <__udivdi3+0x3c>
  800dd1:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd6:	31 d2                	xor    %edx,%edx
  800dd8:	f7 f7                	div    %edi
  800dda:	89 c5                	mov    %eax,%ebp
  800ddc:	89 c8                	mov    %ecx,%eax
  800dde:	31 d2                	xor    %edx,%edx
  800de0:	f7 f5                	div    %ebp
  800de2:	89 c1                	mov    %eax,%ecx
  800de4:	89 d8                	mov    %ebx,%eax
  800de6:	89 cf                	mov    %ecx,%edi
  800de8:	f7 f5                	div    %ebp
  800dea:	89 c3                	mov    %eax,%ebx
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
  800e00:	39 ce                	cmp    %ecx,%esi
  800e02:	77 74                	ja     800e78 <__udivdi3+0xd8>
  800e04:	0f bd fe             	bsr    %esi,%edi
  800e07:	83 f7 1f             	xor    $0x1f,%edi
  800e0a:	0f 84 98 00 00 00    	je     800ea8 <__udivdi3+0x108>
  800e10:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e15:	89 f9                	mov    %edi,%ecx
  800e17:	89 c5                	mov    %eax,%ebp
  800e19:	29 fb                	sub    %edi,%ebx
  800e1b:	d3 e6                	shl    %cl,%esi
  800e1d:	89 d9                	mov    %ebx,%ecx
  800e1f:	d3 ed                	shr    %cl,%ebp
  800e21:	89 f9                	mov    %edi,%ecx
  800e23:	d3 e0                	shl    %cl,%eax
  800e25:	09 ee                	or     %ebp,%esi
  800e27:	89 d9                	mov    %ebx,%ecx
  800e29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e2d:	89 d5                	mov    %edx,%ebp
  800e2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e33:	d3 ed                	shr    %cl,%ebp
  800e35:	89 f9                	mov    %edi,%ecx
  800e37:	d3 e2                	shl    %cl,%edx
  800e39:	89 d9                	mov    %ebx,%ecx
  800e3b:	d3 e8                	shr    %cl,%eax
  800e3d:	09 c2                	or     %eax,%edx
  800e3f:	89 d0                	mov    %edx,%eax
  800e41:	89 ea                	mov    %ebp,%edx
  800e43:	f7 f6                	div    %esi
  800e45:	89 d5                	mov    %edx,%ebp
  800e47:	89 c3                	mov    %eax,%ebx
  800e49:	f7 64 24 0c          	mull   0xc(%esp)
  800e4d:	39 d5                	cmp    %edx,%ebp
  800e4f:	72 10                	jb     800e61 <__udivdi3+0xc1>
  800e51:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e55:	89 f9                	mov    %edi,%ecx
  800e57:	d3 e6                	shl    %cl,%esi
  800e59:	39 c6                	cmp    %eax,%esi
  800e5b:	73 07                	jae    800e64 <__udivdi3+0xc4>
  800e5d:	39 d5                	cmp    %edx,%ebp
  800e5f:	75 03                	jne    800e64 <__udivdi3+0xc4>
  800e61:	83 eb 01             	sub    $0x1,%ebx
  800e64:	31 ff                	xor    %edi,%edi
  800e66:	89 d8                	mov    %ebx,%eax
  800e68:	89 fa                	mov    %edi,%edx
  800e6a:	83 c4 1c             	add    $0x1c,%esp
  800e6d:	5b                   	pop    %ebx
  800e6e:	5e                   	pop    %esi
  800e6f:	5f                   	pop    %edi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    
  800e72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e78:	31 ff                	xor    %edi,%edi
  800e7a:	31 db                	xor    %ebx,%ebx
  800e7c:	89 d8                	mov    %ebx,%eax
  800e7e:	89 fa                	mov    %edi,%edx
  800e80:	83 c4 1c             	add    $0x1c,%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    
  800e88:	90                   	nop
  800e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e90:	89 d8                	mov    %ebx,%eax
  800e92:	f7 f7                	div    %edi
  800e94:	31 ff                	xor    %edi,%edi
  800e96:	89 c3                	mov    %eax,%ebx
  800e98:	89 d8                	mov    %ebx,%eax
  800e9a:	89 fa                	mov    %edi,%edx
  800e9c:	83 c4 1c             	add    $0x1c,%esp
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5f                   	pop    %edi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    
  800ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ea8:	39 ce                	cmp    %ecx,%esi
  800eaa:	72 0c                	jb     800eb8 <__udivdi3+0x118>
  800eac:	31 db                	xor    %ebx,%ebx
  800eae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800eb2:	0f 87 34 ff ff ff    	ja     800dec <__udivdi3+0x4c>
  800eb8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ebd:	e9 2a ff ff ff       	jmp    800dec <__udivdi3+0x4c>
  800ec2:	66 90                	xchg   %ax,%ax
  800ec4:	66 90                	xchg   %ax,%ax
  800ec6:	66 90                	xchg   %ax,%ax
  800ec8:	66 90                	xchg   %ax,%ax
  800eca:	66 90                	xchg   %ax,%ax
  800ecc:	66 90                	xchg   %ax,%ax
  800ece:	66 90                	xchg   %ax,%ax

00800ed0 <__umoddi3>:
  800ed0:	55                   	push   %ebp
  800ed1:	57                   	push   %edi
  800ed2:	56                   	push   %esi
  800ed3:	53                   	push   %ebx
  800ed4:	83 ec 1c             	sub    $0x1c,%esp
  800ed7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800edb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800edf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ee3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ee7:	85 d2                	test   %edx,%edx
  800ee9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800eed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ef1:	89 f3                	mov    %esi,%ebx
  800ef3:	89 3c 24             	mov    %edi,(%esp)
  800ef6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800efa:	75 1c                	jne    800f18 <__umoddi3+0x48>
  800efc:	39 f7                	cmp    %esi,%edi
  800efe:	76 50                	jbe    800f50 <__umoddi3+0x80>
  800f00:	89 c8                	mov    %ecx,%eax
  800f02:	89 f2                	mov    %esi,%edx
  800f04:	f7 f7                	div    %edi
  800f06:	89 d0                	mov    %edx,%eax
  800f08:	31 d2                	xor    %edx,%edx
  800f0a:	83 c4 1c             	add    $0x1c,%esp
  800f0d:	5b                   	pop    %ebx
  800f0e:	5e                   	pop    %esi
  800f0f:	5f                   	pop    %edi
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    
  800f12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f18:	39 f2                	cmp    %esi,%edx
  800f1a:	89 d0                	mov    %edx,%eax
  800f1c:	77 52                	ja     800f70 <__umoddi3+0xa0>
  800f1e:	0f bd ea             	bsr    %edx,%ebp
  800f21:	83 f5 1f             	xor    $0x1f,%ebp
  800f24:	75 5a                	jne    800f80 <__umoddi3+0xb0>
  800f26:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f2a:	0f 82 e0 00 00 00    	jb     801010 <__umoddi3+0x140>
  800f30:	39 0c 24             	cmp    %ecx,(%esp)
  800f33:	0f 86 d7 00 00 00    	jbe    801010 <__umoddi3+0x140>
  800f39:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f3d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f41:	83 c4 1c             	add    $0x1c,%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    
  800f49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f50:	85 ff                	test   %edi,%edi
  800f52:	89 fd                	mov    %edi,%ebp
  800f54:	75 0b                	jne    800f61 <__umoddi3+0x91>
  800f56:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	f7 f7                	div    %edi
  800f5f:	89 c5                	mov    %eax,%ebp
  800f61:	89 f0                	mov    %esi,%eax
  800f63:	31 d2                	xor    %edx,%edx
  800f65:	f7 f5                	div    %ebp
  800f67:	89 c8                	mov    %ecx,%eax
  800f69:	f7 f5                	div    %ebp
  800f6b:	89 d0                	mov    %edx,%eax
  800f6d:	eb 99                	jmp    800f08 <__umoddi3+0x38>
  800f6f:	90                   	nop
  800f70:	89 c8                	mov    %ecx,%eax
  800f72:	89 f2                	mov    %esi,%edx
  800f74:	83 c4 1c             	add    $0x1c,%esp
  800f77:	5b                   	pop    %ebx
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    
  800f7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f80:	8b 34 24             	mov    (%esp),%esi
  800f83:	bf 20 00 00 00       	mov    $0x20,%edi
  800f88:	89 e9                	mov    %ebp,%ecx
  800f8a:	29 ef                	sub    %ebp,%edi
  800f8c:	d3 e0                	shl    %cl,%eax
  800f8e:	89 f9                	mov    %edi,%ecx
  800f90:	89 f2                	mov    %esi,%edx
  800f92:	d3 ea                	shr    %cl,%edx
  800f94:	89 e9                	mov    %ebp,%ecx
  800f96:	09 c2                	or     %eax,%edx
  800f98:	89 d8                	mov    %ebx,%eax
  800f9a:	89 14 24             	mov    %edx,(%esp)
  800f9d:	89 f2                	mov    %esi,%edx
  800f9f:	d3 e2                	shl    %cl,%edx
  800fa1:	89 f9                	mov    %edi,%ecx
  800fa3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fa7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fab:	d3 e8                	shr    %cl,%eax
  800fad:	89 e9                	mov    %ebp,%ecx
  800faf:	89 c6                	mov    %eax,%esi
  800fb1:	d3 e3                	shl    %cl,%ebx
  800fb3:	89 f9                	mov    %edi,%ecx
  800fb5:	89 d0                	mov    %edx,%eax
  800fb7:	d3 e8                	shr    %cl,%eax
  800fb9:	89 e9                	mov    %ebp,%ecx
  800fbb:	09 d8                	or     %ebx,%eax
  800fbd:	89 d3                	mov    %edx,%ebx
  800fbf:	89 f2                	mov    %esi,%edx
  800fc1:	f7 34 24             	divl   (%esp)
  800fc4:	89 d6                	mov    %edx,%esi
  800fc6:	d3 e3                	shl    %cl,%ebx
  800fc8:	f7 64 24 04          	mull   0x4(%esp)
  800fcc:	39 d6                	cmp    %edx,%esi
  800fce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fd2:	89 d1                	mov    %edx,%ecx
  800fd4:	89 c3                	mov    %eax,%ebx
  800fd6:	72 08                	jb     800fe0 <__umoddi3+0x110>
  800fd8:	75 11                	jne    800feb <__umoddi3+0x11b>
  800fda:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800fde:	73 0b                	jae    800feb <__umoddi3+0x11b>
  800fe0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fe4:	1b 14 24             	sbb    (%esp),%edx
  800fe7:	89 d1                	mov    %edx,%ecx
  800fe9:	89 c3                	mov    %eax,%ebx
  800feb:	8b 54 24 08          	mov    0x8(%esp),%edx
  800fef:	29 da                	sub    %ebx,%edx
  800ff1:	19 ce                	sbb    %ecx,%esi
  800ff3:	89 f9                	mov    %edi,%ecx
  800ff5:	89 f0                	mov    %esi,%eax
  800ff7:	d3 e0                	shl    %cl,%eax
  800ff9:	89 e9                	mov    %ebp,%ecx
  800ffb:	d3 ea                	shr    %cl,%edx
  800ffd:	89 e9                	mov    %ebp,%ecx
  800fff:	d3 ee                	shr    %cl,%esi
  801001:	09 d0                	or     %edx,%eax
  801003:	89 f2                	mov    %esi,%edx
  801005:	83 c4 1c             	add    $0x1c,%esp
  801008:	5b                   	pop    %ebx
  801009:	5e                   	pop    %esi
  80100a:	5f                   	pop    %edi
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    
  80100d:	8d 76 00             	lea    0x0(%esi),%esi
  801010:	29 f9                	sub    %edi,%ecx
  801012:	19 d6                	sbb    %edx,%esi
  801014:	89 74 24 04          	mov    %esi,0x4(%esp)
  801018:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80101c:	e9 18 ff ff ff       	jmp    800f39 <__umoddi3+0x69>
