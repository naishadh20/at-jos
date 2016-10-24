
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 6a 00 00 00       	call   8000af <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800055:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80005c:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  80005f:	e8 c9 00 00 00       	call   80012d <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80006c:	c1 e0 05             	shl    $0x5,%eax
  80006f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800074:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 db                	test   %ebx,%ebx
  80007b:	7e 07                	jle    800084 <libmain+0x3a>
		binaryname = argv[0];
  80007d:	8b 06                	mov    (%esi),%eax
  80007f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	56                   	push   %esi
  800088:	53                   	push   %ebx
  800089:	e8 a5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008e:	e8 0a 00 00 00       	call   80009d <exit>
}
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800099:	5b                   	pop    %ebx
  80009a:	5e                   	pop    %esi
  80009b:	5d                   	pop    %ebp
  80009c:	c3                   	ret    

0080009d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a3:	6a 00                	push   $0x0
  8000a5:	e8 42 00 00 00       	call   8000ec <sys_env_destroy>
}
  8000aa:	83 c4 10             	add    $0x10,%esp
  8000ad:	c9                   	leave  
  8000ae:	c3                   	ret    

008000af <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	57                   	push   %edi
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c0:	89 c3                	mov    %eax,%ebx
  8000c2:	89 c7                	mov    %eax,%edi
  8000c4:	89 c6                	mov    %eax,%esi
  8000c6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5f                   	pop    %edi
  8000cb:	5d                   	pop    %ebp
  8000cc:	c3                   	ret    

008000cd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	57                   	push   %edi
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dd:	89 d1                	mov    %edx,%ecx
  8000df:	89 d3                	mov    %edx,%ebx
  8000e1:	89 d7                	mov    %edx,%edi
  8000e3:	89 d6                	mov    %edx,%esi
  8000e5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5f                   	pop    %edi
  8000ea:	5d                   	pop    %ebp
  8000eb:	c3                   	ret    

008000ec <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800102:	89 cb                	mov    %ecx,%ebx
  800104:	89 cf                	mov    %ecx,%edi
  800106:	89 ce                	mov    %ecx,%esi
  800108:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010a:	85 c0                	test   %eax,%eax
  80010c:	7e 17                	jle    800125 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	6a 03                	push   $0x3
  800114:	68 ea 0d 80 00       	push   $0x800dea
  800119:	6a 23                	push   $0x23
  80011b:	68 07 0e 80 00       	push   $0x800e07
  800120:	e8 27 00 00 00       	call   80014c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800125:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800128:	5b                   	pop    %ebx
  800129:	5e                   	pop    %esi
  80012a:	5f                   	pop    %edi
  80012b:	5d                   	pop    %ebp
  80012c:	c3                   	ret    

0080012d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	57                   	push   %edi
  800131:	56                   	push   %esi
  800132:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800133:	ba 00 00 00 00       	mov    $0x0,%edx
  800138:	b8 02 00 00 00       	mov    $0x2,%eax
  80013d:	89 d1                	mov    %edx,%ecx
  80013f:	89 d3                	mov    %edx,%ebx
  800141:	89 d7                	mov    %edx,%edi
  800143:	89 d6                	mov    %edx,%esi
  800145:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800147:	5b                   	pop    %ebx
  800148:	5e                   	pop    %esi
  800149:	5f                   	pop    %edi
  80014a:	5d                   	pop    %ebp
  80014b:	c3                   	ret    

0080014c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800151:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800154:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80015a:	e8 ce ff ff ff       	call   80012d <sys_getenvid>
  80015f:	83 ec 0c             	sub    $0xc,%esp
  800162:	ff 75 0c             	pushl  0xc(%ebp)
  800165:	ff 75 08             	pushl  0x8(%ebp)
  800168:	56                   	push   %esi
  800169:	50                   	push   %eax
  80016a:	68 18 0e 80 00       	push   $0x800e18
  80016f:	e8 b1 00 00 00       	call   800225 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800174:	83 c4 18             	add    $0x18,%esp
  800177:	53                   	push   %ebx
  800178:	ff 75 10             	pushl  0x10(%ebp)
  80017b:	e8 54 00 00 00       	call   8001d4 <vcprintf>
	cprintf("\n");
  800180:	c7 04 24 70 0e 80 00 	movl   $0x800e70,(%esp)
  800187:	e8 99 00 00 00       	call   800225 <cprintf>
  80018c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018f:	cc                   	int3   
  800190:	eb fd                	jmp    80018f <_panic+0x43>

00800192 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800192:	55                   	push   %ebp
  800193:	89 e5                	mov    %esp,%ebp
  800195:	53                   	push   %ebx
  800196:	83 ec 04             	sub    $0x4,%esp
  800199:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019c:	8b 13                	mov    (%ebx),%edx
  80019e:	8d 42 01             	lea    0x1(%edx),%eax
  8001a1:	89 03                	mov    %eax,(%ebx)
  8001a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001aa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001af:	75 1a                	jne    8001cb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b1:	83 ec 08             	sub    $0x8,%esp
  8001b4:	68 ff 00 00 00       	push   $0xff
  8001b9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bc:	50                   	push   %eax
  8001bd:	e8 ed fe ff ff       	call   8000af <sys_cputs>
		b->idx = 0;
  8001c2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001dd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e4:	00 00 00 
	b.cnt = 0;
  8001e7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ee:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f1:	ff 75 0c             	pushl  0xc(%ebp)
  8001f4:	ff 75 08             	pushl  0x8(%ebp)
  8001f7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fd:	50                   	push   %eax
  8001fe:	68 92 01 80 00       	push   $0x800192
  800203:	e8 54 01 00 00       	call   80035c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800208:	83 c4 08             	add    $0x8,%esp
  80020b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800211:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800217:	50                   	push   %eax
  800218:	e8 92 fe ff ff       	call   8000af <sys_cputs>

	return b.cnt;
}
  80021d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800223:	c9                   	leave  
  800224:	c3                   	ret    

