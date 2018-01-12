<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>


<html>
<body>
 <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf"%>

 <rhn:toolbar base="h1" icon="header-system-groups"
  imgAlt="system.common.groupAlt"
  creationUrl="/rhn/systems/ssm/groups/Create.do" creationType="group">
  <bean:message key="grouplist.jsp.header" />
 </rhn:toolbar>

 <h2>
  <bean:message key="ssm.groups.manage.title" />
 </h2>

 <div class="page-summary">
  <p>
   <bean:message key="ssm.groups.manage.summary" />
  </p>
  <ul>
   <li><bean:message key="ssm.groups.manage.item1" /></li>
   <li><bean:message key="ssm.groups.manage.item2" /></li>
   <li><bean:message key="ssm.groups.manage.item3" /></li>
  </ul>
 </div>

 <rl:listset name="groups">
  <rhn:csrf />
  <rl:list emptykey="systems.groups.jsp.noGroups.nonadmin"
   alphabarcolumn="name"
   filter="com.redhat.rhn.frontend.taglibs.list.filters.SystemGroupFilter">
   <rl:decorator name="PageSizeDecorator" />
   <rl:column headerkey="systems.groups.jsp.title" sortable="true" bound="false" sortattr="name">
    <p>
     <a href="/rhn/groups/GroupDetail.do?sgid=${current.id}">
       <c:out value="${current.name}" />
     </a>
    </p>
   </rl:column>

   <rl:column headerkey="ssm.groups.manage.add">
    <input type="radio" name="${current.id}" value="add" align="center"
      <c:if test="${actions_set[current.id] eq 1}">checked</c:if>
    />
   </rl:column>

   <rl:column headerkey="ssm.groups.manage.remove">
    <input type="radio" name="${current.id}" value="remove" align="center"
      <c:if test="${actions_set[current.id] eq 0}">checked</c:if>
    />
   </rl:column>

   <rl:column headerkey="ssm.groups.manage.nochange">
    <input type="radio" name="${current.id}" value="nochange" align="center"
      <c:if test="${empty actions_set[current.id] or actions_set[current.id] eq -1}">checked</c:if>
    />
   </rl:column>
  </rl:list>
  <div class="text-right">
   <rhn:submitted/>
   <html:submit styleClass="btn btn-default" property="dispatch">
    <bean:message key="ssm.groups.manage.button"/>
   </html:submit>
  </div>
 </rl:listset>
</body>
</html>
