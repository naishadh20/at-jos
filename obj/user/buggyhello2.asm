
obj/user/buggyhello2:     file format elf32-i386


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

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 4d 00 00 00       	call   800096 <sys_cputs>
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
  80005a:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800061:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 c0                	test   %eax,%eax
  800066:	7e 08                	jle    800070 <libmain+0x22>
		binaryname = argv[0];
  800068:	8b 0a                	mov    (%edx),%ecx
  80006a:	89 0d 04 20 80 00    	mov    %ecx,0x802004

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
  80008c:	e8 42 00 00 00       	call   8000d3 <sys_env_destroy>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	57                   	push   %edi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009c:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a7:	89 c3                	mov    %eax,%ebx
  8000a9:	89 c7                	mov    %eax,%edi
  8000ab:	89 c6                	mov    %eax,%esi
  8000ad:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5f                   	pop    %edi
  8000b2:	5d                   	pop    %ebp
  8000b3:	c3                   	ret    

008000b4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c4:	89 d1                	mov    %edx,%ecx
  8000c6:	89 d3                	mov    %edx,%ebx
  8000c8:	89 d7                	mov    %edx,%edi
  8000ca:	89 d6                	mov    %edx,%esi
  8000cc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e9:	89 cb                	mov    %ecx,%ebx
  8000eb:	89 cf                	mov    %ecx,%edi
  8000ed:	89 ce                	mov    %ecx,%esi
  8000ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f1:	85 c0                	test   %eax,%eax
  8000f3:	7e 17                	jle    80010c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	50                   	push   %eax
  8000f9:	6a 03                	push   $0x3
  8000fb:	68 d8 0d 80 00       	push   $0x800dd8
  800100:	6a 23                	push   $0x23
  800102:	68 f5 0d 80 00       	push   $0x800df5
  800107:	e8 27 00 00 00       	call   800133 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5f                   	pop    %edi
  800112:	5d                   	pop    %ebp
  800113:	c3                   	ret    

00800114 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	57                   	push   %edi
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011a:	ba 00 00 00 00       	mov    $0x0,%edx
  80011f:	b8 02 00 00 00       	mov    $0x2,%eax
  800124:	89 d1                	mov    %edx,%ecx
  800126:	89 d3                	mov    %edx,%ebx
  800128:	89 d7                	mov    %edx,%edi
  80012a:	89 d6                	mov    %edx,%esi
  80012c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800138:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013b:	8b 35 04 20 80 00    	mov    0x802004,%esi
  800141:	e8 ce ff ff ff       	call   800114 <sys_getenvid>
  800146:	83 ec 0c             	sub    $0xc,%esp
  800149:	ff 75 0c             	pushl  0xc(%ebp)
  80014c:	ff 75 08             	pushl  0x8(%ebp)
  80014f:	56                   	push   %esi
  800150:	50                   	push   %eax
  800151:	68 04 0e 80 00       	push   $0x800e04
  800156:	e8 b1 00 00 00       	call   80020c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015b:	83 c4 18             	add    $0x18,%esp
  80015e:	53                   	push   %ebx
  80015f:	ff 75 10             	pushl  0x10(%ebp)
  800162:	e8 54 00 00 00       	call   8001bb <vcprintf>
	cprintf("\n");
  800167:	c7 04 24 5c 0e 80 00 	movl   $0x800e5c,(%esp)
  80016e:	e8 99 00 00 00       	call   80020c <cprintf>
  800173:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800176:	cc                   	int3   
  800177:	eb fd                	jmp    800176 <_panic+0x43>

00800179 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 04             	sub    $0x4,%esp
  800180:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800183:	8b 13                	mov    (%ebx),%edx
  800185:	8d 42 01             	lea    0x1(%edx),%eax
  800188:	89 03                	mov    %eax,(%ebx)
  80018a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800191:	3d ff 00 00 00       	cmp    $0xff,%eax
  800196:	75 1a                	jne    8001b2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800198:	83 ec 08             	sub    $0x8,%esp
  80019b:	68 ff 00 00 00       	push   $0xff
  8001a0:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 ed fe ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  8001a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001af:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b9:	c9                   	leave  
  8001ba:	c3                   	ret    

