divert(-1)

dnl Okay, this is a bit odd.  Basically we have a 'calc space' mode.  If
dnl in that mode, squelch output, accumulate total space needed, and print
dnl that.  If not in that mode, print everything as usual.  divert() is
dnl really weird so this reads oddly; info m4 for details.

define(RHNORA_CREATELOG, RHNORA_LOG_PATH/create_$1.log)

define(RHNORA_TOTAL_SPACE, 0)

define(RHNORA_SPACE, $1`define(`RHNORA_TOTAL_SPACE', eval(RHNORA_TOTAL_SPACE + $1))')

ifdef(`RHNORA_CALC_SPACE',
`
  define(RHNORA_RENDER_OUTPUT,`divert(-1)undivert(1)divert(0)eval(RHNORA_TOTAL_SPACE)')
'
,
`
  define(RHNORA_RENDER_OUTPUT,`')
')

dnl leave diverstion at 1... used by above macros
divert(1)
