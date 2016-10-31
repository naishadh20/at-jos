
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
  80004e:	e8 c6 00 00 00       	call   800119 <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800060:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800065:	85 db                	test   %ebx,%ebx
  800067:	7e 07                	jle    800070 <libmain+0x37>
		binaryname = argv[0];
  800069:	8b 06                	mov    (%esi),%eax
  80006b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800070:	83 ec 08             	sub    $0x8,%esp
  800073:	56                   	push   %esi
  800074:	53                   	push   %ebx
  800075:	e8 b9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007a:	e8 0a 00 00 00       	call   800089 <exit>
}
  80007f:	83 c4 10             	add    $0x10,%esp
  800082:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800085:	5b                   	pop    %ebx
  800086:	5e                   	pop    %esi
  800087:	5d                   	pop    %ebp
  800088:	c3                   	ret    

00800089 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800089:	55                   	push   %ebp
  80008a:	89 e5                	mov    %esp,%ebp
  80008c:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008f:	6a 00                	push   $0x0
  800091:	e8 42 00 00 00       	call   8000d8 <sys_env_destroy>
}
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	c9                   	leave  
  80009a:	c3                   	ret    

0080009b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009b:	55                   	push   %ebp
  80009c:	89 e5                	mov    %esp,%ebp
  80009e:	57                   	push   %edi
  80009f:	56                   	push   %esi
  8000a0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ac:	89 c3                	mov    %eax,%ebx
  8000ae:	89 c7                	mov    %eax,%edi
  8000b0:	89 c6                	mov    %eax,%esi
  8000b2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b4:	5b                   	pop    %ebx
  8000b5:	5e                   	pop    %esi
  8000b6:	5f                   	pop    %edi
  8000b7:	5d                   	pop    %ebp
  8000b8:	c3                   	ret    

008000b9 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	57                   	push   %edi
  8000bd:	56                   	push   %esi
  8000be:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c9:	89 d1                	mov    %edx,%ecx
  8000cb:	89 d3                	mov    %edx,%ebx
  8000cd:	89 d7                	mov    %edx,%edi
  8000cf:	89 d6                	mov    %edx,%esi
  8000d1:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d3:	5b                   	pop    %ebx
  8000d4:	5e                   	pop    %esi
  8000d5:	5f                   	pop    %edi
  8000d6:	5d                   	pop    %ebp
  8000d7:	c3                   	ret    

008000d8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	57                   	push   %edi
  8000dc:	56                   	push   %esi
  8000dd:	53                   	push   %ebx
  8000de:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e6:	b8 03 00 00 00       	mov    $0x3,%eax
  8000eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ee:	89 cb                	mov    %ecx,%ebx
  8000f0:	89 cf                	mov    %ecx,%edi
  8000f2:	89 ce                	mov    %ecx,%esi
  8000f4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f6:	85 c0                	test   %eax,%eax
  8000f8:	7e 17                	jle    800111 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fa:	83 ec 0c             	sub    $0xc,%esp
  8000fd:	50                   	push   %eax
  8000fe:	6a 03                	push   $0x3
  800100:	68 8a 0f 80 00       	push   $0x800f8a
  800105:	6a 23                	push   $0x23
  800107:	68 a7 0f 80 00       	push   $0x800fa7
  80010c:	e8 f5 01 00 00       	call   800306 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800111:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800114:	5b                   	pop    %ebx
  800115:	5e                   	pop    %esi
  800116:	5f                   	pop    %edi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	57                   	push   %edi
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011f:	ba 00 00 00 00       	mov    $0x0,%edx
  800124:	b8 02 00 00 00       	mov    $0x2,%eax
  800129:	89 d1                	mov    %edx,%ecx
  80012b:	89 d3                	mov    %edx,%ebx
  80012d:	89 d7                	mov    %edx,%edi
  80012f:	89 d6                	mov    %edx,%esi
  800131:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800133:	5b                   	pop    %ebx
  800134:	5e                   	pop    %esi
  800135:	5f                   	pop    %edi
  800136:	5d                   	pop    %ebp
  800137:	c3                   	ret    

00800138 <sys_yield>:

void
sys_yield(void)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	57                   	push   %edi
  80013c:	56                   	push   %esi
  80013d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013e:	ba 00 00 00 00       	mov    $0x0,%edx
  800143:	b8 0a 00 00 00       	mov    $0xa,%eax
  800148:	89 d1                	mov    %edx,%ecx
  80014a:	89 d3                	mov    %edx,%ebx
  80014c:	89 d7                	mov    %edx,%edi
  80014e:	89 d6                	mov    %edx,%esi
  800150:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800152:	5b                   	pop    %ebx
  800153:	5e                   	pop    %esi
  800154:	5f                   	pop    %edi
  800155:	5d                   	pop    %ebp
  800156:	c3                   	ret    

00800157 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	57                   	push   %edi
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
  80015d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800160:	be 00 00 00 00       	mov    $0x0,%esi
  800165:	b8 04 00 00 00       	mov    $0x4,%eax
  80016a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016d:	8b 55 08             	mov    0x8(%ebp),%edx
  800170:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800173:	89 f7                	mov    %esi,%edi
  800175:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800177:	85 c0                	test   %eax,%eax
  800179:	7e 17                	jle    800192 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017b:	83 ec 0c             	sub    $0xc,%esp
  80017e:	50                   	push   %eax
  80017f:	6a 04                	push   $0x4
  800181:	68 8a 0f 80 00       	push   $0x800f8a
  800186:	6a 23                	push   $0x23
  800188:	68 a7 0f 80 00       	push   $0x800fa7
  80018d:	e8 74 01 00 00       	call   800306 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800192:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800195:	5b                   	pop    %ebx
  800196:	5e                   	pop    %esi
  800197:	5f                   	pop    %edi
  800198:	5d                   	pop    %ebp
  800199:	c3                   	ret    

0080019a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019a:	55                   	push   %ebp
  80019b:	89 e5                	mov    %esp,%ebp
  80019d:	57                   	push   %edi
  80019e:	56                   	push   %esi
  80019f:	53                   	push   %ebx
  8001a0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a3:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b4:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b9:	85 c0                	test   %eax,%eax
  8001bb:	7e 17                	jle    8001d4 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bd:	83 ec 0c             	sub    $0xc,%esp
  8001c0:	50                   	push   %eax
  8001c1:	6a 05                	push   $0x5
  8001c3:	68 8a 0f 80 00       	push   $0x800f8a
  8001c8:	6a 23                	push   $0x23
  8001ca:	68 a7 0f 80 00       	push   $0x800fa7
  8001cf:	e8 32 01 00 00       	call   800306 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d7:	5b                   	pop    %ebx
  8001d8:	5e                   	pop    %esi
  8001d9:	5f                   	pop    %edi
  8001da:	5d                   	pop    %ebp
  8001db:	c3                   	ret    

008001dc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	57                   	push   %edi
  8001e0:	56                   	push   %esi
  8001e1:	53                   	push   %ebx
  8001e2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ea:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f5:	89 df                	mov    %ebx,%edi
  8001f7:	89 de                	mov    %ebx,%esi
  8001f9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	7e 17                	jle    800216 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ff:	83 ec 0c             	sub    $0xc,%esp
  800202:	50                   	push   %eax
  800203:	6a 06                	push   $0x6
  800205:	68 8a 0f 80 00       	push   $0x800f8a
  80020a:	6a 23                	push   $0x23
  80020c:	68 a7 0f 80 00       	push   $0x800fa7
  800211:	e8 f0 00 00 00       	call   800306 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800216:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800219:	5b                   	pop    %ebx
  80021a:	5e                   	pop    %esi
  80021b:	5f                   	pop    %edi
  80021c:	5d                   	pop    %ebp
  80021d:	c3                   	ret    

