
obj/user/faultbadhandler:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 3c 01 00 00       	call   800183 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 ef be ad de       	push   $0xdeadbeef
  80004f:	6a 00                	push   $0x0
  800051:	e8 36 02 00 00       	call   80028c <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800070:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800077:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  80007a:	e8 c6 00 00 00       	call   800145 <sys_getenvid>
  80007f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800084:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800087:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800091:	85 db                	test   %ebx,%ebx
  800093:	7e 07                	jle    80009c <libmain+0x37>
		binaryname = argv[0];
  800095:	8b 06                	mov    (%esi),%eax
  800097:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009c:	83 ec 08             	sub    $0x8,%esp
  80009f:	56                   	push   %esi
  8000a0:	53                   	push   %ebx
  8000a1:	e8 8d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a6:	e8 0a 00 00 00       	call   8000b5 <exit>
}
  8000ab:	83 c4 10             	add    $0x10,%esp
  8000ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b1:	5b                   	pop    %ebx
  8000b2:	5e                   	pop    %esi
  8000b3:	5d                   	pop    %ebp
  8000b4:	c3                   	ret    

008000b5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000bb:	6a 00                	push   $0x0
  8000bd:	e8 42 00 00 00       	call   800104 <sys_env_destroy>
}
  8000c2:	83 c4 10             	add    $0x10,%esp
  8000c5:	c9                   	leave  
  8000c6:	c3                   	ret    

008000c7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	57                   	push   %edi
  8000cb:	56                   	push   %esi
  8000cc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d8:	89 c3                	mov    %eax,%ebx
  8000da:	89 c7                	mov    %eax,%edi
  8000dc:	89 c6                	mov    %eax,%esi
  8000de:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e0:	5b                   	pop    %ebx
  8000e1:	5e                   	pop    %esi
  8000e2:	5f                   	pop    %edi
  8000e3:	5d                   	pop    %ebp
  8000e4:	c3                   	ret    

008000e5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	57                   	push   %edi
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f5:	89 d1                	mov    %edx,%ecx
  8000f7:	89 d3                	mov    %edx,%ebx
  8000f9:	89 d7                	mov    %edx,%edi
  8000fb:	89 d6                	mov    %edx,%esi
  8000fd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ff:	5b                   	pop    %ebx
  800100:	5e                   	pop    %esi
  800101:	5f                   	pop    %edi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	57                   	push   %edi
  800108:	56                   	push   %esi
  800109:	53                   	push   %ebx
  80010a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800112:	b8 03 00 00 00       	mov    $0x3,%eax
  800117:	8b 55 08             	mov    0x8(%ebp),%edx
  80011a:	89 cb                	mov    %ecx,%ebx
  80011c:	89 cf                	mov    %ecx,%edi
  80011e:	89 ce                	mov    %ecx,%esi
  800120:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800122:	85 c0                	test   %eax,%eax
  800124:	7e 17                	jle    80013d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800126:	83 ec 0c             	sub    $0xc,%esp
  800129:	50                   	push   %eax
  80012a:	6a 03                	push   $0x3
  80012c:	68 ca 0f 80 00       	push   $0x800fca
  800131:	6a 23                	push   $0x23
  800133:	68 e7 0f 80 00       	push   $0x800fe7
  800138:	e8 f5 01 00 00       	call   800332 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5f                   	pop    %edi
  800143:	5d                   	pop    %ebp
  800144:	c3                   	ret    

00800145 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	57                   	push   %edi
  800149:	56                   	push   %esi
  80014a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014b:	ba 00 00 00 00       	mov    $0x0,%edx
  800150:	b8 02 00 00 00       	mov    $0x2,%eax
  800155:	89 d1                	mov    %edx,%ecx
  800157:	89 d3                	mov    %edx,%ebx
  800159:	89 d7                	mov    %edx,%edi
  80015b:	89 d6                	mov    %edx,%esi
  80015d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015f:	5b                   	pop    %ebx
  800160:	5e                   	pop    %esi
  800161:	5f                   	pop    %edi
  800162:	5d                   	pop    %ebp
  800163:	c3                   	ret    

00800164 <sys_yield>:

void
sys_yield(void)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	57                   	push   %edi
  800168:	56                   	push   %esi
  800169:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016a:	ba 00 00 00 00       	mov    $0x0,%edx
  80016f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800174:	89 d1                	mov    %edx,%ecx
  800176:	89 d3                	mov    %edx,%ebx
  800178:	89 d7                	mov    %edx,%edi
  80017a:	89 d6                	mov    %edx,%esi
  80017c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017e:	5b                   	pop    %ebx
  80017f:	5e                   	pop    %esi
  800180:	5f                   	pop    %edi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018c:	be 00 00 00 00       	mov    $0x0,%esi
  800191:	b8 04 00 00 00       	mov    $0x4,%eax
  800196:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800199:	8b 55 08             	mov    0x8(%ebp),%edx
  80019c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019f:	89 f7                	mov    %esi,%edi
  8001a1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a3:	85 c0                	test   %eax,%eax
  8001a5:	7e 17                	jle    8001be <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	50                   	push   %eax
  8001ab:	6a 04                	push   $0x4
  8001ad:	68 ca 0f 80 00       	push   $0x800fca
  8001b2:	6a 23                	push   $0x23
  8001b4:	68 e7 0f 80 00       	push   $0x800fe7
  8001b9:	e8 74 01 00 00       	call   800332 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c1:	5b                   	pop    %ebx
  8001c2:	5e                   	pop    %esi
  8001c3:	5f                   	pop    %edi
  8001c4:	5d                   	pop    %ebp
  8001c5:	c3                   	ret    

008001c6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	57                   	push   %edi
  8001ca:	56                   	push   %esi
  8001cb:	53                   	push   %ebx
  8001cc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cf:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001dd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e5:	85 c0                	test   %eax,%eax
  8001e7:	7e 17                	jle    800200 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	50                   	push   %eax
  8001ed:	6a 05                	push   $0x5
  8001ef:	68 ca 0f 80 00       	push   $0x800fca
  8001f4:	6a 23                	push   $0x23
  8001f6:	68 e7 0f 80 00       	push   $0x800fe7
  8001fb:	e8 32 01 00 00       	call   800332 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800200:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800203:	5b                   	pop    %ebx
  800204:	5e                   	pop    %esi
  800205:	5f                   	pop    %edi
  800206:	5d                   	pop    %ebp
  800207:	c3                   	ret    

00800208 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800208:	55                   	push   %ebp
  800209:	89 e5                	mov    %esp,%ebp
  80020b:	57                   	push   %edi
  80020c:	56                   	push   %esi
  80020d:	53                   	push   %ebx
  80020e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800211:	bb 00 00 00 00       	mov    $0x0,%ebx
  800216:	b8 06 00 00 00       	mov    $0x6,%eax
  80021b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021e:	8b 55 08             	mov    0x8(%ebp),%edx
  800221:	89 df                	mov    %ebx,%edi
  800223:	89 de                	mov    %ebx,%esi
  800225:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800227:	85 c0                	test   %eax,%eax
  800229:	7e 17                	jle    800242 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	50                   	push   %eax
  80022f:	6a 06                	push   $0x6
  800231:	68 ca 0f 80 00       	push   $0x800fca
  800236:	6a 23                	push   $0x23
  800238:	68 e7 0f 80 00       	push   $0x800fe7
  80023d:	e8 f0 00 00 00       	call   800332 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800242:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800245:	5b                   	pop    %ebx
  800246:	5e                   	pop    %esi
  800247:	5f                   	pop    %edi
  800248:	5d                   	pop    %ebp
  800249:	c3                   	ret    

