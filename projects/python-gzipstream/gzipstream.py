"""GzipStream & GzipStreamXL Classes

GzipStream (Python v1.5.2 - v2.2.*):
    A streaming gzip handler.
    gzipstream.GzipStream extends the functionality of the gzip.GzipFile class
    to allow the processing of streaming data.
    This is done by buffering the stream as it passes through (a seekable
    object is needed).

GzipStreamXL (Python v1.5.2/v2.1.* --- ie. not v2.2.*):
    A streaming gzip handler for very large files.

_StreamBuf:
    Allow seeks on socket-like objects -- support GzipStream class.
    Enables non-seekable file-like objects some flexibility as regards to
    seeking. It does this via a buffer, a StringIO object. Note, because
    it is assumed that a socket stream is being manipulated, once the buffer
    "window" has passed over a data segment, seeking prior to that is not
    allowed.

XXX: Eventually, I wish to merge this with the gzip.GzipFile somehow and
     submit to the python folks.

Author: Todd Warner <taw@redhat.com>
Copyright (c) 2002-2010, Red Hat, Inc.
Released under Python license and GPLv2 license
"""

#WARNING: gzipstream will wrap a file-object. The responsibility of properly
#WARNING: destroying/closing that file-object resides outside of these
#WARNING: classes.
#WARNING:
#WARNING: Also, due to issues with python 1.5.2/2.1.* garbage collection issues,
#WARNING: responsibility of properly handling flushing IO and other expected
#WARNING: behavior of a properly collected object *also* resides with the
#WARNING: instantiating entity. I.e., you need to explicitely close your
#WARNING: GzipStream object!!!


import sys
import gzip
from gzip import zlib
from types import IntType, LongType
import struct
import string
try:
    # Is this *still* needed? cStringIO supposedly works on all platforms
    from cStringIO import StringIO
except ImportError:
    from StringIO import StringIO


_DEBUG_YN = 0
if _DEBUG_YN:
    import time
    try:
        import thread
    except:
        pass


def __getSysVersion():
    """Return 1 for Python versions 1.5.* and 2.1.*
       Return 2 for Python versions 2.2+.*
    """
    minor = int(string.split(string.split(sys.version)[0], '.')[1])
    if minor < 2:
        return 1
    return 2
_SYS_VERSION = __getSysVersion()


