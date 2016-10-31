
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
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
  800045:	e8 bb 01 00 00       	call   800205 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 71 0b 00 00       	call   800bcf <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 60 10 80 00       	push   $0x801060
  80006f:	6a 0e                	push   $0xe
  800071:	68 4a 10 80 00       	push   $0x80104a
  800076:	e8 b1 00 00 00       	call   80012c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 8c 10 80 00       	push   $0x80108c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 f0 06 00 00       	call   800779 <snprintf>
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
  80009c:	e8 dd 0c 00 00       	call   800d7e <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 5c 10 80 00       	push   $0x80105c
  8000ae:	e8 52 01 00 00       	call   800205 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 5c 10 80 00       	push   $0x80105c
  8000c0:	e8 40 01 00 00       	call   800205 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000d5:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000dc:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  8000df:	e8 ad 0a 00 00       	call   800b91 <sys_getenvid>
  8000e4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000ec:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f1:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f6:	85 db                	test   %ebx,%ebx
  8000f8:	7e 07                	jle    800101 <libmain+0x37>
		binaryname = argv[0];
  8000fa:	8b 06                	mov    (%esi),%eax
  8000fc:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800101:	83 ec 08             	sub    $0x8,%esp
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 86 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  80010b:	e8 0a 00 00 00       	call   80011a <exit>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800116:	5b                   	pop    %ebx
  800117:	5e                   	pop    %esi
  800118:	5d                   	pop    %ebp
  800119:	c3                   	ret    

0080011a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800120:	6a 00                	push   $0x0
  800122:	e8 29 0a 00 00       	call   800b50 <sys_env_destroy>
}
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	c9                   	leave  
  80012b:	c3                   	ret    

0080012c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	56                   	push   %esi
  800130:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800131:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800134:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80013a:	e8 52 0a 00 00       	call   800b91 <sys_getenvid>
  80013f:	83 ec 0c             	sub    $0xc,%esp
  800142:	ff 75 0c             	pushl  0xc(%ebp)
  800145:	ff 75 08             	pushl  0x8(%ebp)
  800148:	56                   	push   %esi
  800149:	50                   	push   %eax
  80014a:	68 b8 10 80 00       	push   $0x8010b8
  80014f:	e8 b1 00 00 00       	call   800205 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800154:	83 c4 18             	add    $0x18,%esp
  800157:	53                   	push   %ebx
  800158:	ff 75 10             	pushl  0x10(%ebp)
  80015b:	e8 54 00 00 00       	call   8001b4 <vcprintf>
	cprintf("\n");
  800160:	c7 04 24 0f 11 80 00 	movl   $0x80110f,(%esp)
  800167:	e8 99 00 00 00       	call   800205 <cprintf>
  80016c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016f:	cc                   	int3   
  800170:	eb fd                	jmp    80016f <_panic+0x43>

00800172 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	53                   	push   %ebx
  800176:	83 ec 04             	sub    $0x4,%esp
  800179:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017c:	8b 13                	mov    (%ebx),%edx
  80017e:	8d 42 01             	lea    0x1(%edx),%eax
  800181:	89 03                	mov    %eax,(%ebx)
  800183:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800186:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018f:	75 1a                	jne    8001ab <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800191:	83 ec 08             	sub    $0x8,%esp
  800194:	68 ff 00 00 00       	push   $0xff
  800199:	8d 43 08             	lea    0x8(%ebx),%eax
  80019c:	50                   	push   %eax
  80019d:	e8 71 09 00 00       	call   800b13 <sys_cputs>
		b->idx = 0;
  8001a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c4:	00 00 00 
	b.cnt = 0;
  8001c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d1:	ff 75 0c             	pushl  0xc(%ebp)
  8001d4:	ff 75 08             	pushl  0x8(%ebp)
  8001d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001dd:	50                   	push   %eax
  8001de:	68 72 01 80 00       	push   $0x800172
  8001e3:	e8 54 01 00 00       	call   80033c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e8:	83 c4 08             	add    $0x8,%esp
  8001eb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f7:	50                   	push   %eax
  8001f8:	e8 16 09 00 00       	call   800b13 <sys_cputs>

	return b.cnt;
}
  8001fd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020e:	50                   	push   %eax
  80020f:	ff 75 08             	pushl  0x8(%ebp)
  800212:	e8 9d ff ff ff       	call   8001b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 1c             	sub    $0x1c,%esp
  800222:	89 c7                	mov    %eax,%edi
  800224:	89 d6                	mov    %edx,%esi
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800232:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800235:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80023d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800240:	39 d3                	cmp    %edx,%ebx
  800242:	72 05                	jb     800249 <printnum+0x30>
  800244:	39 45 10             	cmp    %eax,0x10(%ebp)
  800247:	77 45                	ja     80028e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 18             	pushl  0x18(%ebp)
  80024f:	8b 45 14             	mov    0x14(%ebp),%eax
  800252:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800255:	53                   	push   %ebx
  800256:	ff 75 10             	pushl  0x10(%ebp)
  800259:	83 ec 08             	sub    $0x8,%esp
  80025c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025f:	ff 75 e0             	pushl  -0x20(%ebp)
  800262:	ff 75 dc             	pushl  -0x24(%ebp)
  800265:	ff 75 d8             	pushl  -0x28(%ebp)
  800268:	e8 43 0b 00 00       	call   800db0 <__udivdi3>
  80026d:	83 c4 18             	add    $0x18,%esp
  800270:	52                   	push   %edx
  800271:	50                   	push   %eax
  800272:	89 f2                	mov    %esi,%edx
  800274:	89 f8                	mov    %edi,%eax
  800276:	e8 9e ff ff ff       	call   800219 <printnum>
  80027b:	83 c4 20             	add    $0x20,%esp
  80027e:	eb 18                	jmp    800298 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800280:	83 ec 08             	sub    $0x8,%esp
  800283:	56                   	push   %esi
  800284:	ff 75 18             	pushl  0x18(%ebp)
  800287:	ff d7                	call   *%edi
  800289:	83 c4 10             	add    $0x10,%esp
  80028c:	eb 03                	jmp    800291 <printnum+0x78>
  80028e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800291:	83 eb 01             	sub    $0x1,%ebx
  800294:	85 db                	test   %ebx,%ebx
  800296:	7f e8                	jg     800280 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	56                   	push   %esi
  80029c:	83 ec 04             	sub    $0x4,%esp
  80029f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ab:	e8 30 0c 00 00       	call   800ee0 <__umoddi3>
  8002b0:	83 c4 14             	add    $0x14,%esp
  8002b3:	0f be 80 db 10 80 00 	movsbl 0x8010db(%eax),%eax
  8002ba:	50                   	push   %eax
  8002bb:	ff d7                	call   *%edi
}
  8002bd:	83 c4 10             	add    $0x10,%esp
  8002c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c3:	5b                   	pop    %ebx
  8002c4:	5e                   	pop    %esi
  8002c5:	5f                   	pop    %edi
  8002c6:	5d                   	pop    %ebp
  8002c7:	c3                   	ret    

