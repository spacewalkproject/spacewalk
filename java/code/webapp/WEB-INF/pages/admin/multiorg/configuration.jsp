<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:html xhtml="true">
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
<rhn:toolbar base="h1" img="/img/rhn-icon-org.gif"
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
<rhn:toolbar base="h1" img="/img/rhn-icon-org.gif"
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

<form method="post" action="/rhn/admin/multiorg/OrgConfigDetails.do">
<rhn:csrf />
<rhn:submitted/>
<input type="hidden" name="oid" value="${param.oid}"/>
 <h2><bean:message key="orgconfig.jsp.header"/></h2>
 <bean:message key="orgconfig.jsp.description"/>
 <p/>
 <table class="details" align="center">
  <tr>
    <th><label for="staging_content_enabled"><bean:message key="org-config.staging-content.jsp"/></th>
    <td><input type="checkbox" name="staging_content_enabled" 
							    value="enabled" id="staging_content_enabled"  
    		<c:if test = "${org.orgConfig.stagingContentEnabled}">
    			checked="checked"
                </c:if>
    	 />
	</td>
  </tr>
  <tr>
    <th>
      <label for="crash_reporting_enabled">
      <bean:message key="org-config.crash-reporting.jsp"/>
    </th>
    <td>
      <input type="checkbox"
             name="crash_reporting_enabled"
             value="enabled"
             id="crash_reporting_enabled"
             onChange="modifyUploadCheckbox(this)"
             <c:if test = "${org.orgConfig.crashReportingEnabled}">
                 checked="checked"
             </c:if>
      />
    </td>
  </tr>
  <tr>
    <th>
      <label for="crashfile_upload_enabled">
      <bean:message key="org-config.crashfile-upload.jsp"/>
    </th>
    <td>
      <input type="checkbox"
             name="crashfile_upload_enabled"
             value="enabled"
             id="crashfile_upload_enabled"
             <c:if test = "${not org.orgConfig.crashReportingEnabled}">
                 disabled="true"
             </c:if>
             <c:if test = "${org.orgConfig.crashfileUploadEnabled}">
                 checked="checked"
             </c:if>
      />
    </td>
  </tr>
  <tr>
    <th>
        <bean:message key="org-config.crashfile-sizelimit.jsp"/>
    </th>
    <td>
        <input type="number"
               name="crashfile_sizelimit"
               value="${org.orgConfig.crashFileSizelimit}"
               id="crashfile_sizelimit" />
    <td>
  </tr>
  <tr>
    <th>
      <label for="scapfile_upload_enabled">
      <bean:message key="org-config.scapfile-upload.jsp"/>
    </th>
    <td>
      <input type="checkbox"
             name="scapfile_upload_enabled"
             value="enabled"
             id="scapfile_upload_enabled"
             <c:if test = "${org.orgConfig.scapfileUploadEnabled}">
                 checked="checked"
             </c:if>
      />
    </td>
  </tr>
  <tr>
    <th>
        <bean:message key="org-config.scapfile-sizelimit.jsp"/>
    </th>
    <td>
        <input type="number"
               name="scapfile_sizelimit"
               value="${org.orgConfig.scapFileSizelimit}"
               id="scapfile_sizelimit" />
    <td>
  </tr>
 </table>

 <div align="right">
   <hr/>

   <html:submit>
   <bean:message key="orgdetails.jsp.submit"/>
   </html:submit>

 </div>

</form>
</body>
</html:html>
