
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004d:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800054:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  800057:	e8 c9 00 00 00       	call   800125 <sys_getenvid>
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800064:	c1 e0 05             	shl    $0x5,%eax
  800067:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800071:	85 db                	test   %ebx,%ebx
  800073:	7e 07                	jle    80007c <libmain+0x3a>
		binaryname = argv[0];
  800075:	8b 06                	mov    (%esi),%eax
  800077:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007c:	83 ec 08             	sub    $0x8,%esp
  80007f:	56                   	push   %esi
  800080:	53                   	push   %ebx
  800081:	e8 ad ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800086:	e8 0a 00 00 00       	call   800095 <exit>
}
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800091:	5b                   	pop    %ebx
  800092:	5e                   	pop    %esi
  800093:	5d                   	pop    %ebp
  800094:	c3                   	ret    

00800095 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800095:	55                   	push   %ebp
  800096:	89 e5                	mov    %esp,%ebp
  800098:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 ca 0d 80 00       	push   $0x800dca
  800111:	6a 23                	push   $0x23
  800113:	68 e7 0d 80 00       	push   $0x800de7
  800118:	e8 27 00 00 00       	call   800144 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800149:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800152:	e8 ce ff ff ff       	call   800125 <sys_getenvid>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	ff 75 0c             	pushl  0xc(%ebp)
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	56                   	push   %esi
  800161:	50                   	push   %eax
  800162:	68 f8 0d 80 00       	push   $0x800df8
  800167:	e8 b1 00 00 00       	call   80021d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016c:	83 c4 18             	add    $0x18,%esp
  80016f:	53                   	push   %ebx
  800170:	ff 75 10             	pushl  0x10(%ebp)
  800173:	e8 54 00 00 00       	call   8001cc <vcprintf>
	cprintf("\n");
  800178:	c7 04 24 50 0e 80 00 	movl   $0x800e50,(%esp)
  80017f:	e8 99 00 00 00       	call   80021d <cprintf>
  800184:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800187:	cc                   	int3   
  800188:	eb fd                	jmp    800187 <_panic+0x43>

0080018a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	53                   	push   %ebx
  80018e:	83 ec 04             	sub    $0x4,%esp
  800191:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800194:	8b 13                	mov    (%ebx),%edx
  800196:	8d 42 01             	lea    0x1(%edx),%eax
  800199:	89 03                	mov    %eax,(%ebx)
  80019b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a7:	75 1a                	jne    8001c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a9:	83 ec 08             	sub    $0x8,%esp
  8001ac:	68 ff 00 00 00       	push   $0xff
  8001b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b4:	50                   	push   %eax
  8001b5:	e8 ed fe ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  8001ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001dc:	00 00 00 
	b.cnt = 0;
  8001df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e9:	ff 75 0c             	pushl  0xc(%ebp)
  8001ec:	ff 75 08             	pushl  0x8(%ebp)
  8001ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f5:	50                   	push   %eax
  8001f6:	68 8a 01 80 00       	push   $0x80018a
  8001fb:	e8 54 01 00 00       	call   800354 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800200:	83 c4 08             	add    $0x8,%esp
  800203:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800209:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020f:	50                   	push   %eax
  800210:	e8 92 fe ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  800215:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021b:	c9                   	leave  
  80021c:	c3                   	ret    

