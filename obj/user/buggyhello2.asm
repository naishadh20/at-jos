
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 67 00 00 00       	call   8000b0 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const char *binaryname = "<unknown>";


void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi

	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800059:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800060:	00 00 00 
	thisenv = envs+ENVX(sys_getenvid());
  800063:	e8 c6 00 00 00       	call   80012e <sys_getenvid>
  800068:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800070:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800075:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 db                	test   %ebx,%ebx
  80007c:	7e 07                	jle    800085 <libmain+0x37>
		binaryname = argv[0];
  80007e:	8b 06                	mov    (%esi),%eax
  800080:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  800085:	83 ec 08             	sub    $0x8,%esp
  800088:	56                   	push   %esi
  800089:	53                   	push   %ebx
  80008a:	e8 a4 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008f:	e8 0a 00 00 00       	call   80009e <exit>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009a:	5b                   	pop    %ebx
  80009b:	5e                   	pop    %esi
  80009c:	5d                   	pop    %ebp
  80009d:	c3                   	ret    

0080009e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a4:	6a 00                	push   $0x0
  8000a6:	e8 42 00 00 00       	call   8000ed <sys_env_destroy>
}
  8000ab:	83 c4 10             	add    $0x10,%esp
  8000ae:	c9                   	leave  
  8000af:	c3                   	ret    

008000b0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000be:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c1:	89 c3                	mov    %eax,%ebx
  8000c3:	89 c7                	mov    %eax,%edi
  8000c5:	89 c6                	mov    %eax,%esi
  8000c7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000de:	89 d1                	mov    %edx,%ecx
  8000e0:	89 d3                	mov    %edx,%ebx
  8000e2:	89 d7                	mov    %edx,%edi
  8000e4:	89 d6                	mov    %edx,%esi
  8000e6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e8:	5b                   	pop    %ebx
  8000e9:	5e                   	pop    %esi
  8000ea:	5f                   	pop    %edi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fb:	b8 03 00 00 00       	mov    $0x3,%eax
  800100:	8b 55 08             	mov    0x8(%ebp),%edx
  800103:	89 cb                	mov    %ecx,%ebx
  800105:	89 cf                	mov    %ecx,%edi
  800107:	89 ce                	mov    %ecx,%esi
  800109:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010b:	85 c0                	test   %eax,%eax
  80010d:	7e 17                	jle    800126 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	50                   	push   %eax
  800113:	6a 03                	push   $0x3
  800115:	68 b8 0f 80 00       	push   $0x800fb8
  80011a:	6a 23                	push   $0x23
  80011c:	68 d5 0f 80 00       	push   $0x800fd5
  800121:	e8 f5 01 00 00       	call   80031b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800126:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5f                   	pop    %edi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    

0080012e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	57                   	push   %edi
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	b8 02 00 00 00       	mov    $0x2,%eax
  80013e:	89 d1                	mov    %edx,%ecx
  800140:	89 d3                	mov    %edx,%ebx
  800142:	89 d7                	mov    %edx,%edi
  800144:	89 d6                	mov    %edx,%esi
  800146:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5f                   	pop    %edi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    

0080014d <sys_yield>:

void
sys_yield(void)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800153:	ba 00 00 00 00       	mov    $0x0,%edx
  800158:	b8 0a 00 00 00       	mov    $0xa,%eax
  80015d:	89 d1                	mov    %edx,%ecx
  80015f:	89 d3                	mov    %edx,%ebx
  800161:	89 d7                	mov    %edx,%edi
  800163:	89 d6                	mov    %edx,%esi
  800165:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800167:	5b                   	pop    %ebx
  800168:	5e                   	pop    %esi
  800169:	5f                   	pop    %edi
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	57                   	push   %edi
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
  800172:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800175:	be 00 00 00 00       	mov    $0x0,%esi
  80017a:	b8 04 00 00 00       	mov    $0x4,%eax
  80017f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800182:	8b 55 08             	mov    0x8(%ebp),%edx
  800185:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800188:	89 f7                	mov    %esi,%edi
  80018a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80018c:	85 c0                	test   %eax,%eax
  80018e:	7e 17                	jle    8001a7 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	50                   	push   %eax
  800194:	6a 04                	push   $0x4
  800196:	68 b8 0f 80 00       	push   $0x800fb8
  80019b:	6a 23                	push   $0x23
  80019d:	68 d5 0f 80 00       	push   $0x800fd5
  8001a2:	e8 74 01 00 00       	call   80031b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001aa:	5b                   	pop    %ebx
  8001ab:	5e                   	pop    %esi
  8001ac:	5f                   	pop    %edi
  8001ad:	5d                   	pop    %ebp
  8001ae:	c3                   	ret    

008001af <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	57                   	push   %edi
  8001b3:	56                   	push   %esi
  8001b4:	53                   	push   %ebx
  8001b5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b8:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c9:	8b 75 18             	mov    0x18(%ebp),%esi
  8001cc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	7e 17                	jle    8001e9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d2:	83 ec 0c             	sub    $0xc,%esp
  8001d5:	50                   	push   %eax
  8001d6:	6a 05                	push   $0x5
  8001d8:	68 b8 0f 80 00       	push   $0x800fb8
  8001dd:	6a 23                	push   $0x23
  8001df:	68 d5 0f 80 00       	push   $0x800fd5
  8001e4:	e8 32 01 00 00       	call   80031b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ec:	5b                   	pop    %ebx
  8001ed:	5e                   	pop    %esi
  8001ee:	5f                   	pop    %edi
  8001ef:	5d                   	pop    %ebp
  8001f0:	c3                   	ret    

008001f1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	57                   	push   %edi
  8001f5:	56                   	push   %esi
  8001f6:	53                   	push   %ebx
  8001f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ff:	b8 06 00 00 00       	mov    $0x6,%eax
  800204:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800207:	8b 55 08             	mov    0x8(%ebp),%edx
  80020a:	89 df                	mov    %ebx,%edi
  80020c:	89 de                	mov    %ebx,%esi
  80020e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800210:	85 c0                	test   %eax,%eax
  800212:	7e 17                	jle    80022b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800214:	83 ec 0c             	sub    $0xc,%esp
  800217:	50                   	push   %eax
  800218:	6a 06                	push   $0x6
  80021a:	68 b8 0f 80 00       	push   $0x800fb8
  80021f:	6a 23                	push   $0x23
  800221:	68 d5 0f 80 00       	push   $0x800fd5
  800226:	e8 f0 00 00 00       	call   80031b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022e:	5b                   	pop    %ebx
  80022f:	5e                   	pop    %esi
  800230:	5f                   	pop    %edi
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    

00800233 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	57                   	push   %edi
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800241:	b8 08 00 00 00       	mov    $0x8,%eax
  800246:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800249:	8b 55 08             	mov    0x8(%ebp),%edx
  80024c:	89 df                	mov    %ebx,%edi
  80024e:	89 de                	mov    %ebx,%esi
  800250:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800252:	85 c0                	test   %eax,%eax
  800254:	7e 17                	jle    80026d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800256:	83 ec 0c             	sub    $0xc,%esp
  800259:	50                   	push   %eax
  80025a:	6a 08                	push   $0x8
  80025c:	68 b8 0f 80 00       	push   $0x800fb8
  800261:	6a 23                	push   $0x23
  800263:	68 d5 0f 80 00       	push   $0x800fd5
  800268:	e8 ae 00 00 00       	call   80031b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800270:	5b                   	pop    %ebx
  800271:	5e                   	pop    %esi
  800272:	5f                   	pop    %edi
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    

