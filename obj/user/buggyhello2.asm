
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
  800044:	e8 6a 00 00 00       	call   8000b3 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800059:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800060:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  800063:	e8 c9 00 00 00       	call   800131 <sys_getenvid>
  800068:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006d:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800070:	c1 e0 05             	shl    $0x5,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 db                	test   %ebx,%ebx
  80007f:	7e 07                	jle    800088 <libmain+0x3a>
		binaryname = argv[0];
  800081:	8b 06                	mov    (%esi),%eax
  800083:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  800088:	83 ec 08             	sub    $0x8,%esp
  80008b:	56                   	push   %esi
  80008c:	53                   	push   %ebx
  80008d:	e8 a1 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800092:	e8 0a 00 00 00       	call   8000a1 <exit>
}
  800097:	83 c4 10             	add    $0x10,%esp
  80009a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009d:	5b                   	pop    %ebx
  80009e:	5e                   	pop    %esi
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    

008000a1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a7:	6a 00                	push   $0x0
  8000a9:	e8 42 00 00 00       	call   8000f0 <sys_env_destroy>
}
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	c9                   	leave  
  8000b2:	c3                   	ret    

008000b3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	57                   	push   %edi
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c4:	89 c3                	mov    %eax,%ebx
  8000c6:	89 c7                	mov    %eax,%edi
  8000c8:	89 c6                	mov    %eax,%esi
  8000ca:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5f                   	pop    %edi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	57                   	push   %edi
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e1:	89 d1                	mov    %edx,%ecx
  8000e3:	89 d3                	mov    %edx,%ebx
  8000e5:	89 d7                	mov    %edx,%edi
  8000e7:	89 d6                	mov    %edx,%esi
  8000e9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000eb:	5b                   	pop    %ebx
  8000ec:	5e                   	pop    %esi
  8000ed:	5f                   	pop    %edi
  8000ee:	5d                   	pop    %ebp
  8000ef:	c3                   	ret    

008000f0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	57                   	push   %edi
  8000f4:	56                   	push   %esi
  8000f5:	53                   	push   %ebx
  8000f6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fe:	b8 03 00 00 00       	mov    $0x3,%eax
  800103:	8b 55 08             	mov    0x8(%ebp),%edx
  800106:	89 cb                	mov    %ecx,%ebx
  800108:	89 cf                	mov    %ecx,%edi
  80010a:	89 ce                	mov    %ecx,%esi
  80010c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010e:	85 c0                	test   %eax,%eax
  800110:	7e 17                	jle    800129 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800112:	83 ec 0c             	sub    $0xc,%esp
  800115:	50                   	push   %eax
  800116:	6a 03                	push   $0x3
  800118:	68 f8 0d 80 00       	push   $0x800df8
  80011d:	6a 23                	push   $0x23
  80011f:	68 15 0e 80 00       	push   $0x800e15
  800124:	e8 27 00 00 00       	call   800150 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800129:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012c:	5b                   	pop    %ebx
  80012d:	5e                   	pop    %esi
  80012e:	5f                   	pop    %edi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    

00800131 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	57                   	push   %edi
  800135:	56                   	push   %esi
  800136:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800137:	ba 00 00 00 00       	mov    $0x0,%edx
  80013c:	b8 02 00 00 00       	mov    $0x2,%eax
  800141:	89 d1                	mov    %edx,%ecx
  800143:	89 d3                	mov    %edx,%ebx
  800145:	89 d7                	mov    %edx,%edi
  800147:	89 d6                	mov    %edx,%esi
  800149:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014b:	5b                   	pop    %ebx
  80014c:	5e                   	pop    %esi
  80014d:	5f                   	pop    %edi
  80014e:	5d                   	pop    %ebp
  80014f:	c3                   	ret    

00800150 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800155:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800158:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80015e:	e8 ce ff ff ff       	call   800131 <sys_getenvid>
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	ff 75 0c             	pushl  0xc(%ebp)
  800169:	ff 75 08             	pushl  0x8(%ebp)
  80016c:	56                   	push   %esi
  80016d:	50                   	push   %eax
  80016e:	68 24 0e 80 00       	push   $0x800e24
  800173:	e8 b1 00 00 00       	call   800229 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800178:	83 c4 18             	add    $0x18,%esp
  80017b:	53                   	push   %ebx
  80017c:	ff 75 10             	pushl  0x10(%ebp)
  80017f:	e8 54 00 00 00       	call   8001d8 <vcprintf>
	cprintf("\n");
  800184:	c7 04 24 7c 0e 80 00 	movl   $0x800e7c,(%esp)
  80018b:	e8 99 00 00 00       	call   800229 <cprintf>
  800190:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800193:	cc                   	int3   
  800194:	eb fd                	jmp    800193 <_panic+0x43>

