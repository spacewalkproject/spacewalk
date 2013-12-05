<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:html >
    <head></head>
    <body>
        <c:choose>
            <c:when test="${param.oid != 1}">
                <rhn:toolbar base="h1" icon="fa-group"
                             miscUrl="${url}"
                             miscAcl="user_role(org_admin)"
                             miscText="${text}"
                             miscImg="${img}"
                             miscAlt="${text}"
                             deletionUrl="/rhn/admin/multiorg/DeleteOrg.do?oid=${param.oid}"
                             deletionAcl="user_role(satellite_admin)"
                             deletionType="org"
                             imgAlt="users.jsp.imgAlt">
                    <c:out escapeXml="true" value="${org.name}" />
                </rhn:toolbar>
            </c:when>
            <c:otherwise>
                <rhn:toolbar base="h1" icon="fa-group"
                             miscUrl="${url}"
                             miscAcl="user_role(org_admin)"
                             miscText="${text}"
                             miscImg="${img}"
                             miscAlt="${text}"
                             imgAlt="users.jsp.imgAlt">
                    <c:out escapeXml="true" value="${org.name}" />
                </rhn:toolbar>
            </c:otherwise>
        </c:choose>

        <rhn:dialogmenu mindepth="0" maxdepth="2" definition="/WEB-INF/nav/org_tabs.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

        <html:form action="/admin/multiorg/OrgDetails?oid=${oid}"
                   styleClass="form-horizontal">
            <rhn:csrf />
            <html:hidden property="submitted" value="true"/>
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h4><bean:message key="orgdetails.jsp.header"/></h4>
                </div>
                <div class="panel-body">
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="org.name.jsp"/>:
                        </label>
                        <c:choose>
                            <c:when test="${param.oid != 1}">
                                <div class="col-lg-6">
                                    <html:text property="orgName" styleClass="form-control" maxlength="128" size="40" />
                                    <span class="help-block"><strong>Tip:</strong>Between 3 and 128 characters</span>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <span class=""><bean:write name="orgDetailsForm" property="orgName"/></td>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label"><bean:message key="org.id.jsp"/>:</label>
                        <div class="col-lg-6">
                            <bean:write name="orgDetailsForm" property="id"/>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label">
                            <bean:message key="org.active.users.jsp"/>:
                        </label>
                        <div class="col-lg-6">
                            <a class="btn btn-default btn-sm" href="/rhn/admin/multiorg/OrgUsers.do?oid=${param.oid}"><i class="fa fa-group"></i><bean:write name="orgDetailsForm" property="users"/></a>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label"><bean:message key="org.systems.jsp"/>:</label>
                        <div class="col-lg-6"><bean:write name="orgDetailsForm" property="systems"/></div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label"><bean:message key="org.system.groups.jsp"/>:</label>
                        <div class="col-lg-6"><bean:write name="orgDetailsForm" property="groups"/></div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label"><bean:message key="org.actkeys.jsp"/>:</label>
                        <div class="col-lg-6"><bean:write name="orgDetailsForm" property="actkeys"/></div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label"><bean:message key="org.kickstart.profiles.jsp"/>:</label>
                        <div class="col-lg-6"><bean:write name="orgDetailsForm" property="ksprofiles"/></div>
                    </div>
                    <div class="form-group">
                        <label class="col-lg-3 control-label"><bean:message key="org.config.channels.jsp"/>:</label>
                        <div class="col-lg-6"><bean:write name="orgDetailsForm" property="cfgchannels"/></div>
                    </div>

                    <div class="form-group">
                        <div class="col-lg-offset-3 col-lg-6">
                            <html:submit styleClass="btn btn-success">
                                <bean:message key="orgdetails.jsp.submit"/>
                            </html:submit>
                        </div>
                    </div>
                </div>
            </div>


        </html:form>
    </body>
</html:html>
