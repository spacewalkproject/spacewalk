<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<body>

<rhn:toolbar base="h1" img="/img/rhn-icon-search.gif" imgAlt="search.alt.img">
  <bean:message key="scapsearch.jsp.toolbar"/>
</rhn:toolbar>

<p><bean:message key="scapsearch.jsp.summary"/></p>
<p><bean:message key="scapsearch.jsp.instructions"/></p>

<html:form action="/audit/scap/Search.do">
  <rhn:csrf/>
  <div class="search-choises">
    <div class="search-choices-group">
      <table class="details">
        <tr><th><bean:message key="scapsearch.jsp.searchfor"/>:</th>
          <td>
            <html:text property="search_string" name="search_string"
                value="${search_string}" maxlength="100" accesskey="4"/>
            <html:submit>
              <bean:message key="button.search" />
            </html:submit>
            <br/>
            <span class="small-text">
              <bean:message key="scapsearch.jsp.whatsearch.tip"/>
            </span>
          </td>
        </tr>
      </table>
    </div> <!-- search-choices-group -->
  </div> <!-- search-choices -->
  <input type="hidden" name="submitted" value="true"/>
</html:form>

<c:if test="${(search_string != null && search_string != '')}">
  <c:set var="pageList" value="${requestScope.pageList}"/>
  <hr/>

  <rl:listset name="searchSet" legend="xccdf">
    <rhn:csrf/>
    <rl:list emptykey="generic.jsp.none" name="searchResults" dataset="pageList">
      <rl:decorator name="PageSizeDecorator"/>
      <%@ include file="/WEB-INF/pages/common/fragments/audit/rule-common-columns.jspf" %>
    </rl:list>

    <!-- there are two forms here, need to keep the formvars around for pagination -->
    <input type="hidden" name="submitted" value="true"/>
    <input type="hidden" name="search_string" value="${search_string}"/>
  </rl:listset>
</c:if>

</body>
</html>
