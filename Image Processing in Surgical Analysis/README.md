# Python Image Processing in Surgical Analysis -- Bleed Detection

Written by: Jonathan Stump

## Abstract

This project uses frame-by-frame video analysis to pinpoit burning as a result of surgical
cuts. The approach begins by extracting frames from the video at a variable rate, offering
a trade-off between precision and efficiency. These extracted frames are then analyzed for the
the presence of a cutting action -- determined by the surgeon turning on a burn setting for the tool.
After gathering frames where this burning occurs, further analysis takes place to flag bleeding
around the cut area. By using a multi-step process, the approach aims to decrease false positives and
missed bleeding frames.

The end goal of the project is to identify surgical cuts that cause bleeding on the bodily vessels, yet the project's approach does not explicitly check for bleeding at any point in the process. Rather, the approach uses a comparison to a previous frame to detect areas that contain physical signs of burning on the vessels. The visible burn marks are an indicator that the cut was significant enough to cause bleeding and the subsequent cauterization detected.

## Method

This project's approach uses Python and the cv2 library to complete video and image processing,
separating each step into a different function. When the program is run, the functions are run in sequential
order appropriately. These steps are divided into two timed phases -- extraction of the images from the video at the specified rate and bluelight filtering, followed by the second phase where burn detection lays out the final output.

### History

The approach outlined above was derived from several different approaches, each with their own drawbacks and failures. At the beginning of the project, bleed detection was the primary filtering process. Defining masks from an upper and lower red color range and combining them with a bitwise or operation, this function attempted to determine the ratio of pixels in a given image that were red. By comparing the current image's red ratio to a previous image's, the function defined bleeding as any frame whose red ratio was higher than the previous ratio by an arbitrary amount. Despite experimenting with this arbitrary amount and how far back the previous frame should be, too much was variable in the background environment to achieve successful results. Camera shifts and red vessels uncovered by moving away yellow fat were the most common culprits contributing to an abundance of false positives and very few successful bleed detections.

After this approach, the project shifted focus to detecting the blade making the surgical cuts. It was clear from the previous attempt that examining the entire image was too broad of a lense, but the question arose of how to define a narrower window. By determining the sharp tip of the tool, a new process hoped to define a window around the blade for comparison. The blade detection function used contours and geometric analysis to match a preconceived notion of the blade's shape with the tool in the image. Occasionally, the body of the tool was detected successfully, but more often the function incorrectly indentified small tubes and vessels to be the tip of the blade. Two main issues prevented the project from honing this method further. First, the tip of the tool often disappeared under fat and other vessels, leaving the function searching for something that wasn't visible. Second, there was often a second tool present in the frame, either clamped down on a vessel or used to help navigate between layrs of fat. These problems made it clear that the project was better focused elsewhere.

<div style="display: flex; justify-content: space-around; text-align: center;">

  <div>
    <img src="tool_detection_output/frame_0122.jpg" alt="Image Redacted for Privacy Concerns" style="max-width: 85%; height: auto;"/>
    <p>Successful tool detetction</p>
  </div>

  <div>
    <img src="tool_detection_output/frame_0000.jpg" alt="Image Redacted for Privacy Concerns" style="max-width: 85%; height: auto;"/>
    <p>Unsuccessful tool detection</p>
  </div>

</div>

From here, the next approach made two major changes -- implementing a sliding window to only check certain regions of interest at a time, and shifting from bleed detection to burn detection. Since many vessels and tubes in the images were surrounded by red, detecting a grayscale value change -- as the burning caused a region to get darker -- might be the better approach. Still, even after throwing away image-wide brightness changes, comparing the difference between the grayscale values in the current and previous frames, and checking the absolute value and standard deviation of the grayscale values in the window, many areas of the image away from the operation at hand qualified as burning. Despite altering the window size, threshold values, and how far back the previous frame should be, it was clear this process alone could never be fully satisfactory.

To continue down this route but still eliminate false positives, the approach needed another step in the pre-filtering process. This step was bluelight detection. In each surgery video, a rectangular region flashes blue for the duration of the tool burning. This might be for a frame or two -- perhaps the surgeon wanted heat for a small cut -- or for an extended duration as a significant cut is made. Regardless, all bluelight frames are filtered from the extracted frames, and sent as input for the sliding window function. Checking only the bluelight frames, this current approach hopes to eliminate false positives and retain true burning cases by comparing the sliding window against transition frames occuring directly before the bluelight burning began.

