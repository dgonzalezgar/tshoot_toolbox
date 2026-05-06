#!/bin/bash


# ==============================================================================
# Multi-Interface Ping Logger
# ==============================================================================
# 
# This script continuously pings specified target IPs from one or more source 
# network interfaces. It automatically handles log rotation and tags each log 
# entry with the corresponding source interface and a timestamp.
# 
# Usage:
# Use the -i flag for each source interface and the -t flag for each target IP 
# address. You must provide at least one of each.
# 
# ./ping_script.sh -i <interface1> [-i <interface2> ...] -t <target_ip1> [-t <target_ip2> ...]
# 
# Example:
# To ping Google DNS and Cloudflare DNS using both your ISP2 (eth0) and 
# ISP2 (eth1) interfaces, run:
# 
# ./ping_script.sh -i eth0 -i eth1 -t 8.8.8.8 -t 1.1.1.1
# ==============================================================================

# Base log file name
BASE_LOG_FILE="ping_log"

# Maximum number of log files
MAX_LOG_FILES=10

# Maximum size of each log file in bytes (50MB * 1024 * 1024)
MAX_FILE_SIZE=$((50 * 1024 * 1024))

# Number of pings per cycle
PING_COUNT=5

# Sleep duration between cycles (in seconds)
SLEEP_DURATION=1

# Initialize log file counter
LOG_FILE_COUNTER=0

# Initialize arrays for interfaces and an associative array for their specific targets
# Note: Associative arrays require Bash 4.0 or higher
declare -A INTERFACE_TARGETS
INTERFACES=()
CURRENT_INTERFACE=""

# Parse command line arguments using flags
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -i|--interface) 
      CURRENT_INTERFACE="$2"
      # Add interface to our list if it isn't already there
      if [[ ! " ${INTERFACES[*]} " =~ " ${CURRENT_INTERFACE} " ]]; then
        INTERFACES+=("${CURRENT_INTERFACE}")
      fi
      shift ;;
    -t|--target) 
      # Ensure an interface was declared before capturing its targets
      if [[ -z "${CURRENT_INTERFACE}" ]]; then
        echo "Error: You must specify an interface (-i) before its target (-t)."
        exit 1
      fi
      # Append the target IP (with a space) to the current interface's list
      INTERFACE_TARGETS["${CURRENT_INTERFACE}"]+="$2 "
      shift ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Check if at least one interface is provided
if [ "${#INTERFACES[@]}" -lt 1 ]; then
  echo "Usage: $0 -i <source_intf1> -t <target1> [-t <target2>] [-i <source_intf2> -t <target3> ...]"
  echo "Example: $0 -i eth0 -t 8.8.8.8 -t 1.1.1.1 -i wlan0 -t 9.9.9.9"
  exit 1
fi

# Ensure every declared interface has at least one target assigned to it
for INTF in "${INTERFACES[@]}"; do
  if [[ -z "${INTERFACE_TARGETS[$INTF]}" ]]; then
    echo "Error: Interface ${INTF} was declared but has no target IPs assigned."
    exit 1
  fi
done

# Function to get the current log file name
get_log_file_name() {
  echo "${BASE_LOG_FILE}.${LOG_FILE_COUNTER}"
}

# Function to check file size and rotate logs if necessary
check_and_rotate_log() {
  CURRENT_LOG_FILE=$(get_log_file_name)

  # Check if the current log file exists and its size
  if [ -f "${CURRENT_LOG_FILE}" ]; then
    CURRENT_SIZE=$(stat -c%s "${CURRENT_LOG_FILE}")

    if [ "${CURRENT_SIZE}" -ge "${MAX_FILE_SIZE}" ]; then
      echo "$(date +'%Y-%m-%d %H:%M:%S') --- Log file ${CURRENT_LOG_FILE} reached max size, rotating... ---" >> "${CURRENT_LOG_FILE}" # Log rotation event
      LOG_FILE_COUNTER=$(( (LOG_FILE_COUNTER + 1) % MAX_LOG_FILES )) # Increment counter and wrap around
      NEW_LOG_FILE=$(get_log_file_name)
      echo "$(date +'%Y-%m-%d %H:%M:%S') --- New log file is ${NEW_LOG_FILE} ---" >> "${NEW_LOG_FILE}" # Log rotation event in new file
      # Note: Overwriting happens naturally when the counter cycles back to 0
    fi
  fi
}

echo "Starting timestamped ping from interfaces: ${INTERFACES[*]}"
echo "Log rotation enabled (${MAX_LOG_FILES} files, ${MAX_FILE_SIZE} bytes max each)."

# Loop indefinitely for continuous monitoring
while true; do
  
    # Loop through all provided interfaces
    for INTERFACE in "${INTERFACES[@]}"; do
  
        # Extract the specific targets for this interface into an array
        read -ra CURRENT_TARGETS <<< "${INTERFACE_TARGETS[$INTERFACE]}"

        # Loop through the targets assigned ONLY to this interface
            for TARGET_IP in "${CURRENT_TARGETS[@]}"; do
                # Check and rotate log before writing the ping start message
                check_and_rotate_log
                CURRENT_LOG_FILE=$(get_log_file_name)
                echo "$(date +'%Y-%m-%d %H:%M:%S') --- [${INTERFACE}] Pinging ${TARGET_IP} ---" >> "${CURRENT_LOG_FILE}"

                # Execute ping, pipe output to a while loop to process line by line
                # Redirect stderr to stdout (2>&1) to capture errors like "Network is unreachable"
                ping -I "${INTERFACE}" -c "${PING_COUNT}" "${TARGET_IP}" 2>&1 | while read pong; do
                    # Check and rotate log before writing each line of ping output
                    check_and_rotate_log
                    CURRENT_LOG_FILE=$(get_log_file_name)
                    
                    # Prepend current timestamp and the INTERFACE name to each line of ping output
                    echo "$(date +'%Y-%m-%d %H:%M:%S') [${INTERFACE}] $pong" >> "${CURRENT_LOG_FILE}"
                done
            done

      # Check and rotate log before writing the ping finish message
      check_and_rotate_log
      CURRENT_LOG_FILE=$(get_log_file_name)
      echo "$(date +'%Y-%m-%d %H:%M:%S') --- [${INTERFACE}] Finished pinging ${TARGET_IP} ---" >> "${CURRENT_LOG_FILE}"
    done
    

  # Wait before the next cycle of pings to all targets
  sleep "${SLEEP_DURATION}"
done