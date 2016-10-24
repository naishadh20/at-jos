
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800049:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800050:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  800053:	e8 c9 00 00 00       	call   800121 <sys_getenvid>
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800060:	c1 e0 05             	shl    $0x5,%eax
  800063:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800068:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006d:	85 db                	test   %ebx,%ebx
  80006f:	7e 07                	jle    800078 <libmain+0x3a>
		binaryname = argv[0];
  800071:	8b 06                	mov    (%esi),%eax
  800073:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800078:	83 ec 08             	sub    $0x8,%esp
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	e8 b1 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800082:	e8 0a 00 00 00       	call   800091 <exit>
}
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008d:	5b                   	pop    %ebx
  80008e:	5e                   	pop    %esi
  80008f:	5d                   	pop    %ebp
  800090:	c3                   	ret    

00800091 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800097:	6a 00                	push   $0x0
  800099:	e8 42 00 00 00       	call   8000e0 <sys_env_destroy>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	c9                   	leave  
  8000a2:	c3                   	ret    

008000a3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	57                   	push   %edi
  8000a7:	56                   	push   %esi
  8000a8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b4:	89 c3                	mov    %eax,%ebx
  8000b6:	89 c7                	mov    %eax,%edi
  8000b8:	89 c6                	mov    %eax,%esi
  8000ba:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bc:	5b                   	pop    %ebx
  8000bd:	5e                   	pop    %esi
  8000be:	5f                   	pop    %edi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	57                   	push   %edi
  8000c5:	56                   	push   %esi
  8000c6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d1:	89 d1                	mov    %edx,%ecx
  8000d3:	89 d3                	mov    %edx,%ebx
  8000d5:	89 d7                	mov    %edx,%edi
  8000d7:	89 d6                	mov    %edx,%esi
  8000d9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5f                   	pop    %edi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	57                   	push   %edi
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f6:	89 cb                	mov    %ecx,%ebx
  8000f8:	89 cf                	mov    %ecx,%edi
  8000fa:	89 ce                	mov    %ecx,%esi
  8000fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fe:	85 c0                	test   %eax,%eax
  800100:	7e 17                	jle    800119 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	50                   	push   %eax
  800106:	6a 03                	push   $0x3
  800108:	68 ca 0d 80 00       	push   $0x800dca
  80010d:	6a 23                	push   $0x23
  80010f:	68 e7 0d 80 00       	push   $0x800de7
  800114:	e8 27 00 00 00       	call   800140 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800119:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011c:	5b                   	pop    %ebx
  80011d:	5e                   	pop    %esi
  80011e:	5f                   	pop    %edi
  80011f:	5d                   	pop    %ebp
  800120:	c3                   	ret    

00800121 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	57                   	push   %edi
  800125:	56                   	push   %esi
  800126:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800127:	ba 00 00 00 00       	mov    $0x0,%edx
  80012c:	b8 02 00 00 00       	mov    $0x2,%eax
  800131:	89 d1                	mov    %edx,%ecx
  800133:	89 d3                	mov    %edx,%ebx
  800135:	89 d7                	mov    %edx,%edi
  800137:	89 d6                	mov    %edx,%esi
  800139:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5f                   	pop    %edi
  80013e:	5d                   	pop    %ebp
  80013f:	c3                   	ret    

00800140 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800145:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800148:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80014e:	e8 ce ff ff ff       	call   800121 <sys_getenvid>
  800153:	83 ec 0c             	sub    $0xc,%esp
  800156:	ff 75 0c             	pushl  0xc(%ebp)
  800159:	ff 75 08             	pushl  0x8(%ebp)
  80015c:	56                   	push   %esi
  80015d:	50                   	push   %eax
  80015e:	68 f8 0d 80 00       	push   $0x800df8
  800163:	e8 b1 00 00 00       	call   800219 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800168:	83 c4 18             	add    $0x18,%esp
  80016b:	53                   	push   %ebx
  80016c:	ff 75 10             	pushl  0x10(%ebp)
  80016f:	e8 54 00 00 00       	call   8001c8 <vcprintf>
	cprintf("\n");
  800174:	c7 04 24 50 0e 80 00 	movl   $0x800e50,(%esp)
  80017b:	e8 99 00 00 00       	call   800219 <cprintf>
  800180:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800183:	cc                   	int3   
  800184:	eb fd                	jmp    800183 <_panic+0x43>

