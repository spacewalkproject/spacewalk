<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
  <rhn:icon type="header-configuration" title="ssmdiff.jsp.imgAlt" />
  <bean:message key="deployconfirm.jsp.header" />
</h2>

  <div class="page-summary">
    <p>
    <c:choose>
      <c:when test="${requestScope.filenum == 1}">
        <bean:message key="deployconfirm.jsp.summary.one" />
      </c:when>
      <c:otherwise>
        <bean:message key="deployconfirm.jsp.summary" arg0="${requestScope.filenum}"/>
      </c:otherwise>
    </c:choose>
    </p>
  </div>

<html:form method="post" action="/systems/ssm/config/DeployConfirmSubmit.do">
  <rhn:csrf />
  <%@ include file="/WEB-INF/pages/common/fragments/configuration/ssm/configconfirmlist.jspf"%>

  <c:if test="${not empty requestScope.pageList}">
    <p><bean:message key="deployconfirm.jsp.widgetsummary" /></p>
      <table class="schedule-action-interface" align="center">
        <tr>
          <td><html:radio property="use_date" value="false" /></td>
          <th><bean:message key="deployconfirm.jsp.now"/></th>
        </tr>
        <tr>
          <td><html:radio property="use_date" value="true" /></td>
          <th><bean:message key="deployconfirm.jsp.usedate"/></th>
        </tr>
        <tr>
          <th><rhn:icon type="header-schedule" title="syncprofile.jsp.selection" />
          </th>
          <td>
            <jsp:include page="/WEB-INF/pages/common/fragments/date-picker.jsp">
              <jsp:param name="widget" value="date"/>
            </jsp:include>
          </td>
        </tr>
      </table>

    <div class="text-right">
      <hr />
      <html:submit property="dispatch">
        <bean:message key="deployconfirm.jsp.confirm" />
      </html:submit>
    </div>
  </c:if>
</html:form>

</body>
</html>
