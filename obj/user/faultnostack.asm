
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 21 03 80 00       	push   $0x800321
  80003e:	6a 00                	push   $0x0
  800040:	e8 36 02 00 00       	call   80027b <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005f:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800066:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  800069:	e8 c6 00 00 00       	call   800134 <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x37>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 42 00 00 00       	call   8000f3 <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    

008000b6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	57                   	push   %edi
  8000ba:	56                   	push   %esi
  8000bb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c7:	89 c3                	mov    %eax,%ebx
  8000c9:	89 c7                	mov    %eax,%edi
  8000cb:	89 c6                	mov    %eax,%esi
  8000cd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	5f                   	pop    %edi
  8000d2:	5d                   	pop    %ebp
  8000d3:	c3                   	ret    

008000d4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	57                   	push   %edi
  8000d8:	56                   	push   %esi
  8000d9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000da:	ba 00 00 00 00       	mov    $0x0,%edx
  8000df:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e4:	89 d1                	mov    %edx,%ecx
  8000e6:	89 d3                	mov    %edx,%ebx
  8000e8:	89 d7                	mov    %edx,%edi
  8000ea:	89 d6                	mov    %edx,%esi
  8000ec:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5f                   	pop    %edi
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	57                   	push   %edi
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800101:	b8 03 00 00 00       	mov    $0x3,%eax
  800106:	8b 55 08             	mov    0x8(%ebp),%edx
  800109:	89 cb                	mov    %ecx,%ebx
  80010b:	89 cf                	mov    %ecx,%edi
  80010d:	89 ce                	mov    %ecx,%esi
  80010f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800111:	85 c0                	test   %eax,%eax
  800113:	7e 17                	jle    80012c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	50                   	push   %eax
  800119:	6a 03                	push   $0x3
  80011b:	68 ea 0f 80 00       	push   $0x800fea
  800120:	6a 23                	push   $0x23
  800122:	68 07 10 80 00       	push   $0x801007
  800127:	e8 00 02 00 00       	call   80032c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5f                   	pop    %edi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    

00800134 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	57                   	push   %edi
  800138:	56                   	push   %esi
  800139:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013a:	ba 00 00 00 00       	mov    $0x0,%edx
  80013f:	b8 02 00 00 00       	mov    $0x2,%eax
  800144:	89 d1                	mov    %edx,%ecx
  800146:	89 d3                	mov    %edx,%ebx
  800148:	89 d7                	mov    %edx,%edi
  80014a:	89 d6                	mov    %edx,%esi
  80014c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014e:	5b                   	pop    %ebx
  80014f:	5e                   	pop    %esi
  800150:	5f                   	pop    %edi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <sys_yield>:

void
sys_yield(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	57                   	push   %edi
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800163:	89 d1                	mov    %edx,%ecx
  800165:	89 d3                	mov    %edx,%ebx
  800167:	89 d7                	mov    %edx,%edi
  800169:	89 d6                	mov    %edx,%esi
  80016b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016d:	5b                   	pop    %ebx
  80016e:	5e                   	pop    %esi
  80016f:	5f                   	pop    %edi
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    

00800172 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	57                   	push   %edi
  800176:	56                   	push   %esi
  800177:	53                   	push   %ebx
  800178:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017b:	be 00 00 00 00       	mov    $0x0,%esi
  800180:	b8 04 00 00 00       	mov    $0x4,%eax
  800185:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800188:	8b 55 08             	mov    0x8(%ebp),%edx
  80018b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018e:	89 f7                	mov    %esi,%edi
  800190:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800192:	85 c0                	test   %eax,%eax
  800194:	7e 17                	jle    8001ad <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800196:	83 ec 0c             	sub    $0xc,%esp
  800199:	50                   	push   %eax
  80019a:	6a 04                	push   $0x4
  80019c:	68 ea 0f 80 00       	push   $0x800fea
  8001a1:	6a 23                	push   $0x23
  8001a3:	68 07 10 80 00       	push   $0x801007
  8001a8:	e8 7f 01 00 00       	call   80032c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b0:	5b                   	pop    %ebx
  8001b1:	5e                   	pop    %esi
  8001b2:	5f                   	pop    %edi
  8001b3:	5d                   	pop    %ebp
  8001b4:	c3                   	ret    

008001b5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	57                   	push   %edi
  8001b9:	56                   	push   %esi
  8001ba:	53                   	push   %ebx
  8001bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001be:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cf:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001d4:	85 c0                	test   %eax,%eax
  8001d6:	7e 17                	jle    8001ef <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	50                   	push   %eax
  8001dc:	6a 05                	push   $0x5
  8001de:	68 ea 0f 80 00       	push   $0x800fea
  8001e3:	6a 23                	push   $0x23
  8001e5:	68 07 10 80 00       	push   $0x801007
  8001ea:	e8 3d 01 00 00       	call   80032c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f2:	5b                   	pop    %ebx
  8001f3:	5e                   	pop    %esi
  8001f4:	5f                   	pop    %edi
  8001f5:	5d                   	pop    %ebp
  8001f6:	c3                   	ret    

008001f7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	57                   	push   %edi
  8001fb:	56                   	push   %esi
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800200:	bb 00 00 00 00       	mov    $0x0,%ebx
  800205:	b8 06 00 00 00       	mov    $0x6,%eax
  80020a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020d:	8b 55 08             	mov    0x8(%ebp),%edx
  800210:	89 df                	mov    %ebx,%edi
  800212:	89 de                	mov    %ebx,%esi
  800214:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800216:	85 c0                	test   %eax,%eax
  800218:	7e 17                	jle    800231 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80021a:	83 ec 0c             	sub    $0xc,%esp
  80021d:	50                   	push   %eax
  80021e:	6a 06                	push   $0x6
  800220:	68 ea 0f 80 00       	push   $0x800fea
  800225:	6a 23                	push   $0x23
  800227:	68 07 10 80 00       	push   $0x801007
  80022c:	e8 fb 00 00 00       	call   80032c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800231:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800234:	5b                   	pop    %ebx
  800235:	5e                   	pop    %esi
  800236:	5f                   	pop    %edi
  800237:	5d                   	pop    %ebp
  800238:	c3                   	ret    

00800239 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	57                   	push   %edi
  80023d:	56                   	push   %esi
  80023e:	53                   	push   %ebx
  80023f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800242:	bb 00 00 00 00       	mov    $0x0,%ebx
  800247:	b8 08 00 00 00       	mov    $0x8,%eax
  80024c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024f:	8b 55 08             	mov    0x8(%ebp),%edx
  800252:	89 df                	mov    %ebx,%edi
  800254:	89 de                	mov    %ebx,%esi
  800256:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800258:	85 c0                	test   %eax,%eax
  80025a:	7e 17                	jle    800273 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025c:	83 ec 0c             	sub    $0xc,%esp
  80025f:	50                   	push   %eax
  800260:	6a 08                	push   $0x8
  800262:	68 ea 0f 80 00       	push   $0x800fea
  800267:	6a 23                	push   $0x23
  800269:	68 07 10 80 00       	push   $0x801007
  80026e:	e8 b9 00 00 00       	call   80032c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800273:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5f                   	pop    %edi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	57                   	push   %edi
  80027f:	56                   	push   %esi
  800280:	53                   	push   %ebx
  800281:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800284:	bb 00 00 00 00       	mov    $0x0,%ebx
  800289:	b8 09 00 00 00       	mov    $0x9,%eax
  80028e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800291:	8b 55 08             	mov    0x8(%ebp),%edx
  800294:	89 df                	mov    %ebx,%edi
  800296:	89 de                	mov    %ebx,%esi
  800298:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80029a:	85 c0                	test   %eax,%eax
  80029c:	7e 17                	jle    8002b5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029e:	83 ec 0c             	sub    $0xc,%esp
  8002a1:	50                   	push   %eax
  8002a2:	6a 09                	push   $0x9
  8002a4:	68 ea 0f 80 00       	push   $0x800fea
  8002a9:	6a 23                	push   $0x23
  8002ab:	68 07 10 80 00       	push   $0x801007
  8002b0:	e8 77 00 00 00       	call   80032c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b8:	5b                   	pop    %ebx
  8002b9:	5e                   	pop    %esi
  8002ba:	5f                   	pop    %edi
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	57                   	push   %edi
  8002c1:	56                   	push   %esi
  8002c2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c3:	be 00 00 00 00       	mov    $0x0,%esi
  8002c8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002d6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002d9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002db:	5b                   	pop    %ebx
  8002dc:	5e                   	pop    %esi
  8002dd:	5f                   	pop    %edi
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f6:	89 cb                	mov    %ecx,%ebx
  8002f8:	89 cf                	mov    %ecx,%edi
  8002fa:	89 ce                	mov    %ecx,%esi
  8002fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002fe:	85 c0                	test   %eax,%eax
  800300:	7e 17                	jle    800319 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800302:	83 ec 0c             	sub    $0xc,%esp
  800305:	50                   	push   %eax
  800306:	6a 0c                	push   $0xc
  800308:	68 ea 0f 80 00       	push   $0x800fea
  80030d:	6a 23                	push   $0x23
  80030f:	68 07 10 80 00       	push   $0x801007
  800314:	e8 13 00 00 00       	call   80032c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800319:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031c:	5b                   	pop    %ebx
  80031d:	5e                   	pop    %esi
  80031e:	5f                   	pop    %edi
  80031f:	5d                   	pop    %ebp
  800320:	c3                   	ret    

00800321 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800321:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800322:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800327:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800329:	83 c4 04             	add    $0x4,%esp

0080032c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	56                   	push   %esi
  800330:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800331:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800334:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80033a:	e8 f5 fd ff ff       	call   800134 <sys_getenvid>
  80033f:	83 ec 0c             	sub    $0xc,%esp
  800342:	ff 75 0c             	pushl  0xc(%ebp)
  800345:	ff 75 08             	pushl  0x8(%ebp)
  800348:	56                   	push   %esi
  800349:	50                   	push   %eax
  80034a:	68 18 10 80 00       	push   $0x801018
  80034f:	e8 b1 00 00 00       	call   800405 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800354:	83 c4 18             	add    $0x18,%esp
  800357:	53                   	push   %ebx
  800358:	ff 75 10             	pushl  0x10(%ebp)
  80035b:	e8 54 00 00 00       	call   8003b4 <vcprintf>
	cprintf("\n");
  800360:	c7 04 24 6f 10 80 00 	movl   $0x80106f,(%esp)
  800367:	e8 99 00 00 00       	call   800405 <cprintf>
  80036c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80036f:	cc                   	int3   
  800370:	eb fd                	jmp    80036f <_panic+0x43>

00800372 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	53                   	push   %ebx
  800376:	83 ec 04             	sub    $0x4,%esp
  800379:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80037c:	8b 13                	mov    (%ebx),%edx
  80037e:	8d 42 01             	lea    0x1(%edx),%eax
  800381:	89 03                	mov    %eax,(%ebx)
  800383:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800386:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80038a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80038f:	75 1a                	jne    8003ab <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800391:	83 ec 08             	sub    $0x8,%esp
  800394:	68 ff 00 00 00       	push   $0xff
  800399:	8d 43 08             	lea    0x8(%ebx),%eax
  80039c:	50                   	push   %eax
  80039d:	e8 14 fd ff ff       	call   8000b6 <sys_cputs>
		b->idx = 0;
  8003a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003a8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003b2:	c9                   	leave  
  8003b3:	c3                   	ret    

008003b4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003c4:	00 00 00 
	b.cnt = 0;
  8003c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003d1:	ff 75 0c             	pushl  0xc(%ebp)
  8003d4:	ff 75 08             	pushl  0x8(%ebp)
  8003d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	68 72 03 80 00       	push   $0x800372
  8003e3:	e8 54 01 00 00       	call   80053c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e8:	83 c4 08             	add    $0x8,%esp
  8003eb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003f1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003f7:	50                   	push   %eax
  8003f8:	e8 b9 fc ff ff       	call   8000b6 <sys_cputs>

	return b.cnt;
}
  8003fd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800403:	c9                   	leave  
  800404:	c3                   	ret    