008002c8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002cb:	83 fa 01             	cmp    $0x1,%edx
  8002ce:	7e 0e                	jle    8002de <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 02                	mov    (%edx),%eax
  8002d9:	8b 52 04             	mov    0x4(%edx),%edx
  8002dc:	eb 22                	jmp    800300 <getuint+0x38>
	else if (lflag)
  8002de:	85 d2                	test   %edx,%edx
  8002e0:	74 10                	je     8002f2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e2:	8b 10                	mov    (%eax),%edx
  8002e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e7:	89 08                	mov    %ecx,(%eax)
  8002e9:	8b 02                	mov    (%edx),%eax
  8002eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f0:	eb 0e                	jmp    800300 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800300:	5d                   	pop    %ebp
  800301:	c3                   	ret    

00800302 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800308:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	3b 50 04             	cmp    0x4(%eax),%edx
  800311:	73 0a                	jae    80031d <sprintputch+0x1b>
		*b->buf++ = ch;
  800313:	8d 4a 01             	lea    0x1(%edx),%ecx
  800316:	89 08                	mov    %ecx,(%eax)
  800318:	8b 45 08             	mov    0x8(%ebp),%eax
  80031b:	88 02                	mov    %al,(%edx)
}
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    

0080031f <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800325:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800328:	50                   	push   %eax
  800329:	ff 75 10             	pushl  0x10(%ebp)
  80032c:	ff 75 0c             	pushl  0xc(%ebp)
  80032f:	ff 75 08             	pushl  0x8(%ebp)
  800332:	e8 05 00 00 00       	call   80033c <vprintfmt>
	va_end(ap);
}
  800337:	83 c4 10             	add    $0x10,%esp
  80033a:	c9                   	leave  
  80033b:	c3                   	ret    

