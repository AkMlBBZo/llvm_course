#include "sim.h"

#define PIXEL_SIZE 4
#define X_SIZE SIM_X_SIZE / PIXEL_SIZE
#define Y_SIZE SIM_Y_SIZE / PIXEL_SIZE
#define ADDED_HEIGH 64
#define COLOR_MAX_HEIGH 512
#define MIN_RED 64

int field[X_SIZE][Y_SIZE] = {0};
int field_copy[X_SIZE][Y_SIZE] = {0};

const int dirs_x[4] = {-1, 0, 1, 0};
const int dirs_y[4] = {0, -1, 0, 1};

int getX(int pos) {
  return (pos >> 16) / PIXEL_SIZE;
}

int getY(int pos) {
  return (pos & 0xffff) / PIXEL_SIZE;
}

int calcColor(int heigh) {
  if (heigh == 0) return 0xFF000000;
  if (heigh == 1) return 0xFF00A000;
  if (heigh == 2) return 0xFF800080;
  if (heigh == 3) return 0xFFFFD700;
  
  if (heigh >= COLOR_MAX_HEIGH) {
    heigh = COLOR_MAX_HEIGH;
  }

  int red = MIN_RED + ((255 - MIN_RED) * heigh) / COLOR_MAX_HEIGH; 

  return 0xFF000000 | (red << 16);
}

void simulate() {
  for(int x = 0; x < X_SIZE; ++x) {
    for(int y = 0; y < Y_SIZE; ++y) {
      field_copy[x][y] += field[x][y];
      
      if (field[x][y] >= 4) {
        for(int i = 0; i < 4; ++i) {
          int cx = x + dirs_x[i];
          int cy = y + dirs_y[i];

          if (cx >= 0 && cx < X_SIZE && cy >= 0 && cy < Y_SIZE) {
            ++field_copy[cx][cy];
          }
        }
        field_copy[x][y] -= 4;
      }
    }
  }
  
  for(int x = 0; x < X_SIZE; ++x) {
    for(int y = 0; y < Y_SIZE; ++y) {
      field[x][y] = field_copy[x][y];
      field_copy[x][y] = 0;
    }
  }
}

void addSand(int pos) {
  int px = getX(pos);
  int py = getY(pos);
  field[px][py] += ADDED_HEIGH;
}

void app(void) {
  while(1) {
    while(simHasClick()) {
      addSand(simGetClick());
    }

    simulate();

    for(int x = 0; x < SIM_X_SIZE; ++x) {
      for(int y = 0; y < SIM_Y_SIZE; ++y) {
        simPutPixel(x, y, calcColor(field[x / PIXEL_SIZE][y / PIXEL_SIZE]));
      }
    }
    simFlush();
  }
}
