
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 aa 01 00 00       	call   8001db <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 96 0c 00 00       	call   800ce0 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 20 11 80 00       	push   $0x801120
  800057:	6a 20                	push   $0x20
  800059:	68 33 11 80 00       	push   $0x801133
  80005e:	e8 da 01 00 00       	call   80023d <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 ad 0c 00 00       	call   800d23 <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 43 11 80 00       	push   $0x801143
  800083:	6a 22                	push   $0x22
  800085:	68 33 11 80 00       	push   $0x801133
  80008a:	e8 ae 01 00 00       	call   80023d <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 cd 09 00 00       	call   800a6f <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 b4 0c 00 00       	call   800d65 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 54 11 80 00       	push   $0x801154
  8000be:	6a 25                	push   $0x25
  8000c0:	68 33 11 80 00       	push   $0x801133
  8000c5:	e8 73 01 00 00       	call   80023d <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <dumbfork+0x27>
		panic("sys_exofork: %e", envid);
  8000e6:	50                   	push   %eax
  8000e7:	68 67 11 80 00       	push   $0x801167
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 33 11 80 00       	push   $0x801133
  8000f3:	e8 45 01 00 00       	call   80023d <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1e                	jne    80011c <dumbfork+0x4b>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 9f 0b 00 00       	call   800ca2 <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800115:	b8 00 00 00 00       	mov    $0x0,%eax
  80011a:	eb 60                	jmp    80017c <dumbfork+0xab>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800123:	eb 14                	jmp    800139 <dumbfork+0x68>
		duppage(envid, addr);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	52                   	push   %edx
  800129:	56                   	push   %esi
  80012a:	e8 04 ff ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80012f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013c:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  800142:	72 e1                	jb     800125 <dumbfork+0x54>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80014f:	50                   	push   %eax
  800150:	53                   	push   %ebx
  800151:	e8 dd fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	6a 02                	push   $0x2
  80015b:	53                   	push   %ebx
  80015c:	e8 46 0c 00 00       	call   800da7 <sys_env_set_status>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	79 12                	jns    80017a <dumbfork+0xa9>
		panic("sys_env_set_status: %e", r);
  800168:	50                   	push   %eax
  800169:	68 77 11 80 00       	push   $0x801177
  80016e:	6a 4c                	push   $0x4c
  800170:	68 33 11 80 00       	push   $0x801133
  800175:	e8 c3 00 00 00       	call   80023d <_panic>

	return envid;
  80017a:	89 d8                	mov    %ebx,%eax
}
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80018c:	e8 40 ff ff ff       	call   8000d1 <dumbfork>
  800191:	89 c7                	mov    %eax,%edi
  800193:	85 c0                	test   %eax,%eax
  800195:	be 95 11 80 00       	mov    $0x801195,%esi
  80019a:	b8 8e 11 80 00       	mov    $0x80118e,%eax
  80019f:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a7:	eb 1a                	jmp    8001c3 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a9:	83 ec 04             	sub    $0x4,%esp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	68 9b 11 80 00       	push   $0x80119b
  8001b3:	e8 5e 01 00 00       	call   800316 <cprintf>
		sys_yield();
  8001b8:	e8 04 0b 00 00       	call   800cc1 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001bd:	83 c3 01             	add    $0x1,%ebx
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 ff                	test   %edi,%edi
  8001c5:	74 07                	je     8001ce <umain+0x4b>
  8001c7:	83 fb 09             	cmp    $0x9,%ebx
  8001ca:	7e dd                	jle    8001a9 <umain+0x26>
  8001cc:	eb 05                	jmp    8001d3 <umain+0x50>
  8001ce:	83 fb 13             	cmp    $0x13,%ebx
  8001d1:	7e d6                	jle    8001a9 <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e3:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8001e6:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8001ed:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  8001f0:	e8 ad 0a 00 00       	call   800ca2 <sys_getenvid>
  8001f5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001fa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800202:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800207:	85 db                	test   %ebx,%ebx
  800209:	7e 07                	jle    800212 <libmain+0x37>
		binaryname = argv[0];
  80020b:	8b 06                	mov    (%esi),%eax
  80020d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800212:	83 ec 08             	sub    $0x8,%esp
  800215:	56                   	push   %esi
  800216:	53                   	push   %ebx
  800217:	e8 67 ff ff ff       	call   800183 <umain>

	// exit gracefully
	exit();
  80021c:	e8 0a 00 00 00       	call   80022b <exit>
}
  800221:	83 c4 10             	add    $0x10,%esp
  800224:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800227:	5b                   	pop    %ebx
  800228:	5e                   	pop    %esi
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800231:	6a 00                	push   $0x0
  800233:	e8 29 0a 00 00       	call   800c61 <sys_env_destroy>
}
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	c9                   	leave  
  80023c:	c3                   	ret    

0080023d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	56                   	push   %esi
  800241:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800242:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800245:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80024b:	e8 52 0a 00 00       	call   800ca2 <sys_getenvid>
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	ff 75 0c             	pushl  0xc(%ebp)
  800256:	ff 75 08             	pushl  0x8(%ebp)
  800259:	56                   	push   %esi
  80025a:	50                   	push   %eax
  80025b:	68 b8 11 80 00       	push   $0x8011b8
  800260:	e8 b1 00 00 00       	call   800316 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800265:	83 c4 18             	add    $0x18,%esp
  800268:	53                   	push   %ebx
  800269:	ff 75 10             	pushl  0x10(%ebp)
  80026c:	e8 54 00 00 00       	call   8002c5 <vcprintf>
	cprintf("\n");
  800271:	c7 04 24 ab 11 80 00 	movl   $0x8011ab,(%esp)
  800278:	e8 99 00 00 00       	call   800316 <cprintf>
  80027d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800280:	cc                   	int3   
  800281:	eb fd                	jmp    800280 <_panic+0x43>

00800283 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	53                   	push   %ebx
  800287:	83 ec 04             	sub    $0x4,%esp
  80028a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80028d:	8b 13                	mov    (%ebx),%edx
  80028f:	8d 42 01             	lea    0x1(%edx),%eax
  800292:	89 03                	mov    %eax,(%ebx)
  800294:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800297:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80029b:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a0:	75 1a                	jne    8002bc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a2:	83 ec 08             	sub    $0x8,%esp
  8002a5:	68 ff 00 00 00       	push   $0xff
  8002aa:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ad:	50                   	push   %eax
  8002ae:	e8 71 09 00 00       	call   800c24 <sys_cputs>
		b->idx = 0;
  8002b3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002bc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    

008002c5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002ce:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d5:	00 00 00 
	b.cnt = 0;
  8002d8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002df:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e2:	ff 75 0c             	pushl  0xc(%ebp)
  8002e5:	ff 75 08             	pushl  0x8(%ebp)
  8002e8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ee:	50                   	push   %eax
  8002ef:	68 83 02 80 00       	push   $0x800283
  8002f4:	e8 54 01 00 00       	call   80044d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f9:	83 c4 08             	add    $0x8,%esp
  8002fc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800302:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800308:	50                   	push   %eax
  800309:	e8 16 09 00 00       	call   800c24 <sys_cputs>

	return b.cnt;
}
  80030e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800314:	c9                   	leave  
  800315:	c3                   	ret    

00800316 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80031c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80031f:	50                   	push   %eax
  800320:	ff 75 08             	pushl  0x8(%ebp)
  800323:	e8 9d ff ff ff       	call   8002c5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800328:	c9                   	leave  
  800329:	c3                   	ret    

