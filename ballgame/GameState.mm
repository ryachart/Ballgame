//
//  GameState.m
//  ballgame
//
//  Created by Ryan Hart on 8/20/11.
//  Copyright 2011 NoName. All rights reserved.
//

#import "GameState.h"
#import "Player.h"
#import "GameObject.h"

//Modification Definitions
NSString* const GameStateModificationPlayerMovementEnabled = @"PlayerMovementEnabled";
NSString* const GameStateModificationPlayerMovementDisabled = @"PlayerMovementDisabled";
NSString* const GameStateModificationGrowthSpeedAdjustment = @"PlayerGrowthAdjustment";
NSString* const GameStateModificationAddObjectNamed = @"AddObjectNamed";
NSString* const GameStateModificationRemoveObjectNamed = @"RemoveObjectNamed";
NSString* const GameStateModificationPauseGameForDuration = @"PauseGameForDuration";
NSString* const GameStateModificationDisplayTextForDuration = @"DisplayTextForDuration";
NSString* const GameStateModificationPlaySoundNamed = @"PlaySoundNamed";
NSString* const GameStateModificationAnimateCamera = @"AnimateCamera";
NSString* const GameStateModificationPreventPlayerDeathOnFullCharge = @"FullChargeDoesntKill";

//GameState Conditions
NSString* const GameStateConditionPlayerSizeThreshold = @"SizeThreshold";
NSString* const GameStateConditionObjectCollisionBegan = @"CollisionBegan";
NSString* const GameStateConditionObjectCollisionEnded = @"CollisionEnded";
NSString* const GameStateConditionPlayerTap = @"PlayerTapped";
NSString* const GameStateConditionWaitForDuration = @"WaitForDuration";

//Condition Properties
NSString* const GSConditionPropertyTextKey = @"text";
NSString* const GSConditionPropertyDurationKey = @"duration";
NSString* const GSConditionPropertyThresholdKey = @"threshold";

@interface GameState ()

@property (readonly) BOOL playerReachedMaximumSize;
@property (readonly) BOOL playerBecameStuck;
@property (readonly) BOOL playerTouchedGoal;
@property (readonly) NSMutableDictionary *satisfiedConditions;

@end 

@implementation GameState
@synthesize gameStateModifications = _gameStateModifications, advancementConditions=_advancementConditions;
@synthesize isFinalState=_isFinalState, satisfiedConditions=_satisfiedConditions;
@synthesize playerBecameStuck=_playerBecameStuck, playerReachedMaximumSize=_playerReachedMaximumSize, playerTouchedGoal=_playerTouchedGoal;

-(id)init{
    return [self initWithGameStateMods:nil andConditions:nil];
}

-(id)initWithGameStateMods:(NSDictionary*)mods andConditions:(NSDictionary*)conditions
{
    self = [super init];
    if (self) {
        
        _gameStateModifications = [mods retain];
        _advancementConditions = [conditions retain];
        
        // Initialization code here.
        _isFinalState = NO;
        _satisfiedConditions = 0;
        
        _playerReachedMaximumSize = NO;
        _playerTouchedGoal = NO;
        _playerBecameStuck = NO;
        
        _satisfiedConditions = [[NSMutableDictionary dictionaryWithCapacity:[_advancementConditions count]] retain];
        
        for (NSString *key in [_advancementConditions allKeys]){
            [_satisfiedConditions setValue:[NSNumber numberWithBool:NO] forKey:key];
        }
    }
    
    return self;
}

-(BOOL)playerWon{
    return (_playerTouchedGoal && !_playerReachedMaximumSize);
}

-(BOOL)canAdvanceGameState{
    BOOL allConditionsSatisfied = YES;
    for (NSNumber *conditionResult in [_satisfiedConditions allValues]){
        if (![conditionResult boolValue]){
            allConditionsSatisfied = NO;
            break;
        }
    }
    return allConditionsSatisfied;
}

-(BOOL)gameShouldEnd{
    return _playerBecameStuck || _playerReachedMaximumSize || [self playerWon];
}
#pragma mark - Event Handlers

