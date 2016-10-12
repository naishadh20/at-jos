
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
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	83 ec 08             	sub    $0x8,%esp
  800044:	8b 45 08             	mov    0x8(%ebp),%eax
  800047:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800051:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800054:	85 c0                	test   %eax,%eax
  800056:	7e 08                	jle    800060 <libmain+0x22>
		binaryname = argv[0];
  800058:	8b 0a                	mov    (%edx),%ecx
  80005a:	89 0d 00 20 80 00    	mov    %ecx,0x802000

	// call user main routine
	umain(argc, argv);
  800060:	83 ec 08             	sub    $0x8,%esp
  800063:	52                   	push   %edx
  800064:	50                   	push   %eax
  800065:	e8 c9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80006a:	e8 05 00 00 00       	call   800074 <exit>
}
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	c9                   	leave  
  800073:	c3                   	ret    

00800074 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80007a:	6a 00                	push   $0x0
  80007c:	e8 42 00 00 00       	call   8000c3 <sys_env_destroy>
}
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	c9                   	leave  
  800085:	c3                   	ret    

00800086 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800086:	55                   	push   %ebp
  800087:	89 e5                	mov    %esp,%ebp
  800089:	57                   	push   %edi
  80008a:	56                   	push   %esi
  80008b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80008c:	b8 00 00 00 00       	mov    $0x0,%eax
  800091:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800094:	8b 55 08             	mov    0x8(%ebp),%edx
  800097:	89 c3                	mov    %eax,%ebx
  800099:	89 c7                	mov    %eax,%edi
  80009b:	89 c6                	mov    %eax,%esi
  80009d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80009f:	5b                   	pop    %ebx
  8000a0:	5e                   	pop    %esi
  8000a1:	5f                   	pop    %edi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	57                   	push   %edi
  8000a8:	56                   	push   %esi
  8000a9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8000af:	b8 01 00 00 00       	mov    $0x1,%eax
  8000b4:	89 d1                	mov    %edx,%ecx
  8000b6:	89 d3                	mov    %edx,%ebx
  8000b8:	89 d7                	mov    %edx,%edi
  8000ba:	89 d6                	mov    %edx,%esi
  8000bc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000be:	5b                   	pop    %ebx
  8000bf:	5e                   	pop    %esi
  8000c0:	5f                   	pop    %edi
  8000c1:	5d                   	pop    %ebp
  8000c2:	c3                   	ret    

008000c3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	57                   	push   %edi
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
  8000c9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d9:	89 cb                	mov    %ecx,%ebx
  8000db:	89 cf                	mov    %ecx,%edi
  8000dd:	89 ce                	mov    %ecx,%esi
  8000df:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	7e 17                	jle    8000fc <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	50                   	push   %eax
  8000e9:	6a 03                	push   $0x3
  8000eb:	68 aa 0d 80 00       	push   $0x800daa
  8000f0:	6a 23                	push   $0x23
  8000f2:	68 c7 0d 80 00       	push   $0x800dc7
  8000f7:	e8 27 00 00 00       	call   800123 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ff:	5b                   	pop    %ebx
  800100:	5e                   	pop    %esi
  800101:	5f                   	pop    %edi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	57                   	push   %edi
  800108:	56                   	push   %esi
  800109:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010a:	ba 00 00 00 00       	mov    $0x0,%edx
  80010f:	b8 02 00 00 00       	mov    $0x2,%eax
  800114:	89 d1                	mov    %edx,%ecx
  800116:	89 d3                	mov    %edx,%ebx
  800118:	89 d7                	mov    %edx,%edi
  80011a:	89 d6                	mov    %edx,%esi
  80011c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5f                   	pop    %edi
  800121:	5d                   	pop    %ebp
  800122:	c3                   	ret    

00800123 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	56                   	push   %esi
  800127:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800128:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80012b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800131:	e8 ce ff ff ff       	call   800104 <sys_getenvid>
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	ff 75 0c             	pushl  0xc(%ebp)
  80013c:	ff 75 08             	pushl  0x8(%ebp)
  80013f:	56                   	push   %esi
  800140:	50                   	push   %eax
  800141:	68 d8 0d 80 00       	push   $0x800dd8
  800146:	e8 b1 00 00 00       	call   8001fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80014b:	83 c4 18             	add    $0x18,%esp
  80014e:	53                   	push   %ebx
  80014f:	ff 75 10             	pushl  0x10(%ebp)
  800152:	e8 54 00 00 00       	call   8001ab <vcprintf>
	cprintf("\n");
  800157:	c7 04 24 30 0e 80 00 	movl   $0x800e30,(%esp)
  80015e:	e8 99 00 00 00       	call   8001fc <cprintf>
  800163:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800166:	cc                   	int3   
  800167:	eb fd                	jmp    800166 <_panic+0x43>

00800169 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	53                   	push   %ebx
  80016d:	83 ec 04             	sub    $0x4,%esp
  800170:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800173:	8b 13                	mov    (%ebx),%edx
  800175:	8d 42 01             	lea    0x1(%edx),%eax
  800178:	89 03                	mov    %eax,(%ebx)
  80017a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800181:	3d ff 00 00 00       	cmp    $0xff,%eax
  800186:	75 1a                	jne    8001a2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800188:	83 ec 08             	sub    $0x8,%esp
  80018b:	68 ff 00 00 00       	push   $0xff
  800190:	8d 43 08             	lea    0x8(%ebx),%eax
  800193:	50                   	push   %eax
  800194:	e8 ed fe ff ff       	call   800086 <sys_cputs>
		b->idx = 0;
  800199:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a9:	c9                   	leave  
  8001aa:	c3                   	ret    