00800275 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	57                   	push   %edi
  800279:	56                   	push   %esi
  80027a:	53                   	push   %ebx
  80027b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800283:	b8 09 00 00 00       	mov    $0x9,%eax
  800288:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028b:	8b 55 08             	mov    0x8(%ebp),%edx
  80028e:	89 df                	mov    %ebx,%edi
  800290:	89 de                	mov    %ebx,%esi
  800292:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800294:	85 c0                	test   %eax,%eax
  800296:	7e 17                	jle    8002af <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800298:	83 ec 0c             	sub    $0xc,%esp
  80029b:	50                   	push   %eax
  80029c:	6a 09                	push   $0x9
  80029e:	68 b8 0f 80 00       	push   $0x800fb8
  8002a3:	6a 23                	push   $0x23
  8002a5:	68 d5 0f 80 00       	push   $0x800fd5
  8002aa:	e8 6c 00 00 00       	call   80031b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b2:	5b                   	pop    %ebx
  8002b3:	5e                   	pop    %esi
  8002b4:	5f                   	pop    %edi
  8002b5:	5d                   	pop    %ebp
  8002b6:	c3                   	ret    

008002b7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	57                   	push   %edi
  8002bb:	56                   	push   %esi
  8002bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002bd:	be 00 00 00 00       	mov    $0x0,%esi
  8002c2:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002d0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002d3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5f                   	pop    %edi
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	57                   	push   %edi
  8002de:	56                   	push   %esi
  8002df:	53                   	push   %ebx
  8002e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e8:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f0:	89 cb                	mov    %ecx,%ebx
  8002f2:	89 cf                	mov    %ecx,%edi
  8002f4:	89 ce                	mov    %ecx,%esi
  8002f6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f8:	85 c0                	test   %eax,%eax
  8002fa:	7e 17                	jle    800313 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002fc:	83 ec 0c             	sub    $0xc,%esp
  8002ff:	50                   	push   %eax
  800300:	6a 0c                	push   $0xc
  800302:	68 b8 0f 80 00       	push   $0x800fb8
  800307:	6a 23                	push   $0x23
  800309:	68 d5 0f 80 00       	push   $0x800fd5
  80030e:	e8 08 00 00 00       	call   80031b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800313:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800316:	5b                   	pop    %ebx
  800317:	5e                   	pop    %esi
  800318:	5f                   	pop    %edi
  800319:	5d                   	pop    %ebp
  80031a:	c3                   	ret    

0080031b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800320:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800323:	8b 35 04 20 80 00    	mov    0x802004,%esi
  800329:	e8 00 fe ff ff       	call   80012e <sys_getenvid>
  80032e:	83 ec 0c             	sub    $0xc,%esp
  800331:	ff 75 0c             	pushl  0xc(%ebp)
  800334:	ff 75 08             	pushl  0x8(%ebp)
  800337:	56                   	push   %esi
  800338:	50                   	push   %eax
  800339:	68 e4 0f 80 00       	push   $0x800fe4
  80033e:	e8 b1 00 00 00       	call   8003f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800343:	83 c4 18             	add    $0x18,%esp
  800346:	53                   	push   %ebx
  800347:	ff 75 10             	pushl  0x10(%ebp)
  80034a:	e8 54 00 00 00       	call   8003a3 <vcprintf>
	cprintf("\n");
  80034f:	c7 04 24 3c 10 80 00 	movl   $0x80103c,(%esp)
  800356:	e8 99 00 00 00       	call   8003f4 <cprintf>
  80035b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80035e:	cc                   	int3   
  80035f:	eb fd                	jmp    80035e <_panic+0x43>

00800361 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	53                   	push   %ebx
  800365:	83 ec 04             	sub    $0x4,%esp
  800368:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80036b:	8b 13                	mov    (%ebx),%edx
  80036d:	8d 42 01             	lea    0x1(%edx),%eax
  800370:	89 03                	mov    %eax,(%ebx)
  800372:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800375:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800379:	3d ff 00 00 00       	cmp    $0xff,%eax
  80037e:	75 1a                	jne    80039a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800380:	83 ec 08             	sub    $0x8,%esp
  800383:	68 ff 00 00 00       	push   $0xff
  800388:	8d 43 08             	lea    0x8(%ebx),%eax
  80038b:	50                   	push   %eax
  80038c:	e8 1f fd ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  800391:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800397:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80039a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80039e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a1:	c9                   	leave  
  8003a2:	c3                   	ret    

008003a3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003b3:	00 00 00 
	b.cnt = 0;
  8003b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c0:	ff 75 0c             	pushl  0xc(%ebp)
  8003c3:	ff 75 08             	pushl  0x8(%ebp)
  8003c6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003cc:	50                   	push   %eax
  8003cd:	68 61 03 80 00       	push   $0x800361
  8003d2:	e8 54 01 00 00       	call   80052b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003d7:	83 c4 08             	add    $0x8,%esp
  8003da:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003e6:	50                   	push   %eax
  8003e7:	e8 c4 fc ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
}
  8003ec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003f2:	c9                   	leave  
  8003f3:	c3                   	ret    

008003f4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003fa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003fd:	50                   	push   %eax
  8003fe:	ff 75 08             	pushl  0x8(%ebp)
  800401:	e8 9d ff ff ff       	call   8003a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800406:	c9                   	leave  
  800407:	c3                   	ret    

00800408 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
  80040b:	57                   	push   %edi
  80040c:	56                   	push   %esi
  80040d:	53                   	push   %ebx
  80040e:	83 ec 1c             	sub    $0x1c,%esp
  800411:	89 c7                	mov    %eax,%edi
  800413:	89 d6                	mov    %edx,%esi
  800415:	8b 45 08             	mov    0x8(%ebp),%eax
  800418:	8b 55 0c             	mov    0xc(%ebp),%edx
  80041b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800421:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800424:	bb 00 00 00 00       	mov    $0x0,%ebx
  800429:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80042c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80042f:	39 d3                	cmp    %edx,%ebx
  800431:	72 05                	jb     800438 <printnum+0x30>
  800433:	39 45 10             	cmp    %eax,0x10(%ebp)
  800436:	77 45                	ja     80047d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800438:	83 ec 0c             	sub    $0xc,%esp
  80043b:	ff 75 18             	pushl  0x18(%ebp)
  80043e:	8b 45 14             	mov    0x14(%ebp),%eax
  800441:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800444:	53                   	push   %ebx
  800445:	ff 75 10             	pushl  0x10(%ebp)
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80044e:	ff 75 e0             	pushl  -0x20(%ebp)
  800451:	ff 75 dc             	pushl  -0x24(%ebp)
  800454:	ff 75 d8             	pushl  -0x28(%ebp)
  800457:	e8 b4 08 00 00       	call   800d10 <__udivdi3>
  80045c:	83 c4 18             	add    $0x18,%esp
  80045f:	52                   	push   %edx
  800460:	50                   	push   %eax
  800461:	89 f2                	mov    %esi,%edx
  800463:	89 f8                	mov    %edi,%eax
  800465:	e8 9e ff ff ff       	call   800408 <printnum>
  80046a:	83 c4 20             	add    $0x20,%esp
  80046d:	eb 18                	jmp    800487 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80046f:	83 ec 08             	sub    $0x8,%esp
  800472:	56                   	push   %esi
  800473:	ff 75 18             	pushl  0x18(%ebp)
  800476:	ff d7                	call   *%edi
  800478:	83 c4 10             	add    $0x10,%esp
  80047b:	eb 03                	jmp    800480 <printnum+0x78>
  80047d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800480:	83 eb 01             	sub    $0x1,%ebx
  800483:	85 db                	test   %ebx,%ebx
  800485:	7f e8                	jg     80046f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	56                   	push   %esi
  80048b:	83 ec 04             	sub    $0x4,%esp
  80048e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800491:	ff 75 e0             	pushl  -0x20(%ebp)
  800494:	ff 75 dc             	pushl  -0x24(%ebp)
  800497:	ff 75 d8             	pushl  -0x28(%ebp)
  80049a:	e8 a1 09 00 00       	call   800e40 <__umoddi3>
  80049f:	83 c4 14             	add    $0x14,%esp
  8004a2:	0f be 80 08 10 80 00 	movsbl 0x801008(%eax),%eax
  8004a9:	50                   	push   %eax
  8004aa:	ff d7                	call   *%edi
}
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b2:	5b                   	pop    %ebx
  8004b3:	5e                   	pop    %esi
  8004b4:	5f                   	pop    %edi
  8004b5:	5d                   	pop    %ebp
  8004b6:	c3                   	ret    

