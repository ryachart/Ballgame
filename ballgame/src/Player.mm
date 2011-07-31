//
//  Player.m
//  ballgame
//
//  Created by Ryan Hart on 7/10/11.
//  Copyright 2011 __myCompanyName__. All rights reserved.
//

#import "Player.h"
#import "Goal.h"
#define CHARGE_TO_PIXELS 3
@interface Player ()


@end

@implementation Player

@synthesize levelInfo=_levelInfo, status=_status, chargeLevel=_chargeLevel, shouldCharge=_shouldCharge;

-(void)setupGameObject:(NSDictionary*)game_object forWorld:(b2World*)world{
    if (_levelInfo == nil){
        [NSException raise:@"Attempt to setup a player object that doesn't have levelInfo" format:@"Make sure you set the level info for the player object before setupGameObject"];
        return;
    }
    [super setupGameObject:game_object forWorld:world];
    _status = PlayerBeganLevel;
    
    _identifier = GameObjectIDPlayer;
    CGPoint p;
    p.x = [[_levelInfo valueForKey:@"start_x"] floatValue];
    p.y = [[_levelInfo valueForKey:@"start_y"] floatValue];
    
    CGSize originalSize = [self contentSize];
    float originalWidth = originalSize.width;
    float originalHeight = originalSize.height;
    
    // TODO:  put start size in level and move this to the player class
    float newSize = [[_levelInfo valueForKey:@"starting_size"] floatValue];
    float newScaleX = (float)(newSize) / originalWidth;
    float newScaleY = (float)(newSize) / originalHeight;
    [self setScaleX:newScaleX];
    [self setScaleY:newScaleY];
    
    
    _growRate = [[_levelInfo valueForKey:@"size_grow_rate"] floatValue];
    _radius = [[_levelInfo valueForKey:@"starting_size"] floatValue] / 2;
    _chargeLevel = 0.0;
    _shouldCharge = YES;
    
	self.position = ccp( p.x,p.y );
    
    b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
    
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	bodyDef.userData = self;
	_body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
    b2CircleShape dynamicCircle;
	dynamicCircle.m_radius = _radius / PTM_RATIO;
    
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicCircle;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	_body->CreateFixture(&fixtureDef);
}

-(void) updateGameObject: (ccTime) dt
{
    if (_shouldCharge){
        _chargeLevel += _growRate * dt;
    }
    //NSLog(@"chargeLevel: %1.2f", _chargeLevel);
    [super updateGameObject:dt];
    
    
    float32 _radiusSize = (_radius + _chargeLevel/CHARGE_TO_PIXELS) ;
    //[self setScale: _radiusSize / _radius];
    //NSLog(@"scale: %1.2f", [self scale]);
    
    
    for (b2Fixture* f = _body->GetFixtureList(); f; f = f->GetNext()) 
    {
        b2CircleShape dynamicCircle;
        dynamicCircle.m_radius = _radiusSize / PTM_RATIO *2;
        
        b2FixtureDef fixtureDef;
        fixtureDef.shape = &dynamicCircle;	
        fixtureDef.density = 1.0f;
        fixtureDef.friction = 0.30f;
        _body->DestroyFixture(f);
        _body->CreateFixture(&fixtureDef);
    }

    
    //HARDCODE
    if (_chargeLevel > 100){
        _status = PlayerDied;
    }
    for (Effect *effect in _effects){
        [effect updateEffect:dt];
    }
}

-(void)handleCollisionWithObject:(GameObject *)object{
    [super handleCollisionWithObject:object];
    
    NSLog(@"%@", [[object class] description]);
    NSLog(@"%d", [object identifier]);
    
    switch ([object identifier]){
        case GameObjectIDGoal:
            //NSLog(@"Level Completed");
            _status = PlayerCompletedLevel;
            break;
        case GameObjectIDSwitch:
            
            break;
            
        case GameObjectIDChargedWall:
            _chargeLevel += ((ChargedWall*)object).chargeIncrement;
            NSLog(@"Charge level - %f", _chargeLevel);
            break;
            
    }
    
    [object handleCollisionWithObject:self];
}

-(void)noLongerCollidingWithObject:(GameObject*)object{
    [super noLongerCollidingWithObject:object];
    [object noLongerCollidingWithObject:self];
}
@end