0080032a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	57                   	push   %edi
  80032e:	56                   	push   %esi
  80032f:	53                   	push   %ebx
  800330:	83 ec 1c             	sub    $0x1c,%esp
  800333:	89 c7                	mov    %eax,%edi
  800335:	89 d6                	mov    %edx,%esi
  800337:	8b 45 08             	mov    0x8(%ebp),%eax
  80033a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80033d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800340:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800343:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800346:	bb 00 00 00 00       	mov    $0x0,%ebx
  80034b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80034e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800351:	39 d3                	cmp    %edx,%ebx
  800353:	72 05                	jb     80035a <printnum+0x30>
  800355:	39 45 10             	cmp    %eax,0x10(%ebp)
  800358:	77 45                	ja     80039f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80035a:	83 ec 0c             	sub    $0xc,%esp
  80035d:	ff 75 18             	pushl  0x18(%ebp)
  800360:	8b 45 14             	mov    0x14(%ebp),%eax
  800363:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800366:	53                   	push   %ebx
  800367:	ff 75 10             	pushl  0x10(%ebp)
  80036a:	83 ec 08             	sub    $0x8,%esp
  80036d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800370:	ff 75 e0             	pushl  -0x20(%ebp)
  800373:	ff 75 dc             	pushl  -0x24(%ebp)
  800376:	ff 75 d8             	pushl  -0x28(%ebp)
  800379:	e8 12 0b 00 00       	call   800e90 <__udivdi3>
  80037e:	83 c4 18             	add    $0x18,%esp
  800381:	52                   	push   %edx
  800382:	50                   	push   %eax
  800383:	89 f2                	mov    %esi,%edx
  800385:	89 f8                	mov    %edi,%eax
  800387:	e8 9e ff ff ff       	call   80032a <printnum>
  80038c:	83 c4 20             	add    $0x20,%esp
  80038f:	eb 18                	jmp    8003a9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800391:	83 ec 08             	sub    $0x8,%esp
  800394:	56                   	push   %esi
  800395:	ff 75 18             	pushl  0x18(%ebp)
  800398:	ff d7                	call   *%edi
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	eb 03                	jmp    8003a2 <printnum+0x78>
  80039f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a2:	83 eb 01             	sub    $0x1,%ebx
  8003a5:	85 db                	test   %ebx,%ebx
  8003a7:	7f e8                	jg     800391 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a9:	83 ec 08             	sub    $0x8,%esp
  8003ac:	56                   	push   %esi
  8003ad:	83 ec 04             	sub    $0x4,%esp
  8003b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003bc:	e8 ff 0b 00 00       	call   800fc0 <__umoddi3>
  8003c1:	83 c4 14             	add    $0x14,%esp
  8003c4:	0f be 80 dc 11 80 00 	movsbl 0x8011dc(%eax),%eax
  8003cb:	50                   	push   %eax
  8003cc:	ff d7                	call   *%edi
}
  8003ce:	83 c4 10             	add    $0x10,%esp
  8003d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d4:	5b                   	pop    %ebx
  8003d5:	5e                   	pop    %esi
  8003d6:	5f                   	pop    %edi
  8003d7:	5d                   	pop    %ebp
  8003d8:	c3                   	ret    

008003d9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d9:	55                   	push   %ebp
  8003da:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003dc:	83 fa 01             	cmp    $0x1,%edx
  8003df:	7e 0e                	jle    8003ef <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e1:	8b 10                	mov    (%eax),%edx
  8003e3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e6:	89 08                	mov    %ecx,(%eax)
  8003e8:	8b 02                	mov    (%edx),%eax
  8003ea:	8b 52 04             	mov    0x4(%edx),%edx
  8003ed:	eb 22                	jmp    800411 <getuint+0x38>
	else if (lflag)
  8003ef:	85 d2                	test   %edx,%edx
  8003f1:	74 10                	je     800403 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f3:	8b 10                	mov    (%eax),%edx
  8003f5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f8:	89 08                	mov    %ecx,(%eax)
  8003fa:	8b 02                	mov    (%edx),%eax
  8003fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800401:	eb 0e                	jmp    800411 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800403:	8b 10                	mov    (%eax),%edx
  800405:	8d 4a 04             	lea    0x4(%edx),%ecx
  800408:	89 08                	mov    %ecx,(%eax)
  80040a:	8b 02                	mov    (%edx),%eax
  80040c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800419:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80041d:	8b 10                	mov    (%eax),%edx
  80041f:	3b 50 04             	cmp    0x4(%eax),%edx
  800422:	73 0a                	jae    80042e <sprintputch+0x1b>
		*b->buf++ = ch;
  800424:	8d 4a 01             	lea    0x1(%edx),%ecx
  800427:	89 08                	mov    %ecx,(%eax)
  800429:	8b 45 08             	mov    0x8(%ebp),%eax
  80042c:	88 02                	mov    %al,(%edx)
}
  80042e:	5d                   	pop    %ebp
  80042f:	c3                   	ret    

00800430 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800436:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800439:	50                   	push   %eax
  80043a:	ff 75 10             	pushl  0x10(%ebp)
  80043d:	ff 75 0c             	pushl  0xc(%ebp)
  800440:	ff 75 08             	pushl  0x8(%ebp)
  800443:	e8 05 00 00 00       	call   80044d <vprintfmt>
	va_end(ap);
}
  800448:	83 c4 10             	add    $0x10,%esp
  80044b:	c9                   	leave  
  80044c:	c3                   	ret    

