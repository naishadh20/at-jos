
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 67 00 00 00       	call   8000a9 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800052:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800059:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  80005c:	e8 c6 00 00 00       	call   800127 <sys_getenvid>
  800061:	25 ff 03 00 00       	and    $0x3ff,%eax
  800066:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 db                	test   %ebx,%ebx
  800075:	7e 07                	jle    80007e <libmain+0x37>
		binaryname = argv[0];
  800077:	8b 06                	mov    (%esi),%eax
  800079:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	56                   	push   %esi
  800082:	53                   	push   %ebx
  800083:	e8 ab ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800088:	e8 0a 00 00 00       	call   800097 <exit>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    

00800097 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800097:	55                   	push   %ebp
  800098:	89 e5                	mov    %esp,%ebp
  80009a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009d:	6a 00                	push   $0x0
  80009f:	e8 42 00 00 00       	call   8000e6 <sys_env_destroy>
}
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	c9                   	leave  
  8000a8:	c3                   	ret    

008000a9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	57                   	push   %edi
  8000ad:	56                   	push   %esi
  8000ae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000af:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ba:	89 c3                	mov    %eax,%ebx
  8000bc:	89 c7                	mov    %eax,%edi
  8000be:	89 c6                	mov    %eax,%esi
  8000c0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5f                   	pop    %edi
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    

008000c7 <sys_cgetc>:

int
sys_cgetc(void)
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
  8000cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d7:	89 d1                	mov    %edx,%ecx
  8000d9:	89 d3                	mov    %edx,%ebx
  8000db:	89 d7                	mov    %edx,%edi
  8000dd:	89 d6                	mov    %edx,%esi
  8000df:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5f                   	pop    %edi
  8000e4:	5d                   	pop    %ebp
  8000e5:	c3                   	ret    

008000e6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	57                   	push   %edi
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
  8000ec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fc:	89 cb                	mov    %ecx,%ebx
  8000fe:	89 cf                	mov    %ecx,%edi
  800100:	89 ce                	mov    %ecx,%esi
  800102:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800104:	85 c0                	test   %eax,%eax
  800106:	7e 17                	jle    80011f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800108:	83 ec 0c             	sub    $0xc,%esp
  80010b:	50                   	push   %eax
  80010c:	6a 03                	push   $0x3
  80010e:	68 aa 0f 80 00       	push   $0x800faa
  800113:	6a 23                	push   $0x23
  800115:	68 c7 0f 80 00       	push   $0x800fc7
  80011a:	e8 f5 01 00 00       	call   800314 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5f                   	pop    %edi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	57                   	push   %edi
  80012b:	56                   	push   %esi
  80012c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012d:	ba 00 00 00 00       	mov    $0x0,%edx
  800132:	b8 02 00 00 00       	mov    $0x2,%eax
  800137:	89 d1                	mov    %edx,%ecx
  800139:	89 d3                	mov    %edx,%ebx
  80013b:	89 d7                	mov    %edx,%edi
  80013d:	89 d6                	mov    %edx,%esi
  80013f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800141:	5b                   	pop    %ebx
  800142:	5e                   	pop    %esi
  800143:	5f                   	pop    %edi
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <sys_yield>:

void
sys_yield(void)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	57                   	push   %edi
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014c:	ba 00 00 00 00       	mov    $0x0,%edx
  800151:	b8 0a 00 00 00       	mov    $0xa,%eax
  800156:	89 d1                	mov    %edx,%ecx
  800158:	89 d3                	mov    %edx,%ebx
  80015a:	89 d7                	mov    %edx,%edi
  80015c:	89 d6                	mov    %edx,%esi
  80015e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800160:	5b                   	pop    %ebx
  800161:	5e                   	pop    %esi
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
  80016b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016e:	be 00 00 00 00       	mov    $0x0,%esi
  800173:	b8 04 00 00 00       	mov    $0x4,%eax
  800178:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017b:	8b 55 08             	mov    0x8(%ebp),%edx
  80017e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800181:	89 f7                	mov    %esi,%edi
  800183:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800185:	85 c0                	test   %eax,%eax
  800187:	7e 17                	jle    8001a0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800189:	83 ec 0c             	sub    $0xc,%esp
  80018c:	50                   	push   %eax
  80018d:	6a 04                	push   $0x4
  80018f:	68 aa 0f 80 00       	push   $0x800faa
  800194:	6a 23                	push   $0x23
  800196:	68 c7 0f 80 00       	push   $0x800fc7
  80019b:	e8 74 01 00 00       	call   800314 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a3:	5b                   	pop    %ebx
  8001a4:	5e                   	pop    %esi
  8001a5:	5f                   	pop    %edi
  8001a6:	5d                   	pop    %ebp
  8001a7:	c3                   	ret    

008001a8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c7:	85 c0                	test   %eax,%eax
  8001c9:	7e 17                	jle    8001e2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cb:	83 ec 0c             	sub    $0xc,%esp
  8001ce:	50                   	push   %eax
  8001cf:	6a 05                	push   $0x5
  8001d1:	68 aa 0f 80 00       	push   $0x800faa
  8001d6:	6a 23                	push   $0x23
  8001d8:	68 c7 0f 80 00       	push   $0x800fc7
  8001dd:	e8 32 01 00 00       	call   800314 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e5:	5b                   	pop    %ebx
  8001e6:	5e                   	pop    %esi
  8001e7:	5f                   	pop    %edi
  8001e8:	5d                   	pop    %ebp
  8001e9:	c3                   	ret    

