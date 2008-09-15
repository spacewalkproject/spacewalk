<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>

<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-icon-search.gif"
                       helpUrl="/rhn/help/reference/en/s2-sm-system-search.jsp"
                       imgAlt="search.alt.img">
  <bean:message key="systemsearch.jsp.toolbar"/>
</rhn:toolbar>

  <p><bean:message key="systemsearch.jsp.summary"/></p>
  
  <p><bean:message key="erratasearch.jsp.instructions"/></p>
  
  <html:errors />
  <html:form action="/systems/SearchSubmit.do">
  
<div class="search-choices">
	<div class="search-choices-group">
	<table class="details">
		<tr><th><bean:message key="erratasearch.jsp.searchfor"/></th>
			<td>
				<input type="text" name="search_string" value="${search_string}" maxlength="36" />
				<input type="image" src="/img/button-search.gif" name="Search!" />
			</td>
  		</tr>
  		<tr>
  			<th><bean:message key="systemsearch.jsp.fieldtosearch"/></th>
			<td>
				<select name="view_mode" >
					<c:forEach items="${optGroupsKeys}" var="key">
						<optgroup label="<bean:message key="${key}"/>">
						<c:forEach items="${optGroupsMap[key]}" var="option">
							<c:choose>
								<c:when test="${view_mode == option['value']}">
									<option value="${option["value"]}" selected="selected">${option["display"]}</option>
							 	</c:when>
							 	<c:otherwise>
							 		<option value="${option["value"]}">${option["display"]}</option>
							 	</c:otherwise>
							</c:choose>
						</c:forEach>
						</optgroup>
					</c:forEach>
				</select>
			</td>
        </tr>
        
        <tr>
        	<th><bean:message key="systemsearch.jsp.wheretosearch"/></th>
        	<td>
        	    <div style="text-align: left">
        			<html:radio property="whereToSearch" value="all"/><bean:message key="systemsearch.jsp.searchallsystems"/>
        		</div>
        		<div style="text-align: left">
        			<html:radio property="whereToSearch" value="system_list"/><bean:message key="systemsearch.jsp.searchSSM"/>
        		</div>
        	</td>
        </tr>
        
        <tr>
           <th><bean:message key="systemsearch.jsp.invertlabel"/></th>
           <td>
           	   <div style="text-align: left">
           	   	<html:checkbox property="invert"><bean:message key="systemsearch.jsp.invertdescription"/></html:checkbox>
           	   </div>
           </td>
        </tr>
           		
	</table>
    </div>
</div>
	<input type="hidden" name="submitted" value="true"/>
</html:form>

<c:if test="${search_string != null && search_string != ''}">
<hr/>
	<form method="post" name="rhn_list" action="/rhn/systems/SearchSubmit.do">
	    <input type="hidden" name="whereToSearch" value="${whereToSearch}" maxlength="36" />
    	<input type="hidden" name="invert" value="${invert}" maxlength="36" />
	    <input type="hidden" name="search_string" value="${search_string}" maxlength="36" />
    	<input type="hidden" name="view_mode" value="${view_mode}" maxlength="36" />
    	<rhn:list pageList="${requestScope.pageList}" noDataText="systemsearch.jsp.noresults">
        <rhn:listdisplay set="${requestScope.set}" hiddenvars="${requestScope.newset}">
    	<html:hidden property="submitted" value="true"/>
        
            <rhn:require acl="org_entitlement(sw_mgr_enterprise)">
	              <rhn:set value="${current.id}" disabled="${not current.selectable}"  />
			</rhn:require>
			
        	<rhn:column header="systemsearch.jsp.systemname"
        	            url="/rhn/systems/details/Overview.do?sid=${current.id}">
        	            ${current.serverName}
        	</rhn:column>
        	
        	<c:choose>
        		<c:when test="${view_mode == 'systemsearch_simple' ||
        		               view_mode == 'systemsearch_cpu_mhz_lt' ||
        		               view_mode == 'systemsearch_cpu_mhz_gt' || 
        		               view_mode == 'systemsearch_ram_lt' ||
        		               view_mode == 'systemsearch_ram_gt'}">
        					  <rhn:column header="${view_mode}_column">
        					  	${current.matchingField}
        		              </rhn:column>
        		</c:when>
        		<c:otherwise>
        	      <rhn:column header="${view_mode}">
        	       <rhn:highlight tag="strong" text="${search_string}">
        				${current.matchingField}
        		   </rhn:highlight>
        		  </rhn:column>
        		</c:otherwise>
        	</c:choose>
        	<rhn:column header="systemsearch.jsp.entitlement">
        				${current.entitlementLevel}
        	</rhn:column>
        </rhn:listdisplay>
        </rhn:list>	  
	</form>
</c:if>

</body>
</html:html>

