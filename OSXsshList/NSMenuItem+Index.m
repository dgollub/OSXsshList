//
//  NSMenuItem+Index.m
//  OSXsshList
//
//  Created by 倉重ゴルプ　ダニエル on 2015/10/22.
//  Copyright © 2015年 Daniel Kurashige-Gollub. All rights reserved.
//

#import <objc/objc.h>
#import <objc/runtime.h>

#import "NSMenuItem+Index.h"
#import "macros.h"


static char const * const indexKey = "indexKey";


@implementation NSMenuItem (Index)

@dynamic index;

- (void)setIndex:(NSNumber *)newIndex
{
//    LOG_FUNC;

    objc_setAssociatedObject(self, &indexKey, newIndex, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSNumber *)index
{
//    LOG_FUNC;

    return (NSNumber *)objc_getAssociatedObject(self, &indexKey);
}
@end
