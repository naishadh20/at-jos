
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800045:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80004c:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  80004f:	e8 c9 00 00 00       	call   80011d <sys_getenvid>
  800054:	25 ff 03 00 00       	and    $0x3ff,%eax
  800059:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005c:	c1 e0 05             	shl    $0x5,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x3a>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800093:	6a 00                	push   $0x0
  800095:	e8 42 00 00 00       	call   8000dc <sys_env_destroy>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    

0080009f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  8000a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b0:	89 c3                	mov    %eax,%ebx
  8000b2:	89 c7                	mov    %eax,%edi
  8000b4:	89 c6                	mov    %eax,%esi
  8000b6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b8:	5b                   	pop    %ebx
  8000b9:	5e                   	pop    %esi
  8000ba:	5f                   	pop    %edi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cd:	89 d1                	mov    %edx,%ecx
  8000cf:	89 d3                	mov    %edx,%ebx
  8000d1:	89 d7                	mov    %edx,%edi
  8000d3:	89 d6                	mov    %edx,%esi
  8000d5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
  8000e2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ea:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f2:	89 cb                	mov    %ecx,%ebx
  8000f4:	89 cf                	mov    %ecx,%edi
  8000f6:	89 ce                	mov    %ecx,%esi
  8000f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	7e 17                	jle    800115 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fe:	83 ec 0c             	sub    $0xc,%esp
  800101:	50                   	push   %eax
  800102:	6a 03                	push   $0x3
  800104:	68 ca 0d 80 00       	push   $0x800dca
  800109:	6a 23                	push   $0x23
  80010b:	68 e7 0d 80 00       	push   $0x800de7
  800110:	e8 27 00 00 00       	call   80013c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800115:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5f                   	pop    %edi
  80011b:	5d                   	pop    %ebp
  80011c:	c3                   	ret    

0080011d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	57                   	push   %edi
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800123:	ba 00 00 00 00       	mov    $0x0,%edx
  800128:	b8 02 00 00 00       	mov    $0x2,%eax
  80012d:	89 d1                	mov    %edx,%ecx
  80012f:	89 d3                	mov    %edx,%ebx
  800131:	89 d7                	mov    %edx,%edi
  800133:	89 d6                	mov    %edx,%esi
  800135:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5f                   	pop    %edi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800141:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800144:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80014a:	e8 ce ff ff ff       	call   80011d <sys_getenvid>
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 75 0c             	pushl  0xc(%ebp)
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	56                   	push   %esi
  800159:	50                   	push   %eax
  80015a:	68 f8 0d 80 00       	push   $0x800df8
  80015f:	e8 b1 00 00 00       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800164:	83 c4 18             	add    $0x18,%esp
  800167:	53                   	push   %ebx
  800168:	ff 75 10             	pushl  0x10(%ebp)
  80016b:	e8 54 00 00 00       	call   8001c4 <vcprintf>
	cprintf("\n");
  800170:	c7 04 24 50 0e 80 00 	movl   $0x800e50,(%esp)
  800177:	e8 99 00 00 00       	call   800215 <cprintf>
  80017c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017f:	cc                   	int3   
  800180:	eb fd                	jmp    80017f <_panic+0x43>

