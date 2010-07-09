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
<rhn:toolbar base="h1" img="/img/rhn-icon-errata.gif"
	           helpUrl="/rhn/help/channel-mgmt/en-US/channel-mgmt-Custom_Errata_Management.jsp">
    <bean:message key="errata.publish.toolbar"/> <c:out value="${advisory}" />
  </rhn:toolbar>

  <p><bean:message key="errata.publish.packagepush.description" arg0="${requestScope.channel_name}"/></p>
<c:set var="pageList" value="${requestScope.pageList}" />
<html:form action="/errata/manage/AddChannelPackagePushSubmit">
<%@ include file="/WEB-INF/pages/common/fragments/errata/packagepush.jspf" %>
</html:form>
</body>
</html>
