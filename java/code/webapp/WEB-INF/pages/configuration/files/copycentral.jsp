<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/configuration/files/header.jspf" %>
<h2><bean:message key="copycentral.jsp.header"/></h2>

<div class="page-summary">
  <p>
    <bean:message key="copycentral.jsp.summary" arg0="/rhn/configuration/file/FileDetails.do?cfid=${file.id}&amp;crid=${revision.id}" arg1="${revision.revision}"/>
    <br />
    <bean:message key="copycentral.jsp.select" />
  </p>
</div>

<form method="post" name="rhn_list" action="/rhn/configuration/file/CopyFileCentralSubmit.do?type=${requestScope.type}&amp;cfid=${file.id}&amp;crid=${revision.id}">
  <rhn:csrf />
  <jsp:include page="/WEB-INF/pages/common/fragments/configuration/files/copyfile_rows.jsp" />
</form>

</body>
</html>