00800182 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	53                   	push   %ebx
  800186:	83 ec 04             	sub    $0x4,%esp
  800189:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018c:	8b 13                	mov    (%ebx),%edx
  80018e:	8d 42 01             	lea    0x1(%edx),%eax
  800191:	89 03                	mov    %eax,(%ebx)
  800193:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800196:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019f:	75 1a                	jne    8001bb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	68 ff 00 00 00       	push   $0xff
  8001a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 ed fe ff ff       	call   80009f <sys_cputs>
		b->idx = 0;
  8001b2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d4:	00 00 00 
	b.cnt = 0;
  8001d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e1:	ff 75 0c             	pushl  0xc(%ebp)
  8001e4:	ff 75 08             	pushl  0x8(%ebp)
  8001e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	68 82 01 80 00       	push   $0x800182
  8001f3:	e8 54 01 00 00       	call   80034c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f8:	83 c4 08             	add    $0x8,%esp
  8001fb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800201:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800207:	50                   	push   %eax
  800208:	e8 92 fe ff ff       	call   80009f <sys_cputs>

	return b.cnt;
}
  80020d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021e:	50                   	push   %eax
  80021f:	ff 75 08             	pushl  0x8(%ebp)
  800222:	e8 9d ff ff ff       	call   8001c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 1c             	sub    $0x1c,%esp
  800232:	89 c7                	mov    %eax,%edi
  800234:	89 d6                	mov    %edx,%esi
  800236:	8b 45 08             	mov    0x8(%ebp),%eax
  800239:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800242:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800245:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800250:	39 d3                	cmp    %edx,%ebx
  800252:	72 05                	jb     800259 <printnum+0x30>
  800254:	39 45 10             	cmp    %eax,0x10(%ebp)
  800257:	77 45                	ja     80029e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800259:	83 ec 0c             	sub    $0xc,%esp
  80025c:	ff 75 18             	pushl  0x18(%ebp)
  80025f:	8b 45 14             	mov    0x14(%ebp),%eax
  800262:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800265:	53                   	push   %ebx
  800266:	ff 75 10             	pushl  0x10(%ebp)
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026f:	ff 75 e0             	pushl  -0x20(%ebp)
  800272:	ff 75 dc             	pushl  -0x24(%ebp)
  800275:	ff 75 d8             	pushl  -0x28(%ebp)
  800278:	e8 b3 08 00 00       	call   800b30 <__udivdi3>
  80027d:	83 c4 18             	add    $0x18,%esp
  800280:	52                   	push   %edx
  800281:	50                   	push   %eax
  800282:	89 f2                	mov    %esi,%edx
  800284:	89 f8                	mov    %edi,%eax
  800286:	e8 9e ff ff ff       	call   800229 <printnum>
  80028b:	83 c4 20             	add    $0x20,%esp
  80028e:	eb 18                	jmp    8002a8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	56                   	push   %esi
  800294:	ff 75 18             	pushl  0x18(%ebp)
  800297:	ff d7                	call   *%edi
  800299:	83 c4 10             	add    $0x10,%esp
  80029c:	eb 03                	jmp    8002a1 <printnum+0x78>
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a1:	83 eb 01             	sub    $0x1,%ebx
  8002a4:	85 db                	test   %ebx,%ebx
  8002a6:	7f e8                	jg     800290 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	56                   	push   %esi
  8002ac:	83 ec 04             	sub    $0x4,%esp
  8002af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bb:	e8 a0 09 00 00       	call   800c60 <__umoddi3>
  8002c0:	83 c4 14             	add    $0x14,%esp
  8002c3:	0f be 80 1c 0e 80 00 	movsbl 0x800e1c(%eax),%eax
  8002ca:	50                   	push   %eax
  8002cb:	ff d7                	call   *%edi
}
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d3:	5b                   	pop    %ebx
  8002d4:	5e                   	pop    %esi
  8002d5:	5f                   	pop    %edi
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002db:	83 fa 01             	cmp    $0x1,%edx
  8002de:	7e 0e                	jle    8002ee <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	8b 52 04             	mov    0x4(%edx),%edx
  8002ec:	eb 22                	jmp    800310 <getuint+0x38>
	else if (lflag)
  8002ee:	85 d2                	test   %edx,%edx
  8002f0:	74 10                	je     800302 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800300:	eb 0e                	jmp    800310 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800302:	8b 10                	mov    (%eax),%edx
  800304:	8d 4a 04             	lea    0x4(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800318:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031c:	8b 10                	mov    (%eax),%edx
  80031e:	3b 50 04             	cmp    0x4(%eax),%edx
  800321:	73 0a                	jae    80032d <sprintputch+0x1b>
		*b->buf++ = ch;
  800323:	8d 4a 01             	lea    0x1(%edx),%ecx
  800326:	89 08                	mov    %ecx,(%eax)
  800328:	8b 45 08             	mov    0x8(%ebp),%eax
  80032b:	88 02                	mov    %al,(%edx)
}
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800335:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800338:	50                   	push   %eax
  800339:	ff 75 10             	pushl  0x10(%ebp)
  80033c:	ff 75 0c             	pushl  0xc(%ebp)
  80033f:	ff 75 08             	pushl  0x8(%ebp)
  800342:	e8 05 00 00 00       	call   80034c <vprintfmt>
	va_end(ap);
}
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	c9                   	leave  
  80034b:	c3                   	ret    