0080024a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	57                   	push   %edi
  80024e:	56                   	push   %esi
  80024f:	53                   	push   %ebx
  800250:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800253:	bb 00 00 00 00       	mov    $0x0,%ebx
  800258:	b8 08 00 00 00       	mov    $0x8,%eax
  80025d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800260:	8b 55 08             	mov    0x8(%ebp),%edx
  800263:	89 df                	mov    %ebx,%edi
  800265:	89 de                	mov    %ebx,%esi
  800267:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800269:	85 c0                	test   %eax,%eax
  80026b:	7e 17                	jle    800284 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026d:	83 ec 0c             	sub    $0xc,%esp
  800270:	50                   	push   %eax
  800271:	6a 08                	push   $0x8
  800273:	68 ca 0f 80 00       	push   $0x800fca
  800278:	6a 23                	push   $0x23
  80027a:	68 e7 0f 80 00       	push   $0x800fe7
  80027f:	e8 ae 00 00 00       	call   800332 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800284:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800287:	5b                   	pop    %ebx
  800288:	5e                   	pop    %esi
  800289:	5f                   	pop    %edi
  80028a:	5d                   	pop    %ebp
  80028b:	c3                   	ret    

0080028c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	57                   	push   %edi
  800290:	56                   	push   %esi
  800291:	53                   	push   %ebx
  800292:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800295:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029a:	b8 09 00 00 00       	mov    $0x9,%eax
  80029f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a5:	89 df                	mov    %ebx,%edi
  8002a7:	89 de                	mov    %ebx,%esi
  8002a9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ab:	85 c0                	test   %eax,%eax
  8002ad:	7e 17                	jle    8002c6 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002af:	83 ec 0c             	sub    $0xc,%esp
  8002b2:	50                   	push   %eax
  8002b3:	6a 09                	push   $0x9
  8002b5:	68 ca 0f 80 00       	push   $0x800fca
  8002ba:	6a 23                	push   $0x23
  8002bc:	68 e7 0f 80 00       	push   $0x800fe7
  8002c1:	e8 6c 00 00 00       	call   800332 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c9:	5b                   	pop    %ebx
  8002ca:	5e                   	pop    %esi
  8002cb:	5f                   	pop    %edi
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	57                   	push   %edi
  8002d2:	56                   	push   %esi
  8002d3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d4:	be 00 00 00 00       	mov    $0x0,%esi
  8002d9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002e7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ea:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002ec:	5b                   	pop    %ebx
  8002ed:	5e                   	pop    %esi
  8002ee:	5f                   	pop    %edi
  8002ef:	5d                   	pop    %ebp
  8002f0:	c3                   	ret    

008002f1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	57                   	push   %edi
  8002f5:	56                   	push   %esi
  8002f6:	53                   	push   %ebx
  8002f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800304:	8b 55 08             	mov    0x8(%ebp),%edx
  800307:	89 cb                	mov    %ecx,%ebx
  800309:	89 cf                	mov    %ecx,%edi
  80030b:	89 ce                	mov    %ecx,%esi
  80030d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80030f:	85 c0                	test   %eax,%eax
  800311:	7e 17                	jle    80032a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800313:	83 ec 0c             	sub    $0xc,%esp
  800316:	50                   	push   %eax
  800317:	6a 0c                	push   $0xc
  800319:	68 ca 0f 80 00       	push   $0x800fca
  80031e:	6a 23                	push   $0x23
  800320:	68 e7 0f 80 00       	push   $0x800fe7
  800325:	e8 08 00 00 00       	call   800332 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80032a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032d:	5b                   	pop    %ebx
  80032e:	5e                   	pop    %esi
  80032f:	5f                   	pop    %edi
  800330:	5d                   	pop    %ebp
  800331:	c3                   	ret    

00800332 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800337:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80033a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800340:	e8 00 fe ff ff       	call   800145 <sys_getenvid>
  800345:	83 ec 0c             	sub    $0xc,%esp
  800348:	ff 75 0c             	pushl  0xc(%ebp)
  80034b:	ff 75 08             	pushl  0x8(%ebp)
  80034e:	56                   	push   %esi
  80034f:	50                   	push   %eax
  800350:	68 f8 0f 80 00       	push   $0x800ff8
  800355:	e8 b1 00 00 00       	call   80040b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80035a:	83 c4 18             	add    $0x18,%esp
  80035d:	53                   	push   %ebx
  80035e:	ff 75 10             	pushl  0x10(%ebp)
  800361:	e8 54 00 00 00       	call   8003ba <vcprintf>
	cprintf("\n");
  800366:	c7 04 24 50 10 80 00 	movl   $0x801050,(%esp)
  80036d:	e8 99 00 00 00       	call   80040b <cprintf>
  800372:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800375:	cc                   	int3   
  800376:	eb fd                	jmp    800375 <_panic+0x43>

00800378 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	53                   	push   %ebx
  80037c:	83 ec 04             	sub    $0x4,%esp
  80037f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800382:	8b 13                	mov    (%ebx),%edx
  800384:	8d 42 01             	lea    0x1(%edx),%eax
  800387:	89 03                	mov    %eax,(%ebx)
  800389:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800390:	3d ff 00 00 00       	cmp    $0xff,%eax
  800395:	75 1a                	jne    8003b1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800397:	83 ec 08             	sub    $0x8,%esp
  80039a:	68 ff 00 00 00       	push   $0xff
  80039f:	8d 43 08             	lea    0x8(%ebx),%eax
  8003a2:	50                   	push   %eax
  8003a3:	e8 1f fd ff ff       	call   8000c7 <sys_cputs>
		b->idx = 0;
  8003a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003ae:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003b1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003b8:	c9                   	leave  
  8003b9:	c3                   	ret    

008003ba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003c3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003ca:	00 00 00 
	b.cnt = 0;
  8003cd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003d4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003d7:	ff 75 0c             	pushl  0xc(%ebp)
  8003da:	ff 75 08             	pushl  0x8(%ebp)
  8003dd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003e3:	50                   	push   %eax
  8003e4:	68 78 03 80 00       	push   $0x800378
  8003e9:	e8 54 01 00 00       	call   800542 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ee:	83 c4 08             	add    $0x8,%esp
  8003f1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003f7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003fd:	50                   	push   %eax
  8003fe:	e8 c4 fc ff ff       	call   8000c7 <sys_cputs>

	return b.cnt;
}
  800403:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800409:	c9                   	leave  
  80040a:	c3                   	ret    

0080040b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800411:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800414:	50                   	push   %eax
  800415:	ff 75 08             	pushl  0x8(%ebp)
  800418:	e8 9d ff ff ff       	call   8003ba <vcprintf>
	va_end(ap);

	return cnt;
}
  80041d:	c9                   	leave  
  80041e:	c3                   	ret    

