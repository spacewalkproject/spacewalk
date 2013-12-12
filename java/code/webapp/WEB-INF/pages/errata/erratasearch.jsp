<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<html>
    <head>
        <script language="javascript">
        Event.observe(window, 'load',
            function() {
                issueDateSearchOptions();
            });

        function issueDateSearchOptions() {
            if ($("issueDateOptionsCheckBox").checked) {
                Element.show("issueDateOptions");
            } else {
                Element.hide("issueDateOptions");
            }
        }
        </script>
    </head>

<body>
<rhn:toolbar base="h1" icon="header-search"
               helpUrl="/rhn/help/reference/en-US/s1-sm-errata.jsp#s2-sm-errata-search">
    <bean:message key="erratasearch.jsp.toolbar"/>
  </rhn:toolbar>

  <p><bean:message key="erratasearch.jsp.summary"/></p>

  <html:form styleClass="form-horizontal" action="/errata/Search.do">
  <rhn:csrf />

  <!-- Search Box -->
   <div class="panel panel-default">
       <div class="panel-heading">
          <h4><bean:message key="erratasearch.jsp.instructions"/></h4>
       </div>
       <div class="panel-body">
         <table class="table">
           <tr>
             <td><bean:message key="erratasearch.jsp.searchfor"/></td>
             <td>
              <div class="row-0">
                <div class="col-md-5">
                  <html:text property="search_string" styleClass="form-control input-sm" name="search_string"
                     value="${search_string}" maxlength="36" accesskey="4"/>
                </div>
                <span class="col-md-7">
                  <strong><bean:message key="Examples" />: </strong> <bean:message key="erratasearch.jsp.search.tip" />
                </span>
                </div>
             </td>
           </tr>
           <tr><td><bean:message key="erratasearch.jsp.whatsearch"/></td>
             <td>
                <div class="row-0">
                  <div class="col-md-5">
                    <html:select property="view_mode" styleClass="form-control input-sm">
  	                <html:options collection="searchOptions"
  	                             property="value"
  	                             labelProperty="display" />
                    </html:select>
                  </div>
                  <span class="col-md-7">
                    <strong><bean:message key="Tip" />:</strong> <bean:message key="erratasearch.jsp.whatsearch.tip" />
                  </span>
                </div>
             </td>
           </tr>
           <tr><td><bean:message key="erratasearch.jsp.types_to_search"/></td>
             <td>
                <div class="checkbox">
                  <html:checkbox property="errata_type_bug">
                    <rhn:icon type="errata-bugfix" />
                        <bean:message key="erratalist.jsp.bugadvisory"/>
                  </html:checkbox>
                </div>
                <div class="checkbox">
                <html:checkbox property="errata_type_security">
                    <rhn:icon type="errata-security" />
                    <bean:message key="erratalist.jsp.securityadvisory"/>
                </html:checkbox>
                </div>
                <div class="checkbox">
                <html:checkbox property="errata_type_enhancement">
                    <rhn:icon type="errata-enhance" />
                    <bean:message key="erratalist.jsp.productenhancementadvisory"/>
                </html:checkbox>
                </div>
            </td>
           </tr>
           <tr>
            <td><bean:message key="erratasearch.jsp.issue_date"/></td>
                <td>
                  <div class="checkbox">
                    <html:checkbox styleId="issueDateOptionsCheckBox" property="optionIssueDateSearch" onclick="javascript:issueDateSearchOptions()" >
                        <bean:message key="erratasearch.jsp.search_by_issue_dates"/>
                    </html:checkbox>
                  </div>
                    <div id="issueDateOptions">
                        <table class="table">
                            <tr>
                                <td>
                                    <bean:message key="erratasearch.jsp.start_date" />
                                </td>
                                <td>
                                    <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                                        <jsp:param name="widget" value="start"/>
                                    </jsp:include>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <bean:message key="erratasearch.jsp.end_date" />
                                </td>
                                <td>
                                    <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
                                        <jsp:param name="widget" value="end"/>
                                    </jsp:include>
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
           </tr>
           <tr>
              <td><label for="fineGrainedlabel"><bean:message key="systemsearch.jsp.finegrainedlabel"/></label></td>
              <td>
                <div class="checkbox">
                  <html:checkbox property="fineGrained" styleId="fineGrainedlabel"> <label for="fineGrainedlabel"><bean:message key="systemsearch.jsp.finegrained"/></label></html:checkbox>
                </div>
              </td>
           </tr>
           <tr>
            <td>
              &nbsp;
            </td>
            <td>
              <button type="submit" class="btn btn-success btn-sm">
                <rhn:icon type="header-search" />
                <bean:message key="button.search"/>
            </button>
            </td>
           </tr>
         </table>
       </div> <!-- search choices group -->
   </div> <!-- search choices -->
   <input type="hidden" name="submitted" value="true" />
  </html:form>

  <c:if test="${(search_string != null && search_string != '') || param.optionIssueDateSearch != null }">
  <hr />

  <c:set var="pageList" value="${requestScope.pageList}" />
  <rl:listset name="searchSet" legend="errata">
    <rhn:csrf />
    <rl:list name="searchResults" dataset="pageList"
             emptykey="erratasearch.jsp.noerrata" width="100%">

      <rl:decorator name="PageSizeDecorator"/>

      <rl:column bound="false" sortable="true" sortattr="securityAdvisory"
        headerkey="erratalist.jsp.type">
		<c:if test="${current.securityAdvisory}">
		  <rhn:icon type="errata-security" />
		</c:if>
		<c:if test="${current.bugFix}">
		  <rhn:icon type="errata-bugfix" />
		</c:if>
		<c:if test="${current.productEnhancement}">
		  <rhn:icon type="errata-enhance" />
		</c:if>
      </rl:column>

      <rl:column bound="false" sortable="true" sortattr="advisoryName" headerkey="erratalist.jsp.advisory">
        <a href="/rhn/errata/details/Details.do?eid=${current.id}">${current.advisoryName}</a>
      </rl:column>

      <c:choose>
        <c:when test="${view_mode == 'errata_search_by_all_fields'}">
          <%-- If this is a simple_errata_search, we display the synopsis column --%>
          <rl:column bound="false" sortable="true"
            sortattr="advisorySynopsis" headerkey="erratalist.jsp.synopsis">
            <rhn:highlight tag="strong" text="${search_string}">
              ${current.advisorySynopsis}
            </rhn:highlight>
          </rl:column>
        </c:when>
        <c:when test="${view_mode == 'errata_search_by_advisory'}">
          <%--
              If this is a errata_search_by_advisory, we display the synopsis
	          column, but call it Errata Advisory
	      --%>
	      <rl:column bound="false" sortable="true" sortattr="advisorySynopsis"
	           headerkey="erratasearch.jsp.errata_advisory">
            <rhn:highlight tag="strong" text="${search_string}">
              ${current.advisorySynopsis}
            </rhn:highlight>
	      </rl:column>
        </c:when>
        <c:when test="${view_mode == 'errata_search_by_package_name'}">
          <%--
               If this is a errata_search_by_package_name, we display
               a Package Name column.
          --%>
          <rl:column bound="false" sortable="false" headerkey="search.jsp.package_name">
            <c:forEach items="${current.packageNames}" var="name">
              <rhn:highlight tag="strong" text="${search_string}">
                <c:out value="${name}"/>
              </rhn:highlight>
              <br>
            </c:forEach>
          </rl:column>
        </c:when>
        <c:when test="${view_mode == 'errata_search_by_issue_date'}">
          <%--
               If this is a errata_search_by_issue_date, we display
               the advisory synopsis and the issue date
          --%>
          <rl:column bound="false" sortable="false" headerkey="erratalist.jsp.synopsis">
              ${current.advisorySynopsis}
          </rl:column>
        </c:when>
        <c:when test="${view_mode == 'errata_search_by_cve'}">
          <%--
               If this is a errata_search_by_cve, we display
               all the cves per errata
          --%>
          <rl:column bound="false" sortable="false" headerkey="erratalist.jsp.synopsis">
              ${current.advisorySynopsis}
          </rl:column>
          <rl:column bound="false" sortable="false" headerkey="details.jsp.cves">
            <c:forEach items="${current.cves}" var="cve">
                <a href="http://cve.mitre.org/cgi-bin/cvename.cgi?name=${cve.name}">
                   <rhn:highlight tag="strong" text="${search_string}">
                    ${cve.name}
                   </rhn:highlight>
                </a>
              <br>
            </c:forEach>
          </rl:column>
        </c:when>
      </c:choose>
      <rl:column bound="false" sortable="true" headerkey="erratalist.jsp.issueDate"
        sortattr="issueDateObj">
            ${current.issueDate}
      </rl:column>

    </rl:list>
    <rl:csv dataset="pageList"
            name="searchResults"
            exportColumns="advisoryType,advisoryName,advisorySynopsis,issueDate"/>

    <!-- there are two forms here, need to keep the formvars around for pagination -->
    <input type="hidden" name="submitted" value="true" />
    <html:hidden property="search_string" name="search_string" value="${search_string}" />
    <input type="hidden" name="view_mode" value="${view_mode}" />
    <input type="hidden" name="errata_type_bug" value="<%= request.getParameter("errata_type_bug") %>" />
    <input type="hidden" name="errata_type_security" value="<%= request.getParameter("errata_type_security") %>" />
    <input type="hidden" name="errata_type_enhancement" value="<%= request.getParameter("errata_type_enhancement") %>" />
    <input type="hidden" name="optionIssueDateSearch" value="<%= request.getParameter("optionIssueDateSearch") %>" />
    <input type="hidden" name="start_year"  value="<%= request.getParameter("start_year") %>" />
    <input type="hidden" name="start_month" value="<%= request.getParameter("start_month") %>" />
    <input type="hidden" name="start_day"   value="<%= request.getParameter("start_day") %>" />
    <input type="hidden" name="start_hour"  value="<%= request.getParameter("start_hour") %>" />
    <input type="hidden" name="start_minute" value="<%= request.getParameter("start_minute") %>" />
    <input type="hidden" name="start_am_pm" value="<%= request.getParameter("start_am_pm") %>" />
    <input type="hidden" name="end_year" value="<%= request.getParameter("end_year") %>" />
    <input type="hidden" name="end_month" value="<%= request.getParameter("end_month") %>" />
    <input type="hidden" name="end_day" value="<%= request.getParameter("end_day") %>" />
    <input type="hidden" name="end_hour" value="<%= request.getParameter("end_hour") %>" />
    <input type="hidden" name="end_minute" value="<%= request.getParameter("end_minute") %>" />
    <input type="hidden" name="end_am_pm" value="<%= request.getParameter("end_am_pm") %>" />
    <input type="hidden" name="fineGrained" value="${fineGrained}" />

  </rl:listset>

  </c:if>

</body>
</html>