0080044d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044d:	55                   	push   %ebp
  80044e:	89 e5                	mov    %esp,%ebp
  800450:	57                   	push   %edi
  800451:	56                   	push   %esi
  800452:	53                   	push   %ebx
  800453:	83 ec 2c             	sub    $0x2c,%esp
  800456:	8b 75 08             	mov    0x8(%ebp),%esi
  800459:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80045c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80045f:	eb 12                	jmp    800473 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800461:	85 c0                	test   %eax,%eax
  800463:	0f 84 cb 03 00 00    	je     800834 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	53                   	push   %ebx
  80046d:	50                   	push   %eax
  80046e:	ff d6                	call   *%esi
  800470:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800473:	83 c7 01             	add    $0x1,%edi
  800476:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80047a:	83 f8 25             	cmp    $0x25,%eax
  80047d:	75 e2                	jne    800461 <vprintfmt+0x14>
  80047f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800483:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80048a:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800491:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800498:	ba 00 00 00 00       	mov    $0x0,%edx
  80049d:	eb 07                	jmp    8004a6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8d 47 01             	lea    0x1(%edi),%eax
  8004a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ac:	0f b6 07             	movzbl (%edi),%eax
  8004af:	0f b6 c8             	movzbl %al,%ecx
  8004b2:	83 e8 23             	sub    $0x23,%eax
  8004b5:	3c 55                	cmp    $0x55,%al
  8004b7:	0f 87 5c 03 00 00    	ja     800819 <vprintfmt+0x3cc>
  8004bd:	0f b6 c0             	movzbl %al,%eax
  8004c0:	ff 24 85 c0 12 80 00 	jmp    *0x8012c0(,%eax,4)
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004ca:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004ce:	eb d6                	jmp    8004a6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004db:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004de:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004e2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004e5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004e8:	83 fa 09             	cmp    $0x9,%edx
  8004eb:	77 39                	ja     800526 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ed:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f0:	eb e9                	jmp    8004db <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f5:	8d 48 04             	lea    0x4(%eax),%ecx
  8004f8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004fb:	8b 00                	mov    (%eax),%eax
  8004fd:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800500:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800503:	eb 27                	jmp    80052c <vprintfmt+0xdf>
  800505:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800508:	85 c0                	test   %eax,%eax
  80050a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80050f:	0f 49 c8             	cmovns %eax,%ecx
  800512:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800518:	eb 8c                	jmp    8004a6 <vprintfmt+0x59>
  80051a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80051d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800524:	eb 80                	jmp    8004a6 <vprintfmt+0x59>
  800526:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800529:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80052c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800530:	0f 89 70 ff ff ff    	jns    8004a6 <vprintfmt+0x59>
				width = precision, precision = -1;
  800536:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800539:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80053c:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800543:	e9 5e ff ff ff       	jmp    8004a6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800548:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80054e:	e9 53 ff ff ff       	jmp    8004a6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8d 50 04             	lea    0x4(%eax),%edx
  800559:	89 55 14             	mov    %edx,0x14(%ebp)
  80055c:	83 ec 08             	sub    $0x8,%esp
  80055f:	53                   	push   %ebx
  800560:	ff 30                	pushl  (%eax)
  800562:	ff d6                	call   *%esi
			break;
  800564:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80056a:	e9 04 ff ff ff       	jmp    800473 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8d 50 04             	lea    0x4(%eax),%edx
  800575:	89 55 14             	mov    %edx,0x14(%ebp)
  800578:	8b 00                	mov    (%eax),%eax
  80057a:	99                   	cltd   
  80057b:	31 d0                	xor    %edx,%eax
  80057d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80057f:	83 f8 09             	cmp    $0x9,%eax
  800582:	7f 0b                	jg     80058f <vprintfmt+0x142>
  800584:	8b 14 85 20 14 80 00 	mov    0x801420(,%eax,4),%edx
  80058b:	85 d2                	test   %edx,%edx
  80058d:	75 18                	jne    8005a7 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80058f:	50                   	push   %eax
  800590:	68 f4 11 80 00       	push   $0x8011f4
  800595:	53                   	push   %ebx
  800596:	56                   	push   %esi
  800597:	e8 94 fe ff ff       	call   800430 <printfmt>
  80059c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a2:	e9 cc fe ff ff       	jmp    800473 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a7:	52                   	push   %edx
  8005a8:	68 fd 11 80 00       	push   $0x8011fd
  8005ad:	53                   	push   %ebx
  8005ae:	56                   	push   %esi
  8005af:	e8 7c fe ff ff       	call   800430 <printfmt>
  8005b4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ba:	e9 b4 fe ff ff       	jmp    800473 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8d 50 04             	lea    0x4(%eax),%edx
  8005c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c8:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005ca:	85 ff                	test   %edi,%edi
  8005cc:	b8 ed 11 80 00       	mov    $0x8011ed,%eax
  8005d1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d8:	0f 8e 94 00 00 00    	jle    800672 <vprintfmt+0x225>
  8005de:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e2:	0f 84 98 00 00 00    	je     800680 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	ff 75 c8             	pushl  -0x38(%ebp)
  8005ee:	57                   	push   %edi
  8005ef:	e8 c8 02 00 00       	call   8008bc <strnlen>
  8005f4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f7:	29 c1                	sub    %eax,%ecx
  8005f9:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005fc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005ff:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800603:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800606:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800609:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060b:	eb 0f                	jmp    80061c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	ff 75 e0             	pushl  -0x20(%ebp)
  800614:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800616:	83 ef 01             	sub    $0x1,%edi
  800619:	83 c4 10             	add    $0x10,%esp
  80061c:	85 ff                	test   %edi,%edi
  80061e:	7f ed                	jg     80060d <vprintfmt+0x1c0>
  800620:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800623:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800626:	85 c9                	test   %ecx,%ecx
  800628:	b8 00 00 00 00       	mov    $0x0,%eax
  80062d:	0f 49 c1             	cmovns %ecx,%eax
  800630:	29 c1                	sub    %eax,%ecx
  800632:	89 75 08             	mov    %esi,0x8(%ebp)
  800635:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800638:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80063b:	89 cb                	mov    %ecx,%ebx
  80063d:	eb 4d                	jmp    80068c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800643:	74 1b                	je     800660 <vprintfmt+0x213>
  800645:	0f be c0             	movsbl %al,%eax
  800648:	83 e8 20             	sub    $0x20,%eax
  80064b:	83 f8 5e             	cmp    $0x5e,%eax
  80064e:	76 10                	jbe    800660 <vprintfmt+0x213>
					putch('?', putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	ff 75 0c             	pushl  0xc(%ebp)
  800656:	6a 3f                	push   $0x3f
  800658:	ff 55 08             	call   *0x8(%ebp)
  80065b:	83 c4 10             	add    $0x10,%esp
  80065e:	eb 0d                	jmp    80066d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	ff 75 0c             	pushl  0xc(%ebp)
  800666:	52                   	push   %edx
  800667:	ff 55 08             	call   *0x8(%ebp)
  80066a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066d:	83 eb 01             	sub    $0x1,%ebx
  800670:	eb 1a                	jmp    80068c <vprintfmt+0x23f>
  800672:	89 75 08             	mov    %esi,0x8(%ebp)
  800675:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800678:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80067b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80067e:	eb 0c                	jmp    80068c <vprintfmt+0x23f>
  800680:	89 75 08             	mov    %esi,0x8(%ebp)
  800683:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800686:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800689:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80068c:	83 c7 01             	add    $0x1,%edi
  80068f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800693:	0f be d0             	movsbl %al,%edx
  800696:	85 d2                	test   %edx,%edx
  800698:	74 23                	je     8006bd <vprintfmt+0x270>
  80069a:	85 f6                	test   %esi,%esi
  80069c:	78 a1                	js     80063f <vprintfmt+0x1f2>
  80069e:	83 ee 01             	sub    $0x1,%esi
  8006a1:	79 9c                	jns    80063f <vprintfmt+0x1f2>
  8006a3:	89 df                	mov    %ebx,%edi
  8006a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ab:	eb 18                	jmp    8006c5 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	6a 20                	push   $0x20
  8006b3:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006b5:	83 ef 01             	sub    $0x1,%edi
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	eb 08                	jmp    8006c5 <vprintfmt+0x278>
  8006bd:	89 df                	mov    %ebx,%edi
  8006bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006c5:	85 ff                	test   %edi,%edi
  8006c7:	7f e4                	jg     8006ad <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006cc:	e9 a2 fd ff ff       	jmp    800473 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d1:	83 fa 01             	cmp    $0x1,%edx
  8006d4:	7e 16                	jle    8006ec <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8d 50 08             	lea    0x8(%eax),%edx
  8006dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006df:	8b 50 04             	mov    0x4(%eax),%edx
  8006e2:	8b 00                	mov    (%eax),%eax
  8006e4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006e7:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8006ea:	eb 32                	jmp    80071e <vprintfmt+0x2d1>
	else if (lflag)
  8006ec:	85 d2                	test   %edx,%edx
  8006ee:	74 18                	je     800708 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8d 50 04             	lea    0x4(%eax),%edx
  8006f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f9:	8b 00                	mov    (%eax),%eax
  8006fb:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006fe:	89 c1                	mov    %eax,%ecx
  800700:	c1 f9 1f             	sar    $0x1f,%ecx
  800703:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800706:	eb 16                	jmp    80071e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8d 50 04             	lea    0x4(%eax),%edx
  80070e:	89 55 14             	mov    %edx,0x14(%ebp)
  800711:	8b 00                	mov    (%eax),%eax
  800713:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800716:	89 c1                	mov    %eax,%ecx
  800718:	c1 f9 1f             	sar    $0x1f,%ecx
  80071b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80071e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800721:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800724:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800727:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80072a:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80072f:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800733:	0f 89 a8 00 00 00    	jns    8007e1 <vprintfmt+0x394>
				putch('-', putdat);
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	53                   	push   %ebx
  80073d:	6a 2d                	push   $0x2d
  80073f:	ff d6                	call   *%esi
				num = -(long long) num;
  800741:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800744:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800747:	f7 d8                	neg    %eax
  800749:	83 d2 00             	adc    $0x0,%edx
  80074c:	f7 da                	neg    %edx
  80074e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800751:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800754:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800757:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075c:	e9 80 00 00 00       	jmp    8007e1 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800761:	8d 45 14             	lea    0x14(%ebp),%eax
  800764:	e8 70 fc ff ff       	call   8003d9 <getuint>
  800769:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80076f:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800774:	eb 6b                	jmp    8007e1 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800776:	8d 45 14             	lea    0x14(%ebp),%eax
  800779:	e8 5b fc ff ff       	call   8003d9 <getuint>
  80077e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800781:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800784:	6a 04                	push   $0x4
  800786:	6a 03                	push   $0x3
  800788:	6a 01                	push   $0x1
  80078a:	68 00 12 80 00       	push   $0x801200
  80078f:	e8 82 fb ff ff       	call   800316 <cprintf>
			goto number;
  800794:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  800797:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  80079c:	eb 43                	jmp    8007e1 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  80079e:	83 ec 08             	sub    $0x8,%esp
  8007a1:	53                   	push   %ebx
  8007a2:	6a 30                	push   $0x30
  8007a4:	ff d6                	call   *%esi
			putch('x', putdat);
  8007a6:	83 c4 08             	add    $0x8,%esp
  8007a9:	53                   	push   %ebx
  8007aa:	6a 78                	push   $0x78
  8007ac:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8d 50 04             	lea    0x4(%eax),%edx
  8007b4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007b7:	8b 00                	mov    (%eax),%eax
  8007b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007c4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8007c7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007cc:	eb 13                	jmp    8007e1 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d1:	e8 03 fc ff ff       	call   8003d9 <getuint>
  8007d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d9:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8007dc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007e1:	83 ec 0c             	sub    $0xc,%esp
  8007e4:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8007e8:	52                   	push   %edx
  8007e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ec:	50                   	push   %eax
  8007ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8007f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8007f3:	89 da                	mov    %ebx,%edx
  8007f5:	89 f0                	mov    %esi,%eax
  8007f7:	e8 2e fb ff ff       	call   80032a <printnum>

			break;
  8007fc:	83 c4 20             	add    $0x20,%esp
  8007ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800802:	e9 6c fc ff ff       	jmp    800473 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800807:	83 ec 08             	sub    $0x8,%esp
  80080a:	53                   	push   %ebx
  80080b:	51                   	push   %ecx
  80080c:	ff d6                	call   *%esi
			break;
  80080e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800811:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800814:	e9 5a fc ff ff       	jmp    800473 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800819:	83 ec 08             	sub    $0x8,%esp
  80081c:	53                   	push   %ebx
  80081d:	6a 25                	push   $0x25
  80081f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800821:	83 c4 10             	add    $0x10,%esp
  800824:	eb 03                	jmp    800829 <vprintfmt+0x3dc>
  800826:	83 ef 01             	sub    $0x1,%edi
  800829:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80082d:	75 f7                	jne    800826 <vprintfmt+0x3d9>
  80082f:	e9 3f fc ff ff       	jmp    800473 <vprintfmt+0x26>
			break;
		}

	}

}
  800834:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800837:	5b                   	pop    %ebx
  800838:	5e                   	pop    %esi
  800839:	5f                   	pop    %edi
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	83 ec 18             	sub    $0x18,%esp
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800848:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80084f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800852:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800859:	85 c0                	test   %eax,%eax
  80085b:	74 26                	je     800883 <vsnprintf+0x47>
  80085d:	85 d2                	test   %edx,%edx
  80085f:	7e 22                	jle    800883 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800861:	ff 75 14             	pushl  0x14(%ebp)
  800864:	ff 75 10             	pushl  0x10(%ebp)
  800867:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086a:	50                   	push   %eax
  80086b:	68 13 04 80 00       	push   $0x800413
  800870:	e8 d8 fb ff ff       	call   80044d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800875:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800878:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087e:	83 c4 10             	add    $0x10,%esp
  800881:	eb 05                	jmp    800888 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800883:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800890:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800893:	50                   	push   %eax
  800894:	ff 75 10             	pushl  0x10(%ebp)
  800897:	ff 75 0c             	pushl  0xc(%ebp)
  80089a:	ff 75 08             	pushl  0x8(%ebp)
  80089d:	e8 9a ff ff ff       	call   80083c <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a2:	c9                   	leave  
  8008a3:	c3                   	ret    

