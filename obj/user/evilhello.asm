
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
  800040:	e8 4d 00 00 00       	call   800092 <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	83 ec 08             	sub    $0x8,%esp
  800050:	8b 45 08             	mov    0x8(%ebp),%eax
  800053:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800056:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80005d:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 c0                	test   %eax,%eax
  800062:	7e 08                	jle    80006c <libmain+0x22>
		binaryname = argv[0];
  800064:	8b 0a                	mov    (%edx),%ecx
  800066:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  80006c:	83 ec 08             	sub    $0x8,%esp
  80006f:	52                   	push   %edx
  800070:	50                   	push   %eax
  800071:	e8 bd ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800076:	e8 05 00 00 00       	call   800080 <exit>
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800086:	6a 00                	push   $0x0
  800088:	e8 42 00 00 00       	call   8000cf <sys_env_destroy>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	57                   	push   %edi
  800096:	56                   	push   %esi
  800097:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800098:	b8 00 00 00 00       	mov    $0x0,%eax
  80009d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a3:	89 c3                	mov    %eax,%ebx
  8000a5:	89 c7                	mov    %eax,%edi
  8000a7:	89 c6                	mov    %eax,%esi
  8000a9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5f                   	pop    %edi
  8000ae:	5d                   	pop    %ebp
  8000af:	c3                   	ret    

008000b0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c0:	89 d1                	mov    %edx,%ecx
  8000c2:	89 d3                	mov    %edx,%ebx
  8000c4:	89 d7                	mov    %edx,%edi
  8000c6:	89 d6                	mov    %edx,%esi
  8000c8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
  8000d5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dd:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e5:	89 cb                	mov    %ecx,%ebx
  8000e7:	89 cf                	mov    %ecx,%edi
  8000e9:	89 ce                	mov    %ecx,%esi
  8000eb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	7e 17                	jle    800108 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f1:	83 ec 0c             	sub    $0xc,%esp
  8000f4:	50                   	push   %eax
  8000f5:	6a 03                	push   $0x3
  8000f7:	68 ca 0d 80 00       	push   $0x800dca
  8000fc:	6a 23                	push   $0x23
  8000fe:	68 e7 0d 80 00       	push   $0x800de7
  800103:	e8 27 00 00 00       	call   80012f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010b:	5b                   	pop    %ebx
  80010c:	5e                   	pop    %esi
  80010d:	5f                   	pop    %edi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	57                   	push   %edi
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800116:	ba 00 00 00 00       	mov    $0x0,%edx
  80011b:	b8 02 00 00 00       	mov    $0x2,%eax
  800120:	89 d1                	mov    %edx,%ecx
  800122:	89 d3                	mov    %edx,%ebx
  800124:	89 d7                	mov    %edx,%edi
  800126:	89 d6                	mov    %edx,%esi
  800128:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800134:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800137:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80013d:	e8 ce ff ff ff       	call   800110 <sys_getenvid>
  800142:	83 ec 0c             	sub    $0xc,%esp
  800145:	ff 75 0c             	pushl  0xc(%ebp)
  800148:	ff 75 08             	pushl  0x8(%ebp)
  80014b:	56                   	push   %esi
  80014c:	50                   	push   %eax
  80014d:	68 f8 0d 80 00       	push   $0x800df8
  800152:	e8 b1 00 00 00       	call   800208 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800157:	83 c4 18             	add    $0x18,%esp
  80015a:	53                   	push   %ebx
  80015b:	ff 75 10             	pushl  0x10(%ebp)
  80015e:	e8 54 00 00 00       	call   8001b7 <vcprintf>
	cprintf("\n");
  800163:	c7 04 24 50 0e 80 00 	movl   $0x800e50,(%esp)
  80016a:	e8 99 00 00 00       	call   800208 <cprintf>
  80016f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800172:	cc                   	int3   
  800173:	eb fd                	jmp    800172 <_panic+0x43>

00800175 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	53                   	push   %ebx
  800179:	83 ec 04             	sub    $0x4,%esp
  80017c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017f:	8b 13                	mov    (%ebx),%edx
  800181:	8d 42 01             	lea    0x1(%edx),%eax
  800184:	89 03                	mov    %eax,(%ebx)
  800186:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800189:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800192:	75 1a                	jne    8001ae <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800194:	83 ec 08             	sub    $0x8,%esp
  800197:	68 ff 00 00 00       	push   $0xff
  80019c:	8d 43 08             	lea    0x8(%ebx),%eax
  80019f:	50                   	push   %eax
  8001a0:	e8 ed fe ff ff       	call   800092 <sys_cputs>
		b->idx = 0;
  8001a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ab:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ae:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b5:	c9                   	leave  
  8001b6:	c3                   	ret    

