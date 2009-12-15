<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


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



<rl:listset name="packset">

<rl:list emptykey="packagelist.jsp.nopackages">

                <rl:decorator name="ElaborationDecorator"/>


                <rl:column sortable="true"
                                   bound="false"
                           styleclass="first-column last-column"
                           headerkey="packagelist.jsp.name.${type}"
                           sortattr="nvre"
                           defaultsort="asc"  >
                           ${current.nvre}
                </rl:column>

</rl:list>

<input type="hidden" name="aid" value="${aid}">

</rl:listset>

	
</body>
</html>