008001ea <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	57                   	push   %edi
  8001ee:	56                   	push   %esi
  8001ef:	53                   	push   %ebx
  8001f0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f8:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800200:	8b 55 08             	mov    0x8(%ebp),%edx
  800203:	89 df                	mov    %ebx,%edi
  800205:	89 de                	mov    %ebx,%esi
  800207:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800209:	85 c0                	test   %eax,%eax
  80020b:	7e 17                	jle    800224 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020d:	83 ec 0c             	sub    $0xc,%esp
  800210:	50                   	push   %eax
  800211:	6a 06                	push   $0x6
  800213:	68 aa 0f 80 00       	push   $0x800faa
  800218:	6a 23                	push   $0x23
  80021a:	68 c7 0f 80 00       	push   $0x800fc7
  80021f:	e8 f0 00 00 00       	call   800314 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800224:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800227:	5b                   	pop    %ebx
  800228:	5e                   	pop    %esi
  800229:	5f                   	pop    %edi
  80022a:	5d                   	pop    %ebp
  80022b:	c3                   	ret    

0080022c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	57                   	push   %edi
  800230:	56                   	push   %esi
  800231:	53                   	push   %ebx
  800232:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800235:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023a:	b8 08 00 00 00       	mov    $0x8,%eax
  80023f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800242:	8b 55 08             	mov    0x8(%ebp),%edx
  800245:	89 df                	mov    %ebx,%edi
  800247:	89 de                	mov    %ebx,%esi
  800249:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024b:	85 c0                	test   %eax,%eax
  80024d:	7e 17                	jle    800266 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024f:	83 ec 0c             	sub    $0xc,%esp
  800252:	50                   	push   %eax
  800253:	6a 08                	push   $0x8
  800255:	68 aa 0f 80 00       	push   $0x800faa
  80025a:	6a 23                	push   $0x23
  80025c:	68 c7 0f 80 00       	push   $0x800fc7
  800261:	e8 ae 00 00 00       	call   800314 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800266:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800269:	5b                   	pop    %ebx
  80026a:	5e                   	pop    %esi
  80026b:	5f                   	pop    %edi
  80026c:	5d                   	pop    %ebp
  80026d:	c3                   	ret    

0080026e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	57                   	push   %edi
  800272:	56                   	push   %esi
  800273:	53                   	push   %ebx
  800274:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800277:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027c:	b8 09 00 00 00       	mov    $0x9,%eax
  800281:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800284:	8b 55 08             	mov    0x8(%ebp),%edx
  800287:	89 df                	mov    %ebx,%edi
  800289:	89 de                	mov    %ebx,%esi
  80028b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028d:	85 c0                	test   %eax,%eax
  80028f:	7e 17                	jle    8002a8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800291:	83 ec 0c             	sub    $0xc,%esp
  800294:	50                   	push   %eax
  800295:	6a 09                	push   $0x9
  800297:	68 aa 0f 80 00       	push   $0x800faa
  80029c:	6a 23                	push   $0x23
  80029e:	68 c7 0f 80 00       	push   $0x800fc7
  8002a3:	e8 6c 00 00 00       	call   800314 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ab:	5b                   	pop    %ebx
  8002ac:	5e                   	pop    %esi
  8002ad:	5f                   	pop    %edi
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b6:	be 00 00 00 00       	mov    $0x0,%esi
  8002bb:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002ce:	5b                   	pop    %ebx
  8002cf:	5e                   	pop    %esi
  8002d0:	5f                   	pop    %edi
  8002d1:	5d                   	pop    %ebp
  8002d2:	c3                   	ret    

008002d3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	57                   	push   %edi
  8002d7:	56                   	push   %esi
  8002d8:	53                   	push   %ebx
  8002d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e9:	89 cb                	mov    %ecx,%ebx
  8002eb:	89 cf                	mov    %ecx,%edi
  8002ed:	89 ce                	mov    %ecx,%esi
  8002ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f1:	85 c0                	test   %eax,%eax
  8002f3:	7e 17                	jle    80030c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f5:	83 ec 0c             	sub    $0xc,%esp
  8002f8:	50                   	push   %eax
  8002f9:	6a 0c                	push   $0xc
  8002fb:	68 aa 0f 80 00       	push   $0x800faa
  800300:	6a 23                	push   $0x23
  800302:	68 c7 0f 80 00       	push   $0x800fc7
  800307:	e8 08 00 00 00       	call   800314 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80030c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030f:	5b                   	pop    %ebx
  800310:	5e                   	pop    %esi
  800311:	5f                   	pop    %edi
  800312:	5d                   	pop    %ebp
  800313:	c3                   	ret    

00800314 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800319:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800322:	e8 00 fe ff ff       	call   800127 <sys_getenvid>
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	ff 75 0c             	pushl  0xc(%ebp)
  80032d:	ff 75 08             	pushl  0x8(%ebp)
  800330:	56                   	push   %esi
  800331:	50                   	push   %eax
  800332:	68 d8 0f 80 00       	push   $0x800fd8
  800337:	e8 b1 00 00 00       	call   8003ed <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033c:	83 c4 18             	add    $0x18,%esp
  80033f:	53                   	push   %ebx
  800340:	ff 75 10             	pushl  0x10(%ebp)
  800343:	e8 54 00 00 00       	call   80039c <vcprintf>
	cprintf("\n");
  800348:	c7 04 24 30 10 80 00 	movl   $0x801030,(%esp)
  80034f:	e8 99 00 00 00       	call   8003ed <cprintf>
  800354:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800357:	cc                   	int3   
  800358:	eb fd                	jmp    800357 <_panic+0x43>

0080035a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80035a:	55                   	push   %ebp
  80035b:	89 e5                	mov    %esp,%ebp
  80035d:	53                   	push   %ebx
  80035e:	83 ec 04             	sub    $0x4,%esp
  800361:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800364:	8b 13                	mov    (%ebx),%edx
  800366:	8d 42 01             	lea    0x1(%edx),%eax
  800369:	89 03                	mov    %eax,(%ebx)
  80036b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800372:	3d ff 00 00 00       	cmp    $0xff,%eax
  800377:	75 1a                	jne    800393 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800379:	83 ec 08             	sub    $0x8,%esp
  80037c:	68 ff 00 00 00       	push   $0xff
  800381:	8d 43 08             	lea    0x8(%ebx),%eax
  800384:	50                   	push   %eax
  800385:	e8 1f fd ff ff       	call   8000a9 <sys_cputs>
		b->idx = 0;
  80038a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800390:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800393:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800397:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80039a:	c9                   	leave  
  80039b:	c3                   	ret    

