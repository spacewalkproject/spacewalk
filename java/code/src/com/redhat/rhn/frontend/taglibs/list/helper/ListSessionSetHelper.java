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

import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.SessionSetHelper;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.StringUtils;

import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;


/**
 * Used in creating web session backed actions that tie into the "new" list tag (i.e. in the
 * http://rhn.redhat.com/tags/list taglib namespace).
 * <p/>
 * If the user selected items need to be more persistant than simply the session, use
 * {@link ListRhnSetHelper} instead.
 *
 * @author paji
 * @version $Rev$
 * @see ListRhnSetHelper
 */
public class ListSessionSetHelper extends ListSetHelper {

    /** Holds on to the user selected items. */
    private Set<String> set;

    /**
     * Helper instance, keyed to the request at instantiation, used for working with
     * the list itself.
     */
    private SessionSetHelper helper;

    /** Effectively the name of the data set, used to keep different sets of data unique. */
    private String decl;

    /**
     * Creates a new <code>ListSessionSetHelper</code> that will use the given prefix
     * as the uniqueness indicator for tracking the set data.
     * <p/>
     * It is important that if the value chosen for the prefix is unique across all actions
     * to prevent a conflict in storing user selected values.
     *
     * @param inp        listable
     * @param req        the servlet request
     * @param params     the parameter map for this request
     * @param declPrefix the declaration prefix needed to make this set declaration unique
     */
    public ListSessionSetHelper(Listable inp, HttpServletRequest req,
                                Map params, String declPrefix) {
        super(inp, req, params);
        setup(declPrefix);
    }

    /**
     * Creates a new <code>ListSessionSetHelper</code> that will attempt to generate
     * its own unique name for the set combined with the values of the request parameters.
     * <p/>
     * Using a combination of a standard prefix (determined by the <code>Listable</code>
     * parameter value) and parameters helps to scope this instance for a dynamic page.
     * For instance, if the page is scoped to a particular channel, having the channel ID
     * in this parameter map will allow the user to work with in the same section of two
     * different channels without the selections in each list interfering with each other.
     *
     * @param inp    listable
     * @param req    the servlet request
     * @param params the parameter map for this request
     */
    public ListSessionSetHelper(Listable inp, HttpServletRequest req, Map params) {
        this(inp, req, params, inp.getClass().getName());
    }


    /**
     * Creates a new <code>ListSessionSetHelper</code> that will attempt to generate
     * its own unique name for the set. This call is suitable when there are no request
     * parameters of interest for the page.
     *
     * @param inp listable
     * @param req the servlet request
     */
    public ListSessionSetHelper(Listable inp, HttpServletRequest req) {
        this(inp, req, Collections.EMPTY_MAP);
    }

    /** {@inheritDoc} */
    public void destroy() {
        SessionSetHelper.obliterate(getContext().getRequest(), getDecl());
    }

    /** {@inheritDoc} */
    public String getDecl() {
        return decl;
    }

    /** {@inheritDoc} */
    public Collection getAddedKeys() {
        Set preSelected = getPreSelected();
        Collection result = CollectionUtils.subtract(set, preSelected);
        return result;
    }

    /** {@inheritDoc} */
    public Collection getRemovedKeys() {
        Set preSelected = getPreSelected();
        Collection result = CollectionUtils.subtract(preSelected, set);
        return result;
    }

    /**
     * Returns the set that was used to store user selected items. This is the actual set
     * itself; a copy should be made before attempting to manipulate the contents.
     *
     * @return will not be <code>null</code>
     */
    public Set<String> getSet() {
        return set;
    }

    /** {@inheritDoc} */
    protected Map getSelections() {
        Map<Long, Long> selections = new HashMap<Long, Long>();
        for (Object id : set) {
            Long item = Long.valueOf(id.toString());
            selections.put(item, item);
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
        set.addAll(c);
    }

    /** {@inheritDoc} */
    protected void clear() {
        set.clear();
    }

    /** {@inheritDoc} */
    protected void execute(List dataSet) {
        helper.execute(set, getListName(), dataSet);
    }

    /**
     * Initializes this instance, determining the name of the set that will be used
     * and instantiating it.
     *
     * @param prefix basis for the generation of a unique set name
     */
    private void setup(String prefix) {
        RequestContext context = getContext();
        helper = new SessionSetHelper(context.getRequest());

        if (StringUtils.isBlank(prefix)) {
            prefix = getListable().getClass().getName();
        }
        decl = prefix;

        Map params = getParamMap();
        if (!params.isEmpty()) {
            decl = decl + params.hashCode();
        }

        set = SessionSetHelper.lookupAndBind(context.getRequest(),
            decl);

    }

}
