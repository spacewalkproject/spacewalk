<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>


<html>
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/ssm/header.jspf" %>
          <h2>
      <rhn:icon type="header-snapshot" />
      <bean:message key="ssm.operations.provisioning.tagsystems.header"/>
    </h2>

    <html:form styleClass="form-horizontal" action="/systems/ssm/provisioning/TagSystems" method="post">
      <rhn:csrf />
      <rhn:submitted />
      <div class="form-group">
        <label class="col-md-3 control-label">
          <bean:message key="ssm.operations.provisioning.tagsystems.label"/>
        </label>
        <div class="col-md-6">
          <input type="text" name="tag" size="30" maxlength="128" class="form-control"/>
          <span class="help-block">
            <bean:message key="ssm.operations.provisioning.tagsystems.help"/>
          </span>
        </div>
      </div>

      <div class="form-group">
        <div class="col-md-offset-3 col-md-6">
          <input type="submit" value="<bean:message key='ssm.operations.provisioning.tagsystems.button'/>" class="btn btn-success" />
        </div>
      </div>
    </html:form>

    <div class="page-summary">
      <p><bean:message key="ssm.operations.provisioning.tagsystems.summary"/></p>
    </div>

    <rl:listset name="systemsListSet" legend="system">
      <c:set var="notSelectable" value="1" />
      <c:set var="noCsv" value="1" />
      <c:set var="noAddToSsm" value="1" />
      <c:set var="noUpdates" value="1" />
      <c:set var="noErrata" value="1" />
      <c:set var="noPackages" value="1" />
      <c:set var="noConfigFiles" value="1" />
      <c:set var="noCrashes" value="1" />
      <%@ include file="/WEB-INF/pages/common/fragments/systems/system_listdisplay.jspf" %>
    </rl:listset>

  </body>
</html>
