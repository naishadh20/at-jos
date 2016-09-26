///////////////////////////////////////////////////////////////////////////////////////////////////////////
		pgdir_walk
///////////////////////////////////////////////////////////////////////////////////////////////////////////

//Input Arguments: pointer to the page directory, pointer to va, create flag 
//Returns: Pointer to the page table entry


// Given 'pgdir', a pointer to a page directory, pgdir_walk returns
// a pointer to the page table entry (PTE) for linear address 'va'.
// This requires walking the two-level page table structure.
//
// The relevant page table page might not exist yet.
// If this is true, and create == false, then pgdir_walk returns NULL.
// Otherwise, pgdir_walk allocates a new page table page with page_alloc.
//    - If the allocation fails, pgdir_walk returns NULL.
//    - Otherwise, the new page's reference count is incremented,
//	the page is cleared,
//	and pgdir_walk returns a pointer into the new page table page.
//
// Hint 1: you can turn a Page * into the physical address of the
// page it refers to with page2pa() from kern/pmap.h.
//
// Hint 2: the x86 MMU checks permission bits in both the page directory
// and the page table, so it's safe to leave permissions in the page
// directory more permissive than strictly necessary.
//
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//

pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
int dir_idx = PDX(va);
int tab_idx =  PTX(va);
pte_t *page_tbl_entry;
struct PageInfo *page_dir;

if(!(pgdir[dir_idx] & PTE_P)) //if relevant page table doesn't exist
{
	if (create !=0 )
	{
	page_dir = page_alloc(ALLOC_ZERO);//allocates a page filled with zeroes, clears pages.
		if(!page_dir) //if allocation fails
		{
		cprintf ("allocation failed\n");
		return NULL;
		}
	page_dir->pp_ref++;//the new page's reference count is incremented
        pgdir[dir_idx] = page2pa(page_dir) | PTE_P | PTE_U | PTE_W; 
	}
	else
	return NULL;
}
	page_tbl_entry = KADDR(PTE_ADDR(pgdir[dir_idx]));//kernel virtual address of page table entry address.
        return page_tbl_entry+tab_idx;
}

////////////////////////////////////////////////////////
	PDX(va) & PTX(va) ---> mmu.h		
////////////////////////////////////////////////////////
// A linear address 'la' has a three-part structure as follows:
//
// +--------10------+-------10-------+---------12----------+
// | Page Directory |   Page Table   | Offset within Page  |
// |      Index     |      Index     |                     |
// +----------------+----------------+---------------------+
//  \--- PDX(la) --/ \--- PTX(la) --/ \---- PGOFF(la) ----/
//  \---------- PGNUM(la) ----------/
//
// The PDX, PTX, PGOFF, and PGNUM macros decompose linear addresses as shown.
// To construct a linear address la from PDX(la), PTX(la), and PGOFF(la),
// use PGADDR(PDX(la), PTX(la), PGOFF(la)).
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

//
// Map [va, va+size) of virtual address space to physical [pa, pa+size)
// in the page table rooted at pgdir.  Size is a multiple of PGSIZE, and
// va and pa are both page-aligned.
// Use permission bits perm|PTE_P for the entries.
//
// This function is only intended to set up the ``static'' mappings
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk

static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
int total_pages = size/PGSIZE;// total no. of pages to be mapped.
for(int i=0;i<total_pages;i++)
{
pde_t* new_page_table_entry = pgdir_walk(pgdir, (void*) va, 1);//gets the address of the page table entry
if(!new_page_table_entry)
cprintf("Allocation failed");
*new_page_table_entry = pa | (perm | PTE_P);// puts the physical address in that page table entry.
va= va+PGSIZE;
pa= pa+PGSIZE;
}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
	page_lookup
///////////////////////////////////////////////////////////////////////////////////////////////////////////

//Input Arguments: pointer to the page directory, pointer to va, size, ** to store page table entry 
//Returns: page (struct PageInfo)

//
// Return the page mapped at virtual address 'va'.
// If pte_store is not zero, then we store in it the address
// of the pte for this page.  This is used by page_remove and
// can be used to verify page permissions for syscall arguments,
// but should not be used by most callers.
//
// Return NULL if there is no page mapped at va.
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//

struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{

	pte_t *page_table_entry;
	page_table_entry =  pgdir_walk(pgdir, va, 0);
		if (!page_table_entry || !(*page_table_entry & PTE_P)) //if null address of the page table entry or if no page mapped at that va 
		{
		cprintf("unable to find page\n");
		return NULL;
		}
		if(pte_store != NULL)
		{
		*pte_store = page_table_entry;// store in pte_store the address of the looked up page
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

//
// Unmaps the physical page at virtual address 'va'.
// If there is no physical page at that address, silently does nothing.
//
// Details:
//   - The ref count on the physical page should decrement.
//   - The physical page should be freed if the refcount reaches 0.
//   - The pg table entry corresponding to 'va' should be set to 0.
//     (if such a PTE exists)
//   - The TLB must be invalidated if you remove an entry from
//     the page table.
//
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//

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
	 page_decref(page_found); //The ref count on the physical page should decrement.
                             //The physical page should be freed if the refcount reaches 0.
	*page_tbl_entry = 0; //pg table entry corresponding to 'va' should be set to 0.
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
//
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
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

//
// Map the physical page 'pp' at virtual address 'va'.
// The permissions (the low 12 bits) of the page table entry
// should be set to 'perm|PTE_P'.
//
// Requirements
//   - If there is already a page mapped at 'va', it should be page_remove()d.
//   - If necessary, on demand, a page table should be allocated and inserted
//     into 'pgdir'.
//   - pp->pp_ref should be incremented if the insertion succeeds.
//   - The TLB must be invalidated if a page was formerly present at 'va'.
//
// Corner-case hint: Make sure to consider what happens when the same
// pp is re-inserted at the same virtual address in the same pgdir.
// However, try not to distinguish this case in your code, as this
// frequently leads to subtle bugs; there's an elegant way to handle
// everything in one code path.
//
// RETURNS:
//   0 on success
//   -E_NO_MEM, if page table couldn't be allocated
//
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *page_tbl_entry;
	 page_tbl_entry= pgdir_walk(pgdir, va, 1);//Page is always created and pte pointer is returned
	if(! page_tbl_entry)// if page table could not be allocated.
		{
		cprintf("Unable to find the page\n");
		return -E_NO_MEM;
		}
	 pp->pp_ref++;//increment the reference counter before hand as in page_remove the pointer is decremented. So, ppref may reach                     
	//zero,page might be freed before being mapped.
	if (*page_tbl_entry & PTE_P)//if mapped to physical page
	{
	cprintf("Page removed\n");
	page_remove(pgdir, va); //decrement ref pointer, clear the page table entry and invalidate tlb.
	}
*page_tbl_entry = page2pa(pp) | perm | PTE_P;//assign the new physical address of the page pp to pte.
return 0;//success
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


