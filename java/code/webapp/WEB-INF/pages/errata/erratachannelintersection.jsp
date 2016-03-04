<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<html>
<head>
</head>
<body>
    <rhn:toolbar base="h1" icon="header-errata" helpUrl="">
        <bean:message key="header.jsp.errata"/> <c:out value="${advisory}" />
    </rhn:toolbar>

    <p><bean:message key="errata.channel.intersection.summary" arg0="${fn:escapeXml(channel)}" arg1="${fn:escapeXml(advisory)}" /></p>

    <h2><rhn:icon type="header-package"/><bean:message key="channels.overview.packages"/></h2>

    <rhn:list pageList="${requestScope.pageList}" noDataText="packagelist.jsp.nopackages">
        <rhn:listdisplay>
        <rhn:column header="packagelist.jsp.packagename">
            <c:out value="${current.name}"/>
        </rhn:column>

        <rhn:column header="errata.channel.intersection.channel_version">
            <c:out value="${current.channel_version}"/>
        </rhn:column>

        <rhn:column header="errata.channel.intersection.errata_version">
            <c:out value="${current.errata_version}"/>
        </rhn:column>
        </rhn:listdisplay>
    </rhn:list>
</body>
</html>
