# LaMa-Eraser-iOS
An image inpainting app made with SwiftUI.


| Home screen | Before | After (1 round) |
|--------|------|-------|
| ![image](https://github.com/whiteio/LaMa-Eraser-iOS/assets/84482442/a58fa94c-b04c-450b-9946-a077881d2443) | ![image](https://github.com/whiteio/LaMa-Eraser-iOS/assets/84482442/8e903295-21ef-4ac7-a3cb-12a523cee741) | ![image](https://github.com/whiteio/LaMa-Eraser-iOS/assets/84482442/ef2e68cf-9eaa-41bf-b7ce-d18c68a254d9) |



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
- iOS 16
- Xcode 14.1

Port 5000 is used for the flask server.

## Steps
1. Select an image from the photo library
2. Draw masks on the image to perform inpainting
3. Once the image processing has finished, the new image is displayed
4. Rinse and repeat steps 2 and 3 to improve the result if needed
