#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/mman.h>
#include "hps_0.h"

#define REG_BASE 0xff200000 //LW H2F Bride Base Address
#define REG_SPAN 0x00200000 //LW H2F Bridge Span

//Addresses denoted in VHDL description
//Doubled due to read/write bit width
#define VGA_BLANK 0
#define PLAYER_RD_Y 2
#define PLAYER_RD_X 4
#define ENEMY_0_RD_Y 6
#define ENEMY_0_RD_X 8
#define ENEMY_1_RD_Y 10
#define ENEMY_1_RD_X 12
#define ENEMY_2_RD_Y 14
#define ENEMY_2_RD_X 16
#define ENEMY_3_RD_Y 18
#define ENEMY_3_RD_X 20
#define ENEMY_4_RD_Y 22
#define ENEMY_4_RD_X 24
#define ENEMY_5_RD_Y 26
#define ENEMY_5_RD_X 28
#define PLAYER_WRY_POS 30
#define PLAYER_WRX_POS 32
#define ENEMY_0_WRY_POS 34
#define ENEMY_0_WRX_POS 36
#define ENEMY_1_WRY_POS 38
#define ENEMY_1_WRX_POS 40
#define ENEMY_2_WRY_POS 42
#define ENEMY_2_WRX_POS 44
#define ENEMY_3_WRY_POS 46
#define ENEMY_3_WRX_POS 48
#define ENEMY_4_WRY_POS 50
#define ENEMY_4_WRX_POS 52
#define ENEMY_5_WRY_POS 54
#define ENEMY_5_WRX_POS 56
#define LEVEL_SELECT 68

#define RADIUS 10
// HTOTAL - HFRONT_PORCH - HACTIVE
#define LEFT_EDGE 144
// HTOTAL - HFRONT_PORCH
#define RIGHT_EDGE 774
// VTOTAL - VFRONT_PORCH - VACTIVE
#define TOP_EDGE 35
// VTOTAL - VFRONT_PORCH
#define BOTTOM_EDGE 515

//Pointer for base hardware address
void *base;

//Pointers for hex display hardware
uint32_t *hex2;
uint32_t *hex1;
uint32_t *hex0;

uint32_t *button_up;
uint32_t *button_down;
uint32_t *button_left;
uint32_t *button_right;

uint32_t *reset_button;

//Blanking signal for VGA hardware
uint16_t *blank;

//Player read/write data pointers
uint16_t *readPlayerY;
uint16_t *readPlayerX;
uint16_t *writePlayerY;
uint16_t *writePlayerX;

//Enemy 0 read/write data pointers
uint16_t *readEnemy_0_Y;
uint16_t *readEnemy_0_X;
uint16_t *writeEnemy_0_Y;
uint16_t *writeEnemy_0_X;

//Enemy 1 read/write data pointers
uint16_t *readEnemy_1_Y;
uint16_t *readEnemy_1_X;
uint16_t *writeEnemy_1_Y;
uint16_t *writeEnemy_1_X;

//Enemy 2 read/write data pointers
uint16_t *readEnemy_2_Y;
uint16_t *readEnemy_2_X;
uint16_t *writeEnemy_2_Y;
uint16_t *writeEnemy_2_X;

//Enemy 3 read/write data pointers
uint16_t *readEnemy_3_Y;
uint16_t *readEnemy_3_X;
uint16_t *writeEnemy_3_Y;
uint16_t *writeEnemy_3_X;

//Enemy 4 read/write data pointers
uint16_t *readEnemy_4_Y;
uint16_t *readEnemy_4_X;
uint16_t *writeEnemy_4_Y;
uint16_t *writeEnemy_4_X;

//Enemy 5 read/write data pointers
uint16_t *readEnemy_5_Y;
uint16_t *readEnemy_5_X;
uint16_t *writeEnemy_5_Y;
uint16_t *writeEnemy_5_X;

//Signal for hardware level update
uint16_t *levelSelect;

