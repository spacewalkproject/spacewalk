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

package com.redhat.rhn.frontend.taglibs.list.collection;

import com.redhat.rhn.frontend.struts.SessionSetHelper;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;


/**
 * @author paji
 * ListSessionSetHelper.java
 * @version $Rev$
 */
public abstract class WebSessionSet extends SelectableWebList {
    private Set set;
    private SessionSetHelper helper;
    /**
     * Constructor
     * @param request Servlet request
     */
    public WebSessionSet(HttpServletRequest request) {
        super(request);
    }

    @Override
    protected void setup() {
        HttpServletRequest request = getContext().getRequest();
        helper = new SessionSetHelper(request);
        set = SessionSetHelper.lookupAndBind(request, getDecl());
        super.setup();
    }

    protected void clear() {
        set.clear();
    }

    protected void execute(List dataSet) {
        helper.execute(set, getListName(),
                dataSet);
    }

    protected int size() {
        return set.size();
    }

    protected void obliterate() {
        SessionSetHelper.obliterate(getContext().getRequest(),
                                        getDecl());
    }

    protected void syncSelections(List dataSet) {
        helper.syncSelections(set, dataSet);
    }

    protected Map getSelections() {
        Map selections = new HashMap<Long, Long>();
        for (Object id : set) {
            Long item = Long.valueOf(id.toString());
            selections.put(item, item);
        }
        return selections;
    }

    protected void update() {
       helper.updateSet(set, getListName());
    }

    /**
     * @return returns the set
     * assoctiated to this class
     */
    public Set getSet() {
        return set;
    }
}