00800405 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800405:	55                   	push   %ebp
  800406:	89 e5                	mov    %esp,%ebp
  800408:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80040b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80040e:	50                   	push   %eax
  80040f:	ff 75 08             	pushl  0x8(%ebp)
  800412:	e8 9d ff ff ff       	call   8003b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800417:	c9                   	leave  
  800418:	c3                   	ret    

00800419 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	57                   	push   %edi
  80041d:	56                   	push   %esi
  80041e:	53                   	push   %ebx
  80041f:	83 ec 1c             	sub    $0x1c,%esp
  800422:	89 c7                	mov    %eax,%edi
  800424:	89 d6                	mov    %edx,%esi
  800426:	8b 45 08             	mov    0x8(%ebp),%eax
  800429:	8b 55 0c             	mov    0xc(%ebp),%edx
  80042c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80042f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800432:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800435:	bb 00 00 00 00       	mov    $0x0,%ebx
  80043a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80043d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800440:	39 d3                	cmp    %edx,%ebx
  800442:	72 05                	jb     800449 <printnum+0x30>
  800444:	39 45 10             	cmp    %eax,0x10(%ebp)
  800447:	77 45                	ja     80048e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800449:	83 ec 0c             	sub    $0xc,%esp
  80044c:	ff 75 18             	pushl  0x18(%ebp)
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800455:	53                   	push   %ebx
  800456:	ff 75 10             	pushl  0x10(%ebp)
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80045f:	ff 75 e0             	pushl  -0x20(%ebp)
  800462:	ff 75 dc             	pushl  -0x24(%ebp)
  800465:	ff 75 d8             	pushl  -0x28(%ebp)
  800468:	e8 d3 08 00 00       	call   800d40 <__udivdi3>
  80046d:	83 c4 18             	add    $0x18,%esp
  800470:	52                   	push   %edx
  800471:	50                   	push   %eax
  800472:	89 f2                	mov    %esi,%edx
  800474:	89 f8                	mov    %edi,%eax
  800476:	e8 9e ff ff ff       	call   800419 <printnum>
  80047b:	83 c4 20             	add    $0x20,%esp
  80047e:	eb 18                	jmp    800498 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	56                   	push   %esi
  800484:	ff 75 18             	pushl  0x18(%ebp)
  800487:	ff d7                	call   *%edi
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	eb 03                	jmp    800491 <printnum+0x78>
  80048e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800491:	83 eb 01             	sub    $0x1,%ebx
  800494:	85 db                	test   %ebx,%ebx
  800496:	7f e8                	jg     800480 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800498:	83 ec 08             	sub    $0x8,%esp
  80049b:	56                   	push   %esi
  80049c:	83 ec 04             	sub    $0x4,%esp
  80049f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8004a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ab:	e8 c0 09 00 00       	call   800e70 <__umoddi3>
  8004b0:	83 c4 14             	add    $0x14,%esp
  8004b3:	0f be 80 3b 10 80 00 	movsbl 0x80103b(%eax),%eax
  8004ba:	50                   	push   %eax
  8004bb:	ff d7                	call   *%edi
}
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004c3:	5b                   	pop    %ebx
  8004c4:	5e                   	pop    %esi
  8004c5:	5f                   	pop    %edi
  8004c6:	5d                   	pop    %ebp
  8004c7:	c3                   	ret    

