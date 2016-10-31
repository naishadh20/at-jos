
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800049:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800050:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  800053:	e8 c6 00 00 00       	call   80011e <sys_getenvid>
  800058:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800060:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800065:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 db                	test   %ebx,%ebx
  80006c:	7e 07                	jle    800075 <libmain+0x37>
		binaryname = argv[0];
  80006e:	8b 06                	mov    (%esi),%eax
  800070:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800075:	83 ec 08             	sub    $0x8,%esp
  800078:	56                   	push   %esi
  800079:	53                   	push   %ebx
  80007a:	e8 b4 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007f:	e8 0a 00 00 00       	call   80008e <exit>
}
  800084:	83 c4 10             	add    $0x10,%esp
  800087:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008a:	5b                   	pop    %ebx
  80008b:	5e                   	pop    %esi
  80008c:	5d                   	pop    %ebp
  80008d:	c3                   	ret    

0080008e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008e:	55                   	push   %ebp
  80008f:	89 e5                	mov    %esp,%ebp
  800091:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800094:	6a 00                	push   $0x0
  800096:	e8 42 00 00 00       	call   8000dd <sys_env_destroy>
}
  80009b:	83 c4 10             	add    $0x10,%esp
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b1:	89 c3                	mov    %eax,%ebx
  8000b3:	89 c7                	mov    %eax,%edi
  8000b5:	89 c6                	mov    %eax,%esi
  8000b7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <sys_cgetc>:

int
sys_cgetc(void)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ce:	89 d1                	mov    %edx,%ecx
  8000d0:	89 d3                	mov    %edx,%ebx
  8000d2:	89 d7                	mov    %edx,%edi
  8000d4:	89 d6                	mov    %edx,%esi
  8000d6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d8:	5b                   	pop    %ebx
  8000d9:	5e                   	pop    %esi
  8000da:	5f                   	pop    %edi
  8000db:	5d                   	pop    %ebp
  8000dc:	c3                   	ret    

008000dd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dd:	55                   	push   %ebp
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	57                   	push   %edi
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000eb:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f3:	89 cb                	mov    %ecx,%ebx
  8000f5:	89 cf                	mov    %ecx,%edi
  8000f7:	89 ce                	mov    %ecx,%esi
  8000f9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fb:	85 c0                	test   %eax,%eax
  8000fd:	7e 17                	jle    800116 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ff:	83 ec 0c             	sub    $0xc,%esp
  800102:	50                   	push   %eax
  800103:	6a 03                	push   $0x3
  800105:	68 aa 0f 80 00       	push   $0x800faa
  80010a:	6a 23                	push   $0x23
  80010c:	68 c7 0f 80 00       	push   $0x800fc7
  800111:	e8 f5 01 00 00       	call   80030b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800119:	5b                   	pop    %ebx
  80011a:	5e                   	pop    %esi
  80011b:	5f                   	pop    %edi
  80011c:	5d                   	pop    %ebp
  80011d:	c3                   	ret    

0080011e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	57                   	push   %edi
  800122:	56                   	push   %esi
  800123:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800124:	ba 00 00 00 00       	mov    $0x0,%edx
  800129:	b8 02 00 00 00       	mov    $0x2,%eax
  80012e:	89 d1                	mov    %edx,%ecx
  800130:	89 d3                	mov    %edx,%ebx
  800132:	89 d7                	mov    %edx,%edi
  800134:	89 d6                	mov    %edx,%esi
  800136:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800138:	5b                   	pop    %ebx
  800139:	5e                   	pop    %esi
  80013a:	5f                   	pop    %edi
  80013b:	5d                   	pop    %ebp
  80013c:	c3                   	ret    

0080013d <sys_yield>:

