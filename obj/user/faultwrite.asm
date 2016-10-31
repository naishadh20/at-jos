
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004d:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800054:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  800057:	e8 c6 00 00 00       	call   800122 <sys_getenvid>
  80005c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800061:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800064:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800069:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006e:	85 db                	test   %ebx,%ebx
  800070:	7e 07                	jle    800079 <libmain+0x37>
		binaryname = argv[0];
  800072:	8b 06                	mov    (%esi),%eax
  800074:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	56                   	push   %esi
  80007d:	53                   	push   %ebx
  80007e:	e8 b0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800083:	e8 0a 00 00 00       	call   800092 <exit>
}
  800088:	83 c4 10             	add    $0x10,%esp
  80008b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    

00800092 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800098:	6a 00                	push   $0x0
  80009a:	e8 42 00 00 00       	call   8000e1 <sys_env_destroy>
}
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	c9                   	leave  
  8000a3:	c3                   	ret    

008000a4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  8000aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8000af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b5:	89 c3                	mov    %eax,%ebx
  8000b7:	89 c7                	mov    %eax,%edi
  8000b9:	89 c6                	mov    %eax,%esi
  8000bb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5f                   	pop    %edi
  8000c0:	5d                   	pop    %ebp
  8000c1:	c3                   	ret    

008000c2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d2:	89 d1                	mov    %edx,%ecx
  8000d4:	89 d3                	mov    %edx,%ebx
  8000d6:	89 d7                	mov    %edx,%edi
  8000d8:	89 d6                	mov    %edx,%esi
  8000da:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ef:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f7:	89 cb                	mov    %ecx,%ebx
  8000f9:	89 cf                	mov    %ecx,%edi
  8000fb:	89 ce                	mov    %ecx,%esi
  8000fd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ff:	85 c0                	test   %eax,%eax
  800101:	7e 17                	jle    80011a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800103:	83 ec 0c             	sub    $0xc,%esp
  800106:	50                   	push   %eax
  800107:	6a 03                	push   $0x3
  800109:	68 aa 0f 80 00       	push   $0x800faa
  80010e:	6a 23                	push   $0x23
  800110:	68 c7 0f 80 00       	push   $0x800fc7
  800115:	e8 f5 01 00 00       	call   80030f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011d:	5b                   	pop    %ebx
  80011e:	5e                   	pop    %esi
  80011f:	5f                   	pop    %edi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	57                   	push   %edi
  800126:	56                   	push   %esi
  800127:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800128:	ba 00 00 00 00       	mov    $0x0,%edx
  80012d:	b8 02 00 00 00       	mov    $0x2,%eax
  800132:	89 d1                	mov    %edx,%ecx
  800134:	89 d3                	mov    %edx,%ebx
  800136:	89 d7                	mov    %edx,%edi
  800138:	89 d6                	mov    %edx,%esi
  80013a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013c:	5b                   	pop    %ebx
  80013d:	5e                   	pop    %esi
  80013e:	5f                   	pop    %edi
  80013f:	5d                   	pop    %ebp
  800140:	c3                   	ret    

00800141 <sys_yield>:

void
sys_yield(void)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	57                   	push   %edi
  800145:	56                   	push   %esi
  800146:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800147:	ba 00 00 00 00       	mov    $0x0,%edx
  80014c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800151:	89 d1                	mov    %edx,%ecx
  800153:	89 d3                	mov    %edx,%ebx
  800155:	89 d7                	mov    %edx,%edi
  800157:	89 d6                	mov    %edx,%esi
  800159:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015b:	5b                   	pop    %ebx
  80015c:	5e                   	pop    %esi
  80015d:	5f                   	pop    %edi
  80015e:	5d                   	pop    %ebp
  80015f:	c3                   	ret    

00800160 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800169:	be 00 00 00 00       	mov    $0x0,%esi
  80016e:	b8 04 00 00 00       	mov    $0x4,%eax
  800173:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800176:	8b 55 08             	mov    0x8(%ebp),%edx
  800179:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017c:	89 f7                	mov    %esi,%edi
  80017e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800180:	85 c0                	test   %eax,%eax
  800182:	7e 17                	jle    80019b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800184:	83 ec 0c             	sub    $0xc,%esp
  800187:	50                   	push   %eax
  800188:	6a 04                	push   $0x4
  80018a:	68 aa 0f 80 00       	push   $0x800faa
  80018f:	6a 23                	push   $0x23
  800191:	68 c7 0f 80 00       	push   $0x800fc7
  800196:	e8 74 01 00 00       	call   80030f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019e:	5b                   	pop    %ebx
  80019f:	5e                   	pop    %esi
  8001a0:	5f                   	pop    %edi
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    

008001a3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	57                   	push   %edi
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ac:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ba:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c2:	85 c0                	test   %eax,%eax
  8001c4:	7e 17                	jle    8001dd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c6:	83 ec 0c             	sub    $0xc,%esp
  8001c9:	50                   	push   %eax
  8001ca:	6a 05                	push   $0x5
  8001cc:	68 aa 0f 80 00       	push   $0x800faa
  8001d1:	6a 23                	push   $0x23
  8001d3:	68 c7 0f 80 00       	push   $0x800fc7
  8001d8:	e8 32 01 00 00       	call   80030f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5f                   	pop    %edi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    

008001e5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	57                   	push   %edi
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f3:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	89 df                	mov    %ebx,%edi
  800200:	89 de                	mov    %ebx,%esi
  800202:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800204:	85 c0                	test   %eax,%eax
  800206:	7e 17                	jle    80021f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800208:	83 ec 0c             	sub    $0xc,%esp
  80020b:	50                   	push   %eax
  80020c:	6a 06                	push   $0x6
  80020e:	68 aa 0f 80 00       	push   $0x800faa
  800213:	6a 23                	push   $0x23
  800215:	68 c7 0f 80 00       	push   $0x800fc7
  80021a:	e8 f0 00 00 00       	call   80030f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800222:	5b                   	pop    %ebx
  800223:	5e                   	pop    %esi
  800224:	5f                   	pop    %edi
  800225:	5d                   	pop    %ebp
  800226:	c3                   	ret    

