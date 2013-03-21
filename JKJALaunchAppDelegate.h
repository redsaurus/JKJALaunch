#import <Cocoa/Cocoa.h>

extern NSString * const JKJAJediApplicationPath;
extern NSString * const JKJAJediCommandLine;
extern NSString * const JKJAJediOpenGLErrorCheck;
extern NSString * const JKJAJediOpenAL;
extern NSString * const JKJAForce32BitColour;

@interface Untitled3AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSBox *commandLineBox;
	NSBox *openGLBox;
	NSBox *openALBox;
	NSButton *launcherButton;
	NSTextField *launcherString;
	NSTextField *launcherAppPath;
	NSButton *openGLErrorCheckBox;
	NSButton *use32BitColourCheckBox;
	NSButton *openALCheckBox;
	NSTextField *launcherCurrentVersionString;
	NSString *launcherAppPathString;
	NSInteger jediVersionNumber;
	NSButton *saveOptionsCheckBox;
	NSBox *openGLTextBox;
	NSBox *openALTextBox;
	NSButton *disclosureOpenGL;
	NSButton *disclosureOpenAL;
	BOOL isValidAppPath;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSButton *launcherButton;
@property (assign) IBOutlet NSTextField *launcherString;
@property (assign) IBOutlet NSTextField *launcherAppPath;
@property (assign) IBOutlet NSButton *openGLErrorCheckBox;
@property (assign) IBOutlet NSButton *use32BitColourCheckBox;
@property (assign) IBOutlet NSButton *openALCheckBox;
@property (assign) IBOutlet NSTextField *launcherCurrentVersionString;
@property (assign) IBOutlet NSString *launcherAppPathString;
@property (assign) IBOutlet NSBox *commandLineBox;
@property (assign) IBOutlet NSBox *openGLBox;
@property (assign) IBOutlet NSBox *openALBox;
@property (assign) IBOutlet NSButton *saveOptionsCheckBox;
@property (assign) IBOutlet NSBox *openGLTextBox;
@property (assign) IBOutlet NSBox *openALTextBox;
@property (assign) IBOutlet NSButton *disclosureOpenGL;
@property (assign) IBOutlet NSButton *disclosureOpenAL;


- (IBAction) launchJediAcademy:(id)sender;
- (NSInteger)getVersionNumberFromAppPath:(NSString *)appPath;
- (void) setLauncherAppPath:(NSTextField *)textField;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
- (IBAction) selectAppPath:(id)sender;
- (IBAction) toggleOpenGLBox:(id)sender;
- (IBAction) toggleOpenALBox:(id)sender;
- (IBAction) toggleCommandLineBox:(id)sender;


@end
