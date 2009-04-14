<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
<body>

<html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>

<rhn:toolbar base="h2" helpUrl="/rhn/help/reference/en-US/s2-sm-user-active.jsp">
    <bean:message key="yourchangeemail.jsp.title" />
</rhn:toolbar> 

<p>
${pageinstructions}
</p>

<html:errors />

<html:form action="/users/ChangeEmailSubmit.do?uid=${param.uid}">
  <html:text property="email" size="32" />
  <html:submit value="${button_label}" />
  <html:hidden property="uid"/>
</html:form>
</body>
</html>