0080034c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	57                   	push   %edi
  800350:	56                   	push   %esi
  800351:	53                   	push   %ebx
  800352:	83 ec 2c             	sub    $0x2c,%esp
  800355:	8b 75 08             	mov    0x8(%ebp),%esi
  800358:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035e:	eb 12                	jmp    800372 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800360:	85 c0                	test   %eax,%eax
  800362:	0f 84 cb 03 00 00    	je     800733 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	53                   	push   %ebx
  80036c:	50                   	push   %eax
  80036d:	ff d6                	call   *%esi
  80036f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800372:	83 c7 01             	add    $0x1,%edi
  800375:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800379:	83 f8 25             	cmp    $0x25,%eax
  80037c:	75 e2                	jne    800360 <vprintfmt+0x14>
  80037e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800382:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800389:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800390:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800397:	ba 00 00 00 00       	mov    $0x0,%edx
  80039c:	eb 07                	jmp    8003a5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8d 47 01             	lea    0x1(%edi),%eax
  8003a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ab:	0f b6 07             	movzbl (%edi),%eax
  8003ae:	0f b6 c8             	movzbl %al,%ecx
  8003b1:	83 e8 23             	sub    $0x23,%eax
  8003b4:	3c 55                	cmp    $0x55,%al
  8003b6:	0f 87 5c 03 00 00    	ja     800718 <vprintfmt+0x3cc>
  8003bc:	0f b6 c0             	movzbl %al,%eax
  8003bf:	ff 24 85 c0 0e 80 00 	jmp    *0x800ec0(,%eax,4)
  8003c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003cd:	eb d6                	jmp    8003a5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003da:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003dd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e7:	83 fa 09             	cmp    $0x9,%edx
  8003ea:	77 39                	ja     800425 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ec:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ef:	eb e9                	jmp    8003da <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f4:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003fa:	8b 00                	mov    (%eax),%eax
  8003fc:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800402:	eb 27                	jmp    80042b <vprintfmt+0xdf>
  800404:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800407:	85 c0                	test   %eax,%eax
  800409:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040e:	0f 49 c8             	cmovns %eax,%ecx
  800411:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800417:	eb 8c                	jmp    8003a5 <vprintfmt+0x59>
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800423:	eb 80                	jmp    8003a5 <vprintfmt+0x59>
  800425:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800428:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80042b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042f:	0f 89 70 ff ff ff    	jns    8003a5 <vprintfmt+0x59>
				width = precision, precision = -1;
  800435:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800438:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043b:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800442:	e9 5e ff ff ff       	jmp    8003a5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800447:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044d:	e9 53 ff ff ff       	jmp    8003a5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800452:	8b 45 14             	mov    0x14(%ebp),%eax
  800455:	8d 50 04             	lea    0x4(%eax),%edx
  800458:	89 55 14             	mov    %edx,0x14(%ebp)
  80045b:	83 ec 08             	sub    $0x8,%esp
  80045e:	53                   	push   %ebx
  80045f:	ff 30                	pushl  (%eax)
  800461:	ff d6                	call   *%esi
			break;
  800463:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800466:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800469:	e9 04 ff ff ff       	jmp    800372 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046e:	8b 45 14             	mov    0x14(%ebp),%eax
  800471:	8d 50 04             	lea    0x4(%eax),%edx
  800474:	89 55 14             	mov    %edx,0x14(%ebp)
  800477:	8b 00                	mov    (%eax),%eax
  800479:	99                   	cltd   
  80047a:	31 d0                	xor    %edx,%eax
  80047c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047e:	83 f8 07             	cmp    $0x7,%eax
  800481:	7f 0b                	jg     80048e <vprintfmt+0x142>
  800483:	8b 14 85 20 10 80 00 	mov    0x801020(,%eax,4),%edx
  80048a:	85 d2                	test   %edx,%edx
  80048c:	75 18                	jne    8004a6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048e:	50                   	push   %eax
  80048f:	68 34 0e 80 00       	push   $0x800e34
  800494:	53                   	push   %ebx
  800495:	56                   	push   %esi
  800496:	e8 94 fe ff ff       	call   80032f <printfmt>
  80049b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a1:	e9 cc fe ff ff       	jmp    800372 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a6:	52                   	push   %edx
  8004a7:	68 3d 0e 80 00       	push   $0x800e3d
  8004ac:	53                   	push   %ebx
  8004ad:	56                   	push   %esi
  8004ae:	e8 7c fe ff ff       	call   80032f <printfmt>
  8004b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b9:	e9 b4 fe ff ff       	jmp    800372 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 50 04             	lea    0x4(%eax),%edx
  8004c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c9:	85 ff                	test   %edi,%edi
  8004cb:	b8 2d 0e 80 00       	mov    $0x800e2d,%eax
  8004d0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d7:	0f 8e 94 00 00 00    	jle    800571 <vprintfmt+0x225>
  8004dd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e1:	0f 84 98 00 00 00    	je     80057f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	ff 75 c8             	pushl  -0x38(%ebp)
  8004ed:	57                   	push   %edi
  8004ee:	e8 c8 02 00 00       	call   8007bb <strnlen>
  8004f3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f6:	29 c1                	sub    %eax,%ecx
  8004f8:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004fb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fe:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800502:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800505:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800508:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80050a:	eb 0f                	jmp    80051b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	53                   	push   %ebx
  800510:	ff 75 e0             	pushl  -0x20(%ebp)
  800513:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800515:	83 ef 01             	sub    $0x1,%edi
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	85 ff                	test   %edi,%edi
  80051d:	7f ed                	jg     80050c <vprintfmt+0x1c0>
  80051f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800522:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800525:	85 c9                	test   %ecx,%ecx
  800527:	b8 00 00 00 00       	mov    $0x0,%eax
  80052c:	0f 49 c1             	cmovns %ecx,%eax
  80052f:	29 c1                	sub    %eax,%ecx
  800531:	89 75 08             	mov    %esi,0x8(%ebp)
  800534:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800537:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053a:	89 cb                	mov    %ecx,%ebx
  80053c:	eb 4d                	jmp    80058b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800542:	74 1b                	je     80055f <vprintfmt+0x213>
  800544:	0f be c0             	movsbl %al,%eax
  800547:	83 e8 20             	sub    $0x20,%eax
  80054a:	83 f8 5e             	cmp    $0x5e,%eax
  80054d:	76 10                	jbe    80055f <vprintfmt+0x213>
					putch('?', putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	ff 75 0c             	pushl  0xc(%ebp)
  800555:	6a 3f                	push   $0x3f
  800557:	ff 55 08             	call   *0x8(%ebp)
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	eb 0d                	jmp    80056c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	ff 75 0c             	pushl  0xc(%ebp)
  800565:	52                   	push   %edx
  800566:	ff 55 08             	call   *0x8(%ebp)
  800569:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056c:	83 eb 01             	sub    $0x1,%ebx
  80056f:	eb 1a                	jmp    80058b <vprintfmt+0x23f>
  800571:	89 75 08             	mov    %esi,0x8(%ebp)
  800574:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800577:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057d:	eb 0c                	jmp    80058b <vprintfmt+0x23f>
  80057f:	89 75 08             	mov    %esi,0x8(%ebp)
  800582:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800585:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800588:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058b:	83 c7 01             	add    $0x1,%edi
  80058e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800592:	0f be d0             	movsbl %al,%edx
  800595:	85 d2                	test   %edx,%edx
  800597:	74 23                	je     8005bc <vprintfmt+0x270>
  800599:	85 f6                	test   %esi,%esi
  80059b:	78 a1                	js     80053e <vprintfmt+0x1f2>
  80059d:	83 ee 01             	sub    $0x1,%esi
  8005a0:	79 9c                	jns    80053e <vprintfmt+0x1f2>
  8005a2:	89 df                	mov    %ebx,%edi
  8005a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005aa:	eb 18                	jmp    8005c4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	53                   	push   %ebx
  8005b0:	6a 20                	push   $0x20
  8005b2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b4:	83 ef 01             	sub    $0x1,%edi
  8005b7:	83 c4 10             	add    $0x10,%esp
  8005ba:	eb 08                	jmp    8005c4 <vprintfmt+0x278>
  8005bc:	89 df                	mov    %ebx,%edi
  8005be:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c4:	85 ff                	test   %edi,%edi
  8005c6:	7f e4                	jg     8005ac <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005cb:	e9 a2 fd ff ff       	jmp    800372 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d0:	83 fa 01             	cmp    $0x1,%edx
  8005d3:	7e 16                	jle    8005eb <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 50 08             	lea    0x8(%eax),%edx
  8005db:	89 55 14             	mov    %edx,0x14(%ebp)
  8005de:	8b 50 04             	mov    0x4(%eax),%edx
  8005e1:	8b 00                	mov    (%eax),%eax
  8005e3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005e6:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005e9:	eb 32                	jmp    80061d <vprintfmt+0x2d1>
	else if (lflag)
  8005eb:	85 d2                	test   %edx,%edx
  8005ed:	74 18                	je     800607 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 50 04             	lea    0x4(%eax),%edx
  8005f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005fd:	89 c1                	mov    %eax,%ecx
  8005ff:	c1 f9 1f             	sar    $0x1f,%ecx
  800602:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800605:	eb 16                	jmp    80061d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 50 04             	lea    0x4(%eax),%edx
  80060d:	89 55 14             	mov    %edx,0x14(%ebp)
  800610:	8b 00                	mov    (%eax),%eax
  800612:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800615:	89 c1                	mov    %eax,%ecx
  800617:	c1 f9 1f             	sar    $0x1f,%ecx
  80061a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800620:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800623:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800626:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800629:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80062e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800632:	0f 89 a8 00 00 00    	jns    8006e0 <vprintfmt+0x394>
				putch('-', putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	53                   	push   %ebx
  80063c:	6a 2d                	push   $0x2d
  80063e:	ff d6                	call   *%esi
				num = -(long long) num;
  800640:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800643:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800646:	f7 d8                	neg    %eax
  800648:	83 d2 00             	adc    $0x0,%edx
  80064b:	f7 da                	neg    %edx
  80064d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800650:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800653:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800656:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065b:	e9 80 00 00 00       	jmp    8006e0 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800660:	8d 45 14             	lea    0x14(%ebp),%eax
  800663:	e8 70 fc ff ff       	call   8002d8 <getuint>
  800668:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80066e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800673:	eb 6b                	jmp    8006e0 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800675:	8d 45 14             	lea    0x14(%ebp),%eax
  800678:	e8 5b fc ff ff       	call   8002d8 <getuint>
  80067d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800680:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800683:	6a 04                	push   $0x4
  800685:	6a 03                	push   $0x3
  800687:	6a 01                	push   $0x1
  800689:	68 40 0e 80 00       	push   $0x800e40
  80068e:	e8 82 fb ff ff       	call   800215 <cprintf>
			goto number;
  800693:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  800696:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  80069b:	eb 43                	jmp    8006e0 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	6a 30                	push   $0x30
  8006a3:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a5:	83 c4 08             	add    $0x8,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	6a 78                	push   $0x78
  8006ab:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8d 50 04             	lea    0x4(%eax),%edx
  8006b3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006b6:	8b 00                	mov    (%eax),%eax
  8006b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006c6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006cb:	eb 13                	jmp    8006e0 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006cd:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d0:	e8 03 fc ff ff       	call   8002d8 <getuint>
  8006d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006db:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e0:	83 ec 0c             	sub    $0xc,%esp
  8006e3:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006e7:	52                   	push   %edx
  8006e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006eb:	50                   	push   %eax
  8006ec:	ff 75 dc             	pushl  -0x24(%ebp)
  8006ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8006f2:	89 da                	mov    %ebx,%edx
  8006f4:	89 f0                	mov    %esi,%eax
  8006f6:	e8 2e fb ff ff       	call   800229 <printnum>

			break;
  8006fb:	83 c4 20             	add    $0x20,%esp
  8006fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800701:	e9 6c fc ff ff       	jmp    800372 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800706:	83 ec 08             	sub    $0x8,%esp
  800709:	53                   	push   %ebx
  80070a:	51                   	push   %ecx
  80070b:	ff d6                	call   *%esi
			break;
  80070d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800710:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800713:	e9 5a fc ff ff       	jmp    800372 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800718:	83 ec 08             	sub    $0x8,%esp
  80071b:	53                   	push   %ebx
  80071c:	6a 25                	push   $0x25
  80071e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800720:	83 c4 10             	add    $0x10,%esp
  800723:	eb 03                	jmp    800728 <vprintfmt+0x3dc>
  800725:	83 ef 01             	sub    $0x1,%edi
  800728:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80072c:	75 f7                	jne    800725 <vprintfmt+0x3d9>
  80072e:	e9 3f fc ff ff       	jmp    800372 <vprintfmt+0x26>
			break;
		}

	}

}
  800733:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800736:	5b                   	pop    %ebx
  800737:	5e                   	pop    %esi
  800738:	5f                   	pop    %edi
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	83 ec 18             	sub    $0x18,%esp
  800741:	8b 45 08             	mov    0x8(%ebp),%eax
  800744:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800747:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800751:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800758:	85 c0                	test   %eax,%eax
  80075a:	74 26                	je     800782 <vsnprintf+0x47>
  80075c:	85 d2                	test   %edx,%edx
  80075e:	7e 22                	jle    800782 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800760:	ff 75 14             	pushl  0x14(%ebp)
  800763:	ff 75 10             	pushl  0x10(%ebp)
  800766:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800769:	50                   	push   %eax
  80076a:	68 12 03 80 00       	push   $0x800312
  80076f:	e8 d8 fb ff ff       	call   80034c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800774:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800777:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	eb 05                	jmp    800787 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800782:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800787:	c9                   	leave  
  800788:	c3                   	ret    

