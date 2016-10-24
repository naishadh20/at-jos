
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
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800044:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80004b:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  80004e:	e8 c9 00 00 00       	call   80011c <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005b:	c1 e0 05             	shl    $0x5,%eax
  80005e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800063:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800068:	85 db                	test   %ebx,%ebx
  80006a:	7e 07                	jle    800073 <libmain+0x3a>
		binaryname = argv[0];
  80006c:	8b 06                	mov    (%esi),%eax
  80006e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800073:	83 ec 08             	sub    $0x8,%esp
  800076:	56                   	push   %esi
  800077:	53                   	push   %ebx
  800078:	e8 b6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007d:	e8 0a 00 00 00       	call   80008c <exit>
}
  800082:	83 c4 10             	add    $0x10,%esp
  800085:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800088:	5b                   	pop    %ebx
  800089:	5e                   	pop    %esi
  80008a:	5d                   	pop    %ebp
  80008b:	c3                   	ret    

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 17                	jle    800114 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 ca 0d 80 00       	push   $0x800dca
  800108:	6a 23                	push   $0x23
  80010a:	68 e7 0d 80 00       	push   $0x800de7
  80010f:	e8 27 00 00 00       	call   80013b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	56                   	push   %esi
  80013f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800140:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800143:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800149:	e8 ce ff ff ff       	call   80011c <sys_getenvid>
  80014e:	83 ec 0c             	sub    $0xc,%esp
  800151:	ff 75 0c             	pushl  0xc(%ebp)
  800154:	ff 75 08             	pushl  0x8(%ebp)
  800157:	56                   	push   %esi
  800158:	50                   	push   %eax
  800159:	68 f8 0d 80 00       	push   $0x800df8
  80015e:	e8 b1 00 00 00       	call   800214 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800163:	83 c4 18             	add    $0x18,%esp
  800166:	53                   	push   %ebx
  800167:	ff 75 10             	pushl  0x10(%ebp)
  80016a:	e8 54 00 00 00       	call   8001c3 <vcprintf>
	cprintf("\n");
  80016f:	c7 04 24 50 0e 80 00 	movl   $0x800e50,(%esp)
  800176:	e8 99 00 00 00       	call   800214 <cprintf>
  80017b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017e:	cc                   	int3   
  80017f:	eb fd                	jmp    80017e <_panic+0x43>

00800181 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	53                   	push   %ebx
  800185:	83 ec 04             	sub    $0x4,%esp
  800188:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018b:	8b 13                	mov    (%ebx),%edx
  80018d:	8d 42 01             	lea    0x1(%edx),%eax
  800190:	89 03                	mov    %eax,(%ebx)
  800192:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800195:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800199:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019e:	75 1a                	jne    8001ba <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a0:	83 ec 08             	sub    $0x8,%esp
  8001a3:	68 ff 00 00 00       	push   $0xff
  8001a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ab:	50                   	push   %eax
  8001ac:	e8 ed fe ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  8001b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c1:	c9                   	leave  
  8001c2:	c3                   	ret    

008001c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c3:	55                   	push   %ebp
  8001c4:	89 e5                	mov    %esp,%ebp
  8001c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d3:	00 00 00 
	b.cnt = 0;
  8001d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e0:	ff 75 0c             	pushl  0xc(%ebp)
  8001e3:	ff 75 08             	pushl  0x8(%ebp)
  8001e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ec:	50                   	push   %eax
  8001ed:	68 81 01 80 00       	push   $0x800181
  8001f2:	e8 54 01 00 00       	call   80034b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f7:	83 c4 08             	add    $0x8,%esp
  8001fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800200:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800206:	50                   	push   %eax
  800207:	e8 92 fe ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  80020c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021d:	50                   	push   %eax
  80021e:	ff 75 08             	pushl  0x8(%ebp)
  800221:	e8 9d ff ff ff       	call   8001c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800226:	c9                   	leave  
  800227:	c3                   	ret    

