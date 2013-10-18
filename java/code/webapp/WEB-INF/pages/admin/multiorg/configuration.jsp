<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:html>
    <head>
        <script language="javascript" type="text/javascript">
function modifyUploadCheckbox(checkbox) {
    if (checkbox.checked == false) {
        document.getElementById("crashfile_upload_enabled").disabled = true;
    } else {
        document.getElementById("crashfile_upload_enabled").disabled = false;
    }
}
        </script>
    </head>
    <body>
    <c:choose>
        <c:when test="${param.oid != 1}">
            <rhn:toolbar base="h1" icon="icon-group"
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
            <rhn:toolbar base="h1" icon="icon-group"
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

    <form method="post"
          class="form-horizontal"
          action="/rhn/admin/multiorg/OrgConfigDetails.do">
        <rhn:csrf />
        <rhn:submitted/>
        <input type="hidden" name="oid" value="${param.oid}"/>
        <h2><bean:message key="orgconfig.jsp.header"/></h2>
        <p><bean:message key="orgconfig.jsp.description"/></p>

        <div class="form-group">
            <div class="col-lg-offset-3 col-lg-6">
                <label>
                    <input type="checkbox" name="staging_content_enabled"
                           value="enabled" id="staging_content_enabled"
                           <c:if test = "${org.orgConfig.stagingContentEnabled}">
                               checked="checked"
                           </c:if>/>
                    <bean:message key="org-config.staging-content.jsp"/>
                </label>
            </div>
        </div>
        <div class="form-group">
            <div class="col-lg-offset-3 col-lg-6">
                <label>
                    <input type="checkbox"
                           name="crash_reporting_enabled"
                           value="enabled"
                           id="crash_reporting_enabled"
                           onChange="modifyUploadCheckbox(this)"
                           <c:if test = "${org.orgConfig.crashReportingEnabled}">
                               checked="checked"
                           </c:if>/>
                    <bean:message key="org-config.crash-reporting.jsp"/>
                </label>
            </div>
        </div>
        <div class="form-group">
            <div class="col-lg-offset-3 col-lg-6">
                <label>
                    <input type="checkbox"
                           name="crashfile_upload_enabled"
                           value="enabled"
                           id="crashfile_upload_enabled"
                           <c:if test = "${not org.orgConfig.crashReportingEnabled}">
                               disabled="true"
                           </c:if>
                           <c:if test = "${org.orgConfig.crashfileUploadEnabled}">
                               checked="checked"
                           </c:if>/>
                    <bean:message key="org-config.crashfile-upload.jsp"/>
                </label>
            </div>
        </div>
        <div class="form-group">
            <label class="col-lg-3 control-label">
                <bean:message key="org-config.crashfile-sizelimit.jsp"/>:
            </label>
            <div class="col-lg-2">
                <input type="number"
                       class="form-control"
                       name="crashfile_sizelimit"
                       value="${org.orgConfig.crashFileSizelimit}"
                       id="crashfile_sizelimit" />
            </div>
        </div>
        <div class="form-group">
            <div class="col-lg-offset-3 col-lg-6">
                <label>
                    <input type="checkbox"
                           name="scapfile_upload_enabled"
                           value="enabled"
                           id="scapfile_upload_enabled"
                           <c:if test = "${org.orgConfig.scapfileUploadEnabled}">
                               checked="checked"
                           </c:if>/>
                    <bean:message key="org-config.scapfile-upload.jsp"/>
                </label>
            </div>
        </div>
        <div class="form-group">
            <label class="col-lg-3 control-label">
                <bean:message key="org-config.scapfile-sizelimit.jsp"/>:
            </label>
            <div class="col-lg-2">
                <input type="number"
                       class="form-control"
                       name="scapfile_sizelimit"
                       value="${org.orgConfig.scapFileSizelimit}"
                       id="scapfile_sizelimit" />
            </div>
        </div>
        <div class="form-group">
            <div class="col-lg-offset-3 col-lg-6">
                <label>
                    <input type="checkbox"
                           name="scap_retention_set"
                           value="on"
                           id="scap_retention_set"
                           onChange="modifyTrVisibility('tr_scap_retention')"
                           <c:if test = "${org.orgConfig.scapRetentionPeriodDays != null}">
                               checked="checked"
                           </c:if>/>
                    <bean:message key="org-config.scap-retention"/>
                </label>
            </div>
        </div>
        <div class="form-group">
            <label class="col-lg-3 control-label">
                <bean:message key="org-config.scap-retention-period"/>:
            </label>
            <div class="col-lg-2">
                <input type="number"
                       class="form-control"
                       name="scap_retention_period"
                       value="${org.orgConfig.scapRetentionPeriodDays == null ? 90 : org.orgConfig.scapRetentionPeriodDays}"
                       id="scap_retention_period" />
            </div>
        </div>
        <div class="form-group">
            <div class="col-lg-offset-3 col-lg-6">
                <html:submit styleClass="btn btn-success">
                    <bean:message key="orgdetails.jsp.submit"/>
                </html:submit>
            </div>
        </div>
    </form>
</body>
</html:html>