00800789 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800792:	50                   	push   %eax
  800793:	ff 75 10             	pushl  0x10(%ebp)
  800796:	ff 75 0c             	pushl  0xc(%ebp)
  800799:	ff 75 08             	pushl  0x8(%ebp)
  80079c:	e8 9a ff ff ff       	call   80073b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a1:	c9                   	leave  
  8007a2:	c3                   	ret    

008007a3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ae:	eb 03                	jmp    8007b3 <strlen+0x10>
		n++;
  8007b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b7:	75 f7                	jne    8007b0 <strlen+0xd>
		n++;
	return n;
}
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c9:	eb 03                	jmp    8007ce <strnlen+0x13>
		n++;
  8007cb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ce:	39 c2                	cmp    %eax,%edx
  8007d0:	74 08                	je     8007da <strnlen+0x1f>
  8007d2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007d6:	75 f3                	jne    8007cb <strnlen+0x10>
  8007d8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	53                   	push   %ebx
  8007e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e6:	89 c2                	mov    %eax,%edx
  8007e8:	83 c2 01             	add    $0x1,%edx
  8007eb:	83 c1 01             	add    $0x1,%ecx
  8007ee:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007f2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f5:	84 db                	test   %bl,%bl
  8007f7:	75 ef                	jne    8007e8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f9:	5b                   	pop    %ebx
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	53                   	push   %ebx
  800800:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800803:	53                   	push   %ebx
  800804:	e8 9a ff ff ff       	call   8007a3 <strlen>
  800809:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80080c:	ff 75 0c             	pushl  0xc(%ebp)
  80080f:	01 d8                	add    %ebx,%eax
  800811:	50                   	push   %eax
  800812:	e8 c5 ff ff ff       	call   8007dc <strcpy>
	return dst;
}
  800817:	89 d8                	mov    %ebx,%eax
  800819:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    

