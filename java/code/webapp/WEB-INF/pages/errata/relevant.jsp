<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<head>
</head>
<body>
<rhn:toolbar base="h1" icon="header-errata" iconAlt="errata.common.errataAlt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-errata.jsp#s2-sm-applicable-errata">
  <bean:message key="erratalist.jsp.relevanterrata"/>
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="3" definition="/WEB-INF/nav/errata_relevant_tabs.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<p><bean:message key="errata.overview.jsp.summary"/></p>

<c:set var="emptyListKey" value="erratalist.jsp.norelevanterrata"/>
<%@ include file="/WEB-INF/pages/common/fragments/errata/relevant-errata-list.jspf" %>

</body>
</html>
