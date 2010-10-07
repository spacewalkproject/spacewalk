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
package com.redhat.rhn.internal.jasper2;

import java.io.File;
import org.apache.jasper.JasperException;
import org.apache.jasper.JspC;

/**
 * Helper TaskDef which compiles jsp AND jspf files.
 *
 * Instead using default Tomcat 5.5+ JspC Jasper2 Compiler we
 * use our version which extends it. It has the very same
 * functionality but it also compiles *.jspf Struts files.
 *
 * @author Lukas Zapletal
 */
public class JspfC extends JspC {

    /**
     * Overriden scanFiles method from Jasper2 JSP Compiler. To jsp and jspx
     * extensions it adds additional one (jspf) which we use for our
     * fragment files.
     */
    @Override
    public void scanFiles(File file) throws JasperException {
        addExtension("jsp");
        addExtension("jspf");
        addExtension("jspx");
        super.scanFiles(file);
    }
}