0080081e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	56                   	push   %esi
  800822:	53                   	push   %ebx
  800823:	8b 75 08             	mov    0x8(%ebp),%esi
  800826:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800829:	89 f3                	mov    %esi,%ebx
  80082b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082e:	89 f2                	mov    %esi,%edx
  800830:	eb 0f                	jmp    800841 <strncpy+0x23>
		*dst++ = *src;
  800832:	83 c2 01             	add    $0x1,%edx
  800835:	0f b6 01             	movzbl (%ecx),%eax
  800838:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083b:	80 39 01             	cmpb   $0x1,(%ecx)
  80083e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800841:	39 da                	cmp    %ebx,%edx
  800843:	75 ed                	jne    800832 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800845:	89 f0                	mov    %esi,%eax
  800847:	5b                   	pop    %ebx
  800848:	5e                   	pop    %esi
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	56                   	push   %esi
  80084f:	53                   	push   %ebx
  800850:	8b 75 08             	mov    0x8(%ebp),%esi
  800853:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800856:	8b 55 10             	mov    0x10(%ebp),%edx
  800859:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085b:	85 d2                	test   %edx,%edx
  80085d:	74 21                	je     800880 <strlcpy+0x35>
  80085f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800863:	89 f2                	mov    %esi,%edx
  800865:	eb 09                	jmp    800870 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800867:	83 c2 01             	add    $0x1,%edx
  80086a:	83 c1 01             	add    $0x1,%ecx
  80086d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800870:	39 c2                	cmp    %eax,%edx
  800872:	74 09                	je     80087d <strlcpy+0x32>
  800874:	0f b6 19             	movzbl (%ecx),%ebx
  800877:	84 db                	test   %bl,%bl
  800879:	75 ec                	jne    800867 <strlcpy+0x1c>
  80087b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80087d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800880:	29 f0                	sub    %esi,%eax
}
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088f:	eb 06                	jmp    800897 <strcmp+0x11>
		p++, q++;
  800891:	83 c1 01             	add    $0x1,%ecx
  800894:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800897:	0f b6 01             	movzbl (%ecx),%eax
  80089a:	84 c0                	test   %al,%al
  80089c:	74 04                	je     8008a2 <strcmp+0x1c>
  80089e:	3a 02                	cmp    (%edx),%al
  8008a0:	74 ef                	je     800891 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a2:	0f b6 c0             	movzbl %al,%eax
  8008a5:	0f b6 12             	movzbl (%edx),%edx
  8008a8:	29 d0                	sub    %edx,%eax
}
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	53                   	push   %ebx
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b6:	89 c3                	mov    %eax,%ebx
  8008b8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008bb:	eb 06                	jmp    8008c3 <strncmp+0x17>
		n--, p++, q++;
  8008bd:	83 c0 01             	add    $0x1,%eax
  8008c0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c3:	39 d8                	cmp    %ebx,%eax
  8008c5:	74 15                	je     8008dc <strncmp+0x30>
  8008c7:	0f b6 08             	movzbl (%eax),%ecx
  8008ca:	84 c9                	test   %cl,%cl
  8008cc:	74 04                	je     8008d2 <strncmp+0x26>
  8008ce:	3a 0a                	cmp    (%edx),%cl
  8008d0:	74 eb                	je     8008bd <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d2:	0f b6 00             	movzbl (%eax),%eax
  8008d5:	0f b6 12             	movzbl (%edx),%edx
  8008d8:	29 d0                	sub    %edx,%eax
  8008da:	eb 05                	jmp    8008e1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e1:	5b                   	pop    %ebx
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ee:	eb 07                	jmp    8008f7 <strchr+0x13>
		if (*s == c)
  8008f0:	38 ca                	cmp    %cl,%dl
  8008f2:	74 0f                	je     800903 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f4:	83 c0 01             	add    $0x1,%eax
  8008f7:	0f b6 10             	movzbl (%eax),%edx
  8008fa:	84 d2                	test   %dl,%dl
  8008fc:	75 f2                	jne    8008f0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090f:	eb 03                	jmp    800914 <strfind+0xf>
  800911:	83 c0 01             	add    $0x1,%eax
  800914:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800917:	38 ca                	cmp    %cl,%dl
  800919:	74 04                	je     80091f <strfind+0x1a>
  80091b:	84 d2                	test   %dl,%dl
  80091d:	75 f2                	jne    800911 <strfind+0xc>
			break;
	return (char *) s;
}
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	57                   	push   %edi
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80092d:	85 c9                	test   %ecx,%ecx
  80092f:	74 36                	je     800967 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800931:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800937:	75 28                	jne    800961 <memset+0x40>
  800939:	f6 c1 03             	test   $0x3,%cl
  80093c:	75 23                	jne    800961 <memset+0x40>
		c &= 0xFF;
  80093e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800942:	89 d3                	mov    %edx,%ebx
  800944:	c1 e3 08             	shl    $0x8,%ebx
  800947:	89 d6                	mov    %edx,%esi
  800949:	c1 e6 18             	shl    $0x18,%esi
  80094c:	89 d0                	mov    %edx,%eax
  80094e:	c1 e0 10             	shl    $0x10,%eax
  800951:	09 f0                	or     %esi,%eax
  800953:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800955:	89 d8                	mov    %ebx,%eax
  800957:	09 d0                	or     %edx,%eax
  800959:	c1 e9 02             	shr    $0x2,%ecx
  80095c:	fc                   	cld    
  80095d:	f3 ab                	rep stos %eax,%es:(%edi)
  80095f:	eb 06                	jmp    800967 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800961:	8b 45 0c             	mov    0xc(%ebp),%eax
  800964:	fc                   	cld    
  800965:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800967:	89 f8                	mov    %edi,%eax
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	5f                   	pop    %edi
  80096c:	5d                   	pop    %ebp
  80096d:	c3                   	ret    

