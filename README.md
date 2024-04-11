# unnamed

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

***
主要是基於人力的不足, 要把上述參考內容變成真正能用的東西, 還是需要時間. 我們這一兩年也在試圖招人, 但這邊在software方面的人力也真的不多, 基於公司的條件, 好一點的都不會來. 所以我才想到外包這種方式.
我先粗略說一下這個模塊的需求: 基於最新版的ffmpeg版本, windows平台, 32/64bits, 軟解/硬解(Intel GPU / Nvidia GPU), 同時可以做到128/256個Video的decode
API如下:
1. Init 初始化
   handle = init(in_format, out_format, callback, winHandle);
   in_format: 必需, h264/h265
   out_format: 必需, YUV420/RGB24
   callback: 選項, 如果是非同步decode, decode的結果由callback回傳
   winHandle: 選項, 視窗Handle, 將decode結果直接畫到視窗上

2. Deocde 解碼Video Frame...
   int iRet = DecodeFrame(handle, in_buffer, bufferLength, &outBuffer, &outWidth, &outHeight); block decode的方式   
   int iRet = DecodeFrame(handel, in_buffer, bufferLength); callback回傳結果(outBuffer, outWidth, outHeight), unblock decode的方式
   int iRet = DecodeFrame(handle, in_buffer, bufferLength); 直接畫到winHandle對應的視窗上
   handle: init的返回值
   in_buffer: video encode的frame buffer
   bufferLength: frame buffer的長度
   outBuffer: decoded的frame buffer
   outWidth: frame的寬度
   outHeight: frame的高度

3. DeInit 結束, 釋放資源
   DeInit(handle)
   handle: init的返回值

第一階段可能是這樣的功能, 後續會添加轉碼

   參考連結:
   https://www.networkoptix.com/nx-witness
   https://www.networkoptix.com/nx-witness/try-nx-witness-sign-up
   https://support.networkoptix.com/hc/en-us/articles/205752937-Windows-OS-Installation-Guide
   https://support.networkoptix.com/hc/en-us/articles/4410768424471-Nx-Witness-Prerequisites-Setup-Maintenance

   你評估看看
