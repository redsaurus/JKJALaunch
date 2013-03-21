#import "JKJALaunchAppDelegate.h"


NSString * const JKJAJediApplicationPath = @"JediApplicationPath";
NSString * const JKJAJediCommandLine = @"JediCommandLine";
NSString * const JKJAJediOpenGLErrorCheck = @"JediOpenGL";
NSString * const JKJAJediOpenAL = @"JediUseOpenAL";
NSString * const JKJAForce32BitColour = @"JediForce32";

@implementation Untitled3AppDelegate

@synthesize window;
@synthesize launcherButton;
@synthesize launcherString;
@synthesize launcherAppPath;
@synthesize use32BitColourCheckBox;
@synthesize openGLErrorCheckBox;
@synthesize openALCheckBox;
@synthesize launcherCurrentVersionString;
@synthesize launcherAppPathString;
@synthesize commandLineBox;
@synthesize openGLBox;
@synthesize openALBox;
@synthesize saveOptionsCheckBox;
@synthesize openGLTextBox;
@synthesize openALTextBox;
@synthesize disclosureOpenGL;
@synthesize disclosureOpenAL;

+ (void) initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey: JKJAJediOpenGLErrorCheck];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey: JKJAForce32BitColour];
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey: JKJAJediOpenAL];
	[defaultValues setObject:@"" forKey: JKJAJediCommandLine];
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *bundlePath = [bundle bundlePath];
	NSString *curDir = [bundlePath stringByDeletingLastPathComponent];	
	NSString *jampBundlePath = [curDir stringByAppendingString:@"/Jedi Academy MP.app"];	
	[defaultValues setObject:jampBundlePath forKey: JKJAJediApplicationPath];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];	
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	//OK, first of all we look to see if there's Jedi Academy MP.app in the same folder as the launcher AND the current preference is not
	//set to launch an application in the same folder as the launcher
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *bundlePath = [bundle bundlePath];
	NSString *curDir = [bundlePath stringByDeletingLastPathComponent];	
	NSString *jampBundlePath = [curDir stringByAppendingString:@"/Jedi Academy MP.app"];
	NSString *applicationDir = [[[NSUserDefaults standardUserDefaults] objectForKey: JKJAJediApplicationPath] stringByDeletingLastPathComponent];
		
	[self addObserver:self forKeyPath:@"launcherAppPathString" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
	
	[self setValue:jampBundlePath forKey:@"launcherAppPathString"];
	
	//If there is no such Jedi Academy MP.app OR we're set to launch something else
	//in the same folder as the launcher, read from the user preferences
	if (!isValidAppPath || ([curDir compare: applicationDir] == 0))
	{
		[self setValue:[[NSUserDefaults standardUserDefaults] objectForKey: JKJAJediApplicationPath] forKey:@"launcherAppPathString"];
	}
	//Load remaining options from user prefs
	[launcherString setStringValue:[[NSUserDefaults standardUserDefaults] objectForKey: JKJAJediCommandLine]];
	[openGLErrorCheckBox setState:([[[NSUserDefaults standardUserDefaults] objectForKey: JKJAJediOpenGLErrorCheck] boolValue])?NSOnState:NSOffState];
	[use32BitColourCheckBox setState:([[[NSUserDefaults standardUserDefaults] objectForKey: JKJAForce32BitColour] boolValue])?NSOnState:NSOffState];
	[openALCheckBox setState:([[[NSUserDefaults standardUserDefaults] objectForKey: JKJAJediOpenAL] boolValue])?NSOnState:NSOffState];
	
	//Shift on startup or invalid application path brings up the options window
	NSUInteger launchFlags = [NSEvent modifierFlags];
	if ((!isValidAppPath) || (NSShiftKeyMask & launchFlags)){
		[self toggleOpenGLBox: nil];
		[self toggleOpenALBox: nil];
		[disclosureOpenAL setState: NSOffState];
		[disclosureOpenGL setState: NSOffState];
		[window orderFront:self];
	}
	//or we just launch with standard settings
	else {
		[self launchJediAcademy:nil];
	}	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	//works for JKJA, JKII, W:ET
	if ([keyPath compare:@"launcherAppPathString"] == 0){
		NSString *newPath = [change objectForKey:NSKeyValueChangeNewKey];
		jediVersionNumber = [self getVersionNumberFromAppPath: newPath];
			switch(jediVersionNumber){
				case MAC_JKJA_VERSION_ERR:
					isValidAppPath = NO;
					[launcherCurrentVersionString setStringValue:@"Current Version Selected: Invalid"];
					[launcherButton setEnabled:NO];
					break;					
				case MAC_JKJA_VERSION_UNKNOWN:
					isValidAppPath = NO;
					[launcherCurrentVersionString setStringValue:@"Current Version Selected: Unsupported"];
					[launcherButton setEnabled:NO];
					break;
				case MAC_JKJA_VERSION_MP:
					isValidAppPath = YES;
					[launcherButton setEnabled:YES];
					[launcherCurrentVersionString setStringValue:@"Current Version Selected: Jedi Academy MP"];
					break;
				case MAC_JKJA_VERSION_SP:
					isValidAppPath = YES;
					[launcherButton setEnabled:YES];
					[launcherCurrentVersionString setStringValue:@"Current Version Selected: Jedi Academy"];
					break;
				case MAC_JKII_VERSION_SP:
					isValidAppPath = YES;
					[launcherButton setEnabled:YES];
					[launcherCurrentVersionString setStringValue:@"Current Version Selected: Jedi Knight II"];
					break;
				case MAC_JKII_VERSION_MP:
					isValidAppPath = YES;
					[launcherButton setEnabled:YES];
					[launcherCurrentVersionString setStringValue:@"Current Version Selected: Jedi Knight II MP"];
					break;
				case MAC_ET_VERSION_MP:
					isValidAppPath = YES;
					[launcherButton setEnabled:YES];
					[launcherCurrentVersionString setStringValue:@"Current Version Selected: Wolfenstein ET"];
					break;	
				case MAC_ALICE_VERSION_SP:
					isValidAppPath = YES;
					[launcherButton setEnabled:YES];
					[launcherCurrentVersionString setStringValue:@"Current Version Selected: American McGee's Alice™"];
					break;
			}
	}
}

		

