<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>

<%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>
<html:form action="/users/LocalePreferences">
<%@ include file="/WEB-INF/pages/common/fragments/user/localepreferences.jspf" %>
</html:form>
</body>
</html:html>