0080041f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80041f:	55                   	push   %ebp
  800420:	89 e5                	mov    %esp,%ebp
  800422:	57                   	push   %edi
  800423:	56                   	push   %esi
  800424:	53                   	push   %ebx
  800425:	83 ec 1c             	sub    $0x1c,%esp
  800428:	89 c7                	mov    %eax,%edi
  80042a:	89 d6                	mov    %edx,%esi
  80042c:	8b 45 08             	mov    0x8(%ebp),%eax
  80042f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800432:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800435:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800438:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80043b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800440:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800443:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800446:	39 d3                	cmp    %edx,%ebx
  800448:	72 05                	jb     80044f <printnum+0x30>
  80044a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80044d:	77 45                	ja     800494 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80044f:	83 ec 0c             	sub    $0xc,%esp
  800452:	ff 75 18             	pushl  0x18(%ebp)
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80045b:	53                   	push   %ebx
  80045c:	ff 75 10             	pushl  0x10(%ebp)
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	ff 75 e4             	pushl  -0x1c(%ebp)
  800465:	ff 75 e0             	pushl  -0x20(%ebp)
  800468:	ff 75 dc             	pushl  -0x24(%ebp)
  80046b:	ff 75 d8             	pushl  -0x28(%ebp)
  80046e:	e8 ad 08 00 00       	call   800d20 <__udivdi3>
  800473:	83 c4 18             	add    $0x18,%esp
  800476:	52                   	push   %edx
  800477:	50                   	push   %eax
  800478:	89 f2                	mov    %esi,%edx
  80047a:	89 f8                	mov    %edi,%eax
  80047c:	e8 9e ff ff ff       	call   80041f <printnum>
  800481:	83 c4 20             	add    $0x20,%esp
  800484:	eb 18                	jmp    80049e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	56                   	push   %esi
  80048a:	ff 75 18             	pushl  0x18(%ebp)
  80048d:	ff d7                	call   *%edi
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	eb 03                	jmp    800497 <printnum+0x78>
  800494:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800497:	83 eb 01             	sub    $0x1,%ebx
  80049a:	85 db                	test   %ebx,%ebx
  80049c:	7f e8                	jg     800486 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	56                   	push   %esi
  8004a2:	83 ec 04             	sub    $0x4,%esp
  8004a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b1:	e8 9a 09 00 00       	call   800e50 <__umoddi3>
  8004b6:	83 c4 14             	add    $0x14,%esp
  8004b9:	0f be 80 1c 10 80 00 	movsbl 0x80101c(%eax),%eax
  8004c0:	50                   	push   %eax
  8004c1:	ff d7                	call   *%edi
}
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004c9:	5b                   	pop    %ebx
  8004ca:	5e                   	pop    %esi
  8004cb:	5f                   	pop    %edi
  8004cc:	5d                   	pop    %ebp
  8004cd:	c3                   	ret    

008004ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ce:	55                   	push   %ebp
  8004cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004d1:	83 fa 01             	cmp    $0x1,%edx
  8004d4:	7e 0e                	jle    8004e4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004d6:	8b 10                	mov    (%eax),%edx
  8004d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004db:	89 08                	mov    %ecx,(%eax)
  8004dd:	8b 02                	mov    (%edx),%eax
  8004df:	8b 52 04             	mov    0x4(%edx),%edx
  8004e2:	eb 22                	jmp    800506 <getuint+0x38>
	else if (lflag)
  8004e4:	85 d2                	test   %edx,%edx
  8004e6:	74 10                	je     8004f8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004e8:	8b 10                	mov    (%eax),%edx
  8004ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ed:	89 08                	mov    %ecx,(%eax)
  8004ef:	8b 02                	mov    (%edx),%eax
  8004f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f6:	eb 0e                	jmp    800506 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004f8:	8b 10                	mov    (%eax),%edx
  8004fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004fd:	89 08                	mov    %ecx,(%eax)
  8004ff:	8b 02                	mov    (%edx),%eax
  800501:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800506:	5d                   	pop    %ebp
  800507:	c3                   	ret    

00800508 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
  80050b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80050e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800512:	8b 10                	mov    (%eax),%edx
  800514:	3b 50 04             	cmp    0x4(%eax),%edx
  800517:	73 0a                	jae    800523 <sprintputch+0x1b>
		*b->buf++ = ch;
  800519:	8d 4a 01             	lea    0x1(%edx),%ecx
  80051c:	89 08                	mov    %ecx,(%eax)
  80051e:	8b 45 08             	mov    0x8(%ebp),%eax
  800521:	88 02                	mov    %al,(%edx)
}
  800523:	5d                   	pop    %ebp
  800524:	c3                   	ret    

00800525 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80052b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80052e:	50                   	push   %eax
  80052f:	ff 75 10             	pushl  0x10(%ebp)
  800532:	ff 75 0c             	pushl  0xc(%ebp)
  800535:	ff 75 08             	pushl  0x8(%ebp)
  800538:	e8 05 00 00 00       	call   800542 <vprintfmt>
	va_end(ap);
}
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	c9                   	leave  
  800541:	c3                   	ret    