008008a4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8008af:	eb 03                	jmp    8008b4 <strlen+0x10>
		n++;
  8008b1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b8:	75 f7                	jne    8008b1 <strlen+0xd>
		n++;
	return n;
}
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ca:	eb 03                	jmp    8008cf <strnlen+0x13>
		n++;
  8008cc:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cf:	39 c2                	cmp    %eax,%edx
  8008d1:	74 08                	je     8008db <strnlen+0x1f>
  8008d3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008d7:	75 f3                	jne    8008cc <strnlen+0x10>
  8008d9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	53                   	push   %ebx
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e7:	89 c2                	mov    %eax,%edx
  8008e9:	83 c2 01             	add    $0x1,%edx
  8008ec:	83 c1 01             	add    $0x1,%ecx
  8008ef:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008f3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f6:	84 db                	test   %bl,%bl
  8008f8:	75 ef                	jne    8008e9 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008fa:	5b                   	pop    %ebx
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	53                   	push   %ebx
  800901:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800904:	53                   	push   %ebx
  800905:	e8 9a ff ff ff       	call   8008a4 <strlen>
  80090a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80090d:	ff 75 0c             	pushl  0xc(%ebp)
  800910:	01 d8                	add    %ebx,%eax
  800912:	50                   	push   %eax
  800913:	e8 c5 ff ff ff       	call   8008dd <strcpy>
	return dst;
}
  800918:	89 d8                	mov    %ebx,%eax
  80091a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80091d:	c9                   	leave  
  80091e:	c3                   	ret    

