# LaMa-Eraser-iOS
An image inpainting app made with SwiftUI.

## Prerequisites 

LaMa-cleaner backend server needs to be running locally for this to work To set this up:
1. Clone https://github.com/whiteio/lama-zits
2. `cd` into `lama-zits` and install required dependencies:
```
pip install -r requirements.txt
```
3. Run the flask server
```
python predict.py
```
## Environment
- iOS 16
- Xcode 14.1

Port 5000 is used for the flask server.

## Steps
1. Select an image from the photo library
2. Draw masks on the image to perform inpainting
3. Once the image processing has finished, the new image is displayed
4. Rinse and repeat steps 2 and 3 to improve the result if needed

Here's an example after running inpainting one time, to improve the image you can repeat the steps

| Before | Mask | After |
|--------|---------------------------------|-------|
|![image](https://github.com/whiteio/LaMa-Eraser-iOS/assets/84482442/05e0c111-645a-4b19-81e5-43da3f5bd6d4)|![gray_mask](https://github.com/whiteio/LaMa-Eraser-iOS/assets/84482442/c5c401a4-d1c7-4a38-bfe8-fad9c205568b)|![FxpjuZnLr](https://github.com/whiteio/LaMa-Eraser-iOS/assets/84482442/6ffc8ad9-633f-4798-a650-600ceaea9918)|  
