<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<c:choose>
  <c:when test="${requestScope.errorMsg != null}">
    <div class="page-summary">
      <p><bean:message key="${requestScope.errorMsg}" /></p>
    </div>
  </c:when>

  <c:otherwise>
    <%@ include file="/WEB-INF/pages/systems/details/virtualization/images/images-content.jspf" %>
  </c:otherwise>
</c:choose>