008001ab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bb:	00 00 00 
	b.cnt = 0;
  8001be:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c8:	ff 75 0c             	pushl  0xc(%ebp)
  8001cb:	ff 75 08             	pushl  0x8(%ebp)
  8001ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d4:	50                   	push   %eax
  8001d5:	68 69 01 80 00       	push   $0x800169
  8001da:	e8 54 01 00 00       	call   800333 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001df:	83 c4 08             	add    $0x8,%esp
  8001e2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ee:	50                   	push   %eax
  8001ef:	e8 92 fe ff ff       	call   800086 <sys_cputs>

	return b.cnt;
}
  8001f4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800202:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800205:	50                   	push   %eax
  800206:	ff 75 08             	pushl  0x8(%ebp)
  800209:	e8 9d ff ff ff       	call   8001ab <vcprintf>
	va_end(ap);

	return cnt;
}
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	83 ec 1c             	sub    $0x1c,%esp
  800219:	89 c7                	mov    %eax,%edi
  80021b:	89 d6                	mov    %edx,%esi
  80021d:	8b 45 08             	mov    0x8(%ebp),%eax
  800220:	8b 55 0c             	mov    0xc(%ebp),%edx
  800223:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800226:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800229:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80022c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800231:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800234:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800237:	39 d3                	cmp    %edx,%ebx
  800239:	72 05                	jb     800240 <printnum+0x30>
  80023b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023e:	77 45                	ja     800285 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	ff 75 18             	pushl  0x18(%ebp)
  800246:	8b 45 14             	mov    0x14(%ebp),%eax
  800249:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80024c:	53                   	push   %ebx
  80024d:	ff 75 10             	pushl  0x10(%ebp)
  800250:	83 ec 08             	sub    $0x8,%esp
  800253:	ff 75 e4             	pushl  -0x1c(%ebp)
  800256:	ff 75 e0             	pushl  -0x20(%ebp)
  800259:	ff 75 dc             	pushl  -0x24(%ebp)
  80025c:	ff 75 d8             	pushl  -0x28(%ebp)
  80025f:	e8 ac 08 00 00       	call   800b10 <__udivdi3>
  800264:	83 c4 18             	add    $0x18,%esp
  800267:	52                   	push   %edx
  800268:	50                   	push   %eax
  800269:	89 f2                	mov    %esi,%edx
  80026b:	89 f8                	mov    %edi,%eax
  80026d:	e8 9e ff ff ff       	call   800210 <printnum>
  800272:	83 c4 20             	add    $0x20,%esp
  800275:	eb 18                	jmp    80028f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800277:	83 ec 08             	sub    $0x8,%esp
  80027a:	56                   	push   %esi
  80027b:	ff 75 18             	pushl  0x18(%ebp)
  80027e:	ff d7                	call   *%edi
  800280:	83 c4 10             	add    $0x10,%esp
  800283:	eb 03                	jmp    800288 <printnum+0x78>
  800285:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800288:	83 eb 01             	sub    $0x1,%ebx
  80028b:	85 db                	test   %ebx,%ebx
  80028d:	7f e8                	jg     800277 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028f:	83 ec 08             	sub    $0x8,%esp
  800292:	56                   	push   %esi
  800293:	83 ec 04             	sub    $0x4,%esp
  800296:	ff 75 e4             	pushl  -0x1c(%ebp)
  800299:	ff 75 e0             	pushl  -0x20(%ebp)
  80029c:	ff 75 dc             	pushl  -0x24(%ebp)
  80029f:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a2:	e8 99 09 00 00       	call   800c40 <__umoddi3>
  8002a7:	83 c4 14             	add    $0x14,%esp
  8002aa:	0f be 80 fc 0d 80 00 	movsbl 0x800dfc(%eax),%eax
  8002b1:	50                   	push   %eax
  8002b2:	ff d7                	call   *%edi
}
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ba:	5b                   	pop    %ebx
  8002bb:	5e                   	pop    %esi
  8002bc:	5f                   	pop    %edi
  8002bd:	5d                   	pop    %ebp
  8002be:	c3                   	ret    

008002bf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c2:	83 fa 01             	cmp    $0x1,%edx
  8002c5:	7e 0e                	jle    8002d5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c7:	8b 10                	mov    (%eax),%edx
  8002c9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002cc:	89 08                	mov    %ecx,(%eax)
  8002ce:	8b 02                	mov    (%edx),%eax
  8002d0:	8b 52 04             	mov    0x4(%edx),%edx
  8002d3:	eb 22                	jmp    8002f7 <getuint+0x38>
	else if (lflag)
  8002d5:	85 d2                	test   %edx,%edx
  8002d7:	74 10                	je     8002e9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d9:	8b 10                	mov    (%eax),%edx
  8002db:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002de:	89 08                	mov    %ecx,(%eax)
  8002e0:	8b 02                	mov    (%edx),%eax
  8002e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e7:	eb 0e                	jmp    8002f7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ee:	89 08                	mov    %ecx,(%eax)
  8002f0:	8b 02                	mov    (%edx),%eax
  8002f2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f7:	5d                   	pop    %ebp
  8002f8:	c3                   	ret    

