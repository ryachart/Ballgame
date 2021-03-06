//
//  DebugConfigurationViewController.h
//  ballgame
//
//  Created by Ryan Hart on 7/17/11.
//  Copyright 2011 NoName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssetManager.h"
#import "PlayerStateManager.h"

typedef void (*CellBlock)();

@interface DebugConfigurationViewController : UITableViewController {
    NSArray *cellTitles;
    NSArray *cellActions;
    NSArray *levels;
}
@end