00800225 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022e:	50                   	push   %eax
  80022f:	ff 75 08             	pushl  0x8(%ebp)
  800232:	e8 9d ff ff ff       	call   8001d4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	57                   	push   %edi
  80023d:	56                   	push   %esi
  80023e:	53                   	push   %ebx
  80023f:	83 ec 1c             	sub    $0x1c,%esp
  800242:	89 c7                	mov    %eax,%edi
  800244:	89 d6                	mov    %edx,%esi
  800246:	8b 45 08             	mov    0x8(%ebp),%eax
  800249:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800252:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800255:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800260:	39 d3                	cmp    %edx,%ebx
  800262:	72 05                	jb     800269 <printnum+0x30>
  800264:	39 45 10             	cmp    %eax,0x10(%ebp)
  800267:	77 45                	ja     8002ae <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	ff 75 18             	pushl  0x18(%ebp)
  80026f:	8b 45 14             	mov    0x14(%ebp),%eax
  800272:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800275:	53                   	push   %ebx
  800276:	ff 75 10             	pushl  0x10(%ebp)
  800279:	83 ec 08             	sub    $0x8,%esp
  80027c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027f:	ff 75 e0             	pushl  -0x20(%ebp)
  800282:	ff 75 dc             	pushl  -0x24(%ebp)
  800285:	ff 75 d8             	pushl  -0x28(%ebp)
  800288:	e8 b3 08 00 00       	call   800b40 <__udivdi3>
  80028d:	83 c4 18             	add    $0x18,%esp
  800290:	52                   	push   %edx
  800291:	50                   	push   %eax
  800292:	89 f2                	mov    %esi,%edx
  800294:	89 f8                	mov    %edi,%eax
  800296:	e8 9e ff ff ff       	call   800239 <printnum>
  80029b:	83 c4 20             	add    $0x20,%esp
  80029e:	eb 18                	jmp    8002b8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	56                   	push   %esi
  8002a4:	ff 75 18             	pushl  0x18(%ebp)
  8002a7:	ff d7                	call   *%edi
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	eb 03                	jmp    8002b1 <printnum+0x78>
  8002ae:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b1:	83 eb 01             	sub    $0x1,%ebx
  8002b4:	85 db                	test   %ebx,%ebx
  8002b6:	7f e8                	jg     8002a0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b8:	83 ec 08             	sub    $0x8,%esp
  8002bb:	56                   	push   %esi
  8002bc:	83 ec 04             	sub    $0x4,%esp
  8002bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cb:	e8 a0 09 00 00       	call   800c70 <__umoddi3>
  8002d0:	83 c4 14             	add    $0x14,%esp
  8002d3:	0f be 80 3c 0e 80 00 	movsbl 0x800e3c(%eax),%eax
  8002da:	50                   	push   %eax
  8002db:	ff d7                	call   *%edi
}
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e3:	5b                   	pop    %ebx
  8002e4:	5e                   	pop    %esi
  8002e5:	5f                   	pop    %edi
  8002e6:	5d                   	pop    %ebp
  8002e7:	c3                   	ret    

008002e8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002eb:	83 fa 01             	cmp    $0x1,%edx
  8002ee:	7e 0e                	jle    8002fe <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	8b 52 04             	mov    0x4(%edx),%edx
  8002fc:	eb 22                	jmp    800320 <getuint+0x38>
	else if (lflag)
  8002fe:	85 d2                	test   %edx,%edx
  800300:	74 10                	je     800312 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800302:	8b 10                	mov    (%eax),%edx
  800304:	8d 4a 04             	lea    0x4(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	ba 00 00 00 00       	mov    $0x0,%edx
  800310:	eb 0e                	jmp    800320 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800312:	8b 10                	mov    (%eax),%edx
  800314:	8d 4a 04             	lea    0x4(%edx),%ecx
  800317:	89 08                	mov    %ecx,(%eax)
  800319:	8b 02                	mov    (%edx),%eax
  80031b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800320:	5d                   	pop    %ebp
  800321:	c3                   	ret    

00800322 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800328:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032c:	8b 10                	mov    (%eax),%edx
  80032e:	3b 50 04             	cmp    0x4(%eax),%edx
  800331:	73 0a                	jae    80033d <sprintputch+0x1b>
		*b->buf++ = ch;
  800333:	8d 4a 01             	lea    0x1(%edx),%ecx
  800336:	89 08                	mov    %ecx,(%eax)
  800338:	8b 45 08             	mov    0x8(%ebp),%eax
  80033b:	88 02                	mov    %al,(%edx)
}
  80033d:	5d                   	pop    %ebp
  80033e:	c3                   	ret    

0080033f <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800345:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800348:	50                   	push   %eax
  800349:	ff 75 10             	pushl  0x10(%ebp)
  80034c:	ff 75 0c             	pushl  0xc(%ebp)
  80034f:	ff 75 08             	pushl  0x8(%ebp)
  800352:	e8 05 00 00 00       	call   80035c <vprintfmt>
	va_end(ap);
}
  800357:	83 c4 10             	add    $0x10,%esp
  80035a:	c9                   	leave  
  80035b:	c3                   	ret    

