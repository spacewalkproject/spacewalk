<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>



<html>
<body>
<rhn:toolbar base="h1" icon="fa-clock-o"
  			   imgAlt="actions.jsp.imgAlt"
               helpUrl="/rhn/help/reference/en-US/s1-sm-actions.jsp#s2-sm-action-comp">
    <bean:message key="completedactions.jsp.completed_actions"/>
  </rhn:toolbar>

    <p>
    <bean:message key="completedactions.jsp.summary"/>
    </p>

	<rl:listset name="failedList">
        <rhn:csrf />
		<rl:list emptykey="completedactions.jsp.nogroups" styleclass="list">

			<%@ include file="/WEB-INF/pages/common/fragments/scheduledactions/listdisplay-new.jspf" %>

		</rl:list>
		<rhn:submitted/>
		 <div class="text-right">
		     <input type="submit"
               name="dispatch"
               class="btn btn-default"
               value='<bean:message key="actions.jsp.archiveactions"/>'/>
         </div>
	</rl:listset>

  </body>
</html>