00800186 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	53                   	push   %ebx
  80018a:	83 ec 04             	sub    $0x4,%esp
  80018d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800190:	8b 13                	mov    (%ebx),%edx
  800192:	8d 42 01             	lea    0x1(%edx),%eax
  800195:	89 03                	mov    %eax,(%ebx)
  800197:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a3:	75 1a                	jne    8001bf <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	68 ff 00 00 00       	push   $0xff
  8001ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 ed fe ff ff       	call   8000a3 <sys_cputs>
		b->idx = 0;
  8001b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001bc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d8:	00 00 00 
	b.cnt = 0;
  8001db:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e5:	ff 75 0c             	pushl  0xc(%ebp)
  8001e8:	ff 75 08             	pushl  0x8(%ebp)
  8001eb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f1:	50                   	push   %eax
  8001f2:	68 86 01 80 00       	push   $0x800186
  8001f7:	e8 54 01 00 00       	call   800350 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fc:	83 c4 08             	add    $0x8,%esp
  8001ff:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800205:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020b:	50                   	push   %eax
  80020c:	e8 92 fe ff ff       	call   8000a3 <sys_cputs>

	return b.cnt;
}
  800211:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800222:	50                   	push   %eax
  800223:	ff 75 08             	pushl  0x8(%ebp)
  800226:	e8 9d ff ff ff       	call   8001c8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022b:	c9                   	leave  
  80022c:	c3                   	ret    

0080022d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 1c             	sub    $0x1c,%esp
  800236:	89 c7                	mov    %eax,%edi
  800238:	89 d6                	mov    %edx,%esi
  80023a:	8b 45 08             	mov    0x8(%ebp),%eax
  80023d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800240:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800243:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800246:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800251:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800254:	39 d3                	cmp    %edx,%ebx
  800256:	72 05                	jb     80025d <printnum+0x30>
  800258:	39 45 10             	cmp    %eax,0x10(%ebp)
  80025b:	77 45                	ja     8002a2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025d:	83 ec 0c             	sub    $0xc,%esp
  800260:	ff 75 18             	pushl  0x18(%ebp)
  800263:	8b 45 14             	mov    0x14(%ebp),%eax
  800266:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800269:	53                   	push   %ebx
  80026a:	ff 75 10             	pushl  0x10(%ebp)
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	ff 75 e4             	pushl  -0x1c(%ebp)
  800273:	ff 75 e0             	pushl  -0x20(%ebp)
  800276:	ff 75 dc             	pushl  -0x24(%ebp)
  800279:	ff 75 d8             	pushl  -0x28(%ebp)
  80027c:	e8 af 08 00 00       	call   800b30 <__udivdi3>
  800281:	83 c4 18             	add    $0x18,%esp
  800284:	52                   	push   %edx
  800285:	50                   	push   %eax
  800286:	89 f2                	mov    %esi,%edx
  800288:	89 f8                	mov    %edi,%eax
  80028a:	e8 9e ff ff ff       	call   80022d <printnum>
  80028f:	83 c4 20             	add    $0x20,%esp
  800292:	eb 18                	jmp    8002ac <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	56                   	push   %esi
  800298:	ff 75 18             	pushl  0x18(%ebp)
  80029b:	ff d7                	call   *%edi
  80029d:	83 c4 10             	add    $0x10,%esp
  8002a0:	eb 03                	jmp    8002a5 <printnum+0x78>
  8002a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a5:	83 eb 01             	sub    $0x1,%ebx
  8002a8:	85 db                	test   %ebx,%ebx
  8002aa:	7f e8                	jg     800294 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	83 ec 04             	sub    $0x4,%esp
  8002b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002bc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bf:	e8 9c 09 00 00       	call   800c60 <__umoddi3>
  8002c4:	83 c4 14             	add    $0x14,%esp
  8002c7:	0f be 80 1c 0e 80 00 	movsbl 0x800e1c(%eax),%eax
  8002ce:	50                   	push   %eax
  8002cf:	ff d7                	call   *%edi
}
  8002d1:	83 c4 10             	add    $0x10,%esp
  8002d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d7:	5b                   	pop    %ebx
  8002d8:	5e                   	pop    %esi
  8002d9:	5f                   	pop    %edi
  8002da:	5d                   	pop    %ebp
  8002db:	c3                   	ret    

008002dc <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002df:	83 fa 01             	cmp    $0x1,%edx
  8002e2:	7e 0e                	jle    8002f2 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e9:	89 08                	mov    %ecx,(%eax)
  8002eb:	8b 02                	mov    (%edx),%eax
  8002ed:	8b 52 04             	mov    0x4(%edx),%edx
  8002f0:	eb 22                	jmp    800314 <getuint+0x38>
	else if (lflag)
  8002f2:	85 d2                	test   %edx,%edx
  8002f4:	74 10                	je     800306 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f6:	8b 10                	mov    (%eax),%edx
  8002f8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fb:	89 08                	mov    %ecx,(%eax)
  8002fd:	8b 02                	mov    (%edx),%eax
  8002ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800304:	eb 0e                	jmp    800314 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800306:	8b 10                	mov    (%eax),%edx
  800308:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030b:	89 08                	mov    %ecx,(%eax)
  80030d:	8b 02                	mov    (%edx),%eax
  80030f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80031c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800320:	8b 10                	mov    (%eax),%edx
  800322:	3b 50 04             	cmp    0x4(%eax),%edx
  800325:	73 0a                	jae    800331 <sprintputch+0x1b>
		*b->buf++ = ch;
  800327:	8d 4a 01             	lea    0x1(%edx),%ecx
  80032a:	89 08                	mov    %ecx,(%eax)
  80032c:	8b 45 08             	mov    0x8(%ebp),%eax
  80032f:	88 02                	mov    %al,(%edx)
}
  800331:	5d                   	pop    %ebp
  800332:	c3                   	ret    

