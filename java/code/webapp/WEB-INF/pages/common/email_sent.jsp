<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-users.gif"
 helpUrl="/rhn/help/reference/en-US/s1-sm-your-rhn.jsp">
 <bean:message key="email_sent.jsp.title"/>
</rhn:toolbar>
<div class="page-summary">
    <p><bean:message key="email_sent.jsp.message"/></p>
</div>
</body>
</html>
