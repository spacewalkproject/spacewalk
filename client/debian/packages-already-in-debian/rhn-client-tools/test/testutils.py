#!/usr/bin/python

import os,sys
import getopt
import string
import shutil
import glob


DBPATH="/tmp/testdb"
DBCACHEPATH="/tmp/testdbcaches/"
UP2DATE_COMMAND="up2date --justdb --dbpath $DBPATH"
DATAPATH="/tmp/datadir"
TOPDIR="../"
DBDIR="%s/testdbs" % "/usr/src/rhn/test/up2date/depsolve/" 
PKGDIR="%s/testpackages" % "/usr/src/rhn/test/up2date/rollbacks/"
RESULTSPATH="%s/results/" % (TOPDIR)
CONFIGPATH="%s/configs" % "/usr/src/rhn/test/up2date/depsolve/"
REPACKAGEDIR="/tmp/testrepackage"
PLATFORMPATH="/etc/rpm/platform"

def createDbDir():
    # remove the old if its there
    try:
        shutil.rmtree(DBPATH)
    except OSError:
        #whatever...
        print "%s doesnt exist, creating it" % DBPATH
        pass
    
    # make the new
    if not os.access(DBPATH, os.W_OK):
        os.makedirs(DBPATH)

def createRepackageDir():
   # remove the old if its there
    try:
        shutil.rmtree(REPACKAGEDIR)
    except OSError:
        #whatever...
        print "%s doesnt exist, creating it" % REPACKAGEDIR
        pass
    
    # make the new
    if not os.access(REPACKAGEDIR, os.W_OK):
        os.makedirs(REPACKAGEDIR)



def createDataDirs():
    createDbDir()
    createRepackageDir()
        
    if not os.access(DATAPATH, os.W_OK):
        os.makedirs(DATAPATH)


def rebuildRepackageDir(repackageName):
    createRepackageDir()
    files = glob.glob("%s/%s/*.rpm" % (PKGDIR, repackageName))
    for file in files: 
    	shutil.copy(file , REPACKAGEDIR)


# fetch a copy of the rebuild db from the cache if we have it
def lookForDbCache(dbname):
    if not os.access("%s/%s" % (DBCACHEPATH, dbname), os.R_OK):
	return 1

    #print "Using db cache"
    files = glob.glob("%s/%s/*" % (DBCACHEPATH, dbname))
    for file in files:
	shutil.copy(file, DBPATH)

    return 0

def populateDbCache(dbname):
    cache = "%s/%s" % (DBCACHEPATH, dbname)
    os.makedirs(cache)
    files = glob.glob("%s/*" % DBPATH)
    for file in files:
	shutil.copy(file, cache)

def rebuildRpmDatabase(dbname):
    createDbDir()
	
    if lookForDbCache(dbname):
	print "Rebuilding rpm database"
    	shutil.copy("%s/%s/Packages" % (DBDIR,dbname) , DBPATH)
    	cmdline = "rpm -v --dbpath %s  --rebuilddb" % DBPATH
    	fd = os.popen(cmdline)
    	fd.read()
    	fd.close()
	
	populateDbCache(dbname)




def buildUp2dateCommand(options):
    ret = "up2date --justdb --dbpath %s %s" % (DBPATH, options)
    return ret

def getRpmQAList():
    cmdline = "rpm --dbpath %s -qa" % DBPATH
    fd = os.popen(cmdline)
    tmp = fd.readlines()
    out = map(lambda a:string.strip(a), tmp)
    
    fd.close()
    return out

def runUp2date(cmd):
    fd = os.popen(cmd)
    ret = fd.read()
    fd.close()
    return ret

def storeResults(results,testname, type):
    if type == "pre":
        fd = open("%s/%s.pre" % (DATAPATH,testname), "w")
        fd.write(string.join(results,"\n"))
        fd.close()
    if type == "after":
        fd = open("%s/%s.post" % (DATAPATH,testname), "w")
        fd.write(string.join(results, "\n"))
        fd.close()

def saveUp2dateOut(up2dateOut,testname):
    fd = open("%s/%s.up2date-out" % (DATAPATH,testname), "w")
    fd.write(up2dateOut)
    fd.close()

FILENAMES = ['/etc/sysconfig/rhn/up2date',
            '/etc/sysconfig/rhn/systemid',
            '/etc/sysconfig/rhn/sources',
            '/etc/sysconfig/rhn/network']


def setupConfig(configname):
    # copy over the approriate up2date and systemid
    # to /etc/sysconfig/rhn

    path = "%s/%s" % (CONFIGPATH, configname)
    for filename in FILENAMES:
        # store a backup of the original if it doesnt exist yet
        if os.access(filename, os.R_OK) and \
               not os.access("%s..orig-test" % filename, os.R_OK):
            shutil.copy(filename, "%s.orig-test" % filename)

	stored = "%s/%s" % (path, os.path.basename(filename))
    	if os.access(stored, os.R_OK):
            shutil.copy(stored, filename)


def restoreConfig():
    for filename in FILENAMES:
    	if os.access("%s.orig-test" % filename, os.R_OK):
            shutil.copy("%s.orig-test" % filename, filename)

