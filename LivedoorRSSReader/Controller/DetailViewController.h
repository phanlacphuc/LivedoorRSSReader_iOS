//
//  DetailViewController.h
//  LivedoorRSSReader
//
//  Created by Phan Lac Phuc on 6/15/15.
//  Copyright (c) 2015 Phan Lac Phuc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) Article *article;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButtonItem;

@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

