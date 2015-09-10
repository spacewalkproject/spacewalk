<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:html >
    <body>
        <rhn:toolbar base="h1" icon="header-search"
                     helpUrl=""
                     imgAlt="search.alt.img">
            <bean:message key="systemsearch.jsp.toolbar"/>
        </rhn:toolbar>
        <p><bean:message key="systemsearch.jsp.summary"/></p>
        <p><bean:message key="erratasearch.jsp.instructions"/></p>
        <div class="panel panel-default">
            <div class="panel-body">
                <html:form action="/systems/Search.do" styleClass="form-horizontal">
                    <rhn:csrf />
                    <rhn:submitted />

                    <div class="form-group">
                        <label class="col-sm-3 control-label" for="searchfor">
                            <bean:message key="erratasearch.jsp.searchfor"/>
                        </label>
                        <div class="col-sm-6">
                            <html:text property="search_string" styleClass="form-control" name="search_string" styleId="searchfor" value="${search_string}" maxlength="100" accesskey="4"/>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-3 control-label" for="fieldtosearch">
                            <bean:message key="systemsearch.jsp.fieldtosearch"/>
                        </label>
                        <div class="col-sm-6">
                            <select name="view_mode" id="fieldtosearch" class="form-control">
                                <c:forEach items="${optGroupsKeys}" var="key">
                                    <optgroup label="<bean:message key='${key}'/>">
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
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-3 control-label">
                            <bean:message key="systemsearch.jsp.wheretosearch"/>
                        </label>
                        <div class="col-sm-6">
                            <div class="radio">
                              <label for="whereToSearch-all">
                            <html:radio property="whereToSearch" value="all" styleId="whereToSearch-all"/>
                                  <bean:message key="systemsearch.jsp.searchallsystems"/>
                              </label>
                            </div>
                            <div class="radio">
                                <label for="whereToSearch-system_list">
                            <html:radio property="whereToSearch" value="system_list" styleId="whereToSearch-system_list"/>
                                    <bean:message key="systemsearch.jsp.searchSSM"/>
                                </label>
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="invertlabel" class="col-sm-3 control-label">
                            <bean:message key="systemsearch.jsp.invertlabel"/>
                        </label>
                        <div class="col-sm-6">
                            <div class="checkbox">
                                <label for="invertlabel">
                                <html:checkbox property="invert" styleId="invertlabel">
                                        <bean:message key="systemsearch.jsp.invertdescription"/>
                                </html:checkbox>
                                </label>
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="fineGrainedlabel" class="col-sm-3 control-label">
                            <bean:message key="systemsearch.jsp.finegrainedlabel"/>
                        </label>
                        <div class="col-sm-6">
                            <div class="checkbox">
                                <label for="fineGrainedlabel">
                            <html:checkbox property="fineGrained" styleId="fineGrainedlabel">
                                        <bean:message key="systemsearch.jsp.finegrained"/>
                            </html:checkbox>
                                </label>
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-sm-9 col-sm-offset-3">
                            <button type="submit" class="btn btn-primary">
                                <rhn:icon type="header-search" />
                                <bean:message key="button.search"/>
                            </button>
                        </div>
                    </div>
                    <html:hidden property="submitted" value="true"/>
                </html:form>
            </div>
        </div>



        <c:if test="${search_string != null && search_string != ''}">
            <hr/>
            <rl:listset name="searchSet">
                <rhn:csrf />
                <html:hidden property="submitted" value="true"/>
                <html:hidden property="search_string" name="search_string" value="${search_string}" />
                <html:hidden property="view_mode" value="${view_mode}" />
                <html:hidden property="whereToSearch" value="${whereToSearch}" />
                <html:hidden property="invert" value="${invert}" />
                <html:hidden property="fineGrained" value="${fineGrained}" />

                <rl:list name="pageList" dataset="searchResults"
                         emptykey="systemsearch.jsp.noresults" width="100%"
                         decorator="SelectableDecorator"
                         alphabarcolumn="name"
                         filter="com.redhat.rhn.frontend.taglibs.list.filters.SystemOverviewFilter">

                    <rl:decorator name="ElaborationDecorator"/>
                    <rl:decorator name="PageSizeDecorator"/>

                    <%-- <rhn:set value="${current.id}" disabled="${not current.selectable}"  /> --%>
                    <rl:selectablecolumn value="${current.id}"
                                         selected="${current.selected}"
                                         disabled="${not current.selectable}"/>

                    <rl:column bound="false" sortable="true" sortattr="name" headerkey="systemsearch.jsp.systemname">
                        <a href="/rhn/systems/details/Overview.do?sid=${current.id}">
                            <rhn:highlight tag="strong" text="${search_string}">
                                <c:out value="${current.serverName}" escapeXml="true"/>
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
