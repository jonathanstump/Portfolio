
#include <stdlib.h>
#include <string.h>

#include <stdlib.h>
#include <string.h>

// include NESLIB header
#include "neslib.h"

// include CC65 NES Header (PPU)
#include <nes.h>

// link the pattern table into CHR ROM
//#link "chr_generic.s"

// BCD arithmetic support
#include "bcd.h"
//#link "bcd.c"

// VRAM update buffer
#include "vrambuf.h"
//#link "vrambuf.c"

#define NUM_ACTORS 64   // Max sprites for NES
#define PLAYER_START_HEALTH 20


#define DEF_METASPRITE_2x2(name,code,pal)\
const unsigned char name[]={\
        0,      0,      (code)+0,   pal, \
        0,      8,      (code)+1,   pal, \
        8,      0,      (code)+2,   pal, \
        8,      8,      (code)+3,   pal, \
        128};

// define a 2x2 metasprite, flipped horizontally
#define DEF_METASPRITE_2x2_FLIP(name,code,pal)\
const unsigned char name[]={\
        8,      0,      (code)+0,   (pal)|OAM_FLIP_H, \
        8,      8,      (code)+1,   (pal)|OAM_FLIP_H, \
        0,      0,      (code)+2,   (pal)|OAM_FLIP_H, \
        0,      8,      (code)+3,   (pal)|OAM_FLIP_H, \
        128};

#define DEF_METASPRITE_2x2_FLIPV(name,code,pal)\
const unsigned char name[]={\
        0,      8,      (code)+0,   pal, \
        0,      0,      (code)+1,   pal, \
        8,      8,      (code)+2,   pal, \
        8,      0,      (code)+3,   pal, \
        128};

#define DEF_METASPRITE_2x2_FLIPHV(name,code,pal)\
const unsigned char name[]={\
        8,      8,      (code)+0,   pal, \
        8,      0,      (code)+1,   pal, \
        0,      8,      (code)+2,   pal, \
        0,      0,      (code)+3,   pal, \
        128};

DEF_METASPRITE_2x2(playerRStand, 0xd8, 2);
DEF_METASPRITE_2x2(playerRRun1, 0xdc, 2);
DEF_METASPRITE_2x2(playerRRun2, 0xe0, 2);
DEF_METASPRITE_2x2(playerRRun3, 0xe4, 2);
DEF_METASPRITE_2x2(playerRJump, 0xe8, 2);
DEF_METASPRITE_2x2(playerRClimb, 0xec, 2);
DEF_METASPRITE_2x2(playerRSad, 0xf0, 2);
DEF_METASPRITE_2x2(flowers, 0xc4, 2);


DEF_METASPRITE_2x2_FLIP(playerLStand, 0xd8, 2);
DEF_METASPRITE_2x2_FLIP(playerLRun1, 0xdc, 2);
DEF_METASPRITE_2x2_FLIP(playerLRun2, 0xe0, 2);
DEF_METASPRITE_2x2_FLIP(playerLRun3, 0xe4, 2);
DEF_METASPRITE_2x2_FLIP(playerLJump, 0xe8, 2);
DEF_METASPRITE_2x2_FLIP(playerLClimb, 0xec, 2);
DEF_METASPRITE_2x2_FLIP(playerLSad, 0xf0, 2);

DEF_METASPRITE_2x2(tankLRun1, 0x0c, 3);
DEF_METASPRITE_2x2(tankLRun2, 0xfc, 3);
DEF_METASPRITE_2x2_FLIP(tankRRun1, 0x0c, 3);
DEF_METASPRITE_2x2_FLIP(tankRRun2, 0xfc, 3);

DEF_METASPRITE_2x2(playerRRunUp1, 0xec, 2);
DEF_METASPRITE_2x2(playerRRunUp2, 0xf0, 2);

// Defining the metasprites for running down
DEF_METASPRITE_2x2(playerRRunDown1, 0xf4, 2);
DEF_METASPRITE_2x2(playerRRunDown2, 0xf8, 2);

// Defining the left-facing metasprites for running up and down
DEF_METASPRITE_2x2_FLIP(playerLRunUp1, 0xec, 2);
DEF_METASPRITE_2x2_FLIP(playerLRunUp2, 0xf0, 2);
DEF_METASPRITE_2x2_FLIP(playerLRunDown1, 0xf4, 2);
DEF_METASPRITE_2x2_FLIP(playerLRunDown2, 0xf8, 2);

