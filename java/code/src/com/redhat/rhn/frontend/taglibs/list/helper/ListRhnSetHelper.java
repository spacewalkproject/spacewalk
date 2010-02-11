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
package com.redhat.rhn.frontend.taglibs.list.helper;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.commons.collections.CollectionUtils;

import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

/**
 * Used in creating rhnSet backed actions that tie into the "new" list tag (i.e. in the
 * http://rhn.redhat.com/tags/list taglib namespace).
 * <p/>
 * It is important to note that the exact set specified at instantiation may not be where
 * the items selected in the page are stored. For more information, see
 * {@link #setup(RhnSetDecl)} and <a href="https://fedorahosted.org/spacewalk/wiki/ListTag">
 * the Spacewalk wiki.</a>
 * <p/>
 * If the user selected items should be stored in a session rather than the database,
 * use {@link ListSessionSetHelper} instead.
 *
 * @author paji
 * @version $Rev$
 * @see ListSessionSetHelper
 */
public class ListRhnSetHelper extends ListSetHelper {

    /**
     * The actual set that will store the user selected entries in the list. This set
     * is created from the {@link #decl} attribute of the instance.
     */
    private RhnSet set;

    /**
     * Declaration of the set used to store user selected entries. See
     * {@link #setup(RhnSetDecl)} for details on how this declaration is determined.
     */
    private RhnSetDecl decl;

    /**
     * Helper instance, keyed to the request at instantiation, used for working with
     * the list itself.
     */
    private RhnListSetHelper helper;

    /**
     * Creates a new <code>ListRhnSetHelper</code> that will store its selected items
     * in a custom <code>RhnSet</code> determined by the given <code>RhnSetDecl</code>
     * plus the parameters in <code>params</code>
     * <p/>
     * Using a combination of the <code>RhnSetDecl</code> and parameters helps to scope
     * this instance for a dynamic page. For instance, if the page is scoped to a particular
     * channel, having the channel ID in this parameter map will allow the user to work
     * with in the same section of two different channels without the selections in each
     * list interfering with each other.
     *
     * @param inp     the listable
     * @param request the servlet request
     * @param declIn  declaration
     * @param params  the parameter map for this request
     */
    public ListRhnSetHelper(Listable inp, HttpServletRequest request,
                            RhnSetDecl declIn, Map params) {
        super(inp, request, params);
        setup(declIn);
    }


    /**
     * Creates a new <code>ListRhnSetHelper</code> that will store its selected items
     * in an <code>RhnSet</code> retrieved from the given <code>RhnSetDecl</code>. Care
     * should be taken in using this call to ensure there will only be one set of data
     * in this list at a time (see
     * {@link #ListRhnSetHelper(Listable, HttpServletRequest, RhnSetDecl, Map)} for a
     * use case in which this constructor would not be applicable).
     *
     * @param inp     the listable
     * @param request the servlet request
     * @param declIn  declaration
     */
    public ListRhnSetHelper(Listable inp, HttpServletRequest request,
                            RhnSetDecl declIn) {
        this(inp, request, declIn, Collections.EMPTY_MAP);
    }

    /**
     * Returns the actual <code>RhnSet</code> that was used to persist the user
     * selected items.
     *
     * @return will not be <code>null</code>
     */
    public RhnSet getSet() {
        return set;
    }

    /** {@inheritDoc} */
    public void destroy() {
        clear();
    }

    /** {@inheritDoc} */
    public String getDecl() {
        return decl.getLabel();
    }

    /** {@inheritDoc} */
    public Collection getAddedKeys() {
        Set preSelectedValues = getPreSelected();
        Set setValues = set.getElementValues();
        Collection result = CollectionUtils.subtract(preSelectedValues, setValues);
        return result;
    }

    /** {@inheritDoc} */
    public Collection getRemovedKeys() {
        Set setValues = set.getElementValues();
        Set preSelectedValues = getPreSelected();
        Collection result = CollectionUtils.subtract(setValues, preSelectedValues);
        return result;
    }

    /** {@inheritDoc} */
    protected void execute(List dataSet) {
        helper.execute(set, getListName(), dataSet);
    }

    /** {@inheritDoc} */
    protected Map getSelections() {
        Map<Long, Long> selections = new HashMap<Long, Long>();
        for (Long id : set.getElementValues()) {
            selections.put(id, id);
        }
        return selections;
    }

    /** {@inheritDoc} */
    protected int size() {
        return set.size();
    }

    /** {@inheritDoc} */
    protected void syncSelections(List dataSet) {
        helper.syncSelections(set, dataSet);

    }

    /** {@inheritDoc} */
    protected void update() {
        helper.updateSet(set, getListName());
    }

    /** {@inheritDoc} */
    protected void add(Set c) {
        for (Object elem : c) {
            set.addElement((Long) elem);
        }
        RhnSetManager.store(set);
    }

    /** {@inheritDoc} */
    protected void clear() {
        set.clear();
        RhnSetManager.store(set);
    }

    /**
     * Initializes this instance, determining the name of the set that will be used and
     * loading it.
     *
     * @param declIn basis for the set used to store user selections
     */
    private void setup(RhnSetDecl declIn) {
        RequestContext context = getContext();
        Map params = getParamMap();
        if (params.isEmpty()) {
            decl = declIn;
        }
        else {
            decl = declIn.createCustom(params.entrySet().toArray());
        }

        set = decl.get(context.getLoggedInUser());
        helper = new RhnListSetHelper(context.getRequest());
    }

}
