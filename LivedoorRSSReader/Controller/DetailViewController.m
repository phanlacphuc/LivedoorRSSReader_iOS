//
//  DetailViewController.m
//  LivedoorRSSReader
//
//  Created by Phan Lac Phuc on 6/15/15.
//  Copyright (c) 2015 Phan Lac Phuc. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
{
    NSDateFormatter *displayDateFormatter;
}
@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.article) {
        
        displayDateFormatter = [[NSDateFormatter alloc]init];
        [displayDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [displayDateFormatter setDateFormat:@"yyyy年mm月dd日 HH時mm分"];
        
        NSString *pubDateString = [displayDateFormatter stringFromDate:self.article.pubDate];
        
        NSString *htmlString = @"";
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
