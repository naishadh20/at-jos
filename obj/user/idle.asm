
obj/user/idle:     file format elf32-i386


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
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 20 80 00 a0 	movl   $0x800fa0,0x802000
  800040:	0f 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 01 01 00 00       	call   800149 <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800055:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80005c:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  80005f:	e8 c6 00 00 00       	call   80012a <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x37>
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
  800111:	68 af 0f 80 00       	push   $0x800faf
  800116:	6a 23                	push   $0x23
  800118:	68 cc 0f 80 00       	push   $0x800fcc
  80011d:	e8 f5 01 00 00       	call   800317 <_panic>

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

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0a 00 00 00       	mov    $0xa,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	b8 04 00 00 00       	mov    $0x4,%eax
  80017b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7e 17                	jle    8001a3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	50                   	push   %eax
  800190:	6a 04                	push   $0x4
  800192:	68 af 0f 80 00       	push   $0x800faf
  800197:	6a 23                	push   $0x23
  800199:	68 cc 0f 80 00       	push   $0x800fcc
  80019e:	e8 74 01 00 00       	call   800317 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a6:	5b                   	pop    %ebx
  8001a7:	5e                   	pop    %esi
  8001a8:	5f                   	pop    %edi
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    

008001ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7e 17                	jle    8001e5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	50                   	push   %eax
  8001d2:	6a 05                	push   $0x5
  8001d4:	68 af 0f 80 00       	push   $0x800faf
  8001d9:	6a 23                	push   $0x23
  8001db:	68 cc 0f 80 00       	push   $0x800fcc
  8001e0:	e8 32 01 00 00       	call   800317 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	b8 06 00 00 00       	mov    $0x6,%eax
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	8b 55 08             	mov    0x8(%ebp),%edx
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7e 17                	jle    800227 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	50                   	push   %eax
  800214:	6a 06                	push   $0x6
  800216:	68 af 0f 80 00       	push   $0x800faf
  80021b:	6a 23                	push   $0x23
  80021d:	68 cc 0f 80 00       	push   $0x800fcc
  800222:	e8 f0 00 00 00       	call   800317 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5f                   	pop    %edi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	b8 08 00 00 00       	mov    $0x8,%eax
  800242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800245:	8b 55 08             	mov    0x8(%ebp),%edx
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7e 17                	jle    800269 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800252:	83 ec 0c             	sub    $0xc,%esp
  800255:	50                   	push   %eax
  800256:	6a 08                	push   $0x8
  800258:	68 af 0f 80 00       	push   $0x800faf
  80025d:	6a 23                	push   $0x23
  80025f:	68 cc 0f 80 00       	push   $0x800fcc
  800264:	e8 ae 00 00 00       	call   800317 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026c:	5b                   	pop    %ebx
  80026d:	5e                   	pop    %esi
  80026e:	5f                   	pop    %edi
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    

00800271 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	b8 09 00 00 00       	mov    $0x9,%eax
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	8b 55 08             	mov    0x8(%ebp),%edx
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7e 17                	jle    8002ab <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	50                   	push   %eax
  800298:	6a 09                	push   $0x9
  80029a:	68 af 0f 80 00       	push   $0x800faf
  80029f:	6a 23                	push   $0x23
  8002a1:	68 cc 0f 80 00       	push   $0x800fcc
  8002a6:	e8 6c 00 00 00       	call   800317 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5f                   	pop    %edi
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b9:	be 00 00 00 00       	mov    $0x0,%esi
  8002be:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	89 cb                	mov    %ecx,%ebx
  8002ee:	89 cf                	mov    %ecx,%edi
  8002f0:	89 ce                	mov    %ecx,%esi
  8002f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7e 17                	jle    80030f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	50                   	push   %eax
  8002fc:	6a 0c                	push   $0xc
  8002fe:	68 af 0f 80 00       	push   $0x800faf
  800303:	6a 23                	push   $0x23
  800305:	68 cc 0f 80 00       	push   $0x800fcc
  80030a:	e8 08 00 00 00       	call   800317 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80030f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800312:	5b                   	pop    %ebx
  800313:	5e                   	pop    %esi
  800314:	5f                   	pop    %edi
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80031c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800325:	e8 00 fe ff ff       	call   80012a <sys_getenvid>
  80032a:	83 ec 0c             	sub    $0xc,%esp
  80032d:	ff 75 0c             	pushl  0xc(%ebp)
  800330:	ff 75 08             	pushl  0x8(%ebp)
  800333:	56                   	push   %esi
  800334:	50                   	push   %eax
  800335:	68 dc 0f 80 00       	push   $0x800fdc
  80033a:	e8 b1 00 00 00       	call   8003f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033f:	83 c4 18             	add    $0x18,%esp
  800342:	53                   	push   %ebx
  800343:	ff 75 10             	pushl  0x10(%ebp)
  800346:	e8 54 00 00 00       	call   80039f <vcprintf>
	cprintf("\n");
  80034b:	c7 04 24 34 10 80 00 	movl   $0x801034,(%esp)
  800352:	e8 99 00 00 00       	call   8003f0 <cprintf>
  800357:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80035a:	cc                   	int3   
  80035b:	eb fd                	jmp    80035a <_panic+0x43>

0080035d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	53                   	push   %ebx
  800361:	83 ec 04             	sub    $0x4,%esp
  800364:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800367:	8b 13                	mov    (%ebx),%edx
  800369:	8d 42 01             	lea    0x1(%edx),%eax
  80036c:	89 03                	mov    %eax,(%ebx)
  80036e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800371:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800375:	3d ff 00 00 00       	cmp    $0xff,%eax
  80037a:	75 1a                	jne    800396 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80037c:	83 ec 08             	sub    $0x8,%esp
  80037f:	68 ff 00 00 00       	push   $0xff
  800384:	8d 43 08             	lea    0x8(%ebx),%eax
  800387:	50                   	push   %eax
  800388:	e8 1f fd ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  80038d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800393:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800396:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80039a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003af:	00 00 00 
	b.cnt = 0;
  8003b2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003bc:	ff 75 0c             	pushl  0xc(%ebp)
  8003bf:	ff 75 08             	pushl  0x8(%ebp)
  8003c2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	68 5d 03 80 00       	push   $0x80035d
  8003ce:	e8 54 01 00 00       	call   800527 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003d3:	83 c4 08             	add    $0x8,%esp
  8003d6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003dc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003e2:	50                   	push   %eax
  8003e3:	e8 c4 fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  8003e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ee:	c9                   	leave  
  8003ef:	c3                   	ret    

008003f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f9:	50                   	push   %eax
  8003fa:	ff 75 08             	pushl  0x8(%ebp)
  8003fd:	e8 9d ff ff ff       	call   80039f <vcprintf>
	va_end(ap);

	return cnt;
}
  800402:	c9                   	leave  
  800403:	c3                   	ret    

