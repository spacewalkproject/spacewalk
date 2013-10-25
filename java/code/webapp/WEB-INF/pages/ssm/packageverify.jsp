<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
    <bean:message key="ssm.package.verify.select.header"/>
</h2>

<div class="page-summary">
    <p><bean:message key="ssm.package.verify.select.summary"/></p>
</div>

<rl:listset name="groupSet" legend="system-group">
    <rhn:csrf />
    <rl:list dataset="pageList"
             width="100%"
             styleclass="list"
             emptykey="packagelist.jsp.nopackages"
             alphabarcolumn="nvre">

        <rl:decorator name="PageSizeDecorator"/>
        <rl:decorator name="SelectableDecorator"/>

        <rl:selectablecolumn value="${current.selectionKey}"
                             selected="${current.selected}"
                             disabled="${not current.selectable}"/>

        <rl:column headerkey="packagelist.jsp.packagename" bound="false"
                   sortattr="nvre" sortable="true" filterattr="nvre">
            <c:out value="${current.nvre}" escapeXml="false"/>
        </rl:column>

        <rl:column headerkey="packagelist.jsp.packagearch" bound="false">
            <c:choose>
                <c:when test="${not empty current.arch}">${current.arch}</c:when>
                <c:otherwise><bean:message
                        key="packagelist.jsp.notspecified"/></c:otherwise>
            </c:choose>
        </rl:column>

        <rl:column headerkey="ssm.package.verify.select.numsystems" bound="false"
                   styleclass="thin-column last-column">
            <c:out value="${current.numSystems}"/>
        </rl:column>

    </rl:list>

    <div class="text-right">
        <rhn:submitted/>
        <hr/>
        <input type="submit"
               name="dispatch"
               value='<bean:message key="ssm.package.verify.select.confirm"/>'/>
    </div>

</rl:listset>

</body>
</html>
