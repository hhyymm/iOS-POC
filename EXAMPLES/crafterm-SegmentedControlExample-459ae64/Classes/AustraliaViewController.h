//
//  MyViewController2.h
//  SegmentedControlExample
//
//  Created by Marcus Crafter on 26/05/10.
//  Copyright 2010 Red Artisan. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AustraliaViewController : UITableViewController {
    UIViewController * managingViewController;
}

@property (nonatomic, retain) UIViewController * managingViewController;

- (id)initWithParentViewController:(UIViewController *)aViewController;

@end
