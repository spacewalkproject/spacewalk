/* Do not edit: automatically built by gen_rpc.awk. */
#include "db_config.h"

#ifndef NO_SYSTEM_INCLUDES
#include <sys/types.h>

#include <rpc/rpc.h>
#include <rpc/xdr.h>

#include <string.h>
#endif
#include "db_server.h"

#include "db_int.h"
#include "db_server_int.h"
#include "rpc_server_ext.h"

/*
 * PUBLIC: __env_cachesize_reply *__db_env_cachesize_3003 
 * PUBLIC:     __P((__env_cachesize_msg *));
 */
__env_cachesize_reply *
__db_env_cachesize_3003(req)
	__env_cachesize_msg *req;
{
	static __env_cachesize_reply reply; /* must be static */

	__env_cachesize_proc(req->dbenvcl_id,
	    req->gbytes,
	    req->bytes,
	    req->ncache,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __env_close_reply *__db_env_close_3003 __P((__env_close_msg *));
 */
__env_close_reply *
__db_env_close_3003(req)
	__env_close_msg *req;
{
	static __env_close_reply reply; /* must be static */

	__env_close_proc(req->dbenvcl_id,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __env_create_reply *__db_env_create_3003 __P((__env_create_msg *));
 */
__env_create_reply *
__db_env_create_3003(req)
	__env_create_msg *req;
{
	static __env_create_reply reply; /* must be static */

	__env_create_proc(req->timeout,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __env_flags_reply *__db_env_flags_3003 __P((__env_flags_msg *));
 */
__env_flags_reply *
__db_env_flags_3003(req)
	__env_flags_msg *req;
{
	static __env_flags_reply reply; /* must be static */

	__env_flags_proc(req->dbenvcl_id,
	    req->flags,
	    req->onoff,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __env_open_reply *__db_env_open_3003 __P((__env_open_msg *));
 */
__env_open_reply *
__db_env_open_3003(req)
	__env_open_msg *req;
{
	static __env_open_reply reply; /* must be static */

	__env_open_proc(req->dbenvcl_id,
	    (*req->home == '\0') ? NULL : req->home,
	    req->flags,
	    req->mode,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __env_remove_reply *__db_env_remove_3003 __P((__env_remove_msg *));
 */
__env_remove_reply *
__db_env_remove_3003(req)
	__env_remove_msg *req;
{
	static __env_remove_reply reply; /* must be static */

	__env_remove_proc(req->dbenvcl_id,
	    (*req->home == '\0') ? NULL : req->home,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __txn_abort_reply *__db_txn_abort_3003 __P((__txn_abort_msg *));
 */
__txn_abort_reply *
__db_txn_abort_3003(req)
	__txn_abort_msg *req;
{
	static __txn_abort_reply reply; /* must be static */

	__txn_abort_proc(req->txnpcl_id,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __txn_begin_reply *__db_txn_begin_3003 __P((__txn_begin_msg *));
 */
__txn_begin_reply *
__db_txn_begin_3003(req)
	__txn_begin_msg *req;
{
	static __txn_begin_reply reply; /* must be static */

	__txn_begin_proc(req->dbenvcl_id,
	    req->parentcl_id,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __txn_commit_reply *__db_txn_commit_3003 __P((__txn_commit_msg *));
 */
__txn_commit_reply *
__db_txn_commit_3003(req)
	__txn_commit_msg *req;
{
	static __txn_commit_reply reply; /* must be static */

	__txn_commit_proc(req->txnpcl_id,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __txn_discard_reply *__db_txn_discard_3003 
 * PUBLIC:     __P((__txn_discard_msg *));
 */
__txn_discard_reply *
__db_txn_discard_3003(req)
	__txn_discard_msg *req;
{
	static __txn_discard_reply reply; /* must be static */

	__txn_discard_proc(req->txnpcl_id,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __txn_prepare_reply *__db_txn_prepare_3003 
 * PUBLIC:     __P((__txn_prepare_msg *));
 */
__txn_prepare_reply *
__db_txn_prepare_3003(req)
	__txn_prepare_msg *req;
{
	static __txn_prepare_reply reply; /* must be static */

	__txn_prepare_proc(req->txnpcl_id,
	    req->gid,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __txn_recover_reply *__db_txn_recover_3003 
 * PUBLIC:     __P((__txn_recover_msg *));
 */
__txn_recover_reply *
__db_txn_recover_3003(req)
	__txn_recover_msg *req;
{
	static __txn_recover_reply reply; /* must be static */
	static int __txn_recover_free = 0; /* must be static */

	if (__txn_recover_free)
		xdr_free((xdrproc_t)xdr___txn_recover_reply, (void *)&reply);
	__txn_recover_free = 0;

	/* Reinitialize allocated fields */
	reply.txn.txn_val = NULL;
	reply.gid.gid_val = NULL;

	__txn_recover_proc(req->dbenvcl_id,
	    req->count,
	    req->flags,
	    &reply,
	    &__txn_recover_free);
	return (&reply);
}

/*
 * PUBLIC: __db_associate_reply *__db_db_associate_3003 
 * PUBLIC:     __P((__db_associate_msg *));
 */
__db_associate_reply *
__db_db_associate_3003(req)
	__db_associate_msg *req;
{
	static __db_associate_reply reply; /* must be static */

	__db_associate_proc(req->dbpcl_id,
	    req->sdbpcl_id,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_bt_maxkey_reply *__db_db_bt_maxkey_3003 
 * PUBLIC:     __P((__db_bt_maxkey_msg *));
 */
__db_bt_maxkey_reply *
__db_db_bt_maxkey_3003(req)
	__db_bt_maxkey_msg *req;
{
	static __db_bt_maxkey_reply reply; /* must be static */

	__db_bt_maxkey_proc(req->dbpcl_id,
	    req->maxkey,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_bt_minkey_reply *__db_db_bt_minkey_3003 
 * PUBLIC:     __P((__db_bt_minkey_msg *));
 */
__db_bt_minkey_reply *
__db_db_bt_minkey_3003(req)
	__db_bt_minkey_msg *req;
{
	static __db_bt_minkey_reply reply; /* must be static */

	__db_bt_minkey_proc(req->dbpcl_id,
	    req->minkey,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_close_reply *__db_db_close_3003 __P((__db_close_msg *));
 */
__db_close_reply *
__db_db_close_3003(req)
	__db_close_msg *req;
{
	static __db_close_reply reply; /* must be static */

	__db_close_proc(req->dbpcl_id,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_create_reply *__db_db_create_3003 __P((__db_create_msg *));
 */
__db_create_reply *
__db_db_create_3003(req)
	__db_create_msg *req;
{
	static __db_create_reply reply; /* must be static */

	__db_create_proc(req->dbenvcl_id,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_del_reply *__db_db_del_3003 __P((__db_del_msg *));
 */
__db_del_reply *
__db_db_del_3003(req)
	__db_del_msg *req;
{
	static __db_del_reply reply; /* must be static */

	__db_del_proc(req->dbpcl_id,
	    req->txnpcl_id,
	    req->keydlen,
	    req->keydoff,
	    req->keyulen,
	    req->keyflags,
	    req->keydata.keydata_val,
	    req->keydata.keydata_len,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_extentsize_reply *__db_db_extentsize_3003 
 * PUBLIC:     __P((__db_extentsize_msg *));
 */
__db_extentsize_reply *
__db_db_extentsize_3003(req)
	__db_extentsize_msg *req;
{
	static __db_extentsize_reply reply; /* must be static */

	__db_extentsize_proc(req->dbpcl_id,
	    req->extentsize,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_flags_reply *__db_db_flags_3003 __P((__db_flags_msg *));
 */
__db_flags_reply *
__db_db_flags_3003(req)
	__db_flags_msg *req;
{
	static __db_flags_reply reply; /* must be static */

	__db_flags_proc(req->dbpcl_id,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_get_reply *__db_db_get_3003 __P((__db_get_msg *));
 */
__db_get_reply *
__db_db_get_3003(req)
	__db_get_msg *req;
{
	static __db_get_reply reply; /* must be static */
	static int __db_get_free = 0; /* must be static */

	if (__db_get_free)
		xdr_free((xdrproc_t)xdr___db_get_reply, (void *)&reply);
	__db_get_free = 0;

	/* Reinitialize allocated fields */
	reply.keydata.keydata_val = NULL;
	reply.datadata.datadata_val = NULL;

	__db_get_proc(req->dbpcl_id,
	    req->txnpcl_id,
	    req->keydlen,
	    req->keydoff,
	    req->keyulen,
	    req->keyflags,
	    req->keydata.keydata_val,
	    req->keydata.keydata_len,
	    req->datadlen,
	    req->datadoff,
	    req->dataulen,
	    req->dataflags,
	    req->datadata.datadata_val,
	    req->datadata.datadata_len,
	    req->flags,
	    &reply,
	    &__db_get_free);
	return (&reply);
}

/*
 * PUBLIC: __db_h_ffactor_reply *__db_db_h_ffactor_3003 
 * PUBLIC:     __P((__db_h_ffactor_msg *));
 */
__db_h_ffactor_reply *
__db_db_h_ffactor_3003(req)
	__db_h_ffactor_msg *req;
{
	static __db_h_ffactor_reply reply; /* must be static */

	__db_h_ffactor_proc(req->dbpcl_id,
	    req->ffactor,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_h_nelem_reply *__db_db_h_nelem_3003 __P((__db_h_nelem_msg *));
 */
__db_h_nelem_reply *
__db_db_h_nelem_3003(req)
	__db_h_nelem_msg *req;
{
	static __db_h_nelem_reply reply; /* must be static */

	__db_h_nelem_proc(req->dbpcl_id,
	    req->nelem,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_key_range_reply *__db_db_key_range_3003 
 * PUBLIC:     __P((__db_key_range_msg *));
 */
__db_key_range_reply *
__db_db_key_range_3003(req)
	__db_key_range_msg *req;
{
	static __db_key_range_reply reply; /* must be static */

	__db_key_range_proc(req->dbpcl_id,
	    req->txnpcl_id,
	    req->keydlen,
	    req->keydoff,
	    req->keyulen,
	    req->keyflags,
	    req->keydata.keydata_val,
	    req->keydata.keydata_len,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_lorder_reply *__db_db_lorder_3003 __P((__db_lorder_msg *));
 */
__db_lorder_reply *
__db_db_lorder_3003(req)
	__db_lorder_msg *req;
{
	static __db_lorder_reply reply; /* must be static */

	__db_lorder_proc(req->dbpcl_id,
	    req->lorder,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_open_reply *__db_db_open_3003 __P((__db_open_msg *));
 */
__db_open_reply *
__db_db_open_3003(req)
	__db_open_msg *req;
{
	static __db_open_reply reply; /* must be static */

	__db_open_proc(req->dbpcl_id,
	    (*req->name == '\0') ? NULL : req->name,
	    (*req->subdb == '\0') ? NULL : req->subdb,
	    req->type,
	    req->flags,
	    req->mode,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_pagesize_reply *__db_db_pagesize_3003 
 * PUBLIC:     __P((__db_pagesize_msg *));
 */
__db_pagesize_reply *
__db_db_pagesize_3003(req)
	__db_pagesize_msg *req;
{
	static __db_pagesize_reply reply; /* must be static */

	__db_pagesize_proc(req->dbpcl_id,
	    req->pagesize,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_pget_reply *__db_db_pget_3003 __P((__db_pget_msg *));
 */
__db_pget_reply *
__db_db_pget_3003(req)
	__db_pget_msg *req;
{
	static __db_pget_reply reply; /* must be static */
	static int __db_pget_free = 0; /* must be static */

	if (__db_pget_free)
		xdr_free((xdrproc_t)xdr___db_pget_reply, (void *)&reply);
	__db_pget_free = 0;

	/* Reinitialize allocated fields */
	reply.skeydata.skeydata_val = NULL;
	reply.pkeydata.pkeydata_val = NULL;
	reply.datadata.datadata_val = NULL;

	__db_pget_proc(req->dbpcl_id,
	    req->txnpcl_id,
	    req->skeydlen,
	    req->skeydoff,
	    req->skeyulen,
	    req->skeyflags,
	    req->skeydata.skeydata_val,
	    req->skeydata.skeydata_len,
	    req->pkeydlen,
	    req->pkeydoff,
	    req->pkeyulen,
	    req->pkeyflags,
	    req->pkeydata.pkeydata_val,
	    req->pkeydata.pkeydata_len,
	    req->datadlen,
	    req->datadoff,
	    req->dataulen,
	    req->dataflags,
	    req->datadata.datadata_val,
	    req->datadata.datadata_len,
	    req->flags,
	    &reply,
	    &__db_pget_free);
	return (&reply);
}

/*
 * PUBLIC: __db_put_reply *__db_db_put_3003 __P((__db_put_msg *));
 */
__db_put_reply *
__db_db_put_3003(req)
	__db_put_msg *req;
{
	static __db_put_reply reply; /* must be static */
	static int __db_put_free = 0; /* must be static */

	if (__db_put_free)
		xdr_free((xdrproc_t)xdr___db_put_reply, (void *)&reply);
	__db_put_free = 0;

	/* Reinitialize allocated fields */
	reply.keydata.keydata_val = NULL;

	__db_put_proc(req->dbpcl_id,
	    req->txnpcl_id,
	    req->keydlen,
	    req->keydoff,
	    req->keyulen,
	    req->keyflags,
	    req->keydata.keydata_val,
	    req->keydata.keydata_len,
	    req->datadlen,
	    req->datadoff,
	    req->dataulen,
	    req->dataflags,
	    req->datadata.datadata_val,
	    req->datadata.datadata_len,
	    req->flags,
	    &reply,
	    &__db_put_free);
	return (&reply);
}

/*
 * PUBLIC: __db_re_delim_reply *__db_db_re_delim_3003 
 * PUBLIC:     __P((__db_re_delim_msg *));
 */
__db_re_delim_reply *
__db_db_re_delim_3003(req)
	__db_re_delim_msg *req;
{
	static __db_re_delim_reply reply; /* must be static */

	__db_re_delim_proc(req->dbpcl_id,
	    req->delim,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_re_len_reply *__db_db_re_len_3003 __P((__db_re_len_msg *));
 */
__db_re_len_reply *
__db_db_re_len_3003(req)
	__db_re_len_msg *req;
{
	static __db_re_len_reply reply; /* must be static */

	__db_re_len_proc(req->dbpcl_id,
	    req->len,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_re_pad_reply *__db_db_re_pad_3003 __P((__db_re_pad_msg *));
 */
__db_re_pad_reply *
__db_db_re_pad_3003(req)
	__db_re_pad_msg *req;
{
	static __db_re_pad_reply reply; /* must be static */

	__db_re_pad_proc(req->dbpcl_id,
	    req->pad,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_remove_reply *__db_db_remove_3003 __P((__db_remove_msg *));
 */
__db_remove_reply *
__db_db_remove_3003(req)
	__db_remove_msg *req;
{
	static __db_remove_reply reply; /* must be static */

	__db_remove_proc(req->dbpcl_id,
	    (*req->name == '\0') ? NULL : req->name,
	    (*req->subdb == '\0') ? NULL : req->subdb,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_rename_reply *__db_db_rename_3003 __P((__db_rename_msg *));
 */
__db_rename_reply *
__db_db_rename_3003(req)
	__db_rename_msg *req;
{
	static __db_rename_reply reply; /* must be static */

	__db_rename_proc(req->dbpcl_id,
	    (*req->name == '\0') ? NULL : req->name,
	    (*req->subdb == '\0') ? NULL : req->subdb,
	    (*req->newname == '\0') ? NULL : req->newname,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_stat_reply *__db_db_stat_3003 __P((__db_stat_msg *));
 */
__db_stat_reply *
__db_db_stat_3003(req)
	__db_stat_msg *req;
{
	static __db_stat_reply reply; /* must be static */
	static int __db_stat_free = 0; /* must be static */

	if (__db_stat_free)
		xdr_free((xdrproc_t)xdr___db_stat_reply, (void *)&reply);
	__db_stat_free = 0;

	/* Reinitialize allocated fields */
	reply.stats.stats_val = NULL;

	__db_stat_proc(req->dbpcl_id,
	    req->flags,
	    &reply,
	    &__db_stat_free);
	return (&reply);
}

/*
 * PUBLIC: __db_sync_reply *__db_db_sync_3003 __P((__db_sync_msg *));
 */
__db_sync_reply *
__db_db_sync_3003(req)
	__db_sync_msg *req;
{
	static __db_sync_reply reply; /* must be static */

	__db_sync_proc(req->dbpcl_id,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_truncate_reply *__db_db_truncate_3003 
 * PUBLIC:     __P((__db_truncate_msg *));
 */
__db_truncate_reply *
__db_db_truncate_3003(req)
	__db_truncate_msg *req;
{
	static __db_truncate_reply reply; /* must be static */

	__db_truncate_proc(req->dbpcl_id,
	    req->txnpcl_id,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_cursor_reply *__db_db_cursor_3003 __P((__db_cursor_msg *));
 */
__db_cursor_reply *
__db_db_cursor_3003(req)
	__db_cursor_msg *req;
{
	static __db_cursor_reply reply; /* must be static */

	__db_cursor_proc(req->dbpcl_id,
	    req->txnpcl_id,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __db_join_reply *__db_db_join_3003 __P((__db_join_msg *));
 */
__db_join_reply *
__db_db_join_3003(req)
	__db_join_msg *req;
{
	static __db_join_reply reply; /* must be static */

	__db_join_proc(req->dbpcl_id,
	    req->curs.curs_val,
	    req->curs.curs_len,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __dbc_close_reply *__db_dbc_close_3003 __P((__dbc_close_msg *));
 */
__dbc_close_reply *
__db_dbc_close_3003(req)
	__dbc_close_msg *req;
{
	static __dbc_close_reply reply; /* must be static */

	__dbc_close_proc(req->dbccl_id,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __dbc_count_reply *__db_dbc_count_3003 __P((__dbc_count_msg *));
 */
__dbc_count_reply *
__db_dbc_count_3003(req)
	__dbc_count_msg *req;
{
	static __dbc_count_reply reply; /* must be static */

	__dbc_count_proc(req->dbccl_id,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __dbc_del_reply *__db_dbc_del_3003 __P((__dbc_del_msg *));
 */
__dbc_del_reply *
__db_dbc_del_3003(req)
	__dbc_del_msg *req;
{
	static __dbc_del_reply reply; /* must be static */

	__dbc_del_proc(req->dbccl_id,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __dbc_dup_reply *__db_dbc_dup_3003 __P((__dbc_dup_msg *));
 */
__dbc_dup_reply *
__db_dbc_dup_3003(req)
	__dbc_dup_msg *req;
{
	static __dbc_dup_reply reply; /* must be static */

	__dbc_dup_proc(req->dbccl_id,
	    req->flags,
	    &reply);

	return (&reply);
}

/*
 * PUBLIC: __dbc_get_reply *__db_dbc_get_3003 __P((__dbc_get_msg *));
 */
__dbc_get_reply *
__db_dbc_get_3003(req)
	__dbc_get_msg *req;
{
	static __dbc_get_reply reply; /* must be static */
	static int __dbc_get_free = 0; /* must be static */

	if (__dbc_get_free)
		xdr_free((xdrproc_t)xdr___dbc_get_reply, (void *)&reply);
	__dbc_get_free = 0;

	/* Reinitialize allocated fields */
	reply.keydata.keydata_val = NULL;
	reply.datadata.datadata_val = NULL;

	__dbc_get_proc(req->dbccl_id,
	    req->keydlen,
	    req->keydoff,
	    req->keyulen,
	    req->keyflags,
	    req->keydata.keydata_val,
	    req->keydata.keydata_len,
	    req->datadlen,
	    req->datadoff,
	    req->dataulen,
	    req->dataflags,
	    req->datadata.datadata_val,
	    req->datadata.datadata_len,
	    req->flags,
	    &reply,
	    &__dbc_get_free);
	return (&reply);
}

/*
 * PUBLIC: __dbc_pget_reply *__db_dbc_pget_3003 __P((__dbc_pget_msg *));
 */
__dbc_pget_reply *
__db_dbc_pget_3003(req)
	__dbc_pget_msg *req;
{
	static __dbc_pget_reply reply; /* must be static */
	static int __dbc_pget_free = 0; /* must be static */

	if (__dbc_pget_free)
		xdr_free((xdrproc_t)xdr___dbc_pget_reply, (void *)&reply);
	__dbc_pget_free = 0;

	/* Reinitialize allocated fields */
	reply.skeydata.skeydata_val = NULL;
	reply.pkeydata.pkeydata_val = NULL;
	reply.datadata.datadata_val = NULL;

	__dbc_pget_proc(req->dbccl_id,
	    req->skeydlen,
	    req->skeydoff,
	    req->skeyulen,
	    req->skeyflags,
	    req->skeydata.skeydata_val,
	    req->skeydata.skeydata_len,
	    req->pkeydlen,
	    req->pkeydoff,
	    req->pkeyulen,
	    req->pkeyflags,
	    req->pkeydata.pkeydata_val,
	    req->pkeydata.pkeydata_len,
	    req->datadlen,
	    req->datadoff,
	    req->dataulen,
	    req->dataflags,
	    req->datadata.datadata_val,
	    req->datadata.datadata_len,
	    req->flags,
	    &reply,
	    &__dbc_pget_free);
	return (&reply);
}

/*
 * PUBLIC: __dbc_put_reply *__db_dbc_put_3003 __P((__dbc_put_msg *));
 */
__dbc_put_reply *
__db_dbc_put_3003(req)
	__dbc_put_msg *req;
{
	static __dbc_put_reply reply; /* must be static */
	static int __dbc_put_free = 0; /* must be static */

	if (__dbc_put_free)
		xdr_free((xdrproc_t)xdr___dbc_put_reply, (void *)&reply);
	__dbc_put_free = 0;

	/* Reinitialize allocated fields */
	reply.keydata.keydata_val = NULL;

	__dbc_put_proc(req->dbccl_id,
	    req->keydlen,
	    req->keydoff,
	    req->keyulen,
	    req->keyflags,
	    req->keydata.keydata_val,
	    req->keydata.keydata_len,
	    req->datadlen,
	    req->datadoff,
	    req->dataulen,
	    req->dataflags,
	    req->datadata.datadata_val,
	    req->datadata.datadata_len,
	    req->flags,
	    &reply,
	    &__dbc_put_free);
	return (&reply);
}