008001b7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c7:	00 00 00 
	b.cnt = 0;
  8001ca:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d4:	ff 75 0c             	pushl  0xc(%ebp)
  8001d7:	ff 75 08             	pushl  0x8(%ebp)
  8001da:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	68 75 01 80 00       	push   $0x800175
  8001e6:	e8 54 01 00 00       	call   80033f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001eb:	83 c4 08             	add    $0x8,%esp
  8001ee:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 92 fe ff ff       	call   800092 <sys_cputs>

	return b.cnt;
}
  800200:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800206:	c9                   	leave  
  800207:	c3                   	ret    

00800208 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800211:	50                   	push   %eax
  800212:	ff 75 08             	pushl  0x8(%ebp)
  800215:	e8 9d ff ff ff       	call   8001b7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 1c             	sub    $0x1c,%esp
  800225:	89 c7                	mov    %eax,%edi
  800227:	89 d6                	mov    %edx,%esi
  800229:	8b 45 08             	mov    0x8(%ebp),%eax
  80022c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800232:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800235:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800240:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800243:	39 d3                	cmp    %edx,%ebx
  800245:	72 05                	jb     80024c <printnum+0x30>
  800247:	39 45 10             	cmp    %eax,0x10(%ebp)
  80024a:	77 45                	ja     800291 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	ff 75 18             	pushl  0x18(%ebp)
  800252:	8b 45 14             	mov    0x14(%ebp),%eax
  800255:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800258:	53                   	push   %ebx
  800259:	ff 75 10             	pushl  0x10(%ebp)
  80025c:	83 ec 08             	sub    $0x8,%esp
  80025f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800262:	ff 75 e0             	pushl  -0x20(%ebp)
  800265:	ff 75 dc             	pushl  -0x24(%ebp)
  800268:	ff 75 d8             	pushl  -0x28(%ebp)
  80026b:	e8 b0 08 00 00       	call   800b20 <__udivdi3>
  800270:	83 c4 18             	add    $0x18,%esp
  800273:	52                   	push   %edx
  800274:	50                   	push   %eax
  800275:	89 f2                	mov    %esi,%edx
  800277:	89 f8                	mov    %edi,%eax
  800279:	e8 9e ff ff ff       	call   80021c <printnum>
  80027e:	83 c4 20             	add    $0x20,%esp
  800281:	eb 18                	jmp    80029b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800283:	83 ec 08             	sub    $0x8,%esp
  800286:	56                   	push   %esi
  800287:	ff 75 18             	pushl  0x18(%ebp)
  80028a:	ff d7                	call   *%edi
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	eb 03                	jmp    800294 <printnum+0x78>
  800291:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800294:	83 eb 01             	sub    $0x1,%ebx
  800297:	85 db                	test   %ebx,%ebx
  800299:	7f e8                	jg     800283 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	56                   	push   %esi
  80029f:	83 ec 04             	sub    $0x4,%esp
  8002a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ae:	e8 9d 09 00 00       	call   800c50 <__umoddi3>
  8002b3:	83 c4 14             	add    $0x14,%esp
  8002b6:	0f be 80 1c 0e 80 00 	movsbl 0x800e1c(%eax),%eax
  8002bd:	50                   	push   %eax
  8002be:	ff d7                	call   *%edi
}
  8002c0:	83 c4 10             	add    $0x10,%esp
  8002c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5e                   	pop    %esi
  8002c8:	5f                   	pop    %edi
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    

008002cb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ce:	83 fa 01             	cmp    $0x1,%edx
  8002d1:	7e 0e                	jle    8002e1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d8:	89 08                	mov    %ecx,(%eax)
  8002da:	8b 02                	mov    (%edx),%eax
  8002dc:	8b 52 04             	mov    0x4(%edx),%edx
  8002df:	eb 22                	jmp    800303 <getuint+0x38>
	else if (lflag)
  8002e1:	85 d2                	test   %edx,%edx
  8002e3:	74 10                	je     8002f5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e5:	8b 10                	mov    (%eax),%edx
  8002e7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ea:	89 08                	mov    %ecx,(%eax)
  8002ec:	8b 02                	mov    (%edx),%eax
  8002ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f3:	eb 0e                	jmp    800303 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fa:	89 08                	mov    %ecx,(%eax)
  8002fc:	8b 02                	mov    (%edx),%eax
  8002fe:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80030b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030f:	8b 10                	mov    (%eax),%edx
  800311:	3b 50 04             	cmp    0x4(%eax),%edx
  800314:	73 0a                	jae    800320 <sprintputch+0x1b>
		*b->buf++ = ch;
  800316:	8d 4a 01             	lea    0x1(%edx),%ecx
  800319:	89 08                	mov    %ecx,(%eax)
  80031b:	8b 45 08             	mov    0x8(%ebp),%eax
  80031e:	88 02                	mov    %al,(%edx)
}
  800320:	5d                   	pop    %ebp
  800321:	c3                   	ret    

00800322 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800328:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80032b:	50                   	push   %eax
  80032c:	ff 75 10             	pushl  0x10(%ebp)
  80032f:	ff 75 0c             	pushl  0xc(%ebp)
  800332:	ff 75 08             	pushl  0x8(%ebp)
  800335:	e8 05 00 00 00       	call   80033f <vprintfmt>
	va_end(ap);
}
  80033a:	83 c4 10             	add    $0x10,%esp
  80033d:	c9                   	leave  
  80033e:	c3                   	ret    

