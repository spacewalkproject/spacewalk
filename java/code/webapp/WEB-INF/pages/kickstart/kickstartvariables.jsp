<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>
<html:errors />






 <rhn:require acl="is_ks_raw(${ksdata.id})" mixins="com.redhat.rhn.common.security.acl.KickstartAclHandler">
	<%@ include file="/WEB-INF/pages/common/fragments/kickstart/advanced/header.jspf"%>
 </rhn:require>
   
 
 
  <rhn:require acl="is_ks_not_raw(${ksdata.id})" mixins="com.redhat.rhn.common.security.acl.KickstartAclHandler">
  	<html:messages id="message" message="true">
		  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
		</html:messages>
  	<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>

	  <rhn:dialogmenu mindepth="0" maxdepth="1" 
	    definition="/WEB-INF/nav/kickstart_details.xml" 
	    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
	
  </rhn:require>
 
	<h2><bean:message key="kickstart.variable.jsp.header"/></h2>


<div>
  <p>
    <bean:message key="kickstart.variable.jsp.summary"/>
  </p>
  <br>
    <html:form method="post" action="/kickstart/EditVariables.do">
      <table class="details">
          <tr>
              <th>
                  <bean:message key="kickstart.variable.jsp.variabledetails"/>:
              </th>
              <td>
                  <html:textarea rows="25" cols="60" property="variables"/>
              </td>
          </tr>
          
          
          
          <tr>          
            <td align="right" colspan="2"><html:submit><bean:message key="kickstart.variable.jsp.update"/></html:submit></td>
          </tr>
      </table>
	  <html:hidden property="ksid" value="${ksdata.id}"/>
      <html:hidden property="submitted" value="true"/>
    </html:form>
</div>
</body>
</html:html>