0080021e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	57                   	push   %edi
  800222:	56                   	push   %esi
  800223:	53                   	push   %ebx
  800224:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800227:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022c:	b8 08 00 00 00       	mov    $0x8,%eax
  800231:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800234:	8b 55 08             	mov    0x8(%ebp),%edx
  800237:	89 df                	mov    %ebx,%edi
  800239:	89 de                	mov    %ebx,%esi
  80023b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023d:	85 c0                	test   %eax,%eax
  80023f:	7e 17                	jle    800258 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800241:	83 ec 0c             	sub    $0xc,%esp
  800244:	50                   	push   %eax
  800245:	6a 08                	push   $0x8
  800247:	68 8a 0f 80 00       	push   $0x800f8a
  80024c:	6a 23                	push   $0x23
  80024e:	68 a7 0f 80 00       	push   $0x800fa7
  800253:	e8 ae 00 00 00       	call   800306 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800258:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025b:	5b                   	pop    %ebx
  80025c:	5e                   	pop    %esi
  80025d:	5f                   	pop    %edi
  80025e:	5d                   	pop    %ebp
  80025f:	c3                   	ret    

00800260 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800269:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026e:	b8 09 00 00 00       	mov    $0x9,%eax
  800273:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800276:	8b 55 08             	mov    0x8(%ebp),%edx
  800279:	89 df                	mov    %ebx,%edi
  80027b:	89 de                	mov    %ebx,%esi
  80027d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027f:	85 c0                	test   %eax,%eax
  800281:	7e 17                	jle    80029a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800283:	83 ec 0c             	sub    $0xc,%esp
  800286:	50                   	push   %eax
  800287:	6a 09                	push   $0x9
  800289:	68 8a 0f 80 00       	push   $0x800f8a
  80028e:	6a 23                	push   $0x23
  800290:	68 a7 0f 80 00       	push   $0x800fa7
  800295:	e8 6c 00 00 00       	call   800306 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80029a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029d:	5b                   	pop    %ebx
  80029e:	5e                   	pop    %esi
  80029f:	5f                   	pop    %edi
  8002a0:	5d                   	pop    %ebp
  8002a1:	c3                   	ret    

008002a2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	57                   	push   %edi
  8002a6:	56                   	push   %esi
  8002a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a8:	be 00 00 00 00       	mov    $0x0,%esi
  8002ad:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002bb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002be:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5f                   	pop    %edi
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    

008002c5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002db:	89 cb                	mov    %ecx,%ebx
  8002dd:	89 cf                	mov    %ecx,%edi
  8002df:	89 ce                	mov    %ecx,%esi
  8002e1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e3:	85 c0                	test   %eax,%eax
  8002e5:	7e 17                	jle    8002fe <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e7:	83 ec 0c             	sub    $0xc,%esp
  8002ea:	50                   	push   %eax
  8002eb:	6a 0c                	push   $0xc
  8002ed:	68 8a 0f 80 00       	push   $0x800f8a
  8002f2:	6a 23                	push   $0x23
  8002f4:	68 a7 0f 80 00       	push   $0x800fa7
  8002f9:	e8 08 00 00 00       	call   800306 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80030b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80030e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800314:	e8 00 fe ff ff       	call   800119 <sys_getenvid>
  800319:	83 ec 0c             	sub    $0xc,%esp
  80031c:	ff 75 0c             	pushl  0xc(%ebp)
  80031f:	ff 75 08             	pushl  0x8(%ebp)
  800322:	56                   	push   %esi
  800323:	50                   	push   %eax
  800324:	68 b8 0f 80 00       	push   $0x800fb8
  800329:	e8 b1 00 00 00       	call   8003df <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80032e:	83 c4 18             	add    $0x18,%esp
  800331:	53                   	push   %ebx
  800332:	ff 75 10             	pushl  0x10(%ebp)
  800335:	e8 54 00 00 00       	call   80038e <vcprintf>
	cprintf("\n");
  80033a:	c7 04 24 10 10 80 00 	movl   $0x801010,(%esp)
  800341:	e8 99 00 00 00       	call   8003df <cprintf>
  800346:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800349:	cc                   	int3   
  80034a:	eb fd                	jmp    800349 <_panic+0x43>

0080034c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80034c:	55                   	push   %ebp
  80034d:	89 e5                	mov    %esp,%ebp
  80034f:	53                   	push   %ebx
  800350:	83 ec 04             	sub    $0x4,%esp
  800353:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800356:	8b 13                	mov    (%ebx),%edx
  800358:	8d 42 01             	lea    0x1(%edx),%eax
  80035b:	89 03                	mov    %eax,(%ebx)
  80035d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800360:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800364:	3d ff 00 00 00       	cmp    $0xff,%eax
  800369:	75 1a                	jne    800385 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80036b:	83 ec 08             	sub    $0x8,%esp
  80036e:	68 ff 00 00 00       	push   $0xff
  800373:	8d 43 08             	lea    0x8(%ebx),%eax
  800376:	50                   	push   %eax
  800377:	e8 1f fd ff ff       	call   80009b <sys_cputs>
		b->idx = 0;
  80037c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800382:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800385:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800389:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80038c:	c9                   	leave  
  80038d:	c3                   	ret    

0080038e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800397:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80039e:	00 00 00 
	b.cnt = 0;
  8003a1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ab:	ff 75 0c             	pushl  0xc(%ebp)
  8003ae:	ff 75 08             	pushl  0x8(%ebp)
  8003b1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b7:	50                   	push   %eax
  8003b8:	68 4c 03 80 00       	push   $0x80034c
  8003bd:	e8 54 01 00 00       	call   800516 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c2:	83 c4 08             	add    $0x8,%esp
  8003c5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003cb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d1:	50                   	push   %eax
  8003d2:	e8 c4 fc ff ff       	call   80009b <sys_cputs>

	return b.cnt;
}
  8003d7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003dd:	c9                   	leave  
  8003de:	c3                   	ret    

008003df <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e8:	50                   	push   %eax
  8003e9:	ff 75 08             	pushl  0x8(%ebp)
  8003ec:	e8 9d ff ff ff       	call   80038e <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f1:	c9                   	leave  
  8003f2:	c3                   	ret    

