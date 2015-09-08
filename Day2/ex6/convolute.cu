// ###
// ###
// ### Practical Course: GPU Programming in Computer Vision
// ###
// ###
// ### Technical University Munich, Computer Vision Group
// ### Summer Semester 2015, September 7 - October 6
// ###
// ###
// ### Thomas Moellenhoff, Robert Maier, Caner Hazirbas
// ###
// ###
// ###
// ### THIS FILE IS SUPPOSED TO REMAIN UNCHANGED
// ###
// ###


#include "aux.h"
#include <iostream>
#include <stdio.h>
using namespace std;

#define PI 3.14159265359

// uncomment to use the camera
// #define CAMERA

__global__ void convolute(float* out, float* in , float* kernel, int radius, int width, int height, int channel) {
    int x = threadIdx.x + blockDim.x * blockIdx.x;
    int y = threadIdx.y + blockDim.y * blockIdx.y;
    int c = threadIdx.z + blockDim.z * blockIdx.z;
    int bw = blockDim.x;
    int bh = blockDim.y;
    int bd = blockDim.z;
    int ix = threadIdx.x;
    int iy = threadIdx.y;
    int ic = threadIdx.z;
    int diam = 2 * radius + 1;
}

void gaussian_kernel(float* kernel, float sigma, int radius, int diameter) {
    int i, j;
    float sum = 0.f;
    float denom = 2.0 * sigma * sigma;
    float e = 0.f;
    for (i = -radius; i <= radius; i++) {
        for (j = -radius; j <= radius; j++) {
            e = pow(j, 2) + pow(i, 2);
            kernel[(j + radius) + (i + radius) * diameter] = exp(-e / denom) / (denom * PI);
            sum += kernel[(j + radius) + (i + radius) * diameter];
        }
    }
    for (i = 0; i < diameter*diameter; i++) {
        kernel[i] /= sum;
    }
}

float aMin(float* array, int size) {
    float min = array[0];
    for (int i = 1; i < size; i++)
        min = array[i] < min ? array[i] : min;
    return min;
}

float aMax(float* array, int size) {
    float max = array[0];
    for (int i = 1; i < size; i++)
        max = array[i] > max ? array[i] : max;
    return max;
}

void convolution(float* out, float* in, float* kernel, int radius, int width, int height, int channel) {
    float con_sum = 0.f;
    int diameter = 2 * radius + 1;
    int x = 0;
    int y = 0;
    for (int m = 0; m < channel; m++) {
        for (int i = 0; i < height; i++) {
            for (int j = 0; j < width; j++) {
                con_sum = 0.f;
                for (int k = -radius; k <= radius; k++) {
                    for (int l = -radius; l <= radius; l++) {
                        x = fmax(fmin((float)(width-1), (float)(j+l)), 0.f);
                        y = fmax(fmin((float)(height-1), (float)(i+k)), 0.f);
                        con_sum += in[x + y * width + m * width * height] * kernel[(l+radius) + (k+radius) * diameter];
                    }
                }
                out[j + i * width + m * width * height] = con_sum;
            }
        }
    }
}