00800542 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800542:	55                   	push   %ebp
  800543:	89 e5                	mov    %esp,%ebp
  800545:	57                   	push   %edi
  800546:	56                   	push   %esi
  800547:	53                   	push   %ebx
  800548:	83 ec 2c             	sub    $0x2c,%esp
  80054b:	8b 75 08             	mov    0x8(%ebp),%esi
  80054e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800551:	8b 7d 10             	mov    0x10(%ebp),%edi
  800554:	eb 12                	jmp    800568 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800556:	85 c0                	test   %eax,%eax
  800558:	0f 84 cb 03 00 00    	je     800929 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	53                   	push   %ebx
  800562:	50                   	push   %eax
  800563:	ff d6                	call   *%esi
  800565:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800568:	83 c7 01             	add    $0x1,%edi
  80056b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056f:	83 f8 25             	cmp    $0x25,%eax
  800572:	75 e2                	jne    800556 <vprintfmt+0x14>
  800574:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800578:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80057f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800586:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80058d:	ba 00 00 00 00       	mov    $0x0,%edx
  800592:	eb 07                	jmp    80059b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800594:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800597:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059b:	8d 47 01             	lea    0x1(%edi),%eax
  80059e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a1:	0f b6 07             	movzbl (%edi),%eax
  8005a4:	0f b6 c8             	movzbl %al,%ecx
  8005a7:	83 e8 23             	sub    $0x23,%eax
  8005aa:	3c 55                	cmp    $0x55,%al
  8005ac:	0f 87 5c 03 00 00    	ja     80090e <vprintfmt+0x3cc>
  8005b2:	0f b6 c0             	movzbl %al,%eax
  8005b5:	ff 24 85 00 11 80 00 	jmp    *0x801100(,%eax,4)
  8005bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005bf:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005c3:	eb d6                	jmp    80059b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005d0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005d3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005d7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005da:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005dd:	83 fa 09             	cmp    $0x9,%edx
  8005e0:	77 39                	ja     80061b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005e2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005e5:	eb e9                	jmp    8005d0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 48 04             	lea    0x4(%eax),%ecx
  8005ed:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005f0:	8b 00                	mov    (%eax),%eax
  8005f2:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005f8:	eb 27                	jmp    800621 <vprintfmt+0xdf>
  8005fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005fd:	85 c0                	test   %eax,%eax
  8005ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800604:	0f 49 c8             	cmovns %eax,%ecx
  800607:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80060d:	eb 8c                	jmp    80059b <vprintfmt+0x59>
  80060f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800612:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800619:	eb 80                	jmp    80059b <vprintfmt+0x59>
  80061b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061e:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800621:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800625:	0f 89 70 ff ff ff    	jns    80059b <vprintfmt+0x59>
				width = precision, precision = -1;
  80062b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80062e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800631:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800638:	e9 5e ff ff ff       	jmp    80059b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80063d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800640:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800643:	e9 53 ff ff ff       	jmp    80059b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8d 50 04             	lea    0x4(%eax),%edx
  80064e:	89 55 14             	mov    %edx,0x14(%ebp)
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	ff 30                	pushl  (%eax)
  800657:	ff d6                	call   *%esi
			break;
  800659:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80065f:	e9 04 ff ff ff       	jmp    800568 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8d 50 04             	lea    0x4(%eax),%edx
  80066a:	89 55 14             	mov    %edx,0x14(%ebp)
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	99                   	cltd   
  800670:	31 d0                	xor    %edx,%eax
  800672:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800674:	83 f8 09             	cmp    $0x9,%eax
  800677:	7f 0b                	jg     800684 <vprintfmt+0x142>
  800679:	8b 14 85 60 12 80 00 	mov    0x801260(,%eax,4),%edx
  800680:	85 d2                	test   %edx,%edx
  800682:	75 18                	jne    80069c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800684:	50                   	push   %eax
  800685:	68 34 10 80 00       	push   $0x801034
  80068a:	53                   	push   %ebx
  80068b:	56                   	push   %esi
  80068c:	e8 94 fe ff ff       	call   800525 <printfmt>
  800691:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800694:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800697:	e9 cc fe ff ff       	jmp    800568 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80069c:	52                   	push   %edx
  80069d:	68 3d 10 80 00       	push   $0x80103d
  8006a2:	53                   	push   %ebx
  8006a3:	56                   	push   %esi
  8006a4:	e8 7c fe ff ff       	call   800525 <printfmt>
  8006a9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006af:	e9 b4 fe ff ff       	jmp    800568 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006bf:	85 ff                	test   %edi,%edi
  8006c1:	b8 2d 10 80 00       	mov    $0x80102d,%eax
  8006c6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006cd:	0f 8e 94 00 00 00    	jle    800767 <vprintfmt+0x225>
  8006d3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006d7:	0f 84 98 00 00 00    	je     800775 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	ff 75 c8             	pushl  -0x38(%ebp)
  8006e3:	57                   	push   %edi
  8006e4:	e8 c8 02 00 00       	call   8009b1 <strnlen>
  8006e9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006ec:	29 c1                	sub    %eax,%ecx
  8006ee:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006f1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006f4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006fb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006fe:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800700:	eb 0f                	jmp    800711 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	53                   	push   %ebx
  800706:	ff 75 e0             	pushl  -0x20(%ebp)
  800709:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80070b:	83 ef 01             	sub    $0x1,%edi
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	85 ff                	test   %edi,%edi
  800713:	7f ed                	jg     800702 <vprintfmt+0x1c0>
  800715:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800718:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80071b:	85 c9                	test   %ecx,%ecx
  80071d:	b8 00 00 00 00       	mov    $0x0,%eax
  800722:	0f 49 c1             	cmovns %ecx,%eax
  800725:	29 c1                	sub    %eax,%ecx
  800727:	89 75 08             	mov    %esi,0x8(%ebp)
  80072a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80072d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800730:	89 cb                	mov    %ecx,%ebx
  800732:	eb 4d                	jmp    800781 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800734:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800738:	74 1b                	je     800755 <vprintfmt+0x213>
  80073a:	0f be c0             	movsbl %al,%eax
  80073d:	83 e8 20             	sub    $0x20,%eax
  800740:	83 f8 5e             	cmp    $0x5e,%eax
  800743:	76 10                	jbe    800755 <vprintfmt+0x213>
					putch('?', putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	6a 3f                	push   $0x3f
  80074d:	ff 55 08             	call   *0x8(%ebp)
  800750:	83 c4 10             	add    $0x10,%esp
  800753:	eb 0d                	jmp    800762 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800755:	83 ec 08             	sub    $0x8,%esp
  800758:	ff 75 0c             	pushl  0xc(%ebp)
  80075b:	52                   	push   %edx
  80075c:	ff 55 08             	call   *0x8(%ebp)
  80075f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800762:	83 eb 01             	sub    $0x1,%ebx
  800765:	eb 1a                	jmp    800781 <vprintfmt+0x23f>
  800767:	89 75 08             	mov    %esi,0x8(%ebp)
  80076a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80076d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800770:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800773:	eb 0c                	jmp    800781 <vprintfmt+0x23f>
  800775:	89 75 08             	mov    %esi,0x8(%ebp)
  800778:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80077b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80077e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800781:	83 c7 01             	add    $0x1,%edi
  800784:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800788:	0f be d0             	movsbl %al,%edx
  80078b:	85 d2                	test   %edx,%edx
  80078d:	74 23                	je     8007b2 <vprintfmt+0x270>
  80078f:	85 f6                	test   %esi,%esi
  800791:	78 a1                	js     800734 <vprintfmt+0x1f2>
  800793:	83 ee 01             	sub    $0x1,%esi
  800796:	79 9c                	jns    800734 <vprintfmt+0x1f2>
  800798:	89 df                	mov    %ebx,%edi
  80079a:	8b 75 08             	mov    0x8(%ebp),%esi
  80079d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a0:	eb 18                	jmp    8007ba <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007a2:	83 ec 08             	sub    $0x8,%esp
  8007a5:	53                   	push   %ebx
  8007a6:	6a 20                	push   $0x20
  8007a8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007aa:	83 ef 01             	sub    $0x1,%edi
  8007ad:	83 c4 10             	add    $0x10,%esp
  8007b0:	eb 08                	jmp    8007ba <vprintfmt+0x278>
  8007b2:	89 df                	mov    %ebx,%edi
  8007b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ba:	85 ff                	test   %edi,%edi
  8007bc:	7f e4                	jg     8007a2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c1:	e9 a2 fd ff ff       	jmp    800568 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c6:	83 fa 01             	cmp    $0x1,%edx
  8007c9:	7e 16                	jle    8007e1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8d 50 08             	lea    0x8(%eax),%edx
  8007d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d4:	8b 50 04             	mov    0x4(%eax),%edx
  8007d7:	8b 00                	mov    (%eax),%eax
  8007d9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007dc:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007df:	eb 32                	jmp    800813 <vprintfmt+0x2d1>
	else if (lflag)
  8007e1:	85 d2                	test   %edx,%edx
  8007e3:	74 18                	je     8007fd <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e8:	8d 50 04             	lea    0x4(%eax),%edx
  8007eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ee:	8b 00                	mov    (%eax),%eax
  8007f0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007f3:	89 c1                	mov    %eax,%ecx
  8007f5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007fb:	eb 16                	jmp    800813 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800800:	8d 50 04             	lea    0x4(%eax),%edx
  800803:	89 55 14             	mov    %edx,0x14(%ebp)
  800806:	8b 00                	mov    (%eax),%eax
  800808:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80080b:	89 c1                	mov    %eax,%ecx
  80080d:	c1 f9 1f             	sar    $0x1f,%ecx
  800810:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800813:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800816:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800819:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80081c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80081f:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800824:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800828:	0f 89 a8 00 00 00    	jns    8008d6 <vprintfmt+0x394>
				putch('-', putdat);
  80082e:	83 ec 08             	sub    $0x8,%esp
  800831:	53                   	push   %ebx
  800832:	6a 2d                	push   $0x2d
  800834:	ff d6                	call   *%esi
				num = -(long long) num;
  800836:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800839:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80083c:	f7 d8                	neg    %eax
  80083e:	83 d2 00             	adc    $0x0,%edx
  800841:	f7 da                	neg    %edx
  800843:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800846:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800849:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80084c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800851:	e9 80 00 00 00       	jmp    8008d6 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800856:	8d 45 14             	lea    0x14(%ebp),%eax
  800859:	e8 70 fc ff ff       	call   8004ce <getuint>
  80085e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800861:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800864:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800869:	eb 6b                	jmp    8008d6 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80086b:	8d 45 14             	lea    0x14(%ebp),%eax
  80086e:	e8 5b fc ff ff       	call   8004ce <getuint>
  800873:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800876:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800879:	6a 04                	push   $0x4
  80087b:	6a 03                	push   $0x3
  80087d:	6a 01                	push   $0x1
  80087f:	68 40 10 80 00       	push   $0x801040
  800884:	e8 82 fb ff ff       	call   80040b <cprintf>
			goto number;
  800889:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  80088c:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  800891:	eb 43                	jmp    8008d6 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  800893:	83 ec 08             	sub    $0x8,%esp
  800896:	53                   	push   %ebx
  800897:	6a 30                	push   $0x30
  800899:	ff d6                	call   *%esi
			putch('x', putdat);
  80089b:	83 c4 08             	add    $0x8,%esp
  80089e:	53                   	push   %ebx
  80089f:	6a 78                	push   $0x78
  8008a1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a6:	8d 50 04             	lea    0x4(%eax),%edx
  8008a9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008ac:	8b 00                	mov    (%eax),%eax
  8008ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8008b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008b9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008bc:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008c1:	eb 13                	jmp    8008d6 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c6:	e8 03 fc ff ff       	call   8004ce <getuint>
  8008cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008d1:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d6:	83 ec 0c             	sub    $0xc,%esp
  8008d9:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8008dd:	52                   	push   %edx
  8008de:	ff 75 e0             	pushl  -0x20(%ebp)
  8008e1:	50                   	push   %eax
  8008e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8008e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8008e8:	89 da                	mov    %ebx,%edx
  8008ea:	89 f0                	mov    %esi,%eax
  8008ec:	e8 2e fb ff ff       	call   80041f <printnum>

			break;
  8008f1:	83 c4 20             	add    $0x20,%esp
  8008f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008f7:	e9 6c fc ff ff       	jmp    800568 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008fc:	83 ec 08             	sub    $0x8,%esp
  8008ff:	53                   	push   %ebx
  800900:	51                   	push   %ecx
  800901:	ff d6                	call   *%esi
			break;
  800903:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800906:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800909:	e9 5a fc ff ff       	jmp    800568 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80090e:	83 ec 08             	sub    $0x8,%esp
  800911:	53                   	push   %ebx
  800912:	6a 25                	push   $0x25
  800914:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	eb 03                	jmp    80091e <vprintfmt+0x3dc>
  80091b:	83 ef 01             	sub    $0x1,%edi
  80091e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800922:	75 f7                	jne    80091b <vprintfmt+0x3d9>
  800924:	e9 3f fc ff ff       	jmp    800568 <vprintfmt+0x26>
			break;
		}

	}

}
  800929:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80092c:	5b                   	pop    %ebx
  80092d:	5e                   	pop    %esi
  80092e:	5f                   	pop    %edi
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    

