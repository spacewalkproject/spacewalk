<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>

<rhn:toolbar base="h1" icon="fa-desktop" imgAlt="audit.jsp.alt"
 helpUrl="/rhn/help/reference/en-US/s2-sm-system-overview.jsp">
  <bean:message key="audit.overview.jsp.header"/>
</rhn:toolbar>
<%--
<div style="font-weight: bold; text-align: center;">Machine: <c:out value="${machine}" /></div>
--%>
<rl:listset name="auditList">
    <rhn:csrf />
    <rl:list>
        <rl:column sortable="true"
                   sortattr="name"
                   bound="false"
                   headertext="Machine">
            <span style='font-family: Courier, Monospace;'>
                <a href="Search.do?machine=${current.name}&amp;startMilli=${current.start.time}&amp;endMilli=${current.end.time}"><c:out value="${current.name}" /></a>
            </span>
        </rl:column>
        <rl:column sortable="true"
                   sortattr="start"
                   defaultsort="desc"
                   bound="false"
                   headertext="Start">
            <span style='font-family: Courier, Monospace;'>
                <c:out value="${current.start}" escapeXml="true" />
            </span>
        </rl:column>
        <rl:column sortable="false"
                   bound="false"
                   headertext="End">
            <span style='font-family: Courier, Monospace;'>
                <c:out value="${current.end}" escapeXml="true" />
            </span>
        </rl:column>
        <rl:column sortable="true"
                   sortattr="reviewedOn"
                   bound="false"
                   headertext="Reviewed on">
            <span style='font-family: Courier, Monospace;'>
                <c:out value="${current.reviewedOn}" escapeXml="true" />
            </span>
        </rl:column>
        <rl:column sortable="true"
                   sortattr="reviewedBy"
                   bound="false"
                   headertext="Reviewed by">
            <span style='font-family: Courier, Monospace;'>
                <c:out value="${current.reviewedBy}" escapeXml="true" />
            </span>
        </rl:column>
    </rl:list>

    <input type="hidden" name="machine" value="${machine}" />
</rl:listset>

</body>
</html>

