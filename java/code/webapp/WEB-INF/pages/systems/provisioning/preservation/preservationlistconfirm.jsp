<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-kickstart_profile.gif"
             imgAlt="system.common.kickstartAlt">
    <bean:message key="preservation_list.jsp.toolbar"/>
</rhn:toolbar>

	<h2>
      <bean:message key="preservationlistdeleteconfirm.jsp.header2" />
    </h2>

<div>
    <bean:message key="preservationlistdeleteconfirm.jsp.summary"/>
</div>
    <form method="POST" name="rhn_list" action="PreservationListDelete.do">
      <rhn:list pageList="${requestScope.pageList}"
       noDataText="preservation_list_delete.jsp.noneselected">
        	<rhn:listdisplay button="preservation_list.jsp.deletelist">
          		<rhn:column header="preservation_list.jsp.description">
    <A HREF="PreservationListEdit.do?file_list_id=${current.id}">${current.label}</A>
          		</rhn:column>
			</rhn:listdisplay>
      </rhn:list>
    </form>
	
</body>
</html>