00800196 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	53                   	push   %ebx
  80019a:	83 ec 04             	sub    $0x4,%esp
  80019d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a0:	8b 13                	mov    (%ebx),%edx
  8001a2:	8d 42 01             	lea    0x1(%edx),%eax
  8001a5:	89 03                	mov    %eax,(%ebx)
  8001a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b3:	75 1a                	jne    8001cf <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b5:	83 ec 08             	sub    $0x8,%esp
  8001b8:	68 ff 00 00 00       	push   $0xff
  8001bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c0:	50                   	push   %eax
  8001c1:	e8 ed fe ff ff       	call   8000b3 <sys_cputs>
		b->idx = 0;
  8001c6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cc:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e8:	00 00 00 
	b.cnt = 0;
  8001eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f5:	ff 75 0c             	pushl  0xc(%ebp)
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800201:	50                   	push   %eax
  800202:	68 96 01 80 00       	push   $0x800196
  800207:	e8 54 01 00 00       	call   800360 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020c:	83 c4 08             	add    $0x8,%esp
  80020f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800215:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 92 fe ff ff       	call   8000b3 <sys_cputs>

	return b.cnt;
}
  800221:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800232:	50                   	push   %eax
  800233:	ff 75 08             	pushl  0x8(%ebp)
  800236:	e8 9d ff ff ff       	call   8001d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80023b:	c9                   	leave  
  80023c:	c3                   	ret    

0080023d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	57                   	push   %edi
  800241:	56                   	push   %esi
  800242:	53                   	push   %ebx
  800243:	83 ec 1c             	sub    $0x1c,%esp
  800246:	89 c7                	mov    %eax,%edi
  800248:	89 d6                	mov    %edx,%esi
  80024a:	8b 45 08             	mov    0x8(%ebp),%eax
  80024d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800250:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800253:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800256:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800259:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800261:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800264:	39 d3                	cmp    %edx,%ebx
  800266:	72 05                	jb     80026d <printnum+0x30>
  800268:	39 45 10             	cmp    %eax,0x10(%ebp)
  80026b:	77 45                	ja     8002b2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026d:	83 ec 0c             	sub    $0xc,%esp
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	8b 45 14             	mov    0x14(%ebp),%eax
  800276:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800279:	53                   	push   %ebx
  80027a:	ff 75 10             	pushl  0x10(%ebp)
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	ff 75 e4             	pushl  -0x1c(%ebp)
  800283:	ff 75 e0             	pushl  -0x20(%ebp)
  800286:	ff 75 dc             	pushl  -0x24(%ebp)
  800289:	ff 75 d8             	pushl  -0x28(%ebp)
  80028c:	e8 af 08 00 00       	call   800b40 <__udivdi3>
  800291:	83 c4 18             	add    $0x18,%esp
  800294:	52                   	push   %edx
  800295:	50                   	push   %eax
  800296:	89 f2                	mov    %esi,%edx
  800298:	89 f8                	mov    %edi,%eax
  80029a:	e8 9e ff ff ff       	call   80023d <printnum>
  80029f:	83 c4 20             	add    $0x20,%esp
  8002a2:	eb 18                	jmp    8002bc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a4:	83 ec 08             	sub    $0x8,%esp
  8002a7:	56                   	push   %esi
  8002a8:	ff 75 18             	pushl  0x18(%ebp)
  8002ab:	ff d7                	call   *%edi
  8002ad:	83 c4 10             	add    $0x10,%esp
  8002b0:	eb 03                	jmp    8002b5 <printnum+0x78>
  8002b2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b5:	83 eb 01             	sub    $0x1,%ebx
  8002b8:	85 db                	test   %ebx,%ebx
  8002ba:	7f e8                	jg     8002a4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bc:	83 ec 08             	sub    $0x8,%esp
  8002bf:	56                   	push   %esi
  8002c0:	83 ec 04             	sub    $0x4,%esp
  8002c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cf:	e8 9c 09 00 00       	call   800c70 <__umoddi3>
  8002d4:	83 c4 14             	add    $0x14,%esp
  8002d7:	0f be 80 48 0e 80 00 	movsbl 0x800e48(%eax),%eax
  8002de:	50                   	push   %eax
  8002df:	ff d7                	call   *%edi
}
  8002e1:	83 c4 10             	add    $0x10,%esp
  8002e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e7:	5b                   	pop    %ebx
  8002e8:	5e                   	pop    %esi
  8002e9:	5f                   	pop    %edi
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ef:	83 fa 01             	cmp    $0x1,%edx
  8002f2:	7e 0e                	jle    800302 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f4:	8b 10                	mov    (%eax),%edx
  8002f6:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f9:	89 08                	mov    %ecx,(%eax)
  8002fb:	8b 02                	mov    (%edx),%eax
  8002fd:	8b 52 04             	mov    0x4(%edx),%edx
  800300:	eb 22                	jmp    800324 <getuint+0x38>
	else if (lflag)
  800302:	85 d2                	test   %edx,%edx
  800304:	74 10                	je     800316 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800306:	8b 10                	mov    (%eax),%edx
  800308:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030b:	89 08                	mov    %ecx,(%eax)
  80030d:	8b 02                	mov    (%edx),%eax
  80030f:	ba 00 00 00 00       	mov    $0x0,%edx
  800314:	eb 0e                	jmp    800324 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800316:	8b 10                	mov    (%eax),%edx
  800318:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031b:	89 08                	mov    %ecx,(%eax)
  80031d:	8b 02                	mov    (%edx),%eax
  80031f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
  800329:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800330:	8b 10                	mov    (%eax),%edx
  800332:	3b 50 04             	cmp    0x4(%eax),%edx
  800335:	73 0a                	jae    800341 <sprintputch+0x1b>
		*b->buf++ = ch;
  800337:	8d 4a 01             	lea    0x1(%edx),%ecx
  80033a:	89 08                	mov    %ecx,(%eax)
  80033c:	8b 45 08             	mov    0x8(%ebp),%eax
  80033f:	88 02                	mov    %al,(%edx)
}
  800341:	5d                   	pop    %ebp
  800342:	c3                   	ret    

