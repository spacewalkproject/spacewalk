typedef unsigned char des_user_key[8];
typedef unsigned char des_cblock[8];
typedef unsigned long des_ks[32];

void des_crypt( des_cblock in, des_cblock out, des_ks key, int encrypt );
void des_expand_key( des_user_key userKey, des_ks key );

