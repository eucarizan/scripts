# scripts

- [scripts](#scripts)
  - [downloads a video stream](#downloads-a-video-stream)

## downloads a video stream
- downloads a video stream
- saves it as an mp4 file with your chosen filename

download file
file|description
:-:|:-:
[dl_v1.sh](./download_stream/dl_v1.sh)|download video from m3u8 file
[merge_dl.sh](./download_stream/merge_dl.sh)|download video+audio from hls master playlist
[download.sh](./download_stream/lib/download.sh)|main ffmpeg download script


util
file|description
:-:|:-:
[dl.sh](./download_stream/dl.sh)|merge dl modular
[info.sh](./download_stream/info.sh)|counting the lines of a m3u8 file
[cleanup.sh](./download_stream/lib/cleanup.sh)|clean up files
[extract_urls.sh](./download_stream/lib/extract_urls.sh)|extract video url and audio url
[validate.sh](./download_stream/lib/validate.sh)|check for missing file and ffmpeg installation
[paths.sh](./download_stream/config/paths.sh)|configuration file

<!--
older version
file|description
:-:|:-:
-->


## compress videos
- compress videos using ffmpeg

compress file
file|description
:-:|:-:
[compress.sh](./compress_videos/compress.sh)|ffmpeg extreme video compression
<!--
- includes safety checks to prevent errors
-->
<hr/>

<!--
<details>
<summary></summary>

### 
#### 

</details>
<hr/>
-->