008003f3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f3:	55                   	push   %ebp
  8003f4:	89 e5                	mov    %esp,%ebp
  8003f6:	57                   	push   %edi
  8003f7:	56                   	push   %esi
  8003f8:	53                   	push   %ebx
  8003f9:	83 ec 1c             	sub    $0x1c,%esp
  8003fc:	89 c7                	mov    %eax,%edi
  8003fe:	89 d6                	mov    %edx,%esi
  800400:	8b 45 08             	mov    0x8(%ebp),%eax
  800403:	8b 55 0c             	mov    0xc(%ebp),%edx
  800406:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800409:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80040c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80040f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800414:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800417:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80041a:	39 d3                	cmp    %edx,%ebx
  80041c:	72 05                	jb     800423 <printnum+0x30>
  80041e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800421:	77 45                	ja     800468 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800423:	83 ec 0c             	sub    $0xc,%esp
  800426:	ff 75 18             	pushl  0x18(%ebp)
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80042f:	53                   	push   %ebx
  800430:	ff 75 10             	pushl  0x10(%ebp)
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	ff 75 e4             	pushl  -0x1c(%ebp)
  800439:	ff 75 e0             	pushl  -0x20(%ebp)
  80043c:	ff 75 dc             	pushl  -0x24(%ebp)
  80043f:	ff 75 d8             	pushl  -0x28(%ebp)
  800442:	e8 a9 08 00 00       	call   800cf0 <__udivdi3>
  800447:	83 c4 18             	add    $0x18,%esp
  80044a:	52                   	push   %edx
  80044b:	50                   	push   %eax
  80044c:	89 f2                	mov    %esi,%edx
  80044e:	89 f8                	mov    %edi,%eax
  800450:	e8 9e ff ff ff       	call   8003f3 <printnum>
  800455:	83 c4 20             	add    $0x20,%esp
  800458:	eb 18                	jmp    800472 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	56                   	push   %esi
  80045e:	ff 75 18             	pushl  0x18(%ebp)
  800461:	ff d7                	call   *%edi
  800463:	83 c4 10             	add    $0x10,%esp
  800466:	eb 03                	jmp    80046b <printnum+0x78>
  800468:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80046b:	83 eb 01             	sub    $0x1,%ebx
  80046e:	85 db                	test   %ebx,%ebx
  800470:	7f e8                	jg     80045a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800472:	83 ec 08             	sub    $0x8,%esp
  800475:	56                   	push   %esi
  800476:	83 ec 04             	sub    $0x4,%esp
  800479:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047c:	ff 75 e0             	pushl  -0x20(%ebp)
  80047f:	ff 75 dc             	pushl  -0x24(%ebp)
  800482:	ff 75 d8             	pushl  -0x28(%ebp)
  800485:	e8 96 09 00 00       	call   800e20 <__umoddi3>
  80048a:	83 c4 14             	add    $0x14,%esp
  80048d:	0f be 80 dc 0f 80 00 	movsbl 0x800fdc(%eax),%eax
  800494:	50                   	push   %eax
  800495:	ff d7                	call   *%edi
}
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80049d:	5b                   	pop    %ebx
  80049e:	5e                   	pop    %esi
  80049f:	5f                   	pop    %edi
  8004a0:	5d                   	pop    %ebp
  8004a1:	c3                   	ret    

008004a2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a2:	55                   	push   %ebp
  8004a3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004a5:	83 fa 01             	cmp    $0x1,%edx
  8004a8:	7e 0e                	jle    8004b8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004aa:	8b 10                	mov    (%eax),%edx
  8004ac:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004af:	89 08                	mov    %ecx,(%eax)
  8004b1:	8b 02                	mov    (%edx),%eax
  8004b3:	8b 52 04             	mov    0x4(%edx),%edx
  8004b6:	eb 22                	jmp    8004da <getuint+0x38>
	else if (lflag)
  8004b8:	85 d2                	test   %edx,%edx
  8004ba:	74 10                	je     8004cc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004bc:	8b 10                	mov    (%eax),%edx
  8004be:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c1:	89 08                	mov    %ecx,(%eax)
  8004c3:	8b 02                	mov    (%edx),%eax
  8004c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ca:	eb 0e                	jmp    8004da <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004cc:	8b 10                	mov    (%eax),%edx
  8004ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d1:	89 08                	mov    %ecx,(%eax)
  8004d3:	8b 02                	mov    (%edx),%eax
  8004d5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004da:	5d                   	pop    %ebp
  8004db:	c3                   	ret    

008004dc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004e6:	8b 10                	mov    (%eax),%edx
  8004e8:	3b 50 04             	cmp    0x4(%eax),%edx
  8004eb:	73 0a                	jae    8004f7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ed:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f0:	89 08                	mov    %ecx,(%eax)
  8004f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f5:	88 02                	mov    %al,(%edx)
}
  8004f7:	5d                   	pop    %ebp
  8004f8:	c3                   	ret    

008004f9 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004f9:	55                   	push   %ebp
  8004fa:	89 e5                	mov    %esp,%ebp
  8004fc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004ff:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800502:	50                   	push   %eax
  800503:	ff 75 10             	pushl  0x10(%ebp)
  800506:	ff 75 0c             	pushl  0xc(%ebp)
  800509:	ff 75 08             	pushl  0x8(%ebp)
  80050c:	e8 05 00 00 00       	call   800516 <vprintfmt>
	va_end(ap);
}
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	c9                   	leave  
  800515:	c3                   	ret    