int fd;

//Player position variables
unsigned int playerX; //Player X position variable
unsigned int playerY; //Player Y position variable
unsigned int vx = 1; //Positive direction for player x
unsigned int vy = 1; //Positive direction for player y

//Enemy 0 position variables
unsigned int enemy0_X;
unsigned int enemy0_Y;
unsigned int e_vy0 = 1; //Positive direction for enemy 0 X
unsigned int e_vx0 = 1;//Positive direction for enemy 0 Y

//Enemy 1 position variables
unsigned int enemy1_X;
unsigned int enemy1_Y;
unsigned int e_vy1 = 1;
unsigned int e_vx1 = 1;

//Enemy 2 position variables
unsigned int enemy2_X;
unsigned int enemy2_Y;
unsigned int e_vy2 = 1;
unsigned int e_vx2 = 1;

//Enemy 3 position variables
unsigned int enemy3_X;
unsigned int enemy3_Y;
unsigned int e_vy3 = 1;
unsigned int e_vx3 = 1;

//Enemy 4 position variables
unsigned int enemy4_X;
unsigned int enemy4_Y;
unsigned int e_vy4 = 1;
unsigned int e_vx4 = 1;

//Enemy 5 position variables
unsigned int enemy5_X;
unsigned int enemy5_Y;
unsigned int e_vy5 = 1;
unsigned int e_vx5 = 1;

unsigned int levelResetFlag = 0; //Flag for enemy/player collisions
unsigned int levelNumber = 0; //Level counter, 0 is level 1

unsigned int deaths = 0; //Death counter

void writeSpriteX();
void writeSpriteY();
void resetLevel();

void handler(int signo){
	*hex0=0;
	*hex1=0;
	*hex2=0;
	*blank=0;
	munmap(base, REG_SPAN);
	close(fd);
	exit(0);
}

//Reset all sprite positions to initial values based on level number
//All value are in pixels, based on upper left-most pixel of each sprite
void resetLevel()
{
	switch(levelNumber)
	{
		case 0:
			playerX = 280;
			playerY = 245;
			
			enemy0_X = 350;
			enemy0_Y = 150;
			
			enemy1_X = 390;
			enemy1_Y = 380;
			
			enemy2_X = 430;
			enemy2_Y = 150;
			
			enemy3_X = 470;
			enemy3_Y = 380;
			
			enemy4_X = 510;
			enemy4_Y = 150;
			
			enemy5_X = 550;
			enemy5_Y = 380;
			break;
			
		case 1:
			playerX = 310;
			playerY = 245;
			
			enemy0_X = 290;
			enemy0_Y = 120;
			
			enemy1_X = 500;
			enemy1_Y = 150;
			
			enemy2_X = 290;
			enemy2_Y = 180;
			
			enemy3_X = 0;
			enemy3_Y = 0;
			
			enemy4_X = 0;
			enemy4_Y = 0;
			
			enemy5_X = 0;
			enemy5_Y = 0;
			break;
		case 2:
			playerX = 300;
			playerY = 240;
		
			enemy0_X = 265;
			enemy0_Y = 290;
			
			enemy1_X = 450;
			enemy1_Y = 300;
			
			enemy2_X = 490;
			enemy2_Y = 300;
			
			enemy3_X = 570;
			enemy3_Y = 300;
			
			enemy4_X = 530;
			enemy4_Y = 300;
			
			enemy5_X = 265;
			enemy5_Y = 345;
			break;
		default:
			playerX = 289;
			playerY = 257;
			
			enemy0_X = 300;
			enemy0_Y = 100;
			
			enemy1_X = 400;
			enemy1_Y = 100;
			
			enemy2_X = 200;
			enemy2_Y = 200;
			
			enemy3_X = 300;
			enemy3_Y = 200;
			
			enemy4_X = 400;
			enemy4_Y = 200;
			
			enemy5_X = 200;
			enemy5_Y = 300;
			break;
	}
	
	//Update X and Y positions on reset
	writeSpriteX();
	writeSpriteY();
}

