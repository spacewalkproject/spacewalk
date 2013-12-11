<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>


<html>
<head>
    <meta name="page-decorator" content="none" />
</head>
<body>
<rhn:toolbar base="h1" icon="header-errata"
	           helpUrl="/rhn/help/getting-started/en-US/chap-Getting_Started_Guide-Errata_Management.jsp#sect-Getting_Started_Guide-Errata_Management-Creating_and_Editing_Errata"
	           deletionUrl="/rhn/errata/Delete.do?eid=${param.eid}"
               deletionType="errata">
    <bean:message key="errata.edit.toolbar"/> <c:out value="${advisory}" />
  </rhn:toolbar>

  <rhn:dialogmenu mindepth="0" maxdepth="1" definition="/WEB-INF/nav/manage_errata.xml"
                  renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

  <h2><bean:message key="errata.notify.senderratanotification"/></h2>

  <p><bean:message key="errata.notify.instructions"/></p>

  <hr />

  <div class="text-right">
    <form action="/rhn/errata/manage/NotifySubmit.do" method="POST">
      <rhn:csrf />
      <input type="hidden" name="eid" value="<c:out value="${param.eid}"/>"/>
      <html:submit>
        <bean:message key="errata.edit.sendnotification"/>
      </html:submit>
    </form>
  </div>

</body>
</html>