00800228 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	53                   	push   %ebx
  80022e:	83 ec 1c             	sub    $0x1c,%esp
  800231:	89 c7                	mov    %eax,%edi
  800233:	89 d6                	mov    %edx,%esi
  800235:	8b 45 08             	mov    0x8(%ebp),%eax
  800238:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800241:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800244:	bb 00 00 00 00       	mov    $0x0,%ebx
  800249:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80024c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80024f:	39 d3                	cmp    %edx,%ebx
  800251:	72 05                	jb     800258 <printnum+0x30>
  800253:	39 45 10             	cmp    %eax,0x10(%ebp)
  800256:	77 45                	ja     80029d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800258:	83 ec 0c             	sub    $0xc,%esp
  80025b:	ff 75 18             	pushl  0x18(%ebp)
  80025e:	8b 45 14             	mov    0x14(%ebp),%eax
  800261:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800264:	53                   	push   %ebx
  800265:	ff 75 10             	pushl  0x10(%ebp)
  800268:	83 ec 08             	sub    $0x8,%esp
  80026b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026e:	ff 75 e0             	pushl  -0x20(%ebp)
  800271:	ff 75 dc             	pushl  -0x24(%ebp)
  800274:	ff 75 d8             	pushl  -0x28(%ebp)
  800277:	e8 b4 08 00 00       	call   800b30 <__udivdi3>
  80027c:	83 c4 18             	add    $0x18,%esp
  80027f:	52                   	push   %edx
  800280:	50                   	push   %eax
  800281:	89 f2                	mov    %esi,%edx
  800283:	89 f8                	mov    %edi,%eax
  800285:	e8 9e ff ff ff       	call   800228 <printnum>
  80028a:	83 c4 20             	add    $0x20,%esp
  80028d:	eb 18                	jmp    8002a7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028f:	83 ec 08             	sub    $0x8,%esp
  800292:	56                   	push   %esi
  800293:	ff 75 18             	pushl  0x18(%ebp)
  800296:	ff d7                	call   *%edi
  800298:	83 c4 10             	add    $0x10,%esp
  80029b:	eb 03                	jmp    8002a0 <printnum+0x78>
  80029d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a0:	83 eb 01             	sub    $0x1,%ebx
  8002a3:	85 db                	test   %ebx,%ebx
  8002a5:	7f e8                	jg     80028f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a7:	83 ec 08             	sub    $0x8,%esp
  8002aa:	56                   	push   %esi
  8002ab:	83 ec 04             	sub    $0x4,%esp
  8002ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ba:	e8 a1 09 00 00       	call   800c60 <__umoddi3>
  8002bf:	83 c4 14             	add    $0x14,%esp
  8002c2:	0f be 80 1c 0e 80 00 	movsbl 0x800e1c(%eax),%eax
  8002c9:	50                   	push   %eax
  8002ca:	ff d7                	call   *%edi
}
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d2:	5b                   	pop    %ebx
  8002d3:	5e                   	pop    %esi
  8002d4:	5f                   	pop    %edi
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002da:	83 fa 01             	cmp    $0x1,%edx
  8002dd:	7e 0e                	jle    8002ed <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002df:	8b 10                	mov    (%eax),%edx
  8002e1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e4:	89 08                	mov    %ecx,(%eax)
  8002e6:	8b 02                	mov    (%edx),%eax
  8002e8:	8b 52 04             	mov    0x4(%edx),%edx
  8002eb:	eb 22                	jmp    80030f <getuint+0x38>
	else if (lflag)
  8002ed:	85 d2                	test   %edx,%edx
  8002ef:	74 10                	je     800301 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f6:	89 08                	mov    %ecx,(%eax)
  8002f8:	8b 02                	mov    (%edx),%eax
  8002fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ff:	eb 0e                	jmp    80030f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800301:	8b 10                	mov    (%eax),%edx
  800303:	8d 4a 04             	lea    0x4(%edx),%ecx
  800306:	89 08                	mov    %ecx,(%eax)
  800308:	8b 02                	mov    (%edx),%eax
  80030a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800317:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031b:	8b 10                	mov    (%eax),%edx
  80031d:	3b 50 04             	cmp    0x4(%eax),%edx
  800320:	73 0a                	jae    80032c <sprintputch+0x1b>
		*b->buf++ = ch;
  800322:	8d 4a 01             	lea    0x1(%edx),%ecx
  800325:	89 08                	mov    %ecx,(%eax)
  800327:	8b 45 08             	mov    0x8(%ebp),%eax
  80032a:	88 02                	mov    %al,(%edx)
}
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800334:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800337:	50                   	push   %eax
  800338:	ff 75 10             	pushl  0x10(%ebp)
  80033b:	ff 75 0c             	pushl  0xc(%ebp)
  80033e:	ff 75 08             	pushl  0x8(%ebp)
  800341:	e8 05 00 00 00       	call   80034b <vprintfmt>
	va_end(ap);
}
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	c9                   	leave  
  80034a:	c3                   	ret    

