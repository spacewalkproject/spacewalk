<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<head>
<meta http-equiv="Pragma" content="no-cache" />
</head>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/advanced/header.jspf"%>
<div>

  <table class="details" border="0">
    <tr><td>
      <h2><bean:message key="kickstartdownload.jsp.header"/></h2>
          <bean:message key="kickstartdownload.jsp.summary"/>

    </td></tr>

        <tr><td>
          <a href="${ksurl}" target="_new"><bean:message key="kickstartdownload.jsp.download"/></a>

        </td></tr>
        <tr><td>
          <pre style="overflow: scroll;">${filedata}</pre>
        </td></tr>
  </table>
</div>


</body>
</html:html>