008001bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cb:	00 00 00 
	b.cnt = 0;
  8001ce:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d8:	ff 75 0c             	pushl  0xc(%ebp)
  8001db:	ff 75 08             	pushl  0x8(%ebp)
  8001de:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e4:	50                   	push   %eax
  8001e5:	68 79 01 80 00       	push   $0x800179
  8001ea:	e8 54 01 00 00       	call   800343 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ef:	83 c4 08             	add    $0x8,%esp
  8001f2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	e8 92 fe ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  800204:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800212:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800215:	50                   	push   %eax
  800216:	ff 75 08             	pushl  0x8(%ebp)
  800219:	e8 9d ff ff ff       	call   8001bb <vcprintf>
	va_end(ap);

	return cnt;
}
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 1c             	sub    $0x1c,%esp
  800229:	89 c7                	mov    %eax,%edi
  80022b:	89 d6                	mov    %edx,%esi
  80022d:	8b 45 08             	mov    0x8(%ebp),%eax
  800230:	8b 55 0c             	mov    0xc(%ebp),%edx
  800233:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800236:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800239:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80023c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800241:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800244:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800247:	39 d3                	cmp    %edx,%ebx
  800249:	72 05                	jb     800250 <printnum+0x30>
  80024b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024e:	77 45                	ja     800295 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	ff 75 18             	pushl  0x18(%ebp)
  800256:	8b 45 14             	mov    0x14(%ebp),%eax
  800259:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80025c:	53                   	push   %ebx
  80025d:	ff 75 10             	pushl  0x10(%ebp)
  800260:	83 ec 08             	sub    $0x8,%esp
  800263:	ff 75 e4             	pushl  -0x1c(%ebp)
  800266:	ff 75 e0             	pushl  -0x20(%ebp)
  800269:	ff 75 dc             	pushl  -0x24(%ebp)
  80026c:	ff 75 d8             	pushl  -0x28(%ebp)
  80026f:	e8 ac 08 00 00       	call   800b20 <__udivdi3>
  800274:	83 c4 18             	add    $0x18,%esp
  800277:	52                   	push   %edx
  800278:	50                   	push   %eax
  800279:	89 f2                	mov    %esi,%edx
  80027b:	89 f8                	mov    %edi,%eax
  80027d:	e8 9e ff ff ff       	call   800220 <printnum>
  800282:	83 c4 20             	add    $0x20,%esp
  800285:	eb 18                	jmp    80029f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800287:	83 ec 08             	sub    $0x8,%esp
  80028a:	56                   	push   %esi
  80028b:	ff 75 18             	pushl  0x18(%ebp)
  80028e:	ff d7                	call   *%edi
  800290:	83 c4 10             	add    $0x10,%esp
  800293:	eb 03                	jmp    800298 <printnum+0x78>
  800295:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800298:	83 eb 01             	sub    $0x1,%ebx
  80029b:	85 db                	test   %ebx,%ebx
  80029d:	7f e8                	jg     800287 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029f:	83 ec 08             	sub    $0x8,%esp
  8002a2:	56                   	push   %esi
  8002a3:	83 ec 04             	sub    $0x4,%esp
  8002a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ac:	ff 75 dc             	pushl  -0x24(%ebp)
  8002af:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b2:	e8 99 09 00 00       	call   800c50 <__umoddi3>
  8002b7:	83 c4 14             	add    $0x14,%esp
  8002ba:	0f be 80 28 0e 80 00 	movsbl 0x800e28(%eax),%eax
  8002c1:	50                   	push   %eax
  8002c2:	ff d7                	call   *%edi
}
  8002c4:	83 c4 10             	add    $0x10,%esp
  8002c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5e                   	pop    %esi
  8002cc:	5f                   	pop    %edi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d2:	83 fa 01             	cmp    $0x1,%edx
  8002d5:	7e 0e                	jle    8002e5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d7:	8b 10                	mov    (%eax),%edx
  8002d9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002dc:	89 08                	mov    %ecx,(%eax)
  8002de:	8b 02                	mov    (%edx),%eax
  8002e0:	8b 52 04             	mov    0x4(%edx),%edx
  8002e3:	eb 22                	jmp    800307 <getuint+0x38>
	else if (lflag)
  8002e5:	85 d2                	test   %edx,%edx
  8002e7:	74 10                	je     8002f9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ee:	89 08                	mov    %ecx,(%eax)
  8002f0:	8b 02                	mov    (%edx),%eax
  8002f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f7:	eb 0e                	jmp    800307 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f9:	8b 10                	mov    (%eax),%edx
  8002fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fe:	89 08                	mov    %ecx,(%eax)
  800300:	8b 02                	mov    (%edx),%eax
  800302:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800313:	8b 10                	mov    (%eax),%edx
  800315:	3b 50 04             	cmp    0x4(%eax),%edx
  800318:	73 0a                	jae    800324 <sprintputch+0x1b>
		*b->buf++ = ch;
  80031a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80031d:	89 08                	mov    %ecx,(%eax)
  80031f:	8b 45 08             	mov    0x8(%ebp),%eax
  800322:	88 02                	mov    %al,(%edx)
}
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80032c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80032f:	50                   	push   %eax
  800330:	ff 75 10             	pushl  0x10(%ebp)
  800333:	ff 75 0c             	pushl  0xc(%ebp)
  800336:	ff 75 08             	pushl  0x8(%ebp)
  800339:	e8 05 00 00 00       	call   800343 <vprintfmt>
	va_end(ap);
}
  80033e:	83 c4 10             	add    $0x10,%esp
  800341:	c9                   	leave  
  800342:	c3                   	ret    

