
# all the crap that is stored on the rhn side of stuff
# updating/fetching package lists, channels, etc

from up2date_client import up2dateAuth
from up2date_client import up2dateErrors
from up2date_client import config
from up2date_client import rhnserver

import gettext
t = gettext.translation('rhn-client-tools', fallback=True)
# Python 3 translations don't have a ugettext method
if not hasattr(t, 'ugettext'):
    t.ugettext = t.gettext
_ = t.ugettext

# heh, dont get much more generic than this...
class rhnChannel:
    # shrug, use attributes for thetime being
    def __init__(self, **kwargs):
        self.dict = {}

        for kw in kwargs.keys():
            self.dict[kw] = kwargs[kw]

    def __getitem__(self, item):
        return self.dict[item]

    def __setitem__(self, item, value):
        self.dict[item] = value

    def __lt__(self, other):
        return (self.dict["name"] > other.dict["name"])

    def keys(self):
        return self.dict.keys()

    def values(self):
        return self.dict.values()

    def items(self):
        return self.dict.items()

class rhnChannelList:
    def __init__(self):
        # probabaly need to keep these in order for
        #precedence
        self.list = []

    def addChannel(self, channel):
        self.list.append(channel)


    def channels(self):
        return self.list

    def getByLabel(self, channelname):
        for channel in self.list:
            if channel['label'] == channelname:
                return channel
    def getByName(self, channelname):
        return self.getByLabel(channelname)

    def getByType(self, type):
        channels = []
        for channel in self.list:
            if channel['type'] == type:
                channels.append(channel)
        return channels

# for the gui client that needs to show more info
# maybe we should always make this call? If nothing
# else, wrapper should have a way to show extended channel info
def getChannelDetails(timeout=None):

    channels = []
    sourceChannels = getChannels(timeout=timeout)

    for sourceChannel in sourceChannels.channels():
        if sourceChannel['type'] != 'up2date':
            # FIMXE: kluge since we dont have a good name, maybe be able to fix
            sourceChannel['name'] = sourceChannel['label']
            sourceChannel['description'] = "%s channel %s from  %s" % (sourceChannel['type'],
                                                                           sourceChannel['label'],
                                                                           sourceChannel['url'])
        channels.append(sourceChannel)
    return channels

cmdline_pkgs = []

global selected_channels
selected_channels = None
def getChannels(force=None, label_whitelist=None, timeout=None):
    """ return rhnChannelList containing list of channel we are subscribed to """
    cfg = config.initUp2dateConfig()
    global selected_channels
    if not selected_channels and not force:
        selected_channels = rhnChannelList()
        s = rhnserver.RhnServer(timeout=timeout)

        if not up2dateAuth.getSystemId():
            raise up2dateErrors.NoSystemIdError(_("Unable to Locate SystemId"))

        up2dateChannels = s.up2date.listChannels(up2dateAuth.getSystemId())

        for chan in up2dateChannels:
            if label_whitelist and not chan['label'] in label_whitelist:
                continue

            channel = rhnChannel(type = 'up2date', url = config.getServerlURL())
            for key in chan.keys():
                if key == "last_modified":
                    channel['version'] = chan['last_modified']
                else:
                    channel[key] = chan[key]
            selected_channels.addChannel(channel)

    if len(selected_channels.list) == 0:
        raise up2dateErrors.NoChannelsError(_("This system may not be updated until it is associated with a channel."))

    return selected_channels


def setChannels(tempchannels):
    global selected_channels
    selected_channels = None
    whitelist = dict(map(lambda x: (x,1), tempchannels))
    return getChannels(label_whitelist=whitelist)



def subscribeChannels(channels,username,passwd):
    s = rhnserver.RhnServer()
    return s.up2date.subscribeChannels(up2dateAuth.getSystemId(), channels, username,
        passwd)

def unsubscribeChannels(channels,username,passwd):
    s = rhnserver.RhnServer()
    return s.up2date.unsubscribeChannels(up2dateAuth.getSystemId(), channels,
        username, passwd)
