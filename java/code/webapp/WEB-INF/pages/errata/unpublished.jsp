<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:html xhtml="true">
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-icon-errata.gif" imgAlt="errata.common.errataAlt"
 helpUrl="/rhn/help/channel-mgmt/en/channel-mgmt-Manage_Errata-Unpublished_Errata.jsp"
 creationUrl="/rhn/errata/manage/Create.do"
 creationType="erratum">
  <bean:message key="erratalist.jsp.erratamgmt"/>
</rhn:toolbar>

<h2><bean:message key="erratalist.jsp.unpublishederrata"/></h2>

<div class="page-summary">
    <bean:message key="erratalist.jsp.ownederratapagesummary"/>
</div>
<c:set var="pageList" value="${requestScope.pageList}" />

<%@ include file="/WEB-INF/pages/common/fragments/errata/ownedlistdisplay.jspf" %>

</body>
</html:html>

