
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 d0 11 00       	mov    $0x11d000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 d0 11 f0       	mov    $0xf011d000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 ae 22 f0 00 	cmpl   $0x0,0xf022ae80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 ae 22 f0    	mov    %esi,0xf022ae80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 45 52 00 00       	call   f01052a6 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 40 59 10 f0       	push   $0xf0105940
f010006d:	e8 0c 36 00 00       	call   f010367e <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 dc 35 00 00       	call   f0103658 <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 60 62 10 f0 	movl   $0xf0106260,(%esp)
f0100083:	e8 f6 35 00 00       	call   f010367e <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 c9 08 00 00       	call   f010095e <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a1:	b8 08 c0 26 f0       	mov    $0xf026c008,%eax
f01000a6:	2d 98 95 22 f0       	sub    $0xf0229598,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 98 95 22 f0       	push   $0xf0229598
f01000b3:	e8 cb 4b 00 00       	call   f0104c83 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 74 05 00 00       	call   f0100631 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 ac 59 10 f0       	push   $0xf01059ac
f01000ca:	e8 af 35 00 00       	call   f010367e <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 b3 11 00 00       	call   f0101287 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 1d 2e 00 00       	call   f0102ef6 <env_init>
	trap_init();
f01000d9:	e8 73 36 00 00       	call   f0103751 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 b9 4e 00 00       	call   f0104f9c <mp_init>
	lapic_init();
f01000e3:	e8 d9 51 00 00       	call   f01052c1 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 b8 34 00 00       	call   f01035a5 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 f3 11 f0 	movl   $0xf011f3c0,(%esp)
f01000f4:	e8 1b 54 00 00       	call   f0105514 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 ae 22 f0 07 	cmpl   $0x7,0xf022ae88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 64 59 10 f0       	push   $0xf0105964
f010010f:	6a 54                	push   $0x54
f0100111:	68 c7 59 10 f0       	push   $0xf01059c7
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 02 4f 10 f0       	mov    $0xf0104f02,%eax
f0100123:	2d 88 4e 10 f0       	sub    $0xf0104e88,%eax
f0100128:	50                   	push   %eax
f0100129:	68 88 4e 10 f0       	push   $0xf0104e88
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 98 4b 00 00       	call   f0104cd0 <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 b0 22 f0       	mov    $0xf022b020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 5f 51 00 00       	call   f01052a6 <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 b0 22 f0       	sub    $0xf022b020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 40 23 f0       	add    $0xf0234000,%eax
f010016b:	a3 84 ae 22 f0       	mov    %eax,0xf022ae84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 8e 52 00 00       	call   f010540f <lapic_startap>
f0100181:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED);
f0100184:	8b 43 04             	mov    0x4(%ebx),%eax
f0100187:	83 f8 01             	cmp    $0x1,%eax
f010018a:	75 f8                	jne    f0100184 <i386_init+0xea>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010018c:	83 c3 74             	add    $0x74,%ebx
f010018f:	6b 05 c4 b3 22 f0 74 	imul   $0x74,0xf022b3c4,%eax
f0100196:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_primes, ENV_TYPE_USER);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 00                	push   $0x0
f01001a4:	68 c8 0b 22 f0       	push   $0xf0220bc8
f01001a9:	e8 38 2f 00 00       	call   f01030e6 <env_create>
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01001ae:	e8 ea 3d 00 00       	call   f0103f9d <sched_yield>

f01001b3 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001b3:	55                   	push   %ebp
f01001b4:	89 e5                	mov    %esp,%ebp
f01001b6:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001b9:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001be:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c3:	77 12                	ja     f01001d7 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001c5:	50                   	push   %eax
f01001c6:	68 88 59 10 f0       	push   $0xf0105988
f01001cb:	6a 6b                	push   $0x6b
f01001cd:	68 c7 59 10 f0       	push   $0xf01059c7
f01001d2:	e8 69 fe ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01001d7:	05 00 00 00 10       	add    $0x10000000,%eax
f01001dc:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001df:	e8 c2 50 00 00       	call   f01052a6 <cpunum>
f01001e4:	83 ec 08             	sub    $0x8,%esp
f01001e7:	50                   	push   %eax
f01001e8:	68 d3 59 10 f0       	push   $0xf01059d3
f01001ed:	e8 8c 34 00 00       	call   f010367e <cprintf>

	lapic_init();
f01001f2:	e8 ca 50 00 00       	call   f01052c1 <lapic_init>
	env_init_percpu();
f01001f7:	e8 ca 2c 00 00       	call   f0102ec6 <env_init_percpu>
	trap_init_percpu();
f01001fc:	e8 91 34 00 00       	call   f0103692 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100201:	e8 a0 50 00 00       	call   f01052a6 <cpunum>
f0100206:	6b d0 74             	imul   $0x74,%eax,%edx
f0100209:	81 c2 20 b0 22 f0    	add    $0xf022b020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010020f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100214:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100218:	c7 04 24 c0 f3 11 f0 	movl   $0xf011f3c0,(%esp)
f010021f:	e8 f0 52 00 00       	call   f0105514 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
lock_kernel();
sched_yield();
f0100224:	e8 74 3d 00 00       	call   f0103f9d <sched_yield>

f0100229 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100229:	55                   	push   %ebp
f010022a:	89 e5                	mov    %esp,%ebp
f010022c:	53                   	push   %ebx
f010022d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100230:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100233:	ff 75 0c             	pushl  0xc(%ebp)
f0100236:	ff 75 08             	pushl  0x8(%ebp)
f0100239:	68 e9 59 10 f0       	push   $0xf01059e9
f010023e:	e8 3b 34 00 00       	call   f010367e <cprintf>
	vcprintf(fmt, ap);
f0100243:	83 c4 08             	add    $0x8,%esp
f0100246:	53                   	push   %ebx
f0100247:	ff 75 10             	pushl  0x10(%ebp)
f010024a:	e8 09 34 00 00       	call   f0103658 <vcprintf>
	cprintf("\n");
f010024f:	c7 04 24 60 62 10 f0 	movl   $0xf0106260,(%esp)
f0100256:	e8 23 34 00 00       	call   f010367e <cprintf>
	va_end(ap);
}
f010025b:	83 c4 10             	add    $0x10,%esp
f010025e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100261:	c9                   	leave  
f0100262:	c3                   	ret    

f0100263 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100263:	55                   	push   %ebp
f0100264:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100266:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010026b:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010026c:	a8 01                	test   $0x1,%al
f010026e:	74 0b                	je     f010027b <serial_proc_data+0x18>
f0100270:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100275:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100276:	0f b6 c0             	movzbl %al,%eax
f0100279:	eb 05                	jmp    f0100280 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010027b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100280:	5d                   	pop    %ebp
f0100281:	c3                   	ret    

f0100282 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100282:	55                   	push   %ebp
f0100283:	89 e5                	mov    %esp,%ebp
f0100285:	53                   	push   %ebx
f0100286:	83 ec 04             	sub    $0x4,%esp
f0100289:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010028b:	eb 2b                	jmp    f01002b8 <cons_intr+0x36>
		if (c == 0)
f010028d:	85 c0                	test   %eax,%eax
f010028f:	74 27                	je     f01002b8 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100291:	8b 0d 24 a2 22 f0    	mov    0xf022a224,%ecx
f0100297:	8d 51 01             	lea    0x1(%ecx),%edx
f010029a:	89 15 24 a2 22 f0    	mov    %edx,0xf022a224
f01002a0:	88 81 20 a0 22 f0    	mov    %al,-0xfdd5fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002a6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002ac:	75 0a                	jne    f01002b8 <cons_intr+0x36>
			cons.wpos = 0;
f01002ae:	c7 05 24 a2 22 f0 00 	movl   $0x0,0xf022a224
f01002b5:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002b8:	ff d3                	call   *%ebx
f01002ba:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002bd:	75 ce                	jne    f010028d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002bf:	83 c4 04             	add    $0x4,%esp
f01002c2:	5b                   	pop    %ebx
f01002c3:	5d                   	pop    %ebp
f01002c4:	c3                   	ret    

f01002c5 <kbd_proc_data>:
f01002c5:	ba 64 00 00 00       	mov    $0x64,%edx
f01002ca:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01002cb:	a8 01                	test   $0x1,%al
f01002cd:	0f 84 f0 00 00 00    	je     f01003c3 <kbd_proc_data+0xfe>
f01002d3:	ba 60 00 00 00       	mov    $0x60,%edx
f01002d8:	ec                   	in     (%dx),%al
f01002d9:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002db:	3c e0                	cmp    $0xe0,%al
f01002dd:	75 0d                	jne    f01002ec <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01002df:	83 0d 00 a0 22 f0 40 	orl    $0x40,0xf022a000
		return 0;
f01002e6:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002eb:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002ec:	55                   	push   %ebp
f01002ed:	89 e5                	mov    %esp,%ebp
f01002ef:	53                   	push   %ebx
f01002f0:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002f3:	84 c0                	test   %al,%al
f01002f5:	79 36                	jns    f010032d <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002f7:	8b 0d 00 a0 22 f0    	mov    0xf022a000,%ecx
f01002fd:	89 cb                	mov    %ecx,%ebx
f01002ff:	83 e3 40             	and    $0x40,%ebx
f0100302:	83 e0 7f             	and    $0x7f,%eax
f0100305:	85 db                	test   %ebx,%ebx
f0100307:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010030a:	0f b6 d2             	movzbl %dl,%edx
f010030d:	0f b6 82 60 5b 10 f0 	movzbl -0xfefa4a0(%edx),%eax
f0100314:	83 c8 40             	or     $0x40,%eax
f0100317:	0f b6 c0             	movzbl %al,%eax
f010031a:	f7 d0                	not    %eax
f010031c:	21 c8                	and    %ecx,%eax
f010031e:	a3 00 a0 22 f0       	mov    %eax,0xf022a000
		return 0;
f0100323:	b8 00 00 00 00       	mov    $0x0,%eax
f0100328:	e9 9e 00 00 00       	jmp    f01003cb <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f010032d:	8b 0d 00 a0 22 f0    	mov    0xf022a000,%ecx
f0100333:	f6 c1 40             	test   $0x40,%cl
f0100336:	74 0e                	je     f0100346 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100338:	83 c8 80             	or     $0xffffff80,%eax
f010033b:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010033d:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100340:	89 0d 00 a0 22 f0    	mov    %ecx,0xf022a000
	}

	shift |= shiftcode[data];
f0100346:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100349:	0f b6 82 60 5b 10 f0 	movzbl -0xfefa4a0(%edx),%eax
f0100350:	0b 05 00 a0 22 f0    	or     0xf022a000,%eax
f0100356:	0f b6 8a 60 5a 10 f0 	movzbl -0xfefa5a0(%edx),%ecx
f010035d:	31 c8                	xor    %ecx,%eax
f010035f:	a3 00 a0 22 f0       	mov    %eax,0xf022a000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100364:	89 c1                	mov    %eax,%ecx
f0100366:	83 e1 03             	and    $0x3,%ecx
f0100369:	8b 0c 8d 40 5a 10 f0 	mov    -0xfefa5c0(,%ecx,4),%ecx
f0100370:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100374:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100377:	a8 08                	test   $0x8,%al
f0100379:	74 1b                	je     f0100396 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f010037b:	89 da                	mov    %ebx,%edx
f010037d:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100380:	83 f9 19             	cmp    $0x19,%ecx
f0100383:	77 05                	ja     f010038a <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100385:	83 eb 20             	sub    $0x20,%ebx
f0100388:	eb 0c                	jmp    f0100396 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f010038a:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010038d:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100390:	83 fa 19             	cmp    $0x19,%edx
f0100393:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100396:	f7 d0                	not    %eax
f0100398:	a8 06                	test   $0x6,%al
f010039a:	75 2d                	jne    f01003c9 <kbd_proc_data+0x104>
f010039c:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003a2:	75 25                	jne    f01003c9 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01003a4:	83 ec 0c             	sub    $0xc,%esp
f01003a7:	68 03 5a 10 f0       	push   $0xf0105a03
f01003ac:	e8 cd 32 00 00       	call   f010367e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b1:	ba 92 00 00 00       	mov    $0x92,%edx
f01003b6:	b8 03 00 00 00       	mov    $0x3,%eax
f01003bb:	ee                   	out    %al,(%dx)
f01003bc:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003bf:	89 d8                	mov    %ebx,%eax
f01003c1:	eb 08                	jmp    f01003cb <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01003c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003c8:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003c9:	89 d8                	mov    %ebx,%eax
}
f01003cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003ce:	c9                   	leave  
f01003cf:	c3                   	ret    

f01003d0 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003d0:	55                   	push   %ebp
f01003d1:	89 e5                	mov    %esp,%ebp
f01003d3:	57                   	push   %edi
f01003d4:	56                   	push   %esi
f01003d5:	53                   	push   %ebx
f01003d6:	83 ec 1c             	sub    $0x1c,%esp
f01003d9:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003db:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003e0:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003e5:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003ea:	eb 09                	jmp    f01003f5 <cons_putc+0x25>
f01003ec:	89 ca                	mov    %ecx,%edx
f01003ee:	ec                   	in     (%dx),%al
f01003ef:	ec                   	in     (%dx),%al
f01003f0:	ec                   	in     (%dx),%al
f01003f1:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003f2:	83 c3 01             	add    $0x1,%ebx
f01003f5:	89 f2                	mov    %esi,%edx
f01003f7:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003f8:	a8 20                	test   $0x20,%al
f01003fa:	75 08                	jne    f0100404 <cons_putc+0x34>
f01003fc:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100402:	7e e8                	jle    f01003ec <cons_putc+0x1c>
f0100404:	89 f8                	mov    %edi,%eax
f0100406:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100409:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010040e:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010040f:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100414:	be 79 03 00 00       	mov    $0x379,%esi
f0100419:	b9 84 00 00 00       	mov    $0x84,%ecx
f010041e:	eb 09                	jmp    f0100429 <cons_putc+0x59>
f0100420:	89 ca                	mov    %ecx,%edx
f0100422:	ec                   	in     (%dx),%al
f0100423:	ec                   	in     (%dx),%al
f0100424:	ec                   	in     (%dx),%al
f0100425:	ec                   	in     (%dx),%al
f0100426:	83 c3 01             	add    $0x1,%ebx
f0100429:	89 f2                	mov    %esi,%edx
f010042b:	ec                   	in     (%dx),%al
f010042c:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100432:	7f 04                	jg     f0100438 <cons_putc+0x68>
f0100434:	84 c0                	test   %al,%al
f0100436:	79 e8                	jns    f0100420 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100438:	ba 78 03 00 00       	mov    $0x378,%edx
f010043d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100441:	ee                   	out    %al,(%dx)
f0100442:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100447:	b8 0d 00 00 00       	mov    $0xd,%eax
f010044c:	ee                   	out    %al,(%dx)
f010044d:	b8 08 00 00 00       	mov    $0x8,%eax
f0100452:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100453:	89 fa                	mov    %edi,%edx
f0100455:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010045b:	89 f8                	mov    %edi,%eax
f010045d:	80 cc 07             	or     $0x7,%ah
f0100460:	85 d2                	test   %edx,%edx
f0100462:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100465:	89 f8                	mov    %edi,%eax
f0100467:	0f b6 c0             	movzbl %al,%eax
f010046a:	83 f8 09             	cmp    $0x9,%eax
f010046d:	74 74                	je     f01004e3 <cons_putc+0x113>
f010046f:	83 f8 09             	cmp    $0x9,%eax
f0100472:	7f 0a                	jg     f010047e <cons_putc+0xae>
f0100474:	83 f8 08             	cmp    $0x8,%eax
f0100477:	74 14                	je     f010048d <cons_putc+0xbd>
f0100479:	e9 99 00 00 00       	jmp    f0100517 <cons_putc+0x147>
f010047e:	83 f8 0a             	cmp    $0xa,%eax
f0100481:	74 3a                	je     f01004bd <cons_putc+0xed>
f0100483:	83 f8 0d             	cmp    $0xd,%eax
f0100486:	74 3d                	je     f01004c5 <cons_putc+0xf5>
f0100488:	e9 8a 00 00 00       	jmp    f0100517 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f010048d:	0f b7 05 28 a2 22 f0 	movzwl 0xf022a228,%eax
f0100494:	66 85 c0             	test   %ax,%ax
f0100497:	0f 84 e6 00 00 00    	je     f0100583 <cons_putc+0x1b3>
			crt_pos--;
f010049d:	83 e8 01             	sub    $0x1,%eax
f01004a0:	66 a3 28 a2 22 f0    	mov    %ax,0xf022a228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a6:	0f b7 c0             	movzwl %ax,%eax
f01004a9:	66 81 e7 00 ff       	and    $0xff00,%di
f01004ae:	83 cf 20             	or     $0x20,%edi
f01004b1:	8b 15 2c a2 22 f0    	mov    0xf022a22c,%edx
f01004b7:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004bb:	eb 78                	jmp    f0100535 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004bd:	66 83 05 28 a2 22 f0 	addw   $0x50,0xf022a228
f01004c4:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004c5:	0f b7 05 28 a2 22 f0 	movzwl 0xf022a228,%eax
f01004cc:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004d2:	c1 e8 16             	shr    $0x16,%eax
f01004d5:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004d8:	c1 e0 04             	shl    $0x4,%eax
f01004db:	66 a3 28 a2 22 f0    	mov    %ax,0xf022a228
f01004e1:	eb 52                	jmp    f0100535 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004e3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e8:	e8 e3 fe ff ff       	call   f01003d0 <cons_putc>
		cons_putc(' ');
f01004ed:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f2:	e8 d9 fe ff ff       	call   f01003d0 <cons_putc>
		cons_putc(' ');
f01004f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01004fc:	e8 cf fe ff ff       	call   f01003d0 <cons_putc>
		cons_putc(' ');
f0100501:	b8 20 00 00 00       	mov    $0x20,%eax
f0100506:	e8 c5 fe ff ff       	call   f01003d0 <cons_putc>
		cons_putc(' ');
f010050b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100510:	e8 bb fe ff ff       	call   f01003d0 <cons_putc>
f0100515:	eb 1e                	jmp    f0100535 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100517:	0f b7 05 28 a2 22 f0 	movzwl 0xf022a228,%eax
f010051e:	8d 50 01             	lea    0x1(%eax),%edx
f0100521:	66 89 15 28 a2 22 f0 	mov    %dx,0xf022a228
f0100528:	0f b7 c0             	movzwl %ax,%eax
f010052b:	8b 15 2c a2 22 f0    	mov    0xf022a22c,%edx
f0100531:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100535:	66 81 3d 28 a2 22 f0 	cmpw   $0x7cf,0xf022a228
f010053c:	cf 07 
f010053e:	76 43                	jbe    f0100583 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t)); // You can write more than one line once the max is reached. Brings the cursor to init position.
f0100540:	a1 2c a2 22 f0       	mov    0xf022a22c,%eax
f0100545:	83 ec 04             	sub    $0x4,%esp
f0100548:	68 00 0f 00 00       	push   $0xf00
f010054d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100553:	52                   	push   %edx
f0100554:	50                   	push   %eax
f0100555:	e8 76 47 00 00       	call   f0104cd0 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010055a:	8b 15 2c a2 22 f0    	mov    0xf022a22c,%edx
f0100560:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100566:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010056c:	83 c4 10             	add    $0x10,%esp
f010056f:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100574:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t)); // You can write more than one line once the max is reached. Brings the cursor to init position.
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100577:	39 d0                	cmp    %edx,%eax
f0100579:	75 f4                	jne    f010056f <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010057b:	66 83 2d 28 a2 22 f0 	subw   $0x50,0xf022a228
f0100582:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100583:	8b 0d 30 a2 22 f0    	mov    0xf022a230,%ecx
f0100589:	b8 0e 00 00 00       	mov    $0xe,%eax
f010058e:	89 ca                	mov    %ecx,%edx
f0100590:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100591:	0f b7 1d 28 a2 22 f0 	movzwl 0xf022a228,%ebx
f0100598:	8d 71 01             	lea    0x1(%ecx),%esi
f010059b:	89 d8                	mov    %ebx,%eax
f010059d:	66 c1 e8 08          	shr    $0x8,%ax
f01005a1:	89 f2                	mov    %esi,%edx
f01005a3:	ee                   	out    %al,(%dx)
f01005a4:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005a9:	89 ca                	mov    %ecx,%edx
f01005ab:	ee                   	out    %al,(%dx)
f01005ac:	89 d8                	mov    %ebx,%eax
f01005ae:	89 f2                	mov    %esi,%edx
f01005b0:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005b4:	5b                   	pop    %ebx
f01005b5:	5e                   	pop    %esi
f01005b6:	5f                   	pop    %edi
f01005b7:	5d                   	pop    %ebp
f01005b8:	c3                   	ret    

f01005b9 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005b9:	80 3d 34 a2 22 f0 00 	cmpb   $0x0,0xf022a234
f01005c0:	74 11                	je     f01005d3 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005c2:	55                   	push   %ebp
f01005c3:	89 e5                	mov    %esp,%ebp
f01005c5:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005c8:	b8 63 02 10 f0       	mov    $0xf0100263,%eax
f01005cd:	e8 b0 fc ff ff       	call   f0100282 <cons_intr>
}
f01005d2:	c9                   	leave  
f01005d3:	f3 c3                	repz ret 

f01005d5 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005d5:	55                   	push   %ebp
f01005d6:	89 e5                	mov    %esp,%ebp
f01005d8:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005db:	b8 c5 02 10 f0       	mov    $0xf01002c5,%eax
f01005e0:	e8 9d fc ff ff       	call   f0100282 <cons_intr>
}
f01005e5:	c9                   	leave  
f01005e6:	c3                   	ret    

f01005e7 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005e7:	55                   	push   %ebp
f01005e8:	89 e5                	mov    %esp,%ebp
f01005ea:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005ed:	e8 c7 ff ff ff       	call   f01005b9 <serial_intr>
	kbd_intr();
f01005f2:	e8 de ff ff ff       	call   f01005d5 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01005f7:	a1 20 a2 22 f0       	mov    0xf022a220,%eax
f01005fc:	3b 05 24 a2 22 f0    	cmp    0xf022a224,%eax
f0100602:	74 26                	je     f010062a <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100604:	8d 50 01             	lea    0x1(%eax),%edx
f0100607:	89 15 20 a2 22 f0    	mov    %edx,0xf022a220
f010060d:	0f b6 88 20 a0 22 f0 	movzbl -0xfdd5fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100614:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100616:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010061c:	75 11                	jne    f010062f <cons_getc+0x48>
			cons.rpos = 0;
f010061e:	c7 05 20 a2 22 f0 00 	movl   $0x0,0xf022a220
f0100625:	00 00 00 
f0100628:	eb 05                	jmp    f010062f <cons_getc+0x48>
		return c;
	}
	return 0;
f010062a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010062f:	c9                   	leave  
f0100630:	c3                   	ret    

f0100631 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100631:	55                   	push   %ebp
f0100632:	89 e5                	mov    %esp,%ebp
f0100634:	57                   	push   %edi
f0100635:	56                   	push   %esi
f0100636:	53                   	push   %ebx
f0100637:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010063a:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100641:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100648:	5a a5 
	if (*cp != 0xA55A) {
f010064a:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100651:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100655:	74 11                	je     f0100668 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100657:	c7 05 30 a2 22 f0 b4 	movl   $0x3b4,0xf022a230
f010065e:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100661:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100666:	eb 16                	jmp    f010067e <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100668:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010066f:	c7 05 30 a2 22 f0 d4 	movl   $0x3d4,0xf022a230
f0100676:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100679:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010067e:	8b 3d 30 a2 22 f0    	mov    0xf022a230,%edi
f0100684:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100689:	89 fa                	mov    %edi,%edx
f010068b:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010068c:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010068f:	89 da                	mov    %ebx,%edx
f0100691:	ec                   	in     (%dx),%al
f0100692:	0f b6 c8             	movzbl %al,%ecx
f0100695:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100698:	b8 0f 00 00 00       	mov    $0xf,%eax
f010069d:	89 fa                	mov    %edi,%edx
f010069f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a0:	89 da                	mov    %ebx,%edx
f01006a2:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006a3:	89 35 2c a2 22 f0    	mov    %esi,0xf022a22c
	crt_pos = pos;
f01006a9:	0f b6 c0             	movzbl %al,%eax
f01006ac:	09 c8                	or     %ecx,%eax
f01006ae:	66 a3 28 a2 22 f0    	mov    %ax,0xf022a228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006b4:	e8 1c ff ff ff       	call   f01005d5 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01006b9:	83 ec 0c             	sub    $0xc,%esp
f01006bc:	0f b7 05 a8 f3 11 f0 	movzwl 0xf011f3a8,%eax
f01006c3:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006c8:	50                   	push   %eax
f01006c9:	e8 5f 2e 00 00       	call   f010352d <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ce:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006d3:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d8:	89 f2                	mov    %esi,%edx
f01006da:	ee                   	out    %al,(%dx)
f01006db:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006e0:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006e5:	ee                   	out    %al,(%dx)
f01006e6:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006eb:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006f0:	89 da                	mov    %ebx,%edx
f01006f2:	ee                   	out    %al,(%dx)
f01006f3:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01006f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01006fd:	ee                   	out    %al,(%dx)
f01006fe:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100703:	b8 03 00 00 00       	mov    $0x3,%eax
f0100708:	ee                   	out    %al,(%dx)
f0100709:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010070e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100713:	ee                   	out    %al,(%dx)
f0100714:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100719:	b8 01 00 00 00       	mov    $0x1,%eax
f010071e:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010071f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100724:	ec                   	in     (%dx),%al
f0100725:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100727:	83 c4 10             	add    $0x10,%esp
f010072a:	3c ff                	cmp    $0xff,%al
f010072c:	0f 95 05 34 a2 22 f0 	setne  0xf022a234
f0100733:	89 f2                	mov    %esi,%edx
f0100735:	ec                   	in     (%dx),%al
f0100736:	89 da                	mov    %ebx,%edx
f0100738:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100739:	80 f9 ff             	cmp    $0xff,%cl
f010073c:	75 10                	jne    f010074e <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
f010073e:	83 ec 0c             	sub    $0xc,%esp
f0100741:	68 0f 5a 10 f0       	push   $0xf0105a0f
f0100746:	e8 33 2f 00 00       	call   f010367e <cprintf>
f010074b:	83 c4 10             	add    $0x10,%esp
}
f010074e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100751:	5b                   	pop    %ebx
f0100752:	5e                   	pop    %esi
f0100753:	5f                   	pop    %edi
f0100754:	5d                   	pop    %ebp
f0100755:	c3                   	ret    

f0100756 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100756:	55                   	push   %ebp
f0100757:	89 e5                	mov    %esp,%ebp
f0100759:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010075c:	8b 45 08             	mov    0x8(%ebp),%eax
f010075f:	e8 6c fc ff ff       	call   f01003d0 <cons_putc>
}
f0100764:	c9                   	leave  
f0100765:	c3                   	ret    

f0100766 <getchar>:

int
getchar(void)
{
f0100766:	55                   	push   %ebp
f0100767:	89 e5                	mov    %esp,%ebp
f0100769:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010076c:	e8 76 fe ff ff       	call   f01005e7 <cons_getc>
f0100771:	85 c0                	test   %eax,%eax
f0100773:	74 f7                	je     f010076c <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100775:	c9                   	leave  
f0100776:	c3                   	ret    

f0100777 <iscons>:

int
iscons(int fdnum)
{
f0100777:	55                   	push   %ebp
f0100778:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010077a:	b8 01 00 00 00       	mov    $0x1,%eax
f010077f:	5d                   	pop    %ebp
f0100780:	c3                   	ret    

f0100781 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100781:	55                   	push   %ebp
f0100782:	89 e5                	mov    %esp,%ebp
f0100784:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100787:	68 60 5c 10 f0       	push   $0xf0105c60
f010078c:	68 7e 5c 10 f0       	push   $0xf0105c7e
f0100791:	68 83 5c 10 f0       	push   $0xf0105c83
f0100796:	e8 e3 2e 00 00       	call   f010367e <cprintf>
f010079b:	83 c4 0c             	add    $0xc,%esp
f010079e:	68 50 5d 10 f0       	push   $0xf0105d50
f01007a3:	68 8c 5c 10 f0       	push   $0xf0105c8c
f01007a8:	68 83 5c 10 f0       	push   $0xf0105c83
f01007ad:	e8 cc 2e 00 00       	call   f010367e <cprintf>
f01007b2:	83 c4 0c             	add    $0xc,%esp
f01007b5:	68 95 5c 10 f0       	push   $0xf0105c95
f01007ba:	68 b1 5c 10 f0       	push   $0xf0105cb1
f01007bf:	68 83 5c 10 f0       	push   $0xf0105c83
f01007c4:	e8 b5 2e 00 00       	call   f010367e <cprintf>
	return 0;
}
f01007c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ce:	c9                   	leave  
f01007cf:	c3                   	ret    

f01007d0 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007d0:	55                   	push   %ebp
f01007d1:	89 e5                	mov    %esp,%ebp
f01007d3:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007d6:	68 bb 5c 10 f0       	push   $0xf0105cbb
f01007db:	e8 9e 2e 00 00       	call   f010367e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007e0:	83 c4 08             	add    $0x8,%esp
f01007e3:	68 0c 00 10 00       	push   $0x10000c
f01007e8:	68 78 5d 10 f0       	push   $0xf0105d78
f01007ed:	e8 8c 2e 00 00       	call   f010367e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007f2:	83 c4 0c             	add    $0xc,%esp
f01007f5:	68 0c 00 10 00       	push   $0x10000c
f01007fa:	68 0c 00 10 f0       	push   $0xf010000c
f01007ff:	68 a0 5d 10 f0       	push   $0xf0105da0
f0100804:	e8 75 2e 00 00       	call   f010367e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100809:	83 c4 0c             	add    $0xc,%esp
f010080c:	68 21 59 10 00       	push   $0x105921
f0100811:	68 21 59 10 f0       	push   $0xf0105921
f0100816:	68 c4 5d 10 f0       	push   $0xf0105dc4
f010081b:	e8 5e 2e 00 00       	call   f010367e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100820:	83 c4 0c             	add    $0xc,%esp
f0100823:	68 98 95 22 00       	push   $0x229598
f0100828:	68 98 95 22 f0       	push   $0xf0229598
f010082d:	68 e8 5d 10 f0       	push   $0xf0105de8
f0100832:	e8 47 2e 00 00       	call   f010367e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100837:	83 c4 0c             	add    $0xc,%esp
f010083a:	68 08 c0 26 00       	push   $0x26c008
f010083f:	68 08 c0 26 f0       	push   $0xf026c008
f0100844:	68 0c 5e 10 f0       	push   $0xf0105e0c
f0100849:	e8 30 2e 00 00       	call   f010367e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010084e:	b8 07 c4 26 f0       	mov    $0xf026c407,%eax
f0100853:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100858:	83 c4 08             	add    $0x8,%esp
f010085b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100860:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100866:	85 c0                	test   %eax,%eax
f0100868:	0f 48 c2             	cmovs  %edx,%eax
f010086b:	c1 f8 0a             	sar    $0xa,%eax
f010086e:	50                   	push   %eax
f010086f:	68 30 5e 10 f0       	push   $0xf0105e30
f0100874:	e8 05 2e 00 00       	call   f010367e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100879:	b8 00 00 00 00       	mov    $0x0,%eax
f010087e:	c9                   	leave  
f010087f:	c3                   	ret    

f0100880 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100880:	55                   	push   %ebp
f0100881:	89 e5                	mov    %esp,%ebp
f0100883:	57                   	push   %edi
f0100884:	56                   	push   %esi
f0100885:	53                   	push   %ebx
f0100886:	83 ec 38             	sub    $0x38,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100889:	89 eb                	mov    %ebp,%ebx
	
 uint32_t* ebp;
struct Eipdebuginfo info;
ebp = (uint32_t*) read_ebp();
cprintf("Stack backtrace:\n");
f010088b:	68 d4 5c 10 f0       	push   $0xf0105cd4
f0100890:	e8 e9 2d 00 00       	call   f010367e <cprintf>
while (ebp){
f0100895:	83 c4 10             	add    $0x10,%esp
cprintf("%08x ",*(ebp+2)); 
cprintf("%08x ",*(ebp+3)) ;
cprintf("%08x ",*(ebp+4)) ;
cprintf("%08x ",*(ebp+5)) ;
cprintf("%08x\n",*(ebp+6)) ;
debuginfo_eip(eip, &info);
f0100898:	8d 7d d0             	lea    -0x30(%ebp),%edi
	
 uint32_t* ebp;
struct Eipdebuginfo info;
ebp = (uint32_t*) read_ebp();
cprintf("Stack backtrace:\n");
while (ebp){
f010089b:	e9 a9 00 00 00       	jmp    f0100949 <mon_backtrace+0xc9>
uint32_t offset_eip =0;
uint32_t eip = *(ebp+1);
f01008a0:	8b 73 04             	mov    0x4(%ebx),%esi

cprintf ("ebp %08x ",ebp);
f01008a3:	83 ec 08             	sub    $0x8,%esp
f01008a6:	53                   	push   %ebx
f01008a7:	68 e6 5c 10 f0       	push   $0xf0105ce6
f01008ac:	e8 cd 2d 00 00       	call   f010367e <cprintf>
cprintf ("eip %08x ",*(ebp+1));
f01008b1:	83 c4 08             	add    $0x8,%esp
f01008b4:	ff 73 04             	pushl  0x4(%ebx)
f01008b7:	68 f0 5c 10 f0       	push   $0xf0105cf0
f01008bc:	e8 bd 2d 00 00       	call   f010367e <cprintf>
cprintf("args:");
f01008c1:	c7 04 24 fa 5c 10 f0 	movl   $0xf0105cfa,(%esp)
f01008c8:	e8 b1 2d 00 00       	call   f010367e <cprintf>
cprintf("%08x ",*(ebp+2)); 
f01008cd:	83 c4 08             	add    $0x8,%esp
f01008d0:	ff 73 08             	pushl  0x8(%ebx)
f01008d3:	68 ea 5c 10 f0       	push   $0xf0105cea
f01008d8:	e8 a1 2d 00 00       	call   f010367e <cprintf>
cprintf("%08x ",*(ebp+3)) ;
f01008dd:	83 c4 08             	add    $0x8,%esp
f01008e0:	ff 73 0c             	pushl  0xc(%ebx)
f01008e3:	68 ea 5c 10 f0       	push   $0xf0105cea
f01008e8:	e8 91 2d 00 00       	call   f010367e <cprintf>
cprintf("%08x ",*(ebp+4)) ;
f01008ed:	83 c4 08             	add    $0x8,%esp
f01008f0:	ff 73 10             	pushl  0x10(%ebx)
f01008f3:	68 ea 5c 10 f0       	push   $0xf0105cea
f01008f8:	e8 81 2d 00 00       	call   f010367e <cprintf>
cprintf("%08x ",*(ebp+5)) ;
f01008fd:	83 c4 08             	add    $0x8,%esp
f0100900:	ff 73 14             	pushl  0x14(%ebx)
f0100903:	68 ea 5c 10 f0       	push   $0xf0105cea
f0100908:	e8 71 2d 00 00       	call   f010367e <cprintf>
cprintf("%08x\n",*(ebp+6)) ;
f010090d:	83 c4 08             	add    $0x8,%esp
f0100910:	ff 73 18             	pushl  0x18(%ebx)
f0100913:	68 39 76 10 f0       	push   $0xf0107639
f0100918:	e8 61 2d 00 00       	call   f010367e <cprintf>
debuginfo_eip(eip, &info);
f010091d:	83 c4 08             	add    $0x8,%esp
f0100920:	57                   	push   %edi
f0100921:	56                   	push   %esi
f0100922:	e8 b6 38 00 00       	call   f01041dd <debuginfo_eip>
offset_eip = eip-info.eip_fn_addr;
cprintf("\t %s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,offset_eip);
f0100927:	83 c4 08             	add    $0x8,%esp
f010092a:	2b 75 e0             	sub    -0x20(%ebp),%esi
f010092d:	56                   	push   %esi
f010092e:	ff 75 d8             	pushl  -0x28(%ebp)
f0100931:	ff 75 dc             	pushl  -0x24(%ebp)
f0100934:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100937:	ff 75 d0             	pushl  -0x30(%ebp)
f010093a:	68 00 5d 10 f0       	push   $0xf0105d00
f010093f:	e8 3a 2d 00 00       	call   f010367e <cprintf>

//cprintf(" *ebp is %08x\n",*ebp);
 ebp = (uint32_t*) *ebp;
f0100944:	8b 1b                	mov    (%ebx),%ebx
f0100946:	83 c4 20             	add    $0x20,%esp
	
 uint32_t* ebp;
struct Eipdebuginfo info;
ebp = (uint32_t*) read_ebp();
cprintf("Stack backtrace:\n");
while (ebp){
f0100949:	85 db                	test   %ebx,%ebx
f010094b:	0f 85 4f ff ff ff    	jne    f01008a0 <mon_backtrace+0x20>
 ebp = (uint32_t*) *ebp;
}


	return 0;
}
f0100951:	b8 00 00 00 00       	mov    $0x0,%eax
f0100956:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100959:	5b                   	pop    %ebx
f010095a:	5e                   	pop    %esi
f010095b:	5f                   	pop    %edi
f010095c:	5d                   	pop    %ebp
f010095d:	c3                   	ret    

f010095e <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010095e:	55                   	push   %ebp
f010095f:	89 e5                	mov    %esp,%ebp
f0100961:	57                   	push   %edi
f0100962:	56                   	push   %esi
f0100963:	53                   	push   %ebx
f0100964:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100967:	68 5c 5e 10 f0       	push   $0xf0105e5c
f010096c:	e8 0d 2d 00 00       	call   f010367e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100971:	c7 04 24 80 5e 10 f0 	movl   $0xf0105e80,(%esp)
f0100978:	e8 01 2d 00 00       	call   f010367e <cprintf>

	if (tf != NULL)
f010097d:	83 c4 10             	add    $0x10,%esp
f0100980:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100984:	74 0e                	je     f0100994 <monitor+0x36>
		print_trapframe(tf);
f0100986:	83 ec 0c             	sub    $0xc,%esp
f0100989:	ff 75 08             	pushl  0x8(%ebp)
f010098c:	e8 0b 31 00 00       	call   f0103a9c <print_trapframe>
f0100991:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100994:	83 ec 0c             	sub    $0xc,%esp
f0100997:	68 12 5d 10 f0       	push   $0xf0105d12
f010099c:	e8 8b 40 00 00       	call   f0104a2c <readline>
f01009a1:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009a3:	83 c4 10             	add    $0x10,%esp
f01009a6:	85 c0                	test   %eax,%eax
f01009a8:	74 ea                	je     f0100994 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01009aa:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01009b1:	be 00 00 00 00       	mov    $0x0,%esi
f01009b6:	eb 0a                	jmp    f01009c2 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01009b8:	c6 03 00             	movb   $0x0,(%ebx)
f01009bb:	89 f7                	mov    %esi,%edi
f01009bd:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01009c0:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01009c2:	0f b6 03             	movzbl (%ebx),%eax
f01009c5:	84 c0                	test   %al,%al
f01009c7:	74 63                	je     f0100a2c <monitor+0xce>
f01009c9:	83 ec 08             	sub    $0x8,%esp
f01009cc:	0f be c0             	movsbl %al,%eax
f01009cf:	50                   	push   %eax
f01009d0:	68 16 5d 10 f0       	push   $0xf0105d16
f01009d5:	e8 6c 42 00 00       	call   f0104c46 <strchr>
f01009da:	83 c4 10             	add    $0x10,%esp
f01009dd:	85 c0                	test   %eax,%eax
f01009df:	75 d7                	jne    f01009b8 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01009e1:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009e4:	74 46                	je     f0100a2c <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009e6:	83 fe 0f             	cmp    $0xf,%esi
f01009e9:	75 14                	jne    f01009ff <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009eb:	83 ec 08             	sub    $0x8,%esp
f01009ee:	6a 10                	push   $0x10
f01009f0:	68 1b 5d 10 f0       	push   $0xf0105d1b
f01009f5:	e8 84 2c 00 00       	call   f010367e <cprintf>
f01009fa:	83 c4 10             	add    $0x10,%esp
f01009fd:	eb 95                	jmp    f0100994 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01009ff:	8d 7e 01             	lea    0x1(%esi),%edi
f0100a02:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100a06:	eb 03                	jmp    f0100a0b <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100a08:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a0b:	0f b6 03             	movzbl (%ebx),%eax
f0100a0e:	84 c0                	test   %al,%al
f0100a10:	74 ae                	je     f01009c0 <monitor+0x62>
f0100a12:	83 ec 08             	sub    $0x8,%esp
f0100a15:	0f be c0             	movsbl %al,%eax
f0100a18:	50                   	push   %eax
f0100a19:	68 16 5d 10 f0       	push   $0xf0105d16
f0100a1e:	e8 23 42 00 00       	call   f0104c46 <strchr>
f0100a23:	83 c4 10             	add    $0x10,%esp
f0100a26:	85 c0                	test   %eax,%eax
f0100a28:	74 de                	je     f0100a08 <monitor+0xaa>
f0100a2a:	eb 94                	jmp    f01009c0 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100a2c:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a33:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a34:	85 f6                	test   %esi,%esi
f0100a36:	0f 84 58 ff ff ff    	je     f0100994 <monitor+0x36>
f0100a3c:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a41:	83 ec 08             	sub    $0x8,%esp
f0100a44:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a47:	ff 34 85 c0 5e 10 f0 	pushl  -0xfefa140(,%eax,4)
f0100a4e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a51:	e8 92 41 00 00       	call   f0104be8 <strcmp>
f0100a56:	83 c4 10             	add    $0x10,%esp
f0100a59:	85 c0                	test   %eax,%eax
f0100a5b:	75 21                	jne    f0100a7e <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100a5d:	83 ec 04             	sub    $0x4,%esp
f0100a60:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a63:	ff 75 08             	pushl  0x8(%ebp)
f0100a66:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a69:	52                   	push   %edx
f0100a6a:	56                   	push   %esi
f0100a6b:	ff 14 85 c8 5e 10 f0 	call   *-0xfefa138(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a72:	83 c4 10             	add    $0x10,%esp
f0100a75:	85 c0                	test   %eax,%eax
f0100a77:	78 25                	js     f0100a9e <monitor+0x140>
f0100a79:	e9 16 ff ff ff       	jmp    f0100994 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a7e:	83 c3 01             	add    $0x1,%ebx
f0100a81:	83 fb 03             	cmp    $0x3,%ebx
f0100a84:	75 bb                	jne    f0100a41 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a86:	83 ec 08             	sub    $0x8,%esp
f0100a89:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a8c:	68 38 5d 10 f0       	push   $0xf0105d38
f0100a91:	e8 e8 2b 00 00       	call   f010367e <cprintf>
f0100a96:	83 c4 10             	add    $0x10,%esp
f0100a99:	e9 f6 fe ff ff       	jmp    f0100994 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aa1:	5b                   	pop    %ebx
f0100aa2:	5e                   	pop    %esi
f0100aa3:	5f                   	pop    %edi
f0100aa4:	5d                   	pop    %ebp
f0100aa5:	c3                   	ret    

f0100aa6 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100aa6:	55                   	push   %ebp
f0100aa7:	89 e5                	mov    %esp,%ebp
f0100aa9:	53                   	push   %ebx
f0100aaa:	83 ec 04             	sub    $0x4,%esp
f0100aad:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100aaf:	83 3d 38 a2 22 f0 00 	cmpl   $0x0,0xf022a238
f0100ab6:	75 0f                	jne    f0100ac7 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ab8:	b8 07 d0 26 f0       	mov    $0xf026d007,%eax
f0100abd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ac2:	a3 38 a2 22 f0       	mov    %eax,0xf022a238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
f0100ac7:	83 ec 08             	sub    $0x8,%esp
f0100aca:	ff 35 38 a2 22 f0    	pushl  0xf022a238
f0100ad0:	68 e4 5e 10 f0       	push   $0xf0105ee4
f0100ad5:	e8 a4 2b 00 00       	call   f010367e <cprintf>
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
f0100ada:	89 d8                	mov    %ebx,%eax
f0100adc:	03 05 38 a2 22 f0    	add    0xf022a238,%eax
f0100ae2:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100ae7:	83 c4 08             	add    $0x8,%esp
f0100aea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100aef:	50                   	push   %eax
f0100af0:	68 fd 5e 10 f0       	push   $0xf0105efd
f0100af5:	e8 84 2b 00 00       	call   f010367e <cprintf>
	if (n != 0) {
f0100afa:	83 c4 10             	add    $0x10,%esp
		char *next = nextfree;
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
		return next;
	} else return nextfree;
f0100afd:	a1 38 a2 22 f0       	mov    0xf022a238,%eax
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
	if (n != 0) {
f0100b02:	85 db                	test   %ebx,%ebx
f0100b04:	74 13                	je     f0100b19 <boot_alloc+0x73>
		char *next = nextfree;
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
f0100b06:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100b0d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b13:	89 15 38 a2 22 f0    	mov    %edx,0xf022a238
		return next;
	} else return nextfree;

	return NULL;
}
f0100b19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b1c:	c9                   	leave  
f0100b1d:	c3                   	ret    

f0100b1e <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100b1e:	89 d1                	mov    %edx,%ecx
f0100b20:	c1 e9 16             	shr    $0x16,%ecx
f0100b23:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b26:	a8 01                	test   $0x1,%al
f0100b28:	74 52                	je     f0100b7c <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b2a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b2f:	89 c1                	mov    %eax,%ecx
f0100b31:	c1 e9 0c             	shr    $0xc,%ecx
f0100b34:	3b 0d 88 ae 22 f0    	cmp    0xf022ae88,%ecx
f0100b3a:	72 1b                	jb     f0100b57 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b3c:	55                   	push   %ebp
f0100b3d:	89 e5                	mov    %esp,%ebp
f0100b3f:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b42:	50                   	push   %eax
f0100b43:	68 64 59 10 f0       	push   $0xf0105964
f0100b48:	68 87 03 00 00       	push   $0x387
f0100b4d:	68 10 5f 10 f0       	push   $0xf0105f10
f0100b52:	e8 e9 f4 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b57:	c1 ea 0c             	shr    $0xc,%edx
f0100b5a:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b60:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b67:	89 c2                	mov    %eax,%edx
f0100b69:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b71:	85 d2                	test   %edx,%edx
f0100b73:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b78:	0f 44 c2             	cmove  %edx,%eax
f0100b7b:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b81:	c3                   	ret    

f0100b82 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b82:	55                   	push   %ebp
f0100b83:	89 e5                	mov    %esp,%ebp
f0100b85:	57                   	push   %edi
f0100b86:	56                   	push   %esi
f0100b87:	53                   	push   %ebx
f0100b88:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b8b:	84 c0                	test   %al,%al
f0100b8d:	0f 85 a0 02 00 00    	jne    f0100e33 <check_page_free_list+0x2b1>
f0100b93:	e9 ad 02 00 00       	jmp    f0100e45 <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b98:	83 ec 04             	sub    $0x4,%esp
f0100b9b:	68 b8 62 10 f0       	push   $0xf01062b8
f0100ba0:	68 b8 02 00 00       	push   $0x2b8
f0100ba5:	68 10 5f 10 f0       	push   $0xf0105f10
f0100baa:	e8 91 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100baf:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100bb2:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100bb5:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100bb8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100bbb:	89 c2                	mov    %eax,%edx
f0100bbd:	2b 15 90 ae 22 f0    	sub    0xf022ae90,%edx
f0100bc3:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100bc9:	0f 95 c2             	setne  %dl
f0100bcc:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100bcf:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100bd3:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100bd5:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bd9:	8b 00                	mov    (%eax),%eax
f0100bdb:	85 c0                	test   %eax,%eax
f0100bdd:	75 dc                	jne    f0100bbb <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100bdf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100be2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100be8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100beb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100bee:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100bf0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bf3:	a3 40 a2 22 f0       	mov    %eax,0xf022a240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bf8:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bfd:	8b 1d 40 a2 22 f0    	mov    0xf022a240,%ebx
f0100c03:	eb 53                	jmp    f0100c58 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c05:	89 d8                	mov    %ebx,%eax
f0100c07:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f0100c0d:	c1 f8 03             	sar    $0x3,%eax
f0100c10:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c13:	89 c2                	mov    %eax,%edx
f0100c15:	c1 ea 16             	shr    $0x16,%edx
f0100c18:	39 f2                	cmp    %esi,%edx
f0100c1a:	73 3a                	jae    f0100c56 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c1c:	89 c2                	mov    %eax,%edx
f0100c1e:	c1 ea 0c             	shr    $0xc,%edx
f0100c21:	3b 15 88 ae 22 f0    	cmp    0xf022ae88,%edx
f0100c27:	72 12                	jb     f0100c3b <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c29:	50                   	push   %eax
f0100c2a:	68 64 59 10 f0       	push   $0xf0105964
f0100c2f:	6a 58                	push   $0x58
f0100c31:	68 1c 5f 10 f0       	push   $0xf0105f1c
f0100c36:	e8 05 f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c3b:	83 ec 04             	sub    $0x4,%esp
f0100c3e:	68 80 00 00 00       	push   $0x80
f0100c43:	68 97 00 00 00       	push   $0x97
f0100c48:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c4d:	50                   	push   %eax
f0100c4e:	e8 30 40 00 00       	call   f0104c83 <memset>
f0100c53:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c56:	8b 1b                	mov    (%ebx),%ebx
f0100c58:	85 db                	test   %ebx,%ebx
f0100c5a:	75 a9                	jne    f0100c05 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c5c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c61:	e8 40 fe ff ff       	call   f0100aa6 <boot_alloc>
f0100c66:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c69:	8b 15 40 a2 22 f0    	mov    0xf022a240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c6f:	8b 0d 90 ae 22 f0    	mov    0xf022ae90,%ecx
		assert(pp < pages + npages);
f0100c75:	a1 88 ae 22 f0       	mov    0xf022ae88,%eax
f0100c7a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c7d:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c80:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c83:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c86:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c8b:	e9 52 01 00 00       	jmp    f0100de2 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c90:	39 ca                	cmp    %ecx,%edx
f0100c92:	73 19                	jae    f0100cad <check_page_free_list+0x12b>
f0100c94:	68 2a 5f 10 f0       	push   $0xf0105f2a
f0100c99:	68 36 5f 10 f0       	push   $0xf0105f36
f0100c9e:	68 d2 02 00 00       	push   $0x2d2
f0100ca3:	68 10 5f 10 f0       	push   $0xf0105f10
f0100ca8:	e8 93 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100cad:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cb0:	72 19                	jb     f0100ccb <check_page_free_list+0x149>
f0100cb2:	68 4b 5f 10 f0       	push   $0xf0105f4b
f0100cb7:	68 36 5f 10 f0       	push   $0xf0105f36
f0100cbc:	68 d3 02 00 00       	push   $0x2d3
f0100cc1:	68 10 5f 10 f0       	push   $0xf0105f10
f0100cc6:	e8 75 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ccb:	89 d0                	mov    %edx,%eax
f0100ccd:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100cd0:	a8 07                	test   $0x7,%al
f0100cd2:	74 19                	je     f0100ced <check_page_free_list+0x16b>
f0100cd4:	68 dc 62 10 f0       	push   $0xf01062dc
f0100cd9:	68 36 5f 10 f0       	push   $0xf0105f36
f0100cde:	68 d4 02 00 00       	push   $0x2d4
f0100ce3:	68 10 5f 10 f0       	push   $0xf0105f10
f0100ce8:	e8 53 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ced:	c1 f8 03             	sar    $0x3,%eax
f0100cf0:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100cf3:	85 c0                	test   %eax,%eax
f0100cf5:	75 19                	jne    f0100d10 <check_page_free_list+0x18e>
f0100cf7:	68 5f 5f 10 f0       	push   $0xf0105f5f
f0100cfc:	68 36 5f 10 f0       	push   $0xf0105f36
f0100d01:	68 d7 02 00 00       	push   $0x2d7
f0100d06:	68 10 5f 10 f0       	push   $0xf0105f10
f0100d0b:	e8 30 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d10:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d15:	75 19                	jne    f0100d30 <check_page_free_list+0x1ae>
f0100d17:	68 70 5f 10 f0       	push   $0xf0105f70
f0100d1c:	68 36 5f 10 f0       	push   $0xf0105f36
f0100d21:	68 d8 02 00 00       	push   $0x2d8
f0100d26:	68 10 5f 10 f0       	push   $0xf0105f10
f0100d2b:	e8 10 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d30:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d35:	75 19                	jne    f0100d50 <check_page_free_list+0x1ce>
f0100d37:	68 10 63 10 f0       	push   $0xf0106310
f0100d3c:	68 36 5f 10 f0       	push   $0xf0105f36
f0100d41:	68 d9 02 00 00       	push   $0x2d9
f0100d46:	68 10 5f 10 f0       	push   $0xf0105f10
f0100d4b:	e8 f0 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d50:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d55:	75 19                	jne    f0100d70 <check_page_free_list+0x1ee>
f0100d57:	68 89 5f 10 f0       	push   $0xf0105f89
f0100d5c:	68 36 5f 10 f0       	push   $0xf0105f36
f0100d61:	68 da 02 00 00       	push   $0x2da
f0100d66:	68 10 5f 10 f0       	push   $0xf0105f10
f0100d6b:	e8 d0 f2 ff ff       	call   f0100040 <_panic>
		// cprintf("pp: %x, page2pa(pp): %x, page2kva(pp): %x, first_free_page: %x\n",
		// 	pp, page2pa(pp), page2kva(pp), first_free_page);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d70:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d75:	0f 86 f1 00 00 00    	jbe    f0100e6c <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d7b:	89 c7                	mov    %eax,%edi
f0100d7d:	c1 ef 0c             	shr    $0xc,%edi
f0100d80:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d83:	77 12                	ja     f0100d97 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d85:	50                   	push   %eax
f0100d86:	68 64 59 10 f0       	push   $0xf0105964
f0100d8b:	6a 58                	push   $0x58
f0100d8d:	68 1c 5f 10 f0       	push   $0xf0105f1c
f0100d92:	e8 a9 f2 ff ff       	call   f0100040 <_panic>
f0100d97:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d9d:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100da0:	0f 86 b6 00 00 00    	jbe    f0100e5c <check_page_free_list+0x2da>
f0100da6:	68 34 63 10 f0       	push   $0xf0106334
f0100dab:	68 36 5f 10 f0       	push   $0xf0105f36
f0100db0:	68 dd 02 00 00       	push   $0x2dd
f0100db5:	68 10 5f 10 f0       	push   $0xf0105f10
f0100dba:	e8 81 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100dbf:	68 a3 5f 10 f0       	push   $0xf0105fa3
f0100dc4:	68 36 5f 10 f0       	push   $0xf0105f36
f0100dc9:	68 df 02 00 00       	push   $0x2df
f0100dce:	68 10 5f 10 f0       	push   $0xf0105f10
f0100dd3:	e8 68 f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100dd8:	83 c6 01             	add    $0x1,%esi
f0100ddb:	eb 03                	jmp    f0100de0 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100ddd:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100de0:	8b 12                	mov    (%edx),%edx
f0100de2:	85 d2                	test   %edx,%edx
f0100de4:	0f 85 a6 fe ff ff    	jne    f0100c90 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100dea:	85 f6                	test   %esi,%esi
f0100dec:	7f 19                	jg     f0100e07 <check_page_free_list+0x285>
f0100dee:	68 c0 5f 10 f0       	push   $0xf0105fc0
f0100df3:	68 36 5f 10 f0       	push   $0xf0105f36
f0100df8:	68 e7 02 00 00       	push   $0x2e7
f0100dfd:	68 10 5f 10 f0       	push   $0xf0105f10
f0100e02:	e8 39 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e07:	85 db                	test   %ebx,%ebx
f0100e09:	7f 19                	jg     f0100e24 <check_page_free_list+0x2a2>
f0100e0b:	68 d2 5f 10 f0       	push   $0xf0105fd2
f0100e10:	68 36 5f 10 f0       	push   $0xf0105f36
f0100e15:	68 e8 02 00 00       	push   $0x2e8
f0100e1a:	68 10 5f 10 f0       	push   $0xf0105f10
f0100e1f:	e8 1c f2 ff ff       	call   f0100040 <_panic>
	cprintf("check_page_free_list done\n");
f0100e24:	83 ec 0c             	sub    $0xc,%esp
f0100e27:	68 e3 5f 10 f0       	push   $0xf0105fe3
f0100e2c:	e8 4d 28 00 00       	call   f010367e <cprintf>
}
f0100e31:	eb 49                	jmp    f0100e7c <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100e33:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f0100e38:	85 c0                	test   %eax,%eax
f0100e3a:	0f 85 6f fd ff ff    	jne    f0100baf <check_page_free_list+0x2d>
f0100e40:	e9 53 fd ff ff       	jmp    f0100b98 <check_page_free_list+0x16>
f0100e45:	83 3d 40 a2 22 f0 00 	cmpl   $0x0,0xf022a240
f0100e4c:	0f 84 46 fd ff ff    	je     f0100b98 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e52:	be 00 04 00 00       	mov    $0x400,%esi
f0100e57:	e9 a1 fd ff ff       	jmp    f0100bfd <check_page_free_list+0x7b>
		assert(page2pa(pp) != EXTPHYSMEM);
		// cprintf("pp: %x, page2pa(pp): %x, page2kva(pp): %x, first_free_page: %x\n",
		// 	pp, page2pa(pp), page2kva(pp), first_free_page);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e5c:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e61:	0f 85 76 ff ff ff    	jne    f0100ddd <check_page_free_list+0x25b>
f0100e67:	e9 53 ff ff ff       	jmp    f0100dbf <check_page_free_list+0x23d>
f0100e6c:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e71:	0f 85 61 ff ff ff    	jne    f0100dd8 <check_page_free_list+0x256>
f0100e77:	e9 43 ff ff ff       	jmp    f0100dbf <check_page_free_list+0x23d>
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
	cprintf("check_page_free_list done\n");
}
f0100e7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e7f:	5b                   	pop    %ebx
f0100e80:	5e                   	pop    %esi
f0100e81:	5f                   	pop    %edi
f0100e82:	5d                   	pop    %ebp
f0100e83:	c3                   	ret    

f0100e84 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e84:	8b 0d 40 a2 22 f0    	mov    0xf022a240,%ecx
f0100e8a:	b8 08 00 00 00       	mov    $0x8,%eax
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < MPENTRY_PADDR/PGSIZE; i++) {
		pages[i].pp_ref = 0;
f0100e8f:	89 c2                	mov    %eax,%edx
f0100e91:	03 15 90 ae 22 f0    	add    0xf022ae90,%edx
f0100e97:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f0100e9d:	89 0a                	mov    %ecx,(%edx)
		page_free_list = &pages[i];
f0100e9f:	89 c1                	mov    %eax,%ecx
f0100ea1:	03 0d 90 ae 22 f0    	add    0xf022ae90,%ecx
f0100ea7:	83 c0 08             	add    $0x8,%eax
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < MPENTRY_PADDR/PGSIZE; i++) {
f0100eaa:	83 f8 38             	cmp    $0x38,%eax
f0100ead:	75 e0                	jne    f0100e8f <page_init+0xb>
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100eaf:	55                   	push   %ebp
f0100eb0:	89 e5                	mov    %esp,%ebp
f0100eb2:	53                   	push   %ebx
f0100eb3:	89 0d 40 a2 22 f0    	mov    %ecx,0xf022a240
	for (i = 1; i < MPENTRY_PADDR/PGSIZE; i++) {
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	int point = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
f0100eb9:	a1 48 a2 22 f0       	mov    0xf022a248,%eax
f0100ebe:	05 ff ff 01 10       	add    $0x1001ffff,%eax
	//cprintf("%x\n", ((char*)envs) + (sizeof(struct Env) * NENV));
	//cprintf("med=%d\n", med);
	for (i = point; i < npages; i++) {
f0100ec3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ec8:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100ece:	85 c0                	test   %eax,%eax
f0100ed0:	0f 48 c2             	cmovs  %edx,%eax
f0100ed3:	c1 f8 0c             	sar    $0xc,%eax
f0100ed6:	89 c2                	mov    %eax,%edx
f0100ed8:	c1 e0 03             	shl    $0x3,%eax
f0100edb:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ee0:	eb 23                	jmp    f0100f05 <page_init+0x81>
		pages[i].pp_ref = 0;
f0100ee2:	89 c3                	mov    %eax,%ebx
f0100ee4:	03 1d 90 ae 22 f0    	add    0xf022ae90,%ebx
f0100eea:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		pages[i].pp_link = page_free_list;
f0100ef0:	89 0b                	mov    %ecx,(%ebx)
		page_free_list = &pages[i];
f0100ef2:	89 c1                	mov    %eax,%ecx
f0100ef4:	03 0d 90 ae 22 f0    	add    0xf022ae90,%ecx
		page_free_list = &pages[i];
	}
	int point = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
	//cprintf("%x\n", ((char*)envs) + (sizeof(struct Env) * NENV));
	//cprintf("med=%d\n", med);
	for (i = point; i < npages; i++) {
f0100efa:	83 c2 01             	add    $0x1,%edx
f0100efd:	83 c0 08             	add    $0x8,%eax
f0100f00:	bb 01 00 00 00       	mov    $0x1,%ebx
f0100f05:	3b 15 88 ae 22 f0    	cmp    0xf022ae88,%edx
f0100f0b:	72 d5                	jb     f0100ee2 <page_init+0x5e>
f0100f0d:	84 db                	test   %bl,%bl
f0100f0f:	74 06                	je     f0100f17 <page_init+0x93>
f0100f11:	89 0d 40 a2 22 f0    	mov    %ecx,0xf022a240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100f17:	5b                   	pop    %ebx
f0100f18:	5d                   	pop    %ebp
f0100f19:	c3                   	ret    

f0100f1a <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f1a:	55                   	push   %ebp
f0100f1b:	89 e5                	mov    %esp,%ebp
f0100f1d:	53                   	push   %ebx
f0100f1e:	83 ec 04             	sub    $0x4,%esp
	if (page_free_list) {
f0100f21:	8b 1d 40 a2 22 f0    	mov    0xf022a240,%ebx
f0100f27:	85 db                	test   %ebx,%ebx
f0100f29:	74 52                	je     f0100f7d <page_alloc+0x63>
		struct PageInfo *ret = page_free_list;
		page_free_list = page_free_list->pp_link;
f0100f2b:	8b 03                	mov    (%ebx),%eax
f0100f2d:	a3 40 a2 22 f0       	mov    %eax,0xf022a240
		if (alloc_flags & ALLOC_ZERO) 
f0100f32:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f36:	74 45                	je     f0100f7d <page_alloc+0x63>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f38:	89 d8                	mov    %ebx,%eax
f0100f3a:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f0100f40:	c1 f8 03             	sar    $0x3,%eax
f0100f43:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f46:	89 c2                	mov    %eax,%edx
f0100f48:	c1 ea 0c             	shr    $0xc,%edx
f0100f4b:	3b 15 88 ae 22 f0    	cmp    0xf022ae88,%edx
f0100f51:	72 12                	jb     f0100f65 <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f53:	50                   	push   %eax
f0100f54:	68 64 59 10 f0       	push   $0xf0105964
f0100f59:	6a 58                	push   $0x58
f0100f5b:	68 1c 5f 10 f0       	push   $0xf0105f1c
f0100f60:	e8 db f0 ff ff       	call   f0100040 <_panic>
			memset(page2kva(ret), 0, PGSIZE);
f0100f65:	83 ec 04             	sub    $0x4,%esp
f0100f68:	68 00 10 00 00       	push   $0x1000
f0100f6d:	6a 00                	push   $0x0
f0100f6f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f74:	50                   	push   %eax
f0100f75:	e8 09 3d 00 00       	call   f0104c83 <memset>
f0100f7a:	83 c4 10             	add    $0x10,%esp
		return ret;
	}
	return NULL;
}
f0100f7d:	89 d8                	mov    %ebx,%eax
f0100f7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f82:	c9                   	leave  
f0100f83:	c3                   	ret    

f0100f84 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f84:	55                   	push   %ebp
f0100f85:	89 e5                	mov    %esp,%ebp
f0100f87:	8b 45 08             	mov    0x8(%ebp),%eax
	pp->pp_link = page_free_list;
f0100f8a:	8b 15 40 a2 22 f0    	mov    0xf022a240,%edx
f0100f90:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f92:	a3 40 a2 22 f0       	mov    %eax,0xf022a240
}
f0100f97:	5d                   	pop    %ebp
f0100f98:	c3                   	ret    

f0100f99 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f99:	55                   	push   %ebp
f0100f9a:	89 e5                	mov    %esp,%ebp
f0100f9c:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100f9f:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100fa3:	83 e8 01             	sub    $0x1,%eax
f0100fa6:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100faa:	66 85 c0             	test   %ax,%ax
f0100fad:	75 09                	jne    f0100fb8 <page_decref+0x1f>
		page_free(pp);
f0100faf:	52                   	push   %edx
f0100fb0:	e8 cf ff ff ff       	call   f0100f84 <page_free>
f0100fb5:	83 c4 04             	add    $0x4,%esp
}
f0100fb8:	c9                   	leave  
f0100fb9:	c3                   	ret    

f0100fba <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100fba:	55                   	push   %ebp
f0100fbb:	89 e5                	mov    %esp,%ebp
f0100fbd:	56                   	push   %esi
f0100fbe:	53                   	push   %ebx
f0100fbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int dindex = PDX(va), tindex = PTX(va);
f0100fc2:	89 de                	mov    %ebx,%esi
f0100fc4:	c1 ee 0c             	shr    $0xc,%esi
f0100fc7:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
f0100fcd:	c1 eb 16             	shr    $0x16,%ebx
f0100fd0:	c1 e3 02             	shl    $0x2,%ebx
f0100fd3:	03 5d 08             	add    0x8(%ebp),%ebx
f0100fd6:	f6 03 01             	testb  $0x1,(%ebx)
f0100fd9:	75 2d                	jne    f0101008 <pgdir_walk+0x4e>
		if (create) {
f0100fdb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100fdf:	74 59                	je     f010103a <pgdir_walk+0x80>
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
f0100fe1:	83 ec 0c             	sub    $0xc,%esp
f0100fe4:	6a 01                	push   $0x1
f0100fe6:	e8 2f ff ff ff       	call   f0100f1a <page_alloc>
			if (!pg) return NULL;	//allocation fails
f0100feb:	83 c4 10             	add    $0x10,%esp
f0100fee:	85 c0                	test   %eax,%eax
f0100ff0:	74 4f                	je     f0101041 <pgdir_walk+0x87>
			pg->pp_ref++;
f0100ff2:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
f0100ff7:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f0100ffd:	c1 f8 03             	sar    $0x3,%eax
f0101000:	c1 e0 0c             	shl    $0xc,%eax
f0101003:	83 c8 07             	or     $0x7,%eax
f0101006:	89 03                	mov    %eax,(%ebx)
		} else return NULL;
	}
	pte_t *p = KADDR(PTE_ADDR(pgdir[dindex]));
f0101008:	8b 03                	mov    (%ebx),%eax
f010100a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010100f:	89 c2                	mov    %eax,%edx
f0101011:	c1 ea 0c             	shr    $0xc,%edx
f0101014:	3b 15 88 ae 22 f0    	cmp    0xf022ae88,%edx
f010101a:	72 15                	jb     f0101031 <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010101c:	50                   	push   %eax
f010101d:	68 64 59 10 f0       	push   $0xf0105964
f0101022:	68 b5 01 00 00       	push   $0x1b5
f0101027:	68 10 5f 10 f0       	push   $0xf0105f10
f010102c:	e8 0f f0 ff ff       	call   f0100040 <_panic>
	// 		struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
f0101031:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0101038:	eb 0c                	jmp    f0101046 <pgdir_walk+0x8c>
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
			pg->pp_ref++;
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
		} else return NULL;
f010103a:	b8 00 00 00 00       	mov    $0x0,%eax
f010103f:	eb 05                	jmp    f0101046 <pgdir_walk+0x8c>
	int dindex = PDX(va), tindex = PTX(va);
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
f0101041:	b8 00 00 00 00       	mov    $0x0,%eax
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
}
f0101046:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101049:	5b                   	pop    %ebx
f010104a:	5e                   	pop    %esi
f010104b:	5d                   	pop    %ebp
f010104c:	c3                   	ret    

f010104d <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010104d:	55                   	push   %ebp
f010104e:	89 e5                	mov    %esp,%ebp
f0101050:	57                   	push   %edi
f0101051:	56                   	push   %esi
f0101052:	53                   	push   %ebx
f0101053:	83 ec 20             	sub    $0x20,%esp
f0101056:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101059:	89 d7                	mov    %edx,%edi
f010105b:	89 cb                	mov    %ecx,%ebx
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
f010105d:	ff 75 08             	pushl  0x8(%ebp)
f0101060:	52                   	push   %edx
f0101061:	68 7c 63 10 f0       	push   $0xf010637c
f0101066:	e8 13 26 00 00       	call   f010367e <cprintf>
f010106b:	c1 eb 0c             	shr    $0xc,%ebx
f010106e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0101071:	83 c4 10             	add    $0x10,%esp
f0101074:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101077:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
f010107c:	29 df                	sub    %ebx,%edi
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
f010107e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101081:	83 c8 01             	or     $0x1,%eax
f0101084:	89 45 dc             	mov    %eax,-0x24(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0101087:	eb 3f                	jmp    f01010c8 <boot_map_region+0x7b>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
f0101089:	83 ec 04             	sub    $0x4,%esp
f010108c:	6a 01                	push   $0x1
f010108e:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0101091:	50                   	push   %eax
f0101092:	ff 75 e0             	pushl  -0x20(%ebp)
f0101095:	e8 20 ff ff ff       	call   f0100fba <pgdir_walk>
		if (!pte) panic("boot_map_region panic, out of memory");
f010109a:	83 c4 10             	add    $0x10,%esp
f010109d:	85 c0                	test   %eax,%eax
f010109f:	75 17                	jne    f01010b8 <boot_map_region+0x6b>
f01010a1:	83 ec 04             	sub    $0x4,%esp
f01010a4:	68 b0 63 10 f0       	push   $0xf01063b0
f01010a9:	68 d3 01 00 00       	push   $0x1d3
f01010ae:	68 10 5f 10 f0       	push   $0xf0105f10
f01010b3:	e8 88 ef ff ff       	call   f0100040 <_panic>
		*pte = pa | perm | PTE_P;
f01010b8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01010bb:	09 da                	or     %ebx,%edx
f01010bd:	89 10                	mov    %edx,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f01010bf:	83 c6 01             	add    $0x1,%esi
f01010c2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01010c8:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01010cb:	75 bc                	jne    f0101089 <boot_map_region+0x3c>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
	}
}
f01010cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010d0:	5b                   	pop    %ebx
f01010d1:	5e                   	pop    %esi
f01010d2:	5f                   	pop    %edi
f01010d3:	5d                   	pop    %ebp
f01010d4:	c3                   	ret    

f01010d5 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01010d5:	55                   	push   %ebp
f01010d6:	89 e5                	mov    %esp,%ebp
f01010d8:	53                   	push   %ebx
f01010d9:	83 ec 08             	sub    $0x8,%esp
f01010dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
f01010df:	6a 00                	push   $0x0
f01010e1:	ff 75 0c             	pushl  0xc(%ebp)
f01010e4:	ff 75 08             	pushl  0x8(%ebp)
f01010e7:	e8 ce fe ff ff       	call   f0100fba <pgdir_walk>
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f01010ec:	83 c4 10             	add    $0x10,%esp
f01010ef:	85 c0                	test   %eax,%eax
f01010f1:	74 37                	je     f010112a <page_lookup+0x55>
f01010f3:	f6 00 01             	testb  $0x1,(%eax)
f01010f6:	74 39                	je     f0101131 <page_lookup+0x5c>
	if (pte_store)
f01010f8:	85 db                	test   %ebx,%ebx
f01010fa:	74 02                	je     f01010fe <page_lookup+0x29>
		*pte_store = pte;	//found and set
f01010fc:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010fe:	8b 00                	mov    (%eax),%eax
f0101100:	c1 e8 0c             	shr    $0xc,%eax
f0101103:	3b 05 88 ae 22 f0    	cmp    0xf022ae88,%eax
f0101109:	72 14                	jb     f010111f <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f010110b:	83 ec 04             	sub    $0x4,%esp
f010110e:	68 d8 63 10 f0       	push   $0xf01063d8
f0101113:	6a 51                	push   $0x51
f0101115:	68 1c 5f 10 f0       	push   $0xf0105f1c
f010111a:	e8 21 ef ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010111f:	8b 15 90 ae 22 f0    	mov    0xf022ae90,%edx
f0101125:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return pa2page(PTE_ADDR(*pte));		
f0101128:	eb 0c                	jmp    f0101136 <page_lookup+0x61>
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f010112a:	b8 00 00 00 00       	mov    $0x0,%eax
f010112f:	eb 05                	jmp    f0101136 <page_lookup+0x61>
f0101131:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pte_store)
		*pte_store = pte;	//found and set
	return pa2page(PTE_ADDR(*pte));		
}
f0101136:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101139:	c9                   	leave  
f010113a:	c3                   	ret    

f010113b <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010113b:	55                   	push   %ebp
f010113c:	89 e5                	mov    %esp,%ebp
f010113e:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101141:	e8 60 41 00 00       	call   f01052a6 <cpunum>
f0101146:	6b c0 74             	imul   $0x74,%eax,%eax
f0101149:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f0101150:	74 16                	je     f0101168 <tlb_invalidate+0x2d>
f0101152:	e8 4f 41 00 00       	call   f01052a6 <cpunum>
f0101157:	6b c0 74             	imul   $0x74,%eax,%eax
f010115a:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0101160:	8b 55 08             	mov    0x8(%ebp),%edx
f0101163:	39 50 60             	cmp    %edx,0x60(%eax)
f0101166:	75 06                	jne    f010116e <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101168:	8b 45 0c             	mov    0xc(%ebp),%eax
f010116b:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f010116e:	c9                   	leave  
f010116f:	c3                   	ret    

f0101170 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101170:	55                   	push   %ebp
f0101171:	89 e5                	mov    %esp,%ebp
f0101173:	56                   	push   %esi
f0101174:	53                   	push   %ebx
f0101175:	83 ec 14             	sub    $0x14,%esp
f0101178:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010117b:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte;
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f010117e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101181:	50                   	push   %eax
f0101182:	56                   	push   %esi
f0101183:	53                   	push   %ebx
f0101184:	e8 4c ff ff ff       	call   f01010d5 <page_lookup>
	if (!pg || !(*pte & PTE_P)) return;	//page not exist
f0101189:	83 c4 10             	add    $0x10,%esp
f010118c:	85 c0                	test   %eax,%eax
f010118e:	74 27                	je     f01011b7 <page_remove+0x47>
f0101190:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101193:	f6 02 01             	testb  $0x1,(%edx)
f0101196:	74 1f                	je     f01011b7 <page_remove+0x47>
//   - The ref count on the physical page should decrement.
//   - The physical page should be freed if the refcount reaches 0.
	page_decref(pg);
f0101198:	83 ec 0c             	sub    $0xc,%esp
f010119b:	50                   	push   %eax
f010119c:	e8 f8 fd ff ff       	call   f0100f99 <page_decref>
//   - The pg table entry corresponding to 'va' should be set to 0.
	*pte = 0;
f01011a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
//   - The TLB must be invalidated if you remove an entry from
//     the page table.
	tlb_invalidate(pgdir, va);
f01011aa:	83 c4 08             	add    $0x8,%esp
f01011ad:	56                   	push   %esi
f01011ae:	53                   	push   %ebx
f01011af:	e8 87 ff ff ff       	call   f010113b <tlb_invalidate>
f01011b4:	83 c4 10             	add    $0x10,%esp
}
f01011b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011ba:	5b                   	pop    %ebx
f01011bb:	5e                   	pop    %esi
f01011bc:	5d                   	pop    %ebp
f01011bd:	c3                   	ret    

f01011be <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01011be:	55                   	push   %ebp
f01011bf:	89 e5                	mov    %esp,%ebp
f01011c1:	57                   	push   %edi
f01011c2:	56                   	push   %esi
f01011c3:	53                   	push   %ebx
f01011c4:	83 ec 10             	sub    $0x10,%esp
f01011c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011ca:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
f01011cd:	6a 01                	push   $0x1
f01011cf:	57                   	push   %edi
f01011d0:	ff 75 08             	pushl  0x8(%ebp)
f01011d3:	e8 e2 fd ff ff       	call   f0100fba <pgdir_walk>
	if (!pte) 	//page table not allocated
f01011d8:	83 c4 10             	add    $0x10,%esp
f01011db:	85 c0                	test   %eax,%eax
f01011dd:	74 38                	je     f0101217 <page_insert+0x59>
f01011df:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;	
	//increase ref count to avoid the corner case that pp is freed before it is inserted.
	pp->pp_ref++;	
f01011e1:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
f01011e6:	f6 00 01             	testb  $0x1,(%eax)
f01011e9:	74 0f                	je     f01011fa <page_insert+0x3c>
		page_remove(pgdir, va);
f01011eb:	83 ec 08             	sub    $0x8,%esp
f01011ee:	57                   	push   %edi
f01011ef:	ff 75 08             	pushl  0x8(%ebp)
f01011f2:	e8 79 ff ff ff       	call   f0101170 <page_remove>
f01011f7:	83 c4 10             	add    $0x10,%esp
	*pte = page2pa(pp) | perm | PTE_P;
f01011fa:	2b 1d 90 ae 22 f0    	sub    0xf022ae90,%ebx
f0101200:	c1 fb 03             	sar    $0x3,%ebx
f0101203:	c1 e3 0c             	shl    $0xc,%ebx
f0101206:	8b 45 14             	mov    0x14(%ebp),%eax
f0101209:	83 c8 01             	or     $0x1,%eax
f010120c:	09 c3                	or     %eax,%ebx
f010120e:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101210:	b8 00 00 00 00       	mov    $0x0,%eax
f0101215:	eb 05                	jmp    f010121c <page_insert+0x5e>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
	if (!pte) 	//page table not allocated
		return -E_NO_MEM;	
f0101217:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	pp->pp_ref++;	
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
		page_remove(pgdir, va);
	*pte = page2pa(pp) | perm | PTE_P;
	return 0;
}
f010121c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010121f:	5b                   	pop    %ebx
f0101220:	5e                   	pop    %esi
f0101221:	5f                   	pop    %edi
f0101222:	5d                   	pop    %ebp
f0101223:	c3                   	ret    

f0101224 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101224:	55                   	push   %ebp
f0101225:	89 e5                	mov    %esp,%ebp
f0101227:	53                   	push   %ebx
f0101228:	83 ec 04             	sub    $0x4,%esp
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	//panic("mmio_map_region not implemented");

	size_t size_pages = ROUNDUP(size, PGSIZE);
f010122b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010122e:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101234:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base + size_pages > MMIOLIM)
f010123a:	8b 15 00 f3 11 f0    	mov    0xf011f300,%edx
f0101240:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f0101243:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101248:	76 17                	jbe    f0101261 <mmio_map_region+0x3d>
		panic("Out of bounds\n");
f010124a:	83 ec 04             	sub    $0x4,%esp
f010124d:	68 fe 5f 10 f0       	push   $0xf0105ffe
f0101252:	68 63 02 00 00       	push   $0x263
f0101257:	68 10 5f 10 f0       	push   $0xf0105f10
f010125c:	e8 df ed ff ff       	call   f0100040 <_panic>

	boot_map_region(kern_pgdir, base, size_pages, pa, PTE_PCD | PTE_PWT | PTE_W);
f0101261:	83 ec 08             	sub    $0x8,%esp
f0101264:	6a 1a                	push   $0x1a
f0101266:	ff 75 08             	pushl  0x8(%ebp)
f0101269:	89 d9                	mov    %ebx,%ecx
f010126b:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0101270:	e8 d8 fd ff ff       	call   f010104d <boot_map_region>

	uintptr_t mapped_base = base;
f0101275:	a1 00 f3 11 f0       	mov    0xf011f300,%eax
	base += size_pages;
f010127a:	01 c3                	add    %eax,%ebx
f010127c:	89 1d 00 f3 11 f0    	mov    %ebx,0xf011f300
	return (void *) mapped_base;
}
f0101282:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101285:	c9                   	leave  
f0101286:	c3                   	ret    

f0101287 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101287:	55                   	push   %ebp
f0101288:	89 e5                	mov    %esp,%ebp
f010128a:	57                   	push   %edi
f010128b:	56                   	push   %esi
f010128c:	53                   	push   %ebx
f010128d:	83 ec 48             	sub    $0x48,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101290:	6a 15                	push   $0x15
f0101292:	e8 68 22 00 00       	call   f01034ff <mc146818_read>
f0101297:	89 c3                	mov    %eax,%ebx
f0101299:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01012a0:	e8 5a 22 00 00       	call   f01034ff <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01012a5:	c1 e0 08             	shl    $0x8,%eax
f01012a8:	09 d8                	or     %ebx,%eax
f01012aa:	c1 e0 0a             	shl    $0xa,%eax
f01012ad:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01012b3:	85 c0                	test   %eax,%eax
f01012b5:	0f 48 c2             	cmovs  %edx,%eax
f01012b8:	c1 f8 0c             	sar    $0xc,%eax
f01012bb:	a3 44 a2 22 f0       	mov    %eax,0xf022a244
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01012c0:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01012c7:	e8 33 22 00 00       	call   f01034ff <mc146818_read>
f01012cc:	89 c3                	mov    %eax,%ebx
f01012ce:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01012d5:	e8 25 22 00 00       	call   f01034ff <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01012da:	c1 e0 08             	shl    $0x8,%eax
f01012dd:	09 d8                	or     %ebx,%eax
f01012df:	c1 e0 0a             	shl    $0xa,%eax
f01012e2:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01012e8:	83 c4 10             	add    $0x10,%esp
f01012eb:	85 c0                	test   %eax,%eax
f01012ed:	0f 48 c2             	cmovs  %edx,%eax
f01012f0:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01012f3:	85 c0                	test   %eax,%eax
f01012f5:	74 0e                	je     f0101305 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01012f7:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01012fd:	89 15 88 ae 22 f0    	mov    %edx,0xf022ae88
f0101303:	eb 0c                	jmp    f0101311 <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101305:	8b 15 44 a2 22 f0    	mov    0xf022a244,%edx
f010130b:	89 15 88 ae 22 f0    	mov    %edx,0xf022ae88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101311:	c1 e0 0c             	shl    $0xc,%eax
f0101314:	c1 e8 0a             	shr    $0xa,%eax
f0101317:	50                   	push   %eax
f0101318:	a1 44 a2 22 f0       	mov    0xf022a244,%eax
f010131d:	c1 e0 0c             	shl    $0xc,%eax
f0101320:	c1 e8 0a             	shr    $0xa,%eax
f0101323:	50                   	push   %eax
f0101324:	a1 88 ae 22 f0       	mov    0xf022ae88,%eax
f0101329:	c1 e0 0c             	shl    $0xc,%eax
f010132c:	c1 e8 0a             	shr    $0xa,%eax
f010132f:	50                   	push   %eax
f0101330:	68 f8 63 10 f0       	push   $0xf01063f8
f0101335:	e8 44 23 00 00       	call   f010367e <cprintf>
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.

	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010133a:	b8 00 10 00 00       	mov    $0x1000,%eax
f010133f:	e8 62 f7 ff ff       	call   f0100aa6 <boot_alloc>
f0101344:	a3 8c ae 22 f0       	mov    %eax,0xf022ae8c
	memset(kern_pgdir, 0, PGSIZE);
f0101349:	83 c4 0c             	add    $0xc,%esp
f010134c:	68 00 10 00 00       	push   $0x1000
f0101351:	6a 00                	push   $0x0
f0101353:	50                   	push   %eax
f0101354:	e8 2a 39 00 00       	call   f0104c83 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101359:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010135e:	83 c4 10             	add    $0x10,%esp
f0101361:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101366:	77 15                	ja     f010137d <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101368:	50                   	push   %eax
f0101369:	68 88 59 10 f0       	push   $0xf0105988
f010136e:	68 93 00 00 00       	push   $0x93
f0101373:	68 10 5f 10 f0       	push   $0xf0105f10
f0101378:	e8 c3 ec ff ff       	call   f0100040 <_panic>
f010137d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101383:	83 ca 05             	or     $0x5,%edx
f0101386:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
f010138c:	a1 88 ae 22 f0       	mov    0xf022ae88,%eax
f0101391:	c1 e0 03             	shl    $0x3,%eax
f0101394:	e8 0d f7 ff ff       	call   f0100aa6 <boot_alloc>
f0101399:	a3 90 ae 22 f0       	mov    %eax,0xf022ae90

	cprintf("npages: %d\n", npages);
f010139e:	83 ec 08             	sub    $0x8,%esp
f01013a1:	ff 35 88 ae 22 f0    	pushl  0xf022ae88
f01013a7:	68 0d 60 10 f0       	push   $0xf010600d
f01013ac:	e8 cd 22 00 00       	call   f010367e <cprintf>
	cprintf("npages_basemem: %d\n", npages_basemem);
f01013b1:	83 c4 08             	add    $0x8,%esp
f01013b4:	ff 35 44 a2 22 f0    	pushl  0xf022a244
f01013ba:	68 19 60 10 f0       	push   $0xf0106019
f01013bf:	e8 ba 22 00 00       	call   f010367e <cprintf>
	cprintf("pages: %x\n", pages);
f01013c4:	83 c4 08             	add    $0x8,%esp
f01013c7:	ff 35 90 ae 22 f0    	pushl  0xf022ae90
f01013cd:	68 2d 60 10 f0       	push   $0xf010602d
f01013d2:	e8 a7 22 00 00       	call   f010367e <cprintf>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *) boot_alloc(sizeof(struct Env) * NENV);
f01013d7:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01013dc:	e8 c5 f6 ff ff       	call   f0100aa6 <boot_alloc>
f01013e1:	a3 48 a2 22 f0       	mov    %eax,0xf022a248
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01013e6:	e8 99 fa ff ff       	call   f0100e84 <page_init>

	check_page_free_list(1);
f01013eb:	b8 01 00 00 00       	mov    $0x1,%eax
f01013f0:	e8 8d f7 ff ff       	call   f0100b82 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01013f5:	83 c4 10             	add    $0x10,%esp
f01013f8:	83 3d 90 ae 22 f0 00 	cmpl   $0x0,0xf022ae90
f01013ff:	75 17                	jne    f0101418 <mem_init+0x191>
		panic("'pages' is a null pointer!");
f0101401:	83 ec 04             	sub    $0x4,%esp
f0101404:	68 38 60 10 f0       	push   $0xf0106038
f0101409:	68 fa 02 00 00       	push   $0x2fa
f010140e:	68 10 5f 10 f0       	push   $0xf0105f10
f0101413:	e8 28 ec ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101418:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f010141d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101422:	eb 05                	jmp    f0101429 <mem_init+0x1a2>
		++nfree;
f0101424:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101427:	8b 00                	mov    (%eax),%eax
f0101429:	85 c0                	test   %eax,%eax
f010142b:	75 f7                	jne    f0101424 <mem_init+0x19d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010142d:	83 ec 0c             	sub    $0xc,%esp
f0101430:	6a 00                	push   $0x0
f0101432:	e8 e3 fa ff ff       	call   f0100f1a <page_alloc>
f0101437:	89 c7                	mov    %eax,%edi
f0101439:	83 c4 10             	add    $0x10,%esp
f010143c:	85 c0                	test   %eax,%eax
f010143e:	75 19                	jne    f0101459 <mem_init+0x1d2>
f0101440:	68 53 60 10 f0       	push   $0xf0106053
f0101445:	68 36 5f 10 f0       	push   $0xf0105f36
f010144a:	68 02 03 00 00       	push   $0x302
f010144f:	68 10 5f 10 f0       	push   $0xf0105f10
f0101454:	e8 e7 eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101459:	83 ec 0c             	sub    $0xc,%esp
f010145c:	6a 00                	push   $0x0
f010145e:	e8 b7 fa ff ff       	call   f0100f1a <page_alloc>
f0101463:	89 c6                	mov    %eax,%esi
f0101465:	83 c4 10             	add    $0x10,%esp
f0101468:	85 c0                	test   %eax,%eax
f010146a:	75 19                	jne    f0101485 <mem_init+0x1fe>
f010146c:	68 69 60 10 f0       	push   $0xf0106069
f0101471:	68 36 5f 10 f0       	push   $0xf0105f36
f0101476:	68 03 03 00 00       	push   $0x303
f010147b:	68 10 5f 10 f0       	push   $0xf0105f10
f0101480:	e8 bb eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101485:	83 ec 0c             	sub    $0xc,%esp
f0101488:	6a 00                	push   $0x0
f010148a:	e8 8b fa ff ff       	call   f0100f1a <page_alloc>
f010148f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101492:	83 c4 10             	add    $0x10,%esp
f0101495:	85 c0                	test   %eax,%eax
f0101497:	75 19                	jne    f01014b2 <mem_init+0x22b>
f0101499:	68 7f 60 10 f0       	push   $0xf010607f
f010149e:	68 36 5f 10 f0       	push   $0xf0105f36
f01014a3:	68 04 03 00 00       	push   $0x304
f01014a8:	68 10 5f 10 f0       	push   $0xf0105f10
f01014ad:	e8 8e eb ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014b2:	39 f7                	cmp    %esi,%edi
f01014b4:	75 19                	jne    f01014cf <mem_init+0x248>
f01014b6:	68 95 60 10 f0       	push   $0xf0106095
f01014bb:	68 36 5f 10 f0       	push   $0xf0105f36
f01014c0:	68 07 03 00 00       	push   $0x307
f01014c5:	68 10 5f 10 f0       	push   $0xf0105f10
f01014ca:	e8 71 eb ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014d2:	39 c6                	cmp    %eax,%esi
f01014d4:	74 04                	je     f01014da <mem_init+0x253>
f01014d6:	39 c7                	cmp    %eax,%edi
f01014d8:	75 19                	jne    f01014f3 <mem_init+0x26c>
f01014da:	68 34 64 10 f0       	push   $0xf0106434
f01014df:	68 36 5f 10 f0       	push   $0xf0105f36
f01014e4:	68 08 03 00 00       	push   $0x308
f01014e9:	68 10 5f 10 f0       	push   $0xf0105f10
f01014ee:	e8 4d eb ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014f3:	8b 0d 90 ae 22 f0    	mov    0xf022ae90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014f9:	8b 15 88 ae 22 f0    	mov    0xf022ae88,%edx
f01014ff:	c1 e2 0c             	shl    $0xc,%edx
f0101502:	89 f8                	mov    %edi,%eax
f0101504:	29 c8                	sub    %ecx,%eax
f0101506:	c1 f8 03             	sar    $0x3,%eax
f0101509:	c1 e0 0c             	shl    $0xc,%eax
f010150c:	39 d0                	cmp    %edx,%eax
f010150e:	72 19                	jb     f0101529 <mem_init+0x2a2>
f0101510:	68 a7 60 10 f0       	push   $0xf01060a7
f0101515:	68 36 5f 10 f0       	push   $0xf0105f36
f010151a:	68 09 03 00 00       	push   $0x309
f010151f:	68 10 5f 10 f0       	push   $0xf0105f10
f0101524:	e8 17 eb ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101529:	89 f0                	mov    %esi,%eax
f010152b:	29 c8                	sub    %ecx,%eax
f010152d:	c1 f8 03             	sar    $0x3,%eax
f0101530:	c1 e0 0c             	shl    $0xc,%eax
f0101533:	39 c2                	cmp    %eax,%edx
f0101535:	77 19                	ja     f0101550 <mem_init+0x2c9>
f0101537:	68 c4 60 10 f0       	push   $0xf01060c4
f010153c:	68 36 5f 10 f0       	push   $0xf0105f36
f0101541:	68 0a 03 00 00       	push   $0x30a
f0101546:	68 10 5f 10 f0       	push   $0xf0105f10
f010154b:	e8 f0 ea ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101550:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101553:	29 c8                	sub    %ecx,%eax
f0101555:	c1 f8 03             	sar    $0x3,%eax
f0101558:	c1 e0 0c             	shl    $0xc,%eax
f010155b:	39 c2                	cmp    %eax,%edx
f010155d:	77 19                	ja     f0101578 <mem_init+0x2f1>
f010155f:	68 e1 60 10 f0       	push   $0xf01060e1
f0101564:	68 36 5f 10 f0       	push   $0xf0105f36
f0101569:	68 0b 03 00 00       	push   $0x30b
f010156e:	68 10 5f 10 f0       	push   $0xf0105f10
f0101573:	e8 c8 ea ff ff       	call   f0100040 <_panic>


	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101578:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f010157d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101580:	c7 05 40 a2 22 f0 00 	movl   $0x0,0xf022a240
f0101587:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010158a:	83 ec 0c             	sub    $0xc,%esp
f010158d:	6a 00                	push   $0x0
f010158f:	e8 86 f9 ff ff       	call   f0100f1a <page_alloc>
f0101594:	83 c4 10             	add    $0x10,%esp
f0101597:	85 c0                	test   %eax,%eax
f0101599:	74 19                	je     f01015b4 <mem_init+0x32d>
f010159b:	68 fe 60 10 f0       	push   $0xf01060fe
f01015a0:	68 36 5f 10 f0       	push   $0xf0105f36
f01015a5:	68 13 03 00 00       	push   $0x313
f01015aa:	68 10 5f 10 f0       	push   $0xf0105f10
f01015af:	e8 8c ea ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01015b4:	83 ec 0c             	sub    $0xc,%esp
f01015b7:	57                   	push   %edi
f01015b8:	e8 c7 f9 ff ff       	call   f0100f84 <page_free>
	page_free(pp1);
f01015bd:	89 34 24             	mov    %esi,(%esp)
f01015c0:	e8 bf f9 ff ff       	call   f0100f84 <page_free>
	page_free(pp2);
f01015c5:	83 c4 04             	add    $0x4,%esp
f01015c8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015cb:	e8 b4 f9 ff ff       	call   f0100f84 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015d7:	e8 3e f9 ff ff       	call   f0100f1a <page_alloc>
f01015dc:	89 c6                	mov    %eax,%esi
f01015de:	83 c4 10             	add    $0x10,%esp
f01015e1:	85 c0                	test   %eax,%eax
f01015e3:	75 19                	jne    f01015fe <mem_init+0x377>
f01015e5:	68 53 60 10 f0       	push   $0xf0106053
f01015ea:	68 36 5f 10 f0       	push   $0xf0105f36
f01015ef:	68 1a 03 00 00       	push   $0x31a
f01015f4:	68 10 5f 10 f0       	push   $0xf0105f10
f01015f9:	e8 42 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015fe:	83 ec 0c             	sub    $0xc,%esp
f0101601:	6a 00                	push   $0x0
f0101603:	e8 12 f9 ff ff       	call   f0100f1a <page_alloc>
f0101608:	89 c7                	mov    %eax,%edi
f010160a:	83 c4 10             	add    $0x10,%esp
f010160d:	85 c0                	test   %eax,%eax
f010160f:	75 19                	jne    f010162a <mem_init+0x3a3>
f0101611:	68 69 60 10 f0       	push   $0xf0106069
f0101616:	68 36 5f 10 f0       	push   $0xf0105f36
f010161b:	68 1b 03 00 00       	push   $0x31b
f0101620:	68 10 5f 10 f0       	push   $0xf0105f10
f0101625:	e8 16 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010162a:	83 ec 0c             	sub    $0xc,%esp
f010162d:	6a 00                	push   $0x0
f010162f:	e8 e6 f8 ff ff       	call   f0100f1a <page_alloc>
f0101634:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101637:	83 c4 10             	add    $0x10,%esp
f010163a:	85 c0                	test   %eax,%eax
f010163c:	75 19                	jne    f0101657 <mem_init+0x3d0>
f010163e:	68 7f 60 10 f0       	push   $0xf010607f
f0101643:	68 36 5f 10 f0       	push   $0xf0105f36
f0101648:	68 1c 03 00 00       	push   $0x31c
f010164d:	68 10 5f 10 f0       	push   $0xf0105f10
f0101652:	e8 e9 e9 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101657:	39 fe                	cmp    %edi,%esi
f0101659:	75 19                	jne    f0101674 <mem_init+0x3ed>
f010165b:	68 95 60 10 f0       	push   $0xf0106095
f0101660:	68 36 5f 10 f0       	push   $0xf0105f36
f0101665:	68 1e 03 00 00       	push   $0x31e
f010166a:	68 10 5f 10 f0       	push   $0xf0105f10
f010166f:	e8 cc e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101674:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101677:	39 c7                	cmp    %eax,%edi
f0101679:	74 04                	je     f010167f <mem_init+0x3f8>
f010167b:	39 c6                	cmp    %eax,%esi
f010167d:	75 19                	jne    f0101698 <mem_init+0x411>
f010167f:	68 34 64 10 f0       	push   $0xf0106434
f0101684:	68 36 5f 10 f0       	push   $0xf0105f36
f0101689:	68 1f 03 00 00       	push   $0x31f
f010168e:	68 10 5f 10 f0       	push   $0xf0105f10
f0101693:	e8 a8 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101698:	83 ec 0c             	sub    $0xc,%esp
f010169b:	6a 00                	push   $0x0
f010169d:	e8 78 f8 ff ff       	call   f0100f1a <page_alloc>
f01016a2:	83 c4 10             	add    $0x10,%esp
f01016a5:	85 c0                	test   %eax,%eax
f01016a7:	74 19                	je     f01016c2 <mem_init+0x43b>
f01016a9:	68 fe 60 10 f0       	push   $0xf01060fe
f01016ae:	68 36 5f 10 f0       	push   $0xf0105f36
f01016b3:	68 20 03 00 00       	push   $0x320
f01016b8:	68 10 5f 10 f0       	push   $0xf0105f10
f01016bd:	e8 7e e9 ff ff       	call   f0100040 <_panic>
f01016c2:	89 f0                	mov    %esi,%eax
f01016c4:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f01016ca:	c1 f8 03             	sar    $0x3,%eax
f01016cd:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016d0:	89 c2                	mov    %eax,%edx
f01016d2:	c1 ea 0c             	shr    $0xc,%edx
f01016d5:	3b 15 88 ae 22 f0    	cmp    0xf022ae88,%edx
f01016db:	72 12                	jb     f01016ef <mem_init+0x468>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016dd:	50                   	push   %eax
f01016de:	68 64 59 10 f0       	push   $0xf0105964
f01016e3:	6a 58                	push   $0x58
f01016e5:	68 1c 5f 10 f0       	push   $0xf0105f1c
f01016ea:	e8 51 e9 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01016ef:	83 ec 04             	sub    $0x4,%esp
f01016f2:	68 00 10 00 00       	push   $0x1000
f01016f7:	6a 01                	push   $0x1
f01016f9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016fe:	50                   	push   %eax
f01016ff:	e8 7f 35 00 00       	call   f0104c83 <memset>
	page_free(pp0);
f0101704:	89 34 24             	mov    %esi,(%esp)
f0101707:	e8 78 f8 ff ff       	call   f0100f84 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010170c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101713:	e8 02 f8 ff ff       	call   f0100f1a <page_alloc>
f0101718:	83 c4 10             	add    $0x10,%esp
f010171b:	85 c0                	test   %eax,%eax
f010171d:	75 19                	jne    f0101738 <mem_init+0x4b1>
f010171f:	68 0d 61 10 f0       	push   $0xf010610d
f0101724:	68 36 5f 10 f0       	push   $0xf0105f36
f0101729:	68 25 03 00 00       	push   $0x325
f010172e:	68 10 5f 10 f0       	push   $0xf0105f10
f0101733:	e8 08 e9 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101738:	39 c6                	cmp    %eax,%esi
f010173a:	74 19                	je     f0101755 <mem_init+0x4ce>
f010173c:	68 2b 61 10 f0       	push   $0xf010612b
f0101741:	68 36 5f 10 f0       	push   $0xf0105f36
f0101746:	68 26 03 00 00       	push   $0x326
f010174b:	68 10 5f 10 f0       	push   $0xf0105f10
f0101750:	e8 eb e8 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101755:	89 f0                	mov    %esi,%eax
f0101757:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f010175d:	c1 f8 03             	sar    $0x3,%eax
f0101760:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101763:	89 c2                	mov    %eax,%edx
f0101765:	c1 ea 0c             	shr    $0xc,%edx
f0101768:	3b 15 88 ae 22 f0    	cmp    0xf022ae88,%edx
f010176e:	72 12                	jb     f0101782 <mem_init+0x4fb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101770:	50                   	push   %eax
f0101771:	68 64 59 10 f0       	push   $0xf0105964
f0101776:	6a 58                	push   $0x58
f0101778:	68 1c 5f 10 f0       	push   $0xf0105f1c
f010177d:	e8 be e8 ff ff       	call   f0100040 <_panic>
f0101782:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101788:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010178e:	80 38 00             	cmpb   $0x0,(%eax)
f0101791:	74 19                	je     f01017ac <mem_init+0x525>
f0101793:	68 3b 61 10 f0       	push   $0xf010613b
f0101798:	68 36 5f 10 f0       	push   $0xf0105f36
f010179d:	68 29 03 00 00       	push   $0x329
f01017a2:	68 10 5f 10 f0       	push   $0xf0105f10
f01017a7:	e8 94 e8 ff ff       	call   f0100040 <_panic>
f01017ac:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01017af:	39 d0                	cmp    %edx,%eax
f01017b1:	75 db                	jne    f010178e <mem_init+0x507>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01017b3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01017b6:	a3 40 a2 22 f0       	mov    %eax,0xf022a240

	// free the pages we took
	page_free(pp0);
f01017bb:	83 ec 0c             	sub    $0xc,%esp
f01017be:	56                   	push   %esi
f01017bf:	e8 c0 f7 ff ff       	call   f0100f84 <page_free>
	page_free(pp1);
f01017c4:	89 3c 24             	mov    %edi,(%esp)
f01017c7:	e8 b8 f7 ff ff       	call   f0100f84 <page_free>
	page_free(pp2);
f01017cc:	83 c4 04             	add    $0x4,%esp
f01017cf:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017d2:	e8 ad f7 ff ff       	call   f0100f84 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017d7:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f01017dc:	83 c4 10             	add    $0x10,%esp
f01017df:	eb 05                	jmp    f01017e6 <mem_init+0x55f>
		--nfree;
f01017e1:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017e4:	8b 00                	mov    (%eax),%eax
f01017e6:	85 c0                	test   %eax,%eax
f01017e8:	75 f7                	jne    f01017e1 <mem_init+0x55a>
		--nfree;
	assert(nfree == 0);
f01017ea:	85 db                	test   %ebx,%ebx
f01017ec:	74 19                	je     f0101807 <mem_init+0x580>
f01017ee:	68 45 61 10 f0       	push   $0xf0106145
f01017f3:	68 36 5f 10 f0       	push   $0xf0105f36
f01017f8:	68 36 03 00 00       	push   $0x336
f01017fd:	68 10 5f 10 f0       	push   $0xf0105f10
f0101802:	e8 39 e8 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101807:	83 ec 0c             	sub    $0xc,%esp
f010180a:	68 54 64 10 f0       	push   $0xf0106454
f010180f:	e8 6a 1e 00 00       	call   f010367e <cprintf>
	// or page_insert
	page_init();

	check_page_free_list(1);
	check_page_alloc();
	cprintf("so far so good\n");
f0101814:	c7 04 24 50 61 10 f0 	movl   $0xf0106150,(%esp)
f010181b:	e8 5e 1e 00 00       	call   f010367e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101820:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101827:	e8 ee f6 ff ff       	call   f0100f1a <page_alloc>
f010182c:	89 c6                	mov    %eax,%esi
f010182e:	83 c4 10             	add    $0x10,%esp
f0101831:	85 c0                	test   %eax,%eax
f0101833:	75 19                	jne    f010184e <mem_init+0x5c7>
f0101835:	68 53 60 10 f0       	push   $0xf0106053
f010183a:	68 36 5f 10 f0       	push   $0xf0105f36
f010183f:	68 9c 03 00 00       	push   $0x39c
f0101844:	68 10 5f 10 f0       	push   $0xf0105f10
f0101849:	e8 f2 e7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010184e:	83 ec 0c             	sub    $0xc,%esp
f0101851:	6a 00                	push   $0x0
f0101853:	e8 c2 f6 ff ff       	call   f0100f1a <page_alloc>
f0101858:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010185b:	83 c4 10             	add    $0x10,%esp
f010185e:	85 c0                	test   %eax,%eax
f0101860:	75 19                	jne    f010187b <mem_init+0x5f4>
f0101862:	68 69 60 10 f0       	push   $0xf0106069
f0101867:	68 36 5f 10 f0       	push   $0xf0105f36
f010186c:	68 9d 03 00 00       	push   $0x39d
f0101871:	68 10 5f 10 f0       	push   $0xf0105f10
f0101876:	e8 c5 e7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010187b:	83 ec 0c             	sub    $0xc,%esp
f010187e:	6a 00                	push   $0x0
f0101880:	e8 95 f6 ff ff       	call   f0100f1a <page_alloc>
f0101885:	89 c3                	mov    %eax,%ebx
f0101887:	83 c4 10             	add    $0x10,%esp
f010188a:	85 c0                	test   %eax,%eax
f010188c:	75 19                	jne    f01018a7 <mem_init+0x620>
f010188e:	68 7f 60 10 f0       	push   $0xf010607f
f0101893:	68 36 5f 10 f0       	push   $0xf0105f36
f0101898:	68 9e 03 00 00       	push   $0x39e
f010189d:	68 10 5f 10 f0       	push   $0xf0105f10
f01018a2:	e8 99 e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018a7:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01018aa:	75 19                	jne    f01018c5 <mem_init+0x63e>
f01018ac:	68 95 60 10 f0       	push   $0xf0106095
f01018b1:	68 36 5f 10 f0       	push   $0xf0105f36
f01018b6:	68 a1 03 00 00       	push   $0x3a1
f01018bb:	68 10 5f 10 f0       	push   $0xf0105f10
f01018c0:	e8 7b e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01018c5:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01018c8:	74 04                	je     f01018ce <mem_init+0x647>
f01018ca:	39 c6                	cmp    %eax,%esi
f01018cc:	75 19                	jne    f01018e7 <mem_init+0x660>
f01018ce:	68 34 64 10 f0       	push   $0xf0106434
f01018d3:	68 36 5f 10 f0       	push   $0xf0105f36
f01018d8:	68 a2 03 00 00       	push   $0x3a2
f01018dd:	68 10 5f 10 f0       	push   $0xf0105f10
f01018e2:	e8 59 e7 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018e7:	a1 40 a2 22 f0       	mov    0xf022a240,%eax
f01018ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01018ef:	c7 05 40 a2 22 f0 00 	movl   $0x0,0xf022a240
f01018f6:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018f9:	83 ec 0c             	sub    $0xc,%esp
f01018fc:	6a 00                	push   $0x0
f01018fe:	e8 17 f6 ff ff       	call   f0100f1a <page_alloc>
f0101903:	83 c4 10             	add    $0x10,%esp
f0101906:	85 c0                	test   %eax,%eax
f0101908:	74 19                	je     f0101923 <mem_init+0x69c>
f010190a:	68 fe 60 10 f0       	push   $0xf01060fe
f010190f:	68 36 5f 10 f0       	push   $0xf0105f36
f0101914:	68 a9 03 00 00       	push   $0x3a9
f0101919:	68 10 5f 10 f0       	push   $0xf0105f10
f010191e:	e8 1d e7 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101923:	83 ec 04             	sub    $0x4,%esp
f0101926:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101929:	50                   	push   %eax
f010192a:	6a 00                	push   $0x0
f010192c:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f0101932:	e8 9e f7 ff ff       	call   f01010d5 <page_lookup>
f0101937:	83 c4 10             	add    $0x10,%esp
f010193a:	85 c0                	test   %eax,%eax
f010193c:	74 19                	je     f0101957 <mem_init+0x6d0>
f010193e:	68 74 64 10 f0       	push   $0xf0106474
f0101943:	68 36 5f 10 f0       	push   $0xf0105f36
f0101948:	68 ac 03 00 00       	push   $0x3ac
f010194d:	68 10 5f 10 f0       	push   $0xf0105f10
f0101952:	e8 e9 e6 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101957:	6a 02                	push   $0x2
f0101959:	6a 00                	push   $0x0
f010195b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010195e:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f0101964:	e8 55 f8 ff ff       	call   f01011be <page_insert>
f0101969:	83 c4 10             	add    $0x10,%esp
f010196c:	85 c0                	test   %eax,%eax
f010196e:	78 19                	js     f0101989 <mem_init+0x702>
f0101970:	68 ac 64 10 f0       	push   $0xf01064ac
f0101975:	68 36 5f 10 f0       	push   $0xf0105f36
f010197a:	68 af 03 00 00       	push   $0x3af
f010197f:	68 10 5f 10 f0       	push   $0xf0105f10
f0101984:	e8 b7 e6 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101989:	83 ec 0c             	sub    $0xc,%esp
f010198c:	56                   	push   %esi
f010198d:	e8 f2 f5 ff ff       	call   f0100f84 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101992:	6a 02                	push   $0x2
f0101994:	6a 00                	push   $0x0
f0101996:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101999:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f010199f:	e8 1a f8 ff ff       	call   f01011be <page_insert>
f01019a4:	83 c4 20             	add    $0x20,%esp
f01019a7:	85 c0                	test   %eax,%eax
f01019a9:	74 19                	je     f01019c4 <mem_init+0x73d>
f01019ab:	68 dc 64 10 f0       	push   $0xf01064dc
f01019b0:	68 36 5f 10 f0       	push   $0xf0105f36
f01019b5:	68 b3 03 00 00       	push   $0x3b3
f01019ba:	68 10 5f 10 f0       	push   $0xf0105f10
f01019bf:	e8 7c e6 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019c4:	8b 3d 8c ae 22 f0    	mov    0xf022ae8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019ca:	a1 90 ae 22 f0       	mov    0xf022ae90,%eax
f01019cf:	89 c1                	mov    %eax,%ecx
f01019d1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01019d4:	8b 17                	mov    (%edi),%edx
f01019d6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019dc:	89 f0                	mov    %esi,%eax
f01019de:	29 c8                	sub    %ecx,%eax
f01019e0:	c1 f8 03             	sar    $0x3,%eax
f01019e3:	c1 e0 0c             	shl    $0xc,%eax
f01019e6:	39 c2                	cmp    %eax,%edx
f01019e8:	74 19                	je     f0101a03 <mem_init+0x77c>
f01019ea:	68 0c 65 10 f0       	push   $0xf010650c
f01019ef:	68 36 5f 10 f0       	push   $0xf0105f36
f01019f4:	68 b4 03 00 00       	push   $0x3b4
f01019f9:	68 10 5f 10 f0       	push   $0xf0105f10
f01019fe:	e8 3d e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a03:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a08:	89 f8                	mov    %edi,%eax
f0101a0a:	e8 0f f1 ff ff       	call   f0100b1e <check_va2pa>
f0101a0f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101a12:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101a15:	c1 fa 03             	sar    $0x3,%edx
f0101a18:	c1 e2 0c             	shl    $0xc,%edx
f0101a1b:	39 d0                	cmp    %edx,%eax
f0101a1d:	74 19                	je     f0101a38 <mem_init+0x7b1>
f0101a1f:	68 34 65 10 f0       	push   $0xf0106534
f0101a24:	68 36 5f 10 f0       	push   $0xf0105f36
f0101a29:	68 b5 03 00 00       	push   $0x3b5
f0101a2e:	68 10 5f 10 f0       	push   $0xf0105f10
f0101a33:	e8 08 e6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101a38:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a3b:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a40:	74 19                	je     f0101a5b <mem_init+0x7d4>
f0101a42:	68 60 61 10 f0       	push   $0xf0106160
f0101a47:	68 36 5f 10 f0       	push   $0xf0105f36
f0101a4c:	68 b6 03 00 00       	push   $0x3b6
f0101a51:	68 10 5f 10 f0       	push   $0xf0105f10
f0101a56:	e8 e5 e5 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101a5b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a60:	74 19                	je     f0101a7b <mem_init+0x7f4>
f0101a62:	68 71 61 10 f0       	push   $0xf0106171
f0101a67:	68 36 5f 10 f0       	push   $0xf0105f36
f0101a6c:	68 b7 03 00 00       	push   $0x3b7
f0101a71:	68 10 5f 10 f0       	push   $0xf0105f10
f0101a76:	e8 c5 e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a7b:	6a 02                	push   $0x2
f0101a7d:	68 00 10 00 00       	push   $0x1000
f0101a82:	53                   	push   %ebx
f0101a83:	57                   	push   %edi
f0101a84:	e8 35 f7 ff ff       	call   f01011be <page_insert>
f0101a89:	83 c4 10             	add    $0x10,%esp
f0101a8c:	85 c0                	test   %eax,%eax
f0101a8e:	74 19                	je     f0101aa9 <mem_init+0x822>
f0101a90:	68 64 65 10 f0       	push   $0xf0106564
f0101a95:	68 36 5f 10 f0       	push   $0xf0105f36
f0101a9a:	68 ba 03 00 00       	push   $0x3ba
f0101a9f:	68 10 5f 10 f0       	push   $0xf0105f10
f0101aa4:	e8 97 e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101aa9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aae:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0101ab3:	e8 66 f0 ff ff       	call   f0100b1e <check_va2pa>
f0101ab8:	89 da                	mov    %ebx,%edx
f0101aba:	2b 15 90 ae 22 f0    	sub    0xf022ae90,%edx
f0101ac0:	c1 fa 03             	sar    $0x3,%edx
f0101ac3:	c1 e2 0c             	shl    $0xc,%edx
f0101ac6:	39 d0                	cmp    %edx,%eax
f0101ac8:	74 19                	je     f0101ae3 <mem_init+0x85c>
f0101aca:	68 a0 65 10 f0       	push   $0xf01065a0
f0101acf:	68 36 5f 10 f0       	push   $0xf0105f36
f0101ad4:	68 bb 03 00 00       	push   $0x3bb
f0101ad9:	68 10 5f 10 f0       	push   $0xf0105f10
f0101ade:	e8 5d e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ae3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ae8:	74 19                	je     f0101b03 <mem_init+0x87c>
f0101aea:	68 82 61 10 f0       	push   $0xf0106182
f0101aef:	68 36 5f 10 f0       	push   $0xf0105f36
f0101af4:	68 bc 03 00 00       	push   $0x3bc
f0101af9:	68 10 5f 10 f0       	push   $0xf0105f10
f0101afe:	e8 3d e5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b03:	83 ec 0c             	sub    $0xc,%esp
f0101b06:	6a 00                	push   $0x0
f0101b08:	e8 0d f4 ff ff       	call   f0100f1a <page_alloc>
f0101b0d:	83 c4 10             	add    $0x10,%esp
f0101b10:	85 c0                	test   %eax,%eax
f0101b12:	74 19                	je     f0101b2d <mem_init+0x8a6>
f0101b14:	68 fe 60 10 f0       	push   $0xf01060fe
f0101b19:	68 36 5f 10 f0       	push   $0xf0105f36
f0101b1e:	68 bf 03 00 00       	push   $0x3bf
f0101b23:	68 10 5f 10 f0       	push   $0xf0105f10
f0101b28:	e8 13 e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b2d:	6a 02                	push   $0x2
f0101b2f:	68 00 10 00 00       	push   $0x1000
f0101b34:	53                   	push   %ebx
f0101b35:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f0101b3b:	e8 7e f6 ff ff       	call   f01011be <page_insert>
f0101b40:	83 c4 10             	add    $0x10,%esp
f0101b43:	85 c0                	test   %eax,%eax
f0101b45:	74 19                	je     f0101b60 <mem_init+0x8d9>
f0101b47:	68 64 65 10 f0       	push   $0xf0106564
f0101b4c:	68 36 5f 10 f0       	push   $0xf0105f36
f0101b51:	68 c2 03 00 00       	push   $0x3c2
f0101b56:	68 10 5f 10 f0       	push   $0xf0105f10
f0101b5b:	e8 e0 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b60:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b65:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0101b6a:	e8 af ef ff ff       	call   f0100b1e <check_va2pa>
f0101b6f:	89 da                	mov    %ebx,%edx
f0101b71:	2b 15 90 ae 22 f0    	sub    0xf022ae90,%edx
f0101b77:	c1 fa 03             	sar    $0x3,%edx
f0101b7a:	c1 e2 0c             	shl    $0xc,%edx
f0101b7d:	39 d0                	cmp    %edx,%eax
f0101b7f:	74 19                	je     f0101b9a <mem_init+0x913>
f0101b81:	68 a0 65 10 f0       	push   $0xf01065a0
f0101b86:	68 36 5f 10 f0       	push   $0xf0105f36
f0101b8b:	68 c3 03 00 00       	push   $0x3c3
f0101b90:	68 10 5f 10 f0       	push   $0xf0105f10
f0101b95:	e8 a6 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101b9a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b9f:	74 19                	je     f0101bba <mem_init+0x933>
f0101ba1:	68 82 61 10 f0       	push   $0xf0106182
f0101ba6:	68 36 5f 10 f0       	push   $0xf0105f36
f0101bab:	68 c4 03 00 00       	push   $0x3c4
f0101bb0:	68 10 5f 10 f0       	push   $0xf0105f10
f0101bb5:	e8 86 e4 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101bba:	83 ec 0c             	sub    $0xc,%esp
f0101bbd:	6a 00                	push   $0x0
f0101bbf:	e8 56 f3 ff ff       	call   f0100f1a <page_alloc>
f0101bc4:	83 c4 10             	add    $0x10,%esp
f0101bc7:	85 c0                	test   %eax,%eax
f0101bc9:	74 19                	je     f0101be4 <mem_init+0x95d>
f0101bcb:	68 fe 60 10 f0       	push   $0xf01060fe
f0101bd0:	68 36 5f 10 f0       	push   $0xf0105f36
f0101bd5:	68 c8 03 00 00       	push   $0x3c8
f0101bda:	68 10 5f 10 f0       	push   $0xf0105f10
f0101bdf:	e8 5c e4 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101be4:	8b 15 8c ae 22 f0    	mov    0xf022ae8c,%edx
f0101bea:	8b 02                	mov    (%edx),%eax
f0101bec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101bf1:	89 c1                	mov    %eax,%ecx
f0101bf3:	c1 e9 0c             	shr    $0xc,%ecx
f0101bf6:	3b 0d 88 ae 22 f0    	cmp    0xf022ae88,%ecx
f0101bfc:	72 15                	jb     f0101c13 <mem_init+0x98c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101bfe:	50                   	push   %eax
f0101bff:	68 64 59 10 f0       	push   $0xf0105964
f0101c04:	68 cb 03 00 00       	push   $0x3cb
f0101c09:	68 10 5f 10 f0       	push   $0xf0105f10
f0101c0e:	e8 2d e4 ff ff       	call   f0100040 <_panic>
f0101c13:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c18:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c1b:	83 ec 04             	sub    $0x4,%esp
f0101c1e:	6a 00                	push   $0x0
f0101c20:	68 00 10 00 00       	push   $0x1000
f0101c25:	52                   	push   %edx
f0101c26:	e8 8f f3 ff ff       	call   f0100fba <pgdir_walk>
f0101c2b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101c2e:	8d 51 04             	lea    0x4(%ecx),%edx
f0101c31:	83 c4 10             	add    $0x10,%esp
f0101c34:	39 d0                	cmp    %edx,%eax
f0101c36:	74 19                	je     f0101c51 <mem_init+0x9ca>
f0101c38:	68 d0 65 10 f0       	push   $0xf01065d0
f0101c3d:	68 36 5f 10 f0       	push   $0xf0105f36
f0101c42:	68 cc 03 00 00       	push   $0x3cc
f0101c47:	68 10 5f 10 f0       	push   $0xf0105f10
f0101c4c:	e8 ef e3 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101c51:	6a 06                	push   $0x6
f0101c53:	68 00 10 00 00       	push   $0x1000
f0101c58:	53                   	push   %ebx
f0101c59:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f0101c5f:	e8 5a f5 ff ff       	call   f01011be <page_insert>
f0101c64:	83 c4 10             	add    $0x10,%esp
f0101c67:	85 c0                	test   %eax,%eax
f0101c69:	74 19                	je     f0101c84 <mem_init+0x9fd>
f0101c6b:	68 10 66 10 f0       	push   $0xf0106610
f0101c70:	68 36 5f 10 f0       	push   $0xf0105f36
f0101c75:	68 cf 03 00 00       	push   $0x3cf
f0101c7a:	68 10 5f 10 f0       	push   $0xf0105f10
f0101c7f:	e8 bc e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c84:	8b 3d 8c ae 22 f0    	mov    0xf022ae8c,%edi
f0101c8a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c8f:	89 f8                	mov    %edi,%eax
f0101c91:	e8 88 ee ff ff       	call   f0100b1e <check_va2pa>
f0101c96:	89 da                	mov    %ebx,%edx
f0101c98:	2b 15 90 ae 22 f0    	sub    0xf022ae90,%edx
f0101c9e:	c1 fa 03             	sar    $0x3,%edx
f0101ca1:	c1 e2 0c             	shl    $0xc,%edx
f0101ca4:	39 d0                	cmp    %edx,%eax
f0101ca6:	74 19                	je     f0101cc1 <mem_init+0xa3a>
f0101ca8:	68 a0 65 10 f0       	push   $0xf01065a0
f0101cad:	68 36 5f 10 f0       	push   $0xf0105f36
f0101cb2:	68 d0 03 00 00       	push   $0x3d0
f0101cb7:	68 10 5f 10 f0       	push   $0xf0105f10
f0101cbc:	e8 7f e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101cc1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101cc6:	74 19                	je     f0101ce1 <mem_init+0xa5a>
f0101cc8:	68 82 61 10 f0       	push   $0xf0106182
f0101ccd:	68 36 5f 10 f0       	push   $0xf0105f36
f0101cd2:	68 d1 03 00 00       	push   $0x3d1
f0101cd7:	68 10 5f 10 f0       	push   $0xf0105f10
f0101cdc:	e8 5f e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101ce1:	83 ec 04             	sub    $0x4,%esp
f0101ce4:	6a 00                	push   $0x0
f0101ce6:	68 00 10 00 00       	push   $0x1000
f0101ceb:	57                   	push   %edi
f0101cec:	e8 c9 f2 ff ff       	call   f0100fba <pgdir_walk>
f0101cf1:	83 c4 10             	add    $0x10,%esp
f0101cf4:	f6 00 04             	testb  $0x4,(%eax)
f0101cf7:	75 19                	jne    f0101d12 <mem_init+0xa8b>
f0101cf9:	68 50 66 10 f0       	push   $0xf0106650
f0101cfe:	68 36 5f 10 f0       	push   $0xf0105f36
f0101d03:	68 d2 03 00 00       	push   $0x3d2
f0101d08:	68 10 5f 10 f0       	push   $0xf0105f10
f0101d0d:	e8 2e e3 ff ff       	call   f0100040 <_panic>
	cprintf("pp2 %x\n", pp2);
f0101d12:	83 ec 08             	sub    $0x8,%esp
f0101d15:	53                   	push   %ebx
f0101d16:	68 93 61 10 f0       	push   $0xf0106193
f0101d1b:	e8 5e 19 00 00       	call   f010367e <cprintf>
	cprintf("kern_pgdir %x\n", kern_pgdir);
f0101d20:	83 c4 08             	add    $0x8,%esp
f0101d23:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f0101d29:	68 9b 61 10 f0       	push   $0xf010619b
f0101d2e:	e8 4b 19 00 00       	call   f010367e <cprintf>
	cprintf("kern_pgdir[0] is %x\n", kern_pgdir[0]);
f0101d33:	83 c4 08             	add    $0x8,%esp
f0101d36:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0101d3b:	ff 30                	pushl  (%eax)
f0101d3d:	68 aa 61 10 f0       	push   $0xf01061aa
f0101d42:	e8 37 19 00 00       	call   f010367e <cprintf>
	assert(kern_pgdir[0] & PTE_U);
f0101d47:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0101d4c:	83 c4 10             	add    $0x10,%esp
f0101d4f:	f6 00 04             	testb  $0x4,(%eax)
f0101d52:	75 19                	jne    f0101d6d <mem_init+0xae6>
f0101d54:	68 bf 61 10 f0       	push   $0xf01061bf
f0101d59:	68 36 5f 10 f0       	push   $0xf0105f36
f0101d5e:	68 d6 03 00 00       	push   $0x3d6
f0101d63:	68 10 5f 10 f0       	push   $0xf0105f10
f0101d68:	e8 d3 e2 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d6d:	6a 02                	push   $0x2
f0101d6f:	68 00 10 00 00       	push   $0x1000
f0101d74:	53                   	push   %ebx
f0101d75:	50                   	push   %eax
f0101d76:	e8 43 f4 ff ff       	call   f01011be <page_insert>
f0101d7b:	83 c4 10             	add    $0x10,%esp
f0101d7e:	85 c0                	test   %eax,%eax
f0101d80:	74 19                	je     f0101d9b <mem_init+0xb14>
f0101d82:	68 64 65 10 f0       	push   $0xf0106564
f0101d87:	68 36 5f 10 f0       	push   $0xf0105f36
f0101d8c:	68 d9 03 00 00       	push   $0x3d9
f0101d91:	68 10 5f 10 f0       	push   $0xf0105f10
f0101d96:	e8 a5 e2 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d9b:	83 ec 04             	sub    $0x4,%esp
f0101d9e:	6a 00                	push   $0x0
f0101da0:	68 00 10 00 00       	push   $0x1000
f0101da5:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f0101dab:	e8 0a f2 ff ff       	call   f0100fba <pgdir_walk>
f0101db0:	83 c4 10             	add    $0x10,%esp
f0101db3:	f6 00 02             	testb  $0x2,(%eax)
f0101db6:	75 19                	jne    f0101dd1 <mem_init+0xb4a>
f0101db8:	68 84 66 10 f0       	push   $0xf0106684
f0101dbd:	68 36 5f 10 f0       	push   $0xf0105f36
f0101dc2:	68 da 03 00 00       	push   $0x3da
f0101dc7:	68 10 5f 10 f0       	push   $0xf0105f10
f0101dcc:	e8 6f e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101dd1:	83 ec 04             	sub    $0x4,%esp
f0101dd4:	6a 00                	push   $0x0
f0101dd6:	68 00 10 00 00       	push   $0x1000
f0101ddb:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f0101de1:	e8 d4 f1 ff ff       	call   f0100fba <pgdir_walk>
f0101de6:	83 c4 10             	add    $0x10,%esp
f0101de9:	f6 00 04             	testb  $0x4,(%eax)
f0101dec:	74 19                	je     f0101e07 <mem_init+0xb80>
f0101dee:	68 b8 66 10 f0       	push   $0xf01066b8
f0101df3:	68 36 5f 10 f0       	push   $0xf0105f36
f0101df8:	68 db 03 00 00       	push   $0x3db
f0101dfd:	68 10 5f 10 f0       	push   $0xf0105f10
f0101e02:	e8 39 e2 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101e07:	6a 02                	push   $0x2
f0101e09:	68 00 00 40 00       	push   $0x400000
f0101e0e:	56                   	push   %esi
f0101e0f:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f0101e15:	e8 a4 f3 ff ff       	call   f01011be <page_insert>
f0101e1a:	83 c4 10             	add    $0x10,%esp
f0101e1d:	85 c0                	test   %eax,%eax
f0101e1f:	78 19                	js     f0101e3a <mem_init+0xbb3>
f0101e21:	68 f0 66 10 f0       	push   $0xf01066f0
f0101e26:	68 36 5f 10 f0       	push   $0xf0105f36
f0101e2b:	68 de 03 00 00       	push   $0x3de
f0101e30:	68 10 5f 10 f0       	push   $0xf0105f10
f0101e35:	e8 06 e2 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101e3a:	6a 02                	push   $0x2
f0101e3c:	68 00 10 00 00       	push   $0x1000
f0101e41:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101e44:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f0101e4a:	e8 6f f3 ff ff       	call   f01011be <page_insert>
f0101e4f:	83 c4 10             	add    $0x10,%esp
f0101e52:	85 c0                	test   %eax,%eax
f0101e54:	74 19                	je     f0101e6f <mem_init+0xbe8>
f0101e56:	68 28 67 10 f0       	push   $0xf0106728
f0101e5b:	68 36 5f 10 f0       	push   $0xf0105f36
f0101e60:	68 e1 03 00 00       	push   $0x3e1
f0101e65:	68 10 5f 10 f0       	push   $0xf0105f10
f0101e6a:	e8 d1 e1 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e6f:	83 ec 04             	sub    $0x4,%esp
f0101e72:	6a 00                	push   $0x0
f0101e74:	68 00 10 00 00       	push   $0x1000
f0101e79:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f0101e7f:	e8 36 f1 ff ff       	call   f0100fba <pgdir_walk>
f0101e84:	83 c4 10             	add    $0x10,%esp
f0101e87:	f6 00 04             	testb  $0x4,(%eax)
f0101e8a:	74 19                	je     f0101ea5 <mem_init+0xc1e>
f0101e8c:	68 b8 66 10 f0       	push   $0xf01066b8
f0101e91:	68 36 5f 10 f0       	push   $0xf0105f36
f0101e96:	68 e2 03 00 00       	push   $0x3e2
f0101e9b:	68 10 5f 10 f0       	push   $0xf0105f10
f0101ea0:	e8 9b e1 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101ea5:	8b 3d 8c ae 22 f0    	mov    0xf022ae8c,%edi
f0101eab:	ba 00 00 00 00       	mov    $0x0,%edx
f0101eb0:	89 f8                	mov    %edi,%eax
f0101eb2:	e8 67 ec ff ff       	call   f0100b1e <check_va2pa>
f0101eb7:	89 c1                	mov    %eax,%ecx
f0101eb9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101ebc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ebf:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f0101ec5:	c1 f8 03             	sar    $0x3,%eax
f0101ec8:	c1 e0 0c             	shl    $0xc,%eax
f0101ecb:	39 c1                	cmp    %eax,%ecx
f0101ecd:	74 19                	je     f0101ee8 <mem_init+0xc61>
f0101ecf:	68 64 67 10 f0       	push   $0xf0106764
f0101ed4:	68 36 5f 10 f0       	push   $0xf0105f36
f0101ed9:	68 e5 03 00 00       	push   $0x3e5
f0101ede:	68 10 5f 10 f0       	push   $0xf0105f10
f0101ee3:	e8 58 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ee8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101eed:	89 f8                	mov    %edi,%eax
f0101eef:	e8 2a ec ff ff       	call   f0100b1e <check_va2pa>
f0101ef4:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101ef7:	74 19                	je     f0101f12 <mem_init+0xc8b>
f0101ef9:	68 90 67 10 f0       	push   $0xf0106790
f0101efe:	68 36 5f 10 f0       	push   $0xf0105f36
f0101f03:	68 e6 03 00 00       	push   $0x3e6
f0101f08:	68 10 5f 10 f0       	push   $0xf0105f10
f0101f0d:	e8 2e e1 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101f12:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f15:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0101f1a:	74 19                	je     f0101f35 <mem_init+0xcae>
f0101f1c:	68 d5 61 10 f0       	push   $0xf01061d5
f0101f21:	68 36 5f 10 f0       	push   $0xf0105f36
f0101f26:	68 e8 03 00 00       	push   $0x3e8
f0101f2b:	68 10 5f 10 f0       	push   $0xf0105f10
f0101f30:	e8 0b e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101f35:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f3a:	74 19                	je     f0101f55 <mem_init+0xcce>
f0101f3c:	68 e6 61 10 f0       	push   $0xf01061e6
f0101f41:	68 36 5f 10 f0       	push   $0xf0105f36
f0101f46:	68 e9 03 00 00       	push   $0x3e9
f0101f4b:	68 10 5f 10 f0       	push   $0xf0105f10
f0101f50:	e8 eb e0 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101f55:	83 ec 0c             	sub    $0xc,%esp
f0101f58:	6a 00                	push   $0x0
f0101f5a:	e8 bb ef ff ff       	call   f0100f1a <page_alloc>
f0101f5f:	83 c4 10             	add    $0x10,%esp
f0101f62:	85 c0                	test   %eax,%eax
f0101f64:	74 04                	je     f0101f6a <mem_init+0xce3>
f0101f66:	39 c3                	cmp    %eax,%ebx
f0101f68:	74 19                	je     f0101f83 <mem_init+0xcfc>
f0101f6a:	68 c0 67 10 f0       	push   $0xf01067c0
f0101f6f:	68 36 5f 10 f0       	push   $0xf0105f36
f0101f74:	68 ec 03 00 00       	push   $0x3ec
f0101f79:	68 10 5f 10 f0       	push   $0xf0105f10
f0101f7e:	e8 bd e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101f83:	83 ec 08             	sub    $0x8,%esp
f0101f86:	6a 00                	push   $0x0
f0101f88:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f0101f8e:	e8 dd f1 ff ff       	call   f0101170 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f93:	8b 3d 8c ae 22 f0    	mov    0xf022ae8c,%edi
f0101f99:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f9e:	89 f8                	mov    %edi,%eax
f0101fa0:	e8 79 eb ff ff       	call   f0100b1e <check_va2pa>
f0101fa5:	83 c4 10             	add    $0x10,%esp
f0101fa8:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fab:	74 19                	je     f0101fc6 <mem_init+0xd3f>
f0101fad:	68 e4 67 10 f0       	push   $0xf01067e4
f0101fb2:	68 36 5f 10 f0       	push   $0xf0105f36
f0101fb7:	68 f0 03 00 00       	push   $0x3f0
f0101fbc:	68 10 5f 10 f0       	push   $0xf0105f10
f0101fc1:	e8 7a e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101fc6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fcb:	89 f8                	mov    %edi,%eax
f0101fcd:	e8 4c eb ff ff       	call   f0100b1e <check_va2pa>
f0101fd2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101fd5:	2b 15 90 ae 22 f0    	sub    0xf022ae90,%edx
f0101fdb:	c1 fa 03             	sar    $0x3,%edx
f0101fde:	c1 e2 0c             	shl    $0xc,%edx
f0101fe1:	39 d0                	cmp    %edx,%eax
f0101fe3:	74 19                	je     f0101ffe <mem_init+0xd77>
f0101fe5:	68 90 67 10 f0       	push   $0xf0106790
f0101fea:	68 36 5f 10 f0       	push   $0xf0105f36
f0101fef:	68 f1 03 00 00       	push   $0x3f1
f0101ff4:	68 10 5f 10 f0       	push   $0xf0105f10
f0101ff9:	e8 42 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101ffe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102001:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102006:	74 19                	je     f0102021 <mem_init+0xd9a>
f0102008:	68 60 61 10 f0       	push   $0xf0106160
f010200d:	68 36 5f 10 f0       	push   $0xf0105f36
f0102012:	68 f2 03 00 00       	push   $0x3f2
f0102017:	68 10 5f 10 f0       	push   $0xf0105f10
f010201c:	e8 1f e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102021:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102026:	74 19                	je     f0102041 <mem_init+0xdba>
f0102028:	68 e6 61 10 f0       	push   $0xf01061e6
f010202d:	68 36 5f 10 f0       	push   $0xf0105f36
f0102032:	68 f3 03 00 00       	push   $0x3f3
f0102037:	68 10 5f 10 f0       	push   $0xf0105f10
f010203c:	e8 ff df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102041:	83 ec 08             	sub    $0x8,%esp
f0102044:	68 00 10 00 00       	push   $0x1000
f0102049:	57                   	push   %edi
f010204a:	e8 21 f1 ff ff       	call   f0101170 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010204f:	8b 3d 8c ae 22 f0    	mov    0xf022ae8c,%edi
f0102055:	ba 00 00 00 00       	mov    $0x0,%edx
f010205a:	89 f8                	mov    %edi,%eax
f010205c:	e8 bd ea ff ff       	call   f0100b1e <check_va2pa>
f0102061:	83 c4 10             	add    $0x10,%esp
f0102064:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102067:	74 19                	je     f0102082 <mem_init+0xdfb>
f0102069:	68 e4 67 10 f0       	push   $0xf01067e4
f010206e:	68 36 5f 10 f0       	push   $0xf0105f36
f0102073:	68 f7 03 00 00       	push   $0x3f7
f0102078:	68 10 5f 10 f0       	push   $0xf0105f10
f010207d:	e8 be df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102082:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102087:	89 f8                	mov    %edi,%eax
f0102089:	e8 90 ea ff ff       	call   f0100b1e <check_va2pa>
f010208e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102091:	74 19                	je     f01020ac <mem_init+0xe25>
f0102093:	68 08 68 10 f0       	push   $0xf0106808
f0102098:	68 36 5f 10 f0       	push   $0xf0105f36
f010209d:	68 f8 03 00 00       	push   $0x3f8
f01020a2:	68 10 5f 10 f0       	push   $0xf0105f10
f01020a7:	e8 94 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01020ac:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020af:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01020b4:	74 19                	je     f01020cf <mem_init+0xe48>
f01020b6:	68 f7 61 10 f0       	push   $0xf01061f7
f01020bb:	68 36 5f 10 f0       	push   $0xf0105f36
f01020c0:	68 f9 03 00 00       	push   $0x3f9
f01020c5:	68 10 5f 10 f0       	push   $0xf0105f10
f01020ca:	e8 71 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01020cf:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020d4:	74 19                	je     f01020ef <mem_init+0xe68>
f01020d6:	68 e6 61 10 f0       	push   $0xf01061e6
f01020db:	68 36 5f 10 f0       	push   $0xf0105f36
f01020e0:	68 fa 03 00 00       	push   $0x3fa
f01020e5:	68 10 5f 10 f0       	push   $0xf0105f10
f01020ea:	e8 51 df ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01020ef:	83 ec 0c             	sub    $0xc,%esp
f01020f2:	6a 00                	push   $0x0
f01020f4:	e8 21 ee ff ff       	call   f0100f1a <page_alloc>
f01020f9:	83 c4 10             	add    $0x10,%esp
f01020fc:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01020ff:	75 04                	jne    f0102105 <mem_init+0xe7e>
f0102101:	85 c0                	test   %eax,%eax
f0102103:	75 19                	jne    f010211e <mem_init+0xe97>
f0102105:	68 30 68 10 f0       	push   $0xf0106830
f010210a:	68 36 5f 10 f0       	push   $0xf0105f36
f010210f:	68 fd 03 00 00       	push   $0x3fd
f0102114:	68 10 5f 10 f0       	push   $0xf0105f10
f0102119:	e8 22 df ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010211e:	83 ec 0c             	sub    $0xc,%esp
f0102121:	6a 00                	push   $0x0
f0102123:	e8 f2 ed ff ff       	call   f0100f1a <page_alloc>
f0102128:	83 c4 10             	add    $0x10,%esp
f010212b:	85 c0                	test   %eax,%eax
f010212d:	74 19                	je     f0102148 <mem_init+0xec1>
f010212f:	68 fe 60 10 f0       	push   $0xf01060fe
f0102134:	68 36 5f 10 f0       	push   $0xf0105f36
f0102139:	68 00 04 00 00       	push   $0x400
f010213e:	68 10 5f 10 f0       	push   $0xf0105f10
f0102143:	e8 f8 de ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102148:	8b 0d 8c ae 22 f0    	mov    0xf022ae8c,%ecx
f010214e:	8b 11                	mov    (%ecx),%edx
f0102150:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102156:	89 f0                	mov    %esi,%eax
f0102158:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f010215e:	c1 f8 03             	sar    $0x3,%eax
f0102161:	c1 e0 0c             	shl    $0xc,%eax
f0102164:	39 c2                	cmp    %eax,%edx
f0102166:	74 19                	je     f0102181 <mem_init+0xefa>
f0102168:	68 0c 65 10 f0       	push   $0xf010650c
f010216d:	68 36 5f 10 f0       	push   $0xf0105f36
f0102172:	68 03 04 00 00       	push   $0x403
f0102177:	68 10 5f 10 f0       	push   $0xf0105f10
f010217c:	e8 bf de ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102181:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102187:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010218c:	74 19                	je     f01021a7 <mem_init+0xf20>
f010218e:	68 71 61 10 f0       	push   $0xf0106171
f0102193:	68 36 5f 10 f0       	push   $0xf0105f36
f0102198:	68 05 04 00 00       	push   $0x405
f010219d:	68 10 5f 10 f0       	push   $0xf0105f10
f01021a2:	e8 99 de ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01021a7:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01021ad:	83 ec 0c             	sub    $0xc,%esp
f01021b0:	56                   	push   %esi
f01021b1:	e8 ce ed ff ff       	call   f0100f84 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01021b6:	83 c4 0c             	add    $0xc,%esp
f01021b9:	6a 01                	push   $0x1
f01021bb:	68 00 10 40 00       	push   $0x401000
f01021c0:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f01021c6:	e8 ef ed ff ff       	call   f0100fba <pgdir_walk>
f01021cb:	89 c7                	mov    %eax,%edi
f01021cd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01021d0:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f01021d5:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01021d8:	8b 40 04             	mov    0x4(%eax),%eax
f01021db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021e0:	8b 0d 88 ae 22 f0    	mov    0xf022ae88,%ecx
f01021e6:	89 c2                	mov    %eax,%edx
f01021e8:	c1 ea 0c             	shr    $0xc,%edx
f01021eb:	83 c4 10             	add    $0x10,%esp
f01021ee:	39 ca                	cmp    %ecx,%edx
f01021f0:	72 15                	jb     f0102207 <mem_init+0xf80>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021f2:	50                   	push   %eax
f01021f3:	68 64 59 10 f0       	push   $0xf0105964
f01021f8:	68 0c 04 00 00       	push   $0x40c
f01021fd:	68 10 5f 10 f0       	push   $0xf0105f10
f0102202:	e8 39 de ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102207:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010220c:	39 c7                	cmp    %eax,%edi
f010220e:	74 19                	je     f0102229 <mem_init+0xfa2>
f0102210:	68 08 62 10 f0       	push   $0xf0106208
f0102215:	68 36 5f 10 f0       	push   $0xf0105f36
f010221a:	68 0d 04 00 00       	push   $0x40d
f010221f:	68 10 5f 10 f0       	push   $0xf0105f10
f0102224:	e8 17 de ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102229:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010222c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102233:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102239:	89 f0                	mov    %esi,%eax
f010223b:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f0102241:	c1 f8 03             	sar    $0x3,%eax
f0102244:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102247:	89 c2                	mov    %eax,%edx
f0102249:	c1 ea 0c             	shr    $0xc,%edx
f010224c:	39 d1                	cmp    %edx,%ecx
f010224e:	77 12                	ja     f0102262 <mem_init+0xfdb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102250:	50                   	push   %eax
f0102251:	68 64 59 10 f0       	push   $0xf0105964
f0102256:	6a 58                	push   $0x58
f0102258:	68 1c 5f 10 f0       	push   $0xf0105f1c
f010225d:	e8 de dd ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102262:	83 ec 04             	sub    $0x4,%esp
f0102265:	68 00 10 00 00       	push   $0x1000
f010226a:	68 ff 00 00 00       	push   $0xff
f010226f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102274:	50                   	push   %eax
f0102275:	e8 09 2a 00 00       	call   f0104c83 <memset>
	page_free(pp0);
f010227a:	89 34 24             	mov    %esi,(%esp)
f010227d:	e8 02 ed ff ff       	call   f0100f84 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102282:	83 c4 0c             	add    $0xc,%esp
f0102285:	6a 01                	push   $0x1
f0102287:	6a 00                	push   $0x0
f0102289:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f010228f:	e8 26 ed ff ff       	call   f0100fba <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102294:	89 f2                	mov    %esi,%edx
f0102296:	2b 15 90 ae 22 f0    	sub    0xf022ae90,%edx
f010229c:	c1 fa 03             	sar    $0x3,%edx
f010229f:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01022a2:	89 d0                	mov    %edx,%eax
f01022a4:	c1 e8 0c             	shr    $0xc,%eax
f01022a7:	83 c4 10             	add    $0x10,%esp
f01022aa:	3b 05 88 ae 22 f0    	cmp    0xf022ae88,%eax
f01022b0:	72 12                	jb     f01022c4 <mem_init+0x103d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022b2:	52                   	push   %edx
f01022b3:	68 64 59 10 f0       	push   $0xf0105964
f01022b8:	6a 58                	push   $0x58
f01022ba:	68 1c 5f 10 f0       	push   $0xf0105f1c
f01022bf:	e8 7c dd ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01022c4:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01022ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01022cd:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01022d3:	f6 00 01             	testb  $0x1,(%eax)
f01022d6:	74 19                	je     f01022f1 <mem_init+0x106a>
f01022d8:	68 20 62 10 f0       	push   $0xf0106220
f01022dd:	68 36 5f 10 f0       	push   $0xf0105f36
f01022e2:	68 17 04 00 00       	push   $0x417
f01022e7:	68 10 5f 10 f0       	push   $0xf0105f10
f01022ec:	e8 4f dd ff ff       	call   f0100040 <_panic>
f01022f1:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01022f4:	39 c2                	cmp    %eax,%edx
f01022f6:	75 db                	jne    f01022d3 <mem_init+0x104c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01022f8:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f01022fd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102303:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102309:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010230c:	a3 40 a2 22 f0       	mov    %eax,0xf022a240

	// free the pages we took
	page_free(pp0);
f0102311:	83 ec 0c             	sub    $0xc,%esp
f0102314:	56                   	push   %esi
f0102315:	e8 6a ec ff ff       	call   f0100f84 <page_free>
	page_free(pp1);
f010231a:	83 c4 04             	add    $0x4,%esp
f010231d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102320:	e8 5f ec ff ff       	call   f0100f84 <page_free>
	page_free(pp2);
f0102325:	89 1c 24             	mov    %ebx,(%esp)
f0102328:	e8 57 ec ff ff       	call   f0100f84 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010232d:	83 c4 08             	add    $0x8,%esp
f0102330:	68 01 10 00 00       	push   $0x1001
f0102335:	6a 00                	push   $0x0
f0102337:	e8 e8 ee ff ff       	call   f0101224 <mmio_map_region>
f010233c:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f010233e:	83 c4 08             	add    $0x8,%esp
f0102341:	68 00 10 00 00       	push   $0x1000
f0102346:	6a 00                	push   $0x0
f0102348:	e8 d7 ee ff ff       	call   f0101224 <mmio_map_region>
f010234d:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010234f:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102355:	83 c4 10             	add    $0x10,%esp
f0102358:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010235e:	76 07                	jbe    f0102367 <mem_init+0x10e0>
f0102360:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102365:	76 19                	jbe    f0102380 <mem_init+0x10f9>
f0102367:	68 54 68 10 f0       	push   $0xf0106854
f010236c:	68 36 5f 10 f0       	push   $0xf0105f36
f0102371:	68 27 04 00 00       	push   $0x427
f0102376:	68 10 5f 10 f0       	push   $0xf0105f10
f010237b:	e8 c0 dc ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102380:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102386:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010238c:	77 08                	ja     f0102396 <mem_init+0x110f>
f010238e:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102394:	77 19                	ja     f01023af <mem_init+0x1128>
f0102396:	68 7c 68 10 f0       	push   $0xf010687c
f010239b:	68 36 5f 10 f0       	push   $0xf0105f36
f01023a0:	68 28 04 00 00       	push   $0x428
f01023a5:	68 10 5f 10 f0       	push   $0xf0105f10
f01023aa:	e8 91 dc ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01023af:	89 da                	mov    %ebx,%edx
f01023b1:	09 f2                	or     %esi,%edx
f01023b3:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01023b9:	74 19                	je     f01023d4 <mem_init+0x114d>
f01023bb:	68 a4 68 10 f0       	push   $0xf01068a4
f01023c0:	68 36 5f 10 f0       	push   $0xf0105f36
f01023c5:	68 2a 04 00 00       	push   $0x42a
f01023ca:	68 10 5f 10 f0       	push   $0xf0105f10
f01023cf:	e8 6c dc ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01023d4:	39 c6                	cmp    %eax,%esi
f01023d6:	73 19                	jae    f01023f1 <mem_init+0x116a>
f01023d8:	68 37 62 10 f0       	push   $0xf0106237
f01023dd:	68 36 5f 10 f0       	push   $0xf0105f36
f01023e2:	68 2c 04 00 00       	push   $0x42c
f01023e7:	68 10 5f 10 f0       	push   $0xf0105f10
f01023ec:	e8 4f dc ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01023f1:	8b 3d 8c ae 22 f0    	mov    0xf022ae8c,%edi
f01023f7:	89 da                	mov    %ebx,%edx
f01023f9:	89 f8                	mov    %edi,%eax
f01023fb:	e8 1e e7 ff ff       	call   f0100b1e <check_va2pa>
f0102400:	85 c0                	test   %eax,%eax
f0102402:	74 19                	je     f010241d <mem_init+0x1196>
f0102404:	68 cc 68 10 f0       	push   $0xf01068cc
f0102409:	68 36 5f 10 f0       	push   $0xf0105f36
f010240e:	68 2e 04 00 00       	push   $0x42e
f0102413:	68 10 5f 10 f0       	push   $0xf0105f10
f0102418:	e8 23 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010241d:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102423:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102426:	89 c2                	mov    %eax,%edx
f0102428:	89 f8                	mov    %edi,%eax
f010242a:	e8 ef e6 ff ff       	call   f0100b1e <check_va2pa>
f010242f:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102434:	74 19                	je     f010244f <mem_init+0x11c8>
f0102436:	68 f0 68 10 f0       	push   $0xf01068f0
f010243b:	68 36 5f 10 f0       	push   $0xf0105f36
f0102440:	68 2f 04 00 00       	push   $0x42f
f0102445:	68 10 5f 10 f0       	push   $0xf0105f10
f010244a:	e8 f1 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010244f:	89 f2                	mov    %esi,%edx
f0102451:	89 f8                	mov    %edi,%eax
f0102453:	e8 c6 e6 ff ff       	call   f0100b1e <check_va2pa>
f0102458:	85 c0                	test   %eax,%eax
f010245a:	74 19                	je     f0102475 <mem_init+0x11ee>
f010245c:	68 20 69 10 f0       	push   $0xf0106920
f0102461:	68 36 5f 10 f0       	push   $0xf0105f36
f0102466:	68 30 04 00 00       	push   $0x430
f010246b:	68 10 5f 10 f0       	push   $0xf0105f10
f0102470:	e8 cb db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102475:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010247b:	89 f8                	mov    %edi,%eax
f010247d:	e8 9c e6 ff ff       	call   f0100b1e <check_va2pa>
f0102482:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102485:	74 19                	je     f01024a0 <mem_init+0x1219>
f0102487:	68 44 69 10 f0       	push   $0xf0106944
f010248c:	68 36 5f 10 f0       	push   $0xf0105f36
f0102491:	68 31 04 00 00       	push   $0x431
f0102496:	68 10 5f 10 f0       	push   $0xf0105f10
f010249b:	e8 a0 db ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01024a0:	83 ec 04             	sub    $0x4,%esp
f01024a3:	6a 00                	push   $0x0
f01024a5:	53                   	push   %ebx
f01024a6:	57                   	push   %edi
f01024a7:	e8 0e eb ff ff       	call   f0100fba <pgdir_walk>
f01024ac:	83 c4 10             	add    $0x10,%esp
f01024af:	f6 00 1a             	testb  $0x1a,(%eax)
f01024b2:	75 19                	jne    f01024cd <mem_init+0x1246>
f01024b4:	68 70 69 10 f0       	push   $0xf0106970
f01024b9:	68 36 5f 10 f0       	push   $0xf0105f36
f01024be:	68 33 04 00 00       	push   $0x433
f01024c3:	68 10 5f 10 f0       	push   $0xf0105f10
f01024c8:	e8 73 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01024cd:	83 ec 04             	sub    $0x4,%esp
f01024d0:	6a 00                	push   $0x0
f01024d2:	53                   	push   %ebx
f01024d3:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f01024d9:	e8 dc ea ff ff       	call   f0100fba <pgdir_walk>
f01024de:	8b 00                	mov    (%eax),%eax
f01024e0:	83 c4 10             	add    $0x10,%esp
f01024e3:	83 e0 04             	and    $0x4,%eax
f01024e6:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01024e9:	74 19                	je     f0102504 <mem_init+0x127d>
f01024eb:	68 b4 69 10 f0       	push   $0xf01069b4
f01024f0:	68 36 5f 10 f0       	push   $0xf0105f36
f01024f5:	68 34 04 00 00       	push   $0x434
f01024fa:	68 10 5f 10 f0       	push   $0xf0105f10
f01024ff:	e8 3c db ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102504:	83 ec 04             	sub    $0x4,%esp
f0102507:	6a 00                	push   $0x0
f0102509:	53                   	push   %ebx
f010250a:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f0102510:	e8 a5 ea ff ff       	call   f0100fba <pgdir_walk>
f0102515:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010251b:	83 c4 0c             	add    $0xc,%esp
f010251e:	6a 00                	push   $0x0
f0102520:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102523:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f0102529:	e8 8c ea ff ff       	call   f0100fba <pgdir_walk>
f010252e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102534:	83 c4 0c             	add    $0xc,%esp
f0102537:	6a 00                	push   $0x0
f0102539:	56                   	push   %esi
f010253a:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f0102540:	e8 75 ea ff ff       	call   f0100fba <pgdir_walk>
f0102545:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010254b:	c7 04 24 49 62 10 f0 	movl   $0xf0106249,(%esp)
f0102552:	e8 27 11 00 00       	call   f010367e <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, 
f0102557:	a1 90 ae 22 f0       	mov    0xf022ae90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010255c:	83 c4 10             	add    $0x10,%esp
f010255f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102564:	77 15                	ja     f010257b <mem_init+0x12f4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102566:	50                   	push   %eax
f0102567:	68 88 59 10 f0       	push   $0xf0105988
f010256c:	68 c0 00 00 00       	push   $0xc0
f0102571:	68 10 5f 10 f0       	push   $0xf0105f10
f0102576:	e8 c5 da ff ff       	call   f0100040 <_panic>
f010257b:	83 ec 08             	sub    $0x8,%esp
f010257e:	6a 04                	push   $0x4
f0102580:	05 00 00 00 10       	add    $0x10000000,%eax
f0102585:	50                   	push   %eax
f0102586:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010258b:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102590:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102595:	e8 b3 ea ff ff       	call   f010104d <boot_map_region>
		UPAGES, 
		PTSIZE, 
		PADDR(pages), 
		PTE_U);
	cprintf("PADDR(pages) %x\n", PADDR(pages));
f010259a:	a1 90 ae 22 f0       	mov    0xf022ae90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010259f:	83 c4 10             	add    $0x10,%esp
f01025a2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025a7:	77 15                	ja     f01025be <mem_init+0x1337>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025a9:	50                   	push   %eax
f01025aa:	68 88 59 10 f0       	push   $0xf0105988
f01025af:	68 c2 00 00 00       	push   $0xc2
f01025b4:	68 10 5f 10 f0       	push   $0xf0105f10
f01025b9:	e8 82 da ff ff       	call   f0100040 <_panic>
f01025be:	83 ec 08             	sub    $0x8,%esp
f01025c1:	05 00 00 00 10       	add    $0x10000000,%eax
f01025c6:	50                   	push   %eax
f01025c7:	68 62 62 10 f0       	push   $0xf0106262
f01025cc:	e8 ad 10 00 00       	call   f010367e <cprintf>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,
f01025d1:	a1 48 a2 22 f0       	mov    0xf022a248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025d6:	83 c4 10             	add    $0x10,%esp
f01025d9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025de:	77 15                	ja     f01025f5 <mem_init+0x136e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025e0:	50                   	push   %eax
f01025e1:	68 88 59 10 f0       	push   $0xf0105988
f01025e6:	68 cd 00 00 00       	push   $0xcd
f01025eb:	68 10 5f 10 f0       	push   $0xf0105f10
f01025f0:	e8 4b da ff ff       	call   f0100040 <_panic>
f01025f5:	83 ec 08             	sub    $0x8,%esp
f01025f8:	6a 04                	push   $0x4
f01025fa:	05 00 00 00 10       	add    $0x10000000,%eax
f01025ff:	50                   	push   %eax
f0102600:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102605:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010260a:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f010260f:	e8 39 ea ff ff       	call   f010104d <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102614:	83 c4 10             	add    $0x10,%esp
f0102617:	b8 00 50 11 f0       	mov    $0xf0115000,%eax
f010261c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102621:	77 15                	ja     f0102638 <mem_init+0x13b1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102623:	50                   	push   %eax
f0102624:	68 88 59 10 f0       	push   $0xf0105988
f0102629:	68 df 00 00 00       	push   $0xdf
f010262e:	68 10 5f 10 f0       	push   $0xf0105f10
f0102633:	e8 08 da ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f0102638:	83 ec 08             	sub    $0x8,%esp
f010263b:	6a 02                	push   $0x2
f010263d:	68 00 50 11 00       	push   $0x115000
f0102642:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102647:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010264c:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f0102651:	e8 f7 e9 ff ff       	call   f010104d <boot_map_region>
		KSTACKTOP-KSTKSIZE, 
		KSTKSIZE, 
		PADDR(bootstack), 
		PTE_W);
	cprintf("PADDR(bootstack) %x\n", PADDR(bootstack));
f0102656:	83 c4 08             	add    $0x8,%esp
f0102659:	68 00 50 11 00       	push   $0x115000
f010265e:	68 73 62 10 f0       	push   $0xf0106273
f0102663:	e8 16 10 00 00       	call   f010367e <cprintf>
f0102668:	c7 45 c4 00 c0 22 f0 	movl   $0xf022c000,-0x3c(%ebp)
f010266f:	83 c4 10             	add    $0x10,%esp
f0102672:	bb 00 c0 22 f0       	mov    $0xf022c000,%ebx
f0102677:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010267c:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102682:	77 15                	ja     f0102699 <mem_init+0x1412>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102684:	53                   	push   %ebx
f0102685:	68 88 59 10 f0       	push   $0xf0105988
f010268a:	68 2c 01 00 00       	push   $0x12c
f010268f:	68 10 5f 10 f0       	push   $0xf0105f10
f0102694:	e8 a7 d9 ff ff       	call   f0100040 <_panic>
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
int i;
    for (i = 0; i < NCPU; i++) {
        boot_map_region(kern_pgdir, 
f0102699:	83 ec 08             	sub    $0x8,%esp
f010269c:	6a 02                	push   $0x2
f010269e:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01026a4:	50                   	push   %eax
f01026a5:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01026aa:	89 f2                	mov    %esi,%edx
f01026ac:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f01026b1:	e8 97 e9 ff ff       	call   f010104d <boot_map_region>
f01026b6:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01026bc:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
int i;
    for (i = 0; i < NCPU; i++) {
f01026c2:	83 c4 10             	add    $0x10,%esp
f01026c5:	b8 00 c0 26 f0       	mov    $0xf026c000,%eax
f01026ca:	39 d8                	cmp    %ebx,%eax
f01026cc:	75 ae                	jne    f010267c <mem_init+0x13f5>

//<<<<<<< HEAD
	// Initialize the SMP-related parts of the memory map
	mem_init_mp();
//=======
	boot_map_region(kern_pgdir, 
f01026ce:	83 ec 08             	sub    $0x8,%esp
f01026d1:	6a 02                	push   $0x2
f01026d3:	6a 00                	push   $0x0
f01026d5:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01026da:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01026df:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
f01026e4:	e8 64 e9 ff ff       	call   f010104d <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01026e9:	8b 3d 8c ae 22 f0    	mov    0xf022ae8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01026ef:	a1 88 ae 22 f0       	mov    0xf022ae88,%eax
f01026f4:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01026f7:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01026fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102703:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102706:	8b 35 90 ae 22 f0    	mov    0xf022ae90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010270c:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010270f:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102712:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102717:	eb 55                	jmp    f010276e <mem_init+0x14e7>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102719:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010271f:	89 f8                	mov    %edi,%eax
f0102721:	e8 f8 e3 ff ff       	call   f0100b1e <check_va2pa>
f0102726:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010272d:	77 15                	ja     f0102744 <mem_init+0x14bd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010272f:	56                   	push   %esi
f0102730:	68 88 59 10 f0       	push   $0xf0105988
f0102735:	68 4e 03 00 00       	push   $0x34e
f010273a:	68 10 5f 10 f0       	push   $0xf0105f10
f010273f:	e8 fc d8 ff ff       	call   f0100040 <_panic>
f0102744:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f010274b:	39 c2                	cmp    %eax,%edx
f010274d:	74 19                	je     f0102768 <mem_init+0x14e1>
f010274f:	68 e8 69 10 f0       	push   $0xf01069e8
f0102754:	68 36 5f 10 f0       	push   $0xf0105f36
f0102759:	68 4e 03 00 00       	push   $0x34e
f010275e:	68 10 5f 10 f0       	push   $0xf0105f10
f0102763:	e8 d8 d8 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102768:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010276e:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102771:	77 a6                	ja     f0102719 <mem_init+0x1492>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102773:	8b 35 48 a2 22 f0    	mov    0xf022a248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102779:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010277c:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102781:	89 da                	mov    %ebx,%edx
f0102783:	89 f8                	mov    %edi,%eax
f0102785:	e8 94 e3 ff ff       	call   f0100b1e <check_va2pa>
f010278a:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102791:	77 15                	ja     f01027a8 <mem_init+0x1521>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102793:	56                   	push   %esi
f0102794:	68 88 59 10 f0       	push   $0xf0105988
f0102799:	68 53 03 00 00       	push   $0x353
f010279e:	68 10 5f 10 f0       	push   $0xf0105f10
f01027a3:	e8 98 d8 ff ff       	call   f0100040 <_panic>
f01027a8:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01027af:	39 d0                	cmp    %edx,%eax
f01027b1:	74 19                	je     f01027cc <mem_init+0x1545>
f01027b3:	68 1c 6a 10 f0       	push   $0xf0106a1c
f01027b8:	68 36 5f 10 f0       	push   $0xf0105f36
f01027bd:	68 53 03 00 00       	push   $0x353
f01027c2:	68 10 5f 10 f0       	push   $0xf0105f10
f01027c7:	e8 74 d8 ff ff       	call   f0100040 <_panic>
f01027cc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027d2:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01027d8:	75 a7                	jne    f0102781 <mem_init+0x14fa>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027da:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01027dd:	c1 e6 0c             	shl    $0xc,%esi
f01027e0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01027e5:	eb 30                	jmp    f0102817 <mem_init+0x1590>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01027e7:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01027ed:	89 f8                	mov    %edi,%eax
f01027ef:	e8 2a e3 ff ff       	call   f0100b1e <check_va2pa>
f01027f4:	39 c3                	cmp    %eax,%ebx
f01027f6:	74 19                	je     f0102811 <mem_init+0x158a>
f01027f8:	68 50 6a 10 f0       	push   $0xf0106a50
f01027fd:	68 36 5f 10 f0       	push   $0xf0105f36
f0102802:	68 57 03 00 00       	push   $0x357
f0102807:	68 10 5f 10 f0       	push   $0xf0105f10
f010280c:	e8 2f d8 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102811:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102817:	39 f3                	cmp    %esi,%ebx
f0102819:	72 cc                	jb     f01027e7 <mem_init+0x1560>
f010281b:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102820:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102823:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102826:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102829:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f010282f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102832:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102834:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102837:	05 00 80 00 20       	add    $0x20008000,%eax
f010283c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010283f:	89 da                	mov    %ebx,%edx
f0102841:	89 f8                	mov    %edi,%eax
f0102843:	e8 d6 e2 ff ff       	call   f0100b1e <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102848:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f010284e:	77 15                	ja     f0102865 <mem_init+0x15de>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102850:	56                   	push   %esi
f0102851:	68 88 59 10 f0       	push   $0xf0105988
f0102856:	68 5f 03 00 00       	push   $0x35f
f010285b:	68 10 5f 10 f0       	push   $0xf0105f10
f0102860:	e8 db d7 ff ff       	call   f0100040 <_panic>
f0102865:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102868:	8d 94 0b 00 c0 22 f0 	lea    -0xfdd4000(%ebx,%ecx,1),%edx
f010286f:	39 d0                	cmp    %edx,%eax
f0102871:	74 19                	je     f010288c <mem_init+0x1605>
f0102873:	68 78 6a 10 f0       	push   $0xf0106a78
f0102878:	68 36 5f 10 f0       	push   $0xf0105f36
f010287d:	68 5f 03 00 00       	push   $0x35f
f0102882:	68 10 5f 10 f0       	push   $0xf0105f10
f0102887:	e8 b4 d7 ff ff       	call   f0100040 <_panic>
f010288c:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102892:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102895:	75 a8                	jne    f010283f <mem_init+0x15b8>
f0102897:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010289a:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f01028a0:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01028a3:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01028a5:	89 da                	mov    %ebx,%edx
f01028a7:	89 f8                	mov    %edi,%eax
f01028a9:	e8 70 e2 ff ff       	call   f0100b1e <check_va2pa>
f01028ae:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028b1:	74 19                	je     f01028cc <mem_init+0x1645>
f01028b3:	68 c0 6a 10 f0       	push   $0xf0106ac0
f01028b8:	68 36 5f 10 f0       	push   $0xf0105f36
f01028bd:	68 61 03 00 00       	push   $0x361
f01028c2:	68 10 5f 10 f0       	push   $0xf0105f10
f01028c7:	e8 74 d7 ff ff       	call   f0100040 <_panic>
f01028cc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01028d2:	39 de                	cmp    %ebx,%esi
f01028d4:	75 cf                	jne    f01028a5 <mem_init+0x161e>
f01028d6:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01028d9:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f01028e0:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f01028e7:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01028ed:	81 fe 00 c0 26 f0    	cmp    $0xf026c000,%esi
f01028f3:	0f 85 2d ff ff ff    	jne    f0102826 <mem_init+0x159f>
f01028f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01028fe:	eb 2a                	jmp    f010292a <mem_init+0x16a3>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102900:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102906:	83 fa 04             	cmp    $0x4,%edx
f0102909:	77 1f                	ja     f010292a <mem_init+0x16a3>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010290b:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f010290f:	75 7e                	jne    f010298f <mem_init+0x1708>
f0102911:	68 88 62 10 f0       	push   $0xf0106288
f0102916:	68 36 5f 10 f0       	push   $0xf0105f36
f010291b:	68 6c 03 00 00       	push   $0x36c
f0102920:	68 10 5f 10 f0       	push   $0xf0105f10
f0102925:	e8 16 d7 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010292a:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010292f:	76 3f                	jbe    f0102970 <mem_init+0x16e9>
				assert(pgdir[i] & PTE_P);
f0102931:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102934:	f6 c2 01             	test   $0x1,%dl
f0102937:	75 19                	jne    f0102952 <mem_init+0x16cb>
f0102939:	68 88 62 10 f0       	push   $0xf0106288
f010293e:	68 36 5f 10 f0       	push   $0xf0105f36
f0102943:	68 70 03 00 00       	push   $0x370
f0102948:	68 10 5f 10 f0       	push   $0xf0105f10
f010294d:	e8 ee d6 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102952:	f6 c2 02             	test   $0x2,%dl
f0102955:	75 38                	jne    f010298f <mem_init+0x1708>
f0102957:	68 99 62 10 f0       	push   $0xf0106299
f010295c:	68 36 5f 10 f0       	push   $0xf0105f36
f0102961:	68 71 03 00 00       	push   $0x371
f0102966:	68 10 5f 10 f0       	push   $0xf0105f10
f010296b:	e8 d0 d6 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102970:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102974:	74 19                	je     f010298f <mem_init+0x1708>
f0102976:	68 aa 62 10 f0       	push   $0xf01062aa
f010297b:	68 36 5f 10 f0       	push   $0xf0105f36
f0102980:	68 73 03 00 00       	push   $0x373
f0102985:	68 10 5f 10 f0       	push   $0xf0105f10
f010298a:	e8 b1 d6 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010298f:	83 c0 01             	add    $0x1,%eax
f0102992:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102997:	0f 86 63 ff ff ff    	jbe    f0102900 <mem_init+0x1679>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010299d:	83 ec 0c             	sub    $0xc,%esp
f01029a0:	68 e4 6a 10 f0       	push   $0xf0106ae4
f01029a5:	e8 d4 0c 00 00       	call   f010367e <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01029aa:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029af:	83 c4 10             	add    $0x10,%esp
f01029b2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029b7:	77 15                	ja     f01029ce <mem_init+0x1747>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029b9:	50                   	push   %eax
f01029ba:	68 88 59 10 f0       	push   $0xf0105988
f01029bf:	68 02 01 00 00       	push   $0x102
f01029c4:	68 10 5f 10 f0       	push   $0xf0105f10
f01029c9:	e8 72 d6 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01029ce:	05 00 00 00 10       	add    $0x10000000,%eax
f01029d3:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01029d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01029db:	e8 a2 e1 ff ff       	call   f0100b82 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01029e0:	0f 20 c0             	mov    %cr0,%eax
f01029e3:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01029e6:	0d 23 00 05 80       	or     $0x80050023,%eax
f01029eb:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01029ee:	83 ec 0c             	sub    $0xc,%esp
f01029f1:	6a 00                	push   $0x0
f01029f3:	e8 22 e5 ff ff       	call   f0100f1a <page_alloc>
f01029f8:	89 c3                	mov    %eax,%ebx
f01029fa:	83 c4 10             	add    $0x10,%esp
f01029fd:	85 c0                	test   %eax,%eax
f01029ff:	75 19                	jne    f0102a1a <mem_init+0x1793>
f0102a01:	68 53 60 10 f0       	push   $0xf0106053
f0102a06:	68 36 5f 10 f0       	push   $0xf0105f36
f0102a0b:	68 49 04 00 00       	push   $0x449
f0102a10:	68 10 5f 10 f0       	push   $0xf0105f10
f0102a15:	e8 26 d6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a1a:	83 ec 0c             	sub    $0xc,%esp
f0102a1d:	6a 00                	push   $0x0
f0102a1f:	e8 f6 e4 ff ff       	call   f0100f1a <page_alloc>
f0102a24:	89 c7                	mov    %eax,%edi
f0102a26:	83 c4 10             	add    $0x10,%esp
f0102a29:	85 c0                	test   %eax,%eax
f0102a2b:	75 19                	jne    f0102a46 <mem_init+0x17bf>
f0102a2d:	68 69 60 10 f0       	push   $0xf0106069
f0102a32:	68 36 5f 10 f0       	push   $0xf0105f36
f0102a37:	68 4a 04 00 00       	push   $0x44a
f0102a3c:	68 10 5f 10 f0       	push   $0xf0105f10
f0102a41:	e8 fa d5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102a46:	83 ec 0c             	sub    $0xc,%esp
f0102a49:	6a 00                	push   $0x0
f0102a4b:	e8 ca e4 ff ff       	call   f0100f1a <page_alloc>
f0102a50:	89 c6                	mov    %eax,%esi
f0102a52:	83 c4 10             	add    $0x10,%esp
f0102a55:	85 c0                	test   %eax,%eax
f0102a57:	75 19                	jne    f0102a72 <mem_init+0x17eb>
f0102a59:	68 7f 60 10 f0       	push   $0xf010607f
f0102a5e:	68 36 5f 10 f0       	push   $0xf0105f36
f0102a63:	68 4b 04 00 00       	push   $0x44b
f0102a68:	68 10 5f 10 f0       	push   $0xf0105f10
f0102a6d:	e8 ce d5 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102a72:	83 ec 0c             	sub    $0xc,%esp
f0102a75:	53                   	push   %ebx
f0102a76:	e8 09 e5 ff ff       	call   f0100f84 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a7b:	89 f8                	mov    %edi,%eax
f0102a7d:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f0102a83:	c1 f8 03             	sar    $0x3,%eax
f0102a86:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a89:	89 c2                	mov    %eax,%edx
f0102a8b:	c1 ea 0c             	shr    $0xc,%edx
f0102a8e:	83 c4 10             	add    $0x10,%esp
f0102a91:	3b 15 88 ae 22 f0    	cmp    0xf022ae88,%edx
f0102a97:	72 12                	jb     f0102aab <mem_init+0x1824>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a99:	50                   	push   %eax
f0102a9a:	68 64 59 10 f0       	push   $0xf0105964
f0102a9f:	6a 58                	push   $0x58
f0102aa1:	68 1c 5f 10 f0       	push   $0xf0105f1c
f0102aa6:	e8 95 d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102aab:	83 ec 04             	sub    $0x4,%esp
f0102aae:	68 00 10 00 00       	push   $0x1000
f0102ab3:	6a 01                	push   $0x1
f0102ab5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102aba:	50                   	push   %eax
f0102abb:	e8 c3 21 00 00       	call   f0104c83 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ac0:	89 f0                	mov    %esi,%eax
f0102ac2:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f0102ac8:	c1 f8 03             	sar    $0x3,%eax
f0102acb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ace:	89 c2                	mov    %eax,%edx
f0102ad0:	c1 ea 0c             	shr    $0xc,%edx
f0102ad3:	83 c4 10             	add    $0x10,%esp
f0102ad6:	3b 15 88 ae 22 f0    	cmp    0xf022ae88,%edx
f0102adc:	72 12                	jb     f0102af0 <mem_init+0x1869>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ade:	50                   	push   %eax
f0102adf:	68 64 59 10 f0       	push   $0xf0105964
f0102ae4:	6a 58                	push   $0x58
f0102ae6:	68 1c 5f 10 f0       	push   $0xf0105f1c
f0102aeb:	e8 50 d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102af0:	83 ec 04             	sub    $0x4,%esp
f0102af3:	68 00 10 00 00       	push   $0x1000
f0102af8:	6a 02                	push   $0x2
f0102afa:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102aff:	50                   	push   %eax
f0102b00:	e8 7e 21 00 00       	call   f0104c83 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b05:	6a 02                	push   $0x2
f0102b07:	68 00 10 00 00       	push   $0x1000
f0102b0c:	57                   	push   %edi
f0102b0d:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f0102b13:	e8 a6 e6 ff ff       	call   f01011be <page_insert>
	assert(pp1->pp_ref == 1);
f0102b18:	83 c4 20             	add    $0x20,%esp
f0102b1b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b20:	74 19                	je     f0102b3b <mem_init+0x18b4>
f0102b22:	68 60 61 10 f0       	push   $0xf0106160
f0102b27:	68 36 5f 10 f0       	push   $0xf0105f36
f0102b2c:	68 50 04 00 00       	push   $0x450
f0102b31:	68 10 5f 10 f0       	push   $0xf0105f10
f0102b36:	e8 05 d5 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102b3b:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102b42:	01 01 01 
f0102b45:	74 19                	je     f0102b60 <mem_init+0x18d9>
f0102b47:	68 04 6b 10 f0       	push   $0xf0106b04
f0102b4c:	68 36 5f 10 f0       	push   $0xf0105f36
f0102b51:	68 51 04 00 00       	push   $0x451
f0102b56:	68 10 5f 10 f0       	push   $0xf0105f10
f0102b5b:	e8 e0 d4 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102b60:	6a 02                	push   $0x2
f0102b62:	68 00 10 00 00       	push   $0x1000
f0102b67:	56                   	push   %esi
f0102b68:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f0102b6e:	e8 4b e6 ff ff       	call   f01011be <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102b73:	83 c4 10             	add    $0x10,%esp
f0102b76:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102b7d:	02 02 02 
f0102b80:	74 19                	je     f0102b9b <mem_init+0x1914>
f0102b82:	68 28 6b 10 f0       	push   $0xf0106b28
f0102b87:	68 36 5f 10 f0       	push   $0xf0105f36
f0102b8c:	68 53 04 00 00       	push   $0x453
f0102b91:	68 10 5f 10 f0       	push   $0xf0105f10
f0102b96:	e8 a5 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102b9b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102ba0:	74 19                	je     f0102bbb <mem_init+0x1934>
f0102ba2:	68 82 61 10 f0       	push   $0xf0106182
f0102ba7:	68 36 5f 10 f0       	push   $0xf0105f36
f0102bac:	68 54 04 00 00       	push   $0x454
f0102bb1:	68 10 5f 10 f0       	push   $0xf0105f10
f0102bb6:	e8 85 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102bbb:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102bc0:	74 19                	je     f0102bdb <mem_init+0x1954>
f0102bc2:	68 f7 61 10 f0       	push   $0xf01061f7
f0102bc7:	68 36 5f 10 f0       	push   $0xf0105f36
f0102bcc:	68 55 04 00 00       	push   $0x455
f0102bd1:	68 10 5f 10 f0       	push   $0xf0105f10
f0102bd6:	e8 65 d4 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102bdb:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102be2:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102be5:	89 f0                	mov    %esi,%eax
f0102be7:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f0102bed:	c1 f8 03             	sar    $0x3,%eax
f0102bf0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bf3:	89 c2                	mov    %eax,%edx
f0102bf5:	c1 ea 0c             	shr    $0xc,%edx
f0102bf8:	3b 15 88 ae 22 f0    	cmp    0xf022ae88,%edx
f0102bfe:	72 12                	jb     f0102c12 <mem_init+0x198b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c00:	50                   	push   %eax
f0102c01:	68 64 59 10 f0       	push   $0xf0105964
f0102c06:	6a 58                	push   $0x58
f0102c08:	68 1c 5f 10 f0       	push   $0xf0105f1c
f0102c0d:	e8 2e d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c12:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c19:	03 03 03 
f0102c1c:	74 19                	je     f0102c37 <mem_init+0x19b0>
f0102c1e:	68 4c 6b 10 f0       	push   $0xf0106b4c
f0102c23:	68 36 5f 10 f0       	push   $0xf0105f36
f0102c28:	68 57 04 00 00       	push   $0x457
f0102c2d:	68 10 5f 10 f0       	push   $0xf0105f10
f0102c32:	e8 09 d4 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c37:	83 ec 08             	sub    $0x8,%esp
f0102c3a:	68 00 10 00 00       	push   $0x1000
f0102c3f:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f0102c45:	e8 26 e5 ff ff       	call   f0101170 <page_remove>
	assert(pp2->pp_ref == 0);
f0102c4a:	83 c4 10             	add    $0x10,%esp
f0102c4d:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102c52:	74 19                	je     f0102c6d <mem_init+0x19e6>
f0102c54:	68 e6 61 10 f0       	push   $0xf01061e6
f0102c59:	68 36 5f 10 f0       	push   $0xf0105f36
f0102c5e:	68 59 04 00 00       	push   $0x459
f0102c63:	68 10 5f 10 f0       	push   $0xf0105f10
f0102c68:	e8 d3 d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c6d:	8b 0d 8c ae 22 f0    	mov    0xf022ae8c,%ecx
f0102c73:	8b 11                	mov    (%ecx),%edx
f0102c75:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102c7b:	89 d8                	mov    %ebx,%eax
f0102c7d:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f0102c83:	c1 f8 03             	sar    $0x3,%eax
f0102c86:	c1 e0 0c             	shl    $0xc,%eax
f0102c89:	39 c2                	cmp    %eax,%edx
f0102c8b:	74 19                	je     f0102ca6 <mem_init+0x1a1f>
f0102c8d:	68 0c 65 10 f0       	push   $0xf010650c
f0102c92:	68 36 5f 10 f0       	push   $0xf0105f36
f0102c97:	68 5c 04 00 00       	push   $0x45c
f0102c9c:	68 10 5f 10 f0       	push   $0xf0105f10
f0102ca1:	e8 9a d3 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102ca6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102cac:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102cb1:	74 19                	je     f0102ccc <mem_init+0x1a45>
f0102cb3:	68 71 61 10 f0       	push   $0xf0106171
f0102cb8:	68 36 5f 10 f0       	push   $0xf0105f36
f0102cbd:	68 5e 04 00 00       	push   $0x45e
f0102cc2:	68 10 5f 10 f0       	push   $0xf0105f10
f0102cc7:	e8 74 d3 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102ccc:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102cd2:	83 ec 0c             	sub    $0xc,%esp
f0102cd5:	53                   	push   %ebx
f0102cd6:	e8 a9 e2 ff ff       	call   f0100f84 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102cdb:	c7 04 24 78 6b 10 f0 	movl   $0xf0106b78,(%esp)
f0102ce2:	e8 97 09 00 00       	call   f010367e <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102ce7:	83 c4 10             	add    $0x10,%esp
f0102cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ced:	5b                   	pop    %ebx
f0102cee:	5e                   	pop    %esi
f0102cef:	5f                   	pop    %edi
f0102cf0:	5d                   	pop    %ebp
f0102cf1:	c3                   	ret    

f0102cf2 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102cf2:	55                   	push   %ebp
f0102cf3:	89 e5                	mov    %esp,%ebp
f0102cf5:	57                   	push   %edi
f0102cf6:	56                   	push   %esi
f0102cf7:	53                   	push   %ebx
f0102cf8:	83 ec 1c             	sub    $0x1c,%esp
f0102cfb:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102cfe:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	
	uint32_t mem_start = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f0102d01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102d04:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t mem_end = (uint32_t) ROUNDUP(va+len, PGSIZE);
f0102d0a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d0d:	03 45 10             	add    0x10(%ebp),%eax
f0102d10:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102d15:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t i;
	while (mem_start < mem_end) {
f0102d1d:	eb 43                	jmp    f0102d62 <user_mem_check+0x70>
		pte_t *page_tbl_entry = pgdir_walk(env->env_pgdir, (void*)mem_start, 0);
f0102d1f:	83 ec 04             	sub    $0x4,%esp
f0102d22:	6a 00                	push   $0x0
f0102d24:	53                   	push   %ebx
f0102d25:	ff 77 60             	pushl  0x60(%edi)
f0102d28:	e8 8d e2 ff ff       	call   f0100fba <pgdir_walk>
		
		if ((mem_start>=ULIM) || !page_tbl_entry || !(*page_tbl_entry & PTE_P) || ((*page_tbl_entry & perm) != perm)) {
f0102d2d:	83 c4 10             	add    $0x10,%esp
f0102d30:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102d36:	77 10                	ja     f0102d48 <user_mem_check+0x56>
f0102d38:	85 c0                	test   %eax,%eax
f0102d3a:	74 0c                	je     f0102d48 <user_mem_check+0x56>
f0102d3c:	8b 00                	mov    (%eax),%eax
f0102d3e:	a8 01                	test   $0x1,%al
f0102d40:	74 06                	je     f0102d48 <user_mem_check+0x56>
f0102d42:	21 f0                	and    %esi,%eax
f0102d44:	39 c6                	cmp    %eax,%esi
f0102d46:	74 14                	je     f0102d5c <user_mem_check+0x6a>
			user_mem_check_addr = (mem_start<(uint32_t)va?(uint32_t)va:mem_start);
f0102d48:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102d4b:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0102d4f:	89 1d 3c a2 22 f0    	mov    %ebx,0xf022a23c
			return -E_FAULT;
f0102d55:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d5a:	eb 10                	jmp    f0102d6c <user_mem_check+0x7a>
		}
mem_start+=PGSIZE;
f0102d5c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// LAB 3: Your code here.
	
	uint32_t mem_start = (uint32_t) ROUNDDOWN(va, PGSIZE); 
	uint32_t mem_end = (uint32_t) ROUNDUP(va+len, PGSIZE);
	uint32_t i;
	while (mem_start < mem_end) {
f0102d62:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102d65:	72 b8                	jb     f0102d1f <user_mem_check+0x2d>
			return -E_FAULT;
		}
mem_start+=PGSIZE;
	}
	
	return 0;
f0102d67:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d6f:	5b                   	pop    %ebx
f0102d70:	5e                   	pop    %esi
f0102d71:	5f                   	pop    %edi
f0102d72:	5d                   	pop    %ebp
f0102d73:	c3                   	ret    

f0102d74 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102d74:	55                   	push   %ebp
f0102d75:	89 e5                	mov    %esp,%ebp
f0102d77:	53                   	push   %ebx
f0102d78:	83 ec 04             	sub    $0x4,%esp
f0102d7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102d7e:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d81:	83 c8 04             	or     $0x4,%eax
f0102d84:	50                   	push   %eax
f0102d85:	ff 75 10             	pushl  0x10(%ebp)
f0102d88:	ff 75 0c             	pushl  0xc(%ebp)
f0102d8b:	53                   	push   %ebx
f0102d8c:	e8 61 ff ff ff       	call   f0102cf2 <user_mem_check>
f0102d91:	83 c4 10             	add    $0x10,%esp
f0102d94:	85 c0                	test   %eax,%eax
f0102d96:	79 21                	jns    f0102db9 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102d98:	83 ec 04             	sub    $0x4,%esp
f0102d9b:	ff 35 3c a2 22 f0    	pushl  0xf022a23c
f0102da1:	ff 73 48             	pushl  0x48(%ebx)
f0102da4:	68 a4 6b 10 f0       	push   $0xf0106ba4
f0102da9:	e8 d0 08 00 00       	call   f010367e <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102dae:	89 1c 24             	mov    %ebx,(%esp)
f0102db1:	e8 3c 06 00 00       	call   f01033f2 <env_destroy>
f0102db6:	83 c4 10             	add    $0x10,%esp
	}
}
f0102db9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102dbc:	c9                   	leave  
f0102dbd:	c3                   	ret    

f0102dbe <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102dbe:	55                   	push   %ebp
f0102dbf:	89 e5                	mov    %esp,%ebp
f0102dc1:	57                   	push   %edi
f0102dc2:	56                   	push   %esi
f0102dc3:	53                   	push   %ebx
f0102dc4:	83 ec 0c             	sub    $0xc,%esp
f0102dc7:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
f0102dc9:	89 d3                	mov    %edx,%ebx
f0102dcb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102dd1:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102dd8:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (; begin < end; begin += PGSIZE) {
f0102dde:	eb 3d                	jmp    f0102e1d <region_alloc+0x5f>
		struct PageInfo *pg = page_alloc(0);
f0102de0:	83 ec 0c             	sub    $0xc,%esp
f0102de3:	6a 00                	push   $0x0
f0102de5:	e8 30 e1 ff ff       	call   f0100f1a <page_alloc>
		if (!pg) panic("region_alloc failed!");
f0102dea:	83 c4 10             	add    $0x10,%esp
f0102ded:	85 c0                	test   %eax,%eax
f0102def:	75 17                	jne    f0102e08 <region_alloc+0x4a>
f0102df1:	83 ec 04             	sub    $0x4,%esp
f0102df4:	68 d9 6b 10 f0       	push   $0xf0106bd9
f0102df9:	68 12 01 00 00       	push   $0x112
f0102dfe:	68 ee 6b 10 f0       	push   $0xf0106bee
f0102e03:	e8 38 d2 ff ff       	call   f0100040 <_panic>
		page_insert(e->env_pgdir, pg, begin, PTE_W | PTE_U);
f0102e08:	6a 06                	push   $0x6
f0102e0a:	53                   	push   %ebx
f0102e0b:	50                   	push   %eax
f0102e0c:	ff 77 60             	pushl  0x60(%edi)
f0102e0f:	e8 aa e3 ff ff       	call   f01011be <page_insert>
static void
region_alloc(struct Env *e, void *va, size_t len)
{
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
	for (; begin < end; begin += PGSIZE) {
f0102e14:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e1a:	83 c4 10             	add    $0x10,%esp
f0102e1d:	39 f3                	cmp    %esi,%ebx
f0102e1f:	72 bf                	jb     f0102de0 <region_alloc+0x22>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0102e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e24:	5b                   	pop    %ebx
f0102e25:	5e                   	pop    %esi
f0102e26:	5f                   	pop    %edi
f0102e27:	5d                   	pop    %ebp
f0102e28:	c3                   	ret    

f0102e29 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102e29:	55                   	push   %ebp
f0102e2a:	89 e5                	mov    %esp,%ebp
f0102e2c:	56                   	push   %esi
f0102e2d:	53                   	push   %ebx
f0102e2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e31:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102e34:	85 c0                	test   %eax,%eax
f0102e36:	75 1a                	jne    f0102e52 <envid2env+0x29>
		*env_store = curenv;
f0102e38:	e8 69 24 00 00       	call   f01052a6 <cpunum>
f0102e3d:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e40:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0102e46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102e49:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102e4b:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e50:	eb 70                	jmp    f0102ec2 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102e52:	89 c3                	mov    %eax,%ebx
f0102e54:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102e5a:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102e5d:	03 1d 48 a2 22 f0    	add    0xf022a248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102e63:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102e67:	74 05                	je     f0102e6e <envid2env+0x45>
f0102e69:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102e6c:	74 10                	je     f0102e7e <envid2env+0x55>
		*env_store = 0;
f0102e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e71:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102e77:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102e7c:	eb 44                	jmp    f0102ec2 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102e7e:	84 d2                	test   %dl,%dl
f0102e80:	74 36                	je     f0102eb8 <envid2env+0x8f>
f0102e82:	e8 1f 24 00 00       	call   f01052a6 <cpunum>
f0102e87:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e8a:	3b 98 28 b0 22 f0    	cmp    -0xfdd4fd8(%eax),%ebx
f0102e90:	74 26                	je     f0102eb8 <envid2env+0x8f>
f0102e92:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102e95:	e8 0c 24 00 00       	call   f01052a6 <cpunum>
f0102e9a:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e9d:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0102ea3:	3b 70 48             	cmp    0x48(%eax),%esi
f0102ea6:	74 10                	je     f0102eb8 <envid2env+0x8f>
		*env_store = 0;
f0102ea8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102eab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102eb1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102eb6:	eb 0a                	jmp    f0102ec2 <envid2env+0x99>
	}

	*env_store = e;
f0102eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ebb:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102ebd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ec2:	5b                   	pop    %ebx
f0102ec3:	5e                   	pop    %esi
f0102ec4:	5d                   	pop    %ebp
f0102ec5:	c3                   	ret    

f0102ec6 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102ec6:	55                   	push   %ebp
f0102ec7:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102ec9:	b8 20 f3 11 f0       	mov    $0xf011f320,%eax
f0102ece:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102ed1:	b8 23 00 00 00       	mov    $0x23,%eax
f0102ed6:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102ed8:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102eda:	b8 10 00 00 00       	mov    $0x10,%eax
f0102edf:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102ee1:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102ee3:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102ee5:	ea ec 2e 10 f0 08 00 	ljmp   $0x8,$0xf0102eec
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102eec:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ef1:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102ef4:	5d                   	pop    %ebp
f0102ef5:	c3                   	ret    

f0102ef6 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102ef6:	55                   	push   %ebp
f0102ef7:	89 e5                	mov    %esp,%ebp
f0102ef9:	56                   	push   %esi
f0102efa:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1;i >= 0; --i) {
		envs[i].env_id = 0;
f0102efb:	8b 35 48 a2 22 f0    	mov    0xf022a248,%esi
f0102f01:	8b 15 4c a2 22 f0    	mov    0xf022a24c,%edx
f0102f07:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102f0d:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102f10:	89 c1                	mov    %eax,%ecx
f0102f12:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102f19:	89 50 44             	mov    %edx,0x44(%eax)
f0102f1c:	83 e8 7c             	sub    $0x7c,%eax
		 env_free_list = envs+i;
f0102f1f:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1;i >= 0; --i) {
f0102f21:	39 d8                	cmp    %ebx,%eax
f0102f23:	75 eb                	jne    f0102f10 <env_init+0x1a>
f0102f25:	89 35 4c a2 22 f0    	mov    %esi,0xf022a24c
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		 env_free_list = envs+i;
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0102f2b:	e8 96 ff ff ff       	call   f0102ec6 <env_init_percpu>
}
f0102f30:	5b                   	pop    %ebx
f0102f31:	5e                   	pop    %esi
f0102f32:	5d                   	pop    %ebp
f0102f33:	c3                   	ret    

f0102f34 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102f34:	55                   	push   %ebp
f0102f35:	89 e5                	mov    %esp,%ebp
f0102f37:	53                   	push   %ebx
f0102f38:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102f3b:	8b 1d 4c a2 22 f0    	mov    0xf022a24c,%ebx
f0102f41:	85 db                	test   %ebx,%ebx
f0102f43:	0f 84 93 01 00 00    	je     f01030dc <env_alloc+0x1a8>
	 
	struct PageInfo *p = NULL;
	//p = page_alloc(ALLOC_ZERO);
	
	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO))){
f0102f49:	83 ec 0c             	sub    $0xc,%esp
f0102f4c:	6a 01                	push   $0x1
f0102f4e:	e8 c7 df ff ff       	call   f0100f1a <page_alloc>
f0102f53:	83 c4 10             	add    $0x10,%esp
f0102f56:	85 c0                	test   %eax,%eax
f0102f58:	75 16                	jne    f0102f70 <env_alloc+0x3c>
		panic("env_alloc: %e", E_NO_MEM);
f0102f5a:	6a 04                	push   $0x4
f0102f5c:	68 f9 6b 10 f0       	push   $0xf0106bf9
f0102f61:	68 ad 00 00 00       	push   $0xad
f0102f66:	68 ee 6b 10 f0       	push   $0xf0106bee
f0102f6b:	e8 d0 d0 ff ff       	call   f0100040 <_panic>
		return -E_NO_MEM;
	}
	
	p->pp_ref++;
f0102f70:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f75:	2b 05 90 ae 22 f0    	sub    0xf022ae90,%eax
f0102f7b:	c1 f8 03             	sar    $0x3,%eax
f0102f7e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f81:	89 c2                	mov    %eax,%edx
f0102f83:	c1 ea 0c             	shr    $0xc,%edx
f0102f86:	3b 15 88 ae 22 f0    	cmp    0xf022ae88,%edx
f0102f8c:	72 12                	jb     f0102fa0 <env_alloc+0x6c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f8e:	50                   	push   %eax
f0102f8f:	68 64 59 10 f0       	push   $0xf0105964
f0102f94:	6a 58                	push   $0x58
f0102f96:	68 1c 5f 10 f0       	push   $0xf0105f1c
f0102f9b:	e8 a0 d0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102fa0:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = page2kva(p);
f0102fa5:	89 43 60             	mov    %eax,0x60(%ebx)
memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102fa8:	83 ec 04             	sub    $0x4,%esp
f0102fab:	68 00 10 00 00       	push   $0x1000
f0102fb0:	ff 35 8c ae 22 f0    	pushl  0xf022ae8c
f0102fb6:	50                   	push   %eax
f0102fb7:	e8 7c 1d 00 00       	call   f0104d38 <memcpy>

	
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102fbc:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fbf:	83 c4 10             	add    $0x10,%esp
f0102fc2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102fc7:	77 15                	ja     f0102fde <env_alloc+0xaa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fc9:	50                   	push   %eax
f0102fca:	68 88 59 10 f0       	push   $0xf0105988
f0102fcf:	68 b6 00 00 00       	push   $0xb6
f0102fd4:	68 ee 6b 10 f0       	push   $0xf0106bee
f0102fd9:	e8 62 d0 ff ff       	call   f0100040 <_panic>
f0102fde:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102fe4:	83 ca 05             	or     $0x5,%edx
f0102fe7:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102fed:	8b 43 48             	mov    0x48(%ebx),%eax
f0102ff0:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102ff5:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102ffa:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102fff:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0103002:	8b 0d 48 a2 22 f0    	mov    0xf022a248,%ecx
f0103008:	89 da                	mov    %ebx,%edx
f010300a:	29 ca                	sub    %ecx,%edx
f010300c:	c1 fa 02             	sar    $0x2,%edx
f010300f:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103015:	09 d0                	or     %edx,%eax
f0103017:	89 43 48             	mov    %eax,0x48(%ebx)
	cprintf("envs: %x, e: %x, e->env_id: %x\n", envs, e, e->env_id);
f010301a:	50                   	push   %eax
f010301b:	53                   	push   %ebx
f010301c:	51                   	push   %ecx
f010301d:	68 64 6c 10 f0       	push   $0xf0106c64
f0103022:	e8 57 06 00 00       	call   f010367e <cprintf>

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103027:	8b 45 0c             	mov    0xc(%ebp),%eax
f010302a:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010302d:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103034:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010303b:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103042:	83 c4 0c             	add    $0xc,%esp
f0103045:	6a 44                	push   $0x44
f0103047:	6a 00                	push   $0x0
f0103049:	53                   	push   %ebx
f010304a:	e8 34 1c 00 00       	call   f0104c83 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f010304f:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103055:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010305b:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103061:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103068:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f010306e:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103075:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103079:	8b 43 44             	mov    0x44(%ebx),%eax
f010307c:	a3 4c a2 22 f0       	mov    %eax,0xf022a24c
	*newenv_store = e;
f0103081:	8b 45 08             	mov    0x8(%ebp),%eax
f0103084:	89 18                	mov    %ebx,(%eax)

	cprintf("env_id, %x\n", e->env_id);
f0103086:	83 c4 08             	add    $0x8,%esp
f0103089:	ff 73 48             	pushl  0x48(%ebx)
f010308c:	68 07 6c 10 f0       	push   $0xf0106c07
f0103091:	e8 e8 05 00 00       	call   f010367e <cprintf>
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103096:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103099:	e8 08 22 00 00       	call   f01052a6 <cpunum>
f010309e:	6b c0 74             	imul   $0x74,%eax,%eax
f01030a1:	83 c4 10             	add    $0x10,%esp
f01030a4:	ba 00 00 00 00       	mov    $0x0,%edx
f01030a9:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f01030b0:	74 11                	je     f01030c3 <env_alloc+0x18f>
f01030b2:	e8 ef 21 00 00       	call   f01052a6 <cpunum>
f01030b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01030ba:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f01030c0:	8b 50 48             	mov    0x48(%eax),%edx
f01030c3:	83 ec 04             	sub    $0x4,%esp
f01030c6:	53                   	push   %ebx
f01030c7:	52                   	push   %edx
f01030c8:	68 13 6c 10 f0       	push   $0xf0106c13
f01030cd:	e8 ac 05 00 00       	call   f010367e <cprintf>
	return 0;
f01030d2:	83 c4 10             	add    $0x10,%esp
f01030d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01030da:	eb 05                	jmp    f01030e1 <env_alloc+0x1ad>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01030dc:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
	*newenv_store = e;

	cprintf("env_id, %x\n", e->env_id);
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01030e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01030e4:	c9                   	leave  
f01030e5:	c3                   	ret    

f01030e6 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01030e6:	55                   	push   %ebp
f01030e7:	89 e5                	mov    %esp,%ebp
f01030e9:	57                   	push   %edi
f01030ea:	56                   	push   %esi
f01030eb:	53                   	push   %ebx
f01030ec:	83 ec 34             	sub    $0x34,%esp
f01030ef:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *new;
	env_alloc(&new, 0);
f01030f2:	6a 00                	push   $0x0
f01030f4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01030f7:	50                   	push   %eax
f01030f8:	e8 37 fe ff ff       	call   f0102f34 <env_alloc>
cprintf("env .pointer value %x\n", new);
f01030fd:	83 c4 08             	add    $0x8,%esp
f0103100:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103103:	68 28 6c 10 f0       	push   $0xf0106c28
f0103108:	e8 71 05 00 00       	call   f010367e <cprintf>
	load_icode(new, binary);
f010310d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103110:	89 45 d4             	mov    %eax,-0x2c(%ebp)
static void
load_icode(struct Env *e, uint8_t *binary)
{   
    struct Elf *ELFHDR = (struct Elf *) binary;
    struct Proghdr *ph, *eph;
    if (ELFHDR->e_magic != ELF_MAGIC){
f0103113:	83 c4 10             	add    $0x10,%esp
f0103116:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f010311c:	74 17                	je     f0103135 <env_create+0x4f>
        panic("load_icode: ELF_MAGIC not matching");
f010311e:	83 ec 04             	sub    $0x4,%esp
f0103121:	68 84 6c 10 f0       	push   $0xf0106c84
f0103126:	68 39 01 00 00       	push   $0x139
f010312b:	68 ee 6b 10 f0       	push   $0xf0106bee
f0103130:	e8 0b cf ff ff       	call   f0100040 <_panic>

}
    ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0103135:	89 fb                	mov    %edi,%ebx
f0103137:	03 5f 1c             	add    0x1c(%edi),%ebx
    eph = ph + ELFHDR->e_phnum;
f010313a:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f010313e:	c1 e6 05             	shl    $0x5,%esi
f0103141:	01 de                	add    %ebx,%esi
    lcr3(PADDR(e->env_pgdir));
f0103143:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103146:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103149:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010314e:	77 15                	ja     f0103165 <env_create+0x7f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103150:	50                   	push   %eax
f0103151:	68 88 59 10 f0       	push   $0xf0105988
f0103156:	68 3e 01 00 00       	push   $0x13e
f010315b:	68 ee 6b 10 f0       	push   $0xf0106bee
f0103160:	e8 db ce ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103165:	05 00 00 00 10       	add    $0x10000000,%eax
f010316a:	0f 22 d8             	mov    %eax,%cr3
f010316d:	eb 59                	jmp    f01031c8 <env_create+0xe2>
    for(;ph<eph;ph++)
    {
        if(ph->p_type==ELF_PROG_LOAD){
f010316f:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103172:	75 2a                	jne    f010319e <env_create+0xb8>
            if(ph->p_filesz > ph->p_memsz)
f0103174:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103177:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f010317a:	76 17                	jbe    f0103193 <env_create+0xad>
                panic("load_icode: ph->p_filesz > ph->p_memsz");
f010317c:	83 ec 04             	sub    $0x4,%esp
f010317f:	68 a8 6c 10 f0       	push   $0xf0106ca8
f0103184:	68 43 01 00 00       	push   $0x143
f0103189:	68 ee 6b 10 f0       	push   $0xf0106bee
f010318e:	e8 ad ce ff ff       	call   f0100040 <_panic>
            //cprintf("ph=%x",ph);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103193:	8b 53 08             	mov    0x8(%ebx),%edx
f0103196:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103199:	e8 20 fc ff ff       	call   f0102dbe <region_alloc>
            }
            memset((void *)ph->p_va, 0, ph->p_memsz);
f010319e:	83 ec 04             	sub    $0x4,%esp
f01031a1:	ff 73 14             	pushl  0x14(%ebx)
f01031a4:	6a 00                	push   $0x0
f01031a6:	ff 73 08             	pushl  0x8(%ebx)
f01031a9:	e8 d5 1a 00 00       	call   f0104c83 <memset>
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);    }
f01031ae:	83 c4 0c             	add    $0xc,%esp
f01031b1:	ff 73 10             	pushl  0x10(%ebx)
f01031b4:	89 f8                	mov    %edi,%eax
f01031b6:	03 43 04             	add    0x4(%ebx),%eax
f01031b9:	50                   	push   %eax
f01031ba:	ff 73 08             	pushl  0x8(%ebx)
f01031bd:	e8 76 1b 00 00       	call   f0104d38 <memcpy>

}
    ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    eph = ph + ELFHDR->e_phnum;
    lcr3(PADDR(e->env_pgdir));
    for(;ph<eph;ph++)
f01031c2:	83 c3 20             	add    $0x20,%ebx
f01031c5:	83 c4 10             	add    $0x10,%esp
f01031c8:	39 de                	cmp    %ebx,%esi
f01031ca:	77 a3                	ja     f010316f <env_create+0x89>
            //cprintf("ph=%x",ph);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
            }
            memset((void *)ph->p_va, 0, ph->p_memsz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);    }
    lcr3(PADDR(kern_pgdir));
f01031cc:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031d1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031d6:	77 15                	ja     f01031ed <env_create+0x107>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031d8:	50                   	push   %eax
f01031d9:	68 88 59 10 f0       	push   $0xf0105988
f01031de:	68 49 01 00 00       	push   $0x149
f01031e3:	68 ee 6b 10 f0       	push   $0xf0106bee
f01031e8:	e8 53 ce ff ff       	call   f0100040 <_panic>
f01031ed:	05 00 00 00 10       	add    $0x10000000,%eax
f01031f2:	0f 22 d8             	mov    %eax,%cr3
    e->env_tf.tf_eip = ELFHDR->e_entry;
f01031f5:	8b 47 18             	mov    0x18(%edi),%eax
f01031f8:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01031fb:	89 46 30             	mov    %eax,0x30(%esi)
    // Now map one page for the program's initial stack
    // at virtual address USTACKTOP - PGSIZE.
    // LAB 3: Your code here.
    region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f01031fe:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103203:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103208:	89 f0                	mov    %esi,%eax
f010320a:	e8 af fb ff ff       	call   f0102dbe <region_alloc>
	// LAB 3: Your code here.
	struct Env *new;
	env_alloc(&new, 0);
cprintf("env .pointer value %x\n", new);
	load_icode(new, binary);
}
f010320f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103212:	5b                   	pop    %ebx
f0103213:	5e                   	pop    %esi
f0103214:	5f                   	pop    %edi
f0103215:	5d                   	pop    %ebp
f0103216:	c3                   	ret    

f0103217 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103217:	55                   	push   %ebp
f0103218:	89 e5                	mov    %esp,%ebp
f010321a:	57                   	push   %edi
f010321b:	56                   	push   %esi
f010321c:	53                   	push   %ebx
f010321d:	83 ec 1c             	sub    $0x1c,%esp
f0103220:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103223:	e8 7e 20 00 00       	call   f01052a6 <cpunum>
f0103228:	6b c0 74             	imul   $0x74,%eax,%eax
f010322b:	39 b8 28 b0 22 f0    	cmp    %edi,-0xfdd4fd8(%eax)
f0103231:	75 29                	jne    f010325c <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f0103233:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103238:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010323d:	77 15                	ja     f0103254 <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010323f:	50                   	push   %eax
f0103240:	68 88 59 10 f0       	push   $0xf0105988
f0103245:	68 71 01 00 00       	push   $0x171
f010324a:	68 ee 6b 10 f0       	push   $0xf0106bee
f010324f:	e8 ec cd ff ff       	call   f0100040 <_panic>
f0103254:	05 00 00 00 10       	add    $0x10000000,%eax
f0103259:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010325c:	8b 5f 48             	mov    0x48(%edi),%ebx
f010325f:	e8 42 20 00 00       	call   f01052a6 <cpunum>
f0103264:	6b c0 74             	imul   $0x74,%eax,%eax
f0103267:	ba 00 00 00 00       	mov    $0x0,%edx
f010326c:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f0103273:	74 11                	je     f0103286 <env_free+0x6f>
f0103275:	e8 2c 20 00 00       	call   f01052a6 <cpunum>
f010327a:	6b c0 74             	imul   $0x74,%eax,%eax
f010327d:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103283:	8b 50 48             	mov    0x48(%eax),%edx
f0103286:	83 ec 04             	sub    $0x4,%esp
f0103289:	53                   	push   %ebx
f010328a:	52                   	push   %edx
f010328b:	68 3f 6c 10 f0       	push   $0xf0106c3f
f0103290:	e8 e9 03 00 00       	call   f010367e <cprintf>
f0103295:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103298:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010329f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01032a2:	89 d0                	mov    %edx,%eax
f01032a4:	c1 e0 02             	shl    $0x2,%eax
f01032a7:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01032aa:	8b 47 60             	mov    0x60(%edi),%eax
f01032ad:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01032b0:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01032b6:	0f 84 a8 00 00 00    	je     f0103364 <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01032bc:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032c2:	89 f0                	mov    %esi,%eax
f01032c4:	c1 e8 0c             	shr    $0xc,%eax
f01032c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01032ca:	39 05 88 ae 22 f0    	cmp    %eax,0xf022ae88
f01032d0:	77 15                	ja     f01032e7 <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01032d2:	56                   	push   %esi
f01032d3:	68 64 59 10 f0       	push   $0xf0105964
f01032d8:	68 80 01 00 00       	push   $0x180
f01032dd:	68 ee 6b 10 f0       	push   $0xf0106bee
f01032e2:	e8 59 cd ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01032e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01032ea:	c1 e0 16             	shl    $0x16,%eax
f01032ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01032f0:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01032f5:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01032fc:	01 
f01032fd:	74 17                	je     f0103316 <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01032ff:	83 ec 08             	sub    $0x8,%esp
f0103302:	89 d8                	mov    %ebx,%eax
f0103304:	c1 e0 0c             	shl    $0xc,%eax
f0103307:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010330a:	50                   	push   %eax
f010330b:	ff 77 60             	pushl  0x60(%edi)
f010330e:	e8 5d de ff ff       	call   f0101170 <page_remove>
f0103313:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103316:	83 c3 01             	add    $0x1,%ebx
f0103319:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010331f:	75 d4                	jne    f01032f5 <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103321:	8b 47 60             	mov    0x60(%edi),%eax
f0103324:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103327:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010332e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103331:	3b 05 88 ae 22 f0    	cmp    0xf022ae88,%eax
f0103337:	72 14                	jb     f010334d <env_free+0x136>
		panic("pa2page called with invalid pa");
f0103339:	83 ec 04             	sub    $0x4,%esp
f010333c:	68 d8 63 10 f0       	push   $0xf01063d8
f0103341:	6a 51                	push   $0x51
f0103343:	68 1c 5f 10 f0       	push   $0xf0105f1c
f0103348:	e8 f3 cc ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f010334d:	83 ec 0c             	sub    $0xc,%esp
f0103350:	a1 90 ae 22 f0       	mov    0xf022ae90,%eax
f0103355:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103358:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010335b:	50                   	push   %eax
f010335c:	e8 38 dc ff ff       	call   f0100f99 <page_decref>
f0103361:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103364:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103368:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010336b:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103370:	0f 85 29 ff ff ff    	jne    f010329f <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103376:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103379:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010337e:	77 15                	ja     f0103395 <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103380:	50                   	push   %eax
f0103381:	68 88 59 10 f0       	push   $0xf0105988
f0103386:	68 8e 01 00 00       	push   $0x18e
f010338b:	68 ee 6b 10 f0       	push   $0xf0106bee
f0103390:	e8 ab cc ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103395:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010339c:	05 00 00 00 10       	add    $0x10000000,%eax
f01033a1:	c1 e8 0c             	shr    $0xc,%eax
f01033a4:	3b 05 88 ae 22 f0    	cmp    0xf022ae88,%eax
f01033aa:	72 14                	jb     f01033c0 <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f01033ac:	83 ec 04             	sub    $0x4,%esp
f01033af:	68 d8 63 10 f0       	push   $0xf01063d8
f01033b4:	6a 51                	push   $0x51
f01033b6:	68 1c 5f 10 f0       	push   $0xf0105f1c
f01033bb:	e8 80 cc ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f01033c0:	83 ec 0c             	sub    $0xc,%esp
f01033c3:	8b 15 90 ae 22 f0    	mov    0xf022ae90,%edx
f01033c9:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01033cc:	50                   	push   %eax
f01033cd:	e8 c7 db ff ff       	call   f0100f99 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01033d2:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01033d9:	a1 4c a2 22 f0       	mov    0xf022a24c,%eax
f01033de:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01033e1:	89 3d 4c a2 22 f0    	mov    %edi,0xf022a24c
}
f01033e7:	83 c4 10             	add    $0x10,%esp
f01033ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033ed:	5b                   	pop    %ebx
f01033ee:	5e                   	pop    %esi
f01033ef:	5f                   	pop    %edi
f01033f0:	5d                   	pop    %ebp
f01033f1:	c3                   	ret    

f01033f2 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01033f2:	55                   	push   %ebp
f01033f3:	89 e5                	mov    %esp,%ebp
f01033f5:	53                   	push   %ebx
f01033f6:	83 ec 04             	sub    $0x4,%esp
f01033f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01033fc:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103400:	75 19                	jne    f010341b <env_destroy+0x29>
f0103402:	e8 9f 1e 00 00       	call   f01052a6 <cpunum>
f0103407:	6b c0 74             	imul   $0x74,%eax,%eax
f010340a:	3b 98 28 b0 22 f0    	cmp    -0xfdd4fd8(%eax),%ebx
f0103410:	74 09                	je     f010341b <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103412:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103419:	eb 33                	jmp    f010344e <env_destroy+0x5c>
	}

	env_free(e);
f010341b:	83 ec 0c             	sub    $0xc,%esp
f010341e:	53                   	push   %ebx
f010341f:	e8 f3 fd ff ff       	call   f0103217 <env_free>

	if (curenv == e) {
f0103424:	e8 7d 1e 00 00       	call   f01052a6 <cpunum>
f0103429:	6b c0 74             	imul   $0x74,%eax,%eax
f010342c:	83 c4 10             	add    $0x10,%esp
f010342f:	3b 98 28 b0 22 f0    	cmp    -0xfdd4fd8(%eax),%ebx
f0103435:	75 17                	jne    f010344e <env_destroy+0x5c>
		curenv = NULL;
f0103437:	e8 6a 1e 00 00       	call   f01052a6 <cpunum>
f010343c:	6b c0 74             	imul   $0x74,%eax,%eax
f010343f:	c7 80 28 b0 22 f0 00 	movl   $0x0,-0xfdd4fd8(%eax)
f0103446:	00 00 00 
		sched_yield();
f0103449:	e8 4f 0b 00 00       	call   f0103f9d <sched_yield>
	}
}
f010344e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103451:	c9                   	leave  
f0103452:	c3                   	ret    

f0103453 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103453:	55                   	push   %ebp
f0103454:	89 e5                	mov    %esp,%ebp
f0103456:	53                   	push   %ebx
f0103457:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010345a:	e8 47 1e 00 00       	call   f01052a6 <cpunum>
f010345f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103462:	8b 98 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%ebx
f0103468:	e8 39 1e 00 00       	call   f01052a6 <cpunum>
f010346d:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103470:	8b 65 08             	mov    0x8(%ebp),%esp
f0103473:	61                   	popa   
f0103474:	07                   	pop    %es
f0103475:	1f                   	pop    %ds
f0103476:	83 c4 08             	add    $0x8,%esp
f0103479:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010347a:	83 ec 04             	sub    $0x4,%esp
f010347d:	68 55 6c 10 f0       	push   $0xf0106c55
f0103482:	68 c4 01 00 00       	push   $0x1c4
f0103487:	68 ee 6b 10 f0       	push   $0xf0106bee
f010348c:	e8 af cb ff ff       	call   f0100040 <_panic>

f0103491 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103491:	55                   	push   %ebp
f0103492:	89 e5                	mov    %esp,%ebp
f0103494:	53                   	push   %ebx
f0103495:	83 ec 04             	sub    $0x4,%esp
f0103498:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if (e->env_status == ENV_RUNNING)
f010349b:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010349f:	75 07                	jne    f01034a8 <env_run+0x17>
        e->env_status = ENV_RUNNABLE;
f01034a1:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
    curenv = e;
f01034a8:	e8 f9 1d 00 00       	call   f01052a6 <cpunum>
f01034ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01034b0:	89 98 28 b0 22 f0    	mov    %ebx,-0xfdd4fd8(%eax)
    e->env_status = ENV_RUNNING;
f01034b6:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
    e->env_runs++;
f01034bd:	83 43 58 01          	addl   $0x1,0x58(%ebx)

	    lcr3(PADDR(e->env_pgdir));
f01034c1:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034c4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034c9:	77 15                	ja     f01034e0 <env_run+0x4f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034cb:	50                   	push   %eax
f01034cc:	68 88 59 10 f0       	push   $0xf0105988
f01034d1:	68 d6 01 00 00       	push   $0x1d6
f01034d6:	68 ee 6b 10 f0       	push   $0xf0106bee
f01034db:	e8 60 cb ff ff       	call   f0100040 <_panic>
f01034e0:	05 00 00 00 10       	add    $0x10000000,%eax
f01034e5:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01034e8:	83 ec 0c             	sub    $0xc,%esp
f01034eb:	68 c0 f3 11 f0       	push   $0xf011f3c0
f01034f0:	e8 bc 20 00 00       	call   f01055b1 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01034f5:	f3 90                	pause  
unlock_kernel();
    env_pop_tf(&e->env_tf);
f01034f7:	89 1c 24             	mov    %ebx,(%esp)
f01034fa:	e8 54 ff ff ff       	call   f0103453 <env_pop_tf>

f01034ff <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01034ff:	55                   	push   %ebp
f0103500:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103502:	ba 70 00 00 00       	mov    $0x70,%edx
f0103507:	8b 45 08             	mov    0x8(%ebp),%eax
f010350a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010350b:	ba 71 00 00 00       	mov    $0x71,%edx
f0103510:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103511:	0f b6 c0             	movzbl %al,%eax
}
f0103514:	5d                   	pop    %ebp
f0103515:	c3                   	ret    

f0103516 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103516:	55                   	push   %ebp
f0103517:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103519:	ba 70 00 00 00       	mov    $0x70,%edx
f010351e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103521:	ee                   	out    %al,(%dx)
f0103522:	ba 71 00 00 00       	mov    $0x71,%edx
f0103527:	8b 45 0c             	mov    0xc(%ebp),%eax
f010352a:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010352b:	5d                   	pop    %ebp
f010352c:	c3                   	ret    

f010352d <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010352d:	55                   	push   %ebp
f010352e:	89 e5                	mov    %esp,%ebp
f0103530:	56                   	push   %esi
f0103531:	53                   	push   %ebx
f0103532:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103535:	66 a3 a8 f3 11 f0    	mov    %ax,0xf011f3a8
	if (!didinit)
f010353b:	80 3d 50 a2 22 f0 00 	cmpb   $0x0,0xf022a250
f0103542:	74 5a                	je     f010359e <irq_setmask_8259A+0x71>
f0103544:	89 c6                	mov    %eax,%esi
f0103546:	ba 21 00 00 00       	mov    $0x21,%edx
f010354b:	ee                   	out    %al,(%dx)
f010354c:	66 c1 e8 08          	shr    $0x8,%ax
f0103550:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103555:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103556:	83 ec 0c             	sub    $0xc,%esp
f0103559:	68 cf 6c 10 f0       	push   $0xf0106ccf
f010355e:	e8 1b 01 00 00       	call   f010367e <cprintf>
f0103563:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103566:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010356b:	0f b7 f6             	movzwl %si,%esi
f010356e:	f7 d6                	not    %esi
f0103570:	0f a3 de             	bt     %ebx,%esi
f0103573:	73 11                	jae    f0103586 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103575:	83 ec 08             	sub    $0x8,%esp
f0103578:	53                   	push   %ebx
f0103579:	68 90 71 10 f0       	push   $0xf0107190
f010357e:	e8 fb 00 00 00       	call   f010367e <cprintf>
f0103583:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103586:	83 c3 01             	add    $0x1,%ebx
f0103589:	83 fb 10             	cmp    $0x10,%ebx
f010358c:	75 e2                	jne    f0103570 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f010358e:	83 ec 0c             	sub    $0xc,%esp
f0103591:	68 60 62 10 f0       	push   $0xf0106260
f0103596:	e8 e3 00 00 00       	call   f010367e <cprintf>
f010359b:	83 c4 10             	add    $0x10,%esp
}
f010359e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01035a1:	5b                   	pop    %ebx
f01035a2:	5e                   	pop    %esi
f01035a3:	5d                   	pop    %ebp
f01035a4:	c3                   	ret    

f01035a5 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01035a5:	c6 05 50 a2 22 f0 01 	movb   $0x1,0xf022a250
f01035ac:	ba 21 00 00 00       	mov    $0x21,%edx
f01035b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01035b6:	ee                   	out    %al,(%dx)
f01035b7:	ba a1 00 00 00       	mov    $0xa1,%edx
f01035bc:	ee                   	out    %al,(%dx)
f01035bd:	ba 20 00 00 00       	mov    $0x20,%edx
f01035c2:	b8 11 00 00 00       	mov    $0x11,%eax
f01035c7:	ee                   	out    %al,(%dx)
f01035c8:	ba 21 00 00 00       	mov    $0x21,%edx
f01035cd:	b8 20 00 00 00       	mov    $0x20,%eax
f01035d2:	ee                   	out    %al,(%dx)
f01035d3:	b8 04 00 00 00       	mov    $0x4,%eax
f01035d8:	ee                   	out    %al,(%dx)
f01035d9:	b8 03 00 00 00       	mov    $0x3,%eax
f01035de:	ee                   	out    %al,(%dx)
f01035df:	ba a0 00 00 00       	mov    $0xa0,%edx
f01035e4:	b8 11 00 00 00       	mov    $0x11,%eax
f01035e9:	ee                   	out    %al,(%dx)
f01035ea:	ba a1 00 00 00       	mov    $0xa1,%edx
f01035ef:	b8 28 00 00 00       	mov    $0x28,%eax
f01035f4:	ee                   	out    %al,(%dx)
f01035f5:	b8 02 00 00 00       	mov    $0x2,%eax
f01035fa:	ee                   	out    %al,(%dx)
f01035fb:	b8 01 00 00 00       	mov    $0x1,%eax
f0103600:	ee                   	out    %al,(%dx)
f0103601:	ba 20 00 00 00       	mov    $0x20,%edx
f0103606:	b8 68 00 00 00       	mov    $0x68,%eax
f010360b:	ee                   	out    %al,(%dx)
f010360c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103611:	ee                   	out    %al,(%dx)
f0103612:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103617:	b8 68 00 00 00       	mov    $0x68,%eax
f010361c:	ee                   	out    %al,(%dx)
f010361d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103622:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103623:	0f b7 05 a8 f3 11 f0 	movzwl 0xf011f3a8,%eax
f010362a:	66 83 f8 ff          	cmp    $0xffff,%ax
f010362e:	74 13                	je     f0103643 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103630:	55                   	push   %ebp
f0103631:	89 e5                	mov    %esp,%ebp
f0103633:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103636:	0f b7 c0             	movzwl %ax,%eax
f0103639:	50                   	push   %eax
f010363a:	e8 ee fe ff ff       	call   f010352d <irq_setmask_8259A>
f010363f:	83 c4 10             	add    $0x10,%esp
}
f0103642:	c9                   	leave  
f0103643:	f3 c3                	repz ret 

f0103645 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103645:	55                   	push   %ebp
f0103646:	89 e5                	mov    %esp,%ebp
f0103648:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010364b:	ff 75 08             	pushl  0x8(%ebp)
f010364e:	e8 03 d1 ff ff       	call   f0100756 <cputchar>
	*cnt++;
}
f0103653:	83 c4 10             	add    $0x10,%esp
f0103656:	c9                   	leave  
f0103657:	c3                   	ret    

f0103658 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103658:	55                   	push   %ebp
f0103659:	89 e5                	mov    %esp,%ebp
f010365b:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010365e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap); 
f0103665:	ff 75 0c             	pushl  0xc(%ebp)
f0103668:	ff 75 08             	pushl  0x8(%ebp)
f010366b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010366e:	50                   	push   %eax
f010366f:	68 45 36 10 f0       	push   $0xf0103645
f0103674:	e8 5c 0f 00 00       	call   f01045d5 <vprintfmt>
	return cnt;
}
f0103679:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010367c:	c9                   	leave  
f010367d:	c3                   	ret    

f010367e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010367e:	55                   	push   %ebp
f010367f:	89 e5                	mov    %esp,%ebp
f0103681:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103684:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);//vcprintf( const char *format, va_list arg );
f0103687:	50                   	push   %eax
f0103688:	ff 75 08             	pushl  0x8(%ebp)
f010368b:	e8 c8 ff ff ff       	call   f0103658 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103690:	c9                   	leave  
f0103691:	c3                   	ret    

f0103692 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103692:	55                   	push   %ebp
f0103693:	89 e5                	mov    %esp,%ebp
f0103695:	57                   	push   %edi
f0103696:	56                   	push   %esi
f0103697:	53                   	push   %ebx
f0103698:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
int cpuid = thiscpu->cpu_id;
f010369b:	e8 06 1c 00 00       	call   f01052a6 <cpunum>
f01036a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a3:	0f b6 98 20 b0 22 f0 	movzbl -0xfdd4fe0(%eax),%ebx
 


	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpuid * (KSTKSIZE + KSTKGAP);
f01036aa:	e8 f7 1b 00 00       	call   f01052a6 <cpunum>
f01036af:	6b c0 74             	imul   $0x74,%eax,%eax
f01036b2:	89 d9                	mov    %ebx,%ecx
f01036b4:	c1 e1 10             	shl    $0x10,%ecx
f01036b7:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01036bc:	29 ca                	sub    %ecx,%edx
f01036be:	89 90 30 b0 22 f0    	mov    %edx,-0xfdd4fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01036c4:	e8 dd 1b 00 00       	call   f01052a6 <cpunum>
f01036c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01036cc:	66 c7 80 34 b0 22 f0 	movw   $0x10,-0xfdd4fcc(%eax)
f01036d3:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+cpuid] = SEG16(STS_T32A, (uint32_t) (&thiscpu->cpu_ts),
f01036d5:	83 c3 05             	add    $0x5,%ebx
f01036d8:	e8 c9 1b 00 00       	call   f01052a6 <cpunum>
f01036dd:	89 c7                	mov    %eax,%edi
f01036df:	e8 c2 1b 00 00       	call   f01052a6 <cpunum>
f01036e4:	89 c6                	mov    %eax,%esi
f01036e6:	e8 bb 1b 00 00       	call   f01052a6 <cpunum>
f01036eb:	66 c7 04 dd 40 f3 11 	movw   $0x67,-0xfee0cc0(,%ebx,8)
f01036f2:	f0 67 00 
f01036f5:	6b ff 74             	imul   $0x74,%edi,%edi
f01036f8:	81 c7 2c b0 22 f0    	add    $0xf022b02c,%edi
f01036fe:	66 89 3c dd 42 f3 11 	mov    %di,-0xfee0cbe(,%ebx,8)
f0103705:	f0 
f0103706:	6b d6 74             	imul   $0x74,%esi,%edx
f0103709:	81 c2 2c b0 22 f0    	add    $0xf022b02c,%edx
f010370f:	c1 ea 10             	shr    $0x10,%edx
f0103712:	88 14 dd 44 f3 11 f0 	mov    %dl,-0xfee0cbc(,%ebx,8)
f0103719:	c6 04 dd 46 f3 11 f0 	movb   $0x40,-0xfee0cba(,%ebx,8)
f0103720:	40 
f0103721:	6b c0 74             	imul   $0x74,%eax,%eax
f0103724:	05 2c b0 22 f0       	add    $0xf022b02c,%eax
f0103729:	c1 e8 18             	shr    $0x18,%eax
f010372c:	88 04 dd 47 f3 11 f0 	mov    %al,-0xfee0cb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3)+cpuid].sd_s = 0;
f0103733:	c6 04 dd 45 f3 11 f0 	movb   $0x89,-0xfee0cbb(,%ebx,8)
f010373a:	89 
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010373b:	c1 e3 03             	shl    $0x3,%ebx
f010373e:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103741:	b8 ac f3 11 f0       	mov    $0xf011f3ac,%eax
f0103746:	0f 01 18             	lidtl  (%eax)
	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0+(8*cpuid));
	// Load the IDT
	lidt(&idt_pd);
}
f0103749:	83 c4 0c             	add    $0xc,%esp
f010374c:	5b                   	pop    %ebx
f010374d:	5e                   	pop    %esi
f010374e:	5f                   	pop    %edi
f010374f:	5d                   	pop    %ebp
f0103750:	c3                   	ret    

f0103751 <trap_init>:
}


void
trap_init(void)
{
f0103751:	55                   	push   %ebp
f0103752:	89 e5                	mov    %esp,%ebp
f0103754:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[0], 1, GD_KT, i0, 0);
f0103757:	b8 64 3e 10 f0       	mov    $0xf0103e64,%eax
f010375c:	66 a3 60 a2 22 f0    	mov    %ax,0xf022a260
f0103762:	66 c7 05 62 a2 22 f0 	movw   $0x8,0xf022a262
f0103769:	08 00 
f010376b:	c6 05 64 a2 22 f0 00 	movb   $0x0,0xf022a264
f0103772:	c6 05 65 a2 22 f0 8f 	movb   $0x8f,0xf022a265
f0103779:	c1 e8 10             	shr    $0x10,%eax
f010377c:	66 a3 66 a2 22 f0    	mov    %ax,0xf022a266
	    SETGATE(idt[1], 1, GD_KT, i1, 0);
f0103782:	b8 6a 3e 10 f0       	mov    $0xf0103e6a,%eax
f0103787:	66 a3 68 a2 22 f0    	mov    %ax,0xf022a268
f010378d:	66 c7 05 6a a2 22 f0 	movw   $0x8,0xf022a26a
f0103794:	08 00 
f0103796:	c6 05 6c a2 22 f0 00 	movb   $0x0,0xf022a26c
f010379d:	c6 05 6d a2 22 f0 8f 	movb   $0x8f,0xf022a26d
f01037a4:	c1 e8 10             	shr    $0x10,%eax
f01037a7:	66 a3 6e a2 22 f0    	mov    %ax,0xf022a26e
	    SETGATE(idt[3], 1, GD_KT, i3, 3);
f01037ad:	b8 70 3e 10 f0       	mov    $0xf0103e70,%eax
f01037b2:	66 a3 78 a2 22 f0    	mov    %ax,0xf022a278
f01037b8:	66 c7 05 7a a2 22 f0 	movw   $0x8,0xf022a27a
f01037bf:	08 00 
f01037c1:	c6 05 7c a2 22 f0 00 	movb   $0x0,0xf022a27c
f01037c8:	c6 05 7d a2 22 f0 ef 	movb   $0xef,0xf022a27d
f01037cf:	c1 e8 10             	shr    $0x10,%eax
f01037d2:	66 a3 7e a2 22 f0    	mov    %ax,0xf022a27e
	    SETGATE(idt[4], 1, GD_KT, i4, 0);
f01037d8:	b8 76 3e 10 f0       	mov    $0xf0103e76,%eax
f01037dd:	66 a3 80 a2 22 f0    	mov    %ax,0xf022a280
f01037e3:	66 c7 05 82 a2 22 f0 	movw   $0x8,0xf022a282
f01037ea:	08 00 
f01037ec:	c6 05 84 a2 22 f0 00 	movb   $0x0,0xf022a284
f01037f3:	c6 05 85 a2 22 f0 8f 	movb   $0x8f,0xf022a285
f01037fa:	c1 e8 10             	shr    $0x10,%eax
f01037fd:	66 a3 86 a2 22 f0    	mov    %ax,0xf022a286
	    SETGATE(idt[5], 1, GD_KT, i5, 0);
f0103803:	b8 7c 3e 10 f0       	mov    $0xf0103e7c,%eax
f0103808:	66 a3 88 a2 22 f0    	mov    %ax,0xf022a288
f010380e:	66 c7 05 8a a2 22 f0 	movw   $0x8,0xf022a28a
f0103815:	08 00 
f0103817:	c6 05 8c a2 22 f0 00 	movb   $0x0,0xf022a28c
f010381e:	c6 05 8d a2 22 f0 8f 	movb   $0x8f,0xf022a28d
f0103825:	c1 e8 10             	shr    $0x10,%eax
f0103828:	66 a3 8e a2 22 f0    	mov    %ax,0xf022a28e
	    SETGATE(idt[6], 1, GD_KT, i6, 0);
f010382e:	b8 82 3e 10 f0       	mov    $0xf0103e82,%eax
f0103833:	66 a3 90 a2 22 f0    	mov    %ax,0xf022a290
f0103839:	66 c7 05 92 a2 22 f0 	movw   $0x8,0xf022a292
f0103840:	08 00 
f0103842:	c6 05 94 a2 22 f0 00 	movb   $0x0,0xf022a294
f0103849:	c6 05 95 a2 22 f0 8f 	movb   $0x8f,0xf022a295
f0103850:	c1 e8 10             	shr    $0x10,%eax
f0103853:	66 a3 96 a2 22 f0    	mov    %ax,0xf022a296
	    SETGATE(idt[7], 1, GD_KT, i7, 0);
f0103859:	b8 88 3e 10 f0       	mov    $0xf0103e88,%eax
f010385e:	66 a3 98 a2 22 f0    	mov    %ax,0xf022a298
f0103864:	66 c7 05 9a a2 22 f0 	movw   $0x8,0xf022a29a
f010386b:	08 00 
f010386d:	c6 05 9c a2 22 f0 00 	movb   $0x0,0xf022a29c
f0103874:	c6 05 9d a2 22 f0 8f 	movb   $0x8f,0xf022a29d
f010387b:	c1 e8 10             	shr    $0x10,%eax
f010387e:	66 a3 9e a2 22 f0    	mov    %ax,0xf022a29e
	    SETGATE(idt[8], 1, GD_KT, i8, 0);
f0103884:	b8 8e 3e 10 f0       	mov    $0xf0103e8e,%eax
f0103889:	66 a3 a0 a2 22 f0    	mov    %ax,0xf022a2a0
f010388f:	66 c7 05 a2 a2 22 f0 	movw   $0x8,0xf022a2a2
f0103896:	08 00 
f0103898:	c6 05 a4 a2 22 f0 00 	movb   $0x0,0xf022a2a4
f010389f:	c6 05 a5 a2 22 f0 8f 	movb   $0x8f,0xf022a2a5
f01038a6:	c1 e8 10             	shr    $0x10,%eax
f01038a9:	66 a3 a6 a2 22 f0    	mov    %ax,0xf022a2a6
	    SETGATE(idt[9], 1, GD_KT, i9, 0);
f01038af:	b8 92 3e 10 f0       	mov    $0xf0103e92,%eax
f01038b4:	66 a3 a8 a2 22 f0    	mov    %ax,0xf022a2a8
f01038ba:	66 c7 05 aa a2 22 f0 	movw   $0x8,0xf022a2aa
f01038c1:	08 00 
f01038c3:	c6 05 ac a2 22 f0 00 	movb   $0x0,0xf022a2ac
f01038ca:	c6 05 ad a2 22 f0 8f 	movb   $0x8f,0xf022a2ad
f01038d1:	c1 e8 10             	shr    $0x10,%eax
f01038d4:	66 a3 ae a2 22 f0    	mov    %ax,0xf022a2ae
	    SETGATE(idt[10], 1, GD_KT,i10, 0);
f01038da:	b8 98 3e 10 f0       	mov    $0xf0103e98,%eax
f01038df:	66 a3 b0 a2 22 f0    	mov    %ax,0xf022a2b0
f01038e5:	66 c7 05 b2 a2 22 f0 	movw   $0x8,0xf022a2b2
f01038ec:	08 00 
f01038ee:	c6 05 b4 a2 22 f0 00 	movb   $0x0,0xf022a2b4
f01038f5:	c6 05 b5 a2 22 f0 8f 	movb   $0x8f,0xf022a2b5
f01038fc:	c1 e8 10             	shr    $0x10,%eax
f01038ff:	66 a3 b6 a2 22 f0    	mov    %ax,0xf022a2b6
	    SETGATE(idt[11], 1, GD_KT, i11, 0);
f0103905:	b8 9c 3e 10 f0       	mov    $0xf0103e9c,%eax
f010390a:	66 a3 b8 a2 22 f0    	mov    %ax,0xf022a2b8
f0103910:	66 c7 05 ba a2 22 f0 	movw   $0x8,0xf022a2ba
f0103917:	08 00 
f0103919:	c6 05 bc a2 22 f0 00 	movb   $0x0,0xf022a2bc
f0103920:	c6 05 bd a2 22 f0 8f 	movb   $0x8f,0xf022a2bd
f0103927:	c1 e8 10             	shr    $0x10,%eax
f010392a:	66 a3 be a2 22 f0    	mov    %ax,0xf022a2be
	    SETGATE(idt[12], 1, GD_KT, i12, 0);
f0103930:	b8 a0 3e 10 f0       	mov    $0xf0103ea0,%eax
f0103935:	66 a3 c0 a2 22 f0    	mov    %ax,0xf022a2c0
f010393b:	66 c7 05 c2 a2 22 f0 	movw   $0x8,0xf022a2c2
f0103942:	08 00 
f0103944:	c6 05 c4 a2 22 f0 00 	movb   $0x0,0xf022a2c4
f010394b:	c6 05 c5 a2 22 f0 8f 	movb   $0x8f,0xf022a2c5
f0103952:	c1 e8 10             	shr    $0x10,%eax
f0103955:	66 a3 c6 a2 22 f0    	mov    %ax,0xf022a2c6
	    SETGATE(idt[13], 1, GD_KT, i13, 0);
f010395b:	b8 a4 3e 10 f0       	mov    $0xf0103ea4,%eax
f0103960:	66 a3 c8 a2 22 f0    	mov    %ax,0xf022a2c8
f0103966:	66 c7 05 ca a2 22 f0 	movw   $0x8,0xf022a2ca
f010396d:	08 00 
f010396f:	c6 05 cc a2 22 f0 00 	movb   $0x0,0xf022a2cc
f0103976:	c6 05 cd a2 22 f0 8f 	movb   $0x8f,0xf022a2cd
f010397d:	c1 e8 10             	shr    $0x10,%eax
f0103980:	66 a3 ce a2 22 f0    	mov    %ax,0xf022a2ce
	    SETGATE(idt[14], 1, GD_KT, i14, 0);
f0103986:	b8 a8 3e 10 f0       	mov    $0xf0103ea8,%eax
f010398b:	66 a3 d0 a2 22 f0    	mov    %ax,0xf022a2d0
f0103991:	66 c7 05 d2 a2 22 f0 	movw   $0x8,0xf022a2d2
f0103998:	08 00 
f010399a:	c6 05 d4 a2 22 f0 00 	movb   $0x0,0xf022a2d4
f01039a1:	c6 05 d5 a2 22 f0 8f 	movb   $0x8f,0xf022a2d5
f01039a8:	c1 e8 10             	shr    $0x10,%eax
f01039ab:	66 a3 d6 a2 22 f0    	mov    %ax,0xf022a2d6
	    SETGATE(idt[16], 1, GD_KT, i16, 0);
f01039b1:	b8 ac 3e 10 f0       	mov    $0xf0103eac,%eax
f01039b6:	66 a3 e0 a2 22 f0    	mov    %ax,0xf022a2e0
f01039bc:	66 c7 05 e2 a2 22 f0 	movw   $0x8,0xf022a2e2
f01039c3:	08 00 
f01039c5:	c6 05 e4 a2 22 f0 00 	movb   $0x0,0xf022a2e4
f01039cc:	c6 05 e5 a2 22 f0 8f 	movb   $0x8f,0xf022a2e5
f01039d3:	c1 e8 10             	shr    $0x10,%eax
f01039d6:	66 a3 e6 a2 22 f0    	mov    %ax,0xf022a2e6
	    SETGATE(idt[48], 1, GD_KT, i48, 3);	
f01039dc:	b8 b2 3e 10 f0       	mov    $0xf0103eb2,%eax
f01039e1:	66 a3 e0 a3 22 f0    	mov    %ax,0xf022a3e0
f01039e7:	66 c7 05 e2 a3 22 f0 	movw   $0x8,0xf022a3e2
f01039ee:	08 00 
f01039f0:	c6 05 e4 a3 22 f0 00 	movb   $0x0,0xf022a3e4
f01039f7:	c6 05 e5 a3 22 f0 ef 	movb   $0xef,0xf022a3e5
f01039fe:	c1 e8 10             	shr    $0x10,%eax
f0103a01:	66 a3 e6 a3 22 f0    	mov    %ax,0xf022a3e6


	// Per-CPU setup 
	trap_init_percpu();
f0103a07:	e8 86 fc ff ff       	call   f0103692 <trap_init_percpu>
}
f0103a0c:	c9                   	leave  
f0103a0d:	c3                   	ret    

f0103a0e <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103a0e:	55                   	push   %ebp
f0103a0f:	89 e5                	mov    %esp,%ebp
f0103a11:	53                   	push   %ebx
f0103a12:	83 ec 0c             	sub    $0xc,%esp
f0103a15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103a18:	ff 33                	pushl  (%ebx)
f0103a1a:	68 e3 6c 10 f0       	push   $0xf0106ce3
f0103a1f:	e8 5a fc ff ff       	call   f010367e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103a24:	83 c4 08             	add    $0x8,%esp
f0103a27:	ff 73 04             	pushl  0x4(%ebx)
f0103a2a:	68 f2 6c 10 f0       	push   $0xf0106cf2
f0103a2f:	e8 4a fc ff ff       	call   f010367e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103a34:	83 c4 08             	add    $0x8,%esp
f0103a37:	ff 73 08             	pushl  0x8(%ebx)
f0103a3a:	68 01 6d 10 f0       	push   $0xf0106d01
f0103a3f:	e8 3a fc ff ff       	call   f010367e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103a44:	83 c4 08             	add    $0x8,%esp
f0103a47:	ff 73 0c             	pushl  0xc(%ebx)
f0103a4a:	68 10 6d 10 f0       	push   $0xf0106d10
f0103a4f:	e8 2a fc ff ff       	call   f010367e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103a54:	83 c4 08             	add    $0x8,%esp
f0103a57:	ff 73 10             	pushl  0x10(%ebx)
f0103a5a:	68 1f 6d 10 f0       	push   $0xf0106d1f
f0103a5f:	e8 1a fc ff ff       	call   f010367e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103a64:	83 c4 08             	add    $0x8,%esp
f0103a67:	ff 73 14             	pushl  0x14(%ebx)
f0103a6a:	68 2e 6d 10 f0       	push   $0xf0106d2e
f0103a6f:	e8 0a fc ff ff       	call   f010367e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103a74:	83 c4 08             	add    $0x8,%esp
f0103a77:	ff 73 18             	pushl  0x18(%ebx)
f0103a7a:	68 3d 6d 10 f0       	push   $0xf0106d3d
f0103a7f:	e8 fa fb ff ff       	call   f010367e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103a84:	83 c4 08             	add    $0x8,%esp
f0103a87:	ff 73 1c             	pushl  0x1c(%ebx)
f0103a8a:	68 4c 6d 10 f0       	push   $0xf0106d4c
f0103a8f:	e8 ea fb ff ff       	call   f010367e <cprintf>
}
f0103a94:	83 c4 10             	add    $0x10,%esp
f0103a97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103a9a:	c9                   	leave  
f0103a9b:	c3                   	ret    

f0103a9c <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103a9c:	55                   	push   %ebp
f0103a9d:	89 e5                	mov    %esp,%ebp
f0103a9f:	56                   	push   %esi
f0103aa0:	53                   	push   %ebx
f0103aa1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103aa4:	e8 fd 17 00 00       	call   f01052a6 <cpunum>
f0103aa9:	83 ec 04             	sub    $0x4,%esp
f0103aac:	50                   	push   %eax
f0103aad:	53                   	push   %ebx
f0103aae:	68 b0 6d 10 f0       	push   $0xf0106db0
f0103ab3:	e8 c6 fb ff ff       	call   f010367e <cprintf>
	print_regs(&tf->tf_regs);
f0103ab8:	89 1c 24             	mov    %ebx,(%esp)
f0103abb:	e8 4e ff ff ff       	call   f0103a0e <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103ac0:	83 c4 08             	add    $0x8,%esp
f0103ac3:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103ac7:	50                   	push   %eax
f0103ac8:	68 ce 6d 10 f0       	push   $0xf0106dce
f0103acd:	e8 ac fb ff ff       	call   f010367e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103ad2:	83 c4 08             	add    $0x8,%esp
f0103ad5:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103ad9:	50                   	push   %eax
f0103ada:	68 e1 6d 10 f0       	push   $0xf0106de1
f0103adf:	e8 9a fb ff ff       	call   f010367e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ae4:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103ae7:	83 c4 10             	add    $0x10,%esp
f0103aea:	83 f8 13             	cmp    $0x13,%eax
f0103aed:	77 09                	ja     f0103af8 <print_trapframe+0x5c>
		return excnames[trapno];
f0103aef:	8b 14 85 a0 70 10 f0 	mov    -0xfef8f60(,%eax,4),%edx
f0103af6:	eb 1f                	jmp    f0103b17 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103af8:	83 f8 30             	cmp    $0x30,%eax
f0103afb:	74 15                	je     f0103b12 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103afd:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103b00:	83 fa 10             	cmp    $0x10,%edx
f0103b03:	b9 7a 6d 10 f0       	mov    $0xf0106d7a,%ecx
f0103b08:	ba 67 6d 10 f0       	mov    $0xf0106d67,%edx
f0103b0d:	0f 43 d1             	cmovae %ecx,%edx
f0103b10:	eb 05                	jmp    f0103b17 <print_trapframe+0x7b>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103b12:	ba 5b 6d 10 f0       	mov    $0xf0106d5b,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103b17:	83 ec 04             	sub    $0x4,%esp
f0103b1a:	52                   	push   %edx
f0103b1b:	50                   	push   %eax
f0103b1c:	68 f4 6d 10 f0       	push   $0xf0106df4
f0103b21:	e8 58 fb ff ff       	call   f010367e <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103b26:	83 c4 10             	add    $0x10,%esp
f0103b29:	3b 1d 60 aa 22 f0    	cmp    0xf022aa60,%ebx
f0103b2f:	75 1a                	jne    f0103b4b <print_trapframe+0xaf>
f0103b31:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103b35:	75 14                	jne    f0103b4b <print_trapframe+0xaf>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103b37:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103b3a:	83 ec 08             	sub    $0x8,%esp
f0103b3d:	50                   	push   %eax
f0103b3e:	68 06 6e 10 f0       	push   $0xf0106e06
f0103b43:	e8 36 fb ff ff       	call   f010367e <cprintf>
f0103b48:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103b4b:	83 ec 08             	sub    $0x8,%esp
f0103b4e:	ff 73 2c             	pushl  0x2c(%ebx)
f0103b51:	68 15 6e 10 f0       	push   $0xf0106e15
f0103b56:	e8 23 fb ff ff       	call   f010367e <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103b5b:	83 c4 10             	add    $0x10,%esp
f0103b5e:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103b62:	75 49                	jne    f0103bad <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103b64:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103b67:	89 c2                	mov    %eax,%edx
f0103b69:	83 e2 01             	and    $0x1,%edx
f0103b6c:	ba 94 6d 10 f0       	mov    $0xf0106d94,%edx
f0103b71:	b9 89 6d 10 f0       	mov    $0xf0106d89,%ecx
f0103b76:	0f 44 ca             	cmove  %edx,%ecx
f0103b79:	89 c2                	mov    %eax,%edx
f0103b7b:	83 e2 02             	and    $0x2,%edx
f0103b7e:	ba a6 6d 10 f0       	mov    $0xf0106da6,%edx
f0103b83:	be a0 6d 10 f0       	mov    $0xf0106da0,%esi
f0103b88:	0f 45 d6             	cmovne %esi,%edx
f0103b8b:	83 e0 04             	and    $0x4,%eax
f0103b8e:	be fb 6e 10 f0       	mov    $0xf0106efb,%esi
f0103b93:	b8 ab 6d 10 f0       	mov    $0xf0106dab,%eax
f0103b98:	0f 44 c6             	cmove  %esi,%eax
f0103b9b:	51                   	push   %ecx
f0103b9c:	52                   	push   %edx
f0103b9d:	50                   	push   %eax
f0103b9e:	68 23 6e 10 f0       	push   $0xf0106e23
f0103ba3:	e8 d6 fa ff ff       	call   f010367e <cprintf>
f0103ba8:	83 c4 10             	add    $0x10,%esp
f0103bab:	eb 10                	jmp    f0103bbd <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103bad:	83 ec 0c             	sub    $0xc,%esp
f0103bb0:	68 60 62 10 f0       	push   $0xf0106260
f0103bb5:	e8 c4 fa ff ff       	call   f010367e <cprintf>
f0103bba:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103bbd:	83 ec 08             	sub    $0x8,%esp
f0103bc0:	ff 73 30             	pushl  0x30(%ebx)
f0103bc3:	68 32 6e 10 f0       	push   $0xf0106e32
f0103bc8:	e8 b1 fa ff ff       	call   f010367e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103bcd:	83 c4 08             	add    $0x8,%esp
f0103bd0:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103bd4:	50                   	push   %eax
f0103bd5:	68 41 6e 10 f0       	push   $0xf0106e41
f0103bda:	e8 9f fa ff ff       	call   f010367e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103bdf:	83 c4 08             	add    $0x8,%esp
f0103be2:	ff 73 38             	pushl  0x38(%ebx)
f0103be5:	68 54 6e 10 f0       	push   $0xf0106e54
f0103bea:	e8 8f fa ff ff       	call   f010367e <cprintf>
	if ((tf->tf_cs & 3) != 0) 
f0103bef:	83 c4 10             	add    $0x10,%esp
f0103bf2:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103bf6:	74 25                	je     f0103c1d <print_trapframe+0x181>
	{
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103bf8:	83 ec 08             	sub    $0x8,%esp
f0103bfb:	ff 73 3c             	pushl  0x3c(%ebx)
f0103bfe:	68 63 6e 10 f0       	push   $0xf0106e63
f0103c03:	e8 76 fa ff ff       	call   f010367e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103c08:	83 c4 08             	add    $0x8,%esp
f0103c0b:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103c0f:	50                   	push   %eax
f0103c10:	68 72 6e 10 f0       	push   $0xf0106e72
f0103c15:	e8 64 fa ff ff       	call   f010367e <cprintf>
f0103c1a:	83 c4 10             	add    $0x10,%esp
	}
}
f0103c1d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103c20:	5b                   	pop    %ebx
f0103c21:	5e                   	pop    %esi
f0103c22:	5d                   	pop    %ebp
f0103c23:	c3                   	ret    

f0103c24 <trap>:
//>>>>>>> lab3
}

void
trap(struct Trapframe *tf)
{
f0103c24:	55                   	push   %ebp
f0103c25:	89 e5                	mov    %esp,%ebp
f0103c27:	57                   	push   %edi
f0103c28:	56                   	push   %esi
f0103c29:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103c2c:	fc                   	cld    
//<<<<<<< HEAD

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103c2d:	83 3d 80 ae 22 f0 00 	cmpl   $0x0,0xf022ae80
f0103c34:	74 01                	je     f0103c37 <trap+0x13>
		asm volatile("hlt");
f0103c36:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103c37:	e8 6a 16 00 00       	call   f01052a6 <cpunum>
f0103c3c:	6b d0 74             	imul   $0x74,%eax,%edx
f0103c3f:	81 c2 20 b0 22 f0    	add    $0xf022b020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103c45:	b8 01 00 00 00       	mov    $0x1,%eax
f0103c4a:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0103c4e:	83 f8 02             	cmp    $0x2,%eax
f0103c51:	75 10                	jne    f0103c63 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103c53:	83 ec 0c             	sub    $0xc,%esp
f0103c56:	68 c0 f3 11 f0       	push   $0xf011f3c0
f0103c5b:	e8 b4 18 00 00       	call   f0105514 <spin_lock>
f0103c60:	83 c4 10             	add    $0x10,%esp

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103c63:	9c                   	pushf  
f0103c64:	58                   	pop    %eax
	///cprintf("Current ENV Status:%d\nRUNNING VALUE:%d\n",curenv->env_status,ENV_RUNNING);
//>>>>>>> lab3
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103c65:	f6 c4 02             	test   $0x2,%ah
f0103c68:	74 19                	je     f0103c83 <trap+0x5f>
f0103c6a:	68 85 6e 10 f0       	push   $0xf0106e85
f0103c6f:	68 36 5f 10 f0       	push   $0xf0105f36
f0103c74:	68 22 01 00 00       	push   $0x122
f0103c79:	68 9e 6e 10 f0       	push   $0xf0106e9e
f0103c7e:	e8 bd c3 ff ff       	call   f0100040 <_panic>
//<<<<<<< HEAD

//=======
	//print_trapframe(tf);
	
	cprintf("Incoming TRAP frame at %p\n", tf);
f0103c83:	83 ec 08             	sub    $0x8,%esp
f0103c86:	56                   	push   %esi
f0103c87:	68 aa 6e 10 f0       	push   $0xf0106eaa
f0103c8c:	e8 ed f9 ff ff       	call   f010367e <cprintf>
	
//>>>>>>> lab3
	if ((tf->tf_cs & 3) == 3) {
f0103c91:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103c95:	83 e0 03             	and    $0x3,%eax
f0103c98:	83 c4 10             	add    $0x10,%esp
f0103c9b:	66 83 f8 03          	cmp    $0x3,%ax
f0103c9f:	0f 85 a0 00 00 00    	jne    f0103d45 <trap+0x121>
f0103ca5:	83 ec 0c             	sub    $0xc,%esp
f0103ca8:	68 c0 f3 11 f0       	push   $0xf011f3c0
f0103cad:	e8 62 18 00 00       	call   f0105514 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0103cb2:	e8 ef 15 00 00       	call   f01052a6 <cpunum>
f0103cb7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cba:	83 c4 10             	add    $0x10,%esp
f0103cbd:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f0103cc4:	75 19                	jne    f0103cdf <trap+0xbb>
f0103cc6:	68 c5 6e 10 f0       	push   $0xf0106ec5
f0103ccb:	68 36 5f 10 f0       	push   $0xf0105f36
f0103cd0:	68 31 01 00 00       	push   $0x131
f0103cd5:	68 9e 6e 10 f0       	push   $0xf0106e9e
f0103cda:	e8 61 c3 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0103cdf:	e8 c2 15 00 00       	call   f01052a6 <cpunum>
f0103ce4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ce7:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103ced:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103cf1:	75 2d                	jne    f0103d20 <trap+0xfc>
			env_free(curenv);
f0103cf3:	e8 ae 15 00 00       	call   f01052a6 <cpunum>
f0103cf8:	83 ec 0c             	sub    $0xc,%esp
f0103cfb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cfe:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0103d04:	e8 0e f5 ff ff       	call   f0103217 <env_free>
			curenv = NULL;
f0103d09:	e8 98 15 00 00       	call   f01052a6 <cpunum>
f0103d0e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d11:	c7 80 28 b0 22 f0 00 	movl   $0x0,-0xfdd4fd8(%eax)
f0103d18:	00 00 00 
			sched_yield();
f0103d1b:	e8 7d 02 00 00       	call   f0103f9d <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103d20:	e8 81 15 00 00       	call   f01052a6 <cpunum>
f0103d25:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d28:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103d2e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103d33:	89 c7                	mov    %eax,%edi
f0103d35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103d37:	e8 6a 15 00 00       	call   f01052a6 <cpunum>
f0103d3c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d3f:	8b b0 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103d45:	89 35 60 aa 22 f0    	mov    %esi,0xf022aa60
//<<<<<<< HEAD

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103d4b:	83 7e 28 27          	cmpl   $0x27,0x28(%esi)
f0103d4f:	75 1a                	jne    f0103d6b <trap+0x147>
		cprintf("Spurious interrupt on irq 7\n");
f0103d51:	83 ec 0c             	sub    $0xc,%esp
f0103d54:	68 cc 6e 10 f0       	push   $0xf0106ecc
f0103d59:	e8 20 f9 ff ff       	call   f010367e <cprintf>
		print_trapframe(tf);
f0103d5e:	89 34 24             	mov    %esi,(%esp)
f0103d61:	e8 36 fd ff ff       	call   f0103a9c <print_trapframe>
f0103d66:	83 c4 10             	add    $0x10,%esp
f0103d69:	eb 43                	jmp    f0103dae <trap+0x18a>
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103d6b:	83 ec 0c             	sub    $0xc,%esp
f0103d6e:	56                   	push   %esi
f0103d6f:	e8 28 fd ff ff       	call   f0103a9c <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103d74:	83 c4 10             	add    $0x10,%esp
f0103d77:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103d7c:	75 17                	jne    f0103d95 <trap+0x171>
		panic("unhandled trap in kernel");
f0103d7e:	83 ec 04             	sub    $0x4,%esp
f0103d81:	68 e9 6e 10 f0       	push   $0xf0106ee9
f0103d86:	68 e8 00 00 00       	push   $0xe8
f0103d8b:	68 9e 6e 10 f0       	push   $0xf0106e9e
f0103d90:	e8 ab c2 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0103d95:	e8 0c 15 00 00       	call   f01052a6 <cpunum>
f0103d9a:	83 ec 0c             	sub    $0xc,%esp
f0103d9d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103da0:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0103da6:	e8 47 f6 ff ff       	call   f01033f2 <env_destroy>
f0103dab:	83 c4 10             	add    $0x10,%esp
//<<<<<<< HEAD

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103dae:	e8 f3 14 00 00       	call   f01052a6 <cpunum>
f0103db3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103db6:	83 b8 28 b0 22 f0 00 	cmpl   $0x0,-0xfdd4fd8(%eax)
f0103dbd:	74 2a                	je     f0103de9 <trap+0x1c5>
f0103dbf:	e8 e2 14 00 00       	call   f01052a6 <cpunum>
f0103dc4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dc7:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103dcd:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103dd1:	75 16                	jne    f0103de9 <trap+0x1c5>
		env_run(curenv);
f0103dd3:	e8 ce 14 00 00       	call   f01052a6 <cpunum>
f0103dd8:	83 ec 0c             	sub    $0xc,%esp
f0103ddb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dde:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0103de4:	e8 a8 f6 ff ff       	call   f0103491 <env_run>
	else
		sched_yield();
f0103de9:	e8 af 01 00 00       	call   f0103f9d <sched_yield>

f0103dee <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103dee:	55                   	push   %ebp
f0103def:	89 e5                	mov    %esp,%ebp
f0103df1:	57                   	push   %edi
f0103df2:	56                   	push   %esi
f0103df3:	53                   	push   %ebx
f0103df4:	83 ec 0c             	sub    $0xc,%esp
f0103df7:	8b 5d 08             	mov    0x8(%ebp),%ebx

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103dfa:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
if ((tf->tf_cs&3) == 0)
f0103dfd:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103e01:	75 17                	jne    f0103e1a <page_fault_handler+0x2c>
panic("Page Fault occured(Kernel)");
f0103e03:	83 ec 04             	sub    $0x4,%esp
f0103e06:	68 02 6f 10 f0       	push   $0xf0106f02
f0103e0b:	68 66 01 00 00       	push   $0x166
f0103e10:	68 9e 6e 10 f0       	push   $0xf0106e9e
f0103e15:	e8 26 c2 ff ff       	call   f0100040 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103e1a:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103e1d:	e8 84 14 00 00       	call   f01052a6 <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103e22:	57                   	push   %edi
f0103e23:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103e24:	6b c0 74             	imul   $0x74,%eax,%eax
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103e27:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f0103e2d:	ff 70 48             	pushl  0x48(%eax)
f0103e30:	68 60 70 10 f0       	push   $0xf0107060
f0103e35:	e8 44 f8 ff ff       	call   f010367e <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103e3a:	89 1c 24             	mov    %ebx,(%esp)
f0103e3d:	e8 5a fc ff ff       	call   f0103a9c <print_trapframe>
	env_destroy(curenv);
f0103e42:	e8 5f 14 00 00       	call   f01052a6 <cpunum>
f0103e47:	83 c4 04             	add    $0x4,%esp
f0103e4a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e4d:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0103e53:	e8 9a f5 ff ff       	call   f01033f2 <env_destroy>
}
f0103e58:	83 c4 10             	add    $0x10,%esp
f0103e5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103e5e:	5b                   	pop    %ebx
f0103e5f:	5e                   	pop    %esi
f0103e60:	5f                   	pop    %edi
f0103e61:	5d                   	pop    %ebp
f0103e62:	c3                   	ret    
f0103e63:	90                   	nop

f0103e64 <i0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(i0, 0)
f0103e64:	6a 00                	push   $0x0
f0103e66:	6a 00                	push   $0x0
f0103e68:	eb 4e                	jmp    f0103eb8 <_alltraps>

f0103e6a <i1>:
    TRAPHANDLER_NOEC(i1, 1)
f0103e6a:	6a 00                	push   $0x0
f0103e6c:	6a 01                	push   $0x1
f0103e6e:	eb 48                	jmp    f0103eb8 <_alltraps>

f0103e70 <i3>:
    TRAPHANDLER_NOEC(i3, 3)
f0103e70:	6a 00                	push   $0x0
f0103e72:	6a 03                	push   $0x3
f0103e74:	eb 42                	jmp    f0103eb8 <_alltraps>

f0103e76 <i4>:
    TRAPHANDLER_NOEC(i4, 4)
f0103e76:	6a 00                	push   $0x0
f0103e78:	6a 04                	push   $0x4
f0103e7a:	eb 3c                	jmp    f0103eb8 <_alltraps>

f0103e7c <i5>:
    TRAPHANDLER_NOEC(i5, 5)
f0103e7c:	6a 00                	push   $0x0
f0103e7e:	6a 05                	push   $0x5
f0103e80:	eb 36                	jmp    f0103eb8 <_alltraps>

f0103e82 <i6>:
    TRAPHANDLER_NOEC(i6, 6)
f0103e82:	6a 00                	push   $0x0
f0103e84:	6a 06                	push   $0x6
f0103e86:	eb 30                	jmp    f0103eb8 <_alltraps>

f0103e88 <i7>:
    TRAPHANDLER_NOEC(i7, 7)
f0103e88:	6a 00                	push   $0x0
f0103e8a:	6a 07                	push   $0x7
f0103e8c:	eb 2a                	jmp    f0103eb8 <_alltraps>

f0103e8e <i8>:
    TRAPHANDLER(i8, 8)          // Error code pushed
f0103e8e:	6a 08                	push   $0x8
f0103e90:	eb 26                	jmp    f0103eb8 <_alltraps>

f0103e92 <i9>:
    TRAPHANDLER_NOEC(i9, 9)
f0103e92:	6a 00                	push   $0x0
f0103e94:	6a 09                	push   $0x9
f0103e96:	eb 20                	jmp    f0103eb8 <_alltraps>

f0103e98 <i10>:
    TRAPHANDLER(i10, 10)	// Error code pushed
f0103e98:	6a 0a                	push   $0xa
f0103e9a:	eb 1c                	jmp    f0103eb8 <_alltraps>

f0103e9c <i11>:
    TRAPHANDLER(i11, 11)	// Error code pushed
f0103e9c:	6a 0b                	push   $0xb
f0103e9e:	eb 18                	jmp    f0103eb8 <_alltraps>

f0103ea0 <i12>:
    TRAPHANDLER(i12, 12)	// Error code pushed
f0103ea0:	6a 0c                	push   $0xc
f0103ea2:	eb 14                	jmp    f0103eb8 <_alltraps>

f0103ea4 <i13>:
    TRAPHANDLER(i13, 13)	// Error code pushed
f0103ea4:	6a 0d                	push   $0xd
f0103ea6:	eb 10                	jmp    f0103eb8 <_alltraps>

f0103ea8 <i14>:
    TRAPHANDLER(i14, 14)	// Error code pushed
f0103ea8:	6a 0e                	push   $0xe
f0103eaa:	eb 0c                	jmp    f0103eb8 <_alltraps>

f0103eac <i16>:
    TRAPHANDLER_NOEC(i16, 16)
f0103eac:	6a 00                	push   $0x0
f0103eae:	6a 10                	push   $0x10
f0103eb0:	eb 06                	jmp    f0103eb8 <_alltraps>

f0103eb2 <i48>:
    TRAPHANDLER_NOEC(i48, 48) //syscall
f0103eb2:	6a 00                	push   $0x0
f0103eb4:	6a 30                	push   $0x30
f0103eb6:	eb 00                	jmp    f0103eb8 <_alltraps>

f0103eb8 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
    pushl %ds //cpu registers 
f0103eb8:	1e                   	push   %ds
    pushl %es
f0103eb9:	06                   	push   %es
    pushal // General purpose registers
f0103eba:	60                   	pusha  
   movw $ GD_KD, %ax
f0103ebb:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
f0103ebf:	8e d8                	mov    %eax,%ds
  movw %ax, %es
f0103ec1:	8e c0                	mov    %eax,%es
    pushl %esp // Argument for trap()
f0103ec3:	54                   	push   %esp
    call trap
f0103ec4:	e8 5b fd ff ff       	call   f0103c24 <trap>

f0103ec9 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0103ec9:	55                   	push   %ebp
f0103eca:	89 e5                	mov    %esp,%ebp
f0103ecc:	83 ec 08             	sub    $0x8,%esp
f0103ecf:	a1 48 a2 22 f0       	mov    0xf022a248,%eax
f0103ed4:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103ed7:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0103edc:	8b 02                	mov    (%edx),%eax
f0103ede:	83 e8 01             	sub    $0x1,%eax
f0103ee1:	83 f8 02             	cmp    $0x2,%eax
f0103ee4:	76 10                	jbe    f0103ef6 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103ee6:	83 c1 01             	add    $0x1,%ecx
f0103ee9:	83 c2 7c             	add    $0x7c,%edx
f0103eec:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103ef2:	75 e8                	jne    f0103edc <sched_halt+0x13>
f0103ef4:	eb 08                	jmp    f0103efe <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0103ef6:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103efc:	75 1f                	jne    f0103f1d <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0103efe:	83 ec 0c             	sub    $0xc,%esp
f0103f01:	68 f0 70 10 f0       	push   $0xf01070f0
f0103f06:	e8 73 f7 ff ff       	call   f010367e <cprintf>
f0103f0b:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0103f0e:	83 ec 0c             	sub    $0xc,%esp
f0103f11:	6a 00                	push   $0x0
f0103f13:	e8 46 ca ff ff       	call   f010095e <monitor>
f0103f18:	83 c4 10             	add    $0x10,%esp
f0103f1b:	eb f1                	jmp    f0103f0e <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0103f1d:	e8 84 13 00 00       	call   f01052a6 <cpunum>
f0103f22:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f25:	c7 80 28 b0 22 f0 00 	movl   $0x0,-0xfdd4fd8(%eax)
f0103f2c:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0103f2f:	a1 8c ae 22 f0       	mov    0xf022ae8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103f34:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103f39:	77 12                	ja     f0103f4d <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103f3b:	50                   	push   %eax
f0103f3c:	68 88 59 10 f0       	push   $0xf0105988
f0103f41:	6a 3d                	push   $0x3d
f0103f43:	68 19 71 10 f0       	push   $0xf0107119
f0103f48:	e8 f3 c0 ff ff       	call   f0100040 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103f4d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103f52:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0103f55:	e8 4c 13 00 00       	call   f01052a6 <cpunum>
f0103f5a:	6b d0 74             	imul   $0x74,%eax,%edx
f0103f5d:	81 c2 20 b0 22 f0    	add    $0xf022b020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0103f63:	b8 02 00 00 00       	mov    $0x2,%eax
f0103f68:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103f6c:	83 ec 0c             	sub    $0xc,%esp
f0103f6f:	68 c0 f3 11 f0       	push   $0xf011f3c0
f0103f74:	e8 38 16 00 00       	call   f01055b1 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103f79:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0103f7b:	e8 26 13 00 00       	call   f01052a6 <cpunum>
f0103f80:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0103f83:	8b 80 30 b0 22 f0    	mov    -0xfdd4fd0(%eax),%eax
f0103f89:	bd 00 00 00 00       	mov    $0x0,%ebp
f0103f8e:	89 c4                	mov    %eax,%esp
f0103f90:	6a 00                	push   $0x0
f0103f92:	6a 00                	push   $0x0
f0103f94:	fb                   	sti    
f0103f95:	f4                   	hlt    
f0103f96:	eb fd                	jmp    f0103f95 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0103f98:	83 c4 10             	add    $0x10,%esp
f0103f9b:	c9                   	leave  
f0103f9c:	c3                   	ret    

f0103f9d <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0103f9d:	55                   	push   %ebp
f0103f9e:	89 e5                	mov    %esp,%ebp
f0103fa0:	83 ec 08             	sub    $0x8,%esp
	// below to halt the cpu.

	// LAB 4: Your code here.

	// sched_halt never returns
	sched_halt();
f0103fa3:	e8 21 ff ff ff       	call   f0103ec9 <sched_halt>
}
f0103fa8:	c9                   	leave  
f0103fa9:	c3                   	ret    

f0103faa <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103faa:	55                   	push   %ebp
f0103fab:	89 e5                	mov    %esp,%ebp
f0103fad:	53                   	push   %ebx
f0103fae:	83 ec 14             	sub    $0x14,%esp
f0103fb1:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t ret = 0;
	switch (syscallno) {
f0103fb4:	83 f8 01             	cmp    $0x1,%eax
f0103fb7:	74 67                	je     f0104020 <syscall+0x76>
f0103fb9:	83 f8 01             	cmp    $0x1,%eax
f0103fbc:	72 13                	jb     f0103fd1 <syscall+0x27>
f0103fbe:	83 f8 02             	cmp    $0x2,%eax
f0103fc1:	74 69                	je     f010402c <syscall+0x82>
f0103fc3:	83 f8 03             	cmp    $0x3,%eax
f0103fc6:	0f 84 87 00 00 00    	je     f0104053 <syscall+0xa9>
f0103fcc:	e9 0a 01 00 00       	jmp    f01040db <syscall+0x131>
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f0103fd1:	e8 d0 12 00 00       	call   f01052a6 <cpunum>
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f0103fd6:	83 ec 04             	sub    $0x4,%esp
f0103fd9:	6a 01                	push   $0x1
f0103fdb:	8d 55 f4             	lea    -0xc(%ebp),%edx
f0103fde:	52                   	push   %edx
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f0103fdf:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fe2:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f0103fe8:	ff 70 48             	pushl  0x48(%eax)
f0103feb:	e8 39 ee ff ff       	call   f0102e29 <envid2env>
	user_mem_assert(e, s, len, PTE_U);
f0103ff0:	6a 04                	push   $0x4
f0103ff2:	ff 75 10             	pushl  0x10(%ebp)
f0103ff5:	ff 75 0c             	pushl  0xc(%ebp)
f0103ff8:	ff 75 f4             	pushl  -0xc(%ebp)
f0103ffb:	e8 74 ed ff ff       	call   f0102d74 <user_mem_assert>
	

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104000:	83 c4 1c             	add    $0x1c,%esp
f0104003:	ff 75 0c             	pushl  0xc(%ebp)
f0104006:	ff 75 10             	pushl  0x10(%ebp)
f0104009:	68 26 71 10 f0       	push   $0xf0107126
f010400e:	e8 6b f6 ff ff       	call   f010367e <cprintf>
f0104013:	83 c4 10             	add    $0x10,%esp
	// LAB 3: Your code here.
	int32_t ret = 0;
	switch (syscallno) {
		case SYS_cputs: 
			sys_cputs((char*)a1, a2);
			ret = 0;
f0104016:	bb 00 00 00 00       	mov    $0x0,%ebx
f010401b:	e9 c0 00 00 00       	jmp    f01040e0 <syscall+0x136>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104020:	e8 c2 c5 ff ff       	call   f01005e7 <cons_getc>
f0104025:	89 c3                	mov    %eax,%ebx
			sys_cputs((char*)a1, a2);
			ret = 0;
			break;
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
f0104027:	e9 b4 00 00 00       	jmp    f01040e0 <syscall+0x136>
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f010402c:	e8 75 12 00 00       	call   f01052a6 <cpunum>
f0104031:	6b c0 74             	imul   $0x74,%eax,%eax
f0104034:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f010403a:	8b 58 48             	mov    0x48(%eax),%ebx
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
		case SYS_getenvid:
			ret = sys_getenvid();
			cprintf ("ret is %d\n",ret);
f010403d:	83 ec 08             	sub    $0x8,%esp
f0104040:	53                   	push   %ebx
f0104041:	68 2b 71 10 f0       	push   $0xf010712b
f0104046:	e8 33 f6 ff ff       	call   f010367e <cprintf>
			break;
f010404b:	83 c4 10             	add    $0x10,%esp
f010404e:	e9 8d 00 00 00       	jmp    f01040e0 <syscall+0x136>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104053:	83 ec 04             	sub    $0x4,%esp
f0104056:	6a 01                	push   $0x1
f0104058:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010405b:	50                   	push   %eax
f010405c:	ff 75 0c             	pushl  0xc(%ebp)
f010405f:	e8 c5 ed ff ff       	call   f0102e29 <envid2env>
f0104064:	83 c4 10             	add    $0x10,%esp
f0104067:	85 c0                	test   %eax,%eax
f0104069:	78 69                	js     f01040d4 <syscall+0x12a>
		return r;
	if (e == curenv)
f010406b:	e8 36 12 00 00       	call   f01052a6 <cpunum>
f0104070:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104073:	6b c0 74             	imul   $0x74,%eax,%eax
f0104076:	39 90 28 b0 22 f0    	cmp    %edx,-0xfdd4fd8(%eax)
f010407c:	75 23                	jne    f01040a1 <syscall+0xf7>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010407e:	e8 23 12 00 00       	call   f01052a6 <cpunum>
f0104083:	83 ec 08             	sub    $0x8,%esp
f0104086:	6b c0 74             	imul   $0x74,%eax,%eax
f0104089:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f010408f:	ff 70 48             	pushl  0x48(%eax)
f0104092:	68 36 71 10 f0       	push   $0xf0107136
f0104097:	e8 e2 f5 ff ff       	call   f010367e <cprintf>
f010409c:	83 c4 10             	add    $0x10,%esp
f010409f:	eb 25                	jmp    f01040c6 <syscall+0x11c>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01040a1:	8b 5a 48             	mov    0x48(%edx),%ebx
f01040a4:	e8 fd 11 00 00       	call   f01052a6 <cpunum>
f01040a9:	83 ec 04             	sub    $0x4,%esp
f01040ac:	53                   	push   %ebx
f01040ad:	6b c0 74             	imul   $0x74,%eax,%eax
f01040b0:	8b 80 28 b0 22 f0    	mov    -0xfdd4fd8(%eax),%eax
f01040b6:	ff 70 48             	pushl  0x48(%eax)
f01040b9:	68 51 71 10 f0       	push   $0xf0107151
f01040be:	e8 bb f5 ff ff       	call   f010367e <cprintf>
f01040c3:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01040c6:	83 ec 0c             	sub    $0xc,%esp
f01040c9:	ff 75 f4             	pushl  -0xc(%ebp)
f01040cc:	e8 21 f3 ff ff       	call   f01033f2 <env_destroy>
f01040d1:	83 c4 10             	add    $0x10,%esp
			ret = sys_getenvid();
			cprintf ("ret is %d\n",ret);
			break;
		case SYS_env_destroy:
			sys_env_destroy(a1);
			ret = 0;
f01040d4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01040d9:	eb 05                	jmp    f01040e0 <syscall+0x136>
			break;
		default:
			ret = -E_INVAL;
f01040db:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	}
	// cprintf("ret: %x\n", ret);
	return ret;
	panic("syscall not implemented");
}
f01040e0:	89 d8                	mov    %ebx,%eax
f01040e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01040e5:	c9                   	leave  
f01040e6:	c3                   	ret    

f01040e7 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01040e7:	55                   	push   %ebp
f01040e8:	89 e5                	mov    %esp,%ebp
f01040ea:	57                   	push   %edi
f01040eb:	56                   	push   %esi
f01040ec:	53                   	push   %ebx
f01040ed:	83 ec 14             	sub    $0x14,%esp
f01040f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01040f3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01040f6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01040f9:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01040fc:	8b 1a                	mov    (%edx),%ebx
f01040fe:	8b 01                	mov    (%ecx),%eax
f0104100:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104103:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010410a:	eb 7f                	jmp    f010418b <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f010410c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010410f:	01 d8                	add    %ebx,%eax
f0104111:	89 c6                	mov    %eax,%esi
f0104113:	c1 ee 1f             	shr    $0x1f,%esi
f0104116:	01 c6                	add    %eax,%esi
f0104118:	d1 fe                	sar    %esi
f010411a:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010411d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104120:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104123:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104125:	eb 03                	jmp    f010412a <stab_binsearch+0x43>
			m--;
f0104127:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010412a:	39 c3                	cmp    %eax,%ebx
f010412c:	7f 0d                	jg     f010413b <stab_binsearch+0x54>
f010412e:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104132:	83 ea 0c             	sub    $0xc,%edx
f0104135:	39 f9                	cmp    %edi,%ecx
f0104137:	75 ee                	jne    f0104127 <stab_binsearch+0x40>
f0104139:	eb 05                	jmp    f0104140 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010413b:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f010413e:	eb 4b                	jmp    f010418b <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104140:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104143:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104146:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010414a:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010414d:	76 11                	jbe    f0104160 <stab_binsearch+0x79>
			*region_left = m;
f010414f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104152:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104154:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104157:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010415e:	eb 2b                	jmp    f010418b <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104160:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104163:	73 14                	jae    f0104179 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104165:	83 e8 01             	sub    $0x1,%eax
f0104168:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010416b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010416e:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104170:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104177:	eb 12                	jmp    f010418b <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104179:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010417c:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010417e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104182:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104184:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010418b:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010418e:	0f 8e 78 ff ff ff    	jle    f010410c <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104194:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104198:	75 0f                	jne    f01041a9 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010419a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010419d:	8b 00                	mov    (%eax),%eax
f010419f:	83 e8 01             	sub    $0x1,%eax
f01041a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01041a5:	89 06                	mov    %eax,(%esi)
f01041a7:	eb 2c                	jmp    f01041d5 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01041a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01041ac:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01041ae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01041b1:	8b 0e                	mov    (%esi),%ecx
f01041b3:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01041b6:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01041b9:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01041bc:	eb 03                	jmp    f01041c1 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01041be:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01041c1:	39 c8                	cmp    %ecx,%eax
f01041c3:	7e 0b                	jle    f01041d0 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01041c5:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01041c9:	83 ea 0c             	sub    $0xc,%edx
f01041cc:	39 df                	cmp    %ebx,%edi
f01041ce:	75 ee                	jne    f01041be <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01041d0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01041d3:	89 06                	mov    %eax,(%esi)
	}
}
f01041d5:	83 c4 14             	add    $0x14,%esp
f01041d8:	5b                   	pop    %ebx
f01041d9:	5e                   	pop    %esi
f01041da:	5f                   	pop    %edi
f01041db:	5d                   	pop    %ebp
f01041dc:	c3                   	ret    

f01041dd <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01041dd:	55                   	push   %ebp
f01041de:	89 e5                	mov    %esp,%ebp
f01041e0:	57                   	push   %edi
f01041e1:	56                   	push   %esi
f01041e2:	53                   	push   %ebx
f01041e3:	83 ec 3c             	sub    $0x3c,%esp
f01041e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01041e9:	c7 03 69 71 10 f0    	movl   $0xf0107169,(%ebx)
	info->eip_line = 0;
f01041ef:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01041f6:	c7 43 08 69 71 10 f0 	movl   $0xf0107169,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01041fd:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104204:	8b 45 08             	mov    0x8(%ebp),%eax
f0104207:	89 43 10             	mov    %eax,0x10(%ebx)
	info->eip_fn_narg = 0;
f010420a:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104211:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0104216:	0f 87 96 00 00 00    	ja     f01042b2 <debuginfo_eip+0xd5>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f010421c:	e8 85 10 00 00       	call   f01052a6 <cpunum>
f0104221:	6a 04                	push   $0x4
f0104223:	6a 10                	push   $0x10
f0104225:	68 00 00 20 00       	push   $0x200000
f010422a:	6b c0 74             	imul   $0x74,%eax,%eax
f010422d:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0104233:	e8 ba ea ff ff       	call   f0102cf2 <user_mem_check>
f0104238:	83 c4 10             	add    $0x10,%esp
f010423b:	85 c0                	test   %eax,%eax
f010423d:	0f 85 38 02 00 00    	jne    f010447b <debuginfo_eip+0x29e>
		return -1;

		stabs = usd->stabs;
f0104243:	a1 00 00 20 00       	mov    0x200000,%eax
f0104248:	89 c7                	mov    %eax,%edi
f010424a:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = usd->stab_end;
f010424d:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104253:	a1 08 00 20 00       	mov    0x200008,%eax
f0104258:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f010425b:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104261:	89 55 c0             	mov    %edx,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0104264:	e8 3d 10 00 00       	call   f01052a6 <cpunum>
f0104269:	6a 04                	push   $0x4
f010426b:	6a 0c                	push   $0xc
f010426d:	57                   	push   %edi
f010426e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104271:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f0104277:	e8 76 ea ff ff       	call   f0102cf2 <user_mem_check>
f010427c:	83 c4 10             	add    $0x10,%esp
f010427f:	85 c0                	test   %eax,%eax
f0104281:	0f 85 fb 01 00 00    	jne    f0104482 <debuginfo_eip+0x2a5>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0104287:	e8 1a 10 00 00       	call   f01052a6 <cpunum>
f010428c:	6a 04                	push   $0x4
f010428e:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0104291:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104294:	29 ca                	sub    %ecx,%edx
f0104296:	52                   	push   %edx
f0104297:	51                   	push   %ecx
f0104298:	6b c0 74             	imul   $0x74,%eax,%eax
f010429b:	ff b0 28 b0 22 f0    	pushl  -0xfdd4fd8(%eax)
f01042a1:	e8 4c ea ff ff       	call   f0102cf2 <user_mem_check>
f01042a6:	83 c4 10             	add    $0x10,%esp
f01042a9:	85 c0                	test   %eax,%eax
f01042ab:	74 1f                	je     f01042cc <debuginfo_eip+0xef>
f01042ad:	e9 d7 01 00 00       	jmp    f0104489 <debuginfo_eip+0x2ac>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01042b2:	c7 45 c0 a4 44 11 f0 	movl   $0xf01144a4,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01042b9:	c7 45 b8 81 0e 11 f0 	movl   $0xf0110e81,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01042c0:	be 80 0e 11 f0       	mov    $0xf0110e80,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01042c5:	c7 45 bc 58 76 10 f0 	movl   $0xf0107658,-0x44(%ebp)


	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01042cc:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01042cf:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f01042d2:	0f 83 b8 01 00 00    	jae    f0104490 <debuginfo_eip+0x2b3>
f01042d8:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01042dc:	0f 85 b5 01 00 00    	jne    f0104497 <debuginfo_eip+0x2ba>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01042e2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01042e9:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01042ec:	29 fe                	sub    %edi,%esi
f01042ee:	c1 fe 02             	sar    $0x2,%esi
f01042f1:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f01042f7:	83 e8 01             	sub    $0x1,%eax
f01042fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01042fd:	83 ec 08             	sub    $0x8,%esp
f0104300:	ff 75 08             	pushl  0x8(%ebp)
f0104303:	6a 64                	push   $0x64
f0104305:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104308:	89 d1                	mov    %edx,%ecx
f010430a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010430d:	89 f8                	mov    %edi,%eax
f010430f:	e8 d3 fd ff ff       	call   f01040e7 <stab_binsearch>
	if (lfile == 0)
f0104314:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104317:	83 c4 10             	add    $0x10,%esp
f010431a:	85 c0                	test   %eax,%eax
f010431c:	0f 84 7c 01 00 00    	je     f010449e <debuginfo_eip+0x2c1>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104322:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104325:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104328:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010432b:	83 ec 08             	sub    $0x8,%esp
f010432e:	ff 75 08             	pushl  0x8(%ebp)
f0104331:	6a 24                	push   $0x24
f0104333:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104336:	89 d1                	mov    %edx,%ecx
f0104338:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010433b:	89 f8                	mov    %edi,%eax
f010433d:	e8 a5 fd ff ff       	call   f01040e7 <stab_binsearch>

	if (lfun <= rfun) {
f0104342:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104345:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104348:	83 c4 10             	add    $0x10,%esp
f010434b:	39 d0                	cmp    %edx,%eax
f010434d:	7f 52                	jg     f01043a1 <debuginfo_eip+0x1c4>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010434f:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104352:	8d 34 8f             	lea    (%edi,%ecx,4),%esi
f0104355:	8b 3e                	mov    (%esi),%edi
f0104357:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f010435a:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f010435d:	39 cf                	cmp    %ecx,%edi
f010435f:	73 06                	jae    f0104367 <debuginfo_eip+0x18a>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104361:	03 7d b8             	add    -0x48(%ebp),%edi
f0104364:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104367:	8b 4e 08             	mov    0x8(%esi),%ecx
f010436a:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
		// Search within the function definition for the line number.
		lline = lfun;
f010436d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104370:	89 55 d0             	mov    %edx,-0x30(%ebp)
stab_binsearch(stabs, &lline, &rline, N_SLINE, addr); //----------------------------------------> New Insertion
f0104373:	83 ec 08             	sub    $0x8,%esp
f0104376:	8b 45 08             	mov    0x8(%ebp),%eax
f0104379:	29 c8                	sub    %ecx,%eax
f010437b:	50                   	push   %eax
f010437c:	6a 44                	push   $0x44
f010437e:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104381:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104384:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104387:	89 f8                	mov    %edi,%eax
f0104389:	e8 59 fd ff ff       	call   f01040e7 <stab_binsearch>
info->eip_line = stabs[lline].n_desc;
f010438e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104391:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104394:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f0104399:	89 43 04             	mov    %eax,0x4(%ebx)
f010439c:	83 c4 10             	add    $0x10,%esp
f010439f:	eb 12                	jmp    f01043b3 <debuginfo_eip+0x1d6>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01043a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01043a4:	89 43 10             	mov    %eax,0x10(%ebx)
		lline = lfile;
f01043a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01043aa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01043ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01043b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01043b3:	83 ec 08             	sub    $0x8,%esp
f01043b6:	6a 3a                	push   $0x3a
f01043b8:	ff 73 08             	pushl  0x8(%ebx)
f01043bb:	e8 a7 08 00 00       	call   f0104c67 <strfind>
f01043c0:	2b 43 08             	sub    0x8(%ebx),%eax
f01043c3:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01043c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01043c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01043cc:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01043cf:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01043d2:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01043d5:	83 c4 10             	add    $0x10,%esp
f01043d8:	c6 45 c7 00          	movb   $0x0,-0x39(%ebp)
f01043dc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01043df:	eb 0a                	jmp    f01043eb <debuginfo_eip+0x20e>
f01043e1:	83 e8 01             	sub    $0x1,%eax
f01043e4:	83 ea 0c             	sub    $0xc,%edx
f01043e7:	c6 45 c7 01          	movb   $0x1,-0x39(%ebp)
f01043eb:	39 c7                	cmp    %eax,%edi
f01043ed:	7e 05                	jle    f01043f4 <debuginfo_eip+0x217>
f01043ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01043f2:	eb 47                	jmp    f010443b <debuginfo_eip+0x25e>
	       && stabs[lline].n_type != N_SOL
f01043f4:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01043f8:	80 f9 84             	cmp    $0x84,%cl
f01043fb:	75 0e                	jne    f010440b <debuginfo_eip+0x22e>
f01043fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104400:	80 7d c7 00          	cmpb   $0x0,-0x39(%ebp)
f0104404:	74 1c                	je     f0104422 <debuginfo_eip+0x245>
f0104406:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104409:	eb 17                	jmp    f0104422 <debuginfo_eip+0x245>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010440b:	80 f9 64             	cmp    $0x64,%cl
f010440e:	75 d1                	jne    f01043e1 <debuginfo_eip+0x204>
f0104410:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104414:	74 cb                	je     f01043e1 <debuginfo_eip+0x204>
f0104416:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104419:	80 7d c7 00          	cmpb   $0x0,-0x39(%ebp)
f010441d:	74 03                	je     f0104422 <debuginfo_eip+0x245>
f010441f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104422:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104425:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104428:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010442b:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010442e:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104431:	29 f8                	sub    %edi,%eax
f0104433:	39 c2                	cmp    %eax,%edx
f0104435:	73 04                	jae    f010443b <debuginfo_eip+0x25e>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104437:	01 fa                	add    %edi,%edx
f0104439:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010443b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010443e:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104441:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104446:	39 f2                	cmp    %esi,%edx
f0104448:	7d 60                	jge    f01044aa <debuginfo_eip+0x2cd>
		for (lline = lfun + 1;
f010444a:	83 c2 01             	add    $0x1,%edx
f010444d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104450:	89 d0                	mov    %edx,%eax
f0104452:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104455:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104458:	8d 14 97             	lea    (%edi,%edx,4),%edx
f010445b:	eb 04                	jmp    f0104461 <debuginfo_eip+0x284>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010445d:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104461:	39 c6                	cmp    %eax,%esi
f0104463:	7e 40                	jle    f01044a5 <debuginfo_eip+0x2c8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104465:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104469:	83 c0 01             	add    $0x1,%eax
f010446c:	83 c2 0c             	add    $0xc,%edx
f010446f:	80 f9 a0             	cmp    $0xa0,%cl
f0104472:	74 e9                	je     f010445d <debuginfo_eip+0x280>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104474:	b8 00 00 00 00       	mov    $0x0,%eax
f0104479:	eb 2f                	jmp    f01044aa <debuginfo_eip+0x2cd>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
		return -1;
f010447b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104480:	eb 28                	jmp    f01044aa <debuginfo_eip+0x2cd>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;
f0104482:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104487:	eb 21                	jmp    f01044aa <debuginfo_eip+0x2cd>

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
		return -1;
f0104489:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010448e:	eb 1a                	jmp    f01044aa <debuginfo_eip+0x2cd>

	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104490:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104495:	eb 13                	jmp    f01044aa <debuginfo_eip+0x2cd>
f0104497:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010449c:	eb 0c                	jmp    f01044aa <debuginfo_eip+0x2cd>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010449e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01044a3:	eb 05                	jmp    f01044aa <debuginfo_eip+0x2cd>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01044a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01044aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01044ad:	5b                   	pop    %ebx
f01044ae:	5e                   	pop    %esi
f01044af:	5f                   	pop    %edi
f01044b0:	5d                   	pop    %ebp
f01044b1:	c3                   	ret    

f01044b2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01044b2:	55                   	push   %ebp
f01044b3:	89 e5                	mov    %esp,%ebp
f01044b5:	57                   	push   %edi
f01044b6:	56                   	push   %esi
f01044b7:	53                   	push   %ebx
f01044b8:	83 ec 1c             	sub    $0x1c,%esp
f01044bb:	89 c7                	mov    %eax,%edi
f01044bd:	89 d6                	mov    %edx,%esi
f01044bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01044c2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01044c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01044c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01044cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01044ce:	bb 00 00 00 00       	mov    $0x0,%ebx
f01044d3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01044d6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01044d9:	39 d3                	cmp    %edx,%ebx
f01044db:	72 05                	jb     f01044e2 <printnum+0x30>
f01044dd:	39 45 10             	cmp    %eax,0x10(%ebp)
f01044e0:	77 45                	ja     f0104527 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01044e2:	83 ec 0c             	sub    $0xc,%esp
f01044e5:	ff 75 18             	pushl  0x18(%ebp)
f01044e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01044eb:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01044ee:	53                   	push   %ebx
f01044ef:	ff 75 10             	pushl  0x10(%ebp)
f01044f2:	83 ec 08             	sub    $0x8,%esp
f01044f5:	ff 75 e4             	pushl  -0x1c(%ebp)
f01044f8:	ff 75 e0             	pushl  -0x20(%ebp)
f01044fb:	ff 75 dc             	pushl  -0x24(%ebp)
f01044fe:	ff 75 d8             	pushl  -0x28(%ebp)
f0104501:	e8 9a 11 00 00       	call   f01056a0 <__udivdi3>
f0104506:	83 c4 18             	add    $0x18,%esp
f0104509:	52                   	push   %edx
f010450a:	50                   	push   %eax
f010450b:	89 f2                	mov    %esi,%edx
f010450d:	89 f8                	mov    %edi,%eax
f010450f:	e8 9e ff ff ff       	call   f01044b2 <printnum>
f0104514:	83 c4 20             	add    $0x20,%esp
f0104517:	eb 18                	jmp    f0104531 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104519:	83 ec 08             	sub    $0x8,%esp
f010451c:	56                   	push   %esi
f010451d:	ff 75 18             	pushl  0x18(%ebp)
f0104520:	ff d7                	call   *%edi
f0104522:	83 c4 10             	add    $0x10,%esp
f0104525:	eb 03                	jmp    f010452a <printnum+0x78>
f0104527:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010452a:	83 eb 01             	sub    $0x1,%ebx
f010452d:	85 db                	test   %ebx,%ebx
f010452f:	7f e8                	jg     f0104519 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104531:	83 ec 08             	sub    $0x8,%esp
f0104534:	56                   	push   %esi
f0104535:	83 ec 04             	sub    $0x4,%esp
f0104538:	ff 75 e4             	pushl  -0x1c(%ebp)
f010453b:	ff 75 e0             	pushl  -0x20(%ebp)
f010453e:	ff 75 dc             	pushl  -0x24(%ebp)
f0104541:	ff 75 d8             	pushl  -0x28(%ebp)
f0104544:	e8 87 12 00 00       	call   f01057d0 <__umoddi3>
f0104549:	83 c4 14             	add    $0x14,%esp
f010454c:	0f be 80 73 71 10 f0 	movsbl -0xfef8e8d(%eax),%eax
f0104553:	50                   	push   %eax
f0104554:	ff d7                	call   *%edi
}
f0104556:	83 c4 10             	add    $0x10,%esp
f0104559:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010455c:	5b                   	pop    %ebx
f010455d:	5e                   	pop    %esi
f010455e:	5f                   	pop    %edi
f010455f:	5d                   	pop    %ebp
f0104560:	c3                   	ret    

f0104561 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104561:	55                   	push   %ebp
f0104562:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104564:	83 fa 01             	cmp    $0x1,%edx
f0104567:	7e 0e                	jle    f0104577 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104569:	8b 10                	mov    (%eax),%edx
f010456b:	8d 4a 08             	lea    0x8(%edx),%ecx
f010456e:	89 08                	mov    %ecx,(%eax)
f0104570:	8b 02                	mov    (%edx),%eax
f0104572:	8b 52 04             	mov    0x4(%edx),%edx
f0104575:	eb 22                	jmp    f0104599 <getuint+0x38>
	else if (lflag)
f0104577:	85 d2                	test   %edx,%edx
f0104579:	74 10                	je     f010458b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010457b:	8b 10                	mov    (%eax),%edx
f010457d:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104580:	89 08                	mov    %ecx,(%eax)
f0104582:	8b 02                	mov    (%edx),%eax
f0104584:	ba 00 00 00 00       	mov    $0x0,%edx
f0104589:	eb 0e                	jmp    f0104599 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010458b:	8b 10                	mov    (%eax),%edx
f010458d:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104590:	89 08                	mov    %ecx,(%eax)
f0104592:	8b 02                	mov    (%edx),%eax
f0104594:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104599:	5d                   	pop    %ebp
f010459a:	c3                   	ret    

f010459b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010459b:	55                   	push   %ebp
f010459c:	89 e5                	mov    %esp,%ebp
f010459e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01045a1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01045a5:	8b 10                	mov    (%eax),%edx
f01045a7:	3b 50 04             	cmp    0x4(%eax),%edx
f01045aa:	73 0a                	jae    f01045b6 <sprintputch+0x1b>
		*b->buf++ = ch;
f01045ac:	8d 4a 01             	lea    0x1(%edx),%ecx
f01045af:	89 08                	mov    %ecx,(%eax)
f01045b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01045b4:	88 02                	mov    %al,(%edx)
}
f01045b6:	5d                   	pop    %ebp
f01045b7:	c3                   	ret    

f01045b8 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01045b8:	55                   	push   %ebp
f01045b9:	89 e5                	mov    %esp,%ebp
f01045bb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01045be:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01045c1:	50                   	push   %eax
f01045c2:	ff 75 10             	pushl  0x10(%ebp)
f01045c5:	ff 75 0c             	pushl  0xc(%ebp)
f01045c8:	ff 75 08             	pushl  0x8(%ebp)
f01045cb:	e8 05 00 00 00       	call   f01045d5 <vprintfmt>
	va_end(ap);
}
f01045d0:	83 c4 10             	add    $0x10,%esp
f01045d3:	c9                   	leave  
f01045d4:	c3                   	ret    

f01045d5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01045d5:	55                   	push   %ebp
f01045d6:	89 e5                	mov    %esp,%ebp
f01045d8:	57                   	push   %edi
f01045d9:	56                   	push   %esi
f01045da:	53                   	push   %ebx
f01045db:	83 ec 2c             	sub    $0x2c,%esp
f01045de:	8b 75 08             	mov    0x8(%ebp),%esi
f01045e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01045e4:	8b 7d 10             	mov    0x10(%ebp),%edi
f01045e7:	eb 12                	jmp    f01045fb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01045e9:	85 c0                	test   %eax,%eax
f01045eb:	0f 84 cb 03 00 00    	je     f01049bc <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
f01045f1:	83 ec 08             	sub    $0x8,%esp
f01045f4:	53                   	push   %ebx
f01045f5:	50                   	push   %eax
f01045f6:	ff d6                	call   *%esi
f01045f8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01045fb:	83 c7 01             	add    $0x1,%edi
f01045fe:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104602:	83 f8 25             	cmp    $0x25,%eax
f0104605:	75 e2                	jne    f01045e9 <vprintfmt+0x14>
f0104607:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f010460b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104612:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0104619:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104620:	ba 00 00 00 00       	mov    $0x0,%edx
f0104625:	eb 07                	jmp    f010462e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104627:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f010462a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010462e:	8d 47 01             	lea    0x1(%edi),%eax
f0104631:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104634:	0f b6 07             	movzbl (%edi),%eax
f0104637:	0f b6 c8             	movzbl %al,%ecx
f010463a:	83 e8 23             	sub    $0x23,%eax
f010463d:	3c 55                	cmp    $0x55,%al
f010463f:	0f 87 5c 03 00 00    	ja     f01049a1 <vprintfmt+0x3cc>
f0104645:	0f b6 c0             	movzbl %al,%eax
f0104648:	ff 24 85 40 72 10 f0 	jmp    *-0xfef8dc0(,%eax,4)
f010464f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104652:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104656:	eb d6                	jmp    f010462e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104658:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010465b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104660:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104663:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104666:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f010466a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f010466d:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104670:	83 fa 09             	cmp    $0x9,%edx
f0104673:	77 39                	ja     f01046ae <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104675:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104678:	eb e9                	jmp    f0104663 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010467a:	8b 45 14             	mov    0x14(%ebp),%eax
f010467d:	8d 48 04             	lea    0x4(%eax),%ecx
f0104680:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104683:	8b 00                	mov    (%eax),%eax
f0104685:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104688:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010468b:	eb 27                	jmp    f01046b4 <vprintfmt+0xdf>
f010468d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104690:	85 c0                	test   %eax,%eax
f0104692:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104697:	0f 49 c8             	cmovns %eax,%ecx
f010469a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010469d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01046a0:	eb 8c                	jmp    f010462e <vprintfmt+0x59>
f01046a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01046a5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01046ac:	eb 80                	jmp    f010462e <vprintfmt+0x59>
f01046ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01046b1:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
f01046b4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01046b8:	0f 89 70 ff ff ff    	jns    f010462e <vprintfmt+0x59>
				width = precision, precision = -1;
f01046be:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01046c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01046c4:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f01046cb:	e9 5e ff ff ff       	jmp    f010462e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01046d0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01046d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01046d6:	e9 53 ff ff ff       	jmp    f010462e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01046db:	8b 45 14             	mov    0x14(%ebp),%eax
f01046de:	8d 50 04             	lea    0x4(%eax),%edx
f01046e1:	89 55 14             	mov    %edx,0x14(%ebp)
f01046e4:	83 ec 08             	sub    $0x8,%esp
f01046e7:	53                   	push   %ebx
f01046e8:	ff 30                	pushl  (%eax)
f01046ea:	ff d6                	call   *%esi
			break;
f01046ec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01046ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01046f2:	e9 04 ff ff ff       	jmp    f01045fb <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01046f7:	8b 45 14             	mov    0x14(%ebp),%eax
f01046fa:	8d 50 04             	lea    0x4(%eax),%edx
f01046fd:	89 55 14             	mov    %edx,0x14(%ebp)
f0104700:	8b 00                	mov    (%eax),%eax
f0104702:	99                   	cltd   
f0104703:	31 d0                	xor    %edx,%eax
f0104705:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104707:	83 f8 09             	cmp    $0x9,%eax
f010470a:	7f 0b                	jg     f0104717 <vprintfmt+0x142>
f010470c:	8b 14 85 a0 73 10 f0 	mov    -0xfef8c60(,%eax,4),%edx
f0104713:	85 d2                	test   %edx,%edx
f0104715:	75 18                	jne    f010472f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0104717:	50                   	push   %eax
f0104718:	68 8b 71 10 f0       	push   $0xf010718b
f010471d:	53                   	push   %ebx
f010471e:	56                   	push   %esi
f010471f:	e8 94 fe ff ff       	call   f01045b8 <printfmt>
f0104724:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104727:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f010472a:	e9 cc fe ff ff       	jmp    f01045fb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f010472f:	52                   	push   %edx
f0104730:	68 48 5f 10 f0       	push   $0xf0105f48
f0104735:	53                   	push   %ebx
f0104736:	56                   	push   %esi
f0104737:	e8 7c fe ff ff       	call   f01045b8 <printfmt>
f010473c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010473f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104742:	e9 b4 fe ff ff       	jmp    f01045fb <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104747:	8b 45 14             	mov    0x14(%ebp),%eax
f010474a:	8d 50 04             	lea    0x4(%eax),%edx
f010474d:	89 55 14             	mov    %edx,0x14(%ebp)
f0104750:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104752:	85 ff                	test   %edi,%edi
f0104754:	b8 84 71 10 f0       	mov    $0xf0107184,%eax
f0104759:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010475c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104760:	0f 8e 94 00 00 00    	jle    f01047fa <vprintfmt+0x225>
f0104766:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010476a:	0f 84 98 00 00 00    	je     f0104808 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104770:	83 ec 08             	sub    $0x8,%esp
f0104773:	ff 75 c8             	pushl  -0x38(%ebp)
f0104776:	57                   	push   %edi
f0104777:	e8 a1 03 00 00       	call   f0104b1d <strnlen>
f010477c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010477f:	29 c1                	sub    %eax,%ecx
f0104781:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104784:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104787:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010478b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010478e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104791:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104793:	eb 0f                	jmp    f01047a4 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0104795:	83 ec 08             	sub    $0x8,%esp
f0104798:	53                   	push   %ebx
f0104799:	ff 75 e0             	pushl  -0x20(%ebp)
f010479c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010479e:	83 ef 01             	sub    $0x1,%edi
f01047a1:	83 c4 10             	add    $0x10,%esp
f01047a4:	85 ff                	test   %edi,%edi
f01047a6:	7f ed                	jg     f0104795 <vprintfmt+0x1c0>
f01047a8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01047ab:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01047ae:	85 c9                	test   %ecx,%ecx
f01047b0:	b8 00 00 00 00       	mov    $0x0,%eax
f01047b5:	0f 49 c1             	cmovns %ecx,%eax
f01047b8:	29 c1                	sub    %eax,%ecx
f01047ba:	89 75 08             	mov    %esi,0x8(%ebp)
f01047bd:	8b 75 c8             	mov    -0x38(%ebp),%esi
f01047c0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01047c3:	89 cb                	mov    %ecx,%ebx
f01047c5:	eb 4d                	jmp    f0104814 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01047c7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01047cb:	74 1b                	je     f01047e8 <vprintfmt+0x213>
f01047cd:	0f be c0             	movsbl %al,%eax
f01047d0:	83 e8 20             	sub    $0x20,%eax
f01047d3:	83 f8 5e             	cmp    $0x5e,%eax
f01047d6:	76 10                	jbe    f01047e8 <vprintfmt+0x213>
					putch('?', putdat);
f01047d8:	83 ec 08             	sub    $0x8,%esp
f01047db:	ff 75 0c             	pushl  0xc(%ebp)
f01047de:	6a 3f                	push   $0x3f
f01047e0:	ff 55 08             	call   *0x8(%ebp)
f01047e3:	83 c4 10             	add    $0x10,%esp
f01047e6:	eb 0d                	jmp    f01047f5 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f01047e8:	83 ec 08             	sub    $0x8,%esp
f01047eb:	ff 75 0c             	pushl  0xc(%ebp)
f01047ee:	52                   	push   %edx
f01047ef:	ff 55 08             	call   *0x8(%ebp)
f01047f2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01047f5:	83 eb 01             	sub    $0x1,%ebx
f01047f8:	eb 1a                	jmp    f0104814 <vprintfmt+0x23f>
f01047fa:	89 75 08             	mov    %esi,0x8(%ebp)
f01047fd:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0104800:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104803:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104806:	eb 0c                	jmp    f0104814 <vprintfmt+0x23f>
f0104808:	89 75 08             	mov    %esi,0x8(%ebp)
f010480b:	8b 75 c8             	mov    -0x38(%ebp),%esi
f010480e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104811:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104814:	83 c7 01             	add    $0x1,%edi
f0104817:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010481b:	0f be d0             	movsbl %al,%edx
f010481e:	85 d2                	test   %edx,%edx
f0104820:	74 23                	je     f0104845 <vprintfmt+0x270>
f0104822:	85 f6                	test   %esi,%esi
f0104824:	78 a1                	js     f01047c7 <vprintfmt+0x1f2>
f0104826:	83 ee 01             	sub    $0x1,%esi
f0104829:	79 9c                	jns    f01047c7 <vprintfmt+0x1f2>
f010482b:	89 df                	mov    %ebx,%edi
f010482d:	8b 75 08             	mov    0x8(%ebp),%esi
f0104830:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104833:	eb 18                	jmp    f010484d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104835:	83 ec 08             	sub    $0x8,%esp
f0104838:	53                   	push   %ebx
f0104839:	6a 20                	push   $0x20
f010483b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010483d:	83 ef 01             	sub    $0x1,%edi
f0104840:	83 c4 10             	add    $0x10,%esp
f0104843:	eb 08                	jmp    f010484d <vprintfmt+0x278>
f0104845:	89 df                	mov    %ebx,%edi
f0104847:	8b 75 08             	mov    0x8(%ebp),%esi
f010484a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010484d:	85 ff                	test   %edi,%edi
f010484f:	7f e4                	jg     f0104835 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104851:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104854:	e9 a2 fd ff ff       	jmp    f01045fb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104859:	83 fa 01             	cmp    $0x1,%edx
f010485c:	7e 16                	jle    f0104874 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f010485e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104861:	8d 50 08             	lea    0x8(%eax),%edx
f0104864:	89 55 14             	mov    %edx,0x14(%ebp)
f0104867:	8b 50 04             	mov    0x4(%eax),%edx
f010486a:	8b 00                	mov    (%eax),%eax
f010486c:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010486f:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0104872:	eb 32                	jmp    f01048a6 <vprintfmt+0x2d1>
	else if (lflag)
f0104874:	85 d2                	test   %edx,%edx
f0104876:	74 18                	je     f0104890 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0104878:	8b 45 14             	mov    0x14(%ebp),%eax
f010487b:	8d 50 04             	lea    0x4(%eax),%edx
f010487e:	89 55 14             	mov    %edx,0x14(%ebp)
f0104881:	8b 00                	mov    (%eax),%eax
f0104883:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0104886:	89 c1                	mov    %eax,%ecx
f0104888:	c1 f9 1f             	sar    $0x1f,%ecx
f010488b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f010488e:	eb 16                	jmp    f01048a6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0104890:	8b 45 14             	mov    0x14(%ebp),%eax
f0104893:	8d 50 04             	lea    0x4(%eax),%edx
f0104896:	89 55 14             	mov    %edx,0x14(%ebp)
f0104899:	8b 00                	mov    (%eax),%eax
f010489b:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010489e:	89 c1                	mov    %eax,%ecx
f01048a0:	c1 f9 1f             	sar    $0x1f,%ecx
f01048a3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01048a6:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01048a9:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01048ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01048af:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01048b2:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01048b7:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f01048bb:	0f 89 a8 00 00 00    	jns    f0104969 <vprintfmt+0x394>
				putch('-', putdat);
f01048c1:	83 ec 08             	sub    $0x8,%esp
f01048c4:	53                   	push   %ebx
f01048c5:	6a 2d                	push   $0x2d
f01048c7:	ff d6                	call   *%esi
				num = -(long long) num;
f01048c9:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01048cc:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01048cf:	f7 d8                	neg    %eax
f01048d1:	83 d2 00             	adc    $0x0,%edx
f01048d4:	f7 da                	neg    %edx
f01048d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01048d9:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01048dc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01048df:	b8 0a 00 00 00       	mov    $0xa,%eax
f01048e4:	e9 80 00 00 00       	jmp    f0104969 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01048e9:	8d 45 14             	lea    0x14(%ebp),%eax
f01048ec:	e8 70 fc ff ff       	call   f0104561 <getuint>
f01048f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01048f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
f01048f7:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01048fc:	eb 6b                	jmp    f0104969 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f01048fe:	8d 45 14             	lea    0x14(%ebp),%eax
f0104901:	e8 5b fc ff ff       	call   f0104561 <getuint>
f0104906:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104909:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
f010490c:	6a 04                	push   $0x4
f010490e:	6a 03                	push   $0x3
f0104910:	6a 01                	push   $0x1
f0104912:	68 94 71 10 f0       	push   $0xf0107194
f0104917:	e8 62 ed ff ff       	call   f010367e <cprintf>
			goto number;
f010491c:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
f010491f:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
f0104924:	eb 43                	jmp    f0104969 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
f0104926:	83 ec 08             	sub    $0x8,%esp
f0104929:	53                   	push   %ebx
f010492a:	6a 30                	push   $0x30
f010492c:	ff d6                	call   *%esi
			putch('x', putdat);
f010492e:	83 c4 08             	add    $0x8,%esp
f0104931:	53                   	push   %ebx
f0104932:	6a 78                	push   $0x78
f0104934:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104936:	8b 45 14             	mov    0x14(%ebp),%eax
f0104939:	8d 50 04             	lea    0x4(%eax),%edx
f010493c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010493f:	8b 00                	mov    (%eax),%eax
f0104941:	ba 00 00 00 00       	mov    $0x0,%edx
f0104946:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104949:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010494c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010494f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0104954:	eb 13                	jmp    f0104969 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104956:	8d 45 14             	lea    0x14(%ebp),%eax
f0104959:	e8 03 fc ff ff       	call   f0104561 <getuint>
f010495e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104961:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
f0104964:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104969:	83 ec 0c             	sub    $0xc,%esp
f010496c:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
f0104970:	52                   	push   %edx
f0104971:	ff 75 e0             	pushl  -0x20(%ebp)
f0104974:	50                   	push   %eax
f0104975:	ff 75 dc             	pushl  -0x24(%ebp)
f0104978:	ff 75 d8             	pushl  -0x28(%ebp)
f010497b:	89 da                	mov    %ebx,%edx
f010497d:	89 f0                	mov    %esi,%eax
f010497f:	e8 2e fb ff ff       	call   f01044b2 <printnum>

			break;
f0104984:	83 c4 20             	add    $0x20,%esp
f0104987:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010498a:	e9 6c fc ff ff       	jmp    f01045fb <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010498f:	83 ec 08             	sub    $0x8,%esp
f0104992:	53                   	push   %ebx
f0104993:	51                   	push   %ecx
f0104994:	ff d6                	call   *%esi
			break;
f0104996:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104999:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010499c:	e9 5a fc ff ff       	jmp    f01045fb <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01049a1:	83 ec 08             	sub    $0x8,%esp
f01049a4:	53                   	push   %ebx
f01049a5:	6a 25                	push   $0x25
f01049a7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01049a9:	83 c4 10             	add    $0x10,%esp
f01049ac:	eb 03                	jmp    f01049b1 <vprintfmt+0x3dc>
f01049ae:	83 ef 01             	sub    $0x1,%edi
f01049b1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01049b5:	75 f7                	jne    f01049ae <vprintfmt+0x3d9>
f01049b7:	e9 3f fc ff ff       	jmp    f01045fb <vprintfmt+0x26>
			break;
		}

	}

}
f01049bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01049bf:	5b                   	pop    %ebx
f01049c0:	5e                   	pop    %esi
f01049c1:	5f                   	pop    %edi
f01049c2:	5d                   	pop    %ebp
f01049c3:	c3                   	ret    

f01049c4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01049c4:	55                   	push   %ebp
f01049c5:	89 e5                	mov    %esp,%ebp
f01049c7:	83 ec 18             	sub    $0x18,%esp
f01049ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01049cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01049d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01049d3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01049d7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01049da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01049e1:	85 c0                	test   %eax,%eax
f01049e3:	74 26                	je     f0104a0b <vsnprintf+0x47>
f01049e5:	85 d2                	test   %edx,%edx
f01049e7:	7e 22                	jle    f0104a0b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01049e9:	ff 75 14             	pushl  0x14(%ebp)
f01049ec:	ff 75 10             	pushl  0x10(%ebp)
f01049ef:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01049f2:	50                   	push   %eax
f01049f3:	68 9b 45 10 f0       	push   $0xf010459b
f01049f8:	e8 d8 fb ff ff       	call   f01045d5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01049fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104a00:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104a06:	83 c4 10             	add    $0x10,%esp
f0104a09:	eb 05                	jmp    f0104a10 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104a0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104a10:	c9                   	leave  
f0104a11:	c3                   	ret    

f0104a12 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104a12:	55                   	push   %ebp
f0104a13:	89 e5                	mov    %esp,%ebp
f0104a15:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104a18:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104a1b:	50                   	push   %eax
f0104a1c:	ff 75 10             	pushl  0x10(%ebp)
f0104a1f:	ff 75 0c             	pushl  0xc(%ebp)
f0104a22:	ff 75 08             	pushl  0x8(%ebp)
f0104a25:	e8 9a ff ff ff       	call   f01049c4 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104a2a:	c9                   	leave  
f0104a2b:	c3                   	ret    

f0104a2c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104a2c:	55                   	push   %ebp
f0104a2d:	89 e5                	mov    %esp,%ebp
f0104a2f:	57                   	push   %edi
f0104a30:	56                   	push   %esi
f0104a31:	53                   	push   %ebx
f0104a32:	83 ec 0c             	sub    $0xc,%esp
f0104a35:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104a38:	85 c0                	test   %eax,%eax
f0104a3a:	74 11                	je     f0104a4d <readline+0x21>
		cprintf("%s", prompt);
f0104a3c:	83 ec 08             	sub    $0x8,%esp
f0104a3f:	50                   	push   %eax
f0104a40:	68 48 5f 10 f0       	push   $0xf0105f48
f0104a45:	e8 34 ec ff ff       	call   f010367e <cprintf>
f0104a4a:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104a4d:	83 ec 0c             	sub    $0xc,%esp
f0104a50:	6a 00                	push   $0x0
f0104a52:	e8 20 bd ff ff       	call   f0100777 <iscons>
f0104a57:	89 c7                	mov    %eax,%edi
f0104a59:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104a5c:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104a61:	e8 00 bd ff ff       	call   f0100766 <getchar>
f0104a66:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104a68:	85 c0                	test   %eax,%eax
f0104a6a:	79 18                	jns    f0104a84 <readline+0x58>
			cprintf("read error: %e\n", c);
f0104a6c:	83 ec 08             	sub    $0x8,%esp
f0104a6f:	50                   	push   %eax
f0104a70:	68 c8 73 10 f0       	push   $0xf01073c8
f0104a75:	e8 04 ec ff ff       	call   f010367e <cprintf>
			return NULL;
f0104a7a:	83 c4 10             	add    $0x10,%esp
f0104a7d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a82:	eb 79                	jmp    f0104afd <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104a84:	83 f8 08             	cmp    $0x8,%eax
f0104a87:	0f 94 c2             	sete   %dl
f0104a8a:	83 f8 7f             	cmp    $0x7f,%eax
f0104a8d:	0f 94 c0             	sete   %al
f0104a90:	08 c2                	or     %al,%dl
f0104a92:	74 1a                	je     f0104aae <readline+0x82>
f0104a94:	85 f6                	test   %esi,%esi
f0104a96:	7e 16                	jle    f0104aae <readline+0x82>
			if (echoing)
f0104a98:	85 ff                	test   %edi,%edi
f0104a9a:	74 0d                	je     f0104aa9 <readline+0x7d>
				cputchar('\b');
f0104a9c:	83 ec 0c             	sub    $0xc,%esp
f0104a9f:	6a 08                	push   $0x8
f0104aa1:	e8 b0 bc ff ff       	call   f0100756 <cputchar>
f0104aa6:	83 c4 10             	add    $0x10,%esp
			i--;
f0104aa9:	83 ee 01             	sub    $0x1,%esi
f0104aac:	eb b3                	jmp    f0104a61 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104aae:	83 fb 1f             	cmp    $0x1f,%ebx
f0104ab1:	7e 23                	jle    f0104ad6 <readline+0xaa>
f0104ab3:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104ab9:	7f 1b                	jg     f0104ad6 <readline+0xaa>
			if (echoing)
f0104abb:	85 ff                	test   %edi,%edi
f0104abd:	74 0c                	je     f0104acb <readline+0x9f>
				cputchar(c);
f0104abf:	83 ec 0c             	sub    $0xc,%esp
f0104ac2:	53                   	push   %ebx
f0104ac3:	e8 8e bc ff ff       	call   f0100756 <cputchar>
f0104ac8:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104acb:	88 9e 80 aa 22 f0    	mov    %bl,-0xfdd5580(%esi)
f0104ad1:	8d 76 01             	lea    0x1(%esi),%esi
f0104ad4:	eb 8b                	jmp    f0104a61 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0104ad6:	83 fb 0a             	cmp    $0xa,%ebx
f0104ad9:	74 05                	je     f0104ae0 <readline+0xb4>
f0104adb:	83 fb 0d             	cmp    $0xd,%ebx
f0104ade:	75 81                	jne    f0104a61 <readline+0x35>
			if (echoing)
f0104ae0:	85 ff                	test   %edi,%edi
f0104ae2:	74 0d                	je     f0104af1 <readline+0xc5>
				cputchar('\n');
f0104ae4:	83 ec 0c             	sub    $0xc,%esp
f0104ae7:	6a 0a                	push   $0xa
f0104ae9:	e8 68 bc ff ff       	call   f0100756 <cputchar>
f0104aee:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0104af1:	c6 86 80 aa 22 f0 00 	movb   $0x0,-0xfdd5580(%esi)
			return buf;
f0104af8:	b8 80 aa 22 f0       	mov    $0xf022aa80,%eax
		}
	}
}
f0104afd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104b00:	5b                   	pop    %ebx
f0104b01:	5e                   	pop    %esi
f0104b02:	5f                   	pop    %edi
f0104b03:	5d                   	pop    %ebp
f0104b04:	c3                   	ret    

f0104b05 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104b05:	55                   	push   %ebp
f0104b06:	89 e5                	mov    %esp,%ebp
f0104b08:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104b0b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b10:	eb 03                	jmp    f0104b15 <strlen+0x10>
		n++;
f0104b12:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104b15:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104b19:	75 f7                	jne    f0104b12 <strlen+0xd>
		n++;
	return n;
}
f0104b1b:	5d                   	pop    %ebp
f0104b1c:	c3                   	ret    

f0104b1d <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104b1d:	55                   	push   %ebp
f0104b1e:	89 e5                	mov    %esp,%ebp
f0104b20:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104b23:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104b26:	ba 00 00 00 00       	mov    $0x0,%edx
f0104b2b:	eb 03                	jmp    f0104b30 <strnlen+0x13>
		n++;
f0104b2d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104b30:	39 c2                	cmp    %eax,%edx
f0104b32:	74 08                	je     f0104b3c <strnlen+0x1f>
f0104b34:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0104b38:	75 f3                	jne    f0104b2d <strnlen+0x10>
f0104b3a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0104b3c:	5d                   	pop    %ebp
f0104b3d:	c3                   	ret    

f0104b3e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104b3e:	55                   	push   %ebp
f0104b3f:	89 e5                	mov    %esp,%ebp
f0104b41:	53                   	push   %ebx
f0104b42:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104b48:	89 c2                	mov    %eax,%edx
f0104b4a:	83 c2 01             	add    $0x1,%edx
f0104b4d:	83 c1 01             	add    $0x1,%ecx
f0104b50:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0104b54:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104b57:	84 db                	test   %bl,%bl
f0104b59:	75 ef                	jne    f0104b4a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104b5b:	5b                   	pop    %ebx
f0104b5c:	5d                   	pop    %ebp
f0104b5d:	c3                   	ret    

f0104b5e <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104b5e:	55                   	push   %ebp
f0104b5f:	89 e5                	mov    %esp,%ebp
f0104b61:	53                   	push   %ebx
f0104b62:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104b65:	53                   	push   %ebx
f0104b66:	e8 9a ff ff ff       	call   f0104b05 <strlen>
f0104b6b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104b6e:	ff 75 0c             	pushl  0xc(%ebp)
f0104b71:	01 d8                	add    %ebx,%eax
f0104b73:	50                   	push   %eax
f0104b74:	e8 c5 ff ff ff       	call   f0104b3e <strcpy>
	return dst;
}
f0104b79:	89 d8                	mov    %ebx,%eax
f0104b7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104b7e:	c9                   	leave  
f0104b7f:	c3                   	ret    

f0104b80 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104b80:	55                   	push   %ebp
f0104b81:	89 e5                	mov    %esp,%ebp
f0104b83:	56                   	push   %esi
f0104b84:	53                   	push   %ebx
f0104b85:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104b8b:	89 f3                	mov    %esi,%ebx
f0104b8d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104b90:	89 f2                	mov    %esi,%edx
f0104b92:	eb 0f                	jmp    f0104ba3 <strncpy+0x23>
		*dst++ = *src;
f0104b94:	83 c2 01             	add    $0x1,%edx
f0104b97:	0f b6 01             	movzbl (%ecx),%eax
f0104b9a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104b9d:	80 39 01             	cmpb   $0x1,(%ecx)
f0104ba0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104ba3:	39 da                	cmp    %ebx,%edx
f0104ba5:	75 ed                	jne    f0104b94 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104ba7:	89 f0                	mov    %esi,%eax
f0104ba9:	5b                   	pop    %ebx
f0104baa:	5e                   	pop    %esi
f0104bab:	5d                   	pop    %ebp
f0104bac:	c3                   	ret    

f0104bad <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104bad:	55                   	push   %ebp
f0104bae:	89 e5                	mov    %esp,%ebp
f0104bb0:	56                   	push   %esi
f0104bb1:	53                   	push   %ebx
f0104bb2:	8b 75 08             	mov    0x8(%ebp),%esi
f0104bb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104bb8:	8b 55 10             	mov    0x10(%ebp),%edx
f0104bbb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104bbd:	85 d2                	test   %edx,%edx
f0104bbf:	74 21                	je     f0104be2 <strlcpy+0x35>
f0104bc1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0104bc5:	89 f2                	mov    %esi,%edx
f0104bc7:	eb 09                	jmp    f0104bd2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104bc9:	83 c2 01             	add    $0x1,%edx
f0104bcc:	83 c1 01             	add    $0x1,%ecx
f0104bcf:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104bd2:	39 c2                	cmp    %eax,%edx
f0104bd4:	74 09                	je     f0104bdf <strlcpy+0x32>
f0104bd6:	0f b6 19             	movzbl (%ecx),%ebx
f0104bd9:	84 db                	test   %bl,%bl
f0104bdb:	75 ec                	jne    f0104bc9 <strlcpy+0x1c>
f0104bdd:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0104bdf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104be2:	29 f0                	sub    %esi,%eax
}
f0104be4:	5b                   	pop    %ebx
f0104be5:	5e                   	pop    %esi
f0104be6:	5d                   	pop    %ebp
f0104be7:	c3                   	ret    

f0104be8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104be8:	55                   	push   %ebp
f0104be9:	89 e5                	mov    %esp,%ebp
f0104beb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104bee:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104bf1:	eb 06                	jmp    f0104bf9 <strcmp+0x11>
		p++, q++;
f0104bf3:	83 c1 01             	add    $0x1,%ecx
f0104bf6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104bf9:	0f b6 01             	movzbl (%ecx),%eax
f0104bfc:	84 c0                	test   %al,%al
f0104bfe:	74 04                	je     f0104c04 <strcmp+0x1c>
f0104c00:	3a 02                	cmp    (%edx),%al
f0104c02:	74 ef                	je     f0104bf3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104c04:	0f b6 c0             	movzbl %al,%eax
f0104c07:	0f b6 12             	movzbl (%edx),%edx
f0104c0a:	29 d0                	sub    %edx,%eax
}
f0104c0c:	5d                   	pop    %ebp
f0104c0d:	c3                   	ret    

f0104c0e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104c0e:	55                   	push   %ebp
f0104c0f:	89 e5                	mov    %esp,%ebp
f0104c11:	53                   	push   %ebx
f0104c12:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c15:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104c18:	89 c3                	mov    %eax,%ebx
f0104c1a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104c1d:	eb 06                	jmp    f0104c25 <strncmp+0x17>
		n--, p++, q++;
f0104c1f:	83 c0 01             	add    $0x1,%eax
f0104c22:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104c25:	39 d8                	cmp    %ebx,%eax
f0104c27:	74 15                	je     f0104c3e <strncmp+0x30>
f0104c29:	0f b6 08             	movzbl (%eax),%ecx
f0104c2c:	84 c9                	test   %cl,%cl
f0104c2e:	74 04                	je     f0104c34 <strncmp+0x26>
f0104c30:	3a 0a                	cmp    (%edx),%cl
f0104c32:	74 eb                	je     f0104c1f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104c34:	0f b6 00             	movzbl (%eax),%eax
f0104c37:	0f b6 12             	movzbl (%edx),%edx
f0104c3a:	29 d0                	sub    %edx,%eax
f0104c3c:	eb 05                	jmp    f0104c43 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104c3e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104c43:	5b                   	pop    %ebx
f0104c44:	5d                   	pop    %ebp
f0104c45:	c3                   	ret    

f0104c46 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104c46:	55                   	push   %ebp
f0104c47:	89 e5                	mov    %esp,%ebp
f0104c49:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c4c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104c50:	eb 07                	jmp    f0104c59 <strchr+0x13>
		if (*s == c)
f0104c52:	38 ca                	cmp    %cl,%dl
f0104c54:	74 0f                	je     f0104c65 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104c56:	83 c0 01             	add    $0x1,%eax
f0104c59:	0f b6 10             	movzbl (%eax),%edx
f0104c5c:	84 d2                	test   %dl,%dl
f0104c5e:	75 f2                	jne    f0104c52 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0104c60:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104c65:	5d                   	pop    %ebp
f0104c66:	c3                   	ret    

f0104c67 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104c67:	55                   	push   %ebp
f0104c68:	89 e5                	mov    %esp,%ebp
f0104c6a:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c6d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104c71:	eb 03                	jmp    f0104c76 <strfind+0xf>
f0104c73:	83 c0 01             	add    $0x1,%eax
f0104c76:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104c79:	38 ca                	cmp    %cl,%dl
f0104c7b:	74 04                	je     f0104c81 <strfind+0x1a>
f0104c7d:	84 d2                	test   %dl,%dl
f0104c7f:	75 f2                	jne    f0104c73 <strfind+0xc>
			break;
	return (char *) s;
}
f0104c81:	5d                   	pop    %ebp
f0104c82:	c3                   	ret    

f0104c83 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104c83:	55                   	push   %ebp
f0104c84:	89 e5                	mov    %esp,%ebp
f0104c86:	57                   	push   %edi
f0104c87:	56                   	push   %esi
f0104c88:	53                   	push   %ebx
f0104c89:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104c8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104c8f:	85 c9                	test   %ecx,%ecx
f0104c91:	74 36                	je     f0104cc9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104c93:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104c99:	75 28                	jne    f0104cc3 <memset+0x40>
f0104c9b:	f6 c1 03             	test   $0x3,%cl
f0104c9e:	75 23                	jne    f0104cc3 <memset+0x40>
		c &= 0xFF;
f0104ca0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104ca4:	89 d3                	mov    %edx,%ebx
f0104ca6:	c1 e3 08             	shl    $0x8,%ebx
f0104ca9:	89 d6                	mov    %edx,%esi
f0104cab:	c1 e6 18             	shl    $0x18,%esi
f0104cae:	89 d0                	mov    %edx,%eax
f0104cb0:	c1 e0 10             	shl    $0x10,%eax
f0104cb3:	09 f0                	or     %esi,%eax
f0104cb5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0104cb7:	89 d8                	mov    %ebx,%eax
f0104cb9:	09 d0                	or     %edx,%eax
f0104cbb:	c1 e9 02             	shr    $0x2,%ecx
f0104cbe:	fc                   	cld    
f0104cbf:	f3 ab                	rep stos %eax,%es:(%edi)
f0104cc1:	eb 06                	jmp    f0104cc9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104cc3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104cc6:	fc                   	cld    
f0104cc7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104cc9:	89 f8                	mov    %edi,%eax
f0104ccb:	5b                   	pop    %ebx
f0104ccc:	5e                   	pop    %esi
f0104ccd:	5f                   	pop    %edi
f0104cce:	5d                   	pop    %ebp
f0104ccf:	c3                   	ret    

f0104cd0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104cd0:	55                   	push   %ebp
f0104cd1:	89 e5                	mov    %esp,%ebp
f0104cd3:	57                   	push   %edi
f0104cd4:	56                   	push   %esi
f0104cd5:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cd8:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104cdb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104cde:	39 c6                	cmp    %eax,%esi
f0104ce0:	73 35                	jae    f0104d17 <memmove+0x47>
f0104ce2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104ce5:	39 d0                	cmp    %edx,%eax
f0104ce7:	73 2e                	jae    f0104d17 <memmove+0x47>
		s += n;
		d += n;
f0104ce9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104cec:	89 d6                	mov    %edx,%esi
f0104cee:	09 fe                	or     %edi,%esi
f0104cf0:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104cf6:	75 13                	jne    f0104d0b <memmove+0x3b>
f0104cf8:	f6 c1 03             	test   $0x3,%cl
f0104cfb:	75 0e                	jne    f0104d0b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0104cfd:	83 ef 04             	sub    $0x4,%edi
f0104d00:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104d03:	c1 e9 02             	shr    $0x2,%ecx
f0104d06:	fd                   	std    
f0104d07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104d09:	eb 09                	jmp    f0104d14 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104d0b:	83 ef 01             	sub    $0x1,%edi
f0104d0e:	8d 72 ff             	lea    -0x1(%edx),%esi
f0104d11:	fd                   	std    
f0104d12:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104d14:	fc                   	cld    
f0104d15:	eb 1d                	jmp    f0104d34 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104d17:	89 f2                	mov    %esi,%edx
f0104d19:	09 c2                	or     %eax,%edx
f0104d1b:	f6 c2 03             	test   $0x3,%dl
f0104d1e:	75 0f                	jne    f0104d2f <memmove+0x5f>
f0104d20:	f6 c1 03             	test   $0x3,%cl
f0104d23:	75 0a                	jne    f0104d2f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0104d25:	c1 e9 02             	shr    $0x2,%ecx
f0104d28:	89 c7                	mov    %eax,%edi
f0104d2a:	fc                   	cld    
f0104d2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104d2d:	eb 05                	jmp    f0104d34 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104d2f:	89 c7                	mov    %eax,%edi
f0104d31:	fc                   	cld    
f0104d32:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104d34:	5e                   	pop    %esi
f0104d35:	5f                   	pop    %edi
f0104d36:	5d                   	pop    %ebp
f0104d37:	c3                   	ret    

f0104d38 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104d38:	55                   	push   %ebp
f0104d39:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0104d3b:	ff 75 10             	pushl  0x10(%ebp)
f0104d3e:	ff 75 0c             	pushl  0xc(%ebp)
f0104d41:	ff 75 08             	pushl  0x8(%ebp)
f0104d44:	e8 87 ff ff ff       	call   f0104cd0 <memmove>
}
f0104d49:	c9                   	leave  
f0104d4a:	c3                   	ret    

f0104d4b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104d4b:	55                   	push   %ebp
f0104d4c:	89 e5                	mov    %esp,%ebp
f0104d4e:	56                   	push   %esi
f0104d4f:	53                   	push   %ebx
f0104d50:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d53:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104d56:	89 c6                	mov    %eax,%esi
f0104d58:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104d5b:	eb 1a                	jmp    f0104d77 <memcmp+0x2c>
		if (*s1 != *s2)
f0104d5d:	0f b6 08             	movzbl (%eax),%ecx
f0104d60:	0f b6 1a             	movzbl (%edx),%ebx
f0104d63:	38 d9                	cmp    %bl,%cl
f0104d65:	74 0a                	je     f0104d71 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0104d67:	0f b6 c1             	movzbl %cl,%eax
f0104d6a:	0f b6 db             	movzbl %bl,%ebx
f0104d6d:	29 d8                	sub    %ebx,%eax
f0104d6f:	eb 0f                	jmp    f0104d80 <memcmp+0x35>
		s1++, s2++;
f0104d71:	83 c0 01             	add    $0x1,%eax
f0104d74:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104d77:	39 f0                	cmp    %esi,%eax
f0104d79:	75 e2                	jne    f0104d5d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104d7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104d80:	5b                   	pop    %ebx
f0104d81:	5e                   	pop    %esi
f0104d82:	5d                   	pop    %ebp
f0104d83:	c3                   	ret    

f0104d84 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104d84:	55                   	push   %ebp
f0104d85:	89 e5                	mov    %esp,%ebp
f0104d87:	53                   	push   %ebx
f0104d88:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104d8b:	89 c1                	mov    %eax,%ecx
f0104d8d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0104d90:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104d94:	eb 0a                	jmp    f0104da0 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104d96:	0f b6 10             	movzbl (%eax),%edx
f0104d99:	39 da                	cmp    %ebx,%edx
f0104d9b:	74 07                	je     f0104da4 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104d9d:	83 c0 01             	add    $0x1,%eax
f0104da0:	39 c8                	cmp    %ecx,%eax
f0104da2:	72 f2                	jb     f0104d96 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104da4:	5b                   	pop    %ebx
f0104da5:	5d                   	pop    %ebp
f0104da6:	c3                   	ret    

f0104da7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104da7:	55                   	push   %ebp
f0104da8:	89 e5                	mov    %esp,%ebp
f0104daa:	57                   	push   %edi
f0104dab:	56                   	push   %esi
f0104dac:	53                   	push   %ebx
f0104dad:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104db0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104db3:	eb 03                	jmp    f0104db8 <strtol+0x11>
		s++;
f0104db5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104db8:	0f b6 01             	movzbl (%ecx),%eax
f0104dbb:	3c 20                	cmp    $0x20,%al
f0104dbd:	74 f6                	je     f0104db5 <strtol+0xe>
f0104dbf:	3c 09                	cmp    $0x9,%al
f0104dc1:	74 f2                	je     f0104db5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104dc3:	3c 2b                	cmp    $0x2b,%al
f0104dc5:	75 0a                	jne    f0104dd1 <strtol+0x2a>
		s++;
f0104dc7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104dca:	bf 00 00 00 00       	mov    $0x0,%edi
f0104dcf:	eb 11                	jmp    f0104de2 <strtol+0x3b>
f0104dd1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104dd6:	3c 2d                	cmp    $0x2d,%al
f0104dd8:	75 08                	jne    f0104de2 <strtol+0x3b>
		s++, neg = 1;
f0104dda:	83 c1 01             	add    $0x1,%ecx
f0104ddd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104de2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104de8:	75 15                	jne    f0104dff <strtol+0x58>
f0104dea:	80 39 30             	cmpb   $0x30,(%ecx)
f0104ded:	75 10                	jne    f0104dff <strtol+0x58>
f0104def:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104df3:	75 7c                	jne    f0104e71 <strtol+0xca>
		s += 2, base = 16;
f0104df5:	83 c1 02             	add    $0x2,%ecx
f0104df8:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104dfd:	eb 16                	jmp    f0104e15 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0104dff:	85 db                	test   %ebx,%ebx
f0104e01:	75 12                	jne    f0104e15 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104e03:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104e08:	80 39 30             	cmpb   $0x30,(%ecx)
f0104e0b:	75 08                	jne    f0104e15 <strtol+0x6e>
		s++, base = 8;
f0104e0d:	83 c1 01             	add    $0x1,%ecx
f0104e10:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0104e15:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e1a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104e1d:	0f b6 11             	movzbl (%ecx),%edx
f0104e20:	8d 72 d0             	lea    -0x30(%edx),%esi
f0104e23:	89 f3                	mov    %esi,%ebx
f0104e25:	80 fb 09             	cmp    $0x9,%bl
f0104e28:	77 08                	ja     f0104e32 <strtol+0x8b>
			dig = *s - '0';
f0104e2a:	0f be d2             	movsbl %dl,%edx
f0104e2d:	83 ea 30             	sub    $0x30,%edx
f0104e30:	eb 22                	jmp    f0104e54 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0104e32:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104e35:	89 f3                	mov    %esi,%ebx
f0104e37:	80 fb 19             	cmp    $0x19,%bl
f0104e3a:	77 08                	ja     f0104e44 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0104e3c:	0f be d2             	movsbl %dl,%edx
f0104e3f:	83 ea 57             	sub    $0x57,%edx
f0104e42:	eb 10                	jmp    f0104e54 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0104e44:	8d 72 bf             	lea    -0x41(%edx),%esi
f0104e47:	89 f3                	mov    %esi,%ebx
f0104e49:	80 fb 19             	cmp    $0x19,%bl
f0104e4c:	77 16                	ja     f0104e64 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0104e4e:	0f be d2             	movsbl %dl,%edx
f0104e51:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0104e54:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104e57:	7d 0b                	jge    f0104e64 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0104e59:	83 c1 01             	add    $0x1,%ecx
f0104e5c:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104e60:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0104e62:	eb b9                	jmp    f0104e1d <strtol+0x76>

	if (endptr)
f0104e64:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104e68:	74 0d                	je     f0104e77 <strtol+0xd0>
		*endptr = (char *) s;
f0104e6a:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104e6d:	89 0e                	mov    %ecx,(%esi)
f0104e6f:	eb 06                	jmp    f0104e77 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104e71:	85 db                	test   %ebx,%ebx
f0104e73:	74 98                	je     f0104e0d <strtol+0x66>
f0104e75:	eb 9e                	jmp    f0104e15 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0104e77:	89 c2                	mov    %eax,%edx
f0104e79:	f7 da                	neg    %edx
f0104e7b:	85 ff                	test   %edi,%edi
f0104e7d:	0f 45 c2             	cmovne %edx,%eax
}
f0104e80:	5b                   	pop    %ebx
f0104e81:	5e                   	pop    %esi
f0104e82:	5f                   	pop    %edi
f0104e83:	5d                   	pop    %ebp
f0104e84:	c3                   	ret    
f0104e85:	66 90                	xchg   %ax,%ax
f0104e87:	90                   	nop

f0104e88 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0104e88:	fa                   	cli    

	xorw    %ax, %ax
f0104e89:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0104e8b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104e8d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104e8f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0104e91:	0f 01 16             	lgdtl  (%esi)
f0104e94:	74 70                	je     f0104f06 <mpsearch1+0x3>
	movl    %cr0, %eax
f0104e96:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0104e99:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0104e9d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0104ea0:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0104ea6:	08 00                	or     %al,(%eax)

f0104ea8 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0104ea8:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0104eac:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0104eae:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0104eb0:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0104eb2:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0104eb6:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0104eb8:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0104eba:	b8 00 d0 11 00       	mov    $0x11d000,%eax
	movl    %eax, %cr3
f0104ebf:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0104ec2:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0104ec5:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0104eca:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0104ecd:	8b 25 84 ae 22 f0    	mov    0xf022ae84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0104ed3:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0104ed8:	b8 b3 01 10 f0       	mov    $0xf01001b3,%eax
	call    *%eax
f0104edd:	ff d0                	call   *%eax

f0104edf <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0104edf:	eb fe                	jmp    f0104edf <spin>
f0104ee1:	8d 76 00             	lea    0x0(%esi),%esi

f0104ee4 <gdt>:
	...
f0104eec:	ff                   	(bad)  
f0104eed:	ff 00                	incl   (%eax)
f0104eef:	00 00                	add    %al,(%eax)
f0104ef1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0104ef8:	00                   	.byte 0x0
f0104ef9:	92                   	xchg   %eax,%edx
f0104efa:	cf                   	iret   
	...

f0104efc <gdtdesc>:
f0104efc:	17                   	pop    %ss
f0104efd:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0104f02 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0104f02:	90                   	nop

f0104f03 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0104f03:	55                   	push   %ebp
f0104f04:	89 e5                	mov    %esp,%ebp
f0104f06:	57                   	push   %edi
f0104f07:	56                   	push   %esi
f0104f08:	53                   	push   %ebx
f0104f09:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104f0c:	8b 0d 88 ae 22 f0    	mov    0xf022ae88,%ecx
f0104f12:	89 c3                	mov    %eax,%ebx
f0104f14:	c1 eb 0c             	shr    $0xc,%ebx
f0104f17:	39 cb                	cmp    %ecx,%ebx
f0104f19:	72 12                	jb     f0104f2d <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104f1b:	50                   	push   %eax
f0104f1c:	68 64 59 10 f0       	push   $0xf0105964
f0104f21:	6a 57                	push   $0x57
f0104f23:	68 65 75 10 f0       	push   $0xf0107565
f0104f28:	e8 13 b1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0104f2d:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0104f33:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104f35:	89 c2                	mov    %eax,%edx
f0104f37:	c1 ea 0c             	shr    $0xc,%edx
f0104f3a:	39 ca                	cmp    %ecx,%edx
f0104f3c:	72 12                	jb     f0104f50 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104f3e:	50                   	push   %eax
f0104f3f:	68 64 59 10 f0       	push   $0xf0105964
f0104f44:	6a 57                	push   $0x57
f0104f46:	68 65 75 10 f0       	push   $0xf0107565
f0104f4b:	e8 f0 b0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0104f50:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0104f56:	eb 2f                	jmp    f0104f87 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104f58:	83 ec 04             	sub    $0x4,%esp
f0104f5b:	6a 04                	push   $0x4
f0104f5d:	68 75 75 10 f0       	push   $0xf0107575
f0104f62:	53                   	push   %ebx
f0104f63:	e8 e3 fd ff ff       	call   f0104d4b <memcmp>
f0104f68:	83 c4 10             	add    $0x10,%esp
f0104f6b:	85 c0                	test   %eax,%eax
f0104f6d:	75 15                	jne    f0104f84 <mpsearch1+0x81>
f0104f6f:	89 da                	mov    %ebx,%edx
f0104f71:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0104f74:	0f b6 0a             	movzbl (%edx),%ecx
f0104f77:	01 c8                	add    %ecx,%eax
f0104f79:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0104f7c:	39 d7                	cmp    %edx,%edi
f0104f7e:	75 f4                	jne    f0104f74 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0104f80:	84 c0                	test   %al,%al
f0104f82:	74 0e                	je     f0104f92 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0104f84:	83 c3 10             	add    $0x10,%ebx
f0104f87:	39 f3                	cmp    %esi,%ebx
f0104f89:	72 cd                	jb     f0104f58 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0104f8b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f90:	eb 02                	jmp    f0104f94 <mpsearch1+0x91>
f0104f92:	89 d8                	mov    %ebx,%eax
}
f0104f94:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f97:	5b                   	pop    %ebx
f0104f98:	5e                   	pop    %esi
f0104f99:	5f                   	pop    %edi
f0104f9a:	5d                   	pop    %ebp
f0104f9b:	c3                   	ret    

f0104f9c <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0104f9c:	55                   	push   %ebp
f0104f9d:	89 e5                	mov    %esp,%ebp
f0104f9f:	57                   	push   %edi
f0104fa0:	56                   	push   %esi
f0104fa1:	53                   	push   %ebx
f0104fa2:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0104fa5:	c7 05 c0 b3 22 f0 20 	movl   $0xf022b020,0xf022b3c0
f0104fac:	b0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0104faf:	83 3d 88 ae 22 f0 00 	cmpl   $0x0,0xf022ae88
f0104fb6:	75 16                	jne    f0104fce <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0104fb8:	68 00 04 00 00       	push   $0x400
f0104fbd:	68 64 59 10 f0       	push   $0xf0105964
f0104fc2:	6a 6f                	push   $0x6f
f0104fc4:	68 65 75 10 f0       	push   $0xf0107565
f0104fc9:	e8 72 b0 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0104fce:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0104fd5:	85 c0                	test   %eax,%eax
f0104fd7:	74 16                	je     f0104fef <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0104fd9:	c1 e0 04             	shl    $0x4,%eax
f0104fdc:	ba 00 04 00 00       	mov    $0x400,%edx
f0104fe1:	e8 1d ff ff ff       	call   f0104f03 <mpsearch1>
f0104fe6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104fe9:	85 c0                	test   %eax,%eax
f0104feb:	75 3c                	jne    f0105029 <mp_init+0x8d>
f0104fed:	eb 20                	jmp    f010500f <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0104fef:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0104ff6:	c1 e0 0a             	shl    $0xa,%eax
f0104ff9:	2d 00 04 00 00       	sub    $0x400,%eax
f0104ffe:	ba 00 04 00 00       	mov    $0x400,%edx
f0105003:	e8 fb fe ff ff       	call   f0104f03 <mpsearch1>
f0105008:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010500b:	85 c0                	test   %eax,%eax
f010500d:	75 1a                	jne    f0105029 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f010500f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105014:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105019:	e8 e5 fe ff ff       	call   f0104f03 <mpsearch1>
f010501e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105021:	85 c0                	test   %eax,%eax
f0105023:	0f 84 5d 02 00 00    	je     f0105286 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105029:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010502c:	8b 70 04             	mov    0x4(%eax),%esi
f010502f:	85 f6                	test   %esi,%esi
f0105031:	74 06                	je     f0105039 <mp_init+0x9d>
f0105033:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105037:	74 15                	je     f010504e <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105039:	83 ec 0c             	sub    $0xc,%esp
f010503c:	68 d8 73 10 f0       	push   $0xf01073d8
f0105041:	e8 38 e6 ff ff       	call   f010367e <cprintf>
f0105046:	83 c4 10             	add    $0x10,%esp
f0105049:	e9 38 02 00 00       	jmp    f0105286 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010504e:	89 f0                	mov    %esi,%eax
f0105050:	c1 e8 0c             	shr    $0xc,%eax
f0105053:	3b 05 88 ae 22 f0    	cmp    0xf022ae88,%eax
f0105059:	72 15                	jb     f0105070 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010505b:	56                   	push   %esi
f010505c:	68 64 59 10 f0       	push   $0xf0105964
f0105061:	68 90 00 00 00       	push   $0x90
f0105066:	68 65 75 10 f0       	push   $0xf0107565
f010506b:	e8 d0 af ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105070:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105076:	83 ec 04             	sub    $0x4,%esp
f0105079:	6a 04                	push   $0x4
f010507b:	68 7a 75 10 f0       	push   $0xf010757a
f0105080:	53                   	push   %ebx
f0105081:	e8 c5 fc ff ff       	call   f0104d4b <memcmp>
f0105086:	83 c4 10             	add    $0x10,%esp
f0105089:	85 c0                	test   %eax,%eax
f010508b:	74 15                	je     f01050a2 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010508d:	83 ec 0c             	sub    $0xc,%esp
f0105090:	68 08 74 10 f0       	push   $0xf0107408
f0105095:	e8 e4 e5 ff ff       	call   f010367e <cprintf>
f010509a:	83 c4 10             	add    $0x10,%esp
f010509d:	e9 e4 01 00 00       	jmp    f0105286 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01050a2:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f01050a6:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f01050aa:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01050ad:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01050b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01050b7:	eb 0d                	jmp    f01050c6 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f01050b9:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f01050c0:	f0 
f01050c1:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01050c3:	83 c0 01             	add    $0x1,%eax
f01050c6:	39 c7                	cmp    %eax,%edi
f01050c8:	75 ef                	jne    f01050b9 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01050ca:	84 d2                	test   %dl,%dl
f01050cc:	74 15                	je     f01050e3 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f01050ce:	83 ec 0c             	sub    $0xc,%esp
f01050d1:	68 3c 74 10 f0       	push   $0xf010743c
f01050d6:	e8 a3 e5 ff ff       	call   f010367e <cprintf>
f01050db:	83 c4 10             	add    $0x10,%esp
f01050de:	e9 a3 01 00 00       	jmp    f0105286 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01050e3:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01050e7:	3c 01                	cmp    $0x1,%al
f01050e9:	74 1d                	je     f0105108 <mp_init+0x16c>
f01050eb:	3c 04                	cmp    $0x4,%al
f01050ed:	74 19                	je     f0105108 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01050ef:	83 ec 08             	sub    $0x8,%esp
f01050f2:	0f b6 c0             	movzbl %al,%eax
f01050f5:	50                   	push   %eax
f01050f6:	68 60 74 10 f0       	push   $0xf0107460
f01050fb:	e8 7e e5 ff ff       	call   f010367e <cprintf>
f0105100:	83 c4 10             	add    $0x10,%esp
f0105103:	e9 7e 01 00 00       	jmp    f0105286 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105108:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f010510c:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105110:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105115:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f010511a:	01 ce                	add    %ecx,%esi
f010511c:	eb 0d                	jmp    f010512b <mp_init+0x18f>
f010511e:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105125:	f0 
f0105126:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105128:	83 c0 01             	add    $0x1,%eax
f010512b:	39 c7                	cmp    %eax,%edi
f010512d:	75 ef                	jne    f010511e <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010512f:	89 d0                	mov    %edx,%eax
f0105131:	02 43 2a             	add    0x2a(%ebx),%al
f0105134:	74 15                	je     f010514b <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105136:	83 ec 0c             	sub    $0xc,%esp
f0105139:	68 80 74 10 f0       	push   $0xf0107480
f010513e:	e8 3b e5 ff ff       	call   f010367e <cprintf>
f0105143:	83 c4 10             	add    $0x10,%esp
f0105146:	e9 3b 01 00 00       	jmp    f0105286 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f010514b:	85 db                	test   %ebx,%ebx
f010514d:	0f 84 33 01 00 00    	je     f0105286 <mp_init+0x2ea>
		return;
	ismp = 1;
f0105153:	c7 05 00 b0 22 f0 01 	movl   $0x1,0xf022b000
f010515a:	00 00 00 
	lapicaddr = conf->lapicaddr;
f010515d:	8b 43 24             	mov    0x24(%ebx),%eax
f0105160:	a3 00 c0 26 f0       	mov    %eax,0xf026c000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105165:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105168:	be 00 00 00 00       	mov    $0x0,%esi
f010516d:	e9 85 00 00 00       	jmp    f01051f7 <mp_init+0x25b>
		switch (*p) {
f0105172:	0f b6 07             	movzbl (%edi),%eax
f0105175:	84 c0                	test   %al,%al
f0105177:	74 06                	je     f010517f <mp_init+0x1e3>
f0105179:	3c 04                	cmp    $0x4,%al
f010517b:	77 55                	ja     f01051d2 <mp_init+0x236>
f010517d:	eb 4e                	jmp    f01051cd <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010517f:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105183:	74 11                	je     f0105196 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105185:	6b 05 c4 b3 22 f0 74 	imul   $0x74,0xf022b3c4,%eax
f010518c:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f0105191:	a3 c0 b3 22 f0       	mov    %eax,0xf022b3c0
			if (ncpu < NCPU) {
f0105196:	a1 c4 b3 22 f0       	mov    0xf022b3c4,%eax
f010519b:	83 f8 07             	cmp    $0x7,%eax
f010519e:	7f 13                	jg     f01051b3 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f01051a0:	6b d0 74             	imul   $0x74,%eax,%edx
f01051a3:	88 82 20 b0 22 f0    	mov    %al,-0xfdd4fe0(%edx)
				ncpu++;
f01051a9:	83 c0 01             	add    $0x1,%eax
f01051ac:	a3 c4 b3 22 f0       	mov    %eax,0xf022b3c4
f01051b1:	eb 15                	jmp    f01051c8 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01051b3:	83 ec 08             	sub    $0x8,%esp
f01051b6:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01051ba:	50                   	push   %eax
f01051bb:	68 b0 74 10 f0       	push   $0xf01074b0
f01051c0:	e8 b9 e4 ff ff       	call   f010367e <cprintf>
f01051c5:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01051c8:	83 c7 14             	add    $0x14,%edi
			continue;
f01051cb:	eb 27                	jmp    f01051f4 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01051cd:	83 c7 08             	add    $0x8,%edi
			continue;
f01051d0:	eb 22                	jmp    f01051f4 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01051d2:	83 ec 08             	sub    $0x8,%esp
f01051d5:	0f b6 c0             	movzbl %al,%eax
f01051d8:	50                   	push   %eax
f01051d9:	68 d8 74 10 f0       	push   $0xf01074d8
f01051de:	e8 9b e4 ff ff       	call   f010367e <cprintf>
			ismp = 0;
f01051e3:	c7 05 00 b0 22 f0 00 	movl   $0x0,0xf022b000
f01051ea:	00 00 00 
			i = conf->entry;
f01051ed:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f01051f1:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01051f4:	83 c6 01             	add    $0x1,%esi
f01051f7:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01051fb:	39 c6                	cmp    %eax,%esi
f01051fd:	0f 82 6f ff ff ff    	jb     f0105172 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105203:	a1 c0 b3 22 f0       	mov    0xf022b3c0,%eax
f0105208:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010520f:	83 3d 00 b0 22 f0 00 	cmpl   $0x0,0xf022b000
f0105216:	75 26                	jne    f010523e <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105218:	c7 05 c4 b3 22 f0 01 	movl   $0x1,0xf022b3c4
f010521f:	00 00 00 
		lapicaddr = 0;
f0105222:	c7 05 00 c0 26 f0 00 	movl   $0x0,0xf026c000
f0105229:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f010522c:	83 ec 0c             	sub    $0xc,%esp
f010522f:	68 f8 74 10 f0       	push   $0xf01074f8
f0105234:	e8 45 e4 ff ff       	call   f010367e <cprintf>
		return;
f0105239:	83 c4 10             	add    $0x10,%esp
f010523c:	eb 48                	jmp    f0105286 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010523e:	83 ec 04             	sub    $0x4,%esp
f0105241:	ff 35 c4 b3 22 f0    	pushl  0xf022b3c4
f0105247:	0f b6 00             	movzbl (%eax),%eax
f010524a:	50                   	push   %eax
f010524b:	68 7f 75 10 f0       	push   $0xf010757f
f0105250:	e8 29 e4 ff ff       	call   f010367e <cprintf>

	if (mp->imcrp) {
f0105255:	83 c4 10             	add    $0x10,%esp
f0105258:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010525b:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f010525f:	74 25                	je     f0105286 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105261:	83 ec 0c             	sub    $0xc,%esp
f0105264:	68 24 75 10 f0       	push   $0xf0107524
f0105269:	e8 10 e4 ff ff       	call   f010367e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010526e:	ba 22 00 00 00       	mov    $0x22,%edx
f0105273:	b8 70 00 00 00       	mov    $0x70,%eax
f0105278:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105279:	ba 23 00 00 00       	mov    $0x23,%edx
f010527e:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010527f:	83 c8 01             	or     $0x1,%eax
f0105282:	ee                   	out    %al,(%dx)
f0105283:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105286:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105289:	5b                   	pop    %ebx
f010528a:	5e                   	pop    %esi
f010528b:	5f                   	pop    %edi
f010528c:	5d                   	pop    %ebp
f010528d:	c3                   	ret    

f010528e <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f010528e:	55                   	push   %ebp
f010528f:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105291:	8b 0d 04 c0 26 f0    	mov    0xf026c004,%ecx
f0105297:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010529a:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010529c:	a1 04 c0 26 f0       	mov    0xf026c004,%eax
f01052a1:	8b 40 20             	mov    0x20(%eax),%eax
}
f01052a4:	5d                   	pop    %ebp
f01052a5:	c3                   	ret    

f01052a6 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01052a6:	55                   	push   %ebp
f01052a7:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01052a9:	a1 04 c0 26 f0       	mov    0xf026c004,%eax
f01052ae:	85 c0                	test   %eax,%eax
f01052b0:	74 08                	je     f01052ba <cpunum+0x14>
		return lapic[ID] >> 24;
f01052b2:	8b 40 20             	mov    0x20(%eax),%eax
f01052b5:	c1 e8 18             	shr    $0x18,%eax
f01052b8:	eb 05                	jmp    f01052bf <cpunum+0x19>
	return 0;
f01052ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01052bf:	5d                   	pop    %ebp
f01052c0:	c3                   	ret    

f01052c1 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f01052c1:	a1 00 c0 26 f0       	mov    0xf026c000,%eax
f01052c6:	85 c0                	test   %eax,%eax
f01052c8:	0f 84 21 01 00 00    	je     f01053ef <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01052ce:	55                   	push   %ebp
f01052cf:	89 e5                	mov    %esp,%ebp
f01052d1:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01052d4:	68 00 10 00 00       	push   $0x1000
f01052d9:	50                   	push   %eax
f01052da:	e8 45 bf ff ff       	call   f0101224 <mmio_map_region>
f01052df:	a3 04 c0 26 f0       	mov    %eax,0xf026c004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01052e4:	ba 27 01 00 00       	mov    $0x127,%edx
f01052e9:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01052ee:	e8 9b ff ff ff       	call   f010528e <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01052f3:	ba 0b 00 00 00       	mov    $0xb,%edx
f01052f8:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01052fd:	e8 8c ff ff ff       	call   f010528e <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105302:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105307:	b8 c8 00 00 00       	mov    $0xc8,%eax
f010530c:	e8 7d ff ff ff       	call   f010528e <lapicw>
	lapicw(TICR, 10000000); 
f0105311:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105316:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010531b:	e8 6e ff ff ff       	call   f010528e <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105320:	e8 81 ff ff ff       	call   f01052a6 <cpunum>
f0105325:	6b c0 74             	imul   $0x74,%eax,%eax
f0105328:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f010532d:	83 c4 10             	add    $0x10,%esp
f0105330:	39 05 c0 b3 22 f0    	cmp    %eax,0xf022b3c0
f0105336:	74 0f                	je     f0105347 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105338:	ba 00 00 01 00       	mov    $0x10000,%edx
f010533d:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105342:	e8 47 ff ff ff       	call   f010528e <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105347:	ba 00 00 01 00       	mov    $0x10000,%edx
f010534c:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105351:	e8 38 ff ff ff       	call   f010528e <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105356:	a1 04 c0 26 f0       	mov    0xf026c004,%eax
f010535b:	8b 40 30             	mov    0x30(%eax),%eax
f010535e:	c1 e8 10             	shr    $0x10,%eax
f0105361:	3c 03                	cmp    $0x3,%al
f0105363:	76 0f                	jbe    f0105374 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105365:	ba 00 00 01 00       	mov    $0x10000,%edx
f010536a:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010536f:	e8 1a ff ff ff       	call   f010528e <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105374:	ba 33 00 00 00       	mov    $0x33,%edx
f0105379:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010537e:	e8 0b ff ff ff       	call   f010528e <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105383:	ba 00 00 00 00       	mov    $0x0,%edx
f0105388:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010538d:	e8 fc fe ff ff       	call   f010528e <lapicw>
	lapicw(ESR, 0);
f0105392:	ba 00 00 00 00       	mov    $0x0,%edx
f0105397:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010539c:	e8 ed fe ff ff       	call   f010528e <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01053a1:	ba 00 00 00 00       	mov    $0x0,%edx
f01053a6:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01053ab:	e8 de fe ff ff       	call   f010528e <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01053b0:	ba 00 00 00 00       	mov    $0x0,%edx
f01053b5:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01053ba:	e8 cf fe ff ff       	call   f010528e <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01053bf:	ba 00 85 08 00       	mov    $0x88500,%edx
f01053c4:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01053c9:	e8 c0 fe ff ff       	call   f010528e <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01053ce:	8b 15 04 c0 26 f0    	mov    0xf026c004,%edx
f01053d4:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01053da:	f6 c4 10             	test   $0x10,%ah
f01053dd:	75 f5                	jne    f01053d4 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01053df:	ba 00 00 00 00       	mov    $0x0,%edx
f01053e4:	b8 20 00 00 00       	mov    $0x20,%eax
f01053e9:	e8 a0 fe ff ff       	call   f010528e <lapicw>
}
f01053ee:	c9                   	leave  
f01053ef:	f3 c3                	repz ret 

f01053f1 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01053f1:	83 3d 04 c0 26 f0 00 	cmpl   $0x0,0xf026c004
f01053f8:	74 13                	je     f010540d <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01053fa:	55                   	push   %ebp
f01053fb:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f01053fd:	ba 00 00 00 00       	mov    $0x0,%edx
f0105402:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105407:	e8 82 fe ff ff       	call   f010528e <lapicw>
}
f010540c:	5d                   	pop    %ebp
f010540d:	f3 c3                	repz ret 

f010540f <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010540f:	55                   	push   %ebp
f0105410:	89 e5                	mov    %esp,%ebp
f0105412:	56                   	push   %esi
f0105413:	53                   	push   %ebx
f0105414:	8b 75 08             	mov    0x8(%ebp),%esi
f0105417:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010541a:	ba 70 00 00 00       	mov    $0x70,%edx
f010541f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105424:	ee                   	out    %al,(%dx)
f0105425:	ba 71 00 00 00       	mov    $0x71,%edx
f010542a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010542f:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105430:	83 3d 88 ae 22 f0 00 	cmpl   $0x0,0xf022ae88
f0105437:	75 19                	jne    f0105452 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105439:	68 67 04 00 00       	push   $0x467
f010543e:	68 64 59 10 f0       	push   $0xf0105964
f0105443:	68 98 00 00 00       	push   $0x98
f0105448:	68 9c 75 10 f0       	push   $0xf010759c
f010544d:	e8 ee ab ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105452:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105459:	00 00 
	wrv[1] = addr >> 4;
f010545b:	89 d8                	mov    %ebx,%eax
f010545d:	c1 e8 04             	shr    $0x4,%eax
f0105460:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105466:	c1 e6 18             	shl    $0x18,%esi
f0105469:	89 f2                	mov    %esi,%edx
f010546b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105470:	e8 19 fe ff ff       	call   f010528e <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105475:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010547a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010547f:	e8 0a fe ff ff       	call   f010528e <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105484:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105489:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010548e:	e8 fb fd ff ff       	call   f010528e <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105493:	c1 eb 0c             	shr    $0xc,%ebx
f0105496:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105499:	89 f2                	mov    %esi,%edx
f010549b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01054a0:	e8 e9 fd ff ff       	call   f010528e <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01054a5:	89 da                	mov    %ebx,%edx
f01054a7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01054ac:	e8 dd fd ff ff       	call   f010528e <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01054b1:	89 f2                	mov    %esi,%edx
f01054b3:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01054b8:	e8 d1 fd ff ff       	call   f010528e <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01054bd:	89 da                	mov    %ebx,%edx
f01054bf:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01054c4:	e8 c5 fd ff ff       	call   f010528e <lapicw>
		microdelay(200);
	}
}
f01054c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01054cc:	5b                   	pop    %ebx
f01054cd:	5e                   	pop    %esi
f01054ce:	5d                   	pop    %ebp
f01054cf:	c3                   	ret    

f01054d0 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01054d0:	55                   	push   %ebp
f01054d1:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01054d3:	8b 55 08             	mov    0x8(%ebp),%edx
f01054d6:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01054dc:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01054e1:	e8 a8 fd ff ff       	call   f010528e <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01054e6:	8b 15 04 c0 26 f0    	mov    0xf026c004,%edx
f01054ec:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01054f2:	f6 c4 10             	test   $0x10,%ah
f01054f5:	75 f5                	jne    f01054ec <lapic_ipi+0x1c>
		;
}
f01054f7:	5d                   	pop    %ebp
f01054f8:	c3                   	ret    

f01054f9 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01054f9:	55                   	push   %ebp
f01054fa:	89 e5                	mov    %esp,%ebp
f01054fc:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01054ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105505:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105508:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f010550b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105512:	5d                   	pop    %ebp
f0105513:	c3                   	ret    

f0105514 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105514:	55                   	push   %ebp
f0105515:	89 e5                	mov    %esp,%ebp
f0105517:	56                   	push   %esi
f0105518:	53                   	push   %ebx
f0105519:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f010551c:	83 3b 00             	cmpl   $0x0,(%ebx)
f010551f:	74 14                	je     f0105535 <spin_lock+0x21>
f0105521:	8b 73 08             	mov    0x8(%ebx),%esi
f0105524:	e8 7d fd ff ff       	call   f01052a6 <cpunum>
f0105529:	6b c0 74             	imul   $0x74,%eax,%eax
f010552c:	05 20 b0 22 f0       	add    $0xf022b020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105531:	39 c6                	cmp    %eax,%esi
f0105533:	74 07                	je     f010553c <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0105535:	ba 01 00 00 00       	mov    $0x1,%edx
f010553a:	eb 20                	jmp    f010555c <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010553c:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010553f:	e8 62 fd ff ff       	call   f01052a6 <cpunum>
f0105544:	83 ec 0c             	sub    $0xc,%esp
f0105547:	53                   	push   %ebx
f0105548:	50                   	push   %eax
f0105549:	68 ac 75 10 f0       	push   $0xf01075ac
f010554e:	6a 41                	push   $0x41
f0105550:	68 10 76 10 f0       	push   $0xf0107610
f0105555:	e8 e6 aa ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010555a:	f3 90                	pause  
f010555c:	89 d0                	mov    %edx,%eax
f010555e:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105561:	85 c0                	test   %eax,%eax
f0105563:	75 f5                	jne    f010555a <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105565:	e8 3c fd ff ff       	call   f01052a6 <cpunum>
f010556a:	6b c0 74             	imul   $0x74,%eax,%eax
f010556d:	05 20 b0 22 f0       	add    $0xf022b020,%eax
f0105572:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105575:	83 c3 0c             	add    $0xc,%ebx

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0105578:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010557a:	b8 00 00 00 00       	mov    $0x0,%eax
f010557f:	eb 0b                	jmp    f010558c <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105581:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105584:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105587:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105589:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010558c:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105592:	76 11                	jbe    f01055a5 <spin_lock+0x91>
f0105594:	83 f8 09             	cmp    $0x9,%eax
f0105597:	7e e8                	jle    f0105581 <spin_lock+0x6d>
f0105599:	eb 0a                	jmp    f01055a5 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010559b:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01055a2:	83 c0 01             	add    $0x1,%eax
f01055a5:	83 f8 09             	cmp    $0x9,%eax
f01055a8:	7e f1                	jle    f010559b <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01055aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01055ad:	5b                   	pop    %ebx
f01055ae:	5e                   	pop    %esi
f01055af:	5d                   	pop    %ebp
f01055b0:	c3                   	ret    

f01055b1 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01055b1:	55                   	push   %ebp
f01055b2:	89 e5                	mov    %esp,%ebp
f01055b4:	57                   	push   %edi
f01055b5:	56                   	push   %esi
f01055b6:	53                   	push   %ebx
f01055b7:	83 ec 4c             	sub    $0x4c,%esp
f01055ba:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01055bd:	83 3e 00             	cmpl   $0x0,(%esi)
f01055c0:	74 18                	je     f01055da <spin_unlock+0x29>
f01055c2:	8b 5e 08             	mov    0x8(%esi),%ebx
f01055c5:	e8 dc fc ff ff       	call   f01052a6 <cpunum>
f01055ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01055cd:	05 20 b0 22 f0       	add    $0xf022b020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01055d2:	39 c3                	cmp    %eax,%ebx
f01055d4:	0f 84 a5 00 00 00    	je     f010567f <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01055da:	83 ec 04             	sub    $0x4,%esp
f01055dd:	6a 28                	push   $0x28
f01055df:	8d 46 0c             	lea    0xc(%esi),%eax
f01055e2:	50                   	push   %eax
f01055e3:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01055e6:	53                   	push   %ebx
f01055e7:	e8 e4 f6 ff ff       	call   f0104cd0 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01055ec:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01055ef:	0f b6 38             	movzbl (%eax),%edi
f01055f2:	8b 76 04             	mov    0x4(%esi),%esi
f01055f5:	e8 ac fc ff ff       	call   f01052a6 <cpunum>
f01055fa:	57                   	push   %edi
f01055fb:	56                   	push   %esi
f01055fc:	50                   	push   %eax
f01055fd:	68 d8 75 10 f0       	push   $0xf01075d8
f0105602:	e8 77 e0 ff ff       	call   f010367e <cprintf>
f0105607:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010560a:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010560d:	eb 54                	jmp    f0105663 <spin_unlock+0xb2>
f010560f:	83 ec 08             	sub    $0x8,%esp
f0105612:	57                   	push   %edi
f0105613:	50                   	push   %eax
f0105614:	e8 c4 eb ff ff       	call   f01041dd <debuginfo_eip>
f0105619:	83 c4 10             	add    $0x10,%esp
f010561c:	85 c0                	test   %eax,%eax
f010561e:	78 27                	js     f0105647 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105620:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105622:	83 ec 04             	sub    $0x4,%esp
f0105625:	89 c2                	mov    %eax,%edx
f0105627:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010562a:	52                   	push   %edx
f010562b:	ff 75 b0             	pushl  -0x50(%ebp)
f010562e:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105631:	ff 75 ac             	pushl  -0x54(%ebp)
f0105634:	ff 75 a8             	pushl  -0x58(%ebp)
f0105637:	50                   	push   %eax
f0105638:	68 20 76 10 f0       	push   $0xf0107620
f010563d:	e8 3c e0 ff ff       	call   f010367e <cprintf>
f0105642:	83 c4 20             	add    $0x20,%esp
f0105645:	eb 12                	jmp    f0105659 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105647:	83 ec 08             	sub    $0x8,%esp
f010564a:	ff 36                	pushl  (%esi)
f010564c:	68 37 76 10 f0       	push   $0xf0107637
f0105651:	e8 28 e0 ff ff       	call   f010367e <cprintf>
f0105656:	83 c4 10             	add    $0x10,%esp
f0105659:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010565c:	8d 45 e8             	lea    -0x18(%ebp),%eax
f010565f:	39 c3                	cmp    %eax,%ebx
f0105661:	74 08                	je     f010566b <spin_unlock+0xba>
f0105663:	89 de                	mov    %ebx,%esi
f0105665:	8b 03                	mov    (%ebx),%eax
f0105667:	85 c0                	test   %eax,%eax
f0105669:	75 a4                	jne    f010560f <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010566b:	83 ec 04             	sub    $0x4,%esp
f010566e:	68 3f 76 10 f0       	push   $0xf010763f
f0105673:	6a 67                	push   $0x67
f0105675:	68 10 76 10 f0       	push   $0xf0107610
f010567a:	e8 c1 a9 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f010567f:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105686:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010568d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105692:	f0 87 06             	lock xchg %eax,(%esi)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0105695:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105698:	5b                   	pop    %ebx
f0105699:	5e                   	pop    %esi
f010569a:	5f                   	pop    %edi
f010569b:	5d                   	pop    %ebp
f010569c:	c3                   	ret    
f010569d:	66 90                	xchg   %ax,%ax
f010569f:	90                   	nop

f01056a0 <__udivdi3>:
f01056a0:	55                   	push   %ebp
f01056a1:	57                   	push   %edi
f01056a2:	56                   	push   %esi
f01056a3:	53                   	push   %ebx
f01056a4:	83 ec 1c             	sub    $0x1c,%esp
f01056a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01056ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01056af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01056b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01056b7:	85 f6                	test   %esi,%esi
f01056b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01056bd:	89 ca                	mov    %ecx,%edx
f01056bf:	89 f8                	mov    %edi,%eax
f01056c1:	75 3d                	jne    f0105700 <__udivdi3+0x60>
f01056c3:	39 cf                	cmp    %ecx,%edi
f01056c5:	0f 87 c5 00 00 00    	ja     f0105790 <__udivdi3+0xf0>
f01056cb:	85 ff                	test   %edi,%edi
f01056cd:	89 fd                	mov    %edi,%ebp
f01056cf:	75 0b                	jne    f01056dc <__udivdi3+0x3c>
f01056d1:	b8 01 00 00 00       	mov    $0x1,%eax
f01056d6:	31 d2                	xor    %edx,%edx
f01056d8:	f7 f7                	div    %edi
f01056da:	89 c5                	mov    %eax,%ebp
f01056dc:	89 c8                	mov    %ecx,%eax
f01056de:	31 d2                	xor    %edx,%edx
f01056e0:	f7 f5                	div    %ebp
f01056e2:	89 c1                	mov    %eax,%ecx
f01056e4:	89 d8                	mov    %ebx,%eax
f01056e6:	89 cf                	mov    %ecx,%edi
f01056e8:	f7 f5                	div    %ebp
f01056ea:	89 c3                	mov    %eax,%ebx
f01056ec:	89 d8                	mov    %ebx,%eax
f01056ee:	89 fa                	mov    %edi,%edx
f01056f0:	83 c4 1c             	add    $0x1c,%esp
f01056f3:	5b                   	pop    %ebx
f01056f4:	5e                   	pop    %esi
f01056f5:	5f                   	pop    %edi
f01056f6:	5d                   	pop    %ebp
f01056f7:	c3                   	ret    
f01056f8:	90                   	nop
f01056f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105700:	39 ce                	cmp    %ecx,%esi
f0105702:	77 74                	ja     f0105778 <__udivdi3+0xd8>
f0105704:	0f bd fe             	bsr    %esi,%edi
f0105707:	83 f7 1f             	xor    $0x1f,%edi
f010570a:	0f 84 98 00 00 00    	je     f01057a8 <__udivdi3+0x108>
f0105710:	bb 20 00 00 00       	mov    $0x20,%ebx
f0105715:	89 f9                	mov    %edi,%ecx
f0105717:	89 c5                	mov    %eax,%ebp
f0105719:	29 fb                	sub    %edi,%ebx
f010571b:	d3 e6                	shl    %cl,%esi
f010571d:	89 d9                	mov    %ebx,%ecx
f010571f:	d3 ed                	shr    %cl,%ebp
f0105721:	89 f9                	mov    %edi,%ecx
f0105723:	d3 e0                	shl    %cl,%eax
f0105725:	09 ee                	or     %ebp,%esi
f0105727:	89 d9                	mov    %ebx,%ecx
f0105729:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010572d:	89 d5                	mov    %edx,%ebp
f010572f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105733:	d3 ed                	shr    %cl,%ebp
f0105735:	89 f9                	mov    %edi,%ecx
f0105737:	d3 e2                	shl    %cl,%edx
f0105739:	89 d9                	mov    %ebx,%ecx
f010573b:	d3 e8                	shr    %cl,%eax
f010573d:	09 c2                	or     %eax,%edx
f010573f:	89 d0                	mov    %edx,%eax
f0105741:	89 ea                	mov    %ebp,%edx
f0105743:	f7 f6                	div    %esi
f0105745:	89 d5                	mov    %edx,%ebp
f0105747:	89 c3                	mov    %eax,%ebx
f0105749:	f7 64 24 0c          	mull   0xc(%esp)
f010574d:	39 d5                	cmp    %edx,%ebp
f010574f:	72 10                	jb     f0105761 <__udivdi3+0xc1>
f0105751:	8b 74 24 08          	mov    0x8(%esp),%esi
f0105755:	89 f9                	mov    %edi,%ecx
f0105757:	d3 e6                	shl    %cl,%esi
f0105759:	39 c6                	cmp    %eax,%esi
f010575b:	73 07                	jae    f0105764 <__udivdi3+0xc4>
f010575d:	39 d5                	cmp    %edx,%ebp
f010575f:	75 03                	jne    f0105764 <__udivdi3+0xc4>
f0105761:	83 eb 01             	sub    $0x1,%ebx
f0105764:	31 ff                	xor    %edi,%edi
f0105766:	89 d8                	mov    %ebx,%eax
f0105768:	89 fa                	mov    %edi,%edx
f010576a:	83 c4 1c             	add    $0x1c,%esp
f010576d:	5b                   	pop    %ebx
f010576e:	5e                   	pop    %esi
f010576f:	5f                   	pop    %edi
f0105770:	5d                   	pop    %ebp
f0105771:	c3                   	ret    
f0105772:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105778:	31 ff                	xor    %edi,%edi
f010577a:	31 db                	xor    %ebx,%ebx
f010577c:	89 d8                	mov    %ebx,%eax
f010577e:	89 fa                	mov    %edi,%edx
f0105780:	83 c4 1c             	add    $0x1c,%esp
f0105783:	5b                   	pop    %ebx
f0105784:	5e                   	pop    %esi
f0105785:	5f                   	pop    %edi
f0105786:	5d                   	pop    %ebp
f0105787:	c3                   	ret    
f0105788:	90                   	nop
f0105789:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105790:	89 d8                	mov    %ebx,%eax
f0105792:	f7 f7                	div    %edi
f0105794:	31 ff                	xor    %edi,%edi
f0105796:	89 c3                	mov    %eax,%ebx
f0105798:	89 d8                	mov    %ebx,%eax
f010579a:	89 fa                	mov    %edi,%edx
f010579c:	83 c4 1c             	add    $0x1c,%esp
f010579f:	5b                   	pop    %ebx
f01057a0:	5e                   	pop    %esi
f01057a1:	5f                   	pop    %edi
f01057a2:	5d                   	pop    %ebp
f01057a3:	c3                   	ret    
f01057a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01057a8:	39 ce                	cmp    %ecx,%esi
f01057aa:	72 0c                	jb     f01057b8 <__udivdi3+0x118>
f01057ac:	31 db                	xor    %ebx,%ebx
f01057ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01057b2:	0f 87 34 ff ff ff    	ja     f01056ec <__udivdi3+0x4c>
f01057b8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01057bd:	e9 2a ff ff ff       	jmp    f01056ec <__udivdi3+0x4c>
f01057c2:	66 90                	xchg   %ax,%ax
f01057c4:	66 90                	xchg   %ax,%ax
f01057c6:	66 90                	xchg   %ax,%ax
f01057c8:	66 90                	xchg   %ax,%ax
f01057ca:	66 90                	xchg   %ax,%ax
f01057cc:	66 90                	xchg   %ax,%ax
f01057ce:	66 90                	xchg   %ax,%ax

f01057d0 <__umoddi3>:
f01057d0:	55                   	push   %ebp
f01057d1:	57                   	push   %edi
f01057d2:	56                   	push   %esi
f01057d3:	53                   	push   %ebx
f01057d4:	83 ec 1c             	sub    $0x1c,%esp
f01057d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01057db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01057df:	8b 74 24 34          	mov    0x34(%esp),%esi
f01057e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01057e7:	85 d2                	test   %edx,%edx
f01057e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01057ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01057f1:	89 f3                	mov    %esi,%ebx
f01057f3:	89 3c 24             	mov    %edi,(%esp)
f01057f6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01057fa:	75 1c                	jne    f0105818 <__umoddi3+0x48>
f01057fc:	39 f7                	cmp    %esi,%edi
f01057fe:	76 50                	jbe    f0105850 <__umoddi3+0x80>
f0105800:	89 c8                	mov    %ecx,%eax
f0105802:	89 f2                	mov    %esi,%edx
f0105804:	f7 f7                	div    %edi
f0105806:	89 d0                	mov    %edx,%eax
f0105808:	31 d2                	xor    %edx,%edx
f010580a:	83 c4 1c             	add    $0x1c,%esp
f010580d:	5b                   	pop    %ebx
f010580e:	5e                   	pop    %esi
f010580f:	5f                   	pop    %edi
f0105810:	5d                   	pop    %ebp
f0105811:	c3                   	ret    
f0105812:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105818:	39 f2                	cmp    %esi,%edx
f010581a:	89 d0                	mov    %edx,%eax
f010581c:	77 52                	ja     f0105870 <__umoddi3+0xa0>
f010581e:	0f bd ea             	bsr    %edx,%ebp
f0105821:	83 f5 1f             	xor    $0x1f,%ebp
f0105824:	75 5a                	jne    f0105880 <__umoddi3+0xb0>
f0105826:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010582a:	0f 82 e0 00 00 00    	jb     f0105910 <__umoddi3+0x140>
f0105830:	39 0c 24             	cmp    %ecx,(%esp)
f0105833:	0f 86 d7 00 00 00    	jbe    f0105910 <__umoddi3+0x140>
f0105839:	8b 44 24 08          	mov    0x8(%esp),%eax
f010583d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0105841:	83 c4 1c             	add    $0x1c,%esp
f0105844:	5b                   	pop    %ebx
f0105845:	5e                   	pop    %esi
f0105846:	5f                   	pop    %edi
f0105847:	5d                   	pop    %ebp
f0105848:	c3                   	ret    
f0105849:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105850:	85 ff                	test   %edi,%edi
f0105852:	89 fd                	mov    %edi,%ebp
f0105854:	75 0b                	jne    f0105861 <__umoddi3+0x91>
f0105856:	b8 01 00 00 00       	mov    $0x1,%eax
f010585b:	31 d2                	xor    %edx,%edx
f010585d:	f7 f7                	div    %edi
f010585f:	89 c5                	mov    %eax,%ebp
f0105861:	89 f0                	mov    %esi,%eax
f0105863:	31 d2                	xor    %edx,%edx
f0105865:	f7 f5                	div    %ebp
f0105867:	89 c8                	mov    %ecx,%eax
f0105869:	f7 f5                	div    %ebp
f010586b:	89 d0                	mov    %edx,%eax
f010586d:	eb 99                	jmp    f0105808 <__umoddi3+0x38>
f010586f:	90                   	nop
f0105870:	89 c8                	mov    %ecx,%eax
f0105872:	89 f2                	mov    %esi,%edx
f0105874:	83 c4 1c             	add    $0x1c,%esp
f0105877:	5b                   	pop    %ebx
f0105878:	5e                   	pop    %esi
f0105879:	5f                   	pop    %edi
f010587a:	5d                   	pop    %ebp
f010587b:	c3                   	ret    
f010587c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105880:	8b 34 24             	mov    (%esp),%esi
f0105883:	bf 20 00 00 00       	mov    $0x20,%edi
f0105888:	89 e9                	mov    %ebp,%ecx
f010588a:	29 ef                	sub    %ebp,%edi
f010588c:	d3 e0                	shl    %cl,%eax
f010588e:	89 f9                	mov    %edi,%ecx
f0105890:	89 f2                	mov    %esi,%edx
f0105892:	d3 ea                	shr    %cl,%edx
f0105894:	89 e9                	mov    %ebp,%ecx
f0105896:	09 c2                	or     %eax,%edx
f0105898:	89 d8                	mov    %ebx,%eax
f010589a:	89 14 24             	mov    %edx,(%esp)
f010589d:	89 f2                	mov    %esi,%edx
f010589f:	d3 e2                	shl    %cl,%edx
f01058a1:	89 f9                	mov    %edi,%ecx
f01058a3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01058a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01058ab:	d3 e8                	shr    %cl,%eax
f01058ad:	89 e9                	mov    %ebp,%ecx
f01058af:	89 c6                	mov    %eax,%esi
f01058b1:	d3 e3                	shl    %cl,%ebx
f01058b3:	89 f9                	mov    %edi,%ecx
f01058b5:	89 d0                	mov    %edx,%eax
f01058b7:	d3 e8                	shr    %cl,%eax
f01058b9:	89 e9                	mov    %ebp,%ecx
f01058bb:	09 d8                	or     %ebx,%eax
f01058bd:	89 d3                	mov    %edx,%ebx
f01058bf:	89 f2                	mov    %esi,%edx
f01058c1:	f7 34 24             	divl   (%esp)
f01058c4:	89 d6                	mov    %edx,%esi
f01058c6:	d3 e3                	shl    %cl,%ebx
f01058c8:	f7 64 24 04          	mull   0x4(%esp)
f01058cc:	39 d6                	cmp    %edx,%esi
f01058ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01058d2:	89 d1                	mov    %edx,%ecx
f01058d4:	89 c3                	mov    %eax,%ebx
f01058d6:	72 08                	jb     f01058e0 <__umoddi3+0x110>
f01058d8:	75 11                	jne    f01058eb <__umoddi3+0x11b>
f01058da:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01058de:	73 0b                	jae    f01058eb <__umoddi3+0x11b>
f01058e0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01058e4:	1b 14 24             	sbb    (%esp),%edx
f01058e7:	89 d1                	mov    %edx,%ecx
f01058e9:	89 c3                	mov    %eax,%ebx
f01058eb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01058ef:	29 da                	sub    %ebx,%edx
f01058f1:	19 ce                	sbb    %ecx,%esi
f01058f3:	89 f9                	mov    %edi,%ecx
f01058f5:	89 f0                	mov    %esi,%eax
f01058f7:	d3 e0                	shl    %cl,%eax
f01058f9:	89 e9                	mov    %ebp,%ecx
f01058fb:	d3 ea                	shr    %cl,%edx
f01058fd:	89 e9                	mov    %ebp,%ecx
f01058ff:	d3 ee                	shr    %cl,%esi
f0105901:	09 d0                	or     %edx,%eax
f0105903:	89 f2                	mov    %esi,%edx
f0105905:	83 c4 1c             	add    $0x1c,%esp
f0105908:	5b                   	pop    %ebx
f0105909:	5e                   	pop    %esi
f010590a:	5f                   	pop    %edi
f010590b:	5d                   	pop    %ebp
f010590c:	c3                   	ret    
f010590d:	8d 76 00             	lea    0x0(%esi),%esi
f0105910:	29 f9                	sub    %edi,%ecx
f0105912:	19 d6                	sbb    %edx,%esi
f0105914:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105918:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010591c:	e9 18 ff ff ff       	jmp    f0105839 <__umoddi3+0x69>