/*{pal:"nes",layout:"nes"}*/
const char PALETTE[32] = { 
  0x09,			// screen color

  0x07,0x19,0x22,0x00,	// background palette 0
  0x0E,0x07,0x17,0x00,	// background palette 1
  0x00,0x10,0x20,0x00,	// background palette 2
  0x07,0x27,0x28,0x00,   // background palette 3

  0x16,0x35,0x24,0x00,	// sprite palette 0
  0x0D,0x37,0x26,0x00,	// sprite palette 1
  0x0D,0x37,0x17,0x00,	// sprite palette 2
  0x0D,0x38,0x16	// sprite palette 3
};

const char FLASH_PALETTE[32] = {
  0x06,			// screen color

  0x07,0x19,0x22,0x00,	// background palette 0
  0x0E,0x07,0x17,0x00,	// background palette 1
  0x00,0x10,0x20,0x00,	// background palette 2
  0x07,0x27,0x28,0x00,   // background palette 3

  0x16,0x35,0x24,0x00,	// sprite palette 0
  0x0D,0x37,0x26,0x00,	// sprite palette 1
  0x0D,0x37,0x17,0x00,	// sprite palette 2
  0x0D,0x38,0x16	// sprite palette 3
};

const char ATTRIBUTE_TABLE[0x40] = {
  0xaa, 0xa0, 0xa0, 0xa0, 0x00, 0x00, 0x00, 0x00,
  0x88, 0x00, 0x00, 0x00, 0x22, 0x55, 0x55, 0x55,
  0x88, 0x00, 0x00, 0x00, 0x22, 0x55, 0x55, 0x55,
  0x00, 0x0a, 0x0a, 0x0a, 0x00, 0x55, 0x55, 0x55,
  0x00, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00,
  0x00, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00,
  0x00, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
};

const char GAME_OVER_AT[0x40] = {
  0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
  0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
  0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
  0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
  0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
  0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
  0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
  0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa, 0xaa,
};

const unsigned char* const tankRunSeq[4] = {
  tankLRun1, tankLRun2,
  tankRRun1, tankRRun2,
};

const unsigned char* const playerRunSeq[32] = {
  playerLRun1, playerLRun2, playerLRun3, 
  playerLRun1, playerLRun2, playerLRun3, 
  playerLRun1, playerLRun2,
  playerRRun1, playerRRun2, playerRRun3, 
  playerRRun1, playerRRun2, playerRRun3, 
  playerRRun1, playerRRun2,

  // Add the running up and down sequences
  playerRRunUp1, playerRRunUp1, playerRRunUp2, playerRRunUp2,
  playerLRunUp2, playerLRunUp2, playerLRunUp1, playerLRunUp1,
  playerRRunDown1, playerRRunDown1, playerRRunDown2, playerRRunDown2,
  playerLRunDown2, playerLRunDown2, playerLRunDown1, playerLRunDown1,

};

const unsigned char sprite_tile_data[] = {
    0x83 
};


typedef enum {
  RUNNER,
  TANK,
  LEADER,
  NONE
} ZombieType;

typedef struct Gun {
  char damage;
} Gun;

typedef struct Bullet {
  byte x, y;
  sbyte dx, dy;
  char is_onscreen;
} Bullet;

typedef struct Player {
  signed char health;
  char speed;
  char multiplier;
  Gun pistol;
  byte x, y;
  sbyte dx, dy;
  sbyte prev_dx;
  int direction;
  char dollars;
} Player;

typedef struct Zombie {
  signed char health;
  char speed;
  char damage;
  char x, y;
  char dx, dy;
  ZombieType type;
  char commit;
  char time_since_hit;
  char first_x, first_y;
} Zombie;

Player player;
int frame_count = 0;
int numRunners, numTanks;

// array for all zomies
Zombie zombies[NUM_ACTORS];
int total_actors = 0;
int displaying_wave = 0;

Bullet bullets[5];
int numBullets = 0;
int prev_numBullets = 0;

int wave = 1;
char prev_pad = 0;
char oam_id;
char pad;
byte runseq;
char i;
char str[10];  
char mult_num[4];  
char bulls[3];
int animate = 0;
char health_status;
char value;
char prev_multiplier = 0;
signed char flash_timer = 0;   
char is_flash_active = 0; 
char upgrades_achieved = 0;
char bigger_bullets = 0;

