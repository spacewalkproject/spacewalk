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
    <bean:message key="ssm.package.install.selectpackages.header"/>
</h2>

<div class="page-summary">
    <p><bean:message key="ssm.package.install.selectpackages.summary"/></p>
</div>

<rl:listset name="groupSet" legend="system-group">
    <rhn:csrf />
    <rl:list dataset="pageList"
             width="100%"
             styleclass="list"
             emptykey="packagelist.jsp.nopackages">

        <rl:decorator name="PageSizeDecorator"/>
        <rl:decorator name="SelectableDecorator"/>

        <rl:selectablecolumn value="${current.selectionKey}"
                             selected="${current.selected}"
                             disabled="${not current.selectable}"/>

        <rl:column headerkey="packagelist.jsp.packagename" bound="false"
                   sortattr="nvre" sortable="true" filterattr="nvre">
            <c:out value="${current.nvre}" escapeXml="false"/>
        </rl:column>

        <rl:column headerkey="packagelist.jsp.packagearch" bound="false"
                   styleclass="thin-column last-column">
            <c:choose>
                <c:when test="${not empty current.arch}">${current.arch}</c:when>
                <c:otherwise><bean:message
                        key="packagelist.jsp.notspecified"/></c:otherwise>
            </c:choose>
        </rl:column>
    </rl:list>

    <div class="text-right">
        <rhn:submitted/>
        <hr/>
        <input type="submit"
               name="dispatch"
               value='<bean:message key="installpkgs.jsp.installpackages"/>'/>
    </div>

</rl:listset>
<html:hidden property="cid" value="${param.cid}" />
<html:hidden property="mode" value="${param.mode}" />

</body>
</html>
