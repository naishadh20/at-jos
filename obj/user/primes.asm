
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 8e 0d 00 00       	call   800dda <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 20 80 00       	mov    0x802004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 e0 10 80 00       	push   $0x8010e0
  800060:	e8 ce 01 00 00       	call   800233 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 42 0d 00 00       	call   800dac <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 ec 10 80 00       	push   $0x8010ec
  800079:	6a 1a                	push   $0x1a
  80007b:	68 f5 10 80 00       	push   $0x8010f5
  800080:	e8 d5 00 00 00       	call   80015a <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 41 0d 00 00       	call   800dda <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 41 0d 00 00       	call   800df1 <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 ed 0c 00 00       	call   800dac <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 ec 10 80 00       	push   $0x8010ec
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 f5 10 80 00       	push   $0x8010f5
  8000d2:	e8 83 00 00 00       	call   80015a <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 01 0d 00 00       	call   800df1 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800103:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80010a:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  80010d:	e8 ad 0a 00 00       	call   800bbf <sys_getenvid>
  800112:	25 ff 03 00 00       	and    $0x3ff,%eax
  800117:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800124:	85 db                	test   %ebx,%ebx
  800126:	7e 07                	jle    80012f <libmain+0x37>
		binaryname = argv[0];
  800128:	8b 06                	mov    (%esi),%eax
  80012a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012f:	83 ec 08             	sub    $0x8,%esp
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
  800134:	e8 7c ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  800139:	e8 0a 00 00 00       	call   800148 <exit>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5d                   	pop    %ebp
  800147:	c3                   	ret    

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80014e:	6a 00                	push   $0x0
  800150:	e8 29 0a 00 00       	call   800b7e <sys_env_destroy>
}
  800155:	83 c4 10             	add    $0x10,%esp
  800158:	c9                   	leave  
  800159:	c3                   	ret    

0080015a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800162:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800168:	e8 52 0a 00 00       	call   800bbf <sys_getenvid>
  80016d:	83 ec 0c             	sub    $0xc,%esp
  800170:	ff 75 0c             	pushl  0xc(%ebp)
  800173:	ff 75 08             	pushl  0x8(%ebp)
  800176:	56                   	push   %esi
  800177:	50                   	push   %eax
  800178:	68 10 11 80 00       	push   $0x801110
  80017d:	e8 b1 00 00 00       	call   800233 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800182:	83 c4 18             	add    $0x18,%esp
  800185:	53                   	push   %ebx
  800186:	ff 75 10             	pushl  0x10(%ebp)
  800189:	e8 54 00 00 00       	call   8001e2 <vcprintf>
	cprintf("\n");
  80018e:	c7 04 24 68 11 80 00 	movl   $0x801168,(%esp)
  800195:	e8 99 00 00 00       	call   800233 <cprintf>
  80019a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019d:	cc                   	int3   
  80019e:	eb fd                	jmp    80019d <_panic+0x43>

008001a0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 04             	sub    $0x4,%esp
  8001a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001aa:	8b 13                	mov    (%ebx),%edx
  8001ac:	8d 42 01             	lea    0x1(%edx),%eax
  8001af:	89 03                	mov    %eax,(%ebx)
  8001b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bd:	75 1a                	jne    8001d9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001bf:	83 ec 08             	sub    $0x8,%esp
  8001c2:	68 ff 00 00 00       	push   $0xff
  8001c7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ca:	50                   	push   %eax
  8001cb:	e8 71 09 00 00       	call   800b41 <sys_cputs>
		b->idx = 0;
  8001d0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e0:	c9                   	leave  
  8001e1:	c3                   	ret    

008001e2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001eb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f2:	00 00 00 
	b.cnt = 0;
  8001f5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ff:	ff 75 0c             	pushl  0xc(%ebp)
  800202:	ff 75 08             	pushl  0x8(%ebp)
  800205:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020b:	50                   	push   %eax
  80020c:	68 a0 01 80 00       	push   $0x8001a0
  800211:	e8 54 01 00 00       	call   80036a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800216:	83 c4 08             	add    $0x8,%esp
  800219:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800225:	50                   	push   %eax
  800226:	e8 16 09 00 00       	call   800b41 <sys_cputs>

	return b.cnt;
}
  80022b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800239:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023c:	50                   	push   %eax
  80023d:	ff 75 08             	pushl  0x8(%ebp)
  800240:	e8 9d ff ff ff       	call   8001e2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800245:	c9                   	leave  
  800246:	c3                   	ret    