0080033c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	57                   	push   %edi
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
  800342:	83 ec 2c             	sub    $0x2c,%esp
  800345:	8b 75 08             	mov    0x8(%ebp),%esi
  800348:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80034b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80034e:	eb 12                	jmp    800362 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800350:	85 c0                	test   %eax,%eax
  800352:	0f 84 cb 03 00 00    	je     800723 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800358:	83 ec 08             	sub    $0x8,%esp
  80035b:	53                   	push   %ebx
  80035c:	50                   	push   %eax
  80035d:	ff d6                	call   *%esi
  80035f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800362:	83 c7 01             	add    $0x1,%edi
  800365:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800369:	83 f8 25             	cmp    $0x25,%eax
  80036c:	75 e2                	jne    800350 <vprintfmt+0x14>
  80036e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800372:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800379:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800380:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800387:	ba 00 00 00 00       	mov    $0x0,%edx
  80038c:	eb 07                	jmp    800395 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800391:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8d 47 01             	lea    0x1(%edi),%eax
  800398:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039b:	0f b6 07             	movzbl (%edi),%eax
  80039e:	0f b6 c8             	movzbl %al,%ecx
  8003a1:	83 e8 23             	sub    $0x23,%eax
  8003a4:	3c 55                	cmp    $0x55,%al
  8003a6:	0f 87 5c 03 00 00    	ja     800708 <vprintfmt+0x3cc>
  8003ac:	0f b6 c0             	movzbl %al,%eax
  8003af:	ff 24 85 c0 11 80 00 	jmp    *0x8011c0(,%eax,4)
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003bd:	eb d6                	jmp    800395 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ca:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003cd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003d1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003d4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003d7:	83 fa 09             	cmp    $0x9,%edx
  8003da:	77 39                	ja     800415 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003dc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003df:	eb e9                	jmp    8003ca <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8d 48 04             	lea    0x4(%eax),%ecx
  8003e7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ea:	8b 00                	mov    (%eax),%eax
  8003ec:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f2:	eb 27                	jmp    80041b <vprintfmt+0xdf>
  8003f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f7:	85 c0                	test   %eax,%eax
  8003f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fe:	0f 49 c8             	cmovns %eax,%ecx
  800401:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800407:	eb 8c                	jmp    800395 <vprintfmt+0x59>
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800413:	eb 80                	jmp    800395 <vprintfmt+0x59>
  800415:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800418:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80041b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041f:	0f 89 70 ff ff ff    	jns    800395 <vprintfmt+0x59>
				width = precision, precision = -1;
  800425:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800428:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042b:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800432:	e9 5e ff ff ff       	jmp    800395 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800437:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80043d:	e9 53 ff ff ff       	jmp    800395 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 50 04             	lea    0x4(%eax),%edx
  800448:	89 55 14             	mov    %edx,0x14(%ebp)
  80044b:	83 ec 08             	sub    $0x8,%esp
  80044e:	53                   	push   %ebx
  80044f:	ff 30                	pushl  (%eax)
  800451:	ff d6                	call   *%esi
			break;
  800453:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800459:	e9 04 ff ff ff       	jmp    800362 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 50 04             	lea    0x4(%eax),%edx
  800464:	89 55 14             	mov    %edx,0x14(%ebp)
  800467:	8b 00                	mov    (%eax),%eax
  800469:	99                   	cltd   
  80046a:	31 d0                	xor    %edx,%eax
  80046c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80046e:	83 f8 09             	cmp    $0x9,%eax
  800471:	7f 0b                	jg     80047e <vprintfmt+0x142>
  800473:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  80047a:	85 d2                	test   %edx,%edx
  80047c:	75 18                	jne    800496 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80047e:	50                   	push   %eax
  80047f:	68 f3 10 80 00       	push   $0x8010f3
  800484:	53                   	push   %ebx
  800485:	56                   	push   %esi
  800486:	e8 94 fe ff ff       	call   80031f <printfmt>
  80048b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800491:	e9 cc fe ff ff       	jmp    800362 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800496:	52                   	push   %edx
  800497:	68 fc 10 80 00       	push   $0x8010fc
  80049c:	53                   	push   %ebx
  80049d:	56                   	push   %esi
  80049e:	e8 7c fe ff ff       	call   80031f <printfmt>
  8004a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a9:	e9 b4 fe ff ff       	jmp    800362 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8d 50 04             	lea    0x4(%eax),%edx
  8004b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b9:	85 ff                	test   %edi,%edi
  8004bb:	b8 ec 10 80 00       	mov    $0x8010ec,%eax
  8004c0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c7:	0f 8e 94 00 00 00    	jle    800561 <vprintfmt+0x225>
  8004cd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d1:	0f 84 98 00 00 00    	je     80056f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	ff 75 c8             	pushl  -0x38(%ebp)
  8004dd:	57                   	push   %edi
  8004de:	e8 c8 02 00 00       	call   8007ab <strnlen>
  8004e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e6:	29 c1                	sub    %eax,%ecx
  8004e8:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004eb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ee:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fa:	eb 0f                	jmp    80050b <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	53                   	push   %ebx
  800500:	ff 75 e0             	pushl  -0x20(%ebp)
  800503:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800505:	83 ef 01             	sub    $0x1,%edi
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	85 ff                	test   %edi,%edi
  80050d:	7f ed                	jg     8004fc <vprintfmt+0x1c0>
  80050f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800512:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800515:	85 c9                	test   %ecx,%ecx
  800517:	b8 00 00 00 00       	mov    $0x0,%eax
  80051c:	0f 49 c1             	cmovns %ecx,%eax
  80051f:	29 c1                	sub    %eax,%ecx
  800521:	89 75 08             	mov    %esi,0x8(%ebp)
  800524:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800527:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052a:	89 cb                	mov    %ecx,%ebx
  80052c:	eb 4d                	jmp    80057b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800532:	74 1b                	je     80054f <vprintfmt+0x213>
  800534:	0f be c0             	movsbl %al,%eax
  800537:	83 e8 20             	sub    $0x20,%eax
  80053a:	83 f8 5e             	cmp    $0x5e,%eax
  80053d:	76 10                	jbe    80054f <vprintfmt+0x213>
					putch('?', putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	ff 75 0c             	pushl  0xc(%ebp)
  800545:	6a 3f                	push   $0x3f
  800547:	ff 55 08             	call   *0x8(%ebp)
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	eb 0d                	jmp    80055c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	ff 75 0c             	pushl  0xc(%ebp)
  800555:	52                   	push   %edx
  800556:	ff 55 08             	call   *0x8(%ebp)
  800559:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055c:	83 eb 01             	sub    $0x1,%ebx
  80055f:	eb 1a                	jmp    80057b <vprintfmt+0x23f>
  800561:	89 75 08             	mov    %esi,0x8(%ebp)
  800564:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800567:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056d:	eb 0c                	jmp    80057b <vprintfmt+0x23f>
  80056f:	89 75 08             	mov    %esi,0x8(%ebp)
  800572:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800575:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800578:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057b:	83 c7 01             	add    $0x1,%edi
  80057e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800582:	0f be d0             	movsbl %al,%edx
  800585:	85 d2                	test   %edx,%edx
  800587:	74 23                	je     8005ac <vprintfmt+0x270>
  800589:	85 f6                	test   %esi,%esi
  80058b:	78 a1                	js     80052e <vprintfmt+0x1f2>
  80058d:	83 ee 01             	sub    $0x1,%esi
  800590:	79 9c                	jns    80052e <vprintfmt+0x1f2>
  800592:	89 df                	mov    %ebx,%edi
  800594:	8b 75 08             	mov    0x8(%ebp),%esi
  800597:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059a:	eb 18                	jmp    8005b4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059c:	83 ec 08             	sub    $0x8,%esp
  80059f:	53                   	push   %ebx
  8005a0:	6a 20                	push   $0x20
  8005a2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a4:	83 ef 01             	sub    $0x1,%edi
  8005a7:	83 c4 10             	add    $0x10,%esp
  8005aa:	eb 08                	jmp    8005b4 <vprintfmt+0x278>
  8005ac:	89 df                	mov    %ebx,%edi
  8005ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b4:	85 ff                	test   %edi,%edi
  8005b6:	7f e4                	jg     80059c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bb:	e9 a2 fd ff ff       	jmp    800362 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c0:	83 fa 01             	cmp    $0x1,%edx
  8005c3:	7e 16                	jle    8005db <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 50 08             	lea    0x8(%eax),%edx
  8005cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ce:	8b 50 04             	mov    0x4(%eax),%edx
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005d6:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005d9:	eb 32                	jmp    80060d <vprintfmt+0x2d1>
	else if (lflag)
  8005db:	85 d2                	test   %edx,%edx
  8005dd:	74 18                	je     8005f7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 50 04             	lea    0x4(%eax),%edx
  8005e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e8:	8b 00                	mov    (%eax),%eax
  8005ea:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005ed:	89 c1                	mov    %eax,%ecx
  8005ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005f5:	eb 16                	jmp    80060d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 50 04             	lea    0x4(%eax),%edx
  8005fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800600:	8b 00                	mov    (%eax),%eax
  800602:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800605:	89 c1                	mov    %eax,%ecx
  800607:	c1 f9 1f             	sar    $0x1f,%ecx
  80060a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800610:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800613:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800616:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80061e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800622:	0f 89 a8 00 00 00    	jns    8006d0 <vprintfmt+0x394>
				putch('-', putdat);
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	53                   	push   %ebx
  80062c:	6a 2d                	push   $0x2d
  80062e:	ff d6                	call   *%esi
				num = -(long long) num;
  800630:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800633:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800636:	f7 d8                	neg    %eax
  800638:	83 d2 00             	adc    $0x0,%edx
  80063b:	f7 da                	neg    %edx
  80063d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800640:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800643:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800646:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064b:	e9 80 00 00 00       	jmp    8006d0 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800650:	8d 45 14             	lea    0x14(%ebp),%eax
  800653:	e8 70 fc ff ff       	call   8002c8 <getuint>
  800658:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80065e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800663:	eb 6b                	jmp    8006d0 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800665:	8d 45 14             	lea    0x14(%ebp),%eax
  800668:	e8 5b fc ff ff       	call   8002c8 <getuint>
  80066d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800670:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800673:	6a 04                	push   $0x4
  800675:	6a 03                	push   $0x3
  800677:	6a 01                	push   $0x1
  800679:	68 ff 10 80 00       	push   $0x8010ff
  80067e:	e8 82 fb ff ff       	call   800205 <cprintf>
			goto number;
  800683:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  800686:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  80068b:	eb 43                	jmp    8006d0 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	6a 30                	push   $0x30
  800693:	ff d6                	call   *%esi
			putch('x', putdat);
  800695:	83 c4 08             	add    $0x8,%esp
  800698:	53                   	push   %ebx
  800699:	6a 78                	push   $0x78
  80069b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8d 50 04             	lea    0x4(%eax),%edx
  8006a3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a6:	8b 00                	mov    (%eax),%eax
  8006a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006bb:	eb 13                	jmp    8006d0 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c0:	e8 03 fc ff ff       	call   8002c8 <getuint>
  8006c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006cb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d0:	83 ec 0c             	sub    $0xc,%esp
  8006d3:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006d7:	52                   	push   %edx
  8006d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006db:	50                   	push   %eax
  8006dc:	ff 75 dc             	pushl  -0x24(%ebp)
  8006df:	ff 75 d8             	pushl  -0x28(%ebp)
  8006e2:	89 da                	mov    %ebx,%edx
  8006e4:	89 f0                	mov    %esi,%eax
  8006e6:	e8 2e fb ff ff       	call   800219 <printnum>

			break;
  8006eb:	83 c4 20             	add    $0x20,%esp
  8006ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f1:	e9 6c fc ff ff       	jmp    800362 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	53                   	push   %ebx
  8006fa:	51                   	push   %ecx
  8006fb:	ff d6                	call   *%esi
			break;
  8006fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800700:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800703:	e9 5a fc ff ff       	jmp    800362 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	6a 25                	push   $0x25
  80070e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800710:	83 c4 10             	add    $0x10,%esp
  800713:	eb 03                	jmp    800718 <vprintfmt+0x3dc>
  800715:	83 ef 01             	sub    $0x1,%edi
  800718:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80071c:	75 f7                	jne    800715 <vprintfmt+0x3d9>
  80071e:	e9 3f fc ff ff       	jmp    800362 <vprintfmt+0x26>
			break;
		}

	}

}
  800723:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800726:	5b                   	pop    %ebx
  800727:	5e                   	pop    %esi
  800728:	5f                   	pop    %edi
  800729:	5d                   	pop    %ebp
  80072a:	c3                   	ret    

0080072b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	83 ec 18             	sub    $0x18,%esp
  800731:	8b 45 08             	mov    0x8(%ebp),%eax
  800734:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800737:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80073e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800741:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800748:	85 c0                	test   %eax,%eax
  80074a:	74 26                	je     800772 <vsnprintf+0x47>
  80074c:	85 d2                	test   %edx,%edx
  80074e:	7e 22                	jle    800772 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800750:	ff 75 14             	pushl  0x14(%ebp)
  800753:	ff 75 10             	pushl  0x10(%ebp)
  800756:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800759:	50                   	push   %eax
  80075a:	68 02 03 80 00       	push   $0x800302
  80075f:	e8 d8 fb ff ff       	call   80033c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800764:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800767:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076d:	83 c4 10             	add    $0x10,%esp
  800770:	eb 05                	jmp    800777 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800772:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800777:	c9                   	leave  
  800778:	c3                   	ret    

