
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 6a 00 00 00       	call   8000ac <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800052:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800059:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  80005c:	e8 c9 00 00 00       	call   80012a <sys_getenvid>
  800061:	25 ff 03 00 00       	and    $0x3ff,%eax
  800066:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800069:	c1 e0 05             	shl    $0x5,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x3a>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 17                	jle    800122 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	50                   	push   %eax
  80010f:	6a 03                	push   $0x3
  800111:	68 ca 0d 80 00       	push   $0x800dca
  800116:	6a 23                	push   $0x23
  800118:	68 e7 0d 80 00       	push   $0x800de7
  80011d:	e8 27 00 00 00       	call   800149 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5f                   	pop    %edi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	56                   	push   %esi
  80014d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800151:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800157:	e8 ce ff ff ff       	call   80012a <sys_getenvid>
  80015c:	83 ec 0c             	sub    $0xc,%esp
  80015f:	ff 75 0c             	pushl  0xc(%ebp)
  800162:	ff 75 08             	pushl  0x8(%ebp)
  800165:	56                   	push   %esi
  800166:	50                   	push   %eax
  800167:	68 f8 0d 80 00       	push   $0x800df8
  80016c:	e8 b1 00 00 00       	call   800222 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800171:	83 c4 18             	add    $0x18,%esp
  800174:	53                   	push   %ebx
  800175:	ff 75 10             	pushl  0x10(%ebp)
  800178:	e8 54 00 00 00       	call   8001d1 <vcprintf>
	cprintf("\n");
  80017d:	c7 04 24 50 0e 80 00 	movl   $0x800e50,(%esp)
  800184:	e8 99 00 00 00       	call   800222 <cprintf>
  800189:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018c:	cc                   	int3   
  80018d:	eb fd                	jmp    80018c <_panic+0x43>

0080018f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	53                   	push   %ebx
  800193:	83 ec 04             	sub    $0x4,%esp
  800196:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800199:	8b 13                	mov    (%ebx),%edx
  80019b:	8d 42 01             	lea    0x1(%edx),%eax
  80019e:	89 03                	mov    %eax,(%ebx)
  8001a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ac:	75 1a                	jne    8001c8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	68 ff 00 00 00       	push   $0xff
  8001b6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b9:	50                   	push   %eax
  8001ba:	e8 ed fe ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8001bf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001cf:	c9                   	leave  
  8001d0:	c3                   	ret    

008001d1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001da:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e1:	00 00 00 
	b.cnt = 0;
  8001e4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001eb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ee:	ff 75 0c             	pushl  0xc(%ebp)
  8001f1:	ff 75 08             	pushl  0x8(%ebp)
  8001f4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	68 8f 01 80 00       	push   $0x80018f
  800200:	e8 54 01 00 00       	call   800359 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800205:	83 c4 08             	add    $0x8,%esp
  800208:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800214:	50                   	push   %eax
  800215:	e8 92 fe ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80021a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800220:	c9                   	leave  
  800221:	c3                   	ret    

00800222 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800228:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022b:	50                   	push   %eax
  80022c:	ff 75 08             	pushl  0x8(%ebp)
  80022f:	e8 9d ff ff ff       	call   8001d1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	57                   	push   %edi
  80023a:	56                   	push   %esi
  80023b:	53                   	push   %ebx
  80023c:	83 ec 1c             	sub    $0x1c,%esp
  80023f:	89 c7                	mov    %eax,%edi
  800241:	89 d6                	mov    %edx,%esi
  800243:	8b 45 08             	mov    0x8(%ebp),%eax
  800246:	8b 55 0c             	mov    0xc(%ebp),%edx
  800249:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800252:	bb 00 00 00 00       	mov    $0x0,%ebx
  800257:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80025d:	39 d3                	cmp    %edx,%ebx
  80025f:	72 05                	jb     800266 <printnum+0x30>
  800261:	39 45 10             	cmp    %eax,0x10(%ebp)
  800264:	77 45                	ja     8002ab <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800266:	83 ec 0c             	sub    $0xc,%esp
  800269:	ff 75 18             	pushl  0x18(%ebp)
  80026c:	8b 45 14             	mov    0x14(%ebp),%eax
  80026f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800272:	53                   	push   %ebx
  800273:	ff 75 10             	pushl  0x10(%ebp)
  800276:	83 ec 08             	sub    $0x8,%esp
  800279:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027c:	ff 75 e0             	pushl  -0x20(%ebp)
  80027f:	ff 75 dc             	pushl  -0x24(%ebp)
  800282:	ff 75 d8             	pushl  -0x28(%ebp)
  800285:	e8 a6 08 00 00       	call   800b30 <__udivdi3>
  80028a:	83 c4 18             	add    $0x18,%esp
  80028d:	52                   	push   %edx
  80028e:	50                   	push   %eax
  80028f:	89 f2                	mov    %esi,%edx
  800291:	89 f8                	mov    %edi,%eax
  800293:	e8 9e ff ff ff       	call   800236 <printnum>
  800298:	83 c4 20             	add    $0x20,%esp
  80029b:	eb 18                	jmp    8002b5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029d:	83 ec 08             	sub    $0x8,%esp
  8002a0:	56                   	push   %esi
  8002a1:	ff 75 18             	pushl  0x18(%ebp)
  8002a4:	ff d7                	call   *%edi
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	eb 03                	jmp    8002ae <printnum+0x78>
  8002ab:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ae:	83 eb 01             	sub    $0x1,%ebx
  8002b1:	85 db                	test   %ebx,%ebx
  8002b3:	7f e8                	jg     80029d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b5:	83 ec 08             	sub    $0x8,%esp
  8002b8:	56                   	push   %esi
  8002b9:	83 ec 04             	sub    $0x4,%esp
  8002bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c8:	e8 93 09 00 00       	call   800c60 <__umoddi3>
  8002cd:	83 c4 14             	add    $0x14,%esp
  8002d0:	0f be 80 1c 0e 80 00 	movsbl 0x800e1c(%eax),%eax
  8002d7:	50                   	push   %eax
  8002d8:	ff d7                	call   *%edi
}
  8002da:	83 c4 10             	add    $0x10,%esp
  8002dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e0:	5b                   	pop    %ebx
  8002e1:	5e                   	pop    %esi
  8002e2:	5f                   	pop    %edi
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    