0080091f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	56                   	push   %esi
  800923:	53                   	push   %ebx
  800924:	8b 75 08             	mov    0x8(%ebp),%esi
  800927:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092a:	89 f3                	mov    %esi,%ebx
  80092c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80092f:	89 f2                	mov    %esi,%edx
  800931:	eb 0f                	jmp    800942 <strncpy+0x23>
		*dst++ = *src;
  800933:	83 c2 01             	add    $0x1,%edx
  800936:	0f b6 01             	movzbl (%ecx),%eax
  800939:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80093c:	80 39 01             	cmpb   $0x1,(%ecx)
  80093f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800942:	39 da                	cmp    %ebx,%edx
  800944:	75 ed                	jne    800933 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800946:	89 f0                	mov    %esi,%eax
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	56                   	push   %esi
  800950:	53                   	push   %ebx
  800951:	8b 75 08             	mov    0x8(%ebp),%esi
  800954:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800957:	8b 55 10             	mov    0x10(%ebp),%edx
  80095a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80095c:	85 d2                	test   %edx,%edx
  80095e:	74 21                	je     800981 <strlcpy+0x35>
  800960:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800964:	89 f2                	mov    %esi,%edx
  800966:	eb 09                	jmp    800971 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800968:	83 c2 01             	add    $0x1,%edx
  80096b:	83 c1 01             	add    $0x1,%ecx
  80096e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800971:	39 c2                	cmp    %eax,%edx
  800973:	74 09                	je     80097e <strlcpy+0x32>
  800975:	0f b6 19             	movzbl (%ecx),%ebx
  800978:	84 db                	test   %bl,%bl
  80097a:	75 ec                	jne    800968 <strlcpy+0x1c>
  80097c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80097e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800981:	29 f0                	sub    %esi,%eax
}
  800983:	5b                   	pop    %ebx
  800984:	5e                   	pop    %esi
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800990:	eb 06                	jmp    800998 <strcmp+0x11>
		p++, q++;
  800992:	83 c1 01             	add    $0x1,%ecx
  800995:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800998:	0f b6 01             	movzbl (%ecx),%eax
  80099b:	84 c0                	test   %al,%al
  80099d:	74 04                	je     8009a3 <strcmp+0x1c>
  80099f:	3a 02                	cmp    (%edx),%al
  8009a1:	74 ef                	je     800992 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a3:	0f b6 c0             	movzbl %al,%eax
  8009a6:	0f b6 12             	movzbl (%edx),%edx
  8009a9:	29 d0                	sub    %edx,%eax
}
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	53                   	push   %ebx
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b7:	89 c3                	mov    %eax,%ebx
  8009b9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009bc:	eb 06                	jmp    8009c4 <strncmp+0x17>
		n--, p++, q++;
  8009be:	83 c0 01             	add    $0x1,%eax
  8009c1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c4:	39 d8                	cmp    %ebx,%eax
  8009c6:	74 15                	je     8009dd <strncmp+0x30>
  8009c8:	0f b6 08             	movzbl (%eax),%ecx
  8009cb:	84 c9                	test   %cl,%cl
  8009cd:	74 04                	je     8009d3 <strncmp+0x26>
  8009cf:	3a 0a                	cmp    (%edx),%cl
  8009d1:	74 eb                	je     8009be <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d3:	0f b6 00             	movzbl (%eax),%eax
  8009d6:	0f b6 12             	movzbl (%edx),%edx
  8009d9:	29 d0                	sub    %edx,%eax
  8009db:	eb 05                	jmp    8009e2 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009dd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009e2:	5b                   	pop    %ebx
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ef:	eb 07                	jmp    8009f8 <strchr+0x13>
		if (*s == c)
  8009f1:	38 ca                	cmp    %cl,%dl
  8009f3:	74 0f                	je     800a04 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	0f b6 10             	movzbl (%eax),%edx
  8009fb:	84 d2                	test   %dl,%dl
  8009fd:	75 f2                	jne    8009f1 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a10:	eb 03                	jmp    800a15 <strfind+0xf>
  800a12:	83 c0 01             	add    $0x1,%eax
  800a15:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a18:	38 ca                	cmp    %cl,%dl
  800a1a:	74 04                	je     800a20 <strfind+0x1a>
  800a1c:	84 d2                	test   %dl,%dl
  800a1e:	75 f2                	jne    800a12 <strfind+0xc>
			break;
	return (char *) s;
}
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	57                   	push   %edi
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a2e:	85 c9                	test   %ecx,%ecx
  800a30:	74 36                	je     800a68 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a32:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a38:	75 28                	jne    800a62 <memset+0x40>
  800a3a:	f6 c1 03             	test   $0x3,%cl
  800a3d:	75 23                	jne    800a62 <memset+0x40>
		c &= 0xFF;
  800a3f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a43:	89 d3                	mov    %edx,%ebx
  800a45:	c1 e3 08             	shl    $0x8,%ebx
  800a48:	89 d6                	mov    %edx,%esi
  800a4a:	c1 e6 18             	shl    $0x18,%esi
  800a4d:	89 d0                	mov    %edx,%eax
  800a4f:	c1 e0 10             	shl    $0x10,%eax
  800a52:	09 f0                	or     %esi,%eax
  800a54:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a56:	89 d8                	mov    %ebx,%eax
  800a58:	09 d0                	or     %edx,%eax
  800a5a:	c1 e9 02             	shr    $0x2,%ecx
  800a5d:	fc                   	cld    
  800a5e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a60:	eb 06                	jmp    800a68 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a65:	fc                   	cld    
  800a66:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a68:	89 f8                	mov    %edi,%eax
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5f                   	pop    %edi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	57                   	push   %edi
  800a73:	56                   	push   %esi
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
  800a77:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a7d:	39 c6                	cmp    %eax,%esi
  800a7f:	73 35                	jae    800ab6 <memmove+0x47>
  800a81:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a84:	39 d0                	cmp    %edx,%eax
  800a86:	73 2e                	jae    800ab6 <memmove+0x47>
		s += n;
		d += n;
  800a88:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8b:	89 d6                	mov    %edx,%esi
  800a8d:	09 fe                	or     %edi,%esi
  800a8f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a95:	75 13                	jne    800aaa <memmove+0x3b>
  800a97:	f6 c1 03             	test   $0x3,%cl
  800a9a:	75 0e                	jne    800aaa <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a9c:	83 ef 04             	sub    $0x4,%edi
  800a9f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa2:	c1 e9 02             	shr    $0x2,%ecx
  800aa5:	fd                   	std    
  800aa6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa8:	eb 09                	jmp    800ab3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aaa:	83 ef 01             	sub    $0x1,%edi
  800aad:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ab0:	fd                   	std    
  800ab1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab3:	fc                   	cld    
  800ab4:	eb 1d                	jmp    800ad3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab6:	89 f2                	mov    %esi,%edx
  800ab8:	09 c2                	or     %eax,%edx
  800aba:	f6 c2 03             	test   $0x3,%dl
  800abd:	75 0f                	jne    800ace <memmove+0x5f>
  800abf:	f6 c1 03             	test   $0x3,%cl
  800ac2:	75 0a                	jne    800ace <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ac4:	c1 e9 02             	shr    $0x2,%ecx
  800ac7:	89 c7                	mov    %eax,%edi
  800ac9:	fc                   	cld    
  800aca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acc:	eb 05                	jmp    800ad3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ace:	89 c7                	mov    %eax,%edi
  800ad0:	fc                   	cld    
  800ad1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad3:	5e                   	pop    %esi
  800ad4:	5f                   	pop    %edi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ada:	ff 75 10             	pushl  0x10(%ebp)
  800add:	ff 75 0c             	pushl  0xc(%ebp)
  800ae0:	ff 75 08             	pushl  0x8(%ebp)
  800ae3:	e8 87 ff ff ff       	call   800a6f <memmove>
}
  800ae8:	c9                   	leave  
  800ae9:	c3                   	ret    

