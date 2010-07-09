<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1"
    img="/img/rhn-icon-system_group.gif"
	imgAlt="ssm.jsp.imgAlt"
	helpUrl="/rhn/help/reference/en-US/s1-sm-systems.jsp#s2-sm-ssm">
	<bean:message key="ssm.jsp.header" />
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/ssm_status.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
<h2>
    <bean:message key="ssm.operations.viewlog.header"/>
</h2>

<table>
    <tr>
        <td><b><bean:message key="ssm.operations.viewlog.description"/></b></td>
        <td><c:out value="${operationData.description}"/></td>
    </tr>
    <tr>
        <td><b><bean:message key="ssm.operations.viewlog.status"/></b></td>
        <td>
            <c:if test="${operationData.status eq 'In Progress'}">
                <bean:message key="ssm.operations.viewlog.inprogress"/>
            </c:if>
            <c:if test="${operationData.status eq 'Completed'}">
                <bean:message key="ssm.operations.viewlog.completed"/>
            </c:if>
        </td>
    </tr>
    <tr>
        <td><b><bean:message key="ssm.operations.viewlog.started"/></b></td>
        <td><c:out value="${operationData.startedDateString}"/></td>
    </tr>
    <tr>
        <td><b><bean:message key="ssm.operations.viewlog.modified"/></b></td>
        <td><c:out value="${operationData.modifiedDateString}"/></td>
    </tr>
</table>

<rl:listset name="groupSet">

    <rl:list dataset="pageList"
             width="100%"
             name="groupList"
             styleclass="list"
             emptykey="ssm.operations.viewlog.emptyservers">

        <rl:decorator name="PageSizeDecorator"/>

        <rl:column headerkey="ssm.operations.viewlog.servers" bound="false">
            <a href="/network/systems/details/history/history.pxt?sid=${current.id}"><c:out
                    value="${current.name}"/></a>
        </rl:column>

    </rl:list>

</rl:listset>

</body>
</html>
