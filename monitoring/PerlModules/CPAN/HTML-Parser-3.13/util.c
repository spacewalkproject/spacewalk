/* $Id: util.c,v 1.1 2000-10-13 20:26:51 dfaraldo Exp $
 *
 * Copyright 1999-2000, Gisle Aas.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the same terms as Perl itself.
 */

#ifndef EXTERN
#define EXTERN extern
#endif


EXTERN SV*
sv_lower(SV* sv)
{
   STRLEN len;
   char *s = SvPV_force(sv, len);
   for (; len--; s++)
	*s = toLOWER(*s);
   return sv;
}

EXTERN SV*
decode_entities(SV* sv, HV* entity2char)
{
  STRLEN len;
  char *s = SvPV_force(sv, len);
  char *t = s;
  char *end = s + len;
  char *ent_start;

  char *repl;
  STRLEN repl_len;
#ifdef UNICODE_ENTITIES
  char buf[UTF8_MAXLEN];
  int has_utf8 = 0;
  int repl_utf8;
#else
  char buf[1];
#endif
  

  while (s < end) {
    assert(t <= s);

    if ((*t++ = *s++) != '&')
      continue;

    ent_start = s;
    repl = 0;

    if (*s == '#') {
      UV num = 0;
      UV prev = 0;
      int ok = 0;
      s++;
      if (*s == 'x' || *s == 'X') {
	char *tmp;
	s++;
	while (*s) {
	  char *tmp = strchr(PL_hexdigit, *s);
	  if (!tmp)
	    break;
	  num = num << 4 | ((tmp - PL_hexdigit) & 15);
	  if (prev && num <= prev) {
	      /* overflow */
	      ok = 0;
	      break;
	  }
	  prev = num;
	  s++;
	  ok = 1;
	}
      }
      else {
	while (isDIGIT(*s)) {
	  num = num * 10 + (*s - '0');
	  if (prev && num < prev) {
	      /* overflow */
	      ok = 0;
	      break;
	  }
	  prev = num;
	  s++;
	  ok = 1;
	}
      }
      if (ok) {
#ifdef UNICODE_ENTITIES
	if (!SvUTF8(sv) && num <= 255) {
	  buf[0] = num;
	  repl = buf;
	  repl_len = 1;
	  repl_utf8 = 0;
	}
	else {
	  char *tmp = uv_to_utf8(buf, num);
	  repl = buf;
	  repl_len = tmp - buf;
	  repl_utf8 = 1;
	}
#else
	if (num <= 255) {
	  buf[0] = num & 0xFF;
	  repl = buf;
	  repl_len = 1;
	}
#endif
      }
    }
    else {
      char *ent_name = s;
      while (isALNUM(*s))
	s++;
      if (ent_name != s && entity2char) {
	SV** svp = hv_fetch(entity2char, ent_name, s - ent_name, 0);
	if (svp) {
	  repl = SvPV(*svp, repl_len);
#ifdef UNICODE_ENTITIES
	  repl_utf8 = SvUTF8(*svp);
#endif
	}
      }
    }

    if (repl) {
      if (*s == ';')
	s++;
      t--;  /* '&' already copied, undo it */

#ifdef UNICODE_ENTITIES
      if (!SvUTF8(sv) && repl_utf8) {
	  /* need to upgrade */
	  int old_len = t - SvPVX(sv);
	  int len = old_len;
	  char *ustr = bytes_to_utf8(SvPVX(sv), &len);
	  int grow = len - old_len;
	  if (grow) {
	      int entity_len = s - t;
	      SvGROW(sv, SvCUR(sv) + grow + 1);
	      s = SvPVX(sv) + old_len + entity_len;
	      Move(s, s+grow, SvEND(sv) - s + 1, char);
	      s += grow;
	      Copy(ustr, SvPVX(sv), len, char);
	      t = SvPVX(sv) + len;
	  }
	  Safefree(ustr);
	  SvUTF8_on(sv);
      }
#endif

      if (t + repl_len > s) {
	/* need to grow the string */
	STRLEN t_offset = t - SvPVX(sv);
	STRLEN s_offset = s - SvPVX(sv);
	int grow = repl_len - (s - t);
	SvGROW(sv, SvCUR(sv) + grow + 1);
	t = SvPVX(sv) + t_offset;
	s = SvPVX(sv) + s_offset;
	Move(s, s+grow, SvEND(sv) - s + 1, char);
	s += grow;
      }

      /* copy replacement string into string */
      while (repl_len--)
	*t++ = *repl++;
    }
    else {
      while (ent_start < s)
	*t++ = *ent_start++;
    }
  }

  if (t != s) {
    *t = '\0';
    SvCUR_set(sv, t - SvPVX(sv));
  }
  return sv;
}
