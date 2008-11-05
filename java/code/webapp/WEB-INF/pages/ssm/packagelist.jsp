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
    <bean:message key="ssm.package.install.selectpackages.header"/>
</h2>

<div class="page-summary">
    <p><bean:message key="ssm.package.install.selectpackages.summary"/></p>

    <rhn:require acl="org_entitlement(rhn_nonlinux)">
        <p><bean:message key="ssm.package.install.selectpackages.answerfiles"/></p>
    </rhn:require>

    <rhn:require acl="org_entitlement(rhn_nonlinux) or org_entitlement(rhn_provisioning)">
        <p><bean:message key="ssm.package.install.selectpackages.remotecommand"/></p>
    </rhn:require>
</div>

<rl:listset name="groupSet" legend="system-group">
    <rl:list dataset="pageList"
             width="100%"
             name="groupList"
             styleclass="list"
             emptykey="packagelist.jsp.nopackages">

        <rl:decorator name="PageSizeDecorator"/>
        <rl:decorator name="SelectableDecorator"/>

        <rl:selectablecolumn value="${current.selectionKey}"
                             selected="${current.selected}"
                             disabled="${not current.selectable}"
                             styleclass="first-column"/>

        <rl:column headerkey="packagelist.jsp.packagename" bound="false"
                   sortattr="nvre" sortable="true" filterattr="name">
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

    <div align="right">
        <rhn:submitted/>
        <hr/>
        <input type="submit"
               name="dispatch"
               value='<bean:message key="installpkgs.jsp.installpackages"/>'/>

        <rhn:require acl="org_entitlement(rhn_nonlinux)">
            <input type="submit"
                   name="remote"
                   value='<bean:message key="ssm.package.install.selectpackages.answerfiles.button"/>'/>
        </rhn:require>

        <rhn:require
                acl="org_entitlement(rhn_nonlinux) or org_entitlement(rhn_provisioning)">
            <input type="submit"
                   name="remote"
                   value='<bean:message key="ssm.package.install.selectpackages.remotecommand.button"/>'/>
        </rhn:require>

    </div>


</rl:listset>


</body>
</html>