008002e5 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e8:	83 fa 01             	cmp    $0x1,%edx
  8002eb:	7e 0e                	jle    8002fb <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	8b 52 04             	mov    0x4(%edx),%edx
  8002f9:	eb 22                	jmp    80031d <getuint+0x38>
	else if (lflag)
  8002fb:	85 d2                	test   %edx,%edx
  8002fd:	74 10                	je     80030f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	8d 4a 04             	lea    0x4(%edx),%ecx
  800304:	89 08                	mov    %ecx,(%eax)
  800306:	8b 02                	mov    (%edx),%eax
  800308:	ba 00 00 00 00       	mov    $0x0,%edx
  80030d:	eb 0e                	jmp    80031d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030f:	8b 10                	mov    (%eax),%edx
  800311:	8d 4a 04             	lea    0x4(%edx),%ecx
  800314:	89 08                	mov    %ecx,(%eax)
  800316:	8b 02                	mov    (%edx),%eax
  800318:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    

0080031f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800325:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800329:	8b 10                	mov    (%eax),%edx
  80032b:	3b 50 04             	cmp    0x4(%eax),%edx
  80032e:	73 0a                	jae    80033a <sprintputch+0x1b>
		*b->buf++ = ch;
  800330:	8d 4a 01             	lea    0x1(%edx),%ecx
  800333:	89 08                	mov    %ecx,(%eax)
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	88 02                	mov    %al,(%edx)
}
  80033a:	5d                   	pop    %ebp
  80033b:	c3                   	ret    

0080033c <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800342:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800345:	50                   	push   %eax
  800346:	ff 75 10             	pushl  0x10(%ebp)
  800349:	ff 75 0c             	pushl  0xc(%ebp)
  80034c:	ff 75 08             	pushl  0x8(%ebp)
  80034f:	e8 05 00 00 00       	call   800359 <vprintfmt>
	va_end(ap);
}
  800354:	83 c4 10             	add    $0x10,%esp
  800357:	c9                   	leave  
  800358:	c3                   	ret    

