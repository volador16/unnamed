#!/bin/bash
# 使用单ffmpeg进程同时解码多个输入,多ffplay进程对每个输入进行显示
d_type="soft"
is_show=""
only_decode=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    -i)
        shift
        inpath="$1"
        ;;
    -c)
        shift
        count="$1"
        ;;
    -w)
        shift
        width="$1"
        ;;
    -h)
        shift
        height="$1"
        ;;
    -d)
        shift
        d_type="$1"
        ;;
    -show_video)
        is_show="show"
        ;;
    -only_decode)
        only_decode="only_decode"
        ;;
    *)
      echo "未知的参数: $1"
      echo "usage: sh single-ffmpeg_mutil-play.sh -i input-path -w 320 -h 240 [-d cuda] [-show_video] [-only_decode]"
      exit 1
      ;;
  esac
  shift
done

if [[ -z $inpath ]] || [[ -z $width ]] || [[ -z $height ]] || [[ -z $count ]]; then
    echo "usage: sh single-ffmpeg_mutil-play.sh -i input-video -w 320 -h 240 -d cuda"
    exit 1
fi
# brief: 拼接input参数, 用在单进程方式
splicing_input() {
    local count=$1
    local file_ary=(${2//,/ })
    local res=""

    for ((i=0; i<$count; i++))
    do
        file=${file_ary[${i}]}
        res=$res" -i "${file}
    done
    echo $res
}
# @brief: 获取屏幕分辨率
get_screen_resolution() {
    #todo: Cygwin的xserver没有配置好
    #xdpyinfo | grep dimensions
    screen_width=$((1440*2))
    #screen_width=$((1920*1))
    echo $screen_width
}
# @brief: 获取指定目录下的所有文件
get_files_in_path() {
    local path=$1
    local files=()

    for file in "$path"/*.mkv; do
        if [ -f "$file" ]; then
            files+=("$file")
        fi
    done
    echo "${files[@]}"
}
# @brief: 根据屏幕分辨率和输出视频尺寸计算视频的left和top
calculate_position() {
    local idx=$1
    local screen_width=$2
    local video_width=$3
    local video_height=$4

    cols=$(($screen_width / $video_width))
    row_idx=$(($idx / $cols))
    col_idx=$(($idx % $cols))

    left=$(($col_idx * $video_width))
    #top=$(($row_idx * $video_height + 70))
    top=$(($row_idx * $video_height))

    local res=("$left" "$top")
    echo "${res[@]}"
}
# brief: 拼接vf参数
splicing_vf() {
    local count=$1
    local screen_width=$2
    local video_width=$3
    local video_height=$4
    local res="-filter_complex "
    #拼接scale部分
    for ((i=0; i<$count; i++))
    do
        res=$res"["$i":v]scale="$video_width":"$video_height",setpts=N/FRAME_RATE/TB[v"$i"];"
    done
    
    res=${res%?}
    #echo "\""$res"\"" $cols $rows
    echo $res
}
#拼接map参数
splicing_map() {
  local count=$1
  local ret=""

  for ((i=0; i<$count; i++))
  do
    if [[ "$only_decode" != "only_decode" ]]; then
        ret=$ret" -map [v"$i"] -f matroska pipes/pipe"$i
    else
        ret=$ret" -map [v"$i"] -f null -"
    fi
  done
  echo $ret
}

mkdir -p logs
mkdir -p pipes
screen_width=$(get_screen_resolution)

if [[ "$is_show" = "show" ]]; then
#启动ffplay进程,等待piep输出
    for ((i=0; i<$count; i++))
    do
        lt=$(calculate_position $i $screen_width $width $height)
        IFS=" " read -r left top <<< "$lt"
        mkfifo "pipes/pipe"$i
        echo "ffplay -loglevel quiet -autoexit -left $left -top $top -f matroska -i pipes/pipe${i}"
        nohup ffplay -loglevel quiet -autoexit -left $left -top $top -f matroska -i pipes/pipe${i} > logs/ffplay-${i}.log 2>&1 &
    done
    #等待所有ffplay进程启动完毕
    sleep 2
fi

files=$(get_files_in_path $inpath)
files_ary=(${files// /,})
parm_input=$(splicing_input $count $files_ary)
parm_vf=$(splicing_vf $count $screen_width $width $height)
parm_map=$(splicing_map $count)

case $d_type in
    cuda)
        #ffplay -loglevel quiet -autoexit -noborder -vcodec h264_cuvid -vf "scale=$width:$height" -left $left -top $top $input
        # GPU独立模式; cuda的缩放参数需要专门写一个函数
        #ffmpeg -benchmark -hide_banner -hwaccel cuda -hwaccel_output_format cuda -c:v h264_cuvid -i $input -c:v h264_nvenc -f matroska - | ffplay -loglevel quiet -autoexit -noborder -left $left -top $top -vcodec h264_cuvid -f matroska -
        # CPU+GPU混合模式
        cmd_str="ffmpeg -benchmark -hide_banner -hwaccel cuda -c:v h264_cuvid $parm_input $parm_vf $parm_map"
        ffmpeg -y -benchmark -hide_banner -hwaccel cuda -c:v h264_cuvid $parm_input $parm_vf $parm_map > ffmpeg-result.log 2>&1
        ;;
    qsv)
        cmd_str="ffmpeg -benchmark -hide_banner -c:v h264_qsv -gpu_copy 1 $parm_input $parm_vf $parm_map"
        ffmpeg -y -benchmark -hide_banner -c:v h264_qsv -gpu_copy 1 $parm_input $parm_vf $parm_map > ffmpeg-result.log 2>&1
        ;;
    amd)
        #Native 模式：解码后的视频保留在 GPU 内存中，直到显示为止。视频解码器必须与视频渲染器直接连接，没有中间处理过滤器。
        #Copy-back 模式：解码后的视频从 GPU 内存复制回 CPU 内存。
        cmd_str="ffmpeg -benchmark -hide_banner -hwaccel d3d11va -hwaccel_device amf $parm_input $parm_vf $parm_map"
        ffmpeg -y -benchmark -hide_banner -hwaccel d3d11va -hwaccel_device amf $parm_input $parm_vf $parm_map > ffmpeg-result.log 2>&1
        ;;
    soft)
        cmd_str="ffmpeg -benchmark -hide_banner $parm_input $parm_vf $parm_map"
        ffmpeg -y -benchmark -hide_banner $parm_input $parm_vf $parm_map > ffmpeg-result.log 2>&1
        ;;
    *)
        echo "仅支持[cuda|qsv|amd|soft]这4种解码方式"
        exit 1
esac
#ffmpeg -i input/segment_1.mkv -i input/segment_2.mkv -map 0 -f matroska pipes/pipe1 -map 1 -f matroska pipes/pipe2
echo $cmd_str
rm pipes/*