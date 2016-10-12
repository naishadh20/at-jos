
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	83 ec 08             	sub    $0x8,%esp
  80003f:	8b 45 08             	mov    0x8(%ebp),%eax
  800042:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800045:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80004c:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80004f:	85 c0                	test   %eax,%eax
  800051:	7e 08                	jle    80005b <libmain+0x22>
		binaryname = argv[0];
  800053:	8b 0a                	mov    (%edx),%ecx
  800055:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80005b:	83 ec 08             	sub    $0x8,%esp
  80005e:	52                   	push   %edx
  80005f:	50                   	push   %eax
  800060:	e8 ce ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800065:	e8 05 00 00 00       	call   80006f <exit>
}
  80006a:	83 c4 10             	add    $0x10,%esp
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800075:	6a 00                	push   $0x0
  800077:	e8 42 00 00 00       	call   8000be <sys_env_destroy>
}
  80007c:	83 c4 10             	add    $0x10,%esp
  80007f:	c9                   	leave  
  800080:	c3                   	ret    

00800081 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800081:	55                   	push   %ebp
  800082:	89 e5                	mov    %esp,%ebp
  800084:	57                   	push   %edi
  800085:	56                   	push   %esi
  800086:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
  80008c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80008f:	8b 55 08             	mov    0x8(%ebp),%edx
  800092:	89 c3                	mov    %eax,%ebx
  800094:	89 c7                	mov    %eax,%edi
  800096:	89 c6                	mov    %eax,%esi
  800098:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80009a:	5b                   	pop    %ebx
  80009b:	5e                   	pop    %esi
  80009c:	5f                   	pop    %edi
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    

0080009f <sys_cgetc>:

int
sys_cgetc(void)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	57                   	push   %edi
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8000af:	89 d1                	mov    %edx,%ecx
  8000b1:	89 d3                	mov    %edx,%ebx
  8000b3:	89 d7                	mov    %edx,%edi
  8000b5:	89 d6                	mov    %edx,%esi
  8000b7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000cc:	b8 03 00 00 00       	mov    $0x3,%eax
  8000d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d4:	89 cb                	mov    %ecx,%ebx
  8000d6:	89 cf                	mov    %ecx,%edi
  8000d8:	89 ce                	mov    %ecx,%esi
  8000da:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	7e 17                	jle    8000f7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e0:	83 ec 0c             	sub    $0xc,%esp
  8000e3:	50                   	push   %eax
  8000e4:	6a 03                	push   $0x3
  8000e6:	68 aa 0d 80 00       	push   $0x800daa
  8000eb:	6a 23                	push   $0x23
  8000ed:	68 c7 0d 80 00       	push   $0x800dc7
  8000f2:	e8 27 00 00 00       	call   80011e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5f                   	pop    %edi
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	57                   	push   %edi
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800105:	ba 00 00 00 00       	mov    $0x0,%edx
  80010a:	b8 02 00 00 00       	mov    $0x2,%eax
  80010f:	89 d1                	mov    %edx,%ecx
  800111:	89 d3                	mov    %edx,%ebx
  800113:	89 d7                	mov    %edx,%edi
  800115:	89 d6                	mov    %edx,%esi
  800117:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800119:	5b                   	pop    %ebx
  80011a:	5e                   	pop    %esi
  80011b:	5f                   	pop    %edi
  80011c:	5d                   	pop    %ebp
  80011d:	c3                   	ret    

0080011e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800123:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800126:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80012c:	e8 ce ff ff ff       	call   8000ff <sys_getenvid>
  800131:	83 ec 0c             	sub    $0xc,%esp
  800134:	ff 75 0c             	pushl  0xc(%ebp)
  800137:	ff 75 08             	pushl  0x8(%ebp)
  80013a:	56                   	push   %esi
  80013b:	50                   	push   %eax
  80013c:	68 d8 0d 80 00       	push   $0x800dd8
  800141:	e8 b1 00 00 00       	call   8001f7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800146:	83 c4 18             	add    $0x18,%esp
  800149:	53                   	push   %ebx
  80014a:	ff 75 10             	pushl  0x10(%ebp)
  80014d:	e8 54 00 00 00       	call   8001a6 <vcprintf>
	cprintf("\n");
  800152:	c7 04 24 30 0e 80 00 	movl   $0x800e30,(%esp)
  800159:	e8 99 00 00 00       	call   8001f7 <cprintf>
  80015e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800161:	cc                   	int3   
  800162:	eb fd                	jmp    800161 <_panic+0x43>

00800164 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	53                   	push   %ebx
  800168:	83 ec 04             	sub    $0x4,%esp
  80016b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016e:	8b 13                	mov    (%ebx),%edx
  800170:	8d 42 01             	lea    0x1(%edx),%eax
  800173:	89 03                	mov    %eax,(%ebx)
  800175:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800178:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800181:	75 1a                	jne    80019d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800183:	83 ec 08             	sub    $0x8,%esp
  800186:	68 ff 00 00 00       	push   $0xff
  80018b:	8d 43 08             	lea    0x8(%ebx),%eax
  80018e:	50                   	push   %eax
  80018f:	e8 ed fe ff ff       	call   800081 <sys_cputs>
		b->idx = 0;
  800194:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80019d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a4:	c9                   	leave  
  8001a5:	c3                   	ret    

008001a6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001af:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b6:	00 00 00 
	b.cnt = 0;
  8001b9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c3:	ff 75 0c             	pushl  0xc(%ebp)
  8001c6:	ff 75 08             	pushl  0x8(%ebp)
  8001c9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cf:	50                   	push   %eax
  8001d0:	68 64 01 80 00       	push   $0x800164
  8001d5:	e8 54 01 00 00       	call   80032e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001da:	83 c4 08             	add    $0x8,%esp
  8001dd:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e9:	50                   	push   %eax
  8001ea:	e8 92 fe ff ff       	call   800081 <sys_cputs>

	return b.cnt;
}
  8001ef:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f5:	c9                   	leave  
  8001f6:	c3                   	ret    

