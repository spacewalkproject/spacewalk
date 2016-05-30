import os

if os.environ.get('AS_SUSE', False):
    from suse import (
        RepoSync, ChannelException, ChannelTimeoutException
    )
else:
    from reposync import RepoSync

from common import getChannels
