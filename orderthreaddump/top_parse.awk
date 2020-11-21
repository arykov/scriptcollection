# top_parse.awk
#
# USAGE:    awk -f top_parse.awk top.out > top_parse.out
#               where top.out is the output of something like "top -d999 -s120".
#
#           Before running this script, edit the first few lines of this script to give
#           it the desired PIDs to search for.
#
#
# PURPOSE:  Parses the output of something like "top -d999 -s120" (which runs 999 iterations
#           of "top" at 120-second itervals) to generate a tabulated CPU usage
#           for a given list of PIDs (up to two PIDs).
#
#           Of course, tools like HP OpenView can do a great job.  But often times that kind of
#           tools are not installed (or controlled by you) on the particular UNIX machine
#           you want to monitor.  This script works around that limitation.
#
#           Sample output:
#
#                time        CPU:idle    CPU:user    CPU:kernel  CPU:pid=11905   CPU:pid=15449
#                15:53:36         0.4        81.0        18.2        23.4        28.2
#                15:55:36         0.1        79.7        20.0        24.5        26.0
#                15:57:37         0.0        80.4        19.5        24.6        26.1
#                15:59:37         0.4        78.9        20.6        24.9        24.2
#                16:01:37         0.5        78.1        21.2        17.7        18.3
#
#           The columns in the output is separated by tabs, and therefore can be readily imported into
#           Microsoft Excel with Excel's default import settings.  From there, you can easily graph it.
#
#
# AUTHOR:   Vincent Yin, Jan 2005


BEGIN {
    # Edit the following lines to specify the UNIX process IDs for which you'd like to tabulate
    # by this script.  If you only have one pid,then assign 0 (or any other non-existent pid) to PID2.
    PID1=22080
    PID2=0

    # ........................ No change necessary below this line .........................
    FS="[ \t%]+"
    printf ("time    \tCPU:idle\tCPU:user\tCPU:kernel\tCPU:pid=%s\tCPU:pid=%s", PID1, PID2)

    reset()
    LINE_NUM=0
}

function reset() {
    TIME        = ""
    CPU_idle    = -1
    CPU_user    = -1
    CPU_kernel  = -1
    CPU_PID1    = -1
    CPU_PID2    = -1

}

{
    if ($1 == "last" && $2 == "pid:") {
        LINE_NUM++
        if (LINE_NUM > 1) {
            # We cannot reliably detect the end of each "top" iteration because the PID
            # we look for may not be in each iteration.  But we can reliably detect
            # the beginning of each iteration by the substring "last pid:".  So, we
            # print the values at this point -- note that not all variables to be printed
            # are necessarily non-negative because we have no guarantee that all PIDs were
            # collected in the previous "top" iteration.
            printf("\n%s\t%8.1f\t%8.1f\t%8.1f\t%8.2f\t%8.2f", TIME, CPU_idle, CPU_user, CPU_kernel, CPU_PID1, CPU_PID2)
        }

        reset()
        TIME = $NF
    }

    if ($1 == "CPU" && $2 == "states:") {
        CPU_idle    = $3
        CPU_user    = $5
        CPU_kernel  = $7
    }

    if ($1 == PID1 || $2 == PID1) { # If there's a leading blank, then the field might be $2 not $1.
        CPU_PID1=$11
    }

    if ($1 == PID2 || $2 == PID2) { # If there's a leading blank, then the field might be $2 not $1.
        CPU_PID2=$11
    }

}

END {
    printf("\n")
}