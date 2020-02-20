#!/bin/bash


# This script prints all the existing programs and the streams, it uses ffprobe and supports both transport stream or UDP MPEG-2 TS input
# You can use it alongside checkmc.sh script for service and multicast discovery. 

######################################################
# The command line help  and error message functions #
######################################################
display_help() {
    printf "Prints information about all the streams and programs contained in the input multicast, based on ffprobe.\\n\\n"
    printf "Usage: %s -i <input_ts_file>\\n" "$0"
    printf "Usage: %s -i udp://{IP-Address}:{Port}\\n\\n" "$0"
    printf "   -i, --input                input file for analysis, it could be recorded TS file or live stream\\n"
    printf "   -h, --help                  show the help for this program\\n"
    exit 1
}

display_usage() {
    printf "Usage: %s -i <input_ts_file>\\n" "$0"
    printf "Usage: %s -i udp://{IP-Address}:{Port}\\n" "$0"
    printf "Help: %s -h\\n\\n" "$0"
}

display_error() {
    printf "Unrecognized option '%s'.\\n\\n" "$1"
    display_usage
    exit 1
}

display_ts_error() {
    printf "The provided input is not a valid TS file or IP address: '%s'. Please try again\\n\\n" "$1"
    display_help
    exit 1
}

###########################################
# Checks if the defined IP is a valid one #
###########################################
check_ip_address() {
    n='([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])'

    if ! [[ $1 =~ ^$n(\.$n){3}$ ]]; then
        printf "%s' is not valid IP address!\\n\\n" "$1"
        display_usage
        exit 1
    fi
}

#############################################
# Checks if the defined port is a valid one #
#############################################
check_port() {
    if [ "$1" -lt 1024 ] || [ "$1" -gt 65535 ]; then
        printf "The specifie port: %s is outside the range: [1024:65535].\\n" "$1"
        printf "Please define a valid port in the specified above range.\\n\\n"
        display_usage
        exit 1
    fi
}

#####################################
# Checks if the defined file exists #
#####################################
file_not_existing() {
    printf "The input file doesn\\'t exist \\'%s\\'.\\n\\n" "$1"
    display_usage
    exit 1
}

########################################
# Prints the TS statistics via ffprobe #
########################################
ffprobe_print() {
    # Finding out how many characters is the length of the input file/URL
    inp_chars=${#1}
    total_chars=$((inp_chars + 25))
    # Printing 25 + input file/URL characters length number of '#'
    printf '#%.0s' $(seq $total_chars)
    printf "\\n# Statistics for TS: '%s' #\\n" "$1"
    printf '#%.0s' $(seq $total_chars)
    printf "\\n\\n"
    ffprobe "$1" 2>&1 | grep -E -e "Program" -e "Stream" -e "service_name" -e "service_provider"
    printf "\\n"
}

case "$1" in
  -h|--help)
      display_help
      ;;
  -i|--input)
      case "$2" in
          *.ts|udp://*)
              if [[ "$2" == udp://* ]]; then
                  # Splitting the user input to mc_address containing the IP address and the port,
                  # IP address and the port and running checks if the IP and port are valid
                  mc_address="${2#udp://}"
                  ip_address=${mc_address%%:*}
                  port="${mc_address#*:*}"
                  check_ip_address "$ip_address"
                  check_port "$port"
                  ffprobe_print "$2"
              else
                  # Checks if the input file exists
                  if [[ -f "$2" ]]; then
                      ffprobe_print "$2"
                  else
                      file_not_existing "$2"
                  fi
            fi
            ;;
          *)
              display_ts_error
              ;;
              esac
              ;;
    *)
        display_error "$1"
        ;;
esac