0080021d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800223:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800226:	50                   	push   %eax
  800227:	ff 75 08             	pushl  0x8(%ebp)
  80022a:	e8 9d ff ff ff       	call   8001cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 1c             	sub    $0x1c,%esp
  80023a:	89 c7                	mov    %eax,%edi
  80023c:	89 d6                	mov    %edx,%esi
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	8b 55 0c             	mov    0xc(%ebp),%edx
  800244:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800247:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80024d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800252:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800255:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800258:	39 d3                	cmp    %edx,%ebx
  80025a:	72 05                	jb     800261 <printnum+0x30>
  80025c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80025f:	77 45                	ja     8002a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800261:	83 ec 0c             	sub    $0xc,%esp
  800264:	ff 75 18             	pushl  0x18(%ebp)
  800267:	8b 45 14             	mov    0x14(%ebp),%eax
  80026a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80026d:	53                   	push   %ebx
  80026e:	ff 75 10             	pushl  0x10(%ebp)
  800271:	83 ec 08             	sub    $0x8,%esp
  800274:	ff 75 e4             	pushl  -0x1c(%ebp)
  800277:	ff 75 e0             	pushl  -0x20(%ebp)
  80027a:	ff 75 dc             	pushl  -0x24(%ebp)
  80027d:	ff 75 d8             	pushl  -0x28(%ebp)
  800280:	e8 ab 08 00 00       	call   800b30 <__udivdi3>
  800285:	83 c4 18             	add    $0x18,%esp
  800288:	52                   	push   %edx
  800289:	50                   	push   %eax
  80028a:	89 f2                	mov    %esi,%edx
  80028c:	89 f8                	mov    %edi,%eax
  80028e:	e8 9e ff ff ff       	call   800231 <printnum>
  800293:	83 c4 20             	add    $0x20,%esp
  800296:	eb 18                	jmp    8002b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	56                   	push   %esi
  80029c:	ff 75 18             	pushl  0x18(%ebp)
  80029f:	ff d7                	call   *%edi
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	eb 03                	jmp    8002a9 <printnum+0x78>
  8002a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a9:	83 eb 01             	sub    $0x1,%ebx
  8002ac:	85 db                	test   %ebx,%ebx
  8002ae:	7f e8                	jg     800298 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b0:	83 ec 08             	sub    $0x8,%esp
  8002b3:	56                   	push   %esi
  8002b4:	83 ec 04             	sub    $0x4,%esp
  8002b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8002bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c3:	e8 98 09 00 00       	call   800c60 <__umoddi3>
  8002c8:	83 c4 14             	add    $0x14,%esp
  8002cb:	0f be 80 1c 0e 80 00 	movsbl 0x800e1c(%eax),%eax
  8002d2:	50                   	push   %eax
  8002d3:	ff d7                	call   *%edi
}
  8002d5:	83 c4 10             	add    $0x10,%esp
  8002d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002db:	5b                   	pop    %ebx
  8002dc:	5e                   	pop    %esi
  8002dd:	5f                   	pop    %edi
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e3:	83 fa 01             	cmp    $0x1,%edx
  8002e6:	7e 0e                	jle    8002f6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	8b 52 04             	mov    0x4(%edx),%edx
  8002f4:	eb 22                	jmp    800318 <getuint+0x38>
	else if (lflag)
  8002f6:	85 d2                	test   %edx,%edx
  8002f8:	74 10                	je     80030a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002fa:	8b 10                	mov    (%eax),%edx
  8002fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ff:	89 08                	mov    %ecx,(%eax)
  800301:	8b 02                	mov    (%edx),%eax
  800303:	ba 00 00 00 00       	mov    $0x0,%edx
  800308:	eb 0e                	jmp    800318 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030a:	8b 10                	mov    (%eax),%edx
  80030c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030f:	89 08                	mov    %ecx,(%eax)
  800311:	8b 02                	mov    (%edx),%eax
  800313:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800320:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800324:	8b 10                	mov    (%eax),%edx
  800326:	3b 50 04             	cmp    0x4(%eax),%edx
  800329:	73 0a                	jae    800335 <sprintputch+0x1b>
		*b->buf++ = ch;
  80032b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80032e:	89 08                	mov    %ecx,(%eax)
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	88 02                	mov    %al,(%edx)
}
  800335:	5d                   	pop    %ebp
  800336:	c3                   	ret    

