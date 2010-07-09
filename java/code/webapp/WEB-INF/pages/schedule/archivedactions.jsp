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
		<rl:list emptykey="archivedactions.jsp.nogroups" styleclass="list">


			    <rl:decorator name="PageSizeDecorator"/>
                <rl:decorator name="ElaborationDecorator"/>





                <rl:column sortable="true"
                                   bound="false"
                           headerkey="actions.jsp.action"
                           sortattr="actionName"
                           defaultsort="asc"
                           styleclass="first-column list-fat-column-50"
                           filterattr="actionName">
				<a href="/rhn/schedule/CompletedSystems.do?aid=${current.id}">${current.actionName}</a>
                </rl:column>


                <rl:column sortable="true"
                                   bound="false"
                           headerkey="actions.jsp.earliest"
                           sortattr="earliest" >
                        <c:out value="${current.earliest}" />
                </rl:column>


                <rl:column sortable="false"
                                   bound="false"
                           headerkey="actions.jsp.succeeded"
                            >
                        <c:if test="${current.completed != 0}">
				<a href="/rhn/schedule/CompletedSystems.do?aid=${current.id}">${current.completed}</a>
                        </c:if>
                        <c:if test="${current.completed == 0}">
				${current.completed}
                        </c:if>
                </rl:column>


                <rl:column sortable="false"
                                   bound="false"
                           headerkey="actions.jsp.failed"
                           >
                        <c:if test="${current.failed != 0}">
				<a href="/rhn/schedule/FailedSystems.do?aid=${current.id}">${current.failed}</a>
                        </c:if>
                        <c:if test="${current.failed == 0}">
				${current.failed}
                        </c:if>
                </rl:column>



                <rl:column sortable="false"
                                   bound="false"
                           headerkey="actions.jsp.inprogress"
                           >
                        <c:if test="${current.inProgress != 0}">
				<a href="/rhn/schedule/InProgressSystems.do?aid=${current.id}">${current.inProgress}</a>
                        </c:if>
                        <c:if test="${current.inProgress == 0}">
				${current.inProgress}
                        </c:if>
                </rl:column>


                <rl:column sortable="false"
                                   bound="false"
                           headerkey="actions.jsp.total"
                           styleclass="last-column">
				${current.tally}
                </rl:column>




		</rl:list>
		<rhn:submitted/>
	</rl:listset>



</body>
</html>
