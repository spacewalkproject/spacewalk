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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.Elaborator;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;

import org.apache.commons.lang.StringUtils;

import java.util.List;

import javax.servlet.http.HttpServletRequest;


/**
 * @author paji
 * @version $Rev$
 */
public abstract class WebList {
    private static final String LIST = "list";
    private static final String DATA_SET = "dataset";
    private RequestContext context;

    /**
     * Constructor
     * @param request servlet request
     */
    public WebList(HttpServletRequest request) {
        context = new RequestContext(request);
        setupDataSet();
    }

    protected RequestContext getContext() {
        return context;
    }

    protected List getDataSet() {
        return (List)context.getRequest().getAttribute(getDataSetName());
    }

    protected void setupDataSet() {
        List dataSet = getResult();
        HttpServletRequest request = context.getRequest();

        request.setAttribute(getDataSetName(), dataSet);
        if (!StringUtils.isBlank(getListName()) &&
                                    dataSet instanceof DataResult) {
            DataResult data = (DataResult) dataSet;
            Elaborator elab = data.getElaborator();
            if (elab != null) {
                TagHelper.bindElaboratorTo(getListName(),
                        elab, request);
            }
        }
    }

    /**
     * The dataresult associated to a set
     * @return a List of Selectable or Identifiable objects
     */
    protected abstract List getResult();

    /**
     * gets the list name
     * @return listname
     */
    protected String getListName() {
        return LIST;
    }

    /**
     * gets the DataSet Name
     * @return dataSetName
     */
    protected String getDataSetName() {
        return DATA_SET;
    }
}
