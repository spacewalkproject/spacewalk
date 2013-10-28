<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>
<%@ include file="/WEB-INF/pages/common/fragments/kickstart/kickstart-toolbar.jspf" %>

<rhn:dialogmenu mindepth="0" maxdepth="1"
    definition="/WEB-INF/nav/kickstart_details.xml"
    renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

<h2><bean:message key="kickstart.locale.jsp.header1"/></h2>

<div>
  <p>
    <bean:message key="kickstart.locale.jsp.summary1"/>
  </p>
    <html:form method="post" action="/kickstart/LocaleEdit.do">
    <rhn:csrf />
    <html:hidden property="ksid" value="${ksdata.id}"/>
    <html:hidden property="submitted" value="true"/>
      <table class="details">

        <tr>
          <th><bean:message key="kickstart.locale.jsp.timezone" /></th>
	  <td>
            <html:select property="timezone">
              <html:options collection="timezones"
                            property="value"
                            labelProperty="display" />
            </html:select>
	    <bean:message key="kickstart.locale.jsp.hardwareclock" />: <html:checkbox property="use_utc"/>
            <br/>
          </td>
        </tr>

        <tr>
          <td align="right" colspan="2"><html:submit><bean:message key="kickstart.locale.jsp.updatekickstart"/></html:submit></td>
        </tr>
      </table>
    </html:form>
</div>

</body>
</html:html>

