<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-kickstart_profile.gif">
  <bean:message key="kickstartdelete.jsp.header1" arg0="${ksdata.label}"/>
</rhn:toolbar>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_details.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="kickstart.scriptdelete.jsp.header2"/></h2>

<div>
  <p>
    <bean:message key="kickstart.scriptdelete.jsp.summary1"/>
    <html:form method="POST" action="/kickstart/KickstartScriptDelete.do">
      <table class="details">

          <tr>
            <td colspan="2">
              <h2><bean:message key="kickstart.script.langheader"/></h2>
            </td>
          </tr>
          <tr>
              <th>
                  <bean:message key="kickstart.script.language"/>
              </th>
              <td>
                  ${ksscript.interpreter}
              </td>
          </tr>
          <tr>
              <th>
                  <bean:message key="kickstart.script.contents"/>
              </th>
              <td>
                  <textarea name="contents" disabled="true" cols="80" rows="24">${ksscript.dataContents}</textarea>
              </td>
          </tr>
          <tr>
            <td align="right" colspan="2">
            <html:submit>
            <bean:message key="kickstart.scriptdelete.jsp.confirmdelete"/>
            </html:submit>
            </td>
          </tr>

      <html:hidden property="ksid" value="${ksdata.id}"/>
      <html:hidden property="kssid" value="${ksscript.id}"/>
      <html:hidden property="submitted" value="true"/>
      </table>
    </html:form>
  </p>
</div>

</body>
</html>