0080096e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096e:	55                   	push   %ebp
  80096f:	89 e5                	mov    %esp,%ebp
  800971:	57                   	push   %edi
  800972:	56                   	push   %esi
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8b 75 0c             	mov    0xc(%ebp),%esi
  800979:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097c:	39 c6                	cmp    %eax,%esi
  80097e:	73 35                	jae    8009b5 <memmove+0x47>
  800980:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800983:	39 d0                	cmp    %edx,%eax
  800985:	73 2e                	jae    8009b5 <memmove+0x47>
		s += n;
		d += n;
  800987:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098a:	89 d6                	mov    %edx,%esi
  80098c:	09 fe                	or     %edi,%esi
  80098e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800994:	75 13                	jne    8009a9 <memmove+0x3b>
  800996:	f6 c1 03             	test   $0x3,%cl
  800999:	75 0e                	jne    8009a9 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80099b:	83 ef 04             	sub    $0x4,%edi
  80099e:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a1:	c1 e9 02             	shr    $0x2,%ecx
  8009a4:	fd                   	std    
  8009a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a7:	eb 09                	jmp    8009b2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a9:	83 ef 01             	sub    $0x1,%edi
  8009ac:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009af:	fd                   	std    
  8009b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b2:	fc                   	cld    
  8009b3:	eb 1d                	jmp    8009d2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b5:	89 f2                	mov    %esi,%edx
  8009b7:	09 c2                	or     %eax,%edx
  8009b9:	f6 c2 03             	test   $0x3,%dl
  8009bc:	75 0f                	jne    8009cd <memmove+0x5f>
  8009be:	f6 c1 03             	test   $0x3,%cl
  8009c1:	75 0a                	jne    8009cd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009c3:	c1 e9 02             	shr    $0x2,%ecx
  8009c6:	89 c7                	mov    %eax,%edi
  8009c8:	fc                   	cld    
  8009c9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cb:	eb 05                	jmp    8009d2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009cd:	89 c7                	mov    %eax,%edi
  8009cf:	fc                   	cld    
  8009d0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d2:	5e                   	pop    %esi
  8009d3:	5f                   	pop    %edi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d9:	ff 75 10             	pushl  0x10(%ebp)
  8009dc:	ff 75 0c             	pushl  0xc(%ebp)
  8009df:	ff 75 08             	pushl  0x8(%ebp)
  8009e2:	e8 87 ff ff ff       	call   80096e <memmove>
}
  8009e7:	c9                   	leave  
  8009e8:	c3                   	ret    

