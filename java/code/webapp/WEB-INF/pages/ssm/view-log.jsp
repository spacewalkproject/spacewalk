<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>
<rhn:toolbar base="h1"
    icon="header-system-groups"
	imgAlt="ssm.jsp.imgAlt"
	helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s2-sm-ssm">
	<bean:message key="ssm.jsp.header" />
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/ssm_status.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
<h2>
    <bean:message key="ssm.operations.viewlog.header"/>
</h2>

<div class="page-summary">
    <p><bean:message key="${summaryKey}"/></p>
    <p><bean:message key="ssm.operations.viewlog.note"/></p>
</div>

<rl:listset name="groupSet">
    <rhn:csrf />
    <rhn:submitted />

    <rl:list dataset="pageList"
             width="100%"
             name="groupList"
             styleclass="list"
             emptykey="ssm.operations.viewlog.empty">

        <rl:decorator name="PageSizeDecorator"/>

        <rl:column headerkey="ssm.operations.viewlog.description" bound="false"
                   sortattr="description" sortable="true">
            <a href="/rhn/ssm/ViewLogDetails.do?oid=${current.id}"><c:out value="${current.translatedDescription}"/></a>
        </rl:column>

        <rl:column headerkey="ssm.operations.viewlog.status" bound="false">
            <c:if test="${current.status eq 'In Progress'}">
                <bean:message key="ssm.operations.viewlog.inprogress"/>
            </c:if>
            <c:if test="${current.status eq 'Completed'}">
                <bean:message key="ssm.operations.viewlog.completed"/>
            </c:if>
        </rl:column>

        <rl:column headerkey="ssm.operations.viewlog.modified" bound="false">
            <c:out value="${current.modifiedDateString}"/>
        </rl:column>

    </rl:list>

</rl:listset>

</body>
</html>
