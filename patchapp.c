//The current Steam and App Store versions of Jedi Academy do
//not allow you to join servers for which you are missing pk3s,
//even if they are not really necessary. This patches the file
//so that you can connect to such servers.

#include <mach/mach_vm.h>

#define ATI_FSAA_SAMPLES 510

__attribute__ ((constructor)) void whichProgram( void )
{
	int patchLocation = 0x3db33;
	
	const char *progname = getprogname();
	
	printf("%s\n", progname);
	
	if (strcasecmp(progname, "Jedi Academy MP") == 0)
	{
		mach_vm_protect(mach_task_self(), patchLocation, 2, 0, VM_PROT_WRITE | VM_PROT_EXECUTE | VM_PROT_READ);
		*(char *)patchLocation = 0x90;
		*(char *)(patchLocation+1) = 0x90;
		mach_vm_protect(mach_task_self(), patchLocation, 2, 0, VM_PROT_EXECUTE | VM_PROT_READ);
	}
}