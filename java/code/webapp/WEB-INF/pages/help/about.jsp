<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<html>
<body>
  <h1><rhn:icon type="header-info" /><bean:message key="help.jsp.about.title"/></h1>
  <p><bean:message key="help.jsp.about.summary"/></p>
  <div class="marketing-summary">
    <h2><bean:message key="help.jsp.about.overview"/></h2>
    <p><bean:message key="help.jsp.about.overviewsummary"/></p>
  </div>
  <c:if test="${not isSpacewalk}">
  <div class="marketing-summary">
    <h2><bean:message key="help.jsp.about.5_8"/></h2>
    <p><bean:message key="help.jsp.about.5_8summary"/></p>
  </div>
  </c:if>
</body>
</html>