00800779 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80077f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800782:	50                   	push   %eax
  800783:	ff 75 10             	pushl  0x10(%ebp)
  800786:	ff 75 0c             	pushl  0xc(%ebp)
  800789:	ff 75 08             	pushl  0x8(%ebp)
  80078c:	e8 9a ff ff ff       	call   80072b <vsnprintf>
	va_end(ap);

	return rc;
}
  800791:	c9                   	leave  
  800792:	c3                   	ret    

00800793 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800799:	b8 00 00 00 00       	mov    $0x0,%eax
  80079e:	eb 03                	jmp    8007a3 <strlen+0x10>
		n++;
  8007a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a7:	75 f7                	jne    8007a0 <strlen+0xd>
		n++;
	return n;
}
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    

008007ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b9:	eb 03                	jmp    8007be <strnlen+0x13>
		n++;
  8007bb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007be:	39 c2                	cmp    %eax,%edx
  8007c0:	74 08                	je     8007ca <strnlen+0x1f>
  8007c2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007c6:	75 f3                	jne    8007bb <strnlen+0x10>
  8007c8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	53                   	push   %ebx
  8007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d6:	89 c2                	mov    %eax,%edx
  8007d8:	83 c2 01             	add    $0x1,%edx
  8007db:	83 c1 01             	add    $0x1,%ecx
  8007de:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007e2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e5:	84 db                	test   %bl,%bl
  8007e7:	75 ef                	jne    8007d8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007e9:	5b                   	pop    %ebx
  8007ea:	5d                   	pop    %ebp
  8007eb:	c3                   	ret    

008007ec <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	53                   	push   %ebx
  8007f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f3:	53                   	push   %ebx
  8007f4:	e8 9a ff ff ff       	call   800793 <strlen>
  8007f9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007fc:	ff 75 0c             	pushl  0xc(%ebp)
  8007ff:	01 d8                	add    %ebx,%eax
  800801:	50                   	push   %eax
  800802:	e8 c5 ff ff ff       	call   8007cc <strcpy>
	return dst;
}
  800807:	89 d8                	mov    %ebx,%eax
  800809:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080c:	c9                   	leave  
  80080d:	c3                   	ret    

0080080e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	56                   	push   %esi
  800812:	53                   	push   %ebx
  800813:	8b 75 08             	mov    0x8(%ebp),%esi
  800816:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800819:	89 f3                	mov    %esi,%ebx
  80081b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081e:	89 f2                	mov    %esi,%edx
  800820:	eb 0f                	jmp    800831 <strncpy+0x23>
		*dst++ = *src;
  800822:	83 c2 01             	add    $0x1,%edx
  800825:	0f b6 01             	movzbl (%ecx),%eax
  800828:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082b:	80 39 01             	cmpb   $0x1,(%ecx)
  80082e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800831:	39 da                	cmp    %ebx,%edx
  800833:	75 ed                	jne    800822 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800835:	89 f0                	mov    %esi,%eax
  800837:	5b                   	pop    %ebx
  800838:	5e                   	pop    %esi
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	56                   	push   %esi
  80083f:	53                   	push   %ebx
  800840:	8b 75 08             	mov    0x8(%ebp),%esi
  800843:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800846:	8b 55 10             	mov    0x10(%ebp),%edx
  800849:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084b:	85 d2                	test   %edx,%edx
  80084d:	74 21                	je     800870 <strlcpy+0x35>
  80084f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800853:	89 f2                	mov    %esi,%edx
  800855:	eb 09                	jmp    800860 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800857:	83 c2 01             	add    $0x1,%edx
  80085a:	83 c1 01             	add    $0x1,%ecx
  80085d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800860:	39 c2                	cmp    %eax,%edx
  800862:	74 09                	je     80086d <strlcpy+0x32>
  800864:	0f b6 19             	movzbl (%ecx),%ebx
  800867:	84 db                	test   %bl,%bl
  800869:	75 ec                	jne    800857 <strlcpy+0x1c>
  80086b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80086d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800870:	29 f0                	sub    %esi,%eax
}
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087f:	eb 06                	jmp    800887 <strcmp+0x11>
		p++, q++;
  800881:	83 c1 01             	add    $0x1,%ecx
  800884:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800887:	0f b6 01             	movzbl (%ecx),%eax
  80088a:	84 c0                	test   %al,%al
  80088c:	74 04                	je     800892 <strcmp+0x1c>
  80088e:	3a 02                	cmp    (%edx),%al
  800890:	74 ef                	je     800881 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800892:	0f b6 c0             	movzbl %al,%eax
  800895:	0f b6 12             	movzbl (%edx),%edx
  800898:	29 d0                	sub    %edx,%eax
}
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	53                   	push   %ebx
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a6:	89 c3                	mov    %eax,%ebx
  8008a8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ab:	eb 06                	jmp    8008b3 <strncmp+0x17>
		n--, p++, q++;
  8008ad:	83 c0 01             	add    $0x1,%eax
  8008b0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b3:	39 d8                	cmp    %ebx,%eax
  8008b5:	74 15                	je     8008cc <strncmp+0x30>
  8008b7:	0f b6 08             	movzbl (%eax),%ecx
  8008ba:	84 c9                	test   %cl,%cl
  8008bc:	74 04                	je     8008c2 <strncmp+0x26>
  8008be:	3a 0a                	cmp    (%edx),%cl
  8008c0:	74 eb                	je     8008ad <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c2:	0f b6 00             	movzbl (%eax),%eax
  8008c5:	0f b6 12             	movzbl (%edx),%edx
  8008c8:	29 d0                	sub    %edx,%eax
  8008ca:	eb 05                	jmp    8008d1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d1:	5b                   	pop    %ebx
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008de:	eb 07                	jmp    8008e7 <strchr+0x13>
		if (*s == c)
  8008e0:	38 ca                	cmp    %cl,%dl
  8008e2:	74 0f                	je     8008f3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e4:	83 c0 01             	add    $0x1,%eax
  8008e7:	0f b6 10             	movzbl (%eax),%edx
  8008ea:	84 d2                	test   %dl,%dl
  8008ec:	75 f2                	jne    8008e0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ff:	eb 03                	jmp    800904 <strfind+0xf>
  800901:	83 c0 01             	add    $0x1,%eax
  800904:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800907:	38 ca                	cmp    %cl,%dl
  800909:	74 04                	je     80090f <strfind+0x1a>
  80090b:	84 d2                	test   %dl,%dl
  80090d:	75 f2                	jne    800901 <strfind+0xc>
			break;
	return (char *) s;
}
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	57                   	push   %edi
  800915:	56                   	push   %esi
  800916:	53                   	push   %ebx
  800917:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80091d:	85 c9                	test   %ecx,%ecx
  80091f:	74 36                	je     800957 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800921:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800927:	75 28                	jne    800951 <memset+0x40>
  800929:	f6 c1 03             	test   $0x3,%cl
  80092c:	75 23                	jne    800951 <memset+0x40>
		c &= 0xFF;
  80092e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800932:	89 d3                	mov    %edx,%ebx
  800934:	c1 e3 08             	shl    $0x8,%ebx
  800937:	89 d6                	mov    %edx,%esi
  800939:	c1 e6 18             	shl    $0x18,%esi
  80093c:	89 d0                	mov    %edx,%eax
  80093e:	c1 e0 10             	shl    $0x10,%eax
  800941:	09 f0                	or     %esi,%eax
  800943:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800945:	89 d8                	mov    %ebx,%eax
  800947:	09 d0                	or     %edx,%eax
  800949:	c1 e9 02             	shr    $0x2,%ecx
  80094c:	fc                   	cld    
  80094d:	f3 ab                	rep stos %eax,%es:(%edi)
  80094f:	eb 06                	jmp    800957 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800951:	8b 45 0c             	mov    0xc(%ebp),%eax
  800954:	fc                   	cld    
  800955:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800957:	89 f8                	mov    %edi,%eax
  800959:	5b                   	pop    %ebx
  80095a:	5e                   	pop    %esi
  80095b:	5f                   	pop    %edi
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	57                   	push   %edi
  800962:	56                   	push   %esi
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
  800966:	8b 75 0c             	mov    0xc(%ebp),%esi
  800969:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096c:	39 c6                	cmp    %eax,%esi
  80096e:	73 35                	jae    8009a5 <memmove+0x47>
  800970:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800973:	39 d0                	cmp    %edx,%eax
  800975:	73 2e                	jae    8009a5 <memmove+0x47>
		s += n;
		d += n;
  800977:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097a:	89 d6                	mov    %edx,%esi
  80097c:	09 fe                	or     %edi,%esi
  80097e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800984:	75 13                	jne    800999 <memmove+0x3b>
  800986:	f6 c1 03             	test   $0x3,%cl
  800989:	75 0e                	jne    800999 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80098b:	83 ef 04             	sub    $0x4,%edi
  80098e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800991:	c1 e9 02             	shr    $0x2,%ecx
  800994:	fd                   	std    
  800995:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800997:	eb 09                	jmp    8009a2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800999:	83 ef 01             	sub    $0x1,%edi
  80099c:	8d 72 ff             	lea    -0x1(%edx),%esi
  80099f:	fd                   	std    
  8009a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a2:	fc                   	cld    
  8009a3:	eb 1d                	jmp    8009c2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a5:	89 f2                	mov    %esi,%edx
  8009a7:	09 c2                	or     %eax,%edx
  8009a9:	f6 c2 03             	test   $0x3,%dl
  8009ac:	75 0f                	jne    8009bd <memmove+0x5f>
  8009ae:	f6 c1 03             	test   $0x3,%cl
  8009b1:	75 0a                	jne    8009bd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009b3:	c1 e9 02             	shr    $0x2,%ecx
  8009b6:	89 c7                	mov    %eax,%edi
  8009b8:	fc                   	cld    
  8009b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bb:	eb 05                	jmp    8009c2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009bd:	89 c7                	mov    %eax,%edi
  8009bf:	fc                   	cld    
  8009c0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c2:	5e                   	pop    %esi
  8009c3:	5f                   	pop    %edi
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009c9:	ff 75 10             	pushl  0x10(%ebp)
  8009cc:	ff 75 0c             	pushl  0xc(%ebp)
  8009cf:	ff 75 08             	pushl  0x8(%ebp)
  8009d2:	e8 87 ff ff ff       	call   80095e <memmove>
}
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    