00800343 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	57                   	push   %edi
  800347:	56                   	push   %esi
  800348:	53                   	push   %ebx
  800349:	83 ec 2c             	sub    $0x2c,%esp
  80034c:	8b 75 08             	mov    0x8(%ebp),%esi
  80034f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800352:	8b 7d 10             	mov    0x10(%ebp),%edi
  800355:	eb 12                	jmp    800369 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800357:	85 c0                	test   %eax,%eax
  800359:	0f 84 cb 03 00 00    	je     80072a <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  80035f:	83 ec 08             	sub    $0x8,%esp
  800362:	53                   	push   %ebx
  800363:	50                   	push   %eax
  800364:	ff d6                	call   *%esi
  800366:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800369:	83 c7 01             	add    $0x1,%edi
  80036c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800370:	83 f8 25             	cmp    $0x25,%eax
  800373:	75 e2                	jne    800357 <vprintfmt+0x14>
  800375:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800379:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800380:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800387:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80038e:	ba 00 00 00 00       	mov    $0x0,%edx
  800393:	eb 07                	jmp    80039c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800398:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8d 47 01             	lea    0x1(%edi),%eax
  80039f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a2:	0f b6 07             	movzbl (%edi),%eax
  8003a5:	0f b6 c8             	movzbl %al,%ecx
  8003a8:	83 e8 23             	sub    $0x23,%eax
  8003ab:	3c 55                	cmp    $0x55,%al
  8003ad:	0f 87 5c 03 00 00    	ja     80070f <vprintfmt+0x3cc>
  8003b3:	0f b6 c0             	movzbl %al,%eax
  8003b6:	ff 24 85 e0 0e 80 00 	jmp    *0x800ee0(,%eax,4)
  8003bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003c4:	eb d6                	jmp    80039c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003d8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003db:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003de:	83 fa 09             	cmp    $0x9,%edx
  8003e1:	77 39                	ja     80041c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003e3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e6:	eb e9                	jmp    8003d1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003eb:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ee:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f1:	8b 00                	mov    (%eax),%eax
  8003f3:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f9:	eb 27                	jmp    800422 <vprintfmt+0xdf>
  8003fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003fe:	85 c0                	test   %eax,%eax
  800400:	b9 00 00 00 00       	mov    $0x0,%ecx
  800405:	0f 49 c8             	cmovns %eax,%ecx
  800408:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040e:	eb 8c                	jmp    80039c <vprintfmt+0x59>
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800413:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80041a:	eb 80                	jmp    80039c <vprintfmt+0x59>
  80041c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80041f:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800422:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800426:	0f 89 70 ff ff ff    	jns    80039c <vprintfmt+0x59>
				width = precision, precision = -1;
  80042c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80042f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800432:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800439:	e9 5e ff ff ff       	jmp    80039c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80043e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800444:	e9 53 ff ff ff       	jmp    80039c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 50 04             	lea    0x4(%eax),%edx
  80044f:	89 55 14             	mov    %edx,0x14(%ebp)
  800452:	83 ec 08             	sub    $0x8,%esp
  800455:	53                   	push   %ebx
  800456:	ff 30                	pushl  (%eax)
  800458:	ff d6                	call   *%esi
			break;
  80045a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800460:	e9 04 ff ff ff       	jmp    800369 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800465:	8b 45 14             	mov    0x14(%ebp),%eax
  800468:	8d 50 04             	lea    0x4(%eax),%edx
  80046b:	89 55 14             	mov    %edx,0x14(%ebp)
  80046e:	8b 00                	mov    (%eax),%eax
  800470:	99                   	cltd   
  800471:	31 d0                	xor    %edx,%eax
  800473:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800475:	83 f8 07             	cmp    $0x7,%eax
  800478:	7f 0b                	jg     800485 <vprintfmt+0x142>
  80047a:	8b 14 85 40 10 80 00 	mov    0x801040(,%eax,4),%edx
  800481:	85 d2                	test   %edx,%edx
  800483:	75 18                	jne    80049d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800485:	50                   	push   %eax
  800486:	68 40 0e 80 00       	push   $0x800e40
  80048b:	53                   	push   %ebx
  80048c:	56                   	push   %esi
  80048d:	e8 94 fe ff ff       	call   800326 <printfmt>
  800492:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800498:	e9 cc fe ff ff       	jmp    800369 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80049d:	52                   	push   %edx
  80049e:	68 49 0e 80 00       	push   $0x800e49
  8004a3:	53                   	push   %ebx
  8004a4:	56                   	push   %esi
  8004a5:	e8 7c fe ff ff       	call   800326 <printfmt>
  8004aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b0:	e9 b4 fe ff ff       	jmp    800369 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b8:	8d 50 04             	lea    0x4(%eax),%edx
  8004bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004be:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c0:	85 ff                	test   %edi,%edi
  8004c2:	b8 39 0e 80 00       	mov    $0x800e39,%eax
  8004c7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ce:	0f 8e 94 00 00 00    	jle    800568 <vprintfmt+0x225>
  8004d4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d8:	0f 84 98 00 00 00    	je     800576 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	ff 75 c8             	pushl  -0x38(%ebp)
  8004e4:	57                   	push   %edi
  8004e5:	e8 c8 02 00 00       	call   8007b2 <strnlen>
  8004ea:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ed:	29 c1                	sub    %eax,%ecx
  8004ef:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004f2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004f5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004fc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ff:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800501:	eb 0f                	jmp    800512 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	53                   	push   %ebx
  800507:	ff 75 e0             	pushl  -0x20(%ebp)
  80050a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050c:	83 ef 01             	sub    $0x1,%edi
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	85 ff                	test   %edi,%edi
  800514:	7f ed                	jg     800503 <vprintfmt+0x1c0>
  800516:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800519:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80051c:	85 c9                	test   %ecx,%ecx
  80051e:	b8 00 00 00 00       	mov    $0x0,%eax
  800523:	0f 49 c1             	cmovns %ecx,%eax
  800526:	29 c1                	sub    %eax,%ecx
  800528:	89 75 08             	mov    %esi,0x8(%ebp)
  80052b:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80052e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800531:	89 cb                	mov    %ecx,%ebx
  800533:	eb 4d                	jmp    800582 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800535:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800539:	74 1b                	je     800556 <vprintfmt+0x213>
  80053b:	0f be c0             	movsbl %al,%eax
  80053e:	83 e8 20             	sub    $0x20,%eax
  800541:	83 f8 5e             	cmp    $0x5e,%eax
  800544:	76 10                	jbe    800556 <vprintfmt+0x213>
					putch('?', putdat);
  800546:	83 ec 08             	sub    $0x8,%esp
  800549:	ff 75 0c             	pushl  0xc(%ebp)
  80054c:	6a 3f                	push   $0x3f
  80054e:	ff 55 08             	call   *0x8(%ebp)
  800551:	83 c4 10             	add    $0x10,%esp
  800554:	eb 0d                	jmp    800563 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	ff 75 0c             	pushl  0xc(%ebp)
  80055c:	52                   	push   %edx
  80055d:	ff 55 08             	call   *0x8(%ebp)
  800560:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800563:	83 eb 01             	sub    $0x1,%ebx
  800566:	eb 1a                	jmp    800582 <vprintfmt+0x23f>
  800568:	89 75 08             	mov    %esi,0x8(%ebp)
  80056b:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80056e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800571:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800574:	eb 0c                	jmp    800582 <vprintfmt+0x23f>
  800576:	89 75 08             	mov    %esi,0x8(%ebp)
  800579:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80057c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800582:	83 c7 01             	add    $0x1,%edi
  800585:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800589:	0f be d0             	movsbl %al,%edx
  80058c:	85 d2                	test   %edx,%edx
  80058e:	74 23                	je     8005b3 <vprintfmt+0x270>
  800590:	85 f6                	test   %esi,%esi
  800592:	78 a1                	js     800535 <vprintfmt+0x1f2>
  800594:	83 ee 01             	sub    $0x1,%esi
  800597:	79 9c                	jns    800535 <vprintfmt+0x1f2>
  800599:	89 df                	mov    %ebx,%edi
  80059b:	8b 75 08             	mov    0x8(%ebp),%esi
  80059e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a1:	eb 18                	jmp    8005bb <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a3:	83 ec 08             	sub    $0x8,%esp
  8005a6:	53                   	push   %ebx
  8005a7:	6a 20                	push   $0x20
  8005a9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ab:	83 ef 01             	sub    $0x1,%edi
  8005ae:	83 c4 10             	add    $0x10,%esp
  8005b1:	eb 08                	jmp    8005bb <vprintfmt+0x278>
  8005b3:	89 df                	mov    %ebx,%edi
  8005b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bb:	85 ff                	test   %edi,%edi
  8005bd:	7f e4                	jg     8005a3 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c2:	e9 a2 fd ff ff       	jmp    800369 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c7:	83 fa 01             	cmp    $0x1,%edx
  8005ca:	7e 16                	jle    8005e2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 50 08             	lea    0x8(%eax),%edx
  8005d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d5:	8b 50 04             	mov    0x4(%eax),%edx
  8005d8:	8b 00                	mov    (%eax),%eax
  8005da:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005dd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005e0:	eb 32                	jmp    800614 <vprintfmt+0x2d1>
	else if (lflag)
  8005e2:	85 d2                	test   %edx,%edx
  8005e4:	74 18                	je     8005fe <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 50 04             	lea    0x4(%eax),%edx
  8005ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ef:	8b 00                	mov    (%eax),%eax
  8005f1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005f4:	89 c1                	mov    %eax,%ecx
  8005f6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005fc:	eb 16                	jmp    800614 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8d 50 04             	lea    0x4(%eax),%edx
  800604:	89 55 14             	mov    %edx,0x14(%ebp)
  800607:	8b 00                	mov    (%eax),%eax
  800609:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80060c:	89 c1                	mov    %eax,%ecx
  80060e:	c1 f9 1f             	sar    $0x1f,%ecx
  800611:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800614:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800617:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80061a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800620:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800625:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800629:	0f 89 a8 00 00 00    	jns    8006d7 <vprintfmt+0x394>
				putch('-', putdat);
  80062f:	83 ec 08             	sub    $0x8,%esp
  800632:	53                   	push   %ebx
  800633:	6a 2d                	push   $0x2d
  800635:	ff d6                	call   *%esi
				num = -(long long) num;
  800637:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80063a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80063d:	f7 d8                	neg    %eax
  80063f:	83 d2 00             	adc    $0x0,%edx
  800642:	f7 da                	neg    %edx
  800644:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800647:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80064a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80064d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800652:	e9 80 00 00 00       	jmp    8006d7 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800657:	8d 45 14             	lea    0x14(%ebp),%eax
  80065a:	e8 70 fc ff ff       	call   8002cf <getuint>
  80065f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800662:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800665:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80066a:	eb 6b                	jmp    8006d7 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80066c:	8d 45 14             	lea    0x14(%ebp),%eax
  80066f:	e8 5b fc ff ff       	call   8002cf <getuint>
  800674:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800677:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  80067a:	6a 04                	push   $0x4
  80067c:	6a 03                	push   $0x3
  80067e:	6a 01                	push   $0x1
  800680:	68 4c 0e 80 00       	push   $0x800e4c
  800685:	e8 82 fb ff ff       	call   80020c <cprintf>
			goto number;
  80068a:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  80068d:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  800692:	eb 43                	jmp    8006d7 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  800694:	83 ec 08             	sub    $0x8,%esp
  800697:	53                   	push   %ebx
  800698:	6a 30                	push   $0x30
  80069a:	ff d6                	call   *%esi
			putch('x', putdat);
  80069c:	83 c4 08             	add    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	6a 78                	push   $0x78
  8006a2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8d 50 04             	lea    0x4(%eax),%edx
  8006aa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ad:	8b 00                	mov    (%eax),%eax
  8006af:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ba:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006bd:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006c2:	eb 13                	jmp    8006d7 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c7:	e8 03 fc ff ff       	call   8002cf <getuint>
  8006cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006d2:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d7:	83 ec 0c             	sub    $0xc,%esp
  8006da:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006de:	52                   	push   %edx
  8006df:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e2:	50                   	push   %eax
  8006e3:	ff 75 dc             	pushl  -0x24(%ebp)
  8006e6:	ff 75 d8             	pushl  -0x28(%ebp)
  8006e9:	89 da                	mov    %ebx,%edx
  8006eb:	89 f0                	mov    %esi,%eax
  8006ed:	e8 2e fb ff ff       	call   800220 <printnum>

			break;
  8006f2:	83 c4 20             	add    $0x20,%esp
  8006f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f8:	e9 6c fc ff ff       	jmp    800369 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	53                   	push   %ebx
  800701:	51                   	push   %ecx
  800702:	ff d6                	call   *%esi
			break;
  800704:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800707:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80070a:	e9 5a fc ff ff       	jmp    800369 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	53                   	push   %ebx
  800713:	6a 25                	push   $0x25
  800715:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800717:	83 c4 10             	add    $0x10,%esp
  80071a:	eb 03                	jmp    80071f <vprintfmt+0x3dc>
  80071c:	83 ef 01             	sub    $0x1,%edi
  80071f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800723:	75 f7                	jne    80071c <vprintfmt+0x3d9>
  800725:	e9 3f fc ff ff       	jmp    800369 <vprintfmt+0x26>
			break;
		}

	}

}
  80072a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072d:	5b                   	pop    %ebx
  80072e:	5e                   	pop    %esi
  80072f:	5f                   	pop    %edi
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 18             	sub    $0x18,%esp
  800738:	8b 45 08             	mov    0x8(%ebp),%eax
  80073b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800741:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800745:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800748:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074f:	85 c0                	test   %eax,%eax
  800751:	74 26                	je     800779 <vsnprintf+0x47>
  800753:	85 d2                	test   %edx,%edx
  800755:	7e 22                	jle    800779 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800757:	ff 75 14             	pushl  0x14(%ebp)
  80075a:	ff 75 10             	pushl  0x10(%ebp)
  80075d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800760:	50                   	push   %eax
  800761:	68 09 03 80 00       	push   $0x800309
  800766:	e8 d8 fb ff ff       	call   800343 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800771:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	eb 05                	jmp    80077e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800779:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800786:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800789:	50                   	push   %eax
  80078a:	ff 75 10             	pushl  0x10(%ebp)
  80078d:	ff 75 0c             	pushl  0xc(%ebp)
  800790:	ff 75 08             	pushl  0x8(%ebp)
  800793:	e8 9a ff ff ff       	call   800732 <vsnprintf>
	va_end(ap);

	return rc;
}
  800798:	c9                   	leave  
  800799:	c3                   	ret    

