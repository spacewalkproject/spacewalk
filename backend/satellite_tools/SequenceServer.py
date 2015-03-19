#
# Copyright (c) 2008--2015 Red Hat, Inc.
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
# class SequenceServer, a class that nicely serves chunks
#    of any sequence.
#


class SequenceServer:

    """Given a sequence to serve, this class dishes them out in chunks
    or one at a time. This was written originally to reduce redundant
    code. Used only by class Syncer.

    This class was written so that a chunk can be snagged and
    processed. If the processing fails, one can tell the class to only
    present one at a time until that chunk is complete... and then
    resume normal operations.

    For example: the sequence can be a bunch of packageIds. We try to
    process all data that corresponds to some chunk of those package
    ids. If that process fails, we go back and reprocess that chunk,
    one at a time, until it is complete (identifying precisely which
    package broke). Then we resume processing a chunk at a time.

    """

    DIVISOR = 10
    NEVER_LESS_THAN = 10
    NEVER_MORE_THAN = 50

    def __init__(self, seq, divisor=None, neverlessthan=None, nevermorethan=None):
        """Constructor.

        Arguments:

        seq - any sequence to server chunks of
        divisor - the chunk size: 10 would be 1/10th of the seq length
        neverlessthan - chunk-size is never less than this (unless out
                        of data).
        nevermorethan - chunk-size if never more than this number.

        """

        divisor = divisor or self.DIVISOR
        neverlessthan = neverlessthan or self.NEVER_LESS_THAN
        nevermorethan = nevermorethan or self.NEVER_MORE_THAN

        self.seq = seq
        self.chunksize = min(max(len(seq) / divisor, neverlessthan),
                             nevermorethan)
        self.oneYN = 0
        self.alwaysOneYN = 0
        self.returnedChunksize = 0
        self.chunk = self.seq[:self.chunksize]

    def getChunk(self):
        """fetch a chunk from the sequence.
        Does not refresh the chunk until you self.clearChunk()"""

        if not self.chunk:
            self.chunk = self.seq[:self.chunksize]
        if self.oneYN or self.alwaysOneYN:
            _chunk = self.chunk[:1]
        else:
            _chunk = self.chunk
        self.returnedChunksize = len(_chunk)
        return _chunk

    def clearChunk(self):
        """zero the self.chunk you were working with."""

        del self.chunk[:self.returnedChunksize]
        del self.seq[:self.returnedChunksize]
        if not self.chunk:
            self.oneYN = 0

    def doneYN(self):
        return not self.seq