0080035c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	57                   	push   %edi
  800360:	56                   	push   %esi
  800361:	53                   	push   %ebx
  800362:	83 ec 2c             	sub    $0x2c,%esp
  800365:	8b 75 08             	mov    0x8(%ebp),%esi
  800368:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036e:	eb 12                	jmp    800382 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800370:	85 c0                	test   %eax,%eax
  800372:	0f 84 cb 03 00 00    	je     800743 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800378:	83 ec 08             	sub    $0x8,%esp
  80037b:	53                   	push   %ebx
  80037c:	50                   	push   %eax
  80037d:	ff d6                	call   *%esi
  80037f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800382:	83 c7 01             	add    $0x1,%edi
  800385:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800389:	83 f8 25             	cmp    $0x25,%eax
  80038c:	75 e2                	jne    800370 <vprintfmt+0x14>
  80038e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800392:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800399:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003a0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ac:	eb 07                	jmp    8003b5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8d 47 01             	lea    0x1(%edi),%eax
  8003b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bb:	0f b6 07             	movzbl (%edi),%eax
  8003be:	0f b6 c8             	movzbl %al,%ecx
  8003c1:	83 e8 23             	sub    $0x23,%eax
  8003c4:	3c 55                	cmp    $0x55,%al
  8003c6:	0f 87 5c 03 00 00    	ja     800728 <vprintfmt+0x3cc>
  8003cc:	0f b6 c0             	movzbl %al,%eax
  8003cf:	ff 24 85 e0 0e 80 00 	jmp    *0x800ee0(,%eax,4)
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003dd:	eb d6                	jmp    8003b5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ea:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ed:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f7:	83 fa 09             	cmp    $0x9,%edx
  8003fa:	77 39                	ja     800435 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003fc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ff:	eb e9                	jmp    8003ea <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800401:	8b 45 14             	mov    0x14(%ebp),%eax
  800404:	8d 48 04             	lea    0x4(%eax),%ecx
  800407:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040a:	8b 00                	mov    (%eax),%eax
  80040c:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800412:	eb 27                	jmp    80043b <vprintfmt+0xdf>
  800414:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800417:	85 c0                	test   %eax,%eax
  800419:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041e:	0f 49 c8             	cmovns %eax,%ecx
  800421:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800427:	eb 8c                	jmp    8003b5 <vprintfmt+0x59>
  800429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80042c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800433:	eb 80                	jmp    8003b5 <vprintfmt+0x59>
  800435:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800438:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80043b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043f:	0f 89 70 ff ff ff    	jns    8003b5 <vprintfmt+0x59>
				width = precision, precision = -1;
  800445:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800448:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044b:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800452:	e9 5e ff ff ff       	jmp    8003b5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800457:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045d:	e9 53 ff ff ff       	jmp    8003b5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	8d 50 04             	lea    0x4(%eax),%edx
  800468:	89 55 14             	mov    %edx,0x14(%ebp)
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	53                   	push   %ebx
  80046f:	ff 30                	pushl  (%eax)
  800471:	ff d6                	call   *%esi
			break;
  800473:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800479:	e9 04 ff ff ff       	jmp    800382 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047e:	8b 45 14             	mov    0x14(%ebp),%eax
  800481:	8d 50 04             	lea    0x4(%eax),%edx
  800484:	89 55 14             	mov    %edx,0x14(%ebp)
  800487:	8b 00                	mov    (%eax),%eax
  800489:	99                   	cltd   
  80048a:	31 d0                	xor    %edx,%eax
  80048c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048e:	83 f8 07             	cmp    $0x7,%eax
  800491:	7f 0b                	jg     80049e <vprintfmt+0x142>
  800493:	8b 14 85 40 10 80 00 	mov    0x801040(,%eax,4),%edx
  80049a:	85 d2                	test   %edx,%edx
  80049c:	75 18                	jne    8004b6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049e:	50                   	push   %eax
  80049f:	68 54 0e 80 00       	push   $0x800e54
  8004a4:	53                   	push   %ebx
  8004a5:	56                   	push   %esi
  8004a6:	e8 94 fe ff ff       	call   80033f <printfmt>
  8004ab:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b1:	e9 cc fe ff ff       	jmp    800382 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b6:	52                   	push   %edx
  8004b7:	68 5d 0e 80 00       	push   $0x800e5d
  8004bc:	53                   	push   %ebx
  8004bd:	56                   	push   %esi
  8004be:	e8 7c fe ff ff       	call   80033f <printfmt>
  8004c3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c9:	e9 b4 fe ff ff       	jmp    800382 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d1:	8d 50 04             	lea    0x4(%eax),%edx
  8004d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004d9:	85 ff                	test   %edi,%edi
  8004db:	b8 4d 0e 80 00       	mov    $0x800e4d,%eax
  8004e0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e7:	0f 8e 94 00 00 00    	jle    800581 <vprintfmt+0x225>
  8004ed:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f1:	0f 84 98 00 00 00    	je     80058f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	ff 75 c8             	pushl  -0x38(%ebp)
  8004fd:	57                   	push   %edi
  8004fe:	e8 c8 02 00 00       	call   8007cb <strnlen>
  800503:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800506:	29 c1                	sub    %eax,%ecx
  800508:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80050b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80050e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800512:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800515:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800518:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051a:	eb 0f                	jmp    80052b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	53                   	push   %ebx
  800520:	ff 75 e0             	pushl  -0x20(%ebp)
  800523:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800525:	83 ef 01             	sub    $0x1,%edi
  800528:	83 c4 10             	add    $0x10,%esp
  80052b:	85 ff                	test   %edi,%edi
  80052d:	7f ed                	jg     80051c <vprintfmt+0x1c0>
  80052f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800532:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800535:	85 c9                	test   %ecx,%ecx
  800537:	b8 00 00 00 00       	mov    $0x0,%eax
  80053c:	0f 49 c1             	cmovns %ecx,%eax
  80053f:	29 c1                	sub    %eax,%ecx
  800541:	89 75 08             	mov    %esi,0x8(%ebp)
  800544:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800547:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054a:	89 cb                	mov    %ecx,%ebx
  80054c:	eb 4d                	jmp    80059b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800552:	74 1b                	je     80056f <vprintfmt+0x213>
  800554:	0f be c0             	movsbl %al,%eax
  800557:	83 e8 20             	sub    $0x20,%eax
  80055a:	83 f8 5e             	cmp    $0x5e,%eax
  80055d:	76 10                	jbe    80056f <vprintfmt+0x213>
					putch('?', putdat);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	ff 75 0c             	pushl  0xc(%ebp)
  800565:	6a 3f                	push   $0x3f
  800567:	ff 55 08             	call   *0x8(%ebp)
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	eb 0d                	jmp    80057c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80056f:	83 ec 08             	sub    $0x8,%esp
  800572:	ff 75 0c             	pushl  0xc(%ebp)
  800575:	52                   	push   %edx
  800576:	ff 55 08             	call   *0x8(%ebp)
  800579:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057c:	83 eb 01             	sub    $0x1,%ebx
  80057f:	eb 1a                	jmp    80059b <vprintfmt+0x23f>
  800581:	89 75 08             	mov    %esi,0x8(%ebp)
  800584:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800587:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058d:	eb 0c                	jmp    80059b <vprintfmt+0x23f>
  80058f:	89 75 08             	mov    %esi,0x8(%ebp)
  800592:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800595:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800598:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059b:	83 c7 01             	add    $0x1,%edi
  80059e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a2:	0f be d0             	movsbl %al,%edx
  8005a5:	85 d2                	test   %edx,%edx
  8005a7:	74 23                	je     8005cc <vprintfmt+0x270>
  8005a9:	85 f6                	test   %esi,%esi
  8005ab:	78 a1                	js     80054e <vprintfmt+0x1f2>
  8005ad:	83 ee 01             	sub    $0x1,%esi
  8005b0:	79 9c                	jns    80054e <vprintfmt+0x1f2>
  8005b2:	89 df                	mov    %ebx,%edi
  8005b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ba:	eb 18                	jmp    8005d4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bc:	83 ec 08             	sub    $0x8,%esp
  8005bf:	53                   	push   %ebx
  8005c0:	6a 20                	push   $0x20
  8005c2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c4:	83 ef 01             	sub    $0x1,%edi
  8005c7:	83 c4 10             	add    $0x10,%esp
  8005ca:	eb 08                	jmp    8005d4 <vprintfmt+0x278>
  8005cc:	89 df                	mov    %ebx,%edi
  8005ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d4:	85 ff                	test   %edi,%edi
  8005d6:	7f e4                	jg     8005bc <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005db:	e9 a2 fd ff ff       	jmp    800382 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e0:	83 fa 01             	cmp    $0x1,%edx
  8005e3:	7e 16                	jle    8005fb <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8d 50 08             	lea    0x8(%eax),%edx
  8005eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ee:	8b 50 04             	mov    0x4(%eax),%edx
  8005f1:	8b 00                	mov    (%eax),%eax
  8005f3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005f6:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005f9:	eb 32                	jmp    80062d <vprintfmt+0x2d1>
	else if (lflag)
  8005fb:	85 d2                	test   %edx,%edx
  8005fd:	74 18                	je     800617 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8d 50 04             	lea    0x4(%eax),%edx
  800605:	89 55 14             	mov    %edx,0x14(%ebp)
  800608:	8b 00                	mov    (%eax),%eax
  80060a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80060d:	89 c1                	mov    %eax,%ecx
  80060f:	c1 f9 1f             	sar    $0x1f,%ecx
  800612:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800615:	eb 16                	jmp    80062d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)
  800620:	8b 00                	mov    (%eax),%eax
  800622:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800625:	89 c1                	mov    %eax,%ecx
  800627:	c1 f9 1f             	sar    $0x1f,%ecx
  80062a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800630:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800633:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800636:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800639:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800642:	0f 89 a8 00 00 00    	jns    8006f0 <vprintfmt+0x394>
				putch('-', putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 2d                	push   $0x2d
  80064e:	ff d6                	call   *%esi
				num = -(long long) num;
  800650:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800653:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800656:	f7 d8                	neg    %eax
  800658:	83 d2 00             	adc    $0x0,%edx
  80065b:	f7 da                	neg    %edx
  80065d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800660:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800663:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800666:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066b:	e9 80 00 00 00       	jmp    8006f0 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800670:	8d 45 14             	lea    0x14(%ebp),%eax
  800673:	e8 70 fc ff ff       	call   8002e8 <getuint>
  800678:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80067e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800683:	eb 6b                	jmp    8006f0 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800685:	8d 45 14             	lea    0x14(%ebp),%eax
  800688:	e8 5b fc ff ff       	call   8002e8 <getuint>
  80068d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800690:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800693:	6a 04                	push   $0x4
  800695:	6a 03                	push   $0x3
  800697:	6a 01                	push   $0x1
  800699:	68 60 0e 80 00       	push   $0x800e60
  80069e:	e8 82 fb ff ff       	call   800225 <cprintf>
			goto number;
  8006a3:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  8006a6:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  8006ab:	eb 43                	jmp    8006f0 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	6a 30                	push   $0x30
  8006b3:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b5:	83 c4 08             	add    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	6a 78                	push   $0x78
  8006bb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8d 50 04             	lea    0x4(%eax),%edx
  8006c3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006c6:	8b 00                	mov    (%eax),%eax
  8006c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d0:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006d3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006db:	eb 13                	jmp    8006f0 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e0:	e8 03 fc ff ff       	call   8002e8 <getuint>
  8006e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006eb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f0:	83 ec 0c             	sub    $0xc,%esp
  8006f3:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006f7:	52                   	push   %edx
  8006f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fb:	50                   	push   %eax
  8006fc:	ff 75 dc             	pushl  -0x24(%ebp)
  8006ff:	ff 75 d8             	pushl  -0x28(%ebp)
  800702:	89 da                	mov    %ebx,%edx
  800704:	89 f0                	mov    %esi,%eax
  800706:	e8 2e fb ff ff       	call   800239 <printnum>

			break;
  80070b:	83 c4 20             	add    $0x20,%esp
  80070e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800711:	e9 6c fc ff ff       	jmp    800382 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	53                   	push   %ebx
  80071a:	51                   	push   %ecx
  80071b:	ff d6                	call   *%esi
			break;
  80071d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800720:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800723:	e9 5a fc ff ff       	jmp    800382 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	53                   	push   %ebx
  80072c:	6a 25                	push   $0x25
  80072e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	eb 03                	jmp    800738 <vprintfmt+0x3dc>
  800735:	83 ef 01             	sub    $0x1,%edi
  800738:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80073c:	75 f7                	jne    800735 <vprintfmt+0x3d9>
  80073e:	e9 3f fc ff ff       	jmp    800382 <vprintfmt+0x26>
			break;
		}

	}

}
  800743:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800746:	5b                   	pop    %ebx
  800747:	5e                   	pop    %esi
  800748:	5f                   	pop    %edi
  800749:	5d                   	pop    %ebp
  80074a:	c3                   	ret    