008009e9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	56                   	push   %esi
  8009ed:	53                   	push   %ebx
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f4:	89 c6                	mov    %eax,%esi
  8009f6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f9:	eb 1a                	jmp    800a15 <memcmp+0x2c>
		if (*s1 != *s2)
  8009fb:	0f b6 08             	movzbl (%eax),%ecx
  8009fe:	0f b6 1a             	movzbl (%edx),%ebx
  800a01:	38 d9                	cmp    %bl,%cl
  800a03:	74 0a                	je     800a0f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a05:	0f b6 c1             	movzbl %cl,%eax
  800a08:	0f b6 db             	movzbl %bl,%ebx
  800a0b:	29 d8                	sub    %ebx,%eax
  800a0d:	eb 0f                	jmp    800a1e <memcmp+0x35>
		s1++, s2++;
  800a0f:	83 c0 01             	add    $0x1,%eax
  800a12:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a15:	39 f0                	cmp    %esi,%eax
  800a17:	75 e2                	jne    8009fb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1e:	5b                   	pop    %ebx
  800a1f:	5e                   	pop    %esi
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	53                   	push   %ebx
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a29:	89 c1                	mov    %eax,%ecx
  800a2b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a32:	eb 0a                	jmp    800a3e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a34:	0f b6 10             	movzbl (%eax),%edx
  800a37:	39 da                	cmp    %ebx,%edx
  800a39:	74 07                	je     800a42 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3b:	83 c0 01             	add    $0x1,%eax
  800a3e:	39 c8                	cmp    %ecx,%eax
  800a40:	72 f2                	jb     800a34 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a42:	5b                   	pop    %ebx
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	57                   	push   %edi
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
  800a4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a51:	eb 03                	jmp    800a56 <strtol+0x11>
		s++;
  800a53:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a56:	0f b6 01             	movzbl (%ecx),%eax
  800a59:	3c 20                	cmp    $0x20,%al
  800a5b:	74 f6                	je     800a53 <strtol+0xe>
  800a5d:	3c 09                	cmp    $0x9,%al
  800a5f:	74 f2                	je     800a53 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a61:	3c 2b                	cmp    $0x2b,%al
  800a63:	75 0a                	jne    800a6f <strtol+0x2a>
		s++;
  800a65:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a68:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6d:	eb 11                	jmp    800a80 <strtol+0x3b>
  800a6f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a74:	3c 2d                	cmp    $0x2d,%al
  800a76:	75 08                	jne    800a80 <strtol+0x3b>
		s++, neg = 1;
  800a78:	83 c1 01             	add    $0x1,%ecx
  800a7b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a80:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a86:	75 15                	jne    800a9d <strtol+0x58>
  800a88:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8b:	75 10                	jne    800a9d <strtol+0x58>
  800a8d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a91:	75 7c                	jne    800b0f <strtol+0xca>
		s += 2, base = 16;
  800a93:	83 c1 02             	add    $0x2,%ecx
  800a96:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9b:	eb 16                	jmp    800ab3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a9d:	85 db                	test   %ebx,%ebx
  800a9f:	75 12                	jne    800ab3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa6:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa9:	75 08                	jne    800ab3 <strtol+0x6e>
		s++, base = 8;
  800aab:	83 c1 01             	add    $0x1,%ecx
  800aae:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ab3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800abb:	0f b6 11             	movzbl (%ecx),%edx
  800abe:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ac1:	89 f3                	mov    %esi,%ebx
  800ac3:	80 fb 09             	cmp    $0x9,%bl
  800ac6:	77 08                	ja     800ad0 <strtol+0x8b>
			dig = *s - '0';
  800ac8:	0f be d2             	movsbl %dl,%edx
  800acb:	83 ea 30             	sub    $0x30,%edx
  800ace:	eb 22                	jmp    800af2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ad0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad3:	89 f3                	mov    %esi,%ebx
  800ad5:	80 fb 19             	cmp    $0x19,%bl
  800ad8:	77 08                	ja     800ae2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ada:	0f be d2             	movsbl %dl,%edx
  800add:	83 ea 57             	sub    $0x57,%edx
  800ae0:	eb 10                	jmp    800af2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ae2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae5:	89 f3                	mov    %esi,%ebx
  800ae7:	80 fb 19             	cmp    $0x19,%bl
  800aea:	77 16                	ja     800b02 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aec:	0f be d2             	movsbl %dl,%edx
  800aef:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800af2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af5:	7d 0b                	jge    800b02 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800af7:	83 c1 01             	add    $0x1,%ecx
  800afa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800afe:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b00:	eb b9                	jmp    800abb <strtol+0x76>

	if (endptr)
  800b02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b06:	74 0d                	je     800b15 <strtol+0xd0>
		*endptr = (char *) s;
  800b08:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0b:	89 0e                	mov    %ecx,(%esi)
  800b0d:	eb 06                	jmp    800b15 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b0f:	85 db                	test   %ebx,%ebx
  800b11:	74 98                	je     800aab <strtol+0x66>
  800b13:	eb 9e                	jmp    800ab3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b15:	89 c2                	mov    %eax,%edx
  800b17:	f7 da                	neg    %edx
  800b19:	85 ff                	test   %edi,%edi
  800b1b:	0f 45 c2             	cmovne %edx,%eax
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    
  800b23:	66 90                	xchg   %ax,%ax
  800b25:	66 90                	xchg   %ax,%ax
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
