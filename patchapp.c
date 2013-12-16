//The current Steam and App Store versions of Jedi Academy do
//not allow you to join servers for which you are missing pk3s,
//even if they are not really necessary. This patches the file
//so that you can connect to such servers.

#include <mach/mach_vm.h>
#include <CoreFoundation/CoreFoundation.h>
#include <Security/Security.h>

__attribute__ ((constructor)) void whichProgram( void )
{
	
	unsigned char isMPText[3];
	
	int isMP = 0;
	
	int patchLocation = 0x3db33;
	
	const char *progname = getprogname();
		
	if (strcasecmp(progname, "Jedi Academy MP") == 0)
	{
		mach_vm_protect(mach_task_self(), patchLocation, 2, 0, VM_PROT_WRITE | VM_PROT_EXECUTE | VM_PROT_READ);
		*(char *)patchLocation = 0x90;
		*(char *)(patchLocation+1) = 0x90;
		mach_vm_protect(mach_task_self(), patchLocation, 2, 0, VM_PROT_EXECUTE | VM_PROT_READ);
	}
	
	strncpy(isMPText, getenv("ASPYR_JAMP"), 3);
	isMP = strncasecmp(isMPText, "NO", 3);
	
	//check if we're in a sandbox :/ then mess around with prefs a bit
	//hacked together with stuff from https://github.com/ole/NSBundle-OBCodeSigningInfo
	static SecRequirementRef sandboxRequirement = NULL;
	SecRequirementCreateWithString(CFSTR("entitlement[\"com.apple.security.app-sandbox\"] exists"), kSecCSDefaultFlags, &sandboxRequirement);
	
	SecCodeRef *staticCode;
	SecCodeCopySelf(kSecCSDefaultFlags, &staticCode);
	OSStatus codeCheckResult = SecStaticCodeCheckValidityWithErrors(staticCode, kSecCSBasicValidateOnly, sandboxRequirement, NULL);

	if (codeCheckResult == errSecSuccess){
		if (strcasecmp(progname, "SWJKJA") == 0)
		{
			if (isMP)
			{
				CFPreferencesSetAppValue(CFSTR("DefaultChildApp"), CFSTR("Jedi Academy MP"), CFSTR("com.aspyr.jediacademy.appstore"));
			}
			else
			{
				CFPreferencesSetAppValue(CFSTR("DefaultChildApp"), CFSTR("Jedi Academy"), CFSTR("com.aspyr.jediacademy.appstore"));
			}
			CFPreferencesSetAppValue(CFSTR("DoNotShowGameGuide"), kCFBooleanTrue, CFSTR("com.aspyr.jediacademy.appstore"));
		}
		else
		{
			CFPreferencesSetAppValue(CFSTR("DefaultChildApp"), NULL, CFSTR("com.aspyr.jediacademy.appstore"));
			CFPreferencesSetAppValue(CFSTR("DoNotShowGameGuide"), NULL, CFSTR("com.aspyr.jediacademy.appstore"));
		}
	}
}