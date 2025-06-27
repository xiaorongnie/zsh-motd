#!/bin/bash

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

# 系统信息采集
HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $1}')
KERNEL=$(uname -r)
USER=$(whoami)

# 获取最后登录信息（包含远程IP）
LAST_LOGIN_INFO=$(last -F -n 1 "$USER" | grep -v 'wtmp begins' | head -n 1)
LAST_LOGIN_TIME=$(echo "$LAST_LOGIN_INFO" | awk '{for(i=4;i<=8;i++) printf "%s ", $i}' | xargs)
REMOTE_IP=$(echo "$LAST_LOGIN_INFO" | awk '{print $3}')

# 读取上次登录完整时间，过滤掉wtmp头信息
LAST_LOGIN_LINE=$(last -F -n 1 "$USER" | grep -v 'wtmp begins' | head -n 1)
LAST_LOGIN=$(echo "$LAST_LOGIN_LINE" | awk '{for(i=4;i<=8;i++) printf "%s ", $i}')
LAST_LOGIN=$(echo "$LAST_LOGIN" | xargs)

LOAD_RAW=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ //')
UPTIME_SEC=$(awk '{print int($1)}' /proc/uptime)
UPTIME_FMT=$(printf "%d天 %d小时 %d分钟 %d秒" $((UPTIME_SEC/86400)) $((UPTIME_SEC%86400/3600)) $((UPTIME_SEC%3600/60)) $((UPTIME_SEC%60)))
CPU_MODEL=$(grep 'model name' /proc/cpuinfo | head -n 1 | cut -d ':' -f 2 | xargs)
CPU_CORES=$(grep -c ^processor /proc/cpuinfo)
RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
RAM_USED=$(free -m | awk '/Mem:/ {print $3}')
RAM_FREE=$(free -m | awk '/Mem:/ {print $4}')
SWAP_TOTAL=$(free -m | awk '/Swap:/ {print $2}')
SWAP_USED=$(free -m | awk '/Swap:/ {print $3}')
SWAP_FREE=$(free -m | awk '/Swap:/ {print $4}')
DISK_USAGE=$(df -h / | awk '/\/$/ {print $3 "/" $2}')
LOGIN_SESSIONS=$(who | wc -l)
PROCESS_COUNT=$(ps aux | wc -l)
CURRENT_TIME=$(date "+%Y-%m-%d %H:%M:%S")
INTERFACES=$(ip -o -4 addr show | awk '{print $2,$4}' | sort -u)

# 解析负载三段
LOAD1=$(echo "$LOAD_RAW" | cut -d',' -f1 | xargs)
LOAD5=$(echo "$LOAD_RAW" | cut -d',' -f2 | xargs)
LOAD15=$(echo "$LOAD_RAW" | cut -d',' -f3 | xargs)

# TG Logo
echo -e "${BLUE}"
cat << "EOF"
 _______   ______
|__   __| |  ____|
   | |    | |  __   ___   ___
   | |    | | |_ | / _ \ / _ \
   | |    | |__| ||  __/|  __/
   |_|     \_____| \___| \___|
            T   G
EOF
echo -e "${NC}"

# 系统信息展示
echo -e "${YELLOW}📅 时间       : ${CURRENT_TIME}${NC}"
printf "${CYAN}🧑 用户       : %-15s 🖥️ 主机名   : %s${NC}\n" "$USER" "$HOSTNAME"
echo -e "📦 内核版本   : ${KERNEL}"
echo -e "🧠 内存使用   : RAM 总计 ${RAM_TOTAL} MiB / 已用 ${RAM_USED} MiB / 空闲 ${RAM_FREE} MiB"
echo -e "             : Swap 总计 ${SWAP_TOTAL} MiB / 已用 ${SWAP_USED} MiB / 空闲 ${SWAP_FREE} MiB"
echo -e "💽 根分区使用 : ${DISK_USAGE}"
echo -e "🧮 CPU信息    : ${CPU_MODEL} (${CPU_CORES} 核心)"
echo -e "📈 系统负载   : 1分: ${LOAD1} | 5分: ${LOAD5} | 15分: ${LOAD15}"
echo -e "⏱️ 运行时长   : ${UPTIME_FMT}"
echo -e "👥 会话数     : ${LOGIN_SESSIONS}   🧵 进程数: ${PROCESS_COUNT}"
echo -e "🔐 上次登录   : ${LAST_LOGIN}  ${REMOTE_IP} -> ${IP}"

# 网络接口信息（移除MAC地址，仅显示接口名 + IP）
echo -e "${GREEN}🌐 活跃网络接口:${NC}"
printf "  %-15s %-20s\n" "名称" "IPv4地址"
while read -r iface; do
    NAME=$(echo "$iface" | awk '{print $1}')
    IPADDR=$(echo "$iface" | awk '{print $2}')
    printf "  %-15s %-20s\n" "$NAME" "$IPADDR"
done <<< "$INTERFACES"
