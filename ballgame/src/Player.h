//
//  Player.h
//  ballgame
//
//  Created by Ryan Hart on 7/10/11.
//  Copyright 2011 __myCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameObject.h"
#import "ChargedWall.h"

typedef enum {
    PlayerBeganLevel,
    PlayerCompletedLevel,
    PlayerDied
} PlayerStatus;

@interface Player : GameObject {
    float _growRate;
    float _radius;
    float _chargeLevel;
    int _maxSpeed;
    
    NSDictionary *_levelInfo;
    
    PlayerStatus _status;
    BOOL _shouldCharge;
    
}
@property (nonatomic, retain) NSDictionary *levelInfo;
@property (readonly) PlayerStatus status;
@property (readwrite) float chargeLevel;
@property (readwrite) BOOL shouldCharge;

-(BOOL)isStuck;

-(void) updateGameObject: (ccTime) dt;

// Setup functions
-(void) setupSprite;
-(void) setupBody:(b2World *)world;
-(void) startAnimating;
  
@end