008004b7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004b7:	55                   	push   %ebp
  8004b8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004ba:	83 fa 01             	cmp    $0x1,%edx
  8004bd:	7e 0e                	jle    8004cd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004bf:	8b 10                	mov    (%eax),%edx
  8004c1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004c4:	89 08                	mov    %ecx,(%eax)
  8004c6:	8b 02                	mov    (%edx),%eax
  8004c8:	8b 52 04             	mov    0x4(%edx),%edx
  8004cb:	eb 22                	jmp    8004ef <getuint+0x38>
	else if (lflag)
  8004cd:	85 d2                	test   %edx,%edx
  8004cf:	74 10                	je     8004e1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004d1:	8b 10                	mov    (%eax),%edx
  8004d3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d6:	89 08                	mov    %ecx,(%eax)
  8004d8:	8b 02                	mov    (%edx),%eax
  8004da:	ba 00 00 00 00       	mov    $0x0,%edx
  8004df:	eb 0e                	jmp    8004ef <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004e1:	8b 10                	mov    (%eax),%edx
  8004e3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e6:	89 08                	mov    %ecx,(%eax)
  8004e8:	8b 02                	mov    (%edx),%eax
  8004ea:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004ef:	5d                   	pop    %ebp
  8004f0:	c3                   	ret    

008004f1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004fb:	8b 10                	mov    (%eax),%edx
  8004fd:	3b 50 04             	cmp    0x4(%eax),%edx
  800500:	73 0a                	jae    80050c <sprintputch+0x1b>
		*b->buf++ = ch;
  800502:	8d 4a 01             	lea    0x1(%edx),%ecx
  800505:	89 08                	mov    %ecx,(%eax)
  800507:	8b 45 08             	mov    0x8(%ebp),%eax
  80050a:	88 02                	mov    %al,(%edx)
}
  80050c:	5d                   	pop    %ebp
  80050d:	c3                   	ret    

0080050e <printfmt>:

}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80050e:	55                   	push   %ebp
  80050f:	89 e5                	mov    %esp,%ebp
  800511:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800514:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800517:	50                   	push   %eax
  800518:	ff 75 10             	pushl  0x10(%ebp)
  80051b:	ff 75 0c             	pushl  0xc(%ebp)
  80051e:	ff 75 08             	pushl  0x8(%ebp)
  800521:	e8 05 00 00 00       	call   80052b <vprintfmt>
	va_end(ap);
}
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	c9                   	leave  
  80052a:	c3                   	ret    

