<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_details.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="kickstart.troubleshooting.jsp.header1"/></h2>

<div>
  <p>
    <bean:message key="kickstart.troubleshooting.jsp.summary1"/>
  </p>
    <html:form method="post" action="/kickstart/TroubleshootingEdit.do">
      <table class="details">

        <tr>
          <th><bean:message key="kickstart.troubleshooting.jsp.bootloader" /></th>
	  <td>
<c:if test="${ksdata.eliloRequired}">
            eLilo
            <br/>
            <bean:message key="kickstart.troubleshooting.jsp.bootloader.elilo.required"/>
</c:if>
<c:if test="${!ksdata.eliloRequired}">
            <html:select property="bootloader">
              <html:options collection="bootloaders"
                            property="value"
                            labelProperty="display" />
            </html:select>
            <br/>
            <strong><bean:message key="kickstart.troubleshooting.jsp.bootloadertip" /></strong>: <bean:message key="kickstart.troubleshooting.jsp.bootloadertip.text"/>
</c:if>
          </td>
        </tr>

        <tr>
          <th><bean:message key="kickstart.troubleshooting.jsp.kernelparams" />:</th>
          <td><html:text property="kernelParams" maxlength="64" size="32" /></td>
        </tr>

        <tr>
          <th><bean:message key="kickstart.troubleshooting.jsp.nonchrootpost" />:</th>
          <td><html:checkbox property="nonChrootPost" /></td>
        </tr>

        <tr>
          <th><bean:message key="kickstart.troubleshooting.jsp.verboseup2date" />:</th>
          <td><html:checkbox property="verboseUp2date" /></td>
        </tr>

        <tr>
          <td align="right" colspan="2"><html:submit><bean:message key="kickstart.troubleshooting.jsp.updatekickstart"/></html:submit></td>
        </tr>
      </table>
    <html:hidden property="ksid" value="${ksdata.id}"/>
    <html:hidden property="submitted" value="true"/>
    </html:form>
</div>

</body>
</html:html>