00800404 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	57                   	push   %edi
  800408:	56                   	push   %esi
  800409:	53                   	push   %ebx
  80040a:	83 ec 1c             	sub    $0x1c,%esp
  80040d:	89 c7                	mov    %eax,%edi
  80040f:	89 d6                	mov    %edx,%esi
  800411:	8b 45 08             	mov    0x8(%ebp),%eax
  800414:	8b 55 0c             	mov    0xc(%ebp),%edx
  800417:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80041d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800420:	bb 00 00 00 00       	mov    $0x0,%ebx
  800425:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800428:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80042b:	39 d3                	cmp    %edx,%ebx
  80042d:	72 05                	jb     800434 <printnum+0x30>
  80042f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800432:	77 45                	ja     800479 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800434:	83 ec 0c             	sub    $0xc,%esp
  800437:	ff 75 18             	pushl  0x18(%ebp)
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800440:	53                   	push   %ebx
  800441:	ff 75 10             	pushl  0x10(%ebp)
  800444:	83 ec 08             	sub    $0x8,%esp
  800447:	ff 75 e4             	pushl  -0x1c(%ebp)
  80044a:	ff 75 e0             	pushl  -0x20(%ebp)
  80044d:	ff 75 dc             	pushl  -0x24(%ebp)
  800450:	ff 75 d8             	pushl  -0x28(%ebp)
  800453:	e8 a8 08 00 00       	call   800d00 <__udivdi3>
  800458:	83 c4 18             	add    $0x18,%esp
  80045b:	52                   	push   %edx
  80045c:	50                   	push   %eax
  80045d:	89 f2                	mov    %esi,%edx
  80045f:	89 f8                	mov    %edi,%eax
  800461:	e8 9e ff ff ff       	call   800404 <printnum>
  800466:	83 c4 20             	add    $0x20,%esp
  800469:	eb 18                	jmp    800483 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	56                   	push   %esi
  80046f:	ff 75 18             	pushl  0x18(%ebp)
  800472:	ff d7                	call   *%edi
  800474:	83 c4 10             	add    $0x10,%esp
  800477:	eb 03                	jmp    80047c <printnum+0x78>
  800479:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80047c:	83 eb 01             	sub    $0x1,%ebx
  80047f:	85 db                	test   %ebx,%ebx
  800481:	7f e8                	jg     80046b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	56                   	push   %esi
  800487:	83 ec 04             	sub    $0x4,%esp
  80048a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80048d:	ff 75 e0             	pushl  -0x20(%ebp)
  800490:	ff 75 dc             	pushl  -0x24(%ebp)
  800493:	ff 75 d8             	pushl  -0x28(%ebp)
  800496:	e8 95 09 00 00       	call   800e30 <__umoddi3>
  80049b:	83 c4 14             	add    $0x14,%esp
  80049e:	0f be 80 00 10 80 00 	movsbl 0x801000(%eax),%eax
  8004a5:	50                   	push   %eax
  8004a6:	ff d7                	call   *%edi
}
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ae:	5b                   	pop    %ebx
  8004af:	5e                   	pop    %esi
  8004b0:	5f                   	pop    %edi
  8004b1:	5d                   	pop    %ebp
  8004b2:	c3                   	ret    

008004b3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004b3:	55                   	push   %ebp
  8004b4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004b6:	83 fa 01             	cmp    $0x1,%edx
  8004b9:	7e 0e                	jle    8004c9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004bb:	8b 10                	mov    (%eax),%edx
  8004bd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004c0:	89 08                	mov    %ecx,(%eax)
  8004c2:	8b 02                	mov    (%edx),%eax
  8004c4:	8b 52 04             	mov    0x4(%edx),%edx
  8004c7:	eb 22                	jmp    8004eb <getuint+0x38>
	else if (lflag)
  8004c9:	85 d2                	test   %edx,%edx
  8004cb:	74 10                	je     8004dd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004cd:	8b 10                	mov    (%eax),%edx
  8004cf:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d2:	89 08                	mov    %ecx,(%eax)
  8004d4:	8b 02                	mov    (%edx),%eax
  8004d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8004db:	eb 0e                	jmp    8004eb <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004dd:	8b 10                	mov    (%eax),%edx
  8004df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e2:	89 08                	mov    %ecx,(%eax)
  8004e4:	8b 02                	mov    (%edx),%eax
  8004e6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004eb:	5d                   	pop    %ebp
  8004ec:	c3                   	ret    

008004ed <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ed:	55                   	push   %ebp
  8004ee:	89 e5                	mov    %esp,%ebp
  8004f0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f7:	8b 10                	mov    (%eax),%edx
  8004f9:	3b 50 04             	cmp    0x4(%eax),%edx
  8004fc:	73 0a                	jae    800508 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004fe:	8d 4a 01             	lea    0x1(%edx),%ecx
  800501:	89 08                	mov    %ecx,(%eax)
  800503:	8b 45 08             	mov    0x8(%ebp),%eax
  800506:	88 02                	mov    %al,(%edx)
}
  800508:	5d                   	pop    %ebp
  800509:	c3                   	ret    

0080050a <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
  80050d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800510:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800513:	50                   	push   %eax
  800514:	ff 75 10             	pushl  0x10(%ebp)
  800517:	ff 75 0c             	pushl  0xc(%ebp)
  80051a:	ff 75 08             	pushl  0x8(%ebp)
  80051d:	e8 05 00 00 00       	call   800527 <vprintfmt>
	va_end(ap);
}
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	c9                   	leave  
  800526:	c3                   	ret    