// game state declaration, graphics, and control
void generate_map();
void setup_graphics();
void setup_game();
void generate_wave(int wave);
void display_wave(int wave);
byte go_to_next_wave();
void check_erase_wave();
void initialize_player();
void initialize_zombie(Zombie *zombie, ZombieType type, char total);
void player_has_lost();
void end_graphics();
void draw_health_bar();
void display_multiplier();
void update_ammo_graphic();
void next_wave_achieved();
void update_variables_every_loop();

// collision and movement
void check_collision();
int is_valid_area(char x, char y, char type);
int is_collided_zombie_bullet(Zombie *z, Bullet *b);
int is_collided_zombie_player(Zombie *z);
char ai_is_inbounds(char x, char y);
void move_towards_player(Zombie* zombie, Player* player);
void trigger_flash();
void update_flash();
void damage_player(int amount);
void update_zombies();
void update_player();

// shoot and bullet logic
void shoot(int direction);
void initialize_bullets();
void update_bullets();
void draw_bullets();

// upgrade logic
void upgrade_graphics();
void continue_game();
void check_upgrades();
void achieved_upgrade();

void generate_map() {
    int i = 0;
    int j = 0;
    char sprite = 0;

    // Flowers 
    for(i = 4; i < 16; i++) {
        for(j = 4; j < 12; j++) {
            unsigned char tile_value = 0;

            if (i % 2 == 0 && j % 2 == 0) {
                tile_value = 0xC4; 
            } else if (i % 2 == 0 && j % 2 == 1) {
                tile_value = 0xC5; 
            } else if (i % 2 == 1 && j % 2 == 0) {
                tile_value = 0xC6;  
            } else if (i % 2 == 1 && j % 2 == 1) {
                tile_value = 0xC7;  
            }

            vram_adr(NTADR_A(i, j));
            vram_write(&tile_value, 1);  
        }
    }

    // Wheat 
    for(i = 5; i < 16; i++) {
        for(j = 16; j < 28; j++) {
            unsigned char tile_value = 0;

            if (i % 2 == 0 && j % 4 == 0) {
                tile_value = 0xD0;  // Tile at D0
            } else if (i % 2 == 0 && j % 4 == 1) {
                tile_value = 0xD1;  // Tile at D1
            } else if (i % 2 == 1 && j % 4 == 0) {
                tile_value = 0xD2;  // Tile at D2
            } else if (i % 2 == 1 && j % 4 == 1) {
                tile_value = 0xD3;  // Tile at D3
            }

            
            vram_adr(NTADR_A(i, j)); 
            vram_write(&tile_value, 1);  
        }
    }

   // All Boxes
  sprite = 0xC8;
  vram_adr(NTADR_A(20, 4)); 
  vram_write(&sprite, 1);     

  sprite = 0xCA;
  vram_adr(NTADR_A(21, 4));  
  vram_write(&sprite, 1);     

  sprite = 0xC9;
  vram_adr(NTADR_A(20, 5));  
  vram_write(&sprite, 1);     

  sprite = 0xCB;
  vram_adr(NTADR_A(21, 5));  
  vram_write(&sprite, 1);     

  sprite = 0xC8;
  vram_adr(NTADR_A(25, 7)); 
  vram_write(&sprite, 1);     

  sprite = 0xCA;
  vram_adr(NTADR_A(26, 7));  
  vram_write(&sprite, 1);     

  sprite = 0xC9;
  vram_adr(NTADR_A(25, 8));  
  vram_write(&sprite, 1);     

  sprite = 0xCB;
  vram_adr(NTADR_A(26, 8));  
  vram_write(&sprite, 1);     
  
   sprite = 0xC8;
  vram_adr(NTADR_A(20, 12));  
  vram_write(&sprite, 1);     

  sprite = 0xCA;
  vram_adr(NTADR_A(21, 12));  
  vram_write(&sprite, 1);     

  sprite = 0xC9;
  vram_adr(NTADR_A(20, 13)); 
  vram_write(&sprite, 1);     

  sprite = 0xCB;
  vram_adr(NTADR_A(21, 13));  
  vram_write(&sprite, 1);     
  //End Boxes
  
  
 //All fences
  for(i = 4; i < 16; i++) {
    sprite = 0xAC;
    vram_adr(NTADR_A(i,3));
    vram_write(&sprite,1);
  }
  
  for(i = 4; i < 16; i++) {
    sprite = 0xA9;
    vram_adr(NTADR_A(i,12));
    vram_write(&sprite,1);
  }
  
  
  for(i = 4; i < 12; i++) {
    if (i != 7 && i != 6){
      sprite = 0xAB;
      vram_adr(NTADR_A(3, i));
      vram_write(&sprite,1);
    }
  }
  
  for(i = 4; i < 12; i++) {
    if (i != 9 && i != 10){
      sprite = 0xAA;
      vram_adr(NTADR_A(16, i));
      vram_write(&sprite,1);
    }
  }
  
  // multiplier
  itoa(player.multiplier, mult_num, 10);
  strcpy(str, "x");  
  strcat(str, mult_num);
  vram_adr(NTADR_A(2,2));
  vram_write(str, strlen(str));
  
  // ammo
  itoa(5-numBullets, bulls, 10);
  strcpy(str, "Ammo: ");  
  strcat(str, bulls);
  strcat(str, "/5");
  vram_adr(NTADR_A(20, 26));
  vram_write(str, strlen(str));
  
  
}