008004c8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004cb:	83 fa 01             	cmp    $0x1,%edx
  8004ce:	7e 0e                	jle    8004de <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004d0:	8b 10                	mov    (%eax),%edx
  8004d2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004d5:	89 08                	mov    %ecx,(%eax)
  8004d7:	8b 02                	mov    (%edx),%eax
  8004d9:	8b 52 04             	mov    0x4(%edx),%edx
  8004dc:	eb 22                	jmp    800500 <getuint+0x38>
	else if (lflag)
  8004de:	85 d2                	test   %edx,%edx
  8004e0:	74 10                	je     8004f2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004e2:	8b 10                	mov    (%eax),%edx
  8004e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e7:	89 08                	mov    %ecx,(%eax)
  8004e9:	8b 02                	mov    (%edx),%eax
  8004eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f0:	eb 0e                	jmp    800500 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004f2:	8b 10                	mov    (%eax),%edx
  8004f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f7:	89 08                	mov    %ecx,(%eax)
  8004f9:	8b 02                	mov    (%edx),%eax
  8004fb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800500:	5d                   	pop    %ebp
  800501:	c3                   	ret    

00800502 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800502:	55                   	push   %ebp
  800503:	89 e5                	mov    %esp,%ebp
  800505:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800508:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80050c:	8b 10                	mov    (%eax),%edx
  80050e:	3b 50 04             	cmp    0x4(%eax),%edx
  800511:	73 0a                	jae    80051d <sprintputch+0x1b>
		*b->buf++ = ch;
  800513:	8d 4a 01             	lea    0x1(%edx),%ecx
  800516:	89 08                	mov    %ecx,(%eax)
  800518:	8b 45 08             	mov    0x8(%ebp),%eax
  80051b:	88 02                	mov    %al,(%edx)
}
  80051d:	5d                   	pop    %ebp
  80051e:	c3                   	ret    

0080051f <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800525:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800528:	50                   	push   %eax
  800529:	ff 75 10             	pushl  0x10(%ebp)
  80052c:	ff 75 0c             	pushl  0xc(%ebp)
  80052f:	ff 75 08             	pushl  0x8(%ebp)
  800532:	e8 05 00 00 00       	call   80053c <vprintfmt>
	va_end(ap);
}
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	c9                   	leave  
  80053b:	c3                   	ret    

