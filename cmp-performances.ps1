$totalTime = 0
$loopNum = 10
# 使用QSV解码
for ($i = 1; $i -le $loopNum; $i++) {
    #rm C:\Users\zuo.jin\qsv-output.yuv
    $startTime = Get-Date
    # 执行你的命令  -loglevel verbose
    #ffmpeg  -hide_banner -c:v h264_qsv -gpu_copy 1 -i .\output.mp4 -c:v rawvideo -pix_fmt yuv420p qsv-output.yuv
    ffmpeg -loglevel quiet -hide_banner -c:v h264_qsv -gpu_copy 1 -i .\output.mp4 -f null -
    $endTime = Get-Date
    $executionTime = $endTime - $startTime
    $totalTime = $executionTime + $totalTime
}
$execAgvTime = $totalTime / $loopNum
Write-Host "QSV Decoder average execution time: $execAgvTime"
# 使用软件解码的方式
$totalTime = 0
for ($i = 1; $i -le $loopNum; $i++) {
    #rm C:\Users\zuo.jin\qsv-output.yuv
    $startTime = Get-Date
    # 执行你的命令  -loglevel verbose
    #ffmpeg -hide_banner -c:v h264 -i .\output.mp4 -c:v rawvideo -pix_fmt yuv420p sft-output.yuv
    ffmpeg -loglevel quiet -hide_banner -c:v h264 -i .\output.mp4 -f null -
    $endTime = Get-Date
    $executionTime = $endTime - $startTime
    $totalTime = $executionTime + $totalTime
}
$execAgvTime = $totalTime / $loopNum
Write-Host "software Decoder average execution time: $execAgvTime"