008001f7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800200:	50                   	push   %eax
  800201:	ff 75 08             	pushl  0x8(%ebp)
  800204:	e8 9d ff ff ff       	call   8001a6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	57                   	push   %edi
  80020f:	56                   	push   %esi
  800210:	53                   	push   %ebx
  800211:	83 ec 1c             	sub    $0x1c,%esp
  800214:	89 c7                	mov    %eax,%edi
  800216:	89 d6                	mov    %edx,%esi
  800218:	8b 45 08             	mov    0x8(%ebp),%eax
  80021b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800221:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800224:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800227:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80022f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800232:	39 d3                	cmp    %edx,%ebx
  800234:	72 05                	jb     80023b <printnum+0x30>
  800236:	39 45 10             	cmp    %eax,0x10(%ebp)
  800239:	77 45                	ja     800280 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	ff 75 18             	pushl  0x18(%ebp)
  800241:	8b 45 14             	mov    0x14(%ebp),%eax
  800244:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800247:	53                   	push   %ebx
  800248:	ff 75 10             	pushl  0x10(%ebp)
  80024b:	83 ec 08             	sub    $0x8,%esp
  80024e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800251:	ff 75 e0             	pushl  -0x20(%ebp)
  800254:	ff 75 dc             	pushl  -0x24(%ebp)
  800257:	ff 75 d8             	pushl  -0x28(%ebp)
  80025a:	e8 b1 08 00 00       	call   800b10 <__udivdi3>
  80025f:	83 c4 18             	add    $0x18,%esp
  800262:	52                   	push   %edx
  800263:	50                   	push   %eax
  800264:	89 f2                	mov    %esi,%edx
  800266:	89 f8                	mov    %edi,%eax
  800268:	e8 9e ff ff ff       	call   80020b <printnum>
  80026d:	83 c4 20             	add    $0x20,%esp
  800270:	eb 18                	jmp    80028a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800272:	83 ec 08             	sub    $0x8,%esp
  800275:	56                   	push   %esi
  800276:	ff 75 18             	pushl  0x18(%ebp)
  800279:	ff d7                	call   *%edi
  80027b:	83 c4 10             	add    $0x10,%esp
  80027e:	eb 03                	jmp    800283 <printnum+0x78>
  800280:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800283:	83 eb 01             	sub    $0x1,%ebx
  800286:	85 db                	test   %ebx,%ebx
  800288:	7f e8                	jg     800272 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028a:	83 ec 08             	sub    $0x8,%esp
  80028d:	56                   	push   %esi
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	ff 75 e4             	pushl  -0x1c(%ebp)
  800294:	ff 75 e0             	pushl  -0x20(%ebp)
  800297:	ff 75 dc             	pushl  -0x24(%ebp)
  80029a:	ff 75 d8             	pushl  -0x28(%ebp)
  80029d:	e8 9e 09 00 00       	call   800c40 <__umoddi3>
  8002a2:	83 c4 14             	add    $0x14,%esp
  8002a5:	0f be 80 fc 0d 80 00 	movsbl 0x800dfc(%eax),%eax
  8002ac:	50                   	push   %eax
  8002ad:	ff d7                	call   *%edi
}
  8002af:	83 c4 10             	add    $0x10,%esp
  8002b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b5:	5b                   	pop    %ebx
  8002b6:	5e                   	pop    %esi
  8002b7:	5f                   	pop    %edi
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bd:	83 fa 01             	cmp    $0x1,%edx
  8002c0:	7e 0e                	jle    8002d0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 02                	mov    (%edx),%eax
  8002cb:	8b 52 04             	mov    0x4(%edx),%edx
  8002ce:	eb 22                	jmp    8002f2 <getuint+0x38>
	else if (lflag)
  8002d0:	85 d2                	test   %edx,%edx
  8002d2:	74 10                	je     8002e4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d4:	8b 10                	mov    (%eax),%edx
  8002d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d9:	89 08                	mov    %ecx,(%eax)
  8002db:	8b 02                	mov    (%edx),%eax
  8002dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e2:	eb 0e                	jmp    8002f2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e9:	89 08                	mov    %ecx,(%eax)
  8002eb:	8b 02                	mov    (%edx),%eax
  8002ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fa:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	3b 50 04             	cmp    0x4(%eax),%edx
  800303:	73 0a                	jae    80030f <sprintputch+0x1b>
		*b->buf++ = ch;
  800305:	8d 4a 01             	lea    0x1(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 45 08             	mov    0x8(%ebp),%eax
  80030d:	88 02                	mov    %al,(%edx)
}
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031a:	50                   	push   %eax
  80031b:	ff 75 10             	pushl  0x10(%ebp)
  80031e:	ff 75 0c             	pushl  0xc(%ebp)
  800321:	ff 75 08             	pushl  0x8(%ebp)
  800324:	e8 05 00 00 00       	call   80032e <vprintfmt>
	va_end(ap);
}
  800329:	83 c4 10             	add    $0x10,%esp
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	57                   	push   %edi
  800332:	56                   	push   %esi
  800333:	53                   	push   %ebx
  800334:	83 ec 2c             	sub    $0x2c,%esp
  800337:	8b 75 08             	mov    0x8(%ebp),%esi
  80033a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800340:	eb 12                	jmp    800354 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800342:	85 c0                	test   %eax,%eax
  800344:	0f 84 cb 03 00 00    	je     800715 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  80034a:	83 ec 08             	sub    $0x8,%esp
  80034d:	53                   	push   %ebx
  80034e:	50                   	push   %eax
  80034f:	ff d6                	call   *%esi
  800351:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800354:	83 c7 01             	add    $0x1,%edi
  800357:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80035b:	83 f8 25             	cmp    $0x25,%eax
  80035e:	75 e2                	jne    800342 <vprintfmt+0x14>
  800360:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800364:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036b:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800372:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
  80037e:	eb 07                	jmp    800387 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800383:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8d 47 01             	lea    0x1(%edi),%eax
  80038a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038d:	0f b6 07             	movzbl (%edi),%eax
  800390:	0f b6 c8             	movzbl %al,%ecx
  800393:	83 e8 23             	sub    $0x23,%eax
  800396:	3c 55                	cmp    $0x55,%al
  800398:	0f 87 5c 03 00 00    	ja     8006fa <vprintfmt+0x3cc>
  80039e:	0f b6 c0             	movzbl %al,%eax
  8003a1:	ff 24 85 a0 0e 80 00 	jmp    *0x800ea0(,%eax,4)
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ab:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003af:	eb d6                	jmp    800387 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003bf:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003c6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003c9:	83 fa 09             	cmp    $0x9,%edx
  8003cc:	77 39                	ja     800407 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ce:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d1:	eb e9                	jmp    8003bc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	8d 48 04             	lea    0x4(%eax),%ecx
  8003d9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003dc:	8b 00                	mov    (%eax),%eax
  8003de:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e4:	eb 27                	jmp    80040d <vprintfmt+0xdf>
  8003e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f0:	0f 49 c8             	cmovns %eax,%ecx
  8003f3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f9:	eb 8c                	jmp    800387 <vprintfmt+0x59>
  8003fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003fe:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800405:	eb 80                	jmp    800387 <vprintfmt+0x59>
  800407:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040a:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80040d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800411:	0f 89 70 ff ff ff    	jns    800387 <vprintfmt+0x59>
				width = precision, precision = -1;
  800417:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80041a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041d:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800424:	e9 5e ff ff ff       	jmp    800387 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800429:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042f:	e9 53 ff ff ff       	jmp    800387 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 50 04             	lea    0x4(%eax),%edx
  80043a:	89 55 14             	mov    %edx,0x14(%ebp)
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	53                   	push   %ebx
  800441:	ff 30                	pushl  (%eax)
  800443:	ff d6                	call   *%esi
			break;
  800445:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800448:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044b:	e9 04 ff ff ff       	jmp    800354 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 50 04             	lea    0x4(%eax),%edx
  800456:	89 55 14             	mov    %edx,0x14(%ebp)
  800459:	8b 00                	mov    (%eax),%eax
  80045b:	99                   	cltd   
  80045c:	31 d0                	xor    %edx,%eax
  80045e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800460:	83 f8 07             	cmp    $0x7,%eax
  800463:	7f 0b                	jg     800470 <vprintfmt+0x142>
  800465:	8b 14 85 00 10 80 00 	mov    0x801000(,%eax,4),%edx
  80046c:	85 d2                	test   %edx,%edx
  80046e:	75 18                	jne    800488 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800470:	50                   	push   %eax
  800471:	68 14 0e 80 00       	push   $0x800e14
  800476:	53                   	push   %ebx
  800477:	56                   	push   %esi
  800478:	e8 94 fe ff ff       	call   800311 <printfmt>
  80047d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800480:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800483:	e9 cc fe ff ff       	jmp    800354 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800488:	52                   	push   %edx
  800489:	68 1d 0e 80 00       	push   $0x800e1d
  80048e:	53                   	push   %ebx
  80048f:	56                   	push   %esi
  800490:	e8 7c fe ff ff       	call   800311 <printfmt>
  800495:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049b:	e9 b4 fe ff ff       	jmp    800354 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a3:	8d 50 04             	lea    0x4(%eax),%edx
  8004a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ab:	85 ff                	test   %edi,%edi
  8004ad:	b8 0d 0e 80 00       	mov    $0x800e0d,%eax
  8004b2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b9:	0f 8e 94 00 00 00    	jle    800553 <vprintfmt+0x225>
  8004bf:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c3:	0f 84 98 00 00 00    	je     800561 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	ff 75 c8             	pushl  -0x38(%ebp)
  8004cf:	57                   	push   %edi
  8004d0:	e8 c8 02 00 00       	call   80079d <strnlen>
  8004d5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d8:	29 c1                	sub    %eax,%ecx
  8004da:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004dd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ea:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ec:	eb 0f                	jmp    8004fd <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	53                   	push   %ebx
  8004f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f7:	83 ef 01             	sub    $0x1,%edi
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	85 ff                	test   %edi,%edi
  8004ff:	7f ed                	jg     8004ee <vprintfmt+0x1c0>
  800501:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800504:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800507:	85 c9                	test   %ecx,%ecx
  800509:	b8 00 00 00 00       	mov    $0x0,%eax
  80050e:	0f 49 c1             	cmovns %ecx,%eax
  800511:	29 c1                	sub    %eax,%ecx
  800513:	89 75 08             	mov    %esi,0x8(%ebp)
  800516:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800519:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051c:	89 cb                	mov    %ecx,%ebx
  80051e:	eb 4d                	jmp    80056d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800520:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800524:	74 1b                	je     800541 <vprintfmt+0x213>
  800526:	0f be c0             	movsbl %al,%eax
  800529:	83 e8 20             	sub    $0x20,%eax
  80052c:	83 f8 5e             	cmp    $0x5e,%eax
  80052f:	76 10                	jbe    800541 <vprintfmt+0x213>
					putch('?', putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	ff 75 0c             	pushl  0xc(%ebp)
  800537:	6a 3f                	push   $0x3f
  800539:	ff 55 08             	call   *0x8(%ebp)
  80053c:	83 c4 10             	add    $0x10,%esp
  80053f:	eb 0d                	jmp    80054e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	ff 75 0c             	pushl  0xc(%ebp)
  800547:	52                   	push   %edx
  800548:	ff 55 08             	call   *0x8(%ebp)
  80054b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054e:	83 eb 01             	sub    $0x1,%ebx
  800551:	eb 1a                	jmp    80056d <vprintfmt+0x23f>
  800553:	89 75 08             	mov    %esi,0x8(%ebp)
  800556:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800559:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055f:	eb 0c                	jmp    80056d <vprintfmt+0x23f>
  800561:	89 75 08             	mov    %esi,0x8(%ebp)
  800564:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800567:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056d:	83 c7 01             	add    $0x1,%edi
  800570:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800574:	0f be d0             	movsbl %al,%edx
  800577:	85 d2                	test   %edx,%edx
  800579:	74 23                	je     80059e <vprintfmt+0x270>
  80057b:	85 f6                	test   %esi,%esi
  80057d:	78 a1                	js     800520 <vprintfmt+0x1f2>
  80057f:	83 ee 01             	sub    $0x1,%esi
  800582:	79 9c                	jns    800520 <vprintfmt+0x1f2>
  800584:	89 df                	mov    %ebx,%edi
  800586:	8b 75 08             	mov    0x8(%ebp),%esi
  800589:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058c:	eb 18                	jmp    8005a6 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058e:	83 ec 08             	sub    $0x8,%esp
  800591:	53                   	push   %ebx
  800592:	6a 20                	push   $0x20
  800594:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800596:	83 ef 01             	sub    $0x1,%edi
  800599:	83 c4 10             	add    $0x10,%esp
  80059c:	eb 08                	jmp    8005a6 <vprintfmt+0x278>
  80059e:	89 df                	mov    %ebx,%edi
  8005a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a6:	85 ff                	test   %edi,%edi
  8005a8:	7f e4                	jg     80058e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ad:	e9 a2 fd ff ff       	jmp    800354 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b2:	83 fa 01             	cmp    $0x1,%edx
  8005b5:	7e 16                	jle    8005cd <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8d 50 08             	lea    0x8(%eax),%edx
  8005bd:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c0:	8b 50 04             	mov    0x4(%eax),%edx
  8005c3:	8b 00                	mov    (%eax),%eax
  8005c5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005c8:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005cb:	eb 32                	jmp    8005ff <vprintfmt+0x2d1>
	else if (lflag)
  8005cd:	85 d2                	test   %edx,%edx
  8005cf:	74 18                	je     8005e9 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 50 04             	lea    0x4(%eax),%edx
  8005d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005da:	8b 00                	mov    (%eax),%eax
  8005dc:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005df:	89 c1                	mov    %eax,%ecx
  8005e1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005e7:	eb 16                	jmp    8005ff <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8d 50 04             	lea    0x4(%eax),%edx
  8005ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005f7:	89 c1                	mov    %eax,%ecx
  8005f9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005fc:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ff:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800602:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800605:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800608:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80060b:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800610:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800614:	0f 89 a8 00 00 00    	jns    8006c2 <vprintfmt+0x394>
				putch('-', putdat);
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	53                   	push   %ebx
  80061e:	6a 2d                	push   $0x2d
  800620:	ff d6                	call   *%esi
				num = -(long long) num;
  800622:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800625:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800628:	f7 d8                	neg    %eax
  80062a:	83 d2 00             	adc    $0x0,%edx
  80062d:	f7 da                	neg    %edx
  80062f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800632:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800635:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800638:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063d:	e9 80 00 00 00       	jmp    8006c2 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800642:	8d 45 14             	lea    0x14(%ebp),%eax
  800645:	e8 70 fc ff ff       	call   8002ba <getuint>
  80064a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800650:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800655:	eb 6b                	jmp    8006c2 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800657:	8d 45 14             	lea    0x14(%ebp),%eax
  80065a:	e8 5b fc ff ff       	call   8002ba <getuint>
  80065f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800662:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800665:	6a 04                	push   $0x4
  800667:	6a 03                	push   $0x3
  800669:	6a 01                	push   $0x1
  80066b:	68 20 0e 80 00       	push   $0x800e20
  800670:	e8 82 fb ff ff       	call   8001f7 <cprintf>
			goto number;
  800675:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  800678:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  80067d:	eb 43                	jmp    8006c2 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	53                   	push   %ebx
  800683:	6a 30                	push   $0x30
  800685:	ff d6                	call   *%esi
			putch('x', putdat);
  800687:	83 c4 08             	add    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	6a 78                	push   $0x78
  80068d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8d 50 04             	lea    0x4(%eax),%edx
  800695:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800698:	8b 00                	mov    (%eax),%eax
  80069a:	ba 00 00 00 00       	mov    $0x0,%edx
  80069f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006ad:	eb 13                	jmp    8006c2 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006af:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b2:	e8 03 fc ff ff       	call   8002ba <getuint>
  8006b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006bd:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c2:	83 ec 0c             	sub    $0xc,%esp
  8006c5:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006c9:	52                   	push   %edx
  8006ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cd:	50                   	push   %eax
  8006ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8006d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8006d4:	89 da                	mov    %ebx,%edx
  8006d6:	89 f0                	mov    %esi,%eax
  8006d8:	e8 2e fb ff ff       	call   80020b <printnum>

			break;
  8006dd:	83 c4 20             	add    $0x20,%esp
  8006e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e3:	e9 6c fc ff ff       	jmp    800354 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e8:	83 ec 08             	sub    $0x8,%esp
  8006eb:	53                   	push   %ebx
  8006ec:	51                   	push   %ecx
  8006ed:	ff d6                	call   *%esi
			break;
  8006ef:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f5:	e9 5a fc ff ff       	jmp    800354 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	6a 25                	push   $0x25
  800700:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	eb 03                	jmp    80070a <vprintfmt+0x3dc>
  800707:	83 ef 01             	sub    $0x1,%edi
  80070a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80070e:	75 f7                	jne    800707 <vprintfmt+0x3d9>
  800710:	e9 3f fc ff ff       	jmp    800354 <vprintfmt+0x26>
			break;
		}

	}

}
  800715:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800718:	5b                   	pop    %ebx
  800719:	5e                   	pop    %esi
  80071a:	5f                   	pop    %edi
  80071b:	5d                   	pop    %ebp
  80071c:	c3                   	ret    

