<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<rhn:toolbar base="h1" img="/img/rhn-icon-your_rhn.gif"
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
                <bean:message key="task.status.current.db.time"/>:
            </th>
            <td>
                <c:out value="${current_db}"/>
            </td>
        </tr>
        <tr>
          <td colspan="2" style="font-weight: bold;text-align: center"><bean:message key="task.status.last.execution"/></td>
        </tr>


        <c:forEach items="${list}" var="item">
		<tr>
			<th>
				<bean:message key="${item.key}"/>:
			</th>
			<td>
				<c:out value="${item.date}"/>
			</td>
		</tr>
		</c:forEach>

      </table>

</body>
</html>

