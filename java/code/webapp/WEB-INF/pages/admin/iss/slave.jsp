<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<html:html>
    <body>
        <rhn:toolbar base="h1" icon="icon-info-sign"
                     creationUrl="/rhn/admin/iss/EditMaster.do" creationType="master"
                     creationAcl="user_role(satellite_admin)">
            <bean:message key="iss.slave.jsp.toolbar" />
        </rhn:toolbar>
        <p><bean:message key="iss.slave.jsp.explanation" /></p>
        <rhn:dialogmenu mindepth="0" maxdepth="1"
                        definition="/WEB-INF/nav/iss_config.xml"
                        renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
        <c:set var="pageList" value="${requestScope.all}" />
        <h2><bean:message key="iss.slave.jsp.header2" /></h2>
        <rl:listset name="issMasterListSet">
            <rhn:csrf />
            <rhn:submitted />
            <rl:list dataset="pageList" name="issMasterList"
                     emptykey="iss.slave.jsp.nomasters">
                <rl:decorator name="SelectableDecorator" />
                <rl:selectablecolumn value="${current.selectionKey}"
                                     selected="${current.selected}" />
                <rl:column sortable="true" headerkey="iss.master.label" sortattr="label">
                    <html:link href="/rhn/admin/iss/EditMaster.do?id=${current.id}">
                        <c:out value="${current.label}" />
                    </html:link>
                </rl:column>
                <rl:column bound="false" headerkey="iss.master.isDefault"
                           styleclass="center" headerclass="center">
                    <c:if test="${current.defaultMaster}">
                        <img src="/img/rhn-listicon-checked.gif"
                             alt="<bean:message key="iss.master.isDefault"/>"
                             title="<bean:message key="iss.master.isDefault"/>" />
                    </c:if>
                    <c:if test="${not current.defaultMaster}">
                        <img src="/img/rhn-listicon-unchecked.gif"
                             alt="<bean:message key="iss.master.notDefault"/>"
                             title="<bean:message key="iss.master.notDefault"/>" />
                    </c:if>
                </rl:column>
                <rl:column headerkey="iss.num.master.orgs" styleclass="center" headerclass="center">
                    <c:out value="${current.numMasterOrgs}" />
                </rl:column>
                <rl:column headerkey="iss.num.unmapped.orgs" styleclass="center" headerclass="center">
                    <c:out value="${current.numMasterOrgs - current.numMappedMasterOrgs}" />
                </rl:column>
            </rl:list>
            <c:if test="${not empty requestScope.all}">
                <div class="text-right">
                    <rhn:submitted />
                    <input type="submit" name="dispatch" class="btn btn-default"
                           value='<bean:message key="iss.master.remove"/>' />
                </div>
            </c:if>
        </rl:listset>
    </body>
</html:html>
