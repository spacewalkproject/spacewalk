#include <sys/types.h>

typedef unsigned char bf_cblock[8];

int blowfish_make_bfkey(char * key_string, int keylength, char * bfkey);
void blowfish_crypt_8bytes(bf_cblock source, bf_cblock dest, char * bfkey, short direction);
