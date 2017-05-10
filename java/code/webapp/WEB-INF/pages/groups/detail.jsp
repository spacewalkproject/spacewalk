<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<html>
<head>
</head>
<body>

<%@ include file="/WEB-INF/pages/common/fragments/groups/header.jspf" %>

<div class="row-0">
<div class="col-md-6">
<div class="panel panel-default">

<div class="panel-heading">
  <h3><bean:message key="systemgroup.details.status"/></h3>
</div>

<div class="panel-body">
<table class="table">
  <tr>
    <th><bean:message key="systemgroup.details.updates"/></th>
    <td>
      <div class="system-status">
        <c:choose>
            <c:when test="${errata_counts['se'] > 0}">
                <rhn:icon type="system-crit" />
            </c:when>
            <c:when test="${(errata_counts['se'] == 0) && (errata_counts['be'] > 0 || errata_counts['ee'] > 0)}">
                <rhn:icon type="system-warn" />
            </c:when>
            <c:otherwise>
                <rhn:icon type="system-ok" />
            </c:otherwise>
        </c:choose>
        <c:choose>
            <c:when test="${errata_counts['se'] == 0 && errata_counts['be'] == 0 && errata_counts['ee'] == 0}">
                <bean:message key="systemgroup.details.noupdates"/>
            </c:when>
            <c:otherwise>
                <bean:message key="systemgroup.details.someupdates"/>&nbsp;&nbsp;&nbsp;
                <c:if test="${errata_counts['se'] > 0}">
                    <bean:message key="systemgroup.details.updates.critical" arg0="/rhn/groups/ListErrata.do?sgid=${id}" arg1="${errata_counts['se']}"/>&nbsp;&nbsp;&nbsp;
                </c:if>
                <c:if test="${errata_counts['be'] > 0 || errata_counts['ee'] > 0}">
                    <bean:message key="systemgroup.details.updates.noncritical" arg0="/rhn/groups/ListErrata.do?sgid=${id}" arg1="${errata_counts['be'] + errata_counts['ee']}"/>
                </c:if>
            </c:otherwise>
        </c:choose>
      </div>
    </td>
  </tr>
  <tr>
    <th><bean:message key="systemgroup.details.admins"/></th>
    <td>
      <c:if test="${admin_count > 0}">
        ${admin_count} <bean:message key="systemgroup.details.admincount"/>
      </c:if>
      <c:if test="${admin_count == 0}">
        <span class="no-details"><bean:message key="systemgroup.details.none"/></span>
      </c:if>
      <rhn:require acl="user_role(org_admin) or user_role(system_group_admin)">
      <br />
      <a href="/rhn/groups/AdminList.do?sgid=${id}"><bean:message key="systemgroup.details.manageadmins"/></a>
      </rhn:require>
    </td>
  </tr>
  <tr>
    <th><bean:message key="systemgroup.details.systems"/></th>
    <td>
      <c:if test="${system_count > 0}">
        <a href="/rhn/groups/ListRemoveSystems.do?sgid=${id}">
          <bean:message key="systemgroup.details.systems.systems" arg0="${system_count}"/>
        </a>
      </c:if>
      <c:if test="${system_count == 0}">
        <span class="no-details"><bean:message key="systemgroup.details.none"/></span>
      </c:if>
    </td>
  </tr>
</table>
</div>
</div>
</div>

<div class="col-md-6">
<div class="panel panel-default">
<div class="panel-heading">
  <h3><bean:message key="systemgroup.details.properties"/>
  <rhn:require acl="user_role(org_admin) or user_role(system_group_admin)">
    (<a href="/rhn/groups/EditGroup.do?sgid=${id}"><bean:message key="systemgroup.details.editproperties"/></a>)
  </rhn:require></h3>
</div>

<div class="panel-body">
<table class="table">
  <tr>
    <th><bean:message key="systemgroup.details.name"/></th>
    <td><c:out value="${name}" /></td>
  </tr>
  <tr>
    <th valign="top"><bean:message key="systemgroup.details.description"/></th>
    <td><c:out value="${description}" /></td>
  </tr>
</table>
</div>
</div>
</div>
</div>

</body>
</html>