0080074b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	83 ec 18             	sub    $0x18,%esp
  800751:	8b 45 08             	mov    0x8(%ebp),%eax
  800754:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800757:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800761:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800768:	85 c0                	test   %eax,%eax
  80076a:	74 26                	je     800792 <vsnprintf+0x47>
  80076c:	85 d2                	test   %edx,%edx
  80076e:	7e 22                	jle    800792 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800770:	ff 75 14             	pushl  0x14(%ebp)
  800773:	ff 75 10             	pushl  0x10(%ebp)
  800776:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800779:	50                   	push   %eax
  80077a:	68 22 03 80 00       	push   $0x800322
  80077f:	e8 d8 fb ff ff       	call   80035c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800784:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800787:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078d:	83 c4 10             	add    $0x10,%esp
  800790:	eb 05                	jmp    800797 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800792:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a2:	50                   	push   %eax
  8007a3:	ff 75 10             	pushl  0x10(%ebp)
  8007a6:	ff 75 0c             	pushl  0xc(%ebp)
  8007a9:	ff 75 08             	pushl  0x8(%ebp)
  8007ac:	e8 9a ff ff ff       	call   80074b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b1:	c9                   	leave  
  8007b2:	c3                   	ret    

008007b3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007be:	eb 03                	jmp    8007c3 <strlen+0x10>
		n++;
  8007c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c7:	75 f7                	jne    8007c0 <strlen+0xd>
		n++;
	return n;
}
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d9:	eb 03                	jmp    8007de <strnlen+0x13>
		n++;
  8007db:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007de:	39 c2                	cmp    %eax,%edx
  8007e0:	74 08                	je     8007ea <strnlen+0x1f>
  8007e2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007e6:	75 f3                	jne    8007db <strnlen+0x10>
  8007e8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007ea:	5d                   	pop    %ebp
  8007eb:	c3                   	ret    

008007ec <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	53                   	push   %ebx
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f6:	89 c2                	mov    %eax,%edx
  8007f8:	83 c2 01             	add    $0x1,%edx
  8007fb:	83 c1 01             	add    $0x1,%ecx
  8007fe:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800802:	88 5a ff             	mov    %bl,-0x1(%edx)
  800805:	84 db                	test   %bl,%bl
  800807:	75 ef                	jne    8007f8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800809:	5b                   	pop    %ebx
  80080a:	5d                   	pop    %ebp
  80080b:	c3                   	ret    

0080080c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080c:	55                   	push   %ebp
  80080d:	89 e5                	mov    %esp,%ebp
  80080f:	53                   	push   %ebx
  800810:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800813:	53                   	push   %ebx
  800814:	e8 9a ff ff ff       	call   8007b3 <strlen>
  800819:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80081c:	ff 75 0c             	pushl  0xc(%ebp)
  80081f:	01 d8                	add    %ebx,%eax
  800821:	50                   	push   %eax
  800822:	e8 c5 ff ff ff       	call   8007ec <strcpy>
	return dst;
}
  800827:	89 d8                	mov    %ebx,%eax
  800829:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082c:	c9                   	leave  
  80082d:	c3                   	ret    