0080053c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	57                   	push   %edi
  800540:	56                   	push   %esi
  800541:	53                   	push   %ebx
  800542:	83 ec 2c             	sub    $0x2c,%esp
  800545:	8b 75 08             	mov    0x8(%ebp),%esi
  800548:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80054e:	eb 12                	jmp    800562 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800550:	85 c0                	test   %eax,%eax
  800552:	0f 84 cb 03 00 00    	je     800923 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	53                   	push   %ebx
  80055c:	50                   	push   %eax
  80055d:	ff d6                	call   *%esi
  80055f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800562:	83 c7 01             	add    $0x1,%edi
  800565:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800569:	83 f8 25             	cmp    $0x25,%eax
  80056c:	75 e2                	jne    800550 <vprintfmt+0x14>
  80056e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800572:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800579:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800580:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800587:	ba 00 00 00 00       	mov    $0x0,%edx
  80058c:	eb 07                	jmp    800595 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800591:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800595:	8d 47 01             	lea    0x1(%edi),%eax
  800598:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80059b:	0f b6 07             	movzbl (%edi),%eax
  80059e:	0f b6 c8             	movzbl %al,%ecx
  8005a1:	83 e8 23             	sub    $0x23,%eax
  8005a4:	3c 55                	cmp    $0x55,%al
  8005a6:	0f 87 5c 03 00 00    	ja     800908 <vprintfmt+0x3cc>
  8005ac:	0f b6 c0             	movzbl %al,%eax
  8005af:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)
  8005b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005b9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005bd:	eb d6                	jmp    800595 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ca:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005cd:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005d1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005d4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005d7:	83 fa 09             	cmp    $0x9,%edx
  8005da:	77 39                	ja     800615 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005dc:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005df:	eb e9                	jmp    8005ca <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8d 48 04             	lea    0x4(%eax),%ecx
  8005e7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005ea:	8b 00                	mov    (%eax),%eax
  8005ec:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005f2:	eb 27                	jmp    80061b <vprintfmt+0xdf>
  8005f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fe:	0f 49 c8             	cmovns %eax,%ecx
  800601:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800604:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800607:	eb 8c                	jmp    800595 <vprintfmt+0x59>
  800609:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80060c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800613:	eb 80                	jmp    800595 <vprintfmt+0x59>
  800615:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800618:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80061b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80061f:	0f 89 70 ff ff ff    	jns    800595 <vprintfmt+0x59>
				width = precision, precision = -1;
  800625:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800628:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80062b:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800632:	e9 5e ff ff ff       	jmp    800595 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800637:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80063d:	e9 53 ff ff ff       	jmp    800595 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 50 04             	lea    0x4(%eax),%edx
  800648:	89 55 14             	mov    %edx,0x14(%ebp)
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	53                   	push   %ebx
  80064f:	ff 30                	pushl  (%eax)
  800651:	ff d6                	call   *%esi
			break;
  800653:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800656:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800659:	e9 04 ff ff ff       	jmp    800562 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8d 50 04             	lea    0x4(%eax),%edx
  800664:	89 55 14             	mov    %edx,0x14(%ebp)
  800667:	8b 00                	mov    (%eax),%eax
  800669:	99                   	cltd   
  80066a:	31 d0                	xor    %edx,%eax
  80066c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80066e:	83 f8 09             	cmp    $0x9,%eax
  800671:	7f 0b                	jg     80067e <vprintfmt+0x142>
  800673:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  80067a:	85 d2                	test   %edx,%edx
  80067c:	75 18                	jne    800696 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80067e:	50                   	push   %eax
  80067f:	68 53 10 80 00       	push   $0x801053
  800684:	53                   	push   %ebx
  800685:	56                   	push   %esi
  800686:	e8 94 fe ff ff       	call   80051f <printfmt>
  80068b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800691:	e9 cc fe ff ff       	jmp    800562 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800696:	52                   	push   %edx
  800697:	68 5c 10 80 00       	push   $0x80105c
  80069c:	53                   	push   %ebx
  80069d:	56                   	push   %esi
  80069e:	e8 7c fe ff ff       	call   80051f <printfmt>
  8006a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a9:	e9 b4 fe ff ff       	jmp    800562 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8d 50 04             	lea    0x4(%eax),%edx
  8006b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006b9:	85 ff                	test   %edi,%edi
  8006bb:	b8 4c 10 80 00       	mov    $0x80104c,%eax
  8006c0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c7:	0f 8e 94 00 00 00    	jle    800761 <vprintfmt+0x225>
  8006cd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006d1:	0f 84 98 00 00 00    	je     80076f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	ff 75 c8             	pushl  -0x38(%ebp)
  8006dd:	57                   	push   %edi
  8006de:	e8 c8 02 00 00       	call   8009ab <strnlen>
  8006e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006e6:	29 c1                	sub    %eax,%ecx
  8006e8:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006eb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ee:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fa:	eb 0f                	jmp    80070b <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	53                   	push   %ebx
  800700:	ff 75 e0             	pushl  -0x20(%ebp)
  800703:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800705:	83 ef 01             	sub    $0x1,%edi
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	85 ff                	test   %edi,%edi
  80070d:	7f ed                	jg     8006fc <vprintfmt+0x1c0>
  80070f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800712:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800715:	85 c9                	test   %ecx,%ecx
  800717:	b8 00 00 00 00       	mov    $0x0,%eax
  80071c:	0f 49 c1             	cmovns %ecx,%eax
  80071f:	29 c1                	sub    %eax,%ecx
  800721:	89 75 08             	mov    %esi,0x8(%ebp)
  800724:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800727:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80072a:	89 cb                	mov    %ecx,%ebx
  80072c:	eb 4d                	jmp    80077b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80072e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800732:	74 1b                	je     80074f <vprintfmt+0x213>
  800734:	0f be c0             	movsbl %al,%eax
  800737:	83 e8 20             	sub    $0x20,%eax
  80073a:	83 f8 5e             	cmp    $0x5e,%eax
  80073d:	76 10                	jbe    80074f <vprintfmt+0x213>
					putch('?', putdat);
  80073f:	83 ec 08             	sub    $0x8,%esp
  800742:	ff 75 0c             	pushl  0xc(%ebp)
  800745:	6a 3f                	push   $0x3f
  800747:	ff 55 08             	call   *0x8(%ebp)
  80074a:	83 c4 10             	add    $0x10,%esp
  80074d:	eb 0d                	jmp    80075c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80074f:	83 ec 08             	sub    $0x8,%esp
  800752:	ff 75 0c             	pushl  0xc(%ebp)
  800755:	52                   	push   %edx
  800756:	ff 55 08             	call   *0x8(%ebp)
  800759:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80075c:	83 eb 01             	sub    $0x1,%ebx
  80075f:	eb 1a                	jmp    80077b <vprintfmt+0x23f>
  800761:	89 75 08             	mov    %esi,0x8(%ebp)
  800764:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800767:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80076a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80076d:	eb 0c                	jmp    80077b <vprintfmt+0x23f>
  80076f:	89 75 08             	mov    %esi,0x8(%ebp)
  800772:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800775:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800778:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80077b:	83 c7 01             	add    $0x1,%edi
  80077e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800782:	0f be d0             	movsbl %al,%edx
  800785:	85 d2                	test   %edx,%edx
  800787:	74 23                	je     8007ac <vprintfmt+0x270>
  800789:	85 f6                	test   %esi,%esi
  80078b:	78 a1                	js     80072e <vprintfmt+0x1f2>
  80078d:	83 ee 01             	sub    $0x1,%esi
  800790:	79 9c                	jns    80072e <vprintfmt+0x1f2>
  800792:	89 df                	mov    %ebx,%edi
  800794:	8b 75 08             	mov    0x8(%ebp),%esi
  800797:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079a:	eb 18                	jmp    8007b4 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80079c:	83 ec 08             	sub    $0x8,%esp
  80079f:	53                   	push   %ebx
  8007a0:	6a 20                	push   $0x20
  8007a2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a4:	83 ef 01             	sub    $0x1,%edi
  8007a7:	83 c4 10             	add    $0x10,%esp
  8007aa:	eb 08                	jmp    8007b4 <vprintfmt+0x278>
  8007ac:	89 df                	mov    %ebx,%edi
  8007ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007b4:	85 ff                	test   %edi,%edi
  8007b6:	7f e4                	jg     80079c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bb:	e9 a2 fd ff ff       	jmp    800562 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c0:	83 fa 01             	cmp    $0x1,%edx
  8007c3:	7e 16                	jle    8007db <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8d 50 08             	lea    0x8(%eax),%edx
  8007cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ce:	8b 50 04             	mov    0x4(%eax),%edx
  8007d1:	8b 00                	mov    (%eax),%eax
  8007d3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007d6:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007d9:	eb 32                	jmp    80080d <vprintfmt+0x2d1>
	else if (lflag)
  8007db:	85 d2                	test   %edx,%edx
  8007dd:	74 18                	je     8007f7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8d 50 04             	lea    0x4(%eax),%edx
  8007e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e8:	8b 00                	mov    (%eax),%eax
  8007ea:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007ed:	89 c1                	mov    %eax,%ecx
  8007ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007f5:	eb 16                	jmp    80080d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fa:	8d 50 04             	lea    0x4(%eax),%edx
  8007fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800800:	8b 00                	mov    (%eax),%eax
  800802:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800805:	89 c1                	mov    %eax,%ecx
  800807:	c1 f9 1f             	sar    $0x1f,%ecx
  80080a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80080d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800810:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800813:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800816:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800819:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80081e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800822:	0f 89 a8 00 00 00    	jns    8008d0 <vprintfmt+0x394>
				putch('-', putdat);
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	53                   	push   %ebx
  80082c:	6a 2d                	push   $0x2d
  80082e:	ff d6                	call   *%esi
				num = -(long long) num;
  800830:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800833:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800836:	f7 d8                	neg    %eax
  800838:	83 d2 00             	adc    $0x0,%edx
  80083b:	f7 da                	neg    %edx
  80083d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800840:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800843:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800846:	b8 0a 00 00 00       	mov    $0xa,%eax
  80084b:	e9 80 00 00 00       	jmp    8008d0 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800850:	8d 45 14             	lea    0x14(%ebp),%eax
  800853:	e8 70 fc ff ff       	call   8004c8 <getuint>
  800858:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80085b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80085e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800863:	eb 6b                	jmp    8008d0 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800865:	8d 45 14             	lea    0x14(%ebp),%eax
  800868:	e8 5b fc ff ff       	call   8004c8 <getuint>
  80086d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800870:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800873:	6a 04                	push   $0x4
  800875:	6a 03                	push   $0x3
  800877:	6a 01                	push   $0x1
  800879:	68 5f 10 80 00       	push   $0x80105f
  80087e:	e8 82 fb ff ff       	call   800405 <cprintf>
			goto number;
  800883:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  800886:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  80088b:	eb 43                	jmp    8008d0 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  80088d:	83 ec 08             	sub    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	6a 30                	push   $0x30
  800893:	ff d6                	call   *%esi
			putch('x', putdat);
  800895:	83 c4 08             	add    $0x8,%esp
  800898:	53                   	push   %ebx
  800899:	6a 78                	push   $0x78
  80089b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80089d:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a0:	8d 50 04             	lea    0x4(%eax),%edx
  8008a3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008a6:	8b 00                	mov    (%eax),%eax
  8008a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008b3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008b6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008bb:	eb 13                	jmp    8008d0 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c0:	e8 03 fc ff ff       	call   8004c8 <getuint>
  8008c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008cb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d0:	83 ec 0c             	sub    $0xc,%esp
  8008d3:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8008d7:	52                   	push   %edx
  8008d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8008db:	50                   	push   %eax
  8008dc:	ff 75 dc             	pushl  -0x24(%ebp)
  8008df:	ff 75 d8             	pushl  -0x28(%ebp)
  8008e2:	89 da                	mov    %ebx,%edx
  8008e4:	89 f0                	mov    %esi,%eax
  8008e6:	e8 2e fb ff ff       	call   800419 <printnum>

			break;
  8008eb:	83 c4 20             	add    $0x20,%esp
  8008ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008f1:	e9 6c fc ff ff       	jmp    800562 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008f6:	83 ec 08             	sub    $0x8,%esp
  8008f9:	53                   	push   %ebx
  8008fa:	51                   	push   %ecx
  8008fb:	ff d6                	call   *%esi
			break;
  8008fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800900:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800903:	e9 5a fc ff ff       	jmp    800562 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800908:	83 ec 08             	sub    $0x8,%esp
  80090b:	53                   	push   %ebx
  80090c:	6a 25                	push   $0x25
  80090e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800910:	83 c4 10             	add    $0x10,%esp
  800913:	eb 03                	jmp    800918 <vprintfmt+0x3dc>
  800915:	83 ef 01             	sub    $0x1,%edi
  800918:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80091c:	75 f7                	jne    800915 <vprintfmt+0x3d9>
  80091e:	e9 3f fc ff ff       	jmp    800562 <vprintfmt+0x26>
			break;
		}

	}

}
  800923:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800926:	5b                   	pop    %ebx
  800927:	5e                   	pop    %esi
  800928:	5f                   	pop    %edi
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	83 ec 18             	sub    $0x18,%esp
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800937:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80093a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80093e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800941:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800948:	85 c0                	test   %eax,%eax
  80094a:	74 26                	je     800972 <vsnprintf+0x47>
  80094c:	85 d2                	test   %edx,%edx
  80094e:	7e 22                	jle    800972 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800950:	ff 75 14             	pushl  0x14(%ebp)
  800953:	ff 75 10             	pushl  0x10(%ebp)
  800956:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800959:	50                   	push   %eax
  80095a:	68 02 05 80 00       	push   $0x800502
  80095f:	e8 d8 fb ff ff       	call   80053c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800964:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800967:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80096a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096d:	83 c4 10             	add    $0x10,%esp
  800970:	eb 05                	jmp    800977 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800972:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800977:	c9                   	leave  
  800978:	c3                   	ret    