00800333 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800339:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033c:	50                   	push   %eax
  80033d:	ff 75 10             	pushl  0x10(%ebp)
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	ff 75 08             	pushl  0x8(%ebp)
  800346:	e8 05 00 00 00       	call   800350 <vprintfmt>
	va_end(ap);
}
  80034b:	83 c4 10             	add    $0x10,%esp
  80034e:	c9                   	leave  
  80034f:	c3                   	ret    

00800350 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	57                   	push   %edi
  800354:	56                   	push   %esi
  800355:	53                   	push   %ebx
  800356:	83 ec 2c             	sub    $0x2c,%esp
  800359:	8b 75 08             	mov    0x8(%ebp),%esi
  80035c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800362:	eb 12                	jmp    800376 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800364:	85 c0                	test   %eax,%eax
  800366:	0f 84 cb 03 00 00    	je     800737 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	53                   	push   %ebx
  800370:	50                   	push   %eax
  800371:	ff d6                	call   *%esi
  800373:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800376:	83 c7 01             	add    $0x1,%edi
  800379:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80037d:	83 f8 25             	cmp    $0x25,%eax
  800380:	75 e2                	jne    800364 <vprintfmt+0x14>
  800382:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800386:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80038d:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800394:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80039b:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a0:	eb 07                	jmp    8003a9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8d 47 01             	lea    0x1(%edi),%eax
  8003ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003af:	0f b6 07             	movzbl (%edi),%eax
  8003b2:	0f b6 c8             	movzbl %al,%ecx
  8003b5:	83 e8 23             	sub    $0x23,%eax
  8003b8:	3c 55                	cmp    $0x55,%al
  8003ba:	0f 87 5c 03 00 00    	ja     80071c <vprintfmt+0x3cc>
  8003c0:	0f b6 c0             	movzbl %al,%eax
  8003c3:	ff 24 85 c0 0e 80 00 	jmp    *0x800ec0(,%eax,4)
  8003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003cd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003d1:	eb d6                	jmp    8003a9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003db:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003de:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003e1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003eb:	83 fa 09             	cmp    $0x9,%edx
  8003ee:	77 39                	ja     800429 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f3:	eb e9                	jmp    8003de <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f8:	8d 48 04             	lea    0x4(%eax),%ecx
  8003fb:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003fe:	8b 00                	mov    (%eax),%eax
  800400:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800406:	eb 27                	jmp    80042f <vprintfmt+0xdf>
  800408:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040b:	85 c0                	test   %eax,%eax
  80040d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800412:	0f 49 c8             	cmovns %eax,%ecx
  800415:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041b:	eb 8c                	jmp    8003a9 <vprintfmt+0x59>
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800420:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800427:	eb 80                	jmp    8003a9 <vprintfmt+0x59>
  800429:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80042c:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80042f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800433:	0f 89 70 ff ff ff    	jns    8003a9 <vprintfmt+0x59>
				width = precision, precision = -1;
  800439:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80043c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800446:	e9 5e ff ff ff       	jmp    8003a9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80044b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800451:	e9 53 ff ff ff       	jmp    8003a9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	8d 50 04             	lea    0x4(%eax),%edx
  80045c:	89 55 14             	mov    %edx,0x14(%ebp)
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	53                   	push   %ebx
  800463:	ff 30                	pushl  (%eax)
  800465:	ff d6                	call   *%esi
			break;
  800467:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80046d:	e9 04 ff ff ff       	jmp    800376 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8d 50 04             	lea    0x4(%eax),%edx
  800478:	89 55 14             	mov    %edx,0x14(%ebp)
  80047b:	8b 00                	mov    (%eax),%eax
  80047d:	99                   	cltd   
  80047e:	31 d0                	xor    %edx,%eax
  800480:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800482:	83 f8 07             	cmp    $0x7,%eax
  800485:	7f 0b                	jg     800492 <vprintfmt+0x142>
  800487:	8b 14 85 20 10 80 00 	mov    0x801020(,%eax,4),%edx
  80048e:	85 d2                	test   %edx,%edx
  800490:	75 18                	jne    8004aa <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800492:	50                   	push   %eax
  800493:	68 34 0e 80 00       	push   $0x800e34
  800498:	53                   	push   %ebx
  800499:	56                   	push   %esi
  80049a:	e8 94 fe ff ff       	call   800333 <printfmt>
  80049f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a5:	e9 cc fe ff ff       	jmp    800376 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004aa:	52                   	push   %edx
  8004ab:	68 3d 0e 80 00       	push   $0x800e3d
  8004b0:	53                   	push   %ebx
  8004b1:	56                   	push   %esi
  8004b2:	e8 7c fe ff ff       	call   800333 <printfmt>
  8004b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004bd:	e9 b4 fe ff ff       	jmp    800376 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	8d 50 04             	lea    0x4(%eax),%edx
  8004c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004cd:	85 ff                	test   %edi,%edi
  8004cf:	b8 2d 0e 80 00       	mov    $0x800e2d,%eax
  8004d4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004db:	0f 8e 94 00 00 00    	jle    800575 <vprintfmt+0x225>
  8004e1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e5:	0f 84 98 00 00 00    	je     800583 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	ff 75 c8             	pushl  -0x38(%ebp)
  8004f1:	57                   	push   %edi
  8004f2:	e8 c8 02 00 00       	call   8007bf <strnlen>
  8004f7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004fa:	29 c1                	sub    %eax,%ecx
  8004fc:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004ff:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800502:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800506:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800509:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80050c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050e:	eb 0f                	jmp    80051f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	53                   	push   %ebx
  800514:	ff 75 e0             	pushl  -0x20(%ebp)
  800517:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800519:	83 ef 01             	sub    $0x1,%edi
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	85 ff                	test   %edi,%edi
  800521:	7f ed                	jg     800510 <vprintfmt+0x1c0>
  800523:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800526:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800529:	85 c9                	test   %ecx,%ecx
  80052b:	b8 00 00 00 00       	mov    $0x0,%eax
  800530:	0f 49 c1             	cmovns %ecx,%eax
  800533:	29 c1                	sub    %eax,%ecx
  800535:	89 75 08             	mov    %esi,0x8(%ebp)
  800538:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80053b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053e:	89 cb                	mov    %ecx,%ebx
  800540:	eb 4d                	jmp    80058f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800542:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800546:	74 1b                	je     800563 <vprintfmt+0x213>
  800548:	0f be c0             	movsbl %al,%eax
  80054b:	83 e8 20             	sub    $0x20,%eax
  80054e:	83 f8 5e             	cmp    $0x5e,%eax
  800551:	76 10                	jbe    800563 <vprintfmt+0x213>
					putch('?', putdat);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	ff 75 0c             	pushl  0xc(%ebp)
  800559:	6a 3f                	push   $0x3f
  80055b:	ff 55 08             	call   *0x8(%ebp)
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	eb 0d                	jmp    800570 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	ff 75 0c             	pushl  0xc(%ebp)
  800569:	52                   	push   %edx
  80056a:	ff 55 08             	call   *0x8(%ebp)
  80056d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800570:	83 eb 01             	sub    $0x1,%ebx
  800573:	eb 1a                	jmp    80058f <vprintfmt+0x23f>
  800575:	89 75 08             	mov    %esi,0x8(%ebp)
  800578:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80057b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800581:	eb 0c                	jmp    80058f <vprintfmt+0x23f>
  800583:	89 75 08             	mov    %esi,0x8(%ebp)
  800586:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800589:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058f:	83 c7 01             	add    $0x1,%edi
  800592:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800596:	0f be d0             	movsbl %al,%edx
  800599:	85 d2                	test   %edx,%edx
  80059b:	74 23                	je     8005c0 <vprintfmt+0x270>
  80059d:	85 f6                	test   %esi,%esi
  80059f:	78 a1                	js     800542 <vprintfmt+0x1f2>
  8005a1:	83 ee 01             	sub    $0x1,%esi
  8005a4:	79 9c                	jns    800542 <vprintfmt+0x1f2>
  8005a6:	89 df                	mov    %ebx,%edi
  8005a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ae:	eb 18                	jmp    8005c8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b0:	83 ec 08             	sub    $0x8,%esp
  8005b3:	53                   	push   %ebx
  8005b4:	6a 20                	push   $0x20
  8005b6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b8:	83 ef 01             	sub    $0x1,%edi
  8005bb:	83 c4 10             	add    $0x10,%esp
  8005be:	eb 08                	jmp    8005c8 <vprintfmt+0x278>
  8005c0:	89 df                	mov    %ebx,%edi
  8005c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c8:	85 ff                	test   %edi,%edi
  8005ca:	7f e4                	jg     8005b0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005cf:	e9 a2 fd ff ff       	jmp    800376 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d4:	83 fa 01             	cmp    $0x1,%edx
  8005d7:	7e 16                	jle    8005ef <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8d 50 08             	lea    0x8(%eax),%edx
  8005df:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e2:	8b 50 04             	mov    0x4(%eax),%edx
  8005e5:	8b 00                	mov    (%eax),%eax
  8005e7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005ea:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005ed:	eb 32                	jmp    800621 <vprintfmt+0x2d1>
	else if (lflag)
  8005ef:	85 d2                	test   %edx,%edx
  8005f1:	74 18                	je     80060b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 50 04             	lea    0x4(%eax),%edx
  8005f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fc:	8b 00                	mov    (%eax),%eax
  8005fe:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800601:	89 c1                	mov    %eax,%ecx
  800603:	c1 f9 1f             	sar    $0x1f,%ecx
  800606:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800609:	eb 16                	jmp    800621 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 50 04             	lea    0x4(%eax),%edx
  800611:	89 55 14             	mov    %edx,0x14(%ebp)
  800614:	8b 00                	mov    (%eax),%eax
  800616:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800619:	89 c1                	mov    %eax,%ecx
  80061b:	c1 f9 1f             	sar    $0x1f,%ecx
  80061e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800621:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800624:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800627:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80062d:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800632:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800636:	0f 89 a8 00 00 00    	jns    8006e4 <vprintfmt+0x394>
				putch('-', putdat);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	6a 2d                	push   $0x2d
  800642:	ff d6                	call   *%esi
				num = -(long long) num;
  800644:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800647:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80064a:	f7 d8                	neg    %eax
  80064c:	83 d2 00             	adc    $0x0,%edx
  80064f:	f7 da                	neg    %edx
  800651:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800654:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800657:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80065a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065f:	e9 80 00 00 00       	jmp    8006e4 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800664:	8d 45 14             	lea    0x14(%ebp),%eax
  800667:	e8 70 fc ff ff       	call   8002dc <getuint>
  80066c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800672:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800677:	eb 6b                	jmp    8006e4 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800679:	8d 45 14             	lea    0x14(%ebp),%eax
  80067c:	e8 5b fc ff ff       	call   8002dc <getuint>
  800681:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800684:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800687:	6a 04                	push   $0x4
  800689:	6a 03                	push   $0x3
  80068b:	6a 01                	push   $0x1
  80068d:	68 40 0e 80 00       	push   $0x800e40
  800692:	e8 82 fb ff ff       	call   800219 <cprintf>
			goto number;
  800697:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  80069a:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  80069f:	eb 43                	jmp    8006e4 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	53                   	push   %ebx
  8006a5:	6a 30                	push   $0x30
  8006a7:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a9:	83 c4 08             	add    $0x8,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	6a 78                	push   $0x78
  8006af:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8d 50 04             	lea    0x4(%eax),%edx
  8006b7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ba:	8b 00                	mov    (%eax),%eax
  8006bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ca:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006cf:	eb 13                	jmp    8006e4 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d4:	e8 03 fc ff ff       	call   8002dc <getuint>
  8006d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006df:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e4:	83 ec 0c             	sub    $0xc,%esp
  8006e7:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006eb:	52                   	push   %edx
  8006ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ef:	50                   	push   %eax
  8006f0:	ff 75 dc             	pushl  -0x24(%ebp)
  8006f3:	ff 75 d8             	pushl  -0x28(%ebp)
  8006f6:	89 da                	mov    %ebx,%edx
  8006f8:	89 f0                	mov    %esi,%eax
  8006fa:	e8 2e fb ff ff       	call   80022d <printnum>

			break;
  8006ff:	83 c4 20             	add    $0x20,%esp
  800702:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800705:	e9 6c fc ff ff       	jmp    800376 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	53                   	push   %ebx
  80070e:	51                   	push   %ecx
  80070f:	ff d6                	call   *%esi
			break;
  800711:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800714:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800717:	e9 5a fc ff ff       	jmp    800376 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	6a 25                	push   $0x25
  800722:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	eb 03                	jmp    80072c <vprintfmt+0x3dc>
  800729:	83 ef 01             	sub    $0x1,%edi
  80072c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800730:	75 f7                	jne    800729 <vprintfmt+0x3d9>
  800732:	e9 3f fc ff ff       	jmp    800376 <vprintfmt+0x26>
			break;
		}

	}

}
  800737:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80073a:	5b                   	pop    %ebx
  80073b:	5e                   	pop    %esi
  80073c:	5f                   	pop    %edi
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	83 ec 18             	sub    $0x18,%esp
  800745:	8b 45 08             	mov    0x8(%ebp),%eax
  800748:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800752:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800755:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075c:	85 c0                	test   %eax,%eax
  80075e:	74 26                	je     800786 <vsnprintf+0x47>
  800760:	85 d2                	test   %edx,%edx
  800762:	7e 22                	jle    800786 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800764:	ff 75 14             	pushl  0x14(%ebp)
  800767:	ff 75 10             	pushl  0x10(%ebp)
  80076a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076d:	50                   	push   %eax
  80076e:	68 16 03 80 00       	push   $0x800316
  800773:	e8 d8 fb ff ff       	call   800350 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800778:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	eb 05                	jmp    80078b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800786:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800793:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800796:	50                   	push   %eax
  800797:	ff 75 10             	pushl  0x10(%ebp)
  80079a:	ff 75 0c             	pushl  0xc(%ebp)
  80079d:	ff 75 08             	pushl  0x8(%ebp)
  8007a0:	e8 9a ff ff ff       	call   80073f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a5:	c9                   	leave  
  8007a6:	c3                   	ret    