00800527 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800527:	55                   	push   %ebp
  800528:	89 e5                	mov    %esp,%ebp
  80052a:	57                   	push   %edi
  80052b:	56                   	push   %esi
  80052c:	53                   	push   %ebx
  80052d:	83 ec 2c             	sub    $0x2c,%esp
  800530:	8b 75 08             	mov    0x8(%ebp),%esi
  800533:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800536:	8b 7d 10             	mov    0x10(%ebp),%edi
  800539:	eb 12                	jmp    80054d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80053b:	85 c0                	test   %eax,%eax
  80053d:	0f 84 cb 03 00 00    	je     80090e <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	53                   	push   %ebx
  800547:	50                   	push   %eax
  800548:	ff d6                	call   *%esi
  80054a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80054d:	83 c7 01             	add    $0x1,%edi
  800550:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800554:	83 f8 25             	cmp    $0x25,%eax
  800557:	75 e2                	jne    80053b <vprintfmt+0x14>
  800559:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80055d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800564:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80056b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800572:	ba 00 00 00 00       	mov    $0x0,%edx
  800577:	eb 07                	jmp    800580 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800579:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80057c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800580:	8d 47 01             	lea    0x1(%edi),%eax
  800583:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800586:	0f b6 07             	movzbl (%edi),%eax
  800589:	0f b6 c8             	movzbl %al,%ecx
  80058c:	83 e8 23             	sub    $0x23,%eax
  80058f:	3c 55                	cmp    $0x55,%al
  800591:	0f 87 5c 03 00 00    	ja     8008f3 <vprintfmt+0x3cc>
  800597:	0f b6 c0             	movzbl %al,%eax
  80059a:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  8005a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005a4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005a8:	eb d6                	jmp    800580 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005bc:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005bf:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005c2:	83 fa 09             	cmp    $0x9,%edx
  8005c5:	77 39                	ja     800600 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005ca:	eb e9                	jmp    8005b5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 48 04             	lea    0x4(%eax),%ecx
  8005d2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005d5:	8b 00                	mov    (%eax),%eax
  8005d7:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005dd:	eb 27                	jmp    800606 <vprintfmt+0xdf>
  8005df:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e2:	85 c0                	test   %eax,%eax
  8005e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e9:	0f 49 c8             	cmovns %eax,%ecx
  8005ec:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f2:	eb 8c                	jmp    800580 <vprintfmt+0x59>
  8005f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005f7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005fe:	eb 80                	jmp    800580 <vprintfmt+0x59>
  800600:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800603:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800606:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80060a:	0f 89 70 ff ff ff    	jns    800580 <vprintfmt+0x59>
				width = precision, precision = -1;
  800610:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800613:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800616:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80061d:	e9 5e ff ff ff       	jmp    800580 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800622:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800625:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800628:	e9 53 ff ff ff       	jmp    800580 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 50 04             	lea    0x4(%eax),%edx
  800633:	89 55 14             	mov    %edx,0x14(%ebp)
  800636:	83 ec 08             	sub    $0x8,%esp
  800639:	53                   	push   %ebx
  80063a:	ff 30                	pushl  (%eax)
  80063c:	ff d6                	call   *%esi
			break;
  80063e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800641:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800644:	e9 04 ff ff ff       	jmp    80054d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8d 50 04             	lea    0x4(%eax),%edx
  80064f:	89 55 14             	mov    %edx,0x14(%ebp)
  800652:	8b 00                	mov    (%eax),%eax
  800654:	99                   	cltd   
  800655:	31 d0                	xor    %edx,%eax
  800657:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800659:	83 f8 09             	cmp    $0x9,%eax
  80065c:	7f 0b                	jg     800669 <vprintfmt+0x142>
  80065e:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  800665:	85 d2                	test   %edx,%edx
  800667:	75 18                	jne    800681 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800669:	50                   	push   %eax
  80066a:	68 18 10 80 00       	push   $0x801018
  80066f:	53                   	push   %ebx
  800670:	56                   	push   %esi
  800671:	e8 94 fe ff ff       	call   80050a <printfmt>
  800676:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800679:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80067c:	e9 cc fe ff ff       	jmp    80054d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800681:	52                   	push   %edx
  800682:	68 21 10 80 00       	push   $0x801021
  800687:	53                   	push   %ebx
  800688:	56                   	push   %esi
  800689:	e8 7c fe ff ff       	call   80050a <printfmt>
  80068e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800691:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800694:	e9 b4 fe ff ff       	jmp    80054d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8d 50 04             	lea    0x4(%eax),%edx
  80069f:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006a4:	85 ff                	test   %edi,%edi
  8006a6:	b8 11 10 80 00       	mov    $0x801011,%eax
  8006ab:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006ae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b2:	0f 8e 94 00 00 00    	jle    80074c <vprintfmt+0x225>
  8006b8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006bc:	0f 84 98 00 00 00    	je     80075a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	ff 75 c8             	pushl  -0x38(%ebp)
  8006c8:	57                   	push   %edi
  8006c9:	e8 c8 02 00 00       	call   800996 <strnlen>
  8006ce:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006d1:	29 c1                	sub    %eax,%ecx
  8006d3:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006d6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006e0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006e3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e5:	eb 0f                	jmp    8006f6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ee:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f0:	83 ef 01             	sub    $0x1,%edi
  8006f3:	83 c4 10             	add    $0x10,%esp
  8006f6:	85 ff                	test   %edi,%edi
  8006f8:	7f ed                	jg     8006e7 <vprintfmt+0x1c0>
  8006fa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006fd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800700:	85 c9                	test   %ecx,%ecx
  800702:	b8 00 00 00 00       	mov    $0x0,%eax
  800707:	0f 49 c1             	cmovns %ecx,%eax
  80070a:	29 c1                	sub    %eax,%ecx
  80070c:	89 75 08             	mov    %esi,0x8(%ebp)
  80070f:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800712:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800715:	89 cb                	mov    %ecx,%ebx
  800717:	eb 4d                	jmp    800766 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800719:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80071d:	74 1b                	je     80073a <vprintfmt+0x213>
  80071f:	0f be c0             	movsbl %al,%eax
  800722:	83 e8 20             	sub    $0x20,%eax
  800725:	83 f8 5e             	cmp    $0x5e,%eax
  800728:	76 10                	jbe    80073a <vprintfmt+0x213>
					putch('?', putdat);
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	6a 3f                	push   $0x3f
  800732:	ff 55 08             	call   *0x8(%ebp)
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	eb 0d                	jmp    800747 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	ff 75 0c             	pushl  0xc(%ebp)
  800740:	52                   	push   %edx
  800741:	ff 55 08             	call   *0x8(%ebp)
  800744:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800747:	83 eb 01             	sub    $0x1,%ebx
  80074a:	eb 1a                	jmp    800766 <vprintfmt+0x23f>
  80074c:	89 75 08             	mov    %esi,0x8(%ebp)
  80074f:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800752:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800755:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800758:	eb 0c                	jmp    800766 <vprintfmt+0x23f>
  80075a:	89 75 08             	mov    %esi,0x8(%ebp)
  80075d:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800760:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800763:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800766:	83 c7 01             	add    $0x1,%edi
  800769:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80076d:	0f be d0             	movsbl %al,%edx
  800770:	85 d2                	test   %edx,%edx
  800772:	74 23                	je     800797 <vprintfmt+0x270>
  800774:	85 f6                	test   %esi,%esi
  800776:	78 a1                	js     800719 <vprintfmt+0x1f2>
  800778:	83 ee 01             	sub    $0x1,%esi
  80077b:	79 9c                	jns    800719 <vprintfmt+0x1f2>
  80077d:	89 df                	mov    %ebx,%edi
  80077f:	8b 75 08             	mov    0x8(%ebp),%esi
  800782:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800785:	eb 18                	jmp    80079f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	6a 20                	push   $0x20
  80078d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078f:	83 ef 01             	sub    $0x1,%edi
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	eb 08                	jmp    80079f <vprintfmt+0x278>
  800797:	89 df                	mov    %ebx,%edi
  800799:	8b 75 08             	mov    0x8(%ebp),%esi
  80079c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079f:	85 ff                	test   %edi,%edi
  8007a1:	7f e4                	jg     800787 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a6:	e9 a2 fd ff ff       	jmp    80054d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ab:	83 fa 01             	cmp    $0x1,%edx
  8007ae:	7e 16                	jle    8007c6 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8d 50 08             	lea    0x8(%eax),%edx
  8007b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b9:	8b 50 04             	mov    0x4(%eax),%edx
  8007bc:	8b 00                	mov    (%eax),%eax
  8007be:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007c1:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007c4:	eb 32                	jmp    8007f8 <vprintfmt+0x2d1>
	else if (lflag)
  8007c6:	85 d2                	test   %edx,%edx
  8007c8:	74 18                	je     8007e2 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cd:	8d 50 04             	lea    0x4(%eax),%edx
  8007d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d3:	8b 00                	mov    (%eax),%eax
  8007d5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007d8:	89 c1                	mov    %eax,%ecx
  8007da:	c1 f9 1f             	sar    $0x1f,%ecx
  8007dd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007e0:	eb 16                	jmp    8007f8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e5:	8d 50 04             	lea    0x4(%eax),%edx
  8007e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007eb:	8b 00                	mov    (%eax),%eax
  8007ed:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007f0:	89 c1                	mov    %eax,%ecx
  8007f2:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007fb:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800801:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800804:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800809:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80080d:	0f 89 a8 00 00 00    	jns    8008bb <vprintfmt+0x394>
				putch('-', putdat);
  800813:	83 ec 08             	sub    $0x8,%esp
  800816:	53                   	push   %ebx
  800817:	6a 2d                	push   $0x2d
  800819:	ff d6                	call   *%esi
				num = -(long long) num;
  80081b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80081e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800821:	f7 d8                	neg    %eax
  800823:	83 d2 00             	adc    $0x0,%edx
  800826:	f7 da                	neg    %edx
  800828:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80082b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80082e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800831:	b8 0a 00 00 00       	mov    $0xa,%eax
  800836:	e9 80 00 00 00       	jmp    8008bb <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80083b:	8d 45 14             	lea    0x14(%ebp),%eax
  80083e:	e8 70 fc ff ff       	call   8004b3 <getuint>
  800843:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800846:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800849:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80084e:	eb 6b                	jmp    8008bb <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800850:	8d 45 14             	lea    0x14(%ebp),%eax
  800853:	e8 5b fc ff ff       	call   8004b3 <getuint>
  800858:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80085b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  80085e:	6a 04                	push   $0x4
  800860:	6a 03                	push   $0x3
  800862:	6a 01                	push   $0x1
  800864:	68 24 10 80 00       	push   $0x801024
  800869:	e8 82 fb ff ff       	call   8003f0 <cprintf>
			goto number;
  80086e:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  800871:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  800876:	eb 43                	jmp    8008bb <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  800878:	83 ec 08             	sub    $0x8,%esp
  80087b:	53                   	push   %ebx
  80087c:	6a 30                	push   $0x30
  80087e:	ff d6                	call   *%esi
			putch('x', putdat);
  800880:	83 c4 08             	add    $0x8,%esp
  800883:	53                   	push   %ebx
  800884:	6a 78                	push   $0x78
  800886:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800888:	8b 45 14             	mov    0x14(%ebp),%eax
  80088b:	8d 50 04             	lea    0x4(%eax),%edx
  80088e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800891:	8b 00                	mov    (%eax),%eax
  800893:	ba 00 00 00 00       	mov    $0x0,%edx
  800898:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80089b:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80089e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008a1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008a6:	eb 13                	jmp    8008bb <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ab:	e8 03 fc ff ff       	call   8004b3 <getuint>
  8008b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008b6:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008bb:	83 ec 0c             	sub    $0xc,%esp
  8008be:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8008c2:	52                   	push   %edx
  8008c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c6:	50                   	push   %eax
  8008c7:	ff 75 dc             	pushl  -0x24(%ebp)
  8008ca:	ff 75 d8             	pushl  -0x28(%ebp)
  8008cd:	89 da                	mov    %ebx,%edx
  8008cf:	89 f0                	mov    %esi,%eax
  8008d1:	e8 2e fb ff ff       	call   800404 <printnum>

			break;
  8008d6:	83 c4 20             	add    $0x20,%esp
  8008d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008dc:	e9 6c fc ff ff       	jmp    80054d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	53                   	push   %ebx
  8008e5:	51                   	push   %ecx
  8008e6:	ff d6                	call   *%esi
			break;
  8008e8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008ee:	e9 5a fc ff ff       	jmp    80054d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008f3:	83 ec 08             	sub    $0x8,%esp
  8008f6:	53                   	push   %ebx
  8008f7:	6a 25                	push   $0x25
  8008f9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008fb:	83 c4 10             	add    $0x10,%esp
  8008fe:	eb 03                	jmp    800903 <vprintfmt+0x3dc>
  800900:	83 ef 01             	sub    $0x1,%edi
  800903:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800907:	75 f7                	jne    800900 <vprintfmt+0x3d9>
  800909:	e9 3f fc ff ff       	jmp    80054d <vprintfmt+0x26>
			break;
		}

	}

}
  80090e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800911:	5b                   	pop    %ebx
  800912:	5e                   	pop    %esi
  800913:	5f                   	pop    %edi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	83 ec 18             	sub    $0x18,%esp
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800922:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800925:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800929:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80092c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800933:	85 c0                	test   %eax,%eax
  800935:	74 26                	je     80095d <vsnprintf+0x47>
  800937:	85 d2                	test   %edx,%edx
  800939:	7e 22                	jle    80095d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80093b:	ff 75 14             	pushl  0x14(%ebp)
  80093e:	ff 75 10             	pushl  0x10(%ebp)
  800941:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800944:	50                   	push   %eax
  800945:	68 ed 04 80 00       	push   $0x8004ed
  80094a:	e8 d8 fb ff ff       	call   800527 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80094f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800952:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800955:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800958:	83 c4 10             	add    $0x10,%esp
  80095b:	eb 05                	jmp    800962 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80095d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80096a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80096d:	50                   	push   %eax
  80096e:	ff 75 10             	pushl  0x10(%ebp)
  800971:	ff 75 0c             	pushl  0xc(%ebp)
  800974:	ff 75 08             	pushl  0x8(%ebp)
  800977:	e8 9a ff ff ff       	call   800916 <vsnprintf>
	va_end(ap);

	return rc;
}
  80097c:	c9                   	leave  
  80097d:	c3                   	ret    

