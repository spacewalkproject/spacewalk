<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<body>
<rhn:toolbar base="h1" icon="header-action"
  			   imgAlt="actions.jsp.imgAlt"
               helpUrl="/rhn/help/reference/en-US/s1-sm-actions.jsp#s2-sm-action-pend">
    <bean:message key="pendingactions.jsp.pending_actions"/>
  </rhn:toolbar>

  <p>
    <bean:message key="pendingactions.jsp.summary"/>
  </p>

	<rl:listset name="pendingList">
  <rhn:csrf />

	<rl:list emptykey="pendingactions.jsp.nogroups" styleclass="list">
		<%@ include file="/WEB-INF/pages/common/fragments/scheduledactions/listdisplay-new.jspf" %>
	</rl:list>
		<rhn:submitted/>
		  <div class="pull-right">
		    <input type="submit"
               name="dispatch"
               class="btn btn-default"
               value='<bean:message key="actions.jsp.cancelactions"/>'/>
      </div>
	</rl:listset>
</body>
</html>