00800227 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	57                   	push   %edi
  80022b:	56                   	push   %esi
  80022c:	53                   	push   %ebx
  80022d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800230:	bb 00 00 00 00       	mov    $0x0,%ebx
  800235:	b8 08 00 00 00       	mov    $0x8,%eax
  80023a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023d:	8b 55 08             	mov    0x8(%ebp),%edx
  800240:	89 df                	mov    %ebx,%edi
  800242:	89 de                	mov    %ebx,%esi
  800244:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800246:	85 c0                	test   %eax,%eax
  800248:	7e 17                	jle    800261 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024a:	83 ec 0c             	sub    $0xc,%esp
  80024d:	50                   	push   %eax
  80024e:	6a 08                	push   $0x8
  800250:	68 aa 0f 80 00       	push   $0x800faa
  800255:	6a 23                	push   $0x23
  800257:	68 c7 0f 80 00       	push   $0x800fc7
  80025c:	e8 ae 00 00 00       	call   80030f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800261:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800264:	5b                   	pop    %ebx
  800265:	5e                   	pop    %esi
  800266:	5f                   	pop    %edi
  800267:	5d                   	pop    %ebp
  800268:	c3                   	ret    

00800269 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	57                   	push   %edi
  80026d:	56                   	push   %esi
  80026e:	53                   	push   %ebx
  80026f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800272:	bb 00 00 00 00       	mov    $0x0,%ebx
  800277:	b8 09 00 00 00       	mov    $0x9,%eax
  80027c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
  800282:	89 df                	mov    %ebx,%edi
  800284:	89 de                	mov    %ebx,%esi
  800286:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800288:	85 c0                	test   %eax,%eax
  80028a:	7e 17                	jle    8002a3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	50                   	push   %eax
  800290:	6a 09                	push   $0x9
  800292:	68 aa 0f 80 00       	push   $0x800faa
  800297:	6a 23                	push   $0x23
  800299:	68 c7 0f 80 00       	push   $0x800fc7
  80029e:	e8 6c 00 00 00       	call   80030f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a6:	5b                   	pop    %ebx
  8002a7:	5e                   	pop    %esi
  8002a8:	5f                   	pop    %edi
  8002a9:	5d                   	pop    %ebp
  8002aa:	c3                   	ret    

008002ab <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	57                   	push   %edi
  8002af:	56                   	push   %esi
  8002b0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b1:	be 00 00 00 00       	mov    $0x0,%esi
  8002b6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002be:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c9:	5b                   	pop    %ebx
  8002ca:	5e                   	pop    %esi
  8002cb:	5f                   	pop    %edi
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	57                   	push   %edi
  8002d2:	56                   	push   %esi
  8002d3:	53                   	push   %ebx
  8002d4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002dc:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e4:	89 cb                	mov    %ecx,%ebx
  8002e6:	89 cf                	mov    %ecx,%edi
  8002e8:	89 ce                	mov    %ecx,%esi
  8002ea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002ec:	85 c0                	test   %eax,%eax
  8002ee:	7e 17                	jle    800307 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f0:	83 ec 0c             	sub    $0xc,%esp
  8002f3:	50                   	push   %eax
  8002f4:	6a 0c                	push   $0xc
  8002f6:	68 aa 0f 80 00       	push   $0x800faa
  8002fb:	6a 23                	push   $0x23
  8002fd:	68 c7 0f 80 00       	push   $0x800fc7
  800302:	e8 08 00 00 00       	call   80030f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800307:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030a:	5b                   	pop    %ebx
  80030b:	5e                   	pop    %esi
  80030c:	5f                   	pop    %edi
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800314:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800317:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80031d:	e8 00 fe ff ff       	call   800122 <sys_getenvid>
  800322:	83 ec 0c             	sub    $0xc,%esp
  800325:	ff 75 0c             	pushl  0xc(%ebp)
  800328:	ff 75 08             	pushl  0x8(%ebp)
  80032b:	56                   	push   %esi
  80032c:	50                   	push   %eax
  80032d:	68 d8 0f 80 00       	push   $0x800fd8
  800332:	e8 b1 00 00 00       	call   8003e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800337:	83 c4 18             	add    $0x18,%esp
  80033a:	53                   	push   %ebx
  80033b:	ff 75 10             	pushl  0x10(%ebp)
  80033e:	e8 54 00 00 00       	call   800397 <vcprintf>
	cprintf("\n");
  800343:	c7 04 24 30 10 80 00 	movl   $0x801030,(%esp)
  80034a:	e8 99 00 00 00       	call   8003e8 <cprintf>
  80034f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800352:	cc                   	int3   
  800353:	eb fd                	jmp    800352 <_panic+0x43>

00800355 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	53                   	push   %ebx
  800359:	83 ec 04             	sub    $0x4,%esp
  80035c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80035f:	8b 13                	mov    (%ebx),%edx
  800361:	8d 42 01             	lea    0x1(%edx),%eax
  800364:	89 03                	mov    %eax,(%ebx)
  800366:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800369:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80036d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800372:	75 1a                	jne    80038e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800374:	83 ec 08             	sub    $0x8,%esp
  800377:	68 ff 00 00 00       	push   $0xff
  80037c:	8d 43 08             	lea    0x8(%ebx),%eax
  80037f:	50                   	push   %eax
  800380:	e8 1f fd ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  800385:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80038e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800392:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800395:	c9                   	leave  
  800396:	c3                   	ret    

00800397 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a7:	00 00 00 
	b.cnt = 0;
  8003aa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b4:	ff 75 0c             	pushl  0xc(%ebp)
  8003b7:	ff 75 08             	pushl  0x8(%ebp)
  8003ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c0:	50                   	push   %eax
  8003c1:	68 55 03 80 00       	push   $0x800355
  8003c6:	e8 54 01 00 00       	call   80051f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003cb:	83 c4 08             	add    $0x8,%esp
  8003ce:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003da:	50                   	push   %eax
  8003db:	e8 c4 fc ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  8003e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e6:	c9                   	leave  
  8003e7:	c3                   	ret    

