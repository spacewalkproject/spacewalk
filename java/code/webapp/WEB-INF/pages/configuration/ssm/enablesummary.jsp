<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
  <rhn:icon type="header-configuration" title="<bean:message key='ssmdiff.jsp.imgAlt' />" />
  <bean:message key="summary.jsp.toolbar"/>
</h2>

<div class="page-summary">
  <p>
  <bean:message key="summary.jsp.summary" />
  <ol>
    <li><bean:message key="summary.jsp.stepone" />
    <li><bean:message key="summary.jsp.steptwo" />
  </ol>
  </p>
</div>

<div>
<form method="post" name="rhn_list"
      action="/rhn/systems/ssm/config/EnableSummary.do">
  <rhn:csrf />
  <rhn:submitted />
  <%@ include file="/WEB-INF/pages/common/fragments/configuration/enablesummary.jspf" %>
</form>
</div>

</body>
</html>

