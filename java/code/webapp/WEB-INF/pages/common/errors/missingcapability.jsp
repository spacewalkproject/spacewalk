<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
<body>

<rhn:require acl="user_authenticated()">

<h1>
  <img src="/img/rhn-icon-warning.gif"
       alt="${rhn:localize('error.common.errorAlt')}" />
  <bean:message key="missing_capabilities.jsp.header"/>
</h1>
<p><bean:message key="missing_capabilities.jsp.title"/></p>
<p><bean:message key="missing_capabilities.jsp.summary"
			arg0="/rhn/systems/details/Overview.do?sid=${error.server.id}"
			arg1="${error.server.name}"
			arg2="${error.capability}"/></p>

</rhn:require>

</body>
</html>
