//
//  NSManagedObject+BGHelpers.m
//  Library
//
//  Created by Benjie Gillam on 16/09/2010.
//  Updated 2013 to support (require) ARC and remove unnecessary features.
//  Copyright 2013 Benjie Gillam.
//
//  MIT License
//

#import "NSManagedObject+BGHelpers.h"
#import "AppDelegate.h"

@implementation NSManagedObject (BGHelpers)
#pragma mark - Creation
+ (id)create {
	return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:APP.managedObjectContext];
}
#pragma mark - Fetch array
+ (NSArray *)arrayMatchingPredicate:(NSPredicate *)predicate orderedBy:(NSString *)sortKey orderAscending:(BOOL)ascending limitedTo:(int)maxResults {
	NSString *entityName = [self description];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:APP.managedObjectContext]];
	// Merge forced predicate on the next line
	[fetchRequest setPredicate:predicate];
	if (sortKey) {
		if ([sortKey isEqualToString:@"username"]) {
			[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending selector:@selector(caseInsensitiveCompare:)]]];
		} else {
			[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending]]];
		}
	}
	if (maxResults > 0) {
		[fetchRequest setFetchLimit:maxResults];
	}
	[fetchRequest setFetchBatchSize:20];
	[fetchRequest setReturnsObjectsAsFaults:(maxResults < 1 || maxResults > 20)];// Fault the data unless it's specified only 1-20 results.
	//#warning Next line potentially dangerous?
	//[fetchRequest setIncludesSubentities:NO];
	[fetchRequest setIncludesPendingChanges:YES];
	//[fetchRequest setIncludesPropertyValues:YES];
	NSError *error = nil;
	NSArray *objectArray = [[NSArray alloc] initWithArray:[APP.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
	if (error) {
		NSLog(@"WARNING: CoreData %@ fetch triggered error: %@", entityName, error);
	}
	fetchRequest = nil;
	return objectArray;
}

+ (NSArray *)arrayMatchingPredicate:(NSPredicate *)predicate orderedBy:(NSString *)sortKey orderAscending:(BOOL)ascending {
	return [self arrayMatchingPredicate:predicate orderedBy:sortKey orderAscending:ascending limitedTo:-1];
}

+ (NSArray *)arrayMatchingPredicate:(NSPredicate *)predicate {
	return [self arrayMatchingPredicate:predicate orderedBy:nil orderAscending:YES limitedTo:-1];
}

#pragma mark - Fetch single object
+ (id)objectMatchingPredicate:(NSPredicate *)predicate orderedBy:(NSString *)sortKey orderAscending:(BOOL)ascending {
	NSArray *results = [self arrayMatchingPredicate:predicate orderedBy:sortKey orderAscending:ascending limitedTo:1];
	if ([results count] < 1) return nil;
	else return [results objectAtIndex:0];
}
+ (id)objectMatchingPredicate:(NSPredicate *)predicate orderedBy:(NSString *)sortKey {
	return [self objectMatchingPredicate:predicate orderedBy:sortKey orderAscending:NO];
}

+ (id)anyObjectMatchingPredicate:(NSPredicate *)predicate {
	return [self objectMatchingPredicate:predicate orderedBy:nil orderAscending:NO];
}

#pragma mark - Get row count matching predicate

+ (int)rowCountMatchingPredicate:(NSPredicate *)predicate {
	NSString *entityName = [self description];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:APP.managedObjectContext]];
	[fetchRequest setPredicate:predicate];
	[fetchRequest setIncludesPendingChanges:YES];
	NSError *error = nil;
	int fetchRequestCount = [APP.managedObjectContext countForFetchRequest:fetchRequest error:&error];
	if (error) {
		fetchRequest = nil;
		NSLog(@"WARNING: CoreData %@ fetch triggered error: %@", entityName, error);
		return 0;
	}
	fetchRequest = nil;
	return fetchRequestCount;
}

#pragma mark - UUID helpers

+ (NSString *)generateUUID {
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	CFStringRef uuidCfstr = CFUUIDCreateString(NULL, uuid);
	CFRelease(uuid);
	return CFBridgingRelease(uuidCfstr);
}

- (NSString *)generateUUID {
	return [[self class] generateUUID];
}

#pragma mark - Deleting records
- (void)deleteFromCoreDataAndSave:(BOOL)save {
	[APP.managedObjectContext deleteObject:self];
	if (save) {
		[APP saveContext];
	}
}

- (void)deleteFromCoreData {
	[self deleteFromCoreDataAndSave:YES];
}

@end