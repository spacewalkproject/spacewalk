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

class InvalidSession(Exception):
    pass

class AuthenticationError(Exception):
    pass

class MalformedRepository(Exception):
    pass

class FileNotInRepo(Exception):
    pass

class ConfigChannelNotInRepo(Exception):
    pass

class ConfigChannelAlreadyExistsError(Exception):
    pass

class ConfigChannelNotEmptyError(Exception):
    pass

class RepoAlreadyExists(Exception):
    pass

class RepoPlainFile(Exception):
    pass

class ConfigNotManaged(Exception):
    pass

class ConfigurationError(Exception):
    pass

class BinaryFileDiffError(Exception):
    pass

class RepositoryFileError(Exception):
    pass

class RepositoryLocalFileError(Exception):
    pass

class RepositoryFileMissingError(Exception):
    pass

class RepositoryFilePushError(RepositoryFileError):
    pass

class ConfigFileTooLargeError(RepositoryFilePushError):
    pass

class QuotaExceeded(RepositoryFilePushError):
    pass

class RepositoryFileExistsError(RepositoryFilePushError):
    "Attempted to add a file that already exists"
    pass

class RepositoryFileVersionMismatchError(RepositoryFilePushError):
    "File upload failed because the version changed underneath"
    pass

class FileEntryIsDirectory(Exception):
    pass

class DirectoryEntryIsFile(Exception):
    pass

class UserNotFound(Exception):
    pass

class GroupNotFound(Exception):
    pass