0080033f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	57                   	push   %edi
  800343:	56                   	push   %esi
  800344:	53                   	push   %ebx
  800345:	83 ec 2c             	sub    $0x2c,%esp
  800348:	8b 75 08             	mov    0x8(%ebp),%esi
  80034b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80034e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800351:	eb 12                	jmp    800365 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800353:	85 c0                	test   %eax,%eax
  800355:	0f 84 cb 03 00 00    	je     800726 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  80035b:	83 ec 08             	sub    $0x8,%esp
  80035e:	53                   	push   %ebx
  80035f:	50                   	push   %eax
  800360:	ff d6                	call   *%esi
  800362:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800365:	83 c7 01             	add    $0x1,%edi
  800368:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80036c:	83 f8 25             	cmp    $0x25,%eax
  80036f:	75 e2                	jne    800353 <vprintfmt+0x14>
  800371:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800375:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80037c:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800383:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80038a:	ba 00 00 00 00       	mov    $0x0,%edx
  80038f:	eb 07                	jmp    800398 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800394:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8d 47 01             	lea    0x1(%edi),%eax
  80039b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039e:	0f b6 07             	movzbl (%edi),%eax
  8003a1:	0f b6 c8             	movzbl %al,%ecx
  8003a4:	83 e8 23             	sub    $0x23,%eax
  8003a7:	3c 55                	cmp    $0x55,%al
  8003a9:	0f 87 5c 03 00 00    	ja     80070b <vprintfmt+0x3cc>
  8003af:	0f b6 c0             	movzbl %al,%eax
  8003b2:	ff 24 85 c0 0e 80 00 	jmp    *0x800ec0(,%eax,4)
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003bc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003c0:	eb d6                	jmp    800398 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ca:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003cd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003d0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003d4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003d7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003da:	83 fa 09             	cmp    $0x9,%edx
  8003dd:	77 39                	ja     800418 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003df:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003e2:	eb e9                	jmp    8003cd <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e7:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ea:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003ed:	8b 00                	mov    (%eax),%eax
  8003ef:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003f5:	eb 27                	jmp    80041e <vprintfmt+0xdf>
  8003f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003fa:	85 c0                	test   %eax,%eax
  8003fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800401:	0f 49 c8             	cmovns %eax,%ecx
  800404:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040a:	eb 8c                	jmp    800398 <vprintfmt+0x59>
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80040f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800416:	eb 80                	jmp    800398 <vprintfmt+0x59>
  800418:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80041b:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80041e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800422:	0f 89 70 ff ff ff    	jns    800398 <vprintfmt+0x59>
				width = precision, precision = -1;
  800428:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80042b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042e:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800435:	e9 5e ff ff ff       	jmp    800398 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80043a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800440:	e9 53 ff ff ff       	jmp    800398 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800445:	8b 45 14             	mov    0x14(%ebp),%eax
  800448:	8d 50 04             	lea    0x4(%eax),%edx
  80044b:	89 55 14             	mov    %edx,0x14(%ebp)
  80044e:	83 ec 08             	sub    $0x8,%esp
  800451:	53                   	push   %ebx
  800452:	ff 30                	pushl  (%eax)
  800454:	ff d6                	call   *%esi
			break;
  800456:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80045c:	e9 04 ff ff ff       	jmp    800365 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800461:	8b 45 14             	mov    0x14(%ebp),%eax
  800464:	8d 50 04             	lea    0x4(%eax),%edx
  800467:	89 55 14             	mov    %edx,0x14(%ebp)
  80046a:	8b 00                	mov    (%eax),%eax
  80046c:	99                   	cltd   
  80046d:	31 d0                	xor    %edx,%eax
  80046f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800471:	83 f8 07             	cmp    $0x7,%eax
  800474:	7f 0b                	jg     800481 <vprintfmt+0x142>
  800476:	8b 14 85 20 10 80 00 	mov    0x801020(,%eax,4),%edx
  80047d:	85 d2                	test   %edx,%edx
  80047f:	75 18                	jne    800499 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800481:	50                   	push   %eax
  800482:	68 34 0e 80 00       	push   $0x800e34
  800487:	53                   	push   %ebx
  800488:	56                   	push   %esi
  800489:	e8 94 fe ff ff       	call   800322 <printfmt>
  80048e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800494:	e9 cc fe ff ff       	jmp    800365 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800499:	52                   	push   %edx
  80049a:	68 3d 0e 80 00       	push   $0x800e3d
  80049f:	53                   	push   %ebx
  8004a0:	56                   	push   %esi
  8004a1:	e8 7c fe ff ff       	call   800322 <printfmt>
  8004a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ac:	e9 b4 fe ff ff       	jmp    800365 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8d 50 04             	lea    0x4(%eax),%edx
  8004b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ba:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004bc:	85 ff                	test   %edi,%edi
  8004be:	b8 2d 0e 80 00       	mov    $0x800e2d,%eax
  8004c3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ca:	0f 8e 94 00 00 00    	jle    800564 <vprintfmt+0x225>
  8004d0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004d4:	0f 84 98 00 00 00    	je     800572 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	ff 75 c8             	pushl  -0x38(%ebp)
  8004e0:	57                   	push   %edi
  8004e1:	e8 c8 02 00 00       	call   8007ae <strnlen>
  8004e6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e9:	29 c1                	sub    %eax,%ecx
  8004eb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004ee:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004f1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004fb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fd:	eb 0f                	jmp    80050e <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	53                   	push   %ebx
  800503:	ff 75 e0             	pushl  -0x20(%ebp)
  800506:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800508:	83 ef 01             	sub    $0x1,%edi
  80050b:	83 c4 10             	add    $0x10,%esp
  80050e:	85 ff                	test   %edi,%edi
  800510:	7f ed                	jg     8004ff <vprintfmt+0x1c0>
  800512:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800515:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800518:	85 c9                	test   %ecx,%ecx
  80051a:	b8 00 00 00 00       	mov    $0x0,%eax
  80051f:	0f 49 c1             	cmovns %ecx,%eax
  800522:	29 c1                	sub    %eax,%ecx
  800524:	89 75 08             	mov    %esi,0x8(%ebp)
  800527:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80052a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80052d:	89 cb                	mov    %ecx,%ebx
  80052f:	eb 4d                	jmp    80057e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800531:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800535:	74 1b                	je     800552 <vprintfmt+0x213>
  800537:	0f be c0             	movsbl %al,%eax
  80053a:	83 e8 20             	sub    $0x20,%eax
  80053d:	83 f8 5e             	cmp    $0x5e,%eax
  800540:	76 10                	jbe    800552 <vprintfmt+0x213>
					putch('?', putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	ff 75 0c             	pushl  0xc(%ebp)
  800548:	6a 3f                	push   $0x3f
  80054a:	ff 55 08             	call   *0x8(%ebp)
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	eb 0d                	jmp    80055f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	ff 75 0c             	pushl  0xc(%ebp)
  800558:	52                   	push   %edx
  800559:	ff 55 08             	call   *0x8(%ebp)
  80055c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055f:	83 eb 01             	sub    $0x1,%ebx
  800562:	eb 1a                	jmp    80057e <vprintfmt+0x23f>
  800564:	89 75 08             	mov    %esi,0x8(%ebp)
  800567:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80056a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800570:	eb 0c                	jmp    80057e <vprintfmt+0x23f>
  800572:	89 75 08             	mov    %esi,0x8(%ebp)
  800575:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800578:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80057b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057e:	83 c7 01             	add    $0x1,%edi
  800581:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800585:	0f be d0             	movsbl %al,%edx
  800588:	85 d2                	test   %edx,%edx
  80058a:	74 23                	je     8005af <vprintfmt+0x270>
  80058c:	85 f6                	test   %esi,%esi
  80058e:	78 a1                	js     800531 <vprintfmt+0x1f2>
  800590:	83 ee 01             	sub    $0x1,%esi
  800593:	79 9c                	jns    800531 <vprintfmt+0x1f2>
  800595:	89 df                	mov    %ebx,%edi
  800597:	8b 75 08             	mov    0x8(%ebp),%esi
  80059a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80059d:	eb 18                	jmp    8005b7 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059f:	83 ec 08             	sub    $0x8,%esp
  8005a2:	53                   	push   %ebx
  8005a3:	6a 20                	push   $0x20
  8005a5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a7:	83 ef 01             	sub    $0x1,%edi
  8005aa:	83 c4 10             	add    $0x10,%esp
  8005ad:	eb 08                	jmp    8005b7 <vprintfmt+0x278>
  8005af:	89 df                	mov    %ebx,%edi
  8005b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b7:	85 ff                	test   %edi,%edi
  8005b9:	7f e4                	jg     80059f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005be:	e9 a2 fd ff ff       	jmp    800365 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c3:	83 fa 01             	cmp    $0x1,%edx
  8005c6:	7e 16                	jle    8005de <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 50 08             	lea    0x8(%eax),%edx
  8005ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d1:	8b 50 04             	mov    0x4(%eax),%edx
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005d9:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005dc:	eb 32                	jmp    800610 <vprintfmt+0x2d1>
	else if (lflag)
  8005de:	85 d2                	test   %edx,%edx
  8005e0:	74 18                	je     8005fa <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 50 04             	lea    0x4(%eax),%edx
  8005e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005eb:	8b 00                	mov    (%eax),%eax
  8005ed:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005f0:	89 c1                	mov    %eax,%ecx
  8005f2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005f8:	eb 16                	jmp    800610 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 50 04             	lea    0x4(%eax),%edx
  800600:	89 55 14             	mov    %edx,0x14(%ebp)
  800603:	8b 00                	mov    (%eax),%eax
  800605:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800608:	89 c1                	mov    %eax,%ecx
  80060a:	c1 f9 1f             	sar    $0x1f,%ecx
  80060d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800610:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800613:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800616:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800619:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80061c:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800621:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800625:	0f 89 a8 00 00 00    	jns    8006d3 <vprintfmt+0x394>
				putch('-', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	6a 2d                	push   $0x2d
  800631:	ff d6                	call   *%esi
				num = -(long long) num;
  800633:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800636:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800639:	f7 d8                	neg    %eax
  80063b:	83 d2 00             	adc    $0x0,%edx
  80063e:	f7 da                	neg    %edx
  800640:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800643:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800646:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800649:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064e:	e9 80 00 00 00       	jmp    8006d3 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	e8 70 fc ff ff       	call   8002cb <getuint>
  80065b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800661:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800666:	eb 6b                	jmp    8006d3 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800668:	8d 45 14             	lea    0x14(%ebp),%eax
  80066b:	e8 5b fc ff ff       	call   8002cb <getuint>
  800670:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800673:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800676:	6a 04                	push   $0x4
  800678:	6a 03                	push   $0x3
  80067a:	6a 01                	push   $0x1
  80067c:	68 40 0e 80 00       	push   $0x800e40
  800681:	e8 82 fb ff ff       	call   800208 <cprintf>
			goto number;
  800686:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  800689:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  80068e:	eb 43                	jmp    8006d3 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	53                   	push   %ebx
  800694:	6a 30                	push   $0x30
  800696:	ff d6                	call   *%esi
			putch('x', putdat);
  800698:	83 c4 08             	add    $0x8,%esp
  80069b:	53                   	push   %ebx
  80069c:	6a 78                	push   $0x78
  80069e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 04             	lea    0x4(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a9:	8b 00                	mov    (%eax),%eax
  8006ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006be:	eb 13                	jmp    8006d3 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c3:	e8 03 fc ff ff       	call   8002cb <getuint>
  8006c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006cb:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006ce:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d3:	83 ec 0c             	sub    $0xc,%esp
  8006d6:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006da:	52                   	push   %edx
  8006db:	ff 75 e0             	pushl  -0x20(%ebp)
  8006de:	50                   	push   %eax
  8006df:	ff 75 dc             	pushl  -0x24(%ebp)
  8006e2:	ff 75 d8             	pushl  -0x28(%ebp)
  8006e5:	89 da                	mov    %ebx,%edx
  8006e7:	89 f0                	mov    %esi,%eax
  8006e9:	e8 2e fb ff ff       	call   80021c <printnum>

			break;
  8006ee:	83 c4 20             	add    $0x20,%esp
  8006f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f4:	e9 6c fc ff ff       	jmp    800365 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	53                   	push   %ebx
  8006fd:	51                   	push   %ecx
  8006fe:	ff d6                	call   *%esi
			break;
  800700:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800703:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800706:	e9 5a fc ff ff       	jmp    800365 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	53                   	push   %ebx
  80070f:	6a 25                	push   $0x25
  800711:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	eb 03                	jmp    80071b <vprintfmt+0x3dc>
  800718:	83 ef 01             	sub    $0x1,%edi
  80071b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80071f:	75 f7                	jne    800718 <vprintfmt+0x3d9>
  800721:	e9 3f fc ff ff       	jmp    800365 <vprintfmt+0x26>
			break;
		}

	}

}
  800726:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800729:	5b                   	pop    %ebx
  80072a:	5e                   	pop    %esi
  80072b:	5f                   	pop    %edi
  80072c:	5d                   	pop    %ebp
  80072d:	c3                   	ret    

