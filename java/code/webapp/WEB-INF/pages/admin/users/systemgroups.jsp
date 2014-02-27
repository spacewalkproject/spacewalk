<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>

<html:html>
    <head>
    </head>
    <body>
    <rhn:toolbar base="h1" icon="header-organisation"
                 miscAcl="user_role(org_admin)"
                 imgAlt="users.jsp.imgAlt">
        <bean:message key="systemgroup.config.title" />
    </rhn:toolbar>

    <rhn:dialogmenu mindepth="0" maxdepth="2" definition="/WEB-INF/nav/systemgroup_config.xml" renderer="com.redhat.rhn.frontend.nav.DialognavRenderer" />

  <p>
    <bean:message key="extauth.sg.message"/>
  </p>

  <html:form method="post" action="/users/SystemGroupConfig.do" styleClass="form-horizontal">
    <div class="panel panel-default">
      <div class="panel-heading">
        <h2><bean:message key="extauth.user.create"/></h2>
      </div>
      <div class="panel-body">
        <rhn:csrf />
        <html:hidden property="submitted" value="true"/>
        <div class="form-group">
          <div class="col-md-3 control-label">
            <bean:message key="extauth.sg.default_sg"/>
          </div>
          <div class="col-md-4">
            <div class="checkbox">
              <html:checkbox property="create_default"/>
           </div>
          </div>
        </div>
      </div>
    </div>
    <hr/>
    <div class="form-group">
      <div class="col-lg-offset-3 col-md-4">
        <html:submit styleClass="btn btn-success">
          <bean:message key="config.update"/>
        </html:submit>
      </div>
    </div>
  </html:form>

</body>
</html:html>