void
sys_yield(void)
{
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	57                   	push   %edi
  800141:	56                   	push   %esi
  800142:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800143:	ba 00 00 00 00       	mov    $0x0,%edx
  800148:	b8 0a 00 00 00       	mov    $0xa,%eax
  80014d:	89 d1                	mov    %edx,%ecx
  80014f:	89 d3                	mov    %edx,%ebx
  800151:	89 d7                	mov    %edx,%edi
  800153:	89 d6                	mov    %edx,%esi
  800155:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800157:	5b                   	pop    %ebx
  800158:	5e                   	pop    %esi
  800159:	5f                   	pop    %edi
  80015a:	5d                   	pop    %ebp
  80015b:	c3                   	ret    

0080015c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	57                   	push   %edi
  800160:	56                   	push   %esi
  800161:	53                   	push   %ebx
  800162:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800165:	be 00 00 00 00       	mov    $0x0,%esi
  80016a:	b8 04 00 00 00       	mov    $0x4,%eax
  80016f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800172:	8b 55 08             	mov    0x8(%ebp),%edx
  800175:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800178:	89 f7                	mov    %esi,%edi
  80017a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017c:	85 c0                	test   %eax,%eax
  80017e:	7e 17                	jle    800197 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800180:	83 ec 0c             	sub    $0xc,%esp
  800183:	50                   	push   %eax
  800184:	6a 04                	push   $0x4
  800186:	68 aa 0f 80 00       	push   $0x800faa
  80018b:	6a 23                	push   $0x23
  80018d:	68 c7 0f 80 00       	push   $0x800fc7
  800192:	e8 74 01 00 00       	call   80030b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800197:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019a:	5b                   	pop    %ebx
  80019b:	5e                   	pop    %esi
  80019c:	5f                   	pop    %edi
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    

0080019f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	57                   	push   %edi
  8001a3:	56                   	push   %esi
  8001a4:	53                   	push   %ebx
  8001a5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a8:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b9:	8b 75 18             	mov    0x18(%ebp),%esi
  8001bc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001be:	85 c0                	test   %eax,%eax
  8001c0:	7e 17                	jle    8001d9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c2:	83 ec 0c             	sub    $0xc,%esp
  8001c5:	50                   	push   %eax
  8001c6:	6a 05                	push   $0x5
  8001c8:	68 aa 0f 80 00       	push   $0x800faa
  8001cd:	6a 23                	push   $0x23
  8001cf:	68 c7 0f 80 00       	push   $0x800fc7
  8001d4:	e8 32 01 00 00       	call   80030b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001dc:	5b                   	pop    %ebx
  8001dd:	5e                   	pop    %esi
  8001de:	5f                   	pop    %edi
  8001df:	5d                   	pop    %ebp
  8001e0:	c3                   	ret    

008001e1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	57                   	push   %edi
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ef:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fa:	89 df                	mov    %ebx,%edi
  8001fc:	89 de                	mov    %ebx,%esi
  8001fe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800200:	85 c0                	test   %eax,%eax
  800202:	7e 17                	jle    80021b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800204:	83 ec 0c             	sub    $0xc,%esp
  800207:	50                   	push   %eax
  800208:	6a 06                	push   $0x6
  80020a:	68 aa 0f 80 00       	push   $0x800faa
  80020f:	6a 23                	push   $0x23
  800211:	68 c7 0f 80 00       	push   $0x800fc7
  800216:	e8 f0 00 00 00       	call   80030b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021e:	5b                   	pop    %ebx
  80021f:	5e                   	pop    %esi
  800220:	5f                   	pop    %edi
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    

00800223 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	57                   	push   %edi
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
  800229:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800231:	b8 08 00 00 00       	mov    $0x8,%eax
  800236:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800239:	8b 55 08             	mov    0x8(%ebp),%edx
  80023c:	89 df                	mov    %ebx,%edi
  80023e:	89 de                	mov    %ebx,%esi
  800240:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800242:	85 c0                	test   %eax,%eax
  800244:	7e 17                	jle    80025d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800246:	83 ec 0c             	sub    $0xc,%esp
  800249:	50                   	push   %eax
  80024a:	6a 08                	push   $0x8
  80024c:	68 aa 0f 80 00       	push   $0x800faa
  800251:	6a 23                	push   $0x23
  800253:	68 c7 0f 80 00       	push   $0x800fc7
  800258:	e8 ae 00 00 00       	call   80030b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800260:	5b                   	pop    %ebx
  800261:	5e                   	pop    %esi
  800262:	5f                   	pop    %edi
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    

00800265 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	57                   	push   %edi
  800269:	56                   	push   %esi
  80026a:	53                   	push   %ebx
  80026b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800273:	b8 09 00 00 00       	mov    $0x9,%eax
  800278:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027b:	8b 55 08             	mov    0x8(%ebp),%edx
  80027e:	89 df                	mov    %ebx,%edi
  800280:	89 de                	mov    %ebx,%esi
  800282:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800284:	85 c0                	test   %eax,%eax
  800286:	7e 17                	jle    80029f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800288:	83 ec 0c             	sub    $0xc,%esp
  80028b:	50                   	push   %eax
  80028c:	6a 09                	push   $0x9
  80028e:	68 aa 0f 80 00       	push   $0x800faa
  800293:	6a 23                	push   $0x23
  800295:	68 c7 0f 80 00       	push   $0x800fc7
  80029a:	e8 6c 00 00 00       	call   80030b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80029f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a2:	5b                   	pop    %ebx
  8002a3:	5e                   	pop    %esi
  8002a4:	5f                   	pop    %edi
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    

008002a7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	57                   	push   %edi
  8002ab:	56                   	push   %esi
  8002ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ad:	be 00 00 00 00       	mov    $0x0,%esi
  8002b2:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c5:	5b                   	pop    %ebx
  8002c6:	5e                   	pop    %esi
  8002c7:	5f                   	pop    %edi
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	57                   	push   %edi
  8002ce:	56                   	push   %esi
  8002cf:	53                   	push   %ebx
  8002d0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d8:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e0:	89 cb                	mov    %ecx,%ebx
  8002e2:	89 cf                	mov    %ecx,%edi
  8002e4:	89 ce                	mov    %ecx,%esi
  8002e6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e8:	85 c0                	test   %eax,%eax
  8002ea:	7e 17                	jle    800303 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ec:	83 ec 0c             	sub    $0xc,%esp
  8002ef:	50                   	push   %eax
  8002f0:	6a 0c                	push   $0xc
  8002f2:	68 aa 0f 80 00       	push   $0x800faa
  8002f7:	6a 23                	push   $0x23
  8002f9:	68 c7 0f 80 00       	push   $0x800fc7
  8002fe:	e8 08 00 00 00       	call   80030b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800303:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5f                   	pop    %edi
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800310:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800313:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800319:	e8 00 fe ff ff       	call   80011e <sys_getenvid>
  80031e:	83 ec 0c             	sub    $0xc,%esp
  800321:	ff 75 0c             	pushl  0xc(%ebp)
  800324:	ff 75 08             	pushl  0x8(%ebp)
  800327:	56                   	push   %esi
  800328:	50                   	push   %eax
  800329:	68 d8 0f 80 00       	push   $0x800fd8
  80032e:	e8 b1 00 00 00       	call   8003e4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800333:	83 c4 18             	add    $0x18,%esp
  800336:	53                   	push   %ebx
  800337:	ff 75 10             	pushl  0x10(%ebp)
  80033a:	e8 54 00 00 00       	call   800393 <vcprintf>
	cprintf("\n");
  80033f:	c7 04 24 30 10 80 00 	movl   $0x801030,(%esp)
  800346:	e8 99 00 00 00       	call   8003e4 <cprintf>
  80034b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80034e:	cc                   	int3   
  80034f:	eb fd                	jmp    80034e <_panic+0x43>

00800351 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	53                   	push   %ebx
  800355:	83 ec 04             	sub    $0x4,%esp
  800358:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80035b:	8b 13                	mov    (%ebx),%edx
  80035d:	8d 42 01             	lea    0x1(%edx),%eax
  800360:	89 03                	mov    %eax,(%ebx)
  800362:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800365:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800369:	3d ff 00 00 00       	cmp    $0xff,%eax
  80036e:	75 1a                	jne    80038a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800370:	83 ec 08             	sub    $0x8,%esp
  800373:	68 ff 00 00 00       	push   $0xff
  800378:	8d 43 08             	lea    0x8(%ebx),%eax
  80037b:	50                   	push   %eax
  80037c:	e8 1f fd ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  800381:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800387:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80038a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80038e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800391:	c9                   	leave  
  800392:	c3                   	ret    

00800393 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80039c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a3:	00 00 00 
	b.cnt = 0;
  8003a6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ad:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b0:	ff 75 0c             	pushl  0xc(%ebp)
  8003b3:	ff 75 08             	pushl  0x8(%ebp)
  8003b6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003bc:	50                   	push   %eax
  8003bd:	68 51 03 80 00       	push   $0x800351
  8003c2:	e8 54 01 00 00       	call   80051b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c7:	83 c4 08             	add    $0x8,%esp
  8003ca:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d6:	50                   	push   %eax
  8003d7:	e8 c4 fc ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
}
  8003dc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e2:	c9                   	leave  
  8003e3:	c3                   	ret    

