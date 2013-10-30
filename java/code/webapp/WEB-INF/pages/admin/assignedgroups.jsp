<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/user/user-header.jspf" %>

<h2><bean:message key="assignedgroups.jsp.header"/></h2>

<div class="page-summary">
  <p><bean:message key="assignedgroups.jsp.summary"/></p>
  <rhn:require acl="uid_role(system_group_admin)">
    <p><bean:message key="assignedgroups.jsp.asadmin"/></p>
  </rhn:require>
</div>


<rl:listset name="groupSet">
    <rhn:csrf />

	<rl:list dataset="pageList" name="groupList" decorator="SelectableDecorator"
	     emptykey="grouplist.jsp.nogroups"
			 filter="com.redhat.rhn.frontend.taglibs.list.filters.SystemGroupFilter">


 <rl:selectablecolumn value="${current.id}"
					selected="${current.selected}"/>

		<rl:column sortable="true"
					headerkey="assignedgroups.jsp.group"
					sortattr="name">
					
		<c:out value="<a href=\"/network/systems/groups/details.pxt?sgid=${current.id}\">${current.name}</a>" escapeXml="false" />
	    </rl:column>

		<rl:column sortable="true"
					headerkey="grouplist.jsp.systems"
					sortattr="serverCount">
					
						<c:out value="<a href=\"/rhn/groups/ListRemoveSystems.do?sgid=${current.id}\">${current.serverCount}</a>" escapeXml="false" />
	    </rl:column>




</rl:list>
  <c:if test="${not (userIsOrgAdmin)}">
    <div class="text-right">
      <hr />
      <html:submit property="submit">
        <bean:message key="assignedgroups.jsp.submitpermissions"/>
      </html:submit>
    </div>
  </c:if>

  <input type="hidden" name="uid" value="${user.id}" />
  <input type="hidden" name="formvars" value="uid" />

  	<rhn:submitted/>
</rl:listset>



<html:form action="/users/AssignedSystemGroups">
<rhn:csrf />
<rhn:submitted />
<div class="page-summary">
<p><bean:message key="assignedgroups.jsp.youcanselect"/>
</p>
</div>
  <table class="details" align="center">
    <tr>
      <th><bean:message key="assignedgroups.jsp.defaultsysgroups"/></th>
      <td>
        <c:if test="${empty availableGroups}">
          <div class="list-empty-message">
               <bean:message key="assignedgroups.jsp.nogroups"/></div>
        </c:if>
        <c:if test="${!empty availableGroups}">
        <html:select multiple="t" property="defaultGroups" size="4">
          <html:options collection="availableGroups"
            property="value"
            labelProperty="display" />
        </html:select>
        </c:if>
      </td>
    </tr>
  </table>

    <c:if test="${!empty availableGroups}">
    <html:hidden property="uid" />
    <div class="text-right">
      <hr />
      <html:submit property="submit">
        <bean:message key="assignedgroups.jsp.submitdefaults"/>
      </html:submit>
    </div>
  </c:if>

</html:form>





</body>
</html>
