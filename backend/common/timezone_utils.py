"""
Copyright (C) 2017 Oracle and/or its affiliates. All rights reserved.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation, version 2


This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
02110-1301, USA.

Utility to get system UTC offset and format as needed by DBs.
"""
import time


def get_utc_offset():
    """Return the UTC offset, allowing for DST."""
    is_dst = time.daylight and time.localtime().tm_isdst > 0
    utc_offset = - time.timezone
    if is_dst:
        utc_offset = - time.altzone
    mins = divmod(utc_offset, 60)[0]
    hours, mins = divmod(mins, 60)
    return '{0:+03d}:{1:02d}'.format(hours, mins)


if __name__ == "__main__":
    print "UTC offset (allowing for DST if in effect): %s" % get_utc_offset()