008003e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f1:	50                   	push   %eax
  8003f2:	ff 75 08             	pushl  0x8(%ebp)
  8003f5:	e8 9d ff ff ff       	call   800397 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fa:	c9                   	leave  
  8003fb:	c3                   	ret    

008003fc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	57                   	push   %edi
  800400:	56                   	push   %esi
  800401:	53                   	push   %ebx
  800402:	83 ec 1c             	sub    $0x1c,%esp
  800405:	89 c7                	mov    %eax,%edi
  800407:	89 d6                	mov    %edx,%esi
  800409:	8b 45 08             	mov    0x8(%ebp),%eax
  80040c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80040f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800412:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800415:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800418:	bb 00 00 00 00       	mov    $0x0,%ebx
  80041d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800420:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800423:	39 d3                	cmp    %edx,%ebx
  800425:	72 05                	jb     80042c <printnum+0x30>
  800427:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042a:	77 45                	ja     800471 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042c:	83 ec 0c             	sub    $0xc,%esp
  80042f:	ff 75 18             	pushl  0x18(%ebp)
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800438:	53                   	push   %ebx
  800439:	ff 75 10             	pushl  0x10(%ebp)
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800442:	ff 75 e0             	pushl  -0x20(%ebp)
  800445:	ff 75 dc             	pushl  -0x24(%ebp)
  800448:	ff 75 d8             	pushl  -0x28(%ebp)
  80044b:	e8 b0 08 00 00       	call   800d00 <__udivdi3>
  800450:	83 c4 18             	add    $0x18,%esp
  800453:	52                   	push   %edx
  800454:	50                   	push   %eax
  800455:	89 f2                	mov    %esi,%edx
  800457:	89 f8                	mov    %edi,%eax
  800459:	e8 9e ff ff ff       	call   8003fc <printnum>
  80045e:	83 c4 20             	add    $0x20,%esp
  800461:	eb 18                	jmp    80047b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	56                   	push   %esi
  800467:	ff 75 18             	pushl  0x18(%ebp)
  80046a:	ff d7                	call   *%edi
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	eb 03                	jmp    800474 <printnum+0x78>
  800471:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800474:	83 eb 01             	sub    $0x1,%ebx
  800477:	85 db                	test   %ebx,%ebx
  800479:	7f e8                	jg     800463 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	56                   	push   %esi
  80047f:	83 ec 04             	sub    $0x4,%esp
  800482:	ff 75 e4             	pushl  -0x1c(%ebp)
  800485:	ff 75 e0             	pushl  -0x20(%ebp)
  800488:	ff 75 dc             	pushl  -0x24(%ebp)
  80048b:	ff 75 d8             	pushl  -0x28(%ebp)
  80048e:	e8 9d 09 00 00       	call   800e30 <__umoddi3>
  800493:	83 c4 14             	add    $0x14,%esp
  800496:	0f be 80 fc 0f 80 00 	movsbl 0x800ffc(%eax),%eax
  80049d:	50                   	push   %eax
  80049e:	ff d7                	call   *%edi
}
  8004a0:	83 c4 10             	add    $0x10,%esp
  8004a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a6:	5b                   	pop    %ebx
  8004a7:	5e                   	pop    %esi
  8004a8:	5f                   	pop    %edi
  8004a9:	5d                   	pop    %ebp
  8004aa:	c3                   	ret    

008004ab <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ab:	55                   	push   %ebp
  8004ac:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004ae:	83 fa 01             	cmp    $0x1,%edx
  8004b1:	7e 0e                	jle    8004c1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b3:	8b 10                	mov    (%eax),%edx
  8004b5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004b8:	89 08                	mov    %ecx,(%eax)
  8004ba:	8b 02                	mov    (%edx),%eax
  8004bc:	8b 52 04             	mov    0x4(%edx),%edx
  8004bf:	eb 22                	jmp    8004e3 <getuint+0x38>
	else if (lflag)
  8004c1:	85 d2                	test   %edx,%edx
  8004c3:	74 10                	je     8004d5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c5:	8b 10                	mov    (%eax),%edx
  8004c7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ca:	89 08                	mov    %ecx,(%eax)
  8004cc:	8b 02                	mov    (%edx),%eax
  8004ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d3:	eb 0e                	jmp    8004e3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d5:	8b 10                	mov    (%eax),%edx
  8004d7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004da:	89 08                	mov    %ecx,(%eax)
  8004dc:	8b 02                	mov    (%edx),%eax
  8004de:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e3:	5d                   	pop    %ebp
  8004e4:	c3                   	ret    

008004e5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e5:	55                   	push   %ebp
  8004e6:	89 e5                	mov    %esp,%ebp
  8004e8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004eb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ef:	8b 10                	mov    (%eax),%edx
  8004f1:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f4:	73 0a                	jae    800500 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f9:	89 08                	mov    %ecx,(%eax)
  8004fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fe:	88 02                	mov    %al,(%edx)
}
  800500:	5d                   	pop    %ebp
  800501:	c3                   	ret    

00800502 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800502:	55                   	push   %ebp
  800503:	89 e5                	mov    %esp,%ebp
  800505:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800508:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050b:	50                   	push   %eax
  80050c:	ff 75 10             	pushl  0x10(%ebp)
  80050f:	ff 75 0c             	pushl  0xc(%ebp)
  800512:	ff 75 08             	pushl  0x8(%ebp)
  800515:	e8 05 00 00 00       	call   80051f <vprintfmt>
	va_end(ap);
}
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	c9                   	leave  
  80051e:	c3                   	ret    

