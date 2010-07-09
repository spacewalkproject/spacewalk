<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

  <div id="footer">
    <bean:message key="footer.jsp.copyright"/>
    <a href="https://www.redhat.com/legal/privacy_statement.html"><bean:message key="footer.jsp.privacyStatement"/></a>
    : <a href="http://www.redhat.com/legal/legal_statement.html"><bean:message key="footer.jsp.legalStatement"/></a>
    : <a href="http://www.redhat.com/">redhat.com</a>
      <div style="color: black"><bean:message key="footer.jsp.release" arg0="/rhn/help/release-notes/satellite/index.jsp" arg1="${rhn:getConfig('web.version')}" /></div>
    <p><%@ include file="/WEB-INF/pages/common/fragments/bugzilla.jspf" %></p>


  </div>
<%--
	Render Javascript here so we can be sure that all of
	the form elements we may need have been rendered.
--%>
<!-- Javascript -->
<script src="/javascript/check_all.js" type="text/javascript"></script>
