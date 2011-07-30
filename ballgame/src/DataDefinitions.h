//
//  DataDefinitions.h
//  ballgame
//
//  Created by Ryan Hart on 7/10/11.
//

//UI Definitions
#define PTM_RATIO 32
#define SCROLL_BORDER 150
#define PLAYER_Z_ORDER 10

typedef enum{
    LevelStatusStarted,
    LevelStatusCompleted
} LevelStatus;

typedef enum {
    GameObjectIDNone,
    GameObjectIDPlayer,
    GameObjectIDWall,
    GameObjectIDObstacle,
    GameObjectIDGoal,
    GameObjectIDPickup,
    GameObjectIDSwitch
} GameObjectID;
