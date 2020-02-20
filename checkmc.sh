#!/bin/bash


# This script prints all MPEG-2 TS multicast traffic present on the input network interface
# It uses tcpdump and and requires to be executes from an user with existing sudo rights

# Defining the timeout for the tcp command
time_out=30
#########################
# The command line help #
#########################

display_help() {
    printf "Prints all available MPEG-2 TS multicasts on the defined interface.\\n\\n"
    printf "Usage: %s -i <IFNAME>\\n\\n" "$0"
    printf "   -i, --input                input network interface which is receiving the streams\\n"
    printf "   -h, --help                 show the help for this program\\n"
    exit 1
}

display_usage() {
    printf "Usage: %s -i <IFNAME>\\n" "$0"
    printf "Help: %s -h\\n" "$0"
}

display_error() {
    printf "Unrecognized option '%s'.\\n\\n" "$1"
    display_usage
    exit 1
}

#############################
# Program related functions #
#############################

################################################################
# Function checking if the inserted network interface is valid #
################################################################
ifname_check() {
    # Creating an array containing all network interfaces which are up
    net_array=()
    for iface in $(ifconfig | cut -d ' ' -f1| tr ':' '\n' | awk NF)
    do
        net_array+=("$iface")
    done
    unset "net_array[${#net_array[@]}-1]"

    # Checking if the inserted network interface is valid
    if ! [[ "${net_array[*]}" =~ (^| )"$1"( |$) ]]; then 
        printf "The inserted network interface '%s' is not valid!\\n" "$1"
        printf "Valid network interfaces: %s\\n\\n" "${net_array[*]}"
        display_usage
        exit 1
    fi
}

#####################################################################
# Executing the tcpdump command and printing the multicast addresses #
######################################################################
tcpdump_cmd() {
    # Finding out how many characters is the length of the <IFNAME>
    inp_chars=${#1}
    total_chars=$((inp_chars + 55))
    # Printing 55 + IFNAME characters length number of '#'
    printf '#%.0s' $(seq $total_chars)
    printf "\\n# List of multicasts present on network interface: '%s' #\\n" "$1"
    printf '#%.0s' $(seq $total_chars)
    printf "\\n\\n"
    # Please uncomment the below line and comment the line after if you want to show the tcpdump statistics
    # sudo tcpdump -nn -v -q -i "$1" -c 1000 multicast and udp and greater 1344 | sort | uniq | grep '>' 
    sudo timeout "$time_out" tcpdump -nn -v -q -i "$1" -c 1000 multicast and udp and greater 1344 2>/dev/null | sort | uniq | grep '>' 
}

################
# Main Program #
################

case "$1" in
    -h|--help)
        display_help
        ;;
    -i|--input)
        ifname_check "$2"
        tcpdump_cmd "$2"
        exit 1
        ;;
    *)
        display_error "$1"
        exit 1
        ;;
esac
