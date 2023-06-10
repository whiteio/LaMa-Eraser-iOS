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
