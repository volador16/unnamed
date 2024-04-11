#!/bin/bash
#
# 该脚本用于将一段长视频分割成若干个时长1分钟的片段。为后续多路输入，同时decode做输入。
# 由于使用频率低，故都采用硬编码，需要用是请注意修改 input_file、output_directory、segment_duration这些变量
#
input_file="/Users/zuo/Downloads/Dune.Part.Two.2024.1080p.WEBRip.x264./Dune.Part.Two.2024.1080p.WEBRip.x264.Dual.YG.mkv"
output_directory="output"
segment_duration="00:01:00"

# 将"00:01:00"格式的时间转换为秒,返回秒数
convert_time_to_seconds() {
  time=$(echo "$1" | awk -F: '{printf "%d,%d,%d\n", $1, $2, $3}')
  IFS="," read -r hours minutes seconds <<< "$time"
  total_seconds=$((hours * 3600 + minutes * 60 + seconds))
  echo $total_seconds
}
# 两个输入
# 1. “00:00:00”格式的时间； 2. int秒数
# 返回 参数1的时间加上参数2的秒数后的时间。 格式"xx:xx:xx"
add_seconds_to_time() {
  input_time=$(echo "$1" | awk -F: '{printf "%d,%d,%d\n", $1, $2, $3}')
  seconds=$2

  # Convert input time to seconds
  IFS=',' read -r -a time_array <<< "$input_time"
  input_seconds=$((time_array[0] * 3600 + time_array[1] * 60 + time_array[2]))

  # Add seconds to input time
  result_seconds=$((input_seconds + seconds))

  # Calculate hours, minutes, and seconds for the result
  result_hours=$((result_seconds / 3600))
  result_minutes=$(((result_seconds % 3600) / 60))
  result_seconds=$((result_seconds % 60))

  # Format the result as "00:00:00"
  printf "%02d:%02d:%02d\n" "$result_hours" "$result_minutes" "$result_seconds"
}
# Create the output directory if it doesn't exist
mkdir -p "$output_directory"

# Calculate the segment duration in seconds
#segment_duration_seconds=$(ffmpeg -i "$input_file" 2>&1 | grep Duration | awk '{print $2}' | tr -d , | awk -F: '{print ($1 * 3600) + ($2 * 60) + $3}')
# 计算视频总时长
input_total_seconds=$(convert_time_to_seconds `ffmpeg -i "$input_file" 2>&1 | grep Duration | awk '{print $2}' | tr -d , | awk -F. '{print $1}'`)
# Calculate the number of segments
num_segments=128
segment_duration_seconds=$(convert_time_to_seconds $segment_duration)
if [ $input_total_seconds -lt $(($num_segments * $segment_duration_seconds)) ]; then
    echo "视频的长度:$segment_duration_seconds/s. 无法分割成时长: $segment_duration, 分片总数: $num_segments."
    exit -1
fi

# Calculate the segment start time
segment_start_time="00:00:00"

# Split the video into segments
for ((i=0; i<"$num_segments"; i++))
do
    segment_output_file="$output_directory/segment_$i.mp4"
    #echo "ffmpeg -ss "$segment_start_time" -i "$input_file" -t "$segment_duration_seconds" -c copy "$segment_output_file""
    ffmpeg -ss "$segment_start_time" -i "$input_file" -t "$segment_duration_seconds" -c copy "$segment_output_file"
    segment_start_time=$(add_seconds_to_time "$segment_start_time" $segment_duration_seconds)
done
