//
//  LivedoorRSSReader_XMLParserDelegate.h
//  LivedoorRSSReader
//
//  Created by Phan Lac Phuc on 6/17/15.
//  Copyright (c) 2015 Phan Lac Phuc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LivedoorRSSReader_XMLParserDelegate

@required

- (void) didParseNewItemWithTitle:(NSString*)title link:(NSString*)link description:(NSString*)description guid:(NSString*)guid pubDate:(NSDate*)pubDate;

- (void) didParseDocument;

@end

@interface LivedoorRSSReader_XMLParserDelegate : NSObject <NSXMLParserDelegate>

@property (nonatomic, assign) id<LivedoorRSSReader_XMLParserDelegate> didParseDelegate;

@end
