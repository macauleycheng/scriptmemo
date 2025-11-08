#!pip install moviepy
from moviepy import VideoFileClip, TextClip, CompositeVideoClip
import os

directory_path = r"\\family_68_2\tmp\bigtorrent\uncover\tmp"  # Replace with your desired directory
contents = os.listdir(directory_path)

for item in contents:
    
    if not os.path.isfile(item):
        pass

    filename, file_extension = os.path.splitext(item)
    if "result" in item:
        continue
    readfilename = f"{directory_path}\\{item}" 
    outfilename = f"{directory_path}\\{filename}_result{file_extension}"
    print(outfilename)

    try:
        clip = (VideoFileClip(readfilename)
                .subclipped(VideoFileClip(readfilename).duration - 1500, VideoFileClip(readfilename).duration)
            )
        # Get and print video information
        print(f"Video Duration: {clip.duration} seconds")
        print(f"Video FPS: {clip.fps}")
        print(f"Video Resolution: {clip.size[0]}x{clip.size[1]} pixels")
        print(f"Video Width: {clip.w} pixels")
        print(f"Video Height: {clip.h} pixels")
        print(f"Video Rotation: {clip.rotation} degrees")
        #print(f"Has Audio: {clip.has_audio}")
        clip.write_videofile(outfilename, audio_codec="aac"
                             ,codec="h264_nvenc"
                             #,fps=30
                             ) #for GPU codec="h264_nvenc"
        clip.close()
    except:
        print("file fail " + item)
    