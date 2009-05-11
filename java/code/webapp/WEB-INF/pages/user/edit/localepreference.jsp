<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
<body>
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-icon-preferences.gif"
 helpUrl="/rhn/help/reference/en-US/s1-sm-your-rhn.jsp#s2-yourrhn-locale">
<bean:message key="Locale Preferences"/>
</rhn:toolbar>
<html:errors />
<html:form action="/account/LocalePreferences" method="post">
<%@ include file="/WEB-INF/pages/common/fragments/user/localepreferences.jspf" %>
</html:form>
</body>
</html>