00800931 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	83 ec 18             	sub    $0x18,%esp
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80093d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800940:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800944:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800947:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80094e:	85 c0                	test   %eax,%eax
  800950:	74 26                	je     800978 <vsnprintf+0x47>
  800952:	85 d2                	test   %edx,%edx
  800954:	7e 22                	jle    800978 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800956:	ff 75 14             	pushl  0x14(%ebp)
  800959:	ff 75 10             	pushl  0x10(%ebp)
  80095c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80095f:	50                   	push   %eax
  800960:	68 08 05 80 00       	push   $0x800508
  800965:	e8 d8 fb ff ff       	call   800542 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80096a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80096d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800970:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800973:	83 c4 10             	add    $0x10,%esp
  800976:	eb 05                	jmp    80097d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800978:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800985:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800988:	50                   	push   %eax
  800989:	ff 75 10             	pushl  0x10(%ebp)
  80098c:	ff 75 0c             	pushl  0xc(%ebp)
  80098f:	ff 75 08             	pushl  0x8(%ebp)
  800992:	e8 9a ff ff ff       	call   800931 <vsnprintf>
	va_end(ap);

	return rc;
}
  800997:	c9                   	leave  
  800998:	c3                   	ret    

00800999 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80099f:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a4:	eb 03                	jmp    8009a9 <strlen+0x10>
		n++;
  8009a6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ad:	75 f7                	jne    8009a6 <strlen+0xd>
		n++;
	return n;
}
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bf:	eb 03                	jmp    8009c4 <strnlen+0x13>
		n++;
  8009c1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c4:	39 c2                	cmp    %eax,%edx
  8009c6:	74 08                	je     8009d0 <strnlen+0x1f>
  8009c8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009cc:	75 f3                	jne    8009c1 <strnlen+0x10>
  8009ce:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	53                   	push   %ebx
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009dc:	89 c2                	mov    %eax,%edx
  8009de:	83 c2 01             	add    $0x1,%edx
  8009e1:	83 c1 01             	add    $0x1,%ecx
  8009e4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009e8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009eb:	84 db                	test   %bl,%bl
  8009ed:	75 ef                	jne    8009de <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009ef:	5b                   	pop    %ebx
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	53                   	push   %ebx
  8009f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f9:	53                   	push   %ebx
  8009fa:	e8 9a ff ff ff       	call   800999 <strlen>
  8009ff:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a02:	ff 75 0c             	pushl  0xc(%ebp)
  800a05:	01 d8                	add    %ebx,%eax
  800a07:	50                   	push   %eax
  800a08:	e8 c5 ff ff ff       	call   8009d2 <strcpy>
	return dst;
}
  800a0d:	89 d8                	mov    %ebx,%eax
  800a0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a12:	c9                   	leave  
  800a13:	c3                   	ret    

00800a14 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1f:	89 f3                	mov    %esi,%ebx
  800a21:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a24:	89 f2                	mov    %esi,%edx
  800a26:	eb 0f                	jmp    800a37 <strncpy+0x23>
		*dst++ = *src;
  800a28:	83 c2 01             	add    $0x1,%edx
  800a2b:	0f b6 01             	movzbl (%ecx),%eax
  800a2e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a31:	80 39 01             	cmpb   $0x1,(%ecx)
  800a34:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a37:	39 da                	cmp    %ebx,%edx
  800a39:	75 ed                	jne    800a28 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a3b:	89 f0                	mov    %esi,%eax
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
  800a46:	8b 75 08             	mov    0x8(%ebp),%esi
  800a49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4c:	8b 55 10             	mov    0x10(%ebp),%edx
  800a4f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a51:	85 d2                	test   %edx,%edx
  800a53:	74 21                	je     800a76 <strlcpy+0x35>
  800a55:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a59:	89 f2                	mov    %esi,%edx
  800a5b:	eb 09                	jmp    800a66 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a5d:	83 c2 01             	add    $0x1,%edx
  800a60:	83 c1 01             	add    $0x1,%ecx
  800a63:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a66:	39 c2                	cmp    %eax,%edx
  800a68:	74 09                	je     800a73 <strlcpy+0x32>
  800a6a:	0f b6 19             	movzbl (%ecx),%ebx
  800a6d:	84 db                	test   %bl,%bl
  800a6f:	75 ec                	jne    800a5d <strlcpy+0x1c>
  800a71:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a73:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a76:	29 f0                	sub    %esi,%eax
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a82:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a85:	eb 06                	jmp    800a8d <strcmp+0x11>
		p++, q++;
  800a87:	83 c1 01             	add    $0x1,%ecx
  800a8a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a8d:	0f b6 01             	movzbl (%ecx),%eax
  800a90:	84 c0                	test   %al,%al
  800a92:	74 04                	je     800a98 <strcmp+0x1c>
  800a94:	3a 02                	cmp    (%edx),%al
  800a96:	74 ef                	je     800a87 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a98:	0f b6 c0             	movzbl %al,%eax
  800a9b:	0f b6 12             	movzbl (%edx),%edx
  800a9e:	29 d0                	sub    %edx,%eax
}
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	53                   	push   %ebx
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aac:	89 c3                	mov    %eax,%ebx
  800aae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ab1:	eb 06                	jmp    800ab9 <strncmp+0x17>
		n--, p++, q++;
  800ab3:	83 c0 01             	add    $0x1,%eax
  800ab6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab9:	39 d8                	cmp    %ebx,%eax
  800abb:	74 15                	je     800ad2 <strncmp+0x30>
  800abd:	0f b6 08             	movzbl (%eax),%ecx
  800ac0:	84 c9                	test   %cl,%cl
  800ac2:	74 04                	je     800ac8 <strncmp+0x26>
  800ac4:	3a 0a                	cmp    (%edx),%cl
  800ac6:	74 eb                	je     800ab3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac8:	0f b6 00             	movzbl (%eax),%eax
  800acb:	0f b6 12             	movzbl (%edx),%edx
  800ace:	29 d0                	sub    %edx,%eax
  800ad0:	eb 05                	jmp    800ad7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae4:	eb 07                	jmp    800aed <strchr+0x13>
		if (*s == c)
  800ae6:	38 ca                	cmp    %cl,%dl
  800ae8:	74 0f                	je     800af9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aea:	83 c0 01             	add    $0x1,%eax
  800aed:	0f b6 10             	movzbl (%eax),%edx
  800af0:	84 d2                	test   %dl,%dl
  800af2:	75 f2                	jne    800ae6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800af4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b05:	eb 03                	jmp    800b0a <strfind+0xf>
  800b07:	83 c0 01             	add    $0x1,%eax
  800b0a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b0d:	38 ca                	cmp    %cl,%dl
  800b0f:	74 04                	je     800b15 <strfind+0x1a>
  800b11:	84 d2                	test   %dl,%dl
  800b13:	75 f2                	jne    800b07 <strfind+0xc>
			break;
	return (char *) s;
}
  800b15:	5d                   	pop    %ebp
  800b16:	c3                   	ret    

