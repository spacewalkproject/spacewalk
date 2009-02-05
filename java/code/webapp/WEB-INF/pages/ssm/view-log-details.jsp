<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>

<html:errors/>

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
        <td><c:out value="${operationData.status}"/></td>
    </tr>
    <tr>
        <td><b><bean:message key="ssm.operations.viewlog.progress"/></b></td>
        <td><c:out value="${operationData.progress}%"/></td>
    </tr>
    <tr>
        <td><b><bean:message key="ssm.operations.viewlog.started"/></b></td>
        <td><c:out value="${operationData.started}"/></td>
    </tr>
    <tr>
        <td><b><bean:message key="ssm.operations.viewlog.modified"/></b></td>
        <td><c:out value="${operationData.modified}"/></td>
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
            <a href="/network/systems/details/history/history.pxt?sid=${current.id}"><c:out value="${current.name}"/></a>
        </rl:column>

    </rl:list>

</rl:listset>

</body>
</html>
