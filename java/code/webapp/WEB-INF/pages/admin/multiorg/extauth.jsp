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
    <rhn:toolbar base="h1" icon="header-organisation"
                 miscUrl="${url}"
                 miscAcl="user_role(org_admin)"
                 miscText="${text}"
                 miscImg="${img}"
                 miscAlt="${text}"
                 imgAlt="users.jsp.imgAlt">
        <bean:message key="org.allusers.title1" />
    </rhn:toolbar>

    <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/admin_user.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />


    <div class="panel-body">
      <html:form method="post" action="/admin/multiorg/ExternalAuthentication.do">
        <rhn:csrf />
        <html:hidden property="submitted" value="true"/>
        <div class="row-0 form-group">
          <div class="col-md-2">
            <bean:message key="sdc.details.migrate.org"/>
          </div>
          <div class="col-md-3">
            <html:select property="to_org" styleClass="form-control">
              <html:options collection="orgs"
                property="value" labelProperty="label" />
            </html:select>
          </div>
        </div>
        <hr/>
          <div class="text-right">
            <html:submit styleClass="btn btn-success">
              <bean:message key="config.update"/>
            </html:submit>
          </div>
      </html:form>
    </div>

</body>
</html:html>
