
## Cropping 

I had some dashcam footage where i wanted to remove the bottom 100 pixels of the video, to remove the Lat/Lang coords.

```text
"dashcamfootage.MOV" -filter:v "crop=iw:ih-100:0:0" "dashcamfootage-cropped.mp4"
```

This keeps the input width the same, but removed 100 pixels from the input height. The 0:0 is the position to orient the crop from, which for my purpose should be the first pixel.
