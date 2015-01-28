/*

 Copyright (c) 2004 Conectiva, Inc.

 Written by Gustavo Niemeyer <niemeyer@conectiva.com>

 This file is part of Smart Package Manager.

 Smart Package Manager is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License as published
 by the Free Software Foundation; either version 2 of the License, or (at
 your option) any later version.

 Smart Package Manager is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Smart Package Manager; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
#include <pwd.h>

int main(int argc, char *argv[], char *envp[])
{
    char *const smart_argv[] = {"/usr/bin/smart", "update", NULL, NULL};
    char *const smart_envp[] = {"PATH=/bin:/usr/bin", "HOME=", NULL};
    struct passwd *pwd = getpwuid(geteuid());
    if (!pwd) {
        fprintf(stderr, "error: Unable to find passwd entry for uid %d\n",
                geteuid());
        exit(1);
    }
    if (asprintf(&smart_envp[1], "HOME=%s", pwd->pw_dir) == -1) {
        fprintf(stderr, "error: Unable to create HOME environment variable\n");
        exit(1);
    }
    if (argc == 3 && strcmp(argv[1], "--after") == 0) {
        if (asprintf(&smart_argv[2], "--after=%d", atoi(argv[2])) == -1) {
            fprintf(stderr, "error: Unable to create argument variable\n");
            exit(1);
        }
    }
    setreuid(pwd->pw_uid, pwd->pw_uid);
    setregid(pwd->pw_gid, pwd->pw_gid);
    execve(smart_argv[0], smart_argv, smart_envp);
    perror("error: Unable to execute smart");
    return 1;
}
