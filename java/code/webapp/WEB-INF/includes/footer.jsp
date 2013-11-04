<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<div>
  <bean:message key="footer.jsp.copyright" />
  <a href="https://www.redhat.com/legal/privacy_statement.html"><bean:message key="footer.jsp.privacyStatement" /></a>
  : <a href="http://www.redhat.com/legal/legal_statement.html"><bean:message key="footer.jsp.legalStatement" /></a>
  : <a href="http://www.redhat.com/">redhat.com</a>
  <div><bean:message key="footer.jsp.release" arg0="/rhn/help/dispatcher/release_notes" arg1="${rhn:getConfig('web.version')}" /></div>
  <p><%@ include file="/WEB-INF/pages/common/fragments/bugzilla.jspf" %></p>
  <c:set var="custom_footer" scope="page" value="${rhn:getConfig('java.custom_footer')}" />
  <c:if test="${! empty custom_footer}">
      <p><c:out value="${custom_footer}" escapeXml="false" /></p>
  </c:if>
</div>
<div>
  <img src="/img/logo_vendor.png" />
</div>
