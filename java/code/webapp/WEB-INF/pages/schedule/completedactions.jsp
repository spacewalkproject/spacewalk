<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<body>

  <html:messages id="message" message="true">
    <rhn:messages><c:out escapeXml="false" value="${message}" /></rhn:messages>
  </html:messages>
  
  <rhn:toolbar base="h1" img="/img/rhn-icon-schedule_computer.gif"
  			   imgAlt="actions.jsp.imgAlt"
               helpUrl="/rhn/help/reference/en/s2-sm-action-comp.jsp">
    <bean:message key="completedactions.jsp.completed_actions"/>
  </rhn:toolbar>

  <div class="page-summary">
    <p>
    <bean:message key="completedactions.jsp.summary"/>
    </p>
  </div>
  
<form method="post" name="rhn_list" action="/rhn/schedule/CompletedActionsSubmit.do">

<rhn:list pageList="${requestScope.pageList}"
          noDataText="completedactions.jsp.nogroups">
          
	<%@ include file="/WEB-INF/pages/common/fragments/scheduledactions/listdisplay.jspf" %>
	
</rhn:list>

</form>
</body>
</html>