00800337 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80033d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800340:	50                   	push   %eax
  800341:	ff 75 10             	pushl  0x10(%ebp)
  800344:	ff 75 0c             	pushl  0xc(%ebp)
  800347:	ff 75 08             	pushl  0x8(%ebp)
  80034a:	e8 05 00 00 00       	call   800354 <vprintfmt>
	va_end(ap);
}
  80034f:	83 c4 10             	add    $0x10,%esp
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
  80035a:	83 ec 2c             	sub    $0x2c,%esp
  80035d:	8b 75 08             	mov    0x8(%ebp),%esi
  800360:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800363:	8b 7d 10             	mov    0x10(%ebp),%edi
  800366:	eb 12                	jmp    80037a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800368:	85 c0                	test   %eax,%eax
  80036a:	0f 84 cb 03 00 00    	je     80073b <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	53                   	push   %ebx
  800374:	50                   	push   %eax
  800375:	ff d6                	call   *%esi
  800377:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80037a:	83 c7 01             	add    $0x1,%edi
  80037d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800381:	83 f8 25             	cmp    $0x25,%eax
  800384:	75 e2                	jne    800368 <vprintfmt+0x14>
  800386:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80038a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800391:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800398:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80039f:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a4:	eb 07                	jmp    8003ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ad:	8d 47 01             	lea    0x1(%edi),%eax
  8003b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b3:	0f b6 07             	movzbl (%edi),%eax
  8003b6:	0f b6 c8             	movzbl %al,%ecx
  8003b9:	83 e8 23             	sub    $0x23,%eax
  8003bc:	3c 55                	cmp    $0x55,%al
  8003be:	0f 87 5c 03 00 00    	ja     800720 <vprintfmt+0x3cc>
  8003c4:	0f b6 c0             	movzbl %al,%eax
  8003c7:	ff 24 85 c0 0e 80 00 	jmp    *0x800ec0(,%eax,4)
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003d5:	eb d6                	jmp    8003ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003da:	b8 00 00 00 00       	mov    $0x0,%eax
  8003df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003e5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003ec:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003ef:	83 fa 09             	cmp    $0x9,%edx
  8003f2:	77 39                	ja     80042d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f7:	eb e9                	jmp    8003e2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ff:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800402:	8b 00                	mov    (%eax),%eax
  800404:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80040a:	eb 27                	jmp    800433 <vprintfmt+0xdf>
  80040c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040f:	85 c0                	test   %eax,%eax
  800411:	b9 00 00 00 00       	mov    $0x0,%ecx
  800416:	0f 49 c8             	cmovns %eax,%ecx
  800419:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041f:	eb 8c                	jmp    8003ad <vprintfmt+0x59>
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800424:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80042b:	eb 80                	jmp    8003ad <vprintfmt+0x59>
  80042d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800430:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800433:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800437:	0f 89 70 ff ff ff    	jns    8003ad <vprintfmt+0x59>
				width = precision, precision = -1;
  80043d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800440:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800443:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80044a:	e9 5e ff ff ff       	jmp    8003ad <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80044f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800455:	e9 53 ff ff ff       	jmp    8003ad <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80045a:	8b 45 14             	mov    0x14(%ebp),%eax
  80045d:	8d 50 04             	lea    0x4(%eax),%edx
  800460:	89 55 14             	mov    %edx,0x14(%ebp)
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	53                   	push   %ebx
  800467:	ff 30                	pushl  (%eax)
  800469:	ff d6                	call   *%esi
			break;
  80046b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800471:	e9 04 ff ff ff       	jmp    80037a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800476:	8b 45 14             	mov    0x14(%ebp),%eax
  800479:	8d 50 04             	lea    0x4(%eax),%edx
  80047c:	89 55 14             	mov    %edx,0x14(%ebp)
  80047f:	8b 00                	mov    (%eax),%eax
  800481:	99                   	cltd   
  800482:	31 d0                	xor    %edx,%eax
  800484:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800486:	83 f8 07             	cmp    $0x7,%eax
  800489:	7f 0b                	jg     800496 <vprintfmt+0x142>
  80048b:	8b 14 85 20 10 80 00 	mov    0x801020(,%eax,4),%edx
  800492:	85 d2                	test   %edx,%edx
  800494:	75 18                	jne    8004ae <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800496:	50                   	push   %eax
  800497:	68 34 0e 80 00       	push   $0x800e34
  80049c:	53                   	push   %ebx
  80049d:	56                   	push   %esi
  80049e:	e8 94 fe ff ff       	call   800337 <printfmt>
  8004a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a9:	e9 cc fe ff ff       	jmp    80037a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004ae:	52                   	push   %edx
  8004af:	68 3d 0e 80 00       	push   $0x800e3d
  8004b4:	53                   	push   %ebx
  8004b5:	56                   	push   %esi
  8004b6:	e8 7c fe ff ff       	call   800337 <printfmt>
  8004bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c1:	e9 b4 fe ff ff       	jmp    80037a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 50 04             	lea    0x4(%eax),%edx
  8004cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004d1:	85 ff                	test   %edi,%edi
  8004d3:	b8 2d 0e 80 00       	mov    $0x800e2d,%eax
  8004d8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004df:	0f 8e 94 00 00 00    	jle    800579 <vprintfmt+0x225>
  8004e5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e9:	0f 84 98 00 00 00    	je     800587 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	ff 75 c8             	pushl  -0x38(%ebp)
  8004f5:	57                   	push   %edi
  8004f6:	e8 c8 02 00 00       	call   8007c3 <strnlen>
  8004fb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004fe:	29 c1                	sub    %eax,%ecx
  800500:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800503:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800506:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80050a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800510:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800512:	eb 0f                	jmp    800523 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	53                   	push   %ebx
  800518:	ff 75 e0             	pushl  -0x20(%ebp)
  80051b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051d:	83 ef 01             	sub    $0x1,%edi
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	85 ff                	test   %edi,%edi
  800525:	7f ed                	jg     800514 <vprintfmt+0x1c0>
  800527:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80052a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80052d:	85 c9                	test   %ecx,%ecx
  80052f:	b8 00 00 00 00       	mov    $0x0,%eax
  800534:	0f 49 c1             	cmovns %ecx,%eax
  800537:	29 c1                	sub    %eax,%ecx
  800539:	89 75 08             	mov    %esi,0x8(%ebp)
  80053c:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80053f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800542:	89 cb                	mov    %ecx,%ebx
  800544:	eb 4d                	jmp    800593 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800546:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054a:	74 1b                	je     800567 <vprintfmt+0x213>
  80054c:	0f be c0             	movsbl %al,%eax
  80054f:	83 e8 20             	sub    $0x20,%eax
  800552:	83 f8 5e             	cmp    $0x5e,%eax
  800555:	76 10                	jbe    800567 <vprintfmt+0x213>
					putch('?', putdat);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	ff 75 0c             	pushl  0xc(%ebp)
  80055d:	6a 3f                	push   $0x3f
  80055f:	ff 55 08             	call   *0x8(%ebp)
  800562:	83 c4 10             	add    $0x10,%esp
  800565:	eb 0d                	jmp    800574 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	ff 75 0c             	pushl  0xc(%ebp)
  80056d:	52                   	push   %edx
  80056e:	ff 55 08             	call   *0x8(%ebp)
  800571:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800574:	83 eb 01             	sub    $0x1,%ebx
  800577:	eb 1a                	jmp    800593 <vprintfmt+0x23f>
  800579:	89 75 08             	mov    %esi,0x8(%ebp)
  80057c:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80057f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800582:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800585:	eb 0c                	jmp    800593 <vprintfmt+0x23f>
  800587:	89 75 08             	mov    %esi,0x8(%ebp)
  80058a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80058d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800590:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800593:	83 c7 01             	add    $0x1,%edi
  800596:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80059a:	0f be d0             	movsbl %al,%edx
  80059d:	85 d2                	test   %edx,%edx
  80059f:	74 23                	je     8005c4 <vprintfmt+0x270>
  8005a1:	85 f6                	test   %esi,%esi
  8005a3:	78 a1                	js     800546 <vprintfmt+0x1f2>
  8005a5:	83 ee 01             	sub    $0x1,%esi
  8005a8:	79 9c                	jns    800546 <vprintfmt+0x1f2>
  8005aa:	89 df                	mov    %ebx,%edi
  8005ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8005af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b2:	eb 18                	jmp    8005cc <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	53                   	push   %ebx
  8005b8:	6a 20                	push   $0x20
  8005ba:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005bc:	83 ef 01             	sub    $0x1,%edi
  8005bf:	83 c4 10             	add    $0x10,%esp
  8005c2:	eb 08                	jmp    8005cc <vprintfmt+0x278>
  8005c4:	89 df                	mov    %ebx,%edi
  8005c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005cc:	85 ff                	test   %edi,%edi
  8005ce:	7f e4                	jg     8005b4 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d3:	e9 a2 fd ff ff       	jmp    80037a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d8:	83 fa 01             	cmp    $0x1,%edx
  8005db:	7e 16                	jle    8005f3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 08             	lea    0x8(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	8b 50 04             	mov    0x4(%eax),%edx
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005ee:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005f1:	eb 32                	jmp    800625 <vprintfmt+0x2d1>
	else if (lflag)
  8005f3:	85 d2                	test   %edx,%edx
  8005f5:	74 18                	je     80060f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 50 04             	lea    0x4(%eax),%edx
  8005fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800600:	8b 00                	mov    (%eax),%eax
  800602:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800605:	89 c1                	mov    %eax,%ecx
  800607:	c1 f9 1f             	sar    $0x1f,%ecx
  80060a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80060d:	eb 16                	jmp    800625 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8d 50 04             	lea    0x4(%eax),%edx
  800615:	89 55 14             	mov    %edx,0x14(%ebp)
  800618:	8b 00                	mov    (%eax),%eax
  80061a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80061d:	89 c1                	mov    %eax,%ecx
  80061f:	c1 f9 1f             	sar    $0x1f,%ecx
  800622:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800625:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800628:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80062b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800631:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800636:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80063a:	0f 89 a8 00 00 00    	jns    8006e8 <vprintfmt+0x394>
				putch('-', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	53                   	push   %ebx
  800644:	6a 2d                	push   $0x2d
  800646:	ff d6                	call   *%esi
				num = -(long long) num;
  800648:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80064b:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80064e:	f7 d8                	neg    %eax
  800650:	83 d2 00             	adc    $0x0,%edx
  800653:	f7 da                	neg    %edx
  800655:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800658:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80065b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80065e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800663:	e9 80 00 00 00       	jmp    8006e8 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800668:	8d 45 14             	lea    0x14(%ebp),%eax
  80066b:	e8 70 fc ff ff       	call   8002e0 <getuint>
  800670:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800673:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800676:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80067b:	eb 6b                	jmp    8006e8 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80067d:	8d 45 14             	lea    0x14(%ebp),%eax
  800680:	e8 5b fc ff ff       	call   8002e0 <getuint>
  800685:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800688:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  80068b:	6a 04                	push   $0x4
  80068d:	6a 03                	push   $0x3
  80068f:	6a 01                	push   $0x1
  800691:	68 40 0e 80 00       	push   $0x800e40
  800696:	e8 82 fb ff ff       	call   80021d <cprintf>
			goto number;
  80069b:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  80069e:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  8006a3:	eb 43                	jmp    8006e8 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	6a 30                	push   $0x30
  8006ab:	ff d6                	call   *%esi
			putch('x', putdat);
  8006ad:	83 c4 08             	add    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	6a 78                	push   $0x78
  8006b3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8d 50 04             	lea    0x4(%eax),%edx
  8006bb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006be:	8b 00                	mov    (%eax),%eax
  8006c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006cb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ce:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d3:	eb 13                	jmp    8006e8 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d8:	e8 03 fc ff ff       	call   8002e0 <getuint>
  8006dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006e3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e8:	83 ec 0c             	sub    $0xc,%esp
  8006eb:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006ef:	52                   	push   %edx
  8006f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f3:	50                   	push   %eax
  8006f4:	ff 75 dc             	pushl  -0x24(%ebp)
  8006f7:	ff 75 d8             	pushl  -0x28(%ebp)
  8006fa:	89 da                	mov    %ebx,%edx
  8006fc:	89 f0                	mov    %esi,%eax
  8006fe:	e8 2e fb ff ff       	call   800231 <printnum>

			break;
  800703:	83 c4 20             	add    $0x20,%esp
  800706:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800709:	e9 6c fc ff ff       	jmp    80037a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	53                   	push   %ebx
  800712:	51                   	push   %ecx
  800713:	ff d6                	call   *%esi
			break;
  800715:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800718:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80071b:	e9 5a fc ff ff       	jmp    80037a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	53                   	push   %ebx
  800724:	6a 25                	push   $0x25
  800726:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	eb 03                	jmp    800730 <vprintfmt+0x3dc>
  80072d:	83 ef 01             	sub    $0x1,%edi
  800730:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800734:	75 f7                	jne    80072d <vprintfmt+0x3d9>
  800736:	e9 3f fc ff ff       	jmp    80037a <vprintfmt+0x26>
			break;
		}

	}

}
  80073b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80073e:	5b                   	pop    %ebx
  80073f:	5e                   	pop    %esi
  800740:	5f                   	pop    %edi
  800741:	5d                   	pop    %ebp
  800742:	c3                   	ret    