0080034b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	57                   	push   %edi
  80034f:	56                   	push   %esi
  800350:	53                   	push   %ebx
  800351:	83 ec 2c             	sub    $0x2c,%esp
  800354:	8b 75 08             	mov    0x8(%ebp),%esi
  800357:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80035a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80035d:	eb 12                	jmp    800371 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80035f:	85 c0                	test   %eax,%eax
  800361:	0f 84 cb 03 00 00    	je     800732 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800367:	83 ec 08             	sub    $0x8,%esp
  80036a:	53                   	push   %ebx
  80036b:	50                   	push   %eax
  80036c:	ff d6                	call   *%esi
  80036e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800371:	83 c7 01             	add    $0x1,%edi
  800374:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800378:	83 f8 25             	cmp    $0x25,%eax
  80037b:	75 e2                	jne    80035f <vprintfmt+0x14>
  80037d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800381:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800388:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80038f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800396:	ba 00 00 00 00       	mov    $0x0,%edx
  80039b:	eb 07                	jmp    8003a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8d 47 01             	lea    0x1(%edi),%eax
  8003a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003aa:	0f b6 07             	movzbl (%edi),%eax
  8003ad:	0f b6 c8             	movzbl %al,%ecx
  8003b0:	83 e8 23             	sub    $0x23,%eax
  8003b3:	3c 55                	cmp    $0x55,%al
  8003b5:	0f 87 5c 03 00 00    	ja     800717 <vprintfmt+0x3cc>
  8003bb:	0f b6 c0             	movzbl %al,%eax
  8003be:	ff 24 85 c0 0e 80 00 	jmp    *0x800ec0(,%eax,4)
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003c8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003cc:	eb d6                	jmp    8003a4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003dc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003e3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003e6:	83 fa 09             	cmp    $0x9,%edx
  8003e9:	77 39                	ja     800424 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003eb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003ee:	eb e9                	jmp    8003d9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f3:	8d 48 04             	lea    0x4(%eax),%ecx
  8003f6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003f9:	8b 00                	mov    (%eax),%eax
  8003fb:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800401:	eb 27                	jmp    80042a <vprintfmt+0xdf>
  800403:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800406:	85 c0                	test   %eax,%eax
  800408:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040d:	0f 49 c8             	cmovns %eax,%ecx
  800410:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800416:	eb 8c                	jmp    8003a4 <vprintfmt+0x59>
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80041b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800422:	eb 80                	jmp    8003a4 <vprintfmt+0x59>
  800424:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800427:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80042a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042e:	0f 89 70 ff ff ff    	jns    8003a4 <vprintfmt+0x59>
				width = precision, precision = -1;
  800434:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800437:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043a:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800441:	e9 5e ff ff ff       	jmp    8003a4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800446:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80044c:	e9 53 ff ff ff       	jmp    8003a4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800451:	8b 45 14             	mov    0x14(%ebp),%eax
  800454:	8d 50 04             	lea    0x4(%eax),%edx
  800457:	89 55 14             	mov    %edx,0x14(%ebp)
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	53                   	push   %ebx
  80045e:	ff 30                	pushl  (%eax)
  800460:	ff d6                	call   *%esi
			break;
  800462:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800468:	e9 04 ff ff ff       	jmp    800371 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046d:	8b 45 14             	mov    0x14(%ebp),%eax
  800470:	8d 50 04             	lea    0x4(%eax),%edx
  800473:	89 55 14             	mov    %edx,0x14(%ebp)
  800476:	8b 00                	mov    (%eax),%eax
  800478:	99                   	cltd   
  800479:	31 d0                	xor    %edx,%eax
  80047b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047d:	83 f8 07             	cmp    $0x7,%eax
  800480:	7f 0b                	jg     80048d <vprintfmt+0x142>
  800482:	8b 14 85 20 10 80 00 	mov    0x801020(,%eax,4),%edx
  800489:	85 d2                	test   %edx,%edx
  80048b:	75 18                	jne    8004a5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80048d:	50                   	push   %eax
  80048e:	68 34 0e 80 00       	push   $0x800e34
  800493:	53                   	push   %ebx
  800494:	56                   	push   %esi
  800495:	e8 94 fe ff ff       	call   80032e <printfmt>
  80049a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a0:	e9 cc fe ff ff       	jmp    800371 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004a5:	52                   	push   %edx
  8004a6:	68 3d 0e 80 00       	push   $0x800e3d
  8004ab:	53                   	push   %ebx
  8004ac:	56                   	push   %esi
  8004ad:	e8 7c fe ff ff       	call   80032e <printfmt>
  8004b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004b8:	e9 b4 fe ff ff       	jmp    800371 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c0:	8d 50 04             	lea    0x4(%eax),%edx
  8004c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004c8:	85 ff                	test   %edi,%edi
  8004ca:	b8 2d 0e 80 00       	mov    $0x800e2d,%eax
  8004cf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d6:	0f 8e 94 00 00 00    	jle    800570 <vprintfmt+0x225>
  8004dc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e0:	0f 84 98 00 00 00    	je     80057e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	ff 75 c8             	pushl  -0x38(%ebp)
  8004ec:	57                   	push   %edi
  8004ed:	e8 c8 02 00 00       	call   8007ba <strnlen>
  8004f2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f5:	29 c1                	sub    %eax,%ecx
  8004f7:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004fa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004fd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800501:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800504:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800507:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800509:	eb 0f                	jmp    80051a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	53                   	push   %ebx
  80050f:	ff 75 e0             	pushl  -0x20(%ebp)
  800512:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800514:	83 ef 01             	sub    $0x1,%edi
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 ff                	test   %edi,%edi
  80051c:	7f ed                	jg     80050b <vprintfmt+0x1c0>
  80051e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800521:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800524:	85 c9                	test   %ecx,%ecx
  800526:	b8 00 00 00 00       	mov    $0x0,%eax
  80052b:	0f 49 c1             	cmovns %ecx,%eax
  80052e:	29 c1                	sub    %eax,%ecx
  800530:	89 75 08             	mov    %esi,0x8(%ebp)
  800533:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800536:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800539:	89 cb                	mov    %ecx,%ebx
  80053b:	eb 4d                	jmp    80058a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80053d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800541:	74 1b                	je     80055e <vprintfmt+0x213>
  800543:	0f be c0             	movsbl %al,%eax
  800546:	83 e8 20             	sub    $0x20,%eax
  800549:	83 f8 5e             	cmp    $0x5e,%eax
  80054c:	76 10                	jbe    80055e <vprintfmt+0x213>
					putch('?', putdat);
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	ff 75 0c             	pushl  0xc(%ebp)
  800554:	6a 3f                	push   $0x3f
  800556:	ff 55 08             	call   *0x8(%ebp)
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	eb 0d                	jmp    80056b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	ff 75 0c             	pushl  0xc(%ebp)
  800564:	52                   	push   %edx
  800565:	ff 55 08             	call   *0x8(%ebp)
  800568:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056b:	83 eb 01             	sub    $0x1,%ebx
  80056e:	eb 1a                	jmp    80058a <vprintfmt+0x23f>
  800570:	89 75 08             	mov    %esi,0x8(%ebp)
  800573:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800576:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800579:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057c:	eb 0c                	jmp    80058a <vprintfmt+0x23f>
  80057e:	89 75 08             	mov    %esi,0x8(%ebp)
  800581:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800584:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800587:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058a:	83 c7 01             	add    $0x1,%edi
  80058d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800591:	0f be d0             	movsbl %al,%edx
  800594:	85 d2                	test   %edx,%edx
  800596:	74 23                	je     8005bb <vprintfmt+0x270>
  800598:	85 f6                	test   %esi,%esi
  80059a:	78 a1                	js     80053d <vprintfmt+0x1f2>
  80059c:	83 ee 01             	sub    $0x1,%esi
  80059f:	79 9c                	jns    80053d <vprintfmt+0x1f2>
  8005a1:	89 df                	mov    %ebx,%edi
  8005a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a9:	eb 18                	jmp    8005c3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	53                   	push   %ebx
  8005af:	6a 20                	push   $0x20
  8005b1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b3:	83 ef 01             	sub    $0x1,%edi
  8005b6:	83 c4 10             	add    $0x10,%esp
  8005b9:	eb 08                	jmp    8005c3 <vprintfmt+0x278>
  8005bb:	89 df                	mov    %ebx,%edi
  8005bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c3:	85 ff                	test   %edi,%edi
  8005c5:	7f e4                	jg     8005ab <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ca:	e9 a2 fd ff ff       	jmp    800371 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005cf:	83 fa 01             	cmp    $0x1,%edx
  8005d2:	7e 16                	jle    8005ea <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 50 08             	lea    0x8(%eax),%edx
  8005da:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dd:	8b 50 04             	mov    0x4(%eax),%edx
  8005e0:	8b 00                	mov    (%eax),%eax
  8005e2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005e5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8005e8:	eb 32                	jmp    80061c <vprintfmt+0x2d1>
	else if (lflag)
  8005ea:	85 d2                	test   %edx,%edx
  8005ec:	74 18                	je     800606 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 50 04             	lea    0x4(%eax),%edx
  8005f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f7:	8b 00                	mov    (%eax),%eax
  8005f9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005fc:	89 c1                	mov    %eax,%ecx
  8005fe:	c1 f9 1f             	sar    $0x1f,%ecx
  800601:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800604:	eb 16                	jmp    80061c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 50 04             	lea    0x4(%eax),%edx
  80060c:	89 55 14             	mov    %edx,0x14(%ebp)
  80060f:	8b 00                	mov    (%eax),%eax
  800611:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800614:	89 c1                	mov    %eax,%ecx
  800616:	c1 f9 1f             	sar    $0x1f,%ecx
  800619:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80061f:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800622:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800625:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800628:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80062d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800631:	0f 89 a8 00 00 00    	jns    8006df <vprintfmt+0x394>
				putch('-', putdat);
  800637:	83 ec 08             	sub    $0x8,%esp
  80063a:	53                   	push   %ebx
  80063b:	6a 2d                	push   $0x2d
  80063d:	ff d6                	call   *%esi
				num = -(long long) num;
  80063f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800642:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800645:	f7 d8                	neg    %eax
  800647:	83 d2 00             	adc    $0x0,%edx
  80064a:	f7 da                	neg    %edx
  80064c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800652:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800655:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065a:	e9 80 00 00 00       	jmp    8006df <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80065f:	8d 45 14             	lea    0x14(%ebp),%eax
  800662:	e8 70 fc ff ff       	call   8002d7 <getuint>
  800667:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80066d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800672:	eb 6b                	jmp    8006df <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800674:	8d 45 14             	lea    0x14(%ebp),%eax
  800677:	e8 5b fc ff ff       	call   8002d7 <getuint>
  80067c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800682:	6a 04                	push   $0x4
  800684:	6a 03                	push   $0x3
  800686:	6a 01                	push   $0x1
  800688:	68 40 0e 80 00       	push   $0x800e40
  80068d:	e8 82 fb ff ff       	call   800214 <cprintf>
			goto number;
  800692:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  800695:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  80069a:	eb 43                	jmp    8006df <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  80069c:	83 ec 08             	sub    $0x8,%esp
  80069f:	53                   	push   %ebx
  8006a0:	6a 30                	push   $0x30
  8006a2:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a4:	83 c4 08             	add    $0x8,%esp
  8006a7:	53                   	push   %ebx
  8006a8:	6a 78                	push   $0x78
  8006aa:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8d 50 04             	lea    0x4(%eax),%edx
  8006b2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006b5:	8b 00                	mov    (%eax),%eax
  8006b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8006bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006c5:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006ca:	eb 13                	jmp    8006df <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cf:	e8 03 fc ff ff       	call   8002d7 <getuint>
  8006d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8006da:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006df:	83 ec 0c             	sub    $0xc,%esp
  8006e2:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8006e6:	52                   	push   %edx
  8006e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ea:	50                   	push   %eax
  8006eb:	ff 75 dc             	pushl  -0x24(%ebp)
  8006ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8006f1:	89 da                	mov    %ebx,%edx
  8006f3:	89 f0                	mov    %esi,%eax
  8006f5:	e8 2e fb ff ff       	call   800228 <printnum>

			break;
  8006fa:	83 c4 20             	add    $0x20,%esp
  8006fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800700:	e9 6c fc ff ff       	jmp    800371 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	53                   	push   %ebx
  800709:	51                   	push   %ecx
  80070a:	ff d6                	call   *%esi
			break;
  80070c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800712:	e9 5a fc ff ff       	jmp    800371 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800717:	83 ec 08             	sub    $0x8,%esp
  80071a:	53                   	push   %ebx
  80071b:	6a 25                	push   $0x25
  80071d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	eb 03                	jmp    800727 <vprintfmt+0x3dc>
  800724:	83 ef 01             	sub    $0x1,%edi
  800727:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80072b:	75 f7                	jne    800724 <vprintfmt+0x3d9>
  80072d:	e9 3f fc ff ff       	jmp    800371 <vprintfmt+0x26>
			break;
		}

	}

}
  800732:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800735:	5b                   	pop    %ebx
  800736:	5e                   	pop    %esi
  800737:	5f                   	pop    %edi
  800738:	5d                   	pop    %ebp
  800739:	c3                   	ret    

