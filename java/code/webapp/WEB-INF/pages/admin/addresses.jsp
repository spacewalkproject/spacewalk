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

<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>
<rhn:toolbar base="h1" img="/img/rhn-icon-users.gif"
 imgAlt="users.jsp.imgAlt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-your-rhn.jsp#s2-sm-your-rhn-account">
    <bean:message key="Addresses" />
</rhn:toolbar>

<div class="page-summary">
<p>
   <bean:message key="addresses.summary" />
</p>
</div>

  <table class="details">
    <rhn:address type="M" action="my" user="${requestScope.targetuser}" address="${requestScope.addressMarketing}"/>
  </table>
</body>
</html>
