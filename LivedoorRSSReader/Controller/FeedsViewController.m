//
//  FeedsViewController.m
//  LivedoorRSSReader
//
//  Created by Phan Lac Phuc on 6/15/15.
//  Copyright (c) 2015 Phan Lac Phuc. All rights reserved.
//

#import "FeedsViewController.h"
#import "Article.h"
#import "DetailViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface FeedsViewController () <NSXMLParserDelegate>
{
    //for switch and case
    enum nodes {title = 1, articleLink = 2, description = 3, pubDate = 4, guid = 5, invalidNode = -1};
    enum nodes aNode;
    
    Article *article;
    NSArray *articles;
    
    NSDateFormatter *dateFormatter;
    NSDateFormatter *displayDateFormatter;
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
    
    displayDateFormatter = [[NSDateFormatter alloc]init];
    [displayDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [displayDateFormatter setDateFormat:@"yyyy年mm月dd日 HH時mm分"];
    
    NSArray *categoryArray = @[@"主要", @"国内", @"海外", @"IT 経済", @"芸能", @"スポーツ", @"映画", @"グルメ", @"女子", @"トレンド"];
    
    self.title = categoryArray[self.categoryId];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(category_id = %d)", self.categoryId];
    //articles = [Article MR_fetchAllSortedBy:nil ascending:YES withPredicate:predicate groupBy:nil delegate:self];
    
    articles = [Article MR_findAllSortedBy:@"pubDate" ascending:NO withPredicate:predicate];
    
    [self requestArticles];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestArticles {
    
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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/rss+xml"];
    [manager GET:urlArray[self.categoryId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSXMLParser *xmlParser = (NSXMLParser*)responseObject;
        
        //NSLog(@"xml data: %@",[[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        [xmlParser setShouldProcessNamespaces:YES];
        [xmlParser setDelegate:self];
        [xmlParser parse];
        [self.refreshControl endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        [self.refreshControl endRefreshing];
        
    }];
}

- (IBAction)refresh:(UIRefreshControl *)sender {
    [self requestArticles];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return articles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedInfoCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Article *article_this_cell = [articles objectAtIndex:indexPath.row];
    cell.textLabel.text = article_this_cell.title;
    cell.detailTextLabel.text = [displayDateFormatter stringFromDate:article_this_cell.pubDate];
    if (article_this_cell.is_read.boolValue) {
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
    else {
        [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    }
    
    return cell;
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
    Article *selected_article = [articles objectAtIndex:indexPath.row];
    selected_article.is_read = [NSNumber numberWithBool:YES];
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext){
        // nothing to do after saved
    }];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [(DetailViewController*)[segue destinationViewController] setArticle:[articles objectAtIndex:indexPath.row]];
    }
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
        
        article = [Article MR_createEntity];
        article.category_id = [NSNumber numberWithInteger:self.categoryId];
        article.is_read = [NSNumber numberWithBool:NO];
        article.title = @"";
        article.article_description = @"";
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
    
    if (string.length != 0 && article != nil) {
        switch (aNode) {
            case title:
                article.title = [article.title stringByAppendingString:string];
                break;
            case articleLink:
                [Article MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"link = %@", string]];
                article.link = string;
                break;
            case description:
                article.article_description = [article.article_description stringByAppendingString:string];
                break;
            case guid:
                article.guid = string;
                break;
            case pubDate:
                article.pubDate = [dateFormatter dateFromString:string];
                break;
            default:
                break;
        }
    }
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"item"]) {
        article = nil;
    }
}
- (void) parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"parserDidEndDocument");
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext){
        // nothing to do after saved
    }];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category_id = %d", self.categoryId];
    //feeds = [Feed MR_fetchAllSortedBy:nil ascending:YES withPredicate:predicate groupBy:nil delegate:self];
    
    articles = [Article MR_findAllSortedBy:@"pubDate" ascending:NO withPredicate:predicate];
    
    [self.tableView reloadData];
}

@end