0080097e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800984:	b8 00 00 00 00       	mov    $0x0,%eax
  800989:	eb 03                	jmp    80098e <strlen+0x10>
		n++;
  80098b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80098e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800992:	75 f7                	jne    80098b <strlen+0xd>
		n++;
	return n;
}
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099f:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a4:	eb 03                	jmp    8009a9 <strnlen+0x13>
		n++;
  8009a6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a9:	39 c2                	cmp    %eax,%edx
  8009ab:	74 08                	je     8009b5 <strnlen+0x1f>
  8009ad:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009b1:	75 f3                	jne    8009a6 <strnlen+0x10>
  8009b3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	53                   	push   %ebx
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009c1:	89 c2                	mov    %eax,%edx
  8009c3:	83 c2 01             	add    $0x1,%edx
  8009c6:	83 c1 01             	add    $0x1,%ecx
  8009c9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009cd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009d0:	84 db                	test   %bl,%bl
  8009d2:	75 ef                	jne    8009c3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009d4:	5b                   	pop    %ebx
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	53                   	push   %ebx
  8009db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009de:	53                   	push   %ebx
  8009df:	e8 9a ff ff ff       	call   80097e <strlen>
  8009e4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009e7:	ff 75 0c             	pushl  0xc(%ebp)
  8009ea:	01 d8                	add    %ebx,%eax
  8009ec:	50                   	push   %eax
  8009ed:	e8 c5 ff ff ff       	call   8009b7 <strcpy>
	return dst;
}
  8009f2:	89 d8                	mov    %ebx,%eax
  8009f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f7:	c9                   	leave  
  8009f8:	c3                   	ret    

