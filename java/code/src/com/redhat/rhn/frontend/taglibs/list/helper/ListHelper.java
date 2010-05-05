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
 * This class basically serves as a adapter class
 * to help with the action side counter part of the List Tag.  
 * i.e. Pages that use the New List Tag should make use 
 * of this in their action. Here is a useful example of the usage:
 * <code> 
 *  Jsp Side->
 *      <rl:list
 *        emptykey="assignedgroups.jsp.nogroups"
 *       alphabarcolumn="name">
 *       .......
 *       </rl:list>
 *       
 *  Java Side ->
 *   public class  ..... extends RhnAction implements Listable {
 *      public ActionForward execute(.....) {
 *          Map params = new HashMap();
 *          params.put("foo_id", request.getParamater("foo_id")); 
 *          ListHelper helper = new ListHelper(this, request, params);
 *          helper.execute();
 *          return mapping.findForward(RhnHelper.DEFAULT_FORWARD);         
 *      }
 *      
 *      public List getResults(RequestContext context) {
 *          .......
 *          return  fooList;
 *      }
 *   }
 * </code>
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
     * the dataset name. This is the name of the list
     * the actual results will be bound to.
     *  Call this if you are going to use a dataset name thats
     * different from the default value defined by
     * ListHelper.DATA_SET.
     * Idea is that dataset name = model, list name = view.
     * In other words dataset represents the list of results to render
     * the list name represents name of the rendering list.
     * So same data set name can be used for multiple lists. 
     * but each list has a uniqueName. 
     * <code>
     *      <rl:list ..
     *              dataset ="fooList"
     *              list = "bar"
     *              .... 
     *       >
     *       .......
     *       </rl:list>
     *       
     *  Java Side ->
     *      public ActionForward execute(.....) {
     *          ......
     *          ListHelper helper = ....;
     *          helper.setDataSetName("fooList");
     *          helper.setListName("bar");
     *          helper.execute();
     *          ....         
     *      }
     *  </code>
     * @param name the dataSetName to set
     */
    public void setDataSetName(String name) {
        this.dataSetName = name;
    }

    
    /**
     * @return the listName
     */
    public String getListName() {
        return listName;
    }

    /**
     * @return the listName but in it's unique form
     */
    public String getUniqueName() {
        return TagHelper.generateUniqueName(getListName());
    }

    
    /**
     * the list name. This is the name that uniquely
     * identifies a rendered list.
     *  Call this if you are going to use a list name thats
     * different from the default value defined by
     * ListHelper.LIST.
     * Idea is that dataset name = model, list name = view.
     * In other words dataset represents the list of results to render
     * the list name represents name of the rendering list.
     * So same data set name can be used for multiple lists. 
     * but each list has a uniqueName. 
     * <code>
     *      <rl:list ..
     *              dataset ="fooList"
     *              list = "bar"
     *              .... 
     *       >
     *       .......
     *       </rl:list>
     *       
     *  Java Side ->
     *      public ActionForward execute(.....) {
     *          ......
     *          ListHelper helper = ....;
     *          helper.setDataSetName("fooList");
     *          helper.setListName("bar");
     *          helper.execute();
     *          ....         
     *      }
     *  </code>     
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
