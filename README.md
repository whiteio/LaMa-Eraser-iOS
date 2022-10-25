# LaMa-Eraser-iOS
An image inpainting app made with SwiftUI

## Prerequisites 

LaMa-cleaner backend server needs to be running locally for this to work To set this up:
1. Clone https://github.com/Sanster/lama-cleaner.git
2. Follow the install steps [here](https://github.com/Sanster/lama-cleaner#:~:text=Build%3A%20yarn%20build-,Docker,-You%20can%20use)

## Environment
- iOS 16
- Docker server running on localhost
- Xcode 14.1

## Steps
1. Select an image from the photo library
2. Draw masks on the image to perform inpainting
3. Once the image processing has finished, the new image is displayed
4. Rinse and repeat steps 2 and 3 to improve the result if needed
