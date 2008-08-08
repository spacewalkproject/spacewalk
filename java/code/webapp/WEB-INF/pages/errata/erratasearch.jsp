<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<body>

  <html:errors />
  <html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
  </html:messages>

  <rhn:toolbar base="h1" img="/img/rhn-icon-search.gif"
               helpUrl="/rhn/help/reference/en/s2-sm-errata-search.jsp"
               imgAlt="search.alt.img">
    <bean:message key="erratasearch.jsp.toolbar"/>
  </rhn:toolbar> 

  <p><bean:message key="erratasearch.jsp.summary"/></p>
  
  <p><bean:message key="erratasearch.jsp.instructions"/></p>
  
  <html:form action="/errata/Search.do">
  
  <!-- Search Box -->
   <div class="search-choices">

       <div class="search-choices-group">
         <table class="details">
           <tr><th><bean:message key="erratasearch.jsp.searchfor"/></th>
             <td>
               <input type="text" name="search_string" value="${search_string}" maxlength="36" />
               <input type="image" src="/img/button-search.gif" name="Search!" />
             </td>
           </tr>
           <tr><th><bean:message key="erratasearch.jsp.whatsearch"/></th>
             <td rowspan="2">
               <div style="text-align: center">
                 <html:select property="view_mode">
	               <html:options collection="searchOptions"
	                             property="value"
	                             labelProperty="display" />
                 </html:select>
               </div>
             </td>
           </tr>
         </table>
       </div>

   </div>
   <input type="hidden" name="submitted" value="true" />

  </html:form>

  <hr />
  <c:set var="pageList" value="${requestScope.pageList}" />
  <rl:listset name="searchSet">
    <rl:list name="searchResults" dataset="pageList"
             emptykey="erratasearch.jsp.noerrata" width="100%">

      <rl:decorator name="PageSizeDecorator"/>

      <rl:column bound="false" sortable="false" headerkey="erratalist.jsp.type" styleclass="first-column">
		<c:if test="${current.securityAdvisory}">
		  <img src="/img/wrh-security.gif" 
		       title="<bean:message key="erratalist.jsp.securityadvisory"/>" />
		</c:if>
		<c:if test="${current.bugFix}">
		  <img src="/img/wrh-bug.gif" 
		       title="<bean:message key="erratalist.jsp.bugadvisory"/>" />
		</c:if>
		<c:if test="${current.productEnhancement}">
		  <img src="/img/wrh-product.gif" 
		       title="<bean:message key="erratalist.jsp.productenhancementadvisory"/>" />
		</c:if>
      </rl:column>

      <rl:column bound="false" sortable="false" headerkey="erratalist.jsp.advisory">
        <a href="/rhn/errata/details/Details.do?eid=${current.id}">${current.advisoryName}</a>
      </rl:column>

      <c:choose>
        <c:when test="${view_mode == 'simple_errata_search' || view_mode == 'errata_search_by_synopsis'}">
          <%-- If this is a simple_errata_search, we display the synopsis column --%>
          <rl:column bound="false" sortable="false" headerkey="erratalist.jsp.synopsis" styleclass="last-column">
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
	      <rl:column bound="false" sortable="false" headerkey="erratasearch.jsp.errata_advisory" styleclass="last-column">
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
          <rl:column bound="false" sortable="false" headerkey="search.jsp.package_name" styleclass="last-column">
            <c:forEach items="${current.packageNames}" var="name">
              <rhn:highlight tag="strong" text="${search_string}">
                <c:out value="${name}"/>
              </rhn:highlight>
              <br>
            </c:forEach>
          </rl:column>
        </c:when>
        <c:when test="${view_mode == 'errata_search_by_descrp'}">
          <%--
               If this is a errata_search_by_descrp, we display
               the advisory synopsis and the package names associated
          --%>
          <rl:column bound="false" sortable="false" headerkey="erratalist.jsp.synopsis" styleclass="last-column">
            <rhn:highlight tag="strong" text="${search_string}">
              ${current.advisorySynopsis}
            </rhn:highlight>
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
          <rl:column bound="false" sortable="false" headerkey="erratalist.jsp.issueDate" styleclass="last-column">
            ${current.issueDate}
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
          <rl:column bound="false" sortable="false" headerkey="details.jsp.cves" styleclass="last-column">
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
    </rl:list>
    <!-- there are two forms here, need to keep the formvars around for pagination -->
    <input type="hidden" name="submitted" value="true" />
    <input type="hidden" name="search_string" value="${search_string}" />
    <input type="hidden" name="view_mode" value="${view_mode}" />
  </rl:listset>
</body>
</html>