0080082e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	56                   	push   %esi
  800832:	53                   	push   %ebx
  800833:	8b 75 08             	mov    0x8(%ebp),%esi
  800836:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800839:	89 f3                	mov    %esi,%ebx
  80083b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083e:	89 f2                	mov    %esi,%edx
  800840:	eb 0f                	jmp    800851 <strncpy+0x23>
		*dst++ = *src;
  800842:	83 c2 01             	add    $0x1,%edx
  800845:	0f b6 01             	movzbl (%ecx),%eax
  800848:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084b:	80 39 01             	cmpb   $0x1,(%ecx)
  80084e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800851:	39 da                	cmp    %ebx,%edx
  800853:	75 ed                	jne    800842 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800855:	89 f0                	mov    %esi,%eax
  800857:	5b                   	pop    %ebx
  800858:	5e                   	pop    %esi
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    

0080085b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	56                   	push   %esi
  80085f:	53                   	push   %ebx
  800860:	8b 75 08             	mov    0x8(%ebp),%esi
  800863:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800866:	8b 55 10             	mov    0x10(%ebp),%edx
  800869:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086b:	85 d2                	test   %edx,%edx
  80086d:	74 21                	je     800890 <strlcpy+0x35>
  80086f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800873:	89 f2                	mov    %esi,%edx
  800875:	eb 09                	jmp    800880 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800877:	83 c2 01             	add    $0x1,%edx
  80087a:	83 c1 01             	add    $0x1,%ecx
  80087d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800880:	39 c2                	cmp    %eax,%edx
  800882:	74 09                	je     80088d <strlcpy+0x32>
  800884:	0f b6 19             	movzbl (%ecx),%ebx
  800887:	84 db                	test   %bl,%bl
  800889:	75 ec                	jne    800877 <strlcpy+0x1c>
  80088b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80088d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800890:	29 f0                	sub    %esi,%eax
}
  800892:	5b                   	pop    %ebx
  800893:	5e                   	pop    %esi
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089f:	eb 06                	jmp    8008a7 <strcmp+0x11>
		p++, q++;
  8008a1:	83 c1 01             	add    $0x1,%ecx
  8008a4:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a7:	0f b6 01             	movzbl (%ecx),%eax
  8008aa:	84 c0                	test   %al,%al
  8008ac:	74 04                	je     8008b2 <strcmp+0x1c>
  8008ae:	3a 02                	cmp    (%edx),%al
  8008b0:	74 ef                	je     8008a1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b2:	0f b6 c0             	movzbl %al,%eax
  8008b5:	0f b6 12             	movzbl (%edx),%edx
  8008b8:	29 d0                	sub    %edx,%eax
}
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	53                   	push   %ebx
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c6:	89 c3                	mov    %eax,%ebx
  8008c8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008cb:	eb 06                	jmp    8008d3 <strncmp+0x17>
		n--, p++, q++;
  8008cd:	83 c0 01             	add    $0x1,%eax
  8008d0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d3:	39 d8                	cmp    %ebx,%eax
  8008d5:	74 15                	je     8008ec <strncmp+0x30>
  8008d7:	0f b6 08             	movzbl (%eax),%ecx
  8008da:	84 c9                	test   %cl,%cl
  8008dc:	74 04                	je     8008e2 <strncmp+0x26>
  8008de:	3a 0a                	cmp    (%edx),%cl
  8008e0:	74 eb                	je     8008cd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e2:	0f b6 00             	movzbl (%eax),%eax
  8008e5:	0f b6 12             	movzbl (%edx),%edx
  8008e8:	29 d0                	sub    %edx,%eax
  8008ea:	eb 05                	jmp    8008f1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f1:	5b                   	pop    %ebx
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fe:	eb 07                	jmp    800907 <strchr+0x13>
		if (*s == c)
  800900:	38 ca                	cmp    %cl,%dl
  800902:	74 0f                	je     800913 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800904:	83 c0 01             	add    $0x1,%eax
  800907:	0f b6 10             	movzbl (%eax),%edx
  80090a:	84 d2                	test   %dl,%dl
  80090c:	75 f2                	jne    800900 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80090e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091f:	eb 03                	jmp    800924 <strfind+0xf>
  800921:	83 c0 01             	add    $0x1,%eax
  800924:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800927:	38 ca                	cmp    %cl,%dl
  800929:	74 04                	je     80092f <strfind+0x1a>
  80092b:	84 d2                	test   %dl,%dl
  80092d:	75 f2                	jne    800921 <strfind+0xc>
			break;
	return (char *) s;
}
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	57                   	push   %edi
  800935:	56                   	push   %esi
  800936:	53                   	push   %ebx
  800937:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093d:	85 c9                	test   %ecx,%ecx
  80093f:	74 36                	je     800977 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800941:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800947:	75 28                	jne    800971 <memset+0x40>
  800949:	f6 c1 03             	test   $0x3,%cl
  80094c:	75 23                	jne    800971 <memset+0x40>
		c &= 0xFF;
  80094e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800952:	89 d3                	mov    %edx,%ebx
  800954:	c1 e3 08             	shl    $0x8,%ebx
  800957:	89 d6                	mov    %edx,%esi
  800959:	c1 e6 18             	shl    $0x18,%esi
  80095c:	89 d0                	mov    %edx,%eax
  80095e:	c1 e0 10             	shl    $0x10,%eax
  800961:	09 f0                	or     %esi,%eax
  800963:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800965:	89 d8                	mov    %ebx,%eax
  800967:	09 d0                	or     %edx,%eax
  800969:	c1 e9 02             	shr    $0x2,%ecx
  80096c:	fc                   	cld    
  80096d:	f3 ab                	rep stos %eax,%es:(%edi)
  80096f:	eb 06                	jmp    800977 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800971:	8b 45 0c             	mov    0xc(%ebp),%eax
  800974:	fc                   	cld    
  800975:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800977:	89 f8                	mov    %edi,%eax
  800979:	5b                   	pop    %ebx
  80097a:	5e                   	pop    %esi
  80097b:	5f                   	pop    %edi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	57                   	push   %edi
  800982:	56                   	push   %esi
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8b 75 0c             	mov    0xc(%ebp),%esi
  800989:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098c:	39 c6                	cmp    %eax,%esi
  80098e:	73 35                	jae    8009c5 <memmove+0x47>
  800990:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800993:	39 d0                	cmp    %edx,%eax
  800995:	73 2e                	jae    8009c5 <memmove+0x47>
		s += n;
		d += n;
  800997:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099a:	89 d6                	mov    %edx,%esi
  80099c:	09 fe                	or     %edi,%esi
  80099e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a4:	75 13                	jne    8009b9 <memmove+0x3b>
  8009a6:	f6 c1 03             	test   $0x3,%cl
  8009a9:	75 0e                	jne    8009b9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009ab:	83 ef 04             	sub    $0x4,%edi
  8009ae:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b1:	c1 e9 02             	shr    $0x2,%ecx
  8009b4:	fd                   	std    
  8009b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b7:	eb 09                	jmp    8009c2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b9:	83 ef 01             	sub    $0x1,%edi
  8009bc:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009bf:	fd                   	std    
  8009c0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c2:	fc                   	cld    
  8009c3:	eb 1d                	jmp    8009e2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c5:	89 f2                	mov    %esi,%edx
  8009c7:	09 c2                	or     %eax,%edx
  8009c9:	f6 c2 03             	test   $0x3,%dl
  8009cc:	75 0f                	jne    8009dd <memmove+0x5f>
  8009ce:	f6 c1 03             	test   $0x3,%cl
  8009d1:	75 0a                	jne    8009dd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d3:	c1 e9 02             	shr    $0x2,%ecx
  8009d6:	89 c7                	mov    %eax,%edi
  8009d8:	fc                   	cld    
  8009d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009db:	eb 05                	jmp    8009e2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009dd:	89 c7                	mov    %eax,%edi
  8009df:	fc                   	cld    
  8009e0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e2:	5e                   	pop    %esi
  8009e3:	5f                   	pop    %edi
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e9:	ff 75 10             	pushl  0x10(%ebp)
  8009ec:	ff 75 0c             	pushl  0xc(%ebp)
  8009ef:	ff 75 08             	pushl  0x8(%ebp)
  8009f2:	e8 87 ff ff ff       	call   80097e <memmove>
}
  8009f7:	c9                   	leave  
  8009f8:	c3                   	ret    