00800b17 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	57                   	push   %edi
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
  800b1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b23:	85 c9                	test   %ecx,%ecx
  800b25:	74 36                	je     800b5d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b27:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b2d:	75 28                	jne    800b57 <memset+0x40>
  800b2f:	f6 c1 03             	test   $0x3,%cl
  800b32:	75 23                	jne    800b57 <memset+0x40>
		c &= 0xFF;
  800b34:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b38:	89 d3                	mov    %edx,%ebx
  800b3a:	c1 e3 08             	shl    $0x8,%ebx
  800b3d:	89 d6                	mov    %edx,%esi
  800b3f:	c1 e6 18             	shl    $0x18,%esi
  800b42:	89 d0                	mov    %edx,%eax
  800b44:	c1 e0 10             	shl    $0x10,%eax
  800b47:	09 f0                	or     %esi,%eax
  800b49:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b4b:	89 d8                	mov    %ebx,%eax
  800b4d:	09 d0                	or     %edx,%eax
  800b4f:	c1 e9 02             	shr    $0x2,%ecx
  800b52:	fc                   	cld    
  800b53:	f3 ab                	rep stos %eax,%es:(%edi)
  800b55:	eb 06                	jmp    800b5d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5a:	fc                   	cld    
  800b5b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b5d:	89 f8                	mov    %edi,%eax
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b72:	39 c6                	cmp    %eax,%esi
  800b74:	73 35                	jae    800bab <memmove+0x47>
  800b76:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b79:	39 d0                	cmp    %edx,%eax
  800b7b:	73 2e                	jae    800bab <memmove+0x47>
		s += n;
		d += n;
  800b7d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b80:	89 d6                	mov    %edx,%esi
  800b82:	09 fe                	or     %edi,%esi
  800b84:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b8a:	75 13                	jne    800b9f <memmove+0x3b>
  800b8c:	f6 c1 03             	test   $0x3,%cl
  800b8f:	75 0e                	jne    800b9f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b91:	83 ef 04             	sub    $0x4,%edi
  800b94:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b97:	c1 e9 02             	shr    $0x2,%ecx
  800b9a:	fd                   	std    
  800b9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9d:	eb 09                	jmp    800ba8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b9f:	83 ef 01             	sub    $0x1,%edi
  800ba2:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ba5:	fd                   	std    
  800ba6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba8:	fc                   	cld    
  800ba9:	eb 1d                	jmp    800bc8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bab:	89 f2                	mov    %esi,%edx
  800bad:	09 c2                	or     %eax,%edx
  800baf:	f6 c2 03             	test   $0x3,%dl
  800bb2:	75 0f                	jne    800bc3 <memmove+0x5f>
  800bb4:	f6 c1 03             	test   $0x3,%cl
  800bb7:	75 0a                	jne    800bc3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bb9:	c1 e9 02             	shr    $0x2,%ecx
  800bbc:	89 c7                	mov    %eax,%edi
  800bbe:	fc                   	cld    
  800bbf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bc1:	eb 05                	jmp    800bc8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bc3:	89 c7                	mov    %eax,%edi
  800bc5:	fc                   	cld    
  800bc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bcf:	ff 75 10             	pushl  0x10(%ebp)
  800bd2:	ff 75 0c             	pushl  0xc(%ebp)
  800bd5:	ff 75 08             	pushl  0x8(%ebp)
  800bd8:	e8 87 ff ff ff       	call   800b64 <memmove>
}
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	8b 45 08             	mov    0x8(%ebp),%eax
  800be7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bea:	89 c6                	mov    %eax,%esi
  800bec:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bef:	eb 1a                	jmp    800c0b <memcmp+0x2c>
		if (*s1 != *s2)
  800bf1:	0f b6 08             	movzbl (%eax),%ecx
  800bf4:	0f b6 1a             	movzbl (%edx),%ebx
  800bf7:	38 d9                	cmp    %bl,%cl
  800bf9:	74 0a                	je     800c05 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bfb:	0f b6 c1             	movzbl %cl,%eax
  800bfe:	0f b6 db             	movzbl %bl,%ebx
  800c01:	29 d8                	sub    %ebx,%eax
  800c03:	eb 0f                	jmp    800c14 <memcmp+0x35>
		s1++, s2++;
  800c05:	83 c0 01             	add    $0x1,%eax
  800c08:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0b:	39 f0                	cmp    %esi,%eax
  800c0d:	75 e2                	jne    800bf1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	53                   	push   %ebx
  800c1c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c1f:	89 c1                	mov    %eax,%ecx
  800c21:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c24:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c28:	eb 0a                	jmp    800c34 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c2a:	0f b6 10             	movzbl (%eax),%edx
  800c2d:	39 da                	cmp    %ebx,%edx
  800c2f:	74 07                	je     800c38 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c31:	83 c0 01             	add    $0x1,%eax
  800c34:	39 c8                	cmp    %ecx,%eax
  800c36:	72 f2                	jb     800c2a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c38:	5b                   	pop    %ebx
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c44:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c47:	eb 03                	jmp    800c4c <strtol+0x11>
		s++;
  800c49:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4c:	0f b6 01             	movzbl (%ecx),%eax
  800c4f:	3c 20                	cmp    $0x20,%al
  800c51:	74 f6                	je     800c49 <strtol+0xe>
  800c53:	3c 09                	cmp    $0x9,%al
  800c55:	74 f2                	je     800c49 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c57:	3c 2b                	cmp    $0x2b,%al
  800c59:	75 0a                	jne    800c65 <strtol+0x2a>
		s++;
  800c5b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c5e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c63:	eb 11                	jmp    800c76 <strtol+0x3b>
  800c65:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c6a:	3c 2d                	cmp    $0x2d,%al
  800c6c:	75 08                	jne    800c76 <strtol+0x3b>
		s++, neg = 1;
  800c6e:	83 c1 01             	add    $0x1,%ecx
  800c71:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c76:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c7c:	75 15                	jne    800c93 <strtol+0x58>
  800c7e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c81:	75 10                	jne    800c93 <strtol+0x58>
  800c83:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c87:	75 7c                	jne    800d05 <strtol+0xca>
		s += 2, base = 16;
  800c89:	83 c1 02             	add    $0x2,%ecx
  800c8c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c91:	eb 16                	jmp    800ca9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c93:	85 db                	test   %ebx,%ebx
  800c95:	75 12                	jne    800ca9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c97:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c9c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c9f:	75 08                	jne    800ca9 <strtol+0x6e>
		s++, base = 8;
  800ca1:	83 c1 01             	add    $0x1,%ecx
  800ca4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ca9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cae:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cb1:	0f b6 11             	movzbl (%ecx),%edx
  800cb4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cb7:	89 f3                	mov    %esi,%ebx
  800cb9:	80 fb 09             	cmp    $0x9,%bl
  800cbc:	77 08                	ja     800cc6 <strtol+0x8b>
			dig = *s - '0';
  800cbe:	0f be d2             	movsbl %dl,%edx
  800cc1:	83 ea 30             	sub    $0x30,%edx
  800cc4:	eb 22                	jmp    800ce8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cc6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cc9:	89 f3                	mov    %esi,%ebx
  800ccb:	80 fb 19             	cmp    $0x19,%bl
  800cce:	77 08                	ja     800cd8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cd0:	0f be d2             	movsbl %dl,%edx
  800cd3:	83 ea 57             	sub    $0x57,%edx
  800cd6:	eb 10                	jmp    800ce8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cd8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cdb:	89 f3                	mov    %esi,%ebx
  800cdd:	80 fb 19             	cmp    $0x19,%bl
  800ce0:	77 16                	ja     800cf8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ce2:	0f be d2             	movsbl %dl,%edx
  800ce5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ce8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ceb:	7d 0b                	jge    800cf8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ced:	83 c1 01             	add    $0x1,%ecx
  800cf0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cf4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cf6:	eb b9                	jmp    800cb1 <strtol+0x76>

	if (endptr)
  800cf8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cfc:	74 0d                	je     800d0b <strtol+0xd0>
		*endptr = (char *) s;
  800cfe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d01:	89 0e                	mov    %ecx,(%esi)
  800d03:	eb 06                	jmp    800d0b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d05:	85 db                	test   %ebx,%ebx
  800d07:	74 98                	je     800ca1 <strtol+0x66>
  800d09:	eb 9e                	jmp    800ca9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d0b:	89 c2                	mov    %eax,%edx
  800d0d:	f7 da                	neg    %edx
  800d0f:	85 ff                	test   %edi,%edi
  800d11:	0f 45 c2             	cmovne %edx,%eax
}
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    
  800d19:	66 90                	xchg   %ax,%ax
  800d1b:	66 90                	xchg   %ax,%ax
  800d1d:	66 90                	xchg   %ax,%ax
  800d1f:	90                   	nop

