import os

if os.environ.get('AS_SUSE', False):
    from suse.reposync import (
        RepoSync, ChannelException, ChannelTimeoutException
    )
else:
    from reposync import RepoSync, ChannelException, ChannelTimeoutException
