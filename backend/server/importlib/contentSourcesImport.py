#
# Copyright (c) 2016--2017 Red Hat, Inc.
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
#

from importLib import Import, Channel
from spacewalk.server.rhnChannel import channel_info


class ContentSourcesImport(Import):

    def __init__(self, batch, backend):
        Import.__init__(self, batch, backend)
        self.channels_to_link = {}

    def preprocess(self):
        for content_source in self.batch:
            # Link back content sources to channel objects to subscribe them to existing channels right after import
            if 'channels' in content_source and content_source['channels'] is not None:
                for channel_label in content_source['channels']:
                    if channel_label not in self.channels_to_link:
                        db_channel = channel_info(channel_label)
                        channel_obj = Channel()
                        channel_obj.id = db_channel['id']
                        channel_obj['content-sources'] = []
                        self.channels_to_link[channel_label] = channel_obj
                    self.channels_to_link[channel_label]['content-sources'].append(content_source)

    def fix(self):
        pass

    def submit(self):
        try:
            self.backend.processContentSources(self.batch)
            for channel in self.channels_to_link.values():
                self.backend.processChannelContentSources(channel)
        except:
            self.backend.rollback()
            raise
        self.backend.commit()
