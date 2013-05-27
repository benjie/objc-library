//
//  NSManagedObject+BGHelpers.h
//  Library
//
//  Created by Benjie Gillam on 16/09/2010.
//  Updated 2013 to support (require) ARC and remove unnecessary features.
//  Copyright 2013 Benjie Gillam.
//
//  MIT License
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (BGHelpers)

+ (id)create;
+ (NSArray *)arrayMatchingPredicate:(NSPredicate *)predicate orderedBy:(NSString *)sortKey orderAscending:(BOOL)ascending limitedTo:(int)maxResults;
+ (NSArray *)arrayMatchingPredicate:(NSPredicate *)predicate orderedBy:(NSString *)sortKey orderAscending:(BOOL)ascending;
+ (NSArray *)arrayMatchingPredicate:(NSPredicate *)predicate;
+ (id)objectMatchingPredicate:(NSPredicate *)predicate orderedBy:(NSString *)sortKey orderAscending:(BOOL)ascending;
+ (id)objectMatchingPredicate:(NSPredicate *)predicate orderedBy:(NSString *)sortKey;
+ (id)anyObjectMatchingPredicate:(NSPredicate *)predicate;
+ (int)rowCountMatchingPredicate:(NSPredicate *)predicate;
- (void)deleteFromCoreDataAndSave:(BOOL)save;
- (void)deleteFromCoreData;
+ (NSString *)generateUUID;
- (NSString *)generateUUID;

@end