class GzipStream(gzip.GzipFile):
    """Handle streaming gzipped data

    GzipStream extends the functionality of the gzip.GzipFile class.
    gzip.GzipFile generally needs a seekable object. This doesn't allow for
    streaming gzipped data to be processed easily (e.g. can't seek a socket).
    Using the _StreamBuf class enables streaming gzipped data to be processed
    by buffering that data at it passes through.

    For Python versions 1.5.2 & 2.1.*:
    Normal data version.
    Normally sized data stream version == faster.
    For very large data streams (2.5GB-ish), use GzipStreamXL.
    """
    VERSION = _SYS_VERSION # so garbage collector doesn't nuke it too early with
                           # older (v1.5.2-v2.1.*) python.

    def __init__(self, stream=None, mode=None, compresslevel=9):
        if stream is None:
            stream = sys.stdout

        mode = self._initModeLogic(stream, mode)

        # self.stream becomes a _StreamBuf object
        if not isinstance(stream, _StreamBuf):
            self.stream = _StreamBuf(stream, mode)
        else:
            self.stream = stream
        self._gzip = gzip # hang onto for destructive reasons
        self._gzip.GzipFile.__init__(self, '', mode, compresslevel, self.stream)

    def _initModeLogic(self, stream, mode):
        "attempt to determine the mode"
        _mode = None
        _modes = ''
        if hasattr(stream, 'mode'):
            _mode = stream.mode
            _modes = _mode
        # Attributes lie, by the way, so sometimes we have to punt.
        if not _mode and hasattr(stream, 'read'):
            _modes = _modes + 'r'
        if not _mode and hasattr(stream, 'write'):
            _modes = _modes + 'w'
        # NOTE: Async objects needs a mode set or defaults to 'rb'

        if not _mode and not mode:
            # punt
            if 'r' in _modes:
                mode = _mode = 'rb'
            elif 'w' in _modes:
                mode = _mode = 'wb'
        elif not mode:
            mode = _mode

        if mode[0] not in _modes:
            raise ValueError, 'Mode %s not supported' % mode
        return mode

    def _read(self, size=1024):
        # overloaded --- one line changed.
        # Instead of seek(0,2) to see if we are at the end of the
        # file, just do a seek(pos+1) if the same then we are at the
        # end of the file.
        if self.stream is None:
            raise EOFError, "Reached EOF"

        if self._new_member:
            # If the _new_member flag is set, we have to
            #
            # First, check if we're at the end of the file;
            # if so, it's time to stop; no more members to read.
            pos = self.stream.tell()   # Save current position
            self.stream.seek(pos+1)    # Seek further... if at end, won't
                                        # seek any further.
            if pos == self.stream.tell():
                self.stream.close()
                self.stream = None
                return EOFError, "Reached EOF"
            else:
                self.stream.seek( pos ) # Return to original position

            self._init_read()
            self._read_gzip_header()
            self.decompress = zlib.decompressobj(-zlib.MAX_WBITS)
            self._new_member = 0

        # Read a chunk of data from the file
        buf = self.stream.read(size)

        # If the EOF has been reached, flush the decompression object
        # and mark this object as finished.

        if buf == "":
            uncompress = self.decompress.flush()
            self._read_eof()
            self.stream.close()
            self.stream = None
            self._add_read_data( uncompress )
            raise EOFError, 'Reached EOF'

        uncompress = self.decompress.decompress(buf)
        self._add_read_data( uncompress )

        if self.decompress.unused_data != "":
            # Ending case: we've come to the end of a member in the file,
            # so seek back to the start of the unused data, finish up
            # this member, and read a new gzip header.
            # (The number of bytes to seek back is the length of the unused
            # data, minus 8 because _read_eof() will rewind a further 8 bytes)
            self.stream.seek( -len(self.decompress.unused_data)+8, 1)

            # Check the CRC and file size, and set the flag so we read
            # a new member on the next call
            self._read_eof()
            self._new_member = 1

    def seek(self, offset):
        raise IOError, 'Random access not allowed in gzip streams'

    def __repr__(self):
        ret = ''
        if self.stream._closedYN:
            ret = "<closed gzipstream.GzipStream instance, mode '%s' at %s>" % \
                  (self.stream.mode, id(self))
        else:
            ret = "<open gzipstream.GzipStream instance, mode '%s' at %s>" % \
                  (self.stream.mode, id(self))
        return ret

    ### These methods are generally only important for Python v2.2.* ###
    def _read_eof(self):
        # overloaded to accommodate LongType
        if type(self.size) == LongType:
            self._gzip.read32 = self._read32XL
        self._gzip.GzipFile._read_eof(self)

    def close(self):
        if self.stream and self.stream._closedYN:
            # remove this block for python v2.2.*
            return
        # overloaded to accommodate LongType
        if hasattr(self, 'size'):
            if type(self.size) == LongType:
                self._gzip.write32 = self._gzip.write32u
        else:
            # write32u is the "safest" route if punting.
            self._gzip.write32 = self._gzip.write32u
        self._gzip.GzipFile.close(self)
        if self.stream:
            self.stream.close()

    def _read32XL(self, input):
        """Allow for very large files/streams to be processed.
           Slows things down, but...

        Used by Python v2.2.*.
        Also used by Python v1.5.2/v2.1.* in inheriting class GzipStreamXL.
        """
        return struct.unpack("<L", input.read(4))[0]


#
# Python v1.5.2/v2.1.* version only class
#
if _SYS_VERSION == 1:
    class GzipStreamXL(GzipStream):
        """Handle streaming gzipped data -- large data version.

        Very large sized data stream version -- slooower.
        For normally sized data streams (< 2.5GB-ish), use GzipStream.
        """
        def __init__(self, stream=None, mode=None, compresslevel=9):
            gzip.read32 = self._read32XL
            gzip.write32 = gzip.write32u
            GzipStream.__init__(self, stream, mode, compresslevel)


        def _init_write(self, filename):
            """Make size long in order to support very large files.
            """
            GzipStream._init_write(self, filename)
            self.size = 0L


        def _init_read(self):
            """Make size a long in order to support very large files.
            """
            GzipStream._init_read(self)
            self.size = 0L