00800247 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	57                   	push   %edi
  80024b:	56                   	push   %esi
  80024c:	53                   	push   %ebx
  80024d:	83 ec 1c             	sub    $0x1c,%esp
  800250:	89 c7                	mov    %eax,%edi
  800252:	89 d6                	mov    %edx,%esi
  800254:	8b 45 08             	mov    0x8(%ebp),%eax
  800257:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800260:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800263:	bb 00 00 00 00       	mov    $0x0,%ebx
  800268:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80026b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026e:	39 d3                	cmp    %edx,%ebx
  800270:	72 05                	jb     800277 <printnum+0x30>
  800272:	39 45 10             	cmp    %eax,0x10(%ebp)
  800275:	77 45                	ja     8002bc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	ff 75 18             	pushl  0x18(%ebp)
  80027d:	8b 45 14             	mov    0x14(%ebp),%eax
  800280:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800283:	53                   	push   %ebx
  800284:	ff 75 10             	pushl  0x10(%ebp)
  800287:	83 ec 08             	sub    $0x8,%esp
  80028a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028d:	ff 75 e0             	pushl  -0x20(%ebp)
  800290:	ff 75 dc             	pushl  -0x24(%ebp)
  800293:	ff 75 d8             	pushl  -0x28(%ebp)
  800296:	e8 b5 0b 00 00       	call   800e50 <__udivdi3>
  80029b:	83 c4 18             	add    $0x18,%esp
  80029e:	52                   	push   %edx
  80029f:	50                   	push   %eax
  8002a0:	89 f2                	mov    %esi,%edx
  8002a2:	89 f8                	mov    %edi,%eax
  8002a4:	e8 9e ff ff ff       	call   800247 <printnum>
  8002a9:	83 c4 20             	add    $0x20,%esp
  8002ac:	eb 18                	jmp    8002c6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ae:	83 ec 08             	sub    $0x8,%esp
  8002b1:	56                   	push   %esi
  8002b2:	ff 75 18             	pushl  0x18(%ebp)
  8002b5:	ff d7                	call   *%edi
  8002b7:	83 c4 10             	add    $0x10,%esp
  8002ba:	eb 03                	jmp    8002bf <printnum+0x78>
  8002bc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bf:	83 eb 01             	sub    $0x1,%ebx
  8002c2:	85 db                	test   %ebx,%ebx
  8002c4:	7f e8                	jg     8002ae <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c6:	83 ec 08             	sub    $0x8,%esp
  8002c9:	56                   	push   %esi
  8002ca:	83 ec 04             	sub    $0x4,%esp
  8002cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d9:	e8 a2 0c 00 00       	call   800f80 <__umoddi3>
  8002de:	83 c4 14             	add    $0x14,%esp
  8002e1:	0f be 80 34 11 80 00 	movsbl 0x801134(%eax),%eax
  8002e8:	50                   	push   %eax
  8002e9:	ff d7                	call   *%edi
}
  8002eb:	83 c4 10             	add    $0x10,%esp
  8002ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f1:	5b                   	pop    %ebx
  8002f2:	5e                   	pop    %esi
  8002f3:	5f                   	pop    %edi
  8002f4:	5d                   	pop    %ebp
  8002f5:	c3                   	ret    

008002f6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f9:	83 fa 01             	cmp    $0x1,%edx
  8002fc:	7e 0e                	jle    80030c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	8d 4a 08             	lea    0x8(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 02                	mov    (%edx),%eax
  800307:	8b 52 04             	mov    0x4(%edx),%edx
  80030a:	eb 22                	jmp    80032e <getuint+0x38>
	else if (lflag)
  80030c:	85 d2                	test   %edx,%edx
  80030e:	74 10                	je     800320 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 04             	lea    0x4(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
  80031e:	eb 0e                	jmp    80032e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800320:	8b 10                	mov    (%eax),%edx
  800322:	8d 4a 04             	lea    0x4(%edx),%ecx
  800325:	89 08                	mov    %ecx,(%eax)
  800327:	8b 02                	mov    (%edx),%eax
  800329:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    

00800330 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800336:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033a:	8b 10                	mov    (%eax),%edx
  80033c:	3b 50 04             	cmp    0x4(%eax),%edx
  80033f:	73 0a                	jae    80034b <sprintputch+0x1b>
		*b->buf++ = ch;
  800341:	8d 4a 01             	lea    0x1(%edx),%ecx
  800344:	89 08                	mov    %ecx,(%eax)
  800346:	8b 45 08             	mov    0x8(%ebp),%eax
  800349:	88 02                	mov    %al,(%edx)
}
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    

0080034d <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800353:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800356:	50                   	push   %eax
  800357:	ff 75 10             	pushl  0x10(%ebp)
  80035a:	ff 75 0c             	pushl  0xc(%ebp)
  80035d:	ff 75 08             	pushl  0x8(%ebp)
  800360:	e8 05 00 00 00       	call   80036a <vprintfmt>
	va_end(ap);
}
  800365:	83 c4 10             	add    $0x10,%esp
  800368:	c9                   	leave  
  800369:	c3                   	ret    

