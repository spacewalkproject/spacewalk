/* Do not edit: automatically built by gen_rec.awk. */

#ifndef	qam_AUTO_H
#define	qam_AUTO_H
#define	DB_qam_inc	76
typedef struct _qam_inc_args {
	u_int32_t type;
	DB_TXN *txnid;
	DB_LSN prev_lsn;
	int32_t	fileid;
	DB_LSN	lsn;
} __qam_inc_args;

#define	DB_qam_incfirst	77
typedef struct _qam_incfirst_args {
	u_int32_t type;
	DB_TXN *txnid;
	DB_LSN prev_lsn;
	int32_t	fileid;
	db_recno_t	recno;
} __qam_incfirst_args;

#define	DB_qam_mvptr	78
typedef struct _qam_mvptr_args {
	u_int32_t type;
	DB_TXN *txnid;
	DB_LSN prev_lsn;
	u_int32_t	opcode;
	int32_t	fileid;
	db_recno_t	old_first;
	db_recno_t	new_first;
	db_recno_t	old_cur;
	db_recno_t	new_cur;
	DB_LSN	metalsn;
} __qam_mvptr_args;

#define	DB_qam_del	79
typedef struct _qam_del_args {
	u_int32_t type;
	DB_TXN *txnid;
	DB_LSN prev_lsn;
	int32_t	fileid;
	DB_LSN	lsn;
	db_pgno_t	pgno;
	u_int32_t	indx;
	db_recno_t	recno;
} __qam_del_args;

#define	DB_qam_add	80
typedef struct _qam_add_args {
	u_int32_t type;
	DB_TXN *txnid;
	DB_LSN prev_lsn;
	int32_t	fileid;
	DB_LSN	lsn;
	db_pgno_t	pgno;
	u_int32_t	indx;
	db_recno_t	recno;
	DBT	data;
	u_int32_t	vflag;
	DBT	olddata;
} __qam_add_args;

#define	DB_qam_delete	81
typedef struct _qam_delete_args {
	u_int32_t type;
	DB_TXN *txnid;
	DB_LSN prev_lsn;
	DBT	name;
	DB_LSN	lsn;
} __qam_delete_args;

#define	DB_qam_rename	82
typedef struct _qam_rename_args {
	u_int32_t type;
	DB_TXN *txnid;
	DB_LSN prev_lsn;
	DBT	name;
	DBT	newname;
} __qam_rename_args;

#define	DB_qam_delext	83
typedef struct _qam_delext_args {
	u_int32_t type;
	DB_TXN *txnid;
	DB_LSN prev_lsn;
	int32_t	fileid;
	DB_LSN	lsn;
	db_pgno_t	pgno;
	u_int32_t	indx;
	db_recno_t	recno;
	DBT	data;
} __qam_delext_args;

#endif