008009d9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	56                   	push   %esi
  8009dd:	53                   	push   %ebx
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e4:	89 c6                	mov    %eax,%esi
  8009e6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e9:	eb 1a                	jmp    800a05 <memcmp+0x2c>
		if (*s1 != *s2)
  8009eb:	0f b6 08             	movzbl (%eax),%ecx
  8009ee:	0f b6 1a             	movzbl (%edx),%ebx
  8009f1:	38 d9                	cmp    %bl,%cl
  8009f3:	74 0a                	je     8009ff <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009f5:	0f b6 c1             	movzbl %cl,%eax
  8009f8:	0f b6 db             	movzbl %bl,%ebx
  8009fb:	29 d8                	sub    %ebx,%eax
  8009fd:	eb 0f                	jmp    800a0e <memcmp+0x35>
		s1++, s2++;
  8009ff:	83 c0 01             	add    $0x1,%eax
  800a02:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a05:	39 f0                	cmp    %esi,%eax
  800a07:	75 e2                	jne    8009eb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0e:	5b                   	pop    %ebx
  800a0f:	5e                   	pop    %esi
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	53                   	push   %ebx
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a19:	89 c1                	mov    %eax,%ecx
  800a1b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a22:	eb 0a                	jmp    800a2e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a24:	0f b6 10             	movzbl (%eax),%edx
  800a27:	39 da                	cmp    %ebx,%edx
  800a29:	74 07                	je     800a32 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2b:	83 c0 01             	add    $0x1,%eax
  800a2e:	39 c8                	cmp    %ecx,%eax
  800a30:	72 f2                	jb     800a24 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a32:	5b                   	pop    %ebx
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	57                   	push   %edi
  800a39:	56                   	push   %esi
  800a3a:	53                   	push   %ebx
  800a3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a41:	eb 03                	jmp    800a46 <strtol+0x11>
		s++;
  800a43:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a46:	0f b6 01             	movzbl (%ecx),%eax
  800a49:	3c 20                	cmp    $0x20,%al
  800a4b:	74 f6                	je     800a43 <strtol+0xe>
  800a4d:	3c 09                	cmp    $0x9,%al
  800a4f:	74 f2                	je     800a43 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a51:	3c 2b                	cmp    $0x2b,%al
  800a53:	75 0a                	jne    800a5f <strtol+0x2a>
		s++;
  800a55:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a58:	bf 00 00 00 00       	mov    $0x0,%edi
  800a5d:	eb 11                	jmp    800a70 <strtol+0x3b>
  800a5f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a64:	3c 2d                	cmp    $0x2d,%al
  800a66:	75 08                	jne    800a70 <strtol+0x3b>
		s++, neg = 1;
  800a68:	83 c1 01             	add    $0x1,%ecx
  800a6b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a70:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a76:	75 15                	jne    800a8d <strtol+0x58>
  800a78:	80 39 30             	cmpb   $0x30,(%ecx)
  800a7b:	75 10                	jne    800a8d <strtol+0x58>
  800a7d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a81:	75 7c                	jne    800aff <strtol+0xca>
		s += 2, base = 16;
  800a83:	83 c1 02             	add    $0x2,%ecx
  800a86:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8b:	eb 16                	jmp    800aa3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a8d:	85 db                	test   %ebx,%ebx
  800a8f:	75 12                	jne    800aa3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a91:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a96:	80 39 30             	cmpb   $0x30,(%ecx)
  800a99:	75 08                	jne    800aa3 <strtol+0x6e>
		s++, base = 8;
  800a9b:	83 c1 01             	add    $0x1,%ecx
  800a9e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aa3:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aab:	0f b6 11             	movzbl (%ecx),%edx
  800aae:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab1:	89 f3                	mov    %esi,%ebx
  800ab3:	80 fb 09             	cmp    $0x9,%bl
  800ab6:	77 08                	ja     800ac0 <strtol+0x8b>
			dig = *s - '0';
  800ab8:	0f be d2             	movsbl %dl,%edx
  800abb:	83 ea 30             	sub    $0x30,%edx
  800abe:	eb 22                	jmp    800ae2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ac0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ac3:	89 f3                	mov    %esi,%ebx
  800ac5:	80 fb 19             	cmp    $0x19,%bl
  800ac8:	77 08                	ja     800ad2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aca:	0f be d2             	movsbl %dl,%edx
  800acd:	83 ea 57             	sub    $0x57,%edx
  800ad0:	eb 10                	jmp    800ae2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ad2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ad5:	89 f3                	mov    %esi,%ebx
  800ad7:	80 fb 19             	cmp    $0x19,%bl
  800ada:	77 16                	ja     800af2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800adc:	0f be d2             	movsbl %dl,%edx
  800adf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ae2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae5:	7d 0b                	jge    800af2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ae7:	83 c1 01             	add    $0x1,%ecx
  800aea:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aee:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800af0:	eb b9                	jmp    800aab <strtol+0x76>

	if (endptr)
  800af2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af6:	74 0d                	je     800b05 <strtol+0xd0>
		*endptr = (char *) s;
  800af8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afb:	89 0e                	mov    %ecx,(%esi)
  800afd:	eb 06                	jmp    800b05 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aff:	85 db                	test   %ebx,%ebx
  800b01:	74 98                	je     800a9b <strtol+0x66>
  800b03:	eb 9e                	jmp    800aa3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b05:	89 c2                	mov    %eax,%edx
  800b07:	f7 da                	neg    %edx
  800b09:	85 ff                	test   %edi,%edi
  800b0b:	0f 45 c2             	cmovne %edx,%eax
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b19:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b21:	8b 55 08             	mov    0x8(%ebp),%edx
  800b24:	89 c3                	mov    %eax,%ebx
  800b26:	89 c7                	mov    %eax,%edi
  800b28:	89 c6                	mov    %eax,%esi
  800b2a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b37:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b41:	89 d1                	mov    %edx,%ecx
  800b43:	89 d3                	mov    %edx,%ebx
  800b45:	89 d7                	mov    %edx,%edi
  800b47:	89 d6                	mov    %edx,%esi
  800b49:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4b:	5b                   	pop    %ebx
  800b4c:	5e                   	pop    %esi
  800b4d:	5f                   	pop    %edi
  800b4e:	5d                   	pop    %ebp
  800b4f:	c3                   	ret    

