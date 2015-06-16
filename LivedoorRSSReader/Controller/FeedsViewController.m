//
//  FeedsViewController.m
//  LivedoorRSSReader
//
//  Created by Phan Lac Phuc on 6/15/15.
//  Copyright (c) 2015 Phan Lac Phuc. All rights reserved.
//

#import "FeedsViewController.h"
#import "Feed.h"
#import <AFNetworking/AFNetworking.h>

@interface FeedsViewController () <NSXMLParserDelegate>
{
    //for switch and case
    enum nodes {title = 1, articleLink = 2, description = 3, pubDate = 4, guid = 5, invalidNode = -1};
    enum nodes aNode;
    //for holding the parsing result
    NSMutableDictionary *articles;
    //for matching the article title and link
    Feed *feed;
    
    NSArray *feeds;
    
    NSDateFormatter *dateFormatter;
}

@end

@implementation FeedsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
    
    NSArray *categoryArray = @[@"主要", @"国内", @"海外", @"IT 経済", @"芸能", @"スポーツ", @"映画", @"グルメ", @"女子", @"トレンド"];
    NSArray *urlArray = @[@"http://news.livedoor.com/topics/rss/top.xml",
                          @"http://news.livedoor.com/topics/rss/dom.xml",
                          @"http://news.livedoor.com/topics/rss/int.xml",
                          @"http://news.livedoor.com/topics/rss/eco.xml",
                          @"http://news.livedoor.com/topics/rss/ent.xml",
                          @"http://news.livedoor.com/topics/rss/spo.xml",
                          @"http://news.livedoor.com/rss/summary/52.xml",
                          @"http://news.livedoor.com/topics/rss/gourmet.xml",
                          @"http://news.livedoor.com/topics/rss/love.xml",
                          @"http://news.livedoor.com/topics/rss/trend.xml"];
    
    self.title = categoryArray[self.categoryId];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/rss+xml"];
    [manager GET:urlArray[self.categoryId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSXMLParser *xmlParser = (NSXMLParser*)responseObject;
        
        //NSLog(@"xml data: %@",[[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        [xmlParser setShouldProcessNamespaces:YES];
        [xmlParser setDelegate:self];
        [xmlParser parse];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
    
    /*
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category_id = %@", self.categoryId];
    feeds = [Feed MR_fetchAllSortedBy:nil ascending:YES withPredicate:predicate groupBy:nil delegate:self];
    */
    feeds = [Feed MR_findAll];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [Feed MR_countOfEntities];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedInfoCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Feed *feed_for_this_cell = [feeds objectAtIndex:indexPath.row];
    cell.textLabel.text = [feed_for_this_cell title];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - NSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    //self.xmlWeather = [NSMutableDictionary dictionary];
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"item"]) {
        aNode = invalidNode;
        
        feed = [Feed MR_createEntity];
        feed.is_read = [NSNumber numberWithBool:NO];
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
    
    if (string.length != 0 && feed != nil) {
        switch (aNode) {
            case title:
                feed.title = string;
                break;
            case articleLink:
                [Feed MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"link = %@", string]];
                feed.link = string;
                break;
            case description:
                feed.feed_description = string;
                break;
            case guid:
                feed.guid = string;
                break;
            case pubDate:
                feed.pubDate = [dateFormatter dateFromString:string];
                break;
            default:
                break;
        }
    }
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"item"]) {
        feed = nil;
    }
}
- (void) parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"parserDidEndDocument");
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext){
        // nothing to do after saved
    }];
    feeds = [Feed MR_findAll];
    [self.tableView reloadData];
}

@end