008003e4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ea:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ed:	50                   	push   %eax
  8003ee:	ff 75 08             	pushl  0x8(%ebp)
  8003f1:	e8 9d ff ff ff       	call   800393 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f6:	c9                   	leave  
  8003f7:	c3                   	ret    

008003f8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
  8003fb:	57                   	push   %edi
  8003fc:	56                   	push   %esi
  8003fd:	53                   	push   %ebx
  8003fe:	83 ec 1c             	sub    $0x1c,%esp
  800401:	89 c7                	mov    %eax,%edi
  800403:	89 d6                	mov    %edx,%esi
  800405:	8b 45 08             	mov    0x8(%ebp),%eax
  800408:	8b 55 0c             	mov    0xc(%ebp),%edx
  80040b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800411:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800414:	bb 00 00 00 00       	mov    $0x0,%ebx
  800419:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80041c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80041f:	39 d3                	cmp    %edx,%ebx
  800421:	72 05                	jb     800428 <printnum+0x30>
  800423:	39 45 10             	cmp    %eax,0x10(%ebp)
  800426:	77 45                	ja     80046d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800428:	83 ec 0c             	sub    $0xc,%esp
  80042b:	ff 75 18             	pushl  0x18(%ebp)
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800434:	53                   	push   %ebx
  800435:	ff 75 10             	pushl  0x10(%ebp)
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80043e:	ff 75 e0             	pushl  -0x20(%ebp)
  800441:	ff 75 dc             	pushl  -0x24(%ebp)
  800444:	ff 75 d8             	pushl  -0x28(%ebp)
  800447:	e8 b4 08 00 00       	call   800d00 <__udivdi3>
  80044c:	83 c4 18             	add    $0x18,%esp
  80044f:	52                   	push   %edx
  800450:	50                   	push   %eax
  800451:	89 f2                	mov    %esi,%edx
  800453:	89 f8                	mov    %edi,%eax
  800455:	e8 9e ff ff ff       	call   8003f8 <printnum>
  80045a:	83 c4 20             	add    $0x20,%esp
  80045d:	eb 18                	jmp    800477 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	56                   	push   %esi
  800463:	ff 75 18             	pushl  0x18(%ebp)
  800466:	ff d7                	call   *%edi
  800468:	83 c4 10             	add    $0x10,%esp
  80046b:	eb 03                	jmp    800470 <printnum+0x78>
  80046d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800470:	83 eb 01             	sub    $0x1,%ebx
  800473:	85 db                	test   %ebx,%ebx
  800475:	7f e8                	jg     80045f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	56                   	push   %esi
  80047b:	83 ec 04             	sub    $0x4,%esp
  80047e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800481:	ff 75 e0             	pushl  -0x20(%ebp)
  800484:	ff 75 dc             	pushl  -0x24(%ebp)
  800487:	ff 75 d8             	pushl  -0x28(%ebp)
  80048a:	e8 a1 09 00 00       	call   800e30 <__umoddi3>
  80048f:	83 c4 14             	add    $0x14,%esp
  800492:	0f be 80 fc 0f 80 00 	movsbl 0x800ffc(%eax),%eax
  800499:	50                   	push   %eax
  80049a:	ff d7                	call   *%edi
}
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a2:	5b                   	pop    %ebx
  8004a3:	5e                   	pop    %esi
  8004a4:	5f                   	pop    %edi
  8004a5:	5d                   	pop    %ebp
  8004a6:	c3                   	ret    

008004a7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a7:	55                   	push   %ebp
  8004a8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004aa:	83 fa 01             	cmp    $0x1,%edx
  8004ad:	7e 0e                	jle    8004bd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004af:	8b 10                	mov    (%eax),%edx
  8004b1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004b4:	89 08                	mov    %ecx,(%eax)
  8004b6:	8b 02                	mov    (%edx),%eax
  8004b8:	8b 52 04             	mov    0x4(%edx),%edx
  8004bb:	eb 22                	jmp    8004df <getuint+0x38>
	else if (lflag)
  8004bd:	85 d2                	test   %edx,%edx
  8004bf:	74 10                	je     8004d1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c1:	8b 10                	mov    (%eax),%edx
  8004c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c6:	89 08                	mov    %ecx,(%eax)
  8004c8:	8b 02                	mov    (%edx),%eax
  8004ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8004cf:	eb 0e                	jmp    8004df <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d1:	8b 10                	mov    (%eax),%edx
  8004d3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d6:	89 08                	mov    %ecx,(%eax)
  8004d8:	8b 02                	mov    (%edx),%eax
  8004da:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004df:	5d                   	pop    %ebp
  8004e0:	c3                   	ret    

008004e1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e1:	55                   	push   %ebp
  8004e2:	89 e5                	mov    %esp,%ebp
  8004e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004eb:	8b 10                	mov    (%eax),%edx
  8004ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f0:	73 0a                	jae    8004fc <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f5:	89 08                	mov    %ecx,(%eax)
  8004f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fa:	88 02                	mov    %al,(%edx)
}
  8004fc:	5d                   	pop    %ebp
  8004fd:	c3                   	ret    

008004fe <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004fe:	55                   	push   %ebp
  8004ff:	89 e5                	mov    %esp,%ebp
  800501:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800504:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800507:	50                   	push   %eax
  800508:	ff 75 10             	pushl  0x10(%ebp)
  80050b:	ff 75 0c             	pushl  0xc(%ebp)
  80050e:	ff 75 08             	pushl  0x8(%ebp)
  800511:	e8 05 00 00 00       	call   80051b <vprintfmt>
	va_end(ap);
}
  800516:	83 c4 10             	add    $0x10,%esp
  800519:	c9                   	leave  
  80051a:	c3                   	ret    