0080071d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	83 ec 18             	sub    $0x18,%esp
  800723:	8b 45 08             	mov    0x8(%ebp),%eax
  800726:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800729:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800730:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800733:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073a:	85 c0                	test   %eax,%eax
  80073c:	74 26                	je     800764 <vsnprintf+0x47>
  80073e:	85 d2                	test   %edx,%edx
  800740:	7e 22                	jle    800764 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800742:	ff 75 14             	pushl  0x14(%ebp)
  800745:	ff 75 10             	pushl  0x10(%ebp)
  800748:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074b:	50                   	push   %eax
  80074c:	68 f4 02 80 00       	push   $0x8002f4
  800751:	e8 d8 fb ff ff       	call   80032e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800756:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800759:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	eb 05                	jmp    800769 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800764:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800769:	c9                   	leave  
  80076a:	c3                   	ret    

0080076b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800771:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800774:	50                   	push   %eax
  800775:	ff 75 10             	pushl  0x10(%ebp)
  800778:	ff 75 0c             	pushl  0xc(%ebp)
  80077b:	ff 75 08             	pushl  0x8(%ebp)
  80077e:	e8 9a ff ff ff       	call   80071d <vsnprintf>
	va_end(ap);

	return rc;
}
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078b:	b8 00 00 00 00       	mov    $0x0,%eax
  800790:	eb 03                	jmp    800795 <strlen+0x10>
		n++;
  800792:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800795:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800799:	75 f7                	jne    800792 <strlen+0xd>
		n++;
	return n;
}
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ab:	eb 03                	jmp    8007b0 <strnlen+0x13>
		n++;
  8007ad:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b0:	39 c2                	cmp    %eax,%edx
  8007b2:	74 08                	je     8007bc <strnlen+0x1f>
  8007b4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b8:	75 f3                	jne    8007ad <strnlen+0x10>
  8007ba:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007bc:	5d                   	pop    %ebp
  8007bd:	c3                   	ret    

