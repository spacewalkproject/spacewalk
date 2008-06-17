/* Do not edit: automatically built by gen_rec.awk. */

#ifndef	crdel_AUTO_H
#define	crdel_AUTO_H
#define	DB_crdel_fileopen	141
typedef struct _crdel_fileopen_args {
	u_int32_t type;
	DB_TXN *txnid;
	DB_LSN prev_lsn;
	DBT	name;
	u_int32_t	mode;
} __crdel_fileopen_args;

#define	DB_crdel_metasub	142
typedef struct _crdel_metasub_args {
	u_int32_t type;
	DB_TXN *txnid;
	DB_LSN prev_lsn;
	int32_t	fileid;
	db_pgno_t	pgno;
	DBT	page;
	DB_LSN	lsn;
} __crdel_metasub_args;

#define	DB_crdel_metapage	143
typedef struct _crdel_metapage_args {
	u_int32_t type;
	DB_TXN *txnid;
	DB_LSN prev_lsn;
	int32_t	fileid;
	DBT	name;
	db_pgno_t	pgno;
	DBT	page;
} __crdel_metapage_args;

#define	DB_crdel_old_delete	144
typedef struct _crdel_old_delete_args {
	u_int32_t type;
	DB_TXN *txnid;
	DB_LSN prev_lsn;
	DBT	name;
} __crdel_old_delete_args;

#define	DB_crdel_rename	145
typedef struct _crdel_rename_args {
	u_int32_t type;
	DB_TXN *txnid;
	DB_LSN prev_lsn;
	int32_t	fileid;
	DBT	name;
	DBT	newname;
} __crdel_rename_args;

#define	DB_crdel_delete	146
typedef struct _crdel_delete_args {
	u_int32_t type;
	DB_TXN *txnid;
	DB_LSN prev_lsn;
	int32_t	fileid;
	DBT	name;
} __crdel_delete_args;

#endif
