<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html xhtml="true">
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
    
    <rhn:toolbar base="h2" img="/img/rhn-icon-info.gif"   
      creationUrl="/rhn/systems/details/CreateCustomData.do?sid=${system.id}"
      creationType="customdata">
      <bean:message key="sdc.details.customdata.header"/>
    </rhn:toolbar>

    <div class="page-summary">
      <p><bean:message key="sdc.details.customdata.summary"/></p>
    </div>

    <c:choose>
      <c:when test="${listEmpty == 1}">
        <div class="list-empty-message">
          <bean:message key="sdc.details.customdata.nosystems"/>
        </div>
      </c:when>
      <c:otherwise>
        <table class="details">
          <c:forEach items="${pageList}" var="current" varStatus="loop">
            <tr>
              <th>${current.label}</th>
              <td width="50%">
                <pre><c:out value="${current.value}" /></pre>
                <a href="/rhn/systems/details/UpdateCustomData.do?sid=${system.id}&cikid=${current.cikid}">
                  <bean:message key="sdc.details.customdata.editvalue"/>
                </a>
              </td>
            </tr>
          </c:forEach>
        </table>
      </c:otherwise>
    </c:choose>

  </body>
</html:html>
