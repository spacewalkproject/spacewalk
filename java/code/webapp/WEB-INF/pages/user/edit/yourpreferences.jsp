<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
<head>
</head>
<body>
<rhn:toolbar base="h1" icon="header-preferences"
 helpUrl="/rhn/help/reference/en-US/s1-sm-your-rhn.jsp#s2-sm-your-rhn-prefs">
<bean:message key="Your Preferences"/>
</rhn:toolbar>
<html:form action="/account/PrefSubmit">
<rhn:csrf />
<%@ include file="/WEB-INF/pages/common/fragments/user/preferences.jspf" %>
</html:form>
</body>
</html>
