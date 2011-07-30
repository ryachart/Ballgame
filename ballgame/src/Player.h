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

typedef enum {
    PlayerBeganLevel,
    PlayerCompletedLevel,
    PlayerDied
} PlayerStatus;

@interface Player : GameObject {
    float _growRate;
    float _radius;
    float _chargeLevel;
    
    NSDictionary *_levelInfo;
    
    PlayerStatus _status;
    
}
@property (nonatomic, retain) NSDictionary *levelInfo;
@property (readonly) PlayerStatus status;

-(void) updateGameObject: (ccTime) dt;
-(void) reduceCharge:(float)amount;
@end