008009f9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	56                   	push   %esi
  8009fd:	53                   	push   %ebx
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a04:	89 c6                	mov    %eax,%esi
  800a06:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a09:	eb 1a                	jmp    800a25 <memcmp+0x2c>
		if (*s1 != *s2)
  800a0b:	0f b6 08             	movzbl (%eax),%ecx
  800a0e:	0f b6 1a             	movzbl (%edx),%ebx
  800a11:	38 d9                	cmp    %bl,%cl
  800a13:	74 0a                	je     800a1f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a15:	0f b6 c1             	movzbl %cl,%eax
  800a18:	0f b6 db             	movzbl %bl,%ebx
  800a1b:	29 d8                	sub    %ebx,%eax
  800a1d:	eb 0f                	jmp    800a2e <memcmp+0x35>
		s1++, s2++;
  800a1f:	83 c0 01             	add    $0x1,%eax
  800a22:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a25:	39 f0                	cmp    %esi,%eax
  800a27:	75 e2                	jne    800a0b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2e:	5b                   	pop    %ebx
  800a2f:	5e                   	pop    %esi
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	53                   	push   %ebx
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a39:	89 c1                	mov    %eax,%ecx
  800a3b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a42:	eb 0a                	jmp    800a4e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a44:	0f b6 10             	movzbl (%eax),%edx
  800a47:	39 da                	cmp    %ebx,%edx
  800a49:	74 07                	je     800a52 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4b:	83 c0 01             	add    $0x1,%eax
  800a4e:	39 c8                	cmp    %ecx,%eax
  800a50:	72 f2                	jb     800a44 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a52:	5b                   	pop    %ebx
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	57                   	push   %edi
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a61:	eb 03                	jmp    800a66 <strtol+0x11>
		s++;
  800a63:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a66:	0f b6 01             	movzbl (%ecx),%eax
  800a69:	3c 20                	cmp    $0x20,%al
  800a6b:	74 f6                	je     800a63 <strtol+0xe>
  800a6d:	3c 09                	cmp    $0x9,%al
  800a6f:	74 f2                	je     800a63 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a71:	3c 2b                	cmp    $0x2b,%al
  800a73:	75 0a                	jne    800a7f <strtol+0x2a>
		s++;
  800a75:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a78:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7d:	eb 11                	jmp    800a90 <strtol+0x3b>
  800a7f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a84:	3c 2d                	cmp    $0x2d,%al
  800a86:	75 08                	jne    800a90 <strtol+0x3b>
		s++, neg = 1;
  800a88:	83 c1 01             	add    $0x1,%ecx
  800a8b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a90:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a96:	75 15                	jne    800aad <strtol+0x58>
  800a98:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9b:	75 10                	jne    800aad <strtol+0x58>
  800a9d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa1:	75 7c                	jne    800b1f <strtol+0xca>
		s += 2, base = 16;
  800aa3:	83 c1 02             	add    $0x2,%ecx
  800aa6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aab:	eb 16                	jmp    800ac3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aad:	85 db                	test   %ebx,%ebx
  800aaf:	75 12                	jne    800ac3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab6:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab9:	75 08                	jne    800ac3 <strtol+0x6e>
		s++, base = 8;
  800abb:	83 c1 01             	add    $0x1,%ecx
  800abe:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800acb:	0f b6 11             	movzbl (%ecx),%edx
  800ace:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad1:	89 f3                	mov    %esi,%ebx
  800ad3:	80 fb 09             	cmp    $0x9,%bl
  800ad6:	77 08                	ja     800ae0 <strtol+0x8b>
			dig = *s - '0';
  800ad8:	0f be d2             	movsbl %dl,%edx
  800adb:	83 ea 30             	sub    $0x30,%edx
  800ade:	eb 22                	jmp    800b02 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae3:	89 f3                	mov    %esi,%ebx
  800ae5:	80 fb 19             	cmp    $0x19,%bl
  800ae8:	77 08                	ja     800af2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aea:	0f be d2             	movsbl %dl,%edx
  800aed:	83 ea 57             	sub    $0x57,%edx
  800af0:	eb 10                	jmp    800b02 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af5:	89 f3                	mov    %esi,%ebx
  800af7:	80 fb 19             	cmp    $0x19,%bl
  800afa:	77 16                	ja     800b12 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800afc:	0f be d2             	movsbl %dl,%edx
  800aff:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b02:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b05:	7d 0b                	jge    800b12 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b07:	83 c1 01             	add    $0x1,%ecx
  800b0a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b0e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b10:	eb b9                	jmp    800acb <strtol+0x76>

	if (endptr)
  800b12:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b16:	74 0d                	je     800b25 <strtol+0xd0>
		*endptr = (char *) s;
  800b18:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1b:	89 0e                	mov    %ecx,(%esi)
  800b1d:	eb 06                	jmp    800b25 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b1f:	85 db                	test   %ebx,%ebx
  800b21:	74 98                	je     800abb <strtol+0x66>
  800b23:	eb 9e                	jmp    800ac3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b25:	89 c2                	mov    %eax,%edx
  800b27:	f7 da                	neg    %edx
  800b29:	85 ff                	test   %edi,%edi
  800b2b:	0f 45 c2             	cmovne %edx,%eax
}
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5f                   	pop    %edi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    
  800b33:	66 90                	xchg   %ax,%ax
  800b35:	66 90                	xchg   %ax,%ax
  800b37:	66 90                	xchg   %ax,%ax
  800b39:	66 90                	xchg   %ax,%ax
  800b3b:	66 90                	xchg   %ax,%ax
  800b3d:	66 90                	xchg   %ax,%ax
  800b3f:	90                   	nop

