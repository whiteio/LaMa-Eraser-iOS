# LaMa-Eraser-iOS
An image inpainting app made with SwiftUI.


| Before | After | Full Example
|------|-------|-----------|
| <img src="https://github.com/whiteio/LaMa-Eraser-iOS/assets/84482442/10e61c3f-4900-4619-b97a-8847e62ccd23" height=500> | <img src="https://github.com/whiteio/LaMa-Eraser-iOS/assets/84482442/c7e259a2-2438-48b2-8df8-a6e3439596c3" height=500> | ![Simulator Screen Recording - iPhone 14 Pro - 2023-06-13 at 22 43 48](https://github.com/whiteio/LaMa-Eraser-iOS/assets/84482442/f40f4b01-25ab-4429-a803-8750f05af2dc) |



*Video example [here](https://github.com/whiteio/LaMa-Eraser-iOS/blob/main/examples/lama-example.mov)*

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
- iOS 17
- Xcode 15

Port 5000 is used for the flask server.

## Steps
1. Select an image from the photo library
2. Draw masks on the image to perform inpainting
3. Once the image processing has finished, the new image is displayed
4. Rinse and repeat steps 2 and 3 to improve the result if needed
