<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/scheduledactions/action-header.jspf" %>

  <h2><bean:message key="packagelist.jsp.header.${type}"/></h2>
  
  <div class="page-summary">
    <p>
      <bean:message key="packagelist.jsp.summary.${type}"/>
    </p>
  </div>


  <rhn:list pageList="${requestScope.pageList}"
            noDataText="packagelist.jsp.nopackages">
    <rhn:listdisplay>
      <rhn:column header="packagelist.jsp.name.${type}">
        ${current.nvre}
      </rhn:column>
    </rhn:listdisplay>
  </rhn:list>
	
</body>
</html>
