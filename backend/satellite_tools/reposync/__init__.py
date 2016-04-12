import os

if os.environ.get('AS_SUSE', False):
    from suse import (
        RepoSync, ChannelException, ChannelTimeoutException, getCustomChannels
    )
else:
    from reposync import RepoSync, getCustomChannels