0080036a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	57                   	push   %edi
  80036e:	56                   	push   %esi
  80036f:	53                   	push   %ebx
  800370:	83 ec 2c             	sub    $0x2c,%esp
  800373:	8b 75 08             	mov    0x8(%ebp),%esi
  800376:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800379:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037c:	eb 12                	jmp    800390 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037e:	85 c0                	test   %eax,%eax
  800380:	0f 84 cb 03 00 00    	je     800751 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	53                   	push   %ebx
  80038a:	50                   	push   %eax
  80038b:	ff d6                	call   *%esi
  80038d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800390:	83 c7 01             	add    $0x1,%edi
  800393:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800397:	83 f8 25             	cmp    $0x25,%eax
  80039a:	75 e2                	jne    80037e <vprintfmt+0x14>
  80039c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a7:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003ae:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ba:	eb 07                	jmp    8003c3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bf:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	8d 47 01             	lea    0x1(%edi),%eax
  8003c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c9:	0f b6 07             	movzbl (%edi),%eax
  8003cc:	0f b6 c8             	movzbl %al,%ecx
  8003cf:	83 e8 23             	sub    $0x23,%eax
  8003d2:	3c 55                	cmp    $0x55,%al
  8003d4:	0f 87 5c 03 00 00    	ja     800736 <vprintfmt+0x3cc>
  8003da:	0f b6 c0             	movzbl %al,%eax
  8003dd:	ff 24 85 00 12 80 00 	jmp    *0x801200(,%eax,4)
  8003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003eb:	eb d6                	jmp    8003c3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003fb:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ff:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800402:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800405:	83 fa 09             	cmp    $0x9,%edx
  800408:	77 39                	ja     800443 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040d:	eb e9                	jmp    8003f8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	8d 48 04             	lea    0x4(%eax),%ecx
  800415:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800418:	8b 00                	mov    (%eax),%eax
  80041a:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800420:	eb 27                	jmp    800449 <vprintfmt+0xdf>
  800422:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800425:	85 c0                	test   %eax,%eax
  800427:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042c:	0f 49 c8             	cmovns %eax,%ecx
  80042f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800435:	eb 8c                	jmp    8003c3 <vprintfmt+0x59>
  800437:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800441:	eb 80                	jmp    8003c3 <vprintfmt+0x59>
  800443:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800446:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800449:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044d:	0f 89 70 ff ff ff    	jns    8003c3 <vprintfmt+0x59>
				width = precision, precision = -1;
  800453:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800456:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800459:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800460:	e9 5e ff ff ff       	jmp    8003c3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800465:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800468:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80046b:	e9 53 ff ff ff       	jmp    8003c3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8d 50 04             	lea    0x4(%eax),%edx
  800476:	89 55 14             	mov    %edx,0x14(%ebp)
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	53                   	push   %ebx
  80047d:	ff 30                	pushl  (%eax)
  80047f:	ff d6                	call   *%esi
			break;
  800481:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800487:	e9 04 ff ff ff       	jmp    800390 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8d 50 04             	lea    0x4(%eax),%edx
  800492:	89 55 14             	mov    %edx,0x14(%ebp)
  800495:	8b 00                	mov    (%eax),%eax
  800497:	99                   	cltd   
  800498:	31 d0                	xor    %edx,%eax
  80049a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049c:	83 f8 09             	cmp    $0x9,%eax
  80049f:	7f 0b                	jg     8004ac <vprintfmt+0x142>
  8004a1:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  8004a8:	85 d2                	test   %edx,%edx
  8004aa:	75 18                	jne    8004c4 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004ac:	50                   	push   %eax
  8004ad:	68 4c 11 80 00       	push   $0x80114c
  8004b2:	53                   	push   %ebx
  8004b3:	56                   	push   %esi
  8004b4:	e8 94 fe ff ff       	call   80034d <printfmt>
  8004b9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004bf:	e9 cc fe ff ff       	jmp    800390 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004c4:	52                   	push   %edx
  8004c5:	68 55 11 80 00       	push   $0x801155
  8004ca:	53                   	push   %ebx
  8004cb:	56                   	push   %esi
  8004cc:	e8 7c fe ff ff       	call   80034d <printfmt>
  8004d1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d7:	e9 b4 fe ff ff       	jmp    800390 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004df:	8d 50 04             	lea    0x4(%eax),%edx
  8004e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e7:	85 ff                	test   %edi,%edi
  8004e9:	b8 45 11 80 00       	mov    $0x801145,%eax
  8004ee:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f5:	0f 8e 94 00 00 00    	jle    80058f <vprintfmt+0x225>
  8004fb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ff:	0f 84 98 00 00 00    	je     80059d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	ff 75 c8             	pushl  -0x38(%ebp)
  80050b:	57                   	push   %edi
  80050c:	e8 c8 02 00 00       	call   8007d9 <strnlen>
  800511:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800514:	29 c1                	sub    %eax,%ecx
  800516:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800519:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800520:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800523:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800526:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800528:	eb 0f                	jmp    800539 <vprintfmt+0x1cf>
					putch(padc, putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	53                   	push   %ebx
  80052e:	ff 75 e0             	pushl  -0x20(%ebp)
  800531:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800533:	83 ef 01             	sub    $0x1,%edi
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	85 ff                	test   %edi,%edi
  80053b:	7f ed                	jg     80052a <vprintfmt+0x1c0>
  80053d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800540:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800543:	85 c9                	test   %ecx,%ecx
  800545:	b8 00 00 00 00       	mov    $0x0,%eax
  80054a:	0f 49 c1             	cmovns %ecx,%eax
  80054d:	29 c1                	sub    %eax,%ecx
  80054f:	89 75 08             	mov    %esi,0x8(%ebp)
  800552:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800555:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800558:	89 cb                	mov    %ecx,%ebx
  80055a:	eb 4d                	jmp    8005a9 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800560:	74 1b                	je     80057d <vprintfmt+0x213>
  800562:	0f be c0             	movsbl %al,%eax
  800565:	83 e8 20             	sub    $0x20,%eax
  800568:	83 f8 5e             	cmp    $0x5e,%eax
  80056b:	76 10                	jbe    80057d <vprintfmt+0x213>
					putch('?', putdat);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	ff 75 0c             	pushl  0xc(%ebp)
  800573:	6a 3f                	push   $0x3f
  800575:	ff 55 08             	call   *0x8(%ebp)
  800578:	83 c4 10             	add    $0x10,%esp
  80057b:	eb 0d                	jmp    80058a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	ff 75 0c             	pushl  0xc(%ebp)
  800583:	52                   	push   %edx
  800584:	ff 55 08             	call   *0x8(%ebp)
  800587:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058a:	83 eb 01             	sub    $0x1,%ebx
  80058d:	eb 1a                	jmp    8005a9 <vprintfmt+0x23f>
  80058f:	89 75 08             	mov    %esi,0x8(%ebp)
  800592:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800595:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800598:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059b:	eb 0c                	jmp    8005a9 <vprintfmt+0x23f>
  80059d:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a0:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8005a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a9:	83 c7 01             	add    $0x1,%edi
  8005ac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b0:	0f be d0             	movsbl %al,%edx
  8005b3:	85 d2                	test   %edx,%edx
  8005b5:	74 23                	je     8005da <vprintfmt+0x270>
  8005b7:	85 f6                	test   %esi,%esi
  8005b9:	78 a1                	js     80055c <vprintfmt+0x1f2>
  8005bb:	83 ee 01             	sub    $0x1,%esi
  8005be:	79 9c                	jns    80055c <vprintfmt+0x1f2>
  8005c0:	89 df                	mov    %ebx,%edi
  8005c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c8:	eb 18                	jmp    8005e2 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	53                   	push   %ebx
  8005ce:	6a 20                	push   $0x20
  8005d0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d2:	83 ef 01             	sub    $0x1,%edi
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	eb 08                	jmp    8005e2 <vprintfmt+0x278>
  8005da:	89 df                	mov    %ebx,%edi
  8005dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8005df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e2:	85 ff                	test   %edi,%edi
  8005e4:	7f e4                	jg     8005ca <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e9:	e9 a2 fd ff ff       	jmp    800390 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ee:	83 fa 01             	cmp    $0x1,%edx
  8005f1:	7e 16                	jle    800609 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 50 08             	lea    0x8(%eax),%edx
  8005f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fc:	8b 50 04             	mov    0x4(%eax),%edx
  8005ff:	8b 00                	mov    (%eax),%eax
  800601:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800604:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800607:	eb 32                	jmp    80063b <vprintfmt+0x2d1>
	else if (lflag)
  800609:	85 d2                	test   %edx,%edx
  80060b:	74 18                	je     800625 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 50 04             	lea    0x4(%eax),%edx
  800613:	89 55 14             	mov    %edx,0x14(%ebp)
  800616:	8b 00                	mov    (%eax),%eax
  800618:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80061b:	89 c1                	mov    %eax,%ecx
  80061d:	c1 f9 1f             	sar    $0x1f,%ecx
  800620:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800623:	eb 16                	jmp    80063b <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8d 50 04             	lea    0x4(%eax),%edx
  80062b:	89 55 14             	mov    %edx,0x14(%ebp)
  80062e:	8b 00                	mov    (%eax),%eax
  800630:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800633:	89 c1                	mov    %eax,%ecx
  800635:	c1 f9 1f             	sar    $0x1f,%ecx
  800638:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80063b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80063e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800641:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800644:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800647:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800650:	0f 89 a8 00 00 00    	jns    8006fe <vprintfmt+0x394>
				putch('-', putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	53                   	push   %ebx
  80065a:	6a 2d                	push   $0x2d
  80065c:	ff d6                	call   *%esi
				num = -(long long) num;
  80065e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800661:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800664:	f7 d8                	neg    %eax
  800666:	83 d2 00             	adc    $0x0,%edx
  800669:	f7 da                	neg    %edx
  80066b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800671:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800674:	b8 0a 00 00 00       	mov    $0xa,%eax
  800679:	e9 80 00 00 00       	jmp    8006fe <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80067e:	8d 45 14             	lea    0x14(%ebp),%eax
  800681:	e8 70 fc ff ff       	call   8002f6 <getuint>
  800686:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800689:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80068c:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800691:	eb 6b                	jmp    8006fe <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800693:	8d 45 14             	lea    0x14(%ebp),%eax
  800696:	e8 5b fc ff ff       	call   8002f6 <getuint>
  80069b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  8006a1:	6a 04                	push   $0x4
  8006a3:	6a 03                	push   $0x3
  8006a5:	6a 01                	push   $0x1
  8006a7:	68 58 11 80 00       	push   $0x801158
  8006ac:	e8 82 fb ff ff       	call   800233 <cprintf>
			goto number;
  8006b1:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  8006b4:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  8006b9:	eb 43                	jmp    8006fe <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	6a 30                	push   $0x30
  8006c1:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c3:	83 c4 08             	add    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	6a 78                	push   $0x78
  8006c9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8d 50 04             	lea    0x4(%eax),%edx
  8006d1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006d4:	8b 00                	mov    (%eax),%eax
  8006d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8006db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006de:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006e4:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006e9:	eb 13                	jmp    8006fe <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ee:	e8 03 fc ff ff       	call   8002f6 <getuint>
  8006f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006f9:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fe:	83 ec 0c             	sub    $0xc,%esp
  800701:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  800705:	52                   	push   %edx
  800706:	ff 75 e0             	pushl  -0x20(%ebp)
  800709:	50                   	push   %eax
  80070a:	ff 75 dc             	pushl  -0x24(%ebp)
  80070d:	ff 75 d8             	pushl  -0x28(%ebp)
  800710:	89 da                	mov    %ebx,%edx
  800712:	89 f0                	mov    %esi,%eax
  800714:	e8 2e fb ff ff       	call   800247 <printnum>

			break;
  800719:	83 c4 20             	add    $0x20,%esp
  80071c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80071f:	e9 6c fc ff ff       	jmp    800390 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	53                   	push   %ebx
  800728:	51                   	push   %ecx
  800729:	ff d6                	call   *%esi
			break;
  80072b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800731:	e9 5a fc ff ff       	jmp    800390 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	53                   	push   %ebx
  80073a:	6a 25                	push   $0x25
  80073c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	eb 03                	jmp    800746 <vprintfmt+0x3dc>
  800743:	83 ef 01             	sub    $0x1,%edi
  800746:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80074a:	75 f7                	jne    800743 <vprintfmt+0x3d9>
  80074c:	e9 3f fc ff ff       	jmp    800390 <vprintfmt+0x26>
			break;
		}

	}

}
  800751:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800754:	5b                   	pop    %ebx
  800755:	5e                   	pop    %esi
  800756:	5f                   	pop    %edi
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	83 ec 18             	sub    $0x18,%esp
  80075f:	8b 45 08             	mov    0x8(%ebp),%eax
  800762:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800765:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800768:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800776:	85 c0                	test   %eax,%eax
  800778:	74 26                	je     8007a0 <vsnprintf+0x47>
  80077a:	85 d2                	test   %edx,%edx
  80077c:	7e 22                	jle    8007a0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077e:	ff 75 14             	pushl  0x14(%ebp)
  800781:	ff 75 10             	pushl  0x10(%ebp)
  800784:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800787:	50                   	push   %eax
  800788:	68 30 03 80 00       	push   $0x800330
  80078d:	e8 d8 fb ff ff       	call   80036a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800792:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800795:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800798:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079b:	83 c4 10             	add    $0x10,%esp
  80079e:	eb 05                	jmp    8007a5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a5:	c9                   	leave  
  8007a6:	c3                   	ret    

