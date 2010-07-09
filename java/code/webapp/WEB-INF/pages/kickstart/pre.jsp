<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_details.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="pre.jsp.header1"/></h2>

<div>
  <p>
    <bean:message key="pre.jsp.summary"/>
    <p>
    <html:form method="POST" action="/kickstart/KickstartPreEdit.do">
      <table class="details">
          <tr>
            <td colspan="2">
              <h2><bean:message key="pre.jsp.langheader"/></h2>
            </td>
          </tr>
          <tr>
              <th>
                  <bean:message key="pre.jsp.language"/>
              </th>
              <td>
                  <html:text property="language" maxlength="40" size="20" /><br>
                  <bean:message key="pre.jsp.tip1"/><br>
                  <bean:message key="pre.jsp.tip2"/><br>
              </td>
          </tr>
          <tr>
            <td colspan="2">
              <h2><bean:message key="pre.jsp.scriptheader"/></h2>
            </td>
          </tr>
          <tr>
              <th>
                  <rhn:required-field key="pre.jsp.contents"/>
              </th>
              <td>
                  <html:textarea rows="24" cols="80" property="contents"/>
              </td>
          </tr>
          <tr>
            <td align="right" colspan="2"><html:submit><bean:message key="kickstartdetails.jsp.updatekickstart"/></html:submit></td>
          </tr>
      </table>
      <html:hidden property="url" value="${ksdata.tree.basePath}"/>
      <html:hidden property="ksid" value="${ksdata.id}"/>
      <html:hidden property="submitted" value="true"/>
    </html:form>
  </p>
</div>

</body>
</html>

