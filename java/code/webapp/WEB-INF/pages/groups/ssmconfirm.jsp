<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn"%>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl"%>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html"%>


<html>
<body>
 <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf"%>
 <h2>
  <bean:message key="ssm.groups.manage.title" />
 </h2>

 <rl:listset name="groups">
  <rhn:csrf />
  <p>
   <bean:message key="ssm.groups.confirm.added" arg0="${numServers}" />
  </p>
  <rl:list dataset="addSet" name="addList" emptykey="ssm.groups.confirm.added.empty">
   <rl:decorator name="PageSizeDecorator" />
   <rl:column>
    <c:out value="${current.name}" />
   </rl:column>
  </rl:list>
  <p>
   <bean:message key="ssm.groups.confirm.removed" arg0="${numServers}" />
  </p>
  <rl:list dataset="removeSet" name="removeList" emptykey="ssm.groups.confirm.removed.empty">
   <rl:decorator name="PageSizeDecorator" />
   <rl:column>
    <c:out value="${current.name}" />
   </rl:column>
  </rl:list>

  <div class="text-right">
   <rhn:submitted />
   <html:submit styleClass="btn btn-default" property="dispatch">
    <bean:message key="confirm.displayname" />
   </html:submit>
  </div>
 </rl:listset>
</body>
</html>
