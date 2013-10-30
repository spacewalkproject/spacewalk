<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html >
<head>
<meta http-equiv="Pragma" content="no-cache" />
</head>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/advanced/header.jspf"%>
<div class="page-summary">
<c:choose>
  <c:when test="${fileerror != null}">
    <h2><bean:message key="kickstartdownload.jsp.header.error"/></h2>
    <table class="details" border="0">
      <tr><td>
        <pre class="warning" style="overflow: scroll; width: 800px; height: 800px">${fileerror}</pre>
      </td></tr>
    </table>
  </c:when>
  <c:otherwise>
    <h2><bean:message key="kickstartdownload.jsp.header"/></h2>
    <p><bean:message key="kickstartdownload.jsp.summary"/></p>
    <table class="details" border="0">
      <tr><td>
        <a href="${ksurl}" target="_new"><bean:message key="kickstartdownload.jsp.download"/></a>
      </td></tr>
      <tr><td>
        <pre style="overflow: scroll; width: 800px; height: 800px">${filedata}</pre>
      </td></tr>
  </table>
  </c:otherwise>
</c:choose>
</div>

</body>
</html:html>
