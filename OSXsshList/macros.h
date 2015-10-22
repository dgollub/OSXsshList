//
//  macros.h
//  OSXsshList
//
//  Created by 倉重ゴルプ　ダニエル on 2015/10/22.
//  Copyright © 2015年 Daniel Kurashige-Gollub. All rights reserved.
//

#ifndef macros_h
#define macros_h

#import <Foundation/Foundation.h>


#define RANDOM_INT(n) (arc4random_uniform(n+1))
#define mustOverride() @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__] userInfo:nil]
#define methodNotImplemented() mustOverride()
#define NSS_FUNC [NSString stringWithCString:__PRETTY_FUNCTION__ encoding:[NSString defaultCStringEncoding]]




#ifdef DEBUG


#define LOG_FUNC NSLog(@"%@", NSS_FUNC)
#define LOG(...) NSLog(@"%@ %@", NSS_FUNC, [NSString stringWithFormat:__VA_ARGS__])


#else // DEBUG

#define LOG_FUNC
#define LOG(...)


#endif // DEBUG

#endif /* macros_h */