0080072e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072e:	55                   	push   %ebp
  80072f:	89 e5                	mov    %esp,%ebp
  800731:	83 ec 18             	sub    $0x18,%esp
  800734:	8b 45 08             	mov    0x8(%ebp),%eax
  800737:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800741:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800744:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074b:	85 c0                	test   %eax,%eax
  80074d:	74 26                	je     800775 <vsnprintf+0x47>
  80074f:	85 d2                	test   %edx,%edx
  800751:	7e 22                	jle    800775 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800753:	ff 75 14             	pushl  0x14(%ebp)
  800756:	ff 75 10             	pushl  0x10(%ebp)
  800759:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80075c:	50                   	push   %eax
  80075d:	68 05 03 80 00       	push   $0x800305
  800762:	e8 d8 fb ff ff       	call   80033f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800767:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800770:	83 c4 10             	add    $0x10,%esp
  800773:	eb 05                	jmp    80077a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800775:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    

0080077c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800782:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800785:	50                   	push   %eax
  800786:	ff 75 10             	pushl  0x10(%ebp)
  800789:	ff 75 0c             	pushl  0xc(%ebp)
  80078c:	ff 75 08             	pushl  0x8(%ebp)
  80078f:	e8 9a ff ff ff       	call   80072e <vsnprintf>
	va_end(ap);

	return rc;
}
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079c:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a1:	eb 03                	jmp    8007a6 <strlen+0x10>
		n++;
  8007a3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007aa:	75 f7                	jne    8007a3 <strlen+0xd>
		n++;
	return n;
}
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    