008007be <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	53                   	push   %ebx
  8007c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c8:	89 c2                	mov    %eax,%edx
  8007ca:	83 c2 01             	add    $0x1,%edx
  8007cd:	83 c1 01             	add    $0x1,%ecx
  8007d0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d7:	84 db                	test   %bl,%bl
  8007d9:	75 ef                	jne    8007ca <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007db:	5b                   	pop    %ebx
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	53                   	push   %ebx
  8007e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e5:	53                   	push   %ebx
  8007e6:	e8 9a ff ff ff       	call   800785 <strlen>
  8007eb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ee:	ff 75 0c             	pushl  0xc(%ebp)
  8007f1:	01 d8                	add    %ebx,%eax
  8007f3:	50                   	push   %eax
  8007f4:	e8 c5 ff ff ff       	call   8007be <strcpy>
	return dst;
}
  8007f9:	89 d8                	mov    %ebx,%eax
  8007fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	56                   	push   %esi
  800804:	53                   	push   %ebx
  800805:	8b 75 08             	mov    0x8(%ebp),%esi
  800808:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080b:	89 f3                	mov    %esi,%ebx
  80080d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800810:	89 f2                	mov    %esi,%edx
  800812:	eb 0f                	jmp    800823 <strncpy+0x23>
		*dst++ = *src;
  800814:	83 c2 01             	add    $0x1,%edx
  800817:	0f b6 01             	movzbl (%ecx),%eax
  80081a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081d:	80 39 01             	cmpb   $0x1,(%ecx)
  800820:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800823:	39 da                	cmp    %ebx,%edx
  800825:	75 ed                	jne    800814 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800827:	89 f0                	mov    %esi,%eax
  800829:	5b                   	pop    %ebx
  80082a:	5e                   	pop    %esi
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	56                   	push   %esi
  800831:	53                   	push   %ebx
  800832:	8b 75 08             	mov    0x8(%ebp),%esi
  800835:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800838:	8b 55 10             	mov    0x10(%ebp),%edx
  80083b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083d:	85 d2                	test   %edx,%edx
  80083f:	74 21                	je     800862 <strlcpy+0x35>
  800841:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800845:	89 f2                	mov    %esi,%edx
  800847:	eb 09                	jmp    800852 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800849:	83 c2 01             	add    $0x1,%edx
  80084c:	83 c1 01             	add    $0x1,%ecx
  80084f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800852:	39 c2                	cmp    %eax,%edx
  800854:	74 09                	je     80085f <strlcpy+0x32>
  800856:	0f b6 19             	movzbl (%ecx),%ebx
  800859:	84 db                	test   %bl,%bl
  80085b:	75 ec                	jne    800849 <strlcpy+0x1c>
  80085d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80085f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800862:	29 f0                	sub    %esi,%eax
}
  800864:	5b                   	pop    %ebx
  800865:	5e                   	pop    %esi
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800871:	eb 06                	jmp    800879 <strcmp+0x11>
		p++, q++;
  800873:	83 c1 01             	add    $0x1,%ecx
  800876:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800879:	0f b6 01             	movzbl (%ecx),%eax
  80087c:	84 c0                	test   %al,%al
  80087e:	74 04                	je     800884 <strcmp+0x1c>
  800880:	3a 02                	cmp    (%edx),%al
  800882:	74 ef                	je     800873 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800884:	0f b6 c0             	movzbl %al,%eax
  800887:	0f b6 12             	movzbl (%edx),%edx
  80088a:	29 d0                	sub    %edx,%eax
}
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	53                   	push   %ebx
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	8b 55 0c             	mov    0xc(%ebp),%edx
  800898:	89 c3                	mov    %eax,%ebx
  80089a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80089d:	eb 06                	jmp    8008a5 <strncmp+0x17>
		n--, p++, q++;
  80089f:	83 c0 01             	add    $0x1,%eax
  8008a2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008a5:	39 d8                	cmp    %ebx,%eax
  8008a7:	74 15                	je     8008be <strncmp+0x30>
  8008a9:	0f b6 08             	movzbl (%eax),%ecx
  8008ac:	84 c9                	test   %cl,%cl
  8008ae:	74 04                	je     8008b4 <strncmp+0x26>
  8008b0:	3a 0a                	cmp    (%edx),%cl
  8008b2:	74 eb                	je     80089f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b4:	0f b6 00             	movzbl (%eax),%eax
  8008b7:	0f b6 12             	movzbl (%edx),%edx
  8008ba:	29 d0                	sub    %edx,%eax
  8008bc:	eb 05                	jmp    8008c3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008be:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c3:	5b                   	pop    %ebx
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d0:	eb 07                	jmp    8008d9 <strchr+0x13>
		if (*s == c)
  8008d2:	38 ca                	cmp    %cl,%dl
  8008d4:	74 0f                	je     8008e5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d6:	83 c0 01             	add    $0x1,%eax
  8008d9:	0f b6 10             	movzbl (%eax),%edx
  8008dc:	84 d2                	test   %dl,%dl
  8008de:	75 f2                	jne    8008d2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f1:	eb 03                	jmp    8008f6 <strfind+0xf>
  8008f3:	83 c0 01             	add    $0x1,%eax
  8008f6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f9:	38 ca                	cmp    %cl,%dl
  8008fb:	74 04                	je     800901 <strfind+0x1a>
  8008fd:	84 d2                	test   %dl,%dl
  8008ff:	75 f2                	jne    8008f3 <strfind+0xc>
			break;
	return (char *) s;
}
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	57                   	push   %edi
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
  800909:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090f:	85 c9                	test   %ecx,%ecx
  800911:	74 36                	je     800949 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800913:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800919:	75 28                	jne    800943 <memset+0x40>
  80091b:	f6 c1 03             	test   $0x3,%cl
  80091e:	75 23                	jne    800943 <memset+0x40>
		c &= 0xFF;
  800920:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800924:	89 d3                	mov    %edx,%ebx
  800926:	c1 e3 08             	shl    $0x8,%ebx
  800929:	89 d6                	mov    %edx,%esi
  80092b:	c1 e6 18             	shl    $0x18,%esi
  80092e:	89 d0                	mov    %edx,%eax
  800930:	c1 e0 10             	shl    $0x10,%eax
  800933:	09 f0                	or     %esi,%eax
  800935:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800937:	89 d8                	mov    %ebx,%eax
  800939:	09 d0                	or     %edx,%eax
  80093b:	c1 e9 02             	shr    $0x2,%ecx
  80093e:	fc                   	cld    
  80093f:	f3 ab                	rep stos %eax,%es:(%edi)
  800941:	eb 06                	jmp    800949 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800943:	8b 45 0c             	mov    0xc(%ebp),%eax
  800946:	fc                   	cld    
  800947:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800949:	89 f8                	mov    %edi,%eax
  80094b:	5b                   	pop    %ebx
  80094c:	5e                   	pop    %esi
  80094d:	5f                   	pop    %edi
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	57                   	push   %edi
  800954:	56                   	push   %esi
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095e:	39 c6                	cmp    %eax,%esi
  800960:	73 35                	jae    800997 <memmove+0x47>
  800962:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800965:	39 d0                	cmp    %edx,%eax
  800967:	73 2e                	jae    800997 <memmove+0x47>
		s += n;
		d += n;
  800969:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096c:	89 d6                	mov    %edx,%esi
  80096e:	09 fe                	or     %edi,%esi
  800970:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800976:	75 13                	jne    80098b <memmove+0x3b>
  800978:	f6 c1 03             	test   $0x3,%cl
  80097b:	75 0e                	jne    80098b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80097d:	83 ef 04             	sub    $0x4,%edi
  800980:	8d 72 fc             	lea    -0x4(%edx),%esi
  800983:	c1 e9 02             	shr    $0x2,%ecx
  800986:	fd                   	std    
  800987:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800989:	eb 09                	jmp    800994 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80098b:	83 ef 01             	sub    $0x1,%edi
  80098e:	8d 72 ff             	lea    -0x1(%edx),%esi
  800991:	fd                   	std    
  800992:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800994:	fc                   	cld    
  800995:	eb 1d                	jmp    8009b4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800997:	89 f2                	mov    %esi,%edx
  800999:	09 c2                	or     %eax,%edx
  80099b:	f6 c2 03             	test   $0x3,%dl
  80099e:	75 0f                	jne    8009af <memmove+0x5f>
  8009a0:	f6 c1 03             	test   $0x3,%cl
  8009a3:	75 0a                	jne    8009af <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009a5:	c1 e9 02             	shr    $0x2,%ecx
  8009a8:	89 c7                	mov    %eax,%edi
  8009aa:	fc                   	cld    
  8009ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ad:	eb 05                	jmp    8009b4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009af:	89 c7                	mov    %eax,%edi
  8009b1:	fc                   	cld    
  8009b2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b4:	5e                   	pop    %esi
  8009b5:	5f                   	pop    %edi
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009bb:	ff 75 10             	pushl  0x10(%ebp)
  8009be:	ff 75 0c             	pushl  0xc(%ebp)
  8009c1:	ff 75 08             	pushl  0x8(%ebp)
  8009c4:	e8 87 ff ff ff       	call   800950 <memmove>
}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	56                   	push   %esi
  8009cf:	53                   	push   %ebx
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d6:	89 c6                	mov    %eax,%esi
  8009d8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009db:	eb 1a                	jmp    8009f7 <memcmp+0x2c>
		if (*s1 != *s2)
  8009dd:	0f b6 08             	movzbl (%eax),%ecx
  8009e0:	0f b6 1a             	movzbl (%edx),%ebx
  8009e3:	38 d9                	cmp    %bl,%cl
  8009e5:	74 0a                	je     8009f1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e7:	0f b6 c1             	movzbl %cl,%eax
  8009ea:	0f b6 db             	movzbl %bl,%ebx
  8009ed:	29 d8                	sub    %ebx,%eax
  8009ef:	eb 0f                	jmp    800a00 <memcmp+0x35>
		s1++, s2++;
  8009f1:	83 c0 01             	add    $0x1,%eax
  8009f4:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f7:	39 f0                	cmp    %esi,%eax
  8009f9:	75 e2                	jne    8009dd <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a00:	5b                   	pop    %ebx
  800a01:	5e                   	pop    %esi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	53                   	push   %ebx
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a0b:	89 c1                	mov    %eax,%ecx
  800a0d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a10:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a14:	eb 0a                	jmp    800a20 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a16:	0f b6 10             	movzbl (%eax),%edx
  800a19:	39 da                	cmp    %ebx,%edx
  800a1b:	74 07                	je     800a24 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a1d:	83 c0 01             	add    $0x1,%eax
  800a20:	39 c8                	cmp    %ecx,%eax
  800a22:	72 f2                	jb     800a16 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a24:	5b                   	pop    %ebx
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	57                   	push   %edi
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
  800a2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a30:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a33:	eb 03                	jmp    800a38 <strtol+0x11>
		s++;
  800a35:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a38:	0f b6 01             	movzbl (%ecx),%eax
  800a3b:	3c 20                	cmp    $0x20,%al
  800a3d:	74 f6                	je     800a35 <strtol+0xe>
  800a3f:	3c 09                	cmp    $0x9,%al
  800a41:	74 f2                	je     800a35 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a43:	3c 2b                	cmp    $0x2b,%al
  800a45:	75 0a                	jne    800a51 <strtol+0x2a>
		s++;
  800a47:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a4f:	eb 11                	jmp    800a62 <strtol+0x3b>
  800a51:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a56:	3c 2d                	cmp    $0x2d,%al
  800a58:	75 08                	jne    800a62 <strtol+0x3b>
		s++, neg = 1;
  800a5a:	83 c1 01             	add    $0x1,%ecx
  800a5d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a62:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a68:	75 15                	jne    800a7f <strtol+0x58>
  800a6a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a6d:	75 10                	jne    800a7f <strtol+0x58>
  800a6f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a73:	75 7c                	jne    800af1 <strtol+0xca>
		s += 2, base = 16;
  800a75:	83 c1 02             	add    $0x2,%ecx
  800a78:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7d:	eb 16                	jmp    800a95 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a7f:	85 db                	test   %ebx,%ebx
  800a81:	75 12                	jne    800a95 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a83:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a88:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8b:	75 08                	jne    800a95 <strtol+0x6e>
		s++, base = 8;
  800a8d:	83 c1 01             	add    $0x1,%ecx
  800a90:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a95:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a9d:	0f b6 11             	movzbl (%ecx),%edx
  800aa0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa3:	89 f3                	mov    %esi,%ebx
  800aa5:	80 fb 09             	cmp    $0x9,%bl
  800aa8:	77 08                	ja     800ab2 <strtol+0x8b>
			dig = *s - '0';
  800aaa:	0f be d2             	movsbl %dl,%edx
  800aad:	83 ea 30             	sub    $0x30,%edx
  800ab0:	eb 22                	jmp    800ad4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ab2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab5:	89 f3                	mov    %esi,%ebx
  800ab7:	80 fb 19             	cmp    $0x19,%bl
  800aba:	77 08                	ja     800ac4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800abc:	0f be d2             	movsbl %dl,%edx
  800abf:	83 ea 57             	sub    $0x57,%edx
  800ac2:	eb 10                	jmp    800ad4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac7:	89 f3                	mov    %esi,%ebx
  800ac9:	80 fb 19             	cmp    $0x19,%bl
  800acc:	77 16                	ja     800ae4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ace:	0f be d2             	movsbl %dl,%edx
  800ad1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad7:	7d 0b                	jge    800ae4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad9:	83 c1 01             	add    $0x1,%ecx
  800adc:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ae2:	eb b9                	jmp    800a9d <strtol+0x76>

	if (endptr)
  800ae4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae8:	74 0d                	je     800af7 <strtol+0xd0>
		*endptr = (char *) s;
  800aea:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aed:	89 0e                	mov    %ecx,(%esi)
  800aef:	eb 06                	jmp    800af7 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af1:	85 db                	test   %ebx,%ebx
  800af3:	74 98                	je     800a8d <strtol+0x66>
  800af5:	eb 9e                	jmp    800a95 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af7:	89 c2                	mov    %eax,%edx
  800af9:	f7 da                	neg    %edx
  800afb:	85 ff                	test   %edi,%edi
  800afd:	0f 45 c2             	cmovne %edx,%eax
}
  800b00:	5b                   	pop    %ebx
  800b01:	5e                   	pop    %esi
  800b02:	5f                   	pop    %edi
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    
  800b05:	66 90                	xchg   %ax,%ax
  800b07:	66 90                	xchg   %ax,%ax
  800b09:	66 90                	xchg   %ax,%ax
  800b0b:	66 90                	xchg   %ax,%ax
  800b0d:	66 90                	xchg   %ax,%ax
  800b0f:	90                   	nop

