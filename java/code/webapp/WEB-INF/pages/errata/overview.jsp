<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-errata.gif" imgAlt="errata.overview.jsp.alt"
 helpUrl="/rhn/help/reference/en-US/s1-sm-errata.jsp">
  <bean:message key="errata.overview.jsp.errataoverview"/>
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="3" definition="/WEB-INF/nav/errata_overview_tabs.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<p><bean:message key="errata.overview.jsp.summary"/></p>

<h2><bean:message key="errata.jsp.header"/></h2>

<%@ include file="/WEB-INF/pages/common/fragments/errata/relevant-errata-list.jspf" %>

</body>
</html>