int is_valid_area(char x, char y, char type){
  char feet;
  char right;
  char i;
  char mult = type == 1 ? 0 : 1;
  
  
  //metasprite vs one by one
  if(type == 0){
    feet = y + 16;
    right = x + 16;
  } else{
    feet = y + 8;
    right = x + 8;
  }
  
  // wheat
  for(i=0; i<80; i+=32){
    if((feet >= 128+i) && (feet-(2*mult) <= 144+i)){
      if((right >= 40) && (x <= 128)){
        return 0;
      }
    }
  }
  
  //boxes
  if((feet >= 32) && (feet-(4*mult) <= 48)){
    if((right >= 160) && (x <= 172)){
      return 0;
    }
  }
   if((feet >= 56) && (feet-(4*mult) <= 72)){
    if((right >= 202) && (x <= 214)){
      return 0;
    }
  }
  if((feet >= 96) && (feet-(4*mult) <= 112)){
    if((right >= 160) && (x <= 172)){
      return 0;
    }
  }
  
 // fence
 if(type == 0){
  if(right == 34 || x == 28){
    if(feet >= 40 && feet <= 50){
      return 0;
    } else if (feet>=64 && feet <= 98){
      return 0;
    }
  }  
  
  if(right == 34 + 96 || x == 28 +96 ){
    if(feet >= 40 && feet <= 72 ){
      return 0;
    } else if (feet>=90 && feet <= 98){
      return 0;
    }
  }  
  

  if(feet == 32 || y == 28) {
    if (right >= 32 && right <=34 + 96){
      return 0;
    }
  }

  
  if(feet == 98 || y == 94) {
    if (right >= 32 && right <=34 + 96){
      return 0;
    }
  }
 }
  
  return 1;
}
  
void initialize_player() {
  player.health = PLAYER_START_HEALTH;
  player.speed = 3;
  player.pistol.damage = 2;
  player.x = 120;   
  player.y = 100;
  player.dx = 0;
  player.dy = 0;
  player.multiplier = 0;
  player.dollars = 0; // Player's bonus counter
}

void initialize_zombie(Zombie *zombie, ZombieType type, char total) {
  int x;

  zombie->commit = 0;    
  zombie->time_since_hit = 60;
  zombie->type = type;
  zombie->x = rand() % 240;  // Random X position
  zombie->y = rand() % 224;  // Random Y position
  if(zombie->x % 4 == 0){
    zombie->y = 200;
  }
  else if(zombie->x % 4 == 1){
    zombie->y = 24;
  }
  else if(zombie->x % 4 == 2){
    zombie->x = 24;
  }
  else if(zombie->x % 4 == 3){
    zombie->x = 216;
  }
  x = x+ total;
  zombie->first_x = zombie->x;
  zombie->first_y = zombie->y;

  switch(type) {
    case RUNNER: // Little zombies 
      zombie->health = 10;
      zombie->speed = 7;
      zombie->damage = 2;
      break;
    case TANK: // Big zombies
      zombie->health = 22;
      zombie->speed = 5;
      zombie->damage = 7;
      break;
    default:
      break;
  }
}