0080051f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	57                   	push   %edi
  800523:	56                   	push   %esi
  800524:	53                   	push   %ebx
  800525:	83 ec 2c             	sub    $0x2c,%esp
  800528:	8b 75 08             	mov    0x8(%ebp),%esi
  80052b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800531:	eb 12                	jmp    800545 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800533:	85 c0                	test   %eax,%eax
  800535:	0f 84 cb 03 00 00    	je     800906 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	53                   	push   %ebx
  80053f:	50                   	push   %eax
  800540:	ff d6                	call   *%esi
  800542:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800545:	83 c7 01             	add    $0x1,%edi
  800548:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054c:	83 f8 25             	cmp    $0x25,%eax
  80054f:	75 e2                	jne    800533 <vprintfmt+0x14>
  800551:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800555:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80055c:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800563:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80056a:	ba 00 00 00 00       	mov    $0x0,%edx
  80056f:	eb 07                	jmp    800578 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800574:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800578:	8d 47 01             	lea    0x1(%edi),%eax
  80057b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057e:	0f b6 07             	movzbl (%edi),%eax
  800581:	0f b6 c8             	movzbl %al,%ecx
  800584:	83 e8 23             	sub    $0x23,%eax
  800587:	3c 55                	cmp    $0x55,%al
  800589:	0f 87 5c 03 00 00    	ja     8008eb <vprintfmt+0x3cc>
  80058f:	0f b6 c0             	movzbl %al,%eax
  800592:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  800599:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80059c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005a0:	eb d6                	jmp    800578 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8005aa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ad:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b0:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005b4:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005b7:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005ba:	83 fa 09             	cmp    $0x9,%edx
  8005bd:	77 39                	ja     8005f8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005bf:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005c2:	eb e9                	jmp    8005ad <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8d 48 04             	lea    0x4(%eax),%ecx
  8005ca:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005cd:	8b 00                	mov    (%eax),%eax
  8005cf:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d5:	eb 27                	jmp    8005fe <vprintfmt+0xdf>
  8005d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005da:	85 c0                	test   %eax,%eax
  8005dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e1:	0f 49 c8             	cmovns %eax,%ecx
  8005e4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ea:	eb 8c                	jmp    800578 <vprintfmt+0x59>
  8005ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ef:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005f6:	eb 80                	jmp    800578 <vprintfmt+0x59>
  8005f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fb:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8005fe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800602:	0f 89 70 ff ff ff    	jns    800578 <vprintfmt+0x59>
				width = precision, precision = -1;
  800608:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80060b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060e:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800615:	e9 5e ff ff ff       	jmp    800578 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80061a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800620:	e9 53 ff ff ff       	jmp    800578 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8d 50 04             	lea    0x4(%eax),%edx
  80062b:	89 55 14             	mov    %edx,0x14(%ebp)
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	53                   	push   %ebx
  800632:	ff 30                	pushl  (%eax)
  800634:	ff d6                	call   *%esi
			break;
  800636:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800639:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80063c:	e9 04 ff ff ff       	jmp    800545 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8d 50 04             	lea    0x4(%eax),%edx
  800647:	89 55 14             	mov    %edx,0x14(%ebp)
  80064a:	8b 00                	mov    (%eax),%eax
  80064c:	99                   	cltd   
  80064d:	31 d0                	xor    %edx,%eax
  80064f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800651:	83 f8 09             	cmp    $0x9,%eax
  800654:	7f 0b                	jg     800661 <vprintfmt+0x142>
  800656:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  80065d:	85 d2                	test   %edx,%edx
  80065f:	75 18                	jne    800679 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800661:	50                   	push   %eax
  800662:	68 14 10 80 00       	push   $0x801014
  800667:	53                   	push   %ebx
  800668:	56                   	push   %esi
  800669:	e8 94 fe ff ff       	call   800502 <printfmt>
  80066e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800671:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800674:	e9 cc fe ff ff       	jmp    800545 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800679:	52                   	push   %edx
  80067a:	68 1d 10 80 00       	push   $0x80101d
  80067f:	53                   	push   %ebx
  800680:	56                   	push   %esi
  800681:	e8 7c fe ff ff       	call   800502 <printfmt>
  800686:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800689:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80068c:	e9 b4 fe ff ff       	jmp    800545 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8d 50 04             	lea    0x4(%eax),%edx
  800697:	89 55 14             	mov    %edx,0x14(%ebp)
  80069a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80069c:	85 ff                	test   %edi,%edi
  80069e:	b8 0d 10 80 00       	mov    $0x80100d,%eax
  8006a3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006a6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006aa:	0f 8e 94 00 00 00    	jle    800744 <vprintfmt+0x225>
  8006b0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006b4:	0f 84 98 00 00 00    	je     800752 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ba:	83 ec 08             	sub    $0x8,%esp
  8006bd:	ff 75 c8             	pushl  -0x38(%ebp)
  8006c0:	57                   	push   %edi
  8006c1:	e8 c8 02 00 00       	call   80098e <strnlen>
  8006c6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006c9:	29 c1                	sub    %eax,%ecx
  8006cb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006ce:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006db:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006dd:	eb 0f                	jmp    8006ee <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	53                   	push   %ebx
  8006e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e8:	83 ef 01             	sub    $0x1,%edi
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	85 ff                	test   %edi,%edi
  8006f0:	7f ed                	jg     8006df <vprintfmt+0x1c0>
  8006f2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f5:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006f8:	85 c9                	test   %ecx,%ecx
  8006fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ff:	0f 49 c1             	cmovns %ecx,%eax
  800702:	29 c1                	sub    %eax,%ecx
  800704:	89 75 08             	mov    %esi,0x8(%ebp)
  800707:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80070a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070d:	89 cb                	mov    %ecx,%ebx
  80070f:	eb 4d                	jmp    80075e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800711:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800715:	74 1b                	je     800732 <vprintfmt+0x213>
  800717:	0f be c0             	movsbl %al,%eax
  80071a:	83 e8 20             	sub    $0x20,%eax
  80071d:	83 f8 5e             	cmp    $0x5e,%eax
  800720:	76 10                	jbe    800732 <vprintfmt+0x213>
					putch('?', putdat);
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	ff 75 0c             	pushl  0xc(%ebp)
  800728:	6a 3f                	push   $0x3f
  80072a:	ff 55 08             	call   *0x8(%ebp)
  80072d:	83 c4 10             	add    $0x10,%esp
  800730:	eb 0d                	jmp    80073f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	ff 75 0c             	pushl  0xc(%ebp)
  800738:	52                   	push   %edx
  800739:	ff 55 08             	call   *0x8(%ebp)
  80073c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80073f:	83 eb 01             	sub    $0x1,%ebx
  800742:	eb 1a                	jmp    80075e <vprintfmt+0x23f>
  800744:	89 75 08             	mov    %esi,0x8(%ebp)
  800747:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80074a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80074d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800750:	eb 0c                	jmp    80075e <vprintfmt+0x23f>
  800752:	89 75 08             	mov    %esi,0x8(%ebp)
  800755:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800758:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80075e:	83 c7 01             	add    $0x1,%edi
  800761:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800765:	0f be d0             	movsbl %al,%edx
  800768:	85 d2                	test   %edx,%edx
  80076a:	74 23                	je     80078f <vprintfmt+0x270>
  80076c:	85 f6                	test   %esi,%esi
  80076e:	78 a1                	js     800711 <vprintfmt+0x1f2>
  800770:	83 ee 01             	sub    $0x1,%esi
  800773:	79 9c                	jns    800711 <vprintfmt+0x1f2>
  800775:	89 df                	mov    %ebx,%edi
  800777:	8b 75 08             	mov    0x8(%ebp),%esi
  80077a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077d:	eb 18                	jmp    800797 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80077f:	83 ec 08             	sub    $0x8,%esp
  800782:	53                   	push   %ebx
  800783:	6a 20                	push   $0x20
  800785:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800787:	83 ef 01             	sub    $0x1,%edi
  80078a:	83 c4 10             	add    $0x10,%esp
  80078d:	eb 08                	jmp    800797 <vprintfmt+0x278>
  80078f:	89 df                	mov    %ebx,%edi
  800791:	8b 75 08             	mov    0x8(%ebp),%esi
  800794:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800797:	85 ff                	test   %edi,%edi
  800799:	7f e4                	jg     80077f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079e:	e9 a2 fd ff ff       	jmp    800545 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a3:	83 fa 01             	cmp    $0x1,%edx
  8007a6:	7e 16                	jle    8007be <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ab:	8d 50 08             	lea    0x8(%eax),%edx
  8007ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b1:	8b 50 04             	mov    0x4(%eax),%edx
  8007b4:	8b 00                	mov    (%eax),%eax
  8007b6:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007b9:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007bc:	eb 32                	jmp    8007f0 <vprintfmt+0x2d1>
	else if (lflag)
  8007be:	85 d2                	test   %edx,%edx
  8007c0:	74 18                	je     8007da <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	8d 50 04             	lea    0x4(%eax),%edx
  8007c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cb:	8b 00                	mov    (%eax),%eax
  8007cd:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007d0:	89 c1                	mov    %eax,%ecx
  8007d2:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d5:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007d8:	eb 16                	jmp    8007f0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8d 50 04             	lea    0x4(%eax),%edx
  8007e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e3:	8b 00                	mov    (%eax),%eax
  8007e5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007e8:	89 c1                	mov    %eax,%ecx
  8007ea:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ed:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f0:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007f3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007fc:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800801:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800805:	0f 89 a8 00 00 00    	jns    8008b3 <vprintfmt+0x394>
				putch('-', putdat);
  80080b:	83 ec 08             	sub    $0x8,%esp
  80080e:	53                   	push   %ebx
  80080f:	6a 2d                	push   $0x2d
  800811:	ff d6                	call   *%esi
				num = -(long long) num;
  800813:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800816:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800819:	f7 d8                	neg    %eax
  80081b:	83 d2 00             	adc    $0x0,%edx
  80081e:	f7 da                	neg    %edx
  800820:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800823:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800826:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800829:	b8 0a 00 00 00       	mov    $0xa,%eax
  80082e:	e9 80 00 00 00       	jmp    8008b3 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800833:	8d 45 14             	lea    0x14(%ebp),%eax
  800836:	e8 70 fc ff ff       	call   8004ab <getuint>
  80083b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80083e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800841:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800846:	eb 6b                	jmp    8008b3 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800848:	8d 45 14             	lea    0x14(%ebp),%eax
  80084b:	e8 5b fc ff ff       	call   8004ab <getuint>
  800850:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800853:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800856:	6a 04                	push   $0x4
  800858:	6a 03                	push   $0x3
  80085a:	6a 01                	push   $0x1
  80085c:	68 20 10 80 00       	push   $0x801020
  800861:	e8 82 fb ff ff       	call   8003e8 <cprintf>
			goto number;
  800866:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  800869:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  80086e:	eb 43                	jmp    8008b3 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  800870:	83 ec 08             	sub    $0x8,%esp
  800873:	53                   	push   %ebx
  800874:	6a 30                	push   $0x30
  800876:	ff d6                	call   *%esi
			putch('x', putdat);
  800878:	83 c4 08             	add    $0x8,%esp
  80087b:	53                   	push   %ebx
  80087c:	6a 78                	push   $0x78
  80087e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800880:	8b 45 14             	mov    0x14(%ebp),%eax
  800883:	8d 50 04             	lea    0x4(%eax),%edx
  800886:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800889:	8b 00                	mov    (%eax),%eax
  80088b:	ba 00 00 00 00       	mov    $0x0,%edx
  800890:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800893:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800896:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800899:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80089e:	eb 13                	jmp    8008b3 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a3:	e8 03 fc ff ff       	call   8004ab <getuint>
  8008a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008ae:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008b3:	83 ec 0c             	sub    $0xc,%esp
  8008b6:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8008ba:	52                   	push   %edx
  8008bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8008be:	50                   	push   %eax
  8008bf:	ff 75 dc             	pushl  -0x24(%ebp)
  8008c2:	ff 75 d8             	pushl  -0x28(%ebp)
  8008c5:	89 da                	mov    %ebx,%edx
  8008c7:	89 f0                	mov    %esi,%eax
  8008c9:	e8 2e fb ff ff       	call   8003fc <printnum>

			break;
  8008ce:	83 c4 20             	add    $0x20,%esp
  8008d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008d4:	e9 6c fc ff ff       	jmp    800545 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008d9:	83 ec 08             	sub    $0x8,%esp
  8008dc:	53                   	push   %ebx
  8008dd:	51                   	push   %ecx
  8008de:	ff d6                	call   *%esi
			break;
  8008e0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008e6:	e9 5a fc ff ff       	jmp    800545 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008eb:	83 ec 08             	sub    $0x8,%esp
  8008ee:	53                   	push   %ebx
  8008ef:	6a 25                	push   $0x25
  8008f1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008f3:	83 c4 10             	add    $0x10,%esp
  8008f6:	eb 03                	jmp    8008fb <vprintfmt+0x3dc>
  8008f8:	83 ef 01             	sub    $0x1,%edi
  8008fb:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008ff:	75 f7                	jne    8008f8 <vprintfmt+0x3d9>
  800901:	e9 3f fc ff ff       	jmp    800545 <vprintfmt+0x26>
			break;
		}

	}

}
  800906:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800909:	5b                   	pop    %ebx
  80090a:	5e                   	pop    %esi
  80090b:	5f                   	pop    %edi
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	83 ec 18             	sub    $0x18,%esp
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80091a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80091d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800921:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800924:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80092b:	85 c0                	test   %eax,%eax
  80092d:	74 26                	je     800955 <vsnprintf+0x47>
  80092f:	85 d2                	test   %edx,%edx
  800931:	7e 22                	jle    800955 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800933:	ff 75 14             	pushl  0x14(%ebp)
  800936:	ff 75 10             	pushl  0x10(%ebp)
  800939:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80093c:	50                   	push   %eax
  80093d:	68 e5 04 80 00       	push   $0x8004e5
  800942:	e8 d8 fb ff ff       	call   80051f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800947:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80094a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80094d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800950:	83 c4 10             	add    $0x10,%esp
  800953:	eb 05                	jmp    80095a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800955:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80095a:	c9                   	leave  
  80095b:	c3                   	ret    

