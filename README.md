# unnamed

玲：

    基于昨天的交流，随后我查找了一些ffmpeg方面的知识并总结如下：

#### 1. 如果只是视频的解码(decoding)这个需求还需要找外包吗？这点东西我个人觉得没必要。当然，如果你那边忙不过来，又或者是帮我找点活的话除外。

#### 2. 硬件解码和软解码使用的API是不同的，硬解码对系统的环境要求高于软解。
#### Intel GPU：
需要使用支持 Intel QuickSync 技术的FFmpeg版本，并拥有支持QuickSync技术的 Intel GPU的计算机。具体参见：
https://trac.ffmpeg.org/wiki/Hardware/QuickSync


#### NVDIA GPU：
参见：
https://trac.ffmpeg.org/wiki/HWAccelIntro

#### 3. 由于使用了ffmpeg的library，已经大大简化了视频的编解码工作。
#### 硬解码demo：
https://github.com/FFmpeg/FFmpeg/blob/master/doc/examples/hw_decode.c
#### 软解码demo：
https://github.com/FFmpeg/FFmpeg/blob/master/doc/examples/decode_video.c

#### 4. 如果是视频解码模块，那么需要我们协商好input和output分别是什么？