0080052b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80052b:	55                   	push   %ebp
  80052c:	89 e5                	mov    %esp,%ebp
  80052e:	57                   	push   %edi
  80052f:	56                   	push   %esi
  800530:	53                   	push   %ebx
  800531:	83 ec 2c             	sub    $0x2c,%esp
  800534:	8b 75 08             	mov    0x8(%ebp),%esi
  800537:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80053d:	eb 12                	jmp    800551 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80053f:	85 c0                	test   %eax,%eax
  800541:	0f 84 cb 03 00 00    	je     800912 <vprintfmt+0x3e7>
				return;
			putch(ch, putdat);
  800547:	83 ec 08             	sub    $0x8,%esp
  80054a:	53                   	push   %ebx
  80054b:	50                   	push   %eax
  80054c:	ff d6                	call   *%esi
  80054e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800551:	83 c7 01             	add    $0x1,%edi
  800554:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800558:	83 f8 25             	cmp    $0x25,%eax
  80055b:	75 e2                	jne    80053f <vprintfmt+0x14>
  80055d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800561:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800568:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80056f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800576:	ba 00 00 00 00       	mov    $0x0,%edx
  80057b:	eb 07                	jmp    800584 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800580:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8d 47 01             	lea    0x1(%edi),%eax
  800587:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058a:	0f b6 07             	movzbl (%edi),%eax
  80058d:	0f b6 c8             	movzbl %al,%ecx
  800590:	83 e8 23             	sub    $0x23,%eax
  800593:	3c 55                	cmp    $0x55,%al
  800595:	0f 87 5c 03 00 00    	ja     8008f7 <vprintfmt+0x3cc>
  80059b:	0f b6 c0             	movzbl %al,%eax
  80059e:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  8005a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005a8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005ac:	eb d6                	jmp    800584 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005bc:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005c0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005c3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005c6:	83 fa 09             	cmp    $0x9,%edx
  8005c9:	77 39                	ja     800604 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005cb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005ce:	eb e9                	jmp    8005b9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 48 04             	lea    0x4(%eax),%ecx
  8005d6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005d9:	8b 00                	mov    (%eax),%eax
  8005db:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005e1:	eb 27                	jmp    80060a <vprintfmt+0xdf>
  8005e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e6:	85 c0                	test   %eax,%eax
  8005e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ed:	0f 49 c8             	cmovns %eax,%ecx
  8005f0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f6:	eb 8c                	jmp    800584 <vprintfmt+0x59>
  8005f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005fb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800602:	eb 80                	jmp    800584 <vprintfmt+0x59>
  800604:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800607:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80060a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80060e:	0f 89 70 ff ff ff    	jns    800584 <vprintfmt+0x59>
				width = precision, precision = -1;
  800614:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800617:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80061a:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800621:	e9 5e ff ff ff       	jmp    800584 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800626:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800629:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80062c:	e9 53 ff ff ff       	jmp    800584 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8d 50 04             	lea    0x4(%eax),%edx
  800637:	89 55 14             	mov    %edx,0x14(%ebp)
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	ff 30                	pushl  (%eax)
  800640:	ff d6                	call   *%esi
			break;
  800642:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800645:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800648:	e9 04 ff ff ff       	jmp    800551 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8d 50 04             	lea    0x4(%eax),%edx
  800653:	89 55 14             	mov    %edx,0x14(%ebp)
  800656:	8b 00                	mov    (%eax),%eax
  800658:	99                   	cltd   
  800659:	31 d0                	xor    %edx,%eax
  80065b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80065d:	83 f8 09             	cmp    $0x9,%eax
  800660:	7f 0b                	jg     80066d <vprintfmt+0x142>
  800662:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  800669:	85 d2                	test   %edx,%edx
  80066b:	75 18                	jne    800685 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80066d:	50                   	push   %eax
  80066e:	68 20 10 80 00       	push   $0x801020
  800673:	53                   	push   %ebx
  800674:	56                   	push   %esi
  800675:	e8 94 fe ff ff       	call   80050e <printfmt>
  80067a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800680:	e9 cc fe ff ff       	jmp    800551 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800685:	52                   	push   %edx
  800686:	68 29 10 80 00       	push   $0x801029
  80068b:	53                   	push   %ebx
  80068c:	56                   	push   %esi
  80068d:	e8 7c fe ff ff       	call   80050e <printfmt>
  800692:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800695:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800698:	e9 b4 fe ff ff       	jmp    800551 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8d 50 04             	lea    0x4(%eax),%edx
  8006a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006a8:	85 ff                	test   %edi,%edi
  8006aa:	b8 19 10 80 00       	mov    $0x801019,%eax
  8006af:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b6:	0f 8e 94 00 00 00    	jle    800750 <vprintfmt+0x225>
  8006bc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006c0:	0f 84 98 00 00 00    	je     80075e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	ff 75 c8             	pushl  -0x38(%ebp)
  8006cc:	57                   	push   %edi
  8006cd:	e8 c8 02 00 00       	call   80099a <strnlen>
  8006d2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006d5:	29 c1                	sub    %eax,%ecx
  8006d7:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006da:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006dd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006e4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006e7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e9:	eb 0f                	jmp    8006fa <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006eb:	83 ec 08             	sub    $0x8,%esp
  8006ee:	53                   	push   %ebx
  8006ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f4:	83 ef 01             	sub    $0x1,%edi
  8006f7:	83 c4 10             	add    $0x10,%esp
  8006fa:	85 ff                	test   %edi,%edi
  8006fc:	7f ed                	jg     8006eb <vprintfmt+0x1c0>
  8006fe:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800701:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800704:	85 c9                	test   %ecx,%ecx
  800706:	b8 00 00 00 00       	mov    $0x0,%eax
  80070b:	0f 49 c1             	cmovns %ecx,%eax
  80070e:	29 c1                	sub    %eax,%ecx
  800710:	89 75 08             	mov    %esi,0x8(%ebp)
  800713:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800716:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800719:	89 cb                	mov    %ecx,%ebx
  80071b:	eb 4d                	jmp    80076a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80071d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800721:	74 1b                	je     80073e <vprintfmt+0x213>
  800723:	0f be c0             	movsbl %al,%eax
  800726:	83 e8 20             	sub    $0x20,%eax
  800729:	83 f8 5e             	cmp    $0x5e,%eax
  80072c:	76 10                	jbe    80073e <vprintfmt+0x213>
					putch('?', putdat);
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	ff 75 0c             	pushl  0xc(%ebp)
  800734:	6a 3f                	push   $0x3f
  800736:	ff 55 08             	call   *0x8(%ebp)
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	eb 0d                	jmp    80074b <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80073e:	83 ec 08             	sub    $0x8,%esp
  800741:	ff 75 0c             	pushl  0xc(%ebp)
  800744:	52                   	push   %edx
  800745:	ff 55 08             	call   *0x8(%ebp)
  800748:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80074b:	83 eb 01             	sub    $0x1,%ebx
  80074e:	eb 1a                	jmp    80076a <vprintfmt+0x23f>
  800750:	89 75 08             	mov    %esi,0x8(%ebp)
  800753:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800756:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800759:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80075c:	eb 0c                	jmp    80076a <vprintfmt+0x23f>
  80075e:	89 75 08             	mov    %esi,0x8(%ebp)
  800761:	8b 75 c8             	mov    -0x38(%ebp),%esi
  800764:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800767:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80076a:	83 c7 01             	add    $0x1,%edi
  80076d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800771:	0f be d0             	movsbl %al,%edx
  800774:	85 d2                	test   %edx,%edx
  800776:	74 23                	je     80079b <vprintfmt+0x270>
  800778:	85 f6                	test   %esi,%esi
  80077a:	78 a1                	js     80071d <vprintfmt+0x1f2>
  80077c:	83 ee 01             	sub    $0x1,%esi
  80077f:	79 9c                	jns    80071d <vprintfmt+0x1f2>
  800781:	89 df                	mov    %ebx,%edi
  800783:	8b 75 08             	mov    0x8(%ebp),%esi
  800786:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800789:	eb 18                	jmp    8007a3 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80078b:	83 ec 08             	sub    $0x8,%esp
  80078e:	53                   	push   %ebx
  80078f:	6a 20                	push   $0x20
  800791:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800793:	83 ef 01             	sub    $0x1,%edi
  800796:	83 c4 10             	add    $0x10,%esp
  800799:	eb 08                	jmp    8007a3 <vprintfmt+0x278>
  80079b:	89 df                	mov    %ebx,%edi
  80079d:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a3:	85 ff                	test   %edi,%edi
  8007a5:	7f e4                	jg     80078b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007aa:	e9 a2 fd ff ff       	jmp    800551 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007af:	83 fa 01             	cmp    $0x1,%edx
  8007b2:	7e 16                	jle    8007ca <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b7:	8d 50 08             	lea    0x8(%eax),%edx
  8007ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bd:	8b 50 04             	mov    0x4(%eax),%edx
  8007c0:	8b 00                	mov    (%eax),%eax
  8007c2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007c5:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007c8:	eb 32                	jmp    8007fc <vprintfmt+0x2d1>
	else if (lflag)
  8007ca:	85 d2                	test   %edx,%edx
  8007cc:	74 18                	je     8007e6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d1:	8d 50 04             	lea    0x4(%eax),%edx
  8007d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d7:	8b 00                	mov    (%eax),%eax
  8007d9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007dc:	89 c1                	mov    %eax,%ecx
  8007de:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007e4:	eb 16                	jmp    8007fc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8d 50 04             	lea    0x4(%eax),%edx
  8007ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ef:	8b 00                	mov    (%eax),%eax
  8007f1:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007f4:	89 c1                	mov    %eax,%ecx
  8007f6:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007fc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007ff:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800802:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800805:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800808:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80080d:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800811:	0f 89 a8 00 00 00    	jns    8008bf <vprintfmt+0x394>
				putch('-', putdat);
  800817:	83 ec 08             	sub    $0x8,%esp
  80081a:	53                   	push   %ebx
  80081b:	6a 2d                	push   $0x2d
  80081d:	ff d6                	call   *%esi
				num = -(long long) num;
  80081f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800822:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800825:	f7 d8                	neg    %eax
  800827:	83 d2 00             	adc    $0x0,%edx
  80082a:	f7 da                	neg    %edx
  80082c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80082f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800832:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800835:	b8 0a 00 00 00       	mov    $0xa,%eax
  80083a:	e9 80 00 00 00       	jmp    8008bf <vprintfmt+0x394>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80083f:	8d 45 14             	lea    0x14(%ebp),%eax
  800842:	e8 70 fc ff ff       	call   8004b7 <getuint>
  800847:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80084a:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  80084d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800852:	eb 6b                	jmp    8008bf <vprintfmt+0x394>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800854:	8d 45 14             	lea    0x14(%ebp),%eax
  800857:	e8 5b fc ff ff       	call   8004b7 <getuint>
  80085c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80085f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
  800862:	6a 04                	push   $0x4
  800864:	6a 03                	push   $0x3
  800866:	6a 01                	push   $0x1
  800868:	68 2c 10 80 00       	push   $0x80102c
  80086d:	e8 82 fb ff ff       	call   8003f4 <cprintf>
			goto number;
  800872:	83 c4 10             	add    $0x10,%esp

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
			base = 8;
  800875:	b8 08 00 00 00       	mov    $0x8,%eax
