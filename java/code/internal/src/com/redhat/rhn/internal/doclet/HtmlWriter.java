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

import java.util.List;
import java.util.Map;

/**
 * 
 * JSPWriter
 * @version $Rev$
 */
public class HtmlWriter extends DocWriter {

    
    private static final String JSP_OUTPUT = "./build/reports/apidocs/html/";
    private static final String JSP_TEMPLATES = "./buildconf/apidoc/html/";
    
    
    private static final String[] OTHER_FILES = {"faqs", "scripts"};
    
    /**
     * 
     * {@inheritDoc}
     */
    public void write(List<Handler> handlers, 
            Map<String, String> serializers) throws Exception {

        

        //First macro-tize the serializer's docs
        renderSerializers(JSP_TEMPLATES, serializers);
        
        
        //Lets do the index first
        writeFile(JSP_OUTPUT + "index.html", generateIndex(handlers, JSP_TEMPLATES));
        
        for (Handler handler : handlers) {
            writeFile(JSP_OUTPUT + "handlers/" + handler.getClassName() + ".html",
                    generateHandler(handler, JSP_TEMPLATES));
        }
 
        for (String file : OTHER_FILES) {
            writeFile(JSP_OUTPUT + file + ".html", readFile(JSP_TEMPLATES + file + ".txt"));
        }
        
    }
    
    
}