00800743 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	83 ec 18             	sub    $0x18,%esp
  800749:	8b 45 08             	mov    0x8(%ebp),%eax
  80074c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800752:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800756:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800759:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800760:	85 c0                	test   %eax,%eax
  800762:	74 26                	je     80078a <vsnprintf+0x47>
  800764:	85 d2                	test   %edx,%edx
  800766:	7e 22                	jle    80078a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800768:	ff 75 14             	pushl  0x14(%ebp)
  80076b:	ff 75 10             	pushl  0x10(%ebp)
  80076e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800771:	50                   	push   %eax
  800772:	68 1a 03 80 00       	push   $0x80031a
  800777:	e8 d8 fb ff ff       	call   800354 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800782:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800785:	83 c4 10             	add    $0x10,%esp
  800788:	eb 05                	jmp    80078f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80078a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800797:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079a:	50                   	push   %eax
  80079b:	ff 75 10             	pushl  0x10(%ebp)
  80079e:	ff 75 0c             	pushl  0xc(%ebp)
  8007a1:	ff 75 08             	pushl  0x8(%ebp)
  8007a4:	e8 9a ff ff ff       	call   800743 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    

008007ab <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b6:	eb 03                	jmp    8007bb <strlen+0x10>
		n++;
  8007b8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007bf:	75 f7                	jne    8007b8 <strlen+0xd>
		n++;
	return n;
}
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d1:	eb 03                	jmp    8007d6 <strnlen+0x13>
		n++;
  8007d3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d6:	39 c2                	cmp    %eax,%edx
  8007d8:	74 08                	je     8007e2 <strnlen+0x1f>
  8007da:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007de:	75 f3                	jne    8007d3 <strnlen+0x10>
  8007e0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007e2:	5d                   	pop    %ebp
  8007e3:	c3                   	ret    

