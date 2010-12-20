<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
<body>

<rhn:require acl="user_authenticated()">

<h1><img src="/img/rhn-icon-warning.gif"/><bean:message key="service.jsp.title"/></h1>

    <p><bean:message key="service.jsp.summary"/></p>
    <p><bean:message key="service.jsp.message"/></p>

</rhn:require>

</body>
</html>