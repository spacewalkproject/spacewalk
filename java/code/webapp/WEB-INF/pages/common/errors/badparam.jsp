<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<html:xhtml/>
<html>
<body>

<rhn:require acl="user_authenticated()">

<h1><img src="/img/rhn-icon-warning.gif"/><bean:message key="badparam.jsp.title"/></h1>

<p><bean:message key="badparam.jsp.summary"/></p>
    <ol>
      <li><bean:message key="badparam.jsp.reason1"/></li>
      <li><bean:message key="badparam.jsp.reason2"/></li>
      <li><bean:message key="badparam.jsp.reason3"/></li>
      <li><bean:message key="badparam.jsp.reason4"/></li>
    </ol>

</rhn:require>

</body>
</html>