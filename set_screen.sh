#! /bin/bash
#:<<!
#  设置屏幕分辨率的脚本(xrandr命令的封装)
#  one: 只展示一个内置屏幕 2560x1600 缩放为 1440x900
#  two: 左边展示外接屏幕 - 右边展示内置屏幕 都用匹配1080p屏幕DPI的缩放比
#  check: 检测显示器连接状态是否变化 变化则自动调整输出情况
#!

INNER_PORT=eDP-1-1
MODE=LR
[ "$(xrandr | grep '1920x1080')" ] && MODE=$MODE

__setbg() {
    feh --randomize --bg-fill ~/Pictures/wallpaper/*.jpg
}

#__get_inner_view() {
#    case "$MODE" in
#        ONE) echo "--output $INNER_PORT --mode 1920x1080 --scale 0.5x0.5 --pos 0x0" ;;
#        LR) echo "--output $INNER_PORT --mode 1920x1080 --scale 0.5x0.5 --pos 1920x320" ;;
#        TB) echo "--output $INNER_PORT --mode 1920x1080 --scale 0.5x0.5 --pos 500x1080" ;;
#        HLR) echo "--output $INNER_PORT --mode 1920x1080 --scale 0.5x0.5 --pos 2560x320" ;;
#        HTB) echo "--output $INNER_PORT --mode 1920x1080 --scale 0.5x0.5 --pos 500x1080" ;;
#    esac
#}

__get_inner_view() {
    case "$MODE" in
        ONE) echo "--output $INNER_PORT --mode 1920x1080 --rate 144 " ;;
        LR) echo "--output $INNER_PORT --mode 1920x1080 --rate 144 " ;;
        TB) echo "--output $INNER_PORT --mode 1920x1080 --rate 144 " ;;
        HLR) echo "--output $INNER_PORT --mode 1920x1080 --rate 144 " ;;
        HTB) echo "--output $INNER_PORT --mode 1920x1080 --rate 144 " ;;
    esac
}

__get_outer_view() {
    outport=$1
    case "$MODE" in
        LR) echo "--output $outport --mode 1920x1080 --scale 0.9999x0.9999 --pos 0x0 --primary --right-of $INNER_PORT  --rate 144" ;;
        TB) echo "--output $outport --mode 1920x1080 --scale 0.9999x0.9999 --pos 0x0 --primary --rate 144" ;;
        HLR) echo "--output $outport --mode 1920x1080 --scale 0.9999x0.9999 --pos 0x0 --primary --rate 144" ;;
        HTB) echo "--output $outport --mode 1920x1080 --scale 0.9999x0.9999 --pos 0x0 --primary --rate 144" ;;
    esac
}

__get_off_views() {
    for sc in $(xrandr | awk '/connected/ && !/disconnected/ {print $1}'); do echo "--output $sc --off"; done
    #xrandr | grep 'connected' | awk '{print $1}'
}


one() {
    MODE=ONE
    xrandr $(__get_off_views) $(__get_inner_view)
    __setbg
}

two() {
    OUTPORT_CONNECTED=$(xrandr | grep -v $INNER_PORT | grep -w 'connected' | awk '{print $1}')
    [ ! "$OUTPORT_CONNECTED" ] && one && return
    xrandr $(__get_off_views) $(__get_inner_view) $(__get_outer_view $OUTPORT_CONNECTED)
    __setbg
}

check() {
    CONNECTED_PORTS=$(xrandr | grep -w 'connected' | awk '{print $1}' | wc -l)
    CONNECTED_MONITORS=$(xrandr --listmonitors | sed 1d | awk '{print $4}' | wc -l)
    [ $CONNECTED_PORTS -gt $CONNECTED_MONITORS ] && two 
    [ $CONNECTED_PORTS -lt $CONNECTED_MONITORS ] && one
}

check

#case $1 in
#    one) one ;;
#    two) two ;;
#    *) check ;;
#esac