### Extracting

The first step of the current approach is extracting image frames from the video input.
To accomplish this, a function was created that takes in a video, rate, and output folder.

```
def extract_frame(vid, fRate, folder):
```

To iterate over the correct frames, the total number of frames is first determined before
defining a step variable based on the variable rate and the given frame rate of the video.
This step is the new effective frames per second for extracting.

```
    fCount = int(vid.get(cv2.CAP_PROP_FRAME_COUNT))
    fps = vid.get(cv2.CAP_PROP_FPS)
    step = int(fps // fRate) if fRate > 0 else 1
```

Next, the function makes the output folder if it doesn't already exist, and from there iteration over the frames of the video can begin.

```
    os.makedirs(folder, exist_ok=True)

    for i, frame_idx in enumerate(range(0, fCount, step)):
        vid.set(cv2.CAP_PROP_POS_FRAMES, frame_idx)
        ret, frame = vid.read()
        if ret:
            filename = os.path.join(folder, f"frame_{i:04d}.jpg")
            cv2.imwrite(filename, frame)
        else:
            print(f"Error: could not read frame {frame_idx}")
    return fps
```

In each iteration, the function sets the video to the correct frame and creates a jpg image of the current frame. The original frames per second of the video is returned to be used later in the output summary.

### Bluelight Filtering

This function aims to save all input images with an active blue light from extraction to a separate output folder.

<div style="display: flex; justify-content: space-around; text-align: center;">

  <div>
    <img src="extraction/filtered_frames_test/VID001A-bluelight/blade_burn_detection/0004_frame_burn.jpg/" alt="Image Redacted for Privacy Concerns" style="max-width: 85%; height: auto;"/>
    <p>This image demonstrates a frame with an active bluelight. The function examines a region inside the bluelight box without including the text.</p>
  </div>

</div>

```
def detect_bluelight(input_folder, output_folder):
    BUFFER = 3
    L_MEAN_BRIGHTNESS = 65
    U_MEAN_BRIGHTNESS = 75
    L_MEAN_HUE = 102
    U_MEAN_HUE = 107
    L_MEAN_SAT = 247
    U_MEAN_SAT = 252
    trigger_frames = 0
    trigger_indices = set()
    tagged = set()

    os.makedirs(output_folder, exist_ok=True)

    files = sorted(
        [f for f in os.listdir(input_folder) if f.endswith('.jpg')],
        key=lambda x: int(x.split('_')[1].split('.')[0])
    )
```

The beginning of the function defines boundary data points that a bluelight region of interest should fall between. Below those, variables are defined to store important data on which frames should be output. The output folder is created, and the input folder's files are put into a sorted list.

```
    for idx in range(0, len(files)):
        print(f"Processing frame {idx}/{len(files)}")

        filename = files[idx]
        curr_path = os.path.join(input_folder, filename)
        curr_frame = cv2.imread(curr_path)

        if curr_frame is None:
            print(f"Error: could not read {filename}")
            continue

        # region of interest where blue light appears
        x1, y1, x2, y2 = 1193, 1017, 1290, 1055
        roi = curr_frame[y1:y2, x1:x2]
```

Iteration begins to find bluelight frames. The current frame is established and the region of interest where the bluelight may appear is defined.

```
        hsv_roi = cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)

        # Get the mean HSV values of the ROI
        mean_hue = np.mean(hsv_roi[:, :, 0])
        mean_sat = np.mean(hsv_roi[:, :, 1])

        # Convert ROI to grayscale
        gray_roi = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)

        # Calculate mean brightness
        mean_brightness = np.mean(gray_roi)
```

Calculations are done to check the main criteria for being a bluelight frame -- the mean hue, mean saturation, and mean brightness all fall between the ranges defined at the beginning of the function.

```
        if L_MEAN_BRIGHTNESS < mean_brightness < U_MEAN_BRIGHTNESS:
            if (L_MEAN_HUE < mean_hue < U_MEAN_HUE) and (L_MEAN_SAT < mean_sat < U_MEAN_SAT):
                if idx not in trigger_indices:
                    print(f"Bluelight detected at frame {idx}")
                    trigger_indices.add(idx)
                    trigger_frames += 1
                for offset in range(-BUFFER, BUFFER + 1):
                    i = idx + offset
                    if 0 <= i < len(files):
                        tagged.add(i)
```

