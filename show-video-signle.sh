#!/bin/bash
#该脚本用于解码视频并显示在屏幕上
#usage: bash show-vido-signle.sh -i input-video -w 480 -h 384 -l 100 -t 100 -d cuda|qsv|amd|soft
d_type="soft"

while [ "$#" -gt 0 ]; do
  case "$1" in
    -i)
        shift
        input="$1"
        ;;
    -w)
        shift
        width="$1"
        ;;
    -h)
        shift
        height="$1"
        ;;
    -l)
        shift
        left="$1"
        ;;
    -t)
        shift
        top="$1"
        ;;
    -d)
        shift
        d_type="$1"
        ;;
    *)
      echo "未知的参数: $1"
      echo "usage: sh show-vido-signle.sh -i input-video -w 480 -h 384 -l 100 -t 100 -d cuda"
      exit 1
      ;;
  esac
  shift
done

if [[ -z $input ]] || [[ -z $width ]] || [[ -z $height ]] || [[ -z $left ]] || [[ -z $top ]]; then
    echo "usage: sh show-vido-signle.sh -i input-video -w 480 -h 384 -l 100 -t 100 -d cuda"
    exit 1
fi

case $d_type in
    cuda)
        #ffplay -loglevel quiet -autoexit -noborder -vcodec h264_cuvid -vf "scale=$width:$height" -left $left -top $top $input
        # 无法使用cuda 硬编码, 因为session限制
        #ffmpeg -benchmark -hide_banner -hwaccel cuda -hwaccel_output_format cuda -c:v h264_cuvid -i $input -c:v h264_nvenc -f matroska - | ffplay -loglevel quiet -autoexit -noborder -left $left -top $top -vcodec h264_cuvid -f matroska -
        # 不用硬件编码就需要copy, 机器内存不够. 频繁swap
        #ffmpeg -benchmark -hide_banner -hwaccel cuda -c:v h264_cuvid -i $input -f matroska - | ffplay -loglevel quiet -autoexit -noborder -left $left -top $top -vcodec h264_cuvid -f matroska -
        # 只测试解码, 不显示
        ffmpeg -benchmark -hide_banner -hwaccel cuda -c:v h264_cuvid -i $input -f null -
        #ffmpeg -benchmark -hide_banner -hwaccel cuda -c:v h264_cuvid -i $input -vf "scale=$width:$height" -an -pix_fmt yuv420p -f rawvideo - | ffplay -loglevel quiet -autoexit -noborder -left $left -top $top -f rawvideo -pixel_format yuv420p -video_size $width"x"$height -
        ;;
    qsv)
        ffmpeg -benchmark -hide_banner -c:v h264_qsv -gpu_copy 1 -i $input -vf "scale=$width:$height" -f matroska - | ffplay -loglevel quiet -autoexit -noborder -left $left -top $top -f matroska -
        ;;
    amd)
        cmd="ffmpeg -benchmark -hide_banner -hwaccel d3d11va -hwaccel_device amf -i $input -vf "scale=$width:$height" -an -c:v h264_amf -pix_fmt yuv420p -f rawvideo - | ffplay -loglevel warning -autoexit -noborder -left $left -top $top -vcodec h264 -f rawvideo -video_size $width"x"$height -"
        echo $cmd
        `$cmd`
        #ffmpeg -benchmark -hide_banner -hwaccel d3d11va -i $input -vf "scale=$width:$height" -c:v h264_amf -f matroska - | ffplay -loglevel quiet -autoexit -noborder -left $left -top $top -f matroska -
        ;;
    soft)
        ffmpeg -benchmark -hide_banner -c:v h264 -i $input -vf "scale=$width:$height" -f matroska - | ffplay -loglevel quiet -autoexit -noborder -left $left -top $top -f matroska -
        ;;
    *)
        echo "仅支持[cuda|qsv|amd|soft]这4种解码方式"
        exit 1
esac

