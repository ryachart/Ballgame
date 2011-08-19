//
//  SplashScene.h
//  ballgame
//
//  Created by Ryan Hart on 7/17/11.
//  Copyright 2011 NoName. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface SplashScene : CCLayerColor {
    
}
+(CCScene *) scene;
-(void)loadScene;

// Menu items
-(void)playTapped:(id)sender;
-(void)debugTapped:(id)sender;
-(void)settingsTapped:(id)sender;

-(void)startBackgroundMusic;

@end