008002f9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ff:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800303:	8b 10                	mov    (%eax),%edx
  800305:	3b 50 04             	cmp    0x4(%eax),%edx
  800308:	73 0a                	jae    800314 <sprintputch+0x1b>
		*b->buf++ = ch;
  80030a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030d:	89 08                	mov    %ecx,(%eax)
  80030f:	8b 45 08             	mov    0x8(%ebp),%eax
  800312:	88 02                	mov    %al,(%edx)
}
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80031c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031f:	50                   	push   %eax
  800320:	ff 75 10             	pushl  0x10(%ebp)
  800323:	ff 75 0c             	pushl  0xc(%ebp)
  800326:	ff 75 08             	pushl  0x8(%ebp)
  800329:	e8 05 00 00 00       	call   800333 <vprintfmt>
	va_end(ap);
}
  80032e:	83 c4 10             	add    $0x10,%esp
  800331:	c9                   	leave  
  800332:	c3                   	ret    

00800333 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	57                   	push   %edi
  800337:	56                   	push   %esi
  800338:	53                   	push   %ebx
  800339:	83 ec 2c             	sub    $0x2c,%esp
  80033c:	8b 75 08             	mov    0x8(%ebp),%esi
  80033f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800342:	8b 7d 10             	mov    0x10(%ebp),%edi
  800345:	eb 12                	jmp    800359 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800347:	85 c0                	test   %eax,%eax
  800349:	0f 84 cb 03 00 00    	je     80071a <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  80034f:	83 ec 08             	sub    $0x8,%esp
  800352:	53                   	push   %ebx
  800353:	50                   	push   %eax
  800354:	ff d6                	call   *%esi
  800356:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800359:	83 c7 01             	add    $0x1,%edi
  80035c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800360:	83 f8 25             	cmp    $0x25,%eax
  800363:	75 e2                	jne    800347 <vprintfmt+0x14>
  800365:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800369:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800370:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800377:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80037e:	ba 00 00 00 00       	mov    $0x0,%edx
  800383:	eb 07                	jmp    80038c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800388:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8d 47 01             	lea    0x1(%edi),%eax
  80038f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800392:	0f b6 07             	movzbl (%edi),%eax
  800395:	0f b6 c8             	movzbl %al,%ecx
  800398:	83 e8 23             	sub    $0x23,%eax
  80039b:	3c 55                	cmp    $0x55,%al
  80039d:	0f 87 5c 03 00 00    	ja     8006ff <vprintfmt+0x3cc>
  8003a3:	0f b6 c0             	movzbl %al,%eax
  8003a6:	ff 24 85 a0 0e 80 00 	jmp    *0x800ea0(,%eax,4)
  8003ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003b0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b4:	eb d6                	jmp    80038c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003cb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003ce:	83 fa 09             	cmp    $0x9,%edx
  8003d1:	77 39                	ja     80040c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d6:	eb e9                	jmp    8003c1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003db:	8d 48 04             	lea    0x4(%eax),%ecx
  8003de:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e1:	8b 00                	mov    (%eax),%eax
  8003e3:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e9:	eb 27                	jmp    800412 <vprintfmt+0xdf>
  8003eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ee:	85 c0                	test   %eax,%eax
  8003f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f5:	0f 49 c8             	cmovns %eax,%ecx
  8003f8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fe:	eb 8c                	jmp    80038c <vprintfmt+0x59>
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800403:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80040a:	eb 80                	jmp    80038c <vprintfmt+0x59>
  80040c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040f:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800412:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800416:	0f 89 70 ff ff ff    	jns    80038c <vprintfmt+0x59>
				width = precision, precision = -1;
  80041c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80041f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800422:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800429:	e9 5e ff ff ff       	jmp    80038c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800434:	e9 53 ff ff ff       	jmp    80038c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
  80043c:	8d 50 04             	lea    0x4(%eax),%edx
  80043f:	89 55 14             	mov    %edx,0x14(%ebp)
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	53                   	push   %ebx
  800446:	ff 30                	pushl  (%eax)
  800448:	ff d6                	call   *%esi
			break;
  80044a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800450:	e9 04 ff ff ff       	jmp    800359 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8d 50 04             	lea    0x4(%eax),%edx
  80045b:	89 55 14             	mov    %edx,0x14(%ebp)
  80045e:	8b 00                	mov    (%eax),%eax
  800460:	99                   	cltd   
  800461:	31 d0                	xor    %edx,%eax
  800463:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800465:	83 f8 07             	cmp    $0x7,%eax
  800468:	7f 0b                	jg     800475 <vprintfmt+0x142>
  80046a:	8b 14 85 00 10 80 00 	mov    0x801000(,%eax,4),%edx
  800471:	85 d2                	test   %edx,%edx
  800473:	75 18                	jne    80048d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800475:	50                   	push   %eax
  800476:	68 14 0e 80 00       	push   $0x800e14
  80047b:	53                   	push   %ebx
  80047c:	56                   	push   %esi
  80047d:	e8 94 fe ff ff       	call   800316 <printfmt>
  800482:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800488:	e9 cc fe ff ff       	jmp    800359 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80048d:	52                   	push   %edx
  80048e:	68 1d 0e 80 00       	push   $0x800e1d
  800493:	53                   	push   %ebx
  800494:	56                   	push   %esi
  800495:	e8 7c fe ff ff       	call   800316 <printfmt>
  80049a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a0:	e9 b4 fe ff ff       	jmp    800359 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8d 50 04             	lea    0x4(%eax),%edx
  8004ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ae:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b0:	85 ff                	test   %edi,%edi
  8004b2:	b8 0d 0e 80 00       	mov    $0x800e0d,%eax
  8004b7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004be:	0f 8e 94 00 00 00    	jle    800558 <vprintfmt+0x225>
  8004c4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c8:	0f 84 98 00 00 00    	je     800566 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ce:	83 ec 08             	sub    $0x8,%esp
  8004d1:	ff 75 c8             	pushl  -0x38(%ebp)
  8004d4:	57                   	push   %edi
  8004d5:	e8 c8 02 00 00       	call   8007a2 <strnlen>
  8004da:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004dd:	29 c1                	sub    %eax,%ecx
  8004df:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004e2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ec:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ef:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f1:	eb 0f                	jmp    800502 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	53                   	push   %ebx
  8004f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8004fa:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fc:	83 ef 01             	sub    $0x1,%edi
  8004ff:	83 c4 10             	add    $0x10,%esp
  800502:	85 ff                	test   %edi,%edi
  800504:	7f ed                	jg     8004f3 <vprintfmt+0x1c0>
  800506:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800509:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80050c:	85 c9                	test   %ecx,%ecx
  80050e:	b8 00 00 00 00       	mov    $0x0,%eax
  800513:	0f 49 c1             	cmovns %ecx,%eax
  800516:	29 c1                	sub    %eax,%ecx
  800518:	89 75 08             	mov    %esi,0x8(%ebp)
  80051b:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80051e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800521:	89 cb                	mov    %ecx,%ebx
  800523:	eb 4d                	jmp    800572 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800525:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800529:	74 1b                	je     800546 <vprintfmt+0x213>
  80052b:	0f be c0             	movsbl %al,%eax
  80052e:	83 e8 20             	sub    $0x20,%eax
  800531:	83 f8 5e             	cmp    $0x5e,%eax
  800534:	76 10                	jbe    800546 <vprintfmt+0x213>
					putch('?', putdat);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	ff 75 0c             	pushl  0xc(%ebp)
  80053c:	6a 3f                	push   $0x3f
  80053e:	ff 55 08             	call   *0x8(%ebp)
  800541:	83 c4 10             	add    $0x10,%esp
  800544:	eb 0d                	jmp    800553 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800546:	83 ec 08             	sub    $0x8,%esp
  800549:	ff 75 0c             	pushl  0xc(%ebp)
  80054c:	52                   	push   %edx
  80054d:	ff 55 08             	call   *0x8(%ebp)
  800550:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800553:	83 eb 01             	sub    $0x1,%ebx
  800556:	eb 1a                	jmp    800572 <vprintfmt+0x23f>
  800558:	89 75 08             	mov    %esi,0x8(%ebp)
  80055b:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80055e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800561:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800564:	eb 0c                	jmp    800572 <vprintfmt+0x23f>
  800566:	89 75 08             	mov    %esi,0x8(%ebp)
  800569:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80056c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800572:	83 c7 01             	add    $0x1,%edi
  800575:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800579:	0f be d0             	movsbl %al,%edx
  80057c:	85 d2                	test   %edx,%edx
  80057e:	74 23                	je     8005a3 <vprintfmt+0x270>
  800580:	85 f6                	test   %esi,%esi
  800582:	78 a1                	js     800525 <vprintfmt+0x1f2>
  800584:	83 ee 01             	sub    $0x1,%esi
  800587:	79 9c                	jns    800525 <vprintfmt+0x1f2>
  800589:	89 df                	mov    %ebx,%edi
  80058b:	8b 75 08             	mov    0x8(%ebp),%esi
  80058e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800591:	eb 18                	jmp    8005ab <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800593:	83 ec 08             	sub    $0x8,%esp
  800596:	53                   	push   %ebx
  800597:	6a 20                	push   $0x20
  800599:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059b:	83 ef 01             	sub    $0x1,%edi
  80059e:	83 c4 10             	add    $0x10,%esp
  8005a1:	eb 08                	jmp    8005ab <vprintfmt+0x278>
  8005a3:	89 df                	mov    %ebx,%edi
  8005a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ab:	85 ff                	test   %edi,%edi
  8005ad:	7f e4                	jg     800593 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b2:	e9 a2 fd ff ff       	jmp    800359 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b7:	83 fa 01             	cmp    $0x1,%edx
  8005ba:	7e 16                	jle    8005d2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 50 08             	lea    0x8(%eax),%edx
  8005c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c5:	8b 50 04             	mov    0x4(%eax),%edx
  8005c8:	8b 00                	mov    (%eax),%eax
  8005ca:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005cd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005d0:	eb 32                	jmp    800604 <vprintfmt+0x2d1>
	else if (lflag)
  8005d2:	85 d2                	test   %edx,%edx
  8005d4:	74 18                	je     8005ee <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8d 50 04             	lea    0x4(%eax),%edx
  8005dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005df:	8b 00                	mov    (%eax),%eax
  8005e1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005e4:	89 c1                	mov    %eax,%ecx
  8005e6:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005ec:	eb 16                	jmp    800604 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 50 04             	lea    0x4(%eax),%edx
  8005f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f7:	8b 00                	mov    (%eax),%eax
  8005f9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005fc:	89 c1                	mov    %eax,%ecx
  8005fe:	c1 f9 1f             	sar    $0x1f,%ecx
  800601:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800604:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800607:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80060a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800610:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800615:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800619:	0f 89 a8 00 00 00    	jns    8006c7 <vprintfmt+0x394>
				putch('-', putdat);
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	53                   	push   %ebx
  800623:	6a 2d                	push   $0x2d
  800625:	ff d6                	call   *%esi
				num = -(long long) num;
  800627:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80062a:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80062d:	f7 d8                	neg    %eax
  80062f:	83 d2 00             	adc    $0x0,%edx
  800632:	f7 da                	neg    %edx
  800634:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800637:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80063a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80063d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800642:	e9 80 00 00 00       	jmp    8006c7 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800647:	8d 45 14             	lea    0x14(%ebp),%eax
  80064a:	e8 70 fc ff ff       	call   8002bf <getuint>
  80064f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800652:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800655:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80065a:	eb 6b                	jmp    8006c7 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80065c:	8d 45 14             	lea    0x14(%ebp),%eax
  80065f:	e8 5b fc ff ff       	call   8002bf <getuint>
  800664:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800667:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  80066a:	6a 04                	push   $0x4
  80066c:	6a 03                	push   $0x3
  80066e:	6a 01                	push   $0x1
  800670:	68 20 0e 80 00       	push   $0x800e20
  800675:	e8 82 fb ff ff       	call   8001fc <cprintf>
			goto number;
  80067a:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  80067d:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  800682:	eb 43                	jmp    8006c7 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	6a 30                	push   $0x30
  80068a:	ff d6                	call   *%esi
			putch('x', putdat);
  80068c:	83 c4 08             	add    $0x8,%esp
  80068f:	53                   	push   %ebx
  800690:	6a 78                	push   $0x78
  800692:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80069d:	8b 00                	mov    (%eax),%eax
  80069f:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006aa:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ad:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006b2:	eb 13                	jmp    8006c7 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b7:	e8 03 fc ff ff       	call   8002bf <getuint>
  8006bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006c2:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c7:	83 ec 0c             	sub    $0xc,%esp
  8006ca:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006ce:	52                   	push   %edx
  8006cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d2:	50                   	push   %eax
  8006d3:	ff 75 dc             	pushl  -0x24(%ebp)
  8006d6:	ff 75 d8             	pushl  -0x28(%ebp)
  8006d9:	89 da                	mov    %ebx,%edx
  8006db:	89 f0                	mov    %esi,%eax
  8006dd:	e8 2e fb ff ff       	call   800210 <printnum>

			break;
  8006e2:	83 c4 20             	add    $0x20,%esp
  8006e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e8:	e9 6c fc ff ff       	jmp    800359 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	53                   	push   %ebx
  8006f1:	51                   	push   %ecx
  8006f2:	ff d6                	call   *%esi
			break;
  8006f4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006fa:	e9 5a fc ff ff       	jmp    800359 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ff:	83 ec 08             	sub    $0x8,%esp
  800702:	53                   	push   %ebx
  800703:	6a 25                	push   $0x25
  800705:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800707:	83 c4 10             	add    $0x10,%esp
  80070a:	eb 03                	jmp    80070f <vprintfmt+0x3dc>
  80070c:	83 ef 01             	sub    $0x1,%edi
  80070f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800713:	75 f7                	jne    80070c <vprintfmt+0x3d9>
  800715:	e9 3f fc ff ff       	jmp    800359 <vprintfmt+0x26>
			break;
		}

	}

}
  80071a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071d:	5b                   	pop    %ebx
  80071e:	5e                   	pop    %esi
  80071f:	5f                   	pop    %edi
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    

