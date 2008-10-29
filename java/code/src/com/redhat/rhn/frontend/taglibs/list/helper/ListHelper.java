/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.Elaborator;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;

import org.apache.commons.collections.map.HashedMap;
import org.apache.commons.lang.StringUtils;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;


/**
 * @author paji
 * @version $Rev$
 */
public class ListHelper {
    public static final String DATA_SET = "dataset";
    public static final String LIST = "list";
    private Listable listable;
    private String dataSetName = DATA_SET;
    private String listName = LIST;
    private String parentUrl;
    private RequestContext context;
    private Map paramMap = new HashedMap();
    /**
     * constructor
     * @param inp takes in a Listable Object.
     * @param request http servlet request
     * @param params the parameter map for this request
     */
    public ListHelper(Listable inp, HttpServletRequest request, Map params) {
        listable = inp;
        context = new RequestContext(request);
        paramMap = params;
    }

    /**
     * constructor
     * @param inp takes in a Listable Object.
     * @param request http servlet request
     */
    public ListHelper(Listable inp, HttpServletRequest request) {
        this(inp, request, Collections.EMPTY_MAP);
    }    
    /**
     * Setup  the appropriate data bindings.
     */
    public void execute() {
        setupDataSet();
    }

    /**
     * 
     */
    private void setupDataSet() {
        List dataSet = listable.getResult(context);
        HttpServletRequest request = context.getRequest();
        request.setAttribute(ListTagHelper.PARENT_URL, getParentUrl());
        request.setAttribute(getDataSetName(), dataSet);
        if (!StringUtils.isBlank(getListName()) && dataSet instanceof DataResult) {
            DataResult data = (DataResult) dataSet;
            Elaborator elab = data.getElaborator();
            if (elab != null) {
                TagHelper.bindElaboratorTo(getListName(), elab, request);
            }
        }
    }
    /**
     * Basically returns a bound data set or null
     * @return the dataset associated to this listable tag. 
     */
    public List getDataSet() {
        List data =  (List) context.getRequest().getAttribute(getDataSetName());
        if (data == null) {
            setupDataSet();
        }
        return (List) context.getRequest().getAttribute(getDataSetName());
    }
    /**
     * @return the dataSetName
     */
    public String getDataSetName() {
        return dataSetName;
    }

    
    /**
     * @param setName the dataSetName to set
     */
    public void setDataSetName(String setName) {
        this.dataSetName = setName;
    }

    
    /**
     * @return the listName
     */
    public String getListName() {
        return listName;
    }

    
    /**
     * @param name the listName to set
     */
    public void setListName(String name) {
        this.listName = name;
    }
    
    /**
     * @return the context
     */
    public RequestContext getContext() {
        return context;
    }

    /**
     * @return the parentUrl
     */
    public String getParentUrl() {
        String url = parentUrl;
        if (StringUtils.isBlank(parentUrl)) {
            url  = context.getRequest().getRequestURI();
        }
        if (!paramMap.isEmpty()) {
            StringBuilder queryString = new StringBuilder();
            if (url.contains("?")) {
                if (!url.endsWith("?")) {
                    queryString.append("&");
                }
            }
            else {
                url += "?";
            }
            for (Object key : paramMap.keySet()) {
                if (queryString.length() != 0) {
                    queryString.append("&");
                }
                queryString.append(key).append("=").append(paramMap.get(key));
            }
            return url + queryString.toString();
        }
        return url;
    }
    
    /**
     * @param url the parentUrl to set
     */
    public void setParentUrl(String url) {
        this.parentUrl = url;
    }

    
    /**
     * @return the paramMap
     */
    public Map getParamMap() {
        return paramMap;
    }

    
    /**
     * @param params the paramMap to set
     */
    public void setParamMap(Map params) {
        this.paramMap = params;
    }
    
    protected Listable getListable() {
        return listable;
    }
}
