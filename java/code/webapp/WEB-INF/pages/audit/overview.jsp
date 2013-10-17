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

<rhn:toolbar base="h1" icon="icon-desktop" imgAlt="audit.jsp.alt"
 helpUrl="/rhn/help/reference/en-US/s2-sm-system-overview.jsp">
  <bean:message key="audit.overview.jsp.header"/>
</rhn:toolbar>

<rl:listset name="auditList">
    <rhn:csrf />
    <rl:list>
        <rl:column sortable="true"
                   sortattr="name"
                   bound="false"
                   headertext="Machine">
            <span style='font-family: Courier, Monospace;'>
                <a href="Machine.do?machine=${current.name}"><c:out value="${current.name}" escapeXml="true" /></a>

                <c:if test="${current.needsReview}">
                    <c:out value=" <b>(!!)</b>" escapeXml="false" />
                </c:if>
            </span>
        </rl:column>
        <rl:column sortable="true"
                   sortattr="lastReview"
                   bound="false"
                   headertext="Last checked on">
            <span style='font-family: Courier, Monospace;'>
                <c:out value="${current.lastReview}" escapeXml="true" />
            </span>
        </rl:column>
    </rl:list>
</rl:listset>

</body>
</html>