008007e4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	53                   	push   %ebx
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ee:	89 c2                	mov    %eax,%edx
  8007f0:	83 c2 01             	add    $0x1,%edx
  8007f3:	83 c1 01             	add    $0x1,%ecx
  8007f6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007fa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007fd:	84 db                	test   %bl,%bl
  8007ff:	75 ef                	jne    8007f0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800801:	5b                   	pop    %ebx
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	53                   	push   %ebx
  800808:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80080b:	53                   	push   %ebx
  80080c:	e8 9a ff ff ff       	call   8007ab <strlen>
  800811:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800814:	ff 75 0c             	pushl  0xc(%ebp)
  800817:	01 d8                	add    %ebx,%eax
  800819:	50                   	push   %eax
  80081a:	e8 c5 ff ff ff       	call   8007e4 <strcpy>
	return dst;
}
  80081f:	89 d8                	mov    %ebx,%eax
  800821:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800824:	c9                   	leave  
  800825:	c3                   	ret    

00800826 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	56                   	push   %esi
  80082a:	53                   	push   %ebx
  80082b:	8b 75 08             	mov    0x8(%ebp),%esi
  80082e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800831:	89 f3                	mov    %esi,%ebx
  800833:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800836:	89 f2                	mov    %esi,%edx
  800838:	eb 0f                	jmp    800849 <strncpy+0x23>
		*dst++ = *src;
  80083a:	83 c2 01             	add    $0x1,%edx
  80083d:	0f b6 01             	movzbl (%ecx),%eax
  800840:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800843:	80 39 01             	cmpb   $0x1,(%ecx)
  800846:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800849:	39 da                	cmp    %ebx,%edx
  80084b:	75 ed                	jne    80083a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80084d:	89 f0                	mov    %esi,%eax
  80084f:	5b                   	pop    %ebx
  800850:	5e                   	pop    %esi
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	56                   	push   %esi
  800857:	53                   	push   %ebx
  800858:	8b 75 08             	mov    0x8(%ebp),%esi
  80085b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085e:	8b 55 10             	mov    0x10(%ebp),%edx
  800861:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800863:	85 d2                	test   %edx,%edx
  800865:	74 21                	je     800888 <strlcpy+0x35>
  800867:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80086b:	89 f2                	mov    %esi,%edx
  80086d:	eb 09                	jmp    800878 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80086f:	83 c2 01             	add    $0x1,%edx
  800872:	83 c1 01             	add    $0x1,%ecx
  800875:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800878:	39 c2                	cmp    %eax,%edx
  80087a:	74 09                	je     800885 <strlcpy+0x32>
  80087c:	0f b6 19             	movzbl (%ecx),%ebx
  80087f:	84 db                	test   %bl,%bl
  800881:	75 ec                	jne    80086f <strlcpy+0x1c>
  800883:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800885:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800888:	29 f0                	sub    %esi,%eax
}
  80088a:	5b                   	pop    %ebx
  80088b:	5e                   	pop    %esi
  80088c:	5d                   	pop    %ebp
  80088d:	c3                   	ret    

