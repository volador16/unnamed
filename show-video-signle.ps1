# 解码并显示单一视频; 
# usage: show-video-signle.ps1 -w 480 -h 384 -l 100 -t 100
#   -w: 视频显示窗口的宽
#   -h: 视频显示窗口的高
#   -l: 视频显示的左边位置
#   -t：视频显示的顶部位置
param(
    [string]$i=$(throw "Parameter missing: -i input video file"),
    [int]$w=$(throw "Parameter missing: -w width"),
    [int]$h=$(throw "Parameter missing: -h height"),
    [int]$l=$(throw "Parameter missing: -l left"),
    [int]$t=$(throw "Parameter missing: -t top")
)

Write-Host "ffmpeg -benchmark -hide_banner -hwaccel cuda -i $i -vf "scale=$w`:$h" -pix_fmt yuv420p -f rawvideo - | ffplay -autoexit -noborder -left $l -top $t -f rawvideo -pixel_format yuv420p -video_size $w"x"$h -"
ffmpeg -benchmark -hide_banner -hwaccel cuda -i $i -vf "scale=$w`:$h" -pix_fmt yuv420p -f rawvideo - | ffplay -hide_banner -autoexit -noborder -left $l -top $t -f rawvideo -pixel_format yuv420p -video_size $w"x"$h -