0080039c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003ac:	00 00 00 
	b.cnt = 0;
  8003af:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b9:	ff 75 0c             	pushl  0xc(%ebp)
  8003bc:	ff 75 08             	pushl  0x8(%ebp)
  8003bf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c5:	50                   	push   %eax
  8003c6:	68 5a 03 80 00       	push   $0x80035a
  8003cb:	e8 54 01 00 00       	call   800524 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003d0:	83 c4 08             	add    $0x8,%esp
  8003d3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003df:	50                   	push   %eax
  8003e0:	e8 c4 fc ff ff       	call   8000a9 <sys_cputs>

	return b.cnt;
}
  8003e5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003eb:	c9                   	leave  
  8003ec:	c3                   	ret    

008003ed <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003ed:	55                   	push   %ebp
  8003ee:	89 e5                	mov    %esp,%ebp
  8003f0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f6:	50                   	push   %eax
  8003f7:	ff 75 08             	pushl  0x8(%ebp)
  8003fa:	e8 9d ff ff ff       	call   80039c <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ff:	c9                   	leave  
  800400:	c3                   	ret    

00800401 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800401:	55                   	push   %ebp
  800402:	89 e5                	mov    %esp,%ebp
  800404:	57                   	push   %edi
  800405:	56                   	push   %esi
  800406:	53                   	push   %ebx
  800407:	83 ec 1c             	sub    $0x1c,%esp
  80040a:	89 c7                	mov    %eax,%edi
  80040c:	89 d6                	mov    %edx,%esi
  80040e:	8b 45 08             	mov    0x8(%ebp),%eax
  800411:	8b 55 0c             	mov    0xc(%ebp),%edx
  800414:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800417:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80041a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800422:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800425:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800428:	39 d3                	cmp    %edx,%ebx
  80042a:	72 05                	jb     800431 <printnum+0x30>
  80042c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042f:	77 45                	ja     800476 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800431:	83 ec 0c             	sub    $0xc,%esp
  800434:	ff 75 18             	pushl  0x18(%ebp)
  800437:	8b 45 14             	mov    0x14(%ebp),%eax
  80043a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043d:	53                   	push   %ebx
  80043e:	ff 75 10             	pushl  0x10(%ebp)
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	ff 75 e4             	pushl  -0x1c(%ebp)
  800447:	ff 75 e0             	pushl  -0x20(%ebp)
  80044a:	ff 75 dc             	pushl  -0x24(%ebp)
  80044d:	ff 75 d8             	pushl  -0x28(%ebp)
  800450:	e8 ab 08 00 00       	call   800d00 <__udivdi3>
  800455:	83 c4 18             	add    $0x18,%esp
  800458:	52                   	push   %edx
  800459:	50                   	push   %eax
  80045a:	89 f2                	mov    %esi,%edx
  80045c:	89 f8                	mov    %edi,%eax
  80045e:	e8 9e ff ff ff       	call   800401 <printnum>
  800463:	83 c4 20             	add    $0x20,%esp
  800466:	eb 18                	jmp    800480 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	56                   	push   %esi
  80046c:	ff 75 18             	pushl  0x18(%ebp)
  80046f:	ff d7                	call   *%edi
  800471:	83 c4 10             	add    $0x10,%esp
  800474:	eb 03                	jmp    800479 <printnum+0x78>
  800476:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800479:	83 eb 01             	sub    $0x1,%ebx
  80047c:	85 db                	test   %ebx,%ebx
  80047e:	7f e8                	jg     800468 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	56                   	push   %esi
  800484:	83 ec 04             	sub    $0x4,%esp
  800487:	ff 75 e4             	pushl  -0x1c(%ebp)
  80048a:	ff 75 e0             	pushl  -0x20(%ebp)
  80048d:	ff 75 dc             	pushl  -0x24(%ebp)
  800490:	ff 75 d8             	pushl  -0x28(%ebp)
  800493:	e8 98 09 00 00       	call   800e30 <__umoddi3>
  800498:	83 c4 14             	add    $0x14,%esp
  80049b:	0f be 80 fc 0f 80 00 	movsbl 0x800ffc(%eax),%eax
  8004a2:	50                   	push   %eax
  8004a3:	ff d7                	call   *%edi
}
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ab:	5b                   	pop    %ebx
  8004ac:	5e                   	pop    %esi
  8004ad:	5f                   	pop    %edi
  8004ae:	5d                   	pop    %ebp
  8004af:	c3                   	ret    

008004b0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004b3:	83 fa 01             	cmp    $0x1,%edx
  8004b6:	7e 0e                	jle    8004c6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b8:	8b 10                	mov    (%eax),%edx
  8004ba:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004bd:	89 08                	mov    %ecx,(%eax)
  8004bf:	8b 02                	mov    (%edx),%eax
  8004c1:	8b 52 04             	mov    0x4(%edx),%edx
  8004c4:	eb 22                	jmp    8004e8 <getuint+0x38>
	else if (lflag)
  8004c6:	85 d2                	test   %edx,%edx
  8004c8:	74 10                	je     8004da <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004ca:	8b 10                	mov    (%eax),%edx
  8004cc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cf:	89 08                	mov    %ecx,(%eax)
  8004d1:	8b 02                	mov    (%edx),%eax
  8004d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d8:	eb 0e                	jmp    8004e8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004df:	89 08                	mov    %ecx,(%eax)
  8004e1:	8b 02                	mov    (%edx),%eax
  8004e3:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e8:	5d                   	pop    %ebp
  8004e9:	c3                   	ret    

008004ea <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f4:	8b 10                	mov    (%eax),%edx
  8004f6:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f9:	73 0a                	jae    800505 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004fb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fe:	89 08                	mov    %ecx,(%eax)
  800500:	8b 45 08             	mov    0x8(%ebp),%eax
  800503:	88 02                	mov    %al,(%edx)
}
  800505:	5d                   	pop    %ebp
  800506:	c3                   	ret    

