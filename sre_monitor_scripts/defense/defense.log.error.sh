#!/bin/sh

source ../lib

METRIC='defense.log.error'
STEP=60
TAGS="service=defense"

LOG_FILE="/opt/defense/logs/runtime.log"
CURRENT_TIME=$(date +"%Y-%m-%d %H:%M" -d'1 minutes ago')

check() {
    local RESULT=0

    if [ -f $LOG_FILE ]; then
        RESULT=`grep "ERROR" $LOG_FILE | grep "$CURRENT_TIME" | wc -l`
    elif [ `ps aux | grep 'defense'| wc -l` -gt 1 ]; then
        RESULT=-1
        echo "defense进程存在但是日志文件不存在"
    else
        RESULT=0
    fi

    report_falcon $METRIC $RESULT $STEP $TAGS
    # 兼容falcon报警配置
    report_falcon network_region_error_public $RESULT $STEP $TAGS
}
gendoc() {
    cat <<EOF
# $METRIC

## 概述

该脚本检查defense的日志文件中是否有ERROR这个关键字出现，如果出现统计次数

## 原理

直接读取"/opt/defense/logs/runtime.log" 文件
会出现以下几种情况
1. 当前机器没有部署defense, 返回0。
2. 当前机器有部署defense但是日志文件不存在， 返回1。
3. 当前机器部署defense并且日志文件存在， 返回错误日志的条数。

## 处理方法

直接读取"/opt/defense/logs/runtime.log" 文件,
根据日志查看原因，比如数据库故障或者keystone故障。
EOF
}


[ "$#" -gt 0 ] || set -- check
"$@"
