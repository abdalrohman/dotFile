#!/usr/bin/env bash
#-*- coding: utf-8 -*-
: '
@ File Name    :   findModule.sh
@ Created Time :   2021/06/02 6:26

Copyright (C) <2021>  <Abdulrahman Alnaseer>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
'

# Function to list unique kernel modules for all devices
list_unique_kernel_modules() {
    find /sys/ -name modalias -exec cat {} \; |
        while read -r line; do
            /sbin/modprobe --config /dev/null --show-depends "$line"
        done | awk -F'/' '{print $NF}' | sort -u
}

# Main function
main() {
    list_unique_kernel_modules
}

# Run the main function
main