int x = 1, y = 3, z = 4; //--------------------------------------->> Extra
cprintf("x %d, y %x, z %d\n", x, y, z);//-------------------------->> Extra
			goto number;
  80087a:	eb 43                	jmp    8008bf <vprintfmt+0x394>

		// pointer
		case 'p':
			putch('0', putdat);
  80087c:	83 ec 08             	sub    $0x8,%esp
  80087f:	53                   	push   %ebx
  800880:	6a 30                	push   $0x30
  800882:	ff d6                	call   *%esi
			putch('x', putdat);
  800884:	83 c4 08             	add    $0x8,%esp
  800887:	53                   	push   %ebx
  800888:	6a 78                	push   $0x78
  80088a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80088c:	8b 45 14             	mov    0x14(%ebp),%eax
  80088f:	8d 50 04             	lea    0x4(%eax),%edx
  800892:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800895:	8b 00                	mov    (%eax),%eax
  800897:	ba 00 00 00 00       	mov    $0x0,%edx
  80089c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80089f:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008a2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008a5:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008aa:	eb 13                	jmp    8008bf <vprintfmt+0x394>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8008af:	e8 03 fc ff ff       	call   8004b7 <getuint>
  8008b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008ba:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008bf:	83 ec 0c             	sub    $0xc,%esp
  8008c2:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8008c6:	52                   	push   %edx
  8008c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8008ca:	50                   	push   %eax
  8008cb:	ff 75 dc             	pushl  -0x24(%ebp)
  8008ce:	ff 75 d8             	pushl  -0x28(%ebp)
  8008d1:	89 da                	mov    %ebx,%edx
  8008d3:	89 f0                	mov    %esi,%eax
  8008d5:	e8 2e fb ff ff       	call   800408 <printnum>

			break;
  8008da:	83 c4 20             	add    $0x20,%esp
  8008dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008e0:	e9 6c fc ff ff       	jmp    800551 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008e5:	83 ec 08             	sub    $0x8,%esp
  8008e8:	53                   	push   %ebx
  8008e9:	51                   	push   %ecx
  8008ea:	ff d6                	call   *%esi
			break;
  8008ec:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008f2:	e9 5a fc ff ff       	jmp    800551 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	53                   	push   %ebx
  8008fb:	6a 25                	push   $0x25
  8008fd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	eb 03                	jmp    800907 <vprintfmt+0x3dc>
  800904:	83 ef 01             	sub    $0x1,%edi
  800907:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80090b:	75 f7                	jne    800904 <vprintfmt+0x3d9>
  80090d:	e9 3f fc ff ff       	jmp    800551 <vprintfmt+0x26>
			break;
		}

	}

}
  800912:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5f                   	pop    %edi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	83 ec 18             	sub    $0x18,%esp
  800920:	8b 45 08             	mov    0x8(%ebp),%eax
  800923:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800926:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800929:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80092d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800930:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800937:	85 c0                	test   %eax,%eax
  800939:	74 26                	je     800961 <vsnprintf+0x47>
  80093b:	85 d2                	test   %edx,%edx
  80093d:	7e 22                	jle    800961 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80093f:	ff 75 14             	pushl  0x14(%ebp)
  800942:	ff 75 10             	pushl  0x10(%ebp)
  800945:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800948:	50                   	push   %eax
  800949:	68 f1 04 80 00       	push   $0x8004f1
  80094e:	e8 d8 fb ff ff       	call   80052b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800953:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800956:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800959:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095c:	83 c4 10             	add    $0x10,%esp
  80095f:	eb 05                	jmp    800966 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800961:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800966:	c9                   	leave  
  800967:	c3                   	ret    

00800968 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80096e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800971:	50                   	push   %eax
  800972:	ff 75 10             	pushl  0x10(%ebp)
  800975:	ff 75 0c             	pushl  0xc(%ebp)
  800978:	ff 75 08             	pushl  0x8(%ebp)
  80097b:	e8 9a ff ff ff       	call   80091a <vsnprintf>
	va_end(ap);

	return rc;
}
  800980:	c9                   	leave  
  800981:	c3                   	ret    

00800982 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800988:	b8 00 00 00 00       	mov    $0x0,%eax
  80098d:	eb 03                	jmp    800992 <strlen+0x10>
		n++;
  80098f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800992:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800996:	75 f7                	jne    80098f <strlen+0xd>
		n++;
	return n;
}
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a8:	eb 03                	jmp    8009ad <strnlen+0x13>
		n++;
  8009aa:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ad:	39 c2                	cmp    %eax,%edx
  8009af:	74 08                	je     8009b9 <strnlen+0x1f>
  8009b1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009b5:	75 f3                	jne    8009aa <strnlen+0x10>
  8009b7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009c5:	89 c2                	mov    %eax,%edx
  8009c7:	83 c2 01             	add    $0x1,%edx
  8009ca:	83 c1 01             	add    $0x1,%ecx
  8009cd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009d1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009d4:	84 db                	test   %bl,%bl
  8009d6:	75 ef                	jne    8009c7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009d8:	5b                   	pop    %ebx
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009e2:	53                   	push   %ebx
  8009e3:	e8 9a ff ff ff       	call   800982 <strlen>
  8009e8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009eb:	ff 75 0c             	pushl  0xc(%ebp)
  8009ee:	01 d8                	add    %ebx,%eax
  8009f0:	50                   	push   %eax
  8009f1:	e8 c5 ff ff ff       	call   8009bb <strcpy>
	return dst;
}
  8009f6:	89 d8                	mov    %ebx,%eax
  8009f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009fb:	c9                   	leave  
  8009fc:	c3                   	ret    