00800aea <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	56                   	push   %esi
  800aee:	53                   	push   %ebx
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af5:	89 c6                	mov    %eax,%esi
  800af7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afa:	eb 1a                	jmp    800b16 <memcmp+0x2c>
		if (*s1 != *s2)
  800afc:	0f b6 08             	movzbl (%eax),%ecx
  800aff:	0f b6 1a             	movzbl (%edx),%ebx
  800b02:	38 d9                	cmp    %bl,%cl
  800b04:	74 0a                	je     800b10 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b06:	0f b6 c1             	movzbl %cl,%eax
  800b09:	0f b6 db             	movzbl %bl,%ebx
  800b0c:	29 d8                	sub    %ebx,%eax
  800b0e:	eb 0f                	jmp    800b1f <memcmp+0x35>
		s1++, s2++;
  800b10:	83 c0 01             	add    $0x1,%eax
  800b13:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b16:	39 f0                	cmp    %esi,%eax
  800b18:	75 e2                	jne    800afc <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1f:	5b                   	pop    %ebx
  800b20:	5e                   	pop    %esi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	53                   	push   %ebx
  800b27:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b2a:	89 c1                	mov    %eax,%ecx
  800b2c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b2f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b33:	eb 0a                	jmp    800b3f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b35:	0f b6 10             	movzbl (%eax),%edx
  800b38:	39 da                	cmp    %ebx,%edx
  800b3a:	74 07                	je     800b43 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b3c:	83 c0 01             	add    $0x1,%eax
  800b3f:	39 c8                	cmp    %ecx,%eax
  800b41:	72 f2                	jb     800b35 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b43:	5b                   	pop    %ebx
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
  800b4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b52:	eb 03                	jmp    800b57 <strtol+0x11>
		s++;
  800b54:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b57:	0f b6 01             	movzbl (%ecx),%eax
  800b5a:	3c 20                	cmp    $0x20,%al
  800b5c:	74 f6                	je     800b54 <strtol+0xe>
  800b5e:	3c 09                	cmp    $0x9,%al
  800b60:	74 f2                	je     800b54 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b62:	3c 2b                	cmp    $0x2b,%al
  800b64:	75 0a                	jne    800b70 <strtol+0x2a>
		s++;
  800b66:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b69:	bf 00 00 00 00       	mov    $0x0,%edi
  800b6e:	eb 11                	jmp    800b81 <strtol+0x3b>
  800b70:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b75:	3c 2d                	cmp    $0x2d,%al
  800b77:	75 08                	jne    800b81 <strtol+0x3b>
		s++, neg = 1;
  800b79:	83 c1 01             	add    $0x1,%ecx
  800b7c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b81:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b87:	75 15                	jne    800b9e <strtol+0x58>
  800b89:	80 39 30             	cmpb   $0x30,(%ecx)
  800b8c:	75 10                	jne    800b9e <strtol+0x58>
  800b8e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b92:	75 7c                	jne    800c10 <strtol+0xca>
		s += 2, base = 16;
  800b94:	83 c1 02             	add    $0x2,%ecx
  800b97:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b9c:	eb 16                	jmp    800bb4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b9e:	85 db                	test   %ebx,%ebx
  800ba0:	75 12                	jne    800bb4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ba2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba7:	80 39 30             	cmpb   $0x30,(%ecx)
  800baa:	75 08                	jne    800bb4 <strtol+0x6e>
		s++, base = 8;
  800bac:	83 c1 01             	add    $0x1,%ecx
  800baf:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bbc:	0f b6 11             	movzbl (%ecx),%edx
  800bbf:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bc2:	89 f3                	mov    %esi,%ebx
  800bc4:	80 fb 09             	cmp    $0x9,%bl
  800bc7:	77 08                	ja     800bd1 <strtol+0x8b>
			dig = *s - '0';
  800bc9:	0f be d2             	movsbl %dl,%edx
  800bcc:	83 ea 30             	sub    $0x30,%edx
  800bcf:	eb 22                	jmp    800bf3 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800bd1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bd4:	89 f3                	mov    %esi,%ebx
  800bd6:	80 fb 19             	cmp    $0x19,%bl
  800bd9:	77 08                	ja     800be3 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bdb:	0f be d2             	movsbl %dl,%edx
  800bde:	83 ea 57             	sub    $0x57,%edx
  800be1:	eb 10                	jmp    800bf3 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800be3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800be6:	89 f3                	mov    %esi,%ebx
  800be8:	80 fb 19             	cmp    $0x19,%bl
  800beb:	77 16                	ja     800c03 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bed:	0f be d2             	movsbl %dl,%edx
  800bf0:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bf3:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bf6:	7d 0b                	jge    800c03 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bf8:	83 c1 01             	add    $0x1,%ecx
  800bfb:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bff:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c01:	eb b9                	jmp    800bbc <strtol+0x76>

	if (endptr)
  800c03:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c07:	74 0d                	je     800c16 <strtol+0xd0>
		*endptr = (char *) s;
  800c09:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c0c:	89 0e                	mov    %ecx,(%esi)
  800c0e:	eb 06                	jmp    800c16 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c10:	85 db                	test   %ebx,%ebx
  800c12:	74 98                	je     800bac <strtol+0x66>
  800c14:	eb 9e                	jmp    800bb4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c16:	89 c2                	mov    %eax,%edx
  800c18:	f7 da                	neg    %edx
  800c1a:	85 ff                	test   %edi,%edi
  800c1c:	0f 45 c2             	cmovne %edx,%eax
}
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	89 c3                	mov    %eax,%ebx
  800c37:	89 c7                	mov    %eax,%edi
  800c39:	89 c6                	mov    %eax,%esi
  800c3b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c48:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c52:	89 d1                	mov    %edx,%ecx
  800c54:	89 d3                	mov    %edx,%ebx
  800c56:	89 d7                	mov    %edx,%edi
  800c58:	89 d6                	mov    %edx,%esi
  800c5a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c6f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	89 cb                	mov    %ecx,%ebx
  800c79:	89 cf                	mov    %ecx,%edi
  800c7b:	89 ce                	mov    %ecx,%esi
  800c7d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 17                	jle    800c9a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 03                	push   $0x3
  800c89:	68 48 14 80 00       	push   $0x801448
  800c8e:	6a 23                	push   $0x23
  800c90:	68 65 14 80 00       	push   $0x801465
  800c95:	e8 a3 f5 ff ff       	call   80023d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cad:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb2:	89 d1                	mov    %edx,%ecx
  800cb4:	89 d3                	mov    %edx,%ebx
  800cb6:	89 d7                	mov    %edx,%edi
  800cb8:	89 d6                	mov    %edx,%esi
  800cba:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_yield>:

void
sys_yield(void)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800ccc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd1:	89 d1                	mov    %edx,%ecx
  800cd3:	89 d3                	mov    %edx,%ebx
  800cd5:	89 d7                	mov    %edx,%edi
  800cd7:	89 d6                	mov    %edx,%esi
  800cd9:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	be 00 00 00 00       	mov    $0x0,%esi
  800cee:	b8 04 00 00 00       	mov    $0x4,%eax
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfc:	89 f7                	mov    %esi,%edi
  800cfe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d00:	85 c0                	test   %eax,%eax
  800d02:	7e 17                	jle    800d1b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d04:	83 ec 0c             	sub    $0xc,%esp
  800d07:	50                   	push   %eax
  800d08:	6a 04                	push   $0x4
  800d0a:	68 48 14 80 00       	push   $0x801448
  800d0f:	6a 23                	push   $0x23
  800d11:	68 65 14 80 00       	push   $0x801465
  800d16:	e8 22 f5 ff ff       	call   80023d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	57                   	push   %edi
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2c:	b8 05 00 00 00       	mov    $0x5,%eax
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3d:	8b 75 18             	mov    0x18(%ebp),%esi
  800d40:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d42:	85 c0                	test   %eax,%eax
  800d44:	7e 17                	jle    800d5d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d46:	83 ec 0c             	sub    $0xc,%esp
  800d49:	50                   	push   %eax
  800d4a:	6a 05                	push   $0x5
  800d4c:	68 48 14 80 00       	push   $0x801448
  800d51:	6a 23                	push   $0x23
  800d53:	68 65 14 80 00       	push   $0x801465
  800d58:	e8 e0 f4 ff ff       	call   80023d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	57                   	push   %edi
  800d69:	56                   	push   %esi
  800d6a:	53                   	push   %ebx
  800d6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d73:	b8 06 00 00 00       	mov    $0x6,%eax
  800d78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7e:	89 df                	mov    %ebx,%edi
  800d80:	89 de                	mov    %ebx,%esi
  800d82:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d84:	85 c0                	test   %eax,%eax
  800d86:	7e 17                	jle    800d9f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d88:	83 ec 0c             	sub    $0xc,%esp
  800d8b:	50                   	push   %eax
  800d8c:	6a 06                	push   $0x6
  800d8e:	68 48 14 80 00       	push   $0x801448
  800d93:	6a 23                	push   $0x23
  800d95:	68 65 14 80 00       	push   $0x801465
  800d9a:	e8 9e f4 ff ff       	call   80023d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db5:	b8 08 00 00 00       	mov    $0x8,%eax
  800dba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc0:	89 df                	mov    %ebx,%edi
  800dc2:	89 de                	mov    %ebx,%esi
  800dc4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	7e 17                	jle    800de1 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	50                   	push   %eax
  800dce:	6a 08                	push   $0x8
  800dd0:	68 48 14 80 00       	push   $0x801448
  800dd5:	6a 23                	push   $0x23
  800dd7:	68 65 14 80 00       	push   $0x801465
  800ddc:	e8 5c f4 ff ff       	call   80023d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800de1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	57                   	push   %edi
  800ded:	56                   	push   %esi
  800dee:	53                   	push   %ebx
  800def:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df7:	b8 09 00 00 00       	mov    $0x9,%eax
  800dfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dff:	8b 55 08             	mov    0x8(%ebp),%edx
  800e02:	89 df                	mov    %ebx,%edi
  800e04:	89 de                	mov    %ebx,%esi
  800e06:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	7e 17                	jle    800e23 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0c:	83 ec 0c             	sub    $0xc,%esp
  800e0f:	50                   	push   %eax
  800e10:	6a 09                	push   $0x9
  800e12:	68 48 14 80 00       	push   $0x801448
  800e17:	6a 23                	push   $0x23
  800e19:	68 65 14 80 00       	push   $0x801465
  800e1e:	e8 1a f4 ff ff       	call   80023d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e26:	5b                   	pop    %ebx
  800e27:	5e                   	pop    %esi
  800e28:	5f                   	pop    %edi
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    

