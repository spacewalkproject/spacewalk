<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>
<%@ include file="/WEB-INF/pages/common/fragments/user/user_attribute_sizes.jspf"%>
<rhn:toolbar base="h2" helpUrl="/rhn/help/reference/en-US/s1-sm-users.jsp#s2-sm-user-active">
    <bean:message key="yourchangeemail.jsp.title" />
</rhn:toolbar>

<p>
${pageinstructions}
</p>
<html:form action="/users/ChangeEmailSubmit.do?uid=${param.uid}">
  <html:text property="email" size="32" maxlength="${emailLength}" />
  <html:submit value="${button_label}" />
  <html:hidden property="uid"/>
</html:form>
</body>
</html>
