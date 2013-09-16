<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html xhtml="true">
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-search.gif"
                       helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s2-sm-system-search"
                       imgAlt="search.alt.img">
  <bean:message key="systemsearch.jsp.toolbar"/>
</rhn:toolbar>

  <p><bean:message key="systemsearch.jsp.summary"/></p>

  <p><bean:message key="erratasearch.jsp.instructions"/></p>
<html:form action="/systems/Search.do">

<rhn:csrf />
<rhn:submitted />

<div class="search-choices">
	<div class="search-choices-group">
	<table class="details">
		<tr><th><label for="searchfor"><bean:message key="erratasearch.jsp.searchfor"/></label></th>
			<td>
                <html:text property="search_string" name="search_string" styleId="searchfor"
                           value="${search_string}" maxlength="100" accesskey="4"/>
                <button type="submit" class="btn btn-default btn-sm">
                    <span class="glyphicon glyphicon-search" />
                    <bean:message key="button.search"/>
                </button>

			</td>
  		</tr>
  		<tr>
			<th><label for="fieldtosearch"><bean:message key="systemsearch.jsp.fieldtosearch"/></label></th>
			<td>
				<select name="view_mode" styleId="fieldtosearch">
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
				<html:radio property="whereToSearch" value="all" styleId="whereToSearch-all"/><label for="whereToSearch-all"><bean:message key="systemsearch.jsp.searchallsystems"/></label>
        		</div>
        		<div style="text-align: left">
				<html:radio property="whereToSearch" value="system_list" styleId="whereToSearch-system_list"/><label for="whereToSearch-system_list"><bean:message key="systemsearch.jsp.searchSSM"/></label>
        		</div>
        	</td>
        </tr>

        <tr>
           <th><label for="invertlabel"><bean:message key="systemsearch.jsp.invertlabel"/></label></th>
           <td>
           	   <div style="text-align: left">
			<html:checkbox property="invert" styleId="invertlabel"><label for="invertlabel"><bean:message key="systemsearch.jsp.invertdescription"/></label></html:checkbox>
           	   </div>
           </td>
        </tr>
        <tr>
           <th><label for="fineGrainedlabel"><bean:message key="systemsearch.jsp.finegrainedlabel"/></label></th>
           <td>
                <div style="text-align: left">
            <html:checkbox property="fineGrained" styleId="fineGrainedlabel"><label for="fineGrainedlabel"><bean:message key="systemsearch.jsp.finegrained"/></label></html:checkbox>
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
    <rl:listset name="searchSet">
    <rhn:csrf />
    <input type="hidden" name="submitted" value="true"/>
    <html:hidden property="search_string" name="search_string" value="${search_string}" />
    <input type="hidden" name="view_mode" value="${view_mode}" />
    <input type="hidden" name="whereToSearch" value="${whereToSearch}" />
    <input type="hidden" name="invert" value="${invert}" />
    <input type="hidden" name="fineGrained" value="${fineGrained}" />

        <rl:list name="pageList" dataset="searchResults"
            emptykey="systemsearch.jsp.noresults" width="100%"
            decorator="SelectableDecorator"
            alphabarcolumn="name"
            filter="com.redhat.rhn.frontend.taglibs.list.filters.SystemOverviewFilter">

            <rl:decorator name="ElaborationDecorator"/>
            <rl:decorator name="PageSizeDecorator"/>

            <rhn:require acl="org_entitlement(sw_mgr_enterprise)">
                <%-- <rhn:set value="${current.id}" disabled="${not current.selectable}"  /> --%>
                <rl:selectablecolumn value="${current.id}"
                            selected="${current.selected}"
                            disabled="${not current.selectable}"/>
            </rhn:require>

            <rl:column bound="false" sortable="true" sortattr="name" headerkey="systemsearch.jsp.systemname">
                    <a href="/rhn/systems/details/Overview.do?sid=${current.id}">
                        <rhn:highlight tag="strong" text="${search_string}">
                            ${current.serverName}
                        </rhn:highlight>
                    </a>
            </rl:column>

            <c:choose>
                <c:when test="${view_mode == 'systemsearch_simple' ||
                               view_mode == 'systemsearch_cpu_mhz_lt' ||
                               view_mode == 'systemsearch_cpu_mhz_gt' ||
                               view_mode == 'systemsearch_ram_lt' ||
                               view_mode == 'systemsearch_ram_gt'}">
                              <rl:column bound="false" headerkey="${view_mode}_column">
                                <rhn:highlight tag="strong" text="${search_string}">
                                    ${current.lookupMatchingField}
                                </rhn:highlight>
                              </rl:column>
                </c:when>
                <c:when test="${view_mode == 'systemsearch_checkin'}">
                    <rl:column bound="false" headerkey="${view_mode}" >
                        ${current.checkin}
                    </rl:column>
                </c:when>
                <c:when test="${view_mode == 'systemsearch_registered'}">
                    <rl:column bound="false" headerkey="${view_mode}" >
                        ${current.registered}
                    </rl:column>
                </c:when>
                <%--We aren't able to determine what matchingField is from SearchServer yet,
                it could be 1 of 3 values,
                will display all 3 vendor-version-release --%>
                <c:when test="${view_mode == 'systemsearch_dmi_bios'}">
                    <rl:column bound="false" headerkey="${view_mode}">
                        <rhn:highlight tag="strong" text="${search_string}">
                            ${current.dmiBiosVendor} ${current.dmiBiosVersion} ${current.dmiBiosRelease}
                        </rhn:highlight>
                    </rl:column>
                </c:when>
                <c:when test="${view_mode == 'systemsearch_name_and_description'}">
                    <rl:column bound="false" headerkey="${view_mode}_column">
                        <rhn:highlight tag="strong" text="${search_string}">
                            ${current.description}
                        </rhn:highlight>
                    </rl:column>
                </c:when>
                <c:when test="${view_mode == 'systemsearch_hostname'}">
                    <rl:column bound="false" headerkey="${view_mode}">
                        <rhn:highlight tag="strong" text="${search_string}">
                            ${current.decodedHostname}
                        </rhn:highlight>
                    </rl:column>
                </c:when>
                <c:otherwise>
                  <rl:column bound="false" headerkey="${view_mode}">
                   <rhn:highlight tag="strong" text="${search_string}">
                        ${current.matchingFieldValue}
                   </rhn:highlight>
                  </rl:column>
                </c:otherwise>
            </c:choose>

            <rl:column bound="false" headerkey="systemsearch.jsp.entitlement">
                        ${current.entitlementLevel}
            </rl:column>
        </rl:list>
        <rl:csv dataset="searchResults"
                name="searchResults"
                exportColumns="id,serverName,matchingField,matchingFieldValue,entitlementLevel"/>

    </rl:listset>
    </c:if>
</body>
</html:html>