00800722 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	83 ec 18             	sub    $0x18,%esp
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800731:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800735:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800738:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073f:	85 c0                	test   %eax,%eax
  800741:	74 26                	je     800769 <vsnprintf+0x47>
  800743:	85 d2                	test   %edx,%edx
  800745:	7e 22                	jle    800769 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800747:	ff 75 14             	pushl  0x14(%ebp)
  80074a:	ff 75 10             	pushl  0x10(%ebp)
  80074d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800750:	50                   	push   %eax
  800751:	68 f9 02 80 00       	push   $0x8002f9
  800756:	e8 d8 fb ff ff       	call   800333 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80075b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800761:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800764:	83 c4 10             	add    $0x10,%esp
  800767:	eb 05                	jmp    80076e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800769:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    

00800770 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800776:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800779:	50                   	push   %eax
  80077a:	ff 75 10             	pushl  0x10(%ebp)
  80077d:	ff 75 0c             	pushl  0xc(%ebp)
  800780:	ff 75 08             	pushl  0x8(%ebp)
  800783:	e8 9a ff ff ff       	call   800722 <vsnprintf>
	va_end(ap);

	return rc;
}
  800788:	c9                   	leave  
  800789:	c3                   	ret    

0080078a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800790:	b8 00 00 00 00       	mov    $0x0,%eax
  800795:	eb 03                	jmp    80079a <strlen+0x10>
		n++;
  800797:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80079a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079e:	75 f7                	jne    800797 <strlen+0xd>
		n++;
	return n;
}
  8007a0:	5d                   	pop    %ebp
  8007a1:	c3                   	ret    