0080095c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800962:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800965:	50                   	push   %eax
  800966:	ff 75 10             	pushl  0x10(%ebp)
  800969:	ff 75 0c             	pushl  0xc(%ebp)
  80096c:	ff 75 08             	pushl  0x8(%ebp)
  80096f:	e8 9a ff ff ff       	call   80090e <vsnprintf>
	va_end(ap);

	return rc;
}
  800974:	c9                   	leave  
  800975:	c3                   	ret    

00800976 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80097c:	b8 00 00 00 00       	mov    $0x0,%eax
  800981:	eb 03                	jmp    800986 <strlen+0x10>
		n++;
  800983:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800986:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80098a:	75 f7                	jne    800983 <strlen+0xd>
		n++;
	return n;
}
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800994:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800997:	ba 00 00 00 00       	mov    $0x0,%edx
  80099c:	eb 03                	jmp    8009a1 <strnlen+0x13>
		n++;
  80099e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a1:	39 c2                	cmp    %eax,%edx
  8009a3:	74 08                	je     8009ad <strnlen+0x1f>
  8009a5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009a9:	75 f3                	jne    80099e <strnlen+0x10>
  8009ab:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	53                   	push   %ebx
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009b9:	89 c2                	mov    %eax,%edx
  8009bb:	83 c2 01             	add    $0x1,%edx
  8009be:	83 c1 01             	add    $0x1,%ecx
  8009c1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009c5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009c8:	84 db                	test   %bl,%bl
  8009ca:	75 ef                	jne    8009bb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009cc:	5b                   	pop    %ebx
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	53                   	push   %ebx
  8009d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009d6:	53                   	push   %ebx
  8009d7:	e8 9a ff ff ff       	call   800976 <strlen>
  8009dc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009df:	ff 75 0c             	pushl  0xc(%ebp)
  8009e2:	01 d8                	add    %ebx,%eax
  8009e4:	50                   	push   %eax
  8009e5:	e8 c5 ff ff ff       	call   8009af <strcpy>
	return dst;
}
  8009ea:	89 d8                	mov    %ebx,%eax
  8009ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ef:	c9                   	leave  
  8009f0:	c3                   	ret    