00800507 <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800507:	55                   	push   %ebp
  800508:	89 e5                	mov    %esp,%ebp
  80050a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800510:	50                   	push   %eax
  800511:	ff 75 10             	pushl  0x10(%ebp)
  800514:	ff 75 0c             	pushl  0xc(%ebp)
  800517:	ff 75 08             	pushl  0x8(%ebp)
  80051a:	e8 05 00 00 00       	call   800524 <vprintfmt>
	va_end(ap);
}
  80051f:	83 c4 10             	add    $0x10,%esp
  800522:	c9                   	leave  
  800523:	c3                   	ret    

00800524 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800524:	55                   	push   %ebp
  800525:	89 e5                	mov    %esp,%ebp
  800527:	57                   	push   %edi
  800528:	56                   	push   %esi
  800529:	53                   	push   %ebx
  80052a:	83 ec 2c             	sub    $0x2c,%esp
  80052d:	8b 75 08             	mov    0x8(%ebp),%esi
  800530:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800533:	8b 7d 10             	mov    0x10(%ebp),%edi
  800536:	eb 12                	jmp    80054a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800538:	85 c0                	test   %eax,%eax
  80053a:	0f 84 cb 03 00 00    	je     80090b <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	53                   	push   %ebx
  800544:	50                   	push   %eax
  800545:	ff d6                	call   *%esi
  800547:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80054a:	83 c7 01             	add    $0x1,%edi
  80054d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800551:	83 f8 25             	cmp    $0x25,%eax
  800554:	75 e2                	jne    800538 <vprintfmt+0x14>
  800556:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80055a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800561:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800568:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80056f:	ba 00 00 00 00       	mov    $0x0,%edx
  800574:	eb 07                	jmp    80057d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800576:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800579:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057d:	8d 47 01             	lea    0x1(%edi),%eax
  800580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800583:	0f b6 07             	movzbl (%edi),%eax
  800586:	0f b6 c8             	movzbl %al,%ecx
  800589:	83 e8 23             	sub    $0x23,%eax
  80058c:	3c 55                	cmp    $0x55,%al
  80058e:	0f 87 5c 03 00 00    	ja     8008f0 <vprintfmt+0x3cc>
  800594:	0f b6 c0             	movzbl %al,%eax
  800597:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  80059e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005a1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005a5:	eb d6                	jmp    80057d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8005af:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005b9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005bc:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005bf:	83 fa 09             	cmp    $0x9,%edx
  8005c2:	77 39                	ja     8005fd <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005c7:	eb e9                	jmp    8005b2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8d 48 04             	lea    0x4(%eax),%ecx
  8005cf:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005d2:	8b 00                	mov    (%eax),%eax
  8005d4:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005da:	eb 27                	jmp    800603 <vprintfmt+0xdf>
  8005dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005df:	85 c0                	test   %eax,%eax
  8005e1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e6:	0f 49 c8             	cmovns %eax,%ecx
  8005e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ef:	eb 8c                	jmp    80057d <vprintfmt+0x59>
  8005f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005f4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005fb:	eb 80                	jmp    80057d <vprintfmt+0x59>
  8005fd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800600:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800603:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800607:	0f 89 70 ff ff ff    	jns    80057d <vprintfmt+0x59>
				width = precision, precision = -1;
  80060d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800610:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800613:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80061a:	e9 5e ff ff ff       	jmp    80057d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80061f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800622:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800625:	e9 53 ff ff ff       	jmp    80057d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8d 50 04             	lea    0x4(%eax),%edx
  800630:	89 55 14             	mov    %edx,0x14(%ebp)
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	53                   	push   %ebx
  800637:	ff 30                	pushl  (%eax)
  800639:	ff d6                	call   *%esi
			break;
  80063b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800641:	e9 04 ff ff ff       	jmp    80054a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	99                   	cltd   
  800652:	31 d0                	xor    %edx,%eax
  800654:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800656:	83 f8 09             	cmp    $0x9,%eax
  800659:	7f 0b                	jg     800666 <vprintfmt+0x142>
  80065b:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  800662:	85 d2                	test   %edx,%edx
  800664:	75 18                	jne    80067e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800666:	50                   	push   %eax
  800667:	68 14 10 80 00       	push   $0x801014
  80066c:	53                   	push   %ebx
  80066d:	56                   	push   %esi
  80066e:	e8 94 fe ff ff       	call   800507 <printfmt>
  800673:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800676:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800679:	e9 cc fe ff ff       	jmp    80054a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80067e:	52                   	push   %edx
  80067f:	68 1d 10 80 00       	push   $0x80101d
  800684:	53                   	push   %ebx
  800685:	56                   	push   %esi
  800686:	e8 7c fe ff ff       	call   800507 <printfmt>
  80068b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800691:	e9 b4 fe ff ff       	jmp    80054a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8d 50 04             	lea    0x4(%eax),%edx
  80069c:	89 55 14             	mov    %edx,0x14(%ebp)
  80069f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006a1:	85 ff                	test   %edi,%edi
  8006a3:	b8 0d 10 80 00       	mov    $0x80100d,%eax
  8006a8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006ab:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006af:	0f 8e 94 00 00 00    	jle    800749 <vprintfmt+0x225>
  8006b5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006b9:	0f 84 98 00 00 00    	je     800757 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	ff 75 c8             	pushl  -0x38(%ebp)
  8006c5:	57                   	push   %edi
  8006c6:	e8 c8 02 00 00       	call   800993 <strnlen>
  8006cb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006ce:	29 c1                	sub    %eax,%ecx
  8006d0:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006d3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006dd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006e0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e2:	eb 0f                	jmp    8006f3 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006e4:	83 ec 08             	sub    $0x8,%esp
  8006e7:	53                   	push   %ebx
  8006e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006eb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ed:	83 ef 01             	sub    $0x1,%edi
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	85 ff                	test   %edi,%edi
  8006f5:	7f ed                	jg     8006e4 <vprintfmt+0x1c0>
  8006f7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006fa:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006fd:	85 c9                	test   %ecx,%ecx
  8006ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800704:	0f 49 c1             	cmovns %ecx,%eax
  800707:	29 c1                	sub    %eax,%ecx
  800709:	89 75 08             	mov    %esi,0x8(%ebp)
  80070c:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80070f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800712:	89 cb                	mov    %ecx,%ebx
  800714:	eb 4d                	jmp    800763 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800716:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80071a:	74 1b                	je     800737 <vprintfmt+0x213>
  80071c:	0f be c0             	movsbl %al,%eax
  80071f:	83 e8 20             	sub    $0x20,%eax
  800722:	83 f8 5e             	cmp    $0x5e,%eax
  800725:	76 10                	jbe    800737 <vprintfmt+0x213>
					putch('?', putdat);
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	ff 75 0c             	pushl  0xc(%ebp)
  80072d:	6a 3f                	push   $0x3f
  80072f:	ff 55 08             	call   *0x8(%ebp)
  800732:	83 c4 10             	add    $0x10,%esp
  800735:	eb 0d                	jmp    800744 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	52                   	push   %edx
  80073e:	ff 55 08             	call   *0x8(%ebp)
  800741:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800744:	83 eb 01             	sub    $0x1,%ebx
  800747:	eb 1a                	jmp    800763 <vprintfmt+0x23f>
  800749:	89 75 08             	mov    %esi,0x8(%ebp)
  80074c:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80074f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800752:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800755:	eb 0c                	jmp    800763 <vprintfmt+0x23f>
  800757:	89 75 08             	mov    %esi,0x8(%ebp)
  80075a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80075d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800760:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800763:	83 c7 01             	add    $0x1,%edi
  800766:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80076a:	0f be d0             	movsbl %al,%edx
  80076d:	85 d2                	test   %edx,%edx
  80076f:	74 23                	je     800794 <vprintfmt+0x270>
  800771:	85 f6                	test   %esi,%esi
  800773:	78 a1                	js     800716 <vprintfmt+0x1f2>
  800775:	83 ee 01             	sub    $0x1,%esi
  800778:	79 9c                	jns    800716 <vprintfmt+0x1f2>
  80077a:	89 df                	mov    %ebx,%edi
  80077c:	8b 75 08             	mov    0x8(%ebp),%esi
  80077f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800782:	eb 18                	jmp    80079c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	53                   	push   %ebx
  800788:	6a 20                	push   $0x20
  80078a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078c:	83 ef 01             	sub    $0x1,%edi
  80078f:	83 c4 10             	add    $0x10,%esp
  800792:	eb 08                	jmp    80079c <vprintfmt+0x278>
  800794:	89 df                	mov    %ebx,%edi
  800796:	8b 75 08             	mov    0x8(%ebp),%esi
  800799:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079c:	85 ff                	test   %edi,%edi
  80079e:	7f e4                	jg     800784 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a3:	e9 a2 fd ff ff       	jmp    80054a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a8:	83 fa 01             	cmp    $0x1,%edx
  8007ab:	7e 16                	jle    8007c3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b0:	8d 50 08             	lea    0x8(%eax),%edx
  8007b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b6:	8b 50 04             	mov    0x4(%eax),%edx
  8007b9:	8b 00                	mov    (%eax),%eax
  8007bb:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007be:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007c1:	eb 32                	jmp    8007f5 <vprintfmt+0x2d1>
	else if (lflag)
  8007c3:	85 d2                	test   %edx,%edx
  8007c5:	74 18                	je     8007df <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ca:	8d 50 04             	lea    0x4(%eax),%edx
  8007cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d0:	8b 00                	mov    (%eax),%eax
  8007d2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007d5:	89 c1                	mov    %eax,%ecx
  8007d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007da:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007dd:	eb 16                	jmp    8007f5 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8d 50 04             	lea    0x4(%eax),%edx
  8007e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e8:	8b 00                	mov    (%eax),%eax
  8007ea:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007ed:	89 c1                	mov    %eax,%ecx
  8007ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f5:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007f8:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800801:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800806:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80080a:	0f 89 a8 00 00 00    	jns    8008b8 <vprintfmt+0x394>
				putch('-', putdat);
  800810:	83 ec 08             	sub    $0x8,%esp
  800813:	53                   	push   %ebx
  800814:	6a 2d                	push   $0x2d
  800816:	ff d6                	call   *%esi
				num = -(long long) num;
  800818:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80081b:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80081e:	f7 d8                	neg    %eax
  800820:	83 d2 00             	adc    $0x0,%edx
  800823:	f7 da                	neg    %edx
  800825:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800828:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80082b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80082e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800833:	e9 80 00 00 00       	jmp    8008b8 <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800838:	8d 45 14             	lea    0x14(%ebp),%eax
  80083b:	e8 70 fc ff ff       	call   8004b0 <getuint>
  800840:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800843:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800846:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80084b:	eb 6b                	jmp    8008b8 <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80084d:	8d 45 14             	lea    0x14(%ebp),%eax
  800850:	e8 5b fc ff ff       	call   8004b0 <getuint>
  800855:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800858:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  80085b:	6a 04                	push   $0x4
  80085d:	6a 03                	push   $0x3
  80085f:	6a 01                	push   $0x1
  800861:	68 20 10 80 00       	push   $0x801020
  800866:	e8 82 fb ff ff       	call   8003ed <cprintf>
			goto number;
  80086b:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  80086e:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  800873:	eb 43                	jmp    8008b8 <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  800875:	83 ec 08             	sub    $0x8,%esp
  800878:	53                   	push   %ebx
  800879:	6a 30                	push   $0x30
  80087b:	ff d6                	call   *%esi
			putch('x', putdat);
  80087d:	83 c4 08             	add    $0x8,%esp
  800880:	53                   	push   %ebx
  800881:	6a 78                	push   $0x78
  800883:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800885:	8b 45 14             	mov    0x14(%ebp),%eax
  800888:	8d 50 04             	lea    0x4(%eax),%edx
  80088b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80088e:	8b 00                	mov    (%eax),%eax
  800890:	ba 00 00 00 00       	mov    $0x0,%edx
  800895:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800898:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80089b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80089e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008a3:	eb 13                	jmp    8008b8 <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008a5:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a8:	e8 03 fc ff ff       	call   8004b0 <getuint>
  8008ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008b3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008b8:	83 ec 0c             	sub    $0xc,%esp
  8008bb:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8008bf:	52                   	push   %edx
  8008c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c3:	50                   	push   %eax
  8008c4:	ff 75 dc             	pushl  -0x24(%ebp)
  8008c7:	ff 75 d8             	pushl  -0x28(%ebp)
  8008ca:	89 da                	mov    %ebx,%edx
  8008cc:	89 f0                	mov    %esi,%eax
  8008ce:	e8 2e fb ff ff       	call   800401 <printnum>

			break;
  8008d3:	83 c4 20             	add    $0x20,%esp
  8008d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008d9:	e9 6c fc ff ff       	jmp    80054a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008de:	83 ec 08             	sub    $0x8,%esp
  8008e1:	53                   	push   %ebx
  8008e2:	51                   	push   %ecx
  8008e3:	ff d6                	call   *%esi
			break;
  8008e5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008eb:	e9 5a fc ff ff       	jmp    80054a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008f0:	83 ec 08             	sub    $0x8,%esp
  8008f3:	53                   	push   %ebx
  8008f4:	6a 25                	push   $0x25
  8008f6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008f8:	83 c4 10             	add    $0x10,%esp
  8008fb:	eb 03                	jmp    800900 <vprintfmt+0x3dc>
  8008fd:	83 ef 01             	sub    $0x1,%edi
  800900:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800904:	75 f7                	jne    8008fd <vprintfmt+0x3d9>
  800906:	e9 3f fc ff ff       	jmp    80054a <vprintfmt+0x26>
			break;
		}

	}

}
  80090b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80090e:	5b                   	pop    %ebx
  80090f:	5e                   	pop    %esi
  800910:	5f                   	pop    %edi
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	83 ec 18             	sub    $0x18,%esp
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80091f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800922:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800926:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800929:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800930:	85 c0                	test   %eax,%eax
  800932:	74 26                	je     80095a <vsnprintf+0x47>
  800934:	85 d2                	test   %edx,%edx
  800936:	7e 22                	jle    80095a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800938:	ff 75 14             	pushl  0x14(%ebp)
  80093b:	ff 75 10             	pushl  0x10(%ebp)
  80093e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800941:	50                   	push   %eax
  800942:	68 ea 04 80 00       	push   $0x8004ea
  800947:	e8 d8 fb ff ff       	call   800524 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80094c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80094f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800952:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800955:	83 c4 10             	add    $0x10,%esp
  800958:	eb 05                	jmp    80095f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80095a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80095f:	c9                   	leave  
  800960:	c3                   	ret    