008007a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b0:	eb 03                	jmp    8007b5 <strnlen+0x13>
		n++;
  8007b2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b5:	39 c2                	cmp    %eax,%edx
  8007b7:	74 08                	je     8007c1 <strnlen+0x1f>
  8007b9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007bd:	75 f3                	jne    8007b2 <strnlen+0x10>
  8007bf:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	53                   	push   %ebx
  8007c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007cd:	89 c2                	mov    %eax,%edx
  8007cf:	83 c2 01             	add    $0x1,%edx
  8007d2:	83 c1 01             	add    $0x1,%ecx
  8007d5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007d9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007dc:	84 db                	test   %bl,%bl
  8007de:	75 ef                	jne    8007cf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007e0:	5b                   	pop    %ebx
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	53                   	push   %ebx
  8007e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ea:	53                   	push   %ebx
  8007eb:	e8 9a ff ff ff       	call   80078a <strlen>
  8007f0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007f3:	ff 75 0c             	pushl  0xc(%ebp)
  8007f6:	01 d8                	add    %ebx,%eax
  8007f8:	50                   	push   %eax
  8007f9:	e8 c5 ff ff ff       	call   8007c3 <strcpy>
	return dst;
}
  8007fe:	89 d8                	mov    %ebx,%eax
  800800:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800803:	c9                   	leave  
  800804:	c3                   	ret    

