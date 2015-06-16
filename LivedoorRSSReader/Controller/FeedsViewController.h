//
//  FeedsViewController.h
//  LivedoorRSSReader
//
//  Created by Phan Lac Phuc on 6/15/15.
//  Copyright (c) 2015 Phan Lac Phuc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedsViewController : UITableViewController

@property NSInteger categoryId;

- (IBAction)refresh:(UIRefreshControl*)sender;

@end