008009f9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	56                   	push   %esi
  8009fd:	53                   	push   %ebx
  8009fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800a01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a04:	89 f3                	mov    %esi,%ebx
  800a06:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a09:	89 f2                	mov    %esi,%edx
  800a0b:	eb 0f                	jmp    800a1c <strncpy+0x23>
		*dst++ = *src;
  800a0d:	83 c2 01             	add    $0x1,%edx
  800a10:	0f b6 01             	movzbl (%ecx),%eax
  800a13:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a16:	80 39 01             	cmpb   $0x1,(%ecx)
  800a19:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a1c:	39 da                	cmp    %ebx,%edx
  800a1e:	75 ed                	jne    800a0d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a20:	89 f0                	mov    %esi,%eax
  800a22:	5b                   	pop    %ebx
  800a23:	5e                   	pop    %esi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	56                   	push   %esi
  800a2a:	53                   	push   %ebx
  800a2b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a31:	8b 55 10             	mov    0x10(%ebp),%edx
  800a34:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a36:	85 d2                	test   %edx,%edx
  800a38:	74 21                	je     800a5b <strlcpy+0x35>
  800a3a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a3e:	89 f2                	mov    %esi,%edx
  800a40:	eb 09                	jmp    800a4b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a42:	83 c2 01             	add    $0x1,%edx
  800a45:	83 c1 01             	add    $0x1,%ecx
  800a48:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a4b:	39 c2                	cmp    %eax,%edx
  800a4d:	74 09                	je     800a58 <strlcpy+0x32>
  800a4f:	0f b6 19             	movzbl (%ecx),%ebx
  800a52:	84 db                	test   %bl,%bl
  800a54:	75 ec                	jne    800a42 <strlcpy+0x1c>
  800a56:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a58:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a5b:	29 f0                	sub    %esi,%eax
}
  800a5d:	5b                   	pop    %ebx
  800a5e:	5e                   	pop    %esi
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a67:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a6a:	eb 06                	jmp    800a72 <strcmp+0x11>
		p++, q++;
  800a6c:	83 c1 01             	add    $0x1,%ecx
  800a6f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a72:	0f b6 01             	movzbl (%ecx),%eax
  800a75:	84 c0                	test   %al,%al
  800a77:	74 04                	je     800a7d <strcmp+0x1c>
  800a79:	3a 02                	cmp    (%edx),%al
  800a7b:	74 ef                	je     800a6c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7d:	0f b6 c0             	movzbl %al,%eax
  800a80:	0f b6 12             	movzbl (%edx),%edx
  800a83:	29 d0                	sub    %edx,%eax
}
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	53                   	push   %ebx
  800a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a91:	89 c3                	mov    %eax,%ebx
  800a93:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a96:	eb 06                	jmp    800a9e <strncmp+0x17>
		n--, p++, q++;
  800a98:	83 c0 01             	add    $0x1,%eax
  800a9b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a9e:	39 d8                	cmp    %ebx,%eax
  800aa0:	74 15                	je     800ab7 <strncmp+0x30>
  800aa2:	0f b6 08             	movzbl (%eax),%ecx
  800aa5:	84 c9                	test   %cl,%cl
  800aa7:	74 04                	je     800aad <strncmp+0x26>
  800aa9:	3a 0a                	cmp    (%edx),%cl
  800aab:	74 eb                	je     800a98 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aad:	0f b6 00             	movzbl (%eax),%eax
  800ab0:	0f b6 12             	movzbl (%edx),%edx
  800ab3:	29 d0                	sub    %edx,%eax
  800ab5:	eb 05                	jmp    800abc <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ab7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800abc:	5b                   	pop    %ebx
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac9:	eb 07                	jmp    800ad2 <strchr+0x13>
		if (*s == c)
  800acb:	38 ca                	cmp    %cl,%dl
  800acd:	74 0f                	je     800ade <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800acf:	83 c0 01             	add    $0x1,%eax
  800ad2:	0f b6 10             	movzbl (%eax),%edx
  800ad5:	84 d2                	test   %dl,%dl
  800ad7:	75 f2                	jne    800acb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ad9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aea:	eb 03                	jmp    800aef <strfind+0xf>
  800aec:	83 c0 01             	add    $0x1,%eax
  800aef:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800af2:	38 ca                	cmp    %cl,%dl
  800af4:	74 04                	je     800afa <strfind+0x1a>
  800af6:	84 d2                	test   %dl,%dl
  800af8:	75 f2                	jne    800aec <strfind+0xc>
			break;
	return (char *) s;
}
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
  800b02:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b08:	85 c9                	test   %ecx,%ecx
  800b0a:	74 36                	je     800b42 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b0c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b12:	75 28                	jne    800b3c <memset+0x40>
  800b14:	f6 c1 03             	test   $0x3,%cl
  800b17:	75 23                	jne    800b3c <memset+0x40>
		c &= 0xFF;
  800b19:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b1d:	89 d3                	mov    %edx,%ebx
  800b1f:	c1 e3 08             	shl    $0x8,%ebx
  800b22:	89 d6                	mov    %edx,%esi
  800b24:	c1 e6 18             	shl    $0x18,%esi
  800b27:	89 d0                	mov    %edx,%eax
  800b29:	c1 e0 10             	shl    $0x10,%eax
  800b2c:	09 f0                	or     %esi,%eax
  800b2e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b30:	89 d8                	mov    %ebx,%eax
  800b32:	09 d0                	or     %edx,%eax
  800b34:	c1 e9 02             	shr    $0x2,%ecx
  800b37:	fc                   	cld    
  800b38:	f3 ab                	rep stos %eax,%es:(%edi)
  800b3a:	eb 06                	jmp    800b42 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3f:	fc                   	cld    
  800b40:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b42:	89 f8                	mov    %edi,%eax
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	57                   	push   %edi
  800b4d:	56                   	push   %esi
  800b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b51:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b54:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b57:	39 c6                	cmp    %eax,%esi
  800b59:	73 35                	jae    800b90 <memmove+0x47>
  800b5b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b5e:	39 d0                	cmp    %edx,%eax
  800b60:	73 2e                	jae    800b90 <memmove+0x47>
		s += n;
		d += n;
  800b62:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b65:	89 d6                	mov    %edx,%esi
  800b67:	09 fe                	or     %edi,%esi
  800b69:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b6f:	75 13                	jne    800b84 <memmove+0x3b>
  800b71:	f6 c1 03             	test   $0x3,%cl
  800b74:	75 0e                	jne    800b84 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b76:	83 ef 04             	sub    $0x4,%edi
  800b79:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b7c:	c1 e9 02             	shr    $0x2,%ecx
  800b7f:	fd                   	std    
  800b80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b82:	eb 09                	jmp    800b8d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b84:	83 ef 01             	sub    $0x1,%edi
  800b87:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b8a:	fd                   	std    
  800b8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b8d:	fc                   	cld    
  800b8e:	eb 1d                	jmp    800bad <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b90:	89 f2                	mov    %esi,%edx
  800b92:	09 c2                	or     %eax,%edx
  800b94:	f6 c2 03             	test   $0x3,%dl
  800b97:	75 0f                	jne    800ba8 <memmove+0x5f>
  800b99:	f6 c1 03             	test   $0x3,%cl
  800b9c:	75 0a                	jne    800ba8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b9e:	c1 e9 02             	shr    $0x2,%ecx
  800ba1:	89 c7                	mov    %eax,%edi
  800ba3:	fc                   	cld    
  800ba4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba6:	eb 05                	jmp    800bad <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ba8:	89 c7                	mov    %eax,%edi
  800baa:	fc                   	cld    
  800bab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bb4:	ff 75 10             	pushl  0x10(%ebp)
  800bb7:	ff 75 0c             	pushl  0xc(%ebp)
  800bba:	ff 75 08             	pushl  0x8(%ebp)
  800bbd:	e8 87 ff ff ff       	call   800b49 <memmove>
}
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcf:	89 c6                	mov    %eax,%esi
  800bd1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd4:	eb 1a                	jmp    800bf0 <memcmp+0x2c>
		if (*s1 != *s2)
  800bd6:	0f b6 08             	movzbl (%eax),%ecx
  800bd9:	0f b6 1a             	movzbl (%edx),%ebx
  800bdc:	38 d9                	cmp    %bl,%cl
  800bde:	74 0a                	je     800bea <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800be0:	0f b6 c1             	movzbl %cl,%eax
  800be3:	0f b6 db             	movzbl %bl,%ebx
  800be6:	29 d8                	sub    %ebx,%eax
  800be8:	eb 0f                	jmp    800bf9 <memcmp+0x35>
		s1++, s2++;
  800bea:	83 c0 01             	add    $0x1,%eax
  800bed:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf0:	39 f0                	cmp    %esi,%eax
  800bf2:	75 e2                	jne    800bd6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bf4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	53                   	push   %ebx
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c04:	89 c1                	mov    %eax,%ecx
  800c06:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c09:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c0d:	eb 0a                	jmp    800c19 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c0f:	0f b6 10             	movzbl (%eax),%edx
  800c12:	39 da                	cmp    %ebx,%edx
  800c14:	74 07                	je     800c1d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c16:	83 c0 01             	add    $0x1,%eax
  800c19:	39 c8                	cmp    %ecx,%eax
  800c1b:	72 f2                	jb     800c0f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c1d:	5b                   	pop    %ebx
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
  800c26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c29:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2c:	eb 03                	jmp    800c31 <strtol+0x11>
		s++;
  800c2e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c31:	0f b6 01             	movzbl (%ecx),%eax
  800c34:	3c 20                	cmp    $0x20,%al
  800c36:	74 f6                	je     800c2e <strtol+0xe>
  800c38:	3c 09                	cmp    $0x9,%al
  800c3a:	74 f2                	je     800c2e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c3c:	3c 2b                	cmp    $0x2b,%al
  800c3e:	75 0a                	jne    800c4a <strtol+0x2a>
		s++;
  800c40:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c43:	bf 00 00 00 00       	mov    $0x0,%edi
  800c48:	eb 11                	jmp    800c5b <strtol+0x3b>
  800c4a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c4f:	3c 2d                	cmp    $0x2d,%al
  800c51:	75 08                	jne    800c5b <strtol+0x3b>
		s++, neg = 1;
  800c53:	83 c1 01             	add    $0x1,%ecx
  800c56:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c5b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c61:	75 15                	jne    800c78 <strtol+0x58>
  800c63:	80 39 30             	cmpb   $0x30,(%ecx)
  800c66:	75 10                	jne    800c78 <strtol+0x58>
  800c68:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c6c:	75 7c                	jne    800cea <strtol+0xca>
		s += 2, base = 16;
  800c6e:	83 c1 02             	add    $0x2,%ecx
  800c71:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c76:	eb 16                	jmp    800c8e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c78:	85 db                	test   %ebx,%ebx
  800c7a:	75 12                	jne    800c8e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c7c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c81:	80 39 30             	cmpb   $0x30,(%ecx)
  800c84:	75 08                	jne    800c8e <strtol+0x6e>
		s++, base = 8;
  800c86:	83 c1 01             	add    $0x1,%ecx
  800c89:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c93:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c96:	0f b6 11             	movzbl (%ecx),%edx
  800c99:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c9c:	89 f3                	mov    %esi,%ebx
  800c9e:	80 fb 09             	cmp    $0x9,%bl
  800ca1:	77 08                	ja     800cab <strtol+0x8b>
			dig = *s - '0';
  800ca3:	0f be d2             	movsbl %dl,%edx
  800ca6:	83 ea 30             	sub    $0x30,%edx
  800ca9:	eb 22                	jmp    800ccd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cab:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cae:	89 f3                	mov    %esi,%ebx
  800cb0:	80 fb 19             	cmp    $0x19,%bl
  800cb3:	77 08                	ja     800cbd <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cb5:	0f be d2             	movsbl %dl,%edx
  800cb8:	83 ea 57             	sub    $0x57,%edx
  800cbb:	eb 10                	jmp    800ccd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cbd:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cc0:	89 f3                	mov    %esi,%ebx
  800cc2:	80 fb 19             	cmp    $0x19,%bl
  800cc5:	77 16                	ja     800cdd <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cc7:	0f be d2             	movsbl %dl,%edx
  800cca:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ccd:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cd0:	7d 0b                	jge    800cdd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cd2:	83 c1 01             	add    $0x1,%ecx
  800cd5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cd9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cdb:	eb b9                	jmp    800c96 <strtol+0x76>

	if (endptr)
  800cdd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce1:	74 0d                	je     800cf0 <strtol+0xd0>
		*endptr = (char *) s;
  800ce3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce6:	89 0e                	mov    %ecx,(%esi)
  800ce8:	eb 06                	jmp    800cf0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cea:	85 db                	test   %ebx,%ebx
  800cec:	74 98                	je     800c86 <strtol+0x66>
  800cee:	eb 9e                	jmp    800c8e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cf0:	89 c2                	mov    %eax,%edx
  800cf2:	f7 da                	neg    %edx
  800cf4:	85 ff                	test   %edi,%edi
  800cf6:	0f 45 c2             	cmovne %edx,%eax
}
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    
  800cfe:	66 90                	xchg   %ax,%ax