0080088e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800894:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800897:	eb 06                	jmp    80089f <strcmp+0x11>
		p++, q++;
  800899:	83 c1 01             	add    $0x1,%ecx
  80089c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80089f:	0f b6 01             	movzbl (%ecx),%eax
  8008a2:	84 c0                	test   %al,%al
  8008a4:	74 04                	je     8008aa <strcmp+0x1c>
  8008a6:	3a 02                	cmp    (%edx),%al
  8008a8:	74 ef                	je     800899 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008aa:	0f b6 c0             	movzbl %al,%eax
  8008ad:	0f b6 12             	movzbl (%edx),%edx
  8008b0:	29 d0                	sub    %edx,%eax
}
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	53                   	push   %ebx
  8008b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008be:	89 c3                	mov    %eax,%ebx
  8008c0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c3:	eb 06                	jmp    8008cb <strncmp+0x17>
		n--, p++, q++;
  8008c5:	83 c0 01             	add    $0x1,%eax
  8008c8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008cb:	39 d8                	cmp    %ebx,%eax
  8008cd:	74 15                	je     8008e4 <strncmp+0x30>
  8008cf:	0f b6 08             	movzbl (%eax),%ecx
  8008d2:	84 c9                	test   %cl,%cl
  8008d4:	74 04                	je     8008da <strncmp+0x26>
  8008d6:	3a 0a                	cmp    (%edx),%cl
  8008d8:	74 eb                	je     8008c5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008da:	0f b6 00             	movzbl (%eax),%eax
  8008dd:	0f b6 12             	movzbl (%edx),%edx
  8008e0:	29 d0                	sub    %edx,%eax
  8008e2:	eb 05                	jmp    8008e9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e9:	5b                   	pop    %ebx
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f6:	eb 07                	jmp    8008ff <strchr+0x13>
		if (*s == c)
  8008f8:	38 ca                	cmp    %cl,%dl
  8008fa:	74 0f                	je     80090b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008fc:	83 c0 01             	add    $0x1,%eax
  8008ff:	0f b6 10             	movzbl (%eax),%edx
  800902:	84 d2                	test   %dl,%dl
  800904:	75 f2                	jne    8008f8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800906:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800917:	eb 03                	jmp    80091c <strfind+0xf>
  800919:	83 c0 01             	add    $0x1,%eax
  80091c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80091f:	38 ca                	cmp    %cl,%dl
  800921:	74 04                	je     800927 <strfind+0x1a>
  800923:	84 d2                	test   %dl,%dl
  800925:	75 f2                	jne    800919 <strfind+0xc>
			break;
	return (char *) s;
}
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	57                   	push   %edi
  80092d:	56                   	push   %esi
  80092e:	53                   	push   %ebx
  80092f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800932:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800935:	85 c9                	test   %ecx,%ecx
  800937:	74 36                	je     80096f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800939:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093f:	75 28                	jne    800969 <memset+0x40>
  800941:	f6 c1 03             	test   $0x3,%cl
  800944:	75 23                	jne    800969 <memset+0x40>
		c &= 0xFF;
  800946:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094a:	89 d3                	mov    %edx,%ebx
  80094c:	c1 e3 08             	shl    $0x8,%ebx
  80094f:	89 d6                	mov    %edx,%esi
  800951:	c1 e6 18             	shl    $0x18,%esi
  800954:	89 d0                	mov    %edx,%eax
  800956:	c1 e0 10             	shl    $0x10,%eax
  800959:	09 f0                	or     %esi,%eax
  80095b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80095d:	89 d8                	mov    %ebx,%eax
  80095f:	09 d0                	or     %edx,%eax
  800961:	c1 e9 02             	shr    $0x2,%ecx
  800964:	fc                   	cld    
  800965:	f3 ab                	rep stos %eax,%es:(%edi)
  800967:	eb 06                	jmp    80096f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800969:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096c:	fc                   	cld    
  80096d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096f:	89 f8                	mov    %edi,%eax
  800971:	5b                   	pop    %ebx
  800972:	5e                   	pop    %esi
  800973:	5f                   	pop    %edi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	57                   	push   %edi
  80097a:	56                   	push   %esi
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800981:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800984:	39 c6                	cmp    %eax,%esi
  800986:	73 35                	jae    8009bd <memmove+0x47>
  800988:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098b:	39 d0                	cmp    %edx,%eax
  80098d:	73 2e                	jae    8009bd <memmove+0x47>
		s += n;
		d += n;
  80098f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800992:	89 d6                	mov    %edx,%esi
  800994:	09 fe                	or     %edi,%esi
  800996:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80099c:	75 13                	jne    8009b1 <memmove+0x3b>
  80099e:	f6 c1 03             	test   $0x3,%cl
  8009a1:	75 0e                	jne    8009b1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009a3:	83 ef 04             	sub    $0x4,%edi
  8009a6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a9:	c1 e9 02             	shr    $0x2,%ecx
  8009ac:	fd                   	std    
  8009ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009af:	eb 09                	jmp    8009ba <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b1:	83 ef 01             	sub    $0x1,%edi
  8009b4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009b7:	fd                   	std    
  8009b8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ba:	fc                   	cld    
  8009bb:	eb 1d                	jmp    8009da <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bd:	89 f2                	mov    %esi,%edx
  8009bf:	09 c2                	or     %eax,%edx
  8009c1:	f6 c2 03             	test   $0x3,%dl
  8009c4:	75 0f                	jne    8009d5 <memmove+0x5f>
  8009c6:	f6 c1 03             	test   $0x3,%cl
  8009c9:	75 0a                	jne    8009d5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009cb:	c1 e9 02             	shr    $0x2,%ecx
  8009ce:	89 c7                	mov    %eax,%edi
  8009d0:	fc                   	cld    
  8009d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d3:	eb 05                	jmp    8009da <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d5:	89 c7                	mov    %eax,%edi
  8009d7:	fc                   	cld    
  8009d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009da:	5e                   	pop    %esi
  8009db:	5f                   	pop    %edi
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e1:	ff 75 10             	pushl  0x10(%ebp)
  8009e4:	ff 75 0c             	pushl  0xc(%ebp)
  8009e7:	ff 75 08             	pushl  0x8(%ebp)
  8009ea:	e8 87 ff ff ff       	call   800976 <memmove>
}
  8009ef:	c9                   	leave  
  8009f0:	c3                   	ret    