0080073a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	83 ec 18             	sub    $0x18,%esp
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800746:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800749:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800750:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800757:	85 c0                	test   %eax,%eax
  800759:	74 26                	je     800781 <vsnprintf+0x47>
  80075b:	85 d2                	test   %edx,%edx
  80075d:	7e 22                	jle    800781 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075f:	ff 75 14             	pushl  0x14(%ebp)
  800762:	ff 75 10             	pushl  0x10(%ebp)
  800765:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800768:	50                   	push   %eax
  800769:	68 11 03 80 00       	push   $0x800311
  80076e:	e8 d8 fb ff ff       	call   80034b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800773:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800776:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800779:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	eb 05                	jmp    800786 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800781:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800791:	50                   	push   %eax
  800792:	ff 75 10             	pushl  0x10(%ebp)
  800795:	ff 75 0c             	pushl  0xc(%ebp)
  800798:	ff 75 08             	pushl  0x8(%ebp)
  80079b:	e8 9a ff ff ff       	call   80073a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    

008007a2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ad:	eb 03                	jmp    8007b2 <strlen+0x10>
		n++;
  8007af:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b6:	75 f7                	jne    8007af <strlen+0xd>
		n++;
	return n;
}
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c8:	eb 03                	jmp    8007cd <strnlen+0x13>
		n++;
  8007ca:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cd:	39 c2                	cmp    %eax,%edx
  8007cf:	74 08                	je     8007d9 <strnlen+0x1f>
  8007d1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007d5:	75 f3                	jne    8007ca <strnlen+0x10>
  8007d7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e5:	89 c2                	mov    %eax,%edx
  8007e7:	83 c2 01             	add    $0x1,%edx
  8007ea:	83 c1 01             	add    $0x1,%ecx
  8007ed:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007f1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f4:	84 db                	test   %bl,%bl
  8007f6:	75 ef                	jne    8007e7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f8:	5b                   	pop    %ebx
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800802:	53                   	push   %ebx
  800803:	e8 9a ff ff ff       	call   8007a2 <strlen>
  800808:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80080b:	ff 75 0c             	pushl  0xc(%ebp)
  80080e:	01 d8                	add    %ebx,%eax
  800810:	50                   	push   %eax
  800811:	e8 c5 ff ff ff       	call   8007db <strcpy>
	return dst;
}
  800816:	89 d8                	mov    %ebx,%eax
  800818:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    

