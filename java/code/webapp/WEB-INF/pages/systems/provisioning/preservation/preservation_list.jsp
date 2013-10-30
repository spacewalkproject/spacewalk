<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html >
<body>
<rhn:toolbar base="h1" icon="fa-rocket"
    imgAlt="system.common.kickstartAlt"
    creationUrl="PreservationListCreate.do"
    creationType="filelist">
  <bean:message key="preservation_list.jsp.toolbar"/>
</rhn:toolbar>

<div>
    <bean:message key="preservation_list.jsp.summary"/>
</div>
    <form method="post" name="rhn_list" action="PreservationListDeleteSubmit.do">
      <rhn:csrf />
      <rhn:list pageList="${requestScope.pageList}" noDataText="preservation_list.jsp.nokeys">

      <%@ include file="/WEB-INF/pages/common/fragments/systems/file_listdisplay.jspf" %>

      </rhn:list>
    </form>
	
</body>
</html:html>

