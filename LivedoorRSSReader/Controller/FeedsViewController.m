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
#import "LivedoorRSSReader_XMLParserDelegate.h"
#import <AFNetworking/AFNetworking.h>

@interface FeedsViewController () <LivedoorRSSReader_XMLParserDelegate, NSFetchedResultsControllerDelegate>
{
    Article *article;
    
    NSDateFormatter *_displayDateFormatter;
    
    NSFetchedResultsController *_fetchedResultsController;
    
    NSManagedObjectContext *_newContextForSavingInBackground;
}

@end

@implementation FeedsViewController

static NSString *categoryArray[] = {@"主要", @"国内", @"海外", @"IT 経済", @"芸能", @"スポーツ", @"映画", @"グルメ", @"女子", @"トレンド"};
static NSString *urlArray[] = {
    @"http://news.livedoor.com/topics/rss/top.xml",
    @"http://news.livedoor.com/topics/rss/dom.xml",
    @"http://news.livedoor.com/topics/rss/int.xml",
    @"http://news.livedoor.com/topics/rss/eco.xml",
    @"http://news.livedoor.com/topics/rss/ent.xml",
    @"http://news.livedoor.com/topics/rss/spo.xml",
    @"http://news.livedoor.com/rss/summary/52.xml",
    @"http://news.livedoor.com/topics/rss/gourmet.xml",
    @"http://news.livedoor.com/topics/rss/love.xml",
    @"http://news.livedoor.com/topics/rss/trend.xml"
};

#pragma mark - variables initialization

- (NSDateFormatter *) displayDateFormatter {
    if (_displayDateFormatter != nil) {
        return _displayDateFormatter;
    }

    _displayDateFormatter = [[NSDateFormatter alloc]init];
    [_displayDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [_displayDateFormatter setDateFormat:@"yyyy年MM月dd日 HH時mm分"];
    return _displayDateFormatter;
}

- (NSFetchedResultsController*) fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(category_id = %d)", self.categoryId];
    
    NSFetchRequest *fetchRequest = [Article MR_requestAllSortedBy:@"downloaded_date" ascending:NO withPredicate:predicate];
    [fetchRequest setFetchLimit:100];         // Let's say limit fetch to 100
    [fetchRequest setFetchBatchSize:20];      // After 20 are faulted
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:nil cacheName:@"ArticleCache"];
    
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

- (NSManagedObjectContext*) newContextForSavingInBackground {
    
    if (_newContextForSavingInBackground != nil) {
        return _newContextForSavingInBackground;
    }
    _newContextForSavingInBackground = [NSManagedObjectContext MR_context];
    return _newContextForSavingInBackground;
}

- (void)viewDidUnload {
    _fetchedResultsController = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = categoryArray[self.categoryId];
    
    [NSFetchedResultsController deleteCacheWithName:@"ArticleCache"];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    [self requestArticles];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setToolbarHidden:YES];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestArticles {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/rss+xml"];
    [manager GET:urlArray[self.categoryId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSXMLParser *xmlParser = (NSXMLParser*)responseObject;
        
        //NSLog(@"xml data: %@",[[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        [xmlParser setShouldProcessNamespaces:YES];
        
        LivedoorRSSReader_XMLParserDelegate *xmlParserDelegate = [[LivedoorRSSReader_XMLParserDelegate alloc] init];
        xmlParserDelegate.didParseDelegate = self;
        
        [xmlParser setDelegate:xmlParserDelegate];
        
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
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    id sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];

    return [sectionInfo numberOfObjects];
}

- (void) configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    
    Article *article_this_cell = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    cell.textLabel.text = article_this_cell.title;
    cell.detailTextLabel.text = [[self displayDateFormatter] stringFromDate:article_this_cell.pub_date];
    if (article_this_cell.is_read.boolValue) {
        [cell setBackgroundColor:[UIColor whiteColor]];
        [cell.textLabel setBackgroundColor:[UIColor whiteColor]];
        [cell.detailTextLabel setBackgroundColor:[UIColor whiteColor]];
    }
    else {
        [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [cell.textLabel setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [cell.detailTextLabel setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedInfoCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Article *selectedArticle = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [(DetailViewController*)[segue destinationViewController] setArticle:selectedArticle];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

#pragma mark - LivedoorRSSReader_XMLParserDelegate

- (void) didParseNewItemWithTitle:(NSString *)title link:(NSString *)link description:(NSString *)description guid:(NSString *)guid pubDate:(NSDate *)pubDate {
    article = [Article MR_findFirstOrCreateByAttribute:@"link" withValue:link inContext:[self newContextForSavingInBackground]];
    if ( ! [article.pub_date isEqualToDate:pubDate]) {
        // check if there is any update
        
        article.category_id = [NSNumber numberWithInteger:self.categoryId];
        article.is_read = [NSNumber numberWithBool:NO];
        article.title = title;
        article.article_description = description;
        article.link = link;
        article.guid = guid;
        article.pub_date = pubDate;
        article.downloaded_date = [NSDate date];
    }
}
- (void) didParseDocument {
    NSManagedObjectContext *context = [self newContextForSavingInBackground];
    [context MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error){
        NSLog(@"save completed");
    }];
}


@end