008007a7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ad:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b0:	50                   	push   %eax
  8007b1:	ff 75 10             	pushl  0x10(%ebp)
  8007b4:	ff 75 0c             	pushl  0xc(%ebp)
  8007b7:	ff 75 08             	pushl  0x8(%ebp)
  8007ba:	e8 9a ff ff ff       	call   800759 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007bf:	c9                   	leave  
  8007c0:	c3                   	ret    

008007c1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cc:	eb 03                	jmp    8007d1 <strlen+0x10>
		n++;
  8007ce:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d5:	75 f7                	jne    8007ce <strlen+0xd>
		n++;
	return n;
}
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007df:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e7:	eb 03                	jmp    8007ec <strnlen+0x13>
		n++;
  8007e9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ec:	39 c2                	cmp    %eax,%edx
  8007ee:	74 08                	je     8007f8 <strnlen+0x1f>
  8007f0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007f4:	75 f3                	jne    8007e9 <strnlen+0x10>
  8007f6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	53                   	push   %ebx
  8007fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800801:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800804:	89 c2                	mov    %eax,%edx
  800806:	83 c2 01             	add    $0x1,%edx
  800809:	83 c1 01             	add    $0x1,%ecx
  80080c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800810:	88 5a ff             	mov    %bl,-0x1(%edx)
  800813:	84 db                	test   %bl,%bl
  800815:	75 ef                	jne    800806 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800817:	5b                   	pop    %ebx
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	53                   	push   %ebx
  80081e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800821:	53                   	push   %ebx
  800822:	e8 9a ff ff ff       	call   8007c1 <strlen>
  800827:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80082a:	ff 75 0c             	pushl  0xc(%ebp)
  80082d:	01 d8                	add    %ebx,%eax
  80082f:	50                   	push   %eax
  800830:	e8 c5 ff ff ff       	call   8007fa <strcpy>
	return dst;
}
  800835:	89 d8                	mov    %ebx,%eax
  800837:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083a:	c9                   	leave  
  80083b:	c3                   	ret    

