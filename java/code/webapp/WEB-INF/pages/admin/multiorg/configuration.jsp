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
            <rhn:toolbar base="h1" icon="header-organisation"
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
            <rhn:toolbar base="h1" icon="header-organisation"
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
      <div class="panel panel-default">
        <div class="panel-heading">
          <h4><bean:message key="satconfig.jsp.header"/></h4>
        </div>
        <div class="panel-body">
          <p><bean:message key="satconfig.jsp.description"/></p>
          <hr />
          <div class="form-group">
            <label class="col-lg-3 control-label">
              <bean:message key="org-config.orgadm-mgmt.jsp"/>
            </label>
            <div class="col-lg-6">
              <div class="checkbox">
                <input type="checkbox" name="org_admin_mgmt"
                  value="enabled" id="org_admin_mgmt"
                <c:if test = "${org.orgAdminMgmt.enabled}">
                  checked="checked"
                </c:if>/>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="panel panel-default">
        <div class="panel-heading">
          <h4><bean:message key="orgconfig.jsp.header"/></h4>
        </div>
        <div class="panel-body">
          <p><bean:message key="orgconfig.jsp.description"/></p>
          <hr />
	  <%@ include file="/WEB-INF/pages/common/fragments/org-config.jspf" %>
          <div class="form-group">
            <div class="col-lg-offset-3 col-lg-6">
              <html:submit styleClass="btn btn-success">
                <bean:message key="orgdetails.jsp.submit"/>
              </html:submit>
            </div>
          </div>
        </div>
      </div>
    </form>
</body>
</html:html>
