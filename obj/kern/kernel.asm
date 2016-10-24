
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
f0100015:	b8 00 90 11 00       	mov    $0x119000,%eax
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
f0100034:	bc 00 90 11 f0       	mov    $0xf0119000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 50 dc 17 f0       	mov    $0xf017dc50,%eax
f010004b:	2d 26 cd 17 f0       	sub    $0xf017cd26,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 26 cd 17 f0       	push   $0xf017cd26
f0100058:	e8 2d 43 00 00       	call   f010438a <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 9d 04 00 00       	call   f01004ff <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 20 48 10 f0       	push   $0xf0104820
f010006f:	e8 64 2f 00 00       	call   f0102fd8 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 31 10 00 00       	call   f01010aa <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100079:	e8 9a 29 00 00       	call   f0102a18 <env_init>
	trap_init();
f010007e:	e8 c6 2f 00 00       	call   f0103049 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100083:	83 c4 08             	add    $0x8,%esp
f0100086:	6a 00                	push   $0x0
f0100088:	68 c6 1b 13 f0       	push   $0xf0131bc6
f010008d:	e8 57 2b 00 00       	call   f0102be9 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100092:	83 c4 04             	add    $0x4,%esp
f0100095:	ff 35 8c cf 17 f0    	pushl  0xf017cf8c
f010009b:	e8 86 2e 00 00       	call   f0102f26 <env_run>

f01000a0 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000a0:	55                   	push   %ebp
f01000a1:	89 e5                	mov    %esp,%ebp
f01000a3:	56                   	push   %esi
f01000a4:	53                   	push   %ebx
f01000a5:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000a8:	83 3d 40 dc 17 f0 00 	cmpl   $0x0,0xf017dc40
f01000af:	75 37                	jne    f01000e8 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000b1:	89 35 40 dc 17 f0    	mov    %esi,0xf017dc40

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000b7:	fa                   	cli    
f01000b8:	fc                   	cld    

	va_start(ap, fmt);
f01000b9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000bc:	83 ec 04             	sub    $0x4,%esp
f01000bf:	ff 75 0c             	pushl  0xc(%ebp)
f01000c2:	ff 75 08             	pushl  0x8(%ebp)
f01000c5:	68 3b 48 10 f0       	push   $0xf010483b
f01000ca:	e8 09 2f 00 00       	call   f0102fd8 <cprintf>
	vcprintf(fmt, ap);
f01000cf:	83 c4 08             	add    $0x8,%esp
f01000d2:	53                   	push   %ebx
f01000d3:	56                   	push   %esi
f01000d4:	e8 d9 2e 00 00       	call   f0102fb2 <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 8a 50 10 f0 	movl   $0xf010508a,(%esp)
f01000e0:	e8 f3 2e 00 00       	call   f0102fd8 <cprintf>
	va_end(ap);
f01000e5:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e8:	83 ec 0c             	sub    $0xc,%esp
f01000eb:	6a 00                	push   $0x0
f01000ed:	e8 1d 07 00 00       	call   f010080f <monitor>
f01000f2:	83 c4 10             	add    $0x10,%esp
f01000f5:	eb f1                	jmp    f01000e8 <_panic+0x48>

f01000f7 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000f7:	55                   	push   %ebp
f01000f8:	89 e5                	mov    %esp,%ebp
f01000fa:	53                   	push   %ebx
f01000fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000fe:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100101:	ff 75 0c             	pushl  0xc(%ebp)
f0100104:	ff 75 08             	pushl  0x8(%ebp)
f0100107:	68 53 48 10 f0       	push   $0xf0104853
f010010c:	e8 c7 2e 00 00       	call   f0102fd8 <cprintf>
	vcprintf(fmt, ap);
f0100111:	83 c4 08             	add    $0x8,%esp
f0100114:	53                   	push   %ebx
f0100115:	ff 75 10             	pushl  0x10(%ebp)
f0100118:	e8 95 2e 00 00       	call   f0102fb2 <vcprintf>
	cprintf("\n");
f010011d:	c7 04 24 8a 50 10 f0 	movl   $0xf010508a,(%esp)
f0100124:	e8 af 2e 00 00       	call   f0102fd8 <cprintf>
	va_end(ap);
}
f0100129:	83 c4 10             	add    $0x10,%esp
f010012c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010012f:	c9                   	leave  
f0100130:	c3                   	ret    

f0100131 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100131:	55                   	push   %ebp
f0100132:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100134:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100139:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010013a:	a8 01                	test   $0x1,%al
f010013c:	74 0b                	je     f0100149 <serial_proc_data+0x18>
f010013e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100143:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100144:	0f b6 c0             	movzbl %al,%eax
f0100147:	eb 05                	jmp    f010014e <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100149:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010014e:	5d                   	pop    %ebp
f010014f:	c3                   	ret    

f0100150 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100150:	55                   	push   %ebp
f0100151:	89 e5                	mov    %esp,%ebp
f0100153:	53                   	push   %ebx
f0100154:	83 ec 04             	sub    $0x4,%esp
f0100157:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100159:	eb 2b                	jmp    f0100186 <cons_intr+0x36>
		if (c == 0)
f010015b:	85 c0                	test   %eax,%eax
f010015d:	74 27                	je     f0100186 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010015f:	8b 0d 64 cf 17 f0    	mov    0xf017cf64,%ecx
f0100165:	8d 51 01             	lea    0x1(%ecx),%edx
f0100168:	89 15 64 cf 17 f0    	mov    %edx,0xf017cf64
f010016e:	88 81 60 cd 17 f0    	mov    %al,-0xfe832a0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100174:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010017a:	75 0a                	jne    f0100186 <cons_intr+0x36>
			cons.wpos = 0;
f010017c:	c7 05 64 cf 17 f0 00 	movl   $0x0,0xf017cf64
f0100183:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100186:	ff d3                	call   *%ebx
f0100188:	83 f8 ff             	cmp    $0xffffffff,%eax
f010018b:	75 ce                	jne    f010015b <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010018d:	83 c4 04             	add    $0x4,%esp
f0100190:	5b                   	pop    %ebx
f0100191:	5d                   	pop    %ebp
f0100192:	c3                   	ret    

f0100193 <kbd_proc_data>:
f0100193:	ba 64 00 00 00       	mov    $0x64,%edx
f0100198:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100199:	a8 01                	test   $0x1,%al
f010019b:	0f 84 f0 00 00 00    	je     f0100291 <kbd_proc_data+0xfe>
f01001a1:	ba 60 00 00 00       	mov    $0x60,%edx
f01001a6:	ec                   	in     (%dx),%al
f01001a7:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001a9:	3c e0                	cmp    $0xe0,%al
f01001ab:	75 0d                	jne    f01001ba <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01001ad:	83 0d 40 cd 17 f0 40 	orl    $0x40,0xf017cd40
		return 0;
f01001b4:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001b9:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001ba:	55                   	push   %ebp
f01001bb:	89 e5                	mov    %esp,%ebp
f01001bd:	53                   	push   %ebx
f01001be:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001c1:	84 c0                	test   %al,%al
f01001c3:	79 36                	jns    f01001fb <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001c5:	8b 0d 40 cd 17 f0    	mov    0xf017cd40,%ecx
f01001cb:	89 cb                	mov    %ecx,%ebx
f01001cd:	83 e3 40             	and    $0x40,%ebx
f01001d0:	83 e0 7f             	and    $0x7f,%eax
f01001d3:	85 db                	test   %ebx,%ebx
f01001d5:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001d8:	0f b6 d2             	movzbl %dl,%edx
f01001db:	0f b6 82 c0 49 10 f0 	movzbl -0xfefb640(%edx),%eax
f01001e2:	83 c8 40             	or     $0x40,%eax
f01001e5:	0f b6 c0             	movzbl %al,%eax
f01001e8:	f7 d0                	not    %eax
f01001ea:	21 c8                	and    %ecx,%eax
f01001ec:	a3 40 cd 17 f0       	mov    %eax,0xf017cd40
		return 0;
f01001f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01001f6:	e9 9e 00 00 00       	jmp    f0100299 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f01001fb:	8b 0d 40 cd 17 f0    	mov    0xf017cd40,%ecx
f0100201:	f6 c1 40             	test   $0x40,%cl
f0100204:	74 0e                	je     f0100214 <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100206:	83 c8 80             	or     $0xffffff80,%eax
f0100209:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010020b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010020e:	89 0d 40 cd 17 f0    	mov    %ecx,0xf017cd40
	}

	shift |= shiftcode[data];
f0100214:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100217:	0f b6 82 c0 49 10 f0 	movzbl -0xfefb640(%edx),%eax
f010021e:	0b 05 40 cd 17 f0    	or     0xf017cd40,%eax
f0100224:	0f b6 8a c0 48 10 f0 	movzbl -0xfefb740(%edx),%ecx
f010022b:	31 c8                	xor    %ecx,%eax
f010022d:	a3 40 cd 17 f0       	mov    %eax,0xf017cd40

	c = charcode[shift & (CTL | SHIFT)][data];
f0100232:	89 c1                	mov    %eax,%ecx
f0100234:	83 e1 03             	and    $0x3,%ecx
f0100237:	8b 0c 8d a0 48 10 f0 	mov    -0xfefb760(,%ecx,4),%ecx
f010023e:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100242:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100245:	a8 08                	test   $0x8,%al
f0100247:	74 1b                	je     f0100264 <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100249:	89 da                	mov    %ebx,%edx
f010024b:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010024e:	83 f9 19             	cmp    $0x19,%ecx
f0100251:	77 05                	ja     f0100258 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100253:	83 eb 20             	sub    $0x20,%ebx
f0100256:	eb 0c                	jmp    f0100264 <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100258:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010025b:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010025e:	83 fa 19             	cmp    $0x19,%edx
f0100261:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100264:	f7 d0                	not    %eax
f0100266:	a8 06                	test   $0x6,%al
f0100268:	75 2d                	jne    f0100297 <kbd_proc_data+0x104>
f010026a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100270:	75 25                	jne    f0100297 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f0100272:	83 ec 0c             	sub    $0xc,%esp
f0100275:	68 6d 48 10 f0       	push   $0xf010486d
f010027a:	e8 59 2d 00 00       	call   f0102fd8 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010027f:	ba 92 00 00 00       	mov    $0x92,%edx
f0100284:	b8 03 00 00 00       	mov    $0x3,%eax
f0100289:	ee                   	out    %al,(%dx)
f010028a:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010028d:	89 d8                	mov    %ebx,%eax
f010028f:	eb 08                	jmp    f0100299 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100291:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100296:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100297:	89 d8                	mov    %ebx,%eax
}
f0100299:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010029c:	c9                   	leave  
f010029d:	c3                   	ret    

f010029e <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010029e:	55                   	push   %ebp
f010029f:	89 e5                	mov    %esp,%ebp
f01002a1:	57                   	push   %edi
f01002a2:	56                   	push   %esi
f01002a3:	53                   	push   %ebx
f01002a4:	83 ec 1c             	sub    $0x1c,%esp
f01002a7:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002a9:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002ae:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002b3:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002b8:	eb 09                	jmp    f01002c3 <cons_putc+0x25>
f01002ba:	89 ca                	mov    %ecx,%edx
f01002bc:	ec                   	in     (%dx),%al
f01002bd:	ec                   	in     (%dx),%al
f01002be:	ec                   	in     (%dx),%al
f01002bf:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002c0:	83 c3 01             	add    $0x1,%ebx
f01002c3:	89 f2                	mov    %esi,%edx
f01002c5:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002c6:	a8 20                	test   $0x20,%al
f01002c8:	75 08                	jne    f01002d2 <cons_putc+0x34>
f01002ca:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002d0:	7e e8                	jle    f01002ba <cons_putc+0x1c>
f01002d2:	89 f8                	mov    %edi,%eax
f01002d4:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002dc:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002dd:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002e2:	be 79 03 00 00       	mov    $0x379,%esi
f01002e7:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002ec:	eb 09                	jmp    f01002f7 <cons_putc+0x59>
f01002ee:	89 ca                	mov    %ecx,%edx
f01002f0:	ec                   	in     (%dx),%al
f01002f1:	ec                   	in     (%dx),%al
f01002f2:	ec                   	in     (%dx),%al
f01002f3:	ec                   	in     (%dx),%al
f01002f4:	83 c3 01             	add    $0x1,%ebx
f01002f7:	89 f2                	mov    %esi,%edx
f01002f9:	ec                   	in     (%dx),%al
f01002fa:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100300:	7f 04                	jg     f0100306 <cons_putc+0x68>
f0100302:	84 c0                	test   %al,%al
f0100304:	79 e8                	jns    f01002ee <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100306:	ba 78 03 00 00       	mov    $0x378,%edx
f010030b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010030f:	ee                   	out    %al,(%dx)
f0100310:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100315:	b8 0d 00 00 00       	mov    $0xd,%eax
f010031a:	ee                   	out    %al,(%dx)
f010031b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100320:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100321:	89 fa                	mov    %edi,%edx
f0100323:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100329:	89 f8                	mov    %edi,%eax
f010032b:	80 cc 07             	or     $0x7,%ah
f010032e:	85 d2                	test   %edx,%edx
f0100330:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100333:	89 f8                	mov    %edi,%eax
f0100335:	0f b6 c0             	movzbl %al,%eax
f0100338:	83 f8 09             	cmp    $0x9,%eax
f010033b:	74 74                	je     f01003b1 <cons_putc+0x113>
f010033d:	83 f8 09             	cmp    $0x9,%eax
f0100340:	7f 0a                	jg     f010034c <cons_putc+0xae>
f0100342:	83 f8 08             	cmp    $0x8,%eax
f0100345:	74 14                	je     f010035b <cons_putc+0xbd>
f0100347:	e9 99 00 00 00       	jmp    f01003e5 <cons_putc+0x147>
f010034c:	83 f8 0a             	cmp    $0xa,%eax
f010034f:	74 3a                	je     f010038b <cons_putc+0xed>
f0100351:	83 f8 0d             	cmp    $0xd,%eax
f0100354:	74 3d                	je     f0100393 <cons_putc+0xf5>
f0100356:	e9 8a 00 00 00       	jmp    f01003e5 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f010035b:	0f b7 05 68 cf 17 f0 	movzwl 0xf017cf68,%eax
f0100362:	66 85 c0             	test   %ax,%ax
f0100365:	0f 84 e6 00 00 00    	je     f0100451 <cons_putc+0x1b3>
			crt_pos--;
f010036b:	83 e8 01             	sub    $0x1,%eax
f010036e:	66 a3 68 cf 17 f0    	mov    %ax,0xf017cf68
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100374:	0f b7 c0             	movzwl %ax,%eax
f0100377:	66 81 e7 00 ff       	and    $0xff00,%di
f010037c:	83 cf 20             	or     $0x20,%edi
f010037f:	8b 15 6c cf 17 f0    	mov    0xf017cf6c,%edx
f0100385:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100389:	eb 78                	jmp    f0100403 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010038b:	66 83 05 68 cf 17 f0 	addw   $0x50,0xf017cf68
f0100392:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100393:	0f b7 05 68 cf 17 f0 	movzwl 0xf017cf68,%eax
f010039a:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003a0:	c1 e8 16             	shr    $0x16,%eax
f01003a3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003a6:	c1 e0 04             	shl    $0x4,%eax
f01003a9:	66 a3 68 cf 17 f0    	mov    %ax,0xf017cf68
f01003af:	eb 52                	jmp    f0100403 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003b1:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b6:	e8 e3 fe ff ff       	call   f010029e <cons_putc>
		cons_putc(' ');
f01003bb:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c0:	e8 d9 fe ff ff       	call   f010029e <cons_putc>
		cons_putc(' ');
f01003c5:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ca:	e8 cf fe ff ff       	call   f010029e <cons_putc>
		cons_putc(' ');
f01003cf:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d4:	e8 c5 fe ff ff       	call   f010029e <cons_putc>
		cons_putc(' ');
f01003d9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003de:	e8 bb fe ff ff       	call   f010029e <cons_putc>
f01003e3:	eb 1e                	jmp    f0100403 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003e5:	0f b7 05 68 cf 17 f0 	movzwl 0xf017cf68,%eax
f01003ec:	8d 50 01             	lea    0x1(%eax),%edx
f01003ef:	66 89 15 68 cf 17 f0 	mov    %dx,0xf017cf68
f01003f6:	0f b7 c0             	movzwl %ax,%eax
f01003f9:	8b 15 6c cf 17 f0    	mov    0xf017cf6c,%edx
f01003ff:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100403:	66 81 3d 68 cf 17 f0 	cmpw   $0x7cf,0xf017cf68
f010040a:	cf 07 
f010040c:	76 43                	jbe    f0100451 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t)); // You can write more than one line once the max is reached. Brings the cursor to init position.
f010040e:	a1 6c cf 17 f0       	mov    0xf017cf6c,%eax
f0100413:	83 ec 04             	sub    $0x4,%esp
f0100416:	68 00 0f 00 00       	push   $0xf00
f010041b:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100421:	52                   	push   %edx
f0100422:	50                   	push   %eax
f0100423:	e8 af 3f 00 00       	call   f01043d7 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100428:	8b 15 6c cf 17 f0    	mov    0xf017cf6c,%edx
f010042e:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100434:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010043a:	83 c4 10             	add    $0x10,%esp
f010043d:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100442:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t)); // You can write more than one line once the max is reached. Brings the cursor to init position.
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100445:	39 d0                	cmp    %edx,%eax
f0100447:	75 f4                	jne    f010043d <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100449:	66 83 2d 68 cf 17 f0 	subw   $0x50,0xf017cf68
f0100450:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100451:	8b 0d 70 cf 17 f0    	mov    0xf017cf70,%ecx
f0100457:	b8 0e 00 00 00       	mov    $0xe,%eax
f010045c:	89 ca                	mov    %ecx,%edx
f010045e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010045f:	0f b7 1d 68 cf 17 f0 	movzwl 0xf017cf68,%ebx
f0100466:	8d 71 01             	lea    0x1(%ecx),%esi
f0100469:	89 d8                	mov    %ebx,%eax
f010046b:	66 c1 e8 08          	shr    $0x8,%ax
f010046f:	89 f2                	mov    %esi,%edx
f0100471:	ee                   	out    %al,(%dx)
f0100472:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100477:	89 ca                	mov    %ecx,%edx
f0100479:	ee                   	out    %al,(%dx)
f010047a:	89 d8                	mov    %ebx,%eax
f010047c:	89 f2                	mov    %esi,%edx
f010047e:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010047f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100482:	5b                   	pop    %ebx
f0100483:	5e                   	pop    %esi
f0100484:	5f                   	pop    %edi
f0100485:	5d                   	pop    %ebp
f0100486:	c3                   	ret    

f0100487 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100487:	80 3d 74 cf 17 f0 00 	cmpb   $0x0,0xf017cf74
f010048e:	74 11                	je     f01004a1 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100490:	55                   	push   %ebp
f0100491:	89 e5                	mov    %esp,%ebp
f0100493:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100496:	b8 31 01 10 f0       	mov    $0xf0100131,%eax
f010049b:	e8 b0 fc ff ff       	call   f0100150 <cons_intr>
}
f01004a0:	c9                   	leave  
f01004a1:	f3 c3                	repz ret 

f01004a3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004a3:	55                   	push   %ebp
f01004a4:	89 e5                	mov    %esp,%ebp
f01004a6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004a9:	b8 93 01 10 f0       	mov    $0xf0100193,%eax
f01004ae:	e8 9d fc ff ff       	call   f0100150 <cons_intr>
}
f01004b3:	c9                   	leave  
f01004b4:	c3                   	ret    

f01004b5 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004b5:	55                   	push   %ebp
f01004b6:	89 e5                	mov    %esp,%ebp
f01004b8:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004bb:	e8 c7 ff ff ff       	call   f0100487 <serial_intr>
	kbd_intr();
f01004c0:	e8 de ff ff ff       	call   f01004a3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004c5:	a1 60 cf 17 f0       	mov    0xf017cf60,%eax
f01004ca:	3b 05 64 cf 17 f0    	cmp    0xf017cf64,%eax
f01004d0:	74 26                	je     f01004f8 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004d2:	8d 50 01             	lea    0x1(%eax),%edx
f01004d5:	89 15 60 cf 17 f0    	mov    %edx,0xf017cf60
f01004db:	0f b6 88 60 cd 17 f0 	movzbl -0xfe832a0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004e2:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004e4:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004ea:	75 11                	jne    f01004fd <cons_getc+0x48>
			cons.rpos = 0;
f01004ec:	c7 05 60 cf 17 f0 00 	movl   $0x0,0xf017cf60
f01004f3:	00 00 00 
f01004f6:	eb 05                	jmp    f01004fd <cons_getc+0x48>
		return c;
	}
	return 0;
f01004f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004fd:	c9                   	leave  
f01004fe:	c3                   	ret    

f01004ff <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004ff:	55                   	push   %ebp
f0100500:	89 e5                	mov    %esp,%ebp
f0100502:	57                   	push   %edi
f0100503:	56                   	push   %esi
f0100504:	53                   	push   %ebx
f0100505:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100508:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010050f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100516:	5a a5 
	if (*cp != 0xA55A) {
f0100518:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010051f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100523:	74 11                	je     f0100536 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100525:	c7 05 70 cf 17 f0 b4 	movl   $0x3b4,0xf017cf70
f010052c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010052f:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100534:	eb 16                	jmp    f010054c <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100536:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010053d:	c7 05 70 cf 17 f0 d4 	movl   $0x3d4,0xf017cf70
f0100544:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100547:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010054c:	8b 3d 70 cf 17 f0    	mov    0xf017cf70,%edi
f0100552:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100557:	89 fa                	mov    %edi,%edx
f0100559:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010055a:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010055d:	89 da                	mov    %ebx,%edx
f010055f:	ec                   	in     (%dx),%al
f0100560:	0f b6 c8             	movzbl %al,%ecx
f0100563:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100566:	b8 0f 00 00 00       	mov    $0xf,%eax
f010056b:	89 fa                	mov    %edi,%edx
f010056d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010056e:	89 da                	mov    %ebx,%edx
f0100570:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100571:	89 35 6c cf 17 f0    	mov    %esi,0xf017cf6c
	crt_pos = pos;
f0100577:	0f b6 c0             	movzbl %al,%eax
f010057a:	09 c8                	or     %ecx,%eax
f010057c:	66 a3 68 cf 17 f0    	mov    %ax,0xf017cf68
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100582:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100587:	b8 00 00 00 00       	mov    $0x0,%eax
f010058c:	89 f2                	mov    %esi,%edx
f010058e:	ee                   	out    %al,(%dx)
f010058f:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100594:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100599:	ee                   	out    %al,(%dx)
f010059a:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010059f:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005a4:	89 da                	mov    %ebx,%edx
f01005a6:	ee                   	out    %al,(%dx)
f01005a7:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01005b1:	ee                   	out    %al,(%dx)
f01005b2:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005b7:	b8 03 00 00 00       	mov    $0x3,%eax
f01005bc:	ee                   	out    %al,(%dx)
f01005bd:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01005c7:	ee                   	out    %al,(%dx)
f01005c8:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005cd:	b8 01 00 00 00       	mov    $0x1,%eax
f01005d2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005d3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005d8:	ec                   	in     (%dx),%al
f01005d9:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005db:	3c ff                	cmp    $0xff,%al
f01005dd:	0f 95 05 74 cf 17 f0 	setne  0xf017cf74
f01005e4:	89 f2                	mov    %esi,%edx
f01005e6:	ec                   	in     (%dx),%al
f01005e7:	89 da                	mov    %ebx,%edx
f01005e9:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005ea:	80 f9 ff             	cmp    $0xff,%cl
f01005ed:	75 10                	jne    f01005ff <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f01005ef:	83 ec 0c             	sub    $0xc,%esp
f01005f2:	68 79 48 10 f0       	push   $0xf0104879
f01005f7:	e8 dc 29 00 00       	call   f0102fd8 <cprintf>
f01005fc:	83 c4 10             	add    $0x10,%esp
}
f01005ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100602:	5b                   	pop    %ebx
f0100603:	5e                   	pop    %esi
f0100604:	5f                   	pop    %edi
f0100605:	5d                   	pop    %ebp
f0100606:	c3                   	ret    

f0100607 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100607:	55                   	push   %ebp
f0100608:	89 e5                	mov    %esp,%ebp
f010060a:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010060d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100610:	e8 89 fc ff ff       	call   f010029e <cons_putc>
}
f0100615:	c9                   	leave  
f0100616:	c3                   	ret    

f0100617 <getchar>:

int
getchar(void)
{
f0100617:	55                   	push   %ebp
f0100618:	89 e5                	mov    %esp,%ebp
f010061a:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010061d:	e8 93 fe ff ff       	call   f01004b5 <cons_getc>
f0100622:	85 c0                	test   %eax,%eax
f0100624:	74 f7                	je     f010061d <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100626:	c9                   	leave  
f0100627:	c3                   	ret    

f0100628 <iscons>:

int
iscons(int fdnum)
{
f0100628:	55                   	push   %ebp
f0100629:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010062b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100630:	5d                   	pop    %ebp
f0100631:	c3                   	ret    

f0100632 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100632:	55                   	push   %ebp
f0100633:	89 e5                	mov    %esp,%ebp
f0100635:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100638:	68 c0 4a 10 f0       	push   $0xf0104ac0
f010063d:	68 de 4a 10 f0       	push   $0xf0104ade
f0100642:	68 e3 4a 10 f0       	push   $0xf0104ae3
f0100647:	e8 8c 29 00 00       	call   f0102fd8 <cprintf>
f010064c:	83 c4 0c             	add    $0xc,%esp
f010064f:	68 b0 4b 10 f0       	push   $0xf0104bb0
f0100654:	68 ec 4a 10 f0       	push   $0xf0104aec
f0100659:	68 e3 4a 10 f0       	push   $0xf0104ae3
f010065e:	e8 75 29 00 00       	call   f0102fd8 <cprintf>
f0100663:	83 c4 0c             	add    $0xc,%esp
f0100666:	68 f5 4a 10 f0       	push   $0xf0104af5
f010066b:	68 11 4b 10 f0       	push   $0xf0104b11
f0100670:	68 e3 4a 10 f0       	push   $0xf0104ae3
f0100675:	e8 5e 29 00 00       	call   f0102fd8 <cprintf>
	return 0;
}
f010067a:	b8 00 00 00 00       	mov    $0x0,%eax
f010067f:	c9                   	leave  
f0100680:	c3                   	ret    

f0100681 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100681:	55                   	push   %ebp
f0100682:	89 e5                	mov    %esp,%ebp
f0100684:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100687:	68 1b 4b 10 f0       	push   $0xf0104b1b
f010068c:	e8 47 29 00 00       	call   f0102fd8 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100691:	83 c4 08             	add    $0x8,%esp
f0100694:	68 0c 00 10 00       	push   $0x10000c
f0100699:	68 d8 4b 10 f0       	push   $0xf0104bd8
f010069e:	e8 35 29 00 00       	call   f0102fd8 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006a3:	83 c4 0c             	add    $0xc,%esp
f01006a6:	68 0c 00 10 00       	push   $0x10000c
f01006ab:	68 0c 00 10 f0       	push   $0xf010000c
f01006b0:	68 00 4c 10 f0       	push   $0xf0104c00
f01006b5:	e8 1e 29 00 00       	call   f0102fd8 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006ba:	83 c4 0c             	add    $0xc,%esp
f01006bd:	68 11 48 10 00       	push   $0x104811
f01006c2:	68 11 48 10 f0       	push   $0xf0104811
f01006c7:	68 24 4c 10 f0       	push   $0xf0104c24
f01006cc:	e8 07 29 00 00       	call   f0102fd8 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006d1:	83 c4 0c             	add    $0xc,%esp
f01006d4:	68 26 cd 17 00       	push   $0x17cd26
f01006d9:	68 26 cd 17 f0       	push   $0xf017cd26
f01006de:	68 48 4c 10 f0       	push   $0xf0104c48
f01006e3:	e8 f0 28 00 00       	call   f0102fd8 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006e8:	83 c4 0c             	add    $0xc,%esp
f01006eb:	68 50 dc 17 00       	push   $0x17dc50
f01006f0:	68 50 dc 17 f0       	push   $0xf017dc50
f01006f5:	68 6c 4c 10 f0       	push   $0xf0104c6c
f01006fa:	e8 d9 28 00 00       	call   f0102fd8 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006ff:	b8 4f e0 17 f0       	mov    $0xf017e04f,%eax
f0100704:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100709:	83 c4 08             	add    $0x8,%esp
f010070c:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100711:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100717:	85 c0                	test   %eax,%eax
f0100719:	0f 48 c2             	cmovs  %edx,%eax
f010071c:	c1 f8 0a             	sar    $0xa,%eax
f010071f:	50                   	push   %eax
f0100720:	68 90 4c 10 f0       	push   $0xf0104c90
f0100725:	e8 ae 28 00 00       	call   f0102fd8 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010072a:	b8 00 00 00 00       	mov    $0x0,%eax
f010072f:	c9                   	leave  
f0100730:	c3                   	ret    

f0100731 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100731:	55                   	push   %ebp
f0100732:	89 e5                	mov    %esp,%ebp
f0100734:	57                   	push   %edi
f0100735:	56                   	push   %esi
f0100736:	53                   	push   %ebx
f0100737:	83 ec 38             	sub    $0x38,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010073a:	89 eb                	mov    %ebp,%ebx
	
 uint32_t* ebp;
struct Eipdebuginfo info;
ebp = (uint32_t*) read_ebp();
cprintf("Stack backtrace:\n");
f010073c:	68 34 4b 10 f0       	push   $0xf0104b34
f0100741:	e8 92 28 00 00       	call   f0102fd8 <cprintf>
while (ebp){
f0100746:	83 c4 10             	add    $0x10,%esp
cprintf("%08x ",*(ebp+2)); 
cprintf("%08x ",*(ebp+3)) ;
cprintf("%08x ",*(ebp+4)) ;
cprintf("%08x ",*(ebp+5)) ;
cprintf("%08x\n",*(ebp+6)) ;
debuginfo_eip(eip, &info);
f0100749:	8d 7d d0             	lea    -0x30(%ebp),%edi
	
 uint32_t* ebp;
struct Eipdebuginfo info;
ebp = (uint32_t*) read_ebp();
cprintf("Stack backtrace:\n");
while (ebp){
f010074c:	e9 a9 00 00 00       	jmp    f01007fa <mon_backtrace+0xc9>
uint32_t offset_eip =0;
uint32_t eip = *(ebp+1);
f0100751:	8b 73 04             	mov    0x4(%ebx),%esi

cprintf ("ebp %08x ",ebp);
f0100754:	83 ec 08             	sub    $0x8,%esp
f0100757:	53                   	push   %ebx
f0100758:	68 46 4b 10 f0       	push   $0xf0104b46
f010075d:	e8 76 28 00 00       	call   f0102fd8 <cprintf>
cprintf ("eip %08x ",*(ebp+1));
f0100762:	83 c4 08             	add    $0x8,%esp
f0100765:	ff 73 04             	pushl  0x4(%ebx)
f0100768:	68 50 4b 10 f0       	push   $0xf0104b50
f010076d:	e8 66 28 00 00       	call   f0102fd8 <cprintf>
cprintf("args:");
f0100772:	c7 04 24 5a 4b 10 f0 	movl   $0xf0104b5a,(%esp)
f0100779:	e8 5a 28 00 00       	call   f0102fd8 <cprintf>
cprintf("%08x ",*(ebp+2)); 
f010077e:	83 c4 08             	add    $0x8,%esp
f0100781:	ff 73 08             	pushl  0x8(%ebx)
f0100784:	68 4a 4b 10 f0       	push   $0xf0104b4a
f0100789:	e8 4a 28 00 00       	call   f0102fd8 <cprintf>
cprintf("%08x ",*(ebp+3)) ;
f010078e:	83 c4 08             	add    $0x8,%esp
f0100791:	ff 73 0c             	pushl  0xc(%ebx)
f0100794:	68 4a 4b 10 f0       	push   $0xf0104b4a
f0100799:	e8 3a 28 00 00       	call   f0102fd8 <cprintf>
cprintf("%08x ",*(ebp+4)) ;
f010079e:	83 c4 08             	add    $0x8,%esp
f01007a1:	ff 73 10             	pushl  0x10(%ebx)
f01007a4:	68 4a 4b 10 f0       	push   $0xf0104b4a
f01007a9:	e8 2a 28 00 00       	call   f0102fd8 <cprintf>
cprintf("%08x ",*(ebp+5)) ;
f01007ae:	83 c4 08             	add    $0x8,%esp
f01007b1:	ff 73 14             	pushl  0x14(%ebx)
f01007b4:	68 4a 4b 10 f0       	push   $0xf0104b4a
f01007b9:	e8 1a 28 00 00       	call   f0102fd8 <cprintf>
cprintf("%08x\n",*(ebp+6)) ;
f01007be:	83 c4 08             	add    $0x8,%esp
f01007c1:	ff 73 18             	pushl  0x18(%ebx)
f01007c4:	68 0d 5e 10 f0       	push   $0xf0105e0d
f01007c9:	e8 0a 28 00 00       	call   f0102fd8 <cprintf>
debuginfo_eip(eip, &info);
f01007ce:	83 c4 08             	add    $0x8,%esp
f01007d1:	57                   	push   %edi
f01007d2:	56                   	push   %esi
f01007d3:	e8 2a 31 00 00       	call   f0103902 <debuginfo_eip>
offset_eip = eip-info.eip_fn_addr;
cprintf("\t %s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,offset_eip);
f01007d8:	83 c4 08             	add    $0x8,%esp
f01007db:	2b 75 e0             	sub    -0x20(%ebp),%esi
f01007de:	56                   	push   %esi
f01007df:	ff 75 d8             	pushl  -0x28(%ebp)
f01007e2:	ff 75 dc             	pushl  -0x24(%ebp)
f01007e5:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007e8:	ff 75 d0             	pushl  -0x30(%ebp)
f01007eb:	68 60 4b 10 f0       	push   $0xf0104b60
f01007f0:	e8 e3 27 00 00       	call   f0102fd8 <cprintf>

//cprintf(" *ebp is %08x\n",*ebp);
 ebp = (uint32_t*) *ebp;
f01007f5:	8b 1b                	mov    (%ebx),%ebx
f01007f7:	83 c4 20             	add    $0x20,%esp
	
 uint32_t* ebp;
struct Eipdebuginfo info;
ebp = (uint32_t*) read_ebp();
cprintf("Stack backtrace:\n");
while (ebp){
f01007fa:	85 db                	test   %ebx,%ebx
f01007fc:	0f 85 4f ff ff ff    	jne    f0100751 <mon_backtrace+0x20>
 ebp = (uint32_t*) *ebp;
}


	return 0;
}
f0100802:	b8 00 00 00 00       	mov    $0x0,%eax
f0100807:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010080a:	5b                   	pop    %ebx
f010080b:	5e                   	pop    %esi
f010080c:	5f                   	pop    %edi
f010080d:	5d                   	pop    %ebp
f010080e:	c3                   	ret    

f010080f <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010080f:	55                   	push   %ebp
f0100810:	89 e5                	mov    %esp,%ebp
f0100812:	57                   	push   %edi
f0100813:	56                   	push   %esi
f0100814:	53                   	push   %ebx
f0100815:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100818:	68 bc 4c 10 f0       	push   $0xf0104cbc
f010081d:	e8 b6 27 00 00       	call   f0102fd8 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100822:	c7 04 24 e0 4c 10 f0 	movl   $0xf0104ce0,(%esp)
f0100829:	e8 aa 27 00 00       	call   f0102fd8 <cprintf>

	if (tf != NULL)
f010082e:	83 c4 10             	add    $0x10,%esp
f0100831:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100835:	74 0e                	je     f0100845 <monitor+0x36>
		print_trapframe(tf);
f0100837:	83 ec 0c             	sub    $0xc,%esp
f010083a:	ff 75 08             	pushl  0x8(%ebp)
f010083d:	e8 4f 2b 00 00       	call   f0103391 <print_trapframe>
f0100842:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100845:	83 ec 0c             	sub    $0xc,%esp
f0100848:	68 72 4b 10 f0       	push   $0xf0104b72
f010084d:	e8 e1 38 00 00       	call   f0104133 <readline>
f0100852:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100854:	83 c4 10             	add    $0x10,%esp
f0100857:	85 c0                	test   %eax,%eax
f0100859:	74 ea                	je     f0100845 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010085b:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100862:	be 00 00 00 00       	mov    $0x0,%esi
f0100867:	eb 0a                	jmp    f0100873 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100869:	c6 03 00             	movb   $0x0,(%ebx)
f010086c:	89 f7                	mov    %esi,%edi
f010086e:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100871:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100873:	0f b6 03             	movzbl (%ebx),%eax
f0100876:	84 c0                	test   %al,%al
f0100878:	74 63                	je     f01008dd <monitor+0xce>
f010087a:	83 ec 08             	sub    $0x8,%esp
f010087d:	0f be c0             	movsbl %al,%eax
f0100880:	50                   	push   %eax
f0100881:	68 76 4b 10 f0       	push   $0xf0104b76
f0100886:	e8 c2 3a 00 00       	call   f010434d <strchr>
f010088b:	83 c4 10             	add    $0x10,%esp
f010088e:	85 c0                	test   %eax,%eax
f0100890:	75 d7                	jne    f0100869 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100892:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100895:	74 46                	je     f01008dd <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100897:	83 fe 0f             	cmp    $0xf,%esi
f010089a:	75 14                	jne    f01008b0 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010089c:	83 ec 08             	sub    $0x8,%esp
f010089f:	6a 10                	push   $0x10
f01008a1:	68 7b 4b 10 f0       	push   $0xf0104b7b
f01008a6:	e8 2d 27 00 00       	call   f0102fd8 <cprintf>
f01008ab:	83 c4 10             	add    $0x10,%esp
f01008ae:	eb 95                	jmp    f0100845 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01008b0:	8d 7e 01             	lea    0x1(%esi),%edi
f01008b3:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008b7:	eb 03                	jmp    f01008bc <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008b9:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008bc:	0f b6 03             	movzbl (%ebx),%eax
f01008bf:	84 c0                	test   %al,%al
f01008c1:	74 ae                	je     f0100871 <monitor+0x62>
f01008c3:	83 ec 08             	sub    $0x8,%esp
f01008c6:	0f be c0             	movsbl %al,%eax
f01008c9:	50                   	push   %eax
f01008ca:	68 76 4b 10 f0       	push   $0xf0104b76
f01008cf:	e8 79 3a 00 00       	call   f010434d <strchr>
f01008d4:	83 c4 10             	add    $0x10,%esp
f01008d7:	85 c0                	test   %eax,%eax
f01008d9:	74 de                	je     f01008b9 <monitor+0xaa>
f01008db:	eb 94                	jmp    f0100871 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f01008dd:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008e4:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008e5:	85 f6                	test   %esi,%esi
f01008e7:	0f 84 58 ff ff ff    	je     f0100845 <monitor+0x36>
f01008ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008f2:	83 ec 08             	sub    $0x8,%esp
f01008f5:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008f8:	ff 34 85 20 4d 10 f0 	pushl  -0xfefb2e0(,%eax,4)
f01008ff:	ff 75 a8             	pushl  -0x58(%ebp)
f0100902:	e8 e8 39 00 00       	call   f01042ef <strcmp>
f0100907:	83 c4 10             	add    $0x10,%esp
f010090a:	85 c0                	test   %eax,%eax
f010090c:	75 21                	jne    f010092f <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f010090e:	83 ec 04             	sub    $0x4,%esp
f0100911:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100914:	ff 75 08             	pushl  0x8(%ebp)
f0100917:	8d 55 a8             	lea    -0x58(%ebp),%edx
f010091a:	52                   	push   %edx
f010091b:	56                   	push   %esi
f010091c:	ff 14 85 28 4d 10 f0 	call   *-0xfefb2d8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100923:	83 c4 10             	add    $0x10,%esp
f0100926:	85 c0                	test   %eax,%eax
f0100928:	78 25                	js     f010094f <monitor+0x140>
f010092a:	e9 16 ff ff ff       	jmp    f0100845 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010092f:	83 c3 01             	add    $0x1,%ebx
f0100932:	83 fb 03             	cmp    $0x3,%ebx
f0100935:	75 bb                	jne    f01008f2 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100937:	83 ec 08             	sub    $0x8,%esp
f010093a:	ff 75 a8             	pushl  -0x58(%ebp)
f010093d:	68 98 4b 10 f0       	push   $0xf0104b98
f0100942:	e8 91 26 00 00       	call   f0102fd8 <cprintf>
f0100947:	83 c4 10             	add    $0x10,%esp
f010094a:	e9 f6 fe ff ff       	jmp    f0100845 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010094f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100952:	5b                   	pop    %ebx
f0100953:	5e                   	pop    %esi
f0100954:	5f                   	pop    %edi
f0100955:	5d                   	pop    %ebp
f0100956:	c3                   	ret    

f0100957 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100957:	55                   	push   %ebp
f0100958:	89 e5                	mov    %esp,%ebp
f010095a:	53                   	push   %ebx
f010095b:	83 ec 04             	sub    $0x4,%esp
f010095e:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100960:	83 3d 78 cf 17 f0 00 	cmpl   $0x0,0xf017cf78
f0100967:	75 0f                	jne    f0100978 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100969:	b8 4f ec 17 f0       	mov    $0xf017ec4f,%eax
f010096e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100973:	a3 78 cf 17 f0       	mov    %eax,0xf017cf78
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
f0100978:	83 ec 08             	sub    $0x8,%esp
f010097b:	ff 35 78 cf 17 f0    	pushl  0xf017cf78
f0100981:	68 44 4d 10 f0       	push   $0xf0104d44
f0100986:	e8 4d 26 00 00       	call   f0102fd8 <cprintf>
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
f010098b:	89 d8                	mov    %ebx,%eax
f010098d:	03 05 78 cf 17 f0    	add    0xf017cf78,%eax
f0100993:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100998:	83 c4 08             	add    $0x8,%esp
f010099b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009a0:	50                   	push   %eax
f01009a1:	68 5d 4d 10 f0       	push   $0xf0104d5d
f01009a6:	e8 2d 26 00 00       	call   f0102fd8 <cprintf>
	if (n != 0) {
f01009ab:	83 c4 10             	add    $0x10,%esp
		char *next = nextfree;
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
		return next;
	} else return nextfree;
f01009ae:	a1 78 cf 17 f0       	mov    0xf017cf78,%eax
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
	if (n != 0) {
f01009b3:	85 db                	test   %ebx,%ebx
f01009b5:	74 13                	je     f01009ca <boot_alloc+0x73>
		char *next = nextfree;
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
f01009b7:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f01009be:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01009c4:	89 15 78 cf 17 f0    	mov    %edx,0xf017cf78
		return next;
	} else return nextfree;

	return NULL;
}
f01009ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01009cd:	c9                   	leave  
f01009ce:	c3                   	ret    

f01009cf <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f01009cf:	89 d1                	mov    %edx,%ecx
f01009d1:	c1 e9 16             	shr    $0x16,%ecx
f01009d4:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009d7:	a8 01                	test   $0x1,%al
f01009d9:	74 52                	je     f0100a2d <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009e0:	89 c1                	mov    %eax,%ecx
f01009e2:	c1 e9 0c             	shr    $0xc,%ecx
f01009e5:	3b 0d 44 dc 17 f0    	cmp    0xf017dc44,%ecx
f01009eb:	72 1b                	jb     f0100a08 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009ed:	55                   	push   %ebp
f01009ee:	89 e5                	mov    %esp,%ebp
f01009f0:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009f3:	50                   	push   %eax
f01009f4:	68 e4 50 10 f0       	push   $0xf01050e4
f01009f9:	68 25 03 00 00       	push   $0x325
f01009fe:	68 70 4d 10 f0       	push   $0xf0104d70
f0100a03:	e8 98 f6 ff ff       	call   f01000a0 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100a08:	c1 ea 0c             	shr    $0xc,%edx
f0100a0b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a11:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a18:	89 c2                	mov    %eax,%edx
f0100a1a:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a1d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a22:	85 d2                	test   %edx,%edx
f0100a24:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a29:	0f 44 c2             	cmove  %edx,%eax
f0100a2c:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100a32:	c3                   	ret    

f0100a33 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a33:	55                   	push   %ebp
f0100a34:	89 e5                	mov    %esp,%ebp
f0100a36:	57                   	push   %edi
f0100a37:	56                   	push   %esi
f0100a38:	53                   	push   %ebx
f0100a39:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a3c:	84 c0                	test   %al,%al
f0100a3e:	0f 85 81 02 00 00    	jne    f0100cc5 <check_page_free_list+0x292>
f0100a44:	e9 8e 02 00 00       	jmp    f0100cd7 <check_page_free_list+0x2a4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a49:	83 ec 04             	sub    $0x4,%esp
f0100a4c:	68 08 51 10 f0       	push   $0xf0105108
f0100a51:	68 5f 02 00 00       	push   $0x25f
f0100a56:	68 70 4d 10 f0       	push   $0xf0104d70
f0100a5b:	e8 40 f6 ff ff       	call   f01000a0 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a60:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a63:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a66:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a69:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a6c:	89 c2                	mov    %eax,%edx
f0100a6e:	2b 15 4c dc 17 f0    	sub    0xf017dc4c,%edx
f0100a74:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100a7a:	0f 95 c2             	setne  %dl
f0100a7d:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100a80:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100a84:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a86:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a8a:	8b 00                	mov    (%eax),%eax
f0100a8c:	85 c0                	test   %eax,%eax
f0100a8e:	75 dc                	jne    f0100a6c <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100a90:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a93:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100a99:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a9c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100a9f:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100aa1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100aa4:	a3 80 cf 17 f0       	mov    %eax,0xf017cf80
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100aa9:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100aae:	8b 1d 80 cf 17 f0    	mov    0xf017cf80,%ebx
f0100ab4:	eb 53                	jmp    f0100b09 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ab6:	89 d8                	mov    %ebx,%eax
f0100ab8:	2b 05 4c dc 17 f0    	sub    0xf017dc4c,%eax
f0100abe:	c1 f8 03             	sar    $0x3,%eax
f0100ac1:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ac4:	89 c2                	mov    %eax,%edx
f0100ac6:	c1 ea 16             	shr    $0x16,%edx
f0100ac9:	39 f2                	cmp    %esi,%edx
f0100acb:	73 3a                	jae    f0100b07 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100acd:	89 c2                	mov    %eax,%edx
f0100acf:	c1 ea 0c             	shr    $0xc,%edx
f0100ad2:	3b 15 44 dc 17 f0    	cmp    0xf017dc44,%edx
f0100ad8:	72 12                	jb     f0100aec <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ada:	50                   	push   %eax
f0100adb:	68 e4 50 10 f0       	push   $0xf01050e4
f0100ae0:	6a 56                	push   $0x56
f0100ae2:	68 7c 4d 10 f0       	push   $0xf0104d7c
f0100ae7:	e8 b4 f5 ff ff       	call   f01000a0 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100aec:	83 ec 04             	sub    $0x4,%esp
f0100aef:	68 80 00 00 00       	push   $0x80
f0100af4:	68 97 00 00 00       	push   $0x97
f0100af9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100afe:	50                   	push   %eax
f0100aff:	e8 86 38 00 00       	call   f010438a <memset>
f0100b04:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b07:	8b 1b                	mov    (%ebx),%ebx
f0100b09:	85 db                	test   %ebx,%ebx
f0100b0b:	75 a9                	jne    f0100ab6 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100b0d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b12:	e8 40 fe ff ff       	call   f0100957 <boot_alloc>
f0100b17:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b1a:	8b 15 80 cf 17 f0    	mov    0xf017cf80,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b20:	8b 0d 4c dc 17 f0    	mov    0xf017dc4c,%ecx
		assert(pp < pages + npages);
f0100b26:	a1 44 dc 17 f0       	mov    0xf017dc44,%eax
f0100b2b:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100b2e:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b31:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b34:	be 00 00 00 00       	mov    $0x0,%esi
f0100b39:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b3c:	e9 30 01 00 00       	jmp    f0100c71 <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b41:	39 ca                	cmp    %ecx,%edx
f0100b43:	73 19                	jae    f0100b5e <check_page_free_list+0x12b>
f0100b45:	68 8a 4d 10 f0       	push   $0xf0104d8a
f0100b4a:	68 96 4d 10 f0       	push   $0xf0104d96
f0100b4f:	68 79 02 00 00       	push   $0x279
f0100b54:	68 70 4d 10 f0       	push   $0xf0104d70
f0100b59:	e8 42 f5 ff ff       	call   f01000a0 <_panic>
		assert(pp < pages + npages);
f0100b5e:	39 fa                	cmp    %edi,%edx
f0100b60:	72 19                	jb     f0100b7b <check_page_free_list+0x148>
f0100b62:	68 ab 4d 10 f0       	push   $0xf0104dab
f0100b67:	68 96 4d 10 f0       	push   $0xf0104d96
f0100b6c:	68 7a 02 00 00       	push   $0x27a
f0100b71:	68 70 4d 10 f0       	push   $0xf0104d70
f0100b76:	e8 25 f5 ff ff       	call   f01000a0 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b7b:	89 d0                	mov    %edx,%eax
f0100b7d:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100b80:	a8 07                	test   $0x7,%al
f0100b82:	74 19                	je     f0100b9d <check_page_free_list+0x16a>
f0100b84:	68 2c 51 10 f0       	push   $0xf010512c
f0100b89:	68 96 4d 10 f0       	push   $0xf0104d96
f0100b8e:	68 7b 02 00 00       	push   $0x27b
f0100b93:	68 70 4d 10 f0       	push   $0xf0104d70
f0100b98:	e8 03 f5 ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b9d:	c1 f8 03             	sar    $0x3,%eax
f0100ba0:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100ba3:	85 c0                	test   %eax,%eax
f0100ba5:	75 19                	jne    f0100bc0 <check_page_free_list+0x18d>
f0100ba7:	68 bf 4d 10 f0       	push   $0xf0104dbf
f0100bac:	68 96 4d 10 f0       	push   $0xf0104d96
f0100bb1:	68 7e 02 00 00       	push   $0x27e
f0100bb6:	68 70 4d 10 f0       	push   $0xf0104d70
f0100bbb:	e8 e0 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100bc0:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100bc5:	75 19                	jne    f0100be0 <check_page_free_list+0x1ad>
f0100bc7:	68 d0 4d 10 f0       	push   $0xf0104dd0
f0100bcc:	68 96 4d 10 f0       	push   $0xf0104d96
f0100bd1:	68 7f 02 00 00       	push   $0x27f
f0100bd6:	68 70 4d 10 f0       	push   $0xf0104d70
f0100bdb:	e8 c0 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100be0:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100be5:	75 19                	jne    f0100c00 <check_page_free_list+0x1cd>
f0100be7:	68 60 51 10 f0       	push   $0xf0105160
f0100bec:	68 96 4d 10 f0       	push   $0xf0104d96
f0100bf1:	68 80 02 00 00       	push   $0x280
f0100bf6:	68 70 4d 10 f0       	push   $0xf0104d70
f0100bfb:	e8 a0 f4 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c00:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c05:	75 19                	jne    f0100c20 <check_page_free_list+0x1ed>
f0100c07:	68 e9 4d 10 f0       	push   $0xf0104de9
f0100c0c:	68 96 4d 10 f0       	push   $0xf0104d96
f0100c11:	68 81 02 00 00       	push   $0x281
f0100c16:	68 70 4d 10 f0       	push   $0xf0104d70
f0100c1b:	e8 80 f4 ff ff       	call   f01000a0 <_panic>
		// cprintf("pp: %x, page2pa(pp): %x, page2kva(pp): %x, first_free_page: %x\n",
		// 	pp, page2pa(pp), page2kva(pp), first_free_page);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c20:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c25:	76 3f                	jbe    f0100c66 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c27:	89 c3                	mov    %eax,%ebx
f0100c29:	c1 eb 0c             	shr    $0xc,%ebx
f0100c2c:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100c2f:	77 12                	ja     f0100c43 <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c31:	50                   	push   %eax
f0100c32:	68 e4 50 10 f0       	push   $0xf01050e4
f0100c37:	6a 56                	push   $0x56
f0100c39:	68 7c 4d 10 f0       	push   $0xf0104d7c
f0100c3e:	e8 5d f4 ff ff       	call   f01000a0 <_panic>
f0100c43:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c48:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100c4b:	76 1e                	jbe    f0100c6b <check_page_free_list+0x238>
f0100c4d:	68 84 51 10 f0       	push   $0xf0105184
f0100c52:	68 96 4d 10 f0       	push   $0xf0104d96
f0100c57:	68 84 02 00 00       	push   $0x284
f0100c5c:	68 70 4d 10 f0       	push   $0xf0104d70
f0100c61:	e8 3a f4 ff ff       	call   f01000a0 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100c66:	83 c6 01             	add    $0x1,%esi
f0100c69:	eb 04                	jmp    f0100c6f <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100c6b:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c6f:	8b 12                	mov    (%edx),%edx
f0100c71:	85 d2                	test   %edx,%edx
f0100c73:	0f 85 c8 fe ff ff    	jne    f0100b41 <check_page_free_list+0x10e>
f0100c79:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100c7c:	85 f6                	test   %esi,%esi
f0100c7e:	7f 19                	jg     f0100c99 <check_page_free_list+0x266>
f0100c80:	68 03 4e 10 f0       	push   $0xf0104e03
f0100c85:	68 96 4d 10 f0       	push   $0xf0104d96
f0100c8a:	68 8c 02 00 00       	push   $0x28c
f0100c8f:	68 70 4d 10 f0       	push   $0xf0104d70
f0100c94:	e8 07 f4 ff ff       	call   f01000a0 <_panic>
	assert(nfree_extmem > 0);
f0100c99:	85 db                	test   %ebx,%ebx
f0100c9b:	7f 19                	jg     f0100cb6 <check_page_free_list+0x283>
f0100c9d:	68 15 4e 10 f0       	push   $0xf0104e15
f0100ca2:	68 96 4d 10 f0       	push   $0xf0104d96
f0100ca7:	68 8d 02 00 00       	push   $0x28d
f0100cac:	68 70 4d 10 f0       	push   $0xf0104d70
f0100cb1:	e8 ea f3 ff ff       	call   f01000a0 <_panic>
	cprintf("check_page_free_list done\n");
f0100cb6:	83 ec 0c             	sub    $0xc,%esp
f0100cb9:	68 26 4e 10 f0       	push   $0xf0104e26
f0100cbe:	e8 15 23 00 00       	call   f0102fd8 <cprintf>
}
f0100cc3:	eb 29                	jmp    f0100cee <check_page_free_list+0x2bb>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100cc5:	a1 80 cf 17 f0       	mov    0xf017cf80,%eax
f0100cca:	85 c0                	test   %eax,%eax
f0100ccc:	0f 85 8e fd ff ff    	jne    f0100a60 <check_page_free_list+0x2d>
f0100cd2:	e9 72 fd ff ff       	jmp    f0100a49 <check_page_free_list+0x16>
f0100cd7:	83 3d 80 cf 17 f0 00 	cmpl   $0x0,0xf017cf80
f0100cde:	0f 84 65 fd ff ff    	je     f0100a49 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ce4:	be 00 04 00 00       	mov    $0x400,%esi
f0100ce9:	e9 c0 fd ff ff       	jmp    f0100aae <check_page_free_list+0x7b>
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
	cprintf("check_page_free_list done\n");
}
f0100cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cf1:	5b                   	pop    %ebx
f0100cf2:	5e                   	pop    %esi
f0100cf3:	5f                   	pop    %edi
f0100cf4:	5d                   	pop    %ebp
f0100cf5:	c3                   	ret    

f0100cf6 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100cf6:	55                   	push   %ebp
f0100cf7:	89 e5                	mov    %esp,%ebp
f0100cf9:	56                   	push   %esi
f0100cfa:	53                   	push   %ebx
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
f0100cfb:	8b 35 84 cf 17 f0    	mov    0xf017cf84,%esi
f0100d01:	8b 1d 80 cf 17 f0    	mov    0xf017cf80,%ebx
f0100d07:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d0c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100d11:	eb 27                	jmp    f0100d3a <page_init+0x44>
		pages[i].pp_ref = 0;
f0100d13:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100d1a:	89 d1                	mov    %edx,%ecx
f0100d1c:	03 0d 4c dc 17 f0    	add    0xf017dc4c,%ecx
f0100d22:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100d28:	89 19                	mov    %ebx,(%ecx)
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
f0100d2a:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0100d2d:	89 d3                	mov    %edx,%ebx
f0100d2f:	03 1d 4c dc 17 f0    	add    0xf017dc4c,%ebx
f0100d35:	ba 01 00 00 00       	mov    $0x1,%edx
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
f0100d3a:	39 f0                	cmp    %esi,%eax
f0100d3c:	72 d5                	jb     f0100d13 <page_init+0x1d>
f0100d3e:	84 d2                	test   %dl,%dl
f0100d40:	74 06                	je     f0100d48 <page_init+0x52>
f0100d42:	89 1d 80 cf 17 f0    	mov    %ebx,0xf017cf80
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	int med = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
f0100d48:	8b 15 8c cf 17 f0    	mov    0xf017cf8c,%edx
f0100d4e:	8d 82 ff 8f 01 10    	lea    0x10018fff(%edx),%eax
f0100d54:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d59:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0100d5f:	85 c0                	test   %eax,%eax
f0100d61:	0f 48 c3             	cmovs  %ebx,%eax
f0100d64:	c1 f8 0c             	sar    $0xc,%eax
f0100d67:	89 c3                	mov    %eax,%ebx
	cprintf("%x\n", ((char*)envs) + (sizeof(struct Env) * NENV));
f0100d69:	83 ec 08             	sub    $0x8,%esp
f0100d6c:	81 c2 00 80 01 00    	add    $0x18000,%edx
f0100d72:	52                   	push   %edx
f0100d73:	68 ae 50 10 f0       	push   $0xf01050ae
f0100d78:	e8 5b 22 00 00       	call   f0102fd8 <cprintf>
	cprintf("med=%d\n", med);
f0100d7d:	83 c4 08             	add    $0x8,%esp
f0100d80:	53                   	push   %ebx
f0100d81:	68 41 4e 10 f0       	push   $0xf0104e41
f0100d86:	e8 4d 22 00 00       	call   f0102fd8 <cprintf>
	for (i = med; i < npages; i++) {
f0100d8b:	89 da                	mov    %ebx,%edx
f0100d8d:	8b 35 80 cf 17 f0    	mov    0xf017cf80,%esi
f0100d93:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f0100d9a:	83 c4 10             	add    $0x10,%esp
f0100d9d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100da2:	eb 23                	jmp    f0100dc7 <page_init+0xd1>
		pages[i].pp_ref = 0;
f0100da4:	89 c1                	mov    %eax,%ecx
f0100da6:	03 0d 4c dc 17 f0    	add    0xf017dc4c,%ecx
f0100dac:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100db2:	89 31                	mov    %esi,(%ecx)
		page_free_list = &pages[i];
f0100db4:	89 c6                	mov    %eax,%esi
f0100db6:	03 35 4c dc 17 f0    	add    0xf017dc4c,%esi
		page_free_list = &pages[i];
	}
	int med = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
	cprintf("%x\n", ((char*)envs) + (sizeof(struct Env) * NENV));
	cprintf("med=%d\n", med);
	for (i = med; i < npages; i++) {
f0100dbc:	83 c2 01             	add    $0x1,%edx
f0100dbf:	83 c0 08             	add    $0x8,%eax
f0100dc2:	b9 01 00 00 00       	mov    $0x1,%ecx
f0100dc7:	3b 15 44 dc 17 f0    	cmp    0xf017dc44,%edx
f0100dcd:	72 d5                	jb     f0100da4 <page_init+0xae>
f0100dcf:	84 c9                	test   %cl,%cl
f0100dd1:	74 06                	je     f0100dd9 <page_init+0xe3>
f0100dd3:	89 35 80 cf 17 f0    	mov    %esi,0xf017cf80
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100dd9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ddc:	5b                   	pop    %ebx
f0100ddd:	5e                   	pop    %esi
f0100dde:	5d                   	pop    %ebp
f0100ddf:	c3                   	ret    

f0100de0 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100de0:	55                   	push   %ebp
f0100de1:	89 e5                	mov    %esp,%ebp
f0100de3:	53                   	push   %ebx
f0100de4:	83 ec 04             	sub    $0x4,%esp
	if (page_free_list) {
f0100de7:	8b 1d 80 cf 17 f0    	mov    0xf017cf80,%ebx
f0100ded:	85 db                	test   %ebx,%ebx
f0100def:	74 52                	je     f0100e43 <page_alloc+0x63>
		struct PageInfo *ret = page_free_list;
		page_free_list = page_free_list->pp_link;
f0100df1:	8b 03                	mov    (%ebx),%eax
f0100df3:	a3 80 cf 17 f0       	mov    %eax,0xf017cf80
		if (alloc_flags & ALLOC_ZERO) 
f0100df8:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100dfc:	74 45                	je     f0100e43 <page_alloc+0x63>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100dfe:	89 d8                	mov    %ebx,%eax
f0100e00:	2b 05 4c dc 17 f0    	sub    0xf017dc4c,%eax
f0100e06:	c1 f8 03             	sar    $0x3,%eax
f0100e09:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e0c:	89 c2                	mov    %eax,%edx
f0100e0e:	c1 ea 0c             	shr    $0xc,%edx
f0100e11:	3b 15 44 dc 17 f0    	cmp    0xf017dc44,%edx
f0100e17:	72 12                	jb     f0100e2b <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e19:	50                   	push   %eax
f0100e1a:	68 e4 50 10 f0       	push   $0xf01050e4
f0100e1f:	6a 56                	push   $0x56
f0100e21:	68 7c 4d 10 f0       	push   $0xf0104d7c
f0100e26:	e8 75 f2 ff ff       	call   f01000a0 <_panic>
			memset(page2kva(ret), 0, PGSIZE);
f0100e2b:	83 ec 04             	sub    $0x4,%esp
f0100e2e:	68 00 10 00 00       	push   $0x1000
f0100e33:	6a 00                	push   $0x0
f0100e35:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e3a:	50                   	push   %eax
f0100e3b:	e8 4a 35 00 00       	call   f010438a <memset>
f0100e40:	83 c4 10             	add    $0x10,%esp
		return ret;
	}
	return NULL;
}
f0100e43:	89 d8                	mov    %ebx,%eax
f0100e45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e48:	c9                   	leave  
f0100e49:	c3                   	ret    

f0100e4a <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100e4a:	55                   	push   %ebp
f0100e4b:	89 e5                	mov    %esp,%ebp
f0100e4d:	8b 45 08             	mov    0x8(%ebp),%eax
	pp->pp_link = page_free_list;
f0100e50:	8b 15 80 cf 17 f0    	mov    0xf017cf80,%edx
f0100e56:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100e58:	a3 80 cf 17 f0       	mov    %eax,0xf017cf80
}
f0100e5d:	5d                   	pop    %ebp
f0100e5e:	c3                   	ret    

f0100e5f <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100e5f:	55                   	push   %ebp
f0100e60:	89 e5                	mov    %esp,%ebp
f0100e62:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100e65:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100e69:	83 e8 01             	sub    $0x1,%eax
f0100e6c:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100e70:	66 85 c0             	test   %ax,%ax
f0100e73:	75 09                	jne    f0100e7e <page_decref+0x1f>
		page_free(pp);
f0100e75:	52                   	push   %edx
f0100e76:	e8 cf ff ff ff       	call   f0100e4a <page_free>
f0100e7b:	83 c4 04             	add    $0x4,%esp
}
f0100e7e:	c9                   	leave  
f0100e7f:	c3                   	ret    

f0100e80 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100e80:	55                   	push   %ebp
f0100e81:	89 e5                	mov    %esp,%ebp
f0100e83:	56                   	push   %esi
f0100e84:	53                   	push   %ebx
f0100e85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int dindex = PDX(va), tindex = PTX(va);
f0100e88:	89 de                	mov    %ebx,%esi
f0100e8a:	c1 ee 0c             	shr    $0xc,%esi
f0100e8d:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
f0100e93:	c1 eb 16             	shr    $0x16,%ebx
f0100e96:	c1 e3 02             	shl    $0x2,%ebx
f0100e99:	03 5d 08             	add    0x8(%ebp),%ebx
f0100e9c:	f6 03 01             	testb  $0x1,(%ebx)
f0100e9f:	75 2d                	jne    f0100ece <pgdir_walk+0x4e>
		if (create) {
f0100ea1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100ea5:	74 59                	je     f0100f00 <pgdir_walk+0x80>
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
f0100ea7:	83 ec 0c             	sub    $0xc,%esp
f0100eaa:	6a 01                	push   $0x1
f0100eac:	e8 2f ff ff ff       	call   f0100de0 <page_alloc>
			if (!pg) return NULL;	//allocation fails
f0100eb1:	83 c4 10             	add    $0x10,%esp
f0100eb4:	85 c0                	test   %eax,%eax
f0100eb6:	74 4f                	je     f0100f07 <pgdir_walk+0x87>
			pg->pp_ref++;
f0100eb8:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
f0100ebd:	2b 05 4c dc 17 f0    	sub    0xf017dc4c,%eax
f0100ec3:	c1 f8 03             	sar    $0x3,%eax
f0100ec6:	c1 e0 0c             	shl    $0xc,%eax
f0100ec9:	83 c8 07             	or     $0x7,%eax
f0100ecc:	89 03                	mov    %eax,(%ebx)
		} else return NULL;
	}
	pte_t *p = KADDR(PTE_ADDR(pgdir[dindex]));
f0100ece:	8b 03                	mov    (%ebx),%eax
f0100ed0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ed5:	89 c2                	mov    %eax,%edx
f0100ed7:	c1 ea 0c             	shr    $0xc,%edx
f0100eda:	3b 15 44 dc 17 f0    	cmp    0xf017dc44,%edx
f0100ee0:	72 15                	jb     f0100ef7 <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ee2:	50                   	push   %eax
f0100ee3:	68 e4 50 10 f0       	push   $0xf01050e4
f0100ee8:	68 89 01 00 00       	push   $0x189
f0100eed:	68 70 4d 10 f0       	push   $0xf0104d70
f0100ef2:	e8 a9 f1 ff ff       	call   f01000a0 <_panic>
	// 		struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
f0100ef7:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0100efe:	eb 0c                	jmp    f0100f0c <pgdir_walk+0x8c>
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
			pg->pp_ref++;
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
		} else return NULL;
f0100f00:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f05:	eb 05                	jmp    f0100f0c <pgdir_walk+0x8c>
	int dindex = PDX(va), tindex = PTX(va);
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
f0100f07:	b8 00 00 00 00       	mov    $0x0,%eax
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
}
f0100f0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f0f:	5b                   	pop    %ebx
f0100f10:	5e                   	pop    %esi
f0100f11:	5d                   	pop    %ebp
f0100f12:	c3                   	ret    

f0100f13 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100f13:	55                   	push   %ebp
f0100f14:	89 e5                	mov    %esp,%ebp
f0100f16:	57                   	push   %edi
f0100f17:	56                   	push   %esi
f0100f18:	53                   	push   %ebx
f0100f19:	83 ec 20             	sub    $0x20,%esp
f0100f1c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f1f:	89 d7                	mov    %edx,%edi
f0100f21:	89 cb                	mov    %ecx,%ebx
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
f0100f23:	ff 75 08             	pushl  0x8(%ebp)
f0100f26:	52                   	push   %edx
f0100f27:	68 cc 51 10 f0       	push   $0xf01051cc
f0100f2c:	e8 a7 20 00 00       	call   f0102fd8 <cprintf>
f0100f31:	c1 eb 0c             	shr    $0xc,%ebx
f0100f34:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0100f37:	83 c4 10             	add    $0x10,%esp
f0100f3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100f3d:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
f0100f42:	29 df                	sub    %ebx,%edi
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
f0100f44:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f47:	83 c8 01             	or     $0x1,%eax
f0100f4a:	89 45 dc             	mov    %eax,-0x24(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0100f4d:	eb 3f                	jmp    f0100f8e <boot_map_region+0x7b>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
f0100f4f:	83 ec 04             	sub    $0x4,%esp
f0100f52:	6a 01                	push   $0x1
f0100f54:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0100f57:	50                   	push   %eax
f0100f58:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f5b:	e8 20 ff ff ff       	call   f0100e80 <pgdir_walk>
		if (!pte) panic("boot_map_region panic, out of memory");
f0100f60:	83 c4 10             	add    $0x10,%esp
f0100f63:	85 c0                	test   %eax,%eax
f0100f65:	75 17                	jne    f0100f7e <boot_map_region+0x6b>
f0100f67:	83 ec 04             	sub    $0x4,%esp
f0100f6a:	68 00 52 10 f0       	push   $0xf0105200
f0100f6f:	68 a7 01 00 00       	push   $0x1a7
f0100f74:	68 70 4d 10 f0       	push   $0xf0104d70
f0100f79:	e8 22 f1 ff ff       	call   f01000a0 <_panic>
		*pte = pa | perm | PTE_P;
f0100f7e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100f81:	09 da                	or     %ebx,%edx
f0100f83:	89 10                	mov    %edx,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0100f85:	83 c6 01             	add    $0x1,%esi
f0100f88:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100f8e:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0100f91:	75 bc                	jne    f0100f4f <boot_map_region+0x3c>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
	}
}
f0100f93:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f96:	5b                   	pop    %ebx
f0100f97:	5e                   	pop    %esi
f0100f98:	5f                   	pop    %edi
f0100f99:	5d                   	pop    %ebp
f0100f9a:	c3                   	ret    

f0100f9b <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f9b:	55                   	push   %ebp
f0100f9c:	89 e5                	mov    %esp,%ebp
f0100f9e:	53                   	push   %ebx
f0100f9f:	83 ec 08             	sub    $0x8,%esp
f0100fa2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
f0100fa5:	6a 00                	push   $0x0
f0100fa7:	ff 75 0c             	pushl  0xc(%ebp)
f0100faa:	ff 75 08             	pushl  0x8(%ebp)
f0100fad:	e8 ce fe ff ff       	call   f0100e80 <pgdir_walk>
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f0100fb2:	83 c4 10             	add    $0x10,%esp
f0100fb5:	85 c0                	test   %eax,%eax
f0100fb7:	74 37                	je     f0100ff0 <page_lookup+0x55>
f0100fb9:	f6 00 01             	testb  $0x1,(%eax)
f0100fbc:	74 39                	je     f0100ff7 <page_lookup+0x5c>
	if (pte_store)
f0100fbe:	85 db                	test   %ebx,%ebx
f0100fc0:	74 02                	je     f0100fc4 <page_lookup+0x29>
		*pte_store = pte;	//found and set
f0100fc2:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fc4:	8b 00                	mov    (%eax),%eax
f0100fc6:	c1 e8 0c             	shr    $0xc,%eax
f0100fc9:	3b 05 44 dc 17 f0    	cmp    0xf017dc44,%eax
f0100fcf:	72 14                	jb     f0100fe5 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f0100fd1:	83 ec 04             	sub    $0x4,%esp
f0100fd4:	68 28 52 10 f0       	push   $0xf0105228
f0100fd9:	6a 4f                	push   $0x4f
f0100fdb:	68 7c 4d 10 f0       	push   $0xf0104d7c
f0100fe0:	e8 bb f0 ff ff       	call   f01000a0 <_panic>
	return &pages[PGNUM(pa)];
f0100fe5:	8b 15 4c dc 17 f0    	mov    0xf017dc4c,%edx
f0100feb:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return pa2page(PTE_ADDR(*pte));		
f0100fee:	eb 0c                	jmp    f0100ffc <page_lookup+0x61>
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f0100ff0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ff5:	eb 05                	jmp    f0100ffc <page_lookup+0x61>
f0100ff7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pte_store)
		*pte_store = pte;	//found and set
	return pa2page(PTE_ADDR(*pte));		
}
f0100ffc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100fff:	c9                   	leave  
f0101000:	c3                   	ret    

f0101001 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101001:	55                   	push   %ebp
f0101002:	89 e5                	mov    %esp,%ebp
f0101004:	53                   	push   %ebx
f0101005:	83 ec 18             	sub    $0x18,%esp
f0101008:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte;
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f010100b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010100e:	50                   	push   %eax
f010100f:	53                   	push   %ebx
f0101010:	ff 75 08             	pushl  0x8(%ebp)
f0101013:	e8 83 ff ff ff       	call   f0100f9b <page_lookup>
	if (!pg || !(*pte & PTE_P)) return;	//page not exist
f0101018:	83 c4 10             	add    $0x10,%esp
f010101b:	85 c0                	test   %eax,%eax
f010101d:	74 20                	je     f010103f <page_remove+0x3e>
f010101f:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101022:	f6 02 01             	testb  $0x1,(%edx)
f0101025:	74 18                	je     f010103f <page_remove+0x3e>
//   - The ref count on the physical page should decrement.
//   - The physical page should be freed if the refcount reaches 0.
	page_decref(pg);
f0101027:	83 ec 0c             	sub    $0xc,%esp
f010102a:	50                   	push   %eax
f010102b:	e8 2f fe ff ff       	call   f0100e5f <page_decref>
//   - The pg table entry corresponding to 'va' should be set to 0.
	*pte = 0;
f0101030:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101033:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101039:	0f 01 3b             	invlpg (%ebx)
f010103c:	83 c4 10             	add    $0x10,%esp
//   - The TLB must be invalidated if you remove an entry from
//     the page table.
	tlb_invalidate(pgdir, va);
}
f010103f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101042:	c9                   	leave  
f0101043:	c3                   	ret    

f0101044 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101044:	55                   	push   %ebp
f0101045:	89 e5                	mov    %esp,%ebp
f0101047:	57                   	push   %edi
f0101048:	56                   	push   %esi
f0101049:	53                   	push   %ebx
f010104a:	83 ec 10             	sub    $0x10,%esp
f010104d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101050:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
f0101053:	6a 01                	push   $0x1
f0101055:	57                   	push   %edi
f0101056:	ff 75 08             	pushl  0x8(%ebp)
f0101059:	e8 22 fe ff ff       	call   f0100e80 <pgdir_walk>
	if (!pte) 	//page table not allocated
f010105e:	83 c4 10             	add    $0x10,%esp
f0101061:	85 c0                	test   %eax,%eax
f0101063:	74 38                	je     f010109d <page_insert+0x59>
f0101065:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;	
	//increase ref count to avoid the corner case that pp is freed before it is inserted.
	pp->pp_ref++;	
f0101067:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
f010106c:	f6 00 01             	testb  $0x1,(%eax)
f010106f:	74 0f                	je     f0101080 <page_insert+0x3c>
		page_remove(pgdir, va);
f0101071:	83 ec 08             	sub    $0x8,%esp
f0101074:	57                   	push   %edi
f0101075:	ff 75 08             	pushl  0x8(%ebp)
f0101078:	e8 84 ff ff ff       	call   f0101001 <page_remove>
f010107d:	83 c4 10             	add    $0x10,%esp
	*pte = page2pa(pp) | perm | PTE_P;
f0101080:	2b 1d 4c dc 17 f0    	sub    0xf017dc4c,%ebx
f0101086:	c1 fb 03             	sar    $0x3,%ebx
f0101089:	c1 e3 0c             	shl    $0xc,%ebx
f010108c:	8b 45 14             	mov    0x14(%ebp),%eax
f010108f:	83 c8 01             	or     $0x1,%eax
f0101092:	09 c3                	or     %eax,%ebx
f0101094:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101096:	b8 00 00 00 00       	mov    $0x0,%eax
f010109b:	eb 05                	jmp    f01010a2 <page_insert+0x5e>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
	if (!pte) 	//page table not allocated
		return -E_NO_MEM;	
f010109d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	pp->pp_ref++;	
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
		page_remove(pgdir, va);
	*pte = page2pa(pp) | perm | PTE_P;
	return 0;
}
f01010a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010a5:	5b                   	pop    %ebx
f01010a6:	5e                   	pop    %esi
f01010a7:	5f                   	pop    %edi
f01010a8:	5d                   	pop    %ebp
f01010a9:	c3                   	ret    

f01010aa <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01010aa:	55                   	push   %ebp
f01010ab:	89 e5                	mov    %esp,%ebp
f01010ad:	57                   	push   %edi
f01010ae:	56                   	push   %esi
f01010af:	53                   	push   %ebx
f01010b0:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01010b3:	6a 15                	push   $0x15
f01010b5:	e8 b7 1e 00 00       	call   f0102f71 <mc146818_read>
f01010ba:	89 c3                	mov    %eax,%ebx
f01010bc:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01010c3:	e8 a9 1e 00 00       	call   f0102f71 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01010c8:	c1 e0 08             	shl    $0x8,%eax
f01010cb:	09 d8                	or     %ebx,%eax
f01010cd:	c1 e0 0a             	shl    $0xa,%eax
f01010d0:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01010d6:	85 c0                	test   %eax,%eax
f01010d8:	0f 48 c2             	cmovs  %edx,%eax
f01010db:	c1 f8 0c             	sar    $0xc,%eax
f01010de:	a3 84 cf 17 f0       	mov    %eax,0xf017cf84
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01010e3:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01010ea:	e8 82 1e 00 00       	call   f0102f71 <mc146818_read>
f01010ef:	89 c3                	mov    %eax,%ebx
f01010f1:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01010f8:	e8 74 1e 00 00       	call   f0102f71 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01010fd:	c1 e0 08             	shl    $0x8,%eax
f0101100:	09 d8                	or     %ebx,%eax
f0101102:	c1 e0 0a             	shl    $0xa,%eax
f0101105:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010110b:	83 c4 10             	add    $0x10,%esp
f010110e:	85 c0                	test   %eax,%eax
f0101110:	0f 48 c2             	cmovs  %edx,%eax
f0101113:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101116:	85 c0                	test   %eax,%eax
f0101118:	74 0e                	je     f0101128 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010111a:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101120:	89 15 44 dc 17 f0    	mov    %edx,0xf017dc44
f0101126:	eb 0c                	jmp    f0101134 <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101128:	8b 15 84 cf 17 f0    	mov    0xf017cf84,%edx
f010112e:	89 15 44 dc 17 f0    	mov    %edx,0xf017dc44

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101134:	c1 e0 0c             	shl    $0xc,%eax
f0101137:	c1 e8 0a             	shr    $0xa,%eax
f010113a:	50                   	push   %eax
f010113b:	a1 84 cf 17 f0       	mov    0xf017cf84,%eax
f0101140:	c1 e0 0c             	shl    $0xc,%eax
f0101143:	c1 e8 0a             	shr    $0xa,%eax
f0101146:	50                   	push   %eax
f0101147:	a1 44 dc 17 f0       	mov    0xf017dc44,%eax
f010114c:	c1 e0 0c             	shl    $0xc,%eax
f010114f:	c1 e8 0a             	shr    $0xa,%eax
f0101152:	50                   	push   %eax
f0101153:	68 48 52 10 f0       	push   $0xf0105248
f0101158:	e8 7b 1e 00 00       	call   f0102fd8 <cprintf>
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.

	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010115d:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101162:	e8 f0 f7 ff ff       	call   f0100957 <boot_alloc>
f0101167:	a3 48 dc 17 f0       	mov    %eax,0xf017dc48
	memset(kern_pgdir, 0, PGSIZE);
f010116c:	83 c4 0c             	add    $0xc,%esp
f010116f:	68 00 10 00 00       	push   $0x1000
f0101174:	6a 00                	push   $0x0
f0101176:	50                   	push   %eax
f0101177:	e8 0e 32 00 00       	call   f010438a <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010117c:	a1 48 dc 17 f0       	mov    0xf017dc48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101181:	83 c4 10             	add    $0x10,%esp
f0101184:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101189:	77 15                	ja     f01011a0 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010118b:	50                   	push   %eax
f010118c:	68 84 52 10 f0       	push   $0xf0105284
f0101191:	68 91 00 00 00       	push   $0x91
f0101196:	68 70 4d 10 f0       	push   $0xf0104d70
f010119b:	e8 00 ef ff ff       	call   f01000a0 <_panic>
f01011a0:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01011a6:	83 ca 05             	or     $0x5,%edx
f01011a9:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
f01011af:	a1 44 dc 17 f0       	mov    0xf017dc44,%eax
f01011b4:	c1 e0 03             	shl    $0x3,%eax
f01011b7:	e8 9b f7 ff ff       	call   f0100957 <boot_alloc>
f01011bc:	a3 4c dc 17 f0       	mov    %eax,0xf017dc4c

	cprintf("npages: %d\n", npages);
f01011c1:	83 ec 08             	sub    $0x8,%esp
f01011c4:	ff 35 44 dc 17 f0    	pushl  0xf017dc44
f01011ca:	68 49 4e 10 f0       	push   $0xf0104e49
f01011cf:	e8 04 1e 00 00       	call   f0102fd8 <cprintf>
	cprintf("npages_basemem: %d\n", npages_basemem);
f01011d4:	83 c4 08             	add    $0x8,%esp
f01011d7:	ff 35 84 cf 17 f0    	pushl  0xf017cf84
f01011dd:	68 55 4e 10 f0       	push   $0xf0104e55
f01011e2:	e8 f1 1d 00 00       	call   f0102fd8 <cprintf>
	cprintf("pages: %x\n", pages);
f01011e7:	83 c4 08             	add    $0x8,%esp
f01011ea:	ff 35 4c dc 17 f0    	pushl  0xf017dc4c
f01011f0:	68 69 4e 10 f0       	push   $0xf0104e69
f01011f5:	e8 de 1d 00 00       	call   f0102fd8 <cprintf>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *) boot_alloc(sizeof(struct Env) * NENV);
f01011fa:	b8 00 80 01 00       	mov    $0x18000,%eax
f01011ff:	e8 53 f7 ff ff       	call   f0100957 <boot_alloc>
f0101204:	a3 8c cf 17 f0       	mov    %eax,0xf017cf8c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101209:	e8 e8 fa ff ff       	call   f0100cf6 <page_init>

	check_page_free_list(1);
f010120e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101213:	e8 1b f8 ff ff       	call   f0100a33 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101218:	83 c4 10             	add    $0x10,%esp
f010121b:	83 3d 4c dc 17 f0 00 	cmpl   $0x0,0xf017dc4c
f0101222:	75 17                	jne    f010123b <mem_init+0x191>
		panic("'pages' is a null pointer!");
f0101224:	83 ec 04             	sub    $0x4,%esp
f0101227:	68 74 4e 10 f0       	push   $0xf0104e74
f010122c:	68 9f 02 00 00       	push   $0x29f
f0101231:	68 70 4d 10 f0       	push   $0xf0104d70
f0101236:	e8 65 ee ff ff       	call   f01000a0 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010123b:	a1 80 cf 17 f0       	mov    0xf017cf80,%eax
f0101240:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101245:	eb 05                	jmp    f010124c <mem_init+0x1a2>
		++nfree;
f0101247:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010124a:	8b 00                	mov    (%eax),%eax
f010124c:	85 c0                	test   %eax,%eax
f010124e:	75 f7                	jne    f0101247 <mem_init+0x19d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101250:	83 ec 0c             	sub    $0xc,%esp
f0101253:	6a 00                	push   $0x0
f0101255:	e8 86 fb ff ff       	call   f0100de0 <page_alloc>
f010125a:	89 c7                	mov    %eax,%edi
f010125c:	83 c4 10             	add    $0x10,%esp
f010125f:	85 c0                	test   %eax,%eax
f0101261:	75 19                	jne    f010127c <mem_init+0x1d2>
f0101263:	68 8f 4e 10 f0       	push   $0xf0104e8f
f0101268:	68 96 4d 10 f0       	push   $0xf0104d96
f010126d:	68 a7 02 00 00       	push   $0x2a7
f0101272:	68 70 4d 10 f0       	push   $0xf0104d70
f0101277:	e8 24 ee ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f010127c:	83 ec 0c             	sub    $0xc,%esp
f010127f:	6a 00                	push   $0x0
f0101281:	e8 5a fb ff ff       	call   f0100de0 <page_alloc>
f0101286:	89 c6                	mov    %eax,%esi
f0101288:	83 c4 10             	add    $0x10,%esp
f010128b:	85 c0                	test   %eax,%eax
f010128d:	75 19                	jne    f01012a8 <mem_init+0x1fe>
f010128f:	68 a5 4e 10 f0       	push   $0xf0104ea5
f0101294:	68 96 4d 10 f0       	push   $0xf0104d96
f0101299:	68 a8 02 00 00       	push   $0x2a8
f010129e:	68 70 4d 10 f0       	push   $0xf0104d70
f01012a3:	e8 f8 ed ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01012a8:	83 ec 0c             	sub    $0xc,%esp
f01012ab:	6a 00                	push   $0x0
f01012ad:	e8 2e fb ff ff       	call   f0100de0 <page_alloc>
f01012b2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01012b5:	83 c4 10             	add    $0x10,%esp
f01012b8:	85 c0                	test   %eax,%eax
f01012ba:	75 19                	jne    f01012d5 <mem_init+0x22b>
f01012bc:	68 bb 4e 10 f0       	push   $0xf0104ebb
f01012c1:	68 96 4d 10 f0       	push   $0xf0104d96
f01012c6:	68 a9 02 00 00       	push   $0x2a9
f01012cb:	68 70 4d 10 f0       	push   $0xf0104d70
f01012d0:	e8 cb ed ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01012d5:	39 f7                	cmp    %esi,%edi
f01012d7:	75 19                	jne    f01012f2 <mem_init+0x248>
f01012d9:	68 d1 4e 10 f0       	push   $0xf0104ed1
f01012de:	68 96 4d 10 f0       	push   $0xf0104d96
f01012e3:	68 ac 02 00 00       	push   $0x2ac
f01012e8:	68 70 4d 10 f0       	push   $0xf0104d70
f01012ed:	e8 ae ed ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01012f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012f5:	39 c6                	cmp    %eax,%esi
f01012f7:	74 04                	je     f01012fd <mem_init+0x253>
f01012f9:	39 c7                	cmp    %eax,%edi
f01012fb:	75 19                	jne    f0101316 <mem_init+0x26c>
f01012fd:	68 a8 52 10 f0       	push   $0xf01052a8
f0101302:	68 96 4d 10 f0       	push   $0xf0104d96
f0101307:	68 ad 02 00 00       	push   $0x2ad
f010130c:	68 70 4d 10 f0       	push   $0xf0104d70
f0101311:	e8 8a ed ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101316:	8b 0d 4c dc 17 f0    	mov    0xf017dc4c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010131c:	8b 15 44 dc 17 f0    	mov    0xf017dc44,%edx
f0101322:	c1 e2 0c             	shl    $0xc,%edx
f0101325:	89 f8                	mov    %edi,%eax
f0101327:	29 c8                	sub    %ecx,%eax
f0101329:	c1 f8 03             	sar    $0x3,%eax
f010132c:	c1 e0 0c             	shl    $0xc,%eax
f010132f:	39 d0                	cmp    %edx,%eax
f0101331:	72 19                	jb     f010134c <mem_init+0x2a2>
f0101333:	68 e3 4e 10 f0       	push   $0xf0104ee3
f0101338:	68 96 4d 10 f0       	push   $0xf0104d96
f010133d:	68 ae 02 00 00       	push   $0x2ae
f0101342:	68 70 4d 10 f0       	push   $0xf0104d70
f0101347:	e8 54 ed ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010134c:	89 f0                	mov    %esi,%eax
f010134e:	29 c8                	sub    %ecx,%eax
f0101350:	c1 f8 03             	sar    $0x3,%eax
f0101353:	c1 e0 0c             	shl    $0xc,%eax
f0101356:	39 c2                	cmp    %eax,%edx
f0101358:	77 19                	ja     f0101373 <mem_init+0x2c9>
f010135a:	68 00 4f 10 f0       	push   $0xf0104f00
f010135f:	68 96 4d 10 f0       	push   $0xf0104d96
f0101364:	68 af 02 00 00       	push   $0x2af
f0101369:	68 70 4d 10 f0       	push   $0xf0104d70
f010136e:	e8 2d ed ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101373:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101376:	29 c8                	sub    %ecx,%eax
f0101378:	c1 f8 03             	sar    $0x3,%eax
f010137b:	c1 e0 0c             	shl    $0xc,%eax
f010137e:	39 c2                	cmp    %eax,%edx
f0101380:	77 19                	ja     f010139b <mem_init+0x2f1>
f0101382:	68 1d 4f 10 f0       	push   $0xf0104f1d
f0101387:	68 96 4d 10 f0       	push   $0xf0104d96
f010138c:	68 b0 02 00 00       	push   $0x2b0
f0101391:	68 70 4d 10 f0       	push   $0xf0104d70
f0101396:	e8 05 ed ff ff       	call   f01000a0 <_panic>


	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010139b:	a1 80 cf 17 f0       	mov    0xf017cf80,%eax
f01013a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01013a3:	c7 05 80 cf 17 f0 00 	movl   $0x0,0xf017cf80
f01013aa:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01013ad:	83 ec 0c             	sub    $0xc,%esp
f01013b0:	6a 00                	push   $0x0
f01013b2:	e8 29 fa ff ff       	call   f0100de0 <page_alloc>
f01013b7:	83 c4 10             	add    $0x10,%esp
f01013ba:	85 c0                	test   %eax,%eax
f01013bc:	74 19                	je     f01013d7 <mem_init+0x32d>
f01013be:	68 3a 4f 10 f0       	push   $0xf0104f3a
f01013c3:	68 96 4d 10 f0       	push   $0xf0104d96
f01013c8:	68 b8 02 00 00       	push   $0x2b8
f01013cd:	68 70 4d 10 f0       	push   $0xf0104d70
f01013d2:	e8 c9 ec ff ff       	call   f01000a0 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01013d7:	83 ec 0c             	sub    $0xc,%esp
f01013da:	57                   	push   %edi
f01013db:	e8 6a fa ff ff       	call   f0100e4a <page_free>
	page_free(pp1);
f01013e0:	89 34 24             	mov    %esi,(%esp)
f01013e3:	e8 62 fa ff ff       	call   f0100e4a <page_free>
	page_free(pp2);
f01013e8:	83 c4 04             	add    $0x4,%esp
f01013eb:	ff 75 d4             	pushl  -0x2c(%ebp)
f01013ee:	e8 57 fa ff ff       	call   f0100e4a <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01013f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01013fa:	e8 e1 f9 ff ff       	call   f0100de0 <page_alloc>
f01013ff:	89 c6                	mov    %eax,%esi
f0101401:	83 c4 10             	add    $0x10,%esp
f0101404:	85 c0                	test   %eax,%eax
f0101406:	75 19                	jne    f0101421 <mem_init+0x377>
f0101408:	68 8f 4e 10 f0       	push   $0xf0104e8f
f010140d:	68 96 4d 10 f0       	push   $0xf0104d96
f0101412:	68 bf 02 00 00       	push   $0x2bf
f0101417:	68 70 4d 10 f0       	push   $0xf0104d70
f010141c:	e8 7f ec ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0101421:	83 ec 0c             	sub    $0xc,%esp
f0101424:	6a 00                	push   $0x0
f0101426:	e8 b5 f9 ff ff       	call   f0100de0 <page_alloc>
f010142b:	89 c7                	mov    %eax,%edi
f010142d:	83 c4 10             	add    $0x10,%esp
f0101430:	85 c0                	test   %eax,%eax
f0101432:	75 19                	jne    f010144d <mem_init+0x3a3>
f0101434:	68 a5 4e 10 f0       	push   $0xf0104ea5
f0101439:	68 96 4d 10 f0       	push   $0xf0104d96
f010143e:	68 c0 02 00 00       	push   $0x2c0
f0101443:	68 70 4d 10 f0       	push   $0xf0104d70
f0101448:	e8 53 ec ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f010144d:	83 ec 0c             	sub    $0xc,%esp
f0101450:	6a 00                	push   $0x0
f0101452:	e8 89 f9 ff ff       	call   f0100de0 <page_alloc>
f0101457:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010145a:	83 c4 10             	add    $0x10,%esp
f010145d:	85 c0                	test   %eax,%eax
f010145f:	75 19                	jne    f010147a <mem_init+0x3d0>
f0101461:	68 bb 4e 10 f0       	push   $0xf0104ebb
f0101466:	68 96 4d 10 f0       	push   $0xf0104d96
f010146b:	68 c1 02 00 00       	push   $0x2c1
f0101470:	68 70 4d 10 f0       	push   $0xf0104d70
f0101475:	e8 26 ec ff ff       	call   f01000a0 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010147a:	39 fe                	cmp    %edi,%esi
f010147c:	75 19                	jne    f0101497 <mem_init+0x3ed>
f010147e:	68 d1 4e 10 f0       	push   $0xf0104ed1
f0101483:	68 96 4d 10 f0       	push   $0xf0104d96
f0101488:	68 c3 02 00 00       	push   $0x2c3
f010148d:	68 70 4d 10 f0       	push   $0xf0104d70
f0101492:	e8 09 ec ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101497:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010149a:	39 c7                	cmp    %eax,%edi
f010149c:	74 04                	je     f01014a2 <mem_init+0x3f8>
f010149e:	39 c6                	cmp    %eax,%esi
f01014a0:	75 19                	jne    f01014bb <mem_init+0x411>
f01014a2:	68 a8 52 10 f0       	push   $0xf01052a8
f01014a7:	68 96 4d 10 f0       	push   $0xf0104d96
f01014ac:	68 c4 02 00 00       	push   $0x2c4
f01014b1:	68 70 4d 10 f0       	push   $0xf0104d70
f01014b6:	e8 e5 eb ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f01014bb:	83 ec 0c             	sub    $0xc,%esp
f01014be:	6a 00                	push   $0x0
f01014c0:	e8 1b f9 ff ff       	call   f0100de0 <page_alloc>
f01014c5:	83 c4 10             	add    $0x10,%esp
f01014c8:	85 c0                	test   %eax,%eax
f01014ca:	74 19                	je     f01014e5 <mem_init+0x43b>
f01014cc:	68 3a 4f 10 f0       	push   $0xf0104f3a
f01014d1:	68 96 4d 10 f0       	push   $0xf0104d96
f01014d6:	68 c5 02 00 00       	push   $0x2c5
f01014db:	68 70 4d 10 f0       	push   $0xf0104d70
f01014e0:	e8 bb eb ff ff       	call   f01000a0 <_panic>
f01014e5:	89 f0                	mov    %esi,%eax
f01014e7:	2b 05 4c dc 17 f0    	sub    0xf017dc4c,%eax
f01014ed:	c1 f8 03             	sar    $0x3,%eax
f01014f0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014f3:	89 c2                	mov    %eax,%edx
f01014f5:	c1 ea 0c             	shr    $0xc,%edx
f01014f8:	3b 15 44 dc 17 f0    	cmp    0xf017dc44,%edx
f01014fe:	72 12                	jb     f0101512 <mem_init+0x468>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101500:	50                   	push   %eax
f0101501:	68 e4 50 10 f0       	push   $0xf01050e4
f0101506:	6a 56                	push   $0x56
f0101508:	68 7c 4d 10 f0       	push   $0xf0104d7c
f010150d:	e8 8e eb ff ff       	call   f01000a0 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101512:	83 ec 04             	sub    $0x4,%esp
f0101515:	68 00 10 00 00       	push   $0x1000
f010151a:	6a 01                	push   $0x1
f010151c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101521:	50                   	push   %eax
f0101522:	e8 63 2e 00 00       	call   f010438a <memset>
	page_free(pp0);
f0101527:	89 34 24             	mov    %esi,(%esp)
f010152a:	e8 1b f9 ff ff       	call   f0100e4a <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010152f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101536:	e8 a5 f8 ff ff       	call   f0100de0 <page_alloc>
f010153b:	83 c4 10             	add    $0x10,%esp
f010153e:	85 c0                	test   %eax,%eax
f0101540:	75 19                	jne    f010155b <mem_init+0x4b1>
f0101542:	68 49 4f 10 f0       	push   $0xf0104f49
f0101547:	68 96 4d 10 f0       	push   $0xf0104d96
f010154c:	68 ca 02 00 00       	push   $0x2ca
f0101551:	68 70 4d 10 f0       	push   $0xf0104d70
f0101556:	e8 45 eb ff ff       	call   f01000a0 <_panic>
	assert(pp && pp0 == pp);
f010155b:	39 c6                	cmp    %eax,%esi
f010155d:	74 19                	je     f0101578 <mem_init+0x4ce>
f010155f:	68 67 4f 10 f0       	push   $0xf0104f67
f0101564:	68 96 4d 10 f0       	push   $0xf0104d96
f0101569:	68 cb 02 00 00       	push   $0x2cb
f010156e:	68 70 4d 10 f0       	push   $0xf0104d70
f0101573:	e8 28 eb ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101578:	89 f0                	mov    %esi,%eax
f010157a:	2b 05 4c dc 17 f0    	sub    0xf017dc4c,%eax
f0101580:	c1 f8 03             	sar    $0x3,%eax
f0101583:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101586:	89 c2                	mov    %eax,%edx
f0101588:	c1 ea 0c             	shr    $0xc,%edx
f010158b:	3b 15 44 dc 17 f0    	cmp    0xf017dc44,%edx
f0101591:	72 12                	jb     f01015a5 <mem_init+0x4fb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101593:	50                   	push   %eax
f0101594:	68 e4 50 10 f0       	push   $0xf01050e4
f0101599:	6a 56                	push   $0x56
f010159b:	68 7c 4d 10 f0       	push   $0xf0104d7c
f01015a0:	e8 fb ea ff ff       	call   f01000a0 <_panic>
f01015a5:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01015ab:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01015b1:	80 38 00             	cmpb   $0x0,(%eax)
f01015b4:	74 19                	je     f01015cf <mem_init+0x525>
f01015b6:	68 77 4f 10 f0       	push   $0xf0104f77
f01015bb:	68 96 4d 10 f0       	push   $0xf0104d96
f01015c0:	68 ce 02 00 00       	push   $0x2ce
f01015c5:	68 70 4d 10 f0       	push   $0xf0104d70
f01015ca:	e8 d1 ea ff ff       	call   f01000a0 <_panic>
f01015cf:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01015d2:	39 d0                	cmp    %edx,%eax
f01015d4:	75 db                	jne    f01015b1 <mem_init+0x507>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01015d6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01015d9:	a3 80 cf 17 f0       	mov    %eax,0xf017cf80

	// free the pages we took
	page_free(pp0);
f01015de:	83 ec 0c             	sub    $0xc,%esp
f01015e1:	56                   	push   %esi
f01015e2:	e8 63 f8 ff ff       	call   f0100e4a <page_free>
	page_free(pp1);
f01015e7:	89 3c 24             	mov    %edi,(%esp)
f01015ea:	e8 5b f8 ff ff       	call   f0100e4a <page_free>
	page_free(pp2);
f01015ef:	83 c4 04             	add    $0x4,%esp
f01015f2:	ff 75 d4             	pushl  -0x2c(%ebp)
f01015f5:	e8 50 f8 ff ff       	call   f0100e4a <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01015fa:	a1 80 cf 17 f0       	mov    0xf017cf80,%eax
f01015ff:	83 c4 10             	add    $0x10,%esp
f0101602:	eb 05                	jmp    f0101609 <mem_init+0x55f>
		--nfree;
f0101604:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101607:	8b 00                	mov    (%eax),%eax
f0101609:	85 c0                	test   %eax,%eax
f010160b:	75 f7                	jne    f0101604 <mem_init+0x55a>
		--nfree;
	assert(nfree == 0);
f010160d:	85 db                	test   %ebx,%ebx
f010160f:	74 19                	je     f010162a <mem_init+0x580>
f0101611:	68 81 4f 10 f0       	push   $0xf0104f81
f0101616:	68 96 4d 10 f0       	push   $0xf0104d96
f010161b:	68 db 02 00 00       	push   $0x2db
f0101620:	68 70 4d 10 f0       	push   $0xf0104d70
f0101625:	e8 76 ea ff ff       	call   f01000a0 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010162a:	83 ec 0c             	sub    $0xc,%esp
f010162d:	68 c8 52 10 f0       	push   $0xf01052c8
f0101632:	e8 a1 19 00 00       	call   f0102fd8 <cprintf>
	// or page_insert
	page_init();

	check_page_free_list(1);
	check_page_alloc();
	cprintf("so far so good\n");
f0101637:	c7 04 24 8c 4f 10 f0 	movl   $0xf0104f8c,(%esp)
f010163e:	e8 95 19 00 00       	call   f0102fd8 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101643:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010164a:	e8 91 f7 ff ff       	call   f0100de0 <page_alloc>
f010164f:	89 c6                	mov    %eax,%esi
f0101651:	83 c4 10             	add    $0x10,%esp
f0101654:	85 c0                	test   %eax,%eax
f0101656:	75 19                	jne    f0101671 <mem_init+0x5c7>
f0101658:	68 8f 4e 10 f0       	push   $0xf0104e8f
f010165d:	68 96 4d 10 f0       	push   $0xf0104d96
f0101662:	68 39 03 00 00       	push   $0x339
f0101667:	68 70 4d 10 f0       	push   $0xf0104d70
f010166c:	e8 2f ea ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0101671:	83 ec 0c             	sub    $0xc,%esp
f0101674:	6a 00                	push   $0x0
f0101676:	e8 65 f7 ff ff       	call   f0100de0 <page_alloc>
f010167b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010167e:	83 c4 10             	add    $0x10,%esp
f0101681:	85 c0                	test   %eax,%eax
f0101683:	75 19                	jne    f010169e <mem_init+0x5f4>
f0101685:	68 a5 4e 10 f0       	push   $0xf0104ea5
f010168a:	68 96 4d 10 f0       	push   $0xf0104d96
f010168f:	68 3a 03 00 00       	push   $0x33a
f0101694:	68 70 4d 10 f0       	push   $0xf0104d70
f0101699:	e8 02 ea ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f010169e:	83 ec 0c             	sub    $0xc,%esp
f01016a1:	6a 00                	push   $0x0
f01016a3:	e8 38 f7 ff ff       	call   f0100de0 <page_alloc>
f01016a8:	89 c3                	mov    %eax,%ebx
f01016aa:	83 c4 10             	add    $0x10,%esp
f01016ad:	85 c0                	test   %eax,%eax
f01016af:	75 19                	jne    f01016ca <mem_init+0x620>
f01016b1:	68 bb 4e 10 f0       	push   $0xf0104ebb
f01016b6:	68 96 4d 10 f0       	push   $0xf0104d96
f01016bb:	68 3b 03 00 00       	push   $0x33b
f01016c0:	68 70 4d 10 f0       	push   $0xf0104d70
f01016c5:	e8 d6 e9 ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01016ca:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01016cd:	75 19                	jne    f01016e8 <mem_init+0x63e>
f01016cf:	68 d1 4e 10 f0       	push   $0xf0104ed1
f01016d4:	68 96 4d 10 f0       	push   $0xf0104d96
f01016d9:	68 3e 03 00 00       	push   $0x33e
f01016de:	68 70 4d 10 f0       	push   $0xf0104d70
f01016e3:	e8 b8 e9 ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016e8:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01016eb:	74 04                	je     f01016f1 <mem_init+0x647>
f01016ed:	39 c6                	cmp    %eax,%esi
f01016ef:	75 19                	jne    f010170a <mem_init+0x660>
f01016f1:	68 a8 52 10 f0       	push   $0xf01052a8
f01016f6:	68 96 4d 10 f0       	push   $0xf0104d96
f01016fb:	68 3f 03 00 00       	push   $0x33f
f0101700:	68 70 4d 10 f0       	push   $0xf0104d70
f0101705:	e8 96 e9 ff ff       	call   f01000a0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010170a:	a1 80 cf 17 f0       	mov    0xf017cf80,%eax
f010170f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101712:	c7 05 80 cf 17 f0 00 	movl   $0x0,0xf017cf80
f0101719:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010171c:	83 ec 0c             	sub    $0xc,%esp
f010171f:	6a 00                	push   $0x0
f0101721:	e8 ba f6 ff ff       	call   f0100de0 <page_alloc>
f0101726:	83 c4 10             	add    $0x10,%esp
f0101729:	85 c0                	test   %eax,%eax
f010172b:	74 19                	je     f0101746 <mem_init+0x69c>
f010172d:	68 3a 4f 10 f0       	push   $0xf0104f3a
f0101732:	68 96 4d 10 f0       	push   $0xf0104d96
f0101737:	68 46 03 00 00       	push   $0x346
f010173c:	68 70 4d 10 f0       	push   $0xf0104d70
f0101741:	e8 5a e9 ff ff       	call   f01000a0 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101746:	83 ec 04             	sub    $0x4,%esp
f0101749:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010174c:	50                   	push   %eax
f010174d:	6a 00                	push   $0x0
f010174f:	ff 35 48 dc 17 f0    	pushl  0xf017dc48
f0101755:	e8 41 f8 ff ff       	call   f0100f9b <page_lookup>
f010175a:	83 c4 10             	add    $0x10,%esp
f010175d:	85 c0                	test   %eax,%eax
f010175f:	74 19                	je     f010177a <mem_init+0x6d0>
f0101761:	68 e8 52 10 f0       	push   $0xf01052e8
f0101766:	68 96 4d 10 f0       	push   $0xf0104d96
f010176b:	68 49 03 00 00       	push   $0x349
f0101770:	68 70 4d 10 f0       	push   $0xf0104d70
f0101775:	e8 26 e9 ff ff       	call   f01000a0 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010177a:	6a 02                	push   $0x2
f010177c:	6a 00                	push   $0x0
f010177e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101781:	ff 35 48 dc 17 f0    	pushl  0xf017dc48
f0101787:	e8 b8 f8 ff ff       	call   f0101044 <page_insert>
f010178c:	83 c4 10             	add    $0x10,%esp
f010178f:	85 c0                	test   %eax,%eax
f0101791:	78 19                	js     f01017ac <mem_init+0x702>
f0101793:	68 20 53 10 f0       	push   $0xf0105320
f0101798:	68 96 4d 10 f0       	push   $0xf0104d96
f010179d:	68 4c 03 00 00       	push   $0x34c
f01017a2:	68 70 4d 10 f0       	push   $0xf0104d70
f01017a7:	e8 f4 e8 ff ff       	call   f01000a0 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01017ac:	83 ec 0c             	sub    $0xc,%esp
f01017af:	56                   	push   %esi
f01017b0:	e8 95 f6 ff ff       	call   f0100e4a <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01017b5:	6a 02                	push   $0x2
f01017b7:	6a 00                	push   $0x0
f01017b9:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017bc:	ff 35 48 dc 17 f0    	pushl  0xf017dc48
f01017c2:	e8 7d f8 ff ff       	call   f0101044 <page_insert>
f01017c7:	83 c4 20             	add    $0x20,%esp
f01017ca:	85 c0                	test   %eax,%eax
f01017cc:	74 19                	je     f01017e7 <mem_init+0x73d>
f01017ce:	68 50 53 10 f0       	push   $0xf0105350
f01017d3:	68 96 4d 10 f0       	push   $0xf0104d96
f01017d8:	68 50 03 00 00       	push   $0x350
f01017dd:	68 70 4d 10 f0       	push   $0xf0104d70
f01017e2:	e8 b9 e8 ff ff       	call   f01000a0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01017e7:	8b 3d 48 dc 17 f0    	mov    0xf017dc48,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017ed:	a1 4c dc 17 f0       	mov    0xf017dc4c,%eax
f01017f2:	89 c1                	mov    %eax,%ecx
f01017f4:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01017f7:	8b 17                	mov    (%edi),%edx
f01017f9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01017ff:	89 f0                	mov    %esi,%eax
f0101801:	29 c8                	sub    %ecx,%eax
f0101803:	c1 f8 03             	sar    $0x3,%eax
f0101806:	c1 e0 0c             	shl    $0xc,%eax
f0101809:	39 c2                	cmp    %eax,%edx
f010180b:	74 19                	je     f0101826 <mem_init+0x77c>
f010180d:	68 80 53 10 f0       	push   $0xf0105380
f0101812:	68 96 4d 10 f0       	push   $0xf0104d96
f0101817:	68 51 03 00 00       	push   $0x351
f010181c:	68 70 4d 10 f0       	push   $0xf0104d70
f0101821:	e8 7a e8 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101826:	ba 00 00 00 00       	mov    $0x0,%edx
f010182b:	89 f8                	mov    %edi,%eax
f010182d:	e8 9d f1 ff ff       	call   f01009cf <check_va2pa>
f0101832:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101835:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101838:	c1 fa 03             	sar    $0x3,%edx
f010183b:	c1 e2 0c             	shl    $0xc,%edx
f010183e:	39 d0                	cmp    %edx,%eax
f0101840:	74 19                	je     f010185b <mem_init+0x7b1>
f0101842:	68 a8 53 10 f0       	push   $0xf01053a8
f0101847:	68 96 4d 10 f0       	push   $0xf0104d96
f010184c:	68 52 03 00 00       	push   $0x352
f0101851:	68 70 4d 10 f0       	push   $0xf0104d70
f0101856:	e8 45 e8 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f010185b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010185e:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101863:	74 19                	je     f010187e <mem_init+0x7d4>
f0101865:	68 9c 4f 10 f0       	push   $0xf0104f9c
f010186a:	68 96 4d 10 f0       	push   $0xf0104d96
f010186f:	68 53 03 00 00       	push   $0x353
f0101874:	68 70 4d 10 f0       	push   $0xf0104d70
f0101879:	e8 22 e8 ff ff       	call   f01000a0 <_panic>
	assert(pp0->pp_ref == 1);
f010187e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101883:	74 19                	je     f010189e <mem_init+0x7f4>
f0101885:	68 ad 4f 10 f0       	push   $0xf0104fad
f010188a:	68 96 4d 10 f0       	push   $0xf0104d96
f010188f:	68 54 03 00 00       	push   $0x354
f0101894:	68 70 4d 10 f0       	push   $0xf0104d70
f0101899:	e8 02 e8 ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010189e:	6a 02                	push   $0x2
f01018a0:	68 00 10 00 00       	push   $0x1000
f01018a5:	53                   	push   %ebx
f01018a6:	57                   	push   %edi
f01018a7:	e8 98 f7 ff ff       	call   f0101044 <page_insert>
f01018ac:	83 c4 10             	add    $0x10,%esp
f01018af:	85 c0                	test   %eax,%eax
f01018b1:	74 19                	je     f01018cc <mem_init+0x822>
f01018b3:	68 d8 53 10 f0       	push   $0xf01053d8
f01018b8:	68 96 4d 10 f0       	push   $0xf0104d96
f01018bd:	68 57 03 00 00       	push   $0x357
f01018c2:	68 70 4d 10 f0       	push   $0xf0104d70
f01018c7:	e8 d4 e7 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018cc:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018d1:	a1 48 dc 17 f0       	mov    0xf017dc48,%eax
f01018d6:	e8 f4 f0 ff ff       	call   f01009cf <check_va2pa>
f01018db:	89 da                	mov    %ebx,%edx
f01018dd:	2b 15 4c dc 17 f0    	sub    0xf017dc4c,%edx
f01018e3:	c1 fa 03             	sar    $0x3,%edx
f01018e6:	c1 e2 0c             	shl    $0xc,%edx
f01018e9:	39 d0                	cmp    %edx,%eax
f01018eb:	74 19                	je     f0101906 <mem_init+0x85c>
f01018ed:	68 14 54 10 f0       	push   $0xf0105414
f01018f2:	68 96 4d 10 f0       	push   $0xf0104d96
f01018f7:	68 58 03 00 00       	push   $0x358
f01018fc:	68 70 4d 10 f0       	push   $0xf0104d70
f0101901:	e8 9a e7 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101906:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010190b:	74 19                	je     f0101926 <mem_init+0x87c>
f010190d:	68 be 4f 10 f0       	push   $0xf0104fbe
f0101912:	68 96 4d 10 f0       	push   $0xf0104d96
f0101917:	68 59 03 00 00       	push   $0x359
f010191c:	68 70 4d 10 f0       	push   $0xf0104d70
f0101921:	e8 7a e7 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101926:	83 ec 0c             	sub    $0xc,%esp
f0101929:	6a 00                	push   $0x0
f010192b:	e8 b0 f4 ff ff       	call   f0100de0 <page_alloc>
f0101930:	83 c4 10             	add    $0x10,%esp
f0101933:	85 c0                	test   %eax,%eax
f0101935:	74 19                	je     f0101950 <mem_init+0x8a6>
f0101937:	68 3a 4f 10 f0       	push   $0xf0104f3a
f010193c:	68 96 4d 10 f0       	push   $0xf0104d96
f0101941:	68 5c 03 00 00       	push   $0x35c
f0101946:	68 70 4d 10 f0       	push   $0xf0104d70
f010194b:	e8 50 e7 ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101950:	6a 02                	push   $0x2
f0101952:	68 00 10 00 00       	push   $0x1000
f0101957:	53                   	push   %ebx
f0101958:	ff 35 48 dc 17 f0    	pushl  0xf017dc48
f010195e:	e8 e1 f6 ff ff       	call   f0101044 <page_insert>
f0101963:	83 c4 10             	add    $0x10,%esp
f0101966:	85 c0                	test   %eax,%eax
f0101968:	74 19                	je     f0101983 <mem_init+0x8d9>
f010196a:	68 d8 53 10 f0       	push   $0xf01053d8
f010196f:	68 96 4d 10 f0       	push   $0xf0104d96
f0101974:	68 5f 03 00 00       	push   $0x35f
f0101979:	68 70 4d 10 f0       	push   $0xf0104d70
f010197e:	e8 1d e7 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101983:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101988:	a1 48 dc 17 f0       	mov    0xf017dc48,%eax
f010198d:	e8 3d f0 ff ff       	call   f01009cf <check_va2pa>
f0101992:	89 da                	mov    %ebx,%edx
f0101994:	2b 15 4c dc 17 f0    	sub    0xf017dc4c,%edx
f010199a:	c1 fa 03             	sar    $0x3,%edx
f010199d:	c1 e2 0c             	shl    $0xc,%edx
f01019a0:	39 d0                	cmp    %edx,%eax
f01019a2:	74 19                	je     f01019bd <mem_init+0x913>
f01019a4:	68 14 54 10 f0       	push   $0xf0105414
f01019a9:	68 96 4d 10 f0       	push   $0xf0104d96
f01019ae:	68 60 03 00 00       	push   $0x360
f01019b3:	68 70 4d 10 f0       	push   $0xf0104d70
f01019b8:	e8 e3 e6 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f01019bd:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019c2:	74 19                	je     f01019dd <mem_init+0x933>
f01019c4:	68 be 4f 10 f0       	push   $0xf0104fbe
f01019c9:	68 96 4d 10 f0       	push   $0xf0104d96
f01019ce:	68 61 03 00 00       	push   $0x361
f01019d3:	68 70 4d 10 f0       	push   $0xf0104d70
f01019d8:	e8 c3 e6 ff ff       	call   f01000a0 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01019dd:	83 ec 0c             	sub    $0xc,%esp
f01019e0:	6a 00                	push   $0x0
f01019e2:	e8 f9 f3 ff ff       	call   f0100de0 <page_alloc>
f01019e7:	83 c4 10             	add    $0x10,%esp
f01019ea:	85 c0                	test   %eax,%eax
f01019ec:	74 19                	je     f0101a07 <mem_init+0x95d>
f01019ee:	68 3a 4f 10 f0       	push   $0xf0104f3a
f01019f3:	68 96 4d 10 f0       	push   $0xf0104d96
f01019f8:	68 65 03 00 00       	push   $0x365
f01019fd:	68 70 4d 10 f0       	push   $0xf0104d70
f0101a02:	e8 99 e6 ff ff       	call   f01000a0 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a07:	8b 15 48 dc 17 f0    	mov    0xf017dc48,%edx
f0101a0d:	8b 02                	mov    (%edx),%eax
f0101a0f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a14:	89 c1                	mov    %eax,%ecx
f0101a16:	c1 e9 0c             	shr    $0xc,%ecx
f0101a19:	3b 0d 44 dc 17 f0    	cmp    0xf017dc44,%ecx
f0101a1f:	72 15                	jb     f0101a36 <mem_init+0x98c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a21:	50                   	push   %eax
f0101a22:	68 e4 50 10 f0       	push   $0xf01050e4
f0101a27:	68 68 03 00 00       	push   $0x368
f0101a2c:	68 70 4d 10 f0       	push   $0xf0104d70
f0101a31:	e8 6a e6 ff ff       	call   f01000a0 <_panic>
f0101a36:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a3b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a3e:	83 ec 04             	sub    $0x4,%esp
f0101a41:	6a 00                	push   $0x0
f0101a43:	68 00 10 00 00       	push   $0x1000
f0101a48:	52                   	push   %edx
f0101a49:	e8 32 f4 ff ff       	call   f0100e80 <pgdir_walk>
f0101a4e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101a51:	8d 57 04             	lea    0x4(%edi),%edx
f0101a54:	83 c4 10             	add    $0x10,%esp
f0101a57:	39 d0                	cmp    %edx,%eax
f0101a59:	74 19                	je     f0101a74 <mem_init+0x9ca>
f0101a5b:	68 44 54 10 f0       	push   $0xf0105444
f0101a60:	68 96 4d 10 f0       	push   $0xf0104d96
f0101a65:	68 69 03 00 00       	push   $0x369
f0101a6a:	68 70 4d 10 f0       	push   $0xf0104d70
f0101a6f:	e8 2c e6 ff ff       	call   f01000a0 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101a74:	6a 06                	push   $0x6
f0101a76:	68 00 10 00 00       	push   $0x1000
f0101a7b:	53                   	push   %ebx
f0101a7c:	ff 35 48 dc 17 f0    	pushl  0xf017dc48
f0101a82:	e8 bd f5 ff ff       	call   f0101044 <page_insert>
f0101a87:	83 c4 10             	add    $0x10,%esp
f0101a8a:	85 c0                	test   %eax,%eax
f0101a8c:	74 19                	je     f0101aa7 <mem_init+0x9fd>
f0101a8e:	68 84 54 10 f0       	push   $0xf0105484
f0101a93:	68 96 4d 10 f0       	push   $0xf0104d96
f0101a98:	68 6c 03 00 00       	push   $0x36c
f0101a9d:	68 70 4d 10 f0       	push   $0xf0104d70
f0101aa2:	e8 f9 e5 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101aa7:	8b 3d 48 dc 17 f0    	mov    0xf017dc48,%edi
f0101aad:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ab2:	89 f8                	mov    %edi,%eax
f0101ab4:	e8 16 ef ff ff       	call   f01009cf <check_va2pa>
f0101ab9:	89 da                	mov    %ebx,%edx
f0101abb:	2b 15 4c dc 17 f0    	sub    0xf017dc4c,%edx
f0101ac1:	c1 fa 03             	sar    $0x3,%edx
f0101ac4:	c1 e2 0c             	shl    $0xc,%edx
f0101ac7:	39 d0                	cmp    %edx,%eax
f0101ac9:	74 19                	je     f0101ae4 <mem_init+0xa3a>
f0101acb:	68 14 54 10 f0       	push   $0xf0105414
f0101ad0:	68 96 4d 10 f0       	push   $0xf0104d96
f0101ad5:	68 6d 03 00 00       	push   $0x36d
f0101ada:	68 70 4d 10 f0       	push   $0xf0104d70
f0101adf:	e8 bc e5 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101ae4:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ae9:	74 19                	je     f0101b04 <mem_init+0xa5a>
f0101aeb:	68 be 4f 10 f0       	push   $0xf0104fbe
f0101af0:	68 96 4d 10 f0       	push   $0xf0104d96
f0101af5:	68 6e 03 00 00       	push   $0x36e
f0101afa:	68 70 4d 10 f0       	push   $0xf0104d70
f0101aff:	e8 9c e5 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b04:	83 ec 04             	sub    $0x4,%esp
f0101b07:	6a 00                	push   $0x0
f0101b09:	68 00 10 00 00       	push   $0x1000
f0101b0e:	57                   	push   %edi
f0101b0f:	e8 6c f3 ff ff       	call   f0100e80 <pgdir_walk>
f0101b14:	83 c4 10             	add    $0x10,%esp
f0101b17:	f6 00 04             	testb  $0x4,(%eax)
f0101b1a:	75 19                	jne    f0101b35 <mem_init+0xa8b>
f0101b1c:	68 c4 54 10 f0       	push   $0xf01054c4
f0101b21:	68 96 4d 10 f0       	push   $0xf0104d96
f0101b26:	68 6f 03 00 00       	push   $0x36f
f0101b2b:	68 70 4d 10 f0       	push   $0xf0104d70
f0101b30:	e8 6b e5 ff ff       	call   f01000a0 <_panic>
	cprintf("pp2 %x\n", pp2);
f0101b35:	83 ec 08             	sub    $0x8,%esp
f0101b38:	53                   	push   %ebx
f0101b39:	68 cf 4f 10 f0       	push   $0xf0104fcf
f0101b3e:	e8 95 14 00 00       	call   f0102fd8 <cprintf>
	cprintf("kern_pgdir %x\n", kern_pgdir);
f0101b43:	83 c4 08             	add    $0x8,%esp
f0101b46:	ff 35 48 dc 17 f0    	pushl  0xf017dc48
f0101b4c:	68 d7 4f 10 f0       	push   $0xf0104fd7
f0101b51:	e8 82 14 00 00       	call   f0102fd8 <cprintf>
	cprintf("kern_pgdir[0] is %x\n", kern_pgdir[0]);
f0101b56:	83 c4 08             	add    $0x8,%esp
f0101b59:	a1 48 dc 17 f0       	mov    0xf017dc48,%eax
f0101b5e:	ff 30                	pushl  (%eax)
f0101b60:	68 e6 4f 10 f0       	push   $0xf0104fe6
f0101b65:	e8 6e 14 00 00       	call   f0102fd8 <cprintf>
	assert(kern_pgdir[0] & PTE_U);
f0101b6a:	a1 48 dc 17 f0       	mov    0xf017dc48,%eax
f0101b6f:	83 c4 10             	add    $0x10,%esp
f0101b72:	f6 00 04             	testb  $0x4,(%eax)
f0101b75:	75 19                	jne    f0101b90 <mem_init+0xae6>
f0101b77:	68 fb 4f 10 f0       	push   $0xf0104ffb
f0101b7c:	68 96 4d 10 f0       	push   $0xf0104d96
f0101b81:	68 73 03 00 00       	push   $0x373
f0101b86:	68 70 4d 10 f0       	push   $0xf0104d70
f0101b8b:	e8 10 e5 ff ff       	call   f01000a0 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b90:	6a 02                	push   $0x2
f0101b92:	68 00 10 00 00       	push   $0x1000
f0101b97:	53                   	push   %ebx
f0101b98:	50                   	push   %eax
f0101b99:	e8 a6 f4 ff ff       	call   f0101044 <page_insert>
f0101b9e:	83 c4 10             	add    $0x10,%esp
f0101ba1:	85 c0                	test   %eax,%eax
f0101ba3:	74 19                	je     f0101bbe <mem_init+0xb14>
f0101ba5:	68 d8 53 10 f0       	push   $0xf01053d8
f0101baa:	68 96 4d 10 f0       	push   $0xf0104d96
f0101baf:	68 76 03 00 00       	push   $0x376
f0101bb4:	68 70 4d 10 f0       	push   $0xf0104d70
f0101bb9:	e8 e2 e4 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101bbe:	83 ec 04             	sub    $0x4,%esp
f0101bc1:	6a 00                	push   $0x0
f0101bc3:	68 00 10 00 00       	push   $0x1000
f0101bc8:	ff 35 48 dc 17 f0    	pushl  0xf017dc48
f0101bce:	e8 ad f2 ff ff       	call   f0100e80 <pgdir_walk>
f0101bd3:	83 c4 10             	add    $0x10,%esp
f0101bd6:	f6 00 02             	testb  $0x2,(%eax)
f0101bd9:	75 19                	jne    f0101bf4 <mem_init+0xb4a>
f0101bdb:	68 f8 54 10 f0       	push   $0xf01054f8
f0101be0:	68 96 4d 10 f0       	push   $0xf0104d96
f0101be5:	68 77 03 00 00       	push   $0x377
f0101bea:	68 70 4d 10 f0       	push   $0xf0104d70
f0101bef:	e8 ac e4 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bf4:	83 ec 04             	sub    $0x4,%esp
f0101bf7:	6a 00                	push   $0x0
f0101bf9:	68 00 10 00 00       	push   $0x1000
f0101bfe:	ff 35 48 dc 17 f0    	pushl  0xf017dc48
f0101c04:	e8 77 f2 ff ff       	call   f0100e80 <pgdir_walk>
f0101c09:	83 c4 10             	add    $0x10,%esp
f0101c0c:	f6 00 04             	testb  $0x4,(%eax)
f0101c0f:	74 19                	je     f0101c2a <mem_init+0xb80>
f0101c11:	68 2c 55 10 f0       	push   $0xf010552c
f0101c16:	68 96 4d 10 f0       	push   $0xf0104d96
f0101c1b:	68 78 03 00 00       	push   $0x378
f0101c20:	68 70 4d 10 f0       	push   $0xf0104d70
f0101c25:	e8 76 e4 ff ff       	call   f01000a0 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101c2a:	6a 02                	push   $0x2
f0101c2c:	68 00 00 40 00       	push   $0x400000
f0101c31:	56                   	push   %esi
f0101c32:	ff 35 48 dc 17 f0    	pushl  0xf017dc48
f0101c38:	e8 07 f4 ff ff       	call   f0101044 <page_insert>
f0101c3d:	83 c4 10             	add    $0x10,%esp
f0101c40:	85 c0                	test   %eax,%eax
f0101c42:	78 19                	js     f0101c5d <mem_init+0xbb3>
f0101c44:	68 64 55 10 f0       	push   $0xf0105564
f0101c49:	68 96 4d 10 f0       	push   $0xf0104d96
f0101c4e:	68 7b 03 00 00       	push   $0x37b
f0101c53:	68 70 4d 10 f0       	push   $0xf0104d70
f0101c58:	e8 43 e4 ff ff       	call   f01000a0 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101c5d:	6a 02                	push   $0x2
f0101c5f:	68 00 10 00 00       	push   $0x1000
f0101c64:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101c67:	ff 35 48 dc 17 f0    	pushl  0xf017dc48
f0101c6d:	e8 d2 f3 ff ff       	call   f0101044 <page_insert>
f0101c72:	83 c4 10             	add    $0x10,%esp
f0101c75:	85 c0                	test   %eax,%eax
f0101c77:	74 19                	je     f0101c92 <mem_init+0xbe8>
f0101c79:	68 9c 55 10 f0       	push   $0xf010559c
f0101c7e:	68 96 4d 10 f0       	push   $0xf0104d96
f0101c83:	68 7e 03 00 00       	push   $0x37e
f0101c88:	68 70 4d 10 f0       	push   $0xf0104d70
f0101c8d:	e8 0e e4 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c92:	83 ec 04             	sub    $0x4,%esp
f0101c95:	6a 00                	push   $0x0
f0101c97:	68 00 10 00 00       	push   $0x1000
f0101c9c:	ff 35 48 dc 17 f0    	pushl  0xf017dc48
f0101ca2:	e8 d9 f1 ff ff       	call   f0100e80 <pgdir_walk>
f0101ca7:	83 c4 10             	add    $0x10,%esp
f0101caa:	f6 00 04             	testb  $0x4,(%eax)
f0101cad:	74 19                	je     f0101cc8 <mem_init+0xc1e>
f0101caf:	68 2c 55 10 f0       	push   $0xf010552c
f0101cb4:	68 96 4d 10 f0       	push   $0xf0104d96
f0101cb9:	68 7f 03 00 00       	push   $0x37f
f0101cbe:	68 70 4d 10 f0       	push   $0xf0104d70
f0101cc3:	e8 d8 e3 ff ff       	call   f01000a0 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101cc8:	8b 3d 48 dc 17 f0    	mov    0xf017dc48,%edi
f0101cce:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cd3:	89 f8                	mov    %edi,%eax
f0101cd5:	e8 f5 ec ff ff       	call   f01009cf <check_va2pa>
f0101cda:	89 c1                	mov    %eax,%ecx
f0101cdc:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101cdf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ce2:	2b 05 4c dc 17 f0    	sub    0xf017dc4c,%eax
f0101ce8:	c1 f8 03             	sar    $0x3,%eax
f0101ceb:	c1 e0 0c             	shl    $0xc,%eax
f0101cee:	39 c1                	cmp    %eax,%ecx
f0101cf0:	74 19                	je     f0101d0b <mem_init+0xc61>
f0101cf2:	68 d8 55 10 f0       	push   $0xf01055d8
f0101cf7:	68 96 4d 10 f0       	push   $0xf0104d96
f0101cfc:	68 82 03 00 00       	push   $0x382
f0101d01:	68 70 4d 10 f0       	push   $0xf0104d70
f0101d06:	e8 95 e3 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d0b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d10:	89 f8                	mov    %edi,%eax
f0101d12:	e8 b8 ec ff ff       	call   f01009cf <check_va2pa>
f0101d17:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101d1a:	74 19                	je     f0101d35 <mem_init+0xc8b>
f0101d1c:	68 04 56 10 f0       	push   $0xf0105604
f0101d21:	68 96 4d 10 f0       	push   $0xf0104d96
f0101d26:	68 83 03 00 00       	push   $0x383
f0101d2b:	68 70 4d 10 f0       	push   $0xf0104d70
f0101d30:	e8 6b e3 ff ff       	call   f01000a0 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101d35:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d38:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0101d3d:	74 19                	je     f0101d58 <mem_init+0xcae>
f0101d3f:	68 11 50 10 f0       	push   $0xf0105011
f0101d44:	68 96 4d 10 f0       	push   $0xf0104d96
f0101d49:	68 85 03 00 00       	push   $0x385
f0101d4e:	68 70 4d 10 f0       	push   $0xf0104d70
f0101d53:	e8 48 e3 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101d58:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d5d:	74 19                	je     f0101d78 <mem_init+0xcce>
f0101d5f:	68 22 50 10 f0       	push   $0xf0105022
f0101d64:	68 96 4d 10 f0       	push   $0xf0104d96
f0101d69:	68 86 03 00 00       	push   $0x386
f0101d6e:	68 70 4d 10 f0       	push   $0xf0104d70
f0101d73:	e8 28 e3 ff ff       	call   f01000a0 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101d78:	83 ec 0c             	sub    $0xc,%esp
f0101d7b:	6a 00                	push   $0x0
f0101d7d:	e8 5e f0 ff ff       	call   f0100de0 <page_alloc>
f0101d82:	83 c4 10             	add    $0x10,%esp
f0101d85:	85 c0                	test   %eax,%eax
f0101d87:	74 04                	je     f0101d8d <mem_init+0xce3>
f0101d89:	39 c3                	cmp    %eax,%ebx
f0101d8b:	74 19                	je     f0101da6 <mem_init+0xcfc>
f0101d8d:	68 34 56 10 f0       	push   $0xf0105634
f0101d92:	68 96 4d 10 f0       	push   $0xf0104d96
f0101d97:	68 89 03 00 00       	push   $0x389
f0101d9c:	68 70 4d 10 f0       	push   $0xf0104d70
f0101da1:	e8 fa e2 ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101da6:	83 ec 08             	sub    $0x8,%esp
f0101da9:	6a 00                	push   $0x0
f0101dab:	ff 35 48 dc 17 f0    	pushl  0xf017dc48
f0101db1:	e8 4b f2 ff ff       	call   f0101001 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101db6:	8b 3d 48 dc 17 f0    	mov    0xf017dc48,%edi
f0101dbc:	ba 00 00 00 00       	mov    $0x0,%edx
f0101dc1:	89 f8                	mov    %edi,%eax
f0101dc3:	e8 07 ec ff ff       	call   f01009cf <check_va2pa>
f0101dc8:	83 c4 10             	add    $0x10,%esp
f0101dcb:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101dce:	74 19                	je     f0101de9 <mem_init+0xd3f>
f0101dd0:	68 58 56 10 f0       	push   $0xf0105658
f0101dd5:	68 96 4d 10 f0       	push   $0xf0104d96
f0101dda:	68 8d 03 00 00       	push   $0x38d
f0101ddf:	68 70 4d 10 f0       	push   $0xf0104d70
f0101de4:	e8 b7 e2 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101de9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dee:	89 f8                	mov    %edi,%eax
f0101df0:	e8 da eb ff ff       	call   f01009cf <check_va2pa>
f0101df5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101df8:	2b 15 4c dc 17 f0    	sub    0xf017dc4c,%edx
f0101dfe:	c1 fa 03             	sar    $0x3,%edx
f0101e01:	c1 e2 0c             	shl    $0xc,%edx
f0101e04:	39 d0                	cmp    %edx,%eax
f0101e06:	74 19                	je     f0101e21 <mem_init+0xd77>
f0101e08:	68 04 56 10 f0       	push   $0xf0105604
f0101e0d:	68 96 4d 10 f0       	push   $0xf0104d96
f0101e12:	68 8e 03 00 00       	push   $0x38e
f0101e17:	68 70 4d 10 f0       	push   $0xf0104d70
f0101e1c:	e8 7f e2 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f0101e21:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e24:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e29:	74 19                	je     f0101e44 <mem_init+0xd9a>
f0101e2b:	68 9c 4f 10 f0       	push   $0xf0104f9c
f0101e30:	68 96 4d 10 f0       	push   $0xf0104d96
f0101e35:	68 8f 03 00 00       	push   $0x38f
f0101e3a:	68 70 4d 10 f0       	push   $0xf0104d70
f0101e3f:	e8 5c e2 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101e44:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e49:	74 19                	je     f0101e64 <mem_init+0xdba>
f0101e4b:	68 22 50 10 f0       	push   $0xf0105022
f0101e50:	68 96 4d 10 f0       	push   $0xf0104d96
f0101e55:	68 90 03 00 00       	push   $0x390
f0101e5a:	68 70 4d 10 f0       	push   $0xf0104d70
f0101e5f:	e8 3c e2 ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101e64:	83 ec 08             	sub    $0x8,%esp
f0101e67:	68 00 10 00 00       	push   $0x1000
f0101e6c:	57                   	push   %edi
f0101e6d:	e8 8f f1 ff ff       	call   f0101001 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e72:	8b 3d 48 dc 17 f0    	mov    0xf017dc48,%edi
f0101e78:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e7d:	89 f8                	mov    %edi,%eax
f0101e7f:	e8 4b eb ff ff       	call   f01009cf <check_va2pa>
f0101e84:	83 c4 10             	add    $0x10,%esp
f0101e87:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e8a:	74 19                	je     f0101ea5 <mem_init+0xdfb>
f0101e8c:	68 58 56 10 f0       	push   $0xf0105658
f0101e91:	68 96 4d 10 f0       	push   $0xf0104d96
f0101e96:	68 94 03 00 00       	push   $0x394
f0101e9b:	68 70 4d 10 f0       	push   $0xf0104d70
f0101ea0:	e8 fb e1 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101ea5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101eaa:	89 f8                	mov    %edi,%eax
f0101eac:	e8 1e eb ff ff       	call   f01009cf <check_va2pa>
f0101eb1:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101eb4:	74 19                	je     f0101ecf <mem_init+0xe25>
f0101eb6:	68 7c 56 10 f0       	push   $0xf010567c
f0101ebb:	68 96 4d 10 f0       	push   $0xf0104d96
f0101ec0:	68 95 03 00 00       	push   $0x395
f0101ec5:	68 70 4d 10 f0       	push   $0xf0104d70
f0101eca:	e8 d1 e1 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f0101ecf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ed2:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101ed7:	74 19                	je     f0101ef2 <mem_init+0xe48>
f0101ed9:	68 33 50 10 f0       	push   $0xf0105033
f0101ede:	68 96 4d 10 f0       	push   $0xf0104d96
f0101ee3:	68 96 03 00 00       	push   $0x396
f0101ee8:	68 70 4d 10 f0       	push   $0xf0104d70
f0101eed:	e8 ae e1 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101ef2:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101ef7:	74 19                	je     f0101f12 <mem_init+0xe68>
f0101ef9:	68 22 50 10 f0       	push   $0xf0105022
f0101efe:	68 96 4d 10 f0       	push   $0xf0104d96
f0101f03:	68 97 03 00 00       	push   $0x397
f0101f08:	68 70 4d 10 f0       	push   $0xf0104d70
f0101f0d:	e8 8e e1 ff ff       	call   f01000a0 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101f12:	83 ec 0c             	sub    $0xc,%esp
f0101f15:	6a 00                	push   $0x0
f0101f17:	e8 c4 ee ff ff       	call   f0100de0 <page_alloc>
f0101f1c:	83 c4 10             	add    $0x10,%esp
f0101f1f:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101f22:	75 04                	jne    f0101f28 <mem_init+0xe7e>
f0101f24:	85 c0                	test   %eax,%eax
f0101f26:	75 19                	jne    f0101f41 <mem_init+0xe97>
f0101f28:	68 a4 56 10 f0       	push   $0xf01056a4
f0101f2d:	68 96 4d 10 f0       	push   $0xf0104d96
f0101f32:	68 9a 03 00 00       	push   $0x39a
f0101f37:	68 70 4d 10 f0       	push   $0xf0104d70
f0101f3c:	e8 5f e1 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101f41:	83 ec 0c             	sub    $0xc,%esp
f0101f44:	6a 00                	push   $0x0
f0101f46:	e8 95 ee ff ff       	call   f0100de0 <page_alloc>
f0101f4b:	83 c4 10             	add    $0x10,%esp
f0101f4e:	85 c0                	test   %eax,%eax
f0101f50:	74 19                	je     f0101f6b <mem_init+0xec1>
f0101f52:	68 3a 4f 10 f0       	push   $0xf0104f3a
f0101f57:	68 96 4d 10 f0       	push   $0xf0104d96
f0101f5c:	68 9d 03 00 00       	push   $0x39d
f0101f61:	68 70 4d 10 f0       	push   $0xf0104d70
f0101f66:	e8 35 e1 ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101f6b:	8b 0d 48 dc 17 f0    	mov    0xf017dc48,%ecx
f0101f71:	8b 11                	mov    (%ecx),%edx
f0101f73:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101f79:	89 f0                	mov    %esi,%eax
f0101f7b:	2b 05 4c dc 17 f0    	sub    0xf017dc4c,%eax
f0101f81:	c1 f8 03             	sar    $0x3,%eax
f0101f84:	c1 e0 0c             	shl    $0xc,%eax
f0101f87:	39 c2                	cmp    %eax,%edx
f0101f89:	74 19                	je     f0101fa4 <mem_init+0xefa>
f0101f8b:	68 80 53 10 f0       	push   $0xf0105380
f0101f90:	68 96 4d 10 f0       	push   $0xf0104d96
f0101f95:	68 a0 03 00 00       	push   $0x3a0
f0101f9a:	68 70 4d 10 f0       	push   $0xf0104d70
f0101f9f:	e8 fc e0 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f0101fa4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101faa:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101faf:	74 19                	je     f0101fca <mem_init+0xf20>
f0101fb1:	68 ad 4f 10 f0       	push   $0xf0104fad
f0101fb6:	68 96 4d 10 f0       	push   $0xf0104d96
f0101fbb:	68 a2 03 00 00       	push   $0x3a2
f0101fc0:	68 70 4d 10 f0       	push   $0xf0104d70
f0101fc5:	e8 d6 e0 ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f0101fca:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101fd0:	83 ec 0c             	sub    $0xc,%esp
f0101fd3:	56                   	push   %esi
f0101fd4:	e8 71 ee ff ff       	call   f0100e4a <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101fd9:	83 c4 0c             	add    $0xc,%esp
f0101fdc:	6a 01                	push   $0x1
f0101fde:	68 00 10 40 00       	push   $0x401000
f0101fe3:	ff 35 48 dc 17 f0    	pushl  0xf017dc48
f0101fe9:	e8 92 ee ff ff       	call   f0100e80 <pgdir_walk>
f0101fee:	89 c7                	mov    %eax,%edi
f0101ff0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101ff3:	a1 48 dc 17 f0       	mov    0xf017dc48,%eax
f0101ff8:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101ffb:	8b 40 04             	mov    0x4(%eax),%eax
f0101ffe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102003:	8b 0d 44 dc 17 f0    	mov    0xf017dc44,%ecx
f0102009:	89 c2                	mov    %eax,%edx
f010200b:	c1 ea 0c             	shr    $0xc,%edx
f010200e:	83 c4 10             	add    $0x10,%esp
f0102011:	39 ca                	cmp    %ecx,%edx
f0102013:	72 15                	jb     f010202a <mem_init+0xf80>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102015:	50                   	push   %eax
f0102016:	68 e4 50 10 f0       	push   $0xf01050e4
f010201b:	68 a9 03 00 00       	push   $0x3a9
f0102020:	68 70 4d 10 f0       	push   $0xf0104d70
f0102025:	e8 76 e0 ff ff       	call   f01000a0 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010202a:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010202f:	39 c7                	cmp    %eax,%edi
f0102031:	74 19                	je     f010204c <mem_init+0xfa2>
f0102033:	68 44 50 10 f0       	push   $0xf0105044
f0102038:	68 96 4d 10 f0       	push   $0xf0104d96
f010203d:	68 aa 03 00 00       	push   $0x3aa
f0102042:	68 70 4d 10 f0       	push   $0xf0104d70
f0102047:	e8 54 e0 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010204c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010204f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102056:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010205c:	89 f0                	mov    %esi,%eax
f010205e:	2b 05 4c dc 17 f0    	sub    0xf017dc4c,%eax
f0102064:	c1 f8 03             	sar    $0x3,%eax
f0102067:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010206a:	89 c2                	mov    %eax,%edx
f010206c:	c1 ea 0c             	shr    $0xc,%edx
f010206f:	39 d1                	cmp    %edx,%ecx
f0102071:	77 12                	ja     f0102085 <mem_init+0xfdb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102073:	50                   	push   %eax
f0102074:	68 e4 50 10 f0       	push   $0xf01050e4
f0102079:	6a 56                	push   $0x56
f010207b:	68 7c 4d 10 f0       	push   $0xf0104d7c
f0102080:	e8 1b e0 ff ff       	call   f01000a0 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102085:	83 ec 04             	sub    $0x4,%esp
f0102088:	68 00 10 00 00       	push   $0x1000
f010208d:	68 ff 00 00 00       	push   $0xff
f0102092:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102097:	50                   	push   %eax
f0102098:	e8 ed 22 00 00       	call   f010438a <memset>
	page_free(pp0);
f010209d:	89 34 24             	mov    %esi,(%esp)
f01020a0:	e8 a5 ed ff ff       	call   f0100e4a <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01020a5:	83 c4 0c             	add    $0xc,%esp
f01020a8:	6a 01                	push   $0x1
f01020aa:	6a 00                	push   $0x0
f01020ac:	ff 35 48 dc 17 f0    	pushl  0xf017dc48
f01020b2:	e8 c9 ed ff ff       	call   f0100e80 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01020b7:	89 f2                	mov    %esi,%edx
f01020b9:	2b 15 4c dc 17 f0    	sub    0xf017dc4c,%edx
f01020bf:	c1 fa 03             	sar    $0x3,%edx
f01020c2:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020c5:	89 d0                	mov    %edx,%eax
f01020c7:	c1 e8 0c             	shr    $0xc,%eax
f01020ca:	83 c4 10             	add    $0x10,%esp
f01020cd:	3b 05 44 dc 17 f0    	cmp    0xf017dc44,%eax
f01020d3:	72 12                	jb     f01020e7 <mem_init+0x103d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01020d5:	52                   	push   %edx
f01020d6:	68 e4 50 10 f0       	push   $0xf01050e4
f01020db:	6a 56                	push   $0x56
f01020dd:	68 7c 4d 10 f0       	push   $0xf0104d7c
f01020e2:	e8 b9 df ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f01020e7:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01020ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01020f0:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01020f6:	f6 00 01             	testb  $0x1,(%eax)
f01020f9:	74 19                	je     f0102114 <mem_init+0x106a>
f01020fb:	68 5c 50 10 f0       	push   $0xf010505c
f0102100:	68 96 4d 10 f0       	push   $0xf0104d96
f0102105:	68 b4 03 00 00       	push   $0x3b4
f010210a:	68 70 4d 10 f0       	push   $0xf0104d70
f010210f:	e8 8c df ff ff       	call   f01000a0 <_panic>
f0102114:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102117:	39 c2                	cmp    %eax,%edx
f0102119:	75 db                	jne    f01020f6 <mem_init+0x104c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010211b:	a1 48 dc 17 f0       	mov    0xf017dc48,%eax
f0102120:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102126:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f010212c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010212f:	a3 80 cf 17 f0       	mov    %eax,0xf017cf80

	// free the pages we took
	page_free(pp0);
f0102134:	83 ec 0c             	sub    $0xc,%esp
f0102137:	56                   	push   %esi
f0102138:	e8 0d ed ff ff       	call   f0100e4a <page_free>
	page_free(pp1);
f010213d:	83 c4 04             	add    $0x4,%esp
f0102140:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102143:	e8 02 ed ff ff       	call   f0100e4a <page_free>
	page_free(pp2);
f0102148:	89 1c 24             	mov    %ebx,(%esp)
f010214b:	e8 fa ec ff ff       	call   f0100e4a <page_free>

	cprintf("check_page() succeeded!\n");
f0102150:	c7 04 24 73 50 10 f0 	movl   $0xf0105073,(%esp)
f0102157:	e8 7c 0e 00 00       	call   f0102fd8 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, 
f010215c:	a1 4c dc 17 f0       	mov    0xf017dc4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102161:	83 c4 10             	add    $0x10,%esp
f0102164:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102169:	77 15                	ja     f0102180 <mem_init+0x10d6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010216b:	50                   	push   %eax
f010216c:	68 84 52 10 f0       	push   $0xf0105284
f0102171:	68 be 00 00 00       	push   $0xbe
f0102176:	68 70 4d 10 f0       	push   $0xf0104d70
f010217b:	e8 20 df ff ff       	call   f01000a0 <_panic>
f0102180:	83 ec 08             	sub    $0x8,%esp
f0102183:	6a 04                	push   $0x4
f0102185:	05 00 00 00 10       	add    $0x10000000,%eax
f010218a:	50                   	push   %eax
f010218b:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102190:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102195:	a1 48 dc 17 f0       	mov    0xf017dc48,%eax
f010219a:	e8 74 ed ff ff       	call   f0100f13 <boot_map_region>
		UPAGES, 
		PTSIZE, 
		PADDR(pages), 
		PTE_U);
	cprintf("PADDR(pages) %x\n", PADDR(pages));
f010219f:	a1 4c dc 17 f0       	mov    0xf017dc4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021a4:	83 c4 10             	add    $0x10,%esp
f01021a7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021ac:	77 15                	ja     f01021c3 <mem_init+0x1119>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021ae:	50                   	push   %eax
f01021af:	68 84 52 10 f0       	push   $0xf0105284
f01021b4:	68 c0 00 00 00       	push   $0xc0
f01021b9:	68 70 4d 10 f0       	push   $0xf0104d70
f01021be:	e8 dd de ff ff       	call   f01000a0 <_panic>
f01021c3:	83 ec 08             	sub    $0x8,%esp
f01021c6:	05 00 00 00 10       	add    $0x10000000,%eax
f01021cb:	50                   	push   %eax
f01021cc:	68 8c 50 10 f0       	push   $0xf010508c
f01021d1:	e8 02 0e 00 00       	call   f0102fd8 <cprintf>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,
f01021d6:	a1 8c cf 17 f0       	mov    0xf017cf8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01021db:	83 c4 10             	add    $0x10,%esp
f01021de:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01021e3:	77 15                	ja     f01021fa <mem_init+0x1150>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021e5:	50                   	push   %eax
f01021e6:	68 84 52 10 f0       	push   $0xf0105284
f01021eb:	68 cb 00 00 00       	push   $0xcb
f01021f0:	68 70 4d 10 f0       	push   $0xf0104d70
f01021f5:	e8 a6 de ff ff       	call   f01000a0 <_panic>
f01021fa:	83 ec 08             	sub    $0x8,%esp
f01021fd:	6a 04                	push   $0x4
f01021ff:	05 00 00 00 10       	add    $0x10000000,%eax
f0102204:	50                   	push   %eax
f0102205:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010220a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010220f:	a1 48 dc 17 f0       	mov    0xf017dc48,%eax
f0102214:	e8 fa ec ff ff       	call   f0100f13 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102219:	83 c4 10             	add    $0x10,%esp
f010221c:	b8 00 10 11 f0       	mov    $0xf0111000,%eax
f0102221:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102226:	77 15                	ja     f010223d <mem_init+0x1193>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102228:	50                   	push   %eax
f0102229:	68 84 52 10 f0       	push   $0xf0105284
f010222e:	68 dd 00 00 00       	push   $0xdd
f0102233:	68 70 4d 10 f0       	push   $0xf0104d70
f0102238:	e8 63 de ff ff       	call   f01000a0 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f010223d:	83 ec 08             	sub    $0x8,%esp
f0102240:	6a 02                	push   $0x2
f0102242:	68 00 10 11 00       	push   $0x111000
f0102247:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010224c:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102251:	a1 48 dc 17 f0       	mov    0xf017dc48,%eax
f0102256:	e8 b8 ec ff ff       	call   f0100f13 <boot_map_region>
		KSTACKTOP-KSTKSIZE, 
		KSTKSIZE, 
		PADDR(bootstack), 
		PTE_W);
	cprintf("PADDR(bootstack) %x\n", PADDR(bootstack));
f010225b:	83 c4 08             	add    $0x8,%esp
f010225e:	68 00 10 11 00       	push   $0x111000
f0102263:	68 9d 50 10 f0       	push   $0xf010509d
f0102268:	e8 6b 0d 00 00       	call   f0102fd8 <cprintf>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f010226d:	83 c4 08             	add    $0x8,%esp
f0102270:	6a 02                	push   $0x2
f0102272:	6a 00                	push   $0x0
f0102274:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102279:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010227e:	a1 48 dc 17 f0       	mov    0xf017dc48,%eax
f0102283:	e8 8b ec ff ff       	call   f0100f13 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102288:	8b 1d 48 dc 17 f0    	mov    0xf017dc48,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010228e:	a1 44 dc 17 f0       	mov    0xf017dc44,%eax
f0102293:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102296:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010229d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01022a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01022a5:	8b 3d 4c dc 17 f0    	mov    0xf017dc4c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01022ab:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01022ae:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01022b1:	be 00 00 00 00       	mov    $0x0,%esi
f01022b6:	eb 55                	jmp    f010230d <mem_init+0x1263>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01022b8:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01022be:	89 d8                	mov    %ebx,%eax
f01022c0:	e8 0a e7 ff ff       	call   f01009cf <check_va2pa>
f01022c5:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01022cc:	77 15                	ja     f01022e3 <mem_init+0x1239>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01022ce:	57                   	push   %edi
f01022cf:	68 84 52 10 f0       	push   $0xf0105284
f01022d4:	68 f3 02 00 00       	push   $0x2f3
f01022d9:	68 70 4d 10 f0       	push   $0xf0104d70
f01022de:	e8 bd dd ff ff       	call   f01000a0 <_panic>
f01022e3:	8d 94 37 00 00 00 10 	lea    0x10000000(%edi,%esi,1),%edx
f01022ea:	39 d0                	cmp    %edx,%eax
f01022ec:	74 19                	je     f0102307 <mem_init+0x125d>
f01022ee:	68 c8 56 10 f0       	push   $0xf01056c8
f01022f3:	68 96 4d 10 f0       	push   $0xf0104d96
f01022f8:	68 f3 02 00 00       	push   $0x2f3
f01022fd:	68 70 4d 10 f0       	push   $0xf0104d70
f0102302:	e8 99 dd ff ff       	call   f01000a0 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102307:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010230d:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0102310:	77 a6                	ja     f01022b8 <mem_init+0x120e>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102312:	8b 3d 8c cf 17 f0    	mov    0xf017cf8c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102318:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010231b:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f0102320:	89 f2                	mov    %esi,%edx
f0102322:	89 d8                	mov    %ebx,%eax
f0102324:	e8 a6 e6 ff ff       	call   f01009cf <check_va2pa>
f0102329:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102330:	77 15                	ja     f0102347 <mem_init+0x129d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102332:	57                   	push   %edi
f0102333:	68 84 52 10 f0       	push   $0xf0105284
f0102338:	68 f8 02 00 00       	push   $0x2f8
f010233d:	68 70 4d 10 f0       	push   $0xf0104d70
f0102342:	e8 59 dd ff ff       	call   f01000a0 <_panic>
f0102347:	8d 94 37 00 00 40 21 	lea    0x21400000(%edi,%esi,1),%edx
f010234e:	39 c2                	cmp    %eax,%edx
f0102350:	74 19                	je     f010236b <mem_init+0x12c1>
f0102352:	68 fc 56 10 f0       	push   $0xf01056fc
f0102357:	68 96 4d 10 f0       	push   $0xf0104d96
f010235c:	68 f8 02 00 00       	push   $0x2f8
f0102361:	68 70 4d 10 f0       	push   $0xf0104d70
f0102366:	e8 35 dd ff ff       	call   f01000a0 <_panic>
f010236b:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102371:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f0102377:	75 a7                	jne    f0102320 <mem_init+0x1276>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102379:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010237c:	c1 e7 0c             	shl    $0xc,%edi
f010237f:	be 00 00 00 00       	mov    $0x0,%esi
f0102384:	eb 30                	jmp    f01023b6 <mem_init+0x130c>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102386:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f010238c:	89 d8                	mov    %ebx,%eax
f010238e:	e8 3c e6 ff ff       	call   f01009cf <check_va2pa>
f0102393:	39 c6                	cmp    %eax,%esi
f0102395:	74 19                	je     f01023b0 <mem_init+0x1306>
f0102397:	68 30 57 10 f0       	push   $0xf0105730
f010239c:	68 96 4d 10 f0       	push   $0xf0104d96
f01023a1:	68 fc 02 00 00       	push   $0x2fc
f01023a6:	68 70 4d 10 f0       	push   $0xf0104d70
f01023ab:	e8 f0 dc ff ff       	call   f01000a0 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01023b0:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01023b6:	39 fe                	cmp    %edi,%esi
f01023b8:	72 cc                	jb     f0102386 <mem_init+0x12dc>
f01023ba:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01023bf:	89 f2                	mov    %esi,%edx
f01023c1:	89 d8                	mov    %ebx,%eax
f01023c3:	e8 07 e6 ff ff       	call   f01009cf <check_va2pa>
f01023c8:	8d 96 00 90 11 10    	lea    0x10119000(%esi),%edx
f01023ce:	39 c2                	cmp    %eax,%edx
f01023d0:	74 19                	je     f01023eb <mem_init+0x1341>
f01023d2:	68 58 57 10 f0       	push   $0xf0105758
f01023d7:	68 96 4d 10 f0       	push   $0xf0104d96
f01023dc:	68 00 03 00 00       	push   $0x300
f01023e1:	68 70 4d 10 f0       	push   $0xf0104d70
f01023e6:	e8 b5 dc ff ff       	call   f01000a0 <_panic>
f01023eb:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01023f1:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01023f7:	75 c6                	jne    f01023bf <mem_init+0x1315>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01023f9:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01023fe:	89 d8                	mov    %ebx,%eax
f0102400:	e8 ca e5 ff ff       	call   f01009cf <check_va2pa>
f0102405:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102408:	74 51                	je     f010245b <mem_init+0x13b1>
f010240a:	68 a0 57 10 f0       	push   $0xf01057a0
f010240f:	68 96 4d 10 f0       	push   $0xf0104d96
f0102414:	68 01 03 00 00       	push   $0x301
f0102419:	68 70 4d 10 f0       	push   $0xf0104d70
f010241e:	e8 7d dc ff ff       	call   f01000a0 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102423:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102428:	72 36                	jb     f0102460 <mem_init+0x13b6>
f010242a:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f010242f:	76 07                	jbe    f0102438 <mem_init+0x138e>
f0102431:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102436:	75 28                	jne    f0102460 <mem_init+0x13b6>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102438:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f010243c:	0f 85 83 00 00 00    	jne    f01024c5 <mem_init+0x141b>
f0102442:	68 b2 50 10 f0       	push   $0xf01050b2
f0102447:	68 96 4d 10 f0       	push   $0xf0104d96
f010244c:	68 0a 03 00 00       	push   $0x30a
f0102451:	68 70 4d 10 f0       	push   $0xf0104d70
f0102456:	e8 45 dc ff ff       	call   f01000a0 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010245b:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102460:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102465:	76 3f                	jbe    f01024a6 <mem_init+0x13fc>
				assert(pgdir[i] & PTE_P);
f0102467:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f010246a:	f6 c2 01             	test   $0x1,%dl
f010246d:	75 19                	jne    f0102488 <mem_init+0x13de>
f010246f:	68 b2 50 10 f0       	push   $0xf01050b2
f0102474:	68 96 4d 10 f0       	push   $0xf0104d96
f0102479:	68 0e 03 00 00       	push   $0x30e
f010247e:	68 70 4d 10 f0       	push   $0xf0104d70
f0102483:	e8 18 dc ff ff       	call   f01000a0 <_panic>
				assert(pgdir[i] & PTE_W);
f0102488:	f6 c2 02             	test   $0x2,%dl
f010248b:	75 38                	jne    f01024c5 <mem_init+0x141b>
f010248d:	68 c3 50 10 f0       	push   $0xf01050c3
f0102492:	68 96 4d 10 f0       	push   $0xf0104d96
f0102497:	68 0f 03 00 00       	push   $0x30f
f010249c:	68 70 4d 10 f0       	push   $0xf0104d70
f01024a1:	e8 fa db ff ff       	call   f01000a0 <_panic>
			} else
				assert(pgdir[i] == 0);
f01024a6:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01024aa:	74 19                	je     f01024c5 <mem_init+0x141b>
f01024ac:	68 d4 50 10 f0       	push   $0xf01050d4
f01024b1:	68 96 4d 10 f0       	push   $0xf0104d96
f01024b6:	68 11 03 00 00       	push   $0x311
f01024bb:	68 70 4d 10 f0       	push   $0xf0104d70
f01024c0:	e8 db db ff ff       	call   f01000a0 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01024c5:	83 c0 01             	add    $0x1,%eax
f01024c8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01024cd:	0f 86 50 ff ff ff    	jbe    f0102423 <mem_init+0x1379>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01024d3:	83 ec 0c             	sub    $0xc,%esp
f01024d6:	68 d0 57 10 f0       	push   $0xf01057d0
f01024db:	e8 f8 0a 00 00       	call   f0102fd8 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01024e0:	a1 48 dc 17 f0       	mov    0xf017dc48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01024e5:	83 c4 10             	add    $0x10,%esp
f01024e8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01024ed:	77 15                	ja     f0102504 <mem_init+0x145a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01024ef:	50                   	push   %eax
f01024f0:	68 84 52 10 f0       	push   $0xf0105284
f01024f5:	68 fb 00 00 00       	push   $0xfb
f01024fa:	68 70 4d 10 f0       	push   $0xf0104d70
f01024ff:	e8 9c db ff ff       	call   f01000a0 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102504:	05 00 00 00 10       	add    $0x10000000,%eax
f0102509:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010250c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102511:	e8 1d e5 ff ff       	call   f0100a33 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102516:	0f 20 c0             	mov    %cr0,%eax
f0102519:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010251c:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102521:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102524:	83 ec 0c             	sub    $0xc,%esp
f0102527:	6a 00                	push   $0x0
f0102529:	e8 b2 e8 ff ff       	call   f0100de0 <page_alloc>
f010252e:	89 c3                	mov    %eax,%ebx
f0102530:	83 c4 10             	add    $0x10,%esp
f0102533:	85 c0                	test   %eax,%eax
f0102535:	75 19                	jne    f0102550 <mem_init+0x14a6>
f0102537:	68 8f 4e 10 f0       	push   $0xf0104e8f
f010253c:	68 96 4d 10 f0       	push   $0xf0104d96
f0102541:	68 cf 03 00 00       	push   $0x3cf
f0102546:	68 70 4d 10 f0       	push   $0xf0104d70
f010254b:	e8 50 db ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0102550:	83 ec 0c             	sub    $0xc,%esp
f0102553:	6a 00                	push   $0x0
f0102555:	e8 86 e8 ff ff       	call   f0100de0 <page_alloc>
f010255a:	89 c7                	mov    %eax,%edi
f010255c:	83 c4 10             	add    $0x10,%esp
f010255f:	85 c0                	test   %eax,%eax
f0102561:	75 19                	jne    f010257c <mem_init+0x14d2>
f0102563:	68 a5 4e 10 f0       	push   $0xf0104ea5
f0102568:	68 96 4d 10 f0       	push   $0xf0104d96
f010256d:	68 d0 03 00 00       	push   $0x3d0
f0102572:	68 70 4d 10 f0       	push   $0xf0104d70
f0102577:	e8 24 db ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f010257c:	83 ec 0c             	sub    $0xc,%esp
f010257f:	6a 00                	push   $0x0
f0102581:	e8 5a e8 ff ff       	call   f0100de0 <page_alloc>
f0102586:	89 c6                	mov    %eax,%esi
f0102588:	83 c4 10             	add    $0x10,%esp
f010258b:	85 c0                	test   %eax,%eax
f010258d:	75 19                	jne    f01025a8 <mem_init+0x14fe>
f010258f:	68 bb 4e 10 f0       	push   $0xf0104ebb
f0102594:	68 96 4d 10 f0       	push   $0xf0104d96
f0102599:	68 d1 03 00 00       	push   $0x3d1
f010259e:	68 70 4d 10 f0       	push   $0xf0104d70
f01025a3:	e8 f8 da ff ff       	call   f01000a0 <_panic>
	page_free(pp0);
f01025a8:	83 ec 0c             	sub    $0xc,%esp
f01025ab:	53                   	push   %ebx
f01025ac:	e8 99 e8 ff ff       	call   f0100e4a <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025b1:	89 f8                	mov    %edi,%eax
f01025b3:	2b 05 4c dc 17 f0    	sub    0xf017dc4c,%eax
f01025b9:	c1 f8 03             	sar    $0x3,%eax
f01025bc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025bf:	89 c2                	mov    %eax,%edx
f01025c1:	c1 ea 0c             	shr    $0xc,%edx
f01025c4:	83 c4 10             	add    $0x10,%esp
f01025c7:	3b 15 44 dc 17 f0    	cmp    0xf017dc44,%edx
f01025cd:	72 12                	jb     f01025e1 <mem_init+0x1537>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025cf:	50                   	push   %eax
f01025d0:	68 e4 50 10 f0       	push   $0xf01050e4
f01025d5:	6a 56                	push   $0x56
f01025d7:	68 7c 4d 10 f0       	push   $0xf0104d7c
f01025dc:	e8 bf da ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01025e1:	83 ec 04             	sub    $0x4,%esp
f01025e4:	68 00 10 00 00       	push   $0x1000
f01025e9:	6a 01                	push   $0x1
f01025eb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01025f0:	50                   	push   %eax
f01025f1:	e8 94 1d 00 00       	call   f010438a <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025f6:	89 f0                	mov    %esi,%eax
f01025f8:	2b 05 4c dc 17 f0    	sub    0xf017dc4c,%eax
f01025fe:	c1 f8 03             	sar    $0x3,%eax
f0102601:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102604:	89 c2                	mov    %eax,%edx
f0102606:	c1 ea 0c             	shr    $0xc,%edx
f0102609:	83 c4 10             	add    $0x10,%esp
f010260c:	3b 15 44 dc 17 f0    	cmp    0xf017dc44,%edx
f0102612:	72 12                	jb     f0102626 <mem_init+0x157c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102614:	50                   	push   %eax
f0102615:	68 e4 50 10 f0       	push   $0xf01050e4
f010261a:	6a 56                	push   $0x56
f010261c:	68 7c 4d 10 f0       	push   $0xf0104d7c
f0102621:	e8 7a da ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102626:	83 ec 04             	sub    $0x4,%esp
f0102629:	68 00 10 00 00       	push   $0x1000
f010262e:	6a 02                	push   $0x2
f0102630:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102635:	50                   	push   %eax
f0102636:	e8 4f 1d 00 00       	call   f010438a <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010263b:	6a 02                	push   $0x2
f010263d:	68 00 10 00 00       	push   $0x1000
f0102642:	57                   	push   %edi
f0102643:	ff 35 48 dc 17 f0    	pushl  0xf017dc48
f0102649:	e8 f6 e9 ff ff       	call   f0101044 <page_insert>
	assert(pp1->pp_ref == 1);
f010264e:	83 c4 20             	add    $0x20,%esp
f0102651:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102656:	74 19                	je     f0102671 <mem_init+0x15c7>
f0102658:	68 9c 4f 10 f0       	push   $0xf0104f9c
f010265d:	68 96 4d 10 f0       	push   $0xf0104d96
f0102662:	68 d6 03 00 00       	push   $0x3d6
f0102667:	68 70 4d 10 f0       	push   $0xf0104d70
f010266c:	e8 2f da ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102671:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102678:	01 01 01 
f010267b:	74 19                	je     f0102696 <mem_init+0x15ec>
f010267d:	68 f0 57 10 f0       	push   $0xf01057f0
f0102682:	68 96 4d 10 f0       	push   $0xf0104d96
f0102687:	68 d7 03 00 00       	push   $0x3d7
f010268c:	68 70 4d 10 f0       	push   $0xf0104d70
f0102691:	e8 0a da ff ff       	call   f01000a0 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102696:	6a 02                	push   $0x2
f0102698:	68 00 10 00 00       	push   $0x1000
f010269d:	56                   	push   %esi
f010269e:	ff 35 48 dc 17 f0    	pushl  0xf017dc48
f01026a4:	e8 9b e9 ff ff       	call   f0101044 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01026a9:	83 c4 10             	add    $0x10,%esp
f01026ac:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01026b3:	02 02 02 
f01026b6:	74 19                	je     f01026d1 <mem_init+0x1627>
f01026b8:	68 14 58 10 f0       	push   $0xf0105814
f01026bd:	68 96 4d 10 f0       	push   $0xf0104d96
f01026c2:	68 d9 03 00 00       	push   $0x3d9
f01026c7:	68 70 4d 10 f0       	push   $0xf0104d70
f01026cc:	e8 cf d9 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f01026d1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01026d6:	74 19                	je     f01026f1 <mem_init+0x1647>
f01026d8:	68 be 4f 10 f0       	push   $0xf0104fbe
f01026dd:	68 96 4d 10 f0       	push   $0xf0104d96
f01026e2:	68 da 03 00 00       	push   $0x3da
f01026e7:	68 70 4d 10 f0       	push   $0xf0104d70
f01026ec:	e8 af d9 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f01026f1:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01026f6:	74 19                	je     f0102711 <mem_init+0x1667>
f01026f8:	68 33 50 10 f0       	push   $0xf0105033
f01026fd:	68 96 4d 10 f0       	push   $0xf0104d96
f0102702:	68 db 03 00 00       	push   $0x3db
f0102707:	68 70 4d 10 f0       	push   $0xf0104d70
f010270c:	e8 8f d9 ff ff       	call   f01000a0 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102711:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102718:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010271b:	89 f0                	mov    %esi,%eax
f010271d:	2b 05 4c dc 17 f0    	sub    0xf017dc4c,%eax
f0102723:	c1 f8 03             	sar    $0x3,%eax
f0102726:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102729:	89 c2                	mov    %eax,%edx
f010272b:	c1 ea 0c             	shr    $0xc,%edx
f010272e:	3b 15 44 dc 17 f0    	cmp    0xf017dc44,%edx
f0102734:	72 12                	jb     f0102748 <mem_init+0x169e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102736:	50                   	push   %eax
f0102737:	68 e4 50 10 f0       	push   $0xf01050e4
f010273c:	6a 56                	push   $0x56
f010273e:	68 7c 4d 10 f0       	push   $0xf0104d7c
f0102743:	e8 58 d9 ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102748:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010274f:	03 03 03 
f0102752:	74 19                	je     f010276d <mem_init+0x16c3>
f0102754:	68 38 58 10 f0       	push   $0xf0105838
f0102759:	68 96 4d 10 f0       	push   $0xf0104d96
f010275e:	68 dd 03 00 00       	push   $0x3dd
f0102763:	68 70 4d 10 f0       	push   $0xf0104d70
f0102768:	e8 33 d9 ff ff       	call   f01000a0 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010276d:	83 ec 08             	sub    $0x8,%esp
f0102770:	68 00 10 00 00       	push   $0x1000
f0102775:	ff 35 48 dc 17 f0    	pushl  0xf017dc48
f010277b:	e8 81 e8 ff ff       	call   f0101001 <page_remove>
	assert(pp2->pp_ref == 0);
f0102780:	83 c4 10             	add    $0x10,%esp
f0102783:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102788:	74 19                	je     f01027a3 <mem_init+0x16f9>
f010278a:	68 22 50 10 f0       	push   $0xf0105022
f010278f:	68 96 4d 10 f0       	push   $0xf0104d96
f0102794:	68 df 03 00 00       	push   $0x3df
f0102799:	68 70 4d 10 f0       	push   $0xf0104d70
f010279e:	e8 fd d8 ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01027a3:	8b 0d 48 dc 17 f0    	mov    0xf017dc48,%ecx
f01027a9:	8b 11                	mov    (%ecx),%edx
f01027ab:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01027b1:	89 d8                	mov    %ebx,%eax
f01027b3:	2b 05 4c dc 17 f0    	sub    0xf017dc4c,%eax
f01027b9:	c1 f8 03             	sar    $0x3,%eax
f01027bc:	c1 e0 0c             	shl    $0xc,%eax
f01027bf:	39 c2                	cmp    %eax,%edx
f01027c1:	74 19                	je     f01027dc <mem_init+0x1732>
f01027c3:	68 80 53 10 f0       	push   $0xf0105380
f01027c8:	68 96 4d 10 f0       	push   $0xf0104d96
f01027cd:	68 e2 03 00 00       	push   $0x3e2
f01027d2:	68 70 4d 10 f0       	push   $0xf0104d70
f01027d7:	e8 c4 d8 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f01027dc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01027e2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01027e7:	74 19                	je     f0102802 <mem_init+0x1758>
f01027e9:	68 ad 4f 10 f0       	push   $0xf0104fad
f01027ee:	68 96 4d 10 f0       	push   $0xf0104d96
f01027f3:	68 e4 03 00 00       	push   $0x3e4
f01027f8:	68 70 4d 10 f0       	push   $0xf0104d70
f01027fd:	e8 9e d8 ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f0102802:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102808:	83 ec 0c             	sub    $0xc,%esp
f010280b:	53                   	push   %ebx
f010280c:	e8 39 e6 ff ff       	call   f0100e4a <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102811:	c7 04 24 64 58 10 f0 	movl   $0xf0105864,(%esp)
f0102818:	e8 bb 07 00 00       	call   f0102fd8 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010281d:	83 c4 10             	add    $0x10,%esp
f0102820:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102823:	5b                   	pop    %ebx
f0102824:	5e                   	pop    %esi
f0102825:	5f                   	pop    %edi
f0102826:	5d                   	pop    %ebp
f0102827:	c3                   	ret    

f0102828 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102828:	55                   	push   %ebp
f0102829:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010282b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010282e:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102831:	5d                   	pop    %ebp
f0102832:	c3                   	ret    

f0102833 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102833:	55                   	push   %ebp
f0102834:	89 e5                	mov    %esp,%ebp
f0102836:	57                   	push   %edi
f0102837:	56                   	push   %esi
f0102838:	53                   	push   %ebx
f0102839:	83 ec 1c             	sub    $0x1c,%esp
f010283c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010283f:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	
	uint32_t mem_start = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f0102842:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102845:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t mem_end = (uint32_t) ROUNDUP(va+len, PGSIZE);
f010284b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010284e:	03 45 10             	add    0x10(%ebp),%eax
f0102851:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102856:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010285b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t i;
	while (mem_start < mem_end) {
f010285e:	eb 43                	jmp    f01028a3 <user_mem_check+0x70>
		pte_t *page_tbl_entry = pgdir_walk(env->env_pgdir, (void*)mem_start, 0);
f0102860:	83 ec 04             	sub    $0x4,%esp
f0102863:	6a 00                	push   $0x0
f0102865:	53                   	push   %ebx
f0102866:	ff 77 5c             	pushl  0x5c(%edi)
f0102869:	e8 12 e6 ff ff       	call   f0100e80 <pgdir_walk>
		
		if ((mem_start>=ULIM) || !page_tbl_entry || !(*page_tbl_entry & PTE_P) || ((*page_tbl_entry & perm) != perm)) {
f010286e:	83 c4 10             	add    $0x10,%esp
f0102871:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102877:	77 10                	ja     f0102889 <user_mem_check+0x56>
f0102879:	85 c0                	test   %eax,%eax
f010287b:	74 0c                	je     f0102889 <user_mem_check+0x56>
f010287d:	8b 00                	mov    (%eax),%eax
f010287f:	a8 01                	test   $0x1,%al
f0102881:	74 06                	je     f0102889 <user_mem_check+0x56>
f0102883:	21 f0                	and    %esi,%eax
f0102885:	39 c6                	cmp    %eax,%esi
f0102887:	74 14                	je     f010289d <user_mem_check+0x6a>
			user_mem_check_addr = (mem_start<(uint32_t)va?(uint32_t)va:mem_start);
f0102889:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f010288c:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0102890:	89 1d 7c cf 17 f0    	mov    %ebx,0xf017cf7c
			return -E_FAULT;
f0102896:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010289b:	eb 10                	jmp    f01028ad <user_mem_check+0x7a>
		}
mem_start+=PGSIZE;
f010289d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// LAB 3: Your code here.
	
	uint32_t mem_start = (uint32_t) ROUNDDOWN(va, PGSIZE); 
	uint32_t mem_end = (uint32_t) ROUNDUP(va+len, PGSIZE);
	uint32_t i;
	while (mem_start < mem_end) {
f01028a3:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01028a6:	72 b8                	jb     f0102860 <user_mem_check+0x2d>
			return -E_FAULT;
		}
mem_start+=PGSIZE;
	}
	
	return 0;
f01028a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01028ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01028b0:	5b                   	pop    %ebx
f01028b1:	5e                   	pop    %esi
f01028b2:	5f                   	pop    %edi
f01028b3:	5d                   	pop    %ebp
f01028b4:	c3                   	ret    

f01028b5 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01028b5:	55                   	push   %ebp
f01028b6:	89 e5                	mov    %esp,%ebp
f01028b8:	53                   	push   %ebx
f01028b9:	83 ec 04             	sub    $0x4,%esp
f01028bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01028bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01028c2:	83 c8 04             	or     $0x4,%eax
f01028c5:	50                   	push   %eax
f01028c6:	ff 75 10             	pushl  0x10(%ebp)
f01028c9:	ff 75 0c             	pushl  0xc(%ebp)
f01028cc:	53                   	push   %ebx
f01028cd:	e8 61 ff ff ff       	call   f0102833 <user_mem_check>
f01028d2:	83 c4 10             	add    $0x10,%esp
f01028d5:	85 c0                	test   %eax,%eax
f01028d7:	79 21                	jns    f01028fa <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f01028d9:	83 ec 04             	sub    $0x4,%esp
f01028dc:	ff 35 7c cf 17 f0    	pushl  0xf017cf7c
f01028e2:	ff 73 48             	pushl  0x48(%ebx)
f01028e5:	68 90 58 10 f0       	push   $0xf0105890
f01028ea:	e8 e9 06 00 00       	call   f0102fd8 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01028ef:	89 1c 24             	mov    %ebx,(%esp)
f01028f2:	e8 df 05 00 00       	call   f0102ed6 <env_destroy>
f01028f7:	83 c4 10             	add    $0x10,%esp
	}
}
f01028fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01028fd:	c9                   	leave  
f01028fe:	c3                   	ret    

f01028ff <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01028ff:	55                   	push   %ebp
f0102900:	89 e5                	mov    %esp,%ebp
f0102902:	57                   	push   %edi
f0102903:	56                   	push   %esi
f0102904:	53                   	push   %ebx
f0102905:	83 ec 0c             	sub    $0xc,%esp
f0102908:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
f010290a:	89 d3                	mov    %edx,%ebx
f010290c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102912:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102919:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (; begin < end; begin += PGSIZE) {
f010291f:	eb 3d                	jmp    f010295e <region_alloc+0x5f>
		struct PageInfo *pg = page_alloc(0);
f0102921:	83 ec 0c             	sub    $0xc,%esp
f0102924:	6a 00                	push   $0x0
f0102926:	e8 b5 e4 ff ff       	call   f0100de0 <page_alloc>
		if (!pg) panic("region_alloc failed!");
f010292b:	83 c4 10             	add    $0x10,%esp
f010292e:	85 c0                	test   %eax,%eax
f0102930:	75 17                	jne    f0102949 <region_alloc+0x4a>
f0102932:	83 ec 04             	sub    $0x4,%esp
f0102935:	68 c5 58 10 f0       	push   $0xf01058c5
f010293a:	68 06 01 00 00       	push   $0x106
f010293f:	68 da 58 10 f0       	push   $0xf01058da
f0102944:	e8 57 d7 ff ff       	call   f01000a0 <_panic>
		page_insert(e->env_pgdir, pg, begin, PTE_W | PTE_U);
f0102949:	6a 06                	push   $0x6
f010294b:	53                   	push   %ebx
f010294c:	50                   	push   %eax
f010294d:	ff 77 5c             	pushl  0x5c(%edi)
f0102950:	e8 ef e6 ff ff       	call   f0101044 <page_insert>
static void
region_alloc(struct Env *e, void *va, size_t len)
{
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
	for (; begin < end; begin += PGSIZE) {
f0102955:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010295b:	83 c4 10             	add    $0x10,%esp
f010295e:	39 f3                	cmp    %esi,%ebx
f0102960:	72 bf                	jb     f0102921 <region_alloc+0x22>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0102962:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102965:	5b                   	pop    %ebx
f0102966:	5e                   	pop    %esi
f0102967:	5f                   	pop    %edi
f0102968:	5d                   	pop    %ebp
f0102969:	c3                   	ret    

f010296a <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010296a:	55                   	push   %ebp
f010296b:	89 e5                	mov    %esp,%ebp
f010296d:	8b 55 08             	mov    0x8(%ebp),%edx
f0102970:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102973:	85 d2                	test   %edx,%edx
f0102975:	75 11                	jne    f0102988 <envid2env+0x1e>
		*env_store = curenv;
f0102977:	a1 88 cf 17 f0       	mov    0xf017cf88,%eax
f010297c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010297f:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102981:	b8 00 00 00 00       	mov    $0x0,%eax
f0102986:	eb 5e                	jmp    f01029e6 <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102988:	89 d0                	mov    %edx,%eax
f010298a:	25 ff 03 00 00       	and    $0x3ff,%eax
f010298f:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102992:	c1 e0 05             	shl    $0x5,%eax
f0102995:	03 05 8c cf 17 f0    	add    0xf017cf8c,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010299b:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f010299f:	74 05                	je     f01029a6 <envid2env+0x3c>
f01029a1:	3b 50 48             	cmp    0x48(%eax),%edx
f01029a4:	74 10                	je     f01029b6 <envid2env+0x4c>
		*env_store = 0;
f01029a6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01029a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01029af:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01029b4:	eb 30                	jmp    f01029e6 <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01029b6:	84 c9                	test   %cl,%cl
f01029b8:	74 22                	je     f01029dc <envid2env+0x72>
f01029ba:	8b 15 88 cf 17 f0    	mov    0xf017cf88,%edx
f01029c0:	39 d0                	cmp    %edx,%eax
f01029c2:	74 18                	je     f01029dc <envid2env+0x72>
f01029c4:	8b 4a 48             	mov    0x48(%edx),%ecx
f01029c7:	39 48 4c             	cmp    %ecx,0x4c(%eax)
f01029ca:	74 10                	je     f01029dc <envid2env+0x72>
		*env_store = 0;
f01029cc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01029cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01029d5:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01029da:	eb 0a                	jmp    f01029e6 <envid2env+0x7c>
	}

	*env_store = e;
f01029dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01029df:	89 01                	mov    %eax,(%ecx)
	return 0;
f01029e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01029e6:	5d                   	pop    %ebp
f01029e7:	c3                   	ret    

f01029e8 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01029e8:	55                   	push   %ebp
f01029e9:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01029eb:	b8 00 b3 11 f0       	mov    $0xf011b300,%eax
f01029f0:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01029f3:	b8 23 00 00 00       	mov    $0x23,%eax
f01029f8:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01029fa:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01029fc:	b8 10 00 00 00       	mov    $0x10,%eax
f0102a01:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102a03:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102a05:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102a07:	ea 0e 2a 10 f0 08 00 	ljmp   $0x8,$0xf0102a0e
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102a0e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a13:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102a16:	5d                   	pop    %ebp
f0102a17:	c3                   	ret    

f0102a18 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102a18:	55                   	push   %ebp
f0102a19:	89 e5                	mov    %esp,%ebp
f0102a1b:	56                   	push   %esi
f0102a1c:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1;i >= 0; --i) {
		envs[i].env_id = 0;
f0102a1d:	8b 35 8c cf 17 f0    	mov    0xf017cf8c,%esi
f0102a23:	8b 15 90 cf 17 f0    	mov    0xf017cf90,%edx
f0102a29:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f0102a2f:	8d 5e a0             	lea    -0x60(%esi),%ebx
f0102a32:	89 c1                	mov    %eax,%ecx
f0102a34:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102a3b:	89 50 44             	mov    %edx,0x44(%eax)
f0102a3e:	83 e8 60             	sub    $0x60,%eax
		 env_free_list = envs+i;
f0102a41:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1;i >= 0; --i) {
f0102a43:	39 d8                	cmp    %ebx,%eax
f0102a45:	75 eb                	jne    f0102a32 <env_init+0x1a>
f0102a47:	89 35 90 cf 17 f0    	mov    %esi,0xf017cf90
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		 env_free_list = envs+i;
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0102a4d:	e8 96 ff ff ff       	call   f01029e8 <env_init_percpu>
}
f0102a52:	5b                   	pop    %ebx
f0102a53:	5e                   	pop    %esi
f0102a54:	5d                   	pop    %ebp
f0102a55:	c3                   	ret    

f0102a56 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102a56:	55                   	push   %ebp
f0102a57:	89 e5                	mov    %esp,%ebp
f0102a59:	53                   	push   %ebx
f0102a5a:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102a5d:	8b 1d 90 cf 17 f0    	mov    0xf017cf90,%ebx
f0102a63:	85 db                	test   %ebx,%ebx
f0102a65:	0f 84 74 01 00 00    	je     f0102bdf <env_alloc+0x189>
	 
	struct PageInfo *p = NULL;
	//p = page_alloc(ALLOC_ZERO);
	
	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO))){
f0102a6b:	83 ec 0c             	sub    $0xc,%esp
f0102a6e:	6a 01                	push   $0x1
f0102a70:	e8 6b e3 ff ff       	call   f0100de0 <page_alloc>
f0102a75:	83 c4 10             	add    $0x10,%esp
f0102a78:	85 c0                	test   %eax,%eax
f0102a7a:	75 16                	jne    f0102a92 <env_alloc+0x3c>
		panic("env_alloc: %e", E_NO_MEM);
f0102a7c:	6a 04                	push   $0x4
f0102a7e:	68 e5 58 10 f0       	push   $0xf01058e5
f0102a83:	68 aa 00 00 00       	push   $0xaa
f0102a88:	68 da 58 10 f0       	push   $0xf01058da
f0102a8d:	e8 0e d6 ff ff       	call   f01000a0 <_panic>
		return -E_NO_MEM;
	}
	
	p->pp_ref++;
f0102a92:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a97:	2b 05 4c dc 17 f0    	sub    0xf017dc4c,%eax
f0102a9d:	c1 f8 03             	sar    $0x3,%eax
f0102aa0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102aa3:	89 c2                	mov    %eax,%edx
f0102aa5:	c1 ea 0c             	shr    $0xc,%edx
f0102aa8:	3b 15 44 dc 17 f0    	cmp    0xf017dc44,%edx
f0102aae:	72 12                	jb     f0102ac2 <env_alloc+0x6c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ab0:	50                   	push   %eax
f0102ab1:	68 e4 50 10 f0       	push   $0xf01050e4
f0102ab6:	6a 56                	push   $0x56
f0102ab8:	68 7c 4d 10 f0       	push   $0xf0104d7c
f0102abd:	e8 de d5 ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f0102ac2:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = page2kva(p);
f0102ac7:	89 43 5c             	mov    %eax,0x5c(%ebx)
memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102aca:	83 ec 04             	sub    $0x4,%esp
f0102acd:	68 00 10 00 00       	push   $0x1000
f0102ad2:	ff 35 48 dc 17 f0    	pushl  0xf017dc48
f0102ad8:	50                   	push   %eax
f0102ad9:	e8 61 19 00 00       	call   f010443f <memcpy>

	
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102ade:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ae1:	83 c4 10             	add    $0x10,%esp
f0102ae4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ae9:	77 15                	ja     f0102b00 <env_alloc+0xaa>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102aeb:	50                   	push   %eax
f0102aec:	68 84 52 10 f0       	push   $0xf0105284
f0102af1:	68 b3 00 00 00       	push   $0xb3
f0102af6:	68 da 58 10 f0       	push   $0xf01058da
f0102afb:	e8 a0 d5 ff ff       	call   f01000a0 <_panic>
f0102b00:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102b06:	83 ca 05             	or     $0x5,%edx
f0102b09:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102b0f:	8b 43 48             	mov    0x48(%ebx),%eax
f0102b12:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102b17:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102b1c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102b21:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102b24:	8b 0d 8c cf 17 f0    	mov    0xf017cf8c,%ecx
f0102b2a:	89 da                	mov    %ebx,%edx
f0102b2c:	29 ca                	sub    %ecx,%edx
f0102b2e:	c1 fa 05             	sar    $0x5,%edx
f0102b31:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102b37:	09 d0                	or     %edx,%eax
f0102b39:	89 43 48             	mov    %eax,0x48(%ebx)
	cprintf("envs: %x, e: %x, e->env_id: %x\n", envs, e, e->env_id);
f0102b3c:	50                   	push   %eax
f0102b3d:	53                   	push   %ebx
f0102b3e:	51                   	push   %ecx
f0102b3f:	68 50 59 10 f0       	push   $0xf0105950
f0102b44:	e8 8f 04 00 00       	call   f0102fd8 <cprintf>

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102b49:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b4c:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102b4f:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102b56:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102b5d:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102b64:	83 c4 0c             	add    $0xc,%esp
f0102b67:	6a 44                	push   $0x44
f0102b69:	6a 00                	push   $0x0
f0102b6b:	53                   	push   %ebx
f0102b6c:	e8 19 18 00 00       	call   f010438a <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102b71:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102b77:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102b7d:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102b83:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102b8a:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102b90:	8b 43 44             	mov    0x44(%ebx),%eax
f0102b93:	a3 90 cf 17 f0       	mov    %eax,0xf017cf90
	*newenv_store = e;
f0102b98:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b9b:	89 18                	mov    %ebx,(%eax)

	cprintf("env_id, %x\n", e->env_id);
f0102b9d:	83 c4 08             	add    $0x8,%esp
f0102ba0:	ff 73 48             	pushl  0x48(%ebx)
f0102ba3:	68 f3 58 10 f0       	push   $0xf01058f3
f0102ba8:	e8 2b 04 00 00       	call   f0102fd8 <cprintf>
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102bad:	8b 53 48             	mov    0x48(%ebx),%edx
f0102bb0:	a1 88 cf 17 f0       	mov    0xf017cf88,%eax
f0102bb5:	83 c4 10             	add    $0x10,%esp
f0102bb8:	85 c0                	test   %eax,%eax
f0102bba:	74 05                	je     f0102bc1 <env_alloc+0x16b>
f0102bbc:	8b 40 48             	mov    0x48(%eax),%eax
f0102bbf:	eb 05                	jmp    f0102bc6 <env_alloc+0x170>
f0102bc1:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bc6:	83 ec 04             	sub    $0x4,%esp
f0102bc9:	52                   	push   %edx
f0102bca:	50                   	push   %eax
f0102bcb:	68 ff 58 10 f0       	push   $0xf01058ff
f0102bd0:	e8 03 04 00 00       	call   f0102fd8 <cprintf>
	return 0;
f0102bd5:	83 c4 10             	add    $0x10,%esp
f0102bd8:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bdd:	eb 05                	jmp    f0102be4 <env_alloc+0x18e>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102bdf:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
	*newenv_store = e;

	cprintf("env_id, %x\n", e->env_id);
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102be4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102be7:	c9                   	leave  
f0102be8:	c3                   	ret    

f0102be9 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102be9:	55                   	push   %ebp
f0102bea:	89 e5                	mov    %esp,%ebp
f0102bec:	57                   	push   %edi
f0102bed:	56                   	push   %esi
f0102bee:	53                   	push   %ebx
f0102bef:	83 ec 34             	sub    $0x34,%esp
f0102bf2:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *new;
	env_alloc(&new, 0);
f0102bf5:	6a 00                	push   $0x0
f0102bf7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102bfa:	50                   	push   %eax
f0102bfb:	e8 56 fe ff ff       	call   f0102a56 <env_alloc>
cprintf("env .pointer value %x\n", new);
f0102c00:	83 c4 08             	add    $0x8,%esp
f0102c03:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102c06:	68 14 59 10 f0       	push   $0xf0105914
f0102c0b:	e8 c8 03 00 00       	call   f0102fd8 <cprintf>
	load_icode(new, binary);
f0102c10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102c13:	89 45 d4             	mov    %eax,-0x2c(%ebp)
static void
load_icode(struct Env *e, uint8_t *binary)
{   
    struct Elf *ELFHDR = (struct Elf *) binary;
    struct Proghdr *ph, *eph;
    if (ELFHDR->e_magic != ELF_MAGIC){
f0102c16:	83 c4 10             	add    $0x10,%esp
f0102c19:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102c1f:	74 17                	je     f0102c38 <env_create+0x4f>
        panic("load_icode: ELF_MAGIC not matching");
f0102c21:	83 ec 04             	sub    $0x4,%esp
f0102c24:	68 70 59 10 f0       	push   $0xf0105970
f0102c29:	68 2d 01 00 00       	push   $0x12d
f0102c2e:	68 da 58 10 f0       	push   $0xf01058da
f0102c33:	e8 68 d4 ff ff       	call   f01000a0 <_panic>

}
    ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0102c38:	89 fb                	mov    %edi,%ebx
f0102c3a:	03 5f 1c             	add    0x1c(%edi),%ebx
    eph = ph + ELFHDR->e_phnum;
f0102c3d:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102c41:	c1 e6 05             	shl    $0x5,%esi
f0102c44:	01 de                	add    %ebx,%esi
    lcr3(PADDR(e->env_pgdir));
f0102c46:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c49:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c4c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c51:	77 15                	ja     f0102c68 <env_create+0x7f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c53:	50                   	push   %eax
f0102c54:	68 84 52 10 f0       	push   $0xf0105284
f0102c59:	68 32 01 00 00       	push   $0x132
f0102c5e:	68 da 58 10 f0       	push   $0xf01058da
f0102c63:	e8 38 d4 ff ff       	call   f01000a0 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102c68:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c6d:	0f 22 d8             	mov    %eax,%cr3
f0102c70:	eb 59                	jmp    f0102ccb <env_create+0xe2>
    for(;ph<eph;ph++)
    {
        if(ph->p_type==ELF_PROG_LOAD){
f0102c72:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102c75:	75 2a                	jne    f0102ca1 <env_create+0xb8>
            if(ph->p_filesz > ph->p_memsz)
f0102c77:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102c7a:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0102c7d:	76 17                	jbe    f0102c96 <env_create+0xad>
                panic("load_icode: ph->p_filesz > ph->p_memsz");
f0102c7f:	83 ec 04             	sub    $0x4,%esp
f0102c82:	68 94 59 10 f0       	push   $0xf0105994
f0102c87:	68 37 01 00 00       	push   $0x137
f0102c8c:	68 da 58 10 f0       	push   $0xf01058da
f0102c91:	e8 0a d4 ff ff       	call   f01000a0 <_panic>
            //cprintf("ph=%x",ph);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0102c96:	8b 53 08             	mov    0x8(%ebx),%edx
f0102c99:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c9c:	e8 5e fc ff ff       	call   f01028ff <region_alloc>
            }
            memset((void *)ph->p_va, 0, ph->p_memsz);
f0102ca1:	83 ec 04             	sub    $0x4,%esp
f0102ca4:	ff 73 14             	pushl  0x14(%ebx)
f0102ca7:	6a 00                	push   $0x0
f0102ca9:	ff 73 08             	pushl  0x8(%ebx)
f0102cac:	e8 d9 16 00 00       	call   f010438a <memset>
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);    }
f0102cb1:	83 c4 0c             	add    $0xc,%esp
f0102cb4:	ff 73 10             	pushl  0x10(%ebx)
f0102cb7:	89 f8                	mov    %edi,%eax
f0102cb9:	03 43 04             	add    0x4(%ebx),%eax
f0102cbc:	50                   	push   %eax
f0102cbd:	ff 73 08             	pushl  0x8(%ebx)
f0102cc0:	e8 7a 17 00 00       	call   f010443f <memcpy>

}
    ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    eph = ph + ELFHDR->e_phnum;
    lcr3(PADDR(e->env_pgdir));
    for(;ph<eph;ph++)
f0102cc5:	83 c3 20             	add    $0x20,%ebx
f0102cc8:	83 c4 10             	add    $0x10,%esp
f0102ccb:	39 de                	cmp    %ebx,%esi
f0102ccd:	77 a3                	ja     f0102c72 <env_create+0x89>
            //cprintf("ph=%x",ph);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
            }
            memset((void *)ph->p_va, 0, ph->p_memsz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);    }
    lcr3(PADDR(kern_pgdir));
f0102ccf:	a1 48 dc 17 f0       	mov    0xf017dc48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cd4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102cd9:	77 15                	ja     f0102cf0 <env_create+0x107>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cdb:	50                   	push   %eax
f0102cdc:	68 84 52 10 f0       	push   $0xf0105284
f0102ce1:	68 3d 01 00 00       	push   $0x13d
f0102ce6:	68 da 58 10 f0       	push   $0xf01058da
f0102ceb:	e8 b0 d3 ff ff       	call   f01000a0 <_panic>
f0102cf0:	05 00 00 00 10       	add    $0x10000000,%eax
f0102cf5:	0f 22 d8             	mov    %eax,%cr3
    e->env_tf.tf_eip = ELFHDR->e_entry;
f0102cf8:	8b 47 18             	mov    0x18(%edi),%eax
f0102cfb:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102cfe:	89 46 30             	mov    %eax,0x30(%esi)
    // Now map one page for the program's initial stack
    // at virtual address USTACKTOP - PGSIZE.
    // LAB 3: Your code here.
    region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0102d01:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102d06:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102d0b:	89 f0                	mov    %esi,%eax
f0102d0d:	e8 ed fb ff ff       	call   f01028ff <region_alloc>
	// LAB 3: Your code here.
	struct Env *new;
	env_alloc(&new, 0);
cprintf("env .pointer value %x\n", new);
	load_icode(new, binary);
}
f0102d12:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d15:	5b                   	pop    %ebx
f0102d16:	5e                   	pop    %esi
f0102d17:	5f                   	pop    %edi
f0102d18:	5d                   	pop    %ebp
f0102d19:	c3                   	ret    

f0102d1a <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102d1a:	55                   	push   %ebp
f0102d1b:	89 e5                	mov    %esp,%ebp
f0102d1d:	57                   	push   %edi
f0102d1e:	56                   	push   %esi
f0102d1f:	53                   	push   %ebx
f0102d20:	83 ec 1c             	sub    $0x1c,%esp
f0102d23:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102d26:	8b 15 88 cf 17 f0    	mov    0xf017cf88,%edx
f0102d2c:	39 fa                	cmp    %edi,%edx
f0102d2e:	75 29                	jne    f0102d59 <env_free+0x3f>
		lcr3(PADDR(kern_pgdir));
f0102d30:	a1 48 dc 17 f0       	mov    0xf017dc48,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d35:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102d3a:	77 15                	ja     f0102d51 <env_free+0x37>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d3c:	50                   	push   %eax
f0102d3d:	68 84 52 10 f0       	push   $0xf0105284
f0102d42:	68 65 01 00 00       	push   $0x165
f0102d47:	68 da 58 10 f0       	push   $0xf01058da
f0102d4c:	e8 4f d3 ff ff       	call   f01000a0 <_panic>
f0102d51:	05 00 00 00 10       	add    $0x10000000,%eax
f0102d56:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102d59:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102d5c:	85 d2                	test   %edx,%edx
f0102d5e:	74 05                	je     f0102d65 <env_free+0x4b>
f0102d60:	8b 42 48             	mov    0x48(%edx),%eax
f0102d63:	eb 05                	jmp    f0102d6a <env_free+0x50>
f0102d65:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d6a:	83 ec 04             	sub    $0x4,%esp
f0102d6d:	51                   	push   %ecx
f0102d6e:	50                   	push   %eax
f0102d6f:	68 2b 59 10 f0       	push   $0xf010592b
f0102d74:	e8 5f 02 00 00       	call   f0102fd8 <cprintf>
f0102d79:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102d7c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102d83:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102d86:	89 d0                	mov    %edx,%eax
f0102d88:	c1 e0 02             	shl    $0x2,%eax
f0102d8b:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102d8e:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102d91:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102d94:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102d9a:	0f 84 a8 00 00 00    	je     f0102e48 <env_free+0x12e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102da0:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102da6:	89 f0                	mov    %esi,%eax
f0102da8:	c1 e8 0c             	shr    $0xc,%eax
f0102dab:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102dae:	39 05 44 dc 17 f0    	cmp    %eax,0xf017dc44
f0102db4:	77 15                	ja     f0102dcb <env_free+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102db6:	56                   	push   %esi
f0102db7:	68 e4 50 10 f0       	push   $0xf01050e4
f0102dbc:	68 74 01 00 00       	push   $0x174
f0102dc1:	68 da 58 10 f0       	push   $0xf01058da
f0102dc6:	e8 d5 d2 ff ff       	call   f01000a0 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102dcb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102dce:	c1 e0 16             	shl    $0x16,%eax
f0102dd1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102dd4:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102dd9:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102de0:	01 
f0102de1:	74 17                	je     f0102dfa <env_free+0xe0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102de3:	83 ec 08             	sub    $0x8,%esp
f0102de6:	89 d8                	mov    %ebx,%eax
f0102de8:	c1 e0 0c             	shl    $0xc,%eax
f0102deb:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102dee:	50                   	push   %eax
f0102def:	ff 77 5c             	pushl  0x5c(%edi)
f0102df2:	e8 0a e2 ff ff       	call   f0101001 <page_remove>
f0102df7:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102dfa:	83 c3 01             	add    $0x1,%ebx
f0102dfd:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102e03:	75 d4                	jne    f0102dd9 <env_free+0xbf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102e05:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102e08:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102e0b:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e12:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102e15:	3b 05 44 dc 17 f0    	cmp    0xf017dc44,%eax
f0102e1b:	72 14                	jb     f0102e31 <env_free+0x117>
		panic("pa2page called with invalid pa");
f0102e1d:	83 ec 04             	sub    $0x4,%esp
f0102e20:	68 28 52 10 f0       	push   $0xf0105228
f0102e25:	6a 4f                	push   $0x4f
f0102e27:	68 7c 4d 10 f0       	push   $0xf0104d7c
f0102e2c:	e8 6f d2 ff ff       	call   f01000a0 <_panic>
		page_decref(pa2page(pa));
f0102e31:	83 ec 0c             	sub    $0xc,%esp
f0102e34:	a1 4c dc 17 f0       	mov    0xf017dc4c,%eax
f0102e39:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102e3c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102e3f:	50                   	push   %eax
f0102e40:	e8 1a e0 ff ff       	call   f0100e5f <page_decref>
f0102e45:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102e48:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102e4c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102e4f:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102e54:	0f 85 29 ff ff ff    	jne    f0102d83 <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102e5a:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e5d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e62:	77 15                	ja     f0102e79 <env_free+0x15f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e64:	50                   	push   %eax
f0102e65:	68 84 52 10 f0       	push   $0xf0105284
f0102e6a:	68 82 01 00 00       	push   $0x182
f0102e6f:	68 da 58 10 f0       	push   $0xf01058da
f0102e74:	e8 27 d2 ff ff       	call   f01000a0 <_panic>
	e->env_pgdir = 0;
f0102e79:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e80:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e85:	c1 e8 0c             	shr    $0xc,%eax
f0102e88:	3b 05 44 dc 17 f0    	cmp    0xf017dc44,%eax
f0102e8e:	72 14                	jb     f0102ea4 <env_free+0x18a>
		panic("pa2page called with invalid pa");
f0102e90:	83 ec 04             	sub    $0x4,%esp
f0102e93:	68 28 52 10 f0       	push   $0xf0105228
f0102e98:	6a 4f                	push   $0x4f
f0102e9a:	68 7c 4d 10 f0       	push   $0xf0104d7c
f0102e9f:	e8 fc d1 ff ff       	call   f01000a0 <_panic>
	page_decref(pa2page(pa));
f0102ea4:	83 ec 0c             	sub    $0xc,%esp
f0102ea7:	8b 15 4c dc 17 f0    	mov    0xf017dc4c,%edx
f0102ead:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102eb0:	50                   	push   %eax
f0102eb1:	e8 a9 df ff ff       	call   f0100e5f <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102eb6:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102ebd:	a1 90 cf 17 f0       	mov    0xf017cf90,%eax
f0102ec2:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102ec5:	89 3d 90 cf 17 f0    	mov    %edi,0xf017cf90
}
f0102ecb:	83 c4 10             	add    $0x10,%esp
f0102ece:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ed1:	5b                   	pop    %ebx
f0102ed2:	5e                   	pop    %esi
f0102ed3:	5f                   	pop    %edi
f0102ed4:	5d                   	pop    %ebp
f0102ed5:	c3                   	ret    

f0102ed6 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0102ed6:	55                   	push   %ebp
f0102ed7:	89 e5                	mov    %esp,%ebp
f0102ed9:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0102edc:	ff 75 08             	pushl  0x8(%ebp)
f0102edf:	e8 36 fe ff ff       	call   f0102d1a <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102ee4:	c7 04 24 bc 59 10 f0 	movl   $0xf01059bc,(%esp)
f0102eeb:	e8 e8 00 00 00       	call   f0102fd8 <cprintf>
f0102ef0:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0102ef3:	83 ec 0c             	sub    $0xc,%esp
f0102ef6:	6a 00                	push   $0x0
f0102ef8:	e8 12 d9 ff ff       	call   f010080f <monitor>
f0102efd:	83 c4 10             	add    $0x10,%esp
f0102f00:	eb f1                	jmp    f0102ef3 <env_destroy+0x1d>

f0102f02 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102f02:	55                   	push   %ebp
f0102f03:	89 e5                	mov    %esp,%ebp
f0102f05:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f0102f08:	8b 65 08             	mov    0x8(%ebp),%esp
f0102f0b:	61                   	popa   
f0102f0c:	07                   	pop    %es
f0102f0d:	1f                   	pop    %ds
f0102f0e:	83 c4 08             	add    $0x8,%esp
f0102f11:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102f12:	68 41 59 10 f0       	push   $0xf0105941
f0102f17:	68 aa 01 00 00       	push   $0x1aa
f0102f1c:	68 da 58 10 f0       	push   $0xf01058da
f0102f21:	e8 7a d1 ff ff       	call   f01000a0 <_panic>

f0102f26 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0102f26:	55                   	push   %ebp
f0102f27:	89 e5                	mov    %esp,%ebp
f0102f29:	83 ec 08             	sub    $0x8,%esp
f0102f2c:	8b 45 08             	mov    0x8(%ebp),%eax
    if (e->env_status == ENV_RUNNING)
        e->env_status = ENV_RUNNABLE;
    curenv = e;
f0102f2f:	a3 88 cf 17 f0       	mov    %eax,0xf017cf88
    e->env_status = ENV_RUNNING;
f0102f34:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    e->env_runs++;
f0102f3b:	83 40 58 01          	addl   $0x1,0x58(%eax)
    lcr3(PADDR(e->env_pgdir));
f0102f3f:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f42:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102f48:	77 15                	ja     f0102f5f <env_run+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f4a:	52                   	push   %edx
f0102f4b:	68 84 52 10 f0       	push   $0xf0105284
f0102f50:	68 bb 01 00 00       	push   $0x1bb
f0102f55:	68 da 58 10 f0       	push   $0xf01058da
f0102f5a:	e8 41 d1 ff ff       	call   f01000a0 <_panic>
f0102f5f:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0102f65:	0f 22 da             	mov    %edx,%cr3
    env_pop_tf(&e->env_tf);
f0102f68:	83 ec 0c             	sub    $0xc,%esp
f0102f6b:	50                   	push   %eax
f0102f6c:	e8 91 ff ff ff       	call   f0102f02 <env_pop_tf>

f0102f71 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102f71:	55                   	push   %ebp
f0102f72:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f74:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f79:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f7c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102f7d:	ba 71 00 00 00       	mov    $0x71,%edx
f0102f82:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102f83:	0f b6 c0             	movzbl %al,%eax
}
f0102f86:	5d                   	pop    %ebp
f0102f87:	c3                   	ret    

f0102f88 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102f88:	55                   	push   %ebp
f0102f89:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102f8b:	ba 70 00 00 00       	mov    $0x70,%edx
f0102f90:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f93:	ee                   	out    %al,(%dx)
f0102f94:	ba 71 00 00 00       	mov    $0x71,%edx
f0102f99:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f9c:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102f9d:	5d                   	pop    %ebp
f0102f9e:	c3                   	ret    

f0102f9f <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102f9f:	55                   	push   %ebp
f0102fa0:	89 e5                	mov    %esp,%ebp
f0102fa2:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102fa5:	ff 75 08             	pushl  0x8(%ebp)
f0102fa8:	e8 5a d6 ff ff       	call   f0100607 <cputchar>
	*cnt++;
}
f0102fad:	83 c4 10             	add    $0x10,%esp
f0102fb0:	c9                   	leave  
f0102fb1:	c3                   	ret    

f0102fb2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102fb2:	55                   	push   %ebp
f0102fb3:	89 e5                	mov    %esp,%ebp
f0102fb5:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102fb8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap); 
f0102fbf:	ff 75 0c             	pushl  0xc(%ebp)
f0102fc2:	ff 75 08             	pushl  0x8(%ebp)
f0102fc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102fc8:	50                   	push   %eax
f0102fc9:	68 9f 2f 10 f0       	push   $0xf0102f9f
f0102fce:	e8 09 0d 00 00       	call   f0103cdc <vprintfmt>
	return cnt;
}
f0102fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102fd6:	c9                   	leave  
f0102fd7:	c3                   	ret    

f0102fd8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102fd8:	55                   	push   %ebp
f0102fd9:	89 e5                	mov    %esp,%ebp
f0102fdb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102fde:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);//vcprintf( const char *format, va_list arg );
f0102fe1:	50                   	push   %eax
f0102fe2:	ff 75 08             	pushl  0x8(%ebp)
f0102fe5:	e8 c8 ff ff ff       	call   f0102fb2 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102fea:	c9                   	leave  
f0102feb:	c3                   	ret    

f0102fec <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0102fec:	55                   	push   %ebp
f0102fed:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0102fef:	b8 c0 d7 17 f0       	mov    $0xf017d7c0,%eax
f0102ff4:	c7 05 c4 d7 17 f0 00 	movl   $0xf0000000,0xf017d7c4
f0102ffb:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0102ffe:	66 c7 05 c8 d7 17 f0 	movw   $0x10,0xf017d7c8
f0103005:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103007:	66 c7 05 48 b3 11 f0 	movw   $0x67,0xf011b348
f010300e:	67 00 
f0103010:	66 a3 4a b3 11 f0    	mov    %ax,0xf011b34a
f0103016:	89 c2                	mov    %eax,%edx
f0103018:	c1 ea 10             	shr    $0x10,%edx
f010301b:	88 15 4c b3 11 f0    	mov    %dl,0xf011b34c
f0103021:	c6 05 4e b3 11 f0 40 	movb   $0x40,0xf011b34e
f0103028:	c1 e8 18             	shr    $0x18,%eax
f010302b:	a2 4f b3 11 f0       	mov    %al,0xf011b34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103030:	c6 05 4d b3 11 f0 89 	movb   $0x89,0xf011b34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103037:	b8 28 00 00 00       	mov    $0x28,%eax
f010303c:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f010303f:	b8 50 b3 11 f0       	mov    $0xf011b350,%eax
f0103044:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103047:	5d                   	pop    %ebp
f0103048:	c3                   	ret    

f0103049 <trap_init>:
}


void
trap_init(void)
{
f0103049:	55                   	push   %ebp
f010304a:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[0], 1, GD_KT, i0, 0);
f010304c:	b8 a6 36 10 f0       	mov    $0xf01036a6,%eax
f0103051:	66 a3 a0 cf 17 f0    	mov    %ax,0xf017cfa0
f0103057:	66 c7 05 a2 cf 17 f0 	movw   $0x8,0xf017cfa2
f010305e:	08 00 
f0103060:	c6 05 a4 cf 17 f0 00 	movb   $0x0,0xf017cfa4
f0103067:	c6 05 a5 cf 17 f0 8f 	movb   $0x8f,0xf017cfa5
f010306e:	c1 e8 10             	shr    $0x10,%eax
f0103071:	66 a3 a6 cf 17 f0    	mov    %ax,0xf017cfa6
	    SETGATE(idt[1], 1, GD_KT, i1, 0);
f0103077:	b8 ac 36 10 f0       	mov    $0xf01036ac,%eax
f010307c:	66 a3 a8 cf 17 f0    	mov    %ax,0xf017cfa8
f0103082:	66 c7 05 aa cf 17 f0 	movw   $0x8,0xf017cfaa
f0103089:	08 00 
f010308b:	c6 05 ac cf 17 f0 00 	movb   $0x0,0xf017cfac
f0103092:	c6 05 ad cf 17 f0 8f 	movb   $0x8f,0xf017cfad
f0103099:	c1 e8 10             	shr    $0x10,%eax
f010309c:	66 a3 ae cf 17 f0    	mov    %ax,0xf017cfae
	    SETGATE(idt[3], 1, GD_KT, i3, 3);
f01030a2:	b8 b2 36 10 f0       	mov    $0xf01036b2,%eax
f01030a7:	66 a3 b8 cf 17 f0    	mov    %ax,0xf017cfb8
f01030ad:	66 c7 05 ba cf 17 f0 	movw   $0x8,0xf017cfba
f01030b4:	08 00 
f01030b6:	c6 05 bc cf 17 f0 00 	movb   $0x0,0xf017cfbc
f01030bd:	c6 05 bd cf 17 f0 ef 	movb   $0xef,0xf017cfbd
f01030c4:	c1 e8 10             	shr    $0x10,%eax
f01030c7:	66 a3 be cf 17 f0    	mov    %ax,0xf017cfbe
	    SETGATE(idt[4], 1, GD_KT, i4, 0);
f01030cd:	b8 b8 36 10 f0       	mov    $0xf01036b8,%eax
f01030d2:	66 a3 c0 cf 17 f0    	mov    %ax,0xf017cfc0
f01030d8:	66 c7 05 c2 cf 17 f0 	movw   $0x8,0xf017cfc2
f01030df:	08 00 
f01030e1:	c6 05 c4 cf 17 f0 00 	movb   $0x0,0xf017cfc4
f01030e8:	c6 05 c5 cf 17 f0 8f 	movb   $0x8f,0xf017cfc5
f01030ef:	c1 e8 10             	shr    $0x10,%eax
f01030f2:	66 a3 c6 cf 17 f0    	mov    %ax,0xf017cfc6
	    SETGATE(idt[5], 1, GD_KT, i5, 0);
f01030f8:	b8 be 36 10 f0       	mov    $0xf01036be,%eax
f01030fd:	66 a3 c8 cf 17 f0    	mov    %ax,0xf017cfc8
f0103103:	66 c7 05 ca cf 17 f0 	movw   $0x8,0xf017cfca
f010310a:	08 00 
f010310c:	c6 05 cc cf 17 f0 00 	movb   $0x0,0xf017cfcc
f0103113:	c6 05 cd cf 17 f0 8f 	movb   $0x8f,0xf017cfcd
f010311a:	c1 e8 10             	shr    $0x10,%eax
f010311d:	66 a3 ce cf 17 f0    	mov    %ax,0xf017cfce
	    SETGATE(idt[6], 1, GD_KT, i6, 0);
f0103123:	b8 c4 36 10 f0       	mov    $0xf01036c4,%eax
f0103128:	66 a3 d0 cf 17 f0    	mov    %ax,0xf017cfd0
f010312e:	66 c7 05 d2 cf 17 f0 	movw   $0x8,0xf017cfd2
f0103135:	08 00 
f0103137:	c6 05 d4 cf 17 f0 00 	movb   $0x0,0xf017cfd4
f010313e:	c6 05 d5 cf 17 f0 8f 	movb   $0x8f,0xf017cfd5
f0103145:	c1 e8 10             	shr    $0x10,%eax
f0103148:	66 a3 d6 cf 17 f0    	mov    %ax,0xf017cfd6
	    SETGATE(idt[7], 1, GD_KT, i7, 0);
f010314e:	b8 ca 36 10 f0       	mov    $0xf01036ca,%eax
f0103153:	66 a3 d8 cf 17 f0    	mov    %ax,0xf017cfd8
f0103159:	66 c7 05 da cf 17 f0 	movw   $0x8,0xf017cfda
f0103160:	08 00 
f0103162:	c6 05 dc cf 17 f0 00 	movb   $0x0,0xf017cfdc
f0103169:	c6 05 dd cf 17 f0 8f 	movb   $0x8f,0xf017cfdd
f0103170:	c1 e8 10             	shr    $0x10,%eax
f0103173:	66 a3 de cf 17 f0    	mov    %ax,0xf017cfde
	    SETGATE(idt[8], 1, GD_KT, i8, 0);
f0103179:	b8 d0 36 10 f0       	mov    $0xf01036d0,%eax
f010317e:	66 a3 e0 cf 17 f0    	mov    %ax,0xf017cfe0
f0103184:	66 c7 05 e2 cf 17 f0 	movw   $0x8,0xf017cfe2
f010318b:	08 00 
f010318d:	c6 05 e4 cf 17 f0 00 	movb   $0x0,0xf017cfe4
f0103194:	c6 05 e5 cf 17 f0 8f 	movb   $0x8f,0xf017cfe5
f010319b:	c1 e8 10             	shr    $0x10,%eax
f010319e:	66 a3 e6 cf 17 f0    	mov    %ax,0xf017cfe6
	    SETGATE(idt[9], 1, GD_KT, i9, 0);
f01031a4:	b8 d4 36 10 f0       	mov    $0xf01036d4,%eax
f01031a9:	66 a3 e8 cf 17 f0    	mov    %ax,0xf017cfe8
f01031af:	66 c7 05 ea cf 17 f0 	movw   $0x8,0xf017cfea
f01031b6:	08 00 
f01031b8:	c6 05 ec cf 17 f0 00 	movb   $0x0,0xf017cfec
f01031bf:	c6 05 ed cf 17 f0 8f 	movb   $0x8f,0xf017cfed
f01031c6:	c1 e8 10             	shr    $0x10,%eax
f01031c9:	66 a3 ee cf 17 f0    	mov    %ax,0xf017cfee
	    SETGATE(idt[10], 1, GD_KT,i10, 0);
f01031cf:	b8 da 36 10 f0       	mov    $0xf01036da,%eax
f01031d4:	66 a3 f0 cf 17 f0    	mov    %ax,0xf017cff0
f01031da:	66 c7 05 f2 cf 17 f0 	movw   $0x8,0xf017cff2
f01031e1:	08 00 
f01031e3:	c6 05 f4 cf 17 f0 00 	movb   $0x0,0xf017cff4
f01031ea:	c6 05 f5 cf 17 f0 8f 	movb   $0x8f,0xf017cff5
f01031f1:	c1 e8 10             	shr    $0x10,%eax
f01031f4:	66 a3 f6 cf 17 f0    	mov    %ax,0xf017cff6
	    SETGATE(idt[11], 1, GD_KT, i11, 0);
f01031fa:	b8 de 36 10 f0       	mov    $0xf01036de,%eax
f01031ff:	66 a3 f8 cf 17 f0    	mov    %ax,0xf017cff8
f0103205:	66 c7 05 fa cf 17 f0 	movw   $0x8,0xf017cffa
f010320c:	08 00 
f010320e:	c6 05 fc cf 17 f0 00 	movb   $0x0,0xf017cffc
f0103215:	c6 05 fd cf 17 f0 8f 	movb   $0x8f,0xf017cffd
f010321c:	c1 e8 10             	shr    $0x10,%eax
f010321f:	66 a3 fe cf 17 f0    	mov    %ax,0xf017cffe
	    SETGATE(idt[12], 1, GD_KT, i12, 0);
f0103225:	b8 e2 36 10 f0       	mov    $0xf01036e2,%eax
f010322a:	66 a3 00 d0 17 f0    	mov    %ax,0xf017d000
f0103230:	66 c7 05 02 d0 17 f0 	movw   $0x8,0xf017d002
f0103237:	08 00 
f0103239:	c6 05 04 d0 17 f0 00 	movb   $0x0,0xf017d004
f0103240:	c6 05 05 d0 17 f0 8f 	movb   $0x8f,0xf017d005
f0103247:	c1 e8 10             	shr    $0x10,%eax
f010324a:	66 a3 06 d0 17 f0    	mov    %ax,0xf017d006
	    SETGATE(idt[13], 1, GD_KT, i13, 0);
f0103250:	b8 e6 36 10 f0       	mov    $0xf01036e6,%eax
f0103255:	66 a3 08 d0 17 f0    	mov    %ax,0xf017d008
f010325b:	66 c7 05 0a d0 17 f0 	movw   $0x8,0xf017d00a
f0103262:	08 00 
f0103264:	c6 05 0c d0 17 f0 00 	movb   $0x0,0xf017d00c
f010326b:	c6 05 0d d0 17 f0 8f 	movb   $0x8f,0xf017d00d
f0103272:	c1 e8 10             	shr    $0x10,%eax
f0103275:	66 a3 0e d0 17 f0    	mov    %ax,0xf017d00e
	    SETGATE(idt[14], 1, GD_KT, i14, 0);
f010327b:	b8 ea 36 10 f0       	mov    $0xf01036ea,%eax
f0103280:	66 a3 10 d0 17 f0    	mov    %ax,0xf017d010
f0103286:	66 c7 05 12 d0 17 f0 	movw   $0x8,0xf017d012
f010328d:	08 00 
f010328f:	c6 05 14 d0 17 f0 00 	movb   $0x0,0xf017d014
f0103296:	c6 05 15 d0 17 f0 8f 	movb   $0x8f,0xf017d015
f010329d:	c1 e8 10             	shr    $0x10,%eax
f01032a0:	66 a3 16 d0 17 f0    	mov    %ax,0xf017d016
	    SETGATE(idt[16], 1, GD_KT, i16, 0);
f01032a6:	b8 ee 36 10 f0       	mov    $0xf01036ee,%eax
f01032ab:	66 a3 20 d0 17 f0    	mov    %ax,0xf017d020
f01032b1:	66 c7 05 22 d0 17 f0 	movw   $0x8,0xf017d022
f01032b8:	08 00 
f01032ba:	c6 05 24 d0 17 f0 00 	movb   $0x0,0xf017d024
f01032c1:	c6 05 25 d0 17 f0 8f 	movb   $0x8f,0xf017d025
f01032c8:	c1 e8 10             	shr    $0x10,%eax
f01032cb:	66 a3 26 d0 17 f0    	mov    %ax,0xf017d026
	    SETGATE(idt[48], 1, GD_KT, i48, 3);	
f01032d1:	b8 f4 36 10 f0       	mov    $0xf01036f4,%eax
f01032d6:	66 a3 20 d1 17 f0    	mov    %ax,0xf017d120
f01032dc:	66 c7 05 22 d1 17 f0 	movw   $0x8,0xf017d122
f01032e3:	08 00 
f01032e5:	c6 05 24 d1 17 f0 00 	movb   $0x0,0xf017d124
f01032ec:	c6 05 25 d1 17 f0 ef 	movb   $0xef,0xf017d125
f01032f3:	c1 e8 10             	shr    $0x10,%eax
f01032f6:	66 a3 26 d1 17 f0    	mov    %ax,0xf017d126


	// Per-CPU setup 
	trap_init_percpu();
f01032fc:	e8 eb fc ff ff       	call   f0102fec <trap_init_percpu>
}
f0103301:	5d                   	pop    %ebp
f0103302:	c3                   	ret    

f0103303 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103303:	55                   	push   %ebp
f0103304:	89 e5                	mov    %esp,%ebp
f0103306:	53                   	push   %ebx
f0103307:	83 ec 0c             	sub    $0xc,%esp
f010330a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010330d:	ff 33                	pushl  (%ebx)
f010330f:	68 f2 59 10 f0       	push   $0xf01059f2
f0103314:	e8 bf fc ff ff       	call   f0102fd8 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103319:	83 c4 08             	add    $0x8,%esp
f010331c:	ff 73 04             	pushl  0x4(%ebx)
f010331f:	68 01 5a 10 f0       	push   $0xf0105a01
f0103324:	e8 af fc ff ff       	call   f0102fd8 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103329:	83 c4 08             	add    $0x8,%esp
f010332c:	ff 73 08             	pushl  0x8(%ebx)
f010332f:	68 10 5a 10 f0       	push   $0xf0105a10
f0103334:	e8 9f fc ff ff       	call   f0102fd8 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103339:	83 c4 08             	add    $0x8,%esp
f010333c:	ff 73 0c             	pushl  0xc(%ebx)
f010333f:	68 1f 5a 10 f0       	push   $0xf0105a1f
f0103344:	e8 8f fc ff ff       	call   f0102fd8 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103349:	83 c4 08             	add    $0x8,%esp
f010334c:	ff 73 10             	pushl  0x10(%ebx)
f010334f:	68 2e 5a 10 f0       	push   $0xf0105a2e
f0103354:	e8 7f fc ff ff       	call   f0102fd8 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103359:	83 c4 08             	add    $0x8,%esp
f010335c:	ff 73 14             	pushl  0x14(%ebx)
f010335f:	68 3d 5a 10 f0       	push   $0xf0105a3d
f0103364:	e8 6f fc ff ff       	call   f0102fd8 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103369:	83 c4 08             	add    $0x8,%esp
f010336c:	ff 73 18             	pushl  0x18(%ebx)
f010336f:	68 4c 5a 10 f0       	push   $0xf0105a4c
f0103374:	e8 5f fc ff ff       	call   f0102fd8 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103379:	83 c4 08             	add    $0x8,%esp
f010337c:	ff 73 1c             	pushl  0x1c(%ebx)
f010337f:	68 5b 5a 10 f0       	push   $0xf0105a5b
f0103384:	e8 4f fc ff ff       	call   f0102fd8 <cprintf>
}
f0103389:	83 c4 10             	add    $0x10,%esp
f010338c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010338f:	c9                   	leave  
f0103390:	c3                   	ret    

f0103391 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103391:	55                   	push   %ebp
f0103392:	89 e5                	mov    %esp,%ebp
f0103394:	56                   	push   %esi
f0103395:	53                   	push   %ebx
f0103396:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103399:	83 ec 08             	sub    $0x8,%esp
f010339c:	53                   	push   %ebx
f010339d:	68 ac 5b 10 f0       	push   $0xf0105bac
f01033a2:	e8 31 fc ff ff       	call   f0102fd8 <cprintf>
	print_regs(&tf->tf_regs);
f01033a7:	89 1c 24             	mov    %ebx,(%esp)
f01033aa:	e8 54 ff ff ff       	call   f0103303 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01033af:	83 c4 08             	add    $0x8,%esp
f01033b2:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01033b6:	50                   	push   %eax
f01033b7:	68 ac 5a 10 f0       	push   $0xf0105aac
f01033bc:	e8 17 fc ff ff       	call   f0102fd8 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01033c1:	83 c4 08             	add    $0x8,%esp
f01033c4:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01033c8:	50                   	push   %eax
f01033c9:	68 bf 5a 10 f0       	push   $0xf0105abf
f01033ce:	e8 05 fc ff ff       	call   f0102fd8 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01033d3:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01033d6:	83 c4 10             	add    $0x10,%esp
f01033d9:	83 f8 13             	cmp    $0x13,%eax
f01033dc:	77 09                	ja     f01033e7 <print_trapframe+0x56>
		return excnames[trapno];
f01033de:	8b 14 85 80 5d 10 f0 	mov    -0xfefa280(,%eax,4),%edx
f01033e5:	eb 10                	jmp    f01033f7 <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
f01033e7:	83 f8 30             	cmp    $0x30,%eax
f01033ea:	b9 76 5a 10 f0       	mov    $0xf0105a76,%ecx
f01033ef:	ba 6a 5a 10 f0       	mov    $0xf0105a6a,%edx
f01033f4:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01033f7:	83 ec 04             	sub    $0x4,%esp
f01033fa:	52                   	push   %edx
f01033fb:	50                   	push   %eax
f01033fc:	68 d2 5a 10 f0       	push   $0xf0105ad2
f0103401:	e8 d2 fb ff ff       	call   f0102fd8 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103406:	83 c4 10             	add    $0x10,%esp
f0103409:	3b 1d a0 d7 17 f0    	cmp    0xf017d7a0,%ebx
f010340f:	75 1a                	jne    f010342b <print_trapframe+0x9a>
f0103411:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103415:	75 14                	jne    f010342b <print_trapframe+0x9a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103417:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010341a:	83 ec 08             	sub    $0x8,%esp
f010341d:	50                   	push   %eax
f010341e:	68 e4 5a 10 f0       	push   $0xf0105ae4
f0103423:	e8 b0 fb ff ff       	call   f0102fd8 <cprintf>
f0103428:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f010342b:	83 ec 08             	sub    $0x8,%esp
f010342e:	ff 73 2c             	pushl  0x2c(%ebx)
f0103431:	68 f3 5a 10 f0       	push   $0xf0105af3
f0103436:	e8 9d fb ff ff       	call   f0102fd8 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010343b:	83 c4 10             	add    $0x10,%esp
f010343e:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103442:	75 49                	jne    f010348d <print_trapframe+0xfc>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103444:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103447:	89 c2                	mov    %eax,%edx
f0103449:	83 e2 01             	and    $0x1,%edx
f010344c:	ba 90 5a 10 f0       	mov    $0xf0105a90,%edx
f0103451:	b9 85 5a 10 f0       	mov    $0xf0105a85,%ecx
f0103456:	0f 44 ca             	cmove  %edx,%ecx
f0103459:	89 c2                	mov    %eax,%edx
f010345b:	83 e2 02             	and    $0x2,%edx
f010345e:	ba a2 5a 10 f0       	mov    $0xf0105aa2,%edx
f0103463:	be 9c 5a 10 f0       	mov    $0xf0105a9c,%esi
f0103468:	0f 45 d6             	cmovne %esi,%edx
f010346b:	83 e0 04             	and    $0x4,%eax
f010346e:	be d7 5b 10 f0       	mov    $0xf0105bd7,%esi
f0103473:	b8 a7 5a 10 f0       	mov    $0xf0105aa7,%eax
f0103478:	0f 44 c6             	cmove  %esi,%eax
f010347b:	51                   	push   %ecx
f010347c:	52                   	push   %edx
f010347d:	50                   	push   %eax
f010347e:	68 01 5b 10 f0       	push   $0xf0105b01
f0103483:	e8 50 fb ff ff       	call   f0102fd8 <cprintf>
f0103488:	83 c4 10             	add    $0x10,%esp
f010348b:	eb 10                	jmp    f010349d <print_trapframe+0x10c>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010348d:	83 ec 0c             	sub    $0xc,%esp
f0103490:	68 8a 50 10 f0       	push   $0xf010508a
f0103495:	e8 3e fb ff ff       	call   f0102fd8 <cprintf>
f010349a:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010349d:	83 ec 08             	sub    $0x8,%esp
f01034a0:	ff 73 30             	pushl  0x30(%ebx)
f01034a3:	68 10 5b 10 f0       	push   $0xf0105b10
f01034a8:	e8 2b fb ff ff       	call   f0102fd8 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01034ad:	83 c4 08             	add    $0x8,%esp
f01034b0:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01034b4:	50                   	push   %eax
f01034b5:	68 1f 5b 10 f0       	push   $0xf0105b1f
f01034ba:	e8 19 fb ff ff       	call   f0102fd8 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01034bf:	83 c4 08             	add    $0x8,%esp
f01034c2:	ff 73 38             	pushl  0x38(%ebx)
f01034c5:	68 32 5b 10 f0       	push   $0xf0105b32
f01034ca:	e8 09 fb ff ff       	call   f0102fd8 <cprintf>
	if ((tf->tf_cs & 3) != 0) 
f01034cf:	83 c4 10             	add    $0x10,%esp
f01034d2:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01034d6:	74 25                	je     f01034fd <print_trapframe+0x16c>
	{
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01034d8:	83 ec 08             	sub    $0x8,%esp
f01034db:	ff 73 3c             	pushl  0x3c(%ebx)
f01034de:	68 41 5b 10 f0       	push   $0xf0105b41
f01034e3:	e8 f0 fa ff ff       	call   f0102fd8 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01034e8:	83 c4 08             	add    $0x8,%esp
f01034eb:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01034ef:	50                   	push   %eax
f01034f0:	68 50 5b 10 f0       	push   $0xf0105b50
f01034f5:	e8 de fa ff ff       	call   f0102fd8 <cprintf>
f01034fa:	83 c4 10             	add    $0x10,%esp
	}
}
f01034fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103500:	5b                   	pop    %ebx
f0103501:	5e                   	pop    %esi
f0103502:	5d                   	pop    %ebp
f0103503:	c3                   	ret    

f0103504 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103504:	55                   	push   %ebp
f0103505:	89 e5                	mov    %esp,%ebp
f0103507:	53                   	push   %ebx
f0103508:	83 ec 04             	sub    $0x4,%esp
f010350b:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010350e:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
if ((tf->tf_cs&3) == 0)
f0103511:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103515:	75 17                	jne    f010352e <page_fault_handler+0x2a>
panic("Page Fault occured(Kernel)");
f0103517:	83 ec 04             	sub    $0x4,%esp
f010351a:	68 63 5b 10 f0       	push   $0xf0105b63
f010351f:	68 05 01 00 00       	push   $0x105
f0103524:	68 7e 5b 10 f0       	push   $0xf0105b7e
f0103529:	e8 72 cb ff ff       	call   f01000a0 <_panic>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010352e:	ff 73 30             	pushl  0x30(%ebx)
f0103531:	50                   	push   %eax
f0103532:	a1 88 cf 17 f0       	mov    0xf017cf88,%eax
f0103537:	ff 70 48             	pushl  0x48(%eax)
f010353a:	68 24 5d 10 f0       	push   $0xf0105d24
f010353f:	e8 94 fa ff ff       	call   f0102fd8 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103544:	89 1c 24             	mov    %ebx,(%esp)
f0103547:	e8 45 fe ff ff       	call   f0103391 <print_trapframe>
	env_destroy(curenv);
f010354c:	83 c4 04             	add    $0x4,%esp
f010354f:	ff 35 88 cf 17 f0    	pushl  0xf017cf88
f0103555:	e8 7c f9 ff ff       	call   f0102ed6 <env_destroy>
}
f010355a:	83 c4 10             	add    $0x10,%esp
f010355d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103560:	c9                   	leave  
f0103561:	c3                   	ret    

f0103562 <trap>:
	
}

void
trap(struct Trapframe *tf)
{
f0103562:	55                   	push   %ebp
f0103563:	89 e5                	mov    %esp,%ebp
f0103565:	57                   	push   %edi
f0103566:	56                   	push   %esi
f0103567:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010356a:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f010356b:	9c                   	pushf  
f010356c:	58                   	pop    %eax
	///cprintf("Current ENV Status:%d\nRUNNING VALUE:%d\n",curenv->env_status,ENV_RUNNING);
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010356d:	f6 c4 02             	test   $0x2,%ah
f0103570:	74 19                	je     f010358b <trap+0x29>
f0103572:	68 8a 5b 10 f0       	push   $0xf0105b8a
f0103577:	68 96 4d 10 f0       	push   $0xf0104d96
f010357c:	68 db 00 00 00       	push   $0xdb
f0103581:	68 7e 5b 10 f0       	push   $0xf0105b7e
f0103586:	e8 15 cb ff ff       	call   f01000a0 <_panic>
	//print_trapframe(tf);
	
	cprintf("Incoming TRAP frame at %p\n", tf);
f010358b:	83 ec 08             	sub    $0x8,%esp
f010358e:	56                   	push   %esi
f010358f:	68 a3 5b 10 f0       	push   $0xf0105ba3
f0103594:	e8 3f fa ff ff       	call   f0102fd8 <cprintf>
	
	if ((tf->tf_cs & 3) == 3) {
f0103599:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010359d:	83 e0 03             	and    $0x3,%eax
f01035a0:	83 c4 10             	add    $0x10,%esp
f01035a3:	66 83 f8 03          	cmp    $0x3,%ax
f01035a7:	75 31                	jne    f01035da <trap+0x78>
		// Trapped from user mode.
		assert(curenv);
f01035a9:	a1 88 cf 17 f0       	mov    0xf017cf88,%eax
f01035ae:	85 c0                	test   %eax,%eax
f01035b0:	75 19                	jne    f01035cb <trap+0x69>
f01035b2:	68 be 5b 10 f0       	push   $0xf0105bbe
f01035b7:	68 96 4d 10 f0       	push   $0xf0104d96
f01035bc:	68 e2 00 00 00       	push   $0xe2
f01035c1:	68 7e 5b 10 f0       	push   $0xf0105b7e
f01035c6:	e8 d5 ca ff ff       	call   f01000a0 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01035cb:	b9 11 00 00 00       	mov    $0x11,%ecx
f01035d0:	89 c7                	mov    %eax,%edi
f01035d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01035d4:	8b 35 88 cf 17 f0    	mov    0xf017cf88,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01035da:	89 35 a0 d7 17 f0    	mov    %esi,0xf017d7a0
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	
	switch(tf->tf_trapno)
f01035e0:	8b 46 28             	mov    0x28(%esi),%eax
f01035e3:	83 f8 0e             	cmp    $0xe,%eax
f01035e6:	74 0c                	je     f01035f4 <trap+0x92>
f01035e8:	83 f8 30             	cmp    $0x30,%eax
f01035eb:	74 2b                	je     f0103618 <trap+0xb6>
f01035ed:	83 f8 03             	cmp    $0x3,%eax
f01035f0:	75 47                	jne    f0103639 <trap+0xd7>
f01035f2:	eb 0e                	jmp    f0103602 <trap+0xa0>
	{
		case T_PGFLT:
			page_fault_handler(tf);
f01035f4:	83 ec 0c             	sub    $0xc,%esp
f01035f7:	56                   	push   %esi
f01035f8:	e8 07 ff ff ff       	call   f0103504 <page_fault_handler>
f01035fd:	83 c4 10             	add    $0x10,%esp
f0103600:	eb 72                	jmp    f0103674 <trap+0x112>
			break;
		case T_BRKPT:
			print_trapframe(tf);
f0103602:	83 ec 0c             	sub    $0xc,%esp
f0103605:	56                   	push   %esi
f0103606:	e8 86 fd ff ff       	call   f0103391 <print_trapframe>
			monitor(tf);
f010360b:	89 34 24             	mov    %esi,(%esp)
f010360e:	e8 fc d1 ff ff       	call   f010080f <monitor>
f0103613:	83 c4 10             	add    $0x10,%esp
f0103616:	eb 5c                	jmp    f0103674 <trap+0x112>
			break;
		case T_SYSCALL:
			tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
f0103618:	83 ec 08             	sub    $0x8,%esp
f010361b:	ff 76 04             	pushl  0x4(%esi)
f010361e:	ff 36                	pushl  (%esi)
f0103620:	ff 76 10             	pushl  0x10(%esi)
f0103623:	ff 76 18             	pushl  0x18(%esi)
f0103626:	ff 76 14             	pushl  0x14(%esi)
f0103629:	ff 76 1c             	pushl  0x1c(%esi)
f010362c:	e8 da 00 00 00       	call   f010370b <syscall>
f0103631:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103634:	83 c4 20             	add    $0x20,%esp
f0103637:	eb 3b                	jmp    f0103674 <trap+0x112>
			break;
		default:
			print_trapframe(tf);
f0103639:	83 ec 0c             	sub    $0xc,%esp
f010363c:	56                   	push   %esi
f010363d:	e8 4f fd ff ff       	call   f0103391 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f0103642:	83 c4 10             	add    $0x10,%esp
f0103645:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010364a:	75 17                	jne    f0103663 <trap+0x101>
				panic("unhandled trap in kernel");
f010364c:	83 ec 04             	sub    $0x4,%esp
f010364f:	68 c5 5b 10 f0       	push   $0xf0105bc5
f0103654:	68 c5 00 00 00       	push   $0xc5
f0103659:	68 7e 5b 10 f0       	push   $0xf0105b7e
f010365e:	e8 3d ca ff ff       	call   f01000a0 <_panic>
			else 
			{
				env_destroy(curenv);
f0103663:	83 ec 0c             	sub    $0xc,%esp
f0103666:	ff 35 88 cf 17 f0    	pushl  0xf017cf88
f010366c:	e8 65 f8 ff ff       	call   f0102ed6 <env_destroy>
f0103671:	83 c4 10             	add    $0x10,%esp

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
	
	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103674:	a1 88 cf 17 f0       	mov    0xf017cf88,%eax
f0103679:	85 c0                	test   %eax,%eax
f010367b:	74 06                	je     f0103683 <trap+0x121>
f010367d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103681:	74 19                	je     f010369c <trap+0x13a>
f0103683:	68 48 5d 10 f0       	push   $0xf0105d48
f0103688:	68 96 4d 10 f0       	push   $0xf0104d96
f010368d:	68 f4 00 00 00       	push   $0xf4
f0103692:	68 7e 5b 10 f0       	push   $0xf0105b7e
f0103697:	e8 04 ca ff ff       	call   f01000a0 <_panic>
	env_run(curenv);
f010369c:	83 ec 0c             	sub    $0xc,%esp
f010369f:	50                   	push   %eax
f01036a0:	e8 81 f8 ff ff       	call   f0102f26 <env_run>
f01036a5:	90                   	nop

f01036a6 <i0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(i0, 0)
f01036a6:	6a 00                	push   $0x0
f01036a8:	6a 00                	push   $0x0
f01036aa:	eb 4e                	jmp    f01036fa <_alltraps>

f01036ac <i1>:
    TRAPHANDLER_NOEC(i1, 1)
f01036ac:	6a 00                	push   $0x0
f01036ae:	6a 01                	push   $0x1
f01036b0:	eb 48                	jmp    f01036fa <_alltraps>

f01036b2 <i3>:
    TRAPHANDLER_NOEC(i3, 3)
f01036b2:	6a 00                	push   $0x0
f01036b4:	6a 03                	push   $0x3
f01036b6:	eb 42                	jmp    f01036fa <_alltraps>

f01036b8 <i4>:
    TRAPHANDLER_NOEC(i4, 4)
f01036b8:	6a 00                	push   $0x0
f01036ba:	6a 04                	push   $0x4
f01036bc:	eb 3c                	jmp    f01036fa <_alltraps>

f01036be <i5>:
    TRAPHANDLER_NOEC(i5, 5)
f01036be:	6a 00                	push   $0x0
f01036c0:	6a 05                	push   $0x5
f01036c2:	eb 36                	jmp    f01036fa <_alltraps>

f01036c4 <i6>:
    TRAPHANDLER_NOEC(i6, 6)
f01036c4:	6a 00                	push   $0x0
f01036c6:	6a 06                	push   $0x6
f01036c8:	eb 30                	jmp    f01036fa <_alltraps>

f01036ca <i7>:
    TRAPHANDLER_NOEC(i7, 7)
f01036ca:	6a 00                	push   $0x0
f01036cc:	6a 07                	push   $0x7
f01036ce:	eb 2a                	jmp    f01036fa <_alltraps>

f01036d0 <i8>:
    TRAPHANDLER(i8, 8)          // Error code pushed
f01036d0:	6a 08                	push   $0x8
f01036d2:	eb 26                	jmp    f01036fa <_alltraps>

f01036d4 <i9>:
    TRAPHANDLER_NOEC(i9, 9)
f01036d4:	6a 00                	push   $0x0
f01036d6:	6a 09                	push   $0x9
f01036d8:	eb 20                	jmp    f01036fa <_alltraps>

f01036da <i10>:
    TRAPHANDLER(i10, 10)	// Error code pushed
f01036da:	6a 0a                	push   $0xa
f01036dc:	eb 1c                	jmp    f01036fa <_alltraps>

f01036de <i11>:
    TRAPHANDLER(i11, 11)	// Error code pushed
f01036de:	6a 0b                	push   $0xb
f01036e0:	eb 18                	jmp    f01036fa <_alltraps>

f01036e2 <i12>:
    TRAPHANDLER(i12, 12)	// Error code pushed
f01036e2:	6a 0c                	push   $0xc
f01036e4:	eb 14                	jmp    f01036fa <_alltraps>

f01036e6 <i13>:
    TRAPHANDLER(i13, 13)	// Error code pushed
f01036e6:	6a 0d                	push   $0xd
f01036e8:	eb 10                	jmp    f01036fa <_alltraps>

f01036ea <i14>:
    TRAPHANDLER(i14, 14)	// Error code pushed
f01036ea:	6a 0e                	push   $0xe
f01036ec:	eb 0c                	jmp    f01036fa <_alltraps>

f01036ee <i16>:
    TRAPHANDLER_NOEC(i16, 16)
f01036ee:	6a 00                	push   $0x0
f01036f0:	6a 10                	push   $0x10
f01036f2:	eb 06                	jmp    f01036fa <_alltraps>

f01036f4 <i48>:
    TRAPHANDLER_NOEC(i48, 48) //syscall
f01036f4:	6a 00                	push   $0x0
f01036f6:	6a 30                	push   $0x30
f01036f8:	eb 00                	jmp    f01036fa <_alltraps>

f01036fa <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
    pushl %ds //cpu registers 
f01036fa:	1e                   	push   %ds
    pushl %es
f01036fb:	06                   	push   %es
    pushal // General purpose registers
f01036fc:	60                   	pusha  
   movw $ GD_KD, %ax
f01036fd:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
f0103701:	8e d8                	mov    %eax,%ds
  movw %ax, %es
f0103703:	8e c0                	mov    %eax,%es
    pushl %esp // Argument for trap()
f0103705:	54                   	push   %esp
    call trap
f0103706:	e8 57 fe ff ff       	call   f0103562 <trap>

f010370b <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010370b:	55                   	push   %ebp
f010370c:	89 e5                	mov    %esp,%ebp
f010370e:	53                   	push   %ebx
f010370f:	83 ec 14             	sub    $0x14,%esp
f0103712:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t ret = 0;
	switch (syscallno) {
f0103715:	83 f8 01             	cmp    $0x1,%eax
f0103718:	74 5a                	je     f0103774 <syscall+0x69>
f010371a:	83 f8 01             	cmp    $0x1,%eax
f010371d:	72 0f                	jb     f010372e <syscall+0x23>
f010371f:	83 f8 02             	cmp    $0x2,%eax
f0103722:	74 5c                	je     f0103780 <syscall+0x75>
f0103724:	83 f8 03             	cmp    $0x3,%eax
f0103727:	74 72                	je     f010379b <syscall+0x90>
f0103729:	e9 d2 00 00 00       	jmp    f0103800 <syscall+0xf5>
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f010372e:	83 ec 04             	sub    $0x4,%esp
f0103731:	6a 01                	push   $0x1
f0103733:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103736:	50                   	push   %eax
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f0103737:	a1 88 cf 17 f0       	mov    0xf017cf88,%eax
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f010373c:	ff 70 48             	pushl  0x48(%eax)
f010373f:	e8 26 f2 ff ff       	call   f010296a <envid2env>
	user_mem_assert(e, s, len, PTE_U);
f0103744:	6a 04                	push   $0x4
f0103746:	ff 75 10             	pushl  0x10(%ebp)
f0103749:	ff 75 0c             	pushl  0xc(%ebp)
f010374c:	ff 75 f4             	pushl  -0xc(%ebp)
f010374f:	e8 61 f1 ff ff       	call   f01028b5 <user_mem_assert>
	

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103754:	83 c4 1c             	add    $0x1c,%esp
f0103757:	ff 75 0c             	pushl  0xc(%ebp)
f010375a:	ff 75 10             	pushl  0x10(%ebp)
f010375d:	68 d0 5d 10 f0       	push   $0xf0105dd0
f0103762:	e8 71 f8 ff ff       	call   f0102fd8 <cprintf>
f0103767:	83 c4 10             	add    $0x10,%esp
	// LAB 3: Your code here.
	int32_t ret = 0;
	switch (syscallno) {
		case SYS_cputs: 
			sys_cputs((char*)a1, a2);
			ret = 0;
f010376a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010376f:	e9 91 00 00 00       	jmp    f0103805 <syscall+0xfa>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103774:	e8 3c cd ff ff       	call   f01004b5 <cons_getc>
f0103779:	89 c3                	mov    %eax,%ebx
			sys_cputs((char*)a1, a2);
			ret = 0;
			break;
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
f010377b:	e9 85 00 00 00       	jmp    f0103805 <syscall+0xfa>
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f0103780:	a1 88 cf 17 f0       	mov    0xf017cf88,%eax
f0103785:	8b 58 48             	mov    0x48(%eax),%ebx
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
		case SYS_getenvid:
			ret = sys_getenvid();
			cprintf ("ret is %d\n",ret);
f0103788:	83 ec 08             	sub    $0x8,%esp
f010378b:	53                   	push   %ebx
f010378c:	68 d5 5d 10 f0       	push   $0xf0105dd5
f0103791:	e8 42 f8 ff ff       	call   f0102fd8 <cprintf>
			break;
f0103796:	83 c4 10             	add    $0x10,%esp
f0103799:	eb 6a                	jmp    f0103805 <syscall+0xfa>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010379b:	83 ec 04             	sub    $0x4,%esp
f010379e:	6a 01                	push   $0x1
f01037a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01037a3:	50                   	push   %eax
f01037a4:	ff 75 0c             	pushl  0xc(%ebp)
f01037a7:	e8 be f1 ff ff       	call   f010296a <envid2env>
f01037ac:	83 c4 10             	add    $0x10,%esp
f01037af:	85 c0                	test   %eax,%eax
f01037b1:	78 46                	js     f01037f9 <syscall+0xee>
		return r;
	if (e == curenv)
f01037b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01037b6:	8b 15 88 cf 17 f0    	mov    0xf017cf88,%edx
f01037bc:	39 d0                	cmp    %edx,%eax
f01037be:	75 15                	jne    f01037d5 <syscall+0xca>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01037c0:	83 ec 08             	sub    $0x8,%esp
f01037c3:	ff 70 48             	pushl  0x48(%eax)
f01037c6:	68 e0 5d 10 f0       	push   $0xf0105de0
f01037cb:	e8 08 f8 ff ff       	call   f0102fd8 <cprintf>
f01037d0:	83 c4 10             	add    $0x10,%esp
f01037d3:	eb 16                	jmp    f01037eb <syscall+0xe0>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01037d5:	83 ec 04             	sub    $0x4,%esp
f01037d8:	ff 70 48             	pushl  0x48(%eax)
f01037db:	ff 72 48             	pushl  0x48(%edx)
f01037de:	68 fb 5d 10 f0       	push   $0xf0105dfb
f01037e3:	e8 f0 f7 ff ff       	call   f0102fd8 <cprintf>
f01037e8:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01037eb:	83 ec 0c             	sub    $0xc,%esp
f01037ee:	ff 75 f4             	pushl  -0xc(%ebp)
f01037f1:	e8 e0 f6 ff ff       	call   f0102ed6 <env_destroy>
f01037f6:	83 c4 10             	add    $0x10,%esp
			ret = sys_getenvid();
			cprintf ("ret is %d\n",ret);
			break;
		case SYS_env_destroy:
			sys_env_destroy(a1);
			ret = 0;
f01037f9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01037fe:	eb 05                	jmp    f0103805 <syscall+0xfa>
			break;
		default:
			ret = -E_INVAL;
f0103800:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	}
	// cprintf("ret: %x\n", ret);
	return ret;
	panic("syscall not implemented");
}
f0103805:	89 d8                	mov    %ebx,%eax
f0103807:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010380a:	c9                   	leave  
f010380b:	c3                   	ret    

f010380c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010380c:	55                   	push   %ebp
f010380d:	89 e5                	mov    %esp,%ebp
f010380f:	57                   	push   %edi
f0103810:	56                   	push   %esi
f0103811:	53                   	push   %ebx
f0103812:	83 ec 14             	sub    $0x14,%esp
f0103815:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103818:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010381b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010381e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103821:	8b 1a                	mov    (%edx),%ebx
f0103823:	8b 01                	mov    (%ecx),%eax
f0103825:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103828:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010382f:	eb 7f                	jmp    f01038b0 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0103831:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103834:	01 d8                	add    %ebx,%eax
f0103836:	89 c6                	mov    %eax,%esi
f0103838:	c1 ee 1f             	shr    $0x1f,%esi
f010383b:	01 c6                	add    %eax,%esi
f010383d:	d1 fe                	sar    %esi
f010383f:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0103842:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103845:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0103848:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010384a:	eb 03                	jmp    f010384f <stab_binsearch+0x43>
			m--;
f010384c:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010384f:	39 c3                	cmp    %eax,%ebx
f0103851:	7f 0d                	jg     f0103860 <stab_binsearch+0x54>
f0103853:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103857:	83 ea 0c             	sub    $0xc,%edx
f010385a:	39 f9                	cmp    %edi,%ecx
f010385c:	75 ee                	jne    f010384c <stab_binsearch+0x40>
f010385e:	eb 05                	jmp    f0103865 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103860:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0103863:	eb 4b                	jmp    f01038b0 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103865:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103868:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010386b:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010386f:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103872:	76 11                	jbe    f0103885 <stab_binsearch+0x79>
			*region_left = m;
f0103874:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103877:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103879:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010387c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103883:	eb 2b                	jmp    f01038b0 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103885:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103888:	73 14                	jae    f010389e <stab_binsearch+0x92>
			*region_right = m - 1;
f010388a:	83 e8 01             	sub    $0x1,%eax
f010388d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103890:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103893:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103895:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010389c:	eb 12                	jmp    f01038b0 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010389e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01038a1:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01038a3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01038a7:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01038a9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01038b0:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01038b3:	0f 8e 78 ff ff ff    	jle    f0103831 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01038b9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01038bd:	75 0f                	jne    f01038ce <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01038bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01038c2:	8b 00                	mov    (%eax),%eax
f01038c4:	83 e8 01             	sub    $0x1,%eax
f01038c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01038ca:	89 06                	mov    %eax,(%esi)
f01038cc:	eb 2c                	jmp    f01038fa <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01038ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038d1:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01038d3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01038d6:	8b 0e                	mov    (%esi),%ecx
f01038d8:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01038db:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01038de:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01038e1:	eb 03                	jmp    f01038e6 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01038e3:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01038e6:	39 c8                	cmp    %ecx,%eax
f01038e8:	7e 0b                	jle    f01038f5 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01038ea:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01038ee:	83 ea 0c             	sub    $0xc,%edx
f01038f1:	39 df                	cmp    %ebx,%edi
f01038f3:	75 ee                	jne    f01038e3 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01038f5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01038f8:	89 06                	mov    %eax,(%esi)
	}
}
f01038fa:	83 c4 14             	add    $0x14,%esp
f01038fd:	5b                   	pop    %ebx
f01038fe:	5e                   	pop    %esi
f01038ff:	5f                   	pop    %edi
f0103900:	5d                   	pop    %ebp
f0103901:	c3                   	ret    

f0103902 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103902:	55                   	push   %ebp
f0103903:	89 e5                	mov    %esp,%ebp
f0103905:	57                   	push   %edi
f0103906:	56                   	push   %esi
f0103907:	53                   	push   %ebx
f0103908:	83 ec 3c             	sub    $0x3c,%esp
f010390b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010390e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103911:	c7 03 13 5e 10 f0    	movl   $0xf0105e13,(%ebx)
	info->eip_line = 0;
f0103917:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010391e:	c7 43 08 13 5e 10 f0 	movl   $0xf0105e13,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103925:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010392c:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010392f:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103936:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f010393c:	77 7e                	ja     f01039bc <debuginfo_eip+0xba>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f010393e:	6a 04                	push   $0x4
f0103940:	6a 10                	push   $0x10
f0103942:	68 00 00 20 00       	push   $0x200000
f0103947:	ff 35 88 cf 17 f0    	pushl  0xf017cf88
f010394d:	e8 e1 ee ff ff       	call   f0102833 <user_mem_check>
f0103952:	83 c4 10             	add    $0x10,%esp
f0103955:	85 c0                	test   %eax,%eax
f0103957:	0f 85 25 02 00 00    	jne    f0103b82 <debuginfo_eip+0x280>
		return -1;

		stabs = usd->stabs;
f010395d:	a1 00 00 20 00       	mov    0x200000,%eax
f0103962:	89 c1                	mov    %eax,%ecx
f0103964:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0103967:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f010396d:	a1 08 00 20 00       	mov    0x200008,%eax
f0103972:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0103975:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f010397b:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f010397e:	6a 04                	push   $0x4
f0103980:	6a 0c                	push   $0xc
f0103982:	51                   	push   %ecx
f0103983:	ff 35 88 cf 17 f0    	pushl  0xf017cf88
f0103989:	e8 a5 ee ff ff       	call   f0102833 <user_mem_check>
f010398e:	83 c4 10             	add    $0x10,%esp
f0103991:	85 c0                	test   %eax,%eax
f0103993:	0f 85 f0 01 00 00    	jne    f0103b89 <debuginfo_eip+0x287>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0103999:	6a 04                	push   $0x4
f010399b:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010399e:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f01039a1:	29 ca                	sub    %ecx,%edx
f01039a3:	52                   	push   %edx
f01039a4:	51                   	push   %ecx
f01039a5:	ff 35 88 cf 17 f0    	pushl  0xf017cf88
f01039ab:	e8 83 ee ff ff       	call   f0102833 <user_mem_check>
f01039b0:	83 c4 10             	add    $0x10,%esp
f01039b3:	85 c0                	test   %eax,%eax
f01039b5:	74 1f                	je     f01039d6 <debuginfo_eip+0xd4>
f01039b7:	e9 d4 01 00 00       	jmp    f0103b90 <debuginfo_eip+0x28e>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01039bc:	c7 45 bc 5c 03 11 f0 	movl   $0xf011035c,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01039c3:	c7 45 b8 f9 d8 10 f0 	movl   $0xf010d8f9,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01039ca:	be f8 d8 10 f0       	mov    $0xf010d8f8,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01039cf:	c7 45 c0 50 60 10 f0 	movl   $0xf0106050,-0x40(%ebp)


	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01039d6:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01039d9:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f01039dc:	0f 83 b5 01 00 00    	jae    f0103b97 <debuginfo_eip+0x295>
f01039e2:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01039e6:	0f 85 b2 01 00 00    	jne    f0103b9e <debuginfo_eip+0x29c>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01039ec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01039f3:	2b 75 c0             	sub    -0x40(%ebp),%esi
f01039f6:	c1 fe 02             	sar    $0x2,%esi
f01039f9:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f01039ff:	83 e8 01             	sub    $0x1,%eax
f0103a02:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103a05:	83 ec 08             	sub    $0x8,%esp
f0103a08:	57                   	push   %edi
f0103a09:	6a 64                	push   $0x64
f0103a0b:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0103a0e:	89 d1                	mov    %edx,%ecx
f0103a10:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103a13:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0103a16:	89 f0                	mov    %esi,%eax
f0103a18:	e8 ef fd ff ff       	call   f010380c <stab_binsearch>
	if (lfile == 0)
f0103a1d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103a20:	83 c4 10             	add    $0x10,%esp
f0103a23:	85 c0                	test   %eax,%eax
f0103a25:	0f 84 7a 01 00 00    	je     f0103ba5 <debuginfo_eip+0x2a3>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103a2b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103a2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a31:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103a34:	83 ec 08             	sub    $0x8,%esp
f0103a37:	57                   	push   %edi
f0103a38:	6a 24                	push   $0x24
f0103a3a:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0103a3d:	89 d1                	mov    %edx,%ecx
f0103a3f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103a42:	89 f0                	mov    %esi,%eax
f0103a44:	e8 c3 fd ff ff       	call   f010380c <stab_binsearch>

	if (lfun <= rfun) {
f0103a49:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103a4c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103a4f:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0103a52:	83 c4 10             	add    $0x10,%esp
f0103a55:	39 d0                	cmp    %edx,%eax
f0103a57:	7f 52                	jg     f0103aab <debuginfo_eip+0x1a9>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103a59:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103a5c:	8d 0c 96             	lea    (%esi,%edx,4),%ecx
f0103a5f:	8b 11                	mov    (%ecx),%edx
f0103a61:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0103a64:	2b 75 b8             	sub    -0x48(%ebp),%esi
f0103a67:	39 f2                	cmp    %esi,%edx
f0103a69:	73 06                	jae    f0103a71 <debuginfo_eip+0x16f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103a6b:	03 55 b8             	add    -0x48(%ebp),%edx
f0103a6e:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103a71:	8b 51 08             	mov    0x8(%ecx),%edx
f0103a74:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
		// Search within the function definition for the line number.
		lline = lfun;
f0103a77:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103a7a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103a7d:	89 45 d0             	mov    %eax,-0x30(%ebp)
stab_binsearch(stabs, &lline, &rline, N_SLINE, addr); //----------------------------------------> New Insertion
f0103a80:	83 ec 08             	sub    $0x8,%esp
f0103a83:	29 d7                	sub    %edx,%edi
f0103a85:	57                   	push   %edi
f0103a86:	6a 44                	push   $0x44
f0103a88:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103a8b:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103a8e:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103a91:	89 f8                	mov    %edi,%eax
f0103a93:	e8 74 fd ff ff       	call   f010380c <stab_binsearch>
info->eip_line = stabs[lline].n_desc;
f0103a98:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a9b:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103a9e:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f0103aa3:	89 43 04             	mov    %eax,0x4(%ebx)
f0103aa6:	83 c4 10             	add    $0x10,%esp
f0103aa9:	eb 0f                	jmp    f0103aba <debuginfo_eip+0x1b8>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103aab:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0103aae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103ab1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103ab4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ab7:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103aba:	83 ec 08             	sub    $0x8,%esp
f0103abd:	6a 3a                	push   $0x3a
f0103abf:	ff 73 08             	pushl  0x8(%ebx)
f0103ac2:	e8 a7 08 00 00       	call   f010436e <strfind>
f0103ac7:	2b 43 08             	sub    0x8(%ebx),%eax
f0103aca:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103acd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103ad0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103ad3:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103ad6:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0103ad9:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0103adc:	83 c4 10             	add    $0x10,%esp
f0103adf:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0103ae3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103ae6:	eb 0a                	jmp    f0103af2 <debuginfo_eip+0x1f0>
f0103ae8:	83 e8 01             	sub    $0x1,%eax
f0103aeb:	83 ea 0c             	sub    $0xc,%edx
f0103aee:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0103af2:	39 c7                	cmp    %eax,%edi
f0103af4:	7e 05                	jle    f0103afb <debuginfo_eip+0x1f9>
f0103af6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103af9:	eb 47                	jmp    f0103b42 <debuginfo_eip+0x240>
	       && stabs[lline].n_type != N_SOL
f0103afb:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103aff:	80 f9 84             	cmp    $0x84,%cl
f0103b02:	75 0e                	jne    f0103b12 <debuginfo_eip+0x210>
f0103b04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103b07:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103b0b:	74 1c                	je     f0103b29 <debuginfo_eip+0x227>
f0103b0d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103b10:	eb 17                	jmp    f0103b29 <debuginfo_eip+0x227>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103b12:	80 f9 64             	cmp    $0x64,%cl
f0103b15:	75 d1                	jne    f0103ae8 <debuginfo_eip+0x1e6>
f0103b17:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0103b1b:	74 cb                	je     f0103ae8 <debuginfo_eip+0x1e6>
f0103b1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103b20:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103b24:	74 03                	je     f0103b29 <debuginfo_eip+0x227>
f0103b26:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103b29:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103b2c:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103b2f:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103b32:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103b35:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0103b38:	29 f8                	sub    %edi,%eax
f0103b3a:	39 c2                	cmp    %eax,%edx
f0103b3c:	73 04                	jae    f0103b42 <debuginfo_eip+0x240>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103b3e:	01 fa                	add    %edi,%edx
f0103b40:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103b42:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b45:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103b48:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103b4d:	39 f2                	cmp    %esi,%edx
f0103b4f:	7d 60                	jge    f0103bb1 <debuginfo_eip+0x2af>
		for (lline = lfun + 1;
f0103b51:	83 c2 01             	add    $0x1,%edx
f0103b54:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103b57:	89 d0                	mov    %edx,%eax
f0103b59:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103b5c:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103b5f:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103b62:	eb 04                	jmp    f0103b68 <debuginfo_eip+0x266>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103b64:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103b68:	39 c6                	cmp    %eax,%esi
f0103b6a:	7e 40                	jle    f0103bac <debuginfo_eip+0x2aa>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103b6c:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103b70:	83 c0 01             	add    $0x1,%eax
f0103b73:	83 c2 0c             	add    $0xc,%edx
f0103b76:	80 f9 a0             	cmp    $0xa0,%cl
f0103b79:	74 e9                	je     f0103b64 <debuginfo_eip+0x262>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103b7b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b80:	eb 2f                	jmp    f0103bb1 <debuginfo_eip+0x2af>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
		return -1;
f0103b82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103b87:	eb 28                	jmp    f0103bb1 <debuginfo_eip+0x2af>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;
f0103b89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103b8e:	eb 21                	jmp    f0103bb1 <debuginfo_eip+0x2af>

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
		return -1;
f0103b90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103b95:	eb 1a                	jmp    f0103bb1 <debuginfo_eip+0x2af>

	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103b97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103b9c:	eb 13                	jmp    f0103bb1 <debuginfo_eip+0x2af>
f0103b9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103ba3:	eb 0c                	jmp    f0103bb1 <debuginfo_eip+0x2af>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103ba5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103baa:	eb 05                	jmp    f0103bb1 <debuginfo_eip+0x2af>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103bac:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103bb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103bb4:	5b                   	pop    %ebx
f0103bb5:	5e                   	pop    %esi
f0103bb6:	5f                   	pop    %edi
f0103bb7:	5d                   	pop    %ebp
f0103bb8:	c3                   	ret    

f0103bb9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103bb9:	55                   	push   %ebp
f0103bba:	89 e5                	mov    %esp,%ebp
f0103bbc:	57                   	push   %edi
f0103bbd:	56                   	push   %esi
f0103bbe:	53                   	push   %ebx
f0103bbf:	83 ec 1c             	sub    $0x1c,%esp
f0103bc2:	89 c7                	mov    %eax,%edi
f0103bc4:	89 d6                	mov    %edx,%esi
f0103bc6:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bc9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103bcc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103bcf:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103bd2:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103bd5:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103bda:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103bdd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103be0:	39 d3                	cmp    %edx,%ebx
f0103be2:	72 05                	jb     f0103be9 <printnum+0x30>
f0103be4:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103be7:	77 45                	ja     f0103c2e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103be9:	83 ec 0c             	sub    $0xc,%esp
f0103bec:	ff 75 18             	pushl  0x18(%ebp)
f0103bef:	8b 45 14             	mov    0x14(%ebp),%eax
f0103bf2:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103bf5:	53                   	push   %ebx
f0103bf6:	ff 75 10             	pushl  0x10(%ebp)
f0103bf9:	83 ec 08             	sub    $0x8,%esp
f0103bfc:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103bff:	ff 75 e0             	pushl  -0x20(%ebp)
f0103c02:	ff 75 dc             	pushl  -0x24(%ebp)
f0103c05:	ff 75 d8             	pushl  -0x28(%ebp)
f0103c08:	e8 83 09 00 00       	call   f0104590 <__udivdi3>
f0103c0d:	83 c4 18             	add    $0x18,%esp
f0103c10:	52                   	push   %edx
f0103c11:	50                   	push   %eax
f0103c12:	89 f2                	mov    %esi,%edx
f0103c14:	89 f8                	mov    %edi,%eax
f0103c16:	e8 9e ff ff ff       	call   f0103bb9 <printnum>
f0103c1b:	83 c4 20             	add    $0x20,%esp
f0103c1e:	eb 18                	jmp    f0103c38 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103c20:	83 ec 08             	sub    $0x8,%esp
f0103c23:	56                   	push   %esi
f0103c24:	ff 75 18             	pushl  0x18(%ebp)
f0103c27:	ff d7                	call   *%edi
f0103c29:	83 c4 10             	add    $0x10,%esp
f0103c2c:	eb 03                	jmp    f0103c31 <printnum+0x78>
f0103c2e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103c31:	83 eb 01             	sub    $0x1,%ebx
f0103c34:	85 db                	test   %ebx,%ebx
f0103c36:	7f e8                	jg     f0103c20 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103c38:	83 ec 08             	sub    $0x8,%esp
f0103c3b:	56                   	push   %esi
f0103c3c:	83 ec 04             	sub    $0x4,%esp
f0103c3f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103c42:	ff 75 e0             	pushl  -0x20(%ebp)
f0103c45:	ff 75 dc             	pushl  -0x24(%ebp)
f0103c48:	ff 75 d8             	pushl  -0x28(%ebp)
f0103c4b:	e8 70 0a 00 00       	call   f01046c0 <__umoddi3>
f0103c50:	83 c4 14             	add    $0x14,%esp
f0103c53:	0f be 80 1d 5e 10 f0 	movsbl -0xfefa1e3(%eax),%eax
f0103c5a:	50                   	push   %eax
f0103c5b:	ff d7                	call   *%edi
}
f0103c5d:	83 c4 10             	add    $0x10,%esp
f0103c60:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103c63:	5b                   	pop    %ebx
f0103c64:	5e                   	pop    %esi
f0103c65:	5f                   	pop    %edi
f0103c66:	5d                   	pop    %ebp
f0103c67:	c3                   	ret    

f0103c68 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103c68:	55                   	push   %ebp
f0103c69:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103c6b:	83 fa 01             	cmp    $0x1,%edx
f0103c6e:	7e 0e                	jle    f0103c7e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103c70:	8b 10                	mov    (%eax),%edx
f0103c72:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103c75:	89 08                	mov    %ecx,(%eax)
f0103c77:	8b 02                	mov    (%edx),%eax
f0103c79:	8b 52 04             	mov    0x4(%edx),%edx
f0103c7c:	eb 22                	jmp    f0103ca0 <getuint+0x38>
	else if (lflag)
f0103c7e:	85 d2                	test   %edx,%edx
f0103c80:	74 10                	je     f0103c92 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103c82:	8b 10                	mov    (%eax),%edx
f0103c84:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103c87:	89 08                	mov    %ecx,(%eax)
f0103c89:	8b 02                	mov    (%edx),%eax
f0103c8b:	ba 00 00 00 00       	mov    $0x0,%edx
f0103c90:	eb 0e                	jmp    f0103ca0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103c92:	8b 10                	mov    (%eax),%edx
f0103c94:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103c97:	89 08                	mov    %ecx,(%eax)
f0103c99:	8b 02                	mov    (%edx),%eax
f0103c9b:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103ca0:	5d                   	pop    %ebp
f0103ca1:	c3                   	ret    

f0103ca2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103ca2:	55                   	push   %ebp
f0103ca3:	89 e5                	mov    %esp,%ebp
f0103ca5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103ca8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103cac:	8b 10                	mov    (%eax),%edx
f0103cae:	3b 50 04             	cmp    0x4(%eax),%edx
f0103cb1:	73 0a                	jae    f0103cbd <sprintputch+0x1b>
		*b->buf++ = ch;
f0103cb3:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103cb6:	89 08                	mov    %ecx,(%eax)
f0103cb8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cbb:	88 02                	mov    %al,(%edx)
}
f0103cbd:	5d                   	pop    %ebp
f0103cbe:	c3                   	ret    

f0103cbf <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103cbf:	55                   	push   %ebp
f0103cc0:	89 e5                	mov    %esp,%ebp
f0103cc2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0103cc5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103cc8:	50                   	push   %eax
f0103cc9:	ff 75 10             	pushl  0x10(%ebp)
f0103ccc:	ff 75 0c             	pushl  0xc(%ebp)
f0103ccf:	ff 75 08             	pushl  0x8(%ebp)
f0103cd2:	e8 05 00 00 00       	call   f0103cdc <vprintfmt>
	va_end(ap);
}
f0103cd7:	83 c4 10             	add    $0x10,%esp
f0103cda:	c9                   	leave  
f0103cdb:	c3                   	ret    

f0103cdc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103cdc:	55                   	push   %ebp
f0103cdd:	89 e5                	mov    %esp,%ebp
f0103cdf:	57                   	push   %edi
f0103ce0:	56                   	push   %esi
f0103ce1:	53                   	push   %ebx
f0103ce2:	83 ec 2c             	sub    $0x2c,%esp
f0103ce5:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ce8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103ceb:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103cee:	eb 12                	jmp    f0103d02 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103cf0:	85 c0                	test   %eax,%eax
f0103cf2:	0f 84 cb 03 00 00    	je     f01040c3 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
f0103cf8:	83 ec 08             	sub    $0x8,%esp
f0103cfb:	53                   	push   %ebx
f0103cfc:	50                   	push   %eax
f0103cfd:	ff d6                	call   *%esi
f0103cff:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103d02:	83 c7 01             	add    $0x1,%edi
f0103d05:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103d09:	83 f8 25             	cmp    $0x25,%eax
f0103d0c:	75 e2                	jne    f0103cf0 <vprintfmt+0x14>
f0103d0e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0103d12:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0103d19:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0103d20:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0103d27:	ba 00 00 00 00       	mov    $0x0,%edx
f0103d2c:	eb 07                	jmp    f0103d35 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d2e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103d31:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d35:	8d 47 01             	lea    0x1(%edi),%eax
f0103d38:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103d3b:	0f b6 07             	movzbl (%edi),%eax
f0103d3e:	0f b6 c8             	movzbl %al,%ecx
f0103d41:	83 e8 23             	sub    $0x23,%eax
f0103d44:	3c 55                	cmp    $0x55,%al
f0103d46:	0f 87 5c 03 00 00    	ja     f01040a8 <vprintfmt+0x3cc>
f0103d4c:	0f b6 c0             	movzbl %al,%eax
f0103d4f:	ff 24 85 c0 5e 10 f0 	jmp    *-0xfefa140(,%eax,4)
f0103d56:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103d59:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103d5d:	eb d6                	jmp    f0103d35 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d5f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103d62:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d67:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103d6a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103d6d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0103d71:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0103d74:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0103d77:	83 fa 09             	cmp    $0x9,%edx
f0103d7a:	77 39                	ja     f0103db5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103d7c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103d7f:	eb e9                	jmp    f0103d6a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103d81:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d84:	8d 48 04             	lea    0x4(%eax),%ecx
f0103d87:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0103d8a:	8b 00                	mov    (%eax),%eax
f0103d8c:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d8f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103d92:	eb 27                	jmp    f0103dbb <vprintfmt+0xdf>
f0103d94:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103d97:	85 c0                	test   %eax,%eax
f0103d99:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103d9e:	0f 49 c8             	cmovns %eax,%ecx
f0103da1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103da4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103da7:	eb 8c                	jmp    f0103d35 <vprintfmt+0x59>
f0103da9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103dac:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103db3:	eb 80                	jmp    f0103d35 <vprintfmt+0x59>
f0103db5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103db8:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
f0103dbb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103dbf:	0f 89 70 ff ff ff    	jns    f0103d35 <vprintfmt+0x59>
				width = precision, precision = -1;
f0103dc5:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103dc8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103dcb:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0103dd2:	e9 5e ff ff ff       	jmp    f0103d35 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103dd7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103dda:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103ddd:	e9 53 ff ff ff       	jmp    f0103d35 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103de2:	8b 45 14             	mov    0x14(%ebp),%eax
f0103de5:	8d 50 04             	lea    0x4(%eax),%edx
f0103de8:	89 55 14             	mov    %edx,0x14(%ebp)
f0103deb:	83 ec 08             	sub    $0x8,%esp
f0103dee:	53                   	push   %ebx
f0103def:	ff 30                	pushl  (%eax)
f0103df1:	ff d6                	call   *%esi
			break;
f0103df3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103df6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103df9:	e9 04 ff ff ff       	jmp    f0103d02 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103dfe:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e01:	8d 50 04             	lea    0x4(%eax),%edx
f0103e04:	89 55 14             	mov    %edx,0x14(%ebp)
f0103e07:	8b 00                	mov    (%eax),%eax
f0103e09:	99                   	cltd   
f0103e0a:	31 d0                	xor    %edx,%eax
f0103e0c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103e0e:	83 f8 07             	cmp    $0x7,%eax
f0103e11:	7f 0b                	jg     f0103e1e <vprintfmt+0x142>
f0103e13:	8b 14 85 20 60 10 f0 	mov    -0xfef9fe0(,%eax,4),%edx
f0103e1a:	85 d2                	test   %edx,%edx
f0103e1c:	75 18                	jne    f0103e36 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0103e1e:	50                   	push   %eax
f0103e1f:	68 35 5e 10 f0       	push   $0xf0105e35
f0103e24:	53                   	push   %ebx
f0103e25:	56                   	push   %esi
f0103e26:	e8 94 fe ff ff       	call   f0103cbf <printfmt>
f0103e2b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e2e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103e31:	e9 cc fe ff ff       	jmp    f0103d02 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0103e36:	52                   	push   %edx
f0103e37:	68 a8 4d 10 f0       	push   $0xf0104da8
f0103e3c:	53                   	push   %ebx
f0103e3d:	56                   	push   %esi
f0103e3e:	e8 7c fe ff ff       	call   f0103cbf <printfmt>
f0103e43:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e46:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103e49:	e9 b4 fe ff ff       	jmp    f0103d02 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103e4e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e51:	8d 50 04             	lea    0x4(%eax),%edx
f0103e54:	89 55 14             	mov    %edx,0x14(%ebp)
f0103e57:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103e59:	85 ff                	test   %edi,%edi
f0103e5b:	b8 2e 5e 10 f0       	mov    $0xf0105e2e,%eax
f0103e60:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103e63:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103e67:	0f 8e 94 00 00 00    	jle    f0103f01 <vprintfmt+0x225>
f0103e6d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103e71:	0f 84 98 00 00 00    	je     f0103f0f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103e77:	83 ec 08             	sub    $0x8,%esp
f0103e7a:	ff 75 c8             	pushl  -0x38(%ebp)
f0103e7d:	57                   	push   %edi
f0103e7e:	e8 a1 03 00 00       	call   f0104224 <strnlen>
f0103e83:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103e86:	29 c1                	sub    %eax,%ecx
f0103e88:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0103e8b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103e8e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103e92:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103e95:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103e98:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103e9a:	eb 0f                	jmp    f0103eab <vprintfmt+0x1cf>
					putch(padc, putdat);
f0103e9c:	83 ec 08             	sub    $0x8,%esp
f0103e9f:	53                   	push   %ebx
f0103ea0:	ff 75 e0             	pushl  -0x20(%ebp)
f0103ea3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103ea5:	83 ef 01             	sub    $0x1,%edi
f0103ea8:	83 c4 10             	add    $0x10,%esp
f0103eab:	85 ff                	test   %edi,%edi
f0103ead:	7f ed                	jg     f0103e9c <vprintfmt+0x1c0>
f0103eaf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103eb2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103eb5:	85 c9                	test   %ecx,%ecx
f0103eb7:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ebc:	0f 49 c1             	cmovns %ecx,%eax
f0103ebf:	29 c1                	sub    %eax,%ecx
f0103ec1:	89 75 08             	mov    %esi,0x8(%ebp)
f0103ec4:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0103ec7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103eca:	89 cb                	mov    %ecx,%ebx
f0103ecc:	eb 4d                	jmp    f0103f1b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103ece:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103ed2:	74 1b                	je     f0103eef <vprintfmt+0x213>
f0103ed4:	0f be c0             	movsbl %al,%eax
f0103ed7:	83 e8 20             	sub    $0x20,%eax
f0103eda:	83 f8 5e             	cmp    $0x5e,%eax
f0103edd:	76 10                	jbe    f0103eef <vprintfmt+0x213>
					putch('?', putdat);
f0103edf:	83 ec 08             	sub    $0x8,%esp
f0103ee2:	ff 75 0c             	pushl  0xc(%ebp)
f0103ee5:	6a 3f                	push   $0x3f
f0103ee7:	ff 55 08             	call   *0x8(%ebp)
f0103eea:	83 c4 10             	add    $0x10,%esp
f0103eed:	eb 0d                	jmp    f0103efc <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0103eef:	83 ec 08             	sub    $0x8,%esp
f0103ef2:	ff 75 0c             	pushl  0xc(%ebp)
f0103ef5:	52                   	push   %edx
f0103ef6:	ff 55 08             	call   *0x8(%ebp)
f0103ef9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103efc:	83 eb 01             	sub    $0x1,%ebx
f0103eff:	eb 1a                	jmp    f0103f1b <vprintfmt+0x23f>
f0103f01:	89 75 08             	mov    %esi,0x8(%ebp)
f0103f04:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0103f07:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103f0a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103f0d:	eb 0c                	jmp    f0103f1b <vprintfmt+0x23f>
f0103f0f:	89 75 08             	mov    %esi,0x8(%ebp)
f0103f12:	8b 75 c8             	mov    -0x38(%ebp),%esi
f0103f15:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103f18:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103f1b:	83 c7 01             	add    $0x1,%edi
f0103f1e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103f22:	0f be d0             	movsbl %al,%edx
f0103f25:	85 d2                	test   %edx,%edx
f0103f27:	74 23                	je     f0103f4c <vprintfmt+0x270>
f0103f29:	85 f6                	test   %esi,%esi
f0103f2b:	78 a1                	js     f0103ece <vprintfmt+0x1f2>
f0103f2d:	83 ee 01             	sub    $0x1,%esi
f0103f30:	79 9c                	jns    f0103ece <vprintfmt+0x1f2>
f0103f32:	89 df                	mov    %ebx,%edi
f0103f34:	8b 75 08             	mov    0x8(%ebp),%esi
f0103f37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103f3a:	eb 18                	jmp    f0103f54 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103f3c:	83 ec 08             	sub    $0x8,%esp
f0103f3f:	53                   	push   %ebx
f0103f40:	6a 20                	push   $0x20
f0103f42:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103f44:	83 ef 01             	sub    $0x1,%edi
f0103f47:	83 c4 10             	add    $0x10,%esp
f0103f4a:	eb 08                	jmp    f0103f54 <vprintfmt+0x278>
f0103f4c:	89 df                	mov    %ebx,%edi
f0103f4e:	8b 75 08             	mov    0x8(%ebp),%esi
f0103f51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103f54:	85 ff                	test   %edi,%edi
f0103f56:	7f e4                	jg     f0103f3c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103f58:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103f5b:	e9 a2 fd ff ff       	jmp    f0103d02 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103f60:	83 fa 01             	cmp    $0x1,%edx
f0103f63:	7e 16                	jle    f0103f7b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0103f65:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f68:	8d 50 08             	lea    0x8(%eax),%edx
f0103f6b:	89 55 14             	mov    %edx,0x14(%ebp)
f0103f6e:	8b 50 04             	mov    0x4(%eax),%edx
f0103f71:	8b 00                	mov    (%eax),%eax
f0103f73:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0103f76:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0103f79:	eb 32                	jmp    f0103fad <vprintfmt+0x2d1>
	else if (lflag)
f0103f7b:	85 d2                	test   %edx,%edx
f0103f7d:	74 18                	je     f0103f97 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0103f7f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f82:	8d 50 04             	lea    0x4(%eax),%edx
f0103f85:	89 55 14             	mov    %edx,0x14(%ebp)
f0103f88:	8b 00                	mov    (%eax),%eax
f0103f8a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0103f8d:	89 c1                	mov    %eax,%ecx
f0103f8f:	c1 f9 1f             	sar    $0x1f,%ecx
f0103f92:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0103f95:	eb 16                	jmp    f0103fad <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0103f97:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f9a:	8d 50 04             	lea    0x4(%eax),%edx
f0103f9d:	89 55 14             	mov    %edx,0x14(%ebp)
f0103fa0:	8b 00                	mov    (%eax),%eax
f0103fa2:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0103fa5:	89 c1                	mov    %eax,%ecx
f0103fa7:	c1 f9 1f             	sar    $0x1f,%ecx
f0103faa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103fad:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103fb0:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0103fb3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103fb6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103fb9:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103fbe:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0103fc2:	0f 89 a8 00 00 00    	jns    f0104070 <vprintfmt+0x394>
				putch('-', putdat);
f0103fc8:	83 ec 08             	sub    $0x8,%esp
f0103fcb:	53                   	push   %ebx
f0103fcc:	6a 2d                	push   $0x2d
f0103fce:	ff d6                	call   *%esi
				num = -(long long) num;
f0103fd0:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0103fd3:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0103fd6:	f7 d8                	neg    %eax
f0103fd8:	83 d2 00             	adc    $0x0,%edx
f0103fdb:	f7 da                	neg    %edx
f0103fdd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103fe0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103fe3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0103fe6:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103feb:	e9 80 00 00 00       	jmp    f0104070 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103ff0:	8d 45 14             	lea    0x14(%ebp),%eax
f0103ff3:	e8 70 fc ff ff       	call   f0103c68 <getuint>
f0103ff8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103ffb:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
f0103ffe:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0104003:	eb 6b                	jmp    f0104070 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0104005:	8d 45 14             	lea    0x14(%ebp),%eax
f0104008:	e8 5b fc ff ff       	call   f0103c68 <getuint>
f010400d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104010:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
f0104013:	6a 04                	push   $0x4
f0104015:	6a 03                	push   $0x3
f0104017:	6a 01                	push   $0x1
f0104019:	68 3e 5e 10 f0       	push   $0xf0105e3e
f010401e:	e8 b5 ef ff ff       	call   f0102fd8 <cprintf>
			goto number;
f0104023:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
f0104026:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
f010402b:	eb 43                	jmp    f0104070 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
f010402d:	83 ec 08             	sub    $0x8,%esp
f0104030:	53                   	push   %ebx
f0104031:	6a 30                	push   $0x30
f0104033:	ff d6                	call   *%esi
			putch('x', putdat);
f0104035:	83 c4 08             	add    $0x8,%esp
f0104038:	53                   	push   %ebx
f0104039:	6a 78                	push   $0x78
f010403b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010403d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104040:	8d 50 04             	lea    0x4(%eax),%edx
f0104043:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104046:	8b 00                	mov    (%eax),%eax
f0104048:	ba 00 00 00 00       	mov    $0x0,%edx
f010404d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104050:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104053:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0104056:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010405b:	eb 13                	jmp    f0104070 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010405d:	8d 45 14             	lea    0x14(%ebp),%eax
f0104060:	e8 03 fc ff ff       	call   f0103c68 <getuint>
f0104065:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104068:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
f010406b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104070:	83 ec 0c             	sub    $0xc,%esp
f0104073:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
f0104077:	52                   	push   %edx
f0104078:	ff 75 e0             	pushl  -0x20(%ebp)
f010407b:	50                   	push   %eax
f010407c:	ff 75 dc             	pushl  -0x24(%ebp)
f010407f:	ff 75 d8             	pushl  -0x28(%ebp)
f0104082:	89 da                	mov    %ebx,%edx
f0104084:	89 f0                	mov    %esi,%eax
f0104086:	e8 2e fb ff ff       	call   f0103bb9 <printnum>

			break;
f010408b:	83 c4 20             	add    $0x20,%esp
f010408e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104091:	e9 6c fc ff ff       	jmp    f0103d02 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104096:	83 ec 08             	sub    $0x8,%esp
f0104099:	53                   	push   %ebx
f010409a:	51                   	push   %ecx
f010409b:	ff d6                	call   *%esi
			break;
f010409d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01040a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01040a3:	e9 5a fc ff ff       	jmp    f0103d02 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01040a8:	83 ec 08             	sub    $0x8,%esp
f01040ab:	53                   	push   %ebx
f01040ac:	6a 25                	push   $0x25
f01040ae:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01040b0:	83 c4 10             	add    $0x10,%esp
f01040b3:	eb 03                	jmp    f01040b8 <vprintfmt+0x3dc>
f01040b5:	83 ef 01             	sub    $0x1,%edi
f01040b8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01040bc:	75 f7                	jne    f01040b5 <vprintfmt+0x3d9>
f01040be:	e9 3f fc ff ff       	jmp    f0103d02 <vprintfmt+0x26>
			break;
		}

	}

}
f01040c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040c6:	5b                   	pop    %ebx
f01040c7:	5e                   	pop    %esi
f01040c8:	5f                   	pop    %edi
f01040c9:	5d                   	pop    %ebp
f01040ca:	c3                   	ret    

f01040cb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01040cb:	55                   	push   %ebp
f01040cc:	89 e5                	mov    %esp,%ebp
f01040ce:	83 ec 18             	sub    $0x18,%esp
f01040d1:	8b 45 08             	mov    0x8(%ebp),%eax
f01040d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01040d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01040da:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01040de:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01040e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01040e8:	85 c0                	test   %eax,%eax
f01040ea:	74 26                	je     f0104112 <vsnprintf+0x47>
f01040ec:	85 d2                	test   %edx,%edx
f01040ee:	7e 22                	jle    f0104112 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01040f0:	ff 75 14             	pushl  0x14(%ebp)
f01040f3:	ff 75 10             	pushl  0x10(%ebp)
f01040f6:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01040f9:	50                   	push   %eax
f01040fa:	68 a2 3c 10 f0       	push   $0xf0103ca2
f01040ff:	e8 d8 fb ff ff       	call   f0103cdc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104104:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104107:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010410a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010410d:	83 c4 10             	add    $0x10,%esp
f0104110:	eb 05                	jmp    f0104117 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104112:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104117:	c9                   	leave  
f0104118:	c3                   	ret    

f0104119 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104119:	55                   	push   %ebp
f010411a:	89 e5                	mov    %esp,%ebp
f010411c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010411f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104122:	50                   	push   %eax
f0104123:	ff 75 10             	pushl  0x10(%ebp)
f0104126:	ff 75 0c             	pushl  0xc(%ebp)
f0104129:	ff 75 08             	pushl  0x8(%ebp)
f010412c:	e8 9a ff ff ff       	call   f01040cb <vsnprintf>
	va_end(ap);

	return rc;
}
f0104131:	c9                   	leave  
f0104132:	c3                   	ret    

f0104133 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104133:	55                   	push   %ebp
f0104134:	89 e5                	mov    %esp,%ebp
f0104136:	57                   	push   %edi
f0104137:	56                   	push   %esi
f0104138:	53                   	push   %ebx
f0104139:	83 ec 0c             	sub    $0xc,%esp
f010413c:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010413f:	85 c0                	test   %eax,%eax
f0104141:	74 11                	je     f0104154 <readline+0x21>
		cprintf("%s", prompt);
f0104143:	83 ec 08             	sub    $0x8,%esp
f0104146:	50                   	push   %eax
f0104147:	68 a8 4d 10 f0       	push   $0xf0104da8
f010414c:	e8 87 ee ff ff       	call   f0102fd8 <cprintf>
f0104151:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104154:	83 ec 0c             	sub    $0xc,%esp
f0104157:	6a 00                	push   $0x0
f0104159:	e8 ca c4 ff ff       	call   f0100628 <iscons>
f010415e:	89 c7                	mov    %eax,%edi
f0104160:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104163:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104168:	e8 aa c4 ff ff       	call   f0100617 <getchar>
f010416d:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010416f:	85 c0                	test   %eax,%eax
f0104171:	79 18                	jns    f010418b <readline+0x58>
			cprintf("read error: %e\n", c);
f0104173:	83 ec 08             	sub    $0x8,%esp
f0104176:	50                   	push   %eax
f0104177:	68 40 60 10 f0       	push   $0xf0106040
f010417c:	e8 57 ee ff ff       	call   f0102fd8 <cprintf>
			return NULL;
f0104181:	83 c4 10             	add    $0x10,%esp
f0104184:	b8 00 00 00 00       	mov    $0x0,%eax
f0104189:	eb 79                	jmp    f0104204 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010418b:	83 f8 08             	cmp    $0x8,%eax
f010418e:	0f 94 c2             	sete   %dl
f0104191:	83 f8 7f             	cmp    $0x7f,%eax
f0104194:	0f 94 c0             	sete   %al
f0104197:	08 c2                	or     %al,%dl
f0104199:	74 1a                	je     f01041b5 <readline+0x82>
f010419b:	85 f6                	test   %esi,%esi
f010419d:	7e 16                	jle    f01041b5 <readline+0x82>
			if (echoing)
f010419f:	85 ff                	test   %edi,%edi
f01041a1:	74 0d                	je     f01041b0 <readline+0x7d>
				cputchar('\b');
f01041a3:	83 ec 0c             	sub    $0xc,%esp
f01041a6:	6a 08                	push   $0x8
f01041a8:	e8 5a c4 ff ff       	call   f0100607 <cputchar>
f01041ad:	83 c4 10             	add    $0x10,%esp
			i--;
f01041b0:	83 ee 01             	sub    $0x1,%esi
f01041b3:	eb b3                	jmp    f0104168 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01041b5:	83 fb 1f             	cmp    $0x1f,%ebx
f01041b8:	7e 23                	jle    f01041dd <readline+0xaa>
f01041ba:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01041c0:	7f 1b                	jg     f01041dd <readline+0xaa>
			if (echoing)
f01041c2:	85 ff                	test   %edi,%edi
f01041c4:	74 0c                	je     f01041d2 <readline+0x9f>
				cputchar(c);
f01041c6:	83 ec 0c             	sub    $0xc,%esp
f01041c9:	53                   	push   %ebx
f01041ca:	e8 38 c4 ff ff       	call   f0100607 <cputchar>
f01041cf:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01041d2:	88 9e 40 d8 17 f0    	mov    %bl,-0xfe827c0(%esi)
f01041d8:	8d 76 01             	lea    0x1(%esi),%esi
f01041db:	eb 8b                	jmp    f0104168 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01041dd:	83 fb 0a             	cmp    $0xa,%ebx
f01041e0:	74 05                	je     f01041e7 <readline+0xb4>
f01041e2:	83 fb 0d             	cmp    $0xd,%ebx
f01041e5:	75 81                	jne    f0104168 <readline+0x35>
			if (echoing)
f01041e7:	85 ff                	test   %edi,%edi
f01041e9:	74 0d                	je     f01041f8 <readline+0xc5>
				cputchar('\n');
f01041eb:	83 ec 0c             	sub    $0xc,%esp
f01041ee:	6a 0a                	push   $0xa
f01041f0:	e8 12 c4 ff ff       	call   f0100607 <cputchar>
f01041f5:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01041f8:	c6 86 40 d8 17 f0 00 	movb   $0x0,-0xfe827c0(%esi)
			return buf;
f01041ff:	b8 40 d8 17 f0       	mov    $0xf017d840,%eax
		}
	}
}
f0104204:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104207:	5b                   	pop    %ebx
f0104208:	5e                   	pop    %esi
f0104209:	5f                   	pop    %edi
f010420a:	5d                   	pop    %ebp
f010420b:	c3                   	ret    

f010420c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010420c:	55                   	push   %ebp
f010420d:	89 e5                	mov    %esp,%ebp
f010420f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104212:	b8 00 00 00 00       	mov    $0x0,%eax
f0104217:	eb 03                	jmp    f010421c <strlen+0x10>
		n++;
f0104219:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010421c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104220:	75 f7                	jne    f0104219 <strlen+0xd>
		n++;
	return n;
}
f0104222:	5d                   	pop    %ebp
f0104223:	c3                   	ret    

f0104224 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104224:	55                   	push   %ebp
f0104225:	89 e5                	mov    %esp,%ebp
f0104227:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010422a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010422d:	ba 00 00 00 00       	mov    $0x0,%edx
f0104232:	eb 03                	jmp    f0104237 <strnlen+0x13>
		n++;
f0104234:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104237:	39 c2                	cmp    %eax,%edx
f0104239:	74 08                	je     f0104243 <strnlen+0x1f>
f010423b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010423f:	75 f3                	jne    f0104234 <strnlen+0x10>
f0104241:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0104243:	5d                   	pop    %ebp
f0104244:	c3                   	ret    

f0104245 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104245:	55                   	push   %ebp
f0104246:	89 e5                	mov    %esp,%ebp
f0104248:	53                   	push   %ebx
f0104249:	8b 45 08             	mov    0x8(%ebp),%eax
f010424c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010424f:	89 c2                	mov    %eax,%edx
f0104251:	83 c2 01             	add    $0x1,%edx
f0104254:	83 c1 01             	add    $0x1,%ecx
f0104257:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010425b:	88 5a ff             	mov    %bl,-0x1(%edx)
f010425e:	84 db                	test   %bl,%bl
f0104260:	75 ef                	jne    f0104251 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104262:	5b                   	pop    %ebx
f0104263:	5d                   	pop    %ebp
f0104264:	c3                   	ret    

f0104265 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104265:	55                   	push   %ebp
f0104266:	89 e5                	mov    %esp,%ebp
f0104268:	53                   	push   %ebx
f0104269:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010426c:	53                   	push   %ebx
f010426d:	e8 9a ff ff ff       	call   f010420c <strlen>
f0104272:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104275:	ff 75 0c             	pushl  0xc(%ebp)
f0104278:	01 d8                	add    %ebx,%eax
f010427a:	50                   	push   %eax
f010427b:	e8 c5 ff ff ff       	call   f0104245 <strcpy>
	return dst;
}
f0104280:	89 d8                	mov    %ebx,%eax
f0104282:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104285:	c9                   	leave  
f0104286:	c3                   	ret    

f0104287 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104287:	55                   	push   %ebp
f0104288:	89 e5                	mov    %esp,%ebp
f010428a:	56                   	push   %esi
f010428b:	53                   	push   %ebx
f010428c:	8b 75 08             	mov    0x8(%ebp),%esi
f010428f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104292:	89 f3                	mov    %esi,%ebx
f0104294:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104297:	89 f2                	mov    %esi,%edx
f0104299:	eb 0f                	jmp    f01042aa <strncpy+0x23>
		*dst++ = *src;
f010429b:	83 c2 01             	add    $0x1,%edx
f010429e:	0f b6 01             	movzbl (%ecx),%eax
f01042a1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01042a4:	80 39 01             	cmpb   $0x1,(%ecx)
f01042a7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01042aa:	39 da                	cmp    %ebx,%edx
f01042ac:	75 ed                	jne    f010429b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01042ae:	89 f0                	mov    %esi,%eax
f01042b0:	5b                   	pop    %ebx
f01042b1:	5e                   	pop    %esi
f01042b2:	5d                   	pop    %ebp
f01042b3:	c3                   	ret    

f01042b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01042b4:	55                   	push   %ebp
f01042b5:	89 e5                	mov    %esp,%ebp
f01042b7:	56                   	push   %esi
f01042b8:	53                   	push   %ebx
f01042b9:	8b 75 08             	mov    0x8(%ebp),%esi
f01042bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01042bf:	8b 55 10             	mov    0x10(%ebp),%edx
f01042c2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01042c4:	85 d2                	test   %edx,%edx
f01042c6:	74 21                	je     f01042e9 <strlcpy+0x35>
f01042c8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01042cc:	89 f2                	mov    %esi,%edx
f01042ce:	eb 09                	jmp    f01042d9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01042d0:	83 c2 01             	add    $0x1,%edx
f01042d3:	83 c1 01             	add    $0x1,%ecx
f01042d6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01042d9:	39 c2                	cmp    %eax,%edx
f01042db:	74 09                	je     f01042e6 <strlcpy+0x32>
f01042dd:	0f b6 19             	movzbl (%ecx),%ebx
f01042e0:	84 db                	test   %bl,%bl
f01042e2:	75 ec                	jne    f01042d0 <strlcpy+0x1c>
f01042e4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01042e6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01042e9:	29 f0                	sub    %esi,%eax
}
f01042eb:	5b                   	pop    %ebx
f01042ec:	5e                   	pop    %esi
f01042ed:	5d                   	pop    %ebp
f01042ee:	c3                   	ret    

f01042ef <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01042ef:	55                   	push   %ebp
f01042f0:	89 e5                	mov    %esp,%ebp
f01042f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01042f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01042f8:	eb 06                	jmp    f0104300 <strcmp+0x11>
		p++, q++;
f01042fa:	83 c1 01             	add    $0x1,%ecx
f01042fd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104300:	0f b6 01             	movzbl (%ecx),%eax
f0104303:	84 c0                	test   %al,%al
f0104305:	74 04                	je     f010430b <strcmp+0x1c>
f0104307:	3a 02                	cmp    (%edx),%al
f0104309:	74 ef                	je     f01042fa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010430b:	0f b6 c0             	movzbl %al,%eax
f010430e:	0f b6 12             	movzbl (%edx),%edx
f0104311:	29 d0                	sub    %edx,%eax
}
f0104313:	5d                   	pop    %ebp
f0104314:	c3                   	ret    

f0104315 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104315:	55                   	push   %ebp
f0104316:	89 e5                	mov    %esp,%ebp
f0104318:	53                   	push   %ebx
f0104319:	8b 45 08             	mov    0x8(%ebp),%eax
f010431c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010431f:	89 c3                	mov    %eax,%ebx
f0104321:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104324:	eb 06                	jmp    f010432c <strncmp+0x17>
		n--, p++, q++;
f0104326:	83 c0 01             	add    $0x1,%eax
f0104329:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010432c:	39 d8                	cmp    %ebx,%eax
f010432e:	74 15                	je     f0104345 <strncmp+0x30>
f0104330:	0f b6 08             	movzbl (%eax),%ecx
f0104333:	84 c9                	test   %cl,%cl
f0104335:	74 04                	je     f010433b <strncmp+0x26>
f0104337:	3a 0a                	cmp    (%edx),%cl
f0104339:	74 eb                	je     f0104326 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010433b:	0f b6 00             	movzbl (%eax),%eax
f010433e:	0f b6 12             	movzbl (%edx),%edx
f0104341:	29 d0                	sub    %edx,%eax
f0104343:	eb 05                	jmp    f010434a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104345:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010434a:	5b                   	pop    %ebx
f010434b:	5d                   	pop    %ebp
f010434c:	c3                   	ret    

f010434d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010434d:	55                   	push   %ebp
f010434e:	89 e5                	mov    %esp,%ebp
f0104350:	8b 45 08             	mov    0x8(%ebp),%eax
f0104353:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104357:	eb 07                	jmp    f0104360 <strchr+0x13>
		if (*s == c)
f0104359:	38 ca                	cmp    %cl,%dl
f010435b:	74 0f                	je     f010436c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010435d:	83 c0 01             	add    $0x1,%eax
f0104360:	0f b6 10             	movzbl (%eax),%edx
f0104363:	84 d2                	test   %dl,%dl
f0104365:	75 f2                	jne    f0104359 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0104367:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010436c:	5d                   	pop    %ebp
f010436d:	c3                   	ret    

f010436e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010436e:	55                   	push   %ebp
f010436f:	89 e5                	mov    %esp,%ebp
f0104371:	8b 45 08             	mov    0x8(%ebp),%eax
f0104374:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104378:	eb 03                	jmp    f010437d <strfind+0xf>
f010437a:	83 c0 01             	add    $0x1,%eax
f010437d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104380:	38 ca                	cmp    %cl,%dl
f0104382:	74 04                	je     f0104388 <strfind+0x1a>
f0104384:	84 d2                	test   %dl,%dl
f0104386:	75 f2                	jne    f010437a <strfind+0xc>
			break;
	return (char *) s;
}
f0104388:	5d                   	pop    %ebp
f0104389:	c3                   	ret    

f010438a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010438a:	55                   	push   %ebp
f010438b:	89 e5                	mov    %esp,%ebp
f010438d:	57                   	push   %edi
f010438e:	56                   	push   %esi
f010438f:	53                   	push   %ebx
f0104390:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104393:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104396:	85 c9                	test   %ecx,%ecx
f0104398:	74 36                	je     f01043d0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010439a:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01043a0:	75 28                	jne    f01043ca <memset+0x40>
f01043a2:	f6 c1 03             	test   $0x3,%cl
f01043a5:	75 23                	jne    f01043ca <memset+0x40>
		c &= 0xFF;
f01043a7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01043ab:	89 d3                	mov    %edx,%ebx
f01043ad:	c1 e3 08             	shl    $0x8,%ebx
f01043b0:	89 d6                	mov    %edx,%esi
f01043b2:	c1 e6 18             	shl    $0x18,%esi
f01043b5:	89 d0                	mov    %edx,%eax
f01043b7:	c1 e0 10             	shl    $0x10,%eax
f01043ba:	09 f0                	or     %esi,%eax
f01043bc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01043be:	89 d8                	mov    %ebx,%eax
f01043c0:	09 d0                	or     %edx,%eax
f01043c2:	c1 e9 02             	shr    $0x2,%ecx
f01043c5:	fc                   	cld    
f01043c6:	f3 ab                	rep stos %eax,%es:(%edi)
f01043c8:	eb 06                	jmp    f01043d0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01043ca:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043cd:	fc                   	cld    
f01043ce:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01043d0:	89 f8                	mov    %edi,%eax
f01043d2:	5b                   	pop    %ebx
f01043d3:	5e                   	pop    %esi
f01043d4:	5f                   	pop    %edi
f01043d5:	5d                   	pop    %ebp
f01043d6:	c3                   	ret    

f01043d7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01043d7:	55                   	push   %ebp
f01043d8:	89 e5                	mov    %esp,%ebp
f01043da:	57                   	push   %edi
f01043db:	56                   	push   %esi
f01043dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01043df:	8b 75 0c             	mov    0xc(%ebp),%esi
f01043e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01043e5:	39 c6                	cmp    %eax,%esi
f01043e7:	73 35                	jae    f010441e <memmove+0x47>
f01043e9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01043ec:	39 d0                	cmp    %edx,%eax
f01043ee:	73 2e                	jae    f010441e <memmove+0x47>
		s += n;
		d += n;
f01043f0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01043f3:	89 d6                	mov    %edx,%esi
f01043f5:	09 fe                	or     %edi,%esi
f01043f7:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01043fd:	75 13                	jne    f0104412 <memmove+0x3b>
f01043ff:	f6 c1 03             	test   $0x3,%cl
f0104402:	75 0e                	jne    f0104412 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0104404:	83 ef 04             	sub    $0x4,%edi
f0104407:	8d 72 fc             	lea    -0x4(%edx),%esi
f010440a:	c1 e9 02             	shr    $0x2,%ecx
f010440d:	fd                   	std    
f010440e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104410:	eb 09                	jmp    f010441b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104412:	83 ef 01             	sub    $0x1,%edi
f0104415:	8d 72 ff             	lea    -0x1(%edx),%esi
f0104418:	fd                   	std    
f0104419:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010441b:	fc                   	cld    
f010441c:	eb 1d                	jmp    f010443b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010441e:	89 f2                	mov    %esi,%edx
f0104420:	09 c2                	or     %eax,%edx
f0104422:	f6 c2 03             	test   $0x3,%dl
f0104425:	75 0f                	jne    f0104436 <memmove+0x5f>
f0104427:	f6 c1 03             	test   $0x3,%cl
f010442a:	75 0a                	jne    f0104436 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010442c:	c1 e9 02             	shr    $0x2,%ecx
f010442f:	89 c7                	mov    %eax,%edi
f0104431:	fc                   	cld    
f0104432:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104434:	eb 05                	jmp    f010443b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104436:	89 c7                	mov    %eax,%edi
f0104438:	fc                   	cld    
f0104439:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010443b:	5e                   	pop    %esi
f010443c:	5f                   	pop    %edi
f010443d:	5d                   	pop    %ebp
f010443e:	c3                   	ret    

f010443f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010443f:	55                   	push   %ebp
f0104440:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0104442:	ff 75 10             	pushl  0x10(%ebp)
f0104445:	ff 75 0c             	pushl  0xc(%ebp)
f0104448:	ff 75 08             	pushl  0x8(%ebp)
f010444b:	e8 87 ff ff ff       	call   f01043d7 <memmove>
}
f0104450:	c9                   	leave  
f0104451:	c3                   	ret    

f0104452 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104452:	55                   	push   %ebp
f0104453:	89 e5                	mov    %esp,%ebp
f0104455:	56                   	push   %esi
f0104456:	53                   	push   %ebx
f0104457:	8b 45 08             	mov    0x8(%ebp),%eax
f010445a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010445d:	89 c6                	mov    %eax,%esi
f010445f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104462:	eb 1a                	jmp    f010447e <memcmp+0x2c>
		if (*s1 != *s2)
f0104464:	0f b6 08             	movzbl (%eax),%ecx
f0104467:	0f b6 1a             	movzbl (%edx),%ebx
f010446a:	38 d9                	cmp    %bl,%cl
f010446c:	74 0a                	je     f0104478 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010446e:	0f b6 c1             	movzbl %cl,%eax
f0104471:	0f b6 db             	movzbl %bl,%ebx
f0104474:	29 d8                	sub    %ebx,%eax
f0104476:	eb 0f                	jmp    f0104487 <memcmp+0x35>
		s1++, s2++;
f0104478:	83 c0 01             	add    $0x1,%eax
f010447b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010447e:	39 f0                	cmp    %esi,%eax
f0104480:	75 e2                	jne    f0104464 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104482:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104487:	5b                   	pop    %ebx
f0104488:	5e                   	pop    %esi
f0104489:	5d                   	pop    %ebp
f010448a:	c3                   	ret    

f010448b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010448b:	55                   	push   %ebp
f010448c:	89 e5                	mov    %esp,%ebp
f010448e:	53                   	push   %ebx
f010448f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104492:	89 c1                	mov    %eax,%ecx
f0104494:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0104497:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010449b:	eb 0a                	jmp    f01044a7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010449d:	0f b6 10             	movzbl (%eax),%edx
f01044a0:	39 da                	cmp    %ebx,%edx
f01044a2:	74 07                	je     f01044ab <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01044a4:	83 c0 01             	add    $0x1,%eax
f01044a7:	39 c8                	cmp    %ecx,%eax
f01044a9:	72 f2                	jb     f010449d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01044ab:	5b                   	pop    %ebx
f01044ac:	5d                   	pop    %ebp
f01044ad:	c3                   	ret    

f01044ae <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01044ae:	55                   	push   %ebp
f01044af:	89 e5                	mov    %esp,%ebp
f01044b1:	57                   	push   %edi
f01044b2:	56                   	push   %esi
f01044b3:	53                   	push   %ebx
f01044b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01044b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01044ba:	eb 03                	jmp    f01044bf <strtol+0x11>
		s++;
f01044bc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01044bf:	0f b6 01             	movzbl (%ecx),%eax
f01044c2:	3c 20                	cmp    $0x20,%al
f01044c4:	74 f6                	je     f01044bc <strtol+0xe>
f01044c6:	3c 09                	cmp    $0x9,%al
f01044c8:	74 f2                	je     f01044bc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01044ca:	3c 2b                	cmp    $0x2b,%al
f01044cc:	75 0a                	jne    f01044d8 <strtol+0x2a>
		s++;
f01044ce:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01044d1:	bf 00 00 00 00       	mov    $0x0,%edi
f01044d6:	eb 11                	jmp    f01044e9 <strtol+0x3b>
f01044d8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01044dd:	3c 2d                	cmp    $0x2d,%al
f01044df:	75 08                	jne    f01044e9 <strtol+0x3b>
		s++, neg = 1;
f01044e1:	83 c1 01             	add    $0x1,%ecx
f01044e4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01044e9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01044ef:	75 15                	jne    f0104506 <strtol+0x58>
f01044f1:	80 39 30             	cmpb   $0x30,(%ecx)
f01044f4:	75 10                	jne    f0104506 <strtol+0x58>
f01044f6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01044fa:	75 7c                	jne    f0104578 <strtol+0xca>
		s += 2, base = 16;
f01044fc:	83 c1 02             	add    $0x2,%ecx
f01044ff:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104504:	eb 16                	jmp    f010451c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0104506:	85 db                	test   %ebx,%ebx
f0104508:	75 12                	jne    f010451c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010450a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010450f:	80 39 30             	cmpb   $0x30,(%ecx)
f0104512:	75 08                	jne    f010451c <strtol+0x6e>
		s++, base = 8;
f0104514:	83 c1 01             	add    $0x1,%ecx
f0104517:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010451c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104521:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104524:	0f b6 11             	movzbl (%ecx),%edx
f0104527:	8d 72 d0             	lea    -0x30(%edx),%esi
f010452a:	89 f3                	mov    %esi,%ebx
f010452c:	80 fb 09             	cmp    $0x9,%bl
f010452f:	77 08                	ja     f0104539 <strtol+0x8b>
			dig = *s - '0';
f0104531:	0f be d2             	movsbl %dl,%edx
f0104534:	83 ea 30             	sub    $0x30,%edx
f0104537:	eb 22                	jmp    f010455b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0104539:	8d 72 9f             	lea    -0x61(%edx),%esi
f010453c:	89 f3                	mov    %esi,%ebx
f010453e:	80 fb 19             	cmp    $0x19,%bl
f0104541:	77 08                	ja     f010454b <strtol+0x9d>
			dig = *s - 'a' + 10;
f0104543:	0f be d2             	movsbl %dl,%edx
f0104546:	83 ea 57             	sub    $0x57,%edx
f0104549:	eb 10                	jmp    f010455b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010454b:	8d 72 bf             	lea    -0x41(%edx),%esi
f010454e:	89 f3                	mov    %esi,%ebx
f0104550:	80 fb 19             	cmp    $0x19,%bl
f0104553:	77 16                	ja     f010456b <strtol+0xbd>
			dig = *s - 'A' + 10;
f0104555:	0f be d2             	movsbl %dl,%edx
f0104558:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010455b:	3b 55 10             	cmp    0x10(%ebp),%edx
f010455e:	7d 0b                	jge    f010456b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0104560:	83 c1 01             	add    $0x1,%ecx
f0104563:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104567:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0104569:	eb b9                	jmp    f0104524 <strtol+0x76>

	if (endptr)
f010456b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010456f:	74 0d                	je     f010457e <strtol+0xd0>
		*endptr = (char *) s;
f0104571:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104574:	89 0e                	mov    %ecx,(%esi)
f0104576:	eb 06                	jmp    f010457e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104578:	85 db                	test   %ebx,%ebx
f010457a:	74 98                	je     f0104514 <strtol+0x66>
f010457c:	eb 9e                	jmp    f010451c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010457e:	89 c2                	mov    %eax,%edx
f0104580:	f7 da                	neg    %edx
f0104582:	85 ff                	test   %edi,%edi
f0104584:	0f 45 c2             	cmovne %edx,%eax
}
f0104587:	5b                   	pop    %ebx
f0104588:	5e                   	pop    %esi
f0104589:	5f                   	pop    %edi
f010458a:	5d                   	pop    %ebp
f010458b:	c3                   	ret    
f010458c:	66 90                	xchg   %ax,%ax
f010458e:	66 90                	xchg   %ax,%ax

f0104590 <__udivdi3>:
f0104590:	55                   	push   %ebp
f0104591:	57                   	push   %edi
f0104592:	56                   	push   %esi
f0104593:	53                   	push   %ebx
f0104594:	83 ec 1c             	sub    $0x1c,%esp
f0104597:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010459b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010459f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01045a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01045a7:	85 f6                	test   %esi,%esi
f01045a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01045ad:	89 ca                	mov    %ecx,%edx
f01045af:	89 f8                	mov    %edi,%eax
f01045b1:	75 3d                	jne    f01045f0 <__udivdi3+0x60>
f01045b3:	39 cf                	cmp    %ecx,%edi
f01045b5:	0f 87 c5 00 00 00    	ja     f0104680 <__udivdi3+0xf0>
f01045bb:	85 ff                	test   %edi,%edi
f01045bd:	89 fd                	mov    %edi,%ebp
f01045bf:	75 0b                	jne    f01045cc <__udivdi3+0x3c>
f01045c1:	b8 01 00 00 00       	mov    $0x1,%eax
f01045c6:	31 d2                	xor    %edx,%edx
f01045c8:	f7 f7                	div    %edi
f01045ca:	89 c5                	mov    %eax,%ebp
f01045cc:	89 c8                	mov    %ecx,%eax
f01045ce:	31 d2                	xor    %edx,%edx
f01045d0:	f7 f5                	div    %ebp
f01045d2:	89 c1                	mov    %eax,%ecx
f01045d4:	89 d8                	mov    %ebx,%eax
f01045d6:	89 cf                	mov    %ecx,%edi
f01045d8:	f7 f5                	div    %ebp
f01045da:	89 c3                	mov    %eax,%ebx
f01045dc:	89 d8                	mov    %ebx,%eax
f01045de:	89 fa                	mov    %edi,%edx
f01045e0:	83 c4 1c             	add    $0x1c,%esp
f01045e3:	5b                   	pop    %ebx
f01045e4:	5e                   	pop    %esi
f01045e5:	5f                   	pop    %edi
f01045e6:	5d                   	pop    %ebp
f01045e7:	c3                   	ret    
f01045e8:	90                   	nop
f01045e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01045f0:	39 ce                	cmp    %ecx,%esi
f01045f2:	77 74                	ja     f0104668 <__udivdi3+0xd8>
f01045f4:	0f bd fe             	bsr    %esi,%edi
f01045f7:	83 f7 1f             	xor    $0x1f,%edi
f01045fa:	0f 84 98 00 00 00    	je     f0104698 <__udivdi3+0x108>
f0104600:	bb 20 00 00 00       	mov    $0x20,%ebx
f0104605:	89 f9                	mov    %edi,%ecx
f0104607:	89 c5                	mov    %eax,%ebp
f0104609:	29 fb                	sub    %edi,%ebx
f010460b:	d3 e6                	shl    %cl,%esi
f010460d:	89 d9                	mov    %ebx,%ecx
f010460f:	d3 ed                	shr    %cl,%ebp
f0104611:	89 f9                	mov    %edi,%ecx
f0104613:	d3 e0                	shl    %cl,%eax
f0104615:	09 ee                	or     %ebp,%esi
f0104617:	89 d9                	mov    %ebx,%ecx
f0104619:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010461d:	89 d5                	mov    %edx,%ebp
f010461f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104623:	d3 ed                	shr    %cl,%ebp
f0104625:	89 f9                	mov    %edi,%ecx
f0104627:	d3 e2                	shl    %cl,%edx
f0104629:	89 d9                	mov    %ebx,%ecx
f010462b:	d3 e8                	shr    %cl,%eax
f010462d:	09 c2                	or     %eax,%edx
f010462f:	89 d0                	mov    %edx,%eax
f0104631:	89 ea                	mov    %ebp,%edx
f0104633:	f7 f6                	div    %esi
f0104635:	89 d5                	mov    %edx,%ebp
f0104637:	89 c3                	mov    %eax,%ebx
f0104639:	f7 64 24 0c          	mull   0xc(%esp)
f010463d:	39 d5                	cmp    %edx,%ebp
f010463f:	72 10                	jb     f0104651 <__udivdi3+0xc1>
f0104641:	8b 74 24 08          	mov    0x8(%esp),%esi
f0104645:	89 f9                	mov    %edi,%ecx
f0104647:	d3 e6                	shl    %cl,%esi
f0104649:	39 c6                	cmp    %eax,%esi
f010464b:	73 07                	jae    f0104654 <__udivdi3+0xc4>
f010464d:	39 d5                	cmp    %edx,%ebp
f010464f:	75 03                	jne    f0104654 <__udivdi3+0xc4>
f0104651:	83 eb 01             	sub    $0x1,%ebx
f0104654:	31 ff                	xor    %edi,%edi
f0104656:	89 d8                	mov    %ebx,%eax
f0104658:	89 fa                	mov    %edi,%edx
f010465a:	83 c4 1c             	add    $0x1c,%esp
f010465d:	5b                   	pop    %ebx
f010465e:	5e                   	pop    %esi
f010465f:	5f                   	pop    %edi
f0104660:	5d                   	pop    %ebp
f0104661:	c3                   	ret    
f0104662:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104668:	31 ff                	xor    %edi,%edi
f010466a:	31 db                	xor    %ebx,%ebx
f010466c:	89 d8                	mov    %ebx,%eax
f010466e:	89 fa                	mov    %edi,%edx
f0104670:	83 c4 1c             	add    $0x1c,%esp
f0104673:	5b                   	pop    %ebx
f0104674:	5e                   	pop    %esi
f0104675:	5f                   	pop    %edi
f0104676:	5d                   	pop    %ebp
f0104677:	c3                   	ret    
f0104678:	90                   	nop
f0104679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104680:	89 d8                	mov    %ebx,%eax
f0104682:	f7 f7                	div    %edi
f0104684:	31 ff                	xor    %edi,%edi
f0104686:	89 c3                	mov    %eax,%ebx
f0104688:	89 d8                	mov    %ebx,%eax
f010468a:	89 fa                	mov    %edi,%edx
f010468c:	83 c4 1c             	add    $0x1c,%esp
f010468f:	5b                   	pop    %ebx
f0104690:	5e                   	pop    %esi
f0104691:	5f                   	pop    %edi
f0104692:	5d                   	pop    %ebp
f0104693:	c3                   	ret    
f0104694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104698:	39 ce                	cmp    %ecx,%esi
f010469a:	72 0c                	jb     f01046a8 <__udivdi3+0x118>
f010469c:	31 db                	xor    %ebx,%ebx
f010469e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01046a2:	0f 87 34 ff ff ff    	ja     f01045dc <__udivdi3+0x4c>
f01046a8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01046ad:	e9 2a ff ff ff       	jmp    f01045dc <__udivdi3+0x4c>
f01046b2:	66 90                	xchg   %ax,%ax
f01046b4:	66 90                	xchg   %ax,%ax
f01046b6:	66 90                	xchg   %ax,%ax
f01046b8:	66 90                	xchg   %ax,%ax
f01046ba:	66 90                	xchg   %ax,%ax
f01046bc:	66 90                	xchg   %ax,%ax
f01046be:	66 90                	xchg   %ax,%ax

f01046c0 <__umoddi3>:
f01046c0:	55                   	push   %ebp
f01046c1:	57                   	push   %edi
f01046c2:	56                   	push   %esi
f01046c3:	53                   	push   %ebx
f01046c4:	83 ec 1c             	sub    $0x1c,%esp
f01046c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01046cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01046cf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01046d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01046d7:	85 d2                	test   %edx,%edx
f01046d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01046dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01046e1:	89 f3                	mov    %esi,%ebx
f01046e3:	89 3c 24             	mov    %edi,(%esp)
f01046e6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01046ea:	75 1c                	jne    f0104708 <__umoddi3+0x48>
f01046ec:	39 f7                	cmp    %esi,%edi
f01046ee:	76 50                	jbe    f0104740 <__umoddi3+0x80>
f01046f0:	89 c8                	mov    %ecx,%eax
f01046f2:	89 f2                	mov    %esi,%edx
f01046f4:	f7 f7                	div    %edi
f01046f6:	89 d0                	mov    %edx,%eax
f01046f8:	31 d2                	xor    %edx,%edx
f01046fa:	83 c4 1c             	add    $0x1c,%esp
f01046fd:	5b                   	pop    %ebx
f01046fe:	5e                   	pop    %esi
f01046ff:	5f                   	pop    %edi
f0104700:	5d                   	pop    %ebp
f0104701:	c3                   	ret    
f0104702:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104708:	39 f2                	cmp    %esi,%edx
f010470a:	89 d0                	mov    %edx,%eax
f010470c:	77 52                	ja     f0104760 <__umoddi3+0xa0>
f010470e:	0f bd ea             	bsr    %edx,%ebp
f0104711:	83 f5 1f             	xor    $0x1f,%ebp
f0104714:	75 5a                	jne    f0104770 <__umoddi3+0xb0>
f0104716:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010471a:	0f 82 e0 00 00 00    	jb     f0104800 <__umoddi3+0x140>
f0104720:	39 0c 24             	cmp    %ecx,(%esp)
f0104723:	0f 86 d7 00 00 00    	jbe    f0104800 <__umoddi3+0x140>
f0104729:	8b 44 24 08          	mov    0x8(%esp),%eax
f010472d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104731:	83 c4 1c             	add    $0x1c,%esp
f0104734:	5b                   	pop    %ebx
f0104735:	5e                   	pop    %esi
f0104736:	5f                   	pop    %edi
f0104737:	5d                   	pop    %ebp
f0104738:	c3                   	ret    
f0104739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104740:	85 ff                	test   %edi,%edi
f0104742:	89 fd                	mov    %edi,%ebp
f0104744:	75 0b                	jne    f0104751 <__umoddi3+0x91>
f0104746:	b8 01 00 00 00       	mov    $0x1,%eax
f010474b:	31 d2                	xor    %edx,%edx
f010474d:	f7 f7                	div    %edi
f010474f:	89 c5                	mov    %eax,%ebp
f0104751:	89 f0                	mov    %esi,%eax
f0104753:	31 d2                	xor    %edx,%edx
f0104755:	f7 f5                	div    %ebp
f0104757:	89 c8                	mov    %ecx,%eax
f0104759:	f7 f5                	div    %ebp
f010475b:	89 d0                	mov    %edx,%eax
f010475d:	eb 99                	jmp    f01046f8 <__umoddi3+0x38>
f010475f:	90                   	nop
f0104760:	89 c8                	mov    %ecx,%eax
f0104762:	89 f2                	mov    %esi,%edx
f0104764:	83 c4 1c             	add    $0x1c,%esp
f0104767:	5b                   	pop    %ebx
f0104768:	5e                   	pop    %esi
f0104769:	5f                   	pop    %edi
f010476a:	5d                   	pop    %ebp
f010476b:	c3                   	ret    
f010476c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104770:	8b 34 24             	mov    (%esp),%esi
f0104773:	bf 20 00 00 00       	mov    $0x20,%edi
f0104778:	89 e9                	mov    %ebp,%ecx
f010477a:	29 ef                	sub    %ebp,%edi
f010477c:	d3 e0                	shl    %cl,%eax
f010477e:	89 f9                	mov    %edi,%ecx
f0104780:	89 f2                	mov    %esi,%edx
f0104782:	d3 ea                	shr    %cl,%edx
f0104784:	89 e9                	mov    %ebp,%ecx
f0104786:	09 c2                	or     %eax,%edx
f0104788:	89 d8                	mov    %ebx,%eax
f010478a:	89 14 24             	mov    %edx,(%esp)
f010478d:	89 f2                	mov    %esi,%edx
f010478f:	d3 e2                	shl    %cl,%edx
f0104791:	89 f9                	mov    %edi,%ecx
f0104793:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104797:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010479b:	d3 e8                	shr    %cl,%eax
f010479d:	89 e9                	mov    %ebp,%ecx
f010479f:	89 c6                	mov    %eax,%esi
f01047a1:	d3 e3                	shl    %cl,%ebx
f01047a3:	89 f9                	mov    %edi,%ecx
f01047a5:	89 d0                	mov    %edx,%eax
f01047a7:	d3 e8                	shr    %cl,%eax
f01047a9:	89 e9                	mov    %ebp,%ecx
f01047ab:	09 d8                	or     %ebx,%eax
f01047ad:	89 d3                	mov    %edx,%ebx
f01047af:	89 f2                	mov    %esi,%edx
f01047b1:	f7 34 24             	divl   (%esp)
f01047b4:	89 d6                	mov    %edx,%esi
f01047b6:	d3 e3                	shl    %cl,%ebx
f01047b8:	f7 64 24 04          	mull   0x4(%esp)
f01047bc:	39 d6                	cmp    %edx,%esi
f01047be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01047c2:	89 d1                	mov    %edx,%ecx
f01047c4:	89 c3                	mov    %eax,%ebx
f01047c6:	72 08                	jb     f01047d0 <__umoddi3+0x110>
f01047c8:	75 11                	jne    f01047db <__umoddi3+0x11b>
f01047ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01047ce:	73 0b                	jae    f01047db <__umoddi3+0x11b>
f01047d0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01047d4:	1b 14 24             	sbb    (%esp),%edx
f01047d7:	89 d1                	mov    %edx,%ecx
f01047d9:	89 c3                	mov    %eax,%ebx
f01047db:	8b 54 24 08          	mov    0x8(%esp),%edx
f01047df:	29 da                	sub    %ebx,%edx
f01047e1:	19 ce                	sbb    %ecx,%esi
f01047e3:	89 f9                	mov    %edi,%ecx
f01047e5:	89 f0                	mov    %esi,%eax
f01047e7:	d3 e0                	shl    %cl,%eax
f01047e9:	89 e9                	mov    %ebp,%ecx
f01047eb:	d3 ea                	shr    %cl,%edx
f01047ed:	89 e9                	mov    %ebp,%ecx
f01047ef:	d3 ee                	shr    %cl,%esi
f01047f1:	09 d0                	or     %edx,%eax
f01047f3:	89 f2                	mov    %esi,%edx
f01047f5:	83 c4 1c             	add    $0x1c,%esp
f01047f8:	5b                   	pop    %ebx
f01047f9:	5e                   	pop    %esi
f01047fa:	5f                   	pop    %edi
f01047fb:	5d                   	pop    %ebp
f01047fc:	c3                   	ret    
f01047fd:	8d 76 00             	lea    0x0(%esi),%esi
f0104800:	29 f9                	sub    %edi,%ecx
f0104802:	19 d6                	sbb    %edx,%esi
f0104804:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104808:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010480c:	e9 18 ff ff ff       	jmp    f0104729 <__umoddi3+0x69>
