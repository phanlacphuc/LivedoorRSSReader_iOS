//
//  XMLParserDelegate.m
//  LivedoorRSSReader
//
//  Created by Phan Lac Phuc on 6/17/15.
//  Copyright (c) 2015 Phan Lac Phuc. All rights reserved.
//

#import "LivedoorRSSReader_XMLParserDelegate.h"

@interface LivedoorRSSReader_XMLParserDelegate () <NSXMLParserDelegate>


@end
@implementation LivedoorRSSReader_XMLParserDelegate
{
    
    //for switch and case
    enum nodes {title = 1, articleLink = 2, description = 3, pubDate = 4, guid = 5, invalidNode = -1};
    enum nodes aNode;
    NSString *newTitle;
    NSString *newLink;
    NSString *newDescription;
    NSDate *newPubDate;
    NSString *newGuid;
    
    NSDateFormatter *_dateFormatter;
    
}

- (NSDateFormatter *) dateFormatter {
    if (_dateFormatter != nil) {
        return _dateFormatter;
    }
    _dateFormatter = [[NSDateFormatter alloc]init];
    [_dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
    return _dateFormatter;
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    //self.xmlWeather = [NSMutableDictionary dictionary];
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"item"]) {
        aNode = invalidNode;
        
        newTitle = @"";
        newLink = @"";
        newDescription = @"";
        newGuid = @"";
        newPubDate = nil;
    }
    else if([elementName isEqualToString:@"title"]) {
        aNode = title;
    }
    else if([elementName isEqualToString:@"link"]) {
        aNode = articleLink;
    }
    else if([elementName isEqualToString:@"description"]) {
        aNode = description;
    }
    else if([elementName isEqualToString:@"pubDate"]) {
        aNode = pubDate;
    }
    else if([elementName isEqualToString:@"guid"]) {
        aNode = guid;
    }
    else {
        aNode = invalidNode;
    }
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet nonBaseCharacterSet]];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (string.length != 0) {
        switch (aNode) {
            case title:
                newTitle = [newTitle stringByAppendingString:string];
                break;
            case articleLink:
                newLink = string;
                break;
            case description:
                newDescription = [newDescription stringByAppendingString:string];
                break;
            case guid:
                newGuid = string;
                break;
            case pubDate:
                newPubDate = [[self dateFormatter] dateFromString:string];
                break;
            default:
                break;
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"item"]) {
        [self.didParseDelegate didParseNewItemWithTitle:newTitle link:newLink description:newDescription guid:newGuid pubDate:newPubDate];
    }
}
- (void) parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"parserDidEndDocument");
    [self.didParseDelegate didParseDocument];
}
@end
