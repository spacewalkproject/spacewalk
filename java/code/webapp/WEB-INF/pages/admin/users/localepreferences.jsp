<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html >
<body>

<%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>
<html:form action="/users/LocalePreferences">
<rhn:csrf />
<%@ include file="/WEB-INF/pages/common/fragments/user/localepreferences.jspf" %>
</html:form>
</body>
</html:html>
