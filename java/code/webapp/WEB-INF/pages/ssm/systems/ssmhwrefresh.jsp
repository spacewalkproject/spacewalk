<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>


<html>
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
    <h2>
      <bean:message key="ssm.hw.systems.header" />
    </h2>
    <c:choose>
      <c:when test="${system_count > 0}">
        <c:choose>
          <c:when test="${system_count == 1}">
            <p><bean:message key="ssm.hw.systems.summary" arg0="${system_count} system"/></p>
          </c:when>
          <c:otherwise>
            <p><bean:message key="ssm.hw.systems.summary" arg0="${system_count} systems"/></p>
          </c:otherwise>
        </c:choose>
      </c:when>
      <c:otherwise>
        <p><bean:message key="ssm.hw.systems.summary.empty" /></p>
      </c:otherwise>
    </c:choose>

<%--
    <html:form method="post" action="/systems/ssm/misc/HardwareRefresh.do">
--%>
    <html:form action="/systems/ssm/misc/HardwareRefresh.do">
      <rhn:csrf />
      <html:hidden property="submitted" value="true"/>
        <div class="text-right">
          <html:submit styleClass="btn btn-default">
            <bean:message key="ssm.hw.systems.confirmbutton"/>
          </html:submit>
        </div>
    </html:form>
<%--
    <div class="text-right">
      <hr />
      <input type="submit" name="dispatch" value="${rhn:localize('ssm.hw.systems.confirmbutton')}"/>
    </div>
--%>

  </body>
</html>