If the current frame meets the criteria, its index is added to a set of bluelight indeces and the frames around it are marked to be included as transition frames. Those frames are then saved appropriately to the output folder and data on the number of frames is returned.

```
    # save frames
    for index in sorted(tagged):
        path = os.path.join(input_folder, files[index])
        frame = cv2.imread(path)

        label = 'blue' if index in trigger_indices else 'transition'
        if frame is not None:
            filename = os.path.join(output_folder, f"{index:04d}_frame_{label}.jpg")
            print(f"Saving {filename}")
            cv2.imwrite(filename, frame)
        else:
            print("frame is None")

    return trigger_frames, len(tagged)
```

### Burn Detection

Once the bluelight frames are compiled, this function iterates through them, checking a sliding window against previous transition frames to detect for the physical presence of burning on the cut vessel. This filtering approach mirrors the bluelight function in many ways, starting with defining acceptance criteria and setting up input files.

```
def filter_by_burning(input_folder, output_folder, buf):
    BUFFER = buf if buf > 3 else 3
    WINDOW_SIZE = 150
    GLOBAL_THRESH = 10
    WINDOW_THRESH_LOW = 7
    WINDOW_THRESH_HIGH = 12
    L_MEAN_BOUND = 35
    U_MEAN_BOUND = 55
    L_STTDEV_BOUND = 28
    U_STTDEV_BOUND = 40
    STEP = 20
    trigger_frames = 0
    trigger_indices = set()
    tagged = set()
    modified_frames = {}

    os.makedirs(output_folder, exist_ok=True)

    files = sorted(
        [f for f in os.listdir(input_folder) if f.endswith('.jpg')],
        key=lambda x: int(x.split('_')[0])  # ensures numerical order
    )
```

From here, the function iterates over the input files.

```
    for idx in range(buf, len(files)):
        if idx % 50 == 0:
            print(f"Processing frame {idx}/{len(files)}")

        filename = files[idx]
        # parse the true frame number from filename
        frame_number = int(filename.split('_')[0])
        label = os.path.splitext(filename)[0].split('_')[-1]

        if label != "blue":
            continue

        prev_file = files[idx - buf]
        prev_number = int(prev_file.split('_')[0])

        curr_path = os.path.join(input_folder, filename)
        prev_path = os.path.join(input_folder, prev_file)
        curr_frame = cv2.imread(curr_path)
        prev_frame = cv2.imread(prev_path)

        if curr_frame is None or prev_frame is None:
            print(f"Error: could not read {filename}")
            continue
```

The function establishes a current and previous frame only after ensuring that the current frame was marked as a bluelight frame.

```
        gray_prev = cv2.cvtColor(prev_frame, cv2.COLOR_BGR2GRAY)
        gray_curr = cv2.cvtColor(curr_frame, cv2.COLOR_BGR2GRAY)
        diff = gray_curr.astype(np.int16) - gray_prev.astype(np.int16)

        if abs(diff.mean()) > GLOBAL_THRESH:
            print(f"Frame {frame_number}: global thresh throwaway")
            continue
```

The first calculation to determine visible burning is the difference between the grayscale values of the two frames, simulating a brightness difference. Before searching with the sliding window, the function checks for any lighting changes on the whole frame. If the current image is significantly darker or lighter than the previous image, the function skips the current image to avoid false positives.

```
        found = False
        for y in range(500, diff.shape[0] - 500, STEP):
            for x in range(500, diff.shape[1] - 500, STEP):
                # brightness change detection, should get darker
                window_diff = diff[y:y+WINDOW_SIZE, x:x+WINDOW_SIZE]
                mean_change = window_diff.mean()
                if -WINDOW_THRESH_HIGH < mean_change < -WINDOW_THRESH_LOW:
```

Next, the sliding window begins its search, avoiding the edges of the frame where cutting isn't likely to take place. The change in brightness is calculated for the sliding window, continuing our other checks if the current frame is darker than the previous frame by an arbitrary amount.

```
                    curr_gray = gray_curr.astype(np.int16)
                    window = curr_gray[y:y+WINDOW_SIZE, x:x+WINDOW_SIZE]
                    mean = window.mean()
                    if L_MEAN_BOUND < mean < U_MEAN_BOUND:
                        sttdev = window.std()
                        if L_STTDEV_BOUND < sttdev < U_STTDEV_BOUND:
```

