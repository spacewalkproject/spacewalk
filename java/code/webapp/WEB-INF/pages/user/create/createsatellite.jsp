<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:xhtml/>
<html>
<body>
<h1><bean:message key="usercreate.createFirstLogin" /></h1>

    <div class="page-summary">
      <p><bean:message key="usercreate.satSummary" /></p>
    </div>
<br />

<jsp:include page="usercreate.jsp">
  <jsp:param name="action_path" value="/newlogin/CreateFirstUserSubmit"/>
  <jsp:param name="account_type" value="create_sat"/>
</jsp:include>


</body>
</html>

