<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>
<rhn:toolbar base="h1" icon="fa-tachometer"
	           helpUrl="">
    <bean:message key="task.status.title"/>
  </rhn:toolbar>

  <p>
    <bean:message key="task.status.message"/>
  </p>
  <rhn:require acl="user_role(satellite_admin)"/>
  <div class="panel panel-default">
    <div class="panel-body">
      <bean:message key="task.status.taskomatic.on"/>: <c:out value="${taskomatic_on}"/>
    </div>
  </div>
  <div class="panel panel-default">
    <div class="panel-heading">
      <bean:message key="task.status.last.execution"/>
    </div>
    <div class="panel-body">
      <table class="table table-striped">
        <tbody>
        <c:forEach items="${list}" var="item">
      		<tr>
      			<td>
      				<bean:message key="${item.name}"/>:
      			</td>
      			<td>
      				<c:out value="${item.start_time}"/>
      			</td>
      			<td>
      				<c:out value="${item.status}"/>
      			</td>
      		</tr>
        </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</body>
</html>