00800359 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800359:	55                   	push   %ebp
  80035a:	89 e5                	mov    %esp,%ebp
  80035c:	57                   	push   %edi
  80035d:	56                   	push   %esi
  80035e:	53                   	push   %ebx
  80035f:	83 ec 2c             	sub    $0x2c,%esp
  800362:	8b 75 08             	mov    0x8(%ebp),%esi
  800365:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800368:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036b:	eb 12                	jmp    80037f <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80036d:	85 c0                	test   %eax,%eax
  80036f:	0f 84 cb 03 00 00    	je     800740 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800375:	83 ec 08             	sub    $0x8,%esp
  800378:	53                   	push   %ebx
  800379:	50                   	push   %eax
  80037a:	ff d6                	call   *%esi
  80037c:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80037f:	83 c7 01             	add    $0x1,%edi
  800382:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800386:	83 f8 25             	cmp    $0x25,%eax
  800389:	75 e2                	jne    80036d <vprintfmt+0x14>
  80038b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80038f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800396:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80039d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a9:	eb 07                	jmp    8003b2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003ae:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8d 47 01             	lea    0x1(%edi),%eax
  8003b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b8:	0f b6 07             	movzbl (%edi),%eax
  8003bb:	0f b6 c8             	movzbl %al,%ecx
  8003be:	83 e8 23             	sub    $0x23,%eax
  8003c1:	3c 55                	cmp    $0x55,%al
  8003c3:	0f 87 5c 03 00 00    	ja     800725 <vprintfmt+0x3cc>
  8003c9:	0f b6 c0             	movzbl %al,%eax
  8003cc:	ff 24 85 c0 0e 80 00 	jmp    *0x800ec0(,%eax,4)
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d6:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003da:	eb d6                	jmp    8003b2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003df:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ea:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ee:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f1:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f4:	83 fa 09             	cmp    $0x9,%edx
  8003f7:	77 39                	ja     800432 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003fc:	eb e9                	jmp    8003e7 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800401:	8d 48 04             	lea    0x4(%eax),%ecx
  800404:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800407:	8b 00                	mov    (%eax),%eax
  800409:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80040f:	eb 27                	jmp    800438 <vprintfmt+0xdf>
  800411:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800414:	85 c0                	test   %eax,%eax
  800416:	b9 00 00 00 00       	mov    $0x0,%ecx
  80041b:	0f 49 c8             	cmovns %eax,%ecx
  80041e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800424:	eb 8c                	jmp    8003b2 <vprintfmt+0x59>
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800429:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800430:	eb 80                	jmp    8003b2 <vprintfmt+0x59>
  800432:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800435:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800438:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043c:	0f 89 70 ff ff ff    	jns    8003b2 <vprintfmt+0x59>
				width = precision, precision = -1;
  800442:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800445:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800448:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80044f:	e9 5e ff ff ff       	jmp    8003b2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800454:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80045a:	e9 53 ff ff ff       	jmp    8003b2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80045f:	8b 45 14             	mov    0x14(%ebp),%eax
  800462:	8d 50 04             	lea    0x4(%eax),%edx
  800465:	89 55 14             	mov    %edx,0x14(%ebp)
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	53                   	push   %ebx
  80046c:	ff 30                	pushl  (%eax)
  80046e:	ff d6                	call   *%esi
			break;
  800470:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800476:	e9 04 ff ff ff       	jmp    80037f <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	8d 50 04             	lea    0x4(%eax),%edx
  800481:	89 55 14             	mov    %edx,0x14(%ebp)
  800484:	8b 00                	mov    (%eax),%eax
  800486:	99                   	cltd   
  800487:	31 d0                	xor    %edx,%eax
  800489:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048b:	83 f8 07             	cmp    $0x7,%eax
  80048e:	7f 0b                	jg     80049b <vprintfmt+0x142>
  800490:	8b 14 85 20 10 80 00 	mov    0x801020(,%eax,4),%edx
  800497:	85 d2                	test   %edx,%edx
  800499:	75 18                	jne    8004b3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80049b:	50                   	push   %eax
  80049c:	68 34 0e 80 00       	push   $0x800e34
  8004a1:	53                   	push   %ebx
  8004a2:	56                   	push   %esi
  8004a3:	e8 94 fe ff ff       	call   80033c <printfmt>
  8004a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ae:	e9 cc fe ff ff       	jmp    80037f <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b3:	52                   	push   %edx
  8004b4:	68 3d 0e 80 00       	push   $0x800e3d
  8004b9:	53                   	push   %ebx
  8004ba:	56                   	push   %esi
  8004bb:	e8 7c fe ff ff       	call   80033c <printfmt>
  8004c0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c6:	e9 b4 fe ff ff       	jmp    80037f <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ce:	8d 50 04             	lea    0x4(%eax),%edx
  8004d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004d6:	85 ff                	test   %edi,%edi
  8004d8:	b8 2d 0e 80 00       	mov    $0x800e2d,%eax
  8004dd:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e4:	0f 8e 94 00 00 00    	jle    80057e <vprintfmt+0x225>
  8004ea:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ee:	0f 84 98 00 00 00    	je     80058c <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	ff 75 c8             	pushl  -0x38(%ebp)
  8004fa:	57                   	push   %edi
  8004fb:	e8 c8 02 00 00       	call   8007c8 <strnlen>
  800500:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800503:	29 c1                	sub    %eax,%ecx
  800505:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80050b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80050f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800512:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800515:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800517:	eb 0f                	jmp    800528 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	53                   	push   %ebx
  80051d:	ff 75 e0             	pushl  -0x20(%ebp)
  800520:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800522:	83 ef 01             	sub    $0x1,%edi
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	85 ff                	test   %edi,%edi
  80052a:	7f ed                	jg     800519 <vprintfmt+0x1c0>
  80052c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80052f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800532:	85 c9                	test   %ecx,%ecx
  800534:	b8 00 00 00 00       	mov    $0x0,%eax
  800539:	0f 49 c1             	cmovns %ecx,%eax
  80053c:	29 c1                	sub    %eax,%ecx
  80053e:	89 75 08             	mov    %esi,0x8(%ebp)
  800541:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800544:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800547:	89 cb                	mov    %ecx,%ebx
  800549:	eb 4d                	jmp    800598 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054f:	74 1b                	je     80056c <vprintfmt+0x213>
  800551:	0f be c0             	movsbl %al,%eax
  800554:	83 e8 20             	sub    $0x20,%eax
  800557:	83 f8 5e             	cmp    $0x5e,%eax
  80055a:	76 10                	jbe    80056c <vprintfmt+0x213>
					putch('?', putdat);
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	ff 75 0c             	pushl  0xc(%ebp)
  800562:	6a 3f                	push   $0x3f
  800564:	ff 55 08             	call   *0x8(%ebp)
  800567:	83 c4 10             	add    $0x10,%esp
  80056a:	eb 0d                	jmp    800579 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	ff 75 0c             	pushl  0xc(%ebp)
  800572:	52                   	push   %edx
  800573:	ff 55 08             	call   *0x8(%ebp)
  800576:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800579:	83 eb 01             	sub    $0x1,%ebx
  80057c:	eb 1a                	jmp    800598 <vprintfmt+0x23f>
  80057e:	89 75 08             	mov    %esi,0x8(%ebp)
  800581:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800584:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800587:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058a:	eb 0c                	jmp    800598 <vprintfmt+0x23f>
  80058c:	89 75 08             	mov    %esi,0x8(%ebp)
  80058f:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800592:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800595:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800598:	83 c7 01             	add    $0x1,%edi
  80059b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80059f:	0f be d0             	movsbl %al,%edx
  8005a2:	85 d2                	test   %edx,%edx
  8005a4:	74 23                	je     8005c9 <vprintfmt+0x270>
  8005a6:	85 f6                	test   %esi,%esi
  8005a8:	78 a1                	js     80054b <vprintfmt+0x1f2>
  8005aa:	83 ee 01             	sub    $0x1,%esi
  8005ad:	79 9c                	jns    80054b <vprintfmt+0x1f2>
  8005af:	89 df                	mov    %ebx,%edi
  8005b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b7:	eb 18                	jmp    8005d1 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	53                   	push   %ebx
  8005bd:	6a 20                	push   $0x20
  8005bf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c1:	83 ef 01             	sub    $0x1,%edi
  8005c4:	83 c4 10             	add    $0x10,%esp
  8005c7:	eb 08                	jmp    8005d1 <vprintfmt+0x278>
  8005c9:	89 df                	mov    %ebx,%edi
  8005cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d1:	85 ff                	test   %edi,%edi
  8005d3:	7f e4                	jg     8005b9 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d8:	e9 a2 fd ff ff       	jmp    80037f <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005dd:	83 fa 01             	cmp    $0x1,%edx
  8005e0:	7e 16                	jle    8005f8 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 50 08             	lea    0x8(%eax),%edx
  8005e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005eb:	8b 50 04             	mov    0x4(%eax),%edx
  8005ee:	8b 00                	mov    (%eax),%eax
  8005f0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005f3:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005f6:	eb 32                	jmp    80062a <vprintfmt+0x2d1>
	else if (lflag)
  8005f8:	85 d2                	test   %edx,%edx
  8005fa:	74 18                	je     800614 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 50 04             	lea    0x4(%eax),%edx
  800602:	89 55 14             	mov    %edx,0x14(%ebp)
  800605:	8b 00                	mov    (%eax),%eax
  800607:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80060a:	89 c1                	mov    %eax,%ecx
  80060c:	c1 f9 1f             	sar    $0x1f,%ecx
  80060f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800612:	eb 16                	jmp    80062a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 04             	lea    0x4(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	8b 00                	mov    (%eax),%eax
  80061f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800622:	89 c1                	mov    %eax,%ecx
  800624:	c1 f9 1f             	sar    $0x1f,%ecx
  800627:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80062d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800630:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800633:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800636:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063b:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80063f:	0f 89 a8 00 00 00    	jns    8006ed <vprintfmt+0x394>
				putch('-', putdat);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	53                   	push   %ebx
  800649:	6a 2d                	push   $0x2d
  80064b:	ff d6                	call   *%esi
				num = -(long long) num;
  80064d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800650:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800653:	f7 d8                	neg    %eax
  800655:	83 d2 00             	adc    $0x0,%edx
  800658:	f7 da                	neg    %edx
  80065a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800660:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800663:	b8 0a 00 00 00       	mov    $0xa,%eax
  800668:	e9 80 00 00 00       	jmp    8006ed <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066d:	8d 45 14             	lea    0x14(%ebp),%eax
  800670:	e8 70 fc ff ff       	call   8002e5 <getuint>
  800675:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800678:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80067b:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800680:	eb 6b                	jmp    8006ed <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800682:	8d 45 14             	lea    0x14(%ebp),%eax
  800685:	e8 5b fc ff ff       	call   8002e5 <getuint>
  80068a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800690:	6a 04                	push   $0x4
  800692:	6a 03                	push   $0x3
  800694:	6a 01                	push   $0x1
  800696:	68 40 0e 80 00       	push   $0x800e40
  80069b:	e8 82 fb ff ff       	call   800222 <cprintf>
			goto number;
  8006a0:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  8006a3:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  8006a8:	eb 43                	jmp    8006ed <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  8006aa:	83 ec 08             	sub    $0x8,%esp
  8006ad:	53                   	push   %ebx
  8006ae:	6a 30                	push   $0x30
  8006b0:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b2:	83 c4 08             	add    $0x8,%esp
  8006b5:	53                   	push   %ebx
  8006b6:	6a 78                	push   $0x78
  8006b8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8d 50 04             	lea    0x4(%eax),%edx
  8006c0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006c3:	8b 00                	mov    (%eax),%eax
  8006c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006cd:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006d0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006d3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d8:	eb 13                	jmp    8006ed <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006da:	8d 45 14             	lea    0x14(%ebp),%eax
  8006dd:	e8 03 fc ff ff       	call   8002e5 <getuint>
  8006e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006e8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ed:	83 ec 0c             	sub    $0xc,%esp
  8006f0:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006f4:	52                   	push   %edx
  8006f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f8:	50                   	push   %eax
  8006f9:	ff 75 dc             	pushl  -0x24(%ebp)
  8006fc:	ff 75 d8             	pushl  -0x28(%ebp)
  8006ff:	89 da                	mov    %ebx,%edx
  800701:	89 f0                	mov    %esi,%eax
  800703:	e8 2e fb ff ff       	call   800236 <printnum>

			break;
  800708:	83 c4 20             	add    $0x20,%esp
  80070b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80070e:	e9 6c fc ff ff       	jmp    80037f <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	53                   	push   %ebx
  800717:	51                   	push   %ecx
  800718:	ff d6                	call   *%esi
			break;
  80071a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800720:	e9 5a fc ff ff       	jmp    80037f <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	53                   	push   %ebx
  800729:	6a 25                	push   $0x25
  80072b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072d:	83 c4 10             	add    $0x10,%esp
  800730:	eb 03                	jmp    800735 <vprintfmt+0x3dc>
  800732:	83 ef 01             	sub    $0x1,%edi
  800735:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800739:	75 f7                	jne    800732 <vprintfmt+0x3d9>
  80073b:	e9 3f fc ff ff       	jmp    80037f <vprintfmt+0x26>
			break;
		}

	}

}
  800740:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800743:	5b                   	pop    %ebx
  800744:	5e                   	pop    %esi
  800745:	5f                   	pop    %edi
  800746:	5d                   	pop    %ebp
  800747:	c3                   	ret    

