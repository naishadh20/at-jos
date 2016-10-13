///////////////////////////////////////////////////////////
First
/////////////////////////////////////////////////////////

void
env_init(void)
{
   size_t i;
    for (i = NENV-1; i >= 0; i--) {
	envs[i].env_id = 0;
        envs[i].env_link = env_free_list;
        env_free_list = &envs[i];
    }
	// Set up envs array
	// LAB 3: Your code here.

	// Per-CPU part of the initialization
	env_init_percpu();
}



void
env_init(void)
{
    int i;
    for (i = NENV-1;i >= 0; --i) {
    //initialize backwards to maintain the order
        envs[i].env_id = 0;
        //normal link-list routine
        envs[i].env_link = env_free_list;
        env_free_list = envs+i;
    }
    env_init_percpu();
}





///////////////////////////////////////////////////////////
second
/////////////////////////////////////////////////////////


static int
env_setup_vm(struct Env *e)
{
	int i;
	 
	struct PageInfo *p = NULL;
	//p = page_alloc(ALLOC_ZERO);
	
	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO))){
		panic("env_alloc: %e", E_NO_MEM);
		return -E_NO_MEM;
	}
	
	p->pp_ref++;
	e->env_pgdir = page2kva(p);
memcpy(e->env_pgdir, kern_pgdir, PGSIZE);

	
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;

	return 0;
}




static int
env_setup_vm(struct Env *e)
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;

	
	p->pp_ref++;
	e->env_pgdir = (pde_t *) page2kva(p);
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;

	return 0;
}



static void
load_icode(struct Env *e, uint8_t *binary)
{   
    struct Elf *ELFHDR = (struct Elf *) binary;
    struct Proghdr *ph, *eph;
    if (ELFHDR->e_magic != ELF_MAGIC){
        panic("load_icode: ELF_MAGIC not matching");

}
    ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    eph = ph + ELFHDR->e_phnum;
    lcr3(PADDR(e->env_pgdir));
    for(;ph<eph;ph++)
    {
        if(ph->p_type==ELF_PROG_LOAD){
            if(ph->p_filesz > ph->p_memsz)
                panic("load_icode: ph->p_filesz > ph->p_memsz");
            //cprintf("ph=%x",ph);
            region_alloc(e, (void *)ph->p_va, ph->p_memsz);
            }
            memset((void *)ph->p_va, 0, ph->p_memsz);
            memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);    }
    lcr3(PADDR(kern_pgdir));
    e->env_tf.tf_eip = ELFHDR->e_entry;
    // Now map one page for the program's initial stack
    // at virtual address USTACKTOP - PGSIZE.
    // LAB 3: Your code here.
    region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
    
}







static void
load_icode(struct Env *e, uint8_t *binary)
{
	

struct Elf *header = (struct Elf *) binary;
struct Proghdr *ph, *eph;

if (header->e_magic != ELF_MAGIC)
		goto bad;

ph = (struct Proghdr *) ((uint8_t *) header + header->e_phoff);
	eph = ph + header->e_phnum;

lcr3(PADDR(e->env_pgdir));

for (; ph < eph; ph++){
if(ph->p_type == ELF_PROG_LOAD)
region_alloc(e,(void*)ph->p_va, ph->p_memsz);
memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
memset((void *)ph->p_va, 0, ph->p_memsz);

}






















































0xf0103778




