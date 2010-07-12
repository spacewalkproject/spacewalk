#
# Copyright (c) 2010 Red Hat, Inc.
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


from wsgi import wsgiRequest

from common import log_debug

def handle(environ, start_response, server, component_type, type="server.apacheServer"):
    #wsgi seems to capitalize incoming headers and add HTTP- to the front :/
    # so we strip out the first 5 letters, and transform it into what we want.
    replacements = {'_':'-', 'Rhn':'RHN', 'Md5Sum':'MD5sum', 'Xml':'XML'}
    for key in environ.keys():
         if key[:5] == "HTTP_":
             new_key = key[5:].title()
             for k,v in replacements.iteritems():
                 new_key = new_key.replace(k,v)
             environ[new_key] = environ[key]



    req = wsgiRequest.WsgiRequest(environ, start_response)
    req.set_option("SERVER", server)
    req.set_option("RHNComponentType", component_type)
    req.set_option("RootDir", "/usr/share/rhn")

    parseServ = get_handle(type, "HeaderParserHandler", init=1)
    ret = parseServ(req)

    if len(req.output) > 0:
        if not req.sent_header:
            req.send_http_header(status=ret)
        return req.output

    appServ = get_handle(type, "Handler")
    ret = appServ(req)

    if not ret:
       ret = None

    if not req.sent_header:
        req.send_http_header(status=ret)

    #exporter doesn't have a logHandler
    if type != 'satellite_exporter.satexport':
        logServ = get_handle(type, "LogHandler")
        logServ(req)
    cleanServ = get_handle(type, "CleanupHandler")
    cleanServ(req)

    return req.output

def get_handle(type, name, init=0):
    handler_module = __import__(type, globals(), locals(), [type.split('.')[-1]])
    return getattr(handler_module, name)

