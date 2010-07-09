<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-errata.gif"
	           helpUrl="/rhn/help/channel-mgmt/en-US/channel-mgmt-Custom_Errata_Management-Managed_Errata_Details.jsp"
	           deletionUrl="/rhn/errata/Delete.do?eid=${param.eid}"
               deletionType="errata">
    <bean:message key="errata.edit.toolbar"/> <c:out value="${advisory}" />
  </rhn:toolbar>

  <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/manage_errata.xml"
                  renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

  <h2><bean:message key="errata.notify.senderratanotification"/></h2>

  <p><bean:message key="errata.notify.instructions"/></p>

  <hr />

  <div align="right">
    <form action="/rhn/errata/manage/NotifySubmit.do">
      <input type="hidden" name="eid" value="<c:out value="${param.eid}"/>"/>
      <html:submit>
        <bean:message key="errata.edit.sendnotification"/>
      </html:submit>
    </form>
  </div>

</body>
</html>
