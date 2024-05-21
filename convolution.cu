#include "stdio.h"
#include "math.h"


__global__ void 2D_convolution_kernel(float *N, float *F, float *P, int r, int width, int height){
  //N: Input array pointer (linearlized)
  //F: Convolution filter array pointer (2D- not linearized)
  //P: Output array pointer (linearized)
  //r: Filter radius (2r+1)
  //width: width of the input/output array
  // height: height of the input/output array
  int row = blockIdx.y*blockDim.y + threadIdx.y;
  int col = blockIdx.x * blockDim.x + threadIdx.x;
  float Pval = 0.0f;
  for(int rowOffset = 0; rowOffset< 2r+1; rowOffset++){
    for(int colOffset = 0; colOffset< 2r+1; colOffset++){
      currRow = row - r + rowOffset;
      currCol = col - r + colOffset;
      (if currRow >= 0 && currRow<height && currCol>=0 && currCol <width){
        Pval+= N[currRow*width+currCol]*F[rowOffset][colOffset];
      }
    }
  }
  P[row*width+col] = Pval;
} 


int main(){

  dim3 dimBlock(16,16,1);
  dim3 dimGrid(ceil(n/16.0), ceil(n/16.0),1);
  2D_convolution_kernel<<dimGrid,dimBlock>>
}