00800805 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	56                   	push   %esi
  800809:	53                   	push   %ebx
  80080a:	8b 75 08             	mov    0x8(%ebp),%esi
  80080d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800810:	89 f3                	mov    %esi,%ebx
  800812:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800815:	89 f2                	mov    %esi,%edx
  800817:	eb 0f                	jmp    800828 <strncpy+0x23>
		*dst++ = *src;
  800819:	83 c2 01             	add    $0x1,%edx
  80081c:	0f b6 01             	movzbl (%ecx),%eax
  80081f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800822:	80 39 01             	cmpb   $0x1,(%ecx)
  800825:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800828:	39 da                	cmp    %ebx,%edx
  80082a:	75 ed                	jne    800819 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80082c:	89 f0                	mov    %esi,%eax
  80082e:	5b                   	pop    %ebx
  80082f:	5e                   	pop    %esi
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	56                   	push   %esi
  800836:	53                   	push   %ebx
  800837:	8b 75 08             	mov    0x8(%ebp),%esi
  80083a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083d:	8b 55 10             	mov    0x10(%ebp),%edx
  800840:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800842:	85 d2                	test   %edx,%edx
  800844:	74 21                	je     800867 <strlcpy+0x35>
  800846:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80084a:	89 f2                	mov    %esi,%edx
  80084c:	eb 09                	jmp    800857 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80084e:	83 c2 01             	add    $0x1,%edx
  800851:	83 c1 01             	add    $0x1,%ecx
  800854:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800857:	39 c2                	cmp    %eax,%edx
  800859:	74 09                	je     800864 <strlcpy+0x32>
  80085b:	0f b6 19             	movzbl (%ecx),%ebx
  80085e:	84 db                	test   %bl,%bl
  800860:	75 ec                	jne    80084e <strlcpy+0x1c>
  800862:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800864:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800867:	29 f0                	sub    %esi,%eax
}
  800869:	5b                   	pop    %ebx
  80086a:	5e                   	pop    %esi
  80086b:	5d                   	pop    %ebp
  80086c:	c3                   	ret    

