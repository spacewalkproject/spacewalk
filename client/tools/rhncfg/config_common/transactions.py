#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation. 
#

import os
import shutil
import pwd
import grp
import sys
import errno
import shutil
import traceback
import string

from config_common import file_utils, utils, cfg_exceptions
from config_common.rhn_log import log_debug
from selinux import lsetfilecon

class TargetNotFile(Exception): pass
class DuplicateDeployment(Exception): pass
class BackupFileMissing(Exception): pass
class FailedRollback(Exception): pass

BACKUP_PREFIX = '/var/lib/rhncfg/backups'
BACKUP_EXTENSION = '.rhn-cfg-backup'

class DeployTransaction:

    def __init__(self, transaction_root=None, auto_rollback=0):
        # rollback transaction immediately upon failure?
        self.auto_rollback = auto_rollback
        # prepend all given paths
        self.transaction_root = transaction_root

        self.files = []
	self.dirs  = []
	self.new_dirs = []
        self.backup_by_path = {}
        self.newtemp_by_path = {}
	self.changed_dir_info = {}

        self.deployment_cb = None


    def _generate_backup_path(self, path):
        return "%s%s%s" % (BACKUP_PREFIX, path, BACKUP_EXTENSION)

    
    def _rename_to_backup(self, path):
        """renames a file to it's new backup name"""
        # ensure we haven't attempted to back this file up before
        # (protect against odd logic coming from the server)
        if self.backup_by_path.has_key(path):
            raise DuplicateDeployment("Error: attempted to backup %s twice" % path)


        new_path = None

        if os.path.exists(path):
            # race
            if os.path.isfile(path):
                new_path = self._generate_backup_path(path)
                log_debug(6, "renaming %s to backup %s ..." % (path, new_path))
	        # os.renames will fail if the path and the new_path are on different partitions
	    	# need to make sure to handle it if we catch a 'OSError: [Errno 18] Invalid cross-device link'
		try:
		    log_debug(9, "trying to use os.renames")
                    oumask = os.umask(022)
                    os.renames(path, new_path)
                    os.umask(oumask)
		except OSError, e:
		    if e.errno == 18:
			log_debug(9, "os.renames failed, using shutil functions")
			path_dir, path_file = os.path.split(path)
			new_path_dir, new_path_file = os.path.split(new_path)
			if os.path.isdir(new_path_dir):
			    log_debug(9, "backup directory %s exists, copying %s to it" % (new_path_dir, new_path_file))
                	    shutil.copy(path, new_path)
			else:
			    log_debug(9, "backup directory does not exist, creating the tree now")
                	    shutil.copytree(path_dir, new_path_dir, symlinks=0)
                	    shutil.copy(path, new_path)
		    else:
		    	raise
                self.backup_by_path[path] = new_path
                log_debug(9, "backed up to %s" % new_path)
            else:
                raise TargetNotFile("Error: %s is not a valid file, cannot create backup copy" % path)
        return new_path


    def deploy_callback(self, cb):
        self.deployment_cb = cb

    def _chown_chmod_chcon(self, temp_file_path, dest_path, file_info, strict_ownership=1):
        uid = file_info.get('uid')
        if uid is None:
            if file_info.has_key('username'):            
                # determine uid

                try:
                    user_record = pwd.getpwnam(file_info['username'])
                except Exception, e:
                    raise cfg_exceptions.UserNotFound(file_info['username'])
        
                uid = user_record[2]
            else:
                #default to root (3.2 sats)
                uid = 0

        gid = file_info.get('gid')
        if gid is None:
            if file_info.has_key('groupname'):
                # determine gid
                try:
                    group_record = grp.getgrnam(file_info['groupname'])
                except Exception, e:
                    raise cfg_exceptions.GroupNotFound(file_info['groupname'])

                gid = group_record[2]
            else:
                #default to root (3.2 sats)
                gid = 0

        try:
            if file_info['filetype'] != 'symlink':
                os.chown(temp_file_path, uid, gid)

                mode = '600'
                if file_info.has_key('filemode'):
                    mode = file_info['filemode']

                mode = string.atoi(str(mode), 8)
                os.chmod(temp_file_path, mode)

            if file_info.has_key('selinux_ctx'):
                sectx = file_info.get('selinux_ctx')
                if sectx is not None and sectx is not "":
                    log_debug(1, "selinux context: " + sectx);
                    try:
                        if lsetfilecon(temp_file_path, sectx) < 0:
                            raise Exception("failed to set selinux context on %s" % dest_path)
                    except OSError, e:
                        raise Exception("failed to set selinux context on %s" % dest_path, e), None, sys.exc_info()[2]

        except OSError, e:
            if e.errno == errno.EPERM and not strict_ownership:
                sys.stderr.write("cannonical file ownership and permissions lost on %s\n" % dest_path)
            else:
                raise
                

        
    def _normalize_path_to_root(self, path):
        if self.transaction_root:
            path = utils.normalize_path(self.transaction_root + os.sep + path)
        return path

    def add_preprocessed(self, dest_path, processed_file_path, file_info, dirs_created, strict_ownership=1):
	"""preprocess the file if needed, and add the entry to the correct list"""
        dest_path = self._normalize_path_to_root(dest_path)
	log_debug(3, "preprocessing entry")

	# If we get any dirs that were created by mkdir_p, add them here
	if dirs_created:
	    self.new_dirs.extend(dirs_created)

	# If the file is a directory, don't do all the file related work
        # Older servers will not return directories; if filetype is missing,
        # assume file
	if file_info.get('filetype') == 'directory':
		self.dirs.append(file_info)
	elif file_info.get('filetype') == 'symlink':
		self.files.append(file_info)
	else:
        	self._chown_chmod_chcon(processed_file_path, dest_path, file_info, strict_ownership=strict_ownership)

        	if self.newtemp_by_path.has_key(dest_path):
            	    raise DuplicateDeployment("Error:  %s already added to transaction" % dest_path)

        	self.newtemp_by_path[dest_path] = processed_file_path

    def add(self, file_info):
        """add a file to the deploy transaction"""
        for k in file_utils.FileProcessor.file_struct_fields.keys():
            if not file_info.has_key(k):
                raise Exception("needed key %s mising from file structure" % k)

        file_info['path'] = self._normalize_path_to_root(file_info['path'])
        
        # Older servers will not return directories; if filetype is missing,
        # assume file
	if file_info.get('filetype') == 'directory':
	    self.dirs.append(file_info)
	elif file_info.get('filetype') == 'symlink':
	    self.files.append(file_info)
	else:
            self.files.append(file_info)


    def rollback(self):
        """revert the transaction"""
        log_debug(3, "rolling back")

        # restore old file from backup asap
        for path in self.backup_by_path.keys():
            log_debug(6, "restoring %s from %s ..." % (path, self.backup_by_path[path]))
	    # os.rename will fail if the backup file and the old file are on different partitions
	    # need to make sure to handle it if we catch a 'OSError: [Errno 18] Invalid cross-device link'
	    try:
                os.rename(self.backup_by_path[path], path)
	    except OSError, e:
                if e.errno == 18:
		    log_debug(9, "os.rename failed, using shutil.copy")
		    shutil.copy(self.backup_by_path[path], path)
		else:
		    raise
            log_debug(9, "%s restored" % path)

	# remove the temp files that we created
        for tmp_file_path in self.newtemp_by_path.values():
            log_debug(6, "removing tmp file %s ..." % tmp_file_path)
            os.unlink(tmp_file_path)
            log_debug(9, "tmp file removed")

	#revert the owner/perms of any directories that we changed
        for d, val in self.changed_dir_info.items():
            log_debug(6, "reverting owner and perms of %s" % d)
            self._chown_chmod_chcon(d, d, val)
            log_debug(9, "directory reverted")

	#remove any directories created by either mkdir_p or in the deploy
        self.new_dirs.reverse()	
	for i in range(len(self.new_dirs)):
	    remove_dir = self.new_dirs[i]
	    log_debug(6, "removing directory %s that was created during transaction ..." % remove_dir)
	    os.rmdir(remove_dir)
	    log_debug(9, "directory removed")

        log_debug(3, "rollback successful")
                
    def deploy(self):
        """attempt deployment; will rollback if auto_rollback is set"""
        fp = file_utils.FileProcessor()

        log_debug(3, "deploying transaction")
 
	# 0. handle any dirs we need to create first
	#    a) if the dir exists, then just change the mode and owners, 
	#	else create it and then make sure the mode and owners are correct.
	#    b) if there are files, then continue
        # 1. write new version (tmp)
        #    a)  if anything breaks, remove all tmp versions and error out
        # 2. rename old version to backup
        #    a)  if anything breaks, rename all backed up files to original name,
        #        then do 1-a.
        # 3. rename tmp to target name
        #    a)  if anything breaks, remove all deployed files, then do 2-a.
        #
        # (yes, this leaves the backup version on disk...)
        
        try:

	    # 0.
	    if self.dirs:
		for directory in self.dirs:
		    dirname = directory['path']
		    dirmode = directory['filemode']
		    if os.path.isfile(dirname):
			raise cfg_exceptions.DirectoryEntryIsFile(dirname)
                    if os.path.isdir(dirname):
                        s = os.stat(dirname)
                        entry = {}
                        entry["filemode"] = "%o" % (s[0] & 07777)
                        entry["uid"] = s[4]
                        entry["gid"] = s[5]
                        self.changed_dir_info[dirname] = entry
                        log_debug(3, "directory found, chowning and chmoding to %s as needed: %s" % (dirmode, dirname))
                        self._chown_chmod_chcon(dirname, dirname, directory)
                    else:
                        log_debug(3, "directory not found, creating: %s" % dirname)
			dirs_created = utils.mkdir_p(dirname)
                        self.new_dirs.extend(dirs_created)
                        self._chown_chmod_chcon(dirname, dirname, directory)
                    if self.deployment_cb:
                        self.deployment_cb(dirname)

            log_debug(6, "changed_dir_info: %s" % self.changed_dir_info)
	    log_debug(4, "new_dirs: ", self.new_dirs)


	    if not self.newtemp_by_path and not self.files:
		log_debug(4, "directory creation complete, no files found to create")
		return
	    else:
		log_debug(4, "done with directory creation, moving on to files")

            # 1.
            for dep_file in self.files:
                path = dep_file['path']

                log_debug(6, "writing new version of %s to tmp file ..." % path)
                # make any directories needed...
                #
                # TODO:  it'd be nice if this had a hook for letting me know
                # which ones are created... then i could clean created
                # dirs on rollback
                (directory, filename) = os.path.split(path)
		if os.path.isdir(path):
		    raise cfg_exceptions.FileEntryIsDirectory(path)
                if not os.path.exists(directory) and os.path.isdir(directory):
                    log_debug(7, "creating directories for %s ..." % directory)
                    dirs_created = utils.mkdir_p(directory)
		    self.new_dirs.extend(dirs_created)
                    log_debug(7, "directories created and added to list for rollback")
                
                # write the new contents to a tmp file, and store the path of the
                # new tmp file by it's eventual target path
                self.newtemp_by_path[path], temp_new_dirs = fp.process(dep_file, directory=directory)
                self.new_dirs.extend(temp_new_dirs or [])
                
                # properly chown and chmod it
                self._chown_chmod_chcon(self.newtemp_by_path[path], path, dep_file)
                log_debug(9, "tempfile written:  %s" % self.newtemp_by_path[path])


            #paths = map(lambda x: x['path'], self.files)
            paths = self.newtemp_by_path.keys()

            # 2.
            for path in paths:
		if os.path.isdir(path):
		    raise cfg_exceptions.FileEntryIsDirectory(path)	
		else:
                    self._rename_to_backup(path)
                    if self.backup_by_path.has_key(path):
                    	log_debug(9, "backup file %s written" % self.backup_by_path[path])

            # 3.
            for path in paths:
                if self.deployment_cb:
                    self.deployment_cb(path)

                log_debug(6, "deploying %s ..." % path)
                os.rename(self.newtemp_by_path[path], path)
                # race
                del self.newtemp_by_path[path]
                log_debug(9, "new version of %s deployed" % path)

            log_debug(3, "deploy transaction successful")
                
        except Exception:
            #log_debug(1, traceback.format_exception_only(SyntaxError, e))
            #traceback.print_exc()
            if self.auto_rollback:
                self.rollback()
            raise

        


    
        
