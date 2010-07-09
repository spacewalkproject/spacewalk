<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-bean" prefix="bean" %>
<%@ taglib uri="http://jakarta.apache.org/struts/tags-html" prefix="html" %>

<html:xhtml/>
<html>
<body>
<%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
<h2>
  <img src="/img/rhn-config_files.gif" alt='<bean:message key="ssmdiff.jsp.imgAlt" />' />
  <bean:message key="diffconfirm.jsp.header" />
</h2>

  <div class="page-summary">
    <p>
    <c:choose>
      <c:when test="${requestScope.filenum == 1}">
        <bean:message key="diffconfirm.jsp.summary.one" />
      </c:when>
      <c:otherwise>
        <bean:message key="diffconfirm.jsp.summary" arg0="${requestScope.filenum}"/>
      </c:otherwise>
    </c:choose>
    </p>
  </div>

<form method="post" name="rhn_list" action="/rhn/systems/ssm/config/DiffConfirmSubmit.do">
  <%@ include file="/WEB-INF/pages/common/fragments/configuration/ssm/configconfirmlist.jspf"%>

  <c:if test="${not empty requestScope.pageList}">
    <div align="right">
      <hr />
      <html:submit property="dispatch">
        <bean:message key="diffconfirm.jsp.confirm" />
      </html:submit>
    </div>
  </c:if>
</form>

</body>
</html>
