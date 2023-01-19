#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <inttypes.h>

enum {len=230454};
uint8_t buff[len];

void shade(
    uint8_t r1, uint8_t g1, uint8_t b1,
    uint8_t r2, uint8_t g2, uint8_t b2,
    uint8_t r3, uint8_t g3, uint8_t b3,
    uint8_t* imageDataArray);

void setBmpHeader(uint8_t* buff){
    uint8_t bytes[37] = {
        0x42, 0x4D, 0x36, 0x84, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x36, 0x00,
        0x00, 0x00, 0x28, 0x00, 0x00, 0x00, 0x40, 0x01, 0x00, 0x00, 0xF0, 0x00,
        0x00, 0x00, 0x01, 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x84,
        0x03
    };
    for(size_t i = 0; i < 37; ++i){
        *buff = bytes[i];
        ++buff; 
    }
}

int main(){
    uint8_t r1, g1, b1, r2, g2, b2, r3, g3, b3;
    uint8_t r, g, b;
    printf("Please input RGB values for the first vertice in the proper format, e.g. '238 130 238' to input violet: ");
    scanf("%" SCNu8 " %" SCNu8 " %" SCNu8, &r1,&g1,&b1);
    printf("Please input RGB values for the second vertice: ");
    scanf("%" SCNu8 " %" SCNu8 " %" SCNu8, &r2,&g2,&b2);
    printf("Please input RGB values for the third vertice: ");
    scanf("%" SCNu8 " %" SCNu8 " %" SCNu8, &r3,&g3,&b3);
        
    setBmpHeader(buff);
    shade(r1, g1, b1, r2, g2, b2, r3, g3, b3, buff+54);

    printf("Opening file...");
    FILE *imgFile;
    imgFile = fopen("shading.bmp", "wb");
	if (imgFile == NULL)
	{
		printf("Error!\n");
		return -1;
	}
    else printf("Success\n");

    fwrite(buff, len, 1, imgFile);
	fclose(imgFile);

    return 0;
}