- (NSInteger)getVersionNumberFromAppPath:(NSString *)appPath {
	
	NSBundle *jampBundle = [NSBundle bundleWithPath: appPath];
	if (jampBundle == nil){
		return MAC_JKJA_VERSION_ERR;
	}
	
	NSString *jampBundleName = [jampBundle objectForInfoDictionaryKey:@"CFBundleName"];
	if (jampBundleName == nil){
		return MAC_JKJA_VERSION_ERR;
	}
	
	if([jampBundleName compare:@"Wolfenstein ET"] == 0){
		return MAC_ET_VERSION_MP;
	}	
	else if([jampBundleName compare:@"Jedi Knight II"] == 0){
		return MAC_JKII_VERSION_SP;
	}
	else if([jampBundleName compare:@"Jedi Academy"] == 0){
		return MAC_JKJA_VERSION_SP;
	}
	else if([jampBundleName compare:@"Jedi Knight II MP"] == 0){
		return MAC_JKII_VERSION_MP;
	}	
	else if([jampBundleName compare:@"Jedi Academy MP"] == 0){
		return MAC_JKJA_VERSION_MP;
	}
	else if([jampBundleName compare:@"American McGee's Alice™"] == 0){
		return MAC_ALICE_VERSION_SP;
	}
	else {
		return MAC_JKJA_VERSION_UNKNOWN;
	}
}
		
- (IBAction) toggleOpenGLBox:(id)sender {
	NSRect windowFrame = [[openGLBox window] frame];
	[openGLBox setAutoresizingMask:NSViewMinYMargin];
	[openGLTextBox setAutoresizingMask:NSViewMinYMargin];
	[openALBox setAutoresizingMask:NSViewMaxYMargin];
	[openALTextBox setAutoresizingMask:NSViewMaxYMargin];	
	if ([openGLBox isHidden])
	{
		windowFrame.size.height += 40;
		windowFrame.origin.y -= 40;
		[[openGLBox window] setFrame: windowFrame display:YES animate:YES];	
		[openGLBox setHidden:NO];
	}
	else {
		[openGLBox setHidden:YES];
		windowFrame.size.height -= 40;
		windowFrame.origin.y += 40;
		[[openGLBox window] setFrame: windowFrame display:YES animate:YES];			
	}
}

- (IBAction) toggleOpenALBox:(id)sender {
	NSRect windowFrame = [[openALBox window] frame];
	[openGLBox setAutoresizingMask:NSViewMinYMargin];
	[openGLTextBox setAutoresizingMask:NSViewMinYMargin];
	[openALBox setAutoresizingMask:NSViewMinYMargin];
	[openALTextBox setAutoresizingMask:NSViewMinYMargin];
	if ([openALBox isHidden])
	{
		windowFrame.size.height += 25;
		windowFrame.origin.y -= 25;
		[[openALBox window] setFrame: windowFrame display:YES animate:YES];	
		[openALBox setHidden:NO];
	}
	else {
		[openALBox setHidden:YES];
		windowFrame.size.height -= 25;
		windowFrame.origin.y += 25;
		[[openALBox window] setFrame: windowFrame display:YES animate:YES];			
	}
}