00800961 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800967:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80096a:	50                   	push   %eax
  80096b:	ff 75 10             	pushl  0x10(%ebp)
  80096e:	ff 75 0c             	pushl  0xc(%ebp)
  800971:	ff 75 08             	pushl  0x8(%ebp)
  800974:	e8 9a ff ff ff       	call   800913 <vsnprintf>
	va_end(ap);

	return rc;
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800981:	b8 00 00 00 00       	mov    $0x0,%eax
  800986:	eb 03                	jmp    80098b <strlen+0x10>
		n++;
  800988:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80098b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80098f:	75 f7                	jne    800988 <strlen+0xd>
		n++;
	return n;
}
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800999:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099c:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a1:	eb 03                	jmp    8009a6 <strnlen+0x13>
		n++;
  8009a3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a6:	39 c2                	cmp    %eax,%edx
  8009a8:	74 08                	je     8009b2 <strnlen+0x1f>
  8009aa:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009ae:	75 f3                	jne    8009a3 <strnlen+0x10>
  8009b0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	53                   	push   %ebx
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009be:	89 c2                	mov    %eax,%edx
  8009c0:	83 c2 01             	add    $0x1,%edx
  8009c3:	83 c1 01             	add    $0x1,%ecx
  8009c6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009ca:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009cd:	84 db                	test   %bl,%bl
  8009cf:	75 ef                	jne    8009c0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009d1:	5b                   	pop    %ebx
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	53                   	push   %ebx
  8009d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009db:	53                   	push   %ebx
  8009dc:	e8 9a ff ff ff       	call   80097b <strlen>
  8009e1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009e4:	ff 75 0c             	pushl  0xc(%ebp)
  8009e7:	01 d8                	add    %ebx,%eax
  8009e9:	50                   	push   %eax
  8009ea:	e8 c5 ff ff ff       	call   8009b4 <strcpy>
	return dst;
}
  8009ef:	89 d8                	mov    %ebx,%eax
  8009f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	56                   	push   %esi
  8009fa:	53                   	push   %ebx
  8009fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8009fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a01:	89 f3                	mov    %esi,%ebx
  800a03:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a06:	89 f2                	mov    %esi,%edx
  800a08:	eb 0f                	jmp    800a19 <strncpy+0x23>
		*dst++ = *src;
  800a0a:	83 c2 01             	add    $0x1,%edx
  800a0d:	0f b6 01             	movzbl (%ecx),%eax
  800a10:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a13:	80 39 01             	cmpb   $0x1,(%ecx)
  800a16:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a19:	39 da                	cmp    %ebx,%edx
  800a1b:	75 ed                	jne    800a0a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a1d:	89 f0                	mov    %esi,%eax
  800a1f:	5b                   	pop    %ebx
  800a20:	5e                   	pop    %esi
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2e:	8b 55 10             	mov    0x10(%ebp),%edx
  800a31:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a33:	85 d2                	test   %edx,%edx
  800a35:	74 21                	je     800a58 <strlcpy+0x35>
  800a37:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a3b:	89 f2                	mov    %esi,%edx
  800a3d:	eb 09                	jmp    800a48 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a3f:	83 c2 01             	add    $0x1,%edx
  800a42:	83 c1 01             	add    $0x1,%ecx
  800a45:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a48:	39 c2                	cmp    %eax,%edx
  800a4a:	74 09                	je     800a55 <strlcpy+0x32>
  800a4c:	0f b6 19             	movzbl (%ecx),%ebx
  800a4f:	84 db                	test   %bl,%bl
  800a51:	75 ec                	jne    800a3f <strlcpy+0x1c>
  800a53:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a55:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a58:	29 f0                	sub    %esi,%eax
}
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a64:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a67:	eb 06                	jmp    800a6f <strcmp+0x11>
		p++, q++;
  800a69:	83 c1 01             	add    $0x1,%ecx
  800a6c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a6f:	0f b6 01             	movzbl (%ecx),%eax
  800a72:	84 c0                	test   %al,%al
  800a74:	74 04                	je     800a7a <strcmp+0x1c>
  800a76:	3a 02                	cmp    (%edx),%al
  800a78:	74 ef                	je     800a69 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7a:	0f b6 c0             	movzbl %al,%eax
  800a7d:	0f b6 12             	movzbl (%edx),%edx
  800a80:	29 d0                	sub    %edx,%eax
}
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	53                   	push   %ebx
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8e:	89 c3                	mov    %eax,%ebx
  800a90:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a93:	eb 06                	jmp    800a9b <strncmp+0x17>
		n--, p++, q++;
  800a95:	83 c0 01             	add    $0x1,%eax
  800a98:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a9b:	39 d8                	cmp    %ebx,%eax
  800a9d:	74 15                	je     800ab4 <strncmp+0x30>
  800a9f:	0f b6 08             	movzbl (%eax),%ecx
  800aa2:	84 c9                	test   %cl,%cl
  800aa4:	74 04                	je     800aaa <strncmp+0x26>
  800aa6:	3a 0a                	cmp    (%edx),%cl
  800aa8:	74 eb                	je     800a95 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aaa:	0f b6 00             	movzbl (%eax),%eax
  800aad:	0f b6 12             	movzbl (%edx),%edx
  800ab0:	29 d0                	sub    %edx,%eax
  800ab2:	eb 05                	jmp    800ab9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ab4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac6:	eb 07                	jmp    800acf <strchr+0x13>
		if (*s == c)
  800ac8:	38 ca                	cmp    %cl,%dl
  800aca:	74 0f                	je     800adb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800acc:	83 c0 01             	add    $0x1,%eax
  800acf:	0f b6 10             	movzbl (%eax),%edx
  800ad2:	84 d2                	test   %dl,%dl
  800ad4:	75 f2                	jne    800ac8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae7:	eb 03                	jmp    800aec <strfind+0xf>
  800ae9:	83 c0 01             	add    $0x1,%eax
  800aec:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aef:	38 ca                	cmp    %cl,%dl
  800af1:	74 04                	je     800af7 <strfind+0x1a>
  800af3:	84 d2                	test   %dl,%dl
  800af5:	75 f2                	jne    800ae9 <strfind+0xc>
			break;
	return (char *) s;
}
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b05:	85 c9                	test   %ecx,%ecx
  800b07:	74 36                	je     800b3f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b09:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b0f:	75 28                	jne    800b39 <memset+0x40>
  800b11:	f6 c1 03             	test   $0x3,%cl
  800b14:	75 23                	jne    800b39 <memset+0x40>
		c &= 0xFF;
  800b16:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b1a:	89 d3                	mov    %edx,%ebx
  800b1c:	c1 e3 08             	shl    $0x8,%ebx
  800b1f:	89 d6                	mov    %edx,%esi
  800b21:	c1 e6 18             	shl    $0x18,%esi
  800b24:	89 d0                	mov    %edx,%eax
  800b26:	c1 e0 10             	shl    $0x10,%eax
  800b29:	09 f0                	or     %esi,%eax
  800b2b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b2d:	89 d8                	mov    %ebx,%eax
  800b2f:	09 d0                	or     %edx,%eax
  800b31:	c1 e9 02             	shr    $0x2,%ecx
  800b34:	fc                   	cld    
  800b35:	f3 ab                	rep stos %eax,%es:(%edi)
  800b37:	eb 06                	jmp    800b3f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3c:	fc                   	cld    
  800b3d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b3f:	89 f8                	mov    %edi,%eax
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b51:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b54:	39 c6                	cmp    %eax,%esi
  800b56:	73 35                	jae    800b8d <memmove+0x47>
  800b58:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b5b:	39 d0                	cmp    %edx,%eax
  800b5d:	73 2e                	jae    800b8d <memmove+0x47>
		s += n;
		d += n;
  800b5f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b62:	89 d6                	mov    %edx,%esi
  800b64:	09 fe                	or     %edi,%esi
  800b66:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b6c:	75 13                	jne    800b81 <memmove+0x3b>
  800b6e:	f6 c1 03             	test   $0x3,%cl
  800b71:	75 0e                	jne    800b81 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b73:	83 ef 04             	sub    $0x4,%edi
  800b76:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b79:	c1 e9 02             	shr    $0x2,%ecx
  800b7c:	fd                   	std    
  800b7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7f:	eb 09                	jmp    800b8a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b81:	83 ef 01             	sub    $0x1,%edi
  800b84:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b87:	fd                   	std    
  800b88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b8a:	fc                   	cld    
  800b8b:	eb 1d                	jmp    800baa <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8d:	89 f2                	mov    %esi,%edx
  800b8f:	09 c2                	or     %eax,%edx
  800b91:	f6 c2 03             	test   $0x3,%dl
  800b94:	75 0f                	jne    800ba5 <memmove+0x5f>
  800b96:	f6 c1 03             	test   $0x3,%cl
  800b99:	75 0a                	jne    800ba5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b9b:	c1 e9 02             	shr    $0x2,%ecx
  800b9e:	89 c7                	mov    %eax,%edi
  800ba0:	fc                   	cld    
  800ba1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba3:	eb 05                	jmp    800baa <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ba5:	89 c7                	mov    %eax,%edi
  800ba7:	fc                   	cld    
  800ba8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bb1:	ff 75 10             	pushl  0x10(%ebp)
  800bb4:	ff 75 0c             	pushl  0xc(%ebp)
  800bb7:	ff 75 08             	pushl  0x8(%ebp)
  800bba:	e8 87 ff ff ff       	call   800b46 <memmove>
}
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    

