# dvb_scripts
## Sripts Description
### checkmc.sh
The `checkmc.sh` script prints a list of all the unique multicast MPEG-2 TS streams present on the specified input network interface. It uses `tcpdump` and that is why it requires to be run from a user with `sudo` rights. 
<p>The `time_out` variable defined at the beginning defines the timeout after which the script will finish listening on the interface. Useful if you don't have any multicast traffic on the port, so you don't need to kill the script
The `packets_number` variables defines after how many packets the script to stop listening on the interface. 1000 is a relatively safe value and should not slow down the script, but feel free to experiment with different values. 

**Usage:**

```
Usage: /home/gstoyanov/scripts/dvb/checkmc.sh -i <IFNAME>
Help: /home/gstoyanov/scripts/dvb/checkmc.sh -h
```

**Example Output:**

```
###########################################################
# List of multicasts present on network interface: 'eno1' #
###########################################################

  10.120.160.144.49152 > 232.48.11.16.2000: UDP, length 1316
  10.120.244.103.4000 > 232.0.55.4.4000: UDP, length 1316
  10.120.246.67.49162 > 232.0.56.3.4000: UDP, length 1316
```

As you can see from the example in my case all of my present multicasts are SSM (source specific multicasts). You can use `smcroutectl join <IFNAME> <Source_IP> <Multicast_IP>` to join the source specific multicast. More information of working with multicasts you can find in this [wiki page][wiki].</p>
### probemc.sh 
The `probemc.sh` script prints all the existing programs and streams in a UDP MPEG-2 TS multicast. It requires `ffprobe`, so make sure you have `ffmpeg` installed before running this script. 

**Usage:**

```
Usage: probemc.sh -i <input_ts_file>
Usage: probemc.sh -i udp://{IP-Address}:{Port}

   -i, --input                input file for analysis, it could be recorded TS file or live stream
   -h, --help                  show the help for this program
```

__Example Output:__

```
##############################################
# Statistics for TS: 'udp://232.0.55.4:4000' #
##############################################

  Program 5400
      service_name    : Example TV HD
      service_provider: NoProvider
    Stream #0:4[0x20](deu): Subtitle: dvb_teletext ([6][0][0][0] / 0x0006), 492x250
    Stream #0:6[0xff]: Video: h264 ([27][0][0][0] / 0x001B), none, 50 fps, 50 tbr, 90k tbn
    Stream #0:8[0x103](deu): Audio: ac3 ([6][0][0][0] / 0x0006), 48000 Hz, stereo, fltp, 256 kb/s (clean effects)
    Stream #0:9[0x105]: Unknown: none ([5][0][0][0] / 0x0005)
    Stream #0:10[0x106]: Unknown: none ([11][0][0][0] / 0x000B)
  Program 5401
      service_name    : Example 2 TV HD
      service_provider: NoProvider
    Stream #0:14[0x21](deu): Subtitle: dvb_teletext ([6][0][0][0] / 0x0006)
    Stream #0:18[0x31]: Data: scte_35 (CUEI / 0x49455543)
    Stream #0:11[0x1ff]: Video: h264 (High) ([27][0][0][0] / 0x001B), yuv420p(tv, bt709, top first), 1440x1080 [SAR 4:3 DAR 16:9], 25 fps, 50 tbr, 90k tbn, 50 tbc
    Stream #0:15[0x203](deu): Audio: ac3 ([6][0][0][0] / 0x0006), 48000 Hz, stereo, fltp, 384 kb/s (clean effects)
    Stream #0:19[0x205]: Unknown: none ([5][0][0][0] / 0x0005)
```

[wiki]:https://github.com/stoyanovgeorge/ffmpeg/wiki/Work-with-MPEG-2-TS-Multicasts