00800979 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80097f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800982:	50                   	push   %eax
  800983:	ff 75 10             	pushl  0x10(%ebp)
  800986:	ff 75 0c             	pushl  0xc(%ebp)
  800989:	ff 75 08             	pushl  0x8(%ebp)
  80098c:	e8 9a ff ff ff       	call   80092b <vsnprintf>
	va_end(ap);

	return rc;
}
  800991:	c9                   	leave  
  800992:	c3                   	ret    

00800993 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800999:	b8 00 00 00 00       	mov    $0x0,%eax
  80099e:	eb 03                	jmp    8009a3 <strlen+0x10>
		n++;
  8009a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009a7:	75 f7                	jne    8009a0 <strlen+0xd>
		n++;
	return n;
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b9:	eb 03                	jmp    8009be <strnlen+0x13>
		n++;
  8009bb:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009be:	39 c2                	cmp    %eax,%edx
  8009c0:	74 08                	je     8009ca <strnlen+0x1f>
  8009c2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009c6:	75 f3                	jne    8009bb <strnlen+0x10>
  8009c8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	53                   	push   %ebx
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009d6:	89 c2                	mov    %eax,%edx
  8009d8:	83 c2 01             	add    $0x1,%edx
  8009db:	83 c1 01             	add    $0x1,%ecx
  8009de:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009e2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009e5:	84 db                	test   %bl,%bl
  8009e7:	75 ef                	jne    8009d8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009e9:	5b                   	pop    %ebx
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	53                   	push   %ebx
  8009f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f3:	53                   	push   %ebx
  8009f4:	e8 9a ff ff ff       	call   800993 <strlen>
  8009f9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009fc:	ff 75 0c             	pushl  0xc(%ebp)
  8009ff:	01 d8                	add    %ebx,%eax
  800a01:	50                   	push   %eax
  800a02:	e8 c5 ff ff ff       	call   8009cc <strcpy>
	return dst;
}
  800a07:	89 d8                	mov    %ebx,%eax
  800a09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0c:	c9                   	leave  
  800a0d:	c3                   	ret    