008009f1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	56                   	push   %esi
  8009f5:	53                   	push   %ebx
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fc:	89 c6                	mov    %eax,%esi
  8009fe:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a01:	eb 1a                	jmp    800a1d <memcmp+0x2c>
		if (*s1 != *s2)
  800a03:	0f b6 08             	movzbl (%eax),%ecx
  800a06:	0f b6 1a             	movzbl (%edx),%ebx
  800a09:	38 d9                	cmp    %bl,%cl
  800a0b:	74 0a                	je     800a17 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a0d:	0f b6 c1             	movzbl %cl,%eax
  800a10:	0f b6 db             	movzbl %bl,%ebx
  800a13:	29 d8                	sub    %ebx,%eax
  800a15:	eb 0f                	jmp    800a26 <memcmp+0x35>
		s1++, s2++;
  800a17:	83 c0 01             	add    $0x1,%eax
  800a1a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1d:	39 f0                	cmp    %esi,%eax
  800a1f:	75 e2                	jne    800a03 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	53                   	push   %ebx
  800a2e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a31:	89 c1                	mov    %eax,%ecx
  800a33:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a36:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3a:	eb 0a                	jmp    800a46 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3c:	0f b6 10             	movzbl (%eax),%edx
  800a3f:	39 da                	cmp    %ebx,%edx
  800a41:	74 07                	je     800a4a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a43:	83 c0 01             	add    $0x1,%eax
  800a46:	39 c8                	cmp    %ecx,%eax
  800a48:	72 f2                	jb     800a3c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a4a:	5b                   	pop    %ebx
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	57                   	push   %edi
  800a51:	56                   	push   %esi
  800a52:	53                   	push   %ebx
  800a53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a59:	eb 03                	jmp    800a5e <strtol+0x11>
		s++;
  800a5b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5e:	0f b6 01             	movzbl (%ecx),%eax
  800a61:	3c 20                	cmp    $0x20,%al
  800a63:	74 f6                	je     800a5b <strtol+0xe>
  800a65:	3c 09                	cmp    $0x9,%al
  800a67:	74 f2                	je     800a5b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a69:	3c 2b                	cmp    $0x2b,%al
  800a6b:	75 0a                	jne    800a77 <strtol+0x2a>
		s++;
  800a6d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a70:	bf 00 00 00 00       	mov    $0x0,%edi
  800a75:	eb 11                	jmp    800a88 <strtol+0x3b>
  800a77:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a7c:	3c 2d                	cmp    $0x2d,%al
  800a7e:	75 08                	jne    800a88 <strtol+0x3b>
		s++, neg = 1;
  800a80:	83 c1 01             	add    $0x1,%ecx
  800a83:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a88:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a8e:	75 15                	jne    800aa5 <strtol+0x58>
  800a90:	80 39 30             	cmpb   $0x30,(%ecx)
  800a93:	75 10                	jne    800aa5 <strtol+0x58>
  800a95:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a99:	75 7c                	jne    800b17 <strtol+0xca>
		s += 2, base = 16;
  800a9b:	83 c1 02             	add    $0x2,%ecx
  800a9e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa3:	eb 16                	jmp    800abb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aa5:	85 db                	test   %ebx,%ebx
  800aa7:	75 12                	jne    800abb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aae:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab1:	75 08                	jne    800abb <strtol+0x6e>
		s++, base = 8;
  800ab3:	83 c1 01             	add    $0x1,%ecx
  800ab6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800abb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac3:	0f b6 11             	movzbl (%ecx),%edx
  800ac6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ac9:	89 f3                	mov    %esi,%ebx
  800acb:	80 fb 09             	cmp    $0x9,%bl
  800ace:	77 08                	ja     800ad8 <strtol+0x8b>
			dig = *s - '0';
  800ad0:	0f be d2             	movsbl %dl,%edx
  800ad3:	83 ea 30             	sub    $0x30,%edx
  800ad6:	eb 22                	jmp    800afa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ad8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800adb:	89 f3                	mov    %esi,%ebx
  800add:	80 fb 19             	cmp    $0x19,%bl
  800ae0:	77 08                	ja     800aea <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ae2:	0f be d2             	movsbl %dl,%edx
  800ae5:	83 ea 57             	sub    $0x57,%edx
  800ae8:	eb 10                	jmp    800afa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aea:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aed:	89 f3                	mov    %esi,%ebx
  800aef:	80 fb 19             	cmp    $0x19,%bl
  800af2:	77 16                	ja     800b0a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800af4:	0f be d2             	movsbl %dl,%edx
  800af7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800afa:	3b 55 10             	cmp    0x10(%ebp),%edx
  800afd:	7d 0b                	jge    800b0a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aff:	83 c1 01             	add    $0x1,%ecx
  800b02:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b06:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b08:	eb b9                	jmp    800ac3 <strtol+0x76>

	if (endptr)
  800b0a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0e:	74 0d                	je     800b1d <strtol+0xd0>
		*endptr = (char *) s;
  800b10:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b13:	89 0e                	mov    %ecx,(%esi)
  800b15:	eb 06                	jmp    800b1d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b17:	85 db                	test   %ebx,%ebx
  800b19:	74 98                	je     800ab3 <strtol+0x66>
  800b1b:	eb 9e                	jmp    800abb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b1d:	89 c2                	mov    %eax,%edx
  800b1f:	f7 da                	neg    %edx
  800b21:	85 ff                	test   %edi,%edi
  800b23:	0f 45 c2             	cmovne %edx,%eax
}
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5f                   	pop    %edi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    
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
