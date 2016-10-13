///////////////////////////////////////////////////////////////////////////////////////////////////////////
		pgdir_walk
///////////////////////////////////////////////////////////////////////////////////////////////////////////

//Input Arguments: pointer to the page directory, pointer to va, create flag 
//Returns: Pointer to the page table entry

pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
int dir_idx = PDX(va);
int tab_idx =  PTX(va);
pte_t *page_tbl_entry;
struct PageInfo *page_dir;

if(!(pgdir[dir_idx] & PTE_P))
{
	if (create !=0 )
	{
	page_dir = page_alloc(ALLOC_ZERO);
		if(!page_dir)
		{
		cprintf ("allocation failed\n");
		return NULL;
		}
	page_dir->pp_ref++;
        pgdir[dir_idx] = page2pa(page_dir) | PTE_P | PTE_U | PTE_W; 
	}
	else
	return NULL;
}
	page_tbl_entry = KADDR(PTE_ADDR(pgdir[dir_idx]));
        return page_tbl_entry+tab_idx;
}

////////////////////////////////////////////////////////
	PDX(va) & PTX(va) ---> memlayout.h		
////////////////////////////////////////////////////////

// page number field of address
#define PGNUM(la)	(((uintptr_t) (la)) >> PTXSHIFT)

#define PDX(la)		((((uintptr_t) (la)) >> PDXSHIFT) & 0x3FF)

// page table index
#define PTX(la)		((((uintptr_t) (la)) >> PTXSHIFT) & 0x3FF)

// offset in page
#define PGOFF(la)	(((uintptr_t) (la)) & 0xFFF)


////////////////////////////////////////////////////////
	page2pa() ---> pmap.h		
////////////////////////////////////////////////////////
static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT; //PGSHIFT is 12
}

////////////////////////////////////////////////////////
KADDR(PTE_ADDR(pgdir[dir_idx]))	---> pmap.h	
///////////////////////////////////////////////////////

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
	return (void *)(pa + KERNBASE);
}

#define PGNUM(la)	(((uintptr_t) (la)) >> PTXSHIFT) // mmu.h

///////////////////////////////////////////////////////////////////////////////////////////////////////////
	boot_map_region
///////////////////////////////////////////////////////////////////////////////////////////////////////////

//Input Arguments: pointer to the page directory, pointer to va, size, permission bit 
//Returns: Pointer to the page table entry

static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
int total_pages = size/PGSIZE;
for(int i=0;i<total_pages;i++)
{
pde_t* new_page_table_entry = pgdir_walk(pgdir, (void*) va, 1);
if(!new_page_table_entry)
cprintf("Allocation failed");
*new_page_table_entry = pa | (perm | PTE_P);
va= va+PGSIZE;
pa= pa+PGSIZE;
}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
	page_lookup
///////////////////////////////////////////////////////////////////////////////////////////////////////////

//Input Arguments: pointer to the page directory, pointer to va, size, ** to store page table entry 
//Returns: page (struct PageInfo)
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{

	pte_t *page_table_entry;
	page_table_entry =  pgdir_walk(pgdir, va, 0);
		if (!page_table_entry || !(*page_table_entry & PTE_P))
		{
		cprintf("unable to find page\n");
		return NULL;
		}
		if(pte_store != NULL)
		{
		*pte_store = page_table_entry;
		}
	return pa2page(PTE_ADDR(*page_table_entry)); 
}
////////////////////////////////////////////////////////
	pa2page() ---> pmap.h		
////////////////////////////////////////////////////////

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
}

#define PTE_ADDR(pte)	((physaddr_t) (pte) & ~0xFFF) //pmap.h

///////////////////////////////////////////////////////////////////////////////////////////////////////////
	page_remove
///////////////////////////////////////////////////////////////////////////////////////////////////////////
//Input Arguments: pointer to the page directory, pointer to va, size
//Returns:void

void
page_remove(pde_t *pgdir, void *va)
{

pte_t *page_tbl_entry;
struct PageInfo *page_found;
page_found = page_lookup(pgdir, va, &page_tbl_entry);
	if (!page_found || !(*page_tbl_entry & PTE_P))
	{
		cprintf("unable to find page\n");
		return;
	}
	 page_decref(page_found);
	*page_tbl_entry = 0;
	 tlb_invalidate(pgdir, va);
}
////////////////////////////////////////////////////////
	page_decref() ---> pmap.c		
//////////////////////////////////////////////////////

void
page_decref(struct PageInfo* pp)
{
	if (--pp->pp_ref == 0)
		page_free(pp);
}

////////////////////////////////////////////////////////
	tlb_invalidate() ---> pmap.c		
///////////////////////////////////////////////////////

void
tlb_invalidate(pde_t *pgdir, void *va)
{
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va); //??
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
	page_insert
