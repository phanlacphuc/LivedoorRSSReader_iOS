//
//  DetailViewController.h
//  LivedoorRSSReader
//
//  Created by Phan Lac Phuc on 6/15/15.
//  Copyright (c) 2015 Phan Lac Phuc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) Feed *feed;
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

