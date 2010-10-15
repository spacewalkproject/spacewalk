<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
    <h2><bean:message key="sdc.details.customdata.header"/></h2>

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
              <td>
                <pre>${current.value}</pre>
                <a href="/network/systems/details/custominfo/edit.pxt?sid=${system.id}&cikid=${current.cikid}">
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
