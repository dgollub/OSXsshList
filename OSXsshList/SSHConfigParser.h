//
//  SSHConfigParser.h
//  OSXsshList
//
//  Created by 倉重ゴルプ　ダニエル on 2015/10/22.
//  Copyright © 2015年 Daniel Kurashige-Gollub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSHConfigParser : NSObject

- (NSArray *)getConnectionList;

@end

@interface SSHConfigItem : NSObject

@property (nonatomic, assign) int index;
@property (nonatomic, assign) BOOL isValidEntry;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *other;

- (NSString *)getAsCommandLineCommand;

@end
