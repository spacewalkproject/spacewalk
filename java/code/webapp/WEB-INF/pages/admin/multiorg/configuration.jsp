<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:html xhtml="true">
<head>
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
<rhn:submitted/>
<input type="hidden" name="oid" value="${param.oid}"/>
 <h2><bean:message key="orgdetails.jsp.header"/></h2>

 <table class="details" align="center">
  <tr>
    <th><label for="staging_content_enabled"><bean:message key="org-config.staging-content.jsp"/></th>
    <td><input type="checkbox" name="staging_content_enabled" 
							    value="enabled" id="staging_content_enabled"  
    		<c:if test = "${org.stagingContentEnabled}">
    			checked="checked"
    		</c:if>	
    	 />
	</td>
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