0080051b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80051b:	55                   	push   %ebp
  80051c:	89 e5                	mov    %esp,%ebp
  80051e:	57                   	push   %edi
  80051f:	56                   	push   %esi
  800520:	53                   	push   %ebx
  800521:	83 ec 2c             	sub    $0x2c,%esp
  800524:	8b 75 08             	mov    0x8(%ebp),%esi
  800527:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80052d:	eb 12                	jmp    800541 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80052f:	85 c0                	test   %eax,%eax
  800531:	0f 84 cb 03 00 00    	je     800902 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	53                   	push   %ebx
  80053b:	50                   	push   %eax
  80053c:	ff d6                	call   *%esi
  80053e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800541:	83 c7 01             	add    $0x1,%edi
  800544:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800548:	83 f8 25             	cmp    $0x25,%eax
  80054b:	75 e2                	jne    80052f <vprintfmt+0x14>
  80054d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800551:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800558:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80055f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800566:	ba 00 00 00 00       	mov    $0x0,%edx
  80056b:	eb 07                	jmp    800574 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800570:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800574:	8d 47 01             	lea    0x1(%edi),%eax
  800577:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057a:	0f b6 07             	movzbl (%edi),%eax
  80057d:	0f b6 c8             	movzbl %al,%ecx
  800580:	83 e8 23             	sub    $0x23,%eax
  800583:	3c 55                	cmp    $0x55,%al
  800585:	0f 87 5c 03 00 00    	ja     8008e7 <vprintfmt+0x3cc>
  80058b:	0f b6 c0             	movzbl %al,%eax
  80058e:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  800595:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800598:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80059c:	eb d6                	jmp    800574 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005ac:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005b0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005b3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005b6:	83 fa 09             	cmp    $0x9,%edx
  8005b9:	77 39                	ja     8005f4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005bb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005be:	eb e9                	jmp    8005a9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 48 04             	lea    0x4(%eax),%ecx
  8005c6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005c9:	8b 00                	mov    (%eax),%eax
  8005cb:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d1:	eb 27                	jmp    8005fa <vprintfmt+0xdf>
  8005d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d6:	85 c0                	test   %eax,%eax
  8005d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005dd:	0f 49 c8             	cmovns %eax,%ecx
  8005e0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e6:	eb 8c                	jmp    800574 <vprintfmt+0x59>
  8005e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005eb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005f2:	eb 80                	jmp    800574 <vprintfmt+0x59>
  8005f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f7:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8005fa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005fe:	0f 89 70 ff ff ff    	jns    800574 <vprintfmt+0x59>
				width = precision, precision = -1;
  800604:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800607:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060a:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800611:	e9 5e ff ff ff       	jmp    800574 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800616:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800619:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80061c:	e9 53 ff ff ff       	jmp    800574 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8d 50 04             	lea    0x4(%eax),%edx
  800627:	89 55 14             	mov    %edx,0x14(%ebp)
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	ff 30                	pushl  (%eax)
  800630:	ff d6                	call   *%esi
			break;
  800632:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800638:	e9 04 ff ff ff       	jmp    800541 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 50 04             	lea    0x4(%eax),%edx
  800643:	89 55 14             	mov    %edx,0x14(%ebp)
  800646:	8b 00                	mov    (%eax),%eax
  800648:	99                   	cltd   
  800649:	31 d0                	xor    %edx,%eax
  80064b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80064d:	83 f8 09             	cmp    $0x9,%eax
  800650:	7f 0b                	jg     80065d <vprintfmt+0x142>
  800652:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  800659:	85 d2                	test   %edx,%edx
  80065b:	75 18                	jne    800675 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80065d:	50                   	push   %eax
  80065e:	68 14 10 80 00       	push   $0x801014
  800663:	53                   	push   %ebx
  800664:	56                   	push   %esi
  800665:	e8 94 fe ff ff       	call   8004fe <printfmt>
  80066a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800670:	e9 cc fe ff ff       	jmp    800541 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800675:	52                   	push   %edx
  800676:	68 1d 10 80 00       	push   $0x80101d
  80067b:	53                   	push   %ebx
  80067c:	56                   	push   %esi
  80067d:	e8 7c fe ff ff       	call   8004fe <printfmt>
  800682:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800685:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800688:	e9 b4 fe ff ff       	jmp    800541 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8d 50 04             	lea    0x4(%eax),%edx
  800693:	89 55 14             	mov    %edx,0x14(%ebp)
  800696:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800698:	85 ff                	test   %edi,%edi
  80069a:	b8 0d 10 80 00       	mov    $0x80100d,%eax
  80069f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a6:	0f 8e 94 00 00 00    	jle    800740 <vprintfmt+0x225>
  8006ac:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006b0:	0f 84 98 00 00 00    	je     80074e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	ff 75 c8             	pushl  -0x38(%ebp)
  8006bc:	57                   	push   %edi
  8006bd:	e8 c8 02 00 00       	call   80098a <strnlen>
  8006c2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006c5:	29 c1                	sub    %eax,%ecx
  8006c7:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006ca:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006cd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006d7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d9:	eb 0f                	jmp    8006ea <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006db:	83 ec 08             	sub    $0x8,%esp
  8006de:	53                   	push   %ebx
  8006df:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e4:	83 ef 01             	sub    $0x1,%edi
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	85 ff                	test   %edi,%edi
  8006ec:	7f ed                	jg     8006db <vprintfmt+0x1c0>
  8006ee:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f1:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006f4:	85 c9                	test   %ecx,%ecx
  8006f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fb:	0f 49 c1             	cmovns %ecx,%eax
  8006fe:	29 c1                	sub    %eax,%ecx
  800700:	89 75 08             	mov    %esi,0x8(%ebp)
  800703:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800706:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800709:	89 cb                	mov    %ecx,%ebx
  80070b:	eb 4d                	jmp    80075a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80070d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800711:	74 1b                	je     80072e <vprintfmt+0x213>
  800713:	0f be c0             	movsbl %al,%eax
  800716:	83 e8 20             	sub    $0x20,%eax
  800719:	83 f8 5e             	cmp    $0x5e,%eax
  80071c:	76 10                	jbe    80072e <vprintfmt+0x213>
					putch('?', putdat);
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	ff 75 0c             	pushl  0xc(%ebp)
  800724:	6a 3f                	push   $0x3f
  800726:	ff 55 08             	call   *0x8(%ebp)
  800729:	83 c4 10             	add    $0x10,%esp
  80072c:	eb 0d                	jmp    80073b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	ff 75 0c             	pushl  0xc(%ebp)
  800734:	52                   	push   %edx
  800735:	ff 55 08             	call   *0x8(%ebp)
  800738:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80073b:	83 eb 01             	sub    $0x1,%ebx
  80073e:	eb 1a                	jmp    80075a <vprintfmt+0x23f>
  800740:	89 75 08             	mov    %esi,0x8(%ebp)
  800743:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800746:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800749:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80074c:	eb 0c                	jmp    80075a <vprintfmt+0x23f>
  80074e:	89 75 08             	mov    %esi,0x8(%ebp)
  800751:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800754:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800757:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80075a:	83 c7 01             	add    $0x1,%edi
  80075d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800761:	0f be d0             	movsbl %al,%edx
  800764:	85 d2                	test   %edx,%edx
  800766:	74 23                	je     80078b <vprintfmt+0x270>
  800768:	85 f6                	test   %esi,%esi
  80076a:	78 a1                	js     80070d <vprintfmt+0x1f2>
  80076c:	83 ee 01             	sub    $0x1,%esi
  80076f:	79 9c                	jns    80070d <vprintfmt+0x1f2>
  800771:	89 df                	mov    %ebx,%edi
  800773:	8b 75 08             	mov    0x8(%ebp),%esi
  800776:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800779:	eb 18                	jmp    800793 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80077b:	83 ec 08             	sub    $0x8,%esp
  80077e:	53                   	push   %ebx
  80077f:	6a 20                	push   $0x20
  800781:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800783:	83 ef 01             	sub    $0x1,%edi
  800786:	83 c4 10             	add    $0x10,%esp
  800789:	eb 08                	jmp    800793 <vprintfmt+0x278>
  80078b:	89 df                	mov    %ebx,%edi
  80078d:	8b 75 08             	mov    0x8(%ebp),%esi
  800790:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800793:	85 ff                	test   %edi,%edi
  800795:	7f e4                	jg     80077b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800797:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079a:	e9 a2 fd ff ff       	jmp    800541 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80079f:	83 fa 01             	cmp    $0x1,%edx
  8007a2:	7e 16                	jle    8007ba <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	8d 50 08             	lea    0x8(%eax),%edx
  8007aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ad:	8b 50 04             	mov    0x4(%eax),%edx
  8007b0:	8b 00                	mov    (%eax),%eax
  8007b2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007b5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007b8:	eb 32                	jmp    8007ec <vprintfmt+0x2d1>
	else if (lflag)
  8007ba:	85 d2                	test   %edx,%edx
  8007bc:	74 18                	je     8007d6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007be:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c1:	8d 50 04             	lea    0x4(%eax),%edx
  8007c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c7:	8b 00                	mov    (%eax),%eax
  8007c9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007cc:	89 c1                	mov    %eax,%ecx
  8007ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007d4:	eb 16                	jmp    8007ec <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d9:	8d 50 04             	lea    0x4(%eax),%edx
  8007dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007df:	8b 00                	mov    (%eax),%eax
  8007e1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007e4:	89 c1                	mov    %eax,%ecx
  8007e6:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ec:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007ef:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f8:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007fd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800801:	0f 89 a8 00 00 00    	jns    8008af <vprintfmt+0x394>
				putch('-', putdat);
  800807:	83 ec 08             	sub    $0x8,%esp
  80080a:	53                   	push   %ebx
  80080b:	6a 2d                	push   $0x2d
  80080d:	ff d6                	call   *%esi
				num = -(long long) num;
  80080f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800812:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800815:	f7 d8                	neg    %eax
  800817:	83 d2 00             	adc    $0x0,%edx
  80081a:	f7 da                	neg    %edx
  80081c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80081f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800822:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800825:	b8 0a 00 00 00       	mov    $0xa,%eax
  80082a:	e9 80 00 00 00       	jmp    8008af <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80082f:	8d 45 14             	lea    0x14(%ebp),%eax
  800832:	e8 70 fc ff ff       	call   8004a7 <getuint>
  800837:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80083a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80083d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800842:	eb 6b                	jmp    8008af <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800844:	8d 45 14             	lea    0x14(%ebp),%eax
  800847:	e8 5b fc ff ff       	call   8004a7 <getuint>
  80084c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80084f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800852:	6a 04                	push   $0x4
  800854:	6a 03                	push   $0x3
  800856:	6a 01                	push   $0x1
  800858:	68 20 10 80 00       	push   $0x801020
  80085d:	e8 82 fb ff ff       	call   8003e4 <cprintf>
			goto number;
  800862:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  800865:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  80086a:	eb 43                	jmp    8008af <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  80086c:	83 ec 08             	sub    $0x8,%esp
  80086f:	53                   	push   %ebx
  800870:	6a 30                	push   $0x30
  800872:	ff d6                	call   *%esi
			putch('x', putdat);
  800874:	83 c4 08             	add    $0x8,%esp
  800877:	53                   	push   %ebx
  800878:	6a 78                	push   $0x78
  80087a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80087c:	8b 45 14             	mov    0x14(%ebp),%eax
  80087f:	8d 50 04             	lea    0x4(%eax),%edx
  800882:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800885:	8b 00                	mov    (%eax),%eax
  800887:	ba 00 00 00 00       	mov    $0x0,%edx
  80088c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80088f:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800892:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800895:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80089a:	eb 13                	jmp    8008af <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80089c:	8d 45 14             	lea    0x14(%ebp),%eax
  80089f:	e8 03 fc ff ff       	call   8004a7 <getuint>
  8008a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008aa:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008af:	83 ec 0c             	sub    $0xc,%esp
  8008b2:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8008b6:	52                   	push   %edx
  8008b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8008ba:	50                   	push   %eax
  8008bb:	ff 75 dc             	pushl  -0x24(%ebp)
  8008be:	ff 75 d8             	pushl  -0x28(%ebp)
  8008c1:	89 da                	mov    %ebx,%edx
  8008c3:	89 f0                	mov    %esi,%eax
  8008c5:	e8 2e fb ff ff       	call   8003f8 <printnum>

			break;
  8008ca:	83 c4 20             	add    $0x20,%esp
  8008cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008d0:	e9 6c fc ff ff       	jmp    800541 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008d5:	83 ec 08             	sub    $0x8,%esp
  8008d8:	53                   	push   %ebx
  8008d9:	51                   	push   %ecx
  8008da:	ff d6                	call   *%esi
			break;
  8008dc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008e2:	e9 5a fc ff ff       	jmp    800541 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008e7:	83 ec 08             	sub    $0x8,%esp
  8008ea:	53                   	push   %ebx
  8008eb:	6a 25                	push   $0x25
  8008ed:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ef:	83 c4 10             	add    $0x10,%esp
  8008f2:	eb 03                	jmp    8008f7 <vprintfmt+0x3dc>
  8008f4:	83 ef 01             	sub    $0x1,%edi
  8008f7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008fb:	75 f7                	jne    8008f4 <vprintfmt+0x3d9>
  8008fd:	e9 3f fc ff ff       	jmp    800541 <vprintfmt+0x26>
			break;
		}

	}

}
  800902:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800905:	5b                   	pop    %ebx
  800906:	5e                   	pop    %esi
  800907:	5f                   	pop    %edi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	83 ec 18             	sub    $0x18,%esp
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800916:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800919:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80091d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800920:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800927:	85 c0                	test   %eax,%eax
  800929:	74 26                	je     800951 <vsnprintf+0x47>
  80092b:	85 d2                	test   %edx,%edx
  80092d:	7e 22                	jle    800951 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80092f:	ff 75 14             	pushl  0x14(%ebp)
  800932:	ff 75 10             	pushl  0x10(%ebp)
  800935:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800938:	50                   	push   %eax
  800939:	68 e1 04 80 00       	push   $0x8004e1
  80093e:	e8 d8 fb ff ff       	call   80051b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800943:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800946:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800949:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094c:	83 c4 10             	add    $0x10,%esp
  80094f:	eb 05                	jmp    800956 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800951:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800956:	c9                   	leave  
  800957:	c3                   	ret    