00800343 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800349:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034c:	50                   	push   %eax
  80034d:	ff 75 10             	pushl  0x10(%ebp)
  800350:	ff 75 0c             	pushl  0xc(%ebp)
  800353:	ff 75 08             	pushl  0x8(%ebp)
  800356:	e8 05 00 00 00       	call   800360 <vprintfmt>
	va_end(ap);
}
  80035b:	83 c4 10             	add    $0x10,%esp
  80035e:	c9                   	leave  
  80035f:	c3                   	ret    

00800360 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	57                   	push   %edi
  800364:	56                   	push   %esi
  800365:	53                   	push   %ebx
  800366:	83 ec 2c             	sub    $0x2c,%esp
  800369:	8b 75 08             	mov    0x8(%ebp),%esi
  80036c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800372:	eb 12                	jmp    800386 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800374:	85 c0                	test   %eax,%eax
  800376:	0f 84 cb 03 00 00    	je     800747 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  80037c:	83 ec 08             	sub    $0x8,%esp
  80037f:	53                   	push   %ebx
  800380:	50                   	push   %eax
  800381:	ff d6                	call   *%esi
  800383:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800386:	83 c7 01             	add    $0x1,%edi
  800389:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80038d:	83 f8 25             	cmp    $0x25,%eax
  800390:	75 e2                	jne    800374 <vprintfmt+0x14>
  800392:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800396:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039d:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003a4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b0:	eb 07                	jmp    8003b9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8d 47 01             	lea    0x1(%edi),%eax
  8003bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003bf:	0f b6 07             	movzbl (%edi),%eax
  8003c2:	0f b6 c8             	movzbl %al,%ecx
  8003c5:	83 e8 23             	sub    $0x23,%eax
  8003c8:	3c 55                	cmp    $0x55,%al
  8003ca:	0f 87 5c 03 00 00    	ja     80072c <vprintfmt+0x3cc>
  8003d0:	0f b6 c0             	movzbl %al,%eax
  8003d3:	ff 24 85 00 0f 80 00 	jmp    *0x800f00(,%eax,4)
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003dd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e1:	eb d6                	jmp    8003b9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003eb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ee:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f1:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f5:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f8:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003fb:	83 fa 09             	cmp    $0x9,%edx
  8003fe:	77 39                	ja     800439 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800400:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800403:	eb e9                	jmp    8003ee <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	8d 48 04             	lea    0x4(%eax),%ecx
  80040b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040e:	8b 00                	mov    (%eax),%eax
  800410:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800416:	eb 27                	jmp    80043f <vprintfmt+0xdf>
  800418:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80041b:	85 c0                	test   %eax,%eax
  80041d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800422:	0f 49 c8             	cmovns %eax,%ecx
  800425:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042b:	eb 8c                	jmp    8003b9 <vprintfmt+0x59>
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800430:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800437:	eb 80                	jmp    8003b9 <vprintfmt+0x59>
  800439:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80043c:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80043f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800443:	0f 89 70 ff ff ff    	jns    8003b9 <vprintfmt+0x59>
				width = precision, precision = -1;
  800449:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80044c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800456:	e9 5e ff ff ff       	jmp    8003b9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80045b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800461:	e9 53 ff ff ff       	jmp    8003b9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	8d 50 04             	lea    0x4(%eax),%edx
  80046c:	89 55 14             	mov    %edx,0x14(%ebp)
  80046f:	83 ec 08             	sub    $0x8,%esp
  800472:	53                   	push   %ebx
  800473:	ff 30                	pushl  (%eax)
  800475:	ff d6                	call   *%esi
			break;
  800477:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047d:	e9 04 ff ff ff       	jmp    800386 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800482:	8b 45 14             	mov    0x14(%ebp),%eax
  800485:	8d 50 04             	lea    0x4(%eax),%edx
  800488:	89 55 14             	mov    %edx,0x14(%ebp)
  80048b:	8b 00                	mov    (%eax),%eax
  80048d:	99                   	cltd   
  80048e:	31 d0                	xor    %edx,%eax
  800490:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800492:	83 f8 07             	cmp    $0x7,%eax
  800495:	7f 0b                	jg     8004a2 <vprintfmt+0x142>
  800497:	8b 14 85 60 10 80 00 	mov    0x801060(,%eax,4),%edx
  80049e:	85 d2                	test   %edx,%edx
  8004a0:	75 18                	jne    8004ba <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8004a2:	50                   	push   %eax
  8004a3:	68 60 0e 80 00       	push   $0x800e60
  8004a8:	53                   	push   %ebx
  8004a9:	56                   	push   %esi
  8004aa:	e8 94 fe ff ff       	call   800343 <printfmt>
  8004af:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b5:	e9 cc fe ff ff       	jmp    800386 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004ba:	52                   	push   %edx
  8004bb:	68 69 0e 80 00       	push   $0x800e69
  8004c0:	53                   	push   %ebx
  8004c1:	56                   	push   %esi
  8004c2:	e8 7c fe ff ff       	call   800343 <printfmt>
  8004c7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cd:	e9 b4 fe ff ff       	jmp    800386 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8d 50 04             	lea    0x4(%eax),%edx
  8004d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004db:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004dd:	85 ff                	test   %edi,%edi
  8004df:	b8 59 0e 80 00       	mov    $0x800e59,%eax
  8004e4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004eb:	0f 8e 94 00 00 00    	jle    800585 <vprintfmt+0x225>
  8004f1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f5:	0f 84 98 00 00 00    	je     800593 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	ff 75 c8             	pushl  -0x38(%ebp)
  800501:	57                   	push   %edi
  800502:	e8 c8 02 00 00       	call   8007cf <strnlen>
  800507:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80050a:	29 c1                	sub    %eax,%ecx
  80050c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80050f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800512:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800516:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800519:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80051c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051e:	eb 0f                	jmp    80052f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	53                   	push   %ebx
  800524:	ff 75 e0             	pushl  -0x20(%ebp)
  800527:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800529:	83 ef 01             	sub    $0x1,%edi
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	85 ff                	test   %edi,%edi
  800531:	7f ed                	jg     800520 <vprintfmt+0x1c0>
  800533:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800536:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800539:	85 c9                	test   %ecx,%ecx
  80053b:	b8 00 00 00 00       	mov    $0x0,%eax
  800540:	0f 49 c1             	cmovns %ecx,%eax
  800543:	29 c1                	sub    %eax,%ecx
  800545:	89 75 08             	mov    %esi,0x8(%ebp)
  800548:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80054b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054e:	89 cb                	mov    %ecx,%ebx
  800550:	eb 4d                	jmp    80059f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800552:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800556:	74 1b                	je     800573 <vprintfmt+0x213>
  800558:	0f be c0             	movsbl %al,%eax
  80055b:	83 e8 20             	sub    $0x20,%eax
  80055e:	83 f8 5e             	cmp    $0x5e,%eax
  800561:	76 10                	jbe    800573 <vprintfmt+0x213>
					putch('?', putdat);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	ff 75 0c             	pushl  0xc(%ebp)
  800569:	6a 3f                	push   $0x3f
  80056b:	ff 55 08             	call   *0x8(%ebp)
  80056e:	83 c4 10             	add    $0x10,%esp
  800571:	eb 0d                	jmp    800580 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	ff 75 0c             	pushl  0xc(%ebp)
  800579:	52                   	push   %edx
  80057a:	ff 55 08             	call   *0x8(%ebp)
  80057d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800580:	83 eb 01             	sub    $0x1,%ebx
  800583:	eb 1a                	jmp    80059f <vprintfmt+0x23f>
  800585:	89 75 08             	mov    %esi,0x8(%ebp)
  800588:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80058b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800591:	eb 0c                	jmp    80059f <vprintfmt+0x23f>
  800593:	89 75 08             	mov    %esi,0x8(%ebp)
  800596:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800599:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059f:	83 c7 01             	add    $0x1,%edi
  8005a2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a6:	0f be d0             	movsbl %al,%edx
  8005a9:	85 d2                	test   %edx,%edx
  8005ab:	74 23                	je     8005d0 <vprintfmt+0x270>
  8005ad:	85 f6                	test   %esi,%esi
  8005af:	78 a1                	js     800552 <vprintfmt+0x1f2>
  8005b1:	83 ee 01             	sub    $0x1,%esi
  8005b4:	79 9c                	jns    800552 <vprintfmt+0x1f2>
  8005b6:	89 df                	mov    %ebx,%edi
  8005b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005be:	eb 18                	jmp    8005d8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c0:	83 ec 08             	sub    $0x8,%esp
  8005c3:	53                   	push   %ebx
  8005c4:	6a 20                	push   $0x20
  8005c6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c8:	83 ef 01             	sub    $0x1,%edi
  8005cb:	83 c4 10             	add    $0x10,%esp
  8005ce:	eb 08                	jmp    8005d8 <vprintfmt+0x278>
  8005d0:	89 df                	mov    %ebx,%edi
  8005d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d8:	85 ff                	test   %edi,%edi
  8005da:	7f e4                	jg     8005c0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005df:	e9 a2 fd ff ff       	jmp    800386 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e4:	83 fa 01             	cmp    $0x1,%edx
  8005e7:	7e 16                	jle    8005ff <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8d 50 08             	lea    0x8(%eax),%edx
  8005ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f2:	8b 50 04             	mov    0x4(%eax),%edx
  8005f5:	8b 00                	mov    (%eax),%eax
  8005f7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005fa:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005fd:	eb 32                	jmp    800631 <vprintfmt+0x2d1>
	else if (lflag)
  8005ff:	85 d2                	test   %edx,%edx
  800601:	74 18                	je     80061b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8d 50 04             	lea    0x4(%eax),%edx
  800609:	89 55 14             	mov    %edx,0x14(%ebp)
  80060c:	8b 00                	mov    (%eax),%eax
  80060e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800611:	89 c1                	mov    %eax,%ecx
  800613:	c1 f9 1f             	sar    $0x1f,%ecx
  800616:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800619:	eb 16                	jmp    800631 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 50 04             	lea    0x4(%eax),%edx
  800621:	89 55 14             	mov    %edx,0x14(%ebp)
  800624:	8b 00                	mov    (%eax),%eax
  800626:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800629:	89 c1                	mov    %eax,%ecx
  80062b:	c1 f9 1f             	sar    $0x1f,%ecx
  80062e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800631:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800634:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800637:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063d:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800642:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800646:	0f 89 a8 00 00 00    	jns    8006f4 <vprintfmt+0x394>
				putch('-', putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 2d                	push   $0x2d
  800652:	ff d6                	call   *%esi
				num = -(long long) num;
  800654:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800657:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80065a:	f7 d8                	neg    %eax
  80065c:	83 d2 00             	adc    $0x0,%edx
  80065f:	f7 da                	neg    %edx
  800661:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800664:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800667:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80066a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066f:	e9 80 00 00 00       	jmp    8006f4 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800674:	8d 45 14             	lea    0x14(%ebp),%eax
  800677:	e8 70 fc ff ff       	call   8002ec <getuint>
  80067c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800682:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800687:	eb 6b                	jmp    8006f4 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800689:	8d 45 14             	lea    0x14(%ebp),%eax
  80068c:	e8 5b fc ff ff       	call   8002ec <getuint>
  800691:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800694:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800697:	6a 04                	push   $0x4
  800699:	6a 03                	push   $0x3
  80069b:	6a 01                	push   $0x1
  80069d:	68 6c 0e 80 00       	push   $0x800e6c
  8006a2:	e8 82 fb ff ff       	call   800229 <cprintf>
			goto number;
  8006a7:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  8006aa:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  8006af:	eb 43                	jmp    8006f4 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	6a 30                	push   $0x30
  8006b7:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b9:	83 c4 08             	add    $0x8,%esp
  8006bc:	53                   	push   %ebx
  8006bd:	6a 78                	push   $0x78
  8006bf:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8d 50 04             	lea    0x4(%eax),%edx
  8006c7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ca:	8b 00                	mov    (%eax),%eax
  8006cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8006d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006d7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006da:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006df:	eb 13                	jmp    8006f4 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e4:	e8 03 fc ff ff       	call   8002ec <getuint>
  8006e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006ef:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f4:	83 ec 0c             	sub    $0xc,%esp
  8006f7:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006fb:	52                   	push   %edx
  8006fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ff:	50                   	push   %eax
  800700:	ff 75 dc             	pushl  -0x24(%ebp)
  800703:	ff 75 d8             	pushl  -0x28(%ebp)
  800706:	89 da                	mov    %ebx,%edx
  800708:	89 f0                	mov    %esi,%eax
  80070a:	e8 2e fb ff ff       	call   80023d <printnum>

			break;
  80070f:	83 c4 20             	add    $0x20,%esp
  800712:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800715:	e9 6c fc ff ff       	jmp    800386 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	53                   	push   %ebx
  80071e:	51                   	push   %ecx
  80071f:	ff d6                	call   *%esi
			break;
  800721:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800727:	e9 5a fc ff ff       	jmp    800386 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	53                   	push   %ebx
  800730:	6a 25                	push   $0x25
  800732:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	eb 03                	jmp    80073c <vprintfmt+0x3dc>
  800739:	83 ef 01             	sub    $0x1,%edi
  80073c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800740:	75 f7                	jne    800739 <vprintfmt+0x3d9>
  800742:	e9 3f fc ff ff       	jmp    800386 <vprintfmt+0x26>
			break;
		}

	}

}
  800747:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074a:	5b                   	pop    %ebx
  80074b:	5e                   	pop    %esi
  80074c:	5f                   	pop    %edi
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	83 ec 18             	sub    $0x18,%esp
  800755:	8b 45 08             	mov    0x8(%ebp),%eax
  800758:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800762:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800765:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076c:	85 c0                	test   %eax,%eax
  80076e:	74 26                	je     800796 <vsnprintf+0x47>
  800770:	85 d2                	test   %edx,%edx
  800772:	7e 22                	jle    800796 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800774:	ff 75 14             	pushl  0x14(%ebp)
  800777:	ff 75 10             	pushl  0x10(%ebp)
  80077a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077d:	50                   	push   %eax
  80077e:	68 26 03 80 00       	push   $0x800326
  800783:	e8 d8 fb ff ff       	call   800360 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800788:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800791:	83 c4 10             	add    $0x10,%esp
  800794:	eb 05                	jmp    80079b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800796:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a6:	50                   	push   %eax
  8007a7:	ff 75 10             	pushl  0x10(%ebp)
  8007aa:	ff 75 0c             	pushl  0xc(%ebp)
  8007ad:	ff 75 08             	pushl  0x8(%ebp)
  8007b0:	e8 9a ff ff ff       	call   80074f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c2:	eb 03                	jmp    8007c7 <strlen+0x10>
		n++;
  8007c4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cb:	75 f7                	jne    8007c4 <strlen+0xd>
		n++;
	return n;
}
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007dd:	eb 03                	jmp    8007e2 <strnlen+0x13>
		n++;
  8007df:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e2:	39 c2                	cmp    %eax,%edx
  8007e4:	74 08                	je     8007ee <strnlen+0x1f>
  8007e6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ea:	75 f3                	jne    8007df <strnlen+0x10>
  8007ec:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fa:	89 c2                	mov    %eax,%edx
  8007fc:	83 c2 01             	add    $0x1,%edx
  8007ff:	83 c1 01             	add    $0x1,%ecx
  800802:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800806:	88 5a ff             	mov    %bl,-0x1(%edx)
  800809:	84 db                	test   %bl,%bl
  80080b:	75 ef                	jne    8007fc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80080d:	5b                   	pop    %ebx
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	53                   	push   %ebx
  800814:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800817:	53                   	push   %ebx
  800818:	e8 9a ff ff ff       	call   8007b7 <strlen>
  80081d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800820:	ff 75 0c             	pushl  0xc(%ebp)
  800823:	01 d8                	add    %ebx,%eax
  800825:	50                   	push   %eax
  800826:	e8 c5 ff ff ff       	call   8007f0 <strcpy>
	return dst;
}
  80082b:	89 d8                	mov    %ebx,%eax
  80082d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800830:	c9                   	leave  
  800831:	c3                   	ret    

