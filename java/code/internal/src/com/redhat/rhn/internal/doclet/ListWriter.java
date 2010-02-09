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

import com.sun.javadoc.Parameter;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.util.List;
import java.util.Map;

/**
 * Writes a  list of api calls that are used
 * ListWriter
 * @version $Rev$
 */
public class ListWriter extends DocWriter {
    
    
    private static final String LIST_OUT = "./build/reports/apidocs/apilist.txt";
    
    /**
     * 
     * {@inheritDoc}
     */
    public void write(List<Handler> handlers, 
            Map<String, String> serializers) throws Exception {
        
        FileWriter fstream = new FileWriter(LIST_OUT);
        BufferedWriter out = new BufferedWriter(fstream);
        
        for (Handler handler : handlers) {
            for (ApiCall call : handler.getCalls()) {
                out.write(handler.getName() + "." + call.getName() + " " + 
                        call.getMethod().parameters().length + " ");
                
                for (Parameter param : call.getMethod().parameters()) {
                    out.write(param.type().typeName() + " ");
                }
                out.write("\n");
                
            }
        }
        out.close();
    }
    
}