00800748 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	83 ec 18             	sub    $0x18,%esp
  80074e:	8b 45 08             	mov    0x8(%ebp),%eax
  800751:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800754:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800757:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800765:	85 c0                	test   %eax,%eax
  800767:	74 26                	je     80078f <vsnprintf+0x47>
  800769:	85 d2                	test   %edx,%edx
  80076b:	7e 22                	jle    80078f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076d:	ff 75 14             	pushl  0x14(%ebp)
  800770:	ff 75 10             	pushl  0x10(%ebp)
  800773:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800776:	50                   	push   %eax
  800777:	68 1f 03 80 00       	push   $0x80031f
  80077c:	e8 d8 fb ff ff       	call   800359 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800781:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800784:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800787:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078a:	83 c4 10             	add    $0x10,%esp
  80078d:	eb 05                	jmp    800794 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80078f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079f:	50                   	push   %eax
  8007a0:	ff 75 10             	pushl  0x10(%ebp)
  8007a3:	ff 75 0c             	pushl  0xc(%ebp)
  8007a6:	ff 75 08             	pushl  0x8(%ebp)
  8007a9:	e8 9a ff ff ff       	call   800748 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ae:	c9                   	leave  
  8007af:	c3                   	ret    

008007b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	eb 03                	jmp    8007c0 <strlen+0x10>
		n++;
  8007bd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c4:	75 f7                	jne    8007bd <strlen+0xd>
		n++;
	return n;
}
  8007c6:	5d                   	pop    %ebp
  8007c7:	c3                   	ret    

