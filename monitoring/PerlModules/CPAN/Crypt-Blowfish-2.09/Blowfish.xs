/*
 *	Copyright (C) 1995, 1996 Systemics Ltd (http://www.systemics.com/)
 *
 *      Code Modfifications Copyright (C) 2000 W3Works, LLC (http://www.w3works.co/)
 *	All rights reserved.
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "blowfish.h"

/*  thanks to LDS */
#ifndef sv_undef
#define sv_undef PL_sv_undef
#endif

MODULE = Crypt::Blowfish		PACKAGE = Crypt::Blowfish		PREFIX = blowfish_

PROTOTYPES: DISABLE

 
char *
blowfish_init(key)
	unsigned char *	key = NO_INIT
	STRLEN	key_len = NO_INIT
    CODE:
	{
		/*
		* What should this length be???
		*/
		char ks[8192];

		key = (unsigned char *) SvPV(ST(0), key_len);
		if (key_len < 8 || key_len > 56)
			croak("Invalid length key");

		if (blowfish_make_bfkey(key, key_len, ks))
			croak("Error creating key schedule");

		ST(0) = sv_2mortal(newSVpv(ks, sizeof(ks)));
	}

void
blowfish_crypt(input, output, ks, dir)
	char *	input = NO_INIT
	SV *	output
	char *	ks = NO_INIT
	STRLEN	input_len = NO_INIT
	STRLEN	output_len = NO_INIT
	STRLEN	ks_len = NO_INIT
	int		dir
	CODE:
	{
		input = (char *) SvPV(ST(0), input_len);
		if (input_len != 8)
			croak("input must be 8 bytes long");

		ks = (char *) SvPV(ST(2), ks_len);

		if (output == &sv_undef)
			output = sv_newmortal();
		output_len = 8;

		if (!SvUPGRADE(output, SVt_PV))
			croak("cannot use output argument as lvalue");

		/* blowfish_crypt_8bytes(input, SvGROW(output, 8), ks, dir); */
		/* HP-UX (HP cc) fix below, thanks Addi! */
		blowfish_crypt_8bytes( (unsigned char*)input, (unsigned char*)SvGROW(output, 8), ks, (short)dir);

		SvCUR_set(output, output_len);
		*SvEND(output) = '\0';
		(void) SvPOK_only(output);
		SvTAINT(output);

		ST(0) = output;
	}