The next two checks include the absolute value of the region of interest -- ensuring the area isn't too dark or light -- and the standard deviation of the region -- the bleeding and burning will be different from the yellow vessels in the surrounding area. If the criteria is satisfied in the region, a rectangle is drawn highlighting the burn region and the frame is saved in similar fashion to the bluelight function.

```
                            found = True
                            cv2.rectangle(curr_frame, (x, y), (x+WINDOW_SIZE, y+WINDOW_SIZE), (0, 255, 255), 1)
                            cv2.rectangle(prev_frame, (x, y), (x+WINDOW_SIZE, y+WINDOW_SIZE), (0, 255, 255), 1)
                            modified_frames[frame_number] = curr_frame.copy()
                            if prev_number not in trigger_indices:
                                modified_frames[prev_number] = prev_frame.copy()
                            if frame_number not in trigger_indices:
                                print(f"Burning detected at frame {frame_number}")
                                trigger_indices.add(frame_number)
                                trigger_frames += 1
                            for offset in range(-BUFFER, BUFFER + 1):
                                i = frame_number + offset
                                tagged.add(i)
                            break
            if found:
                break

    for index in sorted(tagged):
        frame = None
        if index in modified_frames:
            frame = modified_frames[index]
        else:
            # find file with this frame index
            candidates = [f for f in files if int(f.split('_')[0]) == index]
            if candidates:
                path = os.path.join(input_folder, candidates[0])
                frame = cv2.imread(path)

        label = 'burn' if index in trigger_indices else 'transition'
        if frame is not None:
            filename = os.path.join(output_folder, f"{index:04d}_frame_{label}.jpg")
            print(f"Saving {filename}")
            cv2.imwrite(filename, frame)
        else:
            print(f"frame {index} is None")

    return trigger_frames, len(tagged)
```

If the criteria is satisfied, 'found' is set to true and the sliding window stops traversing the frame. When the images are saved to the output folder, the correct frame index is taken from the input folder.

## Results

To test this approach, the program was run with rates 1, 3, and 7. Quantitative data was gathered on the total frames extracted, number of trigger frames, i.e. bluelight or burning, and a proximity ratio. This ratio attempts to measure how often the burn detection triggers from an acceptable region of interest -- usually the tip of the tool or the cut vessel -- and is defined by the precent value of the number of burn frames triggered from an acceptable region to the total number of burn frames. The results of the quantitative data can be seen in the tables below.

| Rate = 1                    | VID001A | VID001B | VID001C | VID001D |
| --------------------------- | ------- | ------- | ------- | ------- |
| Total Frames                | 341     | 342     | 342     | 341     |
| Bluelight Burn              | 71      | 117     | 170     | 61      |
| Sliding Window              | 2       | 2       | 12      | 5       |
| Proximity Ratio             | 0.00%   | 0.00%   | 0.00%   | 60.00%  |
| Bluelight + Extraction Time | 1m 55s  | 2m 41s  | 1m 43s  | 1m 38s  |
| Burn Detection Time         | 0m 12s  | 0m 21s  | 0m 17s  | 0m 9s   |

| Rate = 3                    | VID001A | VID001B | VID001C | VID001D |
| --------------------------- | ------- | ------- | ------- | ------- |
| Total Frames                | 1101    | 1103    | 1103    | 1101    |
| Bluelight Burn              | 233     | 378     | 545     | 197     |
| Sliding Window              | 14      | 5       | 53      | 31      |
| Proximity Ratio             | 0.00%   | 20.00%  | 15.09%  | 38.71%  |
| Bluelight + Extraction Time | 2m 13s  | 2m 9s   | 2m 36s  | 2m 8s   |
| Burn Detection Time         | 0m 16s  | 0m 31s  | 0m 39s  | 0m 1s   |

| Rate = 7                    | VID001A | VID001B | VID001C | VID001D |
| --------------------------- | ------- | ------- | ------- | ------- |
| Total Frames                | 2478    | 2482    | 2482    | 2478    |
| Bluelight Burn              | 523     | 851     | 1224    | 444     |
| Sliding Window              | 32      | 13      | 107     | 56      |
| Proximity Ratio             | 0.00%   | 7.69%   | 17.76%  | 42.86%  |
| Bluelight + Extraction Time | 4m 21s  | 4m 57s  | 4m 59s  | 4m 39s  |
| Burn Detection Time         | 0m 37s  | 1m 0s   | 1m 25s  | 0m 33s  |

> Note: Each video describes the same surgery in sequential order, with VID0001A being the beginning of the surgery.