//Manage user-inputted player motion, simple X and Y updating
void playerMotion()
{
	if(*button_up == 1)
	{
		playerY = playerY + vy;
	}
	if(*button_down == 1)
	{
		playerY = playerY - vy;
	}
	if(*button_left == 1)
	{
		playerX = playerX + vx;
	}
	if(*button_right == 1)
	{
		playerX = playerX - vx;
	}
}

//Manage all enmy motion on a per level basis
void enemyMotion()
{
	switch(levelNumber)
	{
		case 0:
			//Move enemy 0 on set path
			if(enemy0_Y < 149 | enemy0_Y > 380)
			{
				e_vy0 = -e_vy0;
			}
			
			//Move enemy 1 on set path
			if(enemy1_Y < 149 | enemy1_Y > 380)
			{
				e_vy1 = -e_vy1;
			}
			
			//Move enemy 2 on set path
			if(enemy2_Y < 149 | enemy2_Y > 380)
			{
				e_vy2 = -e_vy2;
			}
			
			//Move enemy 3 on set path
			if(enemy3_Y < 149 | enemy3_Y > 380)
			{
				e_vy3 = -e_vy3;
			}
			
			//Move enemy 4 on set path
			if(enemy4_Y < 149 | enemy4_Y > 380)
			{
				e_vy4 = -e_vy4;
			}
			
			//Move enemy 5 on set path
			if(enemy5_Y < 149 | enemy5_Y > 380)
			{
				e_vy5 = -e_vy5;
			}
			
			enemy0_Y = enemy0_Y + e_vy0;
			enemy1_Y = enemy1_Y + e_vy1;
			enemy2_Y = enemy2_Y + e_vy2;
			enemy3_Y = enemy3_Y + e_vy3;
			enemy4_Y = enemy4_Y + e_vy4;
			enemy5_Y = enemy5_Y + e_vy5;
			break;
		case 1:
			//Move enemy 0 on set path
			if(enemy0_X < 280 | enemy0_X > 660)
			{
				e_vx0 = -e_vx0;
			}
			
			//Move enemy 1 on set path
			if(enemy1_X < 350 | enemy1_X > 550)
			{
				e_vx1 = -e_vx1;
			}
			
			//Move enemy 2 on set path
			if(enemy2_X < 280 | enemy2_X > 660)
			{
				e_vx2 = -e_vx2;
			}
					
			enemy0_X = enemy0_X + e_vx0;
			enemy1_X = enemy1_X + e_vx1;
			enemy2_X = enemy2_X + e_vx2;
			
			break;
		case 2:
			//Move enemy 0 on set path
			if(enemy0_X < 250 | enemy0_X > 350)
			{
				e_vx0 = -e_vx0;
			}
			
			//Move enemy 3 on set path
			if(enemy3_Y < 210 | enemy3_Y > 380)
			{
				e_vy3 = -e_vy3;
			}
			
			//Move enemy 5 on set path
			if(enemy5_X < 260 | enemy5_X > 660)
			{
				e_vx5 = -e_vx5;
			}
			
			enemy0_X = enemy0_X + e_vx0;
			enemy3_Y = enemy3_Y + e_vy3;
			enemy5_X = enemy5_X + e_vx5;
			break;
		default:
			//Debugging movement path, game should never default to this state
			//Move enemy 0 on set path
			if(enemy0_X < 300 | enemy0_X > 310)
			{
				e_vx0 = -e_vx0;
			}
			
			//Move enemy 1 on set path
			if(enemy1_Y < 100 | enemy1_Y > 110)
			{
				e_vy1 = -e_vy1;
			}
			
			//Move enemy 2 on set path
			if(enemy2_X < 200 | enemy2_X > 210)
			{
				e_vx2 = -e_vx2;
			}
			
			//Move enemy 3 on set path
			if(enemy3_Y < 200 | enemy3_Y > 210)
			{
				e_vy3 = -e_vy3;
			}
			
			//Move enemy 4 on set path
			if(enemy4_X < 400 | enemy4_X > 410)
			{
				e_vx4 = -e_vx4;
			}
			
			//Move enemy 5 on set path
			if(enemy5_Y < 300 | enemy5_Y > 310)
			{
				e_vy5 = -e_vy5;
			}
	}
}