def logFailures(name):
    fd = open("%s/FAILURES" % DATAPATH, "w+")
    fd.write("%s\n" % name)
    fd.close()
    
def runTestcase(testcase):
    print "Generating an rpm db in %s based on %s" % (DBPATH, "%s/%s" % (DBDIR,testcase.dbname))
    rebuildRpmDatabase(testcase.dbname)
    cmd = buildUp2dateCommand(testcase.options)
    beforeList = getRpmQAList()
    storeResults(beforeList, testcase.name, "pre")
    setupConfig(testcase.configs)
    print "running up2date as:\n%s" % cmd
    up2dateOut = runUp2date(cmd)
    saveUp2dateOut(up2dateOut,testcase.name)
    afterList = getRpmQAList()
    storeResults(afterList, testcase.name, "after")
    print "diff between before/after"
    compareBeforeAfter(beforeList, afterList)
    print "diff between results and expected results"
    try:
        ret = compareResults(testcase.results, afterList)
    except "NoResultsError":
        print "\n\nNo results listing (%s) was found for this test (%s)\n\n" % (testcase.results, testcase.name)
        ret = 1
    print ret
    if ret:
        print "\n----------- This Case (%s) Failed --------------" % testcase.name
        print "cmd"
        print "dbname: %s results: %s" % (testcase.dbname, testcase.results)
        print "\n\n"
        logFailures(testcase.name)
#    restoreConfig()

def difflists(list1, list2):
    in1_not_in2 = []
    in2_not_in1 = []
    for i in list1:
        if i not in list2:
            in1_not_in2.append(i)

    for i in list2:
        if i not in list1:
            in2_not_in1.append(i)

    return (in1_not_in2, in2_not_in1)

def compareBeforeAfter(before, after):
#    print before
#    print after
    deleted, added = difflists(before, after)
    print "added: %s" % added
    print "deleted: %s" % deleted


def compareResults(resultsName, afterList):
    #open the results file and read it in
    resultsFile = "%s/%s" % (RESULTSPATH, resultsName)
    if not os.access(resultsFile, os.R_OK):
        raise "NoResultsError"
    
    fd = open("%s/%s" % (RESULTSPATH, resultsName), "r")
    expected = fd.readlines()
    expected.sort()
    tmp = map(lambda a:string.strip(a), expected)
    expected = tmp
    afterList.sort()
    deleted, added = difflists(afterList, expected)
    print "epected but not found: %s" % added
    print "not expected, but found: %s" % deleted
    if len(deleted) == 0 and len(added) == 0:
        return 0
    else:
        return 1

            


    
class Testcase:
    def __init__(self, name=None, dbname=None,
                 configs=None, results=None, options=None):
        self.name = name
        self.dbname = dbname
        self.configs = configs
        self.options = options
        self.results = results
    def __repr__(self):
        out = ""
        out = out + "name: %s " % self.name
        out = out + "dbname: %s " % self.dbname
        out = out + "configs: %s " % self.configs
        out = out + "results: %s" % self.results
        out = out + "options: %s " % self.options
        return out
    
testcases = []
testcasenames = []
def parsefile(m):
    while 1:
        s = m.readline()
        if not len(s):
            break    
        s = s[:-1]
        if not s:
            continue
        s = string.strip(s) # remove whitespace
        if s[0] == '#':
            continue
        line = string.split(s, ':')
        testcasename = string.strip(line[0])
        dbname = string.strip(line[1])
        configs = string.strip(line[2])
        results = string.strip(line[3])
        options = string.strip(line[4])

        testcase = Testcase(testcasename, dbname, configs, results, options)
        testcases.append(testcase)
        testcasenames.append(testcase.name)


def main():
    testcasename = None
    printlist = None

    opts, args = getopt.getopt(sys.argv[1:], "f:l",
                               ["filename=", "list"])
    for opt, val in opts:
        if opt == "--filename" or opt == "-f":
            filename = val
        if opt == "--list" or opt == "-l":
            printlist = 1
            print "Available test cases include:"
            print testcasenames
            for i in testcasenames:
                print "%s" % i

    #testcasename = args

    fd = open(filename, "r")
    parsefile(fd)
    #print testcases

    if printlist:
        print "Available test cases include:"
        for i in testcasenames:
            print "%s" % i
        sys.exit()

    createDataDirs()

    # accept a list of test cases, including filename style globs
    if args:
        import fnmatch
        matchedtestcases = []
        for testcasename in args:
            for testcase in testcasenames:
                if fnmatch.fnmatch(testcase, testcasename):
                    matchedtestcases.append(testcase)

        #uniq the list
        tmp = {}
        for i in matchedtestcases:
            tmp[i] = i

        matchedtestcases = tmp.keys()
        matchedtestcases.sort()

        for testcase in matchedtestcases:
            print "going to run testcases: %s" % testcase

        for testcase in matchedtestcases:
            print "running testcase: %s" % testcase
            runTestcase(testcases[testcasenames.index(testcase)])

    if not testcasenames:
        for testcase in testcases:
            runTestcase(testcase)
    #else:
    #    print "running testcase: %s" % testcasename
    #    runTestcase(testcases[testcasenames.index(testcasename)])


