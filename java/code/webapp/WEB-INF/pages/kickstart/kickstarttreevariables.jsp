<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>



<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>


<rhn:toolbar base="h1" img="/img/rhn-kickstart_profile.gif"
			 deletionUrl="/rhn/kickstart/TreeDelete.do?kstid=${kstree.id}"
             deletionType="deleteTree"
             imgAlt="kickstarts.alt.img">
  <bean:message key="treeedit.jsp.toolbar"/>
</rhn:toolbar>


	  <rhn:dialogmenu mindepth="0" maxdepth="1" 
	    definition="/WEB-INF/nav/kickstart_tree_details.xml" 
	    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />
	

	<h2><bean:message key="kickstart.variable.jsp.header"/></h2>


<div>
  <p>
    <bean:message key="kickstart.variable.jsp.summary"/>
   <p> <bean:message key="kickstarttree.variable.jsp.summary"/> </p>
    
  </p>
  <br>
    <html:form method="post" action="/kickstart/tree/EditVariables.do">
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
	  <html:hidden property="kstid" value="${kstid}"/>
      <html:hidden property="submitted" value="true"/>
    </html:form>
</div>
</body>
</html:html>