00800b50 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	57                   	push   %edi
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
  800b56:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b63:	8b 55 08             	mov    0x8(%ebp),%edx
  800b66:	89 cb                	mov    %ecx,%ebx
  800b68:	89 cf                	mov    %ecx,%edi
  800b6a:	89 ce                	mov    %ecx,%esi
  800b6c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b6e:	85 c0                	test   %eax,%eax
  800b70:	7e 17                	jle    800b89 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b72:	83 ec 0c             	sub    $0xc,%esp
  800b75:	50                   	push   %eax
  800b76:	6a 03                	push   $0x3
  800b78:	68 48 13 80 00       	push   $0x801348
  800b7d:	6a 23                	push   $0x23
  800b7f:	68 65 13 80 00       	push   $0x801365
  800b84:	e8 a3 f5 ff ff       	call   80012c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	57                   	push   %edi
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b97:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9c:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba1:	89 d1                	mov    %edx,%ecx
  800ba3:	89 d3                	mov    %edx,%ebx
  800ba5:	89 d7                	mov    %edx,%edi
  800ba7:	89 d6                	mov    %edx,%esi
  800ba9:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <sys_yield>:

void
sys_yield(void)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bc0:	89 d1                	mov    %edx,%ecx
  800bc2:	89 d3                	mov    %edx,%ebx
  800bc4:	89 d7                	mov    %edx,%edi
  800bc6:	89 d6                	mov    %edx,%esi
  800bc8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bca:	5b                   	pop    %ebx
  800bcb:	5e                   	pop    %esi
  800bcc:	5f                   	pop    %edi
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	57                   	push   %edi
  800bd3:	56                   	push   %esi
  800bd4:	53                   	push   %ebx
  800bd5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd8:	be 00 00 00 00       	mov    $0x0,%esi
  800bdd:	b8 04 00 00 00       	mov    $0x4,%eax
  800be2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be5:	8b 55 08             	mov    0x8(%ebp),%edx
  800be8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800beb:	89 f7                	mov    %esi,%edi
  800bed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	7e 17                	jle    800c0a <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf3:	83 ec 0c             	sub    $0xc,%esp
  800bf6:	50                   	push   %eax
  800bf7:	6a 04                	push   $0x4
  800bf9:	68 48 13 80 00       	push   $0x801348
  800bfe:	6a 23                	push   $0x23
  800c00:	68 65 13 80 00       	push   $0x801365
  800c05:	e8 22 f5 ff ff       	call   80012c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c23:	8b 55 08             	mov    0x8(%ebp),%edx
  800c26:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c29:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c2c:	8b 75 18             	mov    0x18(%ebp),%esi
  800c2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c31:	85 c0                	test   %eax,%eax
  800c33:	7e 17                	jle    800c4c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c35:	83 ec 0c             	sub    $0xc,%esp
  800c38:	50                   	push   %eax
  800c39:	6a 05                	push   $0x5
  800c3b:	68 48 13 80 00       	push   $0x801348
  800c40:	6a 23                	push   $0x23
  800c42:	68 65 13 80 00       	push   $0x801365
  800c47:	e8 e0 f4 ff ff       	call   80012c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
  800c5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c62:	b8 06 00 00 00       	mov    $0x6,%eax
  800c67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6d:	89 df                	mov    %ebx,%edi
  800c6f:	89 de                	mov    %ebx,%esi
  800c71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c73:	85 c0                	test   %eax,%eax
  800c75:	7e 17                	jle    800c8e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c77:	83 ec 0c             	sub    $0xc,%esp
  800c7a:	50                   	push   %eax
  800c7b:	6a 06                	push   $0x6
  800c7d:	68 48 13 80 00       	push   $0x801348
  800c82:	6a 23                	push   $0x23
  800c84:	68 65 13 80 00       	push   $0x801365
  800c89:	e8 9e f4 ff ff       	call   80012c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
  800c9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca4:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cac:	8b 55 08             	mov    0x8(%ebp),%edx
  800caf:	89 df                	mov    %ebx,%edi
  800cb1:	89 de                	mov    %ebx,%esi
  800cb3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	7e 17                	jle    800cd0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb9:	83 ec 0c             	sub    $0xc,%esp
  800cbc:	50                   	push   %eax
  800cbd:	6a 08                	push   $0x8
  800cbf:	68 48 13 80 00       	push   $0x801348
  800cc4:	6a 23                	push   $0x23
  800cc6:	68 65 13 80 00       	push   $0x801365
  800ccb:	e8 5c f4 ff ff       	call   80012c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd3:	5b                   	pop    %ebx
  800cd4:	5e                   	pop    %esi
  800cd5:	5f                   	pop    %edi
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    

