//
//  YXFMDatabasePool.h
//  YXFMdb
//
//  Created by August Mueller on 6/22/11.
//  Copyright 2011 Flying Meat Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YXFMDatabase;

/** Pool of `<YXFMDatabase>` objects.

 ### See also
 
 - `<YXFMDatabaseQueue>`
 - `<YXFMDatabase>`

 @warning Before using `YXFMDatabasePool`, please consider using `<YXFMDatabaseQueue>` instead.

 If you really really really know what you're doing and `YXFMDatabasePool` is what
 you really really need (ie, you're using a read only database), OK you can use
 it.  But just be careful not to deadlock!

 For an example on deadlocking, search for:
 `ONLY_USE_THE_POOL_IF_YOU_ARE_DOING_READS_OTHERWISE_YOULL_DEADLOCK_USE_YXFMDATABASEQUEUE_INSTEAD`
 in the main.m file.
 */

@interface YXFMDatabasePool : NSObject {
    NSString            *_path;
    
    dispatch_queue_t    _lockQueue;
    
    NSMutableArray      *_databaseInPool;
    NSMutableArray      *_databaseOutPool;
    
    __unsafe_unretained id _delegate;
    
    NSUInteger          _maximumNumberOfDatabasesToCreate;
    int                 _openFlags;
}

/** Database path */

@property (atomic, retain) NSString *path;

/** Delegate object */

@property (atomic, assign) id delegate;

/** Maximum number of databases to create */

@property (atomic, assign) NSUInteger maximumNumberOfDatabasesToCreate;

/** Open flags */

@property (atomic, readonly) int openFlags;


///---------------------
/// @name Initialization
///---------------------

/** Create pool using path.

 @param aPath The file path of the database.

 @return The `YXFMDatabasePool` object. `nil` on error.
 */

+ (instancetype)databasePoolWithPath:(NSString*)aPath;

/** Create pool using path and specified flags

 @param aPath The file path of the database.
 @param openFlags Flags passed to the openWithFlags method of the database

 @return The `YXFMDatabasePool` object. `nil` on error.
 */

+ (instancetype)databasePoolWithPath:(NSString*)aPath flags:(int)openFlags;

/** Create pool using path.

 @param aPath The file path of the database.

 @return The `YXFMDatabasePool` object. `nil` on error.
 */

- (instancetype)initWithPath:(NSString*)aPath;

/** Create pool using path and specified flags.

 @param aPath The file path of the database.
 @param openFlags Flags passed to the openWithFlags method of the database

 @return The `YXFMDatabasePool` object. `nil` on error.
 */

- (instancetype)initWithPath:(NSString*)aPath flags:(int)openFlags;

///------------------------------------------------
/// @name Keeping track of checked in/out databases
///------------------------------------------------

/** Number of checked-in databases in pool
 
 @returns Number of databases
 */

- (NSUInteger)countOfCheckedInDatabases;

/** Number of checked-out databases in pool

 @returns Number of databases
 */

- (NSUInteger)countOfCheckedOutDatabases;

/** Total number of databases in pool

 @returns Number of databases
 */

- (NSUInteger)countOfOpenDatabases;

/** Release all databases in pool */

- (void)releaseAllDatabases;

///------------------------------------------
/// @name Perform database operations in pool
///------------------------------------------

/** Synchronously perform database operations in pool.

 @param block The code to be run on the `YXFMDatabasePool` pool.
 */

- (void)inDatabase:(void (^)(YXFMDatabase *db))block;

/** Synchronously perform database operations in pool using transaction.

 @param block The code to be run on the `YXFMDatabasePool` pool.
 */

- (void)inTransaction:(void (^)(YXFMDatabase *db, BOOL *rollback))block;

/** Synchronously perform database operations in pool using deferred transaction.

 @param block The code to be run on the `YXFMDatabasePool` pool.
 */

- (void)inDeferredTransaction:(void (^)(YXFMDatabase *db, BOOL *rollback))block;

/** Synchronously perform database operations in pool using save point.

 @param block The code to be run on the `YXFMDatabasePool` pool.
 
 @return `NSError` object if error; `nil` if successful.

 @warning You can not nest these, since calling it will pull another database out of the pool and you'll get a deadlock. If you need to nest, use `<[YXFMDatabase startSavePointWithName:error:]>` instead.
*/

- (NSError*)inSavePoint:(void (^)(YXFMDatabase *db, BOOL *rollback))block;

@end


/** YXFMDatabasePool delegate category
 
 This is a category that defines the protocol for the YXFMDatabasePool delegate
 */

@interface NSObject (YXFMDatabasePoolDelegate)

/** Asks the delegate whether database should be added to the pool. 
 
 @param pool     The `YXFMDatabasePool` object.
 @param database The `YXFMDatabase` object.
 
 @return `YES` if it should add database to pool; `NO` if not.
 
 */

- (BOOL)databasePool:(YXFMDatabasePool*)pool shouldAddDatabaseToPool:(YXFMDatabase*)database;

/** Tells the delegate that database was added to the pool.
 
 @param pool     The `YXFMDatabasePool` object.
 @param database The `YXFMDatabase` object.

 */

- (void)databasePool:(YXFMDatabasePool*)pool didAddDatabase:(YXFMDatabase*)database;

@end

