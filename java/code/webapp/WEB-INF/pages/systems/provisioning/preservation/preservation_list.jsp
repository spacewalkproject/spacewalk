<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:html xhtml="true">
<body>
<rhn:toolbar base="h1" img="/img/rhn-kickstart_profile.gif"
    imgAlt="system.common.kickstartAlt"
    creationUrl="PreservationListCreate.do"
    creationType="filelist">
  <bean:message key="preservation_list.jsp.toolbar"/>
</rhn:toolbar>

<div>
    <bean:message key="preservation_list.jsp.summary"/>
</div>
    <form method="post" name="rhn_list" action="PreservationListDeleteSubmit.do">
      <rhn:list pageList="${requestScope.pageList}" noDataText="preservation_list.jsp.nokeys">

      <%@ include file="/WEB-INF/pages/common/fragments/systems/file_listdisplay.jspf" %>

      </rhn:list>
    </form>
	
</body>
</html:html>