008007c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ce:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d6:	eb 03                	jmp    8007db <strnlen+0x13>
		n++;
  8007d8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007db:	39 c2                	cmp    %eax,%edx
  8007dd:	74 08                	je     8007e7 <strnlen+0x1f>
  8007df:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007e3:	75 f3                	jne    8007d8 <strnlen+0x10>
  8007e5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	53                   	push   %ebx
  8007ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f3:	89 c2                	mov    %eax,%edx
  8007f5:	83 c2 01             	add    $0x1,%edx
  8007f8:	83 c1 01             	add    $0x1,%ecx
  8007fb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ff:	88 5a ff             	mov    %bl,-0x1(%edx)
  800802:	84 db                	test   %bl,%bl
  800804:	75 ef                	jne    8007f5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800806:	5b                   	pop    %ebx
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	53                   	push   %ebx
  80080d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800810:	53                   	push   %ebx
  800811:	e8 9a ff ff ff       	call   8007b0 <strlen>
  800816:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800819:	ff 75 0c             	pushl  0xc(%ebp)
  80081c:	01 d8                	add    %ebx,%eax
  80081e:	50                   	push   %eax
  80081f:	e8 c5 ff ff ff       	call   8007e9 <strcpy>
	return dst;
}
  800824:	89 d8                	mov    %ebx,%eax
  800826:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800829:	c9                   	leave  
  80082a:	c3                   	ret    