///////////////////////////////////////////////////////////////////////////////////////////////////////////
//Input Arguments: pointer to the page directory,page(struct PageInfo),permission
//Returns: int (success flag)
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *page_tbl_entry;
	 page_tbl_entry= pgdir_walk(pgdir, va, 1);
	if(! page_tbl_entry)
		{
		cprintf("Unable to find the page\n");
		return -E_NO_MEM;
		}
	 pp->pp_ref++;
	if (*page_tbl_entry & PTE_P)
	{
	cprintf("Page removed\n");
	page_remove(pgdir, va);
	}
*page_tbl_entry = page2pa(pp) | perm | PTE_P;
return 0;
}

E_NO_MEM	= 4,	// Request failed due to memory shortage (enum in error.h)




///////////////////////////////////////////////////////////////////////////////////////////////////////////

		Exercise 5


	
///////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
	// Map 'pages' read-only by the user at linear address UPAGES
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
	cprintf("PADDR(pages) %x\n", PADDR(pages));
	//////////////////////////////////////////////////////////////////////
	// Use the physical memory that 'bootstack' refers to as the kernel
	// stack.  The kernel stack grows down from virtual address KSTACKTOP.
	// We consider the entire range from [KSTACKTOP-PTSIZE, KSTACKTOP)
	// to be the kernel stack, but break this into two pieces:
	//     * [KSTACKTOP-KSTKSIZE, KSTACKTOP) -- backed by physical memory
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
	cprintf("PADDR(bootstack) %x\n", PADDR(bootstack));



	//////////////////////////////////////////////////////////////////////
	// Map all of physical memory at KERNBASE.
	// Ie.  the VA range [KERNBASE, 2^32) should map to
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W | PTE_P);
	

//memlayout.h
/*
 * Virtual memory map:                                Permissions
 *                                                    kernel/user
 *
 *    4 Gig -------->  +------------------------------+
 *                     |                              | RW/--
 *                     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *                     :              .               :
 *                     :              .               :
 *                     :              .               :
 *                     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~| RW/--
 *                     |                              | RW/--
 *                     |   Remapped Physical Memory   | RW/--
 *                     |                              | RW/--
 *    KERNBASE, ---->  +------------------------------+ 0xf0000000      --+
 *    KSTACKTOP        |     CPU0's Kernel Stack      | RW/--  KSTKSIZE   |
 *                     | - - - - - - - - - - - - - - -|                   |
 *                     |      Invalid Memory (*)      | --/--  KSTKGAP    |
 *                     +------------------------------+                   |
 *                     |     CPU1's Kernel Stack      | RW/--  KSTKSIZE   |
 *                     | - - - - - - - - - - - - - - -|                 PTSIZE
 *                     |      Invalid Memory (*)      | --/--  KSTKGAP    |
 *                     +------------------------------+                   |
 *                     :              .               :                   |
 *                     :              .               :                   |
 *    MMIOLIM ------>  +------------------------------+ 0xefc00000      --+
 *                     |       Memory-mapped I/O      | RW/--  PTSIZE
 * ULIM, MMIOBASE -->  +------------------------------+ 0xef800000
 *                     |  Cur. Page Table (User R-)   | R-/R-  PTSIZE
 *    UVPT      ---->  +------------------------------+ 0xef400000
 *                     |          RO PAGES            | R-/R-  PTSIZE
 *    UPAGES    ---->  +------------------------------+ 0xef000000
 *                     |           RO ENVS            | R-/R-  PTSIZE
 * UTOP,UENVS ------>  +------------------------------+ 0xeec00000
 * UXSTACKTOP -/       |     User Exception Stack     | RW/RW  PGSIZE
 *                     +------------------------------+ 0xeebff000
 *                     |       Empty Memory (*)       | --/--  PGSIZE
 *    USTACKTOP  --->  +------------------------------+ 0xeebfe000
 *                     |      Normal User Stack       | RW/RW  PGSIZE
 *                     +------------------------------+ 0xeebfd000
 *                     |                              |
 *                     |                              |
 *                     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *                     .                              .
 *                     .                              .
 *                     .                              .
 *                     |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|
 *                     |     Program Data & Heap      |
 *    UTEXT -------->  +------------------------------+ 0x00800000
 *    PFTEMP ------->  |       Empty Memory (*)       |        PTSIZE
 *                     |                              |
 *    UTEMP -------->  +------------------------------+ 0x00400000      --+
 *                     |       Empty Memory (*)       |                   |
 *                     | - - - - - - - - - - - - - - -|                   |
 *                     |  User STAB Data (optional)   |                 PTSIZE
 *    USTABDATA ---->  +------------------------------+ 0x00200000        |
 *                     |       Empty Memory (*)       |                   |
 *    0 ------------>  +------------------------------+                 --+
 *
 * (*) Note: The kernel ensures that "Invalid Memory" is *never* mapped.
 *     "Empty Memory" is normally unmapped, but user programs may map pages
 *     there if desired.  JOS user programs map pages temporarily at UTEMP.
 */


