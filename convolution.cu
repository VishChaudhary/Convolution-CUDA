#include "stdio.h"
#include "math.h"

#define FILTER_RADIUS 2
#define TILE_DIM 32

//F: Convolution filter array pointer (2D- not linearized)
__constant__ float F[2*FILTER_RADIUS+1][2*FILTER_RADIUS+1];

__global__ void 2D_convolution_kernel(float *N, float *P,int width, int height){
  //N: Input array pointer (linearlized)
  //P: Output array pointer (linearized)
  //width: width of the input/output array
  // height: height of the input/output array

  int row = blockIdx.y * TILE_DIM + threadIdx.y;
  int col = blockIdx.x * TILE_DIM + threadIdx.x;

  __shared__ N_s[TILE_DIM][TILE_DIM];
  if(row<height && col <width){
    N_s[threadIdx.y][threadIdx.x] = N[row*width+col];
  }
  else{
    N_s[threadIdx.y][threadIdx.x] = 0.0f;
  }
  __synchthreads();
  if(row<height && col<width){
    float Pval = 0.0f;
    for(int rowOffset = 0; rowOffset< 2*FILTER_RADIUS+1; rowOffset++){
      for(int colOffset = 0; colOffset< 2*FILTER_RADIUS+1; colOffset++){
        if(threadIdx.y-FILTER_RADIUS+rowOffset>=0 && threadIdx.y-FILTER_RADIUS+rowOffset < TILE_DIM && threadIdx.x-FILTER_RADIUS+colOffset >=0 && threadIdx.x-FILTER_RADIUS+colOffset < TILE_DIM){
          Pval+= F[rowOffset][colOffset]*N_s[threadIdx.y-FILTER_RADIUS+rowOffset][threadIdx.x-FILTER_RADIUS+colOffset];
        }
        else{
          currRow = row - FILTER_RADIUS + rowOffset;
          currCol = col - FILTER_RADIUS + colOffset;
          if (currRow >= 0 && currRow<height && currCol>=0 && currCol <width){
            Pval+= N[currRow*width+currCol]*F[rowOffset][colOffset];
          }
        }
      }
    }
    P[row*width+col] = Pval;
  }
} 


int main(){
  float* F_h = (float*)malloc(img_size);
  //Informs CUDA runtime that the data being copied into constand mem will not be changed during execution
  cudaMemcpyToSymbol(F,F_h,(2*FILTER_RADIUS+1)*(2*FILTER_RADIUS+1)*(sizeof(float)); 
  dim3 dimBlock(16,16,1);
  dim3 dimGrid(ceil(n/16.0), ceil(n/16.0),1);
  2D_convolution_kernel<<dimGrid,dimBlock>>
}