008009fd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 75 08             	mov    0x8(%ebp),%esi
  800a05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a08:	89 f3                	mov    %esi,%ebx
  800a0a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0d:	89 f2                	mov    %esi,%edx
  800a0f:	eb 0f                	jmp    800a20 <strncpy+0x23>
		*dst++ = *src;
  800a11:	83 c2 01             	add    $0x1,%edx
  800a14:	0f b6 01             	movzbl (%ecx),%eax
  800a17:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a1a:	80 39 01             	cmpb   $0x1,(%ecx)
  800a1d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a20:	39 da                	cmp    %ebx,%edx
  800a22:	75 ed                	jne    800a11 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a24:	89 f0                	mov    %esi,%eax
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 75 08             	mov    0x8(%ebp),%esi
  800a32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a35:	8b 55 10             	mov    0x10(%ebp),%edx
  800a38:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a3a:	85 d2                	test   %edx,%edx
  800a3c:	74 21                	je     800a5f <strlcpy+0x35>
  800a3e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a42:	89 f2                	mov    %esi,%edx
  800a44:	eb 09                	jmp    800a4f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a46:	83 c2 01             	add    $0x1,%edx
  800a49:	83 c1 01             	add    $0x1,%ecx
  800a4c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a4f:	39 c2                	cmp    %eax,%edx
  800a51:	74 09                	je     800a5c <strlcpy+0x32>
  800a53:	0f b6 19             	movzbl (%ecx),%ebx
  800a56:	84 db                	test   %bl,%bl
  800a58:	75 ec                	jne    800a46 <strlcpy+0x1c>
  800a5a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a5c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a5f:	29 f0                	sub    %esi,%eax
}
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a6e:	eb 06                	jmp    800a76 <strcmp+0x11>
		p++, q++;
  800a70:	83 c1 01             	add    $0x1,%ecx
  800a73:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a76:	0f b6 01             	movzbl (%ecx),%eax
  800a79:	84 c0                	test   %al,%al
  800a7b:	74 04                	je     800a81 <strcmp+0x1c>
  800a7d:	3a 02                	cmp    (%edx),%al
  800a7f:	74 ef                	je     800a70 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a81:	0f b6 c0             	movzbl %al,%eax
  800a84:	0f b6 12             	movzbl (%edx),%edx
  800a87:	29 d0                	sub    %edx,%eax
}
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	53                   	push   %ebx
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a95:	89 c3                	mov    %eax,%ebx
  800a97:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a9a:	eb 06                	jmp    800aa2 <strncmp+0x17>
		n--, p++, q++;
  800a9c:	83 c0 01             	add    $0x1,%eax
  800a9f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aa2:	39 d8                	cmp    %ebx,%eax
  800aa4:	74 15                	je     800abb <strncmp+0x30>
  800aa6:	0f b6 08             	movzbl (%eax),%ecx
  800aa9:	84 c9                	test   %cl,%cl
  800aab:	74 04                	je     800ab1 <strncmp+0x26>
  800aad:	3a 0a                	cmp    (%edx),%cl
  800aaf:	74 eb                	je     800a9c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab1:	0f b6 00             	movzbl (%eax),%eax
  800ab4:	0f b6 12             	movzbl (%edx),%edx
  800ab7:	29 d0                	sub    %edx,%eax
  800ab9:	eb 05                	jmp    800ac0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800abb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800acd:	eb 07                	jmp    800ad6 <strchr+0x13>
		if (*s == c)
  800acf:	38 ca                	cmp    %cl,%dl
  800ad1:	74 0f                	je     800ae2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ad3:	83 c0 01             	add    $0x1,%eax
  800ad6:	0f b6 10             	movzbl (%eax),%edx
  800ad9:	84 d2                	test   %dl,%dl
  800adb:	75 f2                	jne    800acf <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800add:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aee:	eb 03                	jmp    800af3 <strfind+0xf>
  800af0:	83 c0 01             	add    $0x1,%eax
  800af3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800af6:	38 ca                	cmp    %cl,%dl
  800af8:	74 04                	je     800afe <strfind+0x1a>
  800afa:	84 d2                	test   %dl,%dl
  800afc:	75 f2                	jne    800af0 <strfind+0xc>
			break;
	return (char *) s;
}
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	57                   	push   %edi
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
  800b06:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b09:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b0c:	85 c9                	test   %ecx,%ecx
  800b0e:	74 36                	je     800b46 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b10:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b16:	75 28                	jne    800b40 <memset+0x40>
  800b18:	f6 c1 03             	test   $0x3,%cl
  800b1b:	75 23                	jne    800b40 <memset+0x40>
		c &= 0xFF;
  800b1d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b21:	89 d3                	mov    %edx,%ebx
  800b23:	c1 e3 08             	shl    $0x8,%ebx
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	c1 e6 18             	shl    $0x18,%esi
  800b2b:	89 d0                	mov    %edx,%eax
  800b2d:	c1 e0 10             	shl    $0x10,%eax
  800b30:	09 f0                	or     %esi,%eax
  800b32:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b34:	89 d8                	mov    %ebx,%eax
  800b36:	09 d0                	or     %edx,%eax
  800b38:	c1 e9 02             	shr    $0x2,%ecx
  800b3b:	fc                   	cld    
  800b3c:	f3 ab                	rep stos %eax,%es:(%edi)
  800b3e:	eb 06                	jmp    800b46 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b43:	fc                   	cld    
  800b44:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b46:	89 f8                	mov    %edi,%eax
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b58:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b5b:	39 c6                	cmp    %eax,%esi
  800b5d:	73 35                	jae    800b94 <memmove+0x47>
  800b5f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b62:	39 d0                	cmp    %edx,%eax
  800b64:	73 2e                	jae    800b94 <memmove+0x47>
		s += n;
		d += n;
  800b66:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b69:	89 d6                	mov    %edx,%esi
  800b6b:	09 fe                	or     %edi,%esi
  800b6d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b73:	75 13                	jne    800b88 <memmove+0x3b>
  800b75:	f6 c1 03             	test   $0x3,%cl
  800b78:	75 0e                	jne    800b88 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b7a:	83 ef 04             	sub    $0x4,%edi
  800b7d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b80:	c1 e9 02             	shr    $0x2,%ecx
  800b83:	fd                   	std    
  800b84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b86:	eb 09                	jmp    800b91 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b88:	83 ef 01             	sub    $0x1,%edi
  800b8b:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b8e:	fd                   	std    
  800b8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b91:	fc                   	cld    
  800b92:	eb 1d                	jmp    800bb1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b94:	89 f2                	mov    %esi,%edx
  800b96:	09 c2                	or     %eax,%edx
  800b98:	f6 c2 03             	test   $0x3,%dl
  800b9b:	75 0f                	jne    800bac <memmove+0x5f>
  800b9d:	f6 c1 03             	test   $0x3,%cl
  800ba0:	75 0a                	jne    800bac <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ba2:	c1 e9 02             	shr    $0x2,%ecx
  800ba5:	89 c7                	mov    %eax,%edi
  800ba7:	fc                   	cld    
  800ba8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800baa:	eb 05                	jmp    800bb1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bac:	89 c7                	mov    %eax,%edi
  800bae:	fc                   	cld    
  800baf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bb8:	ff 75 10             	pushl  0x10(%ebp)
  800bbb:	ff 75 0c             	pushl  0xc(%ebp)
  800bbe:	ff 75 08             	pushl  0x8(%ebp)
  800bc1:	e8 87 ff ff ff       	call   800b4d <memmove>
}
  800bc6:	c9                   	leave  
  800bc7:	c3                   	ret    

