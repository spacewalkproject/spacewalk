<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<rhn:toolbar base="h1" icon="spacewalk-icon-patches" iconAlt="errata.common.errataAlt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-errata.jsp#s2-sm-all-errata">
  <bean:message key="erratalist.jsp.allerrata"/>
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="3" definition="/WEB-INF/nav/errata_all_tabs.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<p><bean:message key="errata.all.jsp.summary"/></p>

<c:set var="emptyListKey" value="erratalist.jsp.noerrata"/>
<%@ include file="/WEB-INF/pages/common/fragments/errata/relevant-errata-list.jspf" %>

</body>
</html>
