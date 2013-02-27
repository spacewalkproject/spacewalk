<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<html:html xhtml="true">
<body>
  <rhn:toolbar base="h1" img="/img/icon_bug.gif" imgAlt="info.alt.img"
               deletionUrl="SoftwareCrashDelete.do?crid=${crid}"
               deletionType="crash">
    ${fn:escapeXml(crash.crash)}
  </rhn:toolbar>
  <h2><bean:message key="crashes.jsp.details"/></h2>

<div class="page-summary">
  <p><bean:message key="crashes.jsp.details.summary"/></p>
</div>

<%@ include file="/WEB-INF/pages/common/fragments/systems/crash_details.jspf" %>

</body>
</html:html>
