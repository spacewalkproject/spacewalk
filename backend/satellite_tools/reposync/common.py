import os
import re
import shutil
import sys
import time
from datetime import datetime

from spacewalk.server import rhnPackage, rhnSQL, rhnChannel
from spacewalk.common import fileutils, rhnLog
from spacewalk.common.rhnLog import log_debug
from spacewalk.common.checksum import getFileChecksum
from spacewalk.common.rhnConfig import CFG, initCFG
from spacewalk.server.importlib.importLib import IncompletePackage, Erratum, Bug, Keyword
from spacewalk.server.importlib.packageImport import ChannelPackageSubscription
from spacewalk.server.importlib.backendOracle import SQLBackend
from spacewalk.server.importlib.errataImport import ErrataImport
from spacewalk.server import taskomatic

default_log_location = '/var/log/rhn/reposync/'
relative_comps_dir = 'rhn/comps'
default_hash = 'sha256'
