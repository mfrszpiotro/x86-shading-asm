#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>

//uint8_t buff[len];

void shade(
    //uint8_t
    char r1, char g1, char b1,
    char r2, char g2, char b2,
    char r3, char g3, char b3,
    //uint8_t*
    unsigned char* imageDataArray);

bool isColor(unsigned int number){
     return (0 <= number && number <= 255) ? 1 : 0;
}

void setBmpHeader(unsigned char* buff){
    unsigned char bytes[37] = {
        0x42, 0x4D, 0x36, 0x84, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x36, 0x00,
        0x00, 0x00, 0x28, 0x00, 0x00, 0x00, 0x40, 0x01, 0x00, 0x00, 0xF0, 0x00,
        0x00, 0x00, 0x01, 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x84,
        0x03
    };
    for(int i = 0; i < 37; ++i){
        *buff = bytes[i];
        ++buff; 
    }
}

// double getIa(){
//     char y1y2 = 210;
//     char Ys = 74;
//     char Y1 = 230;
//     char Y2 = 28;
//     char I1 = 238;
//     char I2 = 130;
//     double left = (Ys-Y2)/(y1y2);
//     left *= I1;
//     double right = (Y1-Ys)/(y1y2);
//     right *= I2;
//     return left-right;
// }

int main(){
    //getIa();

    char r1, g1, b1, r2, g2, b2, r3, g3, b3;

    unsigned int r, g, b;
    printf("Please input RGB values for the first vertice in the proper format, e.g. '238 130 238' to input violet: ");
    scanf("%d %d %d", &r,&g,&b);
    if(isColor(r) && isColor(g) && isColor(b)){
        r1 = r+0, g1 = g+0, b1 = b+0;
    }
    else {
        printf("Improper color values (should be 0-255 for each).\n");
        return -2;
    }

    printf("Please input RGB values for the second vertice: ");
    scanf("%d %d %d", &r,&g,&b);
    if(isColor(r) && isColor(g) && isColor(b)){
        r2 = r+0, g2 = g+0, b2 = b+0;
    }
    else {
        printf("Improper color values (should be 0-255 for each).\n");
        return -2;
    }

    printf("Please input RGB values for the third vertice: ");
    scanf("%d %d %d", &r,&g,&b);
    if(isColor(r) && isColor(g) && isColor(b)){
        r3 = r+0, g3 = g+0, b3 = b+0;
    }
    else {
        printf("Improper color values (should be 0-255 for each).\n");
        return -2;
    }

    char* buff;
	FILE *imgFile;
    //enum len
    unsigned int len = 230454;
    //na stosie
    //albo w statycznym segmencie
    buff = (char *)malloc(sizeof(unsigned char) * len);
    
    setBmpHeader(buff);
    shade(r1, g1, b1, r2, g2, b2, r3, g3, b3, buff+54);

    printf("Opening file...");
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