void generate_wave(int wave) {
 //Change values to change number of zombies spawning each wave
  int i;
  animate = 0;
 //Tank round every 7 rounds
  if (wave % 7 == 0){
    numRunners = 0;
    numTanks = wave - 2;
  } else {
    numRunners = wave +1;
    numTanks = wave -3;
  }
//Initialize zombies
  total_actors = 0;
  for (i = 0; i < numRunners && total_actors < NUM_ACTORS; i++, total_actors++) {
    initialize_zombie(&zombies[total_actors], RUNNER, i);
  }
  for (i = 0; i < numTanks && total_actors < NUM_ACTORS; i++, total_actors++) {
    initialize_zombie(&zombies[total_actors], TANK, i);
  }
}


void display_wnum(int wave){
//Display wave number at the start of each round
  char wave_num[3];
  char output[10];
  
  itoa(wave, wave_num, 10);
  strcpy(output, "Wave ");
  strcat(output, wave_num);
  
  vrambuf_put(NTADR_A(13, 14), output, strlen(output)); 
  displaying_wave = 1; 
}

void check_erase_wave(){
//Create a delay for when to stop displaying wave numbers.
  if (displaying_wave) {
    if (frame_count >= 180) { 
      vrambuf_put(NTADR_A(13,14),"        ", 8); 
      frame_count = 0;  
      displaying_wave = 0;  
    } else {
      frame_count++; 
    }
  }
}

byte go_to_next_wave(){
  char i;
  for(i=0; i<total_actors; i++){
    if(zombies[i].health > 0){
      return 0;
    }
  }
  return 1;
}

char ai_is_inbounds(char x, char y){
//Make sure that the zombies spawn in bounds and stay inbounds
  if((x < 8) || (x > 232)){
      return 0;
   } else if((y < 8) || (y > 216)){
      return 0;
   }
   return 1;
}

void move_towards_player(Zombie* zombie, Player* player) {
   //Function to automate zombies movement and ensure they're always chasing after the player
    int dx = player->x - zombie->x; 
    int dy = player->y - zombie->y;
    char type;
   // char i;
    char r = rand() % 2;
    char speed = zombie->speed / 2;
    char add_y = rand() % speed;
    char add_x = speed - add_y;

    type = (zombie->type == RUNNER) ? 1 : 0; 
    
    if((!is_valid_area(zombie->x, zombie->y + 1, type)) 
        || (!is_valid_area(zombie->x, zombie->y - 1, type))){
        if(zombie->commit == 0){
          zombie->commit = player->direction;
          zombie->x += zombie->commit*speed;
        }else{
          zombie->x += zombie->commit*speed;
        }
    }else if((!is_valid_area(zombie->x + 1, zombie->y, type)) 
        || (!is_valid_area(zombie->x - 1, zombie->y, type))){
      if(zombie->commit == 0){
          zombie->commit = dy > 0 ? 1 : -1;
          zombie->y += zombie->commit*speed;
        }else{
          zombie->y += zombie->commit*speed;
        }
    } else{
          zombie->commit = 0;
          // alternate movements to ensure all zombies don't fully group up on top of each other
          if (r == 0) {
            if (dx > 0) {  
               if(ai_is_inbounds(zombie->x + add_x, zombie->y)){
                 zombie->x += add_x;
               }
            } else {  
               if(ai_is_inbounds(zombie->x - add_x, zombie->y)){
                 zombie->x -= add_x;
               }
            }
        } else {
            if (dy > 0) {
              if(ai_is_inbounds(zombie->x, zombie->y+add_y)){
                 zombie->y += add_y;
              }
            }else {  
              if(ai_is_inbounds(zombie->x, zombie->y-add_y)){
                 zombie->y -= add_y;
              }
            }
        }
      }
}

void shoot(int direction) {
    //Handling the calls of object pool\bullets
    Bullet bullet;
    char i;
    
    // Set the bullet's initial position to be just in front of the player
    bullet.x = player.x + (8 * direction);  
    bullet.y = player.y + 4; 

    bullet.dx = 7 * direction; 
    bullet.dy = 0; 
    
    bullet.is_onscreen = 1; 
    
    for(i=0; i<5; i++){
      if(bullets[i].is_onscreen == 0){ 
        bullets[i] = bullet;
        numBullets++;  
        return;
      }
    }
    
}