0080081d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	56                   	push   %esi
  800821:	53                   	push   %ebx
  800822:	8b 75 08             	mov    0x8(%ebp),%esi
  800825:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800828:	89 f3                	mov    %esi,%ebx
  80082a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082d:	89 f2                	mov    %esi,%edx
  80082f:	eb 0f                	jmp    800840 <strncpy+0x23>
		*dst++ = *src;
  800831:	83 c2 01             	add    $0x1,%edx
  800834:	0f b6 01             	movzbl (%ecx),%eax
  800837:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083a:	80 39 01             	cmpb   $0x1,(%ecx)
  80083d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800840:	39 da                	cmp    %ebx,%edx
  800842:	75 ed                	jne    800831 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800844:	89 f0                	mov    %esi,%eax
  800846:	5b                   	pop    %ebx
  800847:	5e                   	pop    %esi
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	56                   	push   %esi
  80084e:	53                   	push   %ebx
  80084f:	8b 75 08             	mov    0x8(%ebp),%esi
  800852:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800855:	8b 55 10             	mov    0x10(%ebp),%edx
  800858:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085a:	85 d2                	test   %edx,%edx
  80085c:	74 21                	je     80087f <strlcpy+0x35>
  80085e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800862:	89 f2                	mov    %esi,%edx
  800864:	eb 09                	jmp    80086f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800866:	83 c2 01             	add    $0x1,%edx
  800869:	83 c1 01             	add    $0x1,%ecx
  80086c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80086f:	39 c2                	cmp    %eax,%edx
  800871:	74 09                	je     80087c <strlcpy+0x32>
  800873:	0f b6 19             	movzbl (%ecx),%ebx
  800876:	84 db                	test   %bl,%bl
  800878:	75 ec                	jne    800866 <strlcpy+0x1c>
  80087a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80087c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80087f:	29 f0                	sub    %esi,%eax
}
  800881:	5b                   	pop    %ebx
  800882:	5e                   	pop    %esi
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088e:	eb 06                	jmp    800896 <strcmp+0x11>
		p++, q++;
  800890:	83 c1 01             	add    $0x1,%ecx
  800893:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800896:	0f b6 01             	movzbl (%ecx),%eax
  800899:	84 c0                	test   %al,%al
  80089b:	74 04                	je     8008a1 <strcmp+0x1c>
  80089d:	3a 02                	cmp    (%edx),%al
  80089f:	74 ef                	je     800890 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a1:	0f b6 c0             	movzbl %al,%eax
  8008a4:	0f b6 12             	movzbl (%edx),%edx
  8008a7:	29 d0                	sub    %edx,%eax
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b5:	89 c3                	mov    %eax,%ebx
  8008b7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ba:	eb 06                	jmp    8008c2 <strncmp+0x17>
		n--, p++, q++;
  8008bc:	83 c0 01             	add    $0x1,%eax
  8008bf:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c2:	39 d8                	cmp    %ebx,%eax
  8008c4:	74 15                	je     8008db <strncmp+0x30>
  8008c6:	0f b6 08             	movzbl (%eax),%ecx
  8008c9:	84 c9                	test   %cl,%cl
  8008cb:	74 04                	je     8008d1 <strncmp+0x26>
  8008cd:	3a 0a                	cmp    (%edx),%cl
  8008cf:	74 eb                	je     8008bc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d1:	0f b6 00             	movzbl (%eax),%eax
  8008d4:	0f b6 12             	movzbl (%edx),%edx
  8008d7:	29 d0                	sub    %edx,%eax
  8008d9:	eb 05                	jmp    8008e0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e0:	5b                   	pop    %ebx
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ed:	eb 07                	jmp    8008f6 <strchr+0x13>
		if (*s == c)
  8008ef:	38 ca                	cmp    %cl,%dl
  8008f1:	74 0f                	je     800902 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f3:	83 c0 01             	add    $0x1,%eax
  8008f6:	0f b6 10             	movzbl (%eax),%edx
  8008f9:	84 d2                	test   %dl,%dl
  8008fb:	75 f2                	jne    8008ef <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090e:	eb 03                	jmp    800913 <strfind+0xf>
  800910:	83 c0 01             	add    $0x1,%eax
  800913:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800916:	38 ca                	cmp    %cl,%dl
  800918:	74 04                	je     80091e <strfind+0x1a>
  80091a:	84 d2                	test   %dl,%dl
  80091c:	75 f2                	jne    800910 <strfind+0xc>
			break;
	return (char *) s;
}
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	57                   	push   %edi
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	8b 7d 08             	mov    0x8(%ebp),%edi
  800929:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80092c:	85 c9                	test   %ecx,%ecx
  80092e:	74 36                	je     800966 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800930:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800936:	75 28                	jne    800960 <memset+0x40>
  800938:	f6 c1 03             	test   $0x3,%cl
  80093b:	75 23                	jne    800960 <memset+0x40>
		c &= 0xFF;
  80093d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800941:	89 d3                	mov    %edx,%ebx
  800943:	c1 e3 08             	shl    $0x8,%ebx
  800946:	89 d6                	mov    %edx,%esi
  800948:	c1 e6 18             	shl    $0x18,%esi
  80094b:	89 d0                	mov    %edx,%eax
  80094d:	c1 e0 10             	shl    $0x10,%eax
  800950:	09 f0                	or     %esi,%eax
  800952:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800954:	89 d8                	mov    %ebx,%eax
  800956:	09 d0                	or     %edx,%eax
  800958:	c1 e9 02             	shr    $0x2,%ecx
  80095b:	fc                   	cld    
  80095c:	f3 ab                	rep stos %eax,%es:(%edi)
  80095e:	eb 06                	jmp    800966 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800960:	8b 45 0c             	mov    0xc(%ebp),%eax
  800963:	fc                   	cld    
  800964:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800966:	89 f8                	mov    %edi,%eax
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5f                   	pop    %edi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	57                   	push   %edi
  800971:	56                   	push   %esi
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 75 0c             	mov    0xc(%ebp),%esi
  800978:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097b:	39 c6                	cmp    %eax,%esi
  80097d:	73 35                	jae    8009b4 <memmove+0x47>
  80097f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800982:	39 d0                	cmp    %edx,%eax
  800984:	73 2e                	jae    8009b4 <memmove+0x47>
		s += n;
		d += n;
  800986:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800989:	89 d6                	mov    %edx,%esi
  80098b:	09 fe                	or     %edi,%esi
  80098d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800993:	75 13                	jne    8009a8 <memmove+0x3b>
  800995:	f6 c1 03             	test   $0x3,%cl
  800998:	75 0e                	jne    8009a8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80099a:	83 ef 04             	sub    $0x4,%edi
  80099d:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a0:	c1 e9 02             	shr    $0x2,%ecx
  8009a3:	fd                   	std    
  8009a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a6:	eb 09                	jmp    8009b1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a8:	83 ef 01             	sub    $0x1,%edi
  8009ab:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009ae:	fd                   	std    
  8009af:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b1:	fc                   	cld    
  8009b2:	eb 1d                	jmp    8009d1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b4:	89 f2                	mov    %esi,%edx
  8009b6:	09 c2                	or     %eax,%edx
  8009b8:	f6 c2 03             	test   $0x3,%dl
  8009bb:	75 0f                	jne    8009cc <memmove+0x5f>
  8009bd:	f6 c1 03             	test   $0x3,%cl
  8009c0:	75 0a                	jne    8009cc <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009c2:	c1 e9 02             	shr    $0x2,%ecx
  8009c5:	89 c7                	mov    %eax,%edi
  8009c7:	fc                   	cld    
  8009c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ca:	eb 05                	jmp    8009d1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009cc:	89 c7                	mov    %eax,%edi
  8009ce:	fc                   	cld    
  8009cf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d1:	5e                   	pop    %esi
  8009d2:	5f                   	pop    %edi
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d8:	ff 75 10             	pushl  0x10(%ebp)
  8009db:	ff 75 0c             	pushl  0xc(%ebp)
  8009de:	ff 75 08             	pushl  0x8(%ebp)
  8009e1:	e8 87 ff ff ff       	call   80096d <memmove>
}
  8009e6:	c9                   	leave  
  8009e7:	c3                   	ret    