00800bc8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
  800bcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd3:	89 c6                	mov    %eax,%esi
  800bd5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd8:	eb 1a                	jmp    800bf4 <memcmp+0x2c>
		if (*s1 != *s2)
  800bda:	0f b6 08             	movzbl (%eax),%ecx
  800bdd:	0f b6 1a             	movzbl (%edx),%ebx
  800be0:	38 d9                	cmp    %bl,%cl
  800be2:	74 0a                	je     800bee <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800be4:	0f b6 c1             	movzbl %cl,%eax
  800be7:	0f b6 db             	movzbl %bl,%ebx
  800bea:	29 d8                	sub    %ebx,%eax
  800bec:	eb 0f                	jmp    800bfd <memcmp+0x35>
		s1++, s2++;
  800bee:	83 c0 01             	add    $0x1,%eax
  800bf1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf4:	39 f0                	cmp    %esi,%eax
  800bf6:	75 e2                	jne    800bda <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bf8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	53                   	push   %ebx
  800c05:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c08:	89 c1                	mov    %eax,%ecx
  800c0a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c0d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c11:	eb 0a                	jmp    800c1d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c13:	0f b6 10             	movzbl (%eax),%edx
  800c16:	39 da                	cmp    %ebx,%edx
  800c18:	74 07                	je     800c21 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c1a:	83 c0 01             	add    $0x1,%eax
  800c1d:	39 c8                	cmp    %ecx,%eax
  800c1f:	72 f2                	jb     800c13 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c21:	5b                   	pop    %ebx
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
  800c2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c30:	eb 03                	jmp    800c35 <strtol+0x11>
		s++;
  800c32:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c35:	0f b6 01             	movzbl (%ecx),%eax
  800c38:	3c 20                	cmp    $0x20,%al
  800c3a:	74 f6                	je     800c32 <strtol+0xe>
  800c3c:	3c 09                	cmp    $0x9,%al
  800c3e:	74 f2                	je     800c32 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c40:	3c 2b                	cmp    $0x2b,%al
  800c42:	75 0a                	jne    800c4e <strtol+0x2a>
		s++;
  800c44:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c47:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4c:	eb 11                	jmp    800c5f <strtol+0x3b>
  800c4e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c53:	3c 2d                	cmp    $0x2d,%al
  800c55:	75 08                	jne    800c5f <strtol+0x3b>
		s++, neg = 1;
  800c57:	83 c1 01             	add    $0x1,%ecx
  800c5a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c5f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c65:	75 15                	jne    800c7c <strtol+0x58>
  800c67:	80 39 30             	cmpb   $0x30,(%ecx)
  800c6a:	75 10                	jne    800c7c <strtol+0x58>
  800c6c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c70:	75 7c                	jne    800cee <strtol+0xca>
		s += 2, base = 16;
  800c72:	83 c1 02             	add    $0x2,%ecx
  800c75:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c7a:	eb 16                	jmp    800c92 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c7c:	85 db                	test   %ebx,%ebx
  800c7e:	75 12                	jne    800c92 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c80:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c85:	80 39 30             	cmpb   $0x30,(%ecx)
  800c88:	75 08                	jne    800c92 <strtol+0x6e>
		s++, base = 8;
  800c8a:	83 c1 01             	add    $0x1,%ecx
  800c8d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c92:	b8 00 00 00 00       	mov    $0x0,%eax
  800c97:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c9a:	0f b6 11             	movzbl (%ecx),%edx
  800c9d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ca0:	89 f3                	mov    %esi,%ebx
  800ca2:	80 fb 09             	cmp    $0x9,%bl
  800ca5:	77 08                	ja     800caf <strtol+0x8b>
			dig = *s - '0';
  800ca7:	0f be d2             	movsbl %dl,%edx
  800caa:	83 ea 30             	sub    $0x30,%edx
  800cad:	eb 22                	jmp    800cd1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800caf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cb2:	89 f3                	mov    %esi,%ebx
  800cb4:	80 fb 19             	cmp    $0x19,%bl
  800cb7:	77 08                	ja     800cc1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cb9:	0f be d2             	movsbl %dl,%edx
  800cbc:	83 ea 57             	sub    $0x57,%edx
  800cbf:	eb 10                	jmp    800cd1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cc1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cc4:	89 f3                	mov    %esi,%ebx
  800cc6:	80 fb 19             	cmp    $0x19,%bl
  800cc9:	77 16                	ja     800ce1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ccb:	0f be d2             	movsbl %dl,%edx
  800cce:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cd1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cd4:	7d 0b                	jge    800ce1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cd6:	83 c1 01             	add    $0x1,%ecx
  800cd9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cdd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cdf:	eb b9                	jmp    800c9a <strtol+0x76>

	if (endptr)
  800ce1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce5:	74 0d                	je     800cf4 <strtol+0xd0>
		*endptr = (char *) s;
  800ce7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cea:	89 0e                	mov    %ecx,(%esi)
  800cec:	eb 06                	jmp    800cf4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cee:	85 db                	test   %ebx,%ebx
  800cf0:	74 98                	je     800c8a <strtol+0x66>
  800cf2:	eb 9e                	jmp    800c92 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cf4:	89 c2                	mov    %eax,%edx
  800cf6:	f7 da                	neg    %edx
  800cf8:	85 ff                	test   %edi,%edi
  800cfa:	0f 45 c2             	cmovne %edx,%eax
}
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    
  800d02:	66 90                	xchg   %ax,%ax
  800d04:	66 90                	xchg   %ax,%ax
  800d06:	66 90                	xchg   %ax,%ax
  800d08:	66 90                	xchg   %ax,%ax
  800d0a:	66 90                	xchg   %ax,%ax
  800d0c:	66 90                	xchg   %ax,%ax
  800d0e:	66 90                	xchg   %ax,%ax

00800d10 <__udivdi3>:
  800d10:	55                   	push   %ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 1c             	sub    $0x1c,%esp
  800d17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d27:	85 f6                	test   %esi,%esi
  800d29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d2d:	89 ca                	mov    %ecx,%edx
  800d2f:	89 f8                	mov    %edi,%eax
  800d31:	75 3d                	jne    800d70 <__udivdi3+0x60>
  800d33:	39 cf                	cmp    %ecx,%edi
  800d35:	0f 87 c5 00 00 00    	ja     800e00 <__udivdi3+0xf0>
  800d3b:	85 ff                	test   %edi,%edi
  800d3d:	89 fd                	mov    %edi,%ebp
  800d3f:	75 0b                	jne    800d4c <__udivdi3+0x3c>
  800d41:	b8 01 00 00 00       	mov    $0x1,%eax
  800d46:	31 d2                	xor    %edx,%edx
  800d48:	f7 f7                	div    %edi
  800d4a:	89 c5                	mov    %eax,%ebp
  800d4c:	89 c8                	mov    %ecx,%eax
  800d4e:	31 d2                	xor    %edx,%edx
  800d50:	f7 f5                	div    %ebp
  800d52:	89 c1                	mov    %eax,%ecx
  800d54:	89 d8                	mov    %ebx,%eax
  800d56:	89 cf                	mov    %ecx,%edi
  800d58:	f7 f5                	div    %ebp
  800d5a:	89 c3                	mov    %eax,%ebx
  800d5c:	89 d8                	mov    %ebx,%eax
  800d5e:	89 fa                	mov    %edi,%edx
  800d60:	83 c4 1c             	add    $0x1c,%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    
  800d68:	90                   	nop
  800d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d70:	39 ce                	cmp    %ecx,%esi
  800d72:	77 74                	ja     800de8 <__udivdi3+0xd8>
  800d74:	0f bd fe             	bsr    %esi,%edi
  800d77:	83 f7 1f             	xor    $0x1f,%edi
  800d7a:	0f 84 98 00 00 00    	je     800e18 <__udivdi3+0x108>
  800d80:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d85:	89 f9                	mov    %edi,%ecx
  800d87:	89 c5                	mov    %eax,%ebp
  800d89:	29 fb                	sub    %edi,%ebx
  800d8b:	d3 e6                	shl    %cl,%esi
  800d8d:	89 d9                	mov    %ebx,%ecx
  800d8f:	d3 ed                	shr    %cl,%ebp
  800d91:	89 f9                	mov    %edi,%ecx
  800d93:	d3 e0                	shl    %cl,%eax
  800d95:	09 ee                	or     %ebp,%esi
  800d97:	89 d9                	mov    %ebx,%ecx
  800d99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d9d:	89 d5                	mov    %edx,%ebp
  800d9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800da3:	d3 ed                	shr    %cl,%ebp
  800da5:	89 f9                	mov    %edi,%ecx
  800da7:	d3 e2                	shl    %cl,%edx
  800da9:	89 d9                	mov    %ebx,%ecx
  800dab:	d3 e8                	shr    %cl,%eax
  800dad:	09 c2                	or     %eax,%edx
  800daf:	89 d0                	mov    %edx,%eax
  800db1:	89 ea                	mov    %ebp,%edx
  800db3:	f7 f6                	div    %esi
  800db5:	89 d5                	mov    %edx,%ebp
  800db7:	89 c3                	mov    %eax,%ebx
  800db9:	f7 64 24 0c          	mull   0xc(%esp)
  800dbd:	39 d5                	cmp    %edx,%ebp
  800dbf:	72 10                	jb     800dd1 <__udivdi3+0xc1>
  800dc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800dc5:	89 f9                	mov    %edi,%ecx
  800dc7:	d3 e6                	shl    %cl,%esi
  800dc9:	39 c6                	cmp    %eax,%esi
  800dcb:	73 07                	jae    800dd4 <__udivdi3+0xc4>
  800dcd:	39 d5                	cmp    %edx,%ebp
  800dcf:	75 03                	jne    800dd4 <__udivdi3+0xc4>
  800dd1:	83 eb 01             	sub    $0x1,%ebx
  800dd4:	31 ff                	xor    %edi,%edi
  800dd6:	89 d8                	mov    %ebx,%eax
  800dd8:	89 fa                	mov    %edi,%edx
  800dda:	83 c4 1c             	add    $0x1c,%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    
  800de2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800de8:	31 ff                	xor    %edi,%edi
  800dea:	31 db                	xor    %ebx,%ebx
  800dec:	89 d8                	mov    %ebx,%eax
  800dee:	89 fa                	mov    %edi,%edx
  800df0:	83 c4 1c             	add    $0x1c,%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    
  800df8:	90                   	nop
  800df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e00:	89 d8                	mov    %ebx,%eax
  800e02:	f7 f7                	div    %edi
  800e04:	31 ff                	xor    %edi,%edi
  800e06:	89 c3                	mov    %eax,%ebx
  800e08:	89 d8                	mov    %ebx,%eax
  800e0a:	89 fa                	mov    %edi,%edx
  800e0c:	83 c4 1c             	add    $0x1c,%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    
  800e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e18:	39 ce                	cmp    %ecx,%esi
  800e1a:	72 0c                	jb     800e28 <__udivdi3+0x118>
  800e1c:	31 db                	xor    %ebx,%ebx
  800e1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e22:	0f 87 34 ff ff ff    	ja     800d5c <__udivdi3+0x4c>
  800e28:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e2d:	e9 2a ff ff ff       	jmp    800d5c <__udivdi3+0x4c>
  800e32:	66 90                	xchg   %ax,%ax
  800e34:	66 90                	xchg   %ax,%ax
  800e36:	66 90                	xchg   %ax,%ax
  800e38:	66 90                	xchg   %ax,%ax
  800e3a:	66 90                	xchg   %ax,%ax
  800e3c:	66 90                	xchg   %ax,%ax
  800e3e:	66 90                	xchg   %ax,%ax