008007a7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b2:	eb 03                	jmp    8007b7 <strlen+0x10>
		n++;
  8007b4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007bb:	75 f7                	jne    8007b4 <strlen+0xd>
		n++;
	return n;
}
  8007bd:	5d                   	pop    %ebp
  8007be:	c3                   	ret    

008007bf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007cd:	eb 03                	jmp    8007d2 <strnlen+0x13>
		n++;
  8007cf:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d2:	39 c2                	cmp    %eax,%edx
  8007d4:	74 08                	je     8007de <strnlen+0x1f>
  8007d6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007da:	75 f3                	jne    8007cf <strnlen+0x10>
  8007dc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	53                   	push   %ebx
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ea:	89 c2                	mov    %eax,%edx
  8007ec:	83 c2 01             	add    $0x1,%edx
  8007ef:	83 c1 01             	add    $0x1,%ecx
  8007f2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007f6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f9:	84 db                	test   %bl,%bl
  8007fb:	75 ef                	jne    8007ec <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007fd:	5b                   	pop    %ebx
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	53                   	push   %ebx
  800804:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800807:	53                   	push   %ebx
  800808:	e8 9a ff ff ff       	call   8007a7 <strlen>
  80080d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800810:	ff 75 0c             	pushl  0xc(%ebp)
  800813:	01 d8                	add    %ebx,%eax
  800815:	50                   	push   %eax
  800816:	e8 c5 ff ff ff       	call   8007e0 <strcpy>
	return dst;
}
  80081b:	89 d8                	mov    %ebx,%eax
  80081d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800820:	c9                   	leave  
  800821:	c3                   	ret    

