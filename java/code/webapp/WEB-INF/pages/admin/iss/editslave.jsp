<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<html:html>
    <body>
        <c:choose>
            <c:when test="${requestScope.sid > 0}">
                <rhn:toolbar base="h1" icon="fa-info-circle"
                             deletionUrl="/rhn/admin/iss/RemoveSlaveConfirm.do?sid=${requestScope.sid}"
                             deletionType="slave" deletionAcl="user_role(satellite_admin)">
                    <bean:message key="iss.editslave.jsp.toolbar" />
                </rhn:toolbar>
            </c:when>
            <c:otherwise>
                <rhn:toolbar base="h1" icon="fa-info-circle">
                    <bean:message key="iss.editslave.jsp.toolbar" />
                </rhn:toolbar>
            </c:otherwise>
        </c:choose>
        <p><bean:message key="iss.editslave.jsp.explanation" /></p>
        <rhn:dialogmenu mindepth="0" maxdepth="1"
                        definition="/WEB-INF/nav/iss_config.xml"
                        renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
        <h2><bean:message key="iss.editslave.jsp.header2" /></h2>
        <html:form action="/admin/iss/UpdateSlave" styleClass="form-horizontal" >
            <rhn:csrf />
            <html:hidden property="submitted" value="true" />
            <html:hidden property="id" />
            <div class="form-group">
                <label for="slave" class="col-lg-3 control-label">
                    <rhn:required-field key="iss.slave.name" />
                </label>
                <div class="col-lg-6">
                    <html:text property="slave" size="45" maxlength="256"
                               styleId="slave" styleClass="form-control" />
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <div class="checkbox">
                        <label>
                            <html:checkbox property="enabled" styleId="enabled" />
                            <bean:message key="iss.slave.isEnabled" />
                        </label>
                    </div>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <div class="checkbox">
                        <label>
                            <html:checkbox property="allowAllOrgs"
                                           styleId="allowAllOrgs" />
                            <bean:message key="iss.slave.toAll" />
                        </label>
                    </div>
                </div>
            </div>

            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <html:submit styleClass="btn btn-success">
                        <c:choose>
                            <c:when test="${requestScope.sid > 0}">
                                <bean:message key="iss.slave.edit" />
                            </c:when>
                            <c:otherwise>
                                <bean:message key="iss.slave.create" />
                            </c:otherwise>
                        </c:choose>
                    </html:submit>
                </div>
            </div>
        </html:form>
        <c:if test="${requestScope.sid > 0}">
            <h2><bean:message key="iss.editslave.jsp.allowed.orgs.header" /></h2>
            <rl:listset name="localOrgsListSet">
                <rhn:csrf />
                <rhn:submitted />
                <rl:list dataset="localOrgsList" name="localOrgsList"
                         emptykey="editslave.jsp.nolocalorgs">
                    <rl:decorator name="SelectableDecorator" />
                    <rl:selectablecolumn value="${current.selectionKey}"
                                         selected="${current.selected}" />
                    <rl:column sortable="true" headerkey="iss.localorg.name" sortattr="name">
                        <c:out value="${current.name}" />
                    </rl:column>
                </rl:list>
                <div class="form-group">
                    <div class="col-lg-offset-3 col-lg-6">
                        <rhn:submitted />
                        <input type="submit" name="dispatch" class="btn btn-success"
                               value='<bean:message key="iss.slave.associate"/>' />
                    </div>
                </div>
            </rl:listset>
        </c:if>
    </body>
</html:html>

