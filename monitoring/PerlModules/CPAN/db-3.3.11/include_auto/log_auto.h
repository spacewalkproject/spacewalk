/* Do not edit: automatically built by gen_rec.awk. */

#ifndef	log_AUTO_H
#define	log_AUTO_H
#define	DB_log_register1	1
typedef struct _log_register1_args {
	u_int32_t type;
	DB_TXN *txnid;
	DB_LSN prev_lsn;
	u_int32_t	opcode;
	DBT	name;
	DBT	uid;
	int32_t	fileid;
	DBTYPE	ftype;
} __log_register1_args;

#define	DB_log_register	2
typedef struct _log_register_args {
	u_int32_t type;
	DB_TXN *txnid;
	DB_LSN prev_lsn;
	u_int32_t	opcode;
	DBT	name;
	DBT	uid;
	int32_t	fileid;
	DBTYPE	ftype;
	db_pgno_t	meta_pgno;
} __log_register_args;

#endif