008009e8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f3:	89 c6                	mov    %eax,%esi
  8009f5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f8:	eb 1a                	jmp    800a14 <memcmp+0x2c>
		if (*s1 != *s2)
  8009fa:	0f b6 08             	movzbl (%eax),%ecx
  8009fd:	0f b6 1a             	movzbl (%edx),%ebx
  800a00:	38 d9                	cmp    %bl,%cl
  800a02:	74 0a                	je     800a0e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a04:	0f b6 c1             	movzbl %cl,%eax
  800a07:	0f b6 db             	movzbl %bl,%ebx
  800a0a:	29 d8                	sub    %ebx,%eax
  800a0c:	eb 0f                	jmp    800a1d <memcmp+0x35>
		s1++, s2++;
  800a0e:	83 c0 01             	add    $0x1,%eax
  800a11:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a14:	39 f0                	cmp    %esi,%eax
  800a16:	75 e2                	jne    8009fa <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1d:	5b                   	pop    %ebx
  800a1e:	5e                   	pop    %esi
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	53                   	push   %ebx
  800a25:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a28:	89 c1                	mov    %eax,%ecx
  800a2a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a31:	eb 0a                	jmp    800a3d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a33:	0f b6 10             	movzbl (%eax),%edx
  800a36:	39 da                	cmp    %ebx,%edx
  800a38:	74 07                	je     800a41 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	39 c8                	cmp    %ecx,%eax
  800a3f:	72 f2                	jb     800a33 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a41:	5b                   	pop    %ebx
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	57                   	push   %edi
  800a48:	56                   	push   %esi
  800a49:	53                   	push   %ebx
  800a4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a50:	eb 03                	jmp    800a55 <strtol+0x11>
		s++;
  800a52:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a55:	0f b6 01             	movzbl (%ecx),%eax
  800a58:	3c 20                	cmp    $0x20,%al
  800a5a:	74 f6                	je     800a52 <strtol+0xe>
  800a5c:	3c 09                	cmp    $0x9,%al
  800a5e:	74 f2                	je     800a52 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a60:	3c 2b                	cmp    $0x2b,%al
  800a62:	75 0a                	jne    800a6e <strtol+0x2a>
		s++;
  800a64:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a67:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6c:	eb 11                	jmp    800a7f <strtol+0x3b>
  800a6e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a73:	3c 2d                	cmp    $0x2d,%al
  800a75:	75 08                	jne    800a7f <strtol+0x3b>
		s++, neg = 1;
  800a77:	83 c1 01             	add    $0x1,%ecx
  800a7a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a85:	75 15                	jne    800a9c <strtol+0x58>
  800a87:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8a:	75 10                	jne    800a9c <strtol+0x58>
  800a8c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a90:	75 7c                	jne    800b0e <strtol+0xca>
		s += 2, base = 16;
  800a92:	83 c1 02             	add    $0x2,%ecx
  800a95:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9a:	eb 16                	jmp    800ab2 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a9c:	85 db                	test   %ebx,%ebx
  800a9e:	75 12                	jne    800ab2 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa5:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa8:	75 08                	jne    800ab2 <strtol+0x6e>
		s++, base = 8;
  800aaa:	83 c1 01             	add    $0x1,%ecx
  800aad:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aba:	0f b6 11             	movzbl (%ecx),%edx
  800abd:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ac0:	89 f3                	mov    %esi,%ebx
  800ac2:	80 fb 09             	cmp    $0x9,%bl
  800ac5:	77 08                	ja     800acf <strtol+0x8b>
			dig = *s - '0';
  800ac7:	0f be d2             	movsbl %dl,%edx
  800aca:	83 ea 30             	sub    $0x30,%edx
  800acd:	eb 22                	jmp    800af1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800acf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad2:	89 f3                	mov    %esi,%ebx
  800ad4:	80 fb 19             	cmp    $0x19,%bl
  800ad7:	77 08                	ja     800ae1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ad9:	0f be d2             	movsbl %dl,%edx
  800adc:	83 ea 57             	sub    $0x57,%edx
  800adf:	eb 10                	jmp    800af1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ae1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae4:	89 f3                	mov    %esi,%ebx
  800ae6:	80 fb 19             	cmp    $0x19,%bl
  800ae9:	77 16                	ja     800b01 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aeb:	0f be d2             	movsbl %dl,%edx
  800aee:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800af1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af4:	7d 0b                	jge    800b01 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800af6:	83 c1 01             	add    $0x1,%ecx
  800af9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800afd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aff:	eb b9                	jmp    800aba <strtol+0x76>

	if (endptr)
  800b01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b05:	74 0d                	je     800b14 <strtol+0xd0>
		*endptr = (char *) s;
  800b07:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0a:	89 0e                	mov    %ecx,(%esi)
  800b0c:	eb 06                	jmp    800b14 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b0e:	85 db                	test   %ebx,%ebx
  800b10:	74 98                	je     800aaa <strtol+0x66>
  800b12:	eb 9e                	jmp    800ab2 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b14:	89 c2                	mov    %eax,%edx
  800b16:	f7 da                	neg    %edx
  800b18:	85 ff                	test   %edi,%edi
  800b1a:	0f 45 c2             	cmovne %edx,%eax
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    
  800b22:	66 90                	xchg   %ax,%ax
  800b24:	66 90                	xchg   %ax,%ax
  800b26:	66 90                	xchg   %ax,%ax
  800b28:	66 90                	xchg   %ax,%ax
  800b2a:	66 90                	xchg   %ax,%ax
  800b2c:	66 90                	xchg   %ax,%ax
  800b2e:	66 90                	xchg   %ax,%ax

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
