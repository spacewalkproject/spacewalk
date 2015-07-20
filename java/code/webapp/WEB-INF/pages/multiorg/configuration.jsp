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
      <c:out escapeXml="true" value="${org.name}" />
    </rhn:toolbar>

    <div class="panel panel-default">
      <div class="panel-heading">
        <h4><bean:message key="orgconfig.jsp.header"/></h4>
      </div>
      <div class="panel-body">
        <p><bean:message key="orgconfig.jsp.description.noteditable"/></p>
        <hr />
          <form method="post"
          class="form-horizontal"
          action="/rhn/multiorg/OrgConfigDetails.do">
            <rhn:csrf />
            <rhn:submitted/>
            <input type="hidden" name="oid" value="${param.oid}"/>
	    <%@ include file="/WEB-INF/pages/common/fragments/org-config.jspf" %>
            <div class="form-group">
                <div class="col-lg-offset-3 col-lg-6">
                    <input type="submit" class="btn btn-success"
                      value="<bean:message key='orgdetails.jsp.submit'/>"
                      <c:if test = "${edit_disabled}">
                        disabled="${disabled}"
                      </c:if>
                    />
                </div>
            </div>
        </form>
      </div>
    </div>
</body>
</html:html>