00800516 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	57                   	push   %edi
  80051a:	56                   	push   %esi
  80051b:	53                   	push   %ebx
  80051c:	83 ec 2c             	sub    $0x2c,%esp
  80051f:	8b 75 08             	mov    0x8(%ebp),%esi
  800522:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800525:	8b 7d 10             	mov    0x10(%ebp),%edi
  800528:	eb 12                	jmp    80053c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80052a:	85 c0                	test   %eax,%eax
  80052c:	0f 84 cb 03 00 00    	je     8008fd <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	53                   	push   %ebx
  800536:	50                   	push   %eax
  800537:	ff d6                	call   *%esi
  800539:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80053c:	83 c7 01             	add    $0x1,%edi
  80053f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800543:	83 f8 25             	cmp    $0x25,%eax
  800546:	75 e2                	jne    80052a <vprintfmt+0x14>
  800548:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80054c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800553:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80055a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800561:	ba 00 00 00 00       	mov    $0x0,%edx
  800566:	eb 07                	jmp    80056f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800568:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80056b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8d 47 01             	lea    0x1(%edi),%eax
  800572:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800575:	0f b6 07             	movzbl (%edi),%eax
  800578:	0f b6 c8             	movzbl %al,%ecx
  80057b:	83 e8 23             	sub    $0x23,%eax
  80057e:	3c 55                	cmp    $0x55,%al
  800580:	0f 87 5c 03 00 00    	ja     8008e2 <vprintfmt+0x3cc>
  800586:	0f b6 c0             	movzbl %al,%eax
  800589:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  800590:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800593:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800597:	eb d6                	jmp    80056f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800599:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059c:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005ab:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005ae:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005b1:	83 fa 09             	cmp    $0x9,%edx
  8005b4:	77 39                	ja     8005ef <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005b6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005b9:	eb e9                	jmp    8005a4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8d 48 04             	lea    0x4(%eax),%ecx
  8005c1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005c4:	8b 00                	mov    (%eax),%eax
  8005c6:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005cc:	eb 27                	jmp    8005f5 <vprintfmt+0xdf>
  8005ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d1:	85 c0                	test   %eax,%eax
  8005d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d8:	0f 49 c8             	cmovns %eax,%ecx
  8005db:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e1:	eb 8c                	jmp    80056f <vprintfmt+0x59>
  8005e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005e6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ed:	eb 80                	jmp    80056f <vprintfmt+0x59>
  8005ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f2:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8005f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f9:	0f 89 70 ff ff ff    	jns    80056f <vprintfmt+0x59>
				width = precision, precision = -1;
  8005ff:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800602:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800605:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80060c:	e9 5e ff ff ff       	jmp    80056f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800611:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800614:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800617:	e9 53 ff ff ff       	jmp    80056f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 04             	lea    0x4(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)
  800625:	83 ec 08             	sub    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	ff 30                	pushl  (%eax)
  80062b:	ff d6                	call   *%esi
			break;
  80062d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800630:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800633:	e9 04 ff ff ff       	jmp    80053c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8d 50 04             	lea    0x4(%eax),%edx
  80063e:	89 55 14             	mov    %edx,0x14(%ebp)
  800641:	8b 00                	mov    (%eax),%eax
  800643:	99                   	cltd   
  800644:	31 d0                	xor    %edx,%eax
  800646:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800648:	83 f8 09             	cmp    $0x9,%eax
  80064b:	7f 0b                	jg     800658 <vprintfmt+0x142>
  80064d:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800654:	85 d2                	test   %edx,%edx
  800656:	75 18                	jne    800670 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800658:	50                   	push   %eax
  800659:	68 f4 0f 80 00       	push   $0x800ff4
  80065e:	53                   	push   %ebx
  80065f:	56                   	push   %esi
  800660:	e8 94 fe ff ff       	call   8004f9 <printfmt>
  800665:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800668:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80066b:	e9 cc fe ff ff       	jmp    80053c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800670:	52                   	push   %edx
  800671:	68 fd 0f 80 00       	push   $0x800ffd
  800676:	53                   	push   %ebx
  800677:	56                   	push   %esi
  800678:	e8 7c fe ff ff       	call   8004f9 <printfmt>
  80067d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800680:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800683:	e9 b4 fe ff ff       	jmp    80053c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8d 50 04             	lea    0x4(%eax),%edx
  80068e:	89 55 14             	mov    %edx,0x14(%ebp)
  800691:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800693:	85 ff                	test   %edi,%edi
  800695:	b8 ed 0f 80 00       	mov    $0x800fed,%eax
  80069a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80069d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a1:	0f 8e 94 00 00 00    	jle    80073b <vprintfmt+0x225>
  8006a7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006ab:	0f 84 98 00 00 00    	je     800749 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	ff 75 c8             	pushl  -0x38(%ebp)
  8006b7:	57                   	push   %edi
  8006b8:	e8 c8 02 00 00       	call   800985 <strnlen>
  8006bd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006c0:	29 c1                	sub    %eax,%ecx
  8006c2:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006c5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006c8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006cf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006d2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d4:	eb 0f                	jmp    8006e5 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	ff 75 e0             	pushl  -0x20(%ebp)
  8006dd:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006df:	83 ef 01             	sub    $0x1,%edi
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	85 ff                	test   %edi,%edi
  8006e7:	7f ed                	jg     8006d6 <vprintfmt+0x1c0>
  8006e9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006ec:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006ef:	85 c9                	test   %ecx,%ecx
  8006f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f6:	0f 49 c1             	cmovns %ecx,%eax
  8006f9:	29 c1                	sub    %eax,%ecx
  8006fb:	89 75 08             	mov    %esi,0x8(%ebp)
  8006fe:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800701:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800704:	89 cb                	mov    %ecx,%ebx
  800706:	eb 4d                	jmp    800755 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800708:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80070c:	74 1b                	je     800729 <vprintfmt+0x213>
  80070e:	0f be c0             	movsbl %al,%eax
  800711:	83 e8 20             	sub    $0x20,%eax
  800714:	83 f8 5e             	cmp    $0x5e,%eax
  800717:	76 10                	jbe    800729 <vprintfmt+0x213>
					putch('?', putdat);
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	ff 75 0c             	pushl  0xc(%ebp)
  80071f:	6a 3f                	push   $0x3f
  800721:	ff 55 08             	call   *0x8(%ebp)
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	eb 0d                	jmp    800736 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800729:	83 ec 08             	sub    $0x8,%esp
  80072c:	ff 75 0c             	pushl  0xc(%ebp)
  80072f:	52                   	push   %edx
  800730:	ff 55 08             	call   *0x8(%ebp)
  800733:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800736:	83 eb 01             	sub    $0x1,%ebx
  800739:	eb 1a                	jmp    800755 <vprintfmt+0x23f>
  80073b:	89 75 08             	mov    %esi,0x8(%ebp)
  80073e:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800741:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800744:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800747:	eb 0c                	jmp    800755 <vprintfmt+0x23f>
  800749:	89 75 08             	mov    %esi,0x8(%ebp)
  80074c:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80074f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800752:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800755:	83 c7 01             	add    $0x1,%edi
  800758:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80075c:	0f be d0             	movsbl %al,%edx
  80075f:	85 d2                	test   %edx,%edx
  800761:	74 23                	je     800786 <vprintfmt+0x270>
  800763:	85 f6                	test   %esi,%esi
  800765:	78 a1                	js     800708 <vprintfmt+0x1f2>
  800767:	83 ee 01             	sub    $0x1,%esi
  80076a:	79 9c                	jns    800708 <vprintfmt+0x1f2>
  80076c:	89 df                	mov    %ebx,%edi
  80076e:	8b 75 08             	mov    0x8(%ebp),%esi
  800771:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800774:	eb 18                	jmp    80078e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800776:	83 ec 08             	sub    $0x8,%esp
  800779:	53                   	push   %ebx
  80077a:	6a 20                	push   $0x20
  80077c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80077e:	83 ef 01             	sub    $0x1,%edi
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	eb 08                	jmp    80078e <vprintfmt+0x278>
  800786:	89 df                	mov    %ebx,%edi
  800788:	8b 75 08             	mov    0x8(%ebp),%esi
  80078b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80078e:	85 ff                	test   %edi,%edi
  800790:	7f e4                	jg     800776 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800792:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800795:	e9 a2 fd ff ff       	jmp    80053c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80079a:	83 fa 01             	cmp    $0x1,%edx
  80079d:	7e 16                	jle    8007b5 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	8d 50 08             	lea    0x8(%eax),%edx
  8007a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a8:	8b 50 04             	mov    0x4(%eax),%edx
  8007ab:	8b 00                	mov    (%eax),%eax
  8007ad:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007b0:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007b3:	eb 32                	jmp    8007e7 <vprintfmt+0x2d1>
	else if (lflag)
  8007b5:	85 d2                	test   %edx,%edx
  8007b7:	74 18                	je     8007d1 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8d 50 04             	lea    0x4(%eax),%edx
  8007bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c2:	8b 00                	mov    (%eax),%eax
  8007c4:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007c7:	89 c1                	mov    %eax,%ecx
  8007c9:	c1 f9 1f             	sar    $0x1f,%ecx
  8007cc:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007cf:	eb 16                	jmp    8007e7 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8d 50 04             	lea    0x4(%eax),%edx
  8007d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007da:	8b 00                	mov    (%eax),%eax
  8007dc:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007df:	89 c1                	mov    %eax,%ecx
  8007e1:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007e7:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007ea:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f3:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007f8:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007fc:	0f 89 a8 00 00 00    	jns    8008aa <vprintfmt+0x394>
				putch('-', putdat);
  800802:	83 ec 08             	sub    $0x8,%esp
  800805:	53                   	push   %ebx
  800806:	6a 2d                	push   $0x2d
  800808:	ff d6                	call   *%esi
				num = -(long long) num;
  80080a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80080d:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800810:	f7 d8                	neg    %eax
  800812:	83 d2 00             	adc    $0x0,%edx
  800815:	f7 da                	neg    %edx
  800817:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80081a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80081d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800820:	b8 0a 00 00 00       	mov    $0xa,%eax
  800825:	e9 80 00 00 00       	jmp    8008aa <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80082a:	8d 45 14             	lea    0x14(%ebp),%eax
  80082d:	e8 70 fc ff ff       	call   8004a2 <getuint>
  800832:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800835:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800838:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80083d:	eb 6b                	jmp    8008aa <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80083f:	8d 45 14             	lea    0x14(%ebp),%eax
  800842:	e8 5b fc ff ff       	call   8004a2 <getuint>
  800847:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80084a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  80084d:	6a 04                	push   $0x4
  80084f:	6a 03                	push   $0x3
  800851:	6a 01                	push   $0x1
  800853:	68 00 10 80 00       	push   $0x801000
  800858:	e8 82 fb ff ff       	call   8003df <cprintf>
			goto number;
  80085d:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  800860:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  800865:	eb 43                	jmp    8008aa <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	53                   	push   %ebx
  80086b:	6a 30                	push   $0x30
  80086d:	ff d6                	call   *%esi
			putch('x', putdat);
  80086f:	83 c4 08             	add    $0x8,%esp
  800872:	53                   	push   %ebx
  800873:	6a 78                	push   $0x78
  800875:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800877:	8b 45 14             	mov    0x14(%ebp),%eax
  80087a:	8d 50 04             	lea    0x4(%eax),%edx
  80087d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800880:	8b 00                	mov    (%eax),%eax
  800882:	ba 00 00 00 00       	mov    $0x0,%edx
  800887:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80088a:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80088d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800890:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800895:	eb 13                	jmp    8008aa <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800897:	8d 45 14             	lea    0x14(%ebp),%eax
  80089a:	e8 03 fc ff ff       	call   8004a2 <getuint>
  80089f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008a5:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008aa:	83 ec 0c             	sub    $0xc,%esp
  8008ad:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8008b1:	52                   	push   %edx
  8008b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b5:	50                   	push   %eax
  8008b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8008b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8008bc:	89 da                	mov    %ebx,%edx
  8008be:	89 f0                	mov    %esi,%eax
  8008c0:	e8 2e fb ff ff       	call   8003f3 <printnum>

			break;
  8008c5:	83 c4 20             	add    $0x20,%esp
  8008c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008cb:	e9 6c fc ff ff       	jmp    80053c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008d0:	83 ec 08             	sub    $0x8,%esp
  8008d3:	53                   	push   %ebx
  8008d4:	51                   	push   %ecx
  8008d5:	ff d6                	call   *%esi
			break;
  8008d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008dd:	e9 5a fc ff ff       	jmp    80053c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008e2:	83 ec 08             	sub    $0x8,%esp
  8008e5:	53                   	push   %ebx
  8008e6:	6a 25                	push   $0x25
  8008e8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	eb 03                	jmp    8008f2 <vprintfmt+0x3dc>
  8008ef:	83 ef 01             	sub    $0x1,%edi
  8008f2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008f6:	75 f7                	jne    8008ef <vprintfmt+0x3d9>
  8008f8:	e9 3f fc ff ff       	jmp    80053c <vprintfmt+0x26>
			break;
		}

	}

}
  8008fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5f                   	pop    %edi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	83 ec 18             	sub    $0x18,%esp
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800911:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800914:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800918:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80091b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800922:	85 c0                	test   %eax,%eax
  800924:	74 26                	je     80094c <vsnprintf+0x47>
  800926:	85 d2                	test   %edx,%edx
  800928:	7e 22                	jle    80094c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80092a:	ff 75 14             	pushl  0x14(%ebp)
  80092d:	ff 75 10             	pushl  0x10(%ebp)
  800930:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800933:	50                   	push   %eax
  800934:	68 dc 04 80 00       	push   $0x8004dc
  800939:	e8 d8 fb ff ff       	call   800516 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80093e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800941:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800944:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800947:	83 c4 10             	add    $0x10,%esp
  80094a:	eb 05                	jmp    800951 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80094c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800951:	c9                   	leave  
  800952:	c3                   	ret    