00800958 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80095e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800961:	50                   	push   %eax
  800962:	ff 75 10             	pushl  0x10(%ebp)
  800965:	ff 75 0c             	pushl  0xc(%ebp)
  800968:	ff 75 08             	pushl  0x8(%ebp)
  80096b:	e8 9a ff ff ff       	call   80090a <vsnprintf>
	va_end(ap);

	return rc;
}
  800970:	c9                   	leave  
  800971:	c3                   	ret    

00800972 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800978:	b8 00 00 00 00       	mov    $0x0,%eax
  80097d:	eb 03                	jmp    800982 <strlen+0x10>
		n++;
  80097f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800982:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800986:	75 f7                	jne    80097f <strlen+0xd>
		n++;
	return n;
}
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800990:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800993:	ba 00 00 00 00       	mov    $0x0,%edx
  800998:	eb 03                	jmp    80099d <strnlen+0x13>
		n++;
  80099a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099d:	39 c2                	cmp    %eax,%edx
  80099f:	74 08                	je     8009a9 <strnlen+0x1f>
  8009a1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009a5:	75 f3                	jne    80099a <strnlen+0x10>
  8009a7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	53                   	push   %ebx
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009b5:	89 c2                	mov    %eax,%edx
  8009b7:	83 c2 01             	add    $0x1,%edx
  8009ba:	83 c1 01             	add    $0x1,%ecx
  8009bd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009c1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009c4:	84 db                	test   %bl,%bl
  8009c6:	75 ef                	jne    8009b7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009c8:	5b                   	pop    %ebx
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009d2:	53                   	push   %ebx
  8009d3:	e8 9a ff ff ff       	call   800972 <strlen>
  8009d8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009db:	ff 75 0c             	pushl  0xc(%ebp)
  8009de:	01 d8                	add    %ebx,%eax
  8009e0:	50                   	push   %eax
  8009e1:	e8 c5 ff ff ff       	call   8009ab <strcpy>
	return dst;
}
  8009e6:	89 d8                	mov    %ebx,%eax
  8009e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    

