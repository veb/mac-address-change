//
//  AppDelegate.m
//  MacAddressSwitcher
//
//  Created by Ray Arvin Rimorin on 7/11/14.
//  Copyright (c) 2014 veb.co.nz. All rights reserved.
//

#import "AppDelegate.h"
@import SystemConfiguration;


@interface AppDelegate ()
@property (nonatomic, strong) NSMutableArray *interfaces;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}


- (void)awakeFromNib {
    [self initInterfaces];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@"MACSwitcher"];

//    [self.statusItem setImage:icon];
//    [self.statusItem setAlternateImage:hilighticon];
    [self.statusItem setHighlightMode:YES];
    
    
    NSMenu *menu = [[NSMenu alloc] init];

    [menu addItemWithTitle:@"Generate new address" action:nil keyEquivalent:@""];

    [menu addItem:[NSMenuItem separatorItem]];
    for (Interface *interface in self.interfaces) {
        NSMenuItem *item = [NSMenuItem new];
        [item setRepresentedObject:interface];
        [item setTitle:interface.displayName];
        [item setAction:@selector(switchMacAddress:)];
        [menu addItem:item];
    }
    
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:@"Quit Switcher" action:@selector(terminate:) keyEquivalent:@""];

    _statusItem.menu = menu;

    
}

- (void)initInterfaces {
    NSArray *cfinterfaces = (__bridge NSArray *)SCNetworkInterfaceCopyAll();
    
    self.interfaces = [NSMutableArray array];
    
    for (int i=0; i<cfinterfaces.count; i++) {
        NSString *interfaceBSDName = (__bridge NSString *)SCNetworkInterfaceGetBSDName((__bridge SCNetworkInterfaceRef)(cfinterfaces[i]));
        
        NSString *interfaceDisplayName = (__bridge NSString *)SCNetworkInterfaceGetLocalizedDisplayName((__bridge SCNetworkInterfaceRef)(cfinterfaces[i]));
        
        Interface *interface = [Interface new];
        interface.BSDName= interfaceBSDName;
        interface.displayName = interfaceDisplayName;
        [self.interfaces addObject:interface];
        
        NSLog(@"%@: %@", interfaceBSDName, interfaceDisplayName);
    }
}

- (void)switchMacAddress:(id)sender {
    NSString * output = nil;
    NSString * processErrorDescription = nil;
    
    Interface *interface = [sender representedObject];
    BOOL success = [self runProcessAsAdministrator:[[NSBundle mainBundle] pathForResource:@"spoof" ofType:@".sh"]
                      withArguments:@[interface.BSDName]
                             output:&output
                   errorDescription:&processErrorDescription];
    
    NSString *message = success?output:processErrorDescription;
    
    [[NSAlert alertWithMessageText:@"Results"
                     defaultButton:@"OK"
                   alternateButton:nil
                       otherButton:nil
         informativeTextWithFormat:message] runModal];
    
    return;
}


- (BOOL) runProcessAsAdministrator:(NSString*)scriptPath
                     withArguments:(NSArray *)arguments
                            output:(NSString **)output
                  errorDescription:(NSString **)errorDescription {
    
    NSString * allArgs = [arguments componentsJoinedByString:@" "];
    NSString * fullScript = [NSString stringWithFormat:@"%@ %@", scriptPath, allArgs];
    
    NSDictionary *errorInfo = [NSDictionary new];
    NSString *script =  [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", fullScript];
    
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    NSAppleEventDescriptor * eventResult = [appleScript executeAndReturnError:&errorInfo];
    
    // Check errorInfo
    if (! eventResult)
    {
        // Describe common errors
        *errorDescription = nil;
        if ([errorInfo valueForKey:NSAppleScriptErrorNumber])
        {
            NSNumber * errorNumber = (NSNumber *)[errorInfo valueForKey:NSAppleScriptErrorNumber];
            if ([errorNumber intValue] == -128)
                *errorDescription = @"The administrator password is required to do this.";
        }
        
        // Set error message from provided message
        if (*errorDescription == nil)
        {
            if ([errorInfo valueForKey:NSAppleScriptErrorMessage])
                *errorDescription =  (NSString *)[errorInfo valueForKey:NSAppleScriptErrorMessage];
        }
        
        return NO;
    }
    else
    {
        // Set output to the AppleScript's output
        *output = [eventResult stringValue];
        
        return YES;
    }
}
@end

@implementation Interface

@end