int main(int argc, char **argv)
{
    // Before the GPU can process your kernels, a so called "CUDA context" must be initialized
    // This happens on the very first call to a CUDA function, and takes some time (around half a second)
    // We will do it right here, so that the run time measurements are accurate
    cudaDeviceSynchronize();  CUDA_CHECK;

    // Reading command line parameters:
    // getParam("param", var, argc, argv) looks whether "-param xyz" is specified, and if so stores the value "xyz" in "var"
    // If "-param" is not specified, the value of "var" remains unchanged
    //
    // return value: getParam("param", ...) returns true if "-param" is specified, and false otherwise

#ifdef CAMERA
#else
    // input image
    string image = "";
    bool ret = getParam("i", image, argc, argv);
    if (!ret) cerr << "ERROR: no image specified" << endl;
    if (argc <= 1) { cout << "Usage: " << argv[0] << " -i <image> [-repeats <repeats>] [-gray]" << endl; return 1; }
#endif
    
    // number of computation repetitions to get a better run time measurement
    int repeats = 1;
    getParam("repeats", repeats, argc, argv);
    cout << "repeats: " << repeats << endl;
    
    // load the input image as grayscale if "-gray" is specifed
    bool gray = false;
    getParam("gray", gray, argc, argv);
    cout << "gray: " << gray << endl;

    // load the input image as grayscale if "-gray" is specifed
    float sigma = 1.f;
    getParam("sigma", sigma, argc, argv);
    cout << "sigma: " << sigma << endl;
    int radius = ceil(3 * sigma);
    int diameter = 2 * radius + 1;

    // Init camera / Load input image
#ifdef CAMERA

    // Init camera
    cv::VideoCapture camera(0);
    if(!camera.isOpened()) { cerr << "ERROR: Could not open camera" << endl; return 1; }
    int camW = 640;
    int camH = 480;
    camera.set(CV_CAP_PROP_FRAME_WIDTH,camW);
    camera.set(CV_CAP_PROP_FRAME_HEIGHT,camH);
    // read in first frame to get the dimensions
    cv::Mat mIn;
    camera >> mIn;
    
#else
    
    // Load the input image using opencv (load as grayscale if "gray==true", otherwise as is (may be color or grayscale))
    cv::Mat mIn = cv::imread(image.c_str(), (gray? CV_LOAD_IMAGE_GRAYSCALE : -1));
    // check
    if (mIn.data == NULL) { cerr << "ERROR: Could not load image " << image << endl; return 1; }
    
#endif

    // convert to float representation (opencv loads image values as single bytes by default)
    mIn.convertTo(mIn,CV_32F);
    // convert range of each channel to [0,1] (opencv default is [0,255])
    mIn /= 255.f;
    // get image dimensions
    int w = mIn.cols;         // width
    int h = mIn.rows;         // height
    int nc = mIn.channels();  // number of channels
    int size = w * h * nc;
    int nbyte = size * sizeof(float);
    cout << "image: " << w << " x " << h << endl;

    // Set the output image format
    // ###
    // ###
    // ### TODO: Change the output image format as needed
    // ###
    // ###
    cv::Mat mOut(h,w,mIn.type());  // mOut will have the same number of channels as the input image, nc layers
    cv::Mat gaussOut(diameter,diameter,CV_8UC1);  // mOut will have the same number of channels as the input image, nc layers
    //cv::Mat mOut(h,w,CV_32FC3);    // mOut will be a color image, 3 layers
    //cv::Mat mOut(h,w,CV_32FC1);    // mOut will be a grayscale image, 1 layer
    // ### Define your own output images here as needed

    // Allocate arrays
    // input/output image width: w
    // input/output image height: h
    // input image number of channels: nc
    // output image number of channels: mOut.channels(), as defined above (nc, 3, or 1)

    // allocate raw input image array
    // allocate raw output array (the computation result will be stored in this array, then later converted to mOut for displaying)
    float *h_imgIn  = new float[(size_t)size];
    float *h_kernel = new float[diameter*diameter];
    float *h_imgOut = new float[(size_t)w*h*mOut.channels()];

    // allocate raw input image for GPU
    float* d_imgIn;
    float* d_imgOut;
    float* d_kernel;

    // For camera mode: Make a loop to read in camera frames
#ifdef CAMERA
    // Read a camera image frame every 30 milliseconds:
    // cv::waitKey(30) waits 30 milliseconds for a keyboard input,
    // returns a value <0 if no key is pressed during this time, returns immediately with a value >=0 if a key is pressed
    while (cv::waitKey(30) < 0)
    {
    // Get camera image
    camera >> mIn;
    // convert to float representation (opencv loads image values as single bytes by default)
    mIn.convertTo(mIn,CV_32F);
    // convert range of each channel to [0,1] (opencv default is [0,255])
    mIn /= 255.f;
#endif

    // Init raw input image array
    // opencv images are interleaved: rgb rgb rgb...  (actually bgr bgr bgr...)
    // But for CUDA it's better to work with layered images: rrr... ggg... bbb...
    // So we will convert as necessary, using interleaved "cv::Mat" for loading/saving/displaying, and layered "float*" for CUDA computations
    convert_mat_to_layered (h_imgIn, mIn);

    // alloc GPU memory
    cudaMalloc(&d_imgIn, nbyte);
    CUDA_CHECK;
    cudaMalloc(&d_imgOut, nbyte);
    CUDA_CHECK;
    cudaMalloc(&d_kernel, diameter*diameter*sizeof(float));
    CUDA_CHECK;

    gaussian_kernel(h_kernel, sigma, radius, diameter);
    // copy host memory
    cudaMemcpy(d_imgIn, h_imgIn, nbyte, cudaMemcpyHostToDevice);
    CUDA_CHECK;
    cudaMemcpy(d_kernel, h_kernel, diameter*diameter*sizeof(float), cudaMemcpyHostToDevice);
    CUDA_CHECK;

    // launch kernel
    dim3 block = dim3(32, 8, nc);
    dim3 grid = dim3((w + block.x - 1) / block.x, (h + block.y - 1) / block.y, (nc + block.z - 1) / block.z);
    // dim3 block = dim3(32, 8, 1);
    // dim3 grid = dim3((w + block.x - 1) / block.x, (h + block.y - 1) / block.y, 1);

    // float min = aMin(h_kernel, diameter);
    // float max = aMax(h_kernel, diameter);

    Timer timer; timer.start();
    for (int i = 0; i < repeats; i++) {
        convolute <<<grid, block>>> (d_imgOut, d_imgIn, d_kernel, radius, w, h, nc);
        // convolution(h_imgOut, h_imgIn, h_kernel, radius, w, h, nc);
        // for (int k = 0; k < diameter; k++) {
        //     for (int j = 0; j < diameter; j++) {
        //         gaussOut.at<uchar>(k, j) = (h_kernel[j + k * diameter]-min) / (max - min) * 255;
        //     }
        //     cout << endl;
        // }
    }

    timer.end();  float t = timer.get();  // elapsed time in seconds
    cout << "time: " << t*1000 << " ms" << endl;

    cudaMemcpy(h_imgOut, d_imgOut, nbyte, cudaMemcpyDeviceToHost);
    CUDA_CHECK;

    // free GPU memory
    cudaFree(d_imgIn);
    CUDA_CHECK;
    cudaFree(d_imgOut);
    CUDA_CHECK;
    cudaFree(d_kernel);
    CUDA_CHECK;


    // show input image
    showImage("Input", mIn, 100, 100);  // show at position (x_from_left=100,y_from_above=100)

    // show output image: first convert to interleaved opencv format from the layered raw array
    convert_layered_to_mat(mOut, h_imgOut);
    // convert_layered_to_mat(gaussOut, h_kernel);
    showImage("Output", mOut, 100+w+40, 100);
    // showImage("Output", gaussOut, 100, 100);

    // ### Display your own output images here as needed

#ifdef CAMERA
    // end of camera loop
    }
#else
    // wait for key inputs
    cv::waitKey(0);
#endif

    // save input and result
    cv::imwrite("image_input.png",mIn*255.f);  // "imwrite" assumes channel range [0,255]
    cv::imwrite("image_result.png",mOut*255.f);

    // free allocated arrays
    delete[] h_imgIn;
    delete[] h_imgOut;
    delete[] h_kernel;

    // close all opencv windows
    cvDestroyAllWindows();
    return 0;
}