class _StreamBuf:
    """Stream buffer for file-like objects.

    Allow seeks on socket-like objects.
    Enables non-seekable file-like objects some flexibility as regards to
    seeking. It does this via a buffer, a StringIO object. Note, because
    it is assumed that a socket stream is being manipulated, once the buffer
    "window" has passed over a data segment, seeking prior to that is not
    allowed.
    XXX: probably reinventing the wheel.
    """
    __MIN_READ_SIZE = 1024 * 2                  # Default = 2K
    __MAX_BUFIO_SIZE = __MIN_READ_SIZE * 10     # Default = 20K
    __ABS_MAX_BUFIO_SIZE = __MAX_BUFIO_SIZE * 2 # Default = 40K

    ### Python versions 1.5.2 & 2.1.* only:
    __INT_CHECK_SIZE = sys.maxint - __ABS_MAX_BUFIO_SIZE -2

    VERSION = _SYS_VERSION # so garbage collector doesn't nuke it too early with
                           # older (v1.5.2-v2.1.*) python.

    def __init__(self, stream=None, mode=None):
        """Constructor.
        stream: an open file-like object.
        """
        self.fo = stream
        self._readableYN = 0
        self._writableYN = 0

        if self.fo is None:
            self.fo = StringIO()
            mode = 'wb'
            self._readableYN = 1
            self._writableYN = 1

        # If mode not declared, try to figure it out.
        if mode is None:
            try:
                mode = self.fo.mode
            except:
                pass

        # Can only read or write, not both and really the 'b' is meaningless.
        if not mode or (type(mode) == type("") \
        and (mode[0] not in 'rw' or (len(mode) > 1 and mode[1] != 'b'))):
            raise IOError, (22, "Invalid argument: mode=%s" % repr(mode))

        if mode[0] == 'r':
            self._readableYN = 1
        else:
            self._writableYN = 1

        # Better be an open file-like object.
        if self._readableYN:
            self.fo.read # Throw AttributeError if not readable.
        if self._writableYN:
            self.fo.write # Throw AttributeError if not writable.

        self._closedYN = 0
        self._currFoPos = 0 # Assume at beginning of stream.
        self._bufIO = StringIO()
        self._lenBufIO = 0
        self.mode = mode
        # Threaded debug loop:
        self.__mutexOnYN = 0
        if _DEBUG_YN and globals().has_key('thread'):
            thread.start_new(self.__debugThread, ())

    def __del__(self):
        "Destructor"
        # Python v1.5.2/v2.1.* tries to run this but close doesn't always
        # still exist. For a pure Python v2.2.*, remove the try: except:.
        try:
            self.close()
        except:
            pass

    def isatty(self):
        if self._closedYN:
            raise ValueError, "I/O operation on closed _StreamBuf object"
        return 0

    def _read(self, size):
        """A buffered read --- refactored.
        """
        if self._closedYN:
            raise ValueError, "I/O operation on closed _StreamBuf object"
        if not self._readableYN:
            raise IOError, (9, "Can't read from a write only object")
        tell = self._bufIO.tell()
        bufIO = self._bufIO.read(size)
        lbufIO = len(bufIO)
        bufFo = ''
        lbufFo = 0
        if lbufIO < size:
            # We read to end of buffer; read from file and tag onto buffer.
            buf = self.fo.read(_StreamBuf.__MIN_READ_SIZE)
            bufFo = buf
            lbufFo = len(bufFo)
            while buf and lbufFo + lbufIO < size:
                buf = self.fo.read(_StreamBuf.__MIN_READ_SIZE)
                bufFo = '%s%s' % (bufFo, buf)
                lbufFo = len(bufFo)
            self._bufIO.write(bufFo)
            self.__mutexOnYN = 1
            self._lenBufIO = self._lenBufIO + lbufFo
            self.__mutexOnYN = 0
        if lbufIO + lbufFo < size: # covers case that size > filelength.
            size = lbufIO + lbufFo
        self._bufIO.seek(tell + size)
        if _StreamBuf.VERSION == 1:
            self._currFoPos = self.__checkInt(self._currFoPos)
        self._currFoPos = self._currFoPos + size
        bufFo = bufFo[:size-lbufIO]
        self._refactorBufIO()
        return '%s%s' % (bufIO, bufFo)

    def read(self, size=None):
        """A buffered read.
        """
        if size and size < 0:
            raise IOError, (22, "Invalid argument")
        if not self._readableYN:
            raise IOError, (9, "Can't read from a write only object")
        fetchSize = _StreamBuf.__MAX_BUFIO_SIZE
        if size:
            fetchSize = min(fetchSize, size)
        buf = self._read(fetchSize)
        bufOut = buf
        accumSize = len(buf)
        while buf:
            if size and accumSize >= size:
                break
            buf = self._read(fetchSize)
            bufOut = '%s%s' % (bufOut, buf)
            if _StreamBuf.VERSION == 1:
                accumSize = self.__checkInt(accumSize)
            accumSize = accumSize + len(buf)
        return bufOut

    def readline(self):
        """Return one line of text: a string ending in a '\n' or EOF.
        """
        if self._closedYN:
            raise ValueError, "I/O operation on closed _StreamBuf object"
        if not self._readableYN:
            raise IOError, (9, "Can't read from a write only object")
        line = ''
        buf = self.read(_StreamBuf.__MIN_READ_SIZE)
        while buf:
            i = string.find(buf, '\n')
            if i >= 0:
                i = i + 1
                self._bufIO.seek(-(len(buf)-i), 1)
                buf = buf[:i]
                line = '%s%s' % (line, buf)
                break
            line = '%s%s' % (line, buf)
            buf = self.read(_StreamBuf.__MIN_READ_SIZE)
        return line

    def readlines(self):
        """Read entire file into memory! And return a list of lines of text.
        """
        if self._closedYN:
            raise ValueError, "I/O operation on closed _StreamBuf object"
        if not self._readableYN:
            raise IOError, (9, "Can't read from a write only object")
        lines = []
        line = self.readline()
        while line:
            lines.append(line)
            line = self.readline()
        return lines

    def _refactorBufIO(self, writeFlushYN=0):
        """Keep the buffer window within __{MAX,ABS_MAX}_BUF_SIZE before
           the current self._bufIO.tell() position.
        """
        self.__mutexOnYN = 1
        tell = self._bufIO.tell()
        tossed = ''
        if writeFlushYN:
            tossed = self._bufIO.getvalue()[:tell]
            self._lenBufIO = self._lenBufIO - len(tossed)
            tell = tell - len(tossed)
            s = self._bufIO.getvalue()[tell:]
            self._bufIO = StringIO()
            self._bufIO.write(s)
            self._bufIO.seek(tell)
        elif tell >= _StreamBuf.__ABS_MAX_BUFIO_SIZE:
            tossed = self._bufIO.getvalue()[:_StreamBuf.__MAX_BUFIO_SIZE]
            self._lenBufIO = self._lenBufIO - _StreamBuf.__MAX_BUFIO_SIZE
            tell = tell - _StreamBuf.__MAX_BUFIO_SIZE
            s = self._bufIO.getvalue()[_StreamBuf.__MAX_BUFIO_SIZE:]
            self._bufIO = StringIO()
            self._bufIO.write(s)
            self._bufIO.seek(tell)
        self.__mutexOnYN = 0
        return tossed

    def _dumpValues(self):
        """Debug code.
        """
        err = sys.stderr.write
        err('self._lenBufIO:   %s/%s\n' % (self._lenBufIO,
                                           len(self._bufIO.getvalue())))
        err('self._currFoPos:  %s\n' % self._currFoPos)
        err('self._readableYN: %s\n' % self._readableYN)
        err('self._writableYN: %s\n' % self._writableYN)
        err('self._closedYN:   %s\n' % self._closedYN)

    def write(self, s):
        """Write string to stream.
        """
        if self._closedYN:
            raise ValueError, "I/O operation on closed _StreamBuf object"
        if not self._writableYN:
            raise IOError, (9, "Can't write to a read only object")
        self._bufIO.write(s)
        if _StreamBuf.VERSION == 1:
            self._currFoPos = self.__checkInt(self._currFoPos)
        self._currFoPos = self._currFoPos + len(s)
        self.__mutexOnYN = 1
        self._lenBufIO = self._lenBufIO + len(s)
        self.__mutexOnYN = 0
        self.fo.write(self._refactorBufIO())

    def writelines(self, l):
        """Given list, concatenate and write.
        """
        if self._closedYN:
            raise ValueError, "I/O operation on closed _StreamBuf object"
        if not self._writableYN:
            raise IOError, (9, "Can't write to a read only object")
        for s in l:
            self.write(s)

    def seek(self, offset, where=0):
        """A limited seek method. See class __doc__ for more details.
        """
        if self._closedYN:
            raise ValueError, "I/O operation on closed _StreamBuf object"

        tell = self._bufIO.tell()
        beginBuf = self._currFoPos - tell
        endBuf = self._lenBufIO + beginBuf - 1

        # Offset from beginning?
        if not where:
            pass
        # Offset from current position?
        elif where == 1:
            if _StreamBuf.VERSION == 1:
                offset = self.__checkInt(offset)
            offset = self._currFoPos + offset
        # Offset from end?
        elif where == 2:
            if self._readableYN:
                if offset < 0 and offset < _StreamBuf.__ABS_MAX_BUFIO_SIZE:
                    raise IOError, (22, "Invalid argument; can't determine %s "
                               "position due to unknown stream length" % offset)
                # Could be ugly if, for example, a socket stream "never ends" ;)
                while self.read(_StreamBuf.__MAX_BUFIO_SIZE):
                    pass
                self._currFoPos = self._currFoPos + offset
                self._bufIO.seek(offset, 2)
                return
            elif self._writableYN:
                offset = endBuf + offset
        else:
            raise IOError, (22, "Invalid argument")
        if self._writableYN and offset > endBuf:
            offset = endBuf
        #
        # Offset reflects "from beginning of file" now.
        #
        if offset < 0:
            raise IOError, (22, "Invalid argument")
        delta = offset - self._currFoPos
        # Before beginning of buffer -- can't do it sensibly -- data gone.
        if offset < beginBuf:
            raise IOError, (22, "Invalid argument; attempted seek before "
                                "beginning of buffer")
        # After end of buffer.
        elif offset > endBuf:
            if self._readableYN:
                while delta:
                    x = min(_StreamBuf.__MAX_BUFIO_SIZE, delta)
                    self.read(x)
                    delta = delta - x
        # Within the buffer.
        else:
            self._bufIO.seek(tell + delta, 0)
            if _StreamBuf.VERSION == 1:
                self._currFoPos = self.__checkInt(self._currFoPos)
            self._currFoPos = self._currFoPos + self._bufIO.tell() - tell

    def tell(self):
        """Return current position in the file-like object.
        """
        return self._currFoPos

    def close(self):
        """Flush the buffer.
        NOTE: fileobject is NOT closed, just flushed. Mapping as closely as
              possible to GzipFile.
        """
        self.flush()
        self._closedYN = 1

    def flush(self):
        """Flush the buffer.
        """
        if self._closedYN:
            raise ValueError, "I/O operation on closed _StreamBuf object"
        if self._readableYN:
            pass
        if self._writableYN:
            self.fo.write(self._refactorBufIO(1))
        if _StreamBuf.VERSION == 1:
            # may seem a bit redundant, but want to easily cut this
            # stuff out someday.
            try:
                self.fo.flush()
            except AttributeError:
                pass
            return
        self.fo.flush()

    def __repr__(self):
        ret = ''
        if self._closedYN:
            ret = "<closed gzipstream._StreamBuf instance, mode '%s' at %s>" % \
                  (self.mode, id(self))
        else:
            ret = "<open gzipstream._StreamBuf instance, mode '%s' at %s>" % \
                  (self.mode, id(self))
        return ret

    # __private__

    def __checkInt(self, i):
        """Might be faster just to declare them longs.
           Python versions 1.5.2 & 2.1.* ONLY!
        """
        if i > _StreamBuf.__INT_CHECK_SIZE and type(i) == IntType:
            i = long(i)
        return i

    def __debugThread(self):
        """XXX: Only used for debugging. Runs a thread that watches some
           tell-tale warning flags that something bad is happening.
        """
        while not self._closedYN and not self.__mutexOnYN:
            if self._lenBufIO != len(self._bufIO.getvalue()):
                sys.stderr.write('XXX: ERROR! _lenBufIO != len(...): %s != %s\n'
                                % (self._lenBufIO, len(self._bufIO.getvalue())))
                sys.stderr.write('XXX:        %s\n' % repr(self))
            if self._lenBufIO > _StreamBuf.__ABS_MAX_BUFIO_SIZE*2:
                sys.stderr.write('XXX: ERROR! StringIO buffer WAY to big: %s\n'
                                 % self._lenBufIO)
                sys.stderr.write('XXX:        %s\n' % repr(self))
            time.sleep(1)

#-------------------------------------------------------------------------------
