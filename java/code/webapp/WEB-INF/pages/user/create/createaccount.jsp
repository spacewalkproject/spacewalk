<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
<body>
<h1><bean:message key="usercreate.createLogin" /></h1>

<h2><bean:message key="usercreate.createAccount" /></h2>

    <div class="page-summary">
      <p><bean:message key="usercreate.loginEnables" /></p>
      <ul>
        <li><bean:message key="usercreate.enables1a" /><a href="https://www.redhat.com/store/"><bean:message key="usercreate.enables1b" /></a></li>
        <li><bean:message key="usercreate.enables2" /></li>
        <li><bean:message key="usercreate.enables3" /></li>
        <li><bean:message key="usercreate.enables4" /></li>
      </ul>
    </div>
<br />

<%@ include file="usercreate.jsp" %>

</body>
</html>