00800cd8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
  800cde:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce6:	b8 09 00 00 00       	mov    $0x9,%eax
  800ceb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	89 df                	mov    %ebx,%edi
  800cf3:	89 de                	mov    %ebx,%esi
  800cf5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	7e 17                	jle    800d12 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfb:	83 ec 0c             	sub    $0xc,%esp
  800cfe:	50                   	push   %eax
  800cff:	6a 09                	push   $0x9
  800d01:	68 48 13 80 00       	push   $0x801348
  800d06:	6a 23                	push   $0x23
  800d08:	68 65 13 80 00       	push   $0x801365
  800d0d:	e8 1a f4 ff ff       	call   80012c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d20:	be 00 00 00 00       	mov    $0x0,%esi
  800d25:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d33:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d36:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d4b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d50:	8b 55 08             	mov    0x8(%ebp),%edx
  800d53:	89 cb                	mov    %ecx,%ebx
  800d55:	89 cf                	mov    %ecx,%edi
  800d57:	89 ce                	mov    %ecx,%esi
  800d59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	7e 17                	jle    800d76 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5f:	83 ec 0c             	sub    $0xc,%esp
  800d62:	50                   	push   %eax
  800d63:	6a 0c                	push   $0xc
  800d65:	68 48 13 80 00       	push   $0x801348
  800d6a:	6a 23                	push   $0x23
  800d6c:	68 65 13 80 00       	push   $0x801365
  800d71:	e8 b6 f3 ff ff       	call   80012c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d84:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d8b:	75 14                	jne    800da1 <set_pgfault_handler+0x23>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800d8d:	83 ec 04             	sub    $0x4,%esp
  800d90:	68 74 13 80 00       	push   $0x801374
  800d95:	6a 20                	push   $0x20
  800d97:	68 98 13 80 00       	push   $0x801398
  800d9c:	e8 8b f3 ff ff       	call   80012c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800da9:	c9                   	leave  
  800daa:	c3                   	ret    
  800dab:	66 90                	xchg   %ax,%ax
  800dad:	66 90                	xchg   %ax,%ax
  800daf:	90                   	nop

00800db0 <__udivdi3>:
  800db0:	55                   	push   %ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 1c             	sub    $0x1c,%esp
  800db7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800dbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800dbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800dc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800dc7:	85 f6                	test   %esi,%esi
  800dc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800dcd:	89 ca                	mov    %ecx,%edx
  800dcf:	89 f8                	mov    %edi,%eax
  800dd1:	75 3d                	jne    800e10 <__udivdi3+0x60>
  800dd3:	39 cf                	cmp    %ecx,%edi
  800dd5:	0f 87 c5 00 00 00    	ja     800ea0 <__udivdi3+0xf0>
  800ddb:	85 ff                	test   %edi,%edi
  800ddd:	89 fd                	mov    %edi,%ebp
  800ddf:	75 0b                	jne    800dec <__udivdi3+0x3c>
  800de1:	b8 01 00 00 00       	mov    $0x1,%eax
  800de6:	31 d2                	xor    %edx,%edx
  800de8:	f7 f7                	div    %edi
  800dea:	89 c5                	mov    %eax,%ebp
  800dec:	89 c8                	mov    %ecx,%eax
  800dee:	31 d2                	xor    %edx,%edx
  800df0:	f7 f5                	div    %ebp
  800df2:	89 c1                	mov    %eax,%ecx
  800df4:	89 d8                	mov    %ebx,%eax
  800df6:	89 cf                	mov    %ecx,%edi
  800df8:	f7 f5                	div    %ebp
  800dfa:	89 c3                	mov    %eax,%ebx
  800dfc:	89 d8                	mov    %ebx,%eax
  800dfe:	89 fa                	mov    %edi,%edx
  800e00:	83 c4 1c             	add    $0x1c,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
  800e08:	90                   	nop
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	39 ce                	cmp    %ecx,%esi
  800e12:	77 74                	ja     800e88 <__udivdi3+0xd8>
  800e14:	0f bd fe             	bsr    %esi,%edi
  800e17:	83 f7 1f             	xor    $0x1f,%edi
  800e1a:	0f 84 98 00 00 00    	je     800eb8 <__udivdi3+0x108>
  800e20:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e25:	89 f9                	mov    %edi,%ecx
  800e27:	89 c5                	mov    %eax,%ebp
  800e29:	29 fb                	sub    %edi,%ebx
  800e2b:	d3 e6                	shl    %cl,%esi
  800e2d:	89 d9                	mov    %ebx,%ecx
  800e2f:	d3 ed                	shr    %cl,%ebp
  800e31:	89 f9                	mov    %edi,%ecx
  800e33:	d3 e0                	shl    %cl,%eax
  800e35:	09 ee                	or     %ebp,%esi
  800e37:	89 d9                	mov    %ebx,%ecx
  800e39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e3d:	89 d5                	mov    %edx,%ebp
  800e3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e43:	d3 ed                	shr    %cl,%ebp
  800e45:	89 f9                	mov    %edi,%ecx
  800e47:	d3 e2                	shl    %cl,%edx
  800e49:	89 d9                	mov    %ebx,%ecx
  800e4b:	d3 e8                	shr    %cl,%eax
  800e4d:	09 c2                	or     %eax,%edx
  800e4f:	89 d0                	mov    %edx,%eax
  800e51:	89 ea                	mov    %ebp,%edx
  800e53:	f7 f6                	div    %esi
  800e55:	89 d5                	mov    %edx,%ebp
  800e57:	89 c3                	mov    %eax,%ebx
  800e59:	f7 64 24 0c          	mull   0xc(%esp)
  800e5d:	39 d5                	cmp    %edx,%ebp
  800e5f:	72 10                	jb     800e71 <__udivdi3+0xc1>
  800e61:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e65:	89 f9                	mov    %edi,%ecx
  800e67:	d3 e6                	shl    %cl,%esi
  800e69:	39 c6                	cmp    %eax,%esi
  800e6b:	73 07                	jae    800e74 <__udivdi3+0xc4>
  800e6d:	39 d5                	cmp    %edx,%ebp
  800e6f:	75 03                	jne    800e74 <__udivdi3+0xc4>
  800e71:	83 eb 01             	sub    $0x1,%ebx
  800e74:	31 ff                	xor    %edi,%edi
  800e76:	89 d8                	mov    %ebx,%eax
  800e78:	89 fa                	mov    %edi,%edx
  800e7a:	83 c4 1c             	add    $0x1c,%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
  800e82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e88:	31 ff                	xor    %edi,%edi
  800e8a:	31 db                	xor    %ebx,%ebx
  800e8c:	89 d8                	mov    %ebx,%eax
  800e8e:	89 fa                	mov    %edi,%edx
  800e90:	83 c4 1c             	add    $0x1c,%esp
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5f                   	pop    %edi
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    
  800e98:	90                   	nop
  800e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	89 d8                	mov    %ebx,%eax
  800ea2:	f7 f7                	div    %edi
  800ea4:	31 ff                	xor    %edi,%edi
  800ea6:	89 c3                	mov    %eax,%ebx
  800ea8:	89 d8                	mov    %ebx,%eax
  800eaa:	89 fa                	mov    %edi,%edx
  800eac:	83 c4 1c             	add    $0x1c,%esp
  800eaf:	5b                   	pop    %ebx
  800eb0:	5e                   	pop    %esi
  800eb1:	5f                   	pop    %edi
  800eb2:	5d                   	pop    %ebp
  800eb3:	c3                   	ret    
  800eb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800eb8:	39 ce                	cmp    %ecx,%esi
  800eba:	72 0c                	jb     800ec8 <__udivdi3+0x118>
  800ebc:	31 db                	xor    %ebx,%ebx
  800ebe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ec2:	0f 87 34 ff ff ff    	ja     800dfc <__udivdi3+0x4c>
  800ec8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ecd:	e9 2a ff ff ff       	jmp    800dfc <__udivdi3+0x4c>
  800ed2:	66 90                	xchg   %ax,%ax
  800ed4:	66 90                	xchg   %ax,%ax
  800ed6:	66 90                	xchg   %ax,%ax
  800ed8:	66 90                	xchg   %ax,%ax
  800eda:	66 90                	xchg   %ax,%ax
  800edc:	66 90                	xchg   %ax,%ax
  800ede:	66 90                	xchg   %ax,%ax