0080083c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	56                   	push   %esi
  800840:	53                   	push   %ebx
  800841:	8b 75 08             	mov    0x8(%ebp),%esi
  800844:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800847:	89 f3                	mov    %esi,%ebx
  800849:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084c:	89 f2                	mov    %esi,%edx
  80084e:	eb 0f                	jmp    80085f <strncpy+0x23>
		*dst++ = *src;
  800850:	83 c2 01             	add    $0x1,%edx
  800853:	0f b6 01             	movzbl (%ecx),%eax
  800856:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800859:	80 39 01             	cmpb   $0x1,(%ecx)
  80085c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085f:	39 da                	cmp    %ebx,%edx
  800861:	75 ed                	jne    800850 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800863:	89 f0                	mov    %esi,%eax
  800865:	5b                   	pop    %ebx
  800866:	5e                   	pop    %esi
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	56                   	push   %esi
  80086d:	53                   	push   %ebx
  80086e:	8b 75 08             	mov    0x8(%ebp),%esi
  800871:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800874:	8b 55 10             	mov    0x10(%ebp),%edx
  800877:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800879:	85 d2                	test   %edx,%edx
  80087b:	74 21                	je     80089e <strlcpy+0x35>
  80087d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800881:	89 f2                	mov    %esi,%edx
  800883:	eb 09                	jmp    80088e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800885:	83 c2 01             	add    $0x1,%edx
  800888:	83 c1 01             	add    $0x1,%ecx
  80088b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80088e:	39 c2                	cmp    %eax,%edx
  800890:	74 09                	je     80089b <strlcpy+0x32>
  800892:	0f b6 19             	movzbl (%ecx),%ebx
  800895:	84 db                	test   %bl,%bl
  800897:	75 ec                	jne    800885 <strlcpy+0x1c>
  800899:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80089b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80089e:	29 f0                	sub    %esi,%eax
}
  8008a0:	5b                   	pop    %ebx
  8008a1:	5e                   	pop    %esi
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ad:	eb 06                	jmp    8008b5 <strcmp+0x11>
		p++, q++;
  8008af:	83 c1 01             	add    $0x1,%ecx
  8008b2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b5:	0f b6 01             	movzbl (%ecx),%eax
  8008b8:	84 c0                	test   %al,%al
  8008ba:	74 04                	je     8008c0 <strcmp+0x1c>
  8008bc:	3a 02                	cmp    (%edx),%al
  8008be:	74 ef                	je     8008af <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c0:	0f b6 c0             	movzbl %al,%eax
  8008c3:	0f b6 12             	movzbl (%edx),%edx
  8008c6:	29 d0                	sub    %edx,%eax
}
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	53                   	push   %ebx
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d4:	89 c3                	mov    %eax,%ebx
  8008d6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d9:	eb 06                	jmp    8008e1 <strncmp+0x17>
		n--, p++, q++;
  8008db:	83 c0 01             	add    $0x1,%eax
  8008de:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e1:	39 d8                	cmp    %ebx,%eax
  8008e3:	74 15                	je     8008fa <strncmp+0x30>
  8008e5:	0f b6 08             	movzbl (%eax),%ecx
  8008e8:	84 c9                	test   %cl,%cl
  8008ea:	74 04                	je     8008f0 <strncmp+0x26>
  8008ec:	3a 0a                	cmp    (%edx),%cl
  8008ee:	74 eb                	je     8008db <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f0:	0f b6 00             	movzbl (%eax),%eax
  8008f3:	0f b6 12             	movzbl (%edx),%edx
  8008f6:	29 d0                	sub    %edx,%eax
  8008f8:	eb 05                	jmp    8008ff <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008fa:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ff:	5b                   	pop    %ebx
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	8b 45 08             	mov    0x8(%ebp),%eax
  800908:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090c:	eb 07                	jmp    800915 <strchr+0x13>
		if (*s == c)
  80090e:	38 ca                	cmp    %cl,%dl
  800910:	74 0f                	je     800921 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800912:	83 c0 01             	add    $0x1,%eax
  800915:	0f b6 10             	movzbl (%eax),%edx
  800918:	84 d2                	test   %dl,%dl
  80091a:	75 f2                	jne    80090e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80091c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092d:	eb 03                	jmp    800932 <strfind+0xf>
  80092f:	83 c0 01             	add    $0x1,%eax
  800932:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800935:	38 ca                	cmp    %cl,%dl
  800937:	74 04                	je     80093d <strfind+0x1a>
  800939:	84 d2                	test   %dl,%dl
  80093b:	75 f2                	jne    80092f <strfind+0xc>
			break;
	return (char *) s;
}
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	57                   	push   %edi
  800943:	56                   	push   %esi
  800944:	53                   	push   %ebx
  800945:	8b 7d 08             	mov    0x8(%ebp),%edi
  800948:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094b:	85 c9                	test   %ecx,%ecx
  80094d:	74 36                	je     800985 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800955:	75 28                	jne    80097f <memset+0x40>
  800957:	f6 c1 03             	test   $0x3,%cl
  80095a:	75 23                	jne    80097f <memset+0x40>
		c &= 0xFF;
  80095c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800960:	89 d3                	mov    %edx,%ebx
  800962:	c1 e3 08             	shl    $0x8,%ebx
  800965:	89 d6                	mov    %edx,%esi
  800967:	c1 e6 18             	shl    $0x18,%esi
  80096a:	89 d0                	mov    %edx,%eax
  80096c:	c1 e0 10             	shl    $0x10,%eax
  80096f:	09 f0                	or     %esi,%eax
  800971:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800973:	89 d8                	mov    %ebx,%eax
  800975:	09 d0                	or     %edx,%eax
  800977:	c1 e9 02             	shr    $0x2,%ecx
  80097a:	fc                   	cld    
  80097b:	f3 ab                	rep stos %eax,%es:(%edi)
  80097d:	eb 06                	jmp    800985 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800982:	fc                   	cld    
  800983:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800985:	89 f8                	mov    %edi,%eax
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5f                   	pop    %edi
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	57                   	push   %edi
  800990:	56                   	push   %esi
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 75 0c             	mov    0xc(%ebp),%esi
  800997:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099a:	39 c6                	cmp    %eax,%esi
  80099c:	73 35                	jae    8009d3 <memmove+0x47>
  80099e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a1:	39 d0                	cmp    %edx,%eax
  8009a3:	73 2e                	jae    8009d3 <memmove+0x47>
		s += n;
		d += n;
  8009a5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a8:	89 d6                	mov    %edx,%esi
  8009aa:	09 fe                	or     %edi,%esi
  8009ac:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b2:	75 13                	jne    8009c7 <memmove+0x3b>
  8009b4:	f6 c1 03             	test   $0x3,%cl
  8009b7:	75 0e                	jne    8009c7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b9:	83 ef 04             	sub    $0x4,%edi
  8009bc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
  8009c2:	fd                   	std    
  8009c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c5:	eb 09                	jmp    8009d0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c7:	83 ef 01             	sub    $0x1,%edi
  8009ca:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009cd:	fd                   	std    
  8009ce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d0:	fc                   	cld    
  8009d1:	eb 1d                	jmp    8009f0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d3:	89 f2                	mov    %esi,%edx
  8009d5:	09 c2                	or     %eax,%edx
  8009d7:	f6 c2 03             	test   $0x3,%dl
  8009da:	75 0f                	jne    8009eb <memmove+0x5f>
  8009dc:	f6 c1 03             	test   $0x3,%cl
  8009df:	75 0a                	jne    8009eb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009e1:	c1 e9 02             	shr    $0x2,%ecx
  8009e4:	89 c7                	mov    %eax,%edi
  8009e6:	fc                   	cld    
  8009e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e9:	eb 05                	jmp    8009f0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009eb:	89 c7                	mov    %eax,%edi
  8009ed:	fc                   	cld    
  8009ee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f0:	5e                   	pop    %esi
  8009f1:	5f                   	pop    %edi
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f7:	ff 75 10             	pushl  0x10(%ebp)
  8009fa:	ff 75 0c             	pushl  0xc(%ebp)
  8009fd:	ff 75 08             	pushl  0x8(%ebp)
  800a00:	e8 87 ff ff ff       	call   80098c <memmove>
}
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	56                   	push   %esi
  800a0b:	53                   	push   %ebx
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a12:	89 c6                	mov    %eax,%esi
  800a14:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a17:	eb 1a                	jmp    800a33 <memcmp+0x2c>
		if (*s1 != *s2)
  800a19:	0f b6 08             	movzbl (%eax),%ecx
  800a1c:	0f b6 1a             	movzbl (%edx),%ebx
  800a1f:	38 d9                	cmp    %bl,%cl
  800a21:	74 0a                	je     800a2d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a23:	0f b6 c1             	movzbl %cl,%eax
  800a26:	0f b6 db             	movzbl %bl,%ebx
  800a29:	29 d8                	sub    %ebx,%eax
  800a2b:	eb 0f                	jmp    800a3c <memcmp+0x35>
		s1++, s2++;
  800a2d:	83 c0 01             	add    $0x1,%eax
  800a30:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a33:	39 f0                	cmp    %esi,%eax
  800a35:	75 e2                	jne    800a19 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3c:	5b                   	pop    %ebx
  800a3d:	5e                   	pop    %esi
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	53                   	push   %ebx
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a47:	89 c1                	mov    %eax,%ecx
  800a49:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a50:	eb 0a                	jmp    800a5c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a52:	0f b6 10             	movzbl (%eax),%edx
  800a55:	39 da                	cmp    %ebx,%edx
  800a57:	74 07                	je     800a60 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a59:	83 c0 01             	add    $0x1,%eax
  800a5c:	39 c8                	cmp    %ecx,%eax
  800a5e:	72 f2                	jb     800a52 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a60:	5b                   	pop    %ebx
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	57                   	push   %edi
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
  800a69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6f:	eb 03                	jmp    800a74 <strtol+0x11>
		s++;
  800a71:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a74:	0f b6 01             	movzbl (%ecx),%eax
  800a77:	3c 20                	cmp    $0x20,%al
  800a79:	74 f6                	je     800a71 <strtol+0xe>
  800a7b:	3c 09                	cmp    $0x9,%al
  800a7d:	74 f2                	je     800a71 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a7f:	3c 2b                	cmp    $0x2b,%al
  800a81:	75 0a                	jne    800a8d <strtol+0x2a>
		s++;
  800a83:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a86:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8b:	eb 11                	jmp    800a9e <strtol+0x3b>
  800a8d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a92:	3c 2d                	cmp    $0x2d,%al
  800a94:	75 08                	jne    800a9e <strtol+0x3b>
		s++, neg = 1;
  800a96:	83 c1 01             	add    $0x1,%ecx
  800a99:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aa4:	75 15                	jne    800abb <strtol+0x58>
  800aa6:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa9:	75 10                	jne    800abb <strtol+0x58>
  800aab:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aaf:	75 7c                	jne    800b2d <strtol+0xca>
		s += 2, base = 16;
  800ab1:	83 c1 02             	add    $0x2,%ecx
  800ab4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab9:	eb 16                	jmp    800ad1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800abb:	85 db                	test   %ebx,%ebx
  800abd:	75 12                	jne    800ad1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800abf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac4:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac7:	75 08                	jne    800ad1 <strtol+0x6e>
		s++, base = 8;
  800ac9:	83 c1 01             	add    $0x1,%ecx
  800acc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad9:	0f b6 11             	movzbl (%ecx),%edx
  800adc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800adf:	89 f3                	mov    %esi,%ebx
  800ae1:	80 fb 09             	cmp    $0x9,%bl
  800ae4:	77 08                	ja     800aee <strtol+0x8b>
			dig = *s - '0';
  800ae6:	0f be d2             	movsbl %dl,%edx
  800ae9:	83 ea 30             	sub    $0x30,%edx
  800aec:	eb 22                	jmp    800b10 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aee:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af1:	89 f3                	mov    %esi,%ebx
  800af3:	80 fb 19             	cmp    $0x19,%bl
  800af6:	77 08                	ja     800b00 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af8:	0f be d2             	movsbl %dl,%edx
  800afb:	83 ea 57             	sub    $0x57,%edx
  800afe:	eb 10                	jmp    800b10 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b00:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b03:	89 f3                	mov    %esi,%ebx
  800b05:	80 fb 19             	cmp    $0x19,%bl
  800b08:	77 16                	ja     800b20 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b0a:	0f be d2             	movsbl %dl,%edx
  800b0d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b10:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b13:	7d 0b                	jge    800b20 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b15:	83 c1 01             	add    $0x1,%ecx
  800b18:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b1c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b1e:	eb b9                	jmp    800ad9 <strtol+0x76>

	if (endptr)
  800b20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b24:	74 0d                	je     800b33 <strtol+0xd0>
		*endptr = (char *) s;
  800b26:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b29:	89 0e                	mov    %ecx,(%esi)
  800b2b:	eb 06                	jmp    800b33 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b2d:	85 db                	test   %ebx,%ebx
  800b2f:	74 98                	je     800ac9 <strtol+0x66>
  800b31:	eb 9e                	jmp    800ad1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b33:	89 c2                	mov    %eax,%edx
  800b35:	f7 da                	neg    %edx
  800b37:	85 ff                	test   %edi,%edi
  800b39:	0f 45 c2             	cmovne %edx,%eax
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b47:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	89 c3                	mov    %eax,%ebx
  800b54:	89 c7                	mov    %eax,%edi
  800b56:	89 c6                	mov    %eax,%esi
  800b58:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6f:	89 d1                	mov    %edx,%ecx
  800b71:	89 d3                	mov    %edx,%ebx
  800b73:	89 d7                	mov    %edx,%edi
  800b75:	89 d6                	mov    %edx,%esi
  800b77:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5f                   	pop    %edi
  800b7c:	5d                   	pop    %ebp
  800b7d:	c3                   	ret    

