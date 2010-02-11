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
package com.redhat.rhn.common.db.datasource;


import java.util.List;
import java.util.Map;


/**
 * ModeElaborator
 * @version $Rev$
 */
public class ModeElaborator implements Elaborator {
    private SelectMode mode;
    private Map params;
    
    /**
     * @param select Select mode
     * @param elabParams elaborator params
     */
    public ModeElaborator(SelectMode select, Map elabParams) {
        mode = select;
        params = elabParams;
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public void elaborate(List objectsToElaborate) {
        mode.elaborate(objectsToElaborate, params);
    }
}
