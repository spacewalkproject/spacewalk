<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:html >
<head>
</head>
<body>
<rhn:toolbar base="h1" icon="header-errata" iconAlt="errata.common.errataAlt"
 helpUrl="/rhn/help/getting-started/en-US/chap-Getting_Started_Guide-Errata_Management.jsp"
 creationUrl="/rhn/errata/manage/Create.do"
 creationType="erratum">
  <bean:message key="erratalist.jsp.erratamgmt"/>
</rhn:toolbar>

<h2><bean:message key="erratalist.jsp.unpublishederrata"/></h2>

<div class="page-summary">
    <bean:message key="erratalist.jsp.ownederratapagesummary"/>
</div>
<c:set var="pageList" value="${requestScope.pageList}" />
<c:set var="emptyListKey" value="erratalist.jsp.nounpublishederrata"/>

<%@ include file="/WEB-INF/pages/common/fragments/errata/ownedlistdisplay.jspf" %>

</body>
</html:html>