00800b7e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b87:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8c:	b8 03 00 00 00       	mov    $0x3,%eax
  800b91:	8b 55 08             	mov    0x8(%ebp),%edx
  800b94:	89 cb                	mov    %ecx,%ebx
  800b96:	89 cf                	mov    %ecx,%edi
  800b98:	89 ce                	mov    %ecx,%esi
  800b9a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	7e 17                	jle    800bb7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba0:	83 ec 0c             	sub    $0xc,%esp
  800ba3:	50                   	push   %eax
  800ba4:	6a 03                	push   $0x3
  800ba6:	68 88 13 80 00       	push   $0x801388
  800bab:	6a 23                	push   $0x23
  800bad:	68 a5 13 80 00       	push   $0x8013a5
  800bb2:	e8 a3 f5 ff ff       	call   80015a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bba:	5b                   	pop    %ebx
  800bbb:	5e                   	pop    %esi
  800bbc:	5f                   	pop    %edi
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bca:	b8 02 00 00 00       	mov    $0x2,%eax
  800bcf:	89 d1                	mov    %edx,%ecx
  800bd1:	89 d3                	mov    %edx,%ebx
  800bd3:	89 d7                	mov    %edx,%edi
  800bd5:	89 d6                	mov    %edx,%esi
  800bd7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_yield>:

