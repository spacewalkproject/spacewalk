
"""
Module for taskomatic related functions (inserting into queues, etc)
"""

from server import rhnSQL

class RepodataQueueEntry(object):

    def __init__(self, channel, client, reason, force=False,
            bypass_filters=False):
        self.channel = channel
        self.client = client
        self.reason = reason
        self.force = force
        self.bypass_filters = bypass_filters


class RepodataQueue(object):

    def _boolean_as_char(boolean):
        if boolean:
            return 'Y'
        else:
            return 'N'

    _boolean_as_char = staticmethod(_boolean_as_char)

    def add(self, entry):
        h = rhnSQL.prepare("""
            insert into rhnRepoRegenQueue
                (id, channel_label, client, reason, force, bypass_filters,
                 next_action, created, modified)
            values (
                sequence_nextval('rhn_repo_regen_queue_id_seq'),
                :channel, :client, :reason, :force, :bypass_filters,
                sysdate, sysdate, sysdate
            )
        """)

        h.execute(channel=entry.channel, client=entry.client,
            reason=entry.reason, force=self._boolean_as_char(entry.force),
            bypass_filters=self._boolean_as_char(entry.bypass_filters))

def add_to_repodata_queue(channel, client, reason, force=False,
        bypass_filters=False):
    entry = RepodataQueueEntry(channel, client, reason, force, bypass_filters)
    queue = RepodataQueue()
    queue.add(entry)

# XXX not the best place for this...
def add_to_repodata_queue_for_channel_package_subscription(affected_channels,
        batch, caller):

        tmpreason = []
        for package in batch:
            tmpreason.append(package.short_str())

        reason = " ".join(tmpreason)

        for channel in affected_channels:
            # don't want to cause an error for the db
            add_to_repodata_queue(channel, caller, reason[:128])