0080086d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800873:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800876:	eb 06                	jmp    80087e <strcmp+0x11>
		p++, q++;
  800878:	83 c1 01             	add    $0x1,%ecx
  80087b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80087e:	0f b6 01             	movzbl (%ecx),%eax
  800881:	84 c0                	test   %al,%al
  800883:	74 04                	je     800889 <strcmp+0x1c>
  800885:	3a 02                	cmp    (%edx),%al
  800887:	74 ef                	je     800878 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800889:	0f b6 c0             	movzbl %al,%eax
  80088c:	0f b6 12             	movzbl (%edx),%edx
  80088f:	29 d0                	sub    %edx,%eax
}
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	53                   	push   %ebx
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089d:	89 c3                	mov    %eax,%ebx
  80089f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a2:	eb 06                	jmp    8008aa <strncmp+0x17>
		n--, p++, q++;
  8008a4:	83 c0 01             	add    $0x1,%eax
  8008a7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008aa:	39 d8                	cmp    %ebx,%eax
  8008ac:	74 15                	je     8008c3 <strncmp+0x30>
  8008ae:	0f b6 08             	movzbl (%eax),%ecx
  8008b1:	84 c9                	test   %cl,%cl
  8008b3:	74 04                	je     8008b9 <strncmp+0x26>
  8008b5:	3a 0a                	cmp    (%edx),%cl
  8008b7:	74 eb                	je     8008a4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b9:	0f b6 00             	movzbl (%eax),%eax
  8008bc:	0f b6 12             	movzbl (%edx),%edx
  8008bf:	29 d0                	sub    %edx,%eax
  8008c1:	eb 05                	jmp    8008c8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c8:	5b                   	pop    %ebx
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d5:	eb 07                	jmp    8008de <strchr+0x13>
		if (*s == c)
  8008d7:	38 ca                	cmp    %cl,%dl
  8008d9:	74 0f                	je     8008ea <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008db:	83 c0 01             	add    $0x1,%eax
  8008de:	0f b6 10             	movzbl (%eax),%edx
  8008e1:	84 d2                	test   %dl,%dl
  8008e3:	75 f2                	jne    8008d7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f6:	eb 03                	jmp    8008fb <strfind+0xf>
  8008f8:	83 c0 01             	add    $0x1,%eax
  8008fb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008fe:	38 ca                	cmp    %cl,%dl
  800900:	74 04                	je     800906 <strfind+0x1a>
  800902:	84 d2                	test   %dl,%dl
  800904:	75 f2                	jne    8008f8 <strfind+0xc>
			break;
	return (char *) s;
}
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	57                   	push   %edi
  80090c:	56                   	push   %esi
  80090d:	53                   	push   %ebx
  80090e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800911:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800914:	85 c9                	test   %ecx,%ecx
  800916:	74 36                	je     80094e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800918:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80091e:	75 28                	jne    800948 <memset+0x40>
  800920:	f6 c1 03             	test   $0x3,%cl
  800923:	75 23                	jne    800948 <memset+0x40>
		c &= 0xFF;
  800925:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800929:	89 d3                	mov    %edx,%ebx
  80092b:	c1 e3 08             	shl    $0x8,%ebx
  80092e:	89 d6                	mov    %edx,%esi
  800930:	c1 e6 18             	shl    $0x18,%esi
  800933:	89 d0                	mov    %edx,%eax
  800935:	c1 e0 10             	shl    $0x10,%eax
  800938:	09 f0                	or     %esi,%eax
  80093a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80093c:	89 d8                	mov    %ebx,%eax
  80093e:	09 d0                	or     %edx,%eax
  800940:	c1 e9 02             	shr    $0x2,%ecx
  800943:	fc                   	cld    
  800944:	f3 ab                	rep stos %eax,%es:(%edi)
  800946:	eb 06                	jmp    80094e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800948:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094b:	fc                   	cld    
  80094c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094e:	89 f8                	mov    %edi,%eax
  800950:	5b                   	pop    %ebx
  800951:	5e                   	pop    %esi
  800952:	5f                   	pop    %edi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	57                   	push   %edi
  800959:	56                   	push   %esi
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800960:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800963:	39 c6                	cmp    %eax,%esi
  800965:	73 35                	jae    80099c <memmove+0x47>
  800967:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096a:	39 d0                	cmp    %edx,%eax
  80096c:	73 2e                	jae    80099c <memmove+0x47>
		s += n;
		d += n;
  80096e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800971:	89 d6                	mov    %edx,%esi
  800973:	09 fe                	or     %edi,%esi
  800975:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80097b:	75 13                	jne    800990 <memmove+0x3b>
  80097d:	f6 c1 03             	test   $0x3,%cl
  800980:	75 0e                	jne    800990 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800982:	83 ef 04             	sub    $0x4,%edi
  800985:	8d 72 fc             	lea    -0x4(%edx),%esi
  800988:	c1 e9 02             	shr    $0x2,%ecx
  80098b:	fd                   	std    
  80098c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098e:	eb 09                	jmp    800999 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800990:	83 ef 01             	sub    $0x1,%edi
  800993:	8d 72 ff             	lea    -0x1(%edx),%esi
  800996:	fd                   	std    
  800997:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800999:	fc                   	cld    
  80099a:	eb 1d                	jmp    8009b9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099c:	89 f2                	mov    %esi,%edx
  80099e:	09 c2                	or     %eax,%edx
  8009a0:	f6 c2 03             	test   $0x3,%dl
  8009a3:	75 0f                	jne    8009b4 <memmove+0x5f>
  8009a5:	f6 c1 03             	test   $0x3,%cl
  8009a8:	75 0a                	jne    8009b4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009aa:	c1 e9 02             	shr    $0x2,%ecx
  8009ad:	89 c7                	mov    %eax,%edi
  8009af:	fc                   	cld    
  8009b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b2:	eb 05                	jmp    8009b9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b4:	89 c7                	mov    %eax,%edi
  8009b6:	fc                   	cld    
  8009b7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b9:	5e                   	pop    %esi
  8009ba:	5f                   	pop    %edi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009c0:	ff 75 10             	pushl  0x10(%ebp)
  8009c3:	ff 75 0c             	pushl  0xc(%ebp)
  8009c6:	ff 75 08             	pushl  0x8(%ebp)
  8009c9:	e8 87 ff ff ff       	call   800955 <memmove>
}
  8009ce:	c9                   	leave  
  8009cf:	c3                   	ret    