00800a0e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	56                   	push   %esi
  800a12:	53                   	push   %ebx
  800a13:	8b 75 08             	mov    0x8(%ebp),%esi
  800a16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a19:	89 f3                	mov    %esi,%ebx
  800a1b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a1e:	89 f2                	mov    %esi,%edx
  800a20:	eb 0f                	jmp    800a31 <strncpy+0x23>
		*dst++ = *src;
  800a22:	83 c2 01             	add    $0x1,%edx
  800a25:	0f b6 01             	movzbl (%ecx),%eax
  800a28:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a2b:	80 39 01             	cmpb   $0x1,(%ecx)
  800a2e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a31:	39 da                	cmp    %ebx,%edx
  800a33:	75 ed                	jne    800a22 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a35:	89 f0                	mov    %esi,%eax
  800a37:	5b                   	pop    %ebx
  800a38:	5e                   	pop    %esi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
  800a40:	8b 75 08             	mov    0x8(%ebp),%esi
  800a43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a46:	8b 55 10             	mov    0x10(%ebp),%edx
  800a49:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a4b:	85 d2                	test   %edx,%edx
  800a4d:	74 21                	je     800a70 <strlcpy+0x35>
  800a4f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a53:	89 f2                	mov    %esi,%edx
  800a55:	eb 09                	jmp    800a60 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a57:	83 c2 01             	add    $0x1,%edx
  800a5a:	83 c1 01             	add    $0x1,%ecx
  800a5d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a60:	39 c2                	cmp    %eax,%edx
  800a62:	74 09                	je     800a6d <strlcpy+0x32>
  800a64:	0f b6 19             	movzbl (%ecx),%ebx
  800a67:	84 db                	test   %bl,%bl
  800a69:	75 ec                	jne    800a57 <strlcpy+0x1c>
  800a6b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a6d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a70:	29 f0                	sub    %esi,%eax
}
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a7f:	eb 06                	jmp    800a87 <strcmp+0x11>
		p++, q++;
  800a81:	83 c1 01             	add    $0x1,%ecx
  800a84:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a87:	0f b6 01             	movzbl (%ecx),%eax
  800a8a:	84 c0                	test   %al,%al
  800a8c:	74 04                	je     800a92 <strcmp+0x1c>
  800a8e:	3a 02                	cmp    (%edx),%al
  800a90:	74 ef                	je     800a81 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a92:	0f b6 c0             	movzbl %al,%eax
  800a95:	0f b6 12             	movzbl (%edx),%edx
  800a98:	29 d0                	sub    %edx,%eax
}
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	53                   	push   %ebx
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa6:	89 c3                	mov    %eax,%ebx
  800aa8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aab:	eb 06                	jmp    800ab3 <strncmp+0x17>
		n--, p++, q++;
  800aad:	83 c0 01             	add    $0x1,%eax
  800ab0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab3:	39 d8                	cmp    %ebx,%eax
  800ab5:	74 15                	je     800acc <strncmp+0x30>
  800ab7:	0f b6 08             	movzbl (%eax),%ecx
  800aba:	84 c9                	test   %cl,%cl
  800abc:	74 04                	je     800ac2 <strncmp+0x26>
  800abe:	3a 0a                	cmp    (%edx),%cl
  800ac0:	74 eb                	je     800aad <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac2:	0f b6 00             	movzbl (%eax),%eax
  800ac5:	0f b6 12             	movzbl (%edx),%edx
  800ac8:	29 d0                	sub    %edx,%eax
  800aca:	eb 05                	jmp    800ad1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800acc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  800ada:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ade:	eb 07                	jmp    800ae7 <strchr+0x13>
		if (*s == c)
  800ae0:	38 ca                	cmp    %cl,%dl
  800ae2:	74 0f                	je     800af3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae4:	83 c0 01             	add    $0x1,%eax
  800ae7:	0f b6 10             	movzbl (%eax),%edx
  800aea:	84 d2                	test   %dl,%dl
  800aec:	75 f2                	jne    800ae0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
  800afb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aff:	eb 03                	jmp    800b04 <strfind+0xf>
  800b01:	83 c0 01             	add    $0x1,%eax
  800b04:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b07:	38 ca                	cmp    %cl,%dl
  800b09:	74 04                	je     800b0f <strfind+0x1a>
  800b0b:	84 d2                	test   %dl,%dl
  800b0d:	75 f2                	jne    800b01 <strfind+0xc>
			break;
	return (char *) s;
}
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
  800b17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b1a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b1d:	85 c9                	test   %ecx,%ecx
  800b1f:	74 36                	je     800b57 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b21:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b27:	75 28                	jne    800b51 <memset+0x40>
  800b29:	f6 c1 03             	test   $0x3,%cl
  800b2c:	75 23                	jne    800b51 <memset+0x40>
		c &= 0xFF;
  800b2e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b32:	89 d3                	mov    %edx,%ebx
  800b34:	c1 e3 08             	shl    $0x8,%ebx
  800b37:	89 d6                	mov    %edx,%esi
  800b39:	c1 e6 18             	shl    $0x18,%esi
  800b3c:	89 d0                	mov    %edx,%eax
  800b3e:	c1 e0 10             	shl    $0x10,%eax
  800b41:	09 f0                	or     %esi,%eax
  800b43:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b45:	89 d8                	mov    %ebx,%eax
  800b47:	09 d0                	or     %edx,%eax
  800b49:	c1 e9 02             	shr    $0x2,%ecx
  800b4c:	fc                   	cld    
  800b4d:	f3 ab                	rep stos %eax,%es:(%edi)
  800b4f:	eb 06                	jmp    800b57 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b54:	fc                   	cld    
  800b55:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b57:	89 f8                	mov    %edi,%eax
  800b59:	5b                   	pop    %ebx
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	8b 45 08             	mov    0x8(%ebp),%eax
  800b66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b69:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b6c:	39 c6                	cmp    %eax,%esi
  800b6e:	73 35                	jae    800ba5 <memmove+0x47>
  800b70:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b73:	39 d0                	cmp    %edx,%eax
  800b75:	73 2e                	jae    800ba5 <memmove+0x47>
		s += n;
		d += n;
  800b77:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7a:	89 d6                	mov    %edx,%esi
  800b7c:	09 fe                	or     %edi,%esi
  800b7e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b84:	75 13                	jne    800b99 <memmove+0x3b>
  800b86:	f6 c1 03             	test   $0x3,%cl
  800b89:	75 0e                	jne    800b99 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b8b:	83 ef 04             	sub    $0x4,%edi
  800b8e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b91:	c1 e9 02             	shr    $0x2,%ecx
  800b94:	fd                   	std    
  800b95:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b97:	eb 09                	jmp    800ba2 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b99:	83 ef 01             	sub    $0x1,%edi
  800b9c:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b9f:	fd                   	std    
  800ba0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba2:	fc                   	cld    
  800ba3:	eb 1d                	jmp    800bc2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba5:	89 f2                	mov    %esi,%edx
  800ba7:	09 c2                	or     %eax,%edx
  800ba9:	f6 c2 03             	test   $0x3,%dl
  800bac:	75 0f                	jne    800bbd <memmove+0x5f>
  800bae:	f6 c1 03             	test   $0x3,%cl
  800bb1:	75 0a                	jne    800bbd <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bb3:	c1 e9 02             	shr    $0x2,%ecx
  800bb6:	89 c7                	mov    %eax,%edi
  800bb8:	fc                   	cld    
  800bb9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bbb:	eb 05                	jmp    800bc2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bbd:	89 c7                	mov    %eax,%edi
  800bbf:	fc                   	cld    
  800bc0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bc9:	ff 75 10             	pushl  0x10(%ebp)
  800bcc:	ff 75 0c             	pushl  0xc(%ebp)
  800bcf:	ff 75 08             	pushl  0x8(%ebp)
  800bd2:	e8 87 ff ff ff       	call   800b5e <memmove>
}
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	8b 45 08             	mov    0x8(%ebp),%eax
  800be1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800be4:	89 c6                	mov    %eax,%esi
  800be6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be9:	eb 1a                	jmp    800c05 <memcmp+0x2c>
		if (*s1 != *s2)
  800beb:	0f b6 08             	movzbl (%eax),%ecx
  800bee:	0f b6 1a             	movzbl (%edx),%ebx
  800bf1:	38 d9                	cmp    %bl,%cl
  800bf3:	74 0a                	je     800bff <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bf5:	0f b6 c1             	movzbl %cl,%eax
  800bf8:	0f b6 db             	movzbl %bl,%ebx
  800bfb:	29 d8                	sub    %ebx,%eax
  800bfd:	eb 0f                	jmp    800c0e <memcmp+0x35>
		s1++, s2++;
  800bff:	83 c0 01             	add    $0x1,%eax
  800c02:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c05:	39 f0                	cmp    %esi,%eax
  800c07:	75 e2                	jne    800beb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	53                   	push   %ebx
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c19:	89 c1                	mov    %eax,%ecx
  800c1b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c1e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c22:	eb 0a                	jmp    800c2e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c24:	0f b6 10             	movzbl (%eax),%edx
  800c27:	39 da                	cmp    %ebx,%edx
  800c29:	74 07                	je     800c32 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c2b:	83 c0 01             	add    $0x1,%eax
  800c2e:	39 c8                	cmp    %ecx,%eax
  800c30:	72 f2                	jb     800c24 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c32:	5b                   	pop    %ebx
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c41:	eb 03                	jmp    800c46 <strtol+0x11>
		s++;
  800c43:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c46:	0f b6 01             	movzbl (%ecx),%eax
  800c49:	3c 20                	cmp    $0x20,%al
  800c4b:	74 f6                	je     800c43 <strtol+0xe>
  800c4d:	3c 09                	cmp    $0x9,%al
  800c4f:	74 f2                	je     800c43 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c51:	3c 2b                	cmp    $0x2b,%al
  800c53:	75 0a                	jne    800c5f <strtol+0x2a>
		s++;
  800c55:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c58:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5d:	eb 11                	jmp    800c70 <strtol+0x3b>
  800c5f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c64:	3c 2d                	cmp    $0x2d,%al
  800c66:	75 08                	jne    800c70 <strtol+0x3b>
		s++, neg = 1;
  800c68:	83 c1 01             	add    $0x1,%ecx
  800c6b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c70:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c76:	75 15                	jne    800c8d <strtol+0x58>
  800c78:	80 39 30             	cmpb   $0x30,(%ecx)
  800c7b:	75 10                	jne    800c8d <strtol+0x58>
  800c7d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c81:	75 7c                	jne    800cff <strtol+0xca>
		s += 2, base = 16;
  800c83:	83 c1 02             	add    $0x2,%ecx
  800c86:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c8b:	eb 16                	jmp    800ca3 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c8d:	85 db                	test   %ebx,%ebx
  800c8f:	75 12                	jne    800ca3 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c91:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c96:	80 39 30             	cmpb   $0x30,(%ecx)
  800c99:	75 08                	jne    800ca3 <strtol+0x6e>
		s++, base = 8;
  800c9b:	83 c1 01             	add    $0x1,%ecx
  800c9e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ca3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cab:	0f b6 11             	movzbl (%ecx),%edx
  800cae:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cb1:	89 f3                	mov    %esi,%ebx
  800cb3:	80 fb 09             	cmp    $0x9,%bl
  800cb6:	77 08                	ja     800cc0 <strtol+0x8b>
			dig = *s - '0';
  800cb8:	0f be d2             	movsbl %dl,%edx
  800cbb:	83 ea 30             	sub    $0x30,%edx
  800cbe:	eb 22                	jmp    800ce2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cc0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cc3:	89 f3                	mov    %esi,%ebx
  800cc5:	80 fb 19             	cmp    $0x19,%bl
  800cc8:	77 08                	ja     800cd2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cca:	0f be d2             	movsbl %dl,%edx
  800ccd:	83 ea 57             	sub    $0x57,%edx
  800cd0:	eb 10                	jmp    800ce2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cd2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cd5:	89 f3                	mov    %esi,%ebx
  800cd7:	80 fb 19             	cmp    $0x19,%bl
  800cda:	77 16                	ja     800cf2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cdc:	0f be d2             	movsbl %dl,%edx
  800cdf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ce2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ce5:	7d 0b                	jge    800cf2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ce7:	83 c1 01             	add    $0x1,%ecx
  800cea:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cee:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cf0:	eb b9                	jmp    800cab <strtol+0x76>

	if (endptr)
  800cf2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf6:	74 0d                	je     800d05 <strtol+0xd0>
		*endptr = (char *) s;
  800cf8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cfb:	89 0e                	mov    %ecx,(%esi)
  800cfd:	eb 06                	jmp    800d05 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cff:	85 db                	test   %ebx,%ebx
  800d01:	74 98                	je     800c9b <strtol+0x66>
  800d03:	eb 9e                	jmp    800ca3 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d05:	89 c2                	mov    %eax,%edx
  800d07:	f7 da                	neg    %edx
  800d09:	85 ff                	test   %edi,%edi
  800d0b:	0f 45 c2             	cmovne %edx,%eax
}
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d19:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d20:	75 14                	jne    800d36 <set_pgfault_handler+0x23>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800d22:	83 ec 04             	sub    $0x4,%esp
  800d25:	68 a8 12 80 00       	push   $0x8012a8
  800d2a:	6a 20                	push   $0x20
  800d2c:	68 cc 12 80 00       	push   $0x8012cc
  800d31:	e8 f6 f5 ff ff       	call   80032c <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d36:	8b 45 08             	mov    0x8(%ebp),%eax
  800d39:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d3e:	c9                   	leave  
  800d3f:	c3                   	ret    