00800e2b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	57                   	push   %edi
  800e2f:	56                   	push   %esi
  800e30:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e31:	be 00 00 00 00       	mov    $0x0,%esi
  800e36:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e44:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e47:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e49:	5b                   	pop    %ebx
  800e4a:	5e                   	pop    %esi
  800e4b:	5f                   	pop    %edi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e57:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e5c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e61:	8b 55 08             	mov    0x8(%ebp),%edx
  800e64:	89 cb                	mov    %ecx,%ebx
  800e66:	89 cf                	mov    %ecx,%edi
  800e68:	89 ce                	mov    %ecx,%esi
  800e6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	7e 17                	jle    800e87 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e70:	83 ec 0c             	sub    $0xc,%esp
  800e73:	50                   	push   %eax
  800e74:	6a 0c                	push   $0xc
  800e76:	68 48 14 80 00       	push   $0x801448
  800e7b:	6a 23                	push   $0x23
  800e7d:	68 65 14 80 00       	push   $0x801465
  800e82:	e8 b6 f3 ff ff       	call   80023d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e8a:	5b                   	pop    %ebx
  800e8b:	5e                   	pop    %esi
  800e8c:	5f                   	pop    %edi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    
  800e8f:	90                   	nop

00800e90 <__udivdi3>:
  800e90:	55                   	push   %ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 1c             	sub    $0x1c,%esp
  800e97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800ea3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ea7:	85 f6                	test   %esi,%esi
  800ea9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ead:	89 ca                	mov    %ecx,%edx
  800eaf:	89 f8                	mov    %edi,%eax
  800eb1:	75 3d                	jne    800ef0 <__udivdi3+0x60>
  800eb3:	39 cf                	cmp    %ecx,%edi
  800eb5:	0f 87 c5 00 00 00    	ja     800f80 <__udivdi3+0xf0>
  800ebb:	85 ff                	test   %edi,%edi
  800ebd:	89 fd                	mov    %edi,%ebp
  800ebf:	75 0b                	jne    800ecc <__udivdi3+0x3c>
  800ec1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ec6:	31 d2                	xor    %edx,%edx
  800ec8:	f7 f7                	div    %edi
  800eca:	89 c5                	mov    %eax,%ebp
  800ecc:	89 c8                	mov    %ecx,%eax
  800ece:	31 d2                	xor    %edx,%edx
  800ed0:	f7 f5                	div    %ebp
  800ed2:	89 c1                	mov    %eax,%ecx
  800ed4:	89 d8                	mov    %ebx,%eax
  800ed6:	89 cf                	mov    %ecx,%edi
  800ed8:	f7 f5                	div    %ebp
  800eda:	89 c3                	mov    %eax,%ebx
  800edc:	89 d8                	mov    %ebx,%eax
  800ede:	89 fa                	mov    %edi,%edx
  800ee0:	83 c4 1c             	add    $0x1c,%esp
  800ee3:	5b                   	pop    %ebx
  800ee4:	5e                   	pop    %esi
  800ee5:	5f                   	pop    %edi
  800ee6:	5d                   	pop    %ebp
  800ee7:	c3                   	ret    
  800ee8:	90                   	nop
  800ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	39 ce                	cmp    %ecx,%esi
  800ef2:	77 74                	ja     800f68 <__udivdi3+0xd8>
  800ef4:	0f bd fe             	bsr    %esi,%edi
  800ef7:	83 f7 1f             	xor    $0x1f,%edi
  800efa:	0f 84 98 00 00 00    	je     800f98 <__udivdi3+0x108>
  800f00:	bb 20 00 00 00       	mov    $0x20,%ebx
  800f05:	89 f9                	mov    %edi,%ecx
  800f07:	89 c5                	mov    %eax,%ebp
  800f09:	29 fb                	sub    %edi,%ebx
  800f0b:	d3 e6                	shl    %cl,%esi
  800f0d:	89 d9                	mov    %ebx,%ecx
  800f0f:	d3 ed                	shr    %cl,%ebp
  800f11:	89 f9                	mov    %edi,%ecx
  800f13:	d3 e0                	shl    %cl,%eax
  800f15:	09 ee                	or     %ebp,%esi
  800f17:	89 d9                	mov    %ebx,%ecx
  800f19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f1d:	89 d5                	mov    %edx,%ebp
  800f1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f23:	d3 ed                	shr    %cl,%ebp
  800f25:	89 f9                	mov    %edi,%ecx
  800f27:	d3 e2                	shl    %cl,%edx
  800f29:	89 d9                	mov    %ebx,%ecx
  800f2b:	d3 e8                	shr    %cl,%eax
  800f2d:	09 c2                	or     %eax,%edx
  800f2f:	89 d0                	mov    %edx,%eax
  800f31:	89 ea                	mov    %ebp,%edx
  800f33:	f7 f6                	div    %esi
  800f35:	89 d5                	mov    %edx,%ebp
  800f37:	89 c3                	mov    %eax,%ebx
  800f39:	f7 64 24 0c          	mull   0xc(%esp)
  800f3d:	39 d5                	cmp    %edx,%ebp
  800f3f:	72 10                	jb     800f51 <__udivdi3+0xc1>
  800f41:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f45:	89 f9                	mov    %edi,%ecx
  800f47:	d3 e6                	shl    %cl,%esi
  800f49:	39 c6                	cmp    %eax,%esi
  800f4b:	73 07                	jae    800f54 <__udivdi3+0xc4>
  800f4d:	39 d5                	cmp    %edx,%ebp
  800f4f:	75 03                	jne    800f54 <__udivdi3+0xc4>
  800f51:	83 eb 01             	sub    $0x1,%ebx
  800f54:	31 ff                	xor    %edi,%edi
  800f56:	89 d8                	mov    %ebx,%eax
  800f58:	89 fa                	mov    %edi,%edx
  800f5a:	83 c4 1c             	add    $0x1c,%esp
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	5f                   	pop    %edi
  800f60:	5d                   	pop    %ebp
  800f61:	c3                   	ret    
  800f62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f68:	31 ff                	xor    %edi,%edi
  800f6a:	31 db                	xor    %ebx,%ebx
  800f6c:	89 d8                	mov    %ebx,%eax
  800f6e:	89 fa                	mov    %edi,%edx
  800f70:	83 c4 1c             	add    $0x1c,%esp
  800f73:	5b                   	pop    %ebx
  800f74:	5e                   	pop    %esi
  800f75:	5f                   	pop    %edi
  800f76:	5d                   	pop    %ebp
  800f77:	c3                   	ret    
  800f78:	90                   	nop
  800f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f80:	89 d8                	mov    %ebx,%eax
  800f82:	f7 f7                	div    %edi
  800f84:	31 ff                	xor    %edi,%edi
  800f86:	89 c3                	mov    %eax,%ebx
  800f88:	89 d8                	mov    %ebx,%eax
  800f8a:	89 fa                	mov    %edi,%edx
  800f8c:	83 c4 1c             	add    $0x1c,%esp
  800f8f:	5b                   	pop    %ebx
  800f90:	5e                   	pop    %esi
  800f91:	5f                   	pop    %edi
  800f92:	5d                   	pop    %ebp
  800f93:	c3                   	ret    
  800f94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f98:	39 ce                	cmp    %ecx,%esi
  800f9a:	72 0c                	jb     800fa8 <__udivdi3+0x118>
  800f9c:	31 db                	xor    %ebx,%ebx
  800f9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800fa2:	0f 87 34 ff ff ff    	ja     800edc <__udivdi3+0x4c>
  800fa8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800fad:	e9 2a ff ff ff       	jmp    800edc <__udivdi3+0x4c>
  800fb2:	66 90                	xchg   %ax,%ax
  800fb4:	66 90                	xchg   %ax,%ax
  800fb6:	66 90                	xchg   %ax,%ax
  800fb8:	66 90                	xchg   %ax,%ax
  800fba:	66 90                	xchg   %ax,%ax
  800fbc:	66 90                	xchg   %ax,%ax
  800fbe:	66 90                	xchg   %ax,%ax