00800822 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800822:	55                   	push   %ebp
  800823:	89 e5                	mov    %esp,%ebp
  800825:	56                   	push   %esi
  800826:	53                   	push   %ebx
  800827:	8b 75 08             	mov    0x8(%ebp),%esi
  80082a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082d:	89 f3                	mov    %esi,%ebx
  80082f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800832:	89 f2                	mov    %esi,%edx
  800834:	eb 0f                	jmp    800845 <strncpy+0x23>
		*dst++ = *src;
  800836:	83 c2 01             	add    $0x1,%edx
  800839:	0f b6 01             	movzbl (%ecx),%eax
  80083c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083f:	80 39 01             	cmpb   $0x1,(%ecx)
  800842:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800845:	39 da                	cmp    %ebx,%edx
  800847:	75 ed                	jne    800836 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800849:	89 f0                	mov    %esi,%eax
  80084b:	5b                   	pop    %ebx
  80084c:	5e                   	pop    %esi
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	56                   	push   %esi
  800853:	53                   	push   %ebx
  800854:	8b 75 08             	mov    0x8(%ebp),%esi
  800857:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085a:	8b 55 10             	mov    0x10(%ebp),%edx
  80085d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085f:	85 d2                	test   %edx,%edx
  800861:	74 21                	je     800884 <strlcpy+0x35>
  800863:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800867:	89 f2                	mov    %esi,%edx
  800869:	eb 09                	jmp    800874 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80086b:	83 c2 01             	add    $0x1,%edx
  80086e:	83 c1 01             	add    $0x1,%ecx
  800871:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800874:	39 c2                	cmp    %eax,%edx
  800876:	74 09                	je     800881 <strlcpy+0x32>
  800878:	0f b6 19             	movzbl (%ecx),%ebx
  80087b:	84 db                	test   %bl,%bl
  80087d:	75 ec                	jne    80086b <strlcpy+0x1c>
  80087f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800881:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800884:	29 f0                	sub    %esi,%eax
}
  800886:	5b                   	pop    %ebx
  800887:	5e                   	pop    %esi
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800893:	eb 06                	jmp    80089b <strcmp+0x11>
		p++, q++;
  800895:	83 c1 01             	add    $0x1,%ecx
  800898:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80089b:	0f b6 01             	movzbl (%ecx),%eax
  80089e:	84 c0                	test   %al,%al
  8008a0:	74 04                	je     8008a6 <strcmp+0x1c>
  8008a2:	3a 02                	cmp    (%edx),%al
  8008a4:	74 ef                	je     800895 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a6:	0f b6 c0             	movzbl %al,%eax
  8008a9:	0f b6 12             	movzbl (%edx),%edx
  8008ac:	29 d0                	sub    %edx,%eax
}
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	53                   	push   %ebx
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ba:	89 c3                	mov    %eax,%ebx
  8008bc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008bf:	eb 06                	jmp    8008c7 <strncmp+0x17>
		n--, p++, q++;
  8008c1:	83 c0 01             	add    $0x1,%eax
  8008c4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c7:	39 d8                	cmp    %ebx,%eax
  8008c9:	74 15                	je     8008e0 <strncmp+0x30>
  8008cb:	0f b6 08             	movzbl (%eax),%ecx
  8008ce:	84 c9                	test   %cl,%cl
  8008d0:	74 04                	je     8008d6 <strncmp+0x26>
  8008d2:	3a 0a                	cmp    (%edx),%cl
  8008d4:	74 eb                	je     8008c1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d6:	0f b6 00             	movzbl (%eax),%eax
  8008d9:	0f b6 12             	movzbl (%edx),%edx
  8008dc:	29 d0                	sub    %edx,%eax
  8008de:	eb 05                	jmp    8008e5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e5:	5b                   	pop    %ebx
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f2:	eb 07                	jmp    8008fb <strchr+0x13>
		if (*s == c)
  8008f4:	38 ca                	cmp    %cl,%dl
  8008f6:	74 0f                	je     800907 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f8:	83 c0 01             	add    $0x1,%eax
  8008fb:	0f b6 10             	movzbl (%eax),%edx
  8008fe:	84 d2                	test   %dl,%dl
  800900:	75 f2                	jne    8008f4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800913:	eb 03                	jmp    800918 <strfind+0xf>
  800915:	83 c0 01             	add    $0x1,%eax
  800918:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80091b:	38 ca                	cmp    %cl,%dl
  80091d:	74 04                	je     800923 <strfind+0x1a>
  80091f:	84 d2                	test   %dl,%dl
  800921:	75 f2                	jne    800915 <strfind+0xc>
			break;
	return (char *) s;
}
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	57                   	push   %edi
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800931:	85 c9                	test   %ecx,%ecx
  800933:	74 36                	je     80096b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800935:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093b:	75 28                	jne    800965 <memset+0x40>
  80093d:	f6 c1 03             	test   $0x3,%cl
  800940:	75 23                	jne    800965 <memset+0x40>
		c &= 0xFF;
  800942:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800946:	89 d3                	mov    %edx,%ebx
  800948:	c1 e3 08             	shl    $0x8,%ebx
  80094b:	89 d6                	mov    %edx,%esi
  80094d:	c1 e6 18             	shl    $0x18,%esi
  800950:	89 d0                	mov    %edx,%eax
  800952:	c1 e0 10             	shl    $0x10,%eax
  800955:	09 f0                	or     %esi,%eax
  800957:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800959:	89 d8                	mov    %ebx,%eax
  80095b:	09 d0                	or     %edx,%eax
  80095d:	c1 e9 02             	shr    $0x2,%ecx
  800960:	fc                   	cld    
  800961:	f3 ab                	rep stos %eax,%es:(%edi)
  800963:	eb 06                	jmp    80096b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800965:	8b 45 0c             	mov    0xc(%ebp),%eax
  800968:	fc                   	cld    
  800969:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096b:	89 f8                	mov    %edi,%eax
  80096d:	5b                   	pop    %ebx
  80096e:	5e                   	pop    %esi
  80096f:	5f                   	pop    %edi
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	57                   	push   %edi
  800976:	56                   	push   %esi
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
  80097a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800980:	39 c6                	cmp    %eax,%esi
  800982:	73 35                	jae    8009b9 <memmove+0x47>
  800984:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800987:	39 d0                	cmp    %edx,%eax
  800989:	73 2e                	jae    8009b9 <memmove+0x47>
		s += n;
		d += n;
  80098b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098e:	89 d6                	mov    %edx,%esi
  800990:	09 fe                	or     %edi,%esi
  800992:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800998:	75 13                	jne    8009ad <memmove+0x3b>
  80099a:	f6 c1 03             	test   $0x3,%cl
  80099d:	75 0e                	jne    8009ad <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80099f:	83 ef 04             	sub    $0x4,%edi
  8009a2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a5:	c1 e9 02             	shr    $0x2,%ecx
  8009a8:	fd                   	std    
  8009a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ab:	eb 09                	jmp    8009b6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ad:	83 ef 01             	sub    $0x1,%edi
  8009b0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009b3:	fd                   	std    
  8009b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b6:	fc                   	cld    
  8009b7:	eb 1d                	jmp    8009d6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b9:	89 f2                	mov    %esi,%edx
  8009bb:	09 c2                	or     %eax,%edx
  8009bd:	f6 c2 03             	test   $0x3,%dl
  8009c0:	75 0f                	jne    8009d1 <memmove+0x5f>
  8009c2:	f6 c1 03             	test   $0x3,%cl
  8009c5:	75 0a                	jne    8009d1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009c7:	c1 e9 02             	shr    $0x2,%ecx
  8009ca:	89 c7                	mov    %eax,%edi
  8009cc:	fc                   	cld    
  8009cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cf:	eb 05                	jmp    8009d6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d1:	89 c7                	mov    %eax,%edi
  8009d3:	fc                   	cld    
  8009d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d6:	5e                   	pop    %esi
  8009d7:	5f                   	pop    %edi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009dd:	ff 75 10             	pushl  0x10(%ebp)
  8009e0:	ff 75 0c             	pushl  0xc(%ebp)
  8009e3:	ff 75 08             	pushl  0x8(%ebp)
  8009e6:	e8 87 ff ff ff       	call   800972 <memmove>
}
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    