008009f1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	56                   	push   %esi
  8009f5:	53                   	push   %ebx
  8009f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fc:	89 f3                	mov    %esi,%ebx
  8009fe:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a01:	89 f2                	mov    %esi,%edx
  800a03:	eb 0f                	jmp    800a14 <strncpy+0x23>
		*dst++ = *src;
  800a05:	83 c2 01             	add    $0x1,%edx
  800a08:	0f b6 01             	movzbl (%ecx),%eax
  800a0b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a0e:	80 39 01             	cmpb   $0x1,(%ecx)
  800a11:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a14:	39 da                	cmp    %ebx,%edx
  800a16:	75 ed                	jne    800a05 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a18:	89 f0                	mov    %esi,%eax
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 75 08             	mov    0x8(%ebp),%esi
  800a26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a29:	8b 55 10             	mov    0x10(%ebp),%edx
  800a2c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a2e:	85 d2                	test   %edx,%edx
  800a30:	74 21                	je     800a53 <strlcpy+0x35>
  800a32:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a36:	89 f2                	mov    %esi,%edx
  800a38:	eb 09                	jmp    800a43 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a3a:	83 c2 01             	add    $0x1,%edx
  800a3d:	83 c1 01             	add    $0x1,%ecx
  800a40:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a43:	39 c2                	cmp    %eax,%edx
  800a45:	74 09                	je     800a50 <strlcpy+0x32>
  800a47:	0f b6 19             	movzbl (%ecx),%ebx
  800a4a:	84 db                	test   %bl,%bl
  800a4c:	75 ec                	jne    800a3a <strlcpy+0x1c>
  800a4e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a50:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a53:	29 f0                	sub    %esi,%eax
}
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a62:	eb 06                	jmp    800a6a <strcmp+0x11>
		p++, q++;
  800a64:	83 c1 01             	add    $0x1,%ecx
  800a67:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a6a:	0f b6 01             	movzbl (%ecx),%eax
  800a6d:	84 c0                	test   %al,%al
  800a6f:	74 04                	je     800a75 <strcmp+0x1c>
  800a71:	3a 02                	cmp    (%edx),%al
  800a73:	74 ef                	je     800a64 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a75:	0f b6 c0             	movzbl %al,%eax
  800a78:	0f b6 12             	movzbl (%edx),%edx
  800a7b:	29 d0                	sub    %edx,%eax
}
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	53                   	push   %ebx
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a89:	89 c3                	mov    %eax,%ebx
  800a8b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a8e:	eb 06                	jmp    800a96 <strncmp+0x17>
		n--, p++, q++;
  800a90:	83 c0 01             	add    $0x1,%eax
  800a93:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a96:	39 d8                	cmp    %ebx,%eax
  800a98:	74 15                	je     800aaf <strncmp+0x30>
  800a9a:	0f b6 08             	movzbl (%eax),%ecx
  800a9d:	84 c9                	test   %cl,%cl
  800a9f:	74 04                	je     800aa5 <strncmp+0x26>
  800aa1:	3a 0a                	cmp    (%edx),%cl
  800aa3:	74 eb                	je     800a90 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa5:	0f b6 00             	movzbl (%eax),%eax
  800aa8:	0f b6 12             	movzbl (%edx),%edx
  800aab:	29 d0                	sub    %edx,%eax
  800aad:	eb 05                	jmp    800ab4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aaf:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ab4:	5b                   	pop    %ebx
  800ab5:	5d                   	pop    %ebp
  800ab6:	c3                   	ret    

