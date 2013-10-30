<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
<body>

<h1><img src="/img/rhn-icon-warning.gif"/><bean:message key="baddownload.jsp.title"/></h1>

<p><bean:message key="baddownload.jsp.summary"/></p>
    <ol>
      <li><bean:message key="baddownload.jsp.reason1"/></li>
      <li><bean:message key="baddownload.jsp.reason2"/></li>
      <li><bean:message key="baddownload.jsp.reason3"/></li>
    </ol>
<p><bean:message key="baddownload.jsp.retry"/></p>


</body>
</html>
