<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html:xhtml/>
<html>
<body>

  <rhn:toolbar base="h1" img="/img/rhn-icon-schedule_computer.gif"
  			   imgAlt="actions.jsp.imgAlt"
               helpUrl="/rhn/help/reference/en-US/s1-sm-actions.jsp#s2-sm-action-arch">
    <bean:message key="archivedactions.jsp.archived_actions"/>
  </rhn:toolbar>

  <div class="page-summary">
    <p>
    <bean:message key="archivedactions.jsp.summary"/>
    </p>
  </div>

  <br/>

	<rl:listset name="failedList">
        <rhn:csrf />
		<rl:list emptykey="archivedactions.jsp.nogroups" styleclass="list">

            <%@ include file="/WEB-INF/pages/common/fragments/scheduledactions/listdisplay-new.jspf" %>

		</rl:list>
		<rhn:submitted/>
	</rl:listset>



</body>
</html>
