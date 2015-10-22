//
//  AppDelegate.m
//  OSXsshList
//
//  Created by 倉重ゴルプ　ダニエル on 2015/10/22.
//  Copyright © 2015年 Daniel Kurashige-Gollub. All rights reserved.
//

#import "AppDelegate.h"

#import "macros.h"

#import "NSMenuItem+Index.h"
#import "SSHConfigParser.h"


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (strong, nonatomic) NSStatusItem *statusItem;

@end

@implementation AppDelegate
{
    NSArray *listOfSshEntries;
}

#pragma mark - application life-cycle
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    LOG_FUNC;
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.image = [NSImage imageNamed:@"tower-black-16"];
    
    [self refreshListOfSshEntries];
    
    _statusItem.menu = [self updateMenuEntries];
    
    [_statusItem setAction:@selector(itemClicked:)]; // TODO(dkg): somehow this is never firing when a user clicks on it???
    [_statusItem.button setAction:@selector(itemClicked:)]; // TODO(dkg): somehow this is never firing when a user clicks on it?
    
    // To fix the above ...
    NSClickGestureRecognizer *clicked = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(itemClicked:)];
    clicked.numberOfClicksRequired = 1;
    [_statusItem.button addGestureRecognizer:clicked];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    LOG_FUNC;
}


#pragma mark - menu handling
- (NSMenu *)updateMenuEntries
{
    LOG_FUNC;
    
    NSMenu *mainMenu = [[NSMenu alloc] initWithTitle:@"OSX ssh List"];
    
    [mainMenu addItemWithTitle:@"Edit ~/.ssh/cconfig"
                        action:@selector(menuEditConfig:)
                 keyEquivalent:@"e"];

    [mainMenu addItem:[NSMenuItem separatorItem]];
    
    for (SSHConfigItem *item in listOfSshEntries) {
        if ([item.name isEqualToString:@"*"]) {
            // Just don't display the general settings one.
//            [mainMenu addItem:[NSMenuItem separatorItem]];
        } else {
            NSMenuItem *menuItem = [mainMenu addItemWithTitle:item.name
                                                       action:@selector(menuClicked:)
                                                keyEquivalent:@""];
            menuItem.index = @(item.index);
        }
    }

    [mainMenu addItem:[NSMenuItem separatorItem]];
    
    [mainMenu addItemWithTitle:@"Refresh from ~/.ssh/cconfig"
                        action:@selector(menuRefresh:)
                 keyEquivalent:@"r"];
    
    return mainMenu;
}

- (void)refreshListOfSshEntries
{
    LOG_FUNC;
    
    SSHConfigParser *sshConfig = [SSHConfigParser new];

    listOfSshEntries = [sshConfig getConnectionList];
}

- (void)refreshListAndupdateMenuEntries
{
    LOG_FUNC;
    
    [self refreshListOfSshEntries];
    
    // We can be called from a background thread, so make sure UI stuff happens
    // on the main thread.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _statusItem.menu = [self updateMenuEntries];
    });
}

#pragma mark - actions
- (void)itemClicked:(id)sender
{
    LOG_FUNC;

    [self performSelectorInBackground:@selector(refreshListAndupdateMenuEntries) withObject:nil];
    
    [_statusItem popUpStatusItemMenu:_statusItem.menu];
}

- (void)menuRefresh:(id)sender
{
    LOG_FUNC;
    
    [self performSelectorInBackground:@selector(refreshListAndupdateMenuEntries) withObject:nil];

    [_statusItem popUpStatusItemMenu:_statusItem.menu];
}

- (void)menuClicked:(id)sender
{
    NSMenuItem *menuItem = (NSMenuItem *)sender;
    NSNumber *index = [menuItem index];
    
    SSHConfigItem *item = (SSHConfigItem *)[listOfSshEntries objectAtIndex:[index intValue]];
    
    LOG(@"User clicked on configuration for: %@", [item description]);
    
    NSString *command = [item getAsCommandLineCommand];
    
    system([command UTF8String]);
}

- (void)menuEditConfig:(id)sender
{
    LOG_FUNC;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *sshConfigFile = [@"~/.ssh/config" stringByExpandingTildeInPath];
    NSString *sshFolder = [sshConfigFile stringByDeletingLastPathComponent];
    
    if (![fm fileExistsAtPath:sshFolder]) {
        NSError *error;
        
        [fm createDirectoryAtPath:sshFolder
      withIntermediateDirectories:YES
                       attributes:nil
                            error:&error];
        if (error) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Error"
                                             defaultButton:@"Ok"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"Could not create ~/.ssh/ folder.\nReason: %@", [error description]];
            [alert runModal];
            return;
        }
    }
    
    NSString *command = [NSString stringWithFormat:@"open -e %@", sshConfigFile];

    system([command UTF8String]);
}

@end
