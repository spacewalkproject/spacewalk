<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:xhtml/>
<html>
<body>

  <%@ include file="/WEB-INF/pages/common/fragments/scheduledactions/action-header.jspf" %>

    <h2><bean:message key="packagelist.jsp.header.${type}"/></h2>

      <p>
        <bean:message key="packagelist.jsp.summary.${type}"/>
      </p>

  <rl:listset name="packset">

  <rhn:csrf />
  <rl:list emptykey="packagelist.jsp.nopackages">

                  <rl:decorator name="ElaborationDecorator"/>

                  <rl:column sortable="true"
                                     bound="false"
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