0080079a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a5:	eb 03                	jmp    8007aa <strlen+0x10>
		n++;
  8007a7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007aa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ae:	75 f7                	jne    8007a7 <strlen+0xd>
		n++;
	return n;
}
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c0:	eb 03                	jmp    8007c5 <strnlen+0x13>
		n++;
  8007c2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c5:	39 c2                	cmp    %eax,%edx
  8007c7:	74 08                	je     8007d1 <strnlen+0x1f>
  8007c9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007cd:	75 f3                	jne    8007c2 <strnlen+0x10>
  8007cf:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	53                   	push   %ebx
  8007d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007dd:	89 c2                	mov    %eax,%edx
  8007df:	83 c2 01             	add    $0x1,%edx
  8007e2:	83 c1 01             	add    $0x1,%ecx
  8007e5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007e9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ec:	84 db                	test   %bl,%bl
  8007ee:	75 ef                	jne    8007df <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f0:	5b                   	pop    %ebx
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	53                   	push   %ebx
  8007f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007fa:	53                   	push   %ebx
  8007fb:	e8 9a ff ff ff       	call   80079a <strlen>
  800800:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800803:	ff 75 0c             	pushl  0xc(%ebp)
  800806:	01 d8                	add    %ebx,%eax
  800808:	50                   	push   %eax
  800809:	e8 c5 ff ff ff       	call   8007d3 <strcpy>
	return dst;
}
  80080e:	89 d8                	mov    %ebx,%eax
  800810:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800813:	c9                   	leave  
  800814:	c3                   	ret    