00800832 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	56                   	push   %esi
  800836:	53                   	push   %ebx
  800837:	8b 75 08             	mov    0x8(%ebp),%esi
  80083a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083d:	89 f3                	mov    %esi,%ebx
  80083f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800842:	89 f2                	mov    %esi,%edx
  800844:	eb 0f                	jmp    800855 <strncpy+0x23>
		*dst++ = *src;
  800846:	83 c2 01             	add    $0x1,%edx
  800849:	0f b6 01             	movzbl (%ecx),%eax
  80084c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084f:	80 39 01             	cmpb   $0x1,(%ecx)
  800852:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800855:	39 da                	cmp    %ebx,%edx
  800857:	75 ed                	jne    800846 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800859:	89 f0                	mov    %esi,%eax
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	8b 75 08             	mov    0x8(%ebp),%esi
  800867:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086a:	8b 55 10             	mov    0x10(%ebp),%edx
  80086d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086f:	85 d2                	test   %edx,%edx
  800871:	74 21                	je     800894 <strlcpy+0x35>
  800873:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800877:	89 f2                	mov    %esi,%edx
  800879:	eb 09                	jmp    800884 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087b:	83 c2 01             	add    $0x1,%edx
  80087e:	83 c1 01             	add    $0x1,%ecx
  800881:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800884:	39 c2                	cmp    %eax,%edx
  800886:	74 09                	je     800891 <strlcpy+0x32>
  800888:	0f b6 19             	movzbl (%ecx),%ebx
  80088b:	84 db                	test   %bl,%bl
  80088d:	75 ec                	jne    80087b <strlcpy+0x1c>
  80088f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800891:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800894:	29 f0                	sub    %esi,%eax
}
  800896:	5b                   	pop    %ebx
  800897:	5e                   	pop    %esi
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a3:	eb 06                	jmp    8008ab <strcmp+0x11>
		p++, q++;
  8008a5:	83 c1 01             	add    $0x1,%ecx
  8008a8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ab:	0f b6 01             	movzbl (%ecx),%eax
  8008ae:	84 c0                	test   %al,%al
  8008b0:	74 04                	je     8008b6 <strcmp+0x1c>
  8008b2:	3a 02                	cmp    (%edx),%al
  8008b4:	74 ef                	je     8008a5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b6:	0f b6 c0             	movzbl %al,%eax
  8008b9:	0f b6 12             	movzbl (%edx),%edx
  8008bc:	29 d0                	sub    %edx,%eax
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	53                   	push   %ebx
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ca:	89 c3                	mov    %eax,%ebx
  8008cc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008cf:	eb 06                	jmp    8008d7 <strncmp+0x17>
		n--, p++, q++;
  8008d1:	83 c0 01             	add    $0x1,%eax
  8008d4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d7:	39 d8                	cmp    %ebx,%eax
  8008d9:	74 15                	je     8008f0 <strncmp+0x30>
  8008db:	0f b6 08             	movzbl (%eax),%ecx
  8008de:	84 c9                	test   %cl,%cl
  8008e0:	74 04                	je     8008e6 <strncmp+0x26>
  8008e2:	3a 0a                	cmp    (%edx),%cl
  8008e4:	74 eb                	je     8008d1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e6:	0f b6 00             	movzbl (%eax),%eax
  8008e9:	0f b6 12             	movzbl (%edx),%edx
  8008ec:	29 d0                	sub    %edx,%eax
  8008ee:	eb 05                	jmp    8008f5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f5:	5b                   	pop    %ebx
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800902:	eb 07                	jmp    80090b <strchr+0x13>
		if (*s == c)
  800904:	38 ca                	cmp    %cl,%dl
  800906:	74 0f                	je     800917 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800908:	83 c0 01             	add    $0x1,%eax
  80090b:	0f b6 10             	movzbl (%eax),%edx
  80090e:	84 d2                	test   %dl,%dl
  800910:	75 f2                	jne    800904 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800912:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800923:	eb 03                	jmp    800928 <strfind+0xf>
  800925:	83 c0 01             	add    $0x1,%eax
  800928:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092b:	38 ca                	cmp    %cl,%dl
  80092d:	74 04                	je     800933 <strfind+0x1a>
  80092f:	84 d2                	test   %dl,%dl
  800931:	75 f2                	jne    800925 <strfind+0xc>
			break;
	return (char *) s;
}
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	57                   	push   %edi
  800939:	56                   	push   %esi
  80093a:	53                   	push   %ebx
  80093b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800941:	85 c9                	test   %ecx,%ecx
  800943:	74 36                	je     80097b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800945:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094b:	75 28                	jne    800975 <memset+0x40>
  80094d:	f6 c1 03             	test   $0x3,%cl
  800950:	75 23                	jne    800975 <memset+0x40>
		c &= 0xFF;
  800952:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800956:	89 d3                	mov    %edx,%ebx
  800958:	c1 e3 08             	shl    $0x8,%ebx
  80095b:	89 d6                	mov    %edx,%esi
  80095d:	c1 e6 18             	shl    $0x18,%esi
  800960:	89 d0                	mov    %edx,%eax
  800962:	c1 e0 10             	shl    $0x10,%eax
  800965:	09 f0                	or     %esi,%eax
  800967:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800969:	89 d8                	mov    %ebx,%eax
  80096b:	09 d0                	or     %edx,%eax
  80096d:	c1 e9 02             	shr    $0x2,%ecx
  800970:	fc                   	cld    
  800971:	f3 ab                	rep stos %eax,%es:(%edi)
  800973:	eb 06                	jmp    80097b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800975:	8b 45 0c             	mov    0xc(%ebp),%eax
  800978:	fc                   	cld    
  800979:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097b:	89 f8                	mov    %edi,%eax
  80097d:	5b                   	pop    %ebx
  80097e:	5e                   	pop    %esi
  80097f:	5f                   	pop    %edi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	57                   	push   %edi
  800986:	56                   	push   %esi
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800990:	39 c6                	cmp    %eax,%esi
  800992:	73 35                	jae    8009c9 <memmove+0x47>
  800994:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800997:	39 d0                	cmp    %edx,%eax
  800999:	73 2e                	jae    8009c9 <memmove+0x47>
		s += n;
		d += n;
  80099b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099e:	89 d6                	mov    %edx,%esi
  8009a0:	09 fe                	or     %edi,%esi
  8009a2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a8:	75 13                	jne    8009bd <memmove+0x3b>
  8009aa:	f6 c1 03             	test   $0x3,%cl
  8009ad:	75 0e                	jne    8009bd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009af:	83 ef 04             	sub    $0x4,%edi
  8009b2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b5:	c1 e9 02             	shr    $0x2,%ecx
  8009b8:	fd                   	std    
  8009b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bb:	eb 09                	jmp    8009c6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009bd:	83 ef 01             	sub    $0x1,%edi
  8009c0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c3:	fd                   	std    
  8009c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c6:	fc                   	cld    
  8009c7:	eb 1d                	jmp    8009e6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c9:	89 f2                	mov    %esi,%edx
  8009cb:	09 c2                	or     %eax,%edx
  8009cd:	f6 c2 03             	test   $0x3,%dl
  8009d0:	75 0f                	jne    8009e1 <memmove+0x5f>
  8009d2:	f6 c1 03             	test   $0x3,%cl
  8009d5:	75 0a                	jne    8009e1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d7:	c1 e9 02             	shr    $0x2,%ecx
  8009da:	89 c7                	mov    %eax,%edi
  8009dc:	fc                   	cld    
  8009dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009df:	eb 05                	jmp    8009e6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e1:	89 c7                	mov    %eax,%edi
  8009e3:	fc                   	cld    
  8009e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e6:	5e                   	pop    %esi
  8009e7:	5f                   	pop    %edi
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ed:	ff 75 10             	pushl  0x10(%ebp)
  8009f0:	ff 75 0c             	pushl  0xc(%ebp)
  8009f3:	ff 75 08             	pushl  0x8(%ebp)
  8009f6:	e8 87 ff ff ff       	call   800982 <memmove>
}
  8009fb:	c9                   	leave  
  8009fc:	c3                   	ret    