0080082b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	56                   	push   %esi
  80082f:	53                   	push   %ebx
  800830:	8b 75 08             	mov    0x8(%ebp),%esi
  800833:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800836:	89 f3                	mov    %esi,%ebx
  800838:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083b:	89 f2                	mov    %esi,%edx
  80083d:	eb 0f                	jmp    80084e <strncpy+0x23>
		*dst++ = *src;
  80083f:	83 c2 01             	add    $0x1,%edx
  800842:	0f b6 01             	movzbl (%ecx),%eax
  800845:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800848:	80 39 01             	cmpb   $0x1,(%ecx)
  80084b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084e:	39 da                	cmp    %ebx,%edx
  800850:	75 ed                	jne    80083f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800852:	89 f0                	mov    %esi,%eax
  800854:	5b                   	pop    %ebx
  800855:	5e                   	pop    %esi
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	56                   	push   %esi
  80085c:	53                   	push   %ebx
  80085d:	8b 75 08             	mov    0x8(%ebp),%esi
  800860:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800863:	8b 55 10             	mov    0x10(%ebp),%edx
  800866:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800868:	85 d2                	test   %edx,%edx
  80086a:	74 21                	je     80088d <strlcpy+0x35>
  80086c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800870:	89 f2                	mov    %esi,%edx
  800872:	eb 09                	jmp    80087d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800874:	83 c2 01             	add    $0x1,%edx
  800877:	83 c1 01             	add    $0x1,%ecx
  80087a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80087d:	39 c2                	cmp    %eax,%edx
  80087f:	74 09                	je     80088a <strlcpy+0x32>
  800881:	0f b6 19             	movzbl (%ecx),%ebx
  800884:	84 db                	test   %bl,%bl
  800886:	75 ec                	jne    800874 <strlcpy+0x1c>
  800888:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80088a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80088d:	29 f0                	sub    %esi,%eax
}
  80088f:	5b                   	pop    %ebx
  800890:	5e                   	pop    %esi
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800899:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089c:	eb 06                	jmp    8008a4 <strcmp+0x11>
		p++, q++;
  80089e:	83 c1 01             	add    $0x1,%ecx
  8008a1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a4:	0f b6 01             	movzbl (%ecx),%eax
  8008a7:	84 c0                	test   %al,%al
  8008a9:	74 04                	je     8008af <strcmp+0x1c>
  8008ab:	3a 02                	cmp    (%edx),%al
  8008ad:	74 ef                	je     80089e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008af:	0f b6 c0             	movzbl %al,%eax
  8008b2:	0f b6 12             	movzbl (%edx),%edx
  8008b5:	29 d0                	sub    %edx,%eax
}
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	53                   	push   %ebx
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c3:	89 c3                	mov    %eax,%ebx
  8008c5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c8:	eb 06                	jmp    8008d0 <strncmp+0x17>
		n--, p++, q++;
  8008ca:	83 c0 01             	add    $0x1,%eax
  8008cd:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d0:	39 d8                	cmp    %ebx,%eax
  8008d2:	74 15                	je     8008e9 <strncmp+0x30>
  8008d4:	0f b6 08             	movzbl (%eax),%ecx
  8008d7:	84 c9                	test   %cl,%cl
  8008d9:	74 04                	je     8008df <strncmp+0x26>
  8008db:	3a 0a                	cmp    (%edx),%cl
  8008dd:	74 eb                	je     8008ca <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008df:	0f b6 00             	movzbl (%eax),%eax
  8008e2:	0f b6 12             	movzbl (%edx),%edx
  8008e5:	29 d0                	sub    %edx,%eax
  8008e7:	eb 05                	jmp    8008ee <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ee:	5b                   	pop    %ebx
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fb:	eb 07                	jmp    800904 <strchr+0x13>
		if (*s == c)
  8008fd:	38 ca                	cmp    %cl,%dl
  8008ff:	74 0f                	je     800910 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800901:	83 c0 01             	add    $0x1,%eax
  800904:	0f b6 10             	movzbl (%eax),%edx
  800907:	84 d2                	test   %dl,%dl
  800909:	75 f2                	jne    8008fd <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091c:	eb 03                	jmp    800921 <strfind+0xf>
  80091e:	83 c0 01             	add    $0x1,%eax
  800921:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800924:	38 ca                	cmp    %cl,%dl
  800926:	74 04                	je     80092c <strfind+0x1a>
  800928:	84 d2                	test   %dl,%dl
  80092a:	75 f2                	jne    80091e <strfind+0xc>
			break;
	return (char *) s;
}
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    