void
sys_yield(void)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
  800be9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bee:	89 d1                	mov    %edx,%ecx
  800bf0:	89 d3                	mov    %edx,%ebx
  800bf2:	89 d7                	mov    %edx,%edi
  800bf4:	89 d6                	mov    %edx,%esi
  800bf6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800c06:	be 00 00 00 00       	mov    $0x0,%esi
  800c0b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c13:	8b 55 08             	mov    0x8(%ebp),%edx
  800c16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c19:	89 f7                	mov    %esi,%edi
  800c1b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7e 17                	jle    800c38 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c21:	83 ec 0c             	sub    $0xc,%esp
  800c24:	50                   	push   %eax
  800c25:	6a 04                	push   $0x4
  800c27:	68 88 13 80 00       	push   $0x801388
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 a5 13 80 00       	push   $0x8013a5
  800c33:	e8 22 f5 ff ff       	call   80015a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c57:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 17                	jle    800c7a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	50                   	push   %eax
  800c67:	6a 05                	push   $0x5
  800c69:	68 88 13 80 00       	push   $0x801388
  800c6e:	6a 23                	push   $0x23
  800c70:	68 a5 13 80 00       	push   $0x8013a5
  800c75:	e8 e0 f4 ff ff       	call   80015a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c90:	b8 06 00 00 00       	mov    $0x6,%eax
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	89 df                	mov    %ebx,%edi
  800c9d:	89 de                	mov    %ebx,%esi
  800c9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 17                	jle    800cbc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 06                	push   $0x6
  800cab:	68 88 13 80 00       	push   $0x801388
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 a5 13 80 00       	push   $0x8013a5
  800cb7:	e8 9e f4 ff ff       	call   80015a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	89 df                	mov    %ebx,%edi
  800cdf:	89 de                	mov    %ebx,%esi
  800ce1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 08                	push   $0x8
  800ced:	68 88 13 80 00       	push   $0x801388
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 a5 13 80 00       	push   $0x8013a5
  800cf9:	e8 5c f4 ff ff       	call   80015a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d14:	b8 09 00 00 00       	mov    $0x9,%eax
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	89 df                	mov    %ebx,%edi
  800d21:	89 de                	mov    %ebx,%esi
  800d23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7e 17                	jle    800d40 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d29:	83 ec 0c             	sub    $0xc,%esp
  800d2c:	50                   	push   %eax
  800d2d:	6a 09                	push   $0x9
  800d2f:	68 88 13 80 00       	push   $0x801388
  800d34:	6a 23                	push   $0x23
  800d36:	68 a5 13 80 00       	push   $0x8013a5
  800d3b:	e8 1a f4 ff ff       	call   80015a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	be 00 00 00 00       	mov    $0x0,%esi
  800d53:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d61:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d64:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d79:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	89 cb                	mov    %ecx,%ebx
  800d83:	89 cf                	mov    %ecx,%edi
  800d85:	89 ce                	mov    %ecx,%esi
  800d87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	7e 17                	jle    800da4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	83 ec 0c             	sub    $0xc,%esp
  800d90:	50                   	push   %eax
  800d91:	6a 0c                	push   $0xc
  800d93:	68 88 13 80 00       	push   $0x801388
  800d98:	6a 23                	push   $0x23
  800d9a:	68 a5 13 80 00       	push   $0x8013a5
  800d9f:	e8 b6 f3 ff ff       	call   80015a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800db2:	68 bf 13 80 00       	push   $0x8013bf
  800db7:	6a 51                	push   $0x51
  800db9:	68 b3 13 80 00       	push   $0x8013b3
  800dbe:	e8 97 f3 ff ff       	call   80015a <_panic>

