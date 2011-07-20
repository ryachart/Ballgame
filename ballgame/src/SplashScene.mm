//
//  SplashScreen.m
//  ballgame
//
//  Created by Ryan Hart on 7/17/11.
//  Copyright 2011 NoName. All rights reserved.
//

#import "SplashScene.h"
#import "PlayScene.h"
#import "DebugConfigurationViewController.h"
#import "AppDelegate.h"

@interface SplashScene ()
-(void)playTapped:(id)sender;
-(void)debugTapped:(id)sender;
@end

@implementation SplashScene
+(CCScene*)scene{
    CCScene *scene = [CCScene node];
    SplashScene *layer = [SplashScene node];
    [layer loadScene];
    [scene addChild:layer];
    
    return scene;
}

-(void)loadScene{
    CCMenuItem *_playItem = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Play" fontName:@"Arial" fontSize:32.0] target:self selector:@selector(playTapped:)];
    [_playItem setPosition:ccp(100, 250)];
    CCMenuItem *_debugItem = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Debug" fontName:@"Arial" fontSize:32.0] target:self selector:@selector(debugTapped:)];
    [_debugItem setPosition:ccp(400, 250)];
    
    CCMenu *_menu = [CCMenu menuWithItems:_playItem,_debugItem, nil];
    [_menu setPosition:ccp(0,0)];
    [self addChild:_menu];
    
    
}
-(void)playTapped:(id)sender{
    [[CCDirector sharedDirector] replaceScene:[PlayScene debugScene]];
}
-(void)debugTapped:(id)sender{
    [[CCDirector sharedDirector] pause];
    DebugConfigurationViewController *dbvc = [[DebugConfigurationViewController alloc] initWithStyle:UITableViewStylePlain];
    [[(AppDelegate*)[[UIApplication sharedApplication] delegate] navController] pushViewController:dbvc animated:NO];
    [[(AppDelegate*)[[UIApplication sharedApplication] delegate] navController] setNavigationBarHidden:YES];
    [dbvc release];
}
@end