00800d20 <__udivdi3>:
  800d20:	55                   	push   %ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 1c             	sub    $0x1c,%esp
  800d27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d37:	85 f6                	test   %esi,%esi
  800d39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d3d:	89 ca                	mov    %ecx,%edx
  800d3f:	89 f8                	mov    %edi,%eax
  800d41:	75 3d                	jne    800d80 <__udivdi3+0x60>
  800d43:	39 cf                	cmp    %ecx,%edi
  800d45:	0f 87 c5 00 00 00    	ja     800e10 <__udivdi3+0xf0>
  800d4b:	85 ff                	test   %edi,%edi
  800d4d:	89 fd                	mov    %edi,%ebp
  800d4f:	75 0b                	jne    800d5c <__udivdi3+0x3c>
  800d51:	b8 01 00 00 00       	mov    $0x1,%eax
  800d56:	31 d2                	xor    %edx,%edx
  800d58:	f7 f7                	div    %edi
  800d5a:	89 c5                	mov    %eax,%ebp
  800d5c:	89 c8                	mov    %ecx,%eax
  800d5e:	31 d2                	xor    %edx,%edx
  800d60:	f7 f5                	div    %ebp
  800d62:	89 c1                	mov    %eax,%ecx
  800d64:	89 d8                	mov    %ebx,%eax
  800d66:	89 cf                	mov    %ecx,%edi
  800d68:	f7 f5                	div    %ebp
  800d6a:	89 c3                	mov    %eax,%ebx
  800d6c:	89 d8                	mov    %ebx,%eax
  800d6e:	89 fa                	mov    %edi,%edx
  800d70:	83 c4 1c             	add    $0x1c,%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    
  800d78:	90                   	nop
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	39 ce                	cmp    %ecx,%esi
  800d82:	77 74                	ja     800df8 <__udivdi3+0xd8>
  800d84:	0f bd fe             	bsr    %esi,%edi
  800d87:	83 f7 1f             	xor    $0x1f,%edi
  800d8a:	0f 84 98 00 00 00    	je     800e28 <__udivdi3+0x108>
  800d90:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d95:	89 f9                	mov    %edi,%ecx
  800d97:	89 c5                	mov    %eax,%ebp
  800d99:	29 fb                	sub    %edi,%ebx
  800d9b:	d3 e6                	shl    %cl,%esi
  800d9d:	89 d9                	mov    %ebx,%ecx
  800d9f:	d3 ed                	shr    %cl,%ebp
  800da1:	89 f9                	mov    %edi,%ecx
  800da3:	d3 e0                	shl    %cl,%eax
  800da5:	09 ee                	or     %ebp,%esi
  800da7:	89 d9                	mov    %ebx,%ecx
  800da9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dad:	89 d5                	mov    %edx,%ebp
  800daf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800db3:	d3 ed                	shr    %cl,%ebp
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	d3 e2                	shl    %cl,%edx
  800db9:	89 d9                	mov    %ebx,%ecx
  800dbb:	d3 e8                	shr    %cl,%eax
  800dbd:	09 c2                	or     %eax,%edx
  800dbf:	89 d0                	mov    %edx,%eax
  800dc1:	89 ea                	mov    %ebp,%edx
  800dc3:	f7 f6                	div    %esi
  800dc5:	89 d5                	mov    %edx,%ebp
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	f7 64 24 0c          	mull   0xc(%esp)
  800dcd:	39 d5                	cmp    %edx,%ebp
  800dcf:	72 10                	jb     800de1 <__udivdi3+0xc1>
  800dd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800dd5:	89 f9                	mov    %edi,%ecx
  800dd7:	d3 e6                	shl    %cl,%esi
  800dd9:	39 c6                	cmp    %eax,%esi
  800ddb:	73 07                	jae    800de4 <__udivdi3+0xc4>
  800ddd:	39 d5                	cmp    %edx,%ebp
  800ddf:	75 03                	jne    800de4 <__udivdi3+0xc4>
  800de1:	83 eb 01             	sub    $0x1,%ebx
  800de4:	31 ff                	xor    %edi,%edi
  800de6:	89 d8                	mov    %ebx,%eax
  800de8:	89 fa                	mov    %edi,%edx
  800dea:	83 c4 1c             	add    $0x1c,%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    
  800df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df8:	31 ff                	xor    %edi,%edi
  800dfa:	31 db                	xor    %ebx,%ebx
  800dfc:	89 d8                	mov    %ebx,%eax
  800dfe:	89 fa                	mov    %edi,%edx
  800e00:	83 c4 1c             	add    $0x1c,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
  800e08:	90                   	nop
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	89 d8                	mov    %ebx,%eax
  800e12:	f7 f7                	div    %edi
  800e14:	31 ff                	xor    %edi,%edi
  800e16:	89 c3                	mov    %eax,%ebx
  800e18:	89 d8                	mov    %ebx,%eax
  800e1a:	89 fa                	mov    %edi,%edx
  800e1c:	83 c4 1c             	add    $0x1c,%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	39 ce                	cmp    %ecx,%esi
  800e2a:	72 0c                	jb     800e38 <__udivdi3+0x118>
  800e2c:	31 db                	xor    %ebx,%ebx
  800e2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e32:	0f 87 34 ff ff ff    	ja     800d6c <__udivdi3+0x4c>
  800e38:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e3d:	e9 2a ff ff ff       	jmp    800d6c <__udivdi3+0x4c>
  800e42:	66 90                	xchg   %ax,%ax
  800e44:	66 90                	xchg   %ax,%ax
  800e46:	66 90                	xchg   %ax,%ax
  800e48:	66 90                	xchg   %ax,%ax
  800e4a:	66 90                	xchg   %ax,%ax
  800e4c:	66 90                	xchg   %ax,%ax
  800e4e:	66 90                	xchg   %ax,%ax

