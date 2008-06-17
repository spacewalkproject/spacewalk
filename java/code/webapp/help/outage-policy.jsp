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
<h1>
  <img src="/img/rhn-icon-info.gif"
       alt="<bean:message key='system.common.infoAlt' />" />
  <bean:message key="outage-policy.jsp.header"/>
</h1>
<p><bean:message key="outage-policy.jsp.intro"/></p>

<h2><bean:message key="outage-policy.jsp.scheduled-header"/></h2>
<p><bean:message key="outage-policy.jsp.scheduled"/></p>

<h2><bean:message key="outage-policy.jsp.unscheduled-header"/></h2>
<p><bean:message key="outage-policy.jsp.unscheduled"/></p>

<h2><bean:message key="outage-policy.jsp.emergency-header"/></h2>
<p><bean:message key="outage-policy.jsp.emergency"/></p>

<h2><bean:message key="outage-policy.jsp.notification-header"/></h2>
<p><bean:message key="outage-policy.jsp.notification" arg0="http://www.redhat.com/mailman/listinfo/rhn-outage-list"/></p>

</body>
</html>