00800d40 <__udivdi3>:
  800d40:	55                   	push   %ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 1c             	sub    $0x1c,%esp
  800d47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d57:	85 f6                	test   %esi,%esi
  800d59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d5d:	89 ca                	mov    %ecx,%edx
  800d5f:	89 f8                	mov    %edi,%eax
  800d61:	75 3d                	jne    800da0 <__udivdi3+0x60>
  800d63:	39 cf                	cmp    %ecx,%edi
  800d65:	0f 87 c5 00 00 00    	ja     800e30 <__udivdi3+0xf0>
  800d6b:	85 ff                	test   %edi,%edi
  800d6d:	89 fd                	mov    %edi,%ebp
  800d6f:	75 0b                	jne    800d7c <__udivdi3+0x3c>
  800d71:	b8 01 00 00 00       	mov    $0x1,%eax
  800d76:	31 d2                	xor    %edx,%edx
  800d78:	f7 f7                	div    %edi
  800d7a:	89 c5                	mov    %eax,%ebp
  800d7c:	89 c8                	mov    %ecx,%eax
  800d7e:	31 d2                	xor    %edx,%edx
  800d80:	f7 f5                	div    %ebp
  800d82:	89 c1                	mov    %eax,%ecx
  800d84:	89 d8                	mov    %ebx,%eax
  800d86:	89 cf                	mov    %ecx,%edi
  800d88:	f7 f5                	div    %ebp
  800d8a:	89 c3                	mov    %eax,%ebx
  800d8c:	89 d8                	mov    %ebx,%eax
  800d8e:	89 fa                	mov    %edi,%edx
  800d90:	83 c4 1c             	add    $0x1c,%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    
  800d98:	90                   	nop
  800d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800da0:	39 ce                	cmp    %ecx,%esi
  800da2:	77 74                	ja     800e18 <__udivdi3+0xd8>
  800da4:	0f bd fe             	bsr    %esi,%edi
  800da7:	83 f7 1f             	xor    $0x1f,%edi
  800daa:	0f 84 98 00 00 00    	je     800e48 <__udivdi3+0x108>
  800db0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	89 c5                	mov    %eax,%ebp
  800db9:	29 fb                	sub    %edi,%ebx
  800dbb:	d3 e6                	shl    %cl,%esi
  800dbd:	89 d9                	mov    %ebx,%ecx
  800dbf:	d3 ed                	shr    %cl,%ebp
  800dc1:	89 f9                	mov    %edi,%ecx
  800dc3:	d3 e0                	shl    %cl,%eax
  800dc5:	09 ee                	or     %ebp,%esi
  800dc7:	89 d9                	mov    %ebx,%ecx
  800dc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dcd:	89 d5                	mov    %edx,%ebp
  800dcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800dd3:	d3 ed                	shr    %cl,%ebp
  800dd5:	89 f9                	mov    %edi,%ecx
  800dd7:	d3 e2                	shl    %cl,%edx
  800dd9:	89 d9                	mov    %ebx,%ecx
  800ddb:	d3 e8                	shr    %cl,%eax
  800ddd:	09 c2                	or     %eax,%edx
  800ddf:	89 d0                	mov    %edx,%eax
  800de1:	89 ea                	mov    %ebp,%edx
  800de3:	f7 f6                	div    %esi
  800de5:	89 d5                	mov    %edx,%ebp
  800de7:	89 c3                	mov    %eax,%ebx
  800de9:	f7 64 24 0c          	mull   0xc(%esp)
  800ded:	39 d5                	cmp    %edx,%ebp
  800def:	72 10                	jb     800e01 <__udivdi3+0xc1>
  800df1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800df5:	89 f9                	mov    %edi,%ecx
  800df7:	d3 e6                	shl    %cl,%esi
  800df9:	39 c6                	cmp    %eax,%esi
  800dfb:	73 07                	jae    800e04 <__udivdi3+0xc4>
  800dfd:	39 d5                	cmp    %edx,%ebp
  800dff:	75 03                	jne    800e04 <__udivdi3+0xc4>
  800e01:	83 eb 01             	sub    $0x1,%ebx
  800e04:	31 ff                	xor    %edi,%edi
  800e06:	89 d8                	mov    %ebx,%eax
  800e08:	89 fa                	mov    %edi,%edx
  800e0a:	83 c4 1c             	add    $0x1c,%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    
  800e12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e18:	31 ff                	xor    %edi,%edi
  800e1a:	31 db                	xor    %ebx,%ebx
  800e1c:	89 d8                	mov    %ebx,%eax
  800e1e:	89 fa                	mov    %edi,%edx
  800e20:	83 c4 1c             	add    $0x1c,%esp
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    
  800e28:	90                   	nop
  800e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e30:	89 d8                	mov    %ebx,%eax
  800e32:	f7 f7                	div    %edi
  800e34:	31 ff                	xor    %edi,%edi
  800e36:	89 c3                	mov    %eax,%ebx
  800e38:	89 d8                	mov    %ebx,%eax
  800e3a:	89 fa                	mov    %edi,%edx
  800e3c:	83 c4 1c             	add    $0x1c,%esp
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5f                   	pop    %edi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    
  800e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e48:	39 ce                	cmp    %ecx,%esi
  800e4a:	72 0c                	jb     800e58 <__udivdi3+0x118>
  800e4c:	31 db                	xor    %ebx,%ebx
  800e4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e52:	0f 87 34 ff ff ff    	ja     800d8c <__udivdi3+0x4c>
  800e58:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e5d:	e9 2a ff ff ff       	jmp    800d8c <__udivdi3+0x4c>
  800e62:	66 90                	xchg   %ax,%ax
  800e64:	66 90                	xchg   %ax,%ax
  800e66:	66 90                	xchg   %ax,%ax
  800e68:	66 90                	xchg   %ax,%ax
  800e6a:	66 90                	xchg   %ax,%ax
  800e6c:	66 90                	xchg   %ax,%ax
  800e6e:	66 90                	xchg   %ax,%ax

