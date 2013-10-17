<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<rhn:toolbar base="h1" icon="icon-user"
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
