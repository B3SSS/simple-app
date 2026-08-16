#!/bin/bash

SCRIPT_NAME=$(basename "$0" .sh)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${SCRIPT_NAME}_${TIMESTAMP}.log"

exec > >(tee -a "$LOG_FILE") 2>&1 

diagnostics() {
    echo "=== Server Diagnostics ==="
    echo "Date    : $(date +"%F %T")"
    echo "Hostname: $(hostname -s)"
    echo "OS      : $(grep "PRETTY_NAME" /etc/os-release | cut -d'"' -f2)"
    echo "Kernel  : $(uname -r)"
    echo "Uptime  : $(uptime -p | sed 's/up //g')" 
    echo ""
}

resources() {
    echo "=== Resources ==="
    echo "CPU   : $(nproc) cores, load average: $(awk '{print $1, $2, $3}' /proc/loadavg)"
    echo "RAM   : $(free -h | awk 'NR==2{printf "%s / %s (%.1f%%)\n", $3, $2, $3/$2*100}')"
    echo "Disk /: $(df -h / | awk 'NR==2{printf "%s / %s (%.1f%%)\n", $3, $2, $3/$2*100}')"
    echo ""
}

docker_containers() {
    echo "=== Docker ==="
    if [[ $(docker ps -q | wc -l) -eq 0 ]]; then
        echo "0 running containers"
    else
        docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}"
    fi
    echo ""
}

service_health_checks() {
    echo "=== Service Health Checks ==="
    local total=0
    local running=0
    for service in "$@"; do
        ((total++))
        response=$(curl -s -o /dev/null -H "Content-Type: application/json" -w "%{http_code}|%{time_total}" ${service} 2>&1)
        if [[ $? -eq 0  ]]; then
            ((running++))
            status=$(echo "${response}" | cut -d'|' -f1)
            time_sec=$(echo "${response}" | cut -d'|' -f2)
            time_ms=$(echo "${time_sec} * 1000" | bc | cut -d. -f1)
            echo "[OK] ${service} (${status}, ${time_ms}ms)"
        else
            echo "[FAIL] ${service} (connection refused)"
        fi
    done
    echo ""
    echo "Result: ${running}/${total} services healthy"
}

show_help() {
    script_name=$(basename "$0")
    echo "Usage: $script_name [Options]"
    echo ""
    echo "Script for A lightweight script for quick system resource and Docker container monitoring."
    echo "Example: $script_name http://localhost:5000/health"
    echo ""
    echo "Options:"
    echo "  --help      Show this help message and exit"
    exit 0
}

show_server_info() {
    for arg in "$@"; do
        if [[ $arg == "--help" ]]; then
            show_help $@
        fi
    done

    diagnostics
    resources

    check_docker=$(docker --version > /dev/null 2>&1)
    if [[ $? -eq 0 ]]; then
        docker_containers
    fi

    check_curl=$(curl --version > /dev/null 2>&1)
    if [[ $? -eq 0 && $# -ne 0 ]]; then
        service_health_checks $@
    fi
}

show_server_info $@
