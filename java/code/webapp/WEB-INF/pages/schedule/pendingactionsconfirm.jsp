<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<body>
<rhn:toolbar base="h1" icon="icon-time"
  			   imgAlt="actions.jsp.imgAlt"
               helpUrl="/rhn/help/reference/en-US/s1-sm-actions.jsp#s2-sm-action-pend">
    <bean:message key="pendingactions.jsp.confirm_cancel_actions"/>
  </rhn:toolbar>

    <p>
    <bean:message key="pendingactions.jsp.confirm_cancel_actions_summary"/>
    </p>

	<rl:listset name="pendingList">

    <rhn:csrf />
		<rl:list emptykey="pendingactions.jsp.nogroups" styleclass="list">

      <rl:decorator name="ElaborationDecorator"/>

			<rl:column sortable="true"
                 bound="false"
                 headerkey="actions.jsp.action"
                 sortattr="actionName"
                 defaultsort="asc"
                 filterattr="actionName">
				<a href="/rhn/schedule/CompletedSystems.do?aid=${current.id}"><c:out value="${current.actionName}" /></a>
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
                           headerkey="actions.jsp.total">
				${current.tally}
                </rl:column>

		</rl:list>
		<rhn:submitted/>
		 <div class="pull-right">
		     <input type="submit"
               name="dispatch"
               class="btn btn-default"
               value='<bean:message key="actions.jsp.confirmcancelactions"/>'/>
         </div>
	</rl:listset>

</body>
</html>

