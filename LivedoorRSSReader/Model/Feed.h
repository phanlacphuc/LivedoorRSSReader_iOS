//
//  Feed.h
//  LivedoorRSSReader
//
//  Created by Phan Lac Phuc on 6/16/15.
//  Copyright (c) 2015 Phan Lac Phuc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Feed : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * feed_description;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSNumber * category_id;
@property (nonatomic, retain) NSNumber * is_read;

@end