//Checks Enemy X and Y positions and compare them with player X and Y
//Positions, set reset flag if a collision is made
void checkEnemyPlayerCollision()
{
	//Reset position on collision
	if(levelResetFlag == 1)
	{
		levelResetFlag = 0;
		printf("Reset\n");
		deaths = deaths + 1;
		resetLevel();
		usleep(100);
	}
	
	else
	{
		//Enemy 0 detect
		if(((playerX+RADIUS >= enemy0_X-RADIUS) & (playerX-RADIUS <= enemy0_X+RADIUS))
			& ((playerY+RADIUS >= enemy0_Y-RADIUS) & (playerY-RADIUS <= enemy0_Y+RADIUS)))
		{
			levelResetFlag = 1;
		}
		
		//Enemy 1 detect
		if(((playerX+RADIUS >= enemy1_X-RADIUS) & (playerX-RADIUS <= enemy1_X+RADIUS))
			& ((playerY+RADIUS >= enemy1_Y-RADIUS) & (playerY-RADIUS <= enemy1_Y+RADIUS)))
		{
			levelResetFlag = 1;
		}
		
		//Enemy 2 detect
		if(((playerX+RADIUS >= enemy2_X-RADIUS) & (playerX-RADIUS <= enemy2_X+RADIUS))
			& ((playerY+RADIUS >= enemy2_Y-RADIUS) & (playerY-RADIUS <= enemy2_Y+RADIUS)))
		{
			levelResetFlag = 1;
		}
		
		//Enemy 3 detect
		if(((playerX+RADIUS >= enemy3_X-RADIUS) & (playerX-RADIUS <= enemy3_X+RADIUS))
			& ((playerY+RADIUS >= enemy3_Y-RADIUS) & (playerY-RADIUS <= enemy3_Y+RADIUS)))
		{
			levelResetFlag = 1;
		}
		
		//Enemy 4 detect
		if(((playerX+RADIUS >= enemy4_X-RADIUS) & (playerX-RADIUS <= enemy4_X+RADIUS))
			& ((playerY+RADIUS >= enemy4_Y-RADIUS) & (playerY-RADIUS <= enemy4_Y+RADIUS)))
		{
			levelResetFlag = 1;
		}
		
		//Enemy 5 detect
		if(((playerX+RADIUS >= enemy5_X-RADIUS) & (playerX-RADIUS <= enemy5_X+RADIUS))
			& ((playerY+RADIUS >= enemy5_Y-RADIUS) & (playerY-RADIUS <= enemy5_Y+RADIUS)))
		{
			levelResetFlag = 1;
		}
	}
}