00800953 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800959:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80095c:	50                   	push   %eax
  80095d:	ff 75 10             	pushl  0x10(%ebp)
  800960:	ff 75 0c             	pushl  0xc(%ebp)
  800963:	ff 75 08             	pushl  0x8(%ebp)
  800966:	e8 9a ff ff ff       	call   800905 <vsnprintf>
	va_end(ap);

	return rc;
}
  80096b:	c9                   	leave  
  80096c:	c3                   	ret    

0080096d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
  800978:	eb 03                	jmp    80097d <strlen+0x10>
		n++;
  80097a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80097d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800981:	75 f7                	jne    80097a <strlen+0xd>
		n++;
	return n;
}
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098e:	ba 00 00 00 00       	mov    $0x0,%edx
  800993:	eb 03                	jmp    800998 <strnlen+0x13>
		n++;
  800995:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800998:	39 c2                	cmp    %eax,%edx
  80099a:	74 08                	je     8009a4 <strnlen+0x1f>
  80099c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009a0:	75 f3                	jne    800995 <strnlen+0x10>
  8009a2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	53                   	push   %ebx
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009b0:	89 c2                	mov    %eax,%edx
  8009b2:	83 c2 01             	add    $0x1,%edx
  8009b5:	83 c1 01             	add    $0x1,%ecx
  8009b8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009bc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009bf:	84 db                	test   %bl,%bl
  8009c1:	75 ef                	jne    8009b2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009c3:	5b                   	pop    %ebx
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	53                   	push   %ebx
  8009ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009cd:	53                   	push   %ebx
  8009ce:	e8 9a ff ff ff       	call   80096d <strlen>
  8009d3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009d6:	ff 75 0c             	pushl  0xc(%ebp)
  8009d9:	01 d8                	add    %ebx,%eax
  8009db:	50                   	push   %eax
  8009dc:	e8 c5 ff ff ff       	call   8009a6 <strcpy>
	return dst;
}
  8009e1:	89 d8                	mov    %ebx,%eax
  8009e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e6:	c9                   	leave  
  8009e7:	c3                   	ret    

