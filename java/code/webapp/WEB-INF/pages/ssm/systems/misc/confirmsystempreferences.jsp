<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>

<h2><bean:message key="ssm.misc.sysprefconfirm.header"/></h2>

<div class="page-summary">
<p><bean:message key="ssm.misc.sysprefconfirm.summary"/></p>
</div>

<table class="details">
  <c:if test='${notify == "yes"}'>
   <tr>
     <th><bean:message key="ssm.misc.index.syspref.notify"/></th>
     <td><bean:message key="yes"/></td>
   </tr>
  </c:if>
  <c:if test='${notify == "no"}'>
   <tr>
     <th><bean:message key="ssm.misc.index.syspref.notify"/></th>
     <td><bean:message key="no"/></td>
   </tr>
  </c:if>
  <c:if test='${summary == "yes"}'>
   <tr>
     <th><bean:message key="ssm.misc.index.syspref.dailysummary"/></th>
     <td><bean:message key="yes"/></td>
   </tr>
  </c:if>
  <c:if test='${summary == "no"}'>
   <tr>
     <th><bean:message key="ssm.misc.index.syspref.dailysummary"/></th>
     <td><bean:message key="no"/></td>
   </tr>
  </c:if>
  <c:if test='${update == "yes"}'>
   <tr>
     <th><bean:message key="ssm.misc.index.syspref.update"/></th>
     <td><bean:message key="yes"/></td>
   </tr>
  </c:if>
  <c:if test='${update == "no"}'>
   <tr>
     <th><bean:message key="ssm.misc.index.syspref.update"/></th>
     <td><bean:message key="no"/></td>
   </tr>
  </c:if>
</table>

<form action="/rhn/systems/ssm/misc/ConfirmSystemPreferences.do" method="post">
  <rhn:csrf />
  <rhn:submitted />
  <input type="hidden" name="notify" value="${notify}" />
  <input type="hidden" name="summary" value="${summary}" />
  <input type="hidden" name="update" value="${update}" />

  <div class="text-right">
    <input class="btn btn-default" type="submit" name="confirm" value="<bean:message key='ssm.misc.index.syspref.changepreferences'/>" />
  </div>

</form>



</body>
</html>