-(void)beginCurrentGameState{
    //Check for any timers that need to get kicked off to satisfy duration conditions
#if GAME_STATE_DEBUG
    NSLog(@"The current game state %@ has begun", self);
#endif
}

                              
-(void)endCurrentGameState{
#if GAME_STATE_DEBUG
    NSLog(@"The current game state %@ has ended", self);
#endif
}

-(void)waitForDurationFinished{
    if ([_advancementConditions objectForKey:GameStateConditionWaitForDuration] != nil){
#if GAME_STATE_DEBUG
        NSLog(@"Wait for Duration satisfied");
#endif
        [_satisfiedConditions setValue:[NSNumber numberWithBool:YES] forKey:GameStateConditionWaitForDuration];
    }
}

-(void)levelBegan{
#if GAME_STATE_DEBUG
    NSLog(@"Level Began");
#endif 
}

-(void)playerReachedMaximumSize:(id)player{
    _playerReachedMaximumSize = YES;
    if ([[[self gameStateModifications] objectForKey:GameStateModificationPreventPlayerDeathOnFullCharge] boolValue] == YES){
        _playerReachedMaximumSize = NO;
        [(Player*)player setChargeLevel:[player chargeLevel] * .5];
    }
}
-(void)playerIsStuck:(id)player{
    _playerBecameStuck = YES;
}
-(void)playerSizeChanged:(id)player{
    Player *thePlayer = (Player*)player;
#if GAME_STATE_DEBUG
    NSLog(@"playerSizeChanged to: %1.2f", [player chargeLevel]);
#endif
    if ([_advancementConditions objectForKey:GameStateConditionPlayerSizeThreshold] != nil){
        //If PlayerSizeThreshold is a condition we should monitor that state
        NSDictionary *condition = [_advancementConditions objectForKey:GameStateConditionPlayerSizeThreshold];
        if (thePlayer.chargeLevel >= [[condition valueForKey:GSConditionPropertyThresholdKey] floatValue]){
            [_satisfiedConditions setValue:[NSNumber numberWithBool:YES] forKey:GameStateConditionPlayerSizeThreshold];
        }
    }
}
-(void)playerCollided:(id)player andObject:(id)object{
    GameObject *gObject = (GameObject*)object;
    
    if (gObject.identifier == GameObjectIDGoal){
#if GAME_STATE_DEBUG
        NSLog(@"Player Touched Goal");
#endif
        _playerTouchedGoal = YES;
    }
    else if ([_advancementConditions objectForKey:GameStateConditionObjectCollisionBegan] != nil){
        NSString *conditionObjectName = [_advancementConditions objectForKey:GameStateConditionObjectCollisionBegan];
        if ([gObject.name isEqualToString:conditionObjectName]){
            [_satisfiedConditions setValue:[NSNumber numberWithBool:YES] forKey:GameStateConditionObjectCollisionBegan];
        }
    }
}
-(void)playerCollisionEnded:(id)player andObject:(id)object{
    GameObject *gObject = (GameObject*)object;
    
    if ([_advancementConditions objectForKey:GameStateConditionObjectCollisionEnded] != nil){
        NSString *conditionObjectName = [_advancementConditions objectForKey:GameStateConditionObjectCollisionEnded];
        if ([gObject.name isEqualToString:conditionObjectName]){
            [_satisfiedConditions setValue:[NSNumber numberWithBool:YES] forKey:GameStateConditionObjectCollisionEnded];
        }
    }
}
-(void)playerTappedScreen:(id)touch{
    if ([_satisfiedConditions objectForKey:GameStateConditionPlayerTap] != nil){
        [_satisfiedConditions setObject:[NSNumber numberWithBool:YES] forKey:GameStateConditionPlayerTap];
    }
}


#pragma mark - State Factory

+(GameState*)defaultInitialState{
    return [[[GameState alloc] init] autorelease];
}

#pragma mark - Memory Management
-(void)dealloc{
    [_gameStateModifications release];
    [_advancementConditions release];
    [_satisfiedConditions release];
    [super dealloc];
}
@end
