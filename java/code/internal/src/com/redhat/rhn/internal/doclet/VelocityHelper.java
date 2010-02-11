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

import java.io.StringReader;
import java.io.StringWriter;
import java.util.Calendar;
import java.util.Properties;

import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.Velocity;
import org.apache.velocity.app.VelocityEngine;

/**
 * 
 * VelocityHelper
 * @version $Rev$
 */
public class VelocityHelper {
    
    private VelocityEngine ve = new VelocityEngine();
    private VelocityContext context = new VelocityContext();
    
    /**
     * Constructor to be used when using a template file
     * @param templateDir the template directory
     * @throws Exception e
     */
    public VelocityHelper(String templateDir) throws Exception {
        Properties p = new Properties();
        p.setProperty("file.resource.loader.path", templateDir);
        ve.init(p);
        
    }
    
    /**
     * Constructor used when the template will be passed in
     * @throws Exception e
     */
    public VelocityHelper() throws Exception {
    }
 
    
    
    /**
     * adds a template match to teh helper
     * @param key what to find
     * @param value what to replace with
     */
    public void addMatch(String key, Object value) {
        context.put(key, value);
    }
    
    /**
     * render the template according to a template file
     * @param fileName the filename
     * @return the rendered template
     * @throws Exception e
     */
    public String renderTemplateFile(String fileName) throws Exception {
        Template t = ve.getTemplate(fileName);
        StringWriter writer = new StringWriter();
        Calendar cal = Calendar.getInstance();
        
        String date = (cal.get(Calendar.MONTH) + 1) + "/" + 
                 cal.get(Calendar.DAY_OF_MONTH) +  
                 "/" + cal.get(Calendar.YEAR);
        
        context.put("current_date", date);
        t.merge(context, writer);
        return writer.toString();
    }
    
    
    
    
    /**
     * render the template according to what we've added to addMatch
     * @param template the template
     * @return the rendered template
     * @throws Exception e
     */
    public String renderTemplate(String template) throws Exception {
        StringWriter writer = new StringWriter();
        StringReader reader = new StringReader(template);
        
        Velocity.evaluate(context, writer, "a", reader);             
        
        return writer.toString();
    }
   
}
