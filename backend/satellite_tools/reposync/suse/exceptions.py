from yum.i18n import to_unicode


class ChannelException(Exception):

    """Channel Error"""

    def __init__(self, value=None):
        Exception.__init__(self)
        self.value = value

    def __str__(self):
        return "%s" % (self.value,)

    def __unicode__(self):
        return '%s' % to_unicode(self.value)


class ChannelTimeoutException(ChannelException):

    """Channel timeout error e.g. a remote repository is not responding"""
    pass
