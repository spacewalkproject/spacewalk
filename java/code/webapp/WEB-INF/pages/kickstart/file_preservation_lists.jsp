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

<h2><bean:message key="kickstartdetails.jsp.header2"/></h2>



<div>
    <p><bean:message key="kickstart.filelists.jsp.summary" arg0="${ksdata.id}"/></p>
    <p><bean:message key="kickstart.filelists.jsp.note" arg0="${ksdata.id}"/></p>
<c:set var="pageList" value="${requestScope.pageList}" />

    <form method="post" name="rhn_list" action="/rhn/kickstart/KickstartFilePreservationListsSubmit.do">
      <rhn:submitted />
      <rhn:list pageList="${requestScope.pageList}" noDataText="kickstart.filelists.jsp.nolists">

  <rhn:listdisplay renderDisabled="true" set="${requestScope.set}" hiddenvars="${requestScope.newset}">
    <rhn:set value="${current.id}" />

        <rhn:column header="kickstart.filelists.jsp.name">
            <a href="/rhn/systems/provisioning/preservation/PreservationListEdit.do?file_list_id=${current.id}">${current.label}</a>
        </rhn:column>

      </rhn:listdisplay>
      </rhn:list>

<hr />
<input type="hidden" name="ksid" value="<c:out value="${param.ksid}"/>" />
<input type="hidden" name="returnvisit" value="<c:out value="${param.returnvisit}"/>"/>
<div align="right">
  <html:submit property="dispatch">
    <bean:message key="kickstart.filelists.jsp.submit"/>
  </html:submit>
</div>

    </form>
</div>

</body>
</html:html>