00800d00 <__udivdi3>:
  800d00:	55                   	push   %ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 1c             	sub    $0x1c,%esp
  800d07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d17:	85 f6                	test   %esi,%esi
  800d19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d1d:	89 ca                	mov    %ecx,%edx
  800d1f:	89 f8                	mov    %edi,%eax
  800d21:	75 3d                	jne    800d60 <__udivdi3+0x60>
  800d23:	39 cf                	cmp    %ecx,%edi
  800d25:	0f 87 c5 00 00 00    	ja     800df0 <__udivdi3+0xf0>
  800d2b:	85 ff                	test   %edi,%edi
  800d2d:	89 fd                	mov    %edi,%ebp
  800d2f:	75 0b                	jne    800d3c <__udivdi3+0x3c>
  800d31:	b8 01 00 00 00       	mov    $0x1,%eax
  800d36:	31 d2                	xor    %edx,%edx
  800d38:	f7 f7                	div    %edi
  800d3a:	89 c5                	mov    %eax,%ebp
  800d3c:	89 c8                	mov    %ecx,%eax
  800d3e:	31 d2                	xor    %edx,%edx
  800d40:	f7 f5                	div    %ebp
  800d42:	89 c1                	mov    %eax,%ecx
  800d44:	89 d8                	mov    %ebx,%eax
  800d46:	89 cf                	mov    %ecx,%edi
  800d48:	f7 f5                	div    %ebp
  800d4a:	89 c3                	mov    %eax,%ebx
  800d4c:	89 d8                	mov    %ebx,%eax
  800d4e:	89 fa                	mov    %edi,%edx
  800d50:	83 c4 1c             	add    $0x1c,%esp
  800d53:	5b                   	pop    %ebx
  800d54:	5e                   	pop    %esi
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    
  800d58:	90                   	nop
  800d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d60:	39 ce                	cmp    %ecx,%esi
  800d62:	77 74                	ja     800dd8 <__udivdi3+0xd8>
  800d64:	0f bd fe             	bsr    %esi,%edi
  800d67:	83 f7 1f             	xor    $0x1f,%edi
  800d6a:	0f 84 98 00 00 00    	je     800e08 <__udivdi3+0x108>
  800d70:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d75:	89 f9                	mov    %edi,%ecx
  800d77:	89 c5                	mov    %eax,%ebp
  800d79:	29 fb                	sub    %edi,%ebx
  800d7b:	d3 e6                	shl    %cl,%esi
  800d7d:	89 d9                	mov    %ebx,%ecx
  800d7f:	d3 ed                	shr    %cl,%ebp
  800d81:	89 f9                	mov    %edi,%ecx
  800d83:	d3 e0                	shl    %cl,%eax
  800d85:	09 ee                	or     %ebp,%esi
  800d87:	89 d9                	mov    %ebx,%ecx
  800d89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d8d:	89 d5                	mov    %edx,%ebp
  800d8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d93:	d3 ed                	shr    %cl,%ebp
  800d95:	89 f9                	mov    %edi,%ecx
  800d97:	d3 e2                	shl    %cl,%edx
  800d99:	89 d9                	mov    %ebx,%ecx
  800d9b:	d3 e8                	shr    %cl,%eax
  800d9d:	09 c2                	or     %eax,%edx
  800d9f:	89 d0                	mov    %edx,%eax
  800da1:	89 ea                	mov    %ebp,%edx
  800da3:	f7 f6                	div    %esi
  800da5:	89 d5                	mov    %edx,%ebp
  800da7:	89 c3                	mov    %eax,%ebx
  800da9:	f7 64 24 0c          	mull   0xc(%esp)
  800dad:	39 d5                	cmp    %edx,%ebp
  800daf:	72 10                	jb     800dc1 <__udivdi3+0xc1>
  800db1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	d3 e6                	shl    %cl,%esi
  800db9:	39 c6                	cmp    %eax,%esi
  800dbb:	73 07                	jae    800dc4 <__udivdi3+0xc4>
  800dbd:	39 d5                	cmp    %edx,%ebp
  800dbf:	75 03                	jne    800dc4 <__udivdi3+0xc4>
  800dc1:	83 eb 01             	sub    $0x1,%ebx
  800dc4:	31 ff                	xor    %edi,%edi
  800dc6:	89 d8                	mov    %ebx,%eax
  800dc8:	89 fa                	mov    %edi,%edx
  800dca:	83 c4 1c             	add    $0x1c,%esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    
  800dd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800dd8:	31 ff                	xor    %edi,%edi
  800dda:	31 db                	xor    %ebx,%ebx
  800ddc:	89 d8                	mov    %ebx,%eax
  800dde:	89 fa                	mov    %edi,%edx
  800de0:	83 c4 1c             	add    $0x1c,%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    
  800de8:	90                   	nop
  800de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800df0:	89 d8                	mov    %ebx,%eax
  800df2:	f7 f7                	div    %edi
  800df4:	31 ff                	xor    %edi,%edi
  800df6:	89 c3                	mov    %eax,%ebx
  800df8:	89 d8                	mov    %ebx,%eax
  800dfa:	89 fa                	mov    %edi,%edx
  800dfc:	83 c4 1c             	add    $0x1c,%esp
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    
  800e04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e08:	39 ce                	cmp    %ecx,%esi
  800e0a:	72 0c                	jb     800e18 <__udivdi3+0x118>
  800e0c:	31 db                	xor    %ebx,%ebx
  800e0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e12:	0f 87 34 ff ff ff    	ja     800d4c <__udivdi3+0x4c>
  800e18:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e1d:	e9 2a ff ff ff       	jmp    800d4c <__udivdi3+0x4c>
  800e22:	66 90                	xchg   %ax,%ax
  800e24:	66 90                	xchg   %ax,%ax
  800e26:	66 90                	xchg   %ax,%ax
  800e28:	66 90                	xchg   %ax,%ax
  800e2a:	66 90                	xchg   %ax,%ax
  800e2c:	66 90                	xchg   %ax,%ax
  800e2e:	66 90                	xchg   %ax,%ax

