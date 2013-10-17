<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" icon="icon-dashboard"
	           helpUrl="">
    <bean:message key="task.status.title"/>
  </rhn:toolbar>

<div>
  <p>
    <bean:message key="task.status.message"/>
  </p>
</div>

    <rhn:require acl="user_role(satellite_admin)"/>

      <table class="details">
        <tr>
            <th>
                <bean:message key="task.status.taskomatic.on"/>:
            </th>
            <td>
                <c:out value="${taskomatic_on}"/>
            </td>
        </tr>
        <tr>
          <td colspan="3" style="font-weight: bold;text-align: center"><bean:message key="task.status.last.execution"/></td>
        </tr>

        <c:forEach items="${list}" var="item">
		<tr>
			<th>
				<bean:message key="${item.name}"/>:
			</th>
			<td>
				<c:out value="${item.start_time}"/>
			</td>
			<td>
				<c:out value="${item.status}"/>
			</td>
		</tr>
		</c:forEach>

      </table>

</body>
</html>