008009ed <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	56                   	push   %esi
  8009f1:	53                   	push   %ebx
  8009f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f8:	89 f3                	mov    %esi,%ebx
  8009fa:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009fd:	89 f2                	mov    %esi,%edx
  8009ff:	eb 0f                	jmp    800a10 <strncpy+0x23>
		*dst++ = *src;
  800a01:	83 c2 01             	add    $0x1,%edx
  800a04:	0f b6 01             	movzbl (%ecx),%eax
  800a07:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a0a:	80 39 01             	cmpb   $0x1,(%ecx)
  800a0d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a10:	39 da                	cmp    %ebx,%edx
  800a12:	75 ed                	jne    800a01 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a14:	89 f0                	mov    %esi,%eax
  800a16:	5b                   	pop    %ebx
  800a17:	5e                   	pop    %esi
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	56                   	push   %esi
  800a1e:	53                   	push   %ebx
  800a1f:	8b 75 08             	mov    0x8(%ebp),%esi
  800a22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a25:	8b 55 10             	mov    0x10(%ebp),%edx
  800a28:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a2a:	85 d2                	test   %edx,%edx
  800a2c:	74 21                	je     800a4f <strlcpy+0x35>
  800a2e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a32:	89 f2                	mov    %esi,%edx
  800a34:	eb 09                	jmp    800a3f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a36:	83 c2 01             	add    $0x1,%edx
  800a39:	83 c1 01             	add    $0x1,%ecx
  800a3c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a3f:	39 c2                	cmp    %eax,%edx
  800a41:	74 09                	je     800a4c <strlcpy+0x32>
  800a43:	0f b6 19             	movzbl (%ecx),%ebx
  800a46:	84 db                	test   %bl,%bl
  800a48:	75 ec                	jne    800a36 <strlcpy+0x1c>
  800a4a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a4c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a4f:	29 f0                	sub    %esi,%eax
}
  800a51:	5b                   	pop    %ebx
  800a52:	5e                   	pop    %esi
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a5e:	eb 06                	jmp    800a66 <strcmp+0x11>
		p++, q++;
  800a60:	83 c1 01             	add    $0x1,%ecx
  800a63:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a66:	0f b6 01             	movzbl (%ecx),%eax
  800a69:	84 c0                	test   %al,%al
  800a6b:	74 04                	je     800a71 <strcmp+0x1c>
  800a6d:	3a 02                	cmp    (%edx),%al
  800a6f:	74 ef                	je     800a60 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a71:	0f b6 c0             	movzbl %al,%eax
  800a74:	0f b6 12             	movzbl (%edx),%edx
  800a77:	29 d0                	sub    %edx,%eax
}
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	53                   	push   %ebx
  800a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a82:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a85:	89 c3                	mov    %eax,%ebx
  800a87:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a8a:	eb 06                	jmp    800a92 <strncmp+0x17>
		n--, p++, q++;
  800a8c:	83 c0 01             	add    $0x1,%eax
  800a8f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a92:	39 d8                	cmp    %ebx,%eax
  800a94:	74 15                	je     800aab <strncmp+0x30>
  800a96:	0f b6 08             	movzbl (%eax),%ecx
  800a99:	84 c9                	test   %cl,%cl
  800a9b:	74 04                	je     800aa1 <strncmp+0x26>
  800a9d:	3a 0a                	cmp    (%edx),%cl
  800a9f:	74 eb                	je     800a8c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa1:	0f b6 00             	movzbl (%eax),%eax
  800aa4:	0f b6 12             	movzbl (%edx),%edx
  800aa7:	29 d0                	sub    %edx,%eax
  800aa9:	eb 05                	jmp    800ab0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aab:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ab0:	5b                   	pop    %ebx
  800ab1:	5d                   	pop    %ebp
  800ab2:	c3                   	ret    

