# ***MP4Converter***: A Simple MP4 Converter

## Description
This is a simple MP4 converter that allows you to convert video files to MP4 format.
It is built using Lua (love2d) as the most barebones interface and the FFmpeg binaries for the conversion nonsense.

## Installation
To run the MP4Converter, follow these steps:

1. Clone the repository:
```bash
git clone https://github.com/yourusername/mp4converter.git
```

2. Navigate to the project directory:
```bash
cd mp4converter
```

3. Install the required dependencies:
This software uses FFmpeg to convert video files to the MP4 format.
To suffice this dependency, follow these steps:

1. Download the FFmpeg binaries.
2. Extract the downloaded archive.
3. Rename the extracted directory to `ffmpeg-windows64` or `ffmpeg-linux64` depending on your operating system.
4. Move the renamed directory to `./mp4converter/`.
5. On linux machines ensure that the FFmpeg binaries are executable by running `chmod +x ./mp4converter/ffmpeg-linux64/ffmpeg`.

Here are direct links to the FFmpeg archives for each supported platform:
- Windows: [ffmpeg-master-latest-win64-gpl-shared.zip](https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl-shared.zip)
- Linux: [ffmpeg-master-latest-linux64-gpl.tar.xz](https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz)

You have to extract the contents of the downloaded archive to a directory with the following names:
- Windows: `./mp4converter/ffmpeg-windows64/`
- Linux: `./mp4converter/ffmpeg-linux64/`

*It would be packaged in this repository but I'm way too incompetent with Git-LFS*

But I would like to try an automatic downloader for ffmpeg but we will have to wait
for the release of love2d v12.x *that is promised to have support for HTTPS and SSL*.