//Software edge detections for each level dependent on sprite positions
void checkEdge()
{
	switch(levelNumber)
	{
		case 0:
			if(playerY == 139)
				playerY = playerY + vy;//down
			if(playerX == 329 && playerY < 205)
				playerX = playerX + vx;//right
			if(playerY == 209 && playerX < 330)
				playerY = playerY + vy;
			if(playerX == 252)
				playerX = playerX + vx;
			if(playerY == 285 && playerX < 330)
				playerY = playerY - vy;//up
			if(playerX == 329 && playerY > 285)
				playerX = playerX + vx;
			if(playerY == 389)
				playerY = playerY - vy;//up
			if(playerX == 578 && playerY > 285)
				playerX = playerX - vx;//left
			if(playerX == 578 && playerY < 205)
				playerX = playerX - vx;
			if(playerX == 598)
			{
				levelNumber++; //Next level
				resetLevel();  //Reset new level positions
				usleep(100);
			}
			break;
		case 1:
			if(playerY == 285)
				playerY = playerY - vy;
			if(playerY == 109)
				playerY = playerY + vy;
			if(playerX == 252)
				playerX = playerX + vx;
			if(playerX == 667)
				playerX = playerX - vx;
			if(playerX == 353 && playerY > 190)
				playerX = playerX - vx;
			if(playerY == 185 && (playerX > 354 && playerX < 599))
				playerY = playerY - vy;
			if(playerX == 599 && playerY > 230)
				playerX = playerX + vx;
			if(playerX > 599 && playerY>205)
			{
				levelNumber++;
				resetLevel();			
				usleep(100);
			}
			break;
		case 2:
			if(playerY == 209)
				playerY = playerY + vy;
			if(playerY == 389)
				playerY = playerY - vy;
			if(playerX == 252)
				playerX = playerX + vx;
			if(playerX == 667)
				playerX = playerX - vx;
			if(playerX == 353 && playerY < 305)
				playerX = playerX - vx;
			if(playerY == 309 && (playerX > 376 && playerX < 440))
				playerY = playerY + vy;
			if(playerX == 435 && playerY < 290)
			{
				levelNumber = 0;;
				resetLevel();		
				usleep(100);
			}
			break;
	}
}
//Write the X position of the game sprites to hardware
void writeSpriteX()
{
	*writePlayerX = playerX;
	*writeEnemy_0_X = enemy0_X;
	*writeEnemy_1_X = enemy1_X;
	*writeEnemy_2_X = enemy2_X;
	*writeEnemy_3_X = enemy3_X;
	*writeEnemy_4_X = enemy4_X;
	*writeEnemy_5_X = enemy5_X;
}

//Write the Y position of the game sprites to hardware
void writeSpriteY()
{
	*writePlayerY = playerY;
	*writeEnemy_0_Y = enemy0_Y;
	*writeEnemy_1_Y = enemy1_Y;
	*writeEnemy_2_Y = enemy2_Y;
	*writeEnemy_3_Y = enemy3_Y;
	*writeEnemy_4_Y = enemy4_Y;
	*writeEnemy_5_Y = enemy5_Y;
}

//Update the seven segment displays for the amount of player deaths
void updateDisplays()
{
	usleep(100);
	*hex0=deaths%10; //Ones
	usleep(100);
	*hex1=(deaths/10)%10; //Tens
	usleep(100);
	*hex2=(deaths/100)%10; //Hundreds
}

