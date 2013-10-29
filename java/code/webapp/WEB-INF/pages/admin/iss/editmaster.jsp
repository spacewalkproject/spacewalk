<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>
<html:html>
    <body>
        <c:choose>
            <c:when test="${requestScope.id > 0}">
                <rhn:toolbar base="h1" icon="fa-info-circle"
                             deletionUrl="/rhn/admin/iss/RemoveMasterConfirm.do?mid=${requestScope.id}"
                             deletionType="master" deletionAcl="user_role(satellite_admin)">
                    <bean:message key="iss.editmaster.jsp.toolbar" />
                </rhn:toolbar>
            </c:when>
            <c:otherwise>
                <rhn:toolbar base="h1" icon="fa-info-circle">
                    <bean:message key="iss.editmaster.jsp.toolbar" />
                </rhn:toolbar>
            </c:otherwise>
        </c:choose>
        <p><bean:message key="iss.editmaster.jsp.explanation" /></p>
        <rhn:dialogmenu mindepth="0" maxdepth="1"
                        definition="/WEB-INF/nav/iss_config.xml"
                        renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
        <html:form action="/admin/iss/UpdateMaster.do" styleClass="form-horizontal">
            <rhn:csrf />
            <html:hidden property="id" />
            <rhn:submitted />
            <h2>
                <c:choose>
                    <c:when test="${requestScope.id > 0}">
                        <bean:message key="iss.editmaster.jsp.details.header" arg0="${requestScope.master}" />
                    </c:when>
                    <c:otherwise>
                        <bean:message key="iss.editmaster.jsp.newmaster.details.header" />
                    </c:otherwise>
                </c:choose>
            </h2>
            <c:choose>
                <c:when test="${empty requestScope.id or requestScope.id < 0}">
                    <div class="form-group">
                        <label class="col-lg-3 control-label" for="label">
                            <rhn:required-field  key="iss.master.label" />:
                        </label>
                        <div class="col-lg-6">
                            <html:text property="label" styleId="label" styleClass="form-control" />
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <html:hidden property="label" />
                </c:otherwise>
            </c:choose>

            <div class="form-group">
                <label for="caCert" class="col-lg-3 control-label">
                    <bean:message key="iss.master.cacert" />
                </label>
                <div class="col-lg-6">
                    <html:text property="caCert" styleId="caCert" maxlength="1024" size="50" styleClass="form-control" />
                    <span class="help-block">
                        <bean:message key="iss.master.cacert.note"/>
                    </span>
                </div>
            </div>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <div class="checkbox">
                        <label>
                            <html:checkbox property="defaultMaster"
                                           styleId="defaultMaster" />
                            <bean:message key="iss.master.isDefault" />
                        </label>
                    </div>
                </div>
            </div>

            <c:choose>
                <c:when test="${requestScope.id > 0}">
                    <h2><bean:message key="iss.editmaster.jsp.maporgs.header" arg0="${requestScope.master}" /></h2>
                    <p><bean:message key="iss.editmaster.jsp.maporgs.explanation" /></p>
                    <rl:listset name="issMasterListSet">
                        <rl:list dataset="all" name="issMasterList"
                                 emptykey="iss.editmaster.jsp.nomasterorgs">
                            <rl:column sortable="true" headerkey="iss.master.org.name"
                                       sortattr="sourceOrgName">
                                <c:out value="${current.masterOrgName}" />
                            </rl:column>
                            <rl:column headerkey="iss.slave.orgs" styleclass="center"
                                       headerclass="center">
                                <select name="${current.id}" class="form-control">
                                    <c:forEach var="localOrg" items="${requestScope.slave_org_list}">
                                        <c:choose>
                                            <c:when test="${localOrg.id == current.localOrg.id}">
                                                <option value="${localOrg.id}" selected>
                                                </c:when>
                                                <c:otherwise>
                                                <option value="${localOrg.id}">
                                                </c:otherwise>
                                            </c:choose>
                                            <c:out value="${localOrg.name}" />
                                        </option>
                                    </c:forEach>
                                </select>
                            </rl:column>
                        </rl:list>
                        <div class="form-group">
                            <div class="col-lg-offset-3 col-lg-6">
                                <input type="submit" name="dispatch" class="btn btn-success"
                                       value='<bean:message key="iss.master.update"/>' />
                            </div>
                        </div>
                    </rl:listset>
                </c:when>
                <c:otherwise>
                    <div class="form-group">
                        <div class="col-lg-offset-3 col-lg-6">
                            <html:submit styleClass="btn btn-success">
                                <bean:message key="iss.master.create" />
                            </html:submit>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </html:form>
    </body>
</html:html>