void draw_bullets() {
  // Handle display of bullets
  for (i = 0; i < 5; i++) {
    if (bullets[i].is_onscreen) {
      oam_id = oam_spr(bullets[i].x, bullets[i].y, 0x2D, 0, oam_id); 
    }
  }
}

void update_bullets() {
//Update the position of the bullets so it appears they are traveling across the screen.
  int i;

  for (i = 0; i < 5; i++) {
    if (bullets[i].is_onscreen) {
      bullets[i].x += bullets[i].dx;
      // If the bullet reaches the limit of the screen, set it as inactive
      if (bullets[i].x <= 0 || bullets[i].x >= 240) {
          bullets[i].is_onscreen = 0; 
          numBullets--;
      }else if(!is_valid_area(bullets[i].x, bullets[i].y, 1)){
         bullets[i].is_onscreen = 0; 
         numBullets--;
      }
    }
  }
}

void initialize_bullets() {
  char i;
    for (i = 0; i < 5; i++) {
        bullets[i].x = -1000;           
        bullets[i].y = -1000;          
        bullets[i].dx = 0;         
        bullets[i].dy = 0;          
        bullets[i].is_onscreen = 0;
    }
}

void update_flash() {
   //Creates the flash effect when the player is damaged by a zombie
    if (is_flash_active) {
        pal_bg(FLASH_PALETTE); 
        if (flash_timer <= 0) {
            is_flash_active = 0; 
            pal_bg(PALETTE);
        } else {
            flash_timer--;
        }
    }
}

void trigger_flash() {
//Flash effect when the player is damaged by a zombie
    if (!is_flash_active) {  
        is_flash_active = 1;
        flash_timer = 5;
    }
}



int is_collided_zombie_bullet(Zombie *z, Bullet *b){
  //Checks to see if a zombie is hit by a bullet
  char top = z->y;
  char bottom = z->y + 8;
  char left = z->x;
  char right = z->x + 8;
  if((b->y >= top) && (b->y <= bottom)){
    if((b->x <= right) && (b->x >= left)){
      return 1;
    }
  }
  return 0;
}

int is_collided_zombie_player(Zombie *z){
  //
  char top = player.y;
  char bottom = player.y + 16;
  char left = player.x;
  char right = player.x + 16;
  char z_top = z->y;
  char z_bottom = z->y+8;
  char z_left = z->x;
  char z_right = z->x+8;
  if((z_top >= bottom && z_top <= top) || (z_bottom >= top && z_bottom <= bottom)){
    if(z_left <= right && z_left >= left){
      return 1;
    }else if(z_right >= left && z_right <= right){
      return 1;
    }
  }
}

void damage_player(int amount) {
  player.health -= amount;
  if (player.health < 0) {
    player.health = 0; 
  }
}


void check_collision(){
  char i;
  char j;
  for(i=0; i<5; i++){
    if(bullets[i].is_onscreen){
      for(j=0; j<total_actors; j++){
        if(zombies[j].health > 0){
          if(is_collided_zombie_bullet(&zombies[j], &bullets[i])){
            zombies[j].health -= player.pistol.damage;
            bullets[i].is_onscreen = 0;
            bullets[i].x = -1000;
            bullets[i].y = -1000;
            numBullets--;
            player.multiplier += 1;
          }
        }
      }
    }
  }
  for(j=0; j<total_actors; j++){
    if(zombies[j].health > 0){
     if(is_collided_zombie_player(&zombies[j]) && zombies[j].time_since_hit >= 30){
       damage_player(zombies[j].damage);
       zombies[j].time_since_hit = 0;
       trigger_flash();
       player.multiplier = 0;
     }
      zombies[j].time_since_hit++;
    }
  }
  
}

void continue_game(){
    setup_graphics();
    vrambuf_clear();
    set_vram_update(updbuf);
    generate_wave(wave);
    display_wnum(wave);

    generate_map();
    ppu_on_all();
}

void achieved_upgrade(){
  while(1){
    ppu_off();
    vrambuf_clear();
    upgrade_graphics();
    ppu_on_all();
    pad = pad_poll(0);
    if(pad & PAD_A){
      wave++;
      ppu_off(); 
      vram_adr(NAMETABLE_A);
      vram_fill(0x00, 32*30);
      continue_game();
      break;
    }
  }
}