00800bc1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
  800bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcc:	89 c6                	mov    %eax,%esi
  800bce:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd1:	eb 1a                	jmp    800bed <memcmp+0x2c>
		if (*s1 != *s2)
  800bd3:	0f b6 08             	movzbl (%eax),%ecx
  800bd6:	0f b6 1a             	movzbl (%edx),%ebx
  800bd9:	38 d9                	cmp    %bl,%cl
  800bdb:	74 0a                	je     800be7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bdd:	0f b6 c1             	movzbl %cl,%eax
  800be0:	0f b6 db             	movzbl %bl,%ebx
  800be3:	29 d8                	sub    %ebx,%eax
  800be5:	eb 0f                	jmp    800bf6 <memcmp+0x35>
		s1++, s2++;
  800be7:	83 c0 01             	add    $0x1,%eax
  800bea:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bed:	39 f0                	cmp    %esi,%eax
  800bef:	75 e2                	jne    800bd3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bf1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	53                   	push   %ebx
  800bfe:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c01:	89 c1                	mov    %eax,%ecx
  800c03:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c06:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c0a:	eb 0a                	jmp    800c16 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c0c:	0f b6 10             	movzbl (%eax),%edx
  800c0f:	39 da                	cmp    %ebx,%edx
  800c11:	74 07                	je     800c1a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c13:	83 c0 01             	add    $0x1,%eax
  800c16:	39 c8                	cmp    %ecx,%eax
  800c18:	72 f2                	jb     800c0c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c1a:	5b                   	pop    %ebx
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c29:	eb 03                	jmp    800c2e <strtol+0x11>
		s++;
  800c2b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2e:	0f b6 01             	movzbl (%ecx),%eax
  800c31:	3c 20                	cmp    $0x20,%al
  800c33:	74 f6                	je     800c2b <strtol+0xe>
  800c35:	3c 09                	cmp    $0x9,%al
  800c37:	74 f2                	je     800c2b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c39:	3c 2b                	cmp    $0x2b,%al
  800c3b:	75 0a                	jne    800c47 <strtol+0x2a>
		s++;
  800c3d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c40:	bf 00 00 00 00       	mov    $0x0,%edi
  800c45:	eb 11                	jmp    800c58 <strtol+0x3b>
  800c47:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c4c:	3c 2d                	cmp    $0x2d,%al
  800c4e:	75 08                	jne    800c58 <strtol+0x3b>
		s++, neg = 1;
  800c50:	83 c1 01             	add    $0x1,%ecx
  800c53:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c58:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c5e:	75 15                	jne    800c75 <strtol+0x58>
  800c60:	80 39 30             	cmpb   $0x30,(%ecx)
  800c63:	75 10                	jne    800c75 <strtol+0x58>
  800c65:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c69:	75 7c                	jne    800ce7 <strtol+0xca>
		s += 2, base = 16;
  800c6b:	83 c1 02             	add    $0x2,%ecx
  800c6e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c73:	eb 16                	jmp    800c8b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c75:	85 db                	test   %ebx,%ebx
  800c77:	75 12                	jne    800c8b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c79:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c7e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c81:	75 08                	jne    800c8b <strtol+0x6e>
		s++, base = 8;
  800c83:	83 c1 01             	add    $0x1,%ecx
  800c86:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c90:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c93:	0f b6 11             	movzbl (%ecx),%edx
  800c96:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c99:	89 f3                	mov    %esi,%ebx
  800c9b:	80 fb 09             	cmp    $0x9,%bl
  800c9e:	77 08                	ja     800ca8 <strtol+0x8b>
			dig = *s - '0';
  800ca0:	0f be d2             	movsbl %dl,%edx
  800ca3:	83 ea 30             	sub    $0x30,%edx
  800ca6:	eb 22                	jmp    800cca <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ca8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cab:	89 f3                	mov    %esi,%ebx
  800cad:	80 fb 19             	cmp    $0x19,%bl
  800cb0:	77 08                	ja     800cba <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cb2:	0f be d2             	movsbl %dl,%edx
  800cb5:	83 ea 57             	sub    $0x57,%edx
  800cb8:	eb 10                	jmp    800cca <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cba:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cbd:	89 f3                	mov    %esi,%ebx
  800cbf:	80 fb 19             	cmp    $0x19,%bl
  800cc2:	77 16                	ja     800cda <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cc4:	0f be d2             	movsbl %dl,%edx
  800cc7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cca:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ccd:	7d 0b                	jge    800cda <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ccf:	83 c1 01             	add    $0x1,%ecx
  800cd2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cd6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cd8:	eb b9                	jmp    800c93 <strtol+0x76>

	if (endptr)
  800cda:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cde:	74 0d                	je     800ced <strtol+0xd0>
		*endptr = (char *) s;
  800ce0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce3:	89 0e                	mov    %ecx,(%esi)
  800ce5:	eb 06                	jmp    800ced <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce7:	85 db                	test   %ebx,%ebx
  800ce9:	74 98                	je     800c83 <strtol+0x66>
  800ceb:	eb 9e                	jmp    800c8b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ced:	89 c2                	mov    %eax,%edx
  800cef:	f7 da                	neg    %edx
  800cf1:	85 ff                	test   %edi,%edi
  800cf3:	0f 45 c2             	cmovne %edx,%eax
}
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    
  800cfb:	66 90                	xchg   %ax,%ax
  800cfd:	66 90                	xchg   %ax,%ax
  800cff:	90                   	nop

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