008009e8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f3:	89 f3                	mov    %esi,%ebx
  8009f5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f8:	89 f2                	mov    %esi,%edx
  8009fa:	eb 0f                	jmp    800a0b <strncpy+0x23>
		*dst++ = *src;
  8009fc:	83 c2 01             	add    $0x1,%edx
  8009ff:	0f b6 01             	movzbl (%ecx),%eax
  800a02:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a05:	80 39 01             	cmpb   $0x1,(%ecx)
  800a08:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0b:	39 da                	cmp    %ebx,%edx
  800a0d:	75 ed                	jne    8009fc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a0f:	89 f0                	mov    %esi,%eax
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a20:	8b 55 10             	mov    0x10(%ebp),%edx
  800a23:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a25:	85 d2                	test   %edx,%edx
  800a27:	74 21                	je     800a4a <strlcpy+0x35>
  800a29:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a2d:	89 f2                	mov    %esi,%edx
  800a2f:	eb 09                	jmp    800a3a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a31:	83 c2 01             	add    $0x1,%edx
  800a34:	83 c1 01             	add    $0x1,%ecx
  800a37:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a3a:	39 c2                	cmp    %eax,%edx
  800a3c:	74 09                	je     800a47 <strlcpy+0x32>
  800a3e:	0f b6 19             	movzbl (%ecx),%ebx
  800a41:	84 db                	test   %bl,%bl
  800a43:	75 ec                	jne    800a31 <strlcpy+0x1c>
  800a45:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a47:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a4a:	29 f0                	sub    %esi,%eax
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a56:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a59:	eb 06                	jmp    800a61 <strcmp+0x11>
		p++, q++;
  800a5b:	83 c1 01             	add    $0x1,%ecx
  800a5e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a61:	0f b6 01             	movzbl (%ecx),%eax
  800a64:	84 c0                	test   %al,%al
  800a66:	74 04                	je     800a6c <strcmp+0x1c>
  800a68:	3a 02                	cmp    (%edx),%al
  800a6a:	74 ef                	je     800a5b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a6c:	0f b6 c0             	movzbl %al,%eax
  800a6f:	0f b6 12             	movzbl (%edx),%edx
  800a72:	29 d0                	sub    %edx,%eax
}
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	53                   	push   %ebx
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a80:	89 c3                	mov    %eax,%ebx
  800a82:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a85:	eb 06                	jmp    800a8d <strncmp+0x17>
		n--, p++, q++;
  800a87:	83 c0 01             	add    $0x1,%eax
  800a8a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a8d:	39 d8                	cmp    %ebx,%eax
  800a8f:	74 15                	je     800aa6 <strncmp+0x30>
  800a91:	0f b6 08             	movzbl (%eax),%ecx
  800a94:	84 c9                	test   %cl,%cl
  800a96:	74 04                	je     800a9c <strncmp+0x26>
  800a98:	3a 0a                	cmp    (%edx),%cl
  800a9a:	74 eb                	je     800a87 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a9c:	0f b6 00             	movzbl (%eax),%eax
  800a9f:	0f b6 12             	movzbl (%edx),%edx
  800aa2:	29 d0                	sub    %edx,%eax
  800aa4:	eb 05                	jmp    800aab <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aab:	5b                   	pop    %ebx
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab8:	eb 07                	jmp    800ac1 <strchr+0x13>
		if (*s == c)
  800aba:	38 ca                	cmp    %cl,%dl
  800abc:	74 0f                	je     800acd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800abe:	83 c0 01             	add    $0x1,%eax
  800ac1:	0f b6 10             	movzbl (%eax),%edx
  800ac4:	84 d2                	test   %dl,%dl
  800ac6:	75 f2                	jne    800aba <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad9:	eb 03                	jmp    800ade <strfind+0xf>
  800adb:	83 c0 01             	add    $0x1,%eax
  800ade:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ae1:	38 ca                	cmp    %cl,%dl
  800ae3:	74 04                	je     800ae9 <strfind+0x1a>
  800ae5:	84 d2                	test   %dl,%dl
  800ae7:	75 f2                	jne    800adb <strfind+0xc>
			break;
	return (char *) s;
}
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	57                   	push   %edi
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
  800af1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800af7:	85 c9                	test   %ecx,%ecx
  800af9:	74 36                	je     800b31 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800afb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b01:	75 28                	jne    800b2b <memset+0x40>
  800b03:	f6 c1 03             	test   $0x3,%cl
  800b06:	75 23                	jne    800b2b <memset+0x40>
		c &= 0xFF;
  800b08:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b0c:	89 d3                	mov    %edx,%ebx
  800b0e:	c1 e3 08             	shl    $0x8,%ebx
  800b11:	89 d6                	mov    %edx,%esi
  800b13:	c1 e6 18             	shl    $0x18,%esi
  800b16:	89 d0                	mov    %edx,%eax
  800b18:	c1 e0 10             	shl    $0x10,%eax
  800b1b:	09 f0                	or     %esi,%eax
  800b1d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b1f:	89 d8                	mov    %ebx,%eax
  800b21:	09 d0                	or     %edx,%eax
  800b23:	c1 e9 02             	shr    $0x2,%ecx
  800b26:	fc                   	cld    
  800b27:	f3 ab                	rep stos %eax,%es:(%edi)
  800b29:	eb 06                	jmp    800b31 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2e:	fc                   	cld    
  800b2f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b31:	89 f8                	mov    %edi,%eax
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5f                   	pop    %edi
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b43:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b46:	39 c6                	cmp    %eax,%esi
  800b48:	73 35                	jae    800b7f <memmove+0x47>
  800b4a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b4d:	39 d0                	cmp    %edx,%eax
  800b4f:	73 2e                	jae    800b7f <memmove+0x47>
		s += n;
		d += n;
  800b51:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	09 fe                	or     %edi,%esi
  800b58:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b5e:	75 13                	jne    800b73 <memmove+0x3b>
  800b60:	f6 c1 03             	test   $0x3,%cl
  800b63:	75 0e                	jne    800b73 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b65:	83 ef 04             	sub    $0x4,%edi
  800b68:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b6b:	c1 e9 02             	shr    $0x2,%ecx
  800b6e:	fd                   	std    
  800b6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b71:	eb 09                	jmp    800b7c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b73:	83 ef 01             	sub    $0x1,%edi
  800b76:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b79:	fd                   	std    
  800b7a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b7c:	fc                   	cld    
  800b7d:	eb 1d                	jmp    800b9c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b7f:	89 f2                	mov    %esi,%edx
  800b81:	09 c2                	or     %eax,%edx
  800b83:	f6 c2 03             	test   $0x3,%dl
  800b86:	75 0f                	jne    800b97 <memmove+0x5f>
  800b88:	f6 c1 03             	test   $0x3,%cl
  800b8b:	75 0a                	jne    800b97 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b8d:	c1 e9 02             	shr    $0x2,%ecx
  800b90:	89 c7                	mov    %eax,%edi
  800b92:	fc                   	cld    
  800b93:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b95:	eb 05                	jmp    800b9c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b97:	89 c7                	mov    %eax,%edi
  800b99:	fc                   	cld    
  800b9a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ba3:	ff 75 10             	pushl  0x10(%ebp)
  800ba6:	ff 75 0c             	pushl  0xc(%ebp)
  800ba9:	ff 75 08             	pushl  0x8(%ebp)
  800bac:	e8 87 ff ff ff       	call   800b38 <memmove>
}
  800bb1:	c9                   	leave  
  800bb2:	c3                   	ret    

00800bb3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bbe:	89 c6                	mov    %eax,%esi
  800bc0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc3:	eb 1a                	jmp    800bdf <memcmp+0x2c>
		if (*s1 != *s2)
  800bc5:	0f b6 08             	movzbl (%eax),%ecx
  800bc8:	0f b6 1a             	movzbl (%edx),%ebx
  800bcb:	38 d9                	cmp    %bl,%cl
  800bcd:	74 0a                	je     800bd9 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bcf:	0f b6 c1             	movzbl %cl,%eax
  800bd2:	0f b6 db             	movzbl %bl,%ebx
  800bd5:	29 d8                	sub    %ebx,%eax
  800bd7:	eb 0f                	jmp    800be8 <memcmp+0x35>
		s1++, s2++;
  800bd9:	83 c0 01             	add    $0x1,%eax
  800bdc:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bdf:	39 f0                	cmp    %esi,%eax
  800be1:	75 e2                	jne    800bc5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800be3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	53                   	push   %ebx
  800bf0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bf3:	89 c1                	mov    %eax,%ecx
  800bf5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bfc:	eb 0a                	jmp    800c08 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bfe:	0f b6 10             	movzbl (%eax),%edx
  800c01:	39 da                	cmp    %ebx,%edx
  800c03:	74 07                	je     800c0c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c05:	83 c0 01             	add    $0x1,%eax
  800c08:	39 c8                	cmp    %ecx,%eax
  800c0a:	72 f2                	jb     800bfe <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c0c:	5b                   	pop    %ebx
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1b:	eb 03                	jmp    800c20 <strtol+0x11>
		s++;
  800c1d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c20:	0f b6 01             	movzbl (%ecx),%eax
  800c23:	3c 20                	cmp    $0x20,%al
  800c25:	74 f6                	je     800c1d <strtol+0xe>
  800c27:	3c 09                	cmp    $0x9,%al
  800c29:	74 f2                	je     800c1d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c2b:	3c 2b                	cmp    $0x2b,%al
  800c2d:	75 0a                	jne    800c39 <strtol+0x2a>
		s++;
  800c2f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c32:	bf 00 00 00 00       	mov    $0x0,%edi
  800c37:	eb 11                	jmp    800c4a <strtol+0x3b>
  800c39:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c3e:	3c 2d                	cmp    $0x2d,%al
  800c40:	75 08                	jne    800c4a <strtol+0x3b>
		s++, neg = 1;
  800c42:	83 c1 01             	add    $0x1,%ecx
  800c45:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c4a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c50:	75 15                	jne    800c67 <strtol+0x58>
  800c52:	80 39 30             	cmpb   $0x30,(%ecx)
  800c55:	75 10                	jne    800c67 <strtol+0x58>
  800c57:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c5b:	75 7c                	jne    800cd9 <strtol+0xca>
		s += 2, base = 16;
  800c5d:	83 c1 02             	add    $0x2,%ecx
  800c60:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c65:	eb 16                	jmp    800c7d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c67:	85 db                	test   %ebx,%ebx
  800c69:	75 12                	jne    800c7d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c6b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c70:	80 39 30             	cmpb   $0x30,(%ecx)
  800c73:	75 08                	jne    800c7d <strtol+0x6e>
		s++, base = 8;
  800c75:	83 c1 01             	add    $0x1,%ecx
  800c78:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c82:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c85:	0f b6 11             	movzbl (%ecx),%edx
  800c88:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c8b:	89 f3                	mov    %esi,%ebx
  800c8d:	80 fb 09             	cmp    $0x9,%bl
  800c90:	77 08                	ja     800c9a <strtol+0x8b>
			dig = *s - '0';
  800c92:	0f be d2             	movsbl %dl,%edx
  800c95:	83 ea 30             	sub    $0x30,%edx
  800c98:	eb 22                	jmp    800cbc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c9a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c9d:	89 f3                	mov    %esi,%ebx
  800c9f:	80 fb 19             	cmp    $0x19,%bl
  800ca2:	77 08                	ja     800cac <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ca4:	0f be d2             	movsbl %dl,%edx
  800ca7:	83 ea 57             	sub    $0x57,%edx
  800caa:	eb 10                	jmp    800cbc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cac:	8d 72 bf             	lea    -0x41(%edx),%esi
  800caf:	89 f3                	mov    %esi,%ebx
  800cb1:	80 fb 19             	cmp    $0x19,%bl
  800cb4:	77 16                	ja     800ccc <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cb6:	0f be d2             	movsbl %dl,%edx
  800cb9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cbc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cbf:	7d 0b                	jge    800ccc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cc1:	83 c1 01             	add    $0x1,%ecx
  800cc4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cc8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cca:	eb b9                	jmp    800c85 <strtol+0x76>

	if (endptr)
  800ccc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd0:	74 0d                	je     800cdf <strtol+0xd0>
		*endptr = (char *) s;
  800cd2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd5:	89 0e                	mov    %ecx,(%esi)
  800cd7:	eb 06                	jmp    800cdf <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cd9:	85 db                	test   %ebx,%ebx
  800cdb:	74 98                	je     800c75 <strtol+0x66>
  800cdd:	eb 9e                	jmp    800c7d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cdf:	89 c2                	mov    %eax,%edx
  800ce1:	f7 da                	neg    %edx
  800ce3:	85 ff                	test   %edi,%edi
  800ce5:	0f 45 c2             	cmovne %edx,%eax
}
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    
  800ced:	66 90                	xchg   %ax,%ax
  800cef:	90                   	nop

