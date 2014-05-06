//The current Steam and App Store versions of Jedi Academy do
//not allow you to join servers for which you are missing pk3s,
//even if they are not really necessary. This patches the file
//so that you can connect to such servers.

#include <mach/mach_vm.h>
#include <mach/mach_init.h>
#include <CoreFoundation/CoreFoundation.h>
#include <Security/Security.h>

__attribute__ ((constructor)) void whichProgram( void )
{
	
	char isMPText[3];
	char isASText[3];
	char *envText;
	
	int isMP = 0;
	int isJK2AppStore = 0;
	
	int jampPatchLocation = 0x3db33;
	int jk2mpPatchLocation = 0x117eb;
	int jk2mpPatchLocationAS = 0x115cf;
	
	const char *progname = getprogname();
		
	if (strcasecmp(progname, "Jedi Academy MP") == 0)
	{
		mach_vm_protect(mach_task_self(), jampPatchLocation, 2, 0, VM_PROT_WRITE | VM_PROT_EXECUTE | VM_PROT_READ);
		*(char *)jampPatchLocation = 0x90;
		*(char *)(jampPatchLocation+1) = 0x90;
		mach_vm_protect(mach_task_self(), jampPatchLocation, 2, 0, VM_PROT_EXECUTE | VM_PROT_READ);
	}
	else if(strcasecmp(progname, "Jedi Knight II MP") == 0)
	{
		envText = getenv("ASPYR_JKII_AS");
		if (envText != NULL)
		{
			strncpy(isASText, envText, 3);
			isJK2AppStore = (strncasecmp(isASText, "YS", 3) == 0);
			if (isJK2AppStore)
			{
				jk2mpPatchLocation = jk2mpPatchLocationAS;
			}
		}
		mach_vm_protect(mach_task_self(), jk2mpPatchLocation, 2, 0, VM_PROT_WRITE | VM_PROT_EXECUTE | VM_PROT_READ);
		*(char *)jk2mpPatchLocation = 0xEB;
		mach_vm_protect(mach_task_self(), jk2mpPatchLocation, 2, 0, VM_PROT_EXECUTE | VM_PROT_READ);
		return;
	}
	
	envText = getenv("ASPYR_JAMP");
	
	if (envText != NULL)
	{
		strncpy(isMPText, envText, 3);
		isMP = strncasecmp(isMPText, "NO", 3);
	}
	
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