00800b40 <__udivdi3>:
  800b40:	55                   	push   %ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	83 ec 1c             	sub    $0x1c,%esp
  800b47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800b4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800b4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800b53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b57:	85 f6                	test   %esi,%esi
  800b59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b5d:	89 ca                	mov    %ecx,%edx
  800b5f:	89 f8                	mov    %edi,%eax
  800b61:	75 3d                	jne    800ba0 <__udivdi3+0x60>
  800b63:	39 cf                	cmp    %ecx,%edi
  800b65:	0f 87 c5 00 00 00    	ja     800c30 <__udivdi3+0xf0>
  800b6b:	85 ff                	test   %edi,%edi
  800b6d:	89 fd                	mov    %edi,%ebp
  800b6f:	75 0b                	jne    800b7c <__udivdi3+0x3c>
  800b71:	b8 01 00 00 00       	mov    $0x1,%eax
  800b76:	31 d2                	xor    %edx,%edx
  800b78:	f7 f7                	div    %edi
  800b7a:	89 c5                	mov    %eax,%ebp
  800b7c:	89 c8                	mov    %ecx,%eax
  800b7e:	31 d2                	xor    %edx,%edx
  800b80:	f7 f5                	div    %ebp
  800b82:	89 c1                	mov    %eax,%ecx
  800b84:	89 d8                	mov    %ebx,%eax
  800b86:	89 cf                	mov    %ecx,%edi
  800b88:	f7 f5                	div    %ebp
  800b8a:	89 c3                	mov    %eax,%ebx
  800b8c:	89 d8                	mov    %ebx,%eax
  800b8e:	89 fa                	mov    %edi,%edx
  800b90:	83 c4 1c             	add    $0x1c,%esp
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    
  800b98:	90                   	nop
  800b99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ba0:	39 ce                	cmp    %ecx,%esi
  800ba2:	77 74                	ja     800c18 <__udivdi3+0xd8>
  800ba4:	0f bd fe             	bsr    %esi,%edi
  800ba7:	83 f7 1f             	xor    $0x1f,%edi
  800baa:	0f 84 98 00 00 00    	je     800c48 <__udivdi3+0x108>
  800bb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800bb5:	89 f9                	mov    %edi,%ecx
  800bb7:	89 c5                	mov    %eax,%ebp
  800bb9:	29 fb                	sub    %edi,%ebx
  800bbb:	d3 e6                	shl    %cl,%esi
  800bbd:	89 d9                	mov    %ebx,%ecx
  800bbf:	d3 ed                	shr    %cl,%ebp
  800bc1:	89 f9                	mov    %edi,%ecx
  800bc3:	d3 e0                	shl    %cl,%eax
  800bc5:	09 ee                	or     %ebp,%esi
  800bc7:	89 d9                	mov    %ebx,%ecx
  800bc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bcd:	89 d5                	mov    %edx,%ebp
  800bcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800bd3:	d3 ed                	shr    %cl,%ebp
  800bd5:	89 f9                	mov    %edi,%ecx
  800bd7:	d3 e2                	shl    %cl,%edx
  800bd9:	89 d9                	mov    %ebx,%ecx
  800bdb:	d3 e8                	shr    %cl,%eax
  800bdd:	09 c2                	or     %eax,%edx
  800bdf:	89 d0                	mov    %edx,%eax
  800be1:	89 ea                	mov    %ebp,%edx
  800be3:	f7 f6                	div    %esi
  800be5:	89 d5                	mov    %edx,%ebp
  800be7:	89 c3                	mov    %eax,%ebx
  800be9:	f7 64 24 0c          	mull   0xc(%esp)
  800bed:	39 d5                	cmp    %edx,%ebp
  800bef:	72 10                	jb     800c01 <__udivdi3+0xc1>
  800bf1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800bf5:	89 f9                	mov    %edi,%ecx
  800bf7:	d3 e6                	shl    %cl,%esi
  800bf9:	39 c6                	cmp    %eax,%esi
  800bfb:	73 07                	jae    800c04 <__udivdi3+0xc4>
  800bfd:	39 d5                	cmp    %edx,%ebp
  800bff:	75 03                	jne    800c04 <__udivdi3+0xc4>
  800c01:	83 eb 01             	sub    $0x1,%ebx
  800c04:	31 ff                	xor    %edi,%edi
  800c06:	89 d8                	mov    %ebx,%eax
  800c08:	89 fa                	mov    %edi,%edx
  800c0a:	83 c4 1c             	add    $0x1c,%esp
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    
  800c12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c18:	31 ff                	xor    %edi,%edi
  800c1a:	31 db                	xor    %ebx,%ebx
  800c1c:	89 d8                	mov    %ebx,%eax
  800c1e:	89 fa                	mov    %edi,%edx
  800c20:	83 c4 1c             	add    $0x1c,%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    
  800c28:	90                   	nop
  800c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c30:	89 d8                	mov    %ebx,%eax
  800c32:	f7 f7                	div    %edi
  800c34:	31 ff                	xor    %edi,%edi
  800c36:	89 c3                	mov    %eax,%ebx
  800c38:	89 d8                	mov    %ebx,%eax
  800c3a:	89 fa                	mov    %edi,%edx
  800c3c:	83 c4 1c             	add    $0x1c,%esp
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    
  800c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c48:	39 ce                	cmp    %ecx,%esi
  800c4a:	72 0c                	jb     800c58 <__udivdi3+0x118>
  800c4c:	31 db                	xor    %ebx,%ebx
  800c4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800c52:	0f 87 34 ff ff ff    	ja     800b8c <__udivdi3+0x4c>
  800c58:	bb 01 00 00 00       	mov    $0x1,%ebx
  800c5d:	e9 2a ff ff ff       	jmp    800b8c <__udivdi3+0x4c>
  800c62:	66 90                	xchg   %ax,%ax
  800c64:	66 90                	xchg   %ax,%ax
  800c66:	66 90                	xchg   %ax,%ax
  800c68:	66 90                	xchg   %ax,%ax
  800c6a:	66 90                	xchg   %ax,%ax
  800c6c:	66 90                	xchg   %ax,%ax
  800c6e:	66 90                	xchg   %ax,%ax

