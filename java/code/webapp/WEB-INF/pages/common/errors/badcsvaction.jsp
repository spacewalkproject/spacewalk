<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
<body>

<rhn:require acl="user_authenticated()">

<h1><img src="/img/rhn-icon-warning.gif"/><bean:message key="badcsvaction.jsp.title"/></h1>

<p><bean:message key="badcsvaction.jsp.summary"/></p>
    <ol>
      <li><bean:message key="badcsvaction.jsp.reason1"/></li>
      <li><bean:message key="badcsvaction.jsp.reason2"/></li>
      <li><bean:message key="badcsvaction.jsp.reason3"/></li>
    </ol>
<p><bean:message key="badcsvaction.jsp.retry"/></p>

</rhn:require>

</body>
</html>