008007ae <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8007bc:	eb 03                	jmp    8007c1 <strnlen+0x13>
		n++;
  8007be:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c1:	39 c2                	cmp    %eax,%edx
  8007c3:	74 08                	je     8007cd <strnlen+0x1f>
  8007c5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007c9:	75 f3                	jne    8007be <strnlen+0x10>
  8007cb:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	53                   	push   %ebx
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d9:	89 c2                	mov    %eax,%edx
  8007db:	83 c2 01             	add    $0x1,%edx
  8007de:	83 c1 01             	add    $0x1,%ecx
  8007e1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007e5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e8:	84 db                	test   %bl,%bl
  8007ea:	75 ef                	jne    8007db <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007ec:	5b                   	pop    %ebx
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	53                   	push   %ebx
  8007f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f6:	53                   	push   %ebx
  8007f7:	e8 9a ff ff ff       	call   800796 <strlen>
  8007fc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007ff:	ff 75 0c             	pushl  0xc(%ebp)
  800802:	01 d8                	add    %ebx,%eax
  800804:	50                   	push   %eax
  800805:	e8 c5 ff ff ff       	call   8007cf <strcpy>
	return dst;
}
  80080a:	89 d8                	mov    %ebx,%eax
  80080c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080f:	c9                   	leave  
  800810:	c3                   	ret    

