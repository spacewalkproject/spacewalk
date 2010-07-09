<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-schedule_computer.gif"
  			   imgAlt="actions.jsp.imgAlt"
               helpUrl="/rhn/help/reference/en-US/s1-sm-actions.jsp#s2-sm-action-fail">
    <bean:message key="failedactions.jsp.failed_actions"/>
  </rhn:toolbar>

  <div class="page-summary">
    <p>
    <bean:message key="failedactions.jsp.summary"/>
    </p>
  </div>

	<br/>


	<rl:listset name="failedList">
		<rl:list emptykey="failedactions.jsp.nogroups" styleclass="list">


			<%@ include file="/WEB-INF/pages/common/fragments/scheduledactions/listdisplay-new.jspf" %>


		</rl:list>
		<rhn:submitted/>
		 <div align="right">
		     <input type="submit"
               name="dispatch"
               value='<bean:message key="actions.jsp.archiveactions"/>'/>
         </div>
	</rl:listset>


	
</body>
</html>
