<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<html:html xhtml="true">
<head>
<meta http-equiv="Pragma" content="no-cache" />
</head>

<body>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_details.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
<div>
  <h2><bean:message key="kickstart.edit.pkgs.jsp.header1"/></h2>
  <bean:message key="kickstart.edit.pkgs.jsp.main1"/>
  <br />
  <br />
  <bean:message key="kickstart.edit.pkgs.jsp.main2" />
  <br />
  <html:form method="post" action="/kickstart/KickstartPackagesEdit.do">
    <html:hidden property="ksid" />
    <html:hidden property="submitted" />
    <table width="80%">
    <tr>
	    <td>
		<table width="100%">
	    	<tr>
	    	  <td align="right">
			    <html:textarea style="text-align: left" property="packageList" rows="10" cols="80" tabindex="0" />
			  </td>
			</tr>
			<tr>
	         <td align="right">
	            <input type="submit" value="<bean:message key="kickstart.edit.pkgs.submit.jsp.label" />" />
	         </td>
	      </tr>
	    </table>
	    </td>
	    <td>&nbsp;</td>
	</tr>
	</table>
  </html:form>
</div>
</body>
</html:html>