00800fc0 <__umoddi3>:
  800fc0:	55                   	push   %ebp
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	53                   	push   %ebx
  800fc4:	83 ec 1c             	sub    $0x1c,%esp
  800fc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800fcb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800fcf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fd7:	85 d2                	test   %edx,%edx
  800fd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800fdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fe1:	89 f3                	mov    %esi,%ebx
  800fe3:	89 3c 24             	mov    %edi,(%esp)
  800fe6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fea:	75 1c                	jne    801008 <__umoddi3+0x48>
  800fec:	39 f7                	cmp    %esi,%edi
  800fee:	76 50                	jbe    801040 <__umoddi3+0x80>
  800ff0:	89 c8                	mov    %ecx,%eax
  800ff2:	89 f2                	mov    %esi,%edx
  800ff4:	f7 f7                	div    %edi
  800ff6:	89 d0                	mov    %edx,%eax
  800ff8:	31 d2                	xor    %edx,%edx
  800ffa:	83 c4 1c             	add    $0x1c,%esp
  800ffd:	5b                   	pop    %ebx
  800ffe:	5e                   	pop    %esi
  800fff:	5f                   	pop    %edi
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    
  801002:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801008:	39 f2                	cmp    %esi,%edx
  80100a:	89 d0                	mov    %edx,%eax
  80100c:	77 52                	ja     801060 <__umoddi3+0xa0>
  80100e:	0f bd ea             	bsr    %edx,%ebp
  801011:	83 f5 1f             	xor    $0x1f,%ebp
  801014:	75 5a                	jne    801070 <__umoddi3+0xb0>
  801016:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80101a:	0f 82 e0 00 00 00    	jb     801100 <__umoddi3+0x140>
  801020:	39 0c 24             	cmp    %ecx,(%esp)
  801023:	0f 86 d7 00 00 00    	jbe    801100 <__umoddi3+0x140>
  801029:	8b 44 24 08          	mov    0x8(%esp),%eax
  80102d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801031:	83 c4 1c             	add    $0x1c,%esp
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    
  801039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801040:	85 ff                	test   %edi,%edi
  801042:	89 fd                	mov    %edi,%ebp
  801044:	75 0b                	jne    801051 <__umoddi3+0x91>
  801046:	b8 01 00 00 00       	mov    $0x1,%eax
  80104b:	31 d2                	xor    %edx,%edx
  80104d:	f7 f7                	div    %edi
  80104f:	89 c5                	mov    %eax,%ebp
  801051:	89 f0                	mov    %esi,%eax
  801053:	31 d2                	xor    %edx,%edx
  801055:	f7 f5                	div    %ebp
  801057:	89 c8                	mov    %ecx,%eax
  801059:	f7 f5                	div    %ebp
  80105b:	89 d0                	mov    %edx,%eax
  80105d:	eb 99                	jmp    800ff8 <__umoddi3+0x38>
  80105f:	90                   	nop
  801060:	89 c8                	mov    %ecx,%eax
  801062:	89 f2                	mov    %esi,%edx
  801064:	83 c4 1c             	add    $0x1c,%esp
  801067:	5b                   	pop    %ebx
  801068:	5e                   	pop    %esi
  801069:	5f                   	pop    %edi
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    
  80106c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801070:	8b 34 24             	mov    (%esp),%esi
  801073:	bf 20 00 00 00       	mov    $0x20,%edi
  801078:	89 e9                	mov    %ebp,%ecx
  80107a:	29 ef                	sub    %ebp,%edi
  80107c:	d3 e0                	shl    %cl,%eax
  80107e:	89 f9                	mov    %edi,%ecx
  801080:	89 f2                	mov    %esi,%edx
  801082:	d3 ea                	shr    %cl,%edx
  801084:	89 e9                	mov    %ebp,%ecx
  801086:	09 c2                	or     %eax,%edx
  801088:	89 d8                	mov    %ebx,%eax
  80108a:	89 14 24             	mov    %edx,(%esp)
  80108d:	89 f2                	mov    %esi,%edx
  80108f:	d3 e2                	shl    %cl,%edx
  801091:	89 f9                	mov    %edi,%ecx
  801093:	89 54 24 04          	mov    %edx,0x4(%esp)
  801097:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80109b:	d3 e8                	shr    %cl,%eax
  80109d:	89 e9                	mov    %ebp,%ecx
  80109f:	89 c6                	mov    %eax,%esi
  8010a1:	d3 e3                	shl    %cl,%ebx
  8010a3:	89 f9                	mov    %edi,%ecx
  8010a5:	89 d0                	mov    %edx,%eax
  8010a7:	d3 e8                	shr    %cl,%eax
  8010a9:	89 e9                	mov    %ebp,%ecx
  8010ab:	09 d8                	or     %ebx,%eax
  8010ad:	89 d3                	mov    %edx,%ebx
  8010af:	89 f2                	mov    %esi,%edx
  8010b1:	f7 34 24             	divl   (%esp)
  8010b4:	89 d6                	mov    %edx,%esi
  8010b6:	d3 e3                	shl    %cl,%ebx
  8010b8:	f7 64 24 04          	mull   0x4(%esp)
  8010bc:	39 d6                	cmp    %edx,%esi
  8010be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010c2:	89 d1                	mov    %edx,%ecx
  8010c4:	89 c3                	mov    %eax,%ebx
  8010c6:	72 08                	jb     8010d0 <__umoddi3+0x110>
  8010c8:	75 11                	jne    8010db <__umoddi3+0x11b>
  8010ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8010ce:	73 0b                	jae    8010db <__umoddi3+0x11b>
  8010d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8010d4:	1b 14 24             	sbb    (%esp),%edx
  8010d7:	89 d1                	mov    %edx,%ecx
  8010d9:	89 c3                	mov    %eax,%ebx
  8010db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8010df:	29 da                	sub    %ebx,%edx
  8010e1:	19 ce                	sbb    %ecx,%esi
  8010e3:	89 f9                	mov    %edi,%ecx
  8010e5:	89 f0                	mov    %esi,%eax
  8010e7:	d3 e0                	shl    %cl,%eax
  8010e9:	89 e9                	mov    %ebp,%ecx
  8010eb:	d3 ea                	shr    %cl,%edx
  8010ed:	89 e9                	mov    %ebp,%ecx
  8010ef:	d3 ee                	shr    %cl,%esi
  8010f1:	09 d0                	or     %edx,%eax
  8010f3:	89 f2                	mov    %esi,%edx
  8010f5:	83 c4 1c             	add    $0x1c,%esp
  8010f8:	5b                   	pop    %ebx
  8010f9:	5e                   	pop    %esi
  8010fa:	5f                   	pop    %edi
  8010fb:	5d                   	pop    %ebp
  8010fc:	c3                   	ret    
  8010fd:	8d 76 00             	lea    0x0(%esi),%esi
  801100:	29 f9                	sub    %edi,%ecx
  801102:	19 d6                	sbb    %edx,%esi
  801104:	89 74 24 04          	mov    %esi,0x4(%esp)
  801108:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80110c:	e9 18 ff ff ff       	jmp    801029 <__umoddi3+0x69>
