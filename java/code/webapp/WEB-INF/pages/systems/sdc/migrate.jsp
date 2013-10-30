<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html >
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>
    <div class="panel panel-default">
      <div class="panel-heading">
        <h4><bean:message key="sdc.details.migrate.header"/></h4>
      </div>
      <div class="panel-body">
        <html:form method="post" action="/systems/details/SystemMigrate.do?sid=${system.id}">
          <rhn:csrf />
          <html:hidden property="submitted" value="true"/>
          <div class="row-0 form-group">
            <div class="col-md-2">
              <bean:message key="sdc.details.migrate.org"/>
            </div>
            <div class="col-md-3">
              <html:select property="to_org" styleClass="form-control">
                <html:option value="">-- None --</html:option>
                <c:forEach var="orgVar" items="${orgs}">
                  <html:option value="${orgVar.name}">${orgVar.name}</html:option>
                </c:forEach>
              </html:select>
            </div>
          </div>
          <hr/>
            <div class="text-right">
              <html:submit styleClass="btn btn-success">
                <bean:message key="sdc.details.migrate.migrate"/>
              </html:submit>
            </div>
        </html:form>
      </div>
    </div>
  </body>
</html:html>