00800ab3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800abd:	eb 07                	jmp    800ac6 <strchr+0x13>
		if (*s == c)
  800abf:	38 ca                	cmp    %cl,%dl
  800ac1:	74 0f                	je     800ad2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ac3:	83 c0 01             	add    $0x1,%eax
  800ac6:	0f b6 10             	movzbl (%eax),%edx
  800ac9:	84 d2                	test   %dl,%dl
  800acb:	75 f2                	jne    800abf <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  800ada:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ade:	eb 03                	jmp    800ae3 <strfind+0xf>
  800ae0:	83 c0 01             	add    $0x1,%eax
  800ae3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ae6:	38 ca                	cmp    %cl,%dl
  800ae8:	74 04                	je     800aee <strfind+0x1a>
  800aea:	84 d2                	test   %dl,%dl
  800aec:	75 f2                	jne    800ae0 <strfind+0xc>
			break;
	return (char *) s;
}
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	57                   	push   %edi
  800af4:	56                   	push   %esi
  800af5:	53                   	push   %ebx
  800af6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800afc:	85 c9                	test   %ecx,%ecx
  800afe:	74 36                	je     800b36 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b00:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b06:	75 28                	jne    800b30 <memset+0x40>
  800b08:	f6 c1 03             	test   $0x3,%cl
  800b0b:	75 23                	jne    800b30 <memset+0x40>
		c &= 0xFF;
  800b0d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b11:	89 d3                	mov    %edx,%ebx
  800b13:	c1 e3 08             	shl    $0x8,%ebx
  800b16:	89 d6                	mov    %edx,%esi
  800b18:	c1 e6 18             	shl    $0x18,%esi
  800b1b:	89 d0                	mov    %edx,%eax
  800b1d:	c1 e0 10             	shl    $0x10,%eax
  800b20:	09 f0                	or     %esi,%eax
  800b22:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b24:	89 d8                	mov    %ebx,%eax
  800b26:	09 d0                	or     %edx,%eax
  800b28:	c1 e9 02             	shr    $0x2,%ecx
  800b2b:	fc                   	cld    
  800b2c:	f3 ab                	rep stos %eax,%es:(%edi)
  800b2e:	eb 06                	jmp    800b36 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b33:	fc                   	cld    
  800b34:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b36:	89 f8                	mov    %edi,%eax
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	8b 45 08             	mov    0x8(%ebp),%eax
  800b45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b48:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b4b:	39 c6                	cmp    %eax,%esi
  800b4d:	73 35                	jae    800b84 <memmove+0x47>
  800b4f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b52:	39 d0                	cmp    %edx,%eax
  800b54:	73 2e                	jae    800b84 <memmove+0x47>
		s += n;
		d += n;
  800b56:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b59:	89 d6                	mov    %edx,%esi
  800b5b:	09 fe                	or     %edi,%esi
  800b5d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b63:	75 13                	jne    800b78 <memmove+0x3b>
  800b65:	f6 c1 03             	test   $0x3,%cl
  800b68:	75 0e                	jne    800b78 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b6a:	83 ef 04             	sub    $0x4,%edi
  800b6d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b70:	c1 e9 02             	shr    $0x2,%ecx
  800b73:	fd                   	std    
  800b74:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b76:	eb 09                	jmp    800b81 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b78:	83 ef 01             	sub    $0x1,%edi
  800b7b:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b7e:	fd                   	std    
  800b7f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b81:	fc                   	cld    
  800b82:	eb 1d                	jmp    800ba1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b84:	89 f2                	mov    %esi,%edx
  800b86:	09 c2                	or     %eax,%edx
  800b88:	f6 c2 03             	test   $0x3,%dl
  800b8b:	75 0f                	jne    800b9c <memmove+0x5f>
  800b8d:	f6 c1 03             	test   $0x3,%cl
  800b90:	75 0a                	jne    800b9c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b92:	c1 e9 02             	shr    $0x2,%ecx
  800b95:	89 c7                	mov    %eax,%edi
  800b97:	fc                   	cld    
  800b98:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9a:	eb 05                	jmp    800ba1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b9c:	89 c7                	mov    %eax,%edi
  800b9e:	fc                   	cld    
  800b9f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ba8:	ff 75 10             	pushl  0x10(%ebp)
  800bab:	ff 75 0c             	pushl  0xc(%ebp)
  800bae:	ff 75 08             	pushl  0x8(%ebp)
  800bb1:	e8 87 ff ff ff       	call   800b3d <memmove>
}
  800bb6:	c9                   	leave  
  800bb7:	c3                   	ret    

