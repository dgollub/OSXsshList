//
//  SSHConfigParser.m
//  OSXsshList
//
//  Created by 倉重ゴルプ　ダニエル on 2015/10/22.
//  Copyright © 2015年 Daniel Kurashige-Gollub. All rights reserved.
//

#import "SSHConfigParser.h"
#import "macros.h"

@implementation SSHConfigParser

- (NSArray *)getConnectionList
{
    LOG_FUNC;
    
    NSMutableArray *list = [NSMutableArray new];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *sshConfigFile = [@"~/.ssh/config" stringByExpandingTildeInPath];
    
    if ([fm fileExistsAtPath:sshConfigFile]) {

        NSError *error;
        NSString *contents = [NSString stringWithContentsOfFile:sshConfigFile
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
        if (error) {
            LOG(@"Could nto read SSH config file contents. Reason: %@", [error description]);
            
            SSHConfigItem *item = [SSHConfigItem new];
            
            item.isValidEntry = NO;
            item.host = @"Could not read contents from ~/.ssh/config.";
            
            [list addObject:item];
            
        } else {

            NSArray *items = [self parseConfigFileContent:contents];

            if (items.count == 0) {
                SSHConfigItem *item = [SSHConfigItem new];
                
                item.isValidEntry = NO;
                item.host = @"No entries found in ~/.ssh/config.";
                
                [list addObject:item];
                
            } else {
                [list addObjectsFromArray:items];
            }
        }
        
    } else {
        
        SSHConfigItem *item = [SSHConfigItem new];
        
        item.isValidEntry = NO;
        item.host = @"No ~/.ssh/config file.";
        
        [list addObject:item];
    }
    
    return (NSArray *)list;
}

- (NSArray *)parseConfigFileContent:(NSString *)content
{
    LOG_FUNC;
    
    NSMutableArray *list = [NSMutableArray new];
    
    NSArray *lines = [content componentsSeparatedByString:@"\n"];
    
    SSHConfigItem *item;

    for (NSString *orgLine in lines) {
        
        NSString *line = [orgLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // Ignore empty lines and comments
        if (line.length == 0 || [[line substringToIndex:1] isEqualToString:@"#"])
            continue;
        
        NSString *lower = [line lowercaseString];
        NSArray *tokens = [self parseForTokens:line
                              withCharacterSet:[NSCharacterSet whitespaceCharacterSet]];

        if (tokens.count < 2) {
            tokens = [self parseForTokens:line
                         withCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
            if (tokens.count < 2) {
                LOG(@"Could not parse line: %@", line);
                continue;
            }
        }

        BOOL isHostName = [[lower substringToIndex:8] isEqualToString:@"hostname"];
        
        // If we have a "Host" line, we start a new item.
        if ([[lower substringToIndex:4] isEqualToString:@"host"] && !isHostName) {
        
            if (item) {
                [list addObject:item];
            }
            
            item = [SSHConfigItem new];
            item.isValidEntry = YES;
//            item.index = (int)list.count;
            item.name = [tokens objectAtIndex:1];
            
        } else {
            // we got some option for the entry, parse them
            if (isHostName) {
                item.host = [tokens objectAtIndex:1];
            } else if ([[lower substringToIndex:4] isEqualToString:@"user"]) {
                item.user = [tokens objectAtIndex:1];
            }
        }
    }
    
    if (item) {
        [list addObject:item];
    }

    // sort the list by entry title
    [list sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *nameA = ((SSHConfigItem *)obj1).name;
        NSString *nameB = ((SSHConfigItem *)obj2).name;
        return [nameA compare:nameB];
    }];
    
    // reassign the correct index
    int idx = 0;
    for (SSHConfigItem *item in list) {
        item.index = idx++;
    }
    
    return (NSArray *)list;
}

- (NSArray *)parseForTokens:(NSString *)line withCharacterSet:(NSCharacterSet *)charset
{
    NSArray *tokens = [[line componentsSeparatedByCharactersInSet:charset]
                       filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSString *token = [((NSString *)evaluatedObject) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        return token.length > 0;
    }]];
    
    return tokens;
}


@end // SSHConfigParser




@implementation SSHConfigItem

#pragma mark - public
- (NSString *)getAsCommandLineCommand
{
//    LOG_FUNC;
    
    if (!self.isValidEntry)
        return nil;
    
    if ([self.name isEqualToString:@"*"])
        return nil;
    
    NSString *ssh = [NSString stringWithFormat:@"ssh %@", self.name];
    NSString *cmd = [NSString stringWithFormat:@"osascript -e 'tell application \"Terminal\" to do script \"%@\"'", ssh];
    
    return cmd;
}

- (NSString *)getMenuTitle
{
//    LOG_FUNC;
    if (self.user && self.user.length > 0) {
        return [NSString stringWithFormat:@"%@ (%@@%@)", self.name, self.user, self.host];
    } else {
        return [NSString stringWithFormat:@"%@ (%@)", self.name, self.host];
    }
}

#pragma mark - overwrites

- (NSString *)description
{
    return [NSString
                stringWithFormat:@"Name:\t%@\nHost:\t%@",
                self.name,
                self.host];
}

@end // SSHConfigItem