00800b10 <__udivdi3>:
  800b10:	55                   	push   %ebp
  800b11:	57                   	push   %edi
  800b12:	56                   	push   %esi
  800b13:	53                   	push   %ebx
  800b14:	83 ec 1c             	sub    $0x1c,%esp
  800b17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800b1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800b1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800b23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b27:	85 f6                	test   %esi,%esi
  800b29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b2d:	89 ca                	mov    %ecx,%edx
  800b2f:	89 f8                	mov    %edi,%eax
  800b31:	75 3d                	jne    800b70 <__udivdi3+0x60>
  800b33:	39 cf                	cmp    %ecx,%edi
  800b35:	0f 87 c5 00 00 00    	ja     800c00 <__udivdi3+0xf0>
  800b3b:	85 ff                	test   %edi,%edi
  800b3d:	89 fd                	mov    %edi,%ebp
  800b3f:	75 0b                	jne    800b4c <__udivdi3+0x3c>
  800b41:	b8 01 00 00 00       	mov    $0x1,%eax
  800b46:	31 d2                	xor    %edx,%edx
  800b48:	f7 f7                	div    %edi
  800b4a:	89 c5                	mov    %eax,%ebp
  800b4c:	89 c8                	mov    %ecx,%eax
  800b4e:	31 d2                	xor    %edx,%edx
  800b50:	f7 f5                	div    %ebp
  800b52:	89 c1                	mov    %eax,%ecx
  800b54:	89 d8                	mov    %ebx,%eax
  800b56:	89 cf                	mov    %ecx,%edi
  800b58:	f7 f5                	div    %ebp
  800b5a:	89 c3                	mov    %eax,%ebx
  800b5c:	89 d8                	mov    %ebx,%eax
  800b5e:	89 fa                	mov    %edi,%edx
  800b60:	83 c4 1c             	add    $0x1c,%esp
  800b63:	5b                   	pop    %ebx
  800b64:	5e                   	pop    %esi
  800b65:	5f                   	pop    %edi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    
  800b68:	90                   	nop
  800b69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800b70:	39 ce                	cmp    %ecx,%esi
  800b72:	77 74                	ja     800be8 <__udivdi3+0xd8>
  800b74:	0f bd fe             	bsr    %esi,%edi
  800b77:	83 f7 1f             	xor    $0x1f,%edi
  800b7a:	0f 84 98 00 00 00    	je     800c18 <__udivdi3+0x108>
  800b80:	bb 20 00 00 00       	mov    $0x20,%ebx
  800b85:	89 f9                	mov    %edi,%ecx
  800b87:	89 c5                	mov    %eax,%ebp
  800b89:	29 fb                	sub    %edi,%ebx
  800b8b:	d3 e6                	shl    %cl,%esi
  800b8d:	89 d9                	mov    %ebx,%ecx
  800b8f:	d3 ed                	shr    %cl,%ebp
  800b91:	89 f9                	mov    %edi,%ecx
  800b93:	d3 e0                	shl    %cl,%eax
  800b95:	09 ee                	or     %ebp,%esi
  800b97:	89 d9                	mov    %ebx,%ecx
  800b99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b9d:	89 d5                	mov    %edx,%ebp
  800b9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ba3:	d3 ed                	shr    %cl,%ebp
  800ba5:	89 f9                	mov    %edi,%ecx
  800ba7:	d3 e2                	shl    %cl,%edx
  800ba9:	89 d9                	mov    %ebx,%ecx
  800bab:	d3 e8                	shr    %cl,%eax
  800bad:	09 c2                	or     %eax,%edx
  800baf:	89 d0                	mov    %edx,%eax
  800bb1:	89 ea                	mov    %ebp,%edx
  800bb3:	f7 f6                	div    %esi
  800bb5:	89 d5                	mov    %edx,%ebp
  800bb7:	89 c3                	mov    %eax,%ebx
  800bb9:	f7 64 24 0c          	mull   0xc(%esp)
  800bbd:	39 d5                	cmp    %edx,%ebp
  800bbf:	72 10                	jb     800bd1 <__udivdi3+0xc1>
  800bc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800bc5:	89 f9                	mov    %edi,%ecx
  800bc7:	d3 e6                	shl    %cl,%esi
  800bc9:	39 c6                	cmp    %eax,%esi
  800bcb:	73 07                	jae    800bd4 <__udivdi3+0xc4>
  800bcd:	39 d5                	cmp    %edx,%ebp
  800bcf:	75 03                	jne    800bd4 <__udivdi3+0xc4>
  800bd1:	83 eb 01             	sub    $0x1,%ebx
  800bd4:	31 ff                	xor    %edi,%edi
  800bd6:	89 d8                	mov    %ebx,%eax
  800bd8:	89 fa                	mov    %edi,%edx
  800bda:	83 c4 1c             	add    $0x1c,%esp
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    
  800be2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800be8:	31 ff                	xor    %edi,%edi
  800bea:	31 db                	xor    %ebx,%ebx
  800bec:	89 d8                	mov    %ebx,%eax
  800bee:	89 fa                	mov    %edi,%edx
  800bf0:	83 c4 1c             	add    $0x1c,%esp
  800bf3:	5b                   	pop    %ebx
  800bf4:	5e                   	pop    %esi
  800bf5:	5f                   	pop    %edi
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    
  800bf8:	90                   	nop
  800bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c00:	89 d8                	mov    %ebx,%eax
  800c02:	f7 f7                	div    %edi
  800c04:	31 ff                	xor    %edi,%edi
  800c06:	89 c3                	mov    %eax,%ebx
  800c08:	89 d8                	mov    %ebx,%eax
  800c0a:	89 fa                	mov    %edi,%edx
  800c0c:	83 c4 1c             	add    $0x1c,%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    
  800c14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c18:	39 ce                	cmp    %ecx,%esi
  800c1a:	72 0c                	jb     800c28 <__udivdi3+0x118>
  800c1c:	31 db                	xor    %ebx,%ebx
  800c1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800c22:	0f 87 34 ff ff ff    	ja     800b5c <__udivdi3+0x4c>
  800c28:	bb 01 00 00 00       	mov    $0x1,%ebx
  800c2d:	e9 2a ff ff ff       	jmp    800b5c <__udivdi3+0x4c>
  800c32:	66 90                	xchg   %ax,%ax
  800c34:	66 90                	xchg   %ax,%ax
  800c36:	66 90                	xchg   %ax,%ax
  800c38:	66 90                	xchg   %ax,%ax
  800c3a:	66 90                	xchg   %ax,%ax
  800c3c:	66 90                	xchg   %ax,%ax
  800c3e:	66 90                	xchg   %ax,%ax