00800c70 <__umoddi3>:
  800c70:	55                   	push   %ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 1c             	sub    $0x1c,%esp
  800c77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c87:	85 d2                	test   %edx,%edx
  800c89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c91:	89 f3                	mov    %esi,%ebx
  800c93:	89 3c 24             	mov    %edi,(%esp)
  800c96:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c9a:	75 1c                	jne    800cb8 <__umoddi3+0x48>
  800c9c:	39 f7                	cmp    %esi,%edi
  800c9e:	76 50                	jbe    800cf0 <__umoddi3+0x80>
  800ca0:	89 c8                	mov    %ecx,%eax
  800ca2:	89 f2                	mov    %esi,%edx
  800ca4:	f7 f7                	div    %edi
  800ca6:	89 d0                	mov    %edx,%eax
  800ca8:	31 d2                	xor    %edx,%edx
  800caa:	83 c4 1c             	add    $0x1c,%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    
  800cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cb8:	39 f2                	cmp    %esi,%edx
  800cba:	89 d0                	mov    %edx,%eax
  800cbc:	77 52                	ja     800d10 <__umoddi3+0xa0>
  800cbe:	0f bd ea             	bsr    %edx,%ebp
  800cc1:	83 f5 1f             	xor    $0x1f,%ebp
  800cc4:	75 5a                	jne    800d20 <__umoddi3+0xb0>
  800cc6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800cca:	0f 82 e0 00 00 00    	jb     800db0 <__umoddi3+0x140>
  800cd0:	39 0c 24             	cmp    %ecx,(%esp)
  800cd3:	0f 86 d7 00 00 00    	jbe    800db0 <__umoddi3+0x140>
  800cd9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800cdd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ce1:	83 c4 1c             	add    $0x1c,%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    
  800ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cf0:	85 ff                	test   %edi,%edi
  800cf2:	89 fd                	mov    %edi,%ebp
  800cf4:	75 0b                	jne    800d01 <__umoddi3+0x91>
  800cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfb:	31 d2                	xor    %edx,%edx
  800cfd:	f7 f7                	div    %edi
  800cff:	89 c5                	mov    %eax,%ebp
  800d01:	89 f0                	mov    %esi,%eax
  800d03:	31 d2                	xor    %edx,%edx
  800d05:	f7 f5                	div    %ebp
  800d07:	89 c8                	mov    %ecx,%eax
  800d09:	f7 f5                	div    %ebp
  800d0b:	89 d0                	mov    %edx,%eax
  800d0d:	eb 99                	jmp    800ca8 <__umoddi3+0x38>
  800d0f:	90                   	nop
  800d10:	89 c8                	mov    %ecx,%eax
  800d12:	89 f2                	mov    %esi,%edx
  800d14:	83 c4 1c             	add    $0x1c,%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    
  800d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d20:	8b 34 24             	mov    (%esp),%esi
  800d23:	bf 20 00 00 00       	mov    $0x20,%edi
  800d28:	89 e9                	mov    %ebp,%ecx
  800d2a:	29 ef                	sub    %ebp,%edi
  800d2c:	d3 e0                	shl    %cl,%eax
  800d2e:	89 f9                	mov    %edi,%ecx
  800d30:	89 f2                	mov    %esi,%edx
  800d32:	d3 ea                	shr    %cl,%edx
  800d34:	89 e9                	mov    %ebp,%ecx
  800d36:	09 c2                	or     %eax,%edx
  800d38:	89 d8                	mov    %ebx,%eax
  800d3a:	89 14 24             	mov    %edx,(%esp)
  800d3d:	89 f2                	mov    %esi,%edx
  800d3f:	d3 e2                	shl    %cl,%edx
  800d41:	89 f9                	mov    %edi,%ecx
  800d43:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d4b:	d3 e8                	shr    %cl,%eax
  800d4d:	89 e9                	mov    %ebp,%ecx
  800d4f:	89 c6                	mov    %eax,%esi
  800d51:	d3 e3                	shl    %cl,%ebx
  800d53:	89 f9                	mov    %edi,%ecx
  800d55:	89 d0                	mov    %edx,%eax
  800d57:	d3 e8                	shr    %cl,%eax
  800d59:	89 e9                	mov    %ebp,%ecx
  800d5b:	09 d8                	or     %ebx,%eax
  800d5d:	89 d3                	mov    %edx,%ebx
  800d5f:	89 f2                	mov    %esi,%edx
  800d61:	f7 34 24             	divl   (%esp)
  800d64:	89 d6                	mov    %edx,%esi
  800d66:	d3 e3                	shl    %cl,%ebx
  800d68:	f7 64 24 04          	mull   0x4(%esp)
  800d6c:	39 d6                	cmp    %edx,%esi
  800d6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d72:	89 d1                	mov    %edx,%ecx
  800d74:	89 c3                	mov    %eax,%ebx
  800d76:	72 08                	jb     800d80 <__umoddi3+0x110>
  800d78:	75 11                	jne    800d8b <__umoddi3+0x11b>
  800d7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800d7e:	73 0b                	jae    800d8b <__umoddi3+0x11b>
  800d80:	2b 44 24 04          	sub    0x4(%esp),%eax
  800d84:	1b 14 24             	sbb    (%esp),%edx
  800d87:	89 d1                	mov    %edx,%ecx
  800d89:	89 c3                	mov    %eax,%ebx
  800d8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800d8f:	29 da                	sub    %ebx,%edx
  800d91:	19 ce                	sbb    %ecx,%esi
  800d93:	89 f9                	mov    %edi,%ecx
  800d95:	89 f0                	mov    %esi,%eax
  800d97:	d3 e0                	shl    %cl,%eax
  800d99:	89 e9                	mov    %ebp,%ecx
  800d9b:	d3 ea                	shr    %cl,%edx
  800d9d:	89 e9                	mov    %ebp,%ecx
  800d9f:	d3 ee                	shr    %cl,%esi
  800da1:	09 d0                	or     %edx,%eax
  800da3:	89 f2                	mov    %esi,%edx
  800da5:	83 c4 1c             	add    $0x1c,%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    
  800dad:	8d 76 00             	lea    0x0(%esi),%esi
  800db0:	29 f9                	sub    %edi,%ecx
  800db2:	19 d6                	sbb    %edx,%esi
  800db4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800db8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dbc:	e9 18 ff ff ff       	jmp    800cd9 <__umoddi3+0x69>