008009d0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009db:	89 c6                	mov    %eax,%esi
  8009dd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e0:	eb 1a                	jmp    8009fc <memcmp+0x2c>
		if (*s1 != *s2)
  8009e2:	0f b6 08             	movzbl (%eax),%ecx
  8009e5:	0f b6 1a             	movzbl (%edx),%ebx
  8009e8:	38 d9                	cmp    %bl,%cl
  8009ea:	74 0a                	je     8009f6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009ec:	0f b6 c1             	movzbl %cl,%eax
  8009ef:	0f b6 db             	movzbl %bl,%ebx
  8009f2:	29 d8                	sub    %ebx,%eax
  8009f4:	eb 0f                	jmp    800a05 <memcmp+0x35>
		s1++, s2++;
  8009f6:	83 c0 01             	add    $0x1,%eax
  8009f9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fc:	39 f0                	cmp    %esi,%eax
  8009fe:	75 e2                	jne    8009e2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a05:	5b                   	pop    %ebx
  800a06:	5e                   	pop    %esi
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	53                   	push   %ebx
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a10:	89 c1                	mov    %eax,%ecx
  800a12:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a15:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a19:	eb 0a                	jmp    800a25 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1b:	0f b6 10             	movzbl (%eax),%edx
  800a1e:	39 da                	cmp    %ebx,%edx
  800a20:	74 07                	je     800a29 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a22:	83 c0 01             	add    $0x1,%eax
  800a25:	39 c8                	cmp    %ecx,%eax
  800a27:	72 f2                	jb     800a1b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a29:	5b                   	pop    %ebx
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	57                   	push   %edi
  800a30:	56                   	push   %esi
  800a31:	53                   	push   %ebx
  800a32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a38:	eb 03                	jmp    800a3d <strtol+0x11>
		s++;
  800a3a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3d:	0f b6 01             	movzbl (%ecx),%eax
  800a40:	3c 20                	cmp    $0x20,%al
  800a42:	74 f6                	je     800a3a <strtol+0xe>
  800a44:	3c 09                	cmp    $0x9,%al
  800a46:	74 f2                	je     800a3a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a48:	3c 2b                	cmp    $0x2b,%al
  800a4a:	75 0a                	jne    800a56 <strtol+0x2a>
		s++;
  800a4c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a4f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a54:	eb 11                	jmp    800a67 <strtol+0x3b>
  800a56:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a5b:	3c 2d                	cmp    $0x2d,%al
  800a5d:	75 08                	jne    800a67 <strtol+0x3b>
		s++, neg = 1;
  800a5f:	83 c1 01             	add    $0x1,%ecx
  800a62:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a67:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a6d:	75 15                	jne    800a84 <strtol+0x58>
  800a6f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a72:	75 10                	jne    800a84 <strtol+0x58>
  800a74:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a78:	75 7c                	jne    800af6 <strtol+0xca>
		s += 2, base = 16;
  800a7a:	83 c1 02             	add    $0x2,%ecx
  800a7d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a82:	eb 16                	jmp    800a9a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a84:	85 db                	test   %ebx,%ebx
  800a86:	75 12                	jne    800a9a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a88:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a90:	75 08                	jne    800a9a <strtol+0x6e>
		s++, base = 8;
  800a92:	83 c1 01             	add    $0x1,%ecx
  800a95:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa2:	0f b6 11             	movzbl (%ecx),%edx
  800aa5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa8:	89 f3                	mov    %esi,%ebx
  800aaa:	80 fb 09             	cmp    $0x9,%bl
  800aad:	77 08                	ja     800ab7 <strtol+0x8b>
			dig = *s - '0';
  800aaf:	0f be d2             	movsbl %dl,%edx
  800ab2:	83 ea 30             	sub    $0x30,%edx
  800ab5:	eb 22                	jmp    800ad9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ab7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aba:	89 f3                	mov    %esi,%ebx
  800abc:	80 fb 19             	cmp    $0x19,%bl
  800abf:	77 08                	ja     800ac9 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ac1:	0f be d2             	movsbl %dl,%edx
  800ac4:	83 ea 57             	sub    $0x57,%edx
  800ac7:	eb 10                	jmp    800ad9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ac9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800acc:	89 f3                	mov    %esi,%ebx
  800ace:	80 fb 19             	cmp    $0x19,%bl
  800ad1:	77 16                	ja     800ae9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ad3:	0f be d2             	movsbl %dl,%edx
  800ad6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ad9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800adc:	7d 0b                	jge    800ae9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ade:	83 c1 01             	add    $0x1,%ecx
  800ae1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ae7:	eb b9                	jmp    800aa2 <strtol+0x76>

	if (endptr)
  800ae9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aed:	74 0d                	je     800afc <strtol+0xd0>
		*endptr = (char *) s;
  800aef:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af2:	89 0e                	mov    %ecx,(%esi)
  800af4:	eb 06                	jmp    800afc <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af6:	85 db                	test   %ebx,%ebx
  800af8:	74 98                	je     800a92 <strtol+0x66>
  800afa:	eb 9e                	jmp    800a9a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800afc:	89 c2                	mov    %eax,%edx
  800afe:	f7 da                	neg    %edx
  800b00:	85 ff                	test   %edi,%edi
  800b02:	0f 45 c2             	cmovne %edx,%eax
}
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    
  800b0a:	66 90                	xchg   %ax,%ax
  800b0c:	66 90                	xchg   %ax,%ax
  800b0e:	66 90                	xchg   %ax,%ax

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