00800c40 <__umoddi3>:
  800c40:	55                   	push   %ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 1c             	sub    $0x1c,%esp
  800c47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c57:	85 d2                	test   %edx,%edx
  800c59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c61:	89 f3                	mov    %esi,%ebx
  800c63:	89 3c 24             	mov    %edi,(%esp)
  800c66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c6a:	75 1c                	jne    800c88 <__umoddi3+0x48>
  800c6c:	39 f7                	cmp    %esi,%edi
  800c6e:	76 50                	jbe    800cc0 <__umoddi3+0x80>
  800c70:	89 c8                	mov    %ecx,%eax
  800c72:	89 f2                	mov    %esi,%edx
  800c74:	f7 f7                	div    %edi
  800c76:	89 d0                	mov    %edx,%eax
  800c78:	31 d2                	xor    %edx,%edx
  800c7a:	83 c4 1c             	add    $0x1c,%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    
  800c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c88:	39 f2                	cmp    %esi,%edx
  800c8a:	89 d0                	mov    %edx,%eax
  800c8c:	77 52                	ja     800ce0 <__umoddi3+0xa0>
  800c8e:	0f bd ea             	bsr    %edx,%ebp
  800c91:	83 f5 1f             	xor    $0x1f,%ebp
  800c94:	75 5a                	jne    800cf0 <__umoddi3+0xb0>
  800c96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800c9a:	0f 82 e0 00 00 00    	jb     800d80 <__umoddi3+0x140>
  800ca0:	39 0c 24             	cmp    %ecx,(%esp)
  800ca3:	0f 86 d7 00 00 00    	jbe    800d80 <__umoddi3+0x140>
  800ca9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800cad:	8b 54 24 04          	mov    0x4(%esp),%edx
  800cb1:	83 c4 1c             	add    $0x1c,%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    
  800cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cc0:	85 ff                	test   %edi,%edi
  800cc2:	89 fd                	mov    %edi,%ebp
  800cc4:	75 0b                	jne    800cd1 <__umoddi3+0x91>
  800cc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ccb:	31 d2                	xor    %edx,%edx
  800ccd:	f7 f7                	div    %edi
  800ccf:	89 c5                	mov    %eax,%ebp
  800cd1:	89 f0                	mov    %esi,%eax
  800cd3:	31 d2                	xor    %edx,%edx
  800cd5:	f7 f5                	div    %ebp
  800cd7:	89 c8                	mov    %ecx,%eax
  800cd9:	f7 f5                	div    %ebp
  800cdb:	89 d0                	mov    %edx,%eax
  800cdd:	eb 99                	jmp    800c78 <__umoddi3+0x38>
  800cdf:	90                   	nop
  800ce0:	89 c8                	mov    %ecx,%eax
  800ce2:	89 f2                	mov    %esi,%edx
  800ce4:	83 c4 1c             	add    $0x1c,%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    
  800cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cf0:	8b 34 24             	mov    (%esp),%esi
  800cf3:	bf 20 00 00 00       	mov    $0x20,%edi
  800cf8:	89 e9                	mov    %ebp,%ecx
  800cfa:	29 ef                	sub    %ebp,%edi
  800cfc:	d3 e0                	shl    %cl,%eax
  800cfe:	89 f9                	mov    %edi,%ecx
  800d00:	89 f2                	mov    %esi,%edx
  800d02:	d3 ea                	shr    %cl,%edx
  800d04:	89 e9                	mov    %ebp,%ecx
  800d06:	09 c2                	or     %eax,%edx
  800d08:	89 d8                	mov    %ebx,%eax
  800d0a:	89 14 24             	mov    %edx,(%esp)
  800d0d:	89 f2                	mov    %esi,%edx
  800d0f:	d3 e2                	shl    %cl,%edx
  800d11:	89 f9                	mov    %edi,%ecx
  800d13:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d1b:	d3 e8                	shr    %cl,%eax
  800d1d:	89 e9                	mov    %ebp,%ecx
  800d1f:	89 c6                	mov    %eax,%esi
  800d21:	d3 e3                	shl    %cl,%ebx
  800d23:	89 f9                	mov    %edi,%ecx
  800d25:	89 d0                	mov    %edx,%eax
  800d27:	d3 e8                	shr    %cl,%eax
  800d29:	89 e9                	mov    %ebp,%ecx
  800d2b:	09 d8                	or     %ebx,%eax
  800d2d:	89 d3                	mov    %edx,%ebx
  800d2f:	89 f2                	mov    %esi,%edx
  800d31:	f7 34 24             	divl   (%esp)
  800d34:	89 d6                	mov    %edx,%esi
  800d36:	d3 e3                	shl    %cl,%ebx
  800d38:	f7 64 24 04          	mull   0x4(%esp)
  800d3c:	39 d6                	cmp    %edx,%esi
  800d3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d42:	89 d1                	mov    %edx,%ecx
  800d44:	89 c3                	mov    %eax,%ebx
  800d46:	72 08                	jb     800d50 <__umoddi3+0x110>
  800d48:	75 11                	jne    800d5b <__umoddi3+0x11b>
  800d4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800d4e:	73 0b                	jae    800d5b <__umoddi3+0x11b>
  800d50:	2b 44 24 04          	sub    0x4(%esp),%eax
  800d54:	1b 14 24             	sbb    (%esp),%edx
  800d57:	89 d1                	mov    %edx,%ecx
  800d59:	89 c3                	mov    %eax,%ebx
  800d5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800d5f:	29 da                	sub    %ebx,%edx
  800d61:	19 ce                	sbb    %ecx,%esi
  800d63:	89 f9                	mov    %edi,%ecx
  800d65:	89 f0                	mov    %esi,%eax
  800d67:	d3 e0                	shl    %cl,%eax
  800d69:	89 e9                	mov    %ebp,%ecx
  800d6b:	d3 ea                	shr    %cl,%edx
  800d6d:	89 e9                	mov    %ebp,%ecx
  800d6f:	d3 ee                	shr    %cl,%esi
  800d71:	09 d0                	or     %edx,%eax
  800d73:	89 f2                	mov    %esi,%edx
  800d75:	83 c4 1c             	add    $0x1c,%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    
  800d7d:	8d 76 00             	lea    0x0(%esi),%esi
  800d80:	29 f9                	sub    %edi,%ecx
  800d82:	19 d6                	sbb    %edx,%esi
  800d84:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d8c:	e9 18 ff ff ff       	jmp    800ca9 <__umoddi3+0x69>
