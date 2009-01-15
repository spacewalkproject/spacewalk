#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation. 
#
#include <iconv.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int mem_usage(int *vmsize, int *vmrss, int *vmdata)
{
    FILE *f;
    char buf[1024];
    char *retc;
    f = fopen("/proc/self/status", "r");
    if (f == NULL) {
        return -1;
    }
    *vmsize = 0;
    *vmrss = 0;
    *vmdata = 0;
    while (1) {
        int i;
        const char *strnames[] = {"VmSize:", "VmRSS:", "VmData:"};
        int *results[] = {vmsize, vmrss, vmdata};
        retc = fgets(buf, sizeof(buf), f);
        if (retc == NULL) {
            // End of file
            fclose(f);
            return 0;
        }
        for (i = 0; i < 3; i++) {
            char tmpbuf[1024];
            int slen = strlen(strnames[i]);
            memcpy(tmpbuf, buf, slen);
            tmpbuf[slen] = 0;
            if (!strcmp(strnames[i], tmpbuf)) {
                *(results[i]) = strtol(buf + slen, &retc, 10);
                break;
            }
        }
    }
    return 0;
}

int print_mem_usage(run)
{
    int vmsize;
    int vmrss;
    int vmdata;
    int ret;
    ret = mem_usage(&vmsize, &vmrss, &vmdata);
    if (ret < 0) {
        return ret;
    }
    printf("Run: %-5d; vmsize: %d; vmrss: %d; vmdata: %d\n", run, vmsize, vmrss,
        vmdata);
    return 0;
}

int main(int argc, const char *argv[])
{
    int times;
    char *endptr;
    char *fromcode = "iso-8859-1";
    char *tocode = "utf-8";
    int i;
    iconv_t cd;
    if (argc != 2) {
        printf("Usage: %s <count>\n", argv[0]);
        return 1;
    }
    times = strtol(argv[1], &endptr, 10);
    for (i = 0; i < times; i++)
    {
        if (! (i % 1000)) {
            print_mem_usage(i);
        }
        cd = iconv_open(tocode, fromcode);
        if (cd < 0) {
            printf("Error creating context\n");
            return 1;
        }
        iconv_close(cd);
    }
    return 0;
}
