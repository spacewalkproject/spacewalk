<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

<rhn:toolbar base="h2" icon="header-package"
    deletionUrl="/rhn/systems/details/packages/profiles/DeleteProfile.do?sid=${param.sid}&prid=${param.prid}"
    deletionType="profile">
  <bean:message key="compare.jsp.compareto" arg0="${fn:escapeXml(requestScope.profilename)}" />
</rhn:toolbar>

    <div class="page-summary">
    <bean:message key="compare.jsp.pagesummary" />
    </div>

    <rl:listset name="compareListSet">
        <rhn:csrf />

            <rl:list dataset="pageList"
            width="100%"
            name="compareList"
            emptykey="compare.jsp.nodifferences">

            <rl:decorator name="SelectableDecorator"/>
            <rl:selectablecolumn value="${current.selectionKey}"
                                selected="${current.selected}"
                                disabled="${not current.selectable}"/>

            <rl:column headerkey="compare.jsp.package" bound="false" filterattr="name">
                ${current.name}
            </rl:column>

            <rl:column headerkey="packagelist.jsp.packagearch" bound="false">
                ${current.arch}
            </rl:column>

            <rl:column headerkey="compare.jsp.thissystem" bound="false">
                ${current.system.evr}
            </rl:column>

            <rl:column headertext="${requestScope.profilename}" bound="false">
                ${current.other.evr}
            </rl:column>

            <rl:column headerkey="compare.jsp.difference" bound="false">
                ${current.comparison}
            </rl:column>
        </rl:list>

         <rl:csv dataset="pageList"
                        name="pageList"
                        exportColumns="name,arch,system.evr,other.evr,comparison"/>

        <c:if test="${not empty requestScope.pageList}">
            <rhn:require acl="system_feature(ftr_delta_action)"
                mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">
                <div class="text-right">
                    <rhn:submitted/>
                    <hr />
                    <input class="btn btn-default" type="submit" name="dispatch" class="btn btn-primary"
                        value="<bean:message key="compare.jsp.syncpackageto" arg0="${fn:escapeXml(requestScope.profilename)}"/>" />
                </div>
            </rhn:require>

            <rhn:require acl="not system_feature(ftr_delta_action)"
                mixins="com.redhat.rhn.common.security.acl.SystemAclHandler">
                <div align="left">
                    <hr />
                    <strong><bean:message key="compare.jsp.noprovisioning"
                        arg0="${system.name}" arg1="${param.sid}"/></strong>
                </div>
            </rhn:require>
        </c:if>

        <html:hidden property="sid" value="${param.sid}" />
        <html:hidden property="prid" value="${param.prid}" />
    </rl:listset>
</body>
</html>