There's a general trend of a higher proximity ratio the higher the rate and the further along the video is in the surgery. Outliers include the 60 and 20 percent ratios in VID001D and VID001B respectively in the smaller rate trials, but I believe a small sample size inflated these numbers, as there were only 5 burn frames detected in each case. A greater proximity ratio the higher the rate suggests a more accurate comparison with more total frames, though the extraction time increased significantly.

A higher proximity ratio correlated with the later videos is explained by watching the videos themselves. In the beginning of the surgery, it was much more likely that the surgeon made miniscule cuts that would not draw blood, while further along blood was much more likely to be drawn in the latter two videos when more significant cuts were made. This trend indicates positive behavior from the sliding window approach. When visible burning existed, the function was relatively more likely to detect that region of interest over a false positive elsewhere than cases where no physical burning was present on the vessels. In other words, if physical burning was not present, the approach succeeded in ignoring the operation region of interest. This suggests further acceptance criteria is necessary to prevent regions away from the operation from being flagged.

Though false positives away from the area of interest remain very much an issue, qualitative analysis revealed that false negatives and false positives in close proximity to the cut were rare. The filter by burning function rarely did not flag frames with visible burning -- except in the case that a region checked by the sliding window met the acceptance criteria before the window approached the operation area of interest. If the operation area of interest was flagged, the cut was almost always significant enough to cause bleeding, suggesting that the acceptance criteria was accurate but not exclusive enough.

<div style="display: flex; justify-content: space-around; text-align: center;">

  <div>
    <img src="extraction/filtered_frames/VID001D/bleed_detection_3/0510_frame_burn.jpg" alt="Image Redacted for Privacy Concerns" style="max-width: 100%; height: auto;"/>
    <p>The region of interest contains the cutting area, clear signs of bleeding behind the yellow fat, and burnt blood on the tool itself -- a successful burn detection.</p>
  </div>

  <div>
    <img src="extraction/filtered_frames/VID001C/bleed_detection_3/0138_frame_burn.jpg" alt="Image Redacted for Privacy Concerns" style="max-width: 100%; height: auto;"/>
    <p>The burn detection is not in close proximity to the operation -- a false positive. Positively, however, there is no sign of visible burning or bleeding in the cut area, and the function was right not to flag that region.</p>
  </div>

</div>

<div style="display: flex; justify-content: space-around; text-align: center;">

  <div>
    <img src="extraction/filtered_frames/VID001C/bleed_detection_7/1809_frame_burn.jpg" alt="Image Redacted for Privacy Concerns" style="max-width: 100%; height: auto;"/>
    <p>Another example of successful burn detection. Though it isn't clear if the current cut caused the blackish-red burn under the tool, this is definitely a case worth highlighting.</p>
  </div>

  <div>
    <img src="extraction/filtered_frames/VID001C/bleed_detection_7/1459_frame_burn.jpg" alt="Image Redacted for Privacy Concerns" style="max-width: 100%; height: auto;"/>
    <p>Another false positive in an irrelevant region. It's easy to see why the algorithm might've detected it.</p>
  </div>

</div>

## Conclusion

This project explored a multi-step approach to detect surgical cuts likely to cause bleeding by focusing on visible burning in video frames. The approach does not detect bleeding directly but uses visible burning as a bleeding indicator. The process — extracting frames at a variable rate, filtering for bluelight frames, and applying a sliding window burn detection — allowed the analysis to concentrate on regions of interest rather than the entire image. The results show that higher extraction rates generally improve the proximity ratio, meaning the detected burn regions align better with actual surgical activity. Later stages of surgery, when cuts were more significant, also saw higher detection accuracy, confirming that the method works best when clear visual cues are present.

Though more work must be done to improve the consistency of the approach, the combination of bluelight filtering and sliding window analysis provides a reasonable balance between filtering out irrelevant frames and capturing true burn events. The method successfully reduces false positives compared to earlier approaches while maintaining sensitivity to significant cuts. Moving forward, additional steps should be taken to make the acceptance criteria more exclusive to regions at a distance from the operation. This should be done without diminishing the burn frames in close proximity to the operation -- eliminating false positives without losing correct burn flags. Experimenting with dependent variables such as brightness thresholds, window size, or incorporating additional visual cues could further reduce false positives. This project establishes a strong foundation for automated surgical video analysis and sets the stage for more precise, context-aware detection methods.
