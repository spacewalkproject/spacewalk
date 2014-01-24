
import sys
import os
import subprocess
import xml.sax
import tempfile
import shutil
from base64 import encodestring
sys.path.append("/usr/share/rhn/")
from up2date_client import up2dateLog
from up2date_client import rhnserver
from up2date_client import up2dateAuth
from up2date_client import up2dateErrors

__rhnexport__ = [ 'xccdf_eval' ]

log = up2dateLog.initLog()

def xccdf_eval(args, cache_only=None):
    if cache_only:
        return (0, 'no-ops for caching', {})

    results_dir = None
    if ('id' in args) and ('file_size' in args) and args['file_size'] > 0:
        results_dir = tempfile.mkdtemp()
        pwd = os.getcwd()
        os.chdir(results_dir)

    results_file = tempfile.NamedTemporaryFile(dir=results_dir)
    params, oscap_err = _process_params(args['params'], results_file.name, results_dir)

    oscap_err += _run_oscap(['xccdf', 'eval'] + params + [args['path']])
    if results_dir:
        os.chdir(pwd)

    if not _assert_xml(results_file.file):
        del(results_file)
        _cleanup_temp(results_dir)
        return (1, 'oscap tool did not produce valid xml.\n' + oscap_err, {})

    ret, resume, xslt_err = _xccdf_resume(results_file.name, temp_dir=results_dir)
    if ret != 0 or resume == '':
        del(results_file)
        _cleanup_temp(results_dir)
        return (1, 'Problems with extracting resume:\n' + xslt_err, {})

    try:
        up_err = _upload_results(results_file, results_dir, args)
    except:
        # An error during the upload must not prevent scan completion
        log.log_exception(*sys.exc_info())
        up_err = "Upload of detailed results failed. Fatal error in Python code occurred"
    del(results_file)
    _cleanup_temp(results_dir)
    return (0, 'openscap scan completed', {
        'resume': encodestring(resume),
        'errors': encodestring(oscap_err + xslt_err + up_err)
        })

def _run_oscap(arguments):
    dev_null = open('/dev/null')
    c = _popen(['/usr/bin/oscap'] + arguments, stdout=dev_null.fileno())
    ret = c.wait()
    dev_null.close()
    errors = c.stderr.read()
    if ret != 0:
        errors += 'xccdf_eval: oscap tool returned %i\n' % ret
    log.log_debug('The oscap tool completed\n%s' % errors)
    return errors

def _xccdf_resume(results_file, temp_dir=None):
    xslt = '/usr/share/openscap/xsl/xccdf-resume.xslt'

    dev_null = open('/dev/null')
    resume_file = tempfile.NamedTemporaryFile(dir=temp_dir)
    c = _popen(['/usr/bin/xsltproc', '--output', resume_file.name,
            xslt, results_file], stdout=dev_null.fileno())
    ret = c.wait()
    dev_null.close()

    errors = c.stderr.read()
    if ret != 0:
        errors += 'xccdf_eval: xsltproc tool returned %i\n' % ret
    log.log_debug('The xsltproc tool completed:\n%s' % errors)

    resume = resume_file.read()
    del(resume_file)
    return ret, resume, errors

def _popen(args, stdout=subprocess.PIPE):
    log.log_debug('Running: ' + str(args))
    return subprocess.Popen(args, bufsize=-1, stdin=subprocess.PIPE,
        stdout=stdout, stderr=subprocess.PIPE, shell=False)

def _process_params(args, filename, results_dir=None):
    params = ['--results', filename]
    if results_dir:
        params += ['--oval-results', '--report', 'xccdf-report.html']
    errors = ''
    if args:
        allowed_args = {
            '--profile': 1,
            '--skip-valid': 0,
            '--cpe': 1,
            '--fetch-remote-resources': 0,
            '--datastream-id': 1,
            '--xccdf-id': 1,
            '--tailoring-id': 1,
            '--tailoring-file': 1,
            }
        args = args.split(' ')
        i = 0
        while i < len(args):
            if args[i] in allowed_args:
                j = i + allowed_args[args[i]]
                params += args[i:j+1]
                i = j
            elif not errors:
                errors = 'xccdf_eval: Following arguments forbidden: ' + args[i]
            else:
                errors += ' ' + args[i]
            i += 1
    if errors:
        errors += '\n'
    return params, errors

def _upload_results(xccdf_result, results_dir, args):
    errors = ''
    if results_dir:
        server = rhnserver.RhnServer()
        # No need to check capabilities. The server supports detailed results
        # If rhe 'file_size' and 'id' was in supplied in the argument list.
        systemid = up2dateAuth.getSystemId()
        for filename in os.listdir(results_dir):
            path = os.path.join(results_dir, filename)
            if path == xccdf_result.name:
                f = xccdf_result.file
                filename = "xccdf-results.xml"
            else:
                f = open(path, 'r')
            errors += _upload_file(server, systemid, args, path, filename, f)
            if path != xccdf_result.name:
                f.close()
    return errors

def _upload_file(server, systemid, args, path, filename, f):
    if filename != 'xccdf-report.html' and not _assert_xml(f):
        log.log_debug('Excluding "%s" file from upload. Not an XML.' % path)
        return '\nxccdf_eval: File "%s" not uploaded. Not an XML file format.' % filename

    stat = os.fstat(f.fileno())
    if stat.st_size < args['file_size']:
        try:
            ret = server.scap.upload_result(systemid, args['id'],
                         {'filename': filename,
                          'filecontent': encodestring(f.read()),
                          'content-encoding': 'base64',
                         })
            if ret and ret['result']:
                log.log_debug('The file %s uploaded successfully.' % filename)
            return ''
        except up2dateErrors.Error, e:
            log.log_exception(*sys.exc_info())
            return '\nxccdf_eval: File "%s" not uploaded. %s' % (filename, e)
    else:
        return '\nxccdf_eval: File "%s" not uploaded. File size (%d B) exceeds the limit.' \
            % (filename, stat.st_size)

def _cleanup_temp(results_dir):
    if results_dir:
        shutil.rmtree(results_dir)

def _assert_xml(f):
    try:
        try:
            xml.sax.parse(f, xml.sax.ContentHandler())
            return True
        except Exception, e:
            log.log_exception(*sys.exc_info())
            return False
    finally:
        f.seek(0)