00800815 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	56                   	push   %esi
  800819:	53                   	push   %ebx
  80081a:	8b 75 08             	mov    0x8(%ebp),%esi
  80081d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800820:	89 f3                	mov    %esi,%ebx
  800822:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800825:	89 f2                	mov    %esi,%edx
  800827:	eb 0f                	jmp    800838 <strncpy+0x23>
		*dst++ = *src;
  800829:	83 c2 01             	add    $0x1,%edx
  80082c:	0f b6 01             	movzbl (%ecx),%eax
  80082f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800832:	80 39 01             	cmpb   $0x1,(%ecx)
  800835:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800838:	39 da                	cmp    %ebx,%edx
  80083a:	75 ed                	jne    800829 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80083c:	89 f0                	mov    %esi,%eax
  80083e:	5b                   	pop    %ebx
  80083f:	5e                   	pop    %esi
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	56                   	push   %esi
  800846:	53                   	push   %ebx
  800847:	8b 75 08             	mov    0x8(%ebp),%esi
  80084a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084d:	8b 55 10             	mov    0x10(%ebp),%edx
  800850:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800852:	85 d2                	test   %edx,%edx
  800854:	74 21                	je     800877 <strlcpy+0x35>
  800856:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80085a:	89 f2                	mov    %esi,%edx
  80085c:	eb 09                	jmp    800867 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085e:	83 c2 01             	add    $0x1,%edx
  800861:	83 c1 01             	add    $0x1,%ecx
  800864:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800867:	39 c2                	cmp    %eax,%edx
  800869:	74 09                	je     800874 <strlcpy+0x32>
  80086b:	0f b6 19             	movzbl (%ecx),%ebx
  80086e:	84 db                	test   %bl,%bl
  800870:	75 ec                	jne    80085e <strlcpy+0x1c>
  800872:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800874:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800877:	29 f0                	sub    %esi,%eax
}
  800879:	5b                   	pop    %ebx
  80087a:	5e                   	pop    %esi
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800883:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800886:	eb 06                	jmp    80088e <strcmp+0x11>
		p++, q++;
  800888:	83 c1 01             	add    $0x1,%ecx
  80088b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80088e:	0f b6 01             	movzbl (%ecx),%eax
  800891:	84 c0                	test   %al,%al
  800893:	74 04                	je     800899 <strcmp+0x1c>
  800895:	3a 02                	cmp    (%edx),%al
  800897:	74 ef                	je     800888 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800899:	0f b6 c0             	movzbl %al,%eax
  80089c:	0f b6 12             	movzbl (%edx),%edx
  80089f:	29 d0                	sub    %edx,%eax
}
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	53                   	push   %ebx
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ad:	89 c3                	mov    %eax,%ebx
  8008af:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b2:	eb 06                	jmp    8008ba <strncmp+0x17>
		n--, p++, q++;
  8008b4:	83 c0 01             	add    $0x1,%eax
  8008b7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ba:	39 d8                	cmp    %ebx,%eax
  8008bc:	74 15                	je     8008d3 <strncmp+0x30>
  8008be:	0f b6 08             	movzbl (%eax),%ecx
  8008c1:	84 c9                	test   %cl,%cl
  8008c3:	74 04                	je     8008c9 <strncmp+0x26>
  8008c5:	3a 0a                	cmp    (%edx),%cl
  8008c7:	74 eb                	je     8008b4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c9:	0f b6 00             	movzbl (%eax),%eax
  8008cc:	0f b6 12             	movzbl (%edx),%edx
  8008cf:	29 d0                	sub    %edx,%eax
  8008d1:	eb 05                	jmp    8008d8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d8:	5b                   	pop    %ebx
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e5:	eb 07                	jmp    8008ee <strchr+0x13>
		if (*s == c)
  8008e7:	38 ca                	cmp    %cl,%dl
  8008e9:	74 0f                	je     8008fa <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008eb:	83 c0 01             	add    $0x1,%eax
  8008ee:	0f b6 10             	movzbl (%eax),%edx
  8008f1:	84 d2                	test   %dl,%dl
  8008f3:	75 f2                	jne    8008e7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800906:	eb 03                	jmp    80090b <strfind+0xf>
  800908:	83 c0 01             	add    $0x1,%eax
  80090b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090e:	38 ca                	cmp    %cl,%dl
  800910:	74 04                	je     800916 <strfind+0x1a>
  800912:	84 d2                	test   %dl,%dl
  800914:	75 f2                	jne    800908 <strfind+0xc>
			break;
	return (char *) s;
}
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	57                   	push   %edi
  80091c:	56                   	push   %esi
  80091d:	53                   	push   %ebx
  80091e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800921:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800924:	85 c9                	test   %ecx,%ecx
  800926:	74 36                	je     80095e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800928:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092e:	75 28                	jne    800958 <memset+0x40>
  800930:	f6 c1 03             	test   $0x3,%cl
  800933:	75 23                	jne    800958 <memset+0x40>
		c &= 0xFF;
  800935:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800939:	89 d3                	mov    %edx,%ebx
  80093b:	c1 e3 08             	shl    $0x8,%ebx
  80093e:	89 d6                	mov    %edx,%esi
  800940:	c1 e6 18             	shl    $0x18,%esi
  800943:	89 d0                	mov    %edx,%eax
  800945:	c1 e0 10             	shl    $0x10,%eax
  800948:	09 f0                	or     %esi,%eax
  80094a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80094c:	89 d8                	mov    %ebx,%eax
  80094e:	09 d0                	or     %edx,%eax
  800950:	c1 e9 02             	shr    $0x2,%ecx
  800953:	fc                   	cld    
  800954:	f3 ab                	rep stos %eax,%es:(%edi)
  800956:	eb 06                	jmp    80095e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800958:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095b:	fc                   	cld    
  80095c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095e:	89 f8                	mov    %edi,%eax
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5f                   	pop    %edi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	57                   	push   %edi
  800969:	56                   	push   %esi
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800970:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800973:	39 c6                	cmp    %eax,%esi
  800975:	73 35                	jae    8009ac <memmove+0x47>
  800977:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097a:	39 d0                	cmp    %edx,%eax
  80097c:	73 2e                	jae    8009ac <memmove+0x47>
		s += n;
		d += n;
  80097e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800981:	89 d6                	mov    %edx,%esi
  800983:	09 fe                	or     %edi,%esi
  800985:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098b:	75 13                	jne    8009a0 <memmove+0x3b>
  80098d:	f6 c1 03             	test   $0x3,%cl
  800990:	75 0e                	jne    8009a0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800992:	83 ef 04             	sub    $0x4,%edi
  800995:	8d 72 fc             	lea    -0x4(%edx),%esi
  800998:	c1 e9 02             	shr    $0x2,%ecx
  80099b:	fd                   	std    
  80099c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099e:	eb 09                	jmp    8009a9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a0:	83 ef 01             	sub    $0x1,%edi
  8009a3:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009a6:	fd                   	std    
  8009a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a9:	fc                   	cld    
  8009aa:	eb 1d                	jmp    8009c9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ac:	89 f2                	mov    %esi,%edx
  8009ae:	09 c2                	or     %eax,%edx
  8009b0:	f6 c2 03             	test   $0x3,%dl
  8009b3:	75 0f                	jne    8009c4 <memmove+0x5f>
  8009b5:	f6 c1 03             	test   $0x3,%cl
  8009b8:	75 0a                	jne    8009c4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009ba:	c1 e9 02             	shr    $0x2,%ecx
  8009bd:	89 c7                	mov    %eax,%edi
  8009bf:	fc                   	cld    
  8009c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c2:	eb 05                	jmp    8009c9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c4:	89 c7                	mov    %eax,%edi
  8009c6:	fc                   	cld    
  8009c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c9:	5e                   	pop    %esi
  8009ca:	5f                   	pop    %edi
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d0:	ff 75 10             	pushl  0x10(%ebp)
  8009d3:	ff 75 0c             	pushl  0xc(%ebp)
  8009d6:	ff 75 08             	pushl  0x8(%ebp)
  8009d9:	e8 87 ff ff ff       	call   800965 <memmove>
}
  8009de:	c9                   	leave  
  8009df:	c3                   	ret    