void upgrade_graphics(){
    char value = 0x24;
      oam_clear();
      pal_all(PALETTE);
      vram_adr(NAMETABLE_A);
      vram_fill(0x00, 32*30);
      vram_adr(NAMETABLE_A + 0x3c0);
      vram_write(GAME_OVER_AT, sizeof(GAME_OVER_AT));
      for(i = player.dollars; i > 0; i--) {
        vram_adr(NTADR_A(16 - i, 15)); 
        vram_write(&value, 1);
      }

      if (upgrades_achieved == 0) {
        vram_adr(NTADR_A(11, 17));
        vram_write("Speed + 1", 9);
        player.speed += 1;
      } else if (upgrades_achieved == 1) {
        vram_adr(NTADR_A(11, 17));
        vram_write("Damage + 1", 10);
        player.pistol.damage = 3;
      } else if (upgrades_achieved == 2) {
        vram_adr(NTADR_A(9, 17));
        vram_write("Bigger Bullets", 14);
        bigger_bullets = 1;
      } else if (upgrades_achieved == 3) {
        vram_adr(NTADR_A(11, 17));
        vram_write("Damage + 1", 10);
        player.pistol.damage = 4;
      }
}

void check_upgrades(){
  char i;
  if(player.dollars >=3){
    if(upgrades_achieved < 3){
     achieved_upgrade();    
     upgrades_achieved++;
    for(i=0; i<player.dollars; i++){
      vrambuf_put(NTADR_A(5+i, 2), " ", 1);
    }
   }else{
     for(i=0; i<player.dollars; i++){
      vrambuf_put(NTADR_A(5+i, 2), " ", 1);
     }
   }
   player.dollars = 0;
  }
      
}

void update_ammo_graphic(){
  if(numBullets != prev_numBullets){
     itoa(5-numBullets, bulls, 10);
     strcpy(str, "Ammo: ");  // Clear and prepare ammo text
     strcat(str, bulls);
     strcat(str, "/5");
     vrambuf_put(NTADR_A(20, 26), str, strlen(str));
   }
  prev_numBullets = numBullets;
}

void update_variables_every_loop(){
  animate++;
  oam_id = 0;
  health_status = player.health % 2 == 0 ? player.health/2 : (player.health + 1)/2;
}

void next_wave_achieved(){
   wave++;
   generate_wave(wave);
   display_wnum(wave);
   player.health += 3;
   if(player.health > 20) player.health = 20;
}

void update_player(){
        pad = pad_poll(0);
        if(player.dx != 0){
            player.prev_dx = player.dx;
        }
        if (pad & PAD_LEFT && player.x > 0) player.dx = -2;
        else if (pad & PAD_RIGHT && player.x < 240) player.dx = 2;
        else player.dx = 0;

        if (pad & PAD_UP && player.y > 0) player.dy = -2;
        else if (pad & PAD_DOWN && player.y < 212) player.dy = 2;
        else player.dy = 0;

        if(is_valid_area(player.x + player.dx, player.y + player.dy, 0)){
            player.x = player.x + player.dx;
            player.y = player.y + player.dy;
        }

         runseq = player.x & 7;  // Default running sequence

    // Horizontal movement 
   if(player.prev_dx > 0){
            runseq += 8;
            player.direction = 1;
        } else {
            player.direction = -1;
        }

   	 // Check for vertical movement
    if (player.dy < 0) {  
        // Alternate between four up sprites 
        runseq = 16 + ((player.y) & 7);  
    } else if (player.dy > 0) {  
        // Alternate between four down sprites 
        runseq = 24 + ((player.y) & 7); 
    }

    if(!bigger_bullets){
      if ((pad & PAD_A) && !(prev_pad & PAD_A)) {
          shoot(player.direction); 
      }

      prev_pad = pad;
    }else{
      if(pad & PAD_A){
        shoot(player.direction);
      }
    }
}

