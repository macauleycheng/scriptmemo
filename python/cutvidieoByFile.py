#!pip install moviepy
from moviepy import VideoFileClip, TextClip, CompositeVideoClip
import os, sys

filename = r"\\family_68_2\tmp\bigtorrent\4k2.com@259LUXU-1861.mp4"
#filename=""
if len(filename) == 0:
    if len(sys.argv) > 1:
        print("First argument:", sys.argv[1])
    else: 
        print("need file name")
        sys.exit(0)

    filename = sys.argv[1]

if not os.path.isfile(filename):
    sys.exit(0)

file_name, file_extension = os.path.splitext(filename)
outfilename = f"{file_name}_result{file_extension}"
print("read file" + file_name)
print("output " + outfilename)
#sys.exit(0)

try:
    clip = (VideoFileClip(filename)
            .subclipped(VideoFileClip(filename).duration - 60*25, VideoFileClip(filename).duration)
        )
    # Get and print video information
    print(f"Video Duration: {clip.duration} seconds")
    print(f"Video FPS: {clip.fps}")
    print(f"Video Resolution: {clip.size[0]}x{clip.size[1]} pixels")
    print(f"Video Width: {clip.w} pixels")
    print(f"Video Height: {clip.h} pixels")
    print(f"Video Rotation: {clip.rotation} degrees")
    clip.write_videofile(outfilename, audio_codec="aac", codec="h264_nvenc", fps=30) #for GPU codec="h264_nvenc"
    clip.close()
except:
    print("file fail" + filename)
