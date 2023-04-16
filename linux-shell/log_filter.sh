#!/bin/bash

# 默认日志文件路径
LOG_FILE="app.log"

# 默认时间区间为过去一天
START_TIME=$(date -d "1 day ago" +"%Y-%m-%dT%H:%M:%S.%N+08:00")
END_TIME=$(date +"%Y-%m-%dT%H:%M:%S.%N+08:00")

# 默认正则表达式为空
PATTERN=""

# 默认过滤重复率高的日志
DUPLICATE=false

# 忽略符合正则表达式规则的列
IGNORE_PATTERN=""

# 打印帮助信息
function usage {
    echo "Usage: $0 [-f file] [-s start_time] [-e end_time] [-p pattern] [-i pattern] [-d] [-h]"
    echo "  -f file          Specify the log file path. Default: app.log"
    echo "  -s start_time    Specify the start time of the time range. Default: 1 day ago"
    echo "  -e end_time      Specify the end time of the time range. Default: now"
    echo "  -p pattern       Specify the regular expression pattern for filtering logs. Default: none"
    echo "  -i pattern       Specify the regular expression pattern for ignore columns. Default: none"
    echo "  -d               Disable filtering of high duplicate rate logs. Default: enabled"
    echo "  -h               Print this help message"
}

# 处理命令行参数
while getopts "f:s:e:p:i:dh-:" opt; do
    case $opt in
    f)
        LOG_FILE=$OPTARG
        ;;
    s)
        START_TIME="$OPTARG"
        ;;
    e)
        END_TIME="$OPTARG"
        ;;
    p)
        PATTERN="$OPTARG"
        ;;
    i)
        IGNORE_PATTERN="$OPTARG"
        ;;
    h)
        usage
        exit 0
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
        ;;
    esac
done

echo $IGNORE_PATTERN

# 1. 先按照时间区间进行过滤
# 2. 按照给定pattern正则表达式格式过滤
# 3. 删除掉符合按照给定的delet_pattern正则表达式的列
awk -v start="$START_TIME" -v end="$END_TIME" -v pattern="$PATTERN" -v del_pattern="$IGNORE_PATTERN" '{
    if ($6 ~ /time=/) {
        split($0, a, "time=\"|\"")
        if (a[2] >= start && a[2] <= end && $0 ~ pattern) {
            for (i=1; i<=NF; i++) {
                if (match($i, del_pattern)) {
                    $i = ""
                }
            }
            print $0
        }
    }
} ' "$LOG_FILE"