00800ee0 <__umoddi3>:
  800ee0:	55                   	push   %ebp
  800ee1:	57                   	push   %edi
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 1c             	sub    $0x1c,%esp
  800ee7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800eeb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800eef:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ef3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ef7:	85 d2                	test   %edx,%edx
  800ef9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800efd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f01:	89 f3                	mov    %esi,%ebx
  800f03:	89 3c 24             	mov    %edi,(%esp)
  800f06:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f0a:	75 1c                	jne    800f28 <__umoddi3+0x48>
  800f0c:	39 f7                	cmp    %esi,%edi
  800f0e:	76 50                	jbe    800f60 <__umoddi3+0x80>
  800f10:	89 c8                	mov    %ecx,%eax
  800f12:	89 f2                	mov    %esi,%edx
  800f14:	f7 f7                	div    %edi
  800f16:	89 d0                	mov    %edx,%eax
  800f18:	31 d2                	xor    %edx,%edx
  800f1a:	83 c4 1c             	add    $0x1c,%esp
  800f1d:	5b                   	pop    %ebx
  800f1e:	5e                   	pop    %esi
  800f1f:	5f                   	pop    %edi
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    
  800f22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f28:	39 f2                	cmp    %esi,%edx
  800f2a:	89 d0                	mov    %edx,%eax
  800f2c:	77 52                	ja     800f80 <__umoddi3+0xa0>
  800f2e:	0f bd ea             	bsr    %edx,%ebp
  800f31:	83 f5 1f             	xor    $0x1f,%ebp
  800f34:	75 5a                	jne    800f90 <__umoddi3+0xb0>
  800f36:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f3a:	0f 82 e0 00 00 00    	jb     801020 <__umoddi3+0x140>
  800f40:	39 0c 24             	cmp    %ecx,(%esp)
  800f43:	0f 86 d7 00 00 00    	jbe    801020 <__umoddi3+0x140>
  800f49:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f4d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f51:	83 c4 1c             	add    $0x1c,%esp
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    
  800f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f60:	85 ff                	test   %edi,%edi
  800f62:	89 fd                	mov    %edi,%ebp
  800f64:	75 0b                	jne    800f71 <__umoddi3+0x91>
  800f66:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6b:	31 d2                	xor    %edx,%edx
  800f6d:	f7 f7                	div    %edi
  800f6f:	89 c5                	mov    %eax,%ebp
  800f71:	89 f0                	mov    %esi,%eax
  800f73:	31 d2                	xor    %edx,%edx
  800f75:	f7 f5                	div    %ebp
  800f77:	89 c8                	mov    %ecx,%eax
  800f79:	f7 f5                	div    %ebp
  800f7b:	89 d0                	mov    %edx,%eax
  800f7d:	eb 99                	jmp    800f18 <__umoddi3+0x38>
  800f7f:	90                   	nop
  800f80:	89 c8                	mov    %ecx,%eax
  800f82:	89 f2                	mov    %esi,%edx
  800f84:	83 c4 1c             	add    $0x1c,%esp
  800f87:	5b                   	pop    %ebx
  800f88:	5e                   	pop    %esi
  800f89:	5f                   	pop    %edi
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    
  800f8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f90:	8b 34 24             	mov    (%esp),%esi
  800f93:	bf 20 00 00 00       	mov    $0x20,%edi
  800f98:	89 e9                	mov    %ebp,%ecx
  800f9a:	29 ef                	sub    %ebp,%edi
  800f9c:	d3 e0                	shl    %cl,%eax
  800f9e:	89 f9                	mov    %edi,%ecx
  800fa0:	89 f2                	mov    %esi,%edx
  800fa2:	d3 ea                	shr    %cl,%edx
  800fa4:	89 e9                	mov    %ebp,%ecx
  800fa6:	09 c2                	or     %eax,%edx
  800fa8:	89 d8                	mov    %ebx,%eax
  800faa:	89 14 24             	mov    %edx,(%esp)
  800fad:	89 f2                	mov    %esi,%edx
  800faf:	d3 e2                	shl    %cl,%edx
  800fb1:	89 f9                	mov    %edi,%ecx
  800fb3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fb7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fbb:	d3 e8                	shr    %cl,%eax
  800fbd:	89 e9                	mov    %ebp,%ecx
  800fbf:	89 c6                	mov    %eax,%esi
  800fc1:	d3 e3                	shl    %cl,%ebx
  800fc3:	89 f9                	mov    %edi,%ecx
  800fc5:	89 d0                	mov    %edx,%eax
  800fc7:	d3 e8                	shr    %cl,%eax
  800fc9:	89 e9                	mov    %ebp,%ecx
  800fcb:	09 d8                	or     %ebx,%eax
  800fcd:	89 d3                	mov    %edx,%ebx
  800fcf:	89 f2                	mov    %esi,%edx
  800fd1:	f7 34 24             	divl   (%esp)
  800fd4:	89 d6                	mov    %edx,%esi
  800fd6:	d3 e3                	shl    %cl,%ebx
  800fd8:	f7 64 24 04          	mull   0x4(%esp)
  800fdc:	39 d6                	cmp    %edx,%esi
  800fde:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fe2:	89 d1                	mov    %edx,%ecx
  800fe4:	89 c3                	mov    %eax,%ebx
  800fe6:	72 08                	jb     800ff0 <__umoddi3+0x110>
  800fe8:	75 11                	jne    800ffb <__umoddi3+0x11b>
  800fea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800fee:	73 0b                	jae    800ffb <__umoddi3+0x11b>
  800ff0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800ff4:	1b 14 24             	sbb    (%esp),%edx
  800ff7:	89 d1                	mov    %edx,%ecx
  800ff9:	89 c3                	mov    %eax,%ebx
  800ffb:	8b 54 24 08          	mov    0x8(%esp),%edx
  800fff:	29 da                	sub    %ebx,%edx
  801001:	19 ce                	sbb    %ecx,%esi
  801003:	89 f9                	mov    %edi,%ecx
  801005:	89 f0                	mov    %esi,%eax
  801007:	d3 e0                	shl    %cl,%eax
  801009:	89 e9                	mov    %ebp,%ecx
  80100b:	d3 ea                	shr    %cl,%edx
  80100d:	89 e9                	mov    %ebp,%ecx
  80100f:	d3 ee                	shr    %cl,%esi
  801011:	09 d0                	or     %edx,%eax
  801013:	89 f2                	mov    %esi,%edx
  801015:	83 c4 1c             	add    $0x1c,%esp
  801018:	5b                   	pop    %ebx
  801019:	5e                   	pop    %esi
  80101a:	5f                   	pop    %edi
  80101b:	5d                   	pop    %ebp
  80101c:	c3                   	ret    
  80101d:	8d 76 00             	lea    0x0(%esi),%esi
  801020:	29 f9                	sub    %edi,%ecx
  801022:	19 d6                	sbb    %edx,%esi
  801024:	89 74 24 04          	mov    %esi,0x4(%esp)
  801028:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80102c:	e9 18 ff ff ff       	jmp    800f49 <__umoddi3+0x69>