00800e70 <__umoddi3>:
  800e70:	55                   	push   %ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 1c             	sub    $0x1c,%esp
  800e77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e87:	85 d2                	test   %edx,%edx
  800e89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e91:	89 f3                	mov    %esi,%ebx
  800e93:	89 3c 24             	mov    %edi,(%esp)
  800e96:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e9a:	75 1c                	jne    800eb8 <__umoddi3+0x48>
  800e9c:	39 f7                	cmp    %esi,%edi
  800e9e:	76 50                	jbe    800ef0 <__umoddi3+0x80>
  800ea0:	89 c8                	mov    %ecx,%eax
  800ea2:	89 f2                	mov    %esi,%edx
  800ea4:	f7 f7                	div    %edi
  800ea6:	89 d0                	mov    %edx,%eax
  800ea8:	31 d2                	xor    %edx,%edx
  800eaa:	83 c4 1c             	add    $0x1c,%esp
  800ead:	5b                   	pop    %ebx
  800eae:	5e                   	pop    %esi
  800eaf:	5f                   	pop    %edi
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    
  800eb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800eb8:	39 f2                	cmp    %esi,%edx
  800eba:	89 d0                	mov    %edx,%eax
  800ebc:	77 52                	ja     800f10 <__umoddi3+0xa0>
  800ebe:	0f bd ea             	bsr    %edx,%ebp
  800ec1:	83 f5 1f             	xor    $0x1f,%ebp
  800ec4:	75 5a                	jne    800f20 <__umoddi3+0xb0>
  800ec6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eca:	0f 82 e0 00 00 00    	jb     800fb0 <__umoddi3+0x140>
  800ed0:	39 0c 24             	cmp    %ecx,(%esp)
  800ed3:	0f 86 d7 00 00 00    	jbe    800fb0 <__umoddi3+0x140>
  800ed9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800edd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ee1:	83 c4 1c             	add    $0x1c,%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    
  800ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	85 ff                	test   %edi,%edi
  800ef2:	89 fd                	mov    %edi,%ebp
  800ef4:	75 0b                	jne    800f01 <__umoddi3+0x91>
  800ef6:	b8 01 00 00 00       	mov    $0x1,%eax
  800efb:	31 d2                	xor    %edx,%edx
  800efd:	f7 f7                	div    %edi
  800eff:	89 c5                	mov    %eax,%ebp
  800f01:	89 f0                	mov    %esi,%eax
  800f03:	31 d2                	xor    %edx,%edx
  800f05:	f7 f5                	div    %ebp
  800f07:	89 c8                	mov    %ecx,%eax
  800f09:	f7 f5                	div    %ebp
  800f0b:	89 d0                	mov    %edx,%eax
  800f0d:	eb 99                	jmp    800ea8 <__umoddi3+0x38>
  800f0f:	90                   	nop
  800f10:	89 c8                	mov    %ecx,%eax
  800f12:	89 f2                	mov    %esi,%edx
  800f14:	83 c4 1c             	add    $0x1c,%esp
  800f17:	5b                   	pop    %ebx
  800f18:	5e                   	pop    %esi
  800f19:	5f                   	pop    %edi
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    
  800f1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f20:	8b 34 24             	mov    (%esp),%esi
  800f23:	bf 20 00 00 00       	mov    $0x20,%edi
  800f28:	89 e9                	mov    %ebp,%ecx
  800f2a:	29 ef                	sub    %ebp,%edi
  800f2c:	d3 e0                	shl    %cl,%eax
  800f2e:	89 f9                	mov    %edi,%ecx
  800f30:	89 f2                	mov    %esi,%edx
  800f32:	d3 ea                	shr    %cl,%edx
  800f34:	89 e9                	mov    %ebp,%ecx
  800f36:	09 c2                	or     %eax,%edx
  800f38:	89 d8                	mov    %ebx,%eax
  800f3a:	89 14 24             	mov    %edx,(%esp)
  800f3d:	89 f2                	mov    %esi,%edx
  800f3f:	d3 e2                	shl    %cl,%edx
  800f41:	89 f9                	mov    %edi,%ecx
  800f43:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f4b:	d3 e8                	shr    %cl,%eax
  800f4d:	89 e9                	mov    %ebp,%ecx
  800f4f:	89 c6                	mov    %eax,%esi
  800f51:	d3 e3                	shl    %cl,%ebx
  800f53:	89 f9                	mov    %edi,%ecx
  800f55:	89 d0                	mov    %edx,%eax
  800f57:	d3 e8                	shr    %cl,%eax
  800f59:	89 e9                	mov    %ebp,%ecx
  800f5b:	09 d8                	or     %ebx,%eax
  800f5d:	89 d3                	mov    %edx,%ebx
  800f5f:	89 f2                	mov    %esi,%edx
  800f61:	f7 34 24             	divl   (%esp)
  800f64:	89 d6                	mov    %edx,%esi
  800f66:	d3 e3                	shl    %cl,%ebx
  800f68:	f7 64 24 04          	mull   0x4(%esp)
  800f6c:	39 d6                	cmp    %edx,%esi
  800f6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f72:	89 d1                	mov    %edx,%ecx
  800f74:	89 c3                	mov    %eax,%ebx
  800f76:	72 08                	jb     800f80 <__umoddi3+0x110>
  800f78:	75 11                	jne    800f8b <__umoddi3+0x11b>
  800f7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f7e:	73 0b                	jae    800f8b <__umoddi3+0x11b>
  800f80:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f84:	1b 14 24             	sbb    (%esp),%edx
  800f87:	89 d1                	mov    %edx,%ecx
  800f89:	89 c3                	mov    %eax,%ebx
  800f8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f8f:	29 da                	sub    %ebx,%edx
  800f91:	19 ce                	sbb    %ecx,%esi
  800f93:	89 f9                	mov    %edi,%ecx
  800f95:	89 f0                	mov    %esi,%eax
  800f97:	d3 e0                	shl    %cl,%eax
  800f99:	89 e9                	mov    %ebp,%ecx
  800f9b:	d3 ea                	shr    %cl,%edx
  800f9d:	89 e9                	mov    %ebp,%ecx
  800f9f:	d3 ee                	shr    %cl,%esi
  800fa1:	09 d0                	or     %edx,%eax
  800fa3:	89 f2                	mov    %esi,%edx
  800fa5:	83 c4 1c             	add    $0x1c,%esp
  800fa8:	5b                   	pop    %ebx
  800fa9:	5e                   	pop    %esi
  800faa:	5f                   	pop    %edi
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    
  800fad:	8d 76 00             	lea    0x0(%esi),%esi
  800fb0:	29 f9                	sub    %edi,%ecx
  800fb2:	19 d6                	sbb    %edx,%esi
  800fb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fbc:	e9 18 ff ff ff       	jmp    800ed9 <__umoddi3+0x69>