- (IBAction) toggleCommandLineBox:(id)sender{
	NSRect windowFrame = [[commandLineBox window] frame];
	[openGLBox setAutoresizingMask:NSViewMaxYMargin];
	[openGLTextBox setAutoresizingMask:NSViewMaxYMargin];
	[openALBox setAutoresizingMask:NSViewMaxYMargin];
	[openALTextBox setAutoresizingMask:NSViewMaxYMargin];
	if ([commandLineBox isHidden])
	{
		windowFrame.size.height += 25;
		windowFrame.origin.y -= 25;
		[[commandLineBox window] setFrame: windowFrame display:YES animate:YES];	
		[commandLineBox setHidden:NO];
	}
	else {
		[commandLineBox setHidden:YES];
		windowFrame.size.height -= 25;
		windowFrame.origin.y += 25;
		[[commandLineBox window] setFrame: windowFrame display:YES animate:YES];			
	}
}

- (IBAction)launchJediAcademy:(id)sender {
	NSString *launchString = launcherAppPathString;
	NSString *argsNSString = @"";
	
	NSDictionary *environmentOptions;
	//insert OpenGL dylib that ignores ATI FSAA calls
	if ([openGLErrorCheckBox state] == NSOnState){
		environmentOptions = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@/Contents/Resources/libAGLRedirect.dylib", [[NSBundle mainBundle] bundlePath]] forKey:@"DYLD_INSERT_LIBRARIES"];
	}
	else{
		environmentOptions = [NSDictionary dictionaryWithObject:@"" forKey:@"DYLD_INSERT_LIBRARIES"];
	}	
	
	if ([use32BitColourCheckBox state] == NSOnState){
		argsNSString = [argsNSString stringByAppendingString:@"+set r_colorbits 32 "];
	}
	
	if ([openALCheckBox state] == NSOnState){
		argsNSString = [argsNSString stringByAppendingString:@"+set s_useOpenAL 1 "];
	}
	else{
		argsNSString = [argsNSString stringByAppendingString:@"+set s_useOpenAL 0 "];
	}
		
	argsNSString = [argsNSString stringByAppendingString:[launcherString stringValue]];
	
	if ([openALCheckBox state] == NSOnState){
		argsNSString = [argsNSString stringByAppendingString:@" +snd_restart"]; //needed in Lion to avoid massive slowdown
	}	
	
	const char *argsCString = [argsNSString cString];
	
	//here is AppleEvent stuff that passes the command line
	NSAppleEventDescriptor *launchAppDescriptor = [NSAppleEventDescriptor descriptorWithString: launchString];
	
	NSAppleEventDescriptor *launchDescriptor = [NSAppleEventDescriptor appleEventWithEventClass:'aevt' eventID:'oapp' targetDescriptor:launchAppDescriptor returnID:kAutoGenerateReturnID transactionID:kAnyTransactionID];
	
	NSAppleEventDescriptor *launchArgsDescriptor = [NSAppleEventDescriptor descriptorWithDescriptorType: typeChar bytes:argsCString length:strlen(argsCString)];
	[launchDescriptor setDescriptor:launchArgsDescriptor forKeyword:'CLin'];
		
	NSDictionary *launchOptions = [NSDictionary dictionaryWithObjectsAndKeys:launchDescriptor,@"NSWorkspaceLaunchConfigurationAppleEvent",environmentOptions,@"NSWorkspaceLaunchConfigurationEnvironment",nil];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithString:launchString] forKey:JKJAJediApplicationPath];
	if ([saveOptionsCheckBox state] == NSOnState)
	{
		[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithString:[launcherString stringValue]] forKey:JKJAJediCommandLine];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:([use32BitColourCheckBox state] == NSOnState)?YES:NO] forKey:JKJAForce32BitColour];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:([openGLErrorCheckBox state] == NSOnState)?YES:NO] forKey:JKJAJediOpenGLErrorCheck];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:([openALCheckBox state] == NSOnState)?YES:NO] forKey:JKJAJediOpenAL];
	}
	//now launch!
	[[NSWorkspace sharedWorkspace] launchApplicationAtURL:[NSURL URLWithString:[launchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
												  options:NSWorkspaceLaunchDefault 
											configuration:launchOptions 
													error:nil];	
	[NSTimer scheduledTimerWithTimeInterval:0.2f target:NSApp selector:@selector(terminate:) userInfo:nil repeats:NO];
}

- (IBAction) selectAppPath:(id)sender
{
	NSOpenPanel *selectApp = [NSOpenPanel openPanel];
	[selectApp setAllowsMultipleSelection:NO];
	[selectApp setPrompt:@"OK"];
	[selectApp setTitle:@"Select \"Jedi Academy MP\""];
	
	[selectApp runModal];
	NSArray *apps = [selectApp filenames];
	NSString *selectedAppPath = [apps objectAtIndex:0];
	if (selectedAppPath != nil){
		[self setValue:selectedAppPath forKey:@"launcherAppPathString"];
	}
}

@end