00800e50 <__umoddi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
  800e57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e67:	85 d2                	test   %edx,%edx
  800e69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e71:	89 f3                	mov    %esi,%ebx
  800e73:	89 3c 24             	mov    %edi,(%esp)
  800e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e7a:	75 1c                	jne    800e98 <__umoddi3+0x48>
  800e7c:	39 f7                	cmp    %esi,%edi
  800e7e:	76 50                	jbe    800ed0 <__umoddi3+0x80>
  800e80:	89 c8                	mov    %ecx,%eax
  800e82:	89 f2                	mov    %esi,%edx
  800e84:	f7 f7                	div    %edi
  800e86:	89 d0                	mov    %edx,%eax
  800e88:	31 d2                	xor    %edx,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	39 f2                	cmp    %esi,%edx
  800e9a:	89 d0                	mov    %edx,%eax
  800e9c:	77 52                	ja     800ef0 <__umoddi3+0xa0>
  800e9e:	0f bd ea             	bsr    %edx,%ebp
  800ea1:	83 f5 1f             	xor    $0x1f,%ebp
  800ea4:	75 5a                	jne    800f00 <__umoddi3+0xb0>
  800ea6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eaa:	0f 82 e0 00 00 00    	jb     800f90 <__umoddi3+0x140>
  800eb0:	39 0c 24             	cmp    %ecx,(%esp)
  800eb3:	0f 86 d7 00 00 00    	jbe    800f90 <__umoddi3+0x140>
  800eb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ebd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ec1:	83 c4 1c             	add    $0x1c,%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    
  800ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	85 ff                	test   %edi,%edi
  800ed2:	89 fd                	mov    %edi,%ebp
  800ed4:	75 0b                	jne    800ee1 <__umoddi3+0x91>
  800ed6:	b8 01 00 00 00       	mov    $0x1,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	f7 f7                	div    %edi
  800edf:	89 c5                	mov    %eax,%ebp
  800ee1:	89 f0                	mov    %esi,%eax
  800ee3:	31 d2                	xor    %edx,%edx
  800ee5:	f7 f5                	div    %ebp
  800ee7:	89 c8                	mov    %ecx,%eax
  800ee9:	f7 f5                	div    %ebp
  800eeb:	89 d0                	mov    %edx,%eax
  800eed:	eb 99                	jmp    800e88 <__umoddi3+0x38>
  800eef:	90                   	nop
  800ef0:	89 c8                	mov    %ecx,%eax
  800ef2:	89 f2                	mov    %esi,%edx
  800ef4:	83 c4 1c             	add    $0x1c,%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    
  800efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f00:	8b 34 24             	mov    (%esp),%esi
  800f03:	bf 20 00 00 00       	mov    $0x20,%edi
  800f08:	89 e9                	mov    %ebp,%ecx
  800f0a:	29 ef                	sub    %ebp,%edi
  800f0c:	d3 e0                	shl    %cl,%eax
  800f0e:	89 f9                	mov    %edi,%ecx
  800f10:	89 f2                	mov    %esi,%edx
  800f12:	d3 ea                	shr    %cl,%edx
  800f14:	89 e9                	mov    %ebp,%ecx
  800f16:	09 c2                	or     %eax,%edx
  800f18:	89 d8                	mov    %ebx,%eax
  800f1a:	89 14 24             	mov    %edx,(%esp)
  800f1d:	89 f2                	mov    %esi,%edx
  800f1f:	d3 e2                	shl    %cl,%edx
  800f21:	89 f9                	mov    %edi,%ecx
  800f23:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f27:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f2b:	d3 e8                	shr    %cl,%eax
  800f2d:	89 e9                	mov    %ebp,%ecx
  800f2f:	89 c6                	mov    %eax,%esi
  800f31:	d3 e3                	shl    %cl,%ebx
  800f33:	89 f9                	mov    %edi,%ecx
  800f35:	89 d0                	mov    %edx,%eax
  800f37:	d3 e8                	shr    %cl,%eax
  800f39:	89 e9                	mov    %ebp,%ecx
  800f3b:	09 d8                	or     %ebx,%eax
  800f3d:	89 d3                	mov    %edx,%ebx
  800f3f:	89 f2                	mov    %esi,%edx
  800f41:	f7 34 24             	divl   (%esp)
  800f44:	89 d6                	mov    %edx,%esi
  800f46:	d3 e3                	shl    %cl,%ebx
  800f48:	f7 64 24 04          	mull   0x4(%esp)
  800f4c:	39 d6                	cmp    %edx,%esi
  800f4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f52:	89 d1                	mov    %edx,%ecx
  800f54:	89 c3                	mov    %eax,%ebx
  800f56:	72 08                	jb     800f60 <__umoddi3+0x110>
  800f58:	75 11                	jne    800f6b <__umoddi3+0x11b>
  800f5a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f5e:	73 0b                	jae    800f6b <__umoddi3+0x11b>
  800f60:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f64:	1b 14 24             	sbb    (%esp),%edx
  800f67:	89 d1                	mov    %edx,%ecx
  800f69:	89 c3                	mov    %eax,%ebx
  800f6b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f6f:	29 da                	sub    %ebx,%edx
  800f71:	19 ce                	sbb    %ecx,%esi
  800f73:	89 f9                	mov    %edi,%ecx
  800f75:	89 f0                	mov    %esi,%eax
  800f77:	d3 e0                	shl    %cl,%eax
  800f79:	89 e9                	mov    %ebp,%ecx
  800f7b:	d3 ea                	shr    %cl,%edx
  800f7d:	89 e9                	mov    %ebp,%ecx
  800f7f:	d3 ee                	shr    %cl,%esi
  800f81:	09 d0                	or     %edx,%eax
  800f83:	89 f2                	mov    %esi,%edx
  800f85:	83 c4 1c             	add    $0x1c,%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi
  800f90:	29 f9                	sub    %edi,%ecx
  800f92:	19 d6                	sbb    %edx,%esi
  800f94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f98:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f9c:	e9 18 ff ff ff       	jmp    800eb9 <__umoddi3+0x69>