00800e40 <__umoddi3>:
  800e40:	55                   	push   %ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
  800e44:	83 ec 1c             	sub    $0x1c,%esp
  800e47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e57:	85 d2                	test   %edx,%edx
  800e59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e61:	89 f3                	mov    %esi,%ebx
  800e63:	89 3c 24             	mov    %edi,(%esp)
  800e66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e6a:	75 1c                	jne    800e88 <__umoddi3+0x48>
  800e6c:	39 f7                	cmp    %esi,%edi
  800e6e:	76 50                	jbe    800ec0 <__umoddi3+0x80>
  800e70:	89 c8                	mov    %ecx,%eax
  800e72:	89 f2                	mov    %esi,%edx
  800e74:	f7 f7                	div    %edi
  800e76:	89 d0                	mov    %edx,%eax
  800e78:	31 d2                	xor    %edx,%edx
  800e7a:	83 c4 1c             	add    $0x1c,%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
  800e82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e88:	39 f2                	cmp    %esi,%edx
  800e8a:	89 d0                	mov    %edx,%eax
  800e8c:	77 52                	ja     800ee0 <__umoddi3+0xa0>
  800e8e:	0f bd ea             	bsr    %edx,%ebp
  800e91:	83 f5 1f             	xor    $0x1f,%ebp
  800e94:	75 5a                	jne    800ef0 <__umoddi3+0xb0>
  800e96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e9a:	0f 82 e0 00 00 00    	jb     800f80 <__umoddi3+0x140>
  800ea0:	39 0c 24             	cmp    %ecx,(%esp)
  800ea3:	0f 86 d7 00 00 00    	jbe    800f80 <__umoddi3+0x140>
  800ea9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ead:	8b 54 24 04          	mov    0x4(%esp),%edx
  800eb1:	83 c4 1c             	add    $0x1c,%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	85 ff                	test   %edi,%edi
  800ec2:	89 fd                	mov    %edi,%ebp
  800ec4:	75 0b                	jne    800ed1 <__umoddi3+0x91>
  800ec6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ecb:	31 d2                	xor    %edx,%edx
  800ecd:	f7 f7                	div    %edi
  800ecf:	89 c5                	mov    %eax,%ebp
  800ed1:	89 f0                	mov    %esi,%eax
  800ed3:	31 d2                	xor    %edx,%edx
  800ed5:	f7 f5                	div    %ebp
  800ed7:	89 c8                	mov    %ecx,%eax
  800ed9:	f7 f5                	div    %ebp
  800edb:	89 d0                	mov    %edx,%eax
  800edd:	eb 99                	jmp    800e78 <__umoddi3+0x38>
  800edf:	90                   	nop
  800ee0:	89 c8                	mov    %ecx,%eax
  800ee2:	89 f2                	mov    %esi,%edx
  800ee4:	83 c4 1c             	add    $0x1c,%esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5f                   	pop    %edi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    
  800eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	8b 34 24             	mov    (%esp),%esi
  800ef3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ef8:	89 e9                	mov    %ebp,%ecx
  800efa:	29 ef                	sub    %ebp,%edi
  800efc:	d3 e0                	shl    %cl,%eax
  800efe:	89 f9                	mov    %edi,%ecx
  800f00:	89 f2                	mov    %esi,%edx
  800f02:	d3 ea                	shr    %cl,%edx
  800f04:	89 e9                	mov    %ebp,%ecx
  800f06:	09 c2                	or     %eax,%edx
  800f08:	89 d8                	mov    %ebx,%eax
  800f0a:	89 14 24             	mov    %edx,(%esp)
  800f0d:	89 f2                	mov    %esi,%edx
  800f0f:	d3 e2                	shl    %cl,%edx
  800f11:	89 f9                	mov    %edi,%ecx
  800f13:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f1b:	d3 e8                	shr    %cl,%eax
  800f1d:	89 e9                	mov    %ebp,%ecx
  800f1f:	89 c6                	mov    %eax,%esi
  800f21:	d3 e3                	shl    %cl,%ebx
  800f23:	89 f9                	mov    %edi,%ecx
  800f25:	89 d0                	mov    %edx,%eax
  800f27:	d3 e8                	shr    %cl,%eax
  800f29:	89 e9                	mov    %ebp,%ecx
  800f2b:	09 d8                	or     %ebx,%eax
  800f2d:	89 d3                	mov    %edx,%ebx
  800f2f:	89 f2                	mov    %esi,%edx
  800f31:	f7 34 24             	divl   (%esp)
  800f34:	89 d6                	mov    %edx,%esi
  800f36:	d3 e3                	shl    %cl,%ebx
  800f38:	f7 64 24 04          	mull   0x4(%esp)
  800f3c:	39 d6                	cmp    %edx,%esi
  800f3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f42:	89 d1                	mov    %edx,%ecx
  800f44:	89 c3                	mov    %eax,%ebx
  800f46:	72 08                	jb     800f50 <__umoddi3+0x110>
  800f48:	75 11                	jne    800f5b <__umoddi3+0x11b>
  800f4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f4e:	73 0b                	jae    800f5b <__umoddi3+0x11b>
  800f50:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f54:	1b 14 24             	sbb    (%esp),%edx
  800f57:	89 d1                	mov    %edx,%ecx
  800f59:	89 c3                	mov    %eax,%ebx
  800f5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f5f:	29 da                	sub    %ebx,%edx
  800f61:	19 ce                	sbb    %ecx,%esi
  800f63:	89 f9                	mov    %edi,%ecx
  800f65:	89 f0                	mov    %esi,%eax
  800f67:	d3 e0                	shl    %cl,%eax
  800f69:	89 e9                	mov    %ebp,%ecx
  800f6b:	d3 ea                	shr    %cl,%edx
  800f6d:	89 e9                	mov    %ebp,%ecx
  800f6f:	d3 ee                	shr    %cl,%esi
  800f71:	09 d0                	or     %edx,%eax
  800f73:	89 f2                	mov    %esi,%edx
  800f75:	83 c4 1c             	add    $0x1c,%esp
  800f78:	5b                   	pop    %ebx
  800f79:	5e                   	pop    %esi
  800f7a:	5f                   	pop    %edi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi
  800f80:	29 f9                	sub    %edi,%ecx
  800f82:	19 d6                	sbb    %edx,%esi
  800f84:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f8c:	e9 18 ff ff ff       	jmp    800ea9 <__umoddi3+0x69>
