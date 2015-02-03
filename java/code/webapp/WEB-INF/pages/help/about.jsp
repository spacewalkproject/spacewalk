<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html>
<body>

    <h1><rhn:icon type="header-info" /><bean:message key="help.jsp.about.title"/></h1>
    <p><bean:message key="help.jsp.about.summary"/></p>

    <h2><bean:message key="help.jsp.about.modules"/></h2>
    <p><bean:message key="help.jsp.about.modulessummary"/></p>

  <div class="marketing-summary">
    <h3><bean:message key="help.jsp.about.update"/></h3>
    <p><bean:message key="help.jsp.about.updatesummary"/></p>
  </div>

  <div class="marketing-summary">
    <h3><bean:message key="help.jsp.about.management"/></h3>
    <p><bean:message key="help.jsp.about.managementsummary"/></p>
  </div>

  <div class="marketing-summary">
    <h3><bean:message key="help.jsp.about.provisioning"/></h3>
    <p><bean:message key="help.jsp.about.provisioningsummary"/></p>
  </div>

  <h2><bean:message key="help.jsp.about.architectures"/></h2>
  <p><bean:message key="help.jsp.about.architecturessummary"/></p>

  <div class="marketing-summary">
    <h3><bean:message key="help.jsp.about.hosted"/></h3>
    <p><bean:message key="help.jsp.about.hostedsummary"/></p>
  </div>

  <div class="marketing-summary">
    <h3><bean:message key="help.jsp.about.proxy"/></h3>
    <p><bean:message key="help.jsp.about.proxysummary"/></p>
  </div>

  <div class="marketing-summary">
    <h3><bean:message key="help.jsp.about.satellite"/></h3>
    <p><bean:message key="help.jsp.about.satellitesummary"/></p>
  </div>

</body>
</html>