008009fd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a08:	89 c6                	mov    %eax,%esi
  800a0a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0d:	eb 1a                	jmp    800a29 <memcmp+0x2c>
		if (*s1 != *s2)
  800a0f:	0f b6 08             	movzbl (%eax),%ecx
  800a12:	0f b6 1a             	movzbl (%edx),%ebx
  800a15:	38 d9                	cmp    %bl,%cl
  800a17:	74 0a                	je     800a23 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a19:	0f b6 c1             	movzbl %cl,%eax
  800a1c:	0f b6 db             	movzbl %bl,%ebx
  800a1f:	29 d8                	sub    %ebx,%eax
  800a21:	eb 0f                	jmp    800a32 <memcmp+0x35>
		s1++, s2++;
  800a23:	83 c0 01             	add    $0x1,%eax
  800a26:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a29:	39 f0                	cmp    %esi,%eax
  800a2b:	75 e2                	jne    800a0f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a32:	5b                   	pop    %ebx
  800a33:	5e                   	pop    %esi
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	53                   	push   %ebx
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a3d:	89 c1                	mov    %eax,%ecx
  800a3f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a42:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a46:	eb 0a                	jmp    800a52 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a48:	0f b6 10             	movzbl (%eax),%edx
  800a4b:	39 da                	cmp    %ebx,%edx
  800a4d:	74 07                	je     800a56 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4f:	83 c0 01             	add    $0x1,%eax
  800a52:	39 c8                	cmp    %ecx,%eax
  800a54:	72 f2                	jb     800a48 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a56:	5b                   	pop    %ebx
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	57                   	push   %edi
  800a5d:	56                   	push   %esi
  800a5e:	53                   	push   %ebx
  800a5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a65:	eb 03                	jmp    800a6a <strtol+0x11>
		s++;
  800a67:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6a:	0f b6 01             	movzbl (%ecx),%eax
  800a6d:	3c 20                	cmp    $0x20,%al
  800a6f:	74 f6                	je     800a67 <strtol+0xe>
  800a71:	3c 09                	cmp    $0x9,%al
  800a73:	74 f2                	je     800a67 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a75:	3c 2b                	cmp    $0x2b,%al
  800a77:	75 0a                	jne    800a83 <strtol+0x2a>
		s++;
  800a79:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a81:	eb 11                	jmp    800a94 <strtol+0x3b>
  800a83:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a88:	3c 2d                	cmp    $0x2d,%al
  800a8a:	75 08                	jne    800a94 <strtol+0x3b>
		s++, neg = 1;
  800a8c:	83 c1 01             	add    $0x1,%ecx
  800a8f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a94:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9a:	75 15                	jne    800ab1 <strtol+0x58>
  800a9c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9f:	75 10                	jne    800ab1 <strtol+0x58>
  800aa1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa5:	75 7c                	jne    800b23 <strtol+0xca>
		s += 2, base = 16;
  800aa7:	83 c1 02             	add    $0x2,%ecx
  800aaa:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aaf:	eb 16                	jmp    800ac7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab1:	85 db                	test   %ebx,%ebx
  800ab3:	75 12                	jne    800ac7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aba:	80 39 30             	cmpb   $0x30,(%ecx)
  800abd:	75 08                	jne    800ac7 <strtol+0x6e>
		s++, base = 8;
  800abf:	83 c1 01             	add    $0x1,%ecx
  800ac2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac7:	b8 00 00 00 00       	mov    $0x0,%eax
  800acc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800acf:	0f b6 11             	movzbl (%ecx),%edx
  800ad2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad5:	89 f3                	mov    %esi,%ebx
  800ad7:	80 fb 09             	cmp    $0x9,%bl
  800ada:	77 08                	ja     800ae4 <strtol+0x8b>
			dig = *s - '0';
  800adc:	0f be d2             	movsbl %dl,%edx
  800adf:	83 ea 30             	sub    $0x30,%edx
  800ae2:	eb 22                	jmp    800b06 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae7:	89 f3                	mov    %esi,%ebx
  800ae9:	80 fb 19             	cmp    $0x19,%bl
  800aec:	77 08                	ja     800af6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aee:	0f be d2             	movsbl %dl,%edx
  800af1:	83 ea 57             	sub    $0x57,%edx
  800af4:	eb 10                	jmp    800b06 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af9:	89 f3                	mov    %esi,%ebx
  800afb:	80 fb 19             	cmp    $0x19,%bl
  800afe:	77 16                	ja     800b16 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b00:	0f be d2             	movsbl %dl,%edx
  800b03:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b06:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b09:	7d 0b                	jge    800b16 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b0b:	83 c1 01             	add    $0x1,%ecx
  800b0e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b12:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b14:	eb b9                	jmp    800acf <strtol+0x76>

	if (endptr)
  800b16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1a:	74 0d                	je     800b29 <strtol+0xd0>
		*endptr = (char *) s;
  800b1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1f:	89 0e                	mov    %ecx,(%esi)
  800b21:	eb 06                	jmp    800b29 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b23:	85 db                	test   %ebx,%ebx
  800b25:	74 98                	je     800abf <strtol+0x66>
  800b27:	eb 9e                	jmp    800ac7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b29:	89 c2                	mov    %eax,%edx
  800b2b:	f7 da                	neg    %edx
  800b2d:	85 ff                	test   %edi,%edi
  800b2f:	0f 45 c2             	cmovne %edx,%eax
}
  800b32:	5b                   	pop    %ebx
  800b33:	5e                   	pop    %esi
  800b34:	5f                   	pop    %edi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    
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
