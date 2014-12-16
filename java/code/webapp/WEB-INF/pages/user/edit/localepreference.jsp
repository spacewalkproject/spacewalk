<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
<body>
<rhn:toolbar base="h1" icon="header-globe"
 helpUrl="">
<bean:message key="Locale Preferences"/>
</rhn:toolbar>
<html:form action="/account/LocalePreferences" method="post" styleClass="form-horizontal">
<rhn:csrf />
<%@ include file="/WEB-INF/pages/common/fragments/user/localepreferences.jspf" %>
</html:form>
</body>
</html>