00800cf0 <__udivdi3>:
  800cf0:	55                   	push   %ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 1c             	sub    $0x1c,%esp
  800cf7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800cfb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800cff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d07:	85 f6                	test   %esi,%esi
  800d09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d0d:	89 ca                	mov    %ecx,%edx
  800d0f:	89 f8                	mov    %edi,%eax
  800d11:	75 3d                	jne    800d50 <__udivdi3+0x60>
  800d13:	39 cf                	cmp    %ecx,%edi
  800d15:	0f 87 c5 00 00 00    	ja     800de0 <__udivdi3+0xf0>
  800d1b:	85 ff                	test   %edi,%edi
  800d1d:	89 fd                	mov    %edi,%ebp
  800d1f:	75 0b                	jne    800d2c <__udivdi3+0x3c>
  800d21:	b8 01 00 00 00       	mov    $0x1,%eax
  800d26:	31 d2                	xor    %edx,%edx
  800d28:	f7 f7                	div    %edi
  800d2a:	89 c5                	mov    %eax,%ebp
  800d2c:	89 c8                	mov    %ecx,%eax
  800d2e:	31 d2                	xor    %edx,%edx
  800d30:	f7 f5                	div    %ebp
  800d32:	89 c1                	mov    %eax,%ecx
  800d34:	89 d8                	mov    %ebx,%eax
  800d36:	89 cf                	mov    %ecx,%edi
  800d38:	f7 f5                	div    %ebp
  800d3a:	89 c3                	mov    %eax,%ebx
  800d3c:	89 d8                	mov    %ebx,%eax
  800d3e:	89 fa                	mov    %edi,%edx
  800d40:	83 c4 1c             	add    $0x1c,%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    
  800d48:	90                   	nop
  800d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d50:	39 ce                	cmp    %ecx,%esi
  800d52:	77 74                	ja     800dc8 <__udivdi3+0xd8>
  800d54:	0f bd fe             	bsr    %esi,%edi
  800d57:	83 f7 1f             	xor    $0x1f,%edi
  800d5a:	0f 84 98 00 00 00    	je     800df8 <__udivdi3+0x108>
  800d60:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d65:	89 f9                	mov    %edi,%ecx
  800d67:	89 c5                	mov    %eax,%ebp
  800d69:	29 fb                	sub    %edi,%ebx
  800d6b:	d3 e6                	shl    %cl,%esi
  800d6d:	89 d9                	mov    %ebx,%ecx
  800d6f:	d3 ed                	shr    %cl,%ebp
  800d71:	89 f9                	mov    %edi,%ecx
  800d73:	d3 e0                	shl    %cl,%eax
  800d75:	09 ee                	or     %ebp,%esi
  800d77:	89 d9                	mov    %ebx,%ecx
  800d79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d7d:	89 d5                	mov    %edx,%ebp
  800d7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d83:	d3 ed                	shr    %cl,%ebp
  800d85:	89 f9                	mov    %edi,%ecx
  800d87:	d3 e2                	shl    %cl,%edx
  800d89:	89 d9                	mov    %ebx,%ecx
  800d8b:	d3 e8                	shr    %cl,%eax
  800d8d:	09 c2                	or     %eax,%edx
  800d8f:	89 d0                	mov    %edx,%eax
  800d91:	89 ea                	mov    %ebp,%edx
  800d93:	f7 f6                	div    %esi
  800d95:	89 d5                	mov    %edx,%ebp
  800d97:	89 c3                	mov    %eax,%ebx
  800d99:	f7 64 24 0c          	mull   0xc(%esp)
  800d9d:	39 d5                	cmp    %edx,%ebp
  800d9f:	72 10                	jb     800db1 <__udivdi3+0xc1>
  800da1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800da5:	89 f9                	mov    %edi,%ecx
  800da7:	d3 e6                	shl    %cl,%esi
  800da9:	39 c6                	cmp    %eax,%esi
  800dab:	73 07                	jae    800db4 <__udivdi3+0xc4>
  800dad:	39 d5                	cmp    %edx,%ebp
  800daf:	75 03                	jne    800db4 <__udivdi3+0xc4>
  800db1:	83 eb 01             	sub    $0x1,%ebx
  800db4:	31 ff                	xor    %edi,%edi
  800db6:	89 d8                	mov    %ebx,%eax
  800db8:	89 fa                	mov    %edi,%edx
  800dba:	83 c4 1c             	add    $0x1c,%esp
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    
  800dc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800dc8:	31 ff                	xor    %edi,%edi
  800dca:	31 db                	xor    %ebx,%ebx
  800dcc:	89 d8                	mov    %ebx,%eax
  800dce:	89 fa                	mov    %edi,%edx
  800dd0:	83 c4 1c             	add    $0x1c,%esp
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    
  800dd8:	90                   	nop
  800dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800de0:	89 d8                	mov    %ebx,%eax
  800de2:	f7 f7                	div    %edi
  800de4:	31 ff                	xor    %edi,%edi
  800de6:	89 c3                	mov    %eax,%ebx
  800de8:	89 d8                	mov    %ebx,%eax
  800dea:	89 fa                	mov    %edi,%edx
  800dec:	83 c4 1c             	add    $0x1c,%esp
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    
  800df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800df8:	39 ce                	cmp    %ecx,%esi
  800dfa:	72 0c                	jb     800e08 <__udivdi3+0x118>
  800dfc:	31 db                	xor    %ebx,%ebx
  800dfe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e02:	0f 87 34 ff ff ff    	ja     800d3c <__udivdi3+0x4c>
  800e08:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e0d:	e9 2a ff ff ff       	jmp    800d3c <__udivdi3+0x4c>
  800e12:	66 90                	xchg   %ax,%ax
  800e14:	66 90                	xchg   %ax,%ax
  800e16:	66 90                	xchg   %ax,%ax
  800e18:	66 90                	xchg   %ax,%ax
  800e1a:	66 90                	xchg   %ax,%ax
  800e1c:	66 90                	xchg   %ax,%ax
  800e1e:	66 90                	xchg   %ax,%ax