008009ed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f8:	89 c6                	mov    %eax,%esi
  8009fa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fd:	eb 1a                	jmp    800a19 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ff:	0f b6 08             	movzbl (%eax),%ecx
  800a02:	0f b6 1a             	movzbl (%edx),%ebx
  800a05:	38 d9                	cmp    %bl,%cl
  800a07:	74 0a                	je     800a13 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a09:	0f b6 c1             	movzbl %cl,%eax
  800a0c:	0f b6 db             	movzbl %bl,%ebx
  800a0f:	29 d8                	sub    %ebx,%eax
  800a11:	eb 0f                	jmp    800a22 <memcmp+0x35>
		s1++, s2++;
  800a13:	83 c0 01             	add    $0x1,%eax
  800a16:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a19:	39 f0                	cmp    %esi,%eax
  800a1b:	75 e2                	jne    8009ff <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a22:	5b                   	pop    %ebx
  800a23:	5e                   	pop    %esi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	53                   	push   %ebx
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a2d:	89 c1                	mov    %eax,%ecx
  800a2f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a32:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a36:	eb 0a                	jmp    800a42 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a38:	0f b6 10             	movzbl (%eax),%edx
  800a3b:	39 da                	cmp    %ebx,%edx
  800a3d:	74 07                	je     800a46 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3f:	83 c0 01             	add    $0x1,%eax
  800a42:	39 c8                	cmp    %ecx,%eax
  800a44:	72 f2                	jb     800a38 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a46:	5b                   	pop    %ebx
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	57                   	push   %edi
  800a4d:	56                   	push   %esi
  800a4e:	53                   	push   %ebx
  800a4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a55:	eb 03                	jmp    800a5a <strtol+0x11>
		s++;
  800a57:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5a:	0f b6 01             	movzbl (%ecx),%eax
  800a5d:	3c 20                	cmp    $0x20,%al
  800a5f:	74 f6                	je     800a57 <strtol+0xe>
  800a61:	3c 09                	cmp    $0x9,%al
  800a63:	74 f2                	je     800a57 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a65:	3c 2b                	cmp    $0x2b,%al
  800a67:	75 0a                	jne    800a73 <strtol+0x2a>
		s++;
  800a69:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a6c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a71:	eb 11                	jmp    800a84 <strtol+0x3b>
  800a73:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a78:	3c 2d                	cmp    $0x2d,%al
  800a7a:	75 08                	jne    800a84 <strtol+0x3b>
		s++, neg = 1;
  800a7c:	83 c1 01             	add    $0x1,%ecx
  800a7f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a84:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a8a:	75 15                	jne    800aa1 <strtol+0x58>
  800a8c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8f:	75 10                	jne    800aa1 <strtol+0x58>
  800a91:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a95:	75 7c                	jne    800b13 <strtol+0xca>
		s += 2, base = 16;
  800a97:	83 c1 02             	add    $0x2,%ecx
  800a9a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9f:	eb 16                	jmp    800ab7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aa1:	85 db                	test   %ebx,%ebx
  800aa3:	75 12                	jne    800ab7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aaa:	80 39 30             	cmpb   $0x30,(%ecx)
  800aad:	75 08                	jne    800ab7 <strtol+0x6e>
		s++, base = 8;
  800aaf:	83 c1 01             	add    $0x1,%ecx
  800ab2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ab7:	b8 00 00 00 00       	mov    $0x0,%eax
  800abc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800abf:	0f b6 11             	movzbl (%ecx),%edx
  800ac2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ac5:	89 f3                	mov    %esi,%ebx
  800ac7:	80 fb 09             	cmp    $0x9,%bl
  800aca:	77 08                	ja     800ad4 <strtol+0x8b>
			dig = *s - '0';
  800acc:	0f be d2             	movsbl %dl,%edx
  800acf:	83 ea 30             	sub    $0x30,%edx
  800ad2:	eb 22                	jmp    800af6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ad4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad7:	89 f3                	mov    %esi,%ebx
  800ad9:	80 fb 19             	cmp    $0x19,%bl
  800adc:	77 08                	ja     800ae6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ade:	0f be d2             	movsbl %dl,%edx
  800ae1:	83 ea 57             	sub    $0x57,%edx
  800ae4:	eb 10                	jmp    800af6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ae6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae9:	89 f3                	mov    %esi,%ebx
  800aeb:	80 fb 19             	cmp    $0x19,%bl
  800aee:	77 16                	ja     800b06 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800af0:	0f be d2             	movsbl %dl,%edx
  800af3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800af6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af9:	7d 0b                	jge    800b06 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800afb:	83 c1 01             	add    $0x1,%ecx
  800afe:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b02:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b04:	eb b9                	jmp    800abf <strtol+0x76>

	if (endptr)
  800b06:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0a:	74 0d                	je     800b19 <strtol+0xd0>
		*endptr = (char *) s;
  800b0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0f:	89 0e                	mov    %ecx,(%esi)
  800b11:	eb 06                	jmp    800b19 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b13:	85 db                	test   %ebx,%ebx
  800b15:	74 98                	je     800aaf <strtol+0x66>
  800b17:	eb 9e                	jmp    800ab7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b19:	89 c2                	mov    %eax,%edx
  800b1b:	f7 da                	neg    %edx
  800b1d:	85 ff                	test   %edi,%edi
  800b1f:	0f 45 c2             	cmovne %edx,%eax
}
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5f                   	pop    %edi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    
  800b27:	66 90                	xchg   %ax,%ax
  800b29:	66 90                	xchg   %ax,%ax
  800b2b:	66 90                	xchg   %ax,%ax
  800b2d:	66 90                	xchg   %ax,%ax
  800b2f:	90                   	nop

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