00800ab7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	8b 45 08             	mov    0x8(%ebp),%eax
  800abd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac1:	eb 07                	jmp    800aca <strchr+0x13>
		if (*s == c)
  800ac3:	38 ca                	cmp    %cl,%dl
  800ac5:	74 0f                	je     800ad6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ac7:	83 c0 01             	add    $0x1,%eax
  800aca:	0f b6 10             	movzbl (%eax),%edx
  800acd:	84 d2                	test   %dl,%dl
  800acf:	75 f2                	jne    800ac3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae2:	eb 03                	jmp    800ae7 <strfind+0xf>
  800ae4:	83 c0 01             	add    $0x1,%eax
  800ae7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aea:	38 ca                	cmp    %cl,%dl
  800aec:	74 04                	je     800af2 <strfind+0x1a>
  800aee:	84 d2                	test   %dl,%dl
  800af0:	75 f2                	jne    800ae4 <strfind+0xc>
			break;
	return (char *) s;
}
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	53                   	push   %ebx
  800afa:	8b 7d 08             	mov    0x8(%ebp),%edi
  800afd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b00:	85 c9                	test   %ecx,%ecx
  800b02:	74 36                	je     800b3a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b0a:	75 28                	jne    800b34 <memset+0x40>
  800b0c:	f6 c1 03             	test   $0x3,%cl
  800b0f:	75 23                	jne    800b34 <memset+0x40>
		c &= 0xFF;
  800b11:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b15:	89 d3                	mov    %edx,%ebx
  800b17:	c1 e3 08             	shl    $0x8,%ebx
  800b1a:	89 d6                	mov    %edx,%esi
  800b1c:	c1 e6 18             	shl    $0x18,%esi
  800b1f:	89 d0                	mov    %edx,%eax
  800b21:	c1 e0 10             	shl    $0x10,%eax
  800b24:	09 f0                	or     %esi,%eax
  800b26:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b28:	89 d8                	mov    %ebx,%eax
  800b2a:	09 d0                	or     %edx,%eax
  800b2c:	c1 e9 02             	shr    $0x2,%ecx
  800b2f:	fc                   	cld    
  800b30:	f3 ab                	rep stos %eax,%es:(%edi)
  800b32:	eb 06                	jmp    800b3a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b37:	fc                   	cld    
  800b38:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b3a:	89 f8                	mov    %edi,%eax
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	8b 45 08             	mov    0x8(%ebp),%eax
  800b49:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b4f:	39 c6                	cmp    %eax,%esi
  800b51:	73 35                	jae    800b88 <memmove+0x47>
  800b53:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b56:	39 d0                	cmp    %edx,%eax
  800b58:	73 2e                	jae    800b88 <memmove+0x47>
		s += n;
		d += n;
  800b5a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5d:	89 d6                	mov    %edx,%esi
  800b5f:	09 fe                	or     %edi,%esi
  800b61:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b67:	75 13                	jne    800b7c <memmove+0x3b>
  800b69:	f6 c1 03             	test   $0x3,%cl
  800b6c:	75 0e                	jne    800b7c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b6e:	83 ef 04             	sub    $0x4,%edi
  800b71:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b74:	c1 e9 02             	shr    $0x2,%ecx
  800b77:	fd                   	std    
  800b78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7a:	eb 09                	jmp    800b85 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b7c:	83 ef 01             	sub    $0x1,%edi
  800b7f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b82:	fd                   	std    
  800b83:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b85:	fc                   	cld    
  800b86:	eb 1d                	jmp    800ba5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b88:	89 f2                	mov    %esi,%edx
  800b8a:	09 c2                	or     %eax,%edx
  800b8c:	f6 c2 03             	test   $0x3,%dl
  800b8f:	75 0f                	jne    800ba0 <memmove+0x5f>
  800b91:	f6 c1 03             	test   $0x3,%cl
  800b94:	75 0a                	jne    800ba0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b96:	c1 e9 02             	shr    $0x2,%ecx
  800b99:	89 c7                	mov    %eax,%edi
  800b9b:	fc                   	cld    
  800b9c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9e:	eb 05                	jmp    800ba5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ba0:	89 c7                	mov    %eax,%edi
  800ba2:	fc                   	cld    
  800ba3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bac:	ff 75 10             	pushl  0x10(%ebp)
  800baf:	ff 75 0c             	pushl  0xc(%ebp)
  800bb2:	ff 75 08             	pushl  0x8(%ebp)
  800bb5:	e8 87 ff ff ff       	call   800b41 <memmove>
}
  800bba:	c9                   	leave  
  800bbb:	c3                   	ret    

