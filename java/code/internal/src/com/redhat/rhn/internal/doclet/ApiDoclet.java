/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 */

package com.redhat.rhn.internal.doclet;

import com.sun.javadoc.ClassDoc;
import com.sun.javadoc.MethodDoc;
import com.sun.javadoc.RootDoc;
import com.sun.javadoc.Tag;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


/**
 *
 * TestDoclet
 * @version $Rev$
 */
public class ApiDoclet {

    private static final String XMLRPC_DOC = "@xmlrpc.doc";
    private static final String XMLRPC_PARAM = "@xmlrpc.param";
    private static final String XMLRPC_RETURN = "@xmlrpc.returntype";
    private static final String XMLRPC_NAMESPACE = "@xmlrpc.namespace";
    private static final String XMLRPC_IGNORE = "@xmlrpc.ignore";
    private static final String DEPRECATED = "@deprecated";
    private static final String SINCE = "@since";

    public static final String API_MACROS_FILE = "macros.txt";
    public static final String API_HANDLER_FILE = "handler.txt";
    public static final String API_INDEX_FILE = "apiindex.txt";
    public static final String API_FOOTER_FILE = "api_index_ftr.txt";
    public static final String API_HEADER_FILE = "api_index_hdr.txt";

    protected ApiDoclet() {
    }

    /**
     * start the doclet
     * @param root the document root
     * @param docType 'jsp' or 'wiki'
     * @return boolean
     * @throws Exception e
     */
    public static boolean start(RootDoc root, String docType) throws Exception {
        ClassDoc[] classes = root.classes();

        List<ClassDoc> serializers = getSerializers(classes);
        List<ClassDoc> handlers = getHandlers(classes);
        Map<String, String> serialMap = getSerialMap(serializers);
        List<Handler> handlerList = new ArrayList<Handler>();

        for (ClassDoc clas : handlers) {
            Handler handler = new Handler();

            if (clas.tags(XMLRPC_IGNORE).length > 0) {
                continue;
            }

            Tag name = getFirst(clas.tags(XMLRPC_NAMESPACE));
            if (name != null) {
                handler.setName(name.text());
            }
            else {
                String error = "Someone didn't set " + XMLRPC_NAMESPACE +
                " correctly on " + clas.name();
                error += "  If you really did not want this handler to appear in " +
                        "the API docs.  Add @xmlrpc.ignore to the class javadoc. ";
                throw new Exception(error);

            }
            handler.setClassName(clas.name());

            Tag classDesc = getFirst(clas.tags(XMLRPC_DOC));
            if (classDesc != null) {
                handler.setDesc(classDesc.text());
            }

            for (MethodDoc method : clas.methods()) {
                    if (method.isPublic() && getFirst(method.tags(XMLRPC_IGNORE)) == null) {

                        ApiCall call = new ApiCall(method);
                        call.setName(method.name());

                        Tag methodDoc = getFirst(method.tags(XMLRPC_DOC));
                        if (methodDoc != null) {
                            call.setDoc(methodDoc.text());
                        }

                        for (Tag param : method.tags(XMLRPC_PARAM)) {
                            call.addParam(param.text());
                        }

                        if (method.tags(DEPRECATED).length > 0) {
                            call.setDeprecated(true);
                            call.setDeprecatedVersion(getFirst(
                                    method.tags(DEPRECATED)).text());
                        }

                        if (method.tags(SINCE).length > 0) {
                            call.setSinceAvailable(true);
                            call.setSinceVersion(getFirst(
                                    method.tags(SINCE)).text());
                        }

                        Tag tag = getFirst(method.tags(XMLRPC_RETURN));
                        if (tag != null) {
                            //run templating on the return value
                            //call.setReturnDoc(serialHelper.renderTemplate(tag.text()));
                            call.setReturnDoc(tag.text());
                        }

                        //Finally add the newly built api to the handler
                        handler.addApiCall(call);
                    }
            }
            //Then simply sort the apicalls and add the handler to our List
            Collections.sort(handler.getCalls());
            handlerList.add(handler);
        }
        Collections.sort(handlerList);
        DocWriter writer;
        if (docType.equals("jsp")) {
            writer = new JSPWriter();
        }
        else if (docType.equals("html")) {
            writer = new HtmlWriter();
        }
        else if (docType.equals("list")) {
            writer = new ListWriter();
        }
        else if (docType.equals("singlepage")) {
            writer = new SinglePageWriter();
        }
        else {
            writer = new JSPWriter();
        }
        writer.write(handlerList, serialMap);

        return true;
    }

    private static List<ClassDoc> getSerializers(ClassDoc[] classes) {
        List<ClassDoc> serializers = new ArrayList<ClassDoc>();
        for (ClassDoc clas : classes) {

            if (implInterface("XmlRpcCustomSerializer", clas)) {
                serializers.add(clas);
            }
        }
        return serializers;
    }

    private static Map<String, String> getSerialMap(List<ClassDoc> classes) {
        Map<String, String> map  = new HashMap<String, String>();

        for (ClassDoc clas : classes) {
            Tag tag = getFirst(clas.tags(XMLRPC_DOC));
            if (tag != null) {
                map.put(clas.name(), tag.text());
            }
        }

        return map;
    }


    private static List<ClassDoc> getHandlers(ClassDoc[] classes) {
        List<ClassDoc> handlers = new ArrayList<ClassDoc>();
        for (ClassDoc clas : classes) {
            if (clas.superclass() != null) {
                if (clas.superclass().name().equals("BaseHandler")) {
                    handlers.add(clas);
                }
            }
        }

        Collections.sort(handlers);
        return handlers;
    }

    private static boolean implInterface(String iface, ClassDoc clas) {
        ClassDoc[] interfaces = clas.interfaces();
        for (ClassDoc interf : interfaces) {
           //System.out.println(interf.name() + " " + clas);
            if (interf.name().equals(iface)) {
                return true;
            }
        }
        return false;
    }

    private static Tag getFirst(Tag[] tags) {
        if (tags.length > 0) {
            return tags[0];
        }
        else {
            return null;
        }
    }
}
