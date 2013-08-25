//
//  IODItem.m
//  iOSDiner
//
//  Created by test on 03/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IODItem.h"
#define kInventoryAddress @"http://adamburkepile.com/inventory/"

@implementation IODItem
@synthesize price = _price;
@synthesize pictureFile = _pictureFile;
@synthesize name = _name;

- (id)initWithName:(NSString*)inName andPrice:(float)inPrice andPictureFile:(NSString*)inPictureFile {
    if (self = [self init]) {
        [self setName:inName];
        [self setPrice:inPrice];
        [self setPictureFile:inPictureFile];
    }
    
    return self;
}

-(id)copyWithZone:(NSZone *)zone {
    IODItem* newItem = [IODItem new];
    [newItem setName:[self name]];
    [newItem setPrice:[self price]];
    [newItem setPictureFile:[self pictureFile]];
    
    return newItem;
}
+ (NSArray*)retrieveInventoryItems {
    NSMutableArray* inventory = [NSMutableArray new];
    NSError* err = nil;
    
    NSArray* jsonInventory = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:kInventoryAddress]] 
                                                             options:kNilOptions 
                                                               error:&err];
    [jsonInventory enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary* item = obj;
        [inventory addObject:[[IODItem alloc] initWithName:[item objectForKey:@"Name"] 
                                                  andPrice:[[item objectForKey:@"Price"] floatValue]
                                            andPictureFile:[item objectForKey:@"Image"]]];
    }];
    
    return [inventory copy];
}

@end