00800bbc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
  800bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc7:	89 c6                	mov    %eax,%esi
  800bc9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bcc:	eb 1a                	jmp    800be8 <memcmp+0x2c>
		if (*s1 != *s2)
  800bce:	0f b6 08             	movzbl (%eax),%ecx
  800bd1:	0f b6 1a             	movzbl (%edx),%ebx
  800bd4:	38 d9                	cmp    %bl,%cl
  800bd6:	74 0a                	je     800be2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bd8:	0f b6 c1             	movzbl %cl,%eax
  800bdb:	0f b6 db             	movzbl %bl,%ebx
  800bde:	29 d8                	sub    %ebx,%eax
  800be0:	eb 0f                	jmp    800bf1 <memcmp+0x35>
		s1++, s2++;
  800be2:	83 c0 01             	add    $0x1,%eax
  800be5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be8:	39 f0                	cmp    %esi,%eax
  800bea:	75 e2                	jne    800bce <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	53                   	push   %ebx
  800bf9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bfc:	89 c1                	mov    %eax,%ecx
  800bfe:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c01:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c05:	eb 0a                	jmp    800c11 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c07:	0f b6 10             	movzbl (%eax),%edx
  800c0a:	39 da                	cmp    %ebx,%edx
  800c0c:	74 07                	je     800c15 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c0e:	83 c0 01             	add    $0x1,%eax
  800c11:	39 c8                	cmp    %ecx,%eax
  800c13:	72 f2                	jb     800c07 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c15:	5b                   	pop    %ebx
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c24:	eb 03                	jmp    800c29 <strtol+0x11>
		s++;
  800c26:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c29:	0f b6 01             	movzbl (%ecx),%eax
  800c2c:	3c 20                	cmp    $0x20,%al
  800c2e:	74 f6                	je     800c26 <strtol+0xe>
  800c30:	3c 09                	cmp    $0x9,%al
  800c32:	74 f2                	je     800c26 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c34:	3c 2b                	cmp    $0x2b,%al
  800c36:	75 0a                	jne    800c42 <strtol+0x2a>
		s++;
  800c38:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c3b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c40:	eb 11                	jmp    800c53 <strtol+0x3b>
  800c42:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c47:	3c 2d                	cmp    $0x2d,%al
  800c49:	75 08                	jne    800c53 <strtol+0x3b>
		s++, neg = 1;
  800c4b:	83 c1 01             	add    $0x1,%ecx
  800c4e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c53:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c59:	75 15                	jne    800c70 <strtol+0x58>
  800c5b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c5e:	75 10                	jne    800c70 <strtol+0x58>
  800c60:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c64:	75 7c                	jne    800ce2 <strtol+0xca>
		s += 2, base = 16;
  800c66:	83 c1 02             	add    $0x2,%ecx
  800c69:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c6e:	eb 16                	jmp    800c86 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c70:	85 db                	test   %ebx,%ebx
  800c72:	75 12                	jne    800c86 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c74:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c79:	80 39 30             	cmpb   $0x30,(%ecx)
  800c7c:	75 08                	jne    800c86 <strtol+0x6e>
		s++, base = 8;
  800c7e:	83 c1 01             	add    $0x1,%ecx
  800c81:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c86:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c8e:	0f b6 11             	movzbl (%ecx),%edx
  800c91:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c94:	89 f3                	mov    %esi,%ebx
  800c96:	80 fb 09             	cmp    $0x9,%bl
  800c99:	77 08                	ja     800ca3 <strtol+0x8b>
			dig = *s - '0';
  800c9b:	0f be d2             	movsbl %dl,%edx
  800c9e:	83 ea 30             	sub    $0x30,%edx
  800ca1:	eb 22                	jmp    800cc5 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ca3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ca6:	89 f3                	mov    %esi,%ebx
  800ca8:	80 fb 19             	cmp    $0x19,%bl
  800cab:	77 08                	ja     800cb5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cad:	0f be d2             	movsbl %dl,%edx
  800cb0:	83 ea 57             	sub    $0x57,%edx
  800cb3:	eb 10                	jmp    800cc5 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cb5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cb8:	89 f3                	mov    %esi,%ebx
  800cba:	80 fb 19             	cmp    $0x19,%bl
  800cbd:	77 16                	ja     800cd5 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cbf:	0f be d2             	movsbl %dl,%edx
  800cc2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cc5:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cc8:	7d 0b                	jge    800cd5 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cca:	83 c1 01             	add    $0x1,%ecx
  800ccd:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cd1:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cd3:	eb b9                	jmp    800c8e <strtol+0x76>

	if (endptr)
  800cd5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd9:	74 0d                	je     800ce8 <strtol+0xd0>
		*endptr = (char *) s;
  800cdb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cde:	89 0e                	mov    %ecx,(%esi)
  800ce0:	eb 06                	jmp    800ce8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce2:	85 db                	test   %ebx,%ebx
  800ce4:	74 98                	je     800c7e <strtol+0x66>
  800ce6:	eb 9e                	jmp    800c86 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ce8:	89 c2                	mov    %eax,%edx
  800cea:	f7 da                	neg    %edx
  800cec:	85 ff                	test   %edi,%edi
  800cee:	0f 45 c2             	cmovne %edx,%eax
}
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    
  800cf6:	66 90                	xchg   %ax,%ax
  800cf8:	66 90                	xchg   %ax,%ax
  800cfa:	66 90                	xchg   %ax,%ax
  800cfc:	66 90                	xchg   %ax,%ax
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