00800e30 <__umoddi3>:
  800e30:	55                   	push   %ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 1c             	sub    $0x1c,%esp
  800e37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e47:	85 d2                	test   %edx,%edx
  800e49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e51:	89 f3                	mov    %esi,%ebx
  800e53:	89 3c 24             	mov    %edi,(%esp)
  800e56:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e5a:	75 1c                	jne    800e78 <__umoddi3+0x48>
  800e5c:	39 f7                	cmp    %esi,%edi
  800e5e:	76 50                	jbe    800eb0 <__umoddi3+0x80>
  800e60:	89 c8                	mov    %ecx,%eax
  800e62:	89 f2                	mov    %esi,%edx
  800e64:	f7 f7                	div    %edi
  800e66:	89 d0                	mov    %edx,%eax
  800e68:	31 d2                	xor    %edx,%edx
  800e6a:	83 c4 1c             	add    $0x1c,%esp
  800e6d:	5b                   	pop    %ebx
  800e6e:	5e                   	pop    %esi
  800e6f:	5f                   	pop    %edi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    
  800e72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e78:	39 f2                	cmp    %esi,%edx
  800e7a:	89 d0                	mov    %edx,%eax
  800e7c:	77 52                	ja     800ed0 <__umoddi3+0xa0>
  800e7e:	0f bd ea             	bsr    %edx,%ebp
  800e81:	83 f5 1f             	xor    $0x1f,%ebp
  800e84:	75 5a                	jne    800ee0 <__umoddi3+0xb0>
  800e86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e8a:	0f 82 e0 00 00 00    	jb     800f70 <__umoddi3+0x140>
  800e90:	39 0c 24             	cmp    %ecx,(%esp)
  800e93:	0f 86 d7 00 00 00    	jbe    800f70 <__umoddi3+0x140>
  800e99:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ea1:	83 c4 1c             	add    $0x1c,%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	85 ff                	test   %edi,%edi
  800eb2:	89 fd                	mov    %edi,%ebp
  800eb4:	75 0b                	jne    800ec1 <__umoddi3+0x91>
  800eb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebb:	31 d2                	xor    %edx,%edx
  800ebd:	f7 f7                	div    %edi
  800ebf:	89 c5                	mov    %eax,%ebp
  800ec1:	89 f0                	mov    %esi,%eax
  800ec3:	31 d2                	xor    %edx,%edx
  800ec5:	f7 f5                	div    %ebp
  800ec7:	89 c8                	mov    %ecx,%eax
  800ec9:	f7 f5                	div    %ebp
  800ecb:	89 d0                	mov    %edx,%eax
  800ecd:	eb 99                	jmp    800e68 <__umoddi3+0x38>
  800ecf:	90                   	nop
  800ed0:	89 c8                	mov    %ecx,%eax
  800ed2:	89 f2                	mov    %esi,%edx
  800ed4:	83 c4 1c             	add    $0x1c,%esp
  800ed7:	5b                   	pop    %ebx
  800ed8:	5e                   	pop    %esi
  800ed9:	5f                   	pop    %edi
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    
  800edc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	8b 34 24             	mov    (%esp),%esi
  800ee3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ee8:	89 e9                	mov    %ebp,%ecx
  800eea:	29 ef                	sub    %ebp,%edi
  800eec:	d3 e0                	shl    %cl,%eax
  800eee:	89 f9                	mov    %edi,%ecx
  800ef0:	89 f2                	mov    %esi,%edx
  800ef2:	d3 ea                	shr    %cl,%edx
  800ef4:	89 e9                	mov    %ebp,%ecx
  800ef6:	09 c2                	or     %eax,%edx
  800ef8:	89 d8                	mov    %ebx,%eax
  800efa:	89 14 24             	mov    %edx,(%esp)
  800efd:	89 f2                	mov    %esi,%edx
  800eff:	d3 e2                	shl    %cl,%edx
  800f01:	89 f9                	mov    %edi,%ecx
  800f03:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f07:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f0b:	d3 e8                	shr    %cl,%eax
  800f0d:	89 e9                	mov    %ebp,%ecx
  800f0f:	89 c6                	mov    %eax,%esi
  800f11:	d3 e3                	shl    %cl,%ebx
  800f13:	89 f9                	mov    %edi,%ecx
  800f15:	89 d0                	mov    %edx,%eax
  800f17:	d3 e8                	shr    %cl,%eax
  800f19:	89 e9                	mov    %ebp,%ecx
  800f1b:	09 d8                	or     %ebx,%eax
  800f1d:	89 d3                	mov    %edx,%ebx
  800f1f:	89 f2                	mov    %esi,%edx
  800f21:	f7 34 24             	divl   (%esp)
  800f24:	89 d6                	mov    %edx,%esi
  800f26:	d3 e3                	shl    %cl,%ebx
  800f28:	f7 64 24 04          	mull   0x4(%esp)
  800f2c:	39 d6                	cmp    %edx,%esi
  800f2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f32:	89 d1                	mov    %edx,%ecx
  800f34:	89 c3                	mov    %eax,%ebx
  800f36:	72 08                	jb     800f40 <__umoddi3+0x110>
  800f38:	75 11                	jne    800f4b <__umoddi3+0x11b>
  800f3a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f3e:	73 0b                	jae    800f4b <__umoddi3+0x11b>
  800f40:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f44:	1b 14 24             	sbb    (%esp),%edx
  800f47:	89 d1                	mov    %edx,%ecx
  800f49:	89 c3                	mov    %eax,%ebx
  800f4b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f4f:	29 da                	sub    %ebx,%edx
  800f51:	19 ce                	sbb    %ecx,%esi
  800f53:	89 f9                	mov    %edi,%ecx
  800f55:	89 f0                	mov    %esi,%eax
  800f57:	d3 e0                	shl    %cl,%eax
  800f59:	89 e9                	mov    %ebp,%ecx
  800f5b:	d3 ea                	shr    %cl,%edx
  800f5d:	89 e9                	mov    %ebp,%ecx
  800f5f:	d3 ee                	shr    %cl,%esi
  800f61:	09 d0                	or     %edx,%eax
  800f63:	89 f2                	mov    %esi,%edx
  800f65:	83 c4 1c             	add    $0x1c,%esp
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    
  800f6d:	8d 76 00             	lea    0x0(%esi),%esi
  800f70:	29 f9                	sub    %edi,%ecx
  800f72:	19 d6                	sbb    %edx,%esi
  800f74:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f7c:	e9 18 ff ff ff       	jmp    800e99 <__umoddi3+0x69>
