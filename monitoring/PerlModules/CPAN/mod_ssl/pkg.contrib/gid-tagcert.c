/*
**  gid-tagcert.c -- Tag a CA certificate inside Communicator certX.db
**                   database file for use with `Global Server ID'.
**
**  Originally written by Matthias Loepfe <Matthias.Loepfe@AdNovum.CH>
**  Cleaned up for mod_ssl by Ralf S. Engelschall, <rse@engelschall.com>
**
**  You need the old Berkeley-DB 1.85 library for compiling this program.
**  Fetch it from ftp://ftp.netsw.org/netsw/Database/Hashfile/Libs/
*/

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>

#if 0
#define __BIT_TYPES_DEFINED__
#define u_int8_t  uint8_t
#define u_int16_t uint16_t
#define u_int32_t uint32_t
#endif

#include "db.h"

int main(int argc, char **argv)
{
    DB       *dbp;
    DBT       key;
    DBT       data;
    u_int8_t *p;
    u_int8_t *dn;
    int       dnlen;
    int       offs;
    int       len;
    
    /*
     * Open the DB/1.85 format file
     */
    if ((dbp = dbopen(argv[1], O_RDWR, 0644, DB_HASH, NULL)) == NULL) {
        perror("dbopen");
        return 1;
    }

    /*
     * Retrieve the CA entry through the nickname
     */
    key.size = strlen(argv[2]) + 2;
    key.data = p = (u_int8_t*)malloc(key.size);
    p[0] = '\02';
    strcpy(&p[1], argv[2]);
    if (dbp->get(dbp, &key, &data, 0)) {
        perror("dbp->get");
        return 1;
    }
    
    /*
     * Determine the CA Distinguished Name (DN)
     */
    dn    = (u_int8_t*)data.data + 5;
    dnlen = data.size - 5;

    /*
     * Retrieve the CA data entry through the DN
     */
    key.size = dnlen + 1;
    key.data = p = (u_int8_t*)malloc(key.size);
    p[0] = '\03';
    memcpy(&p[1], dn, dnlen);
    if (dbp->get(dbp, &key, &data, 0)) {
        perror("dbp->get");
        return 1;
    }

    /*
     * Determine the CA database key
     */
    p    = data.data;
    offs = (p[5] << 8) + p[6] + 13;
    p   += offs;
    for (len = 0; memcmp(p + len, dn, dnlen); len++) ;
    p--;

    /*
     * Retrieve the CA entry through the database key
     */
    key.size = dnlen + len + 1;
    key.data = p;
    p[0]     = '\1';
    if (dbp->get(dbp, &key, &data, 0)) {
        perror("dbp->get");
        return 1;
    }
    p = data.data;
    
    /*
     * And check/change the GID-related trustflags
     */
    if ((p[3] == 0) && (p[4] == 0x18)) {
        p[3] = 0x02;
        p[4] = 0x38;
        if (dbp->put(dbp, &key, &data, 0)) {
            perror("dbp->put");
            return 1;
        }
        printf("Trustflags changed from 0x0018 to 0x0238\n");
    }
    else {
        printf("Trustflags unchanged 0x%02x%02x\n", p[3], p[4]);
    }

    /*
     * Close the database file
     */
    dbp->close(dbp);
    return 0;
}
