//
//  AppDelegate.h
//  MacAddressSwitcher
//
//  Created by Ray Arvin Rimorin on 7/11/14.
//  Copyright (c) 2014 veb.co.nz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMenu *statusMenu;

- (void)switchMacAddress:(id)sender;
@end

@interface Interface : NSObject
@property (strong, nonatomic) NSString *BSDName;
@property (strong, nonatomic) NSString *displayName;


@end
