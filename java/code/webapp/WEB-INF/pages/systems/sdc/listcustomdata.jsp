<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html xhtml="true">
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
    
    <rhn:toolbar base="h2" icon="icon-info-sign"   
      creationUrl="/rhn/systems/table/CreateCustomData.do?sid=${system.id}"
      creationType="customdata">
      <bean:message key="sdc.table.customdata.header"/>
    </rhn:toolbar>

    <div class="page-summary">
      <p><bean:message key="sdc.table.customdata.summary"/></p>
    </div>

    <c:choose>
      <c:when test="${listEmpty == 1}">
        <div class="list-empty-message">
          <bean:message key="sdc.table.customdata.nosystems"/>
        </div>
      </c:when>
      <c:otherwise>
        <table class="table">
          <c:forEach items="${pageList}" var="current" varStatus="loop">
            <tr>
              <th>${current.label}</th>
              <td width="50%">
                <pre><c:out value="${current.value}" /></pre>
                <a href="/rhn/systems/table/UpdateCustomData.do?sid=${system.id}&cikid=${current.cikid}">
                  <bean:message key="sdc.table.customdata.editvalue"/>
                </a>
              </td>
            </tr>
          </c:forEach>
        </table>
      </c:otherwise>
    </c:choose>

  </body>
</html:html>
