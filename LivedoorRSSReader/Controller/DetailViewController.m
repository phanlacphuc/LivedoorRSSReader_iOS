//
//  DetailViewController.m
//  LivedoorRSSReader
//
//  Created by Phan Lac Phuc on 6/15/15.
//  Copyright (c) 2015 Phan Lac Phuc. All rights reserved.
//

#import "DetailViewController.h"
#import "LivedoorRSSReader_XMLParserDelegate.h"
#import <AFNetworking/AFNetworking.h>

@interface DetailViewController () <LivedoorRSSReader_XMLParserDelegate>
{
    NSString *htmlString;
    NSUInteger numberOfFoundRelatedArticles;
}
@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.article) {
        
        NSDateFormatter *displayDateFormatter = [[NSDateFormatter alloc]init];
        [displayDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [displayDateFormatter setDateFormat:@"yyyy年MM月dd日 HH時mm分"];
        
        NSString *pubDateString = [displayDateFormatter stringFromDate:self.article.pub_date];
        
        htmlString = @"";
        htmlString = [htmlString stringByAppendingString:@"<h3>"];
        htmlString = [htmlString stringByAppendingString:self.article.title];
        htmlString = [htmlString stringByAppendingString:@"</h3>"];
        htmlString = [htmlString stringByAppendingString:pubDateString];
        htmlString = [htmlString stringByAppendingString:@"<br />"];
        htmlString = [htmlString stringByAppendingString:@"<br />"];
        htmlString = [htmlString stringByAppendingString:self.article.article_description];
        htmlString = [htmlString stringByAppendingString:@"<br />"];
        htmlString = [htmlString stringByAppendingString:@"<h4>関連記事</h4>"];
        
        [self.webview loadHTMLString:htmlString baseURL:nil];
        
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    if (!self.article.is_read.boolValue){
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
            // nothing to do after saved
            Article *artical = [self.article MR_inContext:localContext];
            artical.is_read = [NSNumber numberWithBool:YES];
        }];
    }
    
    [self requestRelatedArticles];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)requestRelatedArticles {
    
    numberOfFoundRelatedArticles = 0;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // search related articles using feedly services
    
    NSString *url = @"http://cloud.feedly.com/v3/search/feeds?locale=JP&query=";
    url = [url stringByAppendingString:self.article.link];
    
    NSString* encodedUrl = [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    
    NSLog(@"url: %@", url);
    [manager GET:encodedUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        
        // the response do not contain the links for related articles, but contain the URL of where we can get the links for related articles. Therefore, we have to send a second request to the obtained URL.
        NSArray *results = responseObject[@"results"];
        if (results.count > 0) {
            
            NSString *relatedArticle = results[0][@"feedId"];
            
            
            NSString *url = [relatedArticle stringByReplacingOccurrencesOfString:@"feed/" withString:@"" options:0 range:NSMakeRange(0, 5)];
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/rss+xml",@"application/atom+xml",nil];
            [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                // the final response is a rss/xml document
                NSXMLParser *xmlParser = (NSXMLParser*)responseObject;
                //NSLog(@"xml data: %@",[[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
                [xmlParser setShouldProcessNamespaces:YES];
                
                LivedoorRSSReader_XMLParserDelegate *xmlParserDelegate = [[LivedoorRSSReader_XMLParserDelegate alloc] init];
                xmlParserDelegate.didParseDelegate = self;
                
                [xmlParser setDelegate:xmlParserDelegate];
                
                [xmlParser parse];
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                NSLog(@"Error: %@", error);
            }];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
}

#pragma mark - LivedoorRSSReader_XMLParserDelegate

- (void) didParseNewItemWithTitle:(NSString *)title link:(NSString *)link description:(NSString *)description guid:(NSString *)guid pubDate:(NSDate *)pubDate {
     // accept max 3 articles which different from the current article itself
     if (numberOfFoundRelatedArticles<3 && ![link isEqualToString:self.article.link]) {
         numberOfFoundRelatedArticles++;
         htmlString = [htmlString stringByAppendingFormat:@"%lu. ", numberOfFoundRelatedArticles];
         htmlString = [htmlString stringByAppendingString:@"<a href="" "];
         htmlString = [htmlString stringByAppendingString:link];
         htmlString = [htmlString stringByAppendingString:@" "">"];
         htmlString = [htmlString stringByAppendingString:title];
         htmlString = [htmlString stringByAppendingString:@"</a>"];
         htmlString = [htmlString stringByAppendingString:@"<br />"];
     }
}
- (void) didParseDocument {
    
    [self.webview loadHTMLString:htmlString baseURL:nil];
}


@end