00800dc3 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800dc9:	68 be 13 80 00       	push   $0x8013be
  800dce:	6a 58                	push   $0x58
  800dd0:	68 b3 13 80 00       	push   $0x8013b3
  800dd5:	e8 80 f3 ff ff       	call   80015a <_panic>

00800dda <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800de0:	68 d4 13 80 00       	push   $0x8013d4
  800de5:	6a 1a                	push   $0x1a
  800de7:	68 ed 13 80 00       	push   $0x8013ed
  800dec:	e8 69 f3 ff ff       	call   80015a <_panic>

00800df1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800df7:	68 f7 13 80 00       	push   $0x8013f7
  800dfc:	6a 2a                	push   $0x2a
  800dfe:	68 ed 13 80 00       	push   $0x8013ed
  800e03:	e8 52 f3 ff ff       	call   80015a <_panic>

00800e08 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e0e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e13:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e16:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e1c:	8b 52 50             	mov    0x50(%edx),%edx
  800e1f:	39 ca                	cmp    %ecx,%edx
  800e21:	75 0d                	jne    800e30 <ipc_find_env+0x28>
			return envs[i].env_id;
  800e23:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e26:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e2b:	8b 40 48             	mov    0x48(%eax),%eax
  800e2e:	eb 0f                	jmp    800e3f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e30:	83 c0 01             	add    $0x1,%eax
  800e33:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e38:	75 d9                	jne    800e13 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    
  800e41:	66 90                	xchg   %ax,%ax
  800e43:	66 90                	xchg   %ax,%ax
  800e45:	66 90                	xchg   %ax,%ax
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