00800e20 <__umoddi3>:
  800e20:	55                   	push   %ebp
  800e21:	57                   	push   %edi
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
  800e24:	83 ec 1c             	sub    $0x1c,%esp
  800e27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e37:	85 d2                	test   %edx,%edx
  800e39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e41:	89 f3                	mov    %esi,%ebx
  800e43:	89 3c 24             	mov    %edi,(%esp)
  800e46:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e4a:	75 1c                	jne    800e68 <__umoddi3+0x48>
  800e4c:	39 f7                	cmp    %esi,%edi
  800e4e:	76 50                	jbe    800ea0 <__umoddi3+0x80>
  800e50:	89 c8                	mov    %ecx,%eax
  800e52:	89 f2                	mov    %esi,%edx
  800e54:	f7 f7                	div    %edi
  800e56:	89 d0                	mov    %edx,%eax
  800e58:	31 d2                	xor    %edx,%edx
  800e5a:	83 c4 1c             	add    $0x1c,%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    
  800e62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e68:	39 f2                	cmp    %esi,%edx
  800e6a:	89 d0                	mov    %edx,%eax
  800e6c:	77 52                	ja     800ec0 <__umoddi3+0xa0>
  800e6e:	0f bd ea             	bsr    %edx,%ebp
  800e71:	83 f5 1f             	xor    $0x1f,%ebp
  800e74:	75 5a                	jne    800ed0 <__umoddi3+0xb0>
  800e76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e7a:	0f 82 e0 00 00 00    	jb     800f60 <__umoddi3+0x140>
  800e80:	39 0c 24             	cmp    %ecx,(%esp)
  800e83:	0f 86 d7 00 00 00    	jbe    800f60 <__umoddi3+0x140>
  800e89:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e91:	83 c4 1c             	add    $0x1c,%esp
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    
  800e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	85 ff                	test   %edi,%edi
  800ea2:	89 fd                	mov    %edi,%ebp
  800ea4:	75 0b                	jne    800eb1 <__umoddi3+0x91>
  800ea6:	b8 01 00 00 00       	mov    $0x1,%eax
  800eab:	31 d2                	xor    %edx,%edx
  800ead:	f7 f7                	div    %edi
  800eaf:	89 c5                	mov    %eax,%ebp
  800eb1:	89 f0                	mov    %esi,%eax
  800eb3:	31 d2                	xor    %edx,%edx
  800eb5:	f7 f5                	div    %ebp
  800eb7:	89 c8                	mov    %ecx,%eax
  800eb9:	f7 f5                	div    %ebp
  800ebb:	89 d0                	mov    %edx,%eax
  800ebd:	eb 99                	jmp    800e58 <__umoddi3+0x38>
  800ebf:	90                   	nop
  800ec0:	89 c8                	mov    %ecx,%eax
  800ec2:	89 f2                	mov    %esi,%edx
  800ec4:	83 c4 1c             	add    $0x1c,%esp
  800ec7:	5b                   	pop    %ebx
  800ec8:	5e                   	pop    %esi
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    
  800ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	8b 34 24             	mov    (%esp),%esi
  800ed3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ed8:	89 e9                	mov    %ebp,%ecx
  800eda:	29 ef                	sub    %ebp,%edi
  800edc:	d3 e0                	shl    %cl,%eax
  800ede:	89 f9                	mov    %edi,%ecx
  800ee0:	89 f2                	mov    %esi,%edx
  800ee2:	d3 ea                	shr    %cl,%edx
  800ee4:	89 e9                	mov    %ebp,%ecx
  800ee6:	09 c2                	or     %eax,%edx
  800ee8:	89 d8                	mov    %ebx,%eax
  800eea:	89 14 24             	mov    %edx,(%esp)
  800eed:	89 f2                	mov    %esi,%edx
  800eef:	d3 e2                	shl    %cl,%edx
  800ef1:	89 f9                	mov    %edi,%ecx
  800ef3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ef7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800efb:	d3 e8                	shr    %cl,%eax
  800efd:	89 e9                	mov    %ebp,%ecx
  800eff:	89 c6                	mov    %eax,%esi
  800f01:	d3 e3                	shl    %cl,%ebx
  800f03:	89 f9                	mov    %edi,%ecx
  800f05:	89 d0                	mov    %edx,%eax
  800f07:	d3 e8                	shr    %cl,%eax
  800f09:	89 e9                	mov    %ebp,%ecx
  800f0b:	09 d8                	or     %ebx,%eax
  800f0d:	89 d3                	mov    %edx,%ebx
  800f0f:	89 f2                	mov    %esi,%edx
  800f11:	f7 34 24             	divl   (%esp)
  800f14:	89 d6                	mov    %edx,%esi
  800f16:	d3 e3                	shl    %cl,%ebx
  800f18:	f7 64 24 04          	mull   0x4(%esp)
  800f1c:	39 d6                	cmp    %edx,%esi
  800f1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f22:	89 d1                	mov    %edx,%ecx
  800f24:	89 c3                	mov    %eax,%ebx
  800f26:	72 08                	jb     800f30 <__umoddi3+0x110>
  800f28:	75 11                	jne    800f3b <__umoddi3+0x11b>
  800f2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f2e:	73 0b                	jae    800f3b <__umoddi3+0x11b>
  800f30:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f34:	1b 14 24             	sbb    (%esp),%edx
  800f37:	89 d1                	mov    %edx,%ecx
  800f39:	89 c3                	mov    %eax,%ebx
  800f3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f3f:	29 da                	sub    %ebx,%edx
  800f41:	19 ce                	sbb    %ecx,%esi
  800f43:	89 f9                	mov    %edi,%ecx
  800f45:	89 f0                	mov    %esi,%eax
  800f47:	d3 e0                	shl    %cl,%eax
  800f49:	89 e9                	mov    %ebp,%ecx
  800f4b:	d3 ea                	shr    %cl,%edx
  800f4d:	89 e9                	mov    %ebp,%ecx
  800f4f:	d3 ee                	shr    %cl,%esi
  800f51:	09 d0                	or     %edx,%eax
  800f53:	89 f2                	mov    %esi,%edx
  800f55:	83 c4 1c             	add    $0x1c,%esp
  800f58:	5b                   	pop    %ebx
  800f59:	5e                   	pop    %esi
  800f5a:	5f                   	pop    %edi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    
  800f5d:	8d 76 00             	lea    0x0(%esi),%esi
  800f60:	29 f9                	sub    %edi,%ecx
  800f62:	19 d6                	sbb    %edx,%esi
  800f64:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f6c:	e9 18 ff ff ff       	jmp    800e89 <__umoddi3+0x69>