00800bb8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
  800bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc3:	89 c6                	mov    %eax,%esi
  800bc5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc8:	eb 1a                	jmp    800be4 <memcmp+0x2c>
		if (*s1 != *s2)
  800bca:	0f b6 08             	movzbl (%eax),%ecx
  800bcd:	0f b6 1a             	movzbl (%edx),%ebx
  800bd0:	38 d9                	cmp    %bl,%cl
  800bd2:	74 0a                	je     800bde <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bd4:	0f b6 c1             	movzbl %cl,%eax
  800bd7:	0f b6 db             	movzbl %bl,%ebx
  800bda:	29 d8                	sub    %ebx,%eax
  800bdc:	eb 0f                	jmp    800bed <memcmp+0x35>
		s1++, s2++;
  800bde:	83 c0 01             	add    $0x1,%eax
  800be1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be4:	39 f0                	cmp    %esi,%eax
  800be6:	75 e2                	jne    800bca <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800be8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	53                   	push   %ebx
  800bf5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bf8:	89 c1                	mov    %eax,%ecx
  800bfa:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bfd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c01:	eb 0a                	jmp    800c0d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c03:	0f b6 10             	movzbl (%eax),%edx
  800c06:	39 da                	cmp    %ebx,%edx
  800c08:	74 07                	je     800c11 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c0a:	83 c0 01             	add    $0x1,%eax
  800c0d:	39 c8                	cmp    %ecx,%eax
  800c0f:	72 f2                	jb     800c03 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c11:	5b                   	pop    %ebx
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c20:	eb 03                	jmp    800c25 <strtol+0x11>
		s++;
  800c22:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c25:	0f b6 01             	movzbl (%ecx),%eax
  800c28:	3c 20                	cmp    $0x20,%al
  800c2a:	74 f6                	je     800c22 <strtol+0xe>
  800c2c:	3c 09                	cmp    $0x9,%al
  800c2e:	74 f2                	je     800c22 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c30:	3c 2b                	cmp    $0x2b,%al
  800c32:	75 0a                	jne    800c3e <strtol+0x2a>
		s++;
  800c34:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c37:	bf 00 00 00 00       	mov    $0x0,%edi
  800c3c:	eb 11                	jmp    800c4f <strtol+0x3b>
  800c3e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c43:	3c 2d                	cmp    $0x2d,%al
  800c45:	75 08                	jne    800c4f <strtol+0x3b>
		s++, neg = 1;
  800c47:	83 c1 01             	add    $0x1,%ecx
  800c4a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c4f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c55:	75 15                	jne    800c6c <strtol+0x58>
  800c57:	80 39 30             	cmpb   $0x30,(%ecx)
  800c5a:	75 10                	jne    800c6c <strtol+0x58>
  800c5c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c60:	75 7c                	jne    800cde <strtol+0xca>
		s += 2, base = 16;
  800c62:	83 c1 02             	add    $0x2,%ecx
  800c65:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c6a:	eb 16                	jmp    800c82 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c6c:	85 db                	test   %ebx,%ebx
  800c6e:	75 12                	jne    800c82 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c70:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c75:	80 39 30             	cmpb   $0x30,(%ecx)
  800c78:	75 08                	jne    800c82 <strtol+0x6e>
		s++, base = 8;
  800c7a:	83 c1 01             	add    $0x1,%ecx
  800c7d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c82:	b8 00 00 00 00       	mov    $0x0,%eax
  800c87:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c8a:	0f b6 11             	movzbl (%ecx),%edx
  800c8d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c90:	89 f3                	mov    %esi,%ebx
  800c92:	80 fb 09             	cmp    $0x9,%bl
  800c95:	77 08                	ja     800c9f <strtol+0x8b>
			dig = *s - '0';
  800c97:	0f be d2             	movsbl %dl,%edx
  800c9a:	83 ea 30             	sub    $0x30,%edx
  800c9d:	eb 22                	jmp    800cc1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c9f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ca2:	89 f3                	mov    %esi,%ebx
  800ca4:	80 fb 19             	cmp    $0x19,%bl
  800ca7:	77 08                	ja     800cb1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ca9:	0f be d2             	movsbl %dl,%edx
  800cac:	83 ea 57             	sub    $0x57,%edx
  800caf:	eb 10                	jmp    800cc1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cb1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cb4:	89 f3                	mov    %esi,%ebx
  800cb6:	80 fb 19             	cmp    $0x19,%bl
  800cb9:	77 16                	ja     800cd1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cbb:	0f be d2             	movsbl %dl,%edx
  800cbe:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cc1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cc4:	7d 0b                	jge    800cd1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cc6:	83 c1 01             	add    $0x1,%ecx
  800cc9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ccd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ccf:	eb b9                	jmp    800c8a <strtol+0x76>

	if (endptr)
  800cd1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd5:	74 0d                	je     800ce4 <strtol+0xd0>
		*endptr = (char *) s;
  800cd7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cda:	89 0e                	mov    %ecx,(%esi)
  800cdc:	eb 06                	jmp    800ce4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cde:	85 db                	test   %ebx,%ebx
  800ce0:	74 98                	je     800c7a <strtol+0x66>
  800ce2:	eb 9e                	jmp    800c82 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ce4:	89 c2                	mov    %eax,%edx
  800ce6:	f7 da                	neg    %edx
  800ce8:	85 ff                	test   %edi,%edi
  800cea:	0f 45 c2             	cmovne %edx,%eax
}
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    
  800cf2:	66 90                	xchg   %ax,%ax
  800cf4:	66 90                	xchg   %ax,%ax
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
