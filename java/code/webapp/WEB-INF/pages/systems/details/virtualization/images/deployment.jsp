<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>

<html>
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

    <html:form action="/systems/details/virtualization/Deployment" styleClass="form-horizontal">
      <html:hidden property="sid" value="${param.sid}" />
      <rhn:csrf />

      <div class="panel panel-default">
        <div class="panel-heading">
          <h4><bean:message key="images.jsp.image" /></h4>
        </div>
        <div class="panel-body">
          <div class="form-group">
            <label class="col-lg-3 control-label">
              <bean:message key="images.jsp.imageurl" />
            </label>
            <div class="col-lg-4">
              <input type="text" name="image_url" class="form-control" placeholder="<bean:message key='images.jsp.imageurl.placeholder' />" />
            </div>
          </div>
        </div>
      </div>

      <div class="panel panel-default">
        <div class="panel-heading">
          <h4><bean:message key="images.jsp.vmsetup" /></h4>
        </div>
        <div class="panel-body">
          <div class="form-group">
            <label class="col-lg-3 control-label">
              <bean:message key="images.jsp.vcpus" />
            </label>
            <div class="col-lg-2">
              <html:text property="vcpus" value="1" styleClass="form-control" />
            </div>
          </div>
          <div class="form-group">
            <label class="col-lg-3 control-label">
              <bean:message key="images.jsp.memory" />
            </label>
            <div class="col-lg-2">
              <html:text property="mem_mb" value="512" styleClass="form-control" />
            </div>
          </div>
          <div class="form-group">
            <label class="col-lg-3 control-label">
              <bean:message key="images.jsp.bridge" />
            </label>
            <div class="col-lg-2">
              <html:text property="bridge" value="br0" styleClass="form-control" />
            </div>
          </div>
        </div>
      </div>

      <div class="panel panel-default">
        <div class="panel-heading">
          <h4><bean:message key="images.jsp.proxyconfig" /></h4>
        </div>
        <div class="panel-body">
          <div class="form-group">
            <label class="col-lg-3 control-label">
              <bean:message key="images.jsp.proxyserver" />
            </label>
            <div class="col-lg-4">
              <html:text property="proxy_server" styleClass="form-control" />
            </div>
          </div>
          <div class="form-group">
            <label class="col-lg-3 control-label">
              <bean:message key="images.jsp.proxyuser" />
            </label>
            <div class="col-lg-4">
              <html:text property="proxy_user" styleClass="form-control" />
            </div>
          </div>
          <div class="form-group">
            <label class="col-lg-3 control-label">
              <bean:message key="images.jsp.proxypass" />
            </label>
            <div class="col-lg-4">
              <html:password property="proxy_pass" styleClass="form-control" />
            </div>
          </div>
        </div>
      </div>

      <div class="text-left">
        <rhn:submitted />
        <html:submit property="dispatch" styleClass="btn btn-success">
          <bean:message key="images.jsp.dispatch" />
        </html:submit>
      </div>
    </html:form>
  </body>
</html>