008009e0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009eb:	89 c6                	mov    %eax,%esi
  8009ed:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f0:	eb 1a                	jmp    800a0c <memcmp+0x2c>
		if (*s1 != *s2)
  8009f2:	0f b6 08             	movzbl (%eax),%ecx
  8009f5:	0f b6 1a             	movzbl (%edx),%ebx
  8009f8:	38 d9                	cmp    %bl,%cl
  8009fa:	74 0a                	je     800a06 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009fc:	0f b6 c1             	movzbl %cl,%eax
  8009ff:	0f b6 db             	movzbl %bl,%ebx
  800a02:	29 d8                	sub    %ebx,%eax
  800a04:	eb 0f                	jmp    800a15 <memcmp+0x35>
		s1++, s2++;
  800a06:	83 c0 01             	add    $0x1,%eax
  800a09:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0c:	39 f0                	cmp    %esi,%eax
  800a0e:	75 e2                	jne    8009f2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a15:	5b                   	pop    %ebx
  800a16:	5e                   	pop    %esi
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	53                   	push   %ebx
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a20:	89 c1                	mov    %eax,%ecx
  800a22:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a25:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a29:	eb 0a                	jmp    800a35 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2b:	0f b6 10             	movzbl (%eax),%edx
  800a2e:	39 da                	cmp    %ebx,%edx
  800a30:	74 07                	je     800a39 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a32:	83 c0 01             	add    $0x1,%eax
  800a35:	39 c8                	cmp    %ecx,%eax
  800a37:	72 f2                	jb     800a2b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a39:	5b                   	pop    %ebx
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	57                   	push   %edi
  800a40:	56                   	push   %esi
  800a41:	53                   	push   %ebx
  800a42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a48:	eb 03                	jmp    800a4d <strtol+0x11>
		s++;
  800a4a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4d:	0f b6 01             	movzbl (%ecx),%eax
  800a50:	3c 20                	cmp    $0x20,%al
  800a52:	74 f6                	je     800a4a <strtol+0xe>
  800a54:	3c 09                	cmp    $0x9,%al
  800a56:	74 f2                	je     800a4a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a58:	3c 2b                	cmp    $0x2b,%al
  800a5a:	75 0a                	jne    800a66 <strtol+0x2a>
		s++;
  800a5c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a5f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a64:	eb 11                	jmp    800a77 <strtol+0x3b>
  800a66:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a6b:	3c 2d                	cmp    $0x2d,%al
  800a6d:	75 08                	jne    800a77 <strtol+0x3b>
		s++, neg = 1;
  800a6f:	83 c1 01             	add    $0x1,%ecx
  800a72:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a77:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a7d:	75 15                	jne    800a94 <strtol+0x58>
  800a7f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a82:	75 10                	jne    800a94 <strtol+0x58>
  800a84:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a88:	75 7c                	jne    800b06 <strtol+0xca>
		s += 2, base = 16;
  800a8a:	83 c1 02             	add    $0x2,%ecx
  800a8d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a92:	eb 16                	jmp    800aaa <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a94:	85 db                	test   %ebx,%ebx
  800a96:	75 12                	jne    800aaa <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a98:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a9d:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa0:	75 08                	jne    800aaa <strtol+0x6e>
		s++, base = 8;
  800aa2:	83 c1 01             	add    $0x1,%ecx
  800aa5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaf:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab2:	0f b6 11             	movzbl (%ecx),%edx
  800ab5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab8:	89 f3                	mov    %esi,%ebx
  800aba:	80 fb 09             	cmp    $0x9,%bl
  800abd:	77 08                	ja     800ac7 <strtol+0x8b>
			dig = *s - '0';
  800abf:	0f be d2             	movsbl %dl,%edx
  800ac2:	83 ea 30             	sub    $0x30,%edx
  800ac5:	eb 22                	jmp    800ae9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ac7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aca:	89 f3                	mov    %esi,%ebx
  800acc:	80 fb 19             	cmp    $0x19,%bl
  800acf:	77 08                	ja     800ad9 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ad1:	0f be d2             	movsbl %dl,%edx
  800ad4:	83 ea 57             	sub    $0x57,%edx
  800ad7:	eb 10                	jmp    800ae9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ad9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800adc:	89 f3                	mov    %esi,%ebx
  800ade:	80 fb 19             	cmp    $0x19,%bl
  800ae1:	77 16                	ja     800af9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ae3:	0f be d2             	movsbl %dl,%edx
  800ae6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ae9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aec:	7d 0b                	jge    800af9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aee:	83 c1 01             	add    $0x1,%ecx
  800af1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800af7:	eb b9                	jmp    800ab2 <strtol+0x76>

	if (endptr)
  800af9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afd:	74 0d                	je     800b0c <strtol+0xd0>
		*endptr = (char *) s;
  800aff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b02:	89 0e                	mov    %ecx,(%esi)
  800b04:	eb 06                	jmp    800b0c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b06:	85 db                	test   %ebx,%ebx
  800b08:	74 98                	je     800aa2 <strtol+0x66>
  800b0a:	eb 9e                	jmp    800aaa <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b0c:	89 c2                	mov    %eax,%edx
  800b0e:	f7 da                	neg    %edx
  800b10:	85 ff                	test   %edi,%edi
  800b12:	0f 45 c2             	cmovne %edx,%eax
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    
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