void update_zombies(){
        oam_id = oam_meta_spr(player.x, player.y, oam_id, playerRunSeq[runseq]);
        for(i = 0; i < numRunners; i++){
            if(zombies[i].health > 0){
                if (animate % 3 == 0){
                    oam_id = oam_spr(zombies[i].x, zombies[i].y, 0x90, 1 | OAM_FLIP_H, oam_id);
                } else if (animate % 3 == 1){
                    oam_id = oam_spr(zombies[i].x, zombies[i].y, 0x91, 1 | OAM_FLIP_H, oam_id);
                } else {
                    oam_id = oam_spr(zombies[i].x, zombies[i].y, 0x91, 1, oam_id);
                }
                move_towards_player(&zombies[i], &player);
             if(animate > 60 && zombies[i].x == zombies[i].first_x 
                && zombies[i].y == zombies[i].first_y){
               zombies[i].health = 0;
             }
            }
        }

        // Handle tank zombies
        for(i = numRunners; i < numTanks + numRunners; i++){
          if(zombies[i].health > 0){
            oam_id = oam_meta_spr(zombies[i].x, zombies[i].y, oam_id, tankRunSeq[animate % 4]);
            move_towards_player(&zombies[i], &player);
            if(animate > 60 && zombies[i].x == zombies[i].first_x 
                && zombies[i].y == zombies[i].first_y){
               zombies[i].health = 0;
            }
          }
        }
}

void draw_health_bar(){
  value = 0x80;
  for(i = 0; i < health_status; i++){
     vrambuf_put(NTADR_A(20 + i, 2), &value, 1);
     value++;
  }
  for(i = health_status; i<10; i++){
     vrambuf_put(NTADR_A(20+i, 2)," ", 1); 
  }
}

void display_multiplier(){
  char value;
  char i;
 if(player.multiplier >= 10){
   player.dollars++;
   value = 0x24;
   player.multiplier = 0;
   for(i=0; i<10; i++){
     if(i < player.dollars){
       vrambuf_put(NTADR_A(5+i, 2), &value, 1);
     }else{
       vrambuf_put(NTADR_A(5+i, 2), " ", 1);
     }
   }
 }
 if(player.multiplier != prev_multiplier){
  itoa(player.multiplier, mult_num, 10);
  strcpy(str, "x");   
  strcat(str, mult_num);
  vrambuf_put(NTADR_A(2, 2), str, strlen(str));  
 }
 prev_multiplier = player.multiplier;
}

void setup_graphics() {
  // clear sprites
  oam_clear();
  // set palette colors
  pal_all(PALETTE);
  vram_adr(NAMETABLE_A + 0x3c0);
  vram_write(ATTRIBUTE_TABLE, sizeof(ATTRIBUTE_TABLE));
}

void end_graphics(){
  oam_clear();
  pal_all(PALETTE);
  vram_adr(NAMETABLE_A);
  vram_fill(0x00, 32*30);
  vram_adr(NAMETABLE_A + 0x3c0);
  vram_write(GAME_OVER_AT, sizeof(GAME_OVER_AT));
  vram_adr(NTADR_A(11, 13));
  vram_write("GAME OVER", 9);
  vram_adr(NTADR_A(6, 15));
  vram_write("Press A to Try Again", 20);
}

void setup_game(){
  setup_graphics();
    initialize_bullets();
    vrambuf_clear();
    set_vram_update(updbuf);
    generate_wave(wave);
    display_wnum(wave);

    initialize_player();
    generate_map();
    ppu_on_all(); 
}

void player_has_lost(){
  while(1){
    // FLICKERING IS INTENTIONAL KEITH -- HAUNTING EFFECT
    ppu_off();
    vrambuf_clear();
    end_graphics();
    ppu_on_all();
    pad = pad_poll(0);
    if(pad & PAD_A){
      wave = 1;
      player.x = 120;
      player.y = 100;
      animate = 0;
      bigger_bullets = 0;
      upgrades_achieved = 0;
      numBullets = 0;
      is_flash_active = 0;
      ppu_off(); 
      vram_adr(NAMETABLE_A);
      vram_fill(0x00, 32*30);
      setup_game();
      break;
    }
  }
}


void main(void)
{   
    ppu_off();
    vrambuf_clear();
  
    setup_game();

    // Infinite loop
    while(1) {
        update_variables_every_loop();
        check_erase_wave();
        if(go_to_next_wave()){
           check_upgrades();
           next_wave_achieved();
        }
        check_collision();
        update_player();
        display_multiplier();
        update_ammo_graphic();
        update_zombies();
        update_flash();
        draw_health_bar();
        if(player.health <= 0){
          player_has_lost();
        }
        draw_bullets();
        update_bullets();

        if (oam_id != 0) oam_hide_rest(oam_id);
        vrambuf_flush();
        ppu_wait_frame();
    }
}