00800811 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	56                   	push   %esi
  800815:	53                   	push   %ebx
  800816:	8b 75 08             	mov    0x8(%ebp),%esi
  800819:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081c:	89 f3                	mov    %esi,%ebx
  80081e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800821:	89 f2                	mov    %esi,%edx
  800823:	eb 0f                	jmp    800834 <strncpy+0x23>
		*dst++ = *src;
  800825:	83 c2 01             	add    $0x1,%edx
  800828:	0f b6 01             	movzbl (%ecx),%eax
  80082b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80082e:	80 39 01             	cmpb   $0x1,(%ecx)
  800831:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800834:	39 da                	cmp    %ebx,%edx
  800836:	75 ed                	jne    800825 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800838:	89 f0                	mov    %esi,%eax
  80083a:	5b                   	pop    %ebx
  80083b:	5e                   	pop    %esi
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	56                   	push   %esi
  800842:	53                   	push   %ebx
  800843:	8b 75 08             	mov    0x8(%ebp),%esi
  800846:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800849:	8b 55 10             	mov    0x10(%ebp),%edx
  80084c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084e:	85 d2                	test   %edx,%edx
  800850:	74 21                	je     800873 <strlcpy+0x35>
  800852:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800856:	89 f2                	mov    %esi,%edx
  800858:	eb 09                	jmp    800863 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80085a:	83 c2 01             	add    $0x1,%edx
  80085d:	83 c1 01             	add    $0x1,%ecx
  800860:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800863:	39 c2                	cmp    %eax,%edx
  800865:	74 09                	je     800870 <strlcpy+0x32>
  800867:	0f b6 19             	movzbl (%ecx),%ebx
  80086a:	84 db                	test   %bl,%bl
  80086c:	75 ec                	jne    80085a <strlcpy+0x1c>
  80086e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800870:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800873:	29 f0                	sub    %esi,%eax
}
  800875:	5b                   	pop    %ebx
  800876:	5e                   	pop    %esi
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800882:	eb 06                	jmp    80088a <strcmp+0x11>
		p++, q++;
  800884:	83 c1 01             	add    $0x1,%ecx
  800887:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80088a:	0f b6 01             	movzbl (%ecx),%eax
  80088d:	84 c0                	test   %al,%al
  80088f:	74 04                	je     800895 <strcmp+0x1c>
  800891:	3a 02                	cmp    (%edx),%al
  800893:	74 ef                	je     800884 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800895:	0f b6 c0             	movzbl %al,%eax
  800898:	0f b6 12             	movzbl (%edx),%edx
  80089b:	29 d0                	sub    %edx,%eax
}
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	53                   	push   %ebx
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a9:	89 c3                	mov    %eax,%ebx
  8008ab:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ae:	eb 06                	jmp    8008b6 <strncmp+0x17>
		n--, p++, q++;
  8008b0:	83 c0 01             	add    $0x1,%eax
  8008b3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b6:	39 d8                	cmp    %ebx,%eax
  8008b8:	74 15                	je     8008cf <strncmp+0x30>
  8008ba:	0f b6 08             	movzbl (%eax),%ecx
  8008bd:	84 c9                	test   %cl,%cl
  8008bf:	74 04                	je     8008c5 <strncmp+0x26>
  8008c1:	3a 0a                	cmp    (%edx),%cl
  8008c3:	74 eb                	je     8008b0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c5:	0f b6 00             	movzbl (%eax),%eax
  8008c8:	0f b6 12             	movzbl (%edx),%edx
  8008cb:	29 d0                	sub    %edx,%eax
  8008cd:	eb 05                	jmp    8008d4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d4:	5b                   	pop    %ebx
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e1:	eb 07                	jmp    8008ea <strchr+0x13>
		if (*s == c)
  8008e3:	38 ca                	cmp    %cl,%dl
  8008e5:	74 0f                	je     8008f6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e7:	83 c0 01             	add    $0x1,%eax
  8008ea:	0f b6 10             	movzbl (%eax),%edx
  8008ed:	84 d2                	test   %dl,%dl
  8008ef:	75 f2                	jne    8008e3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800902:	eb 03                	jmp    800907 <strfind+0xf>
  800904:	83 c0 01             	add    $0x1,%eax
  800907:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090a:	38 ca                	cmp    %cl,%dl
  80090c:	74 04                	je     800912 <strfind+0x1a>
  80090e:	84 d2                	test   %dl,%dl
  800910:	75 f2                	jne    800904 <strfind+0xc>
			break;
	return (char *) s;
}
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	57                   	push   %edi
  800918:	56                   	push   %esi
  800919:	53                   	push   %ebx
  80091a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800920:	85 c9                	test   %ecx,%ecx
  800922:	74 36                	je     80095a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800924:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092a:	75 28                	jne    800954 <memset+0x40>
  80092c:	f6 c1 03             	test   $0x3,%cl
  80092f:	75 23                	jne    800954 <memset+0x40>
		c &= 0xFF;
  800931:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800935:	89 d3                	mov    %edx,%ebx
  800937:	c1 e3 08             	shl    $0x8,%ebx
  80093a:	89 d6                	mov    %edx,%esi
  80093c:	c1 e6 18             	shl    $0x18,%esi
  80093f:	89 d0                	mov    %edx,%eax
  800941:	c1 e0 10             	shl    $0x10,%eax
  800944:	09 f0                	or     %esi,%eax
  800946:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800948:	89 d8                	mov    %ebx,%eax
  80094a:	09 d0                	or     %edx,%eax
  80094c:	c1 e9 02             	shr    $0x2,%ecx
  80094f:	fc                   	cld    
  800950:	f3 ab                	rep stos %eax,%es:(%edi)
  800952:	eb 06                	jmp    80095a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800954:	8b 45 0c             	mov    0xc(%ebp),%eax
  800957:	fc                   	cld    
  800958:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095a:	89 f8                	mov    %edi,%eax
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5f                   	pop    %edi
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	57                   	push   %edi
  800965:	56                   	push   %esi
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096f:	39 c6                	cmp    %eax,%esi
  800971:	73 35                	jae    8009a8 <memmove+0x47>
  800973:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800976:	39 d0                	cmp    %edx,%eax
  800978:	73 2e                	jae    8009a8 <memmove+0x47>
		s += n;
		d += n;
  80097a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097d:	89 d6                	mov    %edx,%esi
  80097f:	09 fe                	or     %edi,%esi
  800981:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800987:	75 13                	jne    80099c <memmove+0x3b>
  800989:	f6 c1 03             	test   $0x3,%cl
  80098c:	75 0e                	jne    80099c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80098e:	83 ef 04             	sub    $0x4,%edi
  800991:	8d 72 fc             	lea    -0x4(%edx),%esi
  800994:	c1 e9 02             	shr    $0x2,%ecx
  800997:	fd                   	std    
  800998:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099a:	eb 09                	jmp    8009a5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80099c:	83 ef 01             	sub    $0x1,%edi
  80099f:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009a2:	fd                   	std    
  8009a3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a5:	fc                   	cld    
  8009a6:	eb 1d                	jmp    8009c5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a8:	89 f2                	mov    %esi,%edx
  8009aa:	09 c2                	or     %eax,%edx
  8009ac:	f6 c2 03             	test   $0x3,%dl
  8009af:	75 0f                	jne    8009c0 <memmove+0x5f>
  8009b1:	f6 c1 03             	test   $0x3,%cl
  8009b4:	75 0a                	jne    8009c0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009b6:	c1 e9 02             	shr    $0x2,%ecx
  8009b9:	89 c7                	mov    %eax,%edi
  8009bb:	fc                   	cld    
  8009bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009be:	eb 05                	jmp    8009c5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c0:	89 c7                	mov    %eax,%edi
  8009c2:	fc                   	cld    
  8009c3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c5:	5e                   	pop    %esi
  8009c6:	5f                   	pop    %edi
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009cc:	ff 75 10             	pushl  0x10(%ebp)
  8009cf:	ff 75 0c             	pushl  0xc(%ebp)
  8009d2:	ff 75 08             	pushl  0x8(%ebp)
  8009d5:	e8 87 ff ff ff       	call   800961 <memmove>
}
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	56                   	push   %esi
  8009e0:	53                   	push   %ebx
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e7:	89 c6                	mov    %eax,%esi
  8009e9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ec:	eb 1a                	jmp    800a08 <memcmp+0x2c>
		if (*s1 != *s2)
  8009ee:	0f b6 08             	movzbl (%eax),%ecx
  8009f1:	0f b6 1a             	movzbl (%edx),%ebx
  8009f4:	38 d9                	cmp    %bl,%cl
  8009f6:	74 0a                	je     800a02 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009f8:	0f b6 c1             	movzbl %cl,%eax
  8009fb:	0f b6 db             	movzbl %bl,%ebx
  8009fe:	29 d8                	sub    %ebx,%eax
  800a00:	eb 0f                	jmp    800a11 <memcmp+0x35>
		s1++, s2++;
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a08:	39 f0                	cmp    %esi,%eax
  800a0a:	75 e2                	jne    8009ee <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	53                   	push   %ebx
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a1c:	89 c1                	mov    %eax,%ecx
  800a1e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a21:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a25:	eb 0a                	jmp    800a31 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a27:	0f b6 10             	movzbl (%eax),%edx
  800a2a:	39 da                	cmp    %ebx,%edx
  800a2c:	74 07                	je     800a35 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2e:	83 c0 01             	add    $0x1,%eax
  800a31:	39 c8                	cmp    %ecx,%eax
  800a33:	72 f2                	jb     800a27 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a35:	5b                   	pop    %ebx
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	57                   	push   %edi
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
  800a3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a44:	eb 03                	jmp    800a49 <strtol+0x11>
		s++;
  800a46:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a49:	0f b6 01             	movzbl (%ecx),%eax
  800a4c:	3c 20                	cmp    $0x20,%al
  800a4e:	74 f6                	je     800a46 <strtol+0xe>
  800a50:	3c 09                	cmp    $0x9,%al
  800a52:	74 f2                	je     800a46 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a54:	3c 2b                	cmp    $0x2b,%al
  800a56:	75 0a                	jne    800a62 <strtol+0x2a>
		s++;
  800a58:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a5b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a60:	eb 11                	jmp    800a73 <strtol+0x3b>
  800a62:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a67:	3c 2d                	cmp    $0x2d,%al
  800a69:	75 08                	jne    800a73 <strtol+0x3b>
		s++, neg = 1;
  800a6b:	83 c1 01             	add    $0x1,%ecx
  800a6e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a73:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a79:	75 15                	jne    800a90 <strtol+0x58>
  800a7b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a7e:	75 10                	jne    800a90 <strtol+0x58>
  800a80:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a84:	75 7c                	jne    800b02 <strtol+0xca>
		s += 2, base = 16;
  800a86:	83 c1 02             	add    $0x2,%ecx
  800a89:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8e:	eb 16                	jmp    800aa6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a90:	85 db                	test   %ebx,%ebx
  800a92:	75 12                	jne    800aa6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a94:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a99:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9c:	75 08                	jne    800aa6 <strtol+0x6e>
		s++, base = 8;
  800a9e:	83 c1 01             	add    $0x1,%ecx
  800aa1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aab:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aae:	0f b6 11             	movzbl (%ecx),%edx
  800ab1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	80 fb 09             	cmp    $0x9,%bl
  800ab9:	77 08                	ja     800ac3 <strtol+0x8b>
			dig = *s - '0';
  800abb:	0f be d2             	movsbl %dl,%edx
  800abe:	83 ea 30             	sub    $0x30,%edx
  800ac1:	eb 22                	jmp    800ae5 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ac3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ac6:	89 f3                	mov    %esi,%ebx
  800ac8:	80 fb 19             	cmp    $0x19,%bl
  800acb:	77 08                	ja     800ad5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800acd:	0f be d2             	movsbl %dl,%edx
  800ad0:	83 ea 57             	sub    $0x57,%edx
  800ad3:	eb 10                	jmp    800ae5 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ad5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ad8:	89 f3                	mov    %esi,%ebx
  800ada:	80 fb 19             	cmp    $0x19,%bl
  800add:	77 16                	ja     800af5 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800adf:	0f be d2             	movsbl %dl,%edx
  800ae2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ae5:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae8:	7d 0b                	jge    800af5 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800aea:	83 c1 01             	add    $0x1,%ecx
  800aed:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af1:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800af3:	eb b9                	jmp    800aae <strtol+0x76>

	if (endptr)
  800af5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af9:	74 0d                	je     800b08 <strtol+0xd0>
		*endptr = (char *) s;
  800afb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afe:	89 0e                	mov    %ecx,(%esi)
  800b00:	eb 06                	jmp    800b08 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b02:	85 db                	test   %ebx,%ebx
  800b04:	74 98                	je     800a9e <strtol+0x66>
  800b06:	eb 9e                	jmp    800aa6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b08:	89 c2                	mov    %eax,%edx
  800b0a:	f7 da                	neg    %edx
  800b0c:	85 ff                	test   %edi,%edi
  800b0e:	0f 45 c2             	cmovne %edx,%eax
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    
  800b16:	66 90                	xchg   %ax,%ax
  800b18:	66 90                	xchg   %ax,%ax
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