0080092e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	57                   	push   %edi
  800932:	56                   	push   %esi
  800933:	53                   	push   %ebx
  800934:	8b 7d 08             	mov    0x8(%ebp),%edi
  800937:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093a:	85 c9                	test   %ecx,%ecx
  80093c:	74 36                	je     800974 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800944:	75 28                	jne    80096e <memset+0x40>
  800946:	f6 c1 03             	test   $0x3,%cl
  800949:	75 23                	jne    80096e <memset+0x40>
		c &= 0xFF;
  80094b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094f:	89 d3                	mov    %edx,%ebx
  800951:	c1 e3 08             	shl    $0x8,%ebx
  800954:	89 d6                	mov    %edx,%esi
  800956:	c1 e6 18             	shl    $0x18,%esi
  800959:	89 d0                	mov    %edx,%eax
  80095b:	c1 e0 10             	shl    $0x10,%eax
  80095e:	09 f0                	or     %esi,%eax
  800960:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800962:	89 d8                	mov    %ebx,%eax
  800964:	09 d0                	or     %edx,%eax
  800966:	c1 e9 02             	shr    $0x2,%ecx
  800969:	fc                   	cld    
  80096a:	f3 ab                	rep stos %eax,%es:(%edi)
  80096c:	eb 06                	jmp    800974 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800971:	fc                   	cld    
  800972:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800974:	89 f8                	mov    %edi,%eax
  800976:	5b                   	pop    %ebx
  800977:	5e                   	pop    %esi
  800978:	5f                   	pop    %edi
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 75 0c             	mov    0xc(%ebp),%esi
  800986:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800989:	39 c6                	cmp    %eax,%esi
  80098b:	73 35                	jae    8009c2 <memmove+0x47>
  80098d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800990:	39 d0                	cmp    %edx,%eax
  800992:	73 2e                	jae    8009c2 <memmove+0x47>
		s += n;
		d += n;
  800994:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800997:	89 d6                	mov    %edx,%esi
  800999:	09 fe                	or     %edi,%esi
  80099b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a1:	75 13                	jne    8009b6 <memmove+0x3b>
  8009a3:	f6 c1 03             	test   $0x3,%cl
  8009a6:	75 0e                	jne    8009b6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009a8:	83 ef 04             	sub    $0x4,%edi
  8009ab:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ae:	c1 e9 02             	shr    $0x2,%ecx
  8009b1:	fd                   	std    
  8009b2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b4:	eb 09                	jmp    8009bf <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b6:	83 ef 01             	sub    $0x1,%edi
  8009b9:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009bc:	fd                   	std    
  8009bd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009bf:	fc                   	cld    
  8009c0:	eb 1d                	jmp    8009df <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c2:	89 f2                	mov    %esi,%edx
  8009c4:	09 c2                	or     %eax,%edx
  8009c6:	f6 c2 03             	test   $0x3,%dl
  8009c9:	75 0f                	jne    8009da <memmove+0x5f>
  8009cb:	f6 c1 03             	test   $0x3,%cl
  8009ce:	75 0a                	jne    8009da <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d0:	c1 e9 02             	shr    $0x2,%ecx
  8009d3:	89 c7                	mov    %eax,%edi
  8009d5:	fc                   	cld    
  8009d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d8:	eb 05                	jmp    8009df <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009da:	89 c7                	mov    %eax,%edi
  8009dc:	fc                   	cld    
  8009dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009df:	5e                   	pop    %esi
  8009e0:	5f                   	pop    %edi
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e6:	ff 75 10             	pushl  0x10(%ebp)
  8009e9:	ff 75 0c             	pushl  0xc(%ebp)
  8009ec:	ff 75 08             	pushl  0x8(%ebp)
  8009ef:	e8 87 ff ff ff       	call   80097b <memmove>
}
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	56                   	push   %esi
  8009fa:	53                   	push   %ebx
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a01:	89 c6                	mov    %eax,%esi
  800a03:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a06:	eb 1a                	jmp    800a22 <memcmp+0x2c>
		if (*s1 != *s2)
  800a08:	0f b6 08             	movzbl (%eax),%ecx
  800a0b:	0f b6 1a             	movzbl (%edx),%ebx
  800a0e:	38 d9                	cmp    %bl,%cl
  800a10:	74 0a                	je     800a1c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a12:	0f b6 c1             	movzbl %cl,%eax
  800a15:	0f b6 db             	movzbl %bl,%ebx
  800a18:	29 d8                	sub    %ebx,%eax
  800a1a:	eb 0f                	jmp    800a2b <memcmp+0x35>
		s1++, s2++;
  800a1c:	83 c0 01             	add    $0x1,%eax
  800a1f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a22:	39 f0                	cmp    %esi,%eax
  800a24:	75 e2                	jne    800a08 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2b:	5b                   	pop    %ebx
  800a2c:	5e                   	pop    %esi
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	53                   	push   %ebx
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a36:	89 c1                	mov    %eax,%ecx
  800a38:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3f:	eb 0a                	jmp    800a4b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a41:	0f b6 10             	movzbl (%eax),%edx
  800a44:	39 da                	cmp    %ebx,%edx
  800a46:	74 07                	je     800a4f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a48:	83 c0 01             	add    $0x1,%eax
  800a4b:	39 c8                	cmp    %ecx,%eax
  800a4d:	72 f2                	jb     800a41 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a4f:	5b                   	pop    %ebx
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	57                   	push   %edi
  800a56:	56                   	push   %esi
  800a57:	53                   	push   %ebx
  800a58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5e:	eb 03                	jmp    800a63 <strtol+0x11>
		s++;
  800a60:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a63:	0f b6 01             	movzbl (%ecx),%eax
  800a66:	3c 20                	cmp    $0x20,%al
  800a68:	74 f6                	je     800a60 <strtol+0xe>
  800a6a:	3c 09                	cmp    $0x9,%al
  800a6c:	74 f2                	je     800a60 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6e:	3c 2b                	cmp    $0x2b,%al
  800a70:	75 0a                	jne    800a7c <strtol+0x2a>
		s++;
  800a72:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a75:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7a:	eb 11                	jmp    800a8d <strtol+0x3b>
  800a7c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a81:	3c 2d                	cmp    $0x2d,%al
  800a83:	75 08                	jne    800a8d <strtol+0x3b>
		s++, neg = 1;
  800a85:	83 c1 01             	add    $0x1,%ecx
  800a88:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a93:	75 15                	jne    800aaa <strtol+0x58>
  800a95:	80 39 30             	cmpb   $0x30,(%ecx)
  800a98:	75 10                	jne    800aaa <strtol+0x58>
  800a9a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a9e:	75 7c                	jne    800b1c <strtol+0xca>
		s += 2, base = 16;
  800aa0:	83 c1 02             	add    $0x2,%ecx
  800aa3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa8:	eb 16                	jmp    800ac0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aaa:	85 db                	test   %ebx,%ebx
  800aac:	75 12                	jne    800ac0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aae:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab6:	75 08                	jne    800ac0 <strtol+0x6e>
		s++, base = 8;
  800ab8:	83 c1 01             	add    $0x1,%ecx
  800abb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac8:	0f b6 11             	movzbl (%ecx),%edx
  800acb:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ace:	89 f3                	mov    %esi,%ebx
  800ad0:	80 fb 09             	cmp    $0x9,%bl
  800ad3:	77 08                	ja     800add <strtol+0x8b>
			dig = *s - '0';
  800ad5:	0f be d2             	movsbl %dl,%edx
  800ad8:	83 ea 30             	sub    $0x30,%edx
  800adb:	eb 22                	jmp    800aff <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800add:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae0:	89 f3                	mov    %esi,%ebx
  800ae2:	80 fb 19             	cmp    $0x19,%bl
  800ae5:	77 08                	ja     800aef <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ae7:	0f be d2             	movsbl %dl,%edx
  800aea:	83 ea 57             	sub    $0x57,%edx
  800aed:	eb 10                	jmp    800aff <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aef:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af2:	89 f3                	mov    %esi,%ebx
  800af4:	80 fb 19             	cmp    $0x19,%bl
  800af7:	77 16                	ja     800b0f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800af9:	0f be d2             	movsbl %dl,%edx
  800afc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aff:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b02:	7d 0b                	jge    800b0f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b04:	83 c1 01             	add    $0x1,%ecx
  800b07:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b0b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b0d:	eb b9                	jmp    800ac8 <strtol+0x76>

	if (endptr)
  800b0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b13:	74 0d                	je     800b22 <strtol+0xd0>
		*endptr = (char *) s;
  800b15:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b18:	89 0e                	mov    %ecx,(%esi)
  800b1a:	eb 06                	jmp    800b22 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b1c:	85 db                	test   %ebx,%ebx
  800b1e:	74 98                	je     800ab8 <strtol+0x66>
  800b20:	eb 9e                	jmp    800ac0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b22:	89 c2                	mov    %eax,%edx
  800b24:	f7 da                	neg    %edx
  800b26:	85 ff                	test   %edi,%edi
  800b28:	0f 45 c2             	cmovne %edx,%eax
}
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

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
