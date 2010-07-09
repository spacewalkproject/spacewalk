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

<div>

  <table class="details" border="0">
    <tr><td>
      <h2><bean:message key="kickstartdownload.jsp.header"/></h2>
          <bean:message key="kickstartdownload.jsp.summary"/>

    </td></tr>

    <c:choose>
      <c:when test="${invalid_channel}">
        <tr><td>
          <img src="/img/rhn-listicon-alert.gif"
               alt="<bean:message key='error.common.errorAlt' />" />
          <bean:message key="kickstartdownload.jsp.invalidchannel"/>
        </td></tr>
      </c:when>
      <c:otherwise>
        <tr><td>
          <a href="${ksurl}" target="_new"><bean:message key="kickstartdownload.jsp.download"/></a>

        </td></tr>
        <tr><td>

          <pre style="overflow: scroll; width: 800px; height: 800px;">${filedata}</pre>

        </td></tr>
      </c:otherwise>
    </c:choose>
  </table>
</div>
</body>
</html>

