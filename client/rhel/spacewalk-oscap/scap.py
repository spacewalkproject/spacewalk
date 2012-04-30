
import sys
import subprocess
import xml.sax
import tempfile
from base64 import encodestring
sys.path.append("/usr/share/rhn/")
from up2date_client import up2dateLog

__rhnexport__ = [ 'xccdf_eval' ]

log = up2dateLog.initLog()

def xccdf_eval(args, cache_only=None):
    if cache_only:
        return (0, 'no-ops for caching', {})

    results_file = tempfile.NamedTemporaryFile()
    if args['params']:
        oscap_err = _run_oscap(['xccdf', 'eval', '--results', results_file.name]
            + args['params'].split(' ') + [args['path']])
    else:
        oscap_err = _run_oscap(['xccdf', 'eval', '--results', results_file.name]
            + [args['path']])

    if not _assert_xml(results_file.name):
        return (1, 'oscap tool did not produce valid xml.\n' + oscap_err, {})

    ret, resume, xslt_err = _xccdf_resume(results_file.name)
    del(results_file)
    if ret != 0 or resume == '':
        return (1, 'Problems with extracting resume:\n' + xslt_err, {})
    return (0, 'openscap scan completed', {
        'resume': encodestring(resume),
        'errors': encodestring(oscap_err + xslt_err)
        })

def _run_oscap(arguments):
    c = _popen(['/usr/bin/oscap'] + arguments)
    ret = c.wait()
    errors = c.stderr.read()
    if ret != 0:
        errors += 'xccdf_eval: oscap tool returned %i\n' % ret
    log.log_debug('The oscap tool completed\n%s' % errors)
    return errors

def _xccdf_resume(results_file):
    xslt = '/usr/share/openscap/xsl/xccdf-resume.xslt'
    c = _popen(['/usr/bin/xsltproc', xslt, results_file])
    ret = c.wait()
    errors = c.stderr.read()
    if ret != 0:
        errors += 'xccdf_eval: xsltproc tool returned %i\n' % ret
    log.log_debug('The xsltproc tool completed:\n%s' % errors)
    return ret, c.stdout.read(), errors

def _popen(args):
    log.log_debug('Running: ' + str(args))
    return subprocess.Popen(args, bufsize=-1, stdin=subprocess.PIPE,
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=False)

def _assert_xml(filename):
    f = open(filename, 'rb')
    try:
        try:
            xml.sax.parse(f, xml.sax.ContentHandler())
            return True
        except:
            return False
    finally:
        f.close()