//Initialize all addresses for communication with hardware, address numbers defined above
void initAddresses()
{
	//Assign hex display addresses
	hex0=(uint32_t*)(base+HEX0_BASE);
	hex1=(uint32_t*)(base+HEX1_BASE);
	hex2=(uint32_t*)(base+HEX2_BASE);
	
	//Assign button addresses
	button_up=(uint32_t*)(base+BUTTON_UP_BASE);
	button_down=(uint32_t*)(base+BUTTON_DOWN_BASE);
	button_left=(uint32_t*)(base+BUTTON_LEFT_BASE);
	button_right=(uint32_t*)(base+BUTTON_RIGHT_BASE);
	
	//Assign reset switch address
	reset_button=(uint32_t*)(base+RESET_SWITCH_BASE);
	
	blank=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+VGA_BLANK);
	
	//Assign player addresses for reading/writing movement
	readPlayerY=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+PLAYER_RD_Y);
	readPlayerX=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+PLAYER_RD_X);
	writePlayerY=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+PLAYER_WRY_POS);
	writePlayerX=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+PLAYER_WRX_POS);
	
	//Assign enemy addresses for reading/writing movement
	readEnemy_0_Y=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_0_RD_Y);
	readEnemy_0_X=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_0_RD_X);
	writeEnemy_0_Y=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_0_WRY_POS);
	writeEnemy_0_X=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_0_WRX_POS);
	
	readEnemy_1_Y=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_1_RD_Y);
	readEnemy_1_X=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_1_RD_X);
	writeEnemy_1_Y=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_1_WRY_POS);
	writeEnemy_1_X=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_1_WRX_POS);
	
	readEnemy_2_Y=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_2_RD_Y);
	readEnemy_2_X=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_2_RD_X);
	writeEnemy_2_Y=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_2_WRY_POS);
	writeEnemy_2_X=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_2_WRX_POS);
	
	readEnemy_3_Y=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_3_RD_Y);
	readEnemy_3_X=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_3_RD_X);
	writeEnemy_3_Y=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_3_WRY_POS);
	writeEnemy_3_X=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_3_WRX_POS);
	
	readEnemy_4_Y=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_4_RD_Y);
	readEnemy_4_X=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_4_RD_X);
	writeEnemy_4_Y=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_4_WRY_POS);
	writeEnemy_4_X=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_4_WRX_POS);
	
	readEnemy_5_Y=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_5_RD_Y);
	readEnemy_5_X=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_5_RD_X);
	writeEnemy_5_Y=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_5_WRY_POS);
	writeEnemy_5_X=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+ENEMY_5_WRX_POS);
	
	//Harware Collision Detection
	levelSelect=(uint16_t*)(base+DE10_VGA_RASTER_SPRITES_0_BASE+LEVEL_SELECT);
	
	signal(SIGINT, handler); //handles crtl+c
	
	//Set initial values
	*hex0=0;
	*hex1=0;
	*hex2=0;

	//Write initial positions
	*writePlayerX = playerX;
	*writePlayerY = playerY;
	*writeEnemy_0_X = enemy0_X;
	*writeEnemy_0_Y = enemy0_Y;
	*writeEnemy_1_X = enemy1_X;
	*writeEnemy_1_Y = enemy1_Y;
	*writeEnemy_2_X = enemy2_X;
	*writeEnemy_2_Y = enemy2_Y;
	*writeEnemy_3_X = enemy3_X;
	*writeEnemy_3_Y = enemy3_Y;
	*writeEnemy_4_X = enemy4_X;
	*writeEnemy_4_Y = enemy4_Y;
	*writeEnemy_5_X = enemy5_X;
	*writeEnemy_5_Y = enemy5_Y;
}

//Main program loop/setup
int main(){
	deaths = 0;
	int i = 0;
	unsigned int is_blank = 0;
	
	fd=open("/dev/mem", O_RDWR|O_SYNC);
	if(fd<0){
		printf("Can't open memory\n");
		return -1;
	}
	//Assign base address from HPS address assignment
	base=mmap(NULL, REG_SPAN, PROT_READ|PROT_WRITE, MAP_SHARED, fd, REG_BASE);
	if(base==MAP_FAILED){
		printf("Can't map to memory\n");
		close(fd);
		return -1;
	}
	
	//Initialize all necessary Avalon bus addressing, set initial values
	initAddresses();
	resetLevel(); //Start off by resetting level, sets start positions
	
	for(;;){
		usleep(5000);
		
		while(!is_blank){
			is_blank = *blank;
			printf("Not blanked\n");
		}
		
		*levelSelect = levelNumber;
		
		//Reset levels, deaths, positions
		if(*reset_button == 1)
		{
			levelNumber = 0;
			deaths = 0;
			resetLevel();
		}
		
		else
		{
			//Collision Detection
			checkEnemyPlayerCollision();
			
			//Edge Detection
			checkEdge();
			
			if(levelResetFlag != 1)
			{
				playerMotion(); //Move player
				enemyMotion(); //Move enemys
				
				usleep(100);
				//Write position data to bus
				writeSpriteX();
				usleep(100);
				writeSpriteY();
				
				//Hex displays for deaths
				updateDisplays();
			}
		}
	}
}

