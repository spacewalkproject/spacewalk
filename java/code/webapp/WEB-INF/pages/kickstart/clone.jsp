<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>

<html:errors />
<html:messages id="message" message="true">
  <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
</html:messages>

<rhn:toolbar base="h1" img="/img/rhn-kickstart_profile.gif" imgAlt="system.common.kickstartAlt">
  <bean:message key="kickstart.clone.jsp.header1" arg0="${ksdata.name}"/>
</rhn:toolbar>


<rhn:dialogmenu mindepth="0" maxdepth="1" 
    definition="/WEB-INF/nav/kickstart_details.xml" 
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="kickstart.clone.jsp.header2"/></h2>

<div>
  <p>
    <bean:message key="kickstart.clone.jsp.summary"/>
    <p />
    <html:form method="POST" action="/kickstart/KickstartClone.do">
      <table class="details">

          <tr>
            <th><bean:message key="kickstartdetails.jsp.label" /><span class="required-form-field">*</span>:</th>
            <td><html:text property="label" maxlength="64" size="32" /></td>
          </tr>
          <tr>          
            <td align="right" colspan="2"><html:submit><bean:message key="kickstart.clone.jsp.clone"/></html:submit></td>
          </tr>

      <html:hidden property="ksid" value="${ksdata.id}"/>
      <html:hidden property="submitted" value="true"/>
      </table>
    </html:form>
  </p>
</div>

